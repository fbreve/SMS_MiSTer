// Additional F13 edge-history test. Keep the twelve canonical replay cases
// unchanged; derive an independent module/driver with its own library.
const fs=require('fs'),path=require('path'),d=__dirname;
let s=fs.readFileSync(path.join(d,'history_tb.sv'),'utf8').replace('module history_tb;','module edge_tb;');
s=s.replace('parameter CASE=0;','parameter MODE=0;parameter CASE=MODE?0:8;');
s=s.replace('reg mrst=0,','reg discard_reset=0,discarded_boot=1;always @(posedge clk)if(mapper_set)discarded_boot<=mapper_in[54];reg mrst=0,');
s=s.replace(/(machine loaded_machine\([^;]+?)\.RESET_n\(mrst\)/,'$1.RESET_n(mrst&&!discard_reset)');
s=s.replace(/(machine loaded_machine\([^;]+?)\.bootloader_n\(boot\)/,'$1.bootloader_n(boot&&discarded_boot)');
const at='holdref=1;perturb=1;put(16\'hffff,8\'h07,30);';
s=s.replace(at,`holdref=1;if(MODE)discarded_boot=0;else discard_reset=1;repeat(4)tick;discard_reset=0;repeat(4)tick;perturb=1;put(16'hffff,8'h07,30);`);
const start=s.indexOf(' if(mapper_out!==saved)$fatal');
const end=s.indexOf('initial begin repeat(8000000)');
s=s.slice(0,start)+`
 addr=16'h8123;repeat(3)tick;
 if(mapper_out[62]!==!MODE||mapper_out[23:16]!==(MODE?2:0)||refstate[23:16]!==3||q0!==(MODE?2:0)||q1!==3)$fatal(1,"edge-history reproduction absent");
 $display("EDGE_HISTORY first_load reference%h restored%h ROM%h/%h DATA%h/%h",refstate,mapper_out,adr1,adr0,q1,q0);
 mreq=0;operation(0);addr=16'h8123;repeat(3)tick;
 if(mapper_out!==saved||q0!==3)$fatal(1,"second load should preserve saved bank");
 $display("PASS F13 edge-history MODE%0d first LOAD DATA%h second LOAD DATA03 same snapshot%h",MODE,MODE?8'h02:8'h00,saved);$finish;
end
`+s.slice(end);
fs.writeFileSync(path.join(d,'edge_tb.sv'),s);
let script=fs.readFileSync(path.join(d,'run.do'),'utf8').replaceAll('work','edge_work').replace('vcom -2008','vcom -work edge_work -2008').replace('vlog -sv','vlog -work edge_work -sv').replace('history_tb.sv','edge_tb.sv').replace('edge_work.history_tb -gCASE=$env(F13_CASE)','edge_work.edge_tb -gMODE=$env(F13_EDGE_MODE)');
fs.writeFileSync(path.join(d,'edge.do'),script);
