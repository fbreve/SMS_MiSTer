`timescale 1ns/1ps
module pause_tb;wire[135:0]refvdp_regs,refvdp2_regs;parameter CASE=0,KEEP=0,FULL=0,STALL=0,OFFSET=0,DELAY=6;
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
reg [10:0] audio_control_out = '0;
wire [10:0] audio_control_in;
wire audio_quiescent;
reg audio_phase_out = '0;
wire audio_phase_in;
wire audio_ext_set;
wire audio_phase_set;
reg [63:0] mapper_out = '0;
wire [63:0] mapper_in;
wire mapper_set;
reg [95:0] evolution_out = '0;
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
savestates dut(.bg_out(139'd0),.bg2_out(139'd0),.bg_in(),.bg2_in(),.bg_valid(),.ss_cpu_prepare(cpu_prepare),.z80_replay(replay),.z80_tick_active(actual_tick),.z80_replay_t2(replay_t2),
 .clock_phase(clkd==25?2'd3:clkd==20?2'd2:clkd==10?2'd1:2'd0),.clock_phase_in(phase_in),.clock_phase_set(phase_set),.clock_phase_ready(phase_ready),
 .sprite_out(4778'd0),.sprite2_out(4778'd0),.sprite_in(),.sprite2_in(),.sprite_valid(),.z80_restart(restart_out),.z80_nmi(3'b001),.mapper_history_out(18'h0ffff),.mapper_history_in(),.clk(clk),.reset_n(reset_n),.ss_save(ss_save),.ss_load(ss_load),.ss_slot(ss_slot),.ss_bios_mode(ss_bios_mode),.ss_game_id(ss_game_id),.ss_freeze(ss_freeze),.ss_capture_progress(ss_capture_progress),.vblank(vblank),.x(x),.z80_reg(z80_reg),.z80_dir(z80_dir),.z80_set(z80_set),.z80_m1_n(z80_m1_n),.z80_mreq_n(z80_mreq_n),.z80_iset(z80_iset),.cpu_ce(cpu_ce),.vdp_ce(vdp_ce),.pix_ce(pix_ce),.sp_ce(sp_ce),.vdp_regs(vdp_regs),.vdp_regs_in(vdp_regs_in),.vdp_regs_set(vdp_regs_set),.cram_out(cram_out),.cram_A(cram_A),.cram_D(cram_D),.cram_wr(cram_wr),.vram_en(vram_en),.vram_A(vram_A),.vram_D(vram_D),.vram_WE(vram_WE),.vram_WA(vram_WA),.vram_WD(vram_WD),.psg_out(psg_out),.psg_in(psg_in),.psg_set(psg_set),.psg_ext_out(psg_ext_out),.psg2_ext_out(psg2_ext_out),.psg_ext_in(psg_ext_in),.psg2_ext_in(psg2_ext_in),.psg_div_out(psg_div_out),.psg_div_in(psg_div_in),.audio_control_out(audio_control_out),.audio_control_in(audio_control_in),.audio_quiescent(audio_quiescent),.audio_phase_out(audio_phase_out),.audio_phase_in(audio_phase_in),.audio_ext_set(audio_ext_set),.audio_phase_set(audio_phase_set),.mapper_out(mapper_out),.mapper_in(mapper_in),.mapper_set(mapper_set),.evolution_out(evolution_out),.evolution_in(evolution_in),.evolution_set(evolution_set),.storage_busy(storage_busy),.ss_busy(ss_busy),.eeprom_present(eeprom_present),.eeprom_ext_out(eeprom_ext_out),.eeprom_ext_in(eeprom_ext_in),.eeprom_full(eeprom_full),.nvram_refill(nvram_refill),.gun_out(gun_out),.gun_in(gun_in),.gun_set(gun_set),.gun_valid(gun_valid),.paddle_out(paddle_out),.paddle_in(paddle_in),.paddle_set(paddle_set),.paddle_valid(paddle_valid),.tap_out(tap_out),.tap_in(tap_in),.tap_set(tap_set),.tap_valid(tap_valid),.sc_ram_size(sc_ram_size),.sc_ram_restored(sc_ram_restored),.eeprom_out(eeprom_out),.eeprom_in(eeprom_in),.eeprom_set(eeprom_set),.wram_A(wram_A),.wram_D(wram_D),.wram_WE(wram_WE),.wram_WA(wram_WA),.wram_WD(wram_WD),.nvram_A(nvram_A),.nvram_D(nvram_D),.nvram_WE(nvram_WE),.nvram_WA(nvram_WA),.nvram_WD(nvram_WD),.systeme(systeme),.vdp2_regs(vdp2_regs),.vdp2_regs_in(vdp2_regs_in),.vdp2_regs_set(vdp2_regs_set),.cram2_out(cram2_out),.cram2_A(cram2_A),.cram2_D(cram2_D),.cram2_wr(cram2_wr),.vram2_en(vram2_en),.vram2_A(vram2_A),.vram2_D(vram2_D),.vram2_WE(vram2_WE),.vram2_WA(vram2_WA),.vram2_WD(vram2_WD),.psg2_out(psg2_out),.psg2_in(psg2_in),.psg2_set(psg2_set),.md_out(md_out),.md_in(md_in),.md_set(md_set),.md_valid(md_valid),.gg_out(gg_out),.gg_in(gg_in),.gg_set(gg_set),.io_out(io_out),.io_in(io_in),.io_set(io_set),.video_state_out(video_state_out),.video_state_in(video_state_in),.video_state_set(video_state_set),.DDRAM_ADDR(DDRAM_ADDR),.DDRAM_DIN(DDRAM_DIN),.DDRAM_BE(DDRAM_BE),.DDRAM_WE(DDRAM_WE),.DDRAM_DOUT(DDRAM_DOUT),.DDRAM_DOUT_READY(DDRAM_DOUT_READY),.DDRAM_RD(DDRAM_RD),.DDRAM_BURSTCNT(DDRAM_BURSTCNT),.DDRAM_BUSY(DDRAM_BUSY));
always #5 clk=~clk;
reg [63:0] mem[0:12287]; integer cycle=0, pending=0; reg [28:0] readaddr;
integer writes=0,reads=0; reg restored=0; reg [135:0] seen1,seen2;
reg ce_cpu=0,ce_pix=0,ce_vdp=0,ce_sp=0;
assign cpu_ce=ce_pix;assign vdp_ce=ce_vdp;assign pix_ce=ce_pix;assign sp_ce=ce_sp;
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
video video1(.clk(clk),.ce_pix(ce_pix),.pal(1'b0),.border(1'b0),.ggres(1'b0),.mask_column(1'b0),.cut_mask(1'b0),.smode_M1(1'b0),.smode_M2(1'b0),.smode_M3(1'b0),.smode_M4(1'b1),.video_state_out(video_state_out),.video_state_in(video_state_in),.video_state_set(video_state_set),.x(x),.y(y),.vcounter_cpu(),.hsync(),.vsync(),.hblank(hb),.vblank(vb));
video videoref(.clk(clk),.ce_pix(ce_pix&&!holdref),.pal(1'b0),.border(1'b0),.ggres(1'b0),.mask_column(1'b0),.cut_mask(1'b0),.smode_M1(1'b0),.smode_M2(1'b0),.smode_M3(1'b0),.smode_M4(1'b1),.video_state_out(rvideo),.video_state_in(22'd0),.video_state_set(1'b0),.x(rx),.y(ry),.vcounter_cpu(),.hsync(),.vsync(),.hblank(rhb),.vblank(rvb));
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
T80s #(.T2Write(0)) cpu(.RESET_n(reset_n),.CLK(clk),.CEN((ce_pix&&!ss_freeze&&(!paused||ss_capture_progress))||(ce_cpu&&cpu_prepare&&replay)),.WAIT_n(1'b1),.INT_n(1'b1),.NMI_n(1'b1),.BUSRQ_n(1'b1),.M1_n(cm1),.MREQ_n(cmreq),.IORQ_n(ciq),.RD_n(crd),.WR_n(cwr),.RFSH_n(),.HALT_n(),.BUSAK_n(),.OUT0(1'b0),.A(ca),.DI(rom(ca)),.DO(co),.REG(z80_reg),.NMIEnable(1'b1),.NMIDIR(dut.z80_nmi_dir),.NMIValid(dut.z80_nmi_valid),.NMIHold(dut.z80_nmi_hold),.RestoreHold(ss_freeze),.ReplayT2(replay_t2),.NMIReplay(replay),.RestartContext(restart_out),.RestartDIR(dut.z80_restart_dir),.RestartValid(dut.z80_restart_valid),.DIRSet(z80_set),.DIR(z80_dir),.ISet_out(z80_iset));
T80s #(.T2Write(0)) rcpu(.RESET_n(reset_n),.CLK(clk),.CEN((ce_pix&&!holdref&&(!rpaused||ref_progress))),.WAIT_n(1'b1),.INT_n(1'b1),.NMI_n(1'b1),.BUSRQ_n(1'b1),.M1_n(rm1),.MREQ_n(rmreq),.IORQ_n(riq),.RD_n(rrd),.WR_n(rwr),.RFSH_n(),.HALT_n(),.BUSAK_n(),.OUT0(1'b0),.A(ra),.DI(rom(ra)),.DO(ro),.REG(rr),.DIRSet(1'b0),.DIR(230'd0),.ISet_out(riset));
generate if(FULL)begin:fullvdps
vdp vdp1(.clk_sys(clk),.ce_vdp((ce_vdp&&!ss_freeze)),.ce_pix((ce_pix&&!ss_freeze)),.ce_sp((ce_sp&&!ss_freeze)),.gg(1'b0),.ggres(1'b0),.se_bank(1'b0),.sp64(1'b0),.HL(1'b0),.mask_line_irq(1'b0),.capture_cpu_edges(1'b0),.legacy_ext_nt(1'b0),.RD_n(1'b1),.WR_n(1'b1),.IRQ_n(),.WR_direct(1'b0),.A_direct(6'b0),.A(8'h00),.D_in(8'b0),.D_out(),.x(x),.y(y),.vcounter_cpu(8'b0),.color(),.palettemode(1'b0),.y1(),.mask_column(),.black_column(1'b0),.smode_M1(),.smode_M2(),.smode_M3(),.smode_M4(),.ysj_quirk(1'b0),.reset_n(reset_n),.ss_regs_out(vdp_regs),.ss_regs_in(vdp_regs_in),.ss_regs_set(vdp_regs_set),.ss_cram_out(),.ss_cram_wr(1'b0),.ss_cram_A(5'b0),.ss_cram_D(12'b0),.ss_vram_en(1'b0),.ss_vram_A(15'b0),.ss_vram_D(),.ss_vram_WE(1'b0),.ss_vram_WA(15'b0),.ss_vram_WD(8'b0));
vdp refvdp1(.clk_sys(clk),.ce_vdp((ce_vdp&&!holdref)),.ce_pix((ce_pix&&!holdref)),.ce_sp((ce_sp&&!holdref)),.gg(1'b0),.ggres(1'b0),.se_bank(1'b0),.sp64(1'b0),.HL(1'b0),.mask_line_irq(1'b0),.capture_cpu_edges(1'b0),.legacy_ext_nt(1'b0),.RD_n(1'b1),.WR_n(1'b1),.IRQ_n(),.WR_direct(1'b0),.A_direct(6'b0),.A(8'h00),.D_in(8'b0),.D_out(),.x(rx),.y(ry),.vcounter_cpu(8'b0),.color(),.palettemode(1'b0),.y1(),.mask_column(),.black_column(1'b0),.smode_M1(),.smode_M2(),.smode_M3(),.smode_M4(),.ysj_quirk(1'b0),.reset_n(reset_n),.ss_regs_out(refvdp_regs),.ss_regs_in(136'd0),.ss_regs_set(1'b0),.ss_cram_out(),.ss_cram_wr(1'b0),.ss_cram_A(5'b0),.ss_cram_D(12'b0),.ss_vram_en(1'b0),.ss_vram_A(15'b0),.ss_vram_D(),.ss_vram_WE(1'b0),.ss_vram_WA(15'b0),.ss_vram_WD(8'b0));
vdp vdp2(.clk_sys(clk),.ce_vdp((ce_vdp&&!ss_freeze)),.ce_pix((ce_pix&&!ss_freeze)),.ce_sp((ce_sp&&!ss_freeze)),.gg(1'b0),.ggres(1'b0),.se_bank(1'b1),.sp64(1'b0),.HL(1'b0),.mask_line_irq(1'b0),.capture_cpu_edges(1'b0),.legacy_ext_nt(1'b0),.RD_n(1'b1),.WR_n(1'b1),.IRQ_n(),.WR_direct(1'b0),.A_direct(6'b0),.A(8'h00),.D_in(8'b0),.D_out(),.x(x),.y(y),.vcounter_cpu(8'b0),.color(),.palettemode(1'b0),.y1(),.mask_column(),.black_column(1'b0),.smode_M1(),.smode_M2(),.smode_M3(),.smode_M4(),.ysj_quirk(1'b0),.reset_n(reset_n),.ss_regs_out(vdp2_regs),.ss_regs_in(vdp2_regs_in),.ss_regs_set(vdp2_regs_set),.ss_cram_out(),.ss_cram_wr(1'b0),.ss_cram_A(5'b0),.ss_cram_D(12'b0),.ss_vram_en(1'b0),.ss_vram_A(15'b0),.ss_vram_D(),.ss_vram_WE(1'b0),.ss_vram_WA(15'b0),.ss_vram_WD(8'b0));
vdp refvdp2(.clk_sys(clk),.ce_vdp((ce_vdp&&!holdref)),.ce_pix((ce_pix&&!holdref)),.ce_sp((ce_sp&&!holdref)),.gg(1'b0),.ggres(1'b0),.se_bank(1'b1),.sp64(1'b0),.HL(1'b0),.mask_line_irq(1'b0),.capture_cpu_edges(1'b0),.legacy_ext_nt(1'b0),.RD_n(1'b1),.WR_n(1'b1),.IRQ_n(),.WR_direct(1'b0),.A_direct(6'b0),.A(8'h00),.D_in(8'b0),.D_out(),.x(rx),.y(ry),.vcounter_cpu(8'b0),.color(),.palettemode(1'b0),.y1(),.mask_column(),.black_column(1'b0),.smode_M1(),.smode_M2(),.smode_M3(),.smode_M4(),.ysj_quirk(1'b0),.reset_n(reset_n),.ss_regs_out(refvdp2_regs),.ss_regs_in(136'd0),.ss_regs_set(1'b0),.ss_cram_out(),.ss_cram_wr(1'b0),.ss_cram_A(5'b0),.ss_cram_D(12'b0),.ss_vram_en(1'b0),.ss_vram_A(15'b0),.ss_vram_D(),.ss_vram_WE(1'b0),.ss_vram_WA(15'b0),.ss_vram_WD(8'b0));
end else begin:lightvdps assign vdp_regs=0;assign vdp2_regs=0;end endgenerate
wire pq1,pq2;wire[3:0]div2;wire signed[10:0]audio1,audio2;reg pwr=1;reg[7:0]pd=0;
assign audio_quiescent=pq1&&pq2;
jt89 psg1(.clk(clk),.clk_en(ce_cpu&&!ss_freeze&&(!paused||ss_capture_progress)),.rst(!reset_n),.wr_n(pwr),.din(pd),.mux(8'hff),.soundL(audio1),.soundR(),.ready(),.ss_out(psg_out),.ss_set(psg_set),.ss_in(psg_in),.ss_ext_out(psg_ext_out),.ss_ext_in(psg_ext_in),.ss_ext_set(audio_ext_set),.ss_div_out(psg_div_out),.ss_div_in(psg_div_in),.ss_quiescent(pq1));
jt89 psg2(.clk(clk),.clk_en(ce_cpu&&!ss_freeze&&(!paused||ss_capture_progress)),.rst(!reset_n),.wr_n(pwr),.din(pd),.mux(8'hff),.soundL(audio2),.soundR(),.ready(),.ss_out(psg2_out),.ss_set(psg2_set),.ss_in(psg2_in),.ss_ext_out(psg2_ext_out),.ss_ext_in(psg2_ext_in),.ss_ext_set(audio_ext_set),.ss_div_out(div2),.ss_div_in(psg_div_in),.ss_quiescent(pq2));
wire[95:0]rpsgext;wire[55:0]rpsgcfg;wire[3:0]rpsgdiv;wire signed[10:0]raudio;
jt89 rpsg(.clk(clk),.clk_en(ce_cpu&&!holdref&&(!rpaused||ref_progress)),.rst(!reset_n),.wr_n(pwr),.din(pd),.mux(8'hff),.soundL(raudio),.soundR(),.ready(),.ss_out(rpsgcfg),.ss_set(1'b0),.ss_in(56'd0),.ss_ext_out(rpsgext),.ss_ext_in(96'd0),.ss_ext_set(1'b0),.ss_div_out(rpsgdiv),.ss_div_in(4'd0),.ss_quiescent());
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
 held=1;holdref=1;phase_at_freeze={paused,pp,up};freeze_start=cycle;
 if(ss_capture_progress)$fatal(1,"override persists at freeze");
 $display("FREEZE case%0d cycle%0d phase%0b",CASE,cycle,phase_at_freeze);
end
always@(negedge ss_freeze)if(held)begin
 holdref=0;transfers=transfers+1;freeze_clocks=cycle-freeze_start;quiet=4;
 $display("RELEASE case%0d cycle%0d transport%0d phase%0b reference%0b",CASE,cycle,freeze_clocks,{paused,pp,up},{rpaused,rpp,rup});
end
always@(negedge clk)begin #2;
 if(quiet>0)quiet=quiet-1;
 if(compare_machine&&reset_n&&!ss_freeze&&quiet==0)begin
  checks=checks+1;
  if({paused,pp,up}!=={rpaused,rpp,rup})$fatal(1,"logical host phase mismatch cycle%0d DUT%0b ref%0b",cycle,{paused,pp,up},{rpaused,rpp,rup});
  if(z80_reg!==rr||ca!==ra||co!==ro||cm1!==rm1||cmreq!==rmreq||crd!==rrd||cwr!==rwr||ciq!==riq)
   $fatal(1,"CPU registers/bus mismatch cycle%0d DUT%h ref%h bus%h/%h progress%b/%b",cycle,z80_reg,rr,ca,ra,ss_capture_progress,ref_progress);
  if(psg_out!==rpsgcfg||psg_ext_out!==rpsgext||psg_div_out!==rpsgdiv||audio1!==raudio||psg2_ext_out!==psg_ext_out||audio2!==audio1)
   $fatal(1,"PSG state/audio mismatch cycle%0d ext%h/%h div%0d/%0d audio%0d/%0d",cycle,psg_ext_out,rpsgext,psg_div_out,rpsgdiv,audio1,raudio);
  if(video_state_out!==rvideo)$fatal(1,"beam mismatch cycle%0d",cycle);
  if(FULL&&(vdp_regs!==refvdp_regs||vdp2_regs!==refvdp2_regs))$fatal(1,"dual-VDP architectural state mismatch cycle%0d",cycle);
 end
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
initial begin
 systeme=1;ss_game_id=32'h12345678;reset_n=0;
 if(CASE==3||CASE==5||CASE==6||CASE==9)repeat(36)tick;else repeat(DELAY)tick;
 reset_n=1;put(8'h8d);put(8'h02);put(8'h91);put(8'he7);put(8'hf3);
 compare_machine=1;
 while(!(frame>=1&&vb&&x==200))tick;
 if(CASE==3||CASE==4||CASE==5||CASE==6||CASE==9||CASE==16||CASE==17||CASE==18)begin
  button;wait(paused);repeat(64)tick;
  $display("NATURAL PAUSED case%0d bus%h M1%b MREQ%b ISet%0d phase%0b",CASE,ca,cm1,cmreq,z80_iset,{paused,pp,up});
  if(CASE==3&&(cm1||cmreq||z80_iset!=0))$fatal(1,"qualifying paused phase not reached");
  if(CASE==4&&!cm1&&!cmreq&&z80_iset==0)$fatal(1,"previous non-M1 phase not reached");
  if(CASE==5)begin button;wait(!paused);tick;end
  if(CASE==9)begin wait(vb);button;end
 end
 if(CASE==1||CASE==8)button;
 if(CASE==22)begin joy=1;repeat(3)tick;end
 if(CASE==10)begin request(1);repeat(OFFSET)tick;button;end
 else if(CASE==17)begin request(1);repeat(OFFSET)tick;button;end
 else if(CASE==18)begin request(1);wait(ss_capture_progress);repeat(OFFSET)tick;button;end
 else if(CASE==2)begin
  request(1);while(!(dut.state==37&&cpu_ce&&!cm1&&!cmreq&&z80_iset==0&&vb&&x<256))tick;
  joy=1;tick;joy=0;
 end else request(1);
 if(CASE==11||CASE==12||CASE==13)begin wait(ss_freeze);repeat(OFFSET+1)tick;button;end
 if(CASE==23)begin wait(ss_freeze);joy=1;end
 if(CASE==14)fork
  begin wait(ss_freeze);wait(!ss_freeze);joy=1;repeat(2)tick;joy=0;end
  begin complete;end
 join
 else complete;
 if(CASE==6)button;
 if(CASE==15)begin button;repeat(OFFSET+1)tick;button;end
 if(max_latency>1800000)$fatal(1,"capture latency exceeded two frames");
 if(CASE==16)repeat(10000)tick;else repeat(1000000)tick;
 if(CASE==4&&progress_cpu==0)$fatal(1,"stalled-phase override never exercised");
 if(CASE==3&&progress_cpu!=0)$fatal(1,"qualifying pause unnecessarily executed");
 $display("SAVE ONLY EQUIVALENT case%0d checks%0d CPU%h PSG%h audio%0d phase%0b",CASE,checks,z80_reg,psg_ext_out,audio1,{paused,pp,up});
 if(CASE==22||CASE==23)begin
  if(CASE==22&&{paused,pp,up}!==3'b100)$fatal(1,"held pre-capture input lost pending pause");
  if(CASE==23&&{paused,pp,up}!==0)$fatal(1,"held frozen input synthesized a toggle");
  joy=0;repeat(3)tick;button;
  if(CASE==22)wait(!paused);else wait(paused);
  repeat(10000)tick;
 end
 if(FULL)begin
  if(!paused)begin button;wait(paused);repeat(32)tick;end
  button;wait(!paused);repeat(10000)tick;
  button;wait(paused);repeat(10000)tick;
  $display("FULL DUAL VDP repeated toggles equal, VDP%h/%h reference%h/%h",vdp_regs,vdp2_regs,refvdp_regs,refvdp2_regs);
 end
 if(CASE==7||CASE==8||CASE==20||CASE==21||CASE==24)begin
  // Keep CURRENT host phase across loads, deliberately opposite to save phase.
  if(CASE==7||CASE==24)begin button;wait(paused);repeat(64)tick;end
  else if(CASE==8)begin if(!paused)$fatal(1,"saved pending phase never applied");button;wait(!paused);repeat(64)tick;end
  else if(CASE==20)begin button;wait(paused);wait(vb);button;end
  else begin while(!(vb&&x==200))tick;button;end
  compare_machine=0;
  for(i=0;i<2;i=i+1)begin
   request(0);
   fork begin complete;end begin wait(ss_freeze);wait(!ss_freeze);sample_replay(i);end begin if(CASE==24)begin wait(ss_freeze);joy=1;end end join
   if((CASE==7||CASE==24)&&{paused,pp,up}!==3'b100)$fatal(1,"load rewound current paused UI phase");
   if(CASE==8&&{paused,pp,up}!==3'b000)$fatal(1,"load restored historical pending phase");
   if(CASE==20&&{paused,pp,up}!==3'b101)$fatal(1,"load consumed current unpause pending");
   if(CASE==21&&{paused,pp,up}!==3'b010)$fatal(1,"load consumed current pause pending");
   $display("CURRENT HOST LOAD case%0d pass%0d phase%0b CPU%h PSG%h div%0d audio%0d",CASE,i,{paused,pp,up},z80_reg,psg_ext_out,psg_div_out,audio1);
  end
  if(CASE==24)begin joy=0;repeat(3)tick;button;if(!up||!paused)$fatal(1,"fresh edge after held-load history not recognized");wait(!paused);repeat(10000)tick;end
 end
 $display("PASS FIXED case%0d stall%0d full%0d delay%0d offset%0d accepts%0d transfers%0d checks%0d worstLatency%0d overrideCPU%0d overridePSG%0d",CASE,STALL,FULL,DELAY,OFFSET,accepts,transfers,checks,max_latency,progress_cpu,progress_psg);$finish;
end
initial begin #1000000000;$fatal(1,"watchdog case%0d state%0d phase%0b bus%h cooldown%0d loop%0d",CASE,dut.state,{paused,pp,up},ca,dut.op_cooldown,i);end

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
endmodule
