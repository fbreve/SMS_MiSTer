const fs=require('fs'),p=require('path'),d=__dirname,adapter=require('../savestate_g06_g10_fix/controller_adapter');
const dst=p.join(d,'shared');fs.mkdirSync(dst,{recursive:true});
let s=fs.readFileSync(p.join(d,'../savestate_f06_sega_sram/prefix.sv'),'utf8');
s=s.slice(0,s.indexOf('reg[63:0]oldtag;'));
s=s.replace('module sram_tb;','module shared_tb; parameter STALL=0;').replace('savestates dut(','savestates #(.TB_FAST(1)) dut(')
 .replace("reg [7:0] nvram_D = '0;","reg [7:0] nvram_D = '0;")
 .replace('assign vram_D=0;','').replace('assign wram_D=0;','').replace('assign replay=0;','assign replay=0;assign restart_out=0;');
s=s.replace('assign vdp_regs=0;assign cram_out=0;assign vram_D=0;assign wram_D=0;','assign vdp_regs=0;assign cram_out=0;');
s=s.replace("wire [7:0] vram_D;","reg [7:0] vram_D=0;").replace("wire [7:0] wram_D;","reg [7:0] wram_D=0;");
s=s.replace('wire [7:0] nvram_D;', 'reg [7:0] nvram_D=0;').replace('wire [63:0] mapper_out;', 'reg [63:0] mapper_out=0;');
s=s.replace('savestates #(.TB_FAST(1)) dut(', 'savestates #(.TB_FAST(1)) dut(');
s=s.replace('integer pending=0;','integer pending=0;');
s=s.replace('always@(negedge clk)phase_ready<=phase_set;',`always@(negedge clk)phase_ready<=phase_set;
reg[15:0]lfsr=16'h1ace;integer cyc=0;
always@(negedge clk)begin cyc++;lfsr={lfsr[14:0],lfsr[15]^lfsr[13]^lfsr[12]^lfsr[10]};DDRAM_BUSY=(DDRAM_RD||DDRAM_WE)&&(STALL==1?cyc%31<13:STALL==2?lfsr[3:0]<12:0);end`)
 .replace('pending<=3;readaddr<=DDRAM_ADDR;','pending<=3+(STALL?lfsr[3:0]:0);readaddr<=DDRAM_ADDR;');
fs.writeFileSync(p.join(dst,'shared_tb.sv'),s+fs.readFileSync(p.join(d,'shared_tail.sv'),'utf8'));
fs.writeFileSync(p.join(dst,'savestates_sim.sv'),adapter('rtl/savestates.sv'));
fs.writeFileSync(p.join(dst,'compile.do'),'onerror {quit -code 1}\nvlib work\nvlog -sv -quiet ../../../rtl/opll_snapshot.sv savestates_sim.sv shared_tb.sv\nquit -code 0\n');
for(const stall of [0,1,2])fs.writeFileSync(p.join(dst,'run'+stall+'.do'),`onerror {quit -code 1}\nonbreak {quit -code 1}\nvsim -c -t 1ps -gSTALL=${stall} work.shared_tb\nrun -all\nquit -code 0\n`);

