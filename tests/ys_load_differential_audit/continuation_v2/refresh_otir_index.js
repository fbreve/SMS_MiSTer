// Refresh only cases affected by the earliest-IO-index reporting correction.
const fs=require('fs'),cp=require('child_process'),p=require('path'),assert=require('assert');const d=__dirname,exe='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe';
for(const kind of ['cpu','vdp']){
 const file=kind==='cpu'?'matrix_results.json':'vdp_matrix_results.json',data=JSON.parse(fs.readFileSync(p.join(d,file)));
 for(const mode of [0,1,2,3]){
  const q=data.results.find(x=>x.mode===mode&&x.program===10&&(x.intCase===undefined||x.intCase===0)),log=`${kind}_m${mode}_p10_ioindex.log`;
  const r=cp.spawnSync(exe,['-c','-do',kind==='cpu'?'probe.do':'probe_vdp.do','-l',log],{cwd:d,env:{...process.env,YS_MODE:String(mode),YS_PROGRAM:'10',YS_INTCASE:'0'},encoding:'utf8',timeout:30000});
  const s=fs.readFileSync(p.join(d,log),'utf8'),m=s.match(/RESULT failed=(\d+) arch_first=(-?\d+) bus_first=(-?\d+) IO=(\d+)\/(\d+) IO_first_bad=(-?\d+)/);assert(r.status===0&&m&&!/\*\* (Fatal|Error)/.test(s));assert.equal(q.equal,m[1]==='0');
  q.log=log;q.ioFirstBad=+m[6];
 }
 data.note='Only PROGRAM10 inactive-interrupt cases refreshed after fixing earliest IO mismatch index; verdicts unchanged.';
 fs.writeFileSync(p.join(d,file),JSON.stringify(data,null,2)+'\n');
}
console.log('PASS focused OTIR reporting refresh; all verdicts unchanged.');
