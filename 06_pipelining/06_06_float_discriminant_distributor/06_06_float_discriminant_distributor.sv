module float_discriminant_distributor #(
    parameter FLEN          = 64,
    parameter NE            = 11,
              n_pipe_stages = 64
) (
    input                           clk,
    input                           rst,

    input                           arg_vld,
    input        [FLEN - 1:0]       a,
    input        [FLEN - 1:0]       b,
    input        [FLEN - 1:0]       c,

    output logic                    res_vld,
    output logic [FLEN - 1:0]       res,
    output logic                    res_negative,
    output logic                    err,

    output logic                    busy
);

    // Task:
    //
    // Implement a module that will calculate the discriminant based
    // on the triplet of input number a, b, c. The module must be pipelined.
    // It should be able to accept a new triple of arguments on each clock cycle
    // and also, after some time, provide the result on each clock cycle.
    // The idea of the task is similar to the task 04_11. The main difference is
    // in the underlying module 03_08 instead of formula modules.
    //
    // Note 1:
    // Reuse your file "03_08_float_discriminant.sv" from the Homework 03.
    //
    // Note 2:
    // Latency of the module "float_discriminant" should be clarified from the waveform.

    logic [FLEN - 1:0] a_reg [0:n_pipe_stages - 1];
    logic [FLEN - 1:0] b_reg [0:n_pipe_stages - 1];
    logic [FLEN - 1:0] c_reg [0:n_pipe_stages - 1];
    
    logic [n_pipe_stages-1:0] arg_vld_module;
    
    logic [n_pipe_stages - 1:0] module_res_vld;
    logic [         FLEN - 1:0] module_res [0:n_pipe_stages-1];
    logic [n_pipe_stages - 1:0] module_res_negative;
    logic [n_pipe_stages - 1:0] module_err;
    
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
            always_ff @(posedge clk or posedge rst) begin
                if (rst) begin
                    arg_vld_module[i] <= 1'b0;
                end else if (cnt == i) begin
                    arg_vld_module[i] <= arg_vld;
                end else begin
                    arg_vld_module[i] <= 1'b0;
                end

                if (arg_vld && (cnt == i)) begin
                    a_reg[i] <= a;
                    b_reg[i] <= b;
                    c_reg[i] <= c;
                end
            end
        end
    endgenerate

    generate
        for (i = 0; i < n_pipe_stages; i++) begin
            float_discriminant inst_discriminant (
                .clk         (clk                   ),
                .rst         (rst                   ),
                .arg_vld     (arg_vld_module[i]     ),
                .a           (a_reg[i]              ),
                .b           (b_reg[i]              ),
                .c           (c_reg[i]              ),
                .res_vld     (module_res_vld[i]     ),
                .res         (module_res[i]         ),
                .res_negative(module_res_negative[i]),
                .err         (module_err[i]         ),
                .busy        (                      )
            );
        end
    endgenerate

    always_comb begin
        res_vld      = '0;
        res          = '0;
        res_negative = '0;
        err          = '0;
        
        for (int j = 0; j < n_pipe_stages; j++) begin
            if (module_res_vld[j]) begin
                res_vld      = 1'b1;
                res          = module_res[j];
                res_negative = module_res_negative[j];
                err          = module_err[j];
            end
        end
    end

    always_comb begin
        busy = 1'b0;
        for (int j = 0; j < n_pipe_stages; j++) begin
            if (arg_vld_module[j] || module_res_vld[j]) begin
                busy = 1'b1;
            end
        end
    end

endmodule
