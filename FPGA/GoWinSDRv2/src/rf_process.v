module rf_rxt #(
    parameter                           SAMPLE_RATE = 32'd30720000 ,
    parameter                           BIT_RATE    = 32'd1000000   
)(
    input                               clk                        ,
    input                               rst_n                      ,
    input                               sample_clk                 ,

    // RX DATA Port
    output                              rx_data_out                ,
    output                              rx_clk_out                 ,
    output                              rx_data_valid              ,
    output                              rx_data_missing            ,

    // RX Signal Input
    input              [  11:0]         adc_data_in_i1             ,
    input              [  11:0]         adc_data_in_q1             ,
    input                               adc_in_valid               ,

    // TX DATA Port
    input              [   7:0]         tx_data_in                 ,
    input                               tx_clk_in                  ,
    input                               tx_data_valid              ,
    output                              tx_data_ready              ,

    // TX Signal Output
    output             [  11:0]         dac_data_out_i1            ,
    output             [  11:0]         dac_data_out_q1            ,
    output                              dac_out_valid               
);

endmodule