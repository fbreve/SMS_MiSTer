const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto'),assert=require('assert');
const d=__dirname,root=p.resolve(d,'../..'),old=p.join(root,'tests/ys_fm227_validation_20261115');
const hash=b=>crypto.createHash('sha256').update(b).digest('hex'),sha=f=>hash(fs.readFileSync(f)),git=(...args)=>cp.execFileSync('git',args,{cwd:root});
const manifest=JSON.parse(fs.readFileSync(p.join(old,'release/MANIFEST.json'))),before=process.argv.includes('--before');
const files=['SMS.sv','rtl/savestates.sv'];
const buildInputs=JSON.parse(fs.readFileSync(p.join(old,'physical_r2/seed1_candidate_inputs.json')));
const source={};for(const f of files){source[f]=sha(p.join(root,f));assert.equal(source[f],buildInputs.files[f],f+' differs from compiled input');}
assert.equal(source['rtl/savestates.sv'],manifest.compiledSourceSHA256);
assert.equal(sha(p.join(old,'r2/production_correction.patch')),manifest.uncommittedPatchSHA256);
assert.equal(git('branch','--show-current').toString().trim(),'fix/ys-physical-sram-on-fm-pr227');
assert.equal(git('rev-parse','master').toString().trim(),'66f16d5c656fd8906d62570da4d258875bcee684');
assert.equal(git('rev-parse','integration/ym2413-public-v1-upstream').toString().trim(),manifest.baseline);
const protectedFiles=['REPORT.md','AUDIT.md','HARDWARE_TEST.md','release/MANIFEST.json','r2/source_identity.json','r2/functional_gate.json','physical_r2/comparison.json',...manifest.artifacts.map(x=>'release/'+x.file)];
const protectedHashes={};for(const f of protectedFiles)protectedHashes[f]=sha(p.join(old,f));
for(const a of manifest.artifacts)assert.equal(protectedHashes['release/'+a.file],a.SHA256);
const sys=hash(git('ls-tree','-r','HEAD','sys'));
const result={status:'PASS',head:git('rev-parse','HEAD').toString().trim(),source,originalPatchSHA256:manifest.uncommittedPatchSHA256,originalManifestSHA256:protectedHashes['release/MANIFEST.json'],primaryRBF:manifest.artifacts[0],protectedHashes,sysTreeSHA256:sys};
if(before){assert.equal(result.head,manifest.sourceCommit);assert.equal(hash(git('diff','--','rtl/savestates.sv')),manifest.uncommittedPatchSHA256);assert.equal(git('diff','--cached','--name-only').toString().trim(),'');}
else{const original=JSON.parse(fs.readFileSync(p.join(d,'identity_before.json')));assert.deepEqual(source,original.source);assert.deepEqual(protectedHashes,original.protectedHashes);assert.equal(sys,original.sysTreeSHA256);result.committedLFHashes={};for(const f of files){const blob=git('show','HEAD:'+f);result.committedLFHashes[f]=hash(blob);assert.equal(hash(blob),hash(Buffer.from(fs.readFileSync(p.join(root,f),'utf8').replace(/\r\n/g,'\n'))),f+' committed content differs');assert.equal(hash(git('cat-file','--filters','HEAD:'+f)),source[f],f+' checkout-filtered committed bytes differ');}result.lineEndings='Git blobs use LF; qualified compiled inputs and unchanged Windows working files use CRLF. git cat-file --filters reproduces qualified bytes exactly.';assert.equal(git('diff','--name-only').toString().trim(),'');assert.equal(git('diff','--cached','--name-only').toString().trim(),'');assert.deepEqual(git('diff','--name-only',manifest.baseline,'HEAD').toString().trim().split(/\r?\n/),['SMS.sv','rtl/savestates.sv']);}
fs.writeFileSync(p.join(d,before?'identity_before.json':'identity_after.json'),JSON.stringify(result,null,2)+'\n',{flag:'wx'});console.log('PASS source, patch, protected artifacts and refs ('+(before?'before':'after')+').');
