# Full-state YM2413 matched three-seed study

Fresh seeds 2 and 3 use the exact frozen Seed 1 source inputs and compilation stages. Only the QSF seed differs. Baseline is upstream master `66f16d5c656fd8906d62570da4d258875bcee684`; candidate is its reviewed uncommitted 104-word/version-17 port. Quartus Prime Lite 17.0.2 Build 602, Cyclone V 5CSEBA6U23I7. No RTL, test, shared sys or existing worktree files were edited. No retries, additional seeds, commits, merges or PRs.

| Seed | Build | Needed ALMs | Placed ALMs | Fitted registers | M10Ks | Setup WNS (ns) | Setup TNS (ns) | Hold WNS (ns) |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| 1 | baseline | 26416 | 31445 | 35435 | 488 | 0.456 | 0 | 0.243 |
| 1 | candidate | 27438 | 32465 | 36049 | 489 | -0.173 | -3.97 | 0.168 |
| 2 | baseline | 26371 | 31382 | 35339 | 488 | 0.673 | 0 | 0.203 |
| 2 | candidate | 27421 | 32490 | 36112 | 489 | 0.367 | 0 | 0.244 |
| 3 | baseline | 26465 | 31471 | 35326 | 488 | 0.319 | 0 | 0.241 |
| 3 | candidate | 27445 | 32453 | 36044 | 489 | 0.002 | 0 | 0.17 |

## Assessment and recommendation

Recommend the preserved Seed 2 candidate for manual MiSTer validation: setup +0.367 ns, hold +0.244 ns, no reported constrained timing violations. Seed 3 also passes, but its +0.002 ns setup margin is only 2 ps and offers little margin. Hardware FM functionality remains untested. Seed 1 remains timing-failing and is not recommended.

Master passes all three seeds; candidate passes two of three. Candidate minus master WNS is -0.629, -0.306 and -0.317 ns (mean -0.417 ns). Candidate WNS spans -0.173 to +0.367 ns. The timing failure is placement-sensitive, while a lower timing margin is consistent across all matched pairs. Three seeds do not establish statistical robustness or isolate the cause of the whole-fit placement/routing change. Do not treat the result as evidence that the resource overhead has no timing cost.

All candidate worst paths remain in HDMI. Seed 1: shadowmask RAM to OSD h_cnt; Seed 2: scaler o_v_poly_t.r1 to o_v_poly_pix.r; Seed 3: shadowmask RAM to OSD dsp_width. Thus the exact Seed 1 worst endpoint does not recur as the worst endpoint, but the shadowmask-to-OSD path family recurs in Seed 3. Targeted shadowmask-to-h_cnt checks are recorded below. All FM/PhaseMemory/snapshot queries are positive; the worst FM-to slack is +2.261, +1.917 and +2.431 ns for seeds 1, 2 and 3. Core clock setup slack is +1.183, +0.719 and +1.361 ns. Hold timing passes in all runs.

The measured candidate overhead is +980 to +1050 needed ALMs, +982 to +1108 placed ALMs, +614 to +773 fitted registers, and exactly one M10K across seeds. Mapped-register overhead stays +481; physical-register variation reflects fitter optimization. PhaseMemory remains AUTO 18 x 18 simple-dual-port single-clock storage in one M10K, zero MLABs, with unchanged register/read-during-write settings. The additional memory is the 256 x 32 snapshot scratch RAM.

Actual fitter settings match within every pair, including the requested seed; expanded assignments differ only by the approved snapshot source. The reviewed production HDL is compiled, including rtl/opll_snapshot.sv. Seeds 2 and 3 add only the inherited full-state unused ss_v_ff_count warning relative to master, with no latch/multiple-driver/width diagnostics. Native reports stayed unchanged after read-only queries. Both builds retain the same external-I/O constraint gaps: 27 input ports/94 paths and 91 output ports/153 paths for setup and hold; no unconstrained clocks. Timing qualification is limited to existing project constraints.

- Seed 2 baseline, targeted shadowmask-to-OSD h_cnt: 1.289 ns; [full path](../physical_seed2/baseline/physical_shadowmask_osd.rpt).
- Seed 2 candidate, targeted shadowmask-to-OSD h_cnt: 2.101 ns; [full path](../physical_seed2/candidate/physical_shadowmask_osd.rpt).
- Seed 3 baseline, targeted shadowmask-to-OSD h_cnt: 1.758 ns; [full path](../physical_seed3/baseline/physical_shadowmask_osd.rpt).
- Seed 3 candidate, targeted shadowmask-to-OSD h_cnt: 0.124 ns; [full path](../physical_seed3/candidate/physical_shadowmask_osd.rpt).

## Critical paths and FM checks

### Seed 1: baseline

- setup: 0.456 ns; `ascal:ascal|o_vcpt_pre3[1]` to `ascal:ascal|o_vcpt_pre3[7]`.
- fm_from: 4.977 ns; `emu:emu|system:system|opll:fm|controller:ct|ml[1]` to `emu:emu|system:system|opll:fm|PhaseGenerator:pg|memin[16]`.
- fm_to: 2.335 ns; `emu:emu|ce_cpu` to `emu:emu|system:system|opll:fm|controller:ct|user_voice_wdata.ML[0]`.
- phase_from: 11.844 ns; `emu:emu|system:system|opll:fm|PhaseGenerator:pg|PhaseMemory:MEM|altsyncram:phase_array_rtl_0|altsyncram_a0q1:auto_generated|ram_block1a0~PORT_B_WRITE_ENABLE_REG` to `emu:emu|system:system|opll:fm|PhaseGenerator:pg|noise14`.
- phase_to: 7.344 ns; `emu:emu|system:system|mapper_detect:mapper_detect_inst|rom_crc32[0]` to `emu:emu|system:system|opll:fm|PhaseGenerator:pg|PhaseMemory:MEM|altsyncram:phase_array_rtl_0|altsyncram_a0q1:auto_generated|ram_block1a0~porta_we_reg`.

Violating groups: [].

### Seed 1: candidate

- setup: -0.173 ns; `shadowmask:HDMI_shadowmask|altshift_taps:vid_rtl_0|shift_taps_0vu:auto_generated|altsyncram_pr91:altsyncram4|ram_block5a0` to `osd:hdmi_osd|h_cnt[16]~DUPLICATE`.
- fm_from: 4.225 ns; `emu:emu|system:system|opll:fm|controller:ct|ml[0]` to `emu:emu|system:system|opll:fm|PhaseGenerator:pg|memin[11]`.
- fm_to: 2.261 ns; `emu:emu|ce_cpu~DUPLICATE` to `emu:emu|system:system|opll:fm|controller:ct|am`.
- phase_from: 8.755 ns; `emu:emu|system:system|opll:fm|PhaseGenerator:pg|PhaseMemory:MEM|ss_mem_ready` to `emu:emu|savestates:savestates_inst|z80_snap[48]`.
- phase_to: 8.168 ns; `emu:emu|savestates:savestates_inst|opll_snapshot:fm_snapshot|state.AP_WRITE~DUPLICATE` to `emu:emu|system:system|opll:fm|PhaseGenerator:pg|PhaseMemory:MEM|altsyncram:phase_array_rtl_0|altsyncram_a0q1:auto_generated|ram_block1a0~porta_we_reg`.
- snapshot_from: 4.504 ns; `emu:emu|savestates:savestates_inst|opll_snapshot:fm_snapshot|index[7]` to `emu:emu|system:system|opll:fm|envelopegenerator:eg|memin.phase[19]`.
- snapshot_to: 6.181 ns; `emu:emu|savestates:savestates_inst|ss_freeze` to `emu:emu|savestates:savestates_inst|opll_snapshot:fm_snapshot|altsyncram:memory_rtl_0|altsyncram_p3p1:auto_generated|ram_block1a0~porta_datain_reg13`.

Violating groups: [{"type":"Setup 'pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk'","slack":-0.173,"tns":-3.97}].

### Seed 2: baseline

- setup: 0.673 ns; `ascal:ascal|o_hcpt[3]` to `ascal:ascal|o_vcpt_sync[10]`.
- fm_from: 5.451 ns; `emu:emu|system:system|opll:fm|controller:ct|ml[1]` to `emu:emu|system:system|opll:fm|PhaseGenerator:pg|memin[16]`.
- fm_to: 2.927 ns; `emu:emu|ce_cpu` to `emu:emu|system:system|opll:fm|Operator:op|opout[13]`.
- phase_from: 12.417 ns; `emu:emu|system:system|opll:fm|PhaseGenerator:pg|PhaseMemory:MEM|altsyncram:phase_array_rtl_0|altsyncram_a0q1:auto_generated|ram_block1a0~PORT_B_WRITE_ENABLE_REG` to `emu:emu|system:system|opll:fm|PhaseGenerator:pg|memin[16]`.
- phase_to: 8.969 ns; `emu:emu|hps_io:hps_io|ioctl_index[4]` to `emu:emu|system:system|opll:fm|PhaseGenerator:pg|PhaseMemory:MEM|altsyncram:phase_array_rtl_0|altsyncram_a0q1:auto_generated|ram_block1a0~porta_we_reg`.

Violating groups: [].

### Seed 2: candidate

- setup: 0.367 ns; `ascal:ascal|o_v_poly_t.r1[25]` to `ascal:ascal|o_v_poly_pix.r[7]`.
- fm_from: 4.391 ns; `emu:emu|system:system|opll:fm|controller:ct|VoiceMemory:vmem|ss_mem_ready` to `emu:emu|savestates:savestates_inst|state.ST_SAVE_VRAM`.
- fm_to: 1.917 ns; `emu:emu|ce_cpu~DUPLICATE` to `emu:emu|system:system|opll:fm|controller:ct|inst_cache[3][3]`.
- phase_from: 6.187 ns; `emu:emu|system:system|opll:fm|PhaseGenerator:pg|PhaseMemory:MEM|ss_mem_ready` to `emu:emu|savestates:savestates_inst|state.ST_SAVE_VRAM`.
- phase_to: 7.621 ns; `emu:emu|hps_io:hps_io|joystick_1[4]~DUPLICATE` to `emu:emu|system:system|opll:fm|PhaseGenerator:pg|PhaseMemory:MEM|altsyncram:phase_array_rtl_0|altsyncram_a0q1:auto_generated|ram_block1a0~porta_we_reg`.
- snapshot_from: 3.635 ns; `emu:emu|savestates:savestates_inst|opll_snapshot:fm_snapshot|index[3]` to `emu:emu|system:system|opll:fm|envelopegenerator:eg|memin.state[0]`.
- snapshot_to: 4.16 ns; `emu:emu|savestates:savestates_inst|ss_freeze` to `emu:emu|savestates:savestates_inst|opll_snapshot:fm_snapshot|altsyncram:memory_rtl_0|altsyncram_p3p1:auto_generated|ram_block1a0~porta_datain_reg16`.

Violating groups: [].

### Seed 3: baseline

- setup: 0.319 ns; `ascal:ascal|altsyncram:o_line1[0].r[7]__3|altsyncram_ccn1:auto_generated|ram_block1a0~PORT_B_WRITE_ENABLE_REG` to `ascal:ascal|o_vpix_inner[0].r[4]`.
- fm_from: 5.12 ns; `emu:emu|system:system|opll:fm|controller:ct|ml[0]` to `emu:emu|system:system|opll:fm|PhaseGenerator:pg|memin[16]`.
- fm_to: 2.083 ns; `emu:emu|ce_cpu~DUPLICATE` to `emu:emu|system:system|opll:fm|Operator:op|addr[13]`.
- phase_from: 12.763 ns; `emu:emu|system:system|opll:fm|PhaseGenerator:pg|PhaseMemory:MEM|altsyncram:phase_array_rtl_0|altsyncram_a0q1:auto_generated|ram_block1a0~PORT_B_WRITE_ENABLE_REG` to `emu:emu|system:system|opll:fm|PhaseGenerator:pg|memin[16]`.
- phase_to: 8.511 ns; `emu:emu|hps_io:hps_io|ioctl_download` to `emu:emu|system:system|opll:fm|PhaseGenerator:pg|PhaseMemory:MEM|altsyncram:phase_array_rtl_0|altsyncram_a0q1:auto_generated|ram_block1a0~porta_we_reg`.

Violating groups: [].

### Seed 3: candidate

- setup: 0.002 ns; `shadowmask:HDMI_shadowmask|altshift_taps:vid_rtl_0|shift_taps_0vu:auto_generated|altsyncram_pr91:altsyncram4|ram_block5a0` to `osd:hdmi_osd|dsp_width[18]`.
- fm_from: 4.855 ns; `emu:emu|system:system|opll:fm|controller:ct|ml[0]` to `emu:emu|system:system|opll:fm|PhaseGenerator:pg|memin[14]`.
- fm_to: 2.431 ns; `emu:emu|ce_cpu` to `emu:emu|system:system|opll:fm|envelopegenerator:eg|egout[0]`.
- phase_from: 7.259 ns; `emu:emu|system:system|opll:fm|PhaseGenerator:pg|PhaseMemory:MEM|ss_mem_ready` to `emu:emu|savestates:savestates_inst|state.ST_LOAD_AUDIO_PAYLOAD`.
- phase_to: 7.773 ns; `emu:emu|savestates:savestates_inst|ss_freeze` to `emu:emu|system:system|opll:fm|PhaseGenerator:pg|PhaseMemory:MEM|altsyncram:phase_array_rtl_0|altsyncram_a0q1:auto_generated|ram_block1a0~porta_we_reg`.
- snapshot_from: 4.153 ns; `emu:emu|savestates:savestates_inst|opll_snapshot:fm_snapshot|altsyncram:memory_rtl_0|altsyncram_p3p1:auto_generated|ram_block1a0~PORT_B_WRITE_ENABLE_REG` to `emu:emu|system:system|opll:fm|envelopegenerator:eg|egstate[1]_OTERM519`.
- snapshot_to: 6.393 ns; `emu:emu|savestates:savestates_inst|ss_freeze` to `emu:emu|savestates:savestates_inst|opll_snapshot:fm_snapshot|altsyncram:memory_rtl_0|altsyncram_p3p1:auto_generated|ram_block1a0~porta_datain_reg31`.

Violating groups: [].

## Preserved timing-passing candidates

- Seed 2: [SMS_YM2413_FULLSTATE_104W_v17_66f16d5c_src601fe4306448_Q17.0.2_seed2_TIMING_PASS_807f035075c5.rbf](SMS_YM2413_FULLSTATE_104W_v17_66f16d5c_src601fe4306448_Q17.0.2_seed2_TIMING_PASS_807f035075c5.rbf); SHA-256 `807f035075c508348b9097267495eccfcf0c15332ee4b9ef3dfee51f823f08c5`.
- Seed 3: [SMS_YM2413_FULLSTATE_104W_v17_66f16d5c_src601fe4306448_Q17.0.2_seed3_TIMING_PASS_028ffa7fc5d9.rbf](SMS_YM2413_FULLSTATE_104W_v17_66f16d5c_src601fe4306448_Q17.0.2_seed3_TIMING_PASS_028ffa7fc5d9.rbf); SHA-256 `028ffa7fc5d9d6a11ecdff51c922b93f3aaf72d4d323dce188e4d6432b5c71c5`.

Exact source hashes, tool identity, native reports, settings and logs are retained in each physical_seedN directory. study.json binds all result/input manifests and preserved RBFs. Existing unconstrained external I/O paths limit timing qualification; these builds are not hardware validation.
