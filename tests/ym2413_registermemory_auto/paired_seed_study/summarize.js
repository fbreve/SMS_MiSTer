const fs=require('fs'),p=require('path'),crypto=require('crypto'),assert=require('assert'),cp=require('child_process'),d=__dirname,task=p.dirname(d),repo=p.resolve(task,'../..');
const read=f=>{const b=fs.readFileSync(f);return b.toString(b[0]===255&&b[1]===254?'utf16le':'utf8');},hash=b=>crypto.createHash('sha256').update(b).digest('hex');
const seeds=[1,2,3],results={},metrics=['neededALMs','placedALMs','fittedRegisters','M10K','MLABcells','MLABbits','setupSlack','setupTNS'];
const seed2=p.join(task,'physical_seed2'),m2=JSON.parse(read(p.join(seed2,'inputs.json')));
for(const seed of seeds){
 const dir=p.join(task,'physical_seed'+seed),r=JSON.parse(read(p.join(dir,'results.json'))),m=JSON.parse(read(p.join(dir,'inputs.json'))),ref=m.reference.directory;
 for(const [f,v]of Object.entries(m.builds.candidate.inputs)){
  const b=fs.readFileSync(p.join(dir,'candidate',f));assert.equal(hash(b),v.SHA256);
  let text=b.toString('latin1'),expected=fs.readFileSync(p.join(seed2,'candidate',f)).toString('latin1');
  if(f==='SMS.qsf')text=text.replace('-name SEED '+seed,'-name SEED 2');assert.equal(text,expected,'Cross-seed input '+f);
 }
 const a=r.builds.baseline,b=r.builds.candidate,summary=read(p.join(ref,'candidate/output_files/SMS.fit.summary')),fit=read(p.join(ref,'candidate/output_files/SMS.fit.rpt')),sta=read(p.join(ref,'candidate/output_files/SMS.sta.summary'));
 const num=(s,re)=>{const match=s.match(re);assert(match,String(re));return +match[1].replaceAll(',','');};
 const setup=[...sta.matchAll(/Type\s*:\s*Setup[^\r\n]*\r?\nSlack\s*:\s*([-\d.]+)\r?\nTNS\s*:\s*([-\d.]+)/g)];assert(setup.length);
 const measured={neededALMs:num(summary,/Logic utilization[^:]*:\s*([\d,]+)/),placedALMs:num(fit,/\[A\] ALMs used in final placement[^;]*;\s*([\d,]+)/),fittedRegisters:num(summary,/Total registers\s*:\s*([\d,]+)/),M10K:num(fit,/; M10K blocks\s*;\s*([\d,]+)/),setupSlack:Math.min(...setup.map(x=>+x[1])),setupTNS:setup.reduce((s,x)=>s+(+x[2]),0)};
 for(const [k,v]of Object.entries(measured))assert.equal(v,a[k],'Original native reference '+seed+' '+k);
 for(const [f,h]of Object.entries(a.reportHashes))assert.equal(hash(fs.readFileSync(p.join(ref,'candidate/output_files',f))),h);
 assert.deepEqual(r.expandedSettingDifferences,{onlyBaseline:[],onlyCandidate:[]});assert.deepEqual(r.fitterSettingDifferences,{onlyBaseline:[],onlyCandidate:[]});
 assert.equal(r.memoryImplementation.candidate.registerMemory.length,1);const rm=r.memoryImplementation.candidate,entry=rm.registerMemory[0],at=k=>entry[rm.header.indexOf(k)];
 assert.equal(at('M10K blocks'),'1');assert.equal(at('MLAB cells'),'0');assert.equal(at('Mixed Width RDW Mode'),'Old data');assert.equal(at('Clock Mode'),'Single Clock');
 assert.equal(at('Port B Input Registers'),'yes');assert.equal(at('Port B Output Registers'),'no');assert.equal(at('Implementation Port B Width'),'22');
 const seed2Result=JSON.parse(read(p.join(seed2,'results.json')));assert.deepEqual(rm.registerParameters,seed2Result.memoryImplementation.candidate.registerParameters,'Cross-seed inferred RAM parameters');
 const primitive=read(p.join(dir,'candidate/db/altsyncram_2tp1.tdf'));assert(primitive.includes('MIXED_PORT_FEED_THROUGH_MODE = "old"'));assert(primitive.includes('PORT_B_ADDRESS_CLOCK = "clock0"'));assert(primitive.includes('PORT_B_READ_ENABLE_CLOCK = "clock0"'));
 assert.deepEqual(r.otherMemoryDifferences,{onlyReference:[],onlyCandidate:[]});
 const rbf=p.join(dir,r.preservedRBF.filename);assert.equal(hash(fs.readFileSync(rbf)),r.preservedRBF.SHA256);
 results[seed]={reference:measured,candidate:Object.fromEntries(metrics.map(k=>[k,b[k]])),deltas:Object.fromEntries(metrics.map(k=>[k,b[k]-a[k]])),referenceCritical:a.paths.setup[0],candidateCritical:b.paths.setup[0],candidateTimingPass:b.qualifiedConstrainedTiming,violations:b.violations,registerMemory:Object.fromEntries(rm.header.map((k,i)=>[k,entry[i]])),registerMemoryPaths:r.registerMemoryPaths,interconnect:b.interconnect,warnings:r.warnings,sourceHash:m.sourceHash,rbf:r.preservedRBF};
}
const stats=values=>({mean:values.reduce((a,b)=>a+b,0)/values.length,min:Math.min(...values),max:Math.max(...values)}),statistics={};
for(const k of metrics)statistics[k]={reference:stats(seeds.map(s=>JSON.parse(read(p.join(task,'physical_seed'+s,'results.json'))).builds.baseline[k])),candidate:stats(seeds.map(s=>results[s].candidate[k])),pairedDelta:stats(seeds.map(s=>results[s].deltas[k]))};
for(const [f,h]of Object.entries(JSON.parse(read(p.join(d,'seed2_preservation.json')))))assert.equal(hash(fs.readFileSync(p.join(seed2,f))),h,'Seed 2 changed '+f);
const before=JSON.parse(read(p.join(task,'physical_seed1/preservation_before.json'))),git=(cwd,...args)=>cp.execFileSync('git',['--no-optional-locks',...args],{cwd,stdio:['ignore','pipe','pipe']});
for(const [w,v]of Object.entries(before.worktrees)){assert.equal(git(w,'rev-parse','HEAD').toString().trim(),v.HEAD);assert.equal(hash(git(w,'diff','--binary','HEAD')),v.diff);assert.equal(git(w,'status','--porcelain','--untracked-files=no').toString(),v.status);}
assert.equal(git(repo,'rev-parse','master').toString().trim(),before.master);
const output={baseline:m2.baseline,branch:m2.candidate.branch,version:m2.version,device:m2.device,sourceEquality:'PASS all 221 frozen inputs equal except QSF Seed assignment; source unchanged',referenceVerification:'PASS independently parsed original fitter and timing summaries, native report hashes',preservation:'PASS all original Seed 2 files and all previous worktree HEADs/tracked diffs/status/master unchanged',results,statistics};
fs.writeFileSync(p.join(d,'results.json'),JSON.stringify(output,null,2)+'\n');console.log(JSON.stringify(output,null,2));
