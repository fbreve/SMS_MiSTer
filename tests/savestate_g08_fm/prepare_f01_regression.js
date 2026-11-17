const fs=require('fs'),p=require('path'),assert=require('assert'),d=__dirname,out=p.join(d,'f01'),src=p.join(d,'../savestate_f06_sega_sram_fix'),old=p.join(d,'../savestate_f01_opll_fix');
fs.mkdirSync(out,{recursive:true});for(const f of ['random_tb.sv','pause_fixture.sv','T80_sim.vhd','T80s_sim.vhd','opll_reference.vhd','rom.hex','random_run.do'])fs.copyFileSync(p.join(src,f),p.join(out,f));
fs.cpSync(p.join(src,'sim_opll'),p.join(out,'sim_opll'),{recursive:true});
fs.writeFileSync(p.join(out,'savestates_sim.sv'),require('../savestate_g06_g10_fix/controller_adapter')('rtl/savestates.sv'));
let s=fs.readFileSync(p.join(out,'random_tb.sv'),'utf8').replace('wire[15:0]al,ar,rl,rr_audio;','wire[15:0]rl,rr_audio;').replace('module random_tb;','module random_tb;wire[15:0]al,ar,last_sample_in;wire last_sample_valid;');
s=s.replace(/savestates\s+dut\s*\(/,'savestates dut(.audio_last_out(audio_phase_out?al:ar),.audio_last_in(last_sample_in),.audio_last_valid(last_sample_valid),').replace('AudioMix mix(.clk','AudioMix mix(.ss_last_sample(last_sample_in),.ss_last_valid(last_sample_valid),.clk');
s=s.replace('if((FM_SUPPRESS||systeme)&&errors)$fatal','if(errors)$fatal');assert(s.includes('if(errors)$fatal'));fs.writeFileSync(p.join(out,'random_tb.sv'),s);
let c=fs.readFileSync(p.join(src,'random_compile.do'),'utf8').replaceAll('../../rtl/','../../../rtl/').replaceAll('../savestate_f01_opll_architecture/','../../savestate_f01_opll_architecture/');fs.writeFileSync(p.join(out,'compile.do'),c);
for(let seed=1;seed<=16;seed++){const to=p.join(out,'random_'+seed);fs.mkdirSync(to,{recursive:true});for(const f of ['reference.dat','rom.hex'])fs.copyFileSync(p.join(old,'random_'+seed,f),p.join(to,f));}
console.log('Prepared16 F01 programs with original independent references and strict mixed output checks.');
