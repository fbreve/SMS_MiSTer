// Source-only preparation. Never starts Quartus; no compiled database copied.
const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto'),assert=require('assert');
const d=__dirname,root=p.resolve(d,'../..'),prior=p.join(root,'tests/savestate_g06_g10_fix');
const git=(...args)=>cp.execFileSync('git',args,{cwd:root,maxBuffer:32*1024*1024}),sha=b=>crypto.createHash('sha256').update(b).digest('hex'),norm=b=>b.toString().replace(/\r\n/g,'\n');
assert.equal(git('rev-parse','HEAD').toString().trim(),'58583189b5c650dc6658ef467e8dcb72d9f6e6c2');
const manifest=JSON.parse(fs.readFileSync(p.join(prior,'build_sources.json'))),tracked=new Set(git('ls-tree','-r','--name-only','HEAD').toString().trim().split(/\r?\n/));
let verified=0,external=[];const inputs={v14:{},v15:{}};
for(const [file,hash] of Object.entries(manifest)){const old=fs.readFileSync(p.join(prior,'quartus',file));assert.equal(sha(old),hash,'retained v14 input '+file);if(tracked.has(file)){assert.equal(norm(old),norm(git('show','HEAD:'+file)),'committed v14 baseline '+file);verified++;}else external.push(file);}
for(const version of ['v14','v15']){const dst=p.join(d,'quartus_'+version);if(fs.existsSync(dst))throw Error('Fresh source-only directory required '+dst);for(const file of Object.keys(manifest)){let b=version==='v14'&&tracked.has(file)?git('show','HEAD:'+file):fs.readFileSync(p.join(root,file));const out=p.join(dst,file);fs.mkdirSync(p.dirname(out),{recursive:true});fs.writeFileSync(out,b);inputs[version][file]=sha(b);}
 fs.copyFileSync(p.join(prior,'quartus/build_id.v'),p.join(dst,'build_id.v'));
}
fs.writeFileSync(p.join(d,'build_inputs.json'),JSON.stringify({head:git('rev-parse','HEAD').toString().trim(),seed:1,tool:'Quartus Prime Lite 17.0.2',verified,external,inputs,retainedV14:{ALMsNeeded:35419,ALMsPlaced:38142,registers:48002,M10K:487,memoryBits:3809858,DSP:39,setup:.384,hold:.226,violations:0},note:'Fresh source-only baseline and candidate; build_id.tcl regenerates date at full build. Check dates match before comparing.'},null,2));
console.log('Prepared source-only v14 and v15: '+verified+' committed inputs verified. Quartus NOT started.');
