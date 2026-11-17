const fs=require('fs'),path=require('path');const out=__dirname,data=JSON.parse(fs.readFileSync(path.join(out,'measurements.json')));
const normalize=s=>s.replace(/Z:\/seed\d+\/(baseline|candidate)\//gi,'').replace(/ File:.*$/,'').replace(/ Line: \d+/g,'').replace(/\s+/g,' ').trim();
const audits=[];
for(const seed of [1,2,3]){
 const b=data.find(r=>r.seed===seed&&r.label==='baseline'),c=data.find(r=>r.seed===seed&&r.label==='candidate');if(!b||!c)continue;
 const bw=new Set(b.criticalWarnings.map(w=>normalize(w.text))),cw=new Set(c.criticalWarnings.map(w=>normalize(w.text)));
 const hierarchy=[];
 for(const row of c.hierarchy){const old=b.hierarchy.find(r=>r.path===row.path);if(/\|opll:fm$|\|savestates:|opll_snapshot:/.test(row.path)){hierarchy.push({path:row.path,baseline:old||null,candidate:row});}}
 const bp=new Set(b.unconstrainedPorts.map(p=>JSON.stringify(p))),cp=new Set(c.unconstrainedPorts.map(p=>JSON.stringify(p)));
 const own=s=>Number(s.match(/\(([-\d.]+)\)/)?.[1]||0);
 const ownHierarchyDeltas=c.hierarchy.map(row=>{const old=b.hierarchy.find(r=>r.path===row.path);return {path:row.path,entity:row.entity,baselineOwnALMs:own(old?.neededALMs||''),candidateOwnALMs:own(row.neededALMs),deltaOwnALMs:own(row.neededALMs)-own(old?.neededALMs||'')};}).sort((a,b)=>b.deltaOwnALMs-a.deltaOwnALMs);
 audits.push({seed,newUnconstrainedPorts:[...cp].filter(p=>!bp.has(p)),removedUnconstrainedPorts:[...bp].filter(p=>!cp.has(p)),newCriticalWarnings:[...cw].filter(w=>!bw.has(w)),removedCriticalWarnings:[...bw].filter(w=>!cw.has(w)),baselineUniqueCriticalWarnings:[...bw],candidateUniqueCriticalWarnings:[...cw],hierarchy,ownHierarchyDeltas,baselineViolatingTiming:b.timing.filter(t=>t.slack<0||t.tns<0),candidateViolatingTiming:c.timing.filter(t=>t.slack<0||t.tns<0)});
}
fs.writeFileSync(path.join(out,'comparison_audit.json'),JSON.stringify(audits,null,2));
console.log(JSON.stringify(audits.map(a=>({seed:a.seed,newCriticalWarnings:a.newCriticalWarnings,removedCriticalWarnings:a.removedCriticalWarnings,baselineWarningCount:a.baselineUniqueCriticalWarnings.length,candidateWarningCount:a.candidateUniqueCriticalWarnings.length,hierarchy:a.hierarchy,baselineViolatingTiming:a.baselineViolatingTiming,candidateViolatingTiming:a.candidateViolatingTiming})),null,2));
