const fs=require('fs'),cp=require('child_process'),p=require('path'),assert=require('assert');
const d=__dirname,exe='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe';
const plans=[];
for(const mode of [0,1,2,3])for(let program=0;program<12;program++)plans.push({mode,program,intCase:0});
for(const mode of [1,2])for(const program of [0,5,9,10,11])for(const intCase of [1,2,3,4,5])plans.push({mode,program,intCase});
const results=[];
for(const q of plans){const name=`m${q.mode}_p${q.program}_i${q.intCase}`,log=name+'.log';
 const r=cp.spawnSync(exe,['-c','-do','probe.do','-l',log],{cwd:d,env:{...process.env,YS_MODE:String(q.mode),YS_PROGRAM:String(q.program),YS_INTCASE:String(q.intCase)},encoding:'utf8',timeout:30000});
 const s=fs.existsSync(p.join(d,log))?fs.readFileSync(p.join(d,log),'utf8'):r.stdout;
 const v=s.match(/RESULT failed=(\d+) arch_first=(-?\d+) bus_first=(-?\d+) IO=(\d+)\/(\d+) IO_first_bad=(-?\d+) handlerINT=(\d+)\/(\d+) handlerNMI=(\d+)\/(\d+) checks=(\d+)/);
 assert(r.status===0&&v&&s.includes('COMPLETE')&&!/\*\* (Fatal|Error)/.test(s),'incomplete simulation '+name);
 results.push({...q,log,equal:v[1]==='0',archFirst:+v[2],busFirst:+v[3],io:[+v[4],+v[5]],ioFirstBad:+v[6],intHandlers:[+v[7],+v[8]],nmiHandlers:[+v[9],+v[10]],checks:+v[11],capture:s.match(/CAPTURE[^\r\n]+/)[0],first:s.match(/FIRST[^\r\n]+/)?.[0]??null});
 fs.writeFileSync(p.join(d,'matrix_results.json'),JSON.stringify({results},null,2)+'\n');
}
console.log(JSON.stringify({cases:results.length,byMode:[0,1,2,3].map(mode=>({mode,equal:results.filter(x=>x.mode===mode&&x.equal).length,different:results.filter(x=>x.mode===mode&&!x.equal).length})),unexpectedContextFailures:results.filter(x=>x.mode===1&&x.intCase===0&&!x.equal),historicalFailures:results.filter(x=>x.mode===2&&!x.equal)},null,2));
