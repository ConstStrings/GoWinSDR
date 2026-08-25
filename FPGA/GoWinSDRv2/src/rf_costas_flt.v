module costas_loop_filter_new #(
    parameter ERROR_WIDTH = 26,      // 输入误差信号位宽
    parameter PHASE_WIDTH = 24,      // 相位累加器位宽
    parameter KP_WIDTH = 24,         // 比例增益位宽
    parameter KI_WIDTH = 24          // 积分增益位宽
)(
    input wire clk,
    input wire rst_n,
    input wire signed [ERROR_WIDTH-1:0] error_in,   // 输入误差信号
    input wire error_valid,                          // 误差有效信号
    output reg signed [PHASE_WIDTH-1:0] phase_out,  // 输出相位调整值
    output reg phase_valid                           // 输出有效信号
);

    // 环路滤波器参数 (可根据需要调整)
    localparam signed [KP_WIDTH-1:0] KP = 24'sd1600;    // 比例增益 (64/32768 ≈ 0.00195) - 再降低4倍
    localparam signed [KI_WIDTH-1:0] KI = 24'sd10000;     // 积分增益 (2/32768 ≈ 0.00006) - 再降低4倍 //可以考虑往大了造比如32768

    // 内部信号
    reg signed [ERROR_WIDTH+KP_WIDTH-1:0] proportional_term;
    reg signed [ERROR_WIDTH+KI_WIDTH-1:0] integral_accumulator;
    reg signed [ERROR_WIDTH+KI_WIDTH-1:0] integral_next;
    
    // 比例路径和积分路径
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            proportional_term <= 0;
            integral_accumulator <= 0;
            phase_out <= 0;
            phase_valid <= 1'b0;
        end else begin
            if (error_valid) begin
                // 比例项: Kp * error
                proportional_term <= error_in * KP;
                
                // 积分项: 先计算累加结果
                integral_next = integral_accumulator + (error_in * KI);
                
                // 防止积分饱和 - 限制在合理范围内
                if (integral_next > (2**(ERROR_WIDTH+KI_WIDTH-1) - 1)) begin
                    integral_accumulator <= (2**(ERROR_WIDTH+KI_WIDTH-1) - 1);
                end else if (integral_next < -(2**(ERROR_WIDTH+KI_WIDTH-1))) begin
                    integral_accumulator <= -(2**(ERROR_WIDTH+KI_WIDTH-1));
                end else begin
                    integral_accumulator <= integral_next;
                end
                
                // 相位校正 = 比例项 + 积分项 (调整位宽对齐)
                // 比例项右移 (KP_WIDTH-8) 位, 积分项右移 (KI_WIDTH) 位
                phase_out <= (proportional_term >>> (KP_WIDTH-8)) + 
                            (integral_accumulator >>> KI_WIDTH);
                phase_valid <= 1'b1;
            end else begin
                phase_valid <= 1'b0;
            end
        end
    end

endmodule