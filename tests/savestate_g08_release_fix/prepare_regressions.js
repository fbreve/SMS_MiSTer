const fs=require('fs'),p=require('path');const d=__dirname,root=p.resolve(d,'../..'),prior=p.join(root,'tests/savestate_g05_background_fix'),read=f=>fs.readFileSync(f,'utf8').replace(/\r\n/g,'\n'),adapter=require('../savestate_g06_g10_fix/controller_adapter');
const fmt=p.join(d,'format');fs.mkdirSync(fmt,{recursive:true});
let s=read(p.join(prior,'format/format_tb.sv')).replaceAll("24'h48430f","24'h484310").replace("reg audio_phase_out = '0;","reg audio_phase_out = 1'b1;");
s=s.replace('accepted++;\n for(integer b=0;b<64;b++)reject_bit',`accepted++;
 if(audio_phase_in!==1)$fatal(1,"v16 historical phase1 lost");
 begin reg[63:0]old_audio;old_audio=mem['he];mem['he][63]=0;
 transfer(0);if(guest_writes)$fatal(1,"v16 missing audio accepted");rejections++;mem['he]=old_audio;end
 for(integer b=0;b<64;b++)reject_bit`);
s=s.replace('accepted++;$display("LEGACY_ACCEPT', 'if(audio_phase_in!==0)$fatal(1,"legacy phase not normalized");accepted++;$display("LEGACY_ACCEPT');
s=s.replace('expect_background=1;mem[\'h1a]=oldtag;',`expect_background=1;mem['h1a][63:40]=24'h48430f;
 transfer(0);if(!guest_writes||!sprite_valid||!bg_valid||audio_phase_in!==0)$fatal(1,"v15 compatibility/phase normalization");accepted++;
 expect_background=1;mem['h1a]=oldtag;`);
s=s.replace('PASS V15 FORMAT','PASS V16 FORMAT');fs.writeFileSync(p.join(fmt,'format_tb.sv'),s);fs.writeFileSync(p.join(fmt,'savestates_sim.sv'),adapter(p.join(root,'rtl/savestates.sv')));fs.copyFileSync(p.join(prior,'format/run.do'),p.join(fmt,'run.do'));
const raw=p.join(d,'raw_psg');fs.mkdirSync(raw,{recursive:true});s=read(p.join(root,'tests/savestate_coverage/psg_replay_tb.sv')).replaceAll('jt89 dut(',"jt89 dut(.ss_pending_tick(1'b0),").replaceAll('jt89 reference(',"jt89 reference(.ss_pending_tick(1'b0),");fs.writeFileSync(p.join(raw,'psg_replay_tb.sv'),s);
fs.writeFileSync(p.join(raw,'run.do'),`onerror {quit -code 1}
onbreak {quit -code 1}
vlib raw_work
vlog -work raw_work -suppress 2388 -quiet ../../../rtl/jt89/jt89_vol.v ../../../rtl/jt89/jt89_tone.v ../../../rtl/jt89/jt89_noise.v ../../../rtl/jt89/jt89_mixer.v ../../../rtl/jt89/jt89.v psg_replay_tb.sv
vsim -c raw_work.psg_replay_tb
run -all
quit -code 0
`);
for(const [kind,ids]of [['original',['h0']],['g06',['sanity_collision','sanity_overflow']]]){
const src=p.join(prior,'integrated_'+kind),dst=p.join(d,'vdp_'+kind);fs.mkdirSync(dst,{recursive:true});
for(const f of ['T80_sim.vhd','T80s_sim.vhd','header.svh','vdp_tb.sv','compile.do'])fs.copyFileSync(p.join(src,f),p.join(dst,f));
fs.cpSync(p.join(src,'rtl'),p.join(dst,'rtl'),{recursive:true});fs.writeFileSync(p.join(dst,'savestates_sim.sv'),adapter(p.join(root,'rtl/savestates.sv')));
for(const id of ids)for(const prefix of ['reference_','dut_']){const leaf=p.join(dst,prefix+id);fs.mkdirSync(leaf,{recursive:true});for(const f of ['run.do','rom.hex'])fs.copyFileSync(p.join(src,prefix+id,f),p.join(leaf,f));const run=p.join(leaf,'run.do');fs.writeFileSync(run,read(run).replace('-gSLOTS=64','-gSLOTS=8'));}
fs.writeFileSync(p.join(dst,'cases.json'),JSON.stringify(ids));
}
console.log('Prepared v16 format/legacy, existing128-case raw PSG and ordinary8-slot G05/G06 sanity; physical64-slot packing is unchanged and outside this targeted rerun');
