
// Complete controller outputs: four-state equality, except inactive CPU data.
wire [7:0] alias_fm_state_addr;
wire  alias_fm_state_read;
wire  alias_fm_state_write;
wire [31:0] alias_fm_state_wdata;
wire  alias_fm_legacy_reset;
wire  alias_fm_initialization_run;
wire  alias_ss_freeze;
wire  alias_ss_cpu_prepare;
wire  alias_z80_replay_t2;
wire [1:0] alias_clock_phase_in;
wire  alias_clock_phase_set;
wire [138:0] alias_bg_in;
wire [138:0] alias_bg2_in;
wire  alias_bg_valid;
wire [4777:0] alias_sprite_in;
wire [4777:0] alias_sprite2_in;
wire  alias_sprite_valid;
wire [2:0] alias_z80_restart_dir;
wire  alias_z80_restart_valid;
wire [2:0] alias_z80_nmi_dir;
wire  alias_z80_nmi_valid;
wire  alias_z80_nmi_hold;
wire [229:0] alias_z80_dir;
wire  alias_z80_set;
wire [135:0] alias_vdp_regs_in;
wire  alias_vdp_regs_set;
wire [4:0] alias_cram_A;
wire [11:0] alias_cram_D;
wire  alias_cram_wr;
wire  alias_vram_en;
wire [14:0] alias_vram_A;
wire  alias_vram_WE;
wire [14:0] alias_vram_WA;
wire [7:0] alias_vram_WD;
wire [55:0] alias_psg_in;
wire  alias_psg_set;
wire [95:0] alias_psg_ext_in;
wire [95:0] alias_psg2_ext_in;
wire [3:0] alias_psg_div_in;
wire [10:0] alias_audio_control_in;
wire [15:0] alias_audio_last_in;
wire  alias_audio_last_valid;
wire  alias_audio_phase_in;
wire  alias_audio_ext_set;
wire  alias_audio_phase_set;
wire  alias_audio_pending_tick;
wire [17:0] alias_mapper_history_in;
wire [63:0] alias_mapper_in;
wire  alias_mapper_set;
wire [159:0] alias_evolution_in;
wire  alias_evolution_set;
wire  alias_ss_busy;
wire  alias_ss_capture_progress;
wire [127:0] alias_eeprom_ext_in;
wire  alias_eeprom_full;
wire  alias_nvram_refill;
wire [45:0] alias_gun_in;
wire  alias_gun_set;
wire  alias_gun_valid;
wire [31:0] alias_paddle_in;
wire  alias_paddle_set;
wire  alias_paddle_valid;
wire [18:0] alias_tap_in;
wire  alias_tap_set;
wire  alias_tap_valid;
wire  alias_sc_ram_restored;
wire [63:0] alias_eeprom_in;
wire  alias_eeprom_set;
wire [13:0] alias_wram_A;
wire  alias_wram_WE;
wire [13:0] alias_wram_WA;
wire [7:0] alias_wram_WD;
wire [14:0] alias_nvram_A;
wire  alias_nvram_WE;
wire [14:0] alias_nvram_WA;
wire [7:0] alias_nvram_WD;
wire [135:0] alias_vdp2_regs_in;
wire  alias_vdp2_regs_set;
wire [4:0] alias_cram2_A;
wire [11:0] alias_cram2_D;
wire  alias_cram2_wr;
wire  alias_vram2_en;
wire [14:0] alias_vram2_A;
wire  alias_vram2_WE;
wire [14:0] alias_vram2_WA;
wire [7:0] alias_vram2_WD;
wire [55:0] alias_psg2_in;
wire  alias_psg2_set;
wire [45:0] alias_md_in;
wire  alias_md_set;
wire  alias_md_valid;
wire [127:0] alias_gg_in;
wire  alias_gg_set;
wire [31:0] alias_io_in;
wire  alias_io_set;
wire [21:0] alias_video_state_in;
wire  alias_video_state_set;
wire [28:0] alias_DDRAM_ADDR;
wire [63:0] alias_DDRAM_DIN;
wire [7:0] alias_DDRAM_BE;
wire  alias_DDRAM_WE;
wire  alias_DDRAM_RD;
wire [7:0] alias_DDRAM_BURSTCNT;
savestates_alias #(.TB_FAST(dut.TB_FAST)) alias_ctl(
.fm_state_rdata(dut.fm_state_rdata),
.fm_initialized(dut.fm_initialized),
.clk(dut.clk),
.reset_n(dut.reset_n),
.ss_save(dut.ss_save),
.ss_load(dut.ss_load),
.ss_slot(dut.ss_slot),
.ss_bios_mode(dut.ss_bios_mode),
.ss_game_id(dut.ss_game_id),
.z80_replay(dut.z80_replay),
.z80_tick_active(dut.z80_tick_active),
.clock_phase(dut.clock_phase),
.clock_phase_ready(dut.clock_phase_ready),
.bg_out(dut.bg_out),
.bg2_out(dut.bg2_out),
.sprite_out(dut.sprite_out),
.sprite2_out(dut.sprite2_out),
.vblank(dut.vblank),
.x(dut.x),
.z80_restart(dut.z80_restart),
.z80_nmi(dut.z80_nmi),
.z80_reg(dut.z80_reg),
.z80_m1_n(dut.z80_m1_n),
.z80_mreq_n(dut.z80_mreq_n),
.z80_iset(dut.z80_iset),
.cpu_ce(dut.cpu_ce),
.vdp_ce(dut.vdp_ce),
.pix_ce(dut.pix_ce),
.sp_ce(dut.sp_ce),
.vdp_regs(dut.vdp_regs),
.cram_out(dut.cram_out),
.vram_D(dut.vram_D),
.psg_out(dut.psg_out),
.psg_ext_out(dut.psg_ext_out),
.psg2_ext_out(dut.psg2_ext_out),
.psg_div_out(dut.psg_div_out),
.audio_control_out(dut.audio_control_out),
.audio_quiescent(dut.audio_quiescent),
.audio_phase_out(dut.audio_phase_out),
.audio_last_out(dut.audio_last_out),
.mapper_out(dut.mapper_out),
.mapper_history_out(dut.mapper_history_out),
.evolution_out(dut.evolution_out),
.storage_busy(dut.storage_busy),
.eeprom_present(dut.eeprom_present),
.eeprom_ext_out(dut.eeprom_ext_out),
.gun_out(dut.gun_out),
.paddle_out(dut.paddle_out),
.tap_out(dut.tap_out),
.sc_ram_size(dut.sc_ram_size),
.eeprom_out(dut.eeprom_out),
.wram_D(dut.wram_D),
.nvram_D(dut.nvram_D),
.systeme(dut.systeme),
.vdp2_regs(dut.vdp2_regs),
.cram2_out(dut.cram2_out),
.vram2_D(dut.vram2_D),
.psg2_out(dut.psg2_out),
.md_out(dut.md_out),
.gg_out(dut.gg_out),
.io_out(dut.io_out),
.video_state_out(dut.video_state_out),
.DDRAM_DOUT(dut.DDRAM_DOUT),
.DDRAM_DOUT_READY(dut.DDRAM_DOUT_READY),
.DDRAM_BUSY(dut.DDRAM_BUSY),
.fm_state_addr(alias_fm_state_addr),
.fm_state_read(alias_fm_state_read),
.fm_state_write(alias_fm_state_write),
.fm_state_wdata(alias_fm_state_wdata),
.fm_legacy_reset(alias_fm_legacy_reset),
.fm_initialization_run(alias_fm_initialization_run),
.ss_freeze(alias_ss_freeze),
.ss_cpu_prepare(alias_ss_cpu_prepare),
.z80_replay_t2(alias_z80_replay_t2),
.clock_phase_in(alias_clock_phase_in),
.clock_phase_set(alias_clock_phase_set),
.bg_in(alias_bg_in),
.bg2_in(alias_bg2_in),
.bg_valid(alias_bg_valid),
.sprite_in(alias_sprite_in),
.sprite2_in(alias_sprite2_in),
.sprite_valid(alias_sprite_valid),
.z80_restart_dir(alias_z80_restart_dir),
.z80_restart_valid(alias_z80_restart_valid),
.z80_nmi_dir(alias_z80_nmi_dir),
.z80_nmi_valid(alias_z80_nmi_valid),
.z80_nmi_hold(alias_z80_nmi_hold),
.z80_dir(alias_z80_dir),
.z80_set(alias_z80_set),
.vdp_regs_in(alias_vdp_regs_in),
.vdp_regs_set(alias_vdp_regs_set),
.cram_A(alias_cram_A),
.cram_D(alias_cram_D),
.cram_wr(alias_cram_wr),
.vram_en(alias_vram_en),
.vram_A(alias_vram_A),
.vram_WE(alias_vram_WE),
.vram_WA(alias_vram_WA),
.vram_WD(alias_vram_WD),
.psg_in(alias_psg_in),
.psg_set(alias_psg_set),
.psg_ext_in(alias_psg_ext_in),
.psg2_ext_in(alias_psg2_ext_in),
.psg_div_in(alias_psg_div_in),
.audio_control_in(alias_audio_control_in),
.audio_last_in(alias_audio_last_in),
.audio_last_valid(alias_audio_last_valid),
.audio_phase_in(alias_audio_phase_in),
.audio_ext_set(alias_audio_ext_set),
.audio_phase_set(alias_audio_phase_set),
.audio_pending_tick(alias_audio_pending_tick),
.mapper_history_in(alias_mapper_history_in),
.mapper_in(alias_mapper_in),
.mapper_set(alias_mapper_set),
.evolution_in(alias_evolution_in),
.evolution_set(alias_evolution_set),
.ss_busy(alias_ss_busy),
.ss_capture_progress(alias_ss_capture_progress),
.eeprom_ext_in(alias_eeprom_ext_in),
.eeprom_full(alias_eeprom_full),
.nvram_refill(alias_nvram_refill),
.gun_in(alias_gun_in),
.gun_set(alias_gun_set),
.gun_valid(alias_gun_valid),
.paddle_in(alias_paddle_in),
.paddle_set(alias_paddle_set),
.paddle_valid(alias_paddle_valid),
.tap_in(alias_tap_in),
.tap_set(alias_tap_set),
.tap_valid(alias_tap_valid),
.sc_ram_restored(alias_sc_ram_restored),
.eeprom_in(alias_eeprom_in),
.eeprom_set(alias_eeprom_set),
.wram_A(alias_wram_A),
.wram_WE(alias_wram_WE),
.wram_WA(alias_wram_WA),
.wram_WD(alias_wram_WD),
.nvram_A(alias_nvram_A),
.nvram_WE(alias_nvram_WE),
.nvram_WA(alias_nvram_WA),
.nvram_WD(alias_nvram_WD),
.vdp2_regs_in(alias_vdp2_regs_in),
.vdp2_regs_set(alias_vdp2_regs_set),
.cram2_A(alias_cram2_A),
.cram2_D(alias_cram2_D),
.cram2_wr(alias_cram2_wr),
.vram2_en(alias_vram2_en),
.vram2_A(alias_vram2_A),
.vram2_WE(alias_vram2_WE),
.vram2_WA(alias_vram2_WA),
.vram2_WD(alias_vram2_WD),
.psg2_in(alias_psg2_in),
.psg2_set(alias_psg2_set),
.md_in(alias_md_in),
.md_set(alias_md_set),
.md_valid(alias_md_valid),
.gg_in(alias_gg_in),
.gg_set(alias_gg_set),
.io_in(alias_io_in),
.io_set(alias_io_set),
.video_state_in(alias_video_state_in),
.video_state_set(alias_video_state_set),
.DDRAM_ADDR(alias_DDRAM_ADDR),
.DDRAM_DIN(alias_DDRAM_DIN),
.DDRAM_BE(alias_DDRAM_BE),
.DDRAM_WE(alias_DDRAM_WE),
.DDRAM_RD(alias_DDRAM_RD),
.DDRAM_BURSTCNT(alias_DDRAM_BURSTCNT));
integer alias_cycles=0,alias_consumes=0,alias_inactive=0,alias_writes=0,alias_reads=0;
always @(posedge clk)begin
 alias_cycles++;
if(dut.fm_state_addr !== alias_fm_state_addr)$fatal(1,"ALIAS controller output fm_state_addr cycle%0d",alias_cycles);
if(dut.fm_state_read !== alias_fm_state_read)$fatal(1,"ALIAS controller output fm_state_read cycle%0d",alias_cycles);
if(dut.fm_state_write !== alias_fm_state_write)$fatal(1,"ALIAS controller output fm_state_write cycle%0d",alias_cycles);
if(dut.fm_state_wdata !== alias_fm_state_wdata)$fatal(1,"ALIAS controller output fm_state_wdata cycle%0d",alias_cycles);
if(dut.fm_legacy_reset !== alias_fm_legacy_reset)$fatal(1,"ALIAS controller output fm_legacy_reset cycle%0d",alias_cycles);
if(dut.fm_initialization_run !== alias_fm_initialization_run)$fatal(1,"ALIAS controller output fm_initialization_run cycle%0d",alias_cycles);
if(dut.ss_freeze !== alias_ss_freeze)$fatal(1,"ALIAS controller output ss_freeze cycle%0d",alias_cycles);
if(dut.ss_cpu_prepare !== alias_ss_cpu_prepare)$fatal(1,"ALIAS controller output ss_cpu_prepare cycle%0d",alias_cycles);
if(dut.z80_replay_t2 !== alias_z80_replay_t2)$fatal(1,"ALIAS controller output z80_replay_t2 cycle%0d",alias_cycles);
if(dut.clock_phase_in !== alias_clock_phase_in)$fatal(1,"ALIAS controller output clock_phase_in cycle%0d",alias_cycles);
if(dut.clock_phase_set !== alias_clock_phase_set)$fatal(1,"ALIAS controller output clock_phase_set cycle%0d",alias_cycles);
if(dut.bg_in !== alias_bg_in)$fatal(1,"ALIAS controller output bg_in cycle%0d",alias_cycles);
if(dut.bg2_in !== alias_bg2_in)$fatal(1,"ALIAS controller output bg2_in cycle%0d",alias_cycles);
if(dut.bg_valid !== alias_bg_valid)$fatal(1,"ALIAS controller output bg_valid cycle%0d",alias_cycles);
if(dut.sprite_in !== alias_sprite_in)$fatal(1,"ALIAS controller output sprite_in cycle%0d",alias_cycles);
if(dut.sprite2_in !== alias_sprite2_in)$fatal(1,"ALIAS controller output sprite2_in cycle%0d",alias_cycles);
if(dut.sprite_valid !== alias_sprite_valid)$fatal(1,"ALIAS controller output sprite_valid cycle%0d",alias_cycles);
if(dut.z80_restart_dir !== alias_z80_restart_dir)$fatal(1,"ALIAS controller output z80_restart_dir cycle%0d",alias_cycles);
if(dut.z80_restart_valid !== alias_z80_restart_valid)$fatal(1,"ALIAS controller output z80_restart_valid cycle%0d",alias_cycles);
if(dut.z80_nmi_dir !== alias_z80_nmi_dir)$fatal(1,"ALIAS controller output z80_nmi_dir cycle%0d",alias_cycles);
if(dut.z80_nmi_valid !== alias_z80_nmi_valid)$fatal(1,"ALIAS controller output z80_nmi_valid cycle%0d",alias_cycles);
if(dut.z80_nmi_hold !== alias_z80_nmi_hold)$fatal(1,"ALIAS controller output z80_nmi_hold cycle%0d",alias_cycles);
if(dut.z80_set !== alias_z80_set)$fatal(1,"ALIAS controller output z80_set cycle%0d",alias_cycles);
if(dut.vdp_regs_in !== alias_vdp_regs_in)$fatal(1,"ALIAS controller output vdp_regs_in cycle%0d",alias_cycles);
if(dut.vdp_regs_set !== alias_vdp_regs_set)$fatal(1,"ALIAS controller output vdp_regs_set cycle%0d",alias_cycles);
if(dut.cram_A !== alias_cram_A)$fatal(1,"ALIAS controller output cram_A cycle%0d",alias_cycles);
if(dut.cram_D !== alias_cram_D)$fatal(1,"ALIAS controller output cram_D cycle%0d",alias_cycles);
if(dut.cram_wr !== alias_cram_wr)$fatal(1,"ALIAS controller output cram_wr cycle%0d",alias_cycles);
if(dut.vram_en !== alias_vram_en)$fatal(1,"ALIAS controller output vram_en cycle%0d",alias_cycles);
if(dut.vram_A !== alias_vram_A)$fatal(1,"ALIAS controller output vram_A cycle%0d",alias_cycles);
if(dut.vram_WE !== alias_vram_WE)$fatal(1,"ALIAS controller output vram_WE cycle%0d",alias_cycles);
if(dut.vram_WA !== alias_vram_WA)$fatal(1,"ALIAS controller output vram_WA cycle%0d",alias_cycles);
if(dut.vram_WD !== alias_vram_WD)$fatal(1,"ALIAS controller output vram_WD cycle%0d",alias_cycles);
if(dut.psg_in !== alias_psg_in)$fatal(1,"ALIAS controller output psg_in cycle%0d",alias_cycles);
if(dut.psg_set !== alias_psg_set)$fatal(1,"ALIAS controller output psg_set cycle%0d",alias_cycles);
if(dut.psg_ext_in !== alias_psg_ext_in)$fatal(1,"ALIAS controller output psg_ext_in cycle%0d",alias_cycles);
if(dut.psg2_ext_in !== alias_psg2_ext_in)$fatal(1,"ALIAS controller output psg2_ext_in cycle%0d",alias_cycles);
if(dut.psg_div_in !== alias_psg_div_in)$fatal(1,"ALIAS controller output psg_div_in cycle%0d",alias_cycles);
if(dut.audio_control_in !== alias_audio_control_in)$fatal(1,"ALIAS controller output audio_control_in cycle%0d",alias_cycles);
if(dut.audio_last_in !== alias_audio_last_in)$fatal(1,"ALIAS controller output audio_last_in cycle%0d",alias_cycles);
if(dut.audio_last_valid !== alias_audio_last_valid)$fatal(1,"ALIAS controller output audio_last_valid cycle%0d",alias_cycles);
if(dut.audio_phase_in !== alias_audio_phase_in)$fatal(1,"ALIAS controller output audio_phase_in cycle%0d",alias_cycles);
if(dut.audio_ext_set !== alias_audio_ext_set)$fatal(1,"ALIAS controller output audio_ext_set cycle%0d",alias_cycles);
if(dut.audio_phase_set !== alias_audio_phase_set)$fatal(1,"ALIAS controller output audio_phase_set cycle%0d",alias_cycles);
if(dut.audio_pending_tick !== alias_audio_pending_tick)$fatal(1,"ALIAS controller output audio_pending_tick cycle%0d",alias_cycles);
if(dut.mapper_history_in !== alias_mapper_history_in)$fatal(1,"ALIAS controller output mapper_history_in cycle%0d",alias_cycles);
if(dut.mapper_in !== alias_mapper_in)$fatal(1,"ALIAS controller output mapper_in cycle%0d",alias_cycles);
if(dut.mapper_set !== alias_mapper_set)$fatal(1,"ALIAS controller output mapper_set cycle%0d",alias_cycles);
if(dut.evolution_in !== alias_evolution_in)$fatal(1,"ALIAS controller output evolution_in cycle%0d",alias_cycles);
if(dut.evolution_set !== alias_evolution_set)$fatal(1,"ALIAS controller output evolution_set cycle%0d",alias_cycles);
if(dut.ss_busy !== alias_ss_busy)$fatal(1,"ALIAS controller output ss_busy cycle%0d",alias_cycles);
if(dut.ss_capture_progress !== alias_ss_capture_progress)$fatal(1,"ALIAS controller output ss_capture_progress cycle%0d",alias_cycles);
if(dut.eeprom_ext_in !== alias_eeprom_ext_in)$fatal(1,"ALIAS controller output eeprom_ext_in cycle%0d",alias_cycles);
if(dut.eeprom_full !== alias_eeprom_full)$fatal(1,"ALIAS controller output eeprom_full cycle%0d",alias_cycles);
if(dut.nvram_refill !== alias_nvram_refill)$fatal(1,"ALIAS controller output nvram_refill cycle%0d",alias_cycles);
if(dut.gun_in !== alias_gun_in)$fatal(1,"ALIAS controller output gun_in cycle%0d",alias_cycles);
if(dut.gun_set !== alias_gun_set)$fatal(1,"ALIAS controller output gun_set cycle%0d",alias_cycles);
if(dut.gun_valid !== alias_gun_valid)$fatal(1,"ALIAS controller output gun_valid cycle%0d",alias_cycles);
if(dut.paddle_in !== alias_paddle_in)$fatal(1,"ALIAS controller output paddle_in cycle%0d",alias_cycles);
if(dut.paddle_set !== alias_paddle_set)$fatal(1,"ALIAS controller output paddle_set cycle%0d",alias_cycles);
if(dut.paddle_valid !== alias_paddle_valid)$fatal(1,"ALIAS controller output paddle_valid cycle%0d",alias_cycles);
if(dut.tap_in !== alias_tap_in)$fatal(1,"ALIAS controller output tap_in cycle%0d",alias_cycles);
if(dut.tap_set !== alias_tap_set)$fatal(1,"ALIAS controller output tap_set cycle%0d",alias_cycles);
if(dut.tap_valid !== alias_tap_valid)$fatal(1,"ALIAS controller output tap_valid cycle%0d",alias_cycles);
if(dut.sc_ram_restored !== alias_sc_ram_restored)$fatal(1,"ALIAS controller output sc_ram_restored cycle%0d",alias_cycles);
if(dut.eeprom_in !== alias_eeprom_in)$fatal(1,"ALIAS controller output eeprom_in cycle%0d",alias_cycles);
if(dut.eeprom_set !== alias_eeprom_set)$fatal(1,"ALIAS controller output eeprom_set cycle%0d",alias_cycles);
if(dut.wram_A !== alias_wram_A)$fatal(1,"ALIAS controller output wram_A cycle%0d",alias_cycles);
if(dut.wram_WE !== alias_wram_WE)$fatal(1,"ALIAS controller output wram_WE cycle%0d",alias_cycles);
if(dut.wram_WA !== alias_wram_WA)$fatal(1,"ALIAS controller output wram_WA cycle%0d",alias_cycles);
if(dut.wram_WD !== alias_wram_WD)$fatal(1,"ALIAS controller output wram_WD cycle%0d",alias_cycles);
if(dut.nvram_A !== alias_nvram_A)$fatal(1,"ALIAS controller output nvram_A cycle%0d",alias_cycles);
if(dut.nvram_WE !== alias_nvram_WE)$fatal(1,"ALIAS controller output nvram_WE cycle%0d",alias_cycles);
if(dut.nvram_WA !== alias_nvram_WA)$fatal(1,"ALIAS controller output nvram_WA cycle%0d",alias_cycles);
if(dut.nvram_WD !== alias_nvram_WD)$fatal(1,"ALIAS controller output nvram_WD cycle%0d",alias_cycles);
if(dut.vdp2_regs_in !== alias_vdp2_regs_in)$fatal(1,"ALIAS controller output vdp2_regs_in cycle%0d",alias_cycles);
if(dut.vdp2_regs_set !== alias_vdp2_regs_set)$fatal(1,"ALIAS controller output vdp2_regs_set cycle%0d",alias_cycles);
if(dut.cram2_A !== alias_cram2_A)$fatal(1,"ALIAS controller output cram2_A cycle%0d",alias_cycles);
if(dut.cram2_D !== alias_cram2_D)$fatal(1,"ALIAS controller output cram2_D cycle%0d",alias_cycles);
if(dut.cram2_wr !== alias_cram2_wr)$fatal(1,"ALIAS controller output cram2_wr cycle%0d",alias_cycles);
if(dut.vram2_en !== alias_vram2_en)$fatal(1,"ALIAS controller output vram2_en cycle%0d",alias_cycles);
if(dut.vram2_A !== alias_vram2_A)$fatal(1,"ALIAS controller output vram2_A cycle%0d",alias_cycles);
if(dut.vram2_WE !== alias_vram2_WE)$fatal(1,"ALIAS controller output vram2_WE cycle%0d",alias_cycles);
if(dut.vram2_WA !== alias_vram2_WA)$fatal(1,"ALIAS controller output vram2_WA cycle%0d",alias_cycles);
if(dut.vram2_WD !== alias_vram2_WD)$fatal(1,"ALIAS controller output vram2_WD cycle%0d",alias_cycles);
if(dut.psg2_in !== alias_psg2_in)$fatal(1,"ALIAS controller output psg2_in cycle%0d",alias_cycles);
if(dut.psg2_set !== alias_psg2_set)$fatal(1,"ALIAS controller output psg2_set cycle%0d",alias_cycles);
if(dut.md_in !== alias_md_in)$fatal(1,"ALIAS controller output md_in cycle%0d",alias_cycles);
if(dut.md_set !== alias_md_set)$fatal(1,"ALIAS controller output md_set cycle%0d",alias_cycles);
if(dut.md_valid !== alias_md_valid)$fatal(1,"ALIAS controller output md_valid cycle%0d",alias_cycles);
if(dut.gg_in !== alias_gg_in)$fatal(1,"ALIAS controller output gg_in cycle%0d",alias_cycles);
if(dut.gg_set !== alias_gg_set)$fatal(1,"ALIAS controller output gg_set cycle%0d",alias_cycles);
if(dut.io_in !== alias_io_in)$fatal(1,"ALIAS controller output io_in cycle%0d",alias_cycles);
if(dut.io_set !== alias_io_set)$fatal(1,"ALIAS controller output io_set cycle%0d",alias_cycles);
if(dut.video_state_in !== alias_video_state_in)$fatal(1,"ALIAS controller output video_state_in cycle%0d",alias_cycles);
if(dut.video_state_set !== alias_video_state_set)$fatal(1,"ALIAS controller output video_state_set cycle%0d",alias_cycles);
if(dut.DDRAM_ADDR !== alias_DDRAM_ADDR)$fatal(1,"ALIAS controller output DDRAM_ADDR cycle%0d",alias_cycles);
if(dut.DDRAM_DIN !== alias_DDRAM_DIN)$fatal(1,"ALIAS controller output DDRAM_DIN cycle%0d",alias_cycles);
if(dut.DDRAM_BE !== alias_DDRAM_BE)$fatal(1,"ALIAS controller output DDRAM_BE cycle%0d",alias_cycles);
if(dut.DDRAM_WE !== alias_DDRAM_WE)$fatal(1,"ALIAS controller output DDRAM_WE cycle%0d",alias_cycles);
if(dut.DDRAM_RD !== alias_DDRAM_RD)$fatal(1,"ALIAS controller output DDRAM_RD cycle%0d",alias_cycles);
if(dut.DDRAM_BURSTCNT !== alias_DDRAM_BURSTCNT)$fatal(1,"ALIAS controller output DDRAM_BURSTCNT cycle%0d",alias_cycles);
if(dut.z80_set)begin alias_consumes++;if(dut.z80_dir!==alias_z80_dir)$fatal(1,"ALIAS consumed DIR mismatch");end
else if(dut.z80_dir!==alias_z80_dir)alias_inactive++;
if(dut.DDRAM_WE&&!dut.DDRAM_BUSY)alias_writes++;
if(dut.DDRAM_RD&&!dut.DDRAM_BUSY)alias_reads++;
end
final $display("ALIAS MITER cycles%0d consumes%0d inactive%0d writes%0d reads%0d",alias_cycles,alias_consumes,alias_inactive,alias_writes,alias_reads);
