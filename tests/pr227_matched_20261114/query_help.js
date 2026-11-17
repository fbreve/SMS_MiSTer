const fs=require('fs'),cp=require('child_process'),path=require('path');
if(fs.existsSync('Y:/'))throw Error('Y: occupied');cp.execFileSync('subst.exe',['Y:',__dirname]);
try{const fd=fs.openSync(path.join(__dirname,'timing_help_mapped3.log'),'wx');const r=cp.spawnSync('C:/intelFPGA_lite/17.0/quartus/bin64/quartus_sta.exe',['-t','Y:/timing_help.tcl'],{cwd:'Y:/',stdio:['ignore',fd,fd]});fs.closeSync(fd);console.log(r.status);}finally{cp.execFileSync('subst.exe',['Y:','/D']);}
