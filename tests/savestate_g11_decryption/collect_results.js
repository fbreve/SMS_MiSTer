const fs=require('fs'),p=require('path'),d=__dirname;
const targeted=JSON.parse(fs.readFileSync(p.join(d,'targeted.json'))),groups=[];
function group(fixture,id,args={},kind='matrix'){
 const leaf=p.join(d,fixture,id),name=kind==='pause'?'simulation.log':'replay.log',file=p.join(leaf,name);
 if(!fs.existsSync(file)){groups.push({fixture,id,args,kind,status:'pending'});return;}
 const log=fs.readFileSync(file,'utf8'),fail=/\*\* (Fatal|Failure|Error)/.test(log),pass=kind==='pause'?/PASS G11 PAUSE/.test(log):/PASS MATRIX/.test(log);
 const ledger=log.match(/G12_LEDGER accepted(\d+) returned(\d+) physical(\d+) flight([01])/),consumer=log.match(/G11_CONSUMERS total(\d+) baseline(\d+) phaseValues([01]+)/);
 const reference=p.join(leaf,'reference.log'),refPass=kind==='pause'||fs.existsSync(p.join(leaf,'reference_source.txt'))||(fs.existsSync(reference)&&/PASS MATRIX REFERENCE/.test(fs.readFileSync(reference,'utf8'))&&!/\*\* (Fatal|Failure|Error)/.test(fs.readFileSync(reference,'utf8')));
 const result={fixture,id,args,kind,status:fail?'fail':pass&&refPass?'pass':'pending',suffixes:(log.match(/PASS SUFFIX/g)||[]).length,postResaveFuture:/PASS MATRIX resave/.test(log)?1:0,fullWramSuffixes:(log.match(/PASS ROM_STREAM_WRAM/g)||[]).length,rawReissues:Number((log.match(/G11_RAW_REISSUES (\d+)/)||[])[1]||0),ledger:ledger?{accepted:+ledger[1],returned:+ledger[2],physical:+ledger[3],flight:+ledger[4]}:null,consumer:consumer?{total:+consumer[1],baseline:+consumer[2],phases:consumer[3]}:null};
 const image=p.join(leaf,kind==='pause'?'image.hex':'image_save.hex');
 if(fs.existsSync(image)){const words=fs.readFileSync(image,'utf8').replace(/\/\/[^\n]*/g,'').trim().split(/\s+/);if(words.length===12288&&/^[0-9a-f]+$/i.test(words[0x2f])){const phase=BigInt('0x'+words[0x2f]);result.capturePhase=Number(phase&3n);result.captureConsumed=Number((phase>>3n)&1n);}}
 if(result.status==='pass'&&ledger&&!(ledger[1]===ledger[2]&&ledger[2]===ledger[3]&&ledger[4]==='0'))throw Error('G12 ledger contradiction '+file);
 if(result.status==='pass'&&fixture==='streams'&&(result.fullWramSuffixes!==args.REPLAYS+1||result.rawReissues!==args.REPLAYS))throw Error('missing strong stream/RAM/reissue evidence '+file);
 result.transportClocks=[...log.matchAll(/RELEASE[^\n]*transport(\d+)/g)].map(m=>+m[1]);
 if(result.status==='pass'&&fixture==='streams'&&id==='mc_full_flush'&&(!/-g\/pause_tb\/dut\/TB_FAST=0/.test(log)||!result.transportClocks.some(n=>n>=900000)))throw Error('production-length flush not exercised '+file);
 groups.push(result);
}
group('matrix','bypass',{MODE:0,REPLAYS:1,N:6000});
group('campaign','sega_prefix_long',{MODE:2,PROGRAM:1,REPLAYS:3,N:24000});
for(let n=0;n<targeted.length;n++){const c=targeted[n];if(n%3!==2)group('campaign',c.id,c.args);group('streams',c.id,c.args);}
for(const c of JSON.parse(fs.readFileSync(p.join(d,'collisions.json'))))group('joystick',c.id,c.args);
group('phase','sega_resave_even',{MODE:2,REPLAYS:1,N:24000,TAIL_DELAY:0});
group('phase','sega_resave_shift15',{MODE:2,REPLAYS:1,N:24000,TAIL_DELAY:15});
for(const m of [1,2])for(const s of [0,1])for(const c of [0,1])group('pause',`m${m}_s${s}_c${c}_d8`,{MODE:m,SAVED_PAUSED:s,CURRENT_PAUSED:c,N:m===2&&s===1&&c===0?12000:24000},'pause');
const helpers=[['lut.log',/PASS LUT/],['oracle.log',/PASS SEGA ORACLE 8192/],['recovery.log',/PASS SEGA RECOVERY cases65536/],['mc_recovery.log',/PASS MC RECOVERY cases2097152/]].map(([file,pattern])=>{const log=fs.readFileSync(p.join(d,file),'utf8');return {file,pass:pattern.test(log)&&!/\*\* (Fatal|Failure|Error)/.test(log)};});
const collisions=JSON.parse(fs.readFileSync(p.join(d,'collisions_result.json'))),integrity=JSON.parse(fs.readFileSync(p.join(d,'integrity.json')));
const sourceBridge=JSON.parse(fs.readFileSync(p.join(d,'source_bridge.json')));
const result={groups,helpers,integratedTotal:groups.length,passed:groups.filter(x=>x.status==='pass').length,pending:groups.filter(x=>x.status==='pending').length,failed:groups.filter(x=>x.status==='fail').length,comparedMatrixSuffixes:groups.reduce((n,x)=>n+(x.suffixes||0),0),postResaveFutures:groups.reduce((n,x)=>n+(x.postResaveFuture||0),0),pauseLoadFutures:groups.filter(x=>x.kind==='pause'&&x.status==='pass').length,fullWramStreamSuffixes:groups.filter(x=>x.fixture==='streams').reduce((n,x)=>n+(x.fullWramSuffixes||0),0),collisions,integrity};
result.sourceBridge=sourceBridge;
result.requiredRuntimeGate=groups.every(x=>x.status==='pass')&&helpers.every(x=>x.pass)&&integrity.pass&&sourceBridge.pass&&collisions.every(x=>x.equalCompleteImage&&x.equalFutureOracle&&x.allReplaysPassed)&&collisions[1].equalPostResaveFuture===true;
fs.writeFileSync(p.join(d,'simulation_results.json'),JSON.stringify(result,null,2)+'\n');
console.log(JSON.stringify({integratedTotal:result.integratedTotal,passed:result.passed,pending:result.pending,failed:result.failed,helpers,comparedMatrixSuffixes:result.comparedMatrixSuffixes,fullWramStreamSuffixes:result.fullWramStreamSuffixes,requiredRuntimeGate:result.requiredRuntimeGate},null,2));
if(result.failed)process.exitCode=1;
