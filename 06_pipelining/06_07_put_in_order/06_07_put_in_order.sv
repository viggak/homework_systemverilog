module put_in_order
# (
    parameter width    = 16,
              n_inputs = 4
)
(
    input                       clk,
    input                       rst,

    input  [ n_inputs - 1 : 0 ] up_vlds,
    input  [ n_inputs - 1 : 0 ]
           [ width    - 1 : 0 ] up_data,

    output                      down_vld,
    output [ width   - 1 : 0 ]  down_data
);

    // Task:
    //
    // Implement a module that accepts many outputs of the computational blocks
    // and outputs them one by one in order. Input signals "up_vlds" and "up_data"
    // are coming from an array of non-pipelined computational blocks.
    // These external computational blocks have a variable latency.
    //
    // The order of incoming "up_vlds" is not determent, and the task is to
    // output "down_vld" and corresponding data in a round-robin manner,
    // one after another, in order.
    //
    // Comment:
    // The idea of the block is kinda similar to the "parallel_to_serial" block
    // from Homework 2, but here block should also preserve the output order.

    logic [$clog2(n_inputs) - 1:0] data;
    logic [$clog2(n_inputs) - 1:0] data_next;
    
    logic [n_inputs - 1:0] flag;
    logic [n_inputs - 1:0] flag_next;
    
    logic [n_inputs - 1:0][width - 1:0] data_reg;
    logic [n_inputs - 1:0][width - 1:0] data_reg_next;
    
    logic               down_vld_reg;
    logic [width - 1:0] down_data_reg;
    
    integer i;
    
    always_comb begin
        flag_next     = flag;
        data_reg_next = data_reg;
        data_next     = data;
        down_vld_reg  = '0;
        down_data_reg = '0;
        
        for (i = 0; i < n_inputs; i++) begin
            if (up_vlds[i]) begin
                flag_next[i]     = 1'b1;
                data_reg_next[i] = up_data[i];
            end
        end

        if (flag_next[data]) begin
            down_vld_reg        = 1'b1;
            down_data_reg       = data_reg_next[data];
            flag_next[data] = 1'b0;
            data_next           = (data == n_inputs-1) ? '0 : data + 1'b1;
        end
    end
    
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            data <= '0;
            flag <= '0;
            for (i = 0; i < n_inputs; i++) begin
                data_reg[i] <= '0;
            end
        end else begin
            data     <= data_next;
            flag     <= flag_next;
            data_reg <= data_reg_next;
        end
    end
    
    assign down_vld  = down_vld_reg;
    assign down_data = down_data_reg;

endmodule
