`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/13/2022 09:54:50 PM
// Design Name: 
// Module Name: h2a
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

module h2a(
  input [3:0] in,
  output reg [7:0] out
);
  always @(*) begin
    case(in)
      4'h0: out = 8'h30;
      4'h1: out = 8'h31;
      4'h2: out = 8'h32;
      4'h3: out = 8'h33;
      4'h4: out = 8'h34;
      4'h5: out = 8'h35;
      4'h6: out = 8'h36;
      4'h7: out = 8'h37;
      4'h8: out = 8'h38;
      4'h9: out = 8'h39;
      4'hA: out = 8'h41;
      4'hB: out = 8'h42;
      4'hC: out = 8'h43;
      4'hD: out = 8'h44;
      4'hE: out = 8'h45;
      4'hF: out = 8'h46;
      default: out = 8'h0;
    endcase
  end
endmodule
