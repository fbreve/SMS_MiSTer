`timescale 1ns/1ps
module upgrade_tb;
parameter CUT=0,STALL=1,EXCLUDE=0,ROUNDS=1,BANK=0,PREVIOUS_FM=0;
`include "stress_ports.svh"
always #5 clk=~clk;
reg[63:0] memory[0:12287];reg[7:0]vm[0:32767],vm2[0:32767],wm[0:16383],sm[0:32767];
reg[31:0]fm_q=0;reg[31:0]fm_words[0:99];assign fm_state_rdata=fm_q;assign fm_initialized=1;
integer cycles=0,pending=0,reads=0,writes=0,sram_save_words=0,sram_load_words=0,sram_writes=0,restores=0,errors=0,generation=0;
reg[28:0]read_addr;reg old_wait=0;reg[102:0]old_command;reg block_commit=0;
wire eligible=EXCLUDE==0;
wire full_restore=eligible && !(PREVIOUS_FM && !BANK && (CUT==0 || CUT==9));
function[7:0]pattern(input integer a,input integer kind);pattern=(a*37+(a>>4)+(a>>12)*11+kind*51)&255;endfunction
always @(negedge clk)begin
 cycles++;cpu_ce=cycles%15==0;vdp_ce=cycles%5==0;pix_ce=cycles%10==0;sp_ce=cycles%2;
 DDRAM_BUSY=(STALL&&cycles%53<7)||(block_commit&&dut.state==69);
end
always @(posedge clk)begin
 DDRAM_DOUT_READY<=0;
 if(reset_n&&old_wait&&{DDRAM_RD,DDRAM_WE,DDRAM_ADDR,DDRAM_DIN,DDRAM_BE}!==old_command)$fatal(1,"DDRAM command changed while stalled");
 old_wait<=reset_n&&DDRAM_BUSY&&(DDRAM_RD||DDRAM_WE);old_command<={DDRAM_RD,DDRAM_WE,DDRAM_ADDR,DDRAM_DIN,DDRAM_BE};
 if(pending>0)begin pending<=pending-1;if(pending==1)begin DDRAM_DOUT<=memory[read_addr-29'h7c00000];DDRAM_DOUT_READY<=1;end end
 if(DDRAM_RD&&!DDRAM_BUSY)begin if(pending)$fatal(1,"overlapping read");pending<=3;read_addr<=DDRAM_ADDR;reads++;
  if(DDRAM_ADDR>=29'h7c00d01&&DDRAM_ADDR<=29'h7c01d00)sram_load_words++;end
 if(DDRAM_WE&&!DDRAM_BUSY)begin
  for(integer b=0;b<8;b++)if(DDRAM_BE[b])memory[DDRAM_ADDR-29'h7c00000][8*b+:8]<=DDRAM_DIN[8*b+:8];writes++;
  if(!systeme&&DDRAM_ADDR>=29'h7c00d01&&DDRAM_ADDR<=29'h7c01d00)sram_save_words++;
  if(DDRAM_ADDR==29'h7c0000e&&DDRAM_DIN[63]&&eligible&&sram_save_words<4096)$fatal(1,"commit before full SRAM accepted");
 end
 vram_D<=vm[vram_A];vram2_D<=vm2[vram2_A];wram_D<=wm[wram_A];nvram_D<=sm[nvram_A];
 if(vram_WE)vm[vram_WA]<=vram_WD;if(vram2_WE)vm2[vram2_WA]<=vram2_WD;if(wram_WE)wm[wram_WA]<=wram_WD;
 if(nvram_WE)begin sm[nvram_WA]<=nvram_WD;sram_writes++;end
 if(z80_set)begin restores++;if(z80_dir!==z80_reg)$fatal(1,"CPU context changed");end
 if(mapper_set&&mapper_in!==mapper_out)$fatal(1,"mapper restore order/data");
 if(nvram_WE&&!ss_freeze)$fatal(1,"SRAM write outside freeze");
 if(dut.state==40)errors++;
 if(fm_state_read)fm_q<=fm_words[fm_state_addr];if(fm_state_write)fm_words[fm_state_addr]<=fm_state_wdata;
end
task tick;begin @(negedge clk);#2;end endtask
task reset_dut;begin reset_n=0;repeat(8)tick;reset_n=1;end endtask
task operation(input bit saving);begin
 wait(dut.state==0&&dut.op_cooldown==0);tick;ss_save=saving;ss_load=!saving;tick;ss_save=0;ss_load=0;
 wait(ss_freeze);wait(!ss_freeze);repeat(12)tick;
end endtask
task check_memory(input integer expected_generation);begin
 for(integer n=0;n<32768;n++)if(sm[n]!== (full_restore?pattern(n,2+expected_generation):8'hac))$fatal(1,"physical SRAM mismatch address=%h actual=%h generation=%0d",n,sm[n],expected_generation);
 if(sram_writes!=(full_restore?32768:0))$fatal(1,"wrong SRAM LOAD footprint %0d",sram_writes);
end endtask
initial begin
 for(integer n=0;n<12288;n++)memory[n]=64'hdeadbeef12345678;
 for(integer n=0;n<32768;n++)begin vm[n]=pattern(n,0);vm2[n]=pattern(n,4);sm[n]=pattern(n,2);end
 for(integer n=0;n<16384;n++)wm[n]=pattern(n,1);for(integer n=0;n<100;n++)fm_words[n]=0;
 audio_quiescent=1;vblank=1;x=100;ss_game_id=32'h12345678;z80_reg=230'h123456789abcdef;
 sc3000_mode=EXCLUDE==1;eeprom_present=EXCLUDE==2;systeme=EXCLUDE==4;
 if(EXCLUDE==3)evolution_out[31:16]=16'he132;
 mapper_out=64'h0040000000030100|(BANK?64'h0008000000000000:0);
 reset_dut;operation(1);
 if(memory['h1a][63:40] !== (eligible?24'h484314:24'h484311))$fatal(1,"wrong exclusion tag");
 if(sram_save_words!=(eligible?4096:0))$fatal(1,"wrong physical SAVE count");
 if(PREVIOUS_FM)memory['h1a][63:40]=24'h484311;
 if(CUT>0&&CUT<10)begin
  reset_dut;sram_save_words=0;generation=1;block_commit=CUT==8;for(integer n=0;n<32768;n++)sm[n]=pattern(n,3);
  fork
   operation(1);
   begin
    case(CUT)
     1:wait(DDRAM_WE&&!DDRAM_BUSY&&DDRAM_ADDR==29'h7c0000e&&!DDRAM_DIN[63]);
     2:wait(DDRAM_WE&&!DDRAM_BUSY&&DDRAM_ADDR==29'h7c0001a);
     3:wait(DDRAM_WE&&!DDRAM_BUSY&&DDRAM_ADDR==29'h7c00e00);
     4:wait(DDRAM_WE&&!DDRAM_BUSY&&DDRAM_ADDR==29'h7c01d00);
     5:wait(DDRAM_WE&&!DDRAM_BUSY&&DDRAM_ADDR==29'h7c00020);
     6:wait(DDRAM_WE&&!DDRAM_BUSY&&DDRAM_ADDR==29'h7c0000e&&DDRAM_DIN[63]);
     7:wait(DDRAM_WE&&!DDRAM_BUSY&&DDRAM_ADDR==29'h7c00000);
     8:begin wait(dut.state==69);repeat(12)tick;end
     9:begin wait(dut.state==66);tick;end
    endcase
    if(CUT<8)begin @(posedge clk);#1;end
    reset_n=0;block_commit=0;repeat(8)tick;reset_n=1;
   end
  join
 end
 if(CUT==10)begin
  reset_dut;for(integer n=0;n<32768;n++)sm[n]=8'hac;sram_writes=0;
  fork operation(0);begin wait(sram_writes==1024);tick;reset_dut;end join
 end
 for(integer round=0;round<ROUNDS;round++)begin
  if(round==0)reset_dut;
  for(integer n=0;n<32768;n++)sm[n]=8'hac;sram_writes=0;restores=0;errors=0;sram_load_words=0;
  operation(0);
  if(CUT>=1&&CUT<=5||CUT==8)begin
   if(errors==0||restores!=0||sram_writes!=0)$fatal(1,"incomplete SAVE accepted or applied");
  end else begin
   if(errors!=0||restores!=1)$fatal(1,"valid LOAD failed");check_memory((CUT==6||CUT==7)?1:0);
  end
 end
 $display("PASS STRESS CUT=%0d STALL=%0d EXCLUDE=%0d ROUNDS=%0d BANK=%0d cycles=%0d",CUT,STALL,EXCLUDE,ROUNDS,BANK,cycles);$finish;
end
initial begin #4000000000;$fatal(1,"stress timeout");end
endmodule
