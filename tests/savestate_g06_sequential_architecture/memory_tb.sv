`timescale 1ns/1ps
module memory_tb;
reg clk=0;always #5 clk=~clk;
reg reset_n=0,cap=0,apply_state=0,legacy=0,systeme=0,br=0,bw=0;
reg[7:0]ba=0;reg[63:0]bd=0;wire[63:0]bq;wire done,busy;
wire[7:0]a;wire second,sr,sw;wire[31:0]wd;reg[31:0]rd;
reg[31:0]live[0:299],expected[0:299];integer reads[0:299],writes[0:299];
wire[8:0]row=(second?9'd150:9'd0)+a;
sprite_snapshot dut(.clk(clk),.reset_n(reset_n),.capture(cap),.apply_state(apply_state),.legacy(legacy),.systeme(systeme),.bulk_read(br),.bulk_write(bw),.bulk_addr(ba),.bulk_wdata(bd),.bulk_rdata(bq),.done(done),.busy(busy),.state_addr(a),.state_second(second),.state_read(sr),.state_write(sw),.state_wdata(wd),.state_rdata(rd));
always@(posedge clk)begin
 if(sr)begin if(row>=300)$fatal(1,"read address");rd<=live[row];reads[row]++;end
 if(sw)begin if(row>=300)$fatal(1,"write address");live[row]<=wd;writes[row]++;end
end
task tick;begin @(posedge clk);#1;@(negedge clk);end endtask
task finish_command;begin while(!busy)tick;while(busy)tick;if(!done)$fatal(1,"completion");end endtask
task clear_counts;begin for(integer i=0;i<300;i++)begin reads[i]=0;writes[i]=0;end end endtask
reg[31:0]rng=32'h7e3a215b;
function[31:0]next32;begin rng=rng^(rng<<13);rng=rng^(rng>>17);rng=rng^(rng<<5);next32=rng;end endfunction
integer capture_clocks,apply_clocks,host=0;
always@(posedge clk)host++;
initial begin
clear_counts;repeat(3)tick;reset_n=1;tick;
for(integer trial=0;trial<6;trial++)begin
 systeme=trial[0];legacy=0;clear_counts;
 for(integer i=0;i<300;i++)begin live[i]=next32();expected[i]=i>=150&&!systeme?0:live[i];end
 cap=1;tick;cap=0;capture_clocks=host;while(busy)tick;capture_clocks=host-capture_clocks;
 if(capture_clocks!=600)$fatal(1,"capture latency%0d",capture_clocks);
 for(integer i=0;i<300;i++)if(reads[i]!=(i<150||systeme?1:0)||writes[i]!=0)$fatal(1,"capture coverage row%0d",i);
 for(integer w=149;w>=0;w--)begin
  repeat((trial%3)==0?0:(trial%3)==1?7:97)tick;
  ba=w;br=1;tick;br=0;while(busy)tick;
  if(bq!=={expected[2*w+1],expected[2*w]})$fatal(1,"bulk read%0d",w);
 end
 // Strong Q, then immutable-image replay.
 for(integer i=0;i<300;i++)live[i]=~expected[i];
 for(integer replay=0;replay<3;replay++)begin
  clear_counts;apply_state=1;tick;apply_state=0;apply_clocks=host;while(busy)tick;apply_clocks=host-apply_clocks;
  if(apply_clocks!=(systeme?600:300))$fatal(1,"apply latency");
  for(integer i=0;i<(systeme?300:150);i++)if(live[i]!==expected[i]||writes[i]!=1)$fatal(1,"apply%0d",i);
  for(integer i=0;i<300;i++)live[i]=next32();
 end
 // Typed-independent address-derived replacement proves LOAD ordering and halves.
 for(integer w=0;w<150;w++)begin
  expected[2*w]=32'ha0000000^(2*w);expected[2*w+1]=32'h50000000^(2*w+1);
  ba=w;bd={expected[2*w+1],expected[2*w]};bw=1;tick;bw=0;while(busy)tick;
 end
 clear_counts;apply_state=1;tick;apply_state=0;while(busy)tick;
 for(integer i=0;i<(systeme?300:150);i++)if(live[i]!==expected[i]||writes[i]!=1)$fatal(1,"bulk write/load%0d",i);
 clear_counts;legacy=1;apply_state=1;tick;apply_state=0;while(busy)tick;
 for(integer i=0;i<(systeme?300:150);i++)if(live[i]!==0||writes[i]!=1)$fatal(1,"legacy default%0d",i);
 $display("PASS MEMORY trial%0d dual%b capture600 apply%0d repeated3",trial,systeme,systeme?600:300);
end
$display("PASS MEMORY ALL trials6 words300 exact_once legacy transport_gaps0_7_97");$finish;
end
endmodule
