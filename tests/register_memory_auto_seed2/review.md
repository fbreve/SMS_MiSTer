# RegisterMemory AUTO: independent seed-2 confirmation

**Recommendation: retain the independent experiment; do not promote it to production based on these results.** All functional qualification passes and the whole-design area reduction repeats, but setup margin degrades in both matched seeds (−0.362/−0.432 ns), leaving only **+0.019 ns (19 ps)** in seed 2. Setup/hold TNS remains zero. Timing passes under the existing constraints, but the measured loss of margin merits investigation before adoption. Hardware FM/save-load validation is also outstanding. No further experiment or RTL change was performed.

See the [complete two-seed whole-design table](combined_comparison.md) and [seed-1 report](../register_memory_auto/review.md).

Baseline 8443a0d19a88aff7a5900011bccf386daf146945; branch experiment/registermemory-auto-inference. Only RegisterMemory's logic attribute is removed. PhaseMemory remains original. See [seed-1 report](../register_memory_auto/review.md) for storage semantics, exact RTL line, full functional qualification and reproduction. This pair starts from fresh source copies; SMS.qsf seed 1→2 is the only difference from the qualified seed-1 inputs in both variants. No simulation results are relabeled as new seed-2 runs.

## Whole-design measured comparison

| Metric | Fresh baseline | AUTO candidate | Candidate - baseline |
| --- | ---: | ---: | ---: |
| Needed ALMs | 26489 | 26160 | -329 |
| Placed ALMs | 31545 | 31257 | -288 |
| Mapped registers | 34857 | 34637 | -220 |
| Fitted registers | 35772 | 35426 | -346 |
| Logic ALUTs | 37057 | 36509 | -548 |
| Routing ALUTs | 13184 | 13203 | +19 |
| M10Ks | 487 | 488 | +1 |
| MLAB cells | 0 | 0 | +0 |
| MLAB memory bits | 0 | 0 | +0 |
| Logical memory bits | 3809858 | 3810056 | +198 |
| DSPs | 39 | 39 | +0 |
| Setup slack (ns) | 0.451 | 0.019 | -0.432 |
| Hold slack (ns) | 0.243 | 0.24 | -0.003 |

Both fresh variants completed map/fit/asm/sta successfully. Effective seed 2, fixed BUILD_DATE 261014, Quartus Prime Lite 17.0.2 Build602, device 5CSEBA6U23I7, SMS/sys_top and original constraints/settings are verified. Setup TNS A/B: 0/0 ns; hold TNS A/B: 0/0 ns. Reported violation summary counts A/B: 0/0. Every clock/type slack and TNS is retained in results.json. These results apply to the project's existing constraint coverage, not unconstrained paths.

## Physical memory and local hierarchy evidence


Baseline RegisterMemory hierarchy row (needed ALMs, placed ALMs, combinational logic ALUTs, memory ALUTs, dedicated registers and other columns in original fitter order):

```text
|RegisterMemory:u_register_memory| ; 87.7 (87.7) ; 152.6 (152.6) ; 64.9 (64.9) ; 0.0 (0.0) ; 0.0 (0.0) ; 110 (110) ; 228 (228) ; 0 (0) ; 0 ; 0 ; 0 ; 0 ; 0 ; |sys_top|emu:emu|system:system|opll:fm|controller:ct|RegisterMemory:u_register_memory ; RegisterMemory ; work
```

AUTO RegisterMemory hierarchy row (needed ALMs, placed ALMs, combinational logic ALUTs, memory ALUTs, dedicated registers and other columns in original fitter order):

```text
|RegisterMemory:u_register_memory| ; 14.9 (14.9) ; 15.8 (15.8) ; 0.9 (0.9) ; 0.0 (0.0) ; 0.0 (0.0) ; 32 (32) ; 7 (7) ; 0 (0) ; 198 ; 1 ; 0 ; 0 ; 0 ; |sys_top|emu:emu|system:system|opll:fm|controller:ct|RegisterMemory:u_register_memory ; RegisterMemory ; work
```

Candidate fitted RAM: emu:emu|system:system|opll:fm|controller:ct|RegisterMemory:u_register_memory|altsyncram:regs_array_rtl_0|altsyncram_2tp1:auto_generated|ALTSYNCRAM; type AUTO, mode Simple Dual Port, clock mode Single Clock, logical geometry 9×24 / 9×24, payload 216 bits, implementation 198 bits, M10K 1, MLAB 0, location M10K_X76_Y22_N0, mixed-port read-during-write Old data. Fitter MLAB eligibility: No - Unsupported Mixed Feed Through Setting. Baseline has no RegisterMemory RAM row. Physical evidence is SMS.fit.rpt, Fitter RAM Summary.

Whole-design M10K occupancy is 487/553 (88.07%) → 488/553 (88.25%), leaving 65 blocks. The RTL payload is 216 bits; the fitted implementation is 9?22=198 bits and uses 1.93% of one nominal 10,240-bit M10K. VM2413 CONV_REGS_VECTOR writes zero to bits 15:14 and CONV_REGS does not consume them (vm2413.vhd:154?165); the two added synthesized-away RAM-node warnings correspond to those columns. This is expected whole-design pruning, while the standalone mapped bank test covers all 24 external data bits. AUTO chose this implementation under the original collision semantics; no forced MLAB/M10K experiment was attempted. The one-line removal releases an explicit implementation restriction; high-confidence root cause is forced logic storage, not a failed inference template.

## Interconnect utilization

Final fitter averages/peaks (total/horizontal/vertical) and resource counts are preserved below. Router interim estimates are excluded.

Baseline:

```text
; Average interconnect usage (total/H/V)                      ; 29.1% / 29.4% / 28.4% ;       ;
; Peak interconnect usage (total/H/V)                         ; 47.3% / 46.3% / 51.1% ;       ;
; Block interconnects                         ; 104,998 / 289,320 ( 36 % ) ;
; C12 interconnects                           ; 2,747 / 13,420 ( 20 % )    ;
; C2 interconnects                            ; 30,375 / 119,108 ( 26 % )  ;
; C4 interconnects                            ; 17,949 / 56,300 ( 32 % )   ;
; Local interconnects                         ; 20,501 / 84,580 ( 24 % )   ;
; R14 interconnects                           ; 3,071 / 12,676 ( 24 % )    ;
; R3 interconnects                            ; 41,356 / 130,992 ( 32 % )  ;
; R6 interconnects                            ; 65,900 / 266,960 ( 25 % )  ;
```

AUTO:

```text
; Average interconnect usage (total/H/V)                      ; 29.6% / 30.1% / 28.3% ;       ;
; Peak interconnect usage (total/H/V)                         ; 45.3% / 45.7% / 51.7% ;       ;
; Block interconnects                         ; 104,993 / 289,320 ( 36 % ) ;
; C12 interconnects                           ; 2,723 / 13,420 ( 20 % )    ;
; C2 interconnects                            ; 30,471 / 119,108 ( 26 % )  ;
; C4 interconnects                            ; 17,892 / 56,300 ( 32 % )   ;
; Local interconnects                         ; 19,660 / 84,580 ( 23 % )   ;
; R14 interconnects                           ; 3,300 / 12,676 ( 26 % )    ;
; R3 interconnects                            ; 42,169 / 130,992 ( 32 % )  ;
; R6 interconnects                            ; 67,339 / 266,960 ( 25 % )  ;
```

## Warnings, validation and recommendation

Normalized warning differences: 3 added, 0 removed. Existing warning/critical-warning types, uninferred RAM messages and unconstrained-path information remain in results.json; no claim is made that this experiment fixes unrelated warnings. All seven seed-1 functional runs pass. Seed-2 implementation, if present, reuses this logical qualification only after verifying the same RTL inputs and memory parameters. Hardware audio/game execution and post-route timing simulation have not been performed.

**Recommendation: retain the independent experiment; do not promote it to production based on these results.** All functional qualification passes and the whole-design area reduction repeats, but setup margin degrades in both matched seeds (−0.362/−0.432 ns), leaving only **+0.019 ns (19 ps)** in seed 2. Setup/hold TNS remains zero. Timing passes under the existing constraints, but the measured loss of margin merits investigation before adoption. Hardware FM/save-load validation is also outstanding. No further experiment or RTL change was performed.

Preservation: 213 protected evidence files and 126 branch refs match; no preservation mismatch. Original worktree retains its PhaseMemory-only uncommitted experiment. The new isolated worktree has only RegisterMemory's attribute deletion. No commits, merge, push, PR, master/v19 changes or hardware installation were performed. Databases and source build copies are ignored. See final_validation.json for exact states and RBF hashes, production.diff for the edit, results.json for full measurements and workflow.log for stage exits.

## Cross-seed interpretation and stopping point

Worst setup is in the HDMI PLL output-clock domain in all four reports. The global slack loss is measured; its detailed physical-path cause is unverified, and no claim is made that RegisterMemory itself is the critical HDMI path. A timing-path/placement investigation is recommended before production adoption. This experiment ends here, with no additional RTL or constraint change. Routing ALUTs increase by 51/19 and average total interconnect by 0.7/0.5 percentage points in seeds 1/2. Global total peak interconnect decreases, but seed-2 vertical peak rises 51.1%→51.7%; routing is a tradeoff, not an overall improvement.

Both newly compiled controls reproduce their respective retained seed controls exactly for every compared global resource count and setup/hold slack (baseline_control.json in each experiment). The full mapped parameter section, fitted RAM geometry excluding placement location, generated inputs, mapped register counts and memory-bit counts match across seeds; cross_seed_validation.json records this. The seven seed-1 simulation results are reused explicitly after those checks.

For reproduction, run write_summary.js after measure.js, verify_pair.js and the seed-1 finalize.js targeting this directory. It adds the combined table and this more conservative recommendation based on the observed 19 ps setup margin. All source manifests and original result measurements remain intact.
