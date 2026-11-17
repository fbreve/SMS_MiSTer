const fs=require('fs'),p=require('path'),assert=require('assert'),crypto=require('crypto'),readline=require('readline'),cp=require('child_process'),d=__dirname;
const sha=b=>crypto.createHash('sha256').update(b).digest('hex');
const read=f=>{const b=fs.readFileSync(p.join(d,f));return b.toString(b[0]===255&&b[1]===254?'utf16le':'utf8')};
const check=(f,pass)=>{const s=read(f);assert(s.includes(pass),f+' missing '+pass);assert(/Errors: 0/.test(s),f+' incomplete');assert(!/\*\* (Error|Fatal|Failure):|Errors: [1-9]/.test(s),f+' simulator error');return s};
async function main(){
 const cases=[];for(let phase=0;phase<72;phase++)for(let skew=0;skew<2;skew++)cases.push({id:`sweep_p${phase}_s${skew}`,n:6000,loads:1,phase,skew});
 for(const id of ['directed70_left_fm','directed70_right_fm','directed70_left_mixed','directed70_right_mixed','directed70_native10_left','directed70_native10_right'])cases.push({id,n:48000,loads:3});
 for(const id of ['turbo70_left','turbo70_right','hidden_fm_systeme','production_full_flush'])cases.push({id,n:48000,loads:1});
 for(const id of ['long_fm','long_mixed'])cases.push({id,n:1080000,loads:1});
 for(const id of ['actual_silent_left','actual_silent_right'])cases.push({id,n:48000,loads:3});
 cases.push({id:'beam_candidate',n:6000,loads:1});
 cases.push({id:'beam_reset_candidate',n:6000,loads:1,phase:70,skew:599700});
 cases.push({id:'perturbation_probe',n:48000,loads:3});
 for(let seed=101;seed<=124;seed++)cases.push({id:'random_capture_'+seed,n:48000,loads:1,seed});
 for(let h=0;h<2;h++)cases.push({id:'equal_candidate_h'+h,n:48000,loads:2});
 const ledgers=[];
 for(const c of cases){
  check(c.id+'/reference.log','PASS REFERENCE');const s=check(c.id+'/replay.log','PASS G08FM');
  const results=[...s.matchAll(/# RESULT pass(\d+) errors(\d+) first(-?\d+) raw_errors(\d+)/g)];assert.equal(results.length,c.loads+1,c.id+' suffix count');
  for(const r of results)assert(r[2]==='0'&&r[3]==='-1'&&r[4]==='0',c.id+' audio/PSG');
  const fm=[...s.matchAll(/# FM_RESULT pass(\d+) errors(\d+) first(-?\d+)/g)];assert.equal(fm.length,c.loads+1);for(const r of fm)assert(r[2]==='0'&&r[3]==='-1',c.id+' rawFM');
  const rows=read(c.id+'/restored_state.dat').trim().split(/\r?\n/);assert.equal(rows.length,c.loads*104,c.id+' actual state rows');
  const state=[];for(let load=1;load<=c.loads;load++){const a=[];for(let row=0;row<104;row++){const m=rows[(load-1)*104+row].match(/^load(\d+) row(\d+) actual([0-9a-f]+) expected([0-9a-f]+)$/i);assert(m&&+m[1]===load&&+m[2]===row&&m[3]===m[4],c.id+' state');a.push(m[3]);}state.push(a);assert(s.includes(`PASS OPLL_READBACK load${load} rows104`));}
  let k=0,firstExec,firstUpdate,firstLeft,firstRight,firstPair;const prefixHash=crypto.createHash('sha256');
  for await(const line of readline.createInterface({input:fs.createReadStream(p.join(d,c.id,'reference.dat')),crlfDelay:Infinity})){
   const cols=line.trim().split(/\s+/);assert.equal(cols.length,10);if(c.id.startsWith('actual_silent_'))assert.equal(parseInt(cols[4],16),0,'actual guest-programmed PSG silence');if(k<6000)prefixHash.update(cols.join(' ')+'\n');const native=parseInt(cols[5],16),postPhase=+cols[9];
   const event={k,native,rawFM:cols[6],counter:parseInt(cols[7],16),published:+cols[8],nextPhase:postPhase,pair:cols[0]};
   if(k===0)firstPair=event;if(!firstExec&&(native===10||native===25))firstExec=event;if(!firstUpdate&&cols[8]==='1')firstUpdate=event;
   if(!firstLeft&&postPhase===1)firstLeft=event;if(!firstRight&&postPhase===0)firstRight=event;k++;
  }
  assert.equal(k,c.n,c.id+' reference length');assert(firstExec&&firstUpdate&&firstLeft&&firstRight);
  const firstActual=[...s.matchAll(/# FIRST pass(\d+) k0 .*mix([0-9a-f]+)\/([0-9a-f]+) phase([01])/gi)].map(m=>({pass:+m[1],pair:m[2]+m[3],nextPhase:+m[4]}));assert.equal(firstActual.length,c.loads+1);for(const a of firstActual)assert(a.pair===firstPair.pair&&a.nextPhase===firstPair.nextPhase,c.id+' first pair');
  const accepted=[...s.matchAll(/# ACCEPT save([01]) counter(\d+) native(\d+) fmCE([01]) phase([01]) raw([0-9a-f]+) mixed([0-9a-f]+)\/([0-9a-f]+)/gi)].map(m=>({saving:+m[1],counter:+m[2],native:+m[3],fmCE:+m[4],phase:+m[5],raw:m[6],pair:m[7]+m[8]}));
  if(c.id.startsWith('beam_')){
   const words=read(c.id+'/image_save.hex').split(/\r?\n/).filter(x=>/^[0-9a-f]{16}$/i.test(x));assert.equal(words.length,12288);
   const video=BigInt('0x'+words[0x1a]);c.savedVideo={hcount:Number(video>>13n&511n),vcount:Number(video>>4n&511n),vblank:Number(video&1n)};
   assert(c.savedVideo.hcount<=256&&c.savedVideo.vblank===1,c.id+' real video accepted window');
  }
  if(c.phase!==undefined)assert.equal(accepted.find(a=>a.saving).counter,c.phase,c.id+' actual phase');
  ledgers.push({...c,pairs:c.n*(c.loads+1),accepted,firstActual,loadsVerified:state.map((rows,i)=>({load:i+1,rows,firstExecution:firstExec,firstPublication:firstUpdate,firstConsumption:firstPair,firstLeft,firstRight})),prefix6000SHA:prefixHash.digest('hex'),referenceSHA:sha(fs.readFileSync(p.join(d,c.id,'reference.dat'))),imageSHA:sha(fs.readFileSync(p.join(d,c.id,'image_save.hex')))});
 }
 const imageGroups=new Map();for(const c of ledgers){const prior=imageGroups.get(c.imageSHA);if(prior){assert.equal(c.prefix6000SHA,prior.prefix6000SHA,'equal-image future collision '+c.id);prior.ids.push(c.id);}else imageGroups.set(c.imageSHA,{prefix6000SHA:c.prefix6000SHA,ids:[c.id]});}
 fs.writeFileSync(p.join(d,'image_future_search.json'),JSON.stringify({cases:ledgers.length,distinctImages:imageGroups.size,comparedPrefixPairs:6000,divergentGroups:0,equalGroups:[...imageGroups.values()].filter(x=>x.ids.length>1)},null,2));
 const f01=[];for(let seed=1;seed<=16;seed++){
  const files={};for(const f of ['reference.dat','rom.hex']){const a=fs.readFileSync(p.join(d,`f01/random_${seed}`,f)),b=fs.readFileSync(p.join(d,`../savestate_f01_opll_fix/random_${seed}`,f));assert(a.equals(b),'retained independent F01 oracle '+seed+' '+f);files[f]=sha(a);}
  const s=check(`f01/random_${seed}/replay.log`,'PASS F01');const r=[...s.matchAll(/# RESULT pass(\d+) errors(\d+) first(-?\d+) raw_errors(\d+)/g)];assert.equal(r.length,4);for(const m of r)assert(m[2]==='0'&&m[3]==='-1'&&m[4]==='0');assert.equal([...s.matchAll(/# FM_RESULT pass\d+ errors0 first-1/g)].length,4);f01.push({seed,pairs:192000,files});
 }
 const release=JSON.parse(read('release_manifest.json'));for(const c of release){check(`${c.family}/${c.id}/replay.log`,'PASS MATRIX');for(const f of ['reference.dat','rom.hex','replay.do'])assert.equal(sha(fs.readFileSync(p.join(d,c.family,c.id,f))),c.files[f]);}
 for(const stall of [0,1]){const s=check(`release_original/stall${stall}.log`,'PASS CHARACTERIZED');assert.equal([...s.matchAll(/# RESULT pass\d+ errors0 first-1 raw_errors0/g)].length,4);}
 check('psg/simulation.log','PASS');check('imports/simulation.log','PASS');const format=check('format/simulation.log','PASS V19 FORMAT');
 for(const [id,errors,first]of [['beam_baseline',0,-1],['beam_reset_baseline',1,0]]){
  const s=check(id+'/replay.log','PASS G08FM');assert.equal([...s.matchAll(new RegExp(`# RESULT pass\\d+ errors${errors} first${first} raw_errors0`,'g'))].length,2,id+' physical-beam characterization');assert.equal([...s.matchAll(/# FM_RESULT pass\d+ errors0 first-1/g)].length,2);assert(s.includes('PASS OPLL_READBACK load1 rows104'));
 }
 const beamProof=[];for(const prefix of ['beam','beam_reset']){
  const ids=[prefix+'_baseline',prefix+'_candidate'];const images=ids.map(id=>read(id+'/image_save.hex').split(/\r?\n/).filter(x=>/^[0-9a-f]{16}$/i.test(x)).map(x=>BigInt('0x'+x)));
  const coords=images.map(words=>({hcount:Number(words[26]>>13n&511n),vcount:Number(words[26]>>4n&511n),vblank:Number(words[26]&1n)}));assert.deepEqual(coords[0],coords[1]);assert(coords[0].hcount<=256&&coords[0].vblank===1);
  const rows=images.map(words=>Array.from({length:104},(_,i)=>Number(words[0x2998+Math.floor(i/2)]>>BigInt(i%2*32)&0xffffffffn)));assert.deepEqual(rows[0],rows[1],'paired real-beam OPLL image state');
  assert.equal(read(ids[0]+'/reference.dat'),read(ids[1]+'/reference.dat'),'paired real-beam independent references');
  beamProof.push({prefix,ids,savedVideo:coords[0],OPLLRowsIdentical:104,referencePairs:6000,referenceSHA:sha(Buffer.from(read(ids[0]+'/reference.dat'))),baselineFirstPairErrors:prefix==='beam'?0:1,candidateErrors:0});
 }
 fs.writeFileSync(p.join(d,'beam_proof.json'),JSON.stringify({note:'Unchanged production video timing. Reset skew599700 is a multiple of the joint30-host-clock CE/mixer period; video has no reset_n port and advances throughout the held CPU/OPLL reset. No historical register/phase is forced.',cases:beamProof},null,2));
 const q=check('perturbation_probe/replay.log','PASS G08FM');assert.equal([...q.matchAll(/Q_STRENGTH load\d+ total\d+ phase[1-9]\d* envelope[1-9]\d* feedback[1-9]\d*/g)].length,3);
 const equal=[];for(const variant of ['baseline','candidate']){
  if(variant==='baseline')for(let h=0;h<2;h++){
   const s=check(`equal_baseline_h${h}/replay.log`,'PASS G08FM');
   assert.equal([...s.matchAll(/# RESULT pass\d+ errors1 first0 raw_errors0/g)].length,3,'baseline known first-pair defect only');
   assert.equal([...s.matchAll(/# FM_RESULT pass\d+ errors0 first-1/g)].length,3);
  }
  if(variant==='baseline'){
   const first=h=>[...read(`equal_baseline_h${h}/replay.log`).matchAll(/# FIRST pass(\d+) k0 .*mix([0-9a-f]+)\/([0-9a-f]+) phase([01])/gi)].map(m=>m.slice(1));
   assert.equal(first(0).length,3);assert.deepEqual(first(0),first(1),'identical v18 images must replay same first pair too');
  }
  const a=read(`equal_${variant}_h0/image_save.hex`),b=read(`equal_${variant}_h1/image_save.hex`);assert.equal(a,b,variant+' complete image history pair');assert.equal(read(`equal_${variant}_h0/reference.dat`),read(`equal_${variant}_h1/reference.dat`),variant+' future history pair');equal.push({variant,imageSHA:sha(Buffer.from(a)),referenceSHA:sha(Buffer.from(read(`equal_${variant}_h0/reference.dat`))),completeWords:12288});
 }
 fs.writeFileSync(p.join(d,'handoff_ledger.json'),JSON.stringify({note:'First execution occurs on a rising host edge with native phase10/25; the fixture advances the production-equivalent CE process at the preceding falling edge. Publication is actual pre-edge CE && counter70. Oracle events listed per LOAD are independently recorded and asserted equal by DUT on EVERY compared edge; actual 104-row readback and first pair are separately recorded. firstLeft/firstRight mean first selected channel update; BOTH externally observable halves at k0 are also recorded and asserted in firstActual.',cases:ledgers},null,2));
 const sourceHashes=Object.fromEntries(['SMS.sv','rtl/AudioMix.vhd','rtl/savestates.sv','rtl/system.vhd'].map(f=>[f,sha(fs.readFileSync(f))]));
 for(const[f,h]of Object.entries(sourceHashes))assert.equal(sha(fs.readFileSync(p.join(d,'candidate',f))),h,'tested candidate/root identity '+f);
 const baseline=JSON.parse(read('baseline.json'));
 for(const[f,h]of Object.entries(baseline.hashes))if(!(f in sourceHashes))assert.equal(sha(fs.readFileSync(f)),h,'unrelated production drift '+f);
 const head=cp.execFileSync('git',['rev-parse','HEAD'],{encoding:'utf8'}).trim();
 assert.equal(head,baseline.head,'baseline HEAD drift');
 assert.equal(cp.execFileSync('git',['branch','--show-current'],{encoding:'utf8'}).trim(),'investigate/savestate-g08-fm');
 assert.equal(cp.execFileSync('git',['diff','--cached','--name-only'],{encoding:'utf8'}).trim(),'','nothing may be staged');
 const gate={passed:true,head,sourceHashes,completed:new Date().toISOString(),mainCases:cases.length,mainLoads:cases.reduce((n,c)=>n+c.loads,0),mainPairs:ledgers.reduce((n,c)=>n+c.pairs,0),f01,releaseCases:release.length,originalReleaseSuffixes:8,equal,format:format.match(/PASS V19 FORMAT[^\r\n]*/)[0],handoffLedgerSHA:sha(fs.readFileSync(p.join(d,'handoff_ledger.json')))};
 fs.writeFileSync(p.join(d,'functional_gate.json'),JSON.stringify(gate,null,2));console.log(JSON.stringify(gate,null,2));
}
main().catch(e=>{console.error(e);process.exitCode=1});
