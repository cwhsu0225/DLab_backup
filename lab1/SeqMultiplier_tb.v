`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/21/2022 08:14:25 PM
// Design Name: 
// Module Name: SeqMultiplier_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module SeqMultiplier_tb;

  // input
  reg clk = 1;
  reg enable;
  reg [7:0] A, B;
  
  // output
  wire [15:0] C;

  SeqMultiplier uut(
      .clk(clk), 
      .enable(enable),
      .A(A),
      .B(B),
      .C(C)
  );

  // 50MHz clock generator
  always
    #10 clk = !clk;

  initial begin
    A = 8'd239; B = 8'd35; enable = 0;
    #20;
    enable = 1;
  end
endmodule
