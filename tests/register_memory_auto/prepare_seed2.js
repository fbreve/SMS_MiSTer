// Run only after seed-1 measurement qualifies a second matched pair.
const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto'),assert=require('assert');
const prior=__dirname,root=p.resolve(prior,'../..'),d=p.join(root,'tests/register_memory_auto_seed2');
const hash=f=>crypto.createHash('sha256').update(fs.readFileSync(f)).digest('hex');
const r=JSON.parse(fs.readFileSync(p.join(prior,'results.json'))),functional=JSON.parse(fs.readFileSync(p.join(prior,'functional_results.json')));
assert(Object.values(functional.simulations).every(x=>x.pass));
assert(r.delta.needed<0&&r.delta.placed<0,'Seed 1 lacks credible whole-design area gain');
assert(r.builds.candidate.setup>=0&&r.builds.candidate.hold>=0,'Candidate timing does not pass');
assert(r.builds.candidate.violations===0,'Candidate timing violations');
assert(!fs.existsSync(d),'Never overwrite a second-seed attempt');fs.mkdirSync(d);
const before=JSON.parse(fs.readFileSync(p.join(prior,'preservation_before.json')));
for(const e of fs.readdirSync(prior,{withFileTypes:true})){if(e.isFile()){const f='tests/register_memory_auto/'+e.name;before.files[f]=hash(p.join(root,f));}}
for(const [v,b] of Object.entries(r.builds))for(const f of Object.keys(b.reportHashes)){const rel='tests/register_memory_auto/'+v+'/output_files/'+f;before.files[rel]=hash(p.join(root,rel));}
fs.writeFileSync(p.join(d,'preservation_before.json'),JSON.stringify(before,null,2)+'\n');
const m=JSON.parse(fs.readFileSync(p.join(prior,'input_manifest.json'))),inputs={};
for(const [f,h]of Object.entries(m.inputs)){
 inputs[f]={};for(const v of ['baseline','candidate']){
  const source=p.join(prior,v,f);assert.equal(hash(source),h[v],source);let b=fs.readFileSync(source);
  if(f==='SMS.qsf'){let s=b.toString();assert.equal((s.match(/^set_global_assignment -name SEED 1\r?$/gm)||[]).length,1);b=Buffer.from(s.replace(/^set_global_assignment -name SEED 1(\r?)$/m,'set_global_assignment -name SEED 2$1'));}
  const target=p.join(d,v,f);fs.mkdirSync(p.dirname(target),{recursive:true});fs.writeFileSync(target,b);inputs[f][v]=hash(target);
 }
}
for(const v of ['baseline','candidate'])for(const f of ['build_id.v','jtag.cdf'])fs.copyFileSync(p.join(prior,v,f),p.join(d,v,f));
fs.writeFileSync(p.join(d,'input_manifest.json'),JSON.stringify({...m,seed:2,inputs,functionalEvidence:'../register_memory_auto/functional_results.json',functionalEvidenceSHA256:hash(p.join(prior,'functional_results.json'))},null,2)+'\n');
fs.copyFileSync(p.join(prior,'build.ps1'),p.join(d,'build.ps1'));
fs.copyFileSync(p.join(prior,'.gitignore'),p.join(d,'.gitignore'));
let measure=fs.readFileSync(p.join(prior,'measure.js'),'utf8');const start=measure.indexOf('const simulations=Object.fromEntries('),end=measure.indexOf("\nwrite('results.json'",start);assert(start>0&&end>start);
measure=measure.slice(0,start)+"const simulations=JSON.parse(read(p.join(root,'tests/register_memory_auto/functional_results.json'))).simulations;assert(Object.values(simulations).every(x=>x.pass));\n"+measure.slice(end);
measure=measure.replace("cwd:p.join(d,'worktree')","cwd:p.join(root,'tests/register_memory_auto/worktree')").replaceAll('baselineVsRetained','baselineVsSeed1').replace('tests/timing_history/builds/F','tests/register_memory_auto/baseline').replace('warningComparison:comparisons,simulations,',"warningComparison:comparisons,simulations,newSimulationsRun:false,functionalEvidence:'../register_memory_auto/functional_results.json',");
fs.writeFileSync(p.join(d,'measure.js'),measure);
console.log(JSON.stringify({seed:2,inputs:Object.keys(inputs).length,seed1Delta:r.delta,sourceDifference:Object.keys(inputs).filter(f=>inputs[f].baseline!==inputs[f].candidate),functionalEvidence:'../register_memory_auto/functional_results.json'},null,2));
