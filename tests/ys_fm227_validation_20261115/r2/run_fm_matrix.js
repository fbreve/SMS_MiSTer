const fs=require('fs'),p=require('path'),cp=require('child_process');const d=p.join(__dirname,'fm_v2'),exe='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe',results=[];
for(const shift of [0,7,14])for(const mode of [0,1,2,3,4,5,6]){
 const name=`matrix_s${shift}_m${mode}`,out=fs.openSync(p.join(d,name+'.stdout.log'),'wx'),r=cp.spawnSync(exe,['-c','-wlf',name+'.wlf','-do','run.do','-l',name+'.log'],{cwd:d,env:{...process.env,SHIFT:String(shift),MODE:String(mode),FAST:'0'},stdio:['ignore',out,out],windowsHide:true});fs.closeSync(out);
 const s=fs.readFileSync(p.join(d,name+'.log'),'utf8'),ok=r.status===0&&!/\*\* (Fatal|Error|Failure)/.test(s)&&s.includes('PASS fullstate');results.push({shift,mode,exit:r.status,status:ok?'PASS':'FAIL',log:name+'.log',passes:s.match(/PASS[^\r\n]+/g)||[]});fs.writeFileSync(p.join(__dirname,'fm_matrix_results.json'),JSON.stringify({scope:'Native 900000-clock flush, live OPLL, three phase offsets, seven modes, three independent SAVE/LOAD endpoints per case, internal100-word oracle and continuation audio',results},null,2));console.log(name,ok?'PASS':'FAIL');if(!ok){process.exitCode=1;break;}
 if(process.exitCode)break;
}
