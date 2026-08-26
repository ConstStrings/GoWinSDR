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
    rst_n,
    \eth_transceiver_u/rx_state[3] ,
    \eth_transceiver_u/rx_state[2] ,
    \eth_transceiver_u/rx_state[1] ,
    \eth_transceiver_u/rx_state[0] ,
    \u_eth2rf_processor/rx_data_valid ,
    \u_rf2eth_processor/eth_tx_frame_start ,
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
input rst_n;
input \eth_transceiver_u/rx_state[3] ;
input \eth_transceiver_u/rx_state[2] ;
input \eth_transceiver_u/rx_state[1] ;
input \eth_transceiver_u/rx_state[0] ;
input \u_eth2rf_processor/rx_data_valid ;
input \u_rf2eth_processor/eth_tx_frame_start ;
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
wire rst_n;
wire \eth_transceiver_u/rx_state[3] ;
wire \eth_transceiver_u/rx_state[2] ;
wire \eth_transceiver_u/rx_state[1] ;
wire \eth_transceiver_u/rx_state[0] ;
wire \u_eth2rf_processor/rx_data_valid ;
wire \u_rf2eth_processor/eth_tx_frame_start ;
wire tms_pad_i;
wire tck_pad_i;
wire tdi_pad_i;
wire tdo_pad_o;
wire tms_i_c;
wire tck_i_c;
wire tdi_i_c;
wire tdo_o_c;
wire [9:0] control0;
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
    .enable_i(enable_er1),
    .shift_dr_capture_dr_i(shift_dr_capture_dr),
    .update_dr_i(update_dr)
);

ao_top_0  u_la0_top(
    .control(control0[9:0]),
    .trig0_i(rst_n),
    .trig1_i({\eth_transceiver_u/rx_state[3] ,\eth_transceiver_u/rx_state[2] ,\eth_transceiver_u/rx_state[1] ,\eth_transceiver_u/rx_state[0] }),
    .trig2_i(\u_eth2rf_processor/rx_data_valid ),
    .trig3_i(\u_rf2eth_processor/eth_tx_frame_start ),
    .data_i({\adc_data_out_i1[11] ,\adc_data_out_i1[10] ,\adc_data_out_i1[9] ,\adc_data_out_i1[8] ,\adc_data_out_i1[7] ,\adc_data_out_i1[6] ,\adc_data_out_i1[5] ,\adc_data_out_i1[4] ,\adc_data_out_i1[3] ,\adc_data_out_i1[2] ,\adc_data_out_i1[1] ,\adc_data_out_i1[0] ,\adc_data_out_q1[11] ,\adc_data_out_q1[10] ,\adc_data_out_q1[9] ,\adc_data_out_q1[8] ,\adc_data_out_q1[7] ,\adc_data_out_q1[6] ,\adc_data_out_q1[5] ,\adc_data_out_q1[4] ,\adc_data_out_q1[3] ,\adc_data_out_q1[2] ,\adc_data_out_q1[1] ,\adc_data_out_q1[0] ,\dac_data_out_i1[11] ,\dac_data_out_i1[10] ,\dac_data_out_i1[9] ,\dac_data_out_i1[8] ,\dac_data_out_i1[7] ,\dac_data_out_i1[6] ,\dac_data_out_i1[5] ,\dac_data_out_i1[4] ,\dac_data_out_i1[3] ,\dac_data_out_i1[2] ,\dac_data_out_i1[1] ,\dac_data_out_i1[0] ,\dac_data_out_q1[11] ,\dac_data_out_q1[10] ,\dac_data_out_q1[9] ,\dac_data_out_q1[8] ,\dac_data_out_q1[7] ,\dac_data_out_q1[6] ,\dac_data_out_q1[5] ,\dac_data_out_q1[4] ,\dac_data_out_q1[3] ,\dac_data_out_q1[2] ,\dac_data_out_q1[1] ,\dac_data_out_q1[0] ,bb_symbol_clk,data_clk,bb_byte_clk,rf_tx_ready,rf_tx_valid,\rf_tx_data[7] ,\rf_tx_data[6] ,\rf_tx_data[5] ,\rf_tx_data[4] ,\rf_tx_data[3] ,\rf_tx_data[2] ,\rf_tx_data[1] ,\rf_tx_data[0] ,\u_rf_process/gardner_sync_flag ,\u_rf_process/gardner_sync_I ,\u_rf_process/gardner_sync_Q ,\u_rf_process/dqpsk_rx_data[7] ,\u_rf_process/dqpsk_rx_data[6] ,\u_rf_process/dqpsk_rx_data[5] ,\u_rf_process/dqpsk_rx_data[4] ,\u_rf_process/dqpsk_rx_data[3] ,\u_rf_process/dqpsk_rx_data[2] ,\u_rf_process/dqpsk_rx_data[1] ,\u_rf_process/dqpsk_rx_data[0] ,\u_rf_process/u_rf_dqpsk_decoder/frame_aligned_data_dbg[7] ,\u_rf_process/u_rf_dqpsk_decoder/frame_aligned_data_dbg[6] ,\u_rf_process/u_rf_dqpsk_decoder/frame_aligned_data_dbg[5] ,\u_rf_process/u_rf_dqpsk_decoder/frame_aligned_data_dbg[4] ,\u_rf_process/u_rf_dqpsk_decoder/frame_aligned_data_dbg[3] ,\u_rf_process/u_rf_dqpsk_decoder/frame_aligned_data_dbg[2] ,\u_rf_process/u_rf_dqpsk_decoder/frame_aligned_data_dbg[1] ,\u_rf_process/u_rf_dqpsk_decoder/frame_aligned_data_dbg[0] ,\u_rf_process/u_rf_dqpsk_decoder/frame_head_found_dbg ,\u_rf_process/u_rf_dqpsk_decoder/deframe_state_dbg[1] ,\u_rf_process/u_rf_dqpsk_decoder/deframe_state_dbg[0] ,\u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[15] ,\u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[14] ,\u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[13] ,\u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[12] ,\u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[11] ,\u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[10] ,\u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[9] ,\u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[8] ,\u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[7] ,\u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[6] ,\u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[5] ,\u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[4] ,\u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[3] ,\u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[2] ,\u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[1] ,\u_rf_process/u_rf_dqpsk_decoder/payload_count_dbg[0] ,\u_rf_process/gardner_sync_u0/uk[15] ,\u_rf_process/gardner_sync_u0/uk[14] ,\u_rf_process/gardner_sync_u0/uk[13] ,\u_rf_process/gardner_sync_u0/uk[12] ,\u_rf_process/gardner_sync_u0/uk[11] ,\u_rf_process/gardner_sync_u0/uk[10] ,\u_rf_process/gardner_sync_u0/uk[9] ,\u_rf_process/gardner_sync_u0/uk[8] ,\u_rf_process/gardner_sync_u0/uk[7] ,\u_rf_process/gardner_sync_u0/uk[6] ,\u_rf_process/gardner_sync_u0/uk[5] ,\u_rf_process/gardner_sync_u0/uk[4] ,\u_rf_process/gardner_sync_u0/uk[3] ,\u_rf_process/gardner_sync_u0/uk[2] ,\u_rf_process/gardner_sync_u0/uk[1] ,\u_rf_process/gardner_sync_u0/uk[0] ,\u_rf_process/gardner_sync_u0/I_y[19] ,\u_rf_process/gardner_sync_u0/I_y[18] ,\u_rf_process/gardner_sync_u0/I_y[17] ,\u_rf_process/gardner_sync_u0/I_y[16] ,\u_rf_process/gardner_sync_u0/I_y[15] ,\u_rf_process/gardner_sync_u0/I_y[14] ,\u_rf_process/gardner_sync_u0/I_y[13] ,\u_rf_process/gardner_sync_u0/I_y[12] ,\u_rf_process/gardner_sync_u0/I_y[11] ,\u_rf_process/gardner_sync_u0/I_y[10] ,\u_rf_process/gardner_sync_u0/I_y[9] ,\u_rf_process/gardner_sync_u0/I_y[8] ,\u_rf_process/gardner_sync_u0/I_y[7] ,\u_rf_process/gardner_sync_u0/I_y[6] ,\u_rf_process/gardner_sync_u0/I_y[5] ,\u_rf_process/gardner_sync_u0/I_y[4] ,\u_rf_process/gardner_sync_u0/I_y[3] ,\u_rf_process/gardner_sync_u0/I_y[2] ,\u_rf_process/gardner_sync_u0/I_y[1] ,\u_rf_process/gardner_sync_u0/I_y[0] ,\u_rf_process/gardner_sync_u0/Q_y[19] ,\u_rf_process/gardner_sync_u0/Q_y[18] ,\u_rf_process/gardner_sync_u0/Q_y[17] ,\u_rf_process/gardner_sync_u0/Q_y[16] ,\u_rf_process/gardner_sync_u0/Q_y[15] ,\u_rf_process/gardner_sync_u0/Q_y[14] ,\u_rf_process/gardner_sync_u0/Q_y[13] ,\u_rf_process/gardner_sync_u0/Q_y[12] ,\u_rf_process/gardner_sync_u0/Q_y[11] ,\u_rf_process/gardner_sync_u0/Q_y[10] ,\u_rf_process/gardner_sync_u0/Q_y[9] ,\u_rf_process/gardner_sync_u0/Q_y[8] ,\u_rf_process/gardner_sync_u0/Q_y[7] ,\u_rf_process/gardner_sync_u0/Q_y[6] ,\u_rf_process/gardner_sync_u0/Q_y[5] ,\u_rf_process/gardner_sync_u0/Q_y[4] ,\u_rf_process/gardner_sync_u0/Q_y[3] ,\u_rf_process/gardner_sync_u0/Q_y[2] ,\u_rf_process/gardner_sync_u0/Q_y[1] ,\u_rf_process/gardner_sync_u0/Q_y[0] ,\u_rf_process/gardner_sync_u0/nco_strobe_flag ,\u_rf_process/gardner_sync_u0/ted_strobe_flag }),
    .clk_i(data_clk)
);

endmodule
