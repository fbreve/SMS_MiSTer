const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto'),assert=require('assert'),d=__dirname,root=p.resolve(d,'../..'),prior=p.join(root,'tests/savestate_g08_release_fix');
const git=(...a)=>cp.execFileSync('git',a,{cwd:root,maxBuffer:32*1024*1024}),sha=b=>crypto.createHash('sha256').update(b).digest('hex'),norm=b=>b.toString().replace(/\r\n/g,'\n');
cp.execFileSync(process.execPath,[p.join(d,'check_simulations.js')],{stdio:'inherit'});
assert.equal(git('rev-parse','HEAD').toString().trim(),'08cf1426bfd2e1f2a73fdb25aaf57715d408db11');
const old=JSON.parse(fs.readFileSync(p.join(prior,'build_inputs.json'))),retained=old.inputs.v16,tracked=new Set(git('ls-tree','-r','--name-only','HEAD').toString().trim().split(/\r?\n/));
const inputs={v16:{},candidate:{}},external=[];let verified=0;
for(const[f,h]of Object.entries(retained)){const b=fs.readFileSync(p.join(prior,'quartus_v16',f));assert.equal(sha(b),h,'retained v16 hash '+f);if(tracked.has(f)){assert.equal(norm(b),norm(git('show','HEAD:'+f)),'committed v16 '+f);verified++;}else external.push(f);}
for(const version of ['v16','candidate']){const dst=p.join(d,'quartus_'+version);assert(!fs.existsSync(dst),'Fresh source-only directory required');
 for(const f of Object.keys(retained)){const b=tracked.has(f)?(version==='v16'?git('show','HEAD:'+f):fs.readFileSync(p.join(root,f))):fs.readFileSync(p.join(prior,'quartus_v16',f));const out=p.join(dst,f);fs.mkdirSync(p.dirname(out),{recursive:true});fs.writeFileSync(out,b);inputs[version][f]=sha(b);}
 fs.copyFileSync(p.join(prior,'quartus_v16/build_id.v'),p.join(dst,'build_id.v'));
}
fs.writeFileSync(p.join(d,'build_inputs.json'),JSON.stringify({head:git('rev-parse','HEAD').toString().trim(),seed:1,tool:'Quartus Prime Lite17.0.2',verified,external,inputs,retainedV16:{ALMsNeeded:36068,ALMsPlaced:38816,registers:48258,M10K:487,memoryBits:3809858,DSP:39,setup:.141,hold:.243,violations:0},note:'Fresh source-only control/candidate; no database reuse. Matched generated dates/settings required.'},null,2));
console.log('Prepared fresh v16/candidate trees; Quartus not started.');
