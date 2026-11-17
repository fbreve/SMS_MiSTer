`timescale 1ns/1ps
module exclusion_case(output reg done=0,output wire[2047:0]observed);
parameter CANDIDATE=0,SYSTEM_E=1,ELIGIBLE=1;
localparam MAP_MODE=0,CLASS=0,FORMAT_CASE=0;
reg clk=0,reset_n=0,save_req=0,load_req=0;always #5 clk=~clk;
reg[4:0]phase=0;always @(negedge clk)phase=phase==29?0:phase+1'b1;
wire ce_cpu=phase==10||phase==25,ce_vdp=phase%5==0,ce_pix=phase%10==0,ce_sp=!phase[0];
wire vb=1;wire[8:0]x=100;wire[229:0]cpu_regs=230'h123456789abcdef;
wire m1_n=0,mreq_n=0;wire[1:0]iset=0;wire[2:0]restart_ctx=CLASS;
wire[127:0]vdp_regs=128'h987654321;wire[383:0]cram=384'h0123456789abcdef;
wire[63:0]mapper_word=MAP_MODE==0?64'h0040000000020100:MAP_MODE==1?64'h0044000000020100:64'h0054000000020100;
wire[31:0]io_word=32'hff;wire[21:0]video_word=0;wire full_sram_allowed=ELIGIBLE;
reg[7:0]wram_q=0,sram_q=0,vram_dma_d=0;reg[63:0]ddr_out=0;reg ddr_ready=0;
`include "exclusion_controller.svh"
reg[63:0]ddr[0:12287];reg[7:0]vm[0:32767],wm[0:8191],sm[0:32767];
integer pending=0,mem_writes=0,restores=0,save_words=0,load_words=0,sram_writes=0;
reg[28:0]read_addr;reg error_seen=0;longint cycles=0,save_cycles=0,load_cycles=0;
// Include high physical address bits so bank mirroring cannot pass accidentally.
function[7:0]pattern(input integer a,input integer kind);pattern=(a*37+(a>>4)+(a>>12)*11+kind*51)&255;endfunction
always @(posedge clk)begin
 cycles++;ddr_ready<=0;
 if(pending>0)begin pending<=pending-1;if(pending==1)begin ddr_out<=ddr[read_addr-29'h7c00000];ddr_ready<=1;end end
 if(ss_DDRAM_RD)begin
  if(pending)$fatal(1,"overlapping response");pending<=3;read_addr<=ss_DDRAM_ADDR;
  if(ss_DDRAM_ADDR>=29'h7c00d01 && ss_DDRAM_ADDR<=29'h7c01d00)load_words++;
 end
 if(ss_DDRAM_WE)begin
  for(integer b=0;b<8;b++)if(ss_DDRAM_BE[b])ddr[ss_DDRAM_ADDR-29'h7c00000][8*b+:8]<=ss_DDRAM_DIN[8*b+:8];
  if(ss_DDRAM_ADDR>=29'h7c00d01 && ss_DDRAM_ADDR<=29'h7c01d00)save_words++;
  if(ss_DDRAM_ADDR==29'h7c00005 && ss_DDRAM_DIN[43])begin
   if(save_words!=4096)$fatal(1,"published completeness before full payload");
  end
 end
 vram_dma_d<=vm[ss_vram_A];wram_q<=wm[ss_wram_A[12:0]];sram_q<=sm[ss_nvram_A];
 if(ss_vram_WE)begin vm[ss_vram_WA]<=ss_vram_WD;mem_writes++;end
 if(ss_wram_WE)begin wm[ss_wram_WA[12:0]]<=ss_wram_WD;mem_writes++;end
 if(ss_nvram_WE)begin sm[ss_nvram_WA]<=ss_nvram_WD;mem_writes++;sram_writes++;end
 if(ss_z80_set)begin if(ss_z80_dir!==cpu_regs)$fatal(1,"CPU mismatch");restores++;end
 if(controller.state==40)begin
  if(!error_seen)$display("REJECT old=%b cpu_idx=%0d word0=%h word5=%h latch=%h invalid=%b",controller.is_old_format,controller.cpu_idx,ddr[0],ddr[5],controller.dout_latch,controller.metadata_invalid);
  error_seen=1;
 end
end
task tick;begin @(negedge clk);#1;end endtask
task op(input bit saving);longint start_cycle;begin
 tick;save_req=saving;load_req=!saving;tick;save_req=0;load_req=0;
 wait(ss_ss_freeze);start_cycle=cycles;wait(!ss_ss_freeze);
 if(saving)save_cycles=cycles-start_cycle;else load_cycles=cycles-start_cycle;
 repeat(10)tick;
end endtask
assign observed={ss_restart_dir,ss_restart_valid,ss_ss_freeze,ss_z80_dir,ss_z80_set,ss_vdp_regs_in,ss_vdp_regs_set,ss_cram_A,ss_cram_D,ss_cram_wr,ss_vram_en,ss_vram_A,ss_vram_WE,ss_vram_WA,ss_vram_WD,ss_psg_in,ss_psg_set,ss_psg_ext_in,ss_psg2_ext_in,ss_psg_div_in,ss_audio_control_in,ss_audio_phase_in,ss_audio_ext_set,ss_audio_phase_set,ss_mapper_in,ss_mapper_set,ss_evolution_in,ss_evolution_set,ss_eeprom_in,ss_eeprom_set,ss_wram_A,ss_wram_WE,ss_wram_WA,ss_wram_WD,ss_nvram_A,ss_nvram_WE,ss_nvram_WA,ss_nvram_WD,ss_vdp2_regs_in,ss_vdp2_regs_set,ss_cram2_A,ss_cram2_D,ss_cram2_wr,ss_vram2_en,ss_vram2_A,ss_vram2_WE,ss_vram2_WA,ss_vram2_WD,ss_psg2_in,ss_psg2_set,ss_io_in,ss_io_set,ss_video_state_in,ss_video_state_set,ss_DDRAM_ADDR,ss_DDRAM_DIN,ss_DDRAM_BE,ss_DDRAM_WE,ss_DDRAM_RD,ss_DDRAM_BURSTCNT};
initial begin
 for(integer n=0;n<12288;n++)ddr[n]=0;
 for(integer n=0;n<32768;n++)begin vm[n]=pattern(n,0);sm[n]=pattern(n,2);end
 for(integer n=0;n<8192;n++)wm[n]=pattern(n,1);
 repeat(8)tick;reset_n=1;op(1);
 if(ddr[5][63:38]!==0)$fatal(1,"excluded save changed always-written metadata");
 reset_n=0;repeat(8)tick;reset_n=1;
 op(0);
 if(error_seen||restores!=1||sram_writes!=0)$fatal(1,"excluded operation failed or touched SRAM");
 done=1;
end
initial begin #100000000;$fatal(1,"transport timeout");end
endmodule

module exclusion_tb;
parameter SYSTEM_E=1,ELIGIBLE=1;
wire da,db;wire[2047:0]a,b;
exclusion_case #(.CANDIDATE(0),.SYSTEM_E(SYSTEM_E),.ELIGIBLE(ELIGIBLE))baseline(da,a);
exclusion_case #(.CANDIDATE(2),.SYSTEM_E(SYSTEM_E),.ELIGIBLE(ELIGIBLE))candidate(db,b);
always @(negedge baseline.clk)begin #1;if(a!==b)$fatal(1,"excluded outputs diverged baseline=%h candidate=%h",a,b);end
initial begin wait(da&&db);$display("PASS EXCLUSION all public outputs cycle-equal across SAVE/reset/LOAD SystemE=%0d eligible=%0d",SYSTEM_E,ELIGIBLE);$finish;end
endmodule
