const fs=require('fs'),p=require('path'),cp=require('child_process');const d=__dirname,r2=p.join(d,'r2'),steps=[];
function tail(file){if(!fs.existsSync(file))return '';const n=fs.statSync(file).size,b=Buffer.alloc(Math.min(n,8192)),fd=fs.openSync(file,'r');fs.readSync(fd,b,0,b.length,n-b.length);fs.closeSync(fd);return b.toString();}
function record(status,extra={}){fs.writeFileSync(p.join(d,'workflow_status.json'),JSON.stringify({status,steps,...extra},null,2));}
function step(name,args,cwd=d){const start=new Date().toISOString(),out=fs.openSync(p.join(d,'workflow_'+name+'.stdout.log'),'wx');console.log('START',name,start);const r=cp.spawnSync(process.execPath,args,{cwd,stdio:['ignore',out,out],windowsHide:true});fs.closeSync(out);steps.push({name,start,finish:new Date().toISOString(),exit:r.status,log:'workflow_'+name+'.stdout.log'});record(r.status===0?'running':'FAILED',{step:name});if(r.status!==0)throw Error('Workflow step failed: '+name);console.log('DONE',name);}
(async()=>{try{
 record('waiting_for_complete_native_movies');
 while(!tail(p.join(d,'e_baseline_map.log')).includes('COMPLETE movement sequence')||!tail(p.join(r2,'e_sram_map.log')).includes('COMPLETE movement sequence')){
  for(const file of [p.join(d,'e_baseline_map.log'),p.join(r2,'e_sram_map.log')])if(/\*\* (Fatal|Error)/.test(tail(file)))throw Error('Native movie failed: '+file);
  await new Promise(resolve=>setTimeout(resolve,10000));
 }
 step('import_baseline',['import_controls.js','--baseline-only'],r2);
 step('inspect_slots',['inspect_slots.js'],r2);
 step('analyze_movie',['analyze_map_runs.js','e_'],r2);
 step('first_map_column',['analyze_first_map_column.js'],r2);
 step('functional_gate',['finalize_functional.js'],r2);
 step('quartus',['run_builds.js']);
 step('preserve_rbf',['preserve_release.js']);
 step('preservation',['verify_preservation.js','final']);
 record('qualified_artifacts_ready_report_pending');console.log('All qualification stages complete; inspect results and write final technical report. Hardware remains untested.');
}catch(e){record('FAILED',{error:e.message});console.error(e);process.exitCode=1;}})();
