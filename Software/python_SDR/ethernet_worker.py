# 文件名: py代码/ethernet_worker.py
# (已修复：1. 添加了缺失的 send_video_frame 槽。 2. 移除了 send_audio_chunk 中的锁。)

import socket
import threading
import os
import time
import struct
import zlib
import random
from PyQt6.QtCore import QObject, pyqtSignal, pyqtSlot
from PyQt6.QtGui import QImage


CHUNK_SIZE = 1024  # 每个数据包的最大有效负载大小 (字节)
PREFIX_TEXT = b'\x00'
PREFIX_VIDEO = b'\x01'
PREFIX_FILE_DATA = b'\x02'
PREFIX_AUDIO_DATA = b'\x03'
PREFIX_FILE_INFO = b'\x0F'
PREFIX_AUDIO_STREAM = b'\x04'
PREFIX_ACK = b'\xAA'
HEADER_FORMAT = '!BI'
HEADER_SIZE = struct.calcsize(HEADER_FORMAT)
CRC_SIZE = struct.calcsize('!I')

# --- [!! 停等协议 (Stop-and-Wait) 常量 !!] ---
RETRY_COUNT = 8
ACK_TIMEOUT = 0.01

# --- [!! SR 滑动窗口 (Selective Repeat) 新增常量 !!] ---
WINDOW_SIZE = 16
# A full 1024-byte RF packet plus its reflected ACK takes several milliseconds.
# 10 ms causes premature SR retransmissions when a four-packet window is busy.
RELIABLE_TIMEOUT = 0.05
SR_MAX_RETRIES = 8

# --- [!! 發送速率 (Pacer) 新增常量 !!] ---
MIN_SEND_INTERVAL = 0.00  # 每個數據包的最小發送間隔 (秒)

# FPGA DDR3 ingress flow control.  The FPGA sends this *bare* nine-byte UDP
# payload, i.e. it does not carry this application's HEADER_FORMAT/CRC.
CREDIT_MAGIC = b'CRED'
CREDIT_PACKET_LEN = 9
CREDIT_VERSION = 1
CREDIT_WAIT_TIMEOUT = 0.20


# --- [!! 結束新增 !!] ---


class EthernetWorker(QObject):
    """
    (文档已更新)
    - 增加了对"隐形"P2P LAN模式的支持。
    - 为文件/音频传输实现了 SR (Selective Repeat) 滑动窗口协议。
    - 為 SR 增加了最大重傳次數限制。
    - 為所有數據包添加了最小發送間隔 (Pacer)。
    """

    # (信号保持不变)
    started = pyqtSignal()
    stopped = pyqtSignal()
    log_received = pyqtSignal(str)
    video_frame_ready = pyqtSignal(QImage)
    error_occurred = pyqtSignal(str)
    finished = pyqtSignal()
    file_received = pyqtSignal(str, bytes)
    audio_chunk_received = pyqtSignal(bytes)
    # free MTU-packet slots, whether an FPGA report has been seen, whether the
    # current state is the CRED-timeout fallback.
    ddr_credit_updated = pyqtSignal(int, bool, bool)

    file_send_progress = pyqtSignal(int, int, float)
    file_receive_progress = pyqtSignal(int, int, float)
    file_receive_started = pyqtSignal(str, int)
    file_transfer_finished = pyqtSignal(bool, str)

    def __init__(self):
        super().__init__()
        self.sock = None
        self._running = False
        self.fpga_addr = None
        self._recv_thread = None
        self._lock = threading.Lock()
        self.is_receiving_file = False
        self.current_file_info = {}
        self.file_buffer = bytearray()
        self.enable_file_reception = False
        self.is_lan_mode = False
        self.ack_event = threading.Event()
        self.last_received_ack_seq = -1
        # ACK only carries a 32-bit sequence number.  Never reuse seq=0 for
        # unrelated text commands and file headers, otherwise an old echoed
        # ACK can falsely complete a newly-started transfer.
        self._next_tx_sequence = random.randint(1, 0x3FFFFFFF)

        # --- [!! 新增：视频组包缓存 !!] ---
        # 结构: { frame_id: { 'chunks': {idx: data}, 'total': count, 'timestamp': time } }
        self.video_reassembly_buffer = {}
        # 用于发送端的帧计数器
        self.tx_video_frame_id = 0
        # -------------------------------

        # --- 接收方状态 (SR 修改) ---
        self.recv_base = 0  # 接收窗口基址
        self.recv_buffer = {}  # {seq_num: payload} 存储乱序到达的包
        self.recv_acked = set()  # 已确认的序列号集合

        # --- SR (Selective Repeat) 发送方状态 ---
        self.send_base = 0
        self.next_seq_num = 0
        self.send_buffer = {}  # {seq_num: packet_bytes}
        self.send_timers = {}  # {seq_num: Timer对象}
        self.send_retry_count = {}  # {seq_num: 重传次数}
        self.sr_lock = threading.Lock()
        self.window_space_cv = threading.Condition(self.sr_lock)
        self.sr_transfer_active = False
        self.pacer_lock = threading.Lock()
        self.last_send_time = 0

        # FPGA DDR3 queue credit state.  CRED's sequence number counts ingress
        # frames accepted by the FPGA, so locally sent but not yet reported
        # frames must be subtracted from the most recent free-slot report.
        self.credit_cv = threading.Condition()
        self.credit_packets = 0
        self.credit_sequence = None
        self.credit_sent_count = 0
        self.credit_acknowledged_sends = 0
        self.credit_known = False
        self.credit_bootstrap_sent = False
        self.credit_timeout_fallback = False
        self.credit_timeouts = 0

    @staticmethod
    def _credit_sequence_delta(new_value, old_value):
        if old_value is None:
            return None
        return (new_value - old_value) & 0xFFFF

    def _emit_credit_status(self):
        with self.credit_cv:
            free_packets = self.credit_packets
            known = self.credit_known
            fallback = self.credit_timeout_fallback
        self.ddr_credit_updated.emit(free_packets, known, fallback)

    def _reset_credit_state(self):
        with self.credit_cv:
            self.credit_packets = 0
            self.credit_sequence = None
            self.credit_sent_count = 0
            self.credit_acknowledged_sends = 0
            self.credit_known = False
            self.credit_bootstrap_sent = False
            self.credit_timeout_fallback = False
            self.credit_timeouts = 0
            self.credit_cv.notify_all()
        self._emit_credit_status()

    def _handle_credit_packet(self, data):
        """Handle the FPGA's bare CRED v1 UDP datagram."""
        if len(data) != CREDIT_PACKET_LEN or not data.startswith(CREDIT_MAGIC):
            return False
        if data[4] != CREDIT_VERSION:
            self.log_received.emit(f"[流控警告] 忽略未知 CRED 版本: {data[4]}")
            return True

        free_packets = int.from_bytes(data[5:7], 'big')
        ingress_sequence = int.from_bytes(data[7:9], 'big')
        with self.credit_cv:
            delta = self._credit_sequence_delta(ingress_sequence, self.credit_sequence)
            if delta is None:
                # The bootstrap rule allows only the first packet before an
                # FPGA report, therefore all previous local sends are known.
                self.credit_acknowledged_sends = self.credit_sent_count
                self.credit_known = True
            elif 0 < delta <= 0x7FFF:
                self.credit_acknowledged_sends = min(
                    self.credit_sent_count,
                    self.credit_acknowledged_sends + delta)
            elif delta > 0x7FFF:
                # Delayed old UDP report.  Keep the newer state unchanged.
                return True

            self.credit_sequence = ingress_sequence
            self.credit_packets = free_packets
            self.credit_timeout_fallback = False
            self.credit_cv.notify_all()
        self._emit_credit_status()
        return True

    def _credit_slots_available_locked(self):
        if self.credit_timeout_fallback:
            return 1
        if not self.credit_known:
            return 0 if self.credit_bootstrap_sent else 1
        outstanding = self.credit_sent_count - self.credit_acknowledged_sends
        return max(0, self.credit_packets - outstanding)

    def _reserve_credit_slot(self, timeout=CREDIT_WAIT_TIMEOUT):
        """Reserve one FPGA ingress slot before sending a non-ACK packet."""
        timed_out = False
        with self.credit_cv:
            deadline = time.monotonic() + timeout
            while self._credit_slots_available_locked() <= 0:
                remaining = deadline - time.monotonic()
                if remaining <= 0:
                    # CRED is UDP too.  Do not let one lost status packet
                    # permanently stall the entire GUI transfer.
                    self.credit_timeout_fallback = True
                    self.credit_timeouts += 1
                    timed_out = True
                    break
                self.credit_cv.wait(min(remaining, 0.05))

            self.credit_sent_count += 1
            self.credit_bootstrap_sent = True

        if timed_out:
            self.log_received.emit(
                "[流控警告] CRED 超时；暂按 FPGA 缓冲区未满继续发送，"
                "收到下一份 CRED 后恢复严格流控")
            self._emit_credit_status()
        return True

    def _note_unreserved_credit_send(self):
        """Account for an urgent ACK sent directly by the receive thread."""
        with self.credit_cv:
            self.credit_sent_count += 1
            self.credit_bootstrap_sent = True

    @pyqtSlot(bool)
    def set_lan_mode(self, enabled):
        # (此方法保持不变)
        self.is_lan_mode = enabled
        # if enabled:
        #     self.log_received.emit(f"--- [!] 局域网P2P模式已激活 (目标: {LAN_TARGET_IP}:{LAN_PORT}) ---")
        # else:
        #     self.log_received.emit("--- [!] 局域网P2P模式已停用 (返回FPGA模式) ---")

    def start_listening(self, listen_ip, listen_port, fpga_ip, fpga_port):
        # (此方法保持不变)
        with self._lock:
            if self._recv_thread and self._recv_thread.is_alive():
                self.log_received.emit("[警告] 监听已在运行,请先停止。")
                return
            local_listen_ip = listen_ip
            local_listen_port = listen_port

            self.fpga_addr = (fpga_ip, fpga_port)
            self.recv_base = 0
            self.recv_buffer.clear()
            self.recv_acked.clear()
            self._reset_credit_state()
            self._running = True
            self._recv_thread = threading.Thread(
                target = self._recv_loop, args = (local_listen_ip, local_listen_port), daemon = True
            )
            self._recv_thread.start()
        self.started.emit()
        # self.log_received.emit(f"UDP 正在监听 {local_listen_ip}:{local_listen_port}...")

    def _recv_loop(self, listen_ip, listen_port):
        """
        SR 接收逻辑
        """
        try:
            self.sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            self.sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            self.sock.settimeout(0.5)
            try:
                self.sock.bind((listen_ip, listen_port))
            except Exception as e:
                self.error_occurred.emit(f"UDP 绑定失败: {e} (地址: {listen_ip}:{listen_port})")
                return

            while self._running:
                try:
                    data, addr = self.sock.recvfrom(65536)
                    # CRED is a bare FPGA control datagram, not one of this
                    # application's prefix/sequence/CRC packets.
                    if self._handle_credit_packet(data):
                        continue
                    if not data or len(data) < (HEADER_SIZE + CRC_SIZE):
                        continue

                    # CRC 校验
                    received_crc = struct.unpack('!I', data[-CRC_SIZE:])[0]
                    data_without_crc = data[:-CRC_SIZE]
                    calculated_crc = zlib.crc32(data_without_crc)
                    if received_crc != calculated_crc:
                        self.log_received.emit(f"[UDP 错误] 收到 CRC 校验失败的包,已丢弃")
                        continue

                    # 解析包头
                    prefix_byte, seq_num = struct.unpack(HEADER_FORMAT, data_without_crc[:HEADER_SIZE])
                    prefix = bytes([prefix_byte])
                    payload = data_without_crc[HEADER_SIZE:]

                    # ============================================
                    # [!! 文本命令完全独立处理 !!]
                    # ============================================
                    if prefix == PREFIX_TEXT:
                        try:
                            text_message = payload.decode('utf-8').strip()
                            if text_message:
                                self.log_received.emit(f"[UDP 消息]: {text_message}")
                        except Exception:
                            self.log_received.emit(f"[UDP 警告] 收到无法解码的文本包")
                        self._send_ack(seq_num, addr)
                        continue

                    # ============================================
                    # [!! 🔥 关键修复：提前检测并处理文件头 !!]
                    # ============================================
                    if prefix == PREFIX_FILE_INFO:
                        # A file header establishes the next expected SR
                        # sequence even when the local user only *sends* a
                        # file.  In RF loopback the sender sees its own
                        # header/data again; without this reset recv_base
                        # remains 0, so seq=4 is wrongly rejected as outside
                        # the [0, 3] receive window and retransmits forever.
                        self.recv_base = seq_num + 1
                        self.recv_buffer.clear()
                        self.recv_acked.clear()

                        if not self.enable_file_reception:
                            self._send_ack(seq_num, addr)
                            continue

                        try:
                            info_str = payload.decode('utf-8')
                            filename, filesize_str = info_str.split(':', 1)
                            filesize = int(filesize_str)

                            # 重置文件接收状态
                            self.current_file_info = {
                                "name": filename,
                                "size": filesize,
                                "start_time": time.time()
                            }
                            self.file_buffer.clear()
                            self.is_receiving_file = True

                            # 发射接收开始信号
                            self.file_receive_started.emit(filename, filesize)
                            self.file_receive_progress.emit(0, filesize, 0.0)

                            self.log_received.emit(
                                f"[UDP 文件] (SEQ={seq_num}) 开始接收: {filename} ({filesize} 字节)"
                            )

                        except Exception as e:
                            self.log_received.emit(f"[UDP 错误] 收到损坏的文件头: {e}")
                            self.is_receiving_file = False

                        # 发送 ACK
                        self._send_ack(seq_num, addr)
                        continue  # 跳过后续 SR 处理
                    # ============================================

                    # ACK 包处理
                    if prefix == PREFIX_ACK:
                        self.last_received_ack_seq = seq_num
                        self.ack_event.set()
                        with self.sr_lock:
                            if seq_num in self.send_buffer:
                                self._sr_stop_timer(seq_num)
                                self.send_buffer.pop(seq_num, None)
                                self.send_retry_count.pop(seq_num, None)
                                if seq_num == self.send_base:
                                    while self.send_base < self.next_seq_num and self.send_base not in self.send_buffer:
                                        self.send_base += 1
                                self.window_space_cv.notify_all()
                        continue

                    # 视频包处理 (分片重组)
                    if prefix == PREFIX_VIDEO:
                        try:
                            vid_fid = data_without_crc[1]
                            vid_idx = data_without_crc[2]
                            vid_total = data_without_crc[3]
                            vid_payload = data_without_crc[4:]

                            if vid_fid not in self.video_reassembly_buffer:
                                self.video_reassembly_buffer[vid_fid] = {
                                    'chunks': {},
                                    'total': vid_total,
                                    'ts': time.time()
                                }

                            self.video_reassembly_buffer[vid_fid]['chunks'][vid_idx] = vid_payload
                            current_frame = self.video_reassembly_buffer[vid_fid]

                            if len(current_frame['chunks']) == vid_total:
                                full_jpeg = bytearray()
                                for k in range(vid_total):
                                    if k in current_frame['chunks']:
                                        full_jpeg.extend(current_frame['chunks'][k])

                                image = QImage()
                                if image.loadFromData(full_jpeg, "WEBP"):
                                    self.video_frame_ready.emit(image)

                                del self.video_reassembly_buffer[vid_fid]

                                # 清理过期帧
                                now = time.time()
                                expired_ids = [k for k, v in self.video_reassembly_buffer.items()
                                               if now - v['ts'] > 1.0]
                                for k in expired_ids:
                                    del self.video_reassembly_buffer[k]
                        except Exception as e:
                            pass
                        continue

                    # 音频流处理 (不可靠)
                    if prefix == PREFIX_AUDIO_STREAM:
                        self.audio_chunk_received.emit(payload)
                        continue

                    # ============================================
                    # SR 窗口逻辑 (仅用于文件数据传输)
                    # ============================================

                    # 检查是否为旧包
                    if seq_num < self.recv_base:
                        # 重发 ACK (可能是重传包)
                        self._send_ack(seq_num, addr)
                        continue

                    # 检查是否超出窗口
                    if seq_num >= self.recv_base + WINDOW_SIZE:
                        self.log_received.emit(
                            f"[UDP SR] 收到超出窗口的包 {seq_num} "
                            f"(窗口 [{self.recv_base}, {self.recv_base + WINDOW_SIZE - 1}]), 已丢弃"
                        )
                        continue

                    # 发送 ACK
                    self._send_ack(seq_num, addr)

                    # 检查是否已确认
                    if seq_num in self.recv_acked:
                        continue

                    # 缓存数据包
                    self.recv_buffer[seq_num] = (prefix, payload)
                    self.recv_acked.add(seq_num)

                    # 滑动窗口 - 处理所有连续的已确认包
                    while self.recv_base in self.recv_acked:
                        recv_prefix, recv_payload = self.recv_buffer.pop(self.recv_base)
                        self.recv_acked.remove(self.recv_base)

                        # 处理数据包
                        self._process_received_packet(recv_prefix, self.recv_base, recv_payload, addr)

                        # 窗口滑动
                        self.recv_base += 1

                except socket.timeout:
                    continue
                except Exception as e:
                    if self._running:
                        self.error_occurred.emit(f"UDP 接收错误: {e}")
                    break

        finally:
            try:
                if self.sock:
                    self.sock.close()
            except Exception:
                pass
            self.sock = None
            self._running = False
            self.stopped.emit()
            self.finished.emit()
            self.log_received.emit("UDP 监听已停止")

    def _process_received_packet(self, prefix, seq_num, payload, addr):
        """
        处理已确认接收的数据包
        注意: PREFIX_TEXT 不会到达这里,已在 _recv_loop 中处理
        """
        if prefix == PREFIX_FILE_INFO:
            if not self.enable_file_reception:
                return
            try:
                info_str = payload.decode('utf-8')
                filename, filesize_str = info_str.split(':', 1)
                filesize = int(filesize_str)

                # === [!! 关键修复: 重置接收窗口 !!] ===
                self.recv_base = 0
                self.recv_buffer.clear()
                self.recv_acked.clear()
                # === [!! 修复结束 !!] ===

                self.current_file_info = {
                    "name": filename,
                    "size": filesize,
                    "start_time": time.time()
                }
                self.file_buffer.clear()
                self.is_receiving_file = True

                # 发射接收开始信号
                self.file_receive_started.emit(filename, filesize)
                self.file_receive_progress.emit(0, filesize, 0.0)

                self.log_received.emit(
                    f"[UDP 文件] (SEQ={seq_num}) 开始接收: {filename} ({filesize} 字节)"
                )
            except Exception as e:
                self.log_received.emit(f"[UDP 错误] 收到损坏的文件头: {e}")
                self.is_receiving_file = False

        elif prefix == PREFIX_FILE_DATA:
            if self.is_receiving_file:
                self.file_buffer.extend(payload)

                # 发射接收进度信号
                total_size = self.current_file_info.get("size", -1)
                received_bytes = len(self.file_buffer)

                # 计算实时速率
                start_time = self.current_file_info.get("start_time", time.time())
                elapsed = time.time() - start_time
                if elapsed > 0:
                    speed_mbps = (received_bytes * 8) / (elapsed * 1024 * 1024)
                else:
                    speed_mbps = 0.0

                self.file_receive_progress.emit(received_bytes, total_size, speed_mbps)

                if received_bytes >= total_size:
                    file_data_bytes = self.file_buffer[:total_size]
                    filename = self.current_file_info.get("name", "unknown_file")

                    self.log_received.emit(f"[UDP 文件] 接收完毕: {filename}")
                    self.file_transfer_finished.emit(True, "接收完成")
                    self.file_received.emit(filename, bytes(file_data_bytes))

                    self.is_receiving_file = False
                    self.file_buffer.clear()
                    self.current_file_info.clear()

                    # === [!! 可选: 这里也可以重置,作为双重保险 !!] ===
                    self.recv_base = 0
                    self.recv_buffer.clear()
                    self.recv_acked.clear()
                    # === [!! 修复结束 !!] ===

        elif prefix == PREFIX_AUDIO_DATA:
            self.log_received.emit(f"[UDP 消息] 收到一个音频包 (SEQ={seq_num}) (暂不处理)")

        elif prefix == PREFIX_TEXT:
            # 理论上不会到这里,因为已在 _recv_loop 中处理
            try:
                text_message = payload.decode('utf-8').strip()
                if text_message:
                    self.log_received.emit(f"[UDP 消息]: {text_message}")
            except Exception:
                pass

        else:
            self.log_received.emit(f"[UDP 警告] 收到未知前缀的包: 0x{prefix.hex()}")

    def stop_listening(self):
        # (保持不变)
        self._running = False
        self.log_received.emit("停止请求已发送 -> 正在等待接收线程退出...")

    def set_file_reception_enabled(self, enabled: bool):
        # (保持不变)
        self.enable_file_reception = enabled
        if enabled:
            self.log_received.emit("文件接收已启用")
        else:
            self.log_received.emit("文件接收已禁用")
            if self.is_receiving_file:
                self.is_receiving_file = False
                self.file_buffer.clear()
                self.current_file_info.clear()
                self.log_received.emit("[警告] 文件接收已中止")

    def _pack_data(self, prefix: bytes, seq_num: int, payload: bytes) -> bytes:
        # (保持不变)
        header = struct.pack(HEADER_FORMAT, prefix[0], seq_num)
        data_without_crc = header + payload
        crc = zlib.crc32(data_without_crc)
        return data_without_crc + struct.pack('!I', crc)

    def _allocate_tx_sequence_range(self, count: int) -> int:
        """Return a non-overlapping sequence range for one outbound transfer.

        Callers already hold ``self._lock``.  A range is used for a file so
        its header and every SR chunk cannot be acknowledged by delayed ACKs
        belonging to an earlier command or transfer.
        """
        count = max(1, count)
        if self._next_tx_sequence + count - 1 > 0xFFFFFFFF:
            # Wrap only between transfers, never inside one file's sequence
            # range.  Choosing a non-zero new base avoids the historical
            # all-transactions-use-zero collision.
            self._next_tx_sequence = 1
        start_seq = self._next_tx_sequence
        self._next_tx_sequence += count
        return start_seq

    def _send_udp_payload(self, raw_bytes: bytes) -> bool:
        """
        [!! 重大修改: 添加 Pacer (速率控制器) !!]
        這是所有數據包的底層發送函數。
        ACK 包 (send_ack) 不會調用此函數。
        """
        addr = self.fpga_addr
        if not addr:
            self.error_occurred.emit("发送失败: 目标地址未设置")
            return False
        if not self._reserve_credit_slot():
            return False
        with self.pacer_lock:
            now = time.time()
            elapsed = now - self.last_send_time
            if elapsed < MIN_SEND_INTERVAL:
                time.sleep(MIN_SEND_INTERVAL - elapsed)
            self.last_send_time = time.time()
        try:
            if self.sock:
                self.sock.sendto(raw_bytes, addr)
                return True
            else:
                with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as tmp_sock:
                    tmp_sock.sendto(raw_bytes, addr)
                    return True
        except Exception as e:
            self.error_occurred.emit(f"UDP 发送失败: {e}")
            return False

    def _send_ack(self, seq_num_to_ack: int, target_addr: tuple):
        # (此方法保持不变)
        ack_packet = self._pack_data(PREFIX_ACK, seq_num_to_ack, b'')
        try:
            if self.sock:
                self.sock.sendto(ack_packet, target_addr)
                # The receive thread must never wait for CRED here, otherwise
                # it could prevent the very CRED packet that releases it from
                # being received.  Still include the ACK in local accounting.
                if target_addr == self.fpga_addr:
                    self._note_unreserved_credit_send()
        except Exception as e:
            self.log_received.emit(f"发送 ACK {seq_num_to_ack} 失败: {e}")

    # --- (SR 辅助函数: _sr_start_timer, _sr_stop_timer, _sr_handle_timeout, _send_sr_stream 保持不变) ---
    def _sr_start_timer(self, seq_num):
        self._sr_stop_timer(seq_num)
        timer = threading.Timer(RELIABLE_TIMEOUT, self._sr_handle_timeout, args = (seq_num,))
        timer.daemon = True
        self.send_timers[seq_num] = timer
        timer.start()

    def _sr_stop_timer(self, seq_num):
        """停止特定序列号的计时器"""
        if seq_num in self.send_timers:
            self.send_timers[seq_num].cancel()
            self.send_timers.pop(seq_num, None)

    def _sr_handle_timeout(self, seq_num):
        """处理特定包的超时"""
        with self.sr_lock:
            if not self.sr_transfer_active:
                return
            if seq_num not in self.send_buffer:
                return
            retry_count = self.send_retry_count.get(seq_num, 0) + 1
            self.send_retry_count[seq_num] = retry_count
            if retry_count >= SR_MAX_RETRIES:
                self.error_occurred.emit(
                    f"[UDP SR 错误] 包 {seq_num} 达到最大重传次数 ({SR_MAX_RETRIES})。中止传输。")
                self.sr_transfer_active = False
                for sn in list(self.send_timers.keys()):
                    self._sr_stop_timer(sn)
                self.window_space_cv.notify_all()
                return
            # self.log_received.emit(
            #     f"[UDP SR 重传] 包 {seq_num} 超时! ({retry_count}/{SR_MAX_RETRIES}) 重传")
            packet = self.send_buffer.get(seq_num)
            if packet:
                self._send_udp_payload(packet)
                self._sr_start_timer(seq_num)

    def _send_sr_stream(self, prefix: bytes, start_seq: int, chunk_iterator) -> bool:
        with self.sr_lock:
            self.send_base = start_seq
            self.next_seq_num = start_seq
            self.send_buffer.clear()
            self.send_retry_count.clear()
            for seq_num in list(self.send_timers.keys()):
                self._sr_stop_timer(seq_num)
            self.sr_transfer_active = True
        try:
            chunk_cache = {}
            chunk_gen = iter(chunk_iterator)
            current_packet_index = 0
            all_chunks_loaded = False
            while not all_chunks_loaded or self.send_base < self.next_seq_num:
                with self.sr_lock:
                    if not self._running:
                        self.error_occurred.emit("SR 发送中止 (1)")
                        return False
                    if not self.sr_transfer_active:
                        self.error_occurred.emit("SR 发送中止 (因最大重传)")
                        return False
                    while (self.next_seq_num - self.send_base) < WINDOW_SIZE and not all_chunks_loaded:
                        try:
                            chunk = next(chunk_gen)
                        except StopIteration:
                            all_chunks_loaded = True
                            break
                        current_seq = start_seq + current_packet_index
                        chunk_cache[current_seq] = chunk
                        packet = self._pack_data(prefix, current_seq, chunk)
                        self.send_buffer[current_seq] = packet
                        self.send_retry_count[current_seq] = 0
                        self._send_udp_payload(packet)
                        self._sr_start_timer(current_seq)
                        self.next_seq_num += 1
                        current_packet_index += 1
                with self.sr_lock:
                    if not self._running:
                        self.error_occurred.emit("SR 发送中止 (2)")
                        return False
                    if not self.sr_transfer_active:
                        self.error_occurred.emit("SR 发送中止 (因最大重传)")
                        return False
                    if (self.next_seq_num - self.send_base) >= WINDOW_SIZE and not all_chunks_loaded:
                        self.window_space_cv.wait(RELIABLE_TIMEOUT * 2)
                    elif all_chunks_loaded and self.send_base < self.next_seq_num:
                        self.window_space_cv.wait(RELIABLE_TIMEOUT * 2)
                    acked_keys = [k for k in chunk_cache if k < self.send_base]
                    for k in acked_keys:
                        chunk_cache.pop(k, None)
            self.log_received.emit(f"-> [UDP SR 流] (Prefix 0x{prefix.hex()}) 发送完成。")
            return True
        except Exception as e:
            self.error_occurred.emit(f"SR 流发送失败: {e}")
            return False
        finally:
            with self.sr_lock:
                for seq_num in list(self.send_timers.keys()):
                    self._sr_stop_timer(seq_num)
                self.send_buffer.clear()
                self.send_retry_count.clear()
                self.sr_transfer_active = False

    def _send_reliable_payload(self, prefix: bytes, seq_num: int, payload: bytes) -> bool:
        # (此方法保持不变)
        packet = self._pack_data(prefix, seq_num, payload)
        for i in range(RETRY_COUNT):
            self.ack_event.clear()
            self.last_received_ack_seq = -1
            if not self._send_udp_payload(packet):
                self.error_occurred.emit("UDP 套接字发送失败,中止重试")
                return False
            if self.ack_event.wait(ACK_TIMEOUT):
                if self.last_received_ack_seq == seq_num:
                    return True
                else:
                    self.log_received.emit(
                        f"[UDP 警告] 收到错误 ACK (Seq={self.last_received_ack_seq}, 期望={seq_num})")
            self.log_received.emit(
                f"[UDP 重试] 包 {seq_num} (Prefix 0x{prefix.hex()}) 未收到 ACK ({i + 1}/{RETRY_COUNT})")
        self.error_occurred.emit(f"包 {seq_num} (Prefix 0x{prefix.hex()}) 发送失败 {RETRY_COUNT} 次,已放弃")
        return False

    def _send_unreliable_payload(self, prefix: bytes, payload: bytes) -> bool:
        """
        (此方法保持不变, Pacer 將在 _send_udp_payload 中自動應用)
        """
        packet = self._pack_data(prefix, 0, payload)
        return self._send_udp_payload(packet)

    def send_command(self, cmd_str: str):
        # (保持不变 - 停等协议)
        with self._lock:
            seq_num = self._allocate_tx_sequence_range(1)
            payload = cmd_str.encode('utf-8')
            self.log_received.emit(f"-> [UDP发送 文本]: {cmd_str} (SEQ={seq_num})")
            success = self._send_reliable_payload(PREFIX_TEXT, seq_num, payload)
            if success:
                self.log_received.emit(f"-> [UDP发送 文本]: {cmd_str} 完成,序列号已重置")
            else:
                self.log_received.emit(f"-> [UDP发送 文本]: {cmd_str} 失败")

    def send_file_udp(self, file_path: str):
        """
        [!! SR !!]
        1. 使用 "停等" (_send_reliable_payload) 发送唯一序号的文件头
        2. 使用 "SR" (_send_sr_stream) 发送紧随其后的唯一序号数据块
        添加了进度信号发射
        """
        with self._lock:
            if not self.fpga_addr:
                self.error_occurred.emit("发送失败: 目标地址未设置")
                self.file_transfer_finished.emit(False, "目标地址未设置")
                return
            try:
                file_size = os.path.getsize(file_path)
                filename = os.path.basename(file_path)
                self.log_received.emit(f"-> [UDP发送 文件]: {filename} ({file_size} 字节)")
                start_time = time.time()

                # 发送前发射初始进度
                self.file_send_progress.emit(0, file_size, 0.0)

                # Each transfer owns one unique on-wire sequence range.  This
                # prevents a delayed ACK for a previous TEST command/header
                # from being mistaken for this file header's ACK.
                chunk_count = (file_size + CHUNK_SIZE - 1) // CHUNK_SIZE
                seq_num = self._allocate_tx_sequence_range(chunk_count + 1)
                info_str = f"{filename}:{file_size}"
                info_payload = info_str.encode('utf-8')
                self.log_received.emit(f"-> [UDP发送 文件头] (SEQ={seq_num})")
                if not self._send_reliable_payload(PREFIX_FILE_INFO, seq_num, info_payload):
                    self.error_occurred.emit("文件头发送失败,未收到 ACK")
                    self.file_transfer_finished.emit(False, "文件头发送失败")
                    return
                self.log_received.emit(f"-> [UDP发送 文件头] 完成")

                # --- 2. 发送文件数据 (SEQ=1...N, SR) 带进度 ---
                sent_bytes = 0

                def file_chunk_generator_with_progress(f):
                    nonlocal sent_bytes
                    while True:
                        chunk = f.read(CHUNK_SIZE)
                        if not chunk:
                            break
                        sent_bytes += len(chunk)

                        # 计算实时速率
                        elapsed = time.time() - start_time
                        if elapsed > 0:
                            speed_mbps = (sent_bytes * 8) / (elapsed * 1024 * 1024)
                        else:
                            speed_mbps = 0.0

                        # 发射进度信号
                        self.file_send_progress.emit(sent_bytes, file_size, speed_mbps)

                        yield chunk

                with open(file_path, 'rb') as f:
                    start_seq_num = seq_num + 1
                    self.log_received.emit(f"-> [UDP SR 发送] 文件数据 (从 SEQ={start_seq_num} 开始)...")
                    if not self._send_sr_stream(PREFIX_FILE_DATA, start_seq_num,
                                                file_chunk_generator_with_progress(f)):
                        self.error_occurred.emit(f"文件数据块发送失败 (SR)")
                        self.file_transfer_finished.emit(False, "数据发送失败")
                        return

                end_time = time.time()
                elapsed = end_time - start_time
                speed_mbps = (file_size * 8) / (elapsed * 1024 * 1024) if elapsed > 0 else 0

                # 最终进度
                self.file_send_progress.emit(file_size, file_size, speed_mbps)
                self.file_transfer_finished.emit(True, "发送完成")

                self.log_received.emit(
                    f"-> [UDP发送 文件]: {filename} 完成, "
                    f"耗时: {elapsed:.2f} 秒, "
                    f"速度: {speed_mbps:.2f} Mbps ({file_size} 字节)"
                )
            except FileNotFoundError:
                self.error_occurred.emit(f"文件未找到: {file_path}")
                self.file_transfer_finished.emit(False, "文件未找到")
            except Exception as e:
                self.error_occurred.emit(f"文件发送失败: {e}")
                self.file_transfer_finished.emit(False, str(e))

    def send_audio_udp(self, audio_bytes: bytes):
        """
        [!! SR !!]
        1. 使用 "SR" (_send_sr_stream) 发送所有音频数据块 (SEQ=0...N)
        """
        with self._lock:
            if not self.fpga_addr:
                self.error_occurred.emit("发送失败: 目标地址未设置")
                return
            data_size = len(audio_bytes)
            self.log_received.emit(f"-> [UDP SR 发送 音频]: {data_size} 字节至 {self.fpga_addr}")
            try:
                def audio_chunk_generator(data, size):
                    idx = 0
                    while idx < len(data):
                        yield data[idx: idx + size]
                        idx += size

                chunk_count = (data_size + CHUNK_SIZE - 1) // CHUNK_SIZE
                start_seq_num = self._allocate_tx_sequence_range(chunk_count)
                start_time = time.time()
                success = self._send_sr_stream(PREFIX_AUDIO_DATA, start_seq_num,
                                               audio_chunk_generator(audio_bytes, CHUNK_SIZE))
                end_time = time.time()
                if not success:
                    self.error_occurred.emit("音频发送中断 (SR)")
                    return
                elapsed = end_time - start_time
                speed_mbps = (data_size * 8) / (elapsed * 1024 * 1024) if elapsed > 0 else 0
                self.log_received.emit(
                    f"-> [UDP SR 发送 音频]: 完成, "
                    f"耗时: {elapsed:.2f} 秒, "
                    f"速度: {speed_mbps:.2f} Mbps ({data_size} 字节)"
                )
            except Exception as e:
                self.error_occurred.emit(f"音频发送失败: {e}")

    @pyqtSlot(bytes)
    def send_audio_chunk(self, audio_data: bytes):
        """
        (不可靠的实时流发送)
        """
        with self._lock:
            if not self.fpga_addr:
                return

        if not self._send_unreliable_payload(PREFIX_AUDIO_STREAM, audio_data):
            pass
    #     # --- [!! 修复结束 2 !!] ---
    #
    # --- [!! 关键修复 1 (Bug 214a27) !!] ---
    # @pyqtSlot(bytes)
    # def send_video_frame(self, jpeg_data: bytes):
    #     """
    #     [公共槽] 发送一个实时视频帧 (不可靠)
    #     (不使用 self._lock)
    #     """
    #     if not self.fpga_addr:
    #         return
    #
    # #     # 使用 PREFIX_VIDEO (0x01)，这是为视频保留的
    # #     if not self._send_unreliable_payload(PREFIX_VIDEO, jpeg_data):
    # #         pass  # 丢包, 忽略
    @pyqtSlot(bytes)
    def send_video_frame(self, jpeg_data: bytes):
        """
        [修改版] 视频分包发送逻辑
        协议头 (4 bytes): [0x01 (Prefix)] [Frame_ID] [Packet_Idx] [Total_Packets]
        """
        if not self.fpga_addr:
            return

        # FPGA 限制 1400，我们设定 Payload 为 1024，留足余量
        MAX_PAYLOAD = 1024
        total_len = len(jpeg_data)

        # 计算总包数 (向上取整)
        total_packets = (total_len + MAX_PAYLOAD - 1) // MAX_PAYLOAD

        # 限制最大包数 (因为包头里 Total_Packets 只有 1 byte，最大 255)
        if total_packets > 255:
            print(f"[丢弃] 视频帧过大: {total_len} bytes (需要 {total_packets} 包 > 255)")
            return

        # 帧 ID 自增 (0-255 循环)
        self.tx_video_frame_id = (self.tx_video_frame_id + 1) % 256
        fid = self.tx_video_frame_id

        # 循环发送每个分片
        for i in range(total_packets):
            start = i * MAX_PAYLOAD
            end = min(start + MAX_PAYLOAD, total_len)
            chunk = jpeg_data[start:end]

            # 构建包头: Prefix(1) + FID(1) + Index(1) + Total(1)
            # 1. 构建包内容: Prefix(1) + FID(1) + Index(1) + Total(1) + Data(...)
            # 注意：这里 Prefix 是 0x01 (PREFIX_VIDEO)
            header = struct.pack('!BBBB', 0x01, fid, i, total_packets)
            data_without_crc = header + chunk
            # --- [!! 核心修复 !!] ---
            # 2. 计算 CRC32
            crc = zlib.crc32(data_without_crc)

            # 3. 拼接完整的带 CRC 的包
            final_packet = data_without_crc + struct.pack('!I', crc)

            # 这里的 send_udp_payload 会处理 socket 发送
            # 视频允许丢包，所以我们不使用可靠重传 (Stop-and-Wait/SR)
            # 4. 发送
            self._send_udp_payload(final_packet)

            # [重要] 微小延时，防止瞬间突发流量淹没 FPGA 的 2Mbps 带宽
            # 1024 bytes * 8 bits = 8192 bits.
            # 2Mbps = 2,000,000 bits/s.
            # 理论最小间隔 ≈ 0.004s。设置为 0.002s 比较激进但流畅。
            time.sleep(0.002)
