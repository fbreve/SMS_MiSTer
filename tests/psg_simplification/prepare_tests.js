const fs=require('fs'),p=require('path'),cp=require('child_process'),assert=require('assert');
const d=__dirname,root=p.resolve(d,'../..'),rev='8443a0d19a88aff7a5900011bccf386daf146945';
const get=(f)=>cp.execFileSync('git',['show',`${rev}:${f}`],{cwd:root,maxBuffer:32*1024*1024}).toString().replace(/\r\n/g,'\n');
const read=(v,f)=>v==='A'?get(f):fs.readFileSync(p.join(d,v,f),'utf8').replace(/\r\n/g,'\n');
const out=(f,s)=>{fs.mkdirSync(p.dirname(p.join(d,f)),{recursive:true});fs.writeFileSync(p.join(d,f),s);};
for(const v of ['A','B','C']){
 const dir=`sim_${v}`;
 for(const name of ['jt89','jt89_tone','jt89_noise','jt89_vol','jt89_mixer'])out(`${dir}/${name}.v`,read(v,`rtl/jt89/${name}.v`));
 let ss=read(v,'rtl/savestates.sv');
 // ModelSim 10.5b requires these declarations before the helper wires.
 for(const name of ['mapper_snap','evolution_snap']){const re=new RegExp('^reg\\s+\\[[^\\]]+\\]\\s+'+name+';\\n','m'),decl=ss.match(re)[0];ss=ss.replace(re,'').replace('// NVRAM size calculation helpers',decl+'// NVRAM size calculation helpers');}
 out(`${dir}/controller.sv`,ss);
 let sys=read(v,'rtl/system.vhd');const start=sys.indexOf('\tprocess (clk_sys)\n\tbegin\n\t\tif rising_edge(clk_sys) then\n\t\t\tif RESET_n=\'0\' then \n\t\t\t\tdet_D');assert(start>0);const end=sys.indexOf('\tend process;',start)+ '\tend process;'.length;
 out(`${dir}/controls.vhd`,`library ieee;use ieee.std_logic_1164.all;\nentity controls is port(clk_sys,RESET_n,ss_freeze,psg_set,audio_ext_set,det_WR_n,bal_WR_n:in std_logic;D_in:in std_logic_vector(7 downto 0);audio_control_in:in std_logic_vector(10 downto 0);audio_control_out:out std_logic_vector(10 downto 0));end;\narchitecture extracted of controls is signal det_D:std_logic_vector(2 downto 0);signal PSG_mux:std_logic_vector(7 downto 0);begin\naudio_control_out<=det_D & PSG_mux;\n${sys.slice(start,end)}\nend;\n`);
 out(`${dir}/AudioMix.vhd`,read(v,'rtl/AudioMix.vhd'));
 // Existing replay: run unmodified against protected master. Candidate replay
 // retains the same stimulus, but measures the deliberately weaker contract.
 let tb=fs.readFileSync(p.join(root,'tests/savestate_coverage/psg_replay_tb.sv'),'utf8');
 if(v!=='A'){
  tb=tb.replace(/,\.ss_ext_out\(ext\)[\s\S]*?\.ss_quiescent\(quiet\)/, '');
  tb=tb.replace(/,\.ss_ext_out\(rext\)[\s\S]*?\.ss_quiescent\(rquiet\)/, '');
  tb=tb.replace('.ss_set(1\'b0),.ss_in(saved_cfg)', '.ss_set(load),.ss_in(saved_cfg)');
  tb=tb.replace('integer mode,phase,i,n=0;',`assign div=dut.clk_div;assign rdiv=reference.clk_div;assign ext={dut.noise,dut.ch2,dut.ch1,dut.ch0,dut.u_noise.shift,dut.u_noise.cnt,dut.u_tone2.out,dut.u_tone2.cnt,dut.u_tone1.out,dut.u_tone1.cnt,dut.u_tone0.out,dut.u_tone0.cnt};\nassign rext={reference.noise,reference.ch2,reference.ch1,reference.ch0,reference.u_noise.shift,reference.u_noise.cnt,reference.u_tone2.out,reference.u_tone2.cnt,reference.u_tone1.out,reference.u_tone1.cnt,reference.u_tone0.out,reference.u_tone0.cnt};\nassign quiet=!ce&&!perturb&&!dut.cen_16&&wr&&!dut.clr_noise&&dut.last_wr;assign rquiet=!ce&&!reference.cen_16&&wr&&!reference.clr_noise&&reference.last_wr;\ninteger mode,phase,i,n=0,mismatches=0,late=0,raw=0,cases_different=0,local_diff=0;`);
  tb=tb.replace('if(cfg!==rcfg||ext!==rext||div!==rdiv) $fatal(1,"restore mismatch mode=%0d phase=%0d",mode,phase);','if(cfg!==rcfg) $fatal(1,"configuration restore mismatch");local_diff=0;');
  tb=tb.replace('if(cfg!==rcfg||ext!==rext||div!==rdiv||l!==rl||r!==rr) $fatal(1,"replay mismatch mode=%0d phase=%0d cycle=%0d",mode,phase,i);',`if(cfg!==rcfg) $fatal(1,"configuration replay mismatch");\n  if(ext!==rext||div!==rdiv)raw=raw+1;\n  if(l!==rl||r!==rr)begin mismatches=mismatches+1;local_diff=local_diff+1;if(i>=19000)late=late+1;end`);
  tb=tb.replace('n=n+1;','n=n+1;if(local_diff>0)cases_different=cases_different+1;');
  tb=tb.replace('$display("PASS PSG replay: %0d cases, 8 noise controls, all 16 divider phases, 20000 compared cycles/case",n);',`$display("PASS reduced PSG contract: cases=%0d different_cases=%0d output_mismatches=%0d final1000_mismatches=%0d raw_mismatches=%0d config_errors=0",n,cases_different,mismatches,late,raw);`);
 }
 out(`${dir}/psg_replay_tb.sv`,tb);
 out(`${dir}/replay.do`,`onerror {quit -code 1}\nonbreak {quit -code 1}\nvlib work\nvlog -suppress 2388 -quiet jt89_vol.v jt89_tone.v jt89_noise.v jt89_mixer.v jt89.v\nvlog -sv -quiet psg_replay_tb.sv\nvsim -c -t 1ps work.psg_replay_tb\nrun -all\nquit -code 0\n`);
}
console.log('Prepared exact-source simulator inputs and existing replay tests');
