RegisterMemory MLAB: matched three-seed assessment, 2026-11-07

MLAB passes constrained timing in all three measured seeds. Logic and AUTO each pass two of three. MLAB consistently reduces needed/placed ALMs and registers versus logic without adding an M10K. Seed 3 passes by only +0.030 ns, so this is improved observed closure across these seeds, not proof of timing robustness across future placements. No hardware testing was initiated.

| Implementation | Seed | Needed ALMs | Placed ALMs | Registers | M10Ks | Physical MLABs / cells | WNS ns | TNS ns | Timing |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---|
| logic | 1 | 27,438 | 32,465 | 36,049 | 489 | 0 / 0 | -0.173 | -3.970 | FAIL |
| AUTO | 1 | 27,258 | 32,307 | 35,706 | 490 | 0 / 0 | +0.128 | 0 | PASS |
| MLAB | 1 | 27,280 | 32,249 | 35,842 | 489 | 2 / 22 | +0.377 | 0 | PASS |
| logic | 2 | 27,421 | 32,490 | 36,112 | 489 | 0 / 0 | +0.367 | 0 | PASS |
| AUTO | 2 | 27,295 | 32,221 | 35,784 | 490 | 0 / 0 | +0.090 | 0 | PASS |
| MLAB | 2 | 27,192 | 32,297 | 35,868 | 489 | 2 / 22 | +0.396 | 0 | PASS |
| logic | 3 | 27,445 | 32,453 | 36,044 | 489 | 0 / 0 | +0.002 | 0 | PASS |
| AUTO | 3 | 27,271 | 32,112 | 35,726 | 490 | 0 / 0 | -0.113 | -0.113 | FAIL |
| MLAB | 3 | 27,285 | 32,257 | 35,894 | 489 | 2 / 22 | +0.030 | 0 | PASS |

The logic reference values were independently parsed from the original native fitter and TimeQuest summaries and checked against retained report hashes. The references are the full-state physical_seed1/2/3 candidate directories, not the upstream-master baseline directories. No baseline recompilation was run. All comparisons use the same tool version, device, constraints, project configuration and matching seed.

MLAB minus logic, paired by seed:

| Metric | Seed 1 | Seed 2 | Seed 3 | Mean paired delta | Range |
|---|---:|---:|---:|---:|---|
| neededALMs | -158 | -229 | -160 | -182.333 | -229 to -158 |
| placedALMs | -216 | -193 | -196 | -201.667 | -216 to -193 |
| fittedRegisters | -207 | -244 | -150 | -200.333 | -244 to -150 |
| M10K | 0 | 0 | 0 | 0 | 0 to 0 |
| physicalMLABs | +2 | +2 | +2 | +2 | +2 to +2 |
| MLABcells | +22 | +22 | +22 | +22 | +22 to +22 |
| memoryALMs | +20 | +20 | +20 | +20 | +20 to +20 |
| setupSlack | +0.550 | +0.029 | +0.028 | +0.202 | +0.028 to +0.550 |
| setupTNS | +3.970 | 0 | 0 | +1.323 | 0 to +3.970 |

MLAB minus AUTO, paired by seed:

| Metric | Seed 1 | Seed 2 | Seed 3 | Mean paired delta | Range |
|---|---:|---:|---:|---:|---|
| neededALMs | +22 | -103 | +14 | -22.333 | -103 to +22 |
| placedALMs | -58 | +76 | +145 | +54.333 | -58 to +145 |
| fittedRegisters | +136 | +84 | +168 | +129.333 | +84 to +168 |
| M10K | -1 | -1 | -1 | -1 | -1 to -1 |
| physicalMLABs | +2 | +2 | +2 | +2 | +2 to +2 |
| MLABcells | +22 | +22 | +22 | +22 | +22 to +22 |
| memoryALMs | +20 | +20 | +20 | +20 | +20 to +20 |
| setupSlack | +0.249 | +0.306 | +0.143 | +0.233 | +0.143 to +0.306 |
| setupTNS | 0 | 0 | +0.113 | +0.038 | 0 to +0.113 |

Absolute mean and range across the three seeds:

| Metric | Logic mean [min, max] | AUTO mean [min, max] | MLAB mean [min, max] |
|---|---|---|---|
| neededALMs | 27434.667 [27,421, 27,445] | 27274.667 [27,258, 27,295] | 27252.333 [27,192, 27,285] |
| placedALMs | 32469.333 [32,453, 32,490] | 32213.333 [32,112, 32,307] | 32267.667 [32,249, 32,297] |
| fittedRegisters | 36068.333 [36,044, 36,112] | 35738.667 [35,706, 35,784] | 35,868 [35,842, 35,894] |
| M10K | 489 [489, 489] | 490 [490, 490] | 489 [489, 489] |
| setupSlack | 0.065 [-0.173, 0.367] | 0.035 [-0.113, 0.128] | 0.268 [0.030, 0.396] |
| setupTNS | -1.323 [-3.970, 0] | -0.038 [-0.113, 0] | 0 [0, 0] |

All MLAB builds use exactly 2 physical MLABs, 22 MLAB cells, 198 useful MLAB bits and 20 memory ALMs, with 489 M10Ks. Those 20 memory ALMs are already included in total ALM utilization. AUTO uses 490 M10Ks and zero MLABs. The cells are not 22 physical MLAB blocks. DSP use is unchanged. Whole-design ALM/register deltas include seed-dependent packing and optimization outside RegisterMemory; they are not all local circuit reductions.

Critical paths, all in the HDMI PLL counter-0 clock domain:

| Seed | MLAB critical path | WNS ns |
|---|---|---:|
| 1 | ascal:ascal|o_hcpt[1] -> ascal:ascal|o_vcpt_pre[7] | +0.377 |
| 2 | ascal:ascal|altsyncram:o_line0[0].r[7]__2|altsyncram_ccn1:auto_generated|ram_block1a0~PORT_B_WRITE_ENABLE_REG -> ascal:ascal|o_vpix_inner[0].r[7] | +0.396 |
| 3 | shadowmask:HDMI_shadowmask|altshift_taps:vid_rtl_0|shift_taps_0vu:auto_generated|altsyncram_pr91:altsyncram4|ram_block5a0 -> osd:hdmi_osd|h_cnt[14]~DUPLICATE | +0.030 |

Seed 1 and Seed 2 are scaler paths; Seed 3 recurs in shadowmask RAM to HDMI OSD logic, similar to the sensitive reference paths. The logic reference critical paths are shadowmask RAM to OSD h_cnt[16] (Seed 1), scaler vertical interpolation (Seed 2), and shadowmask RAM to OSD dsp_width[18] (Seed 3). AUTO critical paths are scaler accumulator/counter paths. No MLAB global critical path involves RegisterMemory or FM.

| MLAB seed | From RegisterMemory ns | To RegisterMemory ns | From FM ns | To FM ns | Hold WNS ns |
|---|---:|---:|---:|---:|---:|
| 1 | +7.296 | +5.384 | +4.219 | +1.962 | +0.087 |
| 2 | +7.249 | +7.659 | +4.442 | +1.182 | +0.243 |
| 3 | +6.518 | +8.049 | +4.072 | +1.834 | +0.183 |

No negative setup, hold, recovery, removal or minimum-pulse-width summary group appears in any MLAB build. All setup and hold TNS values are zero. Seed 3 must nevertheless be treated as marginal at +0.030 ns; a positive average WNS cannot substitute for per-seed closure. Existing external I/O constraint limitations remain, as in the reference. The timing qualification covers the existing constrained analysis.

The exact production diff is still only:

```diff
-    attribute ramstyle of regs_array : signal is "logic";
+    attribute ramstyle of regs_array : signal is "MLAB";
```

Branch experiment/ym2413-registermemory-mlab remains based directly on commit 9873761503510e4b2c7e06600bf5515344235c2f, with an empty index. No RTL or test source was changed during this study. All 104 words, descriptor version 17, capture/restore assignments, transport, clocking, initialization and write/read arbitration remain unchanged. No semantic-waiver directive was added.

All 221 frozen input files are identical across candidate seeds except the QSF Seed assignment. Quartus Prime Lite 17.0.2 Build 602 targets Cyclone V 5CSEBA6U23I7, SMS revision/top sys_top, with the existing project/SDC configuration. Expanded assignments and fitter settings match each original paired reference exactly. Tool binary hashes and native report hashes were verified. BUILD_DATE remains frozen to 261104 for comparability; actual builds occurred November 7. The mist/mist-modules dependency remains 9bf1ea25deffe35159cec8762a4f689c1db74a8b. Actual compilation lists include RegisterMemory and rtl/opll_snapshot.sv.

The MLAB organization is identical across seeds: ALTDPRAM simple dual port, single clock, logical 9x24 / implemented 9x22, port A inputs registered, port B inputs unregistered and port B outputs registered. The two constant padding bit slices (14/15) are optimized away; no snapshot field is omitted. Each seed maps 43 ALUTs and 27 logic registers locally at synthesis (5 controls plus 22 outputs). Fitter packing records confirm all 22 defined output registers packed into PORTBDATAOUT in every seed. Fitted dedicated RegisterMemory register counts are 7, 6 and 6 for Seeds 1, 2 and 3; local needed ALMs are 41.7, 42.1 and 41.4. These small control/packing variations are seed-dependent structural differences outside the unchanged memory organization. Physical placement locations differ, as expected.

The generated dpram_iop1.tdf is byte-for-byte identical in all seeds, SHA-256 fdebedb9d2ffe5e3c6a894e21c1857a2695e84a538516be5cef862d60d13dfe3. Inferred parameter tables are also identical. The raw MLAB mixed-port mode is DONT_CARE; it is not a native OLD_DATA MLAB. The common-clock output registers implement the registered pre-write/old-data result. Their clock/data/enable connections in the generated primitive and their retained packed outputs in the fitter were verified in each seed. No seed-dependent semantic transformation was detected. The prior independent vendor-model structural probe passed 4,105 collisions and 24,576 checks of that exact generated arrangement, alongside the independent RTL bank smoke. Those results were reused without rerunning GHDL. This supports the intended registered interface; it does not establish full fitted-netlist equivalence or hardware correctness.

All other fitted RAM modes/shapes/block counts, including PhaseMemory and OPLL snapshot scratch RAM, match each full-state reference after normalizing locations/generated names. No new normalized warnings appear in any MLAB seed. Seed 1 removes the reference timing-not-met warning. Each MLAB build retains the same 67 warning messages, including 38 critical messages; existing power-up/interface diagnostics remain. No new latch, multiple-driver, width, unsupported-inference or collision warning was found. Full warnings, RAM rows, timing endpoints and structural evidence remain in the per-seed results/reports.

Each new build ran fresh isolated map/fit/asm/sta sequentially, once, with no retry or additional seed. Read-only database queries left native reports unchanged. Seed 2 was recursively hashed before and after and is byte-for-byte unchanged. All previous worktree HEADs/tracked diffs/status, master and reference native reports passed preservation assertions. AUTO, mixer, full-state and old minimal worktrees were not edited. No commits, merges, pushes, PRs or physical hardware tests were performed.

Timing-qualified RBFs and complete frozen-input hashes:

- Seed 1: TIMING PASS; eligible for manual hardware testing, not hardware-validated. File ../physical_seed1/SMS_YM2413_REGMEM_MLAB_104W_v17_98737615_srceb24501b048e_Q17.0.2_seed1_TIMING_PASS_39b0586a6397.rbf. Size 4,174,264 bytes. RBF SHA-256: 39b0586a639799b2fc35d0c77451232b2dd9b6bd098f6e1266a2ddac8f471d92. Frozen-input aggregate SHA-256: eb24501b048ed28d0563c915d939ea457231bbeb454c6363c9aea48450bb6911.
- Seed 2: TIMING PASS; eligible for manual hardware testing, not hardware-validated. File ../physical_seed2/SMS_YM2413_REGMEM_MLAB_104W_v17_98737615_src9ee54a99201c_Q17.0.2_seed2_TIMING_PASS_0853f7d54caa.rbf. Size 4,177,232 bytes. RBF SHA-256: 0853f7d54caa8f4fe82f23696cda97d1dc926be991d11a2eebb9dde149a5ef7f. Frozen-input aggregate SHA-256: 9ee54a99201c4e9e370ff4c2e15cdb75f12837a62020a843c8d7afef8f9b2726.
- Seed 3: TIMING PASS; eligible for manual hardware testing, not hardware-validated. File ../physical_seed3/SMS_YM2413_REGMEM_MLAB_104W_v17_98737615_src10aa1381422d_Q17.0.2_seed3_TIMING_PASS_a8746c17703a.rbf. Size 4,168,420 bytes. RBF SHA-256: a8746c17703a9093b1c2a4ef0efbf96ccfdc1fae0c21779561a54bacbe583fd4. Frozen-input aggregate SHA-256: 10aa1381422d616312b6d43d3f32c416f5098721fb8ae1a07c69cb55f0c42887.

Source hashes include the project Seed assignment, so they differ across builds. The shared production RTL/integration hash for the new manifests is 21fe004529641eda20d1020ca849ce18b0d1033092926c9a346c3bc0bd84463a; cross-seed input equality independently verifies the unchanged Seed 2 source too. Per-file/tool hashes, original reference provenance, expanded settings and physical path reports remain in the isolated directories. results.json records exact statistics and preservation assertions. artifact_hashes.json indexes the retained new evidence.

Recommendation: prefer MLAB for the next manual validation stage. In these three matched measurements it offers logic/register savings versus logic, preserves the extra M10K required by AUTO, and passes all three seeds. AUTO has lower average placed ALMs/registers, while MLAB has slightly lower mean needed ALMs and higher observed setup margins. The original logic baseline remains the committed hardware-validated fallback. MLAB is not guaranteed timing-robust beyond these seeds, and Seed 3 is especially marginal. Prefer the existing Seed 2 RBF for manual testing because it has the highest setup margin (+0.396 ns) and +0.243 ns hold margin; Seed 1 is another timing-qualified option.

Remaining validation is manual MiSTer operation: check repeated SAVE/LOAD with sustained notes, key-on/off/envelope transitions, rhythm and custom instruments, writes near snapshot/unfreeze boundaries, cold initialization and legacy/FM-disabled behavior, assessing musical continuation rather than merely nonzero sound. The new mapped memory still needs hardware validation; no full post-fit differential simulation was added here. Do not promote or commit based on these physical measurements alone. No automatic hardware test or follow-on build is started.
