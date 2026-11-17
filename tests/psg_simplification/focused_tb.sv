`timescale 1ns/1ps
module focused_tb;
reg clk=0;always #5 clk=~clk;
reg rst=1,ce=0,perturb=0,load=0,wr=1,cwr=1;
reg[7:0]din=0;reg[55:0]saved;
wire[55:0]cfg,rcfg;wire signed[10:0]l,r,rl,rr;
C_jt89 dut(.clk(clk),.clk_en(ce|perturb),.rst(rst),.wr_n(wr&cwr),.din(din),.mux(8'hff),.soundL(l),.soundR(r),.ready(),.ss_out(cfg),.ss_in(saved),.ss_set(load));
A_jt89 refpsg(.clk(clk),.clk_en(ce),.rst(rst),.wr_n(wr),.din(din),.mux(8'hff),.soundL(rl),.soundR(rr),.ready(),.ss_out(rcfg),.ss_in(56'd0),.ss_set(1'b0),.ss_ext_out(),.ss_ext_in(96'd0),.ss_ext_set(1'b0),.ss_div_out(),.ss_div_in(4'd0),.ss_quiescent());
task tick;begin @(negedge clk);#1;end endtask
task put(input[7:0]b);begin din=b;wr=0;repeat(2)tick;wr=1;repeat(2)tick;end endtask
task reset;begin rst=1;ce=0;perturb=0;load=0;wr=1;cwr=1;repeat(4)tick;rst=0;repeat(3)tick;end endtask
integer mismatches,lastdiff,late,total=0,firstdiff;
initial begin
 // Tone <6 forces a constant positive generator output. Change only current
 // volume history, then restore configuration: stale samples must settle.
 for(integer tone=0;tone<6;tone=tone+1)begin
  reset;put(8'h80|tone);put(8'h00);put(8'h91);ce=1;repeat(100)tick;ce=0;repeat(4)tick;saved=rcfg;
  din=8'h9f;cwr=0;repeat(2)tick;cwr=1;perturb=1;repeat(64)tick;perturb=0;repeat(4)tick;
  load=1;tick;load=0;repeat(2)tick;
  mismatches=0;lastdiff=-1;firstdiff=-1;
  for(integer i=0;i<1000;i=i+1)begin
   ce=i%7==0;tick;if(cfg!==rcfg)$fatal(1,"transient cfg");
   if(l!==rl||r!==rr)begin mismatches=mismatches+1;lastdiff=i;if(firstdiff<0)firstdiff=i;end
  end
  if(mismatches==0||lastdiff>240||lastdiff<0)$fatal(1,"transient did not converge");
  $display("PASS sample transient tone=%0d mismatches=%0d first=%0d last=%0d stable_through=999",tone,mismatches,firstdiff,lastdiff);
 end
 // Noise-only each mode, then tone-only. Keep outputs unmasked and run beyond
 // the initial reset-counter wrap before taking the snapshot.
 for(integer mode=0;mode<9;mode=mode+1)begin
  reset;put(8'h83);put(8'h01);put(8'hc3);put(8'h01);
  if(mode<8)begin put(8'he0|mode);put(8'hf1);end else put(8'h91);
  ce=1;repeat(40000)tick;ce=0;repeat(4)tick;saved=rcfg;
  perturb=1;repeat(4099)tick;perturb=0;repeat(4)tick;load=1;tick;load=0;repeat(4)tick;
  mismatches=0;late=0;
  for(integer i=0;i<50000;i=i+1)begin
   ce=1;tick;if(cfg!==rcfg)$fatal(1,"history cfg");
   if(l!==rl||r!==rr)begin mismatches=mismatches+1;if(i>=10000)late=late+1;end
  end
  if(mismatches==0||late==0)$fatal(1,"isolated history stimulus missing output divergence mode=%0d",mode);
  total=total+mismatches;
  $display("PASS isolated history mode=%0d output_mismatches=%0d tail40000=%0d",mode,mismatches,late);
 end
 $display("PASS focused history: six sample-playback transients converge; eight noise modes plus tone retain waveform differences; total_mismatches=%0d",total);$finish;
end
endmodule
