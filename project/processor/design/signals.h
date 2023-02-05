
/* Your Code Below! Enable the following define's 
 * and replace ??? with actual wires */
// ----- signals -----
// You will also need to define PC properly
`define F_PC                pc_f
`define F_INSN              instr_f

`define D_PC                pc_d
`define D_OPCODE            instr_d[6:0]
`define D_RD                instr_d[11:7]
`define D_RS1               instr_d[19:15]
`define D_RS2               instr_d[24:20]
`define D_FUNCT3            instr_d[14:12]
`define D_FUNCT7            instr_d[31:25]
`define D_IMM               immediate
`define D_SHAMT             instr_d[24:20]

`define R_WRITE_ENABLE      regw_en
`define R_WRITE_DESTINATION instr_w[11:7]
`define R_WRITE_DATA        write_back
`define R_READ_RS1          instr_d[19:15]
`define R_READ_RS2          instr_d[24:20]
`define R_READ_RS1_DATA     data_rs1_x
`define R_READ_RS2_DATA     data_rs2_x

`define E_PC                pc_x
`define E_ALU_RES           alu_out_x
`define E_BR_TAKEN          pc_sel

`define M_PC                pc_m
`define M_ADDRESS           alu_out_m
`define M_RW                rw_m
`define M_SIZE_ENCODED      instr_m[14:12]
`define M_DATA              dmem_out

`define W_PC                pc_w
`define W_ENABLE            regw_en
`define W_DESTINATION       instr_w[11:7]
`define W_DATA              write_back

// ----- signals -----

// ----- design -----
`define TOP_MODULE          pd
// ----- design -----


// ----- memeory module paths -----
`define IMEMORY             imemory_0
`define DMEMORY             dmemory_0

// ----- memeory module paths -----