module rf_dqpsk_encoder #(
    parameter SAMPLE_RATE  = 32'd30720000,
    parameter SYMBOL_RATE  = 32'd960000
)(
    input  wire        bb_symbol_clk,
    input  wire        rst_n,
    input  wire [7:0]  tx_data_in,
    input  wire        tx_data_valid,
    output wire        qpsk_ready,

    input  wire        tx_fifo_ready,
    input  wire        stall,              // pipeline stall (RF FIFO full): freeze state, no carrier insertion
    output reg  signed [11:0] qpsk_i_out,
    output reg  signed [11:0] qpsk_q_out
);

reg [1:0] nibble_idx;           // 2-bit nibble selector within byte
reg [1:0] tx_data_iq;           // current 2-bit data to differentially encode
wire [1:0] tx_data_iq_diff;     // differentially encoded 2-bit symbol

// Idle test pattern: I/Q are in phase and use only +/-1448.
// The polarity toggles at every symbol boundary while the transmitter is idle.
reg carrier_polarity;

// bb_symbol_clk is the QPSK symbol clock: consume one dibit per cycle.
always @(posedge bb_symbol_clk or negedge rst_n) begin
    if (!rst_n) begin
        nibble_idx <= 2'd0;
    end else if (!stall) begin
        if (tx_data_valid) begin
            nibble_idx <= nibble_idx + 1'b1;
        end else begin
            nibble_idx <= 2'd0;
        end
    end
    // stall=1: freeze nibble_idx
end

// Extract 2-bit nibble from byte input (MSB first)
always @(*) begin
    case (nibble_idx)
        2'd0: tx_data_iq = tx_data_in[7:6];
        2'd1: tx_data_iq = tx_data_in[5:4];
        2'd2: tx_data_iq = tx_data_in[3:2];
        2'd3: tx_data_iq = tx_data_in[1:0];
        default: tx_data_iq = 2'd0;
    endcase
end

// ============================================================
// DQPSK Differential Encoder (inline)
// ============================================================
reg [1:0] prev_sym;

function [1:0] dqpsk_encode;
    input [1:0] prev;
    input [1:0] data;
    begin
        case ({prev, data})
            4'b00_00: dqpsk_encode = 2'b00;
            4'b00_01: dqpsk_encode = 2'b10;
            4'b00_11: dqpsk_encode = 2'b11;
            4'b00_10: dqpsk_encode = 2'b01;
            4'b01_00: dqpsk_encode = 2'b01;
            4'b01_01: dqpsk_encode = 2'b00;
            4'b01_11: dqpsk_encode = 2'b10;
            4'b01_10: dqpsk_encode = 2'b11;
            4'b10_00: dqpsk_encode = 2'b10;
            4'b10_01: dqpsk_encode = 2'b11;
            4'b10_11: dqpsk_encode = 2'b01;
            4'b10_10: dqpsk_encode = 2'b00;
            4'b11_00: dqpsk_encode = 2'b11;
            4'b11_01: dqpsk_encode = 2'b01;
            4'b11_11: dqpsk_encode = 2'b00;
            4'b11_10: dqpsk_encode = 2'b10;
        endcase
    end
endfunction

// Every bb_symbol_clk cycle is a symbol boundary.
wire symbol_tick;
assign symbol_tick = tx_data_valid && !stall;

// Combinatorial diff encode output
assign tx_data_iq_diff = dqpsk_encode(prev_sym, tx_data_iq);

// Update prev_sym on valid symbol tick (frozen during stall)
always @(posedge bb_symbol_clk or negedge rst_n) begin
    if (!rst_n) begin
        prev_sym <= 2'b00;
    end else if (symbol_tick) begin
        prev_sym <= tx_data_iq_diff;
    end
end

// ============================================================
// Backpressure: qpsk_ready
//   - When stalled: ready=0, upstream stops
//   - When idle (tx_data_valid=0): ready=1, can accept data anytime
//   - When transmitting, ready pulses after the fourth 2-bit symbol is emitted
// ============================================================
assign qpsk_ready = !stall && tx_fifo_ready &&
                    (!tx_data_valid || (symbol_tick && (nibble_idx == 2'd3)));

// ============================================================
// QPSK constellation mapping + carrier generation
//   stall=0: normal operation (data or carrier)
//   stall=1: hold current output, do NOT switch to carrier
// ============================================================
reg signed [11:0] qpsk_i, qpsk_q;

always @(posedge bb_symbol_clk or negedge rst_n) begin
    if (!rst_n) begin
        qpsk_i      <= 12'd0;
        qpsk_q      <= 12'd0;
        carrier_polarity <= 1'b0;
    end else if (!stall) begin
        if (tx_data_valid) begin
            case (tx_data_iq_diff)
                2'b00: begin
                    qpsk_i <= -12'd1448;
                    qpsk_q <= -12'd1448;
                end
                2'b01: begin
                    qpsk_i <= -12'd1448;
                    qpsk_q <=  12'd1448;
                end
                2'b10: begin
                    qpsk_i <=  12'd1448;
                    qpsk_q <= -12'd1448;
                end
                2'b11: begin
                    qpsk_i <=  12'd1448;
                    qpsk_q <=  12'd1448;
                end
            endcase
        end else begin
            if (carrier_polarity) begin
                qpsk_i <= -12'sd1448;
                qpsk_q <= -12'sd1448;
            end else begin
                qpsk_i <=  12'sd1448;
                qpsk_q <=  12'sd1448;
            end
            carrier_polarity <= ~carrier_polarity;
        end
    end
    // stall=1: qpsk_i, qpsk_q and carrier_polarity all hold their values
end

// Output assignments
always @(posedge bb_symbol_clk or negedge rst_n) begin
    if (!rst_n) begin
        qpsk_i_out <= 12'd0;
        qpsk_q_out <= 12'd0;
    end else begin
        qpsk_i_out <= qpsk_i;
        qpsk_q_out <= qpsk_q;
    end
end

endmodule
