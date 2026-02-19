//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module sort_floats_using_fsm (
    input                          clk,
    input                          rst,

    input                          valid_in,
    input        [0:2][FLEN - 1:0] unsorted,

    output logic                   valid_out,
    output logic [0:2][FLEN - 1:0] sorted,
    output logic                   err,
    output                         busy,

    // f_less_or_equal interface
    output logic      [FLEN - 1:0] f_le_a,
    output logic      [FLEN - 1:0] f_le_b,
    input                          f_le_res,
    input                          f_le_err
);

    logic [FLEN - 1:0] u0, u1, u2;
    logic u0_less_or_equal_u1, u1_less_or_equal_u2, u0_less_or_equal_u2;

    enum logic [1 : 0] {
        state_ord   = 2'b00,
        state_u0_u1 = 2'b01,
        state_u1_u2 = 2'b10,
        state_u0_u2 = 2'b11
    }
    state, new_state;

    always_comb begin
        if (valid_in) begin
            u0 = unsorted[0];
            u1 = unsorted[1];
            u2 = unsorted[2];
        end
    end

    always_comb begin
        new_state = state;

        case (state)
            state_ord:   if ( valid_in) new_state = state_u0_u1;
            state_u0_u1: if (!f_le_err) new_state = state_u1_u2;
            state_u1_u2: if (!f_le_err) new_state = state_u0_u2;
            state_u0_u2: if (!f_le_err) new_state = state_ord;
        endcase
    end

    always_ff @(posedge clk) begin
        if (rst | f_le_err) begin
            state <= state_ord;
        end else begin
            state <= new_state;
        end
    end

    always_comb begin
        case (state)
            state_ord: begin
                f_le_a = u0;
                f_le_b = u1;
                u0_less_or_equal_u1 = f_le_res;
            end
            state_u0_u1: begin
                f_le_a = u1;
                f_le_b = u2;
                u1_less_or_equal_u2 = f_le_res;
            end
            state_u1_u2: begin
                f_le_a = u0;
                f_le_b = u2;
                u0_less_or_equal_u2 = f_le_res;
            end
        endcase
    end

    always_comb begin
        if (u0_less_or_equal_u1 & u1_less_or_equal_u2) begin
            sorted = unsorted;
        end else if (u0_less_or_equal_u1 & !u1_less_or_equal_u2 & u0_less_or_equal_u2) begin
            sorted = {u0, u2, u1};
        end else if (!u0_less_or_equal_u1 & u1_less_or_equal_u2 & u0_less_or_equal_u2) begin
            sorted = {u1, u0, u2};
        end else if (u0_less_or_equal_u1 & !u1_less_or_equal_u2 & !u0_less_or_equal_u2) begin
            sorted = {u2, u0, u1};
        end else if (!u0_less_or_equal_u1 & u1_less_or_equal_u2 & !u0_less_or_equal_u2) begin
            sorted = {u1, u2, u0};
        end else if (!u0_less_or_equal_u1 & !u1_less_or_equal_u2 & !u0_less_or_equal_u2) begin
            sorted = {u2, u1, u0};
        end
    end

    assign valid_out = (state == state_u0_u2) | (f_le_err);
    assign err = f_le_err;
    assign busy = (state != state_ord);

endmodule
