const fs=require('fs'),p=require('path'),d=__dirname;
let s=fs.readFileSync(p.join(d,'fixed_tb.sv'),'utf8').replace('module fixed_tb;','module legacy_debug_tb;');
s=s.replace('initial begin repeat(12000000)tick;', 'always @(posedge clk) if(cycle%100000==0) $display("DEBUG stage%0d state%0d freeze%b replay%b dirs%0d old%b pending%0d expected%b",stage,dut.state,ss_freeze,replay,dirs,dut.is_old_format,pending,dut.dout_expected);\ninitial begin repeat(12000000)tick;');
fs.writeFileSync(p.join(d,'legacy_debug_tb.sv'),s);
fs.writeFileSync(p.join(d,'legacy_debug.do'),fs.readFileSync(p.join(d,'fixed.do'),'utf8').replaceAll('fixed_work','legacy_debug_work').replaceAll('fixed_tb','legacy_debug_tb'));

