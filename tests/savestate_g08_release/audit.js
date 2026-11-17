const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto');
const d=__dirname,root=p.resolve(d,'../..'),read=f=>fs.readFileSync(p.join(d,f),'utf8'),hash=b=>crypto.createHash('sha256').update(b).digest('hex');
function requireThat(x,m){if(!x)throw Error(m)}
const base=JSON.parse(read('baseline.json'));
requireThat(base.head==='f205b05dc058fc5f7f2432779b61e8f3b0e22519','wrong baseline');
for(const [f,h] of Object.entries(base.files))requireThat(hash(fs.readFileSync(p.join(root,f)))===h,'changed tracked source '+f);
const git=args=>cp.execFileSync('git',args,{cwd:root,encoding:'utf8'}).trim();
requireThat(!git(['diff','--name-only'])&&!git(['diff','--cached','--name-only']),'tracked/index changes');
requireThat(git(['rev-parse','HEAD'])===base.head,'HEAD changed');
requireThat(git(['branch','--show-current'])==='investigate/savestate-g08-release','branch changed');
const files=['final_reference.log','final_replay.log','final_stalls.log'];
const logs=Object.fromEntries(files.map(f=>[f,read(f)]));
for(const [f,s] of Object.entries(logs)){
requireThat(!/\*\* (?:Error|Fatal|Failure)|Errors: [1-9]/.test(s)&&/# End time:/.test(s),'incomplete/failed '+f);
requireThat(s.includes('PSG_CONFIG tone6 cnt4 out1 refTone6 refCnt4'),'invalid tone '+f);
requireThat(s.includes('LATE_AUDIO_CAPTURE cycle656704 phase1 div2'),'missing capture evidence '+f);
}
requireThat(logs[files[0]].includes('PASS REFERENCE N20000'),'reference did not finish');
const results={};
for(const f of files.slice(1)){
let s=logs[f];requireThat(s.includes('PASS CHARACTERIZED'),'incomplete characterizer '+f);
const rows=[...s.matchAll(/RESULT pass(\d+) errors(\d+) first(-?\d+) raw_errors(\d+) descriptor([0-9a-f]+)/g)].map(m=>({pass:+m[1],differences:+m[2],first:+m[3],rawDifferences:+m[4],descriptor:m[5]}));
requireThat(rows.length===4,'wrong replay count '+f);
rows.forEach((r,i)=>{const n=i===0&&f==='final_replay.log'?0:14;requireThat(r.pass===i&&r.differences===n&&r.first===(n?1152:-1)&&r.rawDifferences===0&&r.descriptor==='0001250150534758','unexpected causal result '+f)});
const q=[...s.matchAll(/Q_HISTORY pass(\d+) cfg([0-9a-f]+) ext([0-9a-f]+) div(\d+) psg(-?\d+) audio([0-9a-f]+)\/([0-9a-f]+)/g)].map(m=>({pass:+m[1],cfg:m[2],ext:m[3],div:+m[4],psg:+m[5],left:m[6],right:m[7]}));
requireThat(q.length===3&&new Set(q.map(x=>x.cfg)).size===3,'Q histories not distinct');
results[f]={rows,q,sha256:hash(s)};
}
function image(f){const a=read(f).split(/\r?\n/).filter(x=>x&&!x.startsWith('//'));requireThat(a.length===12288&&a.every(x=>/^[0-9a-f]{16}$/i.test(x)),'unknown/incomplete image '+f);const b=Buffer.alloc(98304);a.forEach((x,i)=>b.writeBigUInt64LE(BigInt('0x'+x),i*8));requireThat(a[0x1a].slice(0,6)==='48430f','not v15');return{sha256:hash(b),words:a.length,bytes:b.length};}
const im=image('image.hex'),saved=image('image_save.hex');requireThat(im.sha256===saved.sha256,'LOAD changed image');
const unstalled=image('image_unstalled.hex');requireThat(im.sha256===unstalled.sha256,'transport changed complete image');
requireThat(read('savestates_sim.sv')===require('../savestate_g06_g10_fix/controller_adapter')(p.join(root,'rtl/savestates.sv')),'stale controller adapter');
const fixtureFiles=['prepare.js','audio_tb.sv','savestates_sim.sv','T80_sim.vhd','T80s_sim.vhd','pause_fixture.sv','rom.hex','compile.do','run.do','run.ps1'];
const evidenceHashes=Object.fromEntries(fixtureFiles.concat(['reference.dat','compile.log']).map(f=>[f,hash(fs.readFileSync(p.join(d,f)))]));
const reports=['savestate_g_closure','savestate_g06_g10_release','savestate_g06_g10_fix','savestate_g05_background_fix','savestate_g01_cpu_restart_fix','savestate_systeme_pause_fix'];
const out={classification:'CONFIRMED - FIX REQUIRED',head:base.head,branch:git(['branch','--show-current']),format:15,groups:2,runtimeCases:3,referenceCases:1,replayCases:2,loads:6,saveOnlySegments:2,hostComparisons:160000,rawDifferences:0,audioPairDifferences:98,completeImage:im,unstalledImage:unstalled,knownImageCollisionPairs:0,results,trackedHashesChecked:Object.keys(base.files).length,productionUnchanged:true,staged:false,diffStat:git(['diff','--stat']),status:git(['status','--short']),readReports:Object.fromEntries(reports.map(x=>[x,hash(fs.readFileSync(p.join(root,'tests',x,'review.md')))])),sourceHashes:Object.fromEntries(['SMS.sv','rtl/system.vhd','rtl/AudioMix.vhd','rtl/jt89/jt89.v','rtl/jt89/jt89_mixer.v','rtl/savestates.sv'].map(f=>[f,hash(fs.readFileSync(p.join(root,f)))]))};
out.acceptedDistinctOutputCacheCollisionPairs=0;out.equalImageDifferentTransportResumePairs=1;out.evidenceHashes=evidenceHashes;
fs.writeFileSync(p.join(d,'results.json'),JSON.stringify(out,null,2)+'\n');
console.log(JSON.stringify({classification:out.classification,loads:out.loads,audioPairDifferences:98,rawDifferences:0,completeImage:im,productionUnchanged:true}));
