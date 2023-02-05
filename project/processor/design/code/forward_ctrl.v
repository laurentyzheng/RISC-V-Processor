module forward_ctrl
   #(
        parameter BRANCH = 5'b11000,
        parameter STORE  = 5'b01000,
        parameter LOAD   = 5'b00000,
        parameter R_TYPE = 5'b01100
    )
    (
        input  [31:0]   instr_d,
        input  [31:0]   instr_x,
        input  [31:0]   instr_m,
        input  [31:0]   instr_w,
        output reg [1:0]    a_sel,
        output reg [1:0]    b_sel,
        output reg          memw_sel,
        output reg          stall_sel
    );

    wire [4:0] opid_d = instr_d[6:2];
    wire [4:0] opid_x = instr_x[6:2];
    wire [4:0] opid_m = instr_m[6:2];
    wire [4:0] opid_w = instr_w[6:2];

    wire [4:0] rs1_d = instr_d[19:15];
    wire [4:0] rs2_d = instr_d[24:20];

    wire [4:0] rs1_x = instr_x[19:15];
    wire [4:0] rs2_x = instr_x[24:20];

    wire [4:0] rs2_m = instr_m[24:20];

    wire [4:0] rd_x = instr_x[11:7];
    wire [4:0] rd_m = instr_m[11:7];
    wire [4:0] rd_w = instr_w[11:7];

    wire op_w_has_rd = ( opid_w != STORE ) & ( opid_w != BRANCH ) & (rd_w != 5'b0);
    wire op_m_has_rd = ( opid_m != STORE ) & ( opid_m != BRANCH ) & (rd_m != 5'b0);
    wire op_x_has_rd = ( opid_x != STORE ) & ( opid_x != BRANCH ) & (rd_x != 5'b0);


    wire op_x_is_Rtype = (opid_x == R_TYPE);
    
    // NONE OF I type, U type, J type
    wire op_m_has_rs2 = (opid_m == R_TYPE) | (opid_m == STORE) | (opid_m == BRANCH);
    wire op_d_has_rs2 = (opid_d == R_TYPE) | (opid_d == STORE) | (opid_d == BRANCH);

    wire op_x_has_rs1 = ~(opid_x[0] & (opid_x[1] | opid_x[2]));
    wire op_m_has_rs1 = ~(opid_m[0] & (opid_m[1] | opid_m[2]));
    wire op_d_has_rs1 = ~(opid_d[0] & (opid_d[1] | opid_d[2]));


    wire load_to_use = ( opid_x == LOAD ) & ( ( (rs1_d == rd_x) & op_d_has_rs1 ) | ((rs2_d == rd_x) & (opid_d != STORE) & op_d_has_rs2) ) & op_x_has_rd;

    wire store_needs_rs2 = ( opid_d == STORE ) & ( rs2_d == rd_m ) & ( op_m_has_rd );

    wire decode_needs_wb = ( op_w_has_rd ) & ( ( (rs2_d == rd_w)  &  op_d_has_rs2 ) | ( rs1_d == rd_w & op_d_has_rs1 ) );

    wire needy_branch = ( opid_d == BRANCH ) & ( ( (( (rs1_d == rd_m) & op_d_has_rs1 ) | ( (rs2_d == rd_m) & op_d_has_rs2 )) & ( op_m_has_rd ) ) 
                                               | ( (( (rs1_d == rd_x) & op_d_has_rs1 ) | ( (rs2_d == rd_x) & op_d_has_rs2 )) & ( op_x_has_rd ) ) );


    always @( * ) begin

        // A SEL LOGIC
        // match on not a branch, or store
        if ( op_m_has_rd && op_x_has_rs1 && (opid_x != BRANCH) && (rs1_x == rd_m) )
            a_sel = 2'b11;
        else if ( op_w_has_rd && op_x_has_rs1 && (opid_x != BRANCH) && (rs1_x == rd_w) )
            a_sel = 2'b10;
        else
            a_sel = {1'b0, {(instr_x[6] & instr_x[5]) ^ (instr_x[2] & ~instr_x[3])} };

        // B SEL LOGIC
        if ( op_m_has_rd && op_x_is_Rtype && (rs2_x == rd_m) )
            b_sel = 2'b11;
        else if ( op_w_has_rd && op_x_is_Rtype && (rs2_x == rd_w) )
            b_sel = 2'b10;
        else
            b_sel = {1'b0, {~op_x_is_Rtype}};
            

        if ( op_w_has_rd && op_m_has_rs2 && (rs2_m == rd_w) )
            memw_sel = 1'b1;
        else 
            memw_sel = 1'b0;
            

        if (load_to_use || store_needs_rs2 || decode_needs_wb || needy_branch)
            stall_sel = 1'b1;
        else 
            stall_sel = 1'b0;

    end

endmodule
