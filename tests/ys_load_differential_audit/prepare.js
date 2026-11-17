const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto'),assert=require('assert');
const d=__dirname,root=p.resolve(d,'../..'),v19=p.join(root,'tests/ym2413_v19_fullstate/worktree');
const git=(cwd,...a)=>cp.execFileSync('git',a,{cwd,encoding:'utf8'}).trim();
const hash=b=>crypto.createHash('sha256').update(b).digest('hex');
const files=['SMS.sv','files.qip',...git(root,'ls-files','rtl').split('\n')];
const identity={current:{HEAD:git(root,'rev-parse','HEAD'),branch:git(root,'branch','--show-current'),trackedChanges:git(root,'status','--porcelain','--untracked-files=no')},v19:{HEAD:git(v19,'rev-parse','HEAD'),branch:git(v19,'branch','--show-current'),trackedChanges:git(v19,'status','--porcelain','--untracked-files=no'),untracked:git(v19,'ls-files','--others','--exclude-standard').split('\n')},master:git(root,'rev-parse','master'),files:{}};
for(const f of files){const a=fs.readFileSync(p.join(root,f)),b=fs.readFileSync(p.join(v19,f));identity.files[f]={current:hash(a),v19:hash(b),equal:a.equals(b),equalIgnoringLineEndings:a.toString('latin1').replace(/\r\n/g,'\n')===b.toString('latin1').replace(/\r\n/g,'\n')};}
const physical=p.join(root,'tests/ym2413_v19_fullstate/physical_seed1');
const inputs=JSON.parse(fs.readFileSync(p.join(physical,'inputs.json')));
identity.preservedPhysical={originalIdentity:inputs.candidate,productionVerification:{}};
for(const [f,expected]of Object.entries(inputs.candidate.production)){if(f.startsWith('releases/'))continue;
 const actual=hash(fs.readFileSync(p.join(physical,'candidate',f)));
 identity.preservedPhysical.productionVerification[f]={expected,actual,verified:actual===expected};
 assert.equal(actual,expected,'preserved physical source changed: '+f);
}
fs.writeFileSync(p.join(d,'source_identity.json'),JSON.stringify(identity,null,2)+'\n');
// Test-only ED-class intervention. This is deliberately not a production fix:
// only the naturally captured ED witness is supported by this experiment.
let cpu=fs.readFileSync(p.join(root,'rtl/T80/T80.vhd'),'utf8');
const adapt=s=>s.replace(/:\s*work\.(T80\w*)/g,': entity work.$1');
fs.writeFileSync(p.join(d,'T80_current_sim.vhd'),adapt(cpu));
fs.writeFileSync(p.join(d,'T80s_current_sim.vhd'),adapt(fs.readFileSync(p.join(root,'rtl/T80/T80s.vhd'),'utf8')));
const start=cpu.indexOf("if DIRSet = '1' then"),at=cpu.indexOf('IR <= "00000000";',start);assert(at>start);
cpu=cpu.slice(0,at)+cpu.slice(at).replace('IR <= "00000000";','IR <= x"ED"; -- TEST ONLY: restore captured predecessor class ED');
fs.writeFileSync(p.join(d,'T80_ed_probe.vhd'),adapt(cpu.replace(/\bT80\b/g,'T80_ed')));
const wrapper=fs.readFileSync(p.join(root,'rtl/T80/T80s.vhd'),'utf8').replace(/\bT80s\b/g,'T80s_ed').replace(/work\.T80\b/g,'work.T80_ed');
fs.writeFileSync(p.join(d,'T80s_ed_probe.vhd'),adapt(wrapper));
let tb=fs.readFileSync(p.join(d,'cpu_tb.sv'),'utf8');
if(!tb.includes('begin:probe')){const line=tb.split('\n').find(x=>x.startsWith(' T80s dut'));
 tb=tb.replace(line,' if(i==2)begin:probe\n'+line.replace('T80s dut','T80s_ed dut')+'\n end else begin:original\n'+line+'\n end');fs.writeFileSync(p.join(d,'cpu_tb.sv'),tb);}
console.log(JSON.stringify({current:identity.current,v19:{HEAD:identity.v19.HEAD,trackedChanges:identity.v19.trackedChanges},equalFiles:Object.values(identity.files).filter(x=>x.equal).length,totalFiles:files.length}));
