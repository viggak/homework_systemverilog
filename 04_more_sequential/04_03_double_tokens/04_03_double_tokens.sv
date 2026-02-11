//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module double_tokens
(
    input        clk,
    input        rst,
    input        a,
    output logic b,
    output logic overflow
);

    logic [7 : 0] counter, next_count;
    logic [7 : 0] post_counter, next_post_count;
    logic flag_overflow;

    always_ff @(posedge clk) begin
        if(rst) begin
            counter       <= 8'd0;
            post_counter  <= 8'd0;
            flag_overflow <= 1'b0;
        end else begin
            counter      <= next_count;
            post_counter <= next_post_count;
            if (post_counter == 8'd200) begin
                flag_overflow <= 1'b1;
            end
        end
    end

    always_comb begin
        next_count      = counter;
        next_post_count = post_counter;
        
        if (a == 1'b1) begin
            next_count      = next_count + 8'd2;
            next_post_count = next_post_count + 8'd1;
        end else begin
            next_post_count = 8'd0;
        end

        if (next_count > 8'd0) begin
            b          = 1'b1;
            next_count = next_count - 1'b1;
        end else begin
            b          = 1'b0;
        end
    end

    assign overflow = flag_overflow;

endmodule
