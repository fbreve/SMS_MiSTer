// savestates.sv
// Pure-hardware save-state FSM for SMS_MiSTer.
//
// Memory layout (DDRAM word addresses, slot n base = 0x3E000000 + n*0x10000):
//   Word 0x000: MiSTer SS control word [31:0]=change_det, [63:32]=size_in_32b_words
//   Word 0x001: [31:0]=magic ("SMS1"/"SMSB"), [63:32]=game signature
//   Word 0x002-0x005: Z80 REG[229:0]; v12 word5[40:38]=NMI pending/entry/Old,
//                   v13 word5[43:41]=pre-T2 decoder class; [63:44]=zero.
//                   v13 tag=48430d, subtype=3 at word01a. v12 has zero [63:41].
//   v15 tag=48430f adds139-bit background records, retaining v14 restart.
//   Word032: width139/version15/G5B1; words033..038: two padded records.
//   v14 tag=48430e, subtype3, retaining the v13 CPU word layout.
//   Word 0x02e: sprite descriptor (width4778, version14, owner G6R1).
//   Word 0x02f: [1:0] capture phase0/10/20/25, [2] System E,
//               [3] CPU consumed capture enable, [63:4] zero.
//   Words 0x2901-0x2996: two padded4778-bit sprite records (75 words each).
//   Word 0x006-0x007: VDP regs [127:0] (2 × 64-bit words)
//   Word 0x008-0x00D: CRAM [383:0]     (6 × 64-bit words)
//   Word 0x00E:       PSG  [55:0]      (1 × 64-bit word, upper 8 bits unused)
//   Word 0x00F:       Mapper [63:0]    (1 × 64-bit word)
//   Word 0x010-0x011: VDP2 regs [127:0] (System E only; 2 × 64-bit words)
//   Word 0x012-0x017: CRAM2 [383:0]   (System E only; 6 × 64-bit words)
//   Word 0x018:       PSG2 [55:0]     (System E only; 1 × 64-bit word)
//   Words 0x101-0x900: VRAM 16KB       (2048 × 64-bit words)
//   Words 0x901-0xD00: WRAM 8KB        (1024 × 64-bit words) [SMS/GG]
//   Words 0x901-0x1100: WRAM 16KB      (2048 × 64-bit words) [System E; reuses NVRAM region]
//   Words 0xD01-0x1100: NVRAM 8KB (Dahjee A only; mutually exclusive with System E)
//   Words 0x1101-0x1900: VRAM2 16KB    (System E only; 2048 × 64-bit words)
//   Words 0x1901-0x2100: VDP1 passive 16KB (System E only; inline; written to SD)
//   Words 0x2101-0x2900: VDP2 passive 16KB (System E only; inline; written to SD)
//
// Slot size = 0x3000 words = 96KB.  Up to 4 slots.
// Base word address = 29'h07C00000 + slot * 29'h3000

module savestates (
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
    // Private CPU historical-T1/T2 reconstruction. All guest domains stay held.
    output reg        ss_cpu_prepare,
    input             z80_replay,
    input             z80_tick_active,
    output            z80_replay_t2,
    input       [1:0] clock_phase,
    output      [1:0] clock_phase_in,
    output reg        clock_phase_set,
    input             clock_phase_ready,
    // v15 minimal live background history, independently owned per VDP.
    input [138:0] bg_out, bg2_out,
    output [138:0] bg_in, bg2_in,
    output bg_valid,
    input [4777:0] sprite_out, sprite2_out,
    output [4777:0] sprite_in, sprite2_in,
    output sprite_valid,

    // VBlank level from video.vhd (not gated by ss_freeze)
    // Used to capture save/load at a clean instruction boundary during VBlank
    input             vblank,
    input       [8:0] x,

    // ---- Z80 snapshot / restore ----
    input       [2:0] z80_restart,     // pre-T2 decoder class, not the new opcode
    output      [2:0] z80_restart_dir,
    output            z80_restart_valid,
    input       [2:0] z80_nmi,         // normalized post-sample history at accepted MC1/T2
    output      [2:0] z80_nmi_dir,
    output            z80_nmi_valid,
    output reg        z80_nmi_hold,
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
    input     [135:0] vdp_regs,
    output reg [135:0] vdp_regs_in,
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
    input      [17:0] mapper_history_out,
    output reg [17:0] mapper_history_in,
    output reg [63:0] mapper_in,
    output reg        mapper_set,

    // ---- Master System Evolution extra mapper snapshot / restore ----
    // Low 96 bits retain the IO/EEPROM word layout. v10 stores the additional
    // 57 selector/history bits at 02c, validated by the descriptor at 02d.
    input      [159:0] evolution_out,
    output reg [159:0] evolution_in,
    output reg         evolution_set,

    // ---- EEPROM snapshot / restore ----
    input             storage_busy,
    output            ss_busy,
    output            ss_capture_progress,
    input             eeprom_present,
    input     [127:0] eeprom_ext_out,
    output reg [127:0] eeprom_ext_in,
    output reg        eeprom_full,
    output reg        nvram_refill,
    // Lightgun guest beam/pulse history, excluding host input and crosshair.
    input [45:0] gun_out,
    output reg [45:0] gun_in,
    output reg gun_set,
    output reg gun_valid,
    // Exact local paddle history and shared divider; raw position stays external.
    input      [31:0] paddle_out,
    output reg [31:0] paddle_in,
    output reg        paddle_set,
    output reg        paddle_valid,
    input      [18:0] tap_out,
    output reg [18:0] tap_in,
    output reg        tap_set,
    output reg        tap_valid,
    input       [1:0] sc_ram_size, // 00 absent, 01 2 KiB, 10 16 KiB, 11 32 KiB
    output reg        sc_ram_restored,
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
    input     [135:0] vdp2_regs,
    output reg [135:0] vdp2_regs_in,
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
    input     [45:0] md_out,
    output reg [45:0] md_in,
    output reg md_set,
    output reg md_valid,
    input     [127:0] gg_out,
    output reg [127:0] gg_in,
    output reg        gg_set,
    input      [31:0] io_out,
    output reg [31:0] io_in,
    output reg        io_set,

    // ---- Video State snapshot / restore ----
    input      [21:0] video_state_out,
    output reg [21:0] video_state_in,
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

// -----------------------------------------------------------------------
// Helpers
// -----------------------------------------------------------------------
localparam [31:0] MAGIC = 32'h534D5331; // "SMS1"
localparam [31:0] MAGIC_BIOS = 32'h534D5342; // "SMSB"

// Word 0 header size field (size in 32-bit words = (slot_bytes - 8) / 4).
localparam [31:0] OLD_SS_WORDS = 32'd16382; // 0x3FFE, old 64KB slot format (#191)
localparam [31:0] NEW_SS_WORDS = 32'd24574; // 0x5FFE, current 96KB slot format

// Slot base word address for cartridge savestates (slots 0-3).
// Slot size 0x3000 words (96KB) to accommodate inline passive VRAM banks.
function automatic [28:0] slot_base;
    input [1:0] slot;
    slot_base = 29'h07C00000 + {27'd0, slot} * 29'h3000;
endfunction

// Slot base word address for BIOS savestates.
// Placed after the 4 game slots (4 × 0x3000 = 0xC000 words above base).
// Addresses here are outside the CONF_STR SS range so the
// MiSTer ARM side will not write them to disk -- BIOS states are DDRAM-only.
function automatic [28:0] bios_slot_base;
    input [1:0] slot;
    bios_slot_base = 29'h07C0C000 + {27'd0, slot} * 29'h3000;
endfunction

// -----------------------------------------------------------------------
// State machine
// -----------------------------------------------------------------------
localparam ST_IDLE         = 6'd0;
localparam ST_WAIT_BOUNDARY= 6'd37;  // wait for Z80 instruction boundary (M1)
localparam ST_ARM_FREEZE   = 6'd41;  // assert freeze so it is active before next CE pulse
localparam ST_FREEZE_DRAIN = 6'd54;  // drain in-flight DDRAM replies before SS transactions
localparam ST_SAVE_SETTLE  = 6'd55;  // short DDRAM settle after final save write
localparam ST_FREEZE       = 6'd1;
localparam ST_SAVE_HDR     = 6'd2;
localparam ST_SAVE_CPU0    = 6'd3;
localparam ST_SAVE_VDP0    = 6'd7;
localparam ST_SAVE_CRAM0   = 6'd9;
// CRAM is 6 words (SAVE_CRAM0 .. SAVE_CRAM5 via cram_idx counter)
localparam ST_SAVE_PSG     = 6'd15;
localparam ST_SAVE_MAPPER  = 6'd16;
localparam ST_SAVE_VRAM    = 6'd17;
localparam ST_SAVE_WRAM    = 6'd18;
localparam ST_SAVE_DONE    = 6'd19;

localparam ST_LOAD_HDR_RD  = 6'd20;
localparam ST_LOAD_HDR_WT  = 6'd21;
localparam ST_LOAD_CPU0    = 6'd22;
localparam ST_LOAD_VDP0    = 6'd26;
localparam ST_LOAD_CRAM    = 6'd28;  // streams 32 × 12-bit entries via cram_A/D/wr
localparam ST_LOAD_PSG     = 6'd29;
localparam ST_LOAD_MAPPER  = 6'd30;
localparam ST_LOAD_VRAM    = 6'd31;
localparam ST_LOAD_WRAM    = 6'd32;
localparam ST_LOAD_RESTORE = 6'd33;
localparam ST_UNFREEZE     = 6'd34;
localparam ST_SAVE_NVRAM   = 6'd35;
localparam ST_PRE_UNFREEZE = 6'd56;
localparam ST_LOAD_NVRAM   = 6'd36;
localparam ST_WAIT_RESTORE_BOUNDARY = 6'd39;  // one-cycle mapper-settle phase before core restore
localparam ST_ERROR        = 6'd40;  // error state - unfreeze and return to idle
// System E extra states
localparam ST_SAVE_VDP2REG = 6'd42;  // save VDP2 registers
localparam ST_SAVE_CRAM2   = 6'd43;  // save VDP2 CRAM
localparam ST_SAVE_PSG2    = 6'd44;  // save PSG2
localparam ST_SAVE_VRAM2   = 6'd45;  // save VRAM2 DMA
localparam ST_LOAD_VDP2REG = 6'd46;  // load VDP2 registers
localparam ST_LOAD_CRAM2   = 6'd47;  // load VDP2 CRAM
localparam ST_LOAD_PSG2    = 6'd48;  // load PSG2
localparam ST_LOAD_VRAM2   = 6'd49;  // load VRAM2 DMA
localparam ST_LOAD_VRAM1_PASSIVE = 6'd50; // load/zero-fill VDP1 passive bank (System E)
localparam ST_LOAD_VRAM2_PASSIVE = 6'd51; // load/zero-fill VDP2 passive bank (System E)
localparam ST_SAVE_VRAM1_PASSIVE = 6'd52; // save VDP1 passive bank to DDRAM (System E)
localparam ST_SAVE_VRAM2_PASSIVE = 6'd53; // save VDP2 passive bank to DDRAM (System E)
localparam ST_SAVE_EEPROM        = 7'd64; // save 64-bit EEPROM state to DDRAM
localparam ST_LOAD_EEPROM        = 7'd65; // load 64-bit EEPROM state from DDRAM
localparam ST_SAVE_IO            = 6'd57;
localparam ST_LOAD_IO            = 6'd58;
localparam ST_FLUSH_PIPELINE     = 6'd59;
localparam ST_SAVE_VIDEO         = 6'd60;
localparam ST_LOAD_VIDEO         = 6'd61;
localparam ST_LOAD_HDR_WT2       = 6'd62;
localparam ST_UNFREEZE_SETTLE = 6'd63;
localparam ST_SAVE_GG = 7'd73, ST_LOAD_GG = 7'd74;
localparam [127:0] GG_RESET = 128'h00001fe00003f8000000ffa07fff00ff;
reg [127:0] gg_snap;
reg gg_word;
localparam ST_SAVE_MD = 7'd75, ST_LOAD_MD = 7'd76;
localparam [23:0] MD_EXT_MAGIC = 24'h484303;
reg [45:0] md_snap;
reg has_md_ext;
localparam [23:0] EEPROM_EXT_MAGIC = 24'h484304;
localparam [63:0] EEPROM_DESC = {15'd0,5'd16,3'd2,1'b1,8'd1,32'h45455058};
localparam [63:0] EEPROM_ABSENT = {24'd0,8'd1,32'h45455058};
localparam ST_SAVE_EE_DESC=7'd77, ST_SAVE_EE_EXT=7'd78,
           ST_LOAD_EE_DESC=7'd79, ST_LOAD_EE_EXT=7'd80;
reg [127:0] eeprom_ext_snap;
reg eeprom_exists_snap, has_eeprom_tag, eeprom_ext_word;
localparam [23:0] SC_EXT_MAGIC = 24'h484305;
localparam ST_SAVE_SC_DESC=7'd81, ST_LOAD_SC_DESC=7'd82;
reg [1:0] sc_size_snap;
reg has_sc_tag, sc_ram_full;
wire [63:0] sc_descriptor = {30'd0,sc_size_snap,32'h53435235}; // SCR5
localparam [23:0] TAP_EXT_MAGIC = 24'h484306;
localparam ST_SAVE_TAP=7'd83, ST_LOAD_TAP=7'd84;
reg [18:0] tap_snap;
reg has_tap_tag;
// v7 adds only word 0x027: local paddle state [63:32], "PAD7" [31:0].
localparam [23:0] PADDLE_EXT_MAGIC = 24'h484307;
localparam ST_SAVE_PADDLE=7'd85, ST_LOAD_PADDLE=7'd86;
reg [31:0] paddle_snap;
reg has_paddle_tag;
localparam [23:0] GUN_EXT_MAGIC = 24'h484308;
localparam ST_SAVE_GUN0=7'd87, ST_SAVE_GUN1=7'd88, ST_LOAD_GUN0=7'd89, ST_LOAD_GUN1=7'd90;
reg [45:0] gun_snap;
reg has_gun_tag;
localparam [63:0] GUN_DESC = 64'h0000002e4c475538;
// v9: 02a payload [17] Sega evidence, [16] bank evidence, [15:0] timer.
// Padding [63:18] must be zero; 02b is the exact width18/MDH9 descriptor.
localparam [23:0] MAPPER_HISTORY_MAGIC = 24'h484309;
localparam [63:0] MAPPER_HISTORY_DESC = 64'h000000124d444839;
localparam [17:0] MAPPER_HISTORY_LEGACY = 18'h0ffff;
localparam ST_SAVE_HISTORY0=7'd91, ST_SAVE_HISTORY1=7'd92,
           ST_LOAD_HISTORY0=7'd93, ST_LOAD_HISTORY1=7'd94;
reg [17:0] mapper_history_snap;
reg has_mapper_history;
// v11: 02c keeps F14 selector/history [56:0], adds armed/read/menu [59:57],
// and validates zero padding [63:60]. 02d validates width60 and owner "EV11".
// Evolution v10 and earlier lack protocol phase and are rejected before any
// restore writes; other mappers retain their v1-v10 compatibility paths.
localparam [23:0] EVOLUTION_HISTORY_MAGIC = 24'h48430a;
localparam [23:0] EVOLUTION_PENDING_MAGIC = 24'h48430b;
localparam [63:0] EVOLUTION_HISTORY_DESC = 64'h0000003c45563131;
localparam ST_SAVE_EVOLUTION0=7'd95, ST_SAVE_EVOLUTION1=7'd96,
           ST_LOAD_EVOLUTION0=7'd97, ST_LOAD_EVOLUTION1=7'd98;
reg has_evolution_history, evolution_history_valid;
wire live_evolution = evolution_out[31:16] == 16'hE132;
reg do_save;
wire transfer_sc = do_save ? sc_size_snap != 0 : sc_ram_full;
wire transfer_eeprom = do_save ? eeprom_exists_snap : eeprom_full;
wire [28:0] nvram_ddr_base = transfer_eeprom ? 29'h040 : 29'h0D01;

// Post-op guard time to avoid pathological immediate re-entry (rapid hammering).
localparam [27:0] OP_COOLDOWN_MAX = 28'd26846500; // ~500ms @ 53.7MHz
localparam [19:0] FLUSH_MAX       = 20'd900000;    // ≈16.8ms @ 53.7MHz

// PSG extension v1: 020 descriptor, 021/022 PSG1, 023/024 PSG2.
// Descriptor: [31:0] "PSGX", [39:32] version, [40] PSG2,
// [44:41] divider, [45] AudioMix phase, [48:46] payload words,
// [63:49] reserved zero. Payload high words have [63:32] zero.
localparam [31:0] AUDIO_MAGIC = 32'h50534758;
localparam ST_SAVE_AUDIO_INVALID = 7'd66, ST_SAVE_AUDIO_PAYLOAD = 7'd67,
           ST_SAVE_AUDIO_DESC = 7'd68, ST_SAVE_AUDIO_COMMIT = 7'd69,
           ST_LOAD_AUDIO_DESC = 7'd70, ST_LOAD_AUDIO_PAYLOAD = 7'd71,
           ST_SAVE_AUDIO_DRAIN = 7'd72;
reg [95:0] psg_ext_snap, psg2_ext_snap;
reg [3:0] audio_div_snap;
reg [10:0] audio_control_snap;
reg audio_phase_snap, has_audio_ext;
reg [2:0] audio_word;
wire [2:0] audio_words = systeme ? 3'd4 : 3'd2;
wire [63:0] audio_descriptor = {15'd0, audio_words, audio_phase_snap,
                               audio_div_snap, systeme, 8'd1, AUDIO_MAGIC};


// NVRAM size calculation helpers
wire evolution_state = evolution_snap[31:16] == 16'hE132;
wire has_nvram_8k  = !evolution_state && (mapper_snap[48] | mapper_snap[53]); // Dahjee A / Codemasters CME
wire has_nvram_16k = !evolution_state && mapper_snap[50];                    // Sega mapper nvram_e
wire has_nvram_32k = !evolution_state && (mapper_snap[51] | mapper_snap[52] | mapper_snap[61]); // nvram_ex / nvram_p / The Castle
wire has_nvram     = has_nvram_8k | has_nvram_16k | has_nvram_32k;

// SC configuration selects its own backing independently of Sega flags.
wire transfer_ram = transfer_sc || (sc_size_snap == 0 && has_nvram);
wire [14:0] nvram_size_minus_1 = transfer_eeprom ? 15'd127 :
                                 transfer_sc ? (sc_size_snap == 1 ? 15'd2047 : sc_size_snap == 2 ? 15'd16383 : 15'd32767) :
                                 has_nvram_32k ? 15'd32767 :
                                 has_nvram_16k ? 15'd16383 :
                                                 15'd8191;

// v14: 02e descriptor, 02f phase/owner, 2901..2996 two sprite records.
localparam [23:0] RESTART_MAGIC = 24'h48430e;
localparam [23:0] BACKGROUND_MAGIC = 24'h48430f;
localparam [63:0] BACKGROUND_DESC = {16'd139,8'd15,8'd0,32'h47354231};
localparam ST_SAVE_BG_DESC=7'd107, ST_SAVE_BG=7'd108,
           ST_LOAD_BG_DESC=7'd109, ST_LOAD_BG=7'd110;
reg [138:0] bg_snap,bg2_snap;
reg [1:0] bg_word;
reg bg_second,has_background;
assign bg_in=bg_snap;
assign bg2_in=bg2_snap;
assign bg_valid=has_background;
wire [28:0] bg_address=29'h033+(bg_second?29'd3:29'd0)+{27'd0,bg_word};
// Three sequential transfers over139 useful bits: rotate64/64/11 on SAVE,
// shift64/64/11 on LOAD. No padded register bank or indexed wide crossbar.
wire [63:0] bg_write_word=bg_second ?
    (bg_word==2?{53'd0,bg2_snap[10:0]}:bg2_snap[63:0]) :
    (bg_word==2?{53'd0,bg_snap[10:0]}:bg_snap[63:0]);

localparam [63:0] SPRITE_DESC = {16'd4778,8'd14,8'd0,32'h47365231};
localparam ST_SAVE_SPRITE_DESC=7'd99, ST_SAVE_PHASE=7'd100, ST_SAVE_SPRITE=7'd101,
           ST_LOAD_SPRITE_DESC=7'd102, ST_LOAD_PHASE=7'd103, ST_LOAD_SPRITE=7'd104,
           ST_CPU_PREPARE=7'd105, ST_PHASE_COMMIT=7'd106;
reg [4799:0] sprite_snap, sprite2_snap;
reg [6:0] sprite_word;
reg sprite_second, has_restart;
reg [1:0] phase_snap;
reg capture_tick_snap;
assign sprite_in=sprite_snap[4777:0];
assign sprite2_in=sprite2_snap[4777:0];
assign sprite_valid=has_restart;
assign clock_phase_in=phase_snap;
assign z80_replay_t2=has_restart?capture_tick_snap:1'b1;
wire [28:0] sprite_address=29'h2901+(sprite_second?29'd75:29'd0)+{22'd0,sprite_word};
// A 75-word ring avoids a wide indexed read/write crossbar. SAVE rotates
// back to the original record; LOAD shifts each incoming word into place.
wire [63:0] sprite_write_word=sprite_second?sprite2_snap[63:0]:sprite_snap[63:0];
reg [6:0]  state;
assign ss_busy = state != ST_IDLE;
// A System E UI pause may hold the CPU outside an opcode-fetch boundary.
// Permit only the progress needed to reach that boundary in a capture window.
// Drop the override as soon as the bus qualifies, before accepted capture;
// an already qualifying paused bus needs no extra CPU or PSG execution.
assign ss_capture_progress = systeme && state == ST_WAIT_BOUNDARY &&
                             !storage_busy && vblank && x < 9'd256 &&
                             (z80_m1_n || z80_mreq_n || z80_iset != 2'b00);
// do_save is declared with EEPROM transfer selection above.
reg [1:0]  cur_slot;
reg [28:0] base_addr;
reg [31:0] ss_change_det; // MiSTer framework change detector (increment to trigger save-to-disk)
reg [31:0] cur_magic;
reg [31:0] cur_game_id;
reg        cur_bios_mode;

// counters
reg [11:0] word_cnt;    // general DMA word counter (expanded to 12 bits for 32KB NVRAM)
reg  [2:0] cram_idx;    // 0..5 for CRAM 64-bit words
reg  [4:0] cram_entry;  // 0..31 for entry-by-entry restore
reg  [2:0] cpu_idx;     // 0..3 for CPU words
reg  [2:0] vdp_idx;     // 0..1 for VDP reg words
reg  [19:0] flush_cnt;  // expanded to 20 bits for 900000 cycles
reg  [7:0] unfreeze_cnt; // expanded to 8 bits for 255 cycles
// Latching buffers for multi-word state
reg [229:0] z80_snap;
reg [2:0] nmi_snap;
reg [2:0] restart_snap;
reg has_restart_context, restart_padding_ok;
localparam [23:0] CPU_RESTART_MAGIC = 24'h48430d;
assign z80_restart_dir = restart_snap;
assign z80_restart_valid = has_restart_context;
reg has_nmi_history, nmi_padding_ok;
localparam [23:0] NMI_HISTORY_MAGIC = 24'h48430c;
assign z80_nmi_dir = nmi_snap;
assign z80_nmi_valid = has_nmi_history;
reg [135:0] vdp_snap;
reg [383:0] cram_snap;
reg  [55:0] psg_snap;
reg  [63:0] mapper_snap;
reg [159:0] evolution_snap;
// System E latching buffers
reg [135:0] vdp2_snap;
// Video word extension v1: previously-written zero padding is never latch data
// unless the full tag and reserved bits match. Legacy snapshots restore zero.
localparam [23:0] HCOUNTER_MAGIC = 24'h484301; // "HC", version 1
// Version 2 preserves the HCounter layout and adds two local GG words (01c/01d).
// Bits 39:38 now give the GG payload length, exactly two 64-bit words.
localparam [23:0] IO_EXT_MAGIC = 24'h484302;
reg [383:0] cram2_snap;
reg  [55:0] psg2_snap;
reg  [31:0] io_snap;
reg  [21:0] video_snap;
reg  [63:0] eeprom_snap;
// Version 3 retains v1/v2 fields and adds word 01e after the two GG words.
// Version 4 retains that base payload and describes EEPROM at 01f/030/040.
// Version 5 retains all fields and adds validated SC size at 025 (SCR5).
// Version 6 adds MTAP at 026: [50] TH history, [49:48] player, [47:32] timer,
// [31:0] magic; [63:51] zero. Older versions normalize the accessory.
// SC payload shares 0d01..1d00, never the System E or EEPROM regions.
// 01e: [22:0] P1, [45:23] P2, [63:46] zero. Per port:
// [16:0] timer, [19:17] rises, [20] TH history, [22:21] type history.
wire [63:0] video_word = {BACKGROUND_MAGIC, 2'd3,
                         systeme ? vdp2_snap[135:128] : 8'd0,
                         vdp_snap[135:128], video_snap};

// VRAM DMA pipelining: address issued, wait 2 clocks for data
reg  [2:0]  vram_pipe;
reg [14:0]  vram_save_addr;  // current byte address being saved
reg [14:0]  vram_load_addr;  // current byte address being loaded
reg  [2:0]  vram_byte_cnt;   // 0..7 bytes within 64-bit DDRAM word
reg [63:0]  vram_word_buf;   // accumulate 8 bytes → 1 DDRAM write
reg         vram_load_active; // 1 while writing 8 bytes from dout_latch
// Byte-7 latch: when DDRAM_BUSY stalls a word write, the SPRAM/DPRAM pipeline
// still advances on the next cycle so vram_D would have wrong data on retry.
// We latch the correct byte-7 value on the first stall cycle and use it on retry.
reg  [7:0]  vram_d_latch;
reg         vram_d_latched;  // 1 = latch holds a valid stalled byte-7 value

// WRAM DMA similar
reg [13:0]  wram_save_addr;
reg [13:0]  wram_load_addr;
reg  [2:0]  wram_byte_cnt;
reg [63:0]  wram_word_buf;
reg  [1:0]  wram_pipe;
reg         wram_load_active; // 1 while writing 8 bytes from dout_latch
reg  [7:0]  wram_d_latch;
reg         wram_d_latched;

// NVRAM DMA (SRAM / NVRAM, up to 32KB)
reg [14:0]  nvram_save_addr;
reg [14:0]  nvram_load_addr;
reg  [2:0]  nvram_byte_cnt;
reg [63:0]  nvram_word_buf;
reg  [1:0]  nvram_pipe;
reg         nvram_load_active;
reg  [7:0]  nvram_d_latch;
reg         nvram_d_latched;

// Shared latch for DDRAM read data (LOAD path)
reg [63:0]  dout_latch;
wire bg_word_invalid=(bg_word==2 && dout_latch[63:11]!=0) ||
    (bg_word==0 && dout_latch[22:15]>=8'd240) ||
    (bg_second && !systeme && dout_latch!=0);
// v13 inherits v12 NMI and every v11 extension location and meaning.
wire modern_restart_tag = dout_latch[63:40] == CPU_RESTART_MAGIC || dout_latch[63:40] == RESTART_MAGIC || dout_latch[63:40] == BACKGROUND_MAGIC;
wire modern_nmi_tag = dout_latch[63:40] == NMI_HISTORY_MAGIC || modern_restart_tag;
wire [23:0] load_ext_magic = modern_nmi_tag ? EVOLUTION_PENDING_MAGIC : dout_latch[63:40];
wire invalid_nmi_header = modern_nmi_tag &&
                          (dout_latch[39:38] != 2'd3 ||
                           (modern_restart_tag ? !restart_padding_ok : !nmi_padding_ok));

// Guard flag: set when a ddram_read is issued, cleared when DOUT_READY is consumed.
// Prevents stale DOUT_READY pulses (from pre-freeze scaler reads) from
// being misinterpreted as responses to our own load-path read requests.
reg         dout_expected;

// Watchdog: if a DDRAM read is outstanding for > ~640ms (25-bit @ ~53MHz)
// we abort to ST_ERROR so the FSM never hangs forever.
// ~2^25 / 53e6 ≈ 630 ms -- far longer than any real DDRAM latency.
reg [24:0]  ddram_watchdog;
localparam  DDRAM_WATCHDOG_MAX = 25'h1FFFFFF;

// Drain window after taking DDRAM ownership from scaler/video path.
reg [5:0]   freeze_drain_cnt;

reg [27:0]  op_cooldown;
reg         is_old_format;

// VRAM transfer routing: state-derived only; no additional registered state.
wire vram_second_port = state == ST_SAVE_VRAM2 || state == ST_SAVE_VRAM2_PASSIVE ||
                        state == ST_LOAD_VRAM2 || state == ST_LOAD_VRAM2_PASSIVE;
wire [28:0] vram_ddr_offset = (state == ST_SAVE_VRAM1_PASSIVE || state == ST_LOAD_VRAM1_PASSIVE) ? 29'h1901 :
                              (state == ST_SAVE_VRAM2 || state == ST_LOAD_VRAM2) ? 29'h1101 :
                              (state == ST_SAVE_VRAM2_PASSIVE || state == ST_LOAD_VRAM2_PASSIVE) ? 29'h2101 : 29'h101;
wire [7:0] vram_save_data = vram_second_port ? vram2_D : vram_D;

// Update only the selected port; the other port retains its registered values.
task vram_restore_byte;
    input [7:0] data;
    begin
        if (vram_second_port) begin
            vram2_WE <= 1;
            vram2_WA <= vram_load_addr;
            vram2_WD <= data;
        end else begin
            vram_WE <= 1;
            vram_WA <= vram_load_addr;
            vram_WD <= data;
        end
    end
endtask
// End VRAM transfer routing.

// One registered DDRAM transaction; FSM advances only on receiving-edge acceptance.
wire ddram_pending = DDRAM_RD || DDRAM_WE;
wire ddram_accepted = ddram_pending && !DDRAM_BUSY;
reg ddram_cmd_rd, ddram_cmd_we;
reg [28:0] ddram_cmd_addr;
reg [63:0] ddram_cmd_data;
reg [7:0] ddram_cmd_be;
wire ddram_step = ddram_accepted || (!ddram_pending && !ddram_cmd_rd && !ddram_cmd_we);

// Request preview mirrors only the existing FSM request routes. No state is changed.
task ddram_cmd_write;
    input [28:0] addr;
    input [63:0] data;
    input [7:0] be;
    begin
        ddram_cmd_we = 1; ddram_cmd_rd = 0;
        ddram_cmd_addr = addr; ddram_cmd_data = data; ddram_cmd_be = be;
    end
endtask
task ddram_cmd_read;
    input [28:0] addr;
    begin
        ddram_cmd_rd = 1; ddram_cmd_we = 0;
        ddram_cmd_addr = addr; ddram_cmd_data = 0; ddram_cmd_be = 8'hFF;
    end
endtask
always @(*) begin
    ddram_cmd_rd = 0; ddram_cmd_we = 0;
    ddram_cmd_addr = 0; ddram_cmd_data = 0; ddram_cmd_be = 0;
    case (state)
        ST_WAIT_RESTORE_BOUNDARY: if (! DDRAM_BUSY) if (is_old_format ? (sc_size_snap == 0 && mapper_snap [ 48 ]) : (transfer_ram || transfer_eeprom)) ddram_cmd_read ( base_addr + nvram_ddr_base ) ;
        ST_SAVE_HDR: if (! DDRAM_BUSY) ddram_cmd_write ( base_addr + 29'd1 , { cur_game_id , cur_magic } , 8'hFF ) ;
        ST_SAVE_CPU0: begin
            if (! DDRAM_BUSY) begin
                case (cpu_idx)
                    3'd0: ddram_cmd_write ( base_addr + 29'd2 , z80_snap [ 63 : 0 ] , 8'hFF ) ;
                    3'd1: ddram_cmd_write ( base_addr + 29'd3 , z80_snap [ 127 : 64 ] , 8'hFF ) ;
                    3'd2: ddram_cmd_write ( base_addr + 29'd4 , z80_snap [ 191 : 128 ] , 8'hFF ) ;
                    3'd3: ddram_cmd_write ( base_addr + 29'd5 , {20'd0, restart_snap, nmi_snap, z80_snap[229:192]} , 8'hFF ) ;
                    default: begin end
                endcase
            end
        end
        ST_SAVE_VDP0: begin
            if (! DDRAM_BUSY) begin
                case (vdp_idx [ 0 ])
                    1'b0: ddram_cmd_write ( base_addr + 29'd6 , vdp_snap [ 63 : 0 ] , 8'hFF ) ;
                    1'b1: ddram_cmd_write ( base_addr + 29'd7 , vdp_snap [ 127 : 64 ] , 8'hFF ) ;
                endcase
            end
        end
        ST_SAVE_CRAM0: begin
            if (! DDRAM_BUSY) begin
                case (cram_idx)
                    3'd0: ddram_cmd_write ( base_addr + 29'd8 , cram_snap [ 63 : 0 ] , 8'hFF ) ;
                    3'd1: ddram_cmd_write ( base_addr + 29'd9 , cram_snap [ 127 : 64 ] , 8'hFF ) ;
                    3'd2: ddram_cmd_write ( base_addr + 29'd10 , cram_snap [ 191 : 128 ] , 8'hFF ) ;
                    3'd3: ddram_cmd_write ( base_addr + 29'd11 , cram_snap [ 255 : 192 ] , 8'hFF ) ;
                    3'd4: ddram_cmd_write ( base_addr + 29'd12 , cram_snap [ 319 : 256 ] , 8'hFF ) ;
                    3'd5: ddram_cmd_write ( base_addr + 29'd13 , cram_snap [ 383 : 320 ] , 8'hFF ) ;
                    default: begin end
                endcase
            end
        end
        ST_SAVE_PSG: if (! DDRAM_BUSY) ddram_cmd_write ( base_addr + 29'd14 , { 8'd0 , psg_snap } , 8'hFF ) ;
        ST_SAVE_MAPPER: if (! DDRAM_BUSY) ddram_cmd_write ( base_addr + 29'd15 , mapper_snap , 8'hFF ) ;
        ST_SAVE_IO: if (! DDRAM_BUSY) ddram_cmd_write ( base_addr + 29'h019 , { evolution_snap [ 31 : 0 ] , io_snap } , 8'hFF ) ;
        ST_SAVE_VIDEO: if (! DDRAM_BUSY) ddram_cmd_write ( base_addr + 29'h01a , video_word , 8'hFF ) ;
        ST_SAVE_GG: if (!DDRAM_BUSY) ddram_cmd_write(base_addr + 29'h01c + {28'd0,gg_word}, gg_word ? gg_snap[127:64] : gg_snap[63:0], 8'hFF);
        ST_SAVE_EE_DESC: if (!DDRAM_BUSY) ddram_cmd_write(base_addr + 29'h01f, eeprom_exists_snap ? EEPROM_DESC : EEPROM_ABSENT, 8'hFF);
        ST_SAVE_EE_EXT: if (!DDRAM_BUSY) ddram_cmd_write(base_addr + 29'h030 + {28'd0,eeprom_ext_word}, eeprom_ext_word ? eeprom_ext_snap[127:64] : eeprom_ext_snap[63:0], 8'hFF);
        ST_LOAD_EE_DESC: if (!(DDRAM_DOUT_READY && dout_expected) && !dout_expected && !DDRAM_BUSY) begin
            if (eeprom_present && dout_latch == EEPROM_DESC) ddram_cmd_read(base_addr + 29'h030);
            else ddram_cmd_read(base_addr + 29'h01b);
        end
        ST_LOAD_EE_EXT: if (!(DDRAM_DOUT_READY && dout_expected) && !dout_expected && !DDRAM_BUSY) begin
            if (!eeprom_ext_word) ddram_cmd_read(base_addr + 29'h031);
            else ddram_cmd_read(base_addr + 29'h01b);
        end
        ST_SAVE_SC_DESC: if (!DDRAM_BUSY) ddram_cmd_write(base_addr + 29'h025, sc_descriptor, 8'hFF);
        ST_LOAD_SC_DESC: if (!(DDRAM_DOUT_READY && dout_expected) && !dout_expected && !DDRAM_BUSY) ddram_cmd_read(base_addr + (has_tap_tag ? 29'h026 : 29'h01f));
        ST_SAVE_TAP: if (!DDRAM_BUSY) ddram_cmd_write(base_addr + 29'h026, {13'd0,tap_snap,32'h4d544150}, 8'hFF);
        ST_LOAD_TAP: if (!(DDRAM_DOUT_READY && dout_expected) && !dout_expected && !DDRAM_BUSY) ddram_cmd_read(base_addr + (has_paddle_tag ? 29'h027 : 29'h01f));
        ST_SAVE_PADDLE: if (!DDRAM_BUSY) ddram_cmd_write(base_addr + 29'h027, {paddle_snap,32'h50414437}, 8'hFF);
        ST_LOAD_PADDLE: if (!(DDRAM_DOUT_READY && dout_expected) && !dout_expected && !DDRAM_BUSY) ddram_cmd_read(base_addr + (has_gun_tag ? 29'h028 : 29'h01f));
        ST_SAVE_HISTORY0: if (!DDRAM_BUSY) ddram_cmd_write(base_addr + 29'h02a, {46'd0,mapper_history_snap}, 8'hFF);
        ST_SAVE_HISTORY1: if (!DDRAM_BUSY) ddram_cmd_write(base_addr + 29'h02b, MAPPER_HISTORY_DESC, 8'hFF);
        ST_LOAD_HISTORY0: if (!(DDRAM_DOUT_READY && dout_expected) && !dout_expected && !DDRAM_BUSY) ddram_cmd_read(base_addr + 29'h02b);
        ST_LOAD_HISTORY1: if (!(DDRAM_DOUT_READY && dout_expected) && !dout_expected && !DDRAM_BUSY) ddram_cmd_read(base_addr + (has_evolution_history ? 29'h02c : 29'h01f));
        ST_SAVE_EVOLUTION0: if (!DDRAM_BUSY) ddram_cmd_write(base_addr + 29'h02c, {4'd0,evolution_snap[155:96]}, 8'hFF);

        ST_SAVE_SPRITE_DESC: if (!DDRAM_BUSY) ddram_cmd_write(base_addr+29'h02e,SPRITE_DESC,8'hff);
        ST_SAVE_PHASE: if (!DDRAM_BUSY) ddram_cmd_write(base_addr+29'h02f,{60'd0,capture_tick_snap,systeme,phase_snap},8'hff);
        ST_SAVE_SPRITE: if (!DDRAM_BUSY) ddram_cmd_write(base_addr+sprite_address,sprite_write_word,8'hff);
        ST_LOAD_SPRITE_DESC: if (!dout_expected && !DDRAM_BUSY && dout_latch==SPRITE_DESC) ddram_cmd_read(base_addr+29'h02f);
        ST_LOAD_PHASE: if (!dout_expected && !DDRAM_BUSY && dout_latch[63:4]==0 && dout_latch[2]==systeme) ddram_cmd_read(base_addr+29'h2901);
        ST_LOAD_SPRITE: if (!dout_expected && !DDRAM_BUSY &&
            !(sprite_word==74 && dout_latch[63:42]!=0) && !(sprite_second && !systeme && dout_latch!=0))
            ddram_cmd_read(base_addr+((sprite_second && sprite_word==74)?(has_background?29'h032:29'h01f):sprite_address+29'd1));
        ST_SAVE_BG_DESC: if (!DDRAM_BUSY) ddram_cmd_write(base_addr+29'h032,BACKGROUND_DESC,8'hff);
        ST_SAVE_BG: if (!DDRAM_BUSY) ddram_cmd_write(base_addr+bg_address,bg_write_word,8'hff);
        ST_LOAD_BG_DESC: if (!dout_expected && !DDRAM_BUSY && dout_latch==BACKGROUND_DESC) ddram_cmd_read(base_addr+29'h033);
        ST_LOAD_BG: if (!dout_expected && !DDRAM_BUSY && !bg_word_invalid)
            ddram_cmd_read(base_addr+((bg_second && bg_word==2)?29'h01f:bg_address+29'd1));
        ST_SAVE_EVOLUTION1: if (!DDRAM_BUSY) ddram_cmd_write(base_addr + 29'h02d, EVOLUTION_HISTORY_DESC, 8'hFF);
        ST_LOAD_EVOLUTION0: if (!(DDRAM_DOUT_READY && dout_expected) && !dout_expected && !DDRAM_BUSY) ddram_cmd_read(base_addr + 29'h02d);
        ST_LOAD_EVOLUTION1: if (!(DDRAM_DOUT_READY && dout_expected) && !dout_expected && !DDRAM_BUSY)
            if (!invalid_nmi_header && !((live_evolution || evolution_state) && (!evolution_state || !evolution_history_valid || dout_latch != EVOLUTION_HISTORY_DESC))) ddram_cmd_read(base_addr + (has_restart ? 29'h02e : 29'h01f));
        ST_SAVE_GUN0: if (!DDRAM_BUSY) ddram_cmd_write(base_addr + 29'h028, {18'd0,gun_snap}, 8'hFF);
        ST_SAVE_GUN1: if (!DDRAM_BUSY) ddram_cmd_write(base_addr + 29'h029, GUN_DESC, 8'hFF);
        ST_LOAD_GUN0: if (!(DDRAM_DOUT_READY && dout_expected) && !dout_expected && !DDRAM_BUSY) ddram_cmd_read(base_addr + 29'h029);
        ST_LOAD_GUN1: if (!(DDRAM_DOUT_READY && dout_expected) && !dout_expected && !DDRAM_BUSY) ddram_cmd_read(base_addr + (has_mapper_history ? 29'h02a : 29'h01f));
        ST_SAVE_MD: if (!DDRAM_BUSY) ddram_cmd_write(base_addr + 29'h01e, {18'd0,md_snap}, 8'hFF);
        ST_LOAD_MD: if (!(DDRAM_DOUT_READY && dout_expected) && !dout_expected && !DDRAM_BUSY) begin
            if (has_sc_tag) ddram_cmd_read(base_addr + 29'h025);
            else if (has_eeprom_tag) ddram_cmd_read(base_addr + 29'h01f);
            else ddram_cmd_read(base_addr + 29'h01b);
        end
        ST_LOAD_GG: if (!(DDRAM_DOUT_READY && dout_expected) && !dout_expected && !DDRAM_BUSY) begin
            if (!gg_word) ddram_cmd_read(base_addr + 29'h01d);
            else if (has_md_ext) ddram_cmd_read(base_addr + 29'h01e);
            else ddram_cmd_read(base_addr + 29'h01b);
        end
        ST_SAVE_EEPROM: if (! DDRAM_BUSY) ddram_cmd_write ( base_addr + 29'h01b , evolution_snap [ 31 : 16 ] == 16'hE132 ? evolution_snap [ 95 : 32 ] : eeprom_snap , 8'hFF ) ;
        ST_SAVE_VDP2REG: begin
            if (! DDRAM_BUSY) begin
                case (vdp_idx [ 0 ])
                    1'b0: ddram_cmd_write ( base_addr + 29'h10 , vdp2_snap [ 63 : 0 ] , 8'hFF ) ;
                    1'b1: ddram_cmd_write ( base_addr + 29'h11 , vdp2_snap [ 127 : 64 ] , 8'hFF ) ;
                endcase
            end
        end
        ST_SAVE_CRAM2: begin
            if (! DDRAM_BUSY) begin
                case (cram_idx)
                    3'd0: ddram_cmd_write ( base_addr + 29'h12 , cram2_snap [ 63 : 0 ] , 8'hFF ) ;
                    3'd1: ddram_cmd_write ( base_addr + 29'h13 , cram2_snap [ 127 : 64 ] , 8'hFF ) ;
                    3'd2: ddram_cmd_write ( base_addr + 29'h14 , cram2_snap [ 191 : 128 ] , 8'hFF ) ;
                    3'd3: ddram_cmd_write ( base_addr + 29'h15 , cram2_snap [ 255 : 192 ] , 8'hFF ) ;
                    3'd4: ddram_cmd_write ( base_addr + 29'h16 , cram2_snap [ 319 : 256 ] , 8'hFF ) ;
                    3'd5: ddram_cmd_write ( base_addr + 29'h17 , cram2_snap [ 383 : 320 ] , 8'hFF ) ;
                    default: begin end
                endcase
            end
        end
        ST_SAVE_PSG2: if (! DDRAM_BUSY) ddram_cmd_write ( base_addr + 29'h18 , { 8'h0 , psg2_snap } , 8'h7F ) ;
        ST_SAVE_VRAM , ST_SAVE_VRAM1_PASSIVE , ST_SAVE_VRAM2 , ST_SAVE_VRAM2_PASSIVE: if (!(vram_pipe < 3'd2)) if (vram_byte_cnt < 7 || ! DDRAM_BUSY) if (vram_byte_cnt == 7) ddram_cmd_write ( base_addr + vram_ddr_offset + { 17'd0 , word_cnt } , { vram_d_latched ? vram_d_latch : vram_save_data , vram_word_buf [ 63 : 8 ] } , 8'hFF ) ;
        ST_SAVE_WRAM: if (!(wram_pipe < 2'd2)) if (wram_byte_cnt < 7 || ! DDRAM_BUSY) if (wram_byte_cnt == 7) ddram_cmd_write ( base_addr + 29'h901 + { 17'd0 , word_cnt } , { wram_d_latched ? wram_d_latch : wram_D , wram_word_buf [ 63 : 8 ] } , 8'hFF ) ;
        ST_SAVE_NVRAM: if (!(nvram_pipe < 2'd2)) if (nvram_byte_cnt < 7 || ! DDRAM_BUSY) if (nvram_byte_cnt == 7) ddram_cmd_write ( base_addr + nvram_ddr_base + { 17'd0 , word_cnt } , { nvram_d_latched ? nvram_d_latch : nvram_D , nvram_word_buf [ 63 : 8 ] } , 8'hFF ) ;
        ST_SAVE_AUDIO_INVALID: if (! DDRAM_BUSY) ddram_cmd_write ( base_addr + 29'h00e , { 12'd0 , psg_snap [ 51 : 0 ] } , 8'hFF ) ;
        ST_SAVE_AUDIO_PAYLOAD: begin
            if (! DDRAM_BUSY) begin
                case (audio_word)
                    0: ddram_cmd_write ( base_addr + 29'h021 , psg_ext_snap [ 63 : 0 ] , 8'hFF ) ;
                    1: ddram_cmd_write ( base_addr + 29'h022 , { 32'd0 , psg_ext_snap [ 95 : 64 ] } , 8'hFF ) ;
                    2: ddram_cmd_write ( base_addr + 29'h023 , psg2_ext_snap [ 63 : 0 ] , 8'hFF ) ;
                    3: ddram_cmd_write ( base_addr + 29'h024 , { 32'd0 , psg2_ext_snap [ 95 : 64 ] } , 8'hFF ) ;
                    default: begin end
                endcase
            end
        end
        ST_SAVE_AUDIO_DESC: if (! DDRAM_BUSY) ddram_cmd_write ( base_addr + 29'h020 , audio_descriptor , 8'hFF ) ;
        ST_SAVE_AUDIO_COMMIT: if (! DDRAM_BUSY) ddram_cmd_write ( base_addr + 29'h00e , { 1'b1 , audio_control_snap , psg_snap [ 51 : 0 ] } , 8'hFF ) ;
        ST_SAVE_DONE: begin
            if (cur_bios_mode) begin
                if (! DDRAM_BUSY) ddram_cmd_write ( base_addr , { NEW_SS_WORDS , 32'd0 } , 8'hF0 ) ;
            end else begin
                if (! DDRAM_BUSY) ddram_cmd_write ( base_addr + 29'd0 , { NEW_SS_WORDS , ss_change_det } , 8'hFF ) ;
            end
        end
        ST_LOAD_HDR_RD: if (! DDRAM_BUSY) ddram_cmd_read ( base_addr + 29'd0 ) ;
        ST_LOAD_HDR_WT: if (!(DDRAM_DOUT_READY && dout_expected)) if (! dout_expected && ! DDRAM_BUSY) ddram_cmd_read ( base_addr + 29'd1 ) ;
        ST_LOAD_HDR_WT2: if (!(DDRAM_DOUT_READY && dout_expected)) if (! dout_expected && ! DDRAM_BUSY) if (dout_latch [ 31 : 0 ] == cur_magic && ( is_old_format || dout_latch [ 63 : 32 ] == cur_game_id )) ddram_cmd_read ( base_addr + 29'd2 ) ;
        ST_LOAD_CPU0: begin
            if (!(DDRAM_DOUT_READY && dout_expected)) begin
                if (! dout_expected && ! DDRAM_BUSY) begin
                    case (cpu_idx)
                        3'd0: ddram_cmd_read ( base_addr + 29'd3 ) ;
                        3'd1: ddram_cmd_read ( base_addr + 29'd4 ) ;
                        3'd2: ddram_cmd_read ( base_addr + 29'd5 ) ;
                        3'd3: ddram_cmd_read ( base_addr + 29'd6 ) ;
                        default: begin end
                    endcase
                end
            end
        end
        ST_LOAD_VDP0: begin
            if (!(DDRAM_DOUT_READY && dout_expected)) begin
                if (! dout_expected && ! DDRAM_BUSY) begin
                    case (vdp_idx [ 0 ])
                        1'b0: ddram_cmd_read ( base_addr + 29'd7 ) ;
                        1'b1: ddram_cmd_read ( base_addr + 29'd8 ) ;
                    endcase
                end
            end
        end
        ST_LOAD_CRAM: begin
            if (!(DDRAM_DOUT_READY && dout_expected)) begin
                if (! dout_expected && ! DDRAM_BUSY) begin
                    case (cram_idx)
                        3'd0: ddram_cmd_read ( base_addr + 29'd9 ) ;
                        3'd1: ddram_cmd_read ( base_addr + 29'd10 ) ;
                        3'd2: ddram_cmd_read ( base_addr + 29'd11 ) ;
                        3'd3: ddram_cmd_read ( base_addr + 29'd12 ) ;
                        3'd4: ddram_cmd_read ( base_addr + 29'd13 ) ;
                        3'd5: ddram_cmd_read ( base_addr + 29'd14 ) ;
                        default: begin end
                    endcase
                end
            end
        end
        ST_LOAD_PSG: begin
            if (!(DDRAM_DOUT_READY && dout_expected)) begin
                if (! dout_expected && ! DDRAM_BUSY) begin
                    if (dout_latch [ 63 ]) begin
                        ddram_cmd_read ( base_addr + 29'h020 ) ;
                    end else begin
                        ddram_cmd_read ( base_addr + 29'd15 ) ;
                    end
                end
            end
        end
        ST_LOAD_AUDIO_DESC: if (!(DDRAM_DOUT_READY && dout_expected)) if (! dout_expected && ! DDRAM_BUSY) if (! is_old_format && dout_latch [ 31 : 0 ] == AUDIO_MAGIC && dout_latch [ 39 : 32 ] == 8'd1 && dout_latch [ 40 ] == systeme && dout_latch [ 48 : 46 ] == audio_words && dout_latch [ 63 : 49 ] == 0) ddram_cmd_read ( base_addr + 29'h021 ) ;
        ST_LOAD_AUDIO_PAYLOAD: begin
            if (!(DDRAM_DOUT_READY && dout_expected)) begin
                if (! dout_expected && ! DDRAM_BUSY) begin
                    if (!(audio_word [ 0 ] && ( dout_latch [ 63 : 32 ] != 0 ))) begin
                        if (audio_word == audio_words - 1) begin
                            ddram_cmd_read ( base_addr + 29'h00f ) ;
                        end else begin
                            ddram_cmd_read ( base_addr + 29'h022 + { 26'd0 , audio_word } ) ;
                        end
                    end
                end
            end
        end
        ST_LOAD_MAPPER: begin
            if (!(DDRAM_DOUT_READY && dout_expected)) begin
                if (! dout_expected && ! DDRAM_BUSY) begin
                    if (is_old_format && !live_evolution) begin
                        ddram_cmd_read ( base_addr + 29'h101 ) ;
                    end else if (!is_old_format) begin
                        ddram_cmd_read ( base_addr + 29'h019 ) ;
                    end
                end
            end
        end
        ST_LOAD_IO: if (!(DDRAM_DOUT_READY && dout_expected)) if (! dout_expected && ! DDRAM_BUSY) ddram_cmd_read ( base_addr + 29'h01a ) ;
        ST_LOAD_VIDEO: if (!(DDRAM_DOUT_READY && dout_expected) && !dout_expected && !DDRAM_BUSY) begin
            if (!invalid_nmi_header && !((live_evolution || evolution_state) && (!evolution_state || load_ext_magic != EVOLUTION_PENDING_MAGIC || dout_latch[39:38] != 2'd3))) begin
            if ((load_ext_magic == IO_EXT_MAGIC && dout_latch[39:38] == 2'd2) ||
                    ((load_ext_magic == MD_EXT_MAGIC || load_ext_magic == EEPROM_EXT_MAGIC || load_ext_magic == SC_EXT_MAGIC || load_ext_magic == TAP_EXT_MAGIC || load_ext_magic == PADDLE_EXT_MAGIC || (load_ext_magic == GUN_EXT_MAGIC || (load_ext_magic == MAPPER_HISTORY_MAGIC || (load_ext_magic == EVOLUTION_HISTORY_MAGIC || load_ext_magic == EVOLUTION_PENDING_MAGIC)))) && dout_latch[39:38] == 2'd3)) ddram_cmd_read(base_addr + 29'h01c);
            else ddram_cmd_read(base_addr + 29'h01b);
            end
        end
        ST_LOAD_EEPROM: begin
            if (!(DDRAM_DOUT_READY && dout_expected)) begin
                if (! dout_expected && ! DDRAM_BUSY) begin
                    if (systeme) begin
                        ddram_cmd_read ( base_addr + 29'h10 ) ;
                    end else begin
                        ddram_cmd_read ( base_addr + 29'h101 ) ;
                    end
                end
            end
        end
        ST_LOAD_VDP2REG: begin
            if (!(DDRAM_DOUT_READY && dout_expected)) begin
                if (! dout_expected && ! DDRAM_BUSY) begin
                    case (cram_idx)
                        3'd0: ddram_cmd_read ( base_addr + 29'h11 ) ;
                        3'd1: ddram_cmd_read ( base_addr + 29'h12 ) ;
                        default: begin end
                    endcase
                end
            end
        end
        ST_LOAD_CRAM2: begin
            if (!(DDRAM_DOUT_READY && dout_expected)) begin
                if (! dout_expected && ! DDRAM_BUSY) begin
                    case (cram_idx)
                        3'd0: ddram_cmd_read ( base_addr + 29'h13 ) ;
                        3'd1: ddram_cmd_read ( base_addr + 29'h14 ) ;
                        3'd2: ddram_cmd_read ( base_addr + 29'h15 ) ;
                        3'd3: ddram_cmd_read ( base_addr + 29'h16 ) ;
                        3'd4: ddram_cmd_read ( base_addr + 29'h17 ) ;
                        3'd5: ddram_cmd_read ( base_addr + 29'h18 ) ;
                        default: begin end
                    endcase
                end
            end
        end
        ST_LOAD_PSG2: if (!(DDRAM_DOUT_READY && dout_expected)) if (! dout_expected && ! DDRAM_BUSY) ddram_cmd_read ( base_addr + 29'h101 ) ;
        ST_LOAD_VRAM , ST_LOAD_VRAM1_PASSIVE , ST_LOAD_VRAM2 , ST_LOAD_VRAM2_PASSIVE: begin
            if (!(! vram_load_active)) begin
                if (!(vram_byte_cnt < 7)) begin
                    if (! DDRAM_BUSY) begin
                        if (word_cnt < 12'd2047) begin
                            ddram_cmd_read ( base_addr + vram_ddr_offset + { 17'd0 , word_cnt + 12'd1 } ) ;
                        end else begin
                            case (state)
                                ST_LOAD_VRAM: begin
                                    if (systeme) begin
                                        ddram_cmd_read ( base_addr + 29'h1901 ) ;
                                    end else begin
                                        ddram_cmd_read ( base_addr + 29'h901 ) ;
                                    end
                                end
                                ST_LOAD_VRAM1_PASSIVE: ddram_cmd_read ( base_addr + 29'h901 ) ;
                                ST_LOAD_VRAM2: ddram_cmd_read ( base_addr + 29'h2101 ) ;
                                default: begin end
                            endcase
                        end
                    end
                end
            end
        end
        ST_LOAD_WRAM: begin
            if (!(! wram_load_active)) begin
                if (!(wram_byte_cnt < 7)) begin
                    if (! DDRAM_BUSY) begin
                        if (word_cnt < ( systeme ? 12'd2047 : 12'd1023 )) begin
                            ddram_cmd_read ( base_addr + 29'h901 + { 17'd0 , word_cnt + 12'd1 } ) ;
                        end else begin
                            if (systeme) ddram_cmd_read ( base_addr + 29'h1101 ) ;
                        end
                    end
                end
            end
        end
        ST_LOAD_NVRAM: if (!(! nvram_load_active)) if (!(nvram_byte_cnt < 7)) if (! DDRAM_BUSY) if (word_cnt < ( nvram_size_minus_1 >> 3 )) ddram_cmd_read ( base_addr + nvram_ddr_base + { 17'd0 , word_cnt + 12'd1 } ) ;
        default: begin end
    endcase
end

// -----------------------------------------------------------------------
// DDRAM helper tasks (inline)
// -----------------------------------------------------------------------
task ddram_write;
    input [28:0] addr;
    input [63:0] din;
    input  [7:0] be;
    begin
        DDRAM_ADDR     <= addr;
        DDRAM_DIN      <= din;
        DDRAM_BE       <= be;
        DDRAM_WE       <= 1;
        DDRAM_RD       <= 0;
        DDRAM_BURSTCNT <= 8'd1;
    end
endtask

task ddram_read;
    input [28:0] addr;
    begin
        DDRAM_ADDR     <= addr;
        DDRAM_BE       <= 8'hFF;
        DDRAM_WE       <= 0;
        DDRAM_RD       <= 1;
        DDRAM_BURSTCNT <= 8'd1;
        dout_expected  <= 1;   // mark that a response is in flight
    end
endtask

task ddram_idle;
    begin
        DDRAM_WE <= 0;
        DDRAM_RD <= 0;
    end
endtask

// -----------------------------------------------------------------------
// Main FSM
// -----------------------------------------------------------------------
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        state           <= ST_IDLE;
        ss_freeze       <= 0;
        capture_tick_snap<=1;
        ss_cpu_prepare <= 0; clock_phase_set <= 0; sprite_word <= 0; sprite_second <= 0;
        z80_nmi_hold <= 0; nmi_snap <= 3'b001; has_nmi_history <= 0; nmi_padding_ok <= 1;
        has_restart_context <= 0; restart_snap <= 0; restart_padding_ok <= 1;
        has_restart <= 0; phase_snap <= 0; sprite_snap <= 0; sprite2_snap <= 0;
        has_background<=0;bg_snap<=0;bg2_snap<=0;bg_word<=0;bg_second<=0;
        ss_change_det   <= 0;
        cur_magic       <= MAGIC;
        cur_game_id     <= 0;
        cur_bios_mode   <= 0;
        z80_set         <= 0;
        vdp_regs_set    <= 0;
        cram_wr         <= 0;
        psg_set         <= 0;
        mapper_set      <= 0;
        evolution_set   <= 0;
        evolution_in    <= 160'd0;
        eeprom_set      <= 0;
        vram_en         <= 0;
        vram_WE         <= 0;
        vram_load_active <= 0;
        wram_WE         <= 0;
        wram_load_active <= 0;
        nvram_WE        <= 0;
        nvram_load_active <= 0;
        vdp2_regs_set   <= 0;
        cram2_wr        <= 0;
        psg2_set        <= 0;
        vram2_en        <= 0;
        vram2_WE        <= 0;
        dout_latch      <= 64'd0;
        io_in           <= 32'd0;
        gg_in <= GG_RESET; gg_snap <= GG_RESET; gg_set <= 0; gg_word <= 0;
        md_in <= 0; md_snap <= 0; md_set <= 0; md_valid <= 0; has_md_ext <= 0;
        eeprom_ext_in <= 0; eeprom_ext_snap <= 0; eeprom_full <= 0;
        eeprom_exists_snap <= 0; has_eeprom_tag <= 0; eeprom_ext_word <= 0; nvram_refill <= 0;
        sc_size_snap <= 0; has_sc_tag <= 0; sc_ram_full <= 0; sc_ram_restored <= 0;
        mapper_history_snap <= MAPPER_HISTORY_LEGACY; mapper_history_in <= MAPPER_HISTORY_LEGACY; has_mapper_history <= 0;
        has_evolution_history <= 0; evolution_history_valid <= 0;
        gun_snap <= 0; gun_in <= 0; gun_set <= 0; gun_valid <= 0; has_gun_tag <= 0;
        paddle_snap <= 0; paddle_in <= 0; paddle_set <= 0; paddle_valid <= 0; has_paddle_tag <= 0;
        tap_snap <= 0; tap_in <= 0; tap_set <= 0; tap_valid <= 0; has_tap_tag <= 0;
        io_set          <= 0;
        io_snap         <= 32'd0;
        video_state_in  <= 22'd0;
        video_state_set <= 0;
        video_snap      <= 22'd0;
        dout_expected   <= 0;
        ddram_watchdog  <= 0;
        freeze_drain_cnt <= 0;
        op_cooldown    <= 0;
        is_old_format   <= 0;
        has_audio_ext <= 0;
        audio_ext_set <= 0;
        audio_phase_set <= 0;
        psg_ext_in <= 0; psg2_ext_in <= 0; psg_div_in <= 0;
        audio_control_in <= 0; audio_phase_in <= 0;
        audio_word <= 0;
        flush_cnt       <= 0;
        unfreeze_cnt    <= 0;
        DDRAM_WE        <= 0;
        DDRAM_RD        <= 0;
        DDRAM_BURSTCNT  <= 8'd1;
    end else begin
        // default: clear one-cycle strobes
        z80_set      <= 0;
        vdp_regs_set <= 0;
        cram_wr      <= 0;
        psg_set      <= 0;
        mapper_set   <= 0;
        evolution_set <= 0;
        eeprom_set   <= 0;
        sc_ram_restored <= 0;
        vram_WE      <= 0;
        wram_WE      <= 0;
        nvram_WE     <= 0;
        vdp2_regs_set <= 0;
        cram2_wr     <= 0;
        psg2_set     <= 0;
        vram2_WE     <= 0;
        io_set       <= 0;
        gg_set <= 0;
        md_set <= 0;
        gun_set <= 0;
        paddle_set <= 0;
        tap_set <= 0;
        video_state_set <= 0;
        audio_ext_set <= 0;
        audio_phase_set <= 0;
        ddram_idle();

        // DDRAM read watchdog: abort if no response after ~640ms
        if (dout_expected) begin
            if (ddram_watchdog == DDRAM_WATCHDOG_MAX) begin
                dout_expected  <= 0;
                ddram_watchdog <= 0;
                state          <= ST_ERROR;
            end else
                ddram_watchdog <= ddram_watchdog + 25'd1;
        end else
            ddram_watchdog <= 0;

        if (ddram_step) begin
        case (state)
        // ---------------------------------------------------------------
        ST_IDLE: begin
            ss_freeze   <= 0;
            is_old_format <= 0;
            has_audio_ext <= 0;
             if (op_cooldown != 0)
                 op_cooldown <= op_cooldown - 28'd1;
            else if (ss_save) begin
                do_save   <= 1;
                cur_slot  <= ss_slot;
                state     <= ST_WAIT_BOUNDARY;
            end else if (ss_load) begin
                do_save   <= 0;
                cur_slot  <= ss_slot;
                state     <= ST_WAIT_BOUNDARY;
            end
        end

        // ---------------------------------------------------------------
        ST_WAIT_BOUNDARY: begin
            // Wait for a clean Z80 instruction boundary during VBlank.
            // This ensures both save and load freeze the system at a clean
            // instruction boundary during the VBlank phase, avoiding mid-frame
            // raster-timing inconsistencies.
            //   - M1_n low  : opcode-fetch machine cycle
            //   - MREQ_n low: normal memory read (not interrupt acknowledge)
            //   - ISet=00   : eligible fetch; previous IR may still carry a pending
            //                  prefix/EI class, captured separately in v13.
            //   - cpu_ce     : only act on an actual CPU tick, not on held bus
            //                  levels between ticks.
            if (!storage_busy && cpu_ce && !z80_m1_n && !z80_mreq_n && z80_iset == 2'b00 && vblank && x < 9'd256) begin
                base_addr <= ss_bios_mode ? bios_slot_base(cur_slot) : slot_base(cur_slot);
                cur_bios_mode <= ss_bios_mode;
                cur_magic <= ss_bios_mode ? MAGIC_BIOS : MAGIC;
                cur_game_id <= ss_game_id;

                // Z80 snapshot MUST be captured in the same cycle the boundary is detected.
                // Capturing one cycle later grabs the post-tick state (where PC is already
                // incremented), creating non-deterministic loads that skip an instruction.
                ss_freeze <= 1; // accepted host T finishes; T+1 is held
                if (do_save) begin phase_snap <= clock_phase;capture_tick_snap<=z80_tick_active;end
                z80_snap    <= z80_reg;
                nmi_snap <= z80_nmi;
                restart_snap <= z80_restart;
                if (!do_save) z80_nmi_hold <= 1;
                state       <= ST_ARM_FREEZE;
            end
        end

        // ---------------------------------------------------------------
        ST_ARM_FREEZE: begin
            nvram_refill <= 0;
            // Guest hold was asserted at accepted T. Collect post-T device
            // state here, before any subsequent guest enable is admitted.
            bg_snap<=bg_out;bg2_snap<=systeme?bg2_out:139'd0;
            has_background<=1;
            sprite_snap <= {22'd0,sprite_out};
            sprite2_snap <= systeme ? {22'd0,sprite2_out} : 4800'd0;
            vdp_snap    <= vdp_regs;
            cram_snap   <= cram_out;
            psg_snap    <= psg_out;
            mapper_snap <= mapper_out;
            sc_size_snap <= sc_ram_size;
            sc_ram_full <= 0; has_sc_tag <= 0;
            evolution_snap <= evolution_out;
            if (systeme) begin
                vdp2_snap   <= vdp2_regs;
                cram2_snap  <= cram2_out;
                psg2_snap   <= psg2_out;
            end
            io_snap          <= io_out;
            gg_snap          <= gg_out;
            video_snap       <= video_state_out;

            
            ss_freeze        <= 1;
            freeze_drain_cnt <= 0;
            state            <= ST_FREEZE_DRAIN;
        end

        // ---------------------------------------------------------------
        ST_FREEZE_DRAIN: begin
            // After switching DDRAM ownership, wait for a clean idle window:
            // no bus busy and no read-data pulses for 32 consecutive clocks.
            // This is more robust than a blind fixed delay under heavy load.
            ss_freeze     <= 1;
            dout_expected <= 0;
            if (DDRAM_BUSY || DDRAM_DOUT_READY)
                freeze_drain_cnt <= 0;
            else if (freeze_drain_cnt == 6'd31)
                state <= ST_FREEZE;
            else
                freeze_drain_cnt <= freeze_drain_cnt + 6'd1;
        end

        // ---------------------------------------------------------------
        ST_FREEZE: begin
            ss_freeze <= 1;
            // synthesis translate_off
            if (do_save && audio_quiescent !== 1'b1)
                $fatal(1,"PSG not quiescent at post-drain capture");
            // synthesis translate_on
            if (!do_save) state <= ST_LOAD_HDR_RD;
            else if (audio_quiescent) begin
                // Capture PSG after the pending tick and write pipeline drain.
                // CPU, VDP, IO and video capture edges above are unchanged.
                // MD pads run every clk_sys: capture after freeze is active.
                // The host-clock detector can increment on the ARM edge and
                // finish its terminal fallback while freeze drains. Sample
                // mapper and history together once that activity has settled.
                mapper_snap <= mapper_out;
                mapper_history_snap <= mapper_history_out;
                md_snap <= md_out;
                gun_snap <= gun_out;
                paddle_snap <= paddle_out;
                tap_snap <= tap_out;
                eeprom_snap <= eeprom_out;
                eeprom_ext_snap <= eeprom_ext_out;
                eeprom_exists_snap <= eeprom_present;
                psg_snap <= psg_out;
                psg2_snap <= psg2_out;
                psg_ext_snap <= psg_ext_out;
                psg2_ext_snap <= psg2_ext_out;
                audio_div_snap <= psg_div_out;
                audio_control_snap <= audio_control_out;
                audio_phase_snap <= audio_phase_out;
                audio_word <= 0;
                state <= ST_SAVE_AUDIO_INVALID;
            end
        end

        // ---------------------------------------------------------------
        ST_WAIT_RESTORE_BOUNDARY: begin
            // Restore mapper/bank state first and give it one full clk_sys cycle
            // to settle before loading CPU/VDP/PSG. This avoids occasional
            // resumes with stale ROM mapping or BIOS/cart decode for the first
            // restored core cycle.
            if (!DDRAM_BUSY) begin
                mapper_in  <= mapper_snap;
                mapper_history_in <= mapper_history_snap;
                mapper_set <= 1;
                evolution_in  <= evolution_snap;
                evolution_set <= 1;

                // Old format only ever wrote NVRAM for Dahjee-A (mapper_snap[48]);
                // reading the broadened has_nvram region for other mappers would
                // DMA an unwritten slot area over live cartridge SRAM.
                if (is_old_format ? (sc_size_snap == 0 && mapper_snap[48]) : (transfer_ram || transfer_eeprom)) begin
                    nvram_load_addr   <= 0;
                    nvram_byte_cnt    <= 0;
                    nvram_load_active <= 0;
                    word_cnt          <= 0;
                    ddram_read(base_addr + nvram_ddr_base);
                    state             <= ST_LOAD_NVRAM;
                end else begin
                    state             <= ST_LOAD_RESTORE;
                    cram_entry        <= 0;
                end
            end
        end

        // ===============================================================
        // SAVE
        // ===============================================================

        ST_SAVE_HDR: begin
            if (!DDRAM_BUSY) begin
                ddram_write(base_addr + 29'd1, {cur_game_id, cur_magic}, 8'hFF);
                state <= ST_SAVE_CPU0;
                cpu_idx <= 0;
            end
        end

        ST_SAVE_CPU0: begin
            // z80_snap[228:0] = 229 bits → 4 × 64-bit words
            if (!DDRAM_BUSY) begin
                case (cpu_idx)
                    3'd0: ddram_write(base_addr + 29'd2, z80_snap[63:0],    8'hFF);
                    3'd1: ddram_write(base_addr + 29'd3, z80_snap[127:64],  8'hFF);
                    3'd2: ddram_write(base_addr + 29'd4, z80_snap[191:128], 8'hFF);
                    3'd3: ddram_write(base_addr + 29'd5, {20'd0, restart_snap, nmi_snap, z80_snap[229:192]}, 8'hFF);
                endcase
                if (cpu_idx == 3) begin
                    state   <= ST_SAVE_VDP0;
                    vdp_idx <= 0;
                end else
                    cpu_idx <= cpu_idx + 3'd1;
            end
        end

        ST_SAVE_VDP0: begin
            if (!DDRAM_BUSY) begin
                case (vdp_idx[0])
                    1'b0: ddram_write(base_addr + 29'd6, vdp_snap[63:0],   8'hFF);
                    1'b1: ddram_write(base_addr + 29'd7, vdp_snap[127:64], 8'hFF);
                endcase
                if (vdp_idx[0] == 1) begin
                    state    <= ST_SAVE_CRAM0;
                    cram_idx <= 0;
                end else
                    vdp_idx[0] <= 1'b1;
            end
        end

        ST_SAVE_CRAM0: begin
            // cram_snap[383:0] = 6 × 64 bits
            if (!DDRAM_BUSY) begin
                case (cram_idx)
                    3'd0: ddram_write(base_addr + 29'd8,  cram_snap[63:0],    8'hFF);
                    3'd1: ddram_write(base_addr + 29'd9,  cram_snap[127:64],  8'hFF);
                    3'd2: ddram_write(base_addr + 29'd10, cram_snap[191:128], 8'hFF);
                    3'd3: ddram_write(base_addr + 29'd11, cram_snap[255:192], 8'hFF);
                    3'd4: ddram_write(base_addr + 29'd12, cram_snap[319:256], 8'hFF);
                    3'd5: ddram_write(base_addr + 29'd13, cram_snap[383:320], 8'hFF);
                    default: ;
                endcase
                if (cram_idx == 5)
                    state <= ST_SAVE_PSG;
                else
                    cram_idx <= cram_idx + 3'd1;
            end
        end

        ST_SAVE_PSG: begin
            if (!DDRAM_BUSY) begin
                ddram_write(base_addr + 29'd14, {8'd0, psg_snap}, 8'hFF);
                state <= ST_SAVE_MAPPER;
            end
        end

        ST_SAVE_MAPPER: begin
            if (!DDRAM_BUSY) begin
                ddram_write(base_addr + 29'd15, mapper_snap, 8'hFF);
                state <= ST_SAVE_IO;
            end
        end

        ST_SAVE_IO: begin
            if (!DDRAM_BUSY) begin
                ddram_write(base_addr + 29'h019, {evolution_snap[31:0], io_snap}, 8'hFF);
                state <= ST_SAVE_VIDEO;
            end
        end

        ST_SAVE_VIDEO: begin
            if (!DDRAM_BUSY) begin
                ddram_write(base_addr + 29'h01a, video_word, 8'hFF);
                gg_word <= 0;
                state <= ST_SAVE_GG;
            end
        end

        ST_SAVE_GG: begin
            if (!DDRAM_BUSY) begin
                ddram_write(base_addr + 29'h01c + {28'd0,gg_word}, gg_word ? gg_snap[127:64] : gg_snap[63:0], 8'hFF);
                if (gg_word) state <= ST_SAVE_MD;
                else gg_word <= 1;
            end
        end

        ST_SAVE_MD: begin
            if (!DDRAM_BUSY) begin
                ddram_write(base_addr + 29'h01e, {18'd0,md_snap}, 8'hFF);
                state <= ST_SAVE_SC_DESC;
            end
        end

        ST_SAVE_SC_DESC: begin
            if (!DDRAM_BUSY) begin
                ddram_write(base_addr + 29'h025, sc_descriptor, 8'hFF);
                state <= ST_SAVE_TAP;
            end
        end

        ST_SAVE_TAP: begin
            if (!DDRAM_BUSY) begin
                ddram_write(base_addr + 29'h026, {13'd0,tap_snap,32'h4d544150}, 8'hFF);
                state <= ST_SAVE_PADDLE;
            end
        end

        ST_SAVE_PADDLE: begin
            if (!DDRAM_BUSY) begin
                ddram_write(base_addr + 29'h027, {paddle_snap,32'h50414437}, 8'hFF);
                state <= ST_SAVE_GUN0;
            end
        end

        ST_SAVE_GUN0: begin
            if (!DDRAM_BUSY) begin
                ddram_write(base_addr + 29'h028, {18'd0,gun_snap}, 8'hFF);
                state <= ST_SAVE_GUN1;
            end
        end
        ST_SAVE_GUN1: begin
            if (!DDRAM_BUSY) begin
                ddram_write(base_addr + 29'h029, GUN_DESC, 8'hFF);
                state <= ST_SAVE_HISTORY0;
            end
        end
        ST_SAVE_HISTORY0: begin
            if (!DDRAM_BUSY) begin
                ddram_write(base_addr + 29'h02a, {46'd0,mapper_history_snap}, 8'hFF);
                state <= ST_SAVE_HISTORY1;
            end
        end
        ST_SAVE_HISTORY1: begin
            if (!DDRAM_BUSY) begin
                ddram_write(base_addr + 29'h02b, MAPPER_HISTORY_DESC, 8'hFF);
                state <= ST_SAVE_EVOLUTION0;
            end
        end
        ST_SAVE_EVOLUTION0: begin
            if (!DDRAM_BUSY) begin
                ddram_write(base_addr + 29'h02c, {4'd0,evolution_snap[155:96]}, 8'hFF);
                state <= ST_SAVE_EVOLUTION1;
            end
        end

        ST_SAVE_SPRITE_DESC: if (!DDRAM_BUSY) begin
            ddram_write(base_addr+29'h02e,SPRITE_DESC,8'hff);state<=ST_SAVE_PHASE;
        end
        ST_SAVE_PHASE: if (!DDRAM_BUSY) begin
            ddram_write(base_addr+29'h02f,{60'd0,capture_tick_snap,systeme,phase_snap},8'hff);
            sprite_word<=0;sprite_second<=0;state<=ST_SAVE_SPRITE;
        end
        ST_SAVE_SPRITE: if (!DDRAM_BUSY) begin
            ddram_write(base_addr+sprite_address,sprite_write_word,8'hff);
            if (sprite_second) sprite2_snap <= {sprite2_snap[63:0],sprite2_snap[4799:64]};
            else sprite_snap <= {sprite_snap[63:0],sprite_snap[4799:64]};
            if (sprite_word==74) begin
                sprite_word<=0;sprite_second<=1;
                if (sprite_second) state<=ST_SAVE_BG_DESC;
            end else sprite_word<=sprite_word+7'd1;
        end
        ST_LOAD_SPRITE_DESC, ST_LOAD_PHASE, ST_LOAD_SPRITE: begin
            if (DDRAM_DOUT_READY && dout_expected) begin
                dout_expected<=0;dout_latch<=DDRAM_DOUT;
            end else if (!dout_expected && !DDRAM_BUSY) begin
                case(state)
                ST_LOAD_SPRITE_DESC: if (dout_latch!=SPRITE_DESC) state<=ST_ERROR;
                    else begin ddram_read(base_addr+29'h02f);state<=ST_LOAD_PHASE;end
                ST_LOAD_PHASE: if (dout_latch[63:4]!=0 || dout_latch[2]!=systeme) state<=ST_ERROR;
                    else begin
                        phase_snap<=dout_latch[1:0];capture_tick_snap<=dout_latch[3];sprite_word<=0;sprite_second<=0;
                        ddram_read(base_addr+29'h2901);state<=ST_LOAD_SPRITE;
                    end
                ST_LOAD_SPRITE: if ((sprite_word==74 && dout_latch[63:42]!=0) ||
                                   (sprite_second && !systeme && dout_latch!=0)) state<=ST_ERROR;
                    else begin
                        if (sprite_second) sprite2_snap <= {dout_latch,sprite2_snap[4799:64]};
                        else sprite_snap <= {dout_latch,sprite_snap[4799:64]};
                        if (sprite_second && sprite_word==74) begin
                            ddram_read(base_addr+(has_background?29'h032:29'h01f));
                            state<=has_background?ST_LOAD_BG_DESC:ST_LOAD_EE_DESC;
                        end else begin
                            ddram_read(base_addr+sprite_address+29'd1);
                            if (sprite_word==74) begin sprite_word<=0;sprite_second<=1;end
                            else sprite_word<=sprite_word+7'd1;
                        end
                    end
                endcase
            end
        end
        ST_SAVE_BG_DESC: if (!DDRAM_BUSY) begin
            ddram_write(base_addr+29'h032,BACKGROUND_DESC,8'hff);
            bg_word<=0;bg_second<=0;state<=ST_SAVE_BG;
        end
        ST_SAVE_BG: if (!DDRAM_BUSY) begin
            ddram_write(base_addr+bg_address,bg_write_word,8'hff);
            if (bg_second) begin
                if (bg_word==2) bg2_snap<={bg2_snap[10:0],bg2_snap[138:11]};
                else bg2_snap<={bg2_snap[63:0],bg2_snap[138:64]};
            end else begin
                if (bg_word==2) bg_snap<={bg_snap[10:0],bg_snap[138:11]};
                else bg_snap<={bg_snap[63:0],bg_snap[138:64]};
            end
            if (bg_word==2) begin
                bg_word<=0;bg_second<=1;
                if (bg_second) state<=ST_SAVE_EE_DESC;
            end else bg_word<=bg_word+2'd1;
        end
        ST_LOAD_BG_DESC,ST_LOAD_BG: begin
            if (DDRAM_DOUT_READY && dout_expected) begin
                dout_expected<=0;dout_latch<=DDRAM_DOUT;
            end else if (!dout_expected && !DDRAM_BUSY) begin
                if (state==ST_LOAD_BG_DESC) begin
                    if (dout_latch!=BACKGROUND_DESC) state<=ST_ERROR;
                    else begin bg_word<=0;bg_second<=0;ddram_read(base_addr+29'h033);state<=ST_LOAD_BG;end
                end else if (bg_word_invalid) state<=ST_ERROR;
                else begin
                    if (bg_second) begin
                        if (bg_word==2) bg2_snap<={dout_latch[10:0],bg2_snap[138:11]};
                        else bg2_snap<={dout_latch,bg2_snap[138:64]};
                    end else begin
                        if (bg_word==2) bg_snap<={dout_latch[10:0],bg_snap[138:11]};
                        else bg_snap<={dout_latch,bg_snap[138:64]};
                    end
                    if (bg_second && bg_word==2) begin ddram_read(base_addr+29'h01f);state<=ST_LOAD_EE_DESC;end
                    else begin
                        ddram_read(base_addr+bg_address+29'd1);
                        if (bg_word==2) begin bg_word<=0;bg_second<=1;end
                        else bg_word<=bg_word+2'd1;
                    end
                end
            end
        end
        ST_SAVE_EVOLUTION1: begin
            if (!DDRAM_BUSY) begin
                ddram_write(base_addr + 29'h02d, EVOLUTION_HISTORY_DESC, 8'hFF);
                state <= ST_SAVE_SPRITE_DESC;
            end
        end
        ST_SAVE_EE_DESC: begin
            if (!DDRAM_BUSY) begin
                ddram_write(base_addr + 29'h01f, eeprom_exists_snap ? EEPROM_DESC : EEPROM_ABSENT, 8'hFF);
                eeprom_ext_word <= 0;
                state <= eeprom_exists_snap ? ST_SAVE_EE_EXT : ST_SAVE_EEPROM;
            end
        end
        ST_SAVE_EE_EXT: begin
            if (!DDRAM_BUSY) begin
                ddram_write(base_addr + 29'h030 + {28'd0,eeprom_ext_word}, eeprom_ext_word ? eeprom_ext_snap[127:64] : eeprom_ext_snap[63:0], 8'hFF);
                if (eeprom_ext_word) state <= ST_SAVE_EEPROM;
                else eeprom_ext_word <= 1;
            end
        end

        ST_SAVE_EEPROM: begin
            if (!DDRAM_BUSY) begin
                ddram_write(base_addr + 29'h01b,
                            evolution_snap[31:16] == 16'hE132 ? evolution_snap[95:32] : eeprom_snap,
                            8'hFF);
                if (systeme) begin
                    // System E: save VDP2/CRAM2/PSG2 before VRAM1
                    cram_idx  <= 0;
                    vdp_idx   <= 0;
                    state     <= ST_SAVE_VDP2REG;
                end else begin
                    // Start VRAM DMA: 16384 bytes → 2048 × 64-bit words
                    // DDRAM offset 0x100 words from base
                    vram_save_addr <= 0;
                    vram_byte_cnt  <= 0;
                    vram_word_buf  <= 0;
                    vram_pipe      <= 0;
                    vram_en        <= 1;
                    vram_A         <= 0;
                    word_cnt       <= 0;
                    vram_d_latched <= 0;
                    state          <= ST_SAVE_VRAM;
                end
            end
        end

        ST_SAVE_VDP2REG: begin
            if (!DDRAM_BUSY) begin
                case (vdp_idx[0])
                    1'b0: ddram_write(base_addr + 29'h10, vdp2_snap[63:0],   8'hFF);
                    1'b1: ddram_write(base_addr + 29'h11, vdp2_snap[127:64], 8'hFF);
                endcase
                if (vdp_idx[0] == 1) begin
                    cram_idx <= 0;
                    state    <= ST_SAVE_CRAM2;
                end else
                    vdp_idx[0] <= 1'b1;
            end
        end

        ST_SAVE_CRAM2: begin
            // 6 words × 64-bit = 384 bits = CRAM2
            if (!DDRAM_BUSY) begin
                case (cram_idx)
                    3'd0: ddram_write(base_addr + 29'h12, cram2_snap[ 63:  0], 8'hFF);
                    3'd1: ddram_write(base_addr + 29'h13, cram2_snap[127: 64], 8'hFF);
                    3'd2: ddram_write(base_addr + 29'h14, cram2_snap[191:128], 8'hFF);
                    3'd3: ddram_write(base_addr + 29'h15, cram2_snap[255:192], 8'hFF);
                    3'd4: ddram_write(base_addr + 29'h16, cram2_snap[319:256], 8'hFF);
                    3'd5: ddram_write(base_addr + 29'h17, cram2_snap[383:320], 8'hFF);
                    default: ;
                endcase
                if (cram_idx == 3'd5) begin
                    cram_idx <= 0;
                    state    <= ST_SAVE_PSG2;
                end else begin
                    cram_idx <= cram_idx + 3'd1;
                end
            end
        end

        ST_SAVE_PSG2: begin
            if (!DDRAM_BUSY) begin
                ddram_write(base_addr + 29'h18, {8'h0, psg2_snap}, 8'h7F);
                // Now start VRAM1 DMA from VDP1's active se_bank half
                vram_save_addr <= {mapper_snap[7], 14'b0};
                vram_byte_cnt  <= 0;
                vram_word_buf  <= 0;
                vram_pipe      <= 0;
                vram_en        <= 1;
                vram_A         <= {mapper_snap[7], 14'b0};
                word_cnt       <= 0;
                vram_d_latched <= 0;
                state          <= ST_SAVE_VRAM;
            end
        end

        ST_SAVE_VRAM, ST_SAVE_VRAM1_PASSIVE,
        ST_SAVE_VRAM2, ST_SAVE_VRAM2_PASSIVE: begin
            if (vram_second_port) vram2_en <= 1;
            else                  vram_en <= 1;
            // Prime for two visits; preserve the +1/+2 address lookahead.
            if (vram_pipe < 3'd2) begin
                vram_pipe <= vram_pipe + 3'd1;
                if (vram_pipe >= 1 && vram_save_addr[13:0] != 14'h3FFF) begin
                    if (vram_second_port) vram2_A <= vram_save_addr + 15'd1;
                    else                  vram_A <= vram_save_addr + 15'd1;
                end
            end else begin
                if (vram_byte_cnt < 7 || !DDRAM_BUSY) begin
                    vram_d_latched <= 0;
                    vram_word_buf <= {(vram_byte_cnt == 7 && vram_d_latched) ? vram_d_latch : vram_save_data,
                                      vram_word_buf[63:8]};
                    vram_byte_cnt <= vram_byte_cnt + 3'd1;
                    if (vram_byte_cnt == 7) begin
                        // Use byte 7 directly with the OLD buffer contents.
                        ddram_write(base_addr + vram_ddr_offset + {17'd0, word_cnt},
                                    {vram_d_latched ? vram_d_latch : vram_save_data,
                                     vram_word_buf[63:8]}, 8'hFF);
                        word_cnt <= word_cnt + 12'd1;
                    end
                    if (vram_save_addr[13:0] < 14'h3FFF) begin
                        vram_save_addr <= vram_save_addr + 15'd1;
                        if (vram_second_port) vram2_A <= vram_save_addr + 15'd2;
                        else                  vram_A <= vram_save_addr + 15'd2;
                    end else if (vram_byte_cnt == 7) begin
                        case (state)
                            ST_SAVE_VRAM: begin
                                if (systeme) begin
                                    // System E: save VDP1 passive bank before WRAM
                                    vram_save_addr <= {~mapper_snap[7], 14'b0};
                                    vram_byte_cnt  <= 0;
                                    vram_word_buf  <= 0;
                                    vram_pipe      <= 0;
                                    vram_A         <= {~mapper_snap[7], 14'b0};
                                    word_cnt       <= 0;
                                    vram_d_latched <= 0;
                                    state          <= ST_SAVE_VRAM1_PASSIVE;
                                    vram_en        <= 1;
                                end else begin
                                    vram_en <= 0;
                                    // Start WRAM DMA
                                    wram_save_addr <= 0;
                                    wram_byte_cnt  <= 0;
                                    wram_word_buf  <= 0;
                                    wram_pipe      <= 0;
                                    wram_A         <= 0;
                                    word_cnt       <= 0;
                                    wram_d_latched <= 0;
                                    state          <= ST_SAVE_WRAM;
                                end
                            end
                            ST_SAVE_VRAM1_PASSIVE: begin
                                vram_en <= 0;
                                // Continue to WRAM save
                                wram_save_addr <= 0;
                                wram_byte_cnt  <= 0;
                                wram_word_buf  <= 0;
                                wram_pipe      <= 0;
                                wram_A         <= 0;
                                word_cnt       <= 0;
                                wram_d_latched <= 0;
                                state          <= ST_SAVE_WRAM;
                            end
                            ST_SAVE_VRAM2: begin
                                // Save VDP2 passive bank before ending (ST_SAVE_VRAM2 is System E only)
                                vram_save_addr <= {~mapper_snap[6], 14'b0};
                                vram_byte_cnt  <= 0;
                                vram_word_buf  <= 0;
                                vram_pipe      <= 0;
                                vram2_A        <= {~mapper_snap[6], 14'b0};
                                word_cnt       <= 0;
                                vram_d_latched <= 0;
                                state          <= ST_SAVE_VRAM2_PASSIVE;
                                // vram2_en stays 1 for the passive-save state
                            end
                            ST_SAVE_VRAM2_PASSIVE: begin
                                vram2_en <= 0;
                                if (transfer_eeprom) begin
                                    nvram_save_addr <= 0; nvram_byte_cnt <= 0;
                                    nvram_word_buf <= 0; nvram_pipe <= 0;
                                    nvram_A <= 0; word_cnt <= 0; nvram_d_latched <= 0;
                                    state <= ST_SAVE_NVRAM;
                                end else state <= ST_SAVE_AUDIO_PAYLOAD;
                            end
                        endcase
                    end
                end else begin
                    // Capture only the first stalled eighth byte.
                    if (!vram_d_latched) begin
                        vram_d_latch   <= vram_save_data;
                        vram_d_latched <= 1;
                    end
                end
            end
        end


        ST_SAVE_WRAM: begin
            // System E has 16KB RAM (0x0000-0x3FFF); SMS has 8KB (0xC000-0xDFFF).
            // For System E we reuse the combined WRAM+NVRAM region (0x901-0x1100).
            if (wram_pipe < 2'd2) begin
                wram_pipe <= wram_pipe + 2'd1;
                if (wram_pipe >= 1 && wram_save_addr < (systeme ? 14'd16383 : 14'd8191))
                    wram_A <= wram_save_addr + 14'd1;
            end else begin
                // Stall at 8-byte boundary if DDRAM is busy (same pattern as VRAM)
                if (wram_byte_cnt < 7 || !DDRAM_BUSY) begin
                    wram_d_latched <= 0;
                    wram_word_buf <= {(wram_byte_cnt == 7 && wram_d_latched) ? wram_d_latch : wram_D,
                                      wram_word_buf[63:8]};
                    wram_byte_cnt <= wram_byte_cnt + 3'd1;
                    if (wram_byte_cnt == 7) begin
                        ddram_write(base_addr + 29'h901 + {17'd0, word_cnt},
                                    {wram_d_latched ? wram_d_latch : wram_D,
                                     wram_word_buf[63:8]}, 8'hFF);
                        word_cnt <= word_cnt + 12'd1;
                    end
                    if (wram_save_addr < (systeme ? 14'd16383 : 14'd8191)) begin
                        wram_save_addr <= wram_save_addr + 14'd1;
                        wram_A         <= wram_save_addr + 14'd2;
                    end else if (wram_byte_cnt == 7) begin
                        if (systeme) begin
                            // System E: save second VRAM (16KB) at 0x1101, from VDP2's active se_bank
                            vram_save_addr <= {mapper_snap[6], 14'b0};
                            vram_byte_cnt  <= 0;
                            vram_word_buf  <= 0;
                            vram_pipe      <= 0;
                            vram2_en       <= 1;
                            vram2_A        <= {mapper_snap[6], 14'b0};
                            word_cnt       <= 0;
                            vram_d_latched <= 0;
                            state          <= ST_SAVE_VRAM2;
                        end else if (transfer_ram || transfer_eeprom) begin
                            // Save NVRAM (up to 32KB)
                            nvram_save_addr <= 0;
                            nvram_byte_cnt  <= 0;
                            nvram_word_buf  <= 0;
                            nvram_pipe      <= 0;
                            nvram_A         <= 0;
                            word_cnt        <= 0;
                            nvram_d_latched <= 0;
                            state           <= ST_SAVE_NVRAM;
                        end else begin
                            state <= ST_SAVE_AUDIO_PAYLOAD;
                        end
                    end
                end else begin
                    if (!wram_d_latched) begin
                        wram_d_latch   <= wram_D;
                        wram_d_latched <= 1;
                    end
                end
            end
        end

        ST_SAVE_NVRAM: begin
            if (nvram_pipe < 2'd2) begin
                nvram_pipe <= nvram_pipe + 2'd1;
                if (nvram_pipe >= 1 && nvram_save_addr < nvram_size_minus_1)
                    nvram_A <= nvram_save_addr + 15'd1;
            end else begin
                // Stall at 8-byte boundary if DDRAM is busy (same pattern as VRAM/WRAM)
                if (nvram_byte_cnt < 7 || !DDRAM_BUSY) begin
                    nvram_d_latched <= 0;
                    nvram_word_buf <= {(nvram_byte_cnt == 7 && nvram_d_latched) ? nvram_d_latch : nvram_D,
                                       nvram_word_buf[63:8]};
                    nvram_byte_cnt <= nvram_byte_cnt + 3'd1;
                    if (nvram_byte_cnt == 7) begin
                        ddram_write(base_addr + nvram_ddr_base + {17'd0, word_cnt},
                                    {nvram_d_latched ? nvram_d_latch : nvram_D,
                                     nvram_word_buf[63:8]}, 8'hFF);
                        word_cnt <= word_cnt + 12'd1;
                    end
                    if (nvram_save_addr < nvram_size_minus_1) begin
                        nvram_save_addr <= nvram_save_addr + 15'd1;
                        nvram_A         <= nvram_save_addr + 15'd2;
                    end else if (nvram_byte_cnt == 7) begin
                        state <= ST_SAVE_AUDIO_PAYLOAD;
                    end
                end else begin
                    if (!nvram_d_latched) begin
                        nvram_d_latch   <= nvram_D;
                        nvram_d_latched <= 1;
                    end
                end
            end
        end



        // Invalidate an old slot before replacing any of its contents.
        ST_SAVE_AUDIO_INVALID: begin
            if (!DDRAM_BUSY) begin
                ddram_write(base_addr + 29'h00e, {12'd0, psg_snap[51:0]}, 8'hFF);
                state <= ST_SAVE_HDR;
            end
        end
        ST_SAVE_AUDIO_PAYLOAD: begin
            if (!DDRAM_BUSY) begin
                case (audio_word)
                    0: ddram_write(base_addr + 29'h021, psg_ext_snap[63:0], 8'hFF);
                    1: ddram_write(base_addr + 29'h022, {32'd0,psg_ext_snap[95:64]}, 8'hFF);
                    2: ddram_write(base_addr + 29'h023, psg2_ext_snap[63:0], 8'hFF);
                    3: ddram_write(base_addr + 29'h024, {32'd0,psg2_ext_snap[95:64]}, 8'hFF);
                endcase
                if (audio_word == audio_words-1) state <= ST_SAVE_AUDIO_DESC;
                else audio_word <= audio_word+3'd1;
            end
        end
        ST_SAVE_AUDIO_DESC: begin
            if (!DDRAM_BUSY) begin
                ddram_write(base_addr + 29'h020, audio_descriptor, 8'hFF);
                freeze_drain_cnt <= 0;
                state <= ST_SAVE_AUDIO_DRAIN;
            end
        end
        ST_SAVE_AUDIO_DRAIN: begin
            // Drain all ordered payload/descriptor writes before publishing presence.
            if (DDRAM_BUSY) freeze_drain_cnt <= 0;
            else if (freeze_drain_cnt == 31) state <= ST_SAVE_AUDIO_COMMIT;
            else freeze_drain_cnt <= freeze_drain_cnt+6'd1;
        end
        ST_SAVE_AUDIO_COMMIT: begin
            if (!DDRAM_BUSY) begin
                ddram_write(base_addr + 29'h00e,
                            {1'b1,audio_control_snap,psg_snap[51:0]},8'hFF);
                state <= ST_SAVE_DONE; // framework change detector remains last
            end
        end

        ST_SAVE_DONE: begin
            // Write MiSTer framework control word at slot base (word 0).
            // [31:0]  = change_det: must change on every save to trigger firmware write to /savestates/
            // [63:32] = size in 32-bit words = (slot_size_bytes - 8) / 4
            //           slot = 96KB = 98304 bytes; minus 8-byte control word = 98296 bytes → 24574 words
            if (cur_bios_mode) begin
                // BIOS states live in their own DDRAM region (bios_slot_base);
                // update size only: an overwritten old 64KB BIOS header must
                // not classify this committed extension as an old-format load.
                // Preserve all change_det bytes; BIOS publication stays disabled.
                if (!DDRAM_BUSY) begin
                    ddram_write(base_addr, {NEW_SS_WORDS,32'd0},8'hF0);
                    freeze_drain_cnt <= 0;
                    state <= ST_SAVE_SETTLE;
                end
            end else if (!DDRAM_BUSY) begin
                ddram_write(base_addr + 29'd0, {NEW_SS_WORDS, ss_change_det}, 8'hFF);
                ss_change_det <= ss_change_det + 32'd1;
                freeze_drain_cnt <= 0;
                state <= ST_SAVE_SETTLE;
            end
        end

        ST_SAVE_SETTLE: begin
            // Wait for 32 consecutive idle clocks after the last save write.
            // This avoids immediate load seeing partially drained write queues.
            if (DDRAM_BUSY)
                freeze_drain_cnt <= 0;
            else if (freeze_drain_cnt == 6'd31) begin
                unfreeze_cnt <= 8'd0;
                state <= ST_UNFREEZE;
            end else
                freeze_drain_cnt <= freeze_drain_cnt + 6'd1;
        end

        // ===============================================================
        // LOAD
        // ===============================================================

        ST_LOAD_HDR_RD: begin
            if (!DDRAM_BUSY) begin
                has_nmi_history <= 0; nmi_snap <= 3'b001; nmi_padding_ok <= 1;
                has_restart_context <= 0; restart_snap <= 0; restart_padding_ok <= 1;
        has_restart <= 0; phase_snap <= 0; sprite_snap <= 0; sprite2_snap <= 0;
        has_background<=0;bg_snap<=0;bg2_snap<=0;bg_word<=0;bg_second<=0;
                // Old 64KB files have no beam history: use a deterministic origin.
                video_snap <= 0;
                // Old 64KB files bypass ST_LOAD_VIDEO entirely.
                vdp_snap[135:128] <= 8'd0;
                vdp2_snap[135:128] <= 8'd0;
                gg_snap <= GG_RESET;
                md_snap <= 0; md_valid <= 0; has_md_ext <= 0;
                mapper_history_snap <= MAPPER_HISTORY_LEGACY; has_mapper_history <= 0;
                evolution_snap[159:96] <= 0; has_evolution_history <= 0; evolution_history_valid <= 0;
                gun_snap <= 0; gun_valid <= 0; has_gun_tag <= 0;
                paddle_snap <= 0; paddle_valid <= 0; has_paddle_tag <= 0;
                tap_snap <= 0; tap_valid <= 0; has_tap_tag <= 0;
                eeprom_full <= 0; eeprom_ext_snap <= 0; has_eeprom_tag <= 0;
                // Old 64K files bypass the EEPROM word entirely.
                eeprom_snap <= 64'd1; // inactive wrapper, writes disabled, DO ready
                ddram_read(base_addr + 29'd0);
                state <= ST_LOAD_HDR_WT;
            end
        end

        ST_LOAD_HDR_WT: begin
            if (DDRAM_DOUT_READY && dout_expected) begin
                dout_expected <= 0;
                dout_latch    <= DDRAM_DOUT;
            end else if (!dout_expected && !DDRAM_BUSY) begin
                is_old_format <= (dout_latch[63:32] == OLD_SS_WORDS);
                ddram_read(base_addr + 29'd1);
                state <= ST_LOAD_HDR_WT2;
            end
        end

        ST_LOAD_HDR_WT2: begin
            if (DDRAM_DOUT_READY && dout_expected) begin
                dout_expected <= 0;
                dout_latch    <= DDRAM_DOUT;
            end else if (!dout_expected && !DDRAM_BUSY) begin
                if (dout_latch[31:0] == cur_magic &&
                    (is_old_format || dout_latch[63:32] == cur_game_id)) begin
                    // Untagged files bypass extension validation and its ordinary
                    // lightgun restore. Tagged files must defer this write until
                    // ST_LOAD_EE_DESC, after v12 padding/subtype validation.
                    if (is_old_format && !live_evolution) begin
                        gun_in <= 0; gun_valid <= 0; gun_set <= 1;
                    end
                    // Old format stored no game_id in word 1, so skip that check.
                    // Read Z80 words
                    ddram_read(base_addr + 29'd2);
                    cpu_idx <= 0;
                    state   <= ST_LOAD_CPU0;
                end else begin
                    // Invalid magic: abort
                    unfreeze_cnt <= 8'd0;
                    is_old_format <= 1; // bypass coordinate alignment
                    state <= ST_UNFREEZE;
                end
            end
        end

        ST_LOAD_CPU0: begin
            if (DDRAM_DOUT_READY && dout_expected) begin
                dout_expected <= 0;
                dout_latch    <= DDRAM_DOUT;
            end else if (!dout_expected && !DDRAM_BUSY) begin
                case (cpu_idx)
                    3'd0: begin z80_snap[63:0]    <= dout_latch; ddram_read(base_addr + 29'd3); end
                    3'd1: begin z80_snap[127:64]  <= dout_latch; ddram_read(base_addr + 29'd4); end
                    3'd2: begin z80_snap[191:128] <= dout_latch; ddram_read(base_addr + 29'd5); end
                    3'd3: begin
                        nmi_snap <= dout_latch[40:38];
                        restart_snap <= dout_latch[43:41];
                        restart_padding_ok <= dout_latch[63:44] == 0 && dout_latch[43:41] <= 3'd5;
                        nmi_padding_ok <= dout_latch[63:41] == 0;
                        if (is_old_format) begin
                            z80_snap[211:192] <= dout_latch[19:0];
                            z80_snap[227:212] <= 16'd0;
                            z80_snap[228]     <= 1'b0;
                            z80_snap[229]     <= 1'b0; // Halt_FF default on old format
                        end else begin
                            z80_snap[229:192] <= dout_latch[37:0];
                        end
                        ddram_read(base_addr + 29'd6);
                    end
                endcase
                if (cpu_idx == 3) begin
                    vdp_idx <= 0;
                    state   <= ST_LOAD_VDP0;
                end else
                    cpu_idx <= cpu_idx + 3'd1;
            end
        end

        ST_LOAD_VDP0: begin
            if (DDRAM_DOUT_READY && dout_expected) begin
                dout_expected <= 0;
                dout_latch    <= DDRAM_DOUT;
            end else if (!dout_expected && !DDRAM_BUSY) begin
                case (vdp_idx[0])
                    1'b0: begin vdp_snap[63:0]   <= dout_latch; ddram_read(base_addr + 29'd7); end
                    1'b1: begin vdp_snap[127:64]  <= dout_latch; ddram_read(base_addr + 29'd8); end
                endcase
                if (vdp_idx[0]) begin
                    cram_idx <= 0;
                    state    <= ST_LOAD_CRAM;
                end else
                    vdp_idx[0] <= 1'b1;
            end
        end

        ST_LOAD_CRAM: begin
            // Read 6 DDRAM words, then restore 32 entries one-by-one
            // Phase 1: read all 6 words (use cram_idx as word index)
            // Phase 2: write entries (use cram_entry)
            if (DDRAM_DOUT_READY && dout_expected) begin
                dout_expected <= 0;
                dout_latch    <= DDRAM_DOUT;
            end else if (!dout_expected && !DDRAM_BUSY) begin
                case (cram_idx)
                    3'd0: begin cram_snap[63:0]    <= dout_latch; ddram_read(base_addr + 29'd9);  end
                    3'd1: begin cram_snap[127:64]  <= dout_latch; ddram_read(base_addr + 29'd10); end
                    3'd2: begin cram_snap[191:128] <= dout_latch; ddram_read(base_addr + 29'd11); end
                    3'd3: begin cram_snap[255:192] <= dout_latch; ddram_read(base_addr + 29'd12); end
                    3'd4: begin cram_snap[319:256] <= dout_latch; ddram_read(base_addr + 29'd13); end
                    3'd5: begin cram_snap[383:320] <= dout_latch; ddram_read(base_addr + 29'd14); end
                    default: ;
                endcase
                if (cram_idx == 5) begin
                    // Start writing entries next cycle
                    cram_entry <= 0;
                    state      <= ST_LOAD_PSG;
                    // Note: cram restore happens in ST_LOAD_RESTORE after all reads
                end else
                    cram_idx <= cram_idx + 3'd1;
            end
        end

        ST_LOAD_PSG: begin
            if (DDRAM_DOUT_READY && dout_expected) begin
                dout_expected <= 0;
                dout_latch    <= DDRAM_DOUT;
            end else if (!dout_expected && !DDRAM_BUSY) begin
                psg_snap <= dout_latch[63] ? {4'd0,dout_latch[51:0]} : dout_latch[55:0];
                if (dout_latch[63]) begin
                    audio_control_snap <= dout_latch[62:52];
                    ddram_read(base_addr + 29'h020);
                    state <= ST_LOAD_AUDIO_DESC;
                end else begin
                    // Never inspect stale extension metadata for a legacy state.
                    ddram_read(base_addr + 29'd15);
                    state <= ST_LOAD_MAPPER;
                end
            end
        end

        ST_LOAD_AUDIO_DESC: begin
            if (DDRAM_DOUT_READY && dout_expected) begin
                dout_expected <= 0;
                dout_latch <= DDRAM_DOUT;
            end else if (!dout_expected && !DDRAM_BUSY) begin
                if (!is_old_format && dout_latch[31:0] == AUDIO_MAGIC &&
                    dout_latch[39:32] == 8'd1 && dout_latch[40] == systeme &&
                    dout_latch[48:46] == audio_words && dout_latch[63:49] == 0) begin
                    audio_div_snap <= dout_latch[44:41];
                    audio_phase_snap <= dout_latch[45];
                    audio_word <= 0;
                    ddram_read(base_addr + 29'h021);
                    state <= ST_LOAD_AUDIO_PAYLOAD;
                end else begin
                    // Presence without a supported descriptor is never legacy.
                    state <= ST_ERROR;
                end
            end
        end
        ST_LOAD_AUDIO_PAYLOAD: begin
            if (DDRAM_DOUT_READY && dout_expected) begin
                dout_expected <= 0;
                dout_latch <= DDRAM_DOUT;
            end else if (!dout_expected && !DDRAM_BUSY) begin
                if (audio_word[0] && (dout_latch[63:32] != 0)) begin
                    state <= ST_ERROR;
                end else begin
                    case (audio_word)
                        0: psg_ext_snap[63:0] <= dout_latch;
                        1: psg_ext_snap[95:64] <= dout_latch[31:0];
                        2: psg2_ext_snap[63:0] <= dout_latch;
                        3: psg2_ext_snap[95:64] <= dout_latch[31:0];
                    endcase
                    if (audio_word == audio_words-1) begin
                        has_audio_ext <= 1;
                        ddram_read(base_addr + 29'h00f);
                        state <= ST_LOAD_MAPPER;
                    end else begin
                        audio_word <= audio_word+3'd1;
                        ddram_read(base_addr + 29'h022 + {26'd0,audio_word});
                    end
                end
            end
        end

        ST_LOAD_MAPPER: begin
            if (DDRAM_DOUT_READY && dout_expected) begin
                dout_expected <= 0;
                dout_latch    <= DDRAM_DOUT;
            end else if (!dout_expected && !DDRAM_BUSY) begin
                mapper_snap      <= dout_latch;
                if (is_old_format) begin
                    evolution_snap <= 160'd0;
                    vram_load_addr   <= 0;
                    vram_byte_cnt    <= 0;
                    vram_load_active <= 0;
                    word_cnt         <= 0;
                    if (live_evolution) state <= ST_ERROR;
                    else begin
                        ddram_read(base_addr + 29'h101);
                        state <= ST_LOAD_VRAM;
                    end
                end else begin
                    ddram_read(base_addr + 29'h019);
                    state            <= ST_LOAD_IO;
                end
            end
        end

        ST_LOAD_IO: begin
            if (DDRAM_DOUT_READY && dout_expected) begin
                dout_expected <= 0;
                dout_latch    <= DDRAM_DOUT;
            end else if (!dout_expected && !DDRAM_BUSY) begin
                io_snap          <= dout_latch[31:0];
                evolution_snap[31:0] <= dout_latch[63:32];
                ddram_read(base_addr + 29'h01a);
                state            <= ST_LOAD_VIDEO;
            end
        end

        ST_LOAD_VIDEO: begin
            if (DDRAM_DOUT_READY && dout_expected) begin
                dout_expected <= 0;
                dout_latch    <= DDRAM_DOUT;
            end else if (!dout_expected && !DDRAM_BUSY) begin
                has_nmi_history <= modern_nmi_tag;
                has_restart_context <= modern_restart_tag;
                has_restart <= dout_latch[63:40] == RESTART_MAGIC || dout_latch[63:40] == BACKGROUND_MAGIC;
                has_background <= dout_latch[63:40] == BACKGROUND_MAGIC;
                has_evolution_history <= (load_ext_magic == EVOLUTION_HISTORY_MAGIC || load_ext_magic == EVOLUTION_PENDING_MAGIC) && dout_latch[39:38] == 2'd3;
                if (invalid_nmi_header || (live_evolution || evolution_state) && (!evolution_state || load_ext_magic != EVOLUTION_PENDING_MAGIC || dout_latch[39:38] != 2'd3)) begin
                    state <= ST_ERROR;
                end else begin
                video_snap       <= dout_latch[21:0];
                has_mapper_history <= (load_ext_magic == MAPPER_HISTORY_MAGIC || (load_ext_magic == EVOLUTION_HISTORY_MAGIC || load_ext_magic == EVOLUTION_PENDING_MAGIC)) && dout_latch[39:38] == 2'd3;
                has_gun_tag <= (load_ext_magic == GUN_EXT_MAGIC || (load_ext_magic == MAPPER_HISTORY_MAGIC || (load_ext_magic == EVOLUTION_HISTORY_MAGIC || load_ext_magic == EVOLUTION_PENDING_MAGIC))) && dout_latch[39:38] == 2'd3;
                has_paddle_tag <= (load_ext_magic == PADDLE_EXT_MAGIC || (load_ext_magic == GUN_EXT_MAGIC || (load_ext_magic == MAPPER_HISTORY_MAGIC || (load_ext_magic == EVOLUTION_HISTORY_MAGIC || load_ext_magic == EVOLUTION_PENDING_MAGIC)))) && dout_latch[39:38] == 2'd3;
                has_tap_tag <= (load_ext_magic == TAP_EXT_MAGIC || load_ext_magic == PADDLE_EXT_MAGIC || (load_ext_magic == GUN_EXT_MAGIC || (load_ext_magic == MAPPER_HISTORY_MAGIC || (load_ext_magic == EVOLUTION_HISTORY_MAGIC || load_ext_magic == EVOLUTION_PENDING_MAGIC)))) && dout_latch[39:38] == 2'd3;
                has_sc_tag <= (load_ext_magic == SC_EXT_MAGIC || load_ext_magic == TAP_EXT_MAGIC || load_ext_magic == PADDLE_EXT_MAGIC || (load_ext_magic == GUN_EXT_MAGIC || (load_ext_magic == MAPPER_HISTORY_MAGIC || (load_ext_magic == EVOLUTION_HISTORY_MAGIC || load_ext_magic == EVOLUTION_PENDING_MAGIC)))) && dout_latch[39:38] == 2'd3;
                has_eeprom_tag <= (load_ext_magic == EEPROM_EXT_MAGIC || load_ext_magic == SC_EXT_MAGIC || load_ext_magic == TAP_EXT_MAGIC || load_ext_magic == PADDLE_EXT_MAGIC || (load_ext_magic == GUN_EXT_MAGIC || (load_ext_magic == MAPPER_HISTORY_MAGIC || (load_ext_magic == EVOLUTION_HISTORY_MAGIC || load_ext_magic == EVOLUTION_PENDING_MAGIC)))) && dout_latch[39:38] == 2'd3;
                has_md_ext <= (load_ext_magic == MD_EXT_MAGIC || load_ext_magic == EEPROM_EXT_MAGIC || load_ext_magic == SC_EXT_MAGIC || load_ext_magic == TAP_EXT_MAGIC || load_ext_magic == PADDLE_EXT_MAGIC || (load_ext_magic == GUN_EXT_MAGIC || (load_ext_magic == MAPPER_HISTORY_MAGIC || (load_ext_magic == EVOLUTION_HISTORY_MAGIC || load_ext_magic == EVOLUTION_PENDING_MAGIC)))) && dout_latch[39:38] == 2'd3;
                if ((load_ext_magic == HCOUNTER_MAGIC && dout_latch[39:38] == 2'd0) ||
                    (load_ext_magic == IO_EXT_MAGIC && dout_latch[39:38] == 2'd2) ||
                    ((load_ext_magic == MD_EXT_MAGIC || load_ext_magic == EEPROM_EXT_MAGIC || load_ext_magic == SC_EXT_MAGIC || load_ext_magic == TAP_EXT_MAGIC || load_ext_magic == PADDLE_EXT_MAGIC || (load_ext_magic == GUN_EXT_MAGIC || (load_ext_magic == MAPPER_HISTORY_MAGIC || (load_ext_magic == EVOLUTION_HISTORY_MAGIC || load_ext_magic == EVOLUTION_PENDING_MAGIC)))) && dout_latch[39:38] == 2'd3)) begin
                    vdp_snap[135:128] <= dout_latch[29:22];
                    vdp2_snap[135:128] <= systeme ? dout_latch[37:30] : 8'd0;
                end else begin
                    vdp_snap[135:128] <= 8'd0;
                    vdp2_snap[135:128] <= 8'd0;
                end
                if ((load_ext_magic == IO_EXT_MAGIC && dout_latch[39:38] == 2'd2) ||
                    ((load_ext_magic == MD_EXT_MAGIC || load_ext_magic == EEPROM_EXT_MAGIC || load_ext_magic == SC_EXT_MAGIC || load_ext_magic == TAP_EXT_MAGIC || load_ext_magic == PADDLE_EXT_MAGIC || (load_ext_magic == GUN_EXT_MAGIC || (load_ext_magic == MAPPER_HISTORY_MAGIC || (load_ext_magic == EVOLUTION_HISTORY_MAGIC || load_ext_magic == EVOLUTION_PENDING_MAGIC)))) && dout_latch[39:38] == 2'd3)) begin
                    gg_word <= 0;
                    ddram_read(base_addr + 29'h01c);
                    state <= ST_LOAD_GG;
                end else begin
                    ddram_read(base_addr + 29'h01b);
                    state <= ST_LOAD_EEPROM;
                end
                end
            end
        end

        ST_LOAD_GG: begin
            if (DDRAM_DOUT_READY && dout_expected) begin
                dout_expected <= 0;
                dout_latch <= DDRAM_DOUT;
            end else if (!dout_expected && !DDRAM_BUSY) begin
                if (!gg_word) begin
                    gg_snap[63:0] <= dout_latch;
                    gg_word <= 1;
                    ddram_read(base_addr + 29'h01d);
                end else begin
                    // Invalid/truncated padding never becomes local protocol state.
                    if (dout_latch[63:50] == 14'd0) gg_snap[127:64] <= dout_latch;
                    else gg_snap <= GG_RESET;
                    if (has_md_ext) begin
                        ddram_read(base_addr + 29'h01e);
                        state <= ST_LOAD_MD;
                    end else begin
                        ddram_read(base_addr + 29'h01b);
                        state <= ST_LOAD_EEPROM;
                    end
                end
            end
        end

        ST_LOAD_MD: begin
            if (DDRAM_DOUT_READY && dout_expected) begin
                dout_expected <= 0;
                dout_latch <= DDRAM_DOUT;
            end else if (!dout_expected && !DDRAM_BUSY) begin
                // Reserved bits and impossible local timer/phase values fail closed.
                md_valid <= dout_latch[63:46] == 0 &&
                            dout_latch[16:0] < 80540 && dout_latch[39:23] < 80540 &&
                            dout_latch[19:17] <= 4 && dout_latch[42:40] <= 4;
                md_snap <= dout_latch[45:0];
                if (has_sc_tag) begin
                    ddram_read(base_addr + 29'h025);
                    state <= ST_LOAD_SC_DESC;
                end else if (has_eeprom_tag) begin
                    ddram_read(base_addr + 29'h01f);
                    state <= ST_LOAD_EE_DESC;
                end else begin
                    ddram_read(base_addr + 29'h01b);
                    state <= ST_LOAD_EEPROM;
                end
            end
        end

        ST_LOAD_SC_DESC: begin
            if (DDRAM_DOUT_READY && dout_expected) begin
                dout_expected <= 0; dout_latch <= DDRAM_DOUT;
            end else if (!dout_expected && !DDRAM_BUSY) begin
                // Exact descriptor match validates owner, size and all reserved bits.
                sc_ram_full <= sc_size_snap != 0 && dout_latch == sc_descriptor;
                ddram_read(base_addr + (has_tap_tag ? 29'h026 : 29'h01f));
                state <= has_tap_tag ? ST_LOAD_TAP : ST_LOAD_EE_DESC;
            end
        end

        ST_LOAD_TAP: begin
            if (DDRAM_DOUT_READY && dout_expected) begin
                dout_expected <= 0; dout_latch <= DDRAM_DOUT;
            end else if (!dout_expected && !DDRAM_BUSY) begin
                tap_snap <= dout_latch[50:32];
                tap_valid <= dout_latch[31:0] == 32'h4d544150 &&
                             dout_latch[63:51] == 0 && dout_latch[47:32] <= 16'd57001;
                ddram_read(base_addr + (has_paddle_tag ? 29'h027 : 29'h01f));
                state <= has_paddle_tag ? ST_LOAD_PADDLE : ST_LOAD_EE_DESC;
            end
        end

        ST_LOAD_PADDLE: begin
            if (DDRAM_DOUT_READY && dout_expected) begin
                dout_expected <= 0; dout_latch <= DDRAM_DOUT;
            end else if (!dout_expected && !DDRAM_BUSY) begin
                paddle_snap <= dout_latch[63:32];
                paddle_valid <= dout_latch[31:0] == 32'h50414437 && dout_latch[63:52] <= 12'd3355;
                ddram_read(base_addr + (has_gun_tag ? 29'h028 : 29'h01f));
                state <= has_gun_tag ? ST_LOAD_GUN0 : ST_LOAD_EE_DESC;
            end
        end

        ST_LOAD_GUN0: begin
            if (DDRAM_DOUT_READY && dout_expected) begin
                dout_expected <= 0; dout_latch <= DDRAM_DOUT;
            end else if (!dout_expected && !DDRAM_BUSY) begin
                gun_snap <= dout_latch[45:0];
                gun_valid <= dout_latch[63:46] == 0;
                ddram_read(base_addr + 29'h029); state <= ST_LOAD_GUN1;
            end
        end
        ST_LOAD_GUN1: begin
            if (DDRAM_DOUT_READY && dout_expected) begin
                dout_expected <= 0; dout_latch <= DDRAM_DOUT;
            end else if (!dout_expected && !DDRAM_BUSY) begin
                gun_valid <= gun_valid && dout_latch == GUN_DESC;
                ddram_read(base_addr + (has_mapper_history ? 29'h02a : 29'h01f));
                state <= has_mapper_history ? ST_LOAD_HISTORY0 : ST_LOAD_EE_DESC;
            end
        end
        ST_LOAD_HISTORY0: begin
            if (DDRAM_DOUT_READY && dout_expected) begin
                dout_expected <= 0; dout_latch <= DDRAM_DOUT;
            end else if (!dout_expected && !DDRAM_BUSY) begin
                mapper_history_snap <= dout_latch[63:18] == 0 ? dout_latch[17:0] : MAPPER_HISTORY_LEGACY;
                ddram_read(base_addr + 29'h02b); state <= ST_LOAD_HISTORY1;
            end
        end
        ST_LOAD_HISTORY1: begin
            if (DDRAM_DOUT_READY && dout_expected) begin
                dout_expected <= 0; dout_latch <= DDRAM_DOUT;
            end else if (!dout_expected && !DDRAM_BUSY) begin
                if (dout_latch != MAPPER_HISTORY_DESC) mapper_history_snap <= MAPPER_HISTORY_LEGACY;
                ddram_read(base_addr + (has_evolution_history ? 29'h02c : 29'h01f));
                state <= has_evolution_history ? ST_LOAD_EVOLUTION0 : ST_LOAD_EE_DESC;
            end
        end
        ST_LOAD_EVOLUTION0: begin
            if (DDRAM_DOUT_READY && dout_expected) begin
                dout_expected <= 0; dout_latch <= DDRAM_DOUT;
            end else if (!dout_expected && !DDRAM_BUSY) begin
                evolution_snap[159:96] <= {4'd0,dout_latch[59:0]};
                evolution_history_valid <= dout_latch[63:60] == 0;
                ddram_read(base_addr + 29'h02d); state <= ST_LOAD_EVOLUTION1;
            end
        end
        ST_LOAD_EVOLUTION1: begin
            if (DDRAM_DOUT_READY && dout_expected) begin
                dout_expected <= 0; dout_latch <= DDRAM_DOUT;
            end else if (!dout_expected && !DDRAM_BUSY) begin
                if (!evolution_state || !evolution_history_valid || dout_latch != EVOLUTION_HISTORY_DESC)
                    evolution_snap[159:96] <= 0;
                if ((live_evolution || evolution_state) &&
                    (!evolution_state || !evolution_history_valid || dout_latch != EVOLUTION_HISTORY_DESC)) begin
                    state <= ST_ERROR;
                end else begin
                    ddram_read(base_addr + (has_restart ? 29'h02e : 29'h01f)); state <= has_restart ? ST_LOAD_SPRITE_DESC : ST_LOAD_EE_DESC;
                end
            end
        end
        ST_LOAD_EE_DESC: begin
            // Apply early: TH/HL must settle before the later F07 latch restore.
            gun_in <= gun_snap; gun_set <= 1;
            if (has_gun_tag) begin
                // The restored pulse also depends on input TH directions.
                // Settle only these two bits here; the ordinary full IO restore
                // below retains its existing place in the load sequence.
                io_in <= (io_out & ~32'h0000000a) | (io_snap & 32'h0000000a);
                io_set <= 1;
            end
            if (DDRAM_DOUT_READY && dout_expected) begin
                dout_expected <= 0; dout_latch <= DDRAM_DOUT;
            end else if (!dout_expected && !DDRAM_BUSY) begin
                if (eeprom_present && dout_latch == EEPROM_DESC) begin
                    eeprom_ext_word <= 0;
                    ddram_read(base_addr + 29'h030); state <= ST_LOAD_EE_EXT;
                end else begin
                    ddram_read(base_addr + 29'h01b); state <= ST_LOAD_EEPROM;
                end
            end
        end
        ST_LOAD_EE_EXT: begin
            if (DDRAM_DOUT_READY && dout_expected) begin
                dout_expected <= 0; dout_latch <= DDRAM_DOUT;
            end else if (!dout_expected && !DDRAM_BUSY) begin
                if (!eeprom_ext_word) begin
                    eeprom_ext_snap[63:0] <= dout_latch; eeprom_ext_word <= 1;
                    ddram_read(base_addr + 29'h031);
                end else begin
                    eeprom_ext_snap[127:64] <= dout_latch;
                    eeprom_full <= dout_latch[63:17] == 0 &&
                                   eeprom_ext_snap[3:0] <= 8 &&
                                   eeprom_ext_snap[33:29] <= 15 &&
                                   eeprom_ext_snap[51:50] <= 2;
                    ddram_read(base_addr + 29'h01b); state <= ST_LOAD_EEPROM;
                end
            end
        end

        ST_LOAD_EEPROM: begin
            if (DDRAM_DOUT_READY && dout_expected) begin
                dout_expected <= 0;
                dout_latch    <= DDRAM_DOUT;
            end else if (!dout_expected && !DDRAM_BUSY) begin
                if (dout_latch[17:11] != 0) eeprom_full <= 0;
                if (evolution_snap[31:16] == 16'hE132) begin
                    evolution_snap[95:32] <= dout_latch;
                    eeprom_snap <= 64'd0;
                end else begin
                    evolution_snap[95:32] <= 64'd0;
                    eeprom_snap <= dout_latch;
                end
                if (systeme) begin
                    // System E: read VDP2/CRAM2/PSG2 before restoring VRAM
                    ddram_read(base_addr + 29'h10);
                    cram_idx <= 0;
                    state    <= ST_LOAD_VDP2REG;
                end else begin
                    // Restore memory (VRAM/WRAM) BEFORE applying registers so the VDP never
                    // renders with new register settings against old VRAM content.
                    vram_load_addr   <= 0;
                    vram_byte_cnt    <= 0;
                    vram_load_active <= 0;
                    word_cnt         <= 0;
                    ddram_read(base_addr + 29'h101);
                    state <= ST_LOAD_VRAM;
                end
            end
        end

        ST_LOAD_VDP2REG: begin
            // Read 2 × 64-bit words for VDP2 regs
            if (DDRAM_DOUT_READY && dout_expected) begin
                dout_expected <= 0;
                dout_latch    <= DDRAM_DOUT;
            end else if (!dout_expected && !DDRAM_BUSY) begin
                case (cram_idx)
                    3'd0: begin
                        vdp2_snap[63:0] <= dout_latch;
                        cram_idx <= 3'd1;
                        ddram_read(base_addr + 29'h11);
                    end
                    3'd1: begin
                        vdp2_snap[127:64] <= dout_latch;
                        cram_idx <= 3'd0;
                        ddram_read(base_addr + 29'h12);
                        state <= ST_LOAD_CRAM2;
                    end
                    default: ;
                endcase
            end
        end

        ST_LOAD_CRAM2: begin
            // Read 6 × 64-bit words for CRAM2
            if (DDRAM_DOUT_READY && dout_expected) begin
                dout_expected <= 0;
                dout_latch    <= DDRAM_DOUT;
            end else if (!dout_expected && !DDRAM_BUSY) begin
                case (cram_idx)
                    3'd0: begin cram2_snap[ 63:  0] <= dout_latch; cram_idx <= 3'd1; ddram_read(base_addr + 29'h13); end
                    3'd1: begin cram2_snap[127: 64] <= dout_latch; cram_idx <= 3'd2; ddram_read(base_addr + 29'h14); end
                    3'd2: begin cram2_snap[191:128] <= dout_latch; cram_idx <= 3'd3; ddram_read(base_addr + 29'h15); end
                    3'd3: begin cram2_snap[255:192] <= dout_latch; cram_idx <= 3'd4; ddram_read(base_addr + 29'h16); end
                    3'd4: begin cram2_snap[319:256] <= dout_latch; cram_idx <= 3'd5; ddram_read(base_addr + 29'h17); end
                    3'd5: begin
                        cram2_snap[383:320] <= dout_latch;
                        cram_idx <= 3'd0;
                        ddram_read(base_addr + 29'h18);
                        state <= ST_LOAD_PSG2;
                    end
                    default: ;
                endcase
            end
        end

        ST_LOAD_PSG2: begin
            if (DDRAM_DOUT_READY && dout_expected) begin
                dout_expected <= 0;
                dout_latch    <= DDRAM_DOUT;
            end else if (!dout_expected && !DDRAM_BUSY) begin
                psg2_snap <= dout_latch[55:0];
                // Now restore VRAM1 to VDP1's active se_bank half
                vram_load_addr   <= {mapper_snap[7], 14'b0};
                vram_byte_cnt    <= 0;
                vram_load_active <= 0;
                word_cnt         <= 0;
                ddram_read(base_addr + 29'h101);
                state <= ST_LOAD_VRAM;
            end
        end

        ST_LOAD_VRAM, ST_LOAD_VRAM1_PASSIVE,
        ST_LOAD_VRAM2, ST_LOAD_VRAM2_PASSIVE: begin
            if (!vram_load_active) begin
                if (DDRAM_DOUT_READY && dout_expected) begin
                    dout_expected    <= 0;
                    dout_latch       <= DDRAM_DOUT;
                    vram_byte_cnt    <= 0;
                    vram_load_active <= 1;
                end
            end else begin
                if (vram_byte_cnt < 7) begin
                    vram_restore_byte(dout_latch[8*vram_byte_cnt +: 8]);
                    vram_load_addr <= vram_load_addr + 15'd1;
                    vram_byte_cnt  <= vram_byte_cnt + 3'd1;
                end else begin
                    if (!DDRAM_BUSY) begin
                        vram_restore_byte(dout_latch[8*7 +: 8]);
                        vram_load_addr   <= vram_load_addr + 15'd1;
                        vram_load_active <= 0;
                        vram_byte_cnt    <= 0;
                        if (word_cnt < 12'd2047) begin
                            word_cnt <= word_cnt + 12'd1;
                            ddram_read(base_addr + vram_ddr_offset + {17'd0, word_cnt + 12'd1});
                        end else begin
                            case (state)
                                ST_LOAD_VRAM: begin
                                    if (systeme) begin
                                        // System E: restore VDP1 passive bank from inline slot data.
                                        vram_load_addr   <= {~mapper_snap[7], 14'b0};
                                        vram_byte_cnt    <= 0;
                                        vram_load_active <= 0;
                                        word_cnt         <= 0;
                                        ddram_read(base_addr + 29'h1901);
                                        state <= ST_LOAD_VRAM1_PASSIVE;
                                    end else begin
                                        // VRAM done → WRAM
                                        wram_load_addr   <= 0;
                                        wram_byte_cnt    <= 0;
                                        wram_load_active <= 0;
                                        word_cnt         <= 0;
                                        ddram_read(base_addr + 29'h901);
                                        state <= ST_LOAD_WRAM;
                                    end
                                end
                                ST_LOAD_VRAM1_PASSIVE: begin
                                    wram_load_addr   <= 0;
                                    wram_byte_cnt    <= 0;
                                    wram_load_active <= 0;
                                    word_cnt         <= 0;
                                    ddram_read(base_addr + 29'h901);
                                    state <= ST_LOAD_WRAM;
                                end
                                ST_LOAD_VRAM2: begin
                                    // Restore VDP2 passive bank from inline slot area.
                                    vram_load_addr   <= {~mapper_snap[6], 14'b0};
                                    vram_byte_cnt    <= 0;
                                    vram_load_active <= 0;
                                    word_cnt         <= 0;
                                    ddram_read(base_addr + 29'h2101);
                                    state <= ST_LOAD_VRAM2_PASSIVE;
                                end
                                ST_LOAD_VRAM2_PASSIVE: begin
                                    state      <= ST_WAIT_RESTORE_BOUNDARY;
                                    cram_entry <= 0;
                                end
                            endcase
                        end
                    end
                end
            end
        end

        ST_LOAD_WRAM: begin
            if (!wram_load_active) begin
                if (DDRAM_DOUT_READY && dout_expected) begin
                    dout_expected    <= 0;
                    dout_latch       <= DDRAM_DOUT;
                    wram_byte_cnt    <= 0;
                    wram_load_active <= 1;
                end
            end else begin
                if (wram_byte_cnt < 7) begin
                    wram_WE         <= 1;
                    wram_WA         <= wram_load_addr;
                    wram_WD         <= dout_latch[8*wram_byte_cnt +: 8];
                    wram_load_addr  <= wram_load_addr + 14'd1;
                    wram_byte_cnt   <= wram_byte_cnt + 3'd1;
                end else begin // wram_byte_cnt == 7
                    if (!DDRAM_BUSY) begin
                        wram_WE         <= 1;
                        wram_WA         <= wram_load_addr;
                        wram_WD         <= dout_latch[8*7 +: 8];
                        wram_load_addr  <= wram_load_addr + 14'd1;
                        wram_load_active <= 0;
                        wram_byte_cnt   <= 0;
                        if (word_cnt < (systeme ? 12'd2047 : 12'd1023)) begin
                            word_cnt <= word_cnt + 12'd1;
                            ddram_read(base_addr + 29'h901 + {17'd0, word_cnt + 12'd1});
                        end else begin
                            if (systeme) begin
                                // System E: restore VRAM2 to VDP2's active se_bank half
                                vram_load_addr   <= {mapper_snap[6], 14'b0};
                                vram_byte_cnt    <= 0;
                                vram_load_active <= 0;
                                word_cnt         <= 0;
                                ddram_read(base_addr + 29'h1101);
                                state <= ST_LOAD_VRAM2;
                            end else begin
                                // WRAM done, transition to mapper restore first
                                state      <= ST_WAIT_RESTORE_BOUNDARY;
                                cram_entry <= 0;
                            end
                        end
                    end
                end
            end
        end

        ST_LOAD_NVRAM: begin
            if (!nvram_load_active) begin
                if (DDRAM_DOUT_READY && dout_expected) begin
                    dout_expected     <= 0;
                    dout_latch        <= DDRAM_DOUT;
                    nvram_byte_cnt    <= 0;
                    nvram_load_active <= 1;
                end
            end else begin
                if (nvram_byte_cnt < 7) begin
                    nvram_WE        <= 1;
                    nvram_WA        <= nvram_load_addr;
                    nvram_WD        <= dout_latch[8*nvram_byte_cnt +: 8];
                    nvram_load_addr <= nvram_load_addr + 15'd1;
                    nvram_byte_cnt  <= nvram_byte_cnt + 3'd1;
                end else begin // nvram_byte_cnt == 7
                    if (!DDRAM_BUSY) begin
                        nvram_WE        <= 1;
                        nvram_WA        <= nvram_load_addr;
                        nvram_WD        <= dout_latch[8*7 +: 8];
                        nvram_load_addr <= nvram_load_addr + 15'd1;
                        nvram_load_active <= 0;
                        nvram_byte_cnt  <= 0;
                        if (word_cnt < (nvram_size_minus_1 >> 3)) begin
                            word_cnt <= word_cnt + 12'd1;
                            ddram_read(base_addr + nvram_ddr_base + {17'd0, word_cnt + 12'd1});
                        end else begin
                            state      <= ST_LOAD_RESTORE;
                            cram_entry <= 0;
                        end
                    end
                end
            end
        end




        // ---------------------------------------------------------------
        ST_LOAD_RESTORE: begin
            // VRAM/WRAM and mapper are fully restored. Apply CPU+VDP+PSG state,
            // then stream CRAM while remaining frozen.
            if (cram_entry == 0) begin
                // CPU is frozen; restore all registers unconditionally.
                // z80_set loads z80_dir into T80s regardless of CEN.
                gg_in <= gg_snap;
                gg_set <= 1; // Includes legacy64K, which intentionally skips ordinary IO restore.
                z80_dir      <= z80_snap;
                z80_set      <= 1;
                vdp_regs_in  <= vdp_snap;
                vdp_regs_set <= 1;
                psg_in       <= psg_snap;
                psg_set      <= 1;
                if (has_audio_ext) begin
                    psg_ext_in <= psg_ext_snap;
                    psg2_ext_in <= psg2_ext_snap;
                    psg_div_in <= audio_div_snap;
                    audio_control_in <= audio_control_snap;
                    audio_ext_set <= 1;
                end
                if (!is_old_format) begin
                    io_in        <= io_snap;
                    io_set       <= 1;
                    video_state_in  <= video_snap;
                    video_state_set <= 1;
                end
                // System E: restore second VDP/PSG
                if (systeme) begin
                    vdp2_regs_in  <= vdp2_snap;
                    vdp2_regs_set <= 1;
                    psg2_in       <= psg2_snap;
                    psg2_set      <= 1;
                end
            end
            // Write CRAM entries one per cycle (32 cycles total)
            cram_wr <= 1;
            cram_A  <= cram_entry;
            cram_D  <= cram_snap[12*cram_entry +: 12];
            // Write CRAM2 in parallel when System E
            if (systeme) begin
                cram2_wr <= 1;
                cram2_A  <= cram_entry;
                cram2_D  <= cram2_snap[12*cram_entry +: 12];
            end
            if (cram_entry == 31) begin
                flush_cnt <= 20'd0;
                state     <= ST_FLUSH_PIPELINE;
            end else
                cram_entry <= cram_entry + 5'd1;
        end

        ST_FLUSH_PIPELINE: begin
            if (flush_cnt == FLUSH_MAX) begin
                state <= ST_PRE_UNFREEZE;
            end else begin
                flush_cnt <= flush_cnt + 20'd1;
            end
        end

        ST_PRE_UNFREEZE: begin
            // Refill shared synchronous RAM from the restored engine address.
            nvram_refill <= eeprom_present;
            sc_ram_restored <= !do_save && sc_ram_full;
            if (!do_save) begin
                eeprom_in <= eeprom_snap; eeprom_ext_in <= eeprom_ext_snap;
                eeprom_set <= 1;
            end
            // IO TH has settled during the full restore/flush. Legacy history
            // is reconstructed here; exact v3 history remains held until release.
            if (!do_save) begin md_in <= md_snap; md_set <= 1; end
            if (!do_save) begin
                paddle_in <= paddle_snap; paddle_set <= 1;
                tap_in <= tap_snap; tap_set <= 1;
            end
            unfreeze_cnt <= 8'd0;
            state <= ST_UNFREEZE;
        end

        // ---------------------------------------------------------------
        ST_UNFREEZE: begin
            if (unfreeze_cnt<8'd255) unfreeze_cnt<=unfreeze_cnt+8'd1;
            else begin
                z80_nmi_hold<=0;
                ss_cpu_prepare<=!do_save;
                state<=ST_CPU_PREPARE;
            end
        end
        ST_CPU_PREPARE: begin
            // Replay-complete is semantic: no ordinary instruction may execute.
            if (do_save || !z80_replay) begin
                ss_cpu_prepare<=0;
                clock_phase_set<=1;
                video_state_in<=video_snap;video_state_set<=1;
                state<=ST_PHASE_COMMIT;
            end
        end
        ST_PHASE_COMMIT: begin
            // The falling-edge divider acknowledges phase installation with
            // all enables zero. This edge installs the post-T beam and releases.
            video_state_in<=video_snap;video_state_set<=1;
            if (clock_phase_ready) begin
                clock_phase_set<=0;video_state_set<=0;ss_freeze<=0;unfreeze_cnt<=0;
                if (!do_save && has_audio_ext) begin
                    audio_phase_in<=audio_phase_snap;audio_phase_set<=1;
                end
                state<=ST_UNFREEZE_SETTLE;
            end
        end

        ST_UNFREEZE_SETTLE: begin
            ss_freeze <= 0;
            z80_nmi_hold <= 0;
            if (unfreeze_cnt == 8'd4) begin
                op_cooldown <= OP_COOLDOWN_MAX;
                state       <= ST_IDLE;
            end else begin
                unfreeze_cnt <= unfreeze_cnt + 8'd1;
            end
        end
        // ---------------------------------------------------------------
        ST_ERROR: begin
            ss_cpu_prepare <= 0; clock_phase_set <= 0;
            // Handle load error - unfreeze and return to idle
            ss_freeze <= 0;
            z80_nmi_hold <= 0;
            state <= ST_IDLE;
        end
        default: state <= ST_IDLE;
        endcase
        end // ddram_step

        // The existing FSM helpers execute only on acceptance. Transport owns
        // the registered request throughout the wait and clears it exactly once.
        if (ddram_pending) begin
            DDRAM_RD <= DDRAM_BUSY && DDRAM_RD;
            DDRAM_WE <= DDRAM_BUSY && DDRAM_WE;
            DDRAM_ADDR <= DDRAM_ADDR;
            DDRAM_DIN <= DDRAM_DIN;
            DDRAM_BE <= DDRAM_BE;
            DDRAM_BURSTCNT <= DDRAM_BURSTCNT;
        end else if (ddram_cmd_rd || ddram_cmd_we) begin
            DDRAM_RD <= ddram_cmd_rd; DDRAM_WE <= ddram_cmd_we;
            DDRAM_ADDR <= ddram_cmd_addr; DDRAM_DIN <= ddram_cmd_data;
            DDRAM_BE <= ddram_cmd_be; DDRAM_BURSTCNT <= 8'd1;
            // Synchronous RAM lookahead may change byte 7 while acceptance waits.
            // Preserve the byte already captured in the registered write request.
            if (ddram_cmd_we && vram_byte_cnt == 7 &&
                (state==ST_SAVE_VRAM || state==ST_SAVE_VRAM1_PASSIVE ||
                 state==ST_SAVE_VRAM2 || state==ST_SAVE_VRAM2_PASSIVE)) begin
                vram_d_latch <= ddram_cmd_data[63:56]; vram_d_latched <= 1;
            end
            if (ddram_cmd_we && state==ST_SAVE_WRAM && wram_byte_cnt==7) begin
                wram_d_latch <= ddram_cmd_data[63:56]; wram_d_latched <= 1;
            end
            if (ddram_cmd_we && state==ST_SAVE_NVRAM && nvram_byte_cnt==7) begin
                nvram_d_latch <= ddram_cmd_data[63:56]; nvram_d_latched <= 1;
            end
        end
    end
end

endmodule
