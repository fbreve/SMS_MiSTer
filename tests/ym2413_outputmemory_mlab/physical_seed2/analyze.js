const fs=require('fs'),p=require('path'),crypto=require('crypto'),cp=require('child_process'),assert=require('assert'),d=__dirname;
const hash=b=>crypto.createHash('sha256').update(b).digest('hex'),read=f=>{const b=fs.readFileSync(f);return b.toString(b[0]===255&&b[1]===254?'utf16le':'utf8');};
const r=JSON.parse(read(p.join(d,'results.json'))),manifest=JSON.parse(read(p.join(d,'inputs.json'))),ref=manifest.reference.directory;
const rows=s=>s.split(/\r?\n/).filter(x=>x.startsWith(';')).map(x=>x.split(';').slice(1,-1).map(y=>y.trim()));
function table(s,title){const start=s.indexOf('; '+title+' ');assert(start>=0,title);const lines=s.slice(start).split(/\r?\n/);let stop=lines.findIndex((x,i)=>i>3&&!x.trim());if(stop<0)stop=lines.length;return rows(lines.slice(0,stop).join('\n'));}
const hierarchy={},memories={};for(const [label,root]of [['reference',p.join(ref,'candidate')],['candidate',p.join(d,'candidate')]]){
 hierarchy[label]={};const map=read(p.join(root,'output_files/SMS.map.rpt')),fit=read(p.join(root,'output_files/SMS.fit.rpt'));
 for(const [stage,title,report]of [['map','Analysis & Synthesis Resource Utilization by Entity',map],['fit','Fitter Resource Utilization by Entity',fit]]){const t=table(report,title);hierarchy[label][stage]={header:t.find(x=>x[0]==='Compilation Hierarchy Node'),rows:t.filter(x=>/^(?:RegisterMemory|PhaseMemory|opll_snapshot|opll|EnvelopeMemory|VoiceMemory|FeedbackMemory|OutputMemory)$/.test(x[x.length-2]))};}
 const ram=table(fit,'Fitter RAM Summary'),header=ram.find(x=>x.includes('M10K blocks'));
 assert(header);memories[label]={header,outputMemory:ram.filter(x=>x[0]&&x[0].includes('OutputMemory:Mmem')),all:ram.filter(x=>x[0]&&/^\d+$/.test(x[header.indexOf('M10K blocks')]||''))};
 const synthesis=table(map,'Analysis & Synthesis RAM Summary');memories[label].synthesisRegisterMemory=synthesis.filter(x=>x[0]&&x[0].includes('OutputMemory:Mmem'));
 memories[label].outputEvidence=map.split(/\r?\n/).filter(x=>/OutputMemory:Mmem|data_array/i.test(x)&&/Info \(|;/.test(x));
 const parameterTitle=map.split(/\r?\n/).find(x=>x.startsWith('; Parameter Settings for Inferred Entity Instance:')&&x.includes('OutputMemory:Mmem')&&x.includes('data_array'));
 memories[label].outputParameters=parameterTitle?table(map,parameterTitle.slice(2).replace(/;\s*$/,'').trim()):[];
 if(parameterTitle)fs.writeFileSync(p.join(d,`${label}_outputmemory_parameters.txt`),memories[label].outputParameters.map(x=>x.join(' ; ')).join('\n')+'\n');
 fs.writeFileSync(p.join(d,`${label}_outputmemory_evidence.txt`),memories[label].outputEvidence.join('\n')+'\n');
}
r.hierarchy=hierarchy;r.memoryImplementation=memories;
const normalizedRAM=(m)=>m.all.filter(x=>!x[0].includes('OutputMemory:Mmem')).map(x=>JSON.stringify(x.map((v,i)=>m.header[i]==='Location'?'<LOCATION>':i===0?v.replace(/altsyncram_[^:|]+:auto_generated/g,'altsyncram:<GENERATED>'):v))).sort();
const oldRAM=normalizedRAM(memories.reference),newRAM=normalizedRAM(memories.candidate);
r.otherMemoryDifferences={onlyReference:oldRAM.filter(x=>!newRAM.includes(x)),onlyCandidate:newRAM.filter(x=>!oldRAM.includes(x))};
assert.deepEqual(r.expandedSettingDifferences,{onlyBaseline:[],onlyCandidate:[]},'Expanded settings differ');assert.deepEqual(r.fitterSettingDifferences,{onlyBaseline:[],onlyCandidate:[]},'Fitter settings differ');
for(const [f,h]of Object.entries(r.builds.baseline.reportHashes))assert.equal(hash(fs.readFileSync(p.join(ref,'candidate/output_files',f))),h,'Reference report changed '+f);
const before=JSON.parse(read(p.join(d,'preservation_before.json'))),git=(cwd,...args)=>cp.execFileSync('git',['--no-optional-locks',...args],{cwd,stdio:['ignore','pipe','pipe']});
for(const [w,v]of Object.entries(before.worktrees)){assert.equal(git(w,'rev-parse','HEAD').toString().trim(),v.HEAD,w+' HEAD');assert.equal(hash(git(w,'diff','--binary','HEAD')),v.diff,w+' diff');assert.equal(git(w,'status','--porcelain','--untracked-files=no').toString(),v.status,w+' status');}
assert.equal(git(p.resolve(d,'../../..'),'rev-parse','master').toString().trim(),before.master);
for(const [f,v]of Object.entries(manifest.builds.candidate.inputs))assert.equal(hash(fs.readFileSync(p.join(d,'candidate',f))),v.SHA256,'Candidate frozen input changed '+f);
function paths(file){return read(file).split(/Path #\d+: Setup slack is /).slice(1).map(s=>{const t=rows(s),get=k=>(t.find(x=>x[0]===k)||[])[1];return{slack:+s.split(/\s/)[0],from:get('From Node'),to:get('To Node'),launch:get('Launch Clock'),latch:get('Latch Clock')};});}
r.outputMemoryPaths={from:paths(p.join(d,'candidate/physical_outputs_from.rpt')),to:paths(p.join(d,'candidate/physical_outputs_to.rpt'))};
const b=r.builds.candidate,tag=b.qualifiedConstrainedTiming?'TIMING_PASS':'TIMING_FAIL',filename=`SMS_YM2413_OUTPUTMEM_MLAB_104W_v17_98737615_src${manifest.sourceHash.slice(0,12)}_Q17.0.2_seed2_${tag}_${b.rbf.SHA256.slice(0,12)}.rbf`;
if(b.qualifiedConstrainedTiming){assert(!fs.existsSync(p.join(d,filename)),'Do not overwrite retained RBF');fs.copyFileSync(p.join(d,b.rbf.path),p.join(d,filename));r.preservedRBF={filename,SHA256:hash(fs.readFileSync(p.join(d,filename))),bytes:b.rbf.bytes};} else r.preservedRBF=null;
r.preservation='PASS frozen sources, master, all prior worktree HEADs/tracked diffs/status, archived full-state reports';
fs.writeFileSync(p.join(d,'results.json'),JSON.stringify(r,null,2)+'\n');
console.log(JSON.stringify({deltas:r.deltas,warnings:r.warnings,hierarchy:r.hierarchy,memoryHeader:memories.candidate.header,outputMemory:memories.candidate.outputMemory,critical:b.paths.setup[0],outputPaths:r.outputMemoryPaths,rbf:r.preservedRBF,preservation:r.preservation},null,2));
