const fs=require('fs'),path=require('path'),crypto=require('crypto'),cp=require('child_process'),d=__dirname,r=path.resolve(d,'../..');
const read=p=>{const b=fs.readFileSync(p);return b.toString(b[0]===255&&b[1]===254?'utf16le':'utf8').replace(/^\uFEFF/,'');};
const sha=p=>crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
const git=(...a)=>cp.execFileSync('git',a,{cwd:r,encoding:'utf8',stdio:['ignore','pipe','pipe']}).trimEnd();
const expected=[];const add=(name,marker='PASS FIXED')=>expected.push({name,marker});
const fixed=(c,s=0,f=0,o=0,delay=6)=>add(`fixed_case${c}_stall${s}_full${f}_offset${o}_delay${delay}.log`);
for(const c of [0,1,2,3,4,5,6,7,8,9,20,21,22,23,24])fixed(c);
for(let k=0;k<14;k++)fixed(16,0,0,0,6+10*k);
for(let s=1;s<4;s++)for(const c of [1,3,4,7,8,9])fixed(c,s);
for(const c of [1,4])fixed(c,0,1);
for(let o=0;o<6;o++)fixed(10,0,0,o);
for(let o=0;o<4;o++)fixed(18,0,0,o);
for(let o=0;o<2;o++)fixed(11,0,0,o);
for(const c of [14,15])fixed(c);
for(const c of [1,3,4,7,8])add(`red_case${c}.log`,'PASS case');
add('boundary.log','PASS BOUNDARY cases1600');
for(const n of ['f07_controller','f07_systeme','f02_direct','f02_ddr0','f02_ddr1','f08_real','f08_ddr','f09_short','f09_real','f09_ordinary','f09_ddr','f10_directed','f10_phases','f10_modes','f10_ordinary','f10_ddr','f10_case22','f10_case23','f10_case24','f10_case25','f03_direct','f03_ddr','f03_persistence','f05_ddr','f05_controls','f05_persistence','f11_direct','f11_cpu0','f11_cpu3','f11_order0','f11_order1','format0','format1','format2','format3','psg'])add(`reg_${n}.log`,'PASS');
const missing=[],tests={},scenarios=[];
for(const {name,marker}of expected){
 const p=path.join(d,name);if(!fs.existsSync(p)){missing.push(name+': missing');continue;}
 const s=read(p);if(!s.includes(marker)||/\*\* (Error|Fatal|Failure)|Errors: [1-9]/.test(s)||!s.includes('Errors: 0')){missing.push(name+': incomplete/failing');continue;}
 tests[name]={sha256:sha(p),marker};
 if(name.startsWith('fixed')){
  const summary=s.match(/PASS FIXED case(\d+) stall(\d+) full(\d+) delay(\d+) offset(\d+) accepts(\d+) transfers(\d+) checks(\d+) worstLatency(\d+) overrideCPU(\d+) overridePSG(\d+)/);
  if(!summary)throw Error('Missing scenario summary '+name);
  const keys=['case','stall','full','delay','offset','accepts','transfers','checks','worstLatency','overrideCPU','overridePSG'];
  scenarios.push({log:name,...Object.fromEntries(keys.map((k,i)=>[k,+summary[i+1]])),transport:[...s.matchAll(/RELEASE .*?transport(\d+)/g)].map(m=>+m[1])});
 }
}
const diffNames=git('diff','--name-only').split(/\r?\n/).filter(Boolean);
if(diffNames.some(p=>!['SMS.sv','rtl/savestates.sv'].includes(p)))throw Error('Out-of-scope production change');
if(git('diff','--cached','--name-only'))throw Error('Unexpected staged files');
const prod=read(path.join(r,'rtl/savestates.sv')),base=read(path.join(d,'baseline/savestates.sv'));
const versions=s=>s.split(/\r?\n/).filter(l=>/48430[1-9]|GUN_DESCRIPTOR|GUN_EXT_MAGIC|NEW_SS_WORDS|SLOT_STRIDE/.test(l)).map(l=>l.trim()).join('\n');
if(versions(prod)!==versions(base)||/\bse_paused\b|\bse_pause_pending\b|\bse_unpause_pending\b/.test(prod))throw Error('Unexpected format/UI serialization change');
const sourceHashes=Object.fromEntries(['SMS.sv','rtl/savestates.sv'].map(p=>[p,sha(path.join(r,p))]));
const simulation={base:git('rev-parse','HEAD'),branch:git('branch','--show-current'),sourceHashes,expectedLogs:expected.length,completedLogs:Object.keys(tests).length,missing,tests,scenarios,processBoundaryCases:1600,worstCaptureLatency:Math.max(0,...scenarios.map(s=>s.worstLatency)),worstPausedProgressCPU:Math.max(0,...scenarios.filter(s=>s.case===16).map(s=>s.overrideCPU)),worstPausedProgressPSG:Math.max(0,...scenarios.filter(s=>s.case===16).map(s=>s.overridePSG)),format:'v8 unchanged',serialization:'No host pause payload'};
fs.writeFileSync(path.join(d,'simulation_results.json'),JSON.stringify(simulation,null,2)+'\n');
console.log(JSON.stringify({completed:simulation.completedLogs,expected:expected.length,missing,worstCaptureLatency:simulation.worstCaptureLatency,worstPausedProgressCPU:simulation.worstPausedProgressCPU,worstPausedProgressPSG:simulation.worstPausedProgressPSG},null,2));
if(missing.length)process.exit(1);
if(scenarios.length!==63||scenarios.some(s=>s.worstLatency>1800000))throw Error('Scenario count/capture bound');
if(process.argv.includes('--sim-only'))process.exit(0);
const build=path.join(d,'candidate'),sources=JSON.parse(read(path.join(d,'build_sources.json')));
for(const[p,h]of Object.entries(sources))if(sha(path.join(r,p))!==h||sha(path.join(build,p))!==h)throw Error('Stale build source '+p);
const log=read(path.join(build,'compile.log')),fit=read(path.join(build,'output_files/SMS.fit.summary')),sta=read(path.join(build,'output_files/SMS.sta.summary'));
if(!log.includes('Full Compilation was successful')||!fit.includes('Fitter Status : Successful'))throw Error('Full Quartus compile incomplete');
const val=n=>{const m=fit.match(new RegExp(n+'[^:\\r\\n]*:\\s*([\\d,]+)'));if(!m)throw Error(n);return +m[1].replaceAll(',','');};
const timing=[...sta.matchAll(/Type\s*:\s*([^\r\n]+)\r?\nSlack\s*:\s*(-?[\d.]+)\r?\nTNS\s*:\s*(-?[\d.]+)/g)].map(m=>({type:m[1],slack:+m[2],tns:+m[3]}));
if(!timing.length)throw Error('Missing timing analysis');
const candidate={alms:val('Logic utilization'),registers:val('Total registers'),memoryBits:val('Total block memory bits'),ramBlocks:val('Total RAM Blocks'),dspBlocks:val('Total DSP Blocks'),timing};
candidate.synthesisRegisters=+read(path.join(build,'output_files/SMS.map.summary')).match(/Total registers\s*:\s*([\d,]+)/)[1].replaceAll(',','');
const baseline=JSON.parse(read(path.join(d,'baseline.json')));
const norm=l=>l.trim().replace(/ File:.*$/,'').replace(/ at [^(\s]+\(\d+\)/g,' at SOURCE(LINE)').replace(/Z:\/tests\/savestate_(?:lightgun_fix|systeme_pause_fix)\/candidate\//gi,'BUILD/');
const warnings=s=>[...new Set(s.split(/\r?\n/).filter(l=>/^\s*(Critical )?Warning \(\d+\):/.test(l)).map(norm))];
const old=warnings(read(path.join(r,'tests/savestate_lightgun_fix/candidate/compile.log'))),now=warnings(log);
const result={...simulation,baseline,candidate,delta:Object.fromEntries(['alms','registers','memoryBits','ramBlocks','dspBlocks'].map(k=>[k,candidate[k]-baseline.candidate[k]])),worstSlack:{setup:Math.min(...timing.filter(t=>t.type.startsWith('Setup')).map(t=>t.slack)),hold:Math.min(...timing.filter(t=>t.type.startsWith('Hold')).map(t=>t.slack))},violations:timing.filter(t=>t.slack<0||t.tns<0),newWarnings:now.filter(w=>!old.includes(w)),warningCounts:{baseline:old.length,candidate:now.length,baselineCritical:old.filter(w=>w.startsWith('Critical')).length,candidateCritical:now.filter(w=>w.startsWith('Critical')).length,toolReportedTotal:+log.match(/Full Compilation was successful\. 0 errors, (\d+) warnings/)[1]}};
result.delta.synthesisRegisters=candidate.synthesisRegisters-baseline.candidate.synthesisRegisters;
if(fs.existsSync(path.join(d,'resource_analysis.json')))result.resourceAnalysis=JSON.parse(read(path.join(d,'resource_analysis.json')));
fs.writeFileSync(path.join(d,'results.json'),JSON.stringify(result,null,2)+'\n');
for(const [p,args]of [['production.diff',['diff']],['diff_stat.txt',['diff','--stat']],['git_status.txt',['status','--short']]])fs.writeFileSync(path.join(d,p),git(...args)+'\n');
console.log(JSON.stringify({delta:result.delta,worstSlack:result.worstSlack,violations:result.violations,newWarnings:result.newWarnings,warningCounts:result.warningCounts},null,2));
