`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/15/2022 10:29:30 PM
// Design Name: 
// Module Name: stopwatch
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

module stopwatch(
  input clk, reset, is_timing,
  output [55:0] ms_time
);

  reg [16:0] count;
  reg [55:0] ms_number;
  wire [55:0] ms_next;
  wire ms_tick;
  wire [7:0] digit [0:6];
  wire carry [0:6];

  assign ms_tick = (count == 100000);

  always @(posedge clk) begin
    if (reset)
      count <= 0;
    else
      count <= ms_tick ? 0 : count + 1;
  end

  always @(posedge clk) begin
    if (reset) 
      ms_number <= 56'h30_30_30_30_30_30_30;
    else
      ms_number <= (is_timing && ms_tick) ? ms_next : ms_number;
  end

  // next number = current number + 1
  assign digit[0] = (ms_number[7:0] == 8'h39) ?  8'h30 : (ms_number[7:0] + 4'h1);
  assign carry[0] = (ms_number[7:0] == 8'h39) ? 1'b1 : 1'b0;
  assign digit[1] = carry[0] ? ((ms_number[15:8] == 8'h39) ? 8'h30 : (ms_number[15:8] + 4'h1)) : ms_number[15:8];
  assign carry[1] = (ms_number[15:8] == 8'h39 && carry[0]) ? 1'b1 : 1'b0;
  assign digit[2] = carry[1] ? ((ms_number[23:16] == 8'h39) ? 8'h30 : (ms_number[23:16] + 4'h1)) : ms_number[23:16];
  assign carry[2] = (ms_number[23:16] == 8'h39 && carry[1]) ? 1'b1 : 1'b0;
  assign digit[3] = carry[2] ? ((ms_number[31:24] == 8'h39) ? 8'h30 : (ms_number[31:24] + 4'h1)) : ms_number[31:24];
  assign carry[3] = (ms_number[31:24] == 8'h39 && carry[2]) ? 1'b1 : 1'b0;
  assign digit[4] = carry[3] ? ((ms_number[39:32] == 8'h39) ? 8'h30 : (ms_number[39:32] + 4'h1)) : ms_number[39:32];
  assign carry[4] = (ms_number[39:32] == 8'h39 && carry[3]) ? 1'b1 : 1'b0;
  assign digit[5] = carry[4] ? ((ms_number[47:40] == 8'h39) ? 8'h30 : (ms_number[47:40] + 4'h1)) : ms_number[47:40];
  assign carry[5] = (ms_number[47:40] == 8'h39 && carry[4]) ? 1'b1 : 1'b0;
  assign digit[6] = carry[5] ? ((ms_number[55:48] == 8'h39) ? 8'h30 : (ms_number[55:48] + 4'h1)) : ms_number[55:48];

  assign ms_next = {digit[6], digit[5], digit[4], digit[3], digit[2], digit[1], digit[0]};

  // output
  assign ms_time = ms_number;

endmodule
