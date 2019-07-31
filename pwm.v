`default_nettype none

module pwm
  #(
    parameter CLOCK_FREQ = 50 * 10 ** 6, // 50 MHz
    parameter SCALE = 256
  )
  (
    input wire clk,
    input wire n_rst, 
    input wire [$clog2(SCALE):0] value,
    output wire pulse
  );

  reg [$clog2(SCALE):0] clk_cnt = 'd0;
  reg pulse_reg = 1'b0;

  assign pulse = pulse_reg;

  always @(posedge clk) begin
    if (!n_rst) begin
      // reset
      clk_cnt <= 1'b0;
      pulse_reg = 1'b0;
    end else begin
      // count clock cycles
      clk_cnt <= (clk_cnt < SCALE - 1) ? clk_cnt + 1'b1 : 'd0;
      pulse_reg <= clk_cnt < value;

    end
  end

endmodule
`default_nettype wire
