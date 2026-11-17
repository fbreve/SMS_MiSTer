const fs=require('fs'),path=require('path'),d=__dirname;
let s=fs.readFileSync(path.join(d,'history_tb.sv'),'utf8').replace('module history_tb;','module edge_fixed_tb;').replace('parameter CASE=0,','parameter MODE=0;parameter CASE=MODE?0:8,');
s=s.replace('reg mrst=0,','reg discard_reset=0,discarded_boot=1;always @(posedge clk)if(mapper_set)discarded_boot<=mapper_in[54];reg mrst=0,');
s=s.replace(/(machine loaded_machine\([^;]+?)\.RESET_n\(mrst\)/,'$1.RESET_n(mrst&&!discard_reset)').replace(/(machine loaded_machine\([^;]+?)\.bootloader_n\(boot\)/,'$1.bootloader_n(boot&&discarded_boot)');
s=s.replace("holdref=1;perturb=1;put(16'hffff,8'h07,30);", "holdref=1;if(MODE)discarded_boot=0;else discard_reset=1;repeat(4)tick;discard_reset=0;repeat(4)tick;perturb=1;put(16'hffff,8'h07,30);");
const a=s.indexOf(' same(30);'),b=s.indexOf('initial begin repeat(8000000)');
s=s.slice(0,a)+`
 holdref=0;addr=16'h8123;repeat(3)tick;same(31);
 if(q0!==3)$fatal(1,"first LOAD bank destroyed");
 holdref=1;operation(0);addr=16'h8123;repeat(3)tick;
 if(q0!==3||mapper_out!==saved)$fatal(1,"second LOAD bank destroyed");
 $display("PASS FIXED F13 edge MODE%0d first/second LOAD data03 mapper%h",MODE,mapper_out);$finish;
end
`+s.slice(b);
fs.writeFileSync(path.join(d,'edge_fixed_tb.sv'),s);
let script=fs.readFileSync(path.join(d,'run.do'),'utf8').replaceAll('work','edge_fixed_work').replace('vcom -2008','vcom -work edge_fixed_work -2008').replace('vlog -sv','vlog -work edge_fixed_work -sv').replace('history_tb.sv','edge_fixed_tb.sv').replace('edge_fixed_work.history_tb -gCASE=$env(F13_CASE)','edge_fixed_work.edge_fixed_tb -gMODE=$env(F13_EDGE_MODE)');
fs.writeFileSync(path.join(d,'edge_fixed.do'),script);
