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
    // Task:
    // Implement a module that calculates the formula from the `formula_2_fn.svh` file
    // using only one instance of the isqrt module.
    //
    // Design the FSM to calculate answer step-by-step and provide the correct `res` value
    //
    // You can read the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.ru/fsm

    enum logic [1:0]
    {
        st_ord = 2'b00,
        st_a   = 2'b01,
        st_b   = 2'b10,
        st_c   = 2'b11
    }
    state, new_state;

    always_comb begin
        new_state = state;

        case (state)
            st_ord : if (arg_vld)     new_state = st_c;
            st_c   : if (isqrt_y_vld) new_state = st_b;
            st_b   : if (isqrt_y_vld) new_state = st_a;
            st_a   : if (isqrt_y_vld) new_state = st_ord;
        endcase
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            state <= st_ord;
        end else begin
            state <= new_state;
        end
    end

    always_comb begin
        isqrt_x_vld = '0;

        case (state)
                st_ord     : begin
                    isqrt_x_vld = arg_vld;
                end
                st_c, st_b : begin
                    isqrt_x_vld = isqrt_y_vld;
                end
        endcase
    end

    always_comb begin
        isqrt_x = 'x;

        case (state)
            st_ord : begin
                isqrt_x = c;
            end
            st_c : begin
                isqrt_x = b + isqrt_y;
            end
            st_b : begin
                isqrt_x = a + isqrt_y;
            end
        endcase
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            res_vld <= '0;
        end else begin
            res_vld <= ((state == st_a) & isqrt_y_vld);
        end
    end

    always_ff @(posedge clk) begin
        if (state == st_ord) begin
            res <= '0;
        end else if (isqrt_y_vld) begin
            res <= isqrt_y;
        end
    end

endmodule
