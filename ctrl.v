
// finite state machine

`timescale 1ns/100ps

module ctrl (CLK, RST_F, OPCODE, MM, STAT, RF_WE, ALU_OP, WB_SEL, RD_SEL, PC_SEL, PC_WRITE, PC_RST, BR_SEL);
  
  /* TODO: Declare the ports listed above as inputs or outputs */
  input CLK, RST_F;
  input [3:0] OPCODE, MM, STAT;
  
  
  
  
  output WB_SEL, RD_SEL, RF_WE;
  output PC_SEL, PC_WRITE, PC_RST, BR_SEL; //part 2 outputs
  
  reg WB_SEL, RD_SEL, RF_WE;
  reg PC_SEL, PC_WRITE, PC_RST, BR_SEL; //part 2 registers
  
  output [1:0] ALU_OP;
  reg [1:0] ALU_OP;
  // states
  parameter start0 = 0, start1 = 1, fetch = 2, decode = 3;  //, execute = 4, mem = 5, writeback = 6;
  parameter aluopImm_Execute = 4, aluopImm_Write = 5, aluopReg_Execute=6, aluopReg_Write=7, branchRel=8, branchAbs=9, branchNeg=10, branchX = 11;
   
  // opcodes
  parameter noop = 0, lod = 1, str = 2, alu_op = 8, bra = 4, brr = 5, bne = 6, hlt=15;
	
  // addressing modes
  parameter am_imm = 8;

  // state registers
  reg [5:0]  present_state, next_state;

  /* TODO: Write a clock process that progresses the fsm to the next state on the
       positive edge of the clock, OR resets the state to 'start0' on the negative edge
       of RST_F. Notice that the computer is reset when RST_F is low, not high. */
  

//initial
//begin
//present_state <= start0;
//next_state <= start0;
//end


always @(posedge CLK or negedge RST_F)
  if (!RST_F) begin
  present_state <= start0;
  end
  else begin
  present_state <= next_state;
  end


//always @ (posedge CLK)
  //begin
    //  present_state <= next_state;
  //end

  
  
  /* TODO: Write a process that determines the next state of the fsm. */
/*
  always @ (present_state)
     case (present_state)
        start0: next_state <= start1;
        start1: next_state <= fetch;
        fetch: next_state <= decode;
        decode: next_state <= execute;
        execute: next_state <= mem;
        mem: next_state <= writeback;
        writeback: next_state <= fetch;
     endcase
*/
  // Halt on HLT instruction
  always @ (OPCODE)
  begin
    if (OPCODE == hlt)
    begin 
      #1 $display ("Halt."); //Delay 1 ns so $monitor will print the halt instruction
      $stop;
    end
  end
  
  // Reset PC
  always @ (RST_F)
     begin 
        if(RST_F == 0)
	  PC_RST <=1;
	else
	  PC_RST <=0;
     end	  
    
  /* TODO: Generate outputs based on the FSM states and inputs. For Parts 2 and 3, you will
       add the new control signals here. */
always@(present_state)
  case(present_state)
	start0: begin
		$display("in start 0");
		next_state <= start1;
	end
	start1: begin
		$display("in start1");
//		RST_F <= 1;
		PC_RST <= 0;
		next_state <= fetch;
	end
	fetch: begin      
		$display("in fetch");
		PC_SEL <=0;
		PC_WRITE <= 1;
		ALU_OP <= 3;
		next_state <= decode;
	end
	decode: begin
		$display("in decode");
		RF_WE <= 0;
		PC_WRITE <= 0;
//		case(OPCODE)
			$display("checking opcode");
			if(OPCODE == noop) begin
				$display("noop");
				next_state <= fetch;
			end
			if(OPCODE == alu_op) begin
				$display("alu_op");
				ALU_OP <= (ALU_OP | 10);
				if(MM == am_imm) begin
					$display("immediate operation");
					next_state <= aluopImm_Execute;
				end
				if(MM == 0) begin
					$display("r-type aluop");
					next_state <= aluopReg_Execute;
				end
			end
			if(OPCODE == brr) begin
				$display("branch relative operation");
				next_state <= branchRel;
			end
			if(OPCODE == bra) begin
				$display("branch absolute operation");
				next_state <= branchAbs;
			end
			if(OPCODE == bne) begin
				$display("branch negative absolute operation");
				next_state <= branchNeg;
			end
//		endcase
	end
	aluopImm_Execute: begin
		$display("aluopImm_execute");
		WB_SEL <= 0;
		ALU_OP <= 2'b01;
		RD_SEL <=0;
		next_state<= aluopImm_Write;
	end
	aluopImm_Write:  begin
		$display("aluopImm_Write");
		PC_WRITE <= 0;
		WB_SEL <= 0;
		RF_WE <= 1;
		RD_SEL <= 0;
		next_state <= fetch;
	end
	aluopReg_Execute: begin
		$display("aluopReg_Execute");
		WB_SEL = 0;
		ALU_OP = 2'b00;
		RD_SEL = 1;
		next_state <= aluopReg_Write;
	end
	aluopReg_Write: begin
		$display("aluopReg_Write");
		PC_WRITE<=0;
		WB_SEL<=0;
		RF_WE<= 1;
		RD_SEL <=1;
		next_state<=fetch;
	end
	branchRel: begin
		$display("in branchRel");
		if(  (MM & STAT) != 0 ) begin
			$display("branch condition found");
			BR_SEL <= 0;
			PC_SEL <=1;
			WB_SEL <= 0;
//			PC_WRITE <= 1;
		end
		else begin
			$display("branch condition not found");
		end
		next_state<= fetch;
	end
	branchAbs: begin 
		$display("in branch abs");
		if( ( MM & STAT) != 0) begin
			$display("branch condition found !");
			BR_SEL <= 1;
			PC_SEL <=1;
			WB_SEL <= 0;
//			PC_WRITE <= 1;
		end
		else begin
			$display("branch condition not found");
		end
//		next_state<= branchX;
		next_state<= fetch;
	end
	branchNeg: begin 
		$display("in negative absolute branch");
		if ( (MM & STAT) == 0) begin
			$display("branch condition found !");
			BR_SEL <= 1;
			PC_SEL <=1;
			WB_SEL <= 0;
//			PC_WRITE <= 1;
		end
		else begin
			$display("branch condition not found");
		end
		next_state<= fetch;
	end	
	branchX: begin
		$display("in branchX");
		next_state<= fetch;
	end
  endcase
endmodule
