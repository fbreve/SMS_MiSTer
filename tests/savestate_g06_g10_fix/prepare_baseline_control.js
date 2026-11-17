// Rebuild the unchanged committed post-G01 source with the candidate's date.
// The retained older-date baseline remains untouched and is also reported.
const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto'),assert=require('assert');
const d=__dirname,r=p.resolve(d,'../..'),old=p.resolve(d,'../savestate_g01_cpu_restart_fix/candidate'),dest=p.join(d,'quartus_baseline_date');
assert(!fs.existsSync(dest),'Fresh baseline directory required');
const git=(...a)=>cp.execFileSync('git',a,{cwd:r,maxBuffer:16*1024*1024}),sha=b=>crypto.createHash('sha256').update(b).digest('hex');
assert.equal(git('rev-parse','HEAD').toString().trim(),'8ffd15e2a7e530c0d77b07c6eeae3e8dc0aa0c8a');
const tracked=new Set(git('ls-tree','-r','--name-only','HEAD').toString().trim().split(/\r?\n/));
const manifest=JSON.parse(fs.readFileSync(p.resolve(old,'../build_sources.json'))),out={};let committed=0;
for(const [f,h]of Object.entries(manifest)){if(f.startsWith('releases/'))continue;
 const b=fs.readFileSync(p.join(old,f));assert.equal(sha(b),h,'Retained baseline '+f);
 if(tracked.has(f)){assert.equal(b.toString().replace(/\r\n/g,'\n'),git('show','HEAD:'+f).toString().replace(/\r\n/g,'\n'));committed++;}
 const target=p.join(dest,f);fs.mkdirSync(p.dirname(target),{recursive:true});fs.writeFileSync(target,b);out[f]=h;
}
const buildID=fs.readFileSync(p.join(d,'quartus/build_id.v'));fs.writeFileSync(p.join(dest,'build_id.v'),buildID);
fs.writeFileSync(p.join(d,'baseline_control_sources.json'),JSON.stringify(out,null,2)+'\n');
fs.writeFileSync(p.join(d,'baseline_control.json'),JSON.stringify({head:'8ffd15e2a7e530c0d77b07c6eeae3e8dc0aa0c8a',committed,inputs:Object.keys(out).length,buildID:buildID.toString(),buildIDSha256:sha(buildID),purpose:'Unchanged committed baseline; same generated date as candidate. Retained Oct22 baseline is separately reported.'},null,2)+'\n');
console.log('PASS fresh unchanged baseline control: '+committed+' committed inputs; '+buildID.toString());
