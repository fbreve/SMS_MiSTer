const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto'),assert=require('assert'),d=__dirname,root=p.resolve(d,'../..');
const sha=b=>crypto.createHash('sha256').update(b).digest('hex'),git=args=>cp.execFileSync('git',args,{cwd:root,encoding:'utf8'}).trim();
const baseline=require('./baseline.json'),gate=require('./functional_gate.json'),functional=require('./functional_results.json');
assert.equal(git(['rev-parse','HEAD']),baseline.head);assert.equal(git(['branch','--show-current']),baseline.branch);assert.equal(git(['diff','--name-only']),'');assert.equal(git(['diff','--cached','--name-only']),'');
for(const[f,h]of Object.entries(baseline.hashes))assert.equal(sha(fs.readFileSync(p.join(root,f))),h,'unchanged production '+f);
for(const[f,h]of Object.entries(baseline.reports))assert.equal(sha(fs.readFileSync(p.join(root,f))),h,'unchanged prerequisite '+f);
for(const[f,h]of Object.entries(gate.candidateHashes))assert.equal(sha(fs.readFileSync(p.join(d,'candidate_A',f))),h,'frozen selected source '+f);
for(const e of gate.evidence)assert.equal(sha(fs.readFileSync(p.join(d,e.file))),e.sha256,'pre-build proof '+e.file);
assert(functional.passed);for(const r of functional.results)assert.equal(sha(fs.readFileSync(p.join(d,r.family,r.name,'simulation.log'))),r.logSHA256);
const builds={};for(const name of ['A','confirmation']){const m=require('./build_'+name+'_inputs.json'),result=require('./'+name+'_results.json');assert(result.sourceHashesVerified);
 for(const[f,h]of Object.entries(m.inputs))assert.equal(sha(fs.readFileSync(p.join(d,'quartus_'+name,f))),h,name+' exact built input '+f);
 assert.equal(sha(fs.readFileSync(p.join(d,'quartus_'+name,'build_id.v'))),m.buildIdSHA);
 builds[name]={seed:m.seed,inputCount:Object.keys(m.inputs).length,stages:result.stages,complete:result.candidate.complete,provisional:result.candidate.provisional};
}
const old=require('../savestate_f01_opll_fix/build_final_inputs.json');for(const[f,h]of Object.entries(old.inputs)){assert.equal(sha(fs.readFileSync(p.join(root,f))),h,'F01 production source identity '+f);assert.equal(sha(fs.readFileSync(p.join(d,'../savestate_f01_opll_fix/quartus_final',f))),h,'retained baseline '+f);}
const report=fs.readFileSync(p.join(d,'review.md'),'utf8'),headings=[...report.matchAll(/^## (\d+)\./gm)].map(m=>+m[1]);assert.deepEqual(headings,Array.from({length:58},(_,i)=>i+1));assert(!report.includes('45.129?'));
const artifacts={};for(const f of ['review.md','topology.md','design.md','inventory.json','functional_gate.json','functional_results.json','image_equivalence.json','latency.json','A_results.json','confirmation_results.json','timing_analysis.md','decision.json','pilots.md','README.md','read_retiming/equivalence.md','fm_isolation/isolation/simulation.log'])artifacts[f]=sha(fs.readFileSync(p.join(d,f)));
for(const f of ['build_control.json','physical_diagnostics.json'])artifacts[f]=sha(fs.readFileSync(p.join(d,f)));
for(const f of ['confirmation_path_notes.md','baseline_paths_setup.rpt','baseline_paths_hold.rpt','confirmation_paths_setup.rpt','confirmation_paths_hold.rpt','path_analysis_retry.log','baseline_path_analysis.log','build_A_inputs.json','build_confirmation_inputs.json'])artifacts[f]=sha(fs.readFileSync(p.join(d,f)));
const physicalReports={};for(const [name,folder]of [['baseline',p.join(d,'../savestate_f01_opll_fix/quartus_final')],['A',p.join(d,'quartus_A')],['confirmation',p.join(d,'quartus_confirmation')]]){
 physicalReports[name]={};for(const f of ['output_files/SMS.map.rpt','output_files/SMS.map.summary','output_files/SMS.fit.rpt','output_files/SMS.fit.summary','output_files/SMS.sta.rpt','output_files/SMS.sta.summary','map.log','fit.log','asm.log','sta.log'])if(fs.existsSync(p.join(folder,f)))physicalReports[name][f]=sha(fs.readFileSync(p.join(folder,f)));
}
const generatedTracked=git(['ls-files','--','tests/savestate_g06_sequential_architecture']);assert.equal(generatedTracked,'');
const result={passed:true,head:baseline.head,branch:baseline.branch,productionFilesUnchanged:Object.keys(baseline.hashes).length,F01BaselineInputsVerified:Object.keys(old.inputs).length,selectedCandidateFilesFrozen:Object.keys(gate.candidateHashes).length,preBuildEvidenceUnchanged:gate.evidence.length,nativeCases:functional.nativeCases,builds,format:17,reportSections:58,artifacts,physicalReports,gitDiffStat:git(['diff','--stat']),gitStatusShort:git(['status','--short']),indexEmpty:true,generatedArtifactsTracked:false,noCommitPushOrPRPerformed:true};
fs.writeFileSync(p.join(d,'final_integrity.json'),JSON.stringify(result,null,2)+'\n');console.log({passed:true,productionFilesUnchanged:result.productionFilesUnchanged,reportSections:58,builds});
