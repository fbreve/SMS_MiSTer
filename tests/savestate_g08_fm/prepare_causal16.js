const fs=require('fs'),p=require('path'),assert=require('assert'),d=__dirname;
let s=fs.readFileSync(p.join(d,'causal_run.do'),'utf8');
const old='force -deposit /fm_tb/mix/audio_l 2#$lv\n force -deposit /fm_tb/mix/audio_r 2#$rv';assert(s.includes(old));
s=s.replace(old,'if {[examine -radix binary /fm_tb/audio_phase_in] == 0} {force -deposit /fm_tb/mix/audio_r 2#$rv} else {force -deposit /fm_tb/mix/audio_l 2#$lv}').replace('CAUSAL_CACHE_DEPOSIT','CAUSAL_SINGLE_CACHE_DEPOSIT');
fs.writeFileSync(p.join(d,'causal16_run.do'),s);fs.mkdirSync(p.join(d,'causal16'),{recursive:true});
for(const f of ['reference.dat','rom.hex'])fs.copyFileSync(p.join(d,'causal',f),p.join(d,'causal16',f));
let ps=fs.readFileSync(p.join(d,'causal.ps1'),'utf8');ps=ps.replace('Push-Location causal','Push-Location causal16').replace('do ../causal_run.do','do ../causal16_run.do');
// No source recompile is necessary; reuse the frozen causal-only library.
ps=ps.replace(/ & "\$bin\/vsim.exe" -c -do 'do causal_compile.do'[^\n]+\n if\([^\n]+\n/,'');
fs.writeFileSync(p.join(d,'causal16.ps1'),ps);
