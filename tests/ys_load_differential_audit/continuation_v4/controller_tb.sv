`timescale 1ns/1ps
module controller_tb;
parameter CANDIDATE=1,FORMAT_CASE=0;
reg clk=0,reset_n=0,save_req=0,load_req=0;always #5 clk=~clk;
reg [4:0] phase=0;always @(negedge clk)phase=phase==29?0:phase+1'b1;
wire ce_cpu=phase==10||phase==25,ce_vdp=phase%5==0,ce_pix=phase%10==0,ce_sp=!phase[0];
wire vb=1;wire [8:0]x=100;wire [229:0]cpu_regs=230'h123456789abcdef;wire m1_n=0,mreq_n=0;wire [1:0]iset=0;wire [2:0]restart_ctx=2;
wire [127:0]vdp_regs=128'h987654321;wire [383:0]cram=384'h0123456789abcdef;wire [63:0]mapper_word=64'h0044000000020100;wire [31:0]io_word=32'hff;wire [21:0]video_word=0;
reg [7:0]wram_q=0,sram_q=0,vram_dma_d=0;reg [63:0]ddr_out=0;reg ddr_ready=0;
`include "controller.svh"
reg [63:0]ddr[0:12287];reg [7:0]vm[0:32767],wm[0:8191],sm[0:32767];integer pending=0,mem_writes=0,restores=0;reg [28:0]read_addr;reg error_seen=0;
function [7:0]pattern(input integer a,input integer kind);pattern=(a*37+(a>>4)+kind*51)&255;endfunction
always @(posedge clk)begin
 ddr_ready<=0;
 if(pending>0)begin pending<=pending-1;if(pending==1)begin ddr_out<=ddr[read_addr-29'h7c00000];ddr_ready<=1;end end
 if(ss_DDRAM_RD)begin if(pending)$fatal(1,"overlapping response");pending<=3;read_addr<=ss_DDRAM_ADDR;end
 if(ss_DDRAM_WE)for(integer b=0;b<8;b++)if(ss_DDRAM_BE[b])ddr[ss_DDRAM_ADDR-29'h7c00000][8*b+:8]<=ss_DDRAM_DIN[8*b+:8];
 vram_dma_d<=vm[ss_vram_A];wram_q<=wm[ss_wram_A[12:0]];sram_q<=sm[ss_nvram_A];
 if(ss_vram_WE)begin vm[ss_vram_WA]<=ss_vram_WD;mem_writes++;end
 if(ss_wram_WE)begin wm[ss_wram_WA[12:0]]<=ss_wram_WD;mem_writes++;end
 if(ss_nvram_WE)begin sm[ss_nvram_WA]<=ss_nvram_WD;mem_writes++;end
 if(ss_z80_set)begin if(ss_z80_dir!==cpu_regs)$fatal(1,"CPU roundtrip mismatch");restores++;end
 if(controller.state==40)error_seen=1;
end
task tick;begin @(negedge clk);#1;end endtask
task op(input bit saving);begin
 tick;save_req=saving;load_req=!saving;tick;save_req=0;load_req=0;wait(ss_ss_freeze);wait(!ss_ss_freeze);repeat(10)tick;
end endtask
integer mismatches=0;
initial begin
 for(integer n=0;n<12288;n++)ddr[n]=0;
 for(integer n=0;n<32768;n++)begin vm[n]=pattern(n,0);sm[n]=pattern(n,2);end
 for(integer n=0;n<8192;n++)wm[n]=pattern(n,1);
 repeat(8)tick;reset_n=1;op(1);
 if(CANDIDATE)begin if(ddr[5][63:48]!==16'h4352||ddr[5][43:41]!==3'd2)$fatal(1,"context not serialized");end
 else if(ddr[5][63:38]!==0)$fatal(1,"baseline format changed");
 case(FORMAT_CASE)
 1:ddr[5][63:38]=0;
 2:ddr[5][48]=!ddr[5][48];
 3:ddr[5][47:44]=2;
 4:ddr[5][43:41]=6;
 5:ddr[5][43:41]=7;
 6:ddr[5][38]=1;
 endcase
 // Core/controller reset retains the independently saved DDR slot.
 reset_n=0;repeat(8)tick;reset_n=1;
 for(integer n=0;n<32768;n++)begin vm[n]=0;sm[n]=0;end
 for(integer n=0;n<8192;n++)wm[n]=0;
 mem_writes=0;restores=0;error_seen=0;op(0);
 if(FORMAT_CASE>=2)begin if(!error_seen||mem_writes||restores)$fatal(1,"malformed context applied state");
  $display("PASS CONTROLLER reject format=%0d before memory writes or CPU restore",FORMAT_CASE);
 end else begin
  if(error_seen||restores!=1)$fatal(1,"roundtrip did not complete");
  for(integer n=0;n<16384;n++)if(vm[n]!==pattern(n,0))mismatches++;
  for(integer n=0;n<8192;n++)if(wm[n]!==pattern(n,1))mismatches++;
  for(integer n=0;n<16384;n++)if(sm[n]!==pattern(n,2))mismatches++;
  if(mismatches)$fatal(1,"memory roundtrip mismatch %0d",mismatches);
  if(CANDIDATE&&FORMAT_CASE==0)begin if(!ss_restart_valid||ss_restart_dir!=2)$fatal(1,"context restore mismatch");end
  else if(ss_restart_valid)$fatal(1,"legacy/baseline context should be invalid");
  $display("PASS CONTROLLER roundtrip candidate=%0d format=%0d VRAM16K WRAM8K SRAM16K with production900000-clock flush",CANDIDATE,FORMAT_CASE);
 end
 $finish;
end
initial begin #100000000;$fatal(1,"controller timeout");end
endmodule
