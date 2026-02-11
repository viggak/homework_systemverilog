//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module sort_two_floats_ab (
    input        [FLEN - 1:0] a,
    input        [FLEN - 1:0] b,

    output logic [FLEN - 1:0] res0,
    output logic [FLEN - 1:0] res1,
    output                    err
);

    logic a_less_or_equal_b;

    f_less_or_equal i_floe (
        .a   ( a                 ),
        .b   ( b                 ),
        .res ( a_less_or_equal_b ),
        .err ( err               )
    );

    always_comb begin : a_b_compare
        if ( a_less_or_equal_b ) begin
            res0 = a;
            res1 = b;
        end
        else
        begin
            res0 = b;
            res1 = a;
        end
    end

endmodule

//----------------------------------------------------------------------------
// Example - different style
//----------------------------------------------------------------------------

module sort_two_floats_array
(
    input        [0:1][FLEN - 1:0] unsorted,
    output logic [0:1][FLEN - 1:0] sorted,
    output                         err
);

    logic u0_less_or_equal_u1;

    f_less_or_equal i_floe
    (
        .a   ( unsorted [0]        ),
        .b   ( unsorted [1]        ),
        .res ( u0_less_or_equal_u1 ),
        .err ( err                 )
    );

    always_comb
        if (u0_less_or_equal_u1)
            sorted = unsorted;
        else
              {   sorted [0],   sorted [1] }
            = { unsorted [1], unsorted [0] };

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module sort_three_floats (
    input        [0:2][FLEN - 1:0] unsorted,
    output logic [0:2][FLEN - 1:0] sorted,
    output                         err
);

    logic u0_less_or_equal_u1, u1_less_or_equal_u2, u0_less_or_equal_u2;
    logic err_01, err_12, err_02;

    f_less_or_equal u0_u1 (
        .a  (unsorted[0]        ),
        .b  (unsorted[1]        ),
        .res(u0_less_or_equal_u1),
        .err(err_01             )
    );

    f_less_or_equal u1_u2 (
        .a  (unsorted[1]        ),
        .b  (unsorted[2]        ),
        .res(u1_less_or_equal_u2),
        .err(err_12             )
    );

    f_less_or_equal u0_u2 (
        .a  (unsorted[0]        ),
        .b  (unsorted[2]        ),
        .res(u0_less_or_equal_u2),
        .err(err_02             )
    );

    assign err = err_01 | err_12 | err_02;

    always_comb begin
        if (u0_less_or_equal_u1 && u0_less_or_equal_u2) begin // если [0] самый маленький
            sorted[0] = unsorted[0];
            if (u1_less_or_equal_u2) begin
                sorted[1] = unsorted[1];
                sorted[2] = unsorted[2];
            end else begin
                sorted[1] = unsorted[2];
                sorted[2] = unsorted[1];
            end
        end else if (!u0_less_or_equal_u1 && u1_less_or_equal_u2) begin // если [1] самый маленький
            sorted[0] = unsorted[1];
            if (u0_less_or_equal_u2) begin
                sorted[1] = unsorted[0];
                sorted[2] = unsorted[2];
            end else begin
                sorted[1] = unsorted[2];
                sorted[2] = unsorted[0];
            end 
        end else begin // если [2] самый маленький
            sorted[0] = unsorted[2];
            if (u0_less_or_equal_u1) begin
                sorted[1] = unsorted[0];
                sorted[2] = unsorted[1];
            end else begin
                sorted[1] = unsorted[1];
                sorted[2] = unsorted[0];
            end
        end
    end

endmodule
