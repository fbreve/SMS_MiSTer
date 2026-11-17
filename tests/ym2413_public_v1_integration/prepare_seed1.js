const fs=require('fs'),p=require('path'),c=require('crypto'),vm=require('vm'),assert=require('assert');
const d=__dirname,root=p.resolve(d,'../..'),wt=p.join(d,'worktree'),seed=p.join(d,'quartus_seed1'),ref=p.join(root,'tests/ym2413_b1_c1_seed_study/seed1'),manifest=JSON.parse(fs.readFileSync(p.join(ref,'inputs.json')));
const sha=b=>c.createHash('sha256').update(b).digest('hex'),hash=f=>sha(fs.readFileSync(f));
// Recheck existing focused tests, production scope and all preservation records read-only.
const mock=Object.create(fs);mock.writeFileSync=(f,b)=>assert.deepEqual(JSON.parse(String(b)),JSON.parse(fs.readFileSync(f)));
vm.runInNewContext(fs.readFileSync(p.join(d,'collect_results.js'),'utf8'),{require:n=>n==='fs'?mock:require(n),__dirname:d,console:{log:()=>{}}});
assert(!fs.existsSync(seed),'Fresh build directory required');
const original=JSON.parse(fs.readFileSync(p.join(root,'tests/ym2413_v19_fullstate/physical_seed1/inputs.json')));
for(const [n,h]of Object.entries(original.toolHashes))assert.equal(hash(`C:/intelFPGA_lite/17.0/quartus/bin64/${n}.exe`),h,'Tool changed');
const m=JSON.parse(fs.readFileSync(p.join(d,'candidate_manifest.json'))),inputs={};
for(const [f,info]of Object.entries(manifest.builds.c1.inputs)){
 const frozen=p.join(ref,'c1',f);assert.equal(hash(frozen),info.SHA256);
 const source=m.approvedProduction.includes(f)?p.join(wt,f):frozen;
 const bytes=fs.readFileSync(source);const target=p.join(seed,'v1',f);
 fs.mkdirSync(p.dirname(target),{recursive:true});fs.writeFileSync(target,bytes,{flag:'wx'});
 inputs[f]={SHA256:sha(bytes),source,referenceC1SHA256:info.SHA256};
 if(/\.(qsf|sdc)$/.test(f))assert.equal(sha(bytes),info.SHA256,'QSF/SDC changed');
}
for(const f of ['settings.tcl','paths.tcl'])fs.copyFileSync(p.join(ref,f),p.join(seed,f));
fs.copyFileSync(p.join(root,'tests/ym2413_b1_c1_seed_study/stage_evidence.js'),p.join(seed,'stage_evidence.js'));
fs.writeFileSync(p.join(seed,'inputs.json'),JSON.stringify({seed:1,version:original.version,device:original.device,toolHashes:original.toolHashes,builds:{v1:{inputs}},referenceC1ManifestSHA256:hash(p.join(ref,'inputs.json')),approvedProduction:m.approvedProduction,commentAudit:'Valid CP932 comments retained unchanged by explicit user instruction; no comment cleanup performed.',focusedResultsSHA256:hash(p.join(d,'focused_results.json'))},null,2)+'\n',{flag:'wx'});
console.log('PASS preflight: exact five-file scope, focused evidence and preservation verified; frozen seed-1 inputs prepared; QSF/SDC identical to C1.');
