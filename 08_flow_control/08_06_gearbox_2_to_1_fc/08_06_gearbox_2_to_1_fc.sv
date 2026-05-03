//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module gearbox_2_to_1_fc
# (
    parameter width = 8
)
(
    input                    clk,
    input                    rst,

    input                    up_valid,
    output                   up_ready,
    input   [ 2*width - 1:0] up_data,

    output                   down_valid,
    input                    down_ready,
    output  [   width - 1:0] down_data
);

    // Task:
    // Implement a module that generates tokens from of one token.
    // Example:
    // "0110" => "01", "10"
    //
    // The module must use signals valid-ready for transfer tokens.

    logic [2*width - 1 : 0] data;
    logic [            1:0] state;

    always_ff @(posedge clk) begin
        if (rst) begin
            state <= '0;
            data  <= '0;
        end else begin
            if (up_valid && up_ready) begin
                data  <= up_data;
                state <= 2'd1;
            end 
            else if (down_valid && down_ready) begin
                if (state == 2'd1) begin
                    state <= 2'd2;
                end else begin
                    state <= 2'd0;
                end
            end
        end
    end

    assign up_ready   = (state == 2'd0);
    assign down_valid = (state != 2'd0);
    assign down_data  = (state == 2'd1) ? data[2 * width - 1:width] : data[width - 1:0];

endmodule
