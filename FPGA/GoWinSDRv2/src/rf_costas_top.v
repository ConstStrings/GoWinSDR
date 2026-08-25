module costas (
    input rst_n,
    // Data Processing Block
    input sample_clk,
    input [11:0] sample_i1,
    input [11:0] sample_q1,
    output [11:0] data_out_i,
    output [11:0] data_out_q
);

    assign data_out_i = sum_a[23:12];
    assign data_out_q = sum_b[23:12];

    wire        clk_sam     ; 
    wire signed [11:0]  dds_sin   ;
    wire signed [11:0]  dds_cos   ;
    wire signed [24:0] pd          ;  //costas环路滤波器输出

    assign clk_sam = sample_clk;

	DDS_Costas dds_costas_u0(
		.clk_i(clk_sam), //input clk_i
		.rst_n_i(rst_n), //input rst_n_i
		.phase_valid_i(1'b1), //input phase_valid_i
		.phase_off_i(25'h1ffffff-pd), //input [24:0] phase_off_i
		.cosine_o(dds_cos), //output [11:0] cosine_o
		.sine_o(dds_sin), //output [11:0] sine_o
		.data_valid_o() //output data_valid_o
	);
    
wire signed [23:0] sum_is;
wire signed [23:0] sum_qs;
wire signed [23:0] sum_ic;
wire signed [23:0] sum_qc;

    Gowin_MULT_1212 mul_u0(
        .dout(sum_is), //output [23:0] dout
        .a(sample_i1), //input [11:0] a
        .b(dds_sin), //input [11:0] b
        .clk(clk_sam), //input clk
        .ce(1'b1), //input ce
        .reset(~rst_n) //input reset
    );

    Gowin_MULT_1212 mul_u1(
        .dout(sum_qs), //output [23:0] dout
        .a(sample_q1), //input [11:0] a
        .b(dds_sin), //input [11:0] b
        .clk(clk_sam), //input clk
        .ce(1'b1), //input ce
        .reset(~rst_n) //input reset
    );
    Gowin_MULT_1212 mul_u2(
        .dout(sum_ic), //output [23:0] dout
        .a(sample_i1), //input [11:0] a
        .b(dds_cos), //input [11:0] b
        .clk(clk_sam), //input clk
        .ce(1'b1), //input ce
        .reset(~rst_n) //input reset
    );

    Gowin_MULT_1212 mul_u3(
        .dout(sum_qc), //output [23:0] dout
        .a(sample_q1), //input [11:0] a
        .b(dds_cos), //input [11:0] b
        .clk(clk_sam), //input clk
        .ce(1'b1), //input ce
        .reset(~rst_n) //input reset
    );
  
      
    wire signed [24:0] sum_a = sum_ic - sum_qs;
    wire signed [24:0] sum_b = sum_is + sum_qc;

    // phase_detector phase_detector_inst(
    //     .filtered_I     (filtered_I         ), //I路经过低通滤波后信号
    //     .filtered_Q     (filtered_Q         ), //Q路经过低通滤波后信号

    //     .phase_error    (phase_error        )  //输出的相位误差
    // );

    wire signed sign_product_1 = sum_b[24] ? ~sum_a[24] : sum_a[24];
    wire signed sign_product_2 = sum_a[24] ? ~sum_b[24] : sum_b[24];
    wire signed [25:0] loop_flt_in = {sign_product_1, sum_a[23:0]} + {sign_product_2, sum_b[23:0]}; // 26q12
    localparam upbit = 2;
    localparam out_width = 58;
    wire signed [out_width -1 :0] expanded_filt_in;
    assign expanded_filt_in = {{(out_width - (26 + upbit)){loop_flt_in[25]}}, loop_flt_in, {upbit{1'b0}}};
    
    //costas环路滤波器
    costas_loop_filter_new #(
        .ERROR_WIDTH(26),           // 匹配expanded_filt_in的位宽
        .PHASE_WIDTH(25),           // 匹配pd的位宽
        .KP_WIDTH(24),              // 比例增益位宽
        .KI_WIDTH(24)               // 积分增益位宽
    ) costas_loop_filter_inst (
        .clk(clk_sam),              // 采样频率
        .rst_n(rst_n),
        .error_in(loop_flt_in), // 由鉴相器输出的原始相位误差信号
        .error_valid(1'b1),         // 误差始终有效
        .phase_out(pd),             // 滤波器输出, 用于调整dds相位偏移
        .phase_valid()              // 输出有效信号(未使用)
    );
    
endmodule