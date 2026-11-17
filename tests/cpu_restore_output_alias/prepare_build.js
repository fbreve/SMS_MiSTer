const fs=require('fs'),p=require('path'),assert=require('assert'),crypto=require('crypto');const d=__dirname,sha=b=>crypto.createHash('sha256').update(b).digest('hex');
const name=process.argv[2]||'candidate1';assert(['candidate1','baseline2','candidate2'].includes(name));
require('./verify');const gate=require('./functional_gate.json');assert(gate.passed,'all functional gates must pass before a build');
assert.equal(sha(fs.readFileSync(p.join(d,'candidate/rtl/savestates.sv'))),gate.candidateSHA);
if(name!=='candidate1')assert(require('./candidate1_results.json').physicalGate,'seed1 must be favorable before paired seed2');
const seed=name.endsWith('2')?2:1,baseline=require('../savestate_g08_fm/build_early_inputs.json'),src=p.join(d,'../savestate_g08_fm/quartus_early'),dst=p.join(d,'quartus_'+name);assert(!fs.existsSync(dst),'fresh source-isolated build required');
const inputs={},changes=[];
for(const[f,h]of Object.entries(baseline.inputs)){if(f.startsWith('releases/'))continue;
 const b=fs.readFileSync(p.join(src,f));assert.equal(sha(b),h,f);let next=b;
 if(f==='rtl/savestates.sv'&&name!=='baseline2')next=fs.readFileSync(p.join(d,'candidate/rtl/savestates.sv'));
 if(f==='SMS.qsf'&&seed===2){assert(b.toString().includes('set_global_assignment -name SEED 1'));next=Buffer.from(b.toString().replace('set_global_assignment -name SEED 1','set_global_assignment -name SEED 2'));}
 const to=p.join(dst,f);fs.mkdirSync(p.dirname(to),{recursive:true});fs.writeFileSync(to,next);inputs[f]=sha(next);if(sha(next)!==h)changes.push(f);
}
assert.deepEqual(changes.sort(),[...(name!=='baseline2'?['rtl/savestates.sv']:[]),...(seed===2?['SMS.qsf']:[])].sort());
fs.copyFileSync(p.join(src,'build_id.v'),p.join(dst,'build_id.v'));
fs.writeFileSync(p.join(d,'build_'+name+'_inputs.json'),JSON.stringify({name,seed,head:gate.head,inputs,changes,gateSHA:sha(fs.readFileSync(p.join(d,'functional_gate.json'))),buildIdSHA:sha(fs.readFileSync(p.join(dst,'build_id.v'))),configuration:'Quartus17.0.2 Build602 Lite; 5CSEBA6U23I7; SMS/sys_top; BUILD_DATE261025; exact retained seed1 configuration except paired SEED2'},null,2));
console.log('Prepared fresh '+name+'; only '+changes.join(', ')+' differ.');
