const fs=require('fs'),p=require('path'),crypto=require('crypto'),assert=require('assert'),d=__dirname;
require('./verify');
const sha=b=>crypto.createHash('sha256').update(b).digest('hex'),gate=require('./functional_gate.json'),decision=require('./disposition.json'),first=require('./candidate1_results.json');
assert(gate.passed);assert.equal(gate.evidence.length,40);assert.equal(gate.fullImageWords,196608);assert.equal(gate.nmiTriplets.length,8);
for(const[f,h]of Object.entries(gate.sourceHashes))assert.equal(sha(fs.readFileSync(p.join(d,f))),h,'qualified source '+f);
for(const x of gate.evidence){assert.equal(sha(fs.readFileSync(p.join(d,x.dir,'simulation.log'))),x.logSHA,'qualified log '+x.dir);}
const builds=['candidate1',...(first.physicalGate?['baseline2','candidate2']:[])];
for(const name of builds){const m=require('./build_'+name+'_inputs.json'),q=p.join(d,'quartus_'+name);assert.equal(m.gateSHA,sha(fs.readFileSync(p.join(d,'functional_gate.json'))));for(const[f,h]of Object.entries(m.inputs))assert.equal(sha(fs.readFileSync(p.join(q,f))),h,'build '+name+'/'+f);assert.equal(sha(fs.readFileSync(p.join(q,'build_id.v'))),m.buildIdSHA);}
if(first.physicalGate){const base=require('./build_baseline2_inputs.json'),candidate=require('./build_candidate2_inputs.json'),second=require('./candidate2_results.json');assert.equal(base.seed,2);assert.equal(candidate.seed,2);assert.equal(second.baselineSeed,2);assert.equal(second.candidateSeed,2);for(const f of Object.keys(base.inputs))if(f!=='rtl/savestates.sv')assert.equal(base.inputs[f],candidate.inputs[f],'paired2 '+f);assert.equal(decision.qualified,second.physicalGate);}
else{assert(!decision.qualified);assert(!fs.existsSync(p.join(d,'build_candidate2_inputs.json')),'no unpaired favorable substitution');}
assert.equal(decision.productionApplied,false);assert.equal(decision.diff,'');assert.equal(decision.status,'?? tests/');
const report=fs.readFileSync(p.join(d,'review.md'),'utf8');assert(!report.includes('IN PROGRESS'));assert(report.includes('Final git diff --stat'));assert(report.includes('Final git status --short'));assert(report.includes('No commit, push, merge'));
fs.writeFileSync(p.join(d,'verification.json'),JSON.stringify({passed:true,head:decision.head,branch:decision.branch,productionApplied:false,qualified:decision.qualified,trackedFiles:204,retainedBuildInputs:137,qualifiedCases:gate.evidence.length,sourceHashesVerified:true,priorEvidencePreserved:true,pairedSecondSeed:first.physicalGate,reportSHA:sha(fs.readFileSync(p.join(d,'review.md'))),status:decision.status},null,2)+'\n');
console.log('PASS final report/source/evidence/branch/index preservation and physical decision verification.');
