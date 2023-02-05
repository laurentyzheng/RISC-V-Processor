import sys


leFile = open( sys.argv[1], "r" )
def twos_comp(val, bits):
    """compute the 2's complement of int value val"""
    if (val & (1 << (bits - 1))) != 0: # if sign bit is set e.g., 8bit: 128-255
        val = val - (1 << bits)        # compute negative value
    return val                         # return positive value as is

for line in leFile:
    tokens = line.split()
    if( len(tokens) > 0 ):
        if( tokens[0] == "[F]" ):
            print( "==================================================" )
            print( "F - PC =     0x" + tokens[1] )
            print( "F - instr =  0x" + tokens[2] )
        elif( tokens[0] == "[D]" ):
            print( "D - opcode = " + bin( int( tokens[2], 16 ) )[2:].rjust( 7, "0" ) )
            print( "D - rd =     " + str( int( tokens[3], 16 ) ) )
            print( "D - rs1 =    " + str( int( tokens[4], 16 ) ) )
            print( "D - rs2 =    " + str( int( tokens[5], 16 ) ) )
            print( "D - funct3 = " + bin( int( tokens[6], 16 ) )[2:].rjust( 3, "0" ) )
            print( "D - funct7 = " + bin( int( tokens[7], 16 ) )[2:].rjust( 7, "0" ) )
            print( "D - imm =    " + str( twos_comp(int( tokens[8], 16 ), 32 ) ))
            print( "D - shamt =  " + str( int( tokens[9], 16 ) ) )
        #* [R] rs1 rs2 rd data_rs1 data_rs2 we
        elif( tokens[0] == "[R]" ):
            print( "R - rs1 =    " + hex( int( tokens[1], 16 ) ) )
            print( "R - rs2 =    " + hex( int( tokens[2], 16 ) ) )
            print( "R - data_rs1 = " + hex( int( tokens[3], 16 ) ) )
            print( "R - data_rs2 = " + hex( int( tokens[4], 16 ) ) )
        # * [E] pc_address alu_result branch_taken
        elif( tokens[0] == "[E]" ):
            print( "E - PC =     " + tokens[1] )
            print( "E - alu_result =    " + hex( int( tokens[2], 16 ) ) )
            print( "E - branch_taken =  " + hex( int( tokens[3], 16 ) ) )
        elif( tokens[0] == "[M]" ):
            print( "M - PC =            0x" + tokens[1] )
            print( "M - mem_addr =      0x" + tokens[2] )
            print( "M - mem_rw =        " + tokens[3] )
            print( "M - access_size =   " + tokens[4] )
            print( "M - memory_data =   0x" + tokens[5] )
        elif( tokens[0] == "[W]" ):
            print( "W - PC =            0x" + tokens[1] )
            print( "W - write_enable =  " + tokens[2] )
            print( "W - write_rd =      0x" + tokens[3] )
            print( "W - data_rd =       0x" + tokens[4] )

        else:
            print("Unsupported as of now...")
leFile.close()


