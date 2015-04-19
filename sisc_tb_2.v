// 55:035 sisc processor project
// test bench for sisc processor

`timescale 1ns/100ps  

module sisc_tb_2;

  parameter    tclk = 10.0;    
  reg          clk;
  reg          rst_f;
  //reg [31:0]   ir;

  // component instantiation
  // "uut" stands for "Unit Under Test"
  sisc uut (.CLK   (clk),
            .RST_F (rst_f)
            );

  // clock driver
  initial
  begin
    clk = 0;    
  end

  always
  begin
    #(tclk/2);
    clk = ~clk;
  end
 
  // reset control
  initial 
  begin
    rst_f = 0;
    // wait for 10 ns;
    #10; 
    rst_f = 1;
   
  end

 
endmodule
