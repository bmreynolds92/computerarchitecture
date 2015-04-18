
// finite state machine

`timescale 1ns/100ps

module ctrl (CLK, RST_F, OPCODE, MM, STAT, RF_WE, ALU_OP, WB_SEL, RD_SEL, PC_WRITE, PC_SEL, PC_RST, BR_SEL );
  
  /* TODO: Declare the ports listed above as inputs or outputs */
  input CLK, RST_F;
  input [3:0] OPCODE, MM, STAT;
  
  
  
  
  output WB_SEL, RD_SEL, RF_WE;
  output PC_WRITE, PC_SEL, PC_RST, BR_SEL;  //these are the new lines for part 2
  reg WB_SEL, RD_SEL, RF_WE;
  
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
  

initial
begin
present_state <= start0;
next_state <= start0;
end


always @(negedge RST_F)
begin
  present_state <= start0;
next_state <= start0;
end

always @ (posedge CLK)
  begin
      present_state <= next_state;
  end

  
  
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
    
  /* TODO: Generate outputs based on the FSM states and inputs. For Parts 2 and 3, you will
       add the new control signals here. */
always@(present_state)
  case(present_state)
    fetch:  begin
      
      end
    decode: begin
      RF_WE <= 0;
      end


    execute: begin
      if (MM == 0) begin
	ALU_OP<= 2'b00;
      end
      else if (MM == 8) begin
	ALU_OP <= 2'b01;
      end
      end
      
    writeback: begin
    if (MM == 0 && OPCODE == alu_op) begin
      RF_WE <= 1;
      WB_SEL <= 0;
      RD_SEL <=1;
      end
        if (MM == am_imm && OPCODE == alu_op) begin
	RF_WE <= 1;
	WB_SEL <= 0;
	RD_SEL <=0;
      end
      
      
      end
      
  endcase
	
  // mem
    
  // write back

endmodule
