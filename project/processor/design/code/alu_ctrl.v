// Created by Karim in 2022

module alu_ctrl
	(
			input      [2:0] funct3,
			input            funct7_bit6,
			input      [4:0] opcode_upper,
			output reg [3:0] op_sel
	);

	always @ (*) begin
		if ( opcode_upper == 5'b01101 ) // LUI
			op_sel = 4'b1111;
		else if ( opcode_upper == 5'b00100 ) // Immediate case
			op_sel = ( funct3 == 3'b101 ) ? {funct7_bit6, funct3[2:0]} : {1'b0, funct3[2:0]};
		else if ( opcode_upper == 5'b01100 ) // Arithmetic Case
			op_sel = { funct7_bit6, funct3[2:0] };
		else // All others
			op_sel = 4'b0000;
	end

endmodule
