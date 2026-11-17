# Combined mix + mixout omission: single matched Seed 2 measurement

Compilation succeeded. This seed has a small measurable ALM benefit and passes the existing constrained timing checks. It does not save registers or block RAM, and does not establish a repeatable multi-seed improvement. No hardware validation was performed.

| Metric | Full-state reference | Combined candidate | Change |
|---|---:|---:|---:|
| Needed ALMs | 27,421 | 27,362 | -59 (-0.215%) |
| Placed ALMs | 32,490 | 32,392 | -98 (-0.302%) |
| Recoverable ALMs | 5,439 | 5,373 | -66 |
| Unavailable ALMs | 370 | 343 | -27 |
| Fitted registers | 36,112 | 36,146 | +34 |
| Mapped registers | 34,942 | 34,942 | 0 |
| M10Ks | 489 | 489 | 0 |
| Block memory bits | 3,818,374 | 3,818,374 | 0 |
| MLAB bits/cells | 0/0 | 0/0 | 0 |
| DSP blocks | 39 | 39 | 0 |
| Fitted logic ALUTs | 38,348 | 38,367 | +19 |
| Route-through ALUTs | 13,115 | 13,035 | -80 |
| Setup WNS (ns) | +0.367 | +0.473 | +0.106 |
| Setup TNS (ns) | 0 | 0 | 0 |
| Hold WNS (ns) | +0.244 | +0.242 | -0.002 |
| Hold TNS (ns) | 0 | 0 | 0 |
| Average interconnect usage | 31.5% | 31.8% | +0.3 percentage points |
| Peak interconnect usage | 51.0% | 54.2% | +3.2 percentage points |

Needed ALMs are Quartus's placed minus recoverable plus unavailable estimate, not a synonym for occupied ALMs. Both needed and placed counts improve here. Routing congestion and fitted registers do not improve. Do not attribute all whole-design placement changes directly to deleting two mux inputs.

## Scope and equivalent configuration

- Candidate branch: `experiment/ym2413-selfhealing-combined`; HEAD `9873761503510e4b2c7e06600bf5515344235c2f`, with the approved uncommitted two-assignment experiment.
- Before compilation, every tracked production file under `rtl/`, `sys/`, plus `SMS.sv` and `files.qip`, was compared against that exact commit. The only differences are the two restore assignments in `rtl/VM2413/temporalmixer.vhd`; see `production.diff`. Other fields of word 101, normal mixer operations/registers, capture, 104-word format, version 17, transport and initialization remain unchanged.
- Existing reference: `tests/ym2413_v19_fullstate/physical_seed2/candidate`. Its historic provenance predates commit 98737615 and says dirty HEAD 66f16d5c. This was not assumed equivalent: all 133 frozen production inputs were compared with committed 98737615 and matched after CRLF normalization. Archived native report and RBF SHA-256 hashes were also verified against its original results.
- All 221 reference frozen inputs were hash-verified and copied into this isolated `candidate/` directory. Only the mixer file received the approved two replacements, retaining the archived file encoding/line endings. All other input bytes, including QSF/QPF/QIP, SDC/Tcl, dependency files and generated build metadata, are identical to the reference. `build_id.v` date remains `261104` deliberately for equivalence; actual compilation dates are in `workflow.log`.
- Quartus Prime Lite **17.0.2 Build 602**, Cyclone V **5CSEBA6U23I7**, project/revision `SMS`, top `sys_top`, Seed **2**. All five Quartus executable SHA-256 hashes matched the archived build. Dependency `mist/mist-modules` uses archived commit `9bf1ea25deffe35159cec8762a4f689c1db74a8b` bytes.
- Same map → fit → asm → sta commands as reference, same `Z:/candidate/SMS` project path, no incremental database reuse. The only compilation was this candidate Seed 2. `workflow.log` records each stage exit 0.
- Expanded global/instance assignments and fitter settings compare identically, with no differences. Actual fitter seed and device were checked in generated reports. All 107 expanded RTL assignments have parsing evidence, including `rtl/opll_snapshot.sv` and `temporalmixer.vhd` explicitly marked used.
- Frozen input/source identification SHA-256: `b79b8b3c400ab456c4ec5d870fad84ab6bb861724bc338f5b80d32804a0a6e55`. This hashes the sorted `path SHA256` lines for all 221 input files; full per-file provenance and reference linkage are in `inputs.json`.

## What synthesis and fitting actually changed

| Hierarchy | Mapped combinational ALUTs, reference → candidate | Mapped registers | Fitted needed ALMs, reference → candidate | Fitted registers, reference → candidate |
|---|---:|---:|---:|---:|
| TemporalMixer | 61 → 56 | 54 → 54 | 48.2 → 39.2 | 66 → 62 |
| OPLL including children | 2,352 → 2,366 | 1,546 → 1,546 | 1,631.6 → 1,634.0 | 1,649 → 1,650 |
| Snapshot including scratch RAM | 213 → 206 | 156 → 156 | 160.3 → 132.5 | 162 → 168 |
| PhaseMemory | 48 → 52 | 6 → 6 | 25.1 → 28.5 | 9 → 9 |

Hierarchy ALM counts are Quartus's fractional attribution. The two omissions are **not synthesized identically** to the full-state implementation: TemporalMixer loses five mapped combinational ALUTs, retains all 54 mapped registers, and its inferred mux report loses the restored-output 3:1 mux and reduces the accumulator mux from 4:1 to 3:1. Both operational 14-bit registers remain. However, other mapped hierarchy counts change under synthesis optimization; total OPLL logic increases. The measured whole-design ALM reduction therefore includes altered packing/routing/physical optimization, rather than demonstrating 59 directly deleted RTL ALMs.

PhaseMemory still infers **AUTO, simple dual port, single clock, 18×18 (324 bits)** and fits in **one M10K**, with no MLAB or memory-ALM substitution. Its fitted logic attribution increases by 3.4 needed ALMs and four combinational ALUTs, but registers and RAM implementation remain unchanged. Snapshot scratch remains **256×32 (8,192 bits), simple dual port, single clock, one M10K**. Both retain their reference registered-port/read-during-write settings. No RAM inference regression was found; full RAM rows and synthesis evidence are retained in `results.json`.

## Timing and warning review

The candidate's critical setup path is the HDMI scaler `ascal:ascal|o_state.sREAD` → `ascal:ascal|o_state.sREAD`, +0.473 ns, HDMI PLL domain, 5.965 ns data delay. The reference worst path was also in the HDMI scaler, `o_v_poly_t.r1[25]` → `o_v_poly_pix.r[7]`, +0.367 ns. The next candidate setup paths are scaler line-buffer outputs into `o_vpix_outer/inner` at +0.541/+0.549 ns. No negative setup, hold, recovery, removal or minimum-pulse-width groups were reported.

Targeted slow-model setup queries:

| Scope | Worst from (ns) | Worst to (ns) |
|---|---:|---:|
| FM | +4.425 | +2.252 |
| PhaseMemory | +7.267 | +7.455 |
| Snapshot | +3.486 | +6.091 |

The worst FM destination is `lastkey[12]`, launched by `ce_cpu`; the worst FM-origin path is controller `ml[0]` → phase-generator `memin[17]`. All queried paths have positive slack. Global native summaries cover the existing flow's timing models; targeted detailed reports use the same slow-model query as the reference.

Warnings: 67 → 69 unique native report warnings, with **38 critical warnings unchanged**. The only additions are Warning 10036 for `ss_v_mix` and `ss_v_mixout` assigned but never read, expected from the approved omissions. No inferred latch, multiple-driver or width/truncation warning was found. Existing critical power-up warnings in VDP/mapper/I/O remain unchanged. The existing design is not fully constrained for setup/hold; this measurement passes the existing constrained analysis and does not establish timing coverage for unconstrained interfaces. Read-only timing/settings queries were verified not to alter native reports.

## Preserved artifact and stopping point

RBF: `SMS_YM2413_MIX_MIXOUT_104W_v17_98737615_srcb79b8b3c400a_Q17.0.2_seed2_TIMING_PASS_3a5b3d575a79.rbf`

- Bytes: **4,138,380**
- SHA-256: **`3a5b3d575a7992d2488520679f0874e943db8c05b98f309a5a32ef3066ed2230`**
- Exact inputs, tool identities, source patch, commands, native reports, detailed timing reports, collection scripts and results are retained alongside this report.

Conclusion: **a small, measurable Seed 2 ALM benefit with acceptable constrained timing; no register/M10K benefit and slightly greater measured routing usage.** It is a timing-passing experimental artifact for review, not a hardware-validated implementation. No automatic hardware testing or further seeds/optimizations were started.

Final checks passed: frozen build inputs unchanged; archived reference native reports unchanged; master and all preexisting worktree HEADs, tracked diffs and tracked status unchanged, including `sys/`, full-state, mixout-only and accumulator-only references. No production/test source edits, commits, merges, pushes or PRs were made during measurement. No GHDL instances were needed.
