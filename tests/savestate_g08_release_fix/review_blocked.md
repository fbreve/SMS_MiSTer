# G08.release fix: stopped at the pre-implementation sufficiency gate

**FIX INCOMPLETE — NOT READY TO COMMIT. Production RTL and v15 are unchanged.**
The phase-only prototype fixes every original witness, but a natural accepted
SAVE boundary exposes a separate pending-PSG-tick loss on unchanged v15. It
produces a core audio mismatch even when mixer phases agree. The requested
strict raw-PSG oracle therefore fails before production implementation.

The user's Phase8 says **“Do not alter raw PSG savestate semantics.”** A scope
clarification is pending before extending implementation to the newly exposed
capture/restart behavior. The “unless contradictory production evidence is
found” condition has been satisfied for investigation; it is not treated as
permission to disregard that explicit implementation constraint.

1. **Baseline HEAD:** `f205b05dc058fc5f7f2432779b61e8f3b0e22519`, branch
   `fix/savestate-g08-release`, created as requested. [baseline.json](baseline.json)
   preserves all203 tracked-file hashes. Historical test reports are unchanged.

2. **Baseline format:** committed v15, tag48430f, 96KiB container. No new
   production format has been introduced. v16 exists only as a test-directory
   proposal for the corrected historical phase interpretation.

3. **Original LOAD reproduction:** fresh baseline runs reproduce14 differing
   stereo pairs per20,000-clock suffix on every LOAD, beginning at k1152.
   Raw PSG/config/ext/div/output and clkd remain exact on those witnesses.
   [baseline/unstalled.log](baseline/unstalled.log).

4. **Original SAVE-only stall reproduction:** unstalled SAVE is exact;
   legal busy13/31 transport gives14 differing pairs at k1152+1440n.
   Three LOADs on each transport profile reproduce the original six failures.
   Total98 differing pairs. [baseline/stalled.log](baseline/stalled.log).

5. **First divergent state:** for the original defect, AudioMix.toggle differs
   at the first resumed clock, before the later opposite channel latches.
   The new independent counterexample first differs earlier in the pipeline:
   cen_16 differs at the falling edge immediately following accepted T.

6. **Complete sequencing inventory:** [design_pre_edit.md](design_pre_edit.md)
   records widths, reset/update/freeze/LOAD/restart/consumer and classifications.
   AudioMix has toggle1, audio_l16 and audio_r16; in1/in2/sum/clipped are
   combinational17-bit buses, not accumulators. PSG stereo sums are11-bit
   host-clock registers. ce_snd is an unused declaration. Core AUDIO_L/R are
   direct output wires, signed by AUDIO_S=1. The extended raw source inventory
   remains [the investigation inventory](../savestate_g08_release/state_inventory.md).

7. **Original LOAD root cause:** late ST_FREEZE saves transport-time toggle,
   then the first resumed clock interprets it as the T+1 channel selection.
   In the original witness it stores1 where next-update phase0 is needed.

8. **Original SAVE root cause:** no phase installation occurs on SAVE-only
   release. Toggle continues through transport, so transport parity chooses
   the first resumed channel even with identical PSG and divider history.

9. **Shared cause:** both original failures lack a boundary-relative phase
   handoff. LOAD uses the wrong saved phase; SAVE uses the advanced live phase.
   The new pending-PSG failure has a separate cause and must not be folded into
   that conclusion merely because it also produces stereo output differences.

10. **A — freeze whole AudioMix:** holds SAVE phase, but LOAD still needs
    historical phase and a way to refill outputs without leaking Q. Freezing
    the whole mixer prevents its existing reconstruction. More control/state
    than necessary for the original phase defect; does not repair lost PSG tick.

11. **B — preserve boundary phase:** one historical bit suffices for the
    original witnesses. Existing descriptor020 bit45 can carry it. Capture at
    ARM, install at first resumed clock on both SAVE and LOAD. No new output
    bus, adder, RAM or DSP. This is the tested prototype, not a complete fix.

12. **C — phase plus accumulator:** no registered partial accumulator exists.
    Extra accumulator bits have no consumer justification and do not repair
    a tick lost before source capture.

13. **D — arbitrary canonical phase:** cannot generally preserve which channel
    updates next under identical changing future inputs. Existing LOAD/history
    can decouple toggle from clkd parity. No sufficient zero-history phase
    canonicalization was proven. It cannot restore the missing source tick.

14. **E — freeze plus bit:** could preserve phase with added refill sequencing,
    but is more intrusive than B and still requires a coherent source boundary.
    Stereo/SystemE share the same phase; Pause must retain its current host
    policy. No speculative area saving or correctness claim is made.

15. **Proposed design:** B, with post-T phase captured before ARM's host edge
    advances AudioMix, and explicit first-resumed installation for SAVE/LOAD.
    Late raw-PSG capture remains unchanged in the phase-only prototype.
    Candidate production scope would have been rtl/savestates.sv only.

16. **Sufficiency:** **FAILED**. Both original cases pass the phase prototype,
    as do three broader natural-history/real-CPU-write cases, but an accepted
    phase10/div14 capture fails raw equality at k0. The same failure is
    independently reproduced with unchanged production controller and PSG.
    [sufficiency.json](sufficiency.json) remains explicitly false; it is not
    an implementation/build approval gate.

17. **Format decision:** v16 proposed, not introduced. The corrected historical
    next-channel interpretation would reuse existing bit45 and tag484310;
    BG/sprite schemas and container length would remain unchanged. The
    production format is still v15 while sufficiency is blocked.

18. **Legacy:** proposal normalizes unavailable pre-v16 next-update phase0
    deterministically; it cannot claim exact recovery of old transport phase.
    No production compatibility behavior has changed or passed new validation.

19. **Production files changed:** none. Only this fix's test/report directory
    was authored. proposed/savestates.sv is an unapplied, unapproved proposal;
    prototype adapters are isolated test code, not production changes.

20. **Original LOAD post-prototype:** zero audio and raw differences on all
    original LOAD suffixes. These results are prototype evidence, not a final
    production post-fix claim. [prototype/unstalled.log](prototype/unstalled.log).

21. **All six original LOADs:** all six prototype replays match20,000 immediate
    logical host clocks each, first resumed pair included. The baseline six
    all reproduce14 pair errors. No tolerance or grace clocks were used.

22. **Original SAVE-only post-prototype:** both original transport profiles
    match exactly with explicit phase installation. [prototype/stalled.log](prototype/stalled.log).

23. **Stall sweep:** the two original profiles were reproduced and corrected
    by the prototype. The broader duration/phase matrix is blocked after the
    new strict SAVE-only failure; it is not reported as passing.

24. **First-sample matrix:** tested both natural mixer phases (BOOT6/BOOT7),
    with immediate first-edge raw/audio/phase equality in the passing cases.
    A natural phase10/div14 boundary contradicts universal sufficiency: k0
    raw state differs and k3 AUDIO_R differs despite equal mixer phase.

25. **Stereo stress:** real T80 OUT7f PSG attenuation and OUT06 panning loop,
    including left-only/right-only switching, passes one-LOAD prototype replay
    in the phase1 case. It has193 changing reference pairs/24,000 clocks.
    The pending-tick witness uses the same legal guest loop and exposes
    right-only architectural corruption. Full requested routing matrix is
    blocked, not inferred from these cases.

26. **Tone:** original period6/attenuation0 passes all phase-only original
    witnesses. Broader same-image history pair passes one LOAD per history.

27. **Noise:** no separate completed noise-only fix matrix after the gate
    failure. Raw extended state comparisons include actual second PSG
    counters/sample state, but this is not noise-only audio coverage.

28. **Mixed/multiple channels:** one real-CPU-write, multichannel/stereo case
    passes phase-only replay. No general post-production mixed-pattern claim.

29. **Silence transitions:** earlier legal mute/unmute histories converge to
    equal complete images and futures. Guest panning switches between silent
    and active channels. The full requested near-T silence matrix is blocked.

30. **System E dual PSG:** both real PSGs are captured/restored and included
    independently in matrix raw comparison. The selected mixer contribution
    in completed cases is PSG1. Independent PSG2-only and dual-sum audio
    closure remains blocked; neither is called proven.

31. **Repeated LOAD:** six original plus three other phase-prototype LOADs
    pass. Original Q histories vary actual PSG period/attenuation/sample state.
    New raw failure is SAVE-only, requiring no restored CPU, phase payload
    interpretation or Q history to demonstrate it.

32. **Pause:** no new completed paused/unpause matrix. The source-level
    inventory and proposed phase handoff preserve the F12 current-host policy,
    but that is not runtime validation. The authorized bounded coherent
    capture-progress exception remains unchanged.

33. **Natural equal-image search:** HISTORY0/HISTORY1 apply different earlier
    mute/unmute histories under the same immutable ROM/configuration and future
    inputs. Both complete known12,288-word images have SHA256
    `7354ff88aa6e9b50f27b221671f59f899406df1f0385a0fc49cb5b06b339a72c`.
    Both independent24,000-clock futures and SAVE/one LOAD compare exactly.
    Real CPU PSG/panning writes also challenge the output-cache-at-ARM
    overwrite assertion. No equal-representation/different-omitted-cache pair
    was established. That bounded result does not override the newly found
    temporal source failure or establish global injectivity.

34. **G10 regression / contradiction:** restored divider phase is exact in
    the original passes. New positive evidence contradicts the broader
    assumption that accepted T plus immediate guest hold preserves PSG work
    belonging to T. This is capture-edge peripheral ordering, not arbitrary
    divider release drift. The real preparation-hold assertions still run;
    deterministic release alone cannot repair a source event already lost.

35. **Raw PSG regression:** original suffixes still agree; the new raw oracle
    fails at the FIRST resumed clock. Production source causal chain:
    SMS.sv1014 gates system.ce_cpu immediately with ss_freeze;
    system.vhd788/809 forwards that to JT89;
    jt89.v87 computes cen_16 on the falling edge from gated clk_en and divider;
    savestates.sv1141 asserts hold on accepted T.

    | Event | DUT and uninterrupted reference |
    |---|---|
    | T=658780, clkd10 | Real M1/MREQ accepted at PC0034; PSG divider14 increments to15; tone cnt2 in both |
    | T+half falling edge | DUT freeze forces clk_en0: cen_16=0. Reference retains accepted raw enable long enough for cen_16=1 |
    | T+1=658781, clkd11 | Divider15 in both; reference tone cnt2→1 and historical volume sample updates; DUT cnt stays2 |
    | First resumed k0 | Full raw cfg/ext/div/stereo compare fails even on baseline SAVE-only |
    | k3 | AUDIO_R=-416 (`fe60`) versus expected -4080 (`f010`); AUDIO_L=0; mixer phase0 in BOTH |

    [Strict unchanged-v15 failure](raw_baseline/bus_capture10_div14/replay.log),
    [bounded architectural characterizer](raw_characterization/bus_capture10_div14/replay.log).
    The diagnostic reports differences for16 clocks and explicitly labels
    completion as a characterizer, never a functional pass. This does not
    establish that extra historical PSG bits are necessary: replay/completion
    ordering must be designed before choosing a representation.

36. **G05/G06 sanity:** not run after the pre-edit gate failed. Production
    freeze/restart/VDP sources remain byte-identical. Byte identity is hygiene,
    not a substitute for the requested post-implementation VDP sanity.

37. **Runtime accounting:**18 completed invocations:8 independent oracle runs
    and10 DUT runs. These comprise6 original baseline/prototype invocations,
    6 natural-history/real-CPU-write prototype invocations, 2 prototype raw-edge
    invocations, 2 unchanged-baseline raw-edge invocations and2 bounded raw
    characterizer invocations. Two strict DUT runs intentionally fail on the
    new counterexample; baseline/diagnostic characterizers reproduce errors.
    Five positive prototype DUT cases pass; they are not final production
    coverage. Stopped unreachable-target pilots and corrected compile errors
    are excluded. [audit.js](audit.js) verifies these distinctions.

38. **G08.release:** **FIX INCOMPLETE**. Its original phase defect remains
    confirmed in production. A sufficient phase-only prototype is not yet
    established for all required accepted boundaries.

39. **G08.FM:** **OPEN - BLOCKED BY F01**. No OPLL investigation/fix or overall
    G08 closure. FM contribution is zero in every oracle used here.

40. **Quartus setup:** not run; simulations have not passed the required gate.

41. **Quartus hold:** not run.

42. **Timing violations:** no candidate build result. Do not reinterpret
    absence of a build as zero violations.

43. **ALMs needed:** candidate N/A; retained committed-v15 baseline35,945 /
    41,910 =85.767%. No measured candidate delta.

44. **ALMs placed:** candidate N/A; retained v15 baseline38,718 /41,910 =
    92.384%. Placement pressure remains a design constraint.

45. **Fitted registers:** candidate N/A; retained baseline48,385 /167,640 =
    28.862%. No measured delta.

46. **M10K:** candidate N/A; retained baseline487 /553 =88.065%.

47. **Memory bits:** candidate N/A; retained baseline3,809,858 /5,662,720 =67.280%.

48. **DSP:** candidate N/A; retained baseline39 /112 =34.821%.

49. **Warnings:** no new Quartus comparison. Existing ModelSim CPU width and
    reference-wrapper unused/default-port warnings remain visible. They do not
    cause the cen_16 event difference, which follows explicit production logic.

50. **git diff --stat:** empty tracked diff. All203 baseline tracked hashes
    remain identical. Nothing staged; test/report additions are untracked.

51. **git status --short:** `?? tests/`. Existing tests predate this task;
    only this new fix directory was authored. No production fix, Quartus,
    generated Quartus artifact, commit, push or PR.

52. **Recommendation:** **NOT READY TO COMMIT.** First resolve the pending PSG
    capture/restart event under an explicitly agreed scope/contract, then
    re-establish the joint sufficiency proof before production implementation.
    Preserve both original phase witnesses and the new SAVE-only phase10/div14
    counterexample. Validate logical T+1 source/pipeline ordering, both phases,
    CPU PSG/panning writes, dual audio, Pause, broader transport/phase cases,
    legacy policy, VDP sanity and only then controlled full Quartus. Do not
    blindly add PSG state bits, serialize output buses, hide the first sample
    or weaken raw equality to make the phase-only candidate appear sufficient.

Reproduction: [README.md](README.md). The final evidence audit succeeds only
when the expected failures remain present and production remains unchanged;
its successful exit does not turn sufficiencyPassed=false into an approval.
