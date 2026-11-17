const fs=require('fs'),p=require('path'),assert=require('assert'),crypto=require('crypto');
const d=__dirname,baseMeasure=require('../cpu_restore_output_alias/measure');
const read=f=>{const b=fs.readFileSync(f);return b.toString(b[0]===255&&b[1]===254?'utf16le':'utf8');};
const sha=f=>crypto.createHash('sha256').update(fs.readFileSync(f)).digest('hex');
const normalize=s=>s.replace(/Z:\/seed[12]\/[AC]\//gi,'<BUILD>/').replace(/[A-Z]:[^;\n]*?shared_standard_4pak_decode[\\/]seed[12][\\/][AC][\\/]/gi,'<BUILD>/').replace(/\bLine: \d+/g,'Line: <N>').replace(/(\.(?:vhd|sv|v))\(\d+\)/g,'$1(<N>)');
const splitRow=l=>l.split(';').slice(1,-1).map(x=>x.trim());
function table(text,name){const start=text.indexOf('; '+name+' ');if(start<0)return[];const a=text.slice(start).split(/\r?\n/);let stop=a.findIndex((s,i)=>i>3&&!s.trim());if(stop<0)stop=a.length;return a.slice(0,stop).filter(s=>s.startsWith(';')).map(splitRow);}
function physical(text){
 const rows=table(text,'Fitter Netlist Optimizations'),counts={},retimed={total:0,scaler:0,luminance:0,psg:0},hierarchy={};
 for(const r of rows){if(r.length<4||!r[1]||r[1]==='Action'||r[1]==='Node Type'||r[1]==='Operation')continue;const key=r[1]+' / '+r[2];counts[key]=(counts[key]||0)+1;
  if(r[1]==='Retimed Register'){retimed.total++;if(r[0].includes('ascal:'))retimed.scaler++;if(/o_poly_lum/.test(r[0]))retimed.luminance++;if(/psg/i.test(r[0]))retimed.psg++;}
 }
 const hierarchyRows=text.split(/\r?\n/).filter(l=>/^;/.test(l)&&/;\s*(?:savestates|jt89|AudioMix)\s*;/.test(l)).map(splitRow);
 for(const r of hierarchyRows)hierarchy[r.join(' | ')]=r;
 return{counts,retimed,hierarchyRows:Object.values(hierarchy)};
}
function paths(file,kind){
 if(!fs.existsSync(file))return[];const source=read(file),parts=source.split(new RegExp('Path #\\d+: '+kind+' slack is ')).slice(1);
 return parts.map(s=>{const rows=s.split(/\r?\n/).filter(l=>l.startsWith(';')).map(splitRow),prop=name=>{const r=rows.find(r=>r[0]===name);return r?r.slice(1):[];};return{slack:Number(s.split(/\s/)[0]),from:prop('From Node')[0],to:prop('To Node')[0],launch:prop('Launch Clock')[0],latch:prop('Latch Clock')[0],relationship:prop(kind+' Relationship')[0],skew:prop('Clock Skew')[0],dataDelay:prop('Data Delay')[0],logicLevels:prop('Number of Logic Levels')};});
}
const workflow=fs.existsSync(p.join(d,'workflow.log'))?read(p.join(d,'workflow.log')):'';
const results={builds:{},pairs:{},definitions:{needed:'Fit-summary logic utilization; cross-check placed A minus recoverable B plus unavailable C.',placed:'Fitter [A] ALMs used in final placement.',registers:'Fit-summary total registers.',MLABcells:'Sum of MLABs in Fitter RAM Summary; MLAB bits reported separately.',tns:'Minimum reported TNS among setup or hold summary groups; full per-group values retained. No summing overlapping timing categories.',percent:'100*(C-A)/A; null when baseline is zero.',routing:'Final average/peak interconnect percentages, total/H/V. Routing ALUTs are separate counters, not additional ALMs.',physicalSynthesis:'Counts of fitter netlist-optimization table entries, not unique physical registers or a causal attribution.'}};
for(const seed of [1,2])for(const variant of ['A','C']){
 const key=`seed${seed}/${variant}`,folder=p.join(d,key),completed={};for(const stage of ['map','fit','asm','sta'])completed[stage]=workflow.includes(`${key} ${stage} ended exit=0`);
 if(!Object.values(completed).every(Boolean)){results.builds[key]={completed,qualified:false,diagnostics:fs.existsSync(p.join(folder,'fit.log'))?read(p.join(folder,'fit.log')).split(/\r?\n/).filter(s=>/Error|failed|Warning/.test(s)).slice(-40):[]};continue;}
 const m=baseMeasure(folder),fit=read(p.join(folder,'output_files/SMS.fit.rpt')),map=read(p.join(folder,'output_files/SMS.map.rpt')),sta=read(p.join(folder,'output_files/SMS.sta.rpt'));
 const n=re=>{const x=fit.match(re);assert(x,re);return +x[1].replaceAll(',','');};
 m.M10K=n(/; M10K blocks\s*;\s*([\d,]+)/);m.MLABbits=n(/Total MLAB memory bits\s*;\s*([\d,]+)/);m.memoryALMs=n(/ALMs used for memory[^;]*;\s*([\d,]+)/);
 const ram=table(fit,'Fitter RAM Summary');m.ramHeader=ram.find(r=>r.includes('M10K blocks')&&r.includes('MLAB cells'));
 assert(m.ramHeader,'RAM table header');const m10=m.ramHeader.indexOf('M10K blocks'),ml=m.ramHeader.indexOf('MLAB cells');
 const ramData=ram.filter(r=>r.length>Math.max(m10,ml)&&/^\d+$/.test(r[m10])&&/^\d+$/.test(r[ml]));m.MLABcells=ramData.reduce((a,r)=>a+Number(r[ml]),0);assert.equal(ramData.reduce((a,r)=>a+Number(r[m10]),0),m.M10K);
 m.setupTNS=Math.min(...m.timing.filter(x=>x.type.startsWith('Setup')).map(x=>x.tns));m.holdTNS=Math.min(...m.timing.filter(x=>x.type.startsWith('Hold')).map(x=>x.tns));
 m.interconnect={};for(const which of ['Average','Peak']){const re=new RegExp(which+' interconnect usage[^\\r\\n]*');const lines=fit.split(/\r?\n/).filter(l=>re.test(l));m.interconnect[which]=lines.map(l=>({raw:l,values:[...l.matchAll(/([\d.]+)%/g)].map(x=>+x[1])}));}
 for(const which of ['Average','Peak']){assert.equal(m.interconnect[which].length,1,'Final '+which+' interconnect row');assert.equal(m.interconnect[which][0].values.length,3);for(const[axis,i]of [['Total',0],['H',1],['V',2]])m[which.toLowerCase()+'Interconnect'+axis]=m.interconnect[which][0].values[i];}
 m.routingResourceRows=fit.split(/\r?\n/).filter(l=>/^;/.test(l)&&/;\s*(?:(?:R\d+|C\d+|Block|Local|Direct link) interconnects|LAB Local Interconnect)\s*;/i.test(l));
 m.congestionLogLines=read(p.join(folder,'fit.log')).split(/\r?\n/).filter(l=>/congestion|interconnect usage|routing utilization/i.test(l));
 m.physicalSynthesis=physical(fit);m.physicalSynthesis.estimates=read(p.join(folder,'fit.log')).split(/\r?\n/).filter(l=>/physical synthesis algorithm|estimated slack improvement|retiming|register duplication/i.test(l));
 m.uninferred=map.split(/\r?\n/).filter(l=>/uninferred RAM|RAM logic .*uninferred/.test(l));
 m.inferredMemoryLines=[...new Set(map.split(/\r?\n/).filter(l=>/Inferred.*(?:RAM|ROM)|implemented as|M10K block|MLAB|RAM logic .*uninferred|Found.*(?:RAM|ROM)/i.test(l)).map(l=>normalize(l).replace(/^\s*\d+\.\s*/,'')))];
 m.memoryReportRows=ramData.map(r=>r.map(normalize));
 m.memoryStructuralRows=m.memoryReportRows.map(r=>r.filter((x,i)=>m.ramHeader[i]!=='Location')).sort((a,b)=>JSON.stringify(a).localeCompare(JSON.stringify(b)));
 m.normalizedWarnings=[...new Set(m.warningLines.map(normalize))].sort();m.criticalWarningLines=m.normalizedWarnings.filter(s=>s.startsWith('Critical'));
 m.normalizedFitterSettings=table(fit,'Fitter Settings').map(r=>r.map(normalize));
 m.constraintCoverage=sta.split(/\r?\n/).filter(l=>/not fully constrained|unconstrained paths|operating conditions|Slow [\d]|Fast [\d]/i.test(l));
 m.reportHashes=Object.fromEntries(fs.readdirSync(p.join(folder,'output_files')).filter(f=>/\.(rpt|summary)$/.test(f)).map(f=>[f,sha(p.join(folder,'output_files',f))]));
 m.rbf=fs.existsSync(p.join(folder,'output_files/SMS.rbf'))?{bytes:fs.statSync(p.join(folder,'output_files/SMS.rbf')).size,SHA256:sha(p.join(folder,'output_files/SMS.rbf'))}:null;
 m.completed=completed;m.qualified=m.violations===0&&m.setup>0&&m.hold>0;results.builds[key]=m;
 m.physicalPaths={setup:paths(p.join(folder,'physical_setup.rpt'),'Setup'),hold:paths(p.join(folder,'physical_hold.rpt'),'Hold'),note:'Additional read-only full-path query uses the inherited slow timing model; STA summary remains the acceptance metric.'};
}
const keys=['needed','placed','registers','synthesisRegisters','M10K','MLABcells','MLABbits','memoryALMs','memoryBits','DSP','logicALUT','routingALUT','setup','hold','setupTNS','holdTNS','averageInterconnectTotal','averageInterconnectH','averageInterconnectV','peakInterconnectTotal','peakInterconnectH','peakInterconnectV'];
for(const seed of [1,2]){
 const a=results.builds[`seed${seed}/A`],c=results.builds[`seed${seed}/C`];if(!a.timing||!c.timing){results.pairs[seed]={complete:false};continue;}
 const deltas={};for(const k of keys)deltas[k]={A:a[k],C:c[k],absolute:+(c[k]-a[k]).toFixed(6),percent:a[k]===0?null:+(100*(c[k]-a[k])/a[k]).toFixed(6)};
 const equality=(x,y)=>JSON.stringify(x)===JSON.stringify(y);
 results.pairs[seed]={complete:true,qualified:a.qualified&&c.qualified,deltas,warnings:{added:c.normalizedWarnings.filter(x=>!a.normalizedWarnings.includes(x)),removed:a.normalizedWarnings.filter(x=>!c.normalizedWarnings.includes(x))},inferredMemory:{added:c.inferredMemoryLines.filter(x=>!a.inferredMemoryLines.includes(x)),removed:a.inferredMemoryLines.filter(x=>!c.inferredMemoryLines.includes(x)),fittedRamTableEqual:equality(a.memoryReportRows,c.memoryReportRows),fittedRamStructureEqual:equality(a.memoryStructuralRows,c.memoryStructuralRows)},fitterSettingDifferences:{onlyA:a.normalizedFitterSettings.filter(x=>!c.normalizedFitterSettings.some(y=>equality(x,y))),onlyC:c.normalizedFitterSettings.filter(x=>!a.normalizedFitterSettings.some(y=>equality(x,y)))}};
}
if(results.pairs[1].complete&&results.pairs[2].complete){results.consistency={metrics:{},note:'Two paired seeds describe observed layout sensitivity; no statistical confidence or invariant per-feature cost is claimed.'};for(const k of keys){const a=results.pairs[1].deltas[k],b=results.pairs[2].deltas[k];results.consistency.metrics[k]={absolute:[a.absolute,b.absolute],percent:[a.percent,b.percent],sameSign:Math.sign(a.absolute)===Math.sign(b.absolute)};}results.consistency.mappedRegistersEqualAcrossSeeds={A:results.builds['seed1/A'].synthesisRegisters===results.builds['seed2/A'].synthesisRegisters,C:results.builds['seed1/C'].synthesisRegisters===results.builds['seed2/C'].synthesisRegisters};}
fs.writeFileSync(p.join(d,'results.json'),JSON.stringify(results,null,2)+'\n');
let tableOut='';for(const seed of [1,2]){tableOut+=`## Seed ${seed}\n\n| Metric | Master | C | Delta | Delta % |\n| --- | ---: | ---: | ---: | ---: |\n`;const pair=results.pairs[seed];if(pair.complete)for(const k of keys){const x=pair.deltas[k];tableOut+=`| ${k} | ${x.A} | ${x.C} | ${x.absolute>=0?'+':''}${x.absolute} | ${x.percent===null?'n/a':(x.percent>=0?'+':'')+x.percent.toFixed(2)+'%'} |\n`;}else tableOut+='| Incomplete | — | — | — | — |\n';tableOut+='\n';}
fs.writeFileSync(p.join(d,'comparison_table.md'),tableOut);console.log(JSON.stringify({pairs:results.pairs},null,2));
