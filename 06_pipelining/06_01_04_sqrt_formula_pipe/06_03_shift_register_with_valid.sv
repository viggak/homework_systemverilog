//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module one_bit_wide_shift_register_with_reset
# (
    parameter depth = 8
)
(
    input  clk,
    input  rst,
    input  in_data,
    output out_data
);
    logic [depth - 1:0] data;

    always_ff @ (posedge clk)
        if (rst)
            data <= '0;
        else
            data <= { data [depth - 2:0], in_data };

    assign out_data = data [depth - 1];

endmodule

//----------------------------------------------------------------------------

module shift_register
# (
    parameter width = 8, depth = 8
)
(
    input                clk,
    input  [width - 1:0] in_data,
    output [width - 1:0] out_data
);
    logic [width - 1:0] data [0:depth - 1];

    always_ff @ (posedge clk)
    begin
        data [0] <= in_data;

        for (int i = 1; i < depth; i ++)
            data [i] <= data [i - 1];
    end

    assign out_data = data [depth - 1];

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module shift_register_with_valid
# (
    parameter width = 8, depth = 8
)
(
    input                clk,
    input                rst,

    input                in_vld,
    input  [width - 1:0] in_data,

    output               out_vld,
    output [width - 1:0] out_data
);

    // Task:
    //
    // Implement a variant of a shift register module
    // that moves a transfer of data only if this transfer is valid.
    //
    // For the discussion of shift registers
    // see the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.ru/fsm#state_0

    logic [width - 1:0] shift_data [0:depth - 1];
    logic [depth - 1:0] shift_vld;

    always_ff @(posedge clk) begin
        if (rst) begin
            shift_vld <= '0;
        end else begin
            shift_vld <= {shift_vld[depth - 2:0], in_vld};
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            shift_data[0] <= '0;
        end else if (in_vld) begin
            shift_data[0] <= in_data;
        end

        for (int i = 1; i < depth; i++) begin
            if (shift_vld[i - 1]) begin
                shift_data[i] <= shift_data[i - 1];
            end
        end
    end

    assign out_data = shift_data[depth - 1];
    assign out_vld  = shift_vld [depth - 1];

endmodule
