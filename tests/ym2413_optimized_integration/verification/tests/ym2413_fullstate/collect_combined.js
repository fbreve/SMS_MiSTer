const fs=require('fs'),p=require('path'),crypto=require('crypto'),assert=require('assert'),cp=require('child_process');
const d=__dirname,root=p.resolve(d,'../..'),hash=b=>crypto.createHash('sha256').update(b).digest('hex');
const partial=process.argv.includes('--partial');
const bytes=f=>fs.readFileSync(p.join(d,f)),read=f=>{const b=bytes(f);return b.toString(b[0]===255&&b[1]===254?'utf16le':'utf8').replace(/^\uFEFF/,'');};
const exit=f=>{const s=read(f).trim();assert(/^-?\d+$/.test(s),'Missing explicit exit status '+f);return +s;};
const normal=s=>s.replace(/\r\n/g,'\n'),signed=n=>n>=8192?n-16384:n,clamp=n=>((Math.max(-4096,Math.min(4095,signed(n)))+8192)%8192);
cp.execFileSync('node',[p.join(d,'verify_combined_scope.js')],{cwd:root,stdio:'inherit'});
const manifest=JSON.parse(read('campaign_source_manifest.json'));
for(const [f,h]of Object.entries(manifest.sources))assert.equal(hash(bytes(f)),h,'Campaign source/library changed '+f);
const reproduction=JSON.parse(read('reproduction_results.json'));assert.equal(reproduction.status,'PASS');assert(reproduction.benchByteIdentical);assert.equal(reproduction.files.length,38);for(const f of reproduction.files){assert(f.statementsIdentical);assert.equal(f.campaignSHA256,hash(bytes(f.file)));assert.equal(f.regeneratedSHA256,hash(bytes('fresh_reproduction/'+f.file)));}
assert.equal(hash(fs.readFileSync(p.resolve(d,'../../../tools/ghdl6/bin/ghdl.exe'))),manifest.ghdlExecutableSHA256);
const layout=JSON.parse(read('binary_layout.json')),header=Buffer.from(layout.headerHex,'hex');assert.equal(layout.recordBytes,48);
const pilotA=normal(read('pilot_binary71/trace.csv')),pilotB=normal(read('models_calibration/combined_audio_71.csv'));assert.equal(pilotA,pilotB);
const pilotBin=bytes('pilot_binary71/trace.bin'),pilotRows=pilotA.trim().split('\n').map(s=>s.split(',').map(Number));
assert(pilotBin.subarray(0,header.length).equals(header));assert.equal(pilotBin.length,header.length+48*pilotRows.length);
pilotRows.forEach((row,n)=>row.forEach((v,i)=>assert.equal(pilotBin.readInt32LE(header.length+n*48+i*4),v)));
assert.equal(exit('models_calibration/phase71.exitcode'),0);assert(read('models_calibration/phase71.log').includes('PASS COMBINED TCL ORACLE ALL 28 checkpoints'));
const baseline=[];
for(const [name,pattern]of Object.entries({compile:/do compile\.do/,phase_compile:/do phase_compile\.do/,map:/PASS independent pattern ALL/,protocol:/PASS protocol ALL/,nonfm:/PASS nonFM ALL/,phases:/PASS PHASE SWEEP ALL 72 offsets/,run:/PASS fullstate/})){
 const log='baseline_regression/'+name;assert.equal(exit(log+'.exitcode'),0);const s=read(log+'.log');assert(pattern.test(s));assert(!/\*\* (Fatal|Error|Failure):/.test(s));baseline.push({name,logSHA256:hash(bytes(log+'.log'))});
}
const candidateRegressions=[];
for(const [name,pattern]of [['protocol','PASS protocol ALL'],['nonfm','PASS nonFM ALL']]){
 if(partial&&!fs.existsSync(p.join(d,'candidate_regressions/'+name+'.exitcode')))continue;
 const q='candidate_regressions/'+name;assert.equal(exit(q+'.exitcode'),0);const s=read(q+'.log');assert(s.includes(pattern));assert(!/\*\* (Fatal|Error|Failure):/.test(s));candidateRegressions.push({name,logSHA256:hash(bytes(q+'.log'))});
}
const active=new Set(),started=new Set();let peak=0,ended=0;
for(const line of read('combined_runs/workflow.log').split(/\r?\n/)){
 let m=line.match(/^START shift=(\d+)/);if(m){const n=+m[1];assert(!started.has(n));started.add(n);active.add(n);peak=Math.max(peak,active.size);assert(peak<=4);continue;}
 m=line.match(/^END shift=(\d+) exit=(-?\d+)/);if(m){assert.equal(+m[2],0);assert(active.delete(+m[1]));ended++;}
}
if(!partial){assert.equal(started.size,72);assert.equal(ended,72);assert.equal(active.size,0);}
const priority=f=>{const s=read(f);assert(/Priority=Idle/.test(s),'Priority not verified '+f);return {logSHA256:hash(bytes(f)),samples:+(s.match(/VerifiedLowPrioritySamples=(\d+)/)||[,1])[1]};};
for(const lib of ['reference','candidate']){assert.equal(exit('combined_compile/'+lib+'.exitcode'),0);priority('combined_compile/'+lib+'.priority.log');}
const controls=[];
for(const [field,word]of [['mix','accumulator'],['mixout','output']]){
 const q='controls/'+field;assert.equal(exit(q+'/compile.exitcode'),0);priority(q+'/compile.priority.log');
 assert.notEqual(exit(q+'/run/shift70.exitcode'),0);priority(q+'/run/shift70.priority.log');const s=read(q+'/run/shift70.log');assert(s.includes(word+' poison did not survive omitted restore'));controls.push({field,status:'incorrect restore rejected before unfreeze',logSHA256:hash(bytes(q+'/run/shift70.log'))});
}
const result={status:'PASS',baseline:manifest.baseline,branch:'experiment/ym2413-selfhealing-combined',format:{words:104,version:17},clock:{hostPeriodPs:18684,FMhostPeriods:15,PALhostPeriods:1070460,NTSChostPeriods:896040},baselineRegressions:baseline,candidateRegressions,negativeControls:controls,crossEngine:JSON.parse(read('cross_engine.json')),binaryLayout:layout,campaign:manifest,reproduction,verifiedPeakConcurrency:peak,cases:[]};
result.analysisSources={};for(const f of ['oracle.tcl','combined_oracle.do','combined_models.do','combined_controls.ps1','baseline_regression.ps1','candidate_regressions.ps1','verify_scope.js','verify_combined_scope.js','verify_reproduction.js','collect_combined.js','write_combined_report.js','COMBINED_EXPERIMENT.md'])result.analysisSources[f]=hash(bytes(f));
result.baselineSourceManifestSHA256=hash(bytes('baseline_regression/source_manifest.json'));
result.ModelSim={version:'10.5b',executableSHA256:hash(fs.readFileSync('C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe'))};
const offsets=[2000,8000,20000,50000,100000,150000,250000,300000,350000];
for(let shift=0;shift<72;shift++){
 if(partial&&!fs.existsSync(p.join(d,'combined_runs/shift'+shift+'.exitcode')))continue;
 const prefix='combined_runs/shift'+shift,log=read(prefix+'.log');assert.equal(exit(prefix+'.exitcode'),0);assert(log.includes('PASS COMBINED ALL checkpoints=28'));assert(!/assertion (failure|error)/.test(log));
 const q=priority(prefix+'.priority.log');assert(q.samples>0);
 const passes=[...log.matchAll(/PASS COMBINED shift=(\d+) pass=(\d+) reset_ce=(\d+) full_ce=(\d+) total_ce=(\d+) PALedges=(\d+) NTSCedges=(\d+) hosts=(\d+)/g)].map(m=>({pass:+m[2],resetCE:+m[3],fullCE:+m[4],totalCE:+m[5],PALedges:+m[6],NTSCedges:+m[7],hosts:+m[8]}));assert.equal(passes.length,4);
 const poisons=[...log.matchAll(/POISON BOTH shift=\d+ pass=(\d+) kind=(\d+) saved_mix=(\d+) mix=(\d+) saved_out=(\d+) out=(\d+)/g)].map(m=>({pass:+m[1],kind:+m[2],savedMix:+m[3],mix:+m[4],savedOut:+m[5],out:+m[6]}));assert.equal(poisons.length,4);
 const last=[...log.matchAll(/LAST MISMATCH pass=(\d+) state_ce=(\d+) raw_ce=(\d+) clamp_ce=(\d+) state_host=(\d+) raw_host=(\d+) clamp_host=(\d+) overflow=(\d+) saturated=(\d+) follow_ns=(\d+)/g)].map(m=>({pass:+m[1],stateCE:+m[2],rawCE:+m[3],clampCE:+m[4],stateHost:+m[5],rawHost:+m[6],clampHost:+m[7],overflows:+m[8],saturations:+m[9],followNs:+m[10]}));assert.equal(last.length,4);
 const stimuli=[...log.matchAll(/PASS STIMULUS shift=\d+ pass=(\d+) egstate=(\d+)/g)].map(m=>({pass:+m[1],EGstate:+m[2]}));assert.equal(stimuli.length,4);
 const writes=[...log.matchAll(/LATE WRITE pass=(\d+) event=(\d+) CE=(\d+)/g)].map(m=>({pass:+m[1],event:+m[2],CE:+m[3]}));assert.equal(writes.length,36);
 const effects=[...log.matchAll(/PASS LATE EFFECT pass=(\d+) event=(\d+) CE=(\d+)/g)].map(m=>({pass:+m[1],event:+m[2],CE:+m[3]}));assert.equal(effects.length,36);
 const reset=(70-shift+72)%72+1,full=reset+72;
 for(let k=0;k<4;k++){
  const a=passes[k],b=poisons[k],z=last[k];assert.equal(a.pass,k);assert.equal(b.pass,k);assert.equal(z.pass,k);assert.equal(a.resetCE,reset);assert.equal(a.fullCE,full);assert(a.PALedges>=6&&a.NTSCedges>=6);assert(z.followNs>=115000000);assert.notEqual(b.mix,b.savedMix);assert.notEqual(b.out,b.savedOut);
  assert.equal(z.stateCE,full-1);assert.equal(z.rawCE,full-1);assert.equal(z.stateHost,(full-1)*15);assert.equal(z.rawHost,(full-1)*15);assert(z.clampCE<full);
  assert(Math.abs(z.followNs-(a.totalCE-full)*280.26)<100);
  for(let e=0;e<9;e++){
   const w=writes[k*9+e],t=effects[k*9+e];assert.equal(w.pass,k);assert.equal(t.pass,k);assert.equal(w.event,e);assert.equal(t.event,e);assert.equal(w.CE,full+offsets[e]+8);assert.equal(t.CE,full+offsets[e]+180);
  }
 }
 const video={PAL:[],NTSC:[]};for(const m of log.matchAll(/VIDEO (PAL|NTSC) pass=(\d+) edge=(\d+) host=(\d+)/g))video[m[1]].push({pass:+m[2],edge:+m[3],host:+m[4]});
 for(const [mode,list]of Object.entries(video))for(let k=0;k<4;k++){
  const a=list.filter(x=>x.pass===k);assert(a.length>=6);a.forEach((x,i)=>{assert.equal(x.edge,i+1);if(i)assert.equal(x.host-a[i-1].host,mode==='PAL'?1070460:896040);});
 }
 const trace=bytes('combined_trace_'+shift+'.bin');assert(trace.subarray(0,header.length).equals(header));assert.equal((trace.length-header.length)%48,0);
 const rows=(trace.length-header.length)/48;assert.equal(rows,passes.reduce((sum,x)=>sum+x.totalCE,0));
 const palEvents=[0,1,2,3].map(k=>video.PAL.filter(x=>x.pass===k)),ntscEvents=[0,1,2,3].map(k=>video.NTSC.filter(x=>x.pass===k));
 let k=0,ce=0,clampLast=0,overflow=0,saturated=0,prevC=poisons[0].mix,prevR=poisons[0].savedMix,palIndex=0,ntscIndex=0;
 function finish(){assert.equal(ce,passes[k].totalCE);assert.equal(clampLast,last[k].clampCE);assert.equal(last[k].clampHost,clampLast*15);assert.equal(overflow,last[k].overflows);assert.equal(saturated,last[k].saturations);}
 for(let pos=header.length;pos<trace.length;pos+=48){
  assert.equal(trace.readInt32LE(pos),shift);const pass=trace.readInt32LE(pos+4);
  if(pass!==k){finish();assert.equal(pass,k+1);k=pass;ce=0;clampLast=0;overflow=0;saturated=0;prevC=poisons[k].mix;prevR=poisons[k].savedMix;palIndex=0;ntscIndex=0;}
  assert.equal(trace.readInt32LE(pos+8),++ce);const c=trace.readInt32LE(pos+12),r=trace.readInt32LE(pos+16),cm=trace.readInt32LE(pos+20),rm=trace.readInt32LE(pos+24),host=trace.readInt32LE(pos+28),pal=trace.readInt32LE(pos+32),ntsc=trace.readInt32LE(pos+36),ca=trace.readInt32LE(pos+40),ra=trace.readInt32LE(pos+44),poison=poisons[k],delta=(poison.mix-poison.savedMix+16384)%16384;
  assert.equal(host,(ce-1)*15+1);assert.equal(ca,clamp(c));assert.equal(ra,clamp(r));
  // Counter reports use the pre-increment host index; sampled counters observe
  // those edges starting on the following host clock.
  while(palIndex<palEvents[k].length&&palEvents[k][palIndex].host<host)palIndex++;
  while(ntscIndex<ntscEvents[k].length&&ntscEvents[k][ntscIndex].host<host)ntscIndex++;
  assert.equal(pal,palIndex);assert.equal(ntsc,ntscIndex);
  if(ce<reset){assert.equal((cm-rm+16384)%16384,delta);assert.equal(c,poison.out);assert.equal(r,poison.savedOut);const step=signed((rm-prevR+16384)%16384),sum=signed(prevC)+step;if(sum>8191||sum< -8192)overflow++;prevC=cm;prevR=rm;}
  else assert.equal(cm,rm);
  if(ce>=reset&&ce<full)assert.equal(c,(r+delta)%16384);
  if(ce<full){assert.notEqual(c,r);if(((c>>13)&1)!==((c>>12)&1))saturated++;}else{assert.equal(c,r);assert.equal(ca,ra);}
  if(ca!==ra)clampLast=ce;
  if(ce===full){assert.equal(pal,0);assert.equal(ntsc,0);}
 }
 finish();assert.equal(k,3);
 result.cases.push({shift,passes,poisons,lastMismatch:last,stimuli,lateWrites:writes,lateEffects:effects,video,priority:q,traceRows:rows,traceSHA256:hash(trace),logSHA256:hash(bytes(prefix+'.log'))});
 console.log('PASS independent combined trace/frame/last-mismatch verification shift='+shift);
}
if(!result.cases.length){console.log('No completed phases yet');process.exit(0);}
result.status=partial?'PARTIAL':'PASS';result.loads=4*result.cases.length;result.traceRows=result.cases.reduce((sum,c)=>sum+c.traceRows,0);result.overflows=result.cases.reduce((sum,c)=>sum+c.lastMismatch.reduce((s,x)=>s+x.overflows,0),0);result.saturatedSamples=result.cases.reduce((sum,c)=>sum+c.lastMismatch.reduce((s,x)=>s+x.saturations,0),0);assert(result.overflows>0&&result.saturatedSamples>0);
const ps=result.cases.flatMap(c=>c.poisons);result.poisonPairs=[...new Set(ps.map(x=>x.mix+','+x.out))];result.poisonCoverage={zeroMixNonzeroOut:ps.filter(x=>x.mix===0&&x.out!==0).length,nonzeroMixZeroOut:ps.filter(x=>x.mix!==0&&x.out===0).length,oppositeSigns:ps.filter(x=>(x.mix<8192)!==(x.out<8192)).length,bothPositiveExtreme:ps.filter(x=>x.mix===8191&&x.out===8191).length,bothNegativeExtreme:ps.filter(x=>x.mix===8192&&x.out===8192).length};if(!partial)for(const [name,n]of Object.entries(result.poisonCoverage))assert(n>0,'Missing poison coverage '+name);
result.envelopeStates=[...new Set(result.cases.flatMap(c=>c.stimuli.map(x=>x.EGstate)))].sort();const allPasses=result.cases.flatMap(c=>c.passes);result.convergence={accumulatorResetMinCE:Math.min(...allPasses.map(x=>x.resetCE)),accumulatorResetMaxCE:Math.max(...allPasses.map(x=>x.resetCE)),lastMismatchMinCE:Math.min(...allPasses.map(x=>x.fullCE-1)),lastMismatchMaxCE:Math.max(...allPasses.map(x=>x.fullCE-1)),fullMinCE:Math.min(...allPasses.map(x=>x.fullCE)),fullMaxCE:Math.max(...allPasses.map(x=>x.fullCE))};
if(!partial){assert.equal(result.cases.length,72);assert.equal(result.loads,288);}
fs.writeFileSync(p.join(d,partial?'partial_results.json':'combined_results.json'),JSON.stringify(result,null,2));
const diff=cp.execFileSync('git',['--no-optional-locks','diff','--','rtl/'],{cwd:root});fs.writeFileSync(p.join(d,'production.diff'),diff);
console.log(JSON.stringify({status:result.status,phases:result.cases.length,loads:result.loads,tracePairs:result.traceRows,convergence:result.convergence,overflows:result.overflows,saturatedSamples:result.saturatedSamples,poisonPairs:result.poisonPairs.length,envelopeStates:result.envelopeStates},null,2));
