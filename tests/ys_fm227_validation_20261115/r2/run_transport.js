const fs=require('fs'),p=require('path'),cp=require('child_process'),assert=require('assert');
const d=__dirname,exe='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe';
const tag=process.argv[2]||'';
let r=cp.spawnSync(exe,['-c','-do','compile_transport.do','-l',tag+'compile_transport_matrix.log'],{cwd:d,encoding:'utf8'});
assert(r.status===0&&!/\*\* Error/.test(r.stdout+r.stderr),'compile failed');
const plans=[];
const add=(candidate,format=0,map=0,eligible=1,context=2)=>plans.push({candidate,format,map,eligible,context});
for(const candidate of [0,1,2,3])for(const map of [0,1,2])add(candidate,0,map);
for(const candidate of [2,3]){add(candidate,1);add(candidate,8);add(candidate,0,0,0);add(candidate,0,1,0);add(candidate,7,0,0);}
for(const candidate of [1,3]){
 for(const context of [0,1,3,4,5])add(candidate,0,0,1,context);
 for(const format of [2,3,4,5,6])add(candidate,format);
}
add(1,7); // A CPU-only reader cannot silently accept a full-SRAM marker.
for(const candidate of [2,3])for(const format of [1,8])for(const map of [1,2])add(candidate,format,map);
const results=[];
for(const q of plans){
 const log=`${tag}t_c${q.candidate}_f${q.format}_m${q.map}_e${q.eligible}_p${q.context}.log`;
 const script=`onerror {quit -code 1}\nvsim -c work.transport_tb -gCANDIDATE=${q.candidate} -gFORMAT_CASE=${q.format} -gMAP_MODE=${q.map} -gELIGIBLE=${q.eligible} -gCLASS=${q.context}\nrun -all\nquit -code 0\n`;
 fs.writeFileSync(p.join(d,'transport_case.do'),script);
 r=cp.spawnSync(exe,['-c','-do','transport_case.do','-l',log],{cwd:d,encoding:'utf8',timeout:45000});
 const s=fs.readFileSync(p.join(d,log),'utf8');assert(r.status===0&&s.includes('PASS TRANSPORT')&&!/\*\* (Fatal|Error)/.test(s),'failed/incomplete '+log);
 results.push({...q,log,result:s.match(/PASS TRANSPORT[^\r\n]+/)[0]});
 fs.writeFileSync(p.join(d,tag+'transport_results.json'),JSON.stringify({scope:'51 ported controller cases; CPU-context fixtures are inert and malformed experimental CPU metadata cases are replaced by FM/SRAM format-validation cases. Not the unmodified old CPU-format test.',results},null,2)+'\n');
}
console.log('PASS',results.length,'controller transport/metadata cases. No graphical-causality claim.');
