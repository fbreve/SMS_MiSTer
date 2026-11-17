`timescale 1ns/1ps
module vdp_tb;
reg[4777:0]expected1,expected2;wire[4799:0]padded1={22'd0,expected1},padded2={22'd0,expected2};reg[63:0]saved_image[0:12287]; parameter GG=1,PAL=0,REQUEST_X=40,SPRITE_X=120,SPRITES=2,REPLAYS=3,REFERENCE=0,PROTO=1,TURBO=1,SAVE_ONLY=0,DIAGNOSTIC=0,SAVE_PHASE=-1,COMMON_PHASE=0,FIX=1,SCAN_MASK=0,SLOTS=8,EXT_REFERENCE=0,PHASE_SWEEP=0,WARMUP=0,PAUSE_CAPTURE=0,NATURAL_PHASE=0;
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
reg audio_phase_out = '0;
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
reg[4777:0]random_sprite1=0,random_sprite2=0;
wire  golden_ss_freeze;
wire  golden_ss_cpu_prepare;
wire  golden_z80_replay_t2;
wire [1:0] golden_clock_phase_in;
wire  golden_clock_phase_set;
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
reg extra_profiles=0;reg[31:0]rng=32'h9e3779b9;
reg[63:0]mem[0:12287];integer pending=0;reg[28:0]readaddr;
always@(posedge clk)begin
 DDRAM_DOUT_READY<=0;
 if(pending>0)begin pending<=pending-1;if(pending==1)begin DDRAM_DOUT<=mem[readaddr-29'h07c00000];DDRAM_DOUT_READY<=1;end end
 if(DDRAM_WE&&!DDRAM_BUSY)for(integer b=0;b<8;b++)if(DDRAM_BE[b])mem[DDRAM_ADDR-29'h07c00000][b*8+:8]<=DDRAM_DIN[b*8+:8];
 if(DDRAM_RD&&!DDRAM_BUSY)begin if(pending)$fatal(1,"overlapping read");pending<=extra_profiles?3+(rng[7:4]):3;readaddr<=DDRAM_ADDR;end
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
reg[63:0]oldtag;
initial begin
 for(integer i=0;i<12288;i++)mem[i]=0;
 repeat(4)tick;reset_n=1;transfer(1);
 if(mem['h1a][63:40]!==24'h48430e||mem['h2e]!==64'h12aa0e0047365231||mem['h2f]!==8)$fatal(1,"v14 format writer");
 transfer(0);if(!guest_writes||!sprite_valid)$fatal(1,"valid v14 rejected");accepted++;
 for(integer b=0;b<64;b++)reject_bit('h2e,b);
 for(integer b=4;b<64;b++)reject_bit('h2f,b);
 reject_bit('h2f,2);
 for(integer b=42;b<64;b++)begin reject_bit('h294b,b);reject_bit('h2996,b);end
 reject_bit('h294c,0);
 // Every inherited tagged format retains its prior normalization policy.
 oldtag=mem['h1a];
 for(integer version=1;version<=13;version++)begin
  mem['h1a][63:40]=24'h484300+version;mem['h1a][39:38]=version==1?0:version==2?2:3;
  transfer(0);if(!guest_writes||sprite_valid||sprite_restored!==0)$fatal(1,"legacy normalization version%0d",version);
  accepted++;$display("LEGACY_ACCEPT version%0d",version);
 end
 mem['h1a]=oldtag;mem['h2f][3]=0;
 transfer(0);if(!guest_writes||replay_t2!==0)$fatal(1,"stopped capture flag rejected");accepted++;

 $display("PASS V14 FORMAT rejected%0d accepted%0d",rejections,accepted);
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
  for(integer wordnum=0;wordnum<75;wordnum++)begin
   if(mem['h2901+wordnum]!==padded1[64*wordnum+:64]||mem['h294c+wordnum]!==padded2[64*wordnum+:64])$fatal(1,"full physical record writer profile%0d word%0d",profile,wordnum);
  end
  for(integer wordnum=0;wordnum<12288;wordnum++)saved_image[wordnum]=mem[wordnum];
  random_sprite1=~random_sprite1;random_sprite2=~random_sprite2;
  for(integer replaynum=0;replaynum<3;replaynum++)begin
   transfer(0);
   if(sprite_restored!==expected1||new_sprite2_in!==expected2)$fatal(1,"full physical record restore profile%0d replay%0d",profile,replaynum);
   for(integer wordnum=0;wordnum<12288;wordnum++)if(mem[wordnum]!==saved_image[wordnum])$fatal(1,"transport changed image");
  end
  $display("TRANSPORT_PROFILE PASS %0d systeme%b consumed%b",profile,systeme,!logical_pause);
 end
 $display("PASS TRANSPORT STREAM EQUIVALENCE outputs%0d format185 profiles16 loads48 physicalbits9556",91);$finish;

end
initial begin #100000000;$fatal(1,"format watchdog");end

always@(negedge clk)if(extra_profiles)begin rng={rng[30:0],rng[31]^rng[21]^rng[1]^rng[0]};DDRAM_BUSY<=rng[2:0]==0;end
always@(negedge clk)if(reset_n)begin
 if(dut.state!==golden.state)$fatal(1,"transport FSM cycle differs %0d/%0d",dut.state,golden.state);
 if(1'b1 && (ss_freeze !== golden_ss_freeze))$fatal(1,"transport output ss_freeze mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (cpu_prepare !== golden_ss_cpu_prepare))$fatal(1,"transport output ss_cpu_prepare mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (replay_t2 !== golden_z80_replay_t2))$fatal(1,"transport output z80_replay_t2 mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (phase_in !== golden_clock_phase_in))$fatal(1,"transport output clock_phase_in mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (phase_set !== golden_clock_phase_set))$fatal(1,"transport output clock_phase_set mismatch state%0d golden%0d",dut.state,golden.state);
 if(vdp_regs_set && (sprite_restored !== golden_sprite_in))$fatal(1,"transport output sprite_in mismatch state%0d golden%0d",dut.state,golden.state);
 if(vdp2_regs_set && (new_sprite2_in !== golden_sprite2_in))$fatal(1,"transport output sprite2_in mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (sprite_valid !== golden_sprite_valid))$fatal(1,"transport output sprite_valid mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (new_z80_restart_dir !== golden_z80_restart_dir))$fatal(1,"transport output z80_restart_dir mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (new_z80_restart_valid !== golden_z80_restart_valid))$fatal(1,"transport output z80_restart_valid mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (new_z80_nmi_dir !== golden_z80_nmi_dir))$fatal(1,"transport output z80_nmi_dir mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (new_z80_nmi_valid !== golden_z80_nmi_valid))$fatal(1,"transport output z80_nmi_valid mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (new_z80_nmi_hold !== golden_z80_nmi_hold))$fatal(1,"transport output z80_nmi_hold mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (z80_dir !== golden_z80_dir))$fatal(1,"transport output z80_dir mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (z80_set !== golden_z80_set))$fatal(1,"transport output z80_set mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (vdp_regs_in !== golden_vdp_regs_in))$fatal(1,"transport output vdp_regs_in mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (vdp_regs_set !== golden_vdp_regs_set))$fatal(1,"transport output vdp_regs_set mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (cram_A !== golden_cram_A))$fatal(1,"transport output cram_A mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (cram_D !== golden_cram_D))$fatal(1,"transport output cram_D mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (cram_wr !== golden_cram_wr))$fatal(1,"transport output cram_wr mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (vram_en !== golden_vram_en))$fatal(1,"transport output vram_en mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (vram_A !== golden_vram_A))$fatal(1,"transport output vram_A mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (vram_WE !== golden_vram_WE))$fatal(1,"transport output vram_WE mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (vram_WA !== golden_vram_WA))$fatal(1,"transport output vram_WA mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (vram_WD !== golden_vram_WD))$fatal(1,"transport output vram_WD mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (psg_in !== golden_psg_in))$fatal(1,"transport output psg_in mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (psg_set !== golden_psg_set))$fatal(1,"transport output psg_set mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (psg_ext_in !== golden_psg_ext_in))$fatal(1,"transport output psg_ext_in mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (psg2_ext_in !== golden_psg2_ext_in))$fatal(1,"transport output psg2_ext_in mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (psg_div_in !== golden_psg_div_in))$fatal(1,"transport output psg_div_in mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (audio_control_in !== golden_audio_control_in))$fatal(1,"transport output audio_control_in mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (audio_phase_in !== golden_audio_phase_in))$fatal(1,"transport output audio_phase_in mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (audio_ext_set !== golden_audio_ext_set))$fatal(1,"transport output audio_ext_set mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (audio_phase_set !== golden_audio_phase_set))$fatal(1,"transport output audio_phase_set mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (new_mapper_history_in !== golden_mapper_history_in))$fatal(1,"transport output mapper_history_in mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (mapper_in !== golden_mapper_in))$fatal(1,"transport output mapper_in mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (mapper_set !== golden_mapper_set))$fatal(1,"transport output mapper_set mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (evolution_in !== golden_evolution_in))$fatal(1,"transport output evolution_in mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (evolution_set !== golden_evolution_set))$fatal(1,"transport output evolution_set mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (ss_busy !== golden_ss_busy))$fatal(1,"transport output ss_busy mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (ss_capture_progress !== golden_ss_capture_progress))$fatal(1,"transport output ss_capture_progress mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (eeprom_ext_in !== golden_eeprom_ext_in))$fatal(1,"transport output eeprom_ext_in mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (eeprom_full !== golden_eeprom_full))$fatal(1,"transport output eeprom_full mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (nvram_refill !== golden_nvram_refill))$fatal(1,"transport output nvram_refill mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (gun_in !== golden_gun_in))$fatal(1,"transport output gun_in mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (gun_set !== golden_gun_set))$fatal(1,"transport output gun_set mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (gun_valid !== golden_gun_valid))$fatal(1,"transport output gun_valid mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (paddle_in !== golden_paddle_in))$fatal(1,"transport output paddle_in mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (paddle_set !== golden_paddle_set))$fatal(1,"transport output paddle_set mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (paddle_valid !== golden_paddle_valid))$fatal(1,"transport output paddle_valid mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (tap_in !== golden_tap_in))$fatal(1,"transport output tap_in mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (tap_set !== golden_tap_set))$fatal(1,"transport output tap_set mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (tap_valid !== golden_tap_valid))$fatal(1,"transport output tap_valid mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (sc_ram_restored !== golden_sc_ram_restored))$fatal(1,"transport output sc_ram_restored mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (eeprom_in !== golden_eeprom_in))$fatal(1,"transport output eeprom_in mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (eeprom_set !== golden_eeprom_set))$fatal(1,"transport output eeprom_set mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (wram_A !== golden_wram_A))$fatal(1,"transport output wram_A mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (wram_WE !== golden_wram_WE))$fatal(1,"transport output wram_WE mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (wram_WA !== golden_wram_WA))$fatal(1,"transport output wram_WA mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (wram_WD !== golden_wram_WD))$fatal(1,"transport output wram_WD mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (nvram_A !== golden_nvram_A))$fatal(1,"transport output nvram_A mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (nvram_WE !== golden_nvram_WE))$fatal(1,"transport output nvram_WE mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (nvram_WA !== golden_nvram_WA))$fatal(1,"transport output nvram_WA mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (nvram_WD !== golden_nvram_WD))$fatal(1,"transport output nvram_WD mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (vdp2_regs_in !== golden_vdp2_regs_in))$fatal(1,"transport output vdp2_regs_in mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (vdp2_regs_set !== golden_vdp2_regs_set))$fatal(1,"transport output vdp2_regs_set mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (cram2_A !== golden_cram2_A))$fatal(1,"transport output cram2_A mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (cram2_D !== golden_cram2_D))$fatal(1,"transport output cram2_D mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (cram2_wr !== golden_cram2_wr))$fatal(1,"transport output cram2_wr mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (vram2_en !== golden_vram2_en))$fatal(1,"transport output vram2_en mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (vram2_A !== golden_vram2_A))$fatal(1,"transport output vram2_A mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (vram2_WE !== golden_vram2_WE))$fatal(1,"transport output vram2_WE mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (vram2_WA !== golden_vram2_WA))$fatal(1,"transport output vram2_WA mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (vram2_WD !== golden_vram2_WD))$fatal(1,"transport output vram2_WD mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (psg2_in !== golden_psg2_in))$fatal(1,"transport output psg2_in mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (psg2_set !== golden_psg2_set))$fatal(1,"transport output psg2_set mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (md_in !== golden_md_in))$fatal(1,"transport output md_in mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (md_set !== golden_md_set))$fatal(1,"transport output md_set mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (md_valid !== golden_md_valid))$fatal(1,"transport output md_valid mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (gg_in !== golden_gg_in))$fatal(1,"transport output gg_in mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (gg_set !== golden_gg_set))$fatal(1,"transport output gg_set mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (io_in !== golden_io_in))$fatal(1,"transport output io_in mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (io_set !== golden_io_set))$fatal(1,"transport output io_set mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (video_state_in !== golden_video_state_in))$fatal(1,"transport output video_state_in mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (video_state_set !== golden_video_state_set))$fatal(1,"transport output video_state_set mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (DDRAM_ADDR !== golden_DDRAM_ADDR))$fatal(1,"transport output DDRAM_ADDR mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (DDRAM_DIN !== golden_DDRAM_DIN))$fatal(1,"transport output DDRAM_DIN mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (DDRAM_BE !== golden_DDRAM_BE))$fatal(1,"transport output DDRAM_BE mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (DDRAM_WE !== golden_DDRAM_WE))$fatal(1,"transport output DDRAM_WE mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (DDRAM_RD !== golden_DDRAM_RD))$fatal(1,"transport output DDRAM_RD mismatch state%0d golden%0d",dut.state,golden.state);
 if(1'b1 && (DDRAM_BURSTCNT !== golden_DDRAM_BURSTCNT))$fatal(1,"transport output DDRAM_BURSTCNT mismatch state%0d golden%0d",dut.state,golden.state);
end
endmodule
