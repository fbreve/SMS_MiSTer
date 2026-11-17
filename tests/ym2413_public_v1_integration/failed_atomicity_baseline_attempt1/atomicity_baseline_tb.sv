`timescale 1ns/1ps
module atomicity_tb;
`include "ports.svh"
reg drop_response=0;reg[28:0]drop_addr=0;integer vram_writes=0,mapper_writes=0;
always @(posedge clk)begin if(vram_WE)vram_writes++;if(mapper_set)mapper_writes++;end
integer live_writes=0;
always @(posedge clk) if(z80_set||vdp_regs_set||psg_set||mapper_set||evolution_set||eeprom_set||io_set||video_state_set||vdp2_regs_set||psg2_set||cram_wr||cram2_wr||vram_WE||vram2_WE||wram_WE||nvram_WE||audio_ext_set||audio_phase_set||fm_state_write||fm_legacy_reset)live_writes++;
reg ready=0;reg [31:0] mock_data=0;
assign fm_initialized=ready;assign fm_state_rdata=mock_data;
always #5 clk=~clk;
integer cycles=0,pending=0,applies=0,restores=0,reads=0,checkpoint=0;
reg [28:0] ra;reg [63:0] memory[0:12287];
reg [7:0] last_cap_addr=0,last_app_addr=0;
reg [103:0] cap_bitmap=0,app_bitmap=0;
always @(negedge clk)begin cycles++;cpu_ce=cycles%15==0;vdp_ce=cycles%5==0;pix_ce=cycles%10==0;sp_ce=cycles%2;DDRAM_BUSY=cycles%53<7;end
always @(posedge clk)begin
 mock_data<=fm_state_read&&fm_state_addr==78?32'h00000047:0;
 DDRAM_DOUT_READY<=0;
 if(pending>0)begin pending<=pending-1;if(pending==1)begin if(!(drop_response&&ra==drop_addr))begin DDRAM_DOUT<=memory[ra-29'h07c00000];DDRAM_DOUT_READY<=1;end end end
 if(DDRAM_RD&&!DDRAM_BUSY)begin if(DDRAM_ADDR>=29'h07c029ca && DDRAM_ADDR<=29'h07c029cb)$fatal(1,"stale read from eliminated FM words 50..51");if(pending)$fatal(1,"protocol overlapping reads");pending<=3+cycles%9;ra<=DDRAM_ADDR;reads++;end
 if(DDRAM_WE&&!DDRAM_BUSY)begin
  if(DDRAM_ADDR>=29'h07c029ca && DDRAM_ADDR<=29'h07c029cb)$fatal(1,"stale write to eliminated FM words 50..51");
  for(integer b=0;b<8;b++)if(DDRAM_BE[b])memory[DDRAM_ADDR-29'h07c00000][8*b+:8]<=DDRAM_DIN[8*b+:8];
 end
 if(fm_state_read)begin
  if(fm_state_addr>=104)$fatal(1,"stale capture address %0d",fm_state_addr);
  cap_bitmap[fm_state_addr]<=1;last_cap_addr<=fm_state_addr;
 end
 if(fm_state_write)begin
  if(fm_state_addr>=104)$fatal(1,"stale apply address %0d",fm_state_addr);
  app_bitmap[fm_state_addr]<=1;last_app_addr<=fm_state_addr;
  applies++;
 end
 if(z80_set)restores++;
end
task tick;begin @(negedge clk);#2;end endtask
task operation(input bit saving);begin
 force dut.op_cooldown=0;
 if(saving)cap_bitmap=0;else app_bitmap=0;
 ss_save=saving;ss_load=!saving;tick;ss_save=0;ss_load=0;
 wait(ss_freeze);wait(!ss_freeze);repeat(12)tick;
 release dut.op_cooldown;
end endtask
task reject(input integer kind);integer old_restores,old_applies,old_live;begin
 old_restores=restores;old_applies=applies;old_live=live_writes;operation(0);
 if(live_writes!=old_live)$fatal(1,"rejected LOAD changed non-FM/live state case=%0d",kind);
 if(restores!=old_restores||applies!=old_applies)$fatal(1,"malformed image applied case=%0d",kind);
 $display("PASS protocol malformed=%0d rejected before ANY live-state write",kind);
end endtask

 task reject_all(input integer tag);integer old_live;begin
  old_live=live_writes;operation(0);
  if(live_writes!=old_live)$fatal(1,"FM rejection caused live-state write tag=%0d",tag);
  if(dut.z80_snap[63:0]!==memory[2])$fatal(1,"shadow sentinel did not reach load path");
  $display("PASS baseline FORMAT_REJECT tag=%0d shadow_changed=yes live_writes=0",tag);
 end endtask
 initial begin
  for(integer i=0;i<12288;i++)memory[i]=0;
  repeat(6)tick;reset_n=1;ready=1;audio_quiescent=1;vblank=1;ss_game_id=32'h12345678;video_state_out=0;
  operation(1);if(memory['h2997]!==64'h00681101464d5331)$fatal(1,"saved descriptor");
  memory[2]=64'h123456789abcdef0;
  memory['h2997]^=64'h0000010000000000;reject_all(0);memory['h2997]=64'h00681101464d5331;
  memory['h2998+49][63:32]=32'h80000000;reject_all(1);memory['h2998+49]=0;
  // Fault injection accelerates only the watchdog counter, not a production constant.
  drop_response=1;drop_addr=29'h07c00102;
  fork
   begin
    wait(dut.state==dut.ST_LOAD_VRAM&&dut.dout_expected&&ra==drop_addr&&pending==0);
    @(negedge clk);dut.ddram_watchdog=dut.DDRAM_WATCHDOG_MAX;
   end
   operation(0);
  join
  if(vram_writes!=8||mapper_writes!=0||restores!=0||applies!=0)$fatal(1,"unexpected timeout footprint VRAM=%0d mapper=%0d CPU=%0d FM=%0d",vram_writes,mapper_writes,restores,applies);
  if(ss_freeze!==0)$fatal(1,"timeout did not release freeze");
  $display("PASS baseline LATE_TIMEOUT partial_restore VRAM_bytes=%0d CPU=%0d FM=%0d",vram_writes,restores,applies);
  $display("PASS baseline ATOMICITY_AUDIT ALL");$finish;
 end
 initial begin #100000000;$fatal(1,"atomicity TIMEOUT state=%0d",dut.state);end
endmodule
