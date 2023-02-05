// Created by Karim in 2022

module alu
    #(
        parameter   ADD            = 4'b0000,
        parameter   SUB            = 4'b1000,
        parameter   SLL            = 4'b0001,
        parameter   SLT            = 4'b0010,
        parameter   SLTU           = 4'b0011,
        parameter   XOR            = 4'b0100,
        parameter   SRL            = 4'b0101,
        parameter   SRA            = 4'b1101,
        parameter   AND            = 4'b0111,
        parameter   OR             = 4'b0110
    )
    (
        input  [31:0]    operand1, operand2,
        input  [3:0]     alu_sel,
        output reg [31:0]    alu_out
    );

    always @ (*) begin
        
        case ( alu_sel )
            ADD:
                alu_out = operand1 + operand2;
            SUB:
                alu_out = operand1 - operand2;
            SLL:
                alu_out = operand1 << operand2[4:0];
            SLT:
                alu_out = ($signed(operand1) < $signed(operand2)) ? 32'd1 : 32'd0;
            SLTU:
                alu_out = (operand1 < operand2) ? 32'd1 : 32'd0;
            XOR:
                alu_out = operand1 ^ operand2;
            SRL:
                alu_out = operand1 >> operand2[4:0];
            SRA:
                alu_out = $signed(operand1) >>> operand2[4:0]; //https://nandland.com/shift-operator/
            AND:
                alu_out = operand1 & operand2;
            OR:
                alu_out = operand1 | operand2;

            default:
                alu_out = operand2; //short for lui

        endcase

    end

endmodule