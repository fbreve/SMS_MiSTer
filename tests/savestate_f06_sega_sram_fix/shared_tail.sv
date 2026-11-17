reg[7:0]v1[0:32767],v2[0:32767],wrm[0:16383],nv[0:32767];
integer wc1=0,wc2=0,wcw=0,wcn=0,profile,ns,vs1,vs2,ws;
integer seen1[0:32767],seen2[0:32767],seenw[0:16383],seenn[0:32767];
function[7:0]pat(input integer a,owner);pat=(a*73)^(a>>3)^(a>>8)^(owner*37);endfunction
always@(posedge clk)begin
 vram_D<=v1[vram_A];vram2_D<=v2[vram2_A];wram_D<=wrm[wram_A];nvram_D<=nv[nvram_A];
 if(vram_WE)begin v1[vram_WA]<=vram_WD;wc1++;seen1[vram_WA]++;end
 if(vram2_WE)begin v2[vram2_WA]<=vram2_WD;wc2++;seen2[vram2_WA]++;end
 if(wram_WE)begin wrm[wram_WA]<=wram_WD;wcw++;seenw[wram_WA]++;end
 if(nvram_WE)begin nv[nvram_WA]<=nvram_WD;wcn++;seenn[nvram_WA]++;end
end
task initialize(input bit perturb);begin
 for(integer j=0;j<32768;j++)begin v1[j]=perturb?~pat(j,1):pat(j,1);v2[j]=perturb?~pat(j,2):pat(j,2);nv[j]=perturb?~pat(j,3):pat(j,3);seen1[j]=0;seen2[j]=0;seenn[j]=0;end
 for(integer j=0;j<16384;j++)begin wrm[j]=perturb?~pat(j,4):pat(j,4);seenw[j]=0;end
 wc1=0;wc2=0;wcw=0;wcn=0;repeat(3)tick;
end endtask
task verify_mem;begin
 for(integer j=0;j<32768;j++)begin
  if(v1[j]!== (j<vs1?pat(j,1):~pat(j,1))||seen1[j]!=(j<vs1?1:0))$fatal(1,"VRAM1 byte%h profile%0d",j,profile);
  if(v2[j]!== (j<vs2?pat(j,2):~pat(j,2))||seen2[j]!=(j<vs2?1:0))$fatal(1,"VRAM2 byte%h profile%0d",j,profile);
  if(nv[j]!== (j<ns?pat(j,3):~pat(j,3))||seenn[j]!=(j<ns?1:0))$fatal(1,"NVRAM byte%h profile%0d",j,profile);
 end
 for(integer j=0;j<16384;j++)if(wrm[j]!== (j<ws?pat(j,4):~pat(j,4))||seenw[j]!=(j<ws?1:0))$fatal(1,"WRAM byte%h profile%0d",j,profile);
 if(wc1!=vs1||wc2!=vs2||wcw!=ws||wcn!=ns)$fatal(1,"transfer counts");
end endtask
initial begin
 for(integer j=0;j<12288;j++)mem[j]=0;
 repeat(4)tick;reset_n=1;
 for(profile=0;profile<10;profile++)begin
  systeme=profile<4;mapper_out=systeme?((profile&1)?64'h80:0)|((profile&2)?64'h40:0):0;
  sc_ram_size=profile>=5&&profile<=7?profile-4:0;
  eeprom_present=profile==8;evolution_out=profile==9?160'h00000000000000000000891234568912e1322468:0;
  ns=systeme?0:eeprom_present?128:sc_ram_size==1?2048:sc_ram_size==2?16384:32768;
  vs1=systeme?32768:16384;vs2=systeme?32768:0;ws=systeme?16384:8192;
  // Nonzero history/peripheral roundtrip alongside all physical memory routes.
  md_out=46'h123456789ab;tap_out=19'h12345;paddle_out=32'h12345678;gun_out=46'h12345678;
  gg_out=128'h00001fe00003f8000000ffa07fff00ff;
  initialize(0);transfer(1);initialize(1);transfer(0);verify_mem;
  if(md_in!==md_out||tap_in!==tap_out||paddle_in!==paddle_out||gun_in!==gun_out||gg_in!==gg_out)$fatal(1,"peripheral payload");
  if(profile==9&&evolution_in!==evolution_out)$fatal(1,"Evolution payload");
  $display("PASS SHARED profile%0d stall%0d vram1%0d vram2%0d wram%0d nvram%0d",profile,STALL,wc1,wc2,wcw,wcn);
 end
 $display("PASS SHARED COMPLETE stall%0d",STALL);$finish;
end
initial begin #200000000;$fatal(1,"shared watchdog state%0d",dut.state);end
endmodule
