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
    // Task:
    // Implement a serial module that doubles each incoming token '1' two times.
    // The module should handle doubling for at least 200 tokens '1' arriving in a row.
    //
    // In case module detects more than 200 sequential tokens '1', it should assert
    // an overflow error. The overflow error should be sticky. Once the error is on,
    // the only way to clear it is by using the "rst" reset signal.
    //
    // Note:
    // Check the waveform diagram in the README for better understanding.
    //
    // Example:
    // a -> 10010011000110100001100100
    // b -> 11011011110111111001111110

    logic [7:0] counter, next_counter;
    logic [7:0] post_counter, post_next_counter;
    logic       flag_overflow;

    always_ff @(posedge clk) begin
        if (rst) begin
            counter       <= 8'd0;
            next_counter  <= 8'd0;
            flag_overflow <= 1'b0;
        end else begin
            counter      <= next_counter;
            post_counter <= post_next_counter;
            if (post_counter == 8'd200) begin
                flag_overflow <= 1'b1;
            end
        end
    end

    always_comb begin
        next_counter      = counter;
        post_next_counter = post_counter;

        if (a == 1'b1) begin
            next_counter      = next_counter + 8'd2;
            post_next_counter = post_next_counter + 8'd1;
        end else begin
            post_next_counter = 8'd0;
        end

        if (next_counter > 8'd0) begin
            b            = 1'b1;
            next_counter = next_counter - 1'b1;
        end else begin
            b            = 1'b0;
        end
    end

    assign overflow = flag_overflow;

endmodule
