//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module float_discriminant (
    input                     clk,
    input                     rst,

    input                     arg_vld,
    input        [FLEN - 1:0] a,
    input        [FLEN - 1:0] b,
    input        [FLEN - 1:0] c,

    output logic              res_vld,
    output logic [FLEN - 1:0] res,
    output logic              res_negative,
    output logic              err,

    output logic              busy
);

    localparam [FLEN - 1:0] four      = 64'h4010_0000_0000_0000;

    enum logic [2 : 0] {
        state_ord  = 3'b000,
        state_sq_b = 3'b001,
        state_a_c  = 3'b010,
        state_4ac  = 3'b011,
        state_sub  = 3'b100,
        state_fin  = 3'b110
    }
    state, new_state;

    logic [FLEN - 1:0] a_reg, c_reg;

    logic [FLEN - 1:0] square_b;
    logic [FLEN - 1:0] mult_ac;
    logic [FLEN - 1:0] mult_4ac;

    logic [FLEN - 1:0] a_mult, b_mult;
    logic              mult_up_valid;
    logic [FLEN - 1:0] res_mult;
    logic              mult_down_valid;
    logic              mult_busy;
    logic              mult_error;

    logic [FLEN - 1:0] a_sub, b_sub;
    logic              sub_up_valid;
    logic [FLEN - 1:0] res_sub;
    logic              sub_down_valid;
    logic              sub_busy;
    logic              sub_error;

    f_mult i_f_mult (
        .clk        (clk), 
        .rst        (rst), 
        .a          (a_mult),
        .b          (b_mult),
        .up_valid   (mult_up_valid),
        .res        (res_mult),
        .down_valid (mult_down_valid),
        .busy       (mult_busy),
        .error      (mult_error)
    );

    f_sub i_f_sub (
        .clk        (clk), 
        .rst        (rst), 
        .a          (a_sub),
        .b          (b_sub),
        .up_valid   (sub_up_valid),
        .res        (res_sub),
        .down_valid (sub_down_valid),
        .busy       (sub_busy),
        .error      (sub_error)
    );

    always_ff @(posedge clk) begin
        if (rst) begin
            a_reg <= '0;
            c_reg <= '0;
        end else if (arg_vld) begin
            a_reg <= a;
            c_reg <= c;
        end
    end

    always_comb begin
        new_state = state;

        case (state)
            state_ord:  if (arg_vld)         new_state = state_sq_b;
            state_sq_b: if (mult_down_valid) new_state = state_a_c;
            state_a_c:  if (mult_down_valid) new_state = state_4ac;
            state_4ac:  if (mult_down_valid) new_state = state_sub;
            state_sub:  if (sub_down_valid)  new_state = state_fin;
            state_fin:                       new_state = state_ord;
        endcase
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            state <= state_ord;
        end else begin
            state <= new_state;
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            square_b <= '0;
            mult_ac  <= '0;
            mult_4ac <= '0;
        end else begin
            case (state)
                state_sq_b: if (mult_down_valid)
                    square_b <= res_mult;
                state_a_c:  if (mult_down_valid)
                    mult_ac  <= res_mult;
                state_4ac:  if (mult_down_valid)
                    mult_4ac <= res_mult;
                default: begin
                    square_b   <= square_b;
                    mult_ac    <= mult_ac;
                    mult_4ac   <= mult_4ac;
                end
            endcase
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            a_mult        <= '0;
            b_mult        <= '0;
            mult_up_valid <= '0;
        end else begin
            case (state)
                state_ord: if (arg_vld) begin
                    a_mult        <= b;
                    b_mult        <= b;
                    mult_up_valid <= 1'b1;
                end
                state_sq_b: if (mult_down_valid) begin
                    a_mult        <= a_reg;
                    b_mult        <= c_reg;
                    mult_up_valid <= 1'b1;
                end else begin
                    mult_up_valid <= 1'b0;
                end
                state_a_c: if (mult_down_valid) begin
                    a_mult <= four;
                    b_mult <= res_mult;
                    mult_up_valid <= 1'b1;
                end else begin
                    mult_up_valid <= 1'b0;
                end
                state_4ac: begin
                    mult_up_valid <= 1'b0;
                end
                default: begin
                    a_mult        <= a_mult;
                    b_mult        <= b_mult;
                    mult_up_valid <= mult_up_valid;
                end
            endcase
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            a_sub        <= '0;
            b_sub        <= '0;
            sub_up_valid <= '0;
        end else begin
            case (state)
                state_4ac: if (mult_down_valid) begin
                    a_sub        <= square_b;
                    b_sub        <= res_mult;
                    sub_up_valid <= 1'b1;
                end
                state_sub: begin
                    sub_up_valid <= 1'b0;
                end
            endcase
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            err <= '0;
        end else begin
            case (state)
                state_ord: begin
                    err <= '0;
                end
                state_sq_b: if (mult_down_valid) begin
                    err <= err || mult_error;
                end
                state_a_c: if (mult_down_valid) begin
                    err <= err || mult_error;
                end
                state_4ac: if (mult_down_valid) begin
                    err <= err || mult_error;
                end
                state_sub: if (sub_down_valid) begin
                    err <= err || sub_error;
                end
                default: begin
                    err <= err;
                end
            endcase
        end
    end

    assign res_vld      = (state == state_fin);
    assign res          = res_sub;
    assign res_negative = res[FLEN - 1];
    assign busy         = (state != state_ord) && (state != state_fin);

endmodule
