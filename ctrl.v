
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
  parameter start0 = 0, start1 = 1, fetch = 2, decode = 3, execute = 4, mem = 5, writeback = 6;
   
  // opcodes
  parameter noop = 0, lod = 1, str = 2, alu_op = 8, bra = 4, brr = 5, bne = 6, hlt=15;
	
  // addressing modes
  parameter am_imm = 8;

  // state registers
  reg [2:0]  present_state, next_state;

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
    fetch:  begin
	$display("in case fetch");
      PC_WRITE <= 1; //set PC_WRITE high during fetch
      
      end
    decode: begin
	$display("in case decode");
      PC_WRITE <= 0; //set PC_WRITE low after fetch
      RF_WE <= 0;
      end


    execute: begin
	$display("in case execute");
      if (MM == 0) begin
	ALU_OP<= 2'b00;
      end
      else if (MM == 8) begin
	ALU_OP <= 2'b01;
      end
      
      //part 2 execute
      if (( OPCODE == bra || OPCODE == brr || OPCODE == bne)) begin
	if ( (MM & STAT) == MM ) begin
		PC_SEL <=1;
		PC_WRITE <= 1;
        end
      end

      if ((OPCODE == bra) || (OPCODE == bne)) begin
        BR_SEL <= 1;
        end
      else
      begin
        BR_SEL <= 0;
      end
     
    end
    
    //mem do nothing for now
      
    writeback: begin
	$display("in case writeback");
      if (MM == 0 && OPCODE == alu_op) begin
	RF_WE <= 1;
	WB_SEL <= 0;
	RD_SEL <=1;
	end
	  if (MM == am_imm && OPCODE == alu_op) begin
	  RF_WE <= 1;
	  WB_SEL <= 0;
//	  RD_SEL <=0;
          RD_SEL <=1;
	end
	
      //part 2 writeback
      if ((OPCODE == bra) || (OPCODE == bne)) begin 
	PC_SEL <= 1;
	end
      else
	PC_SEL <= 0;
	
      
      end
      
  endcase
	
  // mem
    
  // write back

endmodule
