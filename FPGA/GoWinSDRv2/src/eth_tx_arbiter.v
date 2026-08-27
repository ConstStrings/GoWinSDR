// Packet-granular arbiter for the single eth_transceiver user-TX port.
// RF packets have priority because their source FIFO is bounded.  Credit
// telemetry is low-priority and can be coalesced by eth_credit_status.
// A granted source retains ownership from its grant until eth_transceiver has
// consumed the terminating valid-low cycle and becomes ready again.
module eth_tx_arbiter (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        downstream_ready,

    input  wire        rf_request,
    output reg         rf_grant,
    input  wire [7:0]  rf_data,
    input  wire        rf_valid,
    input  wire        rf_frame_start,

    input  wire        status_request,
    output reg         status_grant,
    input  wire [7:0]  status_data,
    input  wire        status_valid,
    input  wire        status_frame_start,

    output reg  [7:0]  tx_data,
    output reg         tx_valid,
    output reg         tx_frame_start
);
    localparam ARB_IDLE       = 3'd0;
    localparam ARB_WAIT_RF    = 3'd1;
    localparam ARB_RF_ACTIVE  = 3'd2;
    localparam ARB_WAIT_ST    = 3'd3;
    localparam ARB_ST_ACTIVE  = 3'd4;
    localparam ARB_WAIT_BUSY  = 3'd5;
    localparam ARB_WAIT_READY = 3'd6;

    reg [2:0] state;
    reg       saw_valid;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state          <= ARB_IDLE;
            saw_valid      <= 1'b0;
            rf_grant       <= 1'b0;
            status_grant   <= 1'b0;
            tx_data        <= 8'd0;
            tx_valid       <= 1'b0;
            tx_frame_start <= 1'b0;
        end else begin
            rf_grant       <= 1'b0;
            status_grant   <= 1'b0;
            tx_valid       <= 1'b0;
            tx_frame_start <= 1'b0;

            case (state)
                ARB_IDLE: begin
                    if (downstream_ready) begin
                        if (rf_request) begin
                            rf_grant <= 1'b1;
                            state    <= ARB_WAIT_RF;
                        end else if (status_request) begin
                            status_grant <= 1'b1;
                            state        <= ARB_WAIT_ST;
                        end
                    end
                end

                ARB_WAIT_RF: begin
                    tx_data        <= rf_data;
                    tx_valid       <= rf_valid;
                    tx_frame_start <= rf_frame_start;
                    if (rf_frame_start) begin
                        saw_valid <= 1'b0;
                        state     <= ARB_RF_ACTIVE;
                    end
                end

                ARB_RF_ACTIVE: begin
                    tx_data        <= rf_data;
                    tx_valid       <= rf_valid;
                    tx_frame_start <= rf_frame_start;
                    if (rf_valid)
                        saw_valid <= 1'b1;
                    else if (saw_valid)
                        state <= ARB_WAIT_BUSY;
                end

                ARB_WAIT_ST: begin
                    tx_data        <= status_data;
                    tx_valid       <= status_valid;
                    tx_frame_start <= status_frame_start;
                    if (status_frame_start) begin
                        saw_valid <= 1'b0;
                        state     <= ARB_ST_ACTIVE;
                    end
                end

                ARB_ST_ACTIVE: begin
                    tx_data        <= status_data;
                    tx_valid       <= status_valid;
                    tx_frame_start <= status_frame_start;
                    if (status_valid)
                        saw_valid <= 1'b1;
                    else if (saw_valid)
                        state <= ARB_WAIT_BUSY;
                end

                // eth_transceiver uses the first valid-low cycle to commit
                // its input buffer.  Wait through busy and ready before
                // granting another source, so no two packets can merge.
                ARB_WAIT_BUSY: begin
                    if (!downstream_ready)
                        state <= ARB_WAIT_READY;
                end

                ARB_WAIT_READY: begin
                    if (downstream_ready)
                        state <= ARB_IDLE;
                end

                default: state <= ARB_IDLE;
            endcase
        end
    end
endmodule
