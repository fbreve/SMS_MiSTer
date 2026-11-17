const fs=require('fs'),cp=require('child_process'),p=require('path'),assert=require('assert');const d=__dirname,exe='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe',results=[];
for(const mode of [0,1,2,3])for(const program of [0,1,2,3,4,5,9,10]){
 const log=`vdp_m${mode}_p${program}.log`,r=cp.spawnSync(exe,['-c','-do','probe_vdp.do','-l',log],{cwd:d,env:{...process.env,YS_MODE:String(mode),YS_PROGRAM:String(program),YS_INTCASE:'0'},encoding:'utf8',timeout:30000});
 const s=fs.readFileSync(p.join(d,log),'utf8'),m=s.match(/RESULT failed=(\d+) arch_first=(-?\d+) bus_first=(-?\d+) IO=(\d+)\/(\d+) IO_first_bad=(-?\d+)/),v=s.match(/VRAM actual_writes=(\d+)\/(\d+) first=([^\r\n]+)/);
 assert(r.status===0&&m&&v&&s.includes('COMPLETE')&&!/\*\* (Error|Fatal)/.test(s),'incomplete '+log);
 results.push({mode,program,log,equal:m[1]==='0',archFirst:+m[2],busFirst:+m[3],io:[+m[4],+m[5]],vramCounts:[+v[1],+v[2]],vramFirst:v[3]});
 fs.writeFileSync(p.join(d,'vdp_matrix_results.json'),JSON.stringify({results},null,2)+'\n');
}
console.log(JSON.stringify({cases:results.length,summary:[0,1,2,3].map(mode=>({mode,equal:results.filter(x=>x.mode===mode&&x.equal).length,different:results.filter(x=>x.mode===mode&&!x.equal).length}))},null,2));
