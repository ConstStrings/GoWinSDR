module ad9361_cmos_dev(
    input                               rst_n                      ,
    input                               clk_50m                    ,

    output                              data_clk                   ,
    //Rx Port
    input              [  11:0]         rx_data_in                 ,
    input                               rx_clk_in_p                ,
    input                               rx_frame_in_p              ,

    output             [  11:0]         adc_data_out_i1            ,
    output             [  11:0]         adc_data_out_q1            ,
    output                              adc_out_valid              ,
    output                              adc_status                 ,
 
    input              [  11:0]         dac_data_in_i1             ,
    input              [  11:0]         dac_data_in_q1             ,
    input                               dac_in_valid               ,

    output             [  11:0]         tx_data_out                ,
    output                              tx_clk_out_p               ,
    output                              tx_frame_out_p             ,
    
    output                              en_agc                     ,
    output reg                          enable                     ,
    output reg                          txnrx                      ,
    output                              reset       
);

assign      en_agc        = 1'b0        ;
assign      reset         = rst_n       ;

always @(posedge clk_50m or negedge rst_n) begin
    if(!rst_n)begin
    txnrx <= 1'b0;
    enable<= 1'b0;
    end
    else begin
        txnrx <= 1'b1;
        enable<= 1'b0;
    end
end

assign tx_clk_out_p = rx_clk_in_p;

assign adc_out_valid = 1'b1;
assign adc_status    = 1'b0;

    Gowin_PLL_rfclk u_Gowin_PLL_rfclk(
        .clkin(rx_clk_in_p), //input  clkin
        .clkout0(data_clk), //output  clkout0
        .mdclk(rx_clk_in_p) //input  mdclk
    );


// 1R1T DDR TX framing.  Keep the frame state advancing with every
// data-clock period, matching the validated AD9361 loopback interface.
reg                                     tx_frame;

always @(posedge data_clk or negedge rst_n) begin
    if (!rst_n)
        tx_frame <= 1'b0;
    else
        tx_frame <= ~tx_frame;
end

// IDDR instances (bits 0..11)
IDDR IDDR_rx_frame_data_p_n_inst_0  (.Q0(adc_data_out_q1[0]),  .Q1(adc_data_out_i1[0]),  .CLK(data_clk), .D(rx_data_in[0]));
IDDR IDDR_rx_frame_data_p_n_inst_1  (.Q0(adc_data_out_q1[1]),  .Q1(adc_data_out_i1[1]),  .CLK(data_clk), .D(rx_data_in[1]));
IDDR IDDR_rx_frame_data_p_n_inst_2  (.Q0(adc_data_out_q1[2]),  .Q1(adc_data_out_i1[2]),  .CLK(data_clk), .D(rx_data_in[2]));
IDDR IDDR_rx_frame_data_p_n_inst_3  (.Q0(adc_data_out_q1[3]),  .Q1(adc_data_out_i1[3]),  .CLK(data_clk), .D(rx_data_in[3]));
IDDR IDDR_rx_frame_data_p_n_inst_4  (.Q0(adc_data_out_q1[4]),  .Q1(adc_data_out_i1[4]),  .CLK(data_clk), .D(rx_data_in[4]));
IDDR IDDR_rx_frame_data_p_n_inst_5  (.Q0(adc_data_out_q1[5]),  .Q1(adc_data_out_i1[5]),  .CLK(data_clk), .D(rx_data_in[5]));
IDDR IDDR_rx_frame_data_p_n_inst_6  (.Q0(adc_data_out_q1[6]),  .Q1(adc_data_out_i1[6]),  .CLK(data_clk), .D(rx_data_in[6]));
IDDR IDDR_rx_frame_data_p_n_inst_7  (.Q0(adc_data_out_q1[7]),  .Q1(adc_data_out_i1[7]),  .CLK(data_clk), .D(rx_data_in[7]));
IDDR IDDR_rx_frame_data_p_n_inst_8  (.Q0(adc_data_out_q1[8]),  .Q1(adc_data_out_i1[8]),  .CLK(data_clk), .D(rx_data_in[8]));
IDDR IDDR_rx_frame_data_p_n_inst_9  (.Q0(adc_data_out_q1[9]),  .Q1(adc_data_out_i1[9]),  .CLK(data_clk), .D(rx_data_in[9]));
IDDR IDDR_rx_frame_data_p_n_inst_10 (.Q0(adc_data_out_q1[10]), .Q1(adc_data_out_i1[10]), .CLK(data_clk), .D(rx_data_in[10]));
IDDR IDDR_rx_frame_data_p_n_inst_11 (.Q0(adc_data_out_q1[11]), .Q1(adc_data_out_i1[11]), .CLK(data_clk), .D(rx_data_in[11]));

// ODDR instances (bits 0..11)
ODDR ODDR_tx_data_inst_0  (.Q0(tx_data_out[0]),  .CLK(data_clk), .D0(dac_data_in_q1[0]),  .D1(dac_data_in_i1[0]),  .TX(1'b1));
ODDR ODDR_tx_data_inst_1  (.Q0(tx_data_out[1]),  .CLK(data_clk), .D0(dac_data_in_q1[1]),  .D1(dac_data_in_i1[1]),  .TX(1'b1));
ODDR ODDR_tx_data_inst_2  (.Q0(tx_data_out[2]),  .CLK(data_clk), .D0(dac_data_in_q1[2]),  .D1(dac_data_in_i1[2]),  .TX(1'b1));
ODDR ODDR_tx_data_inst_3  (.Q0(tx_data_out[3]),  .CLK(data_clk), .D0(dac_data_in_q1[3]),  .D1(dac_data_in_i1[3]),  .TX(1'b1));
ODDR ODDR_tx_data_inst_4  (.Q0(tx_data_out[4]),  .CLK(data_clk), .D0(dac_data_in_q1[4]),  .D1(dac_data_in_i1[4]),  .TX(1'b1));
ODDR ODDR_tx_data_inst_5  (.Q0(tx_data_out[5]),  .CLK(data_clk), .D0(dac_data_in_q1[5]),  .D1(dac_data_in_i1[5]),  .TX(1'b1));
ODDR ODDR_tx_data_inst_6  (.Q0(tx_data_out[6]),  .CLK(data_clk), .D0(dac_data_in_q1[6]),  .D1(dac_data_in_i1[6]),  .TX(1'b1));
ODDR ODDR_tx_data_inst_7  (.Q0(tx_data_out[7]),  .CLK(data_clk), .D0(dac_data_in_q1[7]),  .D1(dac_data_in_i1[7]),  .TX(1'b1));
ODDR ODDR_tx_data_inst_8  (.Q0(tx_data_out[8]),  .CLK(data_clk), .D0(dac_data_in_q1[8]),  .D1(dac_data_in_i1[8]),  .TX(1'b1));
ODDR ODDR_tx_data_inst_9  (.Q0(tx_data_out[9]),  .CLK(data_clk), .D0(dac_data_in_q1[9]),  .D1(dac_data_in_i1[9]),  .TX(1'b1));
ODDR ODDR_tx_data_inst_10 (.Q0(tx_data_out[10]), .CLK(data_clk), .D0(dac_data_in_q1[10]), .D1(dac_data_in_i1[10]), .TX(1'b1));
ODDR ODDR_tx_data_inst_11 (.Q0(tx_data_out[11]), .CLK(data_clk), .D0(dac_data_in_q1[11]), .D1(dac_data_in_i1[11]), .TX(1'b1));

ODDR ODDR_tx_frame_inst (
    .Q0                                (tx_frame_out_p           ),// 1-bit DDR output
    .CLK                               (data_clk                  ),// 1-bit clock input
    .D0                                (tx_frame                  ),// 1-bit data input (positive edge)
    .D1                                (~tx_frame                  ),// 1-bit data input (negative edge)
    .TX                                (1'b1                      ) // 1-bit reset
);

endmodule
