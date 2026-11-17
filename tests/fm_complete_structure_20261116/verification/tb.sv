`timescale 1ns/1ps
module tb;
parameter integer SHIFT=0, MODE=0, NCONT=80000;
`include "ports.svh"
reg runref=1, ref_hold=0, compare_audio=0;
reg [7:0] bus_d=0; reg [15:0] bus_a=0; reg bus_wr_n=1;
wire [13:0] audio,ref_audio; wire [31:0] unused_data;wire unused_ready;
wire [12:0] audible,ref_audible;wire fm_enabled=MODE!=6;
wire ref_freeze=ss_freeze||ref_hold;
candidate_wrapper fm(.clk_sys(clk),.RESET_n(reset_n),.ce_raw(cpu_ce),.ss_freeze(ss_freeze),
 .fm_initialization_run(fm_initialization_run),.fm_legacy_reset(fm_legacy_reset),
 .D_in(bus_d),.A(bus_a),.fm_WR_n(bus_wr_n),.fm_state_addr(fm_state_addr),.fm_state_read(fm_state_read),
 .fm_state_write(fm_state_write),.fm_state_wdata(fm_state_wdata),.fm_state_rdata(fm_state_rdata),.fm_initialized(fm_initialized),.FM_out(audio),.fm_ena(fm_enabled),.audible(audible));
reference_wrapper reference_fm(.clk_sys(clk),.RESET_n(reset_n),.ce_raw(cpu_ce),.ss_freeze(ref_freeze),
 .fm_initialization_run(1'b0),.fm_legacy_reset(1'b0),.D_in(bus_d),.A(bus_a),.fm_WR_n(bus_wr_n),
 .fm_state_addr(8'hff),.fm_state_read(1'b0),.fm_state_write(1'b0),.fm_state_wdata(32'd0),
 .fm_state_rdata(unused_data),.fm_initialized(unused_ready),.FM_out(ref_audio),.fm_ena(fm_enabled),.audible(ref_audible));
always #5 clk=~clk;
integer cycles=0,phase=0,pending=0,reads=0,writes=0,checks=0,restores=0,captures=0,checkpoint=0,skip=0;
integer applied=0,captured=0,checkpoint_count=0;
reg [28:0] read_addr;reg [63:0] memory[0:98303];
reg stalls=1;reg [99:0] seen_read=0,seen_write=0;
integer base=0;
always @(negedge clk) begin
 cycles=cycles+1;
 // Same 30-clock pattern as SMS.sv; enables take effect on the next edge.
 phase=(phase+1)%30;
 cpu_ce=(phase==9||phase==24);pix_ce=(phase==9||phase==19||phase==29);
 vdp_ce=(phase==4||phase==9||phase==14||phase==19||phase==24||phase==29);sp_ce=phase[0];
 DDRAM_BUSY=stalls && (cycles%97<9 || cycles%151<3);
end
always @(posedge clk) begin
 DDRAM_DOUT_READY<=0;
 if(pending>0)begin pending<=pending-1;if(pending==1)begin DDRAM_DOUT<=memory[read_addr-29'h07c00000];DDRAM_DOUT_READY<=1;end end
 if(DDRAM_WE&&!DDRAM_BUSY)begin
  if(DDRAM_ADDR<29'h07c00000||DDRAM_ADDR>=29'h07c18000)$fatal(1,"out-of-range DDR write");
  if(DDRAM_ADDR-29'h07c00000-base>=29'h2997 && DDRAM_ADDR-29'h07c00000-base<=29'h29c9)
   if(!ss_freeze)$fatal(1,"FM write without DDR ownership");
  for(integer b=0;b<8;b=b+1)if(DDRAM_BE[b])memory[DDRAM_ADDR-29'h07c00000][8*b+:8]<=DDRAM_DIN[8*b+:8];
  writes<=writes+1;
 end
 if(DDRAM_RD&&!DDRAM_BUSY)begin
  if(pending!=0)$fatal(1,"overlapping DDR read");
  read_addr<=DDRAM_ADDR;pending<=2+cycles%11;reads<=reads+1;
 end
 if(fm_state_read)begin
  if(seen_read[fm_state_addr])$fatal(1,"duplicate capture word");
  seen_read[fm_state_addr]<=1;captured<=captured+1;
 end
 if(fm_state_write)begin
  if(seen_write[fm_state_addr])$fatal(1,"duplicate apply word");
  seen_write[fm_state_addr]<=1;applied<=applied+1;
 end
 if(z80_set)restores<=restores+1;
 #2;
 if(reset_n&&!fm_enabled&&(audible!==0||ref_audible!==0))$fatal(1,"FM-disabled gate regression");
 if(compare_audio&&!ss_freeze&&!ref_hold)begin
  // Only the established mixer transient (144 enabled FM clocks = 2160 host clocks) is excluded after a full LOAD.
  if(skip>0)skip=skip-1;
  else begin
  if(audio!==ref_audio)$fatal(1,"audio continuation mismatch cycle=%0d actual=%h expected=%h",cycles,audio,ref_audio);
  if(audible!==ref_audible)$fatal(1,"clamped FM audio mismatch");
  checks=checks+1;
  end
 end
end
task tick;begin @(negedge clk);#2;end endtask
task ticks(input integer n);begin repeat(n)tick;end endtask
task wr(input [7:0] addr,input [7:0] data);begin
 // Production wrapper latches on every host clock during an I/O write;
 // OPLL sees permanently asserted cs_n/we_n and the held wrapper bus.
 bus_a=16'hf0;bus_d=addr;bus_wr_n=0;ticks(31);bus_wr_n=1;ticks(121);
 bus_a=16'hf1;bus_d=data;bus_wr_n=0;ticks(31);bus_wr_n=1;ticks(2401);
end endtask
task stop_for_oracle(input integer point);begin checkpoint=point;checkpoint_count++;$stop;checkpoint=0;end endtask
task save_state;begin
 force dut.op_cooldown=0;
 seen_read=0;captured=0;
 ss_save=1;tick;ss_save=0;
 wait(dut.fm_capture);tick;
 ref_hold=1;
 stop_for_oracle(1); // live internals before the private read port executes
 wait(!ss_freeze);ticks(12);
 if(captured!=100||seen_read!=={100{1'b1}})$fatal(1,"capture coverage %0d",captured);
 stop_for_oracle(2); // compare stored payload with independently packed internals
 captures++;release dut.op_cooldown;
end endtask
task load_state(input bit full);begin
 force dut.op_cooldown=0;seen_write=0;applied=0;
 ss_load=1;tick;ss_load=0;wait(ss_freeze);
 if(full)begin
  wait(dut.state==dut.ST_FM_APPLY_WAIT);wait(dut.fm_done);tick;
  stop_for_oracle(3); // restored internals, before unfreeze
 end
 wait(!ss_freeze);ref_hold=0;if(full)skip=2200;ticks(12);
 if(full&&(applied!=100||seen_write!=={100{1'b1}}))$fatal(1,"apply coverage %0d",applied);
 release dut.op_cooldown;
end endtask
initial begin
 for(integer i=0;i<98304;i++)memory[i]=0;
 ticks(6);reset_n=1;vblank=1;x=0;audio_quiescent=1;ss_game_id=32'h12345678;
 psg_out=56'h12345;psg_ext_out=96'h123456789;io_out=32'h98765432;video_state_out=22'h12345;
 vdp_regs=128'h123456789abcdef;cram_out={384{1'b1}};
 mapper_out=0;systeme=(MODE==1);ss_bios_mode=(MODE==2);ss_slot=SHIFT%4;
 base=(ss_bios_mode?16'hc000:0)+ss_slot*16'h3000;
 ticks(130);if(!fm_initialized)$fatal(1,"initialization readiness");
 compare_audio=1;
 wr(0,8'he1);wr(1,8'hf1);wr(2,8'h10);wr(3,8'h07);wr(4,8'hf4);wr(5,8'hd3);wr(6,8'h25);wr(7,8'h36);
 for(integer c=0;c<9;c++)begin wr(8'h30+c,c==0?0:8'h10*c);wr(8'h10+c,8'h81+c*7);wr(8'h20+c,8'h19);end
 ticks(30000+SHIFT*15);
 if(MODE==3)begin wr(8'h0e,8'h3f);ticks(20000+SHIFT);end
 if(MODE==4)begin wr(8'h20,8'h09);ticks(10000+SHIFT);end
 if(MODE==5)begin
  // Freeze during an unfinished custom-voice/key command, not after settling.
  bus_a=16'hf0;bus_d=4;bus_wr_n=0;ticks(31);bus_a=16'hf1;bus_d=8'h91;
 end
 save_state();
 for(integer pass=0;pass<3;pass++)begin
  // Save a new endpoint for each independent continuation comparison.
  if(pass>0)save_state();
  ref_hold=1;compare_audio=0;ticks(3);
  wr(8'h30,8'hf0);wr(8'h20,8'h00);wr(8'h0e,8'h20);ticks(12345+pass*17);
  compare_audio=1;
  load_state(1);ticks(NCONT);
  wr(8'h20,8'h09);ticks(1600);wr(8'h20,8'h19);
 end
 if(captures!=3||restores!=3||checks<3*(NCONT-2200))$fatal(1,"coverage incomplete");
 // Legacy untagged 96 KiB image ignores even a stale valid FM descriptor.
 compare_audio=0;memory[base+'h1a]=video_state_out;load_state(0);
 if(dut.has_fm!==0)$fatal(1,"legacy discovery used stale FM tail");
 $display("PASS fullstate SHIFT=%0d MODE=%0d captures=%0d restores=%0d checks=%0d DDRread=%0d DDRwrite=%0d checkpoints=%0d",SHIFT,MODE,captures,restores,checks,reads,writes,checkpoint_count);
 $finish;
end
initial begin #200000000;$fatal(1,"TIMEOUT state=%0d pending=%0d",dut.state,pending);end
endmodule
