const fs=require('fs'),path=require('path'),crypto=require('crypto');const d=__dirname,r=path.resolve(d,'../..');
const sha=b=>crypto.createHash('sha256').update(b).digest('hex');
const proof=JSON.parse(fs.readFileSync(path.join(d,'sufficiency.json'),'utf8'));const design=fs.readFileSync(path.join(d,'design.md'),'utf8');
const prior=design.slice(0,design.indexOf('\n## Consumer-order detail supporting'));
if(sha(prior)!==proof.sourceHashes['design.md'])throw Error('Pre-edit design archive differs');fs.writeFileSync(path.join(d,'design_pre_edit.md'),prior);
for(const n of ['SMS.sv','rtl/T80/T80.vhd','rtl/T80/T80s.vhd','rtl/system.vhd','rtl/savestates.sv']){const a=fs.readFileSync(path.join(r,n)),b=fs.readFileSync(path.join(d,'proposed',n));if(sha(a)!==sha(b))throw Error('Proposed/current source mismatch '+n);}
const manifest=JSON.parse(fs.readFileSync(path.join(d,'build_sources.json'),'utf8'));for(const[n,h]of Object.entries(manifest)){if(sha(fs.readFileSync(path.join(r,n)))!==h)throw Error('Root input changed after build preparation '+n);if(n!=='SMS.qsf'&&sha(fs.readFileSync(path.join(d,'candidate',n)))!==h)throw Error('Candidate source differs '+n);}
console.log('PASS proposed/current/build source identity and exact archived pre-edit design.');
