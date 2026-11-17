const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto'),assert=require('assert');
const d=__dirname,repo=p.resolve(d,'../..'),wt=p.join(d,'worktree'),td=p.join(wt,'tests/ym2413_fullstate'),old=p.join(repo,'tests/ym2413_selfhealing_combined/worktree/tests/ym2413_fullstate'),base='9873761503510e4b2c7e06600bf5515344235c2f';
const git=(cwd,...a)=>cp.execFileSync('git',['--no-optional-locks',...a],{cwd,stdio:['ignore','pipe','pipe']}),hash=b=>crypto.createHash('sha256').update(b).digest('hex');
assert.equal(git(wt,'rev-parse','HEAD').toString().trim(),base);
const list=git(repo,'worktree','list','--porcelain').toString().split(/\r?\n/).filter(x=>x.startsWith('worktree ')).map(x=>x.slice(9)).filter(w=>p.resolve(w)!==p.resolve(wt));
fs.writeFileSync(p.join(d,'preservation_before.json'),JSON.stringify({master:git(repo,'rev-parse','master').toString().trim(),worktrees:Object.fromEntries(list.map(w=>[w,{HEAD:git(w,'rev-parse','HEAD').toString().trim(),diff:hash(git(w,'diff','--binary','HEAD')),status:git(w,'status','--porcelain','--untracked-files=no').toString()}]))},null,2));
const f=p.join(wt,'rtl/VM2413/registermemory.vhd'),s=fs.readFileSync(f,'latin1');assert(s.includes('attribute ramstyle of regs_array : signal is "logic";'));fs.writeFileSync(f,s.replace('attribute ramstyle of regs_array : signal is "logic";','attribute ramstyle of regs_array : signal is "AUTO";'),'latin1');
for(const n of ['prepare_tests.js','instrument_oracle.js'])fs.copyFileSync(p.join(old,n),p.join(td,n));
cp.execFileSync('node',['prepare_tests.js'],{cwd:td,stdio:'inherit'});cp.execFileSync('node',['instrument_oracle.js'],{cwd:td,stdio:'inherit'});
// Reuse only declarations, independently observed state and actual production wrappers.
// No poison hooks, self-healing exceptions, or prior experiment RTL are imported.
let header=fs.readFileSync(p.join(old,'combined_tb.vhd'),'utf8');header=header.slice(0,header.indexOf(' vp:entity candidate_work.video'));
header=header.replace(/combined_tb/g,'auto_tb').replace(/safe_equal\(101\) <=[^;]+;/,"safe_equal(101) <= all_equal(101);").replace("safe_equal(102) <= '1';","safe_equal(102) <= all_equal(102);");
fs.writeFileSync(p.join(td,'auto_header.vhd'),header);
fs.writeFileSync(p.join(d,'production.diff'),git(wt,'diff','--','rtl/','sys/','SMS.sv','files.qip'));
fs.writeFileSync(p.join(d,'source_manifest.json'),JSON.stringify({base,branch:git(wt,'branch','--show-current').toString().trim(),productionDiffSHA256:hash(git(wt,'diff','--','rtl/','sys/','SMS.sv','files.qip')),libraries:Object.fromEntries(['reference','candidate'].map(l=>[l,Object.fromEntries(fs.readdirSync(p.join(td,l)).map(n=>[n,hash(fs.readFileSync(p.join(td,l,n)))]))]))},null,2));
console.log('PASS isolated AUTO attribute; independent libraries and observations prepared');
