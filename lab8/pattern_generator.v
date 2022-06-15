`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/15/2022 10:17:27 PM
// Design Name: 
// Module Name: pattern_generator
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

module pattern_generator(
  input clk, reset, next_batch,
  output [0:63] pattern0, pattern1, pattern2, pattern3, pattern4, pattern5, pattern6, pattern7, pattern8, pattern9
);

  reg [63:0] number_reg;
  wire [63:0] number_next;
  wire [7:0] digit [0:7];
  wire carry [0:7];

  always @(posedge clk) begin
    if (reset) 
      number_reg <= 64'h30_30_30_30_30_30_30_30;
    else
      number_reg <= next_batch ? number_next : number_reg;
  end

  // next number = current number + 10
  assign digit[0] = number_reg[7:0];
  assign digit[1] = (number_reg[15:8] == 8'h39) ?  8'h30 : (number_reg[15:8] + 4'h1);
  assign carry[1] = (number_reg[15:8] == 8'h39) ? 1'b1 : 1'b0;
  assign digit[2] = carry[1] ? ((number_reg[23:16] == 8'h39) ? 8'h30 : (number_reg[23:16] + 4'h1)) : number_reg[23:16];
  assign carry[2] = (number_reg[23:16] == 8'h39 && carry[1]) ? 1'b1 : 1'b0;
  assign digit[3] = carry[2] ? ((number_reg[31:24] == 8'h39) ? 8'h30 : (number_reg[31:24] + 4'h1)) : number_reg[31:24];
  assign carry[3] = (number_reg[31:24] == 8'h39 && carry[2]) ? 1'b1 : 1'b0;
  assign digit[4] = carry[3] ? ((number_reg[39:32] == 8'h39) ? 8'h30 : (number_reg[39:32] + 4'h1)) : number_reg[39:32];
  assign carry[4] = (number_reg[39:32] == 8'h39 && carry[3]) ? 1'b1 : 1'b0;
  assign digit[5] = carry[4] ? ((number_reg[47:40] == 8'h39) ? 8'h30 : (number_reg[47:40] + 4'h1)) : number_reg[47:40];
  assign carry[5] = (number_reg[47:40] == 8'h39 && carry[4]) ? 1'b1 : 1'b0;
  assign digit[6] = carry[5] ? ((number_reg[55:48] == 8'h39) ? 8'h30 : (number_reg[55:48] + 4'h1)) : number_reg[55:48];
  assign carry[6] = (number_reg[55:48] == 8'h39 && carry[5]) ? 1'b1 : 1'b0;
  assign digit[7] = carry[6] ? ((number_reg[63:56] == 8'h39) ? 8'h30 : (number_reg[63:56] + 4'h1)) : number_reg[63:56];

  assign number_next = {digit[7], digit[6], digit[5], digit[4], digit[3], digit[2], digit[1], digit[0]};

  // output
  assign pattern0 = number_reg;
  assign pattern1 = {number_reg[63:8], (number_reg[7:0] | 4'h1)};
  assign pattern2 = {number_reg[63:8], (number_reg[7:0] | 4'h2)};
  assign pattern3 = {number_reg[63:8], (number_reg[7:0] | 4'h3)};
  assign pattern4 = {number_reg[63:8], (number_reg[7:0] | 4'h4)};
  assign pattern5 = {number_reg[63:8], (number_reg[7:0] | 4'h5)};
  assign pattern6 = {number_reg[63:8], (number_reg[7:0] | 4'h6)};
  assign pattern7 = {number_reg[63:8], (number_reg[7:0] | 4'h7)};
  assign pattern8 = {number_reg[63:8], (number_reg[7:0] | 4'h8)};
  assign pattern9 = {number_reg[63:8], (number_reg[7:0] | 4'h9)};

endmodule
