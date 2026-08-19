module eth2rf_processor #(
    parameter FRAME_HEAD = 32'hEB90CAD3
)(
    // Ethernet receive clock domain
    input  wire        eth_rx_clk,
    input  wire        eth_rx_rst_n,
    input  wire [7:0]  rx_data,
    input  wire        rx_data_valid,
    input  wire        rx_frame_start,
    input  wire        rx_frame_end,
    input  wire [15:0] udp_length,       // UDP datagram length from eth_transceiver

    // RF transmit clock domain
    input  wire        rf_tx_clk,
    input  wire        rf_tx_rst_n,
    input  wire        rf_tx_ready,
    output wire [7:0]  rf_tx_data,
    output reg         rf_tx_valid,

    output wire        fifo_almost_full
);

localparam IDLE         = 3'd0;
localparam SEND_HEAD    = 3'd1;
localparam SKIP_LEN      = 3'd2;   // skip 2-byte embedded length (now from udp_length)
localparam SEND_LEN     = 3'd3;   // output captured length to FIFO
localparam SEND_PAYLOAD = 3'd4;
localparam SEND_CRC     = 3'd5;

reg [2:0] send_state;

reg [47:0] payload_buffer;
reg [7:0]  fifo_data_in;
reg        fifo_wr_en;
reg [15:0] eth_data_cnt;
wire [15:0] payload_length;

assign payload_length = udp_length - 16'd8;  // subtract 8 bytes of UDP header

always @(posedge eth_rx_clk or negedge eth_rx_rst_n) begin
    if (!eth_rx_rst_n) begin
        send_state     <= IDLE;
        payload_buffer <= 48'd0;
        fifo_data_in   <= 8'd0;
        fifo_wr_en     <= 1'b0;
        eth_data_cnt   <= 16'd0;
    end
    else begin
        // Write enable must be a pulse for each byte actually produced.
        // Keeping it asserted across an unrelated Ethernet frame fills the
        // asynchronous FIFO with the reset value (8'h00).
        fifo_wr_en <= 1'b0;

        case (send_state)
            IDLE: begin
                payload_buffer <= 48'd0;
                fifo_data_in   <= 8'd0;
                eth_data_cnt   <= 16'd0;

                // rx_frame_start denotes the beginning of any Ethernet
                // frame, including ARP and UDP packets for other ports.
                // Start only after eth_transceiver has accepted a UDP
                // payload byte (rx_data_valid), so only valid payloads are
                // converted to RF frames.
                if (rx_data_valid) begin
                    send_state <= SEND_HEAD;
                    payload_buffer <= {payload_buffer[39:0], rx_data};
                    fifo_data_in   <= FRAME_HEAD[31:24];
                    fifo_wr_en <= 1'b1;
                    eth_data_cnt <= 16'd1;
                end
            end

            // Send 4-byte FRAME_HEAD to FIFO, buffer incoming bytes 0-3
            SEND_HEAD: begin
                if (rx_data_valid) begin
                    eth_data_cnt   <= eth_data_cnt + 1'b1;
                    payload_buffer <= {payload_buffer[39:0], rx_data};
                    case (eth_data_cnt)
                        16'd1: fifo_data_in <= FRAME_HEAD[23:16];
                        16'd2: fifo_data_in <= FRAME_HEAD[15:8];
                        16'd3: begin
                            fifo_data_in <= FRAME_HEAD[7:0];
                            send_state   <= SEND_LEN;
                            eth_data_cnt <= 16'd0;
                        end
                        default: send_state <= IDLE;
                    endcase
                    fifo_wr_en <= 1'b1;
                end
                else if (rx_frame_end) begin
                    // A truncated frame cannot contain a complete payload.
                    send_state <= IDLE;
                end
            end

            // Output captured length to FIFO (2 bytes)
            SEND_LEN: begin
                eth_data_cnt   <= eth_data_cnt + 1'b1;
                fifo_data_in <= payload_length[15 - 8*eth_data_cnt -: 8];
                payload_buffer <= {payload_buffer[39:0], rx_data};
                fifo_wr_en     <= 1'b1;
                if (eth_data_cnt == 16'd1) begin
                    send_state   <= SEND_PAYLOAD;
                    eth_data_cnt <= 16'd0;
                end
            end

            // Pass through payload from buffer
            SEND_PAYLOAD: begin
                eth_data_cnt   <= eth_data_cnt + 1'b1;
                fifo_data_in   <= payload_buffer[47:40];
                payload_buffer <= {payload_buffer[39:0], rx_data};
                fifo_wr_en     <= 1'b1;
                if (eth_data_cnt == payload_length - 1) begin
                    send_state   <= SEND_CRC;
                    eth_data_cnt <= 16'd0;
                end
            end

            // CRC placeholder (4 zero bytes)
            SEND_CRC: begin
                eth_data_cnt <= eth_data_cnt + 1'b1;
                fifo_data_in <= 8'd0;
                fifo_wr_en   <= 1'b1;
                if (eth_data_cnt == 16'd3) begin
                    send_state <= IDLE;
                end
            end

            default: send_state <= IDLE;
        endcase
    end
end

// ============================================================
// FIFO read side (rf_tx_clk domain)
//
// The FIFO Q port is registered.  Keep Q directly on the ready/valid
// interface and prefetch the following word while the current one is being
// accepted.  After the first-word latency this sustains one byte per
// rf_tx_clk, instead of the former three-cycle IDLE/FETCH/SEND sequence.
// ============================================================
reg       fifo_rd_en;
reg       first_read_pending;
wire [7:0] fifo_rd_data;
wire       fifo_empty;

assign rf_tx_data = fifo_rd_data;

always @(posedge rf_tx_clk or negedge rf_tx_rst_n) begin
    if (!rf_tx_rst_n) begin
        fifo_rd_en        <= 1'b0;
        first_read_pending <= 1'b0;
        rf_tx_valid        <= 1'b0;
    end else begin
        // RdEn is a one-cycle request.  The FIFO updates Q on the following
        // clock edge, while the consumer accepts the previous Q value.
        fifo_rd_en <= 1'b0;

        if (first_read_pending) begin
            // The request issued in the previous cycle has populated Q.
            first_read_pending <= 1'b0;
            rf_tx_valid        <= 1'b1;

            // Begin prefetching the next byte immediately.  If the FIFO had
            // only one byte, its Empty flag suppresses the speculative read
            // on the next clock and valid is cleared after that byte is
            // accepted.
            if (rf_tx_ready && !fifo_empty)
                fifo_rd_en <= 1'b1;
        end else if (rf_tx_valid) begin
            if (rf_tx_ready) begin
                if (!fifo_empty) begin
                    // Current byte is accepted this edge; request the next
                    // one so it replaces Q for the next cycle.
                    fifo_rd_en  <= 1'b1;
                    rf_tx_valid <= 1'b1;
                end else begin
                    // The current Q byte is accepted this edge; no successor
                    // is available.
                    rf_tx_valid <= 1'b0;
                end
            end
        end else if (!fifo_empty && rf_tx_ready) begin
            // Empty-to-nonempty transition: prime the registered FIFO Q.
            fifo_rd_en         <= 1'b1;
            first_read_pending <= 1'b1;
        end
    end
end

fifo_eth2rf u_fifo_eth2rf(
    .Data        (fifo_data_in),
    .WrClk       (eth_rx_clk),
    .RdClk       (rf_tx_clk),
    .WrEn        (fifo_wr_en),
    .RdEn        (fifo_rd_en),
    .Almost_Full (fifo_almost_full),
    .Q           (fifo_rd_data),
    .Empty       (fifo_empty),
    .Full        ()
);

endmodule
