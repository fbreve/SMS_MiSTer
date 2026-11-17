const fs=require('fs'),cp=require('child_process'),p=require('path'),assert=require('assert');const d=__dirname,exe='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe',results=[];
for(const mode of [0,1,2])for(const preload of [1,2])for(const program of [0,5,9,10]){
 const log=`preload${preload}_m${mode}_p${program}.log`,r=cp.spawnSync(exe,['-c','-do','probe_preload.do','-l',log],{cwd:d,env:{...process.env,YS_MODE:String(mode),YS_PROGRAM:String(program),YS_PRELOAD:String(preload)},encoding:'utf8',timeout:30000});
 const s=fs.readFileSync(p.join(d,log),'utf8'),m=s.match(/RESULT failed=(\d+) arch_first=(-?\d+) bus_first=(-?\d+)/),v=s.match(/VRAM actual_writes=(\d+)\/(\d+)/);assert(r.status===0&&m&&s.includes('COMPLETE')&&!/\*\* (Fatal|Error)/.test(s),'incomplete '+log);
 results.push({mode,preload,program,log,equal:m[1]==='0',archFirst:+m[2],busFirst:+m[3],VRAM:[+v[1],+v[2]]});fs.writeFileSync(p.join(d,'preload_results.json'),JSON.stringify({results},null,2)+'\n');
}
console.log(JSON.stringify({cases:results.length,unexpected:results.filter(x=>x.equal!==((x.mode!==0)||x.program===0))},null,2));
