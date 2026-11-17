const fs=require('fs'),path=require('path'),crypto=require('crypto'),cp=require('child_process'),d=__dirname,r=path.resolve(d,'../..');
const read=f=>{let b=fs.readFileSync(f);return b[0]===255&&b[1]===254?b.subarray(2).toString('utf16le'):b.toString('utf8').replace(/^\uFEFF/,'');};
const sha=f=>crypto.createHash('sha256').update(fs.readFileSync(f)).digest('hex');
function assert(b,m){if(!b)throw Error(m);}
let logs=[],transfers=0,clockChecks=0;
function log(file,marker){let f=path.join(d,file),s=read(f);assert(s.includes(marker)&&s.includes('# Errors: 0')&&!/\*\* (Error|Fatal|Failure)|Errors: [1-9]/.test(s),'Incomplete/failed '+file);logs.push({file,sha256:sha(f),marker});return s;}
for(const c of [0,1])log(`pre_case${c}.log`,`PASS F13 case${c} expected_divergence1`);
for(const c of [0,1])log(`pre_edge${c}.log`,`PASS F13 edge-history MODE${c}`);
for(const c of [0,1])log(`pre_cpu${c}.log`,'PASS F13 real T80/video accepted');
function fixed(group,c,n,stall,delay){const s=log(`fixed_${group}_case${c}_iter${n}_stall${stall}_delay${delay}.log`,'PASS FIXED F13');assert(s.includes('SAVE_ONLY PASS'),'save-only missing');const saves=(s.match(/CAPTURE case/g)||[]).length,loads=(s.match(/RESTORE case/g)||[]).length;assert(saves===n+1&&loads===n,'incorrect complete FSM counts');transfers+=n+1;clockChecks+=+s.match(/checks(\d+) first\/repeated/)[1];return s;}
for(let c=0;c<12;c++)fixed('core',c,2,0,0);
for(const c of [6,7,9])for(const delay of [65460,65480,65500,65520,65534,65536])fixed('deadline',c,2,0,delay);
for(const c of [1,8,9])fixed('stress',c,8,2,0);
for(const c of [0,1]){log(`fixed_edge${c}.log`,`PASS FIXED F13 edge MODE${c}`);transfers+=3;}
for(const c of [0,1]){log(`fixed_cpu${c}.log`,`PASS FIXED F13 real T80/video EARLY${c} guest OUT data before03 perturbed07 restored03`);transfers+=2;}
const fmt=log('format.log','PASS F13 format cases24');assert((fmt.match(/PASS F13 format case\d/g)||[]).length===24,'format matrix incomplete');transfers+=25;
const boundary=log('boundary_fixed.log','PASS FIXED F13 phased boundary captures225');assert((boundary.match(/BOUNDARY phase/g)||[]).length===225,'phased sweep incomplete');
const terminal=log('terminal_fixed.log','PASS FIXED F13 phased boundary captures15');
const histories=[...(boundary+terminal).matchAll(/BOUNDARY phase(\d+) kind(\d+) request(\d+) mapper([a-f0-9]+) history([a-f0-9]+)/g)].map(m=>({phase:+m[1],kind:+m[2],request:+m[3],mapper:m[4],history:parseInt(m[5],16)}));
assert(histories.some(h=>(h.history&65535)===65534),'terminal pending-decision capture not covered');
const regressions=['banking','mapper_memory','eeprom_direct','eeprom_ddr','eeprom_persistence','sc_ram','f07_controller','f07_systeme','f02_direct','f02_ddr','f08_md6','f09_tap','f10_paddle','f11_lightgun','f11_format0','f11_format3','f12_paused','psg'];
for(const n of regressions)log(`reg_${n}.log`,'PASS');
assert((read(path.join(d,'reg_eeprom_ddr.log')).match(/PASS EEPROM DDRAM case/g)||[]).length===24,'EEPROM24 coverage');
assert((read(path.join(d,'reg_sc_ram.log')).match(/PASS F05 fullDDR/g)||[]).length===60,'SC60 coverage');
assert(read(path.join(d,'reg_f07_systeme.log')).includes('PASS integrated System E'),'System E integration incomplete');
assert(read(path.join(d,'reg_f12_paused.log')).includes('PASS FIXED'),'F12 incomplete');
cp.execFileSync('C:/Program Files/nodejs/node.exe',[path.join(d,'static_checks.js')],{cwd:r,stdio:['ignore','pipe','pipe']});
let sourceHashes=Object.fromEntries(['SMS.sv','rtl/system.vhd','rtl/mapper_ctrl.vhd','rtl/mapper_detect.vhd','rtl/savestates.sv'].map(p=>[p,sha(path.join(r,p))]));
const result={base:'b61f307dcb161a6ac9a70fd544d435436807191d',sourceHashes,canonicalLogs:logs.length,logs,targetedCompleteOperations:transfers,replayClockChecks:clockChecks,boundaryCaptures:240,boundaryHistories:histories,formatCases:24,stressLoads:24,F06:'unresolved; untouched'};
fs.writeFileSync(path.join(d,'simulation_results.json'),JSON.stringify(result,null,2)+'\n');
if(process.argv.includes('--sim-only')){console.log('PASS all '+logs.length+' simulation logs, '+transfers+' complete targeted operations, '+clockChecks+' clock replay comparisons, 240 phased captures.');process.exit(0);}
const compile=read(path.join(d,'candidate/compile.log'));assert(compile.includes('Full Compilation was successful'),'Quartus not complete');
const sources=JSON.parse(read(path.join(d,'build_sources.json')));for(const[p,h]of Object.entries(sources))assert(sha(path.join(r,p))===h&&sha(path.join(d,'candidate',p))===h,'build source changed '+p);
const build=path.join(d,'candidate'),oldBuild=path.join(r,'tests/savestate_systeme_pause_fix/candidate');
const fit=read(path.join(build,'output_files/SMS.fit.summary')),sta=read(path.join(build,'output_files/SMS.sta.summary'));
assert(fit.includes('Fitter Status : Successful'),'fitter failed');
const val=n=>+fit.match(new RegExp(n+'[^:\\r\\n]*:\\s*([\\d,]+)'))[1].replaceAll(',','');
const timing=[...sta.matchAll(/Type\s*:\s*([^\r\n]+)\r?\nSlack\s*:\s*(-?[\d.]+)\r?\nTNS\s*:\s*(-?[\d.]+)/g)].map(m=>({type:m[1],slack:+m[2],tns:+m[3]}));
assert(timing.length>0,'timing summaries absent');
const candidate={ALMs:val('Logic utilization'),fittedRegisters:val('Total registers'),memoryBits:val('Total block memory bits'),RAMBlocks:val('Total RAM Blocks'),DSPs:val('Total DSP Blocks'),synthesisRegisters:+read(path.join(build,'output_files/SMS.map.summary')).match(/Total registers\s*:\s*([\d,]+)/)[1].replaceAll(',','')};
const baseline=JSON.parse(read(path.join(d,'baseline.json'))),delta=Object.fromEntries(Object.entries(candidate).map(([k,v])=>[k,v-baseline[k]]));
const normalize=l=>l.trim().replace(/ File:.*$/,'').replace(/ at [^(\s]+\(\d+\)/g,' at SOURCE(LINE)').replace(/Z:\/tests\/savestate_(?:systeme_pause_fix|mapper_detection_fix)\/candidate\//gi,'BUILD/');
const warnings=s=>[...new Set(s.split(/\r?\n/).filter(l=>/^\s*(Critical )?Warning \(\d+\):/.test(l)).map(normalize))];
const oldWarnings=warnings(read(path.join(oldBuild,'compile.log'))),nowWarnings=warnings(compile),newWarnings=nowWarnings.filter(w=>!oldWarnings.includes(w));
const violations=timing.filter(t=>t.slack<0||t.tns<0),worstSlack={setup:Math.min(...timing.filter(t=>t.type.startsWith('Setup')).map(t=>t.slack)),hold:Math.min(...timing.filter(t=>t.type.startsWith('Hold')).map(t=>t.slack))};
const final={...result,quartus:true,baseline,candidate,delta,timing,worstSlack,violations,newWarnings,warningCounts:{baseline:oldWarnings.length,candidate:nowWarnings.length,baselineCritical:oldWarnings.filter(x=>x.startsWith('Critical')).length,candidateCritical:nowWarnings.filter(x=>x.startsWith('Critical')).length,toolTotal:+compile.match(/Full Compilation was successful\. 0 errors, (\d+) warnings/)[1]},recommendation:violations.length===0&&newWarnings.length===0?'READY TO COMMIT':'NOT READY'};
if(fs.existsSync(path.join(d,'resource_analysis.json'))){final.resourceAnalysis=JSON.parse(read(path.join(d,'resource_analysis.json')));assert(final.resourceAnalysis.fitterOwnRegisterDelta===delta.fittedRegisters,'fitter entity ledger does not reconcile');}
fs.writeFileSync(path.join(d,'results.json'),JSON.stringify(final,null,2)+'\n');
for(const[name,args]of [['git_status.txt',['status','--short']],['diff_stat.txt',['diff','--stat']]])fs.writeFileSync(path.join(d,name),cp.execFileSync('git',['-c','core.safecrlf=false',...args],{cwd:r,encoding:'utf8',stdio:['ignore','pipe','pipe']}));
console.log(JSON.stringify({recommendation:final.recommendation,candidate,delta,worstSlack,violations,newWarnings,warningCounts:final.warningCounts},null,2));
