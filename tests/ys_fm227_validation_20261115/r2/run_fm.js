const fs=require('fs'),p=require('path'),cp=require('child_process');const d=p.join(__dirname,'fm_v2'),exe='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe',results=[];
for(const name of ['protocol','guard_protocol','map','nonfm','validator_stream','early_validator','guard_live']){
 const out=fs.openSync(p.join(d,name+'.stdout.log'),'wx'),r=cp.spawnSync(exe,['-c','-wlf',name+'.wlf','-do',name+'.do','-l',name+'.log'],{cwd:d,stdio:['ignore',out,out],windowsHide:true});fs.closeSync(out);
 const s=fs.readFileSync(p.join(d,name+'.log'),'utf8'),ok=r.status===0&&!/\*\* (Fatal|Error|Failure)/.test(s)&&s.includes('PASS ');results.push({name,exit:r.status,status:ok?'PASS':'FAIL',passes:s.match(/PASS[^\r\n]+/g)||[]});
 fs.writeFileSync(p.join(__dirname,'fm_results.json'),JSON.stringify({results},null,2));console.log(name,ok?'PASS':'FAIL');if(!ok){process.exitCode=1;break;}
}
