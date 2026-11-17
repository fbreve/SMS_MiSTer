const fs=require('fs'),p=require('path'),assert=require('assert'),crypto=require('crypto'),d=__dirname;
const sha=b=>crypto.createHash('sha256').update(b).digest('hex'),name=process.argv[2]||'early',seed=name==='confirmation'?2:1;
assert(['early','confirmation'].includes(name));const gate=require('./functional_gate.json');assert(gate.passed);
const changed=['SMS.sv','rtl/vdp_cram.vhd','rtl/vdp.vhd','rtl/savestates.sv','rtl/system.vhd'];
for(const f of changed)assert.equal(sha(fs.readFileSync(f)),gate.sourceHashes[f]);
const old=require('../savestate_g08_fm/build_early_inputs.json'),src=p.join(d,'../savestate_g08_fm/quartus_early'),dst=p.join(d,'quartus_'+name);assert(!fs.existsSync(dst),'Fresh build required');
const inputs={},changes=[];
for(const[f,h]of Object.entries(old.inputs)){
 const baseline=fs.readFileSync(p.join(src,f));
 // F06 retained a verified Quartus-expanded QSF after compilation.
 if(f==='SMS.qsf'&&sha(baseline)!==h){const proof=require('../savestate_g08_fm/qsf_export_verification.json');assert(proof.pass);assert.equal(proof.originalSHA,h);assert.equal(proof.expandedSHA,sha(baseline));}
 else assert.equal(sha(baseline),h,f);
 let next=changed.includes(f)?fs.readFileSync(f):baseline;
 if(seed===2&&f==='SMS.qsf'){assert(next.toString().includes('set_global_assignment -name SEED 1'));next=Buffer.from(next.toString().replace('set_global_assignment -name SEED 1','set_global_assignment -name SEED 2'));}
 fs.mkdirSync(p.dirname(p.join(dst,f)),{recursive:true});fs.writeFileSync(p.join(dst,f),next);inputs[f]=sha(next);if(sha(next)!==sha(baseline))changes.push(f);
}
assert.deepEqual(changes.slice().sort(),[...changed,...(seed===2?['SMS.qsf']:[])].sort());
fs.copyFileSync(p.join(src,'build_id.v'),p.join(dst,'build_id.v'));
fs.writeFileSync(p.join(d,'build_'+name+'_inputs.json'),JSON.stringify({head:gate.head,name,seed,inputs,changes,buildIdSHA:sha(fs.readFileSync(p.join(dst,'build_id.v'))),tool:'Quartus17.0.2 Build602',device:'5CSEBA6U23I7',project:'SMS',top:'sys_top',settings:'Exact retained v19 QSF/SDC/QIP/IP; fixed BUILD_DATE261025; source-only clean database',gateSHA:sha(fs.readFileSync(p.join(d,'functional_gate.json')))},null,2));
console.log('Prepared controlled '+name+' build: '+Object.keys(inputs).length+' inputs, '+changes.join(', '));
