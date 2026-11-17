// The first snapshot hashed a latin1-decoded string; re-hash raw bytes. Existing worktrees were untouched in between.
const fs=require('fs'),p=require('path'),cp=require('child_process'),c=require('crypto'),assert=require('assert');
const task=__dirname,repo=p.resolve(task,'../..'),f=p.join(task,'preservation_before.json');
const old=JSON.parse(fs.readFileSync(f));
const git=(cwd,...a)=>cp.execFileSync('git',['--no-optional-locks','-c','safe.directory='+cwd.replace(/\\/g,'/'),...a],{cwd,stdio:['ignore','pipe','pipe']});
fs.renameSync(f,p.join(task,'preservation_before.initial_string_hash.json'));
const prior=JSON.parse(fs.readFileSync(p.join(repo,'tests/ym2413_selfhealing_combined/preservation_before.json')));
const known={};for(const v of Object.values(prior.worktrees))known[v.path.replace(/\\/g,'/')]=v.diffSHA256;
const out={master:old.master,worktrees:{}};
for(const [w,item] of Object.entries(old.worktrees)){
 assert.equal(git(w,'rev-parse','HEAD').toString().trim(),item.HEAD);assert.equal(git(w,'status','--porcelain','--untracked-files=no').toString(),item.status);
 const h=c.createHash('sha256').update(git(w,'diff','--binary','HEAD')).digest('hex');
 const key=w.replace(/\\/g,'/');if(known[key]&&!w.endsWith('optimized_integration/worktree'))assert.equal(h,known[key],'consistent with earlier recorded '+key);
 out.worktrees[w]={...item,diffSHA256:h};
}
fs.writeFileSync(f,JSON.stringify(out,null,2));console.log('rehashed',Object.keys(out.worktrees).length,'worktrees');
