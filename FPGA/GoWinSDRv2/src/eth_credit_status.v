// DDR ingress-credit status UDP-payload source.
//
// A received Ethernet UDP frame creates one status-update request.  Requests
// are deliberately coalesced: while a previous status packet is waiting (or
// being transmitted), the newest credit value replaces the old one.  Thus
// flow-control telemetry can never build an unbounded queue or delay RF data.
//
// Status payload, big endian:
//   43 52 45 44 01 <credit[15:8]> <credit[7:0]> <sequence[15:8]>
//   <ingress_sequence[7:0]>
// i.e. "CRED", protocol version 1, free maximum-MTU packet credits, and the
// sequence of the most recently received Ethernet frame.  The sequence is
// deliberately an ingress sequence (not a status-TX sequence), so a PC can
// account for coalesced status reports safely.
module eth_credit_status (
    input  wire        eth_rx_clk,
    input  wire        eth_rx_rst_n,
    input  wire        rx_frame_end,

    // Generated in the DDR-controller clock domain.  It is synchronized here
    // only for telemetry; DDR ingress_accept remains the authoritative guard.
    input  wire [15:0] credit_value,

    input  wire        eth_tx_clk,
    input  wire        eth_tx_rst_n,
    input  wire        tx_grant,
    output wire        tx_request,
    output reg  [7:0] tx_data,
    output reg         tx_data_valid,
    output reg         tx_frame_start
);

    reg        rx_request_toggle;
    reg [15:0] rx_sequence;
    reg        req_meta, req_sync, req_seen;
    reg [15:0] credit_meta, credit_sync;
    reg [15:0] sequence_meta, sequence_sync;
    reg [15:0] pending_credit;
    reg [15:0] pending_sequence;
    reg        pending;
    reg [1:0]  state;
    reg [3:0]  byte_index;

    localparam ST_IDLE  = 2'd0;
    localparam ST_START = 2'd1;
    localparam ST_SEND  = 2'd2;
    localparam ST_DONE  = 2'd3;

    // A toggle is used rather than a one-cycle pulse because RX and TX clocks
    // are unrelated.  It is safe to merge several received frames into one
    // newest-status report.
    always @(posedge eth_rx_clk or negedge eth_rx_rst_n) begin
        if (!eth_rx_rst_n)
        begin
            rx_request_toggle <= 1'b0;
            rx_sequence       <= 16'd0;
        end else if (rx_frame_end) begin
            rx_request_toggle <= ~rx_request_toggle;
            rx_sequence       <= rx_sequence + 1'b1;
        end
    end

    assign tx_request = pending && (state == ST_IDLE);

    always @(posedge eth_tx_clk or negedge eth_tx_rst_n) begin
        if (!eth_tx_rst_n) begin
            req_meta       <= 1'b0;
            req_sync       <= 1'b0;
            req_seen       <= 1'b0;
            credit_meta    <= 16'd0;
            credit_sync    <= 16'd0;
            sequence_meta  <= 16'd0;
            sequence_sync  <= 16'd0;
            pending_credit <= 16'd0;
            pending_sequence <= 16'd0;
            pending        <= 1'b0;
            state          <= ST_IDLE;
            byte_index     <= 4'd0;
            tx_data        <= 8'd0;
            tx_data_valid  <= 1'b0;
            tx_frame_start <= 1'b0;
        end else begin
            req_meta       <= rx_request_toggle;
            req_sync       <= req_meta;
            credit_meta    <= credit_value;
            credit_sync    <= credit_meta;
            sequence_meta  <= rx_sequence;
            sequence_sync  <= sequence_meta;
            tx_data_valid  <= 1'b0;
            tx_frame_start <= 1'b0;

            // Capture the latest stable synchronized status.  A newer update
            // always wins over an unsent older value.
            if (req_sync != req_seen) begin
                req_seen       <= req_sync;
                pending        <= 1'b1;
                pending_credit <= credit_sync;
                pending_sequence <= sequence_sync;
            end

            case (state)
                ST_IDLE: begin
                    if (tx_grant && pending) begin
                        // Do not lose a status update arriving in this exact
                        // cycle; it becomes the next coalesced report.
                        if (req_sync == req_seen)
                            pending <= 1'b0;
                        state      <= ST_START;
                    end
                end

                ST_START: begin
                    tx_frame_start <= 1'b1;
                    byte_index     <= 4'd0;
                    state          <= ST_SEND;
                end

                ST_SEND: begin
                    tx_data_valid <= 1'b1;
                    case (byte_index)
                        4'd0: tx_data <= 8'h43; // C
                        4'd1: tx_data <= 8'h52; // R
                        4'd2: tx_data <= 8'h45; // E
                        4'd3: tx_data <= 8'h44; // D
                        4'd4: tx_data <= 8'h01; // format version
                        4'd5: tx_data <= pending_credit[15:8];
                        4'd6: tx_data <= pending_credit[7:0];
                        4'd7: tx_data <= pending_sequence[15:8];
                        default: tx_data <= pending_sequence[7:0];
                    endcase
                    if (byte_index == 4'd8)
                        state <= ST_DONE;
                    else
                        byte_index <= byte_index + 1'b1;
                end

                ST_DONE: state <= ST_IDLE;
                default: state <= ST_IDLE;
            endcase
        end
    end
endmodule
