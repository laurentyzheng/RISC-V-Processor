// Created by Karim in 2022

module branch_comp
    (
        input [31:0] data_a,
        input [31:0] data_b,
        input branch_unsigned,
        output branch_equal,
        output branch_less
    );

    assign branch_equal = ( data_a == data_b )? 1 : 0;

    assign branch_less = ( branch_unsigned )? ( data_a < data_b ) : ( $signed(data_a) < $signed(data_b) );

endmodule