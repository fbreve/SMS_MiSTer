const fs=require('fs'),d=__dirname;
const s=fs.readFileSync('SMS.sv','utf8').replace(/\r\n/g,'\n');
let body=s.slice(s.indexOf('wire bk_save_write'),s.indexOf('wire [1:0] gun_mode'));
body=body.replace('"rtl/nvram_ff.mif"','"../../rtl/nvram_ff.mif"');
let sig=s.slice(s.indexOf("reg [31:0] ss_game_id"),s.indexOf('// BIOS mode:'));
const head=`\`timescale 1ns/1ps
module lifecycle_tb;
reg clk_sys=0;always #5 clk_sys=~clk_sys;
reg RESET=0,eject_rom=0,cart_download=0,eeprom_active=0,OSD_STATUS=0;
reg ss_freeze=0,eeprom_ss_set=0,eeprom_full=0,ss_sc_ram_restored=0,ss_busy=0;
reg[127:0]status=0;wire reset_active=RESET|status[0]|cart_download|bk_loading|eject_rom;
reg img_mounted=0,img_readonly=0;reg[63:0]img_size=0;
reg[31:0]sd_lba=0;reg sd_ack=0,sd_rd=0,sd_wr=0;
reg[8:0]sd_buff_addr=0;reg sd_buff_wr=0;reg[7:0]sd_buff_dout=0;wire[7:0]sd_buff_din;
reg[14:0]nvram_a=0;reg[7:0]nvram_d=0;reg nvram_we=0;wire[7:0]nvram_q;
reg ss_cpu_prepare=0,ss_nvram_refill=0,ss_nvram_WE=0;reg[14:0]ss_nvram_A=0,ss_nvram_WA=0;reg[7:0]ss_nvram_WD=0;
reg ioctl_wr=0;reg[24:0]ioctl_addr=0;reg[7:0]ioctl_dout=0;
`;
fs.writeFileSync(d+'/lifecycle_tb.sv',head+sig+body+fs.readFileSync(d+'/lifecycle_tail.sv','utf8'));

