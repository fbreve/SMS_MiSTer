const fs=require('fs'),p=require('path'),d=__dirname;
const data=fs.readFileSync(p.join(d,'measurements.md'),'utf8');
const report=`# Protected master versus PSG Candidate C: matched physical comparison

**NO-GO for hardware A/B testing with Candidate C as it stands.** C reduces needed and placed ALMs at both seeds, and reduces fitted registers. Setup margin decreases at both seeds; **seed 2 fails setup timing at -0.012 ns slack and -0.069 ns TNS**, with a new timing-failure critical warning. No candidate change, tuning, retry or extra seed was attempted.

All four fresh implementations completed synthesis, placement/routing, assembly and STA with successful process exit codes. Successful tool completion is separate from timing qualification: master seeds 1/2 and C seed 1 pass reported constrained timing; C seed 2 does not. Measurements completed October 29, 2026, America/Sao_Paulo.

## Identity, preflight and isolation

- Baseline: **8443a0d19a88aff7a5900011bccf386daf146945**.
- Candidate: **experiment/psg-c-controls**, its reviewed **uncommitted** nine-file simplification, frozen in [candidate_C.diff](candidate_C.diff). Reviewed patch SHA256: d3ae1a5d820fd790cb7fb96987c9038b03febca9f4813cd1a45839576104fcdd.
- [Functional revalidation](functional_revalidation.json) verified all 203 candidate manifest files, the exact reviewed patch, all 11 retained PASS/error records and their hashes, and tested controller/JT89 token identity. Prior functional reports and generators were read only. The prior reduced audio contract and known waveform differences remain the functional scope; no new functional simulation or hardware test was claimed.
- Four independent source/build directories: [seed1/A](seed1/A/), [seed1/C](seed1/C/), [seed2/A](seed2/A/), [seed2/C](seed2/C/). Baseline source came from exact Git blobs; C replaces only the nine reviewed files. The 15-file pinned mist/mist-modules dependency is **9bf1ea25deffe35159cec8762a4f689c1db74a8b**, extracted from local objects. No existing database, output or build log was copied into a build tree.
- Identical **Quartus Prime 17.0.2 Build 602 Lite**, executable hashes, **Cyclone V 5CSEBA6U23I7**, SMS/sys_top, **MISTER_FB=1**, QIP/source lists, IP, constraints and optimization settings. **BUILD_DATE 261029** and generated CDF are identical in all four builds. Production RTL was compiled, without simulator adapters.
- Within each seed, only the reviewed RTL differs. Across seeds, only the QSF **SEED 1/2** assignment differs. Actual fitter-setting tables match within both pairs. Standard Fit, High Performance Effort, SPEED, physical combinational optimization/duplication/retiming, router duplication, final placement ALWAYS, ALM packing LOW and automatic packing NORMAL remain unchanged.
- The runner checked empty database/output/log locations and frozen inputs before every build. Map/fit/asm used read_settings_files=on and write_settings_files=off; explicit stages bypassed date-generating preflow without editing the QSF or script. A temporary free Z: alias provided matched short paths and was removed. The pre-existing idle TimeQuest process was untouched; its CPU reading remained 8.03125 seconds before/after.

Evidence: [input manifest and tool hashes](input_manifest.json), [configuration equality](configuration_equality.json), [workflow with all 16 stage exits](workflow.log), [reproduction instructions](reproduce.md).

## Measured results

The tables below use **C minus its matched master**. Needed ALMs are fitter A-B+C, cross-checked against the fit summary; placed ALMs are fitter A. Fitted registers are the fit-summary total, including physical implementation effects. MLAB cells and bits are separate from M10K blocks. Logic/routing ALUTs are separate counters, not additional ALMs. Final interconnect rows are used rather than preliminary router estimates.

${data}

## Consistency and physical interpretation

**Area reductions repeat, with varying magnitude.** Needed ALMs fall **562 (2.12%)** and **451 (1.70%)**. Placed ALMs fall **626 (1.98%)** and **530 (1.68%)**. Fitted registers fall **388 (1.08%)** and **484 (1.35%)**. The mapped-register reduction is exactly **411 (1.18%)** at both seeds. These are whole-design effects of the reviewed C change, including mapping/packing/physical optimization; they are not an exclusive per-PSG cell cost or an invariant saving established by two seeds.

**Timing margin worsens at both seeds.** Setup falls **128 ps** at seed 1 and **379 ps** at seed 2. Hold changes by **+12 ps / -30 ps**, remaining positive. Only C seed 2 has a negative timing-summary group: HDMI setup. Its setup TNS is **-0.069 ns**; hold TNS remains zero. Relative setup-slack change beyond -100% at seed 2 denotes crossing zero, not a clock-frequency percentage.

**Routing improvement is not uniform.** Average total interconnect falls **0.1 / 1.3 percentage points**. Peak total changes **+2.5 / -4.8 points**. Peak vertical usage rises **7.2 / 10.3 points**, to **54.9% / 59.3%**. Routing ALUT reductions do not establish lower peak congestion everywhere.

**Memory inference is unchanged.** All builds use **487 M10Ks, zero MLAB cells/bits, 3,809,858 logical block-memory bits, zero ALMs used for memory and 39 DSP blocks**. Inferred-memory message sets and fitted RAM structural rows match within both pairs. RAM placement coordinates differ; those coordinates were excluded from the structural comparison. No new inferred/uninferred-memory change was found.

**The physical transformation set changes outside the PSG hierarchy.** Both seeds report master/C retimed-register table entries **690/700**, scaler **374/384**, luminance **39/37**. Reported retiming remains extensive in both variants. Fitted-minus-mapped register gaps change **915→938** at seed 1 and **957→884** at seed 2, demonstrating different implementation overhead. Report-entry counts do not partition the fitted-register delta into exclusive causes.

Two paired seeds support the stated repeated directions and observed sensitivity. They do not establish statistical confidence, a guaranteed area reduction at every seed, or a universal timing distribution.

## Failing-path diagnosis and warnings

The additional full-path queries read the completed databases and unchanged SDCs using the **Slow 1100mV 100C** model. They do not refit the design. The original compilation reports were hash-verified unchanged afterward.

All four worst setup paths are in the HDMI PLL clock domain with a **6.732 ns** relationship:

| Build | Worst path within ascal | Slack (ns) | Data delay (ns) | Clock skew (ns) | Logic levels |
| --- | --- | ---: | ---: | ---: | ---: |
| Master seed 1 | o_hacc[7] → o_div[0][20] | +0.518 | 5.495 | -0.519 | 4 |
| C seed 1 | o_hcpt[3] → o_vcpt_pre[0] | +0.390 | 6.033 | -0.109 | 4 |
| Master seed 2 | o_v_poly_t.r1[16] → o_v_poly_pix.r[0] | +0.367 | 5.295 | -0.870 | 1 |
| C seed 2 | o_hcpt[1] → o_vcpt_pre3[4] | **-0.012** | 5.988 | -0.556 | 4 |

[C seed-2 detailed setup report](seed2/C/physical_setup.rpt) returns ten paths, **six violated**. That is the selected report's path count, not a claimed exhaustive endpoint count. The failing path is in the unchanged HDMI scaler source. Worst endpoints differ between builds, so subtracting their delays does not isolate a change to one identical path. The precise physical mechanism behind the scaler-path degradation remains unproven. No RTL or timing-constraint correction was made.

Seed 1 adds **no** normalized warnings. Seed 2 adds **Critical Warning (332148): Timing requirements not met**. Both remove the unused psg_div2 warning. Critical message-line counts are **38/38** at seed 1 and **38/39** at seed 2. Comparisons normalize only build paths and source/report line numbering; raw messages remain in the stage logs and results.json.

Inherited coverage limits remain: **TIMEQUEST_MULTICORNER_ANALYSIS OFF**, and TimeQuest reports that the design is not fully constrained for setup/hold. Positive reported slack covers the reported constrained analysis, not unconstrained paths or all operating corners. The new negative constrained setup result is independently sufficient to fail this comparison's timing qualification.

Full evidence: [machine results](results.json), [all percentage deltas](comparison_table.md), per-build output_files reports/logs, and physical_setup/hold/ignored_sdc reports in each build directory. RBFs and fitted databases are retained for reproducibility; no image was released or programmed.

## Preservation and disposition

[Preservation verification](preservation_after.json) confirms **102,394 existing file metadata records** and **36,648 content hashes**, with zero changes. Primary HEAD/branch/index, every existing ref and worktree, Candidate C's manifest, all four frozen build inputs and executable hashes are unchanged. The original PhaseMemory edit, all untracked tests/reports and the B/C worktree modifications remain intact. [Report verification](report_verification.json) also confirms original compilation report hashes survived the timing queries. No previous database/output was overwritten.

**Stop at NO-GO for hardware A/B testing.** The reproducible area benefit does not close the seed-2 setup violation or the setup-margin loss at seed 1. The passing seed-1 image alone is insufficient to qualify the candidate across this requested pair. A separate timing investigation would be needed before reconsidering hardware qualification; no extra build, seed sweep, tuning or source correction belongs to this completed comparison.

No RTL edit, commit, push, merge, PR, master modification or hardware programming was performed. All new artifacts are confined to tests/psg_c_physical/.
`;
fs.writeFileSync(p.join(d,'review.md'),report);console.log('Wrote final physical-comparison report: NO-GO');
