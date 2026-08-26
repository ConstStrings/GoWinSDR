# 文件名: py代码/main_window.py
# (已修改: 添加文件传输进度信号连接)

from PyQt6.QtWidgets import (QMainWindow, QWidget, QHBoxLayout, QVBoxLayout,
                             QSplitter, QTabWidget)
from PyQt6.QtCore import QThread, Qt, QTimer, pyqtSlot
import numpy as np
import threading

from config_widget import ConfigWidget
from params_widget import ParamsWidget
from text_audio_widget import TextAudioWidget
from file_send_widget import FileSendWidget
from file_receive_widget import FileReceiveWidget
from log_widget import LogWidget
from serial_worker import SerialWorker
from ethernet_widget import EthernetWidget
from video_widget import VideoWidget
from ethernet_worker import EthernetWorker
from audio_worker import AudioWorker
from realtime_audio_widget import RealtimeAudioWidget
from audio_stream_worker import AudioInputWorker, AudioOutputWorker
from realtime_video_widget import RealtimeVideoWidget
from camera_worker import CameraWorker
from iot_widget import IoTWidget
from temperature_fan_widget import TemperatureFanWidget

try:
    from ad9363_config import AD9363_GET_COMMANDS
except ImportError:
    print("警告: 未找到 ad9363_config.py, 参数自动查询功能将无法使用。")
    AD9363_GET_COMMANDS = []


class MainWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("FPGA 无线通信上位机 (AD9363) - [串口+UDP]")
        self.setGeometry(100, 100, 1200, 800)
        self.query_list = []

        self.init_ui()

        # 1. 先调用所有的 setup 函数, 它们只负责 *创建* worker
        self.setup_serial_thread()
        self.setup_ethernet_thread()
        self.setup_audio_thread()
        self.setup_audio_stream_threads()
        self.setup_camera_thread()

        # 2. 集中处理跨线程信号
        try:
            self.eth_worker.audio_chunk_received.connect(
                self.audio_output_worker.receive_and_play_chunk, Qt.ConnectionType.QueuedConnection
            )
            self.audio_input_worker.chunk_ready_bytes.connect(self.eth_worker.send_audio_chunk)
            self.camera_worker.jpeg_bytes_ready.connect(self.eth_worker.send_video_frame)
            self.log_widget.append_log("跨线程信号连接成功")
        except AttributeError as e:
            self.log_widget.append_log(f"[严重错误] 无法连接跨线程信号: {e}")

    def init_ui(self):
        left_panel = QWidget()
        left_layout = QVBoxLayout(left_panel)
        left_panel.setMaximumWidth(380)
        self.config_widget = ConfigWidget()
        self.ethernet_widget = EthernetWidget()
        self.params_widget = ParamsWidget()
        self.temperature_fan_widget = TemperatureFanWidget()
        left_layout.addWidget(self.config_widget)
        left_layout.addWidget(self.ethernet_widget)
        left_layout.addWidget(self.params_widget)
        left_layout.addWidget(self.temperature_fan_widget)
        left_layout.addStretch()

        right_panel = QWidget()
        right_layout = QVBoxLayout(right_panel)
        self.tab_widget = QTabWidget()

        # --- 原有 Tab ---
        self.file_tab_content = QWidget()
        file_tab_layout = QVBoxLayout(self.file_tab_content)
        self.text_audio_widget = TextAudioWidget()
        self.file_send_widget = FileSendWidget()
        self.file_receive_widget = FileReceiveWidget()
        file_tab_layout.addWidget(self.text_audio_widget)
        file_horizontal_container = QWidget()
        file_horizontal_layout = QHBoxLayout(file_horizontal_container)
        file_horizontal_layout.addWidget(self.file_send_widget)
        file_horizontal_layout.addWidget(self.file_receive_widget)
        file_horizontal_layout.setSpacing(10)
        file_horizontal_layout.setContentsMargins(0, 0, 0, 0)
        file_tab_layout.addWidget(file_horizontal_container)
        file_tab_layout.addStretch()

        self.video_widget = VideoWidget()
        self.realtime_audio_widget = RealtimeAudioWidget()
        self.realtime_video_widget = RealtimeVideoWidget()
        self.iot_widget = IoTWidget()

        self.tab_widget.addTab(self.file_tab_content, "文件、文本及录音")
        self.tab_widget.addTab(self.video_widget, "网络视频监控 (UDP)")
        self.tab_widget.addTab(self.realtime_audio_widget, "实时语音")
        self.tab_widget.addTab(self.realtime_video_widget, "实时视频")
        self.tab_widget.addTab(self.iot_widget, "无线物联网")

        self.log_widget = LogWidget()
        splitter = QSplitter(Qt.Orientation.Vertical)
        splitter.addWidget(self.tab_widget)
        splitter.addWidget(self.log_widget)
        splitter.setSizes([500, 300])
        right_layout.addWidget(splitter)

        main_widget = QWidget()
        main_layout = QHBoxLayout(main_widget)
        main_layout.addWidget(left_panel)
        main_layout.addWidget(right_panel, stretch = 1)
        self.setCentralWidget(main_widget)

    def setup_serial_thread(self):
        self.serial_thread = QThread()
        self.serial_worker = SerialWorker()
        self.serial_worker.moveToThread(self.serial_thread)

        self.serial_worker.connected.connect(self.on_serial_connected)
        self.serial_worker.disconnected.connect(self.on_serial_disconnected)
        self.serial_worker.log_received.connect(self.log_widget.append_log)
        self.serial_worker.error_occurred.connect(self.on_serial_error)
        self.serial_worker.param_response_received.connect(self.on_param_response)
        self.serial_worker.log_received.connect(self._handle_temperature_and_fan_response)

        # --- IoT 逻辑连接 ---
        self.iot_widget.send_command_signal.connect(self._handle_param_set_command)
        self.serial_worker.param_response_received.connect(self._handle_iot_response)
        self.serial_worker.log_received.connect(self._handle_iot_raw_log)

        self.serial_thread.started.connect(lambda: self.log_widget.append_log("串口线程启动"))
        self.serial_worker.finished.connect(self.serial_thread.quit)
        self.serial_worker.finished.connect(self.serial_worker.deleteLater)
        self.serial_thread.finished.connect(self.serial_thread.deleteLater)
        self.config_widget.connect_clicked.connect(self.serial_worker.connect_serial)
        self.config_widget.disconnect_clicked.connect(self.serial_worker.disconnect_serial)
        self.params_widget.send_command_signal.connect(self._handle_param_set_command)
        self.params_widget.query_all_signal.connect(self.query_all_parameters)
        self.temperature_fan_widget.temperature_monitor_toggled.connect(
            self.on_temperature_monitor_toggled
        )
        self.temperature_fan_widget.fan_state_requested.connect(self.set_fan_state)
        self.temperature_poll_timer = QTimer(self)
        self.temperature_poll_timer.setInterval(1000)
        self.temperature_poll_timer.timeout.connect(self.query_temperature)
        self.serial_thread.start()

    @pyqtSlot(str)
    def _handle_param_set_command(self, command_str):
        if self.serial_worker:
            self.serial_worker.send_data(command_str)
        else:
            self.log_widget.append_log("[错误] 无法发送命令: SerialWorker 不存在")

    def _handle_iot_response(self, command, value):
        if command == "query_led_state" or command == "led_state":
            self.iot_widget.handle_response(value)

    def _handle_iot_raw_log(self, log_msg):
        msg = log_msg.strip()
        if msg == "1" or msg == "0":
            self.iot_widget.handle_response(msg)

    def _handle_temperature_and_fan_response(self, log_msg):
        """处理不符合 key=value 格式的温度、风扇串口回执。"""
        if self.temperature_fan_widget.update_from_temperature_response(log_msg):
            return

        response = "".join(char for char in log_msg if char.isprintable()).strip().upper()
        if response == "FAN ON":
            self.temperature_fan_widget.update_fan_state(True)
        elif response == "FAN OFF":
            self.temperature_fan_widget.update_fan_state(False)

    def on_temperature_monitor_toggled(self, enabled):
        if enabled:
            self.log_widget.append_log("温度监控已开启（每 1 秒查询）")
            self.query_temperature()
            self.temperature_poll_timer.start()
        else:
            self.temperature_poll_timer.stop()
            self.log_widget.append_log("温度监控已关闭")

    def query_temperature(self):
        if self.serial_worker and self.serial_worker.serial and self.serial_worker.serial.is_open:
            self.serial_worker.send_data("query_temp?")
        else:
            self.temperature_poll_timer.stop()

    def set_fan_state(self, is_on):
        command = "fan_state_set=1" if is_on else "fan_state_set=0"
        self._handle_param_set_command(command)

    def setup_ethernet_thread(self):
        self.eth_thread = QThread()
        self.eth_worker = EthernetWorker()
        self.eth_worker.moveToThread(self.eth_thread)

        # --- 基础信号连接 ---
        self.eth_worker.started.connect(self.on_eth_started)
        self.eth_worker.stopped.connect(self.on_eth_stopped)
        self.eth_worker.log_received.connect(self.log_widget.append_log)
        self.eth_worker.video_frame_ready.connect(self.video_widget.update_frame)
        self.eth_worker.video_frame_ready.connect(self.realtime_video_widget.on_remote_frame_update)
        self.eth_worker.error_occurred.connect(self.on_eth_error)
        self.eth_worker.file_received.connect(self.file_receive_widget.add_received_file)

        # --- 控制信号连接 ---
        self.ethernet_widget.start_listening_clicked.connect(
            self.eth_worker.start_listening, Qt.ConnectionType.QueuedConnection
        )
        self.ethernet_widget.stop_listening_clicked.connect(
            self.eth_worker.stop_listening, Qt.ConnectionType.QueuedConnection
        )
        self.ethernet_widget.send_command_clicked.connect(
            self.eth_worker.send_command, Qt.ConnectionType.QueuedConnection
        )

        # --- 文本和文件基础连接 ---
        self.text_audio_widget.send_text_clicked.connect(self.eth_worker.send_command)
        self.file_send_widget.send_file_clicked.connect(self.eth_worker.send_file_udp)
        self.file_receive_widget.enable_reception_changed.connect(
            self.eth_worker.set_file_reception_enabled
        )

        # === [!! 新增: 文件传输进度信号连接 !!] ===

        # 1. 文件发送进度: Worker -> 发送 Widget
        self.eth_worker.file_send_progress.connect(
            self.file_send_widget.update_progress,
            Qt.ConnectionType.QueuedConnection
        )

        # 2. 文件接收进度: Worker -> 接收 Widget
        self.eth_worker.file_receive_progress.connect(
            self.file_receive_widget.update_progress,
            Qt.ConnectionType.QueuedConnection
        )

        # 3. 文件接收开始: Worker -> 接收 Widget
        self.eth_worker.file_receive_started.connect(
            self.file_receive_widget.start_receiving,
            Qt.ConnectionType.QueuedConnection
        )

        # 4. 文件传输完成: Worker -> MainWindow 处理函数
        self.eth_worker.file_transfer_finished.connect(
            self.on_file_transfer_finished,
            Qt.ConnectionType.QueuedConnection
        )

        # ==========================================

        self.params_widget.lan_mode_toggled.connect(self.eth_worker.set_lan_mode)

        self.eth_thread.start()
        self.log_widget.append_log("网络线程启动")

    def setup_audio_thread(self):
        self.audio_worker = AudioWorker()
        self.text_audio_widget.start_audio_recording.connect(self.audio_worker.start_recording)
        self.text_audio_widget.stop_audio_recording.connect(self.audio_worker.stop_recording)
        self.audio_worker.audio_recorded.connect(self.send_audio_data)
        self.audio_worker.error_occurred.connect(self.log_widget.append_log)

    def setup_audio_stream_threads(self):
        """
        初始化实时音频流线程
        """
        self.audio_input_thread = QThread()
        self.audio_input_worker = AudioInputWorker()
        self.audio_input_worker.moveToThread(self.audio_input_thread)

        self.audio_output_thread = QThread()
        self.audio_output_worker = AudioOutputWorker()
        self.audio_output_worker.moveToThread(self.audio_output_thread)

        # --- 信号连接 ---
        self.realtime_audio_widget.start_tx_streaming.connect(self.audio_input_worker.start_streaming)
        self.realtime_audio_widget.stop_tx_streaming.connect(self.audio_input_worker.stop_streaming)
        self.audio_input_worker.chunk_ready_array.connect(self.realtime_audio_widget.on_tx_waveform_update)
        self.audio_input_worker.error_occurred.connect(self.log_widget.append_log)

        self.realtime_audio_widget.start_rx_playback.connect(self.audio_output_worker.start_playback)
        self.realtime_audio_widget.stop_rx_playback.connect(self.audio_output_worker.stop_playback)
        self.audio_output_worker.waveform_ready.connect(
            self.realtime_audio_widget.on_rx_waveform_update
        )
        self.audio_output_worker.error_occurred.connect(self.log_widget.append_log)

        self.audio_input_thread.start()
        self.audio_output_thread.start()
        self.log_widget.append_log("实时音频流线程启动")

    def setup_camera_thread(self):
        self.camera_thread = QThread()
        self.camera_worker = CameraWorker()
        self.camera_worker.moveToThread(self.camera_thread)
        self.realtime_video_widget.start_tx_streaming.connect(
            self.camera_worker.start_streaming, Qt.ConnectionType.QueuedConnection)
        self.realtime_video_widget.stop_tx_streaming.connect(
            self.camera_worker.stop_streaming, Qt.ConnectionType.QueuedConnection)
        self.camera_worker.frame_ready.connect(self.realtime_video_widget.on_local_frame_update)
        self.camera_worker.error_occurred.connect(self.log_widget.append_log)
        self.camera_thread.started.connect(lambda: self.log_widget.append_log("摄像头线程启动"))
        self.camera_worker.finished.connect(self.camera_thread.quit)
        self.camera_thread.finished.connect(self.camera_worker.deleteLater)
        self.camera_thread.finished.connect(self.camera_thread.deleteLater)
        self.camera_thread.start()

    @pyqtSlot(bytes)
    def on_audio_chunk_received(self, chunk_bytes: bytes):
        pass

    def send_audio_data(self, audio_data: bytes):
        self.log_widget.append_log("音频录制完成,正在通过UDP发送...")
        if self.eth_worker:
            try:
                self.eth_worker.send_audio_udp(audio_data)
            except Exception as e:
                self.log_widget.append_log(f"音频数据发送失败: {e}")
        else:
            self.log_widget.append_log("没有活动的网络连接,无法发送音频数据。")

    # === [!! 新增: 文件传输完成处理函数 !!] ===
    @pyqtSlot(bool, str)
    def on_file_transfer_finished(self, success: bool, message: str):
        """
        处理文件传输完成事件
        :param success: 是否成功
        :param message: 消息内容
        """
        # 通知发送 Widget 完成
        self.file_send_widget.finish_transfer(success, message)

        # 通知接收 Widget 完成
        self.file_receive_widget.finish_receiving(success, message)

        # 在日志中显示
        if success:
            self.log_widget.append_log(f"✓ 文件传输完成: {message}")
        else:
            self.log_widget.append_log(f"✗ 文件传输失败: {message}")

    # ==========================================

    def on_serial_connected(self, message):
        self.log_widget.append_log(message)
        self.config_widget.set_connection_state(True)
        self.params_widget.set_enabled(True)
        self.temperature_fan_widget.set_connection_state(True)
        self.log_widget.append_log("连接成功, 正在查询 AD9363 参数...")
        QTimer.singleShot(100, self.query_all_parameters)

    def on_serial_disconnected(self):
        self.log_widget.append_log("串口已断开")
        self.config_widget.set_connection_state(False)
        self.params_widget.set_enabled(False)
        self.params_widget.clear_all_fields()
        self.temperature_poll_timer.stop()
        self.temperature_fan_widget.set_connection_state(False)
        self.query_list.clear()

    def on_serial_error(self, message):
        self.log_widget.append_log(f"[串口错误] {message}")
        if "连接失败" in message or "读取错误" in message:
            self.on_serial_disconnected()

    def on_eth_started(self):
        self.log_widget.append_log("UDP 监听已开始")
        self.ethernet_widget.set_connection_state(True)
        self.text_audio_widget.set_enabled(True)
        self.file_send_widget.set_enabled(True)
        self.file_receive_widget.set_enabled(True)
        self.realtime_audio_widget.set_enabled(True)
        self.realtime_video_widget.set_enabled(True)

    def on_eth_stopped(self):
        self.log_widget.append_log("UDP 监听已停止")
        self.ethernet_widget.set_connection_state(False)
        self.text_audio_widget.set_enabled(False)
        self.file_send_widget.set_enabled(False)
        self.file_receive_widget.set_enabled(False)
        self.realtime_audio_widget.set_enabled(False)
        self.realtime_video_widget.set_enabled(False)

    def on_eth_error(self, message):
        self.log_widget.append_log(f"[网络错误] {message}")
        if "绑定失败" in message:
            self.on_eth_stopped()

    def query_all_parameters(self):
        if not (self.serial_worker and self.serial_worker.serial and self.serial_worker.serial.is_open):
            self.log_widget.append_log("无法查询: 串口未连接")
            return
        if not AD9363_GET_COMMANDS:
            self.log_widget.append_log("[警告] ad9363_config.py 为空, 没有参数可查询。")
            return
        self.log_widget.append_log("--- 开始查询所有参数 ---")
        self.query_list = AD9363_GET_COMMANDS.copy()
        self.send_next_query()

    def send_next_query(self):
        if not self.query_list:
            self.log_widget.append_log("--- 参数查询完毕 ---")
            return
        command = self.query_list.pop(0)
        self.serial_worker.send_data(command)

    def on_param_response(self, command, value):
        self.log_widget.append_log(f"[响应]: {command} = {value}")
        if command == "tx_lo_freq":
            self.params_widget.update_tx_lo_freq(value)
        elif command == "tx_samp_freq":
            self.params_widget.update_tx_samp_freq(value)
        elif command == "tx_rf_bandwidth":
            self.params_widget.update_tx_rf_bw(value)
        elif command == "tx1_attenuation":
            self.params_widget.update_tx1_atten(value)
        elif command == "tx2_attenuation":
            self.params_widget.update_tx2_atten(value)
        elif command == "tx_fir_en":
            self.params_widget.update_tx_fir_en(value)
        elif command == "rx_lo_freq":
            self.params_widget.update_rx_lo_freq(value)
        elif command == "rx_samp_freq":
            self.params_widget.update_rx_samp_freq(value)
        elif command == "rx_rf_bandwidth":
            self.params_widget.update_rx_rf_bw(value)
        elif command == "rx1_gc_mode":
            self.params_widget.update_rx1_gc_mode(value)
        elif command == "rx2_gc_mode":
            self.params_widget.update_rx2_gc_mode(value)
        elif command == "rx1_rf_gain":
            self.params_widget.update_rx1_rf_gain(value)
        elif command == "rx2_rf_gain":
            self.params_widget.update_rx2_rf_gain(value)
        elif command == "rx_fir_en":
            self.params_widget.update_rx_fir_en(value)
        elif command == "dds_tx1_tone1_freq":
            self.params_widget.update_dds_tx1_t1_freq(value)
        elif command == "dds_tx2_tone1_freq":
            self.params_widget.update_dds_tx2_t1_freq(value)
        QTimer.singleShot(10, self.send_next_query)

    def closeEvent(self, event):
        self.log_widget.append_log("正在关闭应用程序...")
        self.query_list.clear()
        if hasattr(self, "temperature_poll_timer"):
            self.temperature_poll_timer.stop()

        try:
            if hasattr(self, 'audio_input_worker'): self.audio_input_worker.stop_streaming()
            if hasattr(self, 'audio_output_worker'): self.audio_output_worker.stop_playback()
        except Exception:
            pass

        try:
            if hasattr(self, 'camera_worker'): self.camera_worker.stop_streaming()
        except Exception:
            pass

        if hasattr(self, 'serial_thread') and self.serial_thread.isRunning():
            self.serial_worker.disconnect_serial()
            self.serial_thread.quit()
            if not self.serial_thread.wait(2000): self.serial_thread.terminate()
        try:
            if hasattr(self, 'eth_worker'): self.eth_worker.stop_listening()
        except Exception:
            pass
        if hasattr(self, "eth_thread") and self.eth_thread.isRunning():
            self.eth_thread.quit()
            if not self.eth_thread.wait(2000):
                self.log_widget.append_log("网络线程未能正常停止,将强制终止")
                self.eth_thread.terminate()
        if hasattr(self, "audio_input_thread") and self.audio_input_thread.isRunning():
            self.audio_input_thread.quit()
            if not self.audio_input_thread.wait(1000): self.audio_input_thread.terminate()
        if hasattr(self, "audio_output_thread") and self.audio_output_thread.isRunning():
            self.audio_output_thread.quit()
            if not self.audio_output_thread.wait(1000): self.audio_output_thread.terminate()

        if hasattr(self, "camera_thread") and self.camera_thread.isRunning():
            if hasattr(self, 'camera_worker'): self.camera_worker.stop_streaming()
            self.camera_thread.quit()
            if not self.camera_thread.wait(2000):
                self.log_widget.append_log("摄像头线程未能正常停止,将强制终止")
                self.camera_thread.terminate()

        event.accept()
