module pd(
  input clock,
  input reset
);	
	////////////////////////////
	// Piplining registers
	////////////////////////////
	
	// ---- Wires connected directly to the latter of a pipedlined register -----

	wire  [31:0] pc_d, instr_d;
	wire  [31:0] pc_x, data_rs1_x, data_rs2_x, instr_x;
	wire  [31:0] pc_m, alu_out_m,  data_rs2_m, instr_m;
	wire  [31:0] pc_w, alu_out_w,  dmem_out,   instr_w;

	// ---- Wires connected directly to the latter of a pipedlined register -----

	// Fetch to Decode
	pipeline_reg pc_d_pipe 
	(	.clock(clock), .kill(pc_sel),   .stall(stall_sel),
		.in(pc_f),	   .out(pc_d)    );

	pipeline_reg #(.KILL_INSTR(32'h00000013)) instr_d_pipe 
	(	.clock(clock), .kill(pc_sel), .stall(stall_sel),
		.in(instr_f),  .out(instr_d)    );

	// Decode to Execute
	pipeline_reg pc_x_pipe 
	(	.clock(clock),   .kill(stall_sel|pc_sel),             .stall(1'b0),
		.in(pc_d), 	   	 .out(pc_x)  	  );

	pipeline_reg #(.KILL_INSTR(32'h00000013)) instr_x_pipe 
	(	.clock(clock),   .kill(stall_sel|pc_sel), .stall(1'b0),
		.in(instr_d),    .out(instr_x) 	  );


	// Execute to Memory
	pipeline_reg pc_m_pipe 
	(	.clock(clock), 	  .kill(1'b0),  .stall(1'b0),
		.in(pc_x), 	   	  .out(pc_m) 	   );

	pipeline_reg #(.KILL_INSTR(32'h00000013)) instr_m_pipe 
	(	.clock(clock), 	  .kill(1'b0),  .stall(1'b0),
		.in(instr_x),  	  .out(instr_m)    );

	pipeline_reg alu_out_m_pipe 
	(	.clock(clock),    .kill(1'b0),  .stall(1'b0),
		.in(alu_out_x),   .out(alu_out_m)  );

	pipeline_reg rs2_m_pipe (
		.clock(clock),    .kill(1'b0),  .stall(1'b0),
		.in(data_rs2_x),  .out(data_rs2_m) );

	// Memory to Write Back
	pipeline_reg pc_w_pipe 
	(	.clock(clock), .kill(1'b0), .stall(1'b0),
		.in(pc_m),     .out(pc_w)    );

	pipeline_reg alu_w_pipe 
	(	.clock(clock), .kill(1'b0), .stall(1'b0),
		.in(alu_out_m),	   .out(alu_out_w)   );

	pipeline_reg #(.KILL_INSTR(32'h00000013)) instr_w_pipe
	(	.clock(clock), .kill(1'b0), .stall(1'b0),
		.in(instr_m),  .out(instr_w) );

	////////////////////////////
	// End Piplining registers
	////////////////////////////


	////////////////////////////
	// Fetch
	////////////////////////////
	reg [31:0] pc_f;
	wire [31:0] instr_f;

	always @(posedge clock) begin
		if (reset) begin
			pc_f <= 32'h01000000;
		end else begin

			if (pc_sel) begin
				pc_f <= alu_out_x;
			end else begin
				if (!stall_sel) begin
					pc_f <= pc_f + 4;
				end
			end

		end
	end

	wire [31:0] imem_in; // not used
	wire imem_rw; // also not used
	imemory imemory_0 
	(
		.clock(clock),
		.address(pc_f),
		.data_in(imem_in),
		.data_out(instr_f),
		.read_write(imem_rw)
	);

	////////////////////////////
	// End Fetch
	////////////////////////////


	////////////////////////////
	// Execute Stage Data Path and Controls
	////////////////////////////

	wire [31:0] immediate;
	wire [3:0]  alu_sel;
	wire [2:0]  imm_sel;
	wire 		pc_sel;

	execute_control execute_control0
	(
		.instr(instr_x),
		.data_rs1(data_rs1_x),
		.data_rs2(data_rs2_x),
		.alu_sel(alu_sel),
		.imm_sel(imm_sel),
		.pc_sel(pc_sel)
	);

    // Immediate Generation
    imm_gen imm_gen0 (
        .imm_sel(imm_sel),
        .upper_inst(instr_x[31:7]),
        .data_out(immediate)
    );
	
	// Init ALU
	wire [31:0] alu_in1 = (a_sel[1])? ( (a_sel[0])? alu_out_m : write_back ) : ( (a_sel[0])? pc_x : data_rs1_x );
	wire [31:0] alu_in2 = (b_sel[1])? ( (b_sel[0])? alu_out_m : write_back ) : ( (b_sel[0])? immediate : data_rs2_x );
	wire [31:0] alu_out_x;

	alu alu0
	(
		.operand1(alu_in1),
		.operand2(alu_in2),
		.alu_sel(alu_sel),
		.alu_out(alu_out_x)
	);

	////////////////////////////
	// End Execute Stage Data Path and Controls
	////////////////////////////

	////////////////////////////
	// Register Writeback Stage
	////////////////////////////

	// write back with alu on R-type, I-type arithmetic, and U-type. Else, get upper two bits opcode
    wire [1:0] wb_sel = (~instr_w[6] & instr_w[4] )? 2'b01 : { instr_w[6], instr_w[5] };

	// mux to get write back data --> No reg
	wire [31:0] write_back = ( wb_sel[1] ) ? ( pc_w + 4 ) : ( wb_sel[0] ? alu_out_w : dmem_data );

	// Identify reg write enable false if it is a store or a branch
    wire regw_en = ~(instr_w[5] & ~instr_w[4] & ~instr_w[2]);
	
	register_file register_file0
	(
		.clock(clock),
		.addr_rs1(instr_d[19:15]),
		.addr_rs2(instr_d[24:20]),
		.addr_rd(instr_w[11:7]), // destination register from the writeback
		.data_rd(write_back),
		.kill(stall_sel|pc_sel),
		.data_rs1(data_rs1_x),
		.data_rs2(data_rs2_x),
		.write_enable(regw_en)
	);

	////////////////////////////
	// End Register Writeback Stage
	////////////////////////////

	////////////////////////////
	// Memory Stage Components
	////////////////////////////

	// Identify mem readwrite as only write if it is a store instruction: opcode start with 010
    wire rw_m = ~instr_m[6] & instr_m[5] & ~instr_m[4];
	
	// Forward mux feeding into dmem
	wire [31:0] dmem_in = ( memw_sel ) ? write_back : data_rs2_m;

	// Unsigned logic outside dmem module
	wire [31:0] dmem_data = ( instr_w[14] )? ( instr_w[12]? { 16'b0, dmem_out[15:0] } : { 24'b0, dmem_out[7:0] } ) : dmem_out;
	dmemory dmemory_0 
	(
		.clock(clock),
		.read_write(rw_m),
		.access_size(instr_m[13:12]),
		.address(alu_out_m),
		.data_in(dmem_in),
		.data_out(dmem_out)
	);

	// TODO parse unsignedness, its not handled in the dmem anymore 

	////////////////////////////
	// End Memory Stage Components
	////////////////////////////

	////////////////////////////	
	// Control Signals
	////////////////////////////
	wire [1:0] a_sel, b_sel;
	wire memw_sel;
	wire stall_sel;

	forward_ctrl forward_ctrl0
	(
		.instr_d(instr_d),
		.instr_x(instr_x),
		.instr_m(instr_m),
		.instr_w(instr_w),
		.a_sel(a_sel),
		.b_sel(b_sel),
		.memw_sel(memw_sel),
		.stall_sel(stall_sel)
	);
	////////////////////////////	
	// End Control Signals
	////////////////////////////


endmodule

