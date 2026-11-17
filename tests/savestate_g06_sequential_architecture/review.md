# G06/G10 sequential savestate architecture experiment

**E. FUNCTIONAL OR TIMING RISK - DO NOT CONVERT**

Functional proof passes, but the primary fit failed routing. Its reported 1,615-ALM placement difference is **provisional, not a usable gain**; storage costs +2 M10Ks. Seed 2 completes routing at 38,012 placed ALMs (-586) but fails setup at -0.100 ns; hold is +0.244 ns. Neither tested seed is timing-qualified. Confirmation is reported separately below. Production F01/v17 remains unchanged. No timing optimization or next roadmap task was performed.

## 1. Baseline HEAD

`7fcd5e12847eedf9e97a44dc937c3dbac3205f7c`, branch `investigate/savestate-g06-sequential-architecture`. Tracked production and index were clean before experimentation. [baseline.json](baseline.json) freezes 204 tracked regular-file raw SHA256 values, prerequisite report identities and historical endpoints.

## 2. F01 commit

`7fcd5e12847eedf9e97a44dc937c3dbac3205f7c`. This committed implementation is the production reference. Its 137 retained final-build source/config inputs all matched current root files byte-for-byte before the candidate was prepared.

## 3. v17 confirmation

Production format remains v17. Candidate keeps the current tag, descriptors, image size, addresses, ownership, padding, version selection and legacy defaults. No production file was edited. F01 RTL is unchanged; no F06, G08.FM or format-consolidation work occurred.

## 4. Quartus/device/project/seed baseline

Quartus Prime Lite 17.0.2 Build 602; Cyclone V device 5CSEBA6U23I7; project/revision SMS, top sys_top; seed 1. Exact production QSF/SDC/QIP/IP, MISTER_FB=1, performance/packing assignments and BUILD_DATE261025 are preserved. Fresh source-only databases; explicit map/fit/asm/sta with settings writes disabled. Candidate input manifests contain 139 files:137 matched baseline inputs with the isolated substitutions plus two new sources. Confirmation changes only seed 1 to seed 2. See [build_A_inputs.json](build_A_inputs.json), [build_confirmation_inputs.json](build_confirmation_inputs.json) and [build.ps1](build.ps1).

## 5. Current resource baseline

Verified exact-source F01 final build: needed 37,175/41,910 (88.702%); placed 38,598/41,910 (92.097%); fittedFF 48,948/167,640 (29.198%); synthesisFF 46,289; M10K 488/553 (88.246%,65 free); blockbits 3,818,050/5,662,720 (67.424%); DSP 39/112 (34.821%). Baseline reports remain under `../savestate_f01_opll_fix/quartus_final/`.

## 6. Current timing baseline

Worst setup +0.105 ns, hold +0.206 ns; zero failing timing-summary checks. The existing partially unconstrained design information remains a limitation. These are constrained fitter/TimeQuest results, not hardware validation.

## 7. F01 reusable architectural principles

[topology.md](topology.md) documents local fixed-field32-bit/8-address-bit access, registered read response, selected local writes, synchronous256x32/one-M10K scratch, bounded held-state gather/scatter and DDR64 pair assembly. Broad flattened live-state selection and parallel restored-state banks are avoided. Local response/array/per-register muxes still exist. OPLL initialization, cache refill and delayed arithmetic reconstruction are not copied. The measured F01−403 placed ALMs is precedent, not an estimated sprite saving.

## 8. G06 state inventory

All 17 groups, owner, width/count/total, capture/restore/mux, freeze/version policy, first consumer and reason appear in [inventory.json](inventory.json) and the table in [topology.md](topology.md). Per VDP:64×74 slot bits=4,736; address 14, flags 8, color 4, collide 1, overflow 1 and collision-delay 14=42; total 4,778. Both VDPs retain 9,556 meaningful bits plus 44 padding. Evaluator FSM3/count 7/index6 remain live and retain original WAITING/0/0 normalization; no history was removed.

## 9. G10 state inventory

Historical payload stays `phase_snap` (2 bits) plus `capture_tick_snap` (1 bit) at 02f[1:0,3]. The detailed width/representation/consumer table in topology.md separately inventories divider 5, four enables, phase acknowledgment 1, phase/preparation controls, wrapper nmi_restart2, 7-bit shared FSM and wires. CPU/NMI/decoder fields and one/two private replay policy are unchanged. Phase-set installs 0/10/20/25, clears enables, and releases only after acknowledgment. No G10 historical state is reencoded.

## 10. Shared-control inventory

Freeze and delayed edge history; original VDP1/2 architectural restore strobes; has_restart/version selection; sprite_word7/owner 1; System E owner bit; beam 22 plus strobe; original 14/15-bit WRAM/NVRAM address ownership; evaluator normalization. See inventory.shared and topology.md for widths, role, selection and first consumer. These controls remain distinct from the large sprite shadow banks.

## 11. Current transport topology

Live 4,778-bit vectors -> two 4,800-bit FF shadow rings -> selected low 64 DDR word -> unchanged version/ownership predicates -> shift-in shadow rings ->4,778-bit restore buses -> local live fields. External DDR was already sequential 64-bit. The experiment changes internal access/storage, not the external transport format.

## 12. Current restore-mux topology

Each shadow FF participates in capture/hold/zero/rotate/insert selection; original live fields select parallel restored values versus legacy defaults and normal updates. The ring already avoids an arbitrary wide indexed read. Prior local mux extraction retained the bank and increased placed ALMs by 47; it is not repeated. Candidate removes the full shadow/parallel-input bank and retains only bounded local word updates.

## 13. Current fanout topology

ARM and ring updates affect thousands of shadow FF; restore/validity affects all receiver fields. Freeze gates the guest domains and raw overflow. Candidate instead distributes address 8,32-bit write data and selected read/write controls; a local response OR tree and decode remain. Source fanout is not physical fanout. Retained fitter high-fanout rows in each results JSON support inspection; no unsupported exact routing attribution is made.

## 14. +5,458 placement attribution

Measured historical endpoints: pre-G06/G10 `8ffd15e2a7e530c0d77b07c6eeae3e8dc0aa0c8a`, G06/G10 `58583189b5c650dc6658ef467e8dcb72d9f6e6c2`. Delta needed +8,051, placed +5,458, mappedFF+9,603, fittedFF +11,171, controller mappedFF+9,601, top+2, logicALUT+5,818, routingALUT+5,399. The 9,600 scratch FF explain nearly all mapped FF growth. Inference: their storage/update and broad restore choices dominate the opportunity. Unknown: additive placed shares of decode, restart, fanout, locality and remapping. The placed-minus-needed gap improved 2,593, so aggregate packing degradation is not the explanation. [Historical diff](historical_g06_g10.diff) and topology.md preserve this distinction.

## 15. Sequential candidate architecture

Isolated [candidate_A](candidate_A): read held live fields through a local 32-bit port, store unchanged padded records in synchronous RAM, and restore by local 32-bit writes before the original architectural strobe. No dynamic4,778-bit live-vector slice or broad top-level restored bank. Read-only wide test aliases are unused by synthesized transport. Existing G10 reconstruction/release follows coherent installation. See [design.md](design.md).

## 16. State-port definition

VDP port: `ss_state_addr[7:0]`, read/write strobes, `ss_state_wdata/rdata[31:0]`; engine owner select. Fixed-slice local decode, one registered response per VDP at the host edge, deterministic issue/collect. No variable-latency local ready is needed; engine busy/done supplies command acknowledgment. Write strobe reaches only the selected owner; each field merges only its constant overlapping bits. Guest enables remain held.

## 17. Candidate width

A uses 32 bits. No alternative was built:16 bits retains two M10Ks and doubles transactions;64 bits retains two M10Ks and reduces cycles but doubles routed word width. Neither offered a demonstrated physical advantage requiring a second-width build. A different 20/40-bit repacker might reduce block count but is outside this bounded 16/32/64 experiment and is not claimed proven.

## 18. State address map

Rows 0..149 per VDP: packed bits 32r..32r+31; row 149 only[9:0] meaningful,[31:10]=0. Slot i has base 74i:enable 0,X 1..8,cached planes9..40,shifts41..72,wideclock 73. Fixed fields begin 4736/4750/4758/4762/4763/4764 as detailed in inventory. Two rows form each unchanged DDR64 word, low then high. External descriptor 02e, phase/owner 02f, primary 2901..294b, secondary 294c..2996. All 150 rows and both owners are tested.

## 19. Storage architecture

One logical 300x32 scratch,9,600 bits, implemented as two M10Ks; same scratch serves SAVE and validated LOAD. It replaces two 4,800-bit FF banks and does not copy the entire live state into another parallel bank first. SAVE could stream directly; validated LOAD still requires temporary storage before any live mutation, so reuse keeps one proven data path. F01 scratch and live pixel shifters are unchanged. Legacy uses literal-zero scatter; inactive second VDP is not modified outside System E.

## 20. Additional M10K requirement

Measured +2 M10Ks and +9,600 logical block bits. At 32-bit width 300 rows exceed one 256x32 block. Baseline 65 free -> 63 free. The trade is evaluated against placed gain in item49; it is not presented as minimum possible RAM use. One existing F01 scratch cannot hold 9,556 bits and is not borrowed.

## 21. Freeze sequencing

Accepted T executes normally; freeze starts after T. Live sprite state is then stationary, including raw overflow bookkeeping. No guest evaluator/shifter/collision-delay step occurs during scanning. Partial LOAD installation remains private behind freeze. Presentation counters follow the existing contract. No extra CPU replay tick, relaxed first-clock comparison or G10 timing exception is introduced.

## 22. SAVE sequencing

ARM starts a 300-row two-owner issue/collect scan (600 local clocks); inactive secondary reads substitute zero. F01 capture/header work proceeds unchanged in parallel. Sprite descriptor waits for scan completion. Each DDR64 payload fetch synchronously reads two RAM rows and preserves original address/order/padding/commit. Engine handshakes guard previous done until the new command is accepted. DDR backpressure cannot skip or duplicate words.

## 23. LOAD sequencing

Original version, descriptors, padding and ownership predicates validate before any live write. Each accepted DDR64 sprite word stores two RAM rows. After all remaining image checks/transport, apply 150 rows for one VDP or 300 for System E, then execute the original architectural restore. Legacy absent history writes deterministic zeros. Original evaluator normalization and IRQ/register restoration retain already installed sequential fields. F01 apply/flush follows unchanged.

## 24. Release sequencing

Keep freeze through coherent sprite install, architectural restore, existing flush and CPU preparation. Original historical replay, NMI/peripheral hold and WRAM/NVRAM ownership are untouched. States105/106 retain acknowledged phase/beam commit; native T+1 CPU/VDP/pixel/sprite enable order is exact. System E dual ownership, normal/turbo and logical Pause policy are not weakened.

## 25. v17 compatibility proof

Sixteen complete known 98,304-byte images from candidate and committed-controller reference are byte-identical, with hashes in [image_equivalence.json](image_equivalence.json);48 LOADs per implementation restore arbitrary full 9,556-bit records. All 4 phase codes, owner and consumed-enable combinations and 3 transaction-qualified stall profiles occur; some metadata combinations are protocol tests rather than reachability claims. [protocol/format.log](protocol/format.log):2,416 cases, rejected 2,016/accepted 400, with zero live writes on malformed images, including private sprite writes in the mutation oracle. Covers original v1..16/v17, old64 sprite form, sprite/FM/BG padding and ownership/descriptors. External v17 is unchanged.

## 26. SAVE added clocks/time

Exact ready-DDR coherent-controller result:30,428 vs 29,080 clocks (SMS),94,968 vs 93,620 (System E): **+1,348 clocks = 25.106 µs NTSC / 25.337 µs PAL**. Bulk fetch adds 150×8=1,200 clocks; the measured unhidden capture remainder is 148 because the 600-clock scan overlaps unchanged header/F01 work. This overlap remainder is configuration-dependent. Local scan itself is 600 clocks (11.175 µs NTSC / 11.277 µs PAL), not 600 additional clocks on top of the measured total. Native SAVE confirms +1,348. Details and all 64 protocol transfer counts: [latency.json](latency.json).

## 27. LOAD added clocks/time

Fixed-response coherent-controller SMS43,278 vs 42,225: **+1,053 clocks = 19.611 µs NTSC / 19.792 µs PAL**. System E136,828 vs 135,475: **+1,353 clocks = 25.199 µs NTSC / 25.431 µs PAL**. Breakdown:150 bulk stores×5=750 plus application 300/600 and 3 controller handoff clocks. Local apply is 300/600 clocks (5.587 µs NTSC / 5.639 µs PAL / 11.175 µs NTSC / 11.277 µs PAL). Real CPU preparation aligns to its unchanged enable sequence. Natural-phase native tests deliberately adjust last-DDR response modulo 30 and show modern deltas 1,050/1,080; those include that fixture-controlled delay and are not intrinsic fixed-response budgets. Legacy warmup without modern sprite payload adds 300 in that native fixture. Transport waiting can hide/change overlap and has no universal finite wall-clock bound; no universal constant delay is claimed.

## 28. G06 witness result

PASS:14 retained production-oracle cases—zero,one,collision,near,overflow 8,overflow 9,terminated,tall,legacy graphics1/2,legacy tall,first-visible,line-transition,accelerated64. SAVE-only and three LOADs per case, evaluator/shifter/output/status comparisons; first-visible retains 25,000 SAVE+75,000 LOAD observations. Most fixtures use 8 slots for runtime; accelerated64 plus exact64-slot local miter prove physical packing separately. Fresh selected-source64-slot pending-delay case passes native 10,000-host-clock suffix and three LOADs; saved delay 0x3fc0, row 149 upper 10 bits plus row 148 low 4 bits (zero in this witness; randomized mapping covers nonzero low bits). No oracle or tolerance was softened. See functional_results.json.

## 29. G10 witness result

PASS: retained natural-phase test has 12 distinct pre-preparation divider histories plus repeated LOAD, strict 60-host-clock first-event order, CPU/VDP/pixel/sprite and private-preparation isolation. Fresh selected-response rerun also passes. Deterministic stalls, LFSR stalls and production 900,000-clock flush pass. Actual independent dual-VDP replay passes, including IRQ/RAM behavior. Protocol covers all 4 saved phase codes/ownership/consumption; no forced historical CPU state replaces native replay.

## 30. G05 sanity result

PASS: retained42,000-pixel text-to-Mode4 background-pipeline witness for SAVE and three LOADs, including CPU/VDP/BG state and exact guest observations. Historical PASS labels still say V15; compiled transport is currentv17. Earlier distributed response is linked to selected response by the exact read-interface identity and miter; this is explicitly separated from fresh selected-source native runs.

## 31. SAVE-duration result

PASS: minimum, moderate and long private-access gaps 0/7/97 clocks preserve exact local state/output; memory-engine bulk gaps 0/7/97 preserve exact-once words. Coherent controller profiles use ready,1/8-busy and 7/8-busy transaction-qualified DDR with variable read delay; full images/futures agree. Native deterministic/LFSR SAVE stalls and the retained uninterrupted guest oracle pass. An unconditional BUSY pilot starved the existing 32-idle-clock drain and is excluded, not counted as a candidate failure or proof.

## 32. LOAD-duration result

PASS: same gap/transport profiles, immutable images and repeated scatter/LOAD, plus actual deterministic/LFSR stalls and full 900,000-clock production flush. No first-resumed-clock grace interval. Guest futures are independent of private operation duration at coherent release; wall-clock elapsed transfer time naturally changes.

## 33. Equivalence-miter result

PASS:320,016 full 64-slot live-state/output comparisons across 16 mode/width configurations and 20,000 guest clocks each against renamed-only committed parallel sprite RTL. Selected-response gap run independently passes. Read relocation identity OR_i DFF(f_i)=DFF(OR_i f_i) is validated at 480,848 clocks and all 150 addresses, guest enables, modes, writes and collision contributions. Complete-image controller miter adds 16 byte-identical images and 48 LOADs/implementation; native long suffixes expose delayed divergence. [read_retiming/equivalence.md](read_retiming/equivalence.md) documents the source bridge and archives. This is strong finite simulation/compositional evidence, not an exhaustive formal reachability proof.

## 34. Functional-gate result

PASS before full Quartus. [functional_gate.json](functional_gate.json) binds 10 selected candidate source hashes and 12 completed evidence logs; the remaining campaign continued afterward with no contradictory failure. [functional_results.json](functional_results.json) verifies 21 actual-VDP cases and all pre-build evidence hashes unchanged. F01 raw FM/PSG/audio isolation also passes SAVE+three LOADs. Fourteen sprite cases, phase/stall/full-flush, G05, dual and pending64 are not inflated by counting component/protocol controls as native cases. [pilots.md](pilots.md) discloses excluded setup pilots.

## 35. Candidate ALMs needed

35,337 / 41,910 = 84.316%; baseline 37,175; delta -1,838. **Primary is a failed-route provisional report count, not a usable completed fit.** Confirmation 35,214 / 41,910 = 84.023%, delta -1,961. 

## 36. Candidate ALMs placed

36,983 / 41,910 = 88.244%; baseline 38,598; delta -1,615. **Primary is a failed-route provisional report count, not a usable completed fit.** Confirmation 38,012 / 41,910 = 90.699%, delta -586. 

## 37. Placed ALMs recovered

**No robust recovery at the unchanged production seed is proven.** Primary failed-route placement table reports36,983 versus38,598, an arithmetic difference of 1,615. Confirmation reports38,012, difference 586, from a completed fit. No timing-qualified candidate build establishes usable recovery. Failed-route counts must not be promoted to completed-fit savings.

## 38. Historical growth recovered

Arithmetic differences correspond to29.590% primary/10.737% confirmation of 5,458. Primary is only a provisional scale comparison. Confirmation is a completed placement result, with timing qualification reported separately. Different cumulative contexts and seeds mean this does not identify individually recovered historical ALMs.

## 39. Candidate fitted registers

36,558 / 167,640 = 21.807%; baseline 48,948; delta -12,390. **Primary is a failed-route provisional report count, not a usable completed fit.** Confirmation 39,626 / 167,640 = 23.638%, delta -9,322.  SynthesisFF 36,892 vs 46,289, delta -9,397; confirmation 36,892. The 9,600 shadow FF disappear; remaining net differences include narrow engine/response/control and fitter transformations.

## 40. Candidate M10K

490 / 553 = 88.608%; baseline 488; delta +2. **Primary is a failed-route provisional report count, not a usable completed fit.** Confirmation 490 / 553 = 88.608%, delta +2.  Both infer the intended 300x32 sprite scratch, with 63 blocks free.

## 41. Candidate memory bits

3,827,650 / 5,662,720 = 67.594%; baseline 3,818,050; delta +9,600. **Primary is a failed-route provisional report count, not a usable completed fit.** Confirmation 3,827,650 / 5,662,720 = 67.594%, delta +9,600. 

## 42. Candidate DSP

39 / 112 = 34.821%; baseline 39; delta +0. **Primary is a failed-route provisional report count, not a usable completed fit.** Confirmation 39 / 112 = 34.821%, delta +0. 

## 43. Candidate setup slack

Primary setup **N/A**: fitter failed routing; assembler and TimeQuest were not run by the stop-on-failure driver. Confirmation setup -0.100 ns. Baseline remains +0.105 ns. No unrouted estimate is substituted for signoff slack.

## 44. Candidate hold slack

Primary hold **N/A** for the same reason. Confirmation hold +0.244 ns. Baseline remains +0.206 ns. Existing unconstrained-path limitations remain.

## 45. Timing violations

Primary timing violation count **unknown, not zero**: no completed STA. Stages: {"map":"PASSED","fit":"FAILED","asm":"NOT RUN","sta":"NOT RUN"}. Confirmation stages: {"map":"PASSED","fit":"PASSED","asm":"PASSED","sta":"PASSED"}; violation-summary count 1. Primary routing fails. Seed 2 fails the HDMI setup clock check with endpoint TNS -2.016 ns; all ten requested worst setup paths are violated (not an exhaustive path count). Other summary checks have nonnegative slack/TNS.

## 46. New warning types

Primary new numeric types: 10230, 16618, 16684, 169069, 188026; confirmation: 10230, 332148. New/removed normalized messages and all raw unique warnings appear in results JSON. [timing_analysis.md](timing_analysis.md) distinguishes expected experiment diagnostics from material risks; no warning is silently discarded. Existing baseline I/O/ignored-assignment/unconstrained diagnostics are not new architectural findings.

## 47. Worst-path analysis

Primary has no valid post-route worst setup/hold path: routing aborted, so there is no completed timing database/result from which to establish one. Do not reuse baseline +0.105/+0.206 as candidate timing. [timing_analysis.md](timing_analysis.md) records congestion region, hold-repair diagnostics, high-fanout changes, LAB/interconnect pressure and the confirmation result. Aggregate hold-repair delay is lower than baseline; it does not prove a new local hold path caused the failure. Seed 2 worst setup is HDMI shadowmask altshift_taps RAM -> HDMI OSD pixcnt[8],-0.100 ns; baseline worst is shadowmask dout[20] -> OSD nrdout1[20],+0.105 ns. Emulation-clock setup improves +0.635 -> +0.773 ns. The failing path is existing HDMI infrastructure, not a new local sprite-port arc; indirect placement/seed effects remain unpartitioned. See [confirmation_path_notes.md](confirmation_path_notes.md) and linked detailed paths. No hold setting, SDC, RTL or timing optimization was attempted.

## 48. Packing analysis

Primary identity: placed 36,983−recoverable 2,650+unavailable 1,004=needed 35,337. Baseline 38,598−1,955+532=37,175. Placed-minus-needed gap 1,646 vs 1,423, delta +223; placed/needed 1.0466 vs 1.0383. LogicALUT 52,434 (+5,402), route-throughALUT 8 (-18,174). Thus raw FF savings alone do not explain actual placement; global packing/routing is measured separately. Completed seed 2: 38,012-3,673+875=35,214; packing gap 2,798 (+1,375), placed/needed 1.0795. LogicALUT 52,448 (+5,416), route-throughALUT 9,075 (-9,107). LAB occupancy 4,144/4,191 (99%) vs 4,106 (98%); average interconnect 53.1% vs 49.5%, peak total 81.9% vs 79.2%. The completed physical result saves 586 placed ALMs despite 1,961 fewer needed; increased packing gap and routing pressure absorb much of the logical gain. **Primary failed-fit limitation:** only the primary counts are provisional; completed seed 2 counts are valid post-route resource measurements, with failed timing. In particular route-through ALUT delta -18,174 is not a valid routing improvement: routing did not finish. LAB footprint and localized vertical pressure remain high despite fewer FF/ALMs.

## 49. ALMs saved per additional M10K

Arithmetic 807.5 primary/293.0 confirmation reported ALMs per two added M10Ks. Primary is provisional; confirmation is not a timing-qualified usable trade. The storage conversion consumes2 of 65 free blocks (3.077%), leaving63, and retains all history. That bounded capacity cost could be reasonable for a robust gain, but the primary routing failure and seed 2 setup failure prevent accepting the conversion. No further RAM repacker or width sweep was attempted.

## 50. User-visible latency assessment

**Measurable but imperceptible** for internal serialization: ready-DDR SAVE25.106 µs NTSC / 25.337 µs PAL, modern LOAD19.611 µs NTSC / 19.792 µs PAL single/25.199 µs NTSC / 25.431 µs PAL dual. Frequencies are the unchanged nominal 53.693175 MHz NTSC/53.203424 MHz PAL physical clk_sys, not the 100 MHz fixture clock. Total estimated incremental user-visible pause is about 20–26 µs for one operation under the stated ready-DDR conditions, far below a frame; SAVE+single-VDP LOAD serial sum is 44.717 µs NTSC / 45.129 µs PAL; SAVE+dual LOAD is 50.304 µs NTSC / 50.767 µs PAL. The unchanged production LOAD flush alone is approximately 16.8ms; the short coherent-controller budget uses its existing test-only flush bypass. Existing DDR/host/file/flush delays remain and can dominate; transport waiting is not claimed zero or bounded by these numbers.

## 51. Confirmation-build result

One controlled same-source **seed 2** attempt, with only SEED changed and a fresh database. Primary map PASSED/fit FAILED; confirmation stages{"map":"PASSED","fit":"PASSED","asm":"PASSED","sta":"PASSED"}. Primary table placed 36,983; confirmation 38,012 (+1,029), needed 35,214, setup -0.100 ns, hold +0.244 ns. Seed 2 completes routing but fails setup timing. Neither tested seed qualifies physically; the completed placement difference is 586 ALMs, with +2 M10Ks. No broad seed sweep or candidate tuning followed. See manifests/results, [build_control.json](build_control.json) (all 139 inputs compared; only SEED differs) and timing_analysis.md.

## 52. Current versus sequential comparison

| Property | Current parallel internal state | Candidate A |
|---|---|---|
| Meaningful history | 9,556 bits | same |
| External transport / image | DDR64 /v17 | identical |
| Internal state port | two 4,778-bit vectors | local 32 bits,8-bit address |
| Scratch | two 4,800-bit FF rings |300x32 RAM,2M10Ks |
| Restore | broad bank/local parallel selectors | selected local 32-bit scatter |
| Control | broad capture/ring/strobe | narrow port/decode, original architectural strobe |
| Needed ALMs |37,175|35,337|
| Placed ALMs |38,598|36,983|
| Fitted FF |48,948|36,558|
| M10Ks |488|490|
| Setup /hold |+0.105 ns /+0.206 ns|N/A (no completed STA) /N/A (no completed STA)|
| Added ready-DDR SAVE |0|1,348 clocks|
| Added modern LOAD |0|1,053single/1,353dual|
| Complexity | parallel field wiring and ring | local fixed map, RAM/handshake/gather-scatter |

Both retain exact tested guest futures. Candidate adds private transaction/control complexity and a small frozen-time cost; production stays available unchanged.

**Physical qualification:** primary resource numbers above are provisional because routing failed; primary timing is N/A. No row in this comparison establishes a deployable placement improvement.

## 53. Broader applicability

The candidate did not establish a robust physical success, so no broader conversion is recommended from this experiment. Source-level roadmap only: CRAM/VDP architectural shadow groups could have MEDIUM POTENTIAL; compact background/mapper/Evolution/peripheral/CPU contexts LOW POTENTIAL; already sequential WRAM/VRAM/NVRAM and already converted F01 NOT APPROPRIATE; tiny G10 temporal controls NOT APPROPRIATE. These are unmeasured possibilities, not new investigations or implementation targets. No HIGH POTENTIAL claim is supported for another group. No F06/G08.FM work occurred.

## 54. Risk assessment

Finite simulation plus compositional identity, not exhaustive formal proof. Most integrated fixtures are8-slot; full 64 correctness is separately checked by local state/output and accelerated/pending cases. Existing timing constraints leave some paths unconstrained; only two candidate seeds are measured. Two M10Ks are spent and local read/decode fanout remains. Private partial LOAD writes require freeze and validation-before-apply to stay intact; future conversion should retain mandatory regressions and source binding. Earlier distributed-response runs are explicitly bridged, not mislabeled as selected-source runs. Production F01/v17 remains unchanged and no next implementation was performed. **Observed blocking risk:** the unchanged32-bit candidate cannot be accepted after the primary router failed. Fewer logical FF and fewer reported ALMs do not imply routability. New local decode adds 5,402 logicALUTs in the primary attempt; broad selected write and reduction networks remain. The exact causal partition between port topology, physical locality, hold repair and seed/global fitting is unproven. One seed control bounds the experiment; no tuning was performed.

## 55. Decision gate

**E. FUNCTIONAL OR TIMING RISK - DO NOT CONVERT**. This is a recommendation based on the isolated experiment, not authorization to replace production in this task.

## 56. Recommended next roadmap step

**5. reconsider capacity strategy**. Do not perform that next step here. Carry forward exact format/native/latency/resource gates and the two-M10K trade.

## 57. git diff --stat

```text
(empty — no tracked production changes)
```

Candidate sources, tests, manifests and reports are isolated under this untracked test directory; the command does not include untracked experiment files. No generated Quartus artifacts are staged or tracked.

## 58. git status --short

```text
?? tests/
```

Existing test artifacts and this experiment are under the untracked tests tree. Nothing staged; no commit, push or PR. [final_integrity.json](final_integrity.json) verifies unchanged production hashes, HEAD, branch, index and frozen candidate/build sources.
