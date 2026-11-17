RegisterMemory MLAB isolated experiment, Seed 2, 2026-11-07

Quartus Prime Lite 17.0.2 accepts the MLAB attribute and implements RegisterMemory in two physical MLABs. The single authorized synthesis/fitter/assembler/timing flow succeeded and passes constrained timing. MLAB is a promising balanced trade-off in this seed: it saves more needed ALMs than AUTO without consuming an extra M10K, although AUTO uses fewer placed ALMs and registers. This is one placement result, not evidence of robustness across seeds or hardware functionality.

| Seed 2 metric | Full-state logic | AUTO | MLAB | MLAB minus logic | MLAB minus AUTO |
|---|---:|---:|---:|---:|---:|
| Needed ALMs | 27,421 | 27,295 | 27,192 | -229 | -103 |
| Placed ALMs | 32,490 | 32,221 | 32,297 | -193 | +76 |
| Fitted registers, including I/O | 36,112 | 35,784 | 35,868 | -244 | +84 |
| Mapped logic registers | 34,942 | 34,722 | 34,744 | -198 | +22 |
| M10Ks | 489 | 490 | 489 | 0 | -1 |
| MLAB cells, fitter RAM summary | 0 | 0 | 22 | +22 | +22 |
| Physical MLABs | 0 | 0 | 2 | +2 | +2 |
| ALMs used for memory | 0 | 0 | 20 | +20 | +20 |
| Useful MLAB memory bits | 0 | 0 | 198 | +198 | +198 |
| Logic ALUTs | 38,348 | 38,201 | 38,204 | -144 | +3 |
| Route-through ALUTs | 13,115 | 13,038 | 13,112 | -3 | +74 |
| Setup WNS ns | +0.367 | +0.090 | +0.396 | +0.029 | +0.306 |
| Setup TNS ns | 0 | 0 | 0 | 0 | 0 |
| Hold WNS ns | +0.244 | +0.246 | +0.243 | -0.001 | -0.003 |
| Hold TNS ns | 0 | 0 | 0 | 0 | 0 |

All resources above are measured, not estimates inferred from the attribute. Needed ALMs are Quartus's A-B+C estimate and differ from placed ALMs. The 20 memory ALMs are already included in whole-design utilization; do not add them again. The fitter's 22 MLAB-cell count is not 22 physical MLAB blocks. Its RAM location list contains exactly two memory LABs, `LAB_X3_Y47_N0` and `LAB_X3_Y50_N0`. Candidate M10Ks remain 489/553, leaving 64 available.

The branch is `experiment/ym2413-registermemory-mlab`, created directly from `9873761503510e4b2c7e06600bf5515344235c2f` in `tests/ym2413_registermemory_mlab/worktree`. The complete production diff is one attribute change:

```diff
-    attribute ramstyle of regs_array : signal is "logic";
+    attribute ramstyle of regs_array : signal is "MLAB";
```

It does not build on AUTO or the mixer experiments. No array, address logic, read/write process, reset, initialization, transport, snapshot fields or descriptor changes were made. All 104 words and descriptor version 17 remain intact. The index is empty and the only modified tracked file in the new worktree is `rtl/VM2413/registermemory.vhd`. No `no_rw_check` or equivalent semantic waiver was introduced.

The actual memory implementation differs structurally from AUTO:

| RegisterMemory implementation | Logic | AUTO | MLAB |
|---|---|---|---|
| Storage | Logic/register array | One M10K | Two MLABs |
| Inferred primitive | No inferred block RAM | ALTSYNCRAM | ALTDPRAM / LUTRAM |
| Logical size | 9x24 | 9x24 | 9x24 |
| Useful implemented storage | Logic | 9x22, 198 block bits | 9x22, 198 MLAB bits |
| Read structure | Clocked RTL read | Clocked RAM read address/control, no additional output stage | Asynchronous read address/control plus clocked output registers |
| Raw mixed-port collision parameter | RTL old-data behavior | OLD_DATA | DONT_CARE |
| Mapped local ALUTs | 121 | 43 | 43 |
| Mapped local logic registers | 225 | 5 | 27 (5 controls + 22 outputs) |
| Fitted local needed ALMs | 96.9 | 23.9 | 42.1, including 20 memory ALMs |
| Fitted local placed ALMs | 171.8 | 24.5 | 44.3, including 20 memory ALMs |
| Fitted local dedicated logic registers | 228 | 5 | 6 |

The two omitted physical bit slices are the existing constant padding bits 14/15, not savestate-field omissions. At synthesis, Quartus adds 22 output flip-flops to the LUTRAM. The fitter's optimization table explicitly records those `dataout_reg` registers packed into the MLAB `PORTBDATAOUT`; that accounts for the drop from 27 mapped logic registers to 6 dedicated logic registers in the fitted hierarchy. The fitted RAM summary reports single-clock simple dual port, registered port A inputs, unregistered port B inputs, registered port B outputs and zero M10Ks. The registered output function remains present despite the lower dedicated-register count.

**Collision semantics require distinguishing the raw memory from its registered interface.** The generated MLAB primitive reports DONT_CARE, not native OLD_DATA. Its asynchronous output may change during a write. The generated `dpram_iop1.tdf` places enabled output registers on that output with the same clock as the write port. Those registers sample the pre-write value at the edge, preserving the intended registered old-data behavior. The fitter subsequently packs them into the memory output registers. There is no address/control read-register latency added ahead of this output stage.

This inference was not accepted based solely on the attribute or the passing source RTL test. Before running the fitter, a separate Intel Cyclone V vendor-model structural probe reproduced the generated MLAB primitive and common-clock output-register arrangement with an independent memory scoreboard. It passed 12,297 cycles / 24,576 assertions, including 4,105 same-address collisions and 586 disabled-output cycles. Checks cover old-data samples and output stability away from the clock edge. The fitted RAM report leaves the RDW mode columns blank for this MLAB; it must not be described as a native OLD_DATA MLAB setting. The source and generated-structure tests support the registered interface behavior, but this is not a full mapped/post-fit netlist simulation or a proof of every hardware timing condition. Independent review of this transformation and eventual hardware validation remain appropriate before promotion.

The limited GHDL smoke independently compiles the original committed RegisterMemory and the MLAB-only candidate. Its handwritten scoreboard checks both against expected contents/read latency rather than comparing only their outputs or using SAVE-generated expectations. It passed 16,174 cycles and 48,524 independent checks across all nine entries, including normal/snapshot writes, collisions, registered-read stability, snapshot packing, initialization, reset, held pending normal writes, invalid snapshot addresses and the first unfreeze write. The source behavior is otherwise unchanged; the 889-million-checkpoint campaign was deliberately not repeated. This bank smoke does not rerun full musical/audio/legacy-wrapper campaigns.

All four GHDL invocations ran sequentially under an Idle-priority parent and were explicitly sampled at Idle. Every compile/run has retained stdout, stderr, priority samples and exit code. The native mcode simulation required no external HDL compiler process. No unrelated process priorities or global scheduling settings were modified.

The vendor-model probe needed two harness corrections before its valid run: linking Intel's `altera_lnsim_ver` library, and marking power-up memory locations as unspecified until first written. The latter avoids assuming that Intel's zero-initialized model must match the RTL's uninitialized U/X values before the normal initialization writes. Every post-initialization defined read remains checked exactly. Earlier failed setup/oracle logs are retained alongside the final `collision_valid.log`; they are not reported as passing runs. Final vendor-model logs show zero errors/warnings and the explicit PASS marker. The runner checks logs as well as exit status because ModelSim can return zero after `$fatal` when a DO file subsequently quits with code zero.

The Analysis & Synthesis gate found a genuine MLAB RAM row, 198 useful MLAB bits, 43 local ALUTs and 27 mapped local registers, with no unsupported-inference warning. Generated RAM/clock/output structure and the vendor collision probe were inspected before fitting; `physical_seed2/synthesis_gate.json` records the decision and hashes. This justified continuing the same Seed 2 run through fit/asm/sta. No synthesis retries, extra seeds or RTL restructuring occurred.

Critical setup paths, all under the HDMI PLL counter-0 output clock:

- Logic reference: scaler `o_v_poly_t.r1[25]` to `o_v_poly_pix.r[7]`, +0.367 ns.
- AUTO: scaler `o_hcpt[3]` to `o_vcpt_pre3[9]`, +0.090 ns.
- MLAB: scaler line-buffer RAM `o_line0[0].r[7]__2/.../ram_block1a0~PORT_B_WRITE_ENABLE_REG` to `o_vpix_inner[0].r[7]`, +0.396 ns, 4.647 ns data delay, -1.489 ns skew, two logic levels.

No new timing violation involves RegisterMemory. Worst targeted MLAB setup queries are +7.249 ns from RegisterMemory and +7.659 ns to it; from/to FM are +4.442/+1.182 ns, from/to PhaseMemory +7.701/+8.476 ns, and from/to snapshot +4.342/+7.125 ns. All setup, hold, recovery, removal and minimum pulse-width summary groups are nonnegative. The whole core clock group has +0.650 ns setup slack. Full routed paths are retained in `physical_seed2/candidate/physical_*.rpt`.

The matched constraints retain existing external I/O limitations: zero illegal/unconstrained clocks, 27 unconstrained input ports (94 paths), 91 unconstrained output ports (153 paths). Consequently, positive WNS/TNS describes constrained analysis, not complete external I/O timing coverage. No constraints were relaxed. This single seed does not establish a timing improvement across placements; prior AUTO seed results already demonstrate placement sensitivity in HDMI logic.

Warnings are identical to the logic reference after normalizing build paths and source line numbers: 67 warning messages, including 38 critical power-up messages, with no added/removed normalized warning. No new latch, multiple-driver, width, unsupported RAM or collision warning was found. Existing ignored power-up levels, stuck SDRAM pins and connectivity width diagnostics remain. The raw DONT_CARE primitive parameter is a reported architectural distinction, not a new warning to ignore. PhaseMemory, snapshot scratch RAM, EnvelopeMemory, VoiceMemory and all other fitted memory modes/shapes/block counts are unchanged from the full-state reference after normalizing locations/generated names.

Final fitter interconnect totals are 30.9% average and 46.6% peak, versus logic 31.5%/51.0% and AUTO 30.5%/49.6%. These use final fitter fields, not earlier router estimates. MLAB does not dominate AUTO on every resource metric: it improves needed ALMs and M10K use, while placed ALMs and fitted registers are higher.

Configuration and preservation:

- Quartus Prime Lite 17.0.2 Build 602, Cyclone V `5CSEBA6U23I7`, project/revision `SMS`, top `sys_top`, Seed 2, existing QPF/QSF/QIP/SDC settings and dependencies. Dependency `mist/mist-modules` remains at `9bf1ea25deffe35159cec8762a4f689c1db74a8b`.
- The full-state archived Seed 2 `candidate` is the logic comparator. Its original native report hashes were checked. All 133 production/integration files represented there were compared with commit `98737615` allowing only line-ending normalization; all 221 frozen inputs were verified before and after compilation. The MLAB-only attribute is the sole frozen-input difference from the logic reference and from AUTO's corresponding attribute choice.
- Expanded global/instance assignments and fitter settings match the full-state reference exactly. Native reports show RegisterMemory and `rtl/opll_snapshot.sv` actually used. Original tool executable hashes were checked. The reference's `BUILD_DATE=261104` was retained deliberately; this compilation actually ran on November 7.
- Outputs are isolated in `physical_seed2/candidate`, outside every worktree. `map.ps1` ran synthesis once, followed by the gated `continue.ps1` for fit/asm/sta. Every stage exited zero. Read-only settings/timing queries left native reports unchanged.
- Master and all previously existing worktree HEADs/tracked diffs/status passed preservation checks. Archived full-state and AUTO report hashes and frozen inputs passed verification. The committed full-state, AUTO, mixer candidates, old minimal worktree and sys were not edited. No commits, merges, pushes, PRs or hardware tests were performed.

Exact build identification:

- Baseline commit: `9873761503510e4b2c7e06600bf5515344235c2f`, plus the uncommitted one-line diff above.
- Frozen 221-input aggregate SHA-256: `9ee54a99201c4e9e370ff4c2e15cdb75f12837a62020a843c8d7afef8f9b2726` (sorted path/hash pairs). Per-file and Quartus tool hashes are in `physical_seed2/inputs.json`.
- Retained RBF: `physical_seed2/SMS_YM2413_REGMEM_MLAB_104W_v17_98737615_src9ee54a99201c_Q17.0.2_seed2_TIMING_PASS_0853f7d54caa.rbf`.
- RBF size: 4,177,232 bytes.
- RBF SHA-256: `0853f7d54caa8f4fe82f23696cda97d1dc926be991d11a2eebb9dde149a5ef7f`.
- Exact memory/parameter/hierarchy rows, timings, warning differences and comparison deltas are in `physical_seed2/results.json`; the compact comparison is `results.json`. `artifact_hashes.json` records retained evidence hashes. Generated database primitives, logs, scripts and native reports remain available.

Recommendation: MLAB offers the better balanced trade-off in this measured seed when conserving M10Ks matters: it reduces logic/register use versus the logic baseline and retains all 64 free M10Ks, while meeting timing with +0.396 ns margin. AUTO still has the lower placed-ALM/register count. Keep MLAB isolated for independent review, particularly of the DONT_CARE raw primitive plus registered-output transformation. Neither multi-seed robustness nor manual hardware functionality is established here. Stop at this measurement; no automatic follow-on experiment or hardware testing.
