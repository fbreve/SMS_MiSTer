module linear_table_mul_Brtl
  (input  [5:0] i0,
   input  [9:0] i1,
   output [9:0] o);
  wire [16:0] w_mul;
  wire [6:0] n6886;
  wire [16:0] n6887;
  wire [16:0] n6888;
  wire [16:0] n6889;
  wire [9:0] n6890;
  assign o = n6890; //(module output)
  /*# sim_rtl/lineartable.vhd:50:12 */
  assign w_mul = n6889; // (signal)
  /*# sim_rtl/lineartable.vhd:53:21 */
  assign n6886 = {1'b0, i0};
  /*# sim_rtl/lineartable.vhd:53:27 */
  assign n6887 = {{10{n6886[6]}}, n6886}; // sext
  /*# sim_rtl/lineartable.vhd:53:27 */
  assign n6888 = {{7{i1[9]}}, i1}; // sext
  /*# sim_rtl/lineartable.vhd:53:27 */
  assign n6889 = $signed(n6887) * $signed(n6888); // smul
  /*# sim_rtl/lineartable.vhd:54:21 */
  assign n6890 = w_mul[15:6]; // extract
endmodule

module interpolate_mul_Brtl
  (input  [8:0] i0,
   input  [11:0] i1,
   output [13:0] o);
  wire [21:0] w_mul;
  wire [9:0] n6879;
  wire [21:0] n6880;
  wire [21:0] n6881;
  wire [21:0] n6882;
  wire [13:0] n6883;
  assign o = n6883; //(module output)
  /*# sim_rtl/sinetable.vhd:50:12 */
  assign w_mul = n6882; // (signal)
  /*# sim_rtl/sinetable.vhd:53:21 */
  assign n6879 = {1'b0, i0};
  /*# sim_rtl/sinetable.vhd:53:27 */
  assign n6880 = {{12{n6879[9]}}, n6879}; // sext
  /*# sim_rtl/sinetable.vhd:53:27 */
  assign n6881 = {{10{i1[11]}}, i1}; // sext
  /*# sim_rtl/sinetable.vhd:53:27 */
  assign n6882 = $signed(n6880) * $signed(n6881); // smul
  /*# sim_rtl/sinetable.vhd:54:21 */
  assign n6883 = w_mul[20:7]; // extract
endmodule

module attack_table_mul_Brtl
  (input  [7:0] i0,
   input  [7:0] i1,
   output [13:0] o);
  wire [16:0] w_mul;
  wire [8:0] n6872;
  wire [16:0] n6873;
  wire [16:0] n6874;
  wire [16:0] n6875;
  wire [13:0] n6876;
  assign o = n6876; //(module output)
  /*# sim_rtl/attacktable.vhd:51:12 */
  assign w_mul = n6875; // (signal)
  /*# sim_rtl/attacktable.vhd:54:21 */
  assign n6872 = {1'b0, i0};
  /*# sim_rtl/attacktable.vhd:54:27 */
  assign n6873 = {{8{n6872[8]}}, n6872}; // sext
  /*# sim_rtl/attacktable.vhd:54:27 */
  assign n6874 = {{9{i1[7]}}, i1}; // sext
  /*# sim_rtl/attacktable.vhd:54:27 */
  assign n6875 = $signed(n6873) * $signed(n6874); // smul
  /*# sim_rtl/attacktable.vhd:55:21 */
  assign n6876 = w_mul[15:2]; // extract
endmodule

module voicerom_Brtl_c4ea21bb365bbeeaf5f2c654883e56d11e43c44e
  (input  clk,
   input  [5:0] addr,
   output \data[am] ,
   output \data[pm] ,
   output \data[eg] ,
   output \data[kr] ,
   output [3:0] \data[ml] ,
   output [1:0] \data[kl] ,
   output [5:0] \data[tl] ,
   output \data[wf] ,
   output [2:0] \data[fb] ,
   output [3:0] \data[ar] ,
   output [3:0] \data[dr] ,
   output [3:0] \data[sl] ,
   output [3:0] \data[rr] );
  wire n6824;
  wire n6825;
  wire n6826;
  wire n6827;
  wire [3:0] n6828;
  wire [1:0] n6829;
  wire [5:0] n6830;
  wire n6831;
  wire [2:0] n6832;
  wire [3:0] n6833;
  wire [3:0] n6834;
  wire [3:0] n6835;
  wire [3:0] n6836;
  wire n6850;
  wire n6851;
  wire n6852;
  wire n6853;
  wire [3:0] n6854;
  wire [1:0] n6855;
  wire [5:0] n6856;
  wire n6857;
  wire [2:0] n6858;
  wire [3:0] n6859;
  wire [3:0] n6860;
  wire [3:0] n6861;
  wire [3:0] n6862;
  wire [35:0] n6863;
  reg [35:0] n6866;
  wire [35:0] n6869; // mem_rd
  assign \data[am]  = n6824; //(module output)
  assign \data[pm]  = n6825; //(module output)
  assign \data[eg]  = n6826; //(module output)
  assign \data[kr]  = n6827; //(module output)
  assign \data[ml]  = n6828; //(module output)
  assign \data[kl]  = n6829; //(module output)
  assign \data[tl]  = n6830; //(module output)
  assign \data[wf]  = n6831; //(module output)
  assign \data[fb]  = n6832; //(module output)
  assign \data[ar]  = n6833; //(module output)
  assign \data[dr]  = n6834; //(module output)
  assign \data[sl]  = n6835; //(module output)
  assign \data[rr]  = n6836; //(module output)
  /*# sim_rtl/voicerom.vhd:38:8 */
  assign n6824 = n6866[0]; // extract
  /*# sim_rtl/voicerom.vhd:38:8 */
  assign n6825 = n6866[1]; // extract
  /*# sim_rtl/voicerom.vhd:38:8 */
  assign n6826 = n6866[2]; // extract
  /*# sim_rtl/voicerom.vhd:38:8 */
  assign n6827 = n6866[3]; // extract
  /*# sim_rtl/voicerom.vhd:38:8 */
  assign n6828 = n6866[7:4]; // extract
  /*# sim_rtl/voicerom.vhd:38:8 */
  assign n6829 = n6866[9:8]; // extract
  /*# sim_rtl/voicerom.vhd:38:8 */
  assign n6830 = n6866[15:10]; // extract
  /*# sim_rtl/voicerom.vhd:38:8 */
  assign n6831 = n6866[16]; // extract
  /*# sim_rtl/voicerom.vhd:38:8 */
  assign n6832 = n6866[19:17]; // extract
  /*# sim_rtl/voicerom.vhd:38:8 */
  assign n6833 = n6866[23:20]; // extract
  /*# sim_rtl/voicerom.vhd:38:8 */
  assign n6834 = n6866[27:24]; // extract
  /*# sim_rtl/voicerom.vhd:38:8 */
  assign n6835 = n6866[31:28]; // extract
  /*# sim_rtl/voicerom.vhd:38:8 */
  assign n6836 = n6866[35:32]; // extract
  /*# sim_rtl/vm2413.vhd:186:19 */
  assign n6850 = n6869[35]; // extract
  /*# sim_rtl/vm2413.vhd:186:37 */
  assign n6851 = n6869[34]; // extract
  /*# sim_rtl/vm2413.vhd:186:55 */
  assign n6852 = n6869[33]; // extract
  /*# sim_rtl/vm2413.vhd:186:73 */
  assign n6853 = n6869[32]; // extract
  /*# sim_rtl/vm2413.vhd:187:19 */
  assign n6854 = n6869[31:28]; // extract
  /*# sim_rtl/vm2413.vhd:187:47 */
  assign n6855 = n6869[27:26]; // extract
  /*# sim_rtl/vm2413.vhd:187:75 */
  assign n6856 = n6869[25:20]; // extract
  /*# sim_rtl/vm2413.vhd:188:19 */
  assign n6857 = n6869[19]; // extract
  /*# sim_rtl/vm2413.vhd:188:37 */
  assign n6858 = n6869[18:16]; // extract
  /*# sim_rtl/vm2413.vhd:189:19 */
  assign n6859 = n6869[15:12]; // extract
  /*# sim_rtl/vm2413.vhd:189:47 */
  assign n6860 = n6869[11:8]; // extract
  /*# sim_rtl/vm2413.vhd:189:74 */
  assign n6861 = n6869[7:4]; // extract
  /*# sim_rtl/vm2413.vhd:189:100 */
  assign n6862 = n6869[3:0]; // extract
  /*# sim_rtl/vm2413.vhd:185:12 */
  assign n6863 = {n6862, n6861, n6860, n6859, n6858, n6857, n6856, n6855, n6854, n6853, n6852, n6851, n6850};
  /*# sim_rtl/voicerom.vhd:187:5 */
  always @(posedge clk)
    n6866 <= n6863;
  /*# sim_rtl/voicerom.vhd:189:40 */
  reg [35:0] n6867[37:0] ; // memory
  initial begin
    n6867[37] = 36'b000000010000000000001010101001010101;
    n6867[36] = 36'b000001010000000000001111100001011001;
    n6867[35] = 36'b000000010000000000001101100001001000;
    n6867[34] = 36'b000000010000000000001100100010100111;
    n6867[33] = 36'b000000010000000000001111100001101101;
    n6867[32] = 36'b000000010001100011111101111101101010;
    n6867[31] = 36'b010000010000000000001110010000010011;
    n6867[30] = 36'b011000011000100100111111000101000000;
    n6867[29] = 36'b000000010000000000001001010100000010;
    n6867[28] = 36'b000000010101010100111100100100000011;
    n6867[27] = 36'b010100000000000000001111010101000010;
    n6867[26] = 36'b011000010000110001011100001000100000;
    n6867[25] = 36'b110000010000000000001111100000010010;
    n6867[24] = 36'b000101110010010001111111100000100010;
    n6867[23] = 36'b000000010000000010001110010000000100;
    n6867[22] = 36'b000100111000001100011111101000010000;
    n6867[21] = 36'b011000010000000010001111011100000111;
    n6867[20] = 36'b010000010000101110001000010101110001;
    n6867[19] = 36'b011000010000000000000110010100010111;
    n6867[18] = 36'b011000010001101101100110010000010000;
    n6867[17] = 36'b001000010000000010000111001000000111;
    n6867[16] = 36'b001000110010110101001010001000000000;
    n6867[15] = 36'b011000010000000000001000000100000111;
    n6867[14] = 36'b001000010001110101111000001000010000;
    n6867[13] = 36'b001000100000000000000111000100011000;
    n6867[12] = 36'b001100010001011001011110000000000000;
    n6867[11] = 36'b001000010000000000000111011000101000;
    n6867[10] = 36'b001100100001111001101110000000000000;
    n6867[9] = 36'b011000010000000000000110010000100111;
    n6867[8] = 36'b001100010000111001111010100001110000;
    n6867[7] = 36'b000000010000000000001100010000100011;
    n6867[6] = 36'b000100111001100100001111001000010001;
    n6867[5] = 36'b010000010000000000001111011100010011;
    n6867[4] = 36'b000100110001101011011101100000100011;
    n6867[3] = 36'b011000010000000010000111100000010111;
    n6867[2] = 36'b011100010001111001111101000000000000;
    n6867[1] = 36'b000000000000000000000000000000000000;
    n6867[0] = 36'b000000000000000000000000000000000000;
    end
  assign n6869 = n6867[addr];
  /*# sim_rtl/voicerom.vhd:189:40 */
endmodule

module lineartable_Brtl
  (input  clk,
   input  reset,
   input  [13:0] addr,
   output \data[sign] ,
   output [8:0] \data[value] );
  wire n6757;
  wire [8:0] n6758;
  wire ff_sign;
  wire [5:0] ff_weight;
  wire [8:0] ff_data0;
  wire [8:0] ff_data1;
  wire [6:0] w_addr1;
  wire [9:0] w_sub;
  wire [9:0] w_mul;
  wire [9:0] w_inter;
  wire [6:0] n6759;
  wire [6:0] n6761;
  wire [6:0] n6762;
  wire n6764;
  wire [6:0] n6765;
  wire [6:0] n6770;
  wire n6788;
  wire [5:0] n6789;
  wire [9:0] n6794;
  wire [9:0] n6796;
  wire [9:0] n6797;
  wire [9:0] u_linear_table_mul_n6798;
  wire [9:0] n6802;
  wire [9:0] n6803;
  wire [8:0] n6807;
  wire [9:0] n6808;
  reg [9:0] n6812;
  reg n6813;
  reg [5:0] n6814;
  reg [8:0] n6820; // mem_rd
  reg [8:0] n6822; // mem_rd
  assign \data[sign]  = n6757; //(module output)
  assign \data[value]  = n6758; //(module output)
  /*# sim_rtl/lineartable.vhd:63:8 */
  assign n6757 = n6812[0]; // extract
  /*# sim_rtl/lineartable.vhd:63:8 */
  assign n6758 = n6812[9:1]; // extract
  /*# sim_rtl/lineartable.vhd:118:12 */
  assign ff_sign = n6813; // (signal)
  /*# sim_rtl/lineartable.vhd:119:12 */
  assign ff_weight = n6814; // (signal)
  /*# sim_rtl/lineartable.vhd:120:12 */
  assign ff_data0 = n6822; // (signal)
  /*# sim_rtl/lineartable.vhd:121:12 */
  assign ff_data1 = n6820; // (signal)
  /*# sim_rtl/lineartable.vhd:123:12 */
  assign w_addr1 = n6765; // (signal)
  /*# sim_rtl/lineartable.vhd:125:12 */
  assign w_sub = n6797; // (signal)
  /*# sim_rtl/lineartable.vhd:126:12 */
  assign w_mul = u_linear_table_mul_n6798; // (signal)
  /*# sim_rtl/lineartable.vhd:127:12 */
  assign w_inter = n6803; // (signal)
  /*# sim_rtl/lineartable.vhd:129:21 */
  assign n6759 = addr[12:6]; // extract
  /*# sim_rtl/lineartable.vhd:129:37 */
  assign n6761 = n6759 + 7'b0000001;
  /*# sim_rtl/lineartable.vhd:129:52 */
  assign n6762 = addr[12:6]; // extract
  /*# sim_rtl/lineartable.vhd:129:68 */
  assign n6764 = n6762 != 7'b1111111;
  /*# sim_rtl/lineartable.vhd:129:42 */
  assign n6765 = n6764 ? n6761 : 7'b1111111;
  /*# sim_rtl/lineartable.vhd:136:57 */
  assign n6770 = addr[12:6]; // extract
  /*# sim_rtl/lineartable.vhd:144:32 */
  assign n6788 = addr[13]; // extract
  /*# sim_rtl/lineartable.vhd:145:32 */
  assign n6789 = addr[5:0]; // extract
  /*# sim_rtl/lineartable.vhd:151:22 */
  assign n6794 = {1'b0, ff_data1};
  /*# sim_rtl/lineartable.vhd:151:41 */
  assign n6796 = {1'b0, ff_data0};
  /*# sim_rtl/lineartable.vhd:151:34 */
  assign n6797 = n6794 - n6796;
  /*# sim_rtl/lineartable.vhd:153:5 */
  linear_table_mul_Brtl u_linear_table_mul (
    .i0(ff_weight),
    .i1(w_sub),
    .o(u_linear_table_mul_n6798));
  /*# sim_rtl/lineartable.vhd:160:21 */
  assign n6802 = {1'b0, ff_data0};
  /*# sim_rtl/lineartable.vhd:160:33 */
  assign n6803 = n6802 + w_mul;
  /*# sim_rtl/lineartable.vhd:167:35 */
  assign n6807 = w_inter[8:0]; // extract
  /*# sim_rtl/lineartable.vhd:165:21 */
  assign n6808 = {n6807, ff_sign};
  /*# sim_rtl/lineartable.vhd:164:9 */
  always @(posedge clk)
    n6812 <= n6808;
  /*# sim_rtl/lineartable.vhd:143:9 */
  always @(posedge clk)
    n6813 <= n6788;
  /*# sim_rtl/lineartable.vhd:143:9 */
  always @(posedge clk)
    n6814 <= n6789;
  /*# sim_rtl/lineartable.vhd:136:39 */
  reg [8:0] n6817[127:0] ; // memory
  initial begin
    n6817[127] = 9'b000000000;
    n6817[126] = 9'b000000010;
    n6817[125] = 9'b000000010;
    n6817[124] = 9'b000000010;
    n6817[123] = 9'b000000010;
    n6817[122] = 9'b000000010;
    n6817[121] = 9'b000000010;
    n6817[120] = 9'b000000010;
    n6817[119] = 9'b000000011;
    n6817[118] = 9'b000000011;
    n6817[117] = 9'b000000011;
    n6817[116] = 9'b000000011;
    n6817[115] = 9'b000000011;
    n6817[114] = 9'b000000011;
    n6817[113] = 9'b000000011;
    n6817[112] = 9'b000000100;
    n6817[111] = 9'b000000100;
    n6817[110] = 9'b000000100;
    n6817[109] = 9'b000000100;
    n6817[108] = 9'b000000100;
    n6817[107] = 9'b000000101;
    n6817[106] = 9'b000000101;
    n6817[105] = 9'b000000101;
    n6817[104] = 9'b000000101;
    n6817[103] = 9'b000000101;
    n6817[102] = 9'b000000110;
    n6817[101] = 9'b000000110;
    n6817[100] = 9'b000000110;
    n6817[99] = 9'b000000111;
    n6817[98] = 9'b000000111;
    n6817[97] = 9'b000000111;
    n6817[96] = 9'b000001000;
    n6817[95] = 9'b000001000;
    n6817[94] = 9'b000001000;
    n6817[93] = 9'b000001001;
    n6817[92] = 9'b000001001;
    n6817[91] = 9'b000001010;
    n6817[90] = 9'b000001010;
    n6817[89] = 9'b000001010;
    n6817[88] = 9'b000001011;
    n6817[87] = 9'b000001011;
    n6817[86] = 9'b000001100;
    n6817[85] = 9'b000001101;
    n6817[84] = 9'b000001101;
    n6817[83] = 9'b000001110;
    n6817[82] = 9'b000001110;
    n6817[81] = 9'b000001111;
    n6817[80] = 9'b000010000;
    n6817[79] = 9'b000010000;
    n6817[78] = 9'b000010001;
    n6817[77] = 9'b000010010;
    n6817[76] = 9'b000010011;
    n6817[75] = 9'b000010100;
    n6817[74] = 9'b000010100;
    n6817[73] = 9'b000010101;
    n6817[72] = 9'b000010110;
    n6817[71] = 9'b000010111;
    n6817[70] = 9'b000011000;
    n6817[69] = 9'b000011001;
    n6817[68] = 9'b000011011;
    n6817[67] = 9'b000011100;
    n6817[66] = 9'b000011101;
    n6817[65] = 9'b000011110;
    n6817[64] = 9'b000100000;
    n6817[63] = 9'b000100001;
    n6817[62] = 9'b000100011;
    n6817[61] = 9'b000100100;
    n6817[60] = 9'b000100110;
    n6817[59] = 9'b000101000;
    n6817[58] = 9'b000101001;
    n6817[57] = 9'b000101011;
    n6817[56] = 9'b000101101;
    n6817[55] = 9'b000101111;
    n6817[54] = 9'b000110001;
    n6817[53] = 9'b000110011;
    n6817[52] = 9'b000110110;
    n6817[51] = 9'b000111000;
    n6817[50] = 9'b000111011;
    n6817[49] = 9'b000111101;
    n6817[48] = 9'b001000000;
    n6817[47] = 9'b001000011;
    n6817[46] = 9'b001000110;
    n6817[45] = 9'b001001001;
    n6817[44] = 9'b001001100;
    n6817[43] = 9'b001001111;
    n6817[42] = 9'b001010011;
    n6817[41] = 9'b001010111;
    n6817[40] = 9'b001011010;
    n6817[39] = 9'b001011110;
    n6817[38] = 9'b001100011;
    n6817[37] = 9'b001100111;
    n6817[36] = 9'b001101011;
    n6817[35] = 9'b001110000;
    n6817[34] = 9'b001110101;
    n6817[33] = 9'b001111010;
    n6817[32] = 9'b010000000;
    n6817[31] = 9'b010000110;
    n6817[30] = 9'b010001011;
    n6817[29] = 9'b010010010;
    n6817[28] = 9'b010011000;
    n6817[27] = 9'b010011111;
    n6817[26] = 9'b010100110;
    n6817[25] = 9'b010101101;
    n6817[24] = 9'b010110101;
    n6817[23] = 9'b010111101;
    n6817[22] = 9'b011000101;
    n6817[21] = 9'b011001110;
    n6817[20] = 9'b011010111;
    n6817[19] = 9'b011100000;
    n6817[18] = 9'b011101010;
    n6817[17] = 9'b011110101;
    n6817[16] = 9'b100000000;
    n6817[15] = 9'b100001011;
    n6817[14] = 9'b100010111;
    n6817[13] = 9'b100100011;
    n6817[12] = 9'b100110000;
    n6817[11] = 9'b100111101;
    n6817[10] = 9'b101001011;
    n6817[9] = 9'b101011010;
    n6817[8] = 9'b101101001;
    n6817[7] = 9'b101111001;
    n6817[6] = 9'b110001010;
    n6817[5] = 9'b110011011;
    n6817[4] = 9'b110101101;
    n6817[3] = 9'b111000000;
    n6817[2] = 9'b111010100;
    n6817[1] = 9'b111101001;
    n6817[0] = 9'b111111111;
    end
  always @(posedge clk)
    if (1'b1)
      n6820 <= n6817[w_addr1];
  always @(posedge clk)
    if (1'b1)
      n6822 <= n6817[n6770];
  /*# sim_rtl/lineartable.vhd:137:39 */
  /*# sim_rtl/lineartable.vhd:137:37 */
endmodule

module outputmemory_Brtl
  (input  clk,
   input  reset,
   input  wr,
   input  [4:0] addr,
   input  \wdata[sign] ,
   input  [8:0] \wdata[value] ,
   output \rdata[sign] ,
   output [8:0] \rdata[value] ,
   input  [4:0] addr2,
   output \rdata2[sign] ,
   output [8:0] \rdata2[value] ,
   input  ss_hold,
   input  [7:0] ss_addr,
   input  ss_read,
   input  ss_write,
   input  [31:0] ss_wdata,
   output [31:0] ss_rdata,
   output ss_initialized);
  wire [9:0] n6329;
  wire n6331;
  wire [8:0] n6332;
  wire n6334;
  wire [8:0] n6335;
  (* ramstyle="MLAB" *) wire [189:0] data_array;
  reg [31:0] ss_local_data;
  wire ss_mem_active;
  wire [4:0] ss_mem_index;
  reg ss_mem_ready;
  wire [9:0] ss_mem_vector;
  reg [4:0] n6340_init_ch;
  wire [31:0] n6344;
  wire n6346;
  wire n6349;
  wire n6351;
  wire [31:0] n6352;
  wire n6354;
  wire [4:0] n6356;
  wire [31:0] n6360;
  wire [31:0] n6362;
  wire [4:0] n6363;
  wire [4:0] n6366;
  wire n6373;
  wire [8:0] n6374;
  wire [9:0] n6375;
  wire [189:0] n6377;
  wire [189:0] n6378;
  wire n6380;
  wire [4:0] n6382;
  wire [9:0] n6384;
  wire [189:0] n6386;
  wire [189:0] n6387;
  wire n6388;
  wire [4:0] n6391;
  wire n6398;
  wire [8:0] n6399;
  wire [9:0] n6400;
  wire [4:0] n6404;
  wire n6411;
  wire [8:0] n6412;
  wire [9:0] n6413;
  wire [9:0] n6414;
  wire [4:0] n6418;
  wire n6425;
  wire [8:0] n6426;
  wire [9:0] n6427;
  wire [31:0] n6442;
  wire n6444;
  wire n6445;
  wire [31:0] n6446;
  wire n6448;
  wire n6449;
  wire n6450;
  wire [31:0] n6452;
  wire [31:0] n6454;
  wire [4:0] n6455;
  wire [31:0] n6456;
  wire n6458;
  wire [31:0] n6459;
  wire n6461;
  wire n6462;
  wire [4:0] n6463;
  wire n6470;
  wire [8:0] n6471;
  wire [9:0] n6472;
  wire [31:0] n6474;
  wire [31:0] n6475;
  wire n6477;
  wire [9:0] n6478;
  reg [9:0] n6479;
  wire n6480;
  wire [9:0] n6481;
  reg [9:0] n6482;
  wire n6483;
  wire [189:0] n6484;
  reg [189:0] n6485;
  reg n6486;
  wire [4:0] n6487;
  reg [4:0] n6488;
  wire n6489;
  wire n6490;
  wire n6491;
  wire n6492;
  wire n6493;
  wire n6494;
  wire n6495;
  wire n6496;
  wire n6497;
  wire n6498;
  wire n6499;
  wire n6500;
  wire n6501;
  wire n6502;
  wire n6503;
  wire n6504;
  wire n6505;
  wire n6506;
  wire n6507;
  wire n6508;
  wire n6509;
  wire n6510;
  wire n6511;
  wire n6512;
  wire n6513;
  wire n6514;
  wire n6515;
  wire n6516;
  wire n6517;
  wire n6518;
  wire n6519;
  wire n6520;
  wire n6521;
  wire n6522;
  wire n6523;
  wire n6524;
  wire n6525;
  wire n6526;
  wire n6527;
  wire n6528;
  wire n6529;
  wire n6530;
  wire n6531;
  wire n6532;
  wire n6533;
  wire n6534;
  wire n6535;
  wire [9:0] n6536;
  wire [9:0] n6537;
  wire [9:0] n6538;
  wire [9:0] n6539;
  wire [9:0] n6540;
  wire [9:0] n6541;
  wire [9:0] n6542;
  wire [9:0] n6543;
  wire [9:0] n6544;
  wire [9:0] n6545;
  wire [9:0] n6546;
  wire [9:0] n6547;
  wire [9:0] n6548;
  wire [9:0] n6549;
  wire [9:0] n6550;
  wire [9:0] n6551;
  wire [9:0] n6552;
  wire [9:0] n6553;
  wire [9:0] n6554;
  wire [9:0] n6555;
  wire [9:0] n6556;
  wire [9:0] n6557;
  wire [9:0] n6558;
  wire [9:0] n6559;
  wire [9:0] n6560;
  wire [9:0] n6561;
  wire [9:0] n6562;
  wire [9:0] n6563;
  wire [9:0] n6564;
  wire [9:0] n6565;
  wire [9:0] n6566;
  wire [9:0] n6567;
  wire [9:0] n6568;
  wire [9:0] n6569;
  wire [9:0] n6570;
  wire [9:0] n6571;
  wire [9:0] n6572;
  wire [9:0] n6573;
  wire [189:0] n6574;
  wire n6575;
  wire n6576;
  wire n6577;
  wire n6578;
  wire n6579;
  wire n6580;
  wire n6581;
  wire n6582;
  wire n6583;
  wire n6584;
  wire n6585;
  wire n6586;
  wire n6587;
  wire n6588;
  wire n6589;
  wire n6590;
  wire n6591;
  wire n6592;
  wire n6593;
  wire n6594;
  wire n6595;
  wire n6596;
  wire n6597;
  wire n6598;
  wire n6599;
  wire n6600;
  wire n6601;
  wire n6602;
  wire n6603;
  wire n6604;
  wire n6605;
  wire n6606;
  wire n6607;
  wire n6608;
  wire n6609;
  wire n6610;
  wire n6611;
  wire n6612;
  wire n6613;
  wire n6614;
  wire n6615;
  wire n6616;
  wire n6617;
  wire n6618;
  wire n6619;
  wire n6620;
  wire n6621;
  wire [9:0] n6622;
  wire [9:0] n6623;
  wire [9:0] n6624;
  wire [9:0] n6625;
  wire [9:0] n6626;
  wire [9:0] n6627;
  wire [9:0] n6628;
  wire [9:0] n6629;
  wire [9:0] n6630;
  wire [9:0] n6631;
  wire [9:0] n6632;
  wire [9:0] n6633;
  wire [9:0] n6634;
  wire [9:0] n6635;
  wire [9:0] n6636;
  wire [9:0] n6637;
  wire [9:0] n6638;
  wire [9:0] n6639;
  wire [9:0] n6640;
  wire [9:0] n6641;
  wire [9:0] n6642;
  wire [9:0] n6643;
  wire [9:0] n6644;
  wire [9:0] n6645;
  wire [9:0] n6646;
  wire [9:0] n6647;
  wire [9:0] n6648;
  wire [9:0] n6649;
  wire [9:0] n6650;
  wire [9:0] n6651;
  wire [9:0] n6652;
  wire [9:0] n6653;
  wire [9:0] n6654;
  wire [9:0] n6655;
  wire [9:0] n6656;
  wire [9:0] n6657;
  wire [9:0] n6658;
  wire [9:0] n6659;
  wire [189:0] n6660;
  wire n6661;
  wire n6662;
  wire n6663;
  wire n6664;
  wire n6665;
  wire n6666;
  wire n6667;
  wire n6668;
  wire n6669;
  wire n6670;
  wire n6671;
  wire n6672;
  wire n6673;
  wire n6674;
  wire n6675;
  wire n6676;
  wire n6677;
  wire n6678;
  wire n6679;
  wire n6680;
  wire n6681;
  wire n6682;
  wire n6683;
  wire n6684;
  wire n6685;
  wire n6686;
  wire n6687;
  wire n6688;
  wire n6689;
  wire n6690;
  wire n6691;
  wire n6692;
  wire n6693;
  wire n6694;
  wire n6695;
  wire n6696;
  wire n6697;
  wire n6698;
  wire n6699;
  wire n6700;
  wire n6701;
  wire n6702;
  wire n6703;
  wire n6704;
  wire n6705;
  wire n6706;
  wire n6707;
  wire [9:0] n6708;
  wire [9:0] n6709;
  wire [9:0] n6710;
  wire [9:0] n6711;
  wire [9:0] n6712;
  wire [9:0] n6713;
  wire [9:0] n6714;
  wire [9:0] n6715;
  wire [9:0] n6716;
  wire [9:0] n6717;
  wire [9:0] n6718;
  wire [9:0] n6719;
  wire [9:0] n6720;
  wire [9:0] n6721;
  wire [9:0] n6722;
  wire [9:0] n6723;
  wire [9:0] n6724;
  wire [9:0] n6725;
  wire [9:0] n6726;
  wire [9:0] n6727;
  wire [9:0] n6728;
  wire [9:0] n6729;
  wire [9:0] n6730;
  wire [9:0] n6731;
  wire [9:0] n6732;
  wire [9:0] n6733;
  wire [9:0] n6734;
  wire [9:0] n6735;
  wire [9:0] n6736;
  wire [9:0] n6737;
  wire [9:0] n6738;
  wire [9:0] n6739;
  wire [9:0] n6740;
  wire [9:0] n6741;
  wire [9:0] n6742;
  wire [9:0] n6743;
  wire [9:0] n6744;
  wire [9:0] n6745;
  wire [189:0] n6746;
  wire [319:0] n6748;
  wire [9:0] n6749;
  wire [319:0] n6751;
  wire [9:0] n6752;
  wire [319:0] n6754;
  wire [9:0] n6755;
  assign \rdata[sign]  = n6331; //(module output)
  assign \rdata[value]  = n6332; //(module output)
  assign \rdata2[sign]  = n6334; //(module output)
  assign \rdata2[value]  = n6335; //(module output)
  assign ss_rdata = ss_local_data; //(module output)
  assign ss_initialized = ss_mem_ready; //(module output)
  /*# sim_rtl/outputmemory.vhd:37:8 */
  assign n6329 = {\wdata[value] , \wdata[sign] };
  /*# sim_rtl/outputmemory.vhd:37:8 */
  assign n6331 = n6479[0]; // extract
  /*# sim_rtl/outputmemory.vhd:37:8 */
  assign n6332 = n6479[9:1]; // extract
  /*# sim_rtl/outputmemory.vhd:37:8 */
  assign n6334 = n6482[0]; // extract
  /*# sim_rtl/outputmemory.vhd:37:8 */
  assign n6335 = n6482[9:1]; // extract
  /*# sim_rtl/outputmemory.vhd:61:10 */
  assign data_array = n6485; // (signal)
  /*# sim_rtl/outputmemory.vhd:65:12 */
  always @*
    ss_local_data = n6475; // (isignal)
  initial
    ss_local_data = 32'b00000000000000000000000000000000;
  /*# sim_rtl/outputmemory.vhd:66:12 */
  assign ss_mem_active = n6450; // (signal)
  /*# sim_rtl/outputmemory.vhd:67:12 */
  assign ss_mem_index = n6463; // (signal)
  /*# sim_rtl/outputmemory.vhd:68:12 */
  always @*
    ss_mem_ready = n6486; // (isignal)
  initial
    ss_mem_ready = 1'b0;
  /*# sim_rtl/outputmemory.vhd:69:12 */
  assign ss_mem_vector = n6472; // (signal)
  /*# sim_rtl/outputmemory.vhd:75:14 */
  always @*
    n6340_init_ch = n6488; // (isignal)
  initial
    n6340_init_ch = 5'b00000;
  /*# sim_rtl/outputmemory.vhd:86:38 */
  assign n6344 = {27'b0, n6340_init_ch};  // uext
  /*# sim_rtl/outputmemory.vhd:86:38 */
  assign n6346 = n6344 == 32'b00000000000000000000000000010010;
  /*# sim_rtl/outputmemory.vhd:86:28 */
  assign n6349 = n6346 ? 1'b1 : 1'b0;
  /*# sim_rtl/outputmemory.vhd:87:11 */
  assign n6351 = ~ss_hold;
  /*# sim_rtl/outputmemory.vhd:88:12 */
  assign n6352 = {27'b0, n6340_init_ch};  // uext
  /*# sim_rtl/outputmemory.vhd:88:12 */
  assign n6354 = n6352 != 32'b00000000000000000000000000010010;
  /*# sim_rtl/outputmemory.vhd:90:20 */
  assign n6356 = 5'b10010 - n6340_init_ch;
  /*# sim_rtl/outputmemory.vhd:91:28 */
  assign n6360 = {27'b0, n6340_init_ch};  // uext
  /*# sim_rtl/outputmemory.vhd:91:28 */
  assign n6362 = n6360 + 32'b00000000000000000000000000000001;
  /*# sim_rtl/outputmemory.vhd:91:9 */
  assign n6363 = n6362[4:0];  // trunc
  /*# sim_rtl/outputmemory.vhd:95:20 */
  assign n6366 = 5'b10010 - addr;
  /*# sim_rtl/vm2413.vhd:195:15 */
  assign n6373 = n6329[0]; // extract
  /*# sim_rtl/vm2413.vhd:195:25 */
  assign n6374 = n6329[9:1]; // extract
  /*# sim_rtl/vm2413.vhd:195:20 */
  assign n6375 = {n6373, n6374};
  /*# sim_rtl/outputmemory.vhd:93:7 */
  assign n6377 = wr ? n6660 : data_array;
  /*# sim_rtl/outputmemory.vhd:88:1 */
  assign n6378 = n6354 ? n6574 : n6377;
  /*# sim_rtl/outputmemory.vhd:100:20 */
  assign n6380 = ss_mem_active & ss_write;
  /*# sim_rtl/outputmemory.vhd:101:12 */
  assign n6382 = 5'b10010 - ss_mem_index;
  /*# sim_rtl/outputmemory.vhd:101:35 */
  assign n6384 = ss_wdata[9:0]; // extract
  /*# sim_rtl/outputmemory.vhd:100:1 */
  assign n6386 = n6380 ? n6746 : data_array;
  /*# sim_rtl/outputmemory.vhd:87:1 */
  assign n6387 = n6351 ? n6378 : n6386;
  /*# sim_rtl/outputmemory.vhd:87:1 */
  assign n6388 = n6354 & n6351;
  /*# sim_rtl/outputmemory.vhd:103:62 */
  assign n6391 = 5'b10010 - ss_mem_index;
  /*# sim_rtl/vm2413.vhd:200:25 */
  assign n6398 = n6749[9]; // extract
  /*# sim_rtl/vm2413.vhd:200:47 */
  assign n6399 = n6749[8:0]; // extract
  /*# sim_rtl/vm2413.vhd:200:12 */
  assign n6400 = {n6399, n6398};
  /*# sim_rtl/outputmemory.vhd:103:118 */
  assign n6404 = 5'b10010 - addr;
  /*# sim_rtl/vm2413.vhd:200:25 */
  assign n6411 = n6752[9]; // extract
  /*# sim_rtl/vm2413.vhd:200:47 */
  assign n6412 = n6752[8:0]; // extract
  /*# sim_rtl/vm2413.vhd:200:12 */
  assign n6413 = {n6412, n6411};
  /*# sim_rtl/outputmemory.vhd:103:1 */
  assign n6414 = ss_mem_active ? n6400 : n6413;
  /*# sim_rtl/outputmemory.vhd:104:43 */
  assign n6418 = 5'b10010 - addr2;
  /*# sim_rtl/vm2413.vhd:200:25 */
  assign n6425 = n6755[9]; // extract
  /*# sim_rtl/vm2413.vhd:200:47 */
  assign n6426 = n6755[8:0]; // extract
  /*# sim_rtl/vm2413.vhd:200:12 */
  assign n6427 = {n6426, n6425};
  /*# sim_rtl/outputmemory.vhd:109:43 */
  assign n6442 = {24'b0, ss_addr};  // uext
  /*# sim_rtl/outputmemory.vhd:109:64 */
  assign n6444 = $signed(n6442) >= $signed(32'b00000000000000000000000000111010);
  /*# sim_rtl/outputmemory.vhd:109:39 */
  assign n6445 = n6444 & ss_hold;
  /*# sim_rtl/outputmemory.vhd:109:73 */
  assign n6446 = {24'b0, ss_addr};  // uext
  /*# sim_rtl/outputmemory.vhd:109:94 */
  assign n6448 = $signed(n6446) <= $signed(32'b00000000000000000000000001001011);
  /*# sim_rtl/outputmemory.vhd:109:69 */
  assign n6449 = n6448 & n6445;
  /*# sim_rtl/outputmemory.vhd:109:22 */
  assign n6450 = n6449 ? 1'b1 : 1'b0;
  /*# sim_rtl/outputmemory.vhd:110:17 */
  assign n6452 = {24'b0, ss_addr};  // uext
  /*# sim_rtl/outputmemory.vhd:110:38 */
  assign n6454 = n6452 - 32'b00000000000000000000000000111010;
  /*# sim_rtl/outputmemory.vhd:110:17 */
  assign n6455 = n6454[4:0];  // trunc
  /*# sim_rtl/outputmemory.vhd:110:47 */
  assign n6456 = {24'b0, ss_addr};  // uext
  /*# sim_rtl/outputmemory.vhd:110:68 */
  assign n6458 = $signed(n6456) >= $signed(32'b00000000000000000000000000111010);
  /*# sim_rtl/outputmemory.vhd:110:77 */
  assign n6459 = {24'b0, ss_addr};  // uext
  /*# sim_rtl/outputmemory.vhd:110:98 */
  assign n6461 = $signed(n6459) <= $signed(32'b00000000000000000000000001001011);
  /*# sim_rtl/outputmemory.vhd:110:73 */
  assign n6462 = n6461 & n6458;
  /*# sim_rtl/outputmemory.vhd:110:42 */
  assign n6463 = n6462 ? n6455 : 5'b00000;
  /*# sim_rtl/vm2413.vhd:195:15 */
  assign n6470 = n6479[0]; // extract
  /*# sim_rtl/vm2413.vhd:195:25 */
  assign n6471 = n6479[9:1]; // extract
  /*# sim_rtl/vm2413.vhd:195:20 */
  assign n6472 = {n6470, n6471};
  /*# sim_rtl/outputmemory.vhd:112:39 */
  assign n6474 = {22'b0000000000000000000000, ss_mem_vector};
  /*# sim_rtl/outputmemory.vhd:112:55 */
  assign n6475 = ss_mem_active ? n6474 : 32'b00000000000000000000000000000000;
  /*# sim_rtl/outputmemory.vhd:43:3 */
  assign n6477 = ~reset;
  /*# sim_rtl/outputmemory.vhd:84:5 */
  assign n6478 = n6477 ? n6414 : n6479;
  /*# sim_rtl/outputmemory.vhd:84:5 */
  always @(posedge clk)
    n6479 <= n6478;
  /*# sim_rtl/outputmemory.vhd:45:3 */
  assign n6480 = ~reset;
  /*# sim_rtl/outputmemory.vhd:84:5 */
  assign n6481 = n6480 ? n6427 : n6482;
  /*# sim_rtl/outputmemory.vhd:84:5 */
  always @(posedge clk)
    n6482 <= n6481;
  /*# sim_rtl/outputmemory.vhd:61:10 */
  assign n6483 = ~reset;
  /*# sim_rtl/outputmemory.vhd:84:5 */
  assign n6484 = n6483 ? n6387 : data_array;
  /*# sim_rtl/outputmemory.vhd:84:5 */
  always @(posedge clk)
    n6485 <= n6484;
  /*# sim_rtl/outputmemory.vhd:84:5 */
  always @(posedge clk or posedge reset)
    if (reset)
      n6486 <= 1'b0;
    else
      n6486 <= n6349;
  /*# sim_rtl/outputmemory.vhd:84:5 */
  assign n6487 = n6388 ? n6363 : n6340_init_ch;
  /*# sim_rtl/outputmemory.vhd:84:5 */
  always @(posedge clk or posedge reset)
    if (reset)
      n6488 <= 5'b00000;
    else
      n6488 <= n6487;
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6489 = n6356[4]; // extract
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6490 = ~n6489;
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6491 = n6356[3]; // extract
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6492 = ~n6491;
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6493 = n6490 & n6492;
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6494 = n6490 & n6491;
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6495 = n6489 & n6492;
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6496 = n6356[2]; // extract
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6497 = ~n6496;
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6498 = n6493 & n6497;
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6499 = n6493 & n6496;
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6500 = n6494 & n6497;
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6501 = n6494 & n6496;
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6502 = n6495 & n6497;
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6503 = n6356[1]; // extract
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6504 = ~n6503;
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6505 = n6498 & n6504;
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6506 = n6498 & n6503;
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6507 = n6499 & n6504;
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6508 = n6499 & n6503;
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6509 = n6500 & n6504;
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6510 = n6500 & n6503;
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6511 = n6501 & n6504;
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6512 = n6501 & n6503;
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6513 = n6502 & n6504;
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6514 = n6502 & n6503;
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6515 = n6356[0]; // extract
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6516 = ~n6515;
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6517 = n6505 & n6516;
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6518 = n6505 & n6515;
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6519 = n6506 & n6516;
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6520 = n6506 & n6515;
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6521 = n6507 & n6516;
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6522 = n6507 & n6515;
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6523 = n6508 & n6516;
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6524 = n6508 & n6515;
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6525 = n6509 & n6516;
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6526 = n6509 & n6515;
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6527 = n6510 & n6516;
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6528 = n6510 & n6515;
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6529 = n6511 & n6516;
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6530 = n6511 & n6515;
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6531 = n6512 & n6516;
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6532 = n6512 & n6515;
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6533 = n6513 & n6516;
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6534 = n6513 & n6515;
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6535 = n6514 & n6516;
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6536 = data_array[9:0]; // extract
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6537 = n6517 ? 10'b0000000000 : n6536;
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6538 = data_array[19:10]; // extract
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6539 = n6518 ? 10'b0000000000 : n6538;
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6540 = data_array[29:20]; // extract
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6541 = n6519 ? 10'b0000000000 : n6540;
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6542 = data_array[39:30]; // extract
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6543 = n6520 ? 10'b0000000000 : n6542;
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6544 = data_array[49:40]; // extract
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6545 = n6521 ? 10'b0000000000 : n6544;
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6546 = data_array[59:50]; // extract
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6547 = n6522 ? 10'b0000000000 : n6546;
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6548 = data_array[69:60]; // extract
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6549 = n6523 ? 10'b0000000000 : n6548;
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6550 = data_array[79:70]; // extract
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6551 = n6524 ? 10'b0000000000 : n6550;
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6552 = data_array[89:80]; // extract
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6553 = n6525 ? 10'b0000000000 : n6552;
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6554 = data_array[99:90]; // extract
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6555 = n6526 ? 10'b0000000000 : n6554;
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6556 = data_array[109:100]; // extract
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6557 = n6527 ? 10'b0000000000 : n6556;
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6558 = data_array[119:110]; // extract
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6559 = n6528 ? 10'b0000000000 : n6558;
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6560 = data_array[129:120]; // extract
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6561 = n6529 ? 10'b0000000000 : n6560;
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6562 = data_array[139:130]; // extract
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6563 = n6530 ? 10'b0000000000 : n6562;
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6564 = data_array[149:140]; // extract
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6565 = n6531 ? 10'b0000000000 : n6564;
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6566 = data_array[159:150]; // extract
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6567 = n6532 ? 10'b0000000000 : n6566;
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6568 = data_array[169:160]; // extract
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6569 = n6533 ? 10'b0000000000 : n6568;
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6570 = data_array[179:170]; // extract
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6571 = n6534 ? 10'b0000000000 : n6570;
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6572 = data_array[189:180]; // extract
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6573 = n6535 ? 10'b0000000000 : n6572;
  /*# sim_rtl/outputmemory.vhd:90:9 */
  assign n6574 = {n6573, n6571, n6569, n6567, n6565, n6563, n6561, n6559, n6557, n6555, n6553, n6551, n6549, n6547, n6545, n6543, n6541, n6539, n6537};
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6575 = n6366[4]; // extract
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6576 = ~n6575;
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6577 = n6366[3]; // extract
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6578 = ~n6577;
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6579 = n6576 & n6578;
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6580 = n6576 & n6577;
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6581 = n6575 & n6578;
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6582 = n6366[2]; // extract
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6583 = ~n6582;
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6584 = n6579 & n6583;
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6585 = n6579 & n6582;
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6586 = n6580 & n6583;
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6587 = n6580 & n6582;
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6588 = n6581 & n6583;
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6589 = n6366[1]; // extract
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6590 = ~n6589;
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6591 = n6584 & n6590;
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6592 = n6584 & n6589;
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6593 = n6585 & n6590;
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6594 = n6585 & n6589;
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6595 = n6586 & n6590;
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6596 = n6586 & n6589;
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6597 = n6587 & n6590;
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6598 = n6587 & n6589;
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6599 = n6588 & n6590;
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6600 = n6588 & n6589;
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6601 = n6366[0]; // extract
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6602 = ~n6601;
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6603 = n6591 & n6602;
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6604 = n6591 & n6601;
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6605 = n6592 & n6602;
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6606 = n6592 & n6601;
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6607 = n6593 & n6602;
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6608 = n6593 & n6601;
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6609 = n6594 & n6602;
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6610 = n6594 & n6601;
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6611 = n6595 & n6602;
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6612 = n6595 & n6601;
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6613 = n6596 & n6602;
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6614 = n6596 & n6601;
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6615 = n6597 & n6602;
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6616 = n6597 & n6601;
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6617 = n6598 & n6602;
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6618 = n6598 & n6601;
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6619 = n6599 & n6602;
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6620 = n6599 & n6601;
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6621 = n6600 & n6602;
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6622 = data_array[9:0]; // extract
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6623 = n6603 ? n6375 : n6622;
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6624 = data_array[19:10]; // extract
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6625 = n6604 ? n6375 : n6624;
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6626 = data_array[29:20]; // extract
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6627 = n6605 ? n6375 : n6626;
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6628 = data_array[39:30]; // extract
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6629 = n6606 ? n6375 : n6628;
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6630 = data_array[49:40]; // extract
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6631 = n6607 ? n6375 : n6630;
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6632 = data_array[59:50]; // extract
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6633 = n6608 ? n6375 : n6632;
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6634 = data_array[69:60]; // extract
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6635 = n6609 ? n6375 : n6634;
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6636 = data_array[79:70]; // extract
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6637 = n6610 ? n6375 : n6636;
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6638 = data_array[89:80]; // extract
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6639 = n6611 ? n6375 : n6638;
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6640 = data_array[99:90]; // extract
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6641 = n6612 ? n6375 : n6640;
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6642 = data_array[109:100]; // extract
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6643 = n6613 ? n6375 : n6642;
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6644 = data_array[119:110]; // extract
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6645 = n6614 ? n6375 : n6644;
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6646 = data_array[129:120]; // extract
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6647 = n6615 ? n6375 : n6646;
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6648 = data_array[139:130]; // extract
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6649 = n6616 ? n6375 : n6648;
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6650 = data_array[149:140]; // extract
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6651 = n6617 ? n6375 : n6650;
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6652 = data_array[159:150]; // extract
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6653 = n6618 ? n6375 : n6652;
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6654 = data_array[169:160]; // extract
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6655 = n6619 ? n6375 : n6654;
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6656 = data_array[179:170]; // extract
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6657 = n6620 ? n6375 : n6656;
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6658 = data_array[189:180]; // extract
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6659 = n6621 ? n6375 : n6658;
  /*# sim_rtl/outputmemory.vhd:95:9 */
  assign n6660 = {n6659, n6657, n6655, n6653, n6651, n6649, n6647, n6645, n6643, n6641, n6639, n6637, n6635, n6633, n6631, n6629, n6627, n6625, n6623};
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6661 = n6382[4]; // extract
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6662 = ~n6661;
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6663 = n6382[3]; // extract
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6664 = ~n6663;
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6665 = n6662 & n6664;
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6666 = n6662 & n6663;
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6667 = n6661 & n6664;
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6668 = n6382[2]; // extract
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6669 = ~n6668;
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6670 = n6665 & n6669;
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6671 = n6665 & n6668;
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6672 = n6666 & n6669;
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6673 = n6666 & n6668;
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6674 = n6667 & n6669;
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6675 = n6382[1]; // extract
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6676 = ~n6675;
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6677 = n6670 & n6676;
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6678 = n6670 & n6675;
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6679 = n6671 & n6676;
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6680 = n6671 & n6675;
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6681 = n6672 & n6676;
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6682 = n6672 & n6675;
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6683 = n6673 & n6676;
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6684 = n6673 & n6675;
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6685 = n6674 & n6676;
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6686 = n6674 & n6675;
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6687 = n6382[0]; // extract
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6688 = ~n6687;
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6689 = n6677 & n6688;
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6690 = n6677 & n6687;
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6691 = n6678 & n6688;
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6692 = n6678 & n6687;
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6693 = n6679 & n6688;
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6694 = n6679 & n6687;
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6695 = n6680 & n6688;
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6696 = n6680 & n6687;
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6697 = n6681 & n6688;
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6698 = n6681 & n6687;
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6699 = n6682 & n6688;
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6700 = n6682 & n6687;
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6701 = n6683 & n6688;
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6702 = n6683 & n6687;
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6703 = n6684 & n6688;
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6704 = n6684 & n6687;
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6705 = n6685 & n6688;
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6706 = n6685 & n6687;
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6707 = n6686 & n6688;
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6708 = data_array[9:0]; // extract
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6709 = n6689 ? n6384 : n6708;
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6710 = data_array[19:10]; // extract
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6711 = n6690 ? n6384 : n6710;
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6712 = data_array[29:20]; // extract
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6713 = n6691 ? n6384 : n6712;
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6714 = data_array[39:30]; // extract
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6715 = n6692 ? n6384 : n6714;
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6716 = data_array[49:40]; // extract
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6717 = n6693 ? n6384 : n6716;
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6718 = data_array[59:50]; // extract
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6719 = n6694 ? n6384 : n6718;
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6720 = data_array[69:60]; // extract
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6721 = n6695 ? n6384 : n6720;
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6722 = data_array[79:70]; // extract
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6723 = n6696 ? n6384 : n6722;
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6724 = data_array[89:80]; // extract
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6725 = n6697 ? n6384 : n6724;
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6726 = data_array[99:90]; // extract
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6727 = n6698 ? n6384 : n6726;
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6728 = data_array[109:100]; // extract
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6729 = n6699 ? n6384 : n6728;
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6730 = data_array[119:110]; // extract
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6731 = n6700 ? n6384 : n6730;
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6732 = data_array[129:120]; // extract
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6733 = n6701 ? n6384 : n6732;
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6734 = data_array[139:130]; // extract
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6735 = n6702 ? n6384 : n6734;
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6736 = data_array[149:140]; // extract
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6737 = n6703 ? n6384 : n6736;
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6738 = data_array[159:150]; // extract
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6739 = n6704 ? n6384 : n6738;
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6740 = data_array[169:160]; // extract
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6741 = n6705 ? n6384 : n6740;
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6742 = data_array[179:170]; // extract
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6743 = n6706 ? n6384 : n6742;
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6744 = data_array[189:180]; // extract
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6745 = n6707 ? n6384 : n6744;
  /*# sim_rtl/outputmemory.vhd:101:1 */
  assign n6746 = {n6745, n6743, n6741, n6739, n6737, n6735, n6733, n6731, n6729, n6727, n6725, n6723, n6721, n6719, n6717, n6715, n6713, n6711, n6709};
  /*# sim_rtl/outputmemory.vhd:103:62 */
  assign n6748 = {130'bX, data_array};
  /*# sim_rtl/outputmemory.vhd:103:62 */
  assign n6749 = n6748[n6391 * 10 +: 10]; //(Bmux)
  /*# sim_rtl/outputmemory.vhd:103:118 */
  assign n6751 = {130'bX, data_array};
  /*# sim_rtl/outputmemory.vhd:103:118 */
  assign n6752 = n6751[n6404 * 10 +: 10]; //(Bmux)
  /*# sim_rtl/outputmemory.vhd:104:43 */
  assign n6754 = {130'bX, data_array};
  /*# sim_rtl/outputmemory.vhd:104:43 */
  assign n6755 = n6754[n6418 * 10 +: 10]; //(Bmux)
endmodule

module feedbackmemory_Brtl
  (input  clk,
   input  reset,
   input  wr,
   input  [3:0] waddr,
   input  \wdata[sign] ,
   input  [8:0] \wdata[value] ,
   input  [3:0] raddr,
   output \rdata[sign] ,
   output [8:0] \rdata[value] ,
   input  ss_hold,
   input  [7:0] ss_addr,
   input  ss_read,
   input  ss_write,
   input  [31:0] ss_wdata,
   output [31:0] ss_rdata,
   output ss_initialized);
  wire [9:0] n6054;
  wire n6056;
  wire [8:0] n6057;
  (* ramstyle="logic" *) wire [89:0] data_array;
  reg [31:0] ss_local_data;
  wire ss_mem_active;
  wire [3:0] ss_mem_index;
  reg ss_mem_ready;
  wire [9:0] ss_mem_vector;
  reg [3:0] n6062_init_ch;
  wire [31:0] n6066;
  wire n6068;
  wire n6071;
  wire n6073;
  wire [31:0] n6074;
  wire n6076;
  wire [3:0] n6078;
  wire [31:0] n6082;
  wire [31:0] n6084;
  wire [3:0] n6085;
  wire [3:0] n6087;
  wire n6094;
  wire [8:0] n6095;
  wire [9:0] n6096;
  wire [89:0] n6098;
  wire [89:0] n6099;
  wire n6101;
  wire [3:0] n6103;
  wire [9:0] n6105;
  wire [89:0] n6107;
  wire [89:0] n6108;
  wire n6109;
  wire [3:0] n6112;
  wire n6119;
  wire [8:0] n6120;
  wire [9:0] n6121;
  wire [3:0] n6124;
  wire n6131;
  wire [8:0] n6132;
  wire [9:0] n6133;
  wire [9:0] n6134;
  wire [31:0] n6147;
  wire n6149;
  wire n6150;
  wire [31:0] n6151;
  wire n6153;
  wire n6154;
  wire n6155;
  wire [31:0] n6157;
  wire [31:0] n6159;
  wire [3:0] n6160;
  wire [31:0] n6161;
  wire n6163;
  wire [31:0] n6164;
  wire n6166;
  wire n6167;
  wire [3:0] n6168;
  wire n6175;
  wire [8:0] n6176;
  wire [9:0] n6177;
  wire [31:0] n6179;
  wire [31:0] n6180;
  wire n6182;
  wire [9:0] n6183;
  reg [9:0] n6184;
  wire n6185;
  wire [89:0] n6186;
  reg [89:0] n6187;
  reg n6188;
  wire [3:0] n6189;
  reg [3:0] n6190;
  wire n6191;
  wire n6192;
  wire n6193;
  wire n6194;
  wire n6195;
  wire n6196;
  wire n6197;
  wire n6198;
  wire n6199;
  wire n6200;
  wire n6201;
  wire n6202;
  wire n6203;
  wire n6204;
  wire n6205;
  wire n6206;
  wire n6207;
  wire n6208;
  wire n6209;
  wire n6210;
  wire n6211;
  wire n6212;
  wire n6213;
  wire n6214;
  wire n6215;
  wire [9:0] n6216;
  wire [9:0] n6217;
  wire [9:0] n6218;
  wire [9:0] n6219;
  wire [9:0] n6220;
  wire [9:0] n6221;
  wire [9:0] n6222;
  wire [9:0] n6223;
  wire [9:0] n6224;
  wire [9:0] n6225;
  wire [9:0] n6226;
  wire [9:0] n6227;
  wire [9:0] n6228;
  wire [9:0] n6229;
  wire [9:0] n6230;
  wire [9:0] n6231;
  wire [9:0] n6232;
  wire [9:0] n6233;
  wire [89:0] n6234;
  wire n6235;
  wire n6236;
  wire n6237;
  wire n6238;
  wire n6239;
  wire n6240;
  wire n6241;
  wire n6242;
  wire n6243;
  wire n6244;
  wire n6245;
  wire n6246;
  wire n6247;
  wire n6248;
  wire n6249;
  wire n6250;
  wire n6251;
  wire n6252;
  wire n6253;
  wire n6254;
  wire n6255;
  wire n6256;
  wire n6257;
  wire n6258;
  wire n6259;
  wire [9:0] n6260;
  wire [9:0] n6261;
  wire [9:0] n6262;
  wire [9:0] n6263;
  wire [9:0] n6264;
  wire [9:0] n6265;
  wire [9:0] n6266;
  wire [9:0] n6267;
  wire [9:0] n6268;
  wire [9:0] n6269;
  wire [9:0] n6270;
  wire [9:0] n6271;
  wire [9:0] n6272;
  wire [9:0] n6273;
  wire [9:0] n6274;
  wire [9:0] n6275;
  wire [9:0] n6276;
  wire [9:0] n6277;
  wire [89:0] n6278;
  wire n6279;
  wire n6280;
  wire n6281;
  wire n6282;
  wire n6283;
  wire n6284;
  wire n6285;
  wire n6286;
  wire n6287;
  wire n6288;
  wire n6289;
  wire n6290;
  wire n6291;
  wire n6292;
  wire n6293;
  wire n6294;
  wire n6295;
  wire n6296;
  wire n6297;
  wire n6298;
  wire n6299;
  wire n6300;
  wire n6301;
  wire n6302;
  wire n6303;
  wire [9:0] n6304;
  wire [9:0] n6305;
  wire [9:0] n6306;
  wire [9:0] n6307;
  wire [9:0] n6308;
  wire [9:0] n6309;
  wire [9:0] n6310;
  wire [9:0] n6311;
  wire [9:0] n6312;
  wire [9:0] n6313;
  wire [9:0] n6314;
  wire [9:0] n6315;
  wire [9:0] n6316;
  wire [9:0] n6317;
  wire [9:0] n6318;
  wire [9:0] n6319;
  wire [9:0] n6320;
  wire [9:0] n6321;
  wire [89:0] n6322;
  wire [159:0] n6324;
  wire [9:0] n6325;
  wire [159:0] n6327;
  wire [9:0] n6328;
  assign \rdata[sign]  = n6056; //(module output)
  assign \rdata[value]  = n6057; //(module output)
  assign ss_rdata = ss_local_data; //(module output)
  assign ss_initialized = ss_mem_ready; //(module output)
  /*# sim_rtl/feedbackmemory.vhd:42:8 */
  assign n6054 = {\wdata[value] , \wdata[sign] };
  /*# sim_rtl/feedbackmemory.vhd:42:8 */
  assign n6056 = n6184[0]; // extract
  /*# sim_rtl/feedbackmemory.vhd:42:8 */
  assign n6057 = n6184[9:1]; // extract
  /*# sim_rtl/feedbackmemory.vhd:65:10 */
  assign data_array = n6187; // (signal)
  /*# sim_rtl/feedbackmemory.vhd:69:12 */
  always @*
    ss_local_data = n6180; // (isignal)
  initial
    ss_local_data = 32'b00000000000000000000000000000000;
  /*# sim_rtl/feedbackmemory.vhd:70:12 */
  assign ss_mem_active = n6155; // (signal)
  /*# sim_rtl/feedbackmemory.vhd:71:12 */
  assign ss_mem_index = n6168; // (signal)
  /*# sim_rtl/feedbackmemory.vhd:72:12 */
  always @*
    ss_mem_ready = n6188; // (isignal)
  initial
    ss_mem_ready = 1'b0;
  /*# sim_rtl/feedbackmemory.vhd:73:12 */
  assign ss_mem_vector = n6177; // (signal)
  /*# sim_rtl/feedbackmemory.vhd:79:14 */
  always @*
    n6062_init_ch = n6190; // (isignal)
  initial
    n6062_init_ch = 4'b0000;
  /*# sim_rtl/feedbackmemory.vhd:90:38 */
  assign n6066 = {28'b0, n6062_init_ch};  // uext
  /*# sim_rtl/feedbackmemory.vhd:90:38 */
  assign n6068 = n6066 == 32'b00000000000000000000000000001001;
  /*# sim_rtl/feedbackmemory.vhd:90:28 */
  assign n6071 = n6068 ? 1'b1 : 1'b0;
  /*# sim_rtl/feedbackmemory.vhd:91:11 */
  assign n6073 = ~ss_hold;
  /*# sim_rtl/feedbackmemory.vhd:92:12 */
  assign n6074 = {28'b0, n6062_init_ch};  // uext
  /*# sim_rtl/feedbackmemory.vhd:92:12 */
  assign n6076 = n6074 != 32'b00000000000000000000000000001001;
  /*# sim_rtl/feedbackmemory.vhd:94:20 */
  assign n6078 = 4'b1000 - n6062_init_ch;
  /*# sim_rtl/feedbackmemory.vhd:95:28 */
  assign n6082 = {28'b0, n6062_init_ch};  // uext
  /*# sim_rtl/feedbackmemory.vhd:95:28 */
  assign n6084 = n6082 + 32'b00000000000000000000000000000001;
  /*# sim_rtl/feedbackmemory.vhd:95:9 */
  assign n6085 = n6084[3:0];  // trunc
  /*# sim_rtl/feedbackmemory.vhd:99:20 */
  assign n6087 = 4'b1000 - waddr;
  /*# sim_rtl/vm2413.vhd:195:15 */
  assign n6094 = n6054[0]; // extract
  /*# sim_rtl/vm2413.vhd:195:25 */
  assign n6095 = n6054[9:1]; // extract
  /*# sim_rtl/vm2413.vhd:195:20 */
  assign n6096 = {n6094, n6095};
  /*# sim_rtl/feedbackmemory.vhd:97:7 */
  assign n6098 = wr ? n6278 : data_array;
  /*# sim_rtl/feedbackmemory.vhd:92:1 */
  assign n6099 = n6076 ? n6234 : n6098;
  /*# sim_rtl/feedbackmemory.vhd:104:20 */
  assign n6101 = ss_mem_active & ss_write;
  /*# sim_rtl/feedbackmemory.vhd:105:12 */
  assign n6103 = 4'b1000 - ss_mem_index;
  /*# sim_rtl/feedbackmemory.vhd:105:35 */
  assign n6105 = ss_wdata[9:0]; // extract
  /*# sim_rtl/feedbackmemory.vhd:104:1 */
  assign n6107 = n6101 ? n6322 : data_array;
  /*# sim_rtl/feedbackmemory.vhd:91:1 */
  assign n6108 = n6073 ? n6099 : n6107;
  /*# sim_rtl/feedbackmemory.vhd:91:1 */
  assign n6109 = n6076 & n6073;
  /*# sim_rtl/feedbackmemory.vhd:107:62 */
  assign n6112 = 4'b1000 - ss_mem_index;
  /*# sim_rtl/vm2413.vhd:200:25 */
  assign n6119 = n6325[9]; // extract
  /*# sim_rtl/vm2413.vhd:200:47 */
  assign n6120 = n6325[8:0]; // extract
  /*# sim_rtl/vm2413.vhd:200:12 */
  assign n6121 = {n6120, n6119};
  /*# sim_rtl/feedbackmemory.vhd:107:118 */
  assign n6124 = 4'b1000 - raddr;
  /*# sim_rtl/vm2413.vhd:200:25 */
  assign n6131 = n6328[9]; // extract
  /*# sim_rtl/vm2413.vhd:200:47 */
  assign n6132 = n6328[8:0]; // extract
  /*# sim_rtl/vm2413.vhd:200:12 */
  assign n6133 = {n6132, n6131};
  /*# sim_rtl/feedbackmemory.vhd:107:1 */
  assign n6134 = ss_mem_active ? n6121 : n6133;
  /*# sim_rtl/feedbackmemory.vhd:112:43 */
  assign n6147 = {24'b0, ss_addr};  // uext
  /*# sim_rtl/feedbackmemory.vhd:112:64 */
  assign n6149 = $signed(n6147) >= $signed(32'b00000000000000000000000000110001);
  /*# sim_rtl/feedbackmemory.vhd:112:39 */
  assign n6150 = n6149 & ss_hold;
  /*# sim_rtl/feedbackmemory.vhd:112:73 */
  assign n6151 = {24'b0, ss_addr};  // uext
  /*# sim_rtl/feedbackmemory.vhd:112:94 */
  assign n6153 = $signed(n6151) <= $signed(32'b00000000000000000000000000111001);
  /*# sim_rtl/feedbackmemory.vhd:112:69 */
  assign n6154 = n6153 & n6150;
  /*# sim_rtl/feedbackmemory.vhd:112:22 */
  assign n6155 = n6154 ? 1'b1 : 1'b0;
  /*# sim_rtl/feedbackmemory.vhd:113:17 */
  assign n6157 = {24'b0, ss_addr};  // uext
  /*# sim_rtl/feedbackmemory.vhd:113:38 */
  assign n6159 = n6157 - 32'b00000000000000000000000000110001;
  /*# sim_rtl/feedbackmemory.vhd:113:17 */
  assign n6160 = n6159[3:0];  // trunc
  /*# sim_rtl/feedbackmemory.vhd:113:47 */
  assign n6161 = {24'b0, ss_addr};  // uext
  /*# sim_rtl/feedbackmemory.vhd:113:68 */
  assign n6163 = $signed(n6161) >= $signed(32'b00000000000000000000000000110001);
  /*# sim_rtl/feedbackmemory.vhd:113:77 */
  assign n6164 = {24'b0, ss_addr};  // uext
  /*# sim_rtl/feedbackmemory.vhd:113:98 */
  assign n6166 = $signed(n6164) <= $signed(32'b00000000000000000000000000111001);
  /*# sim_rtl/feedbackmemory.vhd:113:73 */
  assign n6167 = n6166 & n6163;
  /*# sim_rtl/feedbackmemory.vhd:113:42 */
  assign n6168 = n6167 ? n6160 : 4'b0000;
  /*# sim_rtl/vm2413.vhd:195:15 */
  assign n6175 = n6184[0]; // extract
  /*# sim_rtl/vm2413.vhd:195:25 */
  assign n6176 = n6184[9:1]; // extract
  /*# sim_rtl/vm2413.vhd:195:20 */
  assign n6177 = {n6175, n6176};
  /*# sim_rtl/feedbackmemory.vhd:115:39 */
  assign n6179 = {22'b0000000000000000000000, ss_mem_vector};
  /*# sim_rtl/feedbackmemory.vhd:115:55 */
  assign n6180 = ss_mem_active ? n6179 : 32'b00000000000000000000000000000000;
  /*# sim_rtl/feedbackmemory.vhd:49:3 */
  assign n6182 = ~reset;
  /*# sim_rtl/feedbackmemory.vhd:88:5 */
  assign n6183 = n6182 ? n6134 : n6184;
  /*# sim_rtl/feedbackmemory.vhd:88:5 */
  always @(posedge clk)
    n6184 <= n6183;
  /*# sim_rtl/feedbackmemory.vhd:65:10 */
  assign n6185 = ~reset;
  /*# sim_rtl/feedbackmemory.vhd:88:5 */
  assign n6186 = n6185 ? n6108 : data_array;
  /*# sim_rtl/feedbackmemory.vhd:88:5 */
  always @(posedge clk)
    n6187 <= n6186;
  /*# sim_rtl/feedbackmemory.vhd:88:5 */
  always @(posedge clk or posedge reset)
    if (reset)
      n6188 <= 1'b0;
    else
      n6188 <= n6071;
  /*# sim_rtl/feedbackmemory.vhd:88:5 */
  assign n6189 = n6109 ? n6085 : n6062_init_ch;
  /*# sim_rtl/feedbackmemory.vhd:88:5 */
  always @(posedge clk or posedge reset)
    if (reset)
      n6190 <= 4'b0000;
    else
      n6190 <= n6189;
  /*# sim_rtl/feedbackmemory.vhd:94:9 */
  assign n6191 = n6078[3]; // extract
  /*# sim_rtl/feedbackmemory.vhd:94:9 */
  assign n6192 = ~n6191;
  /*# sim_rtl/feedbackmemory.vhd:94:9 */
  assign n6193 = n6078[2]; // extract
  /*# sim_rtl/feedbackmemory.vhd:94:9 */
  assign n6194 = ~n6193;
  /*# sim_rtl/feedbackmemory.vhd:94:9 */
  assign n6195 = n6192 & n6194;
  /*# sim_rtl/feedbackmemory.vhd:94:9 */
  assign n6196 = n6192 & n6193;
  /*# sim_rtl/feedbackmemory.vhd:94:9 */
  assign n6197 = n6191 & n6194;
  /*# sim_rtl/feedbackmemory.vhd:94:9 */
  assign n6198 = n6078[1]; // extract
  /*# sim_rtl/feedbackmemory.vhd:94:9 */
  assign n6199 = ~n6198;
  /*# sim_rtl/feedbackmemory.vhd:94:9 */
  assign n6200 = n6195 & n6199;
  /*# sim_rtl/feedbackmemory.vhd:94:9 */
  assign n6201 = n6195 & n6198;
  /*# sim_rtl/feedbackmemory.vhd:94:9 */
  assign n6202 = n6196 & n6199;
  /*# sim_rtl/feedbackmemory.vhd:94:9 */
  assign n6203 = n6196 & n6198;
  /*# sim_rtl/feedbackmemory.vhd:94:9 */
  assign n6204 = n6197 & n6199;
  /*# sim_rtl/feedbackmemory.vhd:94:9 */
  assign n6205 = n6078[0]; // extract
  /*# sim_rtl/feedbackmemory.vhd:94:9 */
  assign n6206 = ~n6205;
  /*# sim_rtl/feedbackmemory.vhd:94:9 */
  assign n6207 = n6200 & n6206;
  /*# sim_rtl/feedbackmemory.vhd:94:9 */
  assign n6208 = n6200 & n6205;
  /*# sim_rtl/feedbackmemory.vhd:94:9 */
  assign n6209 = n6201 & n6206;
  /*# sim_rtl/feedbackmemory.vhd:94:9 */
  assign n6210 = n6201 & n6205;
  /*# sim_rtl/feedbackmemory.vhd:94:9 */
  assign n6211 = n6202 & n6206;
  /*# sim_rtl/feedbackmemory.vhd:94:9 */
  assign n6212 = n6202 & n6205;
  /*# sim_rtl/feedbackmemory.vhd:94:9 */
  assign n6213 = n6203 & n6206;
  /*# sim_rtl/feedbackmemory.vhd:94:9 */
  assign n6214 = n6203 & n6205;
  /*# sim_rtl/feedbackmemory.vhd:94:9 */
  assign n6215 = n6204 & n6206;
  /*# sim_rtl/feedbackmemory.vhd:94:9 */
  assign n6216 = data_array[9:0]; // extract
  /*# sim_rtl/feedbackmemory.vhd:94:9 */
  assign n6217 = n6207 ? 10'b0000000000 : n6216;
  /*# sim_rtl/feedbackmemory.vhd:94:9 */
  assign n6218 = data_array[19:10]; // extract
  /*# sim_rtl/feedbackmemory.vhd:94:9 */
  assign n6219 = n6208 ? 10'b0000000000 : n6218;
  /*# sim_rtl/feedbackmemory.vhd:94:9 */
  assign n6220 = data_array[29:20]; // extract
  /*# sim_rtl/feedbackmemory.vhd:94:9 */
  assign n6221 = n6209 ? 10'b0000000000 : n6220;
  /*# sim_rtl/feedbackmemory.vhd:94:9 */
  assign n6222 = data_array[39:30]; // extract
  /*# sim_rtl/feedbackmemory.vhd:94:9 */
  assign n6223 = n6210 ? 10'b0000000000 : n6222;
  /*# sim_rtl/feedbackmemory.vhd:94:9 */
  assign n6224 = data_array[49:40]; // extract
  /*# sim_rtl/feedbackmemory.vhd:94:9 */
  assign n6225 = n6211 ? 10'b0000000000 : n6224;
  /*# sim_rtl/feedbackmemory.vhd:94:9 */
  assign n6226 = data_array[59:50]; // extract
  /*# sim_rtl/feedbackmemory.vhd:94:9 */
  assign n6227 = n6212 ? 10'b0000000000 : n6226;
  /*# sim_rtl/feedbackmemory.vhd:94:9 */
  assign n6228 = data_array[69:60]; // extract
  /*# sim_rtl/feedbackmemory.vhd:94:9 */
  assign n6229 = n6213 ? 10'b0000000000 : n6228;
  /*# sim_rtl/feedbackmemory.vhd:94:9 */
  assign n6230 = data_array[79:70]; // extract
  /*# sim_rtl/feedbackmemory.vhd:94:9 */
  assign n6231 = n6214 ? 10'b0000000000 : n6230;
  /*# sim_rtl/feedbackmemory.vhd:94:9 */
  assign n6232 = data_array[89:80]; // extract
  /*# sim_rtl/feedbackmemory.vhd:94:9 */
  assign n6233 = n6215 ? 10'b0000000000 : n6232;
  /*# sim_rtl/feedbackmemory.vhd:94:9 */
  assign n6234 = {n6233, n6231, n6229, n6227, n6225, n6223, n6221, n6219, n6217};
  /*# sim_rtl/feedbackmemory.vhd:99:9 */
  assign n6235 = n6087[3]; // extract
  /*# sim_rtl/feedbackmemory.vhd:99:9 */
  assign n6236 = ~n6235;
  /*# sim_rtl/feedbackmemory.vhd:99:9 */
  assign n6237 = n6087[2]; // extract
  /*# sim_rtl/feedbackmemory.vhd:99:9 */
  assign n6238 = ~n6237;
  /*# sim_rtl/feedbackmemory.vhd:99:9 */
  assign n6239 = n6236 & n6238;
  /*# sim_rtl/feedbackmemory.vhd:99:9 */
  assign n6240 = n6236 & n6237;
  /*# sim_rtl/feedbackmemory.vhd:99:9 */
  assign n6241 = n6235 & n6238;
  /*# sim_rtl/feedbackmemory.vhd:99:9 */
  assign n6242 = n6087[1]; // extract
  /*# sim_rtl/feedbackmemory.vhd:99:9 */
  assign n6243 = ~n6242;
  /*# sim_rtl/feedbackmemory.vhd:99:9 */
  assign n6244 = n6239 & n6243;
  /*# sim_rtl/feedbackmemory.vhd:99:9 */
  assign n6245 = n6239 & n6242;
  /*# sim_rtl/feedbackmemory.vhd:99:9 */
  assign n6246 = n6240 & n6243;
  /*# sim_rtl/feedbackmemory.vhd:99:9 */
  assign n6247 = n6240 & n6242;
  /*# sim_rtl/feedbackmemory.vhd:99:9 */
  assign n6248 = n6241 & n6243;
  /*# sim_rtl/feedbackmemory.vhd:99:9 */
  assign n6249 = n6087[0]; // extract
  /*# sim_rtl/feedbackmemory.vhd:99:9 */
  assign n6250 = ~n6249;
  /*# sim_rtl/feedbackmemory.vhd:99:9 */
  assign n6251 = n6244 & n6250;
  /*# sim_rtl/feedbackmemory.vhd:99:9 */
  assign n6252 = n6244 & n6249;
  /*# sim_rtl/feedbackmemory.vhd:99:9 */
  assign n6253 = n6245 & n6250;
  /*# sim_rtl/feedbackmemory.vhd:99:9 */
  assign n6254 = n6245 & n6249;
  /*# sim_rtl/feedbackmemory.vhd:99:9 */
  assign n6255 = n6246 & n6250;
  /*# sim_rtl/feedbackmemory.vhd:99:9 */
  assign n6256 = n6246 & n6249;
  /*# sim_rtl/feedbackmemory.vhd:99:9 */
  assign n6257 = n6247 & n6250;
  /*# sim_rtl/feedbackmemory.vhd:99:9 */
  assign n6258 = n6247 & n6249;
  /*# sim_rtl/feedbackmemory.vhd:99:9 */
  assign n6259 = n6248 & n6250;
  /*# sim_rtl/feedbackmemory.vhd:99:9 */
  assign n6260 = data_array[9:0]; // extract
  /*# sim_rtl/feedbackmemory.vhd:99:9 */
  assign n6261 = n6251 ? n6096 : n6260;
  /*# sim_rtl/feedbackmemory.vhd:99:9 */
  assign n6262 = data_array[19:10]; // extract
  /*# sim_rtl/feedbackmemory.vhd:99:9 */
  assign n6263 = n6252 ? n6096 : n6262;
  /*# sim_rtl/feedbackmemory.vhd:99:9 */
  assign n6264 = data_array[29:20]; // extract
  /*# sim_rtl/feedbackmemory.vhd:99:9 */
  assign n6265 = n6253 ? n6096 : n6264;
  /*# sim_rtl/feedbackmemory.vhd:99:9 */
  assign n6266 = data_array[39:30]; // extract
  /*# sim_rtl/feedbackmemory.vhd:99:9 */
  assign n6267 = n6254 ? n6096 : n6266;
  /*# sim_rtl/feedbackmemory.vhd:99:9 */
  assign n6268 = data_array[49:40]; // extract
  /*# sim_rtl/feedbackmemory.vhd:99:9 */
  assign n6269 = n6255 ? n6096 : n6268;
  /*# sim_rtl/feedbackmemory.vhd:99:9 */
  assign n6270 = data_array[59:50]; // extract
  /*# sim_rtl/feedbackmemory.vhd:99:9 */
  assign n6271 = n6256 ? n6096 : n6270;
  /*# sim_rtl/feedbackmemory.vhd:99:9 */
  assign n6272 = data_array[69:60]; // extract
  /*# sim_rtl/feedbackmemory.vhd:99:9 */
  assign n6273 = n6257 ? n6096 : n6272;
  /*# sim_rtl/feedbackmemory.vhd:99:9 */
  assign n6274 = data_array[79:70]; // extract
  /*# sim_rtl/feedbackmemory.vhd:99:9 */
  assign n6275 = n6258 ? n6096 : n6274;
  /*# sim_rtl/feedbackmemory.vhd:99:9 */
  assign n6276 = data_array[89:80]; // extract
  /*# sim_rtl/feedbackmemory.vhd:99:9 */
  assign n6277 = n6259 ? n6096 : n6276;
  /*# sim_rtl/feedbackmemory.vhd:99:9 */
  assign n6278 = {n6277, n6275, n6273, n6271, n6269, n6267, n6265, n6263, n6261};
  /*# sim_rtl/feedbackmemory.vhd:105:1 */
  assign n6279 = n6103[3]; // extract
  /*# sim_rtl/feedbackmemory.vhd:105:1 */
  assign n6280 = ~n6279;
  /*# sim_rtl/feedbackmemory.vhd:105:1 */
  assign n6281 = n6103[2]; // extract
  /*# sim_rtl/feedbackmemory.vhd:105:1 */
  assign n6282 = ~n6281;
  /*# sim_rtl/feedbackmemory.vhd:105:1 */
  assign n6283 = n6280 & n6282;
  /*# sim_rtl/feedbackmemory.vhd:105:1 */
  assign n6284 = n6280 & n6281;
  /*# sim_rtl/feedbackmemory.vhd:105:1 */
  assign n6285 = n6279 & n6282;
  /*# sim_rtl/feedbackmemory.vhd:105:1 */
  assign n6286 = n6103[1]; // extract
  /*# sim_rtl/feedbackmemory.vhd:105:1 */
  assign n6287 = ~n6286;
  /*# sim_rtl/feedbackmemory.vhd:105:1 */
  assign n6288 = n6283 & n6287;
  /*# sim_rtl/feedbackmemory.vhd:105:1 */
  assign n6289 = n6283 & n6286;
  /*# sim_rtl/feedbackmemory.vhd:105:1 */
  assign n6290 = n6284 & n6287;
  /*# sim_rtl/feedbackmemory.vhd:105:1 */
  assign n6291 = n6284 & n6286;
  /*# sim_rtl/feedbackmemory.vhd:105:1 */
  assign n6292 = n6285 & n6287;
  /*# sim_rtl/feedbackmemory.vhd:105:1 */
  assign n6293 = n6103[0]; // extract
  /*# sim_rtl/feedbackmemory.vhd:105:1 */
  assign n6294 = ~n6293;
  /*# sim_rtl/feedbackmemory.vhd:105:1 */
  assign n6295 = n6288 & n6294;
  /*# sim_rtl/feedbackmemory.vhd:105:1 */
  assign n6296 = n6288 & n6293;
  /*# sim_rtl/feedbackmemory.vhd:105:1 */
  assign n6297 = n6289 & n6294;
  /*# sim_rtl/feedbackmemory.vhd:105:1 */
  assign n6298 = n6289 & n6293;
  /*# sim_rtl/feedbackmemory.vhd:105:1 */
  assign n6299 = n6290 & n6294;
  /*# sim_rtl/feedbackmemory.vhd:105:1 */
  assign n6300 = n6290 & n6293;
  /*# sim_rtl/feedbackmemory.vhd:105:1 */
  assign n6301 = n6291 & n6294;
  /*# sim_rtl/feedbackmemory.vhd:105:1 */
  assign n6302 = n6291 & n6293;
  /*# sim_rtl/feedbackmemory.vhd:105:1 */
  assign n6303 = n6292 & n6294;
  /*# sim_rtl/feedbackmemory.vhd:105:1 */
  assign n6304 = data_array[9:0]; // extract
  /*# sim_rtl/feedbackmemory.vhd:105:1 */
  assign n6305 = n6295 ? n6105 : n6304;
  /*# sim_rtl/feedbackmemory.vhd:105:1 */
  assign n6306 = data_array[19:10]; // extract
  /*# sim_rtl/feedbackmemory.vhd:105:1 */
  assign n6307 = n6296 ? n6105 : n6306;
  /*# sim_rtl/feedbackmemory.vhd:105:1 */
  assign n6308 = data_array[29:20]; // extract
  /*# sim_rtl/feedbackmemory.vhd:105:1 */
  assign n6309 = n6297 ? n6105 : n6308;
  /*# sim_rtl/feedbackmemory.vhd:105:1 */
  assign n6310 = data_array[39:30]; // extract
  /*# sim_rtl/feedbackmemory.vhd:105:1 */
  assign n6311 = n6298 ? n6105 : n6310;
  /*# sim_rtl/feedbackmemory.vhd:105:1 */
  assign n6312 = data_array[49:40]; // extract
  /*# sim_rtl/feedbackmemory.vhd:105:1 */
  assign n6313 = n6299 ? n6105 : n6312;
  /*# sim_rtl/feedbackmemory.vhd:105:1 */
  assign n6314 = data_array[59:50]; // extract
  /*# sim_rtl/feedbackmemory.vhd:105:1 */
  assign n6315 = n6300 ? n6105 : n6314;
  /*# sim_rtl/feedbackmemory.vhd:105:1 */
  assign n6316 = data_array[69:60]; // extract
  /*# sim_rtl/feedbackmemory.vhd:105:1 */
  assign n6317 = n6301 ? n6105 : n6316;
  /*# sim_rtl/feedbackmemory.vhd:105:1 */
  assign n6318 = data_array[79:70]; // extract
  /*# sim_rtl/feedbackmemory.vhd:105:1 */
  assign n6319 = n6302 ? n6105 : n6318;
  /*# sim_rtl/feedbackmemory.vhd:105:1 */
  assign n6320 = data_array[89:80]; // extract
  /*# sim_rtl/feedbackmemory.vhd:105:1 */
  assign n6321 = n6303 ? n6105 : n6320;
  /*# sim_rtl/feedbackmemory.vhd:105:1 */
  assign n6322 = {n6321, n6319, n6317, n6315, n6313, n6311, n6309, n6307, n6305};
  /*# sim_rtl/feedbackmemory.vhd:107:62 */
  assign n6324 = {70'bX, data_array};
  /*# sim_rtl/feedbackmemory.vhd:107:62 */
  assign n6325 = n6324[n6112 * 10 +: 10]; //(Bmux)
  /*# sim_rtl/feedbackmemory.vhd:107:118 */
  assign n6327 = {70'bX, data_array};
  /*# sim_rtl/feedbackmemory.vhd:107:118 */
  assign n6328 = n6327[n6124 * 10 +: 10]; //(Bmux)
endmodule

module sinetable_Brtl
  (input  clk,
   input  clkena,
   input  wf,
   input  [17:0] addr,
   output [13:0] data,
   input  ss_hold,
   input  [7:0] ss_addr,
   input  ss_read,
   input  ss_write,
   input  [31:0] ss_wdata,
   output [31:0] ss_rdata,
   output ss_initialized);
  wire [10:0] ff_data0;
  wire [10:0] ff_data1;
  wire [13:0] w_wf;
  wire [6:0] w_xor;
  wire [6:0] w_addr0;
  wire [6:0] w_addr1;
  wire [6:0] w_xaddr;
  wire ff_sign;
  wire ff_wf;
  wire [8:0] ff_weight;
  wire [11:0] w_sub;
  wire [13:0] w_mul;
  wire [13:0] w_inter;
  wire [13:0] ff_data;
  reg [31:0] ss_local_data;
  wire n5873;
  wire n5874;
  wire n5875;
  wire n5876;
  wire n5877;
  wire n5878;
  wire n5879;
  wire [6:0] n5880;
  wire [6:0] n5881;
  wire [6:0] n5882;
  wire [6:0] n5884;
  wire [6:0] n5885;
  wire n5887;
  wire [6:0] n5888;
  wire [6:0] n5889;
  wire [6:0] n5891;
  wire [6:0] n5892;
  wire n5903;
  wire n5904;
  wire [31:0] n5905;
  wire n5907;
  wire n5909;
  wire [1:0] n5910;
  wire [8:0] n5911;
  reg [8:0] n5913;
  wire [1:0] n5914;
  wire [1:0] n5915;
  reg [1:0] n5917;
  wire [10:0] n5918;
  reg [10:0] n5920;
  wire n5921;
  reg n5923;
  reg n5925;
  wire [23:0] n5926;
  wire [23:0] n5928;
  wire [31:0] n5929;
  wire [10:0] n5930;
  wire [10:0] n5931;
  wire n5932;
  wire n5933;
  wire n5935;
  wire [8:0] n5936;
  wire [13:0] n5937;
  wire n5939;
  wire [1:0] n5940;
  reg [10:0] n5941;
  reg [10:0] n5942;
  reg n5943;
  reg n5944;
  reg [8:0] n5945;
  reg [13:0] n5946;
  wire [10:0] n5953;
  wire [10:0] n5954;
  wire n5955;
  wire n5956;
  wire [8:0] n5957;
  wire [13:0] n5958;
  wire n5965;
  wire n5966;
  wire n5967;
  wire n5968;
  wire n5969;
  wire n5970;
  wire [23:0] n5978;
  localparam [31:0] n5979 = 32'b00000000000000000000000000000000;
  wire [7:0] n5980;
  wire [31:0] n5981;
  wire n5982;
  wire [10:0] n5994;
  wire [10:0] n5995;
  wire n5996;
  wire n5997;
  wire n5998;
  wire [8:0] n5999;
  wire n6000;
  wire n6001;
  wire [8:0] n6002;
  wire [12:0] n6003;
  wire [13:0] n6004;
  wire [13:0] n6005;
  wire [13:0] n6006;
  wire n6007;
  wire n6008;
  wire n6009;
  wire n6010;
  wire n6011;
  wire n6012;
  wire [11:0] n6030;
  wire [11:0] n6032;
  wire [11:0] n6033;
  wire [13:0] u_interpolate_mul_n6034;
  wire [12:0] n6038;
  wire [13:0] n6039;
  wire [13:0] n6040;
  wire [13:0] n6041;
  localparam n6042 = 1'b1;
  reg [10:0] n6043;
  reg [10:0] n6044;
  reg n6045;
  reg n6046;
  reg [8:0] n6047;
  reg [13:0] n6048;
  reg [31:0] n6049;
  wire [10:0] n6052; // mem_rd
  wire [10:0] n6053; // mem_rd
  assign data = ff_data; //(module output)
  assign ss_rdata = ss_local_data; //(module output)
  assign ss_initialized = n6042; //(module output)
  /*# sim_rtl/sinetable.vhd:129:12 */
  assign ff_data0 = n6043; // (signal)
  /*# sim_rtl/sinetable.vhd:130:12 */
  assign ff_data1 = n6044; // (signal)
  /*# sim_rtl/sinetable.vhd:131:12 */
  assign w_wf = n6041; // (signal)
  /*# sim_rtl/sinetable.vhd:132:12 */
  assign w_xor = n5880; // (signal)
  /*# sim_rtl/sinetable.vhd:133:12 */
  assign w_addr0 = w_xaddr; // (signal)
  /*# sim_rtl/sinetable.vhd:134:12 */
  assign w_addr1 = n5888; // (signal)
  /*# sim_rtl/sinetable.vhd:135:12 */
  assign w_xaddr = n5882; // (signal)
  /*# sim_rtl/sinetable.vhd:136:12 */
  assign ff_sign = n6045; // (signal)
  /*# sim_rtl/sinetable.vhd:137:12 */
  assign ff_wf = n6046; // (signal)
  /*# sim_rtl/sinetable.vhd:138:12 */
  assign ff_weight = n6047; // (signal)
  /*# sim_rtl/sinetable.vhd:139:12 */
  assign w_sub = n6033; // (signal)
  /*# sim_rtl/sinetable.vhd:140:12 */
  assign w_mul = u_interpolate_mul_n6034; // (signal)
  /*# sim_rtl/sinetable.vhd:141:12 */
  assign w_inter = n6040; // (signal)
  /*# sim_rtl/sinetable.vhd:142:12 */
  assign ff_data = n6048; // (signal)
  /*# sim_rtl/sinetable.vhd:143:12 */
  always @*
    ss_local_data = n6049; // (isignal)
  initial
    ss_local_data = 32'b00000000000000000000000000000000;
  /*# sim_rtl/sinetable.vhd:147:31 */
  assign n5873 = addr[16]; // extract
  /*# sim_rtl/sinetable.vhd:147:31 */
  assign n5874 = addr[16]; // extract
  /*# sim_rtl/sinetable.vhd:147:31 */
  assign n5875 = addr[16]; // extract
  /*# sim_rtl/sinetable.vhd:147:31 */
  assign n5876 = addr[16]; // extract
  /*# sim_rtl/sinetable.vhd:147:31 */
  assign n5877 = addr[16]; // extract
  /*# sim_rtl/sinetable.vhd:147:31 */
  assign n5878 = addr[16]; // extract
  /*# sim_rtl/sinetable.vhd:147:31 */
  assign n5879 = addr[16]; // extract
  /*# sim_rtl/sinetable.vhd:147:16 */
  assign n5880 = {n5873, n5874, n5875, n5876, n5877, n5878, n5879};
  /*# sim_rtl/sinetable.vhd:148:20 */
  assign n5881 = addr[15:9]; // extract
  /*# sim_rtl/sinetable.vhd:148:36 */
  assign n5882 = n5881 ^ w_xor;
  /*# sim_rtl/sinetable.vhd:150:26 */
  assign n5884 = 7'b1111111 ^ w_xor;
  /*# sim_rtl/sinetable.vhd:150:45 */
  assign n5885 = addr[15:9]; // extract
  /*# sim_rtl/sinetable.vhd:150:61 */
  assign n5887 = n5885 == 7'b1111111;
  /*# sim_rtl/sinetable.vhd:150:36 */
  assign n5888 = n5887 ? n5884 : n5892;
  /*# sim_rtl/sinetable.vhd:151:21 */
  assign n5889 = addr[15:9]; // extract
  /*# sim_rtl/sinetable.vhd:151:37 */
  assign n5891 = n5889 + 7'b0000001;
  /*# sim_rtl/sinetable.vhd:151:42 */
  assign n5892 = n5891 ^ w_xor;
  /*# sim_rtl/sinetable.vhd:172:33 */
  assign n5903 = ss_read | ss_write;
  /*# sim_rtl/sinetable.vhd:172:16 */
  assign n5904 = n5903 & ss_hold;
  /*# sim_rtl/sinetable.vhd:181:6 */
  assign n5905 = {24'b0, ss_addr};  // uext
  /*# sim_rtl/sinetable.vhd:182:1 */
  assign n5907 = n5905 == 32'b00000000000000000000000001100010;
  /*# sim_rtl/sinetable.vhd:187:1 */
  assign n5909 = n5905 == 32'b00000000000000000000000001100011;
  /*# sim_rtl/sinetable.vhd:181:1 */
  assign n5910 = {n5909, n5907};
  /*# sim_rtl/sinetable.vhd:129:12 */
  assign n5911 = ff_data0[8:0]; // extract
  /*# sim_rtl/sinetable.vhd:181:1 */
  always @*
    case (n5910)
      2'b10: n5913 = ff_weight;
      2'b01: n5913 = n5911;
      default: n5913 = 9'b000000000;
    endcase
  /*# sim_rtl/sinetable.vhd:129:12 */
  assign n5914 = ff_data0[10:9]; // extract
  /*# sim_rtl/sinetable.vhd:142:12 */
  assign n5915 = ff_data[1:0]; // extract
  /*# sim_rtl/sinetable.vhd:181:1 */
  always @*
    case (n5910)
      2'b10: n5917 = n5915;
      2'b01: n5917 = n5914;
      default: n5917 = 2'b00;
    endcase
  /*# sim_rtl/sinetable.vhd:142:12 */
  assign n5918 = ff_data[12:2]; // extract
  /*# sim_rtl/sinetable.vhd:181:1 */
  always @*
    case (n5910)
      2'b10: n5920 = n5918;
      2'b01: n5920 = ff_data1;
      default: n5920 = 11'b00000000000;
    endcase
  /*# sim_rtl/sinetable.vhd:142:12 */
  assign n5921 = ff_data[13]; // extract
  /*# sim_rtl/sinetable.vhd:181:1 */
  always @*
    case (n5910)
      2'b10: n5923 = n5921;
      2'b01: n5923 = ff_sign;
      default: n5923 = 1'b0;
    endcase
  /*# sim_rtl/sinetable.vhd:181:1 */
  always @*
    case (n5910)
      2'b10: n5925 = 1'b0;
      2'b01: n5925 = ff_wf;
      default: n5925 = 1'b0;
    endcase
  /*# sim_rtl/sinetable.vhd:180:1 */
  assign n5926 = {n5925, n5923, n5920, n5917, n5913};
  /*# sim_rtl/sinetable.vhd:180:1 */
  assign n5928 = ss_read ? n5926 : 24'b000000000000000000000000;
  /*# sim_rtl/sinetable.vhd:193:6 */
  assign n5929 = {24'b0, ss_addr};  // uext
  /*# sim_rtl/sinetable.vhd:195:39 */
  assign n5930 = ss_wdata[10:0]; // extract
  /*# sim_rtl/sinetable.vhd:197:39 */
  assign n5931 = ss_wdata[21:11]; // extract
  /*# sim_rtl/sinetable.vhd:199:28 */
  assign n5932 = ss_wdata[22]; // extract
  /*# sim_rtl/sinetable.vhd:201:26 */
  assign n5933 = ss_wdata[23]; // extract
  /*# sim_rtl/sinetable.vhd:194:1 */
  assign n5935 = n5929 == 32'b00000000000000000000000001100010;
  /*# sim_rtl/sinetable.vhd:204:39 */
  assign n5936 = ss_wdata[8:0]; // extract
  /*# sim_rtl/sinetable.vhd:206:38 */
  assign n5937 = ss_wdata[22:9]; // extract
  /*# sim_rtl/sinetable.vhd:203:1 */
  assign n5939 = n5929 == 32'b00000000000000000000000001100011;
  /*# sim_rtl/sinetable.vhd:193:1 */
  assign n5940 = {n5939, n5935};
  /*# sim_rtl/sinetable.vhd:193:1 */
  always @*
    case (n5940)
      2'b10: n5941 = ff_data0;
      2'b01: n5941 = n5930;
      default: n5941 = ff_data0;
    endcase
  /*# sim_rtl/sinetable.vhd:193:1 */
  always @*
    case (n5940)
      2'b10: n5942 = ff_data1;
      2'b01: n5942 = n5931;
      default: n5942 = ff_data1;
    endcase
  /*# sim_rtl/sinetable.vhd:193:1 */
  always @*
    case (n5940)
      2'b10: n5943 = ff_sign;
      2'b01: n5943 = n5932;
      default: n5943 = ff_sign;
    endcase
  /*# sim_rtl/sinetable.vhd:193:1 */
  always @*
    case (n5940)
      2'b10: n5944 = ff_wf;
      2'b01: n5944 = n5933;
      default: n5944 = ff_wf;
    endcase
  /*# sim_rtl/sinetable.vhd:193:1 */
  always @*
    case (n5940)
      2'b10: n5945 = n5936;
      2'b01: n5945 = ff_weight;
      default: n5945 = ff_weight;
    endcase
  /*# sim_rtl/sinetable.vhd:193:1 */
  always @*
    case (n5940)
      2'b10: n5946 = n5937;
      2'b01: n5946 = ff_data;
      default: n5946 = ff_data;
    endcase
  /*# sim_rtl/sinetable.vhd:172:1 */
  assign n5953 = n5965 ? n5941 : ff_data0;
  /*# sim_rtl/sinetable.vhd:172:1 */
  assign n5954 = n5966 ? n5942 : ff_data1;
  /*# sim_rtl/sinetable.vhd:172:1 */
  assign n5955 = n5967 ? n5943 : ff_sign;
  /*# sim_rtl/sinetable.vhd:172:1 */
  assign n5956 = n5968 ? n5944 : ff_wf;
  /*# sim_rtl/sinetable.vhd:172:1 */
  assign n5957 = n5969 ? n5945 : ff_weight;
  /*# sim_rtl/sinetable.vhd:172:1 */
  assign n5958 = n5970 ? n5946 : ff_data;
  /*# sim_rtl/sinetable.vhd:172:1 */
  assign n5965 = ss_write & n5904;
  /*# sim_rtl/sinetable.vhd:172:1 */
  assign n5966 = ss_write & n5904;
  /*# sim_rtl/sinetable.vhd:172:1 */
  assign n5967 = ss_write & n5904;
  /*# sim_rtl/sinetable.vhd:172:1 */
  assign n5968 = ss_write & n5904;
  /*# sim_rtl/sinetable.vhd:172:1 */
  assign n5969 = ss_write & n5904;
  /*# sim_rtl/sinetable.vhd:172:1 */
  assign n5970 = ss_write & n5904;
  /*# sim_rtl/sinetable.vhd:172:1 */
  assign n5978 = n5904 ? n5928 : 24'b000000000000000000000000;
  /*# sim_rtl/sinetable.vhd:167:10 */
  assign n5980 = n5979[31:24]; // extract
  /*# sim_rtl/sinetable.vhd:167:10 */
  assign n5981 = {n5980, n5978};
  /*# sim_rtl/sinetable.vhd:213:11 */
  assign n5982 = ~ss_hold;
  /*# sim_rtl/sinetable.vhd:213:1 */
  assign n5994 = n6007 ? n6053 : n5953;
  /*# sim_rtl/sinetable.vhd:213:1 */
  assign n5995 = n6008 ? n6052 : n5954;
  /*# sim_rtl/sinetable.vhd:222:36 */
  assign n5996 = addr[17]; // extract
  /*# sim_rtl/sinetable.vhd:223:43 */
  assign n5997 = addr[17]; // extract
  /*# sim_rtl/sinetable.vhd:223:35 */
  assign n5998 = wf & n5997;
  /*# sim_rtl/sinetable.vhd:224:36 */
  assign n5999 = addr[8:0]; // extract
  /*# sim_rtl/sinetable.vhd:213:1 */
  assign n6000 = n6009 ? n5996 : n5955;
  /*# sim_rtl/sinetable.vhd:213:1 */
  assign n6001 = n6010 ? n5998 : n5956;
  /*# sim_rtl/sinetable.vhd:213:1 */
  assign n6002 = n6011 ? n5999 : n5957;
  /*# sim_rtl/sinetable.vhd:230:46 */
  assign n6003 = w_inter[12:0]; // extract
  /*# sim_rtl/sinetable.vhd:230:37 */
  assign n6004 = {ff_sign, n6003};
  /*# sim_rtl/sinetable.vhd:230:61 */
  assign n6005 = n6004 | w_wf;
  /*# sim_rtl/sinetable.vhd:213:1 */
  assign n6006 = n6012 ? n6005 : n5958;
  /*# sim_rtl/sinetable.vhd:213:1 */
  assign n6007 = clkena & n5982;
  /*# sim_rtl/sinetable.vhd:213:1 */
  assign n6008 = clkena & n5982;
  /*# sim_rtl/sinetable.vhd:213:1 */
  assign n6009 = clkena & n5982;
  /*# sim_rtl/sinetable.vhd:213:1 */
  assign n6010 = clkena & n5982;
  /*# sim_rtl/sinetable.vhd:213:1 */
  assign n6011 = clkena & n5982;
  /*# sim_rtl/sinetable.vhd:213:1 */
  assign n6012 = clkena & n5982;
  /*# sim_rtl/sinetable.vhd:244:21 */
  assign n6030 = {1'b0, ff_data1};
  /*# sim_rtl/sinetable.vhd:244:40 */
  assign n6032 = {1'b0, ff_data0};
  /*# sim_rtl/sinetable.vhd:244:33 */
  assign n6033 = n6030 - n6032;
  /*# sim_rtl/sinetable.vhd:246:5 */
  interpolate_mul_Brtl u_interpolate_mul (
    .i0(ff_weight),
    .i1(w_sub),
    .o(u_interpolate_mul_n6034));
  /*# sim_rtl/sinetable.vhd:254:26 */
  assign n6038 = {ff_data0, 2'b00};
  /*# sim_rtl/sinetable.vhd:254:34 */
  assign n6039 = {1'b0, n6038};  // uext
  /*# sim_rtl/sinetable.vhd:254:34 */
  assign n6040 = n6039 + w_mul;
  /*# sim_rtl/sinetable.vhd:255:16 */
  assign n6041 = {ff_wf, ff_wf, ff_wf, ff_wf, ff_wf, ff_wf, ff_wf, ff_wf, ff_wf, ff_wf, ff_wf, ff_wf, ff_wf, ff_wf};
  /*# sim_rtl/sinetable.vhd:169:1 */
  always @(posedge clk)
    n6043 <= n5994;
  /*# sim_rtl/sinetable.vhd:169:1 */
  always @(posedge clk)
    n6044 <= n5995;
  /*# sim_rtl/sinetable.vhd:169:1 */
  always @(posedge clk)
    n6045 <= n6000;
  /*# sim_rtl/sinetable.vhd:169:1 */
  always @(posedge clk)
    n6046 <= n6001;
  /*# sim_rtl/sinetable.vhd:169:1 */
  always @(posedge clk)
    n6047 <= n6002;
  /*# sim_rtl/sinetable.vhd:169:1 */
  always @(posedge clk)
    n6048 <= n6006;
  /*# sim_rtl/sinetable.vhd:169:1 */
  always @(posedge clk)
    n6049 <= n5981;
  initial
    n6049 = 32'b00000000000000000000000000000000;
  /*# sim_rtl/sinetable.vhd:216:39 */
  reg [10:0] n6050[127:0] ; // memory
  initial begin
    n6050[127] = 11'b00000000000;
    n6050[126] = 11'b00000000000;
    n6050[125] = 11'b00000000000;
    n6050[124] = 11'b00000000000;
    n6050[123] = 11'b00000000000;
    n6050[122] = 11'b00000000000;
    n6050[121] = 11'b00000000001;
    n6050[120] = 11'b00000000001;
    n6050[119] = 11'b00000000010;
    n6050[118] = 11'b00000000010;
    n6050[117] = 11'b00000000011;
    n6050[116] = 11'b00000000011;
    n6050[115] = 11'b00000000100;
    n6050[114] = 11'b00000000101;
    n6050[113] = 11'b00000000110;
    n6050[112] = 11'b00000000111;
    n6050[111] = 11'b00000001000;
    n6050[110] = 11'b00000001001;
    n6050[109] = 11'b00000001010;
    n6050[108] = 11'b00000001011;
    n6050[107] = 11'b00000001100;
    n6050[106] = 11'b00000001101;
    n6050[105] = 11'b00000001110;
    n6050[104] = 11'b00000010000;
    n6050[103] = 11'b00000010001;
    n6050[102] = 11'b00000010011;
    n6050[101] = 11'b00000010100;
    n6050[100] = 11'b00000010110;
    n6050[99] = 11'b00000010111;
    n6050[98] = 11'b00000011001;
    n6050[97] = 11'b00000011011;
    n6050[96] = 11'b00000011101;
    n6050[95] = 11'b00000011110;
    n6050[94] = 11'b00000100000;
    n6050[93] = 11'b00000100010;
    n6050[92] = 11'b00000100101;
    n6050[91] = 11'b00000100111;
    n6050[90] = 11'b00000101001;
    n6050[89] = 11'b00000101011;
    n6050[88] = 11'b00000101110;
    n6050[87] = 11'b00000110000;
    n6050[86] = 11'b00000110011;
    n6050[85] = 11'b00000110101;
    n6050[84] = 11'b00000111000;
    n6050[83] = 11'b00000111011;
    n6050[82] = 11'b00000111101;
    n6050[81] = 11'b00001000000;
    n6050[80] = 11'b00001000011;
    n6050[79] = 11'b00001000110;
    n6050[78] = 11'b00001001001;
    n6050[77] = 11'b00001001101;
    n6050[76] = 11'b00001010000;
    n6050[75] = 11'b00001010011;
    n6050[74] = 11'b00001010111;
    n6050[73] = 11'b00001011010;
    n6050[72] = 11'b00001011110;
    n6050[71] = 11'b00001100010;
    n6050[70] = 11'b00001100110;
    n6050[69] = 11'b00001101010;
    n6050[68] = 11'b00001101110;
    n6050[67] = 11'b00001110010;
    n6050[66] = 11'b00001110110;
    n6050[65] = 11'b00001111010;
    n6050[64] = 11'b00001111111;
    n6050[63] = 11'b00010000011;
    n6050[62] = 11'b00010001000;
    n6050[61] = 11'b00010001101;
    n6050[60] = 11'b00010010010;
    n6050[59] = 11'b00010010111;
    n6050[58] = 11'b00010011100;
    n6050[57] = 11'b00010100001;
    n6050[56] = 11'b00010100111;
    n6050[55] = 11'b00010101100;
    n6050[54] = 11'b00010110010;
    n6050[53] = 11'b00010111000;
    n6050[52] = 11'b00010111110;
    n6050[51] = 11'b00011000100;
    n6050[50] = 11'b00011001010;
    n6050[49] = 11'b00011010001;
    n6050[48] = 11'b00011010111;
    n6050[47] = 11'b00011011110;
    n6050[46] = 11'b00011100101;
    n6050[45] = 11'b00011101100;
    n6050[44] = 11'b00011110100;
    n6050[43] = 11'b00011111011;
    n6050[42] = 11'b00100000011;
    n6050[41] = 11'b00100001011;
    n6050[40] = 11'b00100010100;
    n6050[39] = 11'b00100011100;
    n6050[38] = 11'b00100100101;
    n6050[37] = 11'b00100101110;
    n6050[36] = 11'b00100111000;
    n6050[35] = 11'b00101000001;
    n6050[34] = 11'b00101001011;
    n6050[33] = 11'b00101010110;
    n6050[32] = 11'b00101100000;
    n6050[31] = 11'b00101101011;
    n6050[30] = 11'b00101110111;
    n6050[29] = 11'b00110000011;
    n6050[28] = 11'b00110001111;
    n6050[27] = 11'b00110011100;
    n6050[26] = 11'b00110101001;
    n6050[25] = 11'b00110110111;
    n6050[24] = 11'b00111000110;
    n6050[23] = 11'b00111010101;
    n6050[22] = 11'b00111100101;
    n6050[21] = 11'b00111110110;
    n6050[20] = 11'b01000000111;
    n6050[19] = 11'b01000011010;
    n6050[18] = 11'b01000101101;
    n6050[17] = 11'b01001000010;
    n6050[16] = 11'b01001011000;
    n6050[15] = 11'b01001101111;
    n6050[14] = 11'b01010001000;
    n6050[13] = 11'b01010100011;
    n6050[12] = 11'b01011000000;
    n6050[11] = 11'b01011100000;
    n6050[10] = 11'b01100000011;
    n6050[9] = 11'b01100101001;
    n6050[8] = 11'b01101010101;
    n6050[7] = 11'b01110000101;
    n6050[6] = 11'b01110111110;
    n6050[5] = 11'b10000000001;
    n6050[4] = 11'b10001010011;
    n6050[3] = 11'b10010111100;
    n6050[2] = 11'b10101010001;
    n6050[1] = 11'b11001010000;
    n6050[0] = 11'b11111111111;
    end
  assign n6052 = n6050[w_addr1];
  assign n6053 = n6050[w_addr0];
  /*# sim_rtl/sinetable.vhd:217:39 */
  /*# sim_rtl/sinetable.vhd:216:39 */
endmodule

module phasememory_Brtl
  (input  clk,
   input  reset,
   input  [4:0] slot,
   input  memwr,
   output [17:0] memout,
   input  [17:0] memin,
   input  ss_hold,
   input  [7:0] ss_addr,
   input  ss_read,
   input  ss_write,
   input  [31:0] ss_wdata,
   output [31:0] ss_rdata,
   output ss_initialized);
  wire [323:0] phase_array;
  reg [31:0] ss_local_data;
  wire ss_mem_active;
  wire [4:0] ss_mem_index;
  reg ss_mem_ready;
  wire [17:0] ss_mem_vector;
  reg [4:0] n5518_init_slot;
  wire [31:0] n5522;
  wire n5524;
  wire n5527;
  wire n5529;
  wire [31:0] n5530;
  wire n5532;
  wire [4:0] n5534;
  wire [31:0] n5538;
  wire [31:0] n5540;
  wire [4:0] n5541;
  wire [4:0] n5544;
  wire [323:0] n5547;
  wire [323:0] n5548;
  wire n5550;
  wire [4:0] n5552;
  wire [17:0] n5554;
  wire [323:0] n5556;
  wire [323:0] n5557;
  wire n5558;
  wire [4:0] n5560;
  wire [4:0] n5565;
  wire [17:0] n5568;
  wire [31:0] n5581;
  wire n5583;
  wire n5584;
  wire [31:0] n5585;
  wire n5587;
  wire n5588;
  wire n5589;
  wire [31:0] n5591;
  wire [31:0] n5593;
  wire [4:0] n5594;
  wire [31:0] n5595;
  wire n5597;
  wire [31:0] n5598;
  wire n5600;
  wire n5601;
  wire [4:0] n5602;
  wire [31:0] n5605;
  wire [31:0] n5606;
  wire n5608;
  wire [17:0] n5609;
  reg [17:0] n5610;
  wire n5611;
  wire [323:0] n5612;
  reg [323:0] n5613;
  reg n5614;
  wire [4:0] n5615;
  reg [4:0] n5616;
  wire n5617;
  wire n5618;
  wire n5619;
  wire n5620;
  wire n5621;
  wire n5622;
  wire n5623;
  wire n5624;
  wire n5625;
  wire n5626;
  wire n5627;
  wire n5628;
  wire n5629;
  wire n5630;
  wire n5631;
  wire n5632;
  wire n5633;
  wire n5634;
  wire n5635;
  wire n5636;
  wire n5637;
  wire n5638;
  wire n5639;
  wire n5640;
  wire n5641;
  wire n5642;
  wire n5643;
  wire n5644;
  wire n5645;
  wire n5646;
  wire n5647;
  wire n5648;
  wire n5649;
  wire n5650;
  wire n5651;
  wire n5652;
  wire n5653;
  wire n5654;
  wire n5655;
  wire n5656;
  wire n5657;
  wire n5658;
  wire n5659;
  wire n5660;
  wire n5661;
  wire [17:0] n5662;
  wire [17:0] n5663;
  wire [17:0] n5664;
  wire [17:0] n5665;
  wire [17:0] n5666;
  wire [17:0] n5667;
  wire [17:0] n5668;
  wire [17:0] n5669;
  wire [17:0] n5670;
  wire [17:0] n5671;
  wire [17:0] n5672;
  wire [17:0] n5673;
  wire [17:0] n5674;
  wire [17:0] n5675;
  wire [17:0] n5676;
  wire [17:0] n5677;
  wire [17:0] n5678;
  wire [17:0] n5679;
  wire [17:0] n5680;
  wire [17:0] n5681;
  wire [17:0] n5682;
  wire [17:0] n5683;
  wire [17:0] n5684;
  wire [17:0] n5685;
  wire [17:0] n5686;
  wire [17:0] n5687;
  wire [17:0] n5688;
  wire [17:0] n5689;
  wire [17:0] n5690;
  wire [17:0] n5691;
  wire [17:0] n5692;
  wire [17:0] n5693;
  wire [17:0] n5694;
  wire [17:0] n5695;
  wire [17:0] n5696;
  wire [17:0] n5697;
  wire [323:0] n5698;
  wire n5699;
  wire n5700;
  wire n5701;
  wire n5702;
  wire n5703;
  wire n5704;
  wire n5705;
  wire n5706;
  wire n5707;
  wire n5708;
  wire n5709;
  wire n5710;
  wire n5711;
  wire n5712;
  wire n5713;
  wire n5714;
  wire n5715;
  wire n5716;
  wire n5717;
  wire n5718;
  wire n5719;
  wire n5720;
  wire n5721;
  wire n5722;
  wire n5723;
  wire n5724;
  wire n5725;
  wire n5726;
  wire n5727;
  wire n5728;
  wire n5729;
  wire n5730;
  wire n5731;
  wire n5732;
  wire n5733;
  wire n5734;
  wire n5735;
  wire n5736;
  wire n5737;
  wire n5738;
  wire n5739;
  wire n5740;
  wire n5741;
  wire n5742;
  wire n5743;
  wire [17:0] n5744;
  wire [17:0] n5745;
  wire [17:0] n5746;
  wire [17:0] n5747;
  wire [17:0] n5748;
  wire [17:0] n5749;
  wire [17:0] n5750;
  wire [17:0] n5751;
  wire [17:0] n5752;
  wire [17:0] n5753;
  wire [17:0] n5754;
  wire [17:0] n5755;
  wire [17:0] n5756;
  wire [17:0] n5757;
  wire [17:0] n5758;
  wire [17:0] n5759;
  wire [17:0] n5760;
  wire [17:0] n5761;
  wire [17:0] n5762;
  wire [17:0] n5763;
  wire [17:0] n5764;
  wire [17:0] n5765;
  wire [17:0] n5766;
  wire [17:0] n5767;
  wire [17:0] n5768;
  wire [17:0] n5769;
  wire [17:0] n5770;
  wire [17:0] n5771;
  wire [17:0] n5772;
  wire [17:0] n5773;
  wire [17:0] n5774;
  wire [17:0] n5775;
  wire [17:0] n5776;
  wire [17:0] n5777;
  wire [17:0] n5778;
  wire [17:0] n5779;
  wire [323:0] n5780;
  wire n5781;
  wire n5782;
  wire n5783;
  wire n5784;
  wire n5785;
  wire n5786;
  wire n5787;
  wire n5788;
  wire n5789;
  wire n5790;
  wire n5791;
  wire n5792;
  wire n5793;
  wire n5794;
  wire n5795;
  wire n5796;
  wire n5797;
  wire n5798;
  wire n5799;
  wire n5800;
  wire n5801;
  wire n5802;
  wire n5803;
  wire n5804;
  wire n5805;
  wire n5806;
  wire n5807;
  wire n5808;
  wire n5809;
  wire n5810;
  wire n5811;
  wire n5812;
  wire n5813;
  wire n5814;
  wire n5815;
  wire n5816;
  wire n5817;
  wire n5818;
  wire n5819;
  wire n5820;
  wire n5821;
  wire n5822;
  wire n5823;
  wire n5824;
  wire n5825;
  wire [17:0] n5826;
  wire [17:0] n5827;
  wire [17:0] n5828;
  wire [17:0] n5829;
  wire [17:0] n5830;
  wire [17:0] n5831;
  wire [17:0] n5832;
  wire [17:0] n5833;
  wire [17:0] n5834;
  wire [17:0] n5835;
  wire [17:0] n5836;
  wire [17:0] n5837;
  wire [17:0] n5838;
  wire [17:0] n5839;
  wire [17:0] n5840;
  wire [17:0] n5841;
  wire [17:0] n5842;
  wire [17:0] n5843;
  wire [17:0] n5844;
  wire [17:0] n5845;
  wire [17:0] n5846;
  wire [17:0] n5847;
  wire [17:0] n5848;
  wire [17:0] n5849;
  wire [17:0] n5850;
  wire [17:0] n5851;
  wire [17:0] n5852;
  wire [17:0] n5853;
  wire [17:0] n5854;
  wire [17:0] n5855;
  wire [17:0] n5856;
  wire [17:0] n5857;
  wire [17:0] n5858;
  wire [17:0] n5859;
  wire [17:0] n5860;
  wire [17:0] n5861;
  wire [323:0] n5862;
  wire [575:0] n5864;
  wire [17:0] n5865;
  wire [575:0] n5867;
  wire [17:0] n5868;
  assign memout = n5610; //(module output)
  assign ss_rdata = ss_local_data; //(module output)
  assign ss_initialized = ss_mem_ready; //(module output)
  /*# sim_rtl/phasememory.vhd:60:10 */
  assign phase_array = n5613; // (signal)
  /*# sim_rtl/phasememory.vhd:63:12 */
  always @*
    ss_local_data = n5606; // (isignal)
  initial
    ss_local_data = 32'b00000000000000000000000000000000;
  /*# sim_rtl/phasememory.vhd:64:12 */
  assign ss_mem_active = n5589; // (signal)
  /*# sim_rtl/phasememory.vhd:65:12 */
  assign ss_mem_index = n5602; // (signal)
  /*# sim_rtl/phasememory.vhd:66:12 */
  always @*
    ss_mem_ready = n5614; // (isignal)
  initial
    ss_mem_ready = 1'b0;
  /*# sim_rtl/phasememory.vhd:67:12 */
  assign ss_mem_vector = n5610; // (signal)
  /*# sim_rtl/phasememory.vhd:73:14 */
  always @*
    n5518_init_slot = n5616; // (isignal)
  initial
    n5518_init_slot = 5'b00000;
  /*# sim_rtl/phasememory.vhd:84:39 */
  assign n5522 = {27'b0, n5518_init_slot};  // uext
  /*# sim_rtl/phasememory.vhd:84:39 */
  assign n5524 = n5522 == 32'b00000000000000000000000000010010;
  /*# sim_rtl/phasememory.vhd:84:27 */
  assign n5527 = n5524 ? 1'b1 : 1'b0;
  /*# sim_rtl/phasememory.vhd:85:11 */
  assign n5529 = ~ss_hold;
  /*# sim_rtl/phasememory.vhd:86:14 */
  assign n5530 = {27'b0, n5518_init_slot};  // uext
  /*# sim_rtl/phasememory.vhd:86:14 */
  assign n5532 = n5530 != 32'b00000000000000000000000000010010;
  /*# sim_rtl/phasememory.vhd:88:20 */
  assign n5534 = 5'b10001 - n5518_init_slot;
  /*# sim_rtl/phasememory.vhd:89:31 */
  assign n5538 = {27'b0, n5518_init_slot};  // uext
  /*# sim_rtl/phasememory.vhd:89:31 */
  assign n5540 = n5538 + 32'b00000000000000000000000000000001;
  /*# sim_rtl/phasememory.vhd:89:8 */
  assign n5541 = n5540[4:0];  // trunc
  /*# sim_rtl/phasememory.vhd:93:22 */
  assign n5544 = 5'b10001 - slot;
  /*# sim_rtl/phasememory.vhd:91:6 */
  assign n5547 = memwr ? n5780 : phase_array;
  /*# sim_rtl/phasememory.vhd:86:1 */
  assign n5548 = n5532 ? n5698 : n5547;
  /*# sim_rtl/phasememory.vhd:98:20 */
  assign n5550 = ss_mem_active & ss_write;
  /*# sim_rtl/phasememory.vhd:99:13 */
  assign n5552 = 5'b10001 - ss_mem_index;
  /*# sim_rtl/phasememory.vhd:99:36 */
  assign n5554 = ss_wdata[17:0]; // extract
  /*# sim_rtl/phasememory.vhd:98:1 */
  assign n5556 = n5550 ? n5862 : phase_array;
  /*# sim_rtl/phasememory.vhd:85:1 */
  assign n5557 = n5529 ? n5548 : n5556;
  /*# sim_rtl/phasememory.vhd:85:1 */
  assign n5558 = n5532 & n5529;
  /*# sim_rtl/phasememory.vhd:101:49 */
  assign n5560 = 5'b10001 - ss_mem_index;
  /*# sim_rtl/phasememory.vhd:101:91 */
  assign n5565 = 5'b10001 - slot;
  /*# sim_rtl/phasememory.vhd:101:1 */
  assign n5568 = ss_mem_active ? n5865 : n5868;
  /*# sim_rtl/phasememory.vhd:106:43 */
  assign n5581 = {24'b0, ss_addr};  // uext
  /*# sim_rtl/phasememory.vhd:106:64 */
  assign n5583 = $signed(n5581) >= $signed(32'b00000000000000000000000000001101);
  /*# sim_rtl/phasememory.vhd:106:39 */
  assign n5584 = n5583 & ss_hold;
  /*# sim_rtl/phasememory.vhd:106:73 */
  assign n5585 = {24'b0, ss_addr};  // uext
  /*# sim_rtl/phasememory.vhd:106:94 */
  assign n5587 = $signed(n5585) <= $signed(32'b00000000000000000000000000011110);
  /*# sim_rtl/phasememory.vhd:106:69 */
  assign n5588 = n5587 & n5584;
  /*# sim_rtl/phasememory.vhd:106:22 */
  assign n5589 = n5588 ? 1'b1 : 1'b0;
  /*# sim_rtl/phasememory.vhd:107:17 */
  assign n5591 = {24'b0, ss_addr};  // uext
  /*# sim_rtl/phasememory.vhd:107:38 */
  assign n5593 = n5591 - 32'b00000000000000000000000000001101;
  /*# sim_rtl/phasememory.vhd:107:17 */
  assign n5594 = n5593[4:0];  // trunc
  /*# sim_rtl/phasememory.vhd:107:47 */
  assign n5595 = {24'b0, ss_addr};  // uext
  /*# sim_rtl/phasememory.vhd:107:68 */
  assign n5597 = $signed(n5595) >= $signed(32'b00000000000000000000000000001101);
  /*# sim_rtl/phasememory.vhd:107:77 */
  assign n5598 = {24'b0, ss_addr};  // uext
  /*# sim_rtl/phasememory.vhd:107:98 */
  assign n5600 = $signed(n5598) <= $signed(32'b00000000000000000000000000011110);
  /*# sim_rtl/phasememory.vhd:107:73 */
  assign n5601 = n5600 & n5597;
  /*# sim_rtl/phasememory.vhd:107:42 */
  assign n5602 = n5601 ? n5594 : 5'b00000;
  /*# sim_rtl/phasememory.vhd:109:39 */
  assign n5605 = {14'b00000000000000, ss_mem_vector};
  /*# sim_rtl/phasememory.vhd:109:55 */
  assign n5606 = ss_mem_active ? n5605 : 32'b00000000000000000000000000000000;
  /*# sim_rtl/phasememory.vhd:43:5 */
  assign n5608 = ~reset;
  /*# sim_rtl/phasememory.vhd:82:4 */
  assign n5609 = n5608 ? n5568 : n5610;
  /*# sim_rtl/phasememory.vhd:82:4 */
  always @(posedge clk)
    n5610 <= n5609;
  /*# sim_rtl/phasememory.vhd:60:10 */
  assign n5611 = ~reset;
  /*# sim_rtl/phasememory.vhd:82:4 */
  assign n5612 = n5611 ? n5557 : phase_array;
  /*# sim_rtl/phasememory.vhd:82:4 */
  always @(posedge clk)
    n5613 <= n5612;
  /*# sim_rtl/phasememory.vhd:82:4 */
  always @(posedge clk or posedge reset)
    if (reset)
      n5614 <= 1'b0;
    else
      n5614 <= n5527;
  /*# sim_rtl/phasememory.vhd:82:4 */
  assign n5615 = n5558 ? n5541 : n5518_init_slot;
  /*# sim_rtl/phasememory.vhd:82:4 */
  always @(posedge clk or posedge reset)
    if (reset)
      n5616 <= 5'b00000;
    else
      n5616 <= n5615;
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5617 = n5534[4]; // extract
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5618 = ~n5617;
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5619 = n5534[3]; // extract
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5620 = ~n5619;
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5621 = n5618 & n5620;
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5622 = n5618 & n5619;
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5623 = n5617 & n5620;
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5624 = n5534[2]; // extract
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5625 = ~n5624;
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5626 = n5621 & n5625;
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5627 = n5621 & n5624;
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5628 = n5622 & n5625;
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5629 = n5622 & n5624;
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5630 = n5623 & n5625;
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5631 = n5534[1]; // extract
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5632 = ~n5631;
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5633 = n5626 & n5632;
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5634 = n5626 & n5631;
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5635 = n5627 & n5632;
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5636 = n5627 & n5631;
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5637 = n5628 & n5632;
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5638 = n5628 & n5631;
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5639 = n5629 & n5632;
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5640 = n5629 & n5631;
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5641 = n5630 & n5632;
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5642 = n5534[0]; // extract
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5643 = ~n5642;
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5644 = n5633 & n5643;
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5645 = n5633 & n5642;
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5646 = n5634 & n5643;
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5647 = n5634 & n5642;
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5648 = n5635 & n5643;
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5649 = n5635 & n5642;
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5650 = n5636 & n5643;
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5651 = n5636 & n5642;
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5652 = n5637 & n5643;
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5653 = n5637 & n5642;
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5654 = n5638 & n5643;
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5655 = n5638 & n5642;
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5656 = n5639 & n5643;
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5657 = n5639 & n5642;
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5658 = n5640 & n5643;
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5659 = n5640 & n5642;
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5660 = n5641 & n5643;
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5661 = n5641 & n5642;
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5662 = phase_array[17:0]; // extract
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5663 = n5644 ? 18'b000000000000000000 : n5662;
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5664 = phase_array[35:18]; // extract
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5665 = n5645 ? 18'b000000000000000000 : n5664;
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5666 = phase_array[53:36]; // extract
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5667 = n5646 ? 18'b000000000000000000 : n5666;
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5668 = phase_array[71:54]; // extract
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5669 = n5647 ? 18'b000000000000000000 : n5668;
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5670 = phase_array[89:72]; // extract
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5671 = n5648 ? 18'b000000000000000000 : n5670;
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5672 = phase_array[107:90]; // extract
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5673 = n5649 ? 18'b000000000000000000 : n5672;
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5674 = phase_array[125:108]; // extract
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5675 = n5650 ? 18'b000000000000000000 : n5674;
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5676 = phase_array[143:126]; // extract
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5677 = n5651 ? 18'b000000000000000000 : n5676;
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5678 = phase_array[161:144]; // extract
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5679 = n5652 ? 18'b000000000000000000 : n5678;
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5680 = phase_array[179:162]; // extract
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5681 = n5653 ? 18'b000000000000000000 : n5680;
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5682 = phase_array[197:180]; // extract
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5683 = n5654 ? 18'b000000000000000000 : n5682;
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5684 = phase_array[215:198]; // extract
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5685 = n5655 ? 18'b000000000000000000 : n5684;
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5686 = phase_array[233:216]; // extract
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5687 = n5656 ? 18'b000000000000000000 : n5686;
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5688 = phase_array[251:234]; // extract
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5689 = n5657 ? 18'b000000000000000000 : n5688;
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5690 = phase_array[269:252]; // extract
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5691 = n5658 ? 18'b000000000000000000 : n5690;
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5692 = phase_array[287:270]; // extract
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5693 = n5659 ? 18'b000000000000000000 : n5692;
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5694 = phase_array[305:288]; // extract
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5695 = n5660 ? 18'b000000000000000000 : n5694;
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5696 = phase_array[323:306]; // extract
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5697 = n5661 ? 18'b000000000000000000 : n5696;
  /*# sim_rtl/phasememory.vhd:88:8 */
  assign n5698 = {n5697, n5695, n5693, n5691, n5689, n5687, n5685, n5683, n5681, n5679, n5677, n5675, n5673, n5671, n5669, n5667, n5665, n5663};
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5699 = n5544[4]; // extract
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5700 = ~n5699;
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5701 = n5544[3]; // extract
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5702 = ~n5701;
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5703 = n5700 & n5702;
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5704 = n5700 & n5701;
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5705 = n5699 & n5702;
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5706 = n5544[2]; // extract
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5707 = ~n5706;
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5708 = n5703 & n5707;
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5709 = n5703 & n5706;
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5710 = n5704 & n5707;
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5711 = n5704 & n5706;
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5712 = n5705 & n5707;
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5713 = n5544[1]; // extract
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5714 = ~n5713;
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5715 = n5708 & n5714;
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5716 = n5708 & n5713;
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5717 = n5709 & n5714;
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5718 = n5709 & n5713;
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5719 = n5710 & n5714;
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5720 = n5710 & n5713;
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5721 = n5711 & n5714;
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5722 = n5711 & n5713;
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5723 = n5712 & n5714;
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5724 = n5544[0]; // extract
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5725 = ~n5724;
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5726 = n5715 & n5725;
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5727 = n5715 & n5724;
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5728 = n5716 & n5725;
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5729 = n5716 & n5724;
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5730 = n5717 & n5725;
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5731 = n5717 & n5724;
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5732 = n5718 & n5725;
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5733 = n5718 & n5724;
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5734 = n5719 & n5725;
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5735 = n5719 & n5724;
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5736 = n5720 & n5725;
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5737 = n5720 & n5724;
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5738 = n5721 & n5725;
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5739 = n5721 & n5724;
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5740 = n5722 & n5725;
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5741 = n5722 & n5724;
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5742 = n5723 & n5725;
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5743 = n5723 & n5724;
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5744 = phase_array[17:0]; // extract
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5745 = n5726 ? memin : n5744;
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5746 = phase_array[35:18]; // extract
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5747 = n5727 ? memin : n5746;
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5748 = phase_array[53:36]; // extract
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5749 = n5728 ? memin : n5748;
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5750 = phase_array[71:54]; // extract
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5751 = n5729 ? memin : n5750;
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5752 = phase_array[89:72]; // extract
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5753 = n5730 ? memin : n5752;
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5754 = phase_array[107:90]; // extract
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5755 = n5731 ? memin : n5754;
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5756 = phase_array[125:108]; // extract
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5757 = n5732 ? memin : n5756;
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5758 = phase_array[143:126]; // extract
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5759 = n5733 ? memin : n5758;
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5760 = phase_array[161:144]; // extract
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5761 = n5734 ? memin : n5760;
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5762 = phase_array[179:162]; // extract
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5763 = n5735 ? memin : n5762;
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5764 = phase_array[197:180]; // extract
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5765 = n5736 ? memin : n5764;
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5766 = phase_array[215:198]; // extract
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5767 = n5737 ? memin : n5766;
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5768 = phase_array[233:216]; // extract
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5769 = n5738 ? memin : n5768;
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5770 = phase_array[251:234]; // extract
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5771 = n5739 ? memin : n5770;
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5772 = phase_array[269:252]; // extract
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5773 = n5740 ? memin : n5772;
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5774 = phase_array[287:270]; // extract
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5775 = n5741 ? memin : n5774;
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5776 = phase_array[305:288]; // extract
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5777 = n5742 ? memin : n5776;
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5778 = phase_array[323:306]; // extract
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5779 = n5743 ? memin : n5778;
  /*# sim_rtl/phasememory.vhd:93:10 */
  assign n5780 = {n5779, n5777, n5775, n5773, n5771, n5769, n5767, n5765, n5763, n5761, n5759, n5757, n5755, n5753, n5751, n5749, n5747, n5745};
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5781 = n5552[4]; // extract
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5782 = ~n5781;
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5783 = n5552[3]; // extract
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5784 = ~n5783;
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5785 = n5782 & n5784;
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5786 = n5782 & n5783;
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5787 = n5781 & n5784;
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5788 = n5552[2]; // extract
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5789 = ~n5788;
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5790 = n5785 & n5789;
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5791 = n5785 & n5788;
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5792 = n5786 & n5789;
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5793 = n5786 & n5788;
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5794 = n5787 & n5789;
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5795 = n5552[1]; // extract
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5796 = ~n5795;
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5797 = n5790 & n5796;
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5798 = n5790 & n5795;
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5799 = n5791 & n5796;
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5800 = n5791 & n5795;
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5801 = n5792 & n5796;
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5802 = n5792 & n5795;
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5803 = n5793 & n5796;
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5804 = n5793 & n5795;
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5805 = n5794 & n5796;
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5806 = n5552[0]; // extract
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5807 = ~n5806;
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5808 = n5797 & n5807;
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5809 = n5797 & n5806;
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5810 = n5798 & n5807;
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5811 = n5798 & n5806;
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5812 = n5799 & n5807;
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5813 = n5799 & n5806;
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5814 = n5800 & n5807;
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5815 = n5800 & n5806;
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5816 = n5801 & n5807;
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5817 = n5801 & n5806;
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5818 = n5802 & n5807;
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5819 = n5802 & n5806;
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5820 = n5803 & n5807;
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5821 = n5803 & n5806;
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5822 = n5804 & n5807;
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5823 = n5804 & n5806;
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5824 = n5805 & n5807;
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5825 = n5805 & n5806;
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5826 = phase_array[17:0]; // extract
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5827 = n5808 ? n5554 : n5826;
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5828 = phase_array[35:18]; // extract
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5829 = n5809 ? n5554 : n5828;
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5830 = phase_array[53:36]; // extract
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5831 = n5810 ? n5554 : n5830;
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5832 = phase_array[71:54]; // extract
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5833 = n5811 ? n5554 : n5832;
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5834 = phase_array[89:72]; // extract
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5835 = n5812 ? n5554 : n5834;
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5836 = phase_array[107:90]; // extract
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5837 = n5813 ? n5554 : n5836;
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5838 = phase_array[125:108]; // extract
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5839 = n5814 ? n5554 : n5838;
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5840 = phase_array[143:126]; // extract
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5841 = n5815 ? n5554 : n5840;
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5842 = phase_array[161:144]; // extract
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5843 = n5816 ? n5554 : n5842;
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5844 = phase_array[179:162]; // extract
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5845 = n5817 ? n5554 : n5844;
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5846 = phase_array[197:180]; // extract
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5847 = n5818 ? n5554 : n5846;
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5848 = phase_array[215:198]; // extract
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5849 = n5819 ? n5554 : n5848;
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5850 = phase_array[233:216]; // extract
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5851 = n5820 ? n5554 : n5850;
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5852 = phase_array[251:234]; // extract
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5853 = n5821 ? n5554 : n5852;
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5854 = phase_array[269:252]; // extract
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5855 = n5822 ? n5554 : n5854;
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5856 = phase_array[287:270]; // extract
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5857 = n5823 ? n5554 : n5856;
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5858 = phase_array[305:288]; // extract
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5859 = n5824 ? n5554 : n5858;
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5860 = phase_array[323:306]; // extract
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5861 = n5825 ? n5554 : n5860;
  /*# sim_rtl/phasememory.vhd:99:1 */
  assign n5862 = {n5861, n5859, n5857, n5855, n5853, n5851, n5849, n5847, n5845, n5843, n5841, n5839, n5837, n5835, n5833, n5831, n5829, n5827};
  /*# sim_rtl/phasememory.vhd:101:49 */
  assign n5864 = {252'bX, phase_array};
  /*# sim_rtl/phasememory.vhd:101:49 */
  assign n5865 = n5864[n5560 * 18 +: 18]; //(Bmux)
  /*# sim_rtl/phasememory.vhd:101:91 */
  assign n5867 = {252'bX, phase_array};
  /*# sim_rtl/phasememory.vhd:101:91 */
  assign n5868 = n5867[n5565 * 18 +: 18]; //(Bmux)
endmodule

module envelopememory_Brtl
  (input  clk,
   input  reset,
   input  [4:0] waddr,
   input  wr,
   input  [1:0] \wdata[state] ,
   input  [22:0] \wdata[phase] ,
   input  [4:0] raddr,
   output [1:0] \rdata[state] ,
   output [22:0] \rdata[phase] ,
   input  ss_hold,
   input  [7:0] ss_addr,
   input  ss_read,
   input  ss_write,
   input  [31:0] ss_wdata,
   output [31:0] ss_rdata,
   output ss_initialized);
  wire [24:0] n5122;
  wire [1:0] n5124;
  wire [22:0] n5125;
  wire [449:0] egdata_set;
  reg [31:0] ss_local_data;
  wire ss_mem_active;
  wire [4:0] ss_mem_index;
  reg ss_mem_ready;
  wire [24:0] ss_mem_vector;
  reg [4:0] n5130_init_slot;
  wire [31:0] n5134;
  wire n5136;
  wire n5139;
  wire n5141;
  wire [31:0] n5142;
  wire n5144;
  wire [4:0] n5146;
  wire [31:0] n5150;
  wire [31:0] n5152;
  wire [4:0] n5153;
  wire [4:0] n5156;
  wire [1:0] n5163;
  wire [22:0] n5164;
  wire [24:0] n5165;
  wire [449:0] n5167;
  wire [449:0] n5168;
  wire n5170;
  wire [4:0] n5172;
  wire [24:0] n5174;
  wire [449:0] n5176;
  wire [449:0] n5177;
  wire n5178;
  wire [4:0] n5181;
  wire [1:0] n5188;
  wire [22:0] n5189;
  wire [24:0] n5190;
  wire [4:0] n5194;
  wire [1:0] n5201;
  wire [22:0] n5202;
  wire [24:0] n5203;
  wire [24:0] n5204;
  wire [31:0] n5217;
  wire n5219;
  wire n5220;
  wire [31:0] n5221;
  wire n5223;
  wire n5224;
  wire n5225;
  wire [31:0] n5227;
  wire [31:0] n5229;
  wire [4:0] n5230;
  wire [31:0] n5231;
  wire n5233;
  wire [31:0] n5234;
  wire n5236;
  wire n5237;
  wire [4:0] n5238;
  wire [1:0] n5245;
  wire [22:0] n5246;
  wire [24:0] n5247;
  wire [31:0] n5249;
  wire [31:0] n5250;
  wire n5252;
  wire [24:0] n5253;
  reg [24:0] n5254;
  wire n5255;
  wire [449:0] n5256;
  reg [449:0] n5257;
  reg n5258;
  wire [4:0] n5259;
  reg [4:0] n5260;
  wire n5261;
  wire n5262;
  wire n5263;
  wire n5264;
  wire n5265;
  wire n5266;
  wire n5267;
  wire n5268;
  wire n5269;
  wire n5270;
  wire n5271;
  wire n5272;
  wire n5273;
  wire n5274;
  wire n5275;
  wire n5276;
  wire n5277;
  wire n5278;
  wire n5279;
  wire n5280;
  wire n5281;
  wire n5282;
  wire n5283;
  wire n5284;
  wire n5285;
  wire n5286;
  wire n5287;
  wire n5288;
  wire n5289;
  wire n5290;
  wire n5291;
  wire n5292;
  wire n5293;
  wire n5294;
  wire n5295;
  wire n5296;
  wire n5297;
  wire n5298;
  wire n5299;
  wire n5300;
  wire n5301;
  wire n5302;
  wire n5303;
  wire n5304;
  wire n5305;
  wire [24:0] n5306;
  wire [24:0] n5307;
  wire [24:0] n5308;
  wire [24:0] n5309;
  wire [24:0] n5310;
  wire [24:0] n5311;
  wire [24:0] n5312;
  wire [24:0] n5313;
  wire [24:0] n5314;
  wire [24:0] n5315;
  wire [24:0] n5316;
  wire [24:0] n5317;
  wire [24:0] n5318;
  wire [24:0] n5319;
  wire [24:0] n5320;
  wire [24:0] n5321;
  wire [24:0] n5322;
  wire [24:0] n5323;
  wire [24:0] n5324;
  wire [24:0] n5325;
  wire [24:0] n5326;
  wire [24:0] n5327;
  wire [24:0] n5328;
  wire [24:0] n5329;
  wire [24:0] n5330;
  wire [24:0] n5331;
  wire [24:0] n5332;
  wire [24:0] n5333;
  wire [24:0] n5334;
  wire [24:0] n5335;
  wire [24:0] n5336;
  wire [24:0] n5337;
  wire [24:0] n5338;
  wire [24:0] n5339;
  wire [24:0] n5340;
  wire [24:0] n5341;
  wire [449:0] n5342;
  wire n5343;
  wire n5344;
  wire n5345;
  wire n5346;
  wire n5347;
  wire n5348;
  wire n5349;
  wire n5350;
  wire n5351;
  wire n5352;
  wire n5353;
  wire n5354;
  wire n5355;
  wire n5356;
  wire n5357;
  wire n5358;
  wire n5359;
  wire n5360;
  wire n5361;
  wire n5362;
  wire n5363;
  wire n5364;
  wire n5365;
  wire n5366;
  wire n5367;
  wire n5368;
  wire n5369;
  wire n5370;
  wire n5371;
  wire n5372;
  wire n5373;
  wire n5374;
  wire n5375;
  wire n5376;
  wire n5377;
  wire n5378;
  wire n5379;
  wire n5380;
  wire n5381;
  wire n5382;
  wire n5383;
  wire n5384;
  wire n5385;
  wire n5386;
  wire n5387;
  wire [24:0] n5388;
  wire [24:0] n5389;
  wire [24:0] n5390;
  wire [24:0] n5391;
  wire [24:0] n5392;
  wire [24:0] n5393;
  wire [24:0] n5394;
  wire [24:0] n5395;
  wire [24:0] n5396;
  wire [24:0] n5397;
  wire [24:0] n5398;
  wire [24:0] n5399;
  wire [24:0] n5400;
  wire [24:0] n5401;
  wire [24:0] n5402;
  wire [24:0] n5403;
  wire [24:0] n5404;
  wire [24:0] n5405;
  wire [24:0] n5406;
  wire [24:0] n5407;
  wire [24:0] n5408;
  wire [24:0] n5409;
  wire [24:0] n5410;
  wire [24:0] n5411;
  wire [24:0] n5412;
  wire [24:0] n5413;
  wire [24:0] n5414;
  wire [24:0] n5415;
  wire [24:0] n5416;
  wire [24:0] n5417;
  wire [24:0] n5418;
  wire [24:0] n5419;
  wire [24:0] n5420;
  wire [24:0] n5421;
  wire [24:0] n5422;
  wire [24:0] n5423;
  wire [449:0] n5424;
  wire n5425;
  wire n5426;
  wire n5427;
  wire n5428;
  wire n5429;
  wire n5430;
  wire n5431;
  wire n5432;
  wire n5433;
  wire n5434;
  wire n5435;
  wire n5436;
  wire n5437;
  wire n5438;
  wire n5439;
  wire n5440;
  wire n5441;
  wire n5442;
  wire n5443;
  wire n5444;
  wire n5445;
  wire n5446;
  wire n5447;
  wire n5448;
  wire n5449;
  wire n5450;
  wire n5451;
  wire n5452;
  wire n5453;
  wire n5454;
  wire n5455;
  wire n5456;
  wire n5457;
  wire n5458;
  wire n5459;
  wire n5460;
  wire n5461;
  wire n5462;
  wire n5463;
  wire n5464;
  wire n5465;
  wire n5466;
  wire n5467;
  wire n5468;
  wire n5469;
  wire [24:0] n5470;
  wire [24:0] n5471;
  wire [24:0] n5472;
  wire [24:0] n5473;
  wire [24:0] n5474;
  wire [24:0] n5475;
  wire [24:0] n5476;
  wire [24:0] n5477;
  wire [24:0] n5478;
  wire [24:0] n5479;
  wire [24:0] n5480;
  wire [24:0] n5481;
  wire [24:0] n5482;
  wire [24:0] n5483;
  wire [24:0] n5484;
  wire [24:0] n5485;
  wire [24:0] n5486;
  wire [24:0] n5487;
  wire [24:0] n5488;
  wire [24:0] n5489;
  wire [24:0] n5490;
  wire [24:0] n5491;
  wire [24:0] n5492;
  wire [24:0] n5493;
  wire [24:0] n5494;
  wire [24:0] n5495;
  wire [24:0] n5496;
  wire [24:0] n5497;
  wire [24:0] n5498;
  wire [24:0] n5499;
  wire [24:0] n5500;
  wire [24:0] n5501;
  wire [24:0] n5502;
  wire [24:0] n5503;
  wire [24:0] n5504;
  wire [24:0] n5505;
  wire [449:0] n5506;
  wire [799:0] n5508;
  wire [24:0] n5509;
  wire [799:0] n5511;
  wire [24:0] n5512;
  assign \rdata[state]  = n5124; //(module output)
  assign \rdata[phase]  = n5125; //(module output)
  assign ss_rdata = ss_local_data; //(module output)
  assign ss_initialized = ss_mem_ready; //(module output)
  /*# sim_rtl/envelopememory.vhd:37:8 */
  assign n5122 = {\wdata[phase] , \wdata[state] };
  /*# sim_rtl/envelopememory.vhd:37:8 */
  assign n5124 = n5254[1:0]; // extract
  /*# sim_rtl/envelopememory.vhd:37:8 */
  assign n5125 = n5254[24:2]; // extract
  /*# sim_rtl/envelopememory.vhd:61:10 */
  assign egdata_set = n5257; // (signal)
  /*# sim_rtl/envelopememory.vhd:63:12 */
  always @*
    ss_local_data = n5250; // (isignal)
  initial
    ss_local_data = 32'b00000000000000000000000000000000;
  /*# sim_rtl/envelopememory.vhd:64:12 */
  assign ss_mem_active = n5225; // (signal)
  /*# sim_rtl/envelopememory.vhd:65:12 */
  assign ss_mem_index = n5238; // (signal)
  /*# sim_rtl/envelopememory.vhd:66:12 */
  always @*
    ss_mem_ready = n5258; // (isignal)
  initial
    ss_mem_ready = 1'b0;
  /*# sim_rtl/envelopememory.vhd:67:12 */
  assign ss_mem_vector = n5247; // (signal)
  /*# sim_rtl/envelopememory.vhd:73:14 */
  always @*
    n5130_init_slot = n5260; // (isignal)
  initial
    n5130_init_slot = 5'b00000;
  /*# sim_rtl/envelopememory.vhd:84:39 */
  assign n5134 = {27'b0, n5130_init_slot};  // uext
  /*# sim_rtl/envelopememory.vhd:84:39 */
  assign n5136 = n5134 == 32'b00000000000000000000000000010010;
  /*# sim_rtl/envelopememory.vhd:84:27 */
  assign n5139 = n5136 ? 1'b1 : 1'b0;
  /*# sim_rtl/envelopememory.vhd:85:11 */
  assign n5141 = ~ss_hold;
  /*# sim_rtl/envelopememory.vhd:86:14 */
  assign n5142 = {27'b0, n5130_init_slot};  // uext
  /*# sim_rtl/envelopememory.vhd:86:14 */
  assign n5144 = n5142 != 32'b00000000000000000000000000010010;
  /*# sim_rtl/envelopememory.vhd:87:19 */
  assign n5146 = 5'b10001 - n5130_init_slot;
  /*# sim_rtl/envelopememory.vhd:88:31 */
  assign n5150 = {27'b0, n5130_init_slot};  // uext
  /*# sim_rtl/envelopememory.vhd:88:31 */
  assign n5152 = n5150 + 32'b00000000000000000000000000000001;
  /*# sim_rtl/envelopememory.vhd:88:8 */
  assign n5153 = n5152[4:0];  // trunc
  /*# sim_rtl/envelopememory.vhd:90:19 */
  assign n5156 = 5'b10001 - waddr;
  /*# sim_rtl/vm2413.vhd:215:17 */
  assign n5163 = n5122[1:0]; // extract
  /*# sim_rtl/vm2413.vhd:215:30 */
  assign n5164 = n5122[24:2]; // extract
  /*# sim_rtl/vm2413.vhd:215:23 */
  assign n5165 = {n5163, n5164};
  /*# sim_rtl/envelopememory.vhd:89:6 */
  assign n5167 = wr ? n5424 : egdata_set;
  /*# sim_rtl/envelopememory.vhd:86:1 */
  assign n5168 = n5144 ? n5342 : n5167;
  /*# sim_rtl/envelopememory.vhd:93:20 */
  assign n5170 = ss_mem_active & ss_write;
  /*# sim_rtl/envelopememory.vhd:94:12 */
  assign n5172 = 5'b10001 - ss_mem_index;
  /*# sim_rtl/envelopememory.vhd:94:35 */
  assign n5174 = ss_wdata[24:0]; // extract
  /*# sim_rtl/envelopememory.vhd:93:1 */
  assign n5176 = n5170 ? n5506 : egdata_set;
  /*# sim_rtl/envelopememory.vhd:85:1 */
  assign n5177 = n5141 ? n5168 : n5176;
  /*# sim_rtl/envelopememory.vhd:85:1 */
  assign n5178 = n5144 & n5141;
  /*# sim_rtl/envelopememory.vhd:96:59 */
  assign n5181 = 5'b10001 - ss_mem_index;
  /*# sim_rtl/vm2413.vhd:220:26 */
  assign n5188 = n5509[24:23]; // extract
  /*# sim_rtl/vm2413.vhd:221:26 */
  assign n5189 = n5509[22:0]; // extract
  /*# sim_rtl/vm2413.vhd:220:12 */
  assign n5190 = {n5189, n5188};
  /*# sim_rtl/envelopememory.vhd:96:112 */
  assign n5194 = 5'b10001 - raddr;
  /*# sim_rtl/vm2413.vhd:220:26 */
  assign n5201 = n5512[24:23]; // extract
  /*# sim_rtl/vm2413.vhd:221:26 */
  assign n5202 = n5512[22:0]; // extract
  /*# sim_rtl/vm2413.vhd:220:12 */
  assign n5203 = {n5202, n5201};
  /*# sim_rtl/envelopememory.vhd:96:1 */
  assign n5204 = ss_mem_active ? n5190 : n5203;
  /*# sim_rtl/envelopememory.vhd:101:43 */
  assign n5217 = {24'b0, ss_addr};  // uext
  /*# sim_rtl/envelopememory.vhd:101:64 */
  assign n5219 = $signed(n5217) >= $signed(32'b00000000000000000000000000011111);
  /*# sim_rtl/envelopememory.vhd:101:39 */
  assign n5220 = n5219 & ss_hold;
  /*# sim_rtl/envelopememory.vhd:101:73 */
  assign n5221 = {24'b0, ss_addr};  // uext
  /*# sim_rtl/envelopememory.vhd:101:94 */
  assign n5223 = $signed(n5221) <= $signed(32'b00000000000000000000000000110000);
  /*# sim_rtl/envelopememory.vhd:101:69 */
  assign n5224 = n5223 & n5220;
  /*# sim_rtl/envelopememory.vhd:101:22 */
  assign n5225 = n5224 ? 1'b1 : 1'b0;
  /*# sim_rtl/envelopememory.vhd:102:17 */
  assign n5227 = {24'b0, ss_addr};  // uext
  /*# sim_rtl/envelopememory.vhd:102:38 */
  assign n5229 = n5227 - 32'b00000000000000000000000000011111;
  /*# sim_rtl/envelopememory.vhd:102:17 */
  assign n5230 = n5229[4:0];  // trunc
  /*# sim_rtl/envelopememory.vhd:102:47 */
  assign n5231 = {24'b0, ss_addr};  // uext
  /*# sim_rtl/envelopememory.vhd:102:68 */
  assign n5233 = $signed(n5231) >= $signed(32'b00000000000000000000000000011111);
  /*# sim_rtl/envelopememory.vhd:102:77 */
  assign n5234 = {24'b0, ss_addr};  // uext
  /*# sim_rtl/envelopememory.vhd:102:98 */
  assign n5236 = $signed(n5234) <= $signed(32'b00000000000000000000000000110000);
  /*# sim_rtl/envelopememory.vhd:102:73 */
  assign n5237 = n5236 & n5233;
  /*# sim_rtl/envelopememory.vhd:102:42 */
  assign n5238 = n5237 ? n5230 : 5'b00000;
  /*# sim_rtl/vm2413.vhd:215:17 */
  assign n5245 = n5254[1:0]; // extract
  /*# sim_rtl/vm2413.vhd:215:30 */
  assign n5246 = n5254[24:2]; // extract
  /*# sim_rtl/vm2413.vhd:215:23 */
  assign n5247 = {n5245, n5246};
  /*# sim_rtl/envelopememory.vhd:104:38 */
  assign n5249 = {7'b0000000, ss_mem_vector};
  /*# sim_rtl/envelopememory.vhd:104:54 */
  assign n5250 = ss_mem_active ? n5249 : 32'b00000000000000000000000000000000;
  /*# sim_rtl/envelopememory.vhd:45:3 */
  assign n5252 = ~reset;
  /*# sim_rtl/envelopememory.vhd:82:4 */
  assign n5253 = n5252 ? n5204 : n5254;
  /*# sim_rtl/envelopememory.vhd:82:4 */
  always @(posedge clk)
    n5254 <= n5253;
  /*# sim_rtl/envelopememory.vhd:61:10 */
  assign n5255 = ~reset;
  /*# sim_rtl/envelopememory.vhd:82:4 */
  assign n5256 = n5255 ? n5177 : egdata_set;
  /*# sim_rtl/envelopememory.vhd:82:4 */
  always @(posedge clk)
    n5257 <= n5256;
  /*# sim_rtl/envelopememory.vhd:82:4 */
  always @(posedge clk or posedge reset)
    if (reset)
      n5258 <= 1'b0;
    else
      n5258 <= n5139;
  /*# sim_rtl/envelopememory.vhd:82:4 */
  assign n5259 = n5178 ? n5153 : n5130_init_slot;
  /*# sim_rtl/envelopememory.vhd:82:4 */
  always @(posedge clk or posedge reset)
    if (reset)
      n5260 <= 5'b00000;
    else
      n5260 <= n5259;
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5261 = n5146[4]; // extract
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5262 = ~n5261;
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5263 = n5146[3]; // extract
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5264 = ~n5263;
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5265 = n5262 & n5264;
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5266 = n5262 & n5263;
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5267 = n5261 & n5264;
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5268 = n5146[2]; // extract
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5269 = ~n5268;
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5270 = n5265 & n5269;
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5271 = n5265 & n5268;
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5272 = n5266 & n5269;
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5273 = n5266 & n5268;
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5274 = n5267 & n5269;
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5275 = n5146[1]; // extract
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5276 = ~n5275;
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5277 = n5270 & n5276;
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5278 = n5270 & n5275;
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5279 = n5271 & n5276;
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5280 = n5271 & n5275;
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5281 = n5272 & n5276;
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5282 = n5272 & n5275;
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5283 = n5273 & n5276;
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5284 = n5273 & n5275;
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5285 = n5274 & n5276;
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5286 = n5146[0]; // extract
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5287 = ~n5286;
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5288 = n5277 & n5287;
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5289 = n5277 & n5286;
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5290 = n5278 & n5287;
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5291 = n5278 & n5286;
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5292 = n5279 & n5287;
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5293 = n5279 & n5286;
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5294 = n5280 & n5287;
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5295 = n5280 & n5286;
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5296 = n5281 & n5287;
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5297 = n5281 & n5286;
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5298 = n5282 & n5287;
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5299 = n5282 & n5286;
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5300 = n5283 & n5287;
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5301 = n5283 & n5286;
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5302 = n5284 & n5287;
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5303 = n5284 & n5286;
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5304 = n5285 & n5287;
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5305 = n5285 & n5286;
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5306 = egdata_set[24:0]; // extract
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5307 = n5288 ? 25'b1111111111111111111111111 : n5306;
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5308 = egdata_set[49:25]; // extract
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5309 = n5289 ? 25'b1111111111111111111111111 : n5308;
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5310 = egdata_set[74:50]; // extract
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5311 = n5290 ? 25'b1111111111111111111111111 : n5310;
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5312 = egdata_set[99:75]; // extract
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5313 = n5291 ? 25'b1111111111111111111111111 : n5312;
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5314 = egdata_set[124:100]; // extract
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5315 = n5292 ? 25'b1111111111111111111111111 : n5314;
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5316 = egdata_set[149:125]; // extract
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5317 = n5293 ? 25'b1111111111111111111111111 : n5316;
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5318 = egdata_set[174:150]; // extract
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5319 = n5294 ? 25'b1111111111111111111111111 : n5318;
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5320 = egdata_set[199:175]; // extract
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5321 = n5295 ? 25'b1111111111111111111111111 : n5320;
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5322 = egdata_set[224:200]; // extract
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5323 = n5296 ? 25'b1111111111111111111111111 : n5322;
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5324 = egdata_set[249:225]; // extract
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5325 = n5297 ? 25'b1111111111111111111111111 : n5324;
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5326 = egdata_set[274:250]; // extract
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5327 = n5298 ? 25'b1111111111111111111111111 : n5326;
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5328 = egdata_set[299:275]; // extract
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5329 = n5299 ? 25'b1111111111111111111111111 : n5328;
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5330 = egdata_set[324:300]; // extract
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5331 = n5300 ? 25'b1111111111111111111111111 : n5330;
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5332 = egdata_set[349:325]; // extract
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5333 = n5301 ? 25'b1111111111111111111111111 : n5332;
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5334 = egdata_set[374:350]; // extract
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5335 = n5302 ? 25'b1111111111111111111111111 : n5334;
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5336 = egdata_set[399:375]; // extract
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5337 = n5303 ? 25'b1111111111111111111111111 : n5336;
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5338 = egdata_set[424:400]; // extract
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5339 = n5304 ? 25'b1111111111111111111111111 : n5338;
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5340 = egdata_set[449:425]; // extract
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5341 = n5305 ? 25'b1111111111111111111111111 : n5340;
  /*# sim_rtl/envelopememory.vhd:87:8 */
  assign n5342 = {n5341, n5339, n5337, n5335, n5333, n5331, n5329, n5327, n5325, n5323, n5321, n5319, n5317, n5315, n5313, n5311, n5309, n5307};
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5343 = n5156[4]; // extract
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5344 = ~n5343;
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5345 = n5156[3]; // extract
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5346 = ~n5345;
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5347 = n5344 & n5346;
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5348 = n5344 & n5345;
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5349 = n5343 & n5346;
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5350 = n5156[2]; // extract
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5351 = ~n5350;
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5352 = n5347 & n5351;
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5353 = n5347 & n5350;
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5354 = n5348 & n5351;
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5355 = n5348 & n5350;
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5356 = n5349 & n5351;
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5357 = n5156[1]; // extract
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5358 = ~n5357;
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5359 = n5352 & n5358;
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5360 = n5352 & n5357;
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5361 = n5353 & n5358;
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5362 = n5353 & n5357;
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5363 = n5354 & n5358;
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5364 = n5354 & n5357;
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5365 = n5355 & n5358;
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5366 = n5355 & n5357;
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5367 = n5356 & n5358;
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5368 = n5156[0]; // extract
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5369 = ~n5368;
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5370 = n5359 & n5369;
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5371 = n5359 & n5368;
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5372 = n5360 & n5369;
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5373 = n5360 & n5368;
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5374 = n5361 & n5369;
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5375 = n5361 & n5368;
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5376 = n5362 & n5369;
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5377 = n5362 & n5368;
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5378 = n5363 & n5369;
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5379 = n5363 & n5368;
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5380 = n5364 & n5369;
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5381 = n5364 & n5368;
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5382 = n5365 & n5369;
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5383 = n5365 & n5368;
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5384 = n5366 & n5369;
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5385 = n5366 & n5368;
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5386 = n5367 & n5369;
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5387 = n5367 & n5368;
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5388 = egdata_set[24:0]; // extract
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5389 = n5370 ? n5165 : n5388;
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5390 = egdata_set[49:25]; // extract
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5391 = n5371 ? n5165 : n5390;
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5392 = egdata_set[74:50]; // extract
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5393 = n5372 ? n5165 : n5392;
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5394 = egdata_set[99:75]; // extract
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5395 = n5373 ? n5165 : n5394;
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5396 = egdata_set[124:100]; // extract
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5397 = n5374 ? n5165 : n5396;
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5398 = egdata_set[149:125]; // extract
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5399 = n5375 ? n5165 : n5398;
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5400 = egdata_set[174:150]; // extract
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5401 = n5376 ? n5165 : n5400;
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5402 = egdata_set[199:175]; // extract
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5403 = n5377 ? n5165 : n5402;
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5404 = egdata_set[224:200]; // extract
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5405 = n5378 ? n5165 : n5404;
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5406 = egdata_set[249:225]; // extract
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5407 = n5379 ? n5165 : n5406;
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5408 = egdata_set[274:250]; // extract
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5409 = n5380 ? n5165 : n5408;
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5410 = egdata_set[299:275]; // extract
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5411 = n5381 ? n5165 : n5410;
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5412 = egdata_set[324:300]; // extract
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5413 = n5382 ? n5165 : n5412;
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5414 = egdata_set[349:325]; // extract
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5415 = n5383 ? n5165 : n5414;
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5416 = egdata_set[374:350]; // extract
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5417 = n5384 ? n5165 : n5416;
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5418 = egdata_set[399:375]; // extract
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5419 = n5385 ? n5165 : n5418;
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5420 = egdata_set[424:400]; // extract
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5421 = n5386 ? n5165 : n5420;
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5422 = egdata_set[449:425]; // extract
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5423 = n5387 ? n5165 : n5422;
  /*# sim_rtl/envelopememory.vhd:90:8 */
  assign n5424 = {n5423, n5421, n5419, n5417, n5415, n5413, n5411, n5409, n5407, n5405, n5403, n5401, n5399, n5397, n5395, n5393, n5391, n5389};
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5425 = n5172[4]; // extract
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5426 = ~n5425;
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5427 = n5172[3]; // extract
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5428 = ~n5427;
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5429 = n5426 & n5428;
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5430 = n5426 & n5427;
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5431 = n5425 & n5428;
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5432 = n5172[2]; // extract
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5433 = ~n5432;
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5434 = n5429 & n5433;
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5435 = n5429 & n5432;
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5436 = n5430 & n5433;
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5437 = n5430 & n5432;
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5438 = n5431 & n5433;
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5439 = n5172[1]; // extract
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5440 = ~n5439;
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5441 = n5434 & n5440;
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5442 = n5434 & n5439;
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5443 = n5435 & n5440;
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5444 = n5435 & n5439;
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5445 = n5436 & n5440;
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5446 = n5436 & n5439;
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5447 = n5437 & n5440;
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5448 = n5437 & n5439;
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5449 = n5438 & n5440;
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5450 = n5172[0]; // extract
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5451 = ~n5450;
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5452 = n5441 & n5451;
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5453 = n5441 & n5450;
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5454 = n5442 & n5451;
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5455 = n5442 & n5450;
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5456 = n5443 & n5451;
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5457 = n5443 & n5450;
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5458 = n5444 & n5451;
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5459 = n5444 & n5450;
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5460 = n5445 & n5451;
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5461 = n5445 & n5450;
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5462 = n5446 & n5451;
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5463 = n5446 & n5450;
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5464 = n5447 & n5451;
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5465 = n5447 & n5450;
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5466 = n5448 & n5451;
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5467 = n5448 & n5450;
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5468 = n5449 & n5451;
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5469 = n5449 & n5450;
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5470 = egdata_set[24:0]; // extract
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5471 = n5452 ? n5174 : n5470;
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5472 = egdata_set[49:25]; // extract
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5473 = n5453 ? n5174 : n5472;
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5474 = egdata_set[74:50]; // extract
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5475 = n5454 ? n5174 : n5474;
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5476 = egdata_set[99:75]; // extract
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5477 = n5455 ? n5174 : n5476;
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5478 = egdata_set[124:100]; // extract
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5479 = n5456 ? n5174 : n5478;
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5480 = egdata_set[149:125]; // extract
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5481 = n5457 ? n5174 : n5480;
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5482 = egdata_set[174:150]; // extract
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5483 = n5458 ? n5174 : n5482;
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5484 = egdata_set[199:175]; // extract
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5485 = n5459 ? n5174 : n5484;
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5486 = egdata_set[224:200]; // extract
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5487 = n5460 ? n5174 : n5486;
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5488 = egdata_set[249:225]; // extract
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5489 = n5461 ? n5174 : n5488;
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5490 = egdata_set[274:250]; // extract
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5491 = n5462 ? n5174 : n5490;
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5492 = egdata_set[299:275]; // extract
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5493 = n5463 ? n5174 : n5492;
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5494 = egdata_set[324:300]; // extract
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5495 = n5464 ? n5174 : n5494;
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5496 = egdata_set[349:325]; // extract
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5497 = n5465 ? n5174 : n5496;
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5498 = egdata_set[374:350]; // extract
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5499 = n5466 ? n5174 : n5498;
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5500 = egdata_set[399:375]; // extract
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5501 = n5467 ? n5174 : n5500;
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5502 = egdata_set[424:400]; // extract
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5503 = n5468 ? n5174 : n5502;
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5504 = egdata_set[449:425]; // extract
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5505 = n5469 ? n5174 : n5504;
  /*# sim_rtl/envelopememory.vhd:94:1 */
  assign n5506 = {n5505, n5503, n5501, n5499, n5497, n5495, n5493, n5491, n5489, n5487, n5485, n5483, n5481, n5479, n5477, n5475, n5473, n5471};
  /*# sim_rtl/envelopememory.vhd:96:59 */
  assign n5508 = {350'bX, egdata_set};
  /*# sim_rtl/envelopememory.vhd:96:59 */
  assign n5509 = n5508[n5181 * 25 +: 25]; //(Bmux)
  /*# sim_rtl/envelopememory.vhd:96:112 */
  assign n5511 = {350'bX, egdata_set};
  /*# sim_rtl/envelopememory.vhd:96:112 */
  assign n5512 = n5511[n5194 * 25 +: 25]; //(Bmux)
endmodule

module attacktable_Brtl
  (input  clk,
   input  clkena,
   input  [21:0] addr,
   output [12:0] data,
   input  ss_hold,
   input  [7:0] ss_addr,
   input  ss_read,
   input  ss_write,
   input  [31:0] ss_wdata,
   output [31:0] ss_rdata,
   output ss_initialized);
  wire [7:0] ff_w;
  wire [6:0] ff_d1;
  wire [6:0] ff_d2;
  wire [6:0] w_addr1;
  wire [6:0] w_addr2;
  wire [7:0] w_sub;
  wire [13:0] w_mul;
  wire [13:0] w_inter;
  reg [31:0] ss_local_data;
  wire [6:0] n4987;
  wire [6:0] n4989;
  wire n4991;
  wire [6:0] n4992;
  wire [6:0] n4994;
  wire n5003;
  wire n5004;
  wire [31:0] n5005;
  wire n5007;
  wire n5009;
  wire [1:0] n5010;
  wire [7:0] n5011;
  reg [7:0] n5013;
  wire [4:0] n5014;
  wire [4:0] n5015;
  reg [4:0] n5017;
  wire [1:0] n5018;
  reg [1:0] n5020;
  reg [6:0] n5022;
  wire [21:0] n5023;
  wire [21:0] n5025;
  wire [31:0] n5026;
  wire [7:0] n5027;
  wire [6:0] n5028;
  wire [6:0] n5029;
  wire n5031;
  wire [12:0] n5032;
  wire n5034;
  wire [1:0] n5035;
  reg [12:0] n5036;
  reg [7:0] n5037;
  reg [6:0] n5038;
  reg [6:0] n5039;
  wire [12:0] n5044;
  wire [7:0] n5045;
  wire [6:0] n5046;
  wire [6:0] n5047;
  wire n5052;
  wire n5053;
  wire n5054;
  wire n5055;
  wire [21:0] n5061;
  localparam [31:0] n5062 = 32'b00000000000000000000000000000000;
  wire [9:0] n5063;
  wire [31:0] n5064;
  wire n5065;
  wire [6:0] n5077;
  wire [6:0] n5078;
  wire [7:0] n5079;
  wire [7:0] n5080;
  wire [12:0] n5081;
  wire [12:0] n5082;
  wire n5083;
  wire n5084;
  wire n5085;
  wire n5086;
  wire [7:0] n5100;
  wire [7:0] n5102;
  wire [7:0] n5103;
  wire [13:0] u_attack_table_mul_n5104;
  wire [7:0] n5108;
  wire [13:0] n5110;
  wire [13:0] n5111;
  localparam n5112 = 1'b1;
  reg [12:0] n5113;
  reg [7:0] n5114;
  reg [6:0] n5115;
  reg [6:0] n5116;
  reg [31:0] n5117;
  wire [6:0] n5120; // mem_rd
  wire [6:0] n5121; // mem_rd
  assign data = n5113; //(module output)
  assign ss_rdata = ss_local_data; //(module output)
  assign ss_initialized = n5112; //(module output)
  /*# sim_rtl/attacktable.vhd:113:12 */
  assign ff_w = n5114; // (signal)
  /*# sim_rtl/attacktable.vhd:114:12 */
  assign ff_d1 = n5115; // (signal)
  /*# sim_rtl/attacktable.vhd:115:12 */
  assign ff_d2 = n5116; // (signal)
  /*# sim_rtl/attacktable.vhd:117:12 */
  assign w_addr1 = n4987; // (signal)
  /*# sim_rtl/attacktable.vhd:118:12 */
  assign w_addr2 = n4992; // (signal)
  /*# sim_rtl/attacktable.vhd:119:12 */
  assign w_sub = n5103; // (signal)
  /*# sim_rtl/attacktable.vhd:120:12 */
  assign w_mul = u_attack_table_mul_n5104; // (signal)
  /*# sim_rtl/attacktable.vhd:121:12 */
  assign w_inter = n5111; // (signal)
  /*# sim_rtl/attacktable.vhd:122:12 */
  always @*
    ss_local_data = n5117; // (isignal)
  initial
    ss_local_data = 32'b00000000000000000000000000000000;
  /*# sim_rtl/attacktable.vhd:126:20 */
  assign n4987 = addr[21:15]; // extract
  /*# sim_rtl/attacktable.vhd:127:42 */
  assign n4989 = addr[21:15]; // extract
  /*# sim_rtl/attacktable.vhd:127:59 */
  assign n4991 = n4989 == 7'b1111111;
  /*# sim_rtl/attacktable.vhd:127:32 */
  assign n4992 = n4991 ? 7'b1111111 : n4994;
  /*# sim_rtl/attacktable.vhd:128:24 */
  assign n4994 = w_addr1 + 7'b0000001;
  /*# sim_rtl/attacktable.vhd:146:33 */
  assign n5003 = ss_read | ss_write;
  /*# sim_rtl/attacktable.vhd:146:16 */
  assign n5004 = n5003 & ss_hold;
  /*# sim_rtl/attacktable.vhd:153:6 */
  assign n5005 = {24'b0, ss_addr};  // uext
  /*# sim_rtl/attacktable.vhd:154:1 */
  assign n5007 = n5005 == 32'b00000000000000000000000001011011;
  /*# sim_rtl/attacktable.vhd:158:1 */
  assign n5009 = n5005 == 32'b00000000000000000000000001011100;
  /*# sim_rtl/attacktable.vhd:153:1 */
  assign n5010 = {n5009, n5007};
  /*# sim_rtl/attacktable.vhd:70:9 */
  assign n5011 = n5113[7:0]; // extract
  /*# sim_rtl/attacktable.vhd:153:1 */
  always @*
    case (n5010)
      2'b10: n5013 = n5011;
      2'b01: n5013 = ff_w;
      default: n5013 = 8'b00000000;
    endcase
  /*# sim_rtl/attacktable.vhd:114:12 */
  assign n5014 = ff_d1[4:0]; // extract
  /*# sim_rtl/attacktable.vhd:70:9 */
  assign n5015 = n5113[12:8]; // extract
  /*# sim_rtl/attacktable.vhd:153:1 */
  always @*
    case (n5010)
      2'b10: n5017 = n5015;
      2'b01: n5017 = n5014;
      default: n5017 = 5'b00000;
    endcase
  /*# sim_rtl/attacktable.vhd:114:12 */
  assign n5018 = ff_d1[6:5]; // extract
  /*# sim_rtl/attacktable.vhd:153:1 */
  always @*
    case (n5010)
      2'b10: n5020 = 2'b00;
      2'b01: n5020 = n5018;
      default: n5020 = 2'b00;
    endcase
  /*# sim_rtl/attacktable.vhd:153:1 */
  always @*
    case (n5010)
      2'b10: n5022 = 7'b0000000;
      2'b01: n5022 = ff_d2;
      default: n5022 = 7'b0000000;
    endcase
  /*# sim_rtl/attacktable.vhd:152:1 */
  assign n5023 = {n5022, n5020, n5017, n5013};
  /*# sim_rtl/attacktable.vhd:152:1 */
  assign n5025 = ss_read ? n5023 : 22'b0000000000000000000000;
  /*# sim_rtl/attacktable.vhd:163:6 */
  assign n5026 = {24'b0, ss_addr};  // uext
  /*# sim_rtl/attacktable.vhd:165:34 */
  assign n5027 = ss_wdata[7:0]; // extract
  /*# sim_rtl/attacktable.vhd:167:35 */
  assign n5028 = ss_wdata[14:8]; // extract
  /*# sim_rtl/attacktable.vhd:169:35 */
  assign n5029 = ss_wdata[21:15]; // extract
  /*# sim_rtl/attacktable.vhd:164:1 */
  assign n5031 = n5026 == 32'b00000000000000000000000001011011;
  /*# sim_rtl/attacktable.vhd:172:35 */
  assign n5032 = ss_wdata[12:0]; // extract
  /*# sim_rtl/attacktable.vhd:171:1 */
  assign n5034 = n5026 == 32'b00000000000000000000000001011100;
  /*# sim_rtl/attacktable.vhd:163:1 */
  assign n5035 = {n5034, n5031};
  /*# sim_rtl/attacktable.vhd:163:1 */
  always @*
    case (n5035)
      2'b10: n5036 = n5032;
      2'b01: n5036 = n5113;
      default: n5036 = n5113;
    endcase
  /*# sim_rtl/attacktable.vhd:163:1 */
  always @*
    case (n5035)
      2'b10: n5037 = ff_w;
      2'b01: n5037 = n5027;
      default: n5037 = ff_w;
    endcase
  /*# sim_rtl/attacktable.vhd:163:1 */
  always @*
    case (n5035)
      2'b10: n5038 = ff_d1;
      2'b01: n5038 = n5028;
      default: n5038 = ff_d1;
    endcase
  /*# sim_rtl/attacktable.vhd:163:1 */
  always @*
    case (n5035)
      2'b10: n5039 = ff_d2;
      2'b01: n5039 = n5029;
      default: n5039 = ff_d2;
    endcase
  /*# sim_rtl/attacktable.vhd:146:1 */
  assign n5044 = n5052 ? n5036 : n5113;
  /*# sim_rtl/attacktable.vhd:146:1 */
  assign n5045 = n5053 ? n5037 : ff_w;
  /*# sim_rtl/attacktable.vhd:146:1 */
  assign n5046 = n5054 ? n5038 : ff_d1;
  /*# sim_rtl/attacktable.vhd:146:1 */
  assign n5047 = n5055 ? n5039 : ff_d2;
  /*# sim_rtl/attacktable.vhd:146:1 */
  assign n5052 = ss_write & n5004;
  /*# sim_rtl/attacktable.vhd:146:1 */
  assign n5053 = ss_write & n5004;
  /*# sim_rtl/attacktable.vhd:146:1 */
  assign n5054 = ss_write & n5004;
  /*# sim_rtl/attacktable.vhd:146:1 */
  assign n5055 = ss_write & n5004;
  /*# sim_rtl/attacktable.vhd:146:1 */
  assign n5061 = n5004 ? n5025 : 22'b0000000000000000000000;
  /*# sim_rtl/attacktable.vhd:141:10 */
  assign n5063 = n5062[31:22]; // extract
  /*# sim_rtl/attacktable.vhd:141:10 */
  assign n5064 = {n5063, n5061};
  /*# sim_rtl/attacktable.vhd:179:11 */
  assign n5065 = ~ss_hold;
  /*# sim_rtl/attacktable.vhd:179:1 */
  assign n5077 = n5085 ? n5121 : n5046;
  /*# sim_rtl/attacktable.vhd:179:1 */
  assign n5078 = n5086 ? n5120 : n5047;
  /*# sim_rtl/attacktable.vhd:188:29 */
  assign n5079 = addr[14:7]; // extract
  /*# sim_rtl/attacktable.vhd:179:1 */
  assign n5080 = n5084 ? n5079 : n5045;
  /*# sim_rtl/attacktable.vhd:193:31 */
  assign n5081 = w_inter[12:0]; // extract
  /*# sim_rtl/attacktable.vhd:179:1 */
  assign n5082 = n5083 ? n5081 : n5044;
  /*# sim_rtl/attacktable.vhd:179:1 */
  assign n5083 = clkena & n5065;
  /*# sim_rtl/attacktable.vhd:179:1 */
  assign n5084 = clkena & n5065;
  /*# sim_rtl/attacktable.vhd:179:1 */
  assign n5085 = clkena & n5065;
  /*# sim_rtl/attacktable.vhd:179:1 */
  assign n5086 = clkena & n5065;
  /*# sim_rtl/attacktable.vhd:206:21 */
  assign n5100 = {1'b0, ff_d2};
  /*# sim_rtl/attacktable.vhd:206:37 */
  assign n5102 = {1'b0, ff_d1};
  /*# sim_rtl/attacktable.vhd:206:30 */
  assign n5103 = n5100 - n5102;
  /*# sim_rtl/attacktable.vhd:208:5 */
  attack_table_mul_Brtl u_attack_table_mul (
    .i0(ff_w),
    .i1(w_sub),
    .o(u_attack_table_mul_n5104));
  /*# sim_rtl/attacktable.vhd:215:21 */
  assign n5108 = {1'b0, ff_d1};
  /*# sim_rtl/attacktable.vhd:215:29 */
  assign n5110 = {n5108, 6'b000000};
  /*# sim_rtl/attacktable.vhd:215:41 */
  assign n5111 = n5110 + w_mul;
  /*# sim_rtl/attacktable.vhd:143:1 */
  always @(posedge clk)
    n5113 <= n5082;
  /*# sim_rtl/attacktable.vhd:143:1 */
  always @(posedge clk)
    n5114 <= n5080;
  /*# sim_rtl/attacktable.vhd:143:1 */
  always @(posedge clk)
    n5115 <= n5077;
  /*# sim_rtl/attacktable.vhd:143:1 */
  always @(posedge clk)
    n5116 <= n5078;
  /*# sim_rtl/attacktable.vhd:143:1 */
  always @(posedge clk)
    n5117 <= n5064;
  initial
    n5117 = 32'b00000000000000000000000000000000;
  /*# sim_rtl/attacktable.vhd:182:37 */
  reg [6:0] n5118[127:0] ; // memory
  initial begin
    n5118[127] = 7'b1111111;
    n5118[126] = 7'b1110101;
    n5118[125] = 7'b1101100;
    n5118[124] = 7'b1100010;
    n5118[123] = 7'b1011010;
    n5118[122] = 7'b1010100;
    n5118[121] = 7'b1010000;
    n5118[120] = 7'b1001011;
    n5118[119] = 7'b1001000;
    n5118[118] = 7'b1000101;
    n5118[117] = 7'b1000010;
    n5118[116] = 7'b1000000;
    n5118[115] = 7'b0111101;
    n5118[114] = 7'b0111011;
    n5118[113] = 7'b0111001;
    n5118[112] = 7'b0111000;
    n5118[111] = 7'b0110110;
    n5118[110] = 7'b0110100;
    n5118[109] = 7'b0110011;
    n5118[108] = 7'b0110001;
    n5118[107] = 7'b0110000;
    n5118[106] = 7'b0101111;
    n5118[105] = 7'b0101101;
    n5118[104] = 7'b0101100;
    n5118[103] = 7'b0101011;
    n5118[102] = 7'b0101010;
    n5118[101] = 7'b0101001;
    n5118[100] = 7'b0101000;
    n5118[99] = 7'b0100111;
    n5118[98] = 7'b0100110;
    n5118[97] = 7'b0100101;
    n5118[96] = 7'b0100100;
    n5118[95] = 7'b0100100;
    n5118[94] = 7'b0100011;
    n5118[93] = 7'b0100010;
    n5118[92] = 7'b0100001;
    n5118[91] = 7'b0100001;
    n5118[90] = 7'b0100000;
    n5118[89] = 7'b0011111;
    n5118[88] = 7'b0011110;
    n5118[87] = 7'b0011110;
    n5118[86] = 7'b0011101;
    n5118[85] = 7'b0011101;
    n5118[84] = 7'b0011100;
    n5118[83] = 7'b0011011;
    n5118[82] = 7'b0011011;
    n5118[81] = 7'b0011010;
    n5118[80] = 7'b0011010;
    n5118[79] = 7'b0011001;
    n5118[78] = 7'b0011000;
    n5118[77] = 7'b0011000;
    n5118[76] = 7'b0010111;
    n5118[75] = 7'b0010111;
    n5118[74] = 7'b0010110;
    n5118[73] = 7'b0010110;
    n5118[72] = 7'b0010101;
    n5118[71] = 7'b0010101;
    n5118[70] = 7'b0010101;
    n5118[69] = 7'b0010100;
    n5118[68] = 7'b0010100;
    n5118[67] = 7'b0010011;
    n5118[66] = 7'b0010011;
    n5118[65] = 7'b0010010;
    n5118[64] = 7'b0010010;
    n5118[63] = 7'b0010001;
    n5118[62] = 7'b0010001;
    n5118[61] = 7'b0010001;
    n5118[60] = 7'b0010000;
    n5118[59] = 7'b0010000;
    n5118[58] = 7'b0001111;
    n5118[57] = 7'b0001111;
    n5118[56] = 7'b0001111;
    n5118[55] = 7'b0001110;
    n5118[54] = 7'b0001110;
    n5118[53] = 7'b0001110;
    n5118[52] = 7'b0001101;
    n5118[51] = 7'b0001101;
    n5118[50] = 7'b0001101;
    n5118[49] = 7'b0001100;
    n5118[48] = 7'b0001100;
    n5118[47] = 7'b0001100;
    n5118[46] = 7'b0001011;
    n5118[45] = 7'b0001011;
    n5118[44] = 7'b0001011;
    n5118[43] = 7'b0001010;
    n5118[42] = 7'b0001010;
    n5118[41] = 7'b0001010;
    n5118[40] = 7'b0001001;
    n5118[39] = 7'b0001001;
    n5118[38] = 7'b0001001;
    n5118[37] = 7'b0001001;
    n5118[36] = 7'b0001000;
    n5118[35] = 7'b0001000;
    n5118[34] = 7'b0001000;
    n5118[33] = 7'b0000111;
    n5118[32] = 7'b0000111;
    n5118[31] = 7'b0000111;
    n5118[30] = 7'b0000111;
    n5118[29] = 7'b0000110;
    n5118[28] = 7'b0000110;
    n5118[27] = 7'b0000110;
    n5118[26] = 7'b0000110;
    n5118[25] = 7'b0000101;
    n5118[24] = 7'b0000101;
    n5118[23] = 7'b0000101;
    n5118[22] = 7'b0000100;
    n5118[21] = 7'b0000100;
    n5118[20] = 7'b0000100;
    n5118[19] = 7'b0000100;
    n5118[18] = 7'b0000100;
    n5118[17] = 7'b0000011;
    n5118[16] = 7'b0000011;
    n5118[15] = 7'b0000011;
    n5118[14] = 7'b0000011;
    n5118[13] = 7'b0000010;
    n5118[12] = 7'b0000010;
    n5118[11] = 7'b0000010;
    n5118[10] = 7'b0000010;
    n5118[9] = 7'b0000001;
    n5118[8] = 7'b0000001;
    n5118[7] = 7'b0000001;
    n5118[6] = 7'b0000001;
    n5118[5] = 7'b0000001;
    n5118[4] = 7'b0000000;
    n5118[3] = 7'b0000000;
    n5118[2] = 7'b0000000;
    n5118[1] = 7'b0000000;
    n5118[0] = 7'b0000000;
    end
  assign n5120 = n5118[w_addr2];
  assign n5121 = n5118[w_addr1];
  /*# sim_rtl/attacktable.vhd:183:37 */
  /*# sim_rtl/attacktable.vhd:182:37 */
endmodule

module voicememory_Brtl
  (input  clk,
   input  reset,
   input  \idata[am] ,
   input  \idata[pm] ,
   input  \idata[eg] ,
   input  \idata[kr] ,
   input  [3:0] \idata[ml] ,
   input  [1:0] \idata[kl] ,
   input  [5:0] \idata[tl] ,
   input  \idata[wf] ,
   input  [2:0] \idata[fb] ,
   input  [3:0] \idata[ar] ,
   input  [3:0] \idata[dr] ,
   input  [3:0] \idata[sl] ,
   input  [3:0] \idata[rr] ,
   input  wr,
   input  [5:0] rwaddr,
   input  [5:0] roaddr,
   output \odata[am] ,
   output \odata[pm] ,
   output \odata[eg] ,
   output \odata[kr] ,
   output [3:0] \odata[ml] ,
   output [1:0] \odata[kl] ,
   output [5:0] \odata[tl] ,
   output \odata[wf] ,
   output [2:0] \odata[fb] ,
   output [3:0] \odata[ar] ,
   output [3:0] \odata[dr] ,
   output [3:0] \odata[sl] ,
   output [3:0] \odata[rr] ,
   output \rodata[am] ,
   output \rodata[pm] ,
   output \rodata[eg] ,
   output \rodata[kr] ,
   output [3:0] \rodata[ml] ,
   output [1:0] \rodata[kl] ,
   output [5:0] \rodata[tl] ,
   output \rodata[wf] ,
   output [2:0] \rodata[fb] ,
   output [3:0] \rodata[ar] ,
   output [3:0] \rodata[dr] ,
   output [3:0] \rodata[sl] ,
   output [3:0] \rodata[rr] ,
   input  ss_hold,
   input  [7:0] ss_addr,
   input  ss_read,
   input  ss_write,
   input  [31:0] ss_wdata,
   output [31:0] ss_rdata,
   output ss_initialized);
  wire [35:0] n4146;
  wire n4148;
  wire n4149;
  wire n4150;
  wire n4151;
  wire [3:0] n4152;
  wire [1:0] n4153;
  wire [5:0] n4154;
  wire n4155;
  wire [2:0] n4156;
  wire [3:0] n4157;
  wire [3:0] n4158;
  wire [3:0] n4159;
  wire [3:0] n4160;
  wire n4162;
  wire n4163;
  wire n4164;
  wire n4165;
  wire [3:0] n4166;
  wire [1:0] n4167;
  wire [5:0] n4168;
  wire n4169;
  wire [2:0] n4170;
  wire [3:0] n4171;
  wire [3:0] n4172;
  wire [3:0] n4173;
  wire [3:0] n4174;
  wire [1367:0] voices;
  wire [5:0] rom_addr;
  wire [35:0] rom_data;
  wire [1:0] rstate;
  reg [31:0] ss_local_data;
  wire ss_mem_active;
  wire [5:0] ss_mem_index;
  reg ss_mem_ready;
  wire [31:0] ss_voice_low;
  wire [35:0] ss_mem_vector;
  wire [35:0] rom2413_n4179;
  wire \rom2413.data[am] ;
  wire \rom2413.data[pm] ;
  wire \rom2413.data[eg] ;
  wire \rom2413.data[kr] ;
  wire [3:0] \rom2413.data[ml] ;
  wire [1:0] \rom2413.data[kl] ;
  wire [5:0] \rom2413.data[tl] ;
  wire \rom2413.data[wf] ;
  wire [2:0] \rom2413.data[fb] ;
  wire [3:0] \rom2413.data[ar] ;
  wire [3:0] \rom2413.data[dr] ;
  wire [3:0] \rom2413.data[sl] ;
  wire [3:0] \rom2413.data[rr] ;
  wire [35:0] n4180;
  reg [5:0] n4183_init_id;
  wire [31:0] n4187;
  wire n4189;
  wire n4192;
  wire n4194;
  wire [31:0] n4195;
  wire n4197;
  wire n4199;
  wire n4201;
  wire [5:0] n4203;
  wire n4210;
  wire n4211;
  wire [1:0] n4212;
  wire n4213;
  wire [2:0] n4214;
  wire n4215;
  wire [3:0] n4216;
  wire [3:0] n4217;
  wire [7:0] n4218;
  wire [1:0] n4219;
  wire [9:0] n4220;
  wire [5:0] n4221;
  wire [15:0] n4222;
  wire n4223;
  wire [16:0] n4224;
  wire [2:0] n4225;
  wire [19:0] n4226;
  wire [3:0] n4227;
  wire [23:0] n4228;
  wire [3:0] n4229;
  wire [27:0] n4230;
  wire [3:0] n4231;
  wire [31:0] n4232;
  wire [3:0] n4233;
  wire [35:0] n4234;
  wire [31:0] n4236;
  wire [31:0] n4238;
  wire [5:0] n4239;
  wire n4241;
  wire [2:0] n4242;
  reg [1367:0] n4243;
  reg [5:0] n4244;
  reg [1:0] n4248;
  reg [5:0] n4249;
  wire [5:0] n4251;
  wire n4258;
  wire n4259;
  wire [1:0] n4260;
  wire n4261;
  wire [2:0] n4262;
  wire n4263;
  wire [3:0] n4264;
  wire [3:0] n4265;
  wire [7:0] n4266;
  wire [1:0] n4267;
  wire [9:0] n4268;
  wire [5:0] n4269;
  wire [15:0] n4270;
  wire n4271;
  wire [16:0] n4272;
  wire [2:0] n4273;
  wire [19:0] n4274;
  wire [3:0] n4275;
  wire [23:0] n4276;
  wire [3:0] n4277;
  wire [27:0] n4278;
  wire [3:0] n4279;
  wire [31:0] n4280;
  wire [3:0] n4281;
  wire [35:0] n4282;
  wire [1367:0] n4284;
  wire [1367:0] n4285;
  wire n4289;
  wire n4290;
  wire [5:0] n4292;
  wire [3:0] n4294;
  wire [35:0] n4295;
  wire [1367:0] n4297;
  wire [31:0] n4298;
  wire [1367:0] n4299;
  wire n4300;
  wire [1367:0] n4301;
  wire n4302;
  wire n4303;
  wire [31:0] n4304;
  wire n4305;
  wire [5:0] n4308;
  wire n4315;
  wire n4316;
  wire n4317;
  wire n4318;
  wire [3:0] n4319;
  wire [1:0] n4320;
  wire [5:0] n4321;
  wire n4322;
  wire [2:0] n4323;
  wire [3:0] n4324;
  wire [3:0] n4325;
  wire [3:0] n4326;
  wire [3:0] n4327;
  wire [35:0] n4328;
  wire [5:0] n4331;
  wire n4338;
  wire n4339;
  wire n4340;
  wire n4341;
  wire [3:0] n4342;
  wire [1:0] n4343;
  wire [5:0] n4344;
  wire n4345;
  wire [2:0] n4346;
  wire [3:0] n4347;
  wire [3:0] n4348;
  wire [3:0] n4349;
  wire [3:0] n4350;
  wire [35:0] n4351;
  wire [35:0] n4352;
  wire [5:0] n4355;
  wire n4362;
  wire n4363;
  wire n4364;
  wire n4365;
  wire [3:0] n4366;
  wire [1:0] n4367;
  wire [5:0] n4368;
  wire n4369;
  wire [2:0] n4370;
  wire [3:0] n4371;
  wire [3:0] n4372;
  wire [3:0] n4373;
  wire [3:0] n4374;
  wire [35:0] n4375;
  wire [31:0] n4397;
  wire n4399;
  wire n4400;
  wire [31:0] n4401;
  wire n4403;
  wire n4404;
  wire n4405;
  wire [31:0] n4407;
  wire [31:0] n4409;
  wire [31:0] n4411;
  wire [5:0] n4412;
  wire [31:0] n4413;
  wire n4415;
  wire [31:0] n4416;
  wire n4418;
  wire n4419;
  wire [5:0] n4420;
  wire n4427;
  wire n4428;
  wire [1:0] n4429;
  wire n4430;
  wire [2:0] n4431;
  wire n4432;
  wire [3:0] n4433;
  wire [3:0] n4434;
  wire [7:0] n4435;
  wire [1:0] n4436;
  wire [9:0] n4437;
  wire [5:0] n4438;
  wire [15:0] n4439;
  wire n4440;
  wire [16:0] n4441;
  wire [2:0] n4442;
  wire [19:0] n4443;
  wire [3:0] n4444;
  wire [23:0] n4445;
  wire [3:0] n4446;
  wire [27:0] n4447;
  wire [3:0] n4448;
  wire [31:0] n4449;
  wire [3:0] n4450;
  wire [35:0] n4451;
  wire [31:0] n4452;
  wire n4453;
  wire n4454;
  wire [31:0] n4455;
  wire [3:0] n4456;
  wire [31:0] n4458;
  wire [31:0] n4459;
  wire n4461;
  wire [35:0] n4462;
  reg [35:0] n4463;
  wire n4464;
  wire [35:0] n4465;
  reg [35:0] n4466;
  wire n4467;
  wire [1367:0] n4468;
  reg [1367:0] n4469;
  wire n4470;
  wire n4471;
  wire [5:0] n4472;
  reg [5:0] n4473;
  wire [1:0] n4474;
  reg [1:0] n4475;
  reg n4476;
  wire n4477;
  wire [31:0] n4478;
  reg [31:0] n4479;
  wire [5:0] n4480;
  reg [5:0] n4481;
  wire n4482;
  wire n4483;
  wire n4484;
  wire n4485;
  wire n4486;
  wire n4487;
  wire n4488;
  wire n4489;
  wire n4490;
  wire n4491;
  wire n4492;
  wire n4493;
  wire n4494;
  wire n4495;
  wire n4496;
  wire n4497;
  wire n4498;
  wire n4499;
  wire n4500;
  wire n4501;
  wire n4502;
  wire n4503;
  wire n4504;
  wire n4505;
  wire n4506;
  wire n4507;
  wire n4508;
  wire n4509;
  wire n4510;
  wire n4511;
  wire n4512;
  wire n4513;
  wire n4514;
  wire n4515;
  wire n4516;
  wire n4517;
  wire n4518;
  wire n4519;
  wire n4520;
  wire n4521;
  wire n4522;
  wire n4523;
  wire n4524;
  wire n4525;
  wire n4526;
  wire n4527;
  wire n4528;
  wire n4529;
  wire n4530;
  wire n4531;
  wire n4532;
  wire n4533;
  wire n4534;
  wire n4535;
  wire n4536;
  wire n4537;
  wire n4538;
  wire n4539;
  wire n4540;
  wire n4541;
  wire n4542;
  wire n4543;
  wire n4544;
  wire n4545;
  wire n4546;
  wire n4547;
  wire n4548;
  wire n4549;
  wire n4550;
  wire n4551;
  wire n4552;
  wire n4553;
  wire n4554;
  wire n4555;
  wire n4556;
  wire n4557;
  wire n4558;
  wire n4559;
  wire n4560;
  wire n4561;
  wire n4562;
  wire n4563;
  wire n4564;
  wire n4565;
  wire n4566;
  wire n4567;
  wire n4568;
  wire [35:0] n4569;
  wire [35:0] n4570;
  wire [35:0] n4571;
  wire [35:0] n4572;
  wire [35:0] n4573;
  wire [35:0] n4574;
  wire [35:0] n4575;
  wire [35:0] n4576;
  wire [35:0] n4577;
  wire [35:0] n4578;
  wire [35:0] n4579;
  wire [35:0] n4580;
  wire [35:0] n4581;
  wire [35:0] n4582;
  wire [35:0] n4583;
  wire [35:0] n4584;
  wire [35:0] n4585;
  wire [35:0] n4586;
  wire [35:0] n4587;
  wire [35:0] n4588;
  wire [35:0] n4589;
  wire [35:0] n4590;
  wire [35:0] n4591;
  wire [35:0] n4592;
  wire [35:0] n4593;
  wire [35:0] n4594;
  wire [35:0] n4595;
  wire [35:0] n4596;
  wire [35:0] n4597;
  wire [35:0] n4598;
  wire [35:0] n4599;
  wire [35:0] n4600;
  wire [35:0] n4601;
  wire [35:0] n4602;
  wire [35:0] n4603;
  wire [35:0] n4604;
  wire [35:0] n4605;
  wire [35:0] n4606;
  wire [35:0] n4607;
  wire [35:0] n4608;
  wire [35:0] n4609;
  wire [35:0] n4610;
  wire [35:0] n4611;
  wire [35:0] n4612;
  wire [35:0] n4613;
  wire [35:0] n4614;
  wire [35:0] n4615;
  wire [35:0] n4616;
  wire [35:0] n4617;
  wire [35:0] n4618;
  wire [35:0] n4619;
  wire [35:0] n4620;
  wire [35:0] n4621;
  wire [35:0] n4622;
  wire [35:0] n4623;
  wire [35:0] n4624;
  wire [35:0] n4625;
  wire [35:0] n4626;
  wire [35:0] n4627;
  wire [35:0] n4628;
  wire [35:0] n4629;
  wire [35:0] n4630;
  wire [35:0] n4631;
  wire [35:0] n4632;
  wire [35:0] n4633;
  wire [35:0] n4634;
  wire [35:0] n4635;
  wire [35:0] n4636;
  wire [35:0] n4637;
  wire [35:0] n4638;
  wire [35:0] n4639;
  wire [35:0] n4640;
  wire [35:0] n4641;
  wire [35:0] n4642;
  wire [35:0] n4643;
  wire [35:0] n4644;
  wire [1367:0] n4645;
  wire n4646;
  wire n4647;
  wire n4648;
  wire n4649;
  wire n4650;
  wire n4651;
  wire n4652;
  wire n4653;
  wire n4654;
  wire n4655;
  wire n4656;
  wire n4657;
  wire n4658;
  wire n4659;
  wire n4660;
  wire n4661;
  wire n4662;
  wire n4663;
  wire n4664;
  wire n4665;
  wire n4666;
  wire n4667;
  wire n4668;
  wire n4669;
  wire n4670;
  wire n4671;
  wire n4672;
  wire n4673;
  wire n4674;
  wire n4675;
  wire n4676;
  wire n4677;
  wire n4678;
  wire n4679;
  wire n4680;
  wire n4681;
  wire n4682;
  wire n4683;
  wire n4684;
  wire n4685;
  wire n4686;
  wire n4687;
  wire n4688;
  wire n4689;
  wire n4690;
  wire n4691;
  wire n4692;
  wire n4693;
  wire n4694;
  wire n4695;
  wire n4696;
  wire n4697;
  wire n4698;
  wire n4699;
  wire n4700;
  wire n4701;
  wire n4702;
  wire n4703;
  wire n4704;
  wire n4705;
  wire n4706;
  wire n4707;
  wire n4708;
  wire n4709;
  wire n4710;
  wire n4711;
  wire n4712;
  wire n4713;
  wire n4714;
  wire n4715;
  wire n4716;
  wire n4717;
  wire n4718;
  wire n4719;
  wire n4720;
  wire n4721;
  wire n4722;
  wire n4723;
  wire n4724;
  wire n4725;
  wire n4726;
  wire n4727;
  wire n4728;
  wire n4729;
  wire n4730;
  wire n4731;
  wire n4732;
  wire [35:0] n4733;
  wire [35:0] n4734;
  wire [35:0] n4735;
  wire [35:0] n4736;
  wire [35:0] n4737;
  wire [35:0] n4738;
  wire [35:0] n4739;
  wire [35:0] n4740;
  wire [35:0] n4741;
  wire [35:0] n4742;
  wire [35:0] n4743;
  wire [35:0] n4744;
  wire [35:0] n4745;
  wire [35:0] n4746;
  wire [35:0] n4747;
  wire [35:0] n4748;
  wire [35:0] n4749;
  wire [35:0] n4750;
  wire [35:0] n4751;
  wire [35:0] n4752;
  wire [35:0] n4753;
  wire [35:0] n4754;
  wire [35:0] n4755;
  wire [35:0] n4756;
  wire [35:0] n4757;
  wire [35:0] n4758;
  wire [35:0] n4759;
  wire [35:0] n4760;
  wire [35:0] n4761;
  wire [35:0] n4762;
  wire [35:0] n4763;
  wire [35:0] n4764;
  wire [35:0] n4765;
  wire [35:0] n4766;
  wire [35:0] n4767;
  wire [35:0] n4768;
  wire [35:0] n4769;
  wire [35:0] n4770;
  wire [35:0] n4771;
  wire [35:0] n4772;
  wire [35:0] n4773;
  wire [35:0] n4774;
  wire [35:0] n4775;
  wire [35:0] n4776;
  wire [35:0] n4777;
  wire [35:0] n4778;
  wire [35:0] n4779;
  wire [35:0] n4780;
  wire [35:0] n4781;
  wire [35:0] n4782;
  wire [35:0] n4783;
  wire [35:0] n4784;
  wire [35:0] n4785;
  wire [35:0] n4786;
  wire [35:0] n4787;
  wire [35:0] n4788;
  wire [35:0] n4789;
  wire [35:0] n4790;
  wire [35:0] n4791;
  wire [35:0] n4792;
  wire [35:0] n4793;
  wire [35:0] n4794;
  wire [35:0] n4795;
  wire [35:0] n4796;
  wire [35:0] n4797;
  wire [35:0] n4798;
  wire [35:0] n4799;
  wire [35:0] n4800;
  wire [35:0] n4801;
  wire [35:0] n4802;
  wire [35:0] n4803;
  wire [35:0] n4804;
  wire [35:0] n4805;
  wire [35:0] n4806;
  wire [35:0] n4807;
  wire [35:0] n4808;
  wire [1367:0] n4809;
  wire n4810;
  wire n4811;
  wire n4812;
  wire n4813;
  wire n4814;
  wire n4815;
  wire n4816;
  wire n4817;
  wire n4818;
  wire n4819;
  wire n4820;
  wire n4821;
  wire n4822;
  wire n4823;
  wire n4824;
  wire n4825;
  wire n4826;
  wire n4827;
  wire n4828;
  wire n4829;
  wire n4830;
  wire n4831;
  wire n4832;
  wire n4833;
  wire n4834;
  wire n4835;
  wire n4836;
  wire n4837;
  wire n4838;
  wire n4839;
  wire n4840;
  wire n4841;
  wire n4842;
  wire n4843;
  wire n4844;
  wire n4845;
  wire n4846;
  wire n4847;
  wire n4848;
  wire n4849;
  wire n4850;
  wire n4851;
  wire n4852;
  wire n4853;
  wire n4854;
  wire n4855;
  wire n4856;
  wire n4857;
  wire n4858;
  wire n4859;
  wire n4860;
  wire n4861;
  wire n4862;
  wire n4863;
  wire n4864;
  wire n4865;
  wire n4866;
  wire n4867;
  wire n4868;
  wire n4869;
  wire n4870;
  wire n4871;
  wire n4872;
  wire n4873;
  wire n4874;
  wire n4875;
  wire n4876;
  wire n4877;
  wire n4878;
  wire n4879;
  wire n4880;
  wire n4881;
  wire n4882;
  wire n4883;
  wire n4884;
  wire n4885;
  wire n4886;
  wire n4887;
  wire n4888;
  wire n4889;
  wire n4890;
  wire n4891;
  wire n4892;
  wire n4893;
  wire n4894;
  wire n4895;
  wire n4896;
  wire [35:0] n4897;
  wire [35:0] n4898;
  wire [35:0] n4899;
  wire [35:0] n4900;
  wire [35:0] n4901;
  wire [35:0] n4902;
  wire [35:0] n4903;
  wire [35:0] n4904;
  wire [35:0] n4905;
  wire [35:0] n4906;
  wire [35:0] n4907;
  wire [35:0] n4908;
  wire [35:0] n4909;
  wire [35:0] n4910;
  wire [35:0] n4911;
  wire [35:0] n4912;
  wire [35:0] n4913;
  wire [35:0] n4914;
  wire [35:0] n4915;
  wire [35:0] n4916;
  wire [35:0] n4917;
  wire [35:0] n4918;
  wire [35:0] n4919;
  wire [35:0] n4920;
  wire [35:0] n4921;
  wire [35:0] n4922;
  wire [35:0] n4923;
  wire [35:0] n4924;
  wire [35:0] n4925;
  wire [35:0] n4926;
  wire [35:0] n4927;
  wire [35:0] n4928;
  wire [35:0] n4929;
  wire [35:0] n4930;
  wire [35:0] n4931;
  wire [35:0] n4932;
  wire [35:0] n4933;
  wire [35:0] n4934;
  wire [35:0] n4935;
  wire [35:0] n4936;
  wire [35:0] n4937;
  wire [35:0] n4938;
  wire [35:0] n4939;
  wire [35:0] n4940;
  wire [35:0] n4941;
  wire [35:0] n4942;
  wire [35:0] n4943;
  wire [35:0] n4944;
  wire [35:0] n4945;
  wire [35:0] n4946;
  wire [35:0] n4947;
  wire [35:0] n4948;
  wire [35:0] n4949;
  wire [35:0] n4950;
  wire [35:0] n4951;
  wire [35:0] n4952;
  wire [35:0] n4953;
  wire [35:0] n4954;
  wire [35:0] n4955;
  wire [35:0] n4956;
  wire [35:0] n4957;
  wire [35:0] n4958;
  wire [35:0] n4959;
  wire [35:0] n4960;
  wire [35:0] n4961;
  wire [35:0] n4962;
  wire [35:0] n4963;
  wire [35:0] n4964;
  wire [35:0] n4965;
  wire [35:0] n4966;
  wire [35:0] n4967;
  wire [35:0] n4968;
  wire [35:0] n4969;
  wire [35:0] n4970;
  wire [35:0] n4971;
  wire [35:0] n4972;
  wire [1367:0] n4973;
  wire [2303:0] n4975;
  wire [35:0] n4976;
  wire [2303:0] n4978;
  wire [35:0] n4979;
  wire [2303:0] n4981;
  wire [35:0] n4982;
  assign \odata[am]  = n4148; //(module output)
  assign \odata[pm]  = n4149; //(module output)
  assign \odata[eg]  = n4150; //(module output)
  assign \odata[kr]  = n4151; //(module output)
  assign \odata[ml]  = n4152; //(module output)
  assign \odata[kl]  = n4153; //(module output)
  assign \odata[tl]  = n4154; //(module output)
  assign \odata[wf]  = n4155; //(module output)
  assign \odata[fb]  = n4156; //(module output)
  assign \odata[ar]  = n4157; //(module output)
  assign \odata[dr]  = n4158; //(module output)
  assign \odata[sl]  = n4159; //(module output)
  assign \odata[rr]  = n4160; //(module output)
  assign \rodata[am]  = n4162; //(module output)
  assign \rodata[pm]  = n4163; //(module output)
  assign \rodata[eg]  = n4164; //(module output)
  assign \rodata[kr]  = n4165; //(module output)
  assign \rodata[ml]  = n4166; //(module output)
  assign \rodata[kl]  = n4167; //(module output)
  assign \rodata[tl]  = n4168; //(module output)
  assign \rodata[wf]  = n4169; //(module output)
  assign \rodata[fb]  = n4170; //(module output)
  assign \rodata[ar]  = n4171; //(module output)
  assign \rodata[dr]  = n4172; //(module output)
  assign \rodata[sl]  = n4173; //(module output)
  assign \rodata[rr]  = n4174; //(module output)
  assign ss_rdata = ss_local_data; //(module output)
  assign ss_initialized = ss_mem_ready; //(module output)
  /*# sim_rtl/voicememory.vhd:37:8 */
  assign n4146 = {\idata[rr] , \idata[sl] , \idata[dr] , \idata[ar] , \idata[fb] , \idata[wf] , \idata[tl] , \idata[kl] , \idata[ml] , \idata[kr] , \idata[eg] , \idata[pm] , \idata[am] };
  /*# sim_rtl/voicememory.vhd:37:8 */
  assign n4148 = n4463[0]; // extract
  /*# sim_rtl/voicememory.vhd:37:8 */
  assign n4149 = n4463[1]; // extract
  /*# sim_rtl/voicememory.vhd:37:8 */
  assign n4150 = n4463[2]; // extract
  /*# sim_rtl/voicememory.vhd:37:8 */
  assign n4151 = n4463[3]; // extract
  /*# sim_rtl/voicememory.vhd:37:8 */
  assign n4152 = n4463[7:4]; // extract
  /*# sim_rtl/voicememory.vhd:37:8 */
  assign n4153 = n4463[9:8]; // extract
  /*# sim_rtl/voicememory.vhd:37:8 */
  assign n4154 = n4463[15:10]; // extract
  /*# sim_rtl/voicememory.vhd:37:8 */
  assign n4155 = n4463[16]; // extract
  /*# sim_rtl/voicememory.vhd:37:8 */
  assign n4156 = n4463[19:17]; // extract
  /*# sim_rtl/voicememory.vhd:37:8 */
  assign n4157 = n4463[23:20]; // extract
  /*# sim_rtl/voicememory.vhd:37:8 */
  assign n4158 = n4463[27:24]; // extract
  /*# sim_rtl/voicememory.vhd:37:8 */
  assign n4159 = n4463[31:28]; // extract
  /*# sim_rtl/voicememory.vhd:37:8 */
  assign n4160 = n4463[35:32]; // extract
  /*# sim_rtl/voicememory.vhd:37:8 */
  assign n4162 = n4466[0]; // extract
  /*# sim_rtl/voicememory.vhd:37:8 */
  assign n4163 = n4466[1]; // extract
  /*# sim_rtl/voicememory.vhd:37:8 */
  assign n4164 = n4466[2]; // extract
  /*# sim_rtl/voicememory.vhd:37:8 */
  assign n4165 = n4466[3]; // extract
  /*# sim_rtl/voicememory.vhd:37:8 */
  assign n4166 = n4466[7:4]; // extract
  /*# sim_rtl/voicememory.vhd:37:8 */
  assign n4167 = n4466[9:8]; // extract
  /*# sim_rtl/voicememory.vhd:37:8 */
  assign n4168 = n4466[15:10]; // extract
  /*# sim_rtl/voicememory.vhd:37:8 */
  assign n4169 = n4466[16]; // extract
  /*# sim_rtl/voicememory.vhd:37:8 */
  assign n4170 = n4466[19:17]; // extract
  /*# sim_rtl/voicememory.vhd:37:8 */
  assign n4171 = n4466[23:20]; // extract
  /*# sim_rtl/voicememory.vhd:37:8 */
  assign n4172 = n4466[27:24]; // extract
  /*# sim_rtl/voicememory.vhd:37:8 */
  assign n4173 = n4466[31:28]; // extract
  /*# sim_rtl/voicememory.vhd:37:8 */
  assign n4174 = n4466[35:32]; // extract
  /*# sim_rtl/voicememory.vhd:65:10 */
  assign voices = n4469; // (signal)
  /*# sim_rtl/voicememory.vhd:74:10 */
  assign rom_addr = n4473; // (signal)
  /*# sim_rtl/voicememory.vhd:75:10 */
  assign rom_data = rom2413_n4179; // (signal)
  /*# sim_rtl/voicememory.vhd:76:10 */
  assign rstate = n4475; // (signal)
  /*# sim_rtl/voicememory.vhd:78:12 */
  always @*
    ss_local_data = n4455; // (isignal)
  initial
    ss_local_data = 32'b00000000000000000000000000000000;
  /*# sim_rtl/voicememory.vhd:79:12 */
  assign ss_mem_active = n4405; // (signal)
  /*# sim_rtl/voicememory.vhd:80:12 */
  assign ss_mem_index = n4420; // (signal)
  /*# sim_rtl/voicememory.vhd:81:12 */
  always @*
    ss_mem_ready = n4476; // (isignal)
  initial
    ss_mem_ready = 1'b0;
  /*# sim_rtl/voicememory.vhd:82:12 */
  assign ss_voice_low = n4479; // (signal)
  /*# sim_rtl/voicememory.vhd:83:12 */
  assign ss_mem_vector = n4451; // (signal)
  /*# sim_rtl/voicememory.vhd:87:46 */
  assign rom2413_n4179 = n4180; // (signal)
  /*# sim_rtl/voicememory.vhd:87:3 */
  voicerom_Brtl_c4ea21bb365bbeeaf5f2c654883e56d11e43c44e rom2413 (
    .clk(clk),
    .addr(rom_addr),
    .\data[am] (\rom2413.data[am] ),
    .\data[pm] (\rom2413.data[pm] ),
    .\data[eg] (\rom2413.data[eg] ),
    .\data[kr] (\rom2413.data[kr] ),
    .\data[ml] (\rom2413.data[ml] ),
    .\data[kl] (\rom2413.data[kl] ),
    .\data[tl] (\rom2413.data[tl] ),
    .\data[wf] (\rom2413.data[wf] ),
    .\data[fb] (\rom2413.data[fb] ),
    .\data[ar] (\rom2413.data[ar] ),
    .\data[dr] (\rom2413.data[dr] ),
    .\data[sl] (\rom2413.data[sl] ),
    .\data[rr] (\rom2413.data[rr] ));
  /*# sim_rtl/voicememory.vhd:87:3 */
  assign n4180 = {\rom2413.data[rr] , \rom2413.data[sl] , \rom2413.data[dr] , \rom2413.data[ar] , \rom2413.data[fb] , \rom2413.data[wf] , \rom2413.data[tl] , \rom2413.data[kl] , \rom2413.data[ml] , \rom2413.data[kr] , \rom2413.data[eg] , \rom2413.data[pm] , \rom2413.data[am] };
  /*# sim_rtl/voicememory.vhd:91:14 */
  always @*
    n4183_init_id = n4481; // (isignal)
  initial
    n4183_init_id = 6'b000000;
  /*# sim_rtl/voicememory.vhd:103:38 */
  assign n4187 = {26'b0, n4183_init_id};  // uext
  /*# sim_rtl/voicememory.vhd:103:38 */
  assign n4189 = n4187 == 32'b00000000000000000000000000100110;
  /*# sim_rtl/voicememory.vhd:103:28 */
  assign n4192 = n4189 ? 1'b1 : 1'b0;
  /*# sim_rtl/voicememory.vhd:104:11 */
  assign n4194 = ~ss_hold;
  /*# sim_rtl/voicememory.vhd:105:12 */
  assign n4195 = {26'b0, n4183_init_id};  // uext
  /*# sim_rtl/voicememory.vhd:105:12 */
  assign n4197 = n4195 != 32'b00000000000000000000000000100110;
  /*# sim_rtl/voicememory.vhd:108:9 */
  assign n4199 = rstate == 2'b00;
  /*# sim_rtl/voicememory.vhd:111:9 */
  assign n4201 = rstate == 2'b01;
  /*# sim_rtl/voicememory.vhd:114:18 */
  assign n4203 = 6'b100101 - n4183_init_id;
  /*# sim_rtl/vm2413.vhd:178:17 */
  assign n4210 = rom_data[0]; // extract
  /*# sim_rtl/vm2413.vhd:178:27 */
  assign n4211 = rom_data[1]; // extract
  /*# sim_rtl/vm2413.vhd:178:20 */
  assign n4212 = {n4210, n4211};
  /*# sim_rtl/vm2413.vhd:178:37 */
  assign n4213 = rom_data[2]; // extract
  /*# sim_rtl/vm2413.vhd:178:30 */
  assign n4214 = {n4212, n4213};
  /*# sim_rtl/vm2413.vhd:178:47 */
  assign n4215 = rom_data[3]; // extract
  /*# sim_rtl/vm2413.vhd:178:40 */
  assign n4216 = {n4214, n4215};
  /*# sim_rtl/vm2413.vhd:179:17 */
  assign n4217 = rom_data[7:4]; // extract
  /*# sim_rtl/vm2413.vhd:178:50 */
  assign n4218 = {n4216, n4217};
  /*# sim_rtl/vm2413.vhd:179:27 */
  assign n4219 = rom_data[9:8]; // extract
  /*# sim_rtl/vm2413.vhd:179:20 */
  assign n4220 = {n4218, n4219};
  /*# sim_rtl/vm2413.vhd:179:37 */
  assign n4221 = rom_data[15:10]; // extract
  /*# sim_rtl/vm2413.vhd:179:30 */
  assign n4222 = {n4220, n4221};
  /*# sim_rtl/vm2413.vhd:179:47 */
  assign n4223 = rom_data[16]; // extract
  /*# sim_rtl/vm2413.vhd:179:40 */
  assign n4224 = {n4222, n4223};
  /*# sim_rtl/vm2413.vhd:179:57 */
  assign n4225 = rom_data[19:17]; // extract
  /*# sim_rtl/vm2413.vhd:179:50 */
  assign n4226 = {n4224, n4225};
  /*# sim_rtl/vm2413.vhd:180:17 */
  assign n4227 = rom_data[23:20]; // extract
  /*# sim_rtl/vm2413.vhd:179:60 */
  assign n4228 = {n4226, n4227};
  /*# sim_rtl/vm2413.vhd:180:27 */
  assign n4229 = rom_data[27:24]; // extract
  /*# sim_rtl/vm2413.vhd:180:20 */
  assign n4230 = {n4228, n4229};
  /*# sim_rtl/vm2413.vhd:180:37 */
  assign n4231 = rom_data[31:28]; // extract
  /*# sim_rtl/vm2413.vhd:180:30 */
  assign n4232 = {n4230, n4231};
  /*# sim_rtl/vm2413.vhd:180:47 */
  assign n4233 = rom_data[35:32]; // extract
  /*# sim_rtl/vm2413.vhd:180:40 */
  assign n4234 = {n4232, n4233};
  /*# sim_rtl/voicememory.vhd:116:30 */
  assign n4236 = {26'b0, n4183_init_id};  // uext
  /*# sim_rtl/voicememory.vhd:116:30 */
  assign n4238 = n4236 + 32'b00000000000000000000000000000001;
  /*# sim_rtl/voicememory.vhd:116:11 */
  assign n4239 = n4238[5:0];  // trunc
  /*# sim_rtl/voicememory.vhd:113:9 */
  assign n4241 = rstate == 2'b10;
  /*# sim_rtl/voicememory.vhd:107:9 */
  assign n4242 = {n4241, n4201, n4199};
  /*# sim_rtl/voicememory.vhd:107:9 */
  always @*
    case (n4242)
      3'b100: n4243 = n4645;
      3'b010: n4243 = voices;
      3'b001: n4243 = voices;
      default: n4243 = voices;
    endcase
  /*# sim_rtl/voicememory.vhd:107:9 */
  always @*
    case (n4242)
      3'b100: n4244 = rom_addr;
      3'b010: n4244 = rom_addr;
      3'b001: n4244 = n4183_init_id;
      default: n4244 = rom_addr;
    endcase
  /*# sim_rtl/voicememory.vhd:107:9 */
  always @*
    case (n4242)
      3'b100: n4248 = 2'b00;
      3'b010: n4248 = 2'b10;
      3'b001: n4248 = 2'b01;
      default: n4248 = rstate;
    endcase
  /*# sim_rtl/voicememory.vhd:107:9 */
  always @*
    case (n4242)
      3'b100: n4249 = n4239;
      3'b010: n4249 = n4183_init_id;
      3'b001: n4249 = n4183_init_id;
      default: n4249 = n4183_init_id;
    endcase
  /*# sim_rtl/voicememory.vhd:120:16 */
  assign n4251 = 6'b100101 - rwaddr;
  /*# sim_rtl/vm2413.vhd:178:17 */
  assign n4258 = n4146[0]; // extract
  /*# sim_rtl/vm2413.vhd:178:27 */
  assign n4259 = n4146[1]; // extract
  /*# sim_rtl/vm2413.vhd:178:20 */
  assign n4260 = {n4258, n4259};
  /*# sim_rtl/vm2413.vhd:178:37 */
  assign n4261 = n4146[2]; // extract
  /*# sim_rtl/vm2413.vhd:178:30 */
  assign n4262 = {n4260, n4261};
  /*# sim_rtl/vm2413.vhd:178:47 */
  assign n4263 = n4146[3]; // extract
  /*# sim_rtl/vm2413.vhd:178:40 */
  assign n4264 = {n4262, n4263};
  /*# sim_rtl/vm2413.vhd:179:17 */
  assign n4265 = n4146[7:4]; // extract
  /*# sim_rtl/vm2413.vhd:178:50 */
  assign n4266 = {n4264, n4265};
  /*# sim_rtl/vm2413.vhd:179:27 */
  assign n4267 = n4146[9:8]; // extract
  /*# sim_rtl/vm2413.vhd:179:20 */
  assign n4268 = {n4266, n4267};
  /*# sim_rtl/vm2413.vhd:179:37 */
  assign n4269 = n4146[15:10]; // extract
  /*# sim_rtl/vm2413.vhd:179:30 */
  assign n4270 = {n4268, n4269};
  /*# sim_rtl/vm2413.vhd:179:47 */
  assign n4271 = n4146[16]; // extract
  /*# sim_rtl/vm2413.vhd:179:40 */
  assign n4272 = {n4270, n4271};
  /*# sim_rtl/vm2413.vhd:179:57 */
  assign n4273 = n4146[19:17]; // extract
  /*# sim_rtl/vm2413.vhd:179:50 */
  assign n4274 = {n4272, n4273};
  /*# sim_rtl/vm2413.vhd:180:17 */
  assign n4275 = n4146[23:20]; // extract
  /*# sim_rtl/vm2413.vhd:179:60 */
  assign n4276 = {n4274, n4275};
  /*# sim_rtl/vm2413.vhd:180:27 */
  assign n4277 = n4146[27:24]; // extract
  /*# sim_rtl/vm2413.vhd:180:20 */
  assign n4278 = {n4276, n4277};
  /*# sim_rtl/vm2413.vhd:180:37 */
  assign n4279 = n4146[31:28]; // extract
  /*# sim_rtl/vm2413.vhd:180:30 */
  assign n4280 = {n4278, n4279};
  /*# sim_rtl/vm2413.vhd:180:47 */
  assign n4281 = n4146[35:32]; // extract
  /*# sim_rtl/vm2413.vhd:180:40 */
  assign n4282 = {n4280, n4281};
  /*# sim_rtl/voicememory.vhd:119:7 */
  assign n4284 = wr ? n4809 : voices;
  /*# sim_rtl/voicememory.vhd:105:1 */
  assign n4285 = n4197 ? n4243 : n4284;
  /*# sim_rtl/voicememory.vhd:124:20 */
  assign n4289 = ss_mem_active & ss_write;
  /*# sim_rtl/voicememory.vhd:125:11 */
  assign n4290 = ss_addr[0]; // extract
  /*# sim_rtl/voicememory.vhd:125:60 */
  assign n4292 = 6'b100101 - ss_mem_index;
  /*# sim_rtl/voicememory.vhd:125:83 */
  assign n4294 = ss_wdata[3:0]; // extract
  /*# sim_rtl/voicememory.vhd:125:96 */
  assign n4295 = {n4294, ss_voice_low};
  /*# sim_rtl/voicememory.vhd:125:1 */
  assign n4297 = n4290 ? voices : n4973;
  /*# sim_rtl/voicememory.vhd:124:1 */
  assign n4298 = n4300 ? ss_wdata : ss_voice_low;
  /*# sim_rtl/voicememory.vhd:124:1 */
  assign n4299 = n4289 ? n4297 : voices;
  /*# sim_rtl/voicememory.vhd:124:1 */
  assign n4300 = n4290 & n4289;
  /*# sim_rtl/voicememory.vhd:104:1 */
  assign n4301 = n4194 ? n4285 : n4299;
  /*# sim_rtl/voicememory.vhd:104:1 */
  assign n4302 = n4197 & n4194;
  /*# sim_rtl/voicememory.vhd:104:1 */
  assign n4303 = n4197 & n4194;
  /*# sim_rtl/voicememory.vhd:104:1 */
  assign n4304 = n4194 ? ss_voice_low : n4298;
  /*# sim_rtl/voicememory.vhd:104:1 */
  assign n4305 = n4197 & n4194;
  /*# sim_rtl/voicememory.vhd:127:54 */
  assign n4308 = 6'b100101 - ss_mem_index;
  /*# sim_rtl/vm2413.vhd:186:19 */
  assign n4315 = n4976[35]; // extract
  /*# sim_rtl/vm2413.vhd:186:37 */
  assign n4316 = n4976[34]; // extract
  /*# sim_rtl/vm2413.vhd:186:55 */
  assign n4317 = n4976[33]; // extract
  /*# sim_rtl/vm2413.vhd:186:73 */
  assign n4318 = n4976[32]; // extract
  /*# sim_rtl/vm2413.vhd:187:19 */
  assign n4319 = n4976[31:28]; // extract
  /*# sim_rtl/vm2413.vhd:187:47 */
  assign n4320 = n4976[27:26]; // extract
  /*# sim_rtl/vm2413.vhd:187:75 */
  assign n4321 = n4976[25:20]; // extract
  /*# sim_rtl/vm2413.vhd:188:19 */
  assign n4322 = n4976[19]; // extract
  /*# sim_rtl/vm2413.vhd:188:37 */
  assign n4323 = n4976[18:16]; // extract
  /*# sim_rtl/vm2413.vhd:189:19 */
  assign n4324 = n4976[15:12]; // extract
  /*# sim_rtl/vm2413.vhd:189:47 */
  assign n4325 = n4976[11:8]; // extract
  /*# sim_rtl/vm2413.vhd:189:74 */
  assign n4326 = n4976[7:4]; // extract
  /*# sim_rtl/vm2413.vhd:189:100 */
  assign n4327 = n4976[3:0]; // extract
  /*# sim_rtl/vm2413.vhd:185:12 */
  assign n4328 = {n4327, n4326, n4325, n4324, n4323, n4322, n4321, n4320, n4319, n4318, n4317, n4316, n4315};
  /*# sim_rtl/voicememory.vhd:127:102 */
  assign n4331 = 6'b100101 - rwaddr;
  /*# sim_rtl/vm2413.vhd:186:19 */
  assign n4338 = n4979[35]; // extract
  /*# sim_rtl/vm2413.vhd:186:37 */
  assign n4339 = n4979[34]; // extract
  /*# sim_rtl/vm2413.vhd:186:55 */
  assign n4340 = n4979[33]; // extract
  /*# sim_rtl/vm2413.vhd:186:73 */
  assign n4341 = n4979[32]; // extract
  /*# sim_rtl/vm2413.vhd:187:19 */
  assign n4342 = n4979[31:28]; // extract
  /*# sim_rtl/vm2413.vhd:187:47 */
  assign n4343 = n4979[27:26]; // extract
  /*# sim_rtl/vm2413.vhd:187:75 */
  assign n4344 = n4979[25:20]; // extract
  /*# sim_rtl/vm2413.vhd:188:19 */
  assign n4345 = n4979[19]; // extract
  /*# sim_rtl/vm2413.vhd:188:37 */
  assign n4346 = n4979[18:16]; // extract
  /*# sim_rtl/vm2413.vhd:189:19 */
  assign n4347 = n4979[15:12]; // extract
  /*# sim_rtl/vm2413.vhd:189:47 */
  assign n4348 = n4979[11:8]; // extract
  /*# sim_rtl/vm2413.vhd:189:74 */
  assign n4349 = n4979[7:4]; // extract
  /*# sim_rtl/vm2413.vhd:189:100 */
  assign n4350 = n4979[3:0]; // extract
  /*# sim_rtl/vm2413.vhd:185:12 */
  assign n4351 = {n4350, n4349, n4348, n4347, n4346, n4345, n4344, n4343, n4342, n4341, n4340, n4339, n4338};
  /*# sim_rtl/voicememory.vhd:127:1 */
  assign n4352 = ss_mem_active ? n4328 : n4351;
  /*# sim_rtl/voicememory.vhd:128:35 */
  assign n4355 = 6'b100101 - roaddr;
  /*# sim_rtl/vm2413.vhd:186:19 */
  assign n4362 = n4982[35]; // extract
  /*# sim_rtl/vm2413.vhd:186:37 */
  assign n4363 = n4982[34]; // extract
  /*# sim_rtl/vm2413.vhd:186:55 */
  assign n4364 = n4982[33]; // extract
  /*# sim_rtl/vm2413.vhd:186:73 */
  assign n4365 = n4982[32]; // extract
  /*# sim_rtl/vm2413.vhd:187:19 */
  assign n4366 = n4982[31:28]; // extract
  /*# sim_rtl/vm2413.vhd:187:47 */
  assign n4367 = n4982[27:26]; // extract
  /*# sim_rtl/vm2413.vhd:187:75 */
  assign n4368 = n4982[25:20]; // extract
  /*# sim_rtl/vm2413.vhd:188:19 */
  assign n4369 = n4982[19]; // extract
  /*# sim_rtl/vm2413.vhd:188:37 */
  assign n4370 = n4982[18:16]; // extract
  /*# sim_rtl/vm2413.vhd:189:19 */
  assign n4371 = n4982[15:12]; // extract
  /*# sim_rtl/vm2413.vhd:189:47 */
  assign n4372 = n4982[11:8]; // extract
  /*# sim_rtl/vm2413.vhd:189:74 */
  assign n4373 = n4982[7:4]; // extract
  /*# sim_rtl/vm2413.vhd:189:100 */
  assign n4374 = n4982[3:0]; // extract
  /*# sim_rtl/vm2413.vhd:185:12 */
  assign n4375 = {n4374, n4373, n4372, n4371, n4370, n4369, n4368, n4367, n4366, n4365, n4364, n4363, n4362};
  /*# sim_rtl/voicememory.vhd:133:43 */
  assign n4397 = {24'b0, ss_addr};  // uext
  /*# sim_rtl/voicememory.vhd:133:64 */
  assign n4399 = $signed(n4397) >= $signed(32'b00000000000000000000000000001001);
  /*# sim_rtl/voicememory.vhd:133:39 */
  assign n4400 = n4399 & ss_hold;
  /*# sim_rtl/voicememory.vhd:133:72 */
  assign n4401 = {24'b0, ss_addr};  // uext
  /*# sim_rtl/voicememory.vhd:133:93 */
  assign n4403 = $signed(n4401) <= $signed(32'b00000000000000000000000000001100);
  /*# sim_rtl/voicememory.vhd:133:68 */
  assign n4404 = n4403 & n4400;
  /*# sim_rtl/voicememory.vhd:133:22 */
  assign n4405 = n4404 ? 1'b1 : 1'b0;
  /*# sim_rtl/voicememory.vhd:134:18 */
  assign n4407 = {24'b0, ss_addr};  // uext
  /*# sim_rtl/voicememory.vhd:134:39 */
  assign n4409 = n4407 - 32'b00000000000000000000000000001001;
  /*# sim_rtl/voicememory.vhd:134:42 */
  assign n4411 = $signed(n4409) / $signed(32'b00000000000000000000000000000010); // sdiv
  /*# sim_rtl/voicememory.vhd:134:17 */
  assign n4412 = n4411[5:0];  // trunc
  /*# sim_rtl/voicememory.vhd:134:50 */
  assign n4413 = {24'b0, ss_addr};  // uext
  /*# sim_rtl/voicememory.vhd:134:71 */
  assign n4415 = $signed(n4413) >= $signed(32'b00000000000000000000000000001001);
  /*# sim_rtl/voicememory.vhd:134:79 */
  assign n4416 = {24'b0, ss_addr};  // uext
  /*# sim_rtl/voicememory.vhd:134:100 */
  assign n4418 = $signed(n4416) <= $signed(32'b00000000000000000000000000001100);
  /*# sim_rtl/voicememory.vhd:134:75 */
  assign n4419 = n4418 & n4415;
  /*# sim_rtl/voicememory.vhd:134:45 */
  assign n4420 = n4419 ? n4412 : 6'b000000;
  /*# sim_rtl/vm2413.vhd:178:17 */
  assign n4427 = n4463[0]; // extract
  /*# sim_rtl/vm2413.vhd:178:27 */
  assign n4428 = n4463[1]; // extract
  /*# sim_rtl/vm2413.vhd:178:20 */
  assign n4429 = {n4427, n4428};
  /*# sim_rtl/vm2413.vhd:178:37 */
  assign n4430 = n4463[2]; // extract
  /*# sim_rtl/vm2413.vhd:178:30 */
  assign n4431 = {n4429, n4430};
  /*# sim_rtl/vm2413.vhd:178:47 */
  assign n4432 = n4463[3]; // extract
  /*# sim_rtl/vm2413.vhd:178:40 */
  assign n4433 = {n4431, n4432};
  /*# sim_rtl/vm2413.vhd:179:17 */
  assign n4434 = n4463[7:4]; // extract
  /*# sim_rtl/vm2413.vhd:178:50 */
  assign n4435 = {n4433, n4434};
  /*# sim_rtl/vm2413.vhd:179:27 */
  assign n4436 = n4463[9:8]; // extract
  /*# sim_rtl/vm2413.vhd:179:20 */
  assign n4437 = {n4435, n4436};
  /*# sim_rtl/vm2413.vhd:179:37 */
  assign n4438 = n4463[15:10]; // extract
  /*# sim_rtl/vm2413.vhd:179:30 */
  assign n4439 = {n4437, n4438};
  /*# sim_rtl/vm2413.vhd:179:47 */
  assign n4440 = n4463[16]; // extract
  /*# sim_rtl/vm2413.vhd:179:40 */
  assign n4441 = {n4439, n4440};
  /*# sim_rtl/vm2413.vhd:179:57 */
  assign n4442 = n4463[19:17]; // extract
  /*# sim_rtl/vm2413.vhd:179:50 */
  assign n4443 = {n4441, n4442};
  /*# sim_rtl/vm2413.vhd:180:17 */
  assign n4444 = n4463[23:20]; // extract
  /*# sim_rtl/vm2413.vhd:179:60 */
  assign n4445 = {n4443, n4444};
  /*# sim_rtl/vm2413.vhd:180:27 */
  assign n4446 = n4463[27:24]; // extract
  /*# sim_rtl/vm2413.vhd:180:20 */
  assign n4447 = {n4445, n4446};
  /*# sim_rtl/vm2413.vhd:180:37 */
  assign n4448 = n4463[31:28]; // extract
  /*# sim_rtl/vm2413.vhd:180:30 */
  assign n4449 = {n4447, n4448};
  /*# sim_rtl/vm2413.vhd:180:47 */
  assign n4450 = n4463[35:32]; // extract
  /*# sim_rtl/vm2413.vhd:180:40 */
  assign n4451 = {n4449, n4450};
  /*# sim_rtl/voicememory.vhd:136:31 */
  assign n4452 = ss_mem_vector[31:0]; // extract
  /*# sim_rtl/voicememory.vhd:136:79 */
  assign n4453 = ss_addr[0]; // extract
  /*# sim_rtl/voicememory.vhd:136:68 */
  assign n4454 = n4453 & ss_mem_active;
  /*# sim_rtl/voicememory.vhd:136:45 */
  assign n4455 = n4454 ? n4452 : n4459;
  /*# sim_rtl/voicememory.vhd:136:128 */
  assign n4456 = ss_mem_vector[35:32]; // extract
  /*# sim_rtl/voicememory.vhd:136:113 */
  assign n4458 = {28'b0000000000000000000000000000, n4456};
  /*# sim_rtl/voicememory.vhd:136:87 */
  assign n4459 = ss_mem_active ? n4458 : 32'b00000000000000000000000000000000;
  /*# sim_rtl/voicememory.vhd:46:5 */
  assign n4461 = ~reset;
  /*# sim_rtl/voicememory.vhd:101:5 */
  assign n4462 = n4461 ? n4352 : n4463;
  /*# sim_rtl/voicememory.vhd:101:5 */
  always @(posedge clk)
    n4463 <= n4462;
  /*# sim_rtl/voicememory.vhd:47:5 */
  assign n4464 = ~reset;
  /*# sim_rtl/voicememory.vhd:101:5 */
  assign n4465 = n4464 ? n4375 : n4466;
  /*# sim_rtl/voicememory.vhd:101:5 */
  always @(posedge clk)
    n4466 <= n4465;
  /*# sim_rtl/voicememory.vhd:65:10 */
  assign n4467 = ~reset;
  /*# sim_rtl/voicememory.vhd:101:5 */
  assign n4468 = n4467 ? n4301 : voices;
  /*# sim_rtl/voicememory.vhd:101:5 */
  always @(posedge clk)
    n4469 <= n4468;
  /*# sim_rtl/voicememory.vhd:74:10 */
  assign n4470 = ~reset;
  /*# sim_rtl/voicememory.vhd:74:10 */
  assign n4471 = n4302 & n4470;
  /*# sim_rtl/voicememory.vhd:101:5 */
  assign n4472 = n4471 ? n4244 : rom_addr;
  /*# sim_rtl/voicememory.vhd:101:5 */
  always @(posedge clk)
    n4473 <= n4472;
  /*# sim_rtl/voicememory.vhd:101:5 */
  assign n4474 = n4303 ? n4248 : rstate;
  /*# sim_rtl/voicememory.vhd:101:5 */
  always @(posedge clk or posedge reset)
    if (reset)
      n4475 <= 2'b00;
    else
      n4475 <= n4474;
  /*# sim_rtl/voicememory.vhd:101:5 */
  always @(posedge clk or posedge reset)
    if (reset)
      n4476 <= 1'b0;
    else
      n4476 <= n4192;
  /*# sim_rtl/voicememory.vhd:82:12 */
  assign n4477 = ~reset;
  /*# sim_rtl/voicememory.vhd:101:5 */
  assign n4478 = n4477 ? n4304 : ss_voice_low;
  /*# sim_rtl/voicememory.vhd:101:5 */
  always @(posedge clk)
    n4479 <= n4478;
  /*# sim_rtl/voicememory.vhd:101:5 */
  assign n4480 = n4305 ? n4249 : n4183_init_id;
  /*# sim_rtl/voicememory.vhd:101:5 */
  always @(posedge clk or posedge reset)
    if (reset)
      n4481 <= 6'b000000;
    else
      n4481 <= n4480;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4482 = n4203[5]; // extract
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4483 = ~n4482;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4484 = n4203[4]; // extract
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4485 = ~n4484;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4486 = n4483 & n4485;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4487 = n4483 & n4484;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4488 = n4482 & n4485;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4489 = n4203[3]; // extract
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4490 = ~n4489;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4491 = n4486 & n4490;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4492 = n4486 & n4489;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4493 = n4487 & n4490;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4494 = n4487 & n4489;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4495 = n4488 & n4490;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4496 = n4203[2]; // extract
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4497 = ~n4496;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4498 = n4491 & n4497;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4499 = n4491 & n4496;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4500 = n4492 & n4497;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4501 = n4492 & n4496;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4502 = n4493 & n4497;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4503 = n4493 & n4496;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4504 = n4494 & n4497;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4505 = n4494 & n4496;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4506 = n4495 & n4497;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4507 = n4495 & n4496;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4508 = n4203[1]; // extract
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4509 = ~n4508;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4510 = n4498 & n4509;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4511 = n4498 & n4508;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4512 = n4499 & n4509;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4513 = n4499 & n4508;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4514 = n4500 & n4509;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4515 = n4500 & n4508;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4516 = n4501 & n4509;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4517 = n4501 & n4508;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4518 = n4502 & n4509;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4519 = n4502 & n4508;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4520 = n4503 & n4509;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4521 = n4503 & n4508;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4522 = n4504 & n4509;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4523 = n4504 & n4508;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4524 = n4505 & n4509;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4525 = n4505 & n4508;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4526 = n4506 & n4509;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4527 = n4506 & n4508;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4528 = n4507 & n4509;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4529 = n4203[0]; // extract
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4530 = ~n4529;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4531 = n4510 & n4530;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4532 = n4510 & n4529;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4533 = n4511 & n4530;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4534 = n4511 & n4529;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4535 = n4512 & n4530;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4536 = n4512 & n4529;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4537 = n4513 & n4530;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4538 = n4513 & n4529;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4539 = n4514 & n4530;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4540 = n4514 & n4529;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4541 = n4515 & n4530;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4542 = n4515 & n4529;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4543 = n4516 & n4530;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4544 = n4516 & n4529;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4545 = n4517 & n4530;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4546 = n4517 & n4529;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4547 = n4518 & n4530;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4548 = n4518 & n4529;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4549 = n4519 & n4530;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4550 = n4519 & n4529;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4551 = n4520 & n4530;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4552 = n4520 & n4529;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4553 = n4521 & n4530;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4554 = n4521 & n4529;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4555 = n4522 & n4530;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4556 = n4522 & n4529;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4557 = n4523 & n4530;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4558 = n4523 & n4529;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4559 = n4524 & n4530;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4560 = n4524 & n4529;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4561 = n4525 & n4530;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4562 = n4525 & n4529;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4563 = n4526 & n4530;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4564 = n4526 & n4529;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4565 = n4527 & n4530;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4566 = n4527 & n4529;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4567 = n4528 & n4530;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4568 = n4528 & n4529;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4569 = voices[35:0]; // extract
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4570 = n4531 ? n4234 : n4569;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4571 = voices[71:36]; // extract
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4572 = n4532 ? n4234 : n4571;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4573 = voices[107:72]; // extract
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4574 = n4533 ? n4234 : n4573;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4575 = voices[143:108]; // extract
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4576 = n4534 ? n4234 : n4575;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4577 = voices[179:144]; // extract
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4578 = n4535 ? n4234 : n4577;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4579 = voices[215:180]; // extract
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4580 = n4536 ? n4234 : n4579;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4581 = voices[251:216]; // extract
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4582 = n4537 ? n4234 : n4581;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4583 = voices[287:252]; // extract
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4584 = n4538 ? n4234 : n4583;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4585 = voices[323:288]; // extract
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4586 = n4539 ? n4234 : n4585;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4587 = voices[359:324]; // extract
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4588 = n4540 ? n4234 : n4587;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4589 = voices[395:360]; // extract
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4590 = n4541 ? n4234 : n4589;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4591 = voices[431:396]; // extract
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4592 = n4542 ? n4234 : n4591;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4593 = voices[467:432]; // extract
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4594 = n4543 ? n4234 : n4593;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4595 = voices[503:468]; // extract
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4596 = n4544 ? n4234 : n4595;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4597 = voices[539:504]; // extract
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4598 = n4545 ? n4234 : n4597;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4599 = voices[575:540]; // extract
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4600 = n4546 ? n4234 : n4599;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4601 = voices[611:576]; // extract
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4602 = n4547 ? n4234 : n4601;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4603 = voices[647:612]; // extract
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4604 = n4548 ? n4234 : n4603;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4605 = voices[683:648]; // extract
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4606 = n4549 ? n4234 : n4605;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4607 = voices[719:684]; // extract
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4608 = n4550 ? n4234 : n4607;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4609 = voices[755:720]; // extract
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4610 = n4551 ? n4234 : n4609;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4611 = voices[791:756]; // extract
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4612 = n4552 ? n4234 : n4611;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4613 = voices[827:792]; // extract
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4614 = n4553 ? n4234 : n4613;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4615 = voices[863:828]; // extract
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4616 = n4554 ? n4234 : n4615;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4617 = voices[899:864]; // extract
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4618 = n4555 ? n4234 : n4617;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4619 = voices[935:900]; // extract
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4620 = n4556 ? n4234 : n4619;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4621 = voices[971:936]; // extract
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4622 = n4557 ? n4234 : n4621;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4623 = voices[1007:972]; // extract
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4624 = n4558 ? n4234 : n4623;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4625 = voices[1043:1008]; // extract
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4626 = n4559 ? n4234 : n4625;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4627 = voices[1079:1044]; // extract
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4628 = n4560 ? n4234 : n4627;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4629 = voices[1115:1080]; // extract
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4630 = n4561 ? n4234 : n4629;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4631 = voices[1151:1116]; // extract
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4632 = n4562 ? n4234 : n4631;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4633 = voices[1187:1152]; // extract
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4634 = n4563 ? n4234 : n4633;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4635 = voices[1223:1188]; // extract
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4636 = n4564 ? n4234 : n4635;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4637 = voices[1259:1224]; // extract
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4638 = n4565 ? n4234 : n4637;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4639 = voices[1295:1260]; // extract
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4640 = n4566 ? n4234 : n4639;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4641 = voices[1331:1296]; // extract
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4642 = n4567 ? n4234 : n4641;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4643 = voices[1367:1332]; // extract
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4644 = n4568 ? n4234 : n4643;
  /*# sim_rtl/voicememory.vhd:114:11 */
  assign n4645 = {n4644, n4642, n4640, n4638, n4636, n4634, n4632, n4630, n4628, n4626, n4624, n4622, n4620, n4618, n4616, n4614, n4612, n4610, n4608, n4606, n4604, n4602, n4600, n4598, n4596, n4594, n4592, n4590, n4588, n4586, n4584, n4582, n4580, n4578, n4576, n4574, n4572, n4570};
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4646 = n4251[5]; // extract
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4647 = ~n4646;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4648 = n4251[4]; // extract
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4649 = ~n4648;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4650 = n4647 & n4649;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4651 = n4647 & n4648;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4652 = n4646 & n4649;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4653 = n4251[3]; // extract
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4654 = ~n4653;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4655 = n4650 & n4654;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4656 = n4650 & n4653;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4657 = n4651 & n4654;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4658 = n4651 & n4653;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4659 = n4652 & n4654;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4660 = n4251[2]; // extract
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4661 = ~n4660;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4662 = n4655 & n4661;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4663 = n4655 & n4660;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4664 = n4656 & n4661;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4665 = n4656 & n4660;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4666 = n4657 & n4661;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4667 = n4657 & n4660;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4668 = n4658 & n4661;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4669 = n4658 & n4660;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4670 = n4659 & n4661;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4671 = n4659 & n4660;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4672 = n4251[1]; // extract
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4673 = ~n4672;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4674 = n4662 & n4673;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4675 = n4662 & n4672;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4676 = n4663 & n4673;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4677 = n4663 & n4672;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4678 = n4664 & n4673;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4679 = n4664 & n4672;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4680 = n4665 & n4673;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4681 = n4665 & n4672;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4682 = n4666 & n4673;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4683 = n4666 & n4672;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4684 = n4667 & n4673;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4685 = n4667 & n4672;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4686 = n4668 & n4673;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4687 = n4668 & n4672;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4688 = n4669 & n4673;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4689 = n4669 & n4672;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4690 = n4670 & n4673;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4691 = n4670 & n4672;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4692 = n4671 & n4673;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4693 = n4251[0]; // extract
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4694 = ~n4693;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4695 = n4674 & n4694;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4696 = n4674 & n4693;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4697 = n4675 & n4694;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4698 = n4675 & n4693;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4699 = n4676 & n4694;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4700 = n4676 & n4693;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4701 = n4677 & n4694;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4702 = n4677 & n4693;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4703 = n4678 & n4694;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4704 = n4678 & n4693;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4705 = n4679 & n4694;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4706 = n4679 & n4693;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4707 = n4680 & n4694;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4708 = n4680 & n4693;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4709 = n4681 & n4694;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4710 = n4681 & n4693;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4711 = n4682 & n4694;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4712 = n4682 & n4693;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4713 = n4683 & n4694;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4714 = n4683 & n4693;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4715 = n4684 & n4694;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4716 = n4684 & n4693;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4717 = n4685 & n4694;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4718 = n4685 & n4693;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4719 = n4686 & n4694;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4720 = n4686 & n4693;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4721 = n4687 & n4694;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4722 = n4687 & n4693;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4723 = n4688 & n4694;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4724 = n4688 & n4693;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4725 = n4689 & n4694;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4726 = n4689 & n4693;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4727 = n4690 & n4694;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4728 = n4690 & n4693;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4729 = n4691 & n4694;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4730 = n4691 & n4693;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4731 = n4692 & n4694;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4732 = n4692 & n4693;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4733 = voices[35:0]; // extract
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4734 = n4695 ? n4282 : n4733;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4735 = voices[71:36]; // extract
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4736 = n4696 ? n4282 : n4735;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4737 = voices[107:72]; // extract
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4738 = n4697 ? n4282 : n4737;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4739 = voices[143:108]; // extract
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4740 = n4698 ? n4282 : n4739;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4741 = voices[179:144]; // extract
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4742 = n4699 ? n4282 : n4741;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4743 = voices[215:180]; // extract
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4744 = n4700 ? n4282 : n4743;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4745 = voices[251:216]; // extract
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4746 = n4701 ? n4282 : n4745;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4747 = voices[287:252]; // extract
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4748 = n4702 ? n4282 : n4747;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4749 = voices[323:288]; // extract
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4750 = n4703 ? n4282 : n4749;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4751 = voices[359:324]; // extract
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4752 = n4704 ? n4282 : n4751;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4753 = voices[395:360]; // extract
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4754 = n4705 ? n4282 : n4753;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4755 = voices[431:396]; // extract
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4756 = n4706 ? n4282 : n4755;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4757 = voices[467:432]; // extract
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4758 = n4707 ? n4282 : n4757;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4759 = voices[503:468]; // extract
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4760 = n4708 ? n4282 : n4759;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4761 = voices[539:504]; // extract
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4762 = n4709 ? n4282 : n4761;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4763 = voices[575:540]; // extract
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4764 = n4710 ? n4282 : n4763;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4765 = voices[611:576]; // extract
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4766 = n4711 ? n4282 : n4765;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4767 = voices[647:612]; // extract
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4768 = n4712 ? n4282 : n4767;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4769 = voices[683:648]; // extract
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4770 = n4713 ? n4282 : n4769;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4771 = voices[719:684]; // extract
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4772 = n4714 ? n4282 : n4771;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4773 = voices[755:720]; // extract
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4774 = n4715 ? n4282 : n4773;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4775 = voices[791:756]; // extract
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4776 = n4716 ? n4282 : n4775;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4777 = voices[827:792]; // extract
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4778 = n4717 ? n4282 : n4777;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4779 = voices[863:828]; // extract
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4780 = n4718 ? n4282 : n4779;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4781 = voices[899:864]; // extract
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4782 = n4719 ? n4282 : n4781;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4783 = voices[935:900]; // extract
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4784 = n4720 ? n4282 : n4783;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4785 = voices[971:936]; // extract
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4786 = n4721 ? n4282 : n4785;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4787 = voices[1007:972]; // extract
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4788 = n4722 ? n4282 : n4787;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4789 = voices[1043:1008]; // extract
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4790 = n4723 ? n4282 : n4789;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4791 = voices[1079:1044]; // extract
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4792 = n4724 ? n4282 : n4791;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4793 = voices[1115:1080]; // extract
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4794 = n4725 ? n4282 : n4793;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4795 = voices[1151:1116]; // extract
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4796 = n4726 ? n4282 : n4795;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4797 = voices[1187:1152]; // extract
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4798 = n4727 ? n4282 : n4797;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4799 = voices[1223:1188]; // extract
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4800 = n4728 ? n4282 : n4799;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4801 = voices[1259:1224]; // extract
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4802 = n4729 ? n4282 : n4801;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4803 = voices[1295:1260]; // extract
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4804 = n4730 ? n4282 : n4803;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4805 = voices[1331:1296]; // extract
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4806 = n4731 ? n4282 : n4805;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4807 = voices[1367:1332]; // extract
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4808 = n4732 ? n4282 : n4807;
  /*# sim_rtl/voicememory.vhd:120:9 */
  assign n4809 = {n4808, n4806, n4804, n4802, n4800, n4798, n4796, n4794, n4792, n4790, n4788, n4786, n4784, n4782, n4780, n4778, n4776, n4774, n4772, n4770, n4768, n4766, n4764, n4762, n4760, n4758, n4756, n4754, n4752, n4750, n4748, n4746, n4744, n4742, n4740, n4738, n4736, n4734};
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4810 = n4292[5]; // extract
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4811 = ~n4810;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4812 = n4292[4]; // extract
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4813 = ~n4812;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4814 = n4811 & n4813;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4815 = n4811 & n4812;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4816 = n4810 & n4813;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4817 = n4292[3]; // extract
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4818 = ~n4817;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4819 = n4814 & n4818;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4820 = n4814 & n4817;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4821 = n4815 & n4818;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4822 = n4815 & n4817;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4823 = n4816 & n4818;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4824 = n4292[2]; // extract
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4825 = ~n4824;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4826 = n4819 & n4825;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4827 = n4819 & n4824;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4828 = n4820 & n4825;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4829 = n4820 & n4824;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4830 = n4821 & n4825;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4831 = n4821 & n4824;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4832 = n4822 & n4825;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4833 = n4822 & n4824;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4834 = n4823 & n4825;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4835 = n4823 & n4824;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4836 = n4292[1]; // extract
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4837 = ~n4836;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4838 = n4826 & n4837;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4839 = n4826 & n4836;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4840 = n4827 & n4837;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4841 = n4827 & n4836;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4842 = n4828 & n4837;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4843 = n4828 & n4836;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4844 = n4829 & n4837;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4845 = n4829 & n4836;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4846 = n4830 & n4837;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4847 = n4830 & n4836;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4848 = n4831 & n4837;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4849 = n4831 & n4836;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4850 = n4832 & n4837;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4851 = n4832 & n4836;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4852 = n4833 & n4837;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4853 = n4833 & n4836;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4854 = n4834 & n4837;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4855 = n4834 & n4836;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4856 = n4835 & n4837;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4857 = n4292[0]; // extract
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4858 = ~n4857;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4859 = n4838 & n4858;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4860 = n4838 & n4857;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4861 = n4839 & n4858;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4862 = n4839 & n4857;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4863 = n4840 & n4858;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4864 = n4840 & n4857;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4865 = n4841 & n4858;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4866 = n4841 & n4857;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4867 = n4842 & n4858;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4868 = n4842 & n4857;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4869 = n4843 & n4858;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4870 = n4843 & n4857;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4871 = n4844 & n4858;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4872 = n4844 & n4857;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4873 = n4845 & n4858;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4874 = n4845 & n4857;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4875 = n4846 & n4858;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4876 = n4846 & n4857;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4877 = n4847 & n4858;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4878 = n4847 & n4857;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4879 = n4848 & n4858;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4880 = n4848 & n4857;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4881 = n4849 & n4858;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4882 = n4849 & n4857;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4883 = n4850 & n4858;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4884 = n4850 & n4857;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4885 = n4851 & n4858;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4886 = n4851 & n4857;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4887 = n4852 & n4858;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4888 = n4852 & n4857;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4889 = n4853 & n4858;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4890 = n4853 & n4857;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4891 = n4854 & n4858;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4892 = n4854 & n4857;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4893 = n4855 & n4858;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4894 = n4855 & n4857;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4895 = n4856 & n4858;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4896 = n4856 & n4857;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4897 = voices[35:0]; // extract
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4898 = n4859 ? n4295 : n4897;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4899 = voices[71:36]; // extract
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4900 = n4860 ? n4295 : n4899;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4901 = voices[107:72]; // extract
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4902 = n4861 ? n4295 : n4901;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4903 = voices[143:108]; // extract
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4904 = n4862 ? n4295 : n4903;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4905 = voices[179:144]; // extract
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4906 = n4863 ? n4295 : n4905;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4907 = voices[215:180]; // extract
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4908 = n4864 ? n4295 : n4907;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4909 = voices[251:216]; // extract
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4910 = n4865 ? n4295 : n4909;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4911 = voices[287:252]; // extract
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4912 = n4866 ? n4295 : n4911;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4913 = voices[323:288]; // extract
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4914 = n4867 ? n4295 : n4913;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4915 = voices[359:324]; // extract
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4916 = n4868 ? n4295 : n4915;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4917 = voices[395:360]; // extract
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4918 = n4869 ? n4295 : n4917;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4919 = voices[431:396]; // extract
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4920 = n4870 ? n4295 : n4919;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4921 = voices[467:432]; // extract
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4922 = n4871 ? n4295 : n4921;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4923 = voices[503:468]; // extract
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4924 = n4872 ? n4295 : n4923;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4925 = voices[539:504]; // extract
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4926 = n4873 ? n4295 : n4925;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4927 = voices[575:540]; // extract
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4928 = n4874 ? n4295 : n4927;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4929 = voices[611:576]; // extract
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4930 = n4875 ? n4295 : n4929;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4931 = voices[647:612]; // extract
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4932 = n4876 ? n4295 : n4931;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4933 = voices[683:648]; // extract
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4934 = n4877 ? n4295 : n4933;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4935 = voices[719:684]; // extract
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4936 = n4878 ? n4295 : n4935;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4937 = voices[755:720]; // extract
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4938 = n4879 ? n4295 : n4937;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4939 = voices[791:756]; // extract
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4940 = n4880 ? n4295 : n4939;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4941 = voices[827:792]; // extract
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4942 = n4881 ? n4295 : n4941;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4943 = voices[863:828]; // extract
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4944 = n4882 ? n4295 : n4943;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4945 = voices[899:864]; // extract
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4946 = n4883 ? n4295 : n4945;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4947 = voices[935:900]; // extract
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4948 = n4884 ? n4295 : n4947;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4949 = voices[971:936]; // extract
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4950 = n4885 ? n4295 : n4949;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4951 = voices[1007:972]; // extract
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4952 = n4886 ? n4295 : n4951;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4953 = voices[1043:1008]; // extract
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4954 = n4887 ? n4295 : n4953;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4955 = voices[1079:1044]; // extract
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4956 = n4888 ? n4295 : n4955;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4957 = voices[1115:1080]; // extract
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4958 = n4889 ? n4295 : n4957;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4959 = voices[1151:1116]; // extract
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4960 = n4890 ? n4295 : n4959;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4961 = voices[1187:1152]; // extract
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4962 = n4891 ? n4295 : n4961;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4963 = voices[1223:1188]; // extract
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4964 = n4892 ? n4295 : n4963;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4965 = voices[1259:1224]; // extract
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4966 = n4893 ? n4295 : n4965;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4967 = voices[1295:1260]; // extract
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4968 = n4894 ? n4295 : n4967;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4969 = voices[1331:1296]; // extract
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4970 = n4895 ? n4295 : n4969;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4971 = voices[1367:1332]; // extract
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4972 = n4896 ? n4295 : n4971;
  /*# sim_rtl/voicememory.vhd:125:53 */
  assign n4973 = {n4972, n4970, n4968, n4966, n4964, n4962, n4960, n4958, n4956, n4954, n4952, n4950, n4948, n4946, n4944, n4942, n4940, n4938, n4936, n4934, n4932, n4930, n4928, n4926, n4924, n4922, n4920, n4918, n4916, n4914, n4912, n4910, n4908, n4906, n4904, n4902, n4900, n4898};
  /*# sim_rtl/voicememory.vhd:127:54 */
  assign n4975 = {936'bX, voices};
  /*# sim_rtl/voicememory.vhd:127:54 */
  assign n4976 = n4975[n4308 * 36 +: 36]; //(Bmux)
  /*# sim_rtl/voicememory.vhd:127:102 */
  assign n4978 = {936'bX, voices};
  /*# sim_rtl/voicememory.vhd:127:102 */
  assign n4979 = n4978[n4331 * 36 +: 36]; //(Bmux)
  /*# sim_rtl/voicememory.vhd:128:35 */
  assign n4981 = {936'bX, voices};
  /*# sim_rtl/voicememory.vhd:128:35 */
  assign n4982 = n4981[n4355 * 36 +: 36]; //(Bmux)
endmodule

module registermemory_Brtl
  (input  clk,
   input  reset,
   input  [3:0] addr,
   input  wr,
   input  [23:0] idata,
   output [23:0] odata,
   input  ss_hold,
   input  [7:0] ss_addr,
   input  ss_read,
   input  ss_write,
   input  [31:0] ss_wdata,
   output [31:0] ss_rdata,
   output ss_initialized);
  (* ramstyle="logic" *) wire [215:0] regs_array;
  reg [31:0] ss_local_data;
  wire ss_mem_active;
  wire [3:0] ss_mem_index;
  reg ss_mem_ready;
  wire [23:0] ss_mem_vector;
  reg [3:0] n3902_init_state;
  wire [31:0] n3906;
  wire n3908;
  wire n3911;
  wire n3913;
  wire [31:0] n3914;
  wire n3916;
  wire [3:0] n3918;
  wire [31:0] n3922;
  wire [31:0] n3924;
  wire [3:0] n3925;
  wire [3:0] n3928;
  wire [215:0] n3931;
  wire [215:0] n3932;
  wire n3934;
  wire [3:0] n3936;
  wire [7:0] n3938;
  wire [9:0] n3940;
  wire [13:0] n3941;
  wire [23:0] n3942;
  wire [215:0] n3944;
  wire [215:0] n3945;
  wire n3946;
  wire [3:0] n3948;
  wire [3:0] n3953;
  wire [23:0] n3956;
  wire [31:0] n3969;
  wire n3971;
  wire n3972;
  wire [31:0] n3973;
  wire n3975;
  wire n3976;
  wire n3977;
  wire [31:0] n3979;
  wire [31:0] n3981;
  wire [3:0] n3982;
  wire [31:0] n3983;
  wire n3985;
  wire [31:0] n3986;
  wire n3988;
  wire n3989;
  wire [3:0] n3990;
  wire [7:0] n3992;
  wire [17:0] n3994;
  wire [13:0] n3995;
  wire [31:0] n3996;
  wire [31:0] n3997;
  wire n3999;
  wire [23:0] n4000;
  reg [23:0] n4001;
  wire n4002;
  wire [215:0] n4003;
  reg [215:0] n4004;
  reg n4005;
  wire [3:0] n4006;
  reg [3:0] n4007;
  wire n4008;
  wire n4009;
  wire n4010;
  wire n4011;
  wire n4012;
  wire n4013;
  wire n4014;
  wire n4015;
  wire n4016;
  wire n4017;
  wire n4018;
  wire n4019;
  wire n4020;
  wire n4021;
  wire n4022;
  wire n4023;
  wire n4024;
  wire n4025;
  wire n4026;
  wire n4027;
  wire n4028;
  wire n4029;
  wire n4030;
  wire n4031;
  wire n4032;
  wire [23:0] n4033;
  wire [23:0] n4034;
  wire [23:0] n4035;
  wire [23:0] n4036;
  wire [23:0] n4037;
  wire [23:0] n4038;
  wire [23:0] n4039;
  wire [23:0] n4040;
  wire [23:0] n4041;
  wire [23:0] n4042;
  wire [23:0] n4043;
  wire [23:0] n4044;
  wire [23:0] n4045;
  wire [23:0] n4046;
  wire [23:0] n4047;
  wire [23:0] n4048;
  wire [23:0] n4049;
  wire [23:0] n4050;
  wire [215:0] n4051;
  wire n4052;
  wire n4053;
  wire n4054;
  wire n4055;
  wire n4056;
  wire n4057;
  wire n4058;
  wire n4059;
  wire n4060;
  wire n4061;
  wire n4062;
  wire n4063;
  wire n4064;
  wire n4065;
  wire n4066;
  wire n4067;
  wire n4068;
  wire n4069;
  wire n4070;
  wire n4071;
  wire n4072;
  wire n4073;
  wire n4074;
  wire n4075;
  wire n4076;
  wire [23:0] n4077;
  wire [23:0] n4078;
  wire [23:0] n4079;
  wire [23:0] n4080;
  wire [23:0] n4081;
  wire [23:0] n4082;
  wire [23:0] n4083;
  wire [23:0] n4084;
  wire [23:0] n4085;
  wire [23:0] n4086;
  wire [23:0] n4087;
  wire [23:0] n4088;
  wire [23:0] n4089;
  wire [23:0] n4090;
  wire [23:0] n4091;
  wire [23:0] n4092;
  wire [23:0] n4093;
  wire [23:0] n4094;
  wire [215:0] n4095;
  wire n4096;
  wire n4097;
  wire n4098;
  wire n4099;
  wire n4100;
  wire n4101;
  wire n4102;
  wire n4103;
  wire n4104;
  wire n4105;
  wire n4106;
  wire n4107;
  wire n4108;
  wire n4109;
  wire n4110;
  wire n4111;
  wire n4112;
  wire n4113;
  wire n4114;
  wire n4115;
  wire n4116;
  wire n4117;
  wire n4118;
  wire n4119;
  wire n4120;
  wire [23:0] n4121;
  wire [23:0] n4122;
  wire [23:0] n4123;
  wire [23:0] n4124;
  wire [23:0] n4125;
  wire [23:0] n4126;
  wire [23:0] n4127;
  wire [23:0] n4128;
  wire [23:0] n4129;
  wire [23:0] n4130;
  wire [23:0] n4131;
  wire [23:0] n4132;
  wire [23:0] n4133;
  wire [23:0] n4134;
  wire [23:0] n4135;
  wire [23:0] n4136;
  wire [23:0] n4137;
  wire [23:0] n4138;
  wire [215:0] n4139;
  wire [383:0] n4141;
  wire [23:0] n4142;
  wire [383:0] n4144;
  wire [23:0] n4145;
  assign odata = n4001; //(module output)
  assign ss_rdata = ss_local_data; //(module output)
  assign ss_initialized = ss_mem_ready; //(module output)
  /*# sim_rtl/registermemory.vhd:64:12 */
  assign regs_array = n4004; // (signal)
  /*# sim_rtl/registermemory.vhd:68:12 */
  always @*
    ss_local_data = n3997; // (isignal)
  initial
    ss_local_data = 32'b00000000000000000000000000000000;
  /*# sim_rtl/registermemory.vhd:69:12 */
  assign ss_mem_active = n3977; // (signal)
  /*# sim_rtl/registermemory.vhd:70:12 */
  assign ss_mem_index = n3990; // (signal)
  /*# sim_rtl/registermemory.vhd:71:12 */
  always @*
    ss_mem_ready = n4005; // (isignal)
  initial
    ss_mem_ready = 1'b0;
  /*# sim_rtl/registermemory.vhd:72:12 */
  assign ss_mem_vector = n4001; // (signal)
  /*# sim_rtl/registermemory.vhd:76:18 */
  always @*
    n3902_init_state = n4007; // (isignal)
  initial
    n3902_init_state = 4'b0000;
  /*# sim_rtl/registermemory.vhd:82:47 */
  assign n3906 = {28'b0, n3902_init_state};  // uext
  /*# sim_rtl/registermemory.vhd:82:47 */
  assign n3908 = n3906 == 32'b00000000000000000000000000001001;
  /*# sim_rtl/registermemory.vhd:82:34 */
  assign n3911 = n3908 ? 1'b1 : 1'b0;
  /*# sim_rtl/registermemory.vhd:83:11 */
  assign n3913 = ~ss_hold;
  /*# sim_rtl/registermemory.vhd:84:16 */
  assign n3914 = {28'b0, n3902_init_state};  // uext
  /*# sim_rtl/registermemory.vhd:84:16 */
  assign n3916 = n3914 != 32'b00000000000000000000000000001001;
  /*# sim_rtl/registermemory.vhd:86:29 */
  assign n3918 = 4'b1000 - n3902_init_state;
  /*# sim_rtl/registermemory.vhd:87:42 */
  assign n3922 = {28'b0, n3902_init_state};  // uext
  /*# sim_rtl/registermemory.vhd:87:42 */
  assign n3924 = n3922 + 32'b00000000000000000000000000000001;
  /*# sim_rtl/registermemory.vhd:87:17 */
  assign n3925 = n3924[3:0];  // trunc
  /*# sim_rtl/registermemory.vhd:90:29 */
  assign n3928 = 4'b1000 - addr;
  /*# sim_rtl/registermemory.vhd:88:13 */
  assign n3931 = wr ? n4095 : regs_array;
  /*# sim_rtl/registermemory.vhd:84:1 */
  assign n3932 = n3916 ? n4051 : n3931;
  /*# sim_rtl/registermemory.vhd:94:20 */
  assign n3934 = ss_mem_active & ss_write;
  /*# sim_rtl/registermemory.vhd:95:12 */
  assign n3936 = 4'b1000 - ss_mem_index;
  /*# sim_rtl/registermemory.vhd:95:35 */
  assign n3938 = ss_wdata[21:14]; // extract
  /*# sim_rtl/registermemory.vhd:95:50 */
  assign n3940 = {n3938, 2'b00};
  /*# sim_rtl/registermemory.vhd:95:67 */
  assign n3941 = ss_wdata[13:0]; // extract
  /*# sim_rtl/registermemory.vhd:95:57 */
  assign n3942 = {n3940, n3941};
  /*# sim_rtl/registermemory.vhd:94:1 */
  assign n3944 = n3934 ? n4139 : regs_array;
  /*# sim_rtl/registermemory.vhd:83:1 */
  assign n3945 = n3913 ? n3932 : n3944;
  /*# sim_rtl/registermemory.vhd:83:1 */
  assign n3946 = n3916 & n3913;
  /*# sim_rtl/registermemory.vhd:97:47 */
  assign n3948 = 4'b1000 - ss_mem_index;
  /*# sim_rtl/registermemory.vhd:97:88 */
  assign n3953 = 4'b1000 - addr;
  /*# sim_rtl/registermemory.vhd:97:1 */
  assign n3956 = ss_mem_active ? n4142 : n4145;
  /*# sim_rtl/registermemory.vhd:100:43 */
  assign n3969 = {24'b0, ss_addr};  // uext
  /*# sim_rtl/registermemory.vhd:100:64 */
  assign n3971 = $signed(n3969) >= $signed(32'b00000000000000000000000000000000);
  /*# sim_rtl/registermemory.vhd:100:39 */
  assign n3972 = n3971 & ss_hold;
  /*# sim_rtl/registermemory.vhd:100:72 */
  assign n3973 = {24'b0, ss_addr};  // uext
  /*# sim_rtl/registermemory.vhd:100:93 */
  assign n3975 = $signed(n3973) <= $signed(32'b00000000000000000000000000001000);
  /*# sim_rtl/registermemory.vhd:100:68 */
  assign n3976 = n3975 & n3972;
  /*# sim_rtl/registermemory.vhd:100:22 */
  assign n3977 = n3976 ? 1'b1 : 1'b0;
  /*# sim_rtl/registermemory.vhd:101:17 */
  assign n3979 = {24'b0, ss_addr};  // uext
  /*# sim_rtl/registermemory.vhd:101:38 */
  assign n3981 = n3979 - 32'b00000000000000000000000000000000;
  /*# sim_rtl/registermemory.vhd:101:17 */
  assign n3982 = n3981[3:0];  // trunc
  /*# sim_rtl/registermemory.vhd:101:46 */
  assign n3983 = {24'b0, ss_addr};  // uext
  /*# sim_rtl/registermemory.vhd:101:67 */
  assign n3985 = $signed(n3983) >= $signed(32'b00000000000000000000000000000000);
  /*# sim_rtl/registermemory.vhd:101:75 */
  assign n3986 = {24'b0, ss_addr};  // uext
  /*# sim_rtl/registermemory.vhd:101:96 */
  assign n3988 = $signed(n3986) <= $signed(32'b00000000000000000000000000001000);
  /*# sim_rtl/registermemory.vhd:101:71 */
  assign n3989 = n3988 & n3985;
  /*# sim_rtl/registermemory.vhd:101:41 */
  assign n3990 = n3989 ? n3982 : 4'b0000;
  /*# sim_rtl/registermemory.vhd:103:53 */
  assign n3992 = ss_mem_vector[23:16]; // extract
  /*# sim_rtl/registermemory.vhd:103:38 */
  assign n3994 = {10'b0000000000, n3992};
  /*# sim_rtl/registermemory.vhd:103:83 */
  assign n3995 = ss_mem_vector[13:0]; // extract
  /*# sim_rtl/registermemory.vhd:103:68 */
  assign n3996 = {n3994, n3995};
  /*# sim_rtl/registermemory.vhd:103:97 */
  assign n3997 = ss_mem_active ? n3996 : 32'b00000000000000000000000000000000;
  /*# sim_rtl/registermemory.vhd:48:9 */
  assign n3999 = ~reset;
  /*# sim_rtl/registermemory.vhd:81:9 */
  assign n4000 = n3999 ? n3956 : n4001;
  /*# sim_rtl/registermemory.vhd:81:9 */
  always @(posedge clk)
    n4001 <= n4000;
  /*# sim_rtl/registermemory.vhd:64:12 */
  assign n4002 = ~reset;
  /*# sim_rtl/registermemory.vhd:81:9 */
  assign n4003 = n4002 ? n3945 : regs_array;
  /*# sim_rtl/registermemory.vhd:81:9 */
  always @(posedge clk)
    n4004 <= n4003;
  /*# sim_rtl/registermemory.vhd:81:9 */
  always @(posedge clk or posedge reset)
    if (reset)
      n4005 <= 1'b0;
    else
      n4005 <= n3911;
  /*# sim_rtl/registermemory.vhd:81:9 */
  assign n4006 = n3946 ? n3925 : n3902_init_state;
  /*# sim_rtl/registermemory.vhd:81:9 */
  always @(posedge clk or posedge reset)
    if (reset)
      n4007 <= 4'b0000;
    else
      n4007 <= n4006;
  /*# sim_rtl/registermemory.vhd:86:17 */
  assign n4008 = n3918[3]; // extract
  /*# sim_rtl/registermemory.vhd:86:17 */
  assign n4009 = ~n4008;
  /*# sim_rtl/registermemory.vhd:86:17 */
  assign n4010 = n3918[2]; // extract
  /*# sim_rtl/registermemory.vhd:86:17 */
  assign n4011 = ~n4010;
  /*# sim_rtl/registermemory.vhd:86:17 */
  assign n4012 = n4009 & n4011;
  /*# sim_rtl/registermemory.vhd:86:17 */
  assign n4013 = n4009 & n4010;
  /*# sim_rtl/registermemory.vhd:86:17 */
  assign n4014 = n4008 & n4011;
  /*# sim_rtl/registermemory.vhd:86:17 */
  assign n4015 = n3918[1]; // extract
  /*# sim_rtl/registermemory.vhd:86:17 */
  assign n4016 = ~n4015;
  /*# sim_rtl/registermemory.vhd:86:17 */
  assign n4017 = n4012 & n4016;
  /*# sim_rtl/registermemory.vhd:86:17 */
  assign n4018 = n4012 & n4015;
  /*# sim_rtl/registermemory.vhd:86:17 */
  assign n4019 = n4013 & n4016;
  /*# sim_rtl/registermemory.vhd:86:17 */
  assign n4020 = n4013 & n4015;
  /*# sim_rtl/registermemory.vhd:86:17 */
  assign n4021 = n4014 & n4016;
  /*# sim_rtl/registermemory.vhd:86:17 */
  assign n4022 = n3918[0]; // extract
  /*# sim_rtl/registermemory.vhd:86:17 */
  assign n4023 = ~n4022;
  /*# sim_rtl/registermemory.vhd:86:17 */
  assign n4024 = n4017 & n4023;
  /*# sim_rtl/registermemory.vhd:86:17 */
  assign n4025 = n4017 & n4022;
  /*# sim_rtl/registermemory.vhd:86:17 */
  assign n4026 = n4018 & n4023;
  /*# sim_rtl/registermemory.vhd:86:17 */
  assign n4027 = n4018 & n4022;
  /*# sim_rtl/registermemory.vhd:86:17 */
  assign n4028 = n4019 & n4023;
  /*# sim_rtl/registermemory.vhd:86:17 */
  assign n4029 = n4019 & n4022;
  /*# sim_rtl/registermemory.vhd:86:17 */
  assign n4030 = n4020 & n4023;
  /*# sim_rtl/registermemory.vhd:86:17 */
  assign n4031 = n4020 & n4022;
  /*# sim_rtl/registermemory.vhd:86:17 */
  assign n4032 = n4021 & n4023;
  /*# sim_rtl/registermemory.vhd:86:17 */
  assign n4033 = regs_array[23:0]; // extract
  /*# sim_rtl/registermemory.vhd:86:17 */
  assign n4034 = n4024 ? 24'b000000000000000000000000 : n4033;
  /*# sim_rtl/registermemory.vhd:86:17 */
  assign n4035 = regs_array[47:24]; // extract
  /*# sim_rtl/registermemory.vhd:86:17 */
  assign n4036 = n4025 ? 24'b000000000000000000000000 : n4035;
  /*# sim_rtl/registermemory.vhd:86:17 */
  assign n4037 = regs_array[71:48]; // extract
  /*# sim_rtl/registermemory.vhd:86:17 */
  assign n4038 = n4026 ? 24'b000000000000000000000000 : n4037;
  /*# sim_rtl/registermemory.vhd:86:17 */
  assign n4039 = regs_array[95:72]; // extract
  /*# sim_rtl/registermemory.vhd:86:17 */
  assign n4040 = n4027 ? 24'b000000000000000000000000 : n4039;
  /*# sim_rtl/registermemory.vhd:86:17 */
  assign n4041 = regs_array[119:96]; // extract
  /*# sim_rtl/registermemory.vhd:86:17 */
  assign n4042 = n4028 ? 24'b000000000000000000000000 : n4041;
  /*# sim_rtl/registermemory.vhd:86:17 */
  assign n4043 = regs_array[143:120]; // extract
  /*# sim_rtl/registermemory.vhd:86:17 */
  assign n4044 = n4029 ? 24'b000000000000000000000000 : n4043;
  /*# sim_rtl/registermemory.vhd:86:17 */
  assign n4045 = regs_array[167:144]; // extract
  /*# sim_rtl/registermemory.vhd:86:17 */
  assign n4046 = n4030 ? 24'b000000000000000000000000 : n4045;
  /*# sim_rtl/registermemory.vhd:86:17 */
  assign n4047 = regs_array[191:168]; // extract
  /*# sim_rtl/registermemory.vhd:86:17 */
  assign n4048 = n4031 ? 24'b000000000000000000000000 : n4047;
  /*# sim_rtl/registermemory.vhd:86:17 */
  assign n4049 = regs_array[215:192]; // extract
  /*# sim_rtl/registermemory.vhd:86:17 */
  assign n4050 = n4032 ? 24'b000000000000000000000000 : n4049;
  /*# sim_rtl/registermemory.vhd:86:17 */
  assign n4051 = {n4050, n4048, n4046, n4044, n4042, n4040, n4038, n4036, n4034};
  /*# sim_rtl/registermemory.vhd:90:17 */
  assign n4052 = n3928[3]; // extract
  /*# sim_rtl/registermemory.vhd:90:17 */
  assign n4053 = ~n4052;
  /*# sim_rtl/registermemory.vhd:90:17 */
  assign n4054 = n3928[2]; // extract
  /*# sim_rtl/registermemory.vhd:90:17 */
  assign n4055 = ~n4054;
  /*# sim_rtl/registermemory.vhd:90:17 */
  assign n4056 = n4053 & n4055;
  /*# sim_rtl/registermemory.vhd:90:17 */
  assign n4057 = n4053 & n4054;
  /*# sim_rtl/registermemory.vhd:90:17 */
  assign n4058 = n4052 & n4055;
  /*# sim_rtl/registermemory.vhd:90:17 */
  assign n4059 = n3928[1]; // extract
  /*# sim_rtl/registermemory.vhd:90:17 */
  assign n4060 = ~n4059;
  /*# sim_rtl/registermemory.vhd:90:17 */
  assign n4061 = n4056 & n4060;
  /*# sim_rtl/registermemory.vhd:90:17 */
  assign n4062 = n4056 & n4059;
  /*# sim_rtl/registermemory.vhd:90:17 */
  assign n4063 = n4057 & n4060;
  /*# sim_rtl/registermemory.vhd:90:17 */
  assign n4064 = n4057 & n4059;
  /*# sim_rtl/registermemory.vhd:90:17 */
  assign n4065 = n4058 & n4060;
  /*# sim_rtl/registermemory.vhd:90:17 */
  assign n4066 = n3928[0]; // extract
  /*# sim_rtl/registermemory.vhd:90:17 */
  assign n4067 = ~n4066;
  /*# sim_rtl/registermemory.vhd:90:17 */
  assign n4068 = n4061 & n4067;
  /*# sim_rtl/registermemory.vhd:90:17 */
  assign n4069 = n4061 & n4066;
  /*# sim_rtl/registermemory.vhd:90:17 */
  assign n4070 = n4062 & n4067;
  /*# sim_rtl/registermemory.vhd:90:17 */
  assign n4071 = n4062 & n4066;
  /*# sim_rtl/registermemory.vhd:90:17 */
  assign n4072 = n4063 & n4067;
  /*# sim_rtl/registermemory.vhd:90:17 */
  assign n4073 = n4063 & n4066;
  /*# sim_rtl/registermemory.vhd:90:17 */
  assign n4074 = n4064 & n4067;
  /*# sim_rtl/registermemory.vhd:90:17 */
  assign n4075 = n4064 & n4066;
  /*# sim_rtl/registermemory.vhd:90:17 */
  assign n4076 = n4065 & n4067;
  /*# sim_rtl/registermemory.vhd:90:17 */
  assign n4077 = regs_array[23:0]; // extract
  /*# sim_rtl/registermemory.vhd:90:17 */
  assign n4078 = n4068 ? idata : n4077;
  /*# sim_rtl/registermemory.vhd:90:17 */
  assign n4079 = regs_array[47:24]; // extract
  /*# sim_rtl/registermemory.vhd:90:17 */
  assign n4080 = n4069 ? idata : n4079;
  /*# sim_rtl/registermemory.vhd:90:17 */
  assign n4081 = regs_array[71:48]; // extract
  /*# sim_rtl/registermemory.vhd:90:17 */
  assign n4082 = n4070 ? idata : n4081;
  /*# sim_rtl/registermemory.vhd:90:17 */
  assign n4083 = regs_array[95:72]; // extract
  /*# sim_rtl/registermemory.vhd:90:17 */
  assign n4084 = n4071 ? idata : n4083;
  /*# sim_rtl/registermemory.vhd:90:17 */
  assign n4085 = regs_array[119:96]; // extract
  /*# sim_rtl/registermemory.vhd:90:17 */
  assign n4086 = n4072 ? idata : n4085;
  /*# sim_rtl/registermemory.vhd:90:17 */
  assign n4087 = regs_array[143:120]; // extract
  /*# sim_rtl/registermemory.vhd:90:17 */
  assign n4088 = n4073 ? idata : n4087;
  /*# sim_rtl/registermemory.vhd:90:17 */
  assign n4089 = regs_array[167:144]; // extract
  /*# sim_rtl/registermemory.vhd:90:17 */
  assign n4090 = n4074 ? idata : n4089;
  /*# sim_rtl/registermemory.vhd:90:17 */
  assign n4091 = regs_array[191:168]; // extract
  /*# sim_rtl/registermemory.vhd:90:17 */
  assign n4092 = n4075 ? idata : n4091;
  /*# sim_rtl/registermemory.vhd:90:17 */
  assign n4093 = regs_array[215:192]; // extract
  /*# sim_rtl/registermemory.vhd:90:17 */
  assign n4094 = n4076 ? idata : n4093;
  /*# sim_rtl/registermemory.vhd:90:17 */
  assign n4095 = {n4094, n4092, n4090, n4088, n4086, n4084, n4082, n4080, n4078};
  /*# sim_rtl/registermemory.vhd:95:1 */
  assign n4096 = n3936[3]; // extract
  /*# sim_rtl/registermemory.vhd:95:1 */
  assign n4097 = ~n4096;
  /*# sim_rtl/registermemory.vhd:95:1 */
  assign n4098 = n3936[2]; // extract
  /*# sim_rtl/registermemory.vhd:95:1 */
  assign n4099 = ~n4098;
  /*# sim_rtl/registermemory.vhd:95:1 */
  assign n4100 = n4097 & n4099;
  /*# sim_rtl/registermemory.vhd:95:1 */
  assign n4101 = n4097 & n4098;
  /*# sim_rtl/registermemory.vhd:95:1 */
  assign n4102 = n4096 & n4099;
  /*# sim_rtl/registermemory.vhd:95:1 */
  assign n4103 = n3936[1]; // extract
  /*# sim_rtl/registermemory.vhd:95:1 */
  assign n4104 = ~n4103;
  /*# sim_rtl/registermemory.vhd:95:1 */
  assign n4105 = n4100 & n4104;
  /*# sim_rtl/registermemory.vhd:95:1 */
  assign n4106 = n4100 & n4103;
  /*# sim_rtl/registermemory.vhd:95:1 */
  assign n4107 = n4101 & n4104;
  /*# sim_rtl/registermemory.vhd:95:1 */
  assign n4108 = n4101 & n4103;
  /*# sim_rtl/registermemory.vhd:95:1 */
  assign n4109 = n4102 & n4104;
  /*# sim_rtl/registermemory.vhd:95:1 */
  assign n4110 = n3936[0]; // extract
  /*# sim_rtl/registermemory.vhd:95:1 */
  assign n4111 = ~n4110;
  /*# sim_rtl/registermemory.vhd:95:1 */
  assign n4112 = n4105 & n4111;
  /*# sim_rtl/registermemory.vhd:95:1 */
  assign n4113 = n4105 & n4110;
  /*# sim_rtl/registermemory.vhd:95:1 */
  assign n4114 = n4106 & n4111;
  /*# sim_rtl/registermemory.vhd:95:1 */
  assign n4115 = n4106 & n4110;
  /*# sim_rtl/registermemory.vhd:95:1 */
  assign n4116 = n4107 & n4111;
  /*# sim_rtl/registermemory.vhd:95:1 */
  assign n4117 = n4107 & n4110;
  /*# sim_rtl/registermemory.vhd:95:1 */
  assign n4118 = n4108 & n4111;
  /*# sim_rtl/registermemory.vhd:95:1 */
  assign n4119 = n4108 & n4110;
  /*# sim_rtl/registermemory.vhd:95:1 */
  assign n4120 = n4109 & n4111;
  /*# sim_rtl/registermemory.vhd:95:1 */
  assign n4121 = regs_array[23:0]; // extract
  /*# sim_rtl/registermemory.vhd:95:1 */
  assign n4122 = n4112 ? n3942 : n4121;
  /*# sim_rtl/registermemory.vhd:95:1 */
  assign n4123 = regs_array[47:24]; // extract
  /*# sim_rtl/registermemory.vhd:95:1 */
  assign n4124 = n4113 ? n3942 : n4123;
  /*# sim_rtl/registermemory.vhd:95:1 */
  assign n4125 = regs_array[71:48]; // extract
  /*# sim_rtl/registermemory.vhd:95:1 */
  assign n4126 = n4114 ? n3942 : n4125;
  /*# sim_rtl/registermemory.vhd:95:1 */
  assign n4127 = regs_array[95:72]; // extract
  /*# sim_rtl/registermemory.vhd:95:1 */
  assign n4128 = n4115 ? n3942 : n4127;
  /*# sim_rtl/registermemory.vhd:95:1 */
  assign n4129 = regs_array[119:96]; // extract
  /*# sim_rtl/registermemory.vhd:95:1 */
  assign n4130 = n4116 ? n3942 : n4129;
  /*# sim_rtl/registermemory.vhd:95:1 */
  assign n4131 = regs_array[143:120]; // extract
  /*# sim_rtl/registermemory.vhd:95:1 */
  assign n4132 = n4117 ? n3942 : n4131;
  /*# sim_rtl/registermemory.vhd:95:1 */
  assign n4133 = regs_array[167:144]; // extract
  /*# sim_rtl/registermemory.vhd:95:1 */
  assign n4134 = n4118 ? n3942 : n4133;
  /*# sim_rtl/registermemory.vhd:95:1 */
  assign n4135 = regs_array[191:168]; // extract
  /*# sim_rtl/registermemory.vhd:95:1 */
  assign n4136 = n4119 ? n3942 : n4135;
  /*# sim_rtl/registermemory.vhd:95:1 */
  assign n4137 = regs_array[215:192]; // extract
  /*# sim_rtl/registermemory.vhd:95:1 */
  assign n4138 = n4120 ? n3942 : n4137;
  /*# sim_rtl/registermemory.vhd:95:1 */
  assign n4139 = {n4138, n4136, n4134, n4132, n4130, n4128, n4126, n4124, n4122};
  /*# sim_rtl/registermemory.vhd:97:47 */
  assign n4141 = {168'bX, regs_array};
  /*# sim_rtl/registermemory.vhd:97:47 */
  assign n4142 = n4141[n3948 * 24 +: 24]; //(Bmux)
  /*# sim_rtl/registermemory.vhd:97:88 */
  assign n4144 = {168'bX, regs_array};
  /*# sim_rtl/registermemory.vhd:97:88 */
  assign n4145 = n4144[n3953 * 24 +: 24]; //(Bmux)
endmodule

module temporalmixer_Brtl
  (input  clk,
   input  reset,
   input  clkena,
   input  [4:0] slot,
   input  [1:0] stage,
   input  rhythm,
   output [4:0] maddr,
   input  \mdata[sign] ,
   input  [8:0] \mdata[value] ,
   output [13:0] mixout,
   input  ss_hold,
   input  [7:0] ss_addr,
   input  ss_read,
   input  ss_write,
   input  [31:0] ss_wdata,
   output [31:0] ss_rdata,
   output ss_initialized);
  wire [9:0] n3683;
  wire mute;
  wire [13:0] mix;
  reg [31:0] ss_local_data;
  wire n3691;
  wire n3693;
  wire n3694;
  wire n3696;
  wire n3698;
  wire n3700;
  wire n3702;
  wire n3704;
  wire n3706;
  wire n3708;
  wire n3710;
  wire n3712;
  wire n3714;
  wire n3716;
  wire n3718;
  wire n3720;
  wire n3722;
  wire n3724;
  wire n3726;
  wire n3728;
  wire n3730;
  wire [17:0] n3731;
  reg [4:0] n3741;
  reg n3761;
  wire n3763;
  wire n3765;
  wire n3767;
  wire n3769;
  wire n3771;
  wire n3773;
  wire n3775;
  wire n3777;
  wire n3779;
  wire n3781;
  wire n3783;
  wire n3785;
  wire n3787;
  wire n3789;
  wire n3791;
  wire n3793;
  wire n3795;
  wire n3797;
  wire [17:0] n3798;
  reg [4:0] n3815;
  reg n3835;
  wire [4:0] n3836;
  wire n3837;
  wire n3839;
  wire n3841;
  wire n3842;
  wire n3843;
  wire n3844;
  wire [8:0] n3845;
  wire [13:0] n3846;
  wire [13:0] n3847;
  wire [8:0] n3848;
  wire [13:0] n3849;
  wire [13:0] n3850;
  wire [13:0] n3851;
  wire [13:0] n3852;
  wire [13:0] n3853;
  wire [13:0] n3855;
  wire n3856;
  wire [13:0] n3857;
  wire [13:0] n3859;
  wire [13:0] n3861;
  wire n3862;
  wire n3864;
  wire n3866;
  wire n3867;
  wire n3868;
  wire n3869;
  localparam n3887 = 1'b1;
  wire [4:0] n3888;
  reg [4:0] n3889;
  wire [13:0] n3890;
  reg [13:0] n3891;
  wire n3892;
  reg n3893;
  wire [13:0] n3894;
  reg [13:0] n3895;
  reg [31:0] n3896;
  assign maddr = n3889; //(module output)
  assign mixout = n3891; //(module output)
  assign ss_rdata = ss_local_data; //(module output)
  assign ss_initialized = n3887; //(module output)
  /*# sim_rtl/temporalmixer.vhd:38:8 */
  assign n3683 = {\mdata[value] , \mdata[sign] };
  /*# sim_rtl/temporalmixer.vhd:67:10 */
  assign mute = n3893; // (signal)
  /*# sim_rtl/temporalmixer.vhd:68:10 */
  assign mix = n3895; // (signal)
  /*# sim_rtl/temporalmixer.vhd:70:12 */
  always @*
    ss_local_data = n3896; // (isignal)
  initial
    ss_local_data = 32'b00000000000000000000000000000000;
  /*# sim_rtl/temporalmixer.vhd:92:11 */
  assign n3691 = ~ss_hold;
  /*# sim_rtl/temporalmixer.vhd:95:16 */
  assign n3693 = stage == 2'b00;
  /*# sim_rtl/temporalmixer.vhd:97:19 */
  assign n3694 = ~rhythm;
  /*# sim_rtl/temporalmixer.vhd:100:13 */
  assign n3696 = slot == 5'b00000;
  /*# sim_rtl/temporalmixer.vhd:101:13 */
  assign n3698 = slot == 5'b00001;
  /*# sim_rtl/temporalmixer.vhd:102:13 */
  assign n3700 = slot == 5'b00010;
  /*# sim_rtl/temporalmixer.vhd:103:13 */
  assign n3702 = slot == 5'b00011;
  /*# sim_rtl/temporalmixer.vhd:104:13 */
  assign n3704 = slot == 5'b00100;
  /*# sim_rtl/temporalmixer.vhd:105:13 */
  assign n3706 = slot == 5'b00101;
  /*# sim_rtl/temporalmixer.vhd:106:13 */
  assign n3708 = slot == 5'b00110;
  /*# sim_rtl/temporalmixer.vhd:107:13 */
  assign n3710 = slot == 5'b00111;
  /*# sim_rtl/temporalmixer.vhd:108:13 */
  assign n3712 = slot == 5'b01000;
  /*# sim_rtl/temporalmixer.vhd:109:13 */
  assign n3714 = slot == 5'b01001;
  /*# sim_rtl/temporalmixer.vhd:110:13 */
  assign n3716 = slot == 5'b01010;
  /*# sim_rtl/temporalmixer.vhd:111:13 */
  assign n3718 = slot == 5'b01011;
  /*# sim_rtl/temporalmixer.vhd:112:13 */
  assign n3720 = slot == 5'b01100;
  /*# sim_rtl/temporalmixer.vhd:113:13 */
  assign n3722 = slot == 5'b01101;
  /*# sim_rtl/temporalmixer.vhd:114:13 */
  assign n3724 = slot == 5'b01110;
  /*# sim_rtl/temporalmixer.vhd:115:13 */
  assign n3726 = slot == 5'b01111;
  /*# sim_rtl/temporalmixer.vhd:116:13 */
  assign n3728 = slot == 5'b10000;
  /*# sim_rtl/temporalmixer.vhd:117:13 */
  assign n3730 = slot == 5'b10001;
  /*# sim_rtl/temporalmixer.vhd:99:11 */
  assign n3731 = {n3730, n3728, n3726, n3724, n3722, n3720, n3718, n3716, n3714, n3712, n3710, n3708, n3706, n3704, n3702, n3700, n3698, n3696};
  /*# sim_rtl/temporalmixer.vhd:99:11 */
  always @*
    case (n3731)
      18'b100000000000000000: n3741 = n3889;
      18'b010000000000000000: n3741 = n3889;
      18'b001000000000000000: n3741 = n3889;
      18'b000100000000000000: n3741 = 5'b10001;
      18'b000010000000000000: n3741 = 5'b01111;
      18'b000001000000000000: n3741 = 5'b01101;
      18'b000000100000000000: n3741 = n3889;
      18'b000000010000000000: n3741 = n3889;
      18'b000000001000000000: n3741 = n3889;
      18'b000000000100000000: n3741 = 5'b01011;
      18'b000000000010000000: n3741 = 5'b01001;
      18'b000000000001000000: n3741 = 5'b00111;
      18'b000000000000100000: n3741 = n3889;
      18'b000000000000010000: n3741 = n3889;
      18'b000000000000001000: n3741 = n3889;
      18'b000000000000000100: n3741 = 5'b00101;
      18'b000000000000000010: n3741 = 5'b00011;
      18'b000000000000000001: n3741 = 5'b00001;
      default: n3741 = n3889;
    endcase
  /*# sim_rtl/temporalmixer.vhd:99:11 */
  always @*
    case (n3731)
      18'b100000000000000000: n3761 = 1'b1;
      18'b010000000000000000: n3761 = 1'b1;
      18'b001000000000000000: n3761 = 1'b1;
      18'b000100000000000000: n3761 = 1'b0;
      18'b000010000000000000: n3761 = 1'b0;
      18'b000001000000000000: n3761 = 1'b0;
      18'b000000100000000000: n3761 = 1'b1;
      18'b000000010000000000: n3761 = 1'b1;
      18'b000000001000000000: n3761 = 1'b1;
      18'b000000000100000000: n3761 = 1'b0;
      18'b000000000010000000: n3761 = 1'b0;
      18'b000000000001000000: n3761 = 1'b0;
      18'b000000000000100000: n3761 = 1'b1;
      18'b000000000000010000: n3761 = 1'b1;
      18'b000000000000001000: n3761 = 1'b1;
      18'b000000000000000100: n3761 = 1'b0;
      18'b000000000000000010: n3761 = 1'b0;
      18'b000000000000000001: n3761 = 1'b0;
      default: n3761 = 1'b1;
    endcase
  /*# sim_rtl/temporalmixer.vhd:124:13 */
  assign n3763 = slot == 5'b00000;
  /*# sim_rtl/temporalmixer.vhd:125:13 */
  assign n3765 = slot == 5'b00001;
  /*# sim_rtl/temporalmixer.vhd:126:13 */
  assign n3767 = slot == 5'b00010;
  /*# sim_rtl/temporalmixer.vhd:127:13 */
  assign n3769 = slot == 5'b00011;
  /*# sim_rtl/temporalmixer.vhd:128:13 */
  assign n3771 = slot == 5'b00100;
  /*# sim_rtl/temporalmixer.vhd:129:13 */
  assign n3773 = slot == 5'b00101;
  /*# sim_rtl/temporalmixer.vhd:130:13 */
  assign n3775 = slot == 5'b00110;
  /*# sim_rtl/temporalmixer.vhd:131:13 */
  assign n3777 = slot == 5'b00111;
  /*# sim_rtl/temporalmixer.vhd:132:13 */
  assign n3779 = slot == 5'b01000;
  /*# sim_rtl/temporalmixer.vhd:133:13 */
  assign n3781 = slot == 5'b01001;
  /*# sim_rtl/temporalmixer.vhd:134:13 */
  assign n3783 = slot == 5'b01010;
  /*# sim_rtl/temporalmixer.vhd:135:13 */
  assign n3785 = slot == 5'b01011;
  /*# sim_rtl/temporalmixer.vhd:136:13 */
  assign n3787 = slot == 5'b01100;
  /*# sim_rtl/temporalmixer.vhd:137:13 */
  assign n3789 = slot == 5'b01101;
  /*# sim_rtl/temporalmixer.vhd:138:13 */
  assign n3791 = slot == 5'b01110;
  /*# sim_rtl/temporalmixer.vhd:139:13 */
  assign n3793 = slot == 5'b01111;
  /*# sim_rtl/temporalmixer.vhd:140:13 */
  assign n3795 = slot == 5'b10000;
  /*# sim_rtl/temporalmixer.vhd:141:13 */
  assign n3797 = slot == 5'b10001;
  /*# sim_rtl/temporalmixer.vhd:123:11 */
  assign n3798 = {n3797, n3795, n3793, n3791, n3789, n3787, n3785, n3783, n3781, n3779, n3777, n3775, n3773, n3771, n3769, n3767, n3765, n3763};
  /*# sim_rtl/temporalmixer.vhd:123:11 */
  always @*
    case (n3798)
      18'b100000000000000000: n3815 = n3889;
      18'b010000000000000000: n3815 = 5'b01101;
      18'b001000000000000000: n3815 = 5'b10000;
      18'b000100000000000000: n3815 = 5'b01110;
      18'b000010000000000000: n3815 = 5'b10001;
      18'b000001000000000000: n3815 = 5'b01111;
      18'b000000100000000000: n3815 = 5'b01101;
      18'b000000010000000000: n3815 = 5'b10000;
      18'b000000001000000000: n3815 = 5'b01110;
      18'b000000000100000000: n3815 = 5'b01011;
      18'b000000000010000000: n3815 = 5'b01001;
      18'b000000000001000000: n3815 = 5'b00111;
      18'b000000000000100000: n3815 = n3889;
      18'b000000000000010000: n3815 = 5'b10001;
      18'b000000000000001000: n3815 = 5'b01111;
      18'b000000000000000100: n3815 = 5'b00101;
      18'b000000000000000010: n3815 = 5'b00011;
      18'b000000000000000001: n3815 = 5'b00001;
      default: n3815 = n3889;
    endcase
  /*# sim_rtl/temporalmixer.vhd:123:11 */
  always @*
    case (n3798)
      18'b100000000000000000: n3835 = 1'b1;
      18'b010000000000000000: n3835 = 1'b0;
      18'b001000000000000000: n3835 = 1'b0;
      18'b000100000000000000: n3835 = 1'b0;
      18'b000010000000000000: n3835 = 1'b0;
      18'b000001000000000000: n3835 = 1'b0;
      18'b000000100000000000: n3835 = 1'b0;
      18'b000000010000000000: n3835 = 1'b0;
      18'b000000001000000000: n3835 = 1'b0;
      18'b000000000100000000: n3835 = 1'b0;
      18'b000000000010000000: n3835 = 1'b0;
      18'b000000000001000000: n3835 = 1'b0;
      18'b000000000000100000: n3835 = 1'b1;
      18'b000000000000010000: n3835 = 1'b0;
      18'b000000000000001000: n3835 = 1'b0;
      18'b000000000000000100: n3835 = 1'b0;
      18'b000000000000000010: n3835 = 1'b0;
      18'b000000000000000001: n3835 = 1'b0;
      default: n3835 = 1'b1;
    endcase
  /*# sim_rtl/temporalmixer.vhd:97:9 */
  assign n3836 = n3694 ? n3741 : n3815;
  /*# sim_rtl/temporalmixer.vhd:97:9 */
  assign n3837 = n3694 ? n3761 : n3835;
  /*# sim_rtl/temporalmixer.vhd:148:34 */
  assign n3839 = stage == 2'b10;
  /*# sim_rtl/temporalmixer.vhd:149:41 */
  assign n3841 = slot == 5'b10001;
  /*# sim_rtl/temporalmixer.vhd:153:49 */
  assign n3842 = ~mute;
  /*# sim_rtl/temporalmixer.vhd:154:59 */
  assign n3843 = n3683[0]; // extract
  /*# sim_rtl/temporalmixer.vhd:154:64 */
  assign n3844 = ~n3843;
  /*# sim_rtl/temporalmixer.vhd:155:76 */
  assign n3845 = n3683[9:1]; // extract
  /*# sim_rtl/temporalmixer.vhd:155:68 */
  assign n3846 = {5'b0, n3845};  // uext
  /*# sim_rtl/temporalmixer.vhd:155:68 */
  assign n3847 = mix + n3846;
  /*# sim_rtl/temporalmixer.vhd:157:76 */
  assign n3848 = n3683[9:1]; // extract
  /*# sim_rtl/temporalmixer.vhd:157:68 */
  assign n3849 = {5'b0, n3848};  // uext
  /*# sim_rtl/temporalmixer.vhd:157:68 */
  assign n3850 = mix - n3849;
  /*# sim_rtl/temporalmixer.vhd:154:50 */
  assign n3851 = n3844 ? n3847 : n3850;
  /*# sim_rtl/temporalmixer.vhd:153:41 */
  assign n3852 = n3842 ? n3851 : mix;
  /*# sim_rtl/temporalmixer.vhd:148:25 */
  assign n3853 = n3856 ? mix : n3891;
  /*# sim_rtl/temporalmixer.vhd:149:33 */
  assign n3855 = n3841 ? 14'b00000000000000 : n3852;
  /*# sim_rtl/temporalmixer.vhd:148:25 */
  assign n3856 = n3841 & n3839;
  /*# sim_rtl/temporalmixer.vhd:148:25 */
  assign n3857 = n3839 ? n3855 : mix;
  /*# sim_rtl/temporalmixer.vhd:95:7 */
  assign n3859 = n3693 ? n3891 : n3853;
  /*# sim_rtl/temporalmixer.vhd:95:7 */
  assign n3861 = n3693 ? mix : n3857;
  /*# sim_rtl/temporalmixer.vhd:93:2 */
  assign n3862 = n3693 & clkena;
  /*# sim_rtl/temporalmixer.vhd:93:2 */
  assign n3864 = n3693 & clkena;
  /*# sim_rtl/temporalmixer.vhd:92:1 */
  assign n3866 = n3862 & n3691;
  /*# sim_rtl/temporalmixer.vhd:92:1 */
  assign n3867 = clkena & n3691;
  /*# sim_rtl/temporalmixer.vhd:92:1 */
  assign n3868 = n3864 & n3691;
  /*# sim_rtl/temporalmixer.vhd:92:1 */
  assign n3869 = clkena & n3691;
  /*# sim_rtl/temporalmixer.vhd:88:1 */
  assign n3888 = n3866 ? n3836 : n3889;
  /*# sim_rtl/temporalmixer.vhd:88:1 */
  always @(posedge clk or posedge reset)
    if (reset)
      n3889 <= 5'b00000;
    else
      n3889 <= n3888;
  /*# sim_rtl/temporalmixer.vhd:88:1 */
  assign n3890 = n3867 ? n3859 : n3891;
  /*# sim_rtl/temporalmixer.vhd:88:1 */
  always @(posedge clk or posedge reset)
    if (reset)
      n3891 <= 14'b00000000000000;
    else
      n3891 <= n3890;
  /*# sim_rtl/temporalmixer.vhd:88:1 */
  assign n3892 = n3868 ? n3837 : mute;
  /*# sim_rtl/temporalmixer.vhd:88:1 */
  always @(posedge clk or posedge reset)
    if (reset)
      n3893 <= 1'b1;
    else
      n3893 <= n3892;
  /*# sim_rtl/temporalmixer.vhd:88:1 */
  assign n3894 = n3869 ? n3861 : mix;
  /*# sim_rtl/temporalmixer.vhd:88:1 */
  always @(posedge clk or posedge reset)
    if (reset)
      n3895 <= 14'b00000000000000;
    else
      n3895 <= n3894;
  /*# sim_rtl/temporalmixer.vhd:88:1 */
  always @(posedge clk or posedge reset)
    if (reset)
      n3896 <= 32'b00000000000000000000000000000000;
    else
      n3896 <= 32'b00000000000000000000000000000000;
endmodule

module outputgenerator_Brtl
  (input  clk,
   input  reset,
   input  clkena,
   input  [4:0] slot,
   input  [1:0] stage,
   input  rhythm,
   input  [13:0] opout,
   input  [3:0] faddr,
   output \fdata[sign] ,
   output [8:0] \fdata[value] ,
   input  [4:0] maddr,
   output \mdata[sign] ,
   output [8:0] \mdata[value] ,
   input  ss_hold,
   input  [7:0] ss_addr,
   input  ss_read,
   input  ss_write,
   input  [31:0] ss_wdata,
   output [31:0] ss_rdata,
   output ss_initialized);
  wire n3371;
  wire [8:0] n3372;
  wire n3374;
  wire [8:0] n3375;
  wire fb_wr;
  wire mo_wr;
  wire [3:0] fb_addr;
  wire [4:0] mo_addr;
  wire [9:0] li_data;
  wire [9:0] fb_wdata;
  wire [9:0] mo_wdata;
  wire [9:0] mo_rdata;
  reg [31:0] ss_local_data;
  wire [31:0] ss_fmem_data;
  wire ss_fmem_ready;
  wire [31:0] ss_mmem_data;
  wire ss_mmem_ready;
  wire [9:0] fmem_n3379;
  wire [31:0] fmem_n3380;
  wire fmem_n3381;
  wire \fmem.rdata[sign] ;
  wire [8:0] \fmem.rdata[value] ;
  wire n3382;
  wire [8:0] n3383;
  wire [9:0] n3384;
  wire [9:0] mmem_n3391;
  wire [9:0] mmem_n3392;
  wire [31:0] mmem_n3393;
  wire mmem_n3394;
  wire \mmem.rdata[sign] ;
  wire [8:0] \mmem.rdata[value] ;
  wire \mmem.rdata2[sign] ;
  wire [8:0] \mmem.rdata2[value] ;
  wire n3395;
  wire [8:0] n3396;
  wire [9:0] n3397;
  wire [9:0] n3399;
  wire [9:0] ltbl_n3407;
  wire \ltbl.data[sign] ;
  wire [8:0] \ltbl.data[value] ;
  wire [9:0] n3408;
  wire n3421;
  wire n3422;
  wire n3429;
  wire [8:0] n3430;
  wire [9:0] n3431;
  wire n3437;
  wire [8:0] n3438;
  wire [9:0] n3439;
  wire [31:0] n3440;
  wire n3442;
  reg n3444;
  reg n3446;
  reg [3:0] n3448;
  reg [4:0] n3450;
  reg [9:0] n3452;
  reg [9:0] n3454;
  wire [30:0] n3455;
  wire [30:0] n3457;
  wire [31:0] n3458;
  wire n3459;
  wire n3460;
  wire [3:0] n3461;
  wire [4:0] n3463;
  wire n3470;
  wire [8:0] n3471;
  wire [9:0] n3472;
  wire n3479;
  wire [8:0] n3480;
  wire [9:0] n3481;
  wire n3483;
  reg n3484;
  reg n3485;
  reg [3:0] n3486;
  reg [4:0] n3487;
  reg [9:0] n3488;
  reg [9:0] n3489;
  wire n3496;
  wire n3497;
  wire [3:0] n3498;
  wire [4:0] n3499;
  wire [9:0] n3500;
  wire [9:0] n3501;
  wire n3508;
  wire n3509;
  wire n3510;
  wire n3511;
  wire n3512;
  wire n3513;
  wire [30:0] n3521;
  localparam [31:0] n3522 = 32'b00000000000000000000000000000000;
  wire n3523;
  wire [31:0] n3524;
  wire n3525;
  wire n3527;
  wire n3529;
  wire n3531;
  wire n3533;
  wire n3534;
  wire n3535;
  wire [31:0] n3536;
  wire [31:0] n3538;
  wire [3:0] n3539;
  wire n3547;
  wire n3548;
  wire [8:0] n3549;
  wire [10:0] n3551;
  wire [8:0] n3552;
  wire [10:0] n3554;
  wire [10:0] n3555;
  wire [10:0] n3558;
  wire [10:0] n3559;
  wire n3561;
  wire n3562;
  wire [8:0] n3563;
  wire [10:0] n3565;
  wire [8:0] n3566;
  wire [10:0] n3568;
  wire [10:0] n3569;
  wire [10:0] n3572;
  wire [10:0] n3573;
  wire [10:0] n3575;
  wire n3576;
  wire n3577;
  wire [8:0] n3578;
  wire [9:0] n3580;
  wire [10:0] n3583;
  wire [10:0] n3584;
  wire [8:0] n3585;
  wire [9:0] n3587;
  wire [9:0] n3588;
  wire n3591;
  wire [3:0] n3592;
  wire [9:0] n3593;
  wire n3594;
  wire n3596;
  wire n3597;
  wire n3598;
  wire [9:0] n3599;
  wire n3600;
  wire n3601;
  wire [3:0] n3602;
  wire [9:0] n3603;
  wire [9:0] n3604;
  wire n3605;
  wire n3606;
  wire [3:0] n3607;
  wire [9:0] n3608;
  wire [9:0] n3609;
  wire n3611;
  wire n3613;
  wire [3:0] n3614;
  wire [9:0] n3615;
  wire [9:0] n3616;
  wire n3617;
  wire n3618;
  wire [3:0] n3619;
  wire [4:0] n3620;
  wire [9:0] n3621;
  wire [9:0] n3622;
  wire n3623;
  wire n3624;
  wire n3625;
  wire n3626;
  wire n3627;
  wire n3628;
  wire [31:0] n3662;
  wire [31:0] n3663;
  wire n3665;
  wire n3666;
  reg n3667;
  reg n3668;
  wire n3669;
  wire [3:0] n3670;
  reg [3:0] n3671;
  wire n3672;
  wire [4:0] n3673;
  reg [4:0] n3674;
  wire n3675;
  wire [9:0] n3676;
  reg [9:0] n3677;
  wire n3678;
  wire [9:0] n3679;
  reg [9:0] n3680;
  reg [31:0] n3681;
  assign \fdata[sign]  = n3371; //(module output)
  assign \fdata[value]  = n3372; //(module output)
  assign \mdata[sign]  = n3374; //(module output)
  assign \mdata[value]  = n3375; //(module output)
  assign ss_rdata = n3663; //(module output)
  assign ss_initialized = n3666; //(module output)
  /*# sim_rtl/outputgenerator.vhd:37:8 */
  assign n3371 = fmem_n3379[0]; // extract
  /*# sim_rtl/outputgenerator.vhd:37:8 */
  assign n3372 = fmem_n3379[9:1]; // extract
  /*# sim_rtl/outputgenerator.vhd:37:8 */
  assign n3374 = mmem_n3392[0]; // extract
  /*# sim_rtl/outputgenerator.vhd:37:8 */
  assign n3375 = mmem_n3392[9:1]; // extract
  /*# sim_rtl/outputgenerator.vhd:147:12 */
  assign fb_wr = n3667; // (signal)
  /*# sim_rtl/outputgenerator.vhd:147:19 */
  assign mo_wr = n3668; // (signal)
  /*# sim_rtl/outputgenerator.vhd:148:12 */
  assign fb_addr = n3671; // (signal)
  /*# sim_rtl/outputgenerator.vhd:149:12 */
  assign mo_addr = n3674; // (signal)
  /*# sim_rtl/outputgenerator.vhd:150:12 */
  assign li_data = ltbl_n3407; // (signal)
  /*# sim_rtl/outputgenerator.vhd:150:21 */
  assign fb_wdata = n3677; // (signal)
  /*# sim_rtl/outputgenerator.vhd:150:31 */
  assign mo_wdata = n3680; // (signal)
  /*# sim_rtl/outputgenerator.vhd:150:41 */
  assign mo_rdata = mmem_n3391; // (signal)
  /*# sim_rtl/outputgenerator.vhd:151:12 */
  always @*
    ss_local_data = n3681; // (isignal)
  initial
    ss_local_data = 32'b00000000000000000000000000000000;
  /*# sim_rtl/outputgenerator.vhd:152:12 */
  assign ss_fmem_data = fmem_n3380; // (signal)
  /*# sim_rtl/outputgenerator.vhd:153:12 */
  assign ss_fmem_ready = fmem_n3381; // (signal)
  /*# sim_rtl/outputgenerator.vhd:154:12 */
  assign ss_mmem_data = mmem_n3393; // (signal)
  /*# sim_rtl/outputgenerator.vhd:155:12 */
  assign ss_mmem_ready = mmem_n3394; // (signal)
  /*# sim_rtl/outputgenerator.vhd:166:20 */
  assign fmem_n3379 = n3384; // (signal)
  /*# sim_rtl/outputgenerator.vhd:159:5 */
  feedbackmemory_Brtl fmem (
    .clk(clk),
    .reset(reset),
    .wr(fb_wr),
    .waddr(fb_addr),
    .\wdata[sign] (n3382),
    .\wdata[value] (n3383),
    .raddr(faddr),
    .ss_hold(ss_hold),
    .ss_addr(ss_addr),
    .ss_read(ss_read),
    .ss_write(ss_write),
    .ss_wdata(ss_wdata),
    .\rdata[sign] (\fmem.rdata[sign] ),
    .\rdata[value] (\fmem.rdata[value] ),
    .ss_rdata(fmem_n3380),
    .ss_initialized(fmem_n3381));
  /*# sim_rtl/outputgenerator.vhd:159:5 */
  assign n3382 = fb_wdata[0]; // extract
  /*# sim_rtl/outputgenerator.vhd:159:5 */
  assign n3383 = fb_wdata[9:1]; // extract
  /*# sim_rtl/outputgenerator.vhd:159:5 */
  assign n3384 = {\fmem.rdata[value] , \fmem.rdata[sign] };
  /*# sim_rtl/outputgenerator.vhd:176:20 */
  assign mmem_n3391 = n3397; // (signal)
  /*# sim_rtl/outputgenerator.vhd:178:20 */
  assign mmem_n3392 = n3399; // (signal)
  /*# sim_rtl/outputgenerator.vhd:170:5 */
  outputmemory_Brtl mmem (
    .clk(clk),
    .reset(reset),
    .wr(mo_wr),
    .addr(mo_addr),
    .\wdata[sign] (n3395),
    .\wdata[value] (n3396),
    .addr2(maddr),
    .ss_hold(ss_hold),
    .ss_addr(ss_addr),
    .ss_read(ss_read),
    .ss_write(ss_write),
    .ss_wdata(ss_wdata),
    .\rdata[sign] (\mmem.rdata[sign] ),
    .\rdata[value] (\mmem.rdata[value] ),
    .\rdata2[sign] (\mmem.rdata2[sign] ),
    .\rdata2[value] (\mmem.rdata2[value] ),
    .ss_rdata(mmem_n3393),
    .ss_initialized(mmem_n3394));
  /*# sim_rtl/outputgenerator.vhd:170:5 */
  assign n3395 = mo_wdata[0]; // extract
  /*# sim_rtl/outputgenerator.vhd:170:5 */
  assign n3396 = mo_wdata[9:1]; // extract
  /*# sim_rtl/outputgenerator.vhd:170:5 */
  assign n3397 = {\mmem.rdata[value] , \mmem.rdata[sign] };
  /*# sim_rtl/outputgenerator.vhd:170:5 */
  assign n3399 = {\mmem.rdata2[value] , \mmem.rdata2[sign] };
  /*# sim_rtl/outputgenerator.vhd:186:20 */
  assign ltbl_n3407 = n3408; // (signal)
  /*# sim_rtl/outputgenerator.vhd:182:5 */
  lineartable_Brtl ltbl (
    .clk(clk),
    .reset(reset),
    .addr(opout),
    .\data[sign] (\ltbl.data[sign] ),
    .\data[value] (\ltbl.data[value] ));
  /*# sim_rtl/outputgenerator.vhd:182:5 */
  assign n3408 = {\ltbl.data[value] , \ltbl.data[sign] };
  /*# sim_rtl/outputgenerator.vhd:209:33 */
  assign n3421 = ss_read | ss_write;
  /*# sim_rtl/outputgenerator.vhd:209:16 */
  assign n3422 = n3421 & ss_hold;
  /*# sim_rtl/vm2413.vhd:195:15 */
  assign n3429 = fb_wdata[0]; // extract
  /*# sim_rtl/vm2413.vhd:195:25 */
  assign n3430 = fb_wdata[9:1]; // extract
  /*# sim_rtl/vm2413.vhd:195:20 */
  assign n3431 = {n3429, n3430};
  /*# sim_rtl/vm2413.vhd:195:15 */
  assign n3437 = mo_wdata[0]; // extract
  /*# sim_rtl/vm2413.vhd:195:25 */
  assign n3438 = mo_wdata[9:1]; // extract
  /*# sim_rtl/vm2413.vhd:195:20 */
  assign n3439 = {n3437, n3438};
  /*# sim_rtl/outputgenerator.vhd:218:6 */
  assign n3440 = {24'b0, ss_addr};  // uext
  /*# sim_rtl/outputgenerator.vhd:219:1 */
  assign n3442 = n3440 == 32'b00000000000000000000000001001111;
  /*# sim_rtl/outputgenerator.vhd:218:1 */
  always @*
    case (n3442)
      1'b1: n3444 = fb_wr;
      default: n3444 = 1'b0;
    endcase
  /*# sim_rtl/outputgenerator.vhd:218:1 */
  always @*
    case (n3442)
      1'b1: n3446 = mo_wr;
      default: n3446 = 1'b0;
    endcase
  /*# sim_rtl/outputgenerator.vhd:218:1 */
  always @*
    case (n3442)
      1'b1: n3448 = fb_addr;
      default: n3448 = 4'b0000;
    endcase
  /*# sim_rtl/outputgenerator.vhd:218:1 */
  always @*
    case (n3442)
      1'b1: n3450 = mo_addr;
      default: n3450 = 5'b00000;
    endcase
  /*# sim_rtl/outputgenerator.vhd:218:1 */
  always @*
    case (n3442)
      1'b1: n3452 = n3431;
      default: n3452 = 10'b0000000000;
    endcase
  /*# sim_rtl/outputgenerator.vhd:218:1 */
  always @*
    case (n3442)
      1'b1: n3454 = n3439;
      default: n3454 = 10'b0000000000;
    endcase
  /*# sim_rtl/outputgenerator.vhd:217:1 */
  assign n3455 = {n3454, n3452, n3450, n3448, n3446, n3444};
  /*# sim_rtl/outputgenerator.vhd:217:1 */
  assign n3457 = ss_read ? n3455 : 31'b0000000000000000000000000000000;
  /*# sim_rtl/outputgenerator.vhd:229:6 */
  assign n3458 = {24'b0, ss_addr};  // uext
  /*# sim_rtl/outputgenerator.vhd:231:26 */
  assign n3459 = ss_wdata[0]; // extract
  /*# sim_rtl/outputgenerator.vhd:233:26 */
  assign n3460 = ss_wdata[1]; // extract
  /*# sim_rtl/outputgenerator.vhd:235:37 */
  assign n3461 = ss_wdata[5:2]; // extract
  /*# sim_rtl/outputgenerator.vhd:237:37 */
  assign n3463 = ss_wdata[10:6]; // extract
  /*# sim_rtl/vm2413.vhd:200:25 */
  assign n3470 = ss_wdata[20]; // extract
  /*# sim_rtl/vm2413.vhd:200:47 */
  assign n3471 = ss_wdata[19:11]; // extract
  /*# sim_rtl/vm2413.vhd:200:12 */
  assign n3472 = {n3471, n3470};
  /*# sim_rtl/vm2413.vhd:200:25 */
  assign n3479 = ss_wdata[30]; // extract
  /*# sim_rtl/vm2413.vhd:200:47 */
  assign n3480 = ss_wdata[29:21]; // extract
  /*# sim_rtl/vm2413.vhd:200:12 */
  assign n3481 = {n3480, n3479};
  /*# sim_rtl/outputgenerator.vhd:230:1 */
  assign n3483 = n3458 == 32'b00000000000000000000000001001111;
  /*# sim_rtl/outputgenerator.vhd:229:1 */
  always @*
    case (n3483)
      1'b1: n3484 = n3459;
      default: n3484 = fb_wr;
    endcase
  /*# sim_rtl/outputgenerator.vhd:229:1 */
  always @*
    case (n3483)
      1'b1: n3485 = n3460;
      default: n3485 = mo_wr;
    endcase
  /*# sim_rtl/outputgenerator.vhd:229:1 */
  always @*
    case (n3483)
      1'b1: n3486 = n3461;
      default: n3486 = fb_addr;
    endcase
  /*# sim_rtl/outputgenerator.vhd:229:1 */
  always @*
    case (n3483)
      1'b1: n3487 = n3463;
      default: n3487 = mo_addr;
    endcase
  /*# sim_rtl/outputgenerator.vhd:229:1 */
  always @*
    case (n3483)
      1'b1: n3488 = n3472;
      default: n3488 = fb_wdata;
    endcase
  /*# sim_rtl/outputgenerator.vhd:229:1 */
  always @*
    case (n3483)
      1'b1: n3489 = n3481;
      default: n3489 = mo_wdata;
    endcase
  /*# sim_rtl/outputgenerator.vhd:209:1 */
  assign n3496 = n3508 ? n3484 : fb_wr;
  /*# sim_rtl/outputgenerator.vhd:209:1 */
  assign n3497 = n3509 ? n3485 : mo_wr;
  /*# sim_rtl/outputgenerator.vhd:209:1 */
  assign n3498 = n3510 ? n3486 : fb_addr;
  /*# sim_rtl/outputgenerator.vhd:209:1 */
  assign n3499 = n3511 ? n3487 : mo_addr;
  /*# sim_rtl/outputgenerator.vhd:209:1 */
  assign n3500 = n3512 ? n3488 : fb_wdata;
  /*# sim_rtl/outputgenerator.vhd:209:1 */
  assign n3501 = n3513 ? n3489 : mo_wdata;
  /*# sim_rtl/outputgenerator.vhd:209:1 */
  assign n3508 = ss_write & n3422;
  /*# sim_rtl/outputgenerator.vhd:209:1 */
  assign n3509 = ss_write & n3422;
  /*# sim_rtl/outputgenerator.vhd:209:1 */
  assign n3510 = ss_write & n3422;
  /*# sim_rtl/outputgenerator.vhd:209:1 */
  assign n3511 = ss_write & n3422;
  /*# sim_rtl/outputgenerator.vhd:209:1 */
  assign n3512 = ss_write & n3422;
  /*# sim_rtl/outputgenerator.vhd:209:1 */
  assign n3513 = ss_write & n3422;
  /*# sim_rtl/outputgenerator.vhd:209:1 */
  assign n3521 = n3422 ? n3457 : 31'b0000000000000000000000000000000;
  /*# sim_rtl/outputgenerator.vhd:198:10 */
  assign n3523 = n3522[31]; // extract
  /*# sim_rtl/outputgenerator.vhd:198:10 */
  assign n3524 = {n3523, n3521};
  /*# sim_rtl/outputgenerator.vhd:248:11 */
  assign n3525 = ~ss_hold;
  /*# sim_rtl/outputgenerator.vhd:253:27 */
  assign n3527 = stage == 2'b00;
  /*# sim_rtl/outputgenerator.vhd:257:30 */
  assign n3529 = stage == 2'b01;
  /*# sim_rtl/outputgenerator.vhd:259:30 */
  assign n3531 = stage == 2'b10;
  /*# sim_rtl/outputgenerator.vhd:261:30 */
  assign n3533 = stage == 2'b11;
  /*# sim_rtl/outputgenerator.vhd:263:29 */
  assign n3534 = slot[0]; // extract
  /*# sim_rtl/outputgenerator.vhd:263:33 */
  assign n3535 = ~n3534;
  /*# sim_rtl/outputgenerator.vhd:265:36 */
  assign n3536 = {27'b0, slot};  // uext
  /*# sim_rtl/outputgenerator.vhd:265:54 */
  assign n3538 = $signed(n3536) / $signed(32'b00000000000000000000000000000010); // sdiv
  /*# sim_rtl/outputgenerator.vhd:265:36 */
  assign n3539 = n3538[3:0];  // trunc
  /*# sim_rtl/outputgenerator.vhd:124:15 */
  assign n3547 = mo_rdata[0]; // extract
  /*# sim_rtl/outputgenerator.vhd:124:20 */
  assign n3548 = ~n3547;
  /*# sim_rtl/outputgenerator.vhd:125:28 */
  assign n3549 = mo_rdata[9:1]; // extract
  /*# sim_rtl/outputgenerator.vhd:125:24 */
  assign n3551 = {2'b00, n3549};
  /*# sim_rtl/outputgenerator.vhd:127:34 */
  assign n3552 = mo_rdata[9:1]; // extract
  /*# sim_rtl/outputgenerator.vhd:127:30 */
  assign n3554 = {2'b00, n3552};
  /*# sim_rtl/outputgenerator.vhd:127:19 */
  assign n3555 = ~n3554;
  /*# sim_rtl/outputgenerator.vhd:127:42 */
  assign n3558 = n3555 + 11'b00000000001;
  /*# sim_rtl/outputgenerator.vhd:124:9 */
  assign n3559 = n3548 ? n3551 : n3558;
  /*# sim_rtl/outputgenerator.vhd:129:15 */
  assign n3561 = li_data[0]; // extract
  /*# sim_rtl/outputgenerator.vhd:129:20 */
  assign n3562 = ~n3561;
  /*# sim_rtl/outputgenerator.vhd:130:28 */
  assign n3563 = li_data[9:1]; // extract
  /*# sim_rtl/outputgenerator.vhd:130:24 */
  assign n3565 = {2'b00, n3563};
  /*# sim_rtl/outputgenerator.vhd:132:34 */
  assign n3566 = li_data[9:1]; // extract
  /*# sim_rtl/outputgenerator.vhd:132:30 */
  assign n3568 = {2'b00, n3566};
  /*# sim_rtl/outputgenerator.vhd:132:19 */
  assign n3569 = ~n3568;
  /*# sim_rtl/outputgenerator.vhd:132:42 */
  assign n3572 = n3569 + 11'b00000000001;
  /*# sim_rtl/outputgenerator.vhd:129:9 */
  assign n3573 = n3562 ? n3565 : n3572;
  /*# sim_rtl/outputgenerator.vhd:135:18 */
  assign n3575 = n3559 + n3573;
  /*# sim_rtl/outputgenerator.vhd:138:14 */
  assign n3576 = n3575[10]; // extract
  /*# sim_rtl/outputgenerator.vhd:138:24 */
  assign n3577 = ~n3576;
  /*# sim_rtl/outputgenerator.vhd:139:46 */
  assign n3578 = n3575[9:1]; // extract
  /*# sim_rtl/outputgenerator.vhd:139:20 */
  assign n3580 = {n3578, 1'b0};
  /*# sim_rtl/outputgenerator.vhd:141:28 */
  assign n3583 = n3575 - 11'b00000000001;
  /*# sim_rtl/outputgenerator.vhd:141:19 */
  assign n3584 = ~n3583;
  /*# sim_rtl/outputgenerator.vhd:142:46 */
  assign n3585 = n3584[9:1]; // extract
  /*# sim_rtl/outputgenerator.vhd:142:20 */
  assign n3587 = {n3585, 1'b1};
  /*# sim_rtl/outputgenerator.vhd:138:9 */
  assign n3588 = n3577 ? n3580 : n3587;
  /*# sim_rtl/outputgenerator.vhd:261:17 */
  assign n3591 = n3594 ? 1'b1 : n3496;
  /*# sim_rtl/outputgenerator.vhd:261:17 */
  assign n3592 = n3597 ? n3539 : n3498;
  /*# sim_rtl/outputgenerator.vhd:261:17 */
  assign n3593 = n3598 ? n3588 : n3500;
  /*# sim_rtl/outputgenerator.vhd:261:17 */
  assign n3594 = n3535 & n3533;
  /*# sim_rtl/outputgenerator.vhd:261:17 */
  assign n3596 = n3533 ? 1'b1 : n3497;
  /*# sim_rtl/outputgenerator.vhd:261:17 */
  assign n3597 = n3535 & n3533;
  /*# sim_rtl/outputgenerator.vhd:261:17 */
  assign n3598 = n3535 & n3533;
  /*# sim_rtl/outputgenerator.vhd:261:17 */
  assign n3599 = n3533 ? li_data : n3501;
  /*# sim_rtl/outputgenerator.vhd:259:17 */
  assign n3600 = n3531 ? n3496 : n3591;
  /*# sim_rtl/outputgenerator.vhd:259:17 */
  assign n3601 = n3531 ? n3497 : n3596;
  /*# sim_rtl/outputgenerator.vhd:259:17 */
  assign n3602 = n3531 ? n3498 : n3592;
  /*# sim_rtl/outputgenerator.vhd:259:17 */
  assign n3603 = n3531 ? n3500 : n3593;
  /*# sim_rtl/outputgenerator.vhd:259:17 */
  assign n3604 = n3531 ? n3501 : n3599;
  /*# sim_rtl/outputgenerator.vhd:257:17 */
  assign n3605 = n3529 ? n3496 : n3600;
  /*# sim_rtl/outputgenerator.vhd:257:17 */
  assign n3606 = n3529 ? n3497 : n3601;
  /*# sim_rtl/outputgenerator.vhd:257:17 */
  assign n3607 = n3529 ? n3498 : n3602;
  /*# sim_rtl/outputgenerator.vhd:257:17 */
  assign n3608 = n3529 ? n3500 : n3603;
  /*# sim_rtl/outputgenerator.vhd:257:17 */
  assign n3609 = n3529 ? n3501 : n3604;
  /*# sim_rtl/outputgenerator.vhd:253:17 */
  assign n3611 = n3527 ? 1'b0 : n3605;
  /*# sim_rtl/outputgenerator.vhd:253:17 */
  assign n3613 = n3527 ? 1'b0 : n3606;
  /*# sim_rtl/outputgenerator.vhd:253:17 */
  assign n3614 = n3527 ? n3498 : n3607;
  /*# sim_rtl/outputgenerator.vhd:253:17 */
  assign n3615 = n3527 ? n3500 : n3608;
  /*# sim_rtl/outputgenerator.vhd:253:17 */
  assign n3616 = n3527 ? n3501 : n3609;
  /*# sim_rtl/outputgenerator.vhd:248:1 */
  assign n3617 = n3623 ? n3611 : n3496;
  /*# sim_rtl/outputgenerator.vhd:248:1 */
  assign n3618 = n3624 ? n3613 : n3497;
  /*# sim_rtl/outputgenerator.vhd:248:1 */
  assign n3619 = n3625 ? n3614 : n3498;
  /*# sim_rtl/outputgenerator.vhd:248:1 */
  assign n3620 = n3626 ? slot : n3499;
  /*# sim_rtl/outputgenerator.vhd:248:1 */
  assign n3621 = n3627 ? n3615 : n3500;
  /*# sim_rtl/outputgenerator.vhd:248:1 */
  assign n3622 = n3628 ? n3616 : n3501;
  /*# sim_rtl/outputgenerator.vhd:248:1 */
  assign n3623 = clkena & n3525;
  /*# sim_rtl/outputgenerator.vhd:248:1 */
  assign n3624 = clkena & n3525;
  /*# sim_rtl/outputgenerator.vhd:248:1 */
  assign n3625 = clkena & n3525;
  /*# sim_rtl/outputgenerator.vhd:248:1 */
  assign n3626 = clkena & n3525;
  /*# sim_rtl/outputgenerator.vhd:248:1 */
  assign n3627 = clkena & n3525;
  /*# sim_rtl/outputgenerator.vhd:248:1 */
  assign n3628 = clkena & n3525;
  /*# sim_rtl/outputgenerator.vhd:281:27 */
  assign n3662 = ss_local_data | ss_fmem_data;
  /*# sim_rtl/outputgenerator.vhd:281:43 */
  assign n3663 = n3662 | ss_mmem_data;
  /*# sim_rtl/outputgenerator.vhd:282:23 */
  assign n3665 = 1'b1 & ss_fmem_ready;
  /*# sim_rtl/outputgenerator.vhd:282:41 */
  assign n3666 = n3665 & ss_mmem_ready;
  /*# sim_rtl/outputgenerator.vhd:206:1 */
  always @(posedge clk or posedge reset)
    if (reset)
      n3667 <= 1'b0;
    else
      n3667 <= n3617;
  /*# sim_rtl/outputgenerator.vhd:206:1 */
  always @(posedge clk or posedge reset)
    if (reset)
      n3668 <= 1'b0;
    else
      n3668 <= n3618;
  /*# sim_rtl/outputgenerator.vhd:148:12 */
  assign n3669 = ~reset;
  /*# sim_rtl/outputgenerator.vhd:206:1 */
  assign n3670 = n3669 ? n3619 : fb_addr;
  /*# sim_rtl/outputgenerator.vhd:206:1 */
  always @(posedge clk)
    n3671 <= n3670;
  /*# sim_rtl/outputgenerator.vhd:149:12 */
  assign n3672 = ~reset;
  /*# sim_rtl/outputgenerator.vhd:206:1 */
  assign n3673 = n3672 ? n3620 : mo_addr;
  /*# sim_rtl/outputgenerator.vhd:206:1 */
  always @(posedge clk)
    n3674 <= n3673;
  /*# sim_rtl/outputgenerator.vhd:150:21 */
  assign n3675 = ~reset;
  /*# sim_rtl/outputgenerator.vhd:206:1 */
  assign n3676 = n3675 ? n3621 : fb_wdata;
  /*# sim_rtl/outputgenerator.vhd:206:1 */
  always @(posedge clk)
    n3677 <= n3676;
  /*# sim_rtl/outputgenerator.vhd:150:31 */
  assign n3678 = ~reset;
  /*# sim_rtl/outputgenerator.vhd:206:1 */
  assign n3679 = n3678 ? n3622 : mo_wdata;
  /*# sim_rtl/outputgenerator.vhd:206:1 */
  always @(posedge clk)
    n3680 <= n3679;
  /*# sim_rtl/outputgenerator.vhd:206:1 */
  always @(posedge clk or posedge reset)
    if (reset)
      n3681 <= 32'b00000000000000000000000000000000;
    else
      n3681 <= n3524;
endmodule

module operator_Brtl
  (input  clk,
   input  reset,
   input  clkena,
   input  [4:0] slot,
   input  [1:0] stage,
   input  rhythm,
   input  wf,
   input  [2:0] fb,
   input  noise,
   input  [17:0] pgout,
   input  [12:0] egout,
   output [3:0] faddr,
   input  \fdata[sign] ,
   input  [8:0] \fdata[value] ,
   output [13:0] opout,
   input  ss_hold,
   input  [7:0] ss_addr,
   input  ss_read,
   input  ss_write,
   input  [31:0] ss_wdata,
   output [31:0] ss_rdata,
   output ss_initialized);
  wire [9:0] n3129;
  wire [17:0] addr;
  wire [13:0] data;
  wire w_is_carrier;
  wire [19:0] w_modula_m;
  wire [19:0] w_modula_c;
  wire [19:0] w_modula;
  wire [12:0] ff_egout;
  reg [31:0] ss_local_data;
  wire [31:0] ss_u_sine_table_data;
  wire ss_u_sine_table_ready;
  wire [13:0] u_sine_table_n3134;
  wire [31:0] u_sine_table_n3135;
  wire u_sine_table_n3136;
  wire n3143;
  wire n3146;
  wire [19:0] n3147;
  wire [8:0] n3148;
  wire [9:0] n3150;
  wire [10:0] n3152;
  wire [19:0] n3154;
  wire [2:0] n3156;
  wire [19:0] n3157;
  wire [8:0] n3158;
  wire [10:0] n3160;
  wire [19:0] n3162;
  wire [19:0] n3163;
  wire n3173;
  wire n3174;
  wire [31:0] n3176;
  wire n3178;
  wire n3180;
  wire [1:0] n3181;
  wire [3:0] n3182;
  reg [3:0] n3184;
  wire [13:0] n3185;
  reg [13:0] n3187;
  reg [12:0] n3189;
  wire [30:0] n3190;
  wire [30:0] n3192;
  wire [31:0] n3193;
  wire [17:0] n3194;
  wire [12:0] n3195;
  wire n3197;
  wire [3:0] n3198;
  wire [13:0] n3200;
  wire n3202;
  wire [1:0] n3203;
  reg [3:0] n3204;
  reg [13:0] n3205;
  reg [17:0] n3206;
  reg [12:0] n3207;
  wire [3:0] n3212;
  wire [13:0] n3213;
  wire [17:0] n3214;
  wire [12:0] n3215;
  wire n3220;
  wire n3221;
  wire n3222;
  wire n3223;
  wire [30:0] n3229;
  localparam [31:0] n3230 = 32'b00000000000000000000000000000000;
  wire n3231;
  wire [31:0] n3232;
  wire n3233;
  wire n3235;
  wire n3237;
  wire n3239;
  wire n3240;
  wire n3241;
  wire n3242;
  wire [8:0] n3244;
  wire [17:0] n3246;
  wire n3248;
  wire n3249;
  wire n3250;
  wire n3251;
  wire [8:0] n3253;
  wire [17:0] n3255;
  wire n3257;
  wire n3258;
  wire n3259;
  wire n3260;
  wire [17:0] n3261;
  wire [17:0] n3262;
  wire [17:0] n3263;
  wire [17:0] n3264;
  wire [17:0] n3265;
  wire [17:0] n3266;
  wire [17:0] n3267;
  wire [17:0] n3268;
  wire n3270;
  wire n3272;
  wire n3273;
  wire [31:0] n3274;
  wire [31:0] n3276;
  wire n3278;
  wire [31:0] n3279;
  wire [31:0] n3281;
  wire [31:0] n3283;
  wire [3:0] n3284;
  wire [3:0] n3286;
  wire [3:0] n3287;
  wire n3289;
  wire [13:0] n3291;
  wire [12:0] n3292;
  wire [13:0] n3294;
  wire [13:0] n3295;
  wire n3297;
  wire n3298;
  wire [12:0] n3299;
  wire [12:0] n3300;
  wire [13:0] n3301;
  wire n3302;
  wire [13:0] n3304;
  wire [13:0] n3305;
  wire [13:0] n3306;
  wire n3308;
  wire [13:0] n3309;
  wire [12:0] n3310;
  wire [3:0] n3312;
  wire [13:0] n3313;
  wire [12:0] n3314;
  wire [3:0] n3316;
  wire [13:0] n3317;
  wire [17:0] n3318;
  wire [12:0] n3319;
  wire [3:0] n3321;
  wire [13:0] n3322;
  wire n3323;
  wire [12:0] n3324;
  wire n3326;
  wire n3327;
  wire n3328;
  wire n3329;
  wire [31:0] n3358;
  wire n3360;
  wire n3361;
  wire [3:0] n3362;
  reg [3:0] n3363;
  reg [13:0] n3364;
  wire n3365;
  wire [17:0] n3366;
  reg [17:0] n3367;
  reg [12:0] n3368;
  reg [31:0] n3369;
  assign faddr = n3363; //(module output)
  assign opout = n3364; //(module output)
  assign ss_rdata = n3358; //(module output)
  assign ss_initialized = n3360; //(module output)
  /*# sim_rtl/operator.vhd:42:8 */
  assign n3129 = {\fdata[value] , \fdata[sign] };
  /*# sim_rtl/operator.vhd:96:12 */
  assign addr = n3367; // (signal)
  /*# sim_rtl/operator.vhd:97:12 */
  assign data = u_sine_table_n3134; // (signal)
  /*# sim_rtl/operator.vhd:98:12 */
  assign w_is_carrier = n3143; // (signal)
  /*# sim_rtl/operator.vhd:99:12 */
  assign w_modula_m = n3147; // (signal)
  /*# sim_rtl/operator.vhd:100:12 */
  assign w_modula_c = n3162; // (signal)
  /*# sim_rtl/operator.vhd:101:12 */
  assign w_modula = n3163; // (signal)
  /*# sim_rtl/operator.vhd:102:12 */
  assign ff_egout = n3368; // (signal)
  /*# sim_rtl/operator.vhd:103:12 */
  always @*
    ss_local_data = n3369; // (isignal)
  initial
    ss_local_data = 32'b00000000000000000000000000000000;
  /*# sim_rtl/operator.vhd:104:12 */
  assign ss_u_sine_table_data = u_sine_table_n3135; // (signal)
  /*# sim_rtl/operator.vhd:105:12 */
  assign ss_u_sine_table_ready = u_sine_table_n3136; // (signal)
  /*# sim_rtl/operator.vhd:117:5 */
  sinetable_Brtl u_sine_table (
    .clk(clk),
    .clkena(clkena),
    .wf(wf),
    .addr(addr),
    .ss_hold(ss_hold),
    .ss_addr(ss_addr),
    .ss_read(ss_read),
    .ss_write(ss_write),
    .ss_wdata(ss_wdata),
    .data(u_sine_table_n3134),
    .ss_rdata(u_sine_table_n3135),
    .ss_initialized(u_sine_table_n3136));
  /*# sim_rtl/operator.vhd:127:29 */
  assign n3143 = slot[0]; // extract
  /*# sim_rtl/operator.vhd:128:50 */
  assign n3146 = fb == 3'b000;
  /*# sim_rtl/operator.vhd:128:41 */
  assign n3147 = n3146 ? 20'b00000000000000000000 : n3157;
  /*# sim_rtl/operator.vhd:129:42 */
  assign n3148 = n3129[9:1]; // extract
  /*# sim_rtl/operator.vhd:129:34 */
  assign n3150 = {1'b0, n3148};
  /*# sim_rtl/operator.vhd:129:48 */
  assign n3152 = {n3150, 1'b0};
  /*# sim_rtl/operator.vhd:129:54 */
  assign n3154 = {n3152, 9'b000000000};
  /*# sim_rtl/operator.vhd:129:75 */
  assign n3156 = 3'b111 ^ fb;
  /*# sim_rtl/operator.vhd:129:25 */
  assign n3157 = n3154 >> n3156;
  /*# sim_rtl/operator.vhd:130:31 */
  assign n3158 = n3129[9:1]; // extract
  /*# sim_rtl/operator.vhd:130:37 */
  assign n3160 = {n3158, 2'b00};
  /*# sim_rtl/operator.vhd:130:44 */
  assign n3162 = {n3160, 9'b000000000};
  /*# sim_rtl/operator.vhd:131:37 */
  assign n3163 = w_is_carrier ? w_modula_c : w_modula_m;
  /*# sim_rtl/operator.vhd:153:33 */
  assign n3173 = ss_read | ss_write;
  /*# sim_rtl/operator.vhd:153:16 */
  assign n3174 = n3173 & ss_hold;
  /*# sim_rtl/operator.vhd:160:6 */
  assign n3176 = {24'b0, ss_addr};  // uext
  /*# sim_rtl/operator.vhd:161:1 */
  assign n3178 = n3176 == 32'b00000000000000000000000001100000;
  /*# sim_rtl/operator.vhd:164:1 */
  assign n3180 = n3176 == 32'b00000000000000000000000001100001;
  /*# sim_rtl/operator.vhd:160:1 */
  assign n3181 = {n3180, n3178};
  /*# sim_rtl/operator.vhd:96:12 */
  assign n3182 = addr[3:0]; // extract
  /*# sim_rtl/operator.vhd:160:1 */
  always @*
    case (n3181)
      2'b10: n3184 = n3363;
      2'b01: n3184 = n3182;
      default: n3184 = 4'b0000;
    endcase
  /*# sim_rtl/operator.vhd:96:12 */
  assign n3185 = addr[17:4]; // extract
  /*# sim_rtl/operator.vhd:160:1 */
  always @*
    case (n3181)
      2'b10: n3187 = n3364;
      2'b01: n3187 = n3185;
      default: n3187 = 14'b00000000000000;
    endcase
  /*# sim_rtl/operator.vhd:160:1 */
  always @*
    case (n3181)
      2'b10: n3189 = 13'b0000000000000;
      2'b01: n3189 = ff_egout;
      default: n3189 = 13'b0000000000000;
    endcase
  /*# sim_rtl/operator.vhd:159:1 */
  assign n3190 = {n3189, n3187, n3184};
  /*# sim_rtl/operator.vhd:159:1 */
  assign n3192 = ss_read ? n3190 : 31'b0000000000000000000000000000000;
  /*# sim_rtl/operator.vhd:170:6 */
  assign n3193 = {24'b0, ss_addr};  // uext
  /*# sim_rtl/operator.vhd:172:35 */
  assign n3194 = ss_wdata[17:0]; // extract
  /*# sim_rtl/operator.vhd:174:39 */
  assign n3195 = ss_wdata[30:18]; // extract
  /*# sim_rtl/operator.vhd:171:1 */
  assign n3197 = n3193 == 32'b00000000000000000000000001100000;
  /*# sim_rtl/operator.vhd:177:35 */
  assign n3198 = ss_wdata[3:0]; // extract
  /*# sim_rtl/operator.vhd:179:36 */
  assign n3200 = ss_wdata[17:4]; // extract
  /*# sim_rtl/operator.vhd:176:1 */
  assign n3202 = n3193 == 32'b00000000000000000000000001100001;
  /*# sim_rtl/operator.vhd:170:1 */
  assign n3203 = {n3202, n3197};
  /*# sim_rtl/operator.vhd:170:1 */
  always @*
    case (n3203)
      2'b10: n3204 = n3198;
      2'b01: n3204 = n3363;
      default: n3204 = n3363;
    endcase
  /*# sim_rtl/operator.vhd:170:1 */
  always @*
    case (n3203)
      2'b10: n3205 = n3200;
      2'b01: n3205 = n3364;
      default: n3205 = n3364;
    endcase
  /*# sim_rtl/operator.vhd:170:1 */
  always @*
    case (n3203)
      2'b10: n3206 = addr;
      2'b01: n3206 = n3194;
      default: n3206 = addr;
    endcase
  /*# sim_rtl/operator.vhd:170:1 */
  always @*
    case (n3203)
      2'b10: n3207 = ff_egout;
      2'b01: n3207 = n3195;
      default: n3207 = ff_egout;
    endcase
  /*# sim_rtl/operator.vhd:153:1 */
  assign n3212 = n3220 ? n3204 : n3363;
  /*# sim_rtl/operator.vhd:153:1 */
  assign n3213 = n3221 ? n3205 : n3364;
  /*# sim_rtl/operator.vhd:153:1 */
  assign n3214 = n3222 ? n3206 : addr;
  /*# sim_rtl/operator.vhd:153:1 */
  assign n3215 = n3223 ? n3207 : ff_egout;
  /*# sim_rtl/operator.vhd:153:1 */
  assign n3220 = ss_write & n3174;
  /*# sim_rtl/operator.vhd:153:1 */
  assign n3221 = ss_write & n3174;
  /*# sim_rtl/operator.vhd:153:1 */
  assign n3222 = ss_write & n3174;
  /*# sim_rtl/operator.vhd:153:1 */
  assign n3223 = ss_write & n3174;
  /*# sim_rtl/operator.vhd:153:1 */
  assign n3229 = n3174 ? n3192 : 31'b0000000000000000000000000000000;
  /*# sim_rtl/operator.vhd:142:10 */
  assign n3231 = n3230[31]; // extract
  /*# sim_rtl/operator.vhd:142:10 */
  assign n3232 = {n3231, n3229};
  /*# sim_rtl/operator.vhd:186:11 */
  assign n3233 = ~ss_hold;
  /*# sim_rtl/operator.vhd:189:27 */
  assign n3235 = stage == 2'b00;
  /*# sim_rtl/operator.vhd:191:52 */
  assign n3237 = slot == 5'b01110;
  /*# sim_rtl/operator.vhd:191:65 */
  assign n3239 = slot == 5'b10001;
  /*# sim_rtl/operator.vhd:191:57 */
  assign n3240 = n3237 | n3239;
  /*# sim_rtl/operator.vhd:191:41 */
  assign n3241 = n3240 & rhythm;
  /*# sim_rtl/operator.vhd:192:34 */
  assign n3242 = ~noise;
  /*# sim_rtl/operator.vhd:192:45 */
  assign n3244 = {n3242, 8'b01111111};
  /*# sim_rtl/operator.vhd:192:58 */
  assign n3246 = {n3244, 9'b000000000};
  /*# sim_rtl/operator.vhd:193:50 */
  assign n3248 = slot == 5'b01111;
  /*# sim_rtl/operator.vhd:193:41 */
  assign n3249 = n3248 & rhythm;
  /*# sim_rtl/operator.vhd:194:43 */
  assign n3250 = pgout[17]; // extract
  /*# sim_rtl/operator.vhd:194:34 */
  assign n3251 = ~n3250;
  /*# sim_rtl/operator.vhd:194:57 */
  assign n3253 = {n3251, 8'b01111111};
  /*# sim_rtl/operator.vhd:194:70 */
  assign n3255 = {n3253, 9'b000000000};
  /*# sim_rtl/operator.vhd:195:50 */
  assign n3257 = slot == 5'b10000;
  /*# sim_rtl/operator.vhd:195:41 */
  assign n3258 = n3257 & rhythm;
  /*# sim_rtl/operator.vhd:198:35 */
  assign n3259 = n3129[0]; // extract
  /*# sim_rtl/operator.vhd:198:40 */
  assign n3260 = ~n3259;
  /*# sim_rtl/operator.vhd:199:53 */
  assign n3261 = w_modula[17:0]; // extract
  /*# sim_rtl/operator.vhd:199:43 */
  assign n3262 = pgout + n3261;
  /*# sim_rtl/operator.vhd:201:53 */
  assign n3263 = w_modula[17:0]; // extract
  /*# sim_rtl/operator.vhd:201:43 */
  assign n3264 = pgout - n3263;
  /*# sim_rtl/operator.vhd:198:25 */
  assign n3265 = n3260 ? n3262 : n3264;
  /*# sim_rtl/operator.vhd:195:21 */
  assign n3266 = n3258 ? pgout : n3265;
  /*# sim_rtl/operator.vhd:193:21 */
  assign n3267 = n3249 ? n3255 : n3266;
  /*# sim_rtl/operator.vhd:191:21 */
  assign n3268 = n3241 ? n3246 : n3267;
  /*# sim_rtl/operator.vhd:205:30 */
  assign n3270 = stage == 2'b01;
  /*# sim_rtl/operator.vhd:207:30 */
  assign n3272 = stage == 2'b10;
  /*# sim_rtl/operator.vhd:211:29 */
  assign n3273 = slot[0]; // extract
  /*# sim_rtl/operator.vhd:212:29 */
  assign n3274 = {27'b0, slot};  // uext
  /*# sim_rtl/operator.vhd:212:47 */
  assign n3276 = $signed(n3274) / $signed(32'b00000000000000000000000000000010); // sdiv
  /*# sim_rtl/operator.vhd:212:50 */
  assign n3278 = n3276 == 32'b00000000000000000000000000001000;
  /*# sim_rtl/operator.vhd:215:38 */
  assign n3279 = {27'b0, slot};  // uext
  /*# sim_rtl/operator.vhd:215:56 */
  assign n3281 = $signed(n3279) / $signed(32'b00000000000000000000000000000010); // sdiv
  /*# sim_rtl/operator.vhd:215:59 */
  assign n3283 = n3281 + 32'b00000000000000000000000000000001;
  /*# sim_rtl/operator.vhd:215:38 */
  assign n3284 = n3283[3:0];  // trunc
  /*# sim_rtl/operator.vhd:212:25 */
  assign n3286 = n3278 ? 4'b0000 : n3284;
  /*# sim_rtl/operator.vhd:207:17 */
  assign n3287 = n3308 ? n3286 : n3212;
  /*# sim_rtl/operator.vhd:218:30 */
  assign n3289 = stage == 2'b11;
  /*# sim_rtl/operator.vhd:220:32 */
  assign n3291 = {1'b0, ff_egout};
  /*# sim_rtl/operator.vhd:220:57 */
  assign n3292 = data[12:0]; // extract
  /*# sim_rtl/operator.vhd:220:51 */
  assign n3294 = {1'b0, n3292};
  /*# sim_rtl/operator.vhd:220:45 */
  assign n3295 = n3291 + n3294;
  /*# sim_rtl/operator.vhd:220:75 */
  assign n3297 = $unsigned(n3295) < $unsigned(14'b10000000000000);
  /*# sim_rtl/operator.vhd:221:42 */
  assign n3298 = data[13]; // extract
  /*# sim_rtl/operator.vhd:221:65 */
  assign n3299 = data[12:0]; // extract
  /*# sim_rtl/operator.vhd:221:59 */
  assign n3300 = ff_egout + n3299;
  /*# sim_rtl/operator.vhd:221:47 */
  assign n3301 = {n3298, n3300};
  /*# sim_rtl/operator.vhd:223:42 */
  assign n3302 = data[13]; // extract
  /*# sim_rtl/operator.vhd:223:47 */
  assign n3304 = {n3302, 13'b1111111111111};
  /*# sim_rtl/operator.vhd:220:21 */
  assign n3305 = n3297 ? n3301 : n3304;
  /*# sim_rtl/operator.vhd:218:17 */
  assign n3306 = n3289 ? n3305 : n3213;
  /*# sim_rtl/operator.vhd:207:17 */
  assign n3308 = n3273 & n3272;
  /*# sim_rtl/operator.vhd:207:17 */
  assign n3309 = n3272 ? n3213 : n3306;
  /*# sim_rtl/operator.vhd:207:17 */
  assign n3310 = n3272 ? egout : n3215;
  /*# sim_rtl/operator.vhd:205:17 */
  assign n3312 = n3270 ? n3212 : n3287;
  /*# sim_rtl/operator.vhd:205:17 */
  assign n3313 = n3270 ? n3213 : n3309;
  /*# sim_rtl/operator.vhd:205:17 */
  assign n3314 = n3270 ? n3215 : n3310;
  /*# sim_rtl/operator.vhd:189:17 */
  assign n3316 = n3235 ? n3212 : n3312;
  /*# sim_rtl/operator.vhd:189:17 */
  assign n3317 = n3235 ? n3213 : n3313;
  /*# sim_rtl/operator.vhd:186:1 */
  assign n3318 = n3328 ? n3268 : n3214;
  /*# sim_rtl/operator.vhd:189:17 */
  assign n3319 = n3235 ? n3215 : n3314;
  /*# sim_rtl/operator.vhd:186:1 */
  assign n3321 = n3326 ? n3316 : n3212;
  /*# sim_rtl/operator.vhd:186:1 */
  assign n3322 = n3327 ? n3317 : n3213;
  /*# sim_rtl/operator.vhd:188:13 */
  assign n3323 = n3235 & clkena;
  /*# sim_rtl/operator.vhd:186:1 */
  assign n3324 = n3329 ? n3319 : n3215;
  /*# sim_rtl/operator.vhd:186:1 */
  assign n3326 = clkena & n3233;
  /*# sim_rtl/operator.vhd:186:1 */
  assign n3327 = clkena & n3233;
  /*# sim_rtl/operator.vhd:186:1 */
  assign n3328 = n3323 & n3233;
  /*# sim_rtl/operator.vhd:186:1 */
  assign n3329 = clkena & n3233;
  /*# sim_rtl/operator.vhd:235:27 */
  assign n3358 = ss_local_data | ss_u_sine_table_data;
  /*# sim_rtl/operator.vhd:236:23 */
  assign n3360 = 1'b1 & ss_u_sine_table_ready;
  /*# sim_rtl/operator.vhd:59:9 */
  assign n3361 = ~reset;
  /*# sim_rtl/operator.vhd:150:1 */
  assign n3362 = n3361 ? n3321 : n3363;
  /*# sim_rtl/operator.vhd:150:1 */
  always @(posedge clk)
    n3363 <= n3362;
  /*# sim_rtl/operator.vhd:150:1 */
  always @(posedge clk or posedge reset)
    if (reset)
      n3364 <= 14'b00000000000000;
    else
      n3364 <= n3322;
  /*# sim_rtl/operator.vhd:96:12 */
  assign n3365 = ~reset;
  /*# sim_rtl/operator.vhd:150:1 */
  assign n3366 = n3365 ? n3318 : addr;
  /*# sim_rtl/operator.vhd:150:1 */
  always @(posedge clk)
    n3367 <= n3366;
  /*# sim_rtl/operator.vhd:150:1 */
  always @(posedge clk or posedge reset)
    if (reset)
      n3368 <= 13'b0000000000000;
    else
      n3368 <= n3324;
  /*# sim_rtl/operator.vhd:150:1 */
  always @(posedge clk or posedge reset)
    if (reset)
      n3369 <= 32'b00000000000000000000000000000000;
    else
      n3369 <= n3232;
endmodule

module phasegenerator_Brtl
  (input  clk,
   input  reset,
   input  clkena,
   input  [4:0] slot,
   input  [1:0] stage,
   input  rhythm,
   input  pm,
   input  [3:0] ml,
   input  [2:0] blk,
   input  [8:0] fnum,
   input  key,
   output noise,
   output [17:0] pgout,
   input  ss_hold,
   input  [7:0] ss_addr,
   input  ss_read,
   input  ss_write,
   input  [31:0] ss_wdata,
   output [31:0] ss_rdata,
   output ss_initialized);
  wire memwr;
  wire [17:0] memout;
  wire [17:0] memin;
  wire [12:0] pmcount;
  reg [31:0] ss_local_data;
  wire [31:0] ss_mem_data;
  wire ss_mem_ready;
  reg [17:0] n2716_lastkey;
  reg n2716_noise14;
  reg n2716_noise17;
  wire n2733;
  wire n2734;
  wire [31:0] n2735;
  wire n2737;
  wire n2739;
  wire n2741;
  wire [2:0] n2742;
  wire n2743;
  reg n2745;
  wire [16:0] n2746;
  wire [16:0] n2747;
  wire [16:0] n2748;
  reg [16:0] n2750;
  wire n2751;
  wire n2752;
  reg n2754;
  wire n2755;
  reg n2757;
  wire [11:0] n2758;
  reg [11:0] n2760;
  wire [31:0] n2761;
  wire [31:0] n2763;
  wire [31:0] n2764;
  wire n2765;
  wire [17:0] n2766;
  wire [12:0] n2767;
  wire n2769;
  wire n2770;
  wire [17:0] n2771;
  wire n2773;
  wire [17:0] n2774;
  wire n2775;
  wire n2776;
  wire n2778;
  wire [2:0] n2779;
  reg n2780;
  reg [17:0] n2781;
  reg n2782;
  reg [17:0] n2783;
  reg [12:0] n2784;
  reg [17:0] n2785;
  reg n2786;
  reg n2787;
  wire n2796;
  wire [17:0] n2797;
  wire n2798;
  wire [17:0] n2799;
  wire [12:0] n2800;
  wire [17:0] n2801;
  wire n2802;
  wire n2803;
  wire n2812;
  wire n2813;
  wire n2814;
  wire n2815;
  wire n2816;
  wire n2817;
  wire n2818;
  wire n2819;
  wire [31:0] n2829;
  wire n2831;
  wire n2832;
  wire n2834;
  wire n2836;
  wire n2838;
  wire n2840;
  wire [12:0] n2843;
  wire [12:0] n2844;
  wire [13:0] n2851;
  wire [13:0] n2852;
  wire [13:0] n2853;
  wire [21:0] n2855;
  wire [21:0] n2856;
  wire [17:0] n2857;
  wire [1:0] n2858;
  wire [17:0] n2860;
  wire [17:0] n2861;
  wire n2863;
  wire [17:0] n2865;
  wire [17:0] n2866;
  wire n2868;
  wire [1:0] n2869;
  reg [17:0] n2870;
  wire [17:0] n2871;
  wire n2875;
  wire n2876;
  wire n2877;
  wire n2879;
  wire n2881;
  wire n2882;
  wire n2883;
  wire n2884;
  wire [17:0] n2885;
  wire [17:0] n2887;
  wire n2892;
  wire [5:0] n2893;
  wire n2899;
  wire [2:0] n2900;
  wire n2905;
  wire n2906;
  wire n2907;
  wire n2909;
  wire n2911;
  wire [17:0] n2912;
  wire n2914;
  wire [17:0] n2915;
  wire n2916;
  wire [17:0] n2917;
  wire n2919;
  wire n2920;
  wire [17:0] n2922;
  wire n2923;
  wire [17:0] n2924;
  wire [12:0] n2925;
  wire [17:0] n2926;
  wire n2928;
  wire n2929;
  wire [17:0] n2931;
  wire n2933;
  wire [17:0] n2934;
  wire [12:0] n2935;
  wire [17:0] n2936;
  wire n2938;
  wire n2939;
  wire n2941;
  wire [17:0] n2942;
  wire n2943;
  wire [17:0] n2944;
  wire [12:0] n2945;
  wire [17:0] n2946;
  wire n2948;
  wire n2949;
  wire n2951;
  wire n2952;
  wire n2953;
  wire n2954;
  wire n2955;
  wire n2956;
  wire n2958;
  wire n2959;
  wire [17:0] mem_n3009;
  wire [31:0] mem_n3010;
  wire mem_n3011;
  wire [31:0] n3018;
  wire n3020;
  wire n3021;
  wire n3022;
  reg n3023;
  wire n3024;
  wire [17:0] n3025;
  reg [17:0] n3026;
  reg n3027;
  wire n3028;
  wire [17:0] n3029;
  reg [17:0] n3030;
  reg [12:0] n3031;
  reg [31:0] n3032;
  reg [17:0] n3033;
  reg n3034;
  reg n3035;
  wire [4:0] n3038; // mem_rd
  wire n3040; // mem_rd
  wire n3042; // mem_rd
  wire [31:0] n3044;
  wire n3045;
  wire n3046;
  wire n3047;
  wire n3048;
  wire n3049;
  wire n3050;
  wire n3051;
  wire n3052;
  wire n3053;
  wire n3054;
  wire n3055;
  wire n3056;
  wire n3057;
  wire n3058;
  wire n3059;
  wire n3060;
  wire n3061;
  wire n3062;
  wire n3063;
  wire n3064;
  wire n3065;
  wire n3066;
  wire n3067;
  wire n3068;
  wire n3069;
  wire n3070;
  wire n3071;
  wire n3072;
  wire n3073;
  wire n3074;
  wire n3075;
  wire n3076;
  wire n3077;
  wire n3078;
  wire n3079;
  wire n3080;
  wire n3081;
  wire n3082;
  wire n3083;
  wire n3084;
  wire n3085;
  wire n3086;
  wire n3087;
  wire n3088;
  wire n3089;
  wire n3090;
  wire n3091;
  wire n3092;
  wire n3093;
  wire n3094;
  wire n3095;
  wire n3096;
  wire n3097;
  wire n3098;
  wire n3099;
  wire n3100;
  wire n3101;
  wire n3102;
  wire n3103;
  wire n3104;
  wire n3105;
  wire n3106;
  wire n3107;
  wire n3108;
  wire n3109;
  wire n3110;
  wire n3111;
  wire n3112;
  wire n3113;
  wire n3114;
  wire n3115;
  wire n3116;
  wire n3117;
  wire n3118;
  wire n3119;
  wire n3120;
  wire n3121;
  wire n3122;
  wire n3123;
  wire n3124;
  wire n3125;
  wire n3126;
  wire [17:0] n3127;
  assign noise = n3023; //(module output)
  assign pgout = n3026; //(module output)
  assign ss_rdata = n3018; //(module output)
  assign ss_initialized = n3020; //(module output)
  /*# sim_rtl/phasegenerator.vhd:107:10 */
  assign memwr = n3027; // (signal)
  /*# sim_rtl/phasegenerator.vhd:108:10 */
  assign memout = mem_n3009; // (signal)
  /*# sim_rtl/phasegenerator.vhd:108:18 */
  assign memin = n3030; // (signal)
  /*# sim_rtl/phasegenerator.vhd:111:10 */
  assign pmcount = n3031; // (signal)
  /*# sim_rtl/phasegenerator.vhd:113:12 */
  always @*
    ss_local_data = n3032; // (isignal)
  initial
    ss_local_data = 32'b00000000000000000000000000000000;
  /*# sim_rtl/phasegenerator.vhd:114:12 */
  assign ss_mem_data = mem_n3010; // (signal)
  /*# sim_rtl/phasegenerator.vhd:115:12 */
  assign ss_mem_ready = mem_n3011; // (signal)
  /*# sim_rtl/phasegenerator.vhd:121:18 */
  always @*
    n2716_lastkey = n3033; // (isignal)
  initial
    n2716_lastkey = 18'bX;
  /*# sim_rtl/phasegenerator.vhd:123:18 */
  always @*
    n2716_noise14 = n3034; // (isignal)
  initial
    n2716_noise14 = 1'bX;
  /*# sim_rtl/phasegenerator.vhd:124:18 */
  always @*
    n2716_noise17 = n3035; // (isignal)
  initial
    n2716_noise17 = 1'bX;
  /*# sim_rtl/phasegenerator.vhd:152:33 */
  assign n2733 = ss_read | ss_write;
  /*# sim_rtl/phasegenerator.vhd:152:16 */
  assign n2734 = n2733 & ss_hold;
  /*# sim_rtl/phasegenerator.vhd:163:6 */
  assign n2735 = {24'b0, ss_addr};  // uext
  /*# sim_rtl/phasegenerator.vhd:164:1 */
  assign n2737 = n2735 == 32'b00000000000000000000000001011101;
  /*# sim_rtl/phasegenerator.vhd:168:1 */
  assign n2739 = n2735 == 32'b00000000000000000000000001011110;
  /*# sim_rtl/phasegenerator.vhd:171:1 */
  assign n2741 = n2735 == 32'b00000000000000000000000001011111;
  /*# sim_rtl/phasegenerator.vhd:163:1 */
  assign n2742 = {n2741, n2739, n2737};
  /*# sim_rtl/phasegenerator.vhd:121:18 */
  assign n2743 = n2716_lastkey[0]; // extract
  /*# sim_rtl/phasegenerator.vhd:163:1 */
  always @*
    case (n2742)
      3'b100: n2745 = n2743;
      3'b010: n2745 = n3023;
      3'b001: n2745 = memwr;
      default: n2745 = 1'b0;
    endcase
  /*# sim_rtl/phasegenerator.vhd:108:18 */
  assign n2746 = memin[16:0]; // extract
  /*# sim_rtl/phasegenerator.vhd:58:3 */
  assign n2747 = n3026[16:0]; // extract
  /*# sim_rtl/phasegenerator.vhd:121:18 */
  assign n2748 = n2716_lastkey[17:1]; // extract
  /*# sim_rtl/phasegenerator.vhd:163:1 */
  always @*
    case (n2742)
      3'b100: n2750 = n2748;
      3'b010: n2750 = n2747;
      3'b001: n2750 = n2746;
      default: n2750 = 17'b00000000000000000;
    endcase
  /*# sim_rtl/phasegenerator.vhd:108:18 */
  assign n2751 = memin[17]; // extract
  /*# sim_rtl/phasegenerator.vhd:58:3 */
  assign n2752 = n3026[17]; // extract
  /*# sim_rtl/phasegenerator.vhd:163:1 */
  always @*
    case (n2742)
      3'b100: n2754 = n2716_noise14;
      3'b010: n2754 = n2752;
      3'b001: n2754 = n2751;
      default: n2754 = 1'b0;
    endcase
  /*# sim_rtl/phasegenerator.vhd:111:10 */
  assign n2755 = pmcount[0]; // extract
  /*# sim_rtl/phasegenerator.vhd:163:1 */
  always @*
    case (n2742)
      3'b100: n2757 = n2716_noise17;
      3'b010: n2757 = 1'b0;
      3'b001: n2757 = n2755;
      default: n2757 = 1'b0;
    endcase
  /*# sim_rtl/phasegenerator.vhd:111:10 */
  assign n2758 = pmcount[12:1]; // extract
  /*# sim_rtl/phasegenerator.vhd:163:1 */
  always @*
    case (n2742)
      3'b100: n2760 = 12'b000000000000;
      3'b010: n2760 = 12'b000000000000;
      3'b001: n2760 = n2758;
      default: n2760 = 12'b000000000000;
    endcase
  /*# sim_rtl/phasegenerator.vhd:162:1 */
  assign n2761 = {n2760, n2757, n2754, n2750, n2745};
  /*# sim_rtl/phasegenerator.vhd:162:1 */
  assign n2763 = ss_read ? n2761 : 32'b00000000000000000000000000000000;
  /*# sim_rtl/phasegenerator.vhd:178:6 */
  assign n2764 = {24'b0, ss_addr};  // uext
  /*# sim_rtl/phasegenerator.vhd:180:26 */
  assign n2765 = ss_wdata[0]; // extract
  /*# sim_rtl/phasegenerator.vhd:182:36 */
  assign n2766 = ss_wdata[18:1]; // extract
  /*# sim_rtl/phasegenerator.vhd:184:38 */
  assign n2767 = ss_wdata[31:19]; // extract
  /*# sim_rtl/phasegenerator.vhd:179:1 */
  assign n2769 = n2764 == 32'b00000000000000000000000001011101;
  /*# sim_rtl/phasegenerator.vhd:187:26 */
  assign n2770 = ss_wdata[0]; // extract
  /*# sim_rtl/phasegenerator.vhd:189:36 */
  assign n2771 = ss_wdata[18:1]; // extract
  /*# sim_rtl/phasegenerator.vhd:186:1 */
  assign n2773 = n2764 == 32'b00000000000000000000000001011110;
  /*# sim_rtl/phasegenerator.vhd:192:38 */
  assign n2774 = ss_wdata[17:0]; // extract
  /*# sim_rtl/phasegenerator.vhd:194:28 */
  assign n2775 = ss_wdata[18]; // extract
  /*# sim_rtl/phasegenerator.vhd:196:28 */
  assign n2776 = ss_wdata[19]; // extract
  /*# sim_rtl/phasegenerator.vhd:191:1 */
  assign n2778 = n2764 == 32'b00000000000000000000000001011111;
  /*# sim_rtl/phasegenerator.vhd:178:1 */
  assign n2779 = {n2778, n2773, n2769};
  /*# sim_rtl/phasegenerator.vhd:178:1 */
  always @*
    case (n2779)
      3'b100: n2780 = n3023;
      3'b010: n2780 = n2770;
      3'b001: n2780 = n3023;
      default: n2780 = n3023;
    endcase
  /*# sim_rtl/phasegenerator.vhd:178:1 */
  always @*
    case (n2779)
      3'b100: n2781 = n3026;
      3'b010: n2781 = n2771;
      3'b001: n2781 = n3026;
      default: n2781 = n3026;
    endcase
  /*# sim_rtl/phasegenerator.vhd:178:1 */
  always @*
    case (n2779)
      3'b100: n2782 = memwr;
      3'b010: n2782 = memwr;
      3'b001: n2782 = n2765;
      default: n2782 = memwr;
    endcase
  /*# sim_rtl/phasegenerator.vhd:178:1 */
  always @*
    case (n2779)
      3'b100: n2783 = memin;
      3'b010: n2783 = memin;
      3'b001: n2783 = n2766;
      default: n2783 = memin;
    endcase
  /*# sim_rtl/phasegenerator.vhd:178:1 */
  always @*
    case (n2779)
      3'b100: n2784 = pmcount;
      3'b010: n2784 = pmcount;
      3'b001: n2784 = n2767;
      default: n2784 = pmcount;
    endcase
  /*# sim_rtl/phasegenerator.vhd:178:1 */
  always @*
    case (n2779)
      3'b100: n2785 = n2774;
      3'b010: n2785 = n2716_lastkey;
      3'b001: n2785 = n2716_lastkey;
      default: n2785 = n2716_lastkey;
    endcase
  /*# sim_rtl/phasegenerator.vhd:178:1 */
  always @*
    case (n2779)
      3'b100: n2786 = n2775;
      3'b010: n2786 = n2716_noise14;
      3'b001: n2786 = n2716_noise14;
      default: n2786 = n2716_noise14;
    endcase
  /*# sim_rtl/phasegenerator.vhd:178:1 */
  always @*
    case (n2779)
      3'b100: n2787 = n2776;
      3'b010: n2787 = n2716_noise17;
      3'b001: n2787 = n2716_noise17;
      default: n2787 = n2716_noise17;
    endcase
  /*# sim_rtl/phasegenerator.vhd:152:1 */
  assign n2796 = n2812 ? n2780 : n3023;
  /*# sim_rtl/phasegenerator.vhd:152:1 */
  assign n2797 = n2813 ? n2781 : n3026;
  /*# sim_rtl/phasegenerator.vhd:152:1 */
  assign n2798 = n2814 ? n2782 : memwr;
  /*# sim_rtl/phasegenerator.vhd:152:1 */
  assign n2799 = n2815 ? n2783 : memin;
  /*# sim_rtl/phasegenerator.vhd:152:1 */
  assign n2800 = n2816 ? n2784 : pmcount;
  /*# sim_rtl/phasegenerator.vhd:152:1 */
  assign n2801 = n2817 ? n2785 : n2716_lastkey;
  /*# sim_rtl/phasegenerator.vhd:152:1 */
  assign n2802 = n2818 ? n2786 : n2716_noise14;
  /*# sim_rtl/phasegenerator.vhd:152:1 */
  assign n2803 = n2819 ? n2787 : n2716_noise17;
  /*# sim_rtl/phasegenerator.vhd:152:1 */
  assign n2812 = ss_write & n2734;
  /*# sim_rtl/phasegenerator.vhd:152:1 */
  assign n2813 = ss_write & n2734;
  /*# sim_rtl/phasegenerator.vhd:152:1 */
  assign n2814 = ss_write & n2734;
  /*# sim_rtl/phasegenerator.vhd:152:1 */
  assign n2815 = ss_write & n2734;
  /*# sim_rtl/phasegenerator.vhd:152:1 */
  assign n2816 = ss_write & n2734;
  /*# sim_rtl/phasegenerator.vhd:152:1 */
  assign n2817 = ss_write & n2734;
  /*# sim_rtl/phasegenerator.vhd:152:1 */
  assign n2818 = ss_write & n2734;
  /*# sim_rtl/phasegenerator.vhd:152:1 */
  assign n2819 = ss_write & n2734;
  /*# sim_rtl/phasegenerator.vhd:152:1 */
  assign n2829 = n2734 ? n2763 : 32'b00000000000000000000000000000000;
  /*# sim_rtl/phasegenerator.vhd:203:11 */
  assign n2831 = ~ss_hold;
  /*# sim_rtl/phasegenerator.vhd:206:24 */
  assign n2832 = n2802 ^ n2803;
  /*# sim_rtl/phasegenerator.vhd:208:16 */
  assign n2834 = stage == 2'b00;
  /*# sim_rtl/phasegenerator.vhd:212:19 */
  assign n2836 = stage == 2'b01;
  /*# sim_rtl/phasegenerator.vhd:216:19 */
  assign n2838 = stage == 2'b10;
  /*# sim_rtl/phasegenerator.vhd:219:17 */
  assign n2840 = slot == 5'b00000;
  /*# sim_rtl/phasegenerator.vhd:220:30 */
  assign n2843 = pmcount + 13'b0000000000001;
  /*# sim_rtl/phasegenerator.vhd:216:7 */
  assign n2844 = n2916 ? n2843 : n2800;
  /*# sim_rtl/phasegenerator.vhd:224:40 */
  assign n2851 = {5'b0, fnum};  // uext
  /*# sim_rtl/phasegenerator.vhd:224:40 */
  assign n2852 = {9'b0, n3038};  // uext
  /*# sim_rtl/phasegenerator.vhd:224:40 */
  assign n2853 = n2851 * n2852; // umul
  /*# sim_rtl/phasegenerator.vhd:224:34 */
  assign n2855 = {8'b00000000, n2853};
  /*# sim_rtl/phasegenerator.vhd:224:20 */
  assign n2856 = n2855 << blk;
  /*# sim_rtl/phasegenerator.vhd:224:70 */
  assign n2857 = n2856[19:2]; // extract
  /*# sim_rtl/phasegenerator.vhd:227:24 */
  assign n2858 = pmcount[12:11]; // extract
  /*# sim_rtl/phasegenerator.vhd:229:35 */
  assign n2860 = n2857 >> 3'b111;
  /*# sim_rtl/phasegenerator.vhd:229:33 */
  assign n2861 = n2857 + n2860;
  /*# sim_rtl/phasegenerator.vhd:228:14 */
  assign n2863 = n2858 == 2'b01;
  /*# sim_rtl/phasegenerator.vhd:231:35 */
  assign n2865 = n2857 >> 3'b111;
  /*# sim_rtl/phasegenerator.vhd:231:33 */
  assign n2866 = n2857 - n2865;
  /*# sim_rtl/phasegenerator.vhd:230:14 */
  assign n2868 = n2858 == 2'b11;
  /*# sim_rtl/phasegenerator.vhd:227:12 */
  assign n2869 = {n2868, n2863};
  /*# sim_rtl/phasegenerator.vhd:227:12 */
  always @*
    case (n2869)
      2'b10: n2870 = n2866;
      2'b01: n2870 = n2861;
      default: n2870 = n2857;
    endcase
  /*# sim_rtl/phasegenerator.vhd:226:9 */
  assign n2871 = pm ? n2870 : n2857;
  /*# sim_rtl/phasegenerator.vhd:237:40 */
  assign n2875 = ~n3045;
  /*# sim_rtl/phasegenerator.vhd:237:46 */
  assign n2876 = key & n2875;
  /*# sim_rtl/phasegenerator.vhd:237:72 */
  assign n2877 = ~rhythm;
  /*# sim_rtl/phasegenerator.vhd:237:87 */
  assign n2879 = slot != 5'b01110;
  /*# sim_rtl/phasegenerator.vhd:237:107 */
  assign n2881 = slot != 5'b10001;
  /*# sim_rtl/phasegenerator.vhd:237:98 */
  assign n2882 = n2881 & n2879;
  /*# sim_rtl/phasegenerator.vhd:237:78 */
  assign n2883 = n2877 | n2882;
  /*# sim_rtl/phasegenerator.vhd:237:60 */
  assign n2884 = n2883 & n2876;
  /*# sim_rtl/phasegenerator.vhd:240:27 */
  assign n2885 = memout + n2871;
  /*# sim_rtl/phasegenerator.vhd:237:9 */
  assign n2887 = n2884 ? 18'b000000000000000000 : n2885;
  /*# sim_rtl/phasegenerator.vhd:245:17 */
  assign n2892 = slot == 5'b01110;
  /*# sim_rtl/phasegenerator.vhd:246:53 */
  assign n2893 = memout[15:10]; // extract
  /*# sim_rtl/phasegenerator.vhd:247:20 */
  assign n2899 = slot == 5'b10001;
  /*# sim_rtl/phasegenerator.vhd:248:53 */
  assign n2900 = memout[13:11]; // extract
  /*# sim_rtl/phasegenerator.vhd:247:9 */
  assign n2905 = n2899 ? n3042 : n2803;
  /*# sim_rtl/phasegenerator.vhd:216:7 */
  assign n2906 = n2919 ? n3040 : n2802;
  /*# sim_rtl/phasegenerator.vhd:245:9 */
  assign n2907 = n2892 ? n2803 : n2905;
  /*# sim_rtl/phasegenerator.vhd:255:19 */
  assign n2909 = stage == 2'b11;
  /*# sim_rtl/phasegenerator.vhd:255:7 */
  assign n2911 = n2909 ? 1'b0 : n2798;
  /*# sim_rtl/phasegenerator.vhd:216:7 */
  assign n2912 = n2838 ? memout : n2797;
  /*# sim_rtl/phasegenerator.vhd:216:7 */
  assign n2914 = n2838 ? 1'b1 : n2911;
  /*# sim_rtl/phasegenerator.vhd:216:7 */
  assign n2915 = n2838 ? n2887 : n2799;
  /*# sim_rtl/phasegenerator.vhd:216:7 */
  assign n2916 = n2840 & n2838;
  /*# sim_rtl/phasegenerator.vhd:216:7 */
  assign n2917 = n2838 ? n3127 : n2801;
  /*# sim_rtl/phasegenerator.vhd:216:7 */
  assign n2919 = n2892 & n2838;
  /*# sim_rtl/phasegenerator.vhd:216:7 */
  assign n2920 = n2838 ? n2907 : n2803;
  /*# sim_rtl/phasegenerator.vhd:212:7 */
  assign n2922 = n2836 ? n2797 : n2912;
  /*# sim_rtl/phasegenerator.vhd:212:7 */
  assign n2923 = n2836 ? n2798 : n2914;
  /*# sim_rtl/phasegenerator.vhd:212:7 */
  assign n2924 = n2836 ? n2799 : n2915;
  /*# sim_rtl/phasegenerator.vhd:212:7 */
  assign n2925 = n2836 ? n2800 : n2844;
  /*# sim_rtl/phasegenerator.vhd:212:7 */
  assign n2926 = n2836 ? n2801 : n2917;
  /*# sim_rtl/phasegenerator.vhd:212:7 */
  assign n2928 = n2836 ? n2802 : n2906;
  /*# sim_rtl/phasegenerator.vhd:212:7 */
  assign n2929 = n2836 ? n2803 : n2920;
  /*# sim_rtl/phasegenerator.vhd:208:7 */
  assign n2931 = n2834 ? n2797 : n2922;
  /*# sim_rtl/phasegenerator.vhd:208:7 */
  assign n2933 = n2834 ? 1'b0 : n2923;
  /*# sim_rtl/phasegenerator.vhd:208:7 */
  assign n2934 = n2834 ? n2799 : n2924;
  /*# sim_rtl/phasegenerator.vhd:208:7 */
  assign n2935 = n2834 ? n2800 : n2925;
  /*# sim_rtl/phasegenerator.vhd:208:7 */
  assign n2936 = n2834 ? n2801 : n2926;
  /*# sim_rtl/phasegenerator.vhd:208:7 */
  assign n2938 = n2834 ? n2802 : n2928;
  /*# sim_rtl/phasegenerator.vhd:208:7 */
  assign n2939 = n2834 ? n2803 : n2929;
  /*# sim_rtl/phasegenerator.vhd:203:1 */
  assign n2941 = n2951 ? n2832 : n2796;
  /*# sim_rtl/phasegenerator.vhd:203:1 */
  assign n2942 = n2952 ? n2931 : n2797;
  /*# sim_rtl/phasegenerator.vhd:203:1 */
  assign n2943 = n2953 ? n2933 : n2798;
  /*# sim_rtl/phasegenerator.vhd:203:1 */
  assign n2944 = n2954 ? n2934 : n2799;
  /*# sim_rtl/phasegenerator.vhd:203:1 */
  assign n2945 = n2955 ? n2935 : n2800;
  /*# sim_rtl/phasegenerator.vhd:203:1 */
  assign n2946 = n2956 ? n2936 : n2801;
  /*# sim_rtl/phasegenerator.vhd:203:1 */
  assign n2948 = n2958 ? n2938 : n2802;
  /*# sim_rtl/phasegenerator.vhd:203:1 */
  assign n2949 = n2959 ? n2939 : n2803;
  /*# sim_rtl/phasegenerator.vhd:203:1 */
  assign n2951 = clkena & n2831;
  /*# sim_rtl/phasegenerator.vhd:203:1 */
  assign n2952 = clkena & n2831;
  /*# sim_rtl/phasegenerator.vhd:203:1 */
  assign n2953 = clkena & n2831;
  /*# sim_rtl/phasegenerator.vhd:203:1 */
  assign n2954 = clkena & n2831;
  /*# sim_rtl/phasegenerator.vhd:203:1 */
  assign n2955 = clkena & n2831;
  /*# sim_rtl/phasegenerator.vhd:203:1 */
  assign n2956 = clkena & n2831;
  /*# sim_rtl/phasegenerator.vhd:203:1 */
  assign n2958 = clkena & n2831;
  /*# sim_rtl/phasegenerator.vhd:203:1 */
  assign n2959 = clkena & n2831;
  /*# sim_rtl/phasegenerator.vhd:268:3 */
  phasememory_Brtl mem (
    .clk(clk),
    .reset(reset),
    .slot(slot),
    .memwr(memwr),
    .memin(memin),
    .ss_hold(ss_hold),
    .ss_addr(ss_addr),
    .ss_read(ss_read),
    .ss_write(ss_write),
    .ss_wdata(ss_wdata),
    .memout(mem_n3009),
    .ss_rdata(mem_n3010),
    .ss_initialized(mem_n3011));
  /*# sim_rtl/phasegenerator.vhd:271:27 */
  assign n3018 = ss_local_data | ss_mem_data;
  /*# sim_rtl/phasegenerator.vhd:272:23 */
  assign n3020 = 1'b1 & ss_mem_ready;
  /*# sim_rtl/phasegenerator.vhd:57:3 */
  assign n3021 = ~reset;
  /*# sim_rtl/phasegenerator.vhd:149:1 */
  assign n3022 = n3021 ? n2941 : n3023;
  /*# sim_rtl/phasegenerator.vhd:149:1 */
  always @(posedge clk)
    n3023 <= n3022;
  /*# sim_rtl/phasegenerator.vhd:58:3 */
  assign n3024 = ~reset;
  /*# sim_rtl/phasegenerator.vhd:149:1 */
  assign n3025 = n3024 ? n2942 : n3026;
  /*# sim_rtl/phasegenerator.vhd:149:1 */
  always @(posedge clk)
    n3026 <= n3025;
  /*# sim_rtl/phasegenerator.vhd:149:1 */
  always @(posedge clk or posedge reset)
    if (reset)
      n3027 <= 1'b0;
    else
      n3027 <= n2943;
  /*# sim_rtl/phasegenerator.vhd:108:18 */
  assign n3028 = ~reset;
  /*# sim_rtl/phasegenerator.vhd:149:1 */
  assign n3029 = n3028 ? n2944 : memin;
  /*# sim_rtl/phasegenerator.vhd:149:1 */
  always @(posedge clk)
    n3030 <= n3029;
  /*# sim_rtl/phasegenerator.vhd:149:1 */
  always @(posedge clk or posedge reset)
    if (reset)
      n3031 <= 13'b0000000000000;
    else
      n3031 <= n2945;
  /*# sim_rtl/phasegenerator.vhd:149:1 */
  always @(posedge clk or posedge reset)
    if (reset)
      n3032 <= 32'b00000000000000000000000000000000;
    else
      n3032 <= n2829;
  /*# sim_rtl/phasegenerator.vhd:149:1 */
  always @(posedge clk or posedge reset)
    if (reset)
      n3033 <= 18'b000000000000000000;
    else
      n3033 <= n2946;
  /*# sim_rtl/phasegenerator.vhd:149:1 */
  always @(posedge clk or posedge reset)
    if (reset)
      n3034 <= 1'b0;
    else
      n3034 <= n2948;
  /*# sim_rtl/phasegenerator.vhd:149:1 */
  always @(posedge clk or posedge reset)
    if (reset)
      n3035 <= 1'b0;
    else
      n3035 <= n2949;
  /*# sim_rtl/phasegenerator.vhd:224:47 */
  reg [4:0] n3036[15:0] ; // memory
  initial begin
    n3036[15] = 5'b11110;
    n3036[14] = 5'b11110;
    n3036[13] = 5'b11000;
    n3036[12] = 5'b11000;
    n3036[11] = 5'b10100;
    n3036[10] = 5'b10100;
    n3036[9] = 5'b10010;
    n3036[8] = 5'b10000;
    n3036[7] = 5'b01110;
    n3036[6] = 5'b01100;
    n3036[5] = 5'b01010;
    n3036[4] = 5'b01000;
    n3036[3] = 5'b00110;
    n3036[2] = 5'b00100;
    n3036[1] = 5'b00010;
    n3036[0] = 5'b00001;
    end
  assign n3038 = n3036[ml];
  /*# sim_rtl/phasegenerator.vhd:224:47 */
  /*# sim_rtl/phasegenerator.vhd:224:46 */
  reg n3039[63:0] ; // memory
  initial begin
    n3039[63] = 1'b1;
    n3039[62] = 1'b0;
    n3039[61] = 1'b0;
    n3039[60] = 1'b0;
    n3039[59] = 1'b1;
    n3039[58] = 1'b0;
    n3039[57] = 1'b0;
    n3039[56] = 1'b0;
    n3039[55] = 1'b1;
    n3039[54] = 1'b0;
    n3039[53] = 1'b0;
    n3039[52] = 1'b0;
    n3039[51] = 1'b1;
    n3039[50] = 1'b0;
    n3039[49] = 1'b0;
    n3039[48] = 1'b0;
    n3039[47] = 1'b1;
    n3039[46] = 1'b0;
    n3039[45] = 1'b0;
    n3039[44] = 1'b0;
    n3039[43] = 1'b1;
    n3039[42] = 1'b0;
    n3039[41] = 1'b0;
    n3039[40] = 1'b0;
    n3039[39] = 1'b1;
    n3039[38] = 1'b0;
    n3039[37] = 1'b0;
    n3039[36] = 1'b0;
    n3039[35] = 1'b1;
    n3039[34] = 1'b0;
    n3039[33] = 1'b0;
    n3039[32] = 1'b1;
    n3039[31] = 1'b0;
    n3039[30] = 1'b0;
    n3039[29] = 1'b0;
    n3039[28] = 1'b1;
    n3039[27] = 1'b0;
    n3039[26] = 1'b0;
    n3039[25] = 1'b0;
    n3039[24] = 1'b1;
    n3039[23] = 1'b0;
    n3039[22] = 1'b0;
    n3039[21] = 1'b0;
    n3039[20] = 1'b1;
    n3039[19] = 1'b0;
    n3039[18] = 1'b0;
    n3039[17] = 1'b0;
    n3039[16] = 1'b1;
    n3039[15] = 1'b0;
    n3039[14] = 1'b0;
    n3039[13] = 1'b0;
    n3039[12] = 1'b1;
    n3039[11] = 1'b0;
    n3039[10] = 1'b0;
    n3039[9] = 1'b0;
    n3039[8] = 1'b1;
    n3039[7] = 1'b0;
    n3039[6] = 1'b0;
    n3039[5] = 1'b0;
    n3039[4] = 1'b1;
    n3039[3] = 1'b0;
    n3039[2] = 1'b0;
    n3039[1] = 1'b0;
    n3039[0] = 1'b0;
    end
  assign n3040 = n3039[n2893];
  /*# sim_rtl/phasegenerator.vhd:246:34 */
  /*# sim_rtl/phasegenerator.vhd:246:33 */
  reg n3041[7:0] ; // memory
  initial begin
    n3041[7] = 1'b0;
    n3041[6] = 1'b0;
    n3041[5] = 1'b0;
    n3041[4] = 1'b0;
    n3041[3] = 1'b1;
    n3041[2] = 1'b0;
    n3041[1] = 1'b1;
    n3041[0] = 1'b0;
    end
  assign n3042 = n3041[n2900];
  /*# sim_rtl/phasegenerator.vhd:248:34 */
  /*# sim_rtl/phasegenerator.vhd:237:20 */
  assign n3044 = {14'bX, n2801};
  /*# sim_rtl/phasegenerator.vhd:237:20 */
  assign n3045 = n3044[slot * 1 +: 1]; //(Bmux)
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3046 = slot[4]; // extract
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3047 = ~n3046;
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3048 = slot[3]; // extract
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3049 = ~n3048;
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3050 = n3047 & n3049;
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3051 = n3047 & n3048;
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3052 = n3046 & n3049;
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3053 = slot[2]; // extract
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3054 = ~n3053;
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3055 = n3050 & n3054;
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3056 = n3050 & n3053;
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3057 = n3051 & n3054;
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3058 = n3051 & n3053;
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3059 = n3052 & n3054;
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3060 = slot[1]; // extract
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3061 = ~n3060;
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3062 = n3055 & n3061;
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3063 = n3055 & n3060;
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3064 = n3056 & n3061;
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3065 = n3056 & n3060;
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3066 = n3057 & n3061;
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3067 = n3057 & n3060;
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3068 = n3058 & n3061;
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3069 = n3058 & n3060;
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3070 = n3059 & n3061;
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3071 = slot[0]; // extract
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3072 = ~n3071;
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3073 = n3062 & n3072;
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3074 = n3062 & n3071;
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3075 = n3063 & n3072;
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3076 = n3063 & n3071;
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3077 = n3064 & n3072;
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3078 = n3064 & n3071;
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3079 = n3065 & n3072;
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3080 = n3065 & n3071;
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3081 = n3066 & n3072;
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3082 = n3066 & n3071;
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3083 = n3067 & n3072;
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3084 = n3067 & n3071;
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3085 = n3068 & n3072;
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3086 = n3068 & n3071;
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3087 = n3069 & n3072;
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3088 = n3069 & n3071;
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3089 = n3070 & n3072;
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3090 = n3070 & n3071;
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3091 = n2801[0]; // extract
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3092 = n3073 ? key : n3091;
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3093 = n2801[1]; // extract
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3094 = n3074 ? key : n3093;
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3095 = n2801[2]; // extract
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3096 = n3075 ? key : n3095;
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3097 = n2801[3]; // extract
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3098 = n3076 ? key : n3097;
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3099 = n2801[4]; // extract
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3100 = n3077 ? key : n3099;
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3101 = n2801[5]; // extract
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3102 = n3078 ? key : n3101;
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3103 = n2801[6]; // extract
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3104 = n3079 ? key : n3103;
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3105 = n2801[7]; // extract
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3106 = n3080 ? key : n3105;
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3107 = n2801[8]; // extract
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3108 = n3081 ? key : n3107;
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3109 = n2801[9]; // extract
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3110 = n3082 ? key : n3109;
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3111 = n2801[10]; // extract
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3112 = n3083 ? key : n3111;
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3113 = n2801[11]; // extract
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3114 = n3084 ? key : n3113;
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3115 = n2801[12]; // extract
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3116 = n3085 ? key : n3115;
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3117 = n2801[13]; // extract
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3118 = n3086 ? key : n3117;
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3119 = n2801[14]; // extract
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3120 = n3087 ? key : n3119;
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3121 = n2801[15]; // extract
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3122 = n3088 ? key : n3121;
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3123 = n2801[16]; // extract
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3124 = n3089 ? key : n3123;
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3125 = n2801[17]; // extract
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3126 = n3090 ? key : n3125;
  /*# sim_rtl/phasegenerator.vhd:242:9 */
  assign n3127 = {n3126, n3124, n3122, n3120, n3118, n3116, n3114, n3112, n3110, n3108, n3106, n3104, n3102, n3100, n3098, n3096, n3094, n3092};
endmodule

module envelopegenerator_Brtl
  (input  clk,
   input  reset,
   input  clkena,
   input  [4:0] slot,
   input  [1:0] stage,
   input  rhythm,
   input  am,
   input  [6:0] tl,
   input  [3:0] ar,
   input  [3:0] dr,
   input  [3:0] sl,
   input  [3:0] rr,
   input  [3:0] rks,
   input  key,
   output [12:0] egout,
   input  ss_hold,
   input  [7:0] ss_addr,
   input  ss_read,
   input  ss_write,
   input  [31:0] ss_wdata,
   output [31:0] ss_rdata,
   output ss_initialized);
  wire [4:0] rslot;
  wire [24:0] memin;
  wire [24:0] memout;
  wire memwr;
  wire [21:0] aridx;
  wire [12:0] ardata;
  reg [31:0] ss_local_data;
  wire [31:0] ss_u_envelope_memory_data;
  wire ss_u_envelope_memory_ready;
  wire [31:0] ss_u_attack_table_data;
  wire ss_u_attack_table_ready;
  wire [12:0] u_attack_table_n2047;
  wire [31:0] u_attack_table_n2048;
  wire u_attack_table_n2049;
  wire [24:0] u_envelope_memory_n2056;
  wire [31:0] u_envelope_memory_n2057;
  wire u_envelope_memory_n2058;
  wire [1:0] \u_envelope_memory.rdata[state] ;
  wire [22:0] \u_envelope_memory.rdata[phase] ;
  wire [1:0] n2059;
  wire [22:0] n2060;
  wire [24:0] n2061;
  reg [17:0] n2068_lastkey;
  reg [4:0] n2068_rm;
  reg [14:0] n2068_egtmp;
  reg [19:0] n2068_amphase;
  reg [22:0] n2068_egphase;
  reg [1:0] n2068_egstate;
  reg [17:0] n2068_ntable;
  wire [21:0] n2091;
  wire n2092;
  wire n2093;
  wire [1:0] n2099;
  wire [22:0] n2100;
  wire [24:0] n2101;
  wire [31:0] n2102;
  wire n2104;
  wire n2106;
  wire n2108;
  wire n2110;
  wire n2112;
  wire [4:0] n2113;
  wire [4:0] n2114;
  wire [4:0] n2115;
  wire [4:0] n2116;
  wire [4:0] n2117;
  reg [4:0] n2119;
  wire [7:0] n2120;
  wire [7:0] n2121;
  wire [7:0] n2122;
  wire [7:0] n2123;
  wire [7:0] n2124;
  reg [7:0] n2126;
  wire [4:0] n2127;
  wire [4:0] n2128;
  wire [4:0] n2129;
  wire [4:0] n2130;
  wire [4:0] n2131;
  reg [4:0] n2133;
  wire [1:0] n2134;
  wire [1:0] n2135;
  wire [1:0] n2136;
  wire [1:0] n2137;
  reg [1:0] n2139;
  wire [2:0] n2140;
  wire [2:0] n2141;
  wire [2:0] n2142;
  reg [2:0] n2144;
  wire [1:0] n2145;
  wire [1:0] n2146;
  reg [1:0] n2148;
  wire [4:0] n2149;
  wire [4:0] n2150;
  reg [4:0] n2152;
  wire n2153;
  reg n2155;
  wire [30:0] n2156;
  wire [30:0] n2158;
  wire [31:0] n2159;
  wire [4:0] n2160;
  wire [1:0] n2167;
  wire [22:0] n2168;
  wire [24:0] n2169;
  wire n2170;
  wire n2172;
  wire [12:0] n2173;
  wire [17:0] n2174;
  wire n2176;
  wire [19:0] n2177;
  wire n2179;
  wire [22:0] n2180;
  wire [1:0] n2181;
  wire n2183;
  wire [17:0] n2184;
  wire n2186;
  wire [4:0] n2187;
  reg [12:0] n2188;
  reg [4:0] n2189;
  reg [24:0] n2190;
  reg n2191;
  reg [17:0] n2192;
  reg [19:0] n2193;
  reg [22:0] n2194;
  reg [1:0] n2195;
  reg [17:0] n2196;
  wire [12:0] n2206;
  wire [4:0] n2207;
  wire [24:0] n2208;
  wire n2209;
  wire [17:0] n2210;
  wire [19:0] n2211;
  wire [22:0] n2212;
  wire [1:0] n2213;
  wire [17:0] n2214;
  wire n2224;
  wire n2225;
  wire n2226;
  wire n2227;
  wire n2228;
  wire n2229;
  wire n2230;
  wire n2231;
  wire n2232;
  wire [30:0] n2243;
  localparam [31:0] n2244 = 32'b00000000000000000000000000000000;
  wire n2245;
  wire [31:0] n2246;
  wire n2247;
  wire n2249;
  wire n2251;
  wire [4:0] n2253;
  wire [4:0] n2255;
  wire [4:0] n2256;
  wire n2257;
  wire [16:0] n2258;
  wire n2259;
  wire [17:0] n2260;
  wire n2261;
  wire n2262;
  wire [17:0] n2263;
  wire n2264;
  wire n2265;
  wire [19:0] n2268;
  wire [4:0] n2269;
  wire n2271;
  wire [4:0] n2273;
  wire [4:0] n2274;
  wire [14:0] n2275;
  wire n2277;
  wire [1:0] n2278;
  wire [22:0] n2279;
  wire n2281;
  wire n2283;
  wire [4:0] n2285;
  wire [8:0] n2287;
  wire [14:0] n2289;
  wire [14:0] n2291;
  wire [14:0] n2292;
  wire n2294;
  wire [4:0] n2296;
  wire [8:0] n2298;
  wire [14:0] n2300;
  wire [12:0] n2301;
  wire [14:0] n2303;
  wire [14:0] n2304;
  wire n2306;
  wire [4:0] n2308;
  wire [8:0] n2310;
  wire [14:0] n2312;
  wire [12:0] n2313;
  wire [14:0] n2315;
  wire [14:0] n2316;
  wire n2318;
  wire n2322;
  wire [3:0] n2323;
  reg [4:0] n2324;
  wire [12:0] n2325;
  wire [12:0] n2326;
  wire [12:0] n2327;
  wire [12:0] n2328;
  reg [12:0] n2329;
  wire [1:0] n2330;
  wire [1:0] n2331;
  wire [1:0] n2332;
  wire [1:0] n2333;
  reg [1:0] n2334;
  wire [17:0] n2335;
  wire n2336;
  wire [31:0] n2337;
  wire [31:0] n2339;
  wire n2341;
  wire n2342;
  wire n2343;
  wire [14:0] n2344;
  wire [14:0] n2346;
  wire [14:0] n2347;
  wire [14:0] n2348;
  wire [19:0] n2349;
  wire n2350;
  wire n2351;
  wire [19:0] n2352;
  wire [9:0] n2353;
  wire [9:0] n2355;
  wire [14:0] n2357;
  wire [14:0] n2358;
  wire [19:0] n2359;
  wire [9:0] n2360;
  wire [9:0] n2362;
  wire [14:0] n2364;
  wire [14:0] n2365;
  wire [14:0] n2366;
  wire [14:0] n2367;
  wire [1:0] n2368;
  wire n2370;
  wire [12:0] n2371;
  wire [12:0] n2373;
  wire n2375;
  wire [1:0] n2376;
  wire [4:0] n2377;
  wire [4:0] n2378;
  wire n2379;
  wire [3:0] n2381;
  wire [3:0] n2382;
  wire n2383;
  localparam [17:0] n2384 = 18'b000000000000000000;
  wire [1:0] n2385;
  wire [2:0] n2387;
  wire [5:0] n2390;
  wire [5:0] n2391;
  wire [16:0] n2392;
  wire [4:0] n2393;
  wire [3:0] n2394;
  wire [22:0] n2395;
  wire [22:0] n2396;
  wire [22:0] n2397;
  wire n2399;
  wire [1:0] n2401;
  wire [2:0] n2403;
  wire [4:0] n2404;
  wire [3:0] n2405;
  wire [3:0] n2408;
  wire [22:0] n2409;
  wire [22:0] n2410;
  wire [22:0] n2411;
  wire n2413;
  wire n2415;
  wire n2416;
  wire n2418;
  wire [2:0] n2419;
  reg [22:0] n2420;
  wire [4:0] n2422;
  wire [4:0] n2423;
  wire [22:0] n2424;
  wire n2426;
  wire [22:0] n2428;
  wire [1:0] n2430;
  wire n2432;
  wire [4:0] n2433;
  wire [4:0] n2435;
  wire n2436;
  wire [1:0] n2438;
  wire n2440;
  wire [4:0] n2441;
  wire n2443;
  wire [1:0] n2445;
  wire n2447;
  wire n2449;
  wire [3:0] n2450;
  reg [22:0] n2452;
  reg [1:0] n2453;
  wire n2457;
  wire n2458;
  wire n2464;
  wire n2465;
  wire n2467;
  wire n2468;
  wire [1:0] n2470;
  wire [22:0] n2471;
  wire [22:0] n2472;
  wire [1:0] n2474;
  wire [24:0] n2478;
  wire n2480;
  wire n2482;
  wire [12:0] n2483;
  wire [24:0] n2484;
  wire n2486;
  wire [17:0] n2487;
  wire [4:0] n2488;
  wire [14:0] n2489;
  wire [22:0] n2490;
  wire [1:0] n2491;
  wire [12:0] n2493;
  wire [24:0] n2494;
  wire n2495;
  wire [17:0] n2496;
  wire [4:0] n2497;
  wire [14:0] n2498;
  wire [22:0] n2499;
  wire [1:0] n2500;
  wire [12:0] n2502;
  wire [24:0] n2503;
  wire n2504;
  wire [17:0] n2505;
  wire [4:0] n2506;
  wire [14:0] n2507;
  wire [22:0] n2508;
  wire [1:0] n2509;
  wire [12:0] n2511;
  wire [24:0] n2512;
  wire n2513;
  wire [17:0] n2514;
  wire [19:0] n2517;
  wire [19:0] n2518;
  wire [22:0] n2519;
  wire [1:0] n2520;
  wire [17:0] n2522;
  wire [17:0] n2523;
  wire n2524;
  wire n2525;
  wire n2526;
  wire n2527;
  wire n2528;
  wire n2529;
  wire n2530;
  wire n2531;
  wire n2532;
  wire n2533;
  wire n2535;
  wire [19:0] n2575;
  wire [31:0] n2595;
  wire [31:0] n2596;
  wire n2598;
  wire n2599;
  wire n2600;
  wire [12:0] n2601;
  reg [12:0] n2602;
  reg [4:0] n2603;
  wire n2604;
  wire [24:0] n2605;
  reg [24:0] n2606;
  reg n2607;
  wire n2608;
  wire [21:0] n2609;
  reg [21:0] n2610;
  reg [31:0] n2611;
  reg [17:0] n2612;
  wire [4:0] n2613;
  reg [4:0] n2614;
  wire n2615;
  wire n2616;
  wire [14:0] n2617;
  reg [14:0] n2618;
  reg [19:0] n2619;
  reg [22:0] n2620;
  reg [1:0] n2621;
  reg [17:0] n2622;
  wire [31:0] n2624;
  wire n2625;
  wire [31:0] n2627;
  wire n2628;
  wire n2629;
  wire n2630;
  wire n2631;
  wire n2632;
  wire n2633;
  wire n2634;
  wire n2635;
  wire n2636;
  wire n2637;
  wire n2638;
  wire n2639;
  wire n2640;
  wire n2641;
  wire n2642;
  wire n2643;
  wire n2644;
  wire n2645;
  wire n2646;
  wire n2647;
  wire n2648;
  wire n2649;
  wire n2650;
  wire n2651;
  wire n2652;
  wire n2653;
  wire n2654;
  wire n2655;
  wire n2656;
  wire n2657;
  wire n2658;
  wire n2659;
  wire n2660;
  wire n2661;
  wire n2662;
  wire n2663;
  wire n2664;
  wire n2665;
  wire n2666;
  wire n2667;
  wire n2668;
  wire n2669;
  wire n2670;
  wire n2671;
  wire n2672;
  wire n2673;
  wire n2674;
  wire n2675;
  wire n2676;
  wire n2677;
  wire n2678;
  wire n2679;
  wire n2680;
  wire n2681;
  wire n2682;
  wire n2683;
  wire n2684;
  wire n2685;
  wire n2686;
  wire n2687;
  wire n2688;
  wire n2689;
  wire n2690;
  wire n2691;
  wire n2692;
  wire n2693;
  wire n2694;
  wire n2695;
  wire n2696;
  wire n2697;
  wire n2698;
  wire n2699;
  wire n2700;
  wire n2701;
  wire n2702;
  wire n2703;
  wire n2704;
  wire n2705;
  wire n2706;
  wire n2707;
  wire n2708;
  wire n2709;
  wire [17:0] n2710;
  assign egout = n2602; //(module output)
  assign ss_rdata = n2596; //(module output)
  assign ss_initialized = n2599; //(module output)
  /*# sim_rtl/envelopegenerator.vhd:117:12 */
  assign rslot = n2603; // (signal)
  /*# sim_rtl/envelopegenerator.vhd:118:12 */
  assign memin = n2606; // (signal)
  /*# sim_rtl/envelopegenerator.vhd:119:12 */
  assign memout = u_envelope_memory_n2056; // (signal)
  /*# sim_rtl/envelopegenerator.vhd:120:12 */
  assign memwr = n2607; // (signal)
  /*# sim_rtl/envelopegenerator.vhd:122:12 */
  assign aridx = n2610; // (signal)
  /*# sim_rtl/envelopegenerator.vhd:123:12 */
  assign ardata = u_attack_table_n2047; // (signal)
  /*# sim_rtl/envelopegenerator.vhd:124:12 */
  always @*
    ss_local_data = n2611; // (isignal)
  initial
    ss_local_data = 32'b00000000000000000000000000000000;
  /*# sim_rtl/envelopegenerator.vhd:125:12 */
  assign ss_u_envelope_memory_data = u_envelope_memory_n2057; // (signal)
  /*# sim_rtl/envelopegenerator.vhd:126:12 */
  assign ss_u_envelope_memory_ready = u_envelope_memory_n2058; // (signal)
  /*# sim_rtl/envelopegenerator.vhd:127:12 */
  assign ss_u_attack_table_data = u_attack_table_n2048; // (signal)
  /*# sim_rtl/envelopegenerator.vhd:128:12 */
  assign ss_u_attack_table_ready = u_attack_table_n2049; // (signal)
  /*# sim_rtl/envelopegenerator.vhd:133:5 */
  attacktable_Brtl u_attack_table (
    .clk(clk),
    .clkena(clkena),
    .addr(aridx),
    .ss_hold(ss_hold),
    .ss_addr(ss_addr),
    .ss_read(ss_read),
    .ss_write(ss_write),
    .ss_wdata(ss_wdata),
    .data(u_attack_table_n2047),
    .ss_rdata(u_attack_table_n2048),
    .ss_initialized(u_attack_table_n2049));
  /*# sim_rtl/envelopegenerator.vhd:150:21 */
  assign u_envelope_memory_n2056 = n2061; // (signal)
  /*# sim_rtl/envelopegenerator.vhd:142:5 */
  envelopememory_Brtl u_envelope_memory (
    .clk(clk),
    .reset(reset),
    .waddr(slot),
    .wr(memwr),
    .\wdata[state] (n2059),
    .\wdata[phase] (n2060),
    .raddr(rslot),
    .ss_hold(ss_hold),
    .ss_addr(ss_addr),
    .ss_read(ss_read),
    .ss_write(ss_write),
    .ss_wdata(ss_wdata),
    .\rdata[state] (\u_envelope_memory.rdata[state] ),
    .\rdata[phase] (\u_envelope_memory.rdata[phase] ),
    .ss_rdata(u_envelope_memory_n2057),
    .ss_initialized(u_envelope_memory_n2058));
  /*# sim_rtl/envelopegenerator.vhd:142:5 */
  assign n2059 = memin[1:0]; // extract
  /*# sim_rtl/envelopegenerator.vhd:142:5 */
  assign n2060 = memin[24:2]; // extract
  /*# sim_rtl/envelopegenerator.vhd:142:5 */
  assign n2061 = {\u_envelope_memory.rdata[phase] , \u_envelope_memory.rdata[state] };
  /*# sim_rtl/envelopegenerator.vhd:159:18 */
  always @*
    n2068_lastkey = n2612; // (isignal)
  initial
    n2068_lastkey = 18'bX;
  /*# sim_rtl/envelopegenerator.vhd:160:18 */
  always @*
    n2068_rm = n2614; // (isignal)
  initial
    n2068_rm = 5'bX;
  /*# sim_rtl/envelopegenerator.vhd:161:18 */
  always @*
    n2068_egtmp = n2618; // (isignal)
  initial
    n2068_egtmp = 15'bX;
  /*# sim_rtl/envelopegenerator.vhd:162:18 */
  always @*
    n2068_amphase = n2619; // (isignal)
  initial
    n2068_amphase = 20'bX;
  /*# sim_rtl/envelopegenerator.vhd:163:18 */
  always @*
    n2068_egphase = n2620; // (isignal)
  initial
    n2068_egphase = 23'bX;
  /*# sim_rtl/envelopegenerator.vhd:164:18 */
  always @*
    n2068_egstate = n2621; // (isignal)
  initial
    n2068_egstate = 2'bX;
  /*# sim_rtl/envelopegenerator.vhd:166:18 */
  always @*
    n2068_ntable = n2622; // (isignal)
  initial
    n2068_ntable = 18'bX;
  /*# sim_rtl/envelopegenerator.vhd:196:17 */
  assign n2091 = n2068_egphase[21:0]; // extract
  /*# sim_rtl/envelopegenerator.vhd:198:33 */
  assign n2092 = ss_read | ss_write;
  /*# sim_rtl/envelopegenerator.vhd:198:16 */
  assign n2093 = n2092 & ss_hold;
  /*# sim_rtl/vm2413.vhd:215:17 */
  assign n2099 = memin[1:0]; // extract
  /*# sim_rtl/vm2413.vhd:215:30 */
  assign n2100 = memin[24:2]; // extract
  /*# sim_rtl/vm2413.vhd:215:23 */
  assign n2101 = {n2099, n2100};
  /*# sim_rtl/envelopegenerator.vhd:210:6 */
  assign n2102 = {24'b0, ss_addr};  // uext
  /*# sim_rtl/envelopegenerator.vhd:211:1 */
  assign n2104 = n2102 == 32'b00000000000000000000000001010110;
  /*# sim_rtl/envelopegenerator.vhd:215:1 */
  assign n2106 = n2102 == 32'b00000000000000000000000001010111;
  /*# sim_rtl/envelopegenerator.vhd:218:1 */
  assign n2108 = n2102 == 32'b00000000000000000000000001011000;
  /*# sim_rtl/envelopegenerator.vhd:220:1 */
  assign n2110 = n2102 == 32'b00000000000000000000000001011001;
  /*# sim_rtl/envelopegenerator.vhd:223:1 */
  assign n2112 = n2102 == 32'b00000000000000000000000001011010;
  /*# sim_rtl/envelopegenerator.vhd:210:1 */
  assign n2113 = {n2112, n2110, n2108, n2106, n2104};
  /*# sim_rtl/envelopegenerator.vhd:62:9 */
  assign n2114 = n2602[4:0]; // extract
  /*# sim_rtl/envelopegenerator.vhd:162:18 */
  assign n2115 = n2068_amphase[4:0]; // extract
  /*# sim_rtl/envelopegenerator.vhd:163:18 */
  assign n2116 = n2068_egphase[4:0]; // extract
  /*# sim_rtl/envelopegenerator.vhd:166:18 */
  assign n2117 = n2068_ntable[4:0]; // extract
  /*# sim_rtl/envelopegenerator.vhd:210:1 */
  always @*
    case (n2113)
      5'b10000: n2119 = n2117;
      5'b01000: n2119 = n2116;
      5'b00100: n2119 = n2115;
      5'b00010: n2119 = n2114;
      5'b00001: n2119 = rslot;
      default: n2119 = 5'b00000;
    endcase
  /*# sim_rtl/vm2413.vhd:215:23 */
  assign n2120 = n2101[7:0]; // extract
  /*# sim_rtl/envelopegenerator.vhd:62:9 */
  assign n2121 = n2602[12:5]; // extract
  /*# sim_rtl/envelopegenerator.vhd:162:18 */
  assign n2122 = n2068_amphase[12:5]; // extract
  /*# sim_rtl/envelopegenerator.vhd:163:18 */
  assign n2123 = n2068_egphase[12:5]; // extract
  /*# sim_rtl/envelopegenerator.vhd:166:18 */
  assign n2124 = n2068_ntable[12:5]; // extract
  /*# sim_rtl/envelopegenerator.vhd:210:1 */
  always @*
    case (n2113)
      5'b10000: n2126 = n2124;
      5'b01000: n2126 = n2123;
      5'b00100: n2126 = n2122;
      5'b00010: n2126 = n2121;
      5'b00001: n2126 = n2120;
      default: n2126 = 8'b00000000;
    endcase
  /*# sim_rtl/vm2413.vhd:215:23 */
  assign n2127 = n2101[12:8]; // extract
  /*# sim_rtl/envelopegenerator.vhd:159:18 */
  assign n2128 = n2068_lastkey[4:0]; // extract
  /*# sim_rtl/envelopegenerator.vhd:162:18 */
  assign n2129 = n2068_amphase[17:13]; // extract
  /*# sim_rtl/envelopegenerator.vhd:163:18 */
  assign n2130 = n2068_egphase[17:13]; // extract
  /*# sim_rtl/envelopegenerator.vhd:166:18 */
  assign n2131 = n2068_ntable[17:13]; // extract
  /*# sim_rtl/envelopegenerator.vhd:210:1 */
  always @*
    case (n2113)
      5'b10000: n2133 = n2131;
      5'b01000: n2133 = n2130;
      5'b00100: n2133 = n2129;
      5'b00010: n2133 = n2128;
      5'b00001: n2133 = n2127;
      default: n2133 = 5'b00000;
    endcase
  /*# sim_rtl/vm2413.vhd:215:23 */
  assign n2134 = n2101[14:13]; // extract
  /*# sim_rtl/envelopegenerator.vhd:159:18 */
  assign n2135 = n2068_lastkey[6:5]; // extract
  /*# sim_rtl/envelopegenerator.vhd:162:18 */
  assign n2136 = n2068_amphase[19:18]; // extract
  /*# sim_rtl/envelopegenerator.vhd:163:18 */
  assign n2137 = n2068_egphase[19:18]; // extract
  /*# sim_rtl/envelopegenerator.vhd:210:1 */
  always @*
    case (n2113)
      5'b10000: n2139 = 2'b00;
      5'b01000: n2139 = n2137;
      5'b00100: n2139 = n2136;
      5'b00010: n2139 = n2135;
      5'b00001: n2139 = n2134;
      default: n2139 = 2'b00;
    endcase
  /*# sim_rtl/vm2413.vhd:215:23 */
  assign n2140 = n2101[17:15]; // extract
  /*# sim_rtl/envelopegenerator.vhd:159:18 */
  assign n2141 = n2068_lastkey[9:7]; // extract
  /*# sim_rtl/envelopegenerator.vhd:163:18 */
  assign n2142 = n2068_egphase[22:20]; // extract
  /*# sim_rtl/envelopegenerator.vhd:210:1 */
  always @*
    case (n2113)
      5'b10000: n2144 = 3'b000;
      5'b01000: n2144 = n2142;
      5'b00100: n2144 = 3'b000;
      5'b00010: n2144 = n2141;
      5'b00001: n2144 = n2140;
      default: n2144 = 3'b000;
    endcase
  /*# sim_rtl/vm2413.vhd:215:23 */
  assign n2145 = n2101[19:18]; // extract
  /*# sim_rtl/envelopegenerator.vhd:159:18 */
  assign n2146 = n2068_lastkey[11:10]; // extract
  /*# sim_rtl/envelopegenerator.vhd:210:1 */
  always @*
    case (n2113)
      5'b10000: n2148 = 2'b00;
      5'b01000: n2148 = n2068_egstate;
      5'b00100: n2148 = 2'b00;
      5'b00010: n2148 = n2146;
      5'b00001: n2148 = n2145;
      default: n2148 = 2'b00;
    endcase
  /*# sim_rtl/vm2413.vhd:215:23 */
  assign n2149 = n2101[24:20]; // extract
  /*# sim_rtl/envelopegenerator.vhd:159:18 */
  assign n2150 = n2068_lastkey[16:12]; // extract
  /*# sim_rtl/envelopegenerator.vhd:210:1 */
  always @*
    case (n2113)
      5'b10000: n2152 = 5'b00000;
      5'b01000: n2152 = 5'b00000;
      5'b00100: n2152 = 5'b00000;
      5'b00010: n2152 = n2150;
      5'b00001: n2152 = n2149;
      default: n2152 = 5'b00000;
    endcase
  /*# sim_rtl/envelopegenerator.vhd:159:18 */
  assign n2153 = n2068_lastkey[17]; // extract
  /*# sim_rtl/envelopegenerator.vhd:210:1 */
  always @*
    case (n2113)
      5'b10000: n2155 = 1'b0;
      5'b01000: n2155 = 1'b0;
      5'b00100: n2155 = 1'b0;
      5'b00010: n2155 = n2153;
      5'b00001: n2155 = memwr;
      default: n2155 = 1'b0;
    endcase
  /*# sim_rtl/envelopegenerator.vhd:209:1 */
  assign n2156 = {n2155, n2152, n2148, n2144, n2139, n2133, n2126, n2119};
  /*# sim_rtl/envelopegenerator.vhd:209:1 */
  assign n2158 = ss_read ? n2156 : 31'b0000000000000000000000000000000;
  /*# sim_rtl/envelopegenerator.vhd:228:6 */
  assign n2159 = {24'b0, ss_addr};  // uext
  /*# sim_rtl/envelopegenerator.vhd:230:35 */
  assign n2160 = ss_wdata[4:0]; // extract
  /*# sim_rtl/vm2413.vhd:220:26 */
  assign n2167 = ss_wdata[29:28]; // extract
  /*# sim_rtl/vm2413.vhd:221:26 */
  assign n2168 = ss_wdata[27:5]; // extract
  /*# sim_rtl/vm2413.vhd:220:12 */
  assign n2169 = {n2168, n2167};
  /*# sim_rtl/envelopegenerator.vhd:234:26 */
  assign n2170 = ss_wdata[30]; // extract
  /*# sim_rtl/envelopegenerator.vhd:229:1 */
  assign n2172 = n2159 == 32'b00000000000000000000000001010110;
  /*# sim_rtl/envelopegenerator.vhd:237:36 */
  assign n2173 = ss_wdata[12:0]; // extract
  /*# sim_rtl/envelopegenerator.vhd:239:38 */
  assign n2174 = ss_wdata[30:13]; // extract
  /*# sim_rtl/envelopegenerator.vhd:236:1 */
  assign n2176 = n2159 == 32'b00000000000000000000000001010111;
  /*# sim_rtl/envelopegenerator.vhd:242:38 */
  assign n2177 = ss_wdata[19:0]; // extract
  /*# sim_rtl/envelopegenerator.vhd:241:1 */
  assign n2179 = n2159 == 32'b00000000000000000000000001011000;
  /*# sim_rtl/envelopegenerator.vhd:245:38 */
  assign n2180 = ss_wdata[22:0]; // extract
  /*# sim_rtl/envelopegenerator.vhd:247:37 */
  assign n2181 = ss_wdata[24:23]; // extract
  /*# sim_rtl/envelopegenerator.vhd:244:1 */
  assign n2183 = n2159 == 32'b00000000000000000000000001011001;
  /*# sim_rtl/envelopegenerator.vhd:250:37 */
  assign n2184 = ss_wdata[17:0]; // extract
  /*# sim_rtl/envelopegenerator.vhd:249:1 */
  assign n2186 = n2159 == 32'b00000000000000000000000001011010;
  /*# sim_rtl/envelopegenerator.vhd:228:1 */
  assign n2187 = {n2186, n2183, n2179, n2176, n2172};
  /*# sim_rtl/envelopegenerator.vhd:228:1 */
  always @*
    case (n2187)
      5'b10000: n2188 = n2602;
      5'b01000: n2188 = n2602;
      5'b00100: n2188 = n2602;
      5'b00010: n2188 = n2173;
      5'b00001: n2188 = n2602;
      default: n2188 = n2602;
    endcase
  /*# sim_rtl/envelopegenerator.vhd:228:1 */
  always @*
    case (n2187)
      5'b10000: n2189 = rslot;
      5'b01000: n2189 = rslot;
      5'b00100: n2189 = rslot;
      5'b00010: n2189 = rslot;
      5'b00001: n2189 = n2160;
      default: n2189 = rslot;
    endcase
  /*# sim_rtl/envelopegenerator.vhd:228:1 */
  always @*
    case (n2187)
      5'b10000: n2190 = memin;
      5'b01000: n2190 = memin;
      5'b00100: n2190 = memin;
      5'b00010: n2190 = memin;
      5'b00001: n2190 = n2169;
      default: n2190 = memin;
    endcase
  /*# sim_rtl/envelopegenerator.vhd:228:1 */
  always @*
    case (n2187)
      5'b10000: n2191 = memwr;
      5'b01000: n2191 = memwr;
      5'b00100: n2191 = memwr;
      5'b00010: n2191 = memwr;
      5'b00001: n2191 = n2170;
      default: n2191 = memwr;
    endcase
  /*# sim_rtl/envelopegenerator.vhd:228:1 */
  always @*
    case (n2187)
      5'b10000: n2192 = n2068_lastkey;
      5'b01000: n2192 = n2068_lastkey;
      5'b00100: n2192 = n2068_lastkey;
      5'b00010: n2192 = n2174;
      5'b00001: n2192 = n2068_lastkey;
      default: n2192 = n2068_lastkey;
    endcase
  /*# sim_rtl/envelopegenerator.vhd:228:1 */
  always @*
    case (n2187)
      5'b10000: n2193 = n2068_amphase;
      5'b01000: n2193 = n2068_amphase;
      5'b00100: n2193 = n2177;
      5'b00010: n2193 = n2068_amphase;
      5'b00001: n2193 = n2068_amphase;
      default: n2193 = n2068_amphase;
    endcase
  /*# sim_rtl/envelopegenerator.vhd:228:1 */
  always @*
    case (n2187)
      5'b10000: n2194 = n2068_egphase;
      5'b01000: n2194 = n2180;
      5'b00100: n2194 = n2068_egphase;
      5'b00010: n2194 = n2068_egphase;
      5'b00001: n2194 = n2068_egphase;
      default: n2194 = n2068_egphase;
    endcase
  /*# sim_rtl/envelopegenerator.vhd:228:1 */
  always @*
    case (n2187)
      5'b10000: n2195 = n2068_egstate;
      5'b01000: n2195 = n2181;
      5'b00100: n2195 = n2068_egstate;
      5'b00010: n2195 = n2068_egstate;
      5'b00001: n2195 = n2068_egstate;
      default: n2195 = n2068_egstate;
    endcase
  /*# sim_rtl/envelopegenerator.vhd:228:1 */
  always @*
    case (n2187)
      5'b10000: n2196 = n2184;
      5'b01000: n2196 = n2068_ntable;
      5'b00100: n2196 = n2068_ntable;
      5'b00010: n2196 = n2068_ntable;
      5'b00001: n2196 = n2068_ntable;
      default: n2196 = n2068_ntable;
    endcase
  /*# sim_rtl/envelopegenerator.vhd:198:1 */
  assign n2206 = n2224 ? n2188 : n2602;
  /*# sim_rtl/envelopegenerator.vhd:198:1 */
  assign n2207 = n2225 ? n2189 : rslot;
  /*# sim_rtl/envelopegenerator.vhd:198:1 */
  assign n2208 = n2226 ? n2190 : memin;
  /*# sim_rtl/envelopegenerator.vhd:198:1 */
  assign n2209 = n2227 ? n2191 : memwr;
  /*# sim_rtl/envelopegenerator.vhd:198:1 */
  assign n2210 = n2228 ? n2192 : n2068_lastkey;
  /*# sim_rtl/envelopegenerator.vhd:198:1 */
  assign n2211 = n2229 ? n2193 : n2068_amphase;
  /*# sim_rtl/envelopegenerator.vhd:198:1 */
  assign n2212 = n2230 ? n2194 : n2068_egphase;
  /*# sim_rtl/envelopegenerator.vhd:198:1 */
  assign n2213 = n2231 ? n2195 : n2068_egstate;
  /*# sim_rtl/envelopegenerator.vhd:198:1 */
  assign n2214 = n2232 ? n2196 : n2068_ntable;
  /*# sim_rtl/envelopegenerator.vhd:198:1 */
  assign n2224 = ss_write & n2093;
  /*# sim_rtl/envelopegenerator.vhd:198:1 */
  assign n2225 = ss_write & n2093;
  /*# sim_rtl/envelopegenerator.vhd:198:1 */
  assign n2226 = ss_write & n2093;
  /*# sim_rtl/envelopegenerator.vhd:198:1 */
  assign n2227 = ss_write & n2093;
  /*# sim_rtl/envelopegenerator.vhd:198:1 */
  assign n2228 = ss_write & n2093;
  /*# sim_rtl/envelopegenerator.vhd:198:1 */
  assign n2229 = ss_write & n2093;
  /*# sim_rtl/envelopegenerator.vhd:198:1 */
  assign n2230 = ss_write & n2093;
  /*# sim_rtl/envelopegenerator.vhd:198:1 */
  assign n2231 = ss_write & n2093;
  /*# sim_rtl/envelopegenerator.vhd:198:1 */
  assign n2232 = ss_write & n2093;
  /*# sim_rtl/envelopegenerator.vhd:198:1 */
  assign n2243 = n2093 ? n2158 : 31'b0000000000000000000000000000000;
  /*# sim_rtl/envelopegenerator.vhd:177:10 */
  assign n2245 = n2244[31]; // extract
  /*# sim_rtl/envelopegenerator.vhd:177:10 */
  assign n2246 = {n2245, n2243};
  /*# sim_rtl/envelopegenerator.vhd:257:11 */
  assign n2247 = ~ss_hold;
  /*# sim_rtl/envelopegenerator.vhd:260:27 */
  assign n2249 = stage == 2'b10;
  /*# sim_rtl/envelopegenerator.vhd:261:30 */
  assign n2251 = slot == 5'b10001;
  /*# sim_rtl/envelopegenerator.vhd:264:39 */
  assign n2253 = slot + 5'b00001;
  /*# sim_rtl/envelopegenerator.vhd:261:21 */
  assign n2255 = n2251 ? 5'b00000 : n2253;
  /*# sim_rtl/envelopegenerator.vhd:257:1 */
  assign n2256 = n2525 ? n2255 : n2207;
  /*# sim_rtl/envelopegenerator.vhd:259:13 */
  assign n2257 = n2249 & clkena;
  /*# sim_rtl/envelopegenerator.vhd:275:50 */
  assign n2258 = n2214[16:0]; // extract
  /*# sim_rtl/envelopegenerator.vhd:166:18 */
  assign n2259 = n2214[0]; // extract
  /*# sim_rtl/envelopegenerator.vhd:166:18 */
  assign n2260 = {n2258, n2259};
  /*# sim_rtl/envelopegenerator.vhd:276:50 */
  assign n2261 = n2260[17]; // extract
  /*# sim_rtl/envelopegenerator.vhd:166:18 */
  assign n2262 = n2214[0]; // extract
  /*# sim_rtl/envelopegenerator.vhd:166:18 */
  assign n2263 = {n2258, n2262};
  /*# sim_rtl/envelopegenerator.vhd:276:67 */
  assign n2264 = n2263[14]; // extract
  /*# sim_rtl/envelopegenerator.vhd:276:57 */
  assign n2265 = n2261 ^ n2264;
  /*# sim_rtl/envelopegenerator.vhd:279:36 */
  assign n2268 = n2211 + 20'b00000000000000000001;
  /*# sim_rtl/envelopegenerator.vhd:280:27 */
  assign n2269 = n2268[19:15]; // extract
  /*# sim_rtl/envelopegenerator.vhd:280:64 */
  assign n2271 = n2269 == 5'b11111;
  /*# sim_rtl/envelopegenerator.vhd:162:18 */
  assign n2273 = n2268[19:15]; // extract
  /*# sim_rtl/envelopegenerator.vhd:280:17 */
  assign n2274 = n2271 ? 5'b00001 : n2273;
  /*# sim_rtl/envelopegenerator.vhd:162:18 */
  assign n2275 = n2268[14:0]; // extract
  /*# sim_rtl/envelopegenerator.vhd:284:26 */
  assign n2277 = stage == 2'b00;
  /*# sim_rtl/envelopegenerator.vhd:285:39 */
  assign n2278 = memout[1:0]; // extract
  /*# sim_rtl/envelopegenerator.vhd:286:39 */
  assign n2279 = memout[24:2]; // extract
  /*# sim_rtl/envelopegenerator.vhd:288:29 */
  assign n2281 = stage == 2'b01;
  /*# sim_rtl/envelopegenerator.vhd:291:29 */
  assign n2283 = stage == 2'b10;
  /*# sim_rtl/envelopegenerator.vhd:294:38 */
  assign n2285 = {1'b0, ar};
  /*# sim_rtl/envelopegenerator.vhd:295:43 */
  assign n2287 = {2'b00, tl};
  /*# sim_rtl/envelopegenerator.vhd:295:46 */
  assign n2289 = {n2287, 6'b000000};
  /*# sim_rtl/envelopegenerator.vhd:295:64 */
  assign n2291 = {2'b00, ardata};
  /*# sim_rtl/envelopegenerator.vhd:295:57 */
  assign n2292 = n2289 + n2291;
  /*# sim_rtl/envelopegenerator.vhd:293:25 */
  assign n2294 = n2213 == 2'b01;
  /*# sim_rtl/envelopegenerator.vhd:297:38 */
  assign n2296 = {1'b0, dr};
  /*# sim_rtl/envelopegenerator.vhd:298:43 */
  assign n2298 = {2'b00, tl};
  /*# sim_rtl/envelopegenerator.vhd:298:46 */
  assign n2300 = {n2298, 6'b000000};
  /*# sim_rtl/envelopegenerator.vhd:298:72 */
  assign n2301 = n2212[21:9]; // extract
  /*# sim_rtl/envelopegenerator.vhd:298:64 */
  assign n2303 = {2'b00, n2301};
  /*# sim_rtl/envelopegenerator.vhd:298:57 */
  assign n2304 = n2300 + n2303;
  /*# sim_rtl/envelopegenerator.vhd:296:25 */
  assign n2306 = n2213 == 2'b10;
  /*# sim_rtl/envelopegenerator.vhd:300:38 */
  assign n2308 = {1'b0, rr};
  /*# sim_rtl/envelopegenerator.vhd:301:43 */
  assign n2310 = {2'b00, tl};
  /*# sim_rtl/envelopegenerator.vhd:301:46 */
  assign n2312 = {n2310, 6'b000000};
  /*# sim_rtl/envelopegenerator.vhd:301:72 */
  assign n2313 = n2212[21:9]; // extract
  /*# sim_rtl/envelopegenerator.vhd:301:64 */
  assign n2315 = {2'b00, n2313};
  /*# sim_rtl/envelopegenerator.vhd:301:57 */
  assign n2316 = n2312 + n2315;
  /*# sim_rtl/envelopegenerator.vhd:299:25 */
  assign n2318 = n2213 == 2'b11;
  /*# sim_rtl/envelopegenerator.vhd:302:25 */
  assign n2322 = n2213 == 2'b00;
  /*# sim_rtl/envelopegenerator.vhd:292:21 */
  assign n2323 = {n2322, n2318, n2306, n2294};
  /*# sim_rtl/envelopegenerator.vhd:292:21 */
  always @*
    case (n2323)
      4'b1000: n2324 = n2068_rm;
      4'b0100: n2324 = n2308;
      4'b0010: n2324 = n2296;
      4'b0001: n2324 = n2285;
      default: n2324 = n2068_rm;
    endcase
  /*# sim_rtl/envelopegenerator.vhd:295:57 */
  assign n2325 = n2292[12:0]; // extract
  /*# sim_rtl/envelopegenerator.vhd:298:57 */
  assign n2326 = n2304[12:0]; // extract
  /*# sim_rtl/envelopegenerator.vhd:301:57 */
  assign n2327 = n2316[12:0]; // extract
  /*# sim_rtl/envelopegenerator.vhd:161:18 */
  assign n2328 = n2068_egtmp[12:0]; // extract
  /*# sim_rtl/envelopegenerator.vhd:292:21 */
  always @*
    case (n2323)
      4'b1000: n2329 = 13'b1111111111111;
      4'b0100: n2329 = n2327;
      4'b0010: n2329 = n2326;
      4'b0001: n2329 = n2325;
      default: n2329 = n2328;
    endcase
  /*# sim_rtl/envelopegenerator.vhd:295:57 */
  assign n2330 = n2292[14:13]; // extract
  /*# sim_rtl/envelopegenerator.vhd:298:57 */
  assign n2331 = n2304[14:13]; // extract
  /*# sim_rtl/envelopegenerator.vhd:301:57 */
  assign n2332 = n2316[14:13]; // extract
  /*# sim_rtl/envelopegenerator.vhd:161:18 */
  assign n2333 = n2068_egtmp[14:13]; // extract
  /*# sim_rtl/envelopegenerator.vhd:292:21 */
  always @*
    case (n2323)
      4'b1000: n2334 = 2'b00;
      4'b0100: n2334 = n2332;
      4'b0010: n2334 = n2331;
      4'b0001: n2334 = n2330;
      default: n2334 = n2333;
    endcase
  /*# sim_rtl/envelopegenerator.vhd:166:18 */
  assign n2335 = {n2258, n2265};
  /*# sim_rtl/envelopegenerator.vhd:308:30 */
  assign n2336 = n2335[0]; // extract
  /*# sim_rtl/envelopegenerator.vhd:308:42 */
  assign n2337 = {27'b0, slot};  // uext
  /*# sim_rtl/envelopegenerator.vhd:308:60 */
  assign n2339 = $signed(n2337) / $signed(32'b00000000000000000000000000000010); // sdiv
  /*# sim_rtl/envelopegenerator.vhd:308:63 */
  assign n2341 = n2339 == 32'b00000000000000000000000000000111;
  /*# sim_rtl/envelopegenerator.vhd:308:38 */
  assign n2342 = n2341 & n2336;
  /*# sim_rtl/envelopegenerator.vhd:308:67 */
  assign n2343 = rhythm & n2342;
  /*# sim_rtl/envelopegenerator.vhd:161:18 */
  assign n2344 = {n2334, n2329};
  /*# sim_rtl/envelopegenerator.vhd:309:40 */
  assign n2346 = n2344 + 15'b010000000000000;
  /*# sim_rtl/envelopegenerator.vhd:161:18 */
  assign n2347 = {n2334, n2329};
  /*# sim_rtl/envelopegenerator.vhd:308:21 */
  assign n2348 = n2343 ? n2346 : n2347;
  /*# sim_rtl/envelopegenerator.vhd:162:18 */
  assign n2349 = {n2274, n2275};
  /*# sim_rtl/envelopegenerator.vhd:314:36 */
  assign n2350 = n2349[19]; // extract
  /*# sim_rtl/envelopegenerator.vhd:314:51 */
  assign n2351 = ~n2350;
  /*# sim_rtl/envelopegenerator.vhd:162:18 */
  assign n2352 = {n2274, n2275};
  /*# sim_rtl/envelopegenerator.vhd:316:63 */
  assign n2353 = n2352[18:9]; // extract
  /*# sim_rtl/envelopegenerator.vhd:316:103 */
  assign n2355 = n2353 - 10'b0001000000;
  /*# sim_rtl/envelopegenerator.vhd:316:54 */
  assign n2357 = {5'b00000, n2355};
  /*# sim_rtl/envelopegenerator.vhd:316:44 */
  assign n2358 = n2348 + n2357;
  /*# sim_rtl/envelopegenerator.vhd:162:18 */
  assign n2359 = {n2274, n2275};
  /*# sim_rtl/envelopegenerator.vhd:319:76 */
  assign n2360 = n2359[18:9]; // extract
  /*# sim_rtl/envelopegenerator.vhd:319:68 */
  assign n2362 = 10'b1111000000 - n2360;
  /*# sim_rtl/envelopegenerator.vhd:319:54 */
  assign n2364 = {5'b00000, n2362};
  /*# sim_rtl/envelopegenerator.vhd:319:44 */
  assign n2365 = n2348 + n2364;
  /*# sim_rtl/envelopegenerator.vhd:314:25 */
  assign n2366 = n2351 ? n2358 : n2365;
  /*# sim_rtl/envelopegenerator.vhd:313:21 */
  assign n2367 = am ? n2366 : n2348;
  /*# sim_rtl/envelopegenerator.vhd:324:29 */
  assign n2368 = n2367[14:13]; // extract
  /*# sim_rtl/envelopegenerator.vhd:324:62 */
  assign n2370 = n2368 == 2'b00;
  /*# sim_rtl/envelopegenerator.vhd:325:39 */
  assign n2371 = n2367[12:0]; // extract
  /*# sim_rtl/envelopegenerator.vhd:324:21 */
  assign n2373 = n2370 ? n2371 : 13'b1111111111111;
  /*# sim_rtl/envelopegenerator.vhd:330:27 */
  assign n2375 = n2324 != 5'b00000;
  /*# sim_rtl/envelopegenerator.vhd:332:39 */
  assign n2376 = rks[3:2]; // extract
  /*# sim_rtl/envelopegenerator.vhd:332:34 */
  assign n2377 = {3'b0, n2376};  // uext
  /*# sim_rtl/envelopegenerator.vhd:332:34 */
  assign n2378 = n2324 + n2377;
  /*# sim_rtl/envelopegenerator.vhd:333:30 */
  assign n2379 = n2378[4]; // extract
  /*# sim_rtl/envelopegenerator.vhd:160:18 */
  assign n2381 = n2378[3:0]; // extract
  /*# sim_rtl/envelopegenerator.vhd:333:25 */
  assign n2382 = n2379 ? 4'b1111 : n2381;
  /*# sim_rtl/envelopegenerator.vhd:160:18 */
  assign n2383 = n2378[4]; // extract
  /*# sim_rtl/envelopegenerator.vhd:340:71 */
  assign n2385 = rks[1:0]; // extract
  /*# sim_rtl/envelopegenerator.vhd:340:67 */
  assign n2387 = {1'b1, n2385};
  /*# sim_rtl/envelopegenerator.vhd:340:61 */
  assign n2390 = {3'b0, n2387};  // uext
  /*# sim_rtl/envelopegenerator.vhd:340:61 */
  assign n2391 = 6'b000110 * n2390; // umul
  /*# sim_rtl/envelopegenerator.vhd:165:18 */
  assign n2392 = n2384[17:1]; // extract
  /*# sim_rtl/envelopegenerator.vhd:160:18 */
  assign n2393 = {n2383, n2382};
  /*# sim_rtl/envelopegenerator.vhd:341:58 */
  assign n2394 = n2393[3:0]; // extract
  /*# sim_rtl/envelopegenerator.vhd:165:18 */
  assign n2395 = {n2392, n2391};
  /*# sim_rtl/envelopegenerator.vhd:341:43 */
  assign n2396 = n2395 << n2394;
  /*# sim_rtl/envelopegenerator.vhd:342:52 */
  assign n2397 = n2212 - n2396;
  /*# sim_rtl/envelopegenerator.vhd:338:29 */
  assign n2399 = n2213 == 2'b01;
  /*# sim_rtl/envelopegenerator.vhd:345:62 */
  assign n2401 = rks[1:0]; // extract
  /*# sim_rtl/envelopegenerator.vhd:345:58 */
  assign n2403 = {1'b1, n2401};
  /*# sim_rtl/envelopegenerator.vhd:160:18 */
  assign n2404 = {n2383, n2382};
  /*# sim_rtl/envelopegenerator.vhd:346:58 */
  assign n2405 = n2404[3:0]; // extract
  /*# sim_rtl/envelopegenerator.vhd:346:71 */
  assign n2408 = n2405 - 4'b0001;
  /*# sim_rtl/envelopegenerator.vhd:165:18 */
  assign n2409 = {20'b00000000000000000000, n2403};
  /*# sim_rtl/envelopegenerator.vhd:346:44 */
  assign n2410 = n2409 << n2408;
  /*# sim_rtl/envelopegenerator.vhd:347:52 */
  assign n2411 = n2212 + n2410;
  /*# sim_rtl/envelopegenerator.vhd:343:29 */
  assign n2413 = n2213 == 2'b10;
  /*# sim_rtl/envelopegenerator.vhd:343:40 */
  assign n2415 = n2213 == 2'b11;
  /*# sim_rtl/envelopegenerator.vhd:343:40 */
  assign n2416 = n2413 | n2415;
  /*# sim_rtl/envelopegenerator.vhd:348:29 */
  assign n2418 = n2213 == 2'b00;
  /*# sim_rtl/envelopegenerator.vhd:337:25 */
  assign n2419 = {n2418, n2416, n2399};
  /*# sim_rtl/envelopegenerator.vhd:337:25 */
  always @*
    case (n2419)
      3'b100: n2420 = n2212;
      3'b010: n2420 = n2411;
      3'b001: n2420 = n2397;
      default: n2420 = n2212;
    endcase
  /*# sim_rtl/envelopegenerator.vhd:330:21 */
  assign n2422 = {n2383, n2382};
  /*# sim_rtl/envelopegenerator.vhd:330:21 */
  assign n2423 = n2375 ? n2422 : n2324;
  /*# sim_rtl/envelopegenerator.vhd:330:21 */
  assign n2424 = n2375 ? n2420 : n2212;
  /*# sim_rtl/envelopegenerator.vhd:356:39 */
  assign n2426 = n2424[22]; // extract
  /*# sim_rtl/envelopegenerator.vhd:356:29 */
  assign n2428 = n2426 ? 23'b00000000000000000000000 : n2424;
  /*# sim_rtl/envelopegenerator.vhd:356:29 */
  assign n2430 = n2426 ? 2'b10 : n2213;
  /*# sim_rtl/envelopegenerator.vhd:355:25 */
  assign n2432 = n2213 == 2'b01;
  /*# sim_rtl/envelopegenerator.vhd:361:39 */
  assign n2433 = n2424[22:18]; // extract
  /*# sim_rtl/envelopegenerator.vhd:361:82 */
  assign n2435 = {1'b0, sl};
  /*# sim_rtl/envelopegenerator.vhd:361:76 */
  assign n2436 = $unsigned(n2433) >= $unsigned(n2435);
  /*# sim_rtl/envelopegenerator.vhd:361:29 */
  assign n2438 = n2436 ? 2'b11 : n2213;
  /*# sim_rtl/envelopegenerator.vhd:360:25 */
  assign n2440 = n2213 == 2'b10;
  /*# sim_rtl/envelopegenerator.vhd:365:40 */
  assign n2441 = n2424[22:18]; // extract
  /*# sim_rtl/envelopegenerator.vhd:365:77 */
  assign n2443 = $unsigned(n2441) >= $unsigned(5'b01111);
  /*# sim_rtl/envelopegenerator.vhd:365:29 */
  assign n2445 = n2443 ? 2'b00 : n2213;
  /*# sim_rtl/envelopegenerator.vhd:364:25 */
  assign n2447 = n2213 == 2'b11;
  /*# sim_rtl/envelopegenerator.vhd:368:25 */
  assign n2449 = n2213 == 2'b00;
  /*# sim_rtl/envelopegenerator.vhd:354:21 */
  assign n2450 = {n2449, n2447, n2440, n2432};
  /*# sim_rtl/envelopegenerator.vhd:354:21 */
  always @*
    case (n2450)
      4'b1000: n2452 = 23'b11111111111111111111111;
      4'b0100: n2452 = n2424;
      4'b0010: n2452 = n2424;
      4'b0001: n2452 = n2428;
      default: n2452 = n2424;
    endcase
  /*# sim_rtl/envelopegenerator.vhd:354:21 */
  always @*
    case (n2450)
      4'b1000: n2453 = n2213;
      4'b0100: n2453 = n2445;
      4'b0010: n2453 = n2438;
      4'b0001: n2453 = n2430;
      default: n2453 = n2213;
    endcase
  /*# sim_rtl/envelopegenerator.vhd:372:52 */
  assign n2457 = ~n2625;
  /*# sim_rtl/envelopegenerator.vhd:372:58 */
  assign n2458 = key & n2457;
  /*# sim_rtl/envelopegenerator.vhd:376:69 */
  assign n2464 = ~key;
  /*# sim_rtl/envelopegenerator.vhd:376:61 */
  assign n2465 = n2464 & n2628;
  /*# sim_rtl/envelopegenerator.vhd:376:87 */
  assign n2467 = n2453 != 2'b00;
  /*# sim_rtl/envelopegenerator.vhd:376:75 */
  assign n2468 = n2467 & n2465;
  /*# sim_rtl/envelopegenerator.vhd:376:21 */
  assign n2470 = n2468 ? 2'b11 : n2453;
  /*# sim_rtl/envelopegenerator.vhd:372:21 */
  assign n2471 = {1'b0, 22'b1111111111111111111111};
  /*# sim_rtl/envelopegenerator.vhd:372:21 */
  assign n2472 = n2458 ? n2471 : n2452;
  /*# sim_rtl/envelopegenerator.vhd:372:21 */
  assign n2474 = n2458 ? 2'b01 : n2470;
  /*# sim_rtl/envelopegenerator.vhd:382:30 */
  assign n2478 = {n2472, n2474};
  /*# sim_rtl/envelopegenerator.vhd:384:29 */
  assign n2480 = stage == 2'b11;
  /*# sim_rtl/envelopegenerator.vhd:384:17 */
  assign n2482 = n2480 ? 1'b0 : n2209;
  /*# sim_rtl/envelopegenerator.vhd:291:17 */
  assign n2483 = n2283 ? n2373 : n2206;
  /*# sim_rtl/envelopegenerator.vhd:291:17 */
  assign n2484 = n2283 ? n2478 : n2208;
  /*# sim_rtl/envelopegenerator.vhd:291:17 */
  assign n2486 = n2283 ? 1'b1 : n2482;
  /*# sim_rtl/envelopegenerator.vhd:291:17 */
  assign n2487 = n2283 ? n2710 : n2210;
  /*# sim_rtl/envelopegenerator.vhd:291:17 */
  assign n2488 = n2283 ? n2423 : n2068_rm;
  /*# sim_rtl/envelopegenerator.vhd:291:17 */
  assign n2489 = n2283 ? n2367 : n2068_egtmp;
  /*# sim_rtl/envelopegenerator.vhd:291:17 */
  assign n2490 = n2283 ? n2472 : n2212;
  /*# sim_rtl/envelopegenerator.vhd:291:17 */
  assign n2491 = n2283 ? n2474 : n2213;
  /*# sim_rtl/envelopegenerator.vhd:288:17 */
  assign n2493 = n2281 ? n2206 : n2483;
  /*# sim_rtl/envelopegenerator.vhd:288:17 */
  assign n2494 = n2281 ? n2208 : n2484;
  /*# sim_rtl/envelopegenerator.vhd:288:17 */
  assign n2495 = n2281 ? n2209 : n2486;
  /*# sim_rtl/envelopegenerator.vhd:288:17 */
  assign n2496 = n2281 ? n2210 : n2487;
  /*# sim_rtl/envelopegenerator.vhd:288:17 */
  assign n2497 = n2281 ? n2068_rm : n2488;
  /*# sim_rtl/envelopegenerator.vhd:288:17 */
  assign n2498 = n2281 ? n2068_egtmp : n2489;
  /*# sim_rtl/envelopegenerator.vhd:288:17 */
  assign n2499 = n2281 ? n2212 : n2490;
  /*# sim_rtl/envelopegenerator.vhd:288:17 */
  assign n2500 = n2281 ? n2213 : n2491;
  /*# sim_rtl/envelopegenerator.vhd:284:17 */
  assign n2502 = n2277 ? n2206 : n2493;
  /*# sim_rtl/envelopegenerator.vhd:284:17 */
  assign n2503 = n2277 ? n2208 : n2494;
  /*# sim_rtl/envelopegenerator.vhd:284:17 */
  assign n2504 = n2277 ? n2209 : n2495;
  /*# sim_rtl/envelopegenerator.vhd:284:17 */
  assign n2505 = n2277 ? n2210 : n2496;
  /*# sim_rtl/envelopegenerator.vhd:284:17 */
  assign n2506 = n2277 ? n2068_rm : n2497;
  /*# sim_rtl/envelopegenerator.vhd:284:17 */
  assign n2507 = n2277 ? n2068_egtmp : n2498;
  /*# sim_rtl/envelopegenerator.vhd:284:17 */
  assign n2508 = n2277 ? n2279 : n2499;
  /*# sim_rtl/envelopegenerator.vhd:284:17 */
  assign n2509 = n2277 ? n2278 : n2500;
  /*# sim_rtl/envelopegenerator.vhd:257:1 */
  assign n2511 = n2524 ? n2502 : n2206;
  /*# sim_rtl/envelopegenerator.vhd:257:1 */
  assign n2512 = n2526 ? n2503 : n2208;
  /*# sim_rtl/envelopegenerator.vhd:257:1 */
  assign n2513 = n2527 ? n2504 : n2209;
  /*# sim_rtl/envelopegenerator.vhd:257:1 */
  assign n2514 = n2528 ? n2505 : n2210;
  /*# sim_rtl/envelopegenerator.vhd:273:13 */
  assign n2517 = {n2274, n2275};
  /*# sim_rtl/envelopegenerator.vhd:257:1 */
  assign n2518 = n2531 ? n2517 : n2211;
  /*# sim_rtl/envelopegenerator.vhd:257:1 */
  assign n2519 = n2532 ? n2508 : n2212;
  /*# sim_rtl/envelopegenerator.vhd:257:1 */
  assign n2520 = n2533 ? n2509 : n2213;
  /*# sim_rtl/envelopegenerator.vhd:273:13 */
  assign n2522 = {n2258, n2265};
  /*# sim_rtl/envelopegenerator.vhd:257:1 */
  assign n2523 = n2535 ? n2522 : n2214;
  /*# sim_rtl/envelopegenerator.vhd:257:1 */
  assign n2524 = clkena & n2247;
  /*# sim_rtl/envelopegenerator.vhd:257:1 */
  assign n2525 = n2257 & n2247;
  /*# sim_rtl/envelopegenerator.vhd:257:1 */
  assign n2526 = clkena & n2247;
  /*# sim_rtl/envelopegenerator.vhd:257:1 */
  assign n2527 = clkena & n2247;
  /*# sim_rtl/envelopegenerator.vhd:257:1 */
  assign n2528 = clkena & n2247;
  /*# sim_rtl/envelopegenerator.vhd:257:1 */
  assign n2529 = clkena & n2247;
  /*# sim_rtl/envelopegenerator.vhd:257:1 */
  assign n2530 = clkena & n2247;
  /*# sim_rtl/envelopegenerator.vhd:257:1 */
  assign n2531 = clkena & n2247;
  /*# sim_rtl/envelopegenerator.vhd:257:1 */
  assign n2532 = clkena & n2247;
  /*# sim_rtl/envelopegenerator.vhd:257:1 */
  assign n2533 = clkena & n2247;
  /*# sim_rtl/envelopegenerator.vhd:257:1 */
  assign n2535 = clkena & n2247;
  /*# sim_rtl/envelopegenerator.vhd:179:1 */
  assign n2575 = {5'b00001, 15'b000000000000000};
  /*# sim_rtl/envelopegenerator.vhd:398:27 */
  assign n2595 = ss_local_data | ss_u_envelope_memory_data;
  /*# sim_rtl/envelopegenerator.vhd:398:56 */
  assign n2596 = n2595 | ss_u_attack_table_data;
  /*# sim_rtl/envelopegenerator.vhd:399:23 */
  assign n2598 = 1'b1 & ss_u_envelope_memory_ready;
  /*# sim_rtl/envelopegenerator.vhd:399:54 */
  assign n2599 = n2598 & ss_u_attack_table_ready;
  /*# sim_rtl/envelopegenerator.vhd:62:9 */
  assign n2600 = ~reset;
  /*# sim_rtl/envelopegenerator.vhd:195:1 */
  assign n2601 = n2600 ? n2511 : n2602;
  /*# sim_rtl/envelopegenerator.vhd:195:1 */
  always @(posedge clk)
    n2602 <= n2601;
  /*# sim_rtl/envelopegenerator.vhd:195:1 */
  always @(posedge clk or posedge reset)
    if (reset)
      n2603 <= 5'b00000;
    else
      n2603 <= n2256;
  /*# sim_rtl/envelopegenerator.vhd:118:12 */
  assign n2604 = ~reset;
  /*# sim_rtl/envelopegenerator.vhd:195:1 */
  assign n2605 = n2604 ? n2512 : memin;
  /*# sim_rtl/envelopegenerator.vhd:195:1 */
  always @(posedge clk)
    n2606 <= n2605;
  /*# sim_rtl/envelopegenerator.vhd:195:1 */
  always @(posedge clk or posedge reset)
    if (reset)
      n2607 <= 1'b0;
    else
      n2607 <= n2513;
  /*# sim_rtl/envelopegenerator.vhd:122:12 */
  assign n2608 = ~reset;
  /*# sim_rtl/envelopegenerator.vhd:195:1 */
  assign n2609 = n2608 ? n2091 : aridx;
  /*# sim_rtl/envelopegenerator.vhd:195:1 */
  always @(posedge clk)
    n2610 <= n2609;
  /*# sim_rtl/envelopegenerator.vhd:195:1 */
  always @(posedge clk or posedge reset)
    if (reset)
      n2611 <= 32'b00000000000000000000000000000000;
    else
      n2611 <= n2246;
  /*# sim_rtl/envelopegenerator.vhd:195:1 */
  always @(posedge clk or posedge reset)
    if (reset)
      n2612 <= 18'b000000000000000000;
    else
      n2612 <= n2514;
  /*# sim_rtl/envelopegenerator.vhd:195:1 */
  assign n2613 = n2529 ? n2506 : n2068_rm;
  /*# sim_rtl/envelopegenerator.vhd:195:1 */
  always @(posedge clk or posedge reset)
    if (reset)
      n2614 <= 5'b00000;
    else
      n2614 <= n2613;
  /*# sim_rtl/envelopegenerator.vhd:161:18 */
  assign n2615 = ~reset;
  /*# sim_rtl/envelopegenerator.vhd:161:18 */
  assign n2616 = n2530 & n2615;
  /*# sim_rtl/envelopegenerator.vhd:195:1 */
  assign n2617 = n2616 ? n2507 : n2068_egtmp;
  /*# sim_rtl/envelopegenerator.vhd:195:1 */
  always @(posedge clk)
    n2618 <= n2617;
  /*# sim_rtl/envelopegenerator.vhd:195:1 */
  always @(posedge clk or posedge reset)
    if (reset)
      n2619 <= n2575;
    else
      n2619 <= n2518;
  /*# sim_rtl/envelopegenerator.vhd:195:1 */
  always @(posedge clk or posedge reset)
    if (reset)
      n2620 <= 23'b00000000000000000000000;
    else
      n2620 <= n2519;
  /*# sim_rtl/envelopegenerator.vhd:195:1 */
  always @(posedge clk or posedge reset)
    if (reset)
      n2621 <= 2'b00;
    else
      n2621 <= n2520;
  /*# sim_rtl/envelopegenerator.vhd:195:1 */
  always @(posedge clk or posedge reset)
    if (reset)
      n2622 <= 18'b111111111111111111;
    else
      n2622 <= n2523;
  /*# sim_rtl/envelopegenerator.vhd:372:32 */
  assign n2624 = {14'bX, n2210};
  /*# sim_rtl/envelopegenerator.vhd:372:32 */
  assign n2625 = n2624[slot * 1 +: 1]; //(Bmux)
  /*# sim_rtl/envelopegenerator.vhd:376:35 */
  assign n2627 = {14'bX, n2210};
  /*# sim_rtl/envelopegenerator.vhd:376:35 */
  assign n2628 = n2627[slot * 1 +: 1]; //(Bmux)
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2629 = slot[4]; // extract
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2630 = ~n2629;
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2631 = slot[3]; // extract
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2632 = ~n2631;
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2633 = n2630 & n2632;
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2634 = n2630 & n2631;
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2635 = n2629 & n2632;
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2636 = slot[2]; // extract
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2637 = ~n2636;
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2638 = n2633 & n2637;
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2639 = n2633 & n2636;
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2640 = n2634 & n2637;
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2641 = n2634 & n2636;
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2642 = n2635 & n2637;
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2643 = slot[1]; // extract
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2644 = ~n2643;
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2645 = n2638 & n2644;
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2646 = n2638 & n2643;
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2647 = n2639 & n2644;
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2648 = n2639 & n2643;
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2649 = n2640 & n2644;
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2650 = n2640 & n2643;
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2651 = n2641 & n2644;
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2652 = n2641 & n2643;
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2653 = n2642 & n2644;
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2654 = slot[0]; // extract
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2655 = ~n2654;
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2656 = n2645 & n2655;
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2657 = n2645 & n2654;
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2658 = n2646 & n2655;
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2659 = n2646 & n2654;
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2660 = n2647 & n2655;
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2661 = n2647 & n2654;
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2662 = n2648 & n2655;
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2663 = n2648 & n2654;
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2664 = n2649 & n2655;
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2665 = n2649 & n2654;
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2666 = n2650 & n2655;
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2667 = n2650 & n2654;
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2668 = n2651 & n2655;
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2669 = n2651 & n2654;
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2670 = n2652 & n2655;
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2671 = n2652 & n2654;
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2672 = n2653 & n2655;
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2673 = n2653 & n2654;
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2674 = n2210[0]; // extract
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2675 = n2656 ? key : n2674;
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2676 = n2210[1]; // extract
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2677 = n2657 ? key : n2676;
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2678 = n2210[2]; // extract
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2679 = n2658 ? key : n2678;
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2680 = n2210[3]; // extract
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2681 = n2659 ? key : n2680;
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2682 = n2210[4]; // extract
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2683 = n2660 ? key : n2682;
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2684 = n2210[5]; // extract
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2685 = n2661 ? key : n2684;
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2686 = n2210[6]; // extract
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2687 = n2662 ? key : n2686;
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2688 = n2210[7]; // extract
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2689 = n2663 ? key : n2688;
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2690 = n2210[8]; // extract
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2691 = n2664 ? key : n2690;
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2692 = n2210[9]; // extract
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2693 = n2665 ? key : n2692;
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2694 = n2210[10]; // extract
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2695 = n2666 ? key : n2694;
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2696 = n2210[11]; // extract
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2697 = n2667 ? key : n2696;
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2698 = n2210[12]; // extract
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2699 = n2668 ? key : n2698;
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2700 = n2210[13]; // extract
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2701 = n2669 ? key : n2700;
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2702 = n2210[14]; // extract
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2703 = n2670 ? key : n2702;
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2704 = n2210[15]; // extract
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2705 = n2671 ? key : n2704;
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2706 = n2210[16]; // extract
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2707 = n2672 ? key : n2706;
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2708 = n2210[17]; // extract
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2709 = n2673 ? key : n2708;
  /*# sim_rtl/envelopegenerator.vhd:379:21 */
  assign n2710 = {n2709, n2707, n2705, n2703, n2701, n2699, n2697, n2695, n2693, n2691, n2689, n2687, n2685, n2683, n2681, n2679, n2677, n2675};
endmodule

module controller_Brtl
  (input  clk,
   input  reset,
   input  clkena,
   input  [4:0] slot,
   input  [1:0] stage,
   input  wr,
   input  [7:0] addr,
   input  [7:0] data,
   output am,
   output pm,
   output wf,
   output [3:0] ml,
   output [6:0] tl,
   output [2:0] fb,
   output [3:0] ar,
   output [3:0] dr,
   output [3:0] sl,
   output [3:0] rr,
   output [2:0] blk,
   output [8:0] fnum,
   output [3:0] rks,
   output key,
   output rhythm,
   input  ss_hold,
   input  [7:0] ss_addr,
   input  ss_read,
   input  ss_write,
   input  [31:0] ss_wdata,
   output [31:0] ss_rdata,
   output ss_initialized);
  wire [35:0] inst_cache;
  wire [5:0] slot_voice_addr;
  wire [35:0] slot_voice_data;
  wire user_voice_wr;
  wire [5:0] user_voice_addr;
  wire [35:0] user_voice_rdata;
  wire [35:0] user_voice_wdata;
  wire regs_wr;
  wire [3:0] regs_addr;
  wire [23:0] regs_rdata;
  wire [23:0] regs_wdata;
  wire [7:0] rflag;
  wire [3:0] w_channel;
  reg [31:0] ss_local_data;
  wire [31:0] ss_u_register_memory_data;
  wire ss_u_register_memory_ready;
  wire [31:0] ss_vmem_data;
  wire ss_vmem_ready;
  wire [23:0] u_register_memory_n582;
  wire [31:0] u_register_memory_n583;
  wire u_register_memory_n584;
  wire [35:0] vmem_n591;
  wire [35:0] vmem_n592;
  wire [31:0] vmem_n593;
  wire vmem_n594;
  wire \vmem.odata[am] ;
  wire \vmem.odata[pm] ;
  wire \vmem.odata[eg] ;
  wire \vmem.odata[kr] ;
  wire [3:0] \vmem.odata[ml] ;
  wire [1:0] \vmem.odata[kl] ;
  wire [5:0] \vmem.odata[tl] ;
  wire \vmem.odata[wf] ;
  wire [2:0] \vmem.odata[fb] ;
  wire [3:0] \vmem.odata[ar] ;
  wire [3:0] \vmem.odata[dr] ;
  wire [3:0] \vmem.odata[sl] ;
  wire [3:0] \vmem.odata[rr] ;
  wire \vmem.rodata[am] ;
  wire \vmem.rodata[pm] ;
  wire \vmem.rodata[eg] ;
  wire \vmem.rodata[kr] ;
  wire [3:0] \vmem.rodata[ml] ;
  wire [1:0] \vmem.rodata[kl] ;
  wire [5:0] \vmem.rodata[tl] ;
  wire \vmem.rodata[wf] ;
  wire [2:0] \vmem.rodata[fb] ;
  wire [3:0] \vmem.rodata[ar] ;
  wire [3:0] \vmem.rodata[dr] ;
  wire [3:0] \vmem.rodata[sl] ;
  wire [3:0] \vmem.rodata[rr] ;
  wire n595;
  wire n596;
  wire n597;
  wire n598;
  wire [3:0] n599;
  wire [1:0] n600;
  wire [5:0] n601;
  wire n602;
  wire [2:0] n603;
  wire [3:0] n604;
  wire [3:0] n605;
  wire [3:0] n606;
  wire [3:0] n607;
  wire [35:0] n608;
  wire [35:0] n610;
  reg n618_kflag;
  reg n618_extra_mode;
  reg [5:0] n618_vindex;
  wire n657;
  wire n658;
  wire [3:0] n659;
  wire [3:0] n661;
  wire [3:0] n663;
  wire [3:0] n665;
  wire [3:0] n667;
  wire [3:0] n669;
  wire [3:0] n671;
  wire [3:0] n673;
  wire [3:0] n675;
  wire n684;
  wire n685;
  wire [1:0] n686;
  wire n687;
  wire [2:0] n688;
  wire n689;
  wire [3:0] n690;
  wire [3:0] n691;
  wire [7:0] n692;
  wire [1:0] n693;
  wire [9:0] n694;
  wire [5:0] n695;
  wire [15:0] n696;
  wire n697;
  wire [16:0] n698;
  wire [2:0] n699;
  wire [19:0] n700;
  wire [3:0] n701;
  wire [23:0] n702;
  wire [3:0] n703;
  wire [27:0] n704;
  wire [3:0] n705;
  wire [31:0] n706;
  wire [3:0] n707;
  wire [35:0] n708;
  wire [31:0] n710;
  wire [35:0] n711;
  wire [31:0] n712;
  wire n714;
  wire [35:0] n715;
  wire [3:0] n716;
  wire n717;
  wire n719;
  wire [31:0] n720;
  wire n722;
  wire [3:0] n723;
  wire [7:0] n724;
  wire [13:0] n725;
  wire [21:0] n726;
  wire n728;
  wire [5:0] n729;
  wire n731;
  wire n732;
  wire n734;
  wire [5:0] n735;
  wire [3:0] n736;
  wire [3:0] n737;
  wire [3:0] n738;
  reg [3:0] n740;
  wire n741;
  wire n742;
  wire n743;
  wire n744;
  wire n745;
  reg n747;
  wire n748;
  wire n749;
  wire n750;
  wire n751;
  wire n752;
  wire n753;
  reg n755;
  wire n756;
  wire n757;
  wire n758;
  wire n759;
  wire n760;
  reg n762;
  wire n763;
  wire n764;
  wire n765;
  wire n766;
  wire n767;
  reg n769;
  wire n770;
  wire n771;
  wire n772;
  wire n773;
  wire n774;
  reg n776;
  wire [1:0] n777;
  wire [1:0] n778;
  wire [1:0] n779;
  wire [1:0] n780;
  wire [1:0] n781;
  wire [1:0] n782;
  reg [1:0] n784;
  wire [1:0] n785;
  wire [1:0] n786;
  wire [1:0] n787;
  wire [1:0] n788;
  wire [1:0] n789;
  wire [1:0] n790;
  reg [1:0] n792;
  wire n793;
  wire n794;
  wire n795;
  wire n796;
  wire n797;
  wire n798;
  reg n800;
  wire n801;
  wire n802;
  wire n803;
  wire n804;
  wire n805;
  reg n807;
  wire n808;
  wire n809;
  wire n810;
  wire n811;
  wire n812;
  reg n814;
  wire [3:0] n815;
  wire [3:0] n816;
  wire [3:0] n817;
  wire [3:0] n818;
  wire [3:0] n819;
  reg [3:0] n821;
  wire [2:0] n822;
  wire [2:0] n823;
  wire [2:0] n824;
  wire [2:0] n825;
  reg [2:0] n827;
  wire n828;
  wire n829;
  wire n830;
  wire n831;
  wire n832;
  reg n834;
  wire n835;
  wire n836;
  wire n837;
  wire n838;
  reg n840;
  wire n841;
  wire n842;
  wire n843;
  wire n844;
  reg n846;
  wire n847;
  wire n848;
  wire n849;
  wire n850;
  reg n852;
  wire n853;
  wire n854;
  wire n855;
  reg n857;
  wire [2:0] n858;
  wire [2:0] n859;
  wire [2:0] n860;
  reg [2:0] n862;
  wire n863;
  wire n864;
  reg n866;
  wire [31:0] n867;
  wire [31:0] n869;
  wire [31:0] n870;
  wire [35:0] n871;
  wire [3:0] n872;
  wire [35:0] n874;
  wire [3:0] n875;
  wire [35:0] n877;
  wire [3:0] n878;
  wire [35:0] n880;
  wire [3:0] n881;
  wire [35:0] n883;
  wire [3:0] n884;
  wire [35:0] n886;
  wire [3:0] n887;
  wire [35:0] n889;
  wire [3:0] n890;
  wire [35:0] n892;
  wire [3:0] n893;
  wire [35:0] n895;
  wire [3:0] n896;
  wire n899;
  wire [3:0] n900;
  wire [35:0] n901;
  wire [3:0] n902;
  wire [35:0] n904;
  wire [3:0] n905;
  wire [35:0] n907;
  wire [3:0] n908;
  wire [35:0] n910;
  wire [3:0] n911;
  wire [35:0] n913;
  wire [3:0] n914;
  wire [35:0] n916;
  wire [3:0] n917;
  wire [35:0] n919;
  wire [3:0] n920;
  wire [35:0] n922;
  wire [3:0] n923;
  wire [35:0] n925;
  wire [3:0] n926;
  wire [3:0] n928;
  wire [5:0] n929;
  wire n931;
  wire [4:0] n932;
  wire [5:0] n933;
  wire n935;
  wire n937;
  wire [3:0] n943;
  wire [35:0] n944;
  wire n945;
  wire [3:0] n946;
  wire [35:0] n947;
  wire n948;
  wire [3:0] n949;
  wire [35:0] n950;
  wire n951;
  wire [3:0] n952;
  wire [35:0] n953;
  wire n954;
  wire [3:0] n955;
  wire [35:0] n956;
  wire [3:0] n957;
  wire [3:0] n958;
  wire [35:0] n959;
  wire [1:0] n960;
  wire [3:0] n961;
  wire [35:0] n962;
  wire [5:0] n963;
  wire [3:0] n964;
  wire [35:0] n965;
  wire n966;
  wire [3:0] n967;
  wire [35:0] n968;
  wire [2:0] n969;
  wire [3:0] n970;
  wire [35:0] n971;
  wire [3:0] n972;
  wire [3:0] n973;
  wire [35:0] n974;
  wire [3:0] n975;
  wire [3:0] n976;
  wire [35:0] n977;
  wire [3:0] n978;
  wire [3:0] n979;
  wire [35:0] n980;
  wire [3:0] n981;
  wire [35:0] n982;
  wire n984;
  wire [3:0] n985;
  wire [31:0] n991;
  wire [35:0] n992;
  wire n993;
  wire [31:0] n994;
  wire [35:0] n995;
  wire n996;
  wire [31:0] n997;
  wire [35:0] n998;
  wire n999;
  wire [31:0] n1000;
  wire [35:0] n1001;
  wire n1002;
  wire [31:0] n1003;
  wire [35:0] n1004;
  wire [3:0] n1005;
  wire [31:0] n1006;
  wire [35:0] n1007;
  wire [1:0] n1008;
  wire [31:0] n1009;
  wire [35:0] n1010;
  wire [5:0] n1011;
  wire [31:0] n1012;
  wire [35:0] n1013;
  wire n1014;
  wire [31:0] n1015;
  wire [35:0] n1016;
  wire [2:0] n1017;
  wire [31:0] n1018;
  wire [35:0] n1019;
  wire [3:0] n1020;
  wire [31:0] n1021;
  wire [35:0] n1022;
  wire [3:0] n1023;
  wire [31:0] n1024;
  wire [35:0] n1025;
  wire [3:0] n1026;
  wire [31:0] n1027;
  wire [35:0] n1028;
  wire [3:0] n1029;
  wire [35:0] n1030;
  wire n1031;
  wire [13:0] n1033;
  wire [7:0] n1034;
  wire [23:0] n1035;
  wire n1037;
  wire [5:0] n1038;
  wire [1:0] n1039;
  wire [7:0] n1040;
  wire n1041;
  wire n1042;
  wire n1043;
  wire [3:0] n1044;
  wire [6:0] n1045;
  wire [2:0] n1046;
  wire [3:0] n1047;
  wire [3:0] n1048;
  wire n1050;
  wire [3:0] n1051;
  wire [3:0] n1052;
  wire [2:0] n1053;
  wire [8:0] n1054;
  wire [3:0] n1055;
  wire n1056;
  wire n1057;
  wire n1058;
  wire n1059;
  wire [4:0] n1060;
  wire [5:0] n1061;
  wire n1064;
  wire [5:0] n1065;
  reg n1066;
  reg n1067;
  reg n1068;
  reg [3:0] n1069;
  reg [6:0] n1070;
  reg [2:0] n1071;
  reg [3:0] n1072;
  reg [3:0] n1073;
  reg [3:0] n1074;
  reg [3:0] n1075;
  reg [2:0] n1076;
  reg [8:0] n1077;
  reg [3:0] n1078;
  reg n1079;
  reg n1080;
  wire [3:0] n1081;
  reg [3:0] n1082;
  wire [3:0] n1083;
  reg [3:0] n1084;
  wire [3:0] n1085;
  reg [3:0] n1086;
  wire [3:0] n1087;
  reg [3:0] n1088;
  wire [3:0] n1089;
  reg [3:0] n1090;
  wire [3:0] n1091;
  reg [3:0] n1092;
  wire [3:0] n1093;
  reg [3:0] n1094;
  wire [3:0] n1095;
  reg [3:0] n1096;
  wire [3:0] n1097;
  reg [3:0] n1098;
  reg [5:0] n1099;
  reg n1100;
  reg [5:0] n1101;
  reg [35:0] n1102;
  reg n1103;
  reg [3:0] n1104;
  reg [23:0] n1105;
  reg [7:0] n1106;
  reg n1107;
  reg [5:0] n1108;
  wire n1148;
  wire n1149;
  wire n1150;
  wire [3:0] n1151;
  wire [6:0] n1152;
  wire [2:0] n1153;
  wire [3:0] n1154;
  wire [3:0] n1155;
  wire [3:0] n1156;
  wire [3:0] n1157;
  wire [2:0] n1158;
  wire [8:0] n1159;
  wire [3:0] n1160;
  wire n1161;
  wire n1162;
  wire [35:0] n1163;
  wire [35:0] n1164;
  wire [5:0] n1165;
  wire n1166;
  wire [5:0] n1167;
  wire [35:0] n1168;
  wire n1169;
  wire [3:0] n1170;
  wire [23:0] n1171;
  wire [7:0] n1172;
  wire n1173;
  wire [5:0] n1174;
  wire n1211;
  wire n1212;
  wire n1213;
  wire n1214;
  wire n1215;
  wire n1216;
  wire n1217;
  wire n1218;
  wire n1219;
  wire n1220;
  wire n1221;
  wire n1222;
  wire n1223;
  wire n1224;
  wire n1225;
  wire n1226;
  wire n1227;
  wire n1228;
  wire n1229;
  wire n1230;
  wire n1231;
  wire n1232;
  wire n1233;
  wire n1234;
  wire n1235;
  wire n1236;
  wire [31:0] n1267;
  wire n1269;
  wire n1271;
  wire [3:0] n1272;
  wire [3:0] n1273;
  wire n1274;
  wire n1276;
  wire n1277;
  wire n1279;
  wire n1280;
  wire [31:0] n1281;
  wire [31:0] n1283;
  wire [31:0] n1285;
  wire [5:0] n1286;
  wire [31:0] n1287;
  wire [31:0] n1289;
  wire [3:0] n1290;
  wire [3:0] n1292;
  wire [31:0] n1295;
  wire [31:0] n1297;
  wire [31:0] n1298;
  wire n1299;
  wire [31:0] n1300;
  wire [31:0] n1301;
  wire [5:0] n1302;
  wire [5:0] n1303;
  wire [5:0] n1304;
  wire n1305;
  wire [31:0] n1306;
  wire n1307;
  wire [5:0] n1309;
  wire n1311;
  wire n1313;
  wire n1314;
  wire [31:0] n1315;
  wire n1317;
  wire n1318;
  wire [1:0] n1319;
  wire n1320;
  wire [31:0] n1321;
  wire [31:0] n1322;
  wire n1323;
  wire [31:0] n1324;
  wire n1325;
  wire n1326;
  wire n1327;
  wire n1328;
  wire n1329;
  wire [3:0] n1330;
  wire n1332;
  wire [7:0] n1333;
  wire [7:0] n1334;
  wire [7:0] n1335;
  wire n1337;
  wire n1338;
  wire n1339;
  wire [31:0] n1340;
  wire n1341;
  wire [31:0] n1342;
  wire n1344;
  wire n1345;
  wire [1:0] n1346;
  wire [5:0] n1347;
  wire n1348;
  wire [31:0] n1349;
  wire n1350;
  wire [31:0] n1351;
  wire n1353;
  wire n1354;
  wire n1355;
  wire [2:0] n1356;
  wire n1357;
  wire [31:0] n1358;
  wire n1359;
  wire [31:0] n1360;
  wire n1362;
  wire n1363;
  wire [1:0] n1364;
  wire n1365;
  wire n1367;
  wire [1:0] n1368;
  wire [1:0] n1369;
  wire n1370;
  wire n1371;
  wire n1373;
  wire [3:0] n1374;
  wire [1:0] n1375;
  wire [1:0] n1376;
  wire n1377;
  wire n1378;
  wire [2:0] n1379;
  wire [2:0] n1380;
  wire [2:0] n1381;
  wire n1383;
  wire [3:0] n1384;
  wire [7:0] n1385;
  wire [1:0] n1386;
  wire [1:0] n1387;
  wire [5:0] n1388;
  wire [5:0] n1389;
  wire [5:0] n1390;
  wire [3:0] n1391;
  wire [3:0] n1392;
  wire n1394;
  wire n1395;
  wire [31:0] n1396;
  wire [31:0] n1397;
  wire n1398;
  wire [31:0] n1399;
  wire n1400;
  wire [3:0] n1401;
  wire [3:0] n1402;
  wire n1404;
  wire [7:0] n1405;
  wire [7:0] n1406;
  wire [7:0] n1407;
  wire n1409;
  wire n1410;
  wire [31:0] n1411;
  wire [31:0] n1412;
  wire n1413;
  wire [31:0] n1414;
  wire n1415;
  wire [3:0] n1416;
  wire [3:0] n1417;
  wire n1419;
  wire [7:0] n1420;
  wire [7:0] n1421;
  wire [7:0] n1422;
  wire n1424;
  wire [3:0] n1425;
  reg n1426;
  wire [7:0] n1427;
  reg [7:0] n1428;
  wire [1:0] n1429;
  reg [1:0] n1430;
  wire [5:0] n1431;
  reg [5:0] n1432;
  wire [3:0] n1433;
  reg [3:0] n1434;
  wire [7:0] n1435;
  reg [7:0] n1436;
  wire [7:0] n1437;
  reg [7:0] n1438;
  wire [35:0] n1444;
  wire [31:0] n1445;
  wire n1447;
  wire [31:0] n1448;
  wire n1450;
  wire [31:0] n1451;
  wire n1453;
  wire [3:0] n1454;
  wire [31:0] n1455;
  wire [31:0] n1456;
  wire [31:0] n1458;
  wire n1459;
  wire [1:0] n1460;
  wire n1462;
  wire n1463;
  wire n1464;
  wire [2:0] n1465;
  wire n1466;
  wire n1468;
  wire [3:0] n1469;
  wire [3:0] n1470;
  wire n1472;
  wire [2:0] n1473;
  reg n1477;
  wire [7:0] n1478;
  reg [7:0] n1479;
  wire n1480;
  reg n1481;
  wire [2:0] n1482;
  reg [2:0] n1483;
  wire n1484;
  reg n1485;
  wire n1486;
  reg n1487;
  wire [3:0] n1488;
  reg [3:0] n1489;
  wire [3:0] n1490;
  reg [3:0] n1491;
  wire [1:0] n1498;
  wire [23:0] n1499;
  wire n1500;
  wire [23:0] n1501;
  wire [31:0] n1504;
  wire n1506;
  wire n1508;
  wire n1511;
  wire n1512;
  wire n1513;
  wire n1514;
  wire n1516;
  wire n1517;
  wire [23:0] n1518;
  wire n1520;
  wire n1521;
  wire [23:0] n1522;
  wire [7:0] n1523;
  wire n1525;
  wire n1526;
  wire [35:0] n1527;
  wire n1528;
  wire [23:0] n1529;
  wire [7:0] n1530;
  wire n1534;
  wire n1535;
  wire n1536;
  wire n1537;
  wire [23:0] n1538;
  wire [7:0] n1539;
  wire n1542;
  wire n1544;
  wire [31:0] n1545;
  wire [31:0] n1547;
  wire [3:0] n1548;
  wire [3:0] n1550;
  wire [3:0] n1552;
  wire n1555;
  wire n1556;
  wire n1558;
  wire n1559;
  wire n1560;
  wire n1562;
  wire n1564;
  wire n1565;
  wire n1566;
  wire n1568;
  wire n1569;
  wire n1571;
  wire n1572;
  wire n1574;
  wire n1575;
  wire n1577;
  wire [4:0] n1578;
  reg n1579;
  wire n1581;
  wire n1582;
  wire n1583;
  wire [3:0] n1584;
  wire [6:0] n1592;
  wire [2:0] n1593;
  wire [2:0] n1595;
  wire [3:0] n1597;
  wire [6:0] n1599;
  wire [6:0] n1600;
  wire [7:0] n1602;
  wire n1603;
  wire [1:0] n1604;
  wire n1606;
  wire n1607;
  wire [1:0] n1608;
  wire [1:0] n1610;
  wire [7:0] n1611;
  wire [7:0] n1613;
  wire n1614;
  wire n1616;
  wire n1618;
  wire n1619;
  wire n1620;
  wire [3:0] n1621;
  wire [4:0] n1623;
  wire [7:0] n1625;
  wire n1626;
  wire n1627;
  wire [5:0] n1628;
  wire [6:0] n1630;
  wire [7:0] n1632;
  wire [3:0] n1633;
  wire [4:0] n1635;
  wire [7:0] n1637;
  wire [7:0] n1638;
  wire [7:0] n1639;
  wire [7:0] n1640;
  wire n1641;
  wire [6:0] n1642;
  wire [6:0] n1644;
  wire [8:0] n1645;
  wire [2:0] n1646;
  wire n1647;
  wire n1649;
  wire n1650;
  wire n1651;
  wire [1:0] n1652;
  wire [3:0] n1654;
  wire [3:0] n1656;
  wire n1657;
  wire [2:0] n1658;
  wire n1659;
  wire [3:0] n1660;
  wire [1:0] n1661;
  wire [3:0] n1663;
  wire [3:0] n1664;
  wire [3:0] n1665;
  wire n1666;
  wire n1667;
  wire [3:0] n1668;
  wire n1669;
  wire [2:0] n1670;
  wire [3:0] n1671;
  wire [3:0] n1672;
  wire [3:0] n1673;
  wire n1674;
  wire [3:0] n1675;
  wire [3:0] n1677;
  wire n1678;
  wire n1679;
  wire n1680;
  wire [31:0] n1681;
  wire [31:0] n1683;
  wire n1685;
  wire n1686;
  wire n1687;
  wire n1688;
  wire n1689;
  wire n1690;
  wire n1691;
  wire [3:0] n1692;
  wire [3:0] n1694;
  wire [3:0] n1696;
  wire [3:0] n1698;
  wire [3:0] n1699;
  wire n1701;
  wire [3:0] n1702;
  reg n1703;
  reg n1704;
  reg n1705;
  reg [3:0] n1706;
  reg [6:0] n1707;
  reg [2:0] n1708;
  reg [3:0] n1709;
  reg [3:0] n1710;
  reg [3:0] n1711;
  reg [3:0] n1712;
  reg [2:0] n1713;
  reg [8:0] n1714;
  reg [3:0] n1715;
  reg n1716;
  reg n1717;
  reg [35:0] n1718;
  reg n1720;
  reg [5:0] n1721;
  reg [35:0] n1722;
  reg n1724;
  reg [23:0] n1725;
  reg [7:0] n1726;
  reg n1727;
  reg n1734;
  reg [5:0] n1735;
  wire n1736;
  wire n1737;
  wire n1738;
  wire [3:0] n1739;
  wire [6:0] n1740;
  wire [2:0] n1741;
  wire [3:0] n1742;
  wire [3:0] n1743;
  wire [3:0] n1744;
  wire [3:0] n1745;
  wire [2:0] n1746;
  wire [8:0] n1747;
  wire [3:0] n1748;
  wire n1749;
  wire n1750;
  wire [35:0] n1751;
  wire n1752;
  wire [5:0] n1753;
  wire [35:0] n1754;
  wire n1755;
  wire [23:0] n1756;
  wire [7:0] n1757;
  wire n1765;
  wire [5:0] n1766;
  wire n1767;
  wire n1768;
  wire n1769;
  wire n1770;
  wire n1771;
  wire n1772;
  wire n1773;
  wire n1774;
  wire n1775;
  wire n1776;
  wire n1777;
  wire n1778;
  wire n1779;
  wire n1780;
  wire n1781;
  wire n1782;
  wire n1783;
  wire n1784;
  wire n1785;
  wire n1786;
  wire n1787;
  wire n1788;
  wire n1789;
  wire n1790;
  wire n1791;
  wire n1798;
  wire n1799;
  wire [3:0] n1948;
  wire [31:0] n1949;
  wire [31:0] n1950;
  wire n1952;
  wire n1953;
  wire n1954;
  wire n1955;
  reg n1956;
  wire n1957;
  wire n1958;
  reg n1959;
  reg n1960;
  reg [3:0] n1961;
  reg [6:0] n1962;
  reg [2:0] n1963;
  reg [3:0] n1964;
  reg [3:0] n1965;
  reg [3:0] n1966;
  reg [3:0] n1967;
  reg [2:0] n1968;
  reg [8:0] n1969;
  reg [3:0] n1970;
  reg n1971;
  reg n1972;
  wire n1973;
  wire [35:0] n1974;
  reg [35:0] n1975;
  reg [5:0] n1976;
  reg n1977;
  reg [5:0] n1978;
  wire n1979;
  wire [35:0] n1980;
  reg [35:0] n1981;
  reg n1982;
  reg [3:0] n1983;
  wire n1984;
  wire [23:0] n1985;
  reg [23:0] n1986;
  reg [7:0] n1987;
  reg [31:0] n1988;
  wire n1989;
  reg n1990;
  reg n1991;
  reg [5:0] n1992;
  wire [5:0] n1995; // mem_rd
  wire [63:0] n1997;
  wire [3:0] n1998;
  wire n1999;
  wire n2000;
  wire n2001;
  wire n2002;
  wire n2003;
  wire n2004;
  wire n2005;
  wire n2006;
  wire n2007;
  wire n2008;
  wire n2009;
  wire n2010;
  wire n2011;
  wire n2012;
  wire n2013;
  wire n2014;
  wire n2015;
  wire n2016;
  wire n2017;
  wire n2018;
  wire n2019;
  wire n2020;
  wire n2021;
  wire n2022;
  wire n2023;
  wire [3:0] n2024;
  wire [3:0] n2025;
  wire [3:0] n2026;
  wire [3:0] n2027;
  wire [3:0] n2028;
  wire [3:0] n2029;
  wire [3:0] n2030;
  wire [3:0] n2031;
  wire [3:0] n2032;
  wire [3:0] n2033;
  wire [3:0] n2034;
  wire [3:0] n2035;
  wire [3:0] n2036;
  wire [3:0] n2037;
  wire [3:0] n2038;
  wire [3:0] n2039;
  wire [3:0] n2040;
  wire [3:0] n2041;
  wire [35:0] n2042;
  assign am = n1956; //(module output)
  assign pm = n1959; //(module output)
  assign wf = n1960; //(module output)
  assign ml = n1961; //(module output)
  assign tl = n1962; //(module output)
  assign fb = n1963; //(module output)
  assign ar = n1964; //(module output)
  assign dr = n1965; //(module output)
  assign sl = n1966; //(module output)
  assign rr = n1967; //(module output)
  assign blk = n1968; //(module output)
  assign fnum = n1969; //(module output)
  assign rks = n1970; //(module output)
  assign key = n1971; //(module output)
  assign rhythm = n1972; //(module output)
  assign ss_rdata = n1950; //(module output)
  assign ss_initialized = n1953; //(module output)
  /*# sim_rtl/controller.vhd:160:12 */
  assign inst_cache = n1975; // (signal)
  /*# sim_rtl/controller.vhd:171:12 */
  assign slot_voice_addr = n1976; // (signal)
  /*# sim_rtl/controller.vhd:172:12 */
  assign slot_voice_data = vmem_n592; // (signal)
  /*# sim_rtl/controller.vhd:175:12 */
  assign user_voice_wr = n1977; // (signal)
  /*# sim_rtl/controller.vhd:176:12 */
  assign user_voice_addr = n1978; // (signal)
  /*# sim_rtl/controller.vhd:177:12 */
  assign user_voice_rdata = vmem_n591; // (signal)
  /*# sim_rtl/controller.vhd:178:12 */
  assign user_voice_wdata = n1981; // (signal)
  /*# sim_rtl/controller.vhd:181:12 */
  assign regs_wr = n1982; // (signal)
  /*# sim_rtl/controller.vhd:182:12 */
  assign regs_addr = n1983; // (signal)
  /*# sim_rtl/controller.vhd:183:12 */
  assign regs_rdata = u_register_memory_n582; // (signal)
  /*# sim_rtl/controller.vhd:184:12 */
  assign regs_wdata = n1986; // (signal)
  /*# sim_rtl/controller.vhd:186:12 */
  assign rflag = n1987; // (signal)
  /*# sim_rtl/controller.vhd:187:12 */
  assign w_channel = n1948; // (signal)
  /*# sim_rtl/controller.vhd:190:12 */
  always @*
    ss_local_data = n1988; // (isignal)
  initial
    ss_local_data = 32'b00000000000000000000000000000000;
  /*# sim_rtl/controller.vhd:191:12 */
  assign ss_u_register_memory_data = u_register_memory_n583; // (signal)
  /*# sim_rtl/controller.vhd:192:12 */
  assign ss_u_register_memory_ready = u_register_memory_n584; // (signal)
  /*# sim_rtl/controller.vhd:193:12 */
  assign ss_vmem_data = vmem_n593; // (signal)
  /*# sim_rtl/controller.vhd:194:12 */
  assign ss_vmem_ready = vmem_n594; // (signal)
  /*# sim_rtl/controller.vhd:199:5 */
  registermemory_Brtl u_register_memory (
    .clk(clk),
    .reset(reset),
    .addr(regs_addr),
    .wr(regs_wr),
    .idata(regs_wdata),
    .ss_hold(ss_hold),
    .ss_addr(ss_addr),
    .ss_read(ss_read),
    .ss_write(ss_write),
    .ss_wdata(ss_wdata),
    .odata(u_register_memory_n582),
    .ss_rdata(u_register_memory_n583),
    .ss_initialized(u_register_memory_n584));
  /*# sim_rtl/controller.vhd:212:9 */
  assign vmem_n591 = n608; // (signal)
  /*# sim_rtl/controller.vhd:212:27 */
  assign vmem_n592 = n610; // (signal)
  /*# sim_rtl/controller.vhd:210:5 */
  voicememory_Brtl vmem (
    .clk(clk),
    .reset(reset),
    .\idata[am] (n595),
    .\idata[pm] (n596),
    .\idata[eg] (n597),
    .\idata[kr] (n598),
    .\idata[ml] (n599),
    .\idata[kl] (n600),
    .\idata[tl] (n601),
    .\idata[wf] (n602),
    .\idata[fb] (n603),
    .\idata[ar] (n604),
    .\idata[dr] (n605),
    .\idata[sl] (n606),
    .\idata[rr] (n607),
    .wr(user_voice_wr),
    .rwaddr(user_voice_addr),
    .roaddr(slot_voice_addr),
    .ss_hold(ss_hold),
    .ss_addr(ss_addr),
    .ss_read(ss_read),
    .ss_write(ss_write),
    .ss_wdata(ss_wdata),
    .\odata[am] (\vmem.odata[am] ),
    .\odata[pm] (\vmem.odata[pm] ),
    .\odata[eg] (\vmem.odata[eg] ),
    .\odata[kr] (\vmem.odata[kr] ),
    .\odata[ml] (\vmem.odata[ml] ),
    .\odata[kl] (\vmem.odata[kl] ),
    .\odata[tl] (\vmem.odata[tl] ),
    .\odata[wf] (\vmem.odata[wf] ),
    .\odata[fb] (\vmem.odata[fb] ),
    .\odata[ar] (\vmem.odata[ar] ),
    .\odata[dr] (\vmem.odata[dr] ),
    .\odata[sl] (\vmem.odata[sl] ),
    .\odata[rr] (\vmem.odata[rr] ),
    .\rodata[am] (\vmem.rodata[am] ),
    .\rodata[pm] (\vmem.rodata[pm] ),
    .\rodata[eg] (\vmem.rodata[eg] ),
    .\rodata[kr] (\vmem.rodata[kr] ),
    .\rodata[ml] (\vmem.rodata[ml] ),
    .\rodata[kl] (\vmem.rodata[kl] ),
    .\rodata[tl] (\vmem.rodata[tl] ),
    .\rodata[wf] (\vmem.rodata[wf] ),
    .\rodata[fb] (\vmem.rodata[fb] ),
    .\rodata[ar] (\vmem.rodata[ar] ),
    .\rodata[dr] (\vmem.rodata[dr] ),
    .\rodata[sl] (\vmem.rodata[sl] ),
    .\rodata[rr] (\vmem.rodata[rr] ),
    .ss_rdata(vmem_n593),
    .ss_initialized(vmem_n594));
  /*# sim_rtl/controller.vhd:210:5 */
  assign n595 = user_voice_wdata[0]; // extract
  /*# sim_rtl/controller.vhd:210:5 */
  assign n596 = user_voice_wdata[1]; // extract
  /*# sim_rtl/controller.vhd:210:5 */
  assign n597 = user_voice_wdata[2]; // extract
  /*# sim_rtl/controller.vhd:210:5 */
  assign n598 = user_voice_wdata[3]; // extract
  /*# sim_rtl/controller.vhd:210:5 */
  assign n599 = user_voice_wdata[7:4]; // extract
  /*# sim_rtl/controller.vhd:210:5 */
  assign n600 = user_voice_wdata[9:8]; // extract
  /*# sim_rtl/controller.vhd:210:5 */
  assign n601 = user_voice_wdata[15:10]; // extract
  /*# sim_rtl/controller.vhd:210:5 */
  assign n602 = user_voice_wdata[16]; // extract
  /*# sim_rtl/controller.vhd:210:5 */
  assign n603 = user_voice_wdata[19:17]; // extract
  /*# sim_rtl/controller.vhd:210:5 */
  assign n604 = user_voice_wdata[23:20]; // extract
  /*# sim_rtl/controller.vhd:210:5 */
  assign n605 = user_voice_wdata[27:24]; // extract
  /*# sim_rtl/controller.vhd:210:5 */
  assign n606 = user_voice_wdata[31:28]; // extract
  /*# sim_rtl/controller.vhd:210:5 */
  assign n607 = user_voice_wdata[35:32]; // extract
  /*# sim_rtl/controller.vhd:210:5 */
  assign n608 = {\vmem.odata[rr] , \vmem.odata[sl] , \vmem.odata[dr] , \vmem.odata[ar] , \vmem.odata[fb] , \vmem.odata[wf] , \vmem.odata[tl] , \vmem.odata[kl] , \vmem.odata[ml] , \vmem.odata[kr] , \vmem.odata[eg] , \vmem.odata[pm] , \vmem.odata[am] };
  /*# sim_rtl/controller.vhd:210:5 */
  assign n610 = {\vmem.rodata[rr] , \vmem.rodata[sl] , \vmem.rodata[dr] , \vmem.rodata[ar] , \vmem.rodata[fb] , \vmem.rodata[wf] , \vmem.rodata[tl] , \vmem.rodata[kl] , \vmem.rodata[ml] , \vmem.rodata[kr] , \vmem.rodata[eg] , \vmem.rodata[pm] , \vmem.rodata[am] };
  /*# sim_rtl/controller.vhd:223:18 */
  always @*
    n618_kflag = n1990; // (isignal)
  initial
    n618_kflag = 1'bX;
  /*# sim_rtl/controller.vhd:233:18 */
  always @*
    n618_extra_mode = n1991; // (isignal)
  initial
    n618_extra_mode = 1'bX;
  /*# sim_rtl/controller.vhd:234:18 */
  always @*
    n618_vindex = n1992; // (isignal)
  initial
    n618_vindex = 6'b000000;
  /*# sim_rtl/controller.vhd:304:33 */
  assign n657 = ss_read | ss_write;
  /*# sim_rtl/controller.vhd:304:16 */
  assign n658 = n657 & ss_hold;
  /*# sim_rtl/controller.vhd:305:64 */
  assign n659 = inst_cache[35:32]; // extract
  /*# sim_rtl/controller.vhd:306:64 */
  assign n661 = inst_cache[31:28]; // extract
  /*# sim_rtl/controller.vhd:307:65 */
  assign n663 = inst_cache[27:24]; // extract
  /*# sim_rtl/controller.vhd:308:66 */
  assign n665 = inst_cache[23:20]; // extract
  /*# sim_rtl/controller.vhd:309:66 */
  assign n667 = inst_cache[19:16]; // extract
  /*# sim_rtl/controller.vhd:310:66 */
  assign n669 = inst_cache[15:12]; // extract
  /*# sim_rtl/controller.vhd:311:66 */
  assign n671 = inst_cache[11:8]; // extract
  /*# sim_rtl/controller.vhd:312:66 */
  assign n673 = inst_cache[7:4]; // extract
  /*# sim_rtl/controller.vhd:313:66 */
  assign n675 = inst_cache[3:0]; // extract
  /*# sim_rtl/vm2413.vhd:178:17 */
  assign n684 = user_voice_wdata[0]; // extract
  /*# sim_rtl/vm2413.vhd:178:27 */
  assign n685 = user_voice_wdata[1]; // extract
  /*# sim_rtl/vm2413.vhd:178:20 */
  assign n686 = {n684, n685};
  /*# sim_rtl/vm2413.vhd:178:37 */
  assign n687 = user_voice_wdata[2]; // extract
  /*# sim_rtl/vm2413.vhd:178:30 */
  assign n688 = {n686, n687};
  /*# sim_rtl/vm2413.vhd:178:47 */
  assign n689 = user_voice_wdata[3]; // extract
  /*# sim_rtl/vm2413.vhd:178:40 */
  assign n690 = {n688, n689};
  /*# sim_rtl/vm2413.vhd:179:17 */
  assign n691 = user_voice_wdata[7:4]; // extract
  /*# sim_rtl/vm2413.vhd:178:50 */
  assign n692 = {n690, n691};
  /*# sim_rtl/vm2413.vhd:179:27 */
  assign n693 = user_voice_wdata[9:8]; // extract
  /*# sim_rtl/vm2413.vhd:179:20 */
  assign n694 = {n692, n693};
  /*# sim_rtl/vm2413.vhd:179:37 */
  assign n695 = user_voice_wdata[15:10]; // extract
  /*# sim_rtl/vm2413.vhd:179:30 */
  assign n696 = {n694, n695};
  /*# sim_rtl/vm2413.vhd:179:47 */
  assign n697 = user_voice_wdata[16]; // extract
  /*# sim_rtl/vm2413.vhd:179:40 */
  assign n698 = {n696, n697};
  /*# sim_rtl/vm2413.vhd:179:57 */
  assign n699 = user_voice_wdata[19:17]; // extract
  /*# sim_rtl/vm2413.vhd:179:50 */
  assign n700 = {n698, n699};
  /*# sim_rtl/vm2413.vhd:180:17 */
  assign n701 = user_voice_wdata[23:20]; // extract
  /*# sim_rtl/vm2413.vhd:179:60 */
  assign n702 = {n700, n701};
  /*# sim_rtl/vm2413.vhd:180:27 */
  assign n703 = user_voice_wdata[27:24]; // extract
  /*# sim_rtl/vm2413.vhd:180:20 */
  assign n704 = {n702, n703};
  /*# sim_rtl/vm2413.vhd:180:37 */
  assign n705 = user_voice_wdata[31:28]; // extract
  /*# sim_rtl/vm2413.vhd:180:30 */
  assign n706 = {n704, n705};
  /*# sim_rtl/vm2413.vhd:180:47 */
  assign n707 = user_voice_wdata[35:32]; // extract
  /*# sim_rtl/vm2413.vhd:180:40 */
  assign n708 = {n706, n707};
  /*# sim_rtl/controller.vhd:341:6 */
  assign n710 = {24'b0, ss_addr};  // uext
  /*# sim_rtl/controller.vhd:237:10 */
  assign n711 = {n675, n673, n671, n669, n667, n665, n663, n661, n659};
  /*# sim_rtl/controller.vhd:343:44 */
  assign n712 = n711[31:0]; // extract
  /*# sim_rtl/controller.vhd:342:1 */
  assign n714 = n710 == 32'b00000000000000000000000001010000;
  /*# sim_rtl/controller.vhd:237:10 */
  assign n715 = {n675, n673, n671, n669, n667, n665, n663, n661, n659};
  /*# sim_rtl/controller.vhd:345:43 */
  assign n716 = n715[35:32]; // extract
  /*# sim_rtl/controller.vhd:348:40 */
  assign n717 = user_voice_addr[0]; // extract
  /*# sim_rtl/controller.vhd:344:1 */
  assign n719 = n710 == 32'b00000000000000000000000001010001;
  /*# sim_rtl/controller.vhd:351:50 */
  assign n720 = n708[31:0]; // extract
  /*# sim_rtl/controller.vhd:350:1 */
  assign n722 = n710 == 32'b00000000000000000000000001010010;
  /*# sim_rtl/controller.vhd:353:49 */
  assign n723 = n708[35:32]; // extract
  /*# sim_rtl/controller.vhd:355:39 */
  assign n724 = regs_wdata[23:16]; // extract
  /*# sim_rtl/controller.vhd:355:66 */
  assign n725 = regs_wdata[13:0]; // extract
  /*# sim_rtl/controller.vhd:355:54 */
  assign n726 = {n724, n725};
  /*# sim_rtl/controller.vhd:352:1 */
  assign n728 = n710 == 32'b00000000000000000000000001010011;
  /*# sim_rtl/controller.vhd:357:33 */
  assign n729 = rflag[5:0]; // extract
  /*# sim_rtl/controller.vhd:356:1 */
  assign n731 = n710 == 32'b00000000000000000000000001010100;
  /*# sim_rtl/controller.vhd:375:31 */
  assign n732 = n618_vindex[0]; // extract
  /*# sim_rtl/controller.vhd:366:1 */
  assign n734 = n710 == 32'b00000000000000000000000001010101;
  /*# sim_rtl/controller.vhd:341:1 */
  assign n735 = {n734, n731, n728, n722, n719, n714};
  /*# sim_rtl/controller.vhd:343:44 */
  assign n736 = n712[3:0]; // extract
  /*# sim_rtl/controller.vhd:351:50 */
  assign n737 = n720[3:0]; // extract
  /*# sim_rtl/controller.vhd:357:33 */
  assign n738 = n729[3:0]; // extract
  /*# sim_rtl/controller.vhd:341:1 */
  always @*
    case (n735)
      6'b100000: n740 = n1966;
      6'b010000: n740 = n738;
      6'b001000: n740 = n723;
      6'b000100: n740 = n737;
      6'b000010: n740 = n716;
      6'b000001: n740 = n736;
      default: n740 = 4'b0000;
    endcase
  /*# sim_rtl/controller.vhd:343:44 */
  assign n741 = n712[4]; // extract
  /*# sim_rtl/controller.vhd:182:12 */
  assign n742 = regs_addr[0]; // extract
  /*# sim_rtl/controller.vhd:351:50 */
  assign n743 = n720[4]; // extract
  /*# sim_rtl/controller.vhd:357:33 */
  assign n744 = n729[4]; // extract
  /*# sim_rtl/controller.vhd:94:5 */
  assign n745 = n1967[0]; // extract
  /*# sim_rtl/controller.vhd:341:1 */
  always @*
    case (n735)
      6'b100000: n747 = n745;
      6'b010000: n747 = n744;
      6'b001000: n747 = regs_wr;
      6'b000100: n747 = n743;
      6'b000010: n747 = n742;
      6'b000001: n747 = n741;
      default: n747 = 1'b0;
    endcase
  /*# sim_rtl/controller.vhd:343:44 */
  assign n748 = n712[5]; // extract
  /*# sim_rtl/controller.vhd:182:12 */
  assign n749 = regs_addr[1]; // extract
  /*# sim_rtl/controller.vhd:351:50 */
  assign n750 = n720[5]; // extract
  /*# sim_rtl/controller.vhd:355:54 */
  assign n751 = n726[0]; // extract
  /*# sim_rtl/controller.vhd:357:33 */
  assign n752 = n729[5]; // extract
  /*# sim_rtl/controller.vhd:94:5 */
  assign n753 = n1967[1]; // extract
  /*# sim_rtl/controller.vhd:341:1 */
  always @*
    case (n735)
      6'b100000: n755 = n753;
      6'b010000: n755 = n752;
      6'b001000: n755 = n751;
      6'b000100: n755 = n750;
      6'b000010: n755 = n749;
      6'b000001: n755 = n748;
      default: n755 = 1'b0;
    endcase
  /*# sim_rtl/controller.vhd:343:44 */
  assign n756 = n712[6]; // extract
  /*# sim_rtl/controller.vhd:182:12 */
  assign n757 = regs_addr[2]; // extract
  /*# sim_rtl/controller.vhd:351:50 */
  assign n758 = n720[6]; // extract
  /*# sim_rtl/controller.vhd:355:54 */
  assign n759 = n726[1]; // extract
  /*# sim_rtl/controller.vhd:94:5 */
  assign n760 = n1967[2]; // extract
  /*# sim_rtl/controller.vhd:341:1 */
  always @*
    case (n735)
      6'b100000: n762 = n760;
      6'b010000: n762 = n1956;
      6'b001000: n762 = n759;
      6'b000100: n762 = n758;
      6'b000010: n762 = n757;
      6'b000001: n762 = n756;
      default: n762 = 1'b0;
    endcase
  /*# sim_rtl/controller.vhd:343:44 */
  assign n763 = n712[7]; // extract
  /*# sim_rtl/controller.vhd:182:12 */
  assign n764 = regs_addr[3]; // extract
  /*# sim_rtl/controller.vhd:351:50 */
  assign n765 = n720[7]; // extract
  /*# sim_rtl/controller.vhd:355:54 */
  assign n766 = n726[2]; // extract
  /*# sim_rtl/controller.vhd:94:5 */
  assign n767 = n1967[3]; // extract
  /*# sim_rtl/controller.vhd:341:1 */
  always @*
    case (n735)
      6'b100000: n769 = n767;
      6'b010000: n769 = n1959;
      6'b001000: n769 = n766;
      6'b000100: n769 = n765;
      6'b000010: n769 = n764;
      6'b000001: n769 = n763;
      default: n769 = 1'b0;
    endcase
  /*# sim_rtl/controller.vhd:343:44 */
  assign n770 = n712[8]; // extract
  /*# sim_rtl/controller.vhd:171:12 */
  assign n771 = slot_voice_addr[0]; // extract
  /*# sim_rtl/controller.vhd:351:50 */
  assign n772 = n720[8]; // extract
  /*# sim_rtl/controller.vhd:355:54 */
  assign n773 = n726[3]; // extract
  /*# sim_rtl/controller.vhd:96:5 */
  assign n774 = n1968[0]; // extract
  /*# sim_rtl/controller.vhd:341:1 */
  always @*
    case (n735)
      6'b100000: n776 = n774;
      6'b010000: n776 = n1960;
      6'b001000: n776 = n773;
      6'b000100: n776 = n772;
      6'b000010: n776 = n771;
      6'b000001: n776 = n770;
      default: n776 = 1'b0;
    endcase
  /*# sim_rtl/controller.vhd:343:44 */
  assign n777 = n712[10:9]; // extract
  /*# sim_rtl/controller.vhd:171:12 */
  assign n778 = slot_voice_addr[2:1]; // extract
  /*# sim_rtl/controller.vhd:351:50 */
  assign n779 = n720[10:9]; // extract
  /*# sim_rtl/controller.vhd:355:54 */
  assign n780 = n726[5:4]; // extract
  /*# sim_rtl/controller.vhd:88:5 */
  assign n781 = n1961[1:0]; // extract
  /*# sim_rtl/controller.vhd:96:5 */
  assign n782 = n1968[2:1]; // extract
  /*# sim_rtl/controller.vhd:341:1 */
  always @*
    case (n735)
      6'b100000: n784 = n782;
      6'b010000: n784 = n781;
      6'b001000: n784 = n780;
      6'b000100: n784 = n779;
      6'b000010: n784 = n778;
      6'b000001: n784 = n777;
      default: n784 = 2'b00;
    endcase
  /*# sim_rtl/controller.vhd:343:44 */
  assign n785 = n712[12:11]; // extract
  /*# sim_rtl/controller.vhd:171:12 */
  assign n786 = slot_voice_addr[4:3]; // extract
  /*# sim_rtl/controller.vhd:351:50 */
  assign n787 = n720[12:11]; // extract
  /*# sim_rtl/controller.vhd:355:54 */
  assign n788 = n726[7:6]; // extract
  /*# sim_rtl/controller.vhd:88:5 */
  assign n789 = n1961[3:2]; // extract
  /*# sim_rtl/controller.vhd:97:5 */
  assign n790 = n1969[1:0]; // extract
  /*# sim_rtl/controller.vhd:341:1 */
  always @*
    case (n735)
      6'b100000: n792 = n790;
      6'b010000: n792 = n789;
      6'b001000: n792 = n788;
      6'b000100: n792 = n787;
      6'b000010: n792 = n786;
      6'b000001: n792 = n785;
      default: n792 = 2'b00;
    endcase
  /*# sim_rtl/controller.vhd:343:44 */
  assign n793 = n712[13]; // extract
  /*# sim_rtl/controller.vhd:171:12 */
  assign n794 = slot_voice_addr[5]; // extract
  /*# sim_rtl/controller.vhd:351:50 */
  assign n795 = n720[13]; // extract
  /*# sim_rtl/controller.vhd:355:54 */
  assign n796 = n726[8]; // extract
  /*# sim_rtl/controller.vhd:89:5 */
  assign n797 = n1962[0]; // extract
  /*# sim_rtl/controller.vhd:97:5 */
  assign n798 = n1969[2]; // extract
  /*# sim_rtl/controller.vhd:341:1 */
  always @*
    case (n735)
      6'b100000: n800 = n798;
      6'b010000: n800 = n797;
      6'b001000: n800 = n796;
      6'b000100: n800 = n795;
      6'b000010: n800 = n794;
      6'b000001: n800 = n793;
      default: n800 = 1'b0;
    endcase
  /*# sim_rtl/controller.vhd:343:44 */
  assign n801 = n712[14]; // extract
  /*# sim_rtl/controller.vhd:351:50 */
  assign n802 = n720[14]; // extract
  /*# sim_rtl/controller.vhd:355:54 */
  assign n803 = n726[9]; // extract
  /*# sim_rtl/controller.vhd:89:5 */
  assign n804 = n1962[1]; // extract
  /*# sim_rtl/controller.vhd:97:5 */
  assign n805 = n1969[3]; // extract
  /*# sim_rtl/controller.vhd:341:1 */
  always @*
    case (n735)
      6'b100000: n807 = n805;
      6'b010000: n807 = n804;
      6'b001000: n807 = n803;
      6'b000100: n807 = n802;
      6'b000010: n807 = n717;
      6'b000001: n807 = n801;
      default: n807 = 1'b0;
    endcase
  /*# sim_rtl/controller.vhd:343:44 */
  assign n808 = n712[15]; // extract
  /*# sim_rtl/controller.vhd:351:50 */
  assign n809 = n720[15]; // extract
  /*# sim_rtl/controller.vhd:355:54 */
  assign n810 = n726[10]; // extract
  /*# sim_rtl/controller.vhd:89:5 */
  assign n811 = n1962[2]; // extract
  /*# sim_rtl/controller.vhd:97:5 */
  assign n812 = n1969[4]; // extract
  /*# sim_rtl/controller.vhd:341:1 */
  always @*
    case (n735)
      6'b100000: n814 = n812;
      6'b010000: n814 = n811;
      6'b001000: n814 = n810;
      6'b000100: n814 = n809;
      6'b000010: n814 = user_voice_wr;
      6'b000001: n814 = n808;
      default: n814 = 1'b0;
    endcase
  /*# sim_rtl/controller.vhd:343:44 */
  assign n815 = n712[19:16]; // extract
  /*# sim_rtl/controller.vhd:351:50 */
  assign n816 = n720[19:16]; // extract
  /*# sim_rtl/controller.vhd:355:54 */
  assign n817 = n726[14:11]; // extract
  /*# sim_rtl/controller.vhd:89:5 */
  assign n818 = n1962[6:3]; // extract
  /*# sim_rtl/controller.vhd:97:5 */
  assign n819 = n1969[8:5]; // extract
  /*# sim_rtl/controller.vhd:341:1 */
  always @*
    case (n735)
      6'b100000: n821 = n819;
      6'b010000: n821 = n818;
      6'b001000: n821 = n817;
      6'b000100: n821 = n816;
      6'b000010: n821 = 4'b0000;
      6'b000001: n821 = n815;
      default: n821 = 4'b0000;
    endcase
  /*# sim_rtl/controller.vhd:343:44 */
  assign n822 = n712[22:20]; // extract
  /*# sim_rtl/controller.vhd:351:50 */
  assign n823 = n720[22:20]; // extract
  /*# sim_rtl/controller.vhd:355:54 */
  assign n824 = n726[17:15]; // extract
  /*# sim_rtl/controller.vhd:98:5 */
  assign n825 = n1970[2:0]; // extract
  /*# sim_rtl/controller.vhd:341:1 */
  always @*
    case (n735)
      6'b100000: n827 = n825;
      6'b010000: n827 = n1963;
      6'b001000: n827 = n824;
      6'b000100: n827 = n823;
      6'b000010: n827 = 3'b000;
      6'b000001: n827 = n822;
      default: n827 = 3'b000;
    endcase
  /*# sim_rtl/controller.vhd:343:44 */
  assign n828 = n712[23]; // extract
  /*# sim_rtl/controller.vhd:351:50 */
  assign n829 = n720[23]; // extract
  /*# sim_rtl/controller.vhd:355:54 */
  assign n830 = n726[18]; // extract
  /*# sim_rtl/controller.vhd:91:5 */
  assign n831 = n1964[0]; // extract
  /*# sim_rtl/controller.vhd:98:5 */
  assign n832 = n1970[3]; // extract
  /*# sim_rtl/controller.vhd:341:1 */
  always @*
    case (n735)
      6'b100000: n834 = n832;
      6'b010000: n834 = n831;
      6'b001000: n834 = n830;
      6'b000100: n834 = n829;
      6'b000010: n834 = 1'b0;
      6'b000001: n834 = n828;
      default: n834 = 1'b0;
    endcase
  /*# sim_rtl/controller.vhd:343:44 */
  assign n835 = n712[24]; // extract
  /*# sim_rtl/controller.vhd:351:50 */
  assign n836 = n720[24]; // extract
  /*# sim_rtl/controller.vhd:355:54 */
  assign n837 = n726[19]; // extract
  /*# sim_rtl/controller.vhd:91:5 */
  assign n838 = n1964[1]; // extract
  /*# sim_rtl/controller.vhd:341:1 */
  always @*
    case (n735)
      6'b100000: n840 = n1971;
      6'b010000: n840 = n838;
      6'b001000: n840 = n837;
      6'b000100: n840 = n836;
      6'b000010: n840 = 1'b0;
      6'b000001: n840 = n835;
      default: n840 = 1'b0;
    endcase
  /*# sim_rtl/controller.vhd:343:44 */
  assign n841 = n712[25]; // extract
  /*# sim_rtl/controller.vhd:351:50 */
  assign n842 = n720[25]; // extract
  /*# sim_rtl/controller.vhd:355:54 */
  assign n843 = n726[20]; // extract
  /*# sim_rtl/controller.vhd:91:5 */
  assign n844 = n1964[2]; // extract
  /*# sim_rtl/controller.vhd:341:1 */
  always @*
    case (n735)
      6'b100000: n846 = n1972;
      6'b010000: n846 = n844;
      6'b001000: n846 = n843;
      6'b000100: n846 = n842;
      6'b000010: n846 = 1'b0;
      6'b000001: n846 = n841;
      default: n846 = 1'b0;
    endcase
  /*# sim_rtl/controller.vhd:343:44 */
  assign n847 = n712[26]; // extract
  /*# sim_rtl/controller.vhd:351:50 */
  assign n848 = n720[26]; // extract
  /*# sim_rtl/controller.vhd:355:54 */
  assign n849 = n726[21]; // extract
  /*# sim_rtl/controller.vhd:91:5 */
  assign n850 = n1964[3]; // extract
  /*# sim_rtl/controller.vhd:341:1 */
  always @*
    case (n735)
      6'b100000: n852 = n618_extra_mode;
      6'b010000: n852 = n850;
      6'b001000: n852 = n849;
      6'b000100: n852 = n848;
      6'b000010: n852 = 1'b0;
      6'b000001: n852 = n847;
      default: n852 = 1'b0;
    endcase
  /*# sim_rtl/controller.vhd:343:44 */
  assign n853 = n712[27]; // extract
  /*# sim_rtl/controller.vhd:351:50 */
  assign n854 = n720[27]; // extract
  /*# sim_rtl/controller.vhd:92:5 */
  assign n855 = n1965[0]; // extract
  /*# sim_rtl/controller.vhd:341:1 */
  always @*
    case (n735)
      6'b100000: n857 = n732;
      6'b010000: n857 = n855;
      6'b001000: n857 = 1'b0;
      6'b000100: n857 = n854;
      6'b000010: n857 = 1'b0;
      6'b000001: n857 = n853;
      default: n857 = 1'b0;
    endcase
  /*# sim_rtl/controller.vhd:343:44 */
  assign n858 = n712[30:28]; // extract
  /*# sim_rtl/controller.vhd:351:50 */
  assign n859 = n720[30:28]; // extract
  /*# sim_rtl/controller.vhd:92:5 */
  assign n860 = n1965[3:1]; // extract
  /*# sim_rtl/controller.vhd:341:1 */
  always @*
    case (n735)
      6'b100000: n862 = 3'b000;
      6'b010000: n862 = n860;
      6'b001000: n862 = 3'b000;
      6'b000100: n862 = n859;
      6'b000010: n862 = 3'b000;
      6'b000001: n862 = n858;
      default: n862 = 3'b000;
    endcase
  /*# sim_rtl/controller.vhd:343:44 */
  assign n863 = n712[31]; // extract
  /*# sim_rtl/controller.vhd:351:50 */
  assign n864 = n720[31]; // extract
  /*# sim_rtl/controller.vhd:341:1 */
  always @*
    case (n735)
      6'b100000: n866 = 1'b0;
      6'b010000: n866 = 1'b0;
      6'b001000: n866 = 1'b0;
      6'b000100: n866 = n864;
      6'b000010: n866 = 1'b0;
      6'b000001: n866 = n863;
      default: n866 = 1'b0;
    endcase
  /*# sim_rtl/controller.vhd:340:1 */
  assign n867 = {n866, n862, n857, n852, n846, n840, n834, n827, n821, n814, n807, n800, n792, n784, n776, n769, n762, n755, n747, n740};
  /*# sim_rtl/controller.vhd:340:1 */
  assign n869 = ss_read ? n867 : 32'b00000000000000000000000000000000;
  /*# sim_rtl/controller.vhd:379:6 */
  assign n870 = {24'b0, ss_addr};  // uext
  /*# sim_rtl/controller.vhd:237:10 */
  assign n871 = {n675, ss_wdata};
  /*# sim_rtl/controller.vhd:382:46 */
  assign n872 = n871[3:0]; // extract
  /*# sim_rtl/controller.vhd:237:10 */
  assign n874 = {n675, ss_wdata};
  /*# sim_rtl/controller.vhd:383:46 */
  assign n875 = n874[7:4]; // extract
  /*# sim_rtl/controller.vhd:237:10 */
  assign n877 = {n675, ss_wdata};
  /*# sim_rtl/controller.vhd:384:46 */
  assign n878 = n877[11:8]; // extract
  /*# sim_rtl/controller.vhd:237:10 */
  assign n880 = {n675, ss_wdata};
  /*# sim_rtl/controller.vhd:385:46 */
  assign n881 = n880[15:12]; // extract
  /*# sim_rtl/controller.vhd:237:10 */
  assign n883 = {n675, ss_wdata};
  /*# sim_rtl/controller.vhd:386:46 */
  assign n884 = n883[19:16]; // extract
  /*# sim_rtl/controller.vhd:237:10 */
  assign n886 = {n675, ss_wdata};
  /*# sim_rtl/controller.vhd:387:46 */
  assign n887 = n886[23:20]; // extract
  /*# sim_rtl/controller.vhd:237:10 */
  assign n889 = {n675, ss_wdata};
  /*# sim_rtl/controller.vhd:388:46 */
  assign n890 = n889[27:24]; // extract
  /*# sim_rtl/controller.vhd:237:10 */
  assign n892 = {n675, ss_wdata};
  /*# sim_rtl/controller.vhd:389:46 */
  assign n893 = n892[31:28]; // extract
  /*# sim_rtl/controller.vhd:237:10 */
  assign n895 = {n675, ss_wdata};
  /*# sim_rtl/controller.vhd:390:46 */
  assign n896 = n895[35:32]; // extract
  /*# sim_rtl/controller.vhd:380:1 */
  assign n899 = n870 == 32'b00000000000000000000000001010000;
  /*# sim_rtl/controller.vhd:392:42 */
  assign n900 = ss_wdata[3:0]; // extract
  /*# sim_rtl/controller.vhd:237:10 */
  assign n901 = {n900, n673, n671, n669, n667, n665, n663, n661, n659};
  /*# sim_rtl/controller.vhd:393:46 */
  assign n902 = n901[3:0]; // extract
  /*# sim_rtl/controller.vhd:237:10 */
  assign n904 = {n900, n673, n671, n669, n667, n665, n663, n661, n659};
  /*# sim_rtl/controller.vhd:394:46 */
  assign n905 = n904[7:4]; // extract
  /*# sim_rtl/controller.vhd:237:10 */
  assign n907 = {n900, n673, n671, n669, n667, n665, n663, n661, n659};
  /*# sim_rtl/controller.vhd:395:46 */
  assign n908 = n907[11:8]; // extract
  /*# sim_rtl/controller.vhd:237:10 */
  assign n910 = {n900, n673, n671, n669, n667, n665, n663, n661, n659};
  /*# sim_rtl/controller.vhd:396:46 */
  assign n911 = n910[15:12]; // extract
  /*# sim_rtl/controller.vhd:237:10 */
  assign n913 = {n900, n673, n671, n669, n667, n665, n663, n661, n659};
  /*# sim_rtl/controller.vhd:397:46 */
  assign n914 = n913[19:16]; // extract
  /*# sim_rtl/controller.vhd:237:10 */
  assign n916 = {n900, n673, n671, n669, n667, n665, n663, n661, n659};
  /*# sim_rtl/controller.vhd:398:46 */
  assign n917 = n916[23:20]; // extract
  /*# sim_rtl/controller.vhd:237:10 */
  assign n919 = {n900, n673, n671, n669, n667, n665, n663, n661, n659};
  /*# sim_rtl/controller.vhd:399:46 */
  assign n920 = n919[27:24]; // extract
  /*# sim_rtl/controller.vhd:237:10 */
  assign n922 = {n900, n673, n671, n669, n667, n665, n663, n661, n659};
  /*# sim_rtl/controller.vhd:400:46 */
  assign n923 = n922[31:28]; // extract
  /*# sim_rtl/controller.vhd:237:10 */
  assign n925 = {n900, n673, n671, n669, n667, n665, n663, n661, n659};
  /*# sim_rtl/controller.vhd:401:46 */
  assign n926 = n925[35:32]; // extract
  /*# sim_rtl/controller.vhd:402:39 */
  assign n928 = ss_wdata[7:4]; // extract
  /*# sim_rtl/controller.vhd:404:45 */
  assign n929 = ss_wdata[13:8]; // extract
  /*# sim_rtl/controller.vhd:406:36 */
  assign n931 = ss_wdata[14]; // extract
  /*# sim_rtl/controller.vhd:240:10 */
  assign n932 = user_voice_addr[5:1]; // extract
  /*# sim_rtl/controller.vhd:240:10 */
  assign n933 = {n932, n931};
  /*# sim_rtl/controller.vhd:408:34 */
  assign n935 = ss_wdata[15]; // extract
  /*# sim_rtl/controller.vhd:391:1 */
  assign n937 = n870 == 32'b00000000000000000000000001010001;
  /*# sim_rtl/controller.vhd:242:10 */
  assign n943 = n708[35:32]; // extract
  /*# sim_rtl/controller.vhd:242:10 */
  assign n944 = {n943, ss_wdata};
  /*# sim_rtl/vm2413.vhd:186:19 */
  assign n945 = n944[35]; // extract
  /*# sim_rtl/controller.vhd:242:10 */
  assign n946 = n708[35:32]; // extract
  /*# sim_rtl/controller.vhd:242:10 */
  assign n947 = {n946, ss_wdata};
  /*# sim_rtl/vm2413.vhd:186:37 */
  assign n948 = n947[34]; // extract
  /*# sim_rtl/controller.vhd:242:10 */
  assign n949 = n708[35:32]; // extract
  /*# sim_rtl/controller.vhd:242:10 */
  assign n950 = {n949, ss_wdata};
  /*# sim_rtl/vm2413.vhd:186:55 */
  assign n951 = n950[33]; // extract
  /*# sim_rtl/controller.vhd:242:10 */
  assign n952 = n708[35:32]; // extract
  /*# sim_rtl/controller.vhd:242:10 */
  assign n953 = {n952, ss_wdata};
  /*# sim_rtl/vm2413.vhd:186:73 */
  assign n954 = n953[32]; // extract
  /*# sim_rtl/controller.vhd:242:10 */
  assign n955 = n708[35:32]; // extract
  /*# sim_rtl/controller.vhd:242:10 */
  assign n956 = {n955, ss_wdata};
  /*# sim_rtl/vm2413.vhd:187:19 */
  assign n957 = n956[31:28]; // extract
  /*# sim_rtl/controller.vhd:242:10 */
  assign n958 = n708[35:32]; // extract
  /*# sim_rtl/controller.vhd:242:10 */
  assign n959 = {n958, ss_wdata};
  /*# sim_rtl/vm2413.vhd:187:47 */
  assign n960 = n959[27:26]; // extract
  /*# sim_rtl/controller.vhd:242:10 */
  assign n961 = n708[35:32]; // extract
  /*# sim_rtl/controller.vhd:242:10 */
  assign n962 = {n961, ss_wdata};
  /*# sim_rtl/vm2413.vhd:187:75 */
  assign n963 = n962[25:20]; // extract
  /*# sim_rtl/controller.vhd:242:10 */
  assign n964 = n708[35:32]; // extract
  /*# sim_rtl/controller.vhd:242:10 */
  assign n965 = {n964, ss_wdata};
  /*# sim_rtl/vm2413.vhd:188:19 */
  assign n966 = n965[19]; // extract
  /*# sim_rtl/controller.vhd:242:10 */
  assign n967 = n708[35:32]; // extract
  /*# sim_rtl/controller.vhd:242:10 */
  assign n968 = {n967, ss_wdata};
  /*# sim_rtl/vm2413.vhd:188:37 */
  assign n969 = n968[18:16]; // extract
  /*# sim_rtl/controller.vhd:242:10 */
  assign n970 = n708[35:32]; // extract
  /*# sim_rtl/controller.vhd:242:10 */
  assign n971 = {n970, ss_wdata};
  /*# sim_rtl/vm2413.vhd:189:19 */
  assign n972 = n971[15:12]; // extract
  /*# sim_rtl/controller.vhd:242:10 */
  assign n973 = n708[35:32]; // extract
  /*# sim_rtl/controller.vhd:242:10 */
  assign n974 = {n973, ss_wdata};
  /*# sim_rtl/vm2413.vhd:189:47 */
  assign n975 = n974[11:8]; // extract
  /*# sim_rtl/controller.vhd:242:10 */
  assign n976 = n708[35:32]; // extract
  /*# sim_rtl/controller.vhd:242:10 */
  assign n977 = {n976, ss_wdata};
  /*# sim_rtl/vm2413.vhd:189:74 */
  assign n978 = n977[7:4]; // extract
  /*# sim_rtl/controller.vhd:242:10 */
  assign n979 = n708[35:32]; // extract
  /*# sim_rtl/controller.vhd:242:10 */
  assign n980 = {n979, ss_wdata};
  /*# sim_rtl/vm2413.vhd:189:100 */
  assign n981 = n980[3:0]; // extract
  /*# sim_rtl/vm2413.vhd:185:12 */
  assign n982 = {n981, n978, n975, n972, n969, n966, n963, n960, n957, n954, n951, n948, n945};
  /*# sim_rtl/controller.vhd:410:1 */
  assign n984 = n870 == 32'b00000000000000000000000001010010;
  /*# sim_rtl/controller.vhd:414:48 */
  assign n985 = ss_wdata[3:0]; // extract
  /*# sim_rtl/controller.vhd:242:10 */
  assign n991 = n708[31:0]; // extract
  /*# sim_rtl/controller.vhd:242:10 */
  assign n992 = {n985, n991};
  /*# sim_rtl/vm2413.vhd:186:19 */
  assign n993 = n992[35]; // extract
  /*# sim_rtl/controller.vhd:242:10 */
  assign n994 = n708[31:0]; // extract
  /*# sim_rtl/controller.vhd:242:10 */
  assign n995 = {n985, n994};
  /*# sim_rtl/vm2413.vhd:186:37 */
  assign n996 = n995[34]; // extract
  /*# sim_rtl/controller.vhd:242:10 */
  assign n997 = n708[31:0]; // extract
  /*# sim_rtl/controller.vhd:242:10 */
  assign n998 = {n985, n997};
  /*# sim_rtl/vm2413.vhd:186:55 */
  assign n999 = n998[33]; // extract
  /*# sim_rtl/controller.vhd:242:10 */
  assign n1000 = n708[31:0]; // extract
  /*# sim_rtl/controller.vhd:242:10 */
  assign n1001 = {n985, n1000};
  /*# sim_rtl/vm2413.vhd:186:73 */
  assign n1002 = n1001[32]; // extract
  /*# sim_rtl/controller.vhd:242:10 */
  assign n1003 = n708[31:0]; // extract
  /*# sim_rtl/controller.vhd:242:10 */
  assign n1004 = {n985, n1003};
  /*# sim_rtl/vm2413.vhd:187:19 */
  assign n1005 = n1004[31:28]; // extract
  /*# sim_rtl/controller.vhd:242:10 */
  assign n1006 = n708[31:0]; // extract
  /*# sim_rtl/controller.vhd:242:10 */
  assign n1007 = {n985, n1006};
  /*# sim_rtl/vm2413.vhd:187:47 */
  assign n1008 = n1007[27:26]; // extract
  /*# sim_rtl/controller.vhd:242:10 */
  assign n1009 = n708[31:0]; // extract
  /*# sim_rtl/controller.vhd:242:10 */
  assign n1010 = {n985, n1009};
  /*# sim_rtl/vm2413.vhd:187:75 */
  assign n1011 = n1010[25:20]; // extract
  /*# sim_rtl/controller.vhd:242:10 */
  assign n1012 = n708[31:0]; // extract
  /*# sim_rtl/controller.vhd:242:10 */
  assign n1013 = {n985, n1012};
  /*# sim_rtl/vm2413.vhd:188:19 */
  assign n1014 = n1013[19]; // extract
  /*# sim_rtl/controller.vhd:242:10 */
  assign n1015 = n708[31:0]; // extract
  /*# sim_rtl/controller.vhd:242:10 */
  assign n1016 = {n985, n1015};
  /*# sim_rtl/vm2413.vhd:188:37 */
  assign n1017 = n1016[18:16]; // extract
  /*# sim_rtl/controller.vhd:242:10 */
  assign n1018 = n708[31:0]; // extract
  /*# sim_rtl/controller.vhd:242:10 */
  assign n1019 = {n985, n1018};
  /*# sim_rtl/vm2413.vhd:189:19 */
  assign n1020 = n1019[15:12]; // extract
  /*# sim_rtl/controller.vhd:242:10 */
  assign n1021 = n708[31:0]; // extract
  /*# sim_rtl/controller.vhd:242:10 */
  assign n1022 = {n985, n1021};
  /*# sim_rtl/vm2413.vhd:189:47 */
  assign n1023 = n1022[11:8]; // extract
  /*# sim_rtl/controller.vhd:242:10 */
  assign n1024 = n708[31:0]; // extract
  /*# sim_rtl/controller.vhd:242:10 */
  assign n1025 = {n985, n1024};
  /*# sim_rtl/vm2413.vhd:189:74 */
  assign n1026 = n1025[7:4]; // extract
  /*# sim_rtl/controller.vhd:242:10 */
  assign n1027 = n708[31:0]; // extract
  /*# sim_rtl/controller.vhd:242:10 */
  assign n1028 = {n985, n1027};
  /*# sim_rtl/vm2413.vhd:189:100 */
  assign n1029 = n1028[3:0]; // extract
  /*# sim_rtl/vm2413.vhd:185:12 */
  assign n1030 = {n1029, n1026, n1023, n1020, n1017, n1014, n1011, n1008, n1005, n1002, n999, n996, n993};
  /*# sim_rtl/controller.vhd:416:28 */
  assign n1031 = ss_wdata[4]; // extract
  /*# sim_rtl/controller.vhd:418:80 */
  assign n1033 = ss_wdata[18:5]; // extract
  /*# sim_rtl/controller.vhd:418:136 */
  assign n1034 = ss_wdata[26:19]; // extract
  /*# sim_rtl/controller.vhd:244:10 */
  assign n1035 = {n1034, 2'b00, n1033};
  /*# sim_rtl/controller.vhd:413:1 */
  assign n1037 = n870 == 32'b00000000000000000000000001010011;
  /*# sim_rtl/controller.vhd:421:35 */
  assign n1038 = ss_wdata[5:0]; // extract
  /*# sim_rtl/controller.vhd:245:10 */
  assign n1039 = rflag[7:6]; // extract
  /*# sim_rtl/controller.vhd:245:10 */
  assign n1040 = {n1039, n1038};
  /*# sim_rtl/controller.vhd:423:23 */
  assign n1041 = ss_wdata[6]; // extract
  /*# sim_rtl/controller.vhd:425:23 */
  assign n1042 = ss_wdata[7]; // extract
  /*# sim_rtl/controller.vhd:427:23 */
  assign n1043 = ss_wdata[8]; // extract
  /*# sim_rtl/controller.vhd:429:32 */
  assign n1044 = ss_wdata[12:9]; // extract
  /*# sim_rtl/controller.vhd:431:32 */
  assign n1045 = ss_wdata[19:13]; // extract
  /*# sim_rtl/controller.vhd:433:32 */
  assign n1046 = ss_wdata[22:20]; // extract
  /*# sim_rtl/controller.vhd:435:32 */
  assign n1047 = ss_wdata[26:23]; // extract
  /*# sim_rtl/controller.vhd:437:32 */
  assign n1048 = ss_wdata[30:27]; // extract
  /*# sim_rtl/controller.vhd:420:1 */
  assign n1050 = n870 == 32'b00000000000000000000000001010100;
  /*# sim_rtl/controller.vhd:440:32 */
  assign n1051 = ss_wdata[3:0]; // extract
  /*# sim_rtl/controller.vhd:442:32 */
  assign n1052 = ss_wdata[7:4]; // extract
  /*# sim_rtl/controller.vhd:444:33 */
  assign n1053 = ss_wdata[10:8]; // extract
  /*# sim_rtl/controller.vhd:446:34 */
  assign n1054 = ss_wdata[19:11]; // extract
  /*# sim_rtl/controller.vhd:448:33 */
  assign n1055 = ss_wdata[23:20]; // extract
  /*# sim_rtl/controller.vhd:450:24 */
  assign n1056 = ss_wdata[24]; // extract
  /*# sim_rtl/controller.vhd:452:27 */
  assign n1057 = ss_wdata[25]; // extract
  /*# sim_rtl/controller.vhd:454:31 */
  assign n1058 = ss_wdata[26]; // extract
  /*# sim_rtl/controller.vhd:456:27 */
  assign n1059 = ss_wdata[27]; // extract
  /*# sim_rtl/controller.vhd:262:10 */
  assign n1060 = n618_vindex[5:1]; // extract
  /*# sim_rtl/controller.vhd:262:10 */
  assign n1061 = {n1060, n1059};
  /*# sim_rtl/controller.vhd:439:1 */
  assign n1064 = n870 == 32'b00000000000000000000000001010101;
  /*# sim_rtl/controller.vhd:379:1 */
  assign n1065 = {n1064, n1050, n1037, n984, n937, n899};
  /*# sim_rtl/controller.vhd:379:1 */
  always @*
    case (n1065)
      6'b100000: n1066 = n1956;
      6'b010000: n1066 = n1041;
      6'b001000: n1066 = n1956;
      6'b000100: n1066 = n1956;
      6'b000010: n1066 = n1956;
      6'b000001: n1066 = n1956;
      default: n1066 = n1956;
    endcase
  /*# sim_rtl/controller.vhd:379:1 */
  always @*
    case (n1065)
      6'b100000: n1067 = n1959;
      6'b010000: n1067 = n1042;
      6'b001000: n1067 = n1959;
      6'b000100: n1067 = n1959;
      6'b000010: n1067 = n1959;
      6'b000001: n1067 = n1959;
      default: n1067 = n1959;
    endcase
  /*# sim_rtl/controller.vhd:379:1 */
  always @*
    case (n1065)
      6'b100000: n1068 = n1960;
      6'b010000: n1068 = n1043;
      6'b001000: n1068 = n1960;
      6'b000100: n1068 = n1960;
      6'b000010: n1068 = n1960;
      6'b000001: n1068 = n1960;
      default: n1068 = n1960;
    endcase
  /*# sim_rtl/controller.vhd:379:1 */
  always @*
    case (n1065)
      6'b100000: n1069 = n1961;
      6'b010000: n1069 = n1044;
      6'b001000: n1069 = n1961;
      6'b000100: n1069 = n1961;
      6'b000010: n1069 = n1961;
      6'b000001: n1069 = n1961;
      default: n1069 = n1961;
    endcase
  /*# sim_rtl/controller.vhd:379:1 */
  always @*
    case (n1065)
      6'b100000: n1070 = n1962;
      6'b010000: n1070 = n1045;
      6'b001000: n1070 = n1962;
      6'b000100: n1070 = n1962;
      6'b000010: n1070 = n1962;
      6'b000001: n1070 = n1962;
      default: n1070 = n1962;
    endcase
  /*# sim_rtl/controller.vhd:379:1 */
  always @*
    case (n1065)
      6'b100000: n1071 = n1963;
      6'b010000: n1071 = n1046;
      6'b001000: n1071 = n1963;
      6'b000100: n1071 = n1963;
      6'b000010: n1071 = n1963;
      6'b000001: n1071 = n1963;
      default: n1071 = n1963;
    endcase
  /*# sim_rtl/controller.vhd:379:1 */
  always @*
    case (n1065)
      6'b100000: n1072 = n1964;
      6'b010000: n1072 = n1047;
      6'b001000: n1072 = n1964;
      6'b000100: n1072 = n1964;
      6'b000010: n1072 = n1964;
      6'b000001: n1072 = n1964;
      default: n1072 = n1964;
    endcase
  /*# sim_rtl/controller.vhd:379:1 */
  always @*
    case (n1065)
      6'b100000: n1073 = n1965;
      6'b010000: n1073 = n1048;
      6'b001000: n1073 = n1965;
      6'b000100: n1073 = n1965;
      6'b000010: n1073 = n1965;
      6'b000001: n1073 = n1965;
      default: n1073 = n1965;
    endcase
  /*# sim_rtl/controller.vhd:379:1 */
  always @*
    case (n1065)
      6'b100000: n1074 = n1051;
      6'b010000: n1074 = n1966;
      6'b001000: n1074 = n1966;
      6'b000100: n1074 = n1966;
      6'b000010: n1074 = n1966;
      6'b000001: n1074 = n1966;
      default: n1074 = n1966;
    endcase
  /*# sim_rtl/controller.vhd:379:1 */
  always @*
    case (n1065)
      6'b100000: n1075 = n1052;
      6'b010000: n1075 = n1967;
      6'b001000: n1075 = n1967;
      6'b000100: n1075 = n1967;
      6'b000010: n1075 = n1967;
      6'b000001: n1075 = n1967;
      default: n1075 = n1967;
    endcase
  /*# sim_rtl/controller.vhd:379:1 */
  always @*
    case (n1065)
      6'b100000: n1076 = n1053;
      6'b010000: n1076 = n1968;
      6'b001000: n1076 = n1968;
      6'b000100: n1076 = n1968;
      6'b000010: n1076 = n1968;
      6'b000001: n1076 = n1968;
      default: n1076 = n1968;
    endcase
  /*# sim_rtl/controller.vhd:379:1 */
  always @*
    case (n1065)
      6'b100000: n1077 = n1054;
      6'b010000: n1077 = n1969;
      6'b001000: n1077 = n1969;
      6'b000100: n1077 = n1969;
      6'b000010: n1077 = n1969;
      6'b000001: n1077 = n1969;
      default: n1077 = n1969;
    endcase
  /*# sim_rtl/controller.vhd:379:1 */
  always @*
    case (n1065)
      6'b100000: n1078 = n1055;
      6'b010000: n1078 = n1970;
      6'b001000: n1078 = n1970;
      6'b000100: n1078 = n1970;
      6'b000010: n1078 = n1970;
      6'b000001: n1078 = n1970;
      default: n1078 = n1970;
    endcase
  /*# sim_rtl/controller.vhd:379:1 */
  always @*
    case (n1065)
      6'b100000: n1079 = n1056;
      6'b010000: n1079 = n1971;
      6'b001000: n1079 = n1971;
      6'b000100: n1079 = n1971;
      6'b000010: n1079 = n1971;
      6'b000001: n1079 = n1971;
      default: n1079 = n1971;
    endcase
  /*# sim_rtl/controller.vhd:379:1 */
  always @*
    case (n1065)
      6'b100000: n1080 = n1057;
      6'b010000: n1080 = n1972;
      6'b001000: n1080 = n1972;
      6'b000100: n1080 = n1972;
      6'b000010: n1080 = n1972;
      6'b000001: n1080 = n1972;
      default: n1080 = n1972;
    endcase
  /*# sim_rtl/controller.vhd:160:12 */
  assign n1081 = inst_cache[3:0]; // extract
  /*# sim_rtl/controller.vhd:379:1 */
  always @*
    case (n1065)
      6'b100000: n1082 = n1081;
      6'b010000: n1082 = n1081;
      6'b001000: n1082 = n1081;
      6'b000100: n1082 = n1081;
      6'b000010: n1082 = n926;
      6'b000001: n1082 = n896;
      default: n1082 = n1081;
    endcase
  /*# sim_rtl/controller.vhd:160:12 */
  assign n1083 = inst_cache[7:4]; // extract
  /*# sim_rtl/controller.vhd:379:1 */
  always @*
    case (n1065)
      6'b100000: n1084 = n1083;
      6'b010000: n1084 = n1083;
      6'b001000: n1084 = n1083;
      6'b000100: n1084 = n1083;
      6'b000010: n1084 = n923;
      6'b000001: n1084 = n893;
      default: n1084 = n1083;
    endcase
  /*# sim_rtl/controller.vhd:160:12 */
  assign n1085 = inst_cache[11:8]; // extract
  /*# sim_rtl/controller.vhd:379:1 */
  always @*
    case (n1065)
      6'b100000: n1086 = n1085;
      6'b010000: n1086 = n1085;
      6'b001000: n1086 = n1085;
      6'b000100: n1086 = n1085;
      6'b000010: n1086 = n920;
      6'b000001: n1086 = n890;
      default: n1086 = n1085;
    endcase
  /*# sim_rtl/controller.vhd:160:12 */
  assign n1087 = inst_cache[15:12]; // extract
  /*# sim_rtl/controller.vhd:379:1 */
  always @*
    case (n1065)
      6'b100000: n1088 = n1087;
      6'b010000: n1088 = n1087;
      6'b001000: n1088 = n1087;
      6'b000100: n1088 = n1087;
      6'b000010: n1088 = n917;
      6'b000001: n1088 = n887;
      default: n1088 = n1087;
    endcase
  /*# sim_rtl/controller.vhd:160:12 */
  assign n1089 = inst_cache[19:16]; // extract
  /*# sim_rtl/controller.vhd:379:1 */
  always @*
    case (n1065)
      6'b100000: n1090 = n1089;
      6'b010000: n1090 = n1089;
      6'b001000: n1090 = n1089;
      6'b000100: n1090 = n1089;
      6'b000010: n1090 = n914;
      6'b000001: n1090 = n884;
      default: n1090 = n1089;
    endcase
  /*# sim_rtl/controller.vhd:160:12 */
  assign n1091 = inst_cache[23:20]; // extract
  /*# sim_rtl/controller.vhd:379:1 */
  always @*
    case (n1065)
      6'b100000: n1092 = n1091;
      6'b010000: n1092 = n1091;
      6'b001000: n1092 = n1091;
      6'b000100: n1092 = n1091;
      6'b000010: n1092 = n911;
      6'b000001: n1092 = n881;
      default: n1092 = n1091;
    endcase
  /*# sim_rtl/controller.vhd:160:12 */
  assign n1093 = inst_cache[27:24]; // extract
  /*# sim_rtl/controller.vhd:379:1 */
  always @*
    case (n1065)
      6'b100000: n1094 = n1093;
      6'b010000: n1094 = n1093;
      6'b001000: n1094 = n1093;
      6'b000100: n1094 = n1093;
      6'b000010: n1094 = n908;
      6'b000001: n1094 = n878;
      default: n1094 = n1093;
    endcase
  /*# sim_rtl/controller.vhd:160:12 */
  assign n1095 = inst_cache[31:28]; // extract
  /*# sim_rtl/controller.vhd:379:1 */
  always @*
    case (n1065)
      6'b100000: n1096 = n1095;
      6'b010000: n1096 = n1095;
      6'b001000: n1096 = n1095;
      6'b000100: n1096 = n1095;
      6'b000010: n1096 = n905;
      6'b000001: n1096 = n875;
      default: n1096 = n1095;
    endcase
  /*# sim_rtl/controller.vhd:160:12 */
  assign n1097 = inst_cache[35:32]; // extract
  /*# sim_rtl/controller.vhd:379:1 */
  always @*
    case (n1065)
      6'b100000: n1098 = n1097;
      6'b010000: n1098 = n1097;
      6'b001000: n1098 = n1097;
      6'b000100: n1098 = n1097;
      6'b000010: n1098 = n902;
      6'b000001: n1098 = n872;
      default: n1098 = n1097;
    endcase
  /*# sim_rtl/controller.vhd:379:1 */
  always @*
    case (n1065)
      6'b100000: n1099 = slot_voice_addr;
      6'b010000: n1099 = slot_voice_addr;
      6'b001000: n1099 = slot_voice_addr;
      6'b000100: n1099 = slot_voice_addr;
      6'b000010: n1099 = n929;
      6'b000001: n1099 = slot_voice_addr;
      default: n1099 = slot_voice_addr;
    endcase
  /*# sim_rtl/controller.vhd:379:1 */
  always @*
    case (n1065)
      6'b100000: n1100 = user_voice_wr;
      6'b010000: n1100 = user_voice_wr;
      6'b001000: n1100 = user_voice_wr;
      6'b000100: n1100 = user_voice_wr;
      6'b000010: n1100 = n935;
      6'b000001: n1100 = user_voice_wr;
      default: n1100 = user_voice_wr;
    endcase
  /*# sim_rtl/controller.vhd:379:1 */
  always @*
    case (n1065)
      6'b100000: n1101 = user_voice_addr;
      6'b010000: n1101 = user_voice_addr;
      6'b001000: n1101 = user_voice_addr;
      6'b000100: n1101 = user_voice_addr;
      6'b000010: n1101 = n933;
      6'b000001: n1101 = user_voice_addr;
      default: n1101 = user_voice_addr;
    endcase
  /*# sim_rtl/controller.vhd:379:1 */
  always @*
    case (n1065)
      6'b100000: n1102 = user_voice_wdata;
      6'b010000: n1102 = user_voice_wdata;
      6'b001000: n1102 = n1030;
      6'b000100: n1102 = n982;
      6'b000010: n1102 = user_voice_wdata;
      6'b000001: n1102 = user_voice_wdata;
      default: n1102 = user_voice_wdata;
    endcase
  /*# sim_rtl/controller.vhd:379:1 */
  always @*
    case (n1065)
      6'b100000: n1103 = regs_wr;
      6'b010000: n1103 = regs_wr;
      6'b001000: n1103 = n1031;
      6'b000100: n1103 = regs_wr;
      6'b000010: n1103 = regs_wr;
      6'b000001: n1103 = regs_wr;
      default: n1103 = regs_wr;
    endcase
  /*# sim_rtl/controller.vhd:379:1 */
  always @*
    case (n1065)
      6'b100000: n1104 = regs_addr;
      6'b010000: n1104 = regs_addr;
      6'b001000: n1104 = regs_addr;
      6'b000100: n1104 = regs_addr;
      6'b000010: n1104 = n928;
      6'b000001: n1104 = regs_addr;
      default: n1104 = regs_addr;
    endcase
  /*# sim_rtl/controller.vhd:379:1 */
  always @*
    case (n1065)
      6'b100000: n1105 = regs_wdata;
      6'b010000: n1105 = regs_wdata;
      6'b001000: n1105 = n1035;
      6'b000100: n1105 = regs_wdata;
      6'b000010: n1105 = regs_wdata;
      6'b000001: n1105 = regs_wdata;
      default: n1105 = regs_wdata;
    endcase
  /*# sim_rtl/controller.vhd:379:1 */
  always @*
    case (n1065)
      6'b100000: n1106 = rflag;
      6'b010000: n1106 = n1040;
      6'b001000: n1106 = rflag;
      6'b000100: n1106 = rflag;
      6'b000010: n1106 = rflag;
      6'b000001: n1106 = rflag;
      default: n1106 = rflag;
    endcase
  /*# sim_rtl/controller.vhd:379:1 */
  always @*
    case (n1065)
      6'b100000: n1107 = n1058;
      6'b010000: n1107 = n618_extra_mode;
      6'b001000: n1107 = n618_extra_mode;
      6'b000100: n1107 = n618_extra_mode;
      6'b000010: n1107 = n618_extra_mode;
      6'b000001: n1107 = n618_extra_mode;
      default: n1107 = n618_extra_mode;
    endcase
  /*# sim_rtl/controller.vhd:379:1 */
  always @*
    case (n1065)
      6'b100000: n1108 = n1061;
      6'b010000: n1108 = n618_vindex;
      6'b001000: n1108 = n618_vindex;
      6'b000100: n1108 = n618_vindex;
      6'b000010: n1108 = n618_vindex;
      6'b000001: n1108 = n618_vindex;
      default: n1108 = n618_vindex;
    endcase
  /*# sim_rtl/controller.vhd:304:1 */
  assign n1148 = n1211 ? n1066 : n1956;
  /*# sim_rtl/controller.vhd:304:1 */
  assign n1149 = n1212 ? n1067 : n1959;
  /*# sim_rtl/controller.vhd:304:1 */
  assign n1150 = n1213 ? n1068 : n1960;
  /*# sim_rtl/controller.vhd:304:1 */
  assign n1151 = n1214 ? n1069 : n1961;
  /*# sim_rtl/controller.vhd:304:1 */
  assign n1152 = n1215 ? n1070 : n1962;
  /*# sim_rtl/controller.vhd:304:1 */
  assign n1153 = n1216 ? n1071 : n1963;
  /*# sim_rtl/controller.vhd:304:1 */
  assign n1154 = n1217 ? n1072 : n1964;
  /*# sim_rtl/controller.vhd:304:1 */
  assign n1155 = n1218 ? n1073 : n1965;
  /*# sim_rtl/controller.vhd:304:1 */
  assign n1156 = n1219 ? n1074 : n1966;
  /*# sim_rtl/controller.vhd:304:1 */
  assign n1157 = n1220 ? n1075 : n1967;
  /*# sim_rtl/controller.vhd:304:1 */
  assign n1158 = n1221 ? n1076 : n1968;
  /*# sim_rtl/controller.vhd:304:1 */
  assign n1159 = n1222 ? n1077 : n1969;
  /*# sim_rtl/controller.vhd:304:1 */
  assign n1160 = n1223 ? n1078 : n1970;
  /*# sim_rtl/controller.vhd:304:1 */
  assign n1161 = n1224 ? n1079 : n1971;
  /*# sim_rtl/controller.vhd:304:1 */
  assign n1162 = n1225 ? n1080 : n1972;
  /*# sim_rtl/controller.vhd:378:1 */
  assign n1163 = {n1098, n1096, n1094, n1092, n1090, n1088, n1086, n1084, n1082};
  /*# sim_rtl/controller.vhd:304:1 */
  assign n1164 = n1226 ? n1163 : inst_cache;
  /*# sim_rtl/controller.vhd:304:1 */
  assign n1165 = n1227 ? n1099 : slot_voice_addr;
  /*# sim_rtl/controller.vhd:304:1 */
  assign n1166 = n1228 ? n1100 : user_voice_wr;
  /*# sim_rtl/controller.vhd:304:1 */
  assign n1167 = n1229 ? n1101 : user_voice_addr;
  /*# sim_rtl/controller.vhd:304:1 */
  assign n1168 = n1230 ? n1102 : user_voice_wdata;
  /*# sim_rtl/controller.vhd:304:1 */
  assign n1169 = n1231 ? n1103 : regs_wr;
  /*# sim_rtl/controller.vhd:304:1 */
  assign n1170 = n1232 ? n1104 : regs_addr;
  /*# sim_rtl/controller.vhd:304:1 */
  assign n1171 = n1233 ? n1105 : regs_wdata;
  /*# sim_rtl/controller.vhd:304:1 */
  assign n1172 = n1234 ? n1106 : rflag;
  /*# sim_rtl/controller.vhd:304:1 */
  assign n1173 = n1235 ? n1107 : n618_extra_mode;
  /*# sim_rtl/controller.vhd:304:1 */
  assign n1174 = n1236 ? n1108 : n618_vindex;
  /*# sim_rtl/controller.vhd:304:1 */
  assign n1211 = ss_write & n658;
  /*# sim_rtl/controller.vhd:304:1 */
  assign n1212 = ss_write & n658;
  /*# sim_rtl/controller.vhd:304:1 */
  assign n1213 = ss_write & n658;
  /*# sim_rtl/controller.vhd:304:1 */
  assign n1214 = ss_write & n658;
  /*# sim_rtl/controller.vhd:304:1 */
  assign n1215 = ss_write & n658;
  /*# sim_rtl/controller.vhd:304:1 */
  assign n1216 = ss_write & n658;
  /*# sim_rtl/controller.vhd:304:1 */
  assign n1217 = ss_write & n658;
  /*# sim_rtl/controller.vhd:304:1 */
  assign n1218 = ss_write & n658;
  /*# sim_rtl/controller.vhd:304:1 */
  assign n1219 = ss_write & n658;
  /*# sim_rtl/controller.vhd:304:1 */
  assign n1220 = ss_write & n658;
  /*# sim_rtl/controller.vhd:304:1 */
  assign n1221 = ss_write & n658;
  /*# sim_rtl/controller.vhd:304:1 */
  assign n1222 = ss_write & n658;
  /*# sim_rtl/controller.vhd:304:1 */
  assign n1223 = ss_write & n658;
  /*# sim_rtl/controller.vhd:304:1 */
  assign n1224 = ss_write & n658;
  /*# sim_rtl/controller.vhd:304:1 */
  assign n1225 = ss_write & n658;
  /*# sim_rtl/controller.vhd:304:1 */
  assign n1226 = ss_write & n658;
  /*# sim_rtl/controller.vhd:304:1 */
  assign n1227 = ss_write & n658;
  /*# sim_rtl/controller.vhd:304:1 */
  assign n1228 = ss_write & n658;
  /*# sim_rtl/controller.vhd:304:1 */
  assign n1229 = ss_write & n658;
  /*# sim_rtl/controller.vhd:304:1 */
  assign n1230 = ss_write & n658;
  /*# sim_rtl/controller.vhd:304:1 */
  assign n1231 = ss_write & n658;
  /*# sim_rtl/controller.vhd:304:1 */
  assign n1232 = ss_write & n658;
  /*# sim_rtl/controller.vhd:304:1 */
  assign n1233 = ss_write & n658;
  /*# sim_rtl/controller.vhd:304:1 */
  assign n1234 = ss_write & n658;
  /*# sim_rtl/controller.vhd:304:1 */
  assign n1235 = ss_write & n658;
  /*# sim_rtl/controller.vhd:304:1 */
  assign n1236 = ss_write & n658;
  /*# sim_rtl/controller.vhd:304:1 */
  assign n1267 = n658 ? n869 : 32'b00000000000000000000000000000000;
  /*# sim_rtl/controller.vhd:463:11 */
  assign n1269 = ~ss_hold;
  /*# sim_rtl/controller.vhd:466:27 */
  assign n1271 = stage == 2'b00;
  /*# sim_rtl/controller.vhd:467:38 */
  assign n1272 = slot[4:1]; // extract
  /*# sim_rtl/controller.vhd:463:1 */
  assign n1273 = n1788 ? n1272 : n1170;
  /*# sim_rtl/controller.vhd:465:13 */
  assign n1274 = n1271 & clkena;
  /*# sim_rtl/controller.vhd:475:27 */
  assign n1276 = stage == 2'b00;
  /*# sim_rtl/controller.vhd:476:30 */
  assign n1277 = rflag[5]; // extract
  /*# sim_rtl/controller.vhd:476:54 */
  assign n1279 = $unsigned(w_channel) >= $unsigned(4'b0110);
  /*# sim_rtl/controller.vhd:476:40 */
  assign n1280 = n1279 & n1277;
  /*# sim_rtl/controller.vhd:478:44 */
  assign n1281 = {27'b0, slot};  // uext
  /*# sim_rtl/controller.vhd:478:63 */
  assign n1283 = n1281 - 32'b00000000000000000000000000001100;
  /*# sim_rtl/controller.vhd:478:68 */
  assign n1285 = n1283 + 32'b00000000000000000000000000100000;
  /*# sim_rtl/controller.vhd:478:44 */
  assign n1286 = n1285[5:0];  // trunc
  /*# sim_rtl/controller.vhd:480:55 */
  assign n1287 = {27'b0, slot};  // uext
  /*# sim_rtl/controller.vhd:480:73 */
  assign n1289 = $signed(n1287) / $signed(32'b00000000000000000000000000000010); // sdiv
  /*# sim_rtl/controller.vhd:480:73 */
  assign n1290 = n1289[3:0];  // trunc
  /*# sim_rtl/controller.vhd:480:73 */
  assign n1292 = 4'b1000 - n1290;
  /*# sim_rtl/controller.vhd:480:77 */
  assign n1295 = {28'b0, n1998};  // uext
  /*# sim_rtl/controller.vhd:480:77 */
  assign n1297 = $signed(n1295) * $signed(32'b00000000000000000000000000000010); // smul
  /*# sim_rtl/controller.vhd:480:83 */
  assign n1298 = {27'b0, slot};  // uext
  /*# sim_rtl/controller.vhd:480:102 */
  assign n1299 = n1298[0]; // extract
  /*# sim_rtl/controller.vhd:480:102 */
  assign n1300 = {31'b0, n1299};  // uext
  /*# sim_rtl/controller.vhd:480:81 */
  assign n1301 = n1297 + n1300;
  /*# sim_rtl/controller.vhd:480:44 */
  assign n1302 = n1301[5:0];  // trunc
  /*# sim_rtl/controller.vhd:476:21 */
  assign n1303 = n1280 ? n1286 : n1302;
  /*# sim_rtl/controller.vhd:463:1 */
  assign n1304 = n1783 ? n1303 : n1165;
  /*# sim_rtl/controller.vhd:474:13 */
  assign n1305 = n1276 & clkena;
  /*# sim_rtl/controller.vhd:497:32 */
  assign n1306 = {27'b0, slot};  // uext
  /*# sim_rtl/controller.vhd:497:51 */
  assign n1307 = n1306[0]; // extract
  /*# sim_rtl/controller.vhd:497:22 */
  assign n1309 = {5'b0, n1307};  // uext
  /*# sim_rtl/controller.vhd:493:13 */
  assign n1311 = stage == 2'b00;
  /*# sim_rtl/controller.vhd:513:13 */
  assign n1313 = stage == 2'b01;
  /*# sim_rtl/controller.vhd:525:36 */
  assign n1314 = ~n1173;
  /*# sim_rtl/controller.vhd:525:46 */
  assign n1315 = {24'b0, addr};  // uext
  /*# sim_rtl/controller.vhd:525:65 */
  assign n1317 = $signed(n1315) < $signed(32'b00000000000000000000000000001000);
  /*# sim_rtl/controller.vhd:525:42 */
  assign n1318 = n1317 & n1314;
  /*# sim_rtl/controller.vhd:530:34 */
  assign n1319 = addr[2:1]; // extract
  /*# sim_rtl/controller.vhd:532:53 */
  assign n1320 = addr[0]; // extract
  /*# sim_rtl/controller.vhd:532:36 */
  assign n1321 = {31'b0, n1320};  // uext
  /*# sim_rtl/controller.vhd:532:77 */
  assign n1322 = {26'b0, n1174};  // uext
  /*# sim_rtl/controller.vhd:532:77 */
  assign n1323 = n1322[0]; // extract
  /*# sim_rtl/controller.vhd:532:77 */
  assign n1324 = {31'b0, n1323};  // uext
  /*# sim_rtl/controller.vhd:532:67 */
  assign n1325 = n1321 == n1324;
  /*# sim_rtl/controller.vhd:533:62 */
  assign n1326 = data[7]; // extract
  /*# sim_rtl/controller.vhd:534:62 */
  assign n1327 = data[6]; // extract
  /*# sim_rtl/controller.vhd:535:62 */
  assign n1328 = data[5]; // extract
  /*# sim_rtl/controller.vhd:536:62 */
  assign n1329 = data[4]; // extract
  /*# sim_rtl/controller.vhd:537:62 */
  assign n1330 = data[3:0]; // extract
  /*# sim_rtl/controller.vhd:532:33 */
  assign n1332 = n1325 ? 1'b1 : n1166;
  /*# sim_rtl/controller.vhd:532:33 */
  assign n1333 = {n1330, n1329, n1328, n1327, n1326};
  /*# sim_rtl/controller.vhd:228:18 */
  assign n1334 = user_voice_rdata[7:0]; // extract
  /*# sim_rtl/controller.vhd:532:33 */
  assign n1335 = n1325 ? n1333 : n1334;
  /*# sim_rtl/controller.vhd:531:29 */
  assign n1337 = n1319 == 2'b00;
  /*# sim_rtl/controller.vhd:542:40 */
  assign n1338 = addr[0]; // extract
  /*# sim_rtl/controller.vhd:542:43 */
  assign n1339 = ~n1338;
  /*# sim_rtl/controller.vhd:542:60 */
  assign n1340 = {26'b0, n1174};  // uext
  /*# sim_rtl/controller.vhd:542:60 */
  assign n1341 = n1340[0]; // extract
  /*# sim_rtl/controller.vhd:542:60 */
  assign n1342 = {31'b0, n1341};  // uext
  /*# sim_rtl/controller.vhd:542:66 */
  assign n1344 = n1342 == 32'b00000000000000000000000000000000;
  /*# sim_rtl/controller.vhd:542:48 */
  assign n1345 = n1344 & n1339;
  /*# sim_rtl/controller.vhd:543:62 */
  assign n1346 = data[7:6]; // extract
  /*# sim_rtl/controller.vhd:544:62 */
  assign n1347 = data[5:0]; // extract
  /*# sim_rtl/controller.vhd:546:43 */
  assign n1348 = addr[0]; // extract
  /*# sim_rtl/controller.vhd:546:63 */
  assign n1349 = {26'b0, n1174};  // uext
  /*# sim_rtl/controller.vhd:546:63 */
  assign n1350 = n1349[0]; // extract
  /*# sim_rtl/controller.vhd:546:63 */
  assign n1351 = {31'b0, n1350};  // uext
  /*# sim_rtl/controller.vhd:546:69 */
  assign n1353 = n1351 == 32'b00000000000000000000000000000000;
  /*# sim_rtl/controller.vhd:546:51 */
  assign n1354 = n1353 & n1348;
  /*# sim_rtl/controller.vhd:547:62 */
  assign n1355 = data[3]; // extract
  /*# sim_rtl/controller.vhd:548:62 */
  assign n1356 = data[2:0]; // extract
  /*# sim_rtl/controller.vhd:550:43 */
  assign n1357 = addr[0]; // extract
  /*# sim_rtl/controller.vhd:550:63 */
  assign n1358 = {26'b0, n1174};  // uext
  /*# sim_rtl/controller.vhd:550:63 */
  assign n1359 = n1358[0]; // extract
  /*# sim_rtl/controller.vhd:550:63 */
  assign n1360 = {31'b0, n1359};  // uext
  /*# sim_rtl/controller.vhd:550:69 */
  assign n1362 = n1360 == 32'b00000000000000000000000000000001;
  /*# sim_rtl/controller.vhd:550:51 */
  assign n1363 = n1362 & n1357;
  /*# sim_rtl/controller.vhd:551:62 */
  assign n1364 = data[7:6]; // extract
  /*# sim_rtl/controller.vhd:552:62 */
  assign n1365 = data[4]; // extract
  /*# sim_rtl/controller.vhd:550:33 */
  assign n1367 = n1363 ? 1'b1 : n1166;
  /*# sim_rtl/controller.vhd:228:18 */
  assign n1368 = user_voice_rdata[9:8]; // extract
  /*# sim_rtl/controller.vhd:550:33 */
  assign n1369 = n1363 ? n1364 : n1368;
  /*# sim_rtl/controller.vhd:228:18 */
  assign n1370 = user_voice_rdata[16]; // extract
  /*# sim_rtl/controller.vhd:550:33 */
  assign n1371 = n1363 ? n1365 : n1370;
  /*# sim_rtl/controller.vhd:546:33 */
  assign n1373 = n1354 ? 1'b1 : n1367;
  /*# sim_rtl/controller.vhd:546:33 */
  assign n1374 = {n1356, n1355};
  /*# sim_rtl/controller.vhd:228:18 */
  assign n1375 = user_voice_rdata[9:8]; // extract
  /*# sim_rtl/controller.vhd:546:33 */
  assign n1376 = n1354 ? n1375 : n1369;
  /*# sim_rtl/controller.vhd:546:33 */
  assign n1377 = n1374[0]; // extract
  /*# sim_rtl/controller.vhd:546:33 */
  assign n1378 = n1354 ? n1377 : n1371;
  /*# sim_rtl/controller.vhd:546:33 */
  assign n1379 = n1374[3:1]; // extract
  /*# sim_rtl/controller.vhd:228:18 */
  assign n1380 = user_voice_rdata[19:17]; // extract
  /*# sim_rtl/controller.vhd:546:33 */
  assign n1381 = n1354 ? n1379 : n1380;
  /*# sim_rtl/controller.vhd:542:33 */
  assign n1383 = n1345 ? 1'b1 : n1373;
  /*# sim_rtl/controller.vhd:542:33 */
  assign n1384 = {n1381, n1378};
  /*# sim_rtl/controller.vhd:542:33 */
  assign n1385 = {n1347, n1346};
  /*# sim_rtl/controller.vhd:542:33 */
  assign n1386 = n1385[1:0]; // extract
  /*# sim_rtl/controller.vhd:542:33 */
  assign n1387 = n1345 ? n1386 : n1376;
  /*# sim_rtl/controller.vhd:542:33 */
  assign n1388 = n1385[7:2]; // extract
  /*# sim_rtl/controller.vhd:228:18 */
  assign n1389 = user_voice_rdata[15:10]; // extract
  /*# sim_rtl/controller.vhd:542:33 */
  assign n1390 = n1345 ? n1388 : n1389;
  /*# sim_rtl/controller.vhd:228:18 */
  assign n1391 = user_voice_rdata[19:16]; // extract
  /*# sim_rtl/controller.vhd:542:33 */
  assign n1392 = n1345 ? n1391 : n1384;
  /*# sim_rtl/controller.vhd:541:29 */
  assign n1394 = n1319 == 2'b01;
  /*# sim_rtl/controller.vhd:557:53 */
  assign n1395 = addr[0]; // extract
  /*# sim_rtl/controller.vhd:557:36 */
  assign n1396 = {31'b0, n1395};  // uext
  /*# sim_rtl/controller.vhd:557:77 */
  assign n1397 = {26'b0, n1174};  // uext
  /*# sim_rtl/controller.vhd:557:77 */
  assign n1398 = n1397[0]; // extract
  /*# sim_rtl/controller.vhd:557:77 */
  assign n1399 = {31'b0, n1398};  // uext
  /*# sim_rtl/controller.vhd:557:67 */
  assign n1400 = n1396 == n1399;
  /*# sim_rtl/controller.vhd:558:62 */
  assign n1401 = data[7:4]; // extract
  /*# sim_rtl/controller.vhd:559:62 */
  assign n1402 = data[3:0]; // extract
  /*# sim_rtl/controller.vhd:557:33 */
  assign n1404 = n1400 ? 1'b1 : n1166;
  /*# sim_rtl/controller.vhd:557:33 */
  assign n1405 = {n1402, n1401};
  /*# sim_rtl/controller.vhd:228:18 */
  assign n1406 = user_voice_rdata[27:20]; // extract
  /*# sim_rtl/controller.vhd:557:33 */
  assign n1407 = n1400 ? n1405 : n1406;
  /*# sim_rtl/controller.vhd:556:29 */
  assign n1409 = n1319 == 2'b10;
  /*# sim_rtl/controller.vhd:564:53 */
  assign n1410 = addr[0]; // extract
  /*# sim_rtl/controller.vhd:564:36 */
  assign n1411 = {31'b0, n1410};  // uext
  /*# sim_rtl/controller.vhd:564:77 */
  assign n1412 = {26'b0, n1174};  // uext
  /*# sim_rtl/controller.vhd:564:77 */
  assign n1413 = n1412[0]; // extract
  /*# sim_rtl/controller.vhd:564:77 */
  assign n1414 = {31'b0, n1413};  // uext
  /*# sim_rtl/controller.vhd:564:67 */
  assign n1415 = n1411 == n1414;
  /*# sim_rtl/controller.vhd:565:62 */
  assign n1416 = data[7:4]; // extract
  /*# sim_rtl/controller.vhd:566:62 */
  assign n1417 = data[3:0]; // extract
  /*# sim_rtl/controller.vhd:564:33 */
  assign n1419 = n1415 ? 1'b1 : n1166;
  /*# sim_rtl/controller.vhd:564:33 */
  assign n1420 = {n1417, n1416};
  /*# sim_rtl/controller.vhd:228:18 */
  assign n1421 = user_voice_rdata[35:28]; // extract
  /*# sim_rtl/controller.vhd:564:33 */
  assign n1422 = n1415 ? n1420 : n1421;
  /*# sim_rtl/controller.vhd:563:29 */
  assign n1424 = n1319 == 2'b11;
  /*# sim_rtl/controller.vhd:530:25 */
  assign n1425 = {n1424, n1409, n1394, n1337};
  /*# sim_rtl/controller.vhd:530:25 */
  always @*
    case (n1425)
      4'b1000: n1426 = n1419;
      4'b0100: n1426 = n1404;
      4'b0010: n1426 = n1383;
      4'b0001: n1426 = n1332;
      default: n1426 = n1166;
    endcase
  /*# sim_rtl/controller.vhd:228:18 */
  assign n1427 = user_voice_rdata[7:0]; // extract
  /*# sim_rtl/controller.vhd:530:25 */
  always @*
    case (n1425)
      4'b1000: n1428 = n1427;
      4'b0100: n1428 = n1427;
      4'b0010: n1428 = n1427;
      4'b0001: n1428 = n1335;
      default: n1428 = n1427;
    endcase
  /*# sim_rtl/controller.vhd:228:18 */
  assign n1429 = user_voice_rdata[9:8]; // extract
  /*# sim_rtl/controller.vhd:530:25 */
  always @*
    case (n1425)
      4'b1000: n1430 = n1429;
      4'b0100: n1430 = n1429;
      4'b0010: n1430 = n1387;
      4'b0001: n1430 = n1429;
      default: n1430 = n1429;
    endcase
  /*# sim_rtl/controller.vhd:228:18 */
  assign n1431 = user_voice_rdata[15:10]; // extract
  /*# sim_rtl/controller.vhd:530:25 */
  always @*
    case (n1425)
      4'b1000: n1432 = n1431;
      4'b0100: n1432 = n1431;
      4'b0010: n1432 = n1390;
      4'b0001: n1432 = n1431;
      default: n1432 = n1431;
    endcase
  /*# sim_rtl/controller.vhd:228:18 */
  assign n1433 = user_voice_rdata[19:16]; // extract
  /*# sim_rtl/controller.vhd:530:25 */
  always @*
    case (n1425)
      4'b1000: n1434 = n1433;
      4'b0100: n1434 = n1433;
      4'b0010: n1434 = n1392;
      4'b0001: n1434 = n1433;
      default: n1434 = n1433;
    endcase
  /*# sim_rtl/controller.vhd:228:18 */
  assign n1435 = user_voice_rdata[27:20]; // extract
  /*# sim_rtl/controller.vhd:530:25 */
  always @*
    case (n1425)
      4'b1000: n1436 = n1435;
      4'b0100: n1436 = n1407;
      4'b0010: n1436 = n1435;
      4'b0001: n1436 = n1435;
      default: n1436 = n1435;
    endcase
  /*# sim_rtl/controller.vhd:228:18 */
  assign n1437 = user_voice_rdata[35:28]; // extract
  /*# sim_rtl/controller.vhd:530:25 */
  always @*
    case (n1425)
      4'b1000: n1438 = n1422;
      4'b0100: n1438 = n1437;
      4'b0010: n1438 = n1437;
      4'b0001: n1438 = n1437;
      default: n1438 = n1437;
    endcase
  /*# sim_rtl/controller.vhd:228:18 */
  assign n1444 = {n1438, n1436, n1434, n1432, n1430, n1428};
  /*# sim_rtl/controller.vhd:573:27 */
  assign n1445 = {24'b0, addr};  // uext
  /*# sim_rtl/controller.vhd:573:46 */
  assign n1447 = n1445 == 32'b00000000000000000000000000001110;
  /*# sim_rtl/controller.vhd:577:27 */
  assign n1448 = {24'b0, addr};  // uext
  /*# sim_rtl/controller.vhd:577:46 */
  assign n1450 = $signed(n1448) < $signed(32'b00000000000000000000000000010000);
  /*# sim_rtl/controller.vhd:581:27 */
  assign n1451 = {24'b0, addr};  // uext
  /*# sim_rtl/controller.vhd:581:46 */
  assign n1453 = $signed(n1451) <= $signed(32'b00000000000000000000000000111111);
  /*# sim_rtl/controller.vhd:583:46 */
  assign n1454 = addr[3:0]; // extract
  /*# sim_rtl/controller.vhd:583:29 */
  assign n1455 = {28'b0, n1454};  // uext
  /*# sim_rtl/controller.vhd:583:63 */
  assign n1456 = {27'b0, slot};  // uext
  /*# sim_rtl/controller.vhd:583:82 */
  assign n1458 = $signed(n1456) / $signed(32'b00000000000000000000000000000010); // sdiv
  /*# sim_rtl/controller.vhd:583:61 */
  assign n1459 = n1455 == n1458;
  /*# sim_rtl/controller.vhd:585:38 */
  assign n1460 = addr[5:4]; // extract
  /*# sim_rtl/controller.vhd:586:33 */
  assign n1462 = n1460 == 2'b01;
  /*# sim_rtl/controller.vhd:590:57 */
  assign n1463 = data[5]; // extract
  /*# sim_rtl/controller.vhd:591:57 */
  assign n1464 = data[4]; // extract
  /*# sim_rtl/controller.vhd:592:66 */
  assign n1465 = data[3:1]; // extract
  /*# sim_rtl/controller.vhd:593:56 */
  assign n1466 = data[0]; // extract
  /*# sim_rtl/controller.vhd:589:33 */
  assign n1468 = n1460 == 2'b10;
  /*# sim_rtl/controller.vhd:596:67 */
  assign n1469 = data[7:4]; // extract
  /*# sim_rtl/controller.vhd:597:67 */
  assign n1470 = data[3:0]; // extract
  /*# sim_rtl/controller.vhd:595:33 */
  assign n1472 = n1460 == 2'b11;
  /*# sim_rtl/controller.vhd:585:29 */
  assign n1473 = {n1472, n1468, n1462};
  /*# sim_rtl/controller.vhd:585:29 */
  always @*
    case (n1473)
      3'b100: n1477 = 1'b1;
      3'b010: n1477 = 1'b1;
      3'b001: n1477 = 1'b1;
      default: n1477 = n1169;
    endcase
  /*# sim_rtl/controller.vhd:227:18 */
  assign n1478 = regs_rdata[7:0]; // extract
  /*# sim_rtl/controller.vhd:585:29 */
  always @*
    case (n1473)
      3'b100: n1479 = n1478;
      3'b010: n1479 = n1478;
      3'b001: n1479 = data;
      default: n1479 = n1478;
    endcase
  /*# sim_rtl/controller.vhd:227:18 */
  assign n1480 = regs_rdata[8]; // extract
  /*# sim_rtl/controller.vhd:585:29 */
  always @*
    case (n1473)
      3'b100: n1481 = n1480;
      3'b010: n1481 = n1466;
      3'b001: n1481 = n1480;
      default: n1481 = n1480;
    endcase
  /*# sim_rtl/controller.vhd:227:18 */
  assign n1482 = regs_rdata[11:9]; // extract
  /*# sim_rtl/controller.vhd:585:29 */
  always @*
    case (n1473)
      3'b100: n1483 = n1482;
      3'b010: n1483 = n1465;
      3'b001: n1483 = n1482;
      default: n1483 = n1482;
    endcase
  /*# sim_rtl/controller.vhd:227:18 */
  assign n1484 = regs_rdata[12]; // extract
  /*# sim_rtl/controller.vhd:585:29 */
  always @*
    case (n1473)
      3'b100: n1485 = n1484;
      3'b010: n1485 = n1464;
      3'b001: n1485 = n1484;
      default: n1485 = n1484;
    endcase
  /*# sim_rtl/controller.vhd:227:18 */
  assign n1486 = regs_rdata[13]; // extract
  /*# sim_rtl/controller.vhd:585:29 */
  always @*
    case (n1473)
      3'b100: n1487 = n1486;
      3'b010: n1487 = n1463;
      3'b001: n1487 = n1486;
      default: n1487 = n1486;
    endcase
  /*# sim_rtl/controller.vhd:227:18 */
  assign n1488 = regs_rdata[19:16]; // extract
  /*# sim_rtl/controller.vhd:585:29 */
  always @*
    case (n1473)
      3'b100: n1489 = n1470;
      3'b010: n1489 = n1488;
      3'b001: n1489 = n1488;
      default: n1489 = n1488;
    endcase
  /*# sim_rtl/controller.vhd:227:18 */
  assign n1490 = regs_rdata[23:20]; // extract
  /*# sim_rtl/controller.vhd:585:29 */
  always @*
    case (n1473)
      3'b100: n1491 = n1469;
      3'b010: n1491 = n1490;
      3'b001: n1491 = n1490;
      default: n1491 = n1490;
    endcase
  /*# sim_rtl/controller.vhd:227:18 */
  assign n1498 = regs_rdata[15:14]; // extract
  /*# sim_rtl/controller.vhd:227:18 */
  assign n1499 = {n1491, n1489, n1498, n1487, n1485, n1483, n1481, n1479};
  /*# sim_rtl/controller.vhd:581:21 */
  assign n1500 = n1513 ? n1477 : n1169;
  /*# sim_rtl/controller.vhd:581:21 */
  assign n1501 = n1514 ? n1499 : n1171;
  /*# sim_rtl/controller.vhd:605:27 */
  assign n1504 = {24'b0, addr};  // uext
  /*# sim_rtl/controller.vhd:605:46 */
  assign n1506 = n1504 == 32'b00000000000000000000000011110000;
  /*# sim_rtl/controller.vhd:607:45 */
  assign n1508 = data == 8'b10000000;
  /*# sim_rtl/controller.vhd:607:25 */
  assign n1511 = n1508 ? 1'b1 : 1'b0;
  /*# sim_rtl/controller.vhd:605:21 */
  assign n1512 = n1506 ? n1511 : n1173;
  /*# sim_rtl/controller.vhd:581:21 */
  assign n1513 = n1459 & n1453;
  /*# sim_rtl/controller.vhd:581:21 */
  assign n1514 = n1459 & n1453;
  /*# sim_rtl/controller.vhd:581:21 */
  assign n1516 = n1453 ? n1173 : n1512;
  /*# sim_rtl/controller.vhd:577:21 */
  assign n1517 = n1450 ? n1169 : n1500;
  /*# sim_rtl/controller.vhd:577:21 */
  assign n1518 = n1450 ? n1171 : n1501;
  /*# sim_rtl/controller.vhd:577:21 */
  assign n1520 = n1450 ? n1173 : n1516;
  /*# sim_rtl/controller.vhd:573:21 */
  assign n1521 = n1447 ? n1169 : n1517;
  /*# sim_rtl/controller.vhd:573:21 */
  assign n1522 = n1447 ? n1171 : n1518;
  /*# sim_rtl/controller.vhd:573:21 */
  assign n1523 = n1447 ? data : n1172;
  /*# sim_rtl/controller.vhd:573:21 */
  assign n1525 = n1447 ? n1173 : n1520;
  /*# sim_rtl/controller.vhd:521:17 */
  assign n1526 = n1535 ? n1426 : n1166;
  /*# sim_rtl/controller.vhd:521:17 */
  assign n1527 = n1536 ? n1444 : n1168;
  /*# sim_rtl/controller.vhd:525:21 */
  assign n1528 = n1318 ? n1169 : n1521;
  /*# sim_rtl/controller.vhd:525:21 */
  assign n1529 = n1318 ? n1171 : n1522;
  /*# sim_rtl/controller.vhd:525:21 */
  assign n1530 = n1318 ? n1172 : n1523;
  /*# sim_rtl/controller.vhd:525:21 */
  assign n1534 = n1318 ? n1173 : n1525;
  /*# sim_rtl/controller.vhd:521:17 */
  assign n1535 = n1318 & wr;
  /*# sim_rtl/controller.vhd:521:17 */
  assign n1536 = n1318 & wr;
  /*# sim_rtl/controller.vhd:521:17 */
  assign n1537 = wr ? n1528 : n1169;
  /*# sim_rtl/controller.vhd:521:17 */
  assign n1538 = wr ? n1529 : n1171;
  /*# sim_rtl/controller.vhd:521:17 */
  assign n1539 = wr ? n1530 : n1172;
  /*# sim_rtl/controller.vhd:521:17 */
  assign n1542 = wr ? n1534 : n1173;
  /*# sim_rtl/controller.vhd:519:13 */
  assign n1544 = stage == 2'b10;
  /*# sim_rtl/controller.vhd:626:28 */
  assign n1545 = {27'b0, slot};  // uext
  /*# sim_rtl/controller.vhd:626:46 */
  assign n1547 = $signed(n1545) / $signed(32'b00000000000000000000000000000010); // sdiv
  /*# sim_rtl/controller.vhd:626:46 */
  assign n1548 = n1547[3:0];  // trunc
  /*# sim_rtl/controller.vhd:626:46 */
  assign n1550 = 4'b1000 - n1548;
  /*# sim_rtl/controller.vhd:626:76 */
  assign n1552 = regs_rdata[23:20]; // extract
  /*# sim_rtl/controller.vhd:628:32 */
  assign n1555 = rflag[5]; // extract
  /*# sim_rtl/controller.vhd:631:25 */
  assign n1556 = rflag[5]; // extract
  /*# sim_rtl/controller.vhd:631:42 */
  assign n1558 = $unsigned(5'b01100) <= $unsigned(slot);
  /*# sim_rtl/controller.vhd:631:35 */
  assign n1559 = n1558 & n1556;
  /*# sim_rtl/controller.vhd:634:43 */
  assign n1560 = rflag[4]; // extract
  /*# sim_rtl/controller.vhd:633:25 */
  assign n1562 = slot == 5'b01100;
  /*# sim_rtl/controller.vhd:633:38 */
  assign n1564 = slot == 5'b01101;
  /*# sim_rtl/controller.vhd:633:38 */
  assign n1565 = n1562 | n1564;
  /*# sim_rtl/controller.vhd:636:43 */
  assign n1566 = rflag[0]; // extract
  /*# sim_rtl/controller.vhd:635:25 */
  assign n1568 = slot == 5'b01110;
  /*# sim_rtl/controller.vhd:638:43 */
  assign n1569 = rflag[3]; // extract
  /*# sim_rtl/controller.vhd:637:25 */
  assign n1571 = slot == 5'b01111;
  /*# sim_rtl/controller.vhd:640:43 */
  assign n1572 = rflag[2]; // extract
  /*# sim_rtl/controller.vhd:639:25 */
  assign n1574 = slot == 5'b10000;
  /*# sim_rtl/controller.vhd:642:43 */
  assign n1575 = rflag[1]; // extract
  /*# sim_rtl/controller.vhd:641:25 */
  assign n1577 = slot == 5'b10001;
  /*# sim_rtl/controller.vhd:632:21 */
  assign n1578 = {n1577, n1574, n1571, n1568, n1565};
  /*# sim_rtl/controller.vhd:632:21 */
  always @*
    case (n1578)
      5'b10000: n1579 = n1575;
      5'b01000: n1579 = n1572;
      5'b00100: n1579 = n1569;
      5'b00010: n1579 = n1566;
      5'b00001: n1579 = n1560;
      default: n1579 = n618_kflag;
    endcase
  /*# sim_rtl/controller.vhd:631:17 */
  assign n1581 = n1559 ? n1579 : 1'b0;
  /*# sim_rtl/controller.vhd:649:45 */
  assign n1582 = regs_rdata[12]; // extract
  /*# sim_rtl/controller.vhd:649:32 */
  assign n1583 = n1581 | n1582;
  /*# sim_rtl/controller.vhd:652:62 */
  assign n1584 = regs_rdata[8:5]; // extract
  /*# sim_rtl/controller.vhd:652:29 */
  assign n1592 = {1'b0, n1995};
  /*# sim_rtl/controller.vhd:653:50 */
  assign n1593 = regs_rdata[11:9]; // extract
  /*# sim_rtl/controller.vhd:653:39 */
  assign n1595 = 3'b111 - n1593;
  /*# sim_rtl/controller.vhd:653:32 */
  assign n1597 = {1'b0, n1595};
  /*# sim_rtl/controller.vhd:653:64 */
  assign n1599 = {n1597, 3'b000};
  /*# sim_rtl/controller.vhd:653:26 */
  assign n1600 = n1592 - n1599;
  /*# sim_rtl/controller.vhd:653:73 */
  assign n1602 = {n1600, 1'b0};
  /*# sim_rtl/controller.vhd:655:23 */
  assign n1603 = n1602[7]; // extract
  /*# sim_rtl/controller.vhd:655:58 */
  assign n1604 = slot_voice_data[9:8]; // extract
  /*# sim_rtl/controller.vhd:655:61 */
  assign n1606 = n1604 == 2'b00;
  /*# sim_rtl/controller.vhd:655:39 */
  assign n1607 = n1603 | n1606;
  /*# sim_rtl/controller.vhd:658:60 */
  assign n1608 = slot_voice_data[9:8]; // extract
  /*# sim_rtl/controller.vhd:658:42 */
  assign n1610 = 2'b11 - n1608;
  /*# sim_rtl/controller.vhd:658:28 */
  assign n1611 = n1602 >> n1610;
  /*# sim_rtl/controller.vhd:655:17 */
  assign n1613 = n1607 ? 8'b00000000 : n1611;
  /*# sim_rtl/controller.vhd:662:25 */
  assign n1614 = rflag[5]; // extract
  /*# sim_rtl/controller.vhd:662:45 */
  assign n1616 = slot == 5'b01110;
  /*# sim_rtl/controller.vhd:662:63 */
  assign n1618 = slot == 5'b10000;
  /*# sim_rtl/controller.vhd:662:55 */
  assign n1619 = n1616 | n1618;
  /*# sim_rtl/controller.vhd:662:35 */
  assign n1620 = n1619 & n1614;
  /*# sim_rtl/controller.vhd:663:45 */
  assign n1621 = regs_rdata[23:20]; // extract
  /*# sim_rtl/controller.vhd:663:33 */
  assign n1623 = {1'b0, n1621};
  /*# sim_rtl/controller.vhd:663:60 */
  assign n1625 = {n1623, 3'b000};
  /*# sim_rtl/controller.vhd:664:28 */
  assign n1626 = slot[0]; // extract
  /*# sim_rtl/controller.vhd:664:32 */
  assign n1627 = ~n1626;
  /*# sim_rtl/controller.vhd:665:51 */
  assign n1628 = slot_voice_data[15:10]; // extract
  /*# sim_rtl/controller.vhd:665:33 */
  assign n1630 = {1'b0, n1628};
  /*# sim_rtl/controller.vhd:665:54 */
  assign n1632 = {n1630, 1'b0};
  /*# sim_rtl/controller.vhd:667:45 */
  assign n1633 = regs_rdata[19:16]; // extract
  /*# sim_rtl/controller.vhd:667:33 */
  assign n1635 = {1'b0, n1633};
  /*# sim_rtl/controller.vhd:667:60 */
  assign n1637 = {n1635, 3'b000};
  /*# sim_rtl/controller.vhd:664:17 */
  assign n1638 = n1627 ? n1632 : n1637;
  /*# sim_rtl/controller.vhd:662:17 */
  assign n1639 = n1620 ? n1625 : n1638;
  /*# sim_rtl/controller.vhd:670:28 */
  assign n1640 = n1639 + n1613;
  /*# sim_rtl/controller.vhd:672:23 */
  assign n1641 = n1640[7]; // extract
  /*# sim_rtl/controller.vhd:675:30 */
  assign n1642 = n1640[6:0]; // extract
  /*# sim_rtl/controller.vhd:672:17 */
  assign n1644 = n1641 ? 7'b1111111 : n1642;
  /*# sim_rtl/controller.vhd:679:35 */
  assign n1645 = regs_rdata[8:0]; // extract
  /*# sim_rtl/controller.vhd:680:34 */
  assign n1646 = regs_rdata[11:9]; // extract
  /*# sim_rtl/controller.vhd:683:25 */
  assign n1647 = rflag[5]; // extract
  /*# sim_rtl/controller.vhd:683:42 */
  assign n1649 = $unsigned(5'b01110) <= $unsigned(slot);
  /*# sim_rtl/controller.vhd:683:35 */
  assign n1650 = n1649 & n1647;
  /*# sim_rtl/controller.vhd:684:40 */
  assign n1651 = slot_voice_data[3]; // extract
  /*# sim_rtl/controller.vhd:687:49 */
  assign n1652 = regs_rdata[11:10]; // extract
  /*# sim_rtl/controller.vhd:687:37 */
  assign n1654 = {2'b00, n1652};
  /*# sim_rtl/controller.vhd:684:21 */
  assign n1656 = n1651 ? 4'b0101 : n1654;
  /*# sim_rtl/controller.vhd:690:40 */
  assign n1657 = slot_voice_data[3]; // extract
  /*# sim_rtl/controller.vhd:691:42 */
  assign n1658 = regs_rdata[11:9]; // extract
  /*# sim_rtl/controller.vhd:691:68 */
  assign n1659 = regs_rdata[8]; // extract
  /*# sim_rtl/controller.vhd:691:56 */
  assign n1660 = {n1658, n1659};
  /*# sim_rtl/controller.vhd:693:49 */
  assign n1661 = regs_rdata[11:10]; // extract
  /*# sim_rtl/controller.vhd:693:37 */
  assign n1663 = {2'b00, n1661};
  /*# sim_rtl/controller.vhd:690:21 */
  assign n1664 = n1657 ? n1660 : n1663;
  /*# sim_rtl/controller.vhd:683:17 */
  assign n1665 = n1650 ? n1656 : n1664;
  /*# sim_rtl/controller.vhd:701:39 */
  assign n1666 = slot_voice_data[0]; // extract
  /*# sim_rtl/controller.vhd:702:39 */
  assign n1667 = slot_voice_data[1]; // extract
  /*# sim_rtl/controller.vhd:703:39 */
  assign n1668 = slot_voice_data[7:4]; // extract
  /*# sim_rtl/controller.vhd:704:43 */
  assign n1669 = slot_voice_data[16]; // extract
  /*# sim_rtl/controller.vhd:705:43 */
  assign n1670 = slot_voice_data[19:17]; // extract
  /*# sim_rtl/controller.vhd:708:39 */
  assign n1671 = slot_voice_data[23:20]; // extract
  /*# sim_rtl/controller.vhd:709:39 */
  assign n1672 = slot_voice_data[27:24]; // extract
  /*# sim_rtl/controller.vhd:710:39 */
  assign n1673 = slot_voice_data[31:28]; // extract
  /*# sim_rtl/controller.vhd:714:40 */
  assign n1674 = slot_voice_data[2]; // extract
  /*# sim_rtl/controller.vhd:717:47 */
  assign n1675 = slot_voice_data[35:32]; // extract
  /*# sim_rtl/controller.vhd:714:21 */
  assign n1677 = n1674 ? 4'b0000 : n1675;
  /*# sim_rtl/controller.vhd:720:29 */
  assign n1678 = slot[0]; // extract
  /*# sim_rtl/controller.vhd:720:33 */
  assign n1679 = ~n1678;
  /*# sim_rtl/controller.vhd:720:55 */
  assign n1680 = rflag[5]; // extract
  /*# sim_rtl/controller.vhd:720:75 */
  assign n1681 = {27'b0, slot};  // uext
  /*# sim_rtl/controller.vhd:720:93 */
  assign n1683 = $signed(n1681) / $signed(32'b00000000000000000000000000000010); // sdiv
  /*# sim_rtl/controller.vhd:720:72 */
  assign n1685 = $signed(32'b00000000000000000000000000000111) <= $signed(n1683);
  /*# sim_rtl/controller.vhd:720:65 */
  assign n1686 = n1685 & n1680;
  /*# sim_rtl/controller.vhd:720:44 */
  assign n1687 = ~n1686;
  /*# sim_rtl/controller.vhd:720:40 */
  assign n1688 = n1687 & n1679;
  /*# sim_rtl/controller.vhd:722:37 */
  assign n1689 = regs_rdata[13]; // extract
  /*# sim_rtl/controller.vhd:724:43 */
  assign n1690 = slot_voice_data[2]; // extract
  /*# sim_rtl/controller.vhd:724:46 */
  assign n1691 = ~n1690;
  /*# sim_rtl/controller.vhd:727:48 */
  assign n1692 = slot_voice_data[35:32]; // extract
  /*# sim_rtl/controller.vhd:724:21 */
  assign n1694 = n1691 ? 4'b0111 : n1692;
  /*# sim_rtl/controller.vhd:722:21 */
  assign n1696 = n1689 ? 4'b0101 : n1694;
  /*# sim_rtl/controller.vhd:720:21 */
  assign n1698 = n1688 ? 4'b0000 : n1696;
  /*# sim_rtl/controller.vhd:713:17 */
  assign n1699 = n1583 ? n1677 : n1698;
  /*# sim_rtl/controller.vhd:620:13 */
  assign n1701 = stage == 2'b11;
  /*# sim_rtl/controller.vhd:489:13 */
  assign n1702 = {n1701, n1544, n1313, n1311};
  /*# sim_rtl/controller.vhd:489:13 */
  always @*
    case (n1702)
      4'b1000: n1703 = n1666;
      4'b0100: n1703 = n1148;
      4'b0010: n1703 = n1148;
      4'b0001: n1703 = n1148;
      default: n1703 = n1148;
    endcase
  /*# sim_rtl/controller.vhd:489:13 */
  always @*
    case (n1702)
      4'b1000: n1704 = n1667;
      4'b0100: n1704 = n1149;
      4'b0010: n1704 = n1149;
      4'b0001: n1704 = n1149;
      default: n1704 = n1149;
    endcase
  /*# sim_rtl/controller.vhd:489:13 */
  always @*
    case (n1702)
      4'b1000: n1705 = n1669;
      4'b0100: n1705 = n1150;
      4'b0010: n1705 = n1150;
      4'b0001: n1705 = n1150;
      default: n1705 = n1150;
    endcase
  /*# sim_rtl/controller.vhd:489:13 */
  always @*
    case (n1702)
      4'b1000: n1706 = n1668;
      4'b0100: n1706 = n1151;
      4'b0010: n1706 = n1151;
      4'b0001: n1706 = n1151;
      default: n1706 = n1151;
    endcase
  /*# sim_rtl/controller.vhd:489:13 */
  always @*
    case (n1702)
      4'b1000: n1707 = n1644;
      4'b0100: n1707 = n1152;
      4'b0010: n1707 = n1152;
      4'b0001: n1707 = n1152;
      default: n1707 = n1152;
    endcase
  /*# sim_rtl/controller.vhd:489:13 */
  always @*
    case (n1702)
      4'b1000: n1708 = n1670;
      4'b0100: n1708 = n1153;
      4'b0010: n1708 = n1153;
      4'b0001: n1708 = n1153;
      default: n1708 = n1153;
    endcase
  /*# sim_rtl/controller.vhd:489:13 */
  always @*
    case (n1702)
      4'b1000: n1709 = n1671;
      4'b0100: n1709 = n1154;
      4'b0010: n1709 = n1154;
      4'b0001: n1709 = n1154;
      default: n1709 = n1154;
    endcase
  /*# sim_rtl/controller.vhd:489:13 */
  always @*
    case (n1702)
      4'b1000: n1710 = n1672;
      4'b0100: n1710 = n1155;
      4'b0010: n1710 = n1155;
      4'b0001: n1710 = n1155;
      default: n1710 = n1155;
    endcase
  /*# sim_rtl/controller.vhd:489:13 */
  always @*
    case (n1702)
      4'b1000: n1711 = n1673;
      4'b0100: n1711 = n1156;
      4'b0010: n1711 = n1156;
      4'b0001: n1711 = n1156;
      default: n1711 = n1156;
    endcase
  /*# sim_rtl/controller.vhd:489:13 */
  always @*
    case (n1702)
      4'b1000: n1712 = n1699;
      4'b0100: n1712 = n1157;
      4'b0010: n1712 = n1157;
      4'b0001: n1712 = n1157;
      default: n1712 = n1157;
    endcase
  /*# sim_rtl/controller.vhd:489:13 */
  always @*
    case (n1702)
      4'b1000: n1713 = n1646;
      4'b0100: n1713 = n1158;
      4'b0010: n1713 = n1158;
      4'b0001: n1713 = n1158;
      default: n1713 = n1158;
    endcase
  /*# sim_rtl/controller.vhd:489:13 */
  always @*
    case (n1702)
      4'b1000: n1714 = n1645;
      4'b0100: n1714 = n1159;
      4'b0010: n1714 = n1159;
      4'b0001: n1714 = n1159;
      default: n1714 = n1159;
    endcase
  /*# sim_rtl/controller.vhd:489:13 */
  always @*
    case (n1702)
      4'b1000: n1715 = n1665;
      4'b0100: n1715 = n1160;
      4'b0010: n1715 = n1160;
      4'b0001: n1715 = n1160;
      default: n1715 = n1160;
    endcase
  /*# sim_rtl/controller.vhd:489:13 */
  always @*
    case (n1702)
      4'b1000: n1716 = n1583;
      4'b0100: n1716 = n1161;
      4'b0010: n1716 = n1161;
      4'b0001: n1716 = n1161;
      default: n1716 = n1161;
    endcase
  /*# sim_rtl/controller.vhd:489:13 */
  always @*
    case (n1702)
      4'b1000: n1717 = n1555;
      4'b0100: n1717 = n1162;
      4'b0010: n1717 = n1162;
      4'b0001: n1717 = n1162;
      default: n1717 = n1162;
    endcase
  /*# sim_rtl/controller.vhd:489:13 */
  always @*
    case (n1702)
      4'b1000: n1718 = n2042;
      4'b0100: n1718 = n1164;
      4'b0010: n1718 = n1164;
      4'b0001: n1718 = n1164;
      default: n1718 = n1164;
    endcase
  /*# sim_rtl/controller.vhd:489:13 */
  always @*
    case (n1702)
      4'b1000: n1720 = n1166;
      4'b0100: n1720 = n1526;
      4'b0010: n1720 = n1166;
      4'b0001: n1720 = 1'b0;
      default: n1720 = n1166;
    endcase
  /*# sim_rtl/controller.vhd:489:13 */
  always @*
    case (n1702)
      4'b1000: n1721 = n1167;
      4'b0100: n1721 = n1167;
      4'b0010: n1721 = n1167;
      4'b0001: n1721 = n1309;
      default: n1721 = n1167;
    endcase
  /*# sim_rtl/controller.vhd:489:13 */
  always @*
    case (n1702)
      4'b1000: n1722 = n1168;
      4'b0100: n1722 = n1527;
      4'b0010: n1722 = n1168;
      4'b0001: n1722 = n1168;
      default: n1722 = n1168;
    endcase
  /*# sim_rtl/controller.vhd:489:13 */
  always @*
    case (n1702)
      4'b1000: n1724 = n1169;
      4'b0100: n1724 = n1537;
      4'b0010: n1724 = n1169;
      4'b0001: n1724 = 1'b0;
      default: n1724 = n1169;
    endcase
  /*# sim_rtl/controller.vhd:489:13 */
  always @*
    case (n1702)
      4'b1000: n1725 = n1171;
      4'b0100: n1725 = n1538;
      4'b0010: n1725 = n1171;
      4'b0001: n1725 = n1171;
      default: n1725 = n1171;
    endcase
  /*# sim_rtl/controller.vhd:489:13 */
  always @*
    case (n1702)
      4'b1000: n1726 = n1172;
      4'b0100: n1726 = n1539;
      4'b0010: n1726 = n1172;
      4'b0001: n1726 = n1172;
      default: n1726 = n1172;
    endcase
  /*# sim_rtl/controller.vhd:489:13 */
  always @*
    case (n1702)
      4'b1000: n1727 = n1583;
      4'b0100: n1727 = n618_kflag;
      4'b0010: n1727 = n618_kflag;
      4'b0001: n1727 = n618_kflag;
      default: n1727 = n618_kflag;
    endcase
  /*# sim_rtl/controller.vhd:489:13 */
  always @*
    case (n1702)
      4'b1000: n1734 = n1173;
      4'b0100: n1734 = n1542;
      4'b0010: n1734 = n1173;
      4'b0001: n1734 = n1173;
      default: n1734 = n1173;
    endcase
  /*# sim_rtl/controller.vhd:489:13 */
  always @*
    case (n1702)
      4'b1000: n1735 = n1174;
      4'b0100: n1735 = n1174;
      4'b0010: n1735 = n1174;
      4'b0001: n1735 = n1309;
      default: n1735 = n1174;
    endcase
  /*# sim_rtl/controller.vhd:463:1 */
  assign n1736 = n1767 ? n1703 : n1148;
  /*# sim_rtl/controller.vhd:463:1 */
  assign n1737 = n1768 ? n1704 : n1149;
  /*# sim_rtl/controller.vhd:463:1 */
  assign n1738 = n1769 ? n1705 : n1150;
  /*# sim_rtl/controller.vhd:463:1 */
  assign n1739 = n1770 ? n1706 : n1151;
  /*# sim_rtl/controller.vhd:463:1 */
  assign n1740 = n1771 ? n1707 : n1152;
  /*# sim_rtl/controller.vhd:463:1 */
  assign n1741 = n1772 ? n1708 : n1153;
  /*# sim_rtl/controller.vhd:463:1 */
  assign n1742 = n1773 ? n1709 : n1154;
  /*# sim_rtl/controller.vhd:463:1 */
  assign n1743 = n1774 ? n1710 : n1155;
  /*# sim_rtl/controller.vhd:463:1 */
  assign n1744 = n1775 ? n1711 : n1156;
  /*# sim_rtl/controller.vhd:463:1 */
  assign n1745 = n1776 ? n1712 : n1157;
  /*# sim_rtl/controller.vhd:463:1 */
  assign n1746 = n1777 ? n1713 : n1158;
  /*# sim_rtl/controller.vhd:463:1 */
  assign n1747 = n1778 ? n1714 : n1159;
  /*# sim_rtl/controller.vhd:463:1 */
  assign n1748 = n1779 ? n1715 : n1160;
  /*# sim_rtl/controller.vhd:463:1 */
  assign n1749 = n1780 ? n1716 : n1161;
  /*# sim_rtl/controller.vhd:463:1 */
  assign n1750 = n1781 ? n1717 : n1162;
  /*# sim_rtl/controller.vhd:463:1 */
  assign n1751 = n1782 ? n1718 : n1164;
  /*# sim_rtl/controller.vhd:463:1 */
  assign n1752 = n1784 ? n1720 : n1166;
  /*# sim_rtl/controller.vhd:463:1 */
  assign n1753 = n1785 ? n1721 : n1167;
  /*# sim_rtl/controller.vhd:463:1 */
  assign n1754 = n1786 ? n1722 : n1168;
  /*# sim_rtl/controller.vhd:463:1 */
  assign n1755 = n1787 ? n1724 : n1169;
  /*# sim_rtl/controller.vhd:463:1 */
  assign n1756 = n1789 ? n1725 : n1171;
  /*# sim_rtl/controller.vhd:463:1 */
  assign n1757 = n1790 ? n1726 : n1172;
  /*# sim_rtl/controller.vhd:463:1 */
  assign n1765 = n1798 ? n1734 : n1173;
  /*# sim_rtl/controller.vhd:463:1 */
  assign n1766 = n1799 ? n1735 : n1174;
  /*# sim_rtl/controller.vhd:463:1 */
  assign n1767 = clkena & n1269;
  /*# sim_rtl/controller.vhd:463:1 */
  assign n1768 = clkena & n1269;
  /*# sim_rtl/controller.vhd:463:1 */
  assign n1769 = clkena & n1269;
  /*# sim_rtl/controller.vhd:463:1 */
  assign n1770 = clkena & n1269;
  /*# sim_rtl/controller.vhd:463:1 */
  assign n1771 = clkena & n1269;
  /*# sim_rtl/controller.vhd:463:1 */
  assign n1772 = clkena & n1269;
  /*# sim_rtl/controller.vhd:463:1 */
  assign n1773 = clkena & n1269;
  /*# sim_rtl/controller.vhd:463:1 */
  assign n1774 = clkena & n1269;
  /*# sim_rtl/controller.vhd:463:1 */
  assign n1775 = clkena & n1269;
  /*# sim_rtl/controller.vhd:463:1 */
  assign n1776 = clkena & n1269;
  /*# sim_rtl/controller.vhd:463:1 */
  assign n1777 = clkena & n1269;
  /*# sim_rtl/controller.vhd:463:1 */
  assign n1778 = clkena & n1269;
  /*# sim_rtl/controller.vhd:463:1 */
  assign n1779 = clkena & n1269;
  /*# sim_rtl/controller.vhd:463:1 */
  assign n1780 = clkena & n1269;
  /*# sim_rtl/controller.vhd:463:1 */
  assign n1781 = clkena & n1269;
  /*# sim_rtl/controller.vhd:463:1 */
  assign n1782 = clkena & n1269;
  /*# sim_rtl/controller.vhd:463:1 */
  assign n1783 = n1305 & n1269;
  /*# sim_rtl/controller.vhd:463:1 */
  assign n1784 = clkena & n1269;
  /*# sim_rtl/controller.vhd:463:1 */
  assign n1785 = clkena & n1269;
  /*# sim_rtl/controller.vhd:463:1 */
  assign n1786 = clkena & n1269;
  /*# sim_rtl/controller.vhd:463:1 */
  assign n1787 = clkena & n1269;
  /*# sim_rtl/controller.vhd:463:1 */
  assign n1788 = n1274 & n1269;
  /*# sim_rtl/controller.vhd:463:1 */
  assign n1789 = clkena & n1269;
  /*# sim_rtl/controller.vhd:463:1 */
  assign n1790 = clkena & n1269;
  /*# sim_rtl/controller.vhd:463:1 */
  assign n1791 = clkena & n1269;
  /*# sim_rtl/controller.vhd:463:1 */
  assign n1798 = clkena & n1269;
  /*# sim_rtl/controller.vhd:463:1 */
  assign n1799 = clkena & n1269;
  /*# sim_rtl/controller.vhd:743:28 */
  assign n1948 = slot[4:1]; // extract
  /*# sim_rtl/controller.vhd:748:27 */
  assign n1949 = ss_local_data | ss_u_register_memory_data;
  /*# sim_rtl/controller.vhd:748:56 */
  assign n1950 = n1949 | ss_vmem_data;
  /*# sim_rtl/controller.vhd:749:23 */
  assign n1952 = 1'b1 & ss_u_register_memory_ready;
  /*# sim_rtl/controller.vhd:749:54 */
  assign n1953 = n1952 & ss_vmem_ready;
  /*# sim_rtl/controller.vhd:85:5 */
  assign n1954 = ~reset;
  /*# sim_rtl/controller.vhd:301:1 */
  assign n1955 = n1954 ? n1736 : n1956;
  /*# sim_rtl/controller.vhd:301:1 */
  always @(posedge clk)
    n1956 <= n1955;
  /*# sim_rtl/controller.vhd:86:5 */
  assign n1957 = ~reset;
  /*# sim_rtl/controller.vhd:301:1 */
  assign n1958 = n1957 ? n1737 : n1959;
  /*# sim_rtl/controller.vhd:301:1 */
  always @(posedge clk)
    n1959 <= n1958;
  /*# sim_rtl/controller.vhd:301:1 */
  always @(posedge clk or posedge reset)
    if (reset)
      n1960 <= 1'b0;
    else
      n1960 <= n1738;
  /*# sim_rtl/controller.vhd:301:1 */
  always @(posedge clk or posedge reset)
    if (reset)
      n1961 <= 4'b0000;
    else
      n1961 <= n1739;
  /*# sim_rtl/controller.vhd:301:1 */
  always @(posedge clk or posedge reset)
    if (reset)
      n1962 <= 7'b0000000;
    else
      n1962 <= n1740;
  /*# sim_rtl/controller.vhd:301:1 */
  always @(posedge clk or posedge reset)
    if (reset)
      n1963 <= 3'b000;
    else
      n1963 <= n1741;
  /*# sim_rtl/controller.vhd:301:1 */
  always @(posedge clk or posedge reset)
    if (reset)
      n1964 <= 4'b0000;
    else
      n1964 <= n1742;
  /*# sim_rtl/controller.vhd:301:1 */
  always @(posedge clk or posedge reset)
    if (reset)
      n1965 <= 4'b0000;
    else
      n1965 <= n1743;
  /*# sim_rtl/controller.vhd:301:1 */
  always @(posedge clk or posedge reset)
    if (reset)
      n1966 <= 4'b0000;
    else
      n1966 <= n1744;
  /*# sim_rtl/controller.vhd:301:1 */
  always @(posedge clk or posedge reset)
    if (reset)
      n1967 <= 4'b0000;
    else
      n1967 <= n1745;
  /*# sim_rtl/controller.vhd:301:1 */
  always @(posedge clk or posedge reset)
    if (reset)
      n1968 <= 3'b000;
    else
      n1968 <= n1746;
  /*# sim_rtl/controller.vhd:301:1 */
  always @(posedge clk or posedge reset)
    if (reset)
      n1969 <= 9'b000000000;
    else
      n1969 <= n1747;
  /*# sim_rtl/controller.vhd:301:1 */
  always @(posedge clk or posedge reset)
    if (reset)
      n1970 <= 4'b0000;
    else
      n1970 <= n1748;
  /*# sim_rtl/controller.vhd:301:1 */
  always @(posedge clk or posedge reset)
    if (reset)
      n1971 <= 1'b0;
    else
      n1971 <= n1749;
  /*# sim_rtl/controller.vhd:301:1 */
  always @(posedge clk or posedge reset)
    if (reset)
      n1972 <= 1'b0;
    else
      n1972 <= n1750;
  /*# sim_rtl/controller.vhd:160:12 */
  assign n1973 = ~reset;
  /*# sim_rtl/controller.vhd:301:1 */
  assign n1974 = n1973 ? n1751 : inst_cache;
  /*# sim_rtl/controller.vhd:301:1 */
  always @(posedge clk)
    n1975 <= n1974;
  /*# sim_rtl/controller.vhd:301:1 */
  always @(posedge clk or posedge reset)
    if (reset)
      n1976 <= 6'b000000;
    else
      n1976 <= n1304;
  /*# sim_rtl/controller.vhd:301:1 */
  always @(posedge clk or posedge reset)
    if (reset)
      n1977 <= 1'b0;
    else
      n1977 <= n1752;
  /*# sim_rtl/controller.vhd:301:1 */
  always @(posedge clk or posedge reset)
    if (reset)
      n1978 <= 6'b000000;
    else
      n1978 <= n1753;
  /*# sim_rtl/controller.vhd:178:12 */
  assign n1979 = ~reset;
  /*# sim_rtl/controller.vhd:301:1 */
  assign n1980 = n1979 ? n1754 : user_voice_wdata;
  /*# sim_rtl/controller.vhd:301:1 */
  always @(posedge clk)
    n1981 <= n1980;
  /*# sim_rtl/controller.vhd:301:1 */
  always @(posedge clk or posedge reset)
    if (reset)
      n1982 <= 1'b0;
    else
      n1982 <= n1755;
  /*# sim_rtl/controller.vhd:301:1 */
  always @(posedge clk or posedge reset)
    if (reset)
      n1983 <= 4'b0000;
    else
      n1983 <= n1273;
  /*# sim_rtl/controller.vhd:184:12 */
  assign n1984 = ~reset;
  /*# sim_rtl/controller.vhd:301:1 */
  assign n1985 = n1984 ? n1756 : regs_wdata;
  /*# sim_rtl/controller.vhd:301:1 */
  always @(posedge clk)
    n1986 <= n1985;
  /*# sim_rtl/controller.vhd:301:1 */
  always @(posedge clk or posedge reset)
    if (reset)
      n1987 <= 8'b00000000;
    else
      n1987 <= n1757;
  /*# sim_rtl/controller.vhd:301:1 */
  always @(posedge clk or posedge reset)
    if (reset)
      n1988 <= 32'b00000000000000000000000000000000;
    else
      n1988 <= n1267;
  /*# sim_rtl/controller.vhd:301:1 */
  assign n1989 = n1791 ? n1727 : n618_kflag;
  /*# sim_rtl/controller.vhd:301:1 */
  always @(posedge clk or posedge reset)
    if (reset)
      n1990 <= 1'b0;
    else
      n1990 <= n1989;
  /*# sim_rtl/controller.vhd:301:1 */
  always @(posedge clk or posedge reset)
    if (reset)
      n1991 <= 1'b0;
    else
      n1991 <= n1765;
  /*# sim_rtl/controller.vhd:301:1 */
  always @(posedge clk or posedge reset)
    if (reset)
      n1992 <= 6'b000000;
    else
      n1992 <= n1766;
  /*# sim_rtl/controller.vhd:652:39 */
  reg [5:0] n1993[15:0] ; // memory
  initial begin
    n1993[15] = 6'b111000;
    n1993[14] = 6'b110111;
    n1993[13] = 6'b110110;
    n1993[12] = 6'b110101;
    n1993[11] = 6'b110100;
    n1993[10] = 6'b110011;
    n1993[9] = 6'b110010;
    n1993[8] = 6'b110000;
    n1993[7] = 6'b101111;
    n1993[6] = 6'b101101;
    n1993[5] = 6'b101011;
    n1993[4] = 6'b101000;
    n1993[3] = 6'b100101;
    n1993[2] = 6'b100000;
    n1993[1] = 6'b011000;
    n1993[0] = 6'b000000;
    end
  assign n1995 = n1993[n1584];
  /*# sim_rtl/controller.vhd:652:39 */
  /*# sim_rtl/controller.vhd:480:73 */
  assign n1997 = {28'bX, inst_cache};
  /*# sim_rtl/controller.vhd:480:73 */
  assign n1998 = n1997[n1292 * 4 +: 4]; //(Bmux)
  /*# sim_rtl/controller.vhd:626:17 */
  assign n1999 = n1550[3]; // extract
  /*# sim_rtl/controller.vhd:626:17 */
  assign n2000 = ~n1999;
  /*# sim_rtl/controller.vhd:626:17 */
  assign n2001 = n1550[2]; // extract
  /*# sim_rtl/controller.vhd:626:17 */
  assign n2002 = ~n2001;
  /*# sim_rtl/controller.vhd:626:17 */
  assign n2003 = n2000 & n2002;
  /*# sim_rtl/controller.vhd:626:17 */
  assign n2004 = n2000 & n2001;
  /*# sim_rtl/controller.vhd:626:17 */
  assign n2005 = n1999 & n2002;
  /*# sim_rtl/controller.vhd:626:17 */
  assign n2006 = n1550[1]; // extract
  /*# sim_rtl/controller.vhd:626:17 */
  assign n2007 = ~n2006;
  /*# sim_rtl/controller.vhd:626:17 */
  assign n2008 = n2003 & n2007;
  /*# sim_rtl/controller.vhd:626:17 */
  assign n2009 = n2003 & n2006;
  /*# sim_rtl/controller.vhd:626:17 */
  assign n2010 = n2004 & n2007;
  /*# sim_rtl/controller.vhd:626:17 */
  assign n2011 = n2004 & n2006;
  /*# sim_rtl/controller.vhd:626:17 */
  assign n2012 = n2005 & n2007;
  /*# sim_rtl/controller.vhd:626:17 */
  assign n2013 = n1550[0]; // extract
  /*# sim_rtl/controller.vhd:626:17 */
  assign n2014 = ~n2013;
  /*# sim_rtl/controller.vhd:626:17 */
  assign n2015 = n2008 & n2014;
  /*# sim_rtl/controller.vhd:626:17 */
  assign n2016 = n2008 & n2013;
  /*# sim_rtl/controller.vhd:626:17 */
  assign n2017 = n2009 & n2014;
  /*# sim_rtl/controller.vhd:626:17 */
  assign n2018 = n2009 & n2013;
  /*# sim_rtl/controller.vhd:626:17 */
  assign n2019 = n2010 & n2014;
  /*# sim_rtl/controller.vhd:626:17 */
  assign n2020 = n2010 & n2013;
  /*# sim_rtl/controller.vhd:626:17 */
  assign n2021 = n2011 & n2014;
  /*# sim_rtl/controller.vhd:626:17 */
  assign n2022 = n2011 & n2013;
  /*# sim_rtl/controller.vhd:626:17 */
  assign n2023 = n2012 & n2014;
  /*# sim_rtl/controller.vhd:626:17 */
  assign n2024 = n1164[3:0]; // extract
  /*# sim_rtl/controller.vhd:626:17 */
  assign n2025 = n2015 ? n1552 : n2024;
  /*# sim_rtl/controller.vhd:626:17 */
  assign n2026 = n1164[7:4]; // extract
  /*# sim_rtl/controller.vhd:626:17 */
  assign n2027 = n2016 ? n1552 : n2026;
  /*# sim_rtl/controller.vhd:626:17 */
  assign n2028 = n1164[11:8]; // extract
  /*# sim_rtl/controller.vhd:626:17 */
  assign n2029 = n2017 ? n1552 : n2028;
  /*# sim_rtl/controller.vhd:626:17 */
  assign n2030 = n1164[15:12]; // extract
  /*# sim_rtl/controller.vhd:626:17 */
  assign n2031 = n2018 ? n1552 : n2030;
  /*# sim_rtl/controller.vhd:626:17 */
  assign n2032 = n1164[19:16]; // extract
  /*# sim_rtl/controller.vhd:626:17 */
  assign n2033 = n2019 ? n1552 : n2032;
  /*# sim_rtl/controller.vhd:626:17 */
  assign n2034 = n1164[23:20]; // extract
  /*# sim_rtl/controller.vhd:626:17 */
  assign n2035 = n2020 ? n1552 : n2034;
  /*# sim_rtl/controller.vhd:626:17 */
  assign n2036 = n1164[27:24]; // extract
  /*# sim_rtl/controller.vhd:626:17 */
  assign n2037 = n2021 ? n1552 : n2036;
  /*# sim_rtl/controller.vhd:626:17 */
  assign n2038 = n1164[31:28]; // extract
  /*# sim_rtl/controller.vhd:626:17 */
  assign n2039 = n2022 ? n1552 : n2038;
  /*# sim_rtl/controller.vhd:626:17 */
  assign n2040 = n1164[35:32]; // extract
  /*# sim_rtl/controller.vhd:626:17 */
  assign n2041 = n2023 ? n1552 : n2040;
  /*# sim_rtl/controller.vhd:626:17 */
  assign n2042 = {n2041, n2039, n2037, n2035, n2033, n2031, n2029, n2027, n2025};
endmodule

module slotcounter_Brtl_8
  (input  clk,
   input  reset,
   input  clkena,
   output [4:0] slot,
   output [1:0] stage,
   input  ss_hold,
   input  [7:0] ss_addr,
   input  ss_read,
   input  ss_write,
   input  [31:0] ss_wdata,
   output [31:0] ss_rdata,
   output ss_initialized);
  wire [6:0] ff_count;
  reg [31:0] ss_local_data;
  wire n508;
  wire n509;
  wire [31:0] n513;
  wire [6:0] n514;
  wire [31:0] n515;
  wire n517;
  wire [6:0] n518;
  wire [31:0] n519;
  wire [31:0] n521;
  wire [6:0] n522;
  wire [6:0] n523;
  wire [31:0] n524;
  wire [31:0] n526;
  wire [31:0] n528;
  wire [6:0] n529;
  wire [6:0] n530;
  wire n532;
  reg [6:0] n533;
  wire [6:0] n534;
  wire n535;
  wire n538;
  wire n540;
  wire [6:0] n542;
  wire [6:0] n544;
  wire [6:0] n545;
  wire n546;
  wire [1:0] n559;
  wire [4:0] n560;
  localparam n561 = 1'b1;
  reg [6:0] n562;
  reg [31:0] n563;
  assign slot = n560; //(module output)
  assign stage = n559; //(module output)
  assign ss_rdata = ss_local_data; //(module output)
  assign ss_initialized = n561; //(module output)
  /*# sim_rtl/slotcounter.vhd:65:12 */
  assign ff_count = n562; // (signal)
  /*# sim_rtl/slotcounter.vhd:66:12 */
  always @*
    ss_local_data = n563; // (isignal)
  initial
    ss_local_data = 32'b00000000000000000000000000000000;
  /*# sim_rtl/slotcounter.vhd:84:33 */
  assign n508 = ss_read | ss_write;
  /*# sim_rtl/slotcounter.vhd:84:16 */
  assign n509 = n508 & ss_hold;
  /*# sim_rtl/slotcounter.vhd:93:6 */
  assign n513 = {24'b0, ss_addr};  // uext
  /*# sim_rtl/slotcounter.vhd:94:36 */
  assign n514 = ss_wdata[6:0]; // extract
  /*# sim_rtl/slotcounter.vhd:94:15 */
  assign n515 = {25'b0, n514};  // uext
  /*# sim_rtl/slotcounter.vhd:94:50 */
  assign n517 = $signed(n515) >= $signed(32'b00000000000000000000000000001000);
  /*# sim_rtl/slotcounter.vhd:94:119 */
  assign n518 = ss_wdata[6:0]; // extract
  /*# sim_rtl/slotcounter.vhd:94:98 */
  assign n519 = {25'b0, n518};  // uext
  /*# sim_rtl/slotcounter.vhd:94:132 */
  assign n521 = n519 - 32'b00000000000000000000000000001000;
  /*# sim_rtl/slotcounter.vhd:94:76 */
  assign n522 = n521[6:0];  // trunc
  /*# sim_rtl/slotcounter.vhd:94:203 */
  assign n523 = ss_wdata[6:0]; // extract
  /*# sim_rtl/slotcounter.vhd:94:182 */
  assign n524 = {25'b0, n523};  // uext
  /*# sim_rtl/slotcounter.vhd:94:216 */
  assign n526 = n524 + 32'b00000000000000000000000001001000;
  /*# sim_rtl/slotcounter.vhd:94:219 */
  assign n528 = n526 - 32'b00000000000000000000000000001000;
  /*# sim_rtl/slotcounter.vhd:94:160 */
  assign n529 = n528[6:0];  // trunc
  /*# sim_rtl/slotcounter.vhd:94:12 */
  assign n530 = n517 ? n522 : n529;
  /*# sim_rtl/slotcounter.vhd:94:1 */
  assign n532 = n513 == 32'b00000000000000000000000001001110;
  /*# sim_rtl/slotcounter.vhd:93:1 */
  always @*
    case (n532)
      1'b1: n533 = n530;
      default: n533 = ff_count;
    endcase
  /*# sim_rtl/slotcounter.vhd:84:1 */
  assign n534 = n535 ? n533 : ff_count;
  /*# sim_rtl/slotcounter.vhd:84:1 */
  assign n535 = ss_write & n509;
  /*# sim_rtl/slotcounter.vhd:100:11 */
  assign n538 = ~ss_hold;
  /*# sim_rtl/slotcounter.vhd:103:30 */
  assign n540 = ff_count == 7'b1000111;
  /*# sim_rtl/slotcounter.vhd:106:42 */
  assign n542 = ff_count + 7'b0000001;
  /*# sim_rtl/slotcounter.vhd:103:17 */
  assign n544 = n540 ? 7'b0000000 : n542;
  /*# sim_rtl/slotcounter.vhd:100:1 */
  assign n545 = n546 ? n544 : n534;
  /*# sim_rtl/slotcounter.vhd:100:1 */
  assign n546 = clkena & n538;
  /*# sim_rtl/slotcounter.vhd:116:24 */
  assign n559 = ff_count[1:0]; // extract
  /*# sim_rtl/slotcounter.vhd:117:24 */
  assign n560 = ff_count[6:2]; // extract
  /*# sim_rtl/slotcounter.vhd:81:1 */
  always @(posedge clk or posedge reset)
    if (reset)
      n562 <= 7'b0111111;
    else
      n562 <= n545;
  /*# sim_rtl/slotcounter.vhd:81:1 */
  always @(posedge clk or posedge reset)
    if (reset)
      n563 <= 32'b00000000000000000000000000000000;
    else
      n563 <= 32'b00000000000000000000000000000000;
endmodule

module slotcounter_Brtl_5
  (input  clk,
   input  reset,
   input  clkena,
   output [4:0] slot,
   output [1:0] stage,
   input  ss_hold,
   input  [7:0] ss_addr,
   input  ss_read,
   input  ss_write,
   input  [31:0] ss_wdata,
   output [31:0] ss_rdata,
   output ss_initialized);
  wire [6:0] ff_count;
  reg [31:0] ss_local_data;
  wire n442;
  wire n443;
  wire [31:0] n447;
  wire [6:0] n448;
  wire [31:0] n449;
  wire n451;
  wire [6:0] n452;
  wire [31:0] n453;
  wire [31:0] n455;
  wire [6:0] n456;
  wire [6:0] n457;
  wire [31:0] n458;
  wire [31:0] n460;
  wire [31:0] n462;
  wire [6:0] n463;
  wire [6:0] n464;
  wire n466;
  reg [6:0] n467;
  wire [6:0] n468;
  wire n469;
  wire n472;
  wire n474;
  wire [6:0] n476;
  wire [6:0] n478;
  wire [6:0] n479;
  wire n480;
  wire [1:0] n493;
  wire [4:0] n494;
  localparam n495 = 1'b1;
  reg [6:0] n496;
  reg [31:0] n497;
  assign slot = n494; //(module output)
  assign stage = n493; //(module output)
  assign ss_rdata = ss_local_data; //(module output)
  assign ss_initialized = n495; //(module output)
  /*# sim_rtl/slotcounter.vhd:65:12 */
  assign ff_count = n496; // (signal)
  /*# sim_rtl/slotcounter.vhd:66:12 */
  always @*
    ss_local_data = n497; // (isignal)
  initial
    ss_local_data = 32'b00000000000000000000000000000000;
  /*# sim_rtl/slotcounter.vhd:84:33 */
  assign n442 = ss_read | ss_write;
  /*# sim_rtl/slotcounter.vhd:84:16 */
  assign n443 = n442 & ss_hold;
  /*# sim_rtl/slotcounter.vhd:93:6 */
  assign n447 = {24'b0, ss_addr};  // uext
  /*# sim_rtl/slotcounter.vhd:94:36 */
  assign n448 = ss_wdata[6:0]; // extract
  /*# sim_rtl/slotcounter.vhd:94:15 */
  assign n449 = {25'b0, n448};  // uext
  /*# sim_rtl/slotcounter.vhd:94:50 */
  assign n451 = $signed(n449) >= $signed(32'b00000000000000000000000000000101);
  /*# sim_rtl/slotcounter.vhd:94:119 */
  assign n452 = ss_wdata[6:0]; // extract
  /*# sim_rtl/slotcounter.vhd:94:98 */
  assign n453 = {25'b0, n452};  // uext
  /*# sim_rtl/slotcounter.vhd:94:132 */
  assign n455 = n453 - 32'b00000000000000000000000000000101;
  /*# sim_rtl/slotcounter.vhd:94:76 */
  assign n456 = n455[6:0];  // trunc
  /*# sim_rtl/slotcounter.vhd:94:203 */
  assign n457 = ss_wdata[6:0]; // extract
  /*# sim_rtl/slotcounter.vhd:94:182 */
  assign n458 = {25'b0, n457};  // uext
  /*# sim_rtl/slotcounter.vhd:94:216 */
  assign n460 = n458 + 32'b00000000000000000000000001001000;
  /*# sim_rtl/slotcounter.vhd:94:219 */
  assign n462 = n460 - 32'b00000000000000000000000000000101;
  /*# sim_rtl/slotcounter.vhd:94:160 */
  assign n463 = n462[6:0];  // trunc
  /*# sim_rtl/slotcounter.vhd:94:12 */
  assign n464 = n451 ? n456 : n463;
  /*# sim_rtl/slotcounter.vhd:94:1 */
  assign n466 = n447 == 32'b00000000000000000000000001001110;
  /*# sim_rtl/slotcounter.vhd:93:1 */
  always @*
    case (n466)
      1'b1: n467 = n464;
      default: n467 = ff_count;
    endcase
  /*# sim_rtl/slotcounter.vhd:84:1 */
  assign n468 = n469 ? n467 : ff_count;
  /*# sim_rtl/slotcounter.vhd:84:1 */
  assign n469 = ss_write & n443;
  /*# sim_rtl/slotcounter.vhd:100:11 */
  assign n472 = ~ss_hold;
  /*# sim_rtl/slotcounter.vhd:103:30 */
  assign n474 = ff_count == 7'b1000111;
  /*# sim_rtl/slotcounter.vhd:106:42 */
  assign n476 = ff_count + 7'b0000001;
  /*# sim_rtl/slotcounter.vhd:103:17 */
  assign n478 = n474 ? 7'b0000000 : n476;
  /*# sim_rtl/slotcounter.vhd:100:1 */
  assign n479 = n480 ? n478 : n468;
  /*# sim_rtl/slotcounter.vhd:100:1 */
  assign n480 = clkena & n472;
  /*# sim_rtl/slotcounter.vhd:116:24 */
  assign n493 = ff_count[1:0]; // extract
  /*# sim_rtl/slotcounter.vhd:117:24 */
  assign n494 = ff_count[6:2]; // extract
  /*# sim_rtl/slotcounter.vhd:81:1 */
  always @(posedge clk or posedge reset)
    if (reset)
      n496 <= 7'b1000010;
    else
      n496 <= n479;
  /*# sim_rtl/slotcounter.vhd:81:1 */
  always @(posedge clk or posedge reset)
    if (reset)
      n497 <= 32'b00000000000000000000000000000000;
    else
      n497 <= 32'b00000000000000000000000000000000;
endmodule

module slotcounter_Brtl_2
  (input  clk,
   input  reset,
   input  clkena,
   output [4:0] slot,
   output [1:0] stage,
   input  ss_hold,
   input  [7:0] ss_addr,
   input  ss_read,
   input  ss_write,
   input  [31:0] ss_wdata,
   output [31:0] ss_rdata,
   output ss_initialized);
  wire [6:0] ff_count;
  reg [31:0] ss_local_data;
  wire n376;
  wire n377;
  wire [31:0] n381;
  wire [6:0] n382;
  wire [31:0] n383;
  wire n385;
  wire [6:0] n386;
  wire [31:0] n387;
  wire [31:0] n389;
  wire [6:0] n390;
  wire [6:0] n391;
  wire [31:0] n392;
  wire [31:0] n394;
  wire [31:0] n396;
  wire [6:0] n397;
  wire [6:0] n398;
  wire n400;
  reg [6:0] n401;
  wire [6:0] n402;
  wire n403;
  wire n406;
  wire n408;
  wire [6:0] n410;
  wire [6:0] n412;
  wire [6:0] n413;
  wire n414;
  wire [1:0] n427;
  wire [4:0] n428;
  localparam n429 = 1'b1;
  reg [6:0] n430;
  reg [31:0] n431;
  assign slot = n428; //(module output)
  assign stage = n427; //(module output)
  assign ss_rdata = ss_local_data; //(module output)
  assign ss_initialized = n429; //(module output)
  /*# sim_rtl/slotcounter.vhd:65:12 */
  assign ff_count = n430; // (signal)
  /*# sim_rtl/slotcounter.vhd:66:12 */
  always @*
    ss_local_data = n431; // (isignal)
  initial
    ss_local_data = 32'b00000000000000000000000000000000;
  /*# sim_rtl/slotcounter.vhd:84:33 */
  assign n376 = ss_read | ss_write;
  /*# sim_rtl/slotcounter.vhd:84:16 */
  assign n377 = n376 & ss_hold;
  /*# sim_rtl/slotcounter.vhd:93:6 */
  assign n381 = {24'b0, ss_addr};  // uext
  /*# sim_rtl/slotcounter.vhd:94:36 */
  assign n382 = ss_wdata[6:0]; // extract
  /*# sim_rtl/slotcounter.vhd:94:15 */
  assign n383 = {25'b0, n382};  // uext
  /*# sim_rtl/slotcounter.vhd:94:50 */
  assign n385 = $signed(n383) >= $signed(32'b00000000000000000000000000000010);
  /*# sim_rtl/slotcounter.vhd:94:119 */
  assign n386 = ss_wdata[6:0]; // extract
  /*# sim_rtl/slotcounter.vhd:94:98 */
  assign n387 = {25'b0, n386};  // uext
  /*# sim_rtl/slotcounter.vhd:94:132 */
  assign n389 = n387 - 32'b00000000000000000000000000000010;
  /*# sim_rtl/slotcounter.vhd:94:76 */
  assign n390 = n389[6:0];  // trunc
  /*# sim_rtl/slotcounter.vhd:94:203 */
  assign n391 = ss_wdata[6:0]; // extract
  /*# sim_rtl/slotcounter.vhd:94:182 */
  assign n392 = {25'b0, n391};  // uext
  /*# sim_rtl/slotcounter.vhd:94:216 */
  assign n394 = n392 + 32'b00000000000000000000000001001000;
  /*# sim_rtl/slotcounter.vhd:94:219 */
  assign n396 = n394 - 32'b00000000000000000000000000000010;
  /*# sim_rtl/slotcounter.vhd:94:160 */
  assign n397 = n396[6:0];  // trunc
  /*# sim_rtl/slotcounter.vhd:94:12 */
  assign n398 = n385 ? n390 : n397;
  /*# sim_rtl/slotcounter.vhd:94:1 */
  assign n400 = n381 == 32'b00000000000000000000000001001110;
  /*# sim_rtl/slotcounter.vhd:93:1 */
  always @*
    case (n400)
      1'b1: n401 = n398;
      default: n401 = ff_count;
    endcase
  /*# sim_rtl/slotcounter.vhd:84:1 */
  assign n402 = n403 ? n401 : ff_count;
  /*# sim_rtl/slotcounter.vhd:84:1 */
  assign n403 = ss_write & n377;
  /*# sim_rtl/slotcounter.vhd:100:11 */
  assign n406 = ~ss_hold;
  /*# sim_rtl/slotcounter.vhd:103:30 */
  assign n408 = ff_count == 7'b1000111;
  /*# sim_rtl/slotcounter.vhd:106:42 */
  assign n410 = ff_count + 7'b0000001;
  /*# sim_rtl/slotcounter.vhd:103:17 */
  assign n412 = n408 ? 7'b0000000 : n410;
  /*# sim_rtl/slotcounter.vhd:100:1 */
  assign n413 = n414 ? n412 : n402;
  /*# sim_rtl/slotcounter.vhd:100:1 */
  assign n414 = clkena & n406;
  /*# sim_rtl/slotcounter.vhd:116:24 */
  assign n427 = ff_count[1:0]; // extract
  /*# sim_rtl/slotcounter.vhd:117:24 */
  assign n428 = ff_count[6:2]; // extract
  /*# sim_rtl/slotcounter.vhd:81:1 */
  always @(posedge clk or posedge reset)
    if (reset)
      n430 <= 7'b1000101;
    else
      n430 <= n413;
  /*# sim_rtl/slotcounter.vhd:81:1 */
  always @(posedge clk or posedge reset)
    if (reset)
      n431 <= 32'b00000000000000000000000000000000;
    else
      n431 <= 32'b00000000000000000000000000000000;
endmodule

module slotcounter_Brtl_0
  (input  clk,
   input  reset,
   input  clkena,
   output [4:0] slot,
   output [1:0] stage,
   input  ss_hold,
   input  [7:0] ss_addr,
   input  ss_read,
   input  ss_write,
   input  [31:0] ss_wdata,
   output [31:0] ss_rdata,
   output ss_initialized);
  wire [6:0] ff_count;
  reg [31:0] ss_local_data;
  wire n302;
  wire n303;
  wire [31:0] n304;
  wire n306;
  reg [6:0] n308;
  wire [6:0] n310;
  wire [31:0] n311;
  wire [6:0] n312;
  wire [31:0] n313;
  wire n315;
  wire [6:0] n316;
  wire [31:0] n317;
  wire [31:0] n319;
  wire [6:0] n320;
  wire [6:0] n321;
  wire [31:0] n322;
  wire [31:0] n324;
  wire [31:0] n326;
  wire [6:0] n327;
  wire [6:0] n328;
  wire n330;
  reg [6:0] n331;
  wire [6:0] n332;
  wire n333;
  wire [6:0] n336;
  localparam [31:0] n337 = 32'b00000000000000000000000000000000;
  wire [24:0] n338;
  wire [31:0] n339;
  wire n340;
  wire n342;
  wire [6:0] n344;
  wire [6:0] n346;
  wire [6:0] n347;
  wire n348;
  wire [1:0] n361;
  wire [4:0] n362;
  localparam n363 = 1'b1;
  reg [6:0] n364;
  reg [31:0] n365;
  assign slot = n362; //(module output)
  assign stage = n361; //(module output)
  assign ss_rdata = ss_local_data; //(module output)
  assign ss_initialized = n363; //(module output)
  /*# sim_rtl/slotcounter.vhd:65:12 */
  assign ff_count = n364; // (signal)
  /*# sim_rtl/slotcounter.vhd:66:12 */
  always @*
    ss_local_data = n365; // (isignal)
  initial
    ss_local_data = 32'b00000000000000000000000000000000;
  /*# sim_rtl/slotcounter.vhd:84:33 */
  assign n302 = ss_read | ss_write;
  /*# sim_rtl/slotcounter.vhd:84:16 */
  assign n303 = n302 & ss_hold;
  /*# sim_rtl/slotcounter.vhd:88:6 */
  assign n304 = {24'b0, ss_addr};  // uext
  /*# sim_rtl/slotcounter.vhd:89:1 */
  assign n306 = n304 == 32'b00000000000000000000000001001110;
  /*# sim_rtl/slotcounter.vhd:88:1 */
  always @*
    case (n306)
      1'b1: n308 = ff_count;
      default: n308 = 7'b0000000;
    endcase
  /*# sim_rtl/slotcounter.vhd:87:1 */
  assign n310 = ss_read ? n308 : 7'b0000000;
  /*# sim_rtl/slotcounter.vhd:93:6 */
  assign n311 = {24'b0, ss_addr};  // uext
  /*# sim_rtl/slotcounter.vhd:94:36 */
  assign n312 = ss_wdata[6:0]; // extract
  /*# sim_rtl/slotcounter.vhd:94:15 */
  assign n313 = {25'b0, n312};  // uext
  /*# sim_rtl/slotcounter.vhd:94:50 */
  assign n315 = $signed(n313) >= $signed(32'b00000000000000000000000000000000);
  /*# sim_rtl/slotcounter.vhd:94:119 */
  assign n316 = ss_wdata[6:0]; // extract
  /*# sim_rtl/slotcounter.vhd:94:98 */
  assign n317 = {25'b0, n316};  // uext
  /*# sim_rtl/slotcounter.vhd:94:132 */
  assign n319 = n317 - 32'b00000000000000000000000000000000;
  /*# sim_rtl/slotcounter.vhd:94:76 */
  assign n320 = n319[6:0];  // trunc
  /*# sim_rtl/slotcounter.vhd:94:203 */
  assign n321 = ss_wdata[6:0]; // extract
  /*# sim_rtl/slotcounter.vhd:94:182 */
  assign n322 = {25'b0, n321};  // uext
  /*# sim_rtl/slotcounter.vhd:94:216 */
  assign n324 = n322 + 32'b00000000000000000000000001001000;
  /*# sim_rtl/slotcounter.vhd:94:219 */
  assign n326 = n324 - 32'b00000000000000000000000000000000;
  /*# sim_rtl/slotcounter.vhd:94:160 */
  assign n327 = n326[6:0];  // trunc
  /*# sim_rtl/slotcounter.vhd:94:12 */
  assign n328 = n315 ? n320 : n327;
  /*# sim_rtl/slotcounter.vhd:94:1 */
  assign n330 = n311 == 32'b00000000000000000000000001001110;
  /*# sim_rtl/slotcounter.vhd:93:1 */
  always @*
    case (n330)
      1'b1: n331 = n328;
      default: n331 = ff_count;
    endcase
  /*# sim_rtl/slotcounter.vhd:84:1 */
  assign n332 = n333 ? n331 : ff_count;
  /*# sim_rtl/slotcounter.vhd:84:1 */
  assign n333 = ss_write & n303;
  /*# sim_rtl/slotcounter.vhd:84:1 */
  assign n336 = n303 ? n310 : 7'b0000000;
  /*# sim_rtl/slotcounter.vhd:74:10 */
  assign n338 = n337[31:7]; // extract
  /*# sim_rtl/slotcounter.vhd:74:10 */
  assign n339 = {n338, n336};
  /*# sim_rtl/slotcounter.vhd:100:11 */
  assign n340 = ~ss_hold;
  /*# sim_rtl/slotcounter.vhd:103:30 */
  assign n342 = ff_count == 7'b1000111;
  /*# sim_rtl/slotcounter.vhd:106:42 */
  assign n344 = ff_count + 7'b0000001;
  /*# sim_rtl/slotcounter.vhd:103:17 */
  assign n346 = n342 ? 7'b0000000 : n344;
  /*# sim_rtl/slotcounter.vhd:100:1 */
  assign n347 = n348 ? n346 : n332;
  /*# sim_rtl/slotcounter.vhd:100:1 */
  assign n348 = clkena & n340;
  /*# sim_rtl/slotcounter.vhd:116:24 */
  assign n361 = ff_count[1:0]; // extract
  /*# sim_rtl/slotcounter.vhd:117:24 */
  assign n362 = ff_count[6:2]; // extract
  /*# sim_rtl/slotcounter.vhd:81:1 */
  always @(posedge clk or posedge reset)
    if (reset)
      n364 <= 7'b1000111;
    else
      n364 <= n347;
  /*# sim_rtl/slotcounter.vhd:81:1 */
  always @(posedge clk or posedge reset)
    if (reset)
      n365 <= 32'b00000000000000000000000000000000;
    else
      n365 <= n339;
endmodule

module opll
  (input  xin,
   output xout,
   input  xena,
   input  [7:0] d,
   input  a,
   input  cs_n,
   input  we_n,
   input  ic_n,
   output [13:0] mixout,
   input  ss_hold,
   input  [7:0] ss_addr,
   input  ss_read,
   input  ss_write,
   input  [31:0] ss_wdata,
   output [31:0] ss_rdata,
   output ss_initialized);
  wire reset;
  wire [7:0] opllptr;
  wire [7:0] oplldat;
  wire opllwr;
  wire am;
  wire pm;
  wire wf;
  wire [6:0] tl;
  wire [2:0] fb;
  wire [3:0] ar;
  wire [3:0] dr;
  wire [3:0] sl;
  wire [3:0] rr;
  wire [3:0] ml;
  wire [8:0] fnum;
  wire [2:0] blk;
  wire [3:0] rks;
  wire key;
  wire rhythm;
  wire noise;
  wire [17:0] pgout;
  wire [12:0] egout;
  wire [13:0] opout;
  wire [3:0] faddr;
  wire [4:0] maddr;
  wire [9:0] fdata;
  wire [9:0] mdata;
  wire [4:0] slot;
  wire [4:0] slot2;
  wire [4:0] slot5;
  wire [4:0] slot8;
  wire [1:0] stage;
  wire [1:0] stage2;
  wire [1:0] stage5;
  wire [1:0] stage8;
  reg [31:0] ss_local_data;
  wire [31:0] ss_s0_data;
  wire ss_s0_ready;
  wire [31:0] ss_s2_data;
  wire ss_s2_ready;
  wire [31:0] ss_s5_data;
  wire ss_s5_ready;
  wire [31:0] ss_s8_data;
  wire ss_s8_ready;
  wire [31:0] ss_ct_data;
  wire ss_ct_ready;
  wire [31:0] ss_eg_data;
  wire ss_eg_ready;
  wire [31:0] ss_pg_data;
  wire ss_pg_ready;
  wire [31:0] ss_op_data;
  wire ss_op_ready;
  wire [31:0] ss_og_data;
  wire ss_og_ready;
  wire [31:0] ss_tm_data;
  wire ss_tm_ready;
  wire n5;
  wire n13;
  wire n14;
  wire [31:0] n15;
  wire n17;
  reg [7:0] n19;
  reg [7:0] n21;
  reg n23;
  wire [16:0] n24;
  wire [16:0] n26;
  wire [31:0] n27;
  wire [7:0] n28;
  wire [7:0] n29;
  wire n30;
  wire n32;
  reg [7:0] n33;
  reg [7:0] n34;
  reg n35;
  wire [7:0] n39;
  wire [7:0] n40;
  wire n41;
  wire n45;
  wire n46;
  wire n47;
  wire [16:0] n52;
  localparam [31:0] n53 = 32'b00000000000000000000000000000000;
  wire [14:0] n54;
  wire [31:0] n55;
  wire n56;
  wire n57;
  wire n58;
  wire n59;
  wire n60;
  wire n61;
  wire n62;
  wire n63;
  wire n64;
  wire n65;
  wire [7:0] n66;
  wire n68;
  wire [7:0] n69;
  wire [7:0] n70;
  wire n72;
  wire n73;
  wire [7:0] n74;
  wire n75;
  wire n76;
  wire n77;
  wire n78;
  wire [4:0] s0_n100;
  wire [1:0] s0_n101;
  wire [31:0] s0_n102;
  wire s0_n103;
  wire [4:0] s2_n112;
  wire [1:0] s2_n113;
  wire [31:0] s2_n114;
  wire s2_n115;
  wire [4:0] s5_n124;
  wire [1:0] s5_n125;
  wire [31:0] s5_n126;
  wire s5_n127;
  wire [4:0] s8_n136;
  wire [1:0] s8_n137;
  wire [31:0] s8_n138;
  wire s8_n139;
  wire ct_n148;
  wire ct_n149;
  wire ct_n150;
  wire [3:0] ct_n151;
  wire [6:0] ct_n152;
  wire [2:0] ct_n153;
  wire [3:0] ct_n154;
  wire [3:0] ct_n155;
  wire [3:0] ct_n156;
  wire [3:0] ct_n157;
  wire [2:0] ct_n158;
  wire [8:0] ct_n159;
  wire [3:0] ct_n160;
  wire ct_n161;
  wire ct_n162;
  wire [31:0] ct_n163;
  wire ct_n164;
  wire [12:0] eg_n199;
  wire [31:0] eg_n200;
  wire eg_n201;
  wire pg_n208;
  wire [17:0] pg_n209;
  wire [31:0] pg_n210;
  wire pg_n211;
  wire [3:0] op_n220;
  wire [13:0] op_n221;
  wire [31:0] op_n222;
  wire op_n223;
  wire n225;
  wire [8:0] n226;
  wire [9:0] og_n234;
  wire [9:0] og_n235;
  wire [31:0] og_n236;
  wire og_n237;
  wire \og.fdata[sign] ;
  wire [8:0] \og.fdata[value] ;
  wire \og.mdata[sign] ;
  wire [8:0] \og.mdata[value] ;
  wire [9:0] n238;
  wire [9:0] n240;
  wire [4:0] tm_n248;
  wire [13:0] tm_n249;
  wire [31:0] tm_n250;
  wire tm_n251;
  wire n253;
  wire [8:0] n254;
  wire [31:0] n262;
  wire [31:0] n263;
  wire [31:0] n264;
  wire [31:0] n265;
  wire [31:0] n266;
  wire [31:0] n267;
  wire [31:0] n268;
  wire [31:0] n269;
  wire [31:0] n270;
  wire [31:0] n271;
  wire n273;
  wire n274;
  wire n275;
  wire n276;
  wire n277;
  wire n278;
  wire n279;
  wire n280;
  wire n281;
  wire n282;
  reg [7:0] n286;
  wire n287;
  wire [7:0] n288;
  reg [7:0] n289;
  reg n290;
  reg [31:0] n291;
  assign xout = xin; //(module output)
  assign mixout = tm_n249; //(module output)
  assign ss_rdata = n271; //(module output)
  assign ss_initialized = n282; //(module output)
  /*# sim_rtl/opll.vhd:277:12 */
  assign reset = n5; // (signal)
  /*# sim_rtl/opll.vhd:279:12 */
  assign opllptr = n286; // (signal)
  /*# sim_rtl/opll.vhd:280:12 */
  assign oplldat = n289; // (signal)
  /*# sim_rtl/opll.vhd:281:12 */
  assign opllwr = n290; // (signal)
  /*# sim_rtl/opll.vhd:283:12 */
  assign am = ct_n148; // (signal)
  /*# sim_rtl/opll.vhd:284:12 */
  assign pm = ct_n149; // (signal)
  /*# sim_rtl/opll.vhd:285:12 */
  assign wf = ct_n150; // (signal)
  /*# sim_rtl/opll.vhd:286:12 */
  assign tl = ct_n152; // (signal)
  /*# sim_rtl/opll.vhd:287:12 */
  assign fb = ct_n153; // (signal)
  /*# sim_rtl/opll.vhd:288:12 */
  assign ar = ct_n154; // (signal)
  /*# sim_rtl/opll.vhd:289:12 */
  assign dr = ct_n155; // (signal)
  /*# sim_rtl/opll.vhd:290:12 */
  assign sl = ct_n156; // (signal)
  /*# sim_rtl/opll.vhd:291:12 */
  assign rr = ct_n157; // (signal)
  /*# sim_rtl/opll.vhd:292:12 */
  assign ml = ct_n151; // (signal)
  /*# sim_rtl/opll.vhd:293:12 */
  assign fnum = ct_n159; // (signal)
  /*# sim_rtl/opll.vhd:294:12 */
  assign blk = ct_n158; // (signal)
  /*# sim_rtl/opll.vhd:295:12 */
  assign rks = ct_n160; // (signal)
  /*# sim_rtl/opll.vhd:296:12 */
  assign key = ct_n161; // (signal)
  /*# sim_rtl/opll.vhd:298:12 */
  assign rhythm = ct_n162; // (signal)
  /*# sim_rtl/opll.vhd:300:12 */
  assign noise = pg_n208; // (signal)
  /*# sim_rtl/opll.vhd:301:12 */
  assign pgout = pg_n209; // (signal)
  /*# sim_rtl/opll.vhd:303:12 */
  assign egout = eg_n199; // (signal)
  /*# sim_rtl/opll.vhd:305:12 */
  assign opout = op_n221; // (signal)
  /*# sim_rtl/opll.vhd:308:12 */
  assign faddr = op_n220; // (signal)
  /*# sim_rtl/opll.vhd:309:12 */
  assign maddr = tm_n248; // (signal)
  /*# sim_rtl/opll.vhd:310:12 */
  assign fdata = og_n234; // (signal)
  /*# sim_rtl/opll.vhd:311:12 */
  assign mdata = og_n235; // (signal)
  /*# sim_rtl/opll.vhd:316:12 */
  assign slot = s0_n100; // (signal)
  /*# sim_rtl/opll.vhd:317:12 */
  assign slot2 = s2_n112; // (signal)
  /*# sim_rtl/opll.vhd:318:12 */
  assign slot5 = s5_n124; // (signal)
  /*# sim_rtl/opll.vhd:319:12 */
  assign slot8 = s8_n136; // (signal)
  /*# sim_rtl/opll.vhd:320:12 */
  assign stage = s0_n101; // (signal)
  /*# sim_rtl/opll.vhd:321:12 */
  assign stage2 = s2_n113; // (signal)
  /*# sim_rtl/opll.vhd:322:12 */
  assign stage5 = s5_n125; // (signal)
  /*# sim_rtl/opll.vhd:323:12 */
  assign stage8 = s8_n137; // (signal)
  /*# sim_rtl/opll.vhd:325:12 */
  always @*
    ss_local_data = n291; // (isignal)
  initial
    ss_local_data = 32'b00000000000000000000000000000000;
  /*# sim_rtl/opll.vhd:326:12 */
  assign ss_s0_data = s0_n102; // (signal)
  /*# sim_rtl/opll.vhd:327:12 */
  assign ss_s0_ready = s0_n103; // (signal)
  /*# sim_rtl/opll.vhd:328:12 */
  assign ss_s2_data = s2_n114; // (signal)
  /*# sim_rtl/opll.vhd:329:12 */
  assign ss_s2_ready = s2_n115; // (signal)
  /*# sim_rtl/opll.vhd:330:12 */
  assign ss_s5_data = s5_n126; // (signal)
  /*# sim_rtl/opll.vhd:331:12 */
  assign ss_s5_ready = s5_n127; // (signal)
  /*# sim_rtl/opll.vhd:332:12 */
  assign ss_s8_data = s8_n138; // (signal)
  /*# sim_rtl/opll.vhd:333:12 */
  assign ss_s8_ready = s8_n139; // (signal)
  /*# sim_rtl/opll.vhd:334:12 */
  assign ss_ct_data = ct_n163; // (signal)
  /*# sim_rtl/opll.vhd:335:12 */
  assign ss_ct_ready = ct_n164; // (signal)
  /*# sim_rtl/opll.vhd:336:12 */
  assign ss_eg_data = eg_n200; // (signal)
  /*# sim_rtl/opll.vhd:337:12 */
  assign ss_eg_ready = eg_n201; // (signal)
  /*# sim_rtl/opll.vhd:338:12 */
  assign ss_pg_data = pg_n210; // (signal)
  /*# sim_rtl/opll.vhd:339:12 */
  assign ss_pg_ready = pg_n211; // (signal)
  /*# sim_rtl/opll.vhd:340:12 */
  assign ss_op_data = op_n222; // (signal)
  /*# sim_rtl/opll.vhd:341:12 */
  assign ss_op_ready = op_n223; // (signal)
  /*# sim_rtl/opll.vhd:342:12 */
  assign ss_og_data = og_n236; // (signal)
  /*# sim_rtl/opll.vhd:343:12 */
  assign ss_og_ready = og_n237; // (signal)
  /*# sim_rtl/opll.vhd:344:12 */
  assign ss_tm_data = tm_n250; // (signal)
  /*# sim_rtl/opll.vhd:345:12 */
  assign ss_tm_ready = tm_n251; // (signal)
  /*# sim_rtl/opll.vhd:350:16 */
  assign n5 = ~ic_n;
  /*# sim_rtl/opll.vhd:369:33 */
  assign n13 = ss_read | ss_write;
  /*# sim_rtl/opll.vhd:369:16 */
  assign n14 = n13 & ss_hold;
  /*# sim_rtl/opll.vhd:375:6 */
  assign n15 = {24'b0, ss_addr};  // uext
  /*# sim_rtl/opll.vhd:376:1 */
  assign n17 = n15 == 32'b00000000000000000000000001001101;
  /*# sim_rtl/opll.vhd:375:1 */
  always @*
    case (n17)
      1'b1: n19 = opllptr;
      default: n19 = 8'b00000000;
    endcase
  /*# sim_rtl/opll.vhd:375:1 */
  always @*
    case (n17)
      1'b1: n21 = oplldat;
      default: n21 = 8'b00000000;
    endcase
  /*# sim_rtl/opll.vhd:375:1 */
  always @*
    case (n17)
      1'b1: n23 = opllwr;
      default: n23 = 1'b0;
    endcase
  /*# sim_rtl/opll.vhd:374:1 */
  assign n24 = {n23, n21, n19};
  /*# sim_rtl/opll.vhd:374:1 */
  assign n26 = ss_read ? n24 : 17'b00000000000000000;
  /*# sim_rtl/opll.vhd:383:6 */
  assign n27 = {24'b0, ss_addr};  // uext
  /*# sim_rtl/opll.vhd:385:37 */
  assign n28 = ss_wdata[7:0]; // extract
  /*# sim_rtl/opll.vhd:387:37 */
  assign n29 = ss_wdata[15:8]; // extract
  /*# sim_rtl/opll.vhd:389:27 */
  assign n30 = ss_wdata[16]; // extract
  /*# sim_rtl/opll.vhd:384:1 */
  assign n32 = n27 == 32'b00000000000000000000000001001101;
  /*# sim_rtl/opll.vhd:383:1 */
  always @*
    case (n32)
      1'b1: n33 = n28;
      default: n33 = opllptr;
    endcase
  /*# sim_rtl/opll.vhd:383:1 */
  always @*
    case (n32)
      1'b1: n34 = n29;
      default: n34 = oplldat;
    endcase
  /*# sim_rtl/opll.vhd:383:1 */
  always @*
    case (n32)
      1'b1: n35 = n30;
      default: n35 = opllwr;
    endcase
  /*# sim_rtl/opll.vhd:369:1 */
  assign n39 = n45 ? n33 : opllptr;
  /*# sim_rtl/opll.vhd:369:1 */
  assign n40 = n46 ? n34 : oplldat;
  /*# sim_rtl/opll.vhd:369:1 */
  assign n41 = n47 ? n35 : opllwr;
  /*# sim_rtl/opll.vhd:369:1 */
  assign n45 = ss_write & n14;
  /*# sim_rtl/opll.vhd:369:1 */
  assign n46 = ss_write & n14;
  /*# sim_rtl/opll.vhd:369:1 */
  assign n47 = ss_write & n14;
  /*# sim_rtl/opll.vhd:369:1 */
  assign n52 = n14 ? n26 : 17'b00000000000000000;
  /*# sim_rtl/opll.vhd:358:10 */
  assign n54 = n53[31:17]; // extract
  /*# sim_rtl/opll.vhd:358:10 */
  assign n55 = {n54, n52};
  /*# sim_rtl/opll.vhd:396:11 */
  assign n56 = ~ss_hold;
  /*# sim_rtl/opll.vhd:399:29 */
  assign n57 = ~cs_n;
  /*# sim_rtl/opll.vhd:399:44 */
  assign n58 = ~we_n;
  /*# sim_rtl/opll.vhd:399:35 */
  assign n59 = n58 & n57;
  /*# sim_rtl/opll.vhd:399:56 */
  assign n60 = ~a;
  /*# sim_rtl/opll.vhd:399:50 */
  assign n61 = n60 & n59;
  /*# sim_rtl/opll.vhd:402:29 */
  assign n62 = ~cs_n;
  /*# sim_rtl/opll.vhd:402:44 */
  assign n63 = ~we_n;
  /*# sim_rtl/opll.vhd:402:35 */
  assign n64 = n63 & n62;
  /*# sim_rtl/opll.vhd:402:50 */
  assign n65 = a & n64;
  /*# sim_rtl/opll.vhd:402:17 */
  assign n66 = n65 ? d : n40;
  /*# sim_rtl/opll.vhd:402:17 */
  assign n68 = n65 ? 1'b1 : n41;
  /*# sim_rtl/opll.vhd:396:1 */
  assign n69 = n76 ? d : n39;
  /*# sim_rtl/opll.vhd:399:17 */
  assign n70 = n61 ? n40 : n66;
  /*# sim_rtl/opll.vhd:399:17 */
  assign n72 = n61 ? 1'b0 : n68;
  /*# sim_rtl/opll.vhd:398:13 */
  assign n73 = n61 & xena;
  /*# sim_rtl/opll.vhd:396:1 */
  assign n74 = n77 ? n70 : n40;
  /*# sim_rtl/opll.vhd:396:1 */
  assign n75 = n78 ? n72 : n41;
  /*# sim_rtl/opll.vhd:396:1 */
  assign n76 = n73 & n56;
  /*# sim_rtl/opll.vhd:396:1 */
  assign n77 = xena & n56;
  /*# sim_rtl/opll.vhd:396:1 */
  assign n78 = xena & n56;
  /*# sim_rtl/opll.vhd:414:5 */
  slotcounter_Brtl_0 s0 (
    .clk(xin),
    .reset(reset),
    .clkena(xena),
    .ss_hold(ss_hold),
    .ss_addr(ss_addr),
    .ss_read(ss_read),
    .ss_write(ss_write),
    .ss_wdata(ss_wdata),
    .slot(s0_n100),
    .stage(s0_n101),
    .ss_rdata(s0_n102),
    .ss_initialized(s0_n103));
  /*# sim_rtl/opll.vhd:427:5 */
  slotcounter_Brtl_2 s2 (
    .clk(xin),
    .reset(reset),
    .clkena(xena),
    .ss_hold(ss_hold),
    .ss_addr(ss_addr),
    .ss_read(ss_read),
    .ss_write(ss_write),
    .ss_wdata(ss_wdata),
    .slot(s2_n112),
    .stage(s2_n113),
    .ss_rdata(s2_n114),
    .ss_initialized(s2_n115));
  /*# sim_rtl/opll.vhd:440:5 */
  slotcounter_Brtl_5 s5 (
    .clk(xin),
    .reset(reset),
    .clkena(xena),
    .ss_hold(ss_hold),
    .ss_addr(ss_addr),
    .ss_read(ss_read),
    .ss_write(ss_write),
    .ss_wdata(ss_wdata),
    .slot(s5_n124),
    .stage(s5_n125),
    .ss_rdata(s5_n126),
    .ss_initialized(s5_n127));
  /*# sim_rtl/opll.vhd:453:5 */
  slotcounter_Brtl_8 s8 (
    .clk(xin),
    .reset(reset),
    .clkena(xena),
    .ss_hold(ss_hold),
    .ss_addr(ss_addr),
    .ss_read(ss_read),
    .ss_write(ss_write),
    .ss_wdata(ss_wdata),
    .slot(s8_n136),
    .stage(s8_n137),
    .ss_rdata(s8_n138),
    .ss_initialized(s8_n139));
  /*# sim_rtl/opll.vhd:467:5 */
  controller_Brtl ct (
    .clk(xin),
    .reset(reset),
    .clkena(xena),
    .slot(slot),
    .stage(stage),
    .wr(opllwr),
    .addr(opllptr),
    .data(oplldat),
    .ss_hold(ss_hold),
    .ss_addr(ss_addr),
    .ss_read(ss_read),
    .ss_write(ss_write),
    .ss_wdata(ss_wdata),
    .am(ct_n148),
    .pm(ct_n149),
    .wf(ct_n150),
    .ml(ct_n151),
    .tl(ct_n152),
    .fb(ct_n153),
    .ar(ct_n154),
    .dr(ct_n155),
    .sl(ct_n156),
    .rr(ct_n157),
    .blk(ct_n158),
    .fnum(ct_n159),
    .rks(ct_n160),
    .key(ct_n161),
    .rhythm(ct_n162),
    .ss_rdata(ct_n163),
    .ss_initialized(ct_n164));
  /*# sim_rtl/opll.vhd:473:5 */
  envelopegenerator_Brtl eg (
    .clk(xin),
    .reset(reset),
    .clkena(xena),
    .slot(slot2),
    .stage(stage2),
    .rhythm(rhythm),
    .am(am),
    .tl(tl),
    .ar(ar),
    .dr(dr),
    .sl(sl),
    .rr(rr),
    .rks(rks),
    .key(key),
    .ss_hold(ss_hold),
    .ss_addr(ss_addr),
    .ss_read(ss_read),
    .ss_write(ss_write),
    .ss_wdata(ss_wdata),
    .egout(eg_n199),
    .ss_rdata(eg_n200),
    .ss_initialized(eg_n201));
  /*# sim_rtl/opll.vhd:481:5 */
  phasegenerator_Brtl pg (
    .clk(xin),
    .reset(reset),
    .clkena(xena),
    .slot(slot2),
    .stage(stage2),
    .rhythm(rhythm),
    .pm(pm),
    .ml(ml),
    .blk(blk),
    .fnum(fnum),
    .key(key),
    .ss_hold(ss_hold),
    .ss_addr(ss_addr),
    .ss_read(ss_read),
    .ss_write(ss_write),
    .ss_wdata(ss_wdata),
    .noise(pg_n208),
    .pgout(pg_n209),
    .ss_rdata(pg_n210),
    .ss_initialized(pg_n211));
  /*# sim_rtl/opll.vhd:490:5 */
  operator_Brtl op (
    .clk(xin),
    .reset(reset),
    .clkena(xena),
    .slot(slot5),
    .stage(stage5),
    .rhythm(rhythm),
    .wf(wf),
    .fb(fb),
    .noise(noise),
    .pgout(pgout),
    .egout(egout),
    .\fdata[sign] (n225),
    .\fdata[value] (n226),
    .ss_hold(ss_hold),
    .ss_addr(ss_addr),
    .ss_read(ss_read),
    .ss_write(ss_write),
    .ss_wdata(ss_wdata),
    .faddr(op_n220),
    .opout(op_n221),
    .ss_rdata(op_n222),
    .ss_initialized(op_n223));
  /*# sim_rtl/opll.vhd:490:5 */
  assign n225 = fdata[0]; // extract
  /*# sim_rtl/opll.vhd:490:5 */
  assign n226 = fdata[9:1]; // extract
  /*# sim_rtl/opll.vhd:500:23 */
  assign og_n234 = n238; // (signal)
  /*# sim_rtl/opll.vhd:500:37 */
  assign og_n235 = n240; // (signal)
  /*# sim_rtl/opll.vhd:498:5 */
  outputgenerator_Brtl og (
    .clk(xin),
    .reset(reset),
    .clkena(xena),
    .slot(slot8),
    .stage(stage8),
    .rhythm(rhythm),
    .opout(opout),
    .faddr(faddr),
    .maddr(maddr),
    .ss_hold(ss_hold),
    .ss_addr(ss_addr),
    .ss_read(ss_read),
    .ss_write(ss_write),
    .ss_wdata(ss_wdata),
    .\fdata[sign] (\og.fdata[sign] ),
    .\fdata[value] (\og.fdata[value] ),
    .\mdata[sign] (\og.mdata[sign] ),
    .\mdata[value] (\og.mdata[value] ),
    .ss_rdata(og_n236),
    .ss_initialized(og_n237));
  /*# sim_rtl/opll.vhd:498:5 */
  assign n238 = {\og.fdata[value] , \og.fdata[sign] };
  /*# sim_rtl/opll.vhd:498:5 */
  assign n240 = {\og.mdata[value] , \og.mdata[sign] };
  /*# sim_rtl/opll.vhd:505:5 */
  temporalmixer_Brtl tm (
    .clk(xin),
    .reset(reset),
    .clkena(xena),
    .slot(slot),
    .stage(stage),
    .rhythm(rhythm),
    .\mdata[sign] (n253),
    .\mdata[value] (n254),
    .ss_hold(ss_hold),
    .ss_addr(ss_addr),
    .ss_read(ss_read),
    .ss_write(ss_write),
    .ss_wdata(ss_wdata),
    .maddr(tm_n248),
    .mixout(tm_n249),
    .ss_rdata(tm_n250),
    .ss_initialized(tm_n251));
  /*# sim_rtl/opll.vhd:505:5 */
  assign n253 = mdata[0]; // extract
  /*# sim_rtl/opll.vhd:505:5 */
  assign n254 = mdata[9:1]; // extract
  /*# sim_rtl/opll.vhd:513:27 */
  assign n262 = ss_local_data | ss_s0_data;
  /*# sim_rtl/opll.vhd:513:41 */
  assign n263 = n262 | ss_s2_data;
  /*# sim_rtl/opll.vhd:513:55 */
  assign n264 = n263 | ss_s5_data;
  /*# sim_rtl/opll.vhd:513:69 */
  assign n265 = n264 | ss_s8_data;
  /*# sim_rtl/opll.vhd:513:83 */
  assign n266 = n265 | ss_ct_data;
  /*# sim_rtl/opll.vhd:513:97 */
  assign n267 = n266 | ss_eg_data;
  /*# sim_rtl/opll.vhd:513:111 */
  assign n268 = n267 | ss_pg_data;
  /*# sim_rtl/opll.vhd:513:125 */
  assign n269 = n268 | ss_op_data;
  /*# sim_rtl/opll.vhd:513:139 */
  assign n270 = n269 | ss_og_data;
  /*# sim_rtl/opll.vhd:513:153 */
  assign n271 = n270 | ss_tm_data;
  /*# sim_rtl/opll.vhd:514:23 */
  assign n273 = 1'b1 & ss_s0_ready;
  /*# sim_rtl/opll.vhd:514:39 */
  assign n274 = n273 & ss_s2_ready;
  /*# sim_rtl/opll.vhd:514:55 */
  assign n275 = n274 & ss_s5_ready;
  /*# sim_rtl/opll.vhd:514:71 */
  assign n276 = n275 & ss_s8_ready;
  /*# sim_rtl/opll.vhd:514:87 */
  assign n277 = n276 & ss_ct_ready;
  /*# sim_rtl/opll.vhd:514:103 */
  assign n278 = n277 & ss_eg_ready;
  /*# sim_rtl/opll.vhd:514:119 */
  assign n279 = n278 & ss_pg_ready;
  /*# sim_rtl/opll.vhd:514:135 */
  assign n280 = n279 & ss_op_ready;
  /*# sim_rtl/opll.vhd:514:151 */
  assign n281 = n280 & ss_og_ready;
  /*# sim_rtl/opll.vhd:514:167 */
  assign n282 = n281 & ss_tm_ready;
  /*# sim_rtl/opll.vhd:366:1 */
  always @(posedge xin or posedge reset)
    if (reset)
      n286 <= 8'b00000000;
    else
      n286 <= n69;
  /*# sim_rtl/opll.vhd:280:12 */
  assign n287 = ~reset;
  /*# sim_rtl/opll.vhd:366:1 */
  assign n288 = n287 ? n74 : oplldat;
  /*# sim_rtl/opll.vhd:366:1 */
  always @(posedge xin)
    n289 <= n288;
  /*# sim_rtl/opll.vhd:366:1 */
  always @(posedge xin or posedge reset)
    if (reset)
      n290 <= 1'b0;
    else
      n290 <= n75;
  /*# sim_rtl/opll.vhd:366:1 */
  always @(posedge xin or posedge reset)
    if (reset)
      n291 <= 32'b00000000000000000000000000000000;
    else
      n291 <= n55;
endmodule

