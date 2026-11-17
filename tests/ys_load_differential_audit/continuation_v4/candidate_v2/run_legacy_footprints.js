const fs=require('fs'),cp=require('child_process'),p=require('path'),assert=require('assert');
const exe='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe',results=[];
for(const candidate of [2,3])for(const format of [1,8])for(const map of [1,2]){
 const log=`legacy_c${candidate}_f${format}_m${map}.log`;
 assert(!fs.existsSync(log),'refusing to overwrite evidence');
 fs.writeFileSync('legacy_case.do',`onerror {quit -code 1}\nvsim -c work.transport_tb -gCANDIDATE=${candidate} -gFORMAT_CASE=${format} -gMAP_MODE=${map}\nrun -all\nquit -code 0\n`);
 const q=cp.spawnSync(exe,['-c','-do','legacy_case.do','-l',log],{cwd:__dirname,encoding:'utf8',timeout:45000}),text=fs.readFileSync(p.join(__dirname,log),'utf8');
 assert(q.status===0&&text.includes('PASS TRANSPORT')&&!/\*\* (Fatal|Error)/.test(text),'failed '+log);
 results.push({candidate,format,map,log,result:text.match(/PASS TRANSPORT[^\r\n]+/)[0]});
 fs.writeFileSync('legacy_footprint_results.json',JSON.stringify({scope:'Legacy16K/32K footprints remain conditional; old64K bypass ignores newer completeness even with active mapper flags',results},null,2)+'\n');
}
console.log('PASS8 additional legacy-footprint cases.');
