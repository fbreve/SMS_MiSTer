const fs=require('fs'),p=require('path'),crypto=require('crypto'),cp=require('child_process');
const d=__dirname,root=p.resolve(d,'../..'),read=f=>fs.readFileSync(p.join(d,f),'utf8'),sha=b=>crypto.createHash('sha256').update(b).digest('hex'),norm=s=>s.replaceAll('\r\n','\n'),check=(x,m)=>{if(!x)throw Error(m)};
const base=JSON.parse(read('baseline.json')),mapping={'SMS.sv':'SMS.sv','rtl/system.vhd':'system.vhd','rtl/savestates.sv':'savestates.sv','rtl/jt89/jt89.v':'jt89.v','rtl/jt89/jt89.vhd':'jt89.vhd'};
check(cp.execFileSync('git',['branch','--show-current'],{cwd:root,encoding:'utf8'}).trim()==='fix/savestate-g08-release','branch');
check(cp.execFileSync('git',['rev-parse','HEAD'],{cwd:root,encoding:'utf8'}).trim()===base.head,'HEAD');
for(const[f,h]of Object.entries(base.files))if(!mapping[f])check(sha(fs.readFileSync(p.join(root,f)))===h,'unrelated source changed '+f);
for(const[f,v]of Object.entries(mapping))check(norm(fs.readFileSync(p.join(root,f),'utf8'))===norm(read('proposed/'+v)),'proposal mismatch '+f);
const build=JSON.parse(read('build_inputs.json'));
for(const version of ['v15','v16'])for(const[f,h]of Object.entries(build.inputs[version]))check(sha(fs.readFileSync(p.join(d,'quartus_'+version,f)))===h,'build input changed '+version+'/'+f);
for(const f of Object.keys(mapping))check(sha(fs.readFileSync(p.join(root,f)))===build.inputs.v16[f],'candidate build snapshot differs '+f);
const logs=[];function pass(f,marker){const s=read(f);check(s.includes(marker)&&s.includes('# End time:')&&!/\*\* (?:Error|Fatal|Failure)|Errors: [1-9]/.test(s),'incomplete/failed '+f);logs.push({file:f,sha256:sha(s)});return s}
let loads=0,samples=0;const cases=[];
for(const suite of ['matrix','modes'])for(const c of [...JSON.parse(read(suite+'/cases.json')),...(suite==='modes'?JSON.parse(read(suite+'/boundary_cases.json')):[])]){
 pass(`${suite}/${c.id}/reference.log`,'PASS MATRIX REFERENCE');
 const s=pass(`${suite}/${c.id}/replay.log`,`PASS MATRIX replays${c.args.REPLAYS} N${c.args.N}`),rows=[...s.matchAll(/PASS SUFFIX pass(\d+) samples(\d+)/g)];
 check(rows.length===c.args.REPLAYS+1&&rows.every((m,i)=>+m[1]===i&&+m[2]===c.args.N),'suffix ledger '+c.id);
 loads+=c.args.REPLAYS;samples+=rows.length*c.args.N;cases.push({suite,id:c.id,loads:c.args.REPLAYS,samples:rows.length*c.args.N,pendingReplays:(s.match(/PENDING_REPLAY /g)||[]).length});
}
function image(f){const a=read(f).split(/\r?\n/).filter(x=>x&&!x.startsWith('//'));check(a.length===12288&&a.every(x=>/^[\da-f]{16}$/i.test(x)),'unknown/incomplete image '+f);const b=Buffer.alloc(98304);a.forEach((x,i)=>b.writeBigUInt64LE(BigInt('0x'+x),i*8));return sha(b)}
for(const c of cases){
 const f=`${c.suite}/${c.id}/image.hex`;image(f);
 const a=read(f).split(/\r?\n/).filter(x=>x&&!x.startsWith('//')).map(x=>BigInt('0x'+x)),meta=a[0x2f],phase=Number(meta&3n),div=Number((a[0x20]>>41n)&15n),tick=!!(meta&8n),pending=tick&&(phase===1||phase===3)&&div===15;
 check(c.pendingReplays===(pending?c.loads+1:0),'pending-event ledger '+c.id);
 c.capture={phaseCode:phase,divider:div,tick,pending};
}
const equalImage=image('matrix/history0/image.hex');check(equalImage===image('matrix/history1/image.hex'),'non-injective search images');
pass('original_combined/reference.log','PASS REFERENCE');
for(const id of ['unstalled','stalled']){const s=pass('original_combined/'+id+'.log','PASS CHARACTERIZED'),rows=[...s.matchAll(/RESULT pass(\d+) errors(\d+) first(-?\d+) raw_errors(\d+)/g)];check(rows.length===4&&rows.every(m=>+m[2]===0&&+m[4]===0),'original witness '+id)}
pass('raw_psg/simulation.log','PASS PSG replay: 128 cases');pass('format/simulation.log','PASS V16 FORMAT rejected512 accepted399');pass('legacy/simulation.log','PASS V16 LEGACY 18 loads');
// The final old64 fallback guard changes only ARM's initial LOAD value.
// Tagged LOAD overwrites this value in AUDIO_DESC/VIDEO before release.
const old=norm(read('controller_pre_legacy_fix.sv')),now=norm(read('proposed/savestates.sv'));
check(old.replace('audio_phase_snap<=audio_phase_out;',"audio_phase_snap<=do_save ? audio_phase_out : 1'b0;")===now,'single-line legacy source bridge');
const adapter=require('../savestate_g06_g10_fix/controller_adapter');
for(const suite of ['matrix','format','vdp_original','vdp_g06'])check(norm(read(suite+'/savestates_sim.sv'))===norm(adapter(p.join(d,'controller_pre_legacy_fix.sv'))),'archived adapter '+suite);
for(const suite of ['modes','original_combined','legacy'])check(norm(read(suite+'/savestates_sim.sv'))===norm(adapter(p.join(d,'proposed/savestates.sv'))),'final adapter '+suite);
for(const[suite,id]of [['vdp_original','h0'],['vdp_g06','sanity_collision'],['vdp_g06','sanity_overflow']]){
 pass(`${suite}/reference_${id}/simulation.log`,'PASS UNINTERRUPTED REFERENCE');
 pass(`${suite}/dut_${id}/simulation.log`,'PASS');
}
const result={pass:true,head:base.head,runtimeInvocations:logs.length,productionHashes:Object.fromEntries(Object.keys(mapping).map(f=>[f,sha(fs.readFileSync(p.join(root,f)))])),audioScenarios:cases.length,audioLoads:loads,audioComparedClockPairs:samples,originalLoads:6,rawPsgCases:128,rawPsgCyclesPerCase:20000,formatScenarios:911,legacyLoads:18,vdpLoads:9,equalImageSha256:equalImage,cases,sourceBridge:'Only ARM LOAD phase initialization differs in the earlier matrix/format/VDP controller; all tagged images overwrite before use. Final-source original six LOADs, twenty-two mode/boundary scenarios and eighteen compatibility LOADs cover the correction.',logs};
fs.writeFileSync(p.join(d,'simulation_results.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify({pass:true,audioScenarios:cases.length,audioLoads:loads,audioComparedClockPairs:samples}));
