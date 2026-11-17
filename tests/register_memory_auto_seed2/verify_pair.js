const fs=require('fs'),p=require('path'),crypto=require('crypto'),assert=require('assert');
const d=__dirname,prior=p.join(d,'../register_memory_auto'),hash=f=>crypto.createHash('sha256').update(fs.readFileSync(f)).digest('hex');
const m=JSON.parse(fs.readFileSync(p.join(d,'input_manifest.json'))),old=JSON.parse(fs.readFileSync(p.join(prior,'input_manifest.json'))),a=JSON.parse(fs.readFileSync(p.join(prior,'results.json'))),b=JSON.parse(fs.readFileSync(p.join(d,'results.json')));
for(const [f,h]of Object.entries(m.inputs))for(const v of ['baseline','candidate']){
 assert.equal(hash(p.join(d,v,f)),h[v]);const one=fs.readFileSync(p.join(prior,v,f)),two=fs.readFileSync(p.join(d,v,f));
 if(f==='SMS.qsf')assert(one.equals(Buffer.from(two.toString().replace(/^set_global_assignment -name SEED 2(\r?)$/m,'set_global_assignment -name SEED 1$1'))));else assert(one.equals(two),f);
}
for(const v of ['baseline','candidate']){
 for(const f of ['build_id.v','jtag.cdf'])assert.equal(hash(p.join(d,v,f)),hash(p.join(prior,v,f)));
 assert.equal(a.builds[v].synthesisRegisters,b.builds[v].synthesisRegisters);
 assert.equal(a.builds[v].memoryBits,b.builds[v].memoryBits);
 assert.equal(a.builds[v].M10K,b.builds[v].M10K);
 assert.deepEqual(a.builds[v].registerParameters,b.builds[v].registerParameters,'RegisterMemory mapped parameters changed');
 const rows=x=>x.registerRamRows.map(l=>l.split(';').slice(1,-1).map(s=>s.trim()).filter((s,i)=>i!==21));
 assert.deepEqual(rows(a.builds[v]),rows(b.builds[v]),'RegisterMemory fitted geometry changed');
}
assert.equal(hash(p.join(prior,'functional_results.json')),m.functionalEvidenceSHA256);
const result={verifiedSourceFiles:Object.keys(old.inputs).length,onlyCrossSeedChange:'SMS.qsf SEED 1 -> 2 in both variants',sameRegisterMemoryMappedParameters:true,sameRegisterMemoryFittedGeometry:true,sameWholeDesignMappedRegistersAndMemoryBits:true,sameGeneratedInputs:true,functionalQualificationReused:true,newSimulationsRun:false};
fs.writeFileSync(p.join(d,'cross_seed_validation.json'),JSON.stringify(result,null,2)+'\n');console.log(result);
