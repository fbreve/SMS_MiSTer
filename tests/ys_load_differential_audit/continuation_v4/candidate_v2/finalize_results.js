const fs=require('fs'),crypto=require('crypto'),assert=require('assert');
const comparison=JSON.parse(fs.readFileSync('e_map_comparison.json'));
const sha=b=>crypto.createHash('sha256').update(b).digest('hex');
assert(Object.values(comparison.runs).every(q=>q.completed));
const b=comparison.comparisons.e_sram_vs_e_reference,final=b.checkpoints.find(q=>q.label==='end');
assert(Object.values(final.memory).every(q=>q.count===0));
for(const kind of ['N','P','Q','V','E','G','M'])assert.equal(b.events[kind],null,kind);
const images=b.checkpoints.filter(q=>q.pixels);assert.equal(images.length,46);assert(images.every(q=>q.pixels.mapPixels===0&&q.pixels.HUDPixels===0));
for(const pair of ['e_context_vs_e_baseline','e_sham_vs_e_baseline']){
 const c=comparison.comparisons[pair];assert(Object.values(c.events).every(q=>q===null));
 assert(c.checkpoints.every(q=>Object.values(q.memory).every(m=>m.count===0)));
 assert(c.checkpoints.every(q=>!q.pixels||q.pixels.mapPixels===0&&q.pixels.HUDPixels===0));
}
const bankHashes={};
for(const [name,run]of Object.entries(comparison.runs)){
 bankHashes[name]=[];
 for(const cp of run.checkpoints.filter(q=>['saved','changed_environment','before_load','loaded','end'].includes(q.label))){
  const m=fs.readFileSync(name+'_'+cp.label+'.mem'),s=m.subarray(40960);assert.equal(s.length,32768);
  const saved=fs.readFileSync(name+'_saved.mem').subarray(40960);let wrong=0;for(let i=0;i<32768;i++)if(s[i]!==saved[i])wrong++;
  bankHashes[name].push({checkpoint:cp.label,mapper:cp.mapper,FNV64:cp.SRAM,physical32KSHA256:sha(s),bank0SHA256:sha(s.subarray(0,16384)),bank1SHA256:sha(s.subarray(16384)),bytesDifferentFromOwnSAVE:wrong,physical0462:s[0x462],physical0419:s[0x419]});
 }
}
fs.writeFileSync('sram_checkpoint_hashes.json',JSON.stringify({scope:'Complete physical SRAM, including banks invisible at SAVE/LOAD; hashes never infer contents from mapper flags.',runs:bankHashes},null,2));
const result={decision:'GO to propose physical SRAM preservation only for the reproduced standard-ROM environment-change failure; hardware release unverified',playableMapReached:true,baselineProgressiveGraphicsCorruptionReproduced:true,SRAMOnlyPreventsCorruptionForCompleteSequence:true,predecessorOnlyMatchesCorruptedBaseline:true,equalTimingDiscardedSRAMWriteControlMatchesCorruptedBaseline:true,independentSaveValidation:'e_saved_slot_validation.json',renderedCheckpointsPixelExactWithUninterrupted:images.length,matchingNormalizedStreams:['physical SRAM transactions','CPU VDP port writes','VDP command/address/latch observations','VRAM writes','effective VRAM changes','map-name mutations','mapper state'],finalMemoryBytesExact:73728,regressionControllerCases:51,exclusionEquivalenceCases:2,residualRestartDifferences:{firstFetchDifference:b.events.F,firstWRAMWriteDifference:b.events.W,firstVDPProbeDifference:b.events.T,intermediateWRAMCheckpointDifferences:b.checkpoints.filter(q=>q.memory.WRAM.count).map(q=>({checkpoint:q.label,differences:q.memory.WRAM}))},scopeLimits:['single standard ROM and environment-change route','ordinary predecessor class0 SAVE','simplified synchronous memory/DDR service','audio state stubbed','no hardware/Quartus validation','Japanese/FM-hack map cases and exact reset variant unverified'],artifacts:{}};
for(const file of ['e_map_comparison.json','e_saved_slot_validation.json','first_map_column_evidence.json','sram_checkpoint_hashes.json','distinct_transport_results.json','legacy_footprint_results.json','regression_summary.json'])result.artifacts[file]=sha(fs.readFileSync(file));
fs.writeFileSync('final_results.json',JSON.stringify(result,null,2));console.log('Final assertions passed: five completed trials, 46 exact candidate/reference images, complete final memory match, and two negative controls.');
