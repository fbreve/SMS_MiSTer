# F16 capture-edge prerequisite

**F16 IMPLEMENTATION UNBLOCKED.** Select **B: normalized post-sample NMI history**, with the existing pre-edge architectural CPU payload and post-edge GG payload. Three temporal bits suffice. Production RTL and v11 are unchanged; this directory contains simulation-only prototypes and evidence, not the F16 implementation.

Baseline/branch: `d1df590`, `fix/savestate-cpu-nmi`. The complete [original investigation](../savestate_cpu_nmi/review.md) was reread. Its defect/non-injectivity findings remain authoritative and were not re-investigated. This report resolves its one explicitly open capture/restore semantic choice.

## 1–4. Exact clock ordering and saved instant

Let **T** denote the rising clk_sys edge on which the production controller actually accepts SAVE. Superscripts −/+ mean immediately before that edge and after its signal/nonblocking assignments settle. This is logical RTL sampling, not a claim about an asynchronous pin's physical setup/hold or metastability.

| Operation | Sequential location / enable | What it reads and schedules |
|---|---|---|
| NMI input | `SMS.sv:1044`, `system.vhd:620`, `io.vhd:185` | Before T, CPU sees `(pause or effective_gg) and gg_link_nmi_n`. GG NMI output is combinational from local source flags; host Pause and peer pins remain external |
| CPU edge sampler H | T80 main process, rising CLK_n, RESET inactive, DIRSet=0; **not CEN gated** | Reads input nᵀ and previous Old. Schedules NMI_s=1 on Old=1/input=0; immediately updates its local Old variable. Signal assignments become visible after the process/delta, not to another clocked process's pre-edge read |
| CPU progression F | Same T80 process plus architectural datapath process and T80s bus process, rising clock, CEN=1 | Reads pre-edge microstate, registers and flags. At accepted MC1/T2 it fetches the opcode (or NMI dummy NOP), updates PC/R/IR/bus, and retains pending/entry flags; it does not perform instruction-end NMI arbitration here |
| GG progression G | IO process, rising clk, !ss_freeze, ce_cpu | Reads previous synchronizers/PC6 history, updates pipelines and local NMI source flags. Output may fall only **after T** as those assignments settle. CPU sampler H(T) sees the old GG output, not that new flag |
| SAVE acceptance / CPU capture | `savestates.sv:1014`, rising clk, state37, !storage_busy, cpu_ce, !M1, !MREQ, ISet00, vblank, x<256 | `z80_snap <= z80_reg` takes **architectural CPU state A⁻**, before F(T). It does not see PC/R updated by that same edge |
| GG/IO capture | ST_ARM_FREEZE at T+1 | Reads **G⁺**, produced by G(T). No second CPU enable has happened. `gg_snap` and `io_snap` are post-T; freeze is scheduled for this edge |
| Production DIRSet | T80/T80s clocked processes; independent of CEN | Restores architectural registers; canonicalizes MC1/T1 and bus; explicitly clears NMI_s/NMICycle. Does not assign Old. It suppresses ordinary sampling on that edge |
| GG restoration | IO gg_state_set, same rising edge as CPU DIRSet | Restores local source flags and synchronizers even while frozen. A restored source can change NMI_n **after** the DIRSet edge settles. Without protection the next host-clock sample sees it using Q's stale Old |

Separate processes execute concurrently. Source-code ordering does not make the controller see CPU post-state or make T80 see GG's newly scheduled flag. Instrumented assertions check `dut.z80_snap == saved_cpu_pre` at T and `dut.gg_snap/io_snap == saved_gg/io_post` at T+1. Logs show normal PC0101→0102 and R increment after T while the CPU snapshot still contains PC0101 and pre-increment R. NMI entry instead suppresses that PC increment. This establishes the existing convention using working fields, rather than inventing an NMI convention.

The existing whole-core snapshot already has a deliberate component boundary: **A⁻ with G⁺**. It is not a claim that every field comes from one global post-edge image. The proposed extension preserves every architectural CPU field's meaning and explicitly normalizes just the sampler substep H(T).

## 3. Capture-edge truth table

Tuple order throughout this report is **(P,C,O) = (NMI_s, NMICycle, OldNMI_n)**. Let n be the effective input read at T. At accepted MC1/T2, the exact sampler transition is:

```
edge = O− AND NOT n
P+   = P− OR edge
C+   = C−
O+   = n
```

There is no pending consumption or new NMICycle arbitration at this fetch substep. These equations are not the general transition for an instruction-end clock.

| Case | Input just before T / Old / P / C | Effective sample n | After T (Old,P,C) | Reference meaning |
|---|---|---|---|---|
| Inactive | 1 / 1 / 0 / 0 | 1 | 1,0,0 | No event |
| Already sampled low, no pending | 0 / 0 / 0 / 0 | 0 | 0,0,0 | Held level creates no new edge |
| Fresh assertion first sampled at T | 0 / 1 / 0 / 0 | 0 | 0,1,0 | One remembered event |
| Short pulse, first sample T | 0 / 1 / 0 / 0 | 0 | 0,1,0 | Same event even if input goes high at T+1 and is gone before LOAD |
| Rise/deassertion first sampled at T | 1 / 0 / 1 / 0 | 1 | 1,1,0 | Release changes Old, preserves pending |
| Pending released pulse | 1 / 1 / 1 / 0 | 1 | 1,1,0 | Pending survives inactive input |
| Pending held pulse | 0 / 0 / 1 / 0 | 0 | 0,1,0 | No duplicate |
| Consumed/entry, input released | 1 / 1 / 0 / 1 | 1 | 1,0,1 | Continue selected NMI entry |
| Consumed/entry, input held | 0 / 0 / 0 / 1 | 0 | 0,0,1 | Continue once, no second request |
| Fresh edge during selected entry | 0 / 1 / 0 / 1 | 0 | 0,1,1 | Entry plus another pending request |
| Both pending and entry already present | 1 / 1 / 1 / 1 | 1 | 1,1,1 | Preserve both |
| GG flag scheduled by G(T) | CPU input1 / Old1 / P0 / C0 at T− | 1 | 1,0,0; GG output becomes0 after T | **Not** a CPU edge at T. H(T+1) must observe the fall |

“Exactly at T” means the level presented to the sampler for that edge. The SMS test drives it on the preceding negative edge. A GG flag scheduled by a simultaneous clocked assignment belongs to the last row, not the fresh-assertion row. Releases are also classified by the sample the CPU actually sees, rather than by an ambiguous same-edge testbench race.

## 5–9. Candidate experiments and commutation proof

Both candidates run from the same naturally executed ROM prefix, use the actual controller acceptance condition and actual CPU architectural capture, and record an uninterrupted reference continuation. Neither forces a CPU state to manufacture acceptance. The ROM is the established real T80 counter/signature handler; CPU, T80s and IO are production-derived, with explicit test-only sampler/state controls. The production controller observes the uninterrupted CPU to establish T; its later freeze is deliberately not used to stop the reference. This is an acceptance observer, not a claim that an active SAVE's transport can run concurrently with an unfrozen production CPU.

Candidate LOAD is prototyped in harness logic: architectural DIRSet and GG set are asserted together, exactly as production does, and the proposed side record is applied through test-only inputs afterwards. It does not serialize a new format or claim to test a production v12 reader. The separate established runs exercise the actual unchanged SAVE/LOAD machinery.

**A — pre-edge plus replay:** store P⁻,C⁻,O⁻ **and nᵀ**. After DIRSet has ended, apply the pre-triplet while CEN=0. Perform canonical CPU T1 bus setup with GG held. At historical T2 replay, feed nᵀ to the sampler instead of current external input while the CPU replays F(T). Then release normal sampling. This reproduces H(T) exactly even when current input is high at LOAD. Three pre-bits alone fail the mandatory short pulse. A captured falling-event bit alone is not a complete literal sampler replay: a rising sample must also advance Old. A one-bit captured **sample level** is sufficient together with the pre-triplet; it is historical input data, never a command to drive the physical pin.

**B — normalized:** store P⁺,C⁺,O⁺ from the equations above. After DIRSet has ended, apply them while CEN=0. Hold sampling through canonical T1 setup and replay of F(T) at T2; H(T) is already represented and is not executed again. GG remains held for both preparatory CPU enables because G(T) is already represented by its existing saved payload. Release normal sampling at the following logical host clock, T+1.

Why B matches A without changing the register convention: at accepted MC1/T2, H changes only P and O; F neither consumes P nor changes C, and F's special NMI fetch reads C, which H leaves unchanged. Therefore **F∘H = H∘F at this boundary**. H can be normalized into metadata before replaying F using A⁻. This is not valid at arbitrary instruction-end arbitration; SAVE's accepted fetch boundary is essential. G cannot be replayed here because its existing payload is already G⁺. This proof covers the reachable accepted fetch states; the matrix exercises ordinary, EI, HALT, DD-prefix exit, selected entry, pending, both flags and source transitions.

The prototype compares **every logical host clock**, not just final counters: all 230 architectural CPU bits, MCycle/TState/Prefix/IFF/pending/entry observations, Old, PC/SP, M1/MREQ/RD/WR/IORQ, address, meaningful read/write data, all 128 GG bits, all 32 IO bits, counter/progress/signature. Data on an inactive strobe is masked because stale DO/DI is not a guest bus transaction and is not serialized. After each suffix it compares all 8192 RAM bytes. Candidate T2 post-state matches the reference immediately after T, then all 6000 following logical host clocks match. Transport and two preparatory fetch enables are explicitly outside this logical-clock alignment. This is exact restart equivalence with documented fetch setup, not equality of wall-clock execution during LOAD.

## 10–14. GG, DIRSet, discriminator and repeated LOAD

GG is relevant. It is exercised through the real IO PC6 synchronizer, direction enable, source latch and handler OUT02 acknowledge, not by forcing gg_link_nmi_n. Offset−45 causes G(T) to assert the source after the accepted edge. Its normalized CPU tuple at T remains001: P0,C0,Old1; the saved GG source is asserted. During Q the source may be high or low. On restoring GG, its output can fall after DIRSet. Protected A samples the **historical high** at T2; protected B skips that historical sample. Both first sample the restored low on logical T+1 and reproduce the reference. A must not sample both historical n and the newly restored level as two samples of the same logical clock.

GG pipeline cases that have not yet asserted the source also pass. They require holding GG through both CPU-only fetch preparation enables. Advancing it in preparation would process G(T) again and shift the saved pipeline too far. Both pipeline and latched-source results are deterministic across all three Q histories.

Mandatory pulse-ended-before-LOAD: SMS input first falls for the accepted sample at T, returns high at T+1, remains high through Q/LOAD. Before T tuple001, after T100. Both A and B increment the guest counter exactly once after each restore, with identical PC/SP, stack and handler trace. The held-through-LOAD complement starts with the same normalized100 and keeps physical input low during DIRSet and replay; both execute exactly once, without a new edge caused by the held level.

Each candidate has three Q histories with different external assertions and different amounts of CPU execution before restore. Saved RAM, architectural state and GG/IO are restored independently of Q; sampler history is explicitly replaced after DIRSet. The same recorded future **external pin** sequence is then driven for all replays. This is controlled identical future stimulus; it does not rewind an uncontrolled live host or peer. Raw physical levels are never forced by applying candidate metadata. Current levels during LOAD can differ from the historical T sample (especially in the pulse-ended case).

Assertions verify that DIRSet clears both flags; the replacement occurs only after DIRSet is low; CEN is zero during state injection; preparation starts at MC1/T1, then MC1/T2; no stack/handler write or counter increment occurs during preparation. Preparatory enables are spaced at the normal 15-host-clock CPU period, retaining bus-read setup time. Both candidates then match the reference's selected entry at precisely the corresponding semantic point, with no premature vector/handler activity.

Three deliberate negative controls fail at the first comparison, as intended:

- `missing_capture_sample`: A with just pre-triplet and no historical replay loses the short pulse.
- `gg_sample_too_early`: B with the sampler enabled during historical T2 sees the newly restored GG low one logical clock too early.
- `gg_advanced_twice`: unfreezing GG during CPU fetch setup advances its saved pipeline again.

These failures are retained as expected results; they are not passing equivalence runs.

## 15–19. Minimal state and canonical selection

Select **B**. Both candidates are valid with the exact ordering above. A is not rejected as incorrect; it is not selected because its literal pre-state representation needs a fourth historical sample bit. B is the exact normalized result of that substep, retaining the existing architectural CPU boundary with three bits. This preference follows equivalence, the established mixed component boundary and smaller state, rather than simply easier RTL.

The selected fields are P⁺,C⁺,O⁺, one bit each. Pending and selected entry are independent and can coexist. Normalized Old also remains indispensable: `old_needed_held` and `old_needed_released` have identical architectural CPU captures, P0/C0 and the same future low input. Only normalized Old differs (000 versus001). The reference and both restored candidates produce counter1 versus2, respectively. Old cannot be heuristically derived from current LOAD level or from pending/entry. The point of normalization is to encode the **sample already taken**, not to discard edge history.

Thus **three bits suffice; no fourth sampled-event/input bit is needed for B**. No per-snapshot “sample occurred” marker is needed: every accepted v12 capture uses this convention. A fixed restore replay phase is still required to suppress double sampling; that is operation control, not another bit belonging to saved T. Raw current host/peer input is not serialized or restored. O⁺ is the historical internal sampled level, even though its normalized value numerically equals nᵀ.

## 20–22. Exact implementation contract and proposed v12

**SAVE captures:** the existing `z80_reg=A⁻` at the actual accepted edge, plus `(P− OR (O− AND NOT nᵀ), C−, nᵀ)`. Use stable pre-edge state and effective input atomically on that same edge; do not read a later Q-contaminated sampler value or rely on ordering between separate sequential processes. Keep existing post-T GG/IO capture. No change to legitimate acceptance conditions is required.

**LOAD restores:** architectural A⁻ and local GG/IO post-T state while all guest progression is held. Replace P/C/Old with the saved normalized triplet after the last architectural DIRSet edge. Q's flags and Old are discarded, not preserved.

**DIRSet ordering is:** establish sampler hold and global peripheral freeze → architectural DIRSet and GG set together → let GG output settle → deassert DIRSet → apply saved normalized triplet with CEN0 → canonical CPU-only T1 bus setup → canonical CPU-only T2/F(T) replay. Keep the edge sampler and GG protocol frozen through both preparatory enables. Do not assert a later DIRSet that would clear the restored triplet. Separate T1/T2 by the normal CPU-enable interval; do not compress real memory access setup time.

Fetch preparation must occur only after restore transfers have drained and the normal CPU memory-read path is available. The required sampler/GG hold is a logical restore guard, not a requirement to leave a savestate-owned memory mux selected during CPU fetch. Return memory-read ownership before T1 while retaining those logical guards through T2. The fixture uses ROM/WRAM models and does not validate the physical SDRAM handoff; production implementation must wire the guards independently as necessary and verify that handoff with the full integration regressions. This does not change the defined sampler/fetch ordering.

**First normal CPU enable sees:** T1 setup sees saved C/P/O and cannot arbitrate NMI; the subsequent historical T2 sees those same normalized bits, replays F(T), and does not sample input or advance GG again. At that post-T2 state the machine matches reference T⁺. Normal host-clock sampling resumes on logical T+1. The next ordinary CPU progression enable is at the reference's normal interval after T, not an extra instruction advance. If a different implementation folds setup or normalization into DIRSet, it must preserve these exact state/clock semantics and pass the same trace comparison.

**External NMI level is treated as:** a current input during the future suffix. It is never driven from saved metadata. Local GG source state is historical emulated state and is restored; a resulting low is sampled at the correct future logical clock, after the historical capture sample has already been accounted for.

**Capture-edge pulse is represented as:** pending1 and sampled Old0 in the normalized record, with C preserved. It is represented even if physical input is now high at LOAD.

Proposed v12 payload (proposal only): CPU DDR word/address **0x005**, retaining original architectural bits [37:0]; bit40=P⁺, bit39=C⁺, bit38=O⁺; bits[63:41] reserved zero (23 bits). Total meaningful word width41, of which exactly3 are new NMI history. No new DDR word or change to the meaning of existing CPU register bits. Identify the convention with the next versioned video extension tag **0x48430C**, subtype3 in the existing tag/subtype locations. Keep all v1–v11 payload locations and prior extension meanings, including the F15 Evolution descriptor. The future reader must recognize v12 as inheriting those earlier extensions, require the declared v12 tag/subtype and zero padding, and fail malformed v12 before applying guest state. Do not read arbitrary legacy padding as metadata. Old-reader behavior needs an implementation compatibility test; no assertion is made that an existing old reader rejects every future tag.

Proposed deterministic legacy normalization: for untagged/v1–v11, pending0/entry0; after restoring and settling GG, set Old to the settled current NMI input, then preserve that normalization through canonical fetch setup. Do not replay an imaginary capture sample. This intentionally cannot recover missing legacy events and must be documented. A later genuine falling input is processed normally. Malformed v12 is rejected, not silently treated as valid three-bit history or as an invented pending interrupt. Valid v12 uses the saved triplet exactly; it must not normalize Old from Q/current level.

The implementation contract is now specific: choose B's normalized values, hold sampler/GG through historical fetch replay, and resume at T+1. No choice between raw pre-state and normalized state remains for the subsequent F16 implementation task. This report authorizes no production edit by itself.

## 23–28. Counts, regressions and hygiene

**55 timing/input/program conditions × 2 candidates = 110 runs.** Each records its own uninterrupted reference, then performs three restores with different Q histories: **330 prototype LOAD/replays**, **1,980,330 exact logical-host-clock comparisons**, and **2,703,360 final RAM-byte comparisons**. The matrix covers all truth-table classes, fresh edges at/before/after capture, release at capture, held source, pending+entry, DI/EI/HALT/DD phases, GG source assertion at T delta, GG pipelines, and additional future edges. `cases.json` enumerates the conditions; `results.json` records actual accepted cycles, before/after tuple, PC-bearing full CPU words and every replay's result. This is a focused semantic matrix, not a repeat of the prior 314-case defect investigation.

The strongest unchanged established F16 pending, DIRSet-causal, capture-edge pulse and GG-entry tests were rerun: four actual production SAVE/LOAD runs, 12 LOADs, retaining their expected pre-fix divergence. `established/` contains their adapters/logs. No new claim of a fixed production LOAD is made.

All **21 existing regressions** pass: the prior 19 CPU/F12–F15 selections, plus GG direct and GG DDR integration. `regress.out` and `established.out` retain the runner summaries; individual compile/runtime logs are in `regression/`. No prior evidence folder's tests/logs were overwritten. F06 remains unresolved.

`analyze.js` asserts every candidate pass, all three repeated counters/signatures, candidate-pair agreement, the independent normalized-Old case, all negative-control failures, runner counts and repository identity. `results.json` includes baseline/current SHA256 checks for all 74 tracked SMS/RTL files (LF normalization for text), plus prototype source hashes. `repository_status.txt` records:

```
branch: fix/savestate-cpu-nmi
HEAD: d1df590 (full hash recorded in results)
git diff --stat: empty
git diff --cached --stat: empty
git status --short:
?? tests/
```

Production RTL, architectural register definition and the v11 format are unchanged. Only tests/reports were added, plus a link from the original investigation report. No branch creation, Quartus invocation, staging, commit, push or PR. Temporary simulation libraries and waveforms are removed after validation; canonical logs, adapters and expected-failure evidence remain.

Final prerequisite status: **F16 IMPLEMENTATION UNBLOCKED**. The capture-edge representation and exact GG/DIRSet/fetch-replay ordering are specified and checked against uninterrupted execution. F16 itself remains **CONFIRMED - FIX REQUIRED**; no production fix has been implemented.
