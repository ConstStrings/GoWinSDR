// DQPSK hard-decision decoder matched to rf_dqpsk_encoder.
//
// Each symbol is quantized by its I/Q signs, then differentially decoded
// against the preceding constellation point.  Dibits are packed MSB first,
// matching encoder input order: [7:6], [5:4], [3:2], [1:0].
module rf_dqpsk_decoder (
    input  wire               bb_symbol_clk,
    input  wire               rst_n,

    // Assert for one clock before the first symbol of a newly acquired burst.
    // The first following symbol is decoded with phase reference 2'b00.
    input  wire               symbol_sync,
    input  wire               symbol_valid,
    input  wire signed [11:0] qpsk_i_in,
    input  wire signed [11:0] qpsk_q_in,

    output reg  [7:0]         rx_data_out,
    output reg                rx_data_valid
);

reg [1:0] prev_sym;
reg [1:0] dibit_count;
reg [7:0] byte_shift;
reg [1:0] current_sym;
wire [1:0] decoded_dibit;

// Constellation labels are the inverse of the encoder mapping:
//   00: I<0, Q<0     01: I<0, Q>=0
//   10: I>=0, Q<0    11: I>=0, Q>=0
always @(*) begin
    case ({qpsk_i_in[11], qpsk_q_in[11]})
        2'b11:  current_sym = 2'b00;
        2'b10:  current_sym = 2'b01;
        2'b01:  current_sym = 2'b10;
        default: current_sym = 2'b11;
    endcase
end

// Inverse of rf_dqpsk_encoder.dqpsk_encode(prev_sym, data).
function [1:0] dqpsk_decode;
    input [1:0] prev;
    input [1:0] curr;
    begin
        case ({prev, curr})
            4'b00_00: dqpsk_decode = 2'b00;
            4'b00_10: dqpsk_decode = 2'b01;
            4'b00_11: dqpsk_decode = 2'b11;
            4'b00_01: dqpsk_decode = 2'b10;

            4'b01_01: dqpsk_decode = 2'b00;
            4'b01_00: dqpsk_decode = 2'b01;
            4'b01_10: dqpsk_decode = 2'b11;
            4'b01_11: dqpsk_decode = 2'b10;

            4'b10_10: dqpsk_decode = 2'b00;
            4'b10_11: dqpsk_decode = 2'b01;
            4'b10_01: dqpsk_decode = 2'b11;
            4'b10_00: dqpsk_decode = 2'b10;

            4'b11_11: dqpsk_decode = 2'b00;
            4'b11_01: dqpsk_decode = 2'b01;
            4'b11_00: dqpsk_decode = 2'b11;
            4'b11_10: dqpsk_decode = 2'b10;
            default:   dqpsk_decode = 2'b00;
        endcase
    end
endfunction

assign decoded_dibit = dqpsk_decode(prev_sym, current_sym);

always @(posedge bb_symbol_clk or negedge rst_n) begin
    if (!rst_n) begin
        prev_sym      <= 2'b00;
        dibit_count   <= 2'd0;
        byte_shift    <= 8'd0;
        rx_data_out   <= 8'd0;
        rx_data_valid <= 1'b0;
    end else begin
        rx_data_valid <= 1'b0;

        if (symbol_sync) begin
            prev_sym    <= 2'b00;
            dibit_count <= 2'd0;
            byte_shift  <= 8'd0;
        end else if (symbol_valid) begin
            prev_sym   <= current_sym;
            byte_shift <= {byte_shift[5:0], decoded_dibit};

            if (dibit_count == 2'd3) begin
                rx_data_out   <= {byte_shift[5:0], decoded_dibit};
                rx_data_valid <= 1'b1;
                dibit_count   <= 2'd0;
            end else begin
                dibit_count <= dibit_count + 1'b1;
            end
        end
    end
end

endmodule
