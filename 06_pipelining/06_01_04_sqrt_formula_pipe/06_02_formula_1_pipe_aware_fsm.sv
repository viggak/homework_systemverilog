//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_1_pipe_aware_fsm
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
    //
    // Implement a module formula_1_pipe_aware_fsm
    // with a Finite State Machine (FSM)
    // that drives the inputs and consumes the outputs
    // of a single pipelined module isqrt.
    //
    // The formula_1_pipe_aware_fsm module is supposed to be instantiated
    // inside the module formula_1_pipe_aware_fsm_top,
    // together with a single instance of isqrt.
    //
    // The resulting structure has to compute the formula
    // defined in the file formula_1_fn.svh.
    //
    // The formula_1_pipe_aware_fsm module
    // should NOT create any instances of isqrt module,
    // it should only use the input and output ports connecting
    // to the instance of isqrt at higher level of the instance hierarchy.
    //
    // All the datapath computations except the square root calculation,
    // should be implemented inside formula_1_pipe_aware_fsm module.
    // So this module is not a state machine only, it is a combination
    // of an FSM with a datapath for additions and the intermediate data
    // registers.
    //
    // Note that the module formula_1_pipe_aware_fsm is NOT pipelined itself.
    // It should be able to accept new arguments a, b and c
    // arriving at every N+3 clock cycles.
    //
    // In order to achieve this latency the FSM is supposed to use the fact
    // that isqrt is a pipelined module.
    //
    // For more details, see the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.ru/fsm#state_0

    enum logic [2:0] {
        st_idle    = 3'b000,
        st_a_start = 3'b001,
        st_a_wait  = 3'b010,
        st_b_start = 3'b011,
        st_b_wait  = 3'b100,
        st_c_start = 3'b101,
        st_c_wait  = 3'b110,
        st_res     = 3'b111
    }
    state, new_state;

    always_comb begin
        new_state = state;

        case (state)
            st_idle    : if (arg_vld) begin
                new_state = st_a_start;
            end
            st_a_start : begin
                new_state = st_a_wait;
            end
            st_a_wait  : if (isqrt_y_vld) begin
                new_state = st_b_start;
            end else begin
                new_state = st_a_wait;
            end
            st_b_start : begin
                new_state = st_b_wait;
            end
            st_b_wait  : if (isqrt_y_vld) begin
                new_state = st_c_start;
            end else begin
                new_state = st_b_wait;
            end
            st_c_start : begin
                new_state = st_c_wait;
            end
            st_c_wait  : if (isqrt_y_vld) begin
                new_state = st_res;
            end else begin 
                new_state = st_c_wait;
            end
            st_res     : begin
                new_state = st_idle;
            end
        endcase
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            state <= st_idle;
        end else begin
            state <= new_state;
        end
    end

    always_comb begin
        case (state)
            st_a_start : isqrt_x_vld = 1'b1;
            st_a_wait  : isqrt_x_vld = 1'b0;
            st_b_start : isqrt_x_vld = 1'b1;
            st_b_wait  : isqrt_x_vld = 1'b0;
            st_c_start : isqrt_x_vld = 1'b1;
            st_c_wait  : isqrt_x_vld = 1'b0;
            st_res     : isqrt_x_vld = 1'b0 ;
        endcase
    end

    always_comb begin
        case (state)
            st_a_start : isqrt_x = a;
            st_b_start : isqrt_x = b;
            st_c_start : isqrt_x = c;
            default    : isqrt_x = 'x;
        endcase
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            res_vld <= '0;
        end else begin
            res_vld <= (state == st_res);
        end
    end

    always_ff @(posedge clk) begin
        if (state == st_idle) begin
            res <= '0;
        end else if (isqrt_y_vld) begin
            res <= res + {16'b0, isqrt_y};
        end
    end

endmodule
