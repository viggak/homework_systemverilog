//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module parallel_to_serial
# (
    parameter width = 8
)
(
    input                      clk,
    input                      rst,

    input                      parallel_valid,
    input        [width - 1:0] parallel_data,

    output                     busy,
    output logic               serial_valid,
    output logic               serial_data
);
    // Task:
    // Implement a module that converts multi-bit parallel value to the single-bit serial data.
    //
    // The module should accept 'width' bit input parallel data when 'parallel_valid' input is asserted.
    // At the same clock cycle as 'parallel_valid' is asserted, the module should output
    // the least significant bit of the input data. In the following clock cycles the module
    // should output all the remaining bits of the parallel_data.
    // Together with providing correct 'serial_data' value, module should also assert the 'serial_valid' output.
    //
    // Note:
    // Check the waveform diagram in the README for better understanding.

    logic [        width - 1:0] data_temp;
    logic [$clog2(width) - 1:0] count;

    always_ff @(posedge clk) begin
        if (rst) begin
            serial_valid <= '0;
            serial_data  <= '0;
            data_temp    <= '0;
            count        <= '0;
        end else begin
            serial_valid <= '0;
            if (parallel_valid && count == '0) begin
                data_temp    <= parallel_data;
                count        <= count - 1;  // count = width - 1
                serial_valid <= '1;
                serial_data  <= parallel_data[0];
            end else if (count != '0) begin
                data_temp    <= data_temp >> 1;
                count        <= count - 1;
                serial_valid <= '1;
                serial_data  <= data_temp[1];
            end
        end
    end

    assign busy = (count != 0);

endmodule
