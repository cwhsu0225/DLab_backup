`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/12/2022 01:11:02 AM
// Design Name: 
// Module Name: pwm
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

module pwm(
  input reset,
  input clk,
  input [2:0] mode,
  output reg out
);

  // signal declaration
  reg [19:0] duty_period;
  reg [19:0] count;

  // mode definition
  always @(*) begin
    case (mode)
      3'd0: duty_period = 0;
      3'd1: duty_period = 50000;  // 5%
      3'd2: duty_period = 250000; // 25%
      3'd3: duty_period = 500000; // 50%
      3'd4: duty_period = 750000; // 75%
      3'd5: duty_period = 1000000; // 100%
      default: duty_period =  0;
    endcase
  end

  // register
  always @(posedge clk) begin
    if (reset)
      count <= 0;
    else
      count <= (count == 1000000) ? 0 : count + 1;
  end
  
  // pwm logic
  always @(posedge clk) begin
    if (reset)
      out <= 0;
    else
      out <= (count < duty_period) ? 1 : 0;
  end

endmodule
