# Coupled G06 + G10 restart correction

**READY TO COMMIT** — coupled G06 + G10 implementation, 257 passing runtime invocations and full controlled Quartus completed. G02–G05 and G08.release remain OPEN. No commit, push or PR performed.

1. **Baseline HEAD:** `8ffd15e2a7e530c0d77b07c6eeae3e8dc0aa0c8a`, branch `fix/savestate-g06-g10-restart`. The pre-edit gate recorded an empty tracked/staged diff and hashes for 204 tracked inputs; see [pre_edit_gate.json](pre_edit_gate.json). Existing historical test trees were retained.

2. **Baseline format:** v13, CPU restart tag `48430d`, subtype 3. The container remains 96 KiB / 12,288 64-bit words. This task introduces development format v14; no unpublished-version consolidation was performed.

3. **G06 SAVE-only root cause:** `vdp.vhd` updated overflow bookkeeping when `ce_vdp='0'` from raw presentation x/y even while guest enables were frozen. Freezing enables alone did not freeze historical status. Fresh [baseline/overflow9/dut.log](baseline/overflow9/dut.log) reproduced 16 overflow samples, two status samples and 34 CPU-A/RAM observations different from the uninterrupted reference. The first guest store was `5f` instead of `1f` at x42/y168.

4. **G06 LOAD root cause:** the prior restore discarded retained sprite cache/shifter/status-source history and reset the scanner; it could not reproduce the current line from VRAM alone. Fresh [baseline/dut.log](baseline/dut.log) reproduced three LOADs with 38 collision and six status differences each. Existing VDP flag serialization did not supply the missing source/delay state.

5. **G10 phase root cause:** arbitrary quiet-phase release selected different next CPU/VDP/pixel/sprite/PSG events. Fresh [phase23](baseline_phase/phase23/simulation.log) and [phase27](baseline_phase/phase27/simulation.log) have byte-identical complete known v13 images, SHA256 `d6c2b33cafe29d3608af682c4f5ee411c5721679d0e47b2d1e21451a34da715b`, but 29 versus zero SAVE-only mismatches, including CPU A/guest RAM. The independently reproduced positive pair is SAVE-only release; it is not misrepresented as two LOADs.

6. **Equal-phase two-pixel root cause:** the old NMI/context reconstruction performed historical T1/T2 after guest release, while VDP/pixel enables also ran. Even equal divider phase could not undo those two pixels. Fresh [baseline_phase/equalphase/simulation.log](baseline_phase/equalphase/simulation.log) reproduced nine collision/six status differences and the two-pixel displacement. Phase serialization alone is insufficient.

7. **Restart contract:** [contract.md](contract.md) specifies stage ownership. Accepted host edge T finishes normally, then guest hold takes effect immediately. Capture CPU architecture/context before T, normalized NMI history over T, divider phase at T and device state after T (collected at ARM). Transport and peripheral restore keep guest execution held. After DIRSet/GG/IO settlement, private CPU reconstruction installs metadata and executes only historical T1, plus T2 when T actually consumed a CPU enable. Every VDP/sprite/pixel/PSG guest enable stays zero throughout. Commit phase on a falling edge with all CEs zero; at the acknowledged rising edge install post-T beam and release. The next ordinary falling edge emits logical T+1. Mapper/controller restore policies remain established; guest writes stay inhibited. Presentation counters may run while held, but are not guest execution.

8. **Canonical release:** conjunction of semantic CPU replay completion, captured phase installation acknowledgment, and installation of the post-T beam. SAVE skips CPU reconstruction but performs the same phase/beam commit. `RestoreHold` keeps the CPU NMI sampler stopped until actual release, independently of the metadata-install hold. Current host Pause is retained, never loaded from the image. There is no fixed two-pixel correction and no ordinary instruction executed as preparation.

9. **Bounded liveness:** with production WAIT/BUSRQ inactive, reconstruction needs one effective CPU enable for a suppressed-T capture, otherwise two. Private enables use raw /15 independently of normal /15, turbo /10, System E /10, or UI Pause. Metadata application can suppress one raw opportunity: at most three opportunities / 45 host clocks, then the phase/beam handshake; fixtures assert preparation within 48 host clocks. Existing 900,000-clock flush and 255-clock settlement remain. Bounds exclude externally unbounded DDRAM busy and storage/capture-window waits. F12 permits bounded coherent CPU/PSG advancement to find M1 while logically paused; that is capture-seeking execution, not restore preparation or exact equivalence to an otherwise stationary non-M1 reference. The focused paused tests measure that exception explicitly.

10. **Serialization versus normalization:** [design_pre_edit.md](design_pre_edit.md) compares alternatives. Literal phase costs five bits and still needs sequencing. Arbitrary canonical phase costs zero history bits but loses next-event ordering. Sequencing alone fixes preparation overlap but loses phase history. Chosen hybrid stores two bits for the accepted phase union {0,10,20,25}, one independent CPU-consumed-T bit, and necessary G06 history; sequencing normalizes arbitrary transport phase. Both VDPs share the clock contract but have independent sprite records. This preserves G01/F16 semantics and F12 liveness; ordinary cadence resumes only after preparation. Restore fanout/muxes and snapshot registers require synthesis validation; no intentional RAM increase is designed.

11. **Prototype before production:** baseline witnesses, external protocol prototypes, ordinary/status/collision/overflow, representative G01 LDIR and F16 capture-edge pulse passed before `pre_edit_gate.json` permitted edits. `protocol/sync_phase12_{normal,turbo}` passed 12 phases / 12,000 observations each; `protocol/canonical_overflow` passed strict SAVE-only; `protocol_g01/ldir.log` and `protocol_nmi/sms_edge0.log` passed repeated LOAD. Prototype side records were diagnostic, not a claim that v13 contains missing sprite history. An asynchronous test RAM model initially produced a one-byte signature error; replacing it with the production registered-read model resolved it before editing. Failed diagnostic logs are retained and excluded from passing totals.

12. **G06 sufficiency inventory:** [state_inventory.md](state_inventory.md) lists every requested field and its first consumer. Serialize enable/X/cached four planes/shifts/wideclock per slot; fixed address14, m2 flags8, registered color4, collide1, overflow1 and collision delay14. Freeze existing status flags, already in the VDP register record. `ce_spload`, per-shifter color and active are combinational. Omit evaluator state/count/index (16 bits): preceding x496 forces WAITING; /5 or accelerated /2 samples that ten-clock pixel; accepted post-T x<=256 cannot start another scan. x257 resets count/index before use. Restore WAITING/0/0. Retaining address/flags/inactive planes is conservative because mode changes can consume old partial state. This is a consumer-proven sufficient fixed record, not an information-theoretic compression claim.

13. **v14 layout:** word01a high tag `48430e`, subtype3; CPU word005 keeps v13 fields and zero63:44. Word02e=`12aa0e0047365231`: width 4778, version 14, owner `G6R1`. Word02f: phasebits1:0 (0/10/20/25), System E ownership bit2, CPU-consumed-T bit3, reserved63:4 zero. VDP1 words2901..294b, VDP2 words294c..2996: 75 words each, 4778 useful bits, 22 high padding zeros. Non-System-E record2 is all zero. Slot i occupies bits 74i..74i+73; fixed42 bits follow all 64 slots. Validate descriptor, owner, reserved bits, both padding fields and absent second-device payload before the first early guest restore strobe. [format/simulation.log](format/simulation.log): 170 malformed rejections / 15 valid or legacy accepts.

14. **Legacy:** tags1..13 and old64KiB loading remain accepted with deterministic missing-history normalization. G06 record becomes zero, scanner WAITING/0/0, phase 0, prior historical T1/T2 behavior. Old64KiB snapshots additionally use beam origin0 because beam history is absent. Legacy cannot regain discarded sprite, phase or CPU-consumption history; exact replay of that missing history is not promised. Genuine v13 warm-up LOADs exercise these defaults on actual VDPs, followed by a full naturally executed frame before current-format capture. F16 matrices also exercise legacy CPU formats and malformed modern CPU headers.

15. **Production files:** `SMS.sv`, `rtl/savestates.sv`, `rtl/system.vhd`, `rtl/T80/T80s.vhd`, `rtl/vdp.vhd`, `rtl/vdp_main.vhd`, `rtl/vdp_sprites.vhd`, `rtl/vdp_sprite_shifter.vhd`. No T80 core change. The private snapshot banks use64-bit rotation/shift transfers over75 payload words per VDP; no new guest tick or extra protocol state is introduced. CPU preparation regains memory read address ownership while guest writes remain inhibited. The raw-beam overflow branch honors ss_freeze. The obsolete unread alignment-timeout variable is removed.

16. **SAVE overflow:** mandatory nine-sprite witness matches uninterrupted RGB/full VDP register/CPU A/guest RAM/status/overflow timing for 1,000 observations. Normal and turbo protocol coverage plus final stalled versions retain the original failing guest program. No overflow special case was introduced.

17. **Transport duration:** deterministic DDRAM_BUSY profile83/97 produced 152,027 frozen host clocks; LFSR busy13/16 produced 50,318, versus roughly28,000 unstalled. [stalls/overflow_stall1/simulation.log](stalls/overflow_stall1/simulation.log) and [stall2](stalls/overflow_stall2/simulation.log) assert full sprite/VDP/CPU hold from ARM and exact SAVE-only continuation, including native first-enable order.

18. **Collision LOAD:** final integrated exact oracles compare RGB, full 230-bit CPU, guest RAM and full 136-bit VDP state after SAVE and LOAD. Original status/collision sample displacements are zero. No permissive two-pixel trace alignment is used.

19. **Three distinct LOAD histories:** `distinct_q/dut/simulation.log` preserves the original collision program/reference and actual 64-slot record. It naturally runs80/1450/2820 host clocks before the three LOAD requests, asserts pairwise different full live Q signatures, and the gate separately requires distinct CPU/VDP signatures even excluding beam. All three 1,000-pixel suffixes match the independent uninterrupted oracle exactly. The full 12,288-word known image is unchanged and hashes identically to the earlier known64 case. Initial80/111/142 controls converged to the same accepted Q and prove repeatability only; this coverage gap was corrected before the final controlled build.

20. **Two-pixel delay:** eliminated by holding the VDP while CPU reconstruction completes, then atomically committing beam/phase. Full CPU/RAM/VDP/RGB comparison starts at the first resumed pixel; raw-enable monitors start at the first host clock. It does not mask the first two pixels.

21. **Legal release phases:** the same complete known 64-slot v14 image is loaded at naturally reached pre-preparation phases1,3,7,9,11,13,17,19,21,23,27,29, plus a repeat: 13 LOADs /13,000 exact observations in [candidate/known64_natural13_turbo/simulation.log](candidate/known64_natural13_turbo/simulation.log). Only response latency of the last real DDRAM read is varied; divider registers are not forced. Normal cadence has the matching native 13-LOAD sweep. After canonical installation, raw CPU/VDP/pixel/sprite first-enable distances are phase 0:10/5/10/2, phase 10:15/5/10/2, phase 20:5/5/10/2, phase 25:15/5/5/1 host clocks; later periods15/5/10/2. Turbo/System E effective CPU uses the /10 pixel path; PSG uses raw /15. Wall-time transport/normalization differs, logical suffix does not.

22. **CPU preparation isolation:** assertions hold live G06 record, VDP registers and beam-relative state and force guest VDP/pixel/sprite/PSG enables zero while private CPU replay runs. Both PSG full cfg/ext/div state vectors remain unchanged. The private gate is `ss_prepare_ce AND NMIReplay`, so replay completion prevents an extra ordinary CPU tick.

23. **Reciprocal isolation:** during peripheral/VDP restoration, CPU receives no architectural CEN except the separately identified private reconstruction stage; DIRSet is metadata restoration. Memory writes remain inhibited. Full dual-device tests assert both directions of isolation. Existing peripheral restoration/settlement does not become guest time.

24. **G01:** complete relevant matrix: 90 invocations /73 distinct argument sets, including CB/ED/DD/FD/DDCB/FDCB, LDIR/block repeats, EI delay, HALT, active-bus/full 230-bit CPU and RAM, normal/turbo/System E representatives, three LOADs per case, 36,403 comparisons per case. Repeated controls are not counted as extra distinct scenarios. Matrix uses test-only shortened flush with real255-clock settlement; a full 900,000-flush LDIR representative independently passes. See `matrix_g01/cases.json` and `candidate_g01/ldir_v14.log`.

25. **F16:** 102 invocations /90 distinct effective argument sets (90 original scoped cases plus12 final-source/pilot/repeat controls), all eight normalized triplets, first-sampled-on-capture pulse, held/released pulses, GG ordering, DIRSet ordering, real handler behavior and repeated LOAD. Full-flush capture-edge representative also passes. `RestoreHold` does not suppress metadata application: it suppresses external resampling through actual release. For CPU-consumed-T=0, the private T1 cannot select a new NMI cycle: `T80.vhd` changes NMICycle/NMI_s consumption at instruction-ending T_Res, not reconstruction T1. Normal T2 semantics remain tested by all-triplet regression. A malformed-header test initially watched a valid SAVE beam commit; its stage guard was corrected, the failed log retained, and all 102 cases rerun successfully.

26. **F12:** 18 final known-register cases use actual UI toggle-Pause logic and real T80/dual PSG. Paused M1 requires zero capture override ticks; paused non-M1 representative requires seven CPU / five PSG ticks to reach capture, retaining logical Pause. The stopped-phase sweep exercises14 CPU phases; maximum measured capture latency656,904 host clocks, maximum private reconstruction32 host clocks (bound48). LOAD with current Pause asserted or cleared, release-held, and unpause pass. CPU preparation uses one or two private ticks according to saved consumption, never current UI Pause. Full System E paused test additionally compares both VDPs and post-unpause guest results.

27. **PSG sanity:** two actual production JT89s independently programmed; SAVE plus three LOADs compare each156-bit cfg/ext/div state and raw four-enable vector on every one of10,000 host clocks per suffix. No preparation tick, missing first enable or duplicate release enable. Full System E repeats this with both VDPs active. **G08.release remains OPEN**: AudioMix/filter/FM historical sufficiency is not investigated or closed; F01 is outside scope.

28. **System E:** independent dual real VDPs use different VRAM/CRAM, palette/overscan, sprite lists and tall mode; guest addresses both BA/BB and BE/BF and stores both status reads. Dual real PSGs are independently programmed. Running and logically paused captures each replay three times exactly. Paused replay uses saved consumed-T=0 and one private T1, retains host Pause, then matches reference unpause latency885,681 host clocks plus1,000 CPU/dual-VDP/RAM pixel observations and10,000 PSG/CE host observations. The actual 64-slot-per-VDP running counterpart also passes three LOADs. Its uninitialized inactive payload is labeled as such, not claimed fully known.

29. **Cadence:** ordinary SMS CPU /15, turbo /10, System E /10 exercised. All use private /15 preparation and shared phase commit; turbo/System E mode selection is unchanged. Accelerated sprite /2 and ordinary sprite evaluation /5 are tested. No inference that /15 PSG cadence becomes CPU /10 is made.

30. **Sprite matrix:**14 scenarios: zero, one, collision, near collision, overflow8, overflow9, terminated list with garbage after D0, tall, legacy graphics1, legacy graphics2, legacy tall, first visible line (75,000 LOAD observations plus25,000 SAVE-only), line transition, accelerated64. Each has independent reference, legal v13 warm-up, SAVE transparency and three LOADs. Applicable GG/SMS and legacy modes are explicit in `sprites/cases.json`. Pure ordinary cases use eight instantiated slots with SP64 disabled; accelerated case uses actual 64.

31. **G06 non-injective search:** a legal guest program and two past controller-input histories create evaluator index2 versus4, then restore identical SAT bytes after x496. At ARM both are WAITING/count2; future inputs become identical. No CPU/VDP/sprite/divider historical register is forced; request tasks bypass only host UI op_cooldown for repetition. Both the reduced pair and actual 64-slot pair pass. The complete known64 images are byte-identical, SHA256 `e8fbd6d061530e66d4a7bf8996bef9fbda031d336314aca949dbae42daa2a6e0`; both 3,000-observation CPU/VDP/RGB/RAM suffixes hash `b405e26c0d72492160c8b39a87370fc57579191316d6f1befdf9dfb786dc2025`. See `search/history{0,1}_64` and `evidence_metrics.json`. This directly challenges an omitted field rather than reporting a random search with no pair.

32. **G10 non-injective search:** naturally varied last-read response latency produces distinct legal transport/divider histories for the same immutable complete v14 image. Canonical sequencing makes all 13 LOAD futures equal, including native first-enables and status/CPU/RAM. This is a positive same-image/different-pre-release-history test, not a field-masked comparison.

33. **G02 contamination:** remains **OPEN**. Earlier hold begins at T, and raw status-overflow bookkeeping now freezes. Prior status-clear collision ordering assumptions must be rerun from this baseline; passing the specific status-reading guest program does not close all clear-order cases.

34. **G03 contamination:** remains **OPEN**. CPU fetch read ownership returns privately before guest release, while VDP/bus guest transactions remain held. Rerun prior CPU/VDP transaction completion/read-buffer investigations against the new preparation/release order. This task does not add missing transaction state.

35. **G04 contamination:** remains **OPEN; rerun required**. The14-bit collision-delay register is now serialized as a shared G06 dependency and CPU/VDP relative release changed. Prior collision/IRQ timing evidence requires new-baseline verification; the passing collision witness is not G04 closure.

36. **G05 contamination:** remains **OPEN**. Removing incidental preparation-time pixels changes background reprime timing assumptions. The first-visible-line sprite case corroborates one pattern only. Rerun prior background pipeline/mode/scroll experiments; no background state sufficiency claim is made here.

37. **Simulation totals and limits:** 20 ledger groups /257 explicit passing runtime invocations, including reference runs and repeat controls; these are not 257 distinct parameter scenarios. The format invocation separately covers185 accepts/rejects. See [simulation_results.json](simulation_results.json) for each log/hash and [evidence_metrics.json](evidence_metrics.json) for unique argument counts, image hashes and all eight NMI triplets. Baseline/prototype/failed diagnostics are excluded. Reduced eight-slot fixture payloads are opaque round-trip records padded low, not the physical production 64-slot field layout; only actual 64 cases establish4778-bit packing. Original inactive cache Xs are not silently zeroed for a known-image claim: known64, natural64 and distinct-Q use legal legacy initialization and a natural frame. The dual64 running case with inactive Xs proves device replay, not full-known images. Test-only flush shortening does not enter production; full-flush representatives cover the retained path. The final output-alias correction has an exact source-renaming proof,50,000-clock64-slot equivalence miter, and the actual 64 distinct-Q integration. No physical FPGA/game-ROM sweep was performed. Request tasks bypass only the host UI op_cooldown rate limiter for rapid repetition; no CPU/VDP/sprite/divider historical register is forced in the natural searches. The accepted guest boundary and raw divider recurrence remain production conditions. After the hardware-only transport revision, all 90 G01,102 F16 and18 Pause invocations, the format test, both full-flush representatives, both overflow stall profiles, actual 64-slot distinct-Q replay and dual64-slot System E replay were rerun. Earlier sprite/natural-phase/paused-dual-device/search evidence is linked to the final transport by the source invariant and151-port/91-output cycle-equivalence miter (185 format checks plus16 metadata combinations and48 randomized LOADs). Only the two unconsumed intermediate sprite data buses are compared at their consuming restore strobes; no image field or DDRAM transaction is masked. See transport_invariant.md and ring_regression_sources.json.

38. **G06 classification:** **CLOSED - FIXED AND PROVEN** for the scoped sprite-pipeline obligation. G02–G05 remain open.

39. **G10 classification:** **CLOSED - FIXED AND PROVEN** for deterministic coupled restart. G08.release remains open.

40. **Quartus setup:** +0.384 ns, delta -0.099 ns versus baseline+0.483 ns.

41. **Quartus hold:** +0.226 ns, delta +0.013 ns versus baseline+0.213 ns.

42. **Timing violations:** 0; baseline zero. All timing-summary corners/checks are retained in quartus_results.json.

43. **ALMs needed:** 35,419 / 41,910 (84.512%); delta +8,051 versus 27,368.

44. **ALMs placed:** 38,142 / 41,910 (91.009%); delta +5,458 versus 32,684.

45. **Fitted registers:** 48,002 / 167,640 (28.634%); delta +11,171 versus 36,831.

46. **M10K:** 487 / 553 (88.065%); delta +0 versus 487.

47. **Memory bits:** 3,809,858 / 5,662,720 (67.280%); delta +0 versus 3,809,858.

48. **DSP:** 39 / 112 (34.821%); delta +0 versus 39.

49. **Warnings/resource analysis:** The increase comes from two 4,800-bit snapshot banks, VDP restore muxes and physical packing/routing. Synthesis adds 9,603 registers (9,601 in savestates and 2 at top level). The fitted delta of 11,171 registers reconciles exactly by entity; the additional 1,568 is physical mapping/optimization overhead, not serialized guest state. Logic ALUTs increase by 5,818 and routing ALUTs by 5,399. Placed ALMs +5,458, recoverable packing -2,410 and unavailable ALMs +183 reconcile through A-B+C to needed ALMs +8,051. Hierarchical ALM allocations are estimates; this global packing equation gives the exact delta. The indexed transport failed routing at 39,680 needed ALMs. The cycle-equivalent sequential transfer reduced controller ALUTs from 9,643 to 6,003 and needed ALMs by 4,261, to 35,419. The final design routes and meets timing, with no new warning types/messages. M10K, memory bits and DSPs are unchanged. The matched-date baseline reproduces every retained resource and setup/hold metric exactly. Distinct warning messages 84→84; critical 38→38; aggregate tool warnings100. New warning type IDs: none. See [quartus_results.json](quartus_results.json) and [build_assessment.json](build_assessment.json). Fresh controlled build:136 hashed inputs,134 verified committed baseline files plus two unchanged retained external backup/original inputs, identical QSF/seed 1/Quartus17.0.2 settings, no reused database. The first attempt exposed a VHDL output-read restriction; internal register aliases corrected it without new state. A second attempt was stopped when the distinct-Q coverage gap was found. Only the full final build after the expanded passing gate supplies these results. The pre-flow script regenerated BUILD_DATE from261022 to261023, so the unchanged committed post-G01 source was additionally rebuilt with the same261023 date. Both full builds pass source-hash verification. Required retained-baseline deltas above are supplemented by the date-matched control below.

| Resource | Retained baseline (261022) | Same-date baseline (261023) | Candidate | Delta vs retained | Delta vs same date |
|---|---:|---:|---:|---:|---:|
| ALMsNeeded | 27,368 | 27,368 | 35,419 | +8,051 | +8,051 |
| ALMsPlaced | 32,684 | 32,684 | 38,142 | +5,458 | +5,458 |
| registers | 36,831 | 36,831 | 48,002 | +11,171 | +11,171 |
| M10K | 487 | 487 | 487 | +0 | +0 |
| memoryBits | 3,809,858 | 3,809,858 | 3,809,858 | +0 | +0 |
| DSP | 39 | 39 | 39 | +0 | +0 |

Same-date baseline setup/hold: +0.483 / +0.213 ns; candidate deltas -0.099 / +0.013 ns. See [controlled_comparison.json](controlled_comparison.json) for both complete source/metadata controls and the same-date fitted register ledger.

50. **`git diff --stat`:**

```text
 SMS.sv                     |  29 +++++++-
 rtl/T80/T80s.vhd           |   7 +-
 rtl/savestates.sv          | 177 +++++++++++++++++++++++++++++++++++----------
 rtl/system.vhd             |  17 ++++-
 rtl/vdp.vhd                |  11 ++-
 rtl/vdp_main.vhd           |   6 +-
 rtl/vdp_sprite_shifter.vhd |  12 ++-
 rtl/vdp_sprites.vhd        |  61 +++++++++++++---
 8 files changed, 259 insertions(+), 61 deletions(-)
```

Local test/report additions are untracked and therefore absent from this tracked diff stat; they are confined to this task directory. Mixed legacy VDP line endings were preserved.

51. **`git status --short`:**

```text
 M SMS.sv
 M rtl/T80/T80s.vhd
 M rtl/savestates.sv
 M rtl/system.vhd
 M rtl/vdp.vhd
 M rtl/vdp_main.vhd
 M rtl/vdp_sprite_shifter.vhd
 M rtl/vdp_sprites.vhd
?? tests/
```

`git diff --check` passes. Nothing staged, unchanged HEAD, no commit/push/PR. Generated Quartus source/database/output trees are ignored and no generated Quartus artifact is tracked. Historical untracked `tests/` existed before this task.

52. **Recommendation:** **READY TO COMMIT**. Both scoped obligations pass the functional matrix, exact replay and source invariants, and the final controlled routed build meets timing. G02–G05 and G08.release remain OPEN. No commit, push or PR performed.
