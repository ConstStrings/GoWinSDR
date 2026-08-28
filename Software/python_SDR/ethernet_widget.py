from PyQt6.QtWidgets import (QWidget, QVBoxLayout, QGridLayout, QLabel,
                             QLineEdit, QPushButton, QSpinBox, QGroupBox)
from PyQt6.QtCore import pyqtSignal, pyqtSlot


class EthernetWidget(QWidget):
    """
    网络配置区 (UDP)
    """
    # 信号: (listen_ip, listen_port, fpga_ip, fpga_port)
    start_listening_clicked = pyqtSignal(str, int, str, int)
    stop_listening_clicked = pyqtSignal()
    send_command_clicked = pyqtSignal(str)  # 用于测试

    def __init__(self, parent=None):
        super().__init__(parent)
        self.init_ui()

    def init_ui(self):
        main_layout = QVBoxLayout(self)

        # --- FPGA 目标地址 (用于发送命令) ---
        group_fpga = QGroupBox("FPGA 目标地址 (用于发送)")
        layout_fpga = QGridLayout(group_fpga)

        layout_fpga.addWidget(QLabel("FPGA IP:"), 0, 0)
        self.txt_fpga_ip = QLineEdit("192.168.3.2")
        layout_fpga.addWidget(self.txt_fpga_ip, 0, 1)

        layout_fpga.addWidget(QLabel("FPGA 端口:"), 1, 0)
        self.spin_fpga_port = QSpinBox()
        self.spin_fpga_port.setRange(1, 65535)
        self.spin_fpga_port.setValue(32768)
        layout_fpga.addWidget(self.spin_fpga_port, 1, 1)

        # --- 本地监听设置 (用于接收视频) ---
        group_local = QGroupBox("本地监听设置 (用于接收)")
        layout_local = QGridLayout(group_local)

        layout_local.addWidget(QLabel("本地 IP:"), 0, 0)
        self.txt_listen_ip = QLineEdit("192.168.3.3")
        layout_local.addWidget(self.txt_listen_ip, 0, 1)

        layout_local.addWidget(QLabel("本地端口:"), 1, 0)
        self.spin_listen_port = QSpinBox()
        self.spin_listen_port.setRange(1, 65535)
        self.spin_listen_port.setValue(32768)
        layout_local.addWidget(self.spin_listen_port, 1, 1)

        # --- 控制按钮 ---
        self.btn_start = QPushButton("开始监听 (UDP)")
        self.btn_stop = QPushButton("停止监听")
        self.btn_stop.setEnabled(False)

        self.btn_send_cmd = QPushButton("发送测试命令")
        self.btn_send_cmd.setEnabled(False)  # 监听开始后才启用

        main_layout.addWidget(group_fpga)
        main_layout.addWidget(group_local)

        # FPGA CRED v1 reports free DDR ingress space in MTU-packet units.
        # Keep this on the main network page so the current radio backpressure
        # is visible without opening a transfer-specific dialog.
        group_ddr = QGroupBox("FPGA DDR3 缓冲区（CRED 流控）")
        layout_ddr = QGridLayout(group_ddr)
        layout_ddr.addWidget(QLabel("剩余空间:"), 0, 0)
        self.lbl_ddr_free = QLabel("等待 CRED…")
        self.lbl_ddr_free.setStyleSheet("font-weight: bold; color: #666;")
        layout_ddr.addWidget(self.lbl_ddr_free, 0, 1)
        layout_ddr.addWidget(QLabel("流控状态:"), 1, 0)
        self.lbl_ddr_flow = QLabel("未连接")
        self.lbl_ddr_flow.setStyleSheet("color: #666;")
        layout_ddr.addWidget(self.lbl_ddr_flow, 1, 1)
        main_layout.addWidget(group_ddr)
        main_layout.addWidget(self.btn_start)
        main_layout.addWidget(self.btn_stop)
        main_layout.addWidget(self.btn_send_cmd)

        # 连接信号
        self.btn_start.clicked.connect(self.on_start_click)
        self.btn_stop.clicked.connect(self.on_stop_click)
        self.btn_send_cmd.clicked.connect(
            lambda: self.send_command_clicked.emit("TEST")
        )

    def on_start_click(self):
        self.start_listening_clicked.emit(
            self.txt_listen_ip.text(),
            self.spin_listen_port.value(),
            self.txt_fpga_ip.text(),
            self.spin_fpga_port.value()
        )

    def on_stop_click(self):
        self.stop_listening_clicked.emit()

    def set_connection_state(self, listening):
        """
        由主窗口调用，更新UI状态
        """
        self.btn_start.setEnabled(not listening)
        self.btn_stop.setEnabled(listening)
        self.btn_send_cmd.setEnabled(listening)  # 监听时才可发送

        # 监听时不应更改设置
        self.txt_fpga_ip.setEnabled(not listening)
        self.spin_fpga_port.setEnabled(not listening)
        self.txt_listen_ip.setEnabled(not listening)
        self.spin_listen_port.setEnabled(not listening)

        if not listening:
            self.update_ddr_credit_status(0, False, False)

    @pyqtSlot(int, bool, bool)
    def update_ddr_credit_status(self, free_packets, known, fallback):
        """Show FPGA's latest remaining DDR ingress capacity."""
        if not known:
            if fallback:
                self.lbl_ddr_free.setText("未知（按未满发送）")
                self.lbl_ddr_flow.setText("CRED 超时兜底")
                self.lbl_ddr_flow.setStyleSheet("color: #b36b00;")
            else:
                self.lbl_ddr_free.setText("等待 CRED…")
                self.lbl_ddr_flow.setText("等待 FPGA 状态包")
                self.lbl_ddr_flow.setStyleSheet("color: #666;")
            self.lbl_ddr_free.setStyleSheet("font-weight: bold; color: #666;")
            return

        # CRED reports packet slots, not exact byte count.  One application
        # packet is capped at 1024-byte payload, hence the displayed KiB is an
        # intentionally approximate capacity indicator.
        self.lbl_ddr_free.setText(f"{free_packets} 个 MTU 包（约 {free_packets} KiB）")
        if fallback:
            self.lbl_ddr_flow.setText("CRED 超时兜底（上次上报值）")
            self.lbl_ddr_flow.setStyleSheet("color: #b36b00;")
            self.lbl_ddr_free.setStyleSheet("font-weight: bold; color: #b36b00;")
        else:
            self.lbl_ddr_flow.setText("严格流控")
            self.lbl_ddr_flow.setStyleSheet("color: #16803c;")
            self.lbl_ddr_free.setStyleSheet("font-weight: bold; color: #16803c;")

