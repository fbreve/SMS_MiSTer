const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto'),assert=require('assert'),d=__dirname;
const m=JSON.parse(fs.readFileSync(p.join(d,'inputs.json'))),r=JSON.parse(fs.readFileSync(p.join(d,'results.json'))),work=p.resolve(d,'../worktree');
const sha=b=>crypto.createHash('sha256').update(b).digest('hex'),hash=f=>sha(fs.readFileSync(f));
assert(r.builds.baseline.complete&&r.builds.candidate.complete,'Physical stages incomplete');
for(const [v,b]of Object.entries(m.builds))for(const [f,x]of Object.entries(b.inputs))assert.equal(hash(p.join(d,v,f)),x.SHA256,'Build input changed '+v+'/'+f);
for(const [f,h]of Object.entries(m.candidate.production))assert.equal(hash(p.join(work,f)),h,'Candidate worktree changed '+f);
const git=(...a)=>cp.execFileSync('git',['--no-optional-locks',...a],{cwd:work,stdio:['pipe','pipe','pipe']});
assert.equal(git('rev-parse','HEAD').toString().trim(),m.baseline);assert.equal(git('rev-parse','master').toString().trim(),m.baseline);
assert.equal(sha(git('diff','--binary')),m.worktreePreservation.diffSHA256,'Reviewed patch changed');
assert.equal(git('diff','--name-only','--','sys').toString(),'', 'Shared sys changed');
const sourceTreeSHA256=sha(JSON.stringify(Object.entries(m.builds.candidate.inputs).map(([f,x])=>[f,x.SHA256]).sort((a,b)=>a[0]<b[0]?-1:a[0]>b[0]?1:0)));
let extra;try{extra=git('diff','--no-index','--','NUL','rtl/opll_snapshot.sv');}catch(e){if(e.status!==1)throw e;extra=e.stdout;}
fs.writeFileSync(p.join(d,'candidate.diff'),Buffer.concat([git('diff','--binary'),Buffer.from('\n'),extra]));
const artifacts=p.join(d,'artifacts');fs.mkdirSync(artifacts,{recursive:true});
const record={status:'EXPERIMENTAL / SETUP TIMING FAIL / NOT HARDWARE VALIDATED',branch:m.candidate.branch,HEAD:m.baseline,uncommitted:true,FMreference:m.candidate.FMreference,words:104,descriptorVersion:17,version:m.version,device:m.device,seed:m.seed,buildDate:m.buildDate,sourceTreeSHA256,completePatchSHA256:hash(p.join(d,'candidate.diff')),inputsManifestSHA256:hash(p.join(d,'inputs.json')),artifacts:{}};
for(const v of ['baseline','candidate']){
 const name=v==='candidate'?`SMS_YM2413_FULLSTATE_104W_v17_66f16d5c_DIRTY_src${sourceTreeSHA256.slice(0,12)}_Q17.0.2_seed1_TIMING_FAIL_rbf${r.builds[v].rbf.SHA256.slice(0,12)}.rbf`:'SMS_MASTER_66f16d5c_Q17.0.2_seed1_261104.rbf';
 const original=p.join(d,v,'output_files/SMS.rbf'),dest=p.join(artifacts,name);assert(!fs.existsSync(dest),'Do not overwrite binary');fs.copyFileSync(original,dest);assert.equal(hash(dest),r.builds[v].rbf.SHA256);
 record.artifacts[v]={path:'artifacts/'+name,SHA256:hash(dest),bytes:fs.statSync(dest).size,constrainedTimingPass:r.builds[v].qualifiedConstrainedTiming};
}
const tools='C:/intelFPGA_lite/17.0/quartus/bin64';for(const [tool,h]of Object.entries(m.toolHashes))assert.equal(hash(p.join(tools,tool+'.exe')),h,'Tool executable changed');
fs.writeFileSync(p.join(d,'artifact_identity.json'),JSON.stringify(record,null,2)+'\n');
console.log(JSON.stringify(record,null,2));
