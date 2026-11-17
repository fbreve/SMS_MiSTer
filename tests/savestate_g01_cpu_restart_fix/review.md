# G01 CPU restart correction

**CLOSED - FIXED AND PROVEN. READY TO COMMIT.** Current v13 G01 CPU restart, scoped regressions and full controlled Quartus build pass. No staging, commit, push or PR was performed.

## 1–4. Baseline, original failure and edge timeline

Baseline HEAD: `faf7036e4450027f79cc639a731053dca29840ca`, committed F16. Branch: `fix/savestate-g01-cpu-restart`. The six requested authoritative reports were read; the [G01 investigation](../savestate_g01_cpu_restart/review.md) remains the original counterexample, rather than being rewritten as passing evidence.

The original normal and turbo witnesses accept a real SAVE at PC012A, the B0 byte of ED B0. Baseline LOAD clears the preceding IR=ED; historical T2 therefore fetches B0 with ISet00 instead of ISet10. The CPU performs OR B and skips LDIR. The first register difference is BC one enabled step after canonical T2; the next source-data read is missing. The old C110 mapping byte happens to agree, while guest-written BC/DE/HL observer bytes expose the lost work.

Normal witness timeline (CPU period15):

| Edge | Uninterrupted execution / saved representation |
|---|---|
| T−60, cycle170521 | Fetch ED at0129; IR becomes ED, ISet remains00; combinational Prefix becomes10 |
| T−45, T−30 | ED's MC1/T3,T4 finish and start another M1 fetch |
| Request170558 | Request sees the following fetch's MC1/T1; no CPU state is forced |
| T−15 | T1 sets up the B0 memory read |
| T=170581 | Pre-edge PC/A012A, IR=ED, ISet00, Prefix10 qualify production acceptance. Capture architecture A−, context class2 and F16 normalized NMI triplet. Reference simultaneously installs IR=B0/ISet10 and advances PC to012B |
| T+1 | ARM captures post-T GG/IO and freezes before another CPU enable |
| LOAD/DIRSet | Restore architecture and seed IR=ED from class2; keep existing MC1/T1, bus normalization and global hold |
| NMI metadata | Existing later F16 CEN0 installation replaces pending/entry/Old, after DIRSet |
| Historical T1 | Issue the mandatory fetch with ordinary memory setup time; GG/sampler remain held |
| Historical T2 | Read B0 and consume the seeded ED. IR=B0/ISet10, matching reference immediately after T |
| First continuation | LDIR decrements BC, reads source, writes destination and repeats/terminates at the same guest cycles as reference |

The first lost information is the **pre-T2 predecessor decoder class**, not the newly fetched B0, the mapper latch, or an ALU result. [design.md](design.md) records the pre-edit analysis and alternative assessment.

## 5–11. Accepted-boundary prefix inventory

Production uses T80 Mode0, WAIT high and BUSRQ inactive. M1 low plus MREQ low on a CPU enable identifies the ordinary fetch's pre-edge MC1/T2. ISet00 does **not** establish that the preceding IR has no pending prefix.

| Family | Reachable accepted context | Disposition / required representation |
|---|---|---|
| CB | Old IR=CB, ISet00, XY_State00, next opcode read | POSSIBLE AND REQUIRES PRESERVED STATE: class1. The later ISet01 operation is excluded by existing acceptance |
| ED | Old IR=ED, ISet00, including block first/repeat/terminal fetches | POSSIBLE AND REQUIRES PRESERVED STATE: class2. The later ISet10 operation is excluded |
| DD | Old IR=DD with ISet00; prior index selection may differ | POSSIBLE AND REQUIRES PRESERVED STATE: class3. T2 overwrites index selection from this prefix |
| FD | Same, selecting IY | POSSIBLE AND REQUIRES PRESERVED STATE: class4 |
| DDCB | Can accept before the CB byte with old IR=DD | POSSIBLE AND REQUIRES PRESERVED STATE, already class3. The later indexed displacement/opcode stages use MC6/MC7 and are IMPOSSIBLE AT ACCEPTED BOUNDARY |
| FDCB | Can accept before CB with old IR=FD | Same argument using class4; no additional indexed-CB payload |
| Repeated/mixed DD/FD | Consecutive prefix bytes remain ISet00 | POSSIBLE AND REQUIRES PRESERVED STATE. Save the most recent DD/FD class; no prefix-count history is needed |
| DD/FD followed by ED | ED's following fetch may retain old index selector | POSSIBLE BUT index state is FULLY RECONSTRUCTABLE: pending ED clears it at historical T2 |

For pending unindexed CB, XY_State00 is a reachability invariant: indexed CB routes to MC6/MC7 rather than another accepted M1 fetch with old IR=CB. For no-prefix, historical T2 clears index state; DD/FD overwrite it; ED clears it. Thus no independent XY_State/XY_Ind bit is required in this representation. Pre_XY_F_M belongs to excluded indexed microcycles. ISet11 and XY_State11 are not assigned by the normal Mode0 transition graph.

The proposed state is six classes, encoded in three bits: ordinary=0, CB=1, ED=2, DD=3, FD=4, EI=5. Codes6/7 are invalid. EI matters because SetEI still acts at T2 before IR is replaced. HALT already has architectural Halt_FF; its fetch suppression is covered by that bit or by the saved NMI-entry state. No independent predecessor-HALT bit is required.

## 12–20. Block/repeat inventory and results

| State | Boundary reasoning |
|---|---|
| BC/DE/HL, flags, WZ, PC | Explicitly restored architecture; contains the completed previous iteration and the next iteration's operands |
| Pending ED | Must preserve class2; it selects the correct block opcode interpretation at T2 |
| No_BTR | Reconstructable. ISet00/MC1 has no I_BT/I_BC/I_BTR decision; the preceding T1 has recomputed it to zero. Later iteration decisions derive from the restored registers/flags and new decode |
| BTR_r | Reconstructable. Prefix instruction completion overwrites the old block decision. Its non-fetch T2 consumer is preceded by a new instruction-end decision |
| ALU writeback/pipeline | No general writeback survives preceding T1: Save_ALU_r and Read_To_Reg_r are clear. Later operand/ALU consumers are preceded by decode/refill. No temporary ALU payload is added |
| MCycle/TState and bus strobes | Existing canonical T1/T2 replay reconstructs fetch phase. The repair supplies the missing decoder input to that replay |
| Auto-wait | Normal fetch has no IO/INT acknowledge wait; replay refills the existing wait pipeline before its consumer |

An actual accepted state cannot be an arbitrary mid-block transfer merely because SAVE was requested there. Requests during copy/compare/IO microcycles defer. Acceptance can occur at the repeated ED opcode sequence and at its terminal transition; that context is preserved without storing a repeat counter separate from BC.

All eight instructions pass real T80 first, middle and terminal LOADs:

| Instruction | Program | Accepted first / middle / terminal count | Result |
|---|---:|---|---|
| LDIR | 18 | BC0003 /0002 /0001 | PASS |
| LDDR | 19 | BC0003 /0002 /0001 | PASS |
| CPIR | 20 | BC0003 /0002 /0001 | PASS |
| CPDR | 21 | BC0003 /0002 /0001 | PASS |
| INIR | 22 | BC037C /027C /017C | PASS |
| INDR | 23 | BC037C /027C /017C | PASS |
| OTIR | 24 | BC037C /027C /017C | PASS |
| OTDR | 25 | BC037C /027C /017C | PASS |

First-iteration requests use offset40496, selected from **observed** BC3 acceptance; middle/terminal requests use offsets1348/2570. An earlier offset1968 was naturally deferred into BC2 by the video capture window; those eight successful replays are additional repeat cases, not mislabeled first-iteration coverage.

Guest code initializes three distinctive RAM bytes and ascending/descending source/destination addresses. Compare instructions use a nonmatching accumulator to reach their terminal count. The test IO port supplies a defined address-dependent pattern under identical future inputs. Full architectural registers, flags, PC/SP/WZ, active bus transfers, write strobes/data and all8192 final RAM bytes match reference. Exact bus waveforms catch skipped or duplicated memory/IO iterations, rather than relying solely on final BC.

## 21–25. Solution comparison and choice

| Solution | Correctness, complexity and compatibility assessment |
|---|---|
| A: exclude prefix/repeat context at capture | Cannot provide the required general bound: a ROM containing an unending DD/FD stream can keep every later eligible fetch prefixed. Seeking an excluded boundary can stall SAVE indefinitely or require unbounded paused CPU/PSG progress. No format bits, but new CPU qualification and F12 liveness obligations; rejected |
| B: preserve minimal semantic context | Three bits distinguish six relevant predecessor classes; seed existing IR at DIRSet and use unchanged T1/T2. Adds context ports through CPU/wrapper/system/top/controller and v13 validation. Legacy files normalize to ordinary. F16 ordering, F12 endpoint and G09 mandatory read remain unchanged. Small logic/register cost, no additional memory word; selected |
| C: replay earlier instruction history | PC−1 cannot establish general prefix chains, control-flow or mutable-code history. Re-executing predecessors risks duplicate guest effects and would itself need history. More complexity and verification than B; no complete reconstruction established |
| D: exclude some classes and preserve others | Still needs tagged payload and restore wiring while inheriting acceptance/liveness proof obligations. No advantage over the single three-bit representation; rejected |

The selection follows semantic completeness and capture liveness, not RTL line count. Existing capture acceptance is unchanged. The three-bit field is the smallest fixed-width code for these six semantic classes; it is not a claim that a literal eight-bit IR must be serialized.

## 26. Sufficiency proof before production edits

[sufficiency.json](sufficiency.json) records an **empty tracked diff before production edits**, all six observed classes, nine successful prototypes with27 exact LOADs, and960 naturally accepted observations. [design_pre_edit.md](design_pre_edit.md) preserves the exact document matching that gate's source hash; the later design appendix expands the consumer-order explanation. The prototype uses an explicit test-only side record, separate from the unchanged v12 controller. Its quick variant shortens only test flush latency and holds the fixture beam during freeze. It is CPU-state proof, not a production v13 format test.

The static argument enumerates every input of the accepted T2 transition:

1. Architecture is restored explicitly; phase is canonical MC1/T2, WAIT1, IntCycle0. F16 supplies normalized NMI pending/entry/Old.
2. T1 has drained general ALU/register writeback. MC1/T2 is not an instruction-end T_Res. Register increment/decrement, exchange and non-fetch completion paths cannot consume an omitted predecessor result there.
3. The old decoder's future-relevant T2 actions are prefix selection, index selection from DD/FD, and SetEI. The six classes preserve those exactly. HALT's PC suppression is supplied by saved Halt_FF or the saved NMI-entry condition. Other predecessor outputs are overwritten before their first meaningful consumer.
4. XY selection is cleared, overwritten, or covered by unindexed-CB reachability as above. Block decisions are overwritten before use. Operand/address/ALU pipeline registers refill before the newly fetched instruction consumes them.
5. Therefore restored historical T2 reaches a state future-equivalent to reference T+. Subsequent deterministic guest transitions under identical logical future inputs preserve that equivalence. Equal serialized architecture/NMI/context cannot distinguish two future-relevant predecessor histories through an omitted instruction-context bit at this boundary.

This is the completeness argument; finite tests corroborate it. Absence of a random collision alone is not treated as proof. The proof is for production Mode0/boundary/input wiring, not arbitrary forced T80 state or another CPU mode.

The remaining normalization inventory is resolved as follows: ISet00 and MC1/T1 reset into the historical T2; MCycles relatches the new opcode before instruction-end use; XY_Ind/Pre_XY_F_M are established by the new indexed-fetch sequence, including LD(IX/IY+d),n's special return selection. IntCycle is excluded by the acknowledge bus predicate. Auto_Wait_t1/t2 and BusReq_s/BusAck normalize safely under production WAIT/BUSRQ defaults. T80s DI_Reg refills at historical T2; T80 DI_Reg is an alias. DO is inactive until a freshly decoded write supplies it. Z16_r and I_RXDD cannot carry a relevant accepted ISet00/MC1 distinction; the ALU/address/operand shadows refill in the consumer order documented in design.md. RFSH_n has no connected production consumer in system.vhd and is rederived at historical T2; its retained Q value during synthetic setup needs no payload. Halt_FF/IFF/IM remain architectural fields. No previously listed potentially relevant pipeline item is silently treated as serialized.

## 27–29. Format, legacy policy and exact RTL scope

**v13 introduced.** No final format consolidation was performed.

| Location | v13 meaning |
|---|---|
| Word0x005 bits37:0 | Original architectural REG[229:192], unchanged |
| Bits40:38 | Existing F16 normalized pending/entry/Old, unchanged |
| Bits43:41 | Pre-T2 semantic context0..5 |
| Bits63:44 | Zero padding |
| Word0x01A bits63:40 /39:38 | Tag48430D / subtype3 |

No new DDR word or container length. v13 inherits every v12 NMI and earlier peripheral/Evolution field. The reader rejects all20 high-padding bit positions, reserved context6/7, and invalid tested subtypes before guest-state writes. Both CPU word5 writer paths carry the same new field.

v12 retains exact F16 NMI metadata and requires its original zero padding63:41. Its missing CPU context normalizes to ordinary, matching the former CPU policy. v1–v11/untagged files retain F16's deterministic pending0/entry0 and Old sampled from settled current input after GG restore. Old CPU prefix/EI history was never recorded and cannot be recovered; no PC−1 guess is attempted. The genuine upstream64KB path is retained. Older development readers are not promised exact interpretation of new v13 history.

Only these production files change:

* `rtl/T80/T80.vhd`: export semantic class and seed representative IR only on valid DIRSet.
* `rtl/T80/T80s.vhd`: forward context ports; F16 sequencing unchanged.
* `rtl/system.vhd` and `SMS.sv`: connect context/valid signals.
* `rtl/savestates.sv`: atomic pre-T capture, word5 transport, v13 tag/validation and legacy absence policy.

No normal CEN execution branch, mapper/VDP/audio logic, acceptance predicate, capture-progress expression, or NMI hold/replay ordering changes. No F01/F06 or other G implementation was undertaken.

## 30–37. Post-fix guest oracle and broader G01 proof

The [72-case full matrix](simulation_results.json) includes the56 planned cases plus16 additional EI/held-input/repeat cases. Every case performs actual SAVE transport, strict400-enable SAVE-only comparison, three different legal Q perturbations, then three actual LOADs and12000-host-clock suffixes. The first comparison is after restored historical T2 against reference immediately after accepted T. Transport and synthetic T1 are outside logical alignment; inactive bus data is masked, active transactions are not.

The original normal offset1056 and turbo offset800 cases now pass, including the appended BC/DE/HL guest observer. Original BC2 and BC1 continuations both finish with BC0 and DE=HL=A002. The three previously different observer bytes now agree after every LOAD. The independent RAM-copy fixture additionally proves a real WRAM copy, rather than relying on the original A000 mapper-write suppression or its equal page signature.

| Child | Evidence and disposition |
|---|---|
| Prefix/restart | CB, ED NEG, DD/FD indexed registers, DDCB/FDCB memory effects and mixed prefix chains; current class transport and repeated LOAD pass. CLOSED - FIXED AND PROVEN |
| Block | All eight operations at count3/2/1 and repeat requests, complete bus/RAM/flags/register replay; no skipped/duplicated iteration. CLOSED - FIXED AND PROVEN |
| EI delay | EI followed by distinct C140/C141 stores; real IM1 handler increments C142. INT inactive, already pending/held, asserted after T, pulse during protected continuation and near-capture assertion. Additional SAVE requests span protected/following execution. Exact interrupt/vector/stack/PC timing matches. CLOSED - FIXED AND PROVEN |
| HALT | No interrupt; requests before/while halted; INT pending and arriving while halted; NMI pulse and held future source; repeated LOAD after Q wake/perturbation. Halt_FF, fetch/PC, wake, vector, stack and instruction effects match. CLOSED - FIXED AND PROVEN |
| General restart | Register/immediate arithmetic, RAM read/write, PUSH/POP, CALL/RET, taken/untaken branch timing, defined IO read/write. Complete architecture and active transactions match. CLOSED - FIXED AND PROVEN |

[trace_cases.json](trace_cases.json) adds18 full runs with explicit canonical and first-continuation records plus known-bit checks throughout the architectural suffix and final RAM. They cover the six classes, all eight block operations, HALT interactions and ordinary execution. `CANONICAL_TRACE` at k0 records post-historical-T2; k15 records the first subsequent enabled CPU transition. For example LDIR has IR=B0/ISet10 at k0 and its BC decrement at k15, never OR-B decoding.

Across the90 full G01 runs (72+18):270 LOADs,3,240,270 post-LOAD host-clock comparisons,36,000 SAVE-only native-enable comparisons and2,211,840 final RAM-byte comparisons. Each repeat uses the same saved image after different Q instruction/IO/RAM histories. Pending INT and pulse/held NMI families exercise different interrupt histories. The original mapper-integrated variants also vary actual mapper/BIOS/Wonder Kid histories.

Normal15-clock, turbo10-clock and System E10-clock representative CPU cadences pass. The latter is a CPU/controller cadence and mode-selection check, not a claim to close the separate full clock-tree, encrypted ROM or dual-VDP obligations.

## 38. Post-fix complete-image search

All90 retained G01 images contain12,288 known64-bit words; compare the **entire image**, not just the CPU word. Candidates are grouped by immutable guest program, observer-ROM choice, machine mode, cadence and identical future input schedule. Cross-ROM or different-INT-future pairs are not used as non-injectivity evidence.

The bounded search varies naturally accepted prefix, block-count, EI/protected-boundary and HALT/restart histories. Different pending decoder classes necessarily differ at word5; repeat counts and HALT/IFF distinctions are represented architecturally. Within the ordinary class, the overwrite-before-consumer argument above addresses discarded IR/index/pipeline histories.

There are26 equal-image groups, including independently repeated trace/control snapshots and requests that naturally defer to the same accepted state. Their observed pre-capture context records agree; every associated LOAD follows its own independent reference. **No equal complete current-format images with differing observed omitted CPU context, and no divergent guest continuation pair, were found.** This is a bounded search with repeatability controls, not a claim of format injectivity from failure to find a pair. Hashes, grouping and raw context observations are retained in [simulation_results.json](simulation_results.json).

## 39–42. Scoped regressions

| Scope | Current result |
|---|---|
| F16 CPU/NMI | 56 current-format scenarios, including released-second-pulse111, plus24 malformed-format and10 legacy cases. All eight actual normalized triplets pass; capture-edge pulse, held/released source, GG ordering, later DIRSet-safe metadata, real handler and repeated LOAD are checked |
| Exact final-source NMI bridge | Ten cases independently recheck all eight triplets and GG−45/−15 ordering using the final controller/CPU adapters. This also bridges an early reset-default cleanup; normal replay logic was unchanged |
| v12 compatibility | Both SMS and GG retain F16 metadata and match exact reference,18,403 comparisons per case. They are not incorrectly normalized as pre-F16 legacy |
| Malformed v13 | 24 cases ×three rejected LOAD requests=72; all20 padding positions, context6/7 and subtypes0/2 reject before monitored guest-state writes |
| G09.last-read | Original ordinary A000 and HALT/NMI paths, plus the repaired original LDIR cases. Historical T1/T2 remains mandatory; the latch is replaced before dependent writes. G09 stays CLOSED - PROVEN RECONSTRUCTABLE |
| F12 Pause | Paused M1: overrideCPU0/PSG0; paused non-M1: bounded overrideCPU7/PSG5. Both CPU/PSG SAVE-only trajectories and capture liveness pass; logical host Pause is preserved |
| F15 Evolution | Actual T80 three-LOAD replay and directed cases0/5/9 pass |
| F13 detection | Cases0/6 pass, including current history/deadline behavior |
| Controller capture | Current-tag Tap DDR case0 passes, plus GG DDR's14 modern/legacy/invalid/non-GG scenarios and mid-transfer replay |

The new capture endpoint is identical to F16, so F12 progress does not gain an extra prefix-draining interval. No unrelated exhaustive peripheral matrix was rerun.

## 43–44. Run accounting, adaptations and disposition

**234 canonical passing runtime cases/groups:**9 pre-edit state prototypes,8 pre-edit capture sweeps,17 post-edit capture sweeps,72 full G01 cases,18 known-bit/trace cases,90 scoped F16/format/legacy cases,10 final-source NMI cases,8 Evolution/detection/Pause regression groups and2 controller integration groups. Sweeps account for960 pre-edit and2040 post-edit actual acceptances; these are not inflated into completed SAVE/LOAD transports. The GG runtime group contains14 internal scenarios.

Additional successful compile pilots/repeatability runs are supporting evidence, not additional unique proof coverage. Superseded fixture/debug attempts are excluded: missing prototype restore insertion, stopped preliminary runs, undefined mock IO/IM0 input, inherited block-IO mask width, an inherited full-run PASS label, incorrect pre-F16 expectations for v12, and the second-pulse hold/release mistake. All identified issues were resolved in canonical evidence; no functional mismatch was waived or admitted by weakening register/bus equality.

Test adaptations are explicit: qualified VHDL entity bindings; controller forward-declaration placement; observation ports; defined external test IO data; and a nine-bit zero-extended low-three-bit mask in the **simulation adapter only** for inherited `ioq and x"7"`. ModelSim otherwise raises an operand-width runtime failure on block IO. This does not modify production ALU behavior or purport to validate the entire Z80 ISA. Final trace assertions reject unknown architectural/RAM values.

The primary fixtures use real T80, controller/DDRAM, IO and video, with modeled ROM/RAM and other peripheral endpoints. Original witnesses/G09 retain production mapper/decode; instruction-only cases use transparent fixed memory mapping. Physical live SDRAM/decryption, full CE-tree coupling, initialized VDP output and raw physical-peer rewind remain their separate obligations. G01 closure does not close G02–G08/G10–G12.

**Final functional G01 classification: CLOSED - FIXED AND PROVEN for modern v13 and the stated production/logical-input contract.** Legacy absence of CPU context is deliberately documented, not claimed recoverable.

## 45–54. Controlled Quartus result

Full isolated Quartus17.0.2 compilation **passes**,19:01 elapsed. Baseline sources were verified against134 committed F16 inputs; two retained manifest-only backup inputs are recorded separately and unused. The candidate was prepared from source only, without a reused build database. No root QSF/seed change was made. [verify_sources.js](verify_sources.js), [qsf_flow.json](qsf_flow.json) and [results.json](results.json) verify source/flow identity. Compilation began only after the234-case simulation gate passed.

| Requested resource | F16 baseline | G01 candidate / capacity | Utilization | Delta |
|---|---:|---:|---:|---:|
| ALMs needed | 27,416 | 27,368 /41,910 | 65.302% | −48 |
| ALMs placed | 32,784 | 32,684 /41,910 | 77.986% | −100 |
| Fitted registers | 36,840 | 36,831 /167,640 | 21.970% | −9 |
| M10K | 487 | 487 /553 | 88.065% | 0 |
| Memory bits | 3,809,858 | 3,809,858 /5,662,720 | 67.280% | 0 |
| DSP | 39 | 39 /112 | 34.821% | 0 |

Worst setup **+0.483ns** (F16 +0.540, delta−0.057); hold **+0.213ns** (F16 +0.246, delta−0.033). **Zero** negative-slack/TNS timing-summary checks. Existing timing/IO constraint warning classes remain; zero violations does not claim that previously unconstrained paths gained new constraints.

**New warning types/messages: zero.** Normalized distinct warnings84→84, critical38→38; connectivity hierarchy count19→19 and sections44→44, with no added sections. The full compile reports100 aggregate warnings, not zero warnings.

The five new logical registers are context snapshot3, validity1 and padding-check1. Synthesis merges the existing cur_bios_mode with equivalent cur_magic[0], whose assignments are unchanged, giving mapped registers35,892→35,896 (+4). CPU/wrapper own register counts remain216/14. Controller own ALUTs5399→5390; CPU858→880; wrapper20→21. [prefit.json](prefit.json) retains the exact merge and assignment ledger.

Fitted register differences are physical optimization/duplication changes, not removal of emulated CPU state: per-entity own-register deltas sum exactly−9. The unchanged128-bit T80 register file has136→129 fitted registers; controller own fitted registers rise4835→4841. The complete ledger and other entity changes are in [resource_analysis.json](resource_analysis.json).

Placed ALMs decrease100 (0.305% relative to F16), so there is no unexplained large increase. Packing reconciles exactly: baseline32,784−5,670+302=27,416; candidate32,684−5,601+285=27,368. Delta−48=−100+69−17. Logic ALUTs decrease36 and routing ALUTs68. No new RAM or DSP allocation; M10K remains the most constrained requested resource at88.065%. No unrelated fitter optimization was introduced.

## 55–57. Repository hygiene and recommendation

Only five intended production files and this test/report directory change. No generated Quartus output is staged/tracked. Existing reports are preserved. Nothing staged; no commit, push or PR.

`git diff --stat`:

```text
 SMS.sv            |  8 +++++++-
 rtl/T80/T80.vhd   | 26 +++++++++++++++++++++++++-
 rtl/T80/T80s.vhd  |  8 +++++++-
 rtl/savestates.sv | 38 ++++++++++++++++++++++++++++----------
 rtl/system.vhd    |  5 +++++
 5 files changed, 72 insertions(+), 13 deletions(-)
```

`git diff --cached --stat`: empty. `git status --short`:

```text
 M SMS.sv
 M rtl/T80/T80.vhd
 M rtl/T80/T80s.vhd
 M rtl/savestates.sv
 M rtl/system.vhd
?? tests/
```

The untracked tests tree predates this task. A local ignore file excludes generated compiler caches and isolated candidate/proposed trees from accidental staging; retained test/report evidence remains available.

**READY TO COMMIT.** G01's five children are closed for modern v13 within the stated contract; scoped compatibility/regressions, source identity, resource sanity and full fit/timing gates pass. Nothing staged or committed. This is not a declaration that the other open F/G findings or the final hardware campaign are complete.

## Reproduction

Use PowerShell with ExecutionPolicy Bypass. `prepare_candidate.js` derives proposed files from the exact committed F16 baseline; `gate_proof.js` requires the pre-edit proof and empty production diff and therefore belongs before applying those files. Current integration generators use the retained proposed sources; build/source hashes verify identity with the five actual production files.

Prepare integration with `prepare_integration.js`, compile once using `integrated.ps1 -Compile`, run `sweeps.ps1`, `plan_matrix.js`, four `matrix.ps1` workers, and the additional first-iteration/EI cases. `prepare_trace.js` and `trace_batch.ps1` produce explicit known-bit traces. `prepare_nmi.js`/`nmi/batch.ps1` reproduce scoped F16/legacy/rejection coverage; the released second pulse uses RELEASE_SECOND=1. `prepare_final_nmi.js` creates the final-source eight-triplet bridge. `prepare_regressions.js`/`regress.ps1` and `prepare_controllers.js` run scoped interactions. Finally run `check_simulations.js --final`, prepare a fresh isolated candidate with `prepare_build.js`, then `build.ps1`, resource analysis and Quartus result extraction.
