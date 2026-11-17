`timescale 1ns/1ps
module vdp_tb;
reg active=0;reg[31:0]rng=32'h65ac5e01;integer profile=0,cycles=0;
 parameter GG=1,PAL=0,REQUEST_X=40,SPRITE_X=120,SPRITES=2,REPLAYS=3,REFERENCE=0,PROTO=1,TURBO=1,SAVE_ONLY=0,DIAGNOSTIC=0,SAVE_PHASE=-1,COMMON_PHASE=0,FIX=1,SCAN_MASK=0,SLOTS=8,EXT_REFERENCE=0,PHASE_SWEEP=0,WARMUP=0,PAUSE_CAPTURE=0,NATURAL_PHASE=0;
reg clk = '0;
reg reset_n = '0;
reg ss_save = '0;
reg ss_load = '0;
reg [1:0] ss_slot = '0;
reg ss_bios_mode = '0;
reg [31:0] ss_game_id = '0;
wire fm_write,fm_reset;wire ss_freeze;wire ss_capture_progress;
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
wire [7:0] golden_fm_state_addr;
wire [7:0] new_fm_state_addr;
wire  golden_fm_state_read;
wire  new_fm_state_read;
wire  golden_fm_state_write;
wire [31:0] golden_fm_state_wdata;
wire [31:0] new_fm_state_wdata;
wire  golden_fm_legacy_reset;
wire  golden_fm_initialization_run;
wire  new_fm_initialization_run;
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
savestates #(.TB_FAST(1)) dut(.fm_state_addr(new_fm_state_addr),
.fm_state_read(new_fm_state_read),
.fm_state_write(fm_write),
.fm_state_wdata(new_fm_state_wdata),
.fm_state_rdata(32'd0),
.fm_initialized(1'b1),
.fm_legacy_reset(fm_reset),
.fm_initialization_run(new_fm_initialization_run),
.clk(clk),
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
.sprite_out({{(4778-(N+42)){1'b0}},g06_live}),
.sprite2_out(4778'd0),
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
savestates_golden #(.TB_FAST(1)) golden(.fm_state_addr(golden_fm_state_addr),
.fm_state_read(golden_fm_state_read),
.fm_state_write(golden_fm_state_write),
.fm_state_wdata(golden_fm_state_wdata),
.fm_state_rdata(32'd0),
.fm_initialized(1'b1),
.fm_legacy_reset(golden_fm_legacy_reset),
.fm_initialization_run(golden_fm_initialization_run),
.clk(clk),
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
.sprite_out({{(4778-(N+42)){1'b0}},g06_live}),
.sprite2_out(4778'd0),
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
assign vdp2_regs=0;assign video_state_out=0;assign g06_live=0;assign replay=0;assign restart_out=0;
always@(negedge clk)phase_ready<=phase_set;
reg[63:0]mem[0:12287];integer pending=0;reg[28:0]readaddr;
always@(posedge clk)begin
 DDRAM_DOUT_READY<=0;
 if(pending>0)begin pending<=pending-1;if(pending==1)begin DDRAM_DOUT<=mem[readaddr-29'h07c00000];DDRAM_DOUT_READY<=1;end end
 if(DDRAM_WE&&!DDRAM_BUSY)for(integer b=0;b<8;b++)if(DDRAM_BE[b])mem[DDRAM_ADDR-29'h07c00000][b*8+:8]<=DDRAM_DIN[b*8+:8];
 if(DDRAM_RD&&!DDRAM_BUSY)begin if(pending)$fatal(1,"overlapping read");pending<=3+(profile%3==0?0:rng[7:4]);readaddr<=DDRAM_ADDR;end
end
task tick;begin @(negedge clk);#1;end endtask
integer guest_writes=0,rejections=0,accepted=0;reg loading=0;
always@(posedge clk)if(loading&&(fm_write||fm_reset||wram_WE||vram_WE||nvram_WE||vram2_WE||z80_set||mapper_set||evolution_set||gg_set||io_set||eeprom_set||gun_set||paddle_set||tap_set||vdp_regs_set||vdp2_regs_set||psg_set||psg2_set||cram_wr||cram2_wr||video_state_set||audio_ext_set||audio_phase_set))guest_writes++;
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
always@(negedge clk)if(reset_n)begin
 cycles++;if(new_fm_state_addr !== golden_fm_state_addr)$fatal(1,"output fm_state_addr candidate%0d golden%0d",dut.state,golden.state);
if(new_fm_state_read !== golden_fm_state_read)$fatal(1,"output fm_state_read candidate%0d golden%0d",dut.state,golden.state);
if(fm_write !== golden_fm_state_write)$fatal(1,"output fm_state_write candidate%0d golden%0d",dut.state,golden.state);
if(new_fm_state_wdata !== golden_fm_state_wdata)$fatal(1,"output fm_state_wdata candidate%0d golden%0d",dut.state,golden.state);
if(fm_reset !== golden_fm_legacy_reset)$fatal(1,"output fm_legacy_reset candidate%0d golden%0d",dut.state,golden.state);
if(new_fm_initialization_run !== golden_fm_initialization_run)$fatal(1,"output fm_initialization_run candidate%0d golden%0d",dut.state,golden.state);
if(ss_freeze !== golden_ss_freeze)$fatal(1,"output ss_freeze candidate%0d golden%0d",dut.state,golden.state);
if(cpu_prepare !== golden_ss_cpu_prepare)$fatal(1,"output ss_cpu_prepare candidate%0d golden%0d",dut.state,golden.state);
if(replay_t2 !== golden_z80_replay_t2)$fatal(1,"output z80_replay_t2 candidate%0d golden%0d",dut.state,golden.state);
if(phase_in !== golden_clock_phase_in)$fatal(1,"output clock_phase_in candidate%0d golden%0d",dut.state,golden.state);
if(phase_set !== golden_clock_phase_set)$fatal(1,"output clock_phase_set candidate%0d golden%0d",dut.state,golden.state);
if(bg_restored !== golden_bg_in)$fatal(1,"output bg_in candidate%0d golden%0d",dut.state,golden.state);
if(bg2_restored !== golden_bg2_in)$fatal(1,"output bg2_in candidate%0d golden%0d",dut.state,golden.state);
if(bg_valid !== golden_bg_valid)$fatal(1,"output bg_valid candidate%0d golden%0d",dut.state,golden.state);
if(sprite_restored !== golden_sprite_in)$fatal(1,"output sprite_in candidate%0d golden%0d",dut.state,golden.state);
if(new_sprite2_in !== golden_sprite2_in)$fatal(1,"output sprite2_in candidate%0d golden%0d",dut.state,golden.state);
if(sprite_valid !== golden_sprite_valid)$fatal(1,"output sprite_valid candidate%0d golden%0d",dut.state,golden.state);
if(new_z80_restart_dir !== golden_z80_restart_dir)$fatal(1,"output z80_restart_dir candidate%0d golden%0d",dut.state,golden.state);
if(new_z80_restart_valid !== golden_z80_restart_valid)$fatal(1,"output z80_restart_valid candidate%0d golden%0d",dut.state,golden.state);
if(new_z80_nmi_dir !== golden_z80_nmi_dir)$fatal(1,"output z80_nmi_dir candidate%0d golden%0d",dut.state,golden.state);
if(new_z80_nmi_valid !== golden_z80_nmi_valid)$fatal(1,"output z80_nmi_valid candidate%0d golden%0d",dut.state,golden.state);
if(new_z80_nmi_hold !== golden_z80_nmi_hold)$fatal(1,"output z80_nmi_hold candidate%0d golden%0d",dut.state,golden.state);
if(z80_dir !== golden_z80_dir)$fatal(1,"output z80_dir candidate%0d golden%0d",dut.state,golden.state);
if(z80_set !== golden_z80_set)$fatal(1,"output z80_set candidate%0d golden%0d",dut.state,golden.state);
if(vdp_regs_in !== golden_vdp_regs_in)$fatal(1,"output vdp_regs_in candidate%0d golden%0d",dut.state,golden.state);
if(vdp_regs_set !== golden_vdp_regs_set)$fatal(1,"output vdp_regs_set candidate%0d golden%0d",dut.state,golden.state);
if(cram_A !== golden_cram_A)$fatal(1,"output cram_A candidate%0d golden%0d",dut.state,golden.state);
if(cram_D !== golden_cram_D)$fatal(1,"output cram_D candidate%0d golden%0d",dut.state,golden.state);
if(cram_wr !== golden_cram_wr)$fatal(1,"output cram_wr candidate%0d golden%0d",dut.state,golden.state);
if(vram_en !== golden_vram_en)$fatal(1,"output vram_en candidate%0d golden%0d",dut.state,golden.state);
if(vram_A !== golden_vram_A)$fatal(1,"output vram_A candidate%0d golden%0d",dut.state,golden.state);
if(vram_WE !== golden_vram_WE)$fatal(1,"output vram_WE candidate%0d golden%0d",dut.state,golden.state);
if(vram_WA !== golden_vram_WA)$fatal(1,"output vram_WA candidate%0d golden%0d",dut.state,golden.state);
if(vram_WD !== golden_vram_WD)$fatal(1,"output vram_WD candidate%0d golden%0d",dut.state,golden.state);
if(psg_in !== golden_psg_in)$fatal(1,"output psg_in candidate%0d golden%0d",dut.state,golden.state);
if(psg_set !== golden_psg_set)$fatal(1,"output psg_set candidate%0d golden%0d",dut.state,golden.state);
if(psg_ext_in !== golden_psg_ext_in)$fatal(1,"output psg_ext_in candidate%0d golden%0d",dut.state,golden.state);
if(psg2_ext_in !== golden_psg2_ext_in)$fatal(1,"output psg2_ext_in candidate%0d golden%0d",dut.state,golden.state);
if(psg_div_in !== golden_psg_div_in)$fatal(1,"output psg_div_in candidate%0d golden%0d",dut.state,golden.state);
if(audio_control_in !== golden_audio_control_in)$fatal(1,"output audio_control_in candidate%0d golden%0d",dut.state,golden.state);
if(audio_phase_in !== golden_audio_phase_in)$fatal(1,"output audio_phase_in candidate%0d golden%0d",dut.state,golden.state);
if(audio_ext_set !== golden_audio_ext_set)$fatal(1,"output audio_ext_set candidate%0d golden%0d",dut.state,golden.state);
if(audio_phase_set !== golden_audio_phase_set)$fatal(1,"output audio_phase_set candidate%0d golden%0d",dut.state,golden.state);
if(new_audio_pending_tick !== golden_audio_pending_tick)$fatal(1,"output audio_pending_tick candidate%0d golden%0d",dut.state,golden.state);
if(new_mapper_history_in !== golden_mapper_history_in)$fatal(1,"output mapper_history_in candidate%0d golden%0d",dut.state,golden.state);
if(mapper_in !== golden_mapper_in)$fatal(1,"output mapper_in candidate%0d golden%0d",dut.state,golden.state);
if(mapper_set !== golden_mapper_set)$fatal(1,"output mapper_set candidate%0d golden%0d",dut.state,golden.state);
if(evolution_in !== golden_evolution_in)$fatal(1,"output evolution_in candidate%0d golden%0d",dut.state,golden.state);
if(evolution_set !== golden_evolution_set)$fatal(1,"output evolution_set candidate%0d golden%0d",dut.state,golden.state);
if(ss_busy !== golden_ss_busy)$fatal(1,"output ss_busy candidate%0d golden%0d",dut.state,golden.state);
if(ss_capture_progress !== golden_ss_capture_progress)$fatal(1,"output ss_capture_progress candidate%0d golden%0d",dut.state,golden.state);
if(eeprom_ext_in !== golden_eeprom_ext_in)$fatal(1,"output eeprom_ext_in candidate%0d golden%0d",dut.state,golden.state);
if(eeprom_full !== golden_eeprom_full)$fatal(1,"output eeprom_full candidate%0d golden%0d",dut.state,golden.state);
if(nvram_refill !== golden_nvram_refill)$fatal(1,"output nvram_refill candidate%0d golden%0d",dut.state,golden.state);
if(gun_in !== golden_gun_in)$fatal(1,"output gun_in candidate%0d golden%0d",dut.state,golden.state);
if(gun_set !== golden_gun_set)$fatal(1,"output gun_set candidate%0d golden%0d",dut.state,golden.state);
if(gun_valid !== golden_gun_valid)$fatal(1,"output gun_valid candidate%0d golden%0d",dut.state,golden.state);
if(paddle_in !== golden_paddle_in)$fatal(1,"output paddle_in candidate%0d golden%0d",dut.state,golden.state);
if(paddle_set !== golden_paddle_set)$fatal(1,"output paddle_set candidate%0d golden%0d",dut.state,golden.state);
if(paddle_valid !== golden_paddle_valid)$fatal(1,"output paddle_valid candidate%0d golden%0d",dut.state,golden.state);
if(tap_in !== golden_tap_in)$fatal(1,"output tap_in candidate%0d golden%0d",dut.state,golden.state);
if(tap_set !== golden_tap_set)$fatal(1,"output tap_set candidate%0d golden%0d",dut.state,golden.state);
if(tap_valid !== golden_tap_valid)$fatal(1,"output tap_valid candidate%0d golden%0d",dut.state,golden.state);
if(sc_ram_restored !== golden_sc_ram_restored)$fatal(1,"output sc_ram_restored candidate%0d golden%0d",dut.state,golden.state);
if(eeprom_in !== golden_eeprom_in)$fatal(1,"output eeprom_in candidate%0d golden%0d",dut.state,golden.state);
if(eeprom_set !== golden_eeprom_set)$fatal(1,"output eeprom_set candidate%0d golden%0d",dut.state,golden.state);
if(wram_A !== golden_wram_A)$fatal(1,"output wram_A candidate%0d golden%0d",dut.state,golden.state);
if(wram_WE !== golden_wram_WE)$fatal(1,"output wram_WE candidate%0d golden%0d",dut.state,golden.state);
if(wram_WA !== golden_wram_WA)$fatal(1,"output wram_WA candidate%0d golden%0d",dut.state,golden.state);
if(wram_WD !== golden_wram_WD)$fatal(1,"output wram_WD candidate%0d golden%0d",dut.state,golden.state);
if(nvram_A !== golden_nvram_A)$fatal(1,"output nvram_A candidate%0d golden%0d",dut.state,golden.state);
if(nvram_WE !== golden_nvram_WE)$fatal(1,"output nvram_WE candidate%0d golden%0d",dut.state,golden.state);
if(nvram_WA !== golden_nvram_WA)$fatal(1,"output nvram_WA candidate%0d golden%0d",dut.state,golden.state);
if(nvram_WD !== golden_nvram_WD)$fatal(1,"output nvram_WD candidate%0d golden%0d",dut.state,golden.state);
if(vdp2_regs_in !== golden_vdp2_regs_in)$fatal(1,"output vdp2_regs_in candidate%0d golden%0d",dut.state,golden.state);
if(vdp2_regs_set !== golden_vdp2_regs_set)$fatal(1,"output vdp2_regs_set candidate%0d golden%0d",dut.state,golden.state);
if(cram2_A !== golden_cram2_A)$fatal(1,"output cram2_A candidate%0d golden%0d",dut.state,golden.state);
if(cram2_D !== golden_cram2_D)$fatal(1,"output cram2_D candidate%0d golden%0d",dut.state,golden.state);
if(cram2_wr !== golden_cram2_wr)$fatal(1,"output cram2_wr candidate%0d golden%0d",dut.state,golden.state);
if(vram2_en !== golden_vram2_en)$fatal(1,"output vram2_en candidate%0d golden%0d",dut.state,golden.state);
if(vram2_A !== golden_vram2_A)$fatal(1,"output vram2_A candidate%0d golden%0d",dut.state,golden.state);
if(vram2_WE !== golden_vram2_WE)$fatal(1,"output vram2_WE candidate%0d golden%0d",dut.state,golden.state);
if(vram2_WA !== golden_vram2_WA)$fatal(1,"output vram2_WA candidate%0d golden%0d",dut.state,golden.state);
if(vram2_WD !== golden_vram2_WD)$fatal(1,"output vram2_WD candidate%0d golden%0d",dut.state,golden.state);
if(psg2_in !== golden_psg2_in)$fatal(1,"output psg2_in candidate%0d golden%0d",dut.state,golden.state);
if(psg2_set !== golden_psg2_set)$fatal(1,"output psg2_set candidate%0d golden%0d",dut.state,golden.state);
if(md_in !== golden_md_in)$fatal(1,"output md_in candidate%0d golden%0d",dut.state,golden.state);
if(md_set !== golden_md_set)$fatal(1,"output md_set candidate%0d golden%0d",dut.state,golden.state);
if(md_valid !== golden_md_valid)$fatal(1,"output md_valid candidate%0d golden%0d",dut.state,golden.state);
if(gg_in !== golden_gg_in)$fatal(1,"output gg_in candidate%0d golden%0d",dut.state,golden.state);
if(gg_set !== golden_gg_set)$fatal(1,"output gg_set candidate%0d golden%0d",dut.state,golden.state);
if(io_in !== golden_io_in)$fatal(1,"output io_in candidate%0d golden%0d",dut.state,golden.state);
if(io_set !== golden_io_set)$fatal(1,"output io_set candidate%0d golden%0d",dut.state,golden.state);
if(video_state_in !== golden_video_state_in)$fatal(1,"output video_state_in candidate%0d golden%0d",dut.state,golden.state);
if(video_state_set !== golden_video_state_set)$fatal(1,"output video_state_set candidate%0d golden%0d",dut.state,golden.state);
if(DDRAM_ADDR !== golden_DDRAM_ADDR)$fatal(1,"output DDRAM_ADDR candidate%0d golden%0d",dut.state,golden.state);
if(DDRAM_DIN !== golden_DDRAM_DIN)$fatal(1,"output DDRAM_DIN candidate%0d golden%0d",dut.state,golden.state);
if(DDRAM_BE !== golden_DDRAM_BE)$fatal(1,"output DDRAM_BE candidate%0d golden%0d",dut.state,golden.state);
if(DDRAM_WE !== golden_DDRAM_WE)$fatal(1,"output DDRAM_WE candidate%0d golden%0d",dut.state,golden.state);
if(DDRAM_RD !== golden_DDRAM_RD)$fatal(1,"output DDRAM_RD candidate%0d golden%0d",dut.state,golden.state);
if(DDRAM_BURSTCNT !== golden_DDRAM_BURSTCNT)$fatal(1,"output DDRAM_BURSTCNT candidate%0d golden%0d",dut.state,golden.state);
 if(cycles%1000000==0)$display("MITER_PROGRESS clocks%0d profile%0d state%0d busy%b",cycles,profile,dut.state,ss_busy);
 if(dut.state!==golden.state)$fatal(1,"FSM mismatch");
 if(active)begin rng={rng[30:0],rng[31]^rng[21]^rng[1]^rng[0]};DDRAM_BUSY<=profile%3==0?0:rng[2:0]==0;end
end
reg[63:0]image[0:12287];
initial begin
 for(integer w=0;w<12288;w++)mem[w]=0;
 repeat(4)tick;reset_n=1;active=1;expect_background=1;
 for(profile=0;profile<8;profile++)begin
  evolution_out=160'h00000000000000000000891234568912e1322468;
  evolution_out[155:96]=60'h123456789abcde; evolution_out[155:153]=profile;
  transfer(1);for(integer w=0;w<12288;w++)image[w]=mem[w];
  repeat(3)begin transfer(0);if(evolution_in!==evolution_out)$fatal(1,"Evolution history changed");end
  mem['h1a][63:22]=0;mem['he][63:52]=0;mem[5][63:38]=0;
  transfer(0);if(guest_writes)$fatal(1,"missing Evolution public history invented");
  mem[0][63:32]=32'h3ffe;mem[5][63:20]=0;
  transfer(0);if(guest_writes)$fatal(1,"old64 Evolution history invented");
  $display("PASS EVOLUTION profile%0d current3 public_reject2",profile);
 end
 $display("PASS EVOLUTION ALL outputs101 profiles8 current24 public_rejections16 clocks%0d",cycles);$finish;
end
initial begin #1000000000;$fatal(1,"watchdog");end
endmodule
