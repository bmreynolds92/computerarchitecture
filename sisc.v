// 55:035 sisc project part 1

module sisc( CLK, RST_F );
   input CLK, RST_F;

   //datapath signals
   wire [31:0] RSA, RSB, ALU_RESULT, WB_DATA;
   wire [3:0] CC, WT_REG; 
   //datapath for part2
   wire [15:0] PC_INC; //output for pc as pc_inc, input for br as pc_inc
   wire [15:0] PC_OUT; //output for pc as pc_out, input for im as read_addr
   wire [15:0] BR_ADDR;  //output for br as br_addr, input for pc as br_addr
   wire [31:0] READ_DATA;  //output of IM as read_data, bits [15:0] input to BR as imm


   //control signals
   wire RD_SEL, WB_SEL, RF_WE, STAT_EN;
   wire [31:0] MUX32_0;
   wire [3:0] STAT;
   wire [1:0] ALU_OP;
   //control signals for part2
   wire PC_SEL, PC_WRITE/*aka PC_EN*/, PC_RST, BR_SEL;

   assign MUX32_0 = 32'b11111111111111110001111111111111;
   //instantiate modules
   alu my_alu( 	.rsa (RSA), 
		.rsb (RSB), 
		.imm (READ_DATA[15:0]), 
		.alu_op (ALU_OP),
        	.alu_result (ALU_RESULT), 
		.stat (CC), 
		.stat_en (STAT_EN) );

   mux4 my_mux4(.in_a (READ_DATA[19:16]), 
		.in_b (READ_DATA[15:12]), 
		.sel (RD_SEL), 
		.out (WT_REG) );

   mux32 my_mux32(	.in_a (MUX32_0), 
			.in_b (ALU_RESULT), 
			.sel (WB_SEL), 
			.out (WB_DATA) );

   rf my_rf(	.read_rega (READ_DATA[23:20]), 
		.read_regb (READ_DATA[19:16]), 
		.write_reg (WT_REG) ,
       		.write_data (WB_DATA), 
		.rf_we (RF_WE), 
		.rsa (RSA), 
		.rsb (RSB) );

   statreg my_statreg(  .in (CC), 
			.enable (STAT_EN), 
			.out(STAT) );

   ctrl my_ctrl(.CLK (CLK), 
		.RST_F (RST_F), 
		.OPCODE (READ_DATA[31:28]), 
		.MM (READ_DATA[27:24]), 
		.STAT (STAT), 
		.RF_WE (RF_WE), 
		.ALU_OP (ALU_OP), 
		.WB_SEL (WB_SEL), 
		.RD_SEL (RD_SEL),  
		//these are the new lines for part2
		.PC_WRITE (PC_WRITE),  //aka PC_EN
		.PC_SEL (PC_SEL),  
		.PC_RST (PC_RST),
		.BR_SEL (BR_SEL) );

//modules for part2
  pc my_pc( 	.br_addr 	(BR_ADDR),  //inputs
		.pc_sel 	(PC_SEL),
		.pc_write 	(PC_WRITE),
		.pc_rst 	(PC_RST),
		.pc_out 	(PC_OUT),  //outputs
		.pc_inc 	(PC_INC) );

  br my_br( 	.pc_inc 	(PC_INC),  //inputs
		.imm 		(READ_DATA[15:0]),
		.br_sel 	(BR_SEL),
		.br_addr 	(BR_ADDR) );  //output

  im my_im( 	.read_addr 	(PC_OUT),  //input
		.read_data 	(READ_DATA)  //output
		);

   //monitor signals READ_DATA, R1, R2, R3, RD_SEL, ALU_OP, WB_SEL, RF_WE, and WB_DATA
  initial begin
	my_rf.ram_array[1] <=32'b00001111000011110000111100001111;
	my_rf.ram_array[2] <=32'b0000000000000000000000000000011; 
	end
   initial 
      begin

         $monitor( $time,,,,  "READ_DATA[31:0] = %h\n\t, R0= %b, R1 = %b\n\t R2 = %b, R3 = %b\n\t, R4 = %b \n\t IMMediate = %b\n\t  RD_SEL = %b, ALU_OP = %b,  WB_SEL = %b\n\t, RF_WE = %b, WB_DATA = %b\n\t, MM= %b, ALU_Result = %b\n\t, PC_WRITE = %b,  PC_SEL = %b,  PC_RST = %b,  BR_SEL = %b\n\t BR_ADDR= %b,  PC_OUT  aka READ_ADDR= %b,  PC_INC = %b\n\t   READ_DATA = %b\n\t RST_F = %b\n\n",
          READ_DATA, my_rf.ram_array[0], my_rf.ram_array[1], my_rf.ram_array[2], my_rf.ram_array[3], my_rf.ram_array[4], READ_DATA[15:0],  RD_SEL, ALU_OP, WB_SEL, RF_WE, WB_DATA , READ_DATA[27:24], ALU_RESULT, PC_WRITE, PC_SEL, PC_RST, BR_SEL, BR_ADDR, PC_OUT, PC_INC, READ_DATA, RST_F
                    );
end
endmodule
   
