const fs=require('fs'),p=require('path'),d=__dirname;
let s=fs.readFileSync(p.join(d,'fixed_tb.sv'),'utf8').replace('module fixed_tb;','module legacy_valid_tb;').replace("mem['h1a][63:40]=24'h484300+FORMAT;mem[5]","mem['h1a][63:40]=24'h484300+FORMAT;mem['h1a][39:38]=FORMAT==1?0:FORMAT==2?2:3;mem[5]");
fs.writeFileSync(p.join(d,'legacy_valid_tb.sv'),s);
fs.writeFileSync(p.join(d,'legacy_valid.do'),fs.readFileSync(p.join(d,'fixed.do'),'utf8').replaceAll('fixed_work','legacy_valid_work').replaceAll('fixed_tb','legacy_valid_tb'));
