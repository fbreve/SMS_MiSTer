const fs=require('fs'),p=require('path'),cp=require('child_process'),d=__dirname,w=p.join(d,'worktree'),base='9873761503510e4b2c7e06600bf5515344235c2f',vr=p.join(d,'verification'),td=p.join(vr,'tests/ym2413_fullstate');
const git=(...a)=>cp.execFileSync('git',['--no-optional-locks',...a],{cwd:w,encoding:'latin1'}),put=(f,b)=>{fs.mkdirSync(p.dirname(f),{recursive:true});fs.writeFileSync(f,b,'latin1');};
for(const f of git('ls-tree','-r','--name-only',base,'tests/ym2413_fullstate').trim().split(/\r?\n/))put(p.join(vr,f),git('show',base+':'+f));
for(const f of git('ls-tree','-r','--name-only',base,'rtl/VM2413').trim().split(/\r?\n/).concat(['rtl/system.vhd','rtl/savestates.sv','rtl/opll_snapshot.sv']))put(p.join(vr,f),fs.readFileSync(p.join(w,f),'latin1'));
const prep=p.join(td,'prepare_tests.js');let s=fs.readFileSync(prep,'latin1');s=s.replace("ref='7fcd5e12847eedf9e97a44dc937c3dbac3205f7c'",`ref='${base}'`).replace("'HEAD:rtl/savestates.sv'","'66f16d5c656fd8906d62570da4d258875bcee684:rtl/savestates.sv'");s=s.replace("cwd:root,encoding:'latin1'",`cwd:${JSON.stringify(w)},encoding:'latin1'`);fs.writeFileSync(prep,s,'latin1');
for(const name of ['prepare_tests.js','prepare_nonfm.js','prepare_patterns.js','prepare_phases.js'])cp.execFileSync('node',[name],{cwd:td,stdio:'inherit'});
fs.mkdirSync(p.join(td,'logs'),{recursive:true});
// Extend the existing native transport regression with guard-specific rejection
// and immediate recovery. Keep the original readiness/legacy cases intact.
s=fs.readFileSync(p.join(td,'protocol_tb.sv'),'latin1').replaceAll('protocol_tb','guard_protocol_tb');
s=s.replace('$display("PASS protocol startup guard, descriptor v17, full apply104");',`$display("PASS protocol startup guard, descriptor v17, full apply104");
 memory['h2998+39][31:0]=3;memory['h2998+50][31:0]=32'h7FE00402;reject(10);
 memory['h2998+39][31:0]=2;memory['h2998+50][31:0]=32'h7FE00042;memory['h2998+50][63:32]=32'h00000002;reject(11);
 // A legitimate pending write at stage zero must remain accepted after failures.
 memory['h2998+39][31:0]=0;memory['h2998+50][31:0]=32'h7FE00402;operation(0);
 if(applies!=208||restores!=2)$fatal(1,"stage-zero pending write recovery");
 // Repeat rejection after the stage-zero latch was true, then accept stage3/no-write.
 memory['h2998+39][31:0]=3;reject(12);
 memory['h2998+39][31:0]=71;memory['h2998+50]=0;operation(0);
 if(applies!=312||restores!=3)$fatal(1,"back-to-back valid recovery");
 $display("PASS guard atomic FM rejection A/B, stale-latch isolation and back-to-back recovery");`);
s=s.replace('restores!=2)$fatal(1,"legacy96 fallback")','restores!=4)$fatal(1,"legacy96 fallback")').replace('restores!=3)$fatal(1,"legacy64 fallback")','restores!=5)$fatal(1,"legacy64 fallback")');
fs.writeFileSync(p.join(td,'guard_protocol_tb.sv'),s,'latin1');
fs.writeFileSync(p.join(td,'guard_protocol.do'),'onerror {quit -code 1}\nonbreak {quit -code 1}\nvlog -sv -work test_work guard_protocol_tb.sv\nvsim -t 1ps test_work.guard_protocol_tb\nrun -all\nquit -code 0\n');
// Exercise the actual production LOAD validator/transport on all retained images,
// rather than replacing it with a stand-alone copy of the proposed predicate.
fs.writeFileSync(p.join(td,'validator_stream_tb.sv'),`\`timescale 1ns/1ps
module validator_stream_tb;
\`include "ports.svh"
assign fm_initialized=1;assign fm_state_rdata=0;
always #5 clk=~clk;
reg[31:0]words[0:103];integer cycles=0,pending=0,fd,n,k,good=0,bad=0,applied=0;reg[28:0]ra;
always @(negedge clk)begin cycles++;DDRAM_BUSY=cycles%31<5;end
always @(posedge clk)begin
 DDRAM_DOUT_READY<=0;
 if(pending>0)begin pending<=pending-1;if(pending==1)begin DDRAM_DOUT<={words[2*(ra-29'h07c02998)+1],words[2*(ra-29'h07c02998)]};DDRAM_DOUT_READY<=1;end end
 if(DDRAM_RD&&!DDRAM_BUSY&&DDRAM_ADDR>=29'h07c02998&&DDRAM_ADDR<29'h07c029cc)begin if(pending)$fatal(1,"overlapping read");pending<=2+cycles%5;ra<=DDRAM_ADDR;end
 if(fm_state_write||fm_legacy_reset||dut.fm_apply)$fatal(1,"validation mutated live FM state");
end
task tick;begin @(negedge clk);#2;end endtask
task check_image(input bit want_accept);integer timeout;begin
 reset_n=0;repeat(3)tick;reset_n=1;repeat(3)tick;
 dut.ss_freeze=1;dut.state=dut.ST_FM_LOAD_DESC;dut.dout_latch=dut.FM_DESC;dut.dout_expected=0;dut.base_addr=29'h07c00000;
 timeout=0;
 while(dut.state!=dut.ST_ERROR&&dut.state!=dut.ST_LOAD_EEPROM)begin tick;timeout++;if(timeout>4000)$fatal(1,"validator timeout state=%0d",dut.state);end
 if(want_accept)begin if(dut.state!=dut.ST_LOAD_EEPROM)$fatal(1,"legitimate/guarded image rejected count=%0d stage=%0d mo_wr=%b",good,words[78],words[100][1]);good++;end
 else begin if(dut.state!=dut.ST_ERROR)$fatal(1,"counterexample accepted");bad++;end
end endtask
task stream(input string name,input bit accepted);begin
 fd=$fopen(name,"r");if(!fd)$fatal(1,"missing payload %s",name);n=0;
 while(!$feof(fd))begin k=$fscanf(fd,"%h",words[0]);if(k==1)begin for(integer j=1;j<104;j++)if($fscanf(fd,"%h",words[j])!=1)$fatal(1,"partial image");check_image(accepted);n++;end end
 $fclose(fd);$display("PASS production FSM validation file=%s images=%0d accepted=%b",name,n,accepted);
end endtask
initial begin
 stream("../../payloads/A.hex",0);stream("../../payloads/B.hex",0);
 stream("../../payloads/coherent.hex",1);stream("../../payloads/guarded.hex",1);
 $display("PASS ACTUAL_VALIDATOR accepted=%0d rejected=%0d no_live_FM_writes",good,bad);$finish;
end
initial begin #1000000000;$fatal(1,"validator campaign timeout");end
endmodule
`);
fs.writeFileSync(p.join(td,'validator_stream.do'),'onerror {quit -code 1}\nonbreak {quit -code 1}\nvlib guard_validator_work\nvlog -sv -work guard_validator_work ../../rtl/opll_snapshot.sv savestates_sim.sv validator_stream_tb.sv\nvsim -t 1ps guard_validator_work.validator_stream_tb\nrun -all\nquit -code 0\n');
const payloads=p.join(d,'verification/payloads');fs.mkdirSync(payloads,{recursive:true});const old=p.resolve(d,'../ym2413_collision_reachability');for(const [from,to]of [['payload_0_0.hex','A.hex'],['payload_1_0.hex','B.hex'],['allpayload_10_0.hex','coherent.hex'],['allpayload_15_0.hex','guarded.hex']])fs.copyFileSync(p.join(old,from),p.join(payloads,to));
console.log('PASS isolated native regressions, guard/recovery and actual-validator stream prepared');
