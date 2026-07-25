module phy_led (
    input  wire        sys_clk,
    input  wire        rst_n,
    input  wire        eth_act,
    input  wire        error,
    input  wire        data_clk,
    input  wire        rx_act,
    input  wire        tx_act,

    output wire [4:0]  led
);

// LED control logic
// [0] - ACT, [1] - POWER, [2] - STATUS, [3] - RX, [4] - TX
localparam [7:0] ACT_LED_BRIGHTNESS    = 8'd255;
localparam [7:0] POWER_LED_BRIGHTNESS  = 8'd255;
localparam [7:0] STATUS_LED_BRIGHTNESS = 8'd255;
localparam [7:0] RX_LED_BRIGHTNESS     = 8'd255;
localparam [7:0] TX_LED_BRIGHTNESS     = 8'd6;
localparam       STATUS_NORMAL_BIT     = 23;
localparam       ERROR_PHASE_MSB       = 24;
localparam       ERROR_PHASE_LSB       = 21;

reg [7:0] pwm_cnt;
reg [1:0] eth_act_sync;
reg [1:0] rx_act_sync;
reg [1:0] tx_act_sync;
reg [1:0] status_blink_sync;
reg [31:0] status_cnt;
reg [1:0] error_data_sync;

wire [3:0] error_blink_phase;
wire       error_blink;
wire status_blink;
assign error_blink_phase = status_cnt[ERROR_PHASE_MSB:ERROR_PHASE_LSB];
assign error_blink = (error_blink_phase < 4'd4) ||
                     (error_blink_phase == 4'd5) ||
                     (error_blink_phase == 4'd7);
assign status_blink = error_data_sync[1] ? error_blink : status_cnt[STATUS_NORMAL_BIT];

always @(posedge sys_clk or negedge rst_n) begin
    if (!rst_n) begin
        pwm_cnt <= 8'd0;
        eth_act_sync <= 2'b00;
        rx_act_sync <= 2'b00;
        tx_act_sync <= 2'b00;
        status_blink_sync <= 2'b00;
    end else begin
        pwm_cnt <= pwm_cnt + 8'd1;
        eth_act_sync <= {eth_act_sync[0], eth_act};
        rx_act_sync <= {rx_act_sync[0], rx_act};
        tx_act_sync <= {tx_act_sync[0], tx_act};
        status_blink_sync <= {status_blink_sync[0], status_blink};
    end
end

always @(posedge data_clk or negedge rst_n) begin
    if (!rst_n) begin
        status_cnt <= 32'd0;
        error_data_sync <= 2'b00;
    end else begin
        status_cnt <= status_cnt + 32'd1;
        error_data_sync <= {error_data_sync[0], error};
    end
end

wire [4:0] led_en;
assign led_en[0] = eth_act_sync[1];
assign led_en[1] = rst_n;
assign led_en[2] = status_blink_sync[1];
assign led_en[3] = rx_act_sync[1];
assign led_en[4] = tx_act_sync[1];

wire [4:0] pwm_gate;
assign pwm_gate[0] = (ACT_LED_BRIGHTNESS    == 8'hff) ? 1'b1 : (pwm_cnt < ACT_LED_BRIGHTNESS);
assign pwm_gate[1] = (POWER_LED_BRIGHTNESS  == 8'hff) ? 1'b1 : (pwm_cnt < POWER_LED_BRIGHTNESS);
assign pwm_gate[2] = (STATUS_LED_BRIGHTNESS == 8'hff) ? 1'b1 : (pwm_cnt < STATUS_LED_BRIGHTNESS);
assign pwm_gate[3] = (RX_LED_BRIGHTNESS     == 8'hff) ? 1'b1 : (pwm_cnt < RX_LED_BRIGHTNESS);
assign pwm_gate[4] = (TX_LED_BRIGHTNESS     == 8'hff) ? 1'b1 : (pwm_cnt < TX_LED_BRIGHTNESS);

assign led = led_en & pwm_gate;

endmodule //phy_led
