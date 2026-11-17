const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto'),assert=require('assert'),d=__dirname,root=p.resolve(d,'../..'),sha=b=>crypto.createHash('sha256').update(b).digest('hex');
const name=process.argv[2]||'A',seed=Number(process.argv[3]||1);assert(['A','confirmation'].includes(name)&&[1,2].includes(seed));
const gate=require('./functional_gate.json');assert(gate.passed,'full Quartus requires functional gate');
const baseline=require('./baseline.json');assert.equal(cp.execFileSync('git',['rev-parse','HEAD'],{cwd:root,encoding:'utf8'}).trim(),baseline.head);assert.equal(cp.execFileSync('git',['diff','--name-only'],{cwd:root,encoding:'utf8'}).trim(),'');
for(const[f,h]of Object.entries(baseline.hashes))assert.equal(sha(fs.readFileSync(p.join(root,f))),h,'production unchanged '+f);
for(const[f,h]of Object.entries(gate.candidateHashes))assert.equal(sha(fs.readFileSync(p.join(d,'candidate_A',f))),h,'proof-gated source '+f);
const old=require('../savestate_f01_opll_fix/build_final_inputs.json'),src=p.join(d,'../savestate_f01_opll_fix/quartus_final'),dst=p.join(d,'quartus_'+name);assert(!fs.existsSync(dst),'fresh database required');
const inputs={},changes=[];
for(const[f,h]of Object.entries(old.inputs)){
 const b=fs.readFileSync(p.join(src,f));assert.equal(sha(b),h,'exact retained F01 source '+f);
 let next=fs.existsSync(p.join(d,'candidate_A',f))?fs.readFileSync(p.join(d,'candidate_A',f)):b;
 if(seed!==1&&f==='SMS.qsf'){const q=next.toString();assert(/set_global_assignment -name SEED 1\b/.test(q));next=Buffer.from(q.replace(/set_global_assignment -name SEED 1\b/,'set_global_assignment -name SEED '+seed));}
 const target=p.join(dst,f);fs.mkdirSync(p.dirname(target),{recursive:true});fs.writeFileSync(target,next);inputs[f]=sha(next);if(sha(next)!==h)changes.push(f);
}
for(const f of ['rtl/sprite_state_pkg.vhd','rtl/sprite_snapshot.sv']){fs.copyFileSync(p.join(d,'candidate_A',f),p.join(dst,f));inputs[f]=sha(fs.readFileSync(p.join(dst,f)));changes.push(f);}
fs.copyFileSync(p.join(src,'build_id.v'),p.join(dst,'build_id.v'));
fs.writeFileSync(p.join(d,'build_'+name+'_inputs.json'),JSON.stringify({head:baseline.head,name,seed,tool:'Quartus17.0.2 Build602',device:'5CSEBA6U23I7',project:'SMS',top:'sys_top',inputs,changes,buildIdSHA:sha(fs.readFileSync(p.join(dst,'build_id.v'))),settings:seed===1?'Exact primary production settings.':'Confirmation changes only SEED 1 to SEED 2; do not treat as a paired baseline-seed2 delta.',preflow:'Explicit map/fit/asm/sta preserves matched BUILD_DATE261025; root QSF/SDC/IP unchanged.'},null,2)+'\n');console.log({prepared:name,seed,sourceInputs:Object.keys(inputs).length});
