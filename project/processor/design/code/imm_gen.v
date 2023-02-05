// Created by Karim and Laurent in 2022

module imm_gen
    #(
		parameter D_W 	=	32
	)
	(
    input   [2:0]       imm_sel,
	input 	[D_W - 8:0] upper_inst, //all but opcode,
	output reg [D_W - 1:0] data_out
	);

    /*
        Except for the 5-bit immediates used in CSR instructions
        (Section 2.8), immediates are always sign-extended, and are generally packed towards the leftmost
        available bits in the instruction and have been allocated to reduce hardware complexity.
        In particular, the sign bit for all immediates is always in bit 31 of the instruction to speed sign-extension
        circuitry.
    */

    //combinational, NOTE: 011 is for R-type, but it is also a dont care
    always@( * ) begin
        
        case(imm_sel)
            3'b010  :   //S - type
                data_out = { {21{upper_inst[24]}}, upper_inst[23:18], upper_inst[4:0]};

            3'b101  :   //U - type
                data_out = { upper_inst[24:5], 12'b0};   
                
            3'b100  :   //B - type
                data_out = { {20{upper_inst[24]}}, upper_inst[0], upper_inst[23:18], upper_inst[4:1], 1'b0};

            3'b111  :   //J - type: covers only jump and link!
                data_out = { {12{upper_inst[24]}}, upper_inst[12:5], upper_inst[13], upper_inst[23:14], 1'b0};

            default :   //I - type, covers ( 000, 001, 110 ) which are immediate, load and jalr
                data_out = { {21{upper_inst[24]}}, upper_inst[23:13]}; 
        endcase

    end

endmodule


