# F01 OPLL sequential savestate fix

**F01: CLOSED - FIXED AND PROVEN. READY TO COMMIT.**

Architecture C; v17; one additional M10K. F06 excluded. G08.FM remains open. Production bytes are frozen by sufficiency_gate.json and both build input manifests. [final_audit.json](final_audit.json) binds the final source, regression logs, build evidence and this report.

Controlled builds use Quartus 17.0.2 Build 602, Cyclone V 5CSEBA6U23I7, SMS/sys_top and seed 1. QSF, SDC, IP, performance and packing settings are unchanged; BUILD_DATE matches the baseline at 261025. Fresh source-only databases run explicit map/fit/asm/sta, bypassing only the timestamp preflow. Final settings writes are disabled to preserve original QSF bytes.

|Resource|Early absolute|Early utilization|Delta v16|Delta early|
|---|---:|---:|---:|---:|
|needed|37,175 / 41,910|88.702%|+875|—|
|placed|38,598 / 41,910|92.097%|-403|—|
|registers|48,948 / 167,640|29.198%|+520|—|
|M10K|488 / 553|88.246%|+1|—|
|memoryBits|3,818,050 / 5,662,720|67.424%|+8,192|—|
|DSP|39 / 112|34.821%|+0|—|

|Resource|Final absolute|Final utilization|Delta v16|Delta early|
|---|---:|---:|---:|---:|
|needed|37,175 / 41,910|88.702%|+875|+0|
|placed|38,598 / 41,910|92.097%|-403|+0|
|registers|48,948 / 167,640|29.198%|+520|+0|
|M10K|488 / 553|88.246%|+1|+0|
|memoryBits|3,818,050 / 5,662,720|67.424%|+8,192|+0|
|DSP|39 / 112|34.821%|+0|+0|

**1. Baseline HEAD.** cb2e8615128d61adb996ada68e6bbdcc314c20f6, branch fix/savestate-f01-opll. HEAD is unchanged; no staging, commit, push or PR.

**2. Baseline format/resources.** Committed v16: 36,300 needed ALMs; 39,001/41,910 placed (93.059%); 48,428 fitted registers; 487 M10Ks; 3,809,858 memory bits; 39 DSPs; setup +0.465 ns; hold +0.198 ns. Source-verified baseline reports remain in ../savestate_g12_sdram_fix/quartus_candidate.

**3. Architecture.** C: localized sequential 32-bit state access with one 256×32 M10K scratch memory. No broad parallel shadow bank. F06 and format consolidation are excluded.

**4. Exact state map.** [state_map.md](state_map.md) and [state_map.json](state_map.json) account for all 122 inventory rows and 3,568 logical source bits, including the wrapper. Ready-state history is 1,896 meaningful bits in 104 rows / 3,328 bits; 1,432 bits are canonical or padding. Arrays occupy 76 rows: channel 9×22, user voice 2×36 (nine carrier TL/FB bits canonical), phase 18×18, envelope 18×25, feedback 9×10, output 18×10. Scalar/pipeline history is 591 bits. There are 28 scalar/reserved rows; rows 4f and 67 are reserved. The table specifies every slice, consumer, save/restore rule and reconstruction order, with physical record encoding notes.

**5. Interface.** 8-bit ss_addr, 32-bit ss_wdata/ss_rdata, ss_read, ss_write, ss_hold and aggregated ss_initialized. Reads are synchronous; the response is consumed on the next edge. Fixed endpoint latency and capture/apply completion handshakes bound each access. Private access requires hold. Writes use local word enables and original array ports. The early fitter high-fanout table records the shared ST_ARM_FREEZE node at 9,663 loads and z80_set at 5,920; no OPLL state-data bus appears in its listed high-fanout entries. These global measurements are not a per-net proof of maximum accessor fanout.

**6. Snapshot organization.** One synchronous 256×32 simple dual-port M10K: 8,192 physical bits, of which 104 rows / 416 bytes carry the image. Each DDR64 word contains two rows. Physical integrity tests cover all 256 addresses. One 32-bit temporary stages the low voice word; its high four bits trigger one 36-bit array write.

**7. Inference.** Isolated scratch fit uses one M10K, 8,192 bits, 188 ALMs, 158 FF and zero DSP. The whole-board fitter explicitly names fm_snapshot as one 256×32 / 8,192-bit M10K. The original three OPLL M10Ks / 3,186 bits remain. Isolated live OPLL synthesis is 2,617 ALUT / 1,888 FF versus baseline 1,685 / 1,599, with three M10Ks and four DSPs unchanged. Virtual-pin results are not whole-board deltas. The initial unsupported process template was corrected before the gate; no ALM memory substitute was accepted.

**8. SAVE.** Acceptance edge T executes ordinary work with the old freeze value. From T+1, writers and initializers hold: post-T scalar/pending-store controls pair with pre-commit arrays. The scan takes 104 read/collect pairs / 208 local host edges, excluding command/done handoff. Transaction IDs prove exactly-once coverage. The global audio marker is invalidated before transport and committed after all payload; control word0 remains last.

**9. LOAD.** Validate the complete record before guest mutation, fill scratch, apply 104 read/write pairs, then perform eight stationary cache-refill edges: 216 local host edges excluding handoff. Arrays precede pending scalar controls. Raw mixout is the final meaningful row, 102; row103 is canonical padding. Ordinary writes stay inhibited through partial restore/refill. No intermediate synthesis output is published; the existing G10 CPU/release sequence follows local completion.

**10. Reconstruction.** Restore the base modulo-72 counter and derive delayed counters as (base+72−delay)%72 for delays 2/5/8, supported by the 576-transition architecture proof. Return runtime addresses and refill pure memory/linear caches and EG.aridx for eight host edges with xena=0. Attack/Sine CE pipelines retain historical state. rm5 has no reader before overwrite; output entry18 is unreachable; process temporaries have no inter-activation history. No guest-tick warmup or register replay is used.

**11. Startup uncertainty.** The 37 initializer-control bits and 1,296 fixed-voice backing bits are omitted only under explicit initialization-ready SAVE/LOAD acceptance gating. Six initializers progress on host clocks even with xena=0. Sweeps finish within 114 edges; registered readiness is high at edge115; edge116 is first eligible acceptance. Warm reset removes readiness. Requests wait without prematurely freezing normal guest work. Eight warm-reset/VBlank tests pass with no FM tick. Unreset historical scalar/pipeline values are stored; no blanket FPGA power-up assumption is made. Prior uncertain ROM effects folded into history remain captured.

**12. v17.** [format.md](format.md): tag 0x484311; unchanged 96 KiB container and 0x3000 slot stride. Word2997 is descriptor 0x00681101464d5331 (104 rows/version17/present1/FMS1). Words2998..29cb contain 52 DDR64 words, low32 row2n / high32 row2n+1. Total is 416 payload + 8 descriptor = 424 bytes. Sprite tail2996 and VRAM end2900 do not overlap. Hidden/System E FM is included. All 1,432 padding bits and eight bounded fields validate before applying state. Descriptor follows payload; required global audio presence prevents stale-descriptor partial SAVE acceptance.

**13. Legacy fallback.** Pre-v17 uses an explicitly lossy local FM reset, full ROM initialization, 28 canonical scalar rows and stationary refill. Base counter=71, AM phase=0x08000, noise table=all ones, mute=1; other scalar defaults are zero. Legacy states lack a saved FM program, so no register replay is attempted. Three strong prior histories converge to the same 104-row state and 20,000-sample future. Raw mixout is zero before release; reset-equivalent startup does not imply an entirely silent future. Twenty imports pass: tagged v1–16, public untagged 96 KiB/64 KiB, and v17 before/after. Legacy has one local reset and 28 writes; v17 has 104 writes and no local reset.

**14. Original non-injective witnesses.** The original same-v16 image SHA256 is 85e45a86cf942106d12432cdd8a5a6837d65698a7a891e3f9d81efda8f4aa617. Its natural FM histories now differ in eight v17 words and 15,680/20,000 future raw samples. Each history independently passes SAVE and three LOADs against its own uninterrupted oracle. [pairs.json](pairs.json) retains hashes/differences; pair_a.bin and pair_b.bin retain complete 96 KiB images.

**15. Sustained tone.** current_case0_final passes SAVE-only and three LOADs: 80,000 exact host samples.

**16. Attack.** current_case2 passes active attack. current_case1 is a slow-attack/silent supporting case, not an independent audible witness.

**17. Decay.** decay extends the case2 prefix by 12,000 host clocks and passes SAVE plus three LOAD suffixes.

**18. Sustain.** current_case3 passes. Its selected program duplicates case0 and is not counted as independent evidence.

**19. Release.** current_case4 passes key-off SAVE and three LOAD suffixes; randomized keys add coverage.

**20. Feedback.** current_case6 passes with feedback=7; setup overlaps case0. Random programs span feedback 0..7. The long oracle uses feedback=7.

**21. User instrument.** Custom operators, AM/PM, envelope fields and pending CPU writes pass in case0/6, native/loop and all 16 randomized programs.

**22. Rhythm/noise.** current_case7 exercises all five rhythm keys and channels6..8. SAVE and three LOADs pass, supplemented by randomized programs and the 72-phase sweep.

**23. Multichannel.** current_case8 passes with two active channels. Random programs use 2..9 channels, presets, keys, sustain and rhythm. Preset case5 is a silent supporting case, not an independent audible witness.

**24. SAVE-only.** All 18 controller cases, 72 local phases and 16 random programs pass from the first resumed host edge without grace or tolerance. Long SAVE also passes. Transport duration cannot advance phase, envelope, LFO, noise or feedback.

**25. LOAD.** 54 controller LOADs, 216 local phase LOADs and 48 random LOADs pass, plus long, memory, legacy and Pause proofs. The native T80/production-video test retains the original uninterrupted oracle.

**26. Repeated LOAD.** Each controller/random image remains immutable across strong Q1/Q2/Q3 perturbations and three LOADs. Local phase tests separately verify all 104 restored rows three times per phase, but target successive local endpoints; these are not miscounted as same-image repeated LOADs.

**27. Long suffix.** long.log passes against an independent unmodified baseline OPLL at the actual host/15 enable cadence. Two suffixes each cover 1,050,000 FM ticks: 31,500,000 host samples total, beyond AM period 983,040 CE and PM period 589,824 CE. AM, PM and feedback=7 are enabled. No guest warmup ticks occur.

**28. Memory integrity.** memory.log proves 104 captures, all 256 physical addresses, address-derived/reverse patterns and 312 restores. integrity.log checks 832 typed random rows (8×104), bounded fields, exact-once IDs, alias/truncation/stale data, voice high4 and the final partial row. Full images are known and immutable. Format suite passes 2,016 rejects plus 400 accepts (2,416 cases), including every FM padding bit, descriptor bit and bounded-field violation. Rejects precede FM reset/state write or other guest mutation.

**29. Stalls/duration.** The local state endpoint has fixed latency. DDR transport uses no stalls, fixed 13/31-edge delays, and LFSR 12/16 profiles, plus the explicit stalled case. All produce the same restored state and exact FM suffix. Capture/apply advances private sequencing only.

**30. CPU/FM writes.** The native case uses real T80 OUT F0/F1 traffic, production video and the retained original uninterrupted oracle. The loop case continuously writes keys, instruments, custom operators, feedback and rhythm around accepted boundaries. Both pass SAVE and three LOADs. Wrapper address/data, sticky write and pending pipeline controls are serialized; restoration does not infer them from the final register program.

**31. Pause/restart.** All four saved/current logical Pause combinations pass with actual UI joy/VBlank transitions and actual OPLL/scratch: 80,000 exact host samples. This focused composition supplies the established native clock contract; the separate G12/F12 integration runs all four Pause combinations with the real SDRAM controller. Existing authorized bounded CPU/PSG progress to reach capture remains the F12 contract.

**32. PSG isolation.** The unchanged raw PSG suite passes 128 noise/divider cases × 20,000 = 2,560,000 cycles. Production PSG RTL and payload semantics are unchanged. FM does not replay or consume the falling-edge PSG event. Controller tests also compare PSG configuration, extended history, divider, raw output and native phase.

**33. G08.release isolation.** The isolation and pending cases pass, as do six retained strict stereo cases: gg_left_strong, gg_right_only, systeme_dual_decode, sms_normal_pending25, pending_dual and pending_latency29. These check first samples, L/R phase, pending PSG tick, stalls and three LOADs. Active-FM mixed differences remain characterization only. G08.FM stays OPEN.

**34. Post-fix non-injective search.** Naturally convergent histories have the same complete 96 KiB v17 image (SHA256 b7fbbe4f38d58ee81f605f4a7eb2ef5dc541fa0804c64ac511f955ec6bbac9d4) and the same reference future. The original collision is separated. No differing-future collision was found. The convergent pair does not establish that omitted caches/rm differ at capture. This finite search is complemented by source consumer/overwrite proofs, stationary refill, all 72 phases, and independent long/random oracles; it is not an exhaustive state-space proof.

**35. Sufficiency gate.** [sufficiency_gate.json](sufficiency_gate.json) passed before the first full build and freezes production hashes. It records 18 controller cases / 1,440,000 raw samples; 72 pipeline phases / 17,280,000 samples; long suffix / 31,500,000 samples; memory, startup, legacy, Pause, PSG and format proofs. Quartus was not used to judge an incomplete function.

**36. Early ALMs needed.** 37,175/41,910=88.702%,+875.

**37. Early ALMs placed.** 38,598/41,910=92.097%,−403;3312physicalsitesfree.

**38. Early fitted registers.** 48,948/167,640=29.198%,+520 (synthesis46,289,+481).

**39. Early M10K.** 488/553=88.246%,+1;65free.

**40. Early memory bits.** 3,818,050/5,662,720=67.424%,+8192.

**41. Early DSP.** 39/112=34.821%,unchanged.

**42. Early timing.** Setup+0.105ns (−0.360),hold+0.206ns (+0.008),zero failing timing-summarychecks. Existing partiallyunconstrainedSDC remains. WorstsetupHDMI;emuclock+0.635ns. No newwarningtype; newbenignunusedss_v_ff_count message10036.

**43. Early resource decision.** FITS BUT REQUIRES CAUTION. Routing succeeds with 3,312 free physical sites, 65 free M10Ks and no new warning type or failing timing-summary check. Needed ALMs rise 875, logic ALUTs rise 1,428 and routing ALUTs fall 1,063. Global remapping explains placed ALMs falling 403; this is not an intrinsic negative F01 cost. Packing identity: baseline 39001−3225+524=36300; candidate 38598−1955+532=37175. Setup reserve falls to 0.105 ns. The early copied QSF auto-exported imported assignments; Quartus API comparison proves all 2,278 effective global/instance assignments identical (qsf_export_verification.json). Root QSF was unchanged. Final flow disables settings writes and requires original raw QSF hashes.

**44. Full randomized F01 regression.** After the resource gate, 16 seeds passed 16 SAVE-only segments and 48 LOADs: 3,072,000 exact raw FM host samples. Each 48,000-sample oracle is known and nonconstant. regression_results.json retains minimum/maximum/distinct sample counts, source binding, native phase and hashes. The reference is the unmodified original OPLL. Normal CPU /15 and turbo CPU /10 are covered; System E seeds 5/10/15 still compare hidden FM state. Replay binds work_random.opll; oracle generation binds original_work.opll_reference. Initial library-order elaboration pilots produced no samples and are excluded. During the final source-frozen build audit, the randomized fixture System E right input was found still selecting FM. The test generator was corrected to select PSG2 on both sides and seeds 5/10/15 were rerun; prior copies remain in random_*_prior_mix and are excluded from final counts. The other 13 programs never select that branch. The retained mandatory System E regression had already passed before the final build; production bytes did not change. See oracle_source_identity.json for the 19-unit baseline behavior bridge and simulation portability edits.

**45. Existing targeted regressions.** 28/28 pass with clean ModelSim termination and unchanged input ROM/reference hashes: ten G01 CPU programs; G05 background; two sprite cases; three G10 phase/deterministic/full-900000-flush cases; dual VDP; G04 pending/native; four G12/F12 real-SDRAM/Pause cases; six AudioMix/PSG cases. Non-FM fixtures abstract FM readiness/data; actual FM has separate proofs. Historical V15 fixture labels do not change the current v17 controller compiled here. Shared DDR byte/handshake tasks were unchanged, so the closed shared-memory exhaustive campaign was not rerun. New FM request/header states are covered by actual-controller, format and import tests.

**46. Final ALMs needed.** 37,175/41,910=88.702%; delta v16 +875; delta early +0.

**47. Final ALMs placed.** 38,598/41,910=92.097%; delta v16 -403; delta early +0.

**48. Placed-ALM delta.** -403 versusv16,+0 versusearly; 3,312physicalsitesfree.

**49. Final fitted registers.** 48,948/167,640=29.198%; delta v16 +520; delta early +0.

**50. Final M10K.** 488/553=88.246%; delta v16 +1; delta early +0.

**51. Final memory bits.** 3,818,050/5,662,720=67.424%; delta v16 +8,192; delta early +0.

**52. Final DSP.** 39/112=34.821%; delta v16 +0; delta early +0.

**53. Final setup/hold.** Setup+0.105ns,hold+0.206ns. Deltav16-0.360/+0.008ns;deltaearly+0/+0ns.

**54. Final timing violations.** 0 failingtiming-summarychecks; deltav16+0,deltaearly+0. Existingpartiallyunconstrainedpaths limit interpretation; no hardware/multiseed timingclaim.

**55. Final warnings.** Newwarningtypes: []. Newnormalizedmessages: ["Warning (10036): Verilog HDL or VHDL warning at SOURCE(LINE): object \"ss_v_ff_count\" assigned a value but never read"]. SourcehashverificationPASS,snapshotinferencePASS.

**56. F01 classification.** CLOSED - FIXED AND PROVEN within the documented simulation/source/resource contract.

**57. G08.FM handoff oracle.** [handoff.json](handoff.json) retains all 104 restored rows and the first 20 raw/mixed reference observations for six sustained/native/continuous-CPU/pending/random witnesses. Raw 14-bit mixout: row102 bits13:0. Partial sum: row101 bits19:6; address bits5:1; mute bit0. Base counter: row78 bits6:0. FM update occurs on pre-edge xena && baseCounter==70 (slot17/stage2), using the actual system.ce_cpu gate. Native phase is word02f bits1:0; bit3 belongs to PSG, not FM. AudioMix post-T next-channel phase is word020 bit45. Production 13-bit clamp and <<3 shift are unchanged. The first valid raw sample is the retained/restored mixout, not the first nonzero value. Each witness includes actual saved words and first samples from reference.dat. G08.FM remains OPEN; later work must independently assess release/mixed-sampling order against this restored-OPLL oracle.

**58. Limitations.** Finite simulation and source proofs do not exhaust all reachable states. No FPGA hardware/game-ROM test was performed. The convergent pair does not establish differing omitted state at capture. Silent/duplicate supporting cases are identified rather than counted as independent audible witnesses. Legacy FM fallback is deterministic and lossy. Focused Pause uses the existing clock contract; full F12 is separately regressed. Repeated same-seed Quartus builds do not establish seed robustness. Limited setup margin and partially unconstrained SDC require caution. F06 is untouched; G08.FM stays open; format consolidation is excluded.

**59. Tracked diff stat.** 

~~~text
SMS.sv                           |  13 +-
 files.qip                        |   2 +
 rtl/VM2413/attacktable.vhd       | 109 +++++++--
 rtl/VM2413/controller.vhd        | 484 +++++++++++++++++++++++++++++----------
 rtl/VM2413/envelopegenerator.vhd | 207 +++++++++++++----
 rtl/VM2413/envelopememory.vhd    |  43 +++-
 rtl/VM2413/feedbackmemory.vhd    |  39 +++-
 rtl/VM2413/lineartable.vhd       |   6 +-
 rtl/VM2413/operator.vhd          | 122 ++++++++--
 rtl/VM2413/opll.vhd              | 257 ++++++++++++++++-----
 rtl/VM2413/outputgenerator.vhd   | 144 ++++++++++--
 rtl/VM2413/outputmemory.vhd      |  41 +++-
 rtl/VM2413/phasegenerator.vhd    | 133 +++++++++--
 rtl/VM2413/phasememory.vhd       |  43 +++-
 rtl/VM2413/registermemory.vhd    |  39 +++-
 rtl/VM2413/sinetable.vhd         | 121 ++++++++--
 rtl/VM2413/slotcounter.vhd       |  66 +++++-
 rtl/VM2413/temporalmixer.vhd     | 134 ++++++++---
 rtl/VM2413/vm2413.vhd            |  15 +-
 rtl/VM2413/voicememory.vhd       |  48 +++-
 rtl/VM2413/voicerom.vhd          |   2 +-
 rtl/savestates.sv                | 199 ++++++++++++++--
 rtl/system.vhd                   |  36 ++-
 23 files changed, 1867 insertions(+), 436 deletions(-)
~~~

The new untracked rtl/opll_snapshot.sv and test/report files are absent from tracked diff statistics. Generated Quartus databases and simulator libraries are ignored and unstaged. diff --check reports 168 trailing-whitespace findings in restructured VHDL (110 blank lines); whitespace_review.json records them. They are style findings, retained to keep production bytes identical to the functional gate and both builds. No functional or synthesis error is inferred from them.

**60. Repository status.** 

~~~text
M SMS.sv
 M files.qip
 M rtl/VM2413/attacktable.vhd
 M rtl/VM2413/controller.vhd
 M rtl/VM2413/envelopegenerator.vhd
 M rtl/VM2413/envelopememory.vhd
 M rtl/VM2413/feedbackmemory.vhd
 M rtl/VM2413/lineartable.vhd
 M rtl/VM2413/operator.vhd
 M rtl/VM2413/opll.vhd
 M rtl/VM2413/outputgenerator.vhd
 M rtl/VM2413/outputmemory.vhd
 M rtl/VM2413/phasegenerator.vhd
 M rtl/VM2413/phasememory.vhd
 M rtl/VM2413/registermemory.vhd
 M rtl/VM2413/sinetable.vhd
 M rtl/VM2413/slotcounter.vhd
 M rtl/VM2413/temporalmixer.vhd
 M rtl/VM2413/vm2413.vhd
 M rtl/VM2413/voicememory.vhd
 M rtl/VM2413/voicerom.vhd
 M rtl/savestates.sv
 M rtl/system.vhd
?? rtl/opll_snapshot.sv
?? tests/
~~~

Nothing is staged. HEAD is unchanged. No commit, push or PR was performed.

**61. Recommendation.** READY TO COMMIT, with FITS BUT REQUIRES CAUTION resource classification. User-requested review point only: nothing committed.
