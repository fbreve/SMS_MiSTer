`timescale 1ns/1ps
module vdp_tb;
reg extra_profiles=0;reg[31:0]rng=32'h9e3779b9;reg[4777:0]expected1,expected2;wire[4799:0]padded1={22'd0,expected1},padded2={22'd0,expected2};reg[63:0]image_copy[0:12287];integer compared_cycles=0;
 parameter GG=1,PAL=0,REQUEST_X=40,SPRITE_X=120,SPRITES=2,REPLAYS=3,REFERENCE=0,PROTO=1,TURBO=1,SAVE_ONLY=0,DIAGNOSTIC=0,SAVE_PHASE=-1,COMMON_PHASE=0,FIX=1,SCAN_MASK=0,SLOTS=8,EXT_REFERENCE=0,PHASE_SWEEP=0,WARMUP=0,PAUSE_CAPTURE=0,NATURAL_PHASE=0;
reg clk = '0;
reg reset_n = '0;
reg ss_save = '0;
reg ss_load = '0;
reg [1:0] ss_slot = '0;
reg ss_bios_mode = '0;
reg [31:0] ss_game_id = '0;
wire ss_freeze;wire ss_capture_progress;
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
wire [383:0] cram_out;
wire [4:0] cram_A;
wire [11:0] cram_D;
wire cram_wr;
wire vram_en;
wire [14:0] vram_A;
wire [7:0] vram_D;
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
reg audio_phase_out = 1'b1;
wire audio_phase_in;
wire audio_ext_set;
wire audio_phase_set;
reg [63:0] mapper_out = '0;
wire [63:0] mapper_in;
wire mapper_set;
reg [159:0] evolution_out = '0;
wire [159:0] evolution_in;
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
wire [7:0] wram_D;
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
localparam N=74*SLOTS;
wire[N+41:0]g06_live;wire[4777:0]sprite_restored;wire sprite_valid;
wire cpu_prepare,phase_set,replay,replay_t2;wire[1:0]phase_in;reg phase_ready=0;reg[4:0]clkd=0;reg logical_pause=0;
reg[138:0] bg_live=0,bg2_live=0;wire[138:0] bg_restored,bg2_restored;wire bg_valid;
reg expect_background=1;
reg [4777:0] random_sprite1=0,random_sprite2=0;
wire  golden_ss_freeze;
wire  golden_ss_cpu_prepare;
wire  golden_z80_replay_t2;
wire [1:0] golden_clock_phase_in;
wire  golden_clock_phase_set;
wire [138:0] golden_bg_in;
wire [138:0] golden_bg2_in;
wire  golden_bg_valid;
wire [4777:0] golden_sprite_in;
wire [4777:0] golden_sprite2_in;
wire [4777:0] new_sprite2_in;
wire  golden_sprite_valid;
wire [2:0] golden_z80_restart_dir;
wire [2:0] new_z80_restart_dir;
wire  golden_z80_restart_valid;
wire  new_z80_restart_valid;
wire [2:0] golden_z80_nmi_dir;
wire [2:0] new_z80_nmi_dir;
wire  golden_z80_nmi_valid;
wire  new_z80_nmi_valid;
wire  golden_z80_nmi_hold;
wire  new_z80_nmi_hold;
wire [229:0] golden_z80_dir;
wire  golden_z80_set;
wire [135:0] golden_vdp_regs_in;
wire  golden_vdp_regs_set;
wire [4:0] golden_cram_A;
wire [11:0] golden_cram_D;
wire  golden_cram_wr;
wire  golden_vram_en;
wire [14:0] golden_vram_A;
wire  golden_vram_WE;
wire [14:0] golden_vram_WA;
wire [7:0] golden_vram_WD;
wire [55:0] golden_psg_in;
wire  golden_psg_set;
wire [95:0] golden_psg_ext_in;
wire [95:0] golden_psg2_ext_in;
wire [3:0] golden_psg_div_in;
wire [10:0] golden_audio_control_in;
wire  golden_audio_phase_in;
wire  golden_audio_ext_set;
wire  golden_audio_phase_set;
wire  golden_audio_pending_tick;
wire  new_audio_pending_tick;
wire [17:0] golden_mapper_history_in;
wire [17:0] new_mapper_history_in;
wire [63:0] golden_mapper_in;
wire  golden_mapper_set;
wire [159:0] golden_evolution_in;
wire  golden_evolution_set;
wire  golden_ss_busy;
wire  golden_ss_capture_progress;
wire [127:0] golden_eeprom_ext_in;
wire  golden_eeprom_full;
wire  golden_nvram_refill;
wire [45:0] golden_gun_in;
wire  golden_gun_set;
wire  golden_gun_valid;
wire [31:0] golden_paddle_in;
wire  golden_paddle_set;
wire  golden_paddle_valid;
wire [18:0] golden_tap_in;
wire  golden_tap_set;
wire  golden_tap_valid;
wire  golden_sc_ram_restored;
wire [63:0] golden_eeprom_in;
wire  golden_eeprom_set;
wire [13:0] golden_wram_A;
wire  golden_wram_WE;
wire [13:0] golden_wram_WA;
wire [7:0] golden_wram_WD;
wire [14:0] golden_nvram_A;
wire  golden_nvram_WE;
wire [14:0] golden_nvram_WA;
wire [7:0] golden_nvram_WD;
wire [135:0] golden_vdp2_regs_in;
wire  golden_vdp2_regs_set;
wire [4:0] golden_cram2_A;
wire [11:0] golden_cram2_D;
wire  golden_cram2_wr;
wire  golden_vram2_en;
wire [14:0] golden_vram2_A;
wire  golden_vram2_WE;
wire [14:0] golden_vram2_WA;
wire [7:0] golden_vram2_WD;
wire [55:0] golden_psg2_in;
wire  golden_psg2_set;
wire [45:0] golden_md_in;
wire  golden_md_set;
wire  golden_md_valid;
wire [127:0] golden_gg_in;
wire  golden_gg_set;
wire [31:0] golden_io_in;
wire  golden_io_set;
wire [21:0] golden_video_state_in;
wire  golden_video_state_set;
wire [28:0] golden_DDRAM_ADDR;
wire [63:0] golden_DDRAM_DIN;
wire [7:0] golden_DDRAM_BE;
wire  golden_DDRAM_WE;
wire  golden_DDRAM_RD;
wire [7:0] golden_DDRAM_BURSTCNT;
savestates #(.TB_FAST(1)) dut(.clk(clk),
.reset_n(reset_n),
.ss_save(ss_save),
.ss_load(ss_load),
.ss_slot(ss_slot),
.ss_bios_mode(ss_bios_mode),
.ss_game_id(ss_game_id),
.ss_freeze(ss_freeze),
.ss_cpu_prepare(cpu_prepare),
.z80_replay(replay),
.z80_tick_active(!logical_pause),
.z80_replay_t2(replay_t2),
.clock_phase(clkd==25?2'd3:clkd==20?2'd2:clkd==10?2'd1:2'd0),
.clock_phase_in(phase_in),
.clock_phase_set(phase_set),
.clock_phase_ready(phase_ready),
.bg_out(bg_live),
.bg2_out(bg2_live),
.bg_in(bg_restored),
.bg2_in(bg2_restored),
.bg_valid(bg_valid),
.sprite_out(random_sprite1),
.sprite2_out(random_sprite2),
.sprite_in(sprite_restored),
.sprite2_in(new_sprite2_in),
.sprite_valid(sprite_valid),
.vblank(vblank),
.x(x),
.z80_restart(restart_out),
.z80_restart_dir(new_z80_restart_dir),
.z80_restart_valid(new_z80_restart_valid),
.z80_nmi(3'b001),
.z80_nmi_dir(new_z80_nmi_dir),
.z80_nmi_valid(new_z80_nmi_valid),
.z80_nmi_hold(new_z80_nmi_hold),
.z80_reg(z80_reg),
.z80_dir(z80_dir),
.z80_set(z80_set),
.z80_m1_n(z80_m1_n),
.z80_mreq_n(z80_mreq_n),
.z80_iset(z80_iset),
.cpu_ce(cpu_ce),
.vdp_ce(vdp_ce),
.pix_ce(pix_ce),
.sp_ce(sp_ce),
.vdp_regs(vdp_regs),
.vdp_regs_in(vdp_regs_in),
.vdp_regs_set(vdp_regs_set),
.cram_out(cram_out),
.cram_A(cram_A),
.cram_D(cram_D),
.cram_wr(cram_wr),
.vram_en(vram_en),
.vram_A(vram_A),
.vram_D(vram_D),
.vram_WE(vram_WE),
.vram_WA(vram_WA),
.vram_WD(vram_WD),
.psg_out(psg_out),
.psg_in(psg_in),
.psg_set(psg_set),
.psg_ext_out(psg_ext_out),
.psg2_ext_out(psg2_ext_out),
.psg_ext_in(psg_ext_in),
.psg2_ext_in(psg2_ext_in),
.psg_div_out(psg_div_out),
.psg_div_in(psg_div_in),
.audio_control_out(audio_control_out),
.audio_control_in(audio_control_in),
.audio_quiescent(audio_quiescent),
.audio_phase_out(audio_phase_out),
.audio_phase_in(audio_phase_in),
.audio_ext_set(audio_ext_set),
.audio_phase_set(audio_phase_set),
.audio_pending_tick(new_audio_pending_tick),
.mapper_out(mapper_out),
.mapper_history_out(18'h0ffff),
.mapper_history_in(new_mapper_history_in),
.mapper_in(mapper_in),
.mapper_set(mapper_set),
.evolution_out(evolution_out),
.evolution_in(evolution_in),
.evolution_set(evolution_set),
.storage_busy(storage_busy),
.ss_busy(ss_busy),
.ss_capture_progress(ss_capture_progress),
.eeprom_present(eeprom_present),
.eeprom_ext_out(eeprom_ext_out),
.eeprom_ext_in(eeprom_ext_in),
.eeprom_full(eeprom_full),
.nvram_refill(nvram_refill),
.gun_out(gun_out),
.gun_in(gun_in),
.gun_set(gun_set),
.gun_valid(gun_valid),
.paddle_out(paddle_out),
.paddle_in(paddle_in),
.paddle_set(paddle_set),
.paddle_valid(paddle_valid),
.tap_out(tap_out),
.tap_in(tap_in),
.tap_set(tap_set),
.tap_valid(tap_valid),
.sc_ram_size(sc_ram_size),
.sc_ram_restored(sc_ram_restored),
.eeprom_out(eeprom_out),
.eeprom_in(eeprom_in),
.eeprom_set(eeprom_set),
.wram_A(wram_A),
.wram_D(wram_D),
.wram_WE(wram_WE),
.wram_WA(wram_WA),
.wram_WD(wram_WD),
.nvram_A(nvram_A),
.nvram_D(nvram_D),
.nvram_WE(nvram_WE),
.nvram_WA(nvram_WA),
.nvram_WD(nvram_WD),
.systeme(systeme),
.vdp2_regs(vdp2_regs),
.vdp2_regs_in(vdp2_regs_in),
.vdp2_regs_set(vdp2_regs_set),
.cram2_out(cram2_out),
.cram2_A(cram2_A),
.cram2_D(cram2_D),
.cram2_wr(cram2_wr),
.vram2_en(vram2_en),
.vram2_A(vram2_A),
.vram2_D(vram2_D),
.vram2_WE(vram2_WE),
.vram2_WA(vram2_WA),
.vram2_WD(vram2_WD),
.psg2_out(psg2_out),
.psg2_in(psg2_in),
.psg2_set(psg2_set),
.md_out(md_out),
.md_in(md_in),
.md_set(md_set),
.md_valid(md_valid),
.gg_out(gg_out),
.gg_in(gg_in),
.gg_set(gg_set),
.io_out(io_out),
.io_in(io_in),
.io_set(io_set),
.video_state_out(video_state_out),
.video_state_in(video_state_in),
.video_state_set(video_state_set),
.DDRAM_ADDR(DDRAM_ADDR),
.DDRAM_DIN(DDRAM_DIN),
.DDRAM_BE(DDRAM_BE),
.DDRAM_WE(DDRAM_WE),
.DDRAM_DOUT(DDRAM_DOUT),
.DDRAM_DOUT_READY(DDRAM_DOUT_READY),
.DDRAM_RD(DDRAM_RD),
.DDRAM_BURSTCNT(DDRAM_BURSTCNT),
.DDRAM_BUSY(DDRAM_BUSY));
savestates_golden #(.TB_FAST(1)) golden(.clk(clk),
.reset_n(reset_n),
.ss_save(ss_save),
.ss_load(ss_load),
.ss_slot(ss_slot),
.ss_bios_mode(ss_bios_mode),
.ss_game_id(ss_game_id),
.ss_freeze(golden_ss_freeze),
.ss_cpu_prepare(golden_ss_cpu_prepare),
.z80_replay(replay),
.z80_tick_active(!logical_pause),
.z80_replay_t2(golden_z80_replay_t2),
.clock_phase(clkd==25?2'd3:clkd==20?2'd2:clkd==10?2'd1:2'd0),
.clock_phase_in(golden_clock_phase_in),
.clock_phase_set(golden_clock_phase_set),
.clock_phase_ready(phase_ready),
.bg_out(bg_live),
.bg2_out(bg2_live),
.bg_in(golden_bg_in),
.bg2_in(golden_bg2_in),
.bg_valid(golden_bg_valid),
.sprite_out(random_sprite1),
.sprite2_out(random_sprite2),
.sprite_in(golden_sprite_in),
.sprite2_in(golden_sprite2_in),
.sprite_valid(golden_sprite_valid),
.vblank(vblank),
.x(x),
.z80_restart(restart_out),
.z80_restart_dir(golden_z80_restart_dir),
.z80_restart_valid(golden_z80_restart_valid),
.z80_nmi(3'b001),
.z80_nmi_dir(golden_z80_nmi_dir),
.z80_nmi_valid(golden_z80_nmi_valid),
.z80_nmi_hold(golden_z80_nmi_hold),
.z80_reg(z80_reg),
.z80_dir(golden_z80_dir),
.z80_set(golden_z80_set),
.z80_m1_n(z80_m1_n),
.z80_mreq_n(z80_mreq_n),
.z80_iset(z80_iset),
.cpu_ce(cpu_ce),
.vdp_ce(vdp_ce),
.pix_ce(pix_ce),
.sp_ce(sp_ce),
.vdp_regs(vdp_regs),
.vdp_regs_in(golden_vdp_regs_in),
.vdp_regs_set(golden_vdp_regs_set),
.cram_out(cram_out),
.cram_A(golden_cram_A),
.cram_D(golden_cram_D),
.cram_wr(golden_cram_wr),
.vram_en(golden_vram_en),
.vram_A(golden_vram_A),
.vram_D(vram_D),
.vram_WE(golden_vram_WE),
.vram_WA(golden_vram_WA),
.vram_WD(golden_vram_WD),
.psg_out(psg_out),
.psg_in(golden_psg_in),
.psg_set(golden_psg_set),
.psg_ext_out(psg_ext_out),
.psg2_ext_out(psg2_ext_out),
.psg_ext_in(golden_psg_ext_in),
.psg2_ext_in(golden_psg2_ext_in),
.psg_div_out(psg_div_out),
.psg_div_in(golden_psg_div_in),
.audio_control_out(audio_control_out),
.audio_control_in(golden_audio_control_in),
.audio_quiescent(audio_quiescent),
.audio_phase_out(audio_phase_out),
.audio_phase_in(golden_audio_phase_in),
.audio_ext_set(golden_audio_ext_set),
.audio_phase_set(golden_audio_phase_set),
.audio_pending_tick(golden_audio_pending_tick),
.mapper_out(mapper_out),
.mapper_history_out(18'h0ffff),
.mapper_history_in(golden_mapper_history_in),
.mapper_in(golden_mapper_in),
.mapper_set(golden_mapper_set),
.evolution_out(evolution_out),
.evolution_in(golden_evolution_in),
.evolution_set(golden_evolution_set),
.storage_busy(storage_busy),
.ss_busy(golden_ss_busy),
.ss_capture_progress(golden_ss_capture_progress),
.eeprom_present(eeprom_present),
.eeprom_ext_out(eeprom_ext_out),
.eeprom_ext_in(golden_eeprom_ext_in),
.eeprom_full(golden_eeprom_full),
.nvram_refill(golden_nvram_refill),
.gun_out(gun_out),
.gun_in(golden_gun_in),
.gun_set(golden_gun_set),
.gun_valid(golden_gun_valid),
.paddle_out(paddle_out),
.paddle_in(golden_paddle_in),
.paddle_set(golden_paddle_set),
.paddle_valid(golden_paddle_valid),
.tap_out(tap_out),
.tap_in(golden_tap_in),
.tap_set(golden_tap_set),
.tap_valid(golden_tap_valid),
.sc_ram_size(sc_ram_size),
.sc_ram_restored(golden_sc_ram_restored),
.eeprom_out(eeprom_out),
.eeprom_in(golden_eeprom_in),
.eeprom_set(golden_eeprom_set),
.wram_A(golden_wram_A),
.wram_D(wram_D),
.wram_WE(golden_wram_WE),
.wram_WA(golden_wram_WA),
.wram_WD(golden_wram_WD),
.nvram_A(golden_nvram_A),
.nvram_D(nvram_D),
.nvram_WE(golden_nvram_WE),
.nvram_WA(golden_nvram_WA),
.nvram_WD(golden_nvram_WD),
.systeme(systeme),
.vdp2_regs(vdp2_regs),
.vdp2_regs_in(golden_vdp2_regs_in),
.vdp2_regs_set(golden_vdp2_regs_set),
.cram2_out(cram2_out),
.cram2_A(golden_cram2_A),
.cram2_D(golden_cram2_D),
.cram2_wr(golden_cram2_wr),
.vram2_en(golden_vram2_en),
.vram2_A(golden_vram2_A),
.vram2_D(vram2_D),
.vram2_WE(golden_vram2_WE),
.vram2_WA(golden_vram2_WA),
.vram2_WD(golden_vram2_WD),
.psg2_out(psg2_out),
.psg2_in(golden_psg2_in),
.psg2_set(golden_psg2_set),
.md_out(md_out),
.md_in(golden_md_in),
.md_set(golden_md_set),
.md_valid(golden_md_valid),
.gg_out(gg_out),
.gg_in(golden_gg_in),
.gg_set(golden_gg_set),
.io_out(io_out),
.io_in(golden_io_in),
.io_set(golden_io_set),
.video_state_out(video_state_out),
.video_state_in(golden_video_state_in),
.video_state_set(golden_video_state_set),
.DDRAM_ADDR(golden_DDRAM_ADDR),
.DDRAM_DIN(golden_DDRAM_DIN),
.DDRAM_BE(golden_DDRAM_BE),
.DDRAM_WE(golden_DDRAM_WE),
.DDRAM_DOUT(DDRAM_DOUT),
.DDRAM_DOUT_READY(DDRAM_DOUT_READY),
.DDRAM_RD(golden_DDRAM_RD),
.DDRAM_BURSTCNT(golden_DDRAM_BURSTCNT),
.DDRAM_BUSY(DDRAM_BUSY));

always #5 clk=~clk;
assign vblank=1;assign x=0;assign z80_reg=0;assign z80_m1_n=0;assign z80_mreq_n=0;assign z80_iset=0;
assign cpu_ce=1;assign vdp_ce=0;assign pix_ce=0;assign sp_ce=0;
assign vdp_regs=0;assign cram_out=0;assign vram_D=0;assign wram_D=0;
assign psg_out=0;assign psg2_out=0;assign psg_ext_out=0;assign psg2_ext_out=0;assign psg_div_out=0;assign audio_quiescent=1;
assign vdp2_regs=0;assign video_state_out=0;assign g06_live=0;assign replay=0;
always@(negedge clk)phase_ready<=phase_set;
reg[63:0]mem[0:12287];integer pending=0;reg[28:0]readaddr;
always@(posedge clk)begin
 DDRAM_DOUT_READY<=0;
 if(pending>0)begin pending<=pending-1;if(pending==1)begin DDRAM_DOUT<=mem[readaddr-29'h07c00000];DDRAM_DOUT_READY<=1;end end
 if(DDRAM_WE&&!DDRAM_BUSY)for(integer b=0;b<8;b++)if(DDRAM_BE[b])mem[DDRAM_ADDR-29'h07c00000][b*8+:8]<=DDRAM_DIN[b*8+:8];
 if(DDRAM_RD&&!DDRAM_BUSY)begin if(pending)$fatal(1,"overlapping read");pending<=extra_profiles?3+rng[7:4]:3;readaddr<=DDRAM_ADDR;end
end
task tick;begin @(negedge clk);#1;end endtask
integer guest_writes=0,rejections=0,accepted=0;reg loading=0;
always@(posedge clk)if(loading&&(wram_WE||vram_WE||nvram_WE||vram2_WE||z80_set||mapper_set||evolution_set||gg_set||io_set||eeprom_set||gun_set||paddle_set||tap_set||vdp_regs_set||vdp2_regs_set||psg_set||psg2_set||cram_wr||cram2_wr||video_state_set||audio_ext_set||audio_phase_set))guest_writes++;
task transfer(input bit saveop);begin
 wait(!ss_busy);force dut.op_cooldown=0;force golden.op_cooldown=0;tick;guest_writes=0;loading=!saveop;
 ss_save=saveop;ss_load=!saveop;tick;ss_save=0;ss_load=0;
 wait(ss_busy);wait(!ss_busy);loading=0;release dut.op_cooldown;release golden.op_cooldown;tick;
end endtask
task reject_bit(input integer wordaddr,bitnum);reg[63:0]oldword;begin
 oldword=mem[wordaddr];mem[wordaddr]=oldword^(64'd1<<bitnum);
 transfer(0);if(guest_writes)$fatal(1,"malformed image wrote guest state word%h bit%0d",wordaddr,bitnum);
 mem[wordaddr]=oldword;rejections++;$display("REJECT word%h bit%0d",wordaddr,bitnum);
end endtask
always@(posedge clk)if(loading&&vdp_regs_set)begin
 if(bg_valid!==expect_background)$fatal(1,"background validity mismatch");
 if(expect_background)begin
  if(bg_restored!==bg_live||(systeme&&bg2_restored!==bg2_live))$fatal(1,"background payload roundtrip mismatch");
 end else if(bg_restored!==0||bg2_restored!==0)$fatal(1,"legacy background history leaked");
end
reg[63:0]oldtag;reg[63:0]saved_image[0:12287];
initial begin
 for(integer i=0;i<12288;i++)mem[i]=0;
 for(integer i=0;i<139;i++)begin bg_live[i]=(i%3)==0;bg2_live[i]=(i%5)==0;end
 bg_live[22:15]=179;bg2_live[22:15]=239;
 repeat(4)tick;reset_n=1;transfer(1);
 if(dut.bg_snap!==bg_live||dut.bg2_snap!==0)$fatal(1,"SAVE background ring did not return to capture");
 if(mem['h1a][63:40]!==24'h484310||mem['h2e]!==64'h12aa0e0047365231||mem['h2f]!==8)$fatal(1,"v15 format writer");
 if(mem['h32]!==64'h008b0f0047354231||{mem['h35][10:0],mem['h34],mem['h33]}!==bg_live||mem['h35][63:11]!==0||{mem['h38],mem['h37],mem['h36]}!==0)$fatal(1,"v15 background writer packing");
 transfer(0);if(!guest_writes||!sprite_valid||!bg_valid)$fatal(1,"valid v14 rejected");accepted++;
 if(audio_phase_in!==1)$fatal(1,"v16 historical phase1 lost");
 begin reg[63:0]old_audio;old_audio=mem['he];mem['he][63]=0;
 transfer(0);if(guest_writes)$fatal(1,"v16 missing audio accepted");rejections++;mem['he]=old_audio;end
 for(integer b=0;b<64;b++)reject_bit('h2e,b);
 for(integer b=4;b<64;b++)reject_bit('h2f,b);
 reject_bit('h2f,2);
 for(integer b=42;b<64;b++)begin reject_bit('h294b,b);reject_bit('h2996,b);end
 reject_bit('h294c,0);
 // Background descriptor and every last-word padding bit reject before writes.
 for(integer b=0;b<64;b++)reject_bit('h32,b);
 for(integer b=11;b<64;b++)begin reject_bit('h35,b);reject_bit('h38,b);end
 for(integer b=0;b<139;b++)reject_bit('h36+(b/64),b%64);
 for(integer pos=240;pos<256;pos++)begin
  reg[7:0] oldpos;oldpos=mem['h33][22:15];mem['h33][22:15]=pos;
  transfer(0);if(guest_writes)$fatal(1,"invalid semantic text position accepted");rejections++;mem['h33][22:15]=oldpos;
 end
 // Every inherited tagged format retains its prior normalization policy.
 oldtag=mem['h1a];expect_background=0;
 for(integer version=1;version<=13;version++)begin
  mem['h1a][63:40]=24'h484300+version;mem['h1a][39:38]=version==1?0:version==2?2:3;
  transfer(0);if(!guest_writes||sprite_valid||sprite_restored!==0)$fatal(1,"legacy normalization version%0d",version);
  if(audio_phase_in!==0)$fatal(1,"legacy phase not normalized");accepted++;$display("LEGACY_ACCEPT version%0d",version);
 end
 // v14 keeps sprite/phase history and deterministically lacks G05.
 mem['h1a][63:40]=24'h48430e;mem['h1a][39:38]=3;
 transfer(0);if(!guest_writes||!sprite_valid||bg_valid)$fatal(1,"v14 compatibility");accepted++;
 expect_background=1;mem['h1a][63:40]=24'h48430f;
 transfer(0);if(!guest_writes||!sprite_valid||!bg_valid||audio_phase_in!==0)$fatal(1,"v15 compatibility/phase normalization");accepted++;
 expect_background=1;mem['h1a]=oldtag;mem['h2f][3]=0;
 transfer(0);if(!guest_writes||replay_t2!==0)$fatal(1,"stopped capture flag rejected");accepted++;
 // Independent dual-device nonzero records and invalid second text position.
 systeme=1;transfer(1);
 if(dut.bg_snap!==bg_live||dut.bg2_snap!==bg2_live)$fatal(1,"dual SAVE ring mismatch");
 transfer(0);if(!guest_writes||!bg_valid)$fatal(1,"dual v15 rejected");accepted++;
 for(integer pos=240;pos<256;pos++)begin
  reg[7:0] oldpos;oldpos=mem['h36][22:15];mem['h36][22:15]=pos;
  transfer(0);if(guest_writes)$fatal(1,"invalid second semantic position accepted");rejections++;mem['h36][22:15]=oldpos;
 end
 // Full controller transfers for every payload bit in both independent banks.
 for(integer bitindex=0;bitindex<139;bitindex++)begin
  bg_live=139'd1<<bitindex;bg2_live=139'd1<<(138-bitindex);
  transfer(1);transfer(0);if(!guest_writes)$fatal(1,"one-hot roundtrip rejected");accepted++;
 end
 // Every semantic counter encoding, including the239 endpoint.
 for(integer pos=0;pos<240;pos++)begin
  bg_live=0;bg2_live=0;bg_live[22:15]=pos;bg2_live[22:15]=239-pos;
  transfer(1);transfer(0);if(!guest_writes)$fatal(1,"valid semantic position rejected");accepted++;
 end
 // Genuine oldest size route must ignore poisoned modern extension bytes.
 systeme=0;expect_background=0;mem[0][63:32]=32'h3ffe;
 mem['he][63:56]=0;mem[5][63:20]=0;mem['h32]='1;mem['h33]='1;
 transfer(0);if(!guest_writes||bg_valid||sprite_valid)$fatal(1,"old64 compatibility");accepted++;
 expect_background=1;transfer(1);transfer(0);if(!guest_writes||!bg_valid)$fatal(1,"modern after legacy failed");accepted++;
 $display("PASS V16 FORMAT rejected%0d accepted%0d",rejections,accepted);
 extra_profiles=1;
 for(integer profile=0;profile<16;profile++)begin
  systeme=(profile>>2)&1;logical_pause=(profile>>3)&1;
  case(profile%4)0:clkd=0;1:clkd=10;2:clkd=20;3:clkd=25;endcase
  for(integer bitnum=0;bitnum<4778;bitnum++)begin
   rng={rng[30:0],rng[31]^rng[21]^rng[1]^rng[0]};random_sprite1[bitnum]=rng[0];
   rng={rng[30:0],rng[31]^rng[21]^rng[1]^rng[0]};random_sprite2[bitnum]=rng[0];
  end
  expected1=random_sprite1;expected2=systeme?random_sprite2:4778'd0;
  transfer(1);
  for(integer w=0;w<75;w++)if(mem['h2901+w]!==padded1[64*w+:64]||mem['h294c+w]!==padded2[64*w+:64])$fatal(1,"packed sprite word profile%0d word%0d",profile,w);
  for(integer w=0;w<12288;w++)image_copy[w]=mem[w];
  random_sprite1=~random_sprite1;random_sprite2=~random_sprite2;
  for(integer replaynum=0;replaynum<3;replaynum++)begin
   transfer(0);if(sprite_restored!==expected1||new_sprite2_in!==expected2)$fatal(1,"sprite replay profile%0d replay%0d",profile,replaynum);
   for(integer w=0;w<12288;w++)if(mem[w]!==image_copy[w])$fatal(1,"image modified");
  end
  $display("MATRIX PASS profile%0d",profile);
 end
 $display("PASS EXACT CONTROLLER MITER outputs95 format%0d profiles16 loads48 cycles%0d",rejections+accepted,compared_cycles);$finish;
end
initial begin #1000000000;$fatal(1,"format watchdog");end
always@(negedge clk)if(extra_profiles)begin rng={rng[30:0],rng[31]^rng[21]^rng[1]^rng[0]};DDRAM_BUSY<=rng[2:0]==0;end
always@(negedge clk)if(reset_n)begin
 compared_cycles++;
 if(dut.state!==golden.state || dut.sprite_snap!==golden.sprite_snap || dut.sprite2_snap!==golden.sprite2_snap)$fatal(1,"Miter state/bank state%0d",dut.state);
 if(ss_freeze !== golden_ss_freeze) $fatal(1,"Miter output ss_freeze state%0d golden%0d",dut.state,golden.state);
 if(cpu_prepare !== golden_ss_cpu_prepare) $fatal(1,"Miter output ss_cpu_prepare state%0d golden%0d",dut.state,golden.state);
 if(replay_t2 !== golden_z80_replay_t2) $fatal(1,"Miter output z80_replay_t2 state%0d golden%0d",dut.state,golden.state);
 if(phase_in !== golden_clock_phase_in) $fatal(1,"Miter output clock_phase_in state%0d golden%0d",dut.state,golden.state);
 if(phase_set !== golden_clock_phase_set) $fatal(1,"Miter output clock_phase_set state%0d golden%0d",dut.state,golden.state);
 if(bg_restored !== golden_bg_in) $fatal(1,"Miter output bg_in state%0d golden%0d",dut.state,golden.state);
 if(bg2_restored !== golden_bg2_in) $fatal(1,"Miter output bg2_in state%0d golden%0d",dut.state,golden.state);
 if(bg_valid !== golden_bg_valid) $fatal(1,"Miter output bg_valid state%0d golden%0d",dut.state,golden.state);
 if(sprite_restored !== golden_sprite_in) $fatal(1,"Miter output sprite_in state%0d golden%0d",dut.state,golden.state);
 if(new_sprite2_in !== golden_sprite2_in) $fatal(1,"Miter output sprite2_in state%0d golden%0d",dut.state,golden.state);
 if(sprite_valid !== golden_sprite_valid) $fatal(1,"Miter output sprite_valid state%0d golden%0d",dut.state,golden.state);
 if(new_z80_restart_dir !== golden_z80_restart_dir) $fatal(1,"Miter output z80_restart_dir state%0d golden%0d",dut.state,golden.state);
 if(new_z80_restart_valid !== golden_z80_restart_valid) $fatal(1,"Miter output z80_restart_valid state%0d golden%0d",dut.state,golden.state);
 if(new_z80_nmi_dir !== golden_z80_nmi_dir) $fatal(1,"Miter output z80_nmi_dir state%0d golden%0d",dut.state,golden.state);
 if(new_z80_nmi_valid !== golden_z80_nmi_valid) $fatal(1,"Miter output z80_nmi_valid state%0d golden%0d",dut.state,golden.state);
 if(new_z80_nmi_hold !== golden_z80_nmi_hold) $fatal(1,"Miter output z80_nmi_hold state%0d golden%0d",dut.state,golden.state);
 if(z80_dir !== golden_z80_dir) $fatal(1,"Miter output z80_dir state%0d golden%0d",dut.state,golden.state);
 if(z80_set !== golden_z80_set) $fatal(1,"Miter output z80_set state%0d golden%0d",dut.state,golden.state);
 if(vdp_regs_in !== golden_vdp_regs_in) $fatal(1,"Miter output vdp_regs_in state%0d golden%0d",dut.state,golden.state);
 if(vdp_regs_set !== golden_vdp_regs_set) $fatal(1,"Miter output vdp_regs_set state%0d golden%0d",dut.state,golden.state);
 if(cram_A !== golden_cram_A) $fatal(1,"Miter output cram_A state%0d golden%0d",dut.state,golden.state);
 if(cram_D !== golden_cram_D) $fatal(1,"Miter output cram_D state%0d golden%0d",dut.state,golden.state);
 if(cram_wr !== golden_cram_wr) $fatal(1,"Miter output cram_wr state%0d golden%0d",dut.state,golden.state);
 if(vram_en !== golden_vram_en) $fatal(1,"Miter output vram_en state%0d golden%0d",dut.state,golden.state);
 if(vram_A !== golden_vram_A) $fatal(1,"Miter output vram_A state%0d golden%0d",dut.state,golden.state);
 if(vram_WE !== golden_vram_WE) $fatal(1,"Miter output vram_WE state%0d golden%0d",dut.state,golden.state);
 if(vram_WA !== golden_vram_WA) $fatal(1,"Miter output vram_WA state%0d golden%0d",dut.state,golden.state);
 if(vram_WD !== golden_vram_WD) $fatal(1,"Miter output vram_WD state%0d golden%0d",dut.state,golden.state);
 if(psg_in !== golden_psg_in) $fatal(1,"Miter output psg_in state%0d golden%0d",dut.state,golden.state);
 if(psg_set !== golden_psg_set) $fatal(1,"Miter output psg_set state%0d golden%0d",dut.state,golden.state);
 if(psg_ext_in !== golden_psg_ext_in) $fatal(1,"Miter output psg_ext_in state%0d golden%0d",dut.state,golden.state);
 if(psg2_ext_in !== golden_psg2_ext_in) $fatal(1,"Miter output psg2_ext_in state%0d golden%0d",dut.state,golden.state);
 if(psg_div_in !== golden_psg_div_in) $fatal(1,"Miter output psg_div_in state%0d golden%0d",dut.state,golden.state);
 if(audio_control_in !== golden_audio_control_in) $fatal(1,"Miter output audio_control_in state%0d golden%0d",dut.state,golden.state);
 if(audio_phase_in !== golden_audio_phase_in) $fatal(1,"Miter output audio_phase_in state%0d golden%0d",dut.state,golden.state);
 if(audio_ext_set !== golden_audio_ext_set) $fatal(1,"Miter output audio_ext_set state%0d golden%0d",dut.state,golden.state);
 if(audio_phase_set !== golden_audio_phase_set) $fatal(1,"Miter output audio_phase_set state%0d golden%0d",dut.state,golden.state);
 if(new_audio_pending_tick !== golden_audio_pending_tick) $fatal(1,"Miter output audio_pending_tick state%0d golden%0d",dut.state,golden.state);
 if(new_mapper_history_in !== golden_mapper_history_in) $fatal(1,"Miter output mapper_history_in state%0d golden%0d",dut.state,golden.state);
 if(mapper_in !== golden_mapper_in) $fatal(1,"Miter output mapper_in state%0d golden%0d",dut.state,golden.state);
 if(mapper_set !== golden_mapper_set) $fatal(1,"Miter output mapper_set state%0d golden%0d",dut.state,golden.state);
 if(evolution_in !== golden_evolution_in) $fatal(1,"Miter output evolution_in state%0d golden%0d",dut.state,golden.state);
 if(evolution_set !== golden_evolution_set) $fatal(1,"Miter output evolution_set state%0d golden%0d",dut.state,golden.state);
 if(ss_busy !== golden_ss_busy) $fatal(1,"Miter output ss_busy state%0d golden%0d",dut.state,golden.state);
 if(ss_capture_progress !== golden_ss_capture_progress) $fatal(1,"Miter output ss_capture_progress state%0d golden%0d",dut.state,golden.state);
 if(eeprom_ext_in !== golden_eeprom_ext_in) $fatal(1,"Miter output eeprom_ext_in state%0d golden%0d",dut.state,golden.state);
 if(eeprom_full !== golden_eeprom_full) $fatal(1,"Miter output eeprom_full state%0d golden%0d",dut.state,golden.state);
 if(nvram_refill !== golden_nvram_refill) $fatal(1,"Miter output nvram_refill state%0d golden%0d",dut.state,golden.state);
 if(gun_in !== golden_gun_in) $fatal(1,"Miter output gun_in state%0d golden%0d",dut.state,golden.state);
 if(gun_set !== golden_gun_set) $fatal(1,"Miter output gun_set state%0d golden%0d",dut.state,golden.state);
 if(gun_valid !== golden_gun_valid) $fatal(1,"Miter output gun_valid state%0d golden%0d",dut.state,golden.state);
 if(paddle_in !== golden_paddle_in) $fatal(1,"Miter output paddle_in state%0d golden%0d",dut.state,golden.state);
 if(paddle_set !== golden_paddle_set) $fatal(1,"Miter output paddle_set state%0d golden%0d",dut.state,golden.state);
 if(paddle_valid !== golden_paddle_valid) $fatal(1,"Miter output paddle_valid state%0d golden%0d",dut.state,golden.state);
 if(tap_in !== golden_tap_in) $fatal(1,"Miter output tap_in state%0d golden%0d",dut.state,golden.state);
 if(tap_set !== golden_tap_set) $fatal(1,"Miter output tap_set state%0d golden%0d",dut.state,golden.state);
 if(tap_valid !== golden_tap_valid) $fatal(1,"Miter output tap_valid state%0d golden%0d",dut.state,golden.state);
 if(sc_ram_restored !== golden_sc_ram_restored) $fatal(1,"Miter output sc_ram_restored state%0d golden%0d",dut.state,golden.state);
 if(eeprom_in !== golden_eeprom_in) $fatal(1,"Miter output eeprom_in state%0d golden%0d",dut.state,golden.state);
 if(eeprom_set !== golden_eeprom_set) $fatal(1,"Miter output eeprom_set state%0d golden%0d",dut.state,golden.state);
 if(wram_A !== golden_wram_A) $fatal(1,"Miter output wram_A state%0d golden%0d",dut.state,golden.state);
 if(wram_WE !== golden_wram_WE) $fatal(1,"Miter output wram_WE state%0d golden%0d",dut.state,golden.state);
 if(wram_WA !== golden_wram_WA) $fatal(1,"Miter output wram_WA state%0d golden%0d",dut.state,golden.state);
 if(wram_WD !== golden_wram_WD) $fatal(1,"Miter output wram_WD state%0d golden%0d",dut.state,golden.state);
 if(nvram_A !== golden_nvram_A) $fatal(1,"Miter output nvram_A state%0d golden%0d",dut.state,golden.state);
 if(nvram_WE !== golden_nvram_WE) $fatal(1,"Miter output nvram_WE state%0d golden%0d",dut.state,golden.state);
 if(nvram_WA !== golden_nvram_WA) $fatal(1,"Miter output nvram_WA state%0d golden%0d",dut.state,golden.state);
 if(nvram_WD !== golden_nvram_WD) $fatal(1,"Miter output nvram_WD state%0d golden%0d",dut.state,golden.state);
 if(vdp2_regs_in !== golden_vdp2_regs_in) $fatal(1,"Miter output vdp2_regs_in state%0d golden%0d",dut.state,golden.state);
 if(vdp2_regs_set !== golden_vdp2_regs_set) $fatal(1,"Miter output vdp2_regs_set state%0d golden%0d",dut.state,golden.state);
 if(cram2_A !== golden_cram2_A) $fatal(1,"Miter output cram2_A state%0d golden%0d",dut.state,golden.state);
 if(cram2_D !== golden_cram2_D) $fatal(1,"Miter output cram2_D state%0d golden%0d",dut.state,golden.state);
 if(cram2_wr !== golden_cram2_wr) $fatal(1,"Miter output cram2_wr state%0d golden%0d",dut.state,golden.state);
 if(vram2_en !== golden_vram2_en) $fatal(1,"Miter output vram2_en state%0d golden%0d",dut.state,golden.state);
 if(vram2_A !== golden_vram2_A) $fatal(1,"Miter output vram2_A state%0d golden%0d",dut.state,golden.state);
 if(vram2_WE !== golden_vram2_WE) $fatal(1,"Miter output vram2_WE state%0d golden%0d",dut.state,golden.state);
 if(vram2_WA !== golden_vram2_WA) $fatal(1,"Miter output vram2_WA state%0d golden%0d",dut.state,golden.state);
 if(vram2_WD !== golden_vram2_WD) $fatal(1,"Miter output vram2_WD state%0d golden%0d",dut.state,golden.state);
 if(psg2_in !== golden_psg2_in) $fatal(1,"Miter output psg2_in state%0d golden%0d",dut.state,golden.state);
 if(psg2_set !== golden_psg2_set) $fatal(1,"Miter output psg2_set state%0d golden%0d",dut.state,golden.state);
 if(md_in !== golden_md_in) $fatal(1,"Miter output md_in state%0d golden%0d",dut.state,golden.state);
 if(md_set !== golden_md_set) $fatal(1,"Miter output md_set state%0d golden%0d",dut.state,golden.state);
 if(md_valid !== golden_md_valid) $fatal(1,"Miter output md_valid state%0d golden%0d",dut.state,golden.state);
 if(gg_in !== golden_gg_in) $fatal(1,"Miter output gg_in state%0d golden%0d",dut.state,golden.state);
 if(gg_set !== golden_gg_set) $fatal(1,"Miter output gg_set state%0d golden%0d",dut.state,golden.state);
 if(io_in !== golden_io_in) $fatal(1,"Miter output io_in state%0d golden%0d",dut.state,golden.state);
 if(io_set !== golden_io_set) $fatal(1,"Miter output io_set state%0d golden%0d",dut.state,golden.state);
 if(video_state_in !== golden_video_state_in) $fatal(1,"Miter output video_state_in state%0d golden%0d",dut.state,golden.state);
 if(video_state_set !== golden_video_state_set) $fatal(1,"Miter output video_state_set state%0d golden%0d",dut.state,golden.state);
 if(DDRAM_ADDR !== golden_DDRAM_ADDR) $fatal(1,"Miter output DDRAM_ADDR state%0d golden%0d",dut.state,golden.state);
 if(DDRAM_DIN !== golden_DDRAM_DIN) $fatal(1,"Miter output DDRAM_DIN state%0d golden%0d",dut.state,golden.state);
 if(DDRAM_BE !== golden_DDRAM_BE) $fatal(1,"Miter output DDRAM_BE state%0d golden%0d",dut.state,golden.state);
 if(DDRAM_WE !== golden_DDRAM_WE) $fatal(1,"Miter output DDRAM_WE state%0d golden%0d",dut.state,golden.state);
 if(DDRAM_RD !== golden_DDRAM_RD) $fatal(1,"Miter output DDRAM_RD state%0d golden%0d",dut.state,golden.state);
 if(DDRAM_BURSTCNT !== golden_DDRAM_BURSTCNT) $fatal(1,"Miter output DDRAM_BURSTCNT state%0d golden%0d",dut.state,golden.state);
end
endmodule
