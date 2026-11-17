const fs=require('fs'),p=require('path'),d=__dirname;let s=fs.readFileSync(p.join(d,'format_tb.sv'),'utf8');s=s.slice(0,s.indexOf('reg[63:0]oldtag;'));
s+=`reg[6:0]laststate=0;always@(posedge clk)if(dut.state!==laststate)begin $display("TRACE t%0t state%0d fm%0d hasfm%b restart%b bg%b pending%b phase_set%b ready%b",$time,dut.state,dut.fm_snapshot.state,dut.has_fm,dut.has_restart,dut.has_background,dut.dout_expected,phase_set,phase_ready);laststate<=dut.state;end
initial begin
for(integer i=0;i<12288;i++)mem[i]=0;bg_live=0;bg2_live=0;repeat(4)tick;reset_n=1;transfer(1);transfer(0);$display("V17 done");
mem['h1a][63:40]=24'h48430e;mem['h1a][39:38]=3;expect_background=0;transfer(0);$display("PASS V14 probe");$finish;end
initial begin #10000000;$display("TIMEOUT state%0d fm%0d",dut.state,dut.fm_snapshot.state);$fatal;end
endmodule\n`;
fs.writeFileSync(p.join(d,'probe_tb.sv'),s);fs.writeFileSync(p.join(d,'probe.do'),'onerror {quit -code 1}\nonbreak {quit -code 1}\nvlib probe_work\nvlog -work probe_work -sv ../../../rtl/opll_snapshot.sv savestates_sim.sv probe_tb.sv\nvsim -t 1ps probe_work.vdp_tb -g/vdp_tb/dut/TB_FAST=1\nrun -all\nquit -code 0\n');
