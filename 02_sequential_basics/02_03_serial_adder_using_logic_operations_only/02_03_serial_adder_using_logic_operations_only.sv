//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module serial_adder
(
  input  clk,
  input  rst,
  input  a,
  input  b,
  output sum
);

  // Note:
  // carry_d represents the combinational data input to the carry register.

  logic carry;
  wire carry_d;

  assign { carry_d, sum } = a + b + carry;

  always_ff @ (posedge clk)
    if (rst)
      carry <= '0;
    else
      carry <= carry_d;

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module serial_adder_using_logic_operations_only
(
  input  clk,
  input  rst,
  input  a,
  input  b,
  output sum
);

  logic carry_in;
  wire  carry_out;

  assign sum       = a ^ b ^ carry_in;
  assign carry_out = (a & b) | (carry_in & (a ^ b));

  always_ff @(posedge clk) begin
    if (rst) begin
      carry_in <= '0;
    end else begin
      carry_in <= carry_out;
    end
  end


endmodule
