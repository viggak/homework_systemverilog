//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module serial_to_parallel
# (
    parameter width = 8
)
(
    input                      clk,
    input                      rst,

    input                      serial_valid,
    input                      serial_data,

    output logic               parallel_valid,
    output logic [width - 1:0] parallel_data
);
    logic [width - 1 : 0]         data_temp;
    logic [$clog2(width) - 1 : 0] count;

    always_ff @(posedge clk) begin
        if (rst) begin
            data_temp <= '0;
            count <= '0;
            parallel_valid <= 1'b0;
        end else if (serial_valid) begin
            data_temp <= { serial_data, data_temp[width - 1 : 1] };
            if (count == width - 1) begin
                count <= '0;
                parallel_valid <= 1'b1;
            end else begin
                count <= count + 1;
                parallel_valid <= '0;
            end
        end else begin
            parallel_valid <= '0;
        end
    end

    assign parallel_data = data_temp;

endmodule
