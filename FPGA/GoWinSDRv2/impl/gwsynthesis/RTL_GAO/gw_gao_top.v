module gw_gao(
    bb_symbol_clk,
    data_clk,
    bb_byte_clk,
    rf_tx_ready,
    rf_tx_valid,
    \rf_tx_data[7] ,
    \rf_tx_data[6] ,
    \rf_tx_data[5] ,
    \rf_tx_data[4] ,
    \rf_tx_data[3] ,
    \rf_tx_data[2] ,
    \rf_tx_data[1] ,
    \rf_tx_data[0] ,
    \u_rf_process/tx_byte_fifo_empty ,
    \u_rf_process/tx_byte_held ,
    \u_rf_process/allow_carrier ,
    \u_rf_process/stall_pipeline ,
    rst_n,
    \eth_transceiver_u/rx_state[3] ,
    \eth_transceiver_u/rx_state[2] ,
    \eth_transceiver_u/rx_state[1] ,
    \eth_transceiver_u/rx_state[0] ,
    \u_rf2eth_processor/eth_tx_frame_start ,
    ddr_init_done,
    \u_eth2rf_processor/app_cmd_en ,
    \u_eth2rf_processor/cmd_ready ,
    \u_eth2rf_processor/write_is_last ,
    \u_eth2rf_processor/read_active ,
    \u_eth2rf_processor/read_wait ,
    \u_eth2rf_processor/read_resp_pending ,
    \u_eth2rf_processor/rd_data_valid ,
    \u_eth2rf_processor/rd_data_end ,
    \u_eth2rf_processor/out_fifo_we ,
    \u_eth2rf_processor/out_fifo_full ,
    \u_eth2rf_processor/out_fifo_empty ,
    dbg_tx_underrun_sticky,
    \u_eth2rf_processor/read_words_left[15] ,
    \u_eth2rf_processor/read_words_left[14] ,
    \u_eth2rf_processor/read_words_left[13] ,
    \u_eth2rf_processor/read_words_left[12] ,
    \u_eth2rf_processor/read_words_left[11] ,
    \u_eth2rf_processor/read_words_left[10] ,
    \u_eth2rf_processor/read_words_left[9] ,
    \u_eth2rf_processor/read_words_left[8] ,
    \u_eth2rf_processor/read_words_left[7] ,
    \u_eth2rf_processor/read_words_left[6] ,
    \u_eth2rf_processor/read_words_left[5] ,
    \u_eth2rf_processor/read_words_left[4] ,
    \u_eth2rf_processor/read_words_left[3] ,
    \u_eth2rf_processor/read_words_left[2] ,
    \u_eth2rf_processor/read_words_left[1] ,
    \u_eth2rf_processor/read_words_left[0] ,
    \u_eth2rf_processor/read_bytes_left[15] ,
    \u_eth2rf_processor/read_bytes_left[14] ,
    \u_eth2rf_processor/read_bytes_left[13] ,
    \u_eth2rf_processor/read_bytes_left[12] ,
    \u_eth2rf_processor/read_bytes_left[11] ,
    \u_eth2rf_processor/read_bytes_left[10] ,
    \u_eth2rf_processor/read_bytes_left[9] ,
    \u_eth2rf_processor/read_bytes_left[8] ,
    \u_eth2rf_processor/read_bytes_left[7] ,
    \u_eth2rf_processor/read_bytes_left[6] ,
    \u_eth2rf_processor/read_bytes_left[5] ,
    \u_eth2rf_processor/read_bytes_left[4] ,
    \u_eth2rf_processor/read_bytes_left[3] ,
    \u_eth2rf_processor/read_bytes_left[2] ,
    \u_eth2rf_processor/read_bytes_left[1] ,
    \u_eth2rf_processor/read_bytes_left[0] ,
    ddr_pll_lock_dbg,
    ddr_pll_stop_dbg,
    \u_eth2rf_processor/ddr_clk ,
    dbg_tx_underrun,
    tms_pad_i,
    tck_pad_i,
    tdi_pad_i,
    tdo_pad_o
);

input bb_symbol_clk;
input data_clk;
input bb_byte_clk;
input rf_tx_ready;
input rf_tx_valid;
input \rf_tx_data[7] ;
input \rf_tx_data[6] ;
input \rf_tx_data[5] ;
input \rf_tx_data[4] ;
input \rf_tx_data[3] ;
input \rf_tx_data[2] ;
input \rf_tx_data[1] ;
input \rf_tx_data[0] ;
input \u_rf_process/tx_byte_fifo_empty ;
input \u_rf_process/tx_byte_held ;
input \u_rf_process/allow_carrier ;
input \u_rf_process/stall_pipeline ;
input rst_n;
input \eth_transceiver_u/rx_state[3] ;
input \eth_transceiver_u/rx_state[2] ;
input \eth_transceiver_u/rx_state[1] ;
input \eth_transceiver_u/rx_state[0] ;
input \u_rf2eth_processor/eth_tx_frame_start ;
input ddr_init_done;
input \u_eth2rf_processor/app_cmd_en ;
input \u_eth2rf_processor/cmd_ready ;
input \u_eth2rf_processor/write_is_last ;
input \u_eth2rf_processor/read_active ;
input \u_eth2rf_processor/read_wait ;
input \u_eth2rf_processor/read_resp_pending ;
input \u_eth2rf_processor/rd_data_valid ;
input \u_eth2rf_processor/rd_data_end ;
input \u_eth2rf_processor/out_fifo_we ;
input \u_eth2rf_processor/out_fifo_full ;
input \u_eth2rf_processor/out_fifo_empty ;
input dbg_tx_underrun_sticky;
input \u_eth2rf_processor/read_words_left[15] ;
input \u_eth2rf_processor/read_words_left[14] ;
input \u_eth2rf_processor/read_words_left[13] ;
input \u_eth2rf_processor/read_words_left[12] ;
input \u_eth2rf_processor/read_words_left[11] ;
input \u_eth2rf_processor/read_words_left[10] ;
input \u_eth2rf_processor/read_words_left[9] ;
input \u_eth2rf_processor/read_words_left[8] ;
input \u_eth2rf_processor/read_words_left[7] ;
input \u_eth2rf_processor/read_words_left[6] ;
input \u_eth2rf_processor/read_words_left[5] ;
input \u_eth2rf_processor/read_words_left[4] ;
input \u_eth2rf_processor/read_words_left[3] ;
input \u_eth2rf_processor/read_words_left[2] ;
input \u_eth2rf_processor/read_words_left[1] ;
input \u_eth2rf_processor/read_words_left[0] ;
input \u_eth2rf_processor/read_bytes_left[15] ;
input \u_eth2rf_processor/read_bytes_left[14] ;
input \u_eth2rf_processor/read_bytes_left[13] ;
input \u_eth2rf_processor/read_bytes_left[12] ;
input \u_eth2rf_processor/read_bytes_left[11] ;
input \u_eth2rf_processor/read_bytes_left[10] ;
input \u_eth2rf_processor/read_bytes_left[9] ;
input \u_eth2rf_processor/read_bytes_left[8] ;
input \u_eth2rf_processor/read_bytes_left[7] ;
input \u_eth2rf_processor/read_bytes_left[6] ;
input \u_eth2rf_processor/read_bytes_left[5] ;
input \u_eth2rf_processor/read_bytes_left[4] ;
input \u_eth2rf_processor/read_bytes_left[3] ;
input \u_eth2rf_processor/read_bytes_left[2] ;
input \u_eth2rf_processor/read_bytes_left[1] ;
input \u_eth2rf_processor/read_bytes_left[0] ;
input ddr_pll_lock_dbg;
input ddr_pll_stop_dbg;
input \u_eth2rf_processor/ddr_clk ;
input dbg_tx_underrun;
input tms_pad_i;
input tck_pad_i;
input tdi_pad_i;
output tdo_pad_o;

wire bb_symbol_clk;
wire data_clk;
wire bb_byte_clk;
wire rf_tx_ready;
wire rf_tx_valid;
wire \rf_tx_data[7] ;
wire \rf_tx_data[6] ;
wire \rf_tx_data[5] ;
wire \rf_tx_data[4] ;
wire \rf_tx_data[3] ;
wire \rf_tx_data[2] ;
wire \rf_tx_data[1] ;
wire \rf_tx_data[0] ;
wire \u_rf_process/tx_byte_fifo_empty ;
wire \u_rf_process/tx_byte_held ;
wire \u_rf_process/allow_carrier ;
wire \u_rf_process/stall_pipeline ;
wire rst_n;
wire \eth_transceiver_u/rx_state[3] ;
wire \eth_transceiver_u/rx_state[2] ;
wire \eth_transceiver_u/rx_state[1] ;
wire \eth_transceiver_u/rx_state[0] ;
wire \u_rf2eth_processor/eth_tx_frame_start ;
wire ddr_init_done;
wire \u_eth2rf_processor/app_cmd_en ;
wire \u_eth2rf_processor/cmd_ready ;
wire \u_eth2rf_processor/write_is_last ;
wire \u_eth2rf_processor/read_active ;
wire \u_eth2rf_processor/read_wait ;
wire \u_eth2rf_processor/read_resp_pending ;
wire \u_eth2rf_processor/rd_data_valid ;
wire \u_eth2rf_processor/rd_data_end ;
wire \u_eth2rf_processor/out_fifo_we ;
wire \u_eth2rf_processor/out_fifo_full ;
wire \u_eth2rf_processor/out_fifo_empty ;
wire dbg_tx_underrun_sticky;
wire \u_eth2rf_processor/read_words_left[15] ;
wire \u_eth2rf_processor/read_words_left[14] ;
wire \u_eth2rf_processor/read_words_left[13] ;
wire \u_eth2rf_processor/read_words_left[12] ;
wire \u_eth2rf_processor/read_words_left[11] ;
wire \u_eth2rf_processor/read_words_left[10] ;
wire \u_eth2rf_processor/read_words_left[9] ;
wire \u_eth2rf_processor/read_words_left[8] ;
wire \u_eth2rf_processor/read_words_left[7] ;
wire \u_eth2rf_processor/read_words_left[6] ;
wire \u_eth2rf_processor/read_words_left[5] ;
wire \u_eth2rf_processor/read_words_left[4] ;
wire \u_eth2rf_processor/read_words_left[3] ;
wire \u_eth2rf_processor/read_words_left[2] ;
wire \u_eth2rf_processor/read_words_left[1] ;
wire \u_eth2rf_processor/read_words_left[0] ;
wire \u_eth2rf_processor/read_bytes_left[15] ;
wire \u_eth2rf_processor/read_bytes_left[14] ;
wire \u_eth2rf_processor/read_bytes_left[13] ;
wire \u_eth2rf_processor/read_bytes_left[12] ;
wire \u_eth2rf_processor/read_bytes_left[11] ;
wire \u_eth2rf_processor/read_bytes_left[10] ;
wire \u_eth2rf_processor/read_bytes_left[9] ;
wire \u_eth2rf_processor/read_bytes_left[8] ;
wire \u_eth2rf_processor/read_bytes_left[7] ;
wire \u_eth2rf_processor/read_bytes_left[6] ;
wire \u_eth2rf_processor/read_bytes_left[5] ;
wire \u_eth2rf_processor/read_bytes_left[4] ;
wire \u_eth2rf_processor/read_bytes_left[3] ;
wire \u_eth2rf_processor/read_bytes_left[2] ;
wire \u_eth2rf_processor/read_bytes_left[1] ;
wire \u_eth2rf_processor/read_bytes_left[0] ;
wire ddr_pll_lock_dbg;
wire ddr_pll_stop_dbg;
wire \u_eth2rf_processor/ddr_clk ;
wire dbg_tx_underrun;
wire tms_pad_i;
wire tck_pad_i;
wire tdi_pad_i;
wire tdo_pad_o;
wire tms_i_c;
wire tck_i_c;
wire tdi_i_c;
wire tdo_o_c;
wire [9:0] control0;
wire [9:0] control1;
wire [9:0] control2;
wire gao_jtag_tck;
wire gao_jtag_reset;
wire run_test_idle_er1;
wire run_test_idle_er2;
wire shift_dr_capture_dr;
wire update_dr;
wire pause_dr;
wire enable_er1;
wire enable_er2;
wire gao_jtag_tdi;
wire tdo_er1;

IBUF tms_ibuf (
    .I(tms_pad_i),
    .O(tms_i_c)
);

IBUF tck_ibuf (
    .I(tck_pad_i),
    .O(tck_i_c)
);

IBUF tdi_ibuf (
    .I(tdi_pad_i),
    .O(tdi_i_c)
);

OBUF tdo_obuf (
    .I(tdo_o_c),
    .O(tdo_pad_o)
);

GW_JTAG  u_gw_jtag(
    .tms_pad_i(tms_i_c),
    .tck_pad_i(tck_i_c),
    .tdi_pad_i(tdi_i_c),
    .tdo_pad_o(tdo_o_c),
    .tck_o(gao_jtag_tck),
    .test_logic_reset_o(gao_jtag_reset),
    .run_test_idle_er1_o(run_test_idle_er1),
    .run_test_idle_er2_o(run_test_idle_er2),
    .shift_dr_capture_dr_o(shift_dr_capture_dr),
    .update_dr_o(update_dr),
    .pause_dr_o(pause_dr),
    .enable_er1_o(enable_er1),
    .enable_er2_o(enable_er2),
    .tdi_o(gao_jtag_tdi),
    .tdo_er1_i(tdo_er1),
    .tdo_er2_i(1'b0)
);

gw_con_top  u_icon_top(
    .tck_i(gao_jtag_tck),
    .tdi_i(gao_jtag_tdi),
    .tdo_o(tdo_er1),
    .rst_i(gao_jtag_reset),
    .control0(control0[9:0]),
    .control1(control1[9:0]),
    .control2(control2[9:0]),
    .enable_i(enable_er1),
    .shift_dr_capture_dr_i(shift_dr_capture_dr),
    .update_dr_i(update_dr)
);

ao_top_0  u_la0_top(
    .control(control0[9:0]),
    .trig0_i(rst_n),
    .trig1_i({\eth_transceiver_u/rx_state[3] ,\eth_transceiver_u/rx_state[2] ,\eth_transceiver_u/rx_state[1] ,\eth_transceiver_u/rx_state[0] }),
    .trig2_i(rf_tx_valid),
    .trig3_i(\u_rf2eth_processor/eth_tx_frame_start ),
    .data_i({bb_symbol_clk,data_clk,bb_byte_clk,rf_tx_ready,rf_tx_valid,\rf_tx_data[7] ,\rf_tx_data[6] ,\rf_tx_data[5] ,\rf_tx_data[4] ,\rf_tx_data[3] ,\rf_tx_data[2] ,\rf_tx_data[1] ,\rf_tx_data[0] ,\u_rf_process/tx_byte_fifo_empty ,\u_rf_process/tx_byte_held ,\u_rf_process/allow_carrier ,\u_rf_process/stall_pipeline }),
    .clk_i(bb_byte_clk)
);

ao_top_1  u_la1_top(
    .control(control1[9:0]),
    .trig0_i(dbg_tx_underrun_sticky),
    .data_i({ddr_init_done,\u_eth2rf_processor/app_cmd_en ,\u_eth2rf_processor/cmd_ready ,\u_eth2rf_processor/write_is_last ,\u_eth2rf_processor/read_active ,\u_eth2rf_processor/read_wait ,\u_eth2rf_processor/read_resp_pending ,\u_eth2rf_processor/rd_data_valid ,\u_eth2rf_processor/rd_data_end ,\u_eth2rf_processor/out_fifo_we ,\u_eth2rf_processor/out_fifo_full ,\u_eth2rf_processor/out_fifo_empty ,dbg_tx_underrun_sticky,\u_eth2rf_processor/read_words_left[15] ,\u_eth2rf_processor/read_words_left[14] ,\u_eth2rf_processor/read_words_left[13] ,\u_eth2rf_processor/read_words_left[12] ,\u_eth2rf_processor/read_words_left[11] ,\u_eth2rf_processor/read_words_left[10] ,\u_eth2rf_processor/read_words_left[9] ,\u_eth2rf_processor/read_words_left[8] ,\u_eth2rf_processor/read_words_left[7] ,\u_eth2rf_processor/read_words_left[6] ,\u_eth2rf_processor/read_words_left[5] ,\u_eth2rf_processor/read_words_left[4] ,\u_eth2rf_processor/read_words_left[3] ,\u_eth2rf_processor/read_words_left[2] ,\u_eth2rf_processor/read_words_left[1] ,\u_eth2rf_processor/read_words_left[0] ,\u_eth2rf_processor/read_bytes_left[15] ,\u_eth2rf_processor/read_bytes_left[14] ,\u_eth2rf_processor/read_bytes_left[13] ,\u_eth2rf_processor/read_bytes_left[12] ,\u_eth2rf_processor/read_bytes_left[11] ,\u_eth2rf_processor/read_bytes_left[10] ,\u_eth2rf_processor/read_bytes_left[9] ,\u_eth2rf_processor/read_bytes_left[8] ,\u_eth2rf_processor/read_bytes_left[7] ,\u_eth2rf_processor/read_bytes_left[6] ,\u_eth2rf_processor/read_bytes_left[5] ,\u_eth2rf_processor/read_bytes_left[4] ,\u_eth2rf_processor/read_bytes_left[3] ,\u_eth2rf_processor/read_bytes_left[2] ,\u_eth2rf_processor/read_bytes_left[1] ,\u_eth2rf_processor/read_bytes_left[0] ,ddr_pll_lock_dbg,ddr_pll_stop_dbg}),
    .clk_i(\u_eth2rf_processor/ddr_clk )
);

ao_top_2  u_la2_top(
    .control(control2[9:0]),
    .trig0_i(dbg_tx_underrun),
    .data_i({rf_tx_valid,rf_tx_ready,\u_rf_process/tx_byte_fifo_empty ,\u_rf_process/allow_carrier ,dbg_tx_underrun_sticky}),
    .clk_i(bb_byte_clk)
);

endmodule
