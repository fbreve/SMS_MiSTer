const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto'),d=__dirname,root=p.resolve(d,'../..');
const git=(...a)=>cp.execFileSync('git',['--no-optional-locks',...a],{cwd:root,stdio:['ignore','pipe','ignore'],encoding:'latin1'});
const read=(rev,f)=>{try{return git('show',rev+':'+f);}catch{return null;}},sha=s=>crypto.createHash('sha256').update(s).digest('hex');
const commits=git('log','--all','--full-history','--format=%H','--','rtl/savestates.sv','rtl/opll_snapshot.sv','rtl/VM2413/outputgenerator.vhd','rtl/VM2413/slotcounter.vhd').trim().split(/\r?\n/);
const versions=[],producers=[];
for(const rev of commits){const s=read(rev,'rtl/savestates.sv');if(!s)continue;const desc=s.match(/localparam\s*\[63:0\]\s*FM_DESC\s*=\s*([^;]+);/);if(!desc)continue;
 const version=(desc[1].match(/8'd(\d+)/)||[])[1];versions.push({rev,descriptor:desc[1],version});if(version!=='17')continue;
 const files={};for(const f of ['rtl/VM2413/outputgenerator.vhd','rtl/VM2413/slotcounter.vhd','rtl/opll_snapshot.sv','rtl/savestates.sv','rtl/system.vhd','SMS.sv']){const content=read(rev,f);files[f]={sha256:content?sha(content):null,normalized:content?sha(content.replace(/\s/g,'')):null};}
 producers.push({rev,files});
}
const worktrees=git('worktree','list','--porcelain').split(/\r?\n/).filter(x=>x.startsWith('worktree ')).map(x=>x.slice(9));
const live=[];for(const w of worktrees){const file=p.join(w,'rtl/savestates.sv');if(!fs.existsSync(file))continue;const s=fs.readFileSync(file,'latin1'),desc=s.match(/localparam\s*\[63:0\]\s*FM_DESC\s*=\s*([^;]+);/);if(!desc)continue;const files={};for(const f of ['rtl/VM2413/outputgenerator.vhd','rtl/VM2413/slotcounter.vhd','rtl/opll_snapshot.sv']){const fn=p.join(w,f);files[f]=fs.existsSync(fn)?sha(fs.readFileSync(fn,'latin1').replace(/\s/g,'')):null;}live.push({worktree:w,descriptor:desc[1],files});}
const groups={};for(const row of producers){const key=['rtl/VM2413/outputgenerator.vhd','rtl/VM2413/slotcounter.vhd','rtl/opll_snapshot.sv'].map(f=>row.files[f].normalized).join('/');(groups[key]??=[]).push(row.rev);}
fs.writeFileSync(p.join(d,'producer_audit.json'),JSON.stringify({scope:'Every reachable commit that changes the producer/control files, plus every current worktree; local repository, no remote fetch',commitsExamined:commits.length,versions,producers,live,groups},null,2));
console.log(JSON.stringify({commitsExamined:commits.length,version17ProducerCommits:producers.length,producerGroups:Object.values(groups),worktrees:live.map(x=>({path:x.worktree,descriptor:x.descriptor}))},null,2));
