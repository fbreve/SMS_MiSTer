wire [2:0] ss_restart_out;
wire [2:0] ss_restart_dir;
wire  ss_restart_valid;
wire  ss_clk;
wire  ss_reset_n;
wire  ss_ss_save;
wire  ss_ss_load;
wire [1:0] ss_ss_slot;
wire  ss_ss_bios_mode;
wire [31:0] ss_ss_game_id;
wire  ss_ss_freeze;
wire  ss_vblank;
wire [8:0] ss_x;
wire [229:0] ss_z80_reg;
wire [229:0] ss_z80_dir;
wire  ss_z80_set;
wire  ss_z80_m1_n;
wire  ss_z80_mreq_n;
wire [1:0] ss_z80_iset;
wire  ss_cpu_ce;
wire  ss_vdp_ce;
wire  ss_pix_ce;
wire  ss_sp_ce;
wire [127:0] ss_vdp_regs;
wire [127:0] ss_vdp_regs_in;
wire  ss_vdp_regs_set;
wire [383:0] ss_cram_out;
wire [4:0] ss_cram_A;
wire [11:0] ss_cram_D;
wire  ss_cram_wr;
wire  ss_vram_en;
wire [14:0] ss_vram_A;
wire [7:0] ss_vram_D;
wire  ss_vram_WE;
wire [14:0] ss_vram_WA;
wire [7:0] ss_vram_WD;
wire [55:0] ss_psg_out;
wire [55:0] ss_psg_in;
wire  ss_psg_set;
wire [95:0] ss_psg_ext_out;
wire [95:0] ss_psg2_ext_out;
wire [95:0] ss_psg_ext_in;
wire [95:0] ss_psg2_ext_in;
wire [3:0] ss_psg_div_out;
wire [3:0] ss_psg_div_in;
wire [10:0] ss_audio_control_out;
wire [10:0] ss_audio_control_in;
wire  ss_audio_quiescent;
wire  ss_audio_phase_out;
wire  ss_audio_phase_in;
wire  ss_audio_ext_set;
wire  ss_audio_phase_set;
wire [63:0] ss_mapper_out;
wire [63:0] ss_mapper_in;
wire  ss_mapper_set;
wire [95:0] ss_evolution_out;
wire [95:0] ss_evolution_in;
wire  ss_evolution_set;
wire [63:0] ss_eeprom_out;
wire [63:0] ss_eeprom_in;
wire  ss_eeprom_set;
wire [13:0] ss_wram_A;
wire [7:0] ss_wram_D;
wire  ss_wram_WE;
wire [13:0] ss_wram_WA;
wire [7:0] ss_wram_WD;
wire [14:0] ss_nvram_A;
wire [7:0] ss_nvram_D;
wire  ss_nvram_WE;
wire [14:0] ss_nvram_WA;
wire [7:0] ss_nvram_WD;
wire  ss_systeme;
wire [127:0] ss_vdp2_regs;
wire [127:0] ss_vdp2_regs_in;
wire  ss_vdp2_regs_set;
wire [383:0] ss_cram2_out;
wire [4:0] ss_cram2_A;
wire [11:0] ss_cram2_D;
wire  ss_cram2_wr;
wire  ss_vram2_en;
wire [14:0] ss_vram2_A;
wire [7:0] ss_vram2_D;
wire  ss_vram2_WE;
wire [14:0] ss_vram2_WA;
wire [7:0] ss_vram2_WD;
wire [55:0] ss_psg2_out;
wire [55:0] ss_psg2_in;
wire  ss_psg2_set;
wire [31:0] ss_io_out;
wire [31:0] ss_io_in;
wire  ss_io_set;
wire [21:0] ss_video_state_out;
wire [21:0] ss_video_state_in;
wire  ss_video_state_set;
wire [28:0] ss_DDRAM_ADDR;
wire [63:0] ss_DDRAM_DIN;
wire [7:0] ss_DDRAM_BE;
wire  ss_DDRAM_WE;
wire [63:0] ss_DDRAM_DOUT;
wire  ss_DDRAM_DOUT_READY;
wire  ss_DDRAM_RD;
wire [7:0] ss_DDRAM_BURSTCNT;
wire  ss_DDRAM_BUSY;
assign ss_restart_out=restart_ctx;
assign ss_clk=clk;
assign ss_reset_n=reset_n;
assign ss_ss_save=save_req;
assign ss_ss_load=load_req;
assign ss_ss_slot=2'd0;
assign ss_ss_bios_mode=1'b0;
assign ss_ss_game_id=game_id;
assign ss_vblank=vb;
assign ss_x=x;
assign ss_z80_reg=cpu_regs;
assign ss_z80_m1_n=m1_n;
assign ss_z80_mreq_n=mreq_n;
assign ss_z80_iset=iset;
assign ss_cpu_ce=ce_cpu;
assign ss_vdp_ce=ce_vdp;
assign ss_pix_ce=ce_pix;
assign ss_sp_ce=ce_sp;
assign ss_vdp_regs=vdp_regs;
assign ss_cram_out=cram;
assign ss_vram_D=vram_dma_d;
assign ss_psg_out='0;
assign ss_psg_ext_out='0;
assign ss_psg2_ext_out='0;
assign ss_psg_div_out='0;
assign ss_audio_control_out='0;
assign ss_audio_quiescent=1'b1;
assign ss_audio_phase_out='0;
assign ss_mapper_out=mapper_word;
assign ss_evolution_out='0;
assign ss_eeprom_out='0;
assign ss_wram_D=wram_q;
assign ss_nvram_D=sram_q;
assign ss_systeme='0;
assign ss_vdp2_regs='0;
assign ss_cram2_out='0;
assign ss_vram2_D='0;
assign ss_psg2_out='0;
assign ss_io_out=io_word;
assign ss_video_state_out=video_word;
assign ss_DDRAM_DOUT=ddr_out;
assign ss_DDRAM_DOUT_READY=ddr_ready;
assign ss_DDRAM_BUSY=1'b0;
savestates #(.CANDIDATE(CANDIDATE)) controller(.full_sram_allowed(full_sram_allowed),
.restart_out(ss_restart_out),
.restart_dir(ss_restart_dir),
.restart_valid(ss_restart_valid),
.clk(ss_clk),
.reset_n(ss_reset_n),
.ss_save(ss_ss_save),
.ss_load(ss_ss_load),
.ss_slot(ss_ss_slot),
.ss_bios_mode(ss_ss_bios_mode),
.ss_game_id(ss_ss_game_id),
.ss_freeze(ss_ss_freeze),
.vblank(ss_vblank),
.x(ss_x),
.z80_reg(ss_z80_reg),
.z80_dir(ss_z80_dir),
.z80_set(ss_z80_set),
.z80_m1_n(ss_z80_m1_n),
.z80_mreq_n(ss_z80_mreq_n),
.z80_iset(ss_z80_iset),
.cpu_ce(ss_cpu_ce),
.vdp_ce(ss_vdp_ce),
.pix_ce(ss_pix_ce),
.sp_ce(ss_sp_ce),
.vdp_regs(ss_vdp_regs),
.vdp_regs_in(ss_vdp_regs_in),
.vdp_regs_set(ss_vdp_regs_set),
.cram_out(ss_cram_out),
.cram_A(ss_cram_A),
.cram_D(ss_cram_D),
.cram_wr(ss_cram_wr),
.vram_en(ss_vram_en),
.vram_A(ss_vram_A),
.vram_D(ss_vram_D),
.vram_WE(ss_vram_WE),
.vram_WA(ss_vram_WA),
.vram_WD(ss_vram_WD),
.psg_out(ss_psg_out),
.psg_in(ss_psg_in),
.psg_set(ss_psg_set),
.psg_ext_out(ss_psg_ext_out),
.psg2_ext_out(ss_psg2_ext_out),
.psg_ext_in(ss_psg_ext_in),
.psg2_ext_in(ss_psg2_ext_in),
.psg_div_out(ss_psg_div_out),
.psg_div_in(ss_psg_div_in),
.audio_control_out(ss_audio_control_out),
.audio_control_in(ss_audio_control_in),
.audio_quiescent(ss_audio_quiescent),
.audio_phase_out(ss_audio_phase_out),
.audio_phase_in(ss_audio_phase_in),
.audio_ext_set(ss_audio_ext_set),
.audio_phase_set(ss_audio_phase_set),
.mapper_out(ss_mapper_out),
.mapper_in(ss_mapper_in),
.mapper_set(ss_mapper_set),
.evolution_out(ss_evolution_out),
.evolution_in(ss_evolution_in),
.evolution_set(ss_evolution_set),
.eeprom_out(ss_eeprom_out),
.eeprom_in(ss_eeprom_in),
.eeprom_set(ss_eeprom_set),
.wram_A(ss_wram_A),
.wram_D(ss_wram_D),
.wram_WE(ss_wram_WE),
.wram_WA(ss_wram_WA),
.wram_WD(ss_wram_WD),
.nvram_A(ss_nvram_A),
.nvram_D(ss_nvram_D),
.nvram_WE(ss_nvram_WE),
.nvram_WA(ss_nvram_WA),
.nvram_WD(ss_nvram_WD),
.systeme(ss_systeme),
.vdp2_regs(ss_vdp2_regs),
.vdp2_regs_in(ss_vdp2_regs_in),
.vdp2_regs_set(ss_vdp2_regs_set),
.cram2_out(ss_cram2_out),
.cram2_A(ss_cram2_A),
.cram2_D(ss_cram2_D),
.cram2_wr(ss_cram2_wr),
.vram2_en(ss_vram2_en),
.vram2_A(ss_vram2_A),
.vram2_D(ss_vram2_D),
.vram2_WE(ss_vram2_WE),
.vram2_WA(ss_vram2_WA),
.vram2_WD(ss_vram2_WD),
.psg2_out(ss_psg2_out),
.psg2_in(ss_psg2_in),
.psg2_set(ss_psg2_set),
.io_out(ss_io_out),
.io_in(ss_io_in),
.io_set(ss_io_set),
.video_state_out(ss_video_state_out),
.video_state_in(ss_video_state_in),
.video_state_set(ss_video_state_set),
.DDRAM_ADDR(ss_DDRAM_ADDR),
.DDRAM_DIN(ss_DDRAM_DIN),
.DDRAM_BE(ss_DDRAM_BE),
.DDRAM_WE(ss_DDRAM_WE),
.DDRAM_DOUT(ss_DDRAM_DOUT),
.DDRAM_DOUT_READY(ss_DDRAM_DOUT_READY),
.DDRAM_RD(ss_DDRAM_RD),
.DDRAM_BURSTCNT(ss_DDRAM_BURSTCNT),
.DDRAM_BUSY(ss_DDRAM_BUSY)
);
