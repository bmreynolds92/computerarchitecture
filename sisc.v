// 55:035 sisc project part 1

module sisc( CLK, RST_F, IR);
   input CLK, RST_F;
   input [31:0] IR;

   //datapath signals
   wire [31:0] IR, RSA, RSB, ALU_RESULT, WB_DATA;
   wire [3:0] CC, WT_REG; 

   //control signals
   wire RD_SEL, WB_SEL, RF_WE, STAT_EN;
   wire [31:0] MUX32_0;
   wire [3:0] STAT;
   wire [1:0] ALU_OP;

   assign MUX32_0 = 32'b11111111111111110001111111111111;
   //instantiate modules
   alu my_alu( .rsa (RSA), .rsb (RSB), .imm (IR[15:0]), .alu_op (ALU_OP),
        .alu_result (ALU_RESULT), .stat (CC), .stat_en (STAT_EN) );

   mux4 my_mux4( .in_a (IR[19:16]), .in_b (IR[15:12]), .sel (RD_SEL), .out (WT_REG) );

   mux32 my_mux32( .in_a (MUX32_0), .in_b (ALU_RESULT), .sel (WB_SEL), .out (WB_DATA) );

   rf my_rf( .read_rega (IR[23:20]), .read_regb (IR[19:16]), .write_reg (WT_REG) ,
       .write_data (WB_DATA), .rf_we (RF_WE), .rsa (RSA), .rsb (RSB) );

   statreg my_statreg( .in (CC), .enable (STAT_EN), .out(STAT) );

   ctrl my_ctrl( .CLK (CLK), .RST_F (RST_F), .OPCODE (IR[31:28]), .MM (IR[27:24]), .STAT (STAT), .RF_WE (RF_WE), .ALU_OP (ALU_OP), .WB_SEL (WB_SEL), .RD_SEL (RD_SEL) );

   //monitor signals IR, R1, R2, R3, RD_SEL, ALU_OP, WB_SEL, RF_WE, and WB_DATA
   
   initial begin
   	my_rf.ram_array[1] <= 32'b00001111000011110000111100001111;
   	my_rf.ram_array[2] <= 32'b00000000000000000000000000000011;
   	end
   initial 
      begin

         $monitor( $time,,,,  "IR[31:0] = %b, R1 = %b, R2 = %b, R3 = %b, RD_SEL = %b,ALU_OP = %b,  WB_SEL = %b, RF_WE = %b, WB_DATA = %b, MM= %b, ALU_Result = %b",
          IR, my_rf.ram_array[1], my_rf.ram_array[2], my_rf.ram_array[3], RD_SEL, ALU_OP, WB_SEL, RF_WE, WB_DATA , IR[27:24], ALU_RESULT
                    );
end
endmodule
   
