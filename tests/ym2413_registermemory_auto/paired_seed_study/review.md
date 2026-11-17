RegisterMemory AUTO: matched three-seed assessment, 2026-11-07

The two authorized new builds (Seeds 1 and 3) completed physically. Seed 1 passes constrained timing; Seed 3 fails setup timing. Existing Seed 2 was reused without alteration. AUTO consistently saves logic and registers for one additional M10K, but does not establish reliable timing closure across these seeds. Retain it as an experimental resource-saving candidate; do not promote it as a timing-robust replacement baseline.

| Design | Seed | Needed ALMs | Placed ALMs | Fitted registers | M10Ks | MLAB cells/bits | Setup WNS ns | Setup TNS ns | Constrained timing |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---|
| Full-state | 1 | 27,438 | 32,465 | 36,049 | 489 | 0 / 0 | -0.173 | -3.970 | FAIL |
| AUTO | 1 | 27,258 | 32,307 | 35,706 | 490 | 0 / 0 | +0.128 | 0 | PASS |
| Full-state | 2 | 27,421 | 32,490 | 36,112 | 489 | 0 / 0 | +0.367 | 0 | PASS |
| AUTO | 2 | 27,295 | 32,221 | 35,784 | 490 | 0 / 0 | +0.090 | 0 | PASS |
| Full-state | 3 | 27,445 | 32,453 | 36,044 | 489 | 0 / 0 | +0.002 | 0 | PASS, narrow |
| AUTO | 3 | 27,271 | 32,112 | 35,726 | 490 | 0 / 0 | -0.113 | -0.113 | FAIL |

Original full-state fitter reports/summaries and timing summaries were independently parsed to verify the authoritative reference values. Archived report SHA-256 hashes were checked against their original result manifests. The references are `tests/ym2413_v19_fullstate/physical_seed{1,2,3}/candidate`, not the upstream-master `baseline` directories in those studies.

All following deltas are AUTO minus its same-seed full-state reference. Means/ranges are descriptive for these three runs only.

| Metric | Seed 1 delta | Seed 2 delta | Seed 3 delta | Mean paired delta | Paired delta range |
|---|---:|---:|---:|---:|---:|
| Needed ALMs | -180 | -126 | -174 | -160 | -180 to -126 |
| Placed ALMs | -158 | -269 | -341 | -256 | -341 to -158 |
| Fitted registers | -343 | -328 | -318 | -329.667 | -343 to -318 |
| M10Ks | +1 | +1 | +1 | +1 | +1 to +1 |
| MLAB cells / bits | 0 / 0 | 0 / 0 | 0 / 0 | 0 / 0 | unchanged |
| Setup WNS ns | +0.301 | -0.277 | -0.115 | -0.030333 | -0.277 to +0.301 |
| Setup TNS ns | +3.970 | 0 | -0.113 | +1.285667 | -0.113 to +3.970 |

| Metric | Full-state mean [min, max] | AUTO mean [min, max] |
|---|---|---|
| Needed ALMs | 27,434.667 [27,421, 27,445] | 27,274.667 [27,258, 27,295] |
| Placed ALMs | 32,469.333 [32,453, 32,490] | 32,213.333 [32,112, 32,307] |
| Fitted registers | 36,068.333 [36,044, 36,112] | 35,738.667 [35,706, 35,784] |
| M10Ks | 489 [489, 489] | 490 [490, 490] |
| MLAB cells / bits | 0 / 0 | 0 / 0 |
| Setup WNS ns | +0.065333 [-0.173, +0.367] | +0.035000 [-0.113, +0.128] |
| Setup TNS ns | -1.323333 [-3.970, 0] | -0.037667 [-0.113, 0] |

**The positive mean candidate WNS does not qualify the failing Seed 3 build.** Both designs pass two of three seeds, with different failing seeds. The timing effect changes sign across matched pairs. This is consistent with sensitivity of HDMI placement/routing rather than a consistent timing improvement from AUTO; three seeds do not establish a statistical failure probability. Seed 3's new timing failure is part of the measured cost of the candidate, even though it is outside FM logic.

All critical paths use the HDMI PLL counter-0 output clock:

| Seed | Reference critical path | AUTO critical path |
|---|---|---|
| 1 | HDMI shadowmask RAM `ram_block5a0` to HDMI OSD `h_cnt[16]~DUPLICATE`, -0.173 ns | Scaler `o_hacc[8]` to `o_dir[0][10]`, +0.128 ns |
| 2 | Scaler `o_v_poly_t.r1[25]` to `o_v_poly_pix.r[7]`, +0.367 ns | Scaler `o_hcpt[3]` to `o_vcpt_pre3[9]`, +0.090 ns |
| 3 | HDMI shadowmask RAM `ram_block5a0` to HDMI OSD `dsp_width[18]`, +0.002 ns | Scaler `o_hacc[6]` to `o_dir[0][10]`, -0.113 ns |

Seed 3's failing path has four logic levels, 6.152 ns data delay and -0.493 ns skew. The candidate Seeds 1 and 3 critical paths share the scaler accumulator-to-direction endpoint pattern. No global critical path is in RegisterMemory or YM2413. Targeted worst setup slacks returned by the retained queries are:

| Candidate seed | From FM | To FM | From RegisterMemory | To RegisterMemory | Hold WNS |
|---|---:|---:|---:|---:|---:|
| 1 | +4.823 ns | +1.828 ns | +7.583 ns | +7.705 ns | +0.241 ns |
| 2 | +4.499 ns | +2.721 ns | +7.782 ns | +8.452 ns | +0.246 ns |
| 3 | +4.886 ns | +1.841 ns | +6.422 ns | +7.368 ns | +0.181 ns |

Hold TNS is zero for all candidates. All other timing summary types are nonnegative; Seed 3's only negative summary group is HDMI setup. Existing unconstrained external I/O and ignored power-up warnings remain; timing statements cover the existing constrained analysis, not every external I/O path. No SDC or constraints were changed.

RegisterMemory maps to exactly one M10K and zero MLABs in all candidates: simple dual port, single clock, 9x24 logical, 9x22 implemented, 198 useful memory bits. Both ports have input registers and no additional output registers. Inferred parameter tables are identical across all three seeds: port B address/read-control registered on CLOCK0, mixed-port `OLD_DATA`, unregistered additional output stage, no asynchronous RAM clear or init file. Generated Cyclone V primitives also retain `MIXED_PORT_FEED_THROUGH_MODE="old"` and port B address/read-enable on clock0. The same-port NEW_DATA entries do not change the relevant write-A/read-B OLD_DATA collision mode. The fitter explicitly rejects MLAB fit because of the mixed feed-through setting.

| RegisterMemory | Reference, all seeds | AUTO, all seeds |
|---|---:|---:|
| Mapped ALUTs | 121 | 43 |
| Mapped logic registers | 225 | 5 |
| M10Ks | 0 | 1 |

AUTO's fitted RegisterMemory registers are 7, 5 and 6 for Seeds 1, 2 and 3, reflecting fitter duplication/packing. Its fitted needed ALMs are 23.4, 23.9 and 22.7 respectively. This demonstrates an actual local logic reduction; whole-design deltas also include changed optimization and placement outside the memory hierarchy. The two constant channel padding bits (14 and 15) are optimized away, not savestate fields. All 104 words and descriptor version 17 remain intact. PhaseMemory, snapshot scratch RAM and every other fitted RAM mode/shape/block count match each corresponding full-state reference after normalizing placement locations and generated instance suffixes.

Each candidate adds only the known constant RAM-bit removal warnings (14285/14320) apart from timing status. Seed 1 removes the reference's timing-not-met warning; Seed 3 adds timing-not-met warning 332148. No new latch, multiple-driver, width, collision-mode or simulation/synthesis mismatch warning was found. The existing baseline power-up and interface-width diagnostics remain. Positive report structure and prior RTL simulation do not replace post-fit behavioral testing or manual FPGA validation; neither was performed in this study.

Final fitter interconnect utilization (not the router's earlier progress estimate):

| AUTO seed | Average total/H/V | Peak total/H/V |
|---|---|---|
| 1 | 31.4% / 31.7% / 30.4% | 56.0% / 55.7% / 60.8% |
| 2 | 30.5% / 30.6% / 30.2% | 49.6% / 48.8% / 52.0% |
| 3 | 31.4% / 31.7% / 30.5% | 52.1% / 51.5% / 58.2% |

Source/configuration and artifacts:

- Branch `experiment/ym2413-registermemory-auto`, HEAD `9873761503510e4b2c7e06600bf5515344235c2f`, with the existing one-line `ramstyle` change from `logic` to `AUTO`. No production or test source was modified in this study. New files are isolated measurement scripts, reports and artifacts outside worktrees.
- All 221 frozen inputs match across candidate builds except the QSF Seed assignment. The shared production RTL/integration hash is `784a48630c618c4047c9f96fb96904f374cfab5ccf84eb2f80291a024c4e922f` (sorted production path/hash pairs). The complete per-seed manifests below include project settings; their hashes differ because the Seed assignment differs.
- Quartus Prime Lite 17.0.2 Build 602, Cyclone V `5CSEBA6U23I7`, project/revision `SMS`, top `sys_top`, identical dependencies and SDCs. Tool binary hashes were checked. Expanded global/instance assignments and fitter settings match each paired reference exactly. As for Seed 2, BUILD_DATE is frozen to the reference's `261104`; actual new builds occurred November 7.
- Sequential fresh map/fit/asm/sta flows with the same settings and read-only query scripts as Seed 2. Each compilation stage exited 0; successful process completion is distinguished from Seed 3's failed timing analysis. No retries, baseline recompilations or extra seeds.
- Seeds 1 and 3 are isolated in `../physical_seed1` and `../physical_seed3`; the existing Seed 2 directory was recursively hashed before and after and is byte-for-byte unchanged. All prior worktree HEADs/tracked diffs/status and master passed final preservation checks. Reference native report hashes and frozen input hashes passed too.

| Seed | Complete frozen input manifest aggregate SHA-256 |
|---|---|
| 1 | `0a4e79886b1a0663a14c76165668d3767d22fa4f75c173d6358cd810dd977709` |
| 2 | `dd2a501c28071aeaa591a7b607201c4df98c7a1933521eb54a5782206ae895df` |
| 3 | `84dd22fafa05f5edc4654b8ce92cf612b73c4f53241c1f1d3675b18607ebedcd` |

Retained RBFs have explicit source/tool/seed/timing-status names:

- Seed 1, timing PASS: `../physical_seed1/SMS_YM2413_REGMEM_AUTO_104W_v17_98737615_src0a4e79886b1a_Q17.0.2_seed1_TIMING_PASS_e4cc7a758d38.rbf`, 4,142,012 bytes. SHA-256 `e4cc7a758d3836c751e709e383552137515a9d45212fe0ca6aeb413a17086ec3`.
- Seed 2, existing timing PASS: `../physical_seed2/SMS_YM2413_REGMEM_AUTO_104W_v17_98737615_srcdd2a501c2807_Q17.0.2_seed2_TIMING_PASS_7c528ee38cdd.rbf`, 4,146,320 bytes. SHA-256 `7c528ee38cdd101735abff908b2cb3c1b2e1cb6e42b0a48262f021d3df3fb6dc`.
- Seed 3, timing FAIL, retained for traceability rather than validation: `../physical_seed3/SMS_YM2413_REGMEM_AUTO_104W_v17_98737615_src84dd22fafa05_Q17.0.2_seed3_TIMING_FAIL_db92910497d5.rbf`, 4,148,648 bytes. SHA-256 `db92910497d52b98231a6e7a6e1ab926706e7e1cb0524df15300f27b730633bc`.

Per-seed native reports, full timing paths, inferred RAM parameters, input/tool hashes, warning differences, expanded assignments and RBF metadata are preserved in each physical directory. This directory's `results.json` contains the cross-seed checks and exact numerical statistics. Scripts preserve provenance and reject source drift or accidental report replacement.

Recommendation: the extra M10K buys a reproducible average reduction of 160 needed ALMs, 256 placed ALMs and about 330 registers. With 63 M10Ks left, that is a defensible experimental logic/register trade-off if those resources are the priority. It is not a timing improvement: paired WNS averages -0.030333 ns, varies in sign and fails Seed 3. Keep AUTO for independent review and possible separately authorized validation using a passing artifact; do not treat it as a timing-robust baseline or use the failing RBF for validation. No new builds, fixes, combinations, commits or hardware tests are authorized or undertaken here.
