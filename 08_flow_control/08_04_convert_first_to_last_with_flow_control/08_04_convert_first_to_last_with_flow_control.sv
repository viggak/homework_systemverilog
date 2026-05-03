//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module convert_first_to_last_with_flow_control
# (
    parameter width = 8
)
(
    input                clock,
    input                reset,

    input                up_valid,
    output               up_ready,
    input                up_first,
    input  [width - 1:0] up_data,

    output               down_valid,
    input                down_ready,
    output               down_last,
    output [width - 1:0] down_data
);

    // Task:
    // Implement a module that converts 'first' input status signal
    // to the 'last' output status signal.
    //
    // The module should respect and set correct valid and ready signals
    // to control flow from the upstream and to the downstream.

    logic [width - 1:0] data;
    logic               flag_buf;

    always_ff @(posedge clock) begin
        if (reset) begin
            data     <= '0;
            flag_buf <= '0;
        end else begin
            if (up_valid && up_ready) begin
                data <= up_data;
                flag_buf <= 1'b1;
            end else if (down_valid && down_ready) begin
                flag_buf <= 1'b0;
            end
        end
    end

    assign up_ready   = (down_ready & down_valid) | !flag_buf;
    assign down_valid = up_valid & flag_buf;
    assign down_last  = up_first;
    assign down_data  = data;

endmodule
