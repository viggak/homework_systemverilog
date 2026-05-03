//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module gearbox_1_to_2
# (
    parameter width = 0
)
(
    input                    clk,
    input                    rst,

    input                    up_vld,    // upstream
    input  [    width - 1:0] up_data,

    output                   down_vld,  // downstream
    output [2 * width - 1:0] down_data
);
    // Task:
    // Implement a module that transforms a stream of data
    // from 'width' to the 2*'width' data width.
    //
    // The module should be capable to accept new data at each
    // clock cycle and produce concatenated 'down_data'
    // at each second clock cycle.
    //
    // The module should work properly with reset 'rst'
    // and valid 'vld' signals

    logic [width - 1:0] buffer;
    logic               flag;

    always_ff @(posedge clk) begin
        if (rst) begin
            buffer <= '0;
            flag   <= '0;
        end else if (up_vld) begin
            if (flag == 1'b0) begin
                buffer <= up_data;
                flag   <= 1'b1;
            end else begin
                flag   <= 1'b0;
            end
        end
    end

    assign down_vld  = (flag & up_vld);
    assign down_data = { buffer, up_data };

endmodule
