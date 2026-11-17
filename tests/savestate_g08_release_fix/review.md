# G08.release coupled AudioMix / pending PSG tick fix

**CLOSED - FIXED AND PROVEN. READY TO COMMIT.**

G08.FM remains OPEN - BLOCKED BY F01. The user’s scope amendment authorizes the minimal coupled PSG event correction; the historical phase-only blocked report is retained as [review_blocked.md](review_blocked.md).

1. **Baseline HEAD:** f205b05dc058fc5f7f2432779b61e8f3b0e22519; branch fix/savestate-g08-release. HEAD remains unchanged. All 203 baseline tracked files are hashed; only the five intended production files differ. [baseline.json](baseline.json).

2. **Baseline format:** Committed v15, tag 48430f, 12,288 × 64-bit words (96 KiB). The new header is v16; container size and record locations are unchanged.

3. **Original LOAD failure:** Fresh unchanged-v15 reproduction: 14 wrong stereo pairs in each 20,000-clock suffix, first at k1152 and then every 1440 clocks. Raw PSG and divider state match. [baseline/unstalled.log](baseline/unstalled.log).

4. **Original SAVE-only failure:** Unstalled SAVE is exact; the original 13-of-31 transport stall produces 14 wrong pairs. Three LOADs on each transport reproduce all six original failures; 98 wrong pairs in total. [baseline/stalled.log](baseline/stalled.log).

5. **First divergent state:** Original witnesses: AudioMix.toggle is wrong on first resume, before the later wrong channel latch. Additional independent witness: cen_16 differs at the falling edge following accepted T (phase10, pre-divider14/post15); tone counter differs at T+1 and AUDIO_R at k3, despite equal mixer phase. [raw_characterization](raw_characterization/).

6. **Complete sequencing inventory:** [design_pre_edit.md](design_pre_edit.md) inventories width, update/reset, freeze, LOAD, release and first consumer. toggle is one historical bit; audio_l/r are 16-bit caches reconstructed before logical observation. PSG stereo sums are 11-bit host-clock registers. in1/in2/sum/clipped are combinational 17-bit signals: there is no stored accumulator. ce_snd is unused. Core AUDIO_L/R are the observation point. Arithmetic and overflow selection are unchanged; no conventional saturation-correctness claim is made.

7. **LOAD root cause:** v15 captures transport-time toggle after drain and later uses it as the next logical channel. Correct history is the post-T next-update phase captured at ARM. Continued mixer execution during transport is safe only after that history is restored at release.

8. **SAVE-only root cause:** No phase installation on SAVE: the live toggle advances through every frozen wall-clock edge, so transport parity selects the resumed channel. The independent pending PSG event is suppressed during the freeze handoff before it can be generated, not during LOAD preparation.

9. **Shared versus independent causes:** Original LOAD and SAVE failures share the missing boundary-relative mixer-phase handoff. Pending PSG tick loss is a separate temporal omission at the source-enable/falling-edge boundary. Both need correction: phase-only failed the retained new witness; pending replay alone cannot correct opposite mixer sequencing. G10 deterministic restart itself is unchanged and remains CLOSED.

10. **Solution A: freeze mixer:** Can preserve SAVE phase, but LOAD still needs historical phase and either output serialization or a refill interval. Freezing arbitrary Q output through LOAD leaks stale samples. At least a historical bit plus control/refill is needed; 32 output bits would be unnecessarily broad. Stereo, dual PSG and Pause require the same careful first-sample ordering.

11. **Solution B: minimal phase:** Chosen. One historical next-channel bit fixes LOAD and SAVE if both caches refill from old restored inputs before observation. The bit already has storage in word020[45]; corrected semantics require v16. Shared alternating phase covers stereo and dual PSG; paused capture retains logical Pause. Expected cost is a small decoder/mux, measured below.

12. **Solution C: phase plus accumulator:** No sequential accumulator exists. Adding intermediate/output payload has no causal justification; it increases storage/mux/fanout without improving the proven first-sample representation. The same stereo/System E/Pause obligations would remain.

13. **Solution D: canonical phase:** An arbitrary constant cannot reproduce both naturally reachable next-channel phases and their partial stereo suffixes. Divider phase does not determine the free-running host mixer toggle after transport. Zero historical bits is insufficient for SAVE and LOAD, regardless of stereo/System E/Pause mode.

14. **Solution E: hybrid freeze and bit:** Sufficient in principle with historical phase and explicit refill, but adds freeze fanout/stages and disrupts existing reconstruction. It needs the same one-bit v16 history and offers no smaller representation or better first sample than B.

15. **Chosen coupled design:** Capture post-T phase at ARM; apply it on first resumed clock for SAVE and LOAD. Derive pending PSG event from capture_tick_snap && phase_snap in {1,3} (native10/25) && audio_div_snap==15. Qualify with audio_phase_set and route to JT89; set cen_16 on the falling edge before first resume. No divider increment, guest CPU tick, or event during transport/private preparation. Both System E PSGs receive the shared event. [design_coupled.md](design_coupled.md).

16. **Sufficiency proof:** Original phase-only and pending-tick counterexamples are retained. After the scope amendment, the combined proposal passed original six LOADs, pending/stereo replays and equal-complete-image history pairs before production edits: [pre_edit_gate.json](pre_edit_gate.json). Accepted T classes and post-divider uniquely determine the deferred event; restored old raw samples refill PSG sums and mixer caches before release. Replay updates samples at T+1 while downstream consumers see the same old values as uninterrupted execution. Equal old source state, cached pair, next-channel phase and deferred event give equal future transitions by induction. Finite search corroborates this ordering argument; it is not an exhaustive proof of arbitrary forced mid-clock images.

17. **Format decision:** v16 introduced, tag484310. Reuse word020 bit45 for corrected historical phase; retain v15 139-bit background records and v14 sprite/restart descriptors. No new payload word, pending-event bit, oscillator history, accumulator, cache register, RAM or DSP. v16 requires its audio extension before guest writes.

18. **Legacy behavior:** Tags1–15 normalize unavailable next-channel phase to0. Genuine old64 LOAD also starts phase0 even when Q phase is1. Existing restart metadata derives the deferred event where available; older formats without it use deterministic no-replay defaults. Exact missing legacy audio history is not promised. Final-source 18-LOAD compatibility test passes. A one-line ARM LOAD initialization guard was added after earlier tagged tests; the exact source bridge and final-source coverage are recorded in simulation_results.json.

19. **Production files:** SMS.sv and rtl/system.vhd wire the event (secondary qualified by System E); rtl/jt89/jt89.v adds one resume-only cen_16 branch; rtl/jt89/jt89.vhd declares the default-zero port; rtl/savestates.sv handles phase capture/release, predicate and v16/legacy validation. AudioMix, raw PSG payload/recurrence, CPU, VDP, OPLL and QSF/SDC are unchanged.

20. **Original LOAD post-fix:** Exact AUDIO_L/R, raw PSG, phase and divider suffix from k0, without grace or tolerance. Final-source original fixture uses 20,000 clocks per replay. [original_combined/unstalled.log](original_combined/unstalled.log).

21. **Six original LOADs:** Unstalled passes1/2/3 and stalled passes1/2/3 all report errors0/raw_errors0; each independently perturbs Q before LOAD. [original_combined/stalled.log](original_combined/stalled.log).

22. **Original SAVE-only post-fix:** Both pass0 suffixes are exact: unstalled and original transport stall. The original 98 differing pairs become zero.

23. **Transport sweep:** No-stall, busy13/31, seeded LFSR busy12/16, and long busy2020/2048; read latency1/3/29; repeated LOADs. Pending-event cases pass each profile. A representative full 900,000-clock flush also passes; other fixtures use the established controller test adapter/fast flush. Results compare logical clocks outside frozen transport.

24. **First-sample matrix:** Every audio suffix compares both outputs, phase, complete raw PSG state and divider at k0 and every following clock. First eight samples are logged. Phase0/1, native0/10/20/25, pre-/pending/post-event cases, and twelve focused phase×divider13/14/15 neighbors pass. Event assertions prohibit duplicate replay or replay while frozen/preparing/restoring.

25. **Stereo stress:** Strong-left, strong-right, left-only, right-only and panning changes pass. The 35-case matrix deliberately decouples component controls for coverage; ten additional cases use literal SMS/GG/System E chip-select and panning decode, plus twelve literal GG boundary cases. The synthetic component matrix is not claimed as literal guest-mode reachability.

26. **Tone:** Tone6 and additional tone/channel combinations pass across SAVE and repeated LOAD, including the newly mandatory pending-tick witness.

27. **Noise:** Noise fixture compares 48,000 clocks per suffix. Existing raw regression separately covers eight noise controls across all16 divider phases.

28. **Mixed PSG:** Mixed tone/noise and multiple channels pass, as do identical future attenuation/frequency writes after each restore. No FM input/history is part of this oracle.

29. **Silence transitions:** Silence-to-signal and signal-to-silence futures pass from the exact first resumed pair. Silence is not used to mask changing-signal or channel-order witnesses.

30. **System E dual PSG:** Primary only, secondary only and dual sum pass, including pending event on both and asymmetric source signals. Literal A2-based chip-select tests exercise independent chip writes and shared enable/replay timing.

31. **Repeated LOAD:** 129 LOADs across the expanded audio matrix, each to the same immutable complete image after differing Q history; plus six original LOADs. Most audio cases use three LOADs, selected long/Pause/boundary/search cases one. Full-image knownness and immutability are asserted.

32. **Pause:** Paused M1 capture needs no progress; paused non-M1 capture uses bounded coherent progress (observed CPU7/PSG5 enables) to reach capture while preserving host Pause. SAVE and LOAD stay logically paused; 950,000-clock suffix later unpauses and remains exact. Private CPU replay holds both raw PSGs and is bounded to48 clocks. This uses the authorized F12 exception to exact stopped-reference equivalence during seeking only. No extra resumed half-stereo update appears.

33. **Post-fix non-injective search:** Natural distinct earlier PSG/audio histories produce equal complete v16 images (SHA256 ccf1d6a6e968a86137e36e75dcdef0345c64154ae08777d75f54d7c04f554d23) and equal future stereo/raw/phase suffixes. Full 96KiB image equality, not only phase equality, is checked. No counterexample remains in the tested boundary/history search; structural sufficiency is in item16.

34. **G10 regression:** CLOSED remains unchanged. Native enable order/divider restoration, first resumed phase, private CPU preparation isolation, transport independence and all four accepted phase classes pass. The event omission fixed here does not contradict G10’s deterministic divider/CPU restart contract.

35. **Raw PSG regression:** Existing regression:128 cases ×20,000 clocks =2,560,000 raw compared clocks, all16 divider phases and eight noise controls; PASS, no ModelSim warnings/errors. New integration comparisons additionally check both raw PSG suffixes including replay. No broad raw PSG serialization redesign.

36. **G05/G06 sanity:** Background42000-pixel suffix and sprite collision(two sprites)/overflow(nine sprites)1000-sample suffixes each pass SAVE plus three LOADs against independent uninterrupted references. These targeted fixtures use the ordinary eight-sprite limit for ModelSim capacity; physical64-slot packing is unchanged and not reproven here. Earlier completed64-slot references are retained in controls64; interrupted DUT pilots are excluded from pass counts. The final legacy guard changes only ARM’s initial LOAD phase, overwritten by these tagged images before use; adapter identity bridge is checked.

37. **Simulation ledger:** Eight final groups: component matrix35; literal modes22 (ten modes+twelve boundaries); original witness2 transport cases; raw PSG128; format911 accepted/rejected scenarios; legacy18 LOADs; background1; sprites2. These comprise1119 heterogeneous scenarios, not1119 independent system programs. Audio matrices compare 6,412,000 stereo clock pairs, plus160000 original pairs. See [simulation_results.json](simulation_results.json) for exact case/load counts and completed-log hashes. Historical failing baselines/prototypes and interrupted/pilot runs are excluded.

38. **G08.release:** CLOSED - FIXED AND PROVEN for the accepted production non-FM capture/restart contract. AudioMix phase and pending PSG event defects are both corrected.

39. **G08.FM:** OPEN - BLOCKED BY F01. Overall G08 is not fully closed. No OPLL/FM historical-state investigation; F06/G11/G12 are out of scope.

40. **Quartus setup:** +0.141ns; fresh v15 +0.211ns, delta -0.070ns; retained v15 +0.211ns, delta -0.070ns.

41. **Quartus hold:** +0.243ns; fresh v15 +0.232ns, delta 0.011ns; retained v15 +0.232ns, delta 0.011ns.

42. **Timing violations:** 0 failing timing-summary checks; fresh v15 0, retained v15 0. All clock-domain setup/hold/recovery/removal/minimum-pulse-width summary checks and TNS are retained in build_results.json. Both flows retain the pre-existing TimeQuest information that setup/hold are not fully constrained; zero reported violations applies under the unchanged SDC, not to unconstrained paths.

43. **ALMs needed:** 36,068/41,910 (86.061%). Delta vs fresh committed-v15 control: +123; vs retained committed-v15 build: +123.

44. **ALMs placed:** 38,816/41,910 (92.618%). Delta vs fresh committed-v15 control: +98; vs retained committed-v15 build: +98.

45. **Fitted registers:** 48,258/167,640 (28.787%). Delta vs fresh committed-v15 control: -127; vs retained committed-v15 build: -127.

46. **M10K:** 487/553 (88.065%). Delta vs fresh committed-v15 control: +0; vs retained committed-v15 build: +0.

47. **Memory bits:** 3,809,858/5,662,720 (67.280%). Delta vs fresh committed-v15 control: +0; vs retained committed-v15 build: +0.

48. **DSP:** 39/112 (34.821%). Delta vs fresh committed-v15 control: +0; vs retained committed-v15 build: +0.

49. **Warnings and resource assessment:** New warning types: none. Candidate critical warning messages: 38; fresh control: 38. 0 normalized new messages require review (see build_results.json). Both builds use Quartus17.0.2, seed1, source-only fresh databases, identical QSF/SDC/IP and matched generated build date. New/removed normalized message details (including unnumbered warnings) and entity/packing attribution are in [build_results.json](build_results.json). Placed utilization rises 0.234 percentage points, leaving 3,094 ALMs unplaced. This is a small measured increase, not substantial growth. The global packing identity A-B+C changes by +98-30+55=+123 needed ALMs; logic ALUTs change +72 and route-through ALUTs -117. Both synthesis summaries report45,808 registers. The fitted -127 register delta is therefore attributed to global fitter optimization/duplication redistribution, not removed architectural state; entity deltas are retained. Setup loses0.070ns but stays positive at0.141ns; no new timing or warning failure. All136 build inputs are hash-verified (134 tracked committed/candidate inputs plus two identical unused retained backup files). Both full flows ran only after the completed simulation gate, with source-only isolated databases, identical device/tool/seed/settings and matched build date. No generated Quartus artifacts are tracked.

50. **git diff --stat:** 

```text
 SMS.sv            |  3 +++
 rtl/jt89/jt89.v   |  3 +++
 rtl/jt89/jt89.vhd |  1 +
 rtl/savestates.sv | 29 ++++++++++++++++++++---------
 rtl/system.vhd    |  5 +++--
 5 files changed, 30 insertions(+), 11 deletions(-)
```

Tracked-file stat excludes the new untracked test/evidence directory.

51. **git status --short:** 

```text
 M SMS.sv
 M rtl/jt89/jt89.v
 M rtl/jt89/jt89.vhd
 M rtl/savestates.sv
 M rtl/system.vhd
?? tests/
```

The repository already held historical tests under untracked tests/. They are retained. New work is under tests/savestate_g08_release_fix; Quartus build directories and simulator caches are ignored. Nothing staged; no commit, push or PR.

52. **Recommendation:** READY TO COMMIT. User review/commit remains separate; no repository publishing action was taken.
