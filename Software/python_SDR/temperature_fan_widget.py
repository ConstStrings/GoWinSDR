import re

from PyQt6.QtCore import pyqtSignal
from PyQt6.QtWidgets import (
    QGroupBox, QHBoxLayout, QLabel, QPushButton, QVBoxLayout, QWidget,
    QCheckBox,
)


class TemperatureFanWidget(QWidget):
    """设备温度显示与风扇控制面板。"""

    temperature_monitor_toggled = pyqtSignal(bool)
    fan_state_requested = pyqtSignal(bool)

    def __init__(self, parent=None):
        super().__init__(parent)
        self.init_ui()
        self.set_connection_state(False)

    def init_ui(self):
        main_layout = QVBoxLayout(self)

        group = QGroupBox("设备温度与风扇")
        layout = QVBoxLayout(group)

        self.monitor_checkbox = QCheckBox("启用温度监控（每 1 秒）")
        self.monitor_checkbox.toggled.connect(self.temperature_monitor_toggled)
        layout.addWidget(self.monitor_checkbox)

        self.mcu_temp_label = QLabel("MCU 温度：-- °C")
        self.ad9361_temp_label = QLabel("AD9361 温度：-- °C（Raw: --）")
        layout.addWidget(self.mcu_temp_label)
        layout.addWidget(self.ad9361_temp_label)

        fan_layout = QHBoxLayout()
        self.fan_status_label = QLabel("风扇状态：关闭")
        self.fan_on_button = QPushButton("打开风扇")
        self.fan_off_button = QPushButton("关闭风扇")
        self.fan_on_button.clicked.connect(lambda: self.fan_state_requested.emit(True))
        self.fan_off_button.clicked.connect(lambda: self.fan_state_requested.emit(False))
        fan_layout.addWidget(self.fan_status_label)
        fan_layout.addStretch()
        fan_layout.addWidget(self.fan_on_button)
        fan_layout.addWidget(self.fan_off_button)
        layout.addLayout(fan_layout)

        main_layout.addWidget(group)

    def set_connection_state(self, connected):
        """在串口连接状态变化时更新可操作性。"""
        self.setEnabled(connected)
        if not connected:
            self.monitor_checkbox.blockSignals(True)
            self.monitor_checkbox.setChecked(False)
            self.monitor_checkbox.blockSignals(False)
            self.clear_display()

    def clear_display(self):
        self.mcu_temp_label.setText("MCU 温度：-- °C")
        self.ad9361_temp_label.setText("AD9361 温度：-- °C（Raw: --）")
        self.fan_status_label.setText("风扇状态：关闭")

    def update_from_temperature_response(self, response):
        """解析 MCU 与 AD9361 温度回复并刷新显示。"""
        # 固件会在小数点附近插入 \x01 等不可见字符，移除后再解析。
        clean_response = "".join(char for char in response if char.isprintable())

        mcu_match = re.search(
            r"MCU\s*Temp\s*:\s*([+-]?\d+(?:\.\d+)?)\s*C",
            clean_response,
            re.IGNORECASE,
        )
        ad9361_match = re.search(
            r"AD9361\s*Temp\s*:\s*([+-]?\d+(?:\.\d+)?)\s*C"
            r"(?:\s*\(\s*Raw\s*:\s*([^)]*)\))?",
            clean_response,
            re.IGNORECASE,
        )

        updated = False
        if mcu_match:
            self.mcu_temp_label.setText(f"MCU 温度：{mcu_match.group(1)} °C")
            updated = True
        if ad9361_match:
            raw_value = (ad9361_match.group(2) or "--").strip()
            self.ad9361_temp_label.setText(
                f"AD9361 温度：{ad9361_match.group(1)} °C（Raw: {raw_value}）"
            )
            updated = True
        return updated

    def update_fan_state(self, is_on):
        self.fan_status_label.setText(f"风扇状态：{'开启' if is_on else '关闭'}")
