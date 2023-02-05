// Created by Karim and Laurent in 2022

module execute_control
    (
        input  [31:0]   instr,
        input  [31:0]   data_rs1,
        input  [31:0]   data_rs2,
        output [3:0]    alu_sel,
        output [2:0]    imm_sel,
        output reg      pc_sel
    );

    wire br_eq;
    wire br_lt;
    wire[2:0] funct3 = instr[14:12];
    wire[6:0] opcode = instr[6:0];
    wire br_unsigned = funct3[1];

    ////////////////////////////
    // Execute Stage Control
    ////////////////////////////

    // either first (3 bit) or (middle 3 bit with top wired to 1)
    assign imm_sel[2:0] = (opcode[6] & opcode[5]) ^ (opcode[2] & ~opcode[3])? {1'b1, opcode[3:2]} : opcode[6:4];

    always @ ( * ) begin
        if ( imm_sel == 3'b111 || imm_sel == 3'b110 ) begin//JAL, JALR
            pc_sel = 1'b1;
        end else if (imm_sel == 3'b100) begin // Branch instr only can enter here
            // This condition enters only for BLT, BGE, BGEU, BLTU
            if (funct3[2]) begin
                pc_sel = br_lt ^ funct3[0]; // LT_funct3[0] = 0, GTE_funct3[0] = 1
            end else begin
                pc_sel = br_eq ^ funct3[0]; // EQ_funct3[0] = 0, NEQ_funct3[0] = 1
            end
        end else begin
            pc_sel = 1'b0;
        end
    
    end

    ////////////////////////////
    // End Execute Stage Control
    ////////////////////////////
    
    
    ////////////////////////////
    // ALU Control
    ////////////////////////////
    alu_ctrl alu_ctrl0 (
        .funct3(funct3),
        .funct7_bit6(instr[30]),
        .opcode_upper(opcode[6:2]),
        .op_sel(alu_sel)
    );

    ////////////////////////////
    // Branch Control
    ////////////////////////////
    branch_comp branch_ctrl0 (
        .data_a(data_rs1),
        .data_b(data_rs2),
        .branch_unsigned(br_unsigned),
        .branch_equal(br_eq),
        .branch_less(br_lt)
    );

   endmodule