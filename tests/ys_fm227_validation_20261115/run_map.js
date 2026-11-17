const fs=require('fs'),p=require('path'),cp=require('child_process');
const d=__dirname,exe='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe';
const rom=JSON.parse(fs.readFileSync(p.join(d,'rom_owner_results.json'))).results.find(q=>q.name==='standard').path;
const plans=[{name:'e_baseline',candidate:0,reference:0},{name:'e_sram',candidate:2,reference:0},{name:'e_reference',candidate:0,reference:1}];
function record(){fs.writeFileSync(p.join(d,'map_run_status.json'),JSON.stringify({scope:'Production FM baseline and physical-SRAM branch; completion is not graphics PASS before analysis',plans},null,2));}
Promise.all(plans.map(q=>new Promise(resolve=>{
 const stdout=fs.openSync(p.join(d,q.name+'.stdout.log'),'wx'),stderr=fs.openSync(p.join(d,q.name+'.stderr.log'),'wx');
 const proc=cp.spawn(exe,['-c','-do','environment_case.do','-l',q.name+'_map.log'],{cwd:d,env:{...process.env,YS_OUT:q.name,YS_CANDIDATE:String(q.candidate),YS_REFERENCE:String(q.reference),YS_SHAM:'0',YS_ROM:rom,YS_SLOT:'seed_slot.hex',YS_SRAM:'seed_sram.hex'},stdio:['ignore',stdout,stderr],windowsHide:true});
 Object.assign(q,{status:'running',pid:proc.pid,started:new Date().toISOString()});record();
 proc.on('exit',code=>{fs.closeSync(stdout);fs.closeSync(stderr);const log=fs.readFileSync(p.join(d,q.name+'_map.log'),'utf8');Object.assign(q,{exitCode:code,finished:new Date().toISOString(),status:code===0&&log.includes('COMPLETE movement sequence')&&!/\*\* (Fatal|Error)/.test(log)?'completed_pending_analysis':'FAILED'});record();console.log(q.name,q.status);resolve();});
}))).then(()=>{if(plans.some(q=>q.status==='FAILED'))process.exitCode=1;});
