`default_nettype none

module pwm_top
  #(
    parameter SYS_CLOCK_FREQ = 50 * 10 ** 6, // 50 MHz
    parameter DIV = 1024,
    //parameter MSEC = 3 * 10 ** 3, // 3 s
    parameter MSEC = 857, // 0.857 s (70 bpm) : the average heart rate of adult men
    parameter SCALE = 256
  )
  (
    input wire clk,
    input wire n_rst,
    input wire sw_in,
    input wire [7:0] SW,
    output wire led,
    output wire ledr
  );

  localparam integer CLK_CNT_MAX = SYS_CLOCK_FREQ / (DIV * 10 ** 3 / MSEC); // SYS_CLOCK_FREQ / DIV_FREQ

  `include "duty.tab"

  reg sw_in_pre;
  reg sw_flag = 1'b0;
  reg mod_onoff = 1'b0;
  reg [$clog2(CLK_CNT_MAX):0] clk_cnt = 'd0;
  reg [$clog2(DIV):0] duty_addr = 'd0;

  // debounce
  wire debounced_sw_in;

  // pwm instance register
  reg [$clog2(SCALE):0] value = 'd127;

  assign ledr = mod_onoff;

  always @(posedge clk) begin
    if (!n_rst) begin
      // reset
      sw_in_pre <= 1'b1;
      sw_flag <= 1'b0;
      mod_onoff <= 1'b0;
      value <= 'd0;
      duty_addr = 'd0;
      clk_cnt = 'd0;
    end else begin
      // count clock cycles
      clk_cnt <= (clk_cnt < CLK_CNT_MAX - 1) ? clk_cnt + 1'b1 : 'd0;

      // chattering control
      sw_in_pre <= debounced_sw_in;
      sw_flag <= ((!debounced_sw_in) & sw_in_pre);

      // pwm on/off
      if (sw_flag) begin
        mod_onoff <= ~mod_onoff;
      end

      if (clk_cnt == CLK_CNT_MAX - 1) begin
        // manage addr
        duty_addr <= (duty_addr < DIV - 1) ? duty_addr + 1'b1 : 1'b0;

        // modulation
        value <= (mod_onoff) ? duty[duty_addr] : value;
      end
      else begin
        duty_addr <= duty_addr;
        value <= value;
      end
    end
  end

  pwm
  #(
    .CLOCK_FREQ(SYS_CLOCK_FREQ),
    .SCALE(SCALE)
  )
  pwm_inst0
  (
    .clk(clk),
    .n_rst(n_rst),
    .value(value),
    .pulse(led)
  );

  debouncer
  #(
    .SYS_CLOCK_FREQ(SYS_CLOCK_FREQ), // 50 MHz
    .NS(1000) // 10 us
  )
  debouncer_inst0
  (
    .clk(clk),
    .n_rst(n_rst),
    .sig_in(sw_in),
    .sig_out(debounced_sw_in)
  );
endmodule

`default_nettype wire
