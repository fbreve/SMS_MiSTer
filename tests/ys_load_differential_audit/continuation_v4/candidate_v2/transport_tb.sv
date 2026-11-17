`timescale 1ns/1ps
module transport_tb;
parameter CANDIDATE=2,FORMAT_CASE=0,MAP_MODE=0,ELIGIBLE=1,CLASS=2;
reg clk=0,reset_n=0,save_req=0,load_req=0;always #5 clk=~clk;
reg[4:0]phase=0;always @(negedge clk)phase=phase==29?0:phase+1'b1;
wire ce_cpu=phase==10||phase==25,ce_vdp=phase%5==0,ce_pix=phase%10==0,ce_sp=!phase[0];
wire vb=1;wire[8:0]x=100;wire[229:0]cpu_regs=230'h123456789abcdef;
wire m1_n=0,mreq_n=0;wire[1:0]iset=0;wire[2:0]restart_ctx=CLASS;
wire[127:0]vdp_regs=128'h987654321;wire[383:0]cram=384'h0123456789abcdef;
wire[63:0]mapper_word=MAP_MODE==0?64'h0040000000020100:MAP_MODE==1?64'h0044000000020100:64'h0054000000020100;
wire[31:0]io_word=32'hff;wire[21:0]video_word=0;wire full_sram_allowed=ELIGIBLE;
reg[7:0]wram_q=0,sram_q=0,vram_dma_d=0;reg[63:0]ddr_out=0;reg ddr_ready=0;
`include "controller.svh"
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
integer expected_save_bytes,expected_load_bytes,mismatches=0;bit full_expected,reject_expected;
initial begin
 for(integer n=0;n<12288;n++)ddr[n]=64'hdeadbeef12345678;
 for(integer n=0;n<32768;n++)begin vm[n]=pattern(n,0);sm[n]=pattern(n,2);end
 for(integer n=0;n<8192;n++)wm[n]=pattern(n,1);
 full_expected=(CANDIDATE&2)!=0&&ELIGIBLE;
 expected_save_bytes=full_expected?32768:MAP_MODE==0?0:MAP_MODE==1?16384:32768;
 repeat(8)tick;reset_n=1;op(1);
 if(save_words!=expected_save_bytes/8)$fatal(1,"wrong SAVE SRAM count %0d",save_words);
 if((CANDIDATE&1)!=0||full_expected)begin
  if(ddr[5][63:48]!==16'h5953||ddr[5][47:44]!==1||ddr[5][43]!==full_expected||ddr[5][42]!==((CANDIDATE&1)!=0)||ddr[5][38]!==0)$fatal(1,"metadata mismatch");
  if((CANDIDATE&1)!=0&&ddr[5][41:39]!==CLASS)$fatal(1,"context not serialized");
  if((CANDIDATE&1)==0&&ddr[5][41:39]!==0)$fatal(1,"SRAM-only enabled context");
 end else if(ddr[5][63:38]!==0)$fatal(1,"legacy writer changed");
 if(full_expected)for(integer n=0;n<32768;n++)if(ddr['hd01+n/8][8*(n%8)+:8]!==pattern(n,2))$fatal(1,"saved physical SRAM payload mismatch address %h",n);
 case(FORMAT_CASE)
 1:ddr[5][63:38]=0; // Simulate legacy overwrite of always-written metadata word; tail remains stale.
 2:ddr[5][48]=!ddr[5][48];
 3:ddr[5][47:44]=2;
 4:begin ddr[5][42]=1;ddr[5][41:39]=6;end
 5:ddr[5][38]=1;
 6:begin ddr[5][42]=0;ddr[5][41:39]=1;end
 7:ddr[5][63:38]={16'h5953,4'd1,1'b1,((CANDIDATE&1)!=0),3'd0,1'b0}; // Otherwise-valid marker in an excluded fixture.
 8:begin
  ddr[0][63:32]=16382;
  ddr[14][63:56]=0; // Valid old PSG word; a new PSG extension in an old header is an invalid hybrid.
 end // Old64K bypass: upper word5 bits must not imply complete SRAM.
 endcase
 reject_expected=FORMAT_CASE>=2&&FORMAT_CASE<=7;
 expected_load_bytes=FORMAT_CASE==8?0:(full_expected&&FORMAT_CASE!=1)?32768:MAP_MODE==0?0:MAP_MODE==1?16384:32768;
 reset_n=0;repeat(8)tick;reset_n=1;
 for(integer n=0;n<32768;n++)begin vm[n]=0;sm[n]=0;end
 for(integer n=0;n<8192;n++)wm[n]=0;
 mem_writes=0;restores=0;error_seen=0;op(0);
 if(reject_expected)begin
  if(!error_seen||mem_writes||restores||sram_writes)$fatal(1,"malformed metadata applied state");
 end else begin
  if(error_seen||restores!=1)$fatal(1,"roundtrip incomplete error=%b restores=%0d memory_writes=%0d load_words=%0d state=%0d old=%b",error_seen,restores,mem_writes,load_words,controller.state,controller.is_old_format);
  for(integer n=0;n<16384;n++)if(vm[n]!==pattern(n,0))mismatches++;
  for(integer n=0;n<8192;n++)if(wm[n]!==pattern(n,1))mismatches++;
  for(integer n=0;n<32768;n++)if(sm[n]!==((n<expected_load_bytes)?pattern(n,2):8'd0))mismatches++;
  if(mismatches||sram_writes!=expected_load_bytes||load_words!=expected_load_bytes/8)$fatal(1,"LOAD SRAM mismatch %0d bytes=%0d reads=%0d",mismatches,sram_writes,load_words);
  if((CANDIDATE&1)!=0&&FORMAT_CASE==0)begin if(!ss_restart_valid||ss_restart_dir!=CLASS)$fatal(1,"context mismatch");end
  else if(ss_restart_valid)$fatal(1,"unrequested context enabled");
 end
 $display("PASS TRANSPORT variant=%0d format=%0d map=%0d eligible=%0d class=%0d rejected=%b SAVE_words=%0d LOAD_words=%0d SRAM_WE=%0d SAVE_cycles=%0d LOAD_cycles=%0d",CANDIDATE,FORMAT_CASE,MAP_MODE,ELIGIBLE,CLASS,reject_expected,save_words,load_words,sram_writes,save_cycles,load_cycles);
 $finish;
end
initial begin #100000000;$fatal(1,"transport timeout");end
endmodule
