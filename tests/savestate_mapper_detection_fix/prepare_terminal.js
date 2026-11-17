const fs=require('fs'),path=require('path'),d=__dirname;
let s=fs.readFileSync(path.join(d,'boundary_fixed_tb.sv'),'utf8').replace('module boundary_fixed_tb;','module terminal_fixed_tb;').replace('integer phase=0;','integer phase=0,enable_origin=0;').replace('(cycle+phase)%15','(cycle-enable_origin+phase)%15').replace('bootcycle=cycle;repeat(3)tick;','bootcycle=cycle;enable_origin=cycle;repeat(3)tick;').replace('kind<3','kind<1').replace('start=65515;start<=65535;start=start+5','start=65520;start<=65520;start=start+5');
fs.writeFileSync(path.join(d,'terminal_fixed_tb.sv'),s);
let script=fs.readFileSync(path.join(d,'boundary_fixed.do'),'utf8').replaceAll('boundary_fixed','terminal_fixed');
fs.writeFileSync(path.join(d,'terminal_fixed.do'),script);
