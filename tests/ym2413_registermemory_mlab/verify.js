const fs=require('fs'),p=require('path'),cp=require('child_process'),assert=require('assert'),d=__dirname,w=p.join(d,'worktree'),base='9873761503510e4b2c7e06600bf5515344235c2f',file='rtl/VM2413/registermemory.vhd';
const git=(...a)=>cp.execFileSync('git',['--no-optional-locks',...a],{cwd:w,stdio:['ignore','pipe','pipe']}),norm=b=>b.toString('latin1').replace(/\r\n/g,'\n');
assert.equal(git('rev-parse','HEAD').toString().trim(),base);assert.equal(git('branch','--show-current').toString().trim(),'experiment/ym2413-registermemory-mlab');assert.equal(git('diff','--cached').toString(),'');assert.equal(git('diff','--name-only',base).toString().trim(),file);
assert.equal(norm(fs.readFileSync(p.join(w,file))),norm(git('show',base+':'+file)).replace('attribute ramstyle of regs_array : signal is "logic";','attribute ramstyle of regs_array : signal is "MLAB";'));
console.log('PASS committed baseline, isolated MLAB branch, empty index and exact MLAB-only production diff');
