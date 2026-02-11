//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module halve_tokens
(
    input  clk,
    input  rst,
    input  a,
    output b
);

    logic flag;

    always_ff @(posedge clk) begin
        if (rst) begin
            flag <= '0;
        end else begin
            if (a) begin
                flag <= ~flag;
            end
        end
    end

    assign b = (~flag) & (a == 1'b1);

endmodule
