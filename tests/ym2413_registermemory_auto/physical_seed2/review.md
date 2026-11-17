RegisterMemory AUTO: controlled Seed 2 physical measurement, 2026-11-07

The single authorized compilation succeeded. AUTO offers a measured ALM/register benefit at the cost of one M10K and reduced setup margin. It does not save M10Ks. All constrained timing checks pass; the narrowest setup margin is +0.090 ns. No hardware test was performed.

| Metric | Full-state Seed 2 | AUTO Seed 2 | Candidate minus reference |
|---|---:|---:|---:|
| Needed ALMs | 27,421 | 27,295 | -126 (-0.460%) |
| Placed ALMs | 32,490 | 32,221 | -269 (-0.828%) |
| Recoverable ALMs | 5,439 | 5,325 | -114 |
| Unavailable ALMs | 370 | 399 | +29 |
| Fitted registers, including I/O | 36,112 | 35,784 | -328 (-0.908%) |
| Mapped logic registers | 34,942 | 34,722 | -220 |
| Logic ALUTs | 38,348 | 38,201 | -147 |
| Route-through ALUTs | 13,115 | 13,038 | -77 |
| M10Ks | 489 | 490 | +1 |
| Reported block memory bits | 3,818,374 | 3,818,572 | +198 |
| MLAB cells / bits / memory ALMs | 0 / 0 / 0 | 0 / 0 / 0 | unchanged |
| DSP blocks | 39 | 39 | unchanged |
| Setup WNS (ns) | +0.367 | +0.090 | -0.277 |
| Setup TNS (ns) | 0 | 0 | unchanged |
| Hold WNS (ns) | +0.244 | +0.246 | +0.002 |
| Hold TNS (ns) | 0 | 0 | unchanged |
| Fitter average interconnect usage | 31.5% | 30.5% | -1.0 percentage point |
| Fitter peak interconnect usage | 51.0% | 49.6% | -1.4 percentage points |

The final fitter interconnect figures above differ from the router's earlier progress estimates (25% average / 43% peak); they are the same report fields used for the reference comparison. Candidate M10K use is 490/553, leaving 63 blocks. Needed ALMs are the fitter's A-B+C estimate, not placed ALMs. Whole-design deltas include synthesis and placement changes elsewhere and must not all be attributed to RegisterMemory's local circuit.

The complete production diff remains exactly:

```diff
-    attribute ramstyle of regs_array : signal is "logic";
+    attribute ramstyle of regs_array : signal is "AUTO";
```

It is based directly on commit `9873761503510e4b2c7e06600bf5515344235c2f`, branch `experiment/ym2413-registermemory-auto`, with that one uncommitted production change. No mixer omissions are present. The 104-word format, descriptor version 17, all captures/restores, reset, address muxes and transport are unchanged. `production.diff` retains the complete diff.

The archived comparison is `tests/ym2413_v19_fullstate/physical_seed2/candidate`, the functional full-state build, not that study's upstream-master `baseline` directory. Its original metadata predates the baseline commit; preparation independently compared all 133 production RTL/integration/configuration files represented there with the committed baseline, allowing only line-ending normalization. All 221 frozen build inputs match the archived reference byte-for-byte except the requested attribute. Tool executable hashes, device, QPF/QSF/QIP/Tcl/SDC files, dependency files, and generated build metadata match. The dependency is `mist/mist-modules` commit `9bf1ea25deffe35159cec8762a4f689c1db74a8b`. Expanded global/instance assignments and fitter settings have zero differences.

Both builds use Quartus Prime Lite 17.0.2 Build 602, Cyclone V `5CSEBA6U23I7`, project/revision `SMS`, top `sys_top`, Seed 2. The reference's `BUILD_DATE=261104` was deliberately retained for a matched comparison; the actual compilation occurred on November 7. Fresh isolated compilation ran map, fit, asm, sta, with settings writes disabled for map/fit/asm. Each stage exited 0, with no retry or extra seed. `workflow.log`, `build.ps1`, `inputs.json`, `expanded_settings.txt` and native reports preserve the configuration and flow. All source hashes passed before and after compilation and after read-only database queries. Actual compilation source lists mark both `rtl/VM2413/registermemory.vhd` and `rtl/opll_snapshot.sv` used.

RegisterMemory is physically implemented as **one M10K**, located at `M10K_X14_Y51_N0`, not an MLAB or register array. The fitter RAM summary reports AUTO, simple dual port, single clock, logical 9x24, physical 9x22, 198 implementation bits, one M10K, zero MLAB cells. The two removed bit slices are bits 14 and 15, the existing zero padding in normal/restored channel register data; there is no savestate-field omission. The resource cost is nevertheless an entire 10,240-bit block. The fitter explicitly reports it cannot fit in MLABs because of an unsupported mixed feed-through setting.

| RegisterMemory hierarchy | Full-state | AUTO | Delta |
|---|---:|---:|---:|
| Mapped ALUTs | 121 | 43 | -78 |
| Mapped logic registers | 225 | 5 | -220 |
| Fitted ALUTs | 121 | 43 | -78 |
| Fitted logic registers | 228 | 5 | -223 |
| Fitter needed ALMs | 96.9 | 23.9 | -73.0 |
| Fitter placed ALMs | 171.8 | 24.5 | -147.3 |
| M10Ks | 0 | 1 | +1 |

Hierarchy ALM attribution is fractional because of shared packing. M10K internal address/control registers are not counted as ordinary logic registers.

The inferred ALTSYNCRAM and the fitted memory summary explicitly specify **mixed-port OLD_DATA**. The generated `candidate/db/altsyncram_2tp1.tdf` additionally specifies Cyclone V `MIXED_PORT_FEED_THROUGH_MODE="old"`, port A write inputs (`address_a`, `data_a`, `wren_a`), port B read inputs (`address_b`, `rden_b`), a common `clock0`, and port B address/read-enable clocking on `clock0`. The RAM input registers are enabled on both ports; there are no extra RAM output registers. This is structurally consistent with the RTL's clocked read and single write process, including synchronous initialization through the write port and the existing normal/snapshot address and write arbitration. `OUTDATA_REG_B=UNREGISTERED` describes the absence of an additional output stage; it does not make the RTL read asynchronous. No asynchronous RAM clear or initialization file was introduced.

The same-port A/B NEW_DATA entries are not the relevant collision mode: this is simple dual port with write A / read B. The relevant same-address read/write collision is mixed-port OLD_DATA, explicitly preserved in both generated primitive settings and the fitted report. There is no reported DONT_CARE/NEW_DATA substitution or new inference/collision warning. These are structural synthesis/fitter findings, not a cycle-by-cycle post-fit simulation or hardware proof. The extensive prior GHDL equivalence suite checks the source RTL only; no new simulation was necessary or run for this measurement. Post-fit behavioral equivalence and manual hardware validation remain unperformed.

PhaseMemory retains its AUTO simple-dual-port 18x18 single-clock M10K with OLD_DATA behavior, and the OPLL snapshot scratch RAM retains its 256x32 simple-dual-port single-clock M10K. EnvelopeMemory, VoiceMemory and all other fitted RAM configurations are unchanged. Normalized comparison of every other fitter RAM row (ignoring placement locations and generated entity suffixes) found zero changes. Small local ALUT/register packing changes in surrounding hierarchies are recorded in `results.json`; they are not changes to memory mode or source.

All seven setup clock groups have positive slack and zero TNS. Hold, recovery, removal and minimum pulse-width summary groups also have no violations. The candidate's critical path is HDMI scaler `ascal|o_hcpt[3]` to `ascal|o_vcpt_pre3[9]`, +0.090 ns, with other endpoints in the same scaler counter path. Its data delay is 5.966 ns, skew -0.476 ns, four logic levels. The reference critical path was scaler `o_v_poly_t.r1[25]` to `o_v_poly_pix.r[7]`, +0.367 ns. Neither critical path involves RegisterMemory or YM2413.

| Targeted setup query, worst returned path (ns) | Reference | AUTO |
|---|---:|---:|
| From FM registers | +4.391 | +4.499 |
| To FM registers | +1.917 | +2.721 |
| From PhaseMemory | +6.187 | +8.247 |
| To PhaseMemory | +7.621 | +8.821 |
| From snapshot hierarchy | +3.635 | +4.318 |
| To snapshot hierarchy | +4.160 | +7.689 |
| From RegisterMemory | not queried separately | +7.782 |
| To RegisterMemory | not queried separately | +8.452 |

RegisterMemory's worst outgoing queried path is `ss_mem_ready` to the savestate FSM; its worst incoming path terminates at the RAM's port B read-enable register. No new RegisterMemory timing violation was found. Full routes and endpoints are retained in `candidate/physical_*.rpt`. A single seed establishes this measured result, not robustness across placements. The +0.090 ns setup margin is positive but small.

Warnings increased from 67 to 70; critical warnings remain 38. The only new normalized warning messages are the RAM-node removal summary (14285) and removal of the constant bit-14 and bit-15 RAM slices (14320). No new inferred latch, multiple driver, width mismatch, read-during-write ambiguity or simulation/synthesis mismatch warning was found. Existing reports include ignored power-up level critical warnings in VDP/mapper/I/O logic, stuck SDRAM pins and interface connectivity width diagnostics (`evolution_ss_out` 96 versus 160 and `mode` 4 versus 5); those diagnostics are present in the reference too and are not fixed here.

Timing qualification remains limited by the unchanged constraints: both designs report zero illegal/unconstrained clocks, 27 unconstrained input ports (94 paths) and 91 unconstrained output ports. Output path count changes from 154 to 153. Thus the positive timing result covers the constrained analysis, not every external I/O path. Ignored constraints and unconstrained paths are retained separately; no constraints were altered to obtain the timing pass.

The retained experimental RBF is:

`SMS_YM2413_REGMEM_AUTO_104W_v17_98737615_srcdd2a501c2807_Q17.0.2_seed2_TIMING_PASS_7c528ee38cdd.rbf`

- Size: 4,146,320 bytes.
- SHA-256: `7c528ee38cdd101735abff908b2cb3c1b2e1cb6e42b0a48262f021d3df3fb6dc`.
- Frozen input manifest aggregate SHA-256: `dd2a501c28071aeaa591a7b607201c4df98c7a1933521eb54a5782206ae895df` (sorted input path and SHA-256 pairs; see preparation script).
- Exact revision: baseline `9873761503510e4b2c7e06600bf5515344235c2f` plus the one-line diff above. This candidate has not been committed.

`results.json` retains exact metrics, hierarchy and RAM rows, warning changes, native report hashes, source inclusion, timing endpoints and RBF identification. `inputs.json` retains per-input and tool hashes. `native_reports_before_queries.json` verifies native reports were unchanged by the read-only queries. All prior worktree HEADs, tracked diffs/status, master, frozen inputs and archived full-state reports passed final preservation assertions. The original functional test sources and validated experiments were not modified. Only isolated measurement artifacts and scripts were created. No commits, additional seeds, hardware testing or further optimizations were performed.

AUTO therefore offers a real but modest whole-design ALM/register reduction and a much stronger local RegisterMemory reduction. It trades one additional M10K for that benefit and reduces global setup margin. Preserve it for review and possible separately authorized validation; this measurement does not establish hardware functionality.
