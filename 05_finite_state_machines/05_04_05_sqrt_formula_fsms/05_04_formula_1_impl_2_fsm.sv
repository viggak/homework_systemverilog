//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_1_impl_2_fsm
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

    output logic        isqrt_1_x_vld,
    output logic [31:0] isqrt_1_x,

    input               isqrt_1_y_vld,
    input        [15:0] isqrt_1_y,

    output logic        isqrt_2_x_vld,
    output logic [31:0] isqrt_2_x,

    input               isqrt_2_y_vld,
    input        [15:0] isqrt_2_y
);

    enum logic [1 : 0] {
        state_ord = 2'b00,
        state_a_b = 2'b01,
        state_c   = 2'b10
    }
    state, new_state;

    always_comb begin
        new_state = state;

        case (state)
            state_ord: if (arg_vld)
                new_state = state_a_b;
            state_a_b: if (isqrt_1_y_vld & isqrt_2_y_vld)
                new_state = state_c;
            state_c:   if (isqrt_1_y_vld & isqrt_2_y_vld)
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
        isqrt_1_x_vld = '0;
        isqrt_2_x_vld = '0;

        case (state)
            state_ord: begin
                isqrt_1_x_vld = arg_vld;
                isqrt_2_x_vld = arg_vld;
            end
            state_a_b: begin
                isqrt_1_x_vld = isqrt_1_y_vld;
                isqrt_2_x_vld = isqrt_2_y_vld;
            end
        endcase
    end

    always_comb begin
        isqrt_1_x = 'x;
        isqrt_2_x = 'x;

        case (state)
            state_ord: begin
                isqrt_1_x = a;
                isqrt_2_x = b;
            end
            state_a_b: begin
                isqrt_1_x = c;
                isqrt_2_x = '0;
            end
        endcase
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            res_vld <= '0;
        end else begin
            res_vld <= ((state == state_c) & isqrt_1_y_vld & isqrt_2_y_vld);
        end
    end

    always_ff @(posedge clk) begin
        if (state == state_ord) begin
            res <= '0;
        end else if (isqrt_1_y_vld & isqrt_2_y_vld) begin
            res <= res + isqrt_1_y + isqrt_2_y;
        end
    end

endmodule
