module eth_transceiver#(
    parameter BOARD_MAC     = 48'h12_34_56_78_90_12,
    parameter BOARD_IP      = {8'd192,8'd168,8'd3,8'd2},
    parameter BOARD_PORT    = 16'h8000,
    parameter DES_MAC       = 48'hff_ff_ff_ff_ff_ff,
    parameter DES_IP        = {8'd192,8'd168,8'd3,8'd3},
    parameter DES_PORT      = 16'h8000
)(
    input               sys_clk,
    input               rst_n,
    
    // PHY接口 - RGMII
    input               RGMII_RXCLK,        // 接收时钟
    input [3:0]         RGMII_RXD,          // 接收数据
    input               RGMII_RXDV,         // 接收数据有效
    
    output              RGMII_GTXCLK,       // 发送时钟
    output [3:0]        RGMII_TXD,          // 发送数据
    output              RGMII_TXEN,         // 发送使能
    output              RGMII_RST_N,        // PHY复位
    
    // 用户发送接口
    input [7:0]         tx_data,            // 待发送数据
    input               tx_data_valid,      // 发送数据有效
    input               tx_frame_start,     // 开始发送帧
    output              tx_ready,           // 准备发送
    
    // 用户接收接口
    output [7:0]        rx_data,            // 接收到的数据
    output              rx_data_valid,      // 接收数据有效
    output              rx_frame_start,     // 帧开始
    output              rx_frame_end,       // 帧结束
    output [15:0]       udp_length,         // UDP数据报长度
    
    // 状态指示
    output              eth_active,
    output              rx_activity,
    output              tx_activity
);

wire tx_active;
wire rx_active;
assign eth_active = tx_active || rx_active;
assign rx_activity = rx_active;
assign tx_activity = tx_active;

/////////////////////////////////////////////////////////////////////////////////////////
// 时钟生成
/////////////////////////////////////////////////////////////////////////////////////////
wire clk_125m;

GMII_PLL pll_inst(
    .clkin      (sys_clk        ),
    .clkout0    (clk_125m       ),  // 125MHz for RGMII
    .clkout1    (clk_125m_90    )   
);

assign RGMII_GTXCLK = clk_125m;
assign RGMII_RST_N = rst_n;

/////////////////////////////////////////////////////////////////////////////////////////
// RGMII转GMII - 接收路径
/////////////////////////////////////////////////////////////////////////////////////////
wire [7:0]  gmii_rxd;
wire        gmii_rxdv;
wire        gmii_rxer;
wire        gmii_rx_ok;
wire        gmii_rxdv_rise;
wire [7:0]  rgmii_rxd_ddr;
wire [1:0]  rgmii_rx_ctl_ddr;
reg  [7:0]  gmii_rxd_reg;
reg         gmii_rxdv_reg;
reg         gmii_rxer_reg;
reg         gmii_rxdv_d;

// DDR采样实现RGMII转GMII
eth_DDR rgmii_rx_data_ddr_u(
    .din    (RGMII_RXD   ), //input [3:0] din
    .clk    (RGMII_RXCLK ), //input clk
    .q      (rgmii_rxd_ddr)  //output [7:0] q
);

eth_rxdv_ddr rgmii_rx_ctl_ddr_u(
    .din    (RGMII_RXDV  ), //input [0:0] din
    .clk    (RGMII_RXCLK ), //input clk
    .q      (rgmii_rx_ctl_ddr)  //output [1:0] q
);

always @(posedge RGMII_RXCLK or negedge rst_n) begin
    if (!rst_n) begin
        gmii_rxd_reg  <= 8'd0;
        gmii_rxdv_reg <= 1'b0;
        gmii_rxer_reg <= 1'b0;
        gmii_rxdv_d   <= 1'b0;
    end
    else begin
        gmii_rxd_reg  <= rgmii_rxd_ddr;
        gmii_rxdv_reg <= rgmii_rx_ctl_ddr[0];
        gmii_rxer_reg <= rgmii_rx_ctl_ddr[0] ^ rgmii_rx_ctl_ddr[1];
        gmii_rxdv_d   <= gmii_rxdv_reg;
    end
end

assign gmii_rxd  = gmii_rxd_reg;
assign gmii_rxdv = gmii_rxdv_reg;
assign gmii_rxer = gmii_rxer_reg;
assign gmii_rx_ok = gmii_rxdv;
assign gmii_rxdv_rise = gmii_rxdv && !gmii_rxdv_d;

/////////////////////////////////////////////////////////////////////////////////////////
// 以太网接收解析
/////////////////////////////////////////////////////////////////////////////////////////
localparam RX_IDLE      = 4'd0;
localparam RX_PREAMBLE  = 4'd1;
localparam RX_DEST_MAC  = 4'd2;
localparam RX_SRC_MAC   = 4'd3;
localparam RX_ETH_TYPE  = 4'd4;
localparam RX_IP_HEAD   = 4'd5;
localparam RX_UDP_HEAD  = 4'd6;
localparam RX_PAYLOAD   = 4'd7;
localparam RX_END       = 4'd8;
localparam RX_ARP       = 4'd9;

reg [3:0]   rx_state;
reg [15:0]  rx_cnt;
reg [47:0]  rx_dest_mac;
reg [47:0]  rx_src_mac;
reg [15:0]  rx_eth_type;
reg [31:0]  rx_src_ip;
reg [15:0]  rx_src_port;
reg [15:0]  rx_dest_port;
reg [15:0]  udp_length_reg;
reg [15:0]  arp_hw_type;
reg [15:0]  arp_proto_type;
reg [7:0]   arp_hw_len;
reg [7:0]   arp_proto_len;
reg [15:0]  arp_opcode;
reg [47:0]  arp_sender_mac;
reg [31:0]  arp_sender_ip;
reg [31:0]  arp_target_ip;
reg         arp_request_toggle;

reg [7:0]   rx_data_reg;
reg         rx_data_valid_reg;
reg         rx_frame_start_reg;
reg         rx_frame_end_reg;
reg         rx_active_reg;

assign rx_data        = rx_data_reg;
assign rx_data_valid  = rx_data_valid_reg;
assign rx_frame_start = rx_frame_start_reg;
assign rx_frame_end   = rx_frame_end_reg;
assign rx_active      = rx_active_reg;
assign udp_length = udp_length_reg;

// 接收状态机
always @(posedge RGMII_RXCLK or negedge rst_n) begin
    if (!rst_n) begin
        rx_state            <= RX_IDLE;
        rx_cnt              <= 16'd0;
        rx_data_reg         <= 8'd0;
        rx_data_valid_reg   <= 1'b0;
        rx_frame_start_reg  <= 1'b0;
        rx_frame_end_reg    <= 1'b0;
        rx_active_reg       <= 1'b0;
        rx_dest_port        <= 16'd0;
        udp_length_reg      <= 16'd0;
        arp_hw_type         <= 16'd0;
        arp_proto_type      <= 16'd0;
        arp_hw_len          <= 8'd0;
        arp_proto_len       <= 8'd0;
        arp_opcode          <= 16'd0;
        arp_sender_mac      <= 48'd0;
        arp_sender_ip       <= 32'd0;
        arp_target_ip       <= 32'd0;
        arp_request_toggle  <= 1'b0;
    end
    else begin
        rx_frame_start_reg <= 1'b0;
        rx_frame_end_reg   <= 1'b0;
        
        case (rx_state)
            RX_IDLE: begin
                rx_cnt              <= 16'd0;
                rx_data_valid_reg   <= 1'b0;
                rx_active_reg       <= 1'b0;
                
                if (gmii_rxdv_rise && gmii_rxd == 8'h55) begin
                    rx_state <= RX_PREAMBLE;
                end
            end
            
            RX_PREAMBLE: begin
                if (gmii_rx_ok) begin
                    if (gmii_rxd == 8'hD5) begin
                        rx_state            <= RX_DEST_MAC;
                        rx_cnt              <= 16'd0;
                        rx_frame_start_reg  <= 1'b1;
                        rx_active_reg       <= 1'b1;
                    end
                    else if (gmii_rxd != 8'h55) begin
                        rx_state <= RX_IDLE;
                    end
                end
                else begin
                    rx_state <= RX_IDLE;
                end
            end
            
            RX_DEST_MAC: begin
                if (gmii_rx_ok) begin
                    rx_dest_mac <= {rx_dest_mac[39:0], gmii_rxd};
                    rx_cnt      <= rx_cnt + 1'b1;
                    if (rx_cnt == 16'd5) begin
                        rx_state <= RX_SRC_MAC;
                        rx_cnt   <= 16'd0;
                    end
                end
                else begin
                    rx_state <= RX_IDLE;
                end
            end
            
            RX_SRC_MAC: begin
                if (gmii_rx_ok) begin
                    rx_src_mac <= {rx_src_mac[39:0], gmii_rxd};
                    rx_cnt     <= rx_cnt + 1'b1;
                    if (rx_cnt == 16'd5) begin
                        rx_state <= RX_ETH_TYPE;
                        rx_cnt   <= 16'd0;
                    end
                end
                else begin
                    rx_state <= RX_IDLE;
                end
            end
            
            RX_ETH_TYPE: begin
                if (gmii_rx_ok) begin
                    rx_eth_type <= {rx_eth_type[7:0], gmii_rxd};
                    rx_cnt      <= rx_cnt + 1'b1;
                    if (rx_cnt == 16'd1) begin
                        // 检查MAC和类型
                        if (({rx_eth_type[7:0], gmii_rxd} == 16'h0800) && 
                            ((rx_dest_mac == BOARD_MAC) || (rx_dest_mac == 48'hFF_FF_FF_FF_FF_FF))) begin
                            rx_state <= RX_IP_HEAD;
                            rx_cnt   <= 16'd0;
                        end
                        else if (({rx_eth_type[7:0], gmii_rxd} == 16'h0806) &&
                            ((rx_dest_mac == BOARD_MAC) || (rx_dest_mac == 48'hFF_FF_FF_FF_FF_FF))) begin
                            rx_state <= RX_ARP;
                            rx_cnt   <= 16'd0;
                        end
                        else begin
                            rx_state <= RX_END;
                        end
                    end
                end
                else begin
                    rx_state <= RX_IDLE;
                end
            end

            RX_ARP: begin
                if (gmii_rx_ok) begin
                    rx_cnt <= rx_cnt + 1'b1;

                    case (rx_cnt)
                        16'd0:  arp_hw_type[15:8]    <= gmii_rxd;
                        16'd1:  arp_hw_type[7:0]     <= gmii_rxd;
                        16'd2:  arp_proto_type[15:8] <= gmii_rxd;
                        16'd3:  arp_proto_type[7:0]  <= gmii_rxd;
                        16'd4:  arp_hw_len           <= gmii_rxd;
                        16'd5:  arp_proto_len        <= gmii_rxd;
                        16'd6:  arp_opcode[15:8]     <= gmii_rxd;
                        16'd7:  arp_opcode[7:0]      <= gmii_rxd;
                        16'd8:  arp_sender_mac[47:40] <= gmii_rxd;
                        16'd9:  arp_sender_mac[39:32] <= gmii_rxd;
                        16'd10: arp_sender_mac[31:24] <= gmii_rxd;
                        16'd11: arp_sender_mac[23:16] <= gmii_rxd;
                        16'd12: arp_sender_mac[15:8]  <= gmii_rxd;
                        16'd13: arp_sender_mac[7:0]   <= gmii_rxd;
                        16'd14: arp_sender_ip[31:24]  <= gmii_rxd;
                        16'd15: arp_sender_ip[23:16]  <= gmii_rxd;
                        16'd16: arp_sender_ip[15:8]   <= gmii_rxd;
                        16'd17: arp_sender_ip[7:0]    <= gmii_rxd;
                        16'd24: arp_target_ip[31:24]  <= gmii_rxd;
                        16'd25: arp_target_ip[23:16]  <= gmii_rxd;
                        16'd26: arp_target_ip[15:8]   <= gmii_rxd;
                        16'd27: begin
                            arp_target_ip[7:0] <= gmii_rxd;

                            if ((arp_hw_type == 16'h0001) &&
                                (arp_proto_type == 16'h0800) &&
                                (arp_hw_len == 8'h06) &&
                                (arp_proto_len == 8'h04) &&
                                (arp_opcode == 16'h0001) &&
                                ({arp_target_ip[31:8], gmii_rxd} == BOARD_IP)) begin
                                arp_request_toggle <= ~arp_request_toggle;
                            end

                            rx_state <= RX_END;
                        end
                    endcase
                end
                else begin
                    rx_state <= RX_IDLE;
                end
            end
            
            RX_IP_HEAD: begin
                if (gmii_rx_ok) begin
                    rx_cnt <= rx_cnt + 1'b1;
                    
                    case (rx_cnt)
                        16'd12: rx_src_ip[31:24]     <= gmii_rxd;
                        16'd13: rx_src_ip[23:16]     <= gmii_rxd;
                        16'd14: rx_src_ip[15:8]      <= gmii_rxd;
                        16'd15: rx_src_ip[7:0]       <= gmii_rxd;
                    endcase
                    
                    if (rx_cnt == 16'd19) begin
                        rx_state <= RX_UDP_HEAD;
                        rx_cnt   <= 16'd0;
                    end
                end
                else begin
                    rx_state <= RX_IDLE;
                end
            end
            
            RX_UDP_HEAD: begin
                if (gmii_rx_ok) begin
                    rx_cnt <= rx_cnt + 1'b1;
                    
                    case (rx_cnt)
                        16'd0: rx_src_port[15:8]  <= gmii_rxd;
                        16'd1: rx_src_port[7:0]   <= gmii_rxd;
                        16'd2: rx_dest_port[15:8] <= gmii_rxd;
                        16'd3: rx_dest_port[7:0]  <= gmii_rxd;
                        16'd4: udp_length_reg[15:8] <= gmii_rxd;
                        16'd5: udp_length_reg[7:0]  <= gmii_rxd;
                    endcase
                    
                    if (rx_cnt == 16'd7) begin
                        if (rx_dest_port == BOARD_PORT) begin
                            rx_state <= RX_PAYLOAD;
                            rx_cnt   <= 16'd0;
                            // rx_data_valid_reg <= 1'b1;
                            // rx_data_reg       <= gmii_rxd;
                        end
                        else begin
                            rx_state <= RX_END;
                        end
                    end
                end
                else begin
                    rx_state <= RX_IDLE;
                end
            end
            
            RX_PAYLOAD: begin
                if (gmii_rx_ok) begin
                    rx_data_reg       <= gmii_rxd;
                    rx_data_valid_reg <= 1'b1;
                    rx_cnt            <= rx_cnt + 1'b1;
                    
                    // UDP数据长度 = UDP总长 - UDP头(8)
                    if (rx_cnt >= (udp_length_reg - 16'd9)) begin
                        // Keep valid asserted for the final payload byte.
                        // RX_END clears it on the following clock.
                        rx_state <= RX_END;
                    end
                end
                else begin
                    rx_state          <= RX_END;
                    rx_data_valid_reg <= 1'b0;
                end
            end
            
            RX_END: begin
                rx_data_valid_reg  <= 1'b0;
                rx_frame_end_reg   <= 1'b1;
                rx_active_reg      <= 1'b0;
                
                if (!gmii_rxdv) begin
                    rx_state <= RX_IDLE;
                end
            end
            
            default: rx_state <= RX_IDLE;
        endcase
    end
end

/////////////////////////////////////////////////////////////////////////////////////////
// 以太网发送
/////////////////////////////////////////////////////////////////////////////////////////
localparam TX_IDLE      = 4'd0;
localparam TX_CHECK_SUM = 4'd1;
localparam TX_PREAMBLE  = 4'd2;
localparam TX_MAC       = 4'd3;
localparam TX_IP_HEAD   = 4'd4;
localparam TX_UDP_HEAD  = 4'd5;
localparam TX_PAYLOAD   = 4'd6;
localparam TX_CRC       = 4'd7;
localparam TX_DELAY     = 4'd8;
localparam TX_ARP       = 4'd9;

reg [3:0]   tx_state;
reg [15:0]  tx_cnt;
localparam integer MAX_UDP_PAYLOAD = 1472; // 1500-byte IP packet - IPv4/UDP headers
reg [7:0]   tx_buffer [0:MAX_UDP_PAYLOAD-1];
reg [15:0]  tx_buf_len;
reg [10:0]  tx_wr_ptr;
reg         tx_buf_ready;

reg [31:0]  ip_header [6:0];
reg [31:0]  ip_checksum_buf;
reg [2:0]   arp_request_sync;
reg         arp_request_seen;
reg         arp_reply_pending;
reg [47:0]  arp_reply_mac;
reg [31:0]  arp_reply_ip;
reg         tx_arp_mode;

wire [31:0] crc_data;
reg         crc_en;
reg [7:0]   gmii_txd;
reg         gmii_txen;

// CRC校验模块
crc crc_inst(
    .Clk        (clk_125m       ),
    .Reset      (tx_frame_start ),
    .Data_in    (gmii_txd       ),
    .Enable     (crc_en         ),
    .Crc        (               ),
    .CrcNext    (crc_data       )
);

// 发送数据缓冲
always @(posedge clk_125m or negedge rst_n) begin
    if (!rst_n) begin
        tx_wr_ptr    <= 11'd0;
        tx_buf_len   <= 16'd0;
        tx_buf_ready <= 1'b0;
    end
    else begin
        if (tx_frame_start) begin
            tx_wr_ptr    <= 11'd0;
            tx_buf_len   <= 16'd0;
            tx_buf_ready <= 1'b0;
        end
        else if (tx_data_valid && !tx_buf_ready) begin
            // Keep writes within one standard-MTU UDP payload.  The RF bridge
            // enforces the same bound, but this protects this interface too.
            if (tx_wr_ptr < MAX_UDP_PAYLOAD) begin
                tx_buffer[tx_wr_ptr] <= tx_data;
                tx_wr_ptr            <= tx_wr_ptr + 1'b1;
                tx_buf_len           <= tx_wr_ptr + 1'b1;
            end
        end
        else if (tx_state == TX_DELAY && tx_cnt[3]) begin
            tx_buf_ready <= 1'b0;
            tx_wr_ptr    <= 11'd0;
        end
        
        // 判断缓冲区是否准备好发送
        if (!tx_data_valid && tx_wr_ptr > 0 && !tx_buf_ready) begin
            tx_buf_ready <= 1'b1;
        end
    end
end

assign tx_ready = (tx_state == TX_IDLE) && !tx_buf_ready;
assign tx_active = (tx_state != TX_IDLE);

// 发送状态机
always @(posedge clk_125m or negedge rst_n) begin
    if (!rst_n) begin
        tx_state    <= TX_IDLE;
        tx_cnt      <= 16'd0;
        gmii_txd    <= 8'd0;
        gmii_txen   <= 1'b0;
        crc_en      <= 1'b0;
        arp_request_sync <= 3'b000;
        arp_request_seen <= 1'b0;
        arp_reply_pending <= 1'b0;
        arp_reply_mac <= 48'd0;
        arp_reply_ip <= 32'd0;
        tx_arp_mode <= 1'b0;
    end
    else begin
        arp_request_sync <= {arp_request_sync[1:0], arp_request_toggle};
        if (arp_request_sync[2] != arp_request_seen) begin
            arp_request_seen   <= arp_request_sync[2];
            arp_reply_pending <= 1'b1;
            arp_reply_mac     <= arp_sender_mac;
            arp_reply_ip      <= arp_sender_ip;
        end

        case (tx_state)
            TX_IDLE: begin
                tx_cnt    <= 16'd0;
                gmii_txen <= 1'b0;
                gmii_txd  <= 8'd0;
                crc_en    <= 1'b0;
                
                if (arp_reply_pending) begin
                    arp_reply_pending <= 1'b0;
                    tx_arp_mode       <= 1'b1;
                    tx_state          <= TX_PREAMBLE;
                end
                else if (tx_buf_ready && tx_buf_len > 0) begin
                    tx_arp_mode <= 1'b0;
                    // 准备IP头
                    ip_header[0] <= {16'h4500, tx_buf_len + 16'd28};
                    ip_header[1] <= {5'b00000, 11'd0, 16'h4000};
                    ip_header[2] <= {8'h80, 8'h11, 16'h0000};
                    ip_header[3] <= BOARD_IP;
                    ip_header[4] <= (rx_state == RX_IDLE) ? DES_IP : rx_src_ip;  // 鑷姩鍥炲
                    ip_header[5] <= {BOARD_PORT, ((rx_state == RX_IDLE) ? DES_PORT : rx_src_port)};
                    ip_header[6] <= {tx_buf_len + 16'd8, 16'h0000};
                    
                    tx_state <= TX_CHECK_SUM;
                end
            end
            
            TX_CHECK_SUM: begin
                tx_cnt <= tx_cnt + 1'b1;
                
                case (tx_cnt)
                    16'd0: ip_checksum_buf <= ((ip_header[0][15:0] + ip_header[0][31:16]) +
                                               (ip_header[1][15:0] + ip_header[1][31:16])) +
                                              (((ip_header[2][15:0] + ip_header[2][31:16]) +
                                               (ip_header[3][15:0] + ip_header[3][31:16])) +
                                               (ip_header[4][15:0] + ip_header[4][31:16]));
                    16'd1: ip_checksum_buf[15:0] <= ip_checksum_buf[31:16] + ip_checksum_buf[15:0];
                    16'd2: begin
                        ip_header[2][15:0] <= ~ip_checksum_buf[15:0];
                        tx_state <= TX_PREAMBLE;
                        tx_cnt   <= 16'd0;
                    end
                endcase
            end
            
            TX_PREAMBLE: begin
                tx_cnt    <= tx_cnt + 1'b1;
                gmii_txen <= 1'b1;
                
                if (tx_cnt < 16'd7)
                    gmii_txd <= 8'h55;
                else
                    gmii_txd <= 8'hD5;
                
                if (tx_cnt == 16'd7) begin
                    tx_state <= TX_MAC;
                    tx_cnt   <= 16'd0;
                end
            end
            
            TX_MAC: begin
                tx_cnt <= tx_cnt + 1'b1;
                crc_en <= 1'b1;
                
                // 鐩殑MAC + 婧怣AC + 绫诲瀷
                if (tx_cnt < 16'd6) begin
                    // 自动回复模式或广播模式
                    if (tx_arp_mode)
                        gmii_txd <= arp_reply_mac[(5 - tx_cnt) * 8 +: 8];
                    else if (rx_state == RX_IDLE)
                        gmii_txd <= DES_MAC[(5 - tx_cnt) * 8 +: 8];
                    else
                        gmii_txd <= rx_src_mac[(5 - tx_cnt) * 8 +: 8];
                end
                else if (tx_cnt < 16'd12)
                    gmii_txd <= BOARD_MAC[(11 - tx_cnt) * 8 +: 8];
                else if (tx_cnt == 16'd12)
                    gmii_txd <= 8'h08;
                else
                    gmii_txd <= tx_arp_mode ? 8'h06 : 8'h00;
                
                if (tx_cnt == 16'd13) begin
                    tx_state <= tx_arp_mode ? TX_ARP : TX_IP_HEAD;
                    tx_cnt   <= 16'd0;
                end
            end

            TX_ARP: begin
                tx_cnt <= tx_cnt + 1'b1;

                case (tx_cnt)
                    16'd0:  gmii_txd <= 8'h00;
                    16'd1:  gmii_txd <= 8'h01;
                    16'd2:  gmii_txd <= 8'h08;
                    16'd3:  gmii_txd <= 8'h00;
                    16'd4:  gmii_txd <= 8'h06;
                    16'd5:  gmii_txd <= 8'h04;
                    16'd6:  gmii_txd <= 8'h00;
                    16'd7:  gmii_txd <= 8'h02;
                    16'd8:  gmii_txd <= BOARD_MAC[47:40];
                    16'd9:  gmii_txd <= BOARD_MAC[39:32];
                    16'd10: gmii_txd <= BOARD_MAC[31:24];
                    16'd11: gmii_txd <= BOARD_MAC[23:16];
                    16'd12: gmii_txd <= BOARD_MAC[15:8];
                    16'd13: gmii_txd <= BOARD_MAC[7:0];
                    16'd14: gmii_txd <= BOARD_IP[31:24];
                    16'd15: gmii_txd <= BOARD_IP[23:16];
                    16'd16: gmii_txd <= BOARD_IP[15:8];
                    16'd17: gmii_txd <= BOARD_IP[7:0];
                    16'd18: gmii_txd <= arp_reply_mac[47:40];
                    16'd19: gmii_txd <= arp_reply_mac[39:32];
                    16'd20: gmii_txd <= arp_reply_mac[31:24];
                    16'd21: gmii_txd <= arp_reply_mac[23:16];
                    16'd22: gmii_txd <= arp_reply_mac[15:8];
                    16'd23: gmii_txd <= arp_reply_mac[7:0];
                    16'd24: gmii_txd <= arp_reply_ip[31:24];
                    16'd25: gmii_txd <= arp_reply_ip[23:16];
                    16'd26: gmii_txd <= arp_reply_ip[15:8];
                    16'd27: gmii_txd <= arp_reply_ip[7:0];
                    default: gmii_txd <= 8'h00;
                endcase

                if (tx_cnt == 16'd45) begin
                    tx_state <= TX_CRC;
                    tx_cnt   <= 16'd0;
                end
            end
            
            TX_IP_HEAD: begin
                tx_cnt   <= tx_cnt + 1'b1;
                gmii_txd <= ip_header[tx_cnt[4:2]][(3 - tx_cnt[1:0]) * 8 +: 8];
                
                if (tx_cnt == 16'd19) begin
                    tx_state <= TX_UDP_HEAD;
                    tx_cnt   <= 16'd0;
                end
            end
            
            TX_UDP_HEAD: begin
                tx_cnt   <= tx_cnt + 1'b1;
                // gmii_txd <= ip_header[5 + tx_cnt[3]][(3 - tx_cnt[1:0]) * 8 +: 8];
                gmii_txd <= ip_header[5 + tx_cnt[2]][(3 - tx_cnt[1:0]) * 8 +: 8];
                
                if (tx_cnt == 16'd7) begin
                    tx_state <= TX_PAYLOAD;
                    tx_cnt   <= 16'd0;
                end
            end
            
            TX_PAYLOAD: begin
                tx_cnt   <= tx_cnt + 1'b1;
                gmii_txd <= tx_buffer[tx_cnt];
                if (tx_cnt == tx_buf_len - 1) begin
                    tx_state <= TX_CRC;
                    tx_cnt   <= 16'd0;
                end
            end
            
            TX_CRC: begin
                tx_cnt <= tx_cnt + 1'b1;
                crc_en   <= 1'b0;
                
                case (tx_cnt[1:0])
                    2'd0: gmii_txd <= {~crc_data[24], ~crc_data[25], ~crc_data[26], ~crc_data[27],
                                      ~crc_data[28], ~crc_data[29], ~crc_data[30], ~crc_data[31]};
                    2'd1: gmii_txd <= {~crc_data[16], ~crc_data[17], ~crc_data[18], ~crc_data[19],
                                      ~crc_data[20], ~crc_data[21], ~crc_data[22], ~crc_data[23]};
                    2'd2: gmii_txd <= {~crc_data[8], ~crc_data[9], ~crc_data[10], ~crc_data[11],
                                      ~crc_data[12], ~crc_data[13], ~crc_data[14], ~crc_data[15]};
                    2'd3: gmii_txd <= {~crc_data[0], ~crc_data[1], ~crc_data[2], ~crc_data[3],
                                      ~crc_data[4], ~crc_data[5], ~crc_data[6], ~crc_data[7]};
                endcase
                
                if (tx_cnt == 16'd3) begin
                    tx_state <= TX_DELAY;
                    tx_cnt   <= 16'd0;
                end
            end
            
            TX_DELAY: begin
                tx_cnt    <= tx_cnt + 1'b1;
                gmii_txen <= 1'b0;
                gmii_txd  <= 8'd0;
                
                if (tx_cnt[3]) begin
                    tx_state <= TX_IDLE;
                end
            end
            
            default: tx_state <= TX_IDLE;
        endcase
    end
end

/////////////////////////////////////////////////////////////////////////////////////////
// GMII转RGMII - 发送路径
/////////////////////////////////////////////////////////////////////////////////////////
reg [7:0] gmii_txd_r;
reg gmii_txen_r;

always @(posedge clk_125m) begin
    gmii_txd_r  <= gmii_txd;
    gmii_txen_r <= gmii_txen;
end

// DDR输出
reg [3:0] txd_h, txd_l;
always @(posedge clk_125m) begin
    txd_h <= gmii_txd_r[7:4];
    txd_l <= gmii_txd_r[3:0];
end

GMII2RGMII gmii2rgmii_inst(
    .clk    (clk_125m   ),
    .din    (gmii_txd_r ),
    .q      (RGMII_TXD  )
);

// RGMII TX_CTL must use the same DDR launch mechanism as TXD.  A fabric
// output register can be edge-shifted relative to the DDR data at the PHY,
// causing the final byte to be excluded from the valid window.
wire rgmii_txen_q1;
ODDR rgmii_txen_oddr (
    .Q0 (RGMII_TXEN),
    .Q1 (rgmii_txen_q1),
    .D0 (gmii_txen_r),
    .D1 (gmii_txen_r),
    .TX (1'b0),
    .CLK(clk_125m)
);

// Retained solely for the existing ILA probe configuration.  It is no longer
// on the RGMII TX_CTL timing path.
reg [2:0] txen_pipe;
always @(posedge clk_125m) begin
    txen_pipe <= {txen_pipe[1:0], gmii_txen_r};
end

endmodule

