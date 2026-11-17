# Independent RegisterMemory AUTO inference experiment

Seed-1 result: all seven functional checks pass. Whole-design AUTO deltas are ?293 needed ALMs, ?275 placed ALMs, ?369 fitted registers, +1 M10K, +51 routing ALUTs. Setup margin declines from +0.508 to +0.146 ns; hold improves from +0.144 to +0.241 ns, with setup/hold TNS 0/0 in both. Average interconnect increases 28.9%?29.6%. This is an area gain with a material setup-margin tradeoff, not a general timing/routing improvement. The result qualifies the requested [fresh seed-2 confirmation](../register_memory_auto_seed2/review.md); retain the experiment until that result and hardware validation.

Baseline: `8443a0d19a88aff7a5900011bccf386daf146945`. Experimental branch: `experiment/registermemory-auto-inference`, isolated in `worktree/`. Fresh matched seed-1 compilation and all functional qualification are complete.

## Scope and storage semantics

The sole production edit deletes `attribute ramstyle of regs_array : signal is "logic";` at original `rtl/VM2413/registermemory.vhd:56`. The declaration and all functional VHDL remain unchanged. Both baseline and candidate retain original PhaseMemory, including its `logic` attribute. Neither master, v19 nor the previous experiments are modified.

RegisterMemory is nine words of 24 bits (216 payload bits). Legal addresses are 0–8; addresses 9–15 are out of bounds and are not a supported behavior. An asynchronous reset restarts only the initialization sequencer; it does not clear the payload asynchronously or update the output. The first nine rising clocks after release sequentially zero one word each and suppress normal writes. Reads are clocked; same-clock reads see old data, including initialization collisions. Output holds during reset and between rising clocks. Memory power-up values are unspecified before initialized; RTL unknowns are preserved in the RTL scoreboard. These semantics support a clocked RAM implementation.

## Functional validation

The independent bank scoreboard checks cycle-by-cycle pair equality, old-data reads, write priority, no asynchronous propagation, reset hold/interruption after every 0–9 initialization writes, all nine addresses, 24 walking payload bits, and deterministic random traffic. Native and Quartus-mapped bank tests each passed 100,819 cycles and 403,520 checks, with five unknown startup reads exercised. Mapped checks require equality for every baseline-defined value and allow unspecified initial hardware payload values.

Native full OPLL and full OPLL with only RegisterMemory replaced by its exported Quartus synthesis functional netlist each passed 946,616 cycles, all known, with 882,358 nonzero audio cycles, 16 instruments, nine channels, 32 rhythm keys, 1,152 freeze-phase cases and 19 reset interruption cuts. PhaseMemory remains original RTL. This is functional mapped simulation, not post-route timing simulation or a hardware run.

All seven qualification runs pass (see functional_results.json). The paired RTL savestate test covers eight roundtrips and 8,482,683 cycles, all 58 controller outputs, accepted DDR behavior, CPU/VDP/PSG restoration, SMS/System E, BIOS/cartridge, slots 0?3 and stalls. The mapped single-controller replay compares 2,222,128 audio samples across two representatives (SMS/cartridge/slot0 and stalled System E/BIOS/slot3), with 56,160 nonzero samples in both native and mapped passes. The full 900,000-cycle load flush is retained; only UI request cooldown is bypassed in the fixture. These tests check existing compatibility and FM freeze behavior; they do not add FM serialization or establish hardware behavior. Whole-design results follow below. See `fixture_notes.md` for caught preparation issues and retained unqualified logs. No interrupted attempt is counted as passing evidence.

## Reproducibility and preservation

All 203 source inputs are recorded in `input_manifest.json`; byte hashes differ only for RegisterMemory. Non-UTF8 Japanese comments are preserved through Latin-1 byte encoding. The original PhaseMemory worktree is untouched; the new worktree has only the RegisterMemory deletion. `verify_inputs.js` checks source scope, all six Quartus binary hashes against the prior experiment, 133 retained evidence files and 126 pre-existing branch refs. Build copies are fresh source-only trees and use Quartus Prime Lite 17.0.2 Build602, device 5CSEBA6U23I7, SMS/sys_top, seed 1, fixed BUILD_DATE 261014, original QSF/QIP/IP/SDC and packing/performance settings. Direct map/fit/asm/sta invocation bypasses only the date-generating preflow. Generated databases and worktrees are ignored. Detailed commands are in `reproduce.md`.

Standalone synthesis already recognizes an AUTO 9×24 simple dual-port RAM with mixed-port OLD_DATA behavior; `standalone_inference.txt` preserves the parameters. The 24 RAM segments in the exported standalone netlist are not a physical block count. Physical M10K/MLAB use and whole-design costs must be taken from completed fitter reports.

No merge, push, PR or hardware installation is authorized or performed. No additional bank or forced memory type is part of this experiment.

## Whole-design measured comparison

| Metric | Fresh baseline | AUTO candidate | Candidate - baseline |
| --- | ---: | ---: | ---: |
| Needed ALMs | 26465 | 26172 | -293 |
| Placed ALMs | 31531 | 31256 | -275 |
| Mapped registers | 34857 | 34637 | -220 |
| Fitted registers | 35709 | 35340 | -369 |
| Logic ALUTs | 37056 | 36509 | -547 |
| Routing ALUTs | 13159 | 13210 | +51 |
| M10Ks | 487 | 488 | +1 |
| MLAB cells | 0 | 0 | +0 |
| MLAB memory bits | 0 | 0 | +0 |
| Logical memory bits | 3809858 | 3810056 | +198 |
| DSPs | 39 | 39 | +0 |
| Setup slack (ns) | 0.508 | 0.146 | -0.362 |
| Hold slack (ns) | 0.144 | 0.241 | +0.097 |

Both fresh variants completed map/fit/asm/sta successfully. Effective seed 1, fixed BUILD_DATE 261014, Quartus Prime Lite 17.0.2 Build602, device 5CSEBA6U23I7, SMS/sys_top and original constraints/settings are verified. Setup TNS A/B: 0/0 ns; hold TNS A/B: 0/0 ns. Reported violation summary counts A/B: 0/0. Every clock/type slack and TNS is retained in results.json. These results apply to the project's existing constraint coverage, not unconstrained paths.

## Physical memory and local hierarchy evidence


Baseline RegisterMemory hierarchy row (needed ALMs, placed ALMs, combinational logic ALUTs, memory ALUTs, dedicated registers and other columns in original fitter order):

```text
|RegisterMemory:u_register_memory| ; 91.7 (91.7) ; 155.3 (155.3) ; 65.7 (65.7) ; 2.0 (2.0) ; 0.0 (0.0) ; 110 (110) ; 224 (224) ; 0 (0) ; 0 ; 0 ; 0 ; 0 ; 0 ; |sys_top|emu:emu|system:system|opll:fm|controller:ct|RegisterMemory:u_register_memory ; RegisterMemory ; work
```

AUTO RegisterMemory hierarchy row (needed ALMs, placed ALMs, combinational logic ALUTs, memory ALUTs, dedicated registers and other columns in original fitter order):

```text
|RegisterMemory:u_register_memory| ; 14.7 (14.7) ; 14.7 (14.7) ; 0.0 (0.0) ; 0.0 (0.0) ; 0.0 (0.0) ; 32 (32) ; 6 (6) ; 0 (0) ; 198 ; 1 ; 0 ; 0 ; 0 ; |sys_top|emu:emu|system:system|opll:fm|controller:ct|RegisterMemory:u_register_memory ; RegisterMemory ; work
```

Candidate fitted RAM: emu:emu|system:system|opll:fm|controller:ct|RegisterMemory:u_register_memory|altsyncram:regs_array_rtl_0|altsyncram_2tp1:auto_generated|ALTSYNCRAM; type AUTO, mode Simple Dual Port, clock mode Single Clock, logical geometry 9×24 / 9×24, payload 216 bits, implementation 198 bits, M10K 1, MLAB 0, location M10K_X76_Y9_N0, mixed-port read-during-write Old data. Fitter MLAB eligibility: No - Unsupported Mixed Feed Through Setting. Baseline has no RegisterMemory RAM row. Physical evidence is SMS.fit.rpt, Fitter RAM Summary.

Whole-design M10K occupancy is 487/553 (88.07%) → 488/553 (88.25%), leaving 65 blocks. The RTL payload is 216 bits; the fitted implementation is 9?22=198 bits and uses 1.93% of one nominal 10,240-bit M10K. VM2413 CONV_REGS_VECTOR writes zero to bits 15:14 and CONV_REGS does not consume them (vm2413.vhd:154?165); the two added synthesized-away RAM-node warnings correspond to those columns. This is expected whole-design pruning, while the standalone mapped bank test covers all 24 external data bits. AUTO chose this implementation under the original collision semantics; no forced MLAB/M10K experiment was attempted. The one-line removal releases an explicit implementation restriction; high-confidence root cause is forced logic storage, not a failed inference template.

## Interconnect utilization

Final fitter averages/peaks (total/horizontal/vertical) and resource counts are preserved below. Router interim estimates are excluded.

Baseline:

```text
; Average interconnect usage (total/H/V)                      ; 28.9% / 29.0% / 28.7% ;       ;
; Peak interconnect usage (total/H/V)                         ; 53.7% / 54.6% / 56.4% ;       ;
; Block interconnects                         ; 103,762 / 289,320 ( 36 % ) ;
; C12 interconnects                           ; 2,938 / 13,420 ( 22 % )    ;
; C2 interconnects                            ; 30,418 / 119,108 ( 26 % )  ;
; C4 interconnects                            ; 17,805 / 56,300 ( 32 % )   ;
; Local interconnects                         ; 21,414 / 84,580 ( 25 % )   ;
; R14 interconnects                           ; 2,973 / 12,676 ( 23 % )    ;
; R3 interconnects                            ; 41,189 / 130,992 ( 31 % )  ;
; R6 interconnects                            ; 65,416 / 266,960 ( 25 % )  ;
```

AUTO:

```text
; Average interconnect usage (total/H/V)                      ; 29.6% / 29.8% / 29.1% ;       ;
; Peak interconnect usage (total/H/V)                         ; 53.0% / 52.2% / 55.6% ;       ;
; Block interconnects                         ; 104,587 / 289,320 ( 36 % ) ;
; C12 interconnects                           ; 2,973 / 13,420 ( 22 % )    ;
; C2 interconnects                            ; 30,492 / 119,108 ( 26 % )  ;
; C4 interconnects                            ; 18,218 / 56,300 ( 32 % )   ;
; Local interconnects                         ; 19,479 / 84,580 ( 23 % )   ;
; R14 interconnects                           ; 3,238 / 12,676 ( 26 % )    ;
; R3 interconnects                            ; 42,220 / 130,992 ( 32 % )  ;
; R6 interconnects                            ; 67,083 / 266,960 ( 25 % )  ;
```

## Warnings, validation and recommendation

Normalized warning differences: 3 added, 0 removed. Existing warning/critical-warning types, uninferred RAM messages and unconstrained-path information remain in results.json; no claim is made that this experiment fixes unrelated warnings. All seven seed-1 functional runs pass. Seed-2 implementation, if present, reuses this logical qualification only after verifying the same RTL inputs and memory parameters. Hardware audio/game execution and post-route timing simulation have not been performed.

Seed 1 shows a credible whole-design area improvement with passing timing and functional evidence, qualifying the requested fresh seed-2 A/B confirmation. Keep this isolated experiment; assess seed 2 before recommending adoption.

Preservation: 133 protected evidence files and 126 branch refs match; no preservation mismatch. Original worktree retains its PhaseMemory-only uncommitted experiment. The new isolated worktree has only RegisterMemory's attribute deletion. No commits, merge, push, PR, master/v19 changes or hardware installation were performed. Databases and source build copies are ignored. See final_validation.json for exact states and RBF hashes, production.diff for the edit, results.json for full measurements and workflow.log for stage exits.
