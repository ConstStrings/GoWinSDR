module gc0802_cmos_dev(
    input                               rst_n                      ,
    input                               clk_50m                    , // 50MHz 系统时钟基准

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

//-------------------------------------------------------------------
// 1. TX 时钟相位处理 (仅针对 TX)
//-------------------------------------------------------------------
reg tx_logic_clk;
reg tx_out_clk_wire;

always @(posedge clk_50m or negedge rst_n) begin
    if (!rst_n) begin
        tx_logic_clk    <= 1'b0;
        tx_out_clk_wire <= 1'b0;
    end else begin
        tx_logic_clk    <= rx_clk_in_p;   // 发送逻辑基准相位
        tx_out_clk_wire <= tx_logic_clk;  // 延迟 20ns (90°)，用于驱动输出时钟
    end
end

// 保持 data_clk 与输入一致，确保不影响 RX 逻辑
assign data_clk = rx_clk_in_p;

assign adc_out_valid = 1'b1;
assign adc_status    = 1'b0;

reg tx_frame = 1'b1;

//-------------------------------------------------------------------
// 2. RX 部分 (保持原样，不修改)
//-------------------------------------------------------------------
genvar i;
generate
    for (i = 0; i < 12; i = i + 1) begin : rx_iddr_gen
        IDDR IDDR_rx_inst (
            .Q0(adc_data_out_i1[i]), 
            .Q1(adc_data_out_q1[i]), 
            .CLK(data_clk), // 依然使用原始 rx_clk_in_p
            .D(rx_data_in[i])
        );
    end
endgenerate

//-------------------------------------------------------------------
// 3. TX 部分 (应用相移优化)
//-------------------------------------------------------------------
generate
    for (i = 0; i < 12; i = i + 1) begin : tx_oddr_gen
        ODDR ODDR_tx_data_inst (
            .Q0(tx_data_out[i]), 
            .CLK(tx_logic_clk),  // 使用逻辑基准相位发出数据
            .D0(dac_data_in_q1[i]), 
            .D1(dac_data_in_i1[i]), 
            .TX(1'b1)
        );
    end
endgenerate

// 使用延迟 90° 的相位发出时钟，使时钟边沿对准数据中心
ODDR ODDR_tx_clk_inst (
    .Q0(tx_clk_out_p),
    .CLK(tx_out_clk_wire),
    .D0(1'b1),
    .D1(1'b0),
    .TX(1'b1)
);

ODDR ODDR_tx_frame_inst (
    .Q0(tx_frame_out_p),
    .CLK(tx_logic_clk), 
    .D0(tx_frame),
    .D1(~tx_frame),
    .TX(1'b1)
);

endmodule