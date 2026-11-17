module savestates #(parameter CANDIDATE=0) (
 input full_sram_allowed, // fixture eligibility: excludes SC, EEPROM and nonordinary configurations
 input [2:0] restart_out, output [2:0] restart_dir, output restart_valid,
    input             clk,
    input             reset_n,

    // Trigger interface (from savestate_ui)
    input             ss_save,         // one-cycle save pulse
    input             ss_load,         // one-cycle load pulse
    input       [1:0] ss_slot,
    input             ss_bios_mode,    // 1 when running BIOS without cart
    input      [31:0] ss_game_id,      // ROM signature (reject cross-ROM loads)

    // Freeze: hold '1' to pause CPU + VDP clock enables
    output reg        ss_freeze,

    // VBlank level from video.vhd (not gated by ss_freeze)
    // Used to capture save/load at a clean instruction boundary during VBlank
    input             vblank,
    input       [8:0] x,

    // ---- Z80 snapshot / restore ----
    input     [229:0] z80_reg,         // live snapshot from T80s
    output reg [229:0] z80_dir,        // restore data
    output reg        z80_set,         // one-cycle restore strobe
    input             z80_m1_n,        // Z80 M1 cycle (low = opcode fetch in progress)
    // '0' = memory request = normal opcode fetch; '1' = interrupt acknowledge (skip!)
    input             z80_mreq_n,
    // "00" = no active prefix = clean instruction boundary (safe to save)
    input       [1:0] z80_iset,
    // Raw CPU clock-enable pulse (ungated by ss_freeze)
    input             cpu_ce,
    // Raw VDP clock-enable pulse (ungated by ss_freeze)
    input             vdp_ce,
    // Raw PIX clock-enable pulse (ungated by ss_freeze)
    input             pix_ce,
    // Raw SP clock-enable pulse (ungated by ss_freeze)
    input             sp_ce,

    // ---- VDP registers ----
    input     [127:0] vdp_regs,
    output reg [127:0] vdp_regs_in,
    output reg        vdp_regs_set,

    // ---- CRAM ----
    input     [383:0] cram_out,
    output reg  [4:0] cram_A,
    output reg [11:0] cram_D,
    output reg        cram_wr,

    // ---- VRAM DMA (port A of dpram in vdp, muxed when freeze) ----
    output reg        vram_en,         // take over port A for reads
    output reg [14:0] vram_A,          // read address
    input       [7:0] vram_D,          // read data (2-cycle latency after vram_A changes)
    output reg        vram_WE,
    output reg [14:0] vram_WA,
    output reg  [7:0] vram_WD,

    // ---- PSG snapshot / restore ----
    input      [55:0] psg_out,
    output reg [55:0] psg_in,
    output reg        psg_set,

    // Opaque exact audio extension; legacy configuration ports stay unchanged.
    input [95:0] psg_ext_out,
    input [95:0] psg2_ext_out,
    output reg [95:0] psg_ext_in,
    output reg [95:0] psg2_ext_in,
    input [3:0] psg_div_out,
    output reg [3:0] psg_div_in,
    input [10:0] audio_control_out,
    output reg [10:0] audio_control_in,
    input audio_quiescent,
    input audio_phase_out,
    output reg audio_phase_in,
    output reg audio_ext_set,
    output reg audio_phase_set,

    // ---- Mapper snapshot / restore ----
    input      [63:0] mapper_out,
    output reg [63:0] mapper_in,
    output reg        mapper_set,

    // ---- Master System Evolution extra mapper snapshot / restore ----
    // Stored in otherwise-unused IO word bits and the EEPROM word. This keeps
    // the established save/load FSM path unchanged for every other mapper.
    input       [95:0] evolution_out,
    output reg  [95:0] evolution_in,
    output reg         evolution_set,

    // ---- EEPROM snapshot / restore ----
    input      [63:0] eeprom_out,
    output reg [63:0] eeprom_in,
    output reg        eeprom_set,

    // ---- Work RAM DMA (second port of a dpram) ----
    output reg [13:0] wram_A,          // read address (byte)
    input       [7:0] wram_D,          // read data
    output reg        wram_WE,
    output reg [13:0] wram_WA,
    output reg  [7:0] wram_WD,

    // ---- NVRAM DMA (SRAM / NVRAM, up to 32KB) ----
    output reg [14:0] nvram_A,          // read address
    input       [7:0] nvram_D,          // read data
    output reg        nvram_WE,
    output reg [14:0] nvram_WA,
    output reg  [7:0] nvram_WD,

    // ---- System E mode (enables VDP2 / PSG2 / VRAM2 save-restore) ----
    input             systeme,

    // ---- VDP2 registers (System E second VDP) ----
    input     [127:0] vdp2_regs,
    output reg [127:0] vdp2_regs_in,
    output reg        vdp2_regs_set,

    // ---- CRAM2 (System E second VDP colour RAM) ----
    input     [383:0] cram2_out,
    output reg  [4:0] cram2_A,
    output reg [11:0] cram2_D,
    output reg        cram2_wr,

    // ---- VRAM2 DMA (port A of dpram in vdp2, muxed when freeze) ----
    output reg        vram2_en,
    output reg [14:0] vram2_A,
    input       [7:0] vram2_D,
    output reg        vram2_WE,
    output reg [14:0] vram2_WA,
    output reg  [7:0] vram2_WD,

    // ---- PSG2 snapshot / restore (System E second PSG) ----
    input      [55:0] psg2_out,
    output reg [55:0] psg2_in,
    output reg        psg2_set,

    // ---- IO snapshot / restore ----
    input      [31:0] io_out,
    output     [31:0] io_in,
    output reg        io_set,

    // ---- Video State snapshot / restore ----
    input      [21:0] video_state_out,
    output     [21:0] video_state_in,
    output reg        video_state_set,

    // ---- DDRAM interface ----
    output reg [28:0] DDRAM_ADDR,
    output reg [63:0] DDRAM_DIN,
    output reg  [7:0] DDRAM_BE,
    output reg        DDRAM_WE,
    input      [63:0] DDRAM_DOUT,
    input             DDRAM_DOUT_READY,
    output reg        DDRAM_RD,
    output reg  [7:0] DDRAM_BURSTCNT,
    input             DDRAM_BUSY
);
assign restart_dir=0;assign restart_valid=0;wire [2:0] restart_snap=0;wire metadata_invalid=0;
wire [6:0] state;
wire [0:0] do_save;
wire [27:0] op_cooldown;
wire [0:0] is_old_format;
wire [1:0] cpu_idx;
wire [63:0] dout_latch;
wire[7:0] fm_addr;wire fm_rd,fm_wr,fm_reset,fm_init;wire[31:0] fm_wdata;reg[31:0] fm_q=0;reg[31:0] fm_words[0:99];
initial for(integer i=0;i<100;i++)fm_words[i]=0;
always @(posedge clk)begin if(fm_rd)fm_q<=fm_words[fm_addr];if(fm_wr)fm_words[fm_addr]<=fm_wdata;if(fm_reset)for(integer i=0;i<100;i++)fm_words[i]<=0;end
generate if((CANDIDATE&2)==0)begin:B
baseline_controller dut(.clk(clk),.reset_n(reset_n),.ss_save(ss_save),.ss_load(ss_load),.ss_slot(ss_slot),.ss_bios_mode(ss_bios_mode),.ss_game_id(ss_game_id),.ss_freeze(ss_freeze),.vblank(vblank),.x(x),.z80_reg(z80_reg),.z80_dir(z80_dir),.z80_set(z80_set),.z80_m1_n(z80_m1_n),.z80_mreq_n(z80_mreq_n),.z80_iset(z80_iset),.cpu_ce(cpu_ce),.vdp_ce(vdp_ce),.pix_ce(pix_ce),.sp_ce(sp_ce),.vdp_regs(vdp_regs),.vdp_regs_in(vdp_regs_in),.vdp_regs_set(vdp_regs_set),.cram_out(cram_out),.cram_A(cram_A),.cram_D(cram_D),.cram_wr(cram_wr),.vram_en(vram_en),.vram_A(vram_A),.vram_D(vram_D),.vram_WE(vram_WE),.vram_WA(vram_WA),.vram_WD(vram_WD),.psg_out(psg_out),.psg_in(psg_in),.psg_set(psg_set),.psg_ext_out(psg_ext_out),.psg2_ext_out(psg2_ext_out),.psg_ext_in(psg_ext_in),.psg2_ext_in(psg2_ext_in),.psg_div_out(psg_div_out),.psg_div_in(psg_div_in),.audio_control_out(audio_control_out),.audio_control_in(audio_control_in),.audio_quiescent(audio_quiescent),.audio_phase_out(audio_phase_out),.audio_phase_in(audio_phase_in),.audio_ext_set(audio_ext_set),.audio_phase_set(audio_phase_set),.mapper_out(mapper_out),.mapper_in(mapper_in),.mapper_set(mapper_set),.evolution_out(evolution_out),.evolution_in(evolution_in),.evolution_set(evolution_set),.eeprom_out(eeprom_out),.eeprom_in(eeprom_in),.eeprom_set(eeprom_set),.wram_A(wram_A),.wram_D(wram_D),.wram_WE(wram_WE),.wram_WA(wram_WA),.wram_WD(wram_WD),.nvram_A(nvram_A),.nvram_D(nvram_D),.nvram_WE(nvram_WE),.nvram_WA(nvram_WA),.nvram_WD(nvram_WD),.systeme(systeme),.vdp2_regs(vdp2_regs),.vdp2_regs_in(vdp2_regs_in),.vdp2_regs_set(vdp2_regs_set),.cram2_out(cram2_out),.cram2_A(cram2_A),.cram2_D(cram2_D),.cram2_wr(cram2_wr),.vram2_en(vram2_en),.vram2_A(vram2_A),.vram2_D(vram2_D),.vram2_WE(vram2_WE),.vram2_WA(vram2_WA),.vram2_WD(vram2_WD),.psg2_out(psg2_out),.psg2_in(psg2_in),.psg2_set(psg2_set),.io_out(io_out),.io_in(io_in),.io_set(io_set),.video_state_out(video_state_out),.video_state_in(video_state_in),.video_state_set(video_state_set),.DDRAM_ADDR(DDRAM_ADDR),.DDRAM_DIN(DDRAM_DIN),.DDRAM_BE(DDRAM_BE),.DDRAM_WE(DDRAM_WE),.DDRAM_DOUT(DDRAM_DOUT),.DDRAM_DOUT_READY(DDRAM_DOUT_READY),.DDRAM_RD(DDRAM_RD),.DDRAM_BURSTCNT(DDRAM_BURSTCNT),.DDRAM_BUSY(DDRAM_BUSY),.fm_state_addr(fm_addr),.fm_state_read(fm_rd),.fm_state_write(fm_wr),.fm_state_wdata(fm_wdata),.fm_state_rdata(fm_q),.fm_initialized(1'b1),.fm_legacy_reset(fm_reset),.fm_initialization_run(fm_init));
assign state=dut.state;
assign do_save=dut.do_save;
assign op_cooldown=dut.op_cooldown;
assign is_old_format=dut.is_old_format;
assign cpu_idx=dut.cpu_idx;
assign dout_latch=dut.dout_latch;
end else begin:F
candidate_controller dut(.clk(clk),.reset_n(reset_n),.ss_save(ss_save),.ss_load(ss_load),.ss_slot(ss_slot),.ss_bios_mode(ss_bios_mode),.ss_game_id(ss_game_id),.ss_freeze(ss_freeze),.vblank(vblank),.x(x),.z80_reg(z80_reg),.z80_dir(z80_dir),.z80_set(z80_set),.z80_m1_n(z80_m1_n),.z80_mreq_n(z80_mreq_n),.z80_iset(z80_iset),.cpu_ce(cpu_ce),.vdp_ce(vdp_ce),.pix_ce(pix_ce),.sp_ce(sp_ce),.vdp_regs(vdp_regs),.vdp_regs_in(vdp_regs_in),.vdp_regs_set(vdp_regs_set),.cram_out(cram_out),.cram_A(cram_A),.cram_D(cram_D),.cram_wr(cram_wr),.vram_en(vram_en),.vram_A(vram_A),.vram_D(vram_D),.vram_WE(vram_WE),.vram_WA(vram_WA),.vram_WD(vram_WD),.psg_out(psg_out),.psg_in(psg_in),.psg_set(psg_set),.psg_ext_out(psg_ext_out),.psg2_ext_out(psg2_ext_out),.psg_ext_in(psg_ext_in),.psg2_ext_in(psg2_ext_in),.psg_div_out(psg_div_out),.psg_div_in(psg_div_in),.audio_control_out(audio_control_out),.audio_control_in(audio_control_in),.audio_quiescent(audio_quiescent),.audio_phase_out(audio_phase_out),.audio_phase_in(audio_phase_in),.audio_ext_set(audio_ext_set),.audio_phase_set(audio_phase_set),.mapper_out(mapper_out),.mapper_in(mapper_in),.mapper_set(mapper_set),.evolution_out(evolution_out),.evolution_in(evolution_in),.evolution_set(evolution_set),.eeprom_out(eeprom_out),.eeprom_in(eeprom_in),.eeprom_set(eeprom_set),.wram_A(wram_A),.wram_D(wram_D),.wram_WE(wram_WE),.wram_WA(wram_WA),.wram_WD(wram_WD),.nvram_A(nvram_A),.nvram_D(nvram_D),.nvram_WE(nvram_WE),.nvram_WA(nvram_WA),.nvram_WD(nvram_WD),.systeme(systeme),.vdp2_regs(vdp2_regs),.vdp2_regs_in(vdp2_regs_in),.vdp2_regs_set(vdp2_regs_set),.cram2_out(cram2_out),.cram2_A(cram2_A),.cram2_D(cram2_D),.cram2_wr(cram2_wr),.vram2_en(vram2_en),.vram2_A(vram2_A),.vram2_D(vram2_D),.vram2_WE(vram2_WE),.vram2_WA(vram2_WA),.vram2_WD(vram2_WD),.psg2_out(psg2_out),.psg2_in(psg2_in),.psg2_set(psg2_set),.io_out(io_out),.io_in(io_in),.io_set(io_set),.video_state_out(video_state_out),.video_state_in(video_state_in),.video_state_set(video_state_set),.DDRAM_ADDR(DDRAM_ADDR),.DDRAM_DIN(DDRAM_DIN),.DDRAM_BE(DDRAM_BE),.DDRAM_WE(DDRAM_WE),.DDRAM_DOUT(DDRAM_DOUT),.DDRAM_DOUT_READY(DDRAM_DOUT_READY),.DDRAM_RD(DDRAM_RD),.DDRAM_BURSTCNT(DDRAM_BURSTCNT),.DDRAM_BUSY(DDRAM_BUSY),.fm_state_addr(fm_addr),.fm_state_read(fm_rd),.fm_state_write(fm_wr),.fm_state_wdata(fm_wdata),.fm_state_rdata(fm_q),.fm_initialized(1'b1),.fm_legacy_reset(fm_reset),.fm_initialization_run(fm_init),.sc3000_mode(!full_sram_allowed),.eeprom_present(1'b0));
assign state=dut.state;
assign do_save=dut.do_save;
assign op_cooldown=dut.op_cooldown;
assign is_old_format=dut.is_old_format;
assign cpu_idx=dut.cpu_idx;
assign dout_latch=dut.dout_latch;
end endgenerate
endmodule
