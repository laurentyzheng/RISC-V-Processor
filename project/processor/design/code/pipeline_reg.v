module pipeline_reg
    #(
        parameter           D_W        = 32,
        parameter [D_W-1:0] KILL_INSTR = 32'b0
    )
    (
        input 	         clock,
        input 	         kill,
        input 	         stall,
        input       [D_W-1:0] in, 
        output  reg [D_W-1:0] out
    );

	initial begin
		out = 32'h00000000;
	end

    always @ (posedge clock) begin

        if ( kill ) begin 
            out <= KILL_INSTR[D_W-1:0];
        end else begin
            if (!stall) begin
                out <= in;
            end
        end
        
    end

endmodule
