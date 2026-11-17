integer payload=0,restore_bytes=0,clocks=0,start_clock,save_clocks,load_clocks;
reg counting_save=0,counting_load=0;
reg[7:0]expected[0:32767];reg[63:0]image[0:12287];
integer write_seen[0:4095],byte_seen[0:32767];
always@(posedge clk)begin
 clocks++;
 if(counting_save&&DDRAM_WE&&!DDRAM_BUSY&&DDRAM_ADDR>=29'h07c00d01&&DDRAM_ADDR<=29'h07c01d00)begin payload++;write_seen[DDRAM_ADDR-29'h07c00d01]++;end
 if(counting_load&&nvram_WE)begin restore_bytes++;byte_seen[nvram_WA]++;if(!ss_freeze)$fatal(1,"SRAM restore outside freeze");end
end
function[7:0]pattern(input integer j,seed);pattern=(j*73)^(j>>3)^(j>>8)^seed;endfunction
task hostfill(input bit perturb,input integer seed);begin
 for(integer j=0;j<32768;j++)begin host_addr=j;host_data=perturb?~expected[j]:pattern(j,seed);if(!perturb)expected[j]=host_data;host_we=1;tick;end
 host_we=0;tick;
end endtask
task guestfill;begin
 for(integer banknum=0;banknum<2;banknum++)begin control(banknum?8'h0c:8'h08);for(integer j=0;j<16384;j++)put(16'h8000+j,expected[banknum*16384+j]);end
 control(0);
end endtask
task scan(input integer limit);reg changed_by_control;begin
 changed_by_control=ext;
 for(integer banknum=0;banknum<2;banknum++)begin
  control(banknum?8'h0c:8'h08);
  for(integer j=0;j<16384;j++)begin a=16'h8000+j;mreq=0;repeat(2)tick;
   // Exposing bank0 after extension mode writes FFFC through the still-live
   // C000 SRAM alias first. The uninterrupted bus performs the same write.
   if(q!==((changed_by_control&&banknum==0&&j=='h3ffc)?8'h08:(banknum*16384+j<limit?expected[banknum*16384+j]:~expected[banknum*16384+j])))$fatal(1,"byte mismatch bank%0d off%h got%h",banknum,j,q);
  end
  mreq=1;
 end
end endtask
task physical_scan(input integer limit);begin
 for(integer j=0;j<32768;j++)begin host_addr=j;repeat(2)tick;if(physical_q!==(j<limit?expected[j]:~expected[j]))$fatal(1,"physical byte%h got%h expected%h",j,physical_q,j<limit?expected[j]:~expected[j]);end
end endtask
task save_now(input integer expected_words);reg[63:0]mapper_before;begin
 mapper_before=mapper_out;payload=0;for(integer j=0;j<4096;j++)write_seen[j]=0;
 counting_save=1;start_clock=clocks;transfer(1);save_clocks=clocks-start_clock;counting_save=0;
 if(mapper_out!==mapper_before)$fatal(1,"SAVE changed mapper");
 if(payload!=expected_words)$fatal(1,"payload words %0d expected%0d",payload,expected_words);
 for(integer j=0;j<expected_words;j++)if(write_seen[j]!=1)$fatal(1,"duplicate/skipped word%0d",j);
 for(integer j=0;j<32768&&j<expected_words*8;j++)if(mem['hd01+j/8][(j%8)*8+:8]!==expected[j])$fatal(1,"image byte%h",j);
 for(integer j=0;j<12288;j++)if((^mem[j])===1'bx)$fatal(1,"unknown full image%h",j);
end endtask
task load_now(input integer expected_bytes);begin
 restore_bytes=0;for(integer j=0;j<32768;j++)byte_seen[j]=0;
 counting_load=1;start_clock=clocks;transfer(0);load_clocks=clocks-start_clock;counting_load=0;
 if(restore_bytes!=expected_bytes)$fatal(1,"restore bytes%0d expected%0d",restore_bytes,expected_bytes);
 for(integer j=0;j<expected_bytes;j++)if(byte_seen[j]!=1)$fatal(1,"duplicate/skipped restore byte%h",j);
end endtask
integer mode,words,bytes,fd;reg[7:0]flags;reg[63:0]mapper_saved;integer changes;
task dump(input string filename);begin fd=$fopen(filename,"wb");for(integer j=0;j<12288;j++)for(integer b=0;b<8;b++)$fwrite(fd,"%c",mem[j][8*b+:8]);$fclose(fd);end endtask
initial begin
 for(integer j=0;j<12288;j++)mem[j]=0;
 repeat(4)tick;reset_n=1;mapper_reset_n=1;repeat(4)tick;
 for(mode=0;mode<9;mode++)begin
  hostfill(0,mode+37);
  if(mode!=6)guestfill; // mode6 has NO prior guest SRAM access in its context
  if(mode==6||mode==8)begin mapper_reset_n=0;repeat(3)tick;mapper_reset_n=1;repeat(3)tick;end
  flags=(mode==1||mode==6||mode==8)?0:mode==3?8'h0c:mode==5?8'h18:8'h08;
  if(mode!=6)control(flags); // mode6 only mapper reset, no guest writes at all
  if(flags[4])expected['h3ffc]=flags; // the second stretched FFFC write aliases SRAM
  a=0;di=0;repeat(3)tick;
  mapper_saved=mapper_out;
  words=OLD?((flags&8'h14)?4096:(flags&8)?2048:0):4096;
  save_now(words);
  if(mem['h1a][63:40]!== (OLD?24'h484311:24'h484312))$fatal(1,"current tag");
  for(integer j=0;j<12288;j++)image[j]=mem[j];
  // SAVE-only must preserve every physical byte. Read after saving and then
  // restore the original mapper flags through guest control before perturbing.
  physical_scan(32768);scan(32768);control(flags);
  if(mapper_out!==mapper_saved)$fatal(1,"SAVE-only mapped future");
  for(integer replaynum=0;replaynum<3;replaynum++)begin
   hostfill(1,0);control(0);load_now(words*8);
   if(mapper_out!==mapper_saved)$fatal(1,"LOAD visibility/bank restore");
   physical_scan(words*8);scan(words*8);
   for(integer j=0;j<12288;j++)if(mem[j]!==image[j])$fatal(1,"LOAD changed image");
  end
  $display("PASS F06 case%0d old%0d stall%0d words%0d SAVEclocks%0d LOADclocks%0d fullbytecanaries32768 replays3",mode,OLD,STALL,words,save_clocks,load_clocks);
 end
 // Same prior single-byte collision, with complete images and aligned framework
 // counter. v18 must differ only in the SRAM word carrying that physical byte.
 hostfill(0,55);control(0);a=0;di=0;
 host_addr=0;host_data=8'h41;host_we=1;tick;host_we=0;expected[0]=8'h41;
 reset_n=0;repeat(3)tick;reset_n=1;repeat(3)tick;save_now(OLD?0:4096);
 for(integer j=0;j<12288;j++)image[j]=mem[j];dump("pair_a.bin");
 host_addr=0;host_data=8'h42;host_we=1;tick;host_we=0;expected[0]=8'h42;
 reset_n=0;repeat(3)tick;reset_n=1;repeat(3)tick;save_now(OLD?0:4096);dump("pair_b.bin");changes=0;
 for(integer j=0;j<12288;j++)if(mem[j]!==image[j])begin changes++;if(j!='hd01)$fatal(1,"non-SRAM image difference%h",j);end
 if(changes!==(OLD?0:1))$fatal(1,"collision separation words%0d",changes);
 readbank(0,8'h42);
 $display("PASS NONINJECTIVE old%0d imagewordsdifferent%0d future41vs42",OLD,changes);
 $display("PASS F06 COMPLETE old%0d stall%0d",OLD,STALL);$finish;
end
initial begin #1000000000;$fatal(1,"watchdog state%0d",dut.state);end
endmodule
