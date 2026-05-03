//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module halve_tokens_with_flow_control
(
    input  clk,
    input  rst,

    input  up_valid,
    output up_ready,
    input  up_token,

    output down_valid,
    input  down_ready,
    output down_data
);

    // Task:
    // Implement a serial module that reduces amount of incoming '1' tokens by half.
    // The module must use the ready-valid protocol.
    //
    //  Expected behavior of the module
    //  1) When the input signals are up_token and up_valid is high, the signal (token) is processed.
    //  2) Every second signal received for processing is sent to the output of the module.
    //  3) When the module cannot process the signal, it sets the up_ready signal to a low level.
    //
    // Example:
    // down_ready     ->   1111_1111_1111_0000
    // up_token       ->   1101_0100_1111_1111
    // up_valid       ->   1111_1111_0101_1111
    // down_valid     ->   1111_1111_1111_1000
    // down_data      ->   0100_0100_0001_0000
    // up_ready       ->   1111_1111_0101_1000

    logic flag;
    logic sec_token, perm_token;
    
    always_ff @(posedge clk) begin
        if (rst) begin
            flag <= '0;
        end else if (perm_token & up_token) begin
            flag <= ~flag;
        end
    end

    assign sec_token  = up_token & flag;
    assign perm_token = up_valid & up_ready;

    assign down_valid = up_valid;
    assign down_data  = up_valid & down_ready & sec_token;
    assign up_ready   = up_valid & (down_ready | ~sec_token);

endmodule
