`timescale 1ns/1ps
module fm_tb;wire[15:0]al,ar;wire[15:0]last_sample_in;wire last_sample_valid;wire[135:0]refvdp_regs,refvdp2_regs;parameter REPLAYS=1,STEREO=0,PHASE=70,RESET_SKEW=0,FM_ONLY=1,CHARACTERIZE=0,PROGRAM=0,RANDOMSEED=1,FM_SUPPRESS=0,CONVERGE=0,FMCASE=0,HISTORY=0,FASTVIDEO=1,TARGET=0,REF=0,SEED=0,N=48000,CASE=0,KEEP=0,FULL=0,STALL=0,OFFSET=0,DELAY=6;
reg clk = '0;
reg reset_n = '0;
reg ss_save = '0;
reg ss_load = '0;
reg [1:0] ss_slot = '0;
reg ss_bios_mode = '0;
reg [31:0] ss_game_id = '0;
wire[7:0]fm_state_addr;wire fm_state_read,fm_state_write,fm_initialized,fm_legacy_reset,fm_initialization_run;wire[31:0]fm_state_wdata,fm_state_rdata,fm_opll_rdata;reg[31:0]fm_wrapper_rdata=0;reg audit_busy=0,audit_read=0;reg[7:0]audit_addr=0;wire[7:0]observed_addr=audit_busy?audit_addr:fm_state_addr;wire observed_read=audit_busy?audit_read:fm_state_read;
wire ss_freeze;wire cpu_prepare,replay,replay_t2,phase_set,actual_tick;wire[1:0]phase_in;reg phase_ready=0;reg[4:0]clkd=0;wire ss_capture_progress;
wire vblank;
wire [8:0] x;
wire [229:0] z80_reg;
wire [229:0] z80_dir;
wire z80_set;
wire z80_m1_n;
wire z80_mreq_n;
wire [1:0] z80_iset;
wire cpu_ce;
wire vdp_ce;
wire pix_ce;
wire sp_ce;
wire [135:0] vdp_regs;
wire [135:0] vdp_regs_in;
wire vdp_regs_set;
reg [383:0] cram_out = '0;
wire [4:0] cram_A;
wire [11:0] cram_D;
wire cram_wr;
wire vram_en;
wire [14:0] vram_A;
reg [7:0] vram_D = '0;
wire vram_WE;
wire [14:0] vram_WA;
wire [7:0] vram_WD;
wire [55:0] psg_out;
wire [55:0] psg_in;
wire psg_set;
wire [95:0] psg_ext_out;
wire [95:0] psg2_ext_out;
wire [95:0] psg_ext_in;
wire [95:0] psg2_ext_in;
wire [3:0] psg_div_out;
wire [3:0] psg_div_in;
reg [10:0] audio_control_out = '0;
wire [10:0] audio_control_in;
wire audio_quiescent;
wire audio_phase_out;
wire audio_phase_in;
wire audio_ext_set;
wire audio_phase_set;
reg [63:0] mapper_out = '0;
wire [63:0] mapper_in;
wire mapper_set;
reg [159:0] evolution_out = '0;
wire [95:0] evolution_in;
wire evolution_set;
reg storage_busy = '0;
wire ss_busy;
reg eeprom_present = '0;
reg [127:0] eeprom_ext_out = '0;
wire [127:0] eeprom_ext_in;
wire eeprom_full;
wire nvram_refill;
reg [45:0] gun_out = '0;
wire [45:0] gun_in;
wire gun_set;
wire gun_valid;
reg [31:0] paddle_out = '0;
wire [31:0] paddle_in;
wire paddle_set;
wire paddle_valid;
reg [18:0] tap_out = '0;
wire [18:0] tap_in;
wire tap_set;
wire tap_valid;
reg [1:0] sc_ram_size = '0;
wire sc_ram_restored;
reg [63:0] eeprom_out = '0;
wire [63:0] eeprom_in;
wire eeprom_set;
wire [13:0] wram_A;
reg [7:0] wram_D = '0;
wire wram_WE;
wire [13:0] wram_WA;
wire [7:0] wram_WD;
wire [14:0] nvram_A;
reg [7:0] nvram_D = '0;
wire nvram_WE;
wire [14:0] nvram_WA;
wire [7:0] nvram_WD;
reg systeme = '0;
wire [135:0] vdp2_regs;
wire [135:0] vdp2_regs_in;
wire vdp2_regs_set;
reg [383:0] cram2_out = '0;
wire [4:0] cram2_A;
wire [11:0] cram2_D;
wire cram2_wr;
wire vram2_en;
wire [14:0] vram2_A;
reg [7:0] vram2_D = '0;
wire vram2_WE;
wire [14:0] vram2_WA;
wire [7:0] vram2_WD;
wire [55:0] psg2_out;
wire [55:0] psg2_in;
wire psg2_set;
reg [45:0] md_out = '0;
wire [45:0] md_in;
wire md_set;
wire md_valid;
reg [127:0] gg_out = '0;
wire [127:0] gg_in;
wire gg_set;
reg [31:0] io_out = '0;
wire [31:0] io_in;
wire io_set;
wire [21:0] video_state_out;
wire [21:0] video_state_in;
wire video_state_set;
wire [28:0] DDRAM_ADDR;
wire [63:0] DDRAM_DIN;
wire [7:0] DDRAM_BE;
wire DDRAM_WE;
reg [63:0] DDRAM_DOUT = '0;
reg DDRAM_DOUT_READY = '0;
wire DDRAM_RD;
wire [7:0] DDRAM_BURSTCNT;
reg DDRAM_BUSY = '0;
wire[2:0]restart_out;
wire audio_pending_tick;
savestates dut (.audio_last_out(audio_phase_out ? al : ar),.audio_last_in(last_sample_in),.audio_last_valid(last_sample_valid),
 .fm_state_addr(fm_state_addr),.fm_state_read(fm_state_read),.fm_state_write(fm_state_write),
 .fm_state_wdata(fm_state_wdata),.fm_state_rdata(fm_state_rdata),.fm_initialized(fm_initialized),
 .fm_legacy_reset(fm_legacy_reset),.fm_initialization_run(fm_initialization_run),.audio_pending_tick(audio_pending_tick),.bg_out(139'd0),.bg2_out(139'd0),.bg_in(),.bg2_in(),.bg_valid(),.ss_cpu_prepare(cpu_prepare),.z80_replay(replay),.z80_tick_active(actual_tick),.z80_replay_t2(replay_t2),
 .clock_phase(clkd==25?2'd3:clkd==20?2'd2:clkd==10?2'd1:2'd0),.clock_phase_in(phase_in),.clock_phase_set(phase_set),.clock_phase_ready(phase_ready),
 .sprite_out(4778'd0),.sprite2_out(4778'd0),.sprite_in(),.sprite2_in(),.sprite_valid(),.z80_restart(restart_out),.z80_nmi(3'b001),.mapper_history_out(18'h0ffff),.mapper_history_in(),.clk(clk),.reset_n(reset_n),.ss_save(ss_save),.ss_load(ss_load),.ss_slot(ss_slot),.ss_bios_mode(ss_bios_mode),.ss_game_id(ss_game_id),.ss_freeze(ss_freeze),.ss_capture_progress(ss_capture_progress),.vblank(vblank),.x(x),.z80_reg(z80_reg),.z80_dir(z80_dir),.z80_set(z80_set),.z80_m1_n(z80_m1_n),.z80_mreq_n(z80_mreq_n),.z80_iset(z80_iset),.cpu_ce(cpu_ce),.vdp_ce(vdp_ce),.pix_ce(pix_ce),.sp_ce(sp_ce),.vdp_regs(vdp_regs),.vdp_regs_in(vdp_regs_in),.vdp_regs_set(vdp_regs_set),.cram_out(cram_out),.cram_A(cram_A),.cram_D(cram_D),.cram_wr(cram_wr),.vram_en(vram_en),.vram_A(vram_A),.vram_D(vram_D),.vram_WE(vram_WE),.vram_WA(vram_WA),.vram_WD(vram_WD),.psg_out(psg_out),.psg_in(psg_in),.psg_set(psg_set),.psg_ext_out(psg_ext_out),.psg2_ext_out(psg2_ext_out),.psg_ext_in(psg_ext_in),.psg2_ext_in(psg2_ext_in),.psg_div_out(psg_div_out),.psg_div_in(psg_div_in),.audio_control_out(audio_control_out),.audio_control_in(audio_control_in),.audio_quiescent(audio_quiescent),.audio_phase_out(audio_phase_out),.audio_phase_in(audio_phase_in),.audio_ext_set(audio_ext_set),.audio_phase_set(audio_phase_set),.mapper_out(mapper_out),.mapper_in(mapper_in),.mapper_set(mapper_set),.evolution_out(evolution_out),.evolution_in(evolution_in),.evolution_set(evolution_set),.storage_busy(storage_busy),.ss_busy(ss_busy),.eeprom_present(eeprom_present),.eeprom_ext_out(eeprom_ext_out),.eeprom_ext_in(eeprom_ext_in),.eeprom_full(eeprom_full),.nvram_refill(nvram_refill),.gun_out(gun_out),.gun_in(gun_in),.gun_set(gun_set),.gun_valid(gun_valid),.paddle_out(paddle_out),.paddle_in(paddle_in),.paddle_set(paddle_set),.paddle_valid(paddle_valid),.tap_out(tap_out),.tap_in(tap_in),.tap_set(tap_set),.tap_valid(tap_valid),.sc_ram_size(sc_ram_size),.sc_ram_restored(sc_ram_restored),.eeprom_out(eeprom_out),.eeprom_in(eeprom_in),.eeprom_set(eeprom_set),.wram_A(wram_A),.wram_D(wram_D),.wram_WE(wram_WE),.wram_WA(wram_WA),.wram_WD(wram_WD),.nvram_A(nvram_A),.nvram_D(nvram_D),.nvram_WE(nvram_WE),.nvram_WA(nvram_WA),.nvram_WD(nvram_WD),.systeme(systeme),.vdp2_regs(vdp2_regs),.vdp2_regs_in(vdp2_regs_in),.vdp2_regs_set(vdp2_regs_set),.cram2_out(cram2_out),.cram2_A(cram2_A),.cram2_D(cram2_D),.cram2_wr(cram2_wr),.vram2_en(vram2_en),.vram2_A(vram2_A),.vram2_D(vram2_D),.vram2_WE(vram2_WE),.vram2_WA(vram2_WA),.vram2_WD(vram2_WD),.psg2_out(psg2_out),.psg2_in(psg2_in),.psg2_set(psg2_set),.md_out(md_out),.md_in(md_in),.md_set(md_set),.md_valid(md_valid),.gg_out(gg_out),.gg_in(gg_in),.gg_set(gg_set),.io_out(io_out),.io_in(io_in),.io_set(io_set),.video_state_out(video_state_out),.video_state_in(video_state_in),.video_state_set(video_state_set),.DDRAM_ADDR(DDRAM_ADDR),.DDRAM_DIN(DDRAM_DIN),.DDRAM_BE(DDRAM_BE),.DDRAM_WE(DDRAM_WE),.DDRAM_DOUT(DDRAM_DOUT),.DDRAM_DOUT_READY(DDRAM_DOUT_READY),.DDRAM_RD(DDRAM_RD),.DDRAM_BURSTCNT(DDRAM_BURSTCNT),.DDRAM_BUSY(DDRAM_BUSY));
always #5 clk=~clk;
reg [63:0] mem[0:12287]; integer cycle=0, pending=0; reg [28:0] readaddr;
integer writes=0,reads=0; reg restored=0; reg [135:0] seen1,seen2;
reg ce_cpu=0,ce_pix=0,ce_vdp=0,ce_sp=0;
wire random_normal_cpu=(RANDOMSEED%5!=0)&&(RANDOMSEED&1);wire guest_cpu_ce=random_normal_cpu?ce_cpu:ce_pix;
assign cpu_ce=guest_cpu_ce;assign vdp_ce=ce_vdp;assign pix_ce=ce_pix;assign sp_ce=ce_sp;
always@(negedge clk)begin cycle=cycle+1;phase_ready<=phase_set;
if(phase_set)begin case(phase_in)0:clkd<=0;1:clkd<=10;2:clkd<=20;3:clkd<=25;endcase
ce_cpu<=0;ce_pix<=0;ce_vdp<=0;ce_sp<=0;end else begin ce_cpu<=0;ce_pix<=0;ce_vdp<=0;ce_sp<=clkd[0];clkd<=clkd+1;
case(clkd)4:ce_vdp<=1;9:begin ce_cpu<=1;ce_pix<=1;ce_vdp<=1;end 14:ce_vdp<=1;19:begin ce_pix<=1;ce_vdp<=1;end 24:begin ce_cpu<=1;ce_vdp<=1;end 29:begin ce_pix<=1;ce_vdp<=1;clkd<=0;end endcase end end
always @(posedge clk) begin
 DDRAM_DOUT_READY<=0;
 if(pending>0)begin pending<=pending-1;if(pending==1)begin DDRAM_DOUT<=mem[readaddr-29'h07c00000];DDRAM_DOUT_READY<=1;end end
 if(DDRAM_WE&&!DDRAM_BUSY)begin
  for(integer b=0;b<8;b=b+1)if(DDRAM_BE[b])mem[DDRAM_ADDR-29'h07c00000][b*8+:8]<=DDRAM_DIN[b*8+:8];writes<=writes+1;
 end
 if(DDRAM_RD&&!DDRAM_BUSY)begin if(pending!=0)$fatal(1,"overlap read");pending<=3;readaddr<=DDRAM_ADDR;reads<=reads+1;end
 if(vdp_regs_set)begin seen1<=vdp_regs_in;restored<=1;end
 if(vdp2_regs_set)seen2<=vdp2_regs_in;
end
task tick;begin @(negedge clk);#1;end endtask
task operation(input bit saving);begin
 force dut.op_cooldown=0; // UI cooldown only; all transfer/restore FSM stages run normally
 if(saving)ss_save=1;else ss_load=1;tick;ss_save=0;ss_load=0;
 wait(ss_freeze);wait(!ss_freeze);repeat(10)tick;release dut.op_cooldown;
end endtask
reg joy=0,holdref=0;wire paused,pp,up,rpaused,rpp,rup;wire[8:0]y,rx,ry;wire vb,hb,rvb,rhb;wire[21:0]rvideo;
pause_fixture p(clk,reset_n,systeme,joy,vb,ss_freeze,KEEP!=0,paused,pp,up);
pause_fixture rp(clk,reset_n,systeme,joy,rvb,ss_freeze,1'b0,rpaused,rpp,rup);
assign vblank=vb;
generate if(FASTVIDEO)begin assign x=0;assign y=224;assign vb=1;assign hb=0;assign video_state_out=22'd0;assign rx=0;assign ry=224;assign rvb=1;assign rhb=0;assign rvideo=0;end else begin
video video1(.clk(clk),.ce_pix(ce_pix),.pal(1'b0),.border(1'b0),.ggres(1'b0),.mask_column(1'b0),.cut_mask(1'b0),.smode_M1(1'b0),.smode_M2(1'b0),.smode_M3(1'b0),.smode_M4(1'b1),.video_state_out(video_state_out),.video_state_in(video_state_in),.video_state_set(video_state_set),.x(x),.y(y),.vcounter_cpu(),.hsync(),.vsync(),.hblank(hb),.vblank(vb));
video videoref(.clk(clk),.ce_pix(ce_pix&&!holdref),.pal(1'b0),.border(1'b0),.ggres(1'b0),.mask_column(1'b0),.cut_mask(1'b0),.smode_M1(1'b0),.smode_M2(1'b0),.smode_M3(1'b0),.smode_M4(1'b1),.video_state_out(rvideo),.video_state_in(22'd0),.video_state_set(1'b0),.x(rx),.y(ry),.vcounter_cpu(),.hsync(),.vsync(),.hblank(rhb),.vblank(rvb));
end endgenerate
reg[4:0]rclkd=0;reg rce_cpu=0,rce_pix=0;
always@(negedge clk)begin rce_cpu<=0;rce_pix<=0;rclkd<=rclkd==29?0:rclkd+1;
if(rclkd==9||rclkd==24)rce_cpu<=1;if(rclkd==9||rclkd==19||rclkd==29)rce_pix<=1;end
wire[15:0]ca,ra;wire[7:0]co,ro;wire cm1,cmreq,rm1,rmreq,ciq,riq,crd,cwr,rrd,rwr;wire[229:0]rr;wire[1:0]riset;reg ref_request=0;
wire ref_progress=systeme&&ref_request&&!holdref&&!storage_busy&&rvb&&rx<256&&(rm1||rmreq||riset!=0);
always@(posedge clk)begin
 if(!reset_n)ref_request<=0;
 else if(ss_save||ss_load)ref_request<=1;
 else if(dut.state==37&&cpu_ce&&!cm1&&!cmreq&&z80_iset==0&&vb&&x<256&&!storage_busy)ref_request<=0;
end
reg[15:0]stall_rng=16'h1ace;
always@(negedge clk)begin #0.001;
 stall_rng={stall_rng[14:0],stall_rng[15]^stall_rng[13]^stall_rng[12]^stall_rng[10]};
 DDRAM_BUSY=(DDRAM_RD||DDRAM_WE)&&(STALL==1?cycle%31<13:STALL==2?stall_rng[3:0]<12:STALL==3?cycle%2048<2020:0);
end

// A increments once per loop. No forced CPU/bus or pause states.
reg[7:0]pause_rom[0:65535];initial $readmemh("rom.hex",pause_rom);function[7:0]rom(input[15:0]a);rom=pause_rom[a];endfunction
assign actual_tick=!paused||ss_capture_progress;
assign z80_m1_n=cm1;assign z80_mreq_n=cmreq;
T80s #(.T2Write(0)) cpu(.RESET_n(reset_n),.CLK(clk),.CEN((guest_cpu_ce&&!ss_freeze&&(!paused||ss_capture_progress))||(ce_cpu&&cpu_prepare&&replay)),.WAIT_n(1'b1),.INT_n(1'b1),.NMI_n(1'b1),.BUSRQ_n(1'b1),.M1_n(cm1),.MREQ_n(cmreq),.IORQ_n(ciq),.RD_n(crd),.WR_n(cwr),.RFSH_n(),.HALT_n(),.BUSAK_n(),.OUT0(1'b0),.A(ca),.DI(rom(ca)),.DO(co),.REG(z80_reg),.NMIEnable(1'b1),.NMIDIR(dut.z80_nmi_dir),.NMIValid(dut.z80_nmi_valid),.NMIHold(dut.z80_nmi_hold),.RestoreHold(ss_freeze),.ReplayT2(replay_t2),.NMIReplay(replay),.RestartContext(restart_out),.RestartDIR(dut.z80_restart_dir),.RestartValid(dut.z80_restart_valid),.DIRSet(z80_set),.DIR(z80_dir),.ISet_out(z80_iset));
T80s #(.T2Write(0)) rcpu(.RESET_n(reset_n),.CLK(clk),.CEN(((random_normal_cpu?rce_cpu:rce_pix)&&!holdref&&(!rpaused||ref_progress))),.WAIT_n(1'b1),.INT_n(1'b1),.NMI_n(1'b1),.BUSRQ_n(1'b1),.M1_n(rm1),.MREQ_n(rmreq),.IORQ_n(riq),.RD_n(rrd),.WR_n(rwr),.RFSH_n(),.HALT_n(),.BUSAK_n(),.OUT0(1'b0),.A(ra),.DI(rom(ra)),.DO(ro),.REG(rr),.DIRSet(1'b0),.DIR(230'd0),.ISet_out(riset));
generate if(FULL)begin:fullvdps
vdp vdp1(.clk_sys(clk),.ce_vdp((ce_vdp&&!ss_freeze)),.ce_pix((ce_pix&&!ss_freeze)),.ce_sp((ce_sp&&!ss_freeze)),.gg(1'b0),.ggres(1'b0),.se_bank(1'b0),.sp64(1'b0),.HL(1'b0),.mask_line_irq(1'b0),.capture_cpu_edges(1'b0),.legacy_ext_nt(1'b0),.RD_n(1'b1),.WR_n(1'b1),.IRQ_n(),.WR_direct(1'b0),.A_direct(6'b0),.A(8'h00),.D_in(8'b0),.D_out(),.x(x),.y(y),.vcounter_cpu(8'b0),.color(),.palettemode(1'b0),.y1(),.mask_column(),.black_column(1'b0),.smode_M1(),.smode_M2(),.smode_M3(),.smode_M4(),.ysj_quirk(1'b0),.reset_n(reset_n),.ss_regs_out(vdp_regs),.ss_regs_in(vdp_regs_in),.ss_regs_set(vdp_regs_set),.ss_cram_out(),.ss_cram_wr(1'b0),.ss_cram_A(5'b0),.ss_cram_D(12'b0),.ss_vram_en(1'b0),.ss_vram_A(15'b0),.ss_vram_D(),.ss_vram_WE(1'b0),.ss_vram_WA(15'b0),.ss_vram_WD(8'b0));
vdp refvdp1(.clk_sys(clk),.ce_vdp((ce_vdp&&!holdref)),.ce_pix((ce_pix&&!holdref)),.ce_sp((ce_sp&&!holdref)),.gg(1'b0),.ggres(1'b0),.se_bank(1'b0),.sp64(1'b0),.HL(1'b0),.mask_line_irq(1'b0),.capture_cpu_edges(1'b0),.legacy_ext_nt(1'b0),.RD_n(1'b1),.WR_n(1'b1),.IRQ_n(),.WR_direct(1'b0),.A_direct(6'b0),.A(8'h00),.D_in(8'b0),.D_out(),.x(rx),.y(ry),.vcounter_cpu(8'b0),.color(),.palettemode(1'b0),.y1(),.mask_column(),.black_column(1'b0),.smode_M1(),.smode_M2(),.smode_M3(),.smode_M4(),.ysj_quirk(1'b0),.reset_n(reset_n),.ss_regs_out(refvdp_regs),.ss_regs_in(136'd0),.ss_regs_set(1'b0),.ss_cram_out(),.ss_cram_wr(1'b0),.ss_cram_A(5'b0),.ss_cram_D(12'b0),.ss_vram_en(1'b0),.ss_vram_A(15'b0),.ss_vram_D(),.ss_vram_WE(1'b0),.ss_vram_WA(15'b0),.ss_vram_WD(8'b0));
vdp vdp2(.clk_sys(clk),.ce_vdp((ce_vdp&&!ss_freeze)),.ce_pix((ce_pix&&!ss_freeze)),.ce_sp((ce_sp&&!ss_freeze)),.gg(1'b0),.ggres(1'b0),.se_bank(1'b1),.sp64(1'b0),.HL(1'b0),.mask_line_irq(1'b0),.capture_cpu_edges(1'b0),.legacy_ext_nt(1'b0),.RD_n(1'b1),.WR_n(1'b1),.IRQ_n(),.WR_direct(1'b0),.A_direct(6'b0),.A(8'h00),.D_in(8'b0),.D_out(),.x(x),.y(y),.vcounter_cpu(8'b0),.color(),.palettemode(1'b0),.y1(),.mask_column(),.black_column(1'b0),.smode_M1(),.smode_M2(),.smode_M3(),.smode_M4(),.ysj_quirk(1'b0),.reset_n(reset_n),.ss_regs_out(vdp2_regs),.ss_regs_in(vdp2_regs_in),.ss_regs_set(vdp2_regs_set),.ss_cram_out(),.ss_cram_wr(1'b0),.ss_cram_A(5'b0),.ss_cram_D(12'b0),.ss_vram_en(1'b0),.ss_vram_A(15'b0),.ss_vram_D(),.ss_vram_WE(1'b0),.ss_vram_WA(15'b0),.ss_vram_WD(8'b0));
vdp refvdp2(.clk_sys(clk),.ce_vdp((ce_vdp&&!holdref)),.ce_pix((ce_pix&&!holdref)),.ce_sp((ce_sp&&!holdref)),.gg(1'b0),.ggres(1'b0),.se_bank(1'b1),.sp64(1'b0),.HL(1'b0),.mask_line_irq(1'b0),.capture_cpu_edges(1'b0),.legacy_ext_nt(1'b0),.RD_n(1'b1),.WR_n(1'b1),.IRQ_n(),.WR_direct(1'b0),.A_direct(6'b0),.A(8'h00),.D_in(8'b0),.D_out(),.x(rx),.y(ry),.vcounter_cpu(8'b0),.color(),.palettemode(1'b0),.y1(),.mask_column(),.black_column(1'b0),.smode_M1(),.smode_M2(),.smode_M3(),.smode_M4(),.ysj_quirk(1'b0),.reset_n(reset_n),.ss_regs_out(refvdp2_regs),.ss_regs_in(136'd0),.ss_regs_set(1'b0),.ss_cram_out(),.ss_cram_wr(1'b0),.ss_cram_A(5'b0),.ss_cram_D(12'b0),.ss_vram_en(1'b0),.ss_vram_A(15'b0),.ss_vram_D(),.ss_vram_WE(1'b0),.ss_vram_WA(15'b0),.ss_vram_WD(8'b0));
end else begin:lightvdps assign vdp_regs=0;assign vdp2_regs=0;end endgenerate
reg qmode=0;wire signed[10:0]a1r,a2r,rar;wire pq1,pq2;wire[3:0]div2;wire signed[10:0]audio1,audio2;reg pwr=1;reg[7:0]pd=0;
assign audio_quiescent=pq1&&pq2;
jt89 psg1(.ss_pending_tick(audio_pending_tick),.clk(clk),.clk_en(ce_cpu&&!ss_freeze&&(!paused||ss_capture_progress)),.rst(!reset_n),.wr_n(pwr),.din(pd),.mux(STEREO?8'hf0:8'hff),.soundL(audio1),.soundR(a1r),.ready(),.ss_out(psg_out),.ss_set(psg_set),.ss_in(psg_in),.ss_ext_out(psg_ext_out),.ss_ext_in(psg_ext_in),.ss_ext_set(audio_ext_set),.ss_div_out(psg_div_out),.ss_div_in(psg_div_in),.ss_quiescent(pq1));
jt89 psg2(.ss_pending_tick(audio_pending_tick),.clk(clk),.clk_en(ce_cpu&&!ss_freeze&&(!paused||ss_capture_progress)),.rst(!reset_n),.wr_n(pwr),.din(pd),.mux(STEREO?8'hf0:8'hff),.soundL(audio2),.soundR(a2r),.ready(),.ss_out(psg2_out),.ss_set(psg2_set),.ss_in(psg2_in),.ss_ext_out(psg2_ext_out),.ss_ext_in(psg2_ext_in),.ss_ext_set(audio_ext_set),.ss_div_out(div2),.ss_div_in(psg_div_in),.ss_quiescent(pq2));
wire[95:0]rpsgext;wire[55:0]rpsgcfg;wire[3:0]rpsgdiv;wire signed[10:0]raudio;
jt89 rpsg(.ss_pending_tick(1'b0),.clk(clk),.clk_en(rce_cpu&&!holdref&&(!rpaused||ref_progress)),.rst(!reset_n),.wr_n(qmode?1'b1:pwr),.din(pd),.mux(STEREO?8'hf0:8'hff),.soundL(raudio),.soundR(rar),.ready(),.ss_out(rpsgcfg),.ss_set(1'b0),.ss_in(56'd0),.ss_ext_out(rpsgext),.ss_ext_in(96'd0),.ss_ext_set(1'b0),.ss_div_out(rpsgdiv),.ss_div_in(4'd0),.ss_quiescent());
integer frame=0,accepts=0,transfers=0,request_cycle=0,max_latency=0,progress_cpu=0,progress_psg=0;
integer checks=0,freeze_start=0,freeze_clocks=0,quiet=0,i;
reg compare_machine=0,held=0;reg[2:0]phase_at_freeze;
reg[258:0]replay_cpu[0:127];reg[166:0]replay_psg[0:127];
always@(posedge vb)frame=frame+1;
always@(posedge clk)begin
 if(reset_n&&ss_capture_progress)begin
  if(dut.state!=37||!vb||x>=256||storage_busy||(!cm1&&!cmreq&&z80_iset==0)||ss_freeze)$fatal(1,"override outside minimal seek window");
  if(paused&&ce_pix)progress_cpu=progress_cpu+1;
  if(paused&&ce_cpu)progress_psg=progress_psg+1;
 end
 if(dut.state==37&&cpu_ce&&!cm1&&!cmreq&&z80_iset==0&&vb&&x<256&&!storage_busy)begin
  accepts=accepts+1;if(cycle-request_cycle>max_latency)max_latency=cycle-request_cycle;
  $display("ACCEPT case%0d cycle%0d latency%0d phase%0b%0b%0b bus%h progressCPU%0d PSG%0d",CASE,cycle,cycle-request_cycle,paused,pp,up,ca,progress_cpu,progress_psg);
 end
end
always@(posedge ss_freeze)begin
 held=1;phase_at_freeze={paused,pp,up};freeze_start=cycle;
 if(ss_capture_progress)$fatal(1,"override persists at freeze");
 $display("FREEZE case%0d cycle%0d phase%0b",CASE,cycle,phase_at_freeze);
end
always@(negedge ss_freeze)if(held)begin
 transfers=transfers+1;freeze_clocks=cycle-freeze_start;quiet=4;
 $display("RELEASE case%0d cycle%0d transport%0d phase%0b reference%0b",CASE,cycle,freeze_clocks,{paused,pp,up},{rpaused,rpp,rup});
end
task button;begin joy=1;repeat(3)tick;joy=0;repeat(3)tick;end endtask
task put(input[7:0]b);begin pd=b;pwr=0;repeat(31)tick;pwr=1;repeat(31)tick;end endtask
task request(input bit saving);begin
 // Replay monitoring returns after a rising edge. Align before pulsing so
 // every request includes a sampling edge rather than ending at the next fall.
 tick;
 $display("REQUEST ENTER case%0d save%b cycle%0d state%0d cooldown%0d",CASE,saving,cycle,dut.state,dut.op_cooldown);
 force dut.op_cooldown=0;request_cycle=cycle;
 ss_save=saving;ss_load=!saving;tick;ss_save=0;ss_load=0;
 $display("REQUEST SENT case%0d save%b cycle%0d state%0d cooldown%0d",CASE,saving,cycle,dut.state,dut.op_cooldown);
 if(dut.state==0)$fatal(1,"test driver failed to present a sampled request");
end endtask
task complete;begin wait(ss_freeze);wait(!ss_freeze);repeat(12)tick;release dut.op_cooldown;end endtask
task automatic sample_replay(input integer pass);begin
 // Start at release, not after the UI helper's arbitrary twelve-clock wait.
 // Compare each subsystem from its FIRST native enable, without skipping any.
 fork
  begin integer n;n=0;while(n<128)begin @(posedge clk);if(ce_pix)begin #1;
   // DO is not driven as meaningful data during a read. Check it on writes;
   // registers, address, M1/MREQ/IORQ/RD/WR are checked on every CPU tick.
   if(pass==0)replay_cpu[n]={z80_reg,ca,(cwr?8'd0:co),cm1,cmreq,ciq,crd,cwr};
   else if(replay_cpu[n]!=={z80_reg,ca,(cwr?8'd0:co),cm1,cmreq,ciq,crd,cwr})$fatal(1,"repeated load CPU/bus mismatch sample%0d regs%h/%h address%h/%h DO%h/%h bus%0b/%0b",n,replay_cpu[n][258:29],z80_reg,replay_cpu[n][28:13],ca,replay_cpu[n][12:5],co,replay_cpu[n][4:0],{cm1,cmreq,ciq,crd,cwr});
   n=n+1;
  end end end
  begin integer n;n=0;while(n<128)begin @(posedge clk);if(CASE==7?ce_pix:ce_cpu)begin #1;
   if(pass==0)replay_psg[n]={psg_out,psg_ext_out,psg_div_out,audio1};
   else if(replay_psg[n]!=={psg_out,psg_ext_out,psg_div_out,audio1})$fatal(1,"repeated load PSG mismatch sample%0d",n);
   n=n+1;
  end end end
 join
end endtask

wire[6:0]fm_counter,rfm_counter;wire[13:0]fmout,rfmout; wire[15:0]rl,rr_audio;wire refphase;
AudioMix mix(.ss_last_sample(last_sample_in),.ss_last_valid(last_sample_valid),.clk(clk),.audio_in_l1((FM_ONLY?16'd0:{audio1[10],audio1,4'b0})),.audio_in_r1((FM_ONLY?16'd0:{a1r[10],a1r,4'b0})),
.audio_in_l2((systeme?{audio2[10],audio2,4'b0}:(FM_SUPPRESS?16'd0:{((fmout[13]==fmout[12])?fmout[12:0]:{fmout[13],{12{fmout[12]}}}),3'b0}))),.audio_in_r2((systeme?{a2r[10],a2r,4'b0}:(FM_SUPPRESS?16'd0:{((fmout[13]==fmout[12])?fmout[12:0]:{fmout[13],{12{fmout[12]}}}),3'b0}))),.audio_l(al),.audio_r(ar),.ss_phase_out(audio_phase_out),.ss_phase_in(reset_n?audio_phase_in:1'b0),.ss_phase_set(audio_phase_set||!reset_n));
AudioMix rmix(.clk(clk),.audio_in_l1((FM_ONLY?16'd0:{raudio[10],raudio,4'b0})),.audio_in_r1((FM_ONLY?16'd0:{rar[10],rar,4'b0})),
.audio_in_l2((systeme?(FM_ONLY?16'd0:{raudio[10],raudio,4'b0}):(FM_SUPPRESS?16'd0:{((rfmout[13]==rfmout[12])?rfmout[12:0]:{rfmout[13],{12{rfmout[12]}}}),3'b0}))),.audio_in_r2((systeme?(FM_ONLY?16'd0:{rar[10],rar,4'b0}):(FM_SUPPRESS?16'd0:{((rfmout[13]==rfmout[12])?rfmout[12:0]:{rfmout[13],{12{rfmout[12]}}}),3'b0}))),.audio_l(rl),.audio_r(rr_audio),.ss_phase_out(refphase),.ss_phase_in(1'b0),.ss_phase_set(!reset_n));
integer fd,k,scan,errors=0,first=-1,pass,raw_errors;reg[31:0]want;reg[31:0]oracle[0:N-1];
reg[55:0]ocfg[0:N-1];reg[95:0]oext[0:N-1];reg[3:0]odiv[0:N-1];reg[21:0]osnd[0:N-1];reg[4:0]ophase[0:N-1];
integer fmerrors=0,fmfirst=-1;reg[13:0]ofm[0:N-1];reg[6:0]ocounter[0:N-1];reg oupdate[0:N-1],omixphase[0:N-1];reg fm_event,rfm_event;
reg[63:0]immutable_image[0:12287];
always@(posedge clk)if(dut.state==1)$display("LATE_AUDIO_CAPTURE cycle%0d phase%b div%0d",cycle,audio_phase_out,psg_div_out);
always@(posedge clk)if((dut.state==34&&dut.unfreeze_cnt>=250)||dut.state==105||dut.state==106)
$display("PRE_RELEASE cycle%0d state%0d clkd%0d cpu%b psgCE%b cen16%b out%0d mix%h/%h phase%b set%b",cycle,dut.state,clkd,ce_cpu,ce_cpu&&!ss_freeze&&!paused,psg1.cen_16,audio1,al,ar,audio_phase_out,audio_phase_set);
initial begin
for(k=0;k<12288;k=k+1)mem[k]=0;audio_control_out=STEREO?11'h7f0:11'h7ff;
systeme=(RANDOMSEED%5==0);ss_game_id=32'h12345678;repeat(6+RESET_SKEW)tick;reset_n=1;repeat(2)tick;
put(8'h86);put(8'h00);put(8'h90); // audible period-six tone
if(psg1.tone0!=6||rpsg.tone0!=6)$fatal(1,"tone programming failed");
fmsetup;
 // Exercise a real key-off/on/off history on every inactive channel. This
 // establishes known phase/envelope state using legal held F0/F1 commands.
 for(integer ch=1;ch<9;ch++)fmwrite(8'h20+ch,8'h19);
 for(integer ch=1;ch<9;ch++)fmwrite(8'h20+ch,8'h09);
 if(PROGRAM)randomsetup;repeat(SEED)tick;
storage_busy=1;request(1);
begin integer seek;seek=0;while(!(dut.state==37&&vb&&x<256&&cpu_ce&&!cm1&&!cmreq&&z80_iset==0&&fm_counter==PHASE))begin tick;seek++;if(seek>2000000)$fatal(1,"unreachable phase%0d",PHASE);end storage_busy=0;end
wait(ss_freeze);
$display("CAPTURE cycle%0d clkd%0d div%0d sample%0d mixer%h/%h phase%b",cycle,clkd,psg_div_out,audio1,al,ar,audio_phase_out);
$display("PSG_CONFIG tone%0d cnt%0d out%b refTone%0d refCnt%0d cfg%h",psg1.tone0,psg1.u_tone0.cnt,psg1.u_tone0.out,rpsg.tone0,rpsg.u_tone0.cnt,psg_out);
if(REF)begin
fd=$fopen("reference.dat","w");
for(k=0;k<N;k=k+1)begin @(posedge clk);#1;$fdisplay(fd,"%h %h %h %h %h %h %h %h %b %b",{rl,rr_audio},rpsgcfg,rpsgext,rpsgdiv,{raudio,rar},rclkd,rfmout,rfm_counter,rfm_event,refphase);end
$fclose(fd);$display("PASS REFERENCE N%0d",N);$finish;
end else begin
fd=$fopen("reference.dat","r");if(!fd)$fatal(1,"missing reference");
for(k=0;k<N;k=k+1)begin scan=$fscanf(fd,"%h %h %h %h %h %h %h %h %b %b",oracle[k],ocfg[k],oext[k],odiv[k],osnd[k],ophase[k],ofm[k],ocounter[k],oupdate[k],omixphase[k]);if(scan!=10)$fatal(1,"bad oracle");end $fclose(fd);
wait(!ss_freeze);
$writememh("image_save.hex",mem);
for(k=0;k<12288;k=k+1)begin if($isunknown(mem[k]))$fatal(1,"unknown image word%h",k);immutable_image[k]=mem[k];end
for(pass=0;pass<=REPLAYS;pass=pass+1)begin
errors=0;first=-1;raw_errors=0;fmerrors=0;fmfirst=-1;
for(k=0;k<N;k=k+1)begin @(posedge clk);#1;
if({psg_out,psg_ext_out,psg_div_out,audio1,a1r,clkd}!=={ocfg[k],oext[k],odiv[k],osnd[k],ophase[k]})raw_errors++;
if(systeme&&{psg2_out,psg2_ext_out,div2,audio2,a2r}!=={ocfg[k],oext[k],odiv[k],osnd[k]})$fatal(1,"System E PSG2 isolation");
if({fm_counter,fm_event,audio_phase_out}!=={ocounter[k],oupdate[k],omixphase[k]})$fatal(1,"FM event/phase mismatch pass%0d k%0d",pass,k);if(fmout!==ofm[k])begin fmerrors++;if(fmfirst<0)fmfirst=k;end
if({al,ar}!==oracle[k])begin errors=errors+1;if(first<0)first=k;if(errors<8)$display("AUDIO_DIFF pass%0d k%0d actual%h expected%h clkd%0d div%0d psg%0d",pass,k,{al,ar},oracle[k],clkd,psg_div_out,audio1);end
if(k>=1148&&k<=1155)$display("TRANSITION pass%0d k%0d phase%b set%b PSG%0d mixer%h/%h expected%h clkd%0d",pass,k,audio_phase_out,audio_phase_set,audio1,al,ar,oracle[k],clkd);
if(k<20)$display("FIRST pass%0d k%0d state%0d clkd%0d cpu%b sndUNDRIVEN psgCE%b psg%0d mix%h/%h phase%b set%b",pass,k,dut.state,clkd,ce_cpu,ce_cpu&&!ss_freeze&&!paused,audio1,al,ar,audio_phase_out,audio_phase_set);
end
$display("FM_RESULT pass%0d errors%0d first%0d",pass,fmerrors,fmfirst);
$display("RESULT pass%0d errors%0d first%0d raw_errors%0d descriptor%h",pass,errors,first,raw_errors,mem['h20]);
if(!CHARACTERIZE&&errors)$fatal(1,"G08.release isolation mismatch");
if(fmerrors)$fatal(1,"F01 raw FM suffix mismatch");
if(raw_errors)$fatal(1,"raw PSG or phase mismatch: isolate mixer before verdict");
for(k=0;k<12288;k=k+1)if(mem[k]!==immutable_image[k])$fatal(1,"image changed during replay");
if(pass<REPLAYS)begin qmode=1; fmwrite(8'hf0,0);fmwrite(0,8'h61^(RANDOMSEED+pass));fmwrite(3,(RANDOMSEED*7+pass)&31);fmwrite(8'h0e,((RANDOMSEED+pass)&1)?8'h3f:0);fmwrite(8'h20,8'h09);fmwrite(8'h30,8'hf0); fmwrite(8'h10,(8'h37+pass+RANDOMSEED*13)&255); repeat(5000+pass*103)tick; put(8'h9f);repeat(777+pass*103)tick;put(8'h80|pass);put(8'h00);put(8'h90|pass);repeat(1000)tick;
$display("Q_HISTORY pass%0d cfg%h ext%h div%0d psg%0d audio%h/%h",pass,psg_out,psg_ext_out,psg_div_out,audio1,al,ar);
request(0);wait(ss_freeze);wait(!ss_freeze);end
end
$writememh("image.hex",mem);$display("PASS G08FM FMCASE%0d HISTORY%0d",FMCASE,HISTORY);$finish;
end end
initial begin #1000000000;$fatal(1,"watchdog");end
reg[311:0]held_psgs;reg preparing=0;integer prepare_clocks=0;
always@(posedge clk)begin
 if(cpu_prepare&&!preparing)begin held_psgs={psg_ext_out,psg_out,psg_div_out,psg2_ext_out,psg2_out,div2};prepare_clocks=0;end
 if(cpu_prepare)begin
  prepare_clocks++;
  if(prepare_clocks>48)$fatal(1,"paused private preparation exceeded bound");
  if({psg_ext_out,psg_out,psg_div_out,psg2_ext_out,psg2_out,div2}!==held_psgs)$fatal(1,"paused CPU preparation advanced PSGs");
 end
 if(compare_machine&&frame>=1&&!ss_freeze&&$isunknown({z80_reg,rr}))$fatal(1,"uninitialized Pause CPU oracle");
 if(preparing&&!cpu_prepare)$display("PAUSE_PRIVATE_PREPARATION clocks%0d savedT2%b UIpaused%b",prepare_clocks,replay_t2,paused);
 preparing<=cpu_prepare;
end
reg fm_a=0,rfm_a=0,fwr=0;reg[7:0]fm_d=0,rfm_d=0,fbus=0;reg fa=0;

// Literal system.vhd latch behavior; legal fixture IO writes, not CPU OUT instructions.
always@(posedge clk)begin
 if(!reset_n||fm_legacy_reset)begin fm_a<=0;fm_d<=0;rfm_a<=0;rfm_d<=0;end
 else begin if(ss_freeze&&fm_state_write&&fm_state_addr==8'h4c)begin fm_a<=fm_state_wdata[0];fm_d<=fm_state_wdata[8:1];end else if(!ss_freeze&&fwr)begin fm_a<=fa;fm_d<=fbus;end
 if(!qmode&&fwr)begin rfm_a<=fa;rfm_d<=fbus;end end
end
assign fm_state_rdata=fm_opll_rdata|fm_wrapper_rdata;
always@(posedge clk)begin fm_wrapper_rdata<=0;if(ss_freeze&&observed_read&&observed_addr==8'h4c)fm_wrapper_rdata<={23'd0,fm_d,fm_a};end
opll fm(.audit_counter(fm_counter),.ss_hold(ss_freeze&&!fm_initialization_run),.ss_addr(observed_addr),.ss_read(observed_read),.ss_write(fm_state_write),.ss_wdata(fm_state_wdata),.ss_rdata(fm_opll_rdata),.ss_initialized(fm_initialized),.xin(clk),.xena(ce_cpu&&!ss_freeze&&!paused),.d(fm_d),.a(fm_a),.cs_n(1'b0),.we_n(1'b0),.ic_n(reset_n&&!fm_legacy_reset),.mixout(fmout));
generate if(REF)begin opll_reference rfm(.audit_counter(rfm_counter),.xin(clk),.xena(rce_cpu&&!holdref&&!rpaused),.d(rfm_d),.a(rfm_a),.cs_n(1'b0),.we_n(1'b0),.ic_n(reset_n),.mixout(rfmout)); end else begin assign rfmout=14'd0;end endgenerate
task fmwrite(input[7:0]addr,input[7:0]data);begin
 fa=0;fbus=addr;fwr=1;repeat(60)tick;fwr=0;repeat(60)tick;
 fa=1;fbus=data;fwr=1;repeat(60)tick;fwr=0;repeat(2400)tick;
end endtask
task fmsetup;begin
 // User instrument: sustained audible carrier, adjustable attack/decay/release.
 fmwrite(0,8'h21);fmwrite(1,8'h21);fmwrite(2,8'h10);fmwrite(3,8'h07);
 fmwrite(4,FMCASE==1?8'h41:8'hf4);fmwrite(5,FMCASE==1?8'h41:8'hf4);
 fmwrite(6,FMCASE==2?8'h84:8'h04);fmwrite(7,FMCASE==2?8'h84:8'h04);
 fmwrite(8'h30,FMCASE==5?8'h10:8'h00);
 fmwrite(8'h10,HISTORY?8'hb1:8'h91);fmwrite(8'h20,8'h19);
 repeat(50000)tick; fmwrite(8'h10,8'h91); if(CONVERGE)begin fmwrite(8'h20,8'h09);fmwrite(8'h20,8'h19);repeat(6000)tick;end
 if(FMCASE==8)begin fmwrite(8'h31,8'h20);fmwrite(8'h11,8'hf1);fmwrite(8'h21,8'h17);end
 if(FMCASE==7)begin fmwrite(8'h36,8'h10);fmwrite(8'h37,8'h10);fmwrite(8'h38,8'h10);fmwrite(8'h16,8'h81);fmwrite(8'h17,8'h71);fmwrite(8'h18,8'h51);fmwrite(8'h26,8'h19);fmwrite(8'h27,8'h19);fmwrite(8'h28,8'h19);fmwrite(8'h0e,8'h3f);end
 if(FMCASE==4)begin if(!FASTVIDEO)while(cycle<630000)tick;fmwrite(8'h20,8'h09);end
 if(FMCASE==1||FMCASE==2)begin fmwrite(8'h20,8'h09);if(!FASTVIDEO)while(cycle<640000)tick;fmwrite(8'h20,8'h19);end
end endtask
integer random_state;integer rv,chan,voices;
function automatic integer next_random;begin random_state=random_state^(random_state<<13);random_state=random_state^(random_state>>17);random_state=random_state^(random_state<<5);next_random=random_state&32'h7fffffff;end endfunction
task randomsetup;begin
 random_state=RANDOMSEED*32'h19e3779;
 rv=next_random();fmwrite(0,(rv&1)?8'he1:8'h61);rv=next_random();fmwrite(1,(rv&1)?8'he1:8'h61);
 rv=next_random();fmwrite(2,rv&63);fmwrite(3,(RANDOMSEED&7)|((RANDOMSEED&3)<<3));
 rv=next_random();fmwrite(4,((8+(rv&7))<<4)|((rv>>3)&15));rv=next_random();fmwrite(5,((8+(rv&7))<<4)|((rv>>3)&15));
 rv=next_random();fmwrite(6,((rv%13)<<4)|(1+((rv>>4)%15)));rv=next_random();fmwrite(7,((rv%13)<<4)|(1+((rv>>4)%15)));
 voices=2+(RANDOMSEED%8);
 for(chan=0;chan<voices;chan++)begin
  rv=next_random();fmwrite(8'h30+chan,chan==0?(rv&3):(rv&255));
  rv=next_random();fmwrite(8'h10+chan,64+(rv%192));
 rv=next_random();fmwrite(8'h20+chan,(chan==0?8'h10:((rv>>4)&8'h30))|((3+(rv%4))<<1)|((rv>>9)&1));
 end
 if(RANDOMSEED%3==0)begin fmwrite(8'h36,8'h10);fmwrite(8'h37,8'h10);fmwrite(8'h38,8'h10);fmwrite(8'h0e,8'h3f);end
 if(RANDOMSEED%4==0)fmwrite(8'hf0,8'h80);
 rv=next_random();repeat(1000+(rv%18000))tick;
 $display("RANDOM_CONFIG seed%0d channels%0d feedback%0d",RANDOMSEED,voices,RANDOMSEED&7);
end endtask
always@(posedge clk)begin
 fm_event<=ce_cpu&&!ss_freeze&&!paused&&fm_counter==70;
 rfm_event<=rce_cpu&&!holdref&&!rpaused&&rfm_counter==70;
 if(dut.state==37&&!storage_busy&&cpu_ce&&!cm1&&!cmreq&&z80_iset==0&&vb&&x<256)begin
  $display("ACCEPT save%b counter%0d native%0d fmCE%b phase%b raw%h mixed%h/%h",dut.do_save,fm_counter,clkd,ce_cpu,audio_phase_out,fmout,al,ar);
  #1;$display("POST_T counter%0d raw%h mixed%h/%h nextPhase%b",fm_counter,fmout,al,ar,audio_phase_out);
 end
end
always@(negedge ss_freeze)if(reset_n)begin #1;
 $display("HANDOFF_RESTORED counter%0d raw%h savedCounter%0d savedRaw%h nextPhase%b",fm_counter,fmout,mem['h2998+39][6:0],mem['h2998+51][13:0],audio_phase_in);
end
integer audit_loads=0;integer audit_fd;reg[31:0]audit_expected;
initial begin
 audit_fd=$fopen("restored_state.dat","w");
 forever begin
  @(posedge clk);#1;
  if(dut.state==34&&dut.unfreeze_cnt==0&&!dut.do_save)begin
   audit_loads++;
   tick;audit_busy=1;
   for(integer row=0;row<104;row++)begin
    audit_addr=row;audit_read=1;tick;
    audit_expected=row[0]?mem['h2998+row/2][63:32]:mem['h2998+row/2][31:0];
    $fdisplay(audit_fd,"load%0d row%0d actual%08h expected%08h",audit_loads,row,fm_state_rdata,audit_expected);
    if(fm_state_rdata!==audit_expected)$fatal(1,"OPLL readback load%0d row%0d actual%h expected%h",audit_loads,row,fm_state_rdata,audit_expected);
    audit_read=0;tick;
   end
   audit_busy=0;
   $display("PASS OPLL_READBACK load%0d rows104",audit_loads);
   wait(dut.state!=34);
  end
 end
end
integer qfd,qloads=0,qp,qe,qf,qt;
initial begin
 qfd=$fopen("perturbed_state.dat","w");
 forever begin
  @(posedge clk);#1;
  if(dut.state==59&&dut.flush_cnt==0&&!dut.do_save)begin
   qloads++;qp=0;qe=0;qf=0;qt=0;
   tick;audit_busy=1;
   for(integer row=0;row<104;row++)begin
    audit_addr=row;audit_read=1;tick;
    audit_expected=row[0]?mem['h2998+row/2][63:32]:mem['h2998+row/2][31:0];
    $fdisplay(qfd,"load%0d row%0d actual%08h saved%08h",qloads,row,fm_state_rdata,audit_expected);
    if(fm_state_rdata!==audit_expected)begin
     qt++;if(row>=13&&row<=30)qp++;if(row>=31&&row<=48)qe++;if(row>=49&&row<=57)qf++;
    end
    audit_read=0;tick;
   end
   audit_busy=0;
   $display("Q_STRENGTH load%0d total%0d phase%0d envelope%0d feedback%0d",qloads,qt,qp,qe,qf);
   if(qp==0||qe==0||qf==0)$fatal(1,"weak OPLL perturbation");
   wait(dut.state!=59);
  end
 end
end
endmodule
