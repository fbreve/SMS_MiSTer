const fs=require('fs'),cp=require('child_process'),p=require('path'),assert=require('assert');const d=__dirname,exe='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe',results=[];
for(const [candidate,format]of [[0,0],[1,0],[1,1],[1,2],[1,3],[1,4],[1,5],[1,6]]){
 const log=`protocol_c${candidate}_f${format}.log`,r=cp.spawnSync(exe,['-c','-do','protocol.do','-l',log],{cwd:d,env:{...process.env,YS_CANDIDATE:String(candidate),YS_FORMAT_CASE:String(format)},encoding:'utf8',timeout:60000});
 const s=fs.readFileSync(p.join(d,log),'utf8');assert(r.status===0&&s.includes('PASS CONTROLLER')&&!/\*\* (Fatal|Error)/.test(s),'incomplete '+log);results.push({candidate,format,log,pass:s.match(/PASS CONTROLLER[^\r\n]+/)[0]});fs.writeFileSync(p.join(d,'protocol_results.json'),JSON.stringify({results},null,2)+'\n');
}
console.log(JSON.stringify({cases:results.length,results},null,2));
