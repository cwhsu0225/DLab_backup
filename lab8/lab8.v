`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/10/2022 10:38:57 AM
// Design Name: 
// Module Name: lab8
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

module lab8(
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
  reg [127:0] row_A, row_B;
  reg [1:0] state_reg, state_next;
  wire [0:63] pattern_list [0:9];
  wire [0:127] hash_list [0:9];
  wire is_done [0:9] , is_bingo [0:9];
  wire [3:0] bingo_idx;
  wire [55:0] calc_time;
  wire reset, btn_pressed, is_timing, next_batch,
       calc_start, calc_done, is_cracked;

  reg [0:127] passwd_hash = 128'hE9982EC5CA981BD365603623CF4B2277;

  localparam IDLE = 2'b00,
             SET = 2'b01,
             CALC = 2'b10,
             DONE = 2'b11;

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

  debounce btn_db3(.clk(clk), .reset(reset), .in(usr_btn[3]), .out(usr_btn3));

  stopwatch stopwatch(.clk(clk), .reset(reset), .is_timing(is_timing), .ms_time(calc_time));

  pattern_generator pattern_generator(
    .clk(clk),
    .reset(reset),
    .next_batch(next_batch),
    .pattern0(pattern_list[0]),
    .pattern1(pattern_list[1]),
    .pattern2(pattern_list[2]),
    .pattern3(pattern_list[3]),
    .pattern4(pattern_list[4]),
    .pattern5(pattern_list[5]),
    .pattern6(pattern_list[6]),
    .pattern7(pattern_list[7]),
    .pattern8(pattern_list[8]),
    .pattern9(pattern_list[9])
   );

  md5 carcker0(.clk(clk), .start(calc_start), .msg(pattern_list[0]), .is_done(is_done[0]), .hash(hash_list[0]));
  md5 carcker1(.clk(clk), .start(calc_start), .msg(pattern_list[1]), .is_done(is_done[1]), .hash(hash_list[1]));
  md5 carcker2(.clk(clk), .start(calc_start), .msg(pattern_list[2]), .is_done(is_done[2]), .hash(hash_list[2]));
  md5 carcker3(.clk(clk), .start(calc_start), .msg(pattern_list[3]), .is_done(is_done[3]), .hash(hash_list[3]));
  md5 carcker4(.clk(clk), .start(calc_start), .msg(pattern_list[4]), .is_done(is_done[4]), .hash(hash_list[4]));
  md5 carcker5(.clk(clk), .start(calc_start), .msg(pattern_list[5]), .is_done(is_done[5]), .hash(hash_list[5]));
  md5 carcker6(.clk(clk), .start(calc_start), .msg(pattern_list[6]), .is_done(is_done[6]), .hash(hash_list[6]));
  md5 carcker7(.clk(clk), .start(calc_start), .msg(pattern_list[7]), .is_done(is_done[7]), .hash(hash_list[7]));
  md5 carcker8(.clk(clk), .start(calc_start), .msg(pattern_list[8]), .is_done(is_done[8]), .hash(hash_list[8]));
  md5 carcker9(.clk(clk), .start(calc_start), .msg(pattern_list[9]), .is_done(is_done[9]), .hash(hash_list[9]));

  encoder encoder(
    .a0(is_bingo[0]),
    .a1(is_bingo[1]), 
    .a2(is_bingo[2]), 
    .a3(is_bingo[3]), 
    .a4(is_bingo[4]), 
    .a5(is_bingo[5]), 
    .a6(is_bingo[6]), 
    .a7(is_bingo[7]), 
    .a8(is_bingo[8]), 
    .a9(is_bingo[9]),
    .out(bingo_idx)
  );
  
  assign reset = ~reset_n;

  assign is_timing = (state_reg != IDLE && state_reg != DONE);

  assign next_batch = (state_reg == CALC && state_next == SET);

  assign calc_start = (state_reg != IDLE && state_reg != SET);

  assign calc_done = is_done[0] & is_done[1] & is_done[2] & is_done[3] & is_done[4] & 
                     is_done[5] & is_done[6] & is_done[7] & is_done[8] & is_done[9];

  assign is_bingo[0] = (hash_list[0] == passwd_hash);
  assign is_bingo[1] = (hash_list[1] == passwd_hash);
  assign is_bingo[2] = (hash_list[2] == passwd_hash);
  assign is_bingo[3] = (hash_list[3] == passwd_hash);
  assign is_bingo[4] = (hash_list[4] == passwd_hash);
  assign is_bingo[5] = (hash_list[5] == passwd_hash);
  assign is_bingo[6] = (hash_list[6] == passwd_hash);
  assign is_bingo[7] = (hash_list[7] == passwd_hash);
  assign is_bingo[8] = (hash_list[8] == passwd_hash);
  assign is_bingo[9] = (hash_list[9] == passwd_hash);

  assign is_cracked = is_bingo[0] | is_bingo[1] | is_bingo[2] | is_bingo[3] | is_bingo[4] | 
                      is_bingo[5] | is_bingo[6] | is_bingo[7] | is_bingo[8] | is_bingo[9];

  // btn pressed logic
  always @(posedge clk) begin
    if (reset)
      btn_reg <= 0;
    else
      btn_reg <= usr_btn3;
  end

  assign btn_pressed = ~btn_reg & usr_btn3;

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
        if (btn_pressed) 
          state_next = SET;
        else
          state_next = IDLE;
      SET:
        state_next = CALC;
      CALC:
        if (calc_done && is_cracked)
          state_next = DONE;
        else if (calc_done && ~is_cracked)
          state_next = SET;
        else 
          state_next = CALC;
      DONE:
        state_next = DONE;
    endcase
  end

  // output logic
  always @(posedge clk) begin
    case (state_reg)
      IDLE: begin
        row_A <= "Press btn3 to   ";
        row_B <= "start cracking  ";
      end
      SET, CALC: begin
        row_A <= "cracking...     ";
        row_B <= "                ";
      end
      DONE: begin
        row_A <= {"Passwd: ", pattern_list[bingo_idx]};
        row_B <= {"Time: ", calc_time, " ms"};
      end
    endcase
  end

endmodule
