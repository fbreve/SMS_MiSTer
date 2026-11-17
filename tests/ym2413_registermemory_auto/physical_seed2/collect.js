const fs=require('fs'),p=require('path'),crypto=require('crypto'),assert=require('assert'),d=__dirname;
const inputs=JSON.parse(fs.readFileSync(p.join(d,'inputs.json'))),workflow=read(p.join(d,'workflow.log'));
function read(f){const b=fs.readFileSync(f);return b.toString(b[0]===255&&b[1]===254?'utf16le':'utf8');}
const sha=f=>crypto.createHash('sha256').update(fs.readFileSync(f)).digest('hex');
const rows=s=>s.split(/\r?\n/).filter(x=>x.startsWith(';')).map(x=>x.split(';').slice(1,-1).map(v=>v.trim()));
function table(s,title){const i=s.indexOf('; '+title+' ');if(i<0)return[];const lines=s.slice(i).split(/\r?\n/);let stop=lines.findIndex((x,j)=>j>3&&!x.trim());if(stop<0)stop=lines.length;return rows(lines.slice(0,stop).join('\n'));}
const normalize=s=>s.replace(/Z:[\\/](?:baseline|candidate)[\\/]/gi,'<BUILD>/').replace(/\bLine: \d+/g,'Line: <N>').replace(/(\.(?:vhd|sv|v))\(\d+\)/g,'$1(<N>)');
function paths(file,kind){if(!fs.existsSync(file))return[];return read(file).split(new RegExp('Path #\\d+: '+kind+' slack is ')).slice(1).map(s=>{const r=rows(s),get=n=>(r.find(x=>x[0]===n)||[]).slice(1);return{slack:+s.split(/\s/)[0],from:get('From Node')[0],to:get('To Node')[0],launch:get('Launch Clock')[0],latch:get('Latch Clock')[0],dataDelay:get('Data Delay')[0],skew:get('Clock Skew')[0],logicLevels:get('Number of Logic Levels')};});}
function measure(v){
 const dir=p.join(d,v),out=p.join(dir,'output_files'),status={};for(const stage of ['map','fit','asm','sta'])status[stage]=workflow.includes(`${v} ${stage} ended exit=0`);
 if(!Object.values(status).every(Boolean))return{complete:false,status};
 const fit=read(p.join(out,'SMS.fit.rpt')),summary=read(p.join(out,'SMS.fit.summary')),map=read(p.join(out,'SMS.map.rpt')),ms=read(p.join(out,'SMS.map.summary')),sta=read(p.join(out,'SMS.sta.rpt')),ss=read(p.join(out,'SMS.sta.summary'));
 const n=(re,s=fit)=>{const m=s.match(re);assert(m,'missing '+v+' '+re);return +m[1].replaceAll(',','');};
 const m={complete:true,status,neededALMs:n(/Logic utilization[^:]*:\s*([\d,]+)/,summary),placedALMs:n(/\[A\] ALMs used in final placement[^;]*;\s*([\d,]+)/),recoverableALMs:n(/\[B\] Estimate of ALMs recoverable[^;]*;\s*([\d,]+)/),unavailableALMs:n(/\[C\] Estimate of ALMs unavailable[^;]*;\s*([\d,]+)/),fittedRegisters:n(/Total registers\s*:\s*([\d,]+)/,summary),mappedRegisters:n(/Total registers\s*:\s*([\d,]+)/,ms),M10K:n(/; M10K blocks\s*;\s*([\d,]+)/),memoryBits:n(/Total block memory bits\s*:\s*([\d,]+)/,summary),MLABbits:n(/Total MLAB memory bits\s*;\s*([\d,]+)/),memoryALMs:n(/ALMs used for memory[^;]*;\s*([\d,]+)/),DSP:n(/Total DSP Blocks\s*:\s*([\d,]+)/,summary),logicALUTs:n(/Combinational ALUT usage for logic\s*;\s*([\d,]+)/),routingALUTs:n(/Combinational ALUT usage for route-throughs\s*;\s*([\d,]+)/)};
 assert(summary.includes('17.0.2 Build 602')&&summary.includes('Device : 5CSEBA6U23I7')&&summary.includes('Top-level Entity Name : sys_top'),'Actual build configuration '+v);
 assert.equal(m.placedALMs-m.recoverableALMs+m.unavailableALMs,m.neededALMs);
 m.timing=[...ss.matchAll(/Type\s*:\s*([^\r\n]+)\r?\nSlack\s*:\s*(-?[\d.]+)\r?\nTNS\s*:\s*(-?[\d.]+)/g)].map(x=>({type:x[1],slack:+x[2],tns:+x[3]}));assert(m.timing.length);
 const timing=type=>m.timing.filter(x=>x.type.startsWith(type));
 m.setupSlack=Math.min(...timing('Setup').map(x=>x.slack));m.setupTNS=Math.min(...timing('Setup').map(x=>x.tns));m.setupTNSDistinctGroups=timing('Setup').reduce((s,x)=>s+x.tns,0);
 m.holdSlack=Math.min(...timing('Hold').map(x=>x.slack));m.holdTNS=Math.min(...timing('Hold').map(x=>x.tns));m.violations=m.timing.filter(x=>x.slack<0||x.tns<0);
 const reports=fs.readdirSync(out).filter(f=>/\.(rpt|summary)$/.test(f)),messages=reports.map(f=>read(p.join(out,f))).join('\n');
 m.warnings=[...new Set(messages.split(/\r?\n/).map(x=>x.trim()).filter(x=>/^(Critical )?Warning(?: \(\d+\))?:/.test(x)))];
 m.normalizedWarnings=[...new Set(m.warnings.map(normalize))].sort();m.warningCounts={total:m.warnings.length,critical:m.warnings.filter(x=>x.startsWith('Critical')).length};
 m.warningReview={latches:m.warnings.filter(x=>/latch/i.test(x)),multipleDrivers:m.warnings.filter(x=>/multiple.*driver|multi.*driver|more than one.*driver|multiple.*constant.*driver/i.test(x)),widths:m.warnings.filter(x=>/truncat|width|size mismatch|port.*size|different.*size/i.test(x)),ram:m.warnings.filter(x=>/RAM|read.during.write|memory/i.test(x))};
 m.inferredLatchLines=map.split(/\r?\n/).filter(x=>/inferred.*latch|latches inferred|latch.*inferred/i.test(x));
 m.sources=table(map,'Analysis & Synthesis Source Files Read').filter(x=>x.length>=4&&/\.(vhd|sv|v)$/i.test(x[0])).map(x=>({path:x[0].replace(/\\/g,'/'),used:x[1],type:x[2],absolute:x[3]}));
 const expected=inputs.sourceDifferences.filter(f=>/\.(vhd|sv|v)$/.test(f));
 m.reviewedSourceInclusion=expected.filter(f=>f!=='rtl/opll_snapshot.sv'||v==='candidate').map(f=>({path:f,record:m.sources.find(s=>s.path.toLowerCase()===f.toLowerCase())||null}));
 assert(m.reviewedSourceInclusion.every(x=>x.record&&x.record.used==='yes'),'Reviewed source absent or unused '+v);
 const baseRoot=p.join(d,v),expectedAssignments=new Set();
 for(const f of Object.keys(inputs.builds[v].inputs).filter(f=>f==='files.qip'||/^rtl\/.+\.qip$/i.test(f))){const q=read(p.join(baseRoot,f));
  for(const x of q.matchAll(/set_global_assignment[^\r\n]*? -name (?:VHDL_FILE|VERILOG_FILE|SYSTEMVERILOG_FILE)\s+([^\r\n]+)/g)){
   const simple=x[1].trim();if(/^rtl\//.test(simple)||simple==='SMS.sv')expectedAssignments.add(simple);
   else {const z=simple.match(/^\[file join \$::quartus\(qip_path\)\s+([^\] ]+)\s*\]/);if(z)expectedAssignments.add(p.posix.join(p.posix.dirname(f),z[1].replace(/^["{]|["}]$/g,'')));}
  }
 }
 const parsedEvidence=f=>map.split(/\r?\n/).filter(line=>/Info \(1202[123]\)/.test(line)&&(line.includes('source file '+f)||line.toLowerCase().includes('/'+f.toLowerCase()+' line:'))).map(x=>x.trim());
 m.coreAssignmentInclusion=[...expectedAssignments].sort().map(f=>({path:f,record:m.sources.find(s=>s.path.toLowerCase()===f.toLowerCase())||null,parsedEvidence:parsedEvidence(f)}));
 assert(m.coreAssignmentInclusion.every(x=>x.record||x.parsedEvidence.length),'Core RTL assignment not parsed '+v+': '+m.coreAssignmentInclusion.filter(x=>!x.record&&!x.parsedEvidence.length).map(x=>x.path).join(', '));
 const declared=p.join(dir,'declared_rtl.txt');
 if(fs.existsSync(declared)){
  m.expandedRTL=read(declared).trim().split(/\r?\n/).map(line=>line.split('\t')[1]?.replace(/\\/g,'/')).filter(Boolean);
  assert(m.expandedRTL.length>0,'Empty expanded source declarations '+v);
  m.expandedRTLInclusion=m.expandedRTL.map(f=>{const relative=f.replace(/^Z:\/(?:baseline|candidate)\//i,'');return{path:f,record:m.sources.find(s=>s.path.toLowerCase()===f.toLowerCase()||s.absolute.toLowerCase()===f.toLowerCase()||s.absolute.toLowerCase().endsWith('/'+f.toLowerCase()))||null,parsedEvidence:parsedEvidence(relative)};});
  assert(m.expandedRTLInclusion.every(x=>x.record||x.parsedEvidence.length),'Expanded Quartus RTL assignment not parsed '+v+': '+m.expandedRTLInclusion.filter(x=>!x.record&&!x.parsedEvidence.length).map(x=>x.path).join(', '));
 }
 const ram=table(fit,'Fitter RAM Summary'),header=ram.find(x=>x.includes('M10K blocks')&&x.includes('MLAB cells'));assert(header,'RAM header');
 const m10=header.indexOf('M10K blocks'),ml=header.indexOf('MLAB cells');m.ramHeader=header;
 m.ramRows=ram.filter(x=>x.length>Math.max(m10,ml)&&/^\d+$/.test(x[m10])&&/^\d+$/.test(x[ml]));m.MLABcells=m.ramRows.reduce((sum,x)=>sum+ +x[ml],0);
 assert.equal(m.ramRows.reduce((sum,x)=>sum+ +x[m10],0),m.M10K);
 m.fmRamRows=m.ramRows.filter(x=>/opll:fm|fm_snapshot/i.test(x[0]));
 m.phaseRamRows=m.ramRows.filter(x=>/PhaseMemory:MEM|phase_array/i.test(x[0]));m.snapshotRamRows=m.ramRows.filter(x=>/fm_snapshot/i.test(x[0]));
 m.fmMemoryImplementations=m.fmRamRows.map(row=>Object.fromEntries(header.map((name,i)=>[name,row[i]]).filter(([name])=>name!=='Location')));
 m.synthesisRAM=table(map,'RAM Summary');
 m.phaseInference=map.split(/\r?\n/).filter(x=>/phase_array|PhaseMemory:MEM/i.test(x)&&/Info \(|;.*(?:ALTSYNCRAM|Simple Dual Port|RAM|AUTO)/.test(x));
 m.snapshotInference=map.split(/\r?\n/).filter(x=>/fm_snapshot/i.test(x)&&/Info \(|;.*(?:ALTSYNCRAM|Simple Dual Port|RAM|M10K)/.test(x));
 m.fitterSettings=table(fit,'Fitter Settings').map(x=>x.map(normalize));
 if(fs.existsSync(p.join(dir,'expanded_settings.txt')))m.expandedSettings=read(p.join(dir,'expanded_settings.txt')).trim().split(/\r?\n/).map(normalize).sort();
 m.actualSeed=m.fitterSettings.find(x=>x[0]==='Fitter Initial Placement Seed');assert(m.actualSeed&&m.actualSeed[1]===String(inputs.seed),'Wrong actual seed '+v);
 m.interconnect={};for(const kind of ['Average','Peak']){const line=fit.split(/\r?\n/).filter(x=>new RegExp(kind+' interconnect usage').test(x));m.interconnect[kind]={raw:line,percent:line.flatMap(x=>[...x.matchAll(/([\d.]+)%/g)].map(y=>+y[1]))};}
 m.utilizationRows=table(fit,'Fitter Resource Usage Summary');
 m.fmHierarchyRows=rows(fit).filter(x=>/opll:fm|fm_snapshot|PhaseMemory:MEM/.test(x.join(' '))&&/;\s*(?:opll|opll_snapshot|PhaseMemory)\s*;/.test(';'+x.join(';')+';'));
 const entities=table(fit,'Fitter Resource Utilization by Entity');
 m.entityHeader=entities.find(x=>x.includes('Compilation Hierarchy Node'))||entities.find(x=>x.some(v=>/Logic utilization|ALMs needed/i.test(v)))||[];
 m.phaseEntityRows=entities.filter(x=>x.some(v=>v==='PhaseMemory'));
 m.paths={setup:paths(p.join(dir,'physical_setup.rpt'),'Setup'),hold:paths(p.join(dir,'physical_hold.rpt'),'Hold')};
 for(const kind of ['fm','phase','snapshot'])for(const direction of ['from','to'])m.paths[kind+'_'+direction]=paths(p.join(dir,`physical_${kind}_${direction}.rpt`),'Setup');
 m.pathFiles=fs.readdirSync(dir).filter(f=>/^physical_.*\.rpt$/.test(f));
 m.unconstrained=sta.split(/\r?\n/).filter(x=>/not fully constrained|unconstrained paths/i.test(x));
 m.reportHashes=Object.fromEntries(reports.map(f=>[f,sha(p.join(out,f))]));
 m.rbf={path:`${v}/output_files/SMS.rbf`,bytes:fs.statSync(p.join(out,'SMS.rbf')).size,SHA256:sha(p.join(out,'SMS.rbf'))};
 m.qualifiedConstrainedTiming=m.violations.length===0&&m.setupSlack>=0&&m.holdSlack>=0;
 return m;
}
const results={identity:{baseline:inputs.baseline,candidate:inputs.candidate,version:inputs.version,device:inputs.device,seed:inputs.seed,buildDate:inputs.buildDate},builds:{baseline:JSON.parse(fs.readFileSync(p.resolve(d,'../../ym2413_v19_fullstate/physical_seed2/results.json'))).builds.candidate,candidate:measure('candidate')}};
const a=results.builds.baseline,b=results.builds.candidate;
if(a.complete&&b.complete){
 const metrics=['neededALMs','placedALMs','recoverableALMs','unavailableALMs','fittedRegisters','mappedRegisters','M10K','memoryBits','MLABbits','MLABcells','memoryALMs','DSP','logicALUTs','routingALUTs','setupSlack','setupTNS','holdSlack','holdTNS'];
 results.deltas=Object.fromEntries(metrics.map(k=>[k,{baseline:a[k],candidate:b[k],delta:+(b[k]-a[k]).toFixed(6),percent:a[k]===0?null:+(100*(b[k]-a[k])/a[k]).toFixed(4)}]));
 results.warnings={added:b.normalizedWarnings.filter(x=>!a.normalizedWarnings.includes(x)),removed:a.normalizedWarnings.filter(x=>!b.normalizedWarnings.includes(x))};
 results.fitterSettingDifferences={onlyBaseline:a.fitterSettings.filter(x=>!b.fitterSettings.some(y=>JSON.stringify(x)===JSON.stringify(y))),onlyCandidate:b.fitterSettings.filter(x=>!a.fitterSettings.some(y=>JSON.stringify(x)===JSON.stringify(y)))};
 results.phaseMemory={baseline:a.phaseRamRows,candidate:b.phaseRamRows};
 if(a.expandedSettings&&b.expandedSettings)results.expandedSettingDifferences={onlyBaseline:a.expandedSettings.filter(x=>!b.expandedSettings.includes(x)),onlyCandidate:b.expandedSettings.filter(x=>!a.expandedSettings.includes(x))};
}
fs.writeFileSync(p.join(d,'results.json'),JSON.stringify(results,null,2)+'\n');
console.log(JSON.stringify({complete:a.complete&&b.complete,deltas:results.deltas,warnings:results.warnings,phaseMemory:results.phaseMemory},null,2));
