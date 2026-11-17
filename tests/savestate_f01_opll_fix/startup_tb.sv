`timescale 1ns/1ps
module startup_tb;
reg clk=0;always #5 clk=~clk;
reg reset_n=0,save=0,ce=0;wire freeze,initialized;wire[13:0]fm;
integer age=0,accepted=0;
always@(posedge clk)if(!reset_n)age<=0;else age<=age+1;
opll sound(.xin(clk),.xena(ce),.d(8'd0),.a(1'b0),.cs_n(1'b0),.we_n(1'b0),.ic_n(reset_n),.mixout(fm),.ss_hold(freeze),.ss_addr(8'hff),.ss_read(1'b0),.ss_write(1'b0),.ss_wdata(32'd0),.ss_rdata(),.ss_initialized(initialized));
savestates ctrl(.clk(clk),.reset_n(reset_n),.ss_save(save),.ss_load(1'b0),.ss_slot(2'd0),.ss_bios_mode(1'b0),.ss_game_id(32'd0),.ss_freeze(freeze),.fm_initialized(initialized),.fm_state_rdata(32'd0),.z80_replay(1'b0),.z80_tick_active(1'b0),.clock_phase(2'd0),.clock_phase_ready(1'b0),.vblank(1'b1),.x(9'd0),.z80_reg(230'd0),.z80_nmi(3'b001),.z80_restart(3'd0),.z80_m1_n(1'b0),.z80_mreq_n(1'b0),.z80_iset(2'd0),.cpu_ce(1'b1),.storage_busy(1'b0),.DDRAM_BUSY(1'b0),.DDRAM_DOUT_READY(1'b0),.audio_quiescent(1'b1),.systeme(1'b0));
task tick;begin @(negedge clk);#1;end endtask
initial begin
 for(integer trial=0;trial<8;trial++)begin
  reset_n=0;save=0;repeat(2)tick;
  if(initialized!==0||freeze!==0)$fatal(1,"reset readiness");
  reset_n=1;repeat(1+trial*13)tick;
  save=1;tick;save=0;
  while(!initialized)begin
   if(freeze)$fatal(1,"SAVE accepted before explicit initialization");
   tick;if(age>116)$fatal(1,"unbounded initializer wait");
  end
  if(age!=115)$fatal(1,"unexpected readiness edge %0d",age);
  while(!freeze)begin tick;if(age>117)$fatal(1,"pending SAVE lost after ready");end
  accepted++;
  $display("STARTUP trial%0d age%0d ce%b",trial,age,ce);
  // Reset during the same existing VBlank, before the private transport begins.
  reset_n=0;tick;
 end
 $display("PASS STARTUP warm_resets%0d no_FM_ticks",accepted);$finish;
end
initial begin #100000;$fatal(1,"startup watchdog");end
endmodule
