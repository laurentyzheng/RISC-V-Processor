// Created by Karim in 2022

module register_file 
    (
        input                clock,
        input [4:0]          addr_rs1, addr_rs2, addr_rd,
        input [31:0]         data_rd,
        input                write_enable,
        input                kill,
        output reg [31:0]    data_rs1, data_rs2
    );

    // Make 31 registers: X31-X1

    (* ram_style = "block" *) reg [31:0] registers_rs1 [31:1];
    (* ram_style = "block" *) reg [31:0] registers_rs2 [31:1];
    
    integer i;

    initial begin
        //stack pointer initialization
        for (i = 0; i < 32; i = i + 1) begin
            if (i != 2) begin
                registers_rs1[i] = 0;
                registers_rs2[i] = 0;
            end
        end

        registers_rs1[2] = (32'h01000000) + `MEM_DEPTH;
        registers_rs2[2] = (32'h01000000) + `MEM_DEPTH;
    end

    always @( posedge clock ) begin
        // If we want to write to anything not x0
        if ( write_enable && addr_rd != 0 ) begin
            registers_rs1[addr_rd] <= data_rd;
            registers_rs2[addr_rd] <= data_rd;
        end

    end

    //one latency read
    always @( posedge clock ) begin
        if (addr_rs1 == 0 || kill) begin
            data_rs1 <= 0;
        end else begin
            data_rs1 <= registers_rs1[addr_rs1];
        end   
    end
    
    always @( posedge clock ) begin
        if (addr_rs2 == 0 || kill) begin
            data_rs2 <= 0;
        end else begin
            data_rs2 <= registers_rs2[addr_rs2];
        end
    end

endmodule