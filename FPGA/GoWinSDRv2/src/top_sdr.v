module top  #(
    parameter                           SAMPLE_RATE = 32'd61440000 ,
    parameter                           BIT_RATE    = 32'd10000000   
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

    output [4:0]                        led                        
                        
    );

assign dac_data_in_i1 = sine;
assign dac_data_in_q1 = cosine;
assign dac_data_in_i2 = 12'd0;
assign dac_data_in_q2 = 12'd0;

wire                                    data_clk                   ;
wire                   [  11:0]         sine                       ;
wire                   [  11:0]         cosine                     ;

wire                   [  11:0]         adc_data_out_i1            ;
wire                   [  11:0]         adc_data_out_q1            ;
wire                                    adc_out_valid              ;
wire                                    adc_status                 ;

wire                   [  11:0]         dac_data_in_i1             ;
wire                   [  11:0]         dac_data_in_q1             ;
wire                                    dac_in_valid               ;
wire                   [   7:0]         eth_rx_data                ;
wire                                    eth_rx_data_valid          ;
wire                                    eth_rx_frame_start         ;
wire                                    eth_rx_frame_end           ;
wire                   [   7:0]         eth_tx_data                ;
wire                                    eth_tx_data_valid          ;
wire                                    eth_tx_frame_start         ;
wire                                    eth_tx_ready               ;
wire                                    eth_active                 ;

assign dac_in_valid = rst_n;

assign eth_tx_data        = eth_rx_data;
assign eth_tx_data_valid  = eth_rx_data_valid;
assign eth_tx_frame_start = eth_rx_frame_start;

    gc0802_cmos_dev u_gc0802_dev_cmos(
    .rst_n                             (rst_n                     ),
    .clk_50m                           (sys_clk                   ), // 50MHz 系统时钟基准
        
    .data_clk                          (data_clk                  ),
       
    .rx_data_in                        (rx_data_in                ),
    .rx_clk_in_p                       (rx_clk_in_p               ),
    .rx_frame_in_p                     (rx_frame_in_p             ),
       
    .adc_data_out_i1                   (adc_data_out_i1           ),
    .adc_data_out_q1                   (adc_data_out_q1           ),
    .adc_out_valid                     (adc_out_valid             ),
    .adc_status                        (adc_status                ),
        
    .dac_data_in_i1                    (dac_data_in_i1            ),
    .dac_data_in_q1                    (dac_data_in_q1            ),
    .dac_in_valid                      (dac_in_valid              ),
       
    .tx_data_out                       (tx_data_out               ),
    .tx_clk_out_p                      (tx_clk_out_p              ),
    .tx_frame_out_p                    (tx_frame_out_p            ),

    .en_agc                            (en_agc                    ),
    .enable                            (enable                    ),
    .txnrx                             (txnrx                     ),
    .reset                             (reset                     )
    );



    DDS_II_Top dds_test_u(
    .clk_i                             (data_clk                  ),//input clk_i
    .rst_n_i                           (rst_n                     ),//input rst_n_i
    .cosine_o                          (cosine                    ), //output [11:0] cosine_o
    .sine_o                            (sine                      ),//output [11:0] sine_o
    .data_valid_o                      (                          ) //output data_valid_o
    );

    eth_transceiver #(
    .BOARD_MAC                         (48'h12_34_56_78_90_12     ),
    .BOARD_IP                          ({8'd192,8'd168,8'd3,8'd2} ),
    .BOARD_PORT                        (16'h8000                  ),
    .DES_MAC                           (48'hff_ff_ff_ff_ff_ff     ),
    .DES_IP                            ({8'd192,8'd168,8'd3,8'd3} ),
    .DES_PORT                          (16'h8000                  )
    ) eth_transceiver_u(
    .sys_clk                           (sys_clk                   ),
    .rst_n                             (rst_n                     ),
    .PHY_CLK                           (                          ),
    .RGMII_RXCLK                       (RGMII_RXCLK               ),
    .RGMII_RXD                         (RGMII_RXD                 ),
    .RGMII_RXDV                        (RGMII_RXDV                ),
    .RGMII_GTXCLK                      (RGMII_GTXCLK              ),
    .RGMII_TXD                         (RGMII_TXD                 ),
    .RGMII_TXEN                        (RGMII_TXEN                ),
    .RGMII_RST_N                       (RGMII_RST_N               ),
    .tx_data                           (eth_tx_data               ),
    .tx_data_valid                     (eth_tx_data_valid         ),
    .tx_frame_start                    (eth_tx_frame_start        ),
    .tx_ready                          (eth_tx_ready              ),
    .rx_data                           (eth_rx_data               ),
    .rx_data_valid                     (eth_rx_data_valid         ),
    .rx_frame_start                    (eth_rx_frame_start        ),
    .rx_frame_end                      (eth_rx_frame_end          ),
    .eth_active                        (eth_active                )
    );

    phy_led phy_led_u(
    .sys_clk                            (sys_clk                   ),
    .rst_n                              (rst_n                     ),
    .eth_act                            (1'b0                      ),
    .error                              (1'b1                      ),
    .data_clk                           (data_clk                  ),
    .rx_act                             (1'b0                      ),
    .tx_act                             (1'b0                      ),
    .led                                (led                       )
    );

endmodule
