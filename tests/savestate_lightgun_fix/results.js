const fs=require('fs'),path=require('path'),cp=require('child_process'),crypto=require('crypto'),d=__dirname,r=path.resolve(d,'../..');
const read=f=>{const b=fs.readFileSync(path.resolve(d,f));return b[0]===255&&b[1]===254?b.subarray(2).toString('utf16le'):b.toString('utf8');};
const sha=f=>crypto.createHash('sha256').update(fs.readFileSync(f)).digest('hex');
const git=(...a)=>cp.execFileSync('git',a,{cwd:r,encoding:'utf8',stdio:['ignore','pipe','pipe']}).trimEnd();
const tests={};
function check(f,marker='PASS',re,count,sim=true){const s=read(f);if(!s.includes(marker)||/\*\* (Failure|Fatal|Error)|Errors: [1-9]/.test(s)||(sim&&!s.includes('Errors: 0')))throw Error('Incomplete/failing '+f);if(re&&(s.match(re)||[]).length!==count)throw Error('Wrong count '+f);if(/^(cpu_stalls|stalls|variant|sweep|phase|format|hcounter_guard|io_order|final_)/.test(f)&&fs.statSync(path.resolve(d,f)).mtimeMs<fs.statSync(path.join(r,'rtl/savestates.sv')).mtimeMs)throw Error('Stale pre-final-RTL log '+f);tests[f]={sha256:sha(path.resolve(d,f)),marker};return s;}
const transport=[];
for(let i=0;i<4;i++){
 const s=check(`cpu_stalls${i}.log`,'PASS F11 freeze-only T80',/differences0/g,1);transport.push({kind:'T80-save-only',stall:i,clocks:+s.match(/transport(\d+)/)[1]});
 for(const kind of ['stalls','variant']){
  const t=check(`${kind}${i}.log`,'PASS F11 future frame',/PASS F11 accepted-boundary equivalence/g,1);
  const m=t.match(/saveClocks=(\d+) loadClocks=(\d+)/);transport.push({kind:kind+i,save:+m[1],load:+m[2]});
 }
 check(`format${i}.log`,'PASS F11 format untagged v1-v7 v8',/PASS F11 format case/g,18);
}
for(const[kind,n]of [['sweep',33],['phase',16]])for(let i=0;i<n;i++)check(`${kind}${i}.log`,'PASS F11 future frame',/PASS F11 accepted-boundary equivalence/g,1);
for(const i of [0,3])check(`hcounter_guard${i}.log`,'PASS F11 HCounter held after restore');
for(const i of [0,1])check(`io_order${i}.log`,'PASS F11 HCounter held after restore');
check('direct.log','ordinary baseline cycles=1000000 external input cases=8');
for(const f of ['static.log','f07_static.log','f02_static.log'])check(f,'PASS',null,null,false);
for(const f of ['f07_sms','f07_gg','f08_short','f08_real','f09_short','f09_real','f09_ordinary','f10_directed','f10_phases','f10_modes','f10_ordinary','f02_direct','f03_direct','psg','coverage_audit'])check(f+'.log');
for(const f of ['final_f07_controller','final_f07_integration','final_f02_ddr0','final_f02_ddr1','final_f08_ddr','final_f03_persistence','final_f05_controls','final_f05_persistence'])check(f+'.log');
for(let i=0;i<3;i++){
 check(`final_f03_ddr${i}.log`,'PASS EEPROM DDRAM: 24',/PASS EEPROM DDRAM case/g,24);
 check(`final_f05_ddr${i}.log`,'PASS SC COMPLETE',/PASS F05 fullDDR/g,60);
 check(`final_f09_ddr${i}.log`,'PASS Master Tap DDRAM COMPLETE',/PASS Tap DDR case/g,22);
 check(`final_f10_ddr${i}.log`,'PASS Paddle DDRAM COMPLETE',/PASS Paddle DDR case/g,22);
 for(const k of [0,1,2,20,21,22,23,24,25])check(`final_f10_case${k}_stall${i}.log`,'PASS Paddle DDRAM COMPLETE',/PASS Paddle DDR case/g,1);
}
const sources=JSON.parse(read('sources.json'));
for(const[f,v]of Object.entries(sources))if(sha(path.join(r,f))!==v.candidate)throw Error('Stale production source '+f);
const simulation={base:git('rev-parse','HEAD'),branch:git('branch','--show-current'),sources,tests,transport,lightgun:{t80Saves:4,boundaryPairs:61,timingCases:49,hcounterGuards:4,directionRestoreCases:2,formatLoads:72,formatSaves:4,externalCases:8,ordinaryCycles:1000000},broader:{eepromDDR:72,scDDR:180,tapDDR:66,paddleDDR:93}};
fs.writeFileSync(path.join(d,'simulation_results.json'),JSON.stringify(simulation,null,2)+'\n');
if(process.argv.includes('--sim-only')){console.log('PASS '+Object.keys(tests).length+' complete simulation/static logs');console.log(JSON.stringify({lightgun:simulation.lightgun,transport}));process.exit(0);}
const baseline=JSON.parse(read('../savestate_paddle/results.json')).candidate;
for(const[f,v]of Object.entries(sources))if(sha(path.join(d,'candidate',f))!==v.candidate)throw Error('Stale build '+f);
const log=read('candidate/compile.log'),fit=read('candidate/output_files/SMS.fit.summary'),sta=read('candidate/output_files/SMS.sta.summary'),map=read('candidate/output_files/SMS.map.summary');
if(!log.includes('Full Compilation was successful')||!fit.includes('Fitter Status : Successful'))throw Error('Build incomplete');
const timing=[...sta.matchAll(/Type\s*:\s*([^\r\n]+)\r?\nSlack\s*:\s*(-?[\d.]+)\r?\nTNS\s*:\s*(-?[\d.]+)/g)].map(m=>({type:m[1],slack:+m[2],tns:+m[3]}));
if(!timing.length)throw Error('Missing timing');
const val=l=>{const m=fit.match(new RegExp(l+'[^:\\r\\n]*:\\s*([\\d,]+)'));if(!m)throw Error(l);return +m[1].replaceAll(',','');};
const candidate={alms:val('Logic utilization'),registers:val('Total registers'),synthesisRegisters:+map.match(/Total registers\s*:\s*([\d,]+)/)[1].replaceAll(',',''),memoryBits:val('Total block memory bits'),ramBlocks:val('Total RAM Blocks'),dspBlocks:val('Total DSP Blocks'),timing};
const norm=l=>l.trim().replace(/ File:.*$/,'').replace(/ at [^(\s]+\(\d+\)/g,' at SOURCE(LINE)').replace(/Z:\/tests\/savestate_(?:paddle|lightgun_fix)\/candidate\//gi,'BUILD/');
const warnings=s=>[...new Set(s.split(/\r?\n/).filter(l=>/^\s*(Critical )?Warning \(\d+\):/.test(l)).map(norm))],oldw=warnings(read('../savestate_paddle/candidate/compile.log')),neww=warnings(log);
const min=t=>Math.min(...timing.filter(x=>x.type.startsWith(t)).map(x=>x.slack));
const result={...simulation,baseline,candidate,delta:Object.fromEntries(['alms','registers','synthesisRegisters','memoryBits','ramBlocks','dspBlocks'].map(k=>[k,candidate[k]-baseline[k]])),worstSlack:{setup:min('Setup'),hold:min('Hold')},violations:timing.filter(x=>x.slack<0||x.tns<0),newWarnings:neww.filter(x=>!oldw.includes(x)),removedWarnings:oldw.filter(x=>!neww.includes(x)),warningCounts:{baseline:oldw.length,candidate:neww.length,baselineCritical:oldw.filter(x=>x.startsWith('Critical')).length,candidateCritical:neww.filter(x=>x.startsWith('Critical')).length,toolReportedTotal:+log.match(/Full Compilation was successful\. 0 errors, (\d+) warnings/)[1]},buildDate:{baseline:read('../savestate_paddle/candidate/build_id.v').trim(),candidate:read('candidate/build_id.v').trim()}};
if(git('diff','--cached','--name-only'))throw Error('Unexpected staged changes');
fs.writeFileSync(path.join(d,'results.json'),JSON.stringify(result,null,2)+'\n');
for(const[f,args]of [['production.diff',['diff']],['git_status.txt',['status','--short']],['diff_stat.txt',['diff','--stat']]])fs.writeFileSync(path.join(d,f),git(...args)+'\n');
console.log(JSON.stringify({delta:result.delta,worstSlack:result.worstSlack,violations:result.violations,newWarnings:result.newWarnings,warningCounts:result.warningCounts,logs:Object.keys(tests).length},null,2));
