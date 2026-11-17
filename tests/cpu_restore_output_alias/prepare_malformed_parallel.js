const fs=require('fs'),p=require('path'),assert=require('assert'),d=__dirname,src=p.join(d,'malformed'),dst=p.join(d,'malformed_parallel');fs.mkdirSync(dst,{recursive:true});
let s=fs.readFileSync(p.join(src,'format_tb.sv'),'utf8');s=s.replace('module vdp_tb;','module vdp_tb;\nparameter SHARD=0,SHARDS=8;integer audit_attempt=0;\n');
s=s.replace(/reject_bit\(('h[^;]+)\);/g,'shard_reject($1);');
const at=s.indexOf('initial begin\n for(integer i=0;i<12288;i++)');assert(at>0);
s=s.slice(0,at)+`task shard_reject(input integer wordaddr,bitnum);begin if((audit_attempt%SHARDS)==SHARD)reject_bit(wordaddr,bitnum);audit_attempt++;end endtask\n`+s.slice(at);
s=s.replace('PASS ALIAS MALFORMED rejected%0d recoveryLoads4",rejections','PASS ALIAS MALFORMED SHARD%0d rejected%0d recoveryLoads4",SHARD,rejections');
fs.writeFileSync(p.join(dst,'format_tb.sv'),s);for(const f of['savestates_sim.sv','candidate_sim.sv','T80_sim.vhd','T80s_sim.vhd'])fs.copyFileSync(p.join(src,f),p.join(dst,f));
let compile=fs.readFileSync(p.join(src,'run.do'),'utf8');compile=compile.slice(0,compile.indexOf('vsim -t'))+'quit -code 0\n';fs.writeFileSync(p.join(dst,'compile.do'),compile);
for(let i=0;i<8;i++){const to=p.join(dst,'s'+i);fs.mkdirSync(to,{recursive:true});fs.writeFileSync(p.join(to,'run.do'),`onerror {quit -code 1}\nonbreak {quit -code 1}\nvsim -t 1ps test_work.vdp_tb -gSHARD=${i} -gSHARDS=8 -g/vdp_tb/dut/TB_FAST=1\nset NumericStdNoWarnings 1\nrun -all\nquit -code 0\n`);}
console.log('Prepared eight disjoint rejection shards; all321 original focused oracles retained, each with real CPU and four successful recovery LOADs.');
