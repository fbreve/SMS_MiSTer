const fs=require('fs'),p=require('path'),cp=require('child_process'),c=require('crypto'),assert=require('assert');
const verif=p.resolve(__dirname,'../..'),task=p.resolve(verif,'..'),wt=p.join(task,'worktree'),base='9873761503510e4b2c7e06600bf5515344235c2f',branch='experiment/ym2413-optimized-integration';
const repo=p.resolve(task,'../..');
const git=(cwd,...a)=>cp.execFileSync('git',['--no-optional-locks','-c','safe.directory='+cwd.replace(/\\/g,'/'),...a],{cwd,stdio:['ignore','pipe','pipe']});
const hash=b=>c.createHash('sha256').update(b).digest('hex'),norm=b=>b.toString('latin1').replace(/\r\n/g,'\n');
assert.equal(git(wt,'rev-parse','HEAD').toString().trim(),base);assert.equal(git(wt,'branch','--show-current').toString().trim(),branch);
assert.equal(git(wt,'diff','--cached').length,0,'index must be empty');
const guarded=p.join(repo,'tests/ym2413_outputmemory_mlab_guarded/worktree'),mixer=p.join(repo,'tests/ym2413_selfhealing_combined/worktree');
const changed=git(wt,'diff','--name-only','HEAD').toString().trim().split(/\r?\n/).sort();
assert.deepEqual(changed,['rtl/VM2413/outputmemory.vhd','rtl/VM2413/temporalmixer.vhd','rtl/savestates.sv'],'only the three approved production files differ');
assert.equal(git(wt,'ls-files','--others','--exclude-standard').toString().trim(),'','no untracked files in worktree');
const files=git(wt,'ls-tree','-r','--name-only',base,'--','SMS.sv','files.qip','rtl/','sys/').toString().trim().split('\n'),sources={};
for(const f of files){
 let expected=norm(git(wt,'show',base+':'+f));
 if(f==='rtl/VM2413/temporalmixer.vhd'){const e=expected;expected=expected.replace('mix <= ss_v_mix;','-- Combined experiment: accumulator heals at its normal clear.').replace('mixout <= ss_v_mixout;','-- Combined experiment: output heals after a complete mixer cycle.');assert.notEqual(e,expected);assert.equal(norm(fs.readFileSync(p.join(mixer,f))),expected,'matches the separately validated combined worktree');}
 if(f==='rtl/VM2413/outputmemory.vhd'){const e=expected;expected=expected.replace('attribute ramstyle of data_array : signal is "logic";','attribute ramstyle of data_array : signal is "MLAB";');assert.notEqual(e,expected);}
 if(f==='rtl/savestates.sv')expected=norm(fs.readFileSync(p.join(guarded,f)));
 const bytes=fs.readFileSync(p.join(wt,f));assert.equal(norm(bytes),expected,'Unexpected production content '+f);
 sources[f]=hash(bytes);
 if(f.startsWith('rtl/'))assert.equal(hash(fs.readFileSync(p.join(verif,f))),hash(bytes),'verification copy '+f);
}
const sv=norm(fs.readFileSync(p.join(wt,'rtl/savestates.sv')));
for(const frag of ['fm_saved_stage_zero<=0;fm_word<=0;','else if(fm_word==50 && dout_latch[1] && !fm_saved_stage_zero)state<=ST_ERROR;',"if(fm_word==39)fm_saved_stage_zero<=dout_latch[1:0]==2'b00;"])assert(sv.includes(frag),'guard fragment '+frag);
const before=JSON.parse(fs.readFileSync(p.join(task,'preservation_before.json')));
assert.equal(git(repo,'rev-parse','master').toString().trim(),before.master);
for(const [w,item] of Object.entries(before.worktrees)){
 assert.equal(git(w,'rev-parse','HEAD').toString().trim(),item.HEAD,w+' HEAD');
 assert.equal(hash(git(w,'diff','--binary','HEAD')),item.diffSHA256,w+' contents');
 assert.equal(git(w,'status','--porcelain','--untracked-files=no').toString(),item.status,w+' status');
}
fs.writeFileSync(p.join(__dirname,'combined_source_manifest.json'),JSON.stringify({baseline:base,sources,changed,omissions:['word101.mix','word102.mixout'],words:104,version:17,preservedWorktrees:Object.keys(before.worktrees).length},null,2));
console.log('PASS exact three-file production scope; mix/mixout omissions; MLAB; validator guard; master and '+Object.keys(before.worktrees).length+' existing worktrees preserved');
