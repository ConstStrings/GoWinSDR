# GoWinSDRv2 Coming Soon, Currently Under Development

**Main Improvements and Progress:**

| Name | Features or Improvements | Development Progress |
| :--- | :----------------------- | :------------------- |
| SDR Core Board | Optimized RF and Ethernet layout to enhance stability; optimized interface arrangement; reserved programmer interface; added 40-pin expansion interface; adopted TCXO (Temperature Compensated Crystal Oscillator); added status indicator lights | Hardware PCB fabrication completed, currently debugging |
| On-board Programmer | Can be directly mounted on the SDR core board, single-cable programming | Development completed |
| SDR Expansion Board | Integrated DAC analog output, audio output and audio amplifier, GPS clock calibration, serial display | PCB design in progress |
| FPGA Firmware | Fixing known bugs | Under development |

**Currently, the v2 version is not yet fully developed. Under normal circumstances, please DO NOT use this version!!! This page is for preview purposes only; please use the v1 version!!!**
# GoWinSDR

**Last edited by ConstString on 2026-03-16*

**Click to Read Chinese Version: https://github.com/ConstStrings/GoWinSDR/blob/master/README.MD**

## Project Overview

**This project is built around the Gowin GW5AT-LV60 FPGA and ADI AD9363/AD9361 RF transceiver, forming a flexible and reconfigurable Software Defined Radio (SDR) system. Through hardware-software co-design, high-speed baseband processing is deployed on the FPGA while the interactive application layer runs on a Python host application, communicating over Gigabit Ethernet to enable QPSK and other real-time communication modes alongside dynamic parameter configuration.**

The system connects to a PC via Gigabit Ethernet or USB 2.0 (under development). The accompanying graphical user interface (GUI host application) provides an intuitive display of communication parameters and data transfer status, supporting real-time parameter configuration and transmission monitoring, greatly enhancing the human-machine interaction experience. Real-world testing has demonstrated that this SDR wireless communication system can achieve genuine wireless communication between two devices at data rates up to **4 Mbps**.

The FPGA used in this project is PL-only, so the AD936X RF chip initialization code has been ported to an STM32 platform. Testing has confirmed stable operation and convenient usage. All logic beyond initialization is implemented in Verilog on the FPGA.

Compared to the many open-source SDR projects built on Xilinx ZYNQ platforms, this project does not rely on a heterogeneous FPGA — all core logic is implemented in Verilog. The data path is cleaner and the operational logic is more intuitive and closer to the hardware level, making it well-suited for radio enthusiasts, communications engineers, and students who wish to gain a deeper understanding of SDR fundamentals, or use it as a base platform for secondary development such as custom coding schemes.

![img](./Image/front.jpg)

## Project Structure

```
GoWinSDR/
├── FPGA/
│   ├── SDR_Final_CMOS/       # Full FPGA project based on the SDR Base board, implements all features
│   ├── SDR_TANG_CMOS/        # AD9363 test project based on the AD9363_Debug test board and Sipeed Tang Mega dev board; single-tone TX/RX only
│   └── Submodule/            # Submodules used during testing; not intended for general use
├── Firmware/
│   └── GoWinSDR_STM32/       # STM32 code for AD9363 initialization, ported from Xilinx, developed with HAL library
├── Hardware/
│   ├── Gerber/               # PCB fabrication files
│   ├── ProPrj_AD9363_Debug/  # LCEDA project, AD9363 functional test board
│   └── ProPrj_GoWinSDR_SMT/  # LCEDA project, complete project PCB
├── Image/                    # Documentation images
├── Matlab/                   # Used for generating filter coefficients
├── Software/                 # PyQt-based host application
└── README.MD
```

## System Block Diagram

![img](./Image/github.png)

## Quick Start

1. **Fabricate the PCB using project ProPrj_GoWinSDR_SMT, solder the components, and verify that all power rails are functioning correctly.**
2. **Open project GoWinSDR_STM32 and flash the STM32 firmware via the onboard SWD interface.**
3. **Open project SDR_Final_CMOS and download/program the bitstream to the FPGA.**
4. **Run the host application using PyCharm or another IDE, and verify that parameters can be configured and signals can be transmitted and received.**
5. **If any subsystem behaves abnormally, use the serial port and the Gowin FPGA's built-in logic analyzer to diagnose the issue.**

## Core Code Description

**Core source files are located under \FPGA\SDR_Final_CMOS\src**

### Top-Level Module

#### `top.v`

> Top-level module responsible for interconnecting all submodules.

------

### AD936X Interface

#### `ad9363_dev_cmos.v`

> AD9363 CMOS interface driver. Uses IDDR primitives to simultaneously capture I/Q ADC data from the 12-bit parallel bus, and ODDR primitives to alternately output I/Q DAC data onto the transmit bus, implementing the AD9363 transceiver timing control.

------

### Ethernet

#### `eth_transceiver.v`

> Ethernet transceiver top-level module. Drives the Gigabit PHY via the RGMII interface, integrates an internal 125 MHz PLL and UDP/IP stack, and exposes a clean user-facing data send/receive interface with ARP response and UDP packet encapsulation/parsing support.

#### `eth_frame_gene.v`

> RF data frame packing module (`rf_data_processor`). Prepends a custom frame header (`0xEB90CAD3`) and appends a frame tail (`0x55AA5C4B`) to user data received from Ethernet, then passes the framed data through a clock-domain-crossing FIFO to the RF transmit side for wireless link frame synchronization.

#### `eth_pack.v`

> RF data frame unpacking module (`rf_data_framer`). Searches the RF demodulated bitstream for the frame header, extracts the payload, and passes it through a CDC FIFO to the Ethernet transmit side. Also supports swapped I/Q frame header detection and timeout-based frame error detection.

#### `arp_responder.v`

> ARP response module. Monitors the Ethernet input stream, identifies ARP request packets and extracts the sender's MAC/IP, then automatically constructs and transmits an ARP reply frame, enabling the PC to correctly resolve the FPGA's MAC address.

#### `crc.v`

> CRC verification module used for Ethernet frame data integrity checking.

------

### Modulation / Demodulation

#### `qpsk_demod.v`

> QPSK demodulation top-level module. Integrates sample clock generation, DDS carrier generation, frequency down-conversion mixing, low-pass filtering, Costas loop carrier synchronization, Gardner timing synchronization, and differential decoding to form a complete demodulation chain from IF-sampled data to baseband bitstream.

#### `costas.v`

> Costas loop carrier recovery module. Generates a local carrier using an on-chip DDS, performs quadrature mixing with the incoming I/Q signal, and uses the phase detector and loop filter to close the loop and control the DDS phase, eliminating carrier frequency and phase offset.

#### `costas_flt_new.v`

> Improved Costas loop filter (`costas_loop_filter_new`). Implements a PI (proportional-integral) controller with anti-windup integration saturation protection. KP/KI gains are configurable. Converts phase detector error into a DDS phase correction word to accelerate loop acquisition and improve stability.

#### `costas_loop_filter.v`

> Costas loop first-order IIR loop filter. Implements the difference equation for the transfer function `H(z) = c1 + c2·z⁻¹/(1−z⁻¹)`, using an adaptive dual-gain strategy (large coefficients for fast initial pull-in, small coefficients for steady-state tracking). Outputs a 24-bit phase control word.

#### `phase_detector.v`

> QPSK carrier synchronization phase detector. Uses the sign bits of the low-pass filtered I/Q signals to compute the phase error via a decision-directed method: `error = Q·sign(I) − I·sign(Q)`. Outputs a 58-bit signed phase error to the loop filter.

#### `gardner_sync.v`

> Gardner timing synchronization top-level module. Cascades the interpolation filter, Gardner TED error detector, and NCO to form a complete symbol timing recovery loop. Outputs I/Q decision data and a sync flag at the optimal sampling instant.

#### `gardner_ted.v`

> Gardner Timing Error Detector (TED). Computes symbol timing error using the Gardner algorithm `e(k) = I(k−1)·[I(k)−I(k−2)]`, passes it through a first-order IIR loop filter, and outputs a 16-bit error control word. Also outputs hard-decision I/Q data at the optimal sampling instant.

#### `nco.v`

> Numerically Controlled Oscillator (NCO) module. Accepts the frequency control word `w(n)` from the loop filter and decrements the internal register η each clock cycle. When η underflows (goes negative), a strobe overflow signal is generated and the fractional interval μk is output to the interpolation filter for symbol timing control.

#### `interpolate_filter.v`

> Farrow-structure interpolation filter. Uses the fractional interval μk from the NCO to perform piecewise polynomial interpolation on the I/Q sample sequence (`y(k) = f1·μk² + f2·μk + f3`), reconstructing the signal at arbitrary phase points to achieve non-integer sample rate conversion.

------

### RF Transceiver

#### `rf_rxt.v`

> RF transceiver processing top-level module. On the receive side, cascades the Costas loop, Gardner timing synchronization, and differential decoder to complete QPSK demodulation and output a bitstream. On the transmit side, applies differential encoding and QPSK constellation mapping to input byte data, driving the DAC to output I/Q baseband signals.

#### `rf_diff_encode.v`

> QPSK differential encoder (`qpsk_differential_encoder`). XORs the current 2-bit input with the previous I/Q state to implement Differential QPSK (DQPSK) encoding, eliminating phase ambiguity at the demodulator.

#### `rf_diff_decode.v`

> QPSK differential decoder (`qpsk_differential_decoder`). XORs the current I/Q decision bits with the previous symbol to recover the original 2-bit data, corresponding to the differential encoder and transparently resolving phase ambiguity.

------

### Miscellaneous

#### `calibration.v`

> Signal calibration module. Squares the ADC input data and applies FIR low-pass filtering to extract the signal envelope, then measures the current frequency using a sine wave frequency meter. The resulting 24-bit calibration frequency value is sent to the STM32 via `data_sender_24bit` for system calibration.

#### `com_fpga.v`

> FPGA-to-MCU communication module (`data_sender_24bit`). Uses a clock divided by 128 as the data clock. Upon receiving a request signal from the STM32, a state machine serially outputs 24-bit data byte by byte, implementing synchronous parallel data transfer from the FPGA to the STM32.

#### `led_control.v`

> 433 MHz OOK demodulation module (`demod_433`). Computes instantaneous power (I²+Q²) from the ADC I/Q input, applies 64-sample moving average filtering, and compares the result against a power threshold to output an OOK demodulated data bit. Can be used for LED status indication or low-speed remote control signal reception.

------

### Constraint Files

#### `SDR_Test.cst`

> Pin constraint file

#### `timeconstrain.sdc`

> Timing constraint file

#### `SDR_Test.rao`

> Logic analyzer configuration file

## ARM Firmware Usage

**Core source files are located under \Firmware\GoWinSDR_STM32\Hardware**

The main program already implements serial command parsing and parameter configuration, so the firmware can be flashed directly without modification. You will need to update the SPI pin definitions in `\Firmware\GoWinSDR_STM32\Hardware\api\softspi.h` to match your actual hardware connections.

For more detailed configuration, you may modify the initialization struct `AD9361_InitParam default_init_param` in `main.c`. The meaning of each parameter is explained in the comments.

During initialization, a log is printed over the serial port. Upon successful initialization, the current status is printed:

```
Sampling Rate:
  RX: 61440000 Hz (61.44 MSPS)
  TX: 61440000 Hz (61.44 MSPS)
ad9361_rfpll_int_recalc_rate: Parent Rate 80000000 Hz
ad9361_rfpll_int_recalc_rate: Parent Rate 80000000 Hz

LO Frequency:
  RX: 2400000000 Hz (2.400 GHz)
  TX: 2400000000 Hz (2.400 GHz)
ad9361_set_tx_atten : attenuation 0 mdB tx1=1 tx2=0
Rx gain can be set in MGC mode only
ad9361_rf_port_setup : INPUT_SELECT 0x3

=== Final Status ===
ENSM (0x017): 0x1A (TX_ON=1)
TX Ctrl (0x002): 0x58
PLL Lock (0x247): 0x02 (TX_PLL=1)
```

The following commands are supported and can be issued over the serial port. To view or modify the command handling logic, refer to `\Firmware\GoWinSDR_STM32\Hardware\ad9361\command.c`:

```
help?  - Displays all available commands.
register?  - Gets the specified register value.
tx_lo_freq?  - Gets current TX LO frequency [MHz].
tx_lo_freq=  - Sets the TX LO frequency [MHz].
tx_samp_freq?  - Gets current TX sampling frequency [Hz].
tx_samp_freq=  - Sets the TX sampling frequency [Hz].
tx_rf_bandwidth?  - Gets current TX RF bandwidth [Hz].
tx_rf_bandwidth=  - Sets the TX RF bandwidth [Hz].
tx1_attenuation?  - Gets current TX1 attenuation [mdB].
tx1_attenuation=  - Sets the TX1 attenuation [mdB].
tx2_attenuation?  - Gets current TX2 attenuation [mdB].
tx2_attenuation=  - Sets the TX2 attenuation [mdB].
tx_fir_en?  - Gets current TX FIR state.
tx_fir_en=  - Sets the TX FIR state.
rx_lo_freq?  - Gets current RX LO frequency [MHz].
rx_lo_freq=  - Sets the RX LO frequency [MHz].
rx_samp_freq?  - Gets current RX sampling frequency [Hz].
rx_samp_freq=  - Sets the RX sampling frequency [Hz].
rx_rf_bandwidth?  - Gets current RX RF bandwidth [Hz].
rx_rf_bandwidth=  - Sets the RX RF bandwidth [Hz].
rx1_gc_mode?  - Gets current RX1 GC mode.
rx1_gc_mode=  - Sets the RX1 GC mode.
rx2_gc_mode?  - Gets current RX2 GC mode.
rx2_gc_mode=  - Sets the RX2 GC mode.
rx1_rf_gain?  - Gets current RX1 RF gain.
rx1_rf_gain=  - Sets the RX1 RF gain.
rx2_rf_gain?  - Gets current RX2 RF gain.
rx2_rf_gain=  - Sets the RX2 RF gain.
rx_fir_en?  - Gets current RX FIR state.
rx_fir_en=  - Sets the RX FIR state.
dds_tx1_tone1_freq?  - Gets current DDS TX1 Tone 1 frequency [Hz].
dds_tx1_tone1_freq=  - Sets the DDS TX1 Tone 1 frequency [Hz].
dds_tx1_tone2_freq?  - Gets current DDS TX1 Tone 2 frequency [Hz].
dds_tx1_tone2_freq=  - Sets the DDS TX1 Tone 2 frequency [Hz].
dds_tx1_tone1_phase?  - Gets current DDS TX1 Tone 1 phase [degrees].
dds_tx1_tone1_phase=  - Sets the DDS TX1 Tone 1 phase [degrees].
dds_tx1_tone2_phase?  - Gets current DDS TX1 Tone 2 phase [degrees].
dds_tx1_tone2_phase=  - Sets the DDS TX1 Tone 2 phase [degrees].
dds_tx1_tone1_scale?  - Gets current DDS TX1 Tone 1 scale.
dds_tx1_tone1_scale=  - Sets the DDS TX1 Tone 1 scale.
dds_tx1_tone2_scale?  - Gets current DDS TX1 Tone 2 scale.
dds_tx1_tone2_scale=  - Sets the DDS TX1 Tone 2 scale.
dds_tx2_tone1_freq?  - Gets current DDS TX2 Tone 1 frequency [Hz].
dds_tx2_tone1_freq=  - Sets the DDS TX2 Tone 1 frequency [Hz].
dds_tx2_tone2_freq?  - Gets current DDS TX2 Tone 2 frequency [Hz].
dds_tx2_tone2_freq=  - Sets the DDS TX2 Tone 2 frequency [Hz].
dds_tx2_tone1_phase?  - Gets current DDS TX2 Tone 1 phase [degrees].
dds_tx2_tone1_phase=  - Sets the DDS TX2 Tone 1 phase [degrees].
dds_tx2_tone2_phase?  - Gets current DDS TX2 Tone 2 phase [degrees].
dds_tx2_tone2_phase=  - Sets the DDS TX2 Tone 2 phase [degrees].
dds_tx2_tone1_scale?  - Gets current DDS TX2 Tone 1 scale.
dds_tx2_tone1_scale=  - Sets the DDS TX2 Tone 1 scale.
dds_tx2_tone2_scale?  - Gets current DDS TX2 Tone 2 scale.
dds_tx2_tone2_scale=  - Sets the DDS TX2 Tone 2 scale.
calibration?  - Get Lo Freq diff.
calibration=  - Calibrate Lo Freq diff.
rx_lo_up=  - Increase RX LO frequency.
rx_lo_down=  - Decrease RX LO frequency.
query_led_state?  - Decrease RX LO frequency.
query_led_state=  - Decrease RX LO frequency.
```

## Host Application Overview

The host application is developed with **Python + PyQt6**, using a multi-threaded architecture. It communicates with the FPGA over both serial and Ethernet channels, providing a graphical interface for parameter configuration, data transfer, and real-time monitoring.

------

### How to Launch

After setting up the Python development environment, run `main.py` in PyCharm or any other IDE.

### Overall Architecture

The main window (`main_window.py`) uses a left-right split layout: the left panel hosts configuration widgets, and the right panel contains a multi-tab functional area. Multiple independent QThread worker threads run in the background, handling serial communication, UDP network send/receive, audio stream capture/playback, and camera capture respectively. All inter-thread communication is handled safely via Qt signals and slots.

------

### Serial Communication

`serial_worker.py` implements the serial worker thread, supporting available port enumeration, configurable baud rates (up to 921600 bps), serial connect/disconnect, and full-duplex data transfer. Incoming data is parsed line by line: responses in `key=value` format are recognized as parameter callbacks and forwarded to the parameter panel, while all other content is displayed as log output.

`config_widget.py` provides the serial configuration UI, including port refresh, baud rate selection, and connection state management.

------

### Ethernet Communication (UDP)

`ethernet_worker.py` implements a dual-mode UDP transmission protocol supporting both reliable and unreliable delivery:

- **Text commands**: Uses Stop-and-Wait protocol with up to 128 retransmission attempts.
- **File transfer**: Sends the file header (containing filename and size) using Stop-and-Wait, then sends file data using the **SR (Selective Repeat) sliding window protocol** (window size 4) with out-of-order retransmission; CRC32 checksums are applied throughout.
- **Real-time video stream**: Uses a custom fragmentation protocol (frame header contains frame ID, fragment index, and total fragment count). Packet loss is tolerated; each frame is split into fragments of up to 1024 bytes and sent unreliably, with the receiver reassembling fragments by frame ID.
- **Real-time audio stream**: PCM audio chunks are sent unreliably for minimal latency.

`ethernet_widget.py` provides the UDP configuration UI, including FPGA target address (IP/port) and local listen address settings, along with start/stop listening buttons.

------

### AD9363 Parameter Configuration

`params_widget.py` provides a parameter configuration panel for the AD9363 RF chip, organized into TX (transmit) and RX (receive) tabs. It covers LO frequency, sample rate, RF bandwidth, gain control, FIR enable, and DDS tone frequency — all readable and writable. Each parameter entry includes a text input and a Set button that sends a `key=value` command over the serial port. A "Query All Parameters" button is available for a one-click refresh, and all GET commands defined in `ad9363_config.py` are automatically queried in batch upon connection.

------

### File Transfer, Text, and Audio Recording

`text_audio_widget.py` supports sending text messages over serial and triggering audio recording start/stop.

`file_send_widget.py` implements the file sending UI, including file browsing, file info preview (name, size, type, path), and a transfer status display with a real-time progress bar, transfer rate (Mbps), and estimated time remaining.

`file_receive_widget.py` implements the file receiving UI, supporting enable/disable of file reception, real-time progress and rate display, and a table of received files that can be saved locally.

------

### Real-Time Voice Transmission

`realtime_audio_widget.py` provides a real-time bidirectional voice transmission interface. The transmit side enumerates system audio input devices (including WASAPI loopback), starts microphone capture after device selection, and streams audio over UDP in real time. The receive side feeds incoming PCM data into an audio output queue for real-time playback. Both sides embed a live waveform display.

`audio_stream_worker.py` is built on the sounddevice library. `AudioInputWorker` continuously captures 44100 Hz / mono / float32 audio chunks from a specified device via callback. `AudioOutputWorker` drives the speaker output through a queue buffer, playing silence when the buffer runs dry to minimize noise.

------

### Real-Time Video Transmission

`realtime_video_widget.py` provides a real-time bidirectional video interface. The transmit side opens the local camera with live preview and encodes frames as WebP for UDP transmission. The receive side decodes incoming network video frames and renders them in real time.

`camera_worker.py` implements camera capture using OpenCV in a dedicated internal thread, grabbing frames at a configured rate limit, horizontally flipping them, and emitting two separate signals: a QImage for local preview and a WebP byte stream for network transmission.

------

### Network Video Monitoring

`video_widget.py` provides a dedicated UDP video monitoring tab used solely for receiving and displaying video streams from the FPGA or network, with auto-scaling support for the video display label.

------

### Wireless IoT Control

`iot_widget.py` implements a simple IoT device status monitoring demo page. Upon activation, it automatically sets the RX LO frequency to 434 MHz and polls `query_led_state?` every 500 ms. Based on the serial response ("1" or "0"), it drives a custom-drawn bulb widget to light up or turn off, visualizing the state of a 433 MHz wireless remote control device.

------

### Waveform Display

`waveform_widget.py` is a custom audio waveform widget built on QPainter and NumPy. It uses off-screen Pixmap double-buffering for rendering, supports adjustable gain amplification (default 5×) with amplitude clipping, and adaptively samples or interpolates waveform data to fit the widget width.

------

## PCB Notes(Important: Read carefully)

1. Due to the presence of RF and high-speed signals, **impedance control is required** when ordering PCB fabrication. When ordering from JLCPCB, select the stackup **JLC06161H-3313** with ±20% impedance tolerance.

2. If you are not confident in your soldering, **always solder the power section first, verify all power rail voltages are correct, and only then solder the remaining components** to avoid damaging chips.

3. Before powering on, **check that none of the power rails are shorted to ground** — shorts can occur even with SMT assembly.

4. The PCB has gone through multiple revision iterations and should not have any major issues. Please ensure soldering quality before troubleshooting.

5. **Important!! The core module supports configuring bank voltage via VDDIO, but if both the core module and the baseboard supply VDDIO simultaneously, a conflict will occur. Therefore, the VDDIO power supply on the core module must be removed before inserting it into the baseboard. The procedure is as follows:**

   Refer to the core module schematic — the VDDIO supply is connected to the 3.3V rail through ferrite beads. You only need to remove the ferrite beads corresponding to the banks used by the project: **FB14, FB15, and FB16**.

      ![](./Image/som1.png)

   The locations of these three ferrite beads on the back of the core module are shown below. Simply desolder and remove them with a soldering iron.

   ​        ![](./Image/som2.png)

   

## Test Results

### File Transfer Test

![img](./Image/filetrans.png)

### Logic Analyzer screenshot (QPSK was undergoing bug fixes at the time; BPSK was used temporarily as a workaround)

#### Complete System Timing Diagram

![](./Image/logic.png)

#### AD9363 individual test

The test was conducted for BPSK communication in the 2.4GHz frequency band. The top four lines respectively represent the receiving IQ path and the transmitting IQ path. The waveform is relatively complete and there is no obvious distortion.

![](./Image/logic3.png)

![](./Image/logic4.png)

In the 2.4GHz test, **without attaching an antenna**, observe the distortion of the sine monochromatic signal.

![](./Image/logic2.png)



### Upper computer video transmission

By utilizing the video transmission function of the host computer, real-time video streams can be transmitted through the frequency band customized on the parameter setting page. The test was conducted using the self-receiving and self-transmitting method (which can be between boards) with the video source being a laptop camera. The left screen shows the captured image from the camera, while the right screen displays the image decoded from the radio frequency signal. Thanks to the strong real-time performance of the FPGA, there is almost no delay felt.

![](./Image/video.png)



### Ethernet data stream

Using the WireShark software, one can view the data streams transmitted in the Ethernet network. The Ethernet data streams during the file transmission process are as follows, divided into data frames and ACK frames.

![](./Image/wireshark.png)



### Spectrum (Early Test Results)

![img](./Image/spec.jpg)

## Product Showcase

![img](./Image/show4.jpg)

![img](./Image/show1.jpg)

![img](./Image/show2.jpg)

![img](./Image/show3.jpg)

## Acknowledgements

- The Costas loop and Gardner loop portions of this project were developed with reference to the open-source project: https://github.com/lauchinyuan/FPGA_QPSK-modem — many thanks to the author for sharing their work.
- The Ethernet transceiver portion was adapted from Sipeed example code: https://github.com/sipeed/TangMega-138K-example. The initial verification version of this project was also based on the Sipeed TangMega-138K development board.

## Remarks

**This project has consumed a considerable amount of effort from myself and our team. Although the AD936X is a mature chip with substantial documentation, existing projects are almost entirely built on the ZYNQ series with tightly coupled code that is difficult to learn from. The hardware and software debugging process was painful, but we ultimately succeeded in bringing the entire system together, and went on to win an award in the FPGA track of the 2025 National Embedded Systems Competition finals. Due to various objective and subjective reasons, some design goals remain incomplete: ARP requests are not yet implemented and must be added manually (as of 2026-3-10), QPSK has known bugs (as of 2026-3-10), and the Gardner loop loses lock at high symbol rates (as of 2026-3-10). I will do my best to continue improving this project in the time I can spare from my studies, and I hope for your understanding.**

For any questions or to get in touch, feel free to reach me by email: 3207235590@qq.com conststrings@gmail.com