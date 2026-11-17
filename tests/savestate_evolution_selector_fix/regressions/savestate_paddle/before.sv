`timescale 1ns/1ps
module before_replay;
reg clk=0;always #5 clk=~clk;
reg holdref=0,freeze=0,jp=0,th0=1,th1=1;reg[7:0]p0=8'ha3,p1=8'h5c;
wire[31:0]state,refstate;wire[9:0]pins,refpins;
paddle_fixture dut(clk,1'b0,freeze,1'b0,1'b0,jp,1'b0,32'd0,p0,p1,8'd0,8'd0,th0,th1,state,pins);
paddle_fixture reference(clk,holdref,1'b0,1'b0,1'b0,jp,1'b0,32'd0,p0,p1,8'd0,8'd0,th0,th1,refstate,refpins);
task tick;begin @(negedge clk);#1;end endtask
task setup;begin
holdref=0;freeze=0;jp=0;th0=1;th1=1;p0=8'ha3;p1=8'h5c;
// Original RTL has no reset. Choose one legal power-up phase, then drive protocol naturally.
dut.cnt_en16khz=10;reference.cnt_en16khz=10;
repeat(2)tick;th0=0;th1=0;tick;end endtask
integer k,i,gaps;reg[31:0]saved;reg mismatch;
initial begin
for(k=0;k<5;k=k+1)begin
setup;
if(k>=3)begin jp=1;while(!state[16])tick;if(k==4)repeat(127)tick;end
saved=state;holdref=1;freeze=1;
if(k<3)begin p0=8'h76;p1=8'h29;th0=1;th1=1;tick;th0=0;th1=0;tick;end
else repeat(k==3?3356:100000)tick;
$display("PRE F10 case%0d saved=%h transported=%h ref=%h pins=%h/%h",k,saved,state,refstate,pins,refpins);
freeze=0;p0=8'he1;p1=8'hb4;holdref=0;
if(k<3)begin th0=1;th1=1;end
mismatch=0;for(i=0;i<6800;i=i+1)begin tick;if(pins!==refpins)mismatch=1;end
if(!mismatch)$fatal(1,"missing observable divergence case%0d",k);
$display("CONFIRMED F10 case%0d future pins=%h/%h state=%h/%h",k,pins,refpins,state,refstate);
end
$display("PASS PRE-FIX F10: five observable divergences (cached high, unequal nibbles, between edges, JP alternation, transport phase)");$finish;
end
endmodule
