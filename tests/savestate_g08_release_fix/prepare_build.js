const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto'),assert=require('assert');const d=__dirname,root=p.resolve(d,'../..'),prior=p.join(root,'tests/savestate_g05_background_fix');
const git=(...a)=>cp.execFileSync('git',a,{cwd:root,maxBuffer:32*1024*1024}),sha=b=>crypto.createHash('sha256').update(b).digest('hex'),norm=b=>b.toString().replace(/\r\n/g,'\n');
assert.equal(git('rev-parse','HEAD').toString().trim(),'f205b05dc058fc5f7f2432779b61e8f3b0e22519');
const old=JSON.parse(fs.readFileSync(p.join(prior,'build_inputs.json'))),retained=old.inputs.v15,tracked=new Set(git('ls-tree','-r','--name-only','HEAD').toString().trim().split(/\r?\n/));
const inputs={v15:{},v16:{}},external=[];let verified=0;
for(const[f,h]of Object.entries(retained)){const b=fs.readFileSync(p.join(prior,'quartus_v15',f));assert.equal(sha(b),h,'retained v15 hash '+f);if(tracked.has(f)){assert.equal(norm(b),norm(git('show','HEAD:'+f)),'committed v15 '+f);verified++;}else external.push(f);}
for(const version of ['v15','v16']){const dst=p.join(d,'quartus_'+version);assert(!fs.existsSync(dst),'Fresh source-only directory required');
for(const f of Object.keys(retained)){const b=tracked.has(f)?(version==='v15'?git('show','HEAD:'+f):fs.readFileSync(p.join(root,f))):fs.readFileSync(p.join(prior,'quartus_v15',f));const out=p.join(dst,f);fs.mkdirSync(p.dirname(out),{recursive:true});fs.writeFileSync(out,b);inputs[version][f]=sha(b);}
fs.copyFileSync(p.join(prior,'quartus_v15/build_id.v'),p.join(dst,'build_id.v'));}
fs.writeFileSync(p.join(d,'build_inputs.json'),JSON.stringify({head:git('rev-parse','HEAD').toString().trim(),seed:1,tool:'Quartus Prime Lite17.0.2',verified,external,inputs,retainedV15:{ALMsNeeded:35945,ALMsPlaced:38718,registers:48385,M10K:487,memoryBits:3809858,DSP:39,setup:.211,hold:.232,violations:0},note:'Two fresh source-only builds; no databases/output copied. Matched generated dates/settings required.'},null,2));
console.log('Prepared fresh v15/v16 source-only trees; Quartus NOT started');
