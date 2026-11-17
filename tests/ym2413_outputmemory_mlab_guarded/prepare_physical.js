const fs=require('fs'),p=require('path'),c=require('crypto'),assert=require('assert');
const task=__dirname,d=p.join(task,'physical_seed2'),wt=p.join(task,'worktree'),un=p.resolve(task,'../ym2413_outputmemory_mlab/physical_seed2');
assert(!fs.existsSync(d),'Refuse overwriting physical build');
const sha=b=>c.createHash('sha256').update(b).digest('hex'),norm=b=>b.toString('latin1').replace(/\r\n/g,'\n');
const m=JSON.parse(fs.readFileSync(p.join(un,'inputs.json'))),syn=JSON.parse(fs.readFileSync(p.join(task,'synthesis/inputs.json')));
for(const [name,h]of Object.entries(m.toolHashes))assert.equal(sha(fs.readFileSync('C:/intelFPGA_lite/17.0/quartus/bin64/'+name+'.exe')),h,'Tool '+name);
fs.mkdirSync(d);
const inputs={},diff=[];
for(const [f,v]of Object.entries(m.builds.candidate.inputs)){if(f.startsWith('releases/'))continue;
 let bytes=fs.readFileSync(p.join(un,'candidate',f));assert.equal(sha(bytes),v.SHA256,'Unguarded input '+f);
 if(/^(rtl\/|sys\/|SMS\.sv$|files\.qip$)/.test(f)){const w=fs.readFileSync(p.join(wt,f));if(norm(bytes)!==norm(w)){diff.push(f);bytes=w;}}
 if(f!=='SMS.qsf')assert.equal(sha(bytes),syn.builds.candidate.inputs[f].SHA256,'Synthesis-approved input '+f);
 const dest=p.join(d,'candidate',f);fs.mkdirSync(p.dirname(dest),{recursive:true});fs.writeFileSync(dest,bytes);inputs[f]={...v,SHA256:sha(bytes)};
}
assert.deepEqual(diff,['rtl/VM2413/outputmemory.vhd','rtl/savestates.sv'].filter(x=>diff.includes(x)));
const manifest={...m,candidate:{branch:'experiment/ym2413-outputmemory-mlab-guarded',HEAD:m.baseline,uncommitted:true},builds:{candidate:{inputs}},sourceDifferencesFromUnguardedMLAB:diff,sourceHash:sha(Buffer.from(Object.entries(inputs).sort().map(([f,v])=>f+' '+v.SHA256).join('\n')))};
fs.writeFileSync(p.join(d,'inputs.json'),JSON.stringify(manifest,null,2)+'\n');
for(const f of ['build.ps1','query.ps1','check_inputs.js','settings.tcl','paths.tcl','collect.js']){
 let s=fs.readFileSync(p.join(un,f),'utf8');if(f.endsWith('.ps1'))s=s.replaceAll('Z:','W:');fs.writeFileSync(p.join(d,f),s);
}
console.log(JSON.stringify({PASS:true,diff,sourceHash:manifest.sourceHash,unguardedSourceHash:m.sourceHash,n:Object.keys(inputs).length}));
