`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/09/19 11:25:45
// Design Name: 
// Module Name: mmult
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

module mmult(
  input clk,                 // Clock signal
  input reset_n,             // Reset signal (negative logic)
  input enable,              // Activation signal for matrix multiplication
  input [0:9*8-1] A_mat,     // A matrix
  input [0:9*8-1] B_mat,     // B matrix
  output valid,              // Signals that the output is valid to read
  output reg [0:9*17-1] C_mat // The result of A x B
);

  reg [2:0] count;

  always @(posedge clk) begin
    if (~reset_n) begin
      C_mat <= 0;
      count <= 0;
    end
    else if (enable && count < 3) begin
      C_mat[count*17 +:17] <= A_mat[0:7] * B_mat[count*8 +:8] + A_mat[8:15] * B_mat[count*8+24 +:8] + A_mat[16:23] * B_mat[count*8+48 +:8];
      C_mat[count*17+51 +:17] <= A_mat[24:31] * B_mat[count*8 +:8] + A_mat[32:39] * B_mat[count*8+24 +:8] + A_mat[40:47] * B_mat[count*8+48 +:8];
      C_mat[count*17+102 +:17] <= A_mat[48:55] * B_mat[count*8 +:8] + A_mat[56:63] * B_mat[count*8+24 +:8] + A_mat[64:71] * B_mat[count*8+48 +:8];
      count <= count + 1;
    end
  end
  
  assign valid = (count == 3);

endmodule
