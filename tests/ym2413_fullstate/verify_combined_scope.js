const fs=require('fs'),p=require('path'),cp=require('child_process'),c=require('crypto'),assert=require('assert');
const root=p.resolve(__dirname,'../..'),base='9873761503510e4b2c7e06600bf5515344235c2f';
const git=(cwd,...a)=>cp.execFileSync('git',['--no-optional-locks','-c','safe.directory='+cwd.replace(/\\/g,'/'),...a],{cwd,stdio:['ignore','pipe','pipe']});
const hash=b=>c.createHash('sha256').update(b).digest('hex'),norm=b=>b.toString('latin1').replace(/\r\n/g,'\n');
assert.equal(git(root,'rev-parse','HEAD').toString().trim(),base);assert.equal(git(root,'branch','--show-current').toString().trim(),'experiment/ym2413-selfhealing-combined');
assert.equal(git(root,'diff','--cached').length,0);
const files=git(root,'ls-tree','-r','--name-only',base,'--','SMS.sv','files.qip','rtl/','sys/').toString().trim().split('\n'),sources={};
for(const f of files){let expected=norm(git(root,'show',base+':'+f));if(f==='rtl/VM2413/temporalmixer.vhd')expected=expected.replace('mix <= ss_v_mix;','-- Combined experiment: accumulator heals at its normal clear.').replace('mixout <= ss_v_mixout;','-- Combined experiment: output heals after a complete mixer cycle.');const bytes=fs.readFileSync(p.join(root,f));assert.equal(norm(bytes),expected,'Unexpected production difference: '+f);sources[f]=hash(bytes);}
const before=JSON.parse(fs.readFileSync(p.resolve(root,'../preservation_before.json')));
assert.equal(git(root,'rev-parse','master').toString().trim(),before.master);
for(const [name,item]of Object.entries(before.worktrees)){
 assert.equal(git(item.path,'rev-parse','HEAD').toString().trim(),item.HEAD,name+' HEAD');
 assert.equal(hash(git(item.path,'diff','--binary','HEAD')),item.diffSHA256,name+' contents');
 assert.equal(git(item.path,'status','--porcelain','--untracked-files=no').toString(),item.status,name+' status');
 console.log('PASS preserved '+name);
}
for(const [name,item]of Object.entries(before.accepted)){
 const bytes=fs.readFileSync(item.path);assert.equal(hash(bytes),item.SHA256,name+' accepted results');
 const r=JSON.parse(bytes);for(const [f,digest]of Object.entries(r.sources||{}))assert.equal(hash(fs.readFileSync(p.join(before.worktrees[name].path,f))),digest,name+' accepted source '+f);
}
fs.writeFileSync(p.join(__dirname,'combined_source_manifest.json'),JSON.stringify({baseline:base,sources,onlyOmissions:['word101.mix','word102.mixout'],words:104,version:17,preserved:true},null,2));
console.log('PASS exact two-assignment scope, source identity, format, empty index, master and all references');
