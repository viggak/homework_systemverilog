//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module posedge_detector (input clk, rst, a, output detected);

  logic a_r;

  // Note:
  // The a_r flip-flop input value d propogates to the output q
  // only on the next clock cycle.

  always_ff @ (posedge clk)
    if (rst)
      a_r <= '0;
    else
      a_r <= a;

  assign detected = ~ a_r & a;

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module one_cycle_pulse_detector (input clk, rst, a, output detected);

  logic a_reg, a_reg_2;

  always_ff @(posedge clk) begin
    if (rst) begin
      a_reg   <= '0;
      a_reg_2 <= '0;
    end else begin
      a_reg_2 <= a_reg;
      a_reg   <= a;
    end
  end

  assign detected = ~a_reg_2 & a_reg & ~a;


endmodule
