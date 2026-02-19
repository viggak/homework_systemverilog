//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_2_fsm
(
    input               clk,
    input               rst,

    input               arg_vld,
    input        [31:0] a,
    input        [31:0] b,
    input        [31:0] c,

    output logic        res_vld,
    output logic [31:0] res,

    // isqrt interface

    output logic        isqrt_x_vld,
    output logic [31:0] isqrt_x,

    input               isqrt_y_vld,
    input        [15:0] isqrt_y
);

    enum logic [1 : 0] {
        state_ord = 2'b00,
        state_c   = 2'b01,
        state_b   = 2'b10,
        state_a   = 2'b11
    }
    state, new_state;

    always_comb begin
        new_state = state;

        case (state)
            state_ord: if (arg_vld)
                new_state = state_c;
            state_c:   if (isqrt_y_vld)
                new_state = state_b;
            state_b:   if (isqrt_y_vld)
                new_state = state_a;
            state_a:   if (isqrt_y_vld)
                new_state = state_ord;
        endcase
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            state <= state_ord;
        end else begin
            state <= new_state;
        end
    end

    always_comb begin
        isqrt_x_vld = '0;

        case (state)
            state_ord: begin
                isqrt_x_vld = arg_vld;
            end
            state_b, state_c: begin
                isqrt_x_vld = isqrt_y_vld;
            end
        endcase
    end

    always_comb begin
        isqrt_x = 'x;

        case (state)
            state_ord: begin
                isqrt_x = c;
            end
            state_c: begin
                isqrt_x = b + isqrt_y;
            end
            state_b: begin
                isqrt_x = a + isqrt_y;
            end
        endcase
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            res_vld <= '0;
        end else begin
            res_vld <= ((state == state_a) & isqrt_y_vld);
        end
    end

    always_ff @(posedge clk) begin
        if (state == state_ord) begin
            res <= '0;
        end else if (isqrt_y_vld) begin
            res <= isqrt_y;
        end
    end

endmodule
