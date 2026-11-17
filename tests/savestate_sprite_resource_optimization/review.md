# G06/G10 sprite snapshot resource optimization

**NO SAFE MATERIAL OPTIMIZATION FOUND**

The tested low-risk extraction is cycle-equivalent but does not recover FPGA area: placed ALMs rise 39001->39048 (+47), and needed ALMs rise 36300->36406 (+106). The parallel-mask variant also worsens standalone synthesis. Production RTL and v16 remain unchanged.

## 1. Current HEAD

`cb2e8615128d61adb996ada68e6bbdcc314c20f6`, branch `optimize/savestate-sprite-resources`. HEAD unchanged; nothing staged, committed, pushed or published.

## 2. Current v16 confirmation

v16 / HC tag 0x484310, original 96KiB container. Both 4778-bit records,22-bit high padding,75 words per record, descriptor/phase/ownership/consumption fields, field meanings, read/write addresses and all accepted legacy formats are unchanged. No format consolidation or new historical state. The exact format and transport equivalence test passes 911 original format scenarios.

## 3. Current baseline resources

Committed post-G12:36300 needed /39001 placed ALMs of 41910; 48428 fitted FF of 167640; 45808 synthesis registers; 487/553 M10K; 3809858/5662720 bits; 39/112 DSP; setup+0.465 ns, hold+0.198 ns,0 reported failing timing checks. Full controlled experiment uses the same Quartus 17.0.2 Build 602,5CSEBA6U23I7, SMS/sys_top, MISTER_FB=1, seed 1, QSF/SDC/IP/performance/packing settings and generated build date.136 input hashes are checked; 134 match committed source, two are unchanged unused backups. A fresh candidate database is used. The retained baseline was source-verified; no fresh baseline fit was necessary. [Build evidence](build_results.json), [input hashes](build_inputs.json).

## 4. G06/G10 resource attribution

The exact 8ffd15e→5858318 diff is [g06_g10.diff](g06_g10.diff). [attribution.md](attribution.md) gives a diff-level map of purpose, width, fanout, storage/combinational structure and continuing necessity. G06 functional history: 9556 useful snapshot bits,9600 padded FF plus distributed live restore selectors. G10 stores two phase bits and one consumed-T bit, with additional preparation/handshake/control logic. Whole change:+8051 needed/+5458 placed/+9603 mapped FF/+11171 fitted FF. Controller mapped FF+9601; top+2. The net 3 FF outside the banks is an aggregate after synthesis changes, not an isolated G10 register cost. Fitted logic ALUT+5818, routing ALUT+5399. Packing gap shrinks 2593. Transport mux estimates8:1/9:1 over 4736 bits are pre-fit LE estimates, not independently removable physical ALMs. Version, freeze, restart and physical fanout costs overlap these cones; available hierarchy cannot isolate an exact ALM charge for each.

## 5. Sprite-state inventory

[Complete field inventory](attribution.md#complete-preserved-sprite-width): per slot enable1, X8, cached planes4x8, shift planes4x8, wideclock1 =74 bits; 64 slots =4736. Fixed fields: address14, mode2 flags8, registered color4, collide1, overflow1, collision delay14 =42. Every meaningful bit remains. Each 4778-bit live record uses 4800 transport bits; restore consumes4778. All 22 padding bits and absent second-bank zeros retain their validation. All cached planes and inactive history are retained across mode changes. Evaluator state/count/index normalization is unchanged; no new reachability assumption or semantic compression is introduced.

## 6. Transport topology

Live VDP record -> post-T ARM capture -> padded bank ->75 accepted low64-bit writes with rotation -> immutable image -> validated75 incoming64-bit LOAD insertions -> low4778 restore bus -> existing VDP strobe. SAVE returns the ring exactly to the captured representation. LOAD shifts out all prior Q after75 accepted words. The candidate shares the lower4736-bit shift and selects only the incoming64-bit head. DDRAM acceptance, latency and request generation are unchanged.

## 7. Restore-mux topology

Existing distributed register restore remains in vdp_sprites, vdp_sprite_shifter and vdp collision delay. Each register still selects saved/legacy-default/live behavior under the same strobes. This experiment does not centralize live restore, add staged guest updates, or alter evaluator/shifter logic. Main optimization target is the private snapshot input/transport mux, not a reduced live record.

## 8. Version-mux topology

has_restart/sprite_valid is already shared across the complete record. It selects deterministic legacy missing-history defaults; current formats preserve all sprite/phase fields. Descriptor, owner, padding, absent-device and malformed-image gates stay in the main FSM unchanged. Removing tag support or eliminating the public/current default distinction is not an authorized area optimization.

## 9. Fanout findings

Baseline top non-global controls include ARM9669, z80_set5898, vdp2_regs_set5426, LOAD_HDR5272, bank controls4800–4811, has_restart1415. The candidate factors accepted capture/clear/save/load events once and moves them to dedicated bank updates. Physical before/after fanout rows are retained in build_results.json; signal names may be merged or duplicated by synthesis. High fanout alone is not an additive ALM estimate. The peak changes from ARM9669 to sprite_capture9560 (-109). z80_set5898->5903; vdp2_regs_set5426->5464; has_restart1415->1432. Bank controls still drive4800 endpoints, and sprite_clear drives4778. This is not a material reduction in the wide-control regime.

## 10. Packing findings

Baseline A-B+C=39001-3225+524=36300 needed ALMs. Candidate 39048-3132+490=36406. Delta needed=+47-(-93)+(-34)=+106. Needed is the fitter packing-adjusted estimate, not a pure synthesis count. Synthesis registers remain45808; fitted register changes reflect physical duplication/retiming, not removal of guest history.

## 11. Candidate A: narrow common selection

Implemented in isolated candidate_A.sv: factor original accepted-edge predicates, combine SAVE and LOAD lower4736-bit movement, select only the incoming64-bit head, and describe bank updates outside the unrelated main FSM. Pure clock-level structural equivalence; no new state or transfer cycle. Standalone controller ALUT6161→6123,−38.

## 12. Candidate B: centralized live restore

Considered and deferred. A shared indexed restore bus would require changing receiver write enables/field organization across evaluator, shifters, fixed fields and collision delay. The existing private-bank extraction has a smaller proof surface. No synthesis saving for centralized live restore is claimed.

## 13. Candidate C: explicit enable / parallel masks

Isolated file candidate_B.sv uses shared register enable and parallel one-hot capture/shift data masks. Standalone controller ALUT rises 6161→15693 (**+9532**), with unchanged14819 registers. Reject at micro-synthesis; no production edit or board fit for this formulation. Shorter parallel RTL is not smaller hardware in this tool flow.

## 14. Candidate D: arrays/records

Considered word/bank organization. Preserve the constant75-word ring; avoid an indexed read/write crossbar. The original G06 indexed prototype failed congestion at 39680 needed, while the current sequential implementation used35419. That historical4261-needed difference is evidence of implementation sensitivity, not a new saving measured here. No unproved inactive-slot packing or record-width reduction is attempted.

## 15. Candidate E: shared version decode

Existing has_restart already centralizes version presence. Family A factors transport acceptance/control; it does not change version decoding or format validity. No extra independent version comparators are introduced. No compatibility-only resource saving is claimed.

## 16. Candidate F: separate transport representation

Implemented together with A as one structural change: private bank next-state logic is separated from the large FSM; live4778-bit record representation and all serialized bytes remain identical. Capture, clear, rotate, insert and hold remain the only bank transitions.

## 17. Candidate G: staged restore while frozen

Considered, not implemented. It could share data paths or permit RAM-backed transport, but must preserve all validation before early guest restore, freeze isolation, partial-state lifetime, legacy defaults and deterministic release. It changes more internal sequencing than the proven extraction. No stage count, resource saving or sufficiency proof is claimed for an unbuilt architecture.

## 18. Additional candidates

RAM-backed scratch storage requires width/port/banking analysis, not just9600 raw bits: simultaneous capture and full-width restore constrain migration. Removing scratch resets/default writes would require a separate before-first-consumer proof. Semantic reduction is not justified by missing regression coverage. These larger-risk alternatives are not silently combined with A. F01, F06 and OPLL/FM internals were not investigated.

## 19. Micro-synthesis results

|Standalone full controller|Mapped ALUT|Delta|Registers|
|---|---:|---:|---:|
|Baseline|6161|0|14819|
|A/F extracted priority process|6123|−38|14819|
|C parallel masks (file B)|15693|+9532|14819|

Same device, seed and relevant performance settings, virtual ports, source-only databases. These are not full-board fits or ALM estimates. Virtual-pin wildcard warnings are isolated to the micro projects. Full-board synthesis for A gives45004 combinational ALUT versus 45302 baseline (−298); controller own6547→6467 (−80), with unchanged14725 controller registers. The remaining logical delta is global mapping. [Machine ledger](simulation_results.json).

## 20. Selected candidate

A/F was the lower-risk experimental candidate selected for the full controlled fit. It remains an isolated experimental source; production RTL is unchanged. A had the smaller standalone synthesis result and the smallest proof surface. Its full controlled fit is not beneficial, so it is rejected rather than adopted. No additional speculative architecture is introduced to force a savings claim.

## 21. Exact RTL changes

No production RTL is retained as changed. The experimental delta removes bank assignments from reset, ARM, SAVE_SPRITE, LOAD_SPRITE and LOAD_HDR_RD and adds a dedicated bank process with identical reset/clear/capture/shift/hold transitions. No new registers, state numbers, descriptors, field encodings, clock/phase logic or live VDP/CPU/top-level RTL are changed. [Candidate source](candidate_A.sv), [baseline](baseline.sv).

## 22. Semantic-equivalence argument

[equivalence.md](equivalence.md) proves bank transition equality by mutually exclusive FSM events and induction. Common lower4736 bits are shifted identically; 64-bit head is the original selected low word or incoming LOAD word. Reset and invalid-image paths are preserved for binary physical inputs. Full miter: **95567723 clocks,95 outputs, all 9600 bank bits, exact FSM,911 format scenarios,16 profiles,48 LOADs**; no masked bus, word, initial resumed clock or transport interval. Separate focused gate: 9294437 clocks,532 format scenarios, same16 profiles/48 LOADs. Counts are separate overlapping campaigns, not independent coverage totals.

## 23. G06 regression

14/14 canonical scenarios passed. Full original matrix: zero, one, collision, near, overflow8, overflow9, terminated, tall, legacy graphics1/2, legacy tall, first visible, line transition, accelerated64. Preserve original arguments/oracles, SAVE-only and three LOADs. Reduced8-slot cases carry the established padded opaque reduced record; actual64-slot case and full-width controller miter establish full-record handling. The first-visible case retains its longer sample window. 

## 24. G10 regression

4/4 phase/stall/full-flush cases passed. Natural phase fixture uses 13 LOADs with 12 distinct legal pre-preparation divider histories and a repeat, without forcing the divider. First-native CPU/VDP/pixel/sprite enable ordering is checked for 60 host clocks; private replay holds live VDP/sprite state. G04 native monitoring checks every one of 10000 logical host clocks. Controller preparation/phase/beam outputs are additionally equal on every full-miter clock. No new CPU tick or hidden pixel delay.

## 25. G05 regression

1/1 targeted case passed: retained post-G08 original text-to-Mode4 history0,42000 pixel samples per suffix, SAVE-only plus three LOADs. ROM, reference, background audit, color, CPU and status assertions unchanged. Its8-slot no-sprite configuration is the established targeted test, not a full64-slot sprite-layout proof. [Scope and excluded support runs](g05_targeted_scope.md).

## 26. G02–G04 sanity

G02 1/1; G03 1/1; G04 1/1. G02 enabled IRQ/status handler preserves accepted-boundary pending-clear exclusion. G03 checks bus history/consumed data and ordered physical memory writes. G04 retains nonzero collision delay, IRQ, CPU230, VDP136, RAM and last_x0-after-first-enable native comparisons. Their source/boundary assumptions are unchanged; no new closure or reopening is inferred from an infrastructure pilot.

## 27. SAVE-only result

Every completed canonical DUT compares SAVE-only to its retained independent uninterrupted oracle before LOAD use. Phase/stall fixtures retain the original G06 full live-sprite/VDP/CPU transport-hold assertion. Private scratch rotation is expected; live guest state must remain frozen. No observable guest advance is introduced. See terminal dispositions in the case ledger; incomplete cases are not counted.

## 28. Transport-stall result

Transaction-qualified deterministic83/97 and LFSR13/16 backpressure plus native/no-stall and production900000-clock LOAD flush are preserved. All accepted bank updates use the original ddram_step, busy, response-latch and rejection predicates. Stalls cannot rotate/insert an extra word. Full-width randomized miter varies busy and read response latency and checks all 150 sprite words plus complete image immutability. Native phase/transport durations and hold markers are retained in the logs.

## 29. LOAD result

Complete current images and every restored full-width record match committed baseline in the miter. Actual VDP RTL simulations use the same live restore paths and strict pixel/status/CPU/RAM oracles. No tolerance, first-pixel grace, two-pixel realignment or changed field interpretation. Only completed passing case logs establish runtime results.

## 30. Repeated-LOAD result

Each original G06 scenario has three LOADs; natural phase test has 13. Guest-Q perturbation 1/1: real NMI handler changes VRAM/CRAM/scroll/mode history with distinct seeds before identical-image replay. G04 additionally asserts pairwise-distinct CPU/VDP perturbation states. Dual-VDP IRQ case 1/1 uses distinct device state and three LOADs. Full controller randomized matrix checks 48 repeated LOADs after differing full-width Q records and immutable images.

## 31. Format compatibility

Full current-format suite passes **512 malformed rejections and399 accepts =911 scenarios**, including genuine old 64KiB and tagged1..15 handling, descriptor/owner/reserved bits, both sprite padding fields, absent second-device payload and BG positions/one-hots. No validation is removed or delayed. The later16 profiles exercise all four phase classes, two ownership modes and consumed/stopped metadata combinations with independent random full records. Some metadata combinations are protocol tests, not claims of natural reachability.

## 32. ALMs needed

36,300 /41,910 (86.614%) -> 36,406 /41,910 (86.867%); delta **+106**. These after-values describe the measured isolated A fit; the production baseline remains unchanged.

## 33. ALMs placed

39,001 /41,910 (93.059%) -> 39,048 /41,910 (93.171%); delta **+47**. These after-values describe the measured isolated A fit; the production baseline remains unchanged.

## 34. Placed ALMs recovered

**-47** versus 39001. No ALMs recovered: the experimental fit uses 47 additional sites. The retained production implementation stays at 39001 placed ALMs, not39048.

## 35. Percentage of G06/G10 placement growth recovered

**-0.861%** of the historical+5458 placed-ALM increase. Signed recovery is reported; negative means more sites used. This is a whole-design same-config fit delta, not an isolated intrinsic cost per saved bit.

## 36. Fitted registers

48,428 /167,640 (28.888%) -> 48,362 /167,640 (28.849%); delta **-66**. These after-values describe the measured isolated A fit; the production baseline remains unchanged.

## 37. M10K

487 /553 (88.065%) -> 487 /553 (88.065%); delta **0**. These after-values describe the measured isolated A fit; the production baseline remains unchanged.

## 38. Memory bits

3,809,858 /5,662,720 (67.280%) -> 3,809,858 /5,662,720 (67.280%); delta **0**. These after-values describe the measured isolated A fit; the production baseline remains unchanged.

## 39. DSP

39 /112 (34.821%) -> 39 /112 (34.821%); delta **0**. These after-values describe the measured isolated A fit; the production baseline remains unchanged.

## 40. Setup before/after

+0.465 ns -> +0.360 ns; delta -0.105 ns.

## 41. Hold before/after

+0.198 ns -> +0.196 ns; delta -0.002 ns.

## 42. Timing violations

0 -> 0 negative-TNS timing-summary checks. All clock-domain summary categories are retained. This is under unchanged SDC; pre-existing not-fully-constrained setup/hold information is not a claim about unconstrained paths. Measured setup and hold remain positive.

## 43. New warning types

**None** across complete map/fit/STA/assembly/compile warning-ID comparison. Existing power-up/connectivity/unconstrained-path warnings remain; this is not a warning-free-core claim. Micro-only virtual-pin warnings are not mixed into this board comparison.

## 44. Packing explanation

Mapped combinational ALUT decreases 298 while synthesis register count is unchanged. Physical delta: placed +47, recoverable -93, unavailable -34, fitted FF -66. Fitted logic ALUT rises 45604->45618 (+14), despite the mapped 298-ALUT reduction; routing ALUT falls 19245->19168 (-77). Design-implementation FF45246->45251 (+5) and routing-optimization FF3081->3010 (-71), with 101 I/O FF unchanged, reconcile the fitted FF delta-66. Controller own fitted ALUT6601->6801 (+200), FF14726->14729 (+3); its estimated hierarchy allocation rises 79.6 needed/69.2 placed ALMs. Other hierarchy effects offset part of that rise. The placed-minus-needed gap falls 2701->2642 (-59), so calling the whole result packing degradation would be misleading. Physical resynthesis/remapping and placement erase the pre-fit saving; neither snapshot storage nor the wide fanout regime disappears. Full hierarchy, register-type and fitted logic/routing rows are in build_results.json. Hierarchy ALM allocations are estimates; the exact global A-B+C identity is in item 10. No register reduction is attributed to guest-state removal.

## 45. Remaining major resource consumers

The two 4800-bit scratch banks remain, as do the live sprite cache/shifters, distributed restore paths, wide capture/load controls and general core video infrastructure. Merely shortening the mux description does not eliminate required snapshot information or every mapped selector. No resource work on unrelated background, CPU, mapper, AudioMix or FM state is bundled here.

## 46. Further safe optimization opportunities

No further material saving is demonstrated by the tested low-risk formulations. Centralized/staged/RAM-backed restore remains an unmeasured, larger correctness-risk experiment; no savings forecast or semantic reduction is justified by these results. Development-format consolidation has no measured area benefit in this task. A future staged/banked transport experiment must prove capture coherency, complete malformed-image validation before restore, live-state isolation and identical release; it is not automatically safe because RAM bits are available. Current state widths and all formats must remain unless separately authorized. No demonstrated saving is assigned to unbuilt families.

## 47. Risk assessment

Single fixed-seed/tool/config comparison; no multi-seed distribution or hardware/game-ROM signoff. Controller miter plus unchanged receiver RTL gives the structural argument; finite VDP tests corroborate it. Earlier immutable reference oracles are retained, not regenerated to match a failure. ModelSim Starter statement-capacity warnings remain. Missing-ROM/native-oracle pilots, conditional-read preflight corrections, marker-label runner errors, and incomplete 64-slot G05 support attempts are excluded. No production divergence is hidden by these exclusions. The authoritative case ledger records PASS/FAIL/INCOMPLETE separately. 

## 48. Final classification

**NO SAFE MATERIAL OPTIMIZATION FOUND**. The simpler structural candidate fails the resource objective even though the exact controller miter passes and timing remains positive. The alternative register-mask formulation increases mapped logic substantially. The result is limited to the tested low-risk candidates; it is not a proof that no alternative architecture could ever save area. No unbeneficial production change is retained.

## 49. Recommended next roadmap step

**D. reconsider F01 architecture before implementation**. Before F01 implementation, establish a physical-ALM and M10K budget against the unchanged current baseline (2909 unplaced ALMs,66 free M10Ks), and assess the intended architecture within that budget under separate authorization. This does not prove F01 cannot fit or require an architectural replan; it requires a measured capacity plan instead of assuming mux cleanup or format consolidation will create room. No F01/F06/FM functional investigation or design was performed here.

## 50. git diff --stat

```text
(empty)
```

Audit/test artifacts are untracked and omitted from this tracked-file stat. Exact final tracked hashes and source identity belong in integrity.json.

## 51. git status --short

```text
?? tests/
```

Nothing staged; no commit, push or PR. Generated Quartus/simulator databases are ignored and none is tracked. Existing historical tests are preserved.

Canonical runtime ledger: **24/24 PASS; 82 specified current-image LOADs.** Legacy warm initialization and controller-format/unit campaigns are counted separately.

|Family / case|Status|LOADs requested|Log|
|---|---|---:|---|
|sprites/dut_zero|PASS|3|[log](sprites/dut_zero/simulation.log)|
|sprites/dut_one|PASS|3|[log](sprites/dut_one/simulation.log)|
|sprites/dut_collision|PASS|3|[log](sprites/dut_collision/simulation.log)|
|sprites/dut_near|PASS|3|[log](sprites/dut_near/simulation.log)|
|sprites/dut_overflow8|PASS|3|[log](sprites/dut_overflow8/simulation.log)|
|sprites/dut_overflow9|PASS|3|[log](sprites/dut_overflow9/simulation.log)|
|sprites/dut_terminated|PASS|3|[log](sprites/dut_terminated/simulation.log)|
|sprites/dut_tall|PASS|3|[log](sprites/dut_tall/simulation.log)|
|sprites/dut_legacy_graphics1|PASS|3|[log](sprites/dut_legacy_graphics1/simulation.log)|
|sprites/dut_legacy_graphics2|PASS|3|[log](sprites/dut_legacy_graphics2/simulation.log)|
|sprites/dut_legacy_tall|PASS|3|[log](sprites/dut_legacy_tall/simulation.log)|
|sprites/dut_first_visible|PASS|3|[log](sprites/dut_first_visible/simulation.log)|
|sprites/dut_line_transition|PASS|3|[log](sprites/dut_line_transition/simulation.log)|
|sprites/dut_accelerated64|PASS|3|[log](sprites/dut_accelerated64/simulation.log)|
|g05_targeted/dut_h0|PASS|3|[log](g05_targeted/dut_h0/simulation.log)|
|g02/dut_active|PASS|3|[log](g02/dut_active/simulation.log)|
|g03/dut_bus|PASS|3|[log](g03/dut_bus/simulation.log)|
|g04/dut_pending|PASS|3|[log](g04/dut_pending/simulation.log)|
|phases/dut_phases|PASS|13|[log](phases/dut_phases/simulation.log)|
|phases/dut_deterministic|PASS|3|[log](phases/dut_deterministic/simulation.log)|
|phases/dut_lfsr|PASS|3|[log](phases/dut_lfsr/simulation.log)|
|phases/dut_full_flush|PASS|3|[log](phases/dut_full_flush/simulation.log)|
|guest_q/dut_history|PASS|3|[log](guest_q/dut_history/simulation.log)|
|dual/dut_collision (independent_dual_vdp_irq)|PASS|3|[log](dual/dut_collision/simulation.log)|
