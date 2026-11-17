const fs=require('fs'),p=require('path'),d=__dirname,dst=p.join(d,'persistence');fs.mkdirSync(dst,{recursive:true});
let s=fs.readFileSync(p.join(d,'current/f06_tb.sv'),'utf8');s=s.slice(0,s.indexOf('integer payload=0'));
s=s.replace('module sram_tb;','module persistence_tb;').replace("reg storage_busy = '0;",'wire storage_busy;');
let sms=fs.readFileSync('SMS.sv','utf8').replace(/\r\n/g,'\n');let body=sms.slice(sms.indexOf('wire bk_save_write'),sms.indexOf('wire [1:0] gun_mode'));
body=body.slice(0,body.indexOf('dpram #('))+body.slice(body.indexOf('always @(posedge clk_sys) begin\n\told_downloading'));
const moved=['wire downloading = cart_download;','reg old_downloading = 0;','reg bk_ena = 0;','reg  bk_loading = 0;','reg  bk_state   = 0;'];for(const v of moved)body=body.replace(v,'');
const vars=`
wire clk_sys=clk;reg cart_download=0,RESET=0,eject_rom=0,OSD_STATUS=0;
reg[127:0]status=0;reg img_mounted=0,img_readonly=0;reg[63:0]img_size=0;
reg[31:0]sd_lba=0;reg sd_ack=0,sd_rd=0,sd_wr=0;reg[8:0]sd_buff_addr=0;reg sd_buff_wr=0;reg[7:0]sd_buff_dout=0;
reg old_downloading=0,bk_ena=0,bk_loading=0,bk_state=0;wire downloading;assign downloading=cart_download;
wire reset_active=RESET|cart_download|bk_loading|eject_rom;
wire eeprom_active=0,eeprom_ss_set=0,ss_sc_ram_restored=0;
wire nvram_we;
assign storage_busy=bk_state|sd_ack|sd_rd|sd_wr;
`;
// Declare test host registers before the instantiated RAM. The production
// persistence FSM/dirty logic below is copied without behavioral edits.
s=s.replace('reg[14:0]host_addr=0;',vars+'reg[14:0]host_addr=0;');
s=s.replace('.address_b(host_addr),.data_b(host_data),.wren_b(host_we)', '.address_b(bk_state?{sd_lba[5:0],sd_buff_addr}:host_addr),.data_b(bk_state?sd_buff_dout:host_data),.wren_b(bk_state?(sd_buff_wr&sd_ack):host_we)');
fs.writeFileSync(p.join(dst,'persistence_tb.sv'),s+'\nassign nvram_we=we;\n'+body+fs.readFileSync(p.join(d,'persistence_tail.sv'),'utf8'));
for(const f of ['savestates_sim.sv','mapper_sim.vhd'])fs.copyFileSync(p.join(d,'current',f),p.join(dst,f));
fs.writeFileSync(p.join(dst,'run.do'),'onerror {quit -code 1}\nvlib work\nvcom -2008 -quiet ../../../rtl/dpram.vhd mapper_sim.vhd ../../../rtl/memory_bus.vhd\nvlog -sv -suppress 2244 -quiet ../../../rtl/opll_snapshot.sv savestates_sim.sv persistence_tb.sv\nvsim -c -t 1ps -L altera_mf work.persistence_tb\nset StdArithNoWarnings 1\nset NumericStdNoWarnings 1\nrun -all\nquit -code 0\n');

