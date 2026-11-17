const fs=require('fs'),p=require('path'),d=__dirname,root=p.resolve(d,'../..'),dst=p.join(d,'legacy');fs.mkdirSync(dst,{recursive:true});
let s=fs.readFileSync(p.join(d,'format/format_tb.sv'),'utf8'),start=s.indexOf('reg[63:0]oldtag;');
s=s.slice(0,start)+`
reg[63:0]image[0:12287];
initial begin
for(integer i=0;i<12288;i++)mem[i]=0;bg_live=0;bg2_live=0;
repeat(4)tick;reset_n=1;transfer(1);transfer(0);
if(audio_phase_in!==1)$fatal(1,"v16 phase1 not restored");
for(integer i=0;i<12288;i++)image[i]=mem[i];
for(integer version=1;version<=15;version++)begin
for(integer i=0;i<12288;i++)mem[i]=image[i];
mem['h1a][63:40]=24'h484300+version;mem['h1a][39:38]=version==1?0:version==2?2:3;
expect_background=version>=15;transfer(0);
if(!guest_writes||audio_phase_in!==0)$fatal(1,"legacy phase leaked version%0d",version);
$display("PASS LEGACY_PHASE version%0d",version);
end
for(integer i=0;i<12288;i++)mem[i]=image[i];
expect_background=0;mem[0][63:32]=32'h3ffe;mem['he][63:56]=0;mem[5][63:20]=0;mem['h32]='1;
transfer(0);if(!guest_writes||audio_phase_in!==0||bg_valid||sprite_valid)$fatal(1,"old64 current mixer phase leaked");
$display("PASS LEGACY_PHASE old64 currentPhase1 restoredPhase0");
expect_background=1;transfer(1);transfer(0);if(audio_phase_in!==1||!bg_valid)$fatal(1,"v16 after old64");
$display("PASS V16 LEGACY 18 loads phase1 v1to15 old64 phase1again");$finish;
end
initial begin #1000000000;$fatal(1,"legacy watchdog");end
endmodule
`;
fs.writeFileSync(p.join(dst,'legacy_tb.sv'),s);fs.writeFileSync(p.join(dst,'savestates_sim.sv'),require('../savestate_g06_g10_fix/controller_adapter')(p.join(root,'rtl/savestates.sv')));
fs.writeFileSync(p.join(dst,'run.do'),`onerror {quit -code 1}
onbreak {quit -code 1}
vlib legacy_work
vlog -work legacy_work -sv -quiet savestates_sim.sv legacy_tb.sv
vsim -c legacy_work.vdp_tb -g/vdp_tb/dut/TB_FAST=1
run -all
quit -code 0
`);
