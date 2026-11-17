const fs=require('fs'),p=require('path'),c=require('crypto'),assert=require('assert');
const task=__dirname,wt=p.join(task,'worktree'),sha=b=>c.createHash('sha256').update(b).digest('hex'),norm=b=>b.toString('latin1').replace(/\r\n/g,'\n');
const syn=JSON.parse(fs.readFileSync(p.join(task,'synthesis/inputs.json'))),s2=JSON.parse(fs.readFileSync(p.join(task,'physical_seed2/inputs.json')));
for(const seed of [1,3]){
 const un=p.resolve(task,'../ym2413_outputmemory_mlab/physical_seed'+seed),d=p.join(task,'physical_seed'+seed);
 assert(!fs.existsSync(d),'Refuse overwriting '+d);
 const m=JSON.parse(fs.readFileSync(p.join(un,'inputs.json')));assert.equal(m.seed,seed);
 for(const [name,h]of Object.entries(m.toolHashes))assert.equal(sha(fs.readFileSync('C:/intelFPGA_lite/17.0/quartus/bin64/'+name+'.exe')),h,'Tool '+name);
 fs.mkdirSync(d);const inputs={},diff=[];
 for(const [f,v]of Object.entries(m.builds.candidate.inputs)){
  let bytes=fs.readFileSync(p.join(un,'candidate',f));assert.equal(sha(bytes),v.SHA256,'Unguarded input '+f);
  if(/^(rtl\/|sys\/|SMS\.sv$|files\.qip$)/.test(f)){const w=fs.readFileSync(p.join(wt,f));if(norm(bytes)!==norm(w)){diff.push(f);bytes=w;}}
  if(f!=='SMS.qsf')assert.equal(sha(bytes),s2.builds.candidate.inputs[f].SHA256,'Seed 2 input '+f);
  else{assert.equal(norm(bytes).replace(/SEED \d+/,'SEED 2'),norm(fs.readFileSync(p.join(task,'physical_seed2/candidate/SMS.qsf'))));}
  const dest=p.join(d,'candidate',f);fs.mkdirSync(p.dirname(dest),{recursive:true});fs.writeFileSync(dest,bytes);inputs[f]={...v,SHA256:sha(bytes)};
 }
 assert.deepEqual(diff,['rtl/savestates.sv']);
 const nonQsf=Object.entries(inputs).filter(([f])=>f!=='SMS.qsf').sort().map(([f,v])=>f+' '+v.SHA256).join('\n');
 const manifest={...m,candidate:s2.candidate,builds:{candidate:{inputs}},sourceDifferencesFromUnguardedMLAB:diff,sourceHash:sha(Buffer.from(Object.entries(inputs).sort().map(([f,v])=>f+' '+v.SHA256).join('\n'))),nonQsfSourceHash:sha(Buffer.from(nonQsf))};
 fs.writeFileSync(p.join(d,'inputs.json'),JSON.stringify(manifest,null,2)+'\n');
 for(const f of ['build.ps1','query.ps1','check_inputs.js','settings.tcl','paths.tcl','collect.js']){
  let s=fs.readFileSync(p.join(task,'physical_seed2',f),'utf8').replaceAll('physical_seed2','physical_seed'+seed);fs.writeFileSync(p.join(d,f),s);
 }
 for(const f of ['atoms.tcl','atoms.ps1','export_fitted.ps1']){
  let s=fs.readFileSync(p.join(un,f),'utf8');if(f.endsWith('.ps1')||f==='atoms.tcl')s=s.replaceAll('Z:','W:');fs.writeFileSync(p.join(d,f),s);
 }
 console.log(JSON.stringify({seed,diff,sourceHash:manifest.sourceHash,nonQsfSourceHash:manifest.nonQsfSourceHash}));
}
