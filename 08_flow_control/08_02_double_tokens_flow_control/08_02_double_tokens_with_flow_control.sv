//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module double_tokens_with_flow_control
(
    input  clk,
    input  rst,

    input  up_valid,
    output up_ready,
    input  up_token,

    output down_valid,
    input  down_ready,
    output down_data
);

  // Task:
  // Implement module double input signals (tokens). The module must use signals valid-ready for
  // transfer tokens. If the module receives more than 100 sequential tokens then it must set up_ready = 0;

    logic [7:0] count;

    logic up_suc, down_suc;
    logic push;

    assign up_suc   = up_valid && up_ready;
    assign push     = up_suc && up_token;
    assign down_suc = down_valid && down_ready && down_data;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            count <= 8'd0;
        end else begin
            case ({push, down_suc})
                2'b10: count <= count + 8'd2;
                2'b11: count <= count + 8'd1;
                2'b01: count <= count - 8'd1;
                2'b00: count <= count;
            endcase
        end
    end

    assign down_valid = 1'b1;
    assign down_data  = (count > 8'd0) || (up_valid && up_token);
    assign up_ready   = (count < 8'd200);

endmodule
