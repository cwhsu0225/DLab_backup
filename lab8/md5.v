`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/29/2022 07:34:44 AM
// Design Name: 
// Module Name: md5
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

module md5(
  input clk, start,
  input [0:63] msg,
  output is_done,
  output [0:127] hash
);

  reg [0:31] m [0:15];
  reg [31:0] k [0:63];
  reg [31:0] s [0:63];
  reg [0:31] a0, b0, c0, d0,
             A_reg, B_reg, C_reg, D_reg,
             A_next, B_next, C_next, D_next, F;
  reg [3:0] g;
  reg [5:0] i_reg, i_next;
  wire [0:31] A_result, B_result, C_result, D_result;     

  initial begin
    {k[ 0], k[ 1], k[ 2], k[ 3], k[ 4], k[ 5], k[ 6], k[ 7], k[ 8], k[ 9], k[10], k[11], k[12], k[13], k[14], k[15], 
     k[16], k[17], k[18], k[19], k[20], k[21], k[22], k[23], k[24], k[25], k[26], k[27], k[28], k[29], k[30], k[31], 
     k[32], k[33], k[34], k[35], k[36], k[37], k[38], k[39], k[40], k[41], k[42], k[43], k[44], k[45], k[46], k[47], 
     k[48], k[49], k[50], k[51], k[52], k[53], k[54], k[55], k[56], k[57], k[58], k[59], k[60], k[61], k[62], k[63]}
    <= {32'hd76aa478, 32'he8c7b756, 32'h242070db, 32'hc1bdceee, 32'hf57c0faf, 32'h4787c62a, 32'ha8304613, 32'hfd469501,
        32'h698098d8, 32'h8b44f7af, 32'hffff5bb1, 32'h895cd7be, 32'h6b901122, 32'hfd987193, 32'ha679438e, 32'h49b40821,
        32'hf61e2562, 32'hc040b340, 32'h265e5a51, 32'he9b6c7aa, 32'hd62f105d, 32'h02441453, 32'hd8a1e681, 32'he7d3fbc8,
        32'h21e1cde6, 32'hc33707d6, 32'hf4d50d87, 32'h455a14ed, 32'ha9e3e905, 32'hfcefa3f8, 32'h676f02d9, 32'h8d2a4c8a,
        32'hfffa3942, 32'h8771f681, 32'h6d9d6122, 32'hfde5380c, 32'ha4beea44, 32'h4bdecfa9, 32'hf6bb4b60, 32'hbebfbc70,
        32'h289b7ec6, 32'heaa127fa, 32'hd4ef3085, 32'h04881d05, 32'hd9d4d039, 32'he6db99e5, 32'h1fa27cf8, 32'hc4ac5665,
        32'hf4292244, 32'h432aff97, 32'hab9423a7, 32'hfc93a039, 32'h655b59c3, 32'h8f0ccc92, 32'hffeff47d, 32'h85845dd1,
        32'h6fa87e4f, 32'hfe2ce6e0, 32'ha3014314, 32'h4e0811a1, 32'hf7537e82, 32'hbd3af235, 32'h2ad7d2bb, 32'heb86d391};

    {s[ 0], s[ 1], s[ 2], s[ 3], s[ 4], s[ 5], s[ 6], s[ 7], s[ 8], s[ 9], s[10], s[11], s[12], s[13], s[14], s[15],
     s[16], s[17], s[18], s[19], s[20], s[21], s[22], s[23], s[24], s[25], s[26], s[27], s[28], s[29], s[30], s[31],
     s[32], s[33], s[34], s[35], s[36], s[37], s[38], s[39], s[40], s[41], s[42], s[43], s[44], s[45], s[46], s[47],
     s[48], s[49], s[50], s[51], s[52], s[53], s[54], s[55], s[56], s[57], s[58], s[59], s[60], s[61], s[62], s[63]}
    <= {32'd7, 32'd12, 32'd17, 32'd22, 32'd7, 32'd12, 32'd17, 32'd22, 32'd7, 32'd12, 32'd17, 32'd22, 32'd7, 32'd12, 32'd17, 32'd22,
        32'd5, 32'd9, 32'd14, 32'd20, 32'd5, 32'd9, 32'd14, 32'd20, 32'd5, 32'd9, 32'd14, 32'd20, 32'd5, 32'd9, 32'd14, 32'd20,
        32'd4, 32'd11, 32'd16, 32'd23, 32'd4, 32'd11, 32'd16, 32'd23, 32'd4, 32'd11, 32'd16, 32'd23, 32'd4, 32'd11, 32'd16, 32'd23,
        32'd6, 32'd10, 32'd15, 32'd21, 32'd6, 32'd10, 32'd15, 32'd21, 32'd6, 32'd10, 32'd15, 32'd21, 32'd6, 32'd10, 32'd15, 32'd21};

    {a0, b0, c0, d0}
    <= {32'h67452301, 32'hefcdab89, 32'h98badcfe, 32'h10325476};
  end

  always @(posedge clk) begin
    if (~start) begin
      // msg (little-endian)
      m[0] <= {msg[24:31], msg[16:23], msg[8:15], msg[0:7]};
      m[1] <= {msg[56:63], msg[48:55], msg[40:47], msg[32:39]};
      // padding
      m[2] <= {8'h00, 8'h00, 8'h00, 8'h80};
      {m[3], m[4], m[5], m[6], m[7], m[8],
       m[9], m[10], m[11], m[12], m[13]} <= 0;
      // lengh bits
      {m[15], m[14]} <= 64'd64;
      // set initial value
      A_reg <= a0;
      B_reg <= b0;
      C_reg <= c0;
      D_reg <= d0;
      i_reg <= 0;
    end
    else if (i_reg < 63) begin
      A_reg <= A_next;
      B_reg <= B_next;
      C_reg <= C_next;
      D_reg <= D_next;
      i_reg <= i_next;
    end
  end

  // md5 hashing
  always @(*) begin
    if (i_reg < 16) begin
      F = (B_reg & C_reg) | (~B_reg & D_reg);
      g = i_reg;
    end
    else if (i_reg < 32) begin
      F = (D_reg & B_reg) | (~D_reg & C_reg);
      g = 5 * i_reg + 1;
    end
    else if (i_reg < 48) begin
      F = B_reg ^ C_reg ^ D_reg;
      g = 3 * i_reg + 5;
    end
    else begin
      F = C_reg ^ (B_reg | ~D_reg);
      g = 7 * i_reg;
    end

    F = F + A_reg + k[i_reg] + m[g];
    
    A_next = D_reg;
    B_next = B_reg + ((F << s[i_reg]) | (F >> (32 - s[i_reg])));
    C_next = B_reg;
    D_next = C_reg;
    i_next = i_reg + 1;
  end

  // output
  assign A_result = a0 + A_next;
  assign B_result = b0 + B_next;
  assign C_result = c0 + C_next;
  assign D_result = d0 + D_next;

  assign is_done = (i_reg == 63);
  assign hash = {A_result[24:31], A_result[16:23], A_result[8:15], A_result[0:7], 
                 B_result[24:31], B_result[16:23], B_result[8:15], B_result[0:7], 
                 C_result[24:31], C_result[16:23], C_result[8:15], C_result[0:7], 
                 D_result[24:31], D_result[16:23], D_result[8:15], D_result[0:7]};

endmodule
