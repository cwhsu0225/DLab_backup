`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/09/26 15:03:31
// Design Name: 
// Module Name: lab3
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

module lab3(
  input  clk,            // System clock at 100 MHz
  input  reset_n,        // System reset signal, in negative logic
  input  [3:0] usr_btn,  // Four user pushbuttons
  output [3:0] usr_led  // Four yellow LEDs,
);

  // signal declaration
  wire usr_btn0, usr_btn1, usr_btn2, usr_btn3, pwm_sig;
  reg btn0_reg, btn1_reg, btn2_reg, btn3_reg;
  wire btn0_tick, btn1_tick, btn2_tick, btn3_tick;
  reg [3:0] number_reg, number_next;
  reg [2:0] brightness_reg, birghtness_next;

  // debounce usr_btn;
  debounce db0(.clk(clk), .reset(~reset_n), .in(usr_btn[0]), .out(usr_btn0));
  debounce db1(.clk(clk), .reset(~reset_n), .in(usr_btn[1]), .out(usr_btn1));
  debounce db2(.clk(clk), .reset(~reset_n), .in(usr_btn[2]), .out(usr_btn2));
  debounce db3(.clk(clk), .reset(~reset_n), .in(usr_btn[3]), .out(usr_btn3));

  // pwm generator
  pwm pwm(.clk(clk), .reset(~reset_n), .mode(brightness_reg), .out(pwm_sig));

  // button pressed logic
  always @(posedge clk) begin
    if (~reset_n) begin
      btn0_reg <= 0;
      btn1_reg <= 0;
      btn2_reg <= 0;
      btn3_reg <= 0;
    end
    else begin
      btn0_reg <= usr_btn0;
      btn1_reg <= usr_btn1;
      btn2_reg <= usr_btn2;
      btn3_reg <= usr_btn3;
    end
  end

  assign btn0_pressed = ~btn0_reg & usr_btn0;
  assign btn1_pressed = ~btn1_reg & usr_btn1;
  assign btn2_pressed = ~btn2_reg & usr_btn2;
  assign btn3_pressed = ~btn3_reg & usr_btn3;

  // number register
  always @(posedge clk) begin
    if (~reset_n)
      number_reg <= 0;
    else
      number_reg <= number_next;
  end

  // next-number logic
  always @(*) begin
    if (btn0_pressed & ~btn1_pressed)
      number_next = (number_reg == -4'd8) ? number_reg : number_reg - 1;
    else if (~btn0_pressed & btn1_pressed)
      number_next = (number_reg == 4'd7) ? number_reg : number_reg + 1;
    else
      number_next = number_reg;
  end

  // brightness register
  always @(posedge clk) begin
    if (~reset_n)
      brightness_reg <= 3'd5;
    else
      brightness_reg <= birghtness_next;
  end

  // next-brightness logic
  always @(*) begin
    if (btn2_pressed & ~btn3_pressed)
      birghtness_next = (brightness_reg == 3'd0) ? brightness_reg : brightness_reg - 1; 
    else if (~btn2_pressed & btn3_pressed)
      birghtness_next = (brightness_reg == 3'd5) ? brightness_reg : brightness_reg + 1; 
    else
      birghtness_next = brightness_reg;
  end

  // apply pwm
  assign usr_led = number_reg & {4{pwm_sig}};
  
endmodule
