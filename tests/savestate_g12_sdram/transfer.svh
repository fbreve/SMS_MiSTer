reg[7:0]v1[0:32767],v2[0:32767],saved_ram[0:16383],saved_v1[0:32767],saved_v2[0:32767];
integer wram_restore_count=0,v1_restore_count=0,v2_restore_count=0;integer wc[0:16383],vc1[0:32767],vc2[0:32767];
function[7:0]pattern(input integer addr,input integer owner);reg[31:0]h;begin
 h=(addr+owner*32'h9e3779b9+PATTERN*32'h5d713f49)*32'h45d9f3b;h=(h^(h>>16))*32'h45d9f3b;pattern=h^(h>>8)^(h>>16)^(h>>24);
end endfunction
initial begin
 for(integer n=0;n<32768;n++)begin v1[n]=pattern(n,1);v2[n]=pattern(n,2);vc1[n]=0;vc2[n]=0;end
 for(integer n=0;n<16384;n++)wc[n]=0;
end
always@(posedge clk)begin
 vram_D<=v1[vram_A];vram2_D<=v2[vram2_A];
 if(vram_WE)begin v1[vram_WA]<=vram_WD;vc1[vram_WA]++;v1_restore_count++;end
 if(vram2_WE)begin v2[vram2_WA]<=vram2_WD;vc2[vram2_WA]++;v2_restore_count++;end
 if(wram_WE)begin wc[wram_WA]++;wram_restore_count++;end
end
always@(posedge ss_freeze)begin
 if(dut.do_save)begin
  for(integer n=0;n<16384;n++)saved_ram[n]=ram_bytes[n];
  for(integer n=0;n<32768;n++)begin saved_v1[n]=v1[n];saved_v2[n]=v2[n];end
 end else begin
  wram_restore_count=0;v1_restore_count=0;v2_restore_count=0;
  for(integer n=0;n<16384;n++)wc[n]=0;
  for(integer n=0;n<32768;n++)begin vc1[n]=0;vc2[n]=0;end
 end
end
task perturb_memory;begin
 if(TRANSFER)begin
 for(integer n=0;n<16384;n++)ram_bytes[n]=saved_ram[n]^8'h5a;
 for(integer n=0;n<32768;n++)begin v1[n]=saved_v1[n]^8'ha5;v2[n]=saved_v2[n]^8'hc3;end
 end
end endtask
always@(negedge ss_freeze)if(reset_n&&!dut.do_save&&TRANSFER)begin
 for(integer n=0;n<(systeme?16384:8192);n++)if(ram_bytes[n]!==saved_ram[n]||wc[n]!=1)$fatal(1,"WRAM data/count addr%0d actual%h expected%h count%0d",n,ram_bytes[n],saved_ram[n],wc[n]);
 for(integer n=(systeme?16384:8192);n<16384;n++)if(ram_bytes[n]!== (saved_ram[n]^8'h5a)||wc[n]!=0)$fatal(1,"WRAM boundary canary");
 for(integer n=0;n<(systeme?32768:16384);n++)if(v1[n]!==saved_v1[n]||vc1[n]!=1)$fatal(1,"VRAM1 data/count addr%0d actual%h expected%h count%0d",n,v1[n],saved_v1[n],vc1[n]);
 for(integer n=0;n<(systeme?32768:0);n++)if(v2[n]!==saved_v2[n]||vc2[n]!=1)$fatal(1,"VRAM2 data/count addr%0d",n);
 if(wram_restore_count!=(systeme?16384:8192)||v1_restore_count!=(systeme?32768:16384)||v2_restore_count!=(systeme?32768:0))$fatal(1,"wrong transfer lengths");
 $display("PASS SHARED_TRANSFER banks%0d pattern%0d WRAM%0d V1%0d V2%0d everyByteExactlyOnce",BANKS,PATTERN,wram_restore_count,v1_restore_count,v2_restore_count);
end
