const fs=require('fs'),p=require('path'),d=__dirname;
let s=fs.readFileSync(p.join(d,'../register_memory_auto_seed2/measure.js'),'utf8');
s=s.replace("for(const [ref,h] of Object.entries(before.refs))assert.equal(cp.execFileSync('git',['rev-parse',ref],{cwd:root,encoding:'utf8'}).trim(),h);","assert.equal(cp.execFileSync('git',['show-ref','--heads'],{cwd:root,encoding:'utf8'}),before.refs);");
s=s.replaceAll('baselineVsSeed1','baselineVsNormal').replace("tests/register_memory_auto/baseline","tests/register_memory_auto_seed2/baseline");
s=s.replace("warningComparison:comparisons,simulations,","warningComparison:comparisons,simulations,implementationExperiment:'Physical synthesis effort EXTRA in both fresh seed2 variants',");
fs.writeFileSync(p.join(d,'measure.js'),s);
console.log('Prepared extraction of new matched pair; logical simulation evidence is explicitly inherited, not rerun.');
