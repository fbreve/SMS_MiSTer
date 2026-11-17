// Keep the original collision ROM/oracle. Change only naturally executed Q
// intervals, and assert pairwise-distinct complete live pre-LOAD signatures.
const fs=require('fs'),p=require('path'),d=p.join(__dirname,'distinct_q'),src=p.join(__dirname,'candidate');
fs.mkdirSync(d,{recursive:true});
for(const f of fs.readdirSync(src))if(/\.(sv|svh|vhd|do|hex)$/.test(f)&&fs.statSync(p.join(src,f)).isFile())fs.copyFileSync(p.join(src,f),p.join(d,f));
fs.cpSync(p.join(src,'rtl'),p.join(d,'rtl'),{recursive:true});
fs.copyFileSync(p.resolve(__dirname,'../../rtl/vdp_sprites.vhd'),p.join(d,'rtl/vdp_sprites.vhd'));
let s=fs.readFileSync(p.join(src,'vdp_tb.sv'),'utf8');
s=s.replace('`include "header.svh"', '`include "header.svh"\ninteger q_iteration=-1;');
s=s.replace('for(n=0;n<80+pass*31;n=n+1)tick;', 'q_iteration=pass;for(n=0;n<80+pass*1370;n=n+1)tick;');
s=s.replace('// Legal DMA perturbation of backing memory plus normal running histories.', '// Distinct naturally executed guest histories; no DMA or internal force.');
s=s.replace('module vdp_tb;', 'module vdp_tb;');
s=s.replace('integer last_issue_cycle=0', 'integer last_issue_cycle=0');
s=s.replace(/\nendmodule\s*$/, `
integer q_seen=0;reg[230+136+18+8+(74*SLOTS+42)-1:0]q_states[0:2];
reg[230+136+18+8+(74*SLOTS+42)-1:0]q_live;integer k;
always@(posedge ss_freeze)if(!dut.do_save&&q_iteration>=0)begin
 q_live={z80_reg,vdp_regs,x,y,ram[256],g06_live};
 for(k=0;k<q_seen;k++)if(q_live===q_states[k])$fatal(1,"Q histories converged %0d and %0d",k,q_iteration);
 q_states[q_seen]=q_live;q_seen++;
 $display("DISTINCT_Q accepted%0d x%0d y%0d PC%h CPU%h VDP%h",q_iteration,x,y,ca,z80_reg,vdp_regs);
end
final if(q_seen==3)$display("PASS DISTINCT_Q three pairwise different accepted guest states");
endmodule
`);
fs.writeFileSync(p.join(d,'vdp_tb.sv'),s);
fs.mkdirSync(p.join(d,'dut'),{recursive:true});
fs.copyFileSync(p.join(src,'reference_warm_t1/reference.dat'),p.join(d,'dut/reference.dat'));
fs.copyFileSync(p.join(src,'rom.hex'),p.join(d,'dut/rom.hex'));
fs.writeFileSync(p.join(d,'dut/run.do'),`onerror {quit -code 1}
onbreak {quit -code 1}
vsim -c -t 1ps -L altera_mf vdp_work.vdp_tb -gTURBO=1 -gFIX=1 -gSLOTS=64 -gEXT_REFERENCE=1 -g/vdp_tb/dut/TB_FAST=1 -gWARMUP=1 -gREPLAYS=3 -gPROTO=1 -gGG=1 -gPAL=0 -gREQUEST_X=40 -gSPRITE_X=120 -gSPRITES=2 -g/vdp_tb/vdp1/vdp_vram_inst/init_file=UNUSED
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
`);
console.log('Actual64-slot distinct-Q collision regression prepared');
