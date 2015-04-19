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

   assign MUX32_0 = 32'd0;
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
//	my_rf.ram_array[1] <=32'd1234;
//	my_rf.ram_array[2] <=32'd0; 
	end
   initial 
      begin

         $monitor( $time,,,,  "READ_DATA[31:0] = %h\n\t, R0= %h, R1 = %h\n\t R2 = %h, R3 = %h\n\t, R4 = %h \n\t IMMediate = %h\n\t  RD_SEL = %h, ALU_OP = %h,  WB_SEL = %h\n\t, RF_WE = %h, WB_DATA = %h\n\t, MM= %h, ALU_Result = %h\n\t, PC_WRITE = %h,  PC_SEL = %h,  PC_RST = %h,  BR_SEL = %h\n\t BR_ADDR= %h,  PC_OUT  aka READ_ADDR= %h,  PC_INC = %h\n\t   READ_DATA = %h\n\t RST_F = %h\n\t OP_CODE = %h\n\t STAT = %h    STAT_EN = %h\n\t RegA=%h, Regb=%h",
          READ_DATA, my_rf.ram_array[0], my_rf.ram_array[1], my_rf.ram_array[2], my_rf.ram_array[3], my_rf.ram_array[4], READ_DATA[15:0],  RD_SEL, ALU_OP, WB_SEL, RF_WE, WB_DATA , READ_DATA[27:24], ALU_RESULT, PC_WRITE, PC_SEL, PC_RST, BR_SEL, BR_ADDR, PC_OUT, PC_INC, READ_DATA, RST_F, READ_DATA[31:28], STAT, STAT_EN, my_rf.rsa, my_rf.rsb
                    );
end
endmodule
   
