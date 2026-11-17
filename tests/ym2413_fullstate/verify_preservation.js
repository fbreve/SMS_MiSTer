// Read-only checks against the inventory taken before creating this experiment.
const fs=require('fs'),path=require('path'),cp=require('child_process'),crypto=require('crypto'),assert=require('assert');
const root=path.resolve(__dirname,'../..'),artifacts=path.resolve(root,'..');
const before=JSON.parse(fs.readFileSync(path.join(artifacts,'preservation_before.json')));
const sha=b=>crypto.createHash('sha256').update(b).digest('hex');
const git=(cwd,...args)=>cp.execFileSync('git',['--no-optional-locks','-c','safe.directory='+cwd.replace(/\\/g,'/'),...args],{cwd,stdio:['pipe','pipe','pipe']});
for(const [name,item] of Object.entries(before.worktrees)){
 assert.equal(git(item.path,'rev-parse','HEAD').toString().trim(),item.HEAD,name+' HEAD changed');
 assert.equal(sha(git(item.path,'diff','--binary','HEAD')),item.diffSHA256,name+' tracked contents changed');
 assert.equal(git(item.path,'status','--porcelain','--untracked-files=no').toString(),item.status,name+' tracked status changed');
 console.log('PASS preserved '+name);
}
assert.equal(git(root,'rev-parse','master').toString().trim(),before.master);
assert.equal(git(root,'rev-parse','HEAD').toString().trim(),'9873761503510e4b2c7e06600bf5515344235c2f');
assert.equal(git(root,'branch','--show-current').toString().trim(),'experiment/ym2413-selfhealing-mix');
assert.equal(git(root,'diff','HEAD','--','sys/').length,0);
assert.equal(git(root,'diff','--cached').length,0);
const mixout=before.worktrees.mixout.path;
assert.equal(sha(fs.readFileSync(path.join(mixout,'tests/ym2413_fullstate/heal_results.json'))),before.mixoutResultsSHA256);
console.log('PASS master, sys/, empty index, baseline HEAD and accepted mixout results preserved');
