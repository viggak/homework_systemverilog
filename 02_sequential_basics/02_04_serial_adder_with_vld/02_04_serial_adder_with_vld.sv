//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module serial_adder_with_vld
(
  input  clk,
  input  rst,
  input  vld,
  input  a,
  input  b,
  input  last,
  output sum
);

  logic carry_out, carry_in;

  always_comb begin
    if (vld) begin
      { carry_in, carry_out } = a + b + carry_in;
    end else begin
      { carry_in, carry_out } = { carry_in, carry_out };
    end
  end

  always_ff @(posedge clk) begin
    if (rst) begin
      carry_out <= '0;
      carry_in <= '0;
    end else if (vld) begin
      if (last) begin
        carry_in <= '0;
      end
    end
  end

  assign sum = carry_out;


endmodule
