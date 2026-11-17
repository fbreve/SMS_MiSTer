const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto'),assert=require('assert'),d=__dirname,root=p.resolve(d,'../..'),prior=p.join(root,'tests/savestate_g12_sdram_fix');
const name=process.argv[2]||'early';assert(['early','final'].includes(name));const gate=require('./sufficiency_gate.json');assert(gate.passed);
const sha=b=>crypto.createHash('sha256').update(b).digest('hex'),norm=b=>b.toString().replace(/\r\n/g,'\n'),git=(...a)=>cp.execFileSync('git',a,{cwd:root,maxBuffer:32*1024*1024});
assert.equal(git('rev-parse','HEAD').toString().trim(),gate.head);
for(const[f,h]of Object.entries(gate.productionHashes))assert.equal(sha(fs.readFileSync(p.join(root,f))),h,'gate source '+f);
const old=JSON.parse(fs.readFileSync(p.join(prior,'build_inputs.json'))).inputs.candidate,tracked=new Set(git('ls-tree','-r','--name-only','HEAD').toString().trim().split(/\r?\n/)),dst=p.join(d,'quartus_'+name);assert(!fs.existsSync(dst),'fresh source-only database required');
const inputs={},baseline={},changes=[];
for(const[f,h]of Object.entries(old)){if(f.startsWith('releases/'))continue;
 const b=fs.readFileSync(p.join(prior,'quartus_candidate',f));assert.equal(sha(b),h,'baseline '+f);if(tracked.has(f))assert.equal(norm(b),norm(git('show','HEAD:'+f)),'committed baseline '+f);
 const next=tracked.has(f)?fs.readFileSync(p.join(root,f)):b;const out=p.join(dst,f);fs.mkdirSync(p.dirname(out),{recursive:true});fs.writeFileSync(out,next);inputs[f]=sha(next);baseline[f]=h;if(norm(next)!==norm(b))changes.push(f);
}
const extra='rtl/opll_snapshot.sv';fs.copyFileSync(p.join(root,extra),p.join(dst,extra));inputs[extra]=sha(fs.readFileSync(p.join(root,extra)));changes.push(extra);
fs.copyFileSync(p.join(prior,'quartus_candidate/build_id.v'),p.join(dst,'build_id.v'));
// Run map/fit/asm/STA explicitly, bypassing only the timestamp pre-flow so the
// exact retained baseline date remains fixed. QSF/SDC/IP stay byte-identical.
fs.writeFileSync(p.join(d,'build_'+name+'_inputs.json'),JSON.stringify({head:gate.head,name,inputs,baseline,changes,seed:1,tool:'Quartus17.0.2 Build602',device:'5CSEBA6U23I7',project:'SMS',top:'sys_top',buildIdSHA:sha(fs.readFileSync(p.join(dst,'build_id.v'))),preFlow:'Timestamp script bypassed by explicit map/fit/asm/sta flow; original QSF and sys/build_id.tcl unchanged.'},null,2));
console.log('Prepared '+name+' isolated source-only build with '+Object.keys(inputs).length+' inputs.');
