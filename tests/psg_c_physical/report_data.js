const fs=require('fs'),p=require('path'),d=__dirname,r=JSON.parse(fs.readFileSync(p.join(d,'results.json')));
const labels={needed:'Needed ALMs',placed:'Placed ALMs',registers:'Fitted registers',synthesisRegisters:'Mapped registers',M10K:'M10K blocks',MLABcells:'MLAB cells',MLABbits:'MLAB memory bits',memoryBits:'Logical block-memory bits',DSP:'DSP blocks',logicALUT:'Logic ALUTs',routingALUT:'Routing ALUTs',setup:'Setup slack (ns)',hold:'Hold slack (ns)',setupTNS:'Setup TNS (ns)',holdTNS:'Hold TNS (ns)'};
const fmt=(x,k)=>Number.isInteger(x)&&!['setup','hold','setupTNS','holdTNS'].includes(k)?x.toLocaleString('en-US'):x.toFixed(3);
const delta=(x,k)=>(x>=0?'+':'')+fmt(x,k),pct=x=>x===null?'n/a':(x>=0?'+':'')+x.toFixed(2)+'%';
let s='';for(const seed of [1,2]){
 const pair=r.pairs[seed];s+=`## Seed ${seed}\n\n`;if(!pair.complete){s+='Incomplete.\n\n';continue;}
 s+='| Metric | Master | C | C − master | Relative delta |\n| --- | ---: | ---: | ---: | ---: |\n';
 for(const[k,label]of Object.entries(labels)){const x=pair.deltas[k];s+=`| ${label} | ${fmt(x.A,k)} | ${fmt(x.C,k)} | ${delta(x.absolute,k)} | ${pct(x.percent)} |\n`;}
 s+='\n| Final interconnect (%) | Master | C | Delta (percentage points) | Relative delta |\n| --- | ---: | ---: | ---: | ---: |\n';
 for(const what of ['average','peak'])for(const axis of ['Total','H','V']){const x=pair.deltas[what+'Interconnect'+axis];s+=`| ${what==='average'?'Average':'Peak'} ${axis} | ${x.A.toFixed(1)} | ${x.C.toFixed(1)} | ${x.absolute>=0?'+':''}${x.absolute.toFixed(1)} | ${pct(x.percent)} |\n`;}
 const a=r.builds[`seed${seed}/A`],c=r.builds[`seed${seed}/C`];
 s+='\n| Physical-synthesis observation | Master | C | Delta | Relative delta |\n| --- | ---: | ---: | ---: | ---: |\n';
 for(const[k,label]of [['total','Retimed-register table entries'],['scaler','Scaler retimed-register entries'],['luminance','Luminance retimed-register entries']]){const x=a.physicalSynthesis.retimed[k],y=c.physicalSynthesis.retimed[k];s+=`| ${label} | ${x} | ${y} | ${y-x>=0?'+':''}${y-x} | ${pct(x===0?null:100*(y-x)/x)} |\n`;}
 const ag=a.registers-a.synthesisRegisters,cg=c.registers-c.synthesisRegisters;s+=`| Fitted minus mapped register count | ${ag} | ${cg} | ${cg-ag>=0?'+':''}${cg-ag} | ${pct(ag===0?null:100*(cg-ag)/ag)} |\n`;
 s+=`\nNew normalized warnings: **${pair.warnings.added.length}**; removed: **${pair.warnings.removed.length}**. Critical warning messages: master **${a.criticalWarnings}**, C **${c.criticalWarnings}**. RAM structure unchanged: **${pair.inferredMemory.fittedRamStructureEqual}**. Actual fitter-setting differences: **${pair.fitterSettingDifferences.onlyA.length+pair.fitterSettingDifferences.onlyC.length}**.\n\n`;
}
s+='Percentages use the matched master as denominator. n/a means the denominator is zero. Interconnect absolute deltas are percentage points. TNS is the worst reported setup/hold-group TNS; full groups are retained in results.json. Physical-synthesis counts are report entries, not unique register counts.\n';
fs.writeFileSync(p.join(d,'measurements.md'),s);
console.log('Wrote human-readable paired measurements');
