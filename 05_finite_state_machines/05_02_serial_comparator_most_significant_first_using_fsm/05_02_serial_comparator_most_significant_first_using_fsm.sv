//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module serial_comparator_least_significant_first_using_fsm
(
  input  clk,
  input  rst,
  input  a,
  input  b,
  output a_less_b,
  output a_eq_b,
  output a_greater_b
);

  // States
  enum logic[2:0]
  {
     st_a_less_b    = 3'b100,
     st_equal       = 3'b010,
     st_a_greater_b = 3'b001
  }
  state, new_state;

  // State transition logic
  always_comb
  begin
    new_state = state;

    // This lint warning is bogus because we assign the default value above
    // verilator lint_off CASEINCOMPLETE

    case (state)
      st_equal       : if (~ a &   b) new_state = st_a_less_b;
                  else if (  a & ~ b) new_state = st_a_greater_b;
      st_a_less_b    : if (  a & ~ b) new_state = st_a_greater_b;
      st_a_greater_b : if (~ a &   b) new_state = st_a_less_b;
    endcase

    // verilator lint_on  CASEINCOMPLETE
  end

  // Output logic
  assign { a_less_b, a_eq_b, a_greater_b } = new_state;

  always_ff @ (posedge clk)
    if (rst)
      state <= st_equal;
    else
      state <= new_state;

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module serial_comparator_most_significant_first_using_fsm
(
  input  clk,
  input  rst,
  input  a,
  input  b,
  output a_less_b,
  output a_eq_b,
  output a_greater_b
);

  // Task:
  // Implement a serial comparator module similar to the previous exercise
  // but use the Finite State Machine to evaluate the result.
  // Most significant bits arrive first.

  enum logic [1:0]
  {
    st_equal   = 2'b00,
    st_less    = 2'b01,
    st_greater = 2'b10
  }
  state, new_state;

  always_comb begin
    new_state = state;

    case (state)
      st_equal   :      if (~a &  b) new_state = st_less;
                   else if ( a & ~b) new_state = st_greater;
                   else              new_state = st_equal;
      st_less    :                   new_state = st_less;
      st_greater :                   new_state = st_greater;
    endcase
  end

  always_ff @(posedge clk) begin
    if (rst) begin
      state <= st_equal;
    end else begin
      state <= new_state;
    end
  end

  assign a_eq_b      = (a == b) & (state == st_equal);
  assign a_less_b    = (~a & b) & (state == st_equal) | (state == st_less);
  assign a_greater_b = (a & ~b) & (state == st_equal) | (state == st_greater);

endmodule
