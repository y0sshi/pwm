`default_nettype none

module debouncer
  #(
    parameter SYS_CLOCK_FREQ = 50 * 10 ** 6, // 50 MHz
    parameter NS = 1000 // 10 us
  )
  (
    input wire clk,
    input wire n_rst,
    input wire sig_in,
    output wire sig_out
  );

  localparam integer SYS_PERIOD_NS = 10 ** 9 / SYS_CLOCK_FREQ;
  localparam integer CLK_CNT_MAX = NS / SYS_PERIOD_NS;

  reg [$clog2(CLK_CNT_MAX):0] clk_cnt;

  always @(posedge clk) begin
    if (!n_rst) begin
      clk_cnt <= 'd0;
    end else begin
      if (sig_in) begin
        clk_cnt <= (clk_cnt < CLK_CNT_MAX - 1) ? clk_cnt + 1'b1 : clk_cnt;
      end else begin
        clk_cnt <= 'd0;
      end
    end
  end

  assign sig_out = clk_cnt == CLK_CNT_MAX - 1;
endmodule

`default_nettype wire
