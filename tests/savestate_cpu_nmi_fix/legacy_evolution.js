const fs=require('fs'),p=require('path'),d=p.join(__dirname,'regression');
let s=fs.readFileSync(p.join(d,'cpu_tb.sv'),'utf8').replace('module cpu_tb;','module legacy_cpu_tb;').replace('operation(1);accepted_saved_armed=',"operation(1);mem['h1a][63:40]=24'h48430b;mem[5][63:38]='1;accepted_saved_armed=");
fs.writeFileSync(p.join(d,'legacy_cpu_tb.sv'),s);
fs.writeFileSync(p.join(d,'legacy_cpu.do'),fs.readFileSync(p.join(d,'cpu.do'),'utf8').replaceAll('pending_cpu_work','legacy_cpu_work').replaceAll('cpu_tb','legacy_cpu_tb'));
