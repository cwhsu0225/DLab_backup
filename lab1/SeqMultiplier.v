`timescale 10ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/21/2022 07:14:18 PM
// Design Name: 
// Module Name: SeqMultiplier
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

module SeqMultiplier(
  input clk,
  input enable,
  input [7:0] A,
  input [7:0] B,
  output [15:0] C
);

  // signal declaration
  reg [4:0] idx_reg;
  reg [7:0] B_reg;
  reg [15:0] C_reg;

  // register
  always @(posedge clk) begin
    if(~enable) begin
      idx_reg <= 8;
      B_reg <= B;
      C_reg <= 0;
    end
    else if (idx_reg != 0) begin
      C_reg <= (C_reg << 1) + (B_reg[7] ? A : 0);
      B_reg <=  B_reg << 1;
      idx_reg <= idx_reg - 1;
    end
  end

  // output
  assign C = C_reg;

endmodule
