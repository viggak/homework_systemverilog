//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_2_pipe
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
    // Implement a pipelined module formula_2_pipe that computes the result
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
    // 3. Your solution should save dynamic power by properly connecting
    // the valid bits.
    //
    // You can read the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.ru/fsm#state_0

    logic [15:0] c_sqrt_res, bc_sqrt_res, abc_sqrt_res;
    logic [31:0] bc_res, abc_res;
    logic        c_sqrt_vld, bc_sqrt_vld, abc_sqrt_vld;
    logic        c_vld, bc_vld;

    isqrt c_isqrt (
        .clk  (clk       ),
        .rst  (rst       ),
        .x_vld(arg_vld   ),
        .x    (c         ),
        .y_vld(c_sqrt_vld),
        .y    (c_sqrt_res)
    );

    isqrt bc_isqrt (
        .clk  (clk        ),
        .rst  (rst        ),
        .x_vld(c_vld      ),
        .x    (bc_res     ),
        .y_vld(bc_sqrt_vld),
        .y    (bc_sqrt_res)
    );

    isqrt abc_isqrt (
        .clk  (clk         ),
        .rst  (rst         ),
        .x_vld(bc_vld      ),
        .x    (abc_res     ),
        .y_vld(abc_sqrt_vld),
        .y    (abc_sqrt_res)
    );

    logic [31:0] a_reg, b_reg;
    logic [31:0] sum_bc, sum_abc;

    shift_register_with_valid #(32, 16) shift_register_b (
        .clk      (clk    ),
        .rst      (rst    ),
        .in_vld   (arg_vld),
        .in_data  (b      ),
        .out_vld  (       ),
        .out_data (b_reg  )
    );

    shift_register_with_valid #(32, 33) shift_register_a (
        .clk      (clk    ),
        .rst      (rst    ),
        .in_vld   (arg_vld),
        .in_data  (a      ),
        .out_vld  (       ),
        .out_data (a_reg  )
    );

    assign sum_bc  = b_reg + c_sqrt_res;
    assign sum_abc = a_reg + bc_sqrt_res;

    always_ff @(posedge clk) begin
        if (rst) begin
            c_vld  <= '0;
            bc_vld <= '0;
        end else begin
            c_vld  <= c_sqrt_vld;
            bc_vld <= bc_sqrt_vld;
        end
    end

    always_ff @(posedge clk) begin
        if (c_sqrt_vld) begin
            bc_res  <= sum_bc;
        end
        if (bc_sqrt_vld) begin
            abc_res <= sum_abc;
        end
    end

    assign res_vld = abc_sqrt_vld;
    assign res     = abc_sqrt_res;

endmodule
