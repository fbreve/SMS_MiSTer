const fs=require('fs'),p=require('path'),assert=require('assert'),cp=require('child_process'),d=__dirname;
const r=JSON.parse(fs.readFileSync(p.join(d,'results.json'))),raw=fs.readFileSync(p.join(d,'workflow.log')),workflow=raw.toString(raw[0]===255&&raw[1]===254?'utf16le':'utf8');
for(const key of ['seed1/A','seed1/C','seed2/A','seed2/C']){
cp.execFileSync('node',[p.join(d,'check_inputs.js'),key]);
assert(Object.values(r.builds[key].completed).every(Boolean));
for(const stage of ['map','fit','asm','sta'])assert(workflow.includes(`${key} ${stage} ended exit=0`));
assert.equal(r.builds[key].M10K,487);assert.equal(r.builds[key].synthesisRegisters,34857);
}
for(const seed of [1,2]){assert(r.pairs[seed].complete&&r.pairs[seed].qualified);assert(r.pairs[seed].deltas.needed.absolute>0);assert.deepEqual(r.pairs[seed].warnings,{added:[],removed:[]});assert.deepEqual(r.pairs[seed].fitterSettingDifferences,{onlyA:[],onlyC:[]});}
assert(fs.readFileSync(p.join(d,'functional.log'),'utf8').includes('PASS 327680'));
assert.deepEqual(JSON.parse(fs.readFileSync(p.join(d,'preservation_before.json'))),JSON.parse(fs.readFileSync(p.join(d,'preservation_after.json'))));
fs.writeFileSync(p.join(d,'final_verification.json'),JSON.stringify({PASS:true,successfulStages:16,postBuildInputsAndToolsUnchanged:true,repositoryHeadRefsIndexAndTrackedDiffUnchanged:true,fitterSettingsMatched:true,ramStructureMatched:[1,2].every(s=>r.pairs[s].inferredMemory.fittedRamStructureEqual),newWarnings:0,recommendation:'NO-GO: increased ALMs in both seeds'},null,2));
console.log('Final artifact verification PASS');
