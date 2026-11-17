// Reuse the seed-1 extraction logic without changing any seed-1 artifacts.
const fs=require('fs'),p=require('path'),assert=require('assert'),d=__dirname;
let s=fs.readFileSync(p.join(d,'../phase_memory_auto/measure.js'),'utf8');
const begin=s.indexOf('const simulations=Object.fromEntries('),end=s.indexOf('\nwrite(\'results.json\'',begin);
assert(begin>=0&&end>begin);
s=s.slice(0,begin)+`const simulations=JSON.parse(read(p.join(root,'tests/phase_memory_auto/results.json'))).simulations;
assert(Object.values(simulations).every(x=>x.pass),'Existing functional evidence did not pass');
assert.equal(hash(p.join(root,'rtl/VM2413/phasememory.vhd')),before.productionPhaseSHA256,'Root PhaseMemory changed');
`+s.slice(end);
s=s.replaceAll('baselineVsRetained','baselineVsSeed1');
s=s.replace("tests/timing_history/builds/F","tests/phase_memory_auto/baseline");
s=s.replace('warningComparison:comparisons,simulations,','warningComparison:comparisons,simulations,functionalEvidence:\'../phase_memory_auto/results.json\',newSimulationsRun:false,');
fs.writeFileSync(p.join(d,'measure.js'),s);
console.log('Prepared seed-2 measurement; simulation evidence is explicitly reused from seed 1.');
