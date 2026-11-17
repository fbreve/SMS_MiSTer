const fs=require('fs'),p=require('path'),cp=require('child_process'),c=require('crypto'),assert=require('assert'),d=__dirname,w=p.join(d,'worktree'),out=p.join(d,'synthesis'),ref=p.resolve(d,'../ym2413_outputmemory_mlab/physical_seed2');
assert(JSON.parse(fs.readFileSync(p.join(d,'functional_results.json'))).PASS);assert(!fs.existsSync(out),'Do not overwrite synthesis');
const hash=b=>c.createHash('sha256').update(b).digest('hex'),norm=b=>b.toString('latin1').replace(/\r\n/g,'\n');
const m=JSON.parse(fs.readFileSync(p.join(ref,'inputs.json'))),r=JSON.parse(fs.readFileSync(p.join(ref,'results.json')));
for(const [f,h]of Object.entries(r.builds.candidate.reportHashes))assert.equal(hash(fs.readFileSync(p.join(ref,'candidate/output_files',f))),h,f);
for(const [f,h]of Object.entries(m.toolHashes))assert.equal(hash(fs.readFileSync('C:/intelFPGA_lite/17.0/quartus/bin64/'+f+'.exe')),h,f);
fs.mkdirSync(out);const inputs={},differences=[];
for(const [f,v]of Object.entries(m.builds.candidate.inputs)){if(f.startsWith('releases/'))continue;
 let bytes=fs.readFileSync(p.join(ref,'candidate',f));assert.equal(hash(bytes),v.SHA256,f);
 if(/^(rtl\/|sys\/|SMS\.sv$|files\.qip$)/.test(f)){
 const candidate=fs.readFileSync(p.join(w,f));if(norm(bytes)!==norm(candidate)){differences.push(f);bytes=candidate;}
 }
 const target=p.join(out,'candidate',f);fs.mkdirSync(p.dirname(target),{recursive:true});fs.writeFileSync(target,bytes);inputs[f]={...v,SHA256:hash(bytes)};
}
assert.deepEqual(differences,['rtl/savestates.sv']);
const manifest={...m,baseline:'9873761503510e4b2c7e06600bf5515344235c2f',candidate:{branch:'experiment/ym2413-outputmemory-mlab-guarded',HEAD:'9873761503510e4b2c7e06600bf5515344235c2f',uncommitted:true},scope:'Analysis & Synthesis only; no fit/asm/sta/RBF',builds:{candidate:{inputs}},sourceHash:hash(Buffer.from(Object.entries(inputs).sort().map(([f,v])=>f+' '+v.SHA256).join('\n'))),sourceDifferencesFromUnguardedMLAB:differences,reference:ref,functionalResultsSHA256:hash(fs.readFileSync(p.join(d,'functional_results.json')))};
fs.writeFileSync(p.join(out,'inputs.json'),JSON.stringify(manifest,null,2));
for(const f of ['map.ps1','check_inputs.js'])fs.copyFileSync(p.join(ref,'../../ym2413_outputmemory_mlab/synthesis',f),p.join(out,f));
console.log('PASS matched 221 frozen inputs; only guard differs from unguarded MLAB comparator');
