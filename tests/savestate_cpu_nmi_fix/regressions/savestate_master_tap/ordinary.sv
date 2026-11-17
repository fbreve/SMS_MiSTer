`timescale 1ns/1ps
module ordinary;
reg clk=0;always #5 clk=~clk;reg reset=0,ce=0,freeze=0,set=0,valid=1,th=1,en=1,raw=0,pausecombo=0;reg[18:0]saved;reg[31:0]players=32'h88442211,randomness=32'h31415926;reg[6:0]physical=127;
wire[18:0]state,oldstate;wire[7:0]a,b,serial,oa,ob,os;wire[6:0]u,ou;
tap_fixture dut(.clk_sys(clk),.reset_active(reset),.ce_cpu(ce),.ss_freeze(freeze),.ss_set(set),.ss_valid(valid),.hold(1'b0),.th(th),.enabled(en),.raw_serial(raw),.ss_in(saved),.players(players),.physical(physical),.pause_combo(pausecombo),.state(state),.joya(a),.joyb(b),.joyser(serial),.USER_OUT(u));
tap_baseline original(.clk_sys(clk),.reset_active(reset),.ce_cpu(ce),.ss_freeze(1'b0),.ss_set(1'b0),.ss_valid(1'b0),.hold(1'b0),.th(th),.enabled(en),.raw_serial(raw),.ss_in(19'd0),.players(players),.physical(physical),.pause_combo(pausecombo),.state(oldstate),.joya(oa),.joyb(ob),.joyser(os),.USER_OUT(ou));
task tick;begin @(negedge clk);#1;end endtask
initial begin
for(integer i=0;i<100000;i=i+1)begin
randomness={randomness[30:0],randomness[31]^randomness[21]^randomness[1]^randomness[0]};ce=i%15==0;th=randomness[0];raw=randomness[7];en=randomness[12];players=randomness;physical=randomness[22:16];pausecombo=randomness[9];reset=i%4096==0;
tick;if(state!==oldstate||a!==oa||b!==ob||serial!==os||u!==ou)$fatal(1,"normal timing differs at%0d state%h/%h pins%h/%h",i,state,oldstate,a,oa);
end
$display("PASS ordinary Master Tap/disabled/raw-serial shared-timer baseline equivalence: 100000 host clocks");
// The shared timer is local state even when the raw-serial pause countdown owns it.
raw=1;pausecombo=1;physical=0;tick;pausecombo=0;tick;saved=state;freeze=1;
repeat(60000)begin tick;if(state!==saved)$fatal(1,"shared timer advances during transport");end
freeze=0;repeat(80)tick;freeze=1;set=1;tick;set=0;if(state!==saved)$fatal(1,"shared timer restore mismatch");
$display("PASS shared local timer freeze/restore; physical pins remain current external inputs");$finish;
end
endmodule
