const fs=require('fs'),p=require('path'),d=__dirname,src=p.join(d,'format'),dst=p.join(d,'imports');fs.mkdirSync(dst,{recursive:true});
let s=fs.readFileSync(p.join(src,'format_tb.sv'),'utf8');s=s.slice(0,s.indexOf('reg[63:0]oldtag;'));
s+=`reg[63:0]image[0:12287];integer fm_resets=0,fm_writes=0;
always@(posedge clk)begin if(fm_reset)fm_resets++;if(fm_write)fm_writes++;end
task import_one(input integer version);begin
 fm_resets=0;fm_writes=0;transfer(0);
 if(!guest_writes||fm_resets!=1||fm_writes!=28)$fatal(1,"pre-v17 fallback routing version%0d reset%0d writes%0d",version,fm_resets,fm_writes);
 $display("PASS IMPORT version%0d reset_once words28",version);
end endtask
initial begin
for(integer i=0;i<12288;i++)mem[i]=0;bg_live=0;bg2_live=0;
repeat(4)tick;reset_n=1;transfer(1);transfer(0);
for(integer i=0;i<12288;i++)image[i]=mem[i];
for(integer version=1;version<=16;version++)begin
 for(integer i=0;i<12288;i++)mem[i]=image[i];
 mem['h1a][63:40]=24'h484300+version;mem['h1a][39:38]=version==1?0:version==2?2:3;
 mem['h2997]='1;expect_background=version>=15;import_one(version);
 if(audio_phase_in!==(version==16))$fatal(1,"pre-v17 audio compatibility");
end
for(integer i=0;i<12288;i++)mem[i]=image[i];
mem['h1a][63:22]=0;mem['he][63:52]=0;mem[5][63:38]=0;mem['h32]='1;mem['h2997]='1;expect_background=0;import_one(0);
mem[0][63:32]=32'h3ffe;mem[5][63:20]=0;import_one(-1);
expect_background=1;transfer(1);fm_resets=0;fm_writes=0;transfer(0);
if(fm_resets||fm_writes!=104)$fatal(1,"v17 did not select exact path after legacy");
$display("PASS IMPORT ALL loads20 tagged1to16 public96 public64 current_before_after");$finish;
end
initial begin #100000000;$fatal(1,"import watchdog");end
endmodule\n`;
fs.writeFileSync(p.join(dst,'imports_tb.sv'),s);fs.copyFileSync(p.join(src,'savestates_sim.sv'),p.join(dst,'savestates_sim.sv'));
fs.writeFileSync(p.join(dst,'run.do'),'onerror {quit -code 1}\nonbreak {quit -code 1}\nvlib imports_work\nvlog -work imports_work -sv ../../../rtl/opll_snapshot.sv savestates_sim.sv imports_tb.sv\nvsim -t 1ps imports_work.vdp_tb -g/vdp_tb/dut/TB_FAST=1\nrun -all\nquit -code 0\n');
