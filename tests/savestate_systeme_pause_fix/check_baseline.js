const fs=require('fs'),path=require('path'),cp=require('child_process'),crypto=require('crypto'),d=__dirname,r=path.resolve(d,'../..'),prior=path.join(r,'tests/savestate_lightgun_fix');
const read=p=>JSON.parse(fs.readFileSync(p,'utf8'));
const manifest=read(path.join(prior,'sources.json')),report=read(path.join(prior,'results.json'));
const sha=b=>crypto.createHash('sha256').update(b).digest('hex');
const git=(...args)=>cp.execFileSync('git',args,{cwd:r,stdio:['ignore','pipe','pipe']});
if(git('rev-parse','HEAD').toString().trim()!==git('rev-parse','dcbe06d').toString().trim())throw Error('Not based directly on committed F11');
const tracked=new Set(git('ls-tree','-r','--name-only','dcbe06d').toString().trim().split(/\r?\n/)),external=[];let committed=0;
for(const[p,v]of Object.entries(manifest)){
 const actual=fs.readFileSync(path.join(prior,'candidate',p));
 if(sha(actual)!==v.candidate)throw Error('Stale F11 build source '+p);
 if(!tracked.has(p)){external.push(p);continue;}
 const a=actual.toString('utf8').replaceAll('\r',''),b=git('show','dcbe06d:'+p).toString('utf8').replaceAll('\r','');
 if(a!==b)throw Error('F11 build differs from committed source '+p);
 committed++;
}
const logBytes=fs.readFileSync(path.join(prior,'candidate/compile.log')),log=logBytes.toString(logBytes[0]===255&&logBytes[1]===254?'utf16le':'utf8');
if(!log.includes('Full Compilation was successful'))throw Error('F11 compilation incomplete');
const baseline={commit:git('rev-parse','dcbe06d').toString().trim(),verifiedSourceFiles:Object.keys(manifest).length,committedFilesCompared:committed,manifestOnlyFiles:external,candidate:report.candidate,worstSlack:report.worstSlack,violations:report.violations,warningCounts:report.warningCounts};
fs.writeFileSync(path.join(d,'baseline.json'),JSON.stringify(baseline,null,2)+'\n');
console.log(JSON.stringify(baseline,null,2));
