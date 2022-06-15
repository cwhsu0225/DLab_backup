`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/12/2022 12:43:26 AM
// Design Name: 
// Module Name: debounce
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

module debounce (
  input clk,
  input reset,
  input in,
  output out
);

  // signal declaration
  reg in_reg, out_reg;
  reg [17:0] count_reg;
  wire stable;

  // debounce logic (2ms)
  always @(posedge clk) begin
    if (reset) begin
      in_reg <= 0;
      out_reg <= 0;
      count_reg <= 0;
    end
    else begin
      in_reg <= in;
      out_reg <= stable ? in : out_reg;
      count_reg <= (in_reg != in) ? 0 : (stable ? count_reg : count_reg + 1);
    end
  end 

  assign stable = (count_reg == 18'd200000);

  // output logic
  assign out = out_reg;

endmodule
