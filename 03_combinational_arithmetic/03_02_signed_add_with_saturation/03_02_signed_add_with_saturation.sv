//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module add
(
  input  [3:0] a, b,
  output [3:0] sum
);

  assign sum = a + b;

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module signed_add_with_saturation
(
  input  [3:0] a, b,
  output [3:0] sum
);

  // Task:
  //
  // Implement a module that adds two signed numbers with saturation.
  //
  // "Adding with saturation" means:
  //
  // When the result does not fit into 4 bits,
  // and the arguments are positive,
  // the sum should be set to the maximum positive number.
  //
  // When the result does not fit into 4 bits,
  // and the arguments are negative,
  // the sum should be set to the minimum negative number.

  wire [4:0] sum_over   = { a[3], a } + { b[3], b };
  wire       sum_signed = sum_over[4];

  wire pos_over = ~a[3] & ~b[3] & ( sum_signed | sum_over[3:0] > 4'b0111);
  wire neg_over =  a[3] &  b[3] & (~sum_signed | sum_over[3:0] < 4'b1000);

  assign sum = pos_over ? 4'b0111 : (neg_over ? 4'b1000 : sum_over[3:0]);

endmodule
