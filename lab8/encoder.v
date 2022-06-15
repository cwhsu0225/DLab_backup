`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/10/2022 07:48:43 PM
// Design Name: 
// Module Name: encoder
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

module encoder(
  input a0, a1, a2, a3, a4, a5, a6, a7, a8, a9,
  output reg [3:0] out
);

  always @(*) begin
    case ({a0, a1, a2, a3, a4, a5, a6, a7, a8, a9})
      10'b1000000000: out = 4'b0000;
      10'b0100000000: out = 4'b0001;
      10'b0010000000: out = 4'b0010;
      10'b0001000000: out = 4'b0011;
      10'b0000100000: out = 4'b0100;
      10'b0000010000: out = 4'b0101;
      10'b0000001000: out = 4'b0110;
      10'b0000000100: out = 4'b0111;
      10'b0000000010: out = 4'b1000;
      10'b0000000001: out = 4'b1001;
      default: out = 4'b1111;
    endcase
  end

endmodule
