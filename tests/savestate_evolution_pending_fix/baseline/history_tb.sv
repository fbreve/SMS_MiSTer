`timescale 1ns/1ps
// Ordinary execution controls and complete delayed switches; never restores or
// forces mapper internals. Checks the transition rule independently of LOAD.
module history_matrix_tb;
reg clk=0,rst=0,wr=1,mreq=1,iq=1,rd=1,m1=1;reg[15:0]a=0;reg[7:0]d=0;
wire[159:0]extra;wire[63:0]mapped;wire[23:0]physical;wire[15:0]game,previous;wire[7:0]mode;wire launch;
evolution_machine dut(.clk(clk),.reset_n(rst),.a(a),.d(d),.mreq(mreq),.iorq(iq),.rd(rd),.wr(wr),.m1(m1),.set(1'b0),.ein(160'd0),.min(64'd0),.extra(extra),.mapped(mapped),.physical(physical),.game(game),.previous(previous),.mode(mode),.launch(launch));
always #5 clk=~clk;
task tick;begin @(negedge clk);#1;end endtask
task idle;begin wr=1;mreq=1;iq=1;rd=1;m1=1;tick;end endtask
task outport(input[7:0]p,input[7:0]v);begin a={8'd0,p};d=v;wr=0;iq=0;repeat(30)tick;idle;end endtask
task sel(input[15:0]v);begin outport('h61,v[7:0]);outport('h62,v[15:8]);end endtask
task fetch(input[15:0]v);begin a=v;mreq=0;rd=0;m1=0;repeat(15)tick;idle;end endtask
task sw(input[7:0]v);begin a='h3ffe;d=v;mreq=0;wr=0;repeat(30)tick;idle;fetch('h100);fetch('h200);repeat(3)tick;end endtask
task check(input[15:0]g,input[15:0]p,input integer n);begin
 if(game!==g||previous!==p)$fatal(1,"history stage%0d game%h prev%h expected%h/%h",n,game,previous,g,p);
 $display("HISTORY stage%0d game=%h previous=%h current=%h%h mode=%h",n,game,previous,extra[7:0],extra[15:8],mode);
end endtask
initial begin
 repeat(4)tick;rst=1;tick;check(0,0,0);
 sel('h2800);check(0,0,1);sw('h87);check('h2800,0,2);
 sel('h2800);sw('h87);check('h2800,0,3);
 sel('h4800);sw('h87);check('h4800,'h2800,4);
 sel('h2800);sw('h87);check('h2800,'h4800,5);
 sel('h2900);sw('h87);check('h2900,'h2800,6);
 sel('h6000);sw('h87);check('h6000,'h2900,7);
 sw('h85);check('h6000,'h2900,8);a='h8123;tick;if(physical!==24'h008123)$fatal(1,"menu not passthrough");
 sw('h87);check('h6000,'h2900,9);
 // Re-enter the real launch-record path, then let its data read complete.
 sw('h85);fetch('h1380);a='h20a8;mreq=0;rd=0;repeat(30)tick;idle;
 sel('h4800);sw('h87);a='h8123;tick;
 if(mapped[63:48]!==16'h20a8||physical!==24'h288123)$fatal(1,"record override failed");
 $display("PASS F14 history matrix initial/first/same/alternating/adjacent/nonadjacent/menu-return/record-reentry");$finish;
end
endmodule
