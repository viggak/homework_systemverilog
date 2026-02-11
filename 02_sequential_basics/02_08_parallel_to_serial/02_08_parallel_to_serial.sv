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
    logic [$clog2(width) - 1 : 0] count;
    logic [width - 1 : 0]         data_temp;

    always_ff @(posedge clk) begin
        if (rst) begin
            count        <= '0;
            data_temp    <= '0;
            serial_data  <= '0;
            serial_valid <= '0;
        end else  begin
            serial_valid <= '0;
            if (parallel_valid && count == '0) begin
                data_temp <= parallel_data;
                count <= count - 1;
                serial_valid <= '1;
                serial_data <= parallel_data[0];
            end else if (count != '0) begin
                data_temp <= data_temp >> 1;
                count <= count - 1;
                serial_valid <= '1;
                serial_data <= data_temp[1];
            end
        end
    end

    assign busy = (count != 0);


endmodule
