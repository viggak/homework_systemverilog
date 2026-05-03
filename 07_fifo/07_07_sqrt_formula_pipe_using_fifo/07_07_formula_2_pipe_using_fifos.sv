//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_2_pipe_using_fifos
(
    input         clk,
    input         rst,

    input         arg_vld,
    input  [31:0] a,
    input  [31:0] b,
    input  [31:0] c,

    output        res_vld,
    output [31:0] res
);
    // Task:
    //
    // Implement a pipelined module formula_2_pipe_using_fifos that computes the result
    // of the formula defined in the file formula_2_fn.svh.
    //
    // The requirements:
    //
    // 1. The module formula_2_pipe has to be pipelined.
    //
    // It should be able to accept a new set of arguments a, b and c
    // arriving at every clock cycle.
    //
    // It also should be able to produce a new result every clock cycle
    // with a fixed latency after accepting the arguments.
    //
    // 2. Your solution should instantiate exactly 3 instances
    // of a pipelined isqrt module, which computes the integer square root.
    //
    // 3. Your solution should use FIFOs instead of shift registers
    // which were used in 06_04_formula_2_pipe.sv.
    //
    // You can read the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.ru/fsm

    localparam width   = 32;
    localparam depth   = 8;
    localparam depth_a = 2 * depth + 1;

    logic        c_vld, bc_vld, abc_vld;
    logic [15:0] c_res, bc_res, abc_res;

    logic        b_delay_vld, a_delay_vld;
    logic [31:0] b_delay, a_delay;

    logic        c_plus_b_vld, bc_plus_a_vld;
    logic [31:0] c_plus_b_res, bc_plus_a_res;

    logic push_a, push_b;
    logic pop_a, pop_b;

    logic [31:0] read_data_a, read_data_b;

    logic empty_a, empty_b;
    logic full_a, full_b;

    isqrt #(.n_pipe_stages(depth)) inst_c (
        .clk  (clk    ),
        .rst  (rst    ),
        .x_vld(arg_vld),
        .x    (c      ),
        .y_vld(c_vld  ),
        .y    (c_res  )
    );

    isqrt #(.n_pipe_stages(depth)) inst_bc (
        .clk  (clk         ),
        .rst  (rst         ),
        .x_vld(c_plus_b_vld),
        .x    (c_plus_b_res),
        .y_vld(bc_vld      ),
        .y    (bc_res      )
    );

    isqrt #(.n_pipe_stages(depth)) inst_abc (
        .clk  (clk          ),
        .rst  (rst          ),
        .x_vld(bc_plus_a_vld),
        .x    (bc_plus_a_res),
        .y_vld(abc_vld      ),
        .y    (abc_res      )
    );

    assign pop_b = c_vld & ~empty_b;
    assign push_b = arg_vld & (~full_b | pop_b);

    flip_flop_fifo_with_counter #(.width(width), .depth(depth)) inst_fifo_b (
        .clk       (clk        ),
        .rst       (rst        ),
        .push      (push_b     ),
        .pop       (pop_b      ),
        .write_data(b          ),
        .read_data (read_data_b),
        .empty     (empty_b    ),
        .full      (full_b     )
    );

    assign pop_a = bc_vld & ~empty_a;
    assign push_a = arg_vld & (~full_a | pop_a);

    flip_flop_fifo_with_counter #(.width(width), .depth(depth_a)) inst_fifo_a (
        .clk       (clk        ),
        .rst       (rst        ),
        .push      (push_a     ),
        .pop       (pop_a      ),
        .write_data(a          ),
        .read_data (read_data_a),
        .empty     (empty_a    ),
        .full      (full_a     )
    );

    always_ff @(posedge clk) begin
        if (rst) begin
            c_plus_b_vld <= '0;
        end else begin
            c_plus_b_vld <= pop_b;
            if (pop_b) begin
                c_plus_b_res <= read_data_b + 32'(c_res);
            end
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            bc_plus_a_vld <= '0;
        end else begin
            bc_plus_a_vld <= pop_a;
            if (pop_a) begin
                bc_plus_a_res <= read_data_a + 32'(bc_res);
            end
        end
    end

    assign res_vld = abc_vld;
    assign res     = 32'(abc_res);

endmodule
