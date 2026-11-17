// Fail-closed full simulation/build gate. --progress writes a partial ledger.
const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto'),assert=require('assert');
const d=__dirname,root=p.resolve(d,'../..'),progress=process.argv.includes('--progress'),sha=b=>crypto.createHash('sha256').update(b).digest('hex'),norm=s=>s.toString().replace(/\r\n/g,'\n'),read=f=>fs.readFileSync(p.join(d,f),'utf8'),json=f=>JSON.parse(read(f));
const groups={original:['h0','h1'],rich:['mode4','gg','text','graphics1','graphics2','mixed_m3','sms224','pal240','scroll'],mode_switch:['special'],visible_text:['early'],dead_text_bits:['h0','h1'],q:['history'],dual_render:['primary','secondary','both'],g02:['active'],g03:['bus'],g04:['pending'],g06:['sanity_collision','sanity_overflow'],dual_irq:['enabled'],hl:['edges'],stalls:['deterministic','lfsr','phases','full_flush'],masked:['masked']};
const ledger={head:cp.execFileSync('git',['rev-parse','HEAD'],{cwd:root}).toString().trim(),production:{},runtime:[],sanity:[],failures:[],missing:[],units:[],collisionSearch:{},phaseCodes:[]};
function checkLog(file,marker){if(!fs.existsSync(p.join(d,file))){ledger.missing.push(file);return null;}let s=read(file);if(/\*\* (?:Error|Fatal|Failure)|Errors: [1-9]/.test(s)){ledger.failures.push(file);return null;}if(!s.includes('# End time:')||!marker.test(s)){ledger.missing.push(file);return null;}return s;}
const initial=json('baseline.json'),gated=json('sufficiency_pre_edit.json'),production=json('production_sources.json');assert.equal(ledger.head,initial.head);assert.equal(cp.execFileSync('git',['branch','--show-current'],{cwd:root}).toString().trim(),'fix/savestate-g05-background');
for(const[f,h]of Object.entries(initial.files)){const b=fs.readFileSync(p.join(root,f));if(production[f]){assert.equal(sha(b),production[f].rawSha,f);assert.equal(sha(norm(b)),production[f].proofNormalizedSha,f);assert.equal(sha(norm(b)),gated.sources[f],f);ledger.production[f]=sha(b);}else assert.equal(sha(b),h,'unintended tracked edit '+f);}
assert.equal(cp.execFileSync('git',['diff','--cached','--name-only'],{cwd:root}).toString(),'','staged changes');
const adapter=require('../savestate_g06_g10_fix/controller_adapter')(p.join(root,'rtl/savestates.sv'));
assert.equal(sha(norm(read('component/vdp_background.vhd'))),gated.sources['rtl/vdp_background.vhd'],'proof-gated component source');
assert.equal(read('format/savestates_sim.sv'),adapter,'proof-gated format controller');
assert.equal(sha(read('component/simulation.log')),gated.component.sha,'immutable pre-edit component evidence');
assert.equal(sha(read('format/simulation.log')),gated.format.sha,'immutable pre-edit format evidence');
for(const[key,cases]of Object.entries(groups)){const family='integrated_'+key;assert.equal(read(family+'/savestates_sim.sv'),adapter,'controller adapter '+family);let tb=read(family+'/vdp_tb.sv');assert(!/prototype_(?:apply|snap)/.test(tb),'side-record bypass '+family);
 // Read-only audit declarations, assignments and forwarding are the only
 // differences in the actual VDP hierarchy; all transition logic must match.
 for(const file of ['vdp_background.vhd','vdp_main.vhd','vdp.vhd','vdp_sprites.vhd','vdp_sprite_shifter.vhd']){
  let s=read(family+'/rtl/'+file).replace(/\s*(?:signal\s+)?audit\w*\s*:\s*out\s+std_logic_vector\([^;]+;/g,'').replace(/\s*signal\s+audit\w*\s*:\s*std_logic_vector\([^;]+;/g,'').replace(/\s*audit\w*(?:\([^)]*\))?\s*<=[^;]+;/g,'').replace(/\s*audit\w*\s*=>\s*audit\w*\s*,/g,'');
  let actual=norm(fs.readFileSync(p.join(root,'rtl',file)));
  if(file==='vdp_main.vhd'||file==='vdp.vhd'){
   // Named ports can appear in a different order in inherited observers.
   const decl=/ss_bg_\w+\s*:[^;]+;/g,map=/ss_bg_\w+\s*=>\s*ss_bg_\w+\s*,/g,compact=x=>x.replace(/\s+/g,'');
   for(const re of [decl,map]){assert.deepEqual((s.match(re)||[]).map(compact).sort(),(actual.match(re)||[]).map(compact).sort(),'G05 ports '+family+'/'+file);s=s.replace(re,'');actual=actual.replace(re,'');}
  }
  assert.equal(s.replace(/\s+/g,''),actual.replace(/\s+/g,''),'VDP source identity '+family+'/'+file);
 }
 for(const id of cases){const reference=key==='original'?'baseline/reference_'+id:key==='stalls'&&id!=='deterministic'?'integrated_stalls/reference_deterministic':family+'/reference_'+id,dir=family+'/dut_'+id;
 const ref=checkLog(reference+'/simulation.log',/PASS UNINTERRUPTED REFERENCE/),dut=checkLog(dir+'/simulation.log',/PASS (?:RICH )?V15 VDP/);
 const record={family,case:id,reference,replays:key==='dead_text_bits'?1:key==='stalls'&&id==='phases'?13:3,passed:!!ref&&!!dut};
 if(ref){record.referenceLogSha=sha(ref);record.samples=+(ref.match(/PASS UNINTERRUPTED REFERENCE samples(\d+)/)||[])[1];let data=read(reference+'/reference.dat').trim().split(/\r?\n/);assert.equal(data.length,record.samples,'reference length '+reference);assert(data.every(l=>l.trim().split(/\s+/).every(v=>/^[0-9a-f]+$/i.test(v))),'unknown reference '+reference);record.referenceDataSha=sha(data.join('\n'));
 if(fs.existsSync(p.join(d,reference,'native_reference.dat'))){const native=read(reference+'/native_reference.dat').trim().split(/\r?\n/);assert.equal(native.length,10000,'native reference length');assert(native.every(l=>l.trim().split(/\s+/).every(v=>/^[0-9a-f]+$/i.test(v))),'unknown native reference');record.nativeReferenceSha=sha(native.join('\n'));}}
 if(dut){record.logSha=sha(dut);const results=[...dut.matchAll(/RESULT pass(\d+) collisionSamples(\d+) statusBusSamples(\d+)/g)];assert.equal(results.length,record.replays,'replays '+dir);assert(results.every(m=>+m[2]===0&&+m[3]===0),'architectural replay '+dir);assert(!/TEXT_HISTORY_RESULT pass\d+ visiblePixelDiff[1-9]|TEXT_HISTORY_RESULT pass\d+ visiblePixelDiff0 fetchDiff[1-9]/.test(dut),'G05 mismatch '+dir);
 record.completeImageSha=image(dir).sha;
 record.capture=[...dut.matchAll(/CAPTURE_BG139 primary([0-9a-f]+) secondary([0-9a-f]+)/gi)].map(m=>({primary:m[1],secondary:m[2]}));assert(record.capture.length>0,'missing capture '+dir);
 for(const m of dut.matchAll(/NATIVE_ENABLE_ORDER PASS phasecode(\d+)/g))ledger.phaseCodes.push(+m[1]);
 record.nativeOrderChecks=[...dut.matchAll(/NATIVE_ENABLE_ORDER PASS/g)].length;assert(record.nativeOrderChecks>=record.replays,'native order '+dir);
 if(key==='q')assert.equal([...dut.matchAll(/G05_DISTINCT_GUEST_Q/g)].length,3,'distinct guest Q histories');
 if(key==='stalls'&&id==='phases'){record.naturalPhases=[...dut.matchAll(/NATURAL_TRANSPORT_PHASE (\d+)/g)].map(m=>+m[1]);assert.equal(new Set(record.naturalPhases).size,12,'natural release phases');}
 }
 ledger.runtime.push(record);
 }}
for(const f of ['sanity_g01','sanity_nmi','sanity_pause']){assert.equal(read(f+'/'+(f==='sanity_pause'?'savestates_sim.sv':'savestates_integrated.sv')),adapter);for(const c of json(f+'/cases.json')){let s=checkLog(f+'/'+c.id+'.log',/PASS (?:G01 TRACE|F16 fixed|FIXED case)/);let loads=s?(f==='sanity_pause'?[...s.matchAll(/CURRENT HOST LOAD case/g)].length:+s.match(/PASS (?:G01 TRACE|F16 fixed)[^\r\n]* loads(\d+)/)[1]):0;if(s)assert.equal(loads,f==='sanity_pause'?(c.args.CASE>=7?2:0):3,'sanity LOAD accounting');ledger.sanity.push({fixture:f,id:c.id,passed:!!s,loads,...(s?{logSha:sha(s)}:{})});}}
for(const [file,marker]of [['component/simulation.log',/PASS BG139_MITER cases368 exactPixelStates285959 semanticPositions240 restoresAll240/],['format/simulation.log',/PASS V15 FORMAT rejected511 accepted398/]]){const s=checkLog(file,marker);ledger.units.push({file,passed:!!s,...(s?{logSha:sha(s)}:{})});}
function image(dir){const words=read(dir+'/image.hex').trim().split(/\s+/);assert(words.length===12288&&words.every(w=>/^[0-9a-f]{16}$/i.test(w)),'complete known image '+dir);assert(words[26].startsWith('48430f'));assert.equal(words[50],'008b0f0047354231');let b=Buffer.alloc(98304);words.forEach((w,i)=>b.writeBigUInt64LE(BigInt('0x'+w),i*8));return{words,sha:sha(b)};}
for(const key of ['original','dead_text_bits']){if(ledger.runtime.filter(c=>c.family==='integrated_'+key).every(c=>c.passed)){const im=[0,1].map(h=>image('integrated_'+key+'/dut_h'+h));const equal=im[0].sha===im[1].sha;assert.equal(equal,key==='dead_text_bits');let differences=[];for(let i=0;i<12288;i++)if(im[0].words[i]!==im[1].words[i])differences.push(i.toString(16));ledger.collisionSearch[key]={completeBinarySha:im.map(a=>a.sha),equal,differingWordAddresses:differences};
 if(key==='dead_text_bits'){let whole=[0,1].map(h=>read('integrated_dead_text_bits/reference_h'+h+'/reference.dat'));assert.equal(whole[0],whole[1],'entire future including audit');ledger.collisionSearch[key].fullFutureSha=sha(whole[0]);
 let raw=[0,1].map(h=>{let s=read('integrated_dead_text_bits/dut_h'+h+'/simulation.log');s=s.slice(s.lastIndexOf('# ACCEPT save1'));return s.match(/ARM x\d+ y\d+[^\r\n]* BG([0-9a-f]+) EXTRA/i)[1];});assert.equal((BigInt('0x'+raw[0])^BigInt('0x'+raw[1])).toString(16),'600','only globally dead text bits differ at accepted SAVE');ledger.collisionSearch[key].rawBG=raw;
 let futures=whole.map(s=>s.trim().split(/\r?\n/).map(l=>l.trim().split(/\s+/).filter((v,i)=>i!==8).join(' ')).join('\n'));assert.equal(futures[0],futures[1]);ledger.collisionSearch[key].equalFutureSamples=42000;ledger.collisionSearch[key].futureSha=sha(futures[0]);}
 }}
ledger.phaseCodes=[...new Set(ledger.phaseCodes)].sort();ledger.totalRuntimeCases=ledger.runtime.length;ledger.totalSanityCases=ledger.sanity.length;ledger.runtimeLoads=ledger.runtime.reduce((s,c)=>s+c.replays,0);ledger.sanityLoads=ledger.sanity.reduce((s,c)=>s+c.loads,0);ledger.totalLoads=ledger.runtimeLoads+ledger.sanityLoads;ledger.groups={VDP:Object.keys(groups).length,CPU_NMI_Pause:3,unit:2,total:Object.keys(groups).length+5};ledger.pass=ledger.failures.length===0&&ledger.missing.length===0;
fs.writeFileSync(p.join(d,progress?'simulation_progress.json':'simulation_results.json'),JSON.stringify(ledger,null,2));
console.log(JSON.stringify({pass:ledger.pass,runtime:ledger.runtime.filter(c=>c.passed).length+'/'+ledger.runtime.length,sanity:ledger.sanity.filter(c=>c.passed).length+'/'+ledger.sanity.length,phaseCodes:ledger.phaseCodes,failures:ledger.failures,missing:progress?ledger.missing.length:ledger.missing},null,2));
if(!progress){assert(ledger.pass,'Mandatory simulation gate incomplete');assert.deepEqual(ledger.phaseCodes,[0,1,2,3]);}
