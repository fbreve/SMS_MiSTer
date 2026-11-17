`timescale 1ns/1ps
module strict_tb;
reg clk=0,reset_n=0,ce=0,hold=0,rd=0,wr=0;reg[7:0] addr=0;reg[31:0] wd=0;reg[15:0] bus_a=0;reg[7:0] bus_d=0;reg bus_wr_n=1;
wire[31:0] cr,rr;wire[13:0] cy,ry;wire[12:0] ca,ra;wire ci,ri;
candidate_wrapper c(.clk_sys(clk),.RESET_n(reset_n),.ce_raw(ce),.ss_freeze(hold),.fm_initialization_run(1'b0),.fm_legacy_reset(1'b0),.fm_ena(1'b1),.D_in(bus_d),.A(bus_a),.fm_WR_n(bus_wr_n),.fm_state_addr(addr),.fm_state_read(rd),.fm_state_write(wr),.fm_state_wdata(wd),.fm_state_rdata(cr),.fm_initialized(ci),.FM_out(cy),.audible(ca));
reference_wrapper r(.clk_sys(clk),.RESET_n(reset_n),.ce_raw(ce),.ss_freeze(hold),.fm_initialization_run(1'b0),.fm_legacy_reset(1'b0),.fm_ena(1'b1),.D_in(bus_d),.A(bus_a),.fm_WR_n(bus_wr_n),.fm_state_addr(addr),.fm_state_read(rd),.fm_state_write(wr),.fm_state_wdata(wd),.fm_state_rdata(rr),.fm_initialized(ri),.FM_out(ry),.audible(ra));
always #5 clk=~clk;
reg[71:0] seen_phases=0;integer clocks=0,phase=0,checks=0,checkpoint=0;reg[31:0]image[0:99];
always @(negedge clk)begin phase=(phase+1)%15;ce=phase==0;end
always @(posedge clk)begin #2;clocks++;if(reset_n&&clocks>3000)begin
 if($isunknown({cy,ry,ca,ra}))$fatal(1,"unknown audio");
 if(cy!==ry||ca!==ra||ci!==ri)$fatal(1,"strict live/output mismatch clock=%0d",clocks);
 if(hold&&cr!==rr)$fatal(1,"state response mismatch");checks++;
end end
task tick;begin @(negedge clk);#3;end endtask
task ticks(input integer n);begin repeat(n)tick;end endtask
task musical(input integer a,input integer d);begin bus_a=16'hf0;bus_d=a;bus_wr_n=0;ticks(31);bus_wr_n=1;ticks(121);bus_a=16'hf1;bus_d=d;bus_wr_n=0;ticks(31);bus_wr_n=1;ticks(2401);end endtask
task mark(input integer n);begin checkpoint=n;$stop;checkpoint=0;end endtask
initial begin
 ticks(6);reset_n=1;ticks(3000);if(!ci||!ri)$fatal(1,"initialization");
 musical(0,'he1);musical(1,'he1);musical(2,0);musical(3,7);musical(4,'hf4);musical(5,'hf4);musical(6,'h25);musical(7,'h25);
 for(integer ch=0;ch<9;ch++)begin musical('h30+ch,ch*16);musical('h10+ch,100+ch*7);musical('h20+ch,'h19);end
 for(integer pass=0;pass<72;pass++)begin
  ticks(15*pass+1);hold=1;tick;
  for(integer w=0;w<100;w++)begin addr=w;rd=1;ticks(3);image[w]=cr;if(cr!==rr)$fatal(1,"captured image mismatch");end
  if(image[78]>71)$fatal(1,"invalid captured scheduler");seen_phases[image[78]]=1;rd=0;mark(1);hold=0;ticks(1009+pass*3);
  if(pass%12==0)begin musical(14,(pass%24==0)?'h3f:'h20);musical('h20,(pass%24==0)?9:'h19);end
  hold=1;tick;for(integer w=0;w<100;w++)begin addr=w;wd=image[w];wr=1;tick;wr=0;tick;end
  mark(2);for(integer w=0;w<100;w++)begin addr=w;rd=1;ticks(3);if(cr!==image[w]||rr!==image[w])$fatal(1,"restored readback mismatch word=%0d",w);end
  rd=0;addr='hff;ticks(8);hold=0;ticks(2000);mark(3);
 end
 $display("PASS strict observed capture counter positions=%0d",$countones(seen_phases));
 $display("PASS strict full-reference equivalence: 72 repeated SAVE/LOAD pairs, all host clocks including immediate mixer transient, raw/clamped output, capture/readback, checks=%0d",checks);$finish;
end
initial begin #50000000;$fatal(1,"strict watchdog");end
endmodule
