const fs=require('fs'),p=require('path'),c=require('crypto'),assert=require('assert');
const d=__dirname,wt=p.join(d,'worktree'),old=p.resolve(d,'../ym2413_c1_mixer_omission/verification_c1/tests/ym2413_fullstate'),v=p.join(d,'verification');
const sha=b=>c.createHash('sha256').update(b).digest('hex'),inputs={};
fs.mkdirSync(v,{recursive:true});
function copy(f){const b=fs.readFileSync(p.join(old,f));const target=p.join(v,f);fs.mkdirSync(p.dirname(target),{recursive:true});fs.writeFileSync(target,b,{flag:'wx'});inputs[f]=sha(b);}
for(const dir of ['candidate','reference'])for(const f of fs.readdirSync(p.join(old,dir)).filter(f=>f.endsWith('.vhd')))copy(dir+'/'+f);
for(const f of fs.readdirSync(old).filter(f=>/\.(sv|svh|vhd|tcl|hex|do)$/.test(f)&&!['savestates_sim.sv','savestates_fast.sv'].includes(f)))copy(f);
for(const f of fs.readdirSync(p.resolve(old,'../../payloads')).filter(f=>f.endsWith('.hex'))){fs.mkdirSync(p.join(v,'payloads'),{recursive:true});fs.copyFileSync(p.resolve(old,'../../payloads',f),p.join(v,'payloads',f));}
const main=fs.readFileSync(p.join(wt,'rtl/savestates.sv'),'utf8');let adapted=main;
for(const n of ['mapper_snap','evolution_snap','dout_latch']){const re=new RegExp('^reg\\s+\\[[^\\]]+\\]\\s+'+n+';\\r?\\n','m'),m=adapted.match(re);assert(m,n);adapted=adapted.replace(re,'').replace('// Helpers',m[0]+'// Helpers');}
fs.writeFileSync(p.join(v,'savestates_sim.sv'),adapted,{flag:'wx'});fs.writeFileSync(p.join(v,'savestates_fast.sv'),adapted.replace("20'd900000","20'd90"),{flag:'wx'});
fs.copyFileSync(p.join(wt,'rtl/opll_snapshot.sv'),p.join(v,'opll_snapshot.sv'));
for(const f of fs.readdirSync(v).filter(f=>f.endsWith('.do'))){const target=p.join(v,f);fs.writeFileSync(target,fs.readFileSync(target,'utf8').replaceAll('../../rtl/opll_snapshot.sv','opll_snapshot.sv'));}
for(const f of ['validator_stream_tb.sv','early_validator_stream_tb.sv']){const target=p.join(v,f);fs.writeFileSync(target,fs.readFileSync(target,'utf8').replaceAll('../../payloads/','payloads/'));}
const rejected="memory['h2997]=64'h00681101464d5331;reject(17);memory['h2997]=64'h00641201464d5331;reject(18);memory['h2997]=64'h00641401464d5331;";
for(const f of ['protocol_tb.sv','guard_protocol_tb.sv']){
 const target=p.join(v,f);let s=fs.readFileSync(target,'utf8');assert(s.includes(rejected));
 s=s.replace(rejected,"memory['h2997]=64'h00681101464d5331;reject(17);memory['h2997]=64'h00641201464d5331;reject(18);memory['h2997]=64'h00641401464d5331;reject(20);memory['h2997]=64'h00641101464d5331;reject(117);memory['h2997]=64'h00640101464d5331;");
 // Positive expectations and diagnostic labels, never the newly added v20 rejection literal.
 s=s.replace("if(memory['h2997]!==64'h00641401464d5331)","if(memory['h2997]!==64'h00640101464d5331)").replaceAll('descriptor not v20','descriptor not public v1').replaceAll('descriptor v20','descriptor public v1').replace('v17 and v18 descriptors','unpublished v17/v18/v20 descriptors');
 fs.writeFileSync(target,s);
}
// Observe every live-state write interface on rejected full LOADs, not just CPU/FM.
const liveSignals='z80_set||vdp_regs_set||psg_set||mapper_set||evolution_set||eeprom_set||io_set||video_state_set||vdp2_regs_set||psg2_set||cram_wr||cram2_wr||vram_WE||vram2_WE||wram_WE||nvram_WE||audio_ext_set||audio_phase_set||fm_state_write||fm_legacy_reset';
for(const f of ['protocol_tb.sv','guard_protocol_tb.sv']){const target=p.join(v,f);let s=fs.readFileSync(target,'utf8');s=s.replace('reg ready=0;',`integer live_writes=0;\nalways @(posedge clk) if(${liveSignals})live_writes++;\nreg ready=0;`);s=s.replace('integer old_restores,old_applies;','integer old_restores,old_applies,old_live;').replace('old_restores=restores;old_applies=applies;operation(0);','old_restores=restores;old_applies=applies;old_live=live_writes;operation(0);\n if(live_writes!=old_live)$fatal(1,"rejected LOAD changed non-FM/live state case=%0d",kind);');s=s.replace('rejected before core/FM apply','rejected before ANY live-state write');fs.writeFileSync(target,s);}
// End-to-end DDRAM + live OPLL rejection of each unpublished descriptor.
{
 const target=p.join(v,'guard_live_tb.sv');let s=fs.readFileSync(target,'utf8');s=s.replace('// Counterexample A and B in word pair 39 (words 78 and 79) plus v17 descriptor rejection',`// Unpublished FM descriptors must not be accepted by public v1.\n memory[base+'h2997]=64'h00681101464d5331;rejected_live(17);\n memory[base+'h2997]=64'h00641201464d5331;rejected_live(18);\n memory[base+'h2997]=64'h00641401464d5331;rejected_live(20);\n memory[base+'h2997]=64'h00640101464d5331;\n // Counterexample A and B in word pair 39 (words 78 and 79)`);fs.writeFileSync(target,s);
 const run=p.join(v,'guard_live.do');fs.writeFileSync(run,fs.readFileSync(run,'utf8').replace('$checkpoint_total==11','$checkpoint_total==14'));
}
fs.writeFileSync(p.join(d,'verification_inputs.json'),JSON.stringify({source:old,templateSourceSHA256:inputs,adapters:['declaration ordering for ModelSim','fast-only FLUSH_MAX=90','local compile/payload paths','independent public-v1 expectations and experimental rejection tests','all live-state write-strobe monitor'],productionTested:p.join(wt,'rtl/savestates.sv'),productionSHA256:sha(Buffer.from(main))},null,2)+'\n',{flag:'wx'});
console.log('Prepared fresh focused verification outside integration worktree');
