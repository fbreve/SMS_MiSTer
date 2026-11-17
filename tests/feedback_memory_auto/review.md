**Recommendation: retain FeedbackMemory's forced-logic implementation. Stop after seed 1; do not run seed 2 or adopt this change.** The independent AUTO experiment is functionally qualified, but it fails the whole-design acceptance criteria: placed ALMs increase, setup margin falls by 218 ps (43%), and video retiming changes remain unexplained. No reproducible two-seed resource benefit is established.

The fresh control exactly reproduces the retained baseline's measured ALMs, registers, M10Ks, DSPs, logic/routing ALUTs and setup/hold minima. The full source-only baseline/AUTO pair completed all eight map/fit/asm/sta stages successfully with Quartus Prime Lite 17.0.2 Build 602, seed 1 and identical settings. Only `rtl/VM2413/feedbackmemory.vhd:57` differs: deletion of its forced-logic attribute. Original PhaseMemory and RegisterMemory are present in both build copies.

Local attribution improves: FeedbackMemory's needed/placed ALMs fall from 51.7/75.7 to 9.2/9.5 and its registers from 106 to 6. These fractional hierarchy attributions do not predict additive whole-design savings. Whole-design needed ALMs fall by only 19, placed ALMs rise by 5, and logic ALUTs rise by 26. One additional M10K is consumed for 90 bits. The fitter explicitly reports MLAB ineligibility: **No - Unsupported Mixed Feed Through Setting**. The actual implementation is a single-clock, simple dual-port 9-by-10 M10K at `M10K_X76_Y22_N0`, mixed-port **Old data**, with no MLAB. Total M10Ks become 488/553, leaving 65.

All seven functional qualifications passed. RTL and mapped-bank tests each made 864,600 checks across 216,114 cycles; native and mapped full-FM tests each ran 946,616 cycles. Native savestate testing passed eight restore cases over 8,482,683 cycles; native-reference and mapped savestate replays each passed 2,222,128 cycles, including 56,160 nonzero-audio checks. No functional or savestate regression was observed in this coverage. This is not formal enumeration of all 2^90 stored states, hardware validation, or post-route timing simulation.

Final setup/hold TNS is zero in both builds, and the normalized warning sets are identical (66 distinct warning lines, including 38 critical warnings). Positive slack alone does not satisfy the requested preservation of timing margin.

### HDMI/scaler evidence

Both worst paths are in the same HDMI output-clock domain, with the original 6.732 ns relationship and Slow 1100mV 100C model. The unchanged SDC was read into each newly fitted database. Source reports are [baseline_setup.rpt](baseline_setup.rpt), [candidate_setup.rpt](candidate_setup.rpt), the targeted `*_poly_lum.rpt` files, and [path_summary.json](path_summary.json).

| Worst setup path statistic | Baseline | AUTO |
| --- | ---: | ---: |
| Slack (ns) | 0.508 | 0.290 |
| Data delay (ns) | 3.626 | 5.774 |
| Data cell subtotal (ns) | 1.696 | 3.023 |
| Data routing subtotal (ns) | 1.928 | 2.751 |
| Clock skew (ns) | -2.398 | -0.468 |
| Logic levels | 2 | 4 |

Baseline's worst path starts at the scaler line-buffer RAM `ascal:ascal|altsyncram:o_linf2[0].r[7]__8|altsyncram_m6n1:auto_generated|ram_block1a0~PORT_B_WRITE_ENABLE_REG` and ends at `ascal:ascal|o_vpix_inner[0].r[7]`. AUTO's starts at `ascal:ascal|o_hcpt[0]` and ends at `ascal:ascal|o_vcpt[6]`. These are different paths: their delay differences cannot be attributed to a single unchanged cone. Report rounding and small additional terms can prevent the displayed cell/routing subtotals from summing exactly to reported data delay.

Physical-retiming report entries change from 708 to 697 overall, 383 to 377 in the scaler, and 49 to 45 in the luminance families. First-pass estimated retiming benefit changes from 279 to 73 ps. This is **not** RegisterMemory AUTO's complete loss of physical retiming: the FeedbackMemory candidate still has 697 entries and retimed luminance endpoints. Nevertheless the video transformation set differs, and the mechanism selecting a different set is not established here.

The targeted `o_vpix_inner` to `o_poly_lum` family actually improves in its worst reported slack, from 0.533 to 1.160 ns, while the global scaler worst case deteriorates. Thus the evidence does not support claiming that luminance retiming loss directly caused the 218 ps regression. It supports an indirect whole-design physical-optimization/placement change; proving its specific cause would require further investigation. No timing fix or additional experiment was attempted.

Final fitter interconnect results also differ from the earlier router estimates:

| Final interconnect utilization (total / horizontal / vertical) | Baseline | AUTO |
| --- | --- | --- |
| Average | 28.9% / 29.0% / 28.7% | 29.8% / 29.9% / 29.5% |
| Peak | 53.7% / 54.6% / 56.4% | 48.7% / 50.5% / 61.2% |

Average use rises despite fewer routing ALUTs; vertical peak use also rises. Router estimates of 25% average and 46%/42% peak are preliminary and are not the final utilization values above.

### Acceptance and stopping decision

| Criterion | Result |
| --- | --- |
| No functional/savestate regression | Passed the stated simulation coverage |
| Reproducible whole-design resource savings | Not established; seed 1 placed area increases |
| No material timing-margin loss | Failed: setup slack decreases 218 ps |
| No unexplained video-retiming loss | Not satisfied: fewer scaler/luminance entries, mechanism unresolved |

The unfavorable result does not depend on the conservative 50 ps second-seed screening threshold: it also fails placed-area savings and video-retiming preservation. Under the user's conditional seed-2 instruction, a second seed is not warranted. No cross-seed consistency claim is made.

Preservation checks match all 8,828 protected existing files and 127 branch references, including the retained fitted databases and prior reports. Master and v19 remain unchanged. The new `experiment/feedbackmemory-auto-inference` branch points to `8443a0d19a88aff7a5900011bccf386daf146945`; its separate worktree contains only the uncommitted attribute deletion. The original PhaseMemory and RegisterMemory worktrees retain their previous edits. No commit, push, merge or PR was made. Both new fitted databases are retained and ignored by Git. The experiment stops here.

The generated measurements and qualification details follow.


# Independent FeedbackMemory AUTO inference: seed 1

Baseline8443a0d19a88aff7a5900011bccf386daf146945; isolated branch experiment/feedbackmemory-auto-inference. Only feedbackmemory.vhd's forced-logic attribute is removed. PhaseMemory and RegisterMemory remain original in both variants. No fitter or timing-constraint change.

**Unfavorable screening: do not adopt or run another optimization experiment under this task.** The criteria and measured limits below explain the decision.

[Stage-1 semantics and feasibility](../feedback_memory_auto/feasibility.md) document the9×10 payload, independent addresses, reset/init priority, clocked OLD_DATA reads and risks. The local baseline attribution is an estimate of opportunity; the complete whole-design results below are the implementation evidence.

## Functional qualification

- bank: # ** Note: PASS bank equivalence: cycles=216114 checks=864600 unknown_reads=5 all81 port pairs x1024 payloads xwrite/read phases;10 reset interruption cuts
- gate: # ** Note: PASS mapped bank equivalence: cycles=216114 checks=864600 unknown_reads=5 all81 port pairs x1024 payloads xwrite/read phases;10 reset interruption cuts
- fm: # ** Note: PASS full OPLL: cycles=946616 known=946616 nonzero=882358 freeze_phases=1152 instruments=16 channels=9 rhythm_keys=32 reset_cuts=19
- fm_gate: # ** Note: PASS full OPLL with mapped candidate FeedbackMemory: cycles=946616 known=946616 nonzero=882358 freeze_phases=1152 instruments=16 channels=9 rhythm_keys=32 reset_cuts=19
- savestate: # PASS savestate/FM paired regression cycles=8482683 audio_checks=8482683 outputs=58 operations=16 restored=8 DDRwrites=57580 DDRreads=57564 busy=218975 SMS/SystemE BIOS/cart slots0..3
- savestate_gate_reference: # PASS savestate/FM mapped FeedbackMemory regression cycles=2222128 audio_checks=2222128 paired_controllers=0 operations=4 restored=2 DDRwrites=14395 DDRreads=14391 busy=58305 SMS/SystemE BIOS/cart slots0..3 # Nonzero audio checks=56160 REF=1
- savestate_gate: # PASS savestate/FM mapped FeedbackMemory regression cycles=2222128 audio_checks=2222128 paired_controllers=0 operations=4 restored=2 DDRwrites=14395 DDRreads=14391 busy=58305 SMS/SystemE BIOS/cart slots0..3 # Nonzero audio checks=56160 REF=0

RTL and mapped bank tests exhaust all81 legal write/read address pairs and1024 data patterns with both write/read phases, reset interruptions after0–9 initialization writes, reset hold, old-data collisions, signed zero encodings, undefined startup reads and output-latency checks. This is exhaustive input/transition coverage, not enumeration of2^90 global states or formal mapped-netlist proof. The simulation-only flat adapter packs/unpacks records and converts addresses through typed wires; no added register or production wrapper is used. The exported Quartus top module is renamed only. Defined baseline outputs must match mapped hardware; unspecified startup data may differ.

Native and mapped full OPLL cover real nonzero FM, all instruments/channels/rhythm and freeze phases. Eight paired savestate cases compare58 outputs and accepted DDR behavior with CPU/VDP/PSG restoration, SMS/SystemE, BIOS/cart, slots0–3 and stalls. Mapped replay uses two real-controller representatives and a native audio oracle, with nonzero coverage and original900000-cycle load flush. ModelSim compatibility adapters and UI cooldown bypass follow the retained experiments. Initial rejected flat-adapter attempts are documented in fixture_notes.md and are excluded from qualification. No hardware or post-route timing simulation was performed. Seed2, if present, explicitly reuses seed1 logical tests only after checking the same RTL and mapped memory parameters.

## Whole-design comparison

| Metric | Fresh baseline | AUTO candidate | Candidate - baseline |
| --- | ---: | ---: | ---: |
| Needed ALMs | 26465 | 26446 | -19 |
| Placed ALMs | 31531 | 31536 | +5 |
| Mapped registers | 34857 | 34757 | -100 |
| Fitted registers | 35709 | 35649 | -60 |
| Logic ALUTs | 37056 | 37082 | +26 |
| Routing ALUTs | 13159 | 13082 | -77 |
| M10Ks | 487 | 488 | +1 |
| MLAB cells | 0 | 0 | +0 |
| MLAB memory bits | 0 | 0 | +0 |
| Logical memory bits | 3809858 | 3809948 | +90 |
| DSPs | 39 | 39 | +0 |
| Setup slack (ns) | 0.508 | 0.29 | -0.218 |
| Hold slack (ns) | 0.144 | 0.243 | +0.099 |

Setup TNS A/B: 0/0 ns; hold TNS A/B: 0/0 ns. All per-clock slacks/TNS, warnings and report hashes remain in results.json. Setup/hold changes are -0.218/0.099 ns. Screening for another seed conservatively requires no more than50ps loss in either global minimum, zero reported violations, area savings, and no scaler/luminance retiming loss; this is a screening rule, not production signoff.

## Physical storage and retiming

baseline: Register retiming report entries whole/scaler/luminance=708/383/49. Transformation entries are not fitted FF counts. FeedbackMemory hierarchy in original report column order:

```text
|FeedbackMemory:Fmem| ; 51.7 (51.7) ; 75.7 (75.7) ; 25.3 (25.3) ; 1.3 (1.3) ; 0.0 (0.0) ; 63 (63) ; 106 (106) ; 0 (0) ; 0 ; 0 ; 0 ; 0 ; 0 ; |sys_top|emu:emu|system:system|opll:fm|OutputGenerator:og|FeedbackMemory:Fmem ; FeedbackMemory ; work
```

candidate: Register retiming report entries whole/scaler/luminance=697/377/45. Transformation entries are not fitted FF counts. FeedbackMemory hierarchy in original report column order:

```text
|FeedbackMemory:Fmem| ; 9.2 (9.2) ; 9.5 (9.5) ; 0.3 (0.3) ; 0.0 (0.0) ; 0.0 (0.0) ; 20 (20) ; 6 (6) ; 0 (0) ; 90 ; 1 ; 0 ; 0 ; 0 ; |sys_top|emu:emu|system:system|opll:fm|OutputGenerator:og|FeedbackMemory:Fmem ; FeedbackMemory ; work
```

Candidate fitted bank: AUTO Simple Dual Port, Single Clock, geometry9×10, physical bits90, M10Ks1, MLABs0, locationM10K_X76_Y22_N0, mixed-port RDWOld data, MLAB eligibilityNo - Unsupported Mixed Feed Through Setting. Baseline has no FeedbackMemory hard-RAM row. Total M10K use 487/553→488/553, leaving65 blocks. Standalone and whole-design inference parameters are retained; small payload utilization alone is not a reason to claim block RAM is preferable.

baseline final interconnect/routing:

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

candidate final interconnect/routing:

```text
; Average interconnect usage (total/H/V)                      ; 29.8% / 29.9% / 29.5% ;       ;
; Peak interconnect usage (total/H/V)                         ; 48.7% / 50.5% / 61.2% ;       ;
; Block interconnects                         ; 104,990 / 289,320 ( 36 % ) ;
; C12 interconnects                           ; 3,073 / 13,420 ( 23 % )    ;
; C2 interconnects                            ; 31,140 / 119,108 ( 26 % )  ;
; C4 interconnects                            ; 18,195 / 56,300 ( 32 % )   ;
; Local interconnects                         ; 20,488 / 84,580 ( 24 % )   ;
; R14 interconnects                           ; 3,237 / 12,676 ( 26 % )    ;
; R3 interconnects                            ; 41,958 / 130,992 ( 32 % )  ;
; R6 interconnects                            ; 67,058 / 266,960 ( 25 % )  ;
```

Detailed HDMI/scaler evidence is baseline_setup.rpt / candidate_setup.rpt and targeted *_poly_lum.rpt, extracted from these fitted databases using the original SDC and Slow1100mV100C model. No false path or clock change was added. The original RegisterMemory experiment's retiming regression is a specific rejection criterion here, not an accepted area tradeoff.

## Warnings, reproducibility and status

Normalized warning differences: 0 added, 0 removed; exact lines are in results.json. Fresh source-only map/fit/asm/sta used Quartus17.0.2 Build602,5CSEBA6U23I7,SMS/sys_top, seed1,fixed BUILD_DATE261014 and original QIP/IP/SDC/performance/packing settings. Physical effort is Normal; the unsuccessful RegisterMemory Extra-effort control is not included.

Preservation: 8828 protected files, including retained reports/fitted databases, and127 branch refs match with zero mismatches. Experimental edit remains uncommitted in its separate worktree. Existing PhaseMemory and RegisterMemory worktrees, v19 and master are unchanged. No merge, push, PR or commit. Generated source trees/databases are ignored. See input_manifest.json, workflow.log, results.json and validation.json. Stop after this unfavorable seed or the requested favorable two-seed comparison; no timing fix or other bank experiment is performed.
