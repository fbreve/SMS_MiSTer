const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto'),assert=require('assert'),d=__dirname,root=p.resolve(d,'../..');
const sha=b=>crypto.createHash('sha256').update(b).digest('hex'),proof=JSON.parse(fs.readFileSync(p.join(d,'sufficiency_pre_edit.json'),'utf8')),baseline=JSON.parse(fs.readFileSync(p.join(d,'baseline.json'),'utf8'));
assert.equal(cp.execFileSync('git',['rev-parse','HEAD'],{cwd:root}).toString().trim(),proof.head);
assert.equal(cp.execFileSync('git',['diff','--cached','--stat'],{cwd:root}).toString(),'');
for(const[f,h]of Object.entries(baseline.files))assert.equal(sha(fs.readFileSync(p.join(root,f))),h,'concurrent production edit '+f);
for(const[f,h]of Object.entries(proof.sources))assert.equal(sha(fs.readFileSync(p.join(d,'proposed',f))),h,'proposed source changed after gate '+f);
for(const f of Object.keys(proof.sources))fs.copyFileSync(p.join(d,'proposed',f),p.join(root,f));
console.log('Applied exactly six proof-gated G05 files; no staging/commit/Quartus');
