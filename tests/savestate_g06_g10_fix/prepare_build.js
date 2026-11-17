// Source-only preparation. This script never invokes Quartus.
const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto'),assert=require('assert');
const here=__dirname,root=p.resolve(here,'../..'),old=p.resolve(here,'../savestate_g01_cpu_restart_fix'),dest=p.join(here,'quartus');
const hash=b=>crypto.createHash('sha256').update(b).digest('hex');
const git=(...args)=>cp.execFileSync('git',args,{cwd:root,maxBuffer:16*1024*1024});
assert.equal(git('rev-parse','HEAD').toString().trim(),'8ffd15e2a7e530c0d77b07c6eeae3e8dc0aa0c8a');
if(fs.existsSync(dest))throw Error('Fresh source-only Quartus directory required; no database reuse');
const manifest=JSON.parse(fs.readFileSync(p.join(old,'build_sources.json'))),tracked=new Set(git('ls-tree','-r','--name-only','HEAD').toString().trim().split(/\r?\n/));
let verified=0;const external=[],sources={};
for(const [file,expected]of Object.entries(manifest)){if(file.startsWith('releases/'))continue;
 const prior=fs.readFileSync(p.join(old,'candidate',file));assert.equal(hash(prior),expected,'Retained baseline hash '+file);
 if(tracked.has(file)){assert.equal(prior.toString().replace(/\r\n/g,'\n'),git('show','HEAD:'+file).toString().replace(/\r\n/g,'\n'),'Post-G01 committed baseline '+file);verified++;}
 else external.push(file);
 const target=p.join(dest,file);fs.mkdirSync(p.dirname(target),{recursive:true});const current=fs.readFileSync(p.join(root,file));fs.writeFileSync(target,current);sources[file]=hash(current);
}
fs.copyFileSync(p.join(old,'candidate/build_id.v'),p.join(dest,'build_id.v'));
fs.writeFileSync(p.join(here,'build_sources.json'),JSON.stringify(sources,null,2));
fs.writeFileSync(p.join(here,'build_baseline.json'),JSON.stringify({head:'8ffd15e2a7e530c0d77b07c6eeae3e8dc0aa0c8a',verified,external,ALMsNeeded:27368,ALMsPlaced:32684,registers:36831,M10K:487,memoryBits:3809858,DSP:39,setup:0.483,hold:0.213,violations:0},null,2));
console.log('Source-only controlled build prepared; '+verified+' committed baseline files verified. Quartus NOT started.');
