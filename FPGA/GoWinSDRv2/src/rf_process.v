module rf_process #(
    parameter                           SAMPLE_RATE = 32'd30720000 ,
    parameter                           SYMBOL_RATE = 32'd7680000  ,
    // 1: insert a carrier when the TX byte FIFO is empty.
    // 0: transmit only queued data (burst mode).
    parameter                           IDLE_CARRIER_ENABLE = 1'b1,
    // 1: bypass the RRC output and feed DQPSK I/Q directly to the DAC FIFO.
    parameter                           RRC_BYPASS_ENABLE = 1'b1
)(
    input                               sys_clk                    ,
    input                               rst_n                      ,
    input                               sample_clk                 ,
    input                               bb_symbol_clk              ,
    input                               bb_byte_clk                ,

    // RX DATA Port
    output             [   7:0]         rx_data_out                ,
    output                              rx_clk_out                 ,
    output                              rx_data_valid              ,
    output                              rx_data_missing            ,    

    // RX Signal Input
    input              [  11:0]         adc_data_in_i1             ,
    input              [  11:0]         adc_data_in_q1             ,
    input                               adc_in_valid               ,

    // TX DATA Port
    input              [   7:0]         tx_data_in                 ,
    input                               tx_clk_in                  ,
    input                               tx_data_valid              ,
    output                              tx_data_ready              ,

    // TX Signal Output
    output             [  11:0]         dac_data_out_i1            ,
    output             [  11:0]         dac_data_out_q1            ,
    output                              dac_out_valid               
);

// ============================================================
// TX Path: Byte-clock CDC FIFO -> Byte Hold -> DQPSK Encoder -> RRC Filter -> FIFO -> DAC
//
// Flow control / backpressure:
//   ETH FIFO empty  -> encoder enters carrier mode (intentional idle)
//                      carrier ONLY written to FIFO when Almost_Empty
//                      (FIFO low on data), otherwise suppressed to
//                      avoid filling the FIFO with useless samples
//   RF  FIFO full   -> stall asserted: encoder freezes state,
//                      no carrier inserted, data stream preserved
// ============================================================

// --- FIFO status signals ---
wire stall_pipeline;
wire fifo_i_almost_full;
wire fifo_q_almost_full;
wire fifo_i_almost_empty;
wire fifo_q_almost_empty;

assign stall_pipeline = fifo_i_almost_full || fifo_q_almost_full;

// Almost_Empty is generated in sample_clk domain.  Synchronize the combined
// low-watermark indication before using it in the bb_symbol_clk domain.
wire dac_fifo_low_sample;
reg  [1:0] dac_fifo_low_sync;
wire       dac_fifo_low;

assign dac_fifo_low_sample = fifo_i_almost_empty && fifo_q_almost_empty;
assign dac_fifo_low        = dac_fifo_low_sync[1];

always @(posedge bb_symbol_clk or negedge rst_n) begin
    if (!rst_n) begin
        dac_fifo_low_sync <= 2'b00;
    end else begin
        dac_fifo_low_sync <= {dac_fifo_low_sync[0], dac_fifo_low_sample};
    end
end

// --- Byte-clock to symbol-clock CDC FIFO ---
// tx_data_in/tx_data_valid are synchronous to tx_clk_in.  The DQPSK path
// consumes bytes on bb_symbol_clk, so use an asynchronous FIFO between them.
wire [7:0] tx_byte_fifo_data;
wire       tx_byte_fifo_empty;
wire       tx_byte_fifo_full;
reg        tx_byte_fifo_rd_en;
reg        tx_byte_fifo_fetch;

assign tx_data_ready = !tx_byte_fifo_full;

fifo_rf_databuf u_fifo_tx_byte_cdc(
    .Data        (tx_data_in),
    .WrClk       (tx_clk_in),
    .RdClk       (bb_symbol_clk),
    .WrEn        (tx_data_valid && tx_data_ready),
    .RdEn        (tx_byte_fifo_rd_en),
    .Q           (tx_byte_fifo_data),
    .Empty       (tx_byte_fifo_empty),
    .Full        (tx_byte_fifo_full)
);

// --- Byte-hold register ---
reg  [7:0] tx_byte_hold;
reg        tx_byte_held;
reg  [7:0] tx_byte_prefetch;
reg        tx_byte_prefetch_valid;

// --- DQPSK Encoder ---
wire signed [11:0] qpsk_i_out;
wire signed [11:0] qpsk_q_out;
wire               qpsk_ready;
wire               qpsk_byte_done;
wire               tx_data_valid_dqpsk;

// Data queued in the CDC FIFO is not an idle interval.  It must suppress
// carrier insertion even before the byte is loaded into tx_byte_hold.
wire tx_data_pending;
wire allow_carrier;

assign tx_data_pending = tx_byte_held || tx_byte_prefetch_valid ||
                         tx_byte_fifo_fetch ||
                         !tx_byte_fifo_empty;
assign allow_carrier   = IDLE_CARRIER_ENABLE && !tx_data_pending &&
                         dac_fifo_low && !stall_pipeline;
assign qpsk_byte_done  = tx_byte_held && qpsk_ready;

always @(posedge bb_symbol_clk or negedge rst_n) begin
    if (!rst_n) begin
        tx_byte_hold           <= 8'd0;
        tx_byte_held           <= 1'b0;
        tx_byte_prefetch       <= 8'd0;
        tx_byte_prefetch_valid <= 1'b0;
        tx_byte_fifo_rd_en     <= 1'b0;
        tx_byte_fifo_fetch     <= 1'b0;
    end else begin
        tx_byte_fifo_rd_en <= 1'b0;

        if (tx_byte_fifo_fetch) begin
            // Complete a FIFO read.  A byte arriving on the final symbol
            // replaces the current byte without an idle symbol gap.
            tx_byte_fifo_fetch <= 1'b0;
            if (!tx_byte_held || qpsk_byte_done) begin
                tx_byte_hold <= tx_byte_fifo_data;
                tx_byte_held <= 1'b1;
            end else begin
                tx_byte_prefetch       <= tx_byte_fifo_data;
                tx_byte_prefetch_valid <= 1'b1;
            end
        end else if (qpsk_byte_done) begin
            if (tx_byte_prefetch_valid) begin
                tx_byte_hold           <= tx_byte_prefetch;
                tx_byte_held           <= 1'b1;
                tx_byte_prefetch_valid <= 1'b0;
            end else begin
                tx_byte_held <= 1'b0;
            end
        end

        // Keep one byte queued while the current byte is being modulated.
        if (!tx_byte_fifo_fetch && !tx_byte_prefetch_valid &&
            !tx_byte_fifo_empty) begin
            tx_byte_fifo_rd_en <= 1'b1;
            tx_byte_fifo_fetch <= 1'b1;
        end
    end
end

assign tx_data_valid_dqpsk = tx_byte_held;

rf_dqpsk_encoder #(
    .SAMPLE_RATE (SAMPLE_RATE),
    .SYMBOL_RATE (SYMBOL_RATE)
) u_rf_dqpsk_encoder (
    .bb_symbol_clk (bb_symbol_clk),
    .rst_n         (rst_n),
    .tx_data_in    (tx_byte_hold),
    .tx_data_valid (tx_data_valid_dqpsk),
    .qpsk_ready    (qpsk_ready),
    .tx_fifo_ready (1'b1),
    .stall         (stall_pipeline),
    .qpsk_i_out    (qpsk_i_out),
    .qpsk_q_out    (qpsk_q_out)
);

// --- RRC Filter ---
// Valid in: data has priority; carrier is inserted only during true idle and
// while the DAC FIFO remains below its low-watermark threshold.
wire fir_valid_in;
assign fir_valid_in = (tx_data_valid_dqpsk || allow_carrier) && !stall_pipeline;

wire signed [26:0] fir_data_tx_i;
wire               fir_valid_tx_i;
wire signed [26:0] fir_data_tx_q;
wire               fir_valid_tx_q;

RRC_FIR_Filter_Top RRC_FIR_Filter_TX_i(
    .clk         (bb_symbol_clk),
    .rstn        (rst_n),
    .fir_rfi_o   (),
    .fir_valid_i (fir_valid_in),
    .fir_sync_i  (1'b1),
    .fir_data_i  (qpsk_i_out),
    .fir_valid_o (fir_valid_tx_i),
    .fir_sync_o  (),
    .fir_data_o  (fir_data_tx_i)
);

RRC_FIR_Filter_Top RRC_FIR_Filter_TX_q(
    .clk         (bb_symbol_clk),
    .rstn        (rst_n),
    .fir_rfi_o   (),
    .fir_valid_i (fir_valid_in),
    .fir_sync_i  (1'b1),
    .fir_data_i  (qpsk_q_out),
    .fir_valid_o (fir_valid_tx_q),
    .fir_sync_o  (),
    .fir_data_o  (fir_data_tx_q)
);

// --- Select RRC output or direct DQPSK I/Q for the DAC FIFO ---
wire signed [11:0] dac_i_12b;
wire signed [11:0] dac_q_12b;
wire               tx_sample_valid;

assign dac_i_12b       = RRC_BYPASS_ENABLE ? qpsk_i_out : fir_data_tx_i[23:12];
assign dac_q_12b       = RRC_BYPASS_ENABLE ? qpsk_q_out : fir_data_tx_q[23:12];
assign tx_sample_valid = RRC_BYPASS_ENABLE ? fir_valid_in :
                         (fir_valid_tx_i && fir_valid_tx_q);

// --- RF TX FIFOs (symbol rate -> sample rate crossing) ---
wire        fifo_wr_en;
reg         fifo_rd_en;

wire [11:0] fifo_i_dout;
wire [11:0] fifo_q_dout;
wire        fifo_i_empty;
wire        fifo_q_empty;
wire        fifo_i_full;
wire        fifo_q_full;

assign fifo_wr_en = tx_sample_valid && !stall_pipeline;

// Read side: FIFO words are QPSK symbols.  A symbol is held for BB_SYMBOL_DIV sample_clk periods. 
localparam integer BB_SYMBOL_DIV = SAMPLE_RATE / SYMBOL_RATE;
localparam [1:0] DAC_TX_IDLE      = 2'd0;
localparam [1:0] DAC_TX_READ_WAIT = 2'd1;
localparam [1:0] DAC_TX_LOAD      = 2'd2;
localparam [1:0] DAC_TX_HOLD      = 2'd3;

reg [1:0]  dac_tx_state;
reg [31:0] dac_tx_state_cnt;
reg        dac_tx_prefetch_pending;

reg  [11:0] dac_i_reg;
reg  [11:0] dac_q_reg;
reg         dac_valid_reg;

always @(posedge sample_clk or negedge rst_n) begin
    if (!rst_n) begin
        dac_i_reg     <= 12'd0;
        dac_q_reg     <= 12'd0;
        dac_valid_reg <= 1'b0;
        dac_tx_state  <= DAC_TX_IDLE;
        fifo_rd_en     <= 1'b0;
        dac_tx_state_cnt <= 32'd0;
        dac_tx_prefetch_pending <= 1'b0;
    end else begin
        case (dac_tx_state)
            DAC_TX_IDLE: begin
                dac_valid_reg <= 1'b0;
                dac_tx_state_cnt <= 32'd0;
                dac_tx_prefetch_pending <= 1'b0;
                fifo_rd_en <= 1'b0;
                if (!fifo_i_empty && !fifo_q_empty) begin
                    fifo_rd_en <= 1'b1;
                    dac_tx_state <= DAC_TX_READ_WAIT;
                end
            end

            DAC_TX_READ_WAIT: begin
                fifo_rd_en <= 1'b0;
                dac_tx_state <= DAC_TX_LOAD;
            end

            DAC_TX_LOAD: begin
                dac_i_reg     <= fifo_i_dout;
                dac_q_reg     <= fifo_q_dout;
                dac_valid_reg <= 1'b1;
                fifo_rd_en    <= 1'b0;
                dac_tx_state_cnt <= 32'd1;
                dac_tx_prefetch_pending <= 1'b0;
                dac_tx_state  <= DAC_TX_HOLD;

                if ((BB_SYMBOL_DIV == 2) && !fifo_i_empty && !fifo_q_empty) begin
                    fifo_rd_en <= 1'b1;
                    dac_tx_prefetch_pending <= 1'b1;
                end
            end

            DAC_TX_HOLD: begin
                fifo_rd_en <= 1'b0;
                if (dac_tx_state_cnt == BB_SYMBOL_DIV - 1) begin
                    dac_tx_state_cnt <= 32'd0;
                    if (dac_tx_prefetch_pending)
                        dac_tx_state <= DAC_TX_LOAD;
                    else
                        dac_tx_state <= DAC_TX_IDLE;
                end
                else if (dac_tx_state_cnt == BB_SYMBOL_DIV - 2) begin
                    dac_tx_state_cnt <= dac_tx_state_cnt + 1'b1;
                    if (!fifo_i_empty && !fifo_q_empty) begin
                        fifo_rd_en <= 1'b1;
                        dac_tx_prefetch_pending <= 1'b1;
                    end
                end
                else begin
                    dac_tx_state_cnt <= dac_tx_state_cnt + 1'b1;
                end
            end

            default: begin
                dac_tx_state <= DAC_TX_IDLE;
                dac_valid_reg <= 1'b0;
                fifo_rd_en <= 1'b0;
            end
        endcase
    end
end

// The FIFO output holds its previous word while Empty=1.  Do not resend
// that stale I/Q word during an idle interval; drive the DAC input to zero.
assign dac_data_out_i1 = dac_valid_reg ? dac_i_reg : 12'd0;
assign dac_data_out_q1 = dac_valid_reg ? dac_q_reg : 12'd0;
assign dac_out_valid   = dac_valid_reg;

fifo_rf fifo_rf_tx_i(
    .Data         (dac_i_12b),
    .WrClk        (bb_symbol_clk),
    .RdClk        (sample_clk),
    .WrEn         (fifo_wr_en),
    .RdEn         (fifo_rd_en),
    .Almost_Empty (fifo_i_almost_empty),
    .Almost_Full  (fifo_i_almost_full),
    .Q            (fifo_i_dout),
    .Empty        (fifo_i_empty),
    .Full         (fifo_i_full)
);

fifo_rf fifo_rf_tx_q(
    .Data         (dac_q_12b),
    .WrClk        (bb_symbol_clk),
    .RdClk        (sample_clk),
    .WrEn         (fifo_wr_en),
    .RdEn         (fifo_rd_en),
    .Almost_Empty (fifo_q_almost_empty),
    .Almost_Full  (fifo_q_almost_full),
    .Q            (fifo_q_dout),
    .Empty        (fifo_q_empty),
    .Full         (fifo_q_full)
);

// ============================================================
// RX Path: ADC -> Costas -> Gardner timing recovery -> DQPSK decoder
// ============================================================

// RRC is bypassed on RX during bring-up; Costas operates directly on ADC I/Q.
wire [11:0] rrc_out_i_adc;
wire [11:0] rrc_out_q_adc;
assign rrc_out_i_adc = adc_data_in_i1;
assign rrc_out_q_adc = adc_data_in_q1;

wire signed [11:0] costas_out_i_dbg;
wire signed [11:0] costas_out_q_dbg;

assign costas_out_i_dbg = rrc_out_i_adc;
assign costas_out_q_dbg = rrc_out_q_adc;

// costas costas_u0 (
//     .rst_n      (rst_n        ),
//     .sample_clk (sample_clk   ),
//     .sample_i1  (rrc_out_i_adc),
//     .sample_q1  (rrc_out_q_adc),
//     .data_out_i (costas_out_i_dbg ),
//     .data_out_q (costas_out_q_dbg )
// );

// // Gardner Timing Synchronization
(* keep = "true" *) wire gardner_sync_I;
(* keep = "true" *) wire gardner_sync_Q;
(* keep = "true" *) wire gardner_sync_flag;

gardner_sync #(
    .SAMPLE_RATE          (SAMPLE_RATE),
    .SYMBOL_RATE          (SYMBOL_RATE),
    // TX/RX 均由本机 AD9361 同一采样时钟驱动，固定在自动计算的标称步进。
    .TIMING_TRACK_ENABLE  (1'b0)
) gardner_sync_u0 (
    .clk(sample_clk),
    .rst_n(rst_n),
    .data_in_I(costas_out_i_dbg),
    .data_in_Q(costas_out_q_dbg),
    .sync_out_I(gardner_sync_I),
    .sync_out_Q(gardner_sync_Q),
    .sync_flag(gardner_sync_flag)
);


wire signed [11:0] dqpsk_rx_i;
wire signed [11:0] dqpsk_rx_q;
wire [7:0]         dqpsk_rx_data;
wire               dqpsk_rx_data_valid;

assign dqpsk_rx_i = gardner_sync_I ? 12'sd1 : -12'sd1;
assign dqpsk_rx_q = gardner_sync_Q ? 12'sd1 : -12'sd1;

rf_dqpsk_decoder u_rf_dqpsk_decoder (
    .bb_symbol_clk (sample_clk),
    .rst_n         (rst_n),
    .symbol_sync   (1'b0),
    .symbol_valid  (gardner_sync_flag),
    .qpsk_i_in     (dqpsk_rx_i),
    .qpsk_q_in     (dqpsk_rx_q),
    .rx_data_out   (dqpsk_rx_data),
    .rx_data_valid (dqpsk_rx_data_valid)
);

assign rx_data_out     = dqpsk_rx_data;
assign rx_clk_out      = sample_clk;
assign rx_data_valid   = dqpsk_rx_data_valid;
assign rx_data_missing = !adc_in_valid;

endmodule
