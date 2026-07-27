module eth2rf_processor #(
    parameter FRAME_HEAD = 32'hEB90CAD3,  // 帧头标识
)(
    // 以太网接收时钟域
    input  wire        eth_rx_clk,
    input  wire        eth_rx_rst_n,
    input  wire [7:0]  rx_data,
    input  wire        rx_data_valid,
    input  wire        rx_frame_start,
    input  wire        rx_frame_end,
    input  wire [15:0] rx_data_length,  
    
    // 射频发送时钟域
    input  wire        rf_tx_clk,
    input  wire        rf_tx_rst_n,
    output reg  [7:0]  rf_tx_data,
    output reg         rf_tx_valid,

    output wire        fifo_almost_full  // FIFO快满信号，用于流控
);

localparam IDLE = 3'd0;
localparam SEND_HEAD = 3'd1;
localparam SEND_LEN  = 3'd2;
localparam SEND_PAYLOAD = 3'd3;
localparam SEND_CRC = 3'd4;

reg [2:0] send_state;

reg [41:0] payload_buffer;
reg [7:0]  fifo_data_in;
reg        fifo_wr_en;
reg [15:0] eth_data_cnt;
reg [15:0] payload_length;

always @(posedge eth_rx_clk or negedge eth_rx_rst_n) begin
    if (!eth_rx_rst_n) begin
        send_state <= IDLE;
        payload_buffer <= 42'd0;
        fifo_data_in <= 8'd0;
        fifo_wr_en <= 1'b0;
        payload_length <= 16'd0;
        eth_data_cnt <= 16'd0;
    end
    else begin
        case (send_state)
            IDLE: begin
                payload_buffer <= 42'd0;
                fifo_data_in <= 8'd0;
                eth_data_cnt <= 16'd0;

                if (rx_frame_start) begin
                    send_state <= SEND_HEAD;
                    fifo_wr_en <= 1'b1;
                    payload_length <= rx_data_length;
                end
            end
            SEND_HEAD: begin
                eth_data_cnt <= eth_data_cnt + 1'b1;
                payload_buffer <= {payload_buffer[41:8], rx_data};
                case (eth_data_cnt)
                    16'd0: fifo_data_in <= FRAME_HEAD[31:24];
                    16'd1: fifo_data_in <= FRAME_HEAD[23:16];
                    16'd2: fifo_data_in <= FRAME_HEAD[15:8];
                    16'd3: begin
                        fifo_data_in <= FRAME_HEAD[7:0];
                        send_state <= SEND_LEN;
                        eth_data_cnt <= 16'd0;
                    end
                    default: begin
                        send_state <= IDLE;
                    end
                endcase
            end
            SEND_LEN: begin
                eth_data_cnt <= eth_data_cnt + 1'b1;
                fifo_data_in <= payload_length[15 - 8*eth_data_cnt +: 8];
                payload_buffer <= {payload_buffer[41:8], rx_data};
                if (eth_data_cnt == 16'd1) begin
                    send_state <= SEND_PAYLOAD;
                    eth_data_cnt <= 16'd0;
                end
            end
            SEND_PAYLOAD: begin
                eth_data_cnt <= eth_data_cnt + 1'b1;
                fifo_data_in <= payload_buffer[41:34];
                payload_buffer <= {payload_buffer[41:8], rx_data};
                if (eth_data_cnt == payload_length - 1) begin
                    send_state <= SEND_CRC;
                    eth_data_cnt <= 16'd0;
                end
            end
            SEND_CRC: begin
                eth_data_cnt <= eth_data_cnt + 1'b1;
                fifo_data_in <= 7'd0; // CRC占位符，实际CRC计算可在接收端实现
                if (eth_data_cnt == 16'd3) begin
                    send_state <= IDLE;
                    fifo_wr_en <= 1'b0;
                end
            end
        endcase
    end
end

reg [1:0] rd_state;
localparam RD_IDLE = 2'd0;
localparam RD_READ = 2'd1;
localparam RD_WAIT = 2'd2;

always @(posedge rf_tx_clk or negedge rf_tx_rst_n) begin
    if (!rf_tx_rst_n) begin
        rd_state <= RD_IDLE;
        fifo_rd_en <= 1'b0;
        rf_tx_data <= 8'd0;
        rf_tx_valid <= 1'b0;
    end else begin
        case (rd_state)
            RD_IDLE: begin
                if (!fifo_empty) begin
                    fifo_rd_en <= 1'b1;
                    rd_state <= RD_READ;
                end else begin
                    fifo_rd_en <= 1'b0;
                    rf_tx_valid <= 1'b0;
                end

            end
       
            RD_READ: begin
                rf_tx_data <= fifo_rd_data;
                rf_tx_valid <= 1'b1;
                
                if (fifo_empty) begin
                    rd_state <= RD_IDLE;
                    fifo_rd_en <= 1'b0;
                end else begin
                    fifo_rd_en <= 1'b1; 
                end
            end
            
            default: begin
                rd_state <= RD_IDLE;
            end
        endcase
    end
end

    fifo_eth2rf u_fifo_eth2rf(
		.Data(fifo_data_in), //input [7:0] Data
		.WrClk(eth_rx_clk), //input WrClk
		.RdClk(rf_tx_clk), //input RdClk
		.WrEn(fifo_wr_en), //input WrEn
		.RdEn(fifo_rd_en), //input RdEn
		.Almost_Full(fifo_almost_full), //output Almost_Full
		.Q(fifo_rd_data), //output [7:0] Q
		.Empty(fifo_empty), //output Empty
		.Full() //output Full
	);

endmodule