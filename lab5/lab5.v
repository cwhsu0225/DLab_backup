`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Dept. of CS, National Chiao Tung University
// Engineer: Chun-Jen Tsai
// 
// Create Date: 2017/10/16 14:21:33
// Design Name: 
// Module Name: lab5
// Project Name: 
// Target Devices: Xilinx FPGA @ 100MHz 
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

module lab5(
  input clk,
  input reset_n,
  input [3:0] usr_btn,
  output [3:0] usr_led,
  output LCD_RS,
  output LCD_RW,
  output LCD_E,
  output [3:0] LCD_D
);

  reg btn_reg;
  wire btn_level, btn_pressed, reset;
  reg [127:0] row_A, row_B;
  reg [2:0] state_reg, state_next;
  reg [10:0] idx_reg, jdx_reg, idx_next, jdx_next;
  reg [1023:0] primes_list;
  wire calc_done;

  reg [9:0] list_ptr_reg, list_ptr_next;
  reg [7:0] file_ptr_reg, file_ptr_next;
  reg [9:0] primes_file [1:172];
  wire mapping_done;

  reg [26:0] time_reg;
  wire tick;

  reg [7:0] disp_ptr_A, disp_ptr_B;
  wire [15:0] ordinal_A, ordinal_B;
  wire [23:0] number_A, number_B;

  localparam IDLE = 3'b000,
             CALC = 3'b001,
             MAPPING = 3'b010,
             DISPLAY = 3'b011,
             DISPLAY_REVERSE = 3'b100;

  LCD_module lcd0(
    .clk(clk),
    .reset(reset),
    .row_A(row_A),
    .row_B(row_B),
    .LCD_E(LCD_E),
    .LCD_RS(LCD_RS),
    .LCD_RW(LCD_RW),
    .LCD_D(LCD_D)
  );

  debounce btn_db0(
    .clk(clk),
    .reset(reset),
    .in(usr_btn[3]),
    .out(btn_level)
  );

  h2a h0(.in(disp_ptr_A[3:0]), .out(ordinal_A[7:0]));
  h2a h1(.in(disp_ptr_A[7:4]), .out(ordinal_A[15:8]));
  h2a h2(.in(primes_file[disp_ptr_A][3:0]), .out(number_A[7:0]));
  h2a h3(.in(primes_file[disp_ptr_A][7:4]), .out(number_A[15:8]));
  h2a h4(.in({1'b0, 1'b0, primes_file[disp_ptr_A][9:8]}), .out(number_A[23:16]));

  h2a h5(.in(disp_ptr_B[3:0]), .out(ordinal_B[7:0]));
  h2a h6(.in(disp_ptr_B[7:4]), .out(ordinal_B[15:8]));
  h2a h7(.in(primes_file[disp_ptr_B][3:0]), .out(number_B[7:0]));
  h2a h8(.in(primes_file[disp_ptr_B][7:4]), .out(number_B[15:8]));
  h2a h9(.in({1'b0, 1'b0, primes_file[disp_ptr_B][9:8]}), .out(number_B[23:16]));

  assign reset = ~reset_n;

  // btn pressed logic
  always @(posedge clk) begin
    if (reset)
      btn_reg <= 0;
    else
      btn_reg <= btn_level;
  end

  assign btn_pressed = ~btn_reg & btn_level;

  // state machine
  always @(posedge clk) begin
    if (reset)
      state_reg <= IDLE;
    else
      state_reg <= state_next;
  end

  always @(*) begin
    case (state_reg)
      IDLE: 
        state_next = CALC;
      CALC: 
        if (calc_done) 
          state_next = MAPPING;
        else 
          state_next = CALC;
      MAPPING:
        if (mapping_done)
          state_next = DISPLAY;
        else
          state_next = MAPPING;
      DISPLAY: 
        if (btn_pressed) 
          state_next = DISPLAY_REVERSE;
        else
          state_next = DISPLAY;
      DISPLAY_REVERSE:
        if (btn_pressed) 
          state_next = DISPLAY;
        else
          state_next = DISPLAY_REVERSE;
      default:
        state_next = state_reg;
    endcase
  end

  assign calc_done = (state_reg == CALC) && (idx_reg == 1023);

  assign mapping_done = (state_reg == MAPPING) && (list_ptr_reg == 1023);

  // sieveing algorithm
  always @(posedge clk) begin
    if (reset) begin
      idx_reg <= 2;
      jdx_reg <= 4;
      primes_list <= {{1022{1'b1}}, 1'b0, 1'b0};
    end
    else if (state_reg == CALC) begin
      idx_reg <= idx_next;
      jdx_reg <= jdx_next;
      primes_list[jdx_reg] <= 0;
    end
  end

  always @(*) begin
    if (idx_reg == 1023) begin
      idx_next = idx_reg;
      jdx_next = jdx_reg;
    end
    else begin
      if (primes_list[idx_reg] && (jdx_reg + idx_reg) <= 1023) begin
        idx_next = idx_reg;
        jdx_next = jdx_reg + idx_reg;
      end
      else begin
        idx_next = idx_reg + 1;
        jdx_next = idx_next + idx_next;
      end
    end
  end

  // mapping logic
  always @(posedge clk) begin
    if (reset) begin
      list_ptr_reg <= 2;
      file_ptr_reg <= 1;
    end
    else if (state_reg == MAPPING) begin
      list_ptr_reg <= list_ptr_next;
      file_ptr_reg <= file_ptr_next;
      if (primes_list[list_ptr_reg]) begin
        primes_file[file_ptr_reg] <= list_ptr_reg;
      end
    end
  end

  always @(*) begin
    if (list_ptr_reg == 1023) begin
      list_ptr_next = list_ptr_reg;
      file_ptr_next = file_ptr_reg;
    end
    else begin
      list_ptr_next = list_ptr_reg + 1;
      file_ptr_next = (primes_list[list_ptr_next] == 1) ? file_ptr_reg + 1 : file_ptr_reg;
    end
  end

  // 0.7 sec generator
  always @(posedge clk) begin
    if (reset)
      time_reg <= 0;
    else
      time_reg <= (time_reg == 70000000) ? 0 : time_reg + 1;
  end

  assign tick = (time_reg == 70000000);

  // display control logic
  always @(posedge clk) begin
    disp_ptr_A <= (reset) ? 1 :
                    (tick && state_reg == DISPLAY && disp_ptr_A == 172) ? 1 :
                    (tick && state_reg == DISPLAY && disp_ptr_A < 172)? disp_ptr_A + 1 :
                    (tick && state_reg == DISPLAY_REVERSE && disp_ptr_A == 1) ? 172 :
                    (tick && state_reg == DISPLAY_REVERSE) ? disp_ptr_A - 1 : disp_ptr_A;
    disp_ptr_B <= (reset) ? 2 :
                    (tick && state_reg == DISPLAY && disp_ptr_B == 172) ? 1 :
                    (tick && state_reg == DISPLAY && disp_ptr_B < 172)? disp_ptr_B + 1 :
                    (tick && state_reg == DISPLAY_REVERSE && disp_ptr_B == 1) ? 172 :
                    (tick && state_reg == DISPLAY_REVERSE) ? disp_ptr_B - 1 : disp_ptr_B;
  end

  // output logic
  always @(posedge clk) begin
    if (reset) begin
      row_A <= "                ";
      row_B <= "                ";
    end 
    else if ((state_reg == DISPLAY || state_reg == DISPLAY_REVERSE) && tick) begin
      row_A <= {"Prime #", ordinal_A," is ", number_A};
      row_B <= {"Prime #", ordinal_B," is ", number_B};
    end
  end

endmodule
