`timescale 1ns/1ps
module before_replay;parameter T=8;reg clk=0;always #5 clk=~clk;
reg reset=0,ce=1,freeze=0,holdref=0,th=1,en=1,set=0;reg[31:0]players=32'h88442211;wire[18:0]state,refstate;wire[7:0]pins,refpins;
tap_fixture #(.T(T)) dut(.clk_sys(clk),.reset_active(reset),.ce_cpu(ce),.ss_freeze(freeze),.ss_set(set),.ss_valid(1'b1),.hold(1'b0),.th(th),.enabled(en),.raw_serial(1'b0),.ss_in(19'd0),.players(players),.physical(7'h7f),.pause_combo(1'b0),.state(state),.joya(pins));
tap_fixture #(.T(T)) reference(.clk_sys(clk),.reset_active(reset),.ce_cpu(ce),.ss_freeze(1'b0),.ss_set(1'b0),.ss_valid(1'b0),.hold(holdref),.th(th),.enabled(en),.raw_serial(1'b0),.ss_in(19'd0),.players(players),.physical(7'h7f),.pause_combo(1'b0),.state(refstate),.joya(refpins));
task tick;begin @(negedge clk);#1;end endtask
integer phase,low,near,edgepending,i,cases=0,gaps=0;reg[18:0]saved;reg mismatch;reg[3:0]phase_gaps=0;
initial begin
for(phase=0;phase<4;phase=phase+1)for(low=0;low<2;low=low+1)for(near=0;near<4;near=near+1)for(edgepending=0;edgepending<2;edgepending=edgepending+1)begin
holdref=0;freeze=0;reset=1;th=1;tick;th=0;tick;th=1;repeat(T+3)tick;reset=0;
// First falling edge after discharge is ignored; subsequent edges select players.
th=0;tick;th=1;tick;repeat(phase)begin th=0;tick;th=1;tick;end
if(low)begin th=0;tick;end
if(near>0)begin th=1;while(state[15:0]<T-1)tick;repeat(near-1)tick;end
ce=0;repeat(2)tick;ce=1; // settle registered pin output without consuming protocol ticks
saved=state;holdref=1;freeze=1;if(edgepending)th=~th;
repeat(T+4)tick;freeze=0;
// No production savestate restore interface exists: simulated load cannot restore protocol.
set=1;tick;set=0;holdref=0;mismatch=0;
for(i=0;i<T+12;i=i+1)begin if(i<8)th=~th;tick;if(pins!==refpins)mismatch=1;end
if(mismatch)begin gaps=gaps+1;phase_gaps[phase]=1;if(cases<8||gaps<5)$display("CONFIRMED F09 T%0d phase%0d low%0d near%0d edge%0d saved%h live%h ref%h pins%h/%h",T,phase,low,near,edgepending,saved,state,refstate,pins,refpins);end
cases=cases+1;
end
if(!gaps||phase_gaps!=15)$fatal(1,"missing phase repro %h gaps%0d",phase_gaps,gaps);
$display("PASS PRE-FIX F09: T=%0d cases=%0d divergences=%0d all four requested phase setups",T,cases,gaps);$finish;
end
endmodule
