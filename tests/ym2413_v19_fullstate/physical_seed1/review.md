# YM2413 full-state Seed 1 physical baseline

**NO-GO for timing-qualified manual hardware validation (Seed 1)**

Both fresh Seed 1 builds completed mapping, fitting, assembly and timing analysis. The candidate RBF was generated, but setup timing fails: -0.173 ns worst slack and -3.970 ns TNS, compared with +0.456 ns / 0 TNS for matched master. Preserve this as an experimental timing-failing measurement, not a qualified hardware baseline.

## Matched identity and scope

Fresh baseline: upstream master `66f16d5c656fd8906d62570da4d258875bcee684`. Candidate: the reviewed uncommitted
`experiment/ym2413-v19-fullstate` full-state port, with FM reference `7fcd5e12847eedf9e97a44dc937c3dbac3205f7c`.
Both use Quartus Prime Lite 17.0.2 Build 602, Cyclone V `5CSEBA6U23I7`, project/revision
SMS, top sys_top, MISTER_FB=1, Seed 1 and common BUILD_DATE 261104.
QSF, constraints, shared sys files, IP and optimization settings match. The sole
configuration-source difference is the approved files.qip addition of opll_snapshot.sv.
The pinned mist/mist-modules dependency is recorded in inputs.json.

The build trees are independent fresh copies in baseline/ and candidate/. No existing
database or output was reused. Explicit map/fit/asm/sta stages preserve the project
settings and use identical standard generated build-date/CDF metadata. A temporary
free Z: alias provided short build paths and was removed afterward. The pre-existing
idle TimeQuest process was not interrupted.

All 104 private words, descriptor version 17, handshakes, initialization, pending writes
and refill latency remain unchanged. No RTL edits, state removal, tuning, retries,
additional seeds, commits, merges, PRs or hardware deployment were performed.

## Fitted resource and timing comparison

Delta is candidate minus matched master. Needed ALMs = placed [A] - recoverable [B] + unavailable [C].
Logic/routing ALUTs are not additional ALMs. Register counts include
the fitter's physical optimization effects. Memory bits are logical bits, distinct
from allocated M10K capacity.

| Metric | Master Seed 1 | Full-state Seed 1 | Delta |
|---|---:|---:|---:|
| Needed ALMs (logic utilization) | 26,416 | 27,438 | +1,022 |
| Placed ALMs [A] | 31,445 | 32,465 | +1,020 |
| Recoverable ALMs [B] | 5,380 | 5,409 | +29 |
| Unavailable ALMs [C] | 351 | 382 | +31 |
| Logic ALUTs | 36,960 | 38,344 | +1,384 |
| Routing ALUTs | 13,040 | 13,087 | +47 |
| Mapped registers | 34,461 | 34,942 | +481 |
| Fitted total registers | 35,435 | 36,049 | +614 |
| M10K blocks | 488 | 489 | +1 |
| Logical block-memory bits | 3,810,182 | 3,818,374 | +8,192 |
| MLAB cells | 0 | 0 | 0 |
| MLAB bits | 0 | 0 | 0 |
| ALMs for memory | 0 | 0 | 0 |
| DSP blocks | 39 | 39 | 0 |
| Worst setup slack (ns) | 0.456 | -0.173 | -0.629 |
| Setup TNS, worst clock group (ns) | 0 | -3.97 | -3.97 |
| Worst hold slack (ns) | 0.243 | 0.168 | -0.075 |
| Hold TNS, worst clock group (ns) | 0 | 0 | 0 |

Routing utilization (total / horizontal / vertical):

- Average: master 29.4 / 29.7 / 28.4%; candidate 31.2 / 31.1 / 31.6%.
- Peak: master 51.2 / 51.8 / 51.2%; candidate 48.6 / 50.3 / 62.1%.

The new violation is confined to the HDMI clock setup group. The worst candidate path is HDMI shadowmask RAM ram_block5a0 to hdmi_osd h_cnt[16]~DUPLICATE, with 5.932 ns data delay and -0.773 ns skew. Master worst path was ascal o_vcpt_pre3[1] to o_vcpt_pre3[7], +0.456 ns. The core/emu group remains positive (+1.109 ns master, +1.183 ns candidate); queried FM paths remain positive (worst FM-to +2.261 ns). Hold passes (+0.168 ns candidate, zero TNS). Added FM logic changes whole-design placement/routing; one seed does not establish the exact cause of a violation in unchanged HDMI logic. No tuning or second build was performed. Both builds have identical inherited constraint gaps: 27 unconstrained input ports / 94 paths and 91 output ports / 153 paths, for setup and hold; zero illegal or unconstrained clocks.

## Source inclusion and memory inference

Quartus source tables and frozen hashes verify the source actually compiled. The
candidate audit covers 67 core assignments and all
23 reviewed HDL files, including rtl/opll_snapshot.sv;
those reviewed HDL files are reported used in the netlist. No simulation adapters
are present. Expanded settings and actual fitter settings are retained.

PhaseMemory retains AUTO simple-dual-port single-clock 18 x 18 storage (324 logical bits), one M10K, zero MLABs, registered inputs, unregistered outputs, and identical read-during-write settings. No RAM inference regression occurred. Its local control logic increases from 14.5 to 24.9 needed ALMs (14.8 to 28.3 placed ALMs; 30 to 48 combinational ALUTs), while its seven dedicated logic registers remain unchanged. The global additional M10K and 8192 logical bits are exactly the 256 x 32 snapshot scratch RAM. Existing voice/envelope RAM allocation remains unchanged.

Fitted FM memories (global total above includes all other core memories):

| Build | Memory | Type / mode | Logical size | M10Ks | MLABs | Read-during-write mode |
|---|---|---|---:|---:|---:|---|
| Master | PhaseGenerator:pg / PhaseMemory:MEM / altsyncram:phase_array_rtl_0 / altsyncram_a0q1:auto_generated / ALTSYNCRAM | AUTO / Simple Dual Port | 324 | 1 | 0 | Old data |
| Master | controller:ct / VoiceMemory:vmem / altsyncram:voices_rtl_0 / altsyncram_g0q1:auto_generated / ALTSYNCRAM | AUTO / Simple Dual Port | 1368 | 1 | 0 | Old data |
| Master | controller:ct / VoiceMemory:vmem / altsyncram:voices_rtl_1 / altsyncram_g0q1:auto_generated / ALTSYNCRAM | AUTO / Simple Dual Port | 1368 | 1 | 0 | Old data |
| Master | envelopegenerator:eg / EnvelopeMemory:u_envelope_memory / altsyncram:egdata_set_rtl_0 / altsyncram_60q1:auto_generated / ALTSYNCRAM | AUTO / Simple Dual Port | 450 | 1 | 0 | Old data |
| Full-state | altsyncram:memory_rtl_0 / altsyncram_p3p1:auto_generated / ALTSYNCRAM | M10K block / Simple Dual Port | 8192 | 1 | 0 | Old data |
| Full-state | PhaseGenerator:pg / PhaseMemory:MEM / altsyncram:phase_array_rtl_0 / altsyncram_a0q1:auto_generated / ALTSYNCRAM | AUTO / Simple Dual Port | 324 | 1 | 0 | Old data |
| Full-state | controller:ct / VoiceMemory:vmem / altsyncram:voices_rtl_0 / altsyncram_g0q1:auto_generated / ALTSYNCRAM | AUTO / Simple Dual Port | 1368 | 1 | 0 | Old data |
| Full-state | controller:ct / VoiceMemory:vmem / altsyncram:voices_rtl_1 / altsyncram_g0q1:auto_generated / ALTSYNCRAM | AUTO / Simple Dual Port | 1368 | 1 | 0 | Old data |
| Full-state | envelopegenerator:eg / EnvelopeMemory:u_envelope_memory / altsyncram:egdata_set_rtl_0 / altsyncram_60q1:auto_generated / ALTSYNCRAM | AUTO / Simple Dual Port | 450 | 1 | 0 | Old data |

## Critical timing paths

### Master

- Setup 0.456 ns: `ascal:ascal|o_vcpt_pre3[1]` → `ascal:ascal|o_vcpt_pre3[7]`; launch `pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk`, latch `pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk`; data delay 5.982, skew -0.094.
- Setup 0.456 ns: `ascal:ascal|o_vcpt_pre3[1]` → `ascal:ascal|o_vcpt_pre3[6]`; launch `pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk`, latch `pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk`; data delay 5.982, skew -0.094.
- Setup 0.456 ns: `ascal:ascal|o_vcpt_pre3[1]` → `ascal:ascal|o_vcpt_pre3[0]`; launch `pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk`, latch `pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk`; data delay 5.982, skew -0.094.
- fm_from: 4.977 ns, `emu:emu|system:system|opll:fm|controller:ct|ml[1]` → `emu:emu|system:system|opll:fm|PhaseGenerator:pg|memin[16]`.
- fm_to: 2.335 ns, `emu:emu|ce_cpu` → `emu:emu|system:system|opll:fm|controller:ct|user_voice_wdata.ML[0]`.
- phase_from: 11.844 ns, `emu:emu|system:system|opll:fm|PhaseGenerator:pg|PhaseMemory:MEM|altsyncram:phase_array_rtl_0|altsyncram_a0q1:auto_generated|ram_block1a0~PORT_B_WRITE_ENABLE_REG` → `emu:emu|system:system|opll:fm|PhaseGenerator:pg|noise14`.
- phase_to: 7.344 ns, `emu:emu|system:system|mapper_detect:mapper_detect_inst|rom_crc32[0]` → `emu:emu|system:system|opll:fm|PhaseGenerator:pg|PhaseMemory:MEM|altsyncram:phase_array_rtl_0|altsyncram_a0q1:auto_generated|ram_block1a0~porta_we_reg`.
### Full-state

- Setup -0.173 ns: `shadowmask:HDMI_shadowmask|altshift_taps:vid_rtl_0|shift_taps_0vu:auto_generated|altsyncram_pr91:altsyncram4|ram_block5a0` → `osd:hdmi_osd|h_cnt[16]~DUPLICATE`; launch `pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk`, latch `pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk`; data delay 5.932, skew -0.773.
- Setup -0.173 ns: `shadowmask:HDMI_shadowmask|altshift_taps:vid_rtl_0|shift_taps_0vu:auto_generated|altsyncram_pr91:altsyncram4|ram_block5a0` → `osd:hdmi_osd|h_cnt[15]~DUPLICATE`; launch `pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk`, latch `pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk`; data delay 5.930, skew -0.775.
- Setup -0.173 ns: `shadowmask:HDMI_shadowmask|altshift_taps:vid_rtl_0|shift_taps_0vu:auto_generated|altsyncram_pr91:altsyncram4|ram_block5a0` → `osd:hdmi_osd|h_cnt[14]~DUPLICATE`; launch `pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk`, latch `pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk`; data delay 5.932, skew -0.773.
- fm_from: 4.225 ns, `emu:emu|system:system|opll:fm|controller:ct|ml[0]` → `emu:emu|system:system|opll:fm|PhaseGenerator:pg|memin[11]`.
- fm_to: 2.261 ns, `emu:emu|ce_cpu~DUPLICATE` → `emu:emu|system:system|opll:fm|controller:ct|am`.
- phase_from: 8.755 ns, `emu:emu|system:system|opll:fm|PhaseGenerator:pg|PhaseMemory:MEM|ss_mem_ready` → `emu:emu|savestates:savestates_inst|z80_snap[48]`.
- phase_to: 8.168 ns, `emu:emu|savestates:savestates_inst|opll_snapshot:fm_snapshot|state.AP_WRITE~DUPLICATE` → `emu:emu|system:system|opll:fm|PhaseGenerator:pg|PhaseMemory:MEM|altsyncram:phase_array_rtl_0|altsyncram_a0q1:auto_generated|ram_block1a0~porta_we_reg`.
- snapshot_from: 4.504 ns, `emu:emu|savestates:savestates_inst|opll_snapshot:fm_snapshot|index[7]` → `emu:emu|system:system|opll:fm|envelopegenerator:eg|memin.phase[19]`.
- snapshot_to: 6.181 ns, `emu:emu|savestates:savestates_inst|ss_freeze` → `emu:emu|savestates:savestates_inst|opll_snapshot:fm_snapshot|altsyncram:memory_rtl_0|altsyncram_p3p1:auto_generated|ram_block1a0~porta_datain_reg13`.

Full paths, routing detail, ignored constraints and unconstrained-path reports are
in each build directory as physical_*.rpt. The extra queries do not alter the native
fit/STA reports; their hashes are checked. Native STA summaries remain the acceptance
metrics. Per-clock and other timing checks are retained in results.json.

## Warning review

Map emits 65 warnings on master and 69 on candidate; both have 38 synthesis critical warnings. The four added synthesis warning occurrences are unused ss_v_ff_count temporaries in slotcounter.vhd instances (Warning 10036). The other added normalized diagnostic is final STA Critical Warning 332148, timing requirements not met. No inferred-latch, multiple-driver or width-mismatch diagnostics were found. Inherited power-up, ignored-assignment and constraint warnings are retained in warnings.md. Actual fitter settings match exactly, including Seed 1. Expanded global settings differ only by the approved rtl/opll_snapshot.sv assignment. All 23 reviewed production HDL sources, including the snapshot, are reported used in the actual compilation. Existing uninstantiated T80pa.vhd and compressor.sv declarations have parser evidence but are absent from the netlist-used source table.

Unresolved: HDMI setup timing failure prevents recommending this RBF for timing-qualified manual hardware validation. No functional claim is made from successful assembly or the earlier simulation review. Timing closure requires a separately authorized follow-up; manual MiSTer validation of musical continuity and SAVE/LOAD remains outstanding. No RTL changes or further physical builds were undertaken.

All raw warnings, normalized added/removed warnings, latch/driver/width categories
and source locations are retained in results.json and warnings.md. Inherited
constraint gaps are reported explicitly; a successful tool exit alone is not timing
qualification or hardware validation.

## Experimental binaries and source provenance

Candidate: [SMS_YM2413_FULLSTATE_104W_v17_66f16d5c_DIRTY_src601fe4306448_Q17.0.2_seed1_TIMING_FAIL_rbf426af7037b9f.rbf](artifacts/SMS_YM2413_FULLSTATE_104W_v17_66f16d5c_DIRTY_src601fe4306448_Q17.0.2_seed1_TIMING_FAIL_rbf426af7037b9f.rbf)

- RBF SHA-256: `426af7037b9f0e24de93ca4291e81bf142bf785fdbf924abcdae0dc4627455cc`
- Bytes: 4154324
- Exact source-tree identity: `601fe43064489cfb6072798110d98a341d66ca94a2f01615459f13fa707c5a4d`
- Complete uncommitted patch SHA-256: `58146692a8b7dcb61e858d0234499c59c4f5b9c7450675bab8111418844d5154`
- Source revision: `66f16d5c656fd8906d62570da4d258875bcee684` plus the complete reviewed patch and pinned dependency;
  the uncommitted candidate is not represented as a new Git commit.

The matched master RBF is also preserved under artifacts/. artifact_identity.json,
inputs.json, candidate.diff, workflow.log and results.json bind binaries, actual
inputs, tools and reports. These RBFs are experimental and have not been tested
on a MiSTer. Manual validation must establish real FM SAVE/LOAD correctness and
musical continuity; compilation and timing do not establish that functionality.

## Reproduction

Use a new empty artifact directory and the retained prepare.js/build.ps1 workflow;
the scripts refuse existing build attempts. No retry or optimization is part of
this measurement. query.ps1 performs additional read-only timing/settings queries;
collect.js, preserve.js and report.js retain source-bound evidence and binaries.
