const fs=require('fs'),p=require('path'),assert=require('assert'),crypto=require('crypto'),d=__dirname,root=p.resolve(d,'../..'),sha=b=>crypto.createHash('sha256').update(b).digest('hex'),adapter=require('../savestate_g06_g10_fix/controller_adapter');
const read=f=>fs.readFileSync(p.join(d,f),'utf8'),probe=process.argv.includes('--probe'),evidence=[];
function log(f,marker,extra,summary=true){const path=p.join(d,f);if(!fs.existsSync(path))throw Error('pending '+f);const b=fs.readFileSync(path),s=b.toString();assert(s.includes(marker)&&(!summary||/Errors: 0/.test(s))&&! /\*\* (Error|Fatal|Failure):|Errors: [1-9]|Failed to open readmem|Failed to open file/.test(s),'pending/failed '+f);if(extra)assert(s.includes(extra),f+' extra marker');evidence.push({file:f,sha256:sha(b),marker});return s;}
try{
 const baseline=require('./baseline.json');for(const[f,h]of Object.entries(baseline.hashes))assert.equal(sha(fs.readFileSync(p.join(root,f))),h,'production unchanged '+f);
 const candidate=read('candidate/rtl/savestates.sv'),adapted=adapter(p.join(d,'candidate/rtl/savestates.sv')),rows=require('./regression_manifest.json');
 const decode=require('./decode_equivalence.json');assert(decode.passed&&decode.contexts===256);assert.equal(decode.sourceSHA[1],sha(Buffer.from(candidate)));
 log('format/simulation.log','PASS CONSOLIDATION FORMAT rejected2032 accepted384');log('imports/simulation.log','PASS IMPORT ALL loads4 public96 public64');
 log('miter/simulation.log','PASS MITER ALL outputs101 profiles16');log('peripherals/simulation.log','PASS PERIPHERALS ALL outputs101 profiles16 loads48');log('evolution/simulation.log','PASS EVOLUTION ALL outputs101 profiles8 current24 public_rejections16');
 log('psg.log','PASS PSG replay: 128 cases');
 for(const seed of [1,10]){const s=log('random_'+seed+'/replay.log','PASS F01');assert.equal((s.match(/FM_RESULT pass[0-3] errors0 first-1/g)||[]).length,4);}
 const fixtures=[];
 for(const r of rows){log(r.family+'/'+r.name+'/simulation.log',r.marker,r.also);const f=r.family==='reg_g01'?'savestates_integrated.sv':'savestates_sim.sv';assert.equal(read(r.family+'/'+f),adapted.replace('900000','0'),'tested controller '+r.family);
  if(['reg_g05','reg_sprites','reg_g10','reg_dual','reg_g04'].includes(r.family)){
   const s=log(r.family+'/'+r.name+'/reference_new.log','PASS UNINTERRUPTED REFERENCE');
   // ModelSim prints the logical vdp_work alias, including when it maps to
   // ../golden_work. Prove the driver mapping and the original compiled input.
   assert(s.includes('Loading vdp_work.savestates'));
   assert(read('references.ps1').includes('& "$bin/vmap.exe" $r.library "../golden_work"'));
   assert(read(r.family+'/compile_golden.do').includes('-work golden_work'));
   assert(read(r.family+'/compile_golden.do').includes('golden_controller.sv'));
   assert.equal(read(r.family+'/golden_controller.sv'),adapter(p.join(root,'rtl/savestates.sv')).replace('900000','0'));
   log(r.family+'/compile_golden.log','do compile_golden.do',null,false);
  }
  const from=p.join(d,r.family,r.name);fixtures.push({family:r.family,name:r.name,files:fs.readdirSync(from).filter(f=>/\.(do|dat|hex)$/.test(f)).map(file=>({file,sha256:sha(fs.readFileSync(p.join(from,file)))}))});
 }
 for(const family of new Set(rows.map(r=>r.family)))log(family+'/compile.log','do compile.do',null,false);
 assert.equal(read('savestates_sim.sv'),adapted);
 const gate={passed:true,head:baseline.head,current:17,candidateSHA:sha(Buffer.from(candidate)),createdUTC:new Date().toISOString(),evidence,fixtures,notes:['Five VDP families changed only their v13 setup import to public96 and regenerated oracles with unchanged v17 controller; current SAVE/LOAD checks and three-replay scoring retained.','No production files modified. No Quartus permitted before this artifact.','Previously retained test-only TB_FAST/flush shortening and simulation portability adaptations retained; production build uses untouched full settings.']};
 const path=p.join(d,'functional_gate.json');
 if(fs.existsSync(path)){
  const existing=JSON.parse(fs.readFileSync(path));
  assert.equal(existing.candidateSHA,gate.candidateSHA);assert.deepEqual(existing.evidence,gate.evidence);assert.deepEqual(existing.fixtures,gate.fixtures);
 }else fs.writeFileSync(path,JSON.stringify(gate,null,2));
 console.log('PASS full functional gate '+evidence.length+' logged checks');
}catch(e){if(probe){console.log(e.message);process.exitCode=1;}else throw e;}
