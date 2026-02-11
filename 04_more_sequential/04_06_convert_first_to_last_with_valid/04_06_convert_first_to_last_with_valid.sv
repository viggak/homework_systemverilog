//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module conv_first_to_last_no_ready
# (
    parameter width = 8
)
(
    input                clock,
    input                reset,

    input                up_valid,
    input                up_first,
    input  [width - 1:0] up_data,

    output               down_valid,
    output               down_last,
    output [width - 1:0] down_data
);

    logic                 flag;
    logic [width - 1 : 0] buffer;

    assign down_valid = ~reset & up_valid & flag;
    assign down_last = down_valid ? up_first : '0;
    assign down_data  = down_valid ? buffer : '0;
    

    always_ff @(posedge clock) begin
        if (reset) begin
            flag   <= 1'b0;
            buffer <= '0;
        end else if (up_valid) begin
            flag   <= 1'b1;
            buffer <= up_data;
        end
    end

endmodule
