# DDR3 IP timing constraints.  These are the generated constraints from the
# known-good DDR_FIFO reference, with the hierarchy adapted to this design.
# The regenerated IP uses a 50 MHz controller clock and a 200 MHz PHY clock.
create_clock -name ddr_clk50 -period 20.000 -waveform {0 10} [get_nets {u_eth2rf_processor/clk100m}]
create_clock -name ddr_clk_x1 -period 20.000 -waveform {0 10} [get_pins {u_eth2rf_processor/u_ddr3/gw3_top/u_ddr_phy_top/fclkdiv/CLKOUT}]
create_clock -name ddr_mem200 -period 5.000 -waveform {0 2.500} [get_nets {u_eth2rf_processor/memory_clk}]
set_clock_groups -asynchronous -group [get_clocks {ddr_clk50}] -group [get_clocks {ddr_clk_x1}]
set_clock_groups -asynchronous -group [get_clocks {ddr_clk_x1}] -group [get_clocks {ddr_mem200}]
set_clock_groups -asynchronous -group [get_clocks {ddr_clk50}] -group [get_clocks {ddr_mem200}]

create_clock -name {RX_CLK_125M} -period 8.000 [get_ports {RGMII_RXCLK}]
create_clock -name {sys_clk} -period 20.000 [get_ports {sys_clk}]

set_input_delay -clock {RX_CLK_125M} -max 3.500 [get_ports {RGMII_RXD[*] RGMII_RXDV}]

set_input_delay -clock {RX_CLK_125M} -min 1.000 [get_ports {RGMII_RXD[*] RGMII_RXDV}]

set_input_delay -clock {RX_CLK_125M} -clock_fall -max 3.500 [get_ports {RGMII_RXD[*] RGMII_RXDV}] -add_delay
set_input_delay -clock {RX_CLK_125M} -clock_fall -min 1.000 [get_ports {RGMII_RXD[*] RGMII_RXDV}] -add_delay

create_clock -name rx_clk_in_p -period 32.552 -waveform {0 16.276} [get_ports {rx_clk_in_p}]

# RX_FRAME 输入延迟
set_input_delay -clock rx_clk_in_p -max 4.8 [get_ports {rx_frame_in_p}]
set_input_delay -clock rx_clk_in_p -min 1.0 [get_ports {rx_frame_in_p}]

# RX_DATA[11:0] 输入延迟
# Gowin不支持通配符[*]，需要逐个列出
set_input_delay -clock rx_clk_in_p -max 4.8 [get_ports {rx_data_in[0]}]
set_input_delay -clock rx_clk_in_p -min 1.0 [get_ports {rx_data_in[0]}]
set_input_delay -clock rx_clk_in_p -max 4.8 [get_ports {rx_data_in[1]}]
set_input_delay -clock rx_clk_in_p -min 1.0 [get_ports {rx_data_in[1]}]
set_input_delay -clock rx_clk_in_p -max 4.8 [get_ports {rx_data_in[2]}]
set_input_delay -clock rx_clk_in_p -min 1.0 [get_ports {rx_data_in[2]}]
set_input_delay -clock rx_clk_in_p -max 4.8 [get_ports {rx_data_in[3]}]
set_input_delay -clock rx_clk_in_p -min 1.0 [get_ports {rx_data_in[3]}]
set_input_delay -clock rx_clk_in_p -max 4.8 [get_ports {rx_data_in[4]}]
set_input_delay -clock rx_clk_in_p -min 1.0 [get_ports {rx_data_in[4]}]
set_input_delay -clock rx_clk_in_p -max 4.8 [get_ports {rx_data_in[5]}]
set_input_delay -clock rx_clk_in_p -min 1.0 [get_ports {rx_data_in[5]}]
set_input_delay -clock rx_clk_in_p -max 4.8 [get_ports {rx_data_in[6]}]
set_input_delay -clock rx_clk_in_p -min 1.0 [get_ports {rx_data_in[6]}]
set_input_delay -clock rx_clk_in_p -max 4.8 [get_ports {rx_data_in[7]}]
set_input_delay -clock rx_clk_in_p -min 1.0 [get_ports {rx_data_in[7]}]
set_input_delay -clock rx_clk_in_p -max 4.8 [get_ports {rx_data_in[8]}]
set_input_delay -clock rx_clk_in_p -min 1.0 [get_ports {rx_data_in[8]}]
set_input_delay -clock rx_clk_in_p -max 4.8 [get_ports {rx_data_in[9]}]
set_input_delay -clock rx_clk_in_p -min 1.0 [get_ports {rx_data_in[9]}]
set_input_delay -clock rx_clk_in_p -max 4.8 [get_ports {rx_data_in[10]}]
set_input_delay -clock rx_clk_in_p -min 1.0 [get_ports {rx_data_in[10]}]
set_input_delay -clock rx_clk_in_p -max 4.8 [get_ports {rx_data_in[11]}]
set_input_delay -clock rx_clk_in_p -min 1.0 [get_ports {rx_data_in[11]}]

##################################################
# 3. 输出延迟约束 (TX路径: FPGA -> AD9363)
##################################################

# TX_FRAME 输出延迟
set_output_delay -clock rx_clk_in_p -max 2.3 [get_ports {tx_frame_out_p}]
set_output_delay -clock rx_clk_in_p -min -0.7 [get_ports {tx_frame_out_p}]

# TX_DATA[11:0] 输出延迟
set_output_delay -clock rx_clk_in_p -max 2.3 [get_ports {tx_data_out[0]}]
set_output_delay -clock rx_clk_in_p -min -0.7 [get_ports {tx_data_out[0]}]
set_output_delay -clock rx_clk_in_p -max 2.3 [get_ports {tx_data_out[1]}]
set_output_delay -clock rx_clk_in_p -min -0.7 [get_ports {tx_data_out[1]}]
set_output_delay -clock rx_clk_in_p -max 2.3 [get_ports {tx_data_out[2]}]
set_output_delay -clock rx_clk_in_p -min -0.7 [get_ports {tx_data_out[2]}]
set_output_delay -clock rx_clk_in_p -max 2.3 [get_ports {tx_data_out[3]}]
set_output_delay -clock rx_clk_in_p -min -0.7 [get_ports {tx_data_out[3]}]
set_output_delay -clock rx_clk_in_p -max 2.3 [get_ports {tx_data_out[4]}]
set_output_delay -clock rx_clk_in_p -min -0.7 [get_ports {tx_data_out[4]}]
set_output_delay -clock rx_clk_in_p -max 2.3 [get_ports {tx_data_out[5]}]
set_output_delay -clock rx_clk_in_p -min -0.7 [get_ports {tx_data_out[5]}]
set_output_delay -clock rx_clk_in_p -max 2.3 [get_ports {tx_data_out[6]}]
set_output_delay -clock rx_clk_in_p -min -0.7 [get_ports {tx_data_out[6]}]
set_output_delay -clock rx_clk_in_p -max 2.3 [get_ports {tx_data_out[7]}]
set_output_delay -clock rx_clk_in_p -min -0.7 [get_ports {tx_data_out[7]}]
set_output_delay -clock rx_clk_in_p -max 2.3 [get_ports {tx_data_out[8]}]
set_output_delay -clock rx_clk_in_p -min -0.7 [get_ports {tx_data_out[8]}]
set_output_delay -clock rx_clk_in_p -max 2.3 [get_ports {tx_data_out[9]}]
set_output_delay -clock rx_clk_in_p -min -0.7 [get_ports {tx_data_out[9]}]
set_output_delay -clock rx_clk_in_p -max 2.3 [get_ports {tx_data_out[10]}]
set_output_delay -clock rx_clk_in_p -min -0.7 [get_ports {tx_data_out[10]}]
set_output_delay -clock rx_clk_in_p -max 2.3 [get_ports {tx_data_out[11]}]
set_output_delay -clock rx_clk_in_p -min -0.7 [get_ports {tx_data_out[11]}]

##################################################
# 4. 虚假路径约束
##################################################

# 异步复位路径
set_false_path -from [get_ports {rst_n}]
