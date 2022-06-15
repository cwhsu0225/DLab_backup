`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Dept. of CS, National Chiao Tung University
// Engineer: Chun-Jen Tsai
// 
// Create Date: 2017/04/27 15:06:57
// Design Name: UART I/O example for Arty
// Module Name: lab4
// Project Name: 
// Target Devices: Xilinx FPGA @ 100MHz
// Tool Versions: 
// Description: 
// 
// The parameters for the UART controller are 9600 baudrate, 8-N-1-N
//
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module lab4(
  input  clk,
  input  reset_n,
  input  [3:0] usr_btn,
  output [3:0] usr_led,
  input  uart_rx,
  output uart_tx
);

  localparam [2:0] S_MAIN_INIT = 0,
                   S_MAIN_PROMPT_1 = 1,
                   S_MAIN_PROMPT_2 = 2,
                   S_MAIN_READ_NUM_1 = 3,
                   S_MAIN_READ_NUM_2 = 4,
                   S_MAIN_CALC = 5,
                   S_MAIN_REPLY = 6;

  localparam [1:0] S_UART_IDLE = 0, S_UART_WAIT = 1,
                   S_UART_SEND = 2, S_UART_INCR = 3;

  localparam INIT_DELAY = 100_000; // 1 msec @ 100 MHz
  localparam MEM_SIZE = 94;
  localparam PROMPT_1_STR = 0;
  localparam PROMPT_2_STR = 35;
  localparam REPLY_STR = 71;

  // declare system variables
  wire enter_pressed;
  wire print_enable, print_done, is_num_key;
  reg [$clog2(MEM_SIZE):0] send_counter;
  reg [2:0] P, P_next;
  reg [1:0] Q, Q_next;
  reg [$clog2(INIT_DELAY):0] init_counter;
  reg [7:0] data[0:MEM_SIZE-1];
  reg [9:0] num_1, num_2;
  wire calc_done;

  // declare UART signals
  wire transmit;
  wire received;
  wire [7:0] rx_byte;
  reg  [7:0] rx_temp;
  wire [7:0] tx_byte;
  wire is_receiving;
  wire is_transmitting;
  wire recv_error;

  /* The UART device takes a 100MHz clock to handle I/O at 9600 baudrate */
  uart uart(
    .clk(clk),
    .rst(~reset_n),
    .rx(uart_rx),
    .tx(uart_tx),
    .transmit(transmit),
    .tx_byte(tx_byte),
    .received(received),
    .rx_byte(rx_byte),
    .is_receiving(is_receiving),
    .is_transmitting(is_transmitting),
    .recv_error(recv_error)
  );

  // Initializes some strings.
  // System Verilog has an easier way to initialize an array,
  // but we are using Verilog 2005 :(
  //
  initial begin
    { data[0], data[1], data[2], data[3], data[4], data[5], data[6], data[7], 
      data[8], data[9], data[10], data[11], data[12], data[13], data[14], data[15],
      data[16], data[17], data[18], data[19], data[20], data[21], data[22], data[23],
      data[24], data[25], data[26], data[27], data[28], data[29], data[30], data[31],
      data[32], data[33], data[34] }
    <= { 8'h0D, 8'h0A, "Enter the first decimal number: ", 8'h00 };

    { data[35], data[36], data[37], data[38], data[39], data[40], data[41], data[42], 
      data[43], data[44], data[45], data[46], data[47], data[48], data[49], data[50], 
      data[51], data[52], data[53], data[54], data[55], data[56], data[57], data[58],
      data[59], data[60], data[61], data[62], data[63], data[64], data[65], data[66], 
      data[67], data[68], data[69], data[70] }
    <= { 8'h0D, 8'h0A, "Enter the second decimal number: ", 8'h00 };

    { data[71], data[72], data[73], data[74], data[75], data[76], data[77], data[78],
      data[79], data[80], data[81], data[82], data[83], data[84], data[85], data[86], 
      data[87], data[88], data[89], data[90], data[91], data[92], data[93] }
    <= { 8'h0D, 8'h0A, "The GCD is: 0x0000",  8'h0D, 8'h0A, 8'h00 };
  end

  // Combinational I/O logics
  assign usr_led = usr_btn;
  assign enter_pressed = (rx_temp == 8'h0D);

  // ------------------------------------------------------------------------
  // Main FSM that reads the UART input and triggers
  // the output of the string "Hello, World!".
  always @(posedge clk) begin
    if (~reset_n) 
      P <= S_MAIN_INIT;
    else
      P <= P_next;
  end

  always @(*) begin // FSM next-state logic
    case (P)
      S_MAIN_INIT: // Wait for initial delay of the circuit.
        if (init_counter < INIT_DELAY) P_next = S_MAIN_INIT;
        else P_next = S_MAIN_PROMPT_1;
      S_MAIN_PROMPT_1:
        if (print_done) P_next = S_MAIN_READ_NUM_1;
        else P_next = S_MAIN_PROMPT_1;
      S_MAIN_READ_NUM_1:
        if (enter_pressed) P_next = S_MAIN_PROMPT_2;
        else P_next = S_MAIN_READ_NUM_1;
      S_MAIN_PROMPT_2:
        if (print_done) P_next = S_MAIN_READ_NUM_2;
        else P_next = S_MAIN_PROMPT_2;
      S_MAIN_READ_NUM_2:
        if (enter_pressed) P_next = S_MAIN_CALC;
        else P_next = S_MAIN_READ_NUM_2;
      S_MAIN_CALC:
        if (calc_done) P_next = S_MAIN_REPLY;
        else P_next = S_MAIN_CALC;
      S_MAIN_REPLY:
        if (print_done) P_next = S_MAIN_INIT;
        else P_next = S_MAIN_REPLY;
      default:
        P_next = P;
    endcase
  end

  // FSM output logics: print string control signals.
  assign print_enable = (P != S_MAIN_PROMPT_1 && P_next == S_MAIN_PROMPT_1) ||
                        (P != S_MAIN_PROMPT_2 && P_next == S_MAIN_PROMPT_2) ||
                        (P != S_MAIN_REPLY && P_next == S_MAIN_REPLY);
  assign print_done = (tx_byte == 8'h0);
  assign calc_done = (P == S_MAIN_CALC) && (num_1 == num_2);

  // Initialization counter.
  always @(posedge clk) begin
    if (P == S_MAIN_INIT) init_counter <= init_counter + 1;
    else init_counter <= 0;
  end
  // End of the FSM of the print string controller
  // ------------------------------------------------------------------------

  // ------------------------------------------------------------------------
  // FSM of the controller to send a string to the UART.
  always @(posedge clk) begin
    if (~reset_n) Q <= S_UART_IDLE;
    else Q <= Q_next;
  end

  always @(*) begin // FSM next-state logic
    case (Q)
      S_UART_IDLE: // wait for the print_string flag
        if (print_enable) Q_next = S_UART_WAIT;
        else Q_next = S_UART_IDLE;
      S_UART_WAIT: // wait for the transmission of current data byte begins
        if (is_transmitting == 1) Q_next = S_UART_SEND;
        else Q_next = S_UART_WAIT;
      S_UART_SEND: // wait for the transmission of current data byte finishes
        if (is_transmitting == 0) Q_next = S_UART_INCR; // transmit next character
        else Q_next = S_UART_SEND;
      S_UART_INCR:
        if (tx_byte == 8'h0) Q_next = S_UART_IDLE; // string transmission ends
        else Q_next = S_UART_WAIT;
    endcase
  end

  // FSM output logics
  assign transmit = (Q_next == S_UART_WAIT) ||
                    ((P == S_MAIN_READ_NUM_1 || P == S_MAIN_READ_NUM_2) && received) ||
                    print_enable;

  assign is_num_key = (rx_byte >= 8'h30 && rx_byte <= 8'h39);

  assign tx_byte = (((P == S_MAIN_READ_NUM_1) || (P == S_MAIN_READ_NUM_2)) && received) ? 
                   ((is_num_key || rx_byte == 8'h0D) ? rx_byte : 0) :
                   data[send_counter];


  // UART send_counter control circuit
  always @(posedge clk) begin
    case (P_next)
      S_MAIN_INIT: send_counter <= PROMPT_1_STR;
      S_MAIN_READ_NUM_1: send_counter <= PROMPT_2_STR;
      S_MAIN_READ_NUM_2: send_counter <= REPLY_STR;
      default: send_counter <= send_counter + (Q_next == S_UART_INCR);
    endcase
  end
  // End of the FSM of the print string controller
  // ------------------------------------------------------------------------

  // ------------------------------------------------------------------------
  // The following logic stores the UART input in a temporary buffer.
  // The input character will stay in the buffer for one clock cycle.
  always @(posedge clk) begin
    rx_temp <= (received) ? rx_byte : 8'h0;
  end

  // number read & gcd algo
  always @(posedge clk) begin
    case (P)
      S_MAIN_INIT: begin
        num_1 <= 0;
        num_2 <= 0;
      end
      S_MAIN_READ_NUM_1: begin
        num_1 <= (received && is_num_key) ? (num_1 * 10) + (rx_byte - 48) : num_1;
      end
      S_MAIN_READ_NUM_2: begin
        num_2 <= (received && is_num_key) ? (num_2 * 10) + (rx_byte - 48) : num_2;
      end
      S_MAIN_CALC: begin
        if (num_1 == num_2) begin
          num_1 <= num_1;
          num_2 <= num_2;
        end
        else begin
          num_1 <= (num_1 > num_2) ? (num_1 - num_2) : num_1;
          num_2 <= (num_1 > num_2) ? num_2 : (num_2 - num_1);
        end
      end
      default: begin
        num_1 <= num_1;
        num_2 <= num_2;
      end
    endcase
  end

  // replace output string
  always @(posedge clk) begin
    data[88] <= ({1'b0, 1'b0, num_1[9:8]} > 9) ? ({1'b0, 1'b0, num_1[9:8]} + 55) : ({1'b0, 1'b0, num_1[9:8]} + 48);
    data[89] <= (num_1[7:4] > 9) ? (num_1[7:4] + 55) : (num_1[7:4] + 48);
    data[90] <= (num_1[3:0] > 9) ? (num_1[3:0] + 55) : (num_1[3:0] + 48);
  end

endmodule
