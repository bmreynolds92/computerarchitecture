module sisc_tb;

reg CLK, RST_F;
reg [31:0] IR;
sisc tester( .RST_F (RST_F ), .CLK (CLK ), .IR ( IR ));

//hold RST_F line at 0 for 2 cycles before assigning instructions to IR
initial 
   begin 
      RST_F = 0;
     #10 RST_F = 1;
   end


initial
   begin
      CLK = 0;
   end

   always begin
      #5 CLK <= 1 - CLK;
   end

initial 
   begin
	#100
	$display("First instruction NOP");
      IR = 32'b00000000000000000000000000000000; // NOP
#100
$display("2d instruction ADD  R3 <- R1 +R2");
      IR =  32'b10000000000100100011000000000001; // ADD 

#100
$display("3d Instruction SUB  R3 <- R1 -R2");
      IR =  32'b10000000000100100011000000000010; // SUB

#100
$display("4th Instruction NOT R3 <- ~R2");
      IR =  32'b10000000000100100011000000000100; // NOT 

#100
$display("5th Instruction OR R3 <- R1 OR R2");
      IR =  32'b10000000000100100011000000000101; // OR  

#100
$display("6th Instruction AND  R3 <- R1 AND R2");
      IR =  32'b10000000000100100011000000000110; // AND 

#100
$display("7th Instruction XOR  R3 <- R1 XOR R2");
      IR =  32'b10000000000100100011000000000111; // XOR 

#100
$display("85h Instruction ROTR R3 <- R1 ROTR [R2]");
      IR =  32'b10000000000100100011000000001000; // ROTR

#100
$display("9th Instruction ROTL R3 <- R1 ROTL [R2]");
      IR =  32'b10000000000100100011000000001001; // ROTL

#100
$display("10th Instruction SHFR  R3 <- R1 >> [R2]");
      IR =  32'b10000000000100100011000000001010; // SHFR
#100
$display("11th Instruction SHFL  R3 <- R1 << [R2]");
      IR =  32'b10000000000100100011000000001011; // SHFL

#100
$display("12 Instruction Add(imm) R2 <- R1 + 00000000000000000010001000100100");
      IR =  32'b10001000000100100010001000100100; // ADD(imm) 

#100
$display("13th isntructions HLT");
      IR =  32'b11110000001000110000000000000000; // HLT 
  end        
      
endmodule


