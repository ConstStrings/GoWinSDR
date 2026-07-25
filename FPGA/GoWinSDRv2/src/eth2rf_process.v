module eth2rf_processor #(
    parameter FRAME_HEAD = 32'hEB90CAD3,  // 帧头标识
    parameter FRAME_TAIL = 32'h55AA5C4B   // 帧尾标识
)(
    // 以太网接收时钟域
    input  wire        eth_rx_clk,
    input  wire        eth_rx_rst_n,
    input  wire [7:0]  rx_data,
    input  wire        rx_data_valid,
    input  wire        rx_frame_start,
    input  wire        rx_frame_end,
    
    // 射频发送时钟域
    input  wire        rf_tx_clk,
    input  wire        rf_tx_rst_n,
    output reg  [7:0]  rf_tx_data,
    output reg         rf_tx_valid,
    output wire        fifo_almost_full  // FIFO快满信号，用于流控
);

    // ========================================
    // 1. 以太网接收侧状态机 (添加帧头帧尾)
    // ========================================
    localparam IDLE       = 4'd0;
    localparam SEND_HEAD1 = 4'd1;
    localparam SEND_HEAD2 = 4'd2;
    localparam SEND_HEAD3 = 4'd3;
    localparam SEND_HEAD4 = 4'd4;
    localparam SEND_DATA  = 4'd5;
    localparam SEND_TAIL1 = 4'd6;
    localparam SEND_TAIL2 = 4'd7;
    localparam SEND_TAIL3 = 4'd8;
    localparam SEND_TAIL4 = 4'd9;
    localparam SEND_LAST1 = 4'd10;
    localparam SEND_LAST2 = 4'd11;
    localparam SEND_LAST3 = 4'd12;
    localparam SEND_LAST4 = 4'd13;
    localparam SEND_LAST5 = 4'd14;

    reg [3:0]  state;
    reg [7:0]  fifo_wr_data;
    reg        fifo_wr_en;
    reg [7:0] temp_data1;
    reg [7:0] temp_data2;
    reg [7:0] temp_data3;
    reg [7:0] temp_data4;
    reg [7:0] temp_data5;
    
    // 状态机：添加帧头和帧尾
    always @(posedge eth_rx_clk or negedge eth_rx_rst_n) begin
        if (!eth_rx_rst_n) begin
            state <= IDLE;
            fifo_wr_data <= 8'd0;
            fifo_wr_en <= 1'b0;
            temp_data1 <= 8'd0;
            temp_data2 <= 8'd0;
            temp_data3 <= 8'd0;
            temp_data4 <= 8'd0;
            temp_data5 <= 8'd0;
        end else begin
            case (state)
                IDLE: begin
                    fifo_wr_en <= 1'b0;
                    if (rx_data_valid) begin
                        state <= SEND_HEAD1;
                        temp_data1 <= rx_data;
                    end
                end
                
                SEND_HEAD1: begin
                    fifo_wr_data <= FRAME_HEAD[31:24];  // 帧头高字节
                    fifo_wr_en <= 1'b1;
                    temp_data1 <= rx_data;
                    temp_data2 <= temp_data1;
                    state <= SEND_HEAD2;
                end
                
                SEND_HEAD2: begin
                    fifo_wr_data <= FRAME_HEAD[23:16];   // 帧头低字节
                    fifo_wr_en <= 1'b1;
                    temp_data1 <= rx_data;
                    temp_data2 <= temp_data1;
                    temp_data3 <= temp_data2;
                    state <= SEND_HEAD3;
                end

                SEND_HEAD3: begin
                    fifo_wr_data <= FRAME_HEAD[15:8];  // 帧头次高字节
                    fifo_wr_en <= 1'b1;
                    temp_data1 <= rx_data;
                    temp_data2 <= temp_data1;
                    temp_data3 <= temp_data2;
                    temp_data4 <= temp_data3;
                    state <= SEND_HEAD4;
                end

                SEND_HEAD4: begin
                    fifo_wr_data <= FRAME_HEAD[7:0];   // 帧头次低字节
                    fifo_wr_en <= 1'b1;
                    temp_data1 <= rx_data;
                    temp_data2 <= temp_data1;
                    temp_data3 <= temp_data2;
                    temp_data4 <= temp_data3;
                    temp_data5 <= temp_data4;
                    state <= SEND_DATA;
                end

                SEND_DATA: begin
                    if (!rx_frame_end) begin
                        temp_data1 <= rx_data;
                        temp_data2 <= temp_data1;
                        temp_data3 <= temp_data2;
                        temp_data4 <= temp_data3;
                        temp_data5 <= temp_data4;
                        fifo_wr_data <= temp_data5;
                        fifo_wr_en <= 1'b1;
                    end else begin
                        fifo_wr_en <= 1'b0;
                        state <= SEND_TAIL1;
                    end
                end
                
                SEND_TAIL1: begin
                    temp_data1 <= FRAME_TAIL[31:24];  // 帧尾高字节
                    temp_data2 <= temp_data1;
                    temp_data3 <= temp_data2;
                    temp_data4 <= temp_data3;
                    temp_data5 <= temp_data4;
                    fifo_wr_data <= temp_data5;
                    fifo_wr_en <= 1'b1;
                    state <= SEND_TAIL2;
                end
                
                SEND_TAIL2: begin
                    temp_data1 <= FRAME_TAIL[23:16];   // 帧尾次低字节
                    temp_data2 <= temp_data1;
                    temp_data3 <= temp_data2;
                    temp_data4 <= temp_data3;
                    temp_data5 <= temp_data4;
                    fifo_wr_data <= temp_data5;
                    fifo_wr_en <= 1'b1;
                    state <= SEND_TAIL3;
                end

                SEND_TAIL3: begin
                    temp_data1 <= FRAME_TAIL[15:8];  // 帧尾次高字节
                    temp_data2 <= temp_data1;
                    temp_data3 <= temp_data2;
                    temp_data4 <= temp_data3;
                    temp_data5 <= temp_data4;
                    fifo_wr_data <= temp_data5;
                    fifo_wr_en <= 1'b1;
                    state <= SEND_TAIL4;
                end

                SEND_TAIL4: begin
                    temp_data1 <= FRAME_TAIL[7:0];   // 帧尾次低字节
                    temp_data2 <= temp_data1;
                    temp_data3 <= temp_data2;
                    temp_data4 <= temp_data3;
                    temp_data5 <= temp_data4;
                    fifo_wr_data <= temp_data5;
                    fifo_wr_en <= 1'b1;
                    state <= SEND_LAST1;
                end

                SEND_LAST1: begin
                    temp_data1 <= 8'd0;
                    temp_data2 <= temp_data1;
                    temp_data3 <= temp_data2;
                    temp_data4 <= temp_data3;
                    temp_data5 <= temp_data4;
                    fifo_wr_data <= temp_data5;
                    fifo_wr_en <= 1'b1;
                    state <= SEND_LAST2;
                end

                SEND_LAST2: begin
                    temp_data2 <= 8'd0;
                    temp_data3 <= temp_data2;
                    temp_data4 <= temp_data3;
                    temp_data5 <= temp_data4;
                    fifo_wr_data <= temp_data5;
                    fifo_wr_en <= 1'b1;
                    state <= SEND_LAST3;
                end

                SEND_LAST3: begin
                    temp_data3 <= 8'd0;
                    temp_data4 <= temp_data3;
                    temp_data5 <= temp_data4;
                    fifo_wr_data <= temp_data5;
                    fifo_wr_en <= 1'b1;
                    state <= SEND_LAST4;
                end

                SEND_LAST4: begin
                    temp_data4 <= 8'd0;
                    temp_data5 <= temp_data4;
                    fifo_wr_data <= temp_data5;
                    fifo_wr_en <= 1'b1;
                    state <= SEND_LAST5;
                end

                SEND_LAST5: begin
                    temp_data5 <= 8'd0;
                    fifo_wr_data <= temp_data5;
                    fifo_wr_en <= 1'b1;
                    state <= IDLE;
                end
                
                default: begin
                    state <= IDLE;
                    fifo_wr_en <= 1'b0;
                end
            endcase
        end
    end

    // ========================================
    // 2. 异步FIFO例化 (跨时钟域)
    // ========================================
    wire [7:0] fifo_rd_data;
    wire       fifo_empty;
    wire       fifo_full;
    reg        fifo_rd_en;
    
    fifo_eth_rx fifo_eth_rx_u0 (
        .Data(fifo_wr_data),        // input [7:0]
        .WrClk(eth_rx_clk),         // input
        .RdClk(rf_tx_clk),          // input
        .WrEn(fifo_wr_en),          // input
        .RdEn(fifo_rd_en),          // input
        .Q(fifo_rd_data),           // output [7:0]
        .Empty(fifo_empty),         // output
        .Full(fifo_full)            // output
    );
    
    // FIFO快满信号生成 (可选，用于背压控制)
    // 注意：需要FIFO IP核支持Almost_Full信号，或者通过计数器估算
    assign fifo_almost_full = fifo_full;  // 简化处理，实际应使用almost_full

    // ========================================
    // 3. 射频发送侧读取控制
    // ========================================
    reg [1:0] rd_state;
    localparam RD_IDLE = 2'd0;
    localparam RD_READ = 2'd1;
    localparam RD_WAIT = 2'd2;
    
    // 读取状态机：从FIFO读取数据并输出
    always @(posedge rf_tx_clk or negedge rf_tx_rst_n) begin
        if (!rf_tx_rst_n) begin
            rd_state <= RD_IDLE;
            fifo_rd_en <= 1'b0;
            rf_tx_data <= 8'd0;
            rf_tx_valid <= 1'b0;
        end else begin
            case (rd_state)
                RD_IDLE: begin
                    fifo_rd_en <= 1'b0;
                    rf_tx_valid <= 1'b0;
                    if (!fifo_empty) begin
                        fifo_rd_en <= 1'b1;
                        rd_state <= RD_READ;
                    end
                end
                
                RD_READ: begin
                    fifo_rd_en <= 1'b0;
                    rd_state <= RD_WAIT;
                end
                
                RD_WAIT: begin

                    rf_tx_data <= fifo_rd_data;
                    rf_tx_valid <= 1'b1;
                    
                    if (!fifo_empty) begin
                        fifo_rd_en <= 1'b1;
                        rd_state <= RD_WAIT;
                    end else begin
                        rd_state <= RD_IDLE;
                    end
                end
                
                default: begin
                    rd_state <= RD_IDLE;
                end
            endcase
        end
    end

endmodule