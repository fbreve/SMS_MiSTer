const fs=require('fs'),path=require('path'),d=__dirname;
let s=fs.readFileSync(path.join(d,'cpu_tb.sv'),'utf8');
s=s.replace('integer accepts=0,',`always @(posedge clk)if(launch)begin $display("LAUNCH_TIMING cycle%0d frozen=%b A=%h stage=%0d",cycle,ss_freeze,addr,stage);if(ss_freeze||addr!==16'h0020)$fatal(1,"Launch committed before target fetch");end\ninteger accepts=0,`);
fs.writeFileSync(path.join(d,'cpu_timing_tb.sv'),s);
fs.writeFileSync(path.join(d,'cpu_timing.do'),fs.readFileSync(path.join(d,'cpu.do'),'utf8').replaceAll('pending_cpu_work','timing_cpu_work').replace('cpu_tb.sv','cpu_timing_tb.sv'));
