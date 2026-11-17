const fs=require('fs'),path=require('path'),crypto=require('crypto'),cp=require('child_process'),d=__dirname,r=path.resolve(d,'../..');
const read=f=>{const b=fs.readFileSync(f);return b[0]===255&&b[1]===254?b.subarray(2).toString('utf16le'):b.toString('utf8').replace(/^\uFEFF/,'');};
const sha=f=>crypto.createHash('sha256').update(fs.readFileSync(f)).digest('hex');
const assert=(b,m)=>{if(!b)throw Error(m);};
let logs=[],clockChecks=0,operations=0,loads=0,ones=0n,zeros=0n;const mask=(1n<<57n)-1n;
function log(n,marker){const f=path.join(d,n+'.log'),s=read(f);assert(s.includes(marker)&&s.includes('# Errors: 0')&&!/\*\* (Error|Fatal|Failure)|Errors: [1-9]/.test(s),'Incomplete/failed '+n);logs.push({name:n,sha256:sha(f)});return s;}
for(let i=0;i<4;i++)log('pre_case'+i,'PASS F14 CASE'+i);
function replay(n,i){const s=log(n,'PASS FIXED F14 CASE'+i);assert((s.match(/REPLAY CASE\d+ iteration/g)||[]).length===3,'three-load coverage '+n);const m=s.match(/accepted=(\d+) loads=(\d+) checks=(\d+)/);assert(m,'missing replay counters '+n);operations+=+m[1];loads+=+m[2];clockChecks+=+m[3];const h=BigInt('0x'+s.match(/SAVE_ONLY PASS CASE\d+ F14=([\da-f]+)/)[1]);ones|=h;zeros|=(~h&mask);
 if(i>=15){const bit=1<<((i-15)%8),p=i>=23?(~bit&255):bit;const expected=(1n<<56n)|(BigInt(((0x96^p)<<8)|(0x69^p))<<40n)|(BigInt(0xc3^p)<<32n)|(BigInt((p<<8)|(~p&255))<<16n)|BigInt(((~p&255)<<8)|p);assert(h===expected,'independent bit-layout oracle '+n);}
 return s;}
for(let i=0;i<15;i++)replay('fixed_case'+i,i);
for(const i of [0,2,3,4,12])replay('stress_case'+i,i);
for(let i=15;i<=30;i++)replay('bits_case'+i,i);
assert(ones===mask&&zeros===mask,'not every F14 bit exercised both zero and one');
const pair=read(path.join(d,'fixed_case0.log'));assert(pair.includes('v10 A=0128000028004800 B=0124000024004800'),'actual pair snapshots not distinguished');
const cpu=log('cpu','actual OUT20 data before28 restored28');assert(cpu.includes('CPU READ before')&&cpu.includes('CPU READ restored')&&(cpu.match(/Flash=288123 DI=28/g)||[]).length===2&&cpu.includes('hostTurboB=1'),'CPU/host boundary data evidence incomplete');
log('history','PASS F14 history matrix');
const format=log('format','PASS F14 format cases30 rejected27 accepted3');assert((format.match(/PASS F14 format case\d/g)||[]).length===30,'Evolution format count');
const compat=log('compat','PASS F13 format cases30 untagged v1-v10');assert((compat.match(/PASS F13 format case\d/g)||[]).length===30,'legacy/non-Evolution format count');
for(const n of ['f13_dahjee','f13_deadline','reg_banking','reg_mapper_memory','reg_eeprom_direct','reg_eeprom_ddr','reg_eeprom_persistence','reg_sc_ram','reg_f07_controller','reg_f07_systeme','reg_f02_direct','reg_f02_ddr','reg_f08_md6','reg_f09_tap','reg_f10_paddle','reg_f11_lightgun','reg_f11_format0','reg_f11_format3','reg_f12_paused','reg_psg'])log(n,'PASS');
assert((read(path.join(d,'reg_eeprom_ddr.log')).match(/PASS EEPROM DDRAM case/g)||[]).length===24,'EEPROM24');
assert((read(path.join(d,'reg_sc_ram.log')).match(/PASS F05 fullDDR/g)||[]).length===60,'SC60');
cp.execFileSync('C:/Program Files/nodejs/node.exe',[path.join(d,'static_checks.js')],{cwd:r,stdio:['ignore','pipe','pipe']});
const sourceHashes=Object.fromEntries(['SMS.sv','rtl/system.vhd','rtl/evolution_mapper.vhd','rtl/savestates.sv'].map(p=>[p,sha(path.join(r,p))]));
const result={base:'eede89d',sourceHashes,canonicalLogs:logs.length,logs,selectorHistories:36,baseBoundaryCases:15,patternCases:16,stallCases:5,directedAcceptedOperations:operations,directedLoads:loads,clockReplayChecks:clockChecks,all57BitsZeroAndOne:true,evolutionFormatCases:30,evolutionRejected:27,otherFormatCases:30,realCpuAcceptedOperations:2,F06:'unresolved; untouched',F15_F16:'untouched'};
fs.writeFileSync(path.join(d,'simulation_results.json'),JSON.stringify(result,null,2)+'\n');
if(process.argv.includes('--sim-only')){console.log(`PASS ${logs.length} canonical logs, ${operations} directed operations / ${loads} LOADs, ${clockChecks} comparisons, all57 bits, real CPU data28/28.`);process.exit(0);}
const build=path.join(d,'candidate'),oldBuild=path.join(r,'tests/savestate_mapper_detection_fix/candidate'),compile=read(path.join(build,'compile.log'));assert(compile.includes('Full Compilation was successful'),'Quartus incomplete');
const sources=JSON.parse(read(path.join(d,'build_sources.json')));for(const[p,h]of Object.entries(sources))assert(sha(path.join(r,p))===h&&sha(path.join(build,p))===h,'build source changed '+p);
const fit=read(path.join(build,'output_files/SMS.fit.summary')),rpt=read(path.join(build,'output_files/SMS.fit.rpt')),sta=read(path.join(build,'output_files/SMS.sta.summary'));assert(fit.includes('Fitter Status : Successful'),'fitter failed');
const val=n=>+fit.match(new RegExp(n+'[^:\\r\\n]*:\\s*([\\d,]+)'))[1].replaceAll(',','');
const reportVal=re=>+rpt.match(re)[1].replaceAll(',','');
const candidate={ALMs:val('Logic utilization'),placedALMs:reportVal(/\[A\] ALMs used in final placement[^;]*;\s*([\d,]+)/),fittedRegisters:val('Total registers'),memoryBits:val('Total block memory bits'),RAMBlocks:val('Total RAM Blocks'),DSPs:val('Total DSP Blocks'),synthesisRegisters:+read(path.join(build,'output_files/SMS.map.summary')).match(/Total registers\s*:\s*([\d,]+)/)[1].replaceAll(',','')};
const baseline=JSON.parse(read(path.join(d,'baseline.json'))),delta=Object.fromEntries(Object.entries(candidate).map(([k,v])=>[k,v-baseline[k]]));
const primary=rpt.match(/-- Primary logic registers\s*;\s*([\d,]+)\s*\/\s*([\d,]+)/),secondary=rpt.match(/-- Secondary logic registers\s*;\s*([\d,]+)\s*\/\s*([\d,]+)/);
assert(primary&&secondary,'core register capacities absent');
const registerBreakdown={dedicatedLogic:reportVal(/; Dedicated logic registers\s*;\s*([\d,]+)/),io:reportVal(/; I\/O registers\s*;\s*([\d,]+)/),primaryUsed:+primary[1].replaceAll(',',''),primaryCapacity:+primary[2].replaceAll(',',''),secondaryUsed:+secondary[1].replaceAll(',',''),secondaryCapacity:+secondary[2].replaceAll(',','')};
assert(registerBreakdown.dedicatedLogic+registerBreakdown.io===candidate.fittedRegisters,'register subtotals do not reconcile');
const totals={ALMs:41910,placedALMs:41910,fittedRegisters:registerBreakdown.primaryCapacity+registerBreakdown.secondaryCapacity,memoryBits:5662720,RAMBlocks:553,DSPs:112};
const utilization=Object.fromEntries(Object.entries(totals).map(([k,total])=>[k,{used:candidate[k],total,percent:+(100*candidate[k]/total).toFixed(3),delta:delta[k]}]));
const timing=[...sta.matchAll(/Type\s*:\s*([^\r\n]+)\r?\nSlack\s*:\s*(-?[\d.]+)\r?\nTNS\s*:\s*(-?[\d.]+)/g)].map(m=>({type:m[1],slack:+m[2],tns:+m[3]}));assert(timing.length,'timing absent');
const violations=timing.filter(t=>t.slack<0||t.tns<0),worstSlack={setup:Math.min(...timing.filter(t=>t.type.startsWith('Setup')).map(t=>t.slack)),hold:Math.min(...timing.filter(t=>t.type.startsWith('Hold')).map(t=>t.slack))};
const normalize=l=>l.trim().replace(/ File:.*$/,'').replace(/ at [^(\s]+\(\d+\)/g,' at SOURCE(LINE)').replace(/Z:\/tests\/savestate_(?:mapper_detection_fix|evolution_selector_fix)\/candidate\//gi,'BUILD/').replace(/Warning \(12241\): \d+ hierarchies have connectivity warnings/,'Warning (12241): COUNT hierarchies have connectivity warnings');
const warnings=s=>[...new Set(s.split(/\r?\n/).filter(l=>/^\s*(Critical )?Warning \(\d+\):/.test(l)).map(normalize))];
const oldWarnings=warnings(read(path.join(oldBuild,'compile.log'))),nowWarnings=warnings(compile),newWarnings=nowWarnings.filter(w=>!oldWarnings.includes(w)),removedWarnings=oldWarnings.filter(w=>!nowWarnings.includes(w));
const connectivityHierarchyCounts={baseline:+read(path.join(oldBuild,'compile.log')).match(/Warning \(12241\): (\d+) hierarchies/)[1],candidate:+compile.match(/Warning \(12241\): (\d+) hierarchies/)[1]};
assert(connectivityHierarchyCounts.candidate<=connectivityHierarchyCounts.baseline,'connectivity warning count increased');
const connectivityNames=s=>[...s.matchAll(/^\d+\. Port Connectivity Checks: "([^"]+)"/gm)].map(m=>m[1]);
const oldConnectivity=connectivityNames(read(path.join(oldBuild,'output_files/SMS.map.rpt'))),nowConnectivity=connectivityNames(read(path.join(build,'output_files/SMS.map.rpt')));
assert(oldConnectivity.length>0&&nowConnectivity.length>0,'connectivity report sections not parsed');
const connectivityHierarchyDiff={baselineSections:oldConnectivity.length,candidateSections:nowConnectivity.length,added:nowConnectivity.filter(n=>!oldConnectivity.includes(n)),removed:oldConnectivity.filter(n=>!nowConnectivity.includes(n))};
assert(!connectivityHierarchyDiff.added.length,'new hierarchy has connectivity warnings');
const resourceAnalysis=JSON.parse(read(path.join(d,'resource_analysis.json')));assert(resourceAnalysis.fitterOwnRegisterDelta===delta.fittedRegisters,'entity ledger does not reconcile');
const final={...result,quartus:true,baseline,candidate,delta,utilization,timing,worstSlack,violations,newWarnings,removedWarnings,resourceAnalysis,registerBreakdown,connectivityHierarchyCounts,connectivityHierarchyDiff,
 registerDenominator:'167640 core ALM register positions = 83820 primary + 83820 secondary. Quartus total fitted registers also includes I/O FFs; dedicated logic/I/O subtotals are listed separately in fit.rpt.',
 labOccupancy:reportVal(/Total LABs:  partially or completely used\s*;\s*([\d,]+)/),
 warningCounts:{baseline:oldWarnings.length,candidate:nowWarnings.length,baselineCritical:oldWarnings.filter(x=>x.startsWith('Critical')).length,candidateCritical:nowWarnings.filter(x=>x.startsWith('Critical')).length,toolTotal:+compile.match(/Full Compilation was successful\. 0 errors, (\d+) warnings/)[1]},recommendation:violations.length===0&&newWarnings.length===0?'READY TO COMMIT':'NOT READY'};
fs.writeFileSync(path.join(d,'results.json'),JSON.stringify(final,null,2)+'\n');
for(const[name,args]of [['git_status.txt',['status','--short']],['diff_stat.txt',['diff','--stat']],['production.diff',['diff']]])fs.writeFileSync(path.join(d,name),cp.execFileSync('git',['-c','core.safecrlf=false',...args],{cwd:r,encoding:'utf8',stdio:['ignore','pipe','pipe']}));
console.log(JSON.stringify({recommendation:final.recommendation,candidate,delta,utilization,worstSlack,violations,newWarnings,removedWarnings,warningCounts:final.warningCounts},null,2));
