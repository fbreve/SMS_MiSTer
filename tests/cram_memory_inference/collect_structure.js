const fs=require('fs'),p=require('path'),assert=require('assert'),d=__dirname;
function table(s,name){const lines=s.split(/\r?\n/),start=lines.findIndex(l=>l.startsWith('; '+name+' '));assert(start>=0,name);const rows=[];for(let i=start+1;i<lines.length&&lines[i].trim();i++)if(lines[i].startsWith(';'))rows.push({line:i+1,cells:lines[i].split(';').slice(1,-1).map(x=>x.trim())});return rows;}
function measure(folder){
 const fit=fs.readFileSync(p.join(folder,'output_files/SMS.fit.rpt'),'utf8'),map=fs.readFileSync(p.join(folder,'output_files/SMS.map.rpt'),'utf8');
 const n=s=>+(s.replaceAll(',','').match(/^[\d.]+/)?.[0]||0),own=s=>+(s.match(/\(([\d.]+)\)/)?.[1]||n(s));
 const hierarchy=table(fit,'Fitter Resource Utilization by Entity').filter(x=>x.cells[0].startsWith('|')).map(({line,cells:a})=>({path:a[14],entity:a[15],line,needed:n(a[1]),placed:n(a[2]),ownNeeded:own(a[1]),ownPlaced:own(a[2]),ownALUT:own(a[6]),ownFF:own(a[7]),memoryBits:n(a[9]),M10K:n(a[10])}));
 return {hierarchy,cram:hierarchy.filter(x=>x.entity==='vdp_cram'),controller:hierarchy.find(x=>x.entity==='savestates'),ram:table(fit,'Fitter RAM Summary').filter(x=>x.cells.some(c=>/vdp_cram/.test(c))),mapRAM:table(map,'Analysis & Synthesis RAM Summary').filter(x=>x.cells.some(c=>/vdp_cram/.test(c))),routing:table(fit,'Routing Usage Summary'),fanout:table(fit,'Non-Global High Fan-Out Signals')};
}
const baseline=measure(p.join(d,'../savestate_g08_fm/quartus_early')),candidate=measure(p.join(d,'quartus_early'));
assert.equal(candidate.cram.length,2);assert(candidate.cram.every(x=>x.M10K===2&&x.memoryBits===768),'two replicated 32x12 RAMs per palette');
const delta=candidate.hierarchy.map(x=>{const old=baseline.hierarchy.find(y=>y.path===x.path);return old?{path:x.path,entity:x.entity,ownPlaced:x.ownPlaced-old.ownPlaced,ownFF:x.ownFF-old.ownFF,ownALUT:x.ownALUT-old.ownALUT}:null;}).filter(Boolean).sort((a,b)=>a.ownPlaced-b.ownPlaced);
fs.writeFileSync(p.join(d,'structure_results.json'),JSON.stringify({baseline,candidate,delta},null,2)+'\n');console.log(JSON.stringify({cram:candidate.cram,controller:candidate.controller,largestReductions:delta.slice(0,6),largestIncreases:delta.slice(-6)},null,2));
