# F15 Evolution pending-operation investigation

**CONFIRMED - FIX REQUIRED.** Investigation only, based on committed F14 `ff9d66b`, branch `investigate/savestate-evolution-pending`. Production RTL and format v10 have zero diff. F06 remains unresolved; F16 is untouched. No fix, FPGA build, staging, commit, push or PR was performed.

The production T80 reaches SAVE acceptance with `switch_armed=1`. SAVE alone preserves its next switch and guest read `$28`; LOAD clears the armed flag, so the same guest reads `$00`. Correct F14 restoration does not recover this protocol phase. Additional directed production-module tests expose lost menu-record reads and lost launch bank resets.

Evidence index: [accepted-boundary tables](boundaries.md), [machine-readable results and source hashes](results.json), [reproduction and limitations](README.md). Final evidence includes45 passing canonical simulation logs, 225,501 directed SAVE-only clock comparisons, 78 matching uninterrupted/SAVE-only real-CPU enable samples, and exact254-bit first-versus-repeated LOAD trajectories. The45 logs comprise24 investigation runs and21 unchanged regression runs.

## 1. Complete state inventory

Sources: [Evolution mapper](../../rtl/evolution_mapper.vhd), [address decoder](../../rtl/evolution_rom_address.vhd), [bank controller](../../rtl/mapper_ctrl.vhd), [system wiring](../../rtl/system.vhd), [savestate controller](../../rtl/savestates.sv). The [original audit](../savestate_coverage/review.md), [F14 investigation](../savestate_evolution_selector/review.md) and [committed F14 fix report](../savestate_evolution_selector_fix/review.md) were read first. Their historical reports are retained unchanged.

All listed registers reset to zero except `old_m1_n=1`. Normal updates require `enable=1` on **every rising host clock**, not CPU CE. Reset has priority, then valid Evolution `ss_set`, then ordinary operation. `game_launch_r` clears unconditionally every clock. `mapper_set` reaches Evolution through `evolution_set`; ownership must be E132. No Evolution process has an `ss_freeze` input.

| RTL state | Bits | Update, lifetime and future effect | v10 / restore / owner |
|---|---:|---|---|
| `bank61_r`, `bank62_r` | 8 each | OUT61/62 while IORQ=0, WR=0; persist until another write. Current ports feed later committed selection. | Exact low96 [15:8]/[7:0]; bank61 also mapper low8. Existing architectural latches. |
| `candidate_bank61_r`, `candidate_bank62_r` | 8 each | OUT62 changes candidate when `{bank61,data}` differs; persists across arbitrary instruction fetches. | F14 candidate61 in extension; candidate62 equals saved port62 by reset/write invariant. Exact F14 restoration. |
| `prior_candidate_bank61_r/62_r` | 8 each | Candidate change retains prior candidate; later game commit copies it to previous game. | Exact F14, extension [151:136]. |
| `game_bank61_r/62_r` | 8 each | Recognized game command commits on second falling M1; copies current ports; drives Flash decoder. | Exact F14 [111:96]. |
| `prev_game_bank61_r/62_r` | 8 each | Same commit copies prior candidate; fallback Flash decoder uses history. | Exact F14 [127:112]. |
| `reg3ffe_r` | 8 | Recognized pending command commits at second falling M1. Mode85 is menu, 87/97/C7 game. Unknown commands leave it unchanged. | Exact existing mapper [15:8]. |
| `reg3ffe_pending` | 8 | Every WR=0/MREQ=0 at A=3FFE overwrites command. **Retains its last value after completion**; value is not a validity flag. | Exact old96 [95:88]. Existing command, F15 phase consumer. |
| `switch_pending` | 1 | Every initiating write sets1 and clears armed; first later falling M1 clears pending and sets armed. A newer write restarts it. | Omitted; LOAD clears0. F15, future-relevant before first fetch, but not retained at accepted ordinary T80 capture. |
| `switch_armed` | 1 | First falling M1 after write sets1; next falling M1 executes recognized command and clears it. Unknown command also consumes armed. | **Omitted; LOAD clears0. F15, accepted and future-relevant.** |
| `old_m1_n` | 1 | Samples current M1 each enabled host clock; detects its falling edge. Frozen bus can still update this sampler. | Not serialized; LOAD samples current bus. Edge history, reconstructable at the tested accepted bus boundary; see section3. |
| `game_started` | 1 | First recognized game launch sets1; only reset clears it. Gates first-launch pulse with menu arm. | Exact F14 [152]. No longer inferred from active mode. |
| `game_launch_r` | 1 | Recognized game commit pulses when started=0 or menu arm=1; unconditionally clears next host clock. Bank controller consumes pulse on following clock and resets banks00/01/02/03. | Not serialized; unconditional clear on restore clock. Transient output, already consumed before the accepted ordinary T80 fetch CE. |
| `launch_fetch_addr_r` | 16 | First non-M1 memory read after recognized menu fetch captures CPU address. Persists after launch. Decoder record overrides fallback selectors. | Exact existing mapper [63:48]. Persistent address belongs to existing/F14 context; outstanding recognition is F15. |
| `record_read_pending_r` | 1 | Falling M1 at1380 when old active mode is not87/97/C7 sets1. Next MREQ=0, M1=1, RD=0 captures address, clears flag and sets menu arm. Refresh is excluded by RD. No timeout; can persist through fetches. | **Omitted; LOAD clears0. F15, accepted and future-relevant.** |
| `menu_launch_armed_r` | 1 | Completed recognized record read sets1; later recognized game commit consumes it and requests bank reset even when started=1. Menu85, unknown commands, ordinary fetches do not clear it. | **Omitted; LOAD clears0. F15, accepted and future-relevant.** |
| `reg8c_r`, `regcd_r`, `reg63_r`, `reg88_r`, `reg8d_r`, `reg8e_r`, `reg8f_r` | 7 × 8 | Corresponding I/O writes; persist until overwritten. Existing menu configuration, independent of delayed phase. | Exact old96 [87:32], restored on ss_set. Existing state, not newly found F15. |
| `mapper_ctrl.bank0/1/2/3` | 4 × 8 | Guest FFFC–FFFF banking, Evolution launch reset, and mapper restore. Restore has priority over launch. | Existing mapper [47:16] in Evolution layout. F15 can **lose a future reset**, despite restoring these latches correctly at T. |

Evolution itself contains175 register bits; the last row is its external bank consumer. Detection history is separate F13 state, not an Evolution phase bit. ROM decoder combinational aliases/tables have no persistent protocol state. Mapper enable comes from explicit Evolution force or exact supported ROM CRC detection, with manual-mapper precedence; it is held fixed throughout these witnesses. BIOS visibility does not independently gate the Evolution process: its CPU-bus observation uses the same enable in menu and game paths.

## 2. Actual protocol

Switch sequence is **write-pending → armed → commit**, rather than interpreting command bits as phase:

1. WR=0, MREQ=0, A=3FFE latches D, sets pending1, armed0. A held write repeats this assignment on every host clock.
2. After release, the first `old_m1_n=1 && m1_n=0` consumes pending and sets armed. The jump opcode is still fetched through the originating view.
3. The next falling M1 consumes armed. Commands85/87/97/C7 update active mode; game commands copy selectors/history and optionally pulse launch. Unknown command leaves view/history unchanged but consumes the phase.
4. Pending command byte remains stale after commit. A new3FFE write cancels/replaces an earlier phase. Reset or LOAD clears both phase flags.

The record/launch sequence is orthogonal: menu-context fetch1380 sets read-pending; the following qualifying **data read** records its address and arms launch. That arm can persist through an arbitrary number of instructions and menu switches. A game commit consumes it, enabling the bank reset even when a game was already started. The 1380 test uses the pre-edge active mode, so it can coincide with a delayed switch transition. The subsequent data-read branch uses pre-edge pending state. Sequential assignment priority also allows the later initiating-write branch to restart switch state.

There is no instruction decoder requiring an actual JP or LD A,(DE), no CPU CE condition in Evolution, and no bounded timeout for either recognition or menu arm. Real guest behavior supplies these customary instructions; arbitrary legal guest programs can leave the flags alive much longer.

## 3. Savestate acceptance overlay

Production ST_WAIT_BOUNDARY accepts only `!storage_busy && cpu_ce && !M1 && !MREQ && ISet==00 && vblank && x<256`. CPU architecture is captured on that edge; ARM one host clock later captures Evolution160 and asserts freeze. After32 quiet clocks the mapper word and F13 history refresh together. Restore publishes mapper/Evolution before CPU DIR restore. These stages are exercised without forcing FSM state or guest registers. Only existing host UI operation cooldown is bypassed.

| Stage | Classification | Reason |
|---|---|---|
| Before initiating write / idle | A | Ordinary opcode fetch is accepted. Real T80 pre-init control resumes correctly. |
| Held3FFE write / `switch_pending=1` before first falling M1 | B | M1=1, so request waits. First following M1 consumes pending before the qualifying MREQ-low CPU CE. |
| First-fetch armed | **A** | Armed survives the accepted M1/MREQ-low fetch and the entire SAVE freeze. Real T80 witness confirms it. |
| Between fetches, before second/commit M1 | B | Request can occur, but acceptance needs an opcode fetch; it either catches the still-held first fetch or reaches the committed second fetch. |
| Second-fetch commit and completed idle | A for completed state | Falling M1 commits before the qualifying held-fetch CE; launch pulse has also been consumed by banks. Exact pulse-at-accept state is C for this ordinary production CE sequence. |
| Read-pending after menu fetch1380 | **A** | Accepted M1-low fetch precedes its non-M1 data read. |
| Data-read completion itself | B | M1=1 prevents acceptance; menu arm may remain until a subsequent accepted fetch. |
| Menu-launch-armed | **A** | Can persist indefinitely; accepted at an unrelated normal fetch. |
| Combined armed/read/menu flags | **A** | Directed bus sequences exercise every nonzero combination of these three independent flags. |

At ordinary15-clock or turbo10-clock CPU CE spacing, a new T80 falling M1 is sampled by Evolution before a later CE can satisfy MREQ-low acceptance. `old_m1_n=0` therefore agrees with the current accepted bus; it is not an extra independent saved bit at these captures. M1 can rise during the post-accept CPU tick; ARM/freeze lets its edge sampler settle without creating another falling M1. No new protocol transition was observed during SAVE. This reasoning depends on the production CE/bus sequence, not merely the controller Boolean condition with arbitrarily driven illegal bus combinations.

## 4–9. Boundary sweep and confirmed effects

Machine-readable [results.json](results.json) retains request and accepted cycles, protocol bits, bus controls, CPU architecture and complete Evolution/mapper payload for **13 real T80 SAVE timings**. Offsets are host clocks relative to first observation of the guest write. The pre-init control requests at opcode000A. Offsets0,1,14,29,30 capture armed at cycle657511 / A000D. Offsets44,45,59,74,89,149,209 are accepted after commit; offset44 misses the first available boundary because request processing is too late. These are actual controller acceptances, not forced capture strobes. The logs distinguish the trigger observation (`REQUEST`) from the exact raised input pulse (`OP_REQUEST`).

The strongest real T80 case uses guest OUT61=00, OUT62=28, LD A,87, LD(3FFE),A, JP0020, then LD A,(8123)/OUT20 loop. Instructions are mirrored across Flash pages; the non-instruction byte at8123 returns the physical high byte. Before and after SAVE-only: Flash288123, DI28. After each of three LOADs: Flash008123, DI00. The accepted state has pending command87, pending0, **armed1**, read0, menu0, started0, active mode00, active game0000, ports0028, oldM1=0, launch0. T80 acceptance is cycle657511, M1/MREQ/RD=0, WR=1, ISet00, VBlank and x<256.

Saved representation is mapper `0000000102030000`; Evolution160 `00000000000000008700000000000000E1320028`; F14 word02C=0; word02D=`0000003945563130`. Thus the pending command is present while its valid/armed phase is absent. CPU words are retained verbatim in the log/results; unused uninitialized T80 GPRs appear as X, just as in the established F14 fixture. The asserted bus, instructions, command, selectors, address and guest data are all known. This is a synthetic production-T80/data-path witness, not a commercial ROM or rendered-frame claim.

| Directed case | Accepted flags armed/read/menu | Accepted A / cycle | Saved mapper / F14 word02C | Reference CPU8123 | LOAD CPU8123 |
|---|---|---|---|---|---|
| 0 switch | 100 | 0100 /121 | `0000000102030000` / `0000000000000000` | 288123 /28 | 008123 /00 |
| 1 record read | 010 | 1380 /376 | `0000000102038500` / `0124000000002400` | 288123 /28 | 488123 /48 |
| 2 menu launch | 001 | 1400 /481 | `20A8000108038500` / `0124000000002400` | 288123 /28 | 2A0123 /2A |

Cases5–8 extend this to110,101,011,111. Case9 commits game87 on the same falling M1 at1380 that recognizes a record using the old menu85 mode: capture is already in the **game view** with read-pending1. Its next data read must change record0 to20A8; reference resumes at288123/28 while LOAD reads488123/48. Thus vulnerability is not confined to captures whose active mode is menu. Exact cycles/payloads and per-clock first divergences are in the corresponding logs and results. The debug-phase order is `{switch_pending,switch_armed,record_read_pending,menu_launch_armed,old_m1_n,game_launch}`.

**First internal divergence:** on the Evolution restore clock, an accepted nonzero protocol flag is cleared while all exported160 bits and mapper64 match the saved input exactly. Future S then consumes the reference flag that LOAD lost. Each directed suffix records every host-clock state and compares all254 observed bits: Evolution160, mapper64, Flash24, protocol6. First state mismatch is suffix sample0. For cases0/1/2 the first Flash mismatch is sample4/113/113 respectively. The earliest case0 differing fetch is reference280200 versus loaded000200; the subsequent explicit data probe is288123 versus008123. Case1 first differs at280200 versus480200 after the recorded-address loss takes effect. Case2 first differs at the final data probe after the missing launch pulse fails to reset bank2 from08 to02. These are used differences, not dead state overwritten before consumption.

## 10–11. Non-injectivity and reconstruction

Separate actual SAVE operations in cases3/4 produce **identical complete initialized 12,288-word DDR images**, including framework header, CPU input, all old extensions and F14 payload. Their mapper/F14/record fields are identical, but menu arm differs. Under identical S, production Evolution plus bank control yields288123 versus2A0123. [pairA.mem](pairA.mem) and [pairB.mem](pairB.mem) retain those images. The reference uses an already captured20A8 record and completed launch to clear arm; the other repeats the same recognized record read, leaving every exported field unchanged and rearming launch. Both set bank2=08 before T.

**Scope limitation:** this is a strict full-byte collision for the controller/production-mapper harness, whose architectural CPU input is a constant zero vector. It is **not** a demonstrated pair of fully reachable real T80 architectural snapshots. The strongest real-T80 result is the actual save/load divergence above. No claim that all230 CPU bits and every peripheral phase have been made identical by two executable guest histories is made. That additional pair would strengthen the information-theoretic lower-bound proof; it is not needed to establish the reproduced LOAD defect.

Pending command alone cannot identify phase: it remains after completion and is identical in the projection pair. Saved active selectors, started, candidate/previous history and launch record likewise do not encode menu arm. Current bus is an ordinary unrelated fetch in both pair members. Read-pending cannot be inferred just from A1380, since it depends on an earlier falling edge and pre-edge mode, and may persist beyond that instruction. No strict all-reachable reconstruction rule from the complete v10+CPU state has been proven. **Heuristic reconstruction is not an approved fix.** The evidence supports preserving the three independently accepted flags directly; a future design choosing reconstruction would first need to close the full-CPU proof gap explicitly.

## 12–14. SAVE-only, repeated LOAD and Q

An independent uninterrupted real-T80 run and armed SAVE-only run have **78 identical CPU-enable samples**, comparing bus controls, complete available architecture, protocol flags, Evolution160, mapper64, Flash address and byte. Wall-clock transport duration is excluded by comparing actual executing CPU enables. Directed tests compare every host clock through SAVE and through S, including banks and launch pulses, against a bus-driven reference. The combined cases additionally cover all nonzero accepted flag combinations. SAVE does not cancel, advance or duplicate these operations in the exercised captures. The mapper's lack of freeze is therefore relevant but is not the reproduced root cause.

Every vulnerable directed state is restored five times after Q that: (0) allows completion; (1) initiates another command97; (2) executes menu85/unrelated record read2100; (3) changes selector9440, port8C and commandC7; (4) returns to menu idle. Each LOAD restores exact F14/mapper state, then produces the same wrong S trajectory for that state. Every254-bit sample of LOADs2–5 must also match the recorded first-LOAD trajectory, not just its final probe. Per-clock reference comparisons identify the same first mismatches. The real T80 armed case also repeats LOAD three times after distinct dwell lengths. Current restore **clears deterministically**; it does not retain Q's flags. Repeatedly wrong behavior is not evidence of correctness.

Totals excluding existing regressions: **23 accepted SAVEs and55 LOADs**, comprising13 real-CPU SAVE timings with15 LOADs, eight vulnerable directed prefixes with40 LOADs, and two independent pair SAVEs. The uninterrupted CPU reference is a separate run with no SAVE. The eight directed prefixes cover all seven nonzero phase combinations plus the distinct game-view record transition. The two pair runs cover additional accepted menu-arm/idle projections.

## 15–17. F14, F13 and execution contexts

The restore-edge assertions compare Evolution output against the complete v10 input and mapper output against its saved word before S. F14's57 bits, including game_started and candidate reconstruction, are correct. Case2 restores bank2=08 correctly at T, then loses its **future** reset. These are F15 protocol omissions, not persistent F14 selector omissions.

The isolated Evolution witness supplies stable valid F13 history0FFFF and does not feed that history into the Evolution state machine; no F13 state can reconstruct the missing flags. The unchanged F13 detector/history and restore-edge suppression regressions pass separately, as does Evolution bank restore priority. This is not a new full-system CRC-download/detector/T80 integration test. Evolution enable/media remain fixed, the same precondition as F14. No mapper detector or F13 code is modified.

Initial/menu launch is exercised by real T80 case0. Already-started menu return85, record fetch1380, subsequent launch and workspace-bank reset are covered by directed cases1/2 and combined cases. Game-context command writes use the same delayed path; the perturbation matrix includes87/97/C7 and menu85 transitions. Record recognition is intentionally excluded while the old active mode is87/97/C7. Existing BIOS handoff, frozen handoff, mapper restore and address/history tests pass. Commercial Evolution dumps, pixel behavior and a complete BIOS boot were not run; only production-supported bus paths are claimed.

## 18–22. Candidate architecture and legacy policy — analysis only

**Do not implement a fix from this report without the separate implementation task.**

The smallest demonstrated capture-relevant state is **three bits**: switch_armed, record_read_pending and menu_launch_armed. Their seven nonzero combinations are exercised; idle000 is a passing control. switch_pending has drained to0 before naturally accepted T80 capture, oldM1 is fixed by the coherent fetch bus, and a launch pulse is consumed before that CE. A future implementation must preserve these invariants and sampling order, rather than blindly snapshotting every declaration. Keeping the full live mutually exclusive switch phase would require two phase bits instead of one, plus record/menu =4 logical bits; that is a conservative general-phase option, not established minimum for current acceptance.

**Acceptance deferral is not proven viable as a complete F15 fix.** Menu arm can persist indefinitely while a guest executes ordinary NOP/JP code without launching a game. Read-pending can likewise persist if no qualifying non-M1 data read occurs. Waiting for either to clear can deadlock SAVE. No CPU/host progress override can force the guest to issue a command it never issues without altering guest semantics. Deferring just the two-fetch switch window might be bounded under additional CPU-running/no-WAIT/no-bus-grant conditions, but those conditions and pause handling need proof; it also leaves the record/menu defects. No unconditional bounded/nondeadlocking deferral is recommended. Forcing completion or clearing flags during SAVE would change the saved machine.

Restore ordering alone cannot recreate erased phase. Recommended candidate is explicit capture/restore of the three accepted flags using the existing mapper-before-CPU application point, with assertions/tests for old-M1 handling and pulse ordering. The existing command byte and F14 history remain authoritative. This recommendation does not assert that a full-CPU non-injectivity proof has been completed; reconstruction has no proven all-reachable alternative here.

**Format analysis:** v10 readers require all word02C padding[63:57]=0 and exact57-bit descriptor02D, so silently putting flags there under v10 is invalid. Existing160-bit transport has seven zero bits [159:153]; three flags would fit within it. A possible future layout would extend02C from57 to60 meaningful bits, use its existing padding bits57–59, keep63–60 zero, update descriptor width/owner and version tag. This uses **zero additional DDR words**, no slot-size change; free02E/02F also exist if a separate validated payload is preferred. Such changed meaning requires a new version, naturally v11, and strict owner/width/padding validation. **No v11 is required merely to investigate; current v10 is unchanged.** A proven alternative using only existing information could keep v10, but none is established. Exact encoding/legacy policy belongs to the separately authorized fix.

For snapshots lacking phase, command85/87/97/C7 does not prove an operation is outstanding. Normalizing all flags to idle is deterministic and avoids inventing a launch, but the confirmed cases show it is not an exact restore. Safest exactness policy for a future state-adding format is rejecting unsupported Evolution v10 snapshots before architectural/peripheral/memory restore, unless a narrowly proven saved-state subset is independently established. Non-Evolution compatibility should remain as before. No broad menu/game exception or heuristic command reconstruction is justified. No legacy behavior is changed in this investigation.

## 23–30. Regressions, limits and repository hygiene

**21 unchanged regression logs pass:** fifteen F14 selector cases; F14 real T80 before28/restored28 with current host turbo; Evolution history/address matrix; F13 detection-history cases0/6; production mapper directed banking/BIOS/SystemE priority tests; F12 paused SystemE actual CPU/PSG test (2,552,454 comparisons). Existing F14 sources are copied into this investigation and run against committed current production, preserving old evidence/logs. The banking adapter retains the established VHDL missing-`others` compatibility additions and historical directed-only scope; no new random-oracle claim is made.

Observation adapter changes only an output port and combinational assignments exposing six internal flags; stripping those additions must reproduce the production Evolution source byte for byte. Controller adapter only moves two existing declarations for ModelSim compatibility. Bank-controller adapter is the existing F13/F14 one, adding no binary-input behavior. Missing-unused-output warnings and two time-zero T80 unknown-GPR warnings are retained in logs. Initial harness development failures are described in README; only final passing logs supply conclusions.

F06 remains unresolved. F16 remains untouched. Production RTL and v10 format have zero tracked diff; nothing is staged. No generated Quartus artifacts were created. Generated ModelSim libraries, waves, transcripts and temporary runner files are removed after validation. Retained files are source adapters, drivers, initialized pair images, logs, reports and JSON evidence.

`git diff --stat`: empty.

`git diff --cached --stat`: empty.

`git status --short`:

```text
?? tests/
```

The untracked tests directory predates this investigation; only `tests/savestate_evolution_pending` is added here. No commit, push or PR was created.

**Final classification: CONFIRMED - FIX REQUIRED.** An actually accepted production-T80 armed state loses its pending commit and changes a known guest byte after LOAD, while SAVE-only matches uninterrupted CPU execution. Additional accepted record/menu states lose address or launch-reset behavior despite exact F14 restoration. Full-T80 non-injectivity and an exhaustive whole-system proof remain explicit limits; neither turns this reproduced defect into an exclusion.
