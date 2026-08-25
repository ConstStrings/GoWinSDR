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

// The idle carrier completes exactly one revolution per symbol period.
// SAMPLE_RATE must be an integer multiple of SYMBOL_RATE.
localparam integer SAMPLES_PER_SYMBOL = SAMPLE_RATE / SYMBOL_RATE;
reg [31:0] carrier_sample_idx;
wire [36:0] carrier_lut_scaled = carrier_sample_idx * 5'd16;
wire [4:0]  carrier_lut_index  = carrier_lut_scaled / SAMPLES_PER_SYMBOL;

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
        carrier_sample_idx <= 32'd0;
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
            // The phase index is derived from SAMPLE_RATE / SYMBOL_RATE.
            // At 30.72 MSPS / 7.68 MSym/s this visits 0,4,8,12, i.e. the
            // same four quadrature points used previously.
            case (carrier_lut_index)
                5'd0 : begin qpsk_i <=  12'd1448; qpsk_q <= -12'd1448; end
                5'd1 : begin qpsk_i <=  12'd1338; qpsk_q <= -12'd554;  end
                5'd2 : begin qpsk_i <=  12'd1448; qpsk_q <=  12'd0;    end
                5'd3 : begin qpsk_i <=  12'd1338; qpsk_q <=  12'd554;  end
                5'd4 : begin qpsk_i <=  12'd1024; qpsk_q <=  12'd1024; end
                5'd5 : begin qpsk_i <=  12'd554;  qpsk_q <=  12'd1338; end
                5'd6 : begin qpsk_i <=  12'd0;    qpsk_q <=  12'd1448; end
                5'd7 : begin qpsk_i <= -12'd554;  qpsk_q <=  12'd1338; end
                5'd8 : begin qpsk_i <= -12'd1024; qpsk_q <=  12'd1024; end
                5'd9 : begin qpsk_i <= -12'd1338; qpsk_q <=  12'd554;  end
                5'd10: begin qpsk_i <= -12'd1448; qpsk_q <=  12'd0;    end
                5'd11: begin qpsk_i <= -12'd1338; qpsk_q <= -12'd554;  end
                5'd12: begin qpsk_i <= -12'd1024; qpsk_q <= -12'd1024; end
                5'd13: begin qpsk_i <= -12'd554;  qpsk_q <= -12'd1338; end
                5'd14: begin qpsk_i <=  12'd0;    qpsk_q <= -12'd1448; end
                default: begin qpsk_i <= 12'd554;  qpsk_q <= -12'd1338; end
            endcase
            if (carrier_sample_idx == SAMPLES_PER_SYMBOL - 1)
                carrier_sample_idx <= 32'd0;
            else
                carrier_sample_idx <= carrier_sample_idx + 1'b1;
        end
    end
    // stall=1: qpsk_i, qpsk_q, carrier_sample_idx all hold current value
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
