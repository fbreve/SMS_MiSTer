const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto');const d=__dirname,root=p.resolve(d,'../..');
const read=f=>fs.readFileSync(p.join(d,f),'utf8'),sha=b=>crypto.createHash('sha256').update(b).digest('hex'),check=(b,m)=>{if(!b)throw Error(m)};
const baseline=JSON.parse(read('baseline.json'));const git=(...a)=>cp.execFileSync('git',a,{cwd:root,encoding:'utf8'}).trim();
check(git('rev-parse','HEAD')===baseline.head,'HEAD changed');check(git('branch','--show-current')==='fix/savestate-g08-release','branch changed');
for(const[f,h]of Object.entries(baseline.files))check(sha(fs.readFileSync(p.join(root,f)))===h,'production changed before sufficiency '+f);
check(!git('diff','--name-only')&&!git('diff','--cached','--name-only'),'tracked/index changes');
function clean(f,marker){let s=read(f);check(s.includes('# End time:')&&s.includes(marker)&&!/\*\* (?:Error|Fatal|Failure)|Errors: [1-9]/.test(s),'failed/incomplete '+f);return s}
const results={};
for(const kind of ['baseline','prototype']){
clean(kind+'/reference.log','PASS REFERENCE N20000');results[kind]={};
for(const id of ['unstalled','stalled']){const f=kind+'/'+id+'.log',s=clean(f,'PASS CHARACTERIZED');const rows=[...s.matchAll(/RESULT pass(\d+) errors(\d+) first(-?\d+) raw_errors(\d+) descriptor([0-9a-f]+)/g)].map(m=>({pass:+m[1],audioDifferences:+m[2],first:+m[3],rawDifferences:+m[4],descriptor:m[5]}));check(rows.length===4,'missing original LOADs');rows.forEach((r,i)=>{const n=kind==='prototype'||(id==='unstalled'&&i===0)?0:14;check(r.audioDifferences===n&&r.rawDifferences===0,'original witness outcome changed')});results[kind][id]={rows,sha256:sha(s)};}}
const natural=[];
for(const id of ['history0','history1','bus_stereo_phase1']){const f='proof_matrix/'+id+'/replay.log',s=clean(f,'PASS MATRIX replays1 N24000');check((s.match(/PASS SUFFIX/g)||[]).length===2,'missing prototype suffix');natural.push({id,sha256:sha(s)});}
function image(f){const words=read(f).split(/\r?\n/).filter(x=>x&&!x.startsWith('//'));check(words.length===12288&&words.every(x=>/^[0-9a-f]{16}$/i.test(x)),'unknown image '+f);let b=Buffer.alloc(98304);words.forEach((x,i)=>b.writeBigUInt64LE(BigInt('0x'+x),i*8));return sha(b)}
const image0=image('proof_matrix/history0/image.hex'),image1=image('proof_matrix/history1/image.hex');check(image0===image1,'natural equal-image search failed');
for(const fixture of ['proof_matrix','raw_baseline']){const s=read(fixture+'/bus_capture10_div14/replay.log');check(s.includes('** Fatal: raw PSG/div mismatch pass0 k0'),'missing contradictory production evidence '+fixture);results[fixture+'_rawFailure']={sha256:sha(s),firstRawMismatch:0};}
const raw=clean('raw_characterization/bus_capture10_div14/replay.log','PASS MATRIX CHARACTERIZED RAW DEFECT');
const audio=[...raw.matchAll(/ARCHITECTURAL_AUDIO_DIFFERENCE pass0 k(\d+) audio([0-9a-f]+) expected([0-9a-f]+) phase([01])\/([01])/g)].map(m=>({k:+m[1],actual:m[2],expected:m[3],phaseActual:+m[4],phaseExpected:+m[5]}));
check(audio.length>0&&audio.every(x=>x.phaseActual===x.phaseExpected),'not isolated from mixer phase');
check(raw.includes('RAW_EDGE_PRE cycle658781 state41 freeze1 clkd11 rawCE0 gatedCE0 refCE0 cen160/1 div15/15 cnt2/2'),'missing pending edge causality');
check(read('raw_baseline/savestates_sim.sv')===require('../savestate_g06_g10_fix/controller_adapter')(p.join(root,'rtl/savestates.sv')),'raw baseline not actual v15 adapter');
const out={status:'FIX INCOMPLETE',productionImplementation:false,phasePrototypePassed:true,sufficiencyPassed:false,blockedBy:'Unchanged v15 accepted SAVE suppresses a pending cen_16 before T+1; phase-only replay fails raw PSG equality.',head:baseline.head,format:15,baselineOriginalLoads:6,baselinePairDifferences:98,prototypeOriginalLoads:6,prototypeOriginalPairDifferences:0,otherPrototypeLoads:3,naturalImagePair:{image0,image1,equal:true,earlierAudioHistoriesDifferent:true},rawCapture:{cycle:658780,phase:10,preDivider:14,postDivider:15,firstRawMismatch:0,firstAudioMismatch:audio[0],audioDifferencesFirst16Clocks:audio.length},completedRuntimes:18,independentReferences:8,dutRuntimes:10,expectedStrictFailures:2,results,natural,productionHashesChecked:Object.keys(baseline.files).length,diffStat:git('diff','--stat'),statusShort:git('status','--short'),staged:false,quartusRun:false};
fs.writeFileSync(p.join(d,'sufficiency.json'),JSON.stringify(out,null,2)+'\n');
console.log(JSON.stringify({status:out.status,sufficiencyPassed:false,productionUnchanged:true,firstRawMismatch:0,firstAudioMismatch:audio[0],naturalEqualImage:image0}));
