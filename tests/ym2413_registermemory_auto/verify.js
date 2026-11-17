const fs=require('fs'),p=require('path'),cp=require('child_process'),c=require('crypto'),assert=require('assert');
const d=__dirname,wt=p.join(d,'worktree'),td=p.join(wt,'tests/ym2413_fullstate'),base='9873761503510e4b2c7e06600bf5515344235c2f';
const git=(cwd,...a)=>cp.execFileSync('git',['--no-optional-locks',...a],{cwd,stdio:['ignore','pipe','pipe']}),hash=b=>c.createHash('sha256').update(b).digest('hex'),norm=b=>b.toString('latin1').replace(/\r\n/g,'\n');
assert.equal(git(wt,'rev-parse','HEAD').toString().trim(),base);assert.equal(git(wt,'branch','--show-current').toString().trim(),'experiment/ym2413-registermemory-auto');assert.equal(git(wt,'diff','--cached').length,0);
for(const f of git(wt,'ls-tree','-r','--name-only',base,'--','SMS.sv','files.qip','rtl/','sys/').toString().trim().split('\n')){
 let expected=norm(git(wt,'show',base+':'+f));if(f==='rtl/VM2413/registermemory.vhd')expected=expected.replace('attribute ramstyle of regs_array : signal is "logic";','attribute ramstyle of regs_array : signal is "AUTO";');assert.equal(norm(fs.readFileSync(p.join(wt,f))),expected,'Unexpected production edit '+f);
}
const before=JSON.parse(fs.readFileSync(p.join(d,'preservation_before.json')));
assert.equal(git(wt,'rev-parse','master').toString().trim(),before.master);
for(const [w,v]of Object.entries(before.worktrees)){assert.equal(git(w,'rev-parse','HEAD').toString().trim(),v.HEAD,w+' HEAD');assert.equal(hash(git(w,'diff','--binary','HEAD')),v.diff,w+' diff');assert.equal(git(w,'status','--porcelain','--untracked-files=no').toString(),v.status,w+' status');}
const manifest=JSON.parse(fs.readFileSync(p.join(d,'source_manifest.json')));
for(const [lib,files]of Object.entries(manifest.libraries))for(const [f,h]of Object.entries(files))assert.equal(hash(fs.readFileSync(p.join(td,lib,f))),h,'Compiled library source changed '+lib+'/'+f);
for(const f of Object.keys(manifest.libraries.reference)){
 let expected=norm(fs.readFileSync(p.join(td,'reference',f)));
 if(f==='registermemory.vhd')expected=expected.replace('attribute ramstyle of regs_array : signal is "logic";','attribute ramstyle of regs_array : signal is "AUTO";');
 assert.equal(norm(fs.readFileSync(p.join(td,'candidate',f))),expected,'Independent libraries differ outside attribute '+f);
}
for(const [f,h]of Object.entries(manifest.testInputs||{}))assert.equal(hash(fs.readFileSync(p.join(d,f))),h,'Frozen test input '+f);
if(manifest.ghdl)assert.equal(hash(fs.readFileSync(manifest.ghdl.path)),manifest.ghdl.SHA256,'GHDL binary changed');
console.log('PASS exact AUTO-only production scope; pinned libraries; empty index; master and all prior worktrees preserved');
