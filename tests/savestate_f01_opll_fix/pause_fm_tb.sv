`timescale 1ns/1ps
module pause_fm_tb;
reg clk=0;always #5 clk=~clk;
reg reset_n=0,hold=0,ce=0,runref=1,qmode=0,joy=0,vb=1;
wire paused,rpaused;wire pp,up,rpp,rup;
pause_fixture ui(.clk(clk),.reset_n(reset_n),.systeme(1'b1),.joy8_sig(joy),.VBlank(vb),.ss_freeze(hold),.preserve(1'b1),.se_paused(paused),.se_pause_pending(pp),.se_unpause_pending(up));
pause_fixture rui(.clk(clk),.reset_n(reset_n),.systeme(1'b1),.joy8_sig(joy),.VBlank(vb),.ss_freeze(1'b0),.preserve(1'b1),.se_paused(rpaused),.se_pause_pending(rpp),.se_unpause_pending(rup));
reg capture=0,apply_state=0;wire[7:0]addr;wire read_en,write_en,initialized,done;
wire[31:0]wdata,opll_data,rdata;reg[31:0]wrapper_data=0;
reg a=0,ra=0,bus_a=0,bus_write=0;reg[7:0]d=0,rd=0,bus_d=0;
wire[13:0]fm,rfm;wire rclk=clk&&runref;
opll sound(.xin(clk),.xena(ce&&!hold&&!paused),.d(d),.a(a),.cs_n(1'b0),.we_n(1'b0),.ic_n(reset_n),.mixout(fm),.ss_hold(hold),.ss_addr(addr),.ss_read(read_en),.ss_write(write_en),.ss_wdata(wdata),.ss_rdata(opll_data),.ss_initialized(initialized));
opll reference_sound(.xin(rclk),.xena(ce&&!rpaused),.d(rd),.a(ra),.cs_n(1'b0),.we_n(1'b0),.ic_n(reset_n),.mixout(rfm),.ss_hold(1'b0),.ss_addr(8'hff),.ss_read(1'b0),.ss_write(1'b0),.ss_wdata(32'd0),.ss_rdata(),.ss_initialized());
opll_snapshot store(.clk(clk),.reset_n(reset_n),.capture(capture),.apply_state(apply_state),.legacy(1'b0),.initialized(initialized),.legacy_reset(),.initialization_run(),.bulk_read(1'b0),.bulk_write(1'b0),.bulk_addr(7'd0),.bulk_wdata(64'd0),.bulk_rdata(),.done(done),.busy(),.state_addr(addr),.state_read(read_en),.state_write(write_en),.state_wdata(wdata),.state_rdata(rdata));
always@(posedge clk)begin
 if(!reset_n)begin a<=0;d<=0;ra<=0;rd<=0;end
 else begin
  if(hold&&write_en&&addr==8'h4c)begin a<=wdata[0];d<=wdata[8:1];end
  else if(!hold&&bus_write)begin a<=bus_a;d<=bus_d;end
  if(!qmode&&bus_write)begin ra<=bus_a;rd<=bus_d;end
 end
 wrapper_data<=0;if(hold&&read_en&&addr==8'h4c)wrapper_data<={23'd0,d,a};
end
assign rdata=opll_data|wrapper_data;
task tick;begin @(negedge clk);#1;end endtask
task ticks(input integer n);begin for(integer i=0;i<n;i++)begin ce=1;tick;ce=0;repeat(14)tick;end end endtask
task wr(input[7:0]r,input[7:0]v);begin bus_a=0;bus_d=r;bus_write=1;ticks(8);bus_write=0;ticks(8);bus_a=1;bus_d=v;bus_write=1;ticks(160);bus_write=0;end endtask
task finish_op;begin wait(done);tick;end endtask
task set_pause(input bit value);begin
 if(paused!==value)begin
  joy=1;repeat(3)tick;joy=0;repeat(3)tick;
  vb=0;repeat(3)tick;vb=1;repeat(3)tick;
 end
 if(paused!==value||rpaused!==value||pp||up||rpp||rup)$fatal(1,"UI pause transition failed");
end endtask
integer checks=0;
initial begin
 for(integer save_mode=0;save_mode<2;save_mode++)for(integer load_mode=0;load_mode<2;load_mode++)begin
  reset_n=0;hold=0;ce=0;runref=1;qmode=0;joy=0;vb=1;repeat(6)tick;reset_n=1;ticks(100);
  wr(0,8'h21);wr(1,8'h21);wr(2,8'h10);wr(3,7);wr(4,8'hf4);wr(5,8'hf4);wr(6,4);wr(7,4);wr(8'h30,0);wr(8'h10,8'h91);wr(8'h20,8'h19);ticks(2000);
  if(fm!==rfm||fm==0)$fatal(1,"active FM prefix");
  ce=0;set_pause(save_mode);hold=1;runref=0;capture=1;tick;capture=0;finish_op;
  if(paused!==save_mode)$fatal(1,"SAVE changed logical Pause");
  qmode=1;hold=0;set_pause(0);wr(8'h30,8'hf0);wr(8'h10,8'h37);ticks(901+load_mode*33);
  ce=0;set_pause(load_mode);hold=1;apply_state=1;tick;apply_state=0;finish_op;
  if(paused!==load_mode||rpaused!==load_mode)$fatal(1,"LOAD changed current host Pause");
  hold=0;runref=1;
  for(integer i=0;i<20000;i++)begin
   ce=(i%15==0);
   if(load_mode)begin
    if(i==100)joy=1;if(i==103)joy=0;if(i==110)vb=0;if(i==113)vb=1;
   end
   tick;if(fm!==rfm)$fatal(1,"Pause FM mismatch save%0d load%0d sample%0d",save_mode,load_mode,i);checks++;
  end
  ce=0;$display("PASS PAUSE FM save%0d load%0d first_and20000",save_mode,load_mode);
 end
 $display("PASS PAUSE FM ALL checks%0d",checks);$finish;
end
initial begin #100000000;$fatal(1,"Pause FM watchdog");end
endmodule
