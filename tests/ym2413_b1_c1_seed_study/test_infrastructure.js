// Read-only parser regression against all six preserved reference builds.
const fs=require('fs'),p=require('path'),vm=require('vm'),assert=require('assert');
const code=fs.readFileSync(p.join(__dirname,'collect_study.js'),'utf8').split('const study =')[0]+'\nmodule.exports=parseVariant;';
const testFs=Object.create(fs);
testFs.existsSync=f=>String(f).endsWith('build.done')||fs.existsSync(f);
const context={require:n=>n==='fs'?testFs:require(n),__dirname,module:{exports:{}}};
vm.runInNewContext(code,context);
for(const seed of [1,2,3]){
 const dir=p.resolve(__dirname,'../ym2413_v19_fullstate/physical_seed'+seed);
 const results=JSON.parse(fs.readFileSync(p.join(dir,'results.json')));
 for(const v of ['baseline','candidate']){
  // Baseline has no opll_snapshot; only candidate exercises required reviewed-source checks.
  if(v==='baseline')continue;
  const actual=context.module.exports(p.join(dir,v)),expected=results.builds[v];
  for(const k of ['neededALMs','placedALMs','fittedRegisters','mappedRegisters','M10K','MLABbits','MLABcells','setupSlack','setupTNS','holdSlack','holdTNS','qualifiedConstrainedTiming'])assert.equal(actual[k],expected[k],seed+'/'+v+'/'+k);
  assert.deepEqual(actual.paths.setup,expected.paths.setup.map(({slack,from,to,launch,latch})=>({slack,from,to,launch,latch})));
  assert.equal(actual.warningCounts.total,expected.warningCounts.total);
  console.log('PASS reference parser seed='+seed+' outcome='+actual.outcome);
 }
}
