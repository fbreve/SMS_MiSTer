const fs=require('fs'),p=require('path'),assert=require('assert'),d=__dirname;
let s=fs.readFileSync(p.join(d,'candidate_known_tb.sv'),'utf8');
const needle="put(8'h86);put(8'h00);put(8'h90); // audible period-six tone";
assert(s.includes(needle));s=s.replace(needle,"put(8'h86);put(8'h00);put(8'h9f);put(8'hbf);put(8'hdf);put(8'hff); // legal all-channel PSG silence");
fs.writeFileSync(p.join(d,'silent_tb.sv'),s);
fs.writeFileSync(p.join(d,'silent_compile.do'),fs.readFileSync(p.join(d,'candidate_known_compile.do'),'utf8').replaceAll('known_candidate_work','silent_work').replace('candidate_known_tb.sv','silent_tb.sv'));
fs.writeFileSync(p.join(d,'silent_run.do'),fs.readFileSync(p.join(d,'candidate_known_run.do'),'utf8').replaceAll('known_candidate_work','silent_work'));
let ps=fs.readFileSync(p.join(d,'known.ps1'),'utf8').replace('"known_$($Variant)_work"',"'silent_work'").replaceAll('$($Variant)_known_compile','silent_compile').replaceAll('$($Variant)_known_run','silent_run');fs.writeFileSync(p.join(d,'silent.ps1'),ps);
