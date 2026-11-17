task tick;begin @(negedge clk_sys);#1;end endtask
task getbyte(input[14:0]addr,input[7:0]value);begin nvram_a=addr;repeat(3)tick;if(nvram_q!==value)$fatal(1,"lifecycle RAM %h got%h expected%h",addr,nvram_q,value);end endtask
task guestbyte(input[14:0]addr,input[7:0]value);begin nvram_a=addr;nvram_d=value;nvram_we=1;tick;nvram_we=0;tick;end endtask
task download(input bit changed,input bit mount,input bit nonempty);begin
 cart_download=1;tick;ioctl_wr=1;
 for(integer j=0;j<64;j++)begin ioctl_addr=j;ioctl_dout=(changed&&j==12)?8'h5a:j;tick;end
 ioctl_wr=0;img_mounted=mount;img_size=nonempty?32768:0;repeat(2)tick;img_mounted=0;cart_download=0;repeat(3)tick;
end endtask
task sector_ack;begin sd_ack=1;repeat(2)tick;sd_ack=0;repeat(3)tick;end endtask
task persistent_load(input[7:0]value);begin
 for(integer sector=0;sector<64;sector++)begin
  wait(sd_rd);sd_ack=1;tick;
  for(integer b=0;b<512;b++)begin sd_buff_addr=b;sd_buff_dout=value;sd_buff_wr=1;tick;end
  sd_buff_wr=0;sd_ack=0;repeat(3)tick;
 end
 if(bk_state)$fatal(1,"persistence did not finish");
end endtask
reg[31:0]id_a;integer count;
initial begin
 repeat(4)tick;getbyte(0,8'hff);getbyte(32767,8'hff);
 guestbyte(0,8'h31);guestbyte(16384,8'h72);
 RESET=1;repeat(3)tick;RESET=0;status[0]=1;repeat(3)tick;status[0]=0;
 getbyte(0,8'h31);getbyte(16384,8'h72);$display("PASS resets retain both banks");
 download(0,0,0);id_a=ss_game_id;getbyte(0,8'h31);getbyte(16384,8'h72);
 download(0,0,0);if(ss_game_id!==id_a)$fatal(1,"same image id");getbyte(0,8'h31);getbyte(16384,8'h72);$display("PASS same ROM reload retained before access");
 download(1,0,0);if(ss_game_id===id_a)$fatal(1,"different image id");getbyte(0,8'h31);getbyte(16384,8'h72);if(bk_ena)$fatal(1,"unmounted bk_ena");$display("PASS different ROM stale SRAM retained before access");
 eject_rom=1;tick;eject_rom=0;getbyte(0,8'h31);getbyte(16384,8'h72);$display("PASS eject retains both banks");
 download(1,1,0);if(!bk_ena||bk_state)$fatal(1,"empty mounted save semantics");getbyte(0,8'h31);getbyte(16384,8'h72);$display("PASS empty mounted save retains stale SRAM");
 img_readonly=1;download(1,1,1);if(bk_ena||bk_state)$fatal(1,"readonly mounted save semantics");img_readonly=0;getbyte(0,8'h31);getbyte(16384,8'h72);$display("PASS readonly mount does not establish replacement");
 download(1,1,1);if(!bk_state||!bk_loading)$fatal(1,"auto persistent load missing");persistent_load(8'h65);getbyte(0,8'h65);getbyte(32767,8'h65);$display("PASS persistent load full32768");
 // SAVE/LOAD arbitration: queue while SS busy; LOAD intentionally requested by
 // host is allowed to supersede savestate bytes only after SS completes.
 ss_busy=1;status[6]=1;repeat(3)tick;status[6]=0;repeat(2)tick;
 if(bk_state||!bk_load_wait)$fatal(1,"queued persistent load arbitration");
 ss_freeze=1;ss_nvram_WE=1;ss_nvram_WA=0;ss_nvram_WD=8'h99;tick;ss_nvram_WE=0;ss_freeze=0;getbyte(0,8'h99);
 ss_busy=0;repeat(3)tick;persistent_load(8'h44);getbyte(0,8'h44);$display("PASS explicitly queued persistent LOAD overwrites after SS");
 status[7]=1;repeat(3)tick;status[7]=0;count=0;
 while(bk_state)begin if(!sd_wr)$fatal(1,"expected persistent write");sector_ack;count++;end
 if(count!=64)$fatal(1,"persistent sector count %0d",count);getbyte(0,8'h44);getbyte(32767,8'h44);$display("PASS persistent write64sectors RAM unchanged");
 $display("PASS LIFECYCLE COMPLETE");$finish;
end
initial begin #20000000;$fatal(1,"lifecycle watchdog");end
endmodule
