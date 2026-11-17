const fs=require('fs'),p=require('path'),d=__dirname,td=p.join(d,'verification/tests/ym2413_fullstate');let s=fs.readFileSync(p.join(td,'tb.sv'),'utf8');
s=s.replace('initial begin\n for(integer i=0;i<98304;i++)memory[i]=0;',`task rejected_live(input integer which);integer before_apply,before_restore;begin
 force dut.op_cooldown=0;before_apply=applied;before_restore=restores;
 ss_load=1;tick;ss_load=0;wait(ss_freeze);wait(dut.state==dut.ST_ERROR);wait(!ss_freeze);ticks(20);
 if(applied!=before_apply||restores!=before_restore)$fatal(1,"rejected image changed live core/FM state");
 stop_for_oracle(4);
 $display("PASS LIVE_REJECTION case=%0d no_FM_or_core_apply audio_and_all104_checked",which);
 release dut.op_cooldown;
end endtask
initial begin
 for(integer i=0;i<98304;i++)memory[i]=0;`);
s=s.replace(' // Legacy untagged 96 KiB image ignores even a stale valid FM descriptor.',` memory[base+'h2998+39][31:0]=3;memory[base+'h2998+50][31:0]=32'h7FE00402;memory[base+'h2998+37][31:0]=0;
 rejected_live(0);
 memory[base+'h2998+39][31:0]=2;memory[base+'h2998+50]=64'h000000027FE00042;memory[base+'h2998+29][63:32]=0;
 rejected_live(1);
 // Legacy untagged 96 KiB image ignores even a stale valid FM descriptor.`);
fs.writeFileSync(p.join(td,'guard_live_tb.sv'),s);
let t=fs.readFileSync(p.join(td,'run.do'),'utf8');const start=t.indexOf('if {[info exists env(FAST)]'),end=t.indexOf('set NumericStdNoWarnings',start);t=t.slice(0,start)+'vsim -t 1ps -L candidate_work -L reference_work guard_live_work.tb -gSHIFT=0 -gMODE=0 -gNCONT=5000\n'+t.slice(end);
t=t.replace('if {$checkpoint_total==9}',`if {$point==4} {equal_words [state_words /tb/fm] [state_words /tb/reference_fm] "rejected LOAD left all104 live FM fields identical"}
 if {$checkpoint_total==11}`);
fs.writeFileSync(p.join(td,'guard_live.do'),'onerror {quit -code 1}\nvlib guard_live_work\nvlog -sv -work guard_live_work ../../rtl/opll_snapshot.sv savestates_fast.sv guard_live_tb.sv\n'+t);
