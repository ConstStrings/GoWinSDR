// RF payload -> Ethernet UDP transmitter bridge.
//
// The RF receiver and Ethernet transmitter use unrelated clocks.  Payload
// bytes cross only through the dual-clock FIFO below; the packet-complete
// counter is Gray encoded before crossing into eth_tx_clk.  Ethernet sending
// begins only after the complete RF packet (including its end marker) is in
// the FIFO.  The Ethernet-domain packet buffer is then filled before one
// uninterrupted tx_data_valid burst is presented to eth_transceiver.
module rf2eth_processor #(
    // 2^11 = 2048 entries.  This accommodates a full Ethernet-MTU UDP
    // payload (1472 bytes) plus the internal end-of-packet marker.
    parameter integer FIFO_ADDR_WIDTH    = 11,
    parameter integer RF_IDLE_CYCLES     = 64,  // > 16 sample clocks/byte
    parameter integer PACKET_COUNT_WIDTH = 4,
    parameter integer MAX_UDP_PAYLOAD    = 1472
) (
    // RF receive clock domain
    input  wire       rf_rx_clk,
    input  wire       rf_rx_rst_n,
    input  wire [7:0] rf_rx_data,
    input  wire       rf_rx_data_valid,
    output reg        rf_rx_overflow,

    // Ethernet user-TX clock domain (RGMII_GTXCLK / 125 MHz)
    input  wire       eth_tx_clk,
    input  wire       eth_tx_rst_n,
    input  wire       eth_tx_ready,
    // A complete RF packet is waiting in the Ethernet-clock-domain FIFO.
    // This is a request, not a grant.  The top-level packet arbiter uses it
    // to ensure this source never races a control/status packet.
    output wire       eth_tx_request,
    output reg  [7:0] eth_tx_data,
    output reg        eth_tx_data_valid,
    output reg        eth_tx_frame_start
);

localparam integer PTR_WIDTH = FIFO_ADDR_WIDTH + 1;

// FIFO word bit [8] is an end-of-packet marker.  It is never sent to Ethernet.
(* ram_style = "block" *) reg [8:0] fifo_mem [0:(1<<FIFO_ADDR_WIDTH)-1];

// eth_transceiver treats the first low cycle of tx_data_valid as end of
// packet.  A synchronous FIFO read cannot be forwarded directly because it
// would insert bubbles.  Stage a completed RF packet here, then replay it at
// one byte per eth_tx_clk without bubbles.
(* ram_style = "block" *) reg [7:0] eth_packet_mem [0:(1<<FIFO_ADDR_WIDTH)-1];

reg [PTR_WIDTH-1:0] wr_bin, wr_gray;
reg [PTR_WIDTH-1:0] rd_bin, rd_gray;
reg [PTR_WIDTH-1:0] rd_gray_wsync1, rd_gray_wsync2;
reg [PTR_WIDTH-1:0] wr_gray_rsync1, wr_gray_rsync2;
reg                 fifo_full, fifo_empty;

reg [8:0] fifo_rd_data;
reg       fifo_rd_valid;
reg       fifo_rd_en;

// RF-domain packet delimiter generation state.
reg [15:0] rf_idle_count;
reg        rf_packet_open;

function [PTR_WIDTH-1:0] bin_to_gray;
    input [PTR_WIDTH-1:0] bin_value;
    begin
        bin_to_gray = (bin_value >> 1) ^ bin_value;
    end
endfunction

wire rf_idle_timeout = (RF_IDLE_CYCLES <= 1) ? 1'b1 :
                       (rf_idle_count >= RF_IDLE_CYCLES - 1);
wire fifo_write_eop  = rf_packet_open && !rf_rx_data_valid && rf_idle_timeout;
wire fifo_write_req  = rf_rx_data_valid || fifo_write_eop;
wire [8:0] fifo_write_data = fifo_write_eop ? 9'h100 :
                                               {1'b0, rf_rx_data};

wire [PTR_WIDTH-1:0] wr_bin_next  = wr_bin + ((fifo_write_req && !fifo_full) ? 1'b1 : 1'b0);
wire [PTR_WIDTH-1:0] wr_gray_next = bin_to_gray(wr_bin_next);
wire fifo_full_next = (wr_gray_next ==
    {~rd_gray_wsync2[PTR_WIDTH-1:PTR_WIDTH-2], rd_gray_wsync2[PTR_WIDTH-3:0]});

wire [PTR_WIDTH-1:0] rd_bin_next  = rd_bin + ((fifo_rd_en && !fifo_empty) ? 1'b1 : 1'b0);
wire [PTR_WIDTH-1:0] rd_gray_next = bin_to_gray(rd_bin_next);
wire fifo_empty_next = (rd_gray_next == wr_gray_rsync2);

// Packet-complete event counter.  A Gray count, rather than a single toggle,
// preserves multiple queued RF packets while Ethernet is temporarily busy.
reg [PACKET_COUNT_WIDTH-1:0] pkt_wr_bin, pkt_wr_gray;
reg [PACKET_COUNT_WIDTH-1:0] pkt_wr_gray_rsync1, pkt_wr_gray_rsync2;
reg [PACKET_COUNT_WIDTH-1:0] pkt_rd_bin;

function [PACKET_COUNT_WIDTH-1:0] pkt_bin_to_gray;
    input [PACKET_COUNT_WIDTH-1:0] bin_value;
    begin
        pkt_bin_to_gray = (bin_value >> 1) ^ bin_value;
    end
endfunction

wire packet_pending = (pkt_wr_gray_rsync2 != pkt_bin_to_gray(pkt_rd_bin));
assign eth_tx_request = packet_pending;

// RF clock domain: append payload bytes and, after a sufficiently long idle
// interval, append the end marker.  The decoder emits one byte every 16
// sample clocks, hence the default 64-cycle timeout cannot split a payload.
always @(posedge rf_rx_clk or negedge rf_rx_rst_n) begin
    if (!rf_rx_rst_n) begin
        rf_idle_count <= 16'd0;
        rf_packet_open <= 1'b0;
        rf_rx_overflow <= 1'b0;
        pkt_wr_bin <= {PACKET_COUNT_WIDTH{1'b0}};
        pkt_wr_gray <= {PACKET_COUNT_WIDTH{1'b0}};
    end else begin
        if (rf_rx_data_valid) begin
            rf_idle_count <= 16'd0;
            rf_packet_open <= 1'b1;
        end else if (rf_packet_open && !rf_idle_timeout) begin
            rf_idle_count <= rf_idle_count + 1'b1;
        end

        if (fifo_write_req && fifo_full) begin
            // The receiver has no ready signal; retain the error for ILA.
            rf_rx_overflow <= 1'b1;
        end

        if (fifo_write_eop && !fifo_full) begin
            rf_packet_open <= 1'b0;
            rf_idle_count <= 16'd0;
            pkt_wr_bin <= pkt_wr_bin + 1'b1;
            pkt_wr_gray <= pkt_bin_to_gray(pkt_wr_bin + 1'b1);
        end
    end
end

always @(posedge rf_rx_clk or negedge rf_rx_rst_n) begin
    if (!rf_rx_rst_n) begin
        wr_bin <= {PTR_WIDTH{1'b0}};
        wr_gray <= {PTR_WIDTH{1'b0}};
        fifo_full <= 1'b0;
        rd_gray_wsync1 <= {PTR_WIDTH{1'b0}};
        rd_gray_wsync2 <= {PTR_WIDTH{1'b0}};
    end else begin
        rd_gray_wsync1 <= rd_gray;
        rd_gray_wsync2 <= rd_gray_wsync1;
        fifo_full <= fifo_full_next;

        if (fifo_write_req && !fifo_full) begin
            fifo_mem[wr_bin[FIFO_ADDR_WIDTH-1:0]] <= fifo_write_data;
            wr_bin <= wr_bin_next;
            wr_gray <= wr_gray_next;
        end
    end
end

// Ethernet clock domain: synchronize the write pointer and packet-complete
// count, then read FIFO words only after a whole packet is known to be ready.
always @(posedge eth_tx_clk or negedge eth_tx_rst_n) begin
    if (!eth_tx_rst_n) begin
        wr_gray_rsync1 <= {PTR_WIDTH{1'b0}};
        wr_gray_rsync2 <= {PTR_WIDTH{1'b0}};
        pkt_wr_gray_rsync1 <= {PACKET_COUNT_WIDTH{1'b0}};
        pkt_wr_gray_rsync2 <= {PACKET_COUNT_WIDTH{1'b0}};
    end else begin
        wr_gray_rsync1 <= wr_gray;
        wr_gray_rsync2 <= wr_gray_rsync1;
        pkt_wr_gray_rsync1 <= pkt_wr_gray;
        pkt_wr_gray_rsync2 <= pkt_wr_gray_rsync1;
    end
end

always @(posedge eth_tx_clk or negedge eth_tx_rst_n) begin
    if (!eth_tx_rst_n) begin
        rd_bin <= {PTR_WIDTH{1'b0}};
        rd_gray <= {PTR_WIDTH{1'b0}};
        fifo_empty <= 1'b1;
        fifo_rd_data <= 9'd0;
        fifo_rd_valid <= 1'b0;
    end else begin
        fifo_rd_valid <= 1'b0;
        fifo_empty <= fifo_empty_next;

        if (fifo_rd_en && !fifo_empty) begin
            fifo_rd_data <= fifo_mem[rd_bin[FIFO_ADDR_WIDTH-1:0]];
            fifo_rd_valid <= 1'b1;
            rd_bin <= rd_bin_next;
            rd_gray <= rd_gray_next;
        end
    end
end

localparam ETH_WAIT_PACKET = 3'd0;
localparam ETH_LOAD_REQUEST = 3'd1;
localparam ETH_LOAD_WAIT = 3'd2;
localparam ETH_START_FRAME = 3'd3;
localparam ETH_SEND_FRAME = 3'd4;
localparam ETH_COMPLETE = 3'd5;

reg [2:0] eth_state;
reg [FIFO_ADDR_WIDTH-1:0] eth_packet_wr_ptr;
reg [FIFO_ADDR_WIDTH-1:0] eth_packet_rd_ptr;
reg [FIFO_ADDR_WIDTH-1:0] eth_packet_len;
reg                       eth_packet_overflow;

always @(posedge eth_tx_clk or negedge eth_tx_rst_n) begin
    if (!eth_tx_rst_n) begin
        eth_state <= ETH_WAIT_PACKET;
        eth_tx_data <= 8'd0;
        eth_tx_data_valid <= 1'b0;
        eth_tx_frame_start <= 1'b0;
        fifo_rd_en <= 1'b0;
        pkt_rd_bin <= {PACKET_COUNT_WIDTH{1'b0}};
        eth_packet_wr_ptr <= {FIFO_ADDR_WIDTH{1'b0}};
        eth_packet_rd_ptr <= {FIFO_ADDR_WIDTH{1'b0}};
        eth_packet_len <= {FIFO_ADDR_WIDTH{1'b0}};
        eth_packet_overflow <= 1'b0;
    end else begin
        // tx_data_valid is assigned high throughout ETH_SEND_FRAME only.
        eth_tx_data_valid <= 1'b0;
        eth_tx_frame_start <= 1'b0;
        fifo_rd_en <= 1'b0;

        case (eth_state)
            ETH_WAIT_PACKET: begin
                if (packet_pending && eth_tx_ready) begin
                    eth_packet_wr_ptr <= {FIFO_ADDR_WIDTH{1'b0}};
                    eth_packet_overflow <= 1'b0;
                    eth_state <= ETH_LOAD_REQUEST;
                end
            end

            // The async FIFO has a registered read port, so this loading
            // phase may contain bubbles.  Those bubbles stay internal.
            ETH_LOAD_REQUEST: begin
                if (!fifo_empty) begin
                    fifo_rd_en <= 1'b1;
                    eth_state <= ETH_LOAD_WAIT;
                end
            end

            ETH_LOAD_WAIT: begin
                if (fifo_rd_valid) begin
                    if (fifo_rd_data[8]) begin
                        // The complete packet is now local to eth_tx_clk.
                        pkt_rd_bin <= pkt_rd_bin + 1'b1;
                        if (!eth_packet_overflow) begin
                            eth_packet_len <= eth_packet_wr_ptr;
                            eth_packet_rd_ptr <= {FIFO_ADDR_WIDTH{1'b0}};
                            eth_state <= ETH_START_FRAME;
                        end else begin
                            // Discard an oversize UDP payload after draining
                            // it completely, so the following packet remains
                            // aligned in the asynchronous FIFO.
                            eth_state <= ETH_WAIT_PACKET;
                        end
                    end else begin
                        if (eth_packet_wr_ptr < MAX_UDP_PAYLOAD) begin
                            eth_packet_mem[eth_packet_wr_ptr] <= fifo_rd_data[7:0];
                            eth_packet_wr_ptr <= eth_packet_wr_ptr + 1'b1;
                        end else begin
                            eth_packet_overflow <= 1'b1;
                        end
                        eth_state <= ETH_LOAD_REQUEST;
                    end
                end
            end

            ETH_START_FRAME: begin
                // Clear eth_transceiver's user TX buffer before streaming.
                eth_tx_frame_start <= 1'b1;
                eth_state <= ETH_SEND_FRAME;
            end

            ETH_SEND_FRAME: begin
                // A valid byte is emitted on every cycle, with no bubbles.
                eth_tx_data <= eth_packet_mem[eth_packet_rd_ptr];
                eth_tx_data_valid <= 1'b1;
                if (eth_packet_rd_ptr == eth_packet_len - 1'b1) begin
                    eth_state <= ETH_COMPLETE;
                end else begin
                    eth_packet_rd_ptr <= eth_packet_rd_ptr + 1'b1;
                end
            end

            ETH_COMPLETE: begin
                // Leave valid low for at least one cycle to commit the
                // eth_transceiver input buffer as one UDP payload.
                eth_state <= ETH_WAIT_PACKET;
            end

            default: eth_state <= ETH_WAIT_PACKET;
        endcase
    end
end

endmodule
