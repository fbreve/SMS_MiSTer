const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto'),assert=require('assert'),d=__dirname;
const sha=p=>crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
const baseline=require('./baseline.json'),logs={};
assert(require('./source_checks.json').passed,'source checks required');
assert(require('./full_flush_proof.json').passed,'production-duration flush required');
function pass(file,marker){const path=p.join(d,file),s=fs.readFileSync(path,'utf8');assert(s.includes(marker),file+' missing '+marker);assert(s.includes('Errors: 0'),file+' missing clean termination');assert(!/\*\* (Fatal|Error|Failure):|Errors: [1-9]/.test(s),file+' errors');logs[file]=sha(path);return s;}
pass('reg_g10_full/dut_full_flush/simulation.log','PASS V15 VDP');
assert.equal(sha(p.join(d,'reg_g10_full/dut_full_flush/simulation.log')).toUpperCase(),require('./full_flush_proof.json').logSHA);
assert(fs.readFileSync(p.join(d,'reg_g10_full/savestates_sim.sv'),'utf8').includes("(TB_FAST?20'd0:20'd900000)"));
const changed=Object.entries(baseline.hashes).filter(([f,h])=>sha(f)!==h).map(([f])=>f);assert.deepEqual(changed,['rtl/savestates.sv']);
assert.equal(cp.execFileSync('git',['rev-parse','HEAD'],{encoding:'utf8'}).trim(),baseline.head);
assert.equal(cp.execFileSync('git',['diff','--cached','--stat'],{encoding:'utf8'}).trim(),'');
const current=[];for(const stall of [0,1,2]){
 const s=pass('current/final'+stall+'.log','PASS F06 COMPLETE old0 stall'+stall);
 assert.equal([...s.matchAll(/PASS F06 case\d+ old0/g)].length,9);
 assert.equal([...s.matchAll(/words4096 /g)].length,9);
 current.push({stall,cases:[...s.matchAll(/case(\d+) old0 stall\d+ words4096 SAVEclocks(\d+) LOADclocks(\d+)/g)].map(m=>({case:+m[1],save:+m[2],load:+m[3]}))});
 const sh=pass('shared/final'+stall+'.log','PASS SHARED COMPLETE stall'+stall);assert.equal([...sh.matchAll(/PASS SHARED profile/g)].length,10);
}
const old=pass('old/simulation0.log','PASS F06 COMPLETE old1 stall0');
pass('legacy/simulation.log','PASS LEGACY COMPLETE');pass('persistence/simulation.log','PASS PERSISTENCE COMPLETE');
for(const stall of [0,2]){const s=pass('eeprom/simulation'+stall+'.log','PASS EEPROM DDRAM:');assert.equal([...s.matchAll(/PASS EEPROM DDRAM case/g)].length,8);}
pass('eeprom/replay.log','PASS EEPROM replay: 6642 cases');pass('psg/simulation.log','PASS PSG');
pass('format/format.log','rejected2016 accepted400');pass('imports/simulation.log','PASS IMPORT ALL loads20');
pass('history/simulation.log','PASS HISTORY COMPLETE NMI8 mapper4 EvolutionPending8 loads24');
const bridge=pass('miter/simulation.log','PASS MITER ALL outputs101 profiles16');
assert(bridge.includes('clocks13600225'));
for(const seed of [1,10])pass('random_'+seed+'/replay.log','PASS F01');
const rows=require('./regression_manifest.json');for(const r of rows){const s=pass(r.family+'/'+r.name+'/simulation.log',r.marker);if(r.also)assert(s.includes(r.also));for(const f of (r.fixtures||[]).filter(x=>!['image.hex','image_save.hex'].includes(x.file))){assert.equal(sha(p.join(d,r.family,r.name,f.file)),f.sha256,'original oracle '+r.family+'/'+r.name+'/'+f.file);}}
// The last production revision only tightens exclusion of EEPROM mode. The
// old-v18 reference and final-v18 controller are checked for all101outputs on
// the non-EEPROM contexts used by the inherited 28 cases, format/imports and
// F01 oracles. Actual EEPROM valid/invalid cases use final source directly.
let a=fs.readFileSync(p.join(d,'format/savestates_sim.sv'),'utf8');
let b=require('../savestate_g06_g10_fix/controller_adapter')('rtl/savestates.sv');
assert.equal(a.replace('sc_size_snap == 0 && !transfer_eeprom','sc_size_snap == 0 && !eeprom_present'),b,'single-predicate source bridge');
const source=fs.readFileSync('rtl/savestates.sv','utf8');assert(source.includes("SRAM_MAGIC = 24'h484312"));
const oldCases=[...old.matchAll(/case(\d+) old1 stall0 words(\d+) SAVEclocks(\d+) LOADclocks(\d+)/g)].map(m=>({case:+m[1],words:+m[2],save:+m[3],load:+m[4]}));
const latency=current[0].cases.map(r=>({...r,old:oldCases.find(x=>x.case===r.case),addedSave:r.save-oldCases.find(x=>x.case===r.case).save,addedLoad:r.load-oldCases.find(x=>x.case===r.case).load}));
const images={};for(const variant of ['current','old'])for(const which of ['a','b'])images[variant+'_'+which]=sha(p.join(d,variant,'pair_'+which+'.bin'));
assert.equal(images.old_a,images.old_b);assert.notEqual(images.current_a,images.current_b);
const ia=fs.readFileSync(p.join(d,'current/pair_a.bin')),ib=fs.readFileSync(p.join(d,'current/pair_b.bin'));let different=[];for(let i=0;i<ia.length;i++)if(ia[i]!==ib[i])different.push(i);assert.deepEqual(different,[0xd01*8]);
const result={passed:true,head:baseline.head,sourceSHA:sha('rtl/savestates.sv'),currentControllerSHA:sha(p.join(d,'current/savestates_sim.sv')),timeUTC:new Date().toISOString(),changed,logs,current,oldCases,latency,images,differentImageBytes:different,componentCases:rows.length,rawPSGCases:128,rawEEPROMCases:6642,sharedProfiles:30,formatCases:2416,historyLoads:24,sourceBridge:'Old-v18 to final-v18 EEPROM-mode exclusion: all101outputs equal for16 non-EEPROM profiles/13600225clocks; final actual EEPROM suite separately covers the changed contexts',contract:'Same loaded ROM; strict ownership and fingerprints excluded'};
fs.writeFileSync(p.join(d,'functional_gate.json'),JSON.stringify(result,null,2));console.log('PASS F06 SIMULATION GATE: '+Object.keys(logs).length+' logs, source frozen '+result.sourceSHA);

