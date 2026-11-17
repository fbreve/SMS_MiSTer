`timescale 1ns/1ps
module replay;parameter T=8;reg clk=0;always #5 clk=~clk;
reg reset=0,ce=1,freeze=0,holdref=0,th=1,en=1,set=0,valid=1,raw=0;reg[18:0]saved;reg[31:0]players=32'h88442211;
wire[18:0]state,refstate;wire[7:0]pins,refpins,bpins,refb;
tap_fixture #(.T(T)) dut(.clk_sys(clk),.reset_active(reset),.ce_cpu(ce),.ss_freeze(freeze),.ss_set(set),.ss_valid(valid),.hold(1'b0),.th(th),.enabled(en),.raw_serial(raw),.ss_in(saved),.players(players),.physical(7'h7f),.pause_combo(1'b0),.state(state),.joya(pins),.joyb(bpins),.joyser(),.USER_OUT());
tap_fixture #(.T(T)) reference(.clk_sys(clk),.reset_active(reset),.ce_cpu(ce),.ss_freeze(1'b0),.ss_set(1'b0),.ss_valid(1'b0),.hold(holdref),.th(th),.enabled(en),.raw_serial(raw),.ss_in(19'd0),.players(players),.physical(7'h7f),.pause_combo(1'b0),.state(refstate),.joya(refpins),.joyb(refb),.joyser(),.USER_OUT());
task tick;begin @(negedge clk);#1;end endtask
task check;begin if(state!==refstate||pins!==refpins||bpins!==refb)$fatal(1,"T%0d case%0d phase%0d low%0d near%0d pending%0d state%h/%h pins%h/%h",T,cases,phase,low,near,edgepending,state,refstate,pins,refpins);end endtask
task settle;begin ce=0;repeat(2)tick;ce=1;end endtask
task roundtrip;reg finalth;begin
 settle;saved=state;holdref=1;freeze=1;repeat(T+5)tick;
 if(state!==saved)$fatal(1,"freeze advances local state");
 finalth=th;freeze=0;repeat(6)begin th=~th;tick;end th=1;repeat(T+3)tick;th=finalth;
 freeze=1;set=1;tick;set=0;if(state!==saved)$fatal(1,"restore not exact");
 repeat(2)tick;check;freeze=0;holdref=0;
end endtask
integer phase,low,near,edgepending,b,i,cases=0;
initial begin
for(phase=0;phase<4;phase=phase+1)for(low=0;low<2;low=low+1)for(near=0;near<4;near=near+1)for(edgepending=0;edgepending<2;edgepending=edgepending+1)for(b=0;b<(T==8?64:1);b=b+1)begin
 holdref=0;freeze=0;reset=1;th=1;tick;th=0;tick;th=1;repeat(T+3)tick;reset=0;
 th=0;tick;th=1;tick;repeat(phase)begin th=0;tick;th=1;tick;end
 if(low)begin th=0;tick;end
 if(near>0)begin th=1;while(state[15:0]<T-1)tick;repeat(near-1)tick;end
 players={8'(b*19+8'h80),8'(b*17+8'h40),8'(b*13+8'h20),8'(b*7+8'h10)};
 settle;
 if(edgepending)begin ce=0;th=~th;end
 roundtrip;ce=1;
 for(i=0;i<T+12;i=i+1)begin if(i<8)th=~th;players=players+32'h01030507;tick;check;end
 roundtrip;th=~th;tick;check;
 en=0;tick;check;en=1;tick;check;reset=1;tick;check;reset=0;
 cases=cases+1;
end
// Exact legacy normalization uses expired capacitor and current TH history.
valid=0;freeze=1;th=0;set=1;tick;set=0;
if(state!=={1'b0,2'd0,16'(T+1)})$fatal(1,"legacy normalization");
repeat(2)tick;freeze=0;th=1;tick;th=0;tick;if(state[17:16]!=0)$fatal(1,"legacy first fall counted");th=1;tick;th=0;tick;if(state[17:16]!=1)$fatal(1,"legacy second fall missed");
$display("PASS Master Tap directed T=%0d cases=%0d: state/pins exact, phases/TH/timeout/buttons, repeated restore, reset/disable, legacy",T,cases);$finish;
end
endmodule
