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
    \dac_data_in_i1[11] ,
    \dac_data_in_i1[10] ,
    \dac_data_in_i1[9] ,
    \dac_data_in_i1[8] ,
    \dac_data_in_i1[7] ,
    \dac_data_in_i1[6] ,
    \dac_data_in_i1[5] ,
    \dac_data_in_i1[4] ,
    \dac_data_in_i1[3] ,
    \dac_data_in_i1[2] ,
    \dac_data_in_i1[1] ,
    \dac_data_in_i1[0] ,
    \dac_data_in_q1[11] ,
    \dac_data_in_q1[10] ,
    \dac_data_in_q1[9] ,
    \dac_data_in_q1[8] ,
    \dac_data_in_q1[7] ,
    \dac_data_in_q1[6] ,
    \dac_data_in_q1[5] ,
    \dac_data_in_q1[4] ,
    \dac_data_in_q1[3] ,
    \dac_data_in_q1[2] ,
    \dac_data_in_q1[1] ,
    \dac_data_in_q1[0] ,
    data_clk,
    \eth_transceiver_u/tx_data[7] ,
    \eth_transceiver_u/tx_data[6] ,
    \eth_transceiver_u/tx_data[5] ,
    \eth_transceiver_u/tx_data[4] ,
    \eth_transceiver_u/tx_data[3] ,
    \eth_transceiver_u/tx_data[2] ,
    \eth_transceiver_u/tx_data[1] ,
    \eth_transceiver_u/tx_data[0] ,
    \eth_transceiver_u/rx_data[7] ,
    \eth_transceiver_u/rx_data[6] ,
    \eth_transceiver_u/rx_data[5] ,
    \eth_transceiver_u/rx_data[4] ,
    \eth_transceiver_u/rx_data[3] ,
    \eth_transceiver_u/rx_data[2] ,
    \eth_transceiver_u/rx_data[1] ,
    \eth_transceiver_u/rx_data[0] ,
    \eth_transceiver_u/rx_state[3] ,
    \eth_transceiver_u/rx_state[2] ,
    \eth_transceiver_u/rx_state[1] ,
    \eth_transceiver_u/rx_state[0] ,
    \eth_transceiver_u/rx_eth_type[15] ,
    \eth_transceiver_u/rx_eth_type[14] ,
    \eth_transceiver_u/rx_eth_type[13] ,
    \eth_transceiver_u/rx_eth_type[12] ,
    \eth_transceiver_u/rx_eth_type[11] ,
    \eth_transceiver_u/rx_eth_type[10] ,
    \eth_transceiver_u/rx_eth_type[9] ,
    \eth_transceiver_u/rx_eth_type[8] ,
    \eth_transceiver_u/rx_eth_type[7] ,
    \eth_transceiver_u/rx_eth_type[6] ,
    \eth_transceiver_u/rx_eth_type[5] ,
    \eth_transceiver_u/rx_eth_type[4] ,
    \eth_transceiver_u/rx_eth_type[3] ,
    \eth_transceiver_u/rx_eth_type[2] ,
    \eth_transceiver_u/rx_eth_type[1] ,
    \eth_transceiver_u/rx_eth_type[0] ,
    \eth_transceiver_u/rx_dest_mac[47] ,
    \eth_transceiver_u/rx_dest_mac[46] ,
    \eth_transceiver_u/rx_dest_mac[45] ,
    \eth_transceiver_u/rx_dest_mac[44] ,
    \eth_transceiver_u/rx_dest_mac[43] ,
    \eth_transceiver_u/rx_dest_mac[42] ,
    \eth_transceiver_u/rx_dest_mac[41] ,
    \eth_transceiver_u/rx_dest_mac[40] ,
    \eth_transceiver_u/rx_dest_mac[39] ,
    \eth_transceiver_u/rx_dest_mac[38] ,
    \eth_transceiver_u/rx_dest_mac[37] ,
    \eth_transceiver_u/rx_dest_mac[36] ,
    \eth_transceiver_u/rx_dest_mac[35] ,
    \eth_transceiver_u/rx_dest_mac[34] ,
    \eth_transceiver_u/rx_dest_mac[33] ,
    \eth_transceiver_u/rx_dest_mac[32] ,
    \eth_transceiver_u/rx_dest_mac[31] ,
    \eth_transceiver_u/rx_dest_mac[30] ,
    \eth_transceiver_u/rx_dest_mac[29] ,
    \eth_transceiver_u/rx_dest_mac[28] ,
    \eth_transceiver_u/rx_dest_mac[27] ,
    \eth_transceiver_u/rx_dest_mac[26] ,
    \eth_transceiver_u/rx_dest_mac[25] ,
    \eth_transceiver_u/rx_dest_mac[24] ,
    \eth_transceiver_u/rx_dest_mac[23] ,
    \eth_transceiver_u/rx_dest_mac[22] ,
    \eth_transceiver_u/rx_dest_mac[21] ,
    \eth_transceiver_u/rx_dest_mac[20] ,
    \eth_transceiver_u/rx_dest_mac[19] ,
    \eth_transceiver_u/rx_dest_mac[18] ,
    \eth_transceiver_u/rx_dest_mac[17] ,
    \eth_transceiver_u/rx_dest_mac[16] ,
    \eth_transceiver_u/rx_dest_mac[15] ,
    \eth_transceiver_u/rx_dest_mac[14] ,
    \eth_transceiver_u/rx_dest_mac[13] ,
    \eth_transceiver_u/rx_dest_mac[12] ,
    \eth_transceiver_u/rx_dest_mac[11] ,
    \eth_transceiver_u/rx_dest_mac[10] ,
    \eth_transceiver_u/rx_dest_mac[9] ,
    \eth_transceiver_u/rx_dest_mac[8] ,
    \eth_transceiver_u/rx_dest_mac[7] ,
    \eth_transceiver_u/rx_dest_mac[6] ,
    \eth_transceiver_u/rx_dest_mac[5] ,
    \eth_transceiver_u/rx_dest_mac[4] ,
    \eth_transceiver_u/rx_dest_mac[3] ,
    \eth_transceiver_u/rx_dest_mac[2] ,
    \eth_transceiver_u/rx_dest_mac[1] ,
    \eth_transceiver_u/rx_dest_mac[0] ,
    \RGMII_RXD[3] ,
    \RGMII_RXD[2] ,
    \RGMII_RXD[1] ,
    \RGMII_RXD[0] ,
    \eth_transceiver_u/rgmii_rxd_ddr[7] ,
    \eth_transceiver_u/rgmii_rxd_ddr[6] ,
    \eth_transceiver_u/rgmii_rxd_ddr[5] ,
    \eth_transceiver_u/rgmii_rxd_ddr[4] ,
    \eth_transceiver_u/rgmii_rxd_ddr[3] ,
    \eth_transceiver_u/rgmii_rxd_ddr[2] ,
    \eth_transceiver_u/rgmii_rxd_ddr[1] ,
    \eth_transceiver_u/rgmii_rxd_ddr[0] ,
    \eth_transceiver_u/rgmii_rx_ctl_ddr[1] ,
    \eth_transceiver_u/rgmii_rx_ctl_ddr[0] ,
    \eth_transceiver_u/gmii_rxd[7] ,
    \eth_transceiver_u/gmii_rxd[6] ,
    \eth_transceiver_u/gmii_rxd[5] ,
    \eth_transceiver_u/gmii_rxd[4] ,
    \eth_transceiver_u/gmii_rxd[3] ,
    \eth_transceiver_u/gmii_rxd[2] ,
    \eth_transceiver_u/gmii_rxd[1] ,
    \eth_transceiver_u/gmii_rxd[0] ,
    \eth_transceiver_u/rx_cnt[15] ,
    \eth_transceiver_u/rx_cnt[14] ,
    \eth_transceiver_u/rx_cnt[13] ,
    \eth_transceiver_u/rx_cnt[12] ,
    \eth_transceiver_u/rx_cnt[11] ,
    \eth_transceiver_u/rx_cnt[10] ,
    \eth_transceiver_u/rx_cnt[9] ,
    \eth_transceiver_u/rx_cnt[8] ,
    \eth_transceiver_u/rx_cnt[7] ,
    \eth_transceiver_u/rx_cnt[6] ,
    \eth_transceiver_u/rx_cnt[5] ,
    \eth_transceiver_u/rx_cnt[4] ,
    \eth_transceiver_u/rx_cnt[3] ,
    \eth_transceiver_u/rx_cnt[2] ,
    \eth_transceiver_u/rx_cnt[1] ,
    \eth_transceiver_u/rx_cnt[0] ,
    RGMII_RXDV,
    \eth_transceiver_u/gmii_rxdv ,
    \eth_transceiver_u/gmii_rxer ,
    \eth_transceiver_u/gmii_txd[7] ,
    \eth_transceiver_u/gmii_txd[6] ,
    \eth_transceiver_u/gmii_txd[5] ,
    \eth_transceiver_u/gmii_txd[4] ,
    \eth_transceiver_u/gmii_txd[3] ,
    \eth_transceiver_u/gmii_txd[2] ,
    \eth_transceiver_u/gmii_txd[1] ,
    \eth_transceiver_u/gmii_txd[0] ,
    \eth_transceiver_u/tx_state[3] ,
    \eth_transceiver_u/tx_state[2] ,
    \eth_transceiver_u/tx_state[1] ,
    \eth_transceiver_u/tx_state[0] ,
    \eth_transceiver_u/tx_buf_len[15] ,
    \eth_transceiver_u/tx_buf_len[14] ,
    \eth_transceiver_u/tx_buf_len[13] ,
    \eth_transceiver_u/tx_buf_len[12] ,
    \eth_transceiver_u/tx_buf_len[11] ,
    \eth_transceiver_u/tx_buf_len[10] ,
    \eth_transceiver_u/tx_buf_len[9] ,
    \eth_transceiver_u/tx_buf_len[8] ,
    \eth_transceiver_u/tx_buf_len[7] ,
    \eth_transceiver_u/tx_buf_len[6] ,
    \eth_transceiver_u/tx_buf_len[5] ,
    \eth_transceiver_u/tx_buf_len[4] ,
    \eth_transceiver_u/tx_buf_len[3] ,
    \eth_transceiver_u/tx_buf_len[2] ,
    \eth_transceiver_u/tx_buf_len[1] ,
    \eth_transceiver_u/tx_buf_len[0] ,
    \eth_transceiver_u/tx_cnt[15] ,
    \eth_transceiver_u/tx_cnt[14] ,
    \eth_transceiver_u/tx_cnt[13] ,
    \eth_transceiver_u/tx_cnt[12] ,
    \eth_transceiver_u/tx_cnt[11] ,
    \eth_transceiver_u/tx_cnt[10] ,
    \eth_transceiver_u/tx_cnt[9] ,
    \eth_transceiver_u/tx_cnt[8] ,
    \eth_transceiver_u/tx_cnt[7] ,
    \eth_transceiver_u/tx_cnt[6] ,
    \eth_transceiver_u/tx_cnt[5] ,
    \eth_transceiver_u/tx_cnt[4] ,
    \eth_transceiver_u/tx_cnt[3] ,
    \eth_transceiver_u/tx_cnt[2] ,
    \eth_transceiver_u/tx_cnt[1] ,
    \eth_transceiver_u/tx_cnt[0] ,
    rst_n,
    \eth_transceiver_u/clk_125m ,
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
input \dac_data_in_i1[11] ;
input \dac_data_in_i1[10] ;
input \dac_data_in_i1[9] ;
input \dac_data_in_i1[8] ;
input \dac_data_in_i1[7] ;
input \dac_data_in_i1[6] ;
input \dac_data_in_i1[5] ;
input \dac_data_in_i1[4] ;
input \dac_data_in_i1[3] ;
input \dac_data_in_i1[2] ;
input \dac_data_in_i1[1] ;
input \dac_data_in_i1[0] ;
input \dac_data_in_q1[11] ;
input \dac_data_in_q1[10] ;
input \dac_data_in_q1[9] ;
input \dac_data_in_q1[8] ;
input \dac_data_in_q1[7] ;
input \dac_data_in_q1[6] ;
input \dac_data_in_q1[5] ;
input \dac_data_in_q1[4] ;
input \dac_data_in_q1[3] ;
input \dac_data_in_q1[2] ;
input \dac_data_in_q1[1] ;
input \dac_data_in_q1[0] ;
input data_clk;
input \eth_transceiver_u/tx_data[7] ;
input \eth_transceiver_u/tx_data[6] ;
input \eth_transceiver_u/tx_data[5] ;
input \eth_transceiver_u/tx_data[4] ;
input \eth_transceiver_u/tx_data[3] ;
input \eth_transceiver_u/tx_data[2] ;
input \eth_transceiver_u/tx_data[1] ;
input \eth_transceiver_u/tx_data[0] ;
input \eth_transceiver_u/rx_data[7] ;
input \eth_transceiver_u/rx_data[6] ;
input \eth_transceiver_u/rx_data[5] ;
input \eth_transceiver_u/rx_data[4] ;
input \eth_transceiver_u/rx_data[3] ;
input \eth_transceiver_u/rx_data[2] ;
input \eth_transceiver_u/rx_data[1] ;
input \eth_transceiver_u/rx_data[0] ;
input \eth_transceiver_u/rx_state[3] ;
input \eth_transceiver_u/rx_state[2] ;
input \eth_transceiver_u/rx_state[1] ;
input \eth_transceiver_u/rx_state[0] ;
input \eth_transceiver_u/rx_eth_type[15] ;
input \eth_transceiver_u/rx_eth_type[14] ;
input \eth_transceiver_u/rx_eth_type[13] ;
input \eth_transceiver_u/rx_eth_type[12] ;
input \eth_transceiver_u/rx_eth_type[11] ;
input \eth_transceiver_u/rx_eth_type[10] ;
input \eth_transceiver_u/rx_eth_type[9] ;
input \eth_transceiver_u/rx_eth_type[8] ;
input \eth_transceiver_u/rx_eth_type[7] ;
input \eth_transceiver_u/rx_eth_type[6] ;
input \eth_transceiver_u/rx_eth_type[5] ;
input \eth_transceiver_u/rx_eth_type[4] ;
input \eth_transceiver_u/rx_eth_type[3] ;
input \eth_transceiver_u/rx_eth_type[2] ;
input \eth_transceiver_u/rx_eth_type[1] ;
input \eth_transceiver_u/rx_eth_type[0] ;
input \eth_transceiver_u/rx_dest_mac[47] ;
input \eth_transceiver_u/rx_dest_mac[46] ;
input \eth_transceiver_u/rx_dest_mac[45] ;
input \eth_transceiver_u/rx_dest_mac[44] ;
input \eth_transceiver_u/rx_dest_mac[43] ;
input \eth_transceiver_u/rx_dest_mac[42] ;
input \eth_transceiver_u/rx_dest_mac[41] ;
input \eth_transceiver_u/rx_dest_mac[40] ;
input \eth_transceiver_u/rx_dest_mac[39] ;
input \eth_transceiver_u/rx_dest_mac[38] ;
input \eth_transceiver_u/rx_dest_mac[37] ;
input \eth_transceiver_u/rx_dest_mac[36] ;
input \eth_transceiver_u/rx_dest_mac[35] ;
input \eth_transceiver_u/rx_dest_mac[34] ;
input \eth_transceiver_u/rx_dest_mac[33] ;
input \eth_transceiver_u/rx_dest_mac[32] ;
input \eth_transceiver_u/rx_dest_mac[31] ;
input \eth_transceiver_u/rx_dest_mac[30] ;
input \eth_transceiver_u/rx_dest_mac[29] ;
input \eth_transceiver_u/rx_dest_mac[28] ;
input \eth_transceiver_u/rx_dest_mac[27] ;
input \eth_transceiver_u/rx_dest_mac[26] ;
input \eth_transceiver_u/rx_dest_mac[25] ;
input \eth_transceiver_u/rx_dest_mac[24] ;
input \eth_transceiver_u/rx_dest_mac[23] ;
input \eth_transceiver_u/rx_dest_mac[22] ;
input \eth_transceiver_u/rx_dest_mac[21] ;
input \eth_transceiver_u/rx_dest_mac[20] ;
input \eth_transceiver_u/rx_dest_mac[19] ;
input \eth_transceiver_u/rx_dest_mac[18] ;
input \eth_transceiver_u/rx_dest_mac[17] ;
input \eth_transceiver_u/rx_dest_mac[16] ;
input \eth_transceiver_u/rx_dest_mac[15] ;
input \eth_transceiver_u/rx_dest_mac[14] ;
input \eth_transceiver_u/rx_dest_mac[13] ;
input \eth_transceiver_u/rx_dest_mac[12] ;
input \eth_transceiver_u/rx_dest_mac[11] ;
input \eth_transceiver_u/rx_dest_mac[10] ;
input \eth_transceiver_u/rx_dest_mac[9] ;
input \eth_transceiver_u/rx_dest_mac[8] ;
input \eth_transceiver_u/rx_dest_mac[7] ;
input \eth_transceiver_u/rx_dest_mac[6] ;
input \eth_transceiver_u/rx_dest_mac[5] ;
input \eth_transceiver_u/rx_dest_mac[4] ;
input \eth_transceiver_u/rx_dest_mac[3] ;
input \eth_transceiver_u/rx_dest_mac[2] ;
input \eth_transceiver_u/rx_dest_mac[1] ;
input \eth_transceiver_u/rx_dest_mac[0] ;
input \RGMII_RXD[3] ;
input \RGMII_RXD[2] ;
input \RGMII_RXD[1] ;
input \RGMII_RXD[0] ;
input \eth_transceiver_u/rgmii_rxd_ddr[7] ;
input \eth_transceiver_u/rgmii_rxd_ddr[6] ;
input \eth_transceiver_u/rgmii_rxd_ddr[5] ;
input \eth_transceiver_u/rgmii_rxd_ddr[4] ;
input \eth_transceiver_u/rgmii_rxd_ddr[3] ;
input \eth_transceiver_u/rgmii_rxd_ddr[2] ;
input \eth_transceiver_u/rgmii_rxd_ddr[1] ;
input \eth_transceiver_u/rgmii_rxd_ddr[0] ;
input \eth_transceiver_u/rgmii_rx_ctl_ddr[1] ;
input \eth_transceiver_u/rgmii_rx_ctl_ddr[0] ;
input \eth_transceiver_u/gmii_rxd[7] ;
input \eth_transceiver_u/gmii_rxd[6] ;
input \eth_transceiver_u/gmii_rxd[5] ;
input \eth_transceiver_u/gmii_rxd[4] ;
input \eth_transceiver_u/gmii_rxd[3] ;
input \eth_transceiver_u/gmii_rxd[2] ;
input \eth_transceiver_u/gmii_rxd[1] ;
input \eth_transceiver_u/gmii_rxd[0] ;
input \eth_transceiver_u/rx_cnt[15] ;
input \eth_transceiver_u/rx_cnt[14] ;
input \eth_transceiver_u/rx_cnt[13] ;
input \eth_transceiver_u/rx_cnt[12] ;
input \eth_transceiver_u/rx_cnt[11] ;
input \eth_transceiver_u/rx_cnt[10] ;
input \eth_transceiver_u/rx_cnt[9] ;
input \eth_transceiver_u/rx_cnt[8] ;
input \eth_transceiver_u/rx_cnt[7] ;
input \eth_transceiver_u/rx_cnt[6] ;
input \eth_transceiver_u/rx_cnt[5] ;
input \eth_transceiver_u/rx_cnt[4] ;
input \eth_transceiver_u/rx_cnt[3] ;
input \eth_transceiver_u/rx_cnt[2] ;
input \eth_transceiver_u/rx_cnt[1] ;
input \eth_transceiver_u/rx_cnt[0] ;
input RGMII_RXDV;
input \eth_transceiver_u/gmii_rxdv ;
input \eth_transceiver_u/gmii_rxer ;
input \eth_transceiver_u/gmii_txd[7] ;
input \eth_transceiver_u/gmii_txd[6] ;
input \eth_transceiver_u/gmii_txd[5] ;
input \eth_transceiver_u/gmii_txd[4] ;
input \eth_transceiver_u/gmii_txd[3] ;
input \eth_transceiver_u/gmii_txd[2] ;
input \eth_transceiver_u/gmii_txd[1] ;
input \eth_transceiver_u/gmii_txd[0] ;
input \eth_transceiver_u/tx_state[3] ;
input \eth_transceiver_u/tx_state[2] ;
input \eth_transceiver_u/tx_state[1] ;
input \eth_transceiver_u/tx_state[0] ;
input \eth_transceiver_u/tx_buf_len[15] ;
input \eth_transceiver_u/tx_buf_len[14] ;
input \eth_transceiver_u/tx_buf_len[13] ;
input \eth_transceiver_u/tx_buf_len[12] ;
input \eth_transceiver_u/tx_buf_len[11] ;
input \eth_transceiver_u/tx_buf_len[10] ;
input \eth_transceiver_u/tx_buf_len[9] ;
input \eth_transceiver_u/tx_buf_len[8] ;
input \eth_transceiver_u/tx_buf_len[7] ;
input \eth_transceiver_u/tx_buf_len[6] ;
input \eth_transceiver_u/tx_buf_len[5] ;
input \eth_transceiver_u/tx_buf_len[4] ;
input \eth_transceiver_u/tx_buf_len[3] ;
input \eth_transceiver_u/tx_buf_len[2] ;
input \eth_transceiver_u/tx_buf_len[1] ;
input \eth_transceiver_u/tx_buf_len[0] ;
input \eth_transceiver_u/tx_cnt[15] ;
input \eth_transceiver_u/tx_cnt[14] ;
input \eth_transceiver_u/tx_cnt[13] ;
input \eth_transceiver_u/tx_cnt[12] ;
input \eth_transceiver_u/tx_cnt[11] ;
input \eth_transceiver_u/tx_cnt[10] ;
input \eth_transceiver_u/tx_cnt[9] ;
input \eth_transceiver_u/tx_cnt[8] ;
input \eth_transceiver_u/tx_cnt[7] ;
input \eth_transceiver_u/tx_cnt[6] ;
input \eth_transceiver_u/tx_cnt[5] ;
input \eth_transceiver_u/tx_cnt[4] ;
input \eth_transceiver_u/tx_cnt[3] ;
input \eth_transceiver_u/tx_cnt[2] ;
input \eth_transceiver_u/tx_cnt[1] ;
input \eth_transceiver_u/tx_cnt[0] ;
input rst_n;
input \eth_transceiver_u/clk_125m ;
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
wire \dac_data_in_i1[11] ;
wire \dac_data_in_i1[10] ;
wire \dac_data_in_i1[9] ;
wire \dac_data_in_i1[8] ;
wire \dac_data_in_i1[7] ;
wire \dac_data_in_i1[6] ;
wire \dac_data_in_i1[5] ;
wire \dac_data_in_i1[4] ;
wire \dac_data_in_i1[3] ;
wire \dac_data_in_i1[2] ;
wire \dac_data_in_i1[1] ;
wire \dac_data_in_i1[0] ;
wire \dac_data_in_q1[11] ;
wire \dac_data_in_q1[10] ;
wire \dac_data_in_q1[9] ;
wire \dac_data_in_q1[8] ;
wire \dac_data_in_q1[7] ;
wire \dac_data_in_q1[6] ;
wire \dac_data_in_q1[5] ;
wire \dac_data_in_q1[4] ;
wire \dac_data_in_q1[3] ;
wire \dac_data_in_q1[2] ;
wire \dac_data_in_q1[1] ;
wire \dac_data_in_q1[0] ;
wire data_clk;
wire \eth_transceiver_u/tx_data[7] ;
wire \eth_transceiver_u/tx_data[6] ;
wire \eth_transceiver_u/tx_data[5] ;
wire \eth_transceiver_u/tx_data[4] ;
wire \eth_transceiver_u/tx_data[3] ;
wire \eth_transceiver_u/tx_data[2] ;
wire \eth_transceiver_u/tx_data[1] ;
wire \eth_transceiver_u/tx_data[0] ;
wire \eth_transceiver_u/rx_data[7] ;
wire \eth_transceiver_u/rx_data[6] ;
wire \eth_transceiver_u/rx_data[5] ;
wire \eth_transceiver_u/rx_data[4] ;
wire \eth_transceiver_u/rx_data[3] ;
wire \eth_transceiver_u/rx_data[2] ;
wire \eth_transceiver_u/rx_data[1] ;
wire \eth_transceiver_u/rx_data[0] ;
wire \eth_transceiver_u/rx_state[3] ;
wire \eth_transceiver_u/rx_state[2] ;
wire \eth_transceiver_u/rx_state[1] ;
wire \eth_transceiver_u/rx_state[0] ;
wire \eth_transceiver_u/rx_eth_type[15] ;
wire \eth_transceiver_u/rx_eth_type[14] ;
wire \eth_transceiver_u/rx_eth_type[13] ;
wire \eth_transceiver_u/rx_eth_type[12] ;
wire \eth_transceiver_u/rx_eth_type[11] ;
wire \eth_transceiver_u/rx_eth_type[10] ;
wire \eth_transceiver_u/rx_eth_type[9] ;
wire \eth_transceiver_u/rx_eth_type[8] ;
wire \eth_transceiver_u/rx_eth_type[7] ;
wire \eth_transceiver_u/rx_eth_type[6] ;
wire \eth_transceiver_u/rx_eth_type[5] ;
wire \eth_transceiver_u/rx_eth_type[4] ;
wire \eth_transceiver_u/rx_eth_type[3] ;
wire \eth_transceiver_u/rx_eth_type[2] ;
wire \eth_transceiver_u/rx_eth_type[1] ;
wire \eth_transceiver_u/rx_eth_type[0] ;
wire \eth_transceiver_u/rx_dest_mac[47] ;
wire \eth_transceiver_u/rx_dest_mac[46] ;
wire \eth_transceiver_u/rx_dest_mac[45] ;
wire \eth_transceiver_u/rx_dest_mac[44] ;
wire \eth_transceiver_u/rx_dest_mac[43] ;
wire \eth_transceiver_u/rx_dest_mac[42] ;
wire \eth_transceiver_u/rx_dest_mac[41] ;
wire \eth_transceiver_u/rx_dest_mac[40] ;
wire \eth_transceiver_u/rx_dest_mac[39] ;
wire \eth_transceiver_u/rx_dest_mac[38] ;
wire \eth_transceiver_u/rx_dest_mac[37] ;
wire \eth_transceiver_u/rx_dest_mac[36] ;
wire \eth_transceiver_u/rx_dest_mac[35] ;
wire \eth_transceiver_u/rx_dest_mac[34] ;
wire \eth_transceiver_u/rx_dest_mac[33] ;
wire \eth_transceiver_u/rx_dest_mac[32] ;
wire \eth_transceiver_u/rx_dest_mac[31] ;
wire \eth_transceiver_u/rx_dest_mac[30] ;
wire \eth_transceiver_u/rx_dest_mac[29] ;
wire \eth_transceiver_u/rx_dest_mac[28] ;
wire \eth_transceiver_u/rx_dest_mac[27] ;
wire \eth_transceiver_u/rx_dest_mac[26] ;
wire \eth_transceiver_u/rx_dest_mac[25] ;
wire \eth_transceiver_u/rx_dest_mac[24] ;
wire \eth_transceiver_u/rx_dest_mac[23] ;
wire \eth_transceiver_u/rx_dest_mac[22] ;
wire \eth_transceiver_u/rx_dest_mac[21] ;
wire \eth_transceiver_u/rx_dest_mac[20] ;
wire \eth_transceiver_u/rx_dest_mac[19] ;
wire \eth_transceiver_u/rx_dest_mac[18] ;
wire \eth_transceiver_u/rx_dest_mac[17] ;
wire \eth_transceiver_u/rx_dest_mac[16] ;
wire \eth_transceiver_u/rx_dest_mac[15] ;
wire \eth_transceiver_u/rx_dest_mac[14] ;
wire \eth_transceiver_u/rx_dest_mac[13] ;
wire \eth_transceiver_u/rx_dest_mac[12] ;
wire \eth_transceiver_u/rx_dest_mac[11] ;
wire \eth_transceiver_u/rx_dest_mac[10] ;
wire \eth_transceiver_u/rx_dest_mac[9] ;
wire \eth_transceiver_u/rx_dest_mac[8] ;
wire \eth_transceiver_u/rx_dest_mac[7] ;
wire \eth_transceiver_u/rx_dest_mac[6] ;
wire \eth_transceiver_u/rx_dest_mac[5] ;
wire \eth_transceiver_u/rx_dest_mac[4] ;
wire \eth_transceiver_u/rx_dest_mac[3] ;
wire \eth_transceiver_u/rx_dest_mac[2] ;
wire \eth_transceiver_u/rx_dest_mac[1] ;
wire \eth_transceiver_u/rx_dest_mac[0] ;
wire \RGMII_RXD[3] ;
wire \RGMII_RXD[2] ;
wire \RGMII_RXD[1] ;
wire \RGMII_RXD[0] ;
wire \eth_transceiver_u/rgmii_rxd_ddr[7] ;
wire \eth_transceiver_u/rgmii_rxd_ddr[6] ;
wire \eth_transceiver_u/rgmii_rxd_ddr[5] ;
wire \eth_transceiver_u/rgmii_rxd_ddr[4] ;
wire \eth_transceiver_u/rgmii_rxd_ddr[3] ;
wire \eth_transceiver_u/rgmii_rxd_ddr[2] ;
wire \eth_transceiver_u/rgmii_rxd_ddr[1] ;
wire \eth_transceiver_u/rgmii_rxd_ddr[0] ;
wire \eth_transceiver_u/rgmii_rx_ctl_ddr[1] ;
wire \eth_transceiver_u/rgmii_rx_ctl_ddr[0] ;
wire \eth_transceiver_u/gmii_rxd[7] ;
wire \eth_transceiver_u/gmii_rxd[6] ;
wire \eth_transceiver_u/gmii_rxd[5] ;
wire \eth_transceiver_u/gmii_rxd[4] ;
wire \eth_transceiver_u/gmii_rxd[3] ;
wire \eth_transceiver_u/gmii_rxd[2] ;
wire \eth_transceiver_u/gmii_rxd[1] ;
wire \eth_transceiver_u/gmii_rxd[0] ;
wire \eth_transceiver_u/rx_cnt[15] ;
wire \eth_transceiver_u/rx_cnt[14] ;
wire \eth_transceiver_u/rx_cnt[13] ;
wire \eth_transceiver_u/rx_cnt[12] ;
wire \eth_transceiver_u/rx_cnt[11] ;
wire \eth_transceiver_u/rx_cnt[10] ;
wire \eth_transceiver_u/rx_cnt[9] ;
wire \eth_transceiver_u/rx_cnt[8] ;
wire \eth_transceiver_u/rx_cnt[7] ;
wire \eth_transceiver_u/rx_cnt[6] ;
wire \eth_transceiver_u/rx_cnt[5] ;
wire \eth_transceiver_u/rx_cnt[4] ;
wire \eth_transceiver_u/rx_cnt[3] ;
wire \eth_transceiver_u/rx_cnt[2] ;
wire \eth_transceiver_u/rx_cnt[1] ;
wire \eth_transceiver_u/rx_cnt[0] ;
wire RGMII_RXDV;
wire \eth_transceiver_u/gmii_rxdv ;
wire \eth_transceiver_u/gmii_rxer ;
wire \eth_transceiver_u/gmii_txd[7] ;
wire \eth_transceiver_u/gmii_txd[6] ;
wire \eth_transceiver_u/gmii_txd[5] ;
wire \eth_transceiver_u/gmii_txd[4] ;
wire \eth_transceiver_u/gmii_txd[3] ;
wire \eth_transceiver_u/gmii_txd[2] ;
wire \eth_transceiver_u/gmii_txd[1] ;
wire \eth_transceiver_u/gmii_txd[0] ;
wire \eth_transceiver_u/tx_state[3] ;
wire \eth_transceiver_u/tx_state[2] ;
wire \eth_transceiver_u/tx_state[1] ;
wire \eth_transceiver_u/tx_state[0] ;
wire \eth_transceiver_u/tx_buf_len[15] ;
wire \eth_transceiver_u/tx_buf_len[14] ;
wire \eth_transceiver_u/tx_buf_len[13] ;
wire \eth_transceiver_u/tx_buf_len[12] ;
wire \eth_transceiver_u/tx_buf_len[11] ;
wire \eth_transceiver_u/tx_buf_len[10] ;
wire \eth_transceiver_u/tx_buf_len[9] ;
wire \eth_transceiver_u/tx_buf_len[8] ;
wire \eth_transceiver_u/tx_buf_len[7] ;
wire \eth_transceiver_u/tx_buf_len[6] ;
wire \eth_transceiver_u/tx_buf_len[5] ;
wire \eth_transceiver_u/tx_buf_len[4] ;
wire \eth_transceiver_u/tx_buf_len[3] ;
wire \eth_transceiver_u/tx_buf_len[2] ;
wire \eth_transceiver_u/tx_buf_len[1] ;
wire \eth_transceiver_u/tx_buf_len[0] ;
wire \eth_transceiver_u/tx_cnt[15] ;
wire \eth_transceiver_u/tx_cnt[14] ;
wire \eth_transceiver_u/tx_cnt[13] ;
wire \eth_transceiver_u/tx_cnt[12] ;
wire \eth_transceiver_u/tx_cnt[11] ;
wire \eth_transceiver_u/tx_cnt[10] ;
wire \eth_transceiver_u/tx_cnt[9] ;
wire \eth_transceiver_u/tx_cnt[8] ;
wire \eth_transceiver_u/tx_cnt[7] ;
wire \eth_transceiver_u/tx_cnt[6] ;
wire \eth_transceiver_u/tx_cnt[5] ;
wire \eth_transceiver_u/tx_cnt[4] ;
wire \eth_transceiver_u/tx_cnt[3] ;
wire \eth_transceiver_u/tx_cnt[2] ;
wire \eth_transceiver_u/tx_cnt[1] ;
wire \eth_transceiver_u/tx_cnt[0] ;
wire rst_n;
wire \eth_transceiver_u/clk_125m ;
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
    .data_i({\adc_data_out_i1[11] ,\adc_data_out_i1[10] ,\adc_data_out_i1[9] ,\adc_data_out_i1[8] ,\adc_data_out_i1[7] ,\adc_data_out_i1[6] ,\adc_data_out_i1[5] ,\adc_data_out_i1[4] ,\adc_data_out_i1[3] ,\adc_data_out_i1[2] ,\adc_data_out_i1[1] ,\adc_data_out_i1[0] ,\adc_data_out_q1[11] ,\adc_data_out_q1[10] ,\adc_data_out_q1[9] ,\adc_data_out_q1[8] ,\adc_data_out_q1[7] ,\adc_data_out_q1[6] ,\adc_data_out_q1[5] ,\adc_data_out_q1[4] ,\adc_data_out_q1[3] ,\adc_data_out_q1[2] ,\adc_data_out_q1[1] ,\adc_data_out_q1[0] ,\dac_data_in_i1[11] ,\dac_data_in_i1[10] ,\dac_data_in_i1[9] ,\dac_data_in_i1[8] ,\dac_data_in_i1[7] ,\dac_data_in_i1[6] ,\dac_data_in_i1[5] ,\dac_data_in_i1[4] ,\dac_data_in_i1[3] ,\dac_data_in_i1[2] ,\dac_data_in_i1[1] ,\dac_data_in_i1[0] ,\dac_data_in_q1[11] ,\dac_data_in_q1[10] ,\dac_data_in_q1[9] ,\dac_data_in_q1[8] ,\dac_data_in_q1[7] ,\dac_data_in_q1[6] ,\dac_data_in_q1[5] ,\dac_data_in_q1[4] ,\dac_data_in_q1[3] ,\dac_data_in_q1[2] ,\dac_data_in_q1[1] ,\dac_data_in_q1[0] ,data_clk,\eth_transceiver_u/tx_data[7] ,\eth_transceiver_u/tx_data[6] ,\eth_transceiver_u/tx_data[5] ,\eth_transceiver_u/tx_data[4] ,\eth_transceiver_u/tx_data[3] ,\eth_transceiver_u/tx_data[2] ,\eth_transceiver_u/tx_data[1] ,\eth_transceiver_u/tx_data[0] ,\eth_transceiver_u/rx_data[7] ,\eth_transceiver_u/rx_data[6] ,\eth_transceiver_u/rx_data[5] ,\eth_transceiver_u/rx_data[4] ,\eth_transceiver_u/rx_data[3] ,\eth_transceiver_u/rx_data[2] ,\eth_transceiver_u/rx_data[1] ,\eth_transceiver_u/rx_data[0] ,\eth_transceiver_u/rx_state[3] ,\eth_transceiver_u/rx_state[2] ,\eth_transceiver_u/rx_state[1] ,\eth_transceiver_u/rx_state[0] ,\eth_transceiver_u/rx_eth_type[15] ,\eth_transceiver_u/rx_eth_type[14] ,\eth_transceiver_u/rx_eth_type[13] ,\eth_transceiver_u/rx_eth_type[12] ,\eth_transceiver_u/rx_eth_type[11] ,\eth_transceiver_u/rx_eth_type[10] ,\eth_transceiver_u/rx_eth_type[9] ,\eth_transceiver_u/rx_eth_type[8] ,\eth_transceiver_u/rx_eth_type[7] ,\eth_transceiver_u/rx_eth_type[6] ,\eth_transceiver_u/rx_eth_type[5] ,\eth_transceiver_u/rx_eth_type[4] ,\eth_transceiver_u/rx_eth_type[3] ,\eth_transceiver_u/rx_eth_type[2] ,\eth_transceiver_u/rx_eth_type[1] ,\eth_transceiver_u/rx_eth_type[0] ,\eth_transceiver_u/rx_dest_mac[47] ,\eth_transceiver_u/rx_dest_mac[46] ,\eth_transceiver_u/rx_dest_mac[45] ,\eth_transceiver_u/rx_dest_mac[44] ,\eth_transceiver_u/rx_dest_mac[43] ,\eth_transceiver_u/rx_dest_mac[42] ,\eth_transceiver_u/rx_dest_mac[41] ,\eth_transceiver_u/rx_dest_mac[40] ,\eth_transceiver_u/rx_dest_mac[39] ,\eth_transceiver_u/rx_dest_mac[38] ,\eth_transceiver_u/rx_dest_mac[37] ,\eth_transceiver_u/rx_dest_mac[36] ,\eth_transceiver_u/rx_dest_mac[35] ,\eth_transceiver_u/rx_dest_mac[34] ,\eth_transceiver_u/rx_dest_mac[33] ,\eth_transceiver_u/rx_dest_mac[32] ,\eth_transceiver_u/rx_dest_mac[31] ,\eth_transceiver_u/rx_dest_mac[30] ,\eth_transceiver_u/rx_dest_mac[29] ,\eth_transceiver_u/rx_dest_mac[28] ,\eth_transceiver_u/rx_dest_mac[27] ,\eth_transceiver_u/rx_dest_mac[26] ,\eth_transceiver_u/rx_dest_mac[25] ,\eth_transceiver_u/rx_dest_mac[24] ,\eth_transceiver_u/rx_dest_mac[23] ,\eth_transceiver_u/rx_dest_mac[22] ,\eth_transceiver_u/rx_dest_mac[21] ,\eth_transceiver_u/rx_dest_mac[20] ,\eth_transceiver_u/rx_dest_mac[19] ,\eth_transceiver_u/rx_dest_mac[18] ,\eth_transceiver_u/rx_dest_mac[17] ,\eth_transceiver_u/rx_dest_mac[16] ,\eth_transceiver_u/rx_dest_mac[15] ,\eth_transceiver_u/rx_dest_mac[14] ,\eth_transceiver_u/rx_dest_mac[13] ,\eth_transceiver_u/rx_dest_mac[12] ,\eth_transceiver_u/rx_dest_mac[11] ,\eth_transceiver_u/rx_dest_mac[10] ,\eth_transceiver_u/rx_dest_mac[9] ,\eth_transceiver_u/rx_dest_mac[8] ,\eth_transceiver_u/rx_dest_mac[7] ,\eth_transceiver_u/rx_dest_mac[6] ,\eth_transceiver_u/rx_dest_mac[5] ,\eth_transceiver_u/rx_dest_mac[4] ,\eth_transceiver_u/rx_dest_mac[3] ,\eth_transceiver_u/rx_dest_mac[2] ,\eth_transceiver_u/rx_dest_mac[1] ,\eth_transceiver_u/rx_dest_mac[0] ,\RGMII_RXD[3] ,\RGMII_RXD[2] ,\RGMII_RXD[1] ,\RGMII_RXD[0] ,\eth_transceiver_u/rgmii_rxd_ddr[7] ,\eth_transceiver_u/rgmii_rxd_ddr[6] ,\eth_transceiver_u/rgmii_rxd_ddr[5] ,\eth_transceiver_u/rgmii_rxd_ddr[4] ,\eth_transceiver_u/rgmii_rxd_ddr[3] ,\eth_transceiver_u/rgmii_rxd_ddr[2] ,\eth_transceiver_u/rgmii_rxd_ddr[1] ,\eth_transceiver_u/rgmii_rxd_ddr[0] ,\eth_transceiver_u/rgmii_rx_ctl_ddr[1] ,\eth_transceiver_u/rgmii_rx_ctl_ddr[0] ,\eth_transceiver_u/gmii_rxd[7] ,\eth_transceiver_u/gmii_rxd[6] ,\eth_transceiver_u/gmii_rxd[5] ,\eth_transceiver_u/gmii_rxd[4] ,\eth_transceiver_u/gmii_rxd[3] ,\eth_transceiver_u/gmii_rxd[2] ,\eth_transceiver_u/gmii_rxd[1] ,\eth_transceiver_u/gmii_rxd[0] ,\eth_transceiver_u/rx_cnt[15] ,\eth_transceiver_u/rx_cnt[14] ,\eth_transceiver_u/rx_cnt[13] ,\eth_transceiver_u/rx_cnt[12] ,\eth_transceiver_u/rx_cnt[11] ,\eth_transceiver_u/rx_cnt[10] ,\eth_transceiver_u/rx_cnt[9] ,\eth_transceiver_u/rx_cnt[8] ,\eth_transceiver_u/rx_cnt[7] ,\eth_transceiver_u/rx_cnt[6] ,\eth_transceiver_u/rx_cnt[5] ,\eth_transceiver_u/rx_cnt[4] ,\eth_transceiver_u/rx_cnt[3] ,\eth_transceiver_u/rx_cnt[2] ,\eth_transceiver_u/rx_cnt[1] ,\eth_transceiver_u/rx_cnt[0] ,RGMII_RXDV,\eth_transceiver_u/gmii_rxdv ,\eth_transceiver_u/gmii_rxer ,\eth_transceiver_u/gmii_txd[7] ,\eth_transceiver_u/gmii_txd[6] ,\eth_transceiver_u/gmii_txd[5] ,\eth_transceiver_u/gmii_txd[4] ,\eth_transceiver_u/gmii_txd[3] ,\eth_transceiver_u/gmii_txd[2] ,\eth_transceiver_u/gmii_txd[1] ,\eth_transceiver_u/gmii_txd[0] ,\eth_transceiver_u/tx_state[3] ,\eth_transceiver_u/tx_state[2] ,\eth_transceiver_u/tx_state[1] ,\eth_transceiver_u/tx_state[0] ,\eth_transceiver_u/tx_buf_len[15] ,\eth_transceiver_u/tx_buf_len[14] ,\eth_transceiver_u/tx_buf_len[13] ,\eth_transceiver_u/tx_buf_len[12] ,\eth_transceiver_u/tx_buf_len[11] ,\eth_transceiver_u/tx_buf_len[10] ,\eth_transceiver_u/tx_buf_len[9] ,\eth_transceiver_u/tx_buf_len[8] ,\eth_transceiver_u/tx_buf_len[7] ,\eth_transceiver_u/tx_buf_len[6] ,\eth_transceiver_u/tx_buf_len[5] ,\eth_transceiver_u/tx_buf_len[4] ,\eth_transceiver_u/tx_buf_len[3] ,\eth_transceiver_u/tx_buf_len[2] ,\eth_transceiver_u/tx_buf_len[1] ,\eth_transceiver_u/tx_buf_len[0] ,\eth_transceiver_u/tx_cnt[15] ,\eth_transceiver_u/tx_cnt[14] ,\eth_transceiver_u/tx_cnt[13] ,\eth_transceiver_u/tx_cnt[12] ,\eth_transceiver_u/tx_cnt[11] ,\eth_transceiver_u/tx_cnt[10] ,\eth_transceiver_u/tx_cnt[9] ,\eth_transceiver_u/tx_cnt[8] ,\eth_transceiver_u/tx_cnt[7] ,\eth_transceiver_u/tx_cnt[6] ,\eth_transceiver_u/tx_cnt[5] ,\eth_transceiver_u/tx_cnt[4] ,\eth_transceiver_u/tx_cnt[3] ,\eth_transceiver_u/tx_cnt[2] ,\eth_transceiver_u/tx_cnt[1] ,\eth_transceiver_u/tx_cnt[0] }),
    .clk_i(\eth_transceiver_u/clk_125m )
);

endmodule
