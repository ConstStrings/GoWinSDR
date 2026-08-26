//利用gardner算法计算定时误差,并通过环路滤波器得到小数间隔
//同时得出最佳判决点的两路输出数据
module gardner_ted #(
    // Q1.15 NCO 标称步进。其值必须对应“每个码元两个 strobe”。
    parameter [15:0] WN_NOMINAL     = 16'h4000,
    // 微分环路滤波器 c1=2^(-LOOP_GAIN_SHIFT)。
    parameter integer LOOP_GAIN_SHIFT = 14,
    // 0: 同源回环，固定标称符号率；1: 外部异步信号，允许 TED 跟踪频偏。
    parameter         TIMING_TRACK_ENABLE = 1'b0
)
(
    input wire          clk             ,  //500kHz
    input wire          rst_n           ,
    input wire          strobe_flag     ,  //有效插值标志
    input wire [19:0]   interpolate_I   ,  //从插值滤波器来的I路数据
    input wire [19:0]   interpolate_Q   ,  //从插值滤波器来的Q路数据
    
    output reg          sync_out_I      ,  //判决后的I路数据
    output reg          sync_out_Q      ,  //判决后的Q路数据
    output reg          sync_flag       ,  //同步标志，代表最佳判决点已到来,与输出的判决数据对齐
    output reg [15:0]   wn                 //通过环路滤波器后误差数据
);

    reg signed [21:0]  error        ; //gardner算法计算出的时间误差
    //用于误差数据缓存
    reg signed [21:0]  error_d1     ;
    
    //寄存strobe_flag的次数
    reg [7:0]   strobe_cnt          ;
    
    
    //用于计算误差的采样数据缓存
    reg [19:0]  interpolate_I_d1    ;  
    reg [19:0]  interpolate_I_d2    ;   
    reg [19:0]  interpolate_Q_d1    ;
    reg [19:0]  interpolate_Q_d2    ;

    wire        samp_flag           ;

    // 限制在标称值的 +/-12.5% 内。这样既可补偿实际符号率的小误差，
    // 又不会因异常误差把 NCO 推到 0 或 Q1.15 回绕区。
    localparam [15:0] WN_MIN = WN_NOMINAL - (WN_NOMINAL >> 3);
    localparam [15:0] WN_MAX = WN_NOMINAL + (WN_NOMINAL >> 3);

    wire signed [22:0] error_delta;
    wire signed [31:0] wn_candidate;

    assign error_delta  = $signed({error[21], error}) -
                          $signed({error_d1[21], error_d1});
    assign wn_candidate = $signed({1'b0, wn}) +
                          (error_delta >>> LOOP_GAIN_SHIFT);

    function [15:0] clamp_wn;
        input signed [31:0] candidate;
        begin
            if (candidate < $signed({1'b0, WN_MIN}))
                clamp_wn = WN_MIN;
            else if (candidate > $signed({1'b0, WN_MAX}))
                clamp_wn = WN_MAX;
            else
                clamp_wn = candidate[15:0];
        end
    endfunction
    
    //sync_flag是samp_flag打一拍,使得sync_flag正好与经过判决后的输出数据对齐
    //后续在sync_flag高电平时采集判决数据即可
    always @ (posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            sync_flag <= 1'b0;
        end else begin
            sync_flag <= samp_flag;
        end
    end

    
    
    //最佳抽样判决时刻标志
    //NCO输出第一个strobe_flag时已经到达第一个最佳抽判时刻
    //故strobe_cnt == 0且strobe_flag高电平到来代表最佳抽判时刻
    assign samp_flag = ((strobe_cnt == 0) && strobe_flag)?1'b1: 1'b0;
    
    
    //计算strobe_flag的次数，也是nco溢出的次数，strobe_flag出现在最佳抽判时刻以及最佳抽判时刻中央
    //strobe_cnt在本案例中为0、1之间计数
    always @ (posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            strobe_cnt <= 8'd0;
        end else if((strobe_cnt == 1) && strobe_flag) begin
            strobe_cnt <= 8'd0;
        end else if(strobe_flag) begin
            strobe_cnt <= strobe_cnt + 8'd1;
        end else begin
            strobe_cnt <= strobe_cnt;
        end
    end
    

    //采集最佳判决时刻以及中间时刻的数据
    //依据Gardner算法计算误差
    //每一个码元符号只需要计算一次误差即可
    //并将得到的时间误差数据通过环路滤波，得到小数间隔
    always @ (posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            interpolate_I_d1 <= 20'b0;
            interpolate_I_d2 <= 20'b0;
            interpolate_Q_d1 <= 20'b0;
            interpolate_Q_d2 <= 20'b0;
            
            //标称 wn 由 SAMPLE_RATE/SYMBOL_RATE 在上层自动计算。
            wn <= WN_NOMINAL;
            error <= 22'b0;
            error_d1 <= 22'b0;

        end else if(strobe_flag) begin
            //最佳判决时刻及判决时刻中间的时刻到来
            //更新用于计算误差的数据
            interpolate_I_d1 <= interpolate_I;
            interpolate_I_d2 <= interpolate_I_d1;

            interpolate_Q_d1 <= interpolate_Q;
            interpolate_Q_d2 <= interpolate_Q_d1;
            
            if(samp_flag) begin
            //最佳判决时刻到来
            //计算并更新定时误差
            //μt(k)=I(k-1/2)[I(k)−I(k−1)]
            //依据符号位的不同，通过移位操作实现*2以及*(-2)
                case({interpolate_I[19],interpolate_I_d2[19],interpolate_Q[19],interpolate_Q_d2[19]})
                    4'b1010:begin
                        //IQ两路都是[I(k)−I(k−1)] < 0 ,两路都将中间值*(-2)并相加得到error
                        //符号位需要扩展
                        error <= ~({interpolate_I_d1[19],interpolate_I_d1[19:0],1'b0})+20'b1 + ~({interpolate_Q_d1[19],interpolate_Q_d1[19:0],1'b0})+20'b1;
                    end
                    4'b1001:begin
                        //I路[I(k)−I(k−1)]<0,Q路[I(k)−I(k−1)]>0,
                        //I路将中间值*(-2),Q路将中间值*2
                        error <= ~({interpolate_I_d1[19],interpolate_I_d1[19:0],1'b0})+20'b1 + {interpolate_Q_d1[19],interpolate_Q_d1[19:0],1'b0};
                    end
                    4'b0110: begin
                        //I路[I(k)−I(k−1)]>0,Q路[I(k)−I(k−1)]<0,
                        //I路将中间值*2,Q路将中间值*(-2)
                        error <= {interpolate_I_d1[19],interpolate_I_d1[19:0],1'b0} + ~({interpolate_Q_d1[19],interpolate_Q_d1[19:0],1'b0})+20'b1;
                    end
                    4'b0101:begin
                        //I路[I(k)−I(k−1)]>0,Q路[I(k)−I(k−1)]>0,
                        //I路将中间值*2,Q路将中间值*2 
                        error <= {interpolate_I_d1[19],interpolate_I_d1[19:0],1'b0} + {interpolate_Q_d1[19],interpolate_Q_d1[19:0],1'b0};                   
                    end
                    4'b0100,4'b0111:begin
                        //I路[I(k)−I(k−1)]>0,Q路[I(k)−I(k−1)]=0
                        //I路将中间值*2
                        error <= {interpolate_I_d1[19],interpolate_I_d1[19:0],1'b0};
                    end
                    4'b1000,4'b1011:begin
                        //I路[I(k)−I(k−1)]<0,Q路[I(k)−I(k−1)]=0
                        //I路将中间值*(-2)
                        error <= ~({interpolate_I_d1[19],interpolate_I_d1[19:0],1'b0})+20'b1;
                    end
                    4'b0001,4'b1101:begin
                        //I路[I(k)−I(k−1)]=0,Q路[I(k)−I(k−1)]>0
                        //Q路将中间值*2
                        error <= {interpolate_Q_d1[19],interpolate_Q_d1[19:0],1'b0};                        
                    end
                    4'b0010,4'b1110:begin
                        //I路[I(k)−I(k−1)]=0,Q路[I(k)−I(k−1)]<0
                        //Q路将中间值*(-2)
                        error <= ~({interpolate_Q_d1[19],interpolate_Q_d1[19:0],1'b0})+20'b1;
                    end
                    default: begin
                        error <= 22'b0;
                    end
                endcase
            //输出判决数据,判决门限设为0,故判决符号位即可
                sync_out_I <= ~interpolate_I[19];
                sync_out_Q <= ~interpolate_Q[19];
            //每个最佳判决时刻更新一次error数据
                error_d1 <= error;
                
            // 同一 AD9361 的 TX/RX 使用同一采样基准，不存在符号率频偏。
            // 固定 wn=wn_nominal 时，Fs=4Rs 会严格每四个 sample_clk 输出一个 flag。
            // 外部异步源才启用微分频率跟踪。
                if (TIMING_TRACK_ENABLE)
                    wn <= clamp_wn(wn_candidate);
                else
                    wn <= WN_NOMINAL;
            end
            
        end else begin
            //其他时刻数据保持不变
            interpolate_I_d1 <= interpolate_I_d1;
            interpolate_I_d2 <= interpolate_I_d2;
            interpolate_Q_d1 <= interpolate_Q_d1;
            interpolate_Q_d2 <= interpolate_Q_d2;
        end
    end
    
    


endmodule
