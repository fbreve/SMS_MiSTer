const fs=require('fs'),path=require('path'),cp=require('child_process'),crypto=require('crypto'),d=__dirname,r=path.resolve(d,'../..');
const read=f=>{let b=fs.readFileSync(path.join(d,f));return b[0]===255&&b[1]===254?b.subarray(2).toString('utf16le'):b.toString('utf8');};
const git=(...a)=>cp.execFileSync('git',a,{cwd:r,encoding:'utf8'}).trimEnd();
const tests={};function check(f,marker){const s=read(f);if(!s.includes(marker)||/\*\* (Fatal|Failure|Error)|Errors: [1-9]/.test(s))throw Error('Incomplete/failing '+f);tests[f]={marker,sha256:crypto.createHash('sha256').update(fs.readFileSync(path.join(d,f))).digest('hex')};return s;}
const boundary=[];
for(const f of ['boundary0.log','boundary1.log','boundary2.log','boundary3.log','variant0.log','variant1.log','variant2.log']){
 const s=check(f,'CONFIRMED F11 accepted-boundary divergence');
 const a=s.match(/SAVED video=(\w+) H=(\w+) sensor=(\d) localHV=(\d+)\/(\d+) time=(\d+) saveClocks=(\d+)/),g=s.match(/GUEST portDD DUT=(\w+) reference=(\w+)/),c=s.match(/loadClocks=(\d+)/);
 boundary.push({file:f,video:a[1],hcounter:a[2],sensor:+a[3],localH:+a[4],localV:+a[5],sensorTime:+a[6],saveClocks:+a[7],loadClocks:+c[1],guest:g[1],referenceGuest:g[2]});
}
check('variant3.log','PASS F11 negative sample');
const cpu=check('cpu.log','CONFIRMED F11 real T80 save-only CPU divergence');
if(!cpu.includes('pending1/0 time0/255')||!cpu.includes('A=b4/f4'))throw Error('Missing causal/architectural CPU evidence');
const cases=JSON.parse(read('sweep_cases.json')),sweep=[];
for(let i=0;i<cases.length;i++){
 const s=check(`sweep_case${i}.log`,'PASS REACHABILITY'),m=s.match(/PAL(\d+) BORDER(\d+) MODE(\d+) PX(\d+) PY(\d+) potentialCPUboundaries(\d+) sensorHigh(\d+) savedXrange(-?\d+)\.\.(-?\d+) Yrange(-?\d+)\.\.(-?\d+) sensorEdges(\d+)\/(\d+) HDEedges(\d+)\/(\d+)/);
 if(!m)throw Error('Missing sweep metrics '+i);
 sweep.push({index:i,...cases[i],potentialBoundaries:+m[6],sensorHigh:+m[7],minSavedX:+m[8],maxSavedX:+m[9],minY:+m[10],maxY:+m[11],sensorRises:+m[12],sensorFalls:+m[13],hdeRises:+m[14],hdeFalls:+m[15]});
}
for(const[f,m]of [
 ['f07_sms.log','PASS: F07 fixed'],['f07_gg.log','PASS: F07 fixed'],['f07_controller.log','PASS controller case 9'],['f07_integration.log','PASS integrated System E'],
 ['f08_short.log','PASS replay T=64 cases=2560'],['f08_real.log','PASS replay T=80540 cases=160'],['f08_ddr.log','PASS MD DDRAM case12'],
 ['f09_short.log','PASS Master Tap directed T=8 cases=4096'],['f09_real.log','PASS Master Tap directed T=57000 cases=64'],['f09_ordinary.log','PASS ordinary Master Tap/disabled/raw-serial shared-timer baseline equivalence: 100000'],['f09_ddr.log','PASS Master Tap DDRAM COMPLETE'],
 ['f10_directed.log','PHASES=0 cases=896'],['f10_phases.log','PHASES=1 cases=6712'],['f10_modes.log','PHASES=2 cases=224'],['f10_ordinary.log','PASS F10 ordinary baseline equivalence: 1000000'],['f10_ddr.log','PASS Paddle DDRAM COMPLETE']])check(f,m);
check('static.log','PASS F11 source provenance');
if(git('diff','--name-only')||git('diff','--cached','--name-only'))throw Error('Forbidden tracked/staged changes');
const result={classification:'CONFIRMED - FIX REQUIRED',head:git('rev-parse','HEAD'),branch:git('branch','--show-current'),tests,fullControllerCases:9,acceptedTransactions:17,loadGuestDivergences:7,negativeLoadSamples:1,realCPUSaveOnlyCounterexamples:1,boundary,sweepCases:sweep.length,potentialCaptureObservations:sweep.reduce((n,c)=>n+c.potentialBoundaries,0),sensorHighObservations:sweep.reduce((n,c)=>n+c.sensorHigh,0),sweep,sourceClockHz:53693175};
fs.writeFileSync(path.join(d,'results.json'),JSON.stringify(result,null,2)+'\n');
for(const[f,args]of [['diff_stat.txt',['diff','--stat']],['git_status.txt',['status','--short']]])fs.writeFileSync(path.join(d,f),git(...args)+'\n');
console.log(JSON.stringify({classification:result.classification,validatedLogs:Object.keys(tests).length,fullControllerCases:result.fullControllerCases,acceptedTransactions:result.acceptedTransactions,sweepCases:result.sweepCases,potentialCaptureObservations:result.potentialCaptureObservations,sensorHighObservations:result.sensorHighObservations},null,2));
