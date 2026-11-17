# F11 lightgun savestate implementation review

Base: 77147af4b1c0657d99bfaa840bcb17ad0be5d658; branch: fix/savestate-lightgun.

1. **Original causal chain**

   On committed F10, SS held the pixel-enable pipeline while raw video kept running. The ungated HDE/VDE hit comparator compared that raw activity with held hcnt/vcnt and target x/y. It armed sensor_pend and cleared sensor_time. SENSOR itself stayed low during freeze, then the delayed pulse appeared after resume. Registered inverted TH reached actual io.vhd port DD, producing DUT B4 versus reference F4; production T80 A diverged. No input changes or CPU load were needed. See the preserved investigation and freeze_only_cpu.log.

2. **Registers corrupted during freeze**

   sensor_pend changed 0->1 and sensor_time changed 255->0. The CPU reproducer captured hcnt=253/vcnt=192 and target x=253. The pending/time writes were outside CE_PIX; the other local beam/pulse registers were already held by the top-level gated enable. Host cursor/button sampling was separate from this defect.

3. **Selected freeze boundary**

   Explicit SS_FREEZE guards both the CE_PIX temporal pipeline and the host-clock hit-arm transition. All 74 bits in the guest temporal cone hold during transport, except deliberate state application during load. Host cursor integration, mouse-strobe history, current trigger and crosshair presentation continue sampling normally. Raw VDP/video timing and release alignment are unchanged.

4. **Alternatives considered**

   | Alternative | Decision |
   |---|---|
   | A: guard the hit-arm writes | Necessary: fixes the confirmed save-only corruption |
   | B: hold the local temporal pipeline | Selected together with A; explicit module hold also protects its pixel updates |
   | Freeze the entire always block | Rejected: would hold host mouse-strobe consumption and current trigger/input handling |
   | C: mask SENSOR/TH only while frozen | Insufficient: the original SENSOR was already low during freeze; latent pending state still fires after release |
   | D: mask raw HDE during freeze | Equivalent hit exclusion with the existing gated CE, but explicit ownership guards preserve the block's raw video inputs and make its full temporal hold testable |
   | Serialization without a freeze fix | Insufficient: save-only performs no state restore and still corrupts pending/time |

5. **Serialization decision**

   Required. With the hit guard applied but no payload, the accepted saved reference retained SENSOR=1/time=51, whereas discarded execution reached SENSOR=0/time=255. Load still returned DUT F4 versus reference B4 (freeze_only_stalls0.log). Freezing a later operation cannot recover an earlier saved pulse.
   
   The validated subset is 46 bits: vcnt[8:0], vtotal[8:0], hde_d[15:0], old_hde, offscreen, sensor_pend, sensor_time[7:0], SENSOR. The delayed vertical/HDE history controls learning vtotal and aim scaling; offscreen qualifies a delayed pulse. The first accepted VBlank line does not guarantee that history or the pulse is idle.
   
   The preliminary 74-bit snapshot was reduced: hcnt resets during horizontal blanking; old_vde converges to the blank level; frame x/y latch current aim at VDE rising, while HDE is still blank. Replay asserts their equality before every active hit window. Raw host input, cursor integration, mouse history and presentation state are excluded. See README.md for packing.

6. **Development format**

   Writer is v8: video marker 484308 with the established marker/count field 3. Word 028 holds the 46-bit payload with 18 zero padding bits; word 029 must equal 0000002e4c475538 (width 46, LGU8). Both descriptor and payload padding are validated before use. Prior fields, slot size and RAM/audio/EEPROM offsets are unchanged.
   
   Untagged and v1-v7/old64 files do not invent missing history: they normalize the gun to masked idle SENSOR, no pending event, saturated time and zero vertical history. Other legacy accessory rules remain intact. Unknown/future tags and malformed gun metadata do not consume/use unvalidated history. All legacy versions through v7 are tested.

7. **Files changed**

   Production: SMS.sv (wiring), rtl/lightgun.sv (hold/state interface), rtl/savestates.sv (validated capture/transport/restore). New permanent tests and evidence live in tests/savestate_lightgun_fix/. Existing untracked regression generators received writer/future-version expectations, new unused-input ties and explicit positive v7 cases; original generator text is retained in regression_sources/. The authoritative F11 investigation artifacts were preserved.

8. **Exact RTL change**

   The two behavioral guards are:
   
   ~~~systemverilog
   if (!SS_FREEZE && CE_PIX) begin ... end
   if (!SS_FREEZE && HDE && VDE && x == hcnt && y <= vcnt && y > vcnt - 8) begin
       sensor_pend <= 1'b1;
       sensor_time <= 8'd0;
   end
   ~~~
   
   SS_STATE_SET has restore priority for the 46-bit subset. SS captures it after the existing freeze/drain boundary, adds matching DDRAM command-preview and FSM handlers, and applies it before the later VDP/F07 restore. The new v8 path also settles only IO control direction bits 1 and 3 early, preserving all other current IO bits; the ordinary full IO restore remains in its existing stage. Applying gun state early alone failed when discarded control was 00 and saved control FF: HCounter 92 was overwritten with 00 by the later direction edge. The coupled F11 restore now settles TH/HL before F07 installs its saved latch and re-primes the edge detector. Both ports have permanent positive regressions for this case. No normal arithmetic, hit condition, pulse length or host-input expression changed.

9. **Production-T80 save-only regression**

   PASS: four profiles, ten qualified real I/O-bus sampling opportunities each, zero differences. Both CPUs' complete register outputs (including A), controller reads, SENSOR, HL, HCounter latch and NMI match after release. The old B4/F4 mismatch is gone. These are 40 qualified bus samples, not 40 IN instructions. Actual IRQ input is inactive; there is no gun-specific IRQ. T80 production sources are unchanged; fixture copies only add ModelSim direct-entity syntax.

10. **Accepted-boundary save/load replay**

    PASS: 61 full save/perturb/load pairs, with real production savestate DDRAM transport and I/O. They include eight original boundary/profile cases, 33 target/configuration sweeps, 16 capture-phase cases, two HCounter guards and two discarded-direction coherence cases. All originally positive and negative windows now match. Each replay compares the first tested DD read, TH/SENSOR/HL/HCounter/NMI and continues 1,300,000 future host clocks. Omitted horizontal/frame fields must converge before HDE+VDE can form a hit.
    
    The actual-T80 proof is save-only; full-load observations use legal I/O strobes and event comparison, without extending scope into F01 CPU restore/microcycle behavior.

11. **Case/sweep accounting**

    49 timing cases = 33 investigation target/video configurations plus 16 requested capture-phase cases. Configurations cover NTSC/PAL, 192/224/240 modes, border cases and aim extremes; additional original variants cover both ports and regions. Actual CPU acceptance can round two requested phases to the same eligible tick; logs distinguish acceptance from the subsequent ARM capture. The investigation's 332424 hypothetical acceptance observations are not counted as saves or CPU instructions. Including four T80 saves, 122 replay transactions and 76 format transactions, the new controller-transport coverage is 202 operations.

12. **Transport duration independence**

    PASS: no stalls, deterministic stalls, randomized stalls and deliberately long transport. T80 save-only durations:
    
    | Profile | Frozen host clocks |
    |---|---:|
    | none | 896035 |
    | deterministic | 896035 |
    | random | 896035 |
    | long | 1792075 |
    
    Original boundary profile durations:
    
    | Case | Save clocks | Load clocks |
    |---|---:|---:|
    | stalls0 | 896040 | 1832235 |
    | stalls1 | 896040 | 1840055 |
    | stalls2 | 896040 | 1844925 |
    | stalls3 | 1792080 | 3902025 |
    
    Guest state/events match at equivalent resumed machine time, including the longer transport. These clock counts include the existing alignment/flush semantics.

13. **Current external input**

    PASS: eight cases and 32000 held-state observations, plus one million ordinary cycles against F10. This module has no physical sensor-bit input; SENSOR is synthesized from beam and aim. Tests cover captured SENSOR inactive/active, current aim moving into/out of range, press/release, mouse strobes/deltas and changed input at resume. Current trigger and mouse-strobe history keep updating during freeze. Already-consumed strobes are not replayed. Local pulse history resumes from the snapshot; current/future host aim is sampled by the ordinary input/frame-latch rules. No raw input or host cursor state is serialized.

14. **F07 HCounter interaction**

    PASS: unchanged SMS/GG F07 tests, controller DDRAM checks and integrated two-real-VDP modern/legacy tests. The four focused guard/direction replays require a stable latch during save transport, at least 900000 frozen observations with the saved latch unchanged after F07 restoration, and a legitimate next-frame sensor rise. Future HCounter events match the reference. Intentional TH settling before F07 installs the saved latch is distinguished from a false event after restored state is installed. No VDP/video RTL changed.

15. **Accessory/ordinary regressions**

    PASS: MD6 2560 short-timeout + 160 production-timeout cases and 13 DDRAM cases; Master Tap 4096 + 64 directed cases, 100000 ordinary/raw-serial comparisons and 66 DDRAM cases; Paddle 7832 directed/phase/mode cases, 1000000 ordinary comparisons and 93 DDRAM/routed/combined cases. The added v7 cases cover earlier exact accessory formats. Ordinary SMS/disabled accessory paths and GG I/O also pass.

16. **Required broader results**

    All 135 selected complete simulation/static logs pass and are SHA-256 recorded in results.json. F07/F02/F08/F09/F10/F03/F04/F05/PSG all pass: GG 24 local + 28 DDRAM cases, EEPROM 6642 local + 72 DDRAM cases and persistence, SC RAM 180 DDRAM cases plus negative/full-tail/ordinary/persistence controls, PSG 128 replay cases. Original I/O/EEPROM/MD audit reproductions pass. Static checks compare 136 source/settings inputs to the built committed F10 baseline and restrict tracked changes to the three F11 files.

17. **F06 status**

    Intentionally unresolved. No F06 fix, SRAM visibility/banking change, mapper cleanup or storage ownership change was made.

18. **F12-F16 status**

    Untouched. No F12-F16 implementation or unrelated cleanup. F01-F10 production behavior was not reworked; their compatibility with the new F11 restore sequence was verified; only that new v8 sequence settles coupled gun/TH inputs early.

19. **Quartus result**

    Full Quartus 17.0.2 Build 602 flow completed successfully: analysis/synthesis, fitter, assembler and timing analysis. Device 5CSEBA6U23I7 and seed/settings match F10. Build started only after the complete simulation/static gate passed. Products are isolated under candidate/.
    
    Generated date: baseline 261020; candidate 261021. The established pre-flow script regenerates this date; it is reported separately from the 136 production source/settings inputs.

20. **Timing**

    Worst setup: **0.408 ns**. Worst hold: **0.158 ns**. Timing violation categories: **0**. Every reported setup/hold/recovery/removal/minimum-pulse category has nonnegative slack and TNS when READY.

21. **Resources versus committed F10**

    | Metric | F10 | F11 | Delta |
    |---|---:|---:|---:|
    | ALMs | 27150 | 27369 | +219 |
    | Fitted registers | 36556 | 36598 | +42 |
    | Synthesis registers | 35616 | 35716 | +100 |
    | RAM blocks | 487 | 487 | +0 |
    | Memory bits | 3809858 | 3809858 | +0 |
    | DSP blocks | 39 | 39 | +0 |
    
    The change adds bounded snapshot/restore and FSM/mux logic; it is not a freeze-only implementation because full replay disproved that option. The ALM increase is 0.81% of F10 utilization and the fitted-register increase is 0.11%. This is bounded for the added snapshot/restore, validated DDRAM mux/FSM logic and direction-settle control; no unexpected large increase was found. Physical optimization explains why the fitted-register delta differs from the synthesis-register delta.

22. **Warnings**

    Distinct numbered warnings: 84->84; critical: 38->38. Tool-reported total: 100. New normalized warnings: 0.
    
    No new warnings or critical warnings versus F10.
    
    Inherited simulation notices include the T80 overloaded-and width warning, mixed-port RAM OLD_DATA behavior and Starter Edition capacity/library notices; they are not production changes.

23. **git diff --stat**

    ~~~
     SMS.sv            | 11 +++++++
     rtl/lightgun.sv   | 37 +++++++++++++++++-------
     rtl/savestates.sv | 85 +++++++++++++++++++++++++++++++++++++++++++++++--------
     3 files changed, 111 insertions(+), 22 deletions(-)
    ~~~

24. **git status --short**

    ~~~
     M SMS.sv
     M rtl/lightgun.sv
     M rtl/savestates.sv
    ?? tests/
    ~~~

25. **Recommendation**

    **READY TO COMMIT**: the confirmed reproducer, replay, transport-duration, input, HCounter, compatibility and full-build gates pass.
    
    No staging, commit, push or PR was performed. Generated Quartus artifacts are not staged. results.json, simulation_results.json, sources.json, production.diff and README.md provide the detailed evidence and rerun instructions.
