const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto'),assert=require('assert'),d=__dirname;
const sha=b=>crypto.createHash('sha256').update(b).digest('hex');const name=process.argv[2]||'early',seed=name==='confirmation'?2:1;
assert(['early','confirmation'].includes(name));const gate=require('./functional_gate.json');assert(gate.passed);const root=fs.readFileSync('rtl/savestates.sv');assert.equal(sha(root),gate.sourceSHA);
const old=require('../savestate_f01_opll_fix/build_final_inputs.json'),src=p.join(d,'../savestate_f01_opll_fix/quartus_final'),dst=p.join(d,'quartus_'+name);assert(!fs.existsSync(dst),'Fresh build required');
const inputs={},changes=[];for(const [f,h]of Object.entries(old.inputs)){
 const baseline=fs.readFileSync(p.join(src,f));assert.equal(sha(baseline),h);
 let next=f==='rtl/savestates.sv'?root:baseline;
 if(seed===2&&f==='SMS.qsf'){assert(next.toString().includes('set_global_assignment -name SEED 1'));next=Buffer.from(next.toString().replace('set_global_assignment -name SEED 1','set_global_assignment -name SEED 2'));}
 fs.mkdirSync(p.dirname(p.join(dst,f)),{recursive:true});fs.writeFileSync(p.join(dst,f),next);inputs[f]=sha(next);if(sha(next)!==h)changes.push(f);
}
assert.deepEqual(changes,seed===1?['rtl/savestates.sv']:['rtl/savestates.sv','SMS.qsf']);
fs.copyFileSync(p.join(src,'build_id.v'),p.join(dst,'build_id.v'));
fs.writeFileSync(p.join(d,'build_'+name+'_inputs.json'),JSON.stringify({head:gate.head,name,seed,inputs,changes,buildIdSHA:sha(fs.readFileSync(p.join(dst,'build_id.v'))),tool:'Quartus17.0.2 Build602',device:'5CSEBA6U23I7',project:'SMS',top:'sys_top',settings:'Exact v17 production QSF/SDC/QIP/IP; fixed BUILD_DATE261025; source-only clean database',gateSHA:sha(fs.readFileSync(p.join(d,'functional_gate.json')))},null,2));
console.log('Prepared controlled '+name+' build with '+Object.keys(inputs).length+' inputs');
