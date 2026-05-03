//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module gearbox_1_to_2_fc
# (
    parameter width = 8
)
(
    input                   clk,
    input                   rst,
    input                   up_valid,
    output                  up_ready,
    input  [   width - 1:0] up_data,
    output                  down_valid,
    output [ 2*width - 1:0] down_data,
    input                   down_ready
);

    // Task:
    // Implement a module that generates one token from of two tokens.
    // Example:
    // "01", "10" => "0110"
    //
    // The module must use signals valid-ready for transfer tokens.

    logic flag_first;
    logic flag_word;

    logic [  width - 1:0] first_word;
    logic [2*width - 1:0] data;

    wire up_suc   = up_valid && up_ready;
    wire down_suc = down_valid && down_ready;

    always_ff @(posedge clk) begin
        if (rst) begin
            flag_first <= '0;
            flag_word  <= '0;
            first_word <= '0;
            data       <= '0;
        end else begin
            case ({down_suc, up_suc})
                2'b00: begin
                end
                
                2'b10: begin
                    flag_word <= '0;
                end
                
                2'b01: begin
                    if (!flag_first) begin
                        first_word <= up_data;
                        flag_first <= 1'b1;
                    end else begin
                        data       <= {first_word, up_data};
                        flag_first <= 1'b0;
                        flag_word  <= 1'b1;
                    end
                end
                
                2'b11: begin
                    first_word <= up_data;
                    flag_first <= 1'b1;
                    flag_word  <= 1'b0;
                end
            endcase
        end
    end

    assign down_data  = data;
    assign down_valid = flag_word;
    assign up_ready   = ~flag_word | down_ready;

endmodule
