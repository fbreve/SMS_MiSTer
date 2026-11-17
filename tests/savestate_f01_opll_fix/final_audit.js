const fs=require('fs'),p=require('path'),crypto=require('crypto'),cp=require('child_process'),assert=require('assert'),d=__dirname,root=p.resolve(d,'../..');
const sha=b=>crypto.createHash('sha256').update(b).digest('hex');
const git=(...args)=>cp.execFileSync('git',args,{cwd:root,encoding:'utf8',maxBuffer:16e6});
const gate=require('./sufficiency_gate.json'),reg=require('./regression_results.json'),build=require('./final_results.json');
assert(reg.passed&&build.sourceHashesVerified&&build.snapshotInferred);assert(build.candidate.setup>0&&build.candidate.hold>0&&build.candidate.violations===0);assert.deepEqual(build.warningDetails.newTypes,[]);
assert.equal(build.classification,'FITS BUT REQUIRES CAUTION');
assert.equal(git('rev-parse','HEAD').trim(),gate.head);assert.equal(git('branch','--show-current').trim(),gate.branch);assert.equal(git('diff','--cached','--name-only').trim(),'');
for(const[f,h]of Object.entries(gate.productionHashes))assert.equal(sha(fs.readFileSync(p.join(root,f))),h,'frozen production '+f);
const tracked=git('diff','--name-only').trim().split(/\r?\n/);assert.deepEqual([...tracked].sort(),[...gate.changedTracked].sort());
const paths=new Set(['review.md','state_map.md','state_map.json','format.md','handoff.json','regression_results.json','sufficiency_gate.json','early_results.json','final_results.json','build_early_inputs.json','build_final_inputs.json','qsf_export_verification.json','pairs.json','pair_a.bin','pair_b.bin','converge_a.bin','converge_b.bin']);
paths.add('oracle_source_identity.json');paths.add('whitespace_review.json');paths.add('README.md');
assert(require('./oracle_source_identity.json').passed);
for(const [name,r] of Object.entries(gate.results)){const f=name.endsWith('.log')?name:name+'/replay.log';assert.equal(sha(fs.readFileSync(p.join(d,f))),r.logSHA);paths.add(f);}
for(const r of reg.randomized){assert.equal(sha(fs.readFileSync(p.join(d,r.log))),r.sha256);assert.equal(sha(fs.readFileSync(p.join(d,'random_'+r.seed+'/reference.dat'))),r.oracleSHA256);paths.add(r.log);paths.add('random_'+r.seed+'/reference.log');paths.add('random_'+r.seed+'/reference.dat');paths.add('random_'+r.seed+'/image_save.hex');}
for(const r of reg.regressions){assert.equal(sha(fs.readFileSync(p.join(d,r.log))),r.logSHA256);paths.add(r.log);}
paths.add('imports/imports.log');
for(const f of fs.readdirSync(d))if(/\.(js|ps1|do|sv|vhd)$/.test(f))paths.add(f);
function sourceTree(dir,relative=''){
 for(const e of fs.readdirSync(dir,{withFileTypes:true})){
  const name=p.posix.join(relative,e.name);
  if(e.isDirectory()){
   if(/^(?:work_.*|.*_work|quartus_.*|settings_raw|db|incremental_db|output_files)$/.test(e.name))continue;
   sourceTree(p.join(dir,e.name),name);
  }else if(/\.(?:js|ps1|do|sv|svh|vhd|v|qsf|qpf|sdc)$/.test(e.name))paths.add(name);
 }
}
sourceTree(d);
for(const name of ['early','final'])for(const stage of ['map','fit','asm','sta'])paths.add('quartus_'+name+'/'+stage+'.log');
const evidence=Object.fromEntries([...paths].sort().map(f=>[f,sha(fs.readFileSync(p.join(d,f)))]));
const passReport=fs.readFileSync(p.join(d,'review.md'),'utf8');assert(passReport.includes('CLOSED - FIXED AND PROVEN')&&passReport.includes('READY TO COMMIT'));assert.equal((passReport.match(/^\*\*\d+\./gm)||[]).length,61);
const result={passed:true,head:gate.head,branch:gate.branch,staged:[],trackedChanges:tracked,newProduction:['rtl/opll_snapshot.sv'],productionHashes:gate.productionHashes,evidence,scope:{F01:'CLOSED - FIXED AND PROVEN',F06:'EXCLUDED',G08FM:'OPEN',format:17,commit:false,push:false,PR:false},resourceClassification:'FITS BUT REQUIRES CAUTION',finalDeltaFromEarly:build.deltaFromEarly};
fs.writeFileSync(p.join(d,'final_audit.json'),JSON.stringify(result,null,2)+'\n');console.log({passed:true,evidenceFiles:paths.size,productionFrozen:true,staged:0});
