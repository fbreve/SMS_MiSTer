const fs=require('fs'),p=require('path'),assert=require('assert'),crypto=require('crypto'),cp=require('child_process'),d=__dirname,root=p.resolve(d,'../..');
const sha=b=>crypto.createHash('sha256').update(b).digest('hex'),baseline=require('./baseline.json'),gate=require('./functional_gate.json'),result=require('./early_results.json'),read=f=>fs.readFileSync(p.join(d,f),'utf8');
assert(gate.passed&&result.sourceHashesVerified&&result.pairedSettings);
const report=read('review.md');for(let n=1;n<=16;n++)assert(new RegExp('^## '+n+'\\. ','m').test(report),'report section '+n);
assert(!/^Pending|pending remaining mode replays/m.test(report),'unfinished report');
const decision=report.match(/\*\*([A-E])\. (?:KEEP|REVERT|NO SAFE)[^\n]+\*\*/);assert(decision,'one final decision');
const keep=decision[1]==='A',changes=[];
for(const x of baseline.tracked){const h=sha(fs.readFileSync(p.join(root,x.file)));if(h!==x.sha256)changes.push(x.file);if(keep&&gate.sourceHashes[x.file])assert.equal(h,gate.sourceHashes[x.file],x.file+' qualified source');}
if(keep){assert(result.snapshotInferred);assert.equal(result.candidate.violations,0);assert(result.candidate.setup>=0&&result.candidate.hold>=0);assert(result.delta.placed<0);assert.deepEqual(changes.sort(),Object.keys(gate.sourceHashes).sort());assert(!result.warningDetails.newMessages.some(x=>x.startsWith('Critical')));}
else {assert.equal(changes.length,0,'rejected production must match baseline');for(const [f,h]of Object.entries(gate.sourceHashes))assert.equal(sha(fs.readFileSync(p.join(d,'candidate',f))),h,'preserved candidate '+f);assert(require('./restore_verification.json').passed);}
assert.equal(cp.execFileSync('git',['rev-parse','HEAD'],{cwd:root,encoding:'utf8'}).trim(),baseline.head);
assert.equal(cp.execFileSync('git',['branch','--show-current'],{cwd:root,encoding:'utf8'}).trim(),baseline.branch);
assert.equal(cp.execFileSync('git',['diff','--cached','--name-only'],{cwd:root,encoding:'utf8'}).trim(),'');
cp.execFileSync('git',['diff','--check'],{cwd:root,stdio:'pipe'});
const out={passed:true,decision:decision[0].replaceAll('**',''),head:baseline.head,branch:baseline.branch,productionChanges:changes,stagedFiles:[],unchangedTracked:baseline.tracked.length-changes.length,qualifiedSourceHashes:gate.sourceHashes,evidenceHashes:Object.fromEntries(['review.md','functional_gate.json','early_results.json','structure_results.json','source_bridge.json','build_early_inputs.json','path_analysis.log','inference_results.json','timing_results.json','restore_verification.json','reproduce.md','experiment.patch'].map(f=>[f,sha(fs.readFileSync(p.join(d,f)))])),noCommitPushPR:true};
fs.writeFileSync(p.join(d,'final_verification.json'),JSON.stringify(out,null,2)+'\n');console.log('PASS final verification: decision, source hashes, report, baseline HEAD, clean index and diff check.');
