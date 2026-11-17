const fs=require('fs'),p=require('path'),assert=require('assert'),d=__dirname;
const b=JSON.parse(fs.readFileSync(p.join(d,'build_results.json')));
function mapped(version){
 const s=fs.readFileSync(p.join(d,'quartus_'+version,'output_files/SMS.map.rpt'),'utf8'),table=s.slice(s.lastIndexOf('Analysis & Synthesis Resource Utilization by Entity')),entities={};
 for(const line of table.split(/\r?\n/)){const c=line.split(';').map(x=>x.trim());if(c.length<11||!c[8].startsWith('|sys_top'))continue;const own=i=>+(c[i].match(/\((\d+)\)/)||[0,0])[1];entities[c[8]]={aluts:own(2),registers:own(3)};}
 const aluts=+s.match(/Combinational ALUT usage for logic\s*;\s*(\d+)/)[1];
 assert.equal(Object.values(entities).reduce((n,e)=>n+e.aluts,0),aluts);
 return {aluts,registers:b[version==='v16'?'baseline':'candidate'].synthesisRegisters,entities};
}
const baseline=mapped('v16'),candidate=mapped('candidate');
const entityDeltas=[...new Set([...Object.keys(baseline.entities),...Object.keys(candidate.entities)])].map(entity=>({entity,aluts:(candidate.entities[entity]?.aluts||0)-(baseline.entities[entity]?.aluts||0),registers:(candidate.entities[entity]?.registers||0)-(baseline.entities[entity]?.registers||0)})).filter(e=>e.aluts||e.registers).sort((a,b)=>Math.abs(b.aluts)-Math.abs(a.aluts));
assert.equal(entityDeltas.reduce((n,e)=>n+e.aluts,0),candidate.aluts-baseline.aluts);
assert.equal(entityDeltas.reduce((n,e)=>n+e.registers,0),0);
const result={baseline,candidate,entityDeltas,mappedAlutDelta:candidate.aluts-baseline.aluts,fittedAlutDelta:b.candidate.packing.logicALUTs-b.baseline.packing.logicALUTs,placedGrowthPercent:100*b.deltas.ALMsPlaced.fresh/b.baseline.ALMsPlaced,placedGrowthPercentagePoints:100*b.deltas.ALMsPlaced.fresh/41910,remainingPlacedALMs:41910-b.candidate.ALMsPlaced,assessment:'Small measured placement increase, not substantial: +185 ALMs, 0.477% relative / 0.441 percentage points;2909 unplaced ALMs remain. No new sequential RTL or mapped register storage. Mapped ALUT changes are global synthesis remapping; fitted register and packing differences are physical optimization. The required behavior is a single combinational existing-clock selection, so no historical payload or larger protocol is introduced.'};
fs.writeFileSync(p.join(d,'resource_analysis.json'),JSON.stringify(result,null,2));console.log(JSON.stringify({mappedAlutDelta:result.mappedAlutDelta,topEntityDeltas:entityDeltas.slice(0,8),assessment:result.assessment},null,2));
