module sqrt_formula_distributor
# (
    parameter formula       = 1,
              impl          = 1,
              n_pipe_stages = 64
)
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
    // Implement a module that will calculate formula 1 or formula 2
    // based on the parameter values. The module must be pipelined.
    // It should be able to accept new triple of arguments a, b, c arriving
    // at every clock cycle.
    //
    // The idea of the task is to implement hardware task distributor,
    // that will accept triplet of the arguments and assign the task
    // of the calculation formula 1 or formula 2 with these arguments
    // to the free FSM-based internal module.
    //
    // The first step to solve the task is to fill 03_04 and 03_05 files.
    //
    // Note 1:
    // Latency of the module "formula_1_isqrt" should be clarified from the corresponding waveform
    // or simply assumed to be equal 50 clock cycles.
    //
    // Note 2:
    // The task assumes idealized distributor (with 50 internal computational blocks),
    // because in practice engineers rarely use more than 10 modules at ones.
    // Usually people use 3-5 blocks and utilize stall in case of high load.
    //
    // Hint:
    // Instantiate sufficient number of "formula_1_impl_1_top", "formula_1_impl_2_top",
    // or "formula_2_top" modules to achieve desired performance.

    logic [31:0] a_reg [n_pipe_stages];
    logic [31:0] b_reg [n_pipe_stages];
    logic [31:0] c_reg [n_pipe_stages];

    logic [n_pipe_stages - 1:0] arg_vld_module;
    logic [n_pipe_stages - 1:0] shift_reg;

    logic [$clog2(n_pipe_stages) - 1:0] cnt;

    always_ff @(posedge clk) begin
        if (rst) begin
            cnt <= '0;
        end else if (arg_vld) begin
            cnt <= cnt + 1;
        end
    end

    genvar i;

    generate
        for (i = 0; i < n_pipe_stages; i++) begin
            always_ff @(posedge clk) begin
                if (rst) begin
                    arg_vld_module[i] <= '0;
                end else if (cnt == i) begin
                    arg_vld_module[i] <= arg_vld;
                end else begin
                    arg_vld_module[i] <= '0;
                end

                if (arg_vld & (cnt == i)) begin
                    a_reg[i] <= a;
                    b_reg[i] <= b;
                    c_reg[i] <= c;
                end
            end
        end
    endgenerate

    logic                [31:0] res_reg [n_pipe_stages];
    logic                [31:0] res_out;
    logic [n_pipe_stages - 1:0] res_vld_module;

    always_comb begin
        for (int j = 0; j < n_pipe_stages; j++) begin
            if (res_vld_module == (1 << j)) begin
                res_out = res_reg[j];
            end
        end
    end

    assign res_vld = |res_vld_module;
    assign res     = res_out;

    generate
        for (i = 0; i < n_pipe_stages; i++) begin
            if (formula == 1 & impl == 1) begin
                formula_1_impl_1_top f_1_i_1 (
                    .clk    (clk              ),
                    .rst    (rst              ),
                    .arg_vld(arg_vld_module[i]),
                    .a      (a_reg[i]         ),
                    .b      (b_reg[i]         ),
                    .c      (c_reg[i]         ),
                    .res_vld(res_vld_module[i]),
                    .res    (res_reg[i]       )
                );
            end else if (formula == 1 & impl == 2) begin
                formula_1_impl_2_top f_1_i_2 (
                    .clk    (clk              ),
                    .rst    (rst              ),
                    .arg_vld(arg_vld_module[i]),
                    .a      (a_reg[i]         ),
                    .b      (b_reg[i]         ),
                    .c      (c_reg[i]         ),
                    .res_vld(res_vld_module[i]),
                    .res    (res_reg[i]       )
                );
            end else if (formula == 2) begin
                formula_2_top f_2 (
                    .clk    (clk              ),
                    .rst    (rst              ),
                    .arg_vld(arg_vld_module[i]),
                    .a      (a_reg[i]         ),
                    .b      (b_reg[i]         ),
                    .c      (c_reg[i]         ),
                    .res_vld(res_vld_module[i]),
                    .res    (res_reg[i]       )
                );
            end
        end
    endgenerate

endmodule
