`default_nettype none
`timescale 1ns/1ns

module sim_pwm_top();

  // system clock
  localparam integer SYS_CLOCK_FREQ = 50 * 10 ** 6; // 50 MHz
  localparam integer SYS_CLOCK_PERIOD_NS = 10 ** 9 / SYS_CLOCK_FREQ;

  // pwm parameter
  localparam integer SCALE = 256;
  localparam integer DIV   = 1024;
  localparam integer MSEC  = 857;

  localparam integer PWM_PERIOD_NS = SYS_CLOCK_PERIOD_NS * SCALE;

  reg clk, n_rst, sw_in;
  wire led;

  pwm_top
  #(
    .SYS_CLOCK_FREQ(SYS_CLOCK_FREQ),
    .DIV(DIV),
    .MSEC(MSEC),
    .SCALE(SCALE)
  )
  pwm_top_inst0
  (
    .clk(clk),
    .n_rst(n_rst),
    .sw_in(sw_in),
    .led(led)
  );

  // generate system clock
  initial begin
    clk <= 1'b0;
    forever #(SYS_CLOCK_PERIOD_NS / 2) clk <= ~clk;
  end

  // reset
  initial begin
    n_rst <= 1'b1;
    repeat (2) #(SYS_CLOCK_PERIOD_NS) n_rst <= ~n_rst;
  end

  // simulation sw_in
  initial begin
    sw_in <= 1'b1;
    #(SYS_CLOCK_PERIOD_NS * 5)
    repeat (2) #(SYS_CLOCK_PERIOD_NS) sw_in <= ~sw_in;
    #(PWM_PERIOD_NS * 256)
    $finish;
  end
  
  // simulation wave and result
  initial begin
    $shm_open("pwm_top.shm");
    //$shm_probe("ACM");
    $shm_probe(pwm_top_inst0,"ACM");
  end

endmodule

`default_nettype wire
