# G08.FM closure and minimal v19 correction

**READY TO COMMIT. G08.FM CLOSED - FIXED AND PROVEN.**

## 1. Baseline HEAD

`854761c3d4ab3f6d5c5d0dda00b4682c1523c443`, F06 commit, branch `investigate/savestate-g08-fm`. The tracked worktree was clean at entry. [Baseline identities and hashes](baseline.json) bind the tracked production inputs and prerequisite reports. Existing untracked tests were retained.

## 2. Current v18 confirmation

The entry writer used tag 484312, a 96 KiB container (12,288 64-bit words), full 32 KiB Sega SRAM semantics and the F01 private v17/104-row FM extension. The final writer is v19 for the causal history below; F06 payload locations/completeness policy are inherited unchanged.

## 3. F01 baseline

Commit 7fcd5e12847eedf9e97a44dc937c3dbac3205f7c. [F01 closure](../savestate_f01_opll_fix/review.md) established complete future-relevant OPLL restoration with sequential 32-bit access. The OPLL production architecture and sources are unchanged here.

## 4. G08.release baseline

Commit 08cf1426bfd2e1f2a73fdb25aaf57715d408db11. [G08.release closure](../savestate_g08_release_fix/review.md) established historical mixer phase and pending PSG-tick capture/restart. Those expressions, raw PSG state and restart FSM ordering are unchanged. This task tests their compatibility with the FM correction.

## 5. FM handoff topology

[Full inventory](handoff_inventory.md): native FM CE → OPLL slot/stage state → TemporalMixer mixout (14 bits) → system sign clamp (13 bits) → shift by 3 → combinational signed AudioMix sum/clipping → alternating 16-bit audio_l/audio_r → direct SMS.AUDIO_L/R wires. System E substitutes PSG2 at the same input; hidden OPLL remains tested separately. There is no additional core output register or independent FM-valid register. Host filter/DAC history is outside this core-port contract.

## 6. OPLL execution phase

FM runs on system.ce_cpu (/15), including CPU turbo/System E, whose guest CPU uses /10. The 72-state slot/stage counter advances only on an unfrozen native FM enable. Directed acceptance uses a real T80 M1/MREQ/iset0 boundary and production controller conditions; storage_busy delays acceptance until the selected counter. No guest counter, CE or accepted state is forced.

## 7. FM sample update phase

Publication occurs with pre-edge counter 70 (slot 17, stage 2) and active native FM CE. mixout then holds until the next publication. Its held value is already valid; nonzero output is not treated as sample validity. The publication event is derived from CE and counter and compared on every host edge. Row 102 contains mixout; row 101 contains the partial accumulator/address/mute; row 78 contains the execution counter.

## 8. AudioMix consumption phase

AudioMix samples its combinational input each host rising edge. Phase 0 updates left, phase 1 right, then flips. A publication and consumption on the same edge consume the old FM value because both are registered processes. Historical post-T next-phase is already in word 020[45]. The additional v19 last-sample value represents the half retained at T+1.

## 9. L/R sequencing

If T selects left, T+1 updates right from post-T inputs and retains the T left sample; the inverse holds when T selects right. The correction restores only the retained half on the existing ss_phase_set edge. Both next phases, asymmetric PSG stereo, FM-only and mixed sources are checked from k0.

## 10. Freeze behavior

Accepted T executes normally. At ARM/T+1 before the edge, the controller captures post-T device state and the T-selected output cache. OPLL temporal state is held from T+1. Combinational FM input and the live AudioMix phase/output caches continue during transport. The latter can refill with the newer sample and therefore cannot alone represent the uninterrupted first pair. [Inventory](handoff_inventory.md) classifies each element.

## 11. Restore behavior

Global LOAD flush precedes ST_FM_APPLY. F01 installs all 104 rows, performs its eight stationary cache-refill clocks, then enters the existing 256-clock UNFREEZE interval and CPU/native preparation. The test reads all 104 actual restored rows through the existing private interface in 208 clocks of that stationary interval, without changing guest state, enables or interval length. Every row equals its saved DDR word.

## 12. Release behavior

The existing first-resumed-edge mixer phase strobe selects the historical next channel. The ordinary selected output computes from restored inputs; the other output simultaneously loads the saved 16-bit last sample when valid. Thereafter ordinary alternating operation resumes. No extra release clocks, skipped samples or altered FM event phase are introduced.

## 13. Coherent observation points

Let T be the actual accepted SAVE rising edge. Reference k0 is T+1 after registered updates. Replay k0 is the first rising edge after freeze falls, after registered updates. Every pair from k0 is compared exactly. Transport/partial private install is not a guest observation; no settling grace is discarded after release.

## 14. Uninterrupted oracle

The independent original pre-F01 OPLL implementation executes legal F0/F1 register programs alongside the original JT89 path and mixer. ROM/register programming covers nonzero changing samples, user/preset voices, feedback, key changes, envelope progression and rhythm. Inactive channels are initialized by legal key-on/off history so X===X is never accepted as evidence. The fixture initializes mixer phase through its existing restore port during reset, then lets it evolve normally; both phase values are covered. It drives held F0/F1 programming through the existing wrapper and uses a real T80 for accepted fetch boundaries. UI cooldown alone is bypassed for rapid requests. Final replays never force OPLL temporal registers or execution counters. References record stereo pair, raw PSG configuration/history/divider, source sample, native phase, raw FM,72-state counter, publication event and mixer phase on every host edge.

## 15. Capture-phase coverage

The main sweep holds the external blanking qualifier at x0/y224/VBlank1 to isolate audio phases; it does not claim a new pixel or beam audit. Two additional FASTVIDEO=0 runs instantiate unchanged production video timing. The first captures real VBlank but masks the value difference through clipping; the reset-duration variant reproduces the v18 error at a real window and passes v19. Paired OPLL images and independent references are identical; actual coordinates and hashes are in [beam_proof.json](beam_proof.json). This is a focused audio acceptance check, not a full integration regression.

The 144-case directed sweep covers all 72 pre-edge OPLL counters ×2 reset/mixer phases. Native 10/25 classes arise through real acceptance and are recorded in [handoff ledger](handoff_ledger.json). Adjacent 69/70/71 boundaries explicitly cover before/on/after publication. Additional native 10, turbo, System E, stereo and normal 900000-clock flush runs supplement the factorized state-space proof. This is not a 72×2×2 cartesian sweep of both native labels: the /15 FM-enable sequence translates by 15 host clocks between 10/25, with both mixer parities already covered; explicit alternate-native and /10-CPU captures corroborate that factorization. It is finite directed coverage, not an exhaustive enumeration of every possible guest program.

## 16. F01 handoff oracle result

PASS: 207 LOADs in 187 main cases. Each LOAD has 104 actual readback rows, first native execution, first publication/raw sample, first mixer consumption/phase and first left/right output in [handoff_ledger.json](handoff_ledger.json). Event entries are independently recorded reference values asserted equal by the DUT on every compared edge; actual row readback and first pairs are separately recorded. Complete state plus k0 output equality and identical deterministic transition inputs establish the forward induction.

## 17. Equal-image future result

Two reachable prefixes differ in an earlier frequency write 91/B1 and then converge through legal key/frequency programming. Both baseline v18 and candidate v19 pairs are compared over all 12,288 words and their complete 48000-pair references. [Gate](functional_gate.json) records image/oracle hashes. Identical images yield identical loaded suffixes; the v18 pair still independently demonstrates the known k0 restoration error versus its uninterrupted reference. Equality between two replays alone does not prove correct restoration. A finite no-collision search is not an injectivity proof; the explicit local state/transition argument supplies sufficiency.

The broader search covers 187 candidate images: 180 distinct complete images, 4 equal-image groups and zero divergent 6,000-pair prefixes. The deliberate history pairs above compare their full 48,000-pair suffixes. See [image/future search](image_future_search.json).

## 18. SAVE-only result

PASS from k0 for every main candidate phase, using transfer stall classes 0/1/2. The original v18 publication-edge witness fails on SAVE-only as well as LOAD: continued transport overwrites the last output cache even though OPLL state is correctly held. v19 restores that cache on both paths.

## 19. LOAD replay result

PASS: legal register/PSG perturbation followed by LOAD restores every OPLL row, FM event/counter, mixer phase, raw sources and stereo future. The [full-flush perturbation probe](perturbation_probe/replay.log) changes 83/76/83 total rows before its three LOADs, including 18/18/18 phase,12/9/12 envelope and 8/9/8 feedback rows. Every actual restored row and every subsequent mixed sample matches. Saved image words remain immutable throughout each replay. [Functional gate](functional_gate.json) and per-case logs bind the checks.

## 20. Repeated-LOAD result

Publication-edge cases for both channels, both sources and native classes perform three LOADs from one image after renewed Q activity. Each suffix equals the independent reference, including k0, all events and CPU/PSG repeated-load checks. The long runs each include SAVE-only and one LOAD; equal-image runs include two LOADs.

## 21. FM-only result

PASS with PSG contribution zero at both AudioMix inputs while actual PSG machines remain active for temporal assertions. Both retained-channel directions and long changing FM suffixes pass. Two additional cases legally write all four PSG volume registers to silence and use the actual PSG mixer inputs (FM_ONLY=0); every reference source sample is asserted zero. Both directions replay three LOADs with full state/event/audio checks.

## 22. PSG+FM result

PASS with a legal period-six PSG tone plus active OPLL, including asymmetric stereo. Relative source timing, pending PSG behavior and complete mixed output are compared, rather than checking raw FM alone. Hidden-FM System E and dual PSG compatibility are also retained.

## 23. L/R result

PASS at the first pair and every subsequent host edge. The actual first 20 pairs and post-phase are retained per suffix. No L/R swap, extra consumption, omitted half or alternating displacement is tolerated.

## 24. Pending-event boundary result

The critical accepted publication edge is counter 70. v18 consumes old FM at T but loses that retained mixed value during transport. There is no missing OPLL pending-event bit: the post-T mixout and publication phase are already exact. The missing state is one downstream output cache. Captures before and after publication pass unchanged v18; v19 also passes the edge itself. PSG pending-tick semantics remain the established G08.release contract.

## 25. Long-suffix result

PASS: FM-only and asymmetric PSG+FM each compare 1,080,000 host pairs per suffix, SAVE-only plus LOAD (4,320,000 pairs together). Raw FM, derived publication events, counter, PSG/divider and mixer phase are checked throughout, detecting displacement and delayed envelope/feedback drift as well as first-pair loss.

## 26. Randomized coverage

After the directed gate passed, 24 seeded capture runs 101..124 use deterministic varied FM programs, LCG-selected target counters, both reset/mixer phases, all transfer stall classes and normal/turbo/System E conditions. Each compares 48000 pairs for SAVE and LOAD and reads all 104 restored rows. Seeds/actual acceptance are in the ledger. System E always uses the actual dual-PSG route; two initial parity-selected FM_ONLY=1 System E pilots compared different DUT/oracle input networks and are excluded. Their logs and causal routing explanation are retained in [pilot notes](pilots/systeme_routing.md); corrected references and replays retain every assertion. Random coverage supplements the complete 72×2 directed sweep.

## 27. First divergence

[Original v18 witness](p70_s0_fm1_stall0/replay.log): at T, raw FM changes from `0x3e14` to `0x3e65`, while left captures `0xf0a0`. At T+1, right should become `0xf328`. Expected `f0a0/f328`; actual `f328/f328`. Exactly one k0 pair differs on SAVE and each of three LOADs; all 48,000 raw FM/PSG/phase/event samples match. Neighbor counters 69 and 71 pass. The [real-video reset-duration witness](beam_reset_baseline/replay.log) independently returns `7ff8/7ff8` instead of `7f68/7ff8` at k0 on SAVE and LOAD, despite 104 exact restored OPLL rows. Its [v19 replay](beam_reset_candidate/replay.log) is exact. The [opposite-channel FM-only witness](baseline_opposite_channel/replay.log) expects `7ff8/7f68` and returns `7ff8/7ff8` at k0, once on SAVE and LOAD, with zero raw/event mismatches. Mono PSG+FM can mask the difference through clipping and is not counted as a failing witness.

## 28. Causal-state proof

Before production edits, cache-only deposits of the naturally observed T outputs eliminate all four 48000-pair failures. A second experiment deposits only the one channel retained at T+1 and again passes. The unforced isolated 16-bit candidate also passes. [Pre-edit gate](pre_edit_gate.json) binds baseline cleanliness, causal logs and candidate hashes. [Design](design_v19.md) explains why a pending bit cannot recreate an overwritten previous value and why broad OPLL/output serialization is unnecessary.

## 29. Decision gate

**C. G08.FM CONFIRMED - MINIMAL FIX REQUIRED. Cause: other - retained AudioMix output-cache history, not OPLL state or FM/mixer phase.** Complete F01 restoration and G08.release phase correctness do not reconstruct this retained historical output at an accepted FM publication edge.

## 30. Production change

Four files only: SMS.sv wires the T-selected sample; system.vhd forwards restore ports; AudioMix.vhd restores the retained half with the existing phase strobe; savestates.sv captures/stores/validates the 16-bit value and inherits v18 SRAM completeness. No OPLL/raw PSG architecture, framework, F06 payload map, resource optimization or format consolidation changes.

## 31. Format version result

v19 tag 484313; audio extension version 2. Word 022[47:32] stores the 16-bit last sample, [63:48] stays zero, PSG1[31:0] stays unchanged; System E word 024[63:32] stays zero. Same 96 KiB container, same payload word count and same private FM descriptor. Outer/extension versions must agree before guest restore. Genuine v1..18 imports retain their previous normalization and zero-padding rules; missing legacy history is not fabricated, so their newly identified first-pair limitation remains. Format suite: 2,098 rejected cases and 420 accepted round-trips passed. [Imports](imports/simulation.log) cover all 18 tags and public64/96 KiB routes.

## 32. F01 regression result

PASS: 16 retained F01 programs against their unchanged independent references, SAVE plus three LOADs each (3,072,000 pairs). Raw FM, native clocks/PSG and now strict mixed audio comparisons all pass, including previously characterized mixed output. Production OPLL/private snapshot sources are unchanged; the main campaign separately proves every actual restored row.

## 33. G08.release regression result

PASS: all 57 retained matrix/mode/boundary cases, original two witnesses with six LOADs plus SAVE-only, and 128×20000 raw PSG comparisons. Original ROMs, reference files and replay arguments are SHA-bound by [release manifest](release_manifest.json). Includes pending PSG, both sources/stereo, System E, Pause, transport variation, first-event and long cases. No G08.release finding was reopened.

## 34. Audio-equivalence result

PASS: 10,776,000 exact host pairs across 187 main candidate cases, in addition to retained F01/release suites. Every compared edge includes raw-state/event/phase assertions and exact mixed L/R. Once both output caches agree at k0, identical restored state and inputs give identical subsequent transitions. No equality is inferred merely from settled audio.

## 35. Simulation gate

**PASS**, [functional_gate.json](functional_gate.json). The controlled build is permitted only after the collector verifies every required completion marker, zero simulator errors, zero audio/raw mismatch counts, complete 104-row readbacks, long and random campaigns, original regressions, full-image pairs and source hashes. [Reproduction notes](reproduce.md) give exact witness/replay commands and frozen-baseline precautions. Superseded pilots are excluded: non-coprime ROM loop; uninitialized inactive channels; pre-apply readback; format assertion ordering; runner parameter transition; and the System E FM-only oracle-routing mismatch. They are test-development artifacts, not successful proof runs.

## 36. Quartus result

Controlled Quartus 17.0.2 Build 602, 5CSEBA6U23I7, SMS/sys_top, seed 1. All 137 retained F06 source/settings inputs and BUILD_DATE261025 are preserved except the four authorized source files. Fresh database; settings writes disabled. Map, fit, assembler and STA succeeded. [Manifest](build_early_inputs.json), [metrics](early_results.json). No hardware run is claimed.

## 37. Resource delta

|Metric|F06 v18|v19|Capacity|v19 %|Delta|
|---|---:|---:|---:|---:|---:|
|needed|37131|37117|41910|88.564|-14|
|placed|38450|38599|41910|92.100|+149|
|registers|48899|48880|167640|29.158|-19|
|M10K|488|488|553|88.246|+0|
|memoryBits|3818050|3818050|5662720|67.424|+0|
|DSP|39|39|112|34.821|+0|

Synthesis registers 46327, delta 37. [Synthesis breakdown](synthesis_delta.json): controller+17 registers, AudioMix+4, downstream audio_out+16, totaling+37. The 20 downstream registers correspond exactly to 10 former low-bit[1,2] merges that a fully restored 16-bit value no longer permits. Synthesis ALUT deltas are+69/+13/+99 in those hierarchies. No new snapshot memory, DSP or broad FM-state bank. Detailed fitter recoverable/unavailable/routing ALUTs and warning differences are retained in the metrics JSON. Placed ALMs and needed utilization are reported separately.

## 38. Timing result

Worst setup+0.104 ns (F06+.366; delta-0.262). Worst hold+0.239 ns (F06+.234; delta 0.005). Violating timing summaries 0. Routing completed. New warning types: none. Full path analysis/warning disposition is linked in [timing review](timing_review.md). Existing baseline unconstrained categories are explicitly inherited, not presented as newly fully constrained timing proof.

## 39. G08.FM closure classification

**CLOSED - FIXED AND PROVEN** under the initialized fixed-session production acceptance/current-input contract. Complete OPLL state, first execution/publication, consumption phase, first outputs, long future, repeated LOAD, SAVE-only and mixed operation all pass. Legacy images lack the new 16-bit history. Finite simulation is supported by the local deterministic transition argument; commercial hardware/DAC validation remains a later task.

## 40. Global G01-G12 closure status

**ALL G01-G12 OBLIGATIONS CLOSED**, within each report’s explicit contract. This conclusion updates the historical open statuses without rewriting those reports.

|Obligation|Classification and evidence|
|---|---|
|G01|CLOSED - FIXED AND PROVEN; [CPU restart](../savestate_g01_cpu_restart_fix/review.md)|
|G02|CLOSED - JUSTIFIED BOUNDARY EXCLUSION; [VDP](../savestate_g02_g05_v14/review.md)|
|G03|CLOSED - PROVEN RECONSTRUCTABLE; [VDP](../savestate_g02_g05_v14/review.md)|
|G04|CLOSED - PROVEN RECONSTRUCTABLE; [VDP](../savestate_g02_g05_v14/review.md)|
|G05|CLOSED - FIXED AND PROVEN; [background](../savestate_g05_background_fix/review.md)|
|G06|CLOSED - FIXED AND PROVEN; [coupled restart](../savestate_g06_g10_fix/review.md)|
|G07|CLOSED - JUSTIFIED EXCLUSION; [boundary proof](../savestate_g_closure/review.md)|
|G08|steady: CLOSED - JUSTIFIED EXCLUSION for steady reconstruction only; [original scope](../savestate_g_closure/review.md). release: CLOSED - FIXED AND PROVEN; [release](../savestate_g08_release_fix/review.md). FM: CLOSED - FIXED AND PROVEN by this report|
|G09|handoff/eeprom-pulse: CLOSED - PROVEN BY EXISTING EVIDENCE; reset: CLOSED - JUSTIFIED EXCLUSION; last-read: CLOSED - PROVEN RECONSTRUCTABLE; [children](../savestate_g09_last_read/review.md)|
|G10|CLOSED - FIXED AND PROVEN; [coupled restart](../savestate_g06_g10_fix/review.md)|
|G11|CLOSED - PROVEN RECONSTRUCTABLE; [decryption](../savestate_g11_decryption/review.md)|
|G12|CLOSED - FIXED AND PROVEN; [live SDRAM](../savestate_g12_sdram_fix/review.md)|

This is obligation closure, not a claim that global integration/resource/hardware release gates have already run.

## 41. Final classification

**READY TO COMMIT**. Nothing has been staged or committed. Review includes the v19 compatibility policy and controlled resource/timing delta.

## 42. Recommended next roadmap step

Full savestate integration regression → global ALM/timing optimization audit → final implementation/resource decision → hardware validation → PR decision. Those tasks are recommended only and were not begun here.

## 43. git diff --stat

```text
 SMS.sv            |  7 ++++++-
 rtl/AudioMix.vhd  |  6 +++++-
 rtl/savestates.sv | 54 ++++++++++++++++++++++++++++++++++++------------------
 rtl/system.vhd    |  3 +++
 4 files changed, 50 insertions(+), 20 deletions(-)
```

## 44. git status --short

```text
 M SMS.sv
 M rtl/AudioMix.vhd
 M rtl/savestates.sv
 M rtl/system.vhd
?? tests/
```

No staged changes, commit, push or PR. Generated simulator/Quartus libraries are ignored locally in this evidence tree. No unrelated production documentation was edited.
