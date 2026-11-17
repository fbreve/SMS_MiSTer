module decrypt_path #(parameter MODE=0)(input clk,input[15:0]a,input m1,input[7:0]raw,output[7:0]data,output reg loaded=0);
`include "crypto_functions.svh"
reg[13:0]load_index=0;wire loading=!loaded;wire[12:0]ka;wire[7:0]kd,mc,sega;
wire[7:0]ld=(MODE==2&&load_index<256)?(load_index<128?xor_byte(load_index[6:0]):swap_byte(load_index[6:0])):key_byte(load_index[12:0]);
always@(negedge clk)if($time>0&&!loaded)begin if(load_index==8191)loaded<=1;else load_index<=load_index+1;end
spram #(.init_file("UNUSED"),.widthad_a(13)) keyram(.clock(clk),.wren(loading),.data(ld),.address(loading?load_index[12:0]:ka),.q(kd));
MC8123_rom_decrypt mcpipe(.clk(clk),.m1(m1),.a(a),.d(mc),.prog_d(raw),.key_a(ka),.key_d(kd));
SEGASYS1_DECT2 segapipe(.clk(clk),.mrom_m1(m1),.mrom_ad(a[14:0]),.mrom_dt(sega),.rad(),.rdt(raw),.ROMCL(clk),.ROMAD(25'h48000+load_index),.ROMDT(ld),.ROMEN(loading));
assign data=(MODE==2&&!a[15])?sega:(((MODE&1)&&!a[15])||(MODE==3&&!a[14]))?mc:raw;
endmodule


