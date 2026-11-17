# G08.release investigation on committed v15

**CONFIRMED - FIX REQUIRED.** The changing, non-FM tone suffix diverges after
LOAD and after a stalled SAVE-only transfer. The raw PSG state, raw PSG samples
and divider phase remain exact. The defect is the AudioMix alternating channel
phase across transport/release. No production fix or format change is made.

1. **Current HEAD:** `f205b05dc058fc5f7f2432779b61e8f3b0e22519`, on
   `investigate/savestate-g08-release`. The branch was created from the committed
   G05 baseline. [baseline.json](baseline.json) preserves tracked-file hashes.

2. **v15:** production tag `48430f`, background descriptor
   `008b0f0047354231`, inherited v14 sprite and deterministic restart records.
   Container remains 12,288 words / 98,304 bytes. The final experiment writes
   and repeatedly reads the current controller's actual complete image.

3. **G08 split:** G08.steady remains CLOSED - JUSTIFIED EXCLUSION;
   G08.release is now CONFIRMED - FIX REQUIRED;
   G08.FM remains OPEN - BLOCKED BY F01. The six requested reports were read
   completely; their hashes are recorded in [results.json](results.json).
   Their historical readiness/format versions are not current integration proof.

4. **Inventory:** [state_inventory.md](state_inventory.md) covers every sequential
   element from PSG output through final core AUDIO_L/R, plus the serialized
   input state and capture transient ordering. Post-oscillator storage comprises
   each PSG's four serialized 9-bit channel samples, two unsaved 11-bit PSG
   output registers, AudioMix toggle and two 16-bit output registers.

5. **audio_l:** updates on each host rising edge selecting phase0. It has no
   reset, freeze gate or literal LOAD. Restored stable inputs reconstruct it
   before release. In the witness, LOAD selects it one host clock later than
   reference at every PSG sample transition. This is a release-order defect,
   not evidence that the 16-bit output cache itself must be serialized.

6. **audio_r:** same behavior with phase1. LOAD selects it one clock earlier
   than reference. The pair at the first failing transition is therefore
   reversed even though the source is mono.

7. **Mixer/output pipeline:** raw PSG channel samples feed registered PSG
   stereo sums, combinational signed scaling by16, and AudioMix's alternating
   saturated signed sum. Final SMS AUDIO_L/R are direct wires. There is no
   core filter or unsigned conversion between AudioMix and those ports.
   AUDIO_S=1 declares signed audio. MiSTer host filtering, asynchronous stable
   input sampling, IIR/DC/ALSA/volume and physical DAC/I2S/SPDIF histories occur
   after this core boundary; they are not used as a rewind oracle or assumed
   to conceal the observed core-port discrepancy.

8. **ss_freeze:** holds guest PSG enables and restored synthesis state;
   PSG output registers and AudioMix continue clocking. AudioMix toggle changes
   on every transport clock. The controller's late audio capture is after drain,
   rather than at accepted logical T. SAVE release does not install audio phase.

9. **v15 restart:** historical CPU preparation holds PSG guest enables; falling
   edge phase commit installs the saved divider class with enables zero, then
   commits beam/release. LOAD asserts audio_phase_set for the first resumed
   host rising edge. AudioMix uses the saved phase for that edge's output
   selection. This witness uses the real protocol, actual T80 replay and real
   divider recurrence, not an invented common enable schedule. It establishes
   that canonical guest enables alone do not establish mixer alternation.

10. **Logical mapping:** accepted T is rising edge cycle656670, divider0.
    The independent reference continues normally; its next rising edge is
    logical T+1. DUT comparison k0 is the FIRST rising edge after phase/beam
    release, corresponding to that same T+1. Each next host rising edge maps
    to the next logical host edge. Every 16-bit channel value is compared
    exactly; there is no skipped settling interval or tolerance. Transport
    and private CPU normalization are excluded. The continuously visible
    release-edge pair is already the settled `0ff0/0ff0` in this witness;
    k0 also agrees. The first disagreement is a later source transition.

11. **Tone-only:** period6, attenuation0, PSG1, FM zero. Startup asserts that
    both actual PSGs used by DUT/reference contain tone0=6; captured cnt4,
    out1, raw output+255. The reference includes positive, negative and both
    transitional channel pairs. It is not silence or a constant-level proof.
    [final_reference.log](final_reference.log), [final_replay.log](final_replay.log).

12. **Noise-only:** not run after sufficient defect confirmation; stop rule.
    No contradictory raw noise-state evidence was established.

13. **Tone+noise:** deferred under the same stop rule.

14. **Multiple channels:** deferred. The mono source already produces
    different independently observable left/right pairs during transitions.

15. **Near-SAVE register changes:** the confirmed witness needs none. Legal
    attenuation/frequency writes are exercised during Q, not relabeled as
    near-T coverage. Near-T attenuation/noise/frequency sweeps remain fix
    validation requirements.

16. **SAVE-only:** unstalled transport92940 clocks preserves the needed mixer
    parity: 0 differences /20,000 pairs. Legal transaction-qualified busy
    windows13/31 yield transport159785 clocks: 14 differing pairs, first k1152.
    The saved image is independent of these later transport stalls. Thus
    SAVE-only output also depends on transport duration.

17. **LOAD:** all six current-format LOAD suffixes (three per transport case)
    have 14 pair differences each. No raw PSG/config/ext/div/output or clkd
    comparison differs in any of the 160,000 scored replay clocks. The format
    is read by the actual current controller; no side record restores audio.

18. **First resumed sample:** k0 equals `0ff0/0ff0` for SAVE and LOAD. No old
    Q output survives to k0 in this witness. The FIRST differing observable
    pair is k1152, the 1153rd resumed rising edge, at clkd13/div15:
    reference L/R=`f010/0ff0` (-4080/+4080), LOAD=`0ff0/f010` (+4080/-4080).
    It is a deterministic digital output error even though the initial
    constant portion of the suffix matches.

19. **Duplicate/missing samples:** k1151 raw PSG becomes -255 while both core
    channels still hold +4080. At k1152 reference updates left and LOAD updates
    right. At k1153 both reach -4080/-4080 again. One channel retains its old
    sample one extra host clock and the other changes one clock early. The
    effect repeats every1440 clocks, at k1152+1440n for n0..13. There is no
    missing/duplicate raw PSG tick and no allowed wall-clock alignment that
    makes both channel sequences equal at logical time.

20. **Adversarial Q:** three legal bus-programmed histories before LOAD set
    tone0=0/1/2 and attenuation0/1/2, yielding raw output255/203/161 and core
    steady pairs0ff0/0cb0/0a10. Distinct cfg/ext/div traces are retained as
    Q_HISTORY records. LOAD returns each to the same expected raw tone6
    trajectory and the same wrong mixer alternation. No internal historical
    register is deposited to manufacture the mismatch.

21. **Release-phase sweep:** two legal transport profiles, with naturally
    evolving pre-release phase, retain exact restored clkd suffixes. A complete
    all-phase/audio-mode cross product is deferred once this counterexample
    satisfies the stop rule. No general G10 reopening is inferred.

22. **Transport duration:** unstalled versus deterministic busy profiles
    produce the SAVE-only parity distinction above. At logical k0 the
    unstalled SAVE's next toggle is1, whereas LOAD and stalled SAVE's next
    toggle is0. First native enables and raw PSG history still agree.

23. **Repeated LOAD:** three per case, six total, all from an immutable full
    image. The test rejects any changed image word after each suffix and any
    unknown saved word. All LOADs reproduce the same phase error independently
    of Q. Repeatability of the wrong result is not correctness.

24. **System E PSG1:** actual System E capture/replay cadence, actual PSG1
    routed with the production signed scaling. This is the confirmed path.

25. **System E PSG2:** an actual second JT89 participates in production
    controller capture/restore and quiescence. Its mixer contribution is
    disabled, equivalent to psg_enables(1)=1. Independent PSG2-only scoring
    was not run after confirmation and is not claimed.

26. **Dual PSG sum:** deferred. The mixer defect already occurs with one
    source; no inference that independent dual-channel summation passed.

27. **Stereo/GG:** separate L/R values are scored on every host clock. The
    mono transition creates strongly different observed pairs and detects
    the phase reversal. Guest stereo panning/GG routing variants remain
    deferred under the stop rule; they are not claimed from mono coverage.

28. **Silence transitions:** Q includes a mute write, then unmute and different
    attenuation, but no independent near-T silence-transition matrix was run.

29. **Non-injective search:** the complete known image is retained, and no
    image word changes during any LOAD. The two SAVE transport variants
    produce equal complete images but different resumed stereo suffixes.
    This is a positive same-image/different-transport resume counterexample.
    It is not a pair of naturally accepted A/B states with different
    audio_l/audio_r caches at T: both variants capture the same T. No such
    cache-state pair was established before the defect-stop rule applied.
    Extra serialized output-cache bits are therefore not justified by this
    evidence. See results.json for binary little-endian image SHA256.

30. **FM isolation:** second mixer input is literal zero, matching disabled
    FM/disabled second-source contribution. No OPLL output participates in
    the oracle. F01 was not investigated.

31. **F12 Pause:** the real retained UI gate is present and the running case
    stays unpaused. Paused non-M1 seeking, LOAD while paused and later unpause
    are deferred after confirmation. The authorized bounded coherent capture
    progress exception remains unchanged; this task does not claim new paused
    audio proof or alter that host contract.

32. **G10 sanity:** every scored clkd and raw PSG divider/output suffix
    matches the independent uninterrupted schedule. Private preparation
    assertions retain the existing 48-clock bound and both PSG state hold.
    The error is the separately clocked mixer phase, not restored divider
    phase or extra preparation PSG execution. G10's existing scoped closure
    remains intact.

33. **PSG restoration sanity:** PSG1 full cfg56/ext96/div4/raw L/R22 compares
    exactly each logical host edge. Zero raw errors across both replay cases.
    Raw PSG completeness and G08.steady are not reopened.

34. **Simulation counts:** two final groups (uninterrupted oracle generation
    and replay/transport characterization), three completed runtime cases:
    one reference plus two DUT transport cases. Two SAVE-only segments,
    six LOADs, 160,000 pair comparisons and matching raw-state/phase checks.
    DC-only, stopped target pilots and preliminary characterizers are excluded.
    PASS CHARACTERIZED denotes successful reproduction, not passing audio.

35. **Audio divergences:** 98 differing stereo pairs /160,000 scored pairs:
    42 across three unstalled LOADs; 56 across stalled SAVE+three LOADs.
    Each affected pair has both channels different. Initial k0 pairs agree.

36. **Complete-v15 equal-image result:** one positive cross-transport
    SAVE-only equal-image/different-output pair, six immutable-image LOADs.
    No distinct-cache-at-acceptance A/B collision established. Images are
    12,288 fully known words; full-image equality is not a masked audio-header
    comparison. Other endpoints are known mocks, so this is not a claim of
    naturally reachable complete VDP/memory game-machine history.

37. **Final classification:** **G08.release = CONFIRMED - FIX REQUIRED.**
    The sufficient causal chain is accepted post-T phase0, late descriptor
    phase1, first-resumed LOAD selects that late phase, exact raw waveform
    with opposite channel-update order. Late capture occurs at cycle656704;
    phase1 is read before that edge, 34 host edges after T. Reference phase
    after T is0; the saved phase therefore describes a different logical edge.
    The first resumed clock uses the saved phase correctly according to the
    present interface, but the phase's temporal meaning is wrong. SAVE-only
    additionally permits transport parity to choose channel alternation.

38. **Remaining FM status:** **G08.FM = OPEN - BLOCKED BY F01**, regardless
    of the non-FM defect. G08.steady remains closed within its original scope.

39. **Limits:** no production fix/prototype, full phase sweep, independent
    noise, dual-sum, GG panning, paused/unpause or physical host-sampler run.
    These are explicit stopped obligations, not passes. Real T80 supplies
    natural acceptance; audio register writes are legal fixture bus writes,
    not CPU-programmed OUTs. Known mocks supply non-audio endpoints. Both
    mixers are seeded through their public phase input during initial reset,
    followed by the entire natural prefix. TB_FAST omits only LOAD flush time;
    retained settlement/replay is real. A longer flush cannot correct the
    late phase value explicitly selected on the first resumed LOAD clock.
    No audible/perceptual or physical DAC severity estimate is asserted.

40. **Production/v15 hygiene:** all baseline tracked hashes unchanged;
    no production RTL, format, historical report or active mapper review edit.
    Only this investigation directory was authored. No Quartus, staging,
    commit, push or PR. Existing untracked tests predate this task. The final
    audit checks branch, HEAD, image validity, exact expected counterexample,
    raw equality, three distinct Q histories and empty tracked/index diffs.

41. **git diff --stat:** empty (tracked production and index unchanged).
    New investigation evidence is untracked and absent from that stat.

42. **git status --short:** `?? tests/`. Simulator libraries/waves/configuration
    and duplicate stdout are ignored in this investigation directory.

43. **Exact next task:** separately authorize a G08.release mixer-phase
    correction. Establish phase representation at accepted logical T and its
    first-resumed update meaning for both SAVE and LOAD; prove the required
    output-cache refill ordering before choosing RTL or format changes.
    Preserve v15 PSG/G10/F12 contracts, then validate this witness plus tone,
    noise, dual PSG, GG stereo, near-T writes, all relevant release/stall phases,
    silence transitions, paused capture/LOAD/unpause and repeated LOAD. Do not
    include F01/G08.FM, G11/G12 or F06 in that fix. This investigation supplies
    no implementation or authorization to implement it.

Reproduction and test adaptations: [README.md](README.md), [run.ps1](run.ps1).
Machine-checked evidence: [audit.js](audit.js), [results.json](results.json).
