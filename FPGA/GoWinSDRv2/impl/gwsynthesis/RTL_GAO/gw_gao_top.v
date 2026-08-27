module gw_gao(
    \adc_data_out_i1[11] ,
    \adc_data_out_i1[10] ,
    \adc_data_out_i1[9] ,
    \adc_data_out_i1[8] ,
    \adc_data_out_i1[7] ,
    \adc_data_out_i1[6] ,
    \adc_data_out_i1[5] ,
    \adc_data_out_i1[4] ,
    \adc_data_out_i1[3] ,
    \adc_data_out_i1[2] ,
    \adc_data_out_i1[1] ,
    \adc_data_out_i1[0] ,
    \adc_data_out_q1[11] ,
    \adc_data_out_q1[10] ,
    \adc_data_out_q1[9] ,
    \adc_data_out_q1[8] ,
    \adc_data_out_q1[7] ,
    \adc_data_out_q1[6] ,
    \adc_data_out_q1[5] ,
    \adc_data_out_q1[4] ,
    \adc_data_out_q1[3] ,
    \adc_data_out_q1[2] ,
    \adc_data_out_q1[1] ,
    \adc_data_out_q1[0] ,
    \dac_data_out_i1[11] ,
    \dac_data_out_i1[10] ,
    \dac_data_out_i1[9] ,
    \dac_data_out_i1[8] ,
    \dac_data_out_i1[7] ,
    \dac_data_out_i1[6] ,
    \dac_data_out_i1[5] ,
    \dac_data_out_i1[4] ,
    \dac_data_out_i1[3] ,
    \dac_data_out_i1[2] ,
    \dac_data_out_i1[1] ,
    \dac_data_out_i1[0] ,
    \dac_data_out_q1[11] ,
    \dac_data_out_q1[10] ,
    \dac_data_out_q1[9] ,
    \dac_data_out_q1[8] ,
    \dac_data_out_q1[7] ,
    \dac_data_out_q1[6] ,
    \dac_data_out_q1[5] ,
    \dac_data_out_q1[4] ,
    \dac_data_out_q1[3] ,
    \dac_data_out_q1[2] ,
    \dac_data_out_q1[1] ,
    \dac_data_out_q1[0] ,
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
    \u_rf_process/gardner_sync_flag ,
    \u_rf_process/gardner_sync_I ,
    \u_rf_process/gardner_sync_Q ,
    \u_rf_process/dqpsk_rx_data[7] ,
    \u_rf_process/dqpsk_rx_data[6] ,
    \u_rf_process/dqpsk_rx_data[5] ,
    \u_rf_process/dqpsk_rx_data[4] ,
    \u_rf_process/dqpsk_rx_data[3] ,
    \u_rf_process/dqpsk_rx_data[2] ,
    \u_rf_process/dqpsk_rx_data[1] ,
    \u_rf_process/dqpsk_rx_data[0] ,
    \u_rf_process/u_rf_dqpsk_decoder/frame_aligned_data_dbg[7] ,
    \u_rf_process/u_rf_dqpsk_decoder/frame_aligned_data_dbg[6] ,
    \u_rf_process/u_rf_dqpsk_decoder/frame_aligned_data_dbg[5] ,
    \u_rf_process/u_rf_dqpsk_decoder/frame_aligned_data_dbg[4] ,
    \u_rf_process/u_rf_dqpsk_decoder/frame_aligned_data_dbg[3] ,
    \u_rf_process/u_rf_dqpsk_decoder/frame_aligned_data_dbg[2] ,
    \u_rf_process/u_rf_dqpsk_decoder/frame_aligned_data_dbg[1] ,
    \u_rf_process/u_rf_dqpsk_decoder/frame_aligned_data_dbg[0] ,
    \u_rf_process/u_rf_dqpsk_decoder/frame_head_found_dbg ,
    \u_rf_process/u_rf_dqpsk_decoder/deframe_state_dbg[1] ,
    \u_rf_process/u_rf_dqpsk_decoder/deframe_state_dbg[0] ,
    \u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[15] ,
    \u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[14] ,
    \u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[13] ,
    \u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[12] ,
    \u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[11] ,
    \u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[10] ,
    \u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[9] ,
    \u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[8] ,
    \u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[7] ,
    \u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[6] ,
    \u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[5] ,
    \u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[4] ,
    \u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[3] ,
    \u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[2] ,
    \u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[1] ,
    \u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[0] ,
    \u_rf_process/gardner_sync_u0/uk[15] ,
    \u_rf_process/gardner_sync_u0/uk[14] ,
    \u_rf_process/gardner_sync_u0/uk[13] ,
    \u_rf_process/gardner_sync_u0/uk[12] ,
    \u_rf_process/gardner_sync_u0/uk[11] ,
    \u_rf_process/gardner_sync_u0/uk[10] ,
    \u_rf_process/gardner_sync_u0/uk[9] ,
    \u_rf_process/gardner_sync_u0/uk[8] ,
    \u_rf_process/gardner_sync_u0/uk[7] ,
    \u_rf_process/gardner_sync_u0/uk[6] ,
    \u_rf_process/gardner_sync_u0/uk[5] ,
    \u_rf_process/gardner_sync_u0/uk[4] ,
    \u_rf_process/gardner_sync_u0/uk[3] ,
    \u_rf_process/gardner_sync_u0/uk[2] ,
    \u_rf_process/gardner_sync_u0/uk[1] ,
    \u_rf_process/gardner_sync_u0/uk[0] ,
    \u_rf_process/gardner_sync_u0/I_y[19] ,
    \u_rf_process/gardner_sync_u0/I_y[18] ,
    \u_rf_process/gardner_sync_u0/I_y[17] ,
    \u_rf_process/gardner_sync_u0/I_y[16] ,
    \u_rf_process/gardner_sync_u0/I_y[15] ,
    \u_rf_process/gardner_sync_u0/I_y[14] ,
    \u_rf_process/gardner_sync_u0/I_y[13] ,
    \u_rf_process/gardner_sync_u0/I_y[12] ,
    \u_rf_process/gardner_sync_u0/I_y[11] ,
    \u_rf_process/gardner_sync_u0/I_y[10] ,
    \u_rf_process/gardner_sync_u0/I_y[9] ,
    \u_rf_process/gardner_sync_u0/I_y[8] ,
    \u_rf_process/gardner_sync_u0/I_y[7] ,
    \u_rf_process/gardner_sync_u0/I_y[6] ,
    \u_rf_process/gardner_sync_u0/I_y[5] ,
    \u_rf_process/gardner_sync_u0/I_y[4] ,
    \u_rf_process/gardner_sync_u0/I_y[3] ,
    \u_rf_process/gardner_sync_u0/I_y[2] ,
    \u_rf_process/gardner_sync_u0/I_y[1] ,
    \u_rf_process/gardner_sync_u0/I_y[0] ,
    \u_rf_process/gardner_sync_u0/Q_y[19] ,
    \u_rf_process/gardner_sync_u0/Q_y[18] ,
    \u_rf_process/gardner_sync_u0/Q_y[17] ,
    \u_rf_process/gardner_sync_u0/Q_y[16] ,
    \u_rf_process/gardner_sync_u0/Q_y[15] ,
    \u_rf_process/gardner_sync_u0/Q_y[14] ,
    \u_rf_process/gardner_sync_u0/Q_y[13] ,
    \u_rf_process/gardner_sync_u0/Q_y[12] ,
    \u_rf_process/gardner_sync_u0/Q_y[11] ,
    \u_rf_process/gardner_sync_u0/Q_y[10] ,
    \u_rf_process/gardner_sync_u0/Q_y[9] ,
    \u_rf_process/gardner_sync_u0/Q_y[8] ,
    \u_rf_process/gardner_sync_u0/Q_y[7] ,
    \u_rf_process/gardner_sync_u0/Q_y[6] ,
    \u_rf_process/gardner_sync_u0/Q_y[5] ,
    \u_rf_process/gardner_sync_u0/Q_y[4] ,
    \u_rf_process/gardner_sync_u0/Q_y[3] ,
    \u_rf_process/gardner_sync_u0/Q_y[2] ,
    \u_rf_process/gardner_sync_u0/Q_y[1] ,
    \u_rf_process/gardner_sync_u0/Q_y[0] ,
    \u_rf_process/gardner_sync_u0/nco_strobe_flag ,
    \u_rf_process/gardner_sync_u0/ted_strobe_flag ,
    ddr_init_done,
    ddr_pll_lock_dbg,
    ddr_phy_reset_dbg,
    ddr_pll_stop_dbg,
    eth_ingress_accept,
    eth_ingress_drop,
    \ddr_queued_words_dbg[15] ,
    \ddr_queued_words_dbg[14] ,
    \ddr_queued_words_dbg[13] ,
    \ddr_queued_words_dbg[12] ,
    \ddr_queued_words_dbg[11] ,
    \ddr_queued_words_dbg[10] ,
    \ddr_queued_words_dbg[9] ,
    \ddr_queued_words_dbg[8] ,
    \ddr_queued_words_dbg[7] ,
    \ddr_queued_words_dbg[6] ,
    \ddr_queued_words_dbg[5] ,
    \ddr_queued_words_dbg[4] ,
    \ddr_queued_words_dbg[3] ,
    \ddr_queued_words_dbg[2] ,
    \ddr_queued_words_dbg[1] ,
    \ddr_queued_words_dbg[0] ,
    \eth_credit_packets_dbg[15] ,
    \eth_credit_packets_dbg[14] ,
    \eth_credit_packets_dbg[13] ,
    \eth_credit_packets_dbg[12] ,
    \eth_credit_packets_dbg[11] ,
    \eth_credit_packets_dbg[10] ,
    \eth_credit_packets_dbg[9] ,
    \eth_credit_packets_dbg[8] ,
    \eth_credit_packets_dbg[7] ,
    \eth_credit_packets_dbg[6] ,
    \eth_credit_packets_dbg[5] ,
    \eth_credit_packets_dbg[4] ,
    \eth_credit_packets_dbg[3] ,
    \eth_credit_packets_dbg[2] ,
    \eth_credit_packets_dbg[1] ,
    \eth_credit_packets_dbg[0] ,
    rst_n,
    \eth_transceiver_u/rx_state[3] ,
    \eth_transceiver_u/rx_state[2] ,
    \eth_transceiver_u/rx_state[1] ,
    \eth_transceiver_u/rx_state[0] ,
    \u_rf2eth_processor/eth_tx_frame_start ,
    \u_eth2rf_processor/in_fifo_q[7] ,
    \u_eth2rf_processor/in_fifo_q[6] ,
    \u_eth2rf_processor/in_fifo_q[5] ,
    \u_eth2rf_processor/in_fifo_q[4] ,
    \u_eth2rf_processor/in_fifo_q[3] ,
    \u_eth2rf_processor/in_fifo_q[2] ,
    \u_eth2rf_processor/in_fifo_q[1] ,
    \u_eth2rf_processor/in_fifo_q[0] ,
    \u_eth2rf_processor/ddr_clk100_counter_dbg[15] ,
    \u_eth2rf_processor/ddr_clk100_counter_dbg[14] ,
    \u_eth2rf_processor/ddr_clk100_counter_dbg[13] ,
    \u_eth2rf_processor/ddr_clk100_counter_dbg[12] ,
    \u_eth2rf_processor/ddr_clk100_counter_dbg[11] ,
    \u_eth2rf_processor/ddr_clk100_counter_dbg[10] ,
    \u_eth2rf_processor/ddr_clk100_counter_dbg[9] ,
    \u_eth2rf_processor/ddr_clk100_counter_dbg[8] ,
    \u_eth2rf_processor/ddr_clk100_counter_dbg[7] ,
    \u_eth2rf_processor/ddr_clk100_counter_dbg[6] ,
    \u_eth2rf_processor/ddr_clk100_counter_dbg[5] ,
    \u_eth2rf_processor/ddr_clk100_counter_dbg[4] ,
    \u_eth2rf_processor/ddr_clk100_counter_dbg[3] ,
    \u_eth2rf_processor/ddr_clk100_counter_dbg[2] ,
    \u_eth2rf_processor/ddr_clk100_counter_dbg[1] ,
    \u_eth2rf_processor/ddr_clk100_counter_dbg[0] ,
    \u_eth2rf_processor/ddr_memclk_counter_dbg[15] ,
    \u_eth2rf_processor/ddr_memclk_counter_dbg[14] ,
    \u_eth2rf_processor/ddr_memclk_counter_dbg[13] ,
    \u_eth2rf_processor/ddr_memclk_counter_dbg[12] ,
    \u_eth2rf_processor/ddr_memclk_counter_dbg[11] ,
    \u_eth2rf_processor/ddr_memclk_counter_dbg[10] ,
    \u_eth2rf_processor/ddr_memclk_counter_dbg[9] ,
    \u_eth2rf_processor/ddr_memclk_counter_dbg[8] ,
    \u_eth2rf_processor/ddr_memclk_counter_dbg[7] ,
    \u_eth2rf_processor/ddr_memclk_counter_dbg[6] ,
    \u_eth2rf_processor/ddr_memclk_counter_dbg[5] ,
    \u_eth2rf_processor/ddr_memclk_counter_dbg[4] ,
    \u_eth2rf_processor/ddr_memclk_counter_dbg[3] ,
    \u_eth2rf_processor/ddr_memclk_counter_dbg[2] ,
    \u_eth2rf_processor/ddr_memclk_counter_dbg[1] ,
    \u_eth2rf_processor/ddr_memclk_counter_dbg[0] ,
    \u_eth2rf_processor/in_fifo_empty ,
    \u_eth2rf_processor/in_fifo_re_r ,
    \u_eth2rf_processor/in_fifo_data_valid ,
    \u_eth2rf_processor/app_cmd[2] ,
    \u_eth2rf_processor/app_cmd[1] ,
    \u_eth2rf_processor/app_cmd[0] ,
    \u_eth2rf_processor/app_wr_mask[15] ,
    \u_eth2rf_processor/app_wr_mask[14] ,
    \u_eth2rf_processor/app_wr_mask[13] ,
    \u_eth2rf_processor/app_wr_mask[12] ,
    \u_eth2rf_processor/app_wr_mask[11] ,
    \u_eth2rf_processor/app_wr_mask[10] ,
    \u_eth2rf_processor/app_wr_mask[9] ,
    \u_eth2rf_processor/app_wr_mask[8] ,
    \u_eth2rf_processor/app_wr_mask[7] ,
    \u_eth2rf_processor/app_wr_mask[6] ,
    \u_eth2rf_processor/app_wr_mask[5] ,
    \u_eth2rf_processor/app_wr_mask[4] ,
    \u_eth2rf_processor/app_wr_mask[3] ,
    \u_eth2rf_processor/app_wr_mask[2] ,
    \u_eth2rf_processor/app_wr_mask[1] ,
    \u_eth2rf_processor/app_wr_mask[0] ,
    \u_eth2rf_processor/app_cmd_en ,
    \u_eth2rf_processor/cmd_ready ,
    \u_eth2rf_processor/app_wr_en ,
    \u_eth2rf_processor/wr_data_rdy ,
    \u_eth2rf_processor/write_pending ,
    \u_eth2rf_processor/write_is_last ,
    \u_eth2rf_processor/read_active ,
    \u_eth2rf_processor/read_wait ,
    \u_eth2rf_processor/rd_data_valid ,
    \u_eth2rf_processor/out_fifo_we ,
    \u_eth2rf_processor/pending_word[127] ,
    \u_eth2rf_processor/pending_word[126] ,
    \u_eth2rf_processor/pending_word[125] ,
    \u_eth2rf_processor/pending_word[124] ,
    \u_eth2rf_processor/pending_word[123] ,
    \u_eth2rf_processor/pending_word[122] ,
    \u_eth2rf_processor/pending_word[121] ,
    \u_eth2rf_processor/pending_word[120] ,
    \u_eth2rf_processor/pending_word[119] ,
    \u_eth2rf_processor/pending_word[118] ,
    \u_eth2rf_processor/pending_word[117] ,
    \u_eth2rf_processor/pending_word[116] ,
    \u_eth2rf_processor/pending_word[115] ,
    \u_eth2rf_processor/pending_word[114] ,
    \u_eth2rf_processor/pending_word[113] ,
    \u_eth2rf_processor/pending_word[112] ,
    \u_eth2rf_processor/pending_word[111] ,
    \u_eth2rf_processor/pending_word[110] ,
    \u_eth2rf_processor/pending_word[109] ,
    \u_eth2rf_processor/pending_word[108] ,
    \u_eth2rf_processor/pending_word[107] ,
    \u_eth2rf_processor/pending_word[106] ,
    \u_eth2rf_processor/pending_word[105] ,
    \u_eth2rf_processor/pending_word[104] ,
    \u_eth2rf_processor/pending_word[103] ,
    \u_eth2rf_processor/pending_word[102] ,
    \u_eth2rf_processor/pending_word[101] ,
    \u_eth2rf_processor/pending_word[100] ,
    \u_eth2rf_processor/pending_word[99] ,
    \u_eth2rf_processor/pending_word[98] ,
    \u_eth2rf_processor/pending_word[97] ,
    \u_eth2rf_processor/pending_word[96] ,
    \u_eth2rf_processor/pending_word[95] ,
    \u_eth2rf_processor/pending_word[94] ,
    \u_eth2rf_processor/pending_word[93] ,
    \u_eth2rf_processor/pending_word[92] ,
    \u_eth2rf_processor/pending_word[91] ,
    \u_eth2rf_processor/pending_word[90] ,
    \u_eth2rf_processor/pending_word[89] ,
    \u_eth2rf_processor/pending_word[88] ,
    \u_eth2rf_processor/pending_word[87] ,
    \u_eth2rf_processor/pending_word[86] ,
    \u_eth2rf_processor/pending_word[85] ,
    \u_eth2rf_processor/pending_word[84] ,
    \u_eth2rf_processor/pending_word[83] ,
    \u_eth2rf_processor/pending_word[82] ,
    \u_eth2rf_processor/pending_word[81] ,
    \u_eth2rf_processor/pending_word[80] ,
    \u_eth2rf_processor/pending_word[79] ,
    \u_eth2rf_processor/pending_word[78] ,
    \u_eth2rf_processor/pending_word[77] ,
    \u_eth2rf_processor/pending_word[76] ,
    \u_eth2rf_processor/pending_word[75] ,
    \u_eth2rf_processor/pending_word[74] ,
    \u_eth2rf_processor/pending_word[73] ,
    \u_eth2rf_processor/pending_word[72] ,
    \u_eth2rf_processor/pending_word[71] ,
    \u_eth2rf_processor/pending_word[70] ,
    \u_eth2rf_processor/pending_word[69] ,
    \u_eth2rf_processor/pending_word[68] ,
    \u_eth2rf_processor/pending_word[67] ,
    \u_eth2rf_processor/pending_word[66] ,
    \u_eth2rf_processor/pending_word[65] ,
    \u_eth2rf_processor/pending_word[64] ,
    \u_eth2rf_processor/pending_word[63] ,
    \u_eth2rf_processor/pending_word[62] ,
    \u_eth2rf_processor/pending_word[61] ,
    \u_eth2rf_processor/pending_word[60] ,
    \u_eth2rf_processor/pending_word[59] ,
    \u_eth2rf_processor/pending_word[58] ,
    \u_eth2rf_processor/pending_word[57] ,
    \u_eth2rf_processor/pending_word[56] ,
    \u_eth2rf_processor/pending_word[55] ,
    \u_eth2rf_processor/pending_word[54] ,
    \u_eth2rf_processor/pending_word[53] ,
    \u_eth2rf_processor/pending_word[52] ,
    \u_eth2rf_processor/pending_word[51] ,
    \u_eth2rf_processor/pending_word[50] ,
    \u_eth2rf_processor/pending_word[49] ,
    \u_eth2rf_processor/pending_word[48] ,
    \u_eth2rf_processor/pending_word[47] ,
    \u_eth2rf_processor/pending_word[46] ,
    \u_eth2rf_processor/pending_word[45] ,
    \u_eth2rf_processor/pending_word[44] ,
    \u_eth2rf_processor/pending_word[43] ,
    \u_eth2rf_processor/pending_word[42] ,
    \u_eth2rf_processor/pending_word[41] ,
    \u_eth2rf_processor/pending_word[40] ,
    \u_eth2rf_processor/pending_word[39] ,
    \u_eth2rf_processor/pending_word[38] ,
    \u_eth2rf_processor/pending_word[37] ,
    \u_eth2rf_processor/pending_word[36] ,
    \u_eth2rf_processor/pending_word[35] ,
    \u_eth2rf_processor/pending_word[34] ,
    \u_eth2rf_processor/pending_word[33] ,
    \u_eth2rf_processor/pending_word[32] ,
    \u_eth2rf_processor/pending_word[31] ,
    \u_eth2rf_processor/pending_word[30] ,
    \u_eth2rf_processor/pending_word[29] ,
    \u_eth2rf_processor/pending_word[28] ,
    \u_eth2rf_processor/pending_word[27] ,
    \u_eth2rf_processor/pending_word[26] ,
    \u_eth2rf_processor/pending_word[25] ,
    \u_eth2rf_processor/pending_word[24] ,
    \u_eth2rf_processor/pending_word[23] ,
    \u_eth2rf_processor/pending_word[22] ,
    \u_eth2rf_processor/pending_word[21] ,
    \u_eth2rf_processor/pending_word[20] ,
    \u_eth2rf_processor/pending_word[19] ,
    \u_eth2rf_processor/pending_word[18] ,
    \u_eth2rf_processor/pending_word[17] ,
    \u_eth2rf_processor/pending_word[16] ,
    \u_eth2rf_processor/pending_word[15] ,
    \u_eth2rf_processor/pending_word[14] ,
    \u_eth2rf_processor/pending_word[13] ,
    \u_eth2rf_processor/pending_word[12] ,
    \u_eth2rf_processor/pending_word[11] ,
    \u_eth2rf_processor/pending_word[10] ,
    \u_eth2rf_processor/pending_word[9] ,
    \u_eth2rf_processor/pending_word[8] ,
    \u_eth2rf_processor/pending_word[7] ,
    \u_eth2rf_processor/pending_word[6] ,
    \u_eth2rf_processor/pending_word[5] ,
    \u_eth2rf_processor/pending_word[4] ,
    \u_eth2rf_processor/pending_word[3] ,
    \u_eth2rf_processor/pending_word[2] ,
    \u_eth2rf_processor/pending_word[1] ,
    \u_eth2rf_processor/pending_word[0] ,
    \u_eth2rf_processor/app_wr_data[127] ,
    \u_eth2rf_processor/app_wr_data[126] ,
    \u_eth2rf_processor/app_wr_data[125] ,
    \u_eth2rf_processor/app_wr_data[124] ,
    \u_eth2rf_processor/app_wr_data[123] ,
    \u_eth2rf_processor/app_wr_data[122] ,
    \u_eth2rf_processor/app_wr_data[121] ,
    \u_eth2rf_processor/app_wr_data[120] ,
    \u_eth2rf_processor/app_wr_data[119] ,
    \u_eth2rf_processor/app_wr_data[118] ,
    \u_eth2rf_processor/app_wr_data[117] ,
    \u_eth2rf_processor/app_wr_data[116] ,
    \u_eth2rf_processor/app_wr_data[115] ,
    \u_eth2rf_processor/app_wr_data[114] ,
    \u_eth2rf_processor/app_wr_data[113] ,
    \u_eth2rf_processor/app_wr_data[112] ,
    \u_eth2rf_processor/app_wr_data[111] ,
    \u_eth2rf_processor/app_wr_data[110] ,
    \u_eth2rf_processor/app_wr_data[109] ,
    \u_eth2rf_processor/app_wr_data[108] ,
    \u_eth2rf_processor/app_wr_data[107] ,
    \u_eth2rf_processor/app_wr_data[106] ,
    \u_eth2rf_processor/app_wr_data[105] ,
    \u_eth2rf_processor/app_wr_data[104] ,
    \u_eth2rf_processor/app_wr_data[103] ,
    \u_eth2rf_processor/app_wr_data[102] ,
    \u_eth2rf_processor/app_wr_data[101] ,
    \u_eth2rf_processor/app_wr_data[100] ,
    \u_eth2rf_processor/app_wr_data[99] ,
    \u_eth2rf_processor/app_wr_data[98] ,
    \u_eth2rf_processor/app_wr_data[97] ,
    \u_eth2rf_processor/app_wr_data[96] ,
    \u_eth2rf_processor/app_wr_data[95] ,
    \u_eth2rf_processor/app_wr_data[94] ,
    \u_eth2rf_processor/app_wr_data[93] ,
    \u_eth2rf_processor/app_wr_data[92] ,
    \u_eth2rf_processor/app_wr_data[91] ,
    \u_eth2rf_processor/app_wr_data[90] ,
    \u_eth2rf_processor/app_wr_data[89] ,
    \u_eth2rf_processor/app_wr_data[88] ,
    \u_eth2rf_processor/app_wr_data[87] ,
    \u_eth2rf_processor/app_wr_data[86] ,
    \u_eth2rf_processor/app_wr_data[85] ,
    \u_eth2rf_processor/app_wr_data[84] ,
    \u_eth2rf_processor/app_wr_data[83] ,
    \u_eth2rf_processor/app_wr_data[82] ,
    \u_eth2rf_processor/app_wr_data[81] ,
    \u_eth2rf_processor/app_wr_data[80] ,
    \u_eth2rf_processor/app_wr_data[79] ,
    \u_eth2rf_processor/app_wr_data[78] ,
    \u_eth2rf_processor/app_wr_data[77] ,
    \u_eth2rf_processor/app_wr_data[76] ,
    \u_eth2rf_processor/app_wr_data[75] ,
    \u_eth2rf_processor/app_wr_data[74] ,
    \u_eth2rf_processor/app_wr_data[73] ,
    \u_eth2rf_processor/app_wr_data[72] ,
    \u_eth2rf_processor/app_wr_data[71] ,
    \u_eth2rf_processor/app_wr_data[70] ,
    \u_eth2rf_processor/app_wr_data[69] ,
    \u_eth2rf_processor/app_wr_data[68] ,
    \u_eth2rf_processor/app_wr_data[67] ,
    \u_eth2rf_processor/app_wr_data[66] ,
    \u_eth2rf_processor/app_wr_data[65] ,
    \u_eth2rf_processor/app_wr_data[64] ,
    \u_eth2rf_processor/app_wr_data[63] ,
    \u_eth2rf_processor/app_wr_data[62] ,
    \u_eth2rf_processor/app_wr_data[61] ,
    \u_eth2rf_processor/app_wr_data[60] ,
    \u_eth2rf_processor/app_wr_data[59] ,
    \u_eth2rf_processor/app_wr_data[58] ,
    \u_eth2rf_processor/app_wr_data[57] ,
    \u_eth2rf_processor/app_wr_data[56] ,
    \u_eth2rf_processor/app_wr_data[55] ,
    \u_eth2rf_processor/app_wr_data[54] ,
    \u_eth2rf_processor/app_wr_data[53] ,
    \u_eth2rf_processor/app_wr_data[52] ,
    \u_eth2rf_processor/app_wr_data[51] ,
    \u_eth2rf_processor/app_wr_data[50] ,
    \u_eth2rf_processor/app_wr_data[49] ,
    \u_eth2rf_processor/app_wr_data[48] ,
    \u_eth2rf_processor/app_wr_data[47] ,
    \u_eth2rf_processor/app_wr_data[46] ,
    \u_eth2rf_processor/app_wr_data[45] ,
    \u_eth2rf_processor/app_wr_data[44] ,
    \u_eth2rf_processor/app_wr_data[43] ,
    \u_eth2rf_processor/app_wr_data[42] ,
    \u_eth2rf_processor/app_wr_data[41] ,
    \u_eth2rf_processor/app_wr_data[40] ,
    \u_eth2rf_processor/app_wr_data[39] ,
    \u_eth2rf_processor/app_wr_data[38] ,
    \u_eth2rf_processor/app_wr_data[37] ,
    \u_eth2rf_processor/app_wr_data[36] ,
    \u_eth2rf_processor/app_wr_data[35] ,
    \u_eth2rf_processor/app_wr_data[34] ,
    \u_eth2rf_processor/app_wr_data[33] ,
    \u_eth2rf_processor/app_wr_data[32] ,
    \u_eth2rf_processor/app_wr_data[31] ,
    \u_eth2rf_processor/app_wr_data[30] ,
    \u_eth2rf_processor/app_wr_data[29] ,
    \u_eth2rf_processor/app_wr_data[28] ,
    \u_eth2rf_processor/app_wr_data[27] ,
    \u_eth2rf_processor/app_wr_data[26] ,
    \u_eth2rf_processor/app_wr_data[25] ,
    \u_eth2rf_processor/app_wr_data[24] ,
    \u_eth2rf_processor/app_wr_data[23] ,
    \u_eth2rf_processor/app_wr_data[22] ,
    \u_eth2rf_processor/app_wr_data[21] ,
    \u_eth2rf_processor/app_wr_data[20] ,
    \u_eth2rf_processor/app_wr_data[19] ,
    \u_eth2rf_processor/app_wr_data[18] ,
    \u_eth2rf_processor/app_wr_data[17] ,
    \u_eth2rf_processor/app_wr_data[16] ,
    \u_eth2rf_processor/app_wr_data[15] ,
    \u_eth2rf_processor/app_wr_data[14] ,
    \u_eth2rf_processor/app_wr_data[13] ,
    \u_eth2rf_processor/app_wr_data[12] ,
    \u_eth2rf_processor/app_wr_data[11] ,
    \u_eth2rf_processor/app_wr_data[10] ,
    \u_eth2rf_processor/app_wr_data[9] ,
    \u_eth2rf_processor/app_wr_data[8] ,
    \u_eth2rf_processor/app_wr_data[7] ,
    \u_eth2rf_processor/app_wr_data[6] ,
    \u_eth2rf_processor/app_wr_data[5] ,
    \u_eth2rf_processor/app_wr_data[4] ,
    \u_eth2rf_processor/app_wr_data[3] ,
    \u_eth2rf_processor/app_wr_data[2] ,
    \u_eth2rf_processor/app_wr_data[1] ,
    \u_eth2rf_processor/app_wr_data[0] ,
    \u_eth2rf_processor/u_ddr3/rd_data[127] ,
    \u_eth2rf_processor/u_ddr3/rd_data[126] ,
    \u_eth2rf_processor/u_ddr3/rd_data[125] ,
    \u_eth2rf_processor/u_ddr3/rd_data[124] ,
    \u_eth2rf_processor/u_ddr3/rd_data[123] ,
    \u_eth2rf_processor/u_ddr3/rd_data[122] ,
    \u_eth2rf_processor/u_ddr3/rd_data[121] ,
    \u_eth2rf_processor/u_ddr3/rd_data[120] ,
    \u_eth2rf_processor/u_ddr3/rd_data[119] ,
    \u_eth2rf_processor/u_ddr3/rd_data[118] ,
    \u_eth2rf_processor/u_ddr3/rd_data[117] ,
    \u_eth2rf_processor/u_ddr3/rd_data[116] ,
    \u_eth2rf_processor/u_ddr3/rd_data[115] ,
    \u_eth2rf_processor/u_ddr3/rd_data[114] ,
    \u_eth2rf_processor/u_ddr3/rd_data[113] ,
    \u_eth2rf_processor/u_ddr3/rd_data[112] ,
    \u_eth2rf_processor/u_ddr3/rd_data[111] ,
    \u_eth2rf_processor/u_ddr3/rd_data[110] ,
    \u_eth2rf_processor/u_ddr3/rd_data[109] ,
    \u_eth2rf_processor/u_ddr3/rd_data[108] ,
    \u_eth2rf_processor/u_ddr3/rd_data[107] ,
    \u_eth2rf_processor/u_ddr3/rd_data[106] ,
    \u_eth2rf_processor/u_ddr3/rd_data[105] ,
    \u_eth2rf_processor/u_ddr3/rd_data[104] ,
    \u_eth2rf_processor/u_ddr3/rd_data[103] ,
    \u_eth2rf_processor/u_ddr3/rd_data[102] ,
    \u_eth2rf_processor/u_ddr3/rd_data[101] ,
    \u_eth2rf_processor/u_ddr3/rd_data[100] ,
    \u_eth2rf_processor/u_ddr3/rd_data[99] ,
    \u_eth2rf_processor/u_ddr3/rd_data[98] ,
    \u_eth2rf_processor/u_ddr3/rd_data[97] ,
    \u_eth2rf_processor/u_ddr3/rd_data[96] ,
    \u_eth2rf_processor/u_ddr3/rd_data[95] ,
    \u_eth2rf_processor/u_ddr3/rd_data[94] ,
    \u_eth2rf_processor/u_ddr3/rd_data[93] ,
    \u_eth2rf_processor/u_ddr3/rd_data[92] ,
    \u_eth2rf_processor/u_ddr3/rd_data[91] ,
    \u_eth2rf_processor/u_ddr3/rd_data[90] ,
    \u_eth2rf_processor/u_ddr3/rd_data[89] ,
    \u_eth2rf_processor/u_ddr3/rd_data[88] ,
    \u_eth2rf_processor/u_ddr3/rd_data[87] ,
    \u_eth2rf_processor/u_ddr3/rd_data[86] ,
    \u_eth2rf_processor/u_ddr3/rd_data[85] ,
    \u_eth2rf_processor/u_ddr3/rd_data[84] ,
    \u_eth2rf_processor/u_ddr3/rd_data[83] ,
    \u_eth2rf_processor/u_ddr3/rd_data[82] ,
    \u_eth2rf_processor/u_ddr3/rd_data[81] ,
    \u_eth2rf_processor/u_ddr3/rd_data[80] ,
    \u_eth2rf_processor/u_ddr3/rd_data[79] ,
    \u_eth2rf_processor/u_ddr3/rd_data[78] ,
    \u_eth2rf_processor/u_ddr3/rd_data[77] ,
    \u_eth2rf_processor/u_ddr3/rd_data[76] ,
    \u_eth2rf_processor/u_ddr3/rd_data[75] ,
    \u_eth2rf_processor/u_ddr3/rd_data[74] ,
    \u_eth2rf_processor/u_ddr3/rd_data[73] ,
    \u_eth2rf_processor/u_ddr3/rd_data[72] ,
    \u_eth2rf_processor/u_ddr3/rd_data[71] ,
    \u_eth2rf_processor/u_ddr3/rd_data[70] ,
    \u_eth2rf_processor/u_ddr3/rd_data[69] ,
    \u_eth2rf_processor/u_ddr3/rd_data[68] ,
    \u_eth2rf_processor/u_ddr3/rd_data[67] ,
    \u_eth2rf_processor/u_ddr3/rd_data[66] ,
    \u_eth2rf_processor/u_ddr3/rd_data[65] ,
    \u_eth2rf_processor/u_ddr3/rd_data[64] ,
    \u_eth2rf_processor/u_ddr3/rd_data[63] ,
    \u_eth2rf_processor/u_ddr3/rd_data[62] ,
    \u_eth2rf_processor/u_ddr3/rd_data[61] ,
    \u_eth2rf_processor/u_ddr3/rd_data[60] ,
    \u_eth2rf_processor/u_ddr3/rd_data[59] ,
    \u_eth2rf_processor/u_ddr3/rd_data[58] ,
    \u_eth2rf_processor/u_ddr3/rd_data[57] ,
    \u_eth2rf_processor/u_ddr3/rd_data[56] ,
    \u_eth2rf_processor/u_ddr3/rd_data[55] ,
    \u_eth2rf_processor/u_ddr3/rd_data[54] ,
    \u_eth2rf_processor/u_ddr3/rd_data[53] ,
    \u_eth2rf_processor/u_ddr3/rd_data[52] ,
    \u_eth2rf_processor/u_ddr3/rd_data[51] ,
    \u_eth2rf_processor/u_ddr3/rd_data[50] ,
    \u_eth2rf_processor/u_ddr3/rd_data[49] ,
    \u_eth2rf_processor/u_ddr3/rd_data[48] ,
    \u_eth2rf_processor/u_ddr3/rd_data[47] ,
    \u_eth2rf_processor/u_ddr3/rd_data[46] ,
    \u_eth2rf_processor/u_ddr3/rd_data[45] ,
    \u_eth2rf_processor/u_ddr3/rd_data[44] ,
    \u_eth2rf_processor/u_ddr3/rd_data[43] ,
    \u_eth2rf_processor/u_ddr3/rd_data[42] ,
    \u_eth2rf_processor/u_ddr3/rd_data[41] ,
    \u_eth2rf_processor/u_ddr3/rd_data[40] ,
    \u_eth2rf_processor/u_ddr3/rd_data[39] ,
    \u_eth2rf_processor/u_ddr3/rd_data[38] ,
    \u_eth2rf_processor/u_ddr3/rd_data[37] ,
    \u_eth2rf_processor/u_ddr3/rd_data[36] ,
    \u_eth2rf_processor/u_ddr3/rd_data[35] ,
    \u_eth2rf_processor/u_ddr3/rd_data[34] ,
    \u_eth2rf_processor/u_ddr3/rd_data[33] ,
    \u_eth2rf_processor/u_ddr3/rd_data[32] ,
    \u_eth2rf_processor/u_ddr3/rd_data[31] ,
    \u_eth2rf_processor/u_ddr3/rd_data[30] ,
    \u_eth2rf_processor/u_ddr3/rd_data[29] ,
    \u_eth2rf_processor/u_ddr3/rd_data[28] ,
    \u_eth2rf_processor/u_ddr3/rd_data[27] ,
    \u_eth2rf_processor/u_ddr3/rd_data[26] ,
    \u_eth2rf_processor/u_ddr3/rd_data[25] ,
    \u_eth2rf_processor/u_ddr3/rd_data[24] ,
    \u_eth2rf_processor/u_ddr3/rd_data[23] ,
    \u_eth2rf_processor/u_ddr3/rd_data[22] ,
    \u_eth2rf_processor/u_ddr3/rd_data[21] ,
    \u_eth2rf_processor/u_ddr3/rd_data[20] ,
    \u_eth2rf_processor/u_ddr3/rd_data[19] ,
    \u_eth2rf_processor/u_ddr3/rd_data[18] ,
    \u_eth2rf_processor/u_ddr3/rd_data[17] ,
    \u_eth2rf_processor/u_ddr3/rd_data[16] ,
    \u_eth2rf_processor/u_ddr3/rd_data[15] ,
    \u_eth2rf_processor/u_ddr3/rd_data[14] ,
    \u_eth2rf_processor/u_ddr3/rd_data[13] ,
    \u_eth2rf_processor/u_ddr3/rd_data[12] ,
    \u_eth2rf_processor/u_ddr3/rd_data[11] ,
    \u_eth2rf_processor/u_ddr3/rd_data[10] ,
    \u_eth2rf_processor/u_ddr3/rd_data[9] ,
    \u_eth2rf_processor/u_ddr3/rd_data[8] ,
    \u_eth2rf_processor/u_ddr3/rd_data[7] ,
    \u_eth2rf_processor/u_ddr3/rd_data[6] ,
    \u_eth2rf_processor/u_ddr3/rd_data[5] ,
    \u_eth2rf_processor/u_ddr3/rd_data[4] ,
    \u_eth2rf_processor/u_ddr3/rd_data[3] ,
    \u_eth2rf_processor/u_ddr3/rd_data[2] ,
    \u_eth2rf_processor/u_ddr3/rd_data[1] ,
    \u_eth2rf_processor/u_ddr3/rd_data[0] ,
    \u_eth2rf_processor/ddr_clk ,
    tms_pad_i,
    tck_pad_i,
    tdi_pad_i,
    tdo_pad_o
);

input \adc_data_out_i1[11] ;
input \adc_data_out_i1[10] ;
input \adc_data_out_i1[9] ;
input \adc_data_out_i1[8] ;
input \adc_data_out_i1[7] ;
input \adc_data_out_i1[6] ;
input \adc_data_out_i1[5] ;
input \adc_data_out_i1[4] ;
input \adc_data_out_i1[3] ;
input \adc_data_out_i1[2] ;
input \adc_data_out_i1[1] ;
input \adc_data_out_i1[0] ;
input \adc_data_out_q1[11] ;
input \adc_data_out_q1[10] ;
input \adc_data_out_q1[9] ;
input \adc_data_out_q1[8] ;
input \adc_data_out_q1[7] ;
input \adc_data_out_q1[6] ;
input \adc_data_out_q1[5] ;
input \adc_data_out_q1[4] ;
input \adc_data_out_q1[3] ;
input \adc_data_out_q1[2] ;
input \adc_data_out_q1[1] ;
input \adc_data_out_q1[0] ;
input \dac_data_out_i1[11] ;
input \dac_data_out_i1[10] ;
input \dac_data_out_i1[9] ;
input \dac_data_out_i1[8] ;
input \dac_data_out_i1[7] ;
input \dac_data_out_i1[6] ;
input \dac_data_out_i1[5] ;
input \dac_data_out_i1[4] ;
input \dac_data_out_i1[3] ;
input \dac_data_out_i1[2] ;
input \dac_data_out_i1[1] ;
input \dac_data_out_i1[0] ;
input \dac_data_out_q1[11] ;
input \dac_data_out_q1[10] ;
input \dac_data_out_q1[9] ;
input \dac_data_out_q1[8] ;
input \dac_data_out_q1[7] ;
input \dac_data_out_q1[6] ;
input \dac_data_out_q1[5] ;
input \dac_data_out_q1[4] ;
input \dac_data_out_q1[3] ;
input \dac_data_out_q1[2] ;
input \dac_data_out_q1[1] ;
input \dac_data_out_q1[0] ;
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
input \u_rf_process/gardner_sync_flag ;
input \u_rf_process/gardner_sync_I ;
input \u_rf_process/gardner_sync_Q ;
input \u_rf_process/dqpsk_rx_data[7] ;
input \u_rf_process/dqpsk_rx_data[6] ;
input \u_rf_process/dqpsk_rx_data[5] ;
input \u_rf_process/dqpsk_rx_data[4] ;
input \u_rf_process/dqpsk_rx_data[3] ;
input \u_rf_process/dqpsk_rx_data[2] ;
input \u_rf_process/dqpsk_rx_data[1] ;
input \u_rf_process/dqpsk_rx_data[0] ;
input \u_rf_process/u_rf_dqpsk_decoder/frame_aligned_data_dbg[7] ;
input \u_rf_process/u_rf_dqpsk_decoder/frame_aligned_data_dbg[6] ;
input \u_rf_process/u_rf_dqpsk_decoder/frame_aligned_data_dbg[5] ;
input \u_rf_process/u_rf_dqpsk_decoder/frame_aligned_data_dbg[4] ;
input \u_rf_process/u_rf_dqpsk_decoder/frame_aligned_data_dbg[3] ;
input \u_rf_process/u_rf_dqpsk_decoder/frame_aligned_data_dbg[2] ;
input \u_rf_process/u_rf_dqpsk_decoder/frame_aligned_data_dbg[1] ;
input \u_rf_process/u_rf_dqpsk_decoder/frame_aligned_data_dbg[0] ;
input \u_rf_process/u_rf_dqpsk_decoder/frame_head_found_dbg ;
input \u_rf_process/u_rf_dqpsk_decoder/deframe_state_dbg[1] ;
input \u_rf_process/u_rf_dqpsk_decoder/deframe_state_dbg[0] ;
input \u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[15] ;
input \u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[14] ;
input \u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[13] ;
input \u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[12] ;
input \u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[11] ;
input \u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[10] ;
input \u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[9] ;
input \u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[8] ;
input \u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[7] ;
input \u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[6] ;
input \u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[5] ;
input \u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[4] ;
input \u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[3] ;
input \u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[2] ;
input \u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[1] ;
input \u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[0] ;
input \u_rf_process/gardner_sync_u0/uk[15] ;
input \u_rf_process/gardner_sync_u0/uk[14] ;
input \u_rf_process/gardner_sync_u0/uk[13] ;
input \u_rf_process/gardner_sync_u0/uk[12] ;
input \u_rf_process/gardner_sync_u0/uk[11] ;
input \u_rf_process/gardner_sync_u0/uk[10] ;
input \u_rf_process/gardner_sync_u0/uk[9] ;
input \u_rf_process/gardner_sync_u0/uk[8] ;
input \u_rf_process/gardner_sync_u0/uk[7] ;
input \u_rf_process/gardner_sync_u0/uk[6] ;
input \u_rf_process/gardner_sync_u0/uk[5] ;
input \u_rf_process/gardner_sync_u0/uk[4] ;
input \u_rf_process/gardner_sync_u0/uk[3] ;
input \u_rf_process/gardner_sync_u0/uk[2] ;
input \u_rf_process/gardner_sync_u0/uk[1] ;
input \u_rf_process/gardner_sync_u0/uk[0] ;
input \u_rf_process/gardner_sync_u0/I_y[19] ;
input \u_rf_process/gardner_sync_u0/I_y[18] ;
input \u_rf_process/gardner_sync_u0/I_y[17] ;
input \u_rf_process/gardner_sync_u0/I_y[16] ;
input \u_rf_process/gardner_sync_u0/I_y[15] ;
input \u_rf_process/gardner_sync_u0/I_y[14] ;
input \u_rf_process/gardner_sync_u0/I_y[13] ;
input \u_rf_process/gardner_sync_u0/I_y[12] ;
input \u_rf_process/gardner_sync_u0/I_y[11] ;
input \u_rf_process/gardner_sync_u0/I_y[10] ;
input \u_rf_process/gardner_sync_u0/I_y[9] ;
input \u_rf_process/gardner_sync_u0/I_y[8] ;
input \u_rf_process/gardner_sync_u0/I_y[7] ;
input \u_rf_process/gardner_sync_u0/I_y[6] ;
input \u_rf_process/gardner_sync_u0/I_y[5] ;
input \u_rf_process/gardner_sync_u0/I_y[4] ;
input \u_rf_process/gardner_sync_u0/I_y[3] ;
input \u_rf_process/gardner_sync_u0/I_y[2] ;
input \u_rf_process/gardner_sync_u0/I_y[1] ;
input \u_rf_process/gardner_sync_u0/I_y[0] ;
input \u_rf_process/gardner_sync_u0/Q_y[19] ;
input \u_rf_process/gardner_sync_u0/Q_y[18] ;
input \u_rf_process/gardner_sync_u0/Q_y[17] ;
input \u_rf_process/gardner_sync_u0/Q_y[16] ;
input \u_rf_process/gardner_sync_u0/Q_y[15] ;
input \u_rf_process/gardner_sync_u0/Q_y[14] ;
input \u_rf_process/gardner_sync_u0/Q_y[13] ;
input \u_rf_process/gardner_sync_u0/Q_y[12] ;
input \u_rf_process/gardner_sync_u0/Q_y[11] ;
input \u_rf_process/gardner_sync_u0/Q_y[10] ;
input \u_rf_process/gardner_sync_u0/Q_y[9] ;
input \u_rf_process/gardner_sync_u0/Q_y[8] ;
input \u_rf_process/gardner_sync_u0/Q_y[7] ;
input \u_rf_process/gardner_sync_u0/Q_y[6] ;
input \u_rf_process/gardner_sync_u0/Q_y[5] ;
input \u_rf_process/gardner_sync_u0/Q_y[4] ;
input \u_rf_process/gardner_sync_u0/Q_y[3] ;
input \u_rf_process/gardner_sync_u0/Q_y[2] ;
input \u_rf_process/gardner_sync_u0/Q_y[1] ;
input \u_rf_process/gardner_sync_u0/Q_y[0] ;
input \u_rf_process/gardner_sync_u0/nco_strobe_flag ;
input \u_rf_process/gardner_sync_u0/ted_strobe_flag ;
input ddr_init_done;
input ddr_pll_lock_dbg;
input ddr_phy_reset_dbg;
input ddr_pll_stop_dbg;
input eth_ingress_accept;
input eth_ingress_drop;
input \ddr_queued_words_dbg[15] ;
input \ddr_queued_words_dbg[14] ;
input \ddr_queued_words_dbg[13] ;
input \ddr_queued_words_dbg[12] ;
input \ddr_queued_words_dbg[11] ;
input \ddr_queued_words_dbg[10] ;
input \ddr_queued_words_dbg[9] ;
input \ddr_queued_words_dbg[8] ;
input \ddr_queued_words_dbg[7] ;
input \ddr_queued_words_dbg[6] ;
input \ddr_queued_words_dbg[5] ;
input \ddr_queued_words_dbg[4] ;
input \ddr_queued_words_dbg[3] ;
input \ddr_queued_words_dbg[2] ;
input \ddr_queued_words_dbg[1] ;
input \ddr_queued_words_dbg[0] ;
input \eth_credit_packets_dbg[15] ;
input \eth_credit_packets_dbg[14] ;
input \eth_credit_packets_dbg[13] ;
input \eth_credit_packets_dbg[12] ;
input \eth_credit_packets_dbg[11] ;
input \eth_credit_packets_dbg[10] ;
input \eth_credit_packets_dbg[9] ;
input \eth_credit_packets_dbg[8] ;
input \eth_credit_packets_dbg[7] ;
input \eth_credit_packets_dbg[6] ;
input \eth_credit_packets_dbg[5] ;
input \eth_credit_packets_dbg[4] ;
input \eth_credit_packets_dbg[3] ;
input \eth_credit_packets_dbg[2] ;
input \eth_credit_packets_dbg[1] ;
input \eth_credit_packets_dbg[0] ;
input rst_n;
input \eth_transceiver_u/rx_state[3] ;
input \eth_transceiver_u/rx_state[2] ;
input \eth_transceiver_u/rx_state[1] ;
input \eth_transceiver_u/rx_state[0] ;
input \u_rf2eth_processor/eth_tx_frame_start ;
input \u_eth2rf_processor/in_fifo_q[7] ;
input \u_eth2rf_processor/in_fifo_q[6] ;
input \u_eth2rf_processor/in_fifo_q[5] ;
input \u_eth2rf_processor/in_fifo_q[4] ;
input \u_eth2rf_processor/in_fifo_q[3] ;
input \u_eth2rf_processor/in_fifo_q[2] ;
input \u_eth2rf_processor/in_fifo_q[1] ;
input \u_eth2rf_processor/in_fifo_q[0] ;
input \u_eth2rf_processor/ddr_clk100_counter_dbg[15] ;
input \u_eth2rf_processor/ddr_clk100_counter_dbg[14] ;
input \u_eth2rf_processor/ddr_clk100_counter_dbg[13] ;
input \u_eth2rf_processor/ddr_clk100_counter_dbg[12] ;
input \u_eth2rf_processor/ddr_clk100_counter_dbg[11] ;
input \u_eth2rf_processor/ddr_clk100_counter_dbg[10] ;
input \u_eth2rf_processor/ddr_clk100_counter_dbg[9] ;
input \u_eth2rf_processor/ddr_clk100_counter_dbg[8] ;
input \u_eth2rf_processor/ddr_clk100_counter_dbg[7] ;
input \u_eth2rf_processor/ddr_clk100_counter_dbg[6] ;
input \u_eth2rf_processor/ddr_clk100_counter_dbg[5] ;
input \u_eth2rf_processor/ddr_clk100_counter_dbg[4] ;
input \u_eth2rf_processor/ddr_clk100_counter_dbg[3] ;
input \u_eth2rf_processor/ddr_clk100_counter_dbg[2] ;
input \u_eth2rf_processor/ddr_clk100_counter_dbg[1] ;
input \u_eth2rf_processor/ddr_clk100_counter_dbg[0] ;
input \u_eth2rf_processor/ddr_memclk_counter_dbg[15] ;
input \u_eth2rf_processor/ddr_memclk_counter_dbg[14] ;
input \u_eth2rf_processor/ddr_memclk_counter_dbg[13] ;
input \u_eth2rf_processor/ddr_memclk_counter_dbg[12] ;
input \u_eth2rf_processor/ddr_memclk_counter_dbg[11] ;
input \u_eth2rf_processor/ddr_memclk_counter_dbg[10] ;
input \u_eth2rf_processor/ddr_memclk_counter_dbg[9] ;
input \u_eth2rf_processor/ddr_memclk_counter_dbg[8] ;
input \u_eth2rf_processor/ddr_memclk_counter_dbg[7] ;
input \u_eth2rf_processor/ddr_memclk_counter_dbg[6] ;
input \u_eth2rf_processor/ddr_memclk_counter_dbg[5] ;
input \u_eth2rf_processor/ddr_memclk_counter_dbg[4] ;
input \u_eth2rf_processor/ddr_memclk_counter_dbg[3] ;
input \u_eth2rf_processor/ddr_memclk_counter_dbg[2] ;
input \u_eth2rf_processor/ddr_memclk_counter_dbg[1] ;
input \u_eth2rf_processor/ddr_memclk_counter_dbg[0] ;
input \u_eth2rf_processor/in_fifo_empty ;
input \u_eth2rf_processor/in_fifo_re_r ;
input \u_eth2rf_processor/in_fifo_data_valid ;
input \u_eth2rf_processor/app_cmd[2] ;
input \u_eth2rf_processor/app_cmd[1] ;
input \u_eth2rf_processor/app_cmd[0] ;
input \u_eth2rf_processor/app_wr_mask[15] ;
input \u_eth2rf_processor/app_wr_mask[14] ;
input \u_eth2rf_processor/app_wr_mask[13] ;
input \u_eth2rf_processor/app_wr_mask[12] ;
input \u_eth2rf_processor/app_wr_mask[11] ;
input \u_eth2rf_processor/app_wr_mask[10] ;
input \u_eth2rf_processor/app_wr_mask[9] ;
input \u_eth2rf_processor/app_wr_mask[8] ;
input \u_eth2rf_processor/app_wr_mask[7] ;
input \u_eth2rf_processor/app_wr_mask[6] ;
input \u_eth2rf_processor/app_wr_mask[5] ;
input \u_eth2rf_processor/app_wr_mask[4] ;
input \u_eth2rf_processor/app_wr_mask[3] ;
input \u_eth2rf_processor/app_wr_mask[2] ;
input \u_eth2rf_processor/app_wr_mask[1] ;
input \u_eth2rf_processor/app_wr_mask[0] ;
input \u_eth2rf_processor/app_cmd_en ;
input \u_eth2rf_processor/cmd_ready ;
input \u_eth2rf_processor/app_wr_en ;
input \u_eth2rf_processor/wr_data_rdy ;
input \u_eth2rf_processor/write_pending ;
input \u_eth2rf_processor/write_is_last ;
input \u_eth2rf_processor/read_active ;
input \u_eth2rf_processor/read_wait ;
input \u_eth2rf_processor/rd_data_valid ;
input \u_eth2rf_processor/out_fifo_we ;
input \u_eth2rf_processor/pending_word[127] ;
input \u_eth2rf_processor/pending_word[126] ;
input \u_eth2rf_processor/pending_word[125] ;
input \u_eth2rf_processor/pending_word[124] ;
input \u_eth2rf_processor/pending_word[123] ;
input \u_eth2rf_processor/pending_word[122] ;
input \u_eth2rf_processor/pending_word[121] ;
input \u_eth2rf_processor/pending_word[120] ;
input \u_eth2rf_processor/pending_word[119] ;
input \u_eth2rf_processor/pending_word[118] ;
input \u_eth2rf_processor/pending_word[117] ;
input \u_eth2rf_processor/pending_word[116] ;
input \u_eth2rf_processor/pending_word[115] ;
input \u_eth2rf_processor/pending_word[114] ;
input \u_eth2rf_processor/pending_word[113] ;
input \u_eth2rf_processor/pending_word[112] ;
input \u_eth2rf_processor/pending_word[111] ;
input \u_eth2rf_processor/pending_word[110] ;
input \u_eth2rf_processor/pending_word[109] ;
input \u_eth2rf_processor/pending_word[108] ;
input \u_eth2rf_processor/pending_word[107] ;
input \u_eth2rf_processor/pending_word[106] ;
input \u_eth2rf_processor/pending_word[105] ;
input \u_eth2rf_processor/pending_word[104] ;
input \u_eth2rf_processor/pending_word[103] ;
input \u_eth2rf_processor/pending_word[102] ;
input \u_eth2rf_processor/pending_word[101] ;
input \u_eth2rf_processor/pending_word[100] ;
input \u_eth2rf_processor/pending_word[99] ;
input \u_eth2rf_processor/pending_word[98] ;
input \u_eth2rf_processor/pending_word[97] ;
input \u_eth2rf_processor/pending_word[96] ;
input \u_eth2rf_processor/pending_word[95] ;
input \u_eth2rf_processor/pending_word[94] ;
input \u_eth2rf_processor/pending_word[93] ;
input \u_eth2rf_processor/pending_word[92] ;
input \u_eth2rf_processor/pending_word[91] ;
input \u_eth2rf_processor/pending_word[90] ;
input \u_eth2rf_processor/pending_word[89] ;
input \u_eth2rf_processor/pending_word[88] ;
input \u_eth2rf_processor/pending_word[87] ;
input \u_eth2rf_processor/pending_word[86] ;
input \u_eth2rf_processor/pending_word[85] ;
input \u_eth2rf_processor/pending_word[84] ;
input \u_eth2rf_processor/pending_word[83] ;
input \u_eth2rf_processor/pending_word[82] ;
input \u_eth2rf_processor/pending_word[81] ;
input \u_eth2rf_processor/pending_word[80] ;
input \u_eth2rf_processor/pending_word[79] ;
input \u_eth2rf_processor/pending_word[78] ;
input \u_eth2rf_processor/pending_word[77] ;
input \u_eth2rf_processor/pending_word[76] ;
input \u_eth2rf_processor/pending_word[75] ;
input \u_eth2rf_processor/pending_word[74] ;
input \u_eth2rf_processor/pending_word[73] ;
input \u_eth2rf_processor/pending_word[72] ;
input \u_eth2rf_processor/pending_word[71] ;
input \u_eth2rf_processor/pending_word[70] ;
input \u_eth2rf_processor/pending_word[69] ;
input \u_eth2rf_processor/pending_word[68] ;
input \u_eth2rf_processor/pending_word[67] ;
input \u_eth2rf_processor/pending_word[66] ;
input \u_eth2rf_processor/pending_word[65] ;
input \u_eth2rf_processor/pending_word[64] ;
input \u_eth2rf_processor/pending_word[63] ;
input \u_eth2rf_processor/pending_word[62] ;
input \u_eth2rf_processor/pending_word[61] ;
input \u_eth2rf_processor/pending_word[60] ;
input \u_eth2rf_processor/pending_word[59] ;
input \u_eth2rf_processor/pending_word[58] ;
input \u_eth2rf_processor/pending_word[57] ;
input \u_eth2rf_processor/pending_word[56] ;
input \u_eth2rf_processor/pending_word[55] ;
input \u_eth2rf_processor/pending_word[54] ;
input \u_eth2rf_processor/pending_word[53] ;
input \u_eth2rf_processor/pending_word[52] ;
input \u_eth2rf_processor/pending_word[51] ;
input \u_eth2rf_processor/pending_word[50] ;
input \u_eth2rf_processor/pending_word[49] ;
input \u_eth2rf_processor/pending_word[48] ;
input \u_eth2rf_processor/pending_word[47] ;
input \u_eth2rf_processor/pending_word[46] ;
input \u_eth2rf_processor/pending_word[45] ;
input \u_eth2rf_processor/pending_word[44] ;
input \u_eth2rf_processor/pending_word[43] ;
input \u_eth2rf_processor/pending_word[42] ;
input \u_eth2rf_processor/pending_word[41] ;
input \u_eth2rf_processor/pending_word[40] ;
input \u_eth2rf_processor/pending_word[39] ;
input \u_eth2rf_processor/pending_word[38] ;
input \u_eth2rf_processor/pending_word[37] ;
input \u_eth2rf_processor/pending_word[36] ;
input \u_eth2rf_processor/pending_word[35] ;
input \u_eth2rf_processor/pending_word[34] ;
input \u_eth2rf_processor/pending_word[33] ;
input \u_eth2rf_processor/pending_word[32] ;
input \u_eth2rf_processor/pending_word[31] ;
input \u_eth2rf_processor/pending_word[30] ;
input \u_eth2rf_processor/pending_word[29] ;
input \u_eth2rf_processor/pending_word[28] ;
input \u_eth2rf_processor/pending_word[27] ;
input \u_eth2rf_processor/pending_word[26] ;
input \u_eth2rf_processor/pending_word[25] ;
input \u_eth2rf_processor/pending_word[24] ;
input \u_eth2rf_processor/pending_word[23] ;
input \u_eth2rf_processor/pending_word[22] ;
input \u_eth2rf_processor/pending_word[21] ;
input \u_eth2rf_processor/pending_word[20] ;
input \u_eth2rf_processor/pending_word[19] ;
input \u_eth2rf_processor/pending_word[18] ;
input \u_eth2rf_processor/pending_word[17] ;
input \u_eth2rf_processor/pending_word[16] ;
input \u_eth2rf_processor/pending_word[15] ;
input \u_eth2rf_processor/pending_word[14] ;
input \u_eth2rf_processor/pending_word[13] ;
input \u_eth2rf_processor/pending_word[12] ;
input \u_eth2rf_processor/pending_word[11] ;
input \u_eth2rf_processor/pending_word[10] ;
input \u_eth2rf_processor/pending_word[9] ;
input \u_eth2rf_processor/pending_word[8] ;
input \u_eth2rf_processor/pending_word[7] ;
input \u_eth2rf_processor/pending_word[6] ;
input \u_eth2rf_processor/pending_word[5] ;
input \u_eth2rf_processor/pending_word[4] ;
input \u_eth2rf_processor/pending_word[3] ;
input \u_eth2rf_processor/pending_word[2] ;
input \u_eth2rf_processor/pending_word[1] ;
input \u_eth2rf_processor/pending_word[0] ;
input \u_eth2rf_processor/app_wr_data[127] ;
input \u_eth2rf_processor/app_wr_data[126] ;
input \u_eth2rf_processor/app_wr_data[125] ;
input \u_eth2rf_processor/app_wr_data[124] ;
input \u_eth2rf_processor/app_wr_data[123] ;
input \u_eth2rf_processor/app_wr_data[122] ;
input \u_eth2rf_processor/app_wr_data[121] ;
input \u_eth2rf_processor/app_wr_data[120] ;
input \u_eth2rf_processor/app_wr_data[119] ;
input \u_eth2rf_processor/app_wr_data[118] ;
input \u_eth2rf_processor/app_wr_data[117] ;
input \u_eth2rf_processor/app_wr_data[116] ;
input \u_eth2rf_processor/app_wr_data[115] ;
input \u_eth2rf_processor/app_wr_data[114] ;
input \u_eth2rf_processor/app_wr_data[113] ;
input \u_eth2rf_processor/app_wr_data[112] ;
input \u_eth2rf_processor/app_wr_data[111] ;
input \u_eth2rf_processor/app_wr_data[110] ;
input \u_eth2rf_processor/app_wr_data[109] ;
input \u_eth2rf_processor/app_wr_data[108] ;
input \u_eth2rf_processor/app_wr_data[107] ;
input \u_eth2rf_processor/app_wr_data[106] ;
input \u_eth2rf_processor/app_wr_data[105] ;
input \u_eth2rf_processor/app_wr_data[104] ;
input \u_eth2rf_processor/app_wr_data[103] ;
input \u_eth2rf_processor/app_wr_data[102] ;
input \u_eth2rf_processor/app_wr_data[101] ;
input \u_eth2rf_processor/app_wr_data[100] ;
input \u_eth2rf_processor/app_wr_data[99] ;
input \u_eth2rf_processor/app_wr_data[98] ;
input \u_eth2rf_processor/app_wr_data[97] ;
input \u_eth2rf_processor/app_wr_data[96] ;
input \u_eth2rf_processor/app_wr_data[95] ;
input \u_eth2rf_processor/app_wr_data[94] ;
input \u_eth2rf_processor/app_wr_data[93] ;
input \u_eth2rf_processor/app_wr_data[92] ;
input \u_eth2rf_processor/app_wr_data[91] ;
input \u_eth2rf_processor/app_wr_data[90] ;
input \u_eth2rf_processor/app_wr_data[89] ;
input \u_eth2rf_processor/app_wr_data[88] ;
input \u_eth2rf_processor/app_wr_data[87] ;
input \u_eth2rf_processor/app_wr_data[86] ;
input \u_eth2rf_processor/app_wr_data[85] ;
input \u_eth2rf_processor/app_wr_data[84] ;
input \u_eth2rf_processor/app_wr_data[83] ;
input \u_eth2rf_processor/app_wr_data[82] ;
input \u_eth2rf_processor/app_wr_data[81] ;
input \u_eth2rf_processor/app_wr_data[80] ;
input \u_eth2rf_processor/app_wr_data[79] ;
input \u_eth2rf_processor/app_wr_data[78] ;
input \u_eth2rf_processor/app_wr_data[77] ;
input \u_eth2rf_processor/app_wr_data[76] ;
input \u_eth2rf_processor/app_wr_data[75] ;
input \u_eth2rf_processor/app_wr_data[74] ;
input \u_eth2rf_processor/app_wr_data[73] ;
input \u_eth2rf_processor/app_wr_data[72] ;
input \u_eth2rf_processor/app_wr_data[71] ;
input \u_eth2rf_processor/app_wr_data[70] ;
input \u_eth2rf_processor/app_wr_data[69] ;
input \u_eth2rf_processor/app_wr_data[68] ;
input \u_eth2rf_processor/app_wr_data[67] ;
input \u_eth2rf_processor/app_wr_data[66] ;
input \u_eth2rf_processor/app_wr_data[65] ;
input \u_eth2rf_processor/app_wr_data[64] ;
input \u_eth2rf_processor/app_wr_data[63] ;
input \u_eth2rf_processor/app_wr_data[62] ;
input \u_eth2rf_processor/app_wr_data[61] ;
input \u_eth2rf_processor/app_wr_data[60] ;
input \u_eth2rf_processor/app_wr_data[59] ;
input \u_eth2rf_processor/app_wr_data[58] ;
input \u_eth2rf_processor/app_wr_data[57] ;
input \u_eth2rf_processor/app_wr_data[56] ;
input \u_eth2rf_processor/app_wr_data[55] ;
input \u_eth2rf_processor/app_wr_data[54] ;
input \u_eth2rf_processor/app_wr_data[53] ;
input \u_eth2rf_processor/app_wr_data[52] ;
input \u_eth2rf_processor/app_wr_data[51] ;
input \u_eth2rf_processor/app_wr_data[50] ;
input \u_eth2rf_processor/app_wr_data[49] ;
input \u_eth2rf_processor/app_wr_data[48] ;
input \u_eth2rf_processor/app_wr_data[47] ;
input \u_eth2rf_processor/app_wr_data[46] ;
input \u_eth2rf_processor/app_wr_data[45] ;
input \u_eth2rf_processor/app_wr_data[44] ;
input \u_eth2rf_processor/app_wr_data[43] ;
input \u_eth2rf_processor/app_wr_data[42] ;
input \u_eth2rf_processor/app_wr_data[41] ;
input \u_eth2rf_processor/app_wr_data[40] ;
input \u_eth2rf_processor/app_wr_data[39] ;
input \u_eth2rf_processor/app_wr_data[38] ;
input \u_eth2rf_processor/app_wr_data[37] ;
input \u_eth2rf_processor/app_wr_data[36] ;
input \u_eth2rf_processor/app_wr_data[35] ;
input \u_eth2rf_processor/app_wr_data[34] ;
input \u_eth2rf_processor/app_wr_data[33] ;
input \u_eth2rf_processor/app_wr_data[32] ;
input \u_eth2rf_processor/app_wr_data[31] ;
input \u_eth2rf_processor/app_wr_data[30] ;
input \u_eth2rf_processor/app_wr_data[29] ;
input \u_eth2rf_processor/app_wr_data[28] ;
input \u_eth2rf_processor/app_wr_data[27] ;
input \u_eth2rf_processor/app_wr_data[26] ;
input \u_eth2rf_processor/app_wr_data[25] ;
input \u_eth2rf_processor/app_wr_data[24] ;
input \u_eth2rf_processor/app_wr_data[23] ;
input \u_eth2rf_processor/app_wr_data[22] ;
input \u_eth2rf_processor/app_wr_data[21] ;
input \u_eth2rf_processor/app_wr_data[20] ;
input \u_eth2rf_processor/app_wr_data[19] ;
input \u_eth2rf_processor/app_wr_data[18] ;
input \u_eth2rf_processor/app_wr_data[17] ;
input \u_eth2rf_processor/app_wr_data[16] ;
input \u_eth2rf_processor/app_wr_data[15] ;
input \u_eth2rf_processor/app_wr_data[14] ;
input \u_eth2rf_processor/app_wr_data[13] ;
input \u_eth2rf_processor/app_wr_data[12] ;
input \u_eth2rf_processor/app_wr_data[11] ;
input \u_eth2rf_processor/app_wr_data[10] ;
input \u_eth2rf_processor/app_wr_data[9] ;
input \u_eth2rf_processor/app_wr_data[8] ;
input \u_eth2rf_processor/app_wr_data[7] ;
input \u_eth2rf_processor/app_wr_data[6] ;
input \u_eth2rf_processor/app_wr_data[5] ;
input \u_eth2rf_processor/app_wr_data[4] ;
input \u_eth2rf_processor/app_wr_data[3] ;
input \u_eth2rf_processor/app_wr_data[2] ;
input \u_eth2rf_processor/app_wr_data[1] ;
input \u_eth2rf_processor/app_wr_data[0] ;
input \u_eth2rf_processor/u_ddr3/rd_data[127] ;
input \u_eth2rf_processor/u_ddr3/rd_data[126] ;
input \u_eth2rf_processor/u_ddr3/rd_data[125] ;
input \u_eth2rf_processor/u_ddr3/rd_data[124] ;
input \u_eth2rf_processor/u_ddr3/rd_data[123] ;
input \u_eth2rf_processor/u_ddr3/rd_data[122] ;
input \u_eth2rf_processor/u_ddr3/rd_data[121] ;
input \u_eth2rf_processor/u_ddr3/rd_data[120] ;
input \u_eth2rf_processor/u_ddr3/rd_data[119] ;
input \u_eth2rf_processor/u_ddr3/rd_data[118] ;
input \u_eth2rf_processor/u_ddr3/rd_data[117] ;
input \u_eth2rf_processor/u_ddr3/rd_data[116] ;
input \u_eth2rf_processor/u_ddr3/rd_data[115] ;
input \u_eth2rf_processor/u_ddr3/rd_data[114] ;
input \u_eth2rf_processor/u_ddr3/rd_data[113] ;
input \u_eth2rf_processor/u_ddr3/rd_data[112] ;
input \u_eth2rf_processor/u_ddr3/rd_data[111] ;
input \u_eth2rf_processor/u_ddr3/rd_data[110] ;
input \u_eth2rf_processor/u_ddr3/rd_data[109] ;
input \u_eth2rf_processor/u_ddr3/rd_data[108] ;
input \u_eth2rf_processor/u_ddr3/rd_data[107] ;
input \u_eth2rf_processor/u_ddr3/rd_data[106] ;
input \u_eth2rf_processor/u_ddr3/rd_data[105] ;
input \u_eth2rf_processor/u_ddr3/rd_data[104] ;
input \u_eth2rf_processor/u_ddr3/rd_data[103] ;
input \u_eth2rf_processor/u_ddr3/rd_data[102] ;
input \u_eth2rf_processor/u_ddr3/rd_data[101] ;
input \u_eth2rf_processor/u_ddr3/rd_data[100] ;
input \u_eth2rf_processor/u_ddr3/rd_data[99] ;
input \u_eth2rf_processor/u_ddr3/rd_data[98] ;
input \u_eth2rf_processor/u_ddr3/rd_data[97] ;
input \u_eth2rf_processor/u_ddr3/rd_data[96] ;
input \u_eth2rf_processor/u_ddr3/rd_data[95] ;
input \u_eth2rf_processor/u_ddr3/rd_data[94] ;
input \u_eth2rf_processor/u_ddr3/rd_data[93] ;
input \u_eth2rf_processor/u_ddr3/rd_data[92] ;
input \u_eth2rf_processor/u_ddr3/rd_data[91] ;
input \u_eth2rf_processor/u_ddr3/rd_data[90] ;
input \u_eth2rf_processor/u_ddr3/rd_data[89] ;
input \u_eth2rf_processor/u_ddr3/rd_data[88] ;
input \u_eth2rf_processor/u_ddr3/rd_data[87] ;
input \u_eth2rf_processor/u_ddr3/rd_data[86] ;
input \u_eth2rf_processor/u_ddr3/rd_data[85] ;
input \u_eth2rf_processor/u_ddr3/rd_data[84] ;
input \u_eth2rf_processor/u_ddr3/rd_data[83] ;
input \u_eth2rf_processor/u_ddr3/rd_data[82] ;
input \u_eth2rf_processor/u_ddr3/rd_data[81] ;
input \u_eth2rf_processor/u_ddr3/rd_data[80] ;
input \u_eth2rf_processor/u_ddr3/rd_data[79] ;
input \u_eth2rf_processor/u_ddr3/rd_data[78] ;
input \u_eth2rf_processor/u_ddr3/rd_data[77] ;
input \u_eth2rf_processor/u_ddr3/rd_data[76] ;
input \u_eth2rf_processor/u_ddr3/rd_data[75] ;
input \u_eth2rf_processor/u_ddr3/rd_data[74] ;
input \u_eth2rf_processor/u_ddr3/rd_data[73] ;
input \u_eth2rf_processor/u_ddr3/rd_data[72] ;
input \u_eth2rf_processor/u_ddr3/rd_data[71] ;
input \u_eth2rf_processor/u_ddr3/rd_data[70] ;
input \u_eth2rf_processor/u_ddr3/rd_data[69] ;
input \u_eth2rf_processor/u_ddr3/rd_data[68] ;
input \u_eth2rf_processor/u_ddr3/rd_data[67] ;
input \u_eth2rf_processor/u_ddr3/rd_data[66] ;
input \u_eth2rf_processor/u_ddr3/rd_data[65] ;
input \u_eth2rf_processor/u_ddr3/rd_data[64] ;
input \u_eth2rf_processor/u_ddr3/rd_data[63] ;
input \u_eth2rf_processor/u_ddr3/rd_data[62] ;
input \u_eth2rf_processor/u_ddr3/rd_data[61] ;
input \u_eth2rf_processor/u_ddr3/rd_data[60] ;
input \u_eth2rf_processor/u_ddr3/rd_data[59] ;
input \u_eth2rf_processor/u_ddr3/rd_data[58] ;
input \u_eth2rf_processor/u_ddr3/rd_data[57] ;
input \u_eth2rf_processor/u_ddr3/rd_data[56] ;
input \u_eth2rf_processor/u_ddr3/rd_data[55] ;
input \u_eth2rf_processor/u_ddr3/rd_data[54] ;
input \u_eth2rf_processor/u_ddr3/rd_data[53] ;
input \u_eth2rf_processor/u_ddr3/rd_data[52] ;
input \u_eth2rf_processor/u_ddr3/rd_data[51] ;
input \u_eth2rf_processor/u_ddr3/rd_data[50] ;
input \u_eth2rf_processor/u_ddr3/rd_data[49] ;
input \u_eth2rf_processor/u_ddr3/rd_data[48] ;
input \u_eth2rf_processor/u_ddr3/rd_data[47] ;
input \u_eth2rf_processor/u_ddr3/rd_data[46] ;
input \u_eth2rf_processor/u_ddr3/rd_data[45] ;
input \u_eth2rf_processor/u_ddr3/rd_data[44] ;
input \u_eth2rf_processor/u_ddr3/rd_data[43] ;
input \u_eth2rf_processor/u_ddr3/rd_data[42] ;
input \u_eth2rf_processor/u_ddr3/rd_data[41] ;
input \u_eth2rf_processor/u_ddr3/rd_data[40] ;
input \u_eth2rf_processor/u_ddr3/rd_data[39] ;
input \u_eth2rf_processor/u_ddr3/rd_data[38] ;
input \u_eth2rf_processor/u_ddr3/rd_data[37] ;
input \u_eth2rf_processor/u_ddr3/rd_data[36] ;
input \u_eth2rf_processor/u_ddr3/rd_data[35] ;
input \u_eth2rf_processor/u_ddr3/rd_data[34] ;
input \u_eth2rf_processor/u_ddr3/rd_data[33] ;
input \u_eth2rf_processor/u_ddr3/rd_data[32] ;
input \u_eth2rf_processor/u_ddr3/rd_data[31] ;
input \u_eth2rf_processor/u_ddr3/rd_data[30] ;
input \u_eth2rf_processor/u_ddr3/rd_data[29] ;
input \u_eth2rf_processor/u_ddr3/rd_data[28] ;
input \u_eth2rf_processor/u_ddr3/rd_data[27] ;
input \u_eth2rf_processor/u_ddr3/rd_data[26] ;
input \u_eth2rf_processor/u_ddr3/rd_data[25] ;
input \u_eth2rf_processor/u_ddr3/rd_data[24] ;
input \u_eth2rf_processor/u_ddr3/rd_data[23] ;
input \u_eth2rf_processor/u_ddr3/rd_data[22] ;
input \u_eth2rf_processor/u_ddr3/rd_data[21] ;
input \u_eth2rf_processor/u_ddr3/rd_data[20] ;
input \u_eth2rf_processor/u_ddr3/rd_data[19] ;
input \u_eth2rf_processor/u_ddr3/rd_data[18] ;
input \u_eth2rf_processor/u_ddr3/rd_data[17] ;
input \u_eth2rf_processor/u_ddr3/rd_data[16] ;
input \u_eth2rf_processor/u_ddr3/rd_data[15] ;
input \u_eth2rf_processor/u_ddr3/rd_data[14] ;
input \u_eth2rf_processor/u_ddr3/rd_data[13] ;
input \u_eth2rf_processor/u_ddr3/rd_data[12] ;
input \u_eth2rf_processor/u_ddr3/rd_data[11] ;
input \u_eth2rf_processor/u_ddr3/rd_data[10] ;
input \u_eth2rf_processor/u_ddr3/rd_data[9] ;
input \u_eth2rf_processor/u_ddr3/rd_data[8] ;
input \u_eth2rf_processor/u_ddr3/rd_data[7] ;
input \u_eth2rf_processor/u_ddr3/rd_data[6] ;
input \u_eth2rf_processor/u_ddr3/rd_data[5] ;
input \u_eth2rf_processor/u_ddr3/rd_data[4] ;
input \u_eth2rf_processor/u_ddr3/rd_data[3] ;
input \u_eth2rf_processor/u_ddr3/rd_data[2] ;
input \u_eth2rf_processor/u_ddr3/rd_data[1] ;
input \u_eth2rf_processor/u_ddr3/rd_data[0] ;
input \u_eth2rf_processor/ddr_clk ;
input tms_pad_i;
input tck_pad_i;
input tdi_pad_i;
output tdo_pad_o;

wire \adc_data_out_i1[11] ;
wire \adc_data_out_i1[10] ;
wire \adc_data_out_i1[9] ;
wire \adc_data_out_i1[8] ;
wire \adc_data_out_i1[7] ;
wire \adc_data_out_i1[6] ;
wire \adc_data_out_i1[5] ;
wire \adc_data_out_i1[4] ;
wire \adc_data_out_i1[3] ;
wire \adc_data_out_i1[2] ;
wire \adc_data_out_i1[1] ;
wire \adc_data_out_i1[0] ;
wire \adc_data_out_q1[11] ;
wire \adc_data_out_q1[10] ;
wire \adc_data_out_q1[9] ;
wire \adc_data_out_q1[8] ;
wire \adc_data_out_q1[7] ;
wire \adc_data_out_q1[6] ;
wire \adc_data_out_q1[5] ;
wire \adc_data_out_q1[4] ;
wire \adc_data_out_q1[3] ;
wire \adc_data_out_q1[2] ;
wire \adc_data_out_q1[1] ;
wire \adc_data_out_q1[0] ;
wire \dac_data_out_i1[11] ;
wire \dac_data_out_i1[10] ;
wire \dac_data_out_i1[9] ;
wire \dac_data_out_i1[8] ;
wire \dac_data_out_i1[7] ;
wire \dac_data_out_i1[6] ;
wire \dac_data_out_i1[5] ;
wire \dac_data_out_i1[4] ;
wire \dac_data_out_i1[3] ;
wire \dac_data_out_i1[2] ;
wire \dac_data_out_i1[1] ;
wire \dac_data_out_i1[0] ;
wire \dac_data_out_q1[11] ;
wire \dac_data_out_q1[10] ;
wire \dac_data_out_q1[9] ;
wire \dac_data_out_q1[8] ;
wire \dac_data_out_q1[7] ;
wire \dac_data_out_q1[6] ;
wire \dac_data_out_q1[5] ;
wire \dac_data_out_q1[4] ;
wire \dac_data_out_q1[3] ;
wire \dac_data_out_q1[2] ;
wire \dac_data_out_q1[1] ;
wire \dac_data_out_q1[0] ;
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
wire \u_rf_process/gardner_sync_flag ;
wire \u_rf_process/gardner_sync_I ;
wire \u_rf_process/gardner_sync_Q ;
wire \u_rf_process/dqpsk_rx_data[7] ;
wire \u_rf_process/dqpsk_rx_data[6] ;
wire \u_rf_process/dqpsk_rx_data[5] ;
wire \u_rf_process/dqpsk_rx_data[4] ;
wire \u_rf_process/dqpsk_rx_data[3] ;
wire \u_rf_process/dqpsk_rx_data[2] ;
wire \u_rf_process/dqpsk_rx_data[1] ;
wire \u_rf_process/dqpsk_rx_data[0] ;
wire \u_rf_process/u_rf_dqpsk_decoder/frame_aligned_data_dbg[7] ;
wire \u_rf_process/u_rf_dqpsk_decoder/frame_aligned_data_dbg[6] ;
wire \u_rf_process/u_rf_dqpsk_decoder/frame_aligned_data_dbg[5] ;
wire \u_rf_process/u_rf_dqpsk_decoder/frame_aligned_data_dbg[4] ;
wire \u_rf_process/u_rf_dqpsk_decoder/frame_aligned_data_dbg[3] ;
wire \u_rf_process/u_rf_dqpsk_decoder/frame_aligned_data_dbg[2] ;
wire \u_rf_process/u_rf_dqpsk_decoder/frame_aligned_data_dbg[1] ;
wire \u_rf_process/u_rf_dqpsk_decoder/frame_aligned_data_dbg[0] ;
wire \u_rf_process/u_rf_dqpsk_decoder/frame_head_found_dbg ;
wire \u_rf_process/u_rf_dqpsk_decoder/deframe_state_dbg[1] ;
wire \u_rf_process/u_rf_dqpsk_decoder/deframe_state_dbg[0] ;
wire \u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[15] ;
wire \u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[14] ;
wire \u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[13] ;
wire \u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[12] ;
wire \u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[11] ;
wire \u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[10] ;
wire \u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[9] ;
wire \u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[8] ;
wire \u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[7] ;
wire \u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[6] ;
wire \u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[5] ;
wire \u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[4] ;
wire \u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[3] ;
wire \u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[2] ;
wire \u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[1] ;
wire \u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[0] ;
wire \u_rf_process/gardner_sync_u0/uk[15] ;
wire \u_rf_process/gardner_sync_u0/uk[14] ;
wire \u_rf_process/gardner_sync_u0/uk[13] ;
wire \u_rf_process/gardner_sync_u0/uk[12] ;
wire \u_rf_process/gardner_sync_u0/uk[11] ;
wire \u_rf_process/gardner_sync_u0/uk[10] ;
wire \u_rf_process/gardner_sync_u0/uk[9] ;
wire \u_rf_process/gardner_sync_u0/uk[8] ;
wire \u_rf_process/gardner_sync_u0/uk[7] ;
wire \u_rf_process/gardner_sync_u0/uk[6] ;
wire \u_rf_process/gardner_sync_u0/uk[5] ;
wire \u_rf_process/gardner_sync_u0/uk[4] ;
wire \u_rf_process/gardner_sync_u0/uk[3] ;
wire \u_rf_process/gardner_sync_u0/uk[2] ;
wire \u_rf_process/gardner_sync_u0/uk[1] ;
wire \u_rf_process/gardner_sync_u0/uk[0] ;
wire \u_rf_process/gardner_sync_u0/I_y[19] ;
wire \u_rf_process/gardner_sync_u0/I_y[18] ;
wire \u_rf_process/gardner_sync_u0/I_y[17] ;
wire \u_rf_process/gardner_sync_u0/I_y[16] ;
wire \u_rf_process/gardner_sync_u0/I_y[15] ;
wire \u_rf_process/gardner_sync_u0/I_y[14] ;
wire \u_rf_process/gardner_sync_u0/I_y[13] ;
wire \u_rf_process/gardner_sync_u0/I_y[12] ;
wire \u_rf_process/gardner_sync_u0/I_y[11] ;
wire \u_rf_process/gardner_sync_u0/I_y[10] ;
wire \u_rf_process/gardner_sync_u0/I_y[9] ;
wire \u_rf_process/gardner_sync_u0/I_y[8] ;
wire \u_rf_process/gardner_sync_u0/I_y[7] ;
wire \u_rf_process/gardner_sync_u0/I_y[6] ;
wire \u_rf_process/gardner_sync_u0/I_y[5] ;
wire \u_rf_process/gardner_sync_u0/I_y[4] ;
wire \u_rf_process/gardner_sync_u0/I_y[3] ;
wire \u_rf_process/gardner_sync_u0/I_y[2] ;
wire \u_rf_process/gardner_sync_u0/I_y[1] ;
wire \u_rf_process/gardner_sync_u0/I_y[0] ;
wire \u_rf_process/gardner_sync_u0/Q_y[19] ;
wire \u_rf_process/gardner_sync_u0/Q_y[18] ;
wire \u_rf_process/gardner_sync_u0/Q_y[17] ;
wire \u_rf_process/gardner_sync_u0/Q_y[16] ;
wire \u_rf_process/gardner_sync_u0/Q_y[15] ;
wire \u_rf_process/gardner_sync_u0/Q_y[14] ;
wire \u_rf_process/gardner_sync_u0/Q_y[13] ;
wire \u_rf_process/gardner_sync_u0/Q_y[12] ;
wire \u_rf_process/gardner_sync_u0/Q_y[11] ;
wire \u_rf_process/gardner_sync_u0/Q_y[10] ;
wire \u_rf_process/gardner_sync_u0/Q_y[9] ;
wire \u_rf_process/gardner_sync_u0/Q_y[8] ;
wire \u_rf_process/gardner_sync_u0/Q_y[7] ;
wire \u_rf_process/gardner_sync_u0/Q_y[6] ;
wire \u_rf_process/gardner_sync_u0/Q_y[5] ;
wire \u_rf_process/gardner_sync_u0/Q_y[4] ;
wire \u_rf_process/gardner_sync_u0/Q_y[3] ;
wire \u_rf_process/gardner_sync_u0/Q_y[2] ;
wire \u_rf_process/gardner_sync_u0/Q_y[1] ;
wire \u_rf_process/gardner_sync_u0/Q_y[0] ;
wire \u_rf_process/gardner_sync_u0/nco_strobe_flag ;
wire \u_rf_process/gardner_sync_u0/ted_strobe_flag ;
wire ddr_init_done;
wire ddr_pll_lock_dbg;
wire ddr_phy_reset_dbg;
wire ddr_pll_stop_dbg;
wire eth_ingress_accept;
wire eth_ingress_drop;
wire \ddr_queued_words_dbg[15] ;
wire \ddr_queued_words_dbg[14] ;
wire \ddr_queued_words_dbg[13] ;
wire \ddr_queued_words_dbg[12] ;
wire \ddr_queued_words_dbg[11] ;
wire \ddr_queued_words_dbg[10] ;
wire \ddr_queued_words_dbg[9] ;
wire \ddr_queued_words_dbg[8] ;
wire \ddr_queued_words_dbg[7] ;
wire \ddr_queued_words_dbg[6] ;
wire \ddr_queued_words_dbg[5] ;
wire \ddr_queued_words_dbg[4] ;
wire \ddr_queued_words_dbg[3] ;
wire \ddr_queued_words_dbg[2] ;
wire \ddr_queued_words_dbg[1] ;
wire \ddr_queued_words_dbg[0] ;
wire \eth_credit_packets_dbg[15] ;
wire \eth_credit_packets_dbg[14] ;
wire \eth_credit_packets_dbg[13] ;
wire \eth_credit_packets_dbg[12] ;
wire \eth_credit_packets_dbg[11] ;
wire \eth_credit_packets_dbg[10] ;
wire \eth_credit_packets_dbg[9] ;
wire \eth_credit_packets_dbg[8] ;
wire \eth_credit_packets_dbg[7] ;
wire \eth_credit_packets_dbg[6] ;
wire \eth_credit_packets_dbg[5] ;
wire \eth_credit_packets_dbg[4] ;
wire \eth_credit_packets_dbg[3] ;
wire \eth_credit_packets_dbg[2] ;
wire \eth_credit_packets_dbg[1] ;
wire \eth_credit_packets_dbg[0] ;
wire rst_n;
wire \eth_transceiver_u/rx_state[3] ;
wire \eth_transceiver_u/rx_state[2] ;
wire \eth_transceiver_u/rx_state[1] ;
wire \eth_transceiver_u/rx_state[0] ;
wire \u_rf2eth_processor/eth_tx_frame_start ;
wire \u_eth2rf_processor/in_fifo_q[7] ;
wire \u_eth2rf_processor/in_fifo_q[6] ;
wire \u_eth2rf_processor/in_fifo_q[5] ;
wire \u_eth2rf_processor/in_fifo_q[4] ;
wire \u_eth2rf_processor/in_fifo_q[3] ;
wire \u_eth2rf_processor/in_fifo_q[2] ;
wire \u_eth2rf_processor/in_fifo_q[1] ;
wire \u_eth2rf_processor/in_fifo_q[0] ;
wire \u_eth2rf_processor/ddr_clk100_counter_dbg[15] ;
wire \u_eth2rf_processor/ddr_clk100_counter_dbg[14] ;
wire \u_eth2rf_processor/ddr_clk100_counter_dbg[13] ;
wire \u_eth2rf_processor/ddr_clk100_counter_dbg[12] ;
wire \u_eth2rf_processor/ddr_clk100_counter_dbg[11] ;
wire \u_eth2rf_processor/ddr_clk100_counter_dbg[10] ;
wire \u_eth2rf_processor/ddr_clk100_counter_dbg[9] ;
wire \u_eth2rf_processor/ddr_clk100_counter_dbg[8] ;
wire \u_eth2rf_processor/ddr_clk100_counter_dbg[7] ;
wire \u_eth2rf_processor/ddr_clk100_counter_dbg[6] ;
wire \u_eth2rf_processor/ddr_clk100_counter_dbg[5] ;
wire \u_eth2rf_processor/ddr_clk100_counter_dbg[4] ;
wire \u_eth2rf_processor/ddr_clk100_counter_dbg[3] ;
wire \u_eth2rf_processor/ddr_clk100_counter_dbg[2] ;
wire \u_eth2rf_processor/ddr_clk100_counter_dbg[1] ;
wire \u_eth2rf_processor/ddr_clk100_counter_dbg[0] ;
wire \u_eth2rf_processor/ddr_memclk_counter_dbg[15] ;
wire \u_eth2rf_processor/ddr_memclk_counter_dbg[14] ;
wire \u_eth2rf_processor/ddr_memclk_counter_dbg[13] ;
wire \u_eth2rf_processor/ddr_memclk_counter_dbg[12] ;
wire \u_eth2rf_processor/ddr_memclk_counter_dbg[11] ;
wire \u_eth2rf_processor/ddr_memclk_counter_dbg[10] ;
wire \u_eth2rf_processor/ddr_memclk_counter_dbg[9] ;
wire \u_eth2rf_processor/ddr_memclk_counter_dbg[8] ;
wire \u_eth2rf_processor/ddr_memclk_counter_dbg[7] ;
wire \u_eth2rf_processor/ddr_memclk_counter_dbg[6] ;
wire \u_eth2rf_processor/ddr_memclk_counter_dbg[5] ;
wire \u_eth2rf_processor/ddr_memclk_counter_dbg[4] ;
wire \u_eth2rf_processor/ddr_memclk_counter_dbg[3] ;
wire \u_eth2rf_processor/ddr_memclk_counter_dbg[2] ;
wire \u_eth2rf_processor/ddr_memclk_counter_dbg[1] ;
wire \u_eth2rf_processor/ddr_memclk_counter_dbg[0] ;
wire \u_eth2rf_processor/in_fifo_empty ;
wire \u_eth2rf_processor/in_fifo_re_r ;
wire \u_eth2rf_processor/in_fifo_data_valid ;
wire \u_eth2rf_processor/app_cmd[2] ;
wire \u_eth2rf_processor/app_cmd[1] ;
wire \u_eth2rf_processor/app_cmd[0] ;
wire \u_eth2rf_processor/app_wr_mask[15] ;
wire \u_eth2rf_processor/app_wr_mask[14] ;
wire \u_eth2rf_processor/app_wr_mask[13] ;
wire \u_eth2rf_processor/app_wr_mask[12] ;
wire \u_eth2rf_processor/app_wr_mask[11] ;
wire \u_eth2rf_processor/app_wr_mask[10] ;
wire \u_eth2rf_processor/app_wr_mask[9] ;
wire \u_eth2rf_processor/app_wr_mask[8] ;
wire \u_eth2rf_processor/app_wr_mask[7] ;
wire \u_eth2rf_processor/app_wr_mask[6] ;
wire \u_eth2rf_processor/app_wr_mask[5] ;
wire \u_eth2rf_processor/app_wr_mask[4] ;
wire \u_eth2rf_processor/app_wr_mask[3] ;
wire \u_eth2rf_processor/app_wr_mask[2] ;
wire \u_eth2rf_processor/app_wr_mask[1] ;
wire \u_eth2rf_processor/app_wr_mask[0] ;
wire \u_eth2rf_processor/app_cmd_en ;
wire \u_eth2rf_processor/cmd_ready ;
wire \u_eth2rf_processor/app_wr_en ;
wire \u_eth2rf_processor/wr_data_rdy ;
wire \u_eth2rf_processor/write_pending ;
wire \u_eth2rf_processor/write_is_last ;
wire \u_eth2rf_processor/read_active ;
wire \u_eth2rf_processor/read_wait ;
wire \u_eth2rf_processor/rd_data_valid ;
wire \u_eth2rf_processor/out_fifo_we ;
wire \u_eth2rf_processor/pending_word[127] ;
wire \u_eth2rf_processor/pending_word[126] ;
wire \u_eth2rf_processor/pending_word[125] ;
wire \u_eth2rf_processor/pending_word[124] ;
wire \u_eth2rf_processor/pending_word[123] ;
wire \u_eth2rf_processor/pending_word[122] ;
wire \u_eth2rf_processor/pending_word[121] ;
wire \u_eth2rf_processor/pending_word[120] ;
wire \u_eth2rf_processor/pending_word[119] ;
wire \u_eth2rf_processor/pending_word[118] ;
wire \u_eth2rf_processor/pending_word[117] ;
wire \u_eth2rf_processor/pending_word[116] ;
wire \u_eth2rf_processor/pending_word[115] ;
wire \u_eth2rf_processor/pending_word[114] ;
wire \u_eth2rf_processor/pending_word[113] ;
wire \u_eth2rf_processor/pending_word[112] ;
wire \u_eth2rf_processor/pending_word[111] ;
wire \u_eth2rf_processor/pending_word[110] ;
wire \u_eth2rf_processor/pending_word[109] ;
wire \u_eth2rf_processor/pending_word[108] ;
wire \u_eth2rf_processor/pending_word[107] ;
wire \u_eth2rf_processor/pending_word[106] ;
wire \u_eth2rf_processor/pending_word[105] ;
wire \u_eth2rf_processor/pending_word[104] ;
wire \u_eth2rf_processor/pending_word[103] ;
wire \u_eth2rf_processor/pending_word[102] ;
wire \u_eth2rf_processor/pending_word[101] ;
wire \u_eth2rf_processor/pending_word[100] ;
wire \u_eth2rf_processor/pending_word[99] ;
wire \u_eth2rf_processor/pending_word[98] ;
wire \u_eth2rf_processor/pending_word[97] ;
wire \u_eth2rf_processor/pending_word[96] ;
wire \u_eth2rf_processor/pending_word[95] ;
wire \u_eth2rf_processor/pending_word[94] ;
wire \u_eth2rf_processor/pending_word[93] ;
wire \u_eth2rf_processor/pending_word[92] ;
wire \u_eth2rf_processor/pending_word[91] ;
wire \u_eth2rf_processor/pending_word[90] ;
wire \u_eth2rf_processor/pending_word[89] ;
wire \u_eth2rf_processor/pending_word[88] ;
wire \u_eth2rf_processor/pending_word[87] ;
wire \u_eth2rf_processor/pending_word[86] ;
wire \u_eth2rf_processor/pending_word[85] ;
wire \u_eth2rf_processor/pending_word[84] ;
wire \u_eth2rf_processor/pending_word[83] ;
wire \u_eth2rf_processor/pending_word[82] ;
wire \u_eth2rf_processor/pending_word[81] ;
wire \u_eth2rf_processor/pending_word[80] ;
wire \u_eth2rf_processor/pending_word[79] ;
wire \u_eth2rf_processor/pending_word[78] ;
wire \u_eth2rf_processor/pending_word[77] ;
wire \u_eth2rf_processor/pending_word[76] ;
wire \u_eth2rf_processor/pending_word[75] ;
wire \u_eth2rf_processor/pending_word[74] ;
wire \u_eth2rf_processor/pending_word[73] ;
wire \u_eth2rf_processor/pending_word[72] ;
wire \u_eth2rf_processor/pending_word[71] ;
wire \u_eth2rf_processor/pending_word[70] ;
wire \u_eth2rf_processor/pending_word[69] ;
wire \u_eth2rf_processor/pending_word[68] ;
wire \u_eth2rf_processor/pending_word[67] ;
wire \u_eth2rf_processor/pending_word[66] ;
wire \u_eth2rf_processor/pending_word[65] ;
wire \u_eth2rf_processor/pending_word[64] ;
wire \u_eth2rf_processor/pending_word[63] ;
wire \u_eth2rf_processor/pending_word[62] ;
wire \u_eth2rf_processor/pending_word[61] ;
wire \u_eth2rf_processor/pending_word[60] ;
wire \u_eth2rf_processor/pending_word[59] ;
wire \u_eth2rf_processor/pending_word[58] ;
wire \u_eth2rf_processor/pending_word[57] ;
wire \u_eth2rf_processor/pending_word[56] ;
wire \u_eth2rf_processor/pending_word[55] ;
wire \u_eth2rf_processor/pending_word[54] ;
wire \u_eth2rf_processor/pending_word[53] ;
wire \u_eth2rf_processor/pending_word[52] ;
wire \u_eth2rf_processor/pending_word[51] ;
wire \u_eth2rf_processor/pending_word[50] ;
wire \u_eth2rf_processor/pending_word[49] ;
wire \u_eth2rf_processor/pending_word[48] ;
wire \u_eth2rf_processor/pending_word[47] ;
wire \u_eth2rf_processor/pending_word[46] ;
wire \u_eth2rf_processor/pending_word[45] ;
wire \u_eth2rf_processor/pending_word[44] ;
wire \u_eth2rf_processor/pending_word[43] ;
wire \u_eth2rf_processor/pending_word[42] ;
wire \u_eth2rf_processor/pending_word[41] ;
wire \u_eth2rf_processor/pending_word[40] ;
wire \u_eth2rf_processor/pending_word[39] ;
wire \u_eth2rf_processor/pending_word[38] ;
wire \u_eth2rf_processor/pending_word[37] ;
wire \u_eth2rf_processor/pending_word[36] ;
wire \u_eth2rf_processor/pending_word[35] ;
wire \u_eth2rf_processor/pending_word[34] ;
wire \u_eth2rf_processor/pending_word[33] ;
wire \u_eth2rf_processor/pending_word[32] ;
wire \u_eth2rf_processor/pending_word[31] ;
wire \u_eth2rf_processor/pending_word[30] ;
wire \u_eth2rf_processor/pending_word[29] ;
wire \u_eth2rf_processor/pending_word[28] ;
wire \u_eth2rf_processor/pending_word[27] ;
wire \u_eth2rf_processor/pending_word[26] ;
wire \u_eth2rf_processor/pending_word[25] ;
wire \u_eth2rf_processor/pending_word[24] ;
wire \u_eth2rf_processor/pending_word[23] ;
wire \u_eth2rf_processor/pending_word[22] ;
wire \u_eth2rf_processor/pending_word[21] ;
wire \u_eth2rf_processor/pending_word[20] ;
wire \u_eth2rf_processor/pending_word[19] ;
wire \u_eth2rf_processor/pending_word[18] ;
wire \u_eth2rf_processor/pending_word[17] ;
wire \u_eth2rf_processor/pending_word[16] ;
wire \u_eth2rf_processor/pending_word[15] ;
wire \u_eth2rf_processor/pending_word[14] ;
wire \u_eth2rf_processor/pending_word[13] ;
wire \u_eth2rf_processor/pending_word[12] ;
wire \u_eth2rf_processor/pending_word[11] ;
wire \u_eth2rf_processor/pending_word[10] ;
wire \u_eth2rf_processor/pending_word[9] ;
wire \u_eth2rf_processor/pending_word[8] ;
wire \u_eth2rf_processor/pending_word[7] ;
wire \u_eth2rf_processor/pending_word[6] ;
wire \u_eth2rf_processor/pending_word[5] ;
wire \u_eth2rf_processor/pending_word[4] ;
wire \u_eth2rf_processor/pending_word[3] ;
wire \u_eth2rf_processor/pending_word[2] ;
wire \u_eth2rf_processor/pending_word[1] ;
wire \u_eth2rf_processor/pending_word[0] ;
wire \u_eth2rf_processor/app_wr_data[127] ;
wire \u_eth2rf_processor/app_wr_data[126] ;
wire \u_eth2rf_processor/app_wr_data[125] ;
wire \u_eth2rf_processor/app_wr_data[124] ;
wire \u_eth2rf_processor/app_wr_data[123] ;
wire \u_eth2rf_processor/app_wr_data[122] ;
wire \u_eth2rf_processor/app_wr_data[121] ;
wire \u_eth2rf_processor/app_wr_data[120] ;
wire \u_eth2rf_processor/app_wr_data[119] ;
wire \u_eth2rf_processor/app_wr_data[118] ;
wire \u_eth2rf_processor/app_wr_data[117] ;
wire \u_eth2rf_processor/app_wr_data[116] ;
wire \u_eth2rf_processor/app_wr_data[115] ;
wire \u_eth2rf_processor/app_wr_data[114] ;
wire \u_eth2rf_processor/app_wr_data[113] ;
wire \u_eth2rf_processor/app_wr_data[112] ;
wire \u_eth2rf_processor/app_wr_data[111] ;
wire \u_eth2rf_processor/app_wr_data[110] ;
wire \u_eth2rf_processor/app_wr_data[109] ;
wire \u_eth2rf_processor/app_wr_data[108] ;
wire \u_eth2rf_processor/app_wr_data[107] ;
wire \u_eth2rf_processor/app_wr_data[106] ;
wire \u_eth2rf_processor/app_wr_data[105] ;
wire \u_eth2rf_processor/app_wr_data[104] ;
wire \u_eth2rf_processor/app_wr_data[103] ;
wire \u_eth2rf_processor/app_wr_data[102] ;
wire \u_eth2rf_processor/app_wr_data[101] ;
wire \u_eth2rf_processor/app_wr_data[100] ;
wire \u_eth2rf_processor/app_wr_data[99] ;
wire \u_eth2rf_processor/app_wr_data[98] ;
wire \u_eth2rf_processor/app_wr_data[97] ;
wire \u_eth2rf_processor/app_wr_data[96] ;
wire \u_eth2rf_processor/app_wr_data[95] ;
wire \u_eth2rf_processor/app_wr_data[94] ;
wire \u_eth2rf_processor/app_wr_data[93] ;
wire \u_eth2rf_processor/app_wr_data[92] ;
wire \u_eth2rf_processor/app_wr_data[91] ;
wire \u_eth2rf_processor/app_wr_data[90] ;
wire \u_eth2rf_processor/app_wr_data[89] ;
wire \u_eth2rf_processor/app_wr_data[88] ;
wire \u_eth2rf_processor/app_wr_data[87] ;
wire \u_eth2rf_processor/app_wr_data[86] ;
wire \u_eth2rf_processor/app_wr_data[85] ;
wire \u_eth2rf_processor/app_wr_data[84] ;
wire \u_eth2rf_processor/app_wr_data[83] ;
wire \u_eth2rf_processor/app_wr_data[82] ;
wire \u_eth2rf_processor/app_wr_data[81] ;
wire \u_eth2rf_processor/app_wr_data[80] ;
wire \u_eth2rf_processor/app_wr_data[79] ;
wire \u_eth2rf_processor/app_wr_data[78] ;
wire \u_eth2rf_processor/app_wr_data[77] ;
wire \u_eth2rf_processor/app_wr_data[76] ;
wire \u_eth2rf_processor/app_wr_data[75] ;
wire \u_eth2rf_processor/app_wr_data[74] ;
wire \u_eth2rf_processor/app_wr_data[73] ;
wire \u_eth2rf_processor/app_wr_data[72] ;
wire \u_eth2rf_processor/app_wr_data[71] ;
wire \u_eth2rf_processor/app_wr_data[70] ;
wire \u_eth2rf_processor/app_wr_data[69] ;
wire \u_eth2rf_processor/app_wr_data[68] ;
wire \u_eth2rf_processor/app_wr_data[67] ;
wire \u_eth2rf_processor/app_wr_data[66] ;
wire \u_eth2rf_processor/app_wr_data[65] ;
wire \u_eth2rf_processor/app_wr_data[64] ;
wire \u_eth2rf_processor/app_wr_data[63] ;
wire \u_eth2rf_processor/app_wr_data[62] ;
wire \u_eth2rf_processor/app_wr_data[61] ;
wire \u_eth2rf_processor/app_wr_data[60] ;
wire \u_eth2rf_processor/app_wr_data[59] ;
wire \u_eth2rf_processor/app_wr_data[58] ;
wire \u_eth2rf_processor/app_wr_data[57] ;
wire \u_eth2rf_processor/app_wr_data[56] ;
wire \u_eth2rf_processor/app_wr_data[55] ;
wire \u_eth2rf_processor/app_wr_data[54] ;
wire \u_eth2rf_processor/app_wr_data[53] ;
wire \u_eth2rf_processor/app_wr_data[52] ;
wire \u_eth2rf_processor/app_wr_data[51] ;
wire \u_eth2rf_processor/app_wr_data[50] ;
wire \u_eth2rf_processor/app_wr_data[49] ;
wire \u_eth2rf_processor/app_wr_data[48] ;
wire \u_eth2rf_processor/app_wr_data[47] ;
wire \u_eth2rf_processor/app_wr_data[46] ;
wire \u_eth2rf_processor/app_wr_data[45] ;
wire \u_eth2rf_processor/app_wr_data[44] ;
wire \u_eth2rf_processor/app_wr_data[43] ;
wire \u_eth2rf_processor/app_wr_data[42] ;
wire \u_eth2rf_processor/app_wr_data[41] ;
wire \u_eth2rf_processor/app_wr_data[40] ;
wire \u_eth2rf_processor/app_wr_data[39] ;
wire \u_eth2rf_processor/app_wr_data[38] ;
wire \u_eth2rf_processor/app_wr_data[37] ;
wire \u_eth2rf_processor/app_wr_data[36] ;
wire \u_eth2rf_processor/app_wr_data[35] ;
wire \u_eth2rf_processor/app_wr_data[34] ;
wire \u_eth2rf_processor/app_wr_data[33] ;
wire \u_eth2rf_processor/app_wr_data[32] ;
wire \u_eth2rf_processor/app_wr_data[31] ;
wire \u_eth2rf_processor/app_wr_data[30] ;
wire \u_eth2rf_processor/app_wr_data[29] ;
wire \u_eth2rf_processor/app_wr_data[28] ;
wire \u_eth2rf_processor/app_wr_data[27] ;
wire \u_eth2rf_processor/app_wr_data[26] ;
wire \u_eth2rf_processor/app_wr_data[25] ;
wire \u_eth2rf_processor/app_wr_data[24] ;
wire \u_eth2rf_processor/app_wr_data[23] ;
wire \u_eth2rf_processor/app_wr_data[22] ;
wire \u_eth2rf_processor/app_wr_data[21] ;
wire \u_eth2rf_processor/app_wr_data[20] ;
wire \u_eth2rf_processor/app_wr_data[19] ;
wire \u_eth2rf_processor/app_wr_data[18] ;
wire \u_eth2rf_processor/app_wr_data[17] ;
wire \u_eth2rf_processor/app_wr_data[16] ;
wire \u_eth2rf_processor/app_wr_data[15] ;
wire \u_eth2rf_processor/app_wr_data[14] ;
wire \u_eth2rf_processor/app_wr_data[13] ;
wire \u_eth2rf_processor/app_wr_data[12] ;
wire \u_eth2rf_processor/app_wr_data[11] ;
wire \u_eth2rf_processor/app_wr_data[10] ;
wire \u_eth2rf_processor/app_wr_data[9] ;
wire \u_eth2rf_processor/app_wr_data[8] ;
wire \u_eth2rf_processor/app_wr_data[7] ;
wire \u_eth2rf_processor/app_wr_data[6] ;
wire \u_eth2rf_processor/app_wr_data[5] ;
wire \u_eth2rf_processor/app_wr_data[4] ;
wire \u_eth2rf_processor/app_wr_data[3] ;
wire \u_eth2rf_processor/app_wr_data[2] ;
wire \u_eth2rf_processor/app_wr_data[1] ;
wire \u_eth2rf_processor/app_wr_data[0] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[127] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[126] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[125] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[124] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[123] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[122] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[121] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[120] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[119] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[118] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[117] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[116] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[115] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[114] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[113] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[112] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[111] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[110] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[109] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[108] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[107] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[106] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[105] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[104] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[103] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[102] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[101] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[100] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[99] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[98] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[97] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[96] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[95] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[94] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[93] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[92] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[91] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[90] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[89] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[88] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[87] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[86] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[85] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[84] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[83] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[82] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[81] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[80] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[79] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[78] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[77] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[76] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[75] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[74] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[73] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[72] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[71] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[70] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[69] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[68] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[67] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[66] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[65] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[64] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[63] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[62] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[61] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[60] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[59] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[58] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[57] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[56] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[55] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[54] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[53] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[52] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[51] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[50] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[49] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[48] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[47] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[46] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[45] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[44] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[43] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[42] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[41] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[40] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[39] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[38] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[37] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[36] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[35] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[34] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[33] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[32] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[31] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[30] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[29] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[28] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[27] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[26] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[25] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[24] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[23] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[22] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[21] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[20] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[19] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[18] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[17] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[16] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[15] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[14] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[13] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[12] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[11] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[10] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[9] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[8] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[7] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[6] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[5] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[4] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[3] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[2] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[1] ;
wire \u_eth2rf_processor/u_ddr3/rd_data[0] ;
wire \u_eth2rf_processor/ddr_clk ;
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
    .data_i({\adc_data_out_i1[11] ,\adc_data_out_i1[10] ,\adc_data_out_i1[9] ,\adc_data_out_i1[8] ,\adc_data_out_i1[7] ,\adc_data_out_i1[6] ,\adc_data_out_i1[5] ,\adc_data_out_i1[4] ,\adc_data_out_i1[3] ,\adc_data_out_i1[2] ,\adc_data_out_i1[1] ,\adc_data_out_i1[0] ,\adc_data_out_q1[11] ,\adc_data_out_q1[10] ,\adc_data_out_q1[9] ,\adc_data_out_q1[8] ,\adc_data_out_q1[7] ,\adc_data_out_q1[6] ,\adc_data_out_q1[5] ,\adc_data_out_q1[4] ,\adc_data_out_q1[3] ,\adc_data_out_q1[2] ,\adc_data_out_q1[1] ,\adc_data_out_q1[0] ,\dac_data_out_i1[11] ,\dac_data_out_i1[10] ,\dac_data_out_i1[9] ,\dac_data_out_i1[8] ,\dac_data_out_i1[7] ,\dac_data_out_i1[6] ,\dac_data_out_i1[5] ,\dac_data_out_i1[4] ,\dac_data_out_i1[3] ,\dac_data_out_i1[2] ,\dac_data_out_i1[1] ,\dac_data_out_i1[0] ,\dac_data_out_q1[11] ,\dac_data_out_q1[10] ,\dac_data_out_q1[9] ,\dac_data_out_q1[8] ,\dac_data_out_q1[7] ,\dac_data_out_q1[6] ,\dac_data_out_q1[5] ,\dac_data_out_q1[4] ,\dac_data_out_q1[3] ,\dac_data_out_q1[2] ,\dac_data_out_q1[1] ,\dac_data_out_q1[0] ,bb_symbol_clk,data_clk,bb_byte_clk,rf_tx_ready,rf_tx_valid,\rf_tx_data[7] ,\rf_tx_data[6] ,\rf_tx_data[5] ,\rf_tx_data[4] ,\rf_tx_data[3] ,\rf_tx_data[2] ,\rf_tx_data[1] ,\rf_tx_data[0] ,\u_rf_process/gardner_sync_flag ,\u_rf_process/gardner_sync_I ,\u_rf_process/gardner_sync_Q ,\u_rf_process/dqpsk_rx_data[7] ,\u_rf_process/dqpsk_rx_data[6] ,\u_rf_process/dqpsk_rx_data[5] ,\u_rf_process/dqpsk_rx_data[4] ,\u_rf_process/dqpsk_rx_data[3] ,\u_rf_process/dqpsk_rx_data[2] ,\u_rf_process/dqpsk_rx_data[1] ,\u_rf_process/dqpsk_rx_data[0] ,\u_rf_process/u_rf_dqpsk_decoder/frame_aligned_data_dbg[7] ,\u_rf_process/u_rf_dqpsk_decoder/frame_aligned_data_dbg[6] ,\u_rf_process/u_rf_dqpsk_decoder/frame_aligned_data_dbg[5] ,\u_rf_process/u_rf_dqpsk_decoder/frame_aligned_data_dbg[4] ,\u_rf_process/u_rf_dqpsk_decoder/frame_aligned_data_dbg[3] ,\u_rf_process/u_rf_dqpsk_decoder/frame_aligned_data_dbg[2] ,\u_rf_process/u_rf_dqpsk_decoder/frame_aligned_data_dbg[1] ,\u_rf_process/u_rf_dqpsk_decoder/frame_aligned_data_dbg[0] ,\u_rf_process/u_rf_dqpsk_decoder/frame_head_found_dbg ,\u_rf_process/u_rf_dqpsk_decoder/deframe_state_dbg[1] ,\u_rf_process/u_rf_dqpsk_decoder/deframe_state_dbg[0] ,\u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[15] ,\u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[14] ,\u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[13] ,\u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[12] ,\u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[11] ,\u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[10] ,\u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[9] ,\u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[8] ,\u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[7] ,\u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[6] ,\u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[5] ,\u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[4] ,\u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[3] ,\u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[2] ,\u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[1] ,\u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[0] ,\u_rf_process/gardner_sync_u0/uk[15] ,\u_rf_process/gardner_sync_u0/uk[14] ,\u_rf_process/gardner_sync_u0/uk[13] ,\u_rf_process/gardner_sync_u0/uk[12] ,\u_rf_process/gardner_sync_u0/uk[11] ,\u_rf_process/gardner_sync_u0/uk[10] ,\u_rf_process/gardner_sync_u0/uk[9] ,\u_rf_process/gardner_sync_u0/uk[8] ,\u_rf_process/gardner_sync_u0/uk[7] ,\u_rf_process/gardner_sync_u0/uk[6] ,\u_rf_process/gardner_sync_u0/uk[5] ,\u_rf_process/gardner_sync_u0/uk[4] ,\u_rf_process/gardner_sync_u0/uk[3] ,\u_rf_process/gardner_sync_u0/uk[2] ,\u_rf_process/gardner_sync_u0/uk[1] ,\u_rf_process/gardner_sync_u0/uk[0] ,\u_rf_process/gardner_sync_u0/I_y[19] ,\u_rf_process/gardner_sync_u0/I_y[18] ,\u_rf_process/gardner_sync_u0/I_y[17] ,\u_rf_process/gardner_sync_u0/I_y[16] ,\u_rf_process/gardner_sync_u0/I_y[15] ,\u_rf_process/gardner_sync_u0/I_y[14] ,\u_rf_process/gardner_sync_u0/I_y[13] ,\u_rf_process/gardner_sync_u0/I_y[12] ,\u_rf_process/gardner_sync_u0/I_y[11] ,\u_rf_process/gardner_sync_u0/I_y[10] ,\u_rf_process/gardner_sync_u0/I_y[9] ,\u_rf_process/gardner_sync_u0/I_y[8] ,\u_rf_process/gardner_sync_u0/I_y[7] ,\u_rf_process/gardner_sync_u0/I_y[6] ,\u_rf_process/gardner_sync_u0/I_y[5] ,\u_rf_process/gardner_sync_u0/I_y[4] ,\u_rf_process/gardner_sync_u0/I_y[3] ,\u_rf_process/gardner_sync_u0/I_y[2] ,\u_rf_process/gardner_sync_u0/I_y[1] ,\u_rf_process/gardner_sync_u0/I_y[0] ,\u_rf_process/gardner_sync_u0/Q_y[19] ,\u_rf_process/gardner_sync_u0/Q_y[18] ,\u_rf_process/gardner_sync_u0/Q_y[17] ,\u_rf_process/gardner_sync_u0/Q_y[16] ,\u_rf_process/gardner_sync_u0/Q_y[15] ,\u_rf_process/gardner_sync_u0/Q_y[14] ,\u_rf_process/gardner_sync_u0/Q_y[13] ,\u_rf_process/gardner_sync_u0/Q_y[12] ,\u_rf_process/gardner_sync_u0/Q_y[11] ,\u_rf_process/gardner_sync_u0/Q_y[10] ,\u_rf_process/gardner_sync_u0/Q_y[9] ,\u_rf_process/gardner_sync_u0/Q_y[8] ,\u_rf_process/gardner_sync_u0/Q_y[7] ,\u_rf_process/gardner_sync_u0/Q_y[6] ,\u_rf_process/gardner_sync_u0/Q_y[5] ,\u_rf_process/gardner_sync_u0/Q_y[4] ,\u_rf_process/gardner_sync_u0/Q_y[3] ,\u_rf_process/gardner_sync_u0/Q_y[2] ,\u_rf_process/gardner_sync_u0/Q_y[1] ,\u_rf_process/gardner_sync_u0/Q_y[0] ,\u_rf_process/gardner_sync_u0/nco_strobe_flag ,\u_rf_process/gardner_sync_u0/ted_strobe_flag ,ddr_init_done,ddr_pll_lock_dbg,ddr_phy_reset_dbg,ddr_pll_stop_dbg,eth_ingress_accept,eth_ingress_drop,\ddr_queued_words_dbg[15] ,\ddr_queued_words_dbg[14] ,\ddr_queued_words_dbg[13] ,\ddr_queued_words_dbg[12] ,\ddr_queued_words_dbg[11] ,\ddr_queued_words_dbg[10] ,\ddr_queued_words_dbg[9] ,\ddr_queued_words_dbg[8] ,\ddr_queued_words_dbg[7] ,\ddr_queued_words_dbg[6] ,\ddr_queued_words_dbg[5] ,\ddr_queued_words_dbg[4] ,\ddr_queued_words_dbg[3] ,\ddr_queued_words_dbg[2] ,\ddr_queued_words_dbg[1] ,\ddr_queued_words_dbg[0] ,\eth_credit_packets_dbg[15] ,\eth_credit_packets_dbg[14] ,\eth_credit_packets_dbg[13] ,\eth_credit_packets_dbg[12] ,\eth_credit_packets_dbg[11] ,\eth_credit_packets_dbg[10] ,\eth_credit_packets_dbg[9] ,\eth_credit_packets_dbg[8] ,\eth_credit_packets_dbg[7] ,\eth_credit_packets_dbg[6] ,\eth_credit_packets_dbg[5] ,\eth_credit_packets_dbg[4] ,\eth_credit_packets_dbg[3] ,\eth_credit_packets_dbg[2] ,\eth_credit_packets_dbg[1] ,\eth_credit_packets_dbg[0] }),
    .clk_i(bb_byte_clk)
);

ao_top_1  u_la1_top(
    .control(control1[9:0]),
    .trig0_i(\u_eth2rf_processor/app_cmd_en ),
    .data_i({\u_eth2rf_processor/in_fifo_q[7] ,\u_eth2rf_processor/in_fifo_q[6] ,\u_eth2rf_processor/in_fifo_q[5] ,\u_eth2rf_processor/in_fifo_q[4] ,\u_eth2rf_processor/in_fifo_q[3] ,\u_eth2rf_processor/in_fifo_q[2] ,\u_eth2rf_processor/in_fifo_q[1] ,\u_eth2rf_processor/in_fifo_q[0] ,ddr_init_done,\u_eth2rf_processor/ddr_clk100_counter_dbg[15] ,\u_eth2rf_processor/ddr_clk100_counter_dbg[14] ,\u_eth2rf_processor/ddr_clk100_counter_dbg[13] ,\u_eth2rf_processor/ddr_clk100_counter_dbg[12] ,\u_eth2rf_processor/ddr_clk100_counter_dbg[11] ,\u_eth2rf_processor/ddr_clk100_counter_dbg[10] ,\u_eth2rf_processor/ddr_clk100_counter_dbg[9] ,\u_eth2rf_processor/ddr_clk100_counter_dbg[8] ,\u_eth2rf_processor/ddr_clk100_counter_dbg[7] ,\u_eth2rf_processor/ddr_clk100_counter_dbg[6] ,\u_eth2rf_processor/ddr_clk100_counter_dbg[5] ,\u_eth2rf_processor/ddr_clk100_counter_dbg[4] ,\u_eth2rf_processor/ddr_clk100_counter_dbg[3] ,\u_eth2rf_processor/ddr_clk100_counter_dbg[2] ,\u_eth2rf_processor/ddr_clk100_counter_dbg[1] ,\u_eth2rf_processor/ddr_clk100_counter_dbg[0] ,\u_eth2rf_processor/ddr_memclk_counter_dbg[15] ,\u_eth2rf_processor/ddr_memclk_counter_dbg[14] ,\u_eth2rf_processor/ddr_memclk_counter_dbg[13] ,\u_eth2rf_processor/ddr_memclk_counter_dbg[12] ,\u_eth2rf_processor/ddr_memclk_counter_dbg[11] ,\u_eth2rf_processor/ddr_memclk_counter_dbg[10] ,\u_eth2rf_processor/ddr_memclk_counter_dbg[9] ,\u_eth2rf_processor/ddr_memclk_counter_dbg[8] ,\u_eth2rf_processor/ddr_memclk_counter_dbg[7] ,\u_eth2rf_processor/ddr_memclk_counter_dbg[6] ,\u_eth2rf_processor/ddr_memclk_counter_dbg[5] ,\u_eth2rf_processor/ddr_memclk_counter_dbg[4] ,\u_eth2rf_processor/ddr_memclk_counter_dbg[3] ,\u_eth2rf_processor/ddr_memclk_counter_dbg[2] ,\u_eth2rf_processor/ddr_memclk_counter_dbg[1] ,\u_eth2rf_processor/ddr_memclk_counter_dbg[0] ,\u_eth2rf_processor/in_fifo_empty ,\u_eth2rf_processor/in_fifo_re_r ,\u_eth2rf_processor/in_fifo_data_valid ,\u_eth2rf_processor/app_cmd[2] ,\u_eth2rf_processor/app_cmd[1] ,\u_eth2rf_processor/app_cmd[0] ,\u_eth2rf_processor/app_wr_mask[15] ,\u_eth2rf_processor/app_wr_mask[14] ,\u_eth2rf_processor/app_wr_mask[13] ,\u_eth2rf_processor/app_wr_mask[12] ,\u_eth2rf_processor/app_wr_mask[11] ,\u_eth2rf_processor/app_wr_mask[10] ,\u_eth2rf_processor/app_wr_mask[9] ,\u_eth2rf_processor/app_wr_mask[8] ,\u_eth2rf_processor/app_wr_mask[7] ,\u_eth2rf_processor/app_wr_mask[6] ,\u_eth2rf_processor/app_wr_mask[5] ,\u_eth2rf_processor/app_wr_mask[4] ,\u_eth2rf_processor/app_wr_mask[3] ,\u_eth2rf_processor/app_wr_mask[2] ,\u_eth2rf_processor/app_wr_mask[1] ,\u_eth2rf_processor/app_wr_mask[0] ,\u_eth2rf_processor/app_cmd_en ,\u_eth2rf_processor/cmd_ready ,\u_eth2rf_processor/app_wr_en ,\u_eth2rf_processor/wr_data_rdy ,\u_eth2rf_processor/write_pending ,\u_eth2rf_processor/write_is_last ,\ddr_queued_words_dbg[15] ,\ddr_queued_words_dbg[14] ,\ddr_queued_words_dbg[13] ,\ddr_queued_words_dbg[12] ,\ddr_queued_words_dbg[11] ,\ddr_queued_words_dbg[10] ,\ddr_queued_words_dbg[9] ,\ddr_queued_words_dbg[8] ,\ddr_queued_words_dbg[7] ,\ddr_queued_words_dbg[6] ,\ddr_queued_words_dbg[5] ,\ddr_queued_words_dbg[4] ,\ddr_queued_words_dbg[3] ,\ddr_queued_words_dbg[2] ,\ddr_queued_words_dbg[1] ,\ddr_queued_words_dbg[0] ,\eth_credit_packets_dbg[15] ,\eth_credit_packets_dbg[14] ,\eth_credit_packets_dbg[13] ,\eth_credit_packets_dbg[12] ,\eth_credit_packets_dbg[11] ,\eth_credit_packets_dbg[10] ,\eth_credit_packets_dbg[9] ,\eth_credit_packets_dbg[8] ,\eth_credit_packets_dbg[7] ,\eth_credit_packets_dbg[6] ,\eth_credit_packets_dbg[5] ,\eth_credit_packets_dbg[4] ,\eth_credit_packets_dbg[3] ,\eth_credit_packets_dbg[2] ,\eth_credit_packets_dbg[1] ,\eth_credit_packets_dbg[0] ,\u_eth2rf_processor/read_active ,\u_eth2rf_processor/read_wait ,\u_eth2rf_processor/rd_data_valid ,\u_eth2rf_processor/out_fifo_we ,ddr_pll_lock_dbg,ddr_phy_reset_dbg,ddr_pll_stop_dbg,\u_eth2rf_processor/pending_word[127] ,\u_eth2rf_processor/pending_word[126] ,\u_eth2rf_processor/pending_word[125] ,\u_eth2rf_processor/pending_word[124] ,\u_eth2rf_processor/pending_word[123] ,\u_eth2rf_processor/pending_word[122] ,\u_eth2rf_processor/pending_word[121] ,\u_eth2rf_processor/pending_word[120] ,\u_eth2rf_processor/pending_word[119] ,\u_eth2rf_processor/pending_word[118] ,\u_eth2rf_processor/pending_word[117] ,\u_eth2rf_processor/pending_word[116] ,\u_eth2rf_processor/pending_word[115] ,\u_eth2rf_processor/pending_word[114] ,\u_eth2rf_processor/pending_word[113] ,\u_eth2rf_processor/pending_word[112] ,\u_eth2rf_processor/pending_word[111] ,\u_eth2rf_processor/pending_word[110] ,\u_eth2rf_processor/pending_word[109] ,\u_eth2rf_processor/pending_word[108] ,\u_eth2rf_processor/pending_word[107] ,\u_eth2rf_processor/pending_word[106] ,\u_eth2rf_processor/pending_word[105] ,\u_eth2rf_processor/pending_word[104] ,\u_eth2rf_processor/pending_word[103] ,\u_eth2rf_processor/pending_word[102] ,\u_eth2rf_processor/pending_word[101] ,\u_eth2rf_processor/pending_word[100] ,\u_eth2rf_processor/pending_word[99] ,\u_eth2rf_processor/pending_word[98] ,\u_eth2rf_processor/pending_word[97] ,\u_eth2rf_processor/pending_word[96] ,\u_eth2rf_processor/pending_word[95] ,\u_eth2rf_processor/pending_word[94] ,\u_eth2rf_processor/pending_word[93] ,\u_eth2rf_processor/pending_word[92] ,\u_eth2rf_processor/pending_word[91] ,\u_eth2rf_processor/pending_word[90] ,\u_eth2rf_processor/pending_word[89] ,\u_eth2rf_processor/pending_word[88] ,\u_eth2rf_processor/pending_word[87] ,\u_eth2rf_processor/pending_word[86] ,\u_eth2rf_processor/pending_word[85] ,\u_eth2rf_processor/pending_word[84] ,\u_eth2rf_processor/pending_word[83] ,\u_eth2rf_processor/pending_word[82] ,\u_eth2rf_processor/pending_word[81] ,\u_eth2rf_processor/pending_word[80] ,\u_eth2rf_processor/pending_word[79] ,\u_eth2rf_processor/pending_word[78] ,\u_eth2rf_processor/pending_word[77] ,\u_eth2rf_processor/pending_word[76] ,\u_eth2rf_processor/pending_word[75] ,\u_eth2rf_processor/pending_word[74] ,\u_eth2rf_processor/pending_word[73] ,\u_eth2rf_processor/pending_word[72] ,\u_eth2rf_processor/pending_word[71] ,\u_eth2rf_processor/pending_word[70] ,\u_eth2rf_processor/pending_word[69] ,\u_eth2rf_processor/pending_word[68] ,\u_eth2rf_processor/pending_word[67] ,\u_eth2rf_processor/pending_word[66] ,\u_eth2rf_processor/pending_word[65] ,\u_eth2rf_processor/pending_word[64] ,\u_eth2rf_processor/pending_word[63] ,\u_eth2rf_processor/pending_word[62] ,\u_eth2rf_processor/pending_word[61] ,\u_eth2rf_processor/pending_word[60] ,\u_eth2rf_processor/pending_word[59] ,\u_eth2rf_processor/pending_word[58] ,\u_eth2rf_processor/pending_word[57] ,\u_eth2rf_processor/pending_word[56] ,\u_eth2rf_processor/pending_word[55] ,\u_eth2rf_processor/pending_word[54] ,\u_eth2rf_processor/pending_word[53] ,\u_eth2rf_processor/pending_word[52] ,\u_eth2rf_processor/pending_word[51] ,\u_eth2rf_processor/pending_word[50] ,\u_eth2rf_processor/pending_word[49] ,\u_eth2rf_processor/pending_word[48] ,\u_eth2rf_processor/pending_word[47] ,\u_eth2rf_processor/pending_word[46] ,\u_eth2rf_processor/pending_word[45] ,\u_eth2rf_processor/pending_word[44] ,\u_eth2rf_processor/pending_word[43] ,\u_eth2rf_processor/pending_word[42] ,\u_eth2rf_processor/pending_word[41] ,\u_eth2rf_processor/pending_word[40] ,\u_eth2rf_processor/pending_word[39] ,\u_eth2rf_processor/pending_word[38] ,\u_eth2rf_processor/pending_word[37] ,\u_eth2rf_processor/pending_word[36] ,\u_eth2rf_processor/pending_word[35] ,\u_eth2rf_processor/pending_word[34] ,\u_eth2rf_processor/pending_word[33] ,\u_eth2rf_processor/pending_word[32] ,\u_eth2rf_processor/pending_word[31] ,\u_eth2rf_processor/pending_word[30] ,\u_eth2rf_processor/pending_word[29] ,\u_eth2rf_processor/pending_word[28] ,\u_eth2rf_processor/pending_word[27] ,\u_eth2rf_processor/pending_word[26] ,\u_eth2rf_processor/pending_word[25] ,\u_eth2rf_processor/pending_word[24] ,\u_eth2rf_processor/pending_word[23] ,\u_eth2rf_processor/pending_word[22] ,\u_eth2rf_processor/pending_word[21] ,\u_eth2rf_processor/pending_word[20] ,\u_eth2rf_processor/pending_word[19] ,\u_eth2rf_processor/pending_word[18] ,\u_eth2rf_processor/pending_word[17] ,\u_eth2rf_processor/pending_word[16] ,\u_eth2rf_processor/pending_word[15] ,\u_eth2rf_processor/pending_word[14] ,\u_eth2rf_processor/pending_word[13] ,\u_eth2rf_processor/pending_word[12] ,\u_eth2rf_processor/pending_word[11] ,\u_eth2rf_processor/pending_word[10] ,\u_eth2rf_processor/pending_word[9] ,\u_eth2rf_processor/pending_word[8] ,\u_eth2rf_processor/pending_word[7] ,\u_eth2rf_processor/pending_word[6] ,\u_eth2rf_processor/pending_word[5] ,\u_eth2rf_processor/pending_word[4] ,\u_eth2rf_processor/pending_word[3] ,\u_eth2rf_processor/pending_word[2] ,\u_eth2rf_processor/pending_word[1] ,\u_eth2rf_processor/pending_word[0] ,\u_eth2rf_processor/app_wr_data[127] ,\u_eth2rf_processor/app_wr_data[126] ,\u_eth2rf_processor/app_wr_data[125] ,\u_eth2rf_processor/app_wr_data[124] ,\u_eth2rf_processor/app_wr_data[123] ,\u_eth2rf_processor/app_wr_data[122] ,\u_eth2rf_processor/app_wr_data[121] ,\u_eth2rf_processor/app_wr_data[120] ,\u_eth2rf_processor/app_wr_data[119] ,\u_eth2rf_processor/app_wr_data[118] ,\u_eth2rf_processor/app_wr_data[117] ,\u_eth2rf_processor/app_wr_data[116] ,\u_eth2rf_processor/app_wr_data[115] ,\u_eth2rf_processor/app_wr_data[114] ,\u_eth2rf_processor/app_wr_data[113] ,\u_eth2rf_processor/app_wr_data[112] ,\u_eth2rf_processor/app_wr_data[111] ,\u_eth2rf_processor/app_wr_data[110] ,\u_eth2rf_processor/app_wr_data[109] ,\u_eth2rf_processor/app_wr_data[108] ,\u_eth2rf_processor/app_wr_data[107] ,\u_eth2rf_processor/app_wr_data[106] ,\u_eth2rf_processor/app_wr_data[105] ,\u_eth2rf_processor/app_wr_data[104] ,\u_eth2rf_processor/app_wr_data[103] ,\u_eth2rf_processor/app_wr_data[102] ,\u_eth2rf_processor/app_wr_data[101] ,\u_eth2rf_processor/app_wr_data[100] ,\u_eth2rf_processor/app_wr_data[99] ,\u_eth2rf_processor/app_wr_data[98] ,\u_eth2rf_processor/app_wr_data[97] ,\u_eth2rf_processor/app_wr_data[96] ,\u_eth2rf_processor/app_wr_data[95] ,\u_eth2rf_processor/app_wr_data[94] ,\u_eth2rf_processor/app_wr_data[93] ,\u_eth2rf_processor/app_wr_data[92] ,\u_eth2rf_processor/app_wr_data[91] ,\u_eth2rf_processor/app_wr_data[90] ,\u_eth2rf_processor/app_wr_data[89] ,\u_eth2rf_processor/app_wr_data[88] ,\u_eth2rf_processor/app_wr_data[87] ,\u_eth2rf_processor/app_wr_data[86] ,\u_eth2rf_processor/app_wr_data[85] ,\u_eth2rf_processor/app_wr_data[84] ,\u_eth2rf_processor/app_wr_data[83] ,\u_eth2rf_processor/app_wr_data[82] ,\u_eth2rf_processor/app_wr_data[81] ,\u_eth2rf_processor/app_wr_data[80] ,\u_eth2rf_processor/app_wr_data[79] ,\u_eth2rf_processor/app_wr_data[78] ,\u_eth2rf_processor/app_wr_data[77] ,\u_eth2rf_processor/app_wr_data[76] ,\u_eth2rf_processor/app_wr_data[75] ,\u_eth2rf_processor/app_wr_data[74] ,\u_eth2rf_processor/app_wr_data[73] ,\u_eth2rf_processor/app_wr_data[72] ,\u_eth2rf_processor/app_wr_data[71] ,\u_eth2rf_processor/app_wr_data[70] ,\u_eth2rf_processor/app_wr_data[69] ,\u_eth2rf_processor/app_wr_data[68] ,\u_eth2rf_processor/app_wr_data[67] ,\u_eth2rf_processor/app_wr_data[66] ,\u_eth2rf_processor/app_wr_data[65] ,\u_eth2rf_processor/app_wr_data[64] ,\u_eth2rf_processor/app_wr_data[63] ,\u_eth2rf_processor/app_wr_data[62] ,\u_eth2rf_processor/app_wr_data[61] ,\u_eth2rf_processor/app_wr_data[60] ,\u_eth2rf_processor/app_wr_data[59] ,\u_eth2rf_processor/app_wr_data[58] ,\u_eth2rf_processor/app_wr_data[57] ,\u_eth2rf_processor/app_wr_data[56] ,\u_eth2rf_processor/app_wr_data[55] ,\u_eth2rf_processor/app_wr_data[54] ,\u_eth2rf_processor/app_wr_data[53] ,\u_eth2rf_processor/app_wr_data[52] ,\u_eth2rf_processor/app_wr_data[51] ,\u_eth2rf_processor/app_wr_data[50] ,\u_eth2rf_processor/app_wr_data[49] ,\u_eth2rf_processor/app_wr_data[48] ,\u_eth2rf_processor/app_wr_data[47] ,\u_eth2rf_processor/app_wr_data[46] ,\u_eth2rf_processor/app_wr_data[45] ,\u_eth2rf_processor/app_wr_data[44] ,\u_eth2rf_processor/app_wr_data[43] ,\u_eth2rf_processor/app_wr_data[42] ,\u_eth2rf_processor/app_wr_data[41] ,\u_eth2rf_processor/app_wr_data[40] ,\u_eth2rf_processor/app_wr_data[39] ,\u_eth2rf_processor/app_wr_data[38] ,\u_eth2rf_processor/app_wr_data[37] ,\u_eth2rf_processor/app_wr_data[36] ,\u_eth2rf_processor/app_wr_data[35] ,\u_eth2rf_processor/app_wr_data[34] ,\u_eth2rf_processor/app_wr_data[33] ,\u_eth2rf_processor/app_wr_data[32] ,\u_eth2rf_processor/app_wr_data[31] ,\u_eth2rf_processor/app_wr_data[30] ,\u_eth2rf_processor/app_wr_data[29] ,\u_eth2rf_processor/app_wr_data[28] ,\u_eth2rf_processor/app_wr_data[27] ,\u_eth2rf_processor/app_wr_data[26] ,\u_eth2rf_processor/app_wr_data[25] ,\u_eth2rf_processor/app_wr_data[24] ,\u_eth2rf_processor/app_wr_data[23] ,\u_eth2rf_processor/app_wr_data[22] ,\u_eth2rf_processor/app_wr_data[21] ,\u_eth2rf_processor/app_wr_data[20] ,\u_eth2rf_processor/app_wr_data[19] ,\u_eth2rf_processor/app_wr_data[18] ,\u_eth2rf_processor/app_wr_data[17] ,\u_eth2rf_processor/app_wr_data[16] ,\u_eth2rf_processor/app_wr_data[15] ,\u_eth2rf_processor/app_wr_data[14] ,\u_eth2rf_processor/app_wr_data[13] ,\u_eth2rf_processor/app_wr_data[12] ,\u_eth2rf_processor/app_wr_data[11] ,\u_eth2rf_processor/app_wr_data[10] ,\u_eth2rf_processor/app_wr_data[9] ,\u_eth2rf_processor/app_wr_data[8] ,\u_eth2rf_processor/app_wr_data[7] ,\u_eth2rf_processor/app_wr_data[6] ,\u_eth2rf_processor/app_wr_data[5] ,\u_eth2rf_processor/app_wr_data[4] ,\u_eth2rf_processor/app_wr_data[3] ,\u_eth2rf_processor/app_wr_data[2] ,\u_eth2rf_processor/app_wr_data[1] ,\u_eth2rf_processor/app_wr_data[0] ,\u_eth2rf_processor/u_ddr3/rd_data[127] ,\u_eth2rf_processor/u_ddr3/rd_data[126] ,\u_eth2rf_processor/u_ddr3/rd_data[125] ,\u_eth2rf_processor/u_ddr3/rd_data[124] ,\u_eth2rf_processor/u_ddr3/rd_data[123] ,\u_eth2rf_processor/u_ddr3/rd_data[122] ,\u_eth2rf_processor/u_ddr3/rd_data[121] ,\u_eth2rf_processor/u_ddr3/rd_data[120] ,\u_eth2rf_processor/u_ddr3/rd_data[119] ,\u_eth2rf_processor/u_ddr3/rd_data[118] ,\u_eth2rf_processor/u_ddr3/rd_data[117] ,\u_eth2rf_processor/u_ddr3/rd_data[116] ,\u_eth2rf_processor/u_ddr3/rd_data[115] ,\u_eth2rf_processor/u_ddr3/rd_data[114] ,\u_eth2rf_processor/u_ddr3/rd_data[113] ,\u_eth2rf_processor/u_ddr3/rd_data[112] ,\u_eth2rf_processor/u_ddr3/rd_data[111] ,\u_eth2rf_processor/u_ddr3/rd_data[110] ,\u_eth2rf_processor/u_ddr3/rd_data[109] ,\u_eth2rf_processor/u_ddr3/rd_data[108] ,\u_eth2rf_processor/u_ddr3/rd_data[107] ,\u_eth2rf_processor/u_ddr3/rd_data[106] ,\u_eth2rf_processor/u_ddr3/rd_data[105] ,\u_eth2rf_processor/u_ddr3/rd_data[104] ,\u_eth2rf_processor/u_ddr3/rd_data[103] ,\u_eth2rf_processor/u_ddr3/rd_data[102] ,\u_eth2rf_processor/u_ddr3/rd_data[101] ,\u_eth2rf_processor/u_ddr3/rd_data[100] ,\u_eth2rf_processor/u_ddr3/rd_data[99] ,\u_eth2rf_processor/u_ddr3/rd_data[98] ,\u_eth2rf_processor/u_ddr3/rd_data[97] ,\u_eth2rf_processor/u_ddr3/rd_data[96] ,\u_eth2rf_processor/u_ddr3/rd_data[95] ,\u_eth2rf_processor/u_ddr3/rd_data[94] ,\u_eth2rf_processor/u_ddr3/rd_data[93] ,\u_eth2rf_processor/u_ddr3/rd_data[92] ,\u_eth2rf_processor/u_ddr3/rd_data[91] ,\u_eth2rf_processor/u_ddr3/rd_data[90] ,\u_eth2rf_processor/u_ddr3/rd_data[89] ,\u_eth2rf_processor/u_ddr3/rd_data[88] ,\u_eth2rf_processor/u_ddr3/rd_data[87] ,\u_eth2rf_processor/u_ddr3/rd_data[86] ,\u_eth2rf_processor/u_ddr3/rd_data[85] ,\u_eth2rf_processor/u_ddr3/rd_data[84] ,\u_eth2rf_processor/u_ddr3/rd_data[83] ,\u_eth2rf_processor/u_ddr3/rd_data[82] ,\u_eth2rf_processor/u_ddr3/rd_data[81] ,\u_eth2rf_processor/u_ddr3/rd_data[80] ,\u_eth2rf_processor/u_ddr3/rd_data[79] ,\u_eth2rf_processor/u_ddr3/rd_data[78] ,\u_eth2rf_processor/u_ddr3/rd_data[77] ,\u_eth2rf_processor/u_ddr3/rd_data[76] ,\u_eth2rf_processor/u_ddr3/rd_data[75] ,\u_eth2rf_processor/u_ddr3/rd_data[74] ,\u_eth2rf_processor/u_ddr3/rd_data[73] ,\u_eth2rf_processor/u_ddr3/rd_data[72] ,\u_eth2rf_processor/u_ddr3/rd_data[71] ,\u_eth2rf_processor/u_ddr3/rd_data[70] ,\u_eth2rf_processor/u_ddr3/rd_data[69] ,\u_eth2rf_processor/u_ddr3/rd_data[68] ,\u_eth2rf_processor/u_ddr3/rd_data[67] ,\u_eth2rf_processor/u_ddr3/rd_data[66] ,\u_eth2rf_processor/u_ddr3/rd_data[65] ,\u_eth2rf_processor/u_ddr3/rd_data[64] ,\u_eth2rf_processor/u_ddr3/rd_data[63] ,\u_eth2rf_processor/u_ddr3/rd_data[62] ,\u_eth2rf_processor/u_ddr3/rd_data[61] ,\u_eth2rf_processor/u_ddr3/rd_data[60] ,\u_eth2rf_processor/u_ddr3/rd_data[59] ,\u_eth2rf_processor/u_ddr3/rd_data[58] ,\u_eth2rf_processor/u_ddr3/rd_data[57] ,\u_eth2rf_processor/u_ddr3/rd_data[56] ,\u_eth2rf_processor/u_ddr3/rd_data[55] ,\u_eth2rf_processor/u_ddr3/rd_data[54] ,\u_eth2rf_processor/u_ddr3/rd_data[53] ,\u_eth2rf_processor/u_ddr3/rd_data[52] ,\u_eth2rf_processor/u_ddr3/rd_data[51] ,\u_eth2rf_processor/u_ddr3/rd_data[50] ,\u_eth2rf_processor/u_ddr3/rd_data[49] ,\u_eth2rf_processor/u_ddr3/rd_data[48] ,\u_eth2rf_processor/u_ddr3/rd_data[47] ,\u_eth2rf_processor/u_ddr3/rd_data[46] ,\u_eth2rf_processor/u_ddr3/rd_data[45] ,\u_eth2rf_processor/u_ddr3/rd_data[44] ,\u_eth2rf_processor/u_ddr3/rd_data[43] ,\u_eth2rf_processor/u_ddr3/rd_data[42] ,\u_eth2rf_processor/u_ddr3/rd_data[41] ,\u_eth2rf_processor/u_ddr3/rd_data[40] ,\u_eth2rf_processor/u_ddr3/rd_data[39] ,\u_eth2rf_processor/u_ddr3/rd_data[38] ,\u_eth2rf_processor/u_ddr3/rd_data[37] ,\u_eth2rf_processor/u_ddr3/rd_data[36] ,\u_eth2rf_processor/u_ddr3/rd_data[35] ,\u_eth2rf_processor/u_ddr3/rd_data[34] ,\u_eth2rf_processor/u_ddr3/rd_data[33] ,\u_eth2rf_processor/u_ddr3/rd_data[32] ,\u_eth2rf_processor/u_ddr3/rd_data[31] ,\u_eth2rf_processor/u_ddr3/rd_data[30] ,\u_eth2rf_processor/u_ddr3/rd_data[29] ,\u_eth2rf_processor/u_ddr3/rd_data[28] ,\u_eth2rf_processor/u_ddr3/rd_data[27] ,\u_eth2rf_processor/u_ddr3/rd_data[26] ,\u_eth2rf_processor/u_ddr3/rd_data[25] ,\u_eth2rf_processor/u_ddr3/rd_data[24] ,\u_eth2rf_processor/u_ddr3/rd_data[23] ,\u_eth2rf_processor/u_ddr3/rd_data[22] ,\u_eth2rf_processor/u_ddr3/rd_data[21] ,\u_eth2rf_processor/u_ddr3/rd_data[20] ,\u_eth2rf_processor/u_ddr3/rd_data[19] ,\u_eth2rf_processor/u_ddr3/rd_data[18] ,\u_eth2rf_processor/u_ddr3/rd_data[17] ,\u_eth2rf_processor/u_ddr3/rd_data[16] ,\u_eth2rf_processor/u_ddr3/rd_data[15] ,\u_eth2rf_processor/u_ddr3/rd_data[14] ,\u_eth2rf_processor/u_ddr3/rd_data[13] ,\u_eth2rf_processor/u_ddr3/rd_data[12] ,\u_eth2rf_processor/u_ddr3/rd_data[11] ,\u_eth2rf_processor/u_ddr3/rd_data[10] ,\u_eth2rf_processor/u_ddr3/rd_data[9] ,\u_eth2rf_processor/u_ddr3/rd_data[8] ,\u_eth2rf_processor/u_ddr3/rd_data[7] ,\u_eth2rf_processor/u_ddr3/rd_data[6] ,\u_eth2rf_processor/u_ddr3/rd_data[5] ,\u_eth2rf_processor/u_ddr3/rd_data[4] ,\u_eth2rf_processor/u_ddr3/rd_data[3] ,\u_eth2rf_processor/u_ddr3/rd_data[2] ,\u_eth2rf_processor/u_ddr3/rd_data[1] ,\u_eth2rf_processor/u_ddr3/rd_data[0] }),
    .clk_i(\u_eth2rf_processor/ddr_clk )
);

endmodule
