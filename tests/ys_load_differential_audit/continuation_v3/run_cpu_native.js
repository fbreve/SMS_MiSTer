const fs=require('fs'),p=require('path'),cp=require('child_process'),assert=require('assert');const d=__dirname,exe='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe';
let tb=fs.readFileSync(p.join(d,'../continuation_v2/cpu_matrix_tb.sv'),'utf8').replace('module cpu_matrix_tb;','module cpu_native_tb;').replaceAll('T80s_historical cpu(',"T80s_context #(.Mode(0),.T2Write(0)) cpu(").replaceAll('T80s_context cpu(',"T80s_context #(.Mode(0),.T2Write(0)) cpu(");
fs.writeFileSync(p.join(d,'cpu_native_tb.sv'),tb);
let r=cp.spawnSync('C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vlog.exe',['-sv','-quiet','cpu_native_tb.sv'],{cwd:d,encoding:'utf8'});assert.equal(r.status,0,r.stdout+r.stderr);
const plans=[];for(const variant of [0,1])for(let program=0;program<12;program++)plans.push({variant,program,intCase:0});for(const program of [0,5,9,10,11])for(const intCase of [1,4,5])plans.push({variant:1,program,intCase});
const results=[];
for(const q of plans){const log=`native_v${q.variant}_p${q.program}_i${q.intCase}.log`,script=`onerror {quit -code 1}\nvsim -c -t 1ps work.cpu_native_tb -gVARIANT=${q.variant} -gPROGRAM=${q.program} -gINTCASE=${q.intCase}\nset NumericStdNoWarnings 1\nset StdArithNoWarnings 1\nrun -all\nquit -code 0\n`;
 fs.writeFileSync(p.join(d,'native_case.do'),script);r=cp.spawnSync(exe,['-c','-do','native_case.do','-l',log],{cwd:d,encoding:'utf8',timeout:30000});const s=fs.readFileSync(p.join(d,log),'utf8'),m=s.match(/RESULT failed=(\d+) arch_first=(-?\d+) bus_first=(-?\d+)/);assert(r.status===0&&m&&!/\*\* (Fatal|Error)/.test(s),'incomplete '+log);const equal=m[1]==='0';assert.equal(equal,q.variant===1||q.program===0,'unexpected '+log);results.push({...q,log,equal,archFirst:+m[2],busFirst:+m[3]});fs.writeFileSync(p.join(d,'cpu_native_results.json'),JSON.stringify({T2Write:0,results},null,2)+'\n');
}
console.log('PASS 39 expected CPU outcomes with production T2Write=0; context candidate 27/27 equal, baseline ordinary equal/11 predecessor failures.');
