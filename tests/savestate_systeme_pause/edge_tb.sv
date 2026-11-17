`timescale 1ns/1ps
module edge_tb;
reg clk=0,reset_n=0,joy=0,vb=1,freeze=0;
wire paused,pp,up;
always #5 clk=~clk;
pause_fixture p(clk,reset_n,1'b1,joy,vb,freeze,1'b0,paused,pp,up);
task tick;begin @(negedge clk);#1;end endtask
initial begin
repeat(4)tick;reset_n=1;repeat(3)tick;
freeze=1;tick;joy=1;repeat(5)tick;freeze=0;repeat(5)tick;
if({paused,pp,up}!==0)$fatal(1,"held transport button manufactured edge");
joy=0;repeat(3)tick;joy=1;repeat(3)tick;
if({paused,pp,up}!==3'b010)$fatal(1,"fresh post-transport edge lost");
joy=0;repeat(3)tick;vb=0;repeat(3)tick;
if({paused,pp,up}!==3'b100)$fatal(1,"queued pause not applied");
joy=1;repeat(3)tick;
if({paused,pp,up}!==3'b101)$fatal(1,"unpause pending not reachable");
freeze=1;repeat(3)tick;vb=1;repeat(3)tick;freeze=0;repeat(5)tick;
if({paused,pp,up}!==0)$fatal(1,"transport held-button clear/release incorrect");
joy=0;repeat(3)tick;joy=1;repeat(3)tick;
if({paused,pp,up}!==3'b010)$fatal(1,"next fresh edge not recognized");
$display("PASS pause edge history: current held input consumed during transport, no duplicate release edge, fresh edges work, pending unpause clears");$finish;
end
endmodule
