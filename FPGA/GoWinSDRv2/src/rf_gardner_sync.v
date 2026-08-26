// Gardner 定时恢复：NCO 每个码元产生两个 strobe（中点和最佳判决点）。
// WN 使用 Q1.15 格式，因此标称步进为 2*SYMBOL_RATE/SAMPLE_RATE。
module gardner_sync #(
    parameter [31:0] SAMPLE_RATE = 32'd30720000,
    parameter [31:0] SYMBOL_RATE = 32'd7680000,
    // 同一 AD9361 时钟域的本机回环不需要频率跟踪；保持标称 wn 可避免
    // 由未锁定 TED 误差引起的采样率漂移。外部异步发射机可置为 1。
    parameter          TIMING_TRACK_ENABLE = 1'b0
)
(
    input wire          clk         ,  //500kHz
    input wire          rst_n       ,
    input wire [11:0]   data_in_I   ,
    input wire [11:0]   data_in_Q   ,
    
    output wire         sync_out_I  ,
    output wire         sync_out_Q  ,
    output wire         sync_flag      //最佳抽样判决时刻标志
);
    // 先扩展到 64 bit，避免 SYMBOL_RATE << 16 在 32 bit 中溢出。
    // 例如 Fs=30.72 MHz、Rs=7.68 MHz 时 NCO_WN_NOMINAL=16'h4000，
    // 即每两个 sample_clk 周期产生一个 strobe，每两个 strobe 输出一个符号。
    localparam [63:0] NCO_WN_NOMINAL_WIDE =
        ({32'd0, SYMBOL_RATE} << 16) / SAMPLE_RATE;
    localparam [15:0] NCO_WN_NOMINAL = NCO_WN_NOMINAL_WIDE[15:0];

    wire [15:0]         uk          ;  //小数间隔，15bit小数位
    wire [19:0]         I_y         ;  //插值滤波器输出I路
    wire [19:0]         Q_y         ;  //插值滤波器输出Q路
    wire [15:0]         wn          ;  //通过环路滤波器后的误差数据
    wire                nco_strobe_flag;
    wire                ted_strobe_flag;
    // MULT_1716 具有输入、输出寄存器，且 I_y/Q_y 另有一级输出寄存器。
    // NCO 的 uk/strobe 到插值结果可供 TED 使用共有 3 拍流水线延迟。
    reg [2:0]           strobe_delay;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            strobe_delay <= 3'b000;
        else
            strobe_delay <= {strobe_delay[1:0], nco_strobe_flag};
    end

    assign ted_strobe_flag = strobe_delay[2];
    
    
    //内插滤波器
    interpolate_filter interpolate_filter_inst
    (
        .clk            (clk        ),
        .rst_n          (rst_n      ),
        .data_in_I_12   (data_in_I  ),
        .data_in_Q_12   (data_in_Q  ),
        .uk             (uk),  //小数间隔，15bit小数位

        .I_y            (I_y        ),  //I路插值输出
        .Q_y            (Q_y        )       //Q路插值输出
    );
    
    
    //gardner定时误差检测，包含环路滤波器
    gardner_ted #(
        .WN_NOMINAL     (NCO_WN_NOMINAL),
        // 当前插值器/误差量纲下，2^-14 的微分校正适合 2--8 倍采样；
        // 远小于旧实现的 2^-8，避免低过采样时 wn 一次更新跳变过大。
        .LOOP_GAIN_SHIFT    (14),
        .TIMING_TRACK_ENABLE(TIMING_TRACK_ENABLE)
    ) gardner_ted_inst
    (
        .clk                (clk            ),  //500kHz
        .rst_n              (rst_n          ),
        .strobe_flag        (ted_strobe_flag),  //与插值输出对齐的有效标志
        .interpolate_I      (I_y            ),  //从插值滤波器来的I路数据
        .interpolate_Q      (Q_y            ),  //从插值滤波器来的Q路数据

        .sync_out_I         (sync_out_I     ),  //同步后的I路数据
        .sync_out_Q         (sync_out_Q     ),  //同步后的I路数据
        .sync_flag          (sync_flag      ),  //同步标志，代表最佳判决点已到来,用于后续数据抽样
        .wn                 (wn             )   //通过环路滤波器后的误差数据
    );
    
    //nco模块
    nco nco_inst
    (
        .clk            (clk        ),
        .rst_n          (rst_n      ),
        .wn             (wn         ),  //环路滤波器输出的w(n)，低15bit为小数位

        .strobe_flag    (nco_strobe_flag), //NCO 溢出，需经流水线后供 TED 使用
        .uk             (uk         )   //输出到插值滤波器的小数间隔,低15bit为小数位
    );
    
    
    


endmodule
