const fs=require('fs'),p=require('path'),cp=require('child_process'),c=require('crypto'),assert=require('assert');
const task=__dirname,repo=p.resolve(task,'../..'),src=p.join(task,'physical_seed2'),old=JSON.parse(fs.readFileSync(p.join(src,'inputs.json')));
const sha=b=>c.createHash('sha256').update(b).digest('hex'),norm=b=>b.toString('latin1').replace(/\r\n/g,'\n');
cp.execFileSync('node',[p.join(task,'verify.js')],{stdio:'inherit'});
cp.execFileSync('node',[p.join(src,'check_inputs.js')],{stdio:'inherit'});
for(const [tool,h]of Object.entries(old.toolHashes))assert.equal(sha(fs.readFileSync('C:/intelFPGA_lite/17.0/quartus/bin64/'+tool+'.exe')),h);
const expected={1:[27438,32465,36049,489,-.173,-3.970],3:[27445,32453,36044,489,.002,0]};
const study=p.join(task,'paired_seed_study');assert(!fs.existsSync(study));fs.mkdirSync(study);
const seed2Files={};function keep(dir){for(const e of fs.readdirSync(dir,{withFileTypes:true})){const f=p.join(dir,e.name);if(e.isDirectory())keep(f);else seed2Files[p.relative(src,f)]=sha(fs.readFileSync(f));}}keep(src);
fs.writeFileSync(p.join(study,'seed2_preservation.json'),JSON.stringify(seed2Files,null,2)+'\n');
const git=(...args)=>cp.execFileSync('git',['--no-optional-locks',...args],{cwd:repo,stdio:['ignore','pipe','pipe']});
const worktrees=git('worktree','list','--porcelain').toString().split(/\r?\n/).filter(x=>x.startsWith('worktree ')).map(x=>x.slice(9));
const preservation={master:git('rev-parse','master').toString().trim(),worktrees:Object.fromEntries(worktrees.map(w=>{const g=(...a)=>cp.execFileSync('git',['--no-optional-locks',...a],{cwd:w,stdio:['ignore','pipe','pipe']});return[w,{HEAD:g('rev-parse','HEAD').toString().trim(),diff:sha(g('diff','--binary','HEAD')),status:g('status','--porcelain','--untracked-files=no').toString()}];}))};
for(const seed of [1,3]){
 const d=p.join(task,'physical_seed'+seed),ref=p.join(repo,'tests/ym2413_v19_fullstate/physical_seed'+seed);assert(!fs.existsSync(d));
 const m=JSON.parse(fs.readFileSync(p.join(ref,'inputs.json'))),r=JSON.parse(fs.readFileSync(p.join(ref,'results.json'))).builds.candidate;
 assert.deepEqual([r.neededALMs,r.placedALMs,r.fittedRegisters,r.M10K,r.setupSlack,r.setupTNS],expected[seed]);
 for(const [f,h]of Object.entries(r.reportHashes))assert.equal(sha(fs.readFileSync(p.join(ref,'candidate/output_files',f))),h,'Reference report '+f);
 assert.equal(sha(fs.readFileSync(p.join(ref,r.rbf.path))),r.rbf.SHA256);
 for(const [tool,h]of Object.entries(m.toolHashes))assert.equal(h,old.toolHashes[tool]);
 fs.mkdirSync(d);fs.writeFileSync(p.join(d,'preservation_before.json'),JSON.stringify(preservation,null,2)+'\n');
 const inputs={};for(const [f,v]of Object.entries(old.builds.candidate.inputs)){
  let bytes=fs.readFileSync(p.join(src,'candidate',f));assert.equal(sha(bytes),v.SHA256);
  if(f==='SMS.qsf'){const text=bytes.toString('latin1');assert.equal((text.match(/-name SEED 2\b/g)||[]).length,1);bytes=Buffer.from(text.replace('-name SEED 2','-name SEED '+seed),'latin1');}
  const refBytes=fs.readFileSync(p.join(ref,'candidate',f));assert.equal(sha(refBytes),m.builds.candidate.inputs[f].SHA256);
  const expectedReference=f==='rtl/VM2413/registermemory.vhd'?Buffer.from(bytes.toString('latin1').replace('attribute ramstyle of regs_array : signal is "AUTO";','attribute ramstyle of regs_array : signal is "logic";'),'latin1'):bytes;
  assert.equal(norm(expectedReference),norm(refBytes),'Only attribute differs from paired reference '+seed+' '+f);
  const dest=p.join(d,'candidate',f);fs.mkdirSync(p.dirname(dest),{recursive:true});fs.writeFileSync(dest,bytes);inputs[f]={...v,SHA256:sha(bytes)};
 }
 const rtl=Object.entries(inputs).filter(([f])=>/^(rtl\/|sys\/|SMS\.sv$|files\.qip$)/.test(f));
 const manifest={...old,seed,builds:{candidate:{inputs}},sourceHash:sha(Buffer.from(Object.entries(inputs).sort().map(([f,v])=>f+' '+v.SHA256).join('\n'))),productionSourceHash:sha(Buffer.from(rtl.sort().map(([f,v])=>f+' '+v.SHA256).join('\n'))),reference:{...old.reference,directory:ref,inputsSHA256:sha(fs.readFileSync(p.join(ref,'inputs.json'))),resultsSHA256:sha(fs.readFileSync(p.join(ref,'results.json')))},seedPolicy:'Seeds 1 and 3 only; unchanged AUTO source; Seed 2 preserved'};
 manifest.builds.candidate.inputs['SMS.qsf'].seedOverride=seed;
 manifest.baselineReuse='Reused original matched full-state physical_seed'+seed+'/candidate reports after hash and source/configuration verification; no reference rebuild.';
 manifest.seedStudyPolicy='Frozen AUTO Seed 2 inputs, with only QSF Seed assignment changed to '+seed+'. Seed 2 artifacts preserved.';
 fs.writeFileSync(p.join(d,'inputs.json'),JSON.stringify(manifest,null,2)+'\n');
 for(const f of ['production.diff','build.ps1','check_inputs.js','settings.tcl','paths.tcl','query.ps1'])fs.copyFileSync(p.join(src,f),p.join(d,f));
 fs.writeFileSync(p.join(d,'collect.js'),fs.readFileSync(p.join(src,'collect.js'),'utf8').replace('../../ym2413_v19_fullstate/physical_seed2/results.json','../../ym2413_v19_fullstate/physical_seed'+seed+'/results.json'));
 fs.writeFileSync(p.join(d,'analyze.js'),fs.readFileSync(p.join(src,'analyze.js'),'utf8').replace('_Q17.0.2_seed2_','_Q17.0.2_seed'+seed+'_'));
 console.log(JSON.stringify({seed,PASS:true,reference:expected[seed],inputs:Object.keys(inputs).length,sourceHash:manifest.sourceHash,productionSourceHash:manifest.productionSourceHash}));
}
fs.writeFileSync(p.join(study,'run.ps1'),`$ErrorActionPreference='Stop'\nforeach($taskSeed in @(1,3)){\n $taskDir=Join-Path $PSScriptRoot "../physical_seed$taskSeed"\n & powershell -NoProfile -ExecutionPolicy Bypass -File "$taskDir/build.ps1"\n if($LASTEXITCODE){throw "Build failed Seed $taskSeed"}\n & powershell -NoProfile -ExecutionPolicy Bypass -File "$taskDir/query.ps1"\n if($LASTEXITCODE){throw "Query failed Seed $taskSeed"}\n & node "$taskDir/collect.js" *> "$taskDir/collect.log"\n if($LASTEXITCODE){throw "Collector failed Seed $taskSeed"}\n & node "$taskDir/analyze.js" *> "$taskDir/analysis.log"\n if($LASTEXITCODE){throw "Analysis failed Seed $taskSeed"}\n Write-Output "PASS Seed $taskSeed build and analysis"\n}\n`);
