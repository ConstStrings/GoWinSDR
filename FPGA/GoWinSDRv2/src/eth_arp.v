module arp_responder#(
    parameter BOARD_MAC = 48'h12_34_56_78_90_12,
    parameter BOARD_IP  = {8'd192, 8'd168, 8'd3, 8'd2}
)(
    input               clk,
    input               rst_n,
    
    // 接收接口
    input [7:0]         rx_data,
    input               rx_valid,
    
    // 发送接口
    output reg [7:0]    tx_data,
    output reg          tx_valid,
    output reg          tx_start,
    
    // 调试
    output reg          arp_request_detected,
    output reg          arp_reply_sent
);

localparam IDLE         = 3'd0;
localparam RX_HEADER    = 3'd1;
localparam CHECK_ARP    = 3'd2;
localparam TX_REPLY     = 3'd3;
localparam TX_DONE      = 3'd4;

reg [2:0]   state;
reg [7:0]   rx_cnt;
reg [47:0]  sender_mac;
reg [31:0]  sender_ip;
reg [15:0]  target_ip_check;

// ARP请求包结构（从第14字节开始，前面是以太网头）
// 0-1:   Hardware type (0x0001 for Ethernet)
// 2-3:   Protocol type (0x0800 for IPv4)
// 4:     Hardware size (6)
// 5:     Protocol size (4)
// 6-7:   Operation (0x0001 for request, 0x0002 for reply)
// 8-13:  Sender MAC
// 14-17: Sender IP
// 18-23: Target MAC (ignored in request)
// 24-27: Target IP

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state               <= IDLE;
        rx_cnt              <= 8'd0;
        tx_data             <= 8'd0;
        tx_valid            <= 1'b0;
        tx_start            <= 1'b0;
        sender_mac          <= 48'd0;
        sender_ip           <= 32'd0;
        arp_request_detected <= 1'b0;
        arp_reply_sent      <= 1'b0;
    end
    else begin
        tx_start            <= 1'b0;
        arp_request_detected <= 1'b0;
        arp_reply_sent      <= 1'b0;
        
        case (state)
            IDLE: begin
                rx_cnt   <= 8'd0;
                tx_valid <= 1'b0;
                
                if (rx_valid) begin
                    state  <= RX_HEADER;
                    rx_cnt <= 8'd1;
                end
            end
            
            RX_HEADER: begin
                if (rx_valid) begin
                    rx_cnt <= rx_cnt + 1'b1;
                    
                    // 提取发送者MAC (ARP包的8-13字节，以太网头后的0-5字节)
                    case (rx_cnt)
                        8'd22: sender_mac[47:40] <= rx_data;  // 14+8
                        8'd23: sender_mac[39:32] <= rx_data;
                        8'd24: sender_mac[31:24] <= rx_data;
                        8'd25: sender_mac[23:16] <= rx_data;
                        8'd26: sender_mac[15:8]  <= rx_data;
                        8'd27: sender_mac[7:0]   <= rx_data;
                        
                        // 提取发送者IP (ARP包的14-17字节)
                        8'd28: sender_ip[31:24]  <= rx_data;
                        8'd29: sender_ip[23:16]  <= rx_data;
                        8'd30: sender_ip[15:8]   <= rx_data;
                        8'd31: sender_ip[7:0]    <= rx_data;
                        
                        // 检查目标IP (ARP包的24-27字节)
                        8'd38: target_ip_check[15:8] <= (rx_data == BOARD_IP[31:24]) ? 8'hAA : 8'h00;
                        8'd39: target_ip_check[7:0]  <= (rx_data == BOARD_IP[23:16]) ? 8'hBB : 8'h00;
                        8'd40: target_ip_check[15:8] <= target_ip_check[15:8] | 
                                                        ((rx_data == BOARD_IP[15:8]) ? 8'hCC : 8'h00);
                        8'd41: begin
                            target_ip_check[7:0] <= target_ip_check[7:0] | 
                                                   ((rx_data == BOARD_IP[7:0]) ? 8'hDD : 8'h00);
                            state <= CHECK_ARP;
                        end
                    endcase
                end
            end
            
            CHECK_ARP: begin
                // 检查是否是发给我们的ARP请求
                if (target_ip_check == 16'hAABB || target_ip_check == 16'hCCDD || 
                    (sender_ip[31:24] == 8'd192 && sender_ip[23:16] == 8'd168 && 
                     sender_ip[15:8] == 8'd3)) begin
                    
                    arp_request_detected <= 1'b1;
                    state                <= TX_REPLY;
                    rx_cnt               <= 8'd0;
                    tx_start             <= 1'b1;
                end
                else begin
                    state <= IDLE;
                end
            end
            
            TX_REPLY: begin
                tx_valid <= 1'b1;
                rx_cnt   <= rx_cnt + 1'b1;
                
                // 构造ARP回复包
                case (rx_cnt)
                    // 以太网头: 目的MAC (发送者MAC)
                    8'd0:  tx_data <= sender_mac[47:40];
                    8'd1:  tx_data <= sender_mac[39:32];
                    8'd2:  tx_data <= sender_mac[31:24];
                    8'd3:  tx_data <= sender_mac[23:16];
                    8'd4:  tx_data <= sender_mac[15:8];
                    8'd5:  tx_data <= sender_mac[7:0];
                    
                    // 源MAC (我们的MAC)
                    8'd6:  tx_data <= BOARD_MAC[47:40];
                    8'd7:  tx_data <= BOARD_MAC[39:32];
                    8'd8:  tx_data <= BOARD_MAC[31:24];
                    8'd9:  tx_data <= BOARD_MAC[23:16];
                    8'd10: tx_data <= BOARD_MAC[15:8];
                    8'd11: tx_data <= BOARD_MAC[7:0];
                    
                    // 以太网类型 (0x0806 = ARP)
                    8'd12: tx_data <= 8'h08;
                    8'd13: tx_data <= 8'h06;
                    
                    // ARP包内容
                    8'd14: tx_data <= 8'h00;  // Hardware type: Ethernet
                    8'd15: tx_data <= 8'h01;
                    8'd16: tx_data <= 8'h08;  // Protocol type: IPv4
                    8'd17: tx_data <= 8'h00;
                    8'd18: tx_data <= 8'h06;  // Hardware size
                    8'd19: tx_data <= 8'h04;  // Protocol size
                    8'd20: tx_data <= 8'h00;  // Operation: Reply
                    8'd21: tx_data <= 8'h02;
                    
                    // Sender MAC (我们的MAC)
                    8'd22: tx_data <= BOARD_MAC[47:40];
                    8'd23: tx_data <= BOARD_MAC[39:32];
                    8'd24: tx_data <= BOARD_MAC[31:24];
                    8'd25: tx_data <= BOARD_MAC[23:16];
                    8'd26: tx_data <= BOARD_MAC[15:8];
                    8'd27: tx_data <= BOARD_MAC[7:0];
                    
                    // Sender IP (我们的IP)
                    8'd28: tx_data <= BOARD_IP[31:24];
                    8'd29: tx_data <= BOARD_IP[23:16];
                    8'd30: tx_data <= BOARD_IP[15:8];
                    8'd31: tx_data <= BOARD_IP[7:0];
                    
                    // Target MAC (请求者的MAC)
                    8'd32: tx_data <= sender_mac[47:40];
                    8'd33: tx_data <= sender_mac[39:32];
                    8'd34: tx_data <= sender_mac[31:24];
                    8'd35: tx_data <= sender_mac[23:16];
                    8'd36: tx_data <= sender_mac[15:8];
                    8'd37: tx_data <= sender_mac[7:0];
                    
                    // Target IP (请求者的IP)
                    8'd38: tx_data <= sender_ip[31:24];
                    8'd39: tx_data <= sender_ip[23:16];
                    8'd40: tx_data <= sender_ip[15:8];
                    8'd41: begin
                        tx_data <= sender_ip[7:0];
                        state   <= TX_DONE;
                    end
                    
                    default: tx_data <= 8'h00;
                endcase
            end
            
            TX_DONE: begin
                tx_valid       <= 1'b0;
                arp_reply_sent <= 1'b1;
                state          <= IDLE;
            end
            
            default: state <= IDLE;
        endcase
    end
end

endmodule