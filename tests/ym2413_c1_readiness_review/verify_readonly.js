// Read historical files only; write new audit evidence exclusively beside this script.
const fs=require('fs'),p=require('path'),crypto=require('crypto'),vm=require('vm'),cp=require('child_process'),assert=require('assert');
const root=p.resolve(__dirname,'../..'),study=p.join(root,'tests/ym2413_b1_c1_seed_study');
const read=f=>fs.readFileSync(f,'utf8'),json=f=>JSON.parse(read(f)),hash=b=>crypto.createHash('sha256').update(b).digest('hex'),sha=f=>hash(fs.readFileSync(f));
const evidence={builds:[],settingDifferences:{},sourceAudit:[],checkedFiles:{}};
function check(f,expected){const actual=sha(f);if(expected)assert.equal(actual,expected,f);evidence.checkedFiles[p.relative(root,f).replace(/\\/g,'/')]=actual;return actual;}
const rows=s=>s.split(/\r?\n/).filter(x=>x.startsWith(';')).map(x=>x.split(';').slice(1,-1).map(x=>x.trim()));
function table(s,title){return rows(s.slice(s.indexOf('; '+title+' ')).split(/\r?\n\s*\r?\n/)[0]);}
const workflow=read(p.join(study,'workflow.log'));check(p.join(study,'workflow.log'));
const recorded=json(p.join(study,'study_results.json'));assert(recorded.allComplete);
const reference=p.join(root,'tests/ym2413_v19_fullstate/physical_seed1');
const refInputs=json(p.join(reference,'inputs.json'));
for(const [tool,h]of Object.entries(refInputs.toolHashes))check(`C:/intelFPGA_lite/17.0/quartus/bin64/${tool}.exe`,h);
let firstSettings;
const settingsNorm=s=>s.replace(/W:[\\/](?:b1|c1)/gi,'<BUILD>').split(/\r?\n/).filter(x=>!/^GLOBAL \{\{\} SEED /.test(x)).sort();
for(const seed of [1,2,3]){
 const seedRoot=p.join(study,'seed'+seed),manifest=json(p.join(seedRoot,'inputs.json'));
 check(p.join(seedRoot,'inputs.json'));assert.equal(manifest.seed,seed);assert.equal(manifest.device,'5CSEBA6U23I7');assert(manifest.version.includes('17.0.2 Build 602'));
 const refSeed=p.join(root,'tests/ym2413_v19_fullstate/physical_seed'+seed);
 check(p.join(refSeed,'results.json'),manifest.reusedBaselineResultsSHA256);
 for(const variant of ['b1','c1']){
  const dir=p.join(seedRoot,variant),out=p.join(dir,'output_files'),r=recorded.seeds.find(s=>s.seed===seed)[variant];
  assert(fs.existsSync(p.join(dir,'build.done')));assert(!fs.existsSync(p.join(dir,'build.failed')));check(p.join(dir,'build.done'));
  for(const [f,i]of Object.entries(manifest.builds[variant].inputs)){
   check(p.join(dir,f),i.SHA256);
   if(!manifest.changedFiles.includes(f)){
    let original=fs.readFileSync(p.join(reference,'candidate',f));
    if(f==='SMS.qsf')original=Buffer.from(original.toString().replace('set_global_assignment -name SEED 1','set_global_assignment -name SEED '+seed));
    assert(fs.readFileSync(p.join(dir,f)).equals(original),'Unexpected substitution '+f);
   }else{
    const wt=p.join(root,'tests',variant==='b1'?'ym2413_optimized_integration':'ym2413_c1_mixer_omission','worktree',f);
    check(wt,i.SHA256);
   }
  }
  for(const stage of ['map','fit','asm','sta','queries']){
   const marker=p.join(dir,stage+'.done');check(marker);
   const saved=json(marker);assert(saved.completed&&Object.keys(saved.hashes).length);
   for(const [f,h]of Object.entries(saved.hashes))check(p.join(dir,f),h);
   assert(workflow.includes(`END seed=${seed} variant=${variant} stage=${stage} exit=0 `),'Missing successful stage workflow');
   if(stage!=='queries')assert(/Info: Quartus Prime [^\r\n]* was successful\. 0 errors/.test(read(p.join(out,'SMS.'+stage+'.rpt'))),'Missing successful tool report');
  }
  for(const [f,h]of Object.entries(r.reportHashes))check(p.join(out,f),h);
  for(const [f,h]of Object.entries(r.physicalReportHashes))check(p.join(dir,f),h);
  const rbf=p.join(out,'SMS.rbf');check(rbf,r.rbfSHA256);assert(fs.statSync(rbf).size>0);
  const fit=read(p.join(out,'SMS.fit.rpt')),map=read(p.join(out,'SMS.map.rpt')),summary=read(p.join(out,'SMS.fit.summary'));
  assert(summary.includes('17.0.2 Build 602')&&summary.includes('Device : 5CSEBA6U23I7'));
  assert(new RegExp('Fitter Initial Placement Seed\\s*;\\s*'+seed+'\\s*;').test(fit));
  for(const f of Object.keys(manifest.builds[variant].inputs).filter(f=>/\.(qsf|sdc)$/.test(f)))check(p.join(dir,f));
  const actualSettings=settingsNorm(read(p.join(dir,'expanded_settings.txt')));
  if(!firstSettings)firstSettings=actualSettings;
  evidence.settingDifferences[`seed${seed}/${variant}`]={added:actualSettings.filter(x=>!firstSettings.includes(x)),removed:firstSettings.filter(x=>!actualSettings.includes(x))};
  assert.deepEqual(actualSettings,firstSettings,'Expanded settings differ beyond seed/build path');
  const n=re=>{const m=fit.match(re);assert(m,re);return +m[1].replaceAll(',','');};
  const registers={mapped:r.mappedRegisters,fitted:r.fittedRegisters,design:n(/;\s*-- Design implementation registers\s*;\s*([\d,]+)/),routing:n(/;\s*-- Routing optimization registers\s*;\s*([\d,]+)/),io:n(/;\s*I\/O registers\s*;\s*([\d,]+)/)};
  assert.equal(registers.fitted,registers.design+registers.routing+registers.io);
  const optimizationCounts={};for(const row of table(fit,'Fitter Netlist Optimizations').slice(2)){if(row.length<4)continue;const k=row.slice(1,4).join(' / ');optimizationCounts[k]=(optimizationCounts[k]||0)+1;}
  assert.equal(optimizationCounts['Duplicated / Router Logic Cell Insertion and Logic Duplication / Routability optimization'],registers.routing);
  const ram=table(fit,'Fitter RAM Summary'),header=ram.find(x=>x.includes('MLAB cells')&&x.includes('M10K blocks'));assert(header);
  const ml=header.indexOf('MLAB cells'),m10=header.indexOf('M10K blocks');
  const ramEntries=ram.filter(x=>/^\d+$/.test(x[ml])&&/^\d+$/.test(x[m10]));
  const outputRam=ramEntries.filter(x=>/OutputMemory:Mmem/.test(x[0]));
  assert.equal(outputRam.reduce((s,x)=>s+ +x[ml],0),20);assert.equal(outputRam.reduce((s,x)=>s+ +x[m10],0),0);
  assert(!ramEntries.some(x=>/RegisterMemory|FeedbackMemory/.test(x[0])));
  const logicEvidence=map.split(/\r?\n/).filter(x=>/Info \(276006\)/.test(x)&&/RegisterMemory|FeedbackMemory/.test(x));assert.equal(logicEvidence.length,2);assert(logicEvidence.every(x=>x.includes('"logic" being set as ramstyle')));
  const entityRows=table(fit,'Fitter Resource Utilization by Entity').filter(x=>x.some(z=>z==='RegisterMemory'||z==='FeedbackMemory'||z==='OutputMemory'));
  const ignored=read(p.join(dir,'physical_ignored_sdc.rpt'));assert(ignored.includes('No constraints were ignored.'));
  const unconstrained=table(read(p.join(dir,'physical_unconstrained.rpt')),'Unconstrained Paths Summary');
  const timing=[...read(p.join(out,'SMS.sta.summary')).matchAll(/Type\s*:\s*([^\r\n]+)\r?\nSlack\s*:\s*(-?[\d.]+)\r?\nTNS\s*:\s*(-?[\d.]+)/g)].map(x=>({type:x[1],slack:+x[2],tns:+x[3]}));
  assert.deepEqual(timing,r.timing);
  evidence.builds.push({seed,variant,rbf:{path:rbf,SHA256:sha(rbf),bytes:fs.statSync(rbf).size},registers,optimizationCounts,optimizationMessages:fit.split(/\r?\n/).filter(x=>/Created \d+ register duplicates|retiming complete/.test(x)),outputRam,logicEvidence,entityRows,unconstrained,timing,setupSlack:r.setupSlack,holdSlack:r.holdSlack,setupTNS:r.setupTNS,holdTNS:r.holdTNS});
 }
}
// Recompute the original collector entirely in memory: intercept its only writes.
const generated={},readonlyFs=Object.create(fs);
readonlyFs.writeFileSync=(f,data)=>{assert(['study_results.json','study_results.md'].includes(p.basename(f)));generated[p.basename(f)]=data;};
vm.runInNewContext(read(p.join(study,'collect_study.js')),{require:n=>n==='fs'?readonlyFs:require(n),__dirname:study,console:{log:()=>{}}});
assert.equal(generated['study_results.md'],read(p.join(study,'study_results.md')),'Markdown differs from regenerated report');
assert.deepEqual(JSON.parse(generated['study_results.json']),recorded,'JSON differs from regenerated report');
evidence.resultTableAccurate=true;
for(const f of ['study_results.json','study_results.md','unattended.done','paired_seed1_verified.txt'])check(p.join(study,f));
const files=JSON.parse(read(p.join(study,'seed1/inputs.json'))).changedFiles;
const originalHashes={},finalHashes={};
for(const f of files){
 const current=p.join(root,'tests/ym2413_c1_mixer_omission/worktree',f),b=fs.readFileSync(current);originalHashes[f]=sha(current);
 const backup=p.join(__dirname,'original_sources',f);fs.mkdirSync(p.dirname(backup),{recursive:true});fs.writeFileSync(backup,b,{flag:'wx'});
 const b1=fs.readFileSync(p.join(root,'tests/ym2413_optimized_integration/worktree',f));
 const baseline=cp.execFileSync('git',['--no-optional-locks','show','9873761503510e4b2c7e06600bf5515344235c2f:'+f],{cwd:root,maxBuffer:1e7});
 const encoding=f==='rtl/VM2413/outputgenerator.vhd'?'shift_jis':'utf-8';
 const decoder=new TextDecoder(encoding,{fatal:true}),text=decoder.decode(b),lines=text.split(/\r?\n/),nonAscii=[];
 lines.forEach((line,i)=>{if(/[^\x00-\x7f]/.test(line))nonAscii.push({line:i+1,text:line,baselineSameComment:baseline.includes(b.toString('latin1').split(/\r?\n/)[i])});});
 // Compare raw bytes of each non-ASCII line; do not transcode legacy source.
 const rawLines=b.toString('latin1').split(/\r?\n/),baseLines=baseline.toString('latin1').split(/\r?\n/),b1Lines=b1.toString('latin1').split(/\r?\n/);
 for(const item of nonAscii){item.identicalRawLineInBaseline=baseLines.includes(rawLines[item.line-1]);item.identicalRawLineInB1=b1Lines.includes(rawLines[item.line-1]);delete item.baselineSameComment;assert(item.identicalRawLineInBaseline&&item.identicalRawLineInB1);}
 assert(!/[\u00c3\u00c2\u0192\ufffd]/.test(text),'Suspicious encoded sequence in C1');
 finalHashes[f]=sha(current);assert.equal(finalHashes[f],originalHashes[f]);
 evidence.sourceAudit.push({path:f,encoding,SHA256:sha(current),CRLF:(b.toString('latin1').match(/\r\n/g)||[]).length,bareLF:(b.toString('latin1').match(/(?<!\r)\n/g)||[]).length,nonAscii,changedLines:[],byteIdenticalBeforeAfter:true,executableTokensUnchanged:true});
}
evidence.outOfScopeMojibake={path:'rtl/savestates.sv',SHA256:check(p.join(root,'rtl/savestates.sv')),lines:read(p.join(root,'rtl/savestates.sv')).split(/\r?\n/).flatMap((text,i)=>/[\u00c3\u0192]/.test(text)?[{line:i+1,text}]:[]),modified:false};
fs.writeFileSync(p.join(__dirname,'source_hashes_before.json'),JSON.stringify(originalHashes,null,2)+'\n',{flag:'wx'});
fs.writeFileSync(p.join(__dirname,'source_hashes_after.json'),JSON.stringify(finalHashes,null,2)+'\n',{flag:'wx'});
// Ensure all files whose integrity was checked remained unchanged throughout this audit.
for(const [relative,h]of Object.entries(evidence.checkedFiles)){const full=p.isAbsolute(relative)?relative:p.join(root,relative);assert.equal(sha(full),h,'Audit changed protected evidence '+relative);}
fs.writeFileSync(p.join(__dirname,'integrity_evidence.json'),JSON.stringify(evidence,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({resultTableAccurate:evidence.resultTableAccurate,builds:evidence.builds.map(b=>({seed:b.seed,variant:b.variant,registers:b.registers,setup:b.setupSlack,hold:b.holdSlack})),C1seed1:evidence.builds.find(b=>b.seed===1&&b.variant==='c1').rbf,changedSourceLines:0,outOfScopeMojibakeLines:evidence.outOfScopeMojibake.lines.length},null,2));
