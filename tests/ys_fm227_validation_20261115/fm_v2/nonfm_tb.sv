`timescale 1ns/1ps
module nonfm_tb;
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
reg DDRAM_BUSY='0;
reg [63:0] DDRAM_DOUT_a=0,DDRAM_DOUT_b=0;reg DDRAM_DOUT_READY_a=0,DDRAM_DOUT_READY_b=0;
wire ss_freeze_a,ss_freeze_b;
wire [229:0] z80_dir_a,z80_dir_b;
wire z80_set_a,z80_set_b;
wire [127:0] vdp_regs_in_a,vdp_regs_in_b;
wire vdp_regs_set_a,vdp_regs_set_b;
wire [4:0] cram_A_a,cram_A_b;
wire [11:0] cram_D_a,cram_D_b;
wire cram_wr_a,cram_wr_b;
wire vram_en_a,vram_en_b;
wire [14:0] vram_A_a,vram_A_b;
wire vram_WE_a,vram_WE_b;
wire [14:0] vram_WA_a,vram_WA_b;
wire [7:0] vram_WD_a,vram_WD_b;
wire [55:0] psg_in_a,psg_in_b;
wire psg_set_a,psg_set_b;
wire [95:0] psg_ext_in_a,psg_ext_in_b;
wire [95:0] psg2_ext_in_a,psg2_ext_in_b;
wire [3:0] psg_div_in_a,psg_div_in_b;
wire [10:0] audio_control_in_a,audio_control_in_b;
wire audio_phase_in_a,audio_phase_in_b;
wire audio_ext_set_a,audio_ext_set_b;
wire audio_phase_set_a,audio_phase_set_b;
wire [63:0] mapper_in_a,mapper_in_b;
wire mapper_set_a,mapper_set_b;
wire [95:0] evolution_in_a,evolution_in_b;
wire evolution_set_a,evolution_set_b;
wire [63:0] eeprom_in_a,eeprom_in_b;
wire eeprom_set_a,eeprom_set_b;
wire [13:0] wram_A_a,wram_A_b;
wire wram_WE_a,wram_WE_b;
wire [13:0] wram_WA_a,wram_WA_b;
wire [7:0] wram_WD_a,wram_WD_b;
wire [14:0] nvram_A_a,nvram_A_b;
wire nvram_WE_a,nvram_WE_b;
wire [14:0] nvram_WA_a,nvram_WA_b;
wire [7:0] nvram_WD_a,nvram_WD_b;
wire [127:0] vdp2_regs_in_a,vdp2_regs_in_b;
wire vdp2_regs_set_a,vdp2_regs_set_b;
wire [4:0] cram2_A_a,cram2_A_b;
wire [11:0] cram2_D_a,cram2_D_b;
wire cram2_wr_a,cram2_wr_b;
wire vram2_en_a,vram2_en_b;
wire [14:0] vram2_A_a,vram2_A_b;
wire vram2_WE_a,vram2_WE_b;
wire [14:0] vram2_WA_a,vram2_WA_b;
wire [7:0] vram2_WD_a,vram2_WD_b;
wire [55:0] psg2_in_a,psg2_in_b;
wire psg2_set_a,psg2_set_b;
wire [31:0] io_in_a,io_in_b;
wire io_set_a,io_set_b;
wire [21:0] video_state_in_a,video_state_in_b;
wire video_state_set_a,video_state_set_b;
wire [28:0] DDRAM_ADDR_a,DDRAM_ADDR_b;
wire [63:0] DDRAM_DIN_a,DDRAM_DIN_b;
wire [7:0] DDRAM_BE_a,DDRAM_BE_b;
wire DDRAM_WE_a,DDRAM_WE_b;
wire DDRAM_RD_a,DDRAM_RD_b;
wire [7:0] DDRAM_BURSTCNT_a,DDRAM_BURSTCNT_b;
wire [7:0] fm_addr;wire fm_read,fm_write,fm_init_run,fm_reset;wire [31:0] fm_wdata;
reg [31:0] fm_rdata=0;
always @(posedge clk)fm_rdata<=fm_read&&fm_addr==78?32'h00000047:0;
master_savestates a(.clk(clk),.reset_n(reset_n),.ss_save(ss_save),.ss_load(ss_load),.ss_slot(ss_slot),.ss_bios_mode(ss_bios_mode),.ss_game_id(ss_game_id),.ss_freeze(ss_freeze_a),.vblank(vblank),.x(x),.z80_reg(z80_reg),.z80_dir(z80_dir_a),.z80_set(z80_set_a),.z80_m1_n(z80_m1_n),.z80_mreq_n(z80_mreq_n),.z80_iset(z80_iset),.cpu_ce(cpu_ce),.vdp_ce(vdp_ce),.pix_ce(pix_ce),.sp_ce(sp_ce),.vdp_regs(vdp_regs),.vdp_regs_in(vdp_regs_in_a),.vdp_regs_set(vdp_regs_set_a),.cram_out(cram_out),.cram_A(cram_A_a),.cram_D(cram_D_a),.cram_wr(cram_wr_a),.vram_en(vram_en_a),.vram_A(vram_A_a),.vram_D(vram_D),.vram_WE(vram_WE_a),.vram_WA(vram_WA_a),.vram_WD(vram_WD_a),.psg_out(psg_out),.psg_in(psg_in_a),.psg_set(psg_set_a),.psg_ext_out(psg_ext_out),.psg2_ext_out(psg2_ext_out),.psg_ext_in(psg_ext_in_a),.psg2_ext_in(psg2_ext_in_a),.psg_div_out(psg_div_out),.psg_div_in(psg_div_in_a),.audio_control_out(audio_control_out),.audio_control_in(audio_control_in_a),.audio_quiescent(audio_quiescent),.audio_phase_out(audio_phase_out),.audio_phase_in(audio_phase_in_a),.audio_ext_set(audio_ext_set_a),.audio_phase_set(audio_phase_set_a),.mapper_out(mapper_out),.mapper_in(mapper_in_a),.mapper_set(mapper_set_a),.evolution_out(evolution_out),.evolution_in(evolution_in_a),.evolution_set(evolution_set_a),.eeprom_out(eeprom_out),.eeprom_in(eeprom_in_a),.eeprom_set(eeprom_set_a),.wram_A(wram_A_a),.wram_D(wram_D),.wram_WE(wram_WE_a),.wram_WA(wram_WA_a),.wram_WD(wram_WD_a),.nvram_A(nvram_A_a),.nvram_D(nvram_D),.nvram_WE(nvram_WE_a),.nvram_WA(nvram_WA_a),.nvram_WD(nvram_WD_a),.systeme(systeme),.vdp2_regs(vdp2_regs),.vdp2_regs_in(vdp2_regs_in_a),.vdp2_regs_set(vdp2_regs_set_a),.cram2_out(cram2_out),.cram2_A(cram2_A_a),.cram2_D(cram2_D_a),.cram2_wr(cram2_wr_a),.vram2_en(vram2_en_a),.vram2_A(vram2_A_a),.vram2_D(vram2_D),.vram2_WE(vram2_WE_a),.vram2_WA(vram2_WA_a),.vram2_WD(vram2_WD_a),.psg2_out(psg2_out),.psg2_in(psg2_in_a),.psg2_set(psg2_set_a),.io_out(io_out),.io_in(io_in_a),.io_set(io_set_a),.video_state_out(video_state_out),.video_state_in(video_state_in_a),.video_state_set(video_state_set_a),.DDRAM_ADDR(DDRAM_ADDR_a),.DDRAM_DIN(DDRAM_DIN_a),.DDRAM_BE(DDRAM_BE_a),.DDRAM_WE(DDRAM_WE_a),.DDRAM_DOUT(DDRAM_DOUT_a),.DDRAM_DOUT_READY(DDRAM_DOUT_READY_a),.DDRAM_RD(DDRAM_RD_a),.DDRAM_BURSTCNT(DDRAM_BURSTCNT_a),.DDRAM_BUSY(DDRAM_BUSY));
savestates b(.sc3000_mode(1'b1),.eeprom_present(1'b0),.clk(clk),.reset_n(reset_n),.ss_save(ss_save),.ss_load(ss_load),.ss_slot(ss_slot),.ss_bios_mode(ss_bios_mode),.ss_game_id(ss_game_id),.ss_freeze(ss_freeze_b),.vblank(vblank),.x(x),.z80_reg(z80_reg),.z80_dir(z80_dir_b),.z80_set(z80_set_b),.z80_m1_n(z80_m1_n),.z80_mreq_n(z80_mreq_n),.z80_iset(z80_iset),.cpu_ce(cpu_ce),.vdp_ce(vdp_ce),.pix_ce(pix_ce),.sp_ce(sp_ce),.vdp_regs(vdp_regs),.vdp_regs_in(vdp_regs_in_b),.vdp_regs_set(vdp_regs_set_b),.cram_out(cram_out),.cram_A(cram_A_b),.cram_D(cram_D_b),.cram_wr(cram_wr_b),.vram_en(vram_en_b),.vram_A(vram_A_b),.vram_D(vram_D),.vram_WE(vram_WE_b),.vram_WA(vram_WA_b),.vram_WD(vram_WD_b),.psg_out(psg_out),.psg_in(psg_in_b),.psg_set(psg_set_b),.psg_ext_out(psg_ext_out),.psg2_ext_out(psg2_ext_out),.psg_ext_in(psg_ext_in_b),.psg2_ext_in(psg2_ext_in_b),.psg_div_out(psg_div_out),.psg_div_in(psg_div_in_b),.audio_control_out(audio_control_out),.audio_control_in(audio_control_in_b),.audio_quiescent(audio_quiescent),.audio_phase_out(audio_phase_out),.audio_phase_in(audio_phase_in_b),.audio_ext_set(audio_ext_set_b),.audio_phase_set(audio_phase_set_b),.mapper_out(mapper_out),.mapper_in(mapper_in_b),.mapper_set(mapper_set_b),.evolution_out(evolution_out),.evolution_in(evolution_in_b),.evolution_set(evolution_set_b),.eeprom_out(eeprom_out),.eeprom_in(eeprom_in_b),.eeprom_set(eeprom_set_b),.wram_A(wram_A_b),.wram_D(wram_D),.wram_WE(wram_WE_b),.wram_WA(wram_WA_b),.wram_WD(wram_WD_b),.nvram_A(nvram_A_b),.nvram_D(nvram_D),.nvram_WE(nvram_WE_b),.nvram_WA(nvram_WA_b),.nvram_WD(nvram_WD_b),.systeme(systeme),.vdp2_regs(vdp2_regs),.vdp2_regs_in(vdp2_regs_in_b),.vdp2_regs_set(vdp2_regs_set_b),.cram2_out(cram2_out),.cram2_A(cram2_A_b),.cram2_D(cram2_D_b),.cram2_wr(cram2_wr_b),.vram2_en(vram2_en_b),.vram2_A(vram2_A_b),.vram2_D(vram2_D),.vram2_WE(vram2_WE_b),.vram2_WA(vram2_WA_b),.vram2_WD(vram2_WD_b),.psg2_out(psg2_out),.psg2_in(psg2_in_b),.psg2_set(psg2_set_b),.io_out(io_out),.io_in(io_in_b),.io_set(io_set_b),.video_state_out(video_state_out),.video_state_in(video_state_in_b),.video_state_set(video_state_set_b),.DDRAM_ADDR(DDRAM_ADDR_b),.DDRAM_DIN(DDRAM_DIN_b),.DDRAM_BE(DDRAM_BE_b),.DDRAM_WE(DDRAM_WE_b),.DDRAM_DOUT(DDRAM_DOUT_b),.DDRAM_DOUT_READY(DDRAM_DOUT_READY_b),.DDRAM_RD(DDRAM_RD_b),.DDRAM_BURSTCNT(DDRAM_BURSTCNT_b),.DDRAM_BUSY(DDRAM_BUSY),
 .fm_state_addr(fm_addr),.fm_state_read(fm_read),.fm_state_write(fm_write),.fm_state_wdata(fm_wdata),.fm_state_rdata(fm_rdata),.fm_initialized(1'b1),.fm_initialization_run(fm_init_run),.fm_legacy_reset(fm_reset));
always #5 clk=~clk;
integer cycles=0;reg stalls=0;
reg [63:0] mem_a[0:98303],mem_b[0:98303];integer pa=0,pb=0;reg [28:0] ra,rb;
integer restored_a=0,restored_b=0;
always @(negedge clk)begin cycles++;cpu_ce=cycles%15==0;pix_ce=cycles%10==0;vdp_ce=cycles%5==0;sp_ce=cycles%2;DDRAM_BUSY=stalls&&(cycles%79<7);end
always @(posedge clk)begin
 DDRAM_DOUT_READY_a<=0;DDRAM_DOUT_READY_b<=0;
 if(pa>0)begin pa<=pa-1;if(pa==1)begin DDRAM_DOUT_a<=mem_a[ra-29'h07c00000];DDRAM_DOUT_READY_a<=1;end end
 if(pb>0)begin pb<=pb-1;if(pb==1)begin DDRAM_DOUT_b<=mem_b[rb-29'h07c00000];DDRAM_DOUT_READY_b<=1;end end
 if(DDRAM_RD_a&&!DDRAM_BUSY)begin if(pa!=0)$fatal(1,"master overlapping reads");pa<=3+cycles%5;ra<=DDRAM_ADDR_a;end
 if(DDRAM_RD_b&&!DDRAM_BUSY)begin if(pb!=0)$fatal(1,"candidate overlapping reads");pb<=3+cycles%5;rb<=DDRAM_ADDR_b;end
 if(DDRAM_WE_a&&!DDRAM_BUSY)for(integer i=0;i<8;i++)if(DDRAM_BE_a[i])mem_a[DDRAM_ADDR_a-29'h07c00000][i*8+:8]<=DDRAM_DIN_a[i*8+:8];
 if(DDRAM_WE_b&&!DDRAM_BUSY)for(integer i=0;i<8;i++)if(DDRAM_BE_b[i])mem_b[DDRAM_ADDR_b-29'h07c00000][i*8+:8]<=DDRAM_DIN_b[i*8+:8];
 if(z80_set_a)begin restored_a++;if(z80_dir_a!==z80_reg)$fatal(1,"master CPU restore");end
 if(z80_set_b)begin restored_b++;if(z80_dir_b!==z80_reg)$fatal(1,"candidate CPU restore");end
end
task tick;begin @(negedge clk);#2;end endtask
task operation(input bit saving);begin
 force a.op_cooldown=0;force b.op_cooldown=0;
 ss_save=saving;ss_load=!saving;tick;ss_save=0;ss_load=0;
 wait(ss_freeze_a&&ss_freeze_b);wait(!ss_freeze_a&&!ss_freeze_b);repeat(12)tick;
 release a.op_cooldown;release b.op_cooldown;
end endtask
initial begin
 for(integer i=0;i<98304;i++)begin mem_a[i]=0;mem_b[i]=0;end
 repeat(6)tick;reset_n=1;vblank=1;audio_quiescent=1;ss_game_id=32'h12345678;
 z80_reg=230'h123456789abcdef;vdp_regs=128'h987654321;psg_out=56'h123456;psg2_out=56'h654321;psg_ext_out=96'h789abcdef;psg2_ext_out=96'h987654321;
 io_out=32'h12345678;video_state_out=22'h12345;cram_out={384{1'b1}};cram2_out={384{1'b1}};
 for(integer c=0;c<8;c++)begin
  systeme=c%2;ss_bios_mode=(c/2)%2;ss_slot=c%4;stalls=c>=4;mapper_out=systeme?64'h60:64'h1000000000000;
  operation(1);
  for(integer i=0;i<98304;i++)begin
   if(i%12288=='h1a)begin if(mem_a[i][21:0]!==mem_b[i][21:0])$fatal(1,"video payload regression");end
   else if(i%12288<'h2997 || i%12288>'h29c9)if(mem_a[i]!==mem_b[i])$fatal(1,"non-FM DDR payload regression case=%0d word=%h",c,i);
  end
  operation(0);
  if(z80_dir_a!==z80_dir_b)$fatal(1,"non-FM output regression z80_dir");
  if(vdp_regs_in_a!==vdp_regs_in_b)$fatal(1,"non-FM output regression vdp_regs_in");
  if(psg_in_a!==psg_in_b)$fatal(1,"non-FM output regression psg_in");
  if(psg_ext_in_a!==psg_ext_in_b)$fatal(1,"non-FM output regression psg_ext_in");
  if(psg2_ext_in_a!==psg2_ext_in_b)$fatal(1,"non-FM output regression psg2_ext_in");
  if(psg_div_in_a!==psg_div_in_b)$fatal(1,"non-FM output regression psg_div_in");
  if(audio_control_in_a!==audio_control_in_b)$fatal(1,"non-FM output regression audio_control_in");
  if(audio_phase_in_a!==audio_phase_in_b)$fatal(1,"non-FM output regression audio_phase_in");
  if(mapper_in_a!==mapper_in_b)$fatal(1,"non-FM output regression mapper_in");
  if(evolution_in_a!==evolution_in_b)$fatal(1,"non-FM output regression evolution_in");
  if(eeprom_in_a!==eeprom_in_b)$fatal(1,"non-FM output regression eeprom_in");
  if(vdp2_regs_in_a!==vdp2_regs_in_b)$fatal(1,"non-FM output regression vdp2_regs_in");
  if(psg2_in_a!==psg2_in_b)$fatal(1,"non-FM output regression psg2_in");
  if(io_in_a!==io_in_b)$fatal(1,"non-FM output regression io_in");
  if(video_state_in_a!==video_state_in_b)$fatal(1,"non-FM output regression video_state_in");
  $display("PASS nonFM case=%0d SystemE=%b BIOS=%b slot=%0d stalls=%b",c,systeme,ss_bios_mode,ss_slot,stalls);
 end
 if(restored_a!=8||restored_b!=8)$fatal(1,"incomplete nonFM restores");
 $display("PASS nonFM ALL restores=8 per controller payloads all slots cycles=%0d",cycles);$finish;
end
initial begin #200000000;$fatal(1,"nonFM TIMEOUT states=%0d,%0d",a.state,b.state);end
endmodule
