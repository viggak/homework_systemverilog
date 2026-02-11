//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module round_robin_arbiter_with_2_requests
(
    input        clk,
    input        rst,
    input  [1:0] requests,
    output [1:0] grants
);
    logic last_grant;

    always_ff @(posedge clk) begin
        if (rst) begin
            last_grant <= 1'b0;
        end else begin
            last_grant <= grants[1];
        end
    end

    assign grants[0] = requests[0] & (~requests[1] |  last_grant);
    assign grants[1] = requests[1] & (~requests[0] | ~last_grant);


endmodule
