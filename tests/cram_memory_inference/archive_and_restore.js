const fs=require('fs'),p=require('path'),assert=require('assert'),crypto=require('crypto'),cp=require('child_process'),d=__dirname,root=p.resolve(d,'../..');
const sha=b=>crypto.createHash('sha256').update(b).digest('hex'),base=require('./baseline.json'),gate=require('./functional_gate.json'),files=Object.keys(gate.sourceHashes);
assert(gate.passed);assert.equal(files.length,5);
for(const x of base.tracked)assert.equal(sha(fs.readFileSync(p.join(root,x.file))),gate.sourceHashes[x.file]||x.sha256,'unexpected working change '+x.file);
assert.equal(cp.execFileSync('git',['diff','--cached','--name-only'],{cwd:root,encoding:'utf8'}).trim(),'');
assert.equal(cp.execFileSync('git',['rev-parse','HEAD'],{cwd:root,encoding:'utf8'}).trim(),base.head);
const saved=[];
for(const f of files){const dst=p.join(d,'candidate',f);assert(!fs.existsSync(dst),'archive already exists');fs.mkdirSync(p.dirname(dst),{recursive:true});fs.copyFileSync(p.join(root,f),dst);assert.equal(sha(fs.readFileSync(dst)),gate.sourceHashes[f]);const old=fs.readFileSync(p.join(d,'baseline',f));assert.equal(sha(old),base.tracked.find(x=>x.file===f).sha256);saved.push({file:f,candidateSHA:gate.sourceHashes[f],baselineSHA:sha(old)});}
fs.writeFileSync(p.join(d,'experiment.patch'),cp.execFileSync('git',['diff','--binary','--',...files],{cwd:root,maxBuffer:10*1024*1024}));
fs.writeFileSync(p.join(d,'experiment_diff.stat'),cp.execFileSync('git',['diff','--stat','--',...files],{cwd:root}));
for(const f of files)fs.writeFileSync(p.join(root,f),fs.readFileSync(p.join(d,'baseline',f)));
for(const x of base.tracked)assert.equal(sha(fs.readFileSync(p.join(root,x.file))),x.sha256,'restore '+x.file);
fs.writeFileSync(p.join(d,'restore_verification.json'),JSON.stringify({passed:true,head:base.head,trackedFilesExact:base.tracked.length,files:saved,productionRestored:true,candidatePreserved:true},null,2)+'\n');
console.log('PASS: candidate and patch preserved; all 204 tracked source files exactly match entry v19 hashes.');
