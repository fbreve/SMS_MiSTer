const fs=require('fs'),path=require('path'),cp=require('child_process'),crypto=require('crypto'),d=__dirname,r=path.resolve(d,'../..');
const read=f=>{const b=fs.readFileSync(path.resolve(d,f));return b[0]===255&&b[1]===254?b.subarray(2).toString('utf16le'):b.toString('utf8');};
const sha=f=>crypto.createHash('sha256').update(fs.readFileSync(f)).digest('hex');
const git=(...a)=>cp.execFileSync('git',a,{cwd:r,encoding:'utf8'}).trimEnd();
const tests={};
function check(f,marker,re,count){const s=read(f);if(!s.includes(marker)||/\*\* (Failure|Fatal|Error)|Errors: [1-9]/.test(s))throw Error('Incomplete/failing '+f);if(re&&(s.match(re)||[]).length!==count)throw Error('Wrong count '+f);tests[f]={sha256:sha(path.resolve(d,f)),marker};}
check('before.log','PASS PRE-FIX F10',/CONFIRMED F10 case/g,5);
check('before_full.log','PASS PRE-FIX F10 full DDRAM COMPLETE',/CONFIRMED F10 full DDR/g,3);
check('directed.log','PHASES=0 cases=896');check('replay.log','PHASES=1 cases=6712');check('modes.log','PHASES=2 cases=224');
check('f10_ordinary.log','PASS F10 ordinary baseline equivalence: 1000000');
check('static.log','PASS F10 static: 32 local bits');check('f07_static.log','Original audit static checks pass.');check('f02_static.log','original audit checks passed.');
const full=['ddr0.log','f10_ddr1.log','f10_ddr2.log'];
for(const f of full)check(f,'PASS Paddle DDRAM COMPLETE',/PASS Paddle DDR case/g,22);
for(let stall=0;stall<3;stall++)for(const k of [0,1,2,20,21]){const f=`routed${stall}_${k}.log`;check(f,'PASS Paddle DDRAM COMPLETE',/PASS Paddle DDR case/g,1);full.push(f);}
for(let stall=0;stall<3;stall++)for(const k of [22,23,24]){const f=`combined${stall}_${k}.log`;check(f,'PASS combined Tap/Paddle',/PASS Paddle DDR case/g,1);full.push(f);}
for(let i=0;i<3;i++){
 check(`../savestate_eeprom/f10_stalls${i}.log`,'PASS EEPROM DDRAM: 23',/PASS EEPROM DDRAM case/g,23);
 check(`../savestate_sc_ram/f10_stalls${i}.log`,'PASS SC COMPLETE',/PASS F05 fullDDR/g,57);
 check(`../savestate_master_tap/f10_stalls${i}.log`,'PASS Master Tap DDRAM COMPLETE',/PASS Tap DDR case/g,21);
}
for(const[f,m]of [
 ['../savestate_hcounter/f10_sms.log','PASS: F07 fixed'],['../savestate_hcounter/f10_gg.log','PASS: F07 fixed'],['../savestate_hcounter/f10_controller.log','PASS controller case 9'],['../savestate_hcounter/f10_integration.log','PASS integrated System E'],
 ['../savestate_gg_io/f10_replay.log','PASS F02 local replay: 24'],['../savestate_gg_io/f10_ddr0.log','PASS F02 DDRAM integration: 14'],['../savestate_gg_io/f10_ddr1.log','PASS F02 DDRAM integration: 14'],
 ['../savestate_md6/f10_replay64.log','PASS replay T=64 cases=2560'],['../savestate_md6/f10_replay80540.log','PASS replay T=80540 cases=160'],['../savestate_md6/f10_integration.log','PASS MD DDRAM case12'],
 ['../savestate_master_tap/f10_ordinary.log','PASS ordinary Master Tap/disabled/raw-serial shared-timer baseline equivalence: 100000'],['../savestate_master_tap/f10_replay8.log','PASS Master Tap directed T=8 cases=4096'],['../savestate_master_tap/f10_replay57000.log','PASS Master Tap directed T=57000 cases=64'],
 ['../savestate_eeprom/f10_replay.log','PASS EEPROM replay: 6642'],['../savestate_eeprom/f10_persistence.log','PASS persistence:'],
 ['../savestate_sc_ram/f10_controls.log','PASS SC zero-size and ordinary SMS negative controls'],['../savestate_sc_ram/f10_persistence.log','PASS SC full restore marks dirty'],
 ['../savestate_coverage/f10_psg.log','PASS PSG replay: 128'],['../savestate_coverage/f10_audit.log','PASS eeprom_gap_tb']])check(f,m);
const lengths=full.flatMap(f=>[...read(f).matchAll(/saveClocks(\d+) loadClocks(\d+)/g)].map(m=>({save:+m[1],load:+m[2]})));
const transport={cases:lengths.length,sourceClockHz:53693175,dividerPeriod:3356,meaningfulPhases:3356,jpAlternatingStates:2,minSave:Math.min(...lengths.map(x=>x.save)),maxSave:Math.max(...lengths.map(x=>x.save)),minLoad:Math.min(...lengths.map(x=>x.load)),maxLoad:Math.max(...lengths.map(x=>x.load)),testbenchClockNs:10};
const sources=JSON.parse(read('sources.json'));
const simulations={tests,transport,directedCases:7832,paddleDDRCases:90,eepromDDRCases:69,scDDRCases:171,masterTapDDRCases:63};
fs.writeFileSync(path.join(d,'simulation_results.json'),JSON.stringify(simulations,null,2)+'\n');
if(process.argv.includes('--sim-only')){console.log('PASS '+Object.keys(tests).length+' simulation/static logs');console.log(JSON.stringify(transport));process.exit(0);}
const previous=JSON.parse(read('../savestate_master_tap/results.json')),baseline=previous.candidate;
for(const[f,v]of Object.entries(sources)){
 if(sha(path.join(r,f))!==v.candidate||sha(path.join(d,'candidate',f))!==v.candidate)throw Error('Stale source/build '+f);
 if(v.baseline!==previous.sources[f].candidate)throw Error('Baseline mismatch '+f);
}
if(sha(path.join(d,'candidate/build_id.v'))!==sha(path.join(d,'../savestate_master_tap/candidate/build_id.v')))throw Error('Generated build date differs from F09');
const log=read('candidate/compile.log'),fit=read('candidate/output_files/SMS.fit.summary'),sta=read('candidate/output_files/SMS.sta.summary'),map=read('candidate/output_files/SMS.map.summary');
if(!log.includes('Full Compilation was successful')||!fit.includes('Fitter Status : Successful'))throw Error('Build incomplete');
const timing=[...sta.matchAll(/Type\s*:\s*([^\r\n]+)\r?\nSlack\s*:\s*(-?[\d.]+)\r?\nTNS\s*:\s*(-?[\d.]+)/g)].map(m=>({type:m[1],slack:+m[2],tns:+m[3]}));
if(!timing.length)throw Error('Missing timing');
const val=l=>{const m=fit.match(new RegExp(l+'[^:\\r\\n]*:\\s*([\\d,]+)'));if(!m)throw Error(l);return +m[1].replaceAll(',','');};
const candidate={alms:val('Logic utilization'),registers:val('Total registers'),synthesisRegisters:+map.match(/Total registers\s*:\s*([\d,]+)/)[1].replaceAll(',',''),memoryBits:val('Total block memory bits'),ramBlocks:val('Total RAM Blocks'),dspBlocks:val('Total DSP Blocks'),timing};
const norm=l=>l.trim().replace(/ File:.*$/,'').replace(/ at [^(\s]+\(\d+\)/g,' at SOURCE(LINE)').replace(/Z:\/tests\/savestate_(?:paddle|master_tap)\/candidate\//gi,'BUILD/');
const warnings=s=>[...new Set(s.split(/\r?\n/).filter(l=>/^\s*(Critical )?Warning \(\d+\):/.test(l)).map(norm))],oldw=warnings(read('../savestate_master_tap/candidate/compile.log')),neww=warnings(log);
const min=t=>Math.min(...timing.filter(x=>x.type.startsWith(t)).map(x=>x.slack));
const result={base:git('rev-parse','HEAD'),branch:git('branch','--show-current'),sources,...simulations,baseline,candidate,delta:Object.fromEntries(['alms','registers','memoryBits','ramBlocks','dspBlocks'].map(k=>[k,candidate[k]-baseline[k]])),worstSlack:{setup:min('Setup'),hold:min('Hold')},violations:timing.filter(x=>x.slack<0||x.tns<0),newWarnings:neww.filter(x=>!oldw.includes(x)),removedWarnings:oldw.filter(x=>!neww.includes(x)),warningCounts:{baseline:oldw.length,candidate:neww.length,baselineCritical:oldw.filter(x=>x.startsWith('Critical')).length,candidateCritical:neww.filter(x=>x.startsWith('Critical')).length,toolReportedTotal:+log.match(/Full Compilation was successful\. 0 errors, (\d+) warnings/)[1]}};
if(git('diff','--cached','--name-only'))throw Error('Unexpected staged changes');
fs.writeFileSync(path.join(d,'results.json'),JSON.stringify(result,null,2)+'\n');
for(const[f,args]of [['production.diff',['diff']],['git_status.txt',['status','--short']],['diff_stat.txt',['diff','--stat']]])fs.writeFileSync(path.join(d,f),git(...args)+'\n');
console.log(JSON.stringify({delta:result.delta,worstSlack:result.worstSlack,violations:result.violations,newWarnings:result.newWarnings,warningCounts:result.warningCounts},null,2));
