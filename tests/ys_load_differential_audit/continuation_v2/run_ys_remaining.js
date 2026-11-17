const fs=require('fs'),cp=require('child_process'),p=require('path'),assert=require('assert');const d=__dirname,roms=JSON.parse(fs.readFileSync(p.join(d,'local_rom_identity.json'))).roms;
const exe='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe';
for(const [name,mode]of [['standard',0],['japan',0],['japan',1]]){
 const rom=roms.find(r=>r.name===name),log=`ys_${name}_${mode===0?'current':'context'}_sram.log`;
 const r=cp.spawnSync(exe,['-c','-do','probe_ys.do','-l',log],{cwd:d,env:{...process.env,YS_MODE:String(mode),YS_ROM:rom.path.replaceAll('\\','/')},encoding:'utf8',timeout:600000});
 const s=fs.readFileSync(p.join(d,log),'utf8');assert(r.status===0&&s.includes('COMPLETE')&&!/\*\* (Fatal|Error)/.test(s),'incomplete '+log);
 console.log(s.match(/YS_ACCEPT[^\r\n]+/)[0]);console.log(s.match(/YS_MEMORY[^\r\n]+/)[0]);console.log(s.match(/RESULT[^\r\n]+/)[0]);
}
