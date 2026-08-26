// DQPSK hard-decision decoder matched to rf_dqpsk_encoder.
//
// Each symbol is quantized by its I/Q signs, then differentially decoded
// against the preceding constellation point.  Dibits are packed MSB first,
// matching encoder input order: [7:6], [5:4], [3:2], [1:0].
module rf_dqpsk_decoder #(
    parameter SAMPLE_RATE  = 32'd30720000,
    parameter SYMBOL_RATE  = 32'd960000,
    parameter FRAME_HEAD   = 32'hEB90CAD3
)(
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
reg [7:0] decoded_byte;
reg       decoded_byte_valid;
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
        decoded_byte  <= 8'd0;
        decoded_byte_valid <= 1'b0;
    end else begin
        decoded_byte_valid <= 1'b0;

        if (symbol_sync) begin
            prev_sym    <= 2'b00;
            dibit_count <= 2'd0;
            byte_shift  <= 8'd0;
        end else if (symbol_valid) begin
            prev_sym   <= current_sym;
            byte_shift <= {byte_shift[5:0], decoded_dibit};

            if (dibit_count == 2'd3) begin
                decoded_byte       <= {byte_shift[5:0], decoded_dibit};
                decoded_byte_valid <= 1'b1;
                dibit_count   <= 2'd0;
            end else begin
                dibit_count <= dibit_count + 1'b1;
            end
        end
    end
end


(* keep = "true" *) reg [31:0] frame_window_dbg;
(* keep = "true" *) reg        frame_head_found_dbg;
(* keep = "true" *) reg [2:0]  frame_bit_offset_dbg;
(* keep = "true" *) reg [7:0]  frame_aligned_data_dbg;
(* keep = "true" *) reg        frame_aligned_data_valid_dbg;

reg [2:0] stream_bit_offset;
reg [1:0] frame_data_dibit_count;
wire [31:0] frame_window_next = {frame_window_dbg[29:0], decoded_dibit};

always @(posedge bb_symbol_clk or negedge rst_n) begin
    if (!rst_n) begin
        frame_window_dbg             <= 32'd0;
        frame_head_found_dbg         <= 1'b0;
        frame_bit_offset_dbg         <= 3'd0;
        frame_aligned_data_dbg       <= 8'd0;
        frame_aligned_data_valid_dbg <= 1'b0;
        stream_bit_offset            <= 3'd0;
        frame_data_dibit_count       <= 2'd0;
    end else begin
        frame_aligned_data_valid_dbg <= 1'b0;

        if (symbol_sync) begin
            frame_window_dbg       <= 32'd0;
            frame_head_found_dbg   <= 1'b0;
            frame_bit_offset_dbg   <= 3'd0;
            frame_aligned_data_dbg <= 8'd0;
            stream_bit_offset      <= 3'd0;
            frame_data_dibit_count <= 2'd0;
        end else if (symbol_valid) begin
            frame_window_dbg  <= frame_window_next;
            stream_bit_offset <= stream_bit_offset + 3'd2;

            if (frame_window_next == FRAME_HEAD) begin
                // The following dibit starts the realigned payload stream.
                frame_head_found_dbg   <= 1'b1;
                frame_bit_offset_dbg   <= stream_bit_offset + 3'd2;
                frame_aligned_data_dbg <= 8'd0;
                frame_data_dibit_count <= 2'd0;
            end else if (frame_head_found_dbg) begin
                frame_aligned_data_dbg <=
                    {frame_aligned_data_dbg[5:0], decoded_dibit};

                if (frame_data_dibit_count == 2'd3) begin
                    frame_aligned_data_valid_dbg <= 1'b1;
                    frame_data_dibit_count       <= 2'd0;
                end else begin
                    frame_data_dibit_count <= frame_data_dibit_count + 1'b1;
                end
            end
        end
    end
end

// -------------------------------------------------------------------------
// Deframer.  The transmit format is:
//   FRAME_HEAD[31:0] | payload_length[15:0] (MSB first) | payload | CRC[31:0]
// frame_aligned_data_dbg is the byte-aligned stream immediately after a
// detected FRAME_HEAD.  Only bytes accepted in READ_PAY are exposed at the
// module outputs.
// -------------------------------------------------------------------------
localparam DEFRAME_SEARCH_HEAD = 2'd0;
localparam DEFRAME_READ_LEN    = 2'd1;
localparam DEFRAME_READ_PAY    = 2'd2;
localparam DEFRAME_READ_CRC    = 2'd3;
localparam [2:0] CRC_BYTE_NUM  = 3'd4;

(* keep = "true" *) reg [1:0]  deframe_state_dbg;
(* keep = "true" *) reg [15:0] frame_length_dbg;
(* keep = "true" *) reg [15:0] payload_count_dbg;
(* keep = "true" *) reg [31:0] frame_crc_rx_dbg;
(* keep = "true" *) reg        frame_crc_done_dbg;
(* keep = "true" *) reg        frame_crc_valid_dbg;

reg       length_byte_sel;
reg [2:0] crc_byte_count;

always @(posedge bb_symbol_clk or negedge rst_n) begin
    if (!rst_n) begin
        deframe_state_dbg   <= DEFRAME_SEARCH_HEAD;
        frame_length_dbg    <= 16'd0;
        payload_count_dbg   <= 16'd0;
        frame_crc_rx_dbg    <= 32'd0;
        frame_crc_done_dbg  <= 1'b0;
        frame_crc_valid_dbg <= 1'b0; // Reserved for the future CRC checker.
        length_byte_sel     <= 1'b0;
        crc_byte_count      <= 3'd0;
        rx_data_out         <= 8'd0;
        rx_data_valid       <= 1'b0;
    end else begin
        rx_data_valid      <= 1'b0;
        frame_crc_done_dbg <= 1'b0;

        if (symbol_sync) begin
            deframe_state_dbg   <= DEFRAME_SEARCH_HEAD;
            frame_length_dbg    <= 16'd0;
            payload_count_dbg   <= 16'd0;
            frame_crc_rx_dbg    <= 32'd0;
            frame_crc_valid_dbg <= 1'b0;
            length_byte_sel     <= 1'b0;
            crc_byte_count      <= 3'd0;
        end else begin
            case (deframe_state_dbg)
                DEFRAME_SEARCH_HEAD: begin
                    if (symbol_valid && (frame_window_next == FRAME_HEAD)) begin
                        deframe_state_dbg <= DEFRAME_READ_LEN;
                        frame_length_dbg  <= 16'd0;
                        payload_count_dbg <= 16'd0;
                        length_byte_sel   <= 1'b0;
                    end
                end

                DEFRAME_READ_LEN: begin
                    if (frame_aligned_data_valid_dbg) begin
                        if (!length_byte_sel) begin
                            frame_length_dbg[15:8] <= frame_aligned_data_dbg;
                            length_byte_sel        <= 1'b1;
                        end else begin
                            frame_length_dbg[7:0] <= frame_aligned_data_dbg;
                            payload_count_dbg     <= 16'd0;
                            length_byte_sel       <= 1'b0;
                            if ({frame_length_dbg[15:8], frame_aligned_data_dbg} == 16'd0) begin
                                deframe_state_dbg <= DEFRAME_READ_CRC;
                                crc_byte_count    <= 3'd0;
                                frame_crc_rx_dbg  <= 32'd0;
                            end else begin
                                deframe_state_dbg <= DEFRAME_READ_PAY;
                            end
                        end
                    end
                end

                DEFRAME_READ_PAY: begin
                    if (frame_aligned_data_valid_dbg) begin
                        rx_data_out   <= frame_aligned_data_dbg;
                        rx_data_valid <= 1'b1;

                        if (payload_count_dbg == frame_length_dbg - 1'b1) begin
                            payload_count_dbg <= payload_count_dbg + 1'b1;
                            deframe_state_dbg <= DEFRAME_READ_CRC;
                            crc_byte_count    <= 3'd0;
                            frame_crc_rx_dbg  <= 32'd0;
                        end else begin
                            payload_count_dbg <= payload_count_dbg + 1'b1;
                        end
                    end
                end

                DEFRAME_READ_CRC: begin
                    if (frame_aligned_data_valid_dbg) begin
                        frame_crc_rx_dbg <=
                            {frame_crc_rx_dbg[23:0], frame_aligned_data_dbg};

                        if (crc_byte_count == CRC_BYTE_NUM - 1'b1) begin
                            frame_crc_done_dbg  <= 1'b1;
                            frame_crc_valid_dbg <= 1'b0;
                            deframe_state_dbg   <= DEFRAME_SEARCH_HEAD;
                            crc_byte_count       <= 3'd0;
                        end else begin
                            crc_byte_count <= crc_byte_count + 1'b1;
                        end
                    end
                end

                default: deframe_state_dbg <= DEFRAME_SEARCH_HEAD;
            endcase
        end
    end
end

endmodule
