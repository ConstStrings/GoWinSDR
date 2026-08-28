module top  #(
    parameter                           SAMPLE_RATE = 32'd30720000 ,
    parameter                           SYMBOL_RATE = 32'd7680000 ,
    parameter                           IDLE_CARRIER_ENABLE = 1'b1,
    // Temporarily bypass RRC for transmit-path bring-up.
    parameter                           RRC_BYPASS_ENABLE = 1'b1
)(
    input                               sys_clk                    ,
    input                               rst_n                      ,

    // RX Port
    input                               rx_clk_in_p                ,
    input              [  11:0]         rx_data_in                 ,
    input                               rx_frame_in_p              ,

    // TX Port
    output             [  11:0]         tx_data_out                ,
    output                              tx_clk_out_p               ,
    output                              tx_frame_out_p             ,//fb

    output                              en_agc                     ,
    output                              enable                     ,
    output                              txnrx                      ,
    output                              reset                      ,

    input                               RGMII_RXCLK                ,
    input  [3:0]                        RGMII_RXD                  ,
    input                               RGMII_RXDV                 ,
    output                              RGMII_GTXCLK               ,
    output [3:0]                        RGMII_TXD                  ,
    output                              RGMII_TXEN                 ,
    output                              RGMII_RST_N                ,

    // DDR3 packet buffer
    output [13:0]                       ddr_addr                   ,
    output [2:0]                        ddr_bank                   ,
    output                              ddr_cs                     ,
    output                              ddr_ras                    ,
    output                              ddr_cas                    ,
    output                              ddr_we                     ,
    output                              ddr_ck                     ,
    output                              ddr_ck_n                   ,
    output                              ddr_cke                    ,
    output                              ddr_odt                    ,
    output                              ddr_reset_n                ,
    output [1:0]                        ddr_dm                     ,
    inout  [15:0]                       ddr_dq                     ,
    inout  [1:0]                        ddr_dqs                    ,
    inout  [1:0]                        ddr_dqs_n                  ,

    output [4:0]                        led                        
                        
    );

// ============================================================
// Clock & Reset
// ============================================================
wire                                    data_clk                   ;
reg                                     bb_symbol_clk              ;
wire                                    bb_byte_clk                ;
reg  [1:0]                              bb_byte_clk_div            ;

reg  [7:0]                              bb_symbol_clk_div_cnt      ;

parameter                           BB_SYMBOL_DIV = SAMPLE_RATE / SYMBOL_RATE;  
always @(posedge data_clk or negedge rst_n) begin
    if (!rst_n) begin
        bb_symbol_clk_div_cnt <= 8'd0;
        bb_symbol_clk <= 1'b0;
    end else begin
        if (bb_symbol_clk_div_cnt == BB_SYMBOL_DIV/2 - 1) begin
            bb_symbol_clk_div_cnt <= 8'd0;
            bb_symbol_clk <= ~bb_symbol_clk;
        end else begin
            bb_symbol_clk_div_cnt <= bb_symbol_clk_div_cnt + 1'b1;
            bb_symbol_clk <= bb_symbol_clk;
        end
    end
end

// One DQPSK byte comprises four 2-bit symbols.
always @(posedge bb_symbol_clk or negedge rst_n) begin
    if (!rst_n) begin
        bb_byte_clk_div <= 2'd0;
    end else begin
        bb_byte_clk_div <= bb_byte_clk_div + 1'b1;
    end
end

assign bb_byte_clk = bb_byte_clk_div[1];

// ============================================================
// RF Frontend (ADC/DAC DDR interface)
// ============================================================
wire                   [  11:0]         adc_data_out_i1            ;
wire                   [  11:0]         adc_data_out_q1            ;
wire                                    adc_out_valid              ;
wire                                    adc_status                 ;

wire                   [  11:0]         dac_data_in_i1_w           ;
wire                   [  11:0]         dac_data_in_q1_w           ;
wire                                    dac_in_valid_w             ;

ad9361_cmos_dev u_ad9361_cmos_dev(
    .rst_n           (rst_n),
    .clk_50m         (sys_clk),
    .data_clk        (data_clk),
        
    .rx_data_in      (rx_data_in),
    .rx_clk_in_p     (rx_clk_in_p),
    .rx_frame_in_p   (rx_frame_in_p),
       
    .adc_data_out_i1 (adc_data_out_i1),
    .adc_data_out_q1 (adc_data_out_q1),
    .adc_out_valid   (adc_out_valid),
    .adc_status      (adc_status),
        
    .dac_data_in_i1  (dac_data_in_i1_w),
    .dac_data_in_q1  (dac_data_in_q1_w),
    .dac_in_valid    (dac_in_valid_w),
       
    .tx_data_out     (tx_data_out),
    .tx_clk_out_p    (tx_clk_out_p),
    .tx_frame_out_p  (tx_frame_out_p),

    .en_agc          (en_agc),
    .enable          (enable),
    .txnrx           (txnrx),
    .reset           (reset)
);

// ============================================================
// Ethernet
// ============================================================
wire                   [   7:0]         eth_rx_data                ;
wire                                    eth_rx_data_valid          ;
wire                                    eth_rx_frame_start         ;
wire                                    eth_rx_frame_end           ;
wire                   [  15:0]         eth_udp_length         ;
wire                   [   7:0]         eth_tx_data                ;
wire                                    eth_tx_data_valid          ;
wire                                    eth_tx_frame_start         ;
  wire                                    eth_tx_ready               ;
  wire                                    eth_active                 ;
  wire                                    eth_rx_activity            ;
  wire                                    eth_tx_activity            ;

eth_transceiver #(
    .BOARD_MAC   (48'h12_34_56_78_90_12),
    .BOARD_IP    ({8'd192,8'd168,8'd3,8'd2}),
    .BOARD_PORT  (16'h8000),
    .DES_MAC     (48'hff_ff_ff_ff_ff_ff),
    .DES_IP      ({8'd192,8'd168,8'd3,8'd3}),
    .DES_PORT    (16'h8000)
) eth_transceiver_u(
    .sys_clk         (sys_clk),
    .rst_n           (rst_n),
    .RGMII_RXCLK     (RGMII_RXCLK),
    .RGMII_RXD       (RGMII_RXD),
    .RGMII_RXDV      (RGMII_RXDV),
    .RGMII_GTXCLK    (RGMII_GTXCLK),
    .RGMII_TXD       (RGMII_TXD),
    .RGMII_TXEN      (RGMII_TXEN),
    .RGMII_RST_N     (RGMII_RST_N),
    .tx_data         (eth_tx_data),
    .tx_data_valid   (eth_tx_data_valid),
    .tx_frame_start  (eth_tx_frame_start),
    .tx_ready        (eth_tx_ready),
    .rx_data         (eth_rx_data),
    .rx_data_valid   (eth_rx_data_valid),
    .rx_frame_start  (eth_rx_frame_start),
    .rx_frame_end    (eth_rx_frame_end),
      .udp_length  (eth_udp_length),
      .eth_active      (eth_active),
      .rx_activity     (eth_rx_activity),
      .tx_activity     (eth_tx_activity)
);

// Ethernet TX is driven by rf2eth_processor below.

// ============================================================
// ETH -> RF byte-clock domain (FIFO crossing from RGMII_RXCLK to bb_byte_clk)
// ============================================================
wire                   [   7:0]         rf_tx_data                 ;
wire                                    rf_tx_valid                ;
wire                                    rf_tx_ready                ;
wire                                    fifo_eth_almost_full       ;
// RX/TX LEDs indicate valid RF payload activity, not Ethernet PHY traffic.
// Reloading these counters on every valid RF byte leaves a visible tail after
// a packet while also keeping the LED continuously on for a long RF burst.
reg [19:0]                              rf_rx_led_hold;
reg [18:0]                              rf_tx_led_hold;
wire                                    rf_rx_packet_led;
wire                                    rf_tx_packet_led;
(* keep = "true" *) wire               ddr_init_done              ;
(* keep = "true" *) wire               ddr_pll_lock_dbg           ;
(* keep = "true" *) wire               ddr_phy_reset_dbg          ;
(* keep = "true" *) wire               ddr_pll_stop_dbg           ;
(* keep = "true" *) wire               eth_ingress_accept         ;
(* keep = "true" *) wire               eth_ingress_drop           ;
(* keep = "true" *) wire [15:0]        ddr_queued_words_dbg       ;
(* keep = "true" *) wire [15:0]        eth_credit_packets_dbg     ;
(* keep = "true" *) wire               dbg_tx_underrun            ;
(* keep = "true" *) wire               dbg_tx_underrun_sticky     ;
// Two independent FPGA-to-PC packet sources share this one Ethernet TX
// interface.  They are selected only by eth_tx_arbiter at packet boundaries.
wire [7:0]                             rf_eth_tx_data;
wire                                   rf_eth_tx_data_valid;
wire                                   rf_eth_tx_frame_start;
wire                                   rf_eth_tx_request;
wire                                   rf_eth_tx_grant;
wire [7:0]                             credit_eth_tx_data;
wire                                   credit_eth_tx_data_valid;
wire                                   credit_eth_tx_frame_start;
wire                                   credit_eth_tx_request;
wire                                   credit_eth_tx_grant;


eth2rf_ddr_queue #(
    .FRAME_HEAD (32'hEB90CAD3)
) u_eth2rf_processor (
    .sys_clk          (sys_clk),
    .rst_n            (rst_n),
    .eth_rx_clk       (RGMII_RXCLK),
    .rx_data          (eth_rx_data),
    .rx_data_valid    (eth_rx_data_valid),
    .rx_frame_end     (eth_rx_frame_end),
    .udp_length       (eth_udp_length),
    
    .rf_tx_clk        (bb_byte_clk),
    .rf_tx_ready      (rf_tx_ready),
    .rf_tx_data       (rf_tx_data),
    .rf_tx_valid      (rf_tx_valid),
    .ingress_accept   (eth_ingress_accept),
    .ingress_drop     (eth_ingress_drop),
    .ddr_init_done    (ddr_init_done),
    .ddr_pll_lock_dbg (ddr_pll_lock_dbg),
    .ddr_phy_reset_dbg(ddr_phy_reset_dbg),
    .ddr_pll_stop_dbg (ddr_pll_stop_dbg),
    .queued_words_dbg (ddr_queued_words_dbg),
    .credit_packets_dbg(eth_credit_packets_dbg),
    .dbg_tx_underrun  (dbg_tx_underrun),
    .dbg_tx_underrun_sticky(dbg_tx_underrun_sticky),
    .ddr_addr         (ddr_addr),
    .ddr_bank         (ddr_bank),
    .ddr_cs           (ddr_cs),
    .ddr_ras          (ddr_ras),
    .ddr_cas          (ddr_cas),
    .ddr_we           (ddr_we),
    .ddr_ck           (ddr_ck),
    .ddr_ck_n         (ddr_ck_n),
    .ddr_cke          (ddr_cke),
    .ddr_odt          (ddr_odt),
    .ddr_reset_n      (ddr_reset_n),
    .ddr_dm           (ddr_dm),
    .ddr_dq           (ddr_dq),
    .ddr_dqs          (ddr_dqs),
    .ddr_dqs_n        (ddr_dqs_n)
);

assign fifo_eth_almost_full = !eth_ingress_accept;

// ============================================================
// RF Signal Processing (DQPSK encoder + RRC + FIFO -> DAC)
// ============================================================
wire                   [  11:0]         dac_data_out_i1            ;
wire                   [  11:0]         dac_data_out_q1            ;
wire                                    dac_out_valid              ;
// 保留 RX 定时恢复及解码链路，方便 ILA 观察 Gardner 输出；
// 顶层暂不将其接入以太网发送路径。
(* keep = "true" *) wire [7:0]          rf_rx_data                ;
(* keep = "true" *) wire                rf_rx_clk                 ;
(* keep = "true" *) wire                rf_rx_data_valid          ;
(* keep = "true" *) wire                rf_rx_data_missing        ;
(* keep = "true" *) wire                rf_rx_to_eth_overflow     ;

rf_process #(
    .SAMPLE_RATE          (SAMPLE_RATE),
    .SYMBOL_RATE          (SYMBOL_RATE),
    .IDLE_CARRIER_ENABLE  (IDLE_CARRIER_ENABLE),
    .RRC_BYPASS_ENABLE    (RRC_BYPASS_ENABLE)
) u_rf_process (
    .sys_clk         (sys_clk),
    .rst_n           (rst_n),
    .sample_clk      (data_clk),
    .bb_symbol_clk   (bb_symbol_clk),
    .bb_byte_clk     (bb_byte_clk),

    // RX (from ADC)
    .adc_data_in_i1  (adc_data_out_i1),
    .adc_data_in_q1  (adc_data_out_q1),
    .adc_in_valid    (adc_out_valid),

    // RX（保留以避免综合裁剪 Gardner 链路）
    .rx_data_out     (rf_rx_data),
    .rx_clk_out      (rf_rx_clk),
    .rx_data_valid   (rf_rx_data_valid),
    .rx_data_missing (rf_rx_data_missing),

    // TX (from Ethernet via CDC)
    .tx_data_in      (rf_tx_data),
    .tx_clk_in       (bb_byte_clk),
    .tx_data_valid   (rf_tx_valid),
    .tx_data_ready   (rf_tx_ready),

    // TX (to DAC)
    .dac_data_out_i1 (dac_data_out_i1),
    .dac_data_out_q1 (dac_data_out_q1),
    .dac_out_valid   (dac_out_valid)
);

// ============================================================
// RF RX -> Ethernet TX (asynchronous clock-domain crossing)
// ============================================================
  rf2eth_processor #(
      .FIFO_ADDR_WIDTH(11),
    // A payload byte is emitted every 16 data_clk periods.  64 periods
    // safely identifies the inter-frame idle without splitting payload.
    .RF_IDLE_CYCLES (64)
) u_rf2eth_processor (
    .rf_rx_clk          (rf_rx_clk),
    .rf_rx_rst_n        (rst_n),
    .rf_rx_data         (rf_rx_data),
    .rf_rx_data_valid   (rf_rx_data_valid),
    .rf_rx_overflow     (rf_rx_to_eth_overflow),

    // eth_transceiver's user TX interface is clocked by its 125 MHz
    // RGMII transmit clock.
    .eth_tx_clk         (RGMII_GTXCLK),
    .eth_tx_rst_n       (rst_n),
    .eth_tx_ready       (rf_eth_tx_grant),
    .eth_tx_request     (rf_eth_tx_request),
    .eth_tx_data        (rf_eth_tx_data),
    .eth_tx_data_valid  (rf_eth_tx_data_valid),
    .eth_tx_frame_start (rf_eth_tx_frame_start)
);

// rf_rx_data_valid is produced only by the RF deframer in READ_PAY, i.e.
// after FRAME_HEAD and the length have been accepted.  rf_tx_valid is the
// dequeued DDR frame byte stream presented to the RF modulator.
always @(posedge rf_rx_clk or negedge rst_n) begin
    if (!rst_n)
        rf_rx_led_hold <= 20'd0;
    else if (rf_rx_data_valid)
        rf_rx_led_hold <= {20{1'b1}};
    else if (rf_rx_led_hold != 20'd0)
        rf_rx_led_hold <= rf_rx_led_hold - 1'b1;
end

always @(posedge bb_byte_clk or negedge rst_n) begin
    if (!rst_n)
        rf_tx_led_hold <= 19'd0;
    else if (rf_tx_valid)
        rf_tx_led_hold <= {19{1'b1}};
    else if (rf_tx_led_hold != 19'd0)
        rf_tx_led_hold <= rf_tx_led_hold - 1'b1;
end

assign rf_rx_packet_led = |rf_rx_led_hold;
assign rf_tx_packet_led = |rf_tx_led_hold;

// One coalesced status packet is requested after each received UDP frame.
// Its snapshot is advisory; ingress_accept remains the final DDR safety gate.
eth_credit_status u_eth_credit_status (
    .eth_rx_clk       (RGMII_RXCLK),
    .eth_rx_rst_n     (rst_n),
    .rx_frame_end     (eth_rx_frame_end),
    .credit_value     (eth_credit_packets_dbg),
    .eth_tx_clk       (RGMII_GTXCLK),
    .eth_tx_rst_n     (rst_n),
    .tx_grant         (credit_eth_tx_grant),
    .tx_request       (credit_eth_tx_request),
    .tx_data          (credit_eth_tx_data),
    .tx_data_valid    (credit_eth_tx_data_valid),
    .tx_frame_start   (credit_eth_tx_frame_start)
);

eth_tx_arbiter u_eth_tx_arbiter (
    .clk                (RGMII_GTXCLK),
    .rst_n              (rst_n),
    .downstream_ready   (eth_tx_ready),
    .rf_request         (rf_eth_tx_request),
    .rf_grant           (rf_eth_tx_grant),
    .rf_data            (rf_eth_tx_data),
    .rf_valid           (rf_eth_tx_data_valid),
    .rf_frame_start     (rf_eth_tx_frame_start),
    .status_request     (credit_eth_tx_request),
    .status_grant       (credit_eth_tx_grant),
    .status_data        (credit_eth_tx_data),
    .status_valid       (credit_eth_tx_data_valid),
    .status_frame_start (credit_eth_tx_frame_start),
    .tx_data            (eth_tx_data),
    .tx_valid           (eth_tx_data_valid),
    .tx_frame_start     (eth_tx_frame_start)
);

// Connect rf_process DAC outputs to RF frontend
assign dac_data_in_i1_w = dac_data_out_i1;
assign dac_data_in_q1_w = dac_data_out_q1;
assign dac_in_valid_w   = dac_out_valid;

// ============================================================
// Status LEDs
// ============================================================
phy_led phy_led_u(
    .sys_clk  (sys_clk),
    .rst_n    (rst_n),
      .eth_act  (eth_active),
      .error    (fifo_eth_almost_full),
      .data_clk (data_clk),
      .rx_act   (rf_rx_packet_led),
      .tx_act   (rf_tx_packet_led),
    .led      (led)
);

endmodule
