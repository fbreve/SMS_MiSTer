const fs=require('fs'),p=require('path'),assert=require('assert'),d=__dirname,name=process.argv[2]||'candidate1',result=require('./'+name+'_results.json');
assert(['candidate1','candidate2'].includes(name));
const read=f=>fs.readFileSync(f,'utf8').trim().split(/\r?\n/).filter(x=>x&&x!=='name');
const old=read(p.join(d,name==='candidate2'?'registers_baseline2.tsv':'../savestates_internal_cost_audit/registers.tsv')),next=read(p.join(d,'registers_'+name+'.tsv'));
const banks=a=>a.filter(x=>/\|(?:z80_snap|z80_dir)\[\d+\](?:~.*)?$/.test(x));
const original=banks(old),current=banks(next);assert.equal(original.filter(x=>x.includes('|z80_snap[')).length,230);assert.equal(original.filter(x=>x.includes('|z80_dir[')).length,230);
result.bankEvidence={baseline:original,candidate:current,baselineCount:original.length,candidateCount:current.length,removed:original.length-current.length,note:'Output aliases may rename a surviving snapshot register; count both snapshot/output name families, not only global FF delta.'};
const dlt=result.delta;
// Conservative routing criterion: no additional routing ALUTs. The full routing
// rows remain in the result for interpretation; no favorable needed-ALM shortcut.
const rt=result.routingTotals;
const gates={intended230BankRemoved:original.length-current.length===230,lowerPlaced:dlt.placed<0,unchangedM10K:dlt.M10K===0,positiveTiming:result.candidate.setup>0&&result.candidate.hold>0,noViolations:result.candidate.violations===0,noNewCritical:result.newCritical.length===0,noRoutingALUTGrowth:dlt.routingALUT<=0,noAverageRoutingGrowth:rt.candidateAverage<=rt.baselineAverage,noPeakRoutingGrowth:rt.candidatePeak<=rt.baselinePeak};
result.physicalCriteria=gates;result.physicalGate=Object.values(gates).every(Boolean);fs.writeFileSync(p.join(d,name+'_results.json'),JSON.stringify(result,null,2)+'\n');
console.log(JSON.stringify({name,gates,physicalGate:result.physicalGate,delta:dlt,bankDelta:result.bankEvidence.removed},null,2));
