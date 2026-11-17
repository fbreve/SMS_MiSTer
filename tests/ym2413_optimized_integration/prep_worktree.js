// Creates the isolated integration worktree and applies exactly the approved production changes.
const fs=require('fs'),p=require('path'),cp=require('child_process'),c=require('crypto'),assert=require('assert');
const task=__dirname,repo=p.resolve(task,'../..'),wt=p.join(task,'worktree'),base='9873761503510e4b2c7e06600bf5515344235c2f',branch='experiment/ym2413-optimized-integration';
const sha=b=>c.createHash('sha256').update(b).digest('hex');
const git=(cwd,...a)=>cp.execFileSync('git',['--no-optional-locks','-c','safe.directory='+cwd.replace(/\\/g,'/'),...a],{cwd,encoding:'latin1',stdio:['ignore','pipe','pipe']});
assert(!fs.existsSync(wt),'Refuse existing worktree');assert(!fs.existsSync(p.join(task,'preservation_before.json')));
const list=git(repo,'worktree','list','--porcelain').split(/\r?\n/).filter(x=>x.startsWith('worktree ')).map(x=>x.slice(9));
const pres={master:git(repo,'rev-parse','master').trim(),worktrees:Object.fromEntries(list.map(w=>[w,{HEAD:git(w,'rev-parse','HEAD').trim(),diffSHA256:sha(git(w,'diff','--binary','HEAD')),status:git(w,'status','--porcelain','--untracked-files=no')}]))};
fs.writeFileSync(p.join(task,'preservation_before.json'),JSON.stringify(pres,null,2));
assert.equal(git(repo,'rev-parse',base).trim(),base);
git(repo,'worktree','add','-b',branch,wt,base);
assert.equal(git(wt,'rev-parse','HEAD').trim(),base);
const srcMix=p.join(repo,'tests/ym2413_selfhealing_combined/worktree'),srcGuard=p.join(repo,'tests/ym2413_outputmemory_mlab_guarded/worktree');
const plan={'rtl/VM2413/temporalmixer.vhd':srcMix,'rtl/VM2413/outputmemory.vhd':srcGuard,'rtl/savestates.sv':srcGuard};
for(const [f,src] of Object.entries(plan))fs.writeFileSync(p.join(wt,f),fs.readFileSync(p.join(src,f)));
console.log(git(wt,'status','--short'));
