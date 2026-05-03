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
    // Task:
    // Implement a module that converts single-bit serial data to the multi-bit parallel value.
    //
    // The module should accept one-bit values with valid interface in a serial manner.
    // After accumulating 'width' bits and receiving last 'serial_valid' input,
    // the module should assert the 'parallel_valid' at the same clock cycle
    // and output 'parallel_data' value.
    //
    // Note:
    // Check the waveform diagram in the README for better understanding.

    logic [        width - 1:0] data_temp;
    logic [$clog2(width) - 1:0] count;

    always_ff @(posedge clk) begin
        if (rst) begin
            data_temp      <= '0;
            count          <= '0;
            parallel_valid <= '0;
        end else if (serial_valid) begin
            data_temp <= { serial_data, data_temp[width-1 : 1] };
            if (count == width - 1) begin
                count          <= '0;
                parallel_valid <= 1'b1;
            end else begin
                count          <= count + 1;
                parallel_valid <= '0;
            end
        end else begin
            parallel_valid <= '0;
        end
    end

    assign parallel_data = data_temp;

endmodule
