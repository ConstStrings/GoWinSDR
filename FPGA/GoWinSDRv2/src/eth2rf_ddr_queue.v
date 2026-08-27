// Ethernet-to-RF packet queue backed by DDR3.
//
// The DDR3 user interface is 128 bit wide.  A descriptor is committed only
// after the final (possibly masked) DDR write has been accepted, so the RF
// side never observes a partially written frame.
module eth2rf_ddr_queue #(
    parameter FRAME_HEAD          = 32'hEB90CAD3,
    parameter RING_WORD_ADDR_BITS = 24,       // 2^24 x 16 B = 256 MiB
    parameter DESC_ADDR_BITS      = 10,       // 1024 complete RF frames
    parameter IN_FIFO_ADDR_BITS   = 11,       // generated FIFO is 2048 x 8
    parameter OUT_FIFO_ADDR_BITS  = 3         // 8 x 128-bit read cache
)(
    input  wire        sys_clk,
    input  wire        rst_n,

    input  wire        eth_rx_clk,
    input  wire [7:0]  rx_data,
    input  wire        rx_data_valid,
    input  wire        rx_frame_end,
    input  wire [15:0] udp_length,

    input  wire        rf_tx_clk,
    input  wire        rf_tx_ready,
    output wire [7:0]  rf_tx_data,
    output wire        rf_tx_valid,

    // Status / PC flow-control observability.  The PC shall only keep this
    // many maximum-length UDP packets outstanding; packets arriving while
    // ingress_accept is low are intentionally discarded as whole packets.
    output wire        ingress_accept,
    output reg         ingress_drop,
    output wire        ddr_init_done,
    output wire        ddr_pll_lock_dbg,
    output wire        ddr_phy_reset_dbg,
    output wire        ddr_pll_stop_dbg,
    output wire [15:0] queued_words_dbg,
    output wire [15:0] credit_packets_dbg,

    output wire [13:0] ddr_addr,
    output wire [2:0]  ddr_bank,
    output wire        ddr_cs,
    output wire        ddr_ras,
    output wire        ddr_cas,
    output wire        ddr_we,
    output wire        ddr_ck,
    output wire        ddr_ck_n,
    output wire        ddr_cke,
    output wire        ddr_odt,
    output wire        ddr_reset_n,
    output wire [1:0]  ddr_dm,
    inout  wire [15:0] ddr_dq,
    inout  wire [1:0]  ddr_dqs,
    inout  wire [1:0]  ddr_dqs_n
);

    localparam MAX_RF_FRAME_BYTES = 16'd1482; // 1472 UDP payload + 10 RF bytes
    localparam RING_WORDS = (1 << RING_WORD_ADDR_BITS);
    localparam RING_GUARD_WORDS = 256;
    localparam [RING_WORD_ADDR_BITS:0] RING_WORDS_CONST = (1 << RING_WORD_ADDR_BITS);

    // ---------------------------------------------------------------------
    // Ethernet clock domain: create the RF frame byte stream.  The input
    // FIFO is the project's generated dual-clock BSRAM FIFO.  Packet length
    // is carried in RF bytes 4..5, so the DDR clock domain derives the end
    // from that length rather than relying on an idle-cycle heuristic.
    // ---------------------------------------------------------------------
    reg [2:0] in_state;
    reg [47:0] payload_pipe;
    reg [15:0] in_count;
    reg [7:0]  in_data;
    reg        in_we;
    reg        drop_until_end;
    wire [15:0] payload_length = udp_length - 16'd8;

    localparam IN_IDLE    = 3'd0;
    localparam IN_HEAD    = 3'd1;
    localparam IN_LEN     = 3'd2;
    localparam IN_PAYLOAD = 3'd3;
    localparam IN_CRC     = 3'd4;

    wire [IN_FIFO_ADDR_BITS:0] in_wr_count;
    wire in_fifo_full, in_fifo_almost_full, in_fifo_empty;
    reg in_fifo_re_r;
    wire [7:0] in_fifo_q;
    wire ddr_clk;
    wire ddr_addr_unused;
    // Clock-health counters for DDR bring-up. They are kept for GAO: when
    // sampled by ddr_clk, they advance by about 1 and 4 respectively
    // (50 MHz controller clock and 200 MHz PHY clock).
    (* keep = "true" *) reg [15:0] ddr_clk100_counter_dbg;
    (* keep = "true" *) reg [15:0] ddr_memclk_counter_dbg;
    reg ddr_allow_meta, ddr_allow_sync;
    wire ddr_can_accept;
    wire [RING_WORD_ADDR_BITS:0] free_words;
    wire [RING_WORD_ADDR_BITS:0] credit_packets_wide;

    localparam [15:0] IN_FIFO_DEPTH = (1 << IN_FIFO_ADDR_BITS);
    wire [15:0] framed_packet_bytes = udp_length + 16'd2; // UDP length + RF header/CRC overhead
    // The pointer-derived count is deliberately separate from the FIFO IP:
    // it lets us reserve the complete incoming packet before its first byte.
    wire in_fifo_has_packet_room = (framed_packet_bytes <= IN_FIFO_DEPTH) &&
                                   (in_wr_count <= (IN_FIFO_DEPTH - framed_packet_bytes));
    assign ingress_accept = ddr_allow_sync && in_fifo_has_packet_room && !drop_until_end;

    always @(posedge eth_rx_clk or negedge rst_n) begin
        if (!rst_n) begin
            ddr_allow_meta <= 1'b0;
            ddr_allow_sync <= 1'b0;
        end else begin
            ddr_allow_meta <= ddr_can_accept;
            ddr_allow_sync <= ddr_allow_meta;
        end
    end

    always @(posedge eth_rx_clk or negedge rst_n) begin
        if (!rst_n) begin
            in_state       <= IN_IDLE;
            payload_pipe   <= 48'd0;
            in_count       <= 16'd0;
            in_data        <= 8'd0;
            in_we          <= 1'b0;
            drop_until_end <= 1'b0;
            ingress_drop   <= 1'b0;
        end else begin
            in_we        <= 1'b0;
            ingress_drop <= 1'b0;

            if (drop_until_end) begin
                if (rx_frame_end) drop_until_end <= 1'b0;
            end else begin
                case (in_state)
                    IN_IDLE: begin
                        in_count <= 16'd0;
                        if (rx_data_valid) begin
                            if (ingress_accept) begin
                                payload_pipe <= {payload_pipe[39:0], rx_data};
                                in_data      <= FRAME_HEAD[31:24];
                                in_we        <= 1'b1;
                                in_count     <= 16'd1;
                                in_state     <= IN_HEAD;
                            end else begin
                                // Ethernet has no application-level ready.
                                // Reject the entire UDP payload, never a
                                // suffix, and let the PC obey the credit.
                                drop_until_end <= 1'b1;
                                ingress_drop   <= 1'b1;
                            end
                        end
                    end
                    IN_HEAD: if (rx_data_valid) begin
                        payload_pipe <= {payload_pipe[39:0], rx_data};
                        in_we <= 1'b1;
                        case (in_count)
                            16'd1: in_data <= FRAME_HEAD[23:16];
                            16'd2: in_data <= FRAME_HEAD[15:8];
                            default: begin
                                in_data  <= FRAME_HEAD[7:0];
                                in_state <= IN_LEN;
                                in_count <= 16'd0;
                            end
                        endcase
                        if (in_count != 16'd3) in_count <= in_count + 1'b1;
                    end else if (rx_frame_end) begin
                        in_state <= IN_IDLE;
                    end
                    IN_LEN: begin
                        in_we        <= 1'b1;
                        in_data      <= (in_count == 0) ? payload_length[15:8] : payload_length[7:0];
                        payload_pipe <= {payload_pipe[39:0], rx_data};
                        if (in_count == 16'd1) begin
                            in_count <= 16'd0;
                            in_state <= IN_PAYLOAD;
                        end else begin
                            in_count <= in_count + 1'b1;
                        end
                    end
                    IN_PAYLOAD: begin
                        in_we        <= 1'b1;
                        in_data      <= payload_pipe[47:40];
                        payload_pipe <= {payload_pipe[39:0], rx_data};
                        if (in_count == payload_length - 1'b1) begin
                            in_count <= 16'd0;
                            in_state <= IN_CRC;
                        end else begin
                            in_count <= in_count + 1'b1;
                        end
                    end
                    IN_CRC: begin
                        in_we   <= 1'b1;
                        in_data <= 8'd0;
                        if (in_count == 16'd3) begin
                            in_count <= 16'd0;
                            in_state <= IN_IDLE;
                        end else begin
                            in_count <= in_count + 1'b1;
                        end
                    end
                    default: in_state <= IN_IDLE;
                endcase
            end
        end
    end

    wire in_fifo_we = in_we && !in_fifo_full;
    // Do not use fifo_eth2rf here: the generated instance has no reset port,
    // leaving its internal Gray pointers indeterminate after configuration.
    // This FIFO has the same registered-Q read timing, but its pointers are
    // reset together with the packet formatter.
    packet_async_fifo_registered #(
        .DATA_WIDTH(8), .ADDR_WIDTH(IN_FIFO_ADDR_BITS), .ALMOST_FULL_LEVEL(1800)
    ) u_ingress_fifo (
        .wr_clk(eth_rx_clk), .rd_clk(ddr_clk), .rst_n(rst_n),
        .wr_en(in_fifo_we), .wr_data(in_data), .rd_en(in_fifo_re_r), .rd_data(in_fifo_q),
        .full(in_fifo_full), .empty(in_fifo_empty), .almost_full(in_fifo_almost_full),
        .wr_count(), .rd_count()
    );

    // Mirror only the asynchronous FIFO pointers (not its payload RAM) to
    // obtain an exact, CDC-safe occupancy count for whole-packet admission.
    reg [IN_FIFO_ADDR_BITS:0] in_wr_bin, in_wr_gray;
    reg [IN_FIFO_ADDR_BITS:0] in_rd_bin, in_rd_gray;
    reg [IN_FIFO_ADDR_BITS:0] in_rd_gray_w1, in_rd_gray_w2;
    reg [IN_FIFO_ADDR_BITS:0] in_wr_gray_r1, in_wr_gray_r2;
    function [IN_FIFO_ADDR_BITS:0] ingress_gray2bin;
        input [IN_FIFO_ADDR_BITS:0] gray;
        integer gi;
        begin
            ingress_gray2bin[IN_FIFO_ADDR_BITS] = gray[IN_FIFO_ADDR_BITS];
            for (gi=IN_FIFO_ADDR_BITS-1; gi>=0; gi=gi-1)
                ingress_gray2bin[gi] = ingress_gray2bin[gi+1] ^ gray[gi];
        end
    endfunction
    reg [IN_FIFO_ADDR_BITS:0] in_rd_bin_eth_reg;
    reg [IN_FIFO_ADDR_BITS:0] in_wr_count_reg;
    assign in_wr_count = in_wr_count_reg;

    always @(posedge eth_rx_clk or negedge rst_n) begin
        if (!rst_n) begin
            in_wr_bin <= 0; in_wr_gray <= 0;
            in_rd_gray_w1 <= 0; in_rd_gray_w2 <= 0;
            in_rd_bin_eth_reg <= 0; in_wr_count_reg <= 0;
        end else begin
            in_rd_gray_w1 <= in_rd_gray;
            in_rd_gray_w2 <= in_rd_gray_w1;
            // Pipeline CDC pointer conversion and occupancy arithmetic.  The
            // synchronized read pointer is intentionally one cycle older,
            // which only overestimates occupancy and is therefore safe.
            in_rd_bin_eth_reg <= ingress_gray2bin(in_rd_gray_w2);
            in_wr_count_reg <= in_wr_bin + (in_fifo_we ? 1'b1 : 1'b0) - in_rd_bin_eth_reg;
            if (in_fifo_we) begin
                in_wr_bin <= in_wr_bin + 1'b1;
                in_wr_gray <= ((in_wr_bin + 1'b1) >> 1) ^ (in_wr_bin + 1'b1);
            end
        end
    end

    always @(posedge ddr_clk or negedge rst_n) begin
        if (!rst_n) begin
            in_rd_bin <= 0; in_rd_gray <= 0;
            in_wr_gray_r1 <= 0; in_wr_gray_r2 <= 0;
        end else begin
            in_wr_gray_r1 <= in_wr_gray;
            in_wr_gray_r2 <= in_wr_gray_r1;
            if (in_fifo_re_r && !in_fifo_empty) begin
                in_rd_bin <= in_rd_bin + 1'b1;
                in_rd_gray <= ((in_rd_bin + 1'b1) >> 1) ^ (in_rd_bin + 1'b1);
            end
        end
    end

    // ---------------------------------------------------------------------
    // DDR3 controller and packet descriptors.  The controller is the
    // 200 MHz generated DDR3 IP; Controller mode retains the 128-bit
    // user word and 16-bit byte mask used by the packet ring.
    // ---------------------------------------------------------------------
    wire clk100m, memory_clk, pll_lock, pll_stop;
    wire ddr_rst;
    wire cmd_ready, wr_data_rdy, rd_data_valid, rd_data_end;
    wire [127:0] rd_data;

    assign ddr_pll_lock_dbg  = pll_lock;
    assign ddr_phy_reset_dbg = ddr_rst;
    assign ddr_pll_stop_dbg  = pll_stop;
    reg  [2:0] app_cmd;
    reg        app_cmd_en;
    reg  [29:0] app_addr;
    reg  [127:0] app_wr_data;
    reg  [15:0]  app_wr_mask;
    reg        app_wr_en, app_wr_end;

    Gowin_PLL_DDR u_ddr_pll (
        .clkin(sys_clk), .clkout0(), .clkout1(clk100m), .clkout2(memory_clk),
        .lock(pll_lock), .mdclk(sys_clk), .reset(~rst_n)
    );

    DDR3_Memory_Interface_200 u_ddr3 (
        .clk(clk100m), .pll_stop(pll_stop), .memory_clk(memory_clk),
        .pll_lock(pll_lock), .rst_n(rst_n), .clk_out(ddr_clk), .ddr_rst(ddr_rst),
        .init_calib_complete(ddr_init_done), .cmd_ready(cmd_ready),
        .cmd(app_cmd), .cmd_en(app_cmd_en), .addr(app_addr),
        .wr_data_rdy(wr_data_rdy), .wr_data(app_wr_data),
        .wr_data_en(app_wr_en), .wr_data_end(app_wr_end), .wr_data_mask(app_wr_mask),
        .rd_data(rd_data), .rd_data_valid(rd_data_valid), .rd_data_end(rd_data_end),
        .sr_req(1'b0), .ref_req(1'b0), .sr_ack(), .ref_ack(), .burst(1'b0),
        .O_ddr_addr({ddr_addr_unused, ddr_addr}), .O_ddr_ba(ddr_bank),
        .O_ddr_cs_n(ddr_cs), .O_ddr_ras_n(ddr_ras), .O_ddr_cas_n(ddr_cas),
        .O_ddr_we_n(ddr_we), .O_ddr_clk(ddr_ck), .O_ddr_clk_n(ddr_ck_n),
        .O_ddr_cke(ddr_cke), .O_ddr_odt(ddr_odt), .O_ddr_reset_n(ddr_reset_n),
        .O_ddr_dqm(ddr_dm), .IO_ddr_dq(ddr_dq), .IO_ddr_dqs(ddr_dqs), .IO_ddr_dqs_n(ddr_dqs_n)
    );

    always @(posedge clk100m or negedge rst_n) begin
        if (!rst_n)
            ddr_clk100_counter_dbg <= 16'd0;
        else
            ddr_clk100_counter_dbg <= ddr_clk100_counter_dbg + 1'b1;
    end

    always @(posedge memory_clk or negedge rst_n) begin
        if (!rst_n)
            ddr_memclk_counter_dbg <= 16'd0;
        else
            ddr_memclk_counter_dbg <= ddr_memclk_counter_dbg + 1'b1;
    end

    // Packet descriptors use BSRAM too.  A register-array descriptor table
    // becomes a large write decoder at 100 MHz and cannot meet timing.
    reg        desc_fifo_we, desc_fifo_re_r;
    reg [7:0]  desc_fifo_data;
    wire [7:0] desc_fifo_q;
    wire       desc_fifo_full, desc_fifo_empty, desc_fifo_almost_full;
    reg        desc_write_pending, desc_write_low_byte;
    reg [15:0] desc_write_len, desc_read_len;
    reg [2:0]  desc_read_state;

    // The descriptor FIFO must be reset as well; otherwise a stale descriptor
    // can make the reader issue a valid DDR read for unrelated data.
    packet_async_fifo_registered #(
        .DATA_WIDTH(8), .ADDR_WIDTH(IN_FIFO_ADDR_BITS), .ALMOST_FULL_LEVEL(1800)
    ) u_descriptor_fifo (
        .wr_clk(ddr_clk), .rd_clk(ddr_clk), .rst_n(rst_n),
        .wr_en(desc_fifo_we), .wr_data(desc_fifo_data), .rd_en(desc_fifo_re_r), .rd_data(desc_fifo_q),
        .full(desc_fifo_full), .empty(desc_fifo_empty), .almost_full(desc_fifo_almost_full),
        .wr_count(), .rd_count()
    );

    reg [RING_WORD_ADDR_BITS-1:0] wr_word_ptr, rd_word_ptr;
    reg [RING_WORD_ADDR_BITS:0] used_words;
    reg [127:0] pack_word;
    reg [4:0] pack_bytes;
    reg [15:0] pack_frame_bytes, pack_frame_target;
    reg [7:0] ingress_len_hi;
    reg in_fifo_data_valid, in_fifo_read_wait;
    reg write_pending, write_is_last;
    // cmd_ready/wr_data_rdy acknowledge acceptance into the controller, not
    // completion at the DDR pins.  Do not make a just-written frame readable
    // until the controller's write pipeline has drained.
    localparam integer WRITE_TO_READ_GUARD_CYCLES = 64;
    reg        write_commit_wait;
    reg [6:0]  write_commit_count;
    reg [127:0] pending_word;
    reg [15:0] pending_mask;
    reg [15:0] pending_frame_bytes;
    reg read_active, read_wait, read_resp_pending;
    reg [15:0] read_bytes_left;
    reg [15:0] read_words_left;
    reg [127:0] read_resp_data;

    // The shift count must be wider than pack_bytes.  In Verilog,
    // (pack_bytes << 3) keeps pack_bytes' 5-bit width, so offsets 32, 40,
    // ... are truncated and bytes 4..15 overwrite bytes 0..3.
    wire [7:0] pack_bit_offset = {3'd0, pack_bytes} << 3;
    wire [127:0] pack_with_input = pack_word | ({120'd0,in_fifo_q} << pack_bit_offset);
    wire [15:0] pack_mask_with_input = (pack_bytes == 5'd15) ? 16'h0000 : (16'hFFFF << (pack_bytes + 1'b1));
    wire [15:0] read_valid_bytes = (read_bytes_left >= 16) ? 16'd16 : read_bytes_left;
    wire out_fifo_full, out_fifo_empty, out_fifo_re;
    wire [132:0] out_fifo_q;
    reg out_fifo_we;
    reg [132:0] out_fifo_d;

    // The ring keeps 256 words of margin, so an asynchronous status update
    // cannot cause an accepted max-MTU packet to overlap unread data.
    // Almost_Full leaves 248 descriptor-byte slots (124 complete frames),
    // covering Ethernet/CDC in-flight packets after acceptance is withdrawn.
    assign ddr_can_accept = ddr_init_done && !desc_fifo_almost_full &&
                            (used_words < (RING_WORDS_CONST - RING_GUARD_WORDS));
    assign free_words = RING_WORDS_CONST - used_words;
    assign credit_packets_wide = free_words >> 7; // 128 words reserves one max-MTU packet
    assign queued_words_dbg = used_words[15:0];
    assign credit_packets_dbg = desc_fifo_almost_full ? 16'd0 :
                                (|credit_packets_wide[RING_WORD_ADDR_BITS:16] ? 16'hFFFF : credit_packets_wide[15:0]);

    // A single controller interface is arbitrated in this clock domain:
    // writes have priority (to absorb Ethernet bursts); reads are still far
    // above the 1.92 MB/s RF byte requirement at the configured symbol rate.
    always @(posedge ddr_clk or negedge rst_n) begin
        if (!rst_n) begin
            app_cmd <= 3'd0; app_cmd_en <= 1'b0; app_addr <= 30'd0;
            app_wr_data <= 128'd0; app_wr_mask <= 16'hFFFF;
            app_wr_en <= 1'b0; app_wr_end <= 1'b0;
            pack_word <= 128'd0; pack_bytes <= 5'd0;
            pack_frame_bytes <= 16'd0; pack_frame_target <= 16'd0; ingress_len_hi <= 8'd0;
            in_fifo_re_r <= 1'b0; in_fifo_data_valid <= 1'b0; in_fifo_read_wait <= 1'b0;
            write_pending <= 1'b0; write_is_last <= 1'b0;
            write_commit_wait <= 1'b0; write_commit_count <= 7'd0;
            pending_word <= 128'd0; pending_mask <= 16'hFFFF; pending_frame_bytes <= 16'd0;
            wr_word_ptr <= 0; rd_word_ptr <= 0; used_words <= 0;
            desc_fifo_we <= 1'b0; desc_fifo_re_r <= 1'b0; desc_fifo_data <= 8'd0;
            desc_write_pending <= 1'b0; desc_write_low_byte <= 1'b0;
            desc_write_len <= 16'd0; desc_read_len <= 16'd0; desc_read_state <= 2'd0;
            read_active <= 1'b0; read_wait <= 1'b0; read_resp_pending <= 1'b0;
            read_bytes_left <= 0; read_words_left <= 0; read_resp_data <= 0;
            out_fifo_we <= 1'b0; out_fifo_d <= 0;
        end else begin
            app_cmd_en <= 1'b0; app_wr_en <= 1'b0; app_wr_end <= 1'b0;
            out_fifo_we <= 1'b0;
            in_fifo_re_r <= 1'b0;
            desc_fifo_we <= 1'b0;
            desc_fifo_re_r <= 1'b0;

            if (!ddr_init_done) begin
                pack_word <= 0; pack_bytes <= 0; pack_frame_bytes <= 0;
                pack_frame_target <= 0; ingress_len_hi <= 0;
                in_fifo_data_valid <= 0; in_fifo_read_wait <= 0;
                write_pending <= 0; write_is_last <= 0;
                write_commit_wait <= 0; write_commit_count <= 0;
                read_active <= 0; read_wait <= 0; read_resp_pending <= 0; read_resp_data <= 0;
                wr_word_ptr <= 0; rd_word_ptr <= 0; used_words <= 0;
                desc_write_pending <= 0; desc_write_low_byte <= 0; desc_read_state <= 0;
            end else if (write_pending) begin
                if (cmd_ready && wr_data_rdy) begin
                    app_cmd <= 3'd0; app_cmd_en <= 1'b1;
                    app_addr <= {3'd0,wr_word_ptr,3'b000};
                    app_wr_data <= pending_word; app_wr_mask <= pending_mask;
                    app_wr_en <= 1'b1; app_wr_end <= 1'b1;
                    wr_word_ptr <= wr_word_ptr + 1'b1;
                    used_words <= used_words + 1'b1;
                    write_pending <= 1'b0;
                    if (write_is_last) begin
                        // A read issued immediately after this handshake can
                        // observe the old DDR contents on short frames.  The
                        // descriptor is therefore published only after a
                        // conservative controller-clock guard interval.
                        write_commit_wait <= 1'b1;
                        write_commit_count <= WRITE_TO_READ_GUARD_CYCLES - 1'b1;
                        write_is_last <= 1'b0;
                    end
                end
            end else if (write_commit_wait) begin
                if (write_commit_count == 0) begin
                    write_commit_wait <= 1'b0;
                    desc_write_pending <= 1'b1;
                    desc_write_low_byte <= 1'b0;
                    desc_write_len <= pending_frame_bytes;
                end else begin
                    write_commit_count <= write_commit_count - 1'b1;
                end
            end else if (desc_write_pending) begin
                desc_fifo_we <= 1'b1;
                desc_fifo_data <= desc_write_low_byte ? desc_write_len[7:0] : desc_write_len[15:8];
                if (desc_write_low_byte) begin
                    desc_write_pending <= 1'b0;
                    desc_write_low_byte <= 1'b0;
                end else begin
                    desc_write_low_byte <= 1'b1;
                end
            end else if (read_wait) begin
                // The DDR read return is a one-cycle pulse.  It must be
                // captured even while the small egress FIFO is full; waiting
                // for !out_fifo_full here drops that final word permanently.
                if (rd_data_valid) begin
                    read_resp_data    <= rd_data;
                    read_resp_pending <= 1'b1;
                    read_wait         <= 1'b0;
                end
            end else if (read_resp_pending) begin
                if (!out_fifo_full) begin
                    out_fifo_d <= {read_valid_bytes[4:0], read_resp_data};
                    out_fifo_we <= 1'b1;
                    rd_word_ptr <= rd_word_ptr + 1'b1;
                    used_words <= used_words - 1'b1;
                    read_resp_pending <= 1'b0;
                    if (read_words_left == 16'd1) begin
                        read_words_left <= 0;
                        read_bytes_left <= 0;
                        read_active <= 1'b0;
                    end else begin
                        read_words_left <= read_words_left - 1'b1;
                        read_bytes_left <= read_bytes_left - read_valid_bytes;
                    end
                end
            end else if (in_fifo_data_valid) begin
                in_fifo_data_valid <= 1'b0;
                pack_word <= pack_with_input;
                pack_frame_bytes <= pack_frame_bytes + 1'b1;
                if (pack_frame_bytes == 16'd4)
                    ingress_len_hi <= in_fifo_q;
                if (pack_frame_bytes == 16'd5)
                    pack_frame_target <= {ingress_len_hi,in_fifo_q} + 16'd10;
                if ((pack_bytes == 5'd15) ||
                    ((pack_frame_target != 0) && (pack_frame_bytes + 1'b1 == pack_frame_target))) begin
                    pending_word <= pack_with_input;
                    pending_mask <= pack_mask_with_input;
                    pending_frame_bytes <= pack_frame_bytes + 1'b1;
                    write_is_last <= (pack_frame_target != 0) &&
                                     (pack_frame_bytes + 1'b1 == pack_frame_target);
                    write_pending <= 1'b1;
                    pack_word <= 0;
                    pack_bytes <= 0;
                    if ((pack_frame_target != 0) && (pack_frame_bytes + 1'b1 == pack_frame_target)) begin
                        pack_frame_bytes <= 0;
                        pack_frame_target <= 0;
                    end
                end else begin
                    pack_bytes <= pack_bytes + 1'b1;
                end
            end else if (in_fifo_read_wait) begin
                // The registered-Q FIFO updates Q at this edge; consume it next edge.
                in_fifo_read_wait <= 1'b0;
                in_fifo_data_valid <= 1'b1;
            end else if (!in_fifo_empty) begin
                // Request now, then consume the registered Q after one full
                // FIFO clock.
                in_fifo_re_r <= 1'b1;
                in_fifo_read_wait <= 1'b1;
            end else if (desc_read_state == 3'd1) begin
                // Wait for the registered FIFO Q after requesting length MSB.
                desc_read_state <= 3'd2;
            end else if (desc_read_state == 3'd2) begin
                desc_read_len[15:8] <= desc_fifo_q;
                desc_fifo_re_r <= 1'b1;
                desc_read_state <= 3'd3;
            end else if (desc_read_state == 3'd3) begin
                // Wait for the registered FIFO Q after requesting length LSB.
                desc_read_state <= 3'd4;
            end else if (desc_read_state == 3'd4) begin
                read_bytes_left <= {desc_read_len[15:8],desc_fifo_q};
                read_words_left <= ({desc_read_len[15:8],desc_fifo_q} + 16'd15) >> 4;
                read_active <= 1'b1;
                desc_read_state <= 3'd0;
            end else if (read_active && !out_fifo_full) begin
                if (cmd_ready) begin
                    app_cmd <= 3'd1; app_cmd_en <= 1'b1;
                    app_addr <= {3'd0,rd_word_ptr,3'b000};
                    read_wait <= 1'b1;
                end
            end else if (!desc_fifo_empty) begin
                desc_fifo_re_r <= 1'b1;
                desc_read_state <= 3'd1;
            end
        end
    end

    packet_async_fifo #(.DATA_WIDTH(133), .ADDR_WIDTH(OUT_FIFO_ADDR_BITS)) u_egress_fifo (
        .wr_clk(ddr_clk), .rd_clk(rf_tx_clk), .rst_n(rst_n),
        .wr_en(out_fifo_we), .wr_data(out_fifo_d), .rd_en(out_fifo_re),
        .rd_data(out_fifo_q), .full(out_fifo_full), .empty(out_fifo_empty),
        .wr_count(), .rd_count()
    );

    // ---------------------------------------------------------------------
    // RF byte clock domain.  A two-word cache prefetches before the current
    // word ends, maintaining one byte per rf_tx_clk handshake (the physical
    // DQPSK byte-rate limit) without a 16-byte boundary bubble.
    // ---------------------------------------------------------------------
    reg [127:0] tx_word, tx_next_word;
    reg [4:0] tx_word_bytes, tx_next_bytes, tx_byte_index;
    reg tx_word_valid, tx_next_valid;
    reg out_fifo_re_r;
    assign out_fifo_re = out_fifo_re_r;
    assign rf_tx_valid = tx_word_valid;
    assign rf_tx_data = tx_word[tx_byte_index*8 +: 8];

    always @(posedge rf_tx_clk or negedge rst_n) begin
        if (!rst_n) begin
            tx_word <= 0; tx_next_word <= 0;
            tx_word_bytes <= 0; tx_next_bytes <= 0; tx_byte_index <= 0;
            tx_word_valid <= 0; tx_next_valid <= 0; out_fifo_re_r <= 0;
        end else begin
            out_fifo_re_r <= 1'b0;
            if (!tx_word_valid && !out_fifo_empty) begin
                tx_word <= out_fifo_q[127:0];
                tx_word_bytes <= out_fifo_q[132:128];
                tx_byte_index <= 0;
                tx_word_valid <= 1'b1;
                out_fifo_re_r <= 1'b1;
            end else if (tx_word_valid) begin
                if (!tx_next_valid && (tx_byte_index >= (tx_word_bytes - 2)) && !out_fifo_empty) begin
                    tx_next_word <= out_fifo_q[127:0];
                    tx_next_bytes <= out_fifo_q[132:128];
                    tx_next_valid <= 1'b1;
                    out_fifo_re_r <= 1'b1;
                end
                if (rf_tx_ready) begin
                    if (tx_byte_index == tx_word_bytes - 1'b1) begin
                        if (tx_next_valid) begin
                            tx_word <= tx_next_word;
                            tx_word_bytes <= tx_next_bytes;
                            tx_byte_index <= 0;
                            tx_next_valid <= 1'b0;
                        end else begin
                            tx_word_valid <= 1'b0;
                            tx_byte_index <= 0;
                        end
                    end else begin
                        tx_byte_index <= tx_byte_index + 1'b1;
                    end
                end
            end
        end
    end
endmodule

// Resettable asynchronous FIFO with a registered read output.  Q is updated
// on the read-clock edge that accepts rd_en, matching the timing assumed by
// the ingress and descriptor state machines above.
module packet_async_fifo_registered #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4,
    parameter ALMOST_FULL_LEVEL = (1 << ADDR_WIDTH) - 4
)(
    input wire wr_clk, input wire rd_clk, input wire rst_n,
    input wire wr_en, input wire [DATA_WIDTH-1:0] wr_data,
    input wire rd_en, output reg [DATA_WIDTH-1:0] rd_data,
    output wire full, output wire empty, output wire almost_full,
    output wire [ADDR_WIDTH:0] wr_count, output wire [ADDR_WIDTH:0] rd_count
);
    reg [DATA_WIDTH-1:0] mem [0:(1<<ADDR_WIDTH)-1];
    reg [ADDR_WIDTH:0] wr_bin, rd_bin, wr_gray, rd_gray;
    reg [ADDR_WIDTH:0] rd_gray_w1, rd_gray_w2, wr_gray_r1, wr_gray_r2;
    reg full_reg;

    wire [ADDR_WIDTH:0] wr_bin_next = wr_bin + ((wr_en && !full_reg) ? 1'b1 : 1'b0);
    wire [ADDR_WIDTH:0] rd_bin_next = rd_bin + ((rd_en && !empty) ? 1'b1 : 1'b0);
    wire [ADDR_WIDTH:0] wr_gray_next = (wr_bin_next >> 1) ^ wr_bin_next;
    wire [ADDR_WIDTH:0] rd_gray_next = (rd_bin_next >> 1) ^ rd_bin_next;

    function [ADDR_WIDTH:0] gray2bin;
        input [ADDR_WIDTH:0] gray;
        integer k;
        begin
            gray2bin[ADDR_WIDTH] = gray[ADDR_WIDTH];
            for (k=ADDR_WIDTH-1; k>=0; k=k-1)
                gray2bin[k] = gray2bin[k+1] ^ gray[k];
        end
    endfunction

    wire [ADDR_WIDTH:0] rd_bin_wr = gray2bin(rd_gray_w2);
    wire [ADDR_WIDTH:0] wr_bin_rd = gray2bin(wr_gray_r2);
    wire full_next = (wr_gray_next ==
                      {~rd_gray_w2[ADDR_WIDTH:ADDR_WIDTH-1], rd_gray_w2[ADDR_WIDTH-2:0]});

    assign full        = full_reg;
    assign empty       = (rd_gray == wr_gray_r2);
    assign wr_count    = wr_bin - rd_bin_wr;
    assign rd_count    = wr_bin_rd - rd_bin;
    assign almost_full = (wr_count >= ALMOST_FULL_LEVEL);

    always @(posedge wr_clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_bin <= 0; wr_gray <= 0;
            rd_gray_w1 <= 0; rd_gray_w2 <= 0;
            full_reg <= 1'b0;
        end else begin
            rd_gray_w1 <= rd_gray;
            rd_gray_w2 <= rd_gray_w1;
            full_reg <= full_next;
            if (wr_en && !full_reg) begin
                mem[wr_bin[ADDR_WIDTH-1:0]] <= wr_data;
                wr_bin  <= wr_bin_next;
                wr_gray <= wr_gray_next;
            end
        end
    end

    always @(posedge rd_clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_bin <= 0; rd_gray <= 0;
            wr_gray_r1 <= 0; wr_gray_r2 <= 0;
            rd_data <= 0;
        end else begin
            wr_gray_r1 <= wr_gray;
            wr_gray_r2 <= wr_gray_r1;
            if (rd_en && !empty) begin
                rd_data <= mem[rd_bin[ADDR_WIDTH-1:0]];
                rd_bin  <= rd_bin_next;
                rd_gray <= rd_gray_next;
            end
        end
    end
endmodule

// Standard Gray-pointer asynchronous FIFO.  The memory is intentionally
// shallow and only absorbs clock-domain/DDR latency; bulk storage is DDR3.
module packet_async_fifo #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
)(
    input wire wr_clk, input wire rd_clk, input wire rst_n,
    input wire wr_en, input wire [DATA_WIDTH-1:0] wr_data,
    input wire rd_en, output wire [DATA_WIDTH-1:0] rd_data,
    output wire full, output wire empty,
    output wire [ADDR_WIDTH:0] wr_count, output wire [ADDR_WIDTH:0] rd_count
);
    reg [DATA_WIDTH-1:0] mem [0:(1<<ADDR_WIDTH)-1];
    reg [ADDR_WIDTH:0] wr_bin, rd_bin, wr_gray, rd_gray;
    reg [ADDR_WIDTH:0] rd_gray_w1, rd_gray_w2, wr_gray_r1, wr_gray_r2;
    reg full_reg;
    wire [ADDR_WIDTH:0] wr_bin_next = wr_bin + ((wr_en && !full_reg) ? 1'b1 : 1'b0);
    wire [ADDR_WIDTH:0] rd_bin_next = rd_bin + ((rd_en && !empty) ? 1'b1 : 1'b0);
    wire [ADDR_WIDTH:0] wr_gray_next = (wr_bin_next >> 1) ^ wr_bin_next;
    wire [ADDR_WIDTH:0] rd_gray_next = (rd_bin_next >> 1) ^ rd_bin_next;
    function [ADDR_WIDTH:0] gray2bin;
        input [ADDR_WIDTH:0] gray;
        integer k;
        begin
            gray2bin[ADDR_WIDTH] = gray[ADDR_WIDTH];
            for (k=ADDR_WIDTH-1; k>=0; k=k-1) gray2bin[k] = gray2bin[k+1] ^ gray[k];
        end
    endfunction
    wire [ADDR_WIDTH:0] rd_bin_wr = gray2bin(rd_gray_w2);
    wire [ADDR_WIDTH:0] wr_bin_rd = gray2bin(wr_gray_r2);
    wire full_next = (wr_gray_next == {~rd_gray_w2[ADDR_WIDTH:ADDR_WIDTH-1],rd_gray_w2[ADDR_WIDTH-2:0]});
    assign full = full_reg;
    assign empty = (rd_gray == wr_gray_r2);
    assign wr_count = wr_bin - rd_bin_wr;
    assign rd_count = wr_bin_rd - rd_bin;
    assign rd_data = mem[rd_bin[ADDR_WIDTH-1:0]];
    always @(posedge wr_clk or negedge rst_n) begin
        if (!rst_n) begin wr_bin<=0; wr_gray<=0; rd_gray_w1<=0; rd_gray_w2<=0; full_reg<=1'b0; end
        else begin
            rd_gray_w1 <= rd_gray; rd_gray_w2 <= rd_gray_w1;
            full_reg <= full_next;
            if (wr_en && !full) begin mem[wr_bin[ADDR_WIDTH-1:0]] <= wr_data; wr_bin<=wr_bin_next; wr_gray<=wr_gray_next; end
        end
    end
    always @(posedge rd_clk or negedge rst_n) begin
        if (!rst_n) begin rd_bin<=0; rd_gray<=0; wr_gray_r1<=0; wr_gray_r2<=0; end
        else begin
            wr_gray_r1 <= wr_gray; wr_gray_r2 <= wr_gray_r1;
            if (rd_en && !empty) begin rd_bin<=rd_bin_next; rd_gray<=rd_gray_next; end
        end
    end
endmodule
