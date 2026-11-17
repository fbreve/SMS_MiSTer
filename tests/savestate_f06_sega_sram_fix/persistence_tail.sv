task fileload(input[7:0]value);begin
 for(integer sector=0;sector<64;sector++)begin
  wait(sd_rd);if(sd_lba!==sector)$fatal(1,"persistent sector order");
  sd_ack=1;tick;
  for(integer j=0;j<512;j++)begin sd_buff_addr=j;sd_buff_dout=value;sd_buff_wr=1;tick;end
  sd_buff_wr=0;sd_ack=0;repeat(3)tick;
 end
 if(bk_state)$fatal(1,"persistent load not complete");
end endtask
task checkphysical(input[7:0]value);begin
 for(integer j=0;j<32768;j++)begin host_addr=j;repeat(2)tick;if(physical_q!==value)$fatal(1,"persistent SRAM byte%h",j);end
end endtask
integer sectors;
initial begin
 for(integer j=0;j<12288;j++)mem[j]=0;
 repeat(4)tick;reset_n=1;mapper_reset_n=1;repeat(4)tick;
 cart_download=1;tick;img_size=32768;img_mounted=1;repeat(2)tick;img_mounted=0;cart_download=0;repeat(3)tick;
 if(!bk_loading||!bk_ena)$fatal(1,"auto file load not started");
 fileload(8'h35);checkphysical(8'h35);
 if(bk_pending)$fatal(1,"file load left dirty pending");
 transfer(1);if(bk_state||bk_pending||sd_rd||sd_wr)$fatal(1,"savestate SAVE triggered persistence");checkphysical(8'h35);
 status[6]=1;repeat(3)tick;status[6]=0;fileload(8'ha7);checkphysical(8'ha7);
 transfer(0);repeat(30)tick;
 if(bk_state||sd_rd||sd_wr)$fatal(1,"v18 release auto-started persistent load");
 checkphysical(8'h35);
 status[7]=1;repeat(3)tick;status[7]=0;sectors=0;
 while(bk_state)begin
  wait(sd_wr);sd_ack=1;tick;
  for(integer j=0;j<512;j++)begin sd_buff_addr=j;repeat(2)tick;if(physical_q!==8'h35)$fatal(1,"persistent write data");end
  sd_ack=0;repeat(3)tick;sectors++;
 end
 if(sectors!=64)$fatal(1,"persistent write size %0d",sectors);
 checkphysical(8'h35);
 $display("PASS PERSISTENCE actualFSM load32768 write32768 SS_SAVE_no_trigger v18_release_no_overwrite");
 // Pending SAVE must not accept while a real persistent read is in progress.
 status[6]=1;repeat(3)tick;status[6]=0;
 force dut.op_cooldown=0;ss_save=1;tick;ss_save=0;
 fork fileload(8'h61);begin repeat(30)tick;if(ss_freeze)$fatal(1,"SS froze during persistence");end join
 wait(ss_busy);wait(!ss_busy);release dut.op_cooldown;checkphysical(8'h61);
 $display("PASS PERSISTENCE storage_busy excludes capture until actual64sectors complete");
 $display("PASS PERSISTENCE COMPLETE");$finish;
end
initial begin #100000000;$fatal(1,"persistent watchdog state%0d",dut.state);end
endmodule
