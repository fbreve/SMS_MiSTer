# EEPROM fallback cleanup: controlled five-seed Quartus study

**Classification B: mixed fitter sensitivity, but comfortably timing-clean across all five tested seeds. Recommendation 2: keep the cleanup, with a hardware smoke test before commit.** It is physically different, not neutral. No RTL repair, constraint change, seed selection, commit, push, or PR was performed.

Baseline HEAD: `f875eb70ccd9023802ee41bb28686d11d65ee717`. Branch: `cleanup/mapper-eeprom-fallback`. Baseline A is a fresh git-archive snapshot; cleanup B overlays only the current `rtl/mapper_ctrl.vhd`. All ten builds are fresh, sequential full compilations, without database reuse. Production files were not edited.

Quartus Prime 17.0.2 Build 602 Lite; revision SMS; device 5CSEBA6U23I7; seeds 1–5; BUILD_DATE=261006. Command: `quartus_sh --flow compile SMS -c SMS`. Date is pinned in both copied generators and preinitialized build_id.v. Only copied SMS.qsf seed assignments change between seeds. Original constraints and remaining settings are preserved. Matched input hashes differ only in mapper_ctrl.vhd; pre/post-build inputs match. Cross-seed manifests differ only in SMS.qsf, verified to differ textually only in SEED. All tracked workspace hashes match before/after.

## Setup timing

All slacks and deltas are ns; delta = cleanup minus baseline. Full endpoints are listed below.

| Seed | Baseline setup | Cleanup setup | Delta | Baseline worst path | Cleanup worst path |
|---|---:|---:|---:|---|---|
| 1 | +0.539 | +0.794 | +0.255 | ram_block1a4~PORT_B_WRITE_ENABLE_REG → o_vpix_inner[0].r[1] | o_vcpt_pre3[4] → o_vcpt_pre3[11] |
| 2 | +0.422 | +0.387 | -0.035 | rom_crc32[11]~DUPLICATE → cen_16 | o_hcpt[3] → o_vcpt_pre2[6] |
| 3 | +0.757 | +0.376 | -0.381 | ram_block1a0~PORT_B_WRITE_ENABLE_REG → o_vpix_inner[0].r[5] | o_hcpt[1] → o_vcpt[11] |
| 4 | +0.682 | +0.396 | -0.286 | o_hcpt[5] → o_vcpt_sync[6] | vid[2] → vid[5] |
| 5 | +0.399 | +0.757 | +0.358 | o_hcpt[2] → o_vcpt[2] | o_hcpt[1] → o_vcpt_pre2[8] |

| Statistic | Baseline | Cleanup |
|---|---:|---:|
| minimum | 0.399 | 0.376 |
| maximum | 0.757 | 0.794 |
| mean | 0.5598 | 0.542 |
| median | 0.539 | 0.396 |
| range | 0.358 | 0.418 |
| passing | 5 | 5 |
| failing | 0 | 0 |
| mean_alms | 26628 | 26543.2 |
| mean_aluts | 37283.4 | 37106.8 |

## Collected timing and resources

TNS is summed over reported clock domains. Fitted combinational ALUTs are the usage-for-logic count. Mapper counts are synthesis per-entity counts, including dedicated registers.

| Seed | Version | Setup TNS | Hold slack | Hold TNS | Fitted ALMs | Fitted registers | Fitted ALUTs | Mapper ALUTs | Mapper registers |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|
| 1 | Baseline | 0.000 | +0.241 | 0.000 | 26660 | 35843 | 37283 | 364 | 106 |
| 1 | Cleanup | 0.000 | +0.243 | 0.000 | 26540 | 35695 | 37106 | 340 | 106 |
| 2 | Baseline | 0.000 | +0.245 | 0.000 | 26617 | 35780 | 37283 | 364 | 106 |
| 2 | Cleanup | 0.000 | +0.195 | 0.000 | 26575 | 35735 | 37109 | 340 | 106 |
| 3 | Baseline | 0.000 | +0.240 | 0.000 | 26615 | 35788 | 37284 | 364 | 106 |
| 3 | Cleanup | 0.000 | +0.245 | 0.000 | 26498 | 35757 | 37106 | 340 | 106 |
| 4 | Baseline | 0.000 | +0.205 | 0.000 | 26656 | 35813 | 37284 | 364 | 106 |
| 4 | Cleanup | 0.000 | +0.205 | 0.000 | 26557 | 35882 | 37107 | 340 | 106 |
| 5 | Baseline | 0.000 | +0.206 | 0.000 | 26592 | 35833 | 37283 | 364 | 106 |
| 5 | Cleanup | 0.000 | +0.242 | 0.000 | 26546 | 35796 | 37106 | 340 | 106 |

| Seed | ALM delta | Fitted register delta | Fitted ALUT delta | Mapper ALUT delta | Mapper register delta |
|---|---:|---:|---:|---:|---:|
| 1 | -120 | -148 | -177 | -24 | 0 |
| 2 | -42 | -45 | -174 | -24 | 0 |
| 3 | -117 | -31 | -178 | -24 | 0 |
| 4 | -99 | 69 | -177 | -24 | 0 |
| 5 | -46 | -37 | -177 | -24 | 0 |

## Full worst setup endpoints

Seed 1, Baseline, +0.539 ns:

From: `ascal:ascal|altsyncram:o_line0[0].r[7]__2|altsyncram_ccn1:auto_generated|ram_block1a4~PORT_B_WRITE_ENABLE_REG`

To: `ascal:ascal|o_vpix_inner[0].r[1]`

Launch/latch clock: `pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk` / `pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk`.

Seed 1, Cleanup, +0.794 ns:

From: `ascal:ascal|o_vcpt_pre3[4]`

To: `ascal:ascal|o_vcpt_pre3[11]`

Launch/latch clock: `pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk` / `pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk`.

Seed 2, Baseline, +0.422 ns:

From: `emu:emu|system:system|mapper_detect:mapper_detect_inst|rom_crc32[11]~DUPLICATE`

To: `emu:emu|system:system|jt89:psg_inst|cen_16`

Launch/latch clock: `emu|pll|pll_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk` / `emu|pll|pll_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk`.

Seed 2, Cleanup, +0.387 ns:

From: `ascal:ascal|o_hcpt[3]`

To: `ascal:ascal|o_vcpt_pre2[6]`

Launch/latch clock: `pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk` / `pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk`.

Seed 3, Baseline, +0.757 ns:

From: `ascal:ascal|altsyncram:o_line0[0].r[7]__2|altsyncram_ccn1:auto_generated|ram_block1a0~PORT_B_WRITE_ENABLE_REG`

To: `ascal:ascal|o_vpix_inner[0].r[5]`

Launch/latch clock: `pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk` / `pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk`.

Seed 3, Cleanup, +0.376 ns:

From: `ascal:ascal|o_hcpt[1]`

To: `ascal:ascal|o_vcpt[11]`

Launch/latch clock: `pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk` / `pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk`.

Seed 4, Baseline, +0.682 ns:

From: `ascal:ascal|o_hcpt[5]`

To: `ascal:ascal|o_vcpt_sync[6]`

Launch/latch clock: `pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk` / `pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk`.

Seed 4, Cleanup, +0.396 ns:

From: `shadowmask:HDMI_shadowmask|vid[2]`

To: `shadowmask:HDMI_shadowmask|vid[5]`

Launch/latch clock: `pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk` / `pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk`.

Seed 5, Baseline, +0.399 ns:

From: `ascal:ascal|o_hcpt[2]`

To: `ascal:ascal|o_vcpt[2]`

Launch/latch clock: `pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk` / `pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk`.

Seed 5, Cleanup, +0.757 ns:

From: `ascal:ascal|o_hcpt[1]`

To: `ascal:ascal|o_vcpt_pre2[8]`

Launch/latch clock: `pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk` / `pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk`.

## Warning comparison

Warning comparison uses stage-specific multisets, including suppressed warnings. Normalization removes build-copy root paths, whitespace, and shifted mapper_ctrl.vhd line numbers only.

| Seed | Version | Errors | Ordinary warnings | Critical warnings | A/B normalized additions/removals |
|---|---|---:|---:|---:|---|
| 1 | A | 0 | 32 | 38 | 0 / 0 |
| 1 | B | 0 | 32 | 38 | 0 / 0 |
| 2 | A | 0 | 32 | 38 | 0 / 0 |
| 2 | B | 0 | 32 | 38 | 0 / 0 |
| 3 | A | 0 | 32 | 38 | 0 / 0 |
| 3 | B | 0 | 32 | 38 | 0 / 0 |
| 4 | A | 0 | 32 | 38 | 0 / 0 |
| 4 | B | 0 | 32 | 38 | 0 / 0 |
| 5 | A | 0 | 32 | 38 | 0 / 0 |
| 5 | B | 0 | 32 | 38 | 0 / 0 |

## Scope of the result

Prior cycle-by-cycle functional verification passed 402,603 cycles and 9,259,869 comparisons across all 23 outputs under the production binary mapper_eeprom contract. This study does not extend that equivalence claim to U/X/Z or other nonbinary std_logic values. Timing claims concern the existing reported constrained paths; constraints were not expanded or relaxed.

The earlier Evolution readback study failed one of five refactor seeds, lost setup margin in four pairs, and reduced mean/median slack from 0.5598/0.539 ns to 0.3784/0.317 ns. It used another baseline commit, so it is a comparison of observed timing-risk patterns, not a controlled cross-candidate comparison.

See study.json for numeric data, verification.json for final preservation checks, and seed1–seed5 directories for raw reports, input manifests, compile logs, result metadata, warning comparisons, RBFs, and independently extracted slow-model setup paths. No commit, push, or PR was performed.

## Interpretation and recommendation

Both versions pass all five seeds: every reported setup/hold domain has zero TNS. Cleanup minimum setup slack is +0.376 ns versus baseline +0.399 ns, a 0.023 ns reduction. Mean slack falls only 0.0178 ns (3.2%), from 0.5598 to 0.5420 ns. Median slack falls 0.143 ns (26.5%), from 0.539 to 0.396 ns. Cleanup range is 0.418 ns versus 0.358 ns, 16.8% wider. Two paired seeds improve and three worsen; the largest loss is 0.381 ns. The median paired delta is -0.035 ns, distinct from the difference of medians (-0.143 ns). These figures show sensitivity and a lower observed median; they do not support claiming a timing improvement or complete physical neutrality.

Unlike the rejected Evolution candidate, this cleanup has no failing seed, retains nearly the baseline minimum margin, and has a mean close to baseline. Evolution's cleanup/refactor minimum was -0.028 ns and its setup range 0.796 ns, with a 0.1814 ns mean reduction. The present results show no comparable collapse of setup margin. Five seeds describe the tested distribution; they cannot prove the absence of an adverse bias in every future fit. Classification B reflects the mixed results rather than discarding the three paired losses or selecting the two favorable seeds.

Four of five cleanup worst paths are scaler paths; seed 4 is HDMI shadow-mask logic. Four baseline worst paths are scaler paths; baseline seed 2 is mapper detection CRC feeding PSG enable. None is in mapper_ctrl. These moved endpoints are consistent with global fitter re-placement and physical optimization following changed synthesized logic. That mechanism is an inference, not a proof of the precise cause, and unrelated path ownership alone does not make a timing failure benign.

Resource reduction is consistent in every pair: 42–120 fewer ALMs and 174–178 fewer fitted combinational ALUTs. Mean reductions are 84.8 ALMs and 176.6 fitted ALUTs. Mapper synthesis consistently falls 364→340 ALUTs while retaining 106 registers; total synthesis registers remain 34,857 in all ten builds. Fitted registers vary: deltas -148, -45, -31, +69, -37. Seed 4's extra fitted registers coexist with fewer ALMs/ALUTs and healthy timing; this is a physical fitter result, not a change to source state ownership. The whole-design ALUT reduction should not be attributed entirely to the mapper's 24-ALUT local reduction.

All builds have 0 errors, 32 ordinary warnings, 38 existing critical warnings, and 46 suppressed ordinary warnings. All eight stage-specific A/B warning multisets (visible and suppressed) match for every seed. Recovery, removal, and minimum-pulse margins also remain positive. The fresh seed-1 pair reproduces both previous RBF hashes, timing, and resources exactly, supporting reproducibility of the pinned procedure.

Recommendation 2 balances the consistently smaller implementation and healthy minimum timing margin against lower median slack and physically changed placement. Keep the cleanup and exercise EEPROM/fallback/Janggun banking, BIOS handoff, savestate restore, and freeze/release in a hardware smoke test before committing. No hardware test was performed in this study. There is no measured basis here for abandoning it or for changing RTL/constraints to improve a chosen seed.

## Final working-tree verification

HEAD remains `f875eb70ccd9023802ee41bb28686d11d65ee717`; branch remains `cleanup/mapper-eeprom-fallback`. All 203 tracked regular-file hashes match the pre-study manifest. Final `git status --short`:

```text
 M rtl/mapper_ctrl.vhd
```

Diff remains one file, 6 insertions and 8 deletions. `git diff --check` passes with empty output. Study artifacts are in the ignored output_files directory. Production RTL and constraints were not modified during the study; the existing cleanup is preserved.