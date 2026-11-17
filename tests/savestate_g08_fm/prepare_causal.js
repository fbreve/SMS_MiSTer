const fs=require('fs'),p=require('path'),d=__dirname;
let s=fs.readFileSync(p.join(d,'fm_tb.sv'),'utf8').replace('CHARACTERIZE=1','CHARACTERIZE=0');
s=s.replace('wire[6:0]fm_counter,rfm_counter;','reg[15:0]cache_l,cache_r;reg cache_ready=0;wire[6:0]fm_counter,rfm_counter;');
s=s.replace('#1;$display("POST_T', '#1;if(dut.do_save)begin cache_l=al;cache_r=ar;cache_ready=1;end $display("POST_T');
fs.writeFileSync(p.join(d,'causal_tb.sv'),s);
fs.writeFileSync(p.join(d,'causal_compile.do'),fs.readFileSync(p.join(d,'compile.do'),'utf8').replaceAll('fm_work','fm_causal_work').replace('fm_tb.sv','causal_tb.sv'));
fs.writeFileSync(p.join(d,'causal_run.do'),`onerror {quit -code 1}
onbreak {quit -code 1}
vsim -L fm_causal_work -L original_work -t 1ps -voptargs=+acc fm_causal_work.fm_tb -gPHASE=70 -gREF=0 -gFM_ONLY=1 -g/fm_tb/dut/TB_FAST=1
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
when {/fm_tb/ss_freeze == 0 && /fm_tb/cache_ready == 1} {
 set lv [examine -radix binary /fm_tb/cache_l]
 set rv [examine -radix binary /fm_tb/cache_r]
 force -deposit /fm_tb/mix/audio_l 2#$lv
 force -deposit /fm_tb/mix/audio_r 2#$rv
 echo "CAUSAL_CACHE_DEPOSIT left=$lv right=$rv"
}
run -all
quit -code 0
`);
fs.mkdirSync(p.join(d,'causal'),{recursive:true});for(const f of ['reference.dat','rom.hex'])fs.copyFileSync(p.join(d,'p70_s0_fm1_stall0',f),p.join(d,'causal',f));
