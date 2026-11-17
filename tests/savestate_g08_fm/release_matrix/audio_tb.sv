`timescale 1ns/1ps
module pause_tb;wire[15:0]al,ar,last_sample_in;wire last_sample_valid;wire[135:0]refvdp_regs,refvdp2_regs;parameter DIVSEEK=-1,PAT=0,ROUTE=0,DUAL=0,BUS=0,HISTORY=0,BOOT=6,PAUSE=0,SEEK=0,REPLAYS=3,LATENCY=3,TARGET=0,REF=0,SEED=0,N=24000,CASE=0,KEEP=0,FULL=0,STALL=0,OFFSET=0,DELAY=6;
reg clk = '0;
reg reset_n = '0;
reg ss_save = '0;
reg ss_load = '0;
reg [1:0] ss_slot = '0;
reg ss_bios_mode = '0;
reg [31:0] ss_game_id = '0;
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
wire [10:0] audio_control_out;
reg[7:0]mux_control=8'hff,rmux=8'hff;assign audio_control_out={3'b111,mux_control};
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
savestates dut(.audio_last_out(audio_phase_out?al:ar),.audio_last_in(last_sample_in),.audio_last_valid(last_sample_valid),.fm_initialized(1'b1),.fm_state_rdata(32'd0),.audio_pending_tick(audio_pending_tick),.bg_out(139'd0),.bg2_out(139'd0),.bg_in(),.bg2_in(),.bg_valid(),.ss_cpu_prepare(cpu_prepare),.z80_replay(replay),.z80_tick_active(actual_tick),.z80_replay_t2(replay_t2),
 .clock_phase(clkd==25?2'd3:clkd==20?2'd2:clkd==10?2'd1:2'd0),.clock_phase_in(phase_in),.clock_phase_set(phase_set),.clock_phase_ready(phase_ready),
 .sprite_out(4778'd0),.sprite2_out(4778'd0),.sprite_in(),.sprite2_in(),.sprite_valid(),.z80_restart(restart_out),.z80_nmi(3'b001),.mapper_history_out(18'h0ffff),.mapper_history_in(),.clk(clk),.reset_n(reset_n),.ss_save(ss_save),.ss_load(ss_load),.ss_slot(ss_slot),.ss_bios_mode(ss_bios_mode),.ss_game_id(ss_game_id),.ss_freeze(ss_freeze),.ss_capture_progress(ss_capture_progress),.vblank(vblank),.x(x),.z80_reg(z80_reg),.z80_dir(z80_dir),.z80_set(z80_set),.z80_m1_n(z80_m1_n),.z80_mreq_n(z80_mreq_n),.z80_iset(z80_iset),.cpu_ce(cpu_ce),.vdp_ce(vdp_ce),.pix_ce(pix_ce),.sp_ce(sp_ce),.vdp_regs(vdp_regs),.vdp_regs_in(vdp_regs_in),.vdp_regs_set(vdp_regs_set),.cram_out(cram_out),.cram_A(cram_A),.cram_D(cram_D),.cram_wr(cram_wr),.vram_en(vram_en),.vram_A(vram_A),.vram_D(vram_D),.vram_WE(vram_WE),.vram_WA(vram_WA),.vram_WD(vram_WD),.psg_out(psg_out),.psg_in(psg_in),.psg_set(psg_set),.psg_ext_out(psg_ext_out),.psg2_ext_out(psg2_ext_out),.psg_ext_in(psg_ext_in),.psg2_ext_in(psg2_ext_in),.psg_div_out(psg_div_out),.psg_div_in(psg_div_in),.audio_control_out(audio_control_out),.audio_control_in(audio_control_in),.audio_quiescent(audio_quiescent),.audio_phase_out(audio_phase_out),.audio_phase_in(audio_phase_in),.audio_ext_set(audio_ext_set),.audio_phase_set(audio_phase_set),.mapper_out(mapper_out),.mapper_in(mapper_in),.mapper_set(mapper_set),.evolution_out(evolution_out),.evolution_in(evolution_in),.evolution_set(evolution_set),.storage_busy(storage_busy),.ss_busy(ss_busy),.eeprom_present(eeprom_present),.eeprom_ext_out(eeprom_ext_out),.eeprom_ext_in(eeprom_ext_in),.eeprom_full(eeprom_full),.nvram_refill(nvram_refill),.gun_out(gun_out),.gun_in(gun_in),.gun_set(gun_set),.gun_valid(gun_valid),.paddle_out(paddle_out),.paddle_in(paddle_in),.paddle_set(paddle_set),.paddle_valid(paddle_valid),.tap_out(tap_out),.tap_in(tap_in),.tap_set(tap_set),.tap_valid(tap_valid),.sc_ram_size(sc_ram_size),.sc_ram_restored(sc_ram_restored),.eeprom_out(eeprom_out),.eeprom_in(eeprom_in),.eeprom_set(eeprom_set),.wram_A(wram_A),.wram_D(wram_D),.wram_WE(wram_WE),.wram_WA(wram_WA),.wram_WD(wram_WD),.nvram_A(nvram_A),.nvram_D(nvram_D),.nvram_WE(nvram_WE),.nvram_WA(nvram_WA),.nvram_WD(nvram_WD),.systeme(systeme),.vdp2_regs(vdp2_regs),.vdp2_regs_in(vdp2_regs_in),.vdp2_regs_set(vdp2_regs_set),.cram2_out(cram2_out),.cram2_A(cram2_A),.cram2_D(cram2_D),.cram2_wr(cram2_wr),.vram2_en(vram2_en),.vram2_A(vram2_A),.vram2_D(vram2_D),.vram2_WE(vram2_WE),.vram2_WA(vram2_WA),.vram2_WD(vram2_WD),.psg2_out(psg2_out),.psg2_in(psg2_in),.psg2_set(psg2_set),.md_out(md_out),.md_in(md_in),.md_set(md_set),.md_valid(md_valid),.gg_out(gg_out),.gg_in(gg_in),.gg_set(gg_set),.io_out(io_out),.io_in(io_in),.io_set(io_set),.video_state_out(video_state_out),.video_state_in(video_state_in),.video_state_set(video_state_set),.DDRAM_ADDR(DDRAM_ADDR),.DDRAM_DIN(DDRAM_DIN),.DDRAM_BE(DDRAM_BE),.DDRAM_WE(DDRAM_WE),.DDRAM_DOUT(DDRAM_DOUT),.DDRAM_DOUT_READY(DDRAM_DOUT_READY),.DDRAM_RD(DDRAM_RD),.DDRAM_BURSTCNT(DDRAM_BURSTCNT),.DDRAM_BUSY(DDRAM_BUSY));
always #5 clk=~clk;
reg [63:0] mem[0:12287]; integer cycle=0, pending=0; reg [28:0] readaddr;
integer writes=0,reads=0; reg restored=0; reg [135:0] seen1,seen2;
reg ce_cpu=0,ce_pix=0,ce_vdp=0,ce_sp=0;
assign cpu_ce=DUAL==3?ce_cpu:ce_pix;assign vdp_ce=ce_vdp;assign pix_ce=ce_pix;assign sp_ce=ce_sp;
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
 if(DDRAM_RD&&!DDRAM_BUSY)begin if(pending!=0)$fatal(1,"overlap read");pending<=LATENCY;readaddr<=DDRAM_ADDR;reads<=reads+1;end
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
reg[4:0]rclkd=0;reg rce_cpu=0,rce_pix=0;
always@(negedge clk)begin rce_cpu<=0;rce_pix<=0;rclkd<=rclkd==29?0:rclkd+1;
if(rclkd==9||rclkd==24)rce_cpu<=1;if(rclkd==9||rclkd==19||rclkd==29)rce_pix<=1;end
pause_fixture p(clk,reset_n,systeme,joy,vb,ss_freeze,KEEP!=0,paused,pp,up);
pause_fixture rp(clk,reset_n,systeme,joy,rvb,1'b0,1'b0,rpaused,rpp,rup);
assign vblank=vb;
video video1(.clk(clk),.ce_pix(ce_pix),.pal(1'b0),.border(1'b0),.ggres(1'b0),.mask_column(1'b0),.cut_mask(1'b0),.smode_M1(1'b0),.smode_M2(1'b0),.smode_M3(1'b0),.smode_M4(1'b1),.video_state_out(video_state_out),.video_state_in(video_state_in),.video_state_set(video_state_set),.x(x),.y(y),.vcounter_cpu(),.hsync(),.vsync(),.hblank(hb),.vblank(vb));
video videoref(.clk(clk),.ce_pix(rce_pix&&!holdref),.pal(1'b0),.border(1'b0),.ggres(1'b0),.mask_column(1'b0),.cut_mask(1'b0),.smode_M1(1'b0),.smode_M2(1'b0),.smode_M3(1'b0),.smode_M4(1'b1),.video_state_out(rvideo),.video_state_in(22'd0),.video_state_set(1'b0),.x(rx),.y(ry),.vcounter_cpu(),.hsync(),.vsync(),.hblank(rhb),.vblank(rvb));
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
T80s #(.T2Write(0)) cpu(.RESET_n(reset_n),.CLK(clk),.CEN(((DUAL==3?ce_cpu:ce_pix)&&!ss_freeze&&(!paused||ss_capture_progress))||(ce_cpu&&cpu_prepare&&replay)),.WAIT_n(1'b1),.INT_n(1'b1),.NMI_n(1'b1),.BUSRQ_n(1'b1),.M1_n(cm1),.MREQ_n(cmreq),.IORQ_n(ciq),.RD_n(crd),.WR_n(cwr),.RFSH_n(),.HALT_n(),.BUSAK_n(),.OUT0(1'b0),.A(ca),.DI(rom(ca)),.DO(co),.REG(z80_reg),.NMIEnable(1'b1),.NMIDIR(dut.z80_nmi_dir),.NMIValid(dut.z80_nmi_valid),.NMIHold(dut.z80_nmi_hold),.RestoreHold(ss_freeze),.ReplayT2(replay_t2),.NMIReplay(replay),.RestartContext(restart_out),.RestartDIR(dut.z80_restart_dir),.RestartValid(dut.z80_restart_valid),.DIRSet(z80_set),.DIR(z80_dir),.ISet_out(z80_iset));
T80s #(.T2Write(0)) rcpu(.RESET_n(reset_n),.CLK(clk),.CEN(((DUAL==3?rce_cpu:rce_pix)&&!holdref&&(!rpaused||ref_progress))),.WAIT_n(1'b1),.INT_n(1'b1),.NMI_n(1'b1),.BUSRQ_n(1'b1),.M1_n(rm1),.MREQ_n(rmreq),.IORQ_n(riq),.RD_n(rrd),.WR_n(rwr),.RFSH_n(),.HALT_n(),.BUSAK_n(),.OUT0(1'b0),.A(ra),.DI(rom(ra)),.DO(ro),.REG(rr),.DIRSet(1'b0),.DIR(230'd0),.ISet_out(riset));
generate if(FULL)begin:fullvdps
vdp vdp1(.clk_sys(clk),.ce_vdp((ce_vdp&&!ss_freeze)),.ce_pix((ce_pix&&!ss_freeze)),.ce_sp((ce_sp&&!ss_freeze)),.gg(1'b0),.ggres(1'b0),.se_bank(1'b0),.sp64(1'b0),.HL(1'b0),.mask_line_irq(1'b0),.capture_cpu_edges(1'b0),.legacy_ext_nt(1'b0),.RD_n(1'b1),.WR_n(1'b1),.IRQ_n(),.WR_direct(1'b0),.A_direct(6'b0),.A(8'h00),.D_in(8'b0),.D_out(),.x(x),.y(y),.vcounter_cpu(8'b0),.color(),.palettemode(1'b0),.y1(),.mask_column(),.black_column(1'b0),.smode_M1(),.smode_M2(),.smode_M3(),.smode_M4(),.ysj_quirk(1'b0),.reset_n(reset_n),.ss_regs_out(vdp_regs),.ss_regs_in(vdp_regs_in),.ss_regs_set(vdp_regs_set),.ss_cram_out(),.ss_cram_wr(1'b0),.ss_cram_A(5'b0),.ss_cram_D(12'b0),.ss_vram_en(1'b0),.ss_vram_A(15'b0),.ss_vram_D(),.ss_vram_WE(1'b0),.ss_vram_WA(15'b0),.ss_vram_WD(8'b0));
vdp refvdp1(.clk_sys(clk),.ce_vdp((ce_vdp&&!holdref)),.ce_pix((ce_pix&&!holdref)),.ce_sp((ce_sp&&!holdref)),.gg(1'b0),.ggres(1'b0),.se_bank(1'b0),.sp64(1'b0),.HL(1'b0),.mask_line_irq(1'b0),.capture_cpu_edges(1'b0),.legacy_ext_nt(1'b0),.RD_n(1'b1),.WR_n(1'b1),.IRQ_n(),.WR_direct(1'b0),.A_direct(6'b0),.A(8'h00),.D_in(8'b0),.D_out(),.x(rx),.y(ry),.vcounter_cpu(8'b0),.color(),.palettemode(1'b0),.y1(),.mask_column(),.black_column(1'b0),.smode_M1(),.smode_M2(),.smode_M3(),.smode_M4(),.ysj_quirk(1'b0),.reset_n(reset_n),.ss_regs_out(refvdp_regs),.ss_regs_in(136'd0),.ss_regs_set(1'b0),.ss_cram_out(),.ss_cram_wr(1'b0),.ss_cram_A(5'b0),.ss_cram_D(12'b0),.ss_vram_en(1'b0),.ss_vram_A(15'b0),.ss_vram_D(),.ss_vram_WE(1'b0),.ss_vram_WA(15'b0),.ss_vram_WD(8'b0));
vdp vdp2(.clk_sys(clk),.ce_vdp((ce_vdp&&!ss_freeze)),.ce_pix((ce_pix&&!ss_freeze)),.ce_sp((ce_sp&&!ss_freeze)),.gg(1'b0),.ggres(1'b0),.se_bank(1'b1),.sp64(1'b0),.HL(1'b0),.mask_line_irq(1'b0),.capture_cpu_edges(1'b0),.legacy_ext_nt(1'b0),.RD_n(1'b1),.WR_n(1'b1),.IRQ_n(),.WR_direct(1'b0),.A_direct(6'b0),.A(8'h00),.D_in(8'b0),.D_out(),.x(x),.y(y),.vcounter_cpu(8'b0),.color(),.palettemode(1'b0),.y1(),.mask_column(),.black_column(1'b0),.smode_M1(),.smode_M2(),.smode_M3(),.smode_M4(),.ysj_quirk(1'b0),.reset_n(reset_n),.ss_regs_out(vdp2_regs),.ss_regs_in(vdp2_regs_in),.ss_regs_set(vdp2_regs_set),.ss_cram_out(),.ss_cram_wr(1'b0),.ss_cram_A(5'b0),.ss_cram_D(12'b0),.ss_vram_en(1'b0),.ss_vram_A(15'b0),.ss_vram_D(),.ss_vram_WE(1'b0),.ss_vram_WA(15'b0),.ss_vram_WD(8'b0));
vdp refvdp2(.clk_sys(clk),.ce_vdp((ce_vdp&&!holdref)),.ce_pix((ce_pix&&!holdref)),.ce_sp((ce_sp&&!holdref)),.gg(1'b0),.ggres(1'b0),.se_bank(1'b1),.sp64(1'b0),.HL(1'b0),.mask_line_irq(1'b0),.capture_cpu_edges(1'b0),.legacy_ext_nt(1'b0),.RD_n(1'b1),.WR_n(1'b1),.IRQ_n(),.WR_direct(1'b0),.A_direct(6'b0),.A(8'h00),.D_in(8'b0),.D_out(),.x(rx),.y(ry),.vcounter_cpu(8'b0),.color(),.palettemode(1'b0),.y1(),.mask_column(),.black_column(1'b0),.smode_M1(),.smode_M2(),.smode_M3(),.smode_M4(),.ysj_quirk(1'b0),.reset_n(reset_n),.ss_regs_out(refvdp2_regs),.ss_regs_in(136'd0),.ss_regs_set(1'b0),.ss_cram_out(),.ss_cram_wr(1'b0),.ss_cram_A(5'b0),.ss_cram_D(12'b0),.ss_vram_en(1'b0),.ss_vram_A(15'b0),.ss_vram_D(),.ss_vram_WE(1'b0),.ss_vram_WA(15'b0),.ss_vram_WD(8'b0));
end else begin:lightvdps assign vdp_regs=0;assign vdp2_regs=0;end endgenerate
reg pwr2=1;reg[7:0]pd2=0;reg qmode=0;wire signed[10:0]a1r,a2r,rar;wire pq1,pq2;wire[3:0]div2;wire signed[10:0]audio1,audio2;reg pwr=1;reg[7:0]pd=0;
assign audio_quiescent=pq1&&pq2;
jt89 psg1(.ss_pending_tick(audio_pending_tick),.clk(clk),.clk_en(ce_cpu&&!ss_freeze&&(!paused||ss_capture_progress)),.rst(!reset_n),.wr_n(BUS&&!ciq&&ca[7:6]==1?cwr:pwr),.din(BUS&&!ciq&&ca[7:6]==1?co:pd),.mux(mux_control),.soundL(audio1),.soundR(a1r),.ready(),.ss_out(psg_out),.ss_set(psg_set),.ss_in(psg_in),.ss_ext_out(psg_ext_out),.ss_ext_in(psg_ext_in),.ss_ext_set(audio_ext_set),.ss_div_out(psg_div_out),.ss_div_in(psg_div_in),.ss_quiescent(pq1));
jt89 psg2(.ss_pending_tick(audio_pending_tick && systeme),.clk(clk),.clk_en(ce_cpu&&!ss_freeze&&(!paused||ss_capture_progress)),.rst(!reset_n),.wr_n(pwr2),.din(pd2),.mux(mux_control),.soundL(audio2),.soundR(a2r),.ready(),.ss_out(psg2_out),.ss_set(psg2_set),.ss_in(psg2_in),.ss_ext_out(psg2_ext_out),.ss_ext_in(psg2_ext_in),.ss_ext_set(audio_ext_set),.ss_div_out(div2),.ss_div_in(psg_div_in),.ss_quiescent(pq2));
wire[95:0]rpsgext;wire[55:0]rpsgcfg;wire[3:0]rpsgdiv;wire signed[10:0]raudio;
jt89 rpsg(.ss_pending_tick(1'b0),.clk(clk),.clk_en(rce_cpu&&!holdref&&(!rpaused||ref_progress)),.rst(!reset_n),.wr_n(BUS&&!riq&&ra[7:6]==1?rwr:(qmode?1'b1:pwr)),.din(BUS&&!riq&&ra[7:6]==1?ro:pd),.mux(rmux),.soundL(raudio),.soundR(rar),.ready(),.ss_out(rpsgcfg),.ss_set(1'b0),.ss_in(56'd0),.ss_ext_out(rpsgext),.ss_ext_in(96'd0),.ss_ext_set(1'b0),.ss_div_out(rpsgdiv),.ss_div_in(4'd0),.ss_quiescent());
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


wire[55:0]r2cfg;wire[95:0]r2ext;wire[3:0]r2div;wire signed[10:0]r2l,r2r;
always@(posedge clk)if(audio_ext_set)mux_control<=audio_control_in[7:0];
jt89 rpsg2(.ss_pending_tick(1'b0),.clk(clk),.clk_en(rce_cpu&&(!rpaused||ref_progress)),.rst(!reset_n),.wr_n(qmode?1'b1:pwr2),.din(pd2),.mux(rmux),.soundL(r2l),.soundR(r2r),.ready(),.ss_out(r2cfg),.ss_set(1'b0),.ss_in(56'd0),.ss_ext_out(r2ext),.ss_ext_in(96'd0),.ss_ext_set(1'b0),.ss_div_out(r2div),.ss_div_in(4'd0),.ss_quiescent());
// Include capture-seeking PSG progress in the independent second reference.
wire[15:0]rl,rr_audio;wire refphase;
wire[15:0]ml1=DUAL==1?16'd0:{audio1[10],audio1,4'b0},mr1=DUAL==1?16'd0:{a1r[10],a1r,4'b0};
wire[15:0]ml2=(DUAL==1||DUAL==2)?{audio2[10],audio2,4'b0}:16'd0,mr2=(DUAL==1||DUAL==2)?{a2r[10],a2r,4'b0}:16'd0;
wire[15:0]rml1=DUAL==1?16'd0:{raudio[10],raudio,4'b0},rmr1=DUAL==1?16'd0:{rar[10],rar,4'b0};
wire[15:0]rml2=(DUAL==1||DUAL==2)?{r2l[10],r2l,4'b0}:16'd0,rmr2=(DUAL==1||DUAL==2)?{r2r[10],r2r,4'b0}:16'd0;
AudioMix mix(.ss_last_sample(last_sample_in),.ss_last_valid(last_sample_valid),.clk(clk),.audio_in_l1(ml1),.audio_in_r1(mr1),.audio_in_l2(ml2),.audio_in_r2(mr2),.audio_l(al),.audio_r(ar),.ss_phase_out(audio_phase_out),.ss_phase_in(reset_n?audio_phase_in:1'b0),.ss_phase_set(audio_phase_set||!reset_n));
AudioMix rmix(.clk(clk),.audio_in_l1(rml1),.audio_in_r1(rmr1),.audio_in_l2(rml2),.audio_in_r2(rmr2),.audio_l(rl),.audio_r(rr_audio),.ss_phase_out(refphase),.ss_phase_in(1'b0),.ss_phase_set(!reset_n));
wire[177:0]raw2=DUAL==3?178'd0:{psg2_out,psg2_ext_out,div2,audio2,a2r};
wire[177:0]rraw2=DUAL==3?178'd0:{r2cfg,r2ext,r2div,r2l,r2r};
wire[360:0]raw={clkd,psg_out,psg_ext_out,psg_div_out,audio1,a1r,raw2};
wire[360:0]rraw={rclkd,rpsgcfg,rpsgext,rpsgdiv,raudio,rar,rraw2};
reg[31:0]oracle[0:N-1];reg[360:0]raw_oracle[0:N-1];reg phase_oracle[0:N-1];reg[63:0]image_copy[0:12287];
integer edge_window=0;
always@(posedge clk)begin
 if(dut.state==37&&vb&&x<256&&cpu_ce&&!cm1&&!cmreq&&z80_iset==0&&!storage_busy)edge_window=5;
 if(edge_window>0)begin
 $display("RAW_EDGE_PRE cycle%0d state%0d freeze%b clkd%0d rawCE%b gatedCE%b refCE%b cen16%b/%b div%0d/%0d cnt%0d/%0d snd%0d/%0d",cycle,dut.state,ss_freeze,clkd,ce_cpu,psg1.clk_en,rpsg.clk_en,psg1.cen_16,rpsg.cen_16,psg_div_out,rpsgdiv,psg1.u_tone0.cnt,rpsg.u_tone0.cnt,audio1,raudio);
 #1;$display("RAW_EDGE_POST cycle%0d freeze%b cen16%b/%b div%0d/%0d cnt%0d/%0d snd%0d/%0d ext%h/%h",cycle,ss_freeze,psg1.cen_16,rpsg.cen_16,psg_div_out,rpsgdiv,psg1.u_tone0.cnt,rpsg.u_tone0.cnt,audio1,raudio,psg_ext_out,rpsgext);
 edge_window--;
 end
end
integer fd,k,j,pass,scan,events=0,changed_pairs=0;reg[31:0]last_pair;reg[31:0]last_ref_pair;
function[15:0]clip(input[15:0]a,input[15:0]b);reg signed[16:0]v;begin v=$signed(a)+$signed(b);clip=(v[16]!=v[15])?(v[16]?16'h8000:16'h7fff):v[15:0];end endfunction
always@(posedge clk)begin
 if(BUS&&!ss_freeze&&!ciq&&!cwr&&ca[7:0]==6)mux_control<=co;
 if(BUS&&!riq&&!rwr&&ra[7:0]==6)rmux<=ro;
 if(dut.state==41&&dut.do_save)begin
 if({al,ar}!=={clip(ml1,ml2),clip(mr1,mr2)})$fatal(1,"historical mixer cache at accepted ARM: requires additional state");
 $display("ARM_BOUNDARY cycle%0d divider%0d phase%b outputs%h/%h raw%h",cycle,clkd,audio_phase_out,al,ar,raw);
 end
end
task put2(input[7:0]v);begin pd2=v;pwr2=0;repeat(31)tick;pwr2=1;repeat(31)tick;end endtask
task program_sound;begin
put(8'h86);put(8'h00);put(8'h90);
put2(8'hc9);put2(8'h00);put2(8'hd3);
if(PAT==1)begin put(8'h9f);put(8'hc6);put(8'h00);put(8'he7);put(8'hf0);end
if(PAT==2||PAT==3)begin put(8'hc6);put(8'h00);put(8'he7);put(8'hf3);end
if(PAT==3)begin put(8'ha9);put(8'h00);put(8'hb5);put(8'hd8);end
if(PAT==6)put(8'h9f);
if(HISTORY)begin put(8'h9f);put(8'h90);end
case(ROUTE)1:begin mux_control=8'hf1;rmux=8'hf1;end 2:begin mux_control=8'h1f;rmux=8'h1f;end 3:begin mux_control=8'hf0;rmux=8'hf0;end 4:begin mux_control=8'h0f;rmux=8'h0f;end endcase
end endtask
task future(input integer n,input bit reference_run);begin
// Identical logical-time future writes, reset after every LOAD.
if((PAT==4||PAT==6||PAT==7)&&n==500)begin pd=PAT==7?8'h9f:8'h90;pwr=0;end
if((PAT==4||PAT==6||PAT==7)&&n==531)pwr=1;
if(PAT==4&&n==900)begin pd=8'h9a;pwr=0;end
if(PAT==4&&n==931)pwr=1;
if(PAT==5&&n==500)begin pd=8'h89;pwr=0;end
if(PAT==5&&n==531)pwr=1;
if(ROUTE==5&&n==501)begin mux_control=8'h0f;rmux=8'h0f;end
if(ROUTE==5&&n==900)begin mux_control=8'hf0;rmux=8'hf0;end
if(PAUSE==3&&n==100)joy=1;
if(PAUSE==3&&n==104)joy=0;
end endtask
initial begin
for(j=0;j<12288;j=j+1)mem[j]=0;
systeme=DUAL!=3;ss_game_id=32'h12345678;repeat(BOOT)tick;reset_n=1;repeat(2)tick;program_sound;
if(PAUSE)begin while(!(vb&&x==200))tick;button;wait(paused);repeat(64)tick;end
if(SEEK)storage_busy=1;request(1);
if(SEEK)begin while(!(dut.state==37&&vb&&x<256&&cpu_ce&&!cm1&&!cmreq&&z80_iset==0&&clkd==(SEEK==30?0:SEEK)&&(DIVSEEK<0||psg_div_out==DIVSEEK)))tick;storage_busy=0;end
wait(ss_freeze);#0.01;
$display("CAPTURE pat%0d route%0d dual%0d boot%0d paused%b phase%b div%0d cycle%0d",PAT,ROUTE,DUAL,BOOT,paused,audio_phase_out,psg_div_out,cycle);
if(REF)begin
fd=$fopen("reference.dat","w");last_ref_pair=0;
for(k=0;k<N;k=k+1)begin @(posedge clk);#1;
if($isunknown({rl,rr_audio,rraw,refphase}))$fatal(1,"unknown reference");
$fdisplay(fd,"%h %h %b",{rl,rr_audio},rraw,refphase);
if({rl,rr_audio}!=last_ref_pair)changed_pairs++;last_ref_pair={rl,rr_audio};
future(k,1);end
$fclose(fd);$display("PASS MATRIX REFERENCE samples%0d changed%0d",N,changed_pairs);$finish;
end
fd=$fopen("reference.dat","r");if(!fd)$fatal(1,"missing oracle");
for(k=0;k<N;k=k+1)begin scan=$fscanf(fd,"%h %h %b",oracle[k],raw_oracle[k],phase_oracle[k]);if(scan!=3)$fatal(1,"short oracle");end $fclose(fd);
wait(!ss_freeze);
for(j=0;j<12288;j=j+1)begin if($isunknown(mem[j]))$fatal(1,"unknown complete image %h",j);image_copy[j]=mem[j];end
$writememh("image_save.hex",mem);
for(pass=0;pass<=REPLAYS;pass=pass+1)begin
qmode=0;
for(k=0;k<N;k=k+1)begin @(posedge clk);#1;
if(raw!==raw_oracle[k])$fatal(1,"raw PSG/div mismatch pass%0d k%0d actual%h expected%h",pass,k,raw,raw_oracle[k]);
if({al,ar}!==oracle[k]||audio_phase_out!==phase_oracle[k])$fatal(1,"audio mismatch pass%0d k%0d audio%h expected%h phase%b/%b",pass,k,{al,ar},oracle[k],audio_phase_out,phase_oracle[k]);
if(k<8)$display("FIRST pass%0d k%0d clkd%0d raw%h inputs%h/%h/%h/%h output%h/%h phase%b paused%b",pass,k,clkd,raw,ml1,mr1,ml2,mr2,al,ar,audio_phase_out,paused);
future(k,0);end
$display("PASS SUFFIX pass%0d samples%0d progressCPU%0d PSG%0d paused%b",pass,N,progress_cpu,progress_psg,paused);
for(j=0;j<12288;j=j+1)if(mem[j]!==image_copy[j])$fatal(1,"image mutated");
if(pass<REPLAYS)begin
qmode=1;put(8'h9f);put2(8'hdf);repeat(777+pass*103)tick;put(8'h80|pass);put(8'h90|pass);put2(8'hd0|pass);repeat(1000)tick;
if(PAUSE==3&&!paused)begin button;wait(paused);repeat(64)tick;end
$display("Q pass%0d raw%h outputs%h/%h",pass,raw,al,ar);
request(0);wait(ss_freeze);wait(!ss_freeze);
end end
$writememh("image.hex",mem);$display("PASS MATRIX replays%0d N%0d",REPLAYS,N);$finish;
end
initial begin #2000000000;$fatal(1,"matrix watchdog state%0d",dut.state);end
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
integer pending_replays=0;
always@(posedge ss_freeze)pending_replays=0;
always@(negedge clk)if(audio_pending_tick)begin
 pending_replays++;
 if(pending_replays>1||ss_freeze||cpu_prepare||audio_ext_set)$fatal(1,"pending event replayed outside single guest release edge");
 $display("PENDING_REPLAY cycle%0d savedPhase%0d savedDiv%0d active%b",cycle,dut.phase_snap,dut.audio_div_snap,dut.capture_tick_snap);
end
endmodule
