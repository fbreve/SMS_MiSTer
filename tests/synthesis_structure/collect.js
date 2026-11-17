// Read-only evidence collector. Run from repository root: node tests/synthesis_structure/collect.js
const fs=require('fs'),path=require('path'),cp=require('child_process'),crypto=require('crypto');
const out='tests/synthesis_structure', build='tests/timing_history/builds/F';
const read=p=>fs.readFileSync(p,'utf8'), norm=s=>s.replace(/\r\n/g,'\n');
const git=(...a)=>cp.execFileSync('git',a,{encoding:'utf8'}).trim();
const hash=p=>crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
const write=(n,v)=>fs.writeFileSync(`${out}/${n}`,JSON.stringify(v,null,2)+'\n');
const walk=p=>fs.readdirSync(p,{withFileTypes:true}).flatMap(e=>e.isDirectory()?walk(path.join(p,e.name)):[path.join(p,e.name).replace(/\\/g,'/')]);
const refs=Object.fromEntries(['master','investigate/cram-memory-inference','investigate/synthesis-structure'].map(r=>[r,git('rev-parse',r)]));
const proof=JSON.parse(read('tests/current_savestate_resource_cost/source_verification.json'));
const inputs=proof.source.map(x=>{const p=x.file;return {file:p,baselineBlob:git('rev-parse',`8443a0d:${p}`),workingMatch:norm(read(p))===norm(cp.execFileSync('git',['show',`8443a0d:${p}`],{encoding:'utf8'})),retainedMatch:norm(read(p))===norm(read(`${build}/${p}`)),sha256:hash(`${build}/${p}`)};});
write('provenance.json',{baseline:git('rev-parse','HEAD'),branch:git('branch','--show-current'),refs,inputs,tool:cp.execFileSync('C:/intelFPGA_lite/17.0/quartus/bin64/quartus_sh.exe',['--version'],{encoding:'utf8'}),reports:walk(build+'/output_files').filter(p=>/\.(rpt|summary)$/.test(p)).map(p=>({file:p,sha256:hash(p)}))});
const files=git('ls-files').split('\n').filter(p=>/\.(vhd|v|sv)$/.test(p));
const declarations=[],arithmetic=[];
for(const p of files){read(p).split(/\r?\n/).forEach((s,i)=>{if(/type\s+\w+\s+is\s+array|\b(?:reg|logic)\b.*\[[^\]]+\]\s*\w+\s*\[|ramstyle|ram_block_type/i.test(s))declarations.push({file:p,line:i+1,text:s.trim()});const code=s.replace(/--.*$|\/\/.*$/g,'');if(/\bmod\b|\brem\b|\s[*/]\s|\b(?:signed|unsigned)\s*\(/i.test(code))arithmetic.push({file:p,line:i+1,text:code.trim()});});}
write('declarations.json',declarations);write('arithmetic_scan.json',arithmetic);
const sections=[['SMS.map.rpt','Analysis & Synthesis RAM Summary'],['SMS.map.rpt','Analysis & Synthesis DSP Block Usage Summary'],['SMS.fit.rpt','Non-Global High Fan-Out Signals'],['SMS.fit.rpt','Fitter RAM Summary']];
let excerpts=[];
for(const [f,title] of sections){const lines=read(`${build}/output_files/${f}`).split(/\r?\n/);const start=lines.findIndex(s=>s.trim().startsWith('; '+title));if(start>=0){let end=start+1;while(end<lines.length&&!(lines[end]===''&&end>start+4))end++;excerpts.push({file:f,title,line:start+1,lines:lines.slice(start,end)});}}
write('report_sections.json',excerpts);
const fitLines=read(`${build}/output_files/SMS.fit.rpt`).split(/\r?\n/);
const ramSection=excerpts.find(x=>x.title==='Fitter RAM Summary');
const ramRows=ramSection.lines.filter(s=>/^;/.test(s)).map(s=>s.split(';').slice(1,-1).map(x=>x.trim()));
write('fitted_ram.json',ramRows);
const metrics=read('tests/timing_history/metrics.csv').trim().split(/\r?\n/).map(s=>s.split(',').map(x=>x.replace(/^"|"$/g,'')));
const baselineMetrics=Object.fromEntries(metrics[0].map((k,i)=>[k,metrics.find(x=>x[0]==='F')[i]]));
write('baseline_metrics.json',{historical:baselineMetrics,allocatedM10kCapacityBits:487*10240,fittedMemoryTotals:ramRows.filter(r=>r.length>20&&/^\d+$/.test(r[18])).reduce((a,r)=>({m10ks:a.m10ks+Number(r[18]),mlabs:a.mlabs+Number(r[19]),configuredBits:a.configuredBits+Number(r[17])}),{m10ks:0,mlabs:0,configuredBits:0})});
write('ram_diagnostics.json',read(`${build}/output_files/SMS.map.rpt`).split(/\r?\n/).flatMap((s,i)=>/uninferred RAM|RAM logic .*uninferred/.test(s)?[{line:i+1,text:s}]:[]));
write('timing_summary.json',{summary:read(`${build}/output_files/SMS.sta.summary`),setupTop:read(`${build}/output_files/audit_setup_paths.rpt`).split(/\r?\n/).filter(s=>/^; 0\.508 ;/.test(s)),holdTop:read(`${build}/output_files/audit_hold_paths.rpt`).split(/\r?\n/).filter(s=>/^; 0\.144 ;/.test(s))});
let hierarchy=[],messages=[],settings=[];
for(const f of ['SMS.map.rpt','SMS.fit.rpt','SMS.sta.rpt']){read(`${build}/output_files/${f}`).split(/\r?\n/).forEach((s,i)=>{if(/^;/.test(s)&&/\|sys_top\|/.test(s)&&/;\s*work\s*;/.test(s))hierarchy.push({report:f,line:i+1,cells:s.split(';').slice(1,-1).map(x=>x.trim())});if(/\b(?:Critical Warning|Warning|Error)\s*\(\d+\)|inferred latch|combinational loop/i.test(s))messages.push({report:f,line:i+1,text:s.trim()});if(/^;/.test(s)&&/MLAB|memory ALMs|ALMs used for memory|Device\s*;|Seed\s*;|BUILD_DATE|MISTER_FB|Fitter Effort|Optimization Technique|Register Packing|Final Placement|Performance Effort|Register Duplication|Total DSP|Total registers|Logic utilization|Total block memory|Total M10K/i.test(s))settings.push({report:f,line:i+1,text:s.trim()});});}
write('hierarchy.json',hierarchy);write('messages.json',messages);write('settings.json',settings.filter(x=>x.text.length<700));
const retained=walk(out).filter(p=>p!==out+'/preservation.json').map(p=>({file:p,sha256:hash(p)}));
write('preservation.json',{refs,trackedDiff:git('diff','--stat'),evidence:retained});
console.log(JSON.stringify({inputs:inputs.length,mismatches:inputs.filter(x=>!x.workingMatch||!x.retainedMatch),declarations:declarations.length,arithmetic:arithmetic.length,hierarchy:hierarchy.length,messages:messages.length,sections:excerpts.map(x=>[x.title,x.line])},null,2));
