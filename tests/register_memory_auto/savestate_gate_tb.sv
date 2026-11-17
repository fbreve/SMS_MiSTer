`timescale 1ns/1ps
module savestate_gate_tb;parameter REF=0;integer oracle,scan;reg[13:0]reference_sample;
reg clk='0;
reg reset_n='0;
reg ss_save='0;
reg ss_load='0;
reg [1:0] ss_slot='0;
reg ss_bios_mode='0;
reg [31:0] ss_game_id='0;
reg vblank='0;
reg [8:0] x='0;
reg [229:0] z80_reg='0;
reg z80_m1_n='0;
reg z80_mreq_n='0;
reg [1:0] z80_iset='0;
reg cpu_ce='0;
reg vdp_ce='0;
reg pix_ce='0;
reg sp_ce='0;
reg [127:0] vdp_regs='0;
reg [383:0] cram_out='0;
reg [7:0] vram_D='0;
reg [55:0] psg_out='0;
reg [95:0] psg_ext_out='0;
reg [95:0] psg2_ext_out='0;
reg [3:0] psg_div_out='0;
reg [10:0] audio_control_out='0;
reg audio_quiescent='0;
reg audio_phase_out='0;
reg [63:0] mapper_out='0;
reg [95:0] evolution_out='0;
reg [63:0] eeprom_out='0;
reg [7:0] wram_D='0;
reg [7:0] nvram_D='0;
reg systeme='0;
reg [127:0] vdp2_regs='0;
reg [383:0] cram2_out='0;
reg [7:0] vram2_D='0;
reg [55:0] psg2_out='0;
reg [31:0] io_out='0;
reg [21:0] video_state_out='0;
reg [63:0] DDRAM_DOUT='0;
reg DDRAM_DOUT_READY='0;
reg DDRAM_BUSY='0;
wire ss_freeze_a,ss_freeze_b; wire ss_freeze=ss_freeze_a;
wire [229:0] z80_dir_a,z80_dir_b; wire [229:0] z80_dir=z80_dir_a;
wire z80_set_a,z80_set_b; wire z80_set=z80_set_a;
wire [127:0] vdp_regs_in_a,vdp_regs_in_b; wire [127:0] vdp_regs_in=vdp_regs_in_a;
wire vdp_regs_set_a,vdp_regs_set_b; wire vdp_regs_set=vdp_regs_set_a;
wire [4:0] cram_A_a,cram_A_b; wire [4:0] cram_A=cram_A_a;
wire [11:0] cram_D_a,cram_D_b; wire [11:0] cram_D=cram_D_a;
wire cram_wr_a,cram_wr_b; wire cram_wr=cram_wr_a;
wire vram_en_a,vram_en_b; wire vram_en=vram_en_a;
wire [14:0] vram_A_a,vram_A_b; wire [14:0] vram_A=vram_A_a;
wire vram_WE_a,vram_WE_b; wire vram_WE=vram_WE_a;
wire [14:0] vram_WA_a,vram_WA_b; wire [14:0] vram_WA=vram_WA_a;
wire [7:0] vram_WD_a,vram_WD_b; wire [7:0] vram_WD=vram_WD_a;
wire [55:0] psg_in_a,psg_in_b; wire [55:0] psg_in=psg_in_a;
wire psg_set_a,psg_set_b; wire psg_set=psg_set_a;
wire [95:0] psg_ext_in_a,psg_ext_in_b; wire [95:0] psg_ext_in=psg_ext_in_a;
wire [95:0] psg2_ext_in_a,psg2_ext_in_b; wire [95:0] psg2_ext_in=psg2_ext_in_a;
wire [3:0] psg_div_in_a,psg_div_in_b; wire [3:0] psg_div_in=psg_div_in_a;
wire [10:0] audio_control_in_a,audio_control_in_b; wire [10:0] audio_control_in=audio_control_in_a;
wire audio_phase_in_a,audio_phase_in_b; wire audio_phase_in=audio_phase_in_a;
wire audio_ext_set_a,audio_ext_set_b; wire audio_ext_set=audio_ext_set_a;
wire audio_phase_set_a,audio_phase_set_b; wire audio_phase_set=audio_phase_set_a;
wire [63:0] mapper_in_a,mapper_in_b; wire [63:0] mapper_in=mapper_in_a;
wire mapper_set_a,mapper_set_b; wire mapper_set=mapper_set_a;
wire [95:0] evolution_in_a,evolution_in_b; wire [95:0] evolution_in=evolution_in_a;
wire evolution_set_a,evolution_set_b; wire evolution_set=evolution_set_a;
wire [63:0] eeprom_in_a,eeprom_in_b; wire [63:0] eeprom_in=eeprom_in_a;
wire eeprom_set_a,eeprom_set_b; wire eeprom_set=eeprom_set_a;
wire [13:0] wram_A_a,wram_A_b; wire [13:0] wram_A=wram_A_a;
wire wram_WE_a,wram_WE_b; wire wram_WE=wram_WE_a;
wire [13:0] wram_WA_a,wram_WA_b; wire [13:0] wram_WA=wram_WA_a;
wire [7:0] wram_WD_a,wram_WD_b; wire [7:0] wram_WD=wram_WD_a;
wire [14:0] nvram_A_a,nvram_A_b; wire [14:0] nvram_A=nvram_A_a;
wire nvram_WE_a,nvram_WE_b; wire nvram_WE=nvram_WE_a;
wire [14:0] nvram_WA_a,nvram_WA_b; wire [14:0] nvram_WA=nvram_WA_a;
wire [7:0] nvram_WD_a,nvram_WD_b; wire [7:0] nvram_WD=nvram_WD_a;
wire [127:0] vdp2_regs_in_a,vdp2_regs_in_b; wire [127:0] vdp2_regs_in=vdp2_regs_in_a;
wire vdp2_regs_set_a,vdp2_regs_set_b; wire vdp2_regs_set=vdp2_regs_set_a;
wire [4:0] cram2_A_a,cram2_A_b; wire [4:0] cram2_A=cram2_A_a;
wire [11:0] cram2_D_a,cram2_D_b; wire [11:0] cram2_D=cram2_D_a;
wire cram2_wr_a,cram2_wr_b; wire cram2_wr=cram2_wr_a;
wire vram2_en_a,vram2_en_b; wire vram2_en=vram2_en_a;
wire [14:0] vram2_A_a,vram2_A_b; wire [14:0] vram2_A=vram2_A_a;
wire vram2_WE_a,vram2_WE_b; wire vram2_WE=vram2_WE_a;
wire [14:0] vram2_WA_a,vram2_WA_b; wire [14:0] vram2_WA=vram2_WA_a;
wire [7:0] vram2_WD_a,vram2_WD_b; wire [7:0] vram2_WD=vram2_WD_a;
wire [55:0] psg2_in_a,psg2_in_b; wire [55:0] psg2_in=psg2_in_a;
wire psg2_set_a,psg2_set_b; wire psg2_set=psg2_set_a;
wire [31:0] io_in_a,io_in_b; wire [31:0] io_in=io_in_a;
wire io_set_a,io_set_b; wire io_set=io_set_a;
wire [21:0] video_state_in_a,video_state_in_b; wire [21:0] video_state_in=video_state_in_a;
wire video_state_set_a,video_state_set_b; wire video_state_set=video_state_set_a;
wire [28:0] DDRAM_ADDR_a,DDRAM_ADDR_b; wire [28:0] DDRAM_ADDR=DDRAM_ADDR_a;
wire [63:0] DDRAM_DIN_a,DDRAM_DIN_b; wire [63:0] DDRAM_DIN=DDRAM_DIN_a;
wire [7:0] DDRAM_BE_a,DDRAM_BE_b; wire [7:0] DDRAM_BE=DDRAM_BE_a;
wire DDRAM_WE_a,DDRAM_WE_b; wire DDRAM_WE=DDRAM_WE_a;
wire DDRAM_RD_a,DDRAM_RD_b; wire DDRAM_RD=DDRAM_RD_a;
wire [7:0] DDRAM_BURSTCNT_a,DDRAM_BURSTCNT_b; wire [7:0] DDRAM_BURSTCNT=DDRAM_BURSTCNT_a;
savestates_baseline a(.clk(clk),.reset_n(reset_n),.ss_save(ss_save),.ss_load(ss_load),.ss_slot(ss_slot),.ss_bios_mode(ss_bios_mode),.ss_game_id(ss_game_id),.ss_freeze(ss_freeze_a),.vblank(vblank),.x(x),.z80_reg(z80_reg),.z80_dir(z80_dir_a),.z80_set(z80_set_a),.z80_m1_n(z80_m1_n),.z80_mreq_n(z80_mreq_n),.z80_iset(z80_iset),.cpu_ce(cpu_ce),.vdp_ce(vdp_ce),.pix_ce(pix_ce),.sp_ce(sp_ce),.vdp_regs(vdp_regs),.vdp_regs_in(vdp_regs_in_a),.vdp_regs_set(vdp_regs_set_a),.cram_out(cram_out),.cram_A(cram_A_a),.cram_D(cram_D_a),.cram_wr(cram_wr_a),.vram_en(vram_en_a),.vram_A(vram_A_a),.vram_D(vram_D),.vram_WE(vram_WE_a),.vram_WA(vram_WA_a),.vram_WD(vram_WD_a),.psg_out(psg_out),.psg_in(psg_in_a),.psg_set(psg_set_a),.psg_ext_out(psg_ext_out),.psg2_ext_out(psg2_ext_out),.psg_ext_in(psg_ext_in_a),.psg2_ext_in(psg2_ext_in_a),.psg_div_out(psg_div_out),.psg_div_in(psg_div_in_a),.audio_control_out(audio_control_out),.audio_control_in(audio_control_in_a),.audio_quiescent(audio_quiescent),.audio_phase_out(audio_phase_out),.audio_phase_in(audio_phase_in_a),.audio_ext_set(audio_ext_set_a),.audio_phase_set(audio_phase_set_a),.mapper_out(mapper_out),.mapper_in(mapper_in_a),.mapper_set(mapper_set_a),.evolution_out(evolution_out),.evolution_in(evolution_in_a),.evolution_set(evolution_set_a),.eeprom_out(eeprom_out),.eeprom_in(eeprom_in_a),.eeprom_set(eeprom_set_a),.wram_A(wram_A_a),.wram_D(wram_D),.wram_WE(wram_WE_a),.wram_WA(wram_WA_a),.wram_WD(wram_WD_a),.nvram_A(nvram_A_a),.nvram_D(nvram_D),.nvram_WE(nvram_WE_a),.nvram_WA(nvram_WA_a),.nvram_WD(nvram_WD_a),.systeme(systeme),.vdp2_regs(vdp2_regs),.vdp2_regs_in(vdp2_regs_in_a),.vdp2_regs_set(vdp2_regs_set_a),.cram2_out(cram2_out),.cram2_A(cram2_A_a),.cram2_D(cram2_D_a),.cram2_wr(cram2_wr_a),.vram2_en(vram2_en_a),.vram2_A(vram2_A_a),.vram2_D(vram2_D),.vram2_WE(vram2_WE_a),.vram2_WA(vram2_WA_a),.vram2_WD(vram2_WD_a),.psg2_out(psg2_out),.psg2_in(psg2_in_a),.psg2_set(psg2_set_a),.io_out(io_out),.io_in(io_in_a),.io_set(io_set_a),.video_state_out(video_state_out),.video_state_in(video_state_in_a),.video_state_set(video_state_set_a),.DDRAM_ADDR(DDRAM_ADDR_a),.DDRAM_DIN(DDRAM_DIN_a),.DDRAM_BE(DDRAM_BE_a),.DDRAM_WE(DDRAM_WE_a),.DDRAM_DOUT(DDRAM_DOUT),.DDRAM_DOUT_READY(DDRAM_DOUT_READY),.DDRAM_RD(DDRAM_RD_a),.DDRAM_BURSTCNT(DDRAM_BURSTCNT_a),.DDRAM_BUSY(DDRAM_BUSY));
wire [13:0] fm_a,fm_b; wire fm_ce=cpu_ce&&!ss_freeze;
assign fm_a=reference_sample;generate if(REF)begin opll_baseline_programmed fm2(clk,fm_ce,reset_n,fm_b);end else begin opll_mapped_programmed fm2(clk,fm_ce,reset_n,fm_b);end endgenerate
always #5 clk=~clk;
reg [63:0] memory[0:98303];integer cycles=0,pending=0;reg [28:0] ra;
integer writes=0,reads=0,loads=0,operations=0,busy_cycles=0,audio_checks=0,nonzero_audio=0;reg stalls=0;
reg [229:0] saved_cpu;reg [127:0] saved_vdp;reg [55:0] saved_psg;
always @(negedge clk)begin
 cycles=cycles+1;cpu_ce=cycles%15==0;vdp_ce=cycles%10==0;pix_ce=cycles%10==0;sp_ce=cycles%5==0;
 if(cycles%500000==0)$display("PROGRESS cycles=%0d state=%0d freeze=%b ops=%0d reads=%0d writes=%0d pending=%0d",cycles,a.state,ss_freeze,operations,reads,writes,pending);
 DDRAM_BUSY=stalls&&(cycles%97<5);if(DDRAM_BUSY)busy_cycles=busy_cycles+1;
 #1;
 if(REF)begin $fdisplay(oracle,"%h",fm_b);reference_sample=fm_b;end else begin scan=$fscanf(oracle,"%h\n",reference_sample);if(scan!=1)$fatal(1,"oracle ended");end
 if(reference_sample!==fm_b)$fatal(1,"FM difference over real savestate freeze at cycle%0d",cycles);audio_checks=audio_checks+1;if((^fm_b)!==1'bx&&fm_b!=0)nonzero_audio=nonzero_audio+1;
end
always @(posedge clk)begin
 DDRAM_DOUT_READY<=0;
 if(pending>0)begin pending<=pending-1;if(pending==1)begin DDRAM_DOUT<=memory[ra-29'h07c00000];DDRAM_DOUT_READY<=1;end end
 if(DDRAM_WE&&!DDRAM_BUSY)begin
  for(integer byteindex=0;byteindex<8;byteindex=byteindex+1)if(DDRAM_BE[byteindex])memory[DDRAM_ADDR-29'h07c00000][byteindex*8+:8]<=DDRAM_DIN[byteindex*8+:8];writes<=writes+1;
 end
 if(DDRAM_RD&&!DDRAM_BUSY)begin if(pending!=0)$fatal(1,"overlapping DDR read");pending<=3;ra<=DDRAM_ADDR;reads<=reads+1;end
 if(z80_set)begin if(z80_dir!==saved_cpu)$fatal(1,"CPU roundtrip");loads<=loads+1;end
 if(vdp_regs_set&&vdp_regs_in!==saved_vdp)$fatal(1,"VDP roundtrip");
 if(psg_set&&psg_in!==saved_psg)$fatal(1,"PSG roundtrip");
end
task tick;begin @(negedge clk);#2;end endtask
task operation(input bit saving);begin
 force a.op_cooldown=0;
 if(saving)ss_save=1;else ss_load=1;tick;ss_save=0;ss_load=0;
 wait(ss_freeze);wait(!ss_freeze);repeat(12)tick;
 release a.op_cooldown;operations=operations+1;$display("Completed operation%0d saving%b cycles%0d",operations,saving,cycles);
end endtask
initial begin
 oracle=$fopen("savestate_oracle.trace",REF?"w":"r");if(!oracle)$fatal(1,"oracle open failed");
 reset_n=0;repeat(6)tick;reset_n=1;vblank=1;x=0;z80_m1_n=0;z80_mreq_n=0;audio_quiescent=1;ss_game_id=32'h12345678;
 repeat(100000)tick; // Program and sound before the first freeze.
 for(integer testcase=0;testcase<8;testcase=testcase+7)begin
  systeme=testcase%2;ss_bios_mode=(testcase/2)%2;ss_slot=testcase%4;stalls=testcase>=4;
  mapper_out=systeme?64'h60:64'h1000000000000;
  saved_cpu={102'h1923,128'h0123456789abcdef0011223344556677}^testcase;
  saved_vdp=128'hfedcba98765432100123456789abcdef^testcase;saved_psg=56'h0123456789abcd^testcase;
  z80_reg=saved_cpu;vdp_regs=saved_vdp;psg_out=saved_psg;vdp2_regs=~saved_vdp;psg2_out=~saved_psg;
  cram_out={384{1'b1}};cram2_out={384{1'b0}};video_state_out=22'h12345;
  operation(1);z80_reg=~saved_cpu;vdp_regs=~saved_vdp;psg_out=~saved_psg;operation(0);
  if(loads!=(testcase==0?1:2))$fatal(1,"load was rejected testcase%0d loads%0d",testcase,loads);
 end
 if(nonzero_audio==0)$fatal(1,"vacuous FM output");
 if(loads!=2||operations!=4||busy_cycles==0||writes<1000||reads<1000)$fatal(1,"coverage incomplete");
 $display("PASS savestate/FM mapped RegisterMemory regression cycles=%0d audio_checks=%0d paired_controllers=0 operations=%0d restored=%0d DDRwrites=%0d DDRreads=%0d busy=%0d SMS/SystemE BIOS/cart slots0..3",cycles,audio_checks,operations,loads,writes,reads,busy_cycles);
 $display("Nonzero audio checks=%0d REF=%0d",nonzero_audio,REF);$fclose(oracle);$finish;
end
initial begin #200000000;$fatal(1,"savestate timeout state=%0d freeze=%b operations=%0d pending=%0d",a.state,ss_freeze,operations,pending);end
endmodule
