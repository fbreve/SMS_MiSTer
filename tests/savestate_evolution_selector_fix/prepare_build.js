const fs=require('fs'),path=require('path'),cp=require('child_process'),crypto=require('crypto'),d=__dirname,r=path.resolve(d,'../..'),prior=path.join(r,'tests/savestate_mapper_detection_fix'),dest=path.join(d,'candidate');
const sha=b=>crypto.createHash('sha256').update(b).digest('hex');
const git=(...a)=>cp.execFileSync('git',a,{cwd:r,stdio:['ignore','pipe','pipe']});
if(!git('rev-parse','HEAD').toString().trim().startsWith('eede89d'))throw Error('Expected committed F13 base');
const manifest=JSON.parse(fs.readFileSync(path.join(prior,'build_sources.json'),'utf8'));
const tracked=new Set(git('ls-tree','-r','--name-only','HEAD').toString().trim().split(/\r?\n/));let committed=0,external=[];
for(const[p,h]of Object.entries(manifest)){
 const b=fs.readFileSync(path.join(prior,'candidate',p));if(sha(b)!==h)throw Error('F13 build source changed '+p);
 if(tracked.has(p)){if(b.toString().replaceAll('\r','')!==git('show','HEAD:'+p).toString().replaceAll('\r',''))throw Error('F13 build not committed baseline '+p);committed++;}else external.push(p);
}
if(!dest.startsWith(d+path.sep))throw Error('Bad isolated build path');
if(!fs.existsSync(dest)){
 fs.mkdirSync(dest,{recursive:true});for(const n of ['rtl','sys'])fs.cpSync(path.join(prior,'candidate',n),path.join(dest,n),{recursive:true});
 for(const n of ['SMS.qpf','SMS.qsf','files.qip','build_id.v'])fs.copyFileSync(path.join(prior,'candidate',n),path.join(dest,n));
}
let sources={};for(const p of Object.keys(manifest)){const a=path.join(r,p),b=path.join(dest,p);fs.mkdirSync(path.dirname(b),{recursive:true});fs.copyFileSync(a,b);sources[p]=sha(fs.readFileSync(a));}
fs.writeFileSync(path.join(d,'build_sources.json'),JSON.stringify(sources,null,2)+'\n');
fs.writeFileSync(path.join(d,'baseline.json'),JSON.stringify({commit:git('rev-parse','HEAD').toString().trim(),verifiedFiles:Object.keys(manifest).length,committed,manifestOnly:external,ALMs:27359,placedALMs:32589,fittedRegisters:36763,synthesisRegisters:35757,memoryBits:3809858,RAMBlocks:487,DSPs:39,setup:.435,hold:.202,violations:0},null,2)+'\n');
console.log('Prepared isolated F14 build; verified '+committed+' committed F13 inputs and '+external.length+' manifest-only backups; no database copied.');
