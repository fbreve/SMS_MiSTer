# G11 ROM/decryption savestate investigation

**G11: CLOSED - PROVEN RECONSTRUCTABLE. No production change.**

## 1. Current committed HEAD

cb2e8615128d61adb996ada68e6bbdcc314c20f6. Branch: investigate/savestate-g11-decryption.

## 2. v16 baseline

Current production rtl/savestates.sv retains tag484310, the v16 AudioMix record, v15 background records and v14 restart/sprite records. No format field was added, removed or reinterpreted.

## 3. G12 boundary/oracle

Used [the G12 post-fix oracle](../savestate_g12_sdram_fix/g11_input_oracle.md). G12 ends at ram_dout/system.rom_do with restored logical address and M1, before selected decryption. Physical SDRAM responses are owned by accepted requests; private reissue must have exactly one acceptance and return before consuming T2. A raw mismatch is classified upstream of G11. No such contradiction occurred.

## 4. Complete ROM/decryption architecture

See [complete architecture and surrounding state](architecture.md). CPU A/M1/MREQ/RD → mapper/decode → fixed media geometry/header transform → live SDRAM raw byte → BIOS/cart/decrypt selection → memory/IO selection → combinational Game Genie replacement → T80 DI/DInst and DI_Reg. The fixture uses the current G12-fixed private/native memory-reference selector.

## 5. Active decryption modes

00: raw/Janggun combinational reversal. 01: MC8123 below8000. 10: Sega2 below8000. 11: MC8123 where A15=0 OR A14=0 (including8000–BFFF; WRAM wins downstream). BIOS/disabled-cartridge selections have priority. Current production instantiates DECT2 directly; DECT1 and the wrapper detector counters are inactive. Mode/key/table/ROM/BIOS/cheat configuration remains the same external session in each comparison.

## 6. Sequential-state inventory

[architecture.md](architecture.md) inventories the active21 MC pipeline bits (key-address stage13 and output8), Sega41 physical pipeline bits (madr16, phase1, output8, two table outputs8 each), immutable memories, function scratch, BIOS read stages, code-loader state, media geometry and the G12/CPU/restart surroundings. Nine madr bits and three swap-output bits have no architectural consumer. No hidden previous-byte feedback, queue, request-valid or output-feedback state exists in either active decryptor.

## 7. State classifications

CPU architecture/context, mapper and guest media controls: SERIALIZED by existing contracts. MC key stage and both registered decrypt results; Sega relevant madr/table stages: OVERWRITTEN BEFORE OBSERVATION / DETERMINISTICALLY RECONSTRUCTED. Immutable downloaded media/configuration and inactive DECT1/wrapper: BOUNDARY-EXCLUDED. Function scratch and unused bit fields: architecturally irrelevant. Sega phase remains physically free-running; its two values are architecturally irrelevant at admitted consumers (the explicit Phase23 closure category), not unreachable or historically restored. No UNKNOWN or independent guest-FUTURE-RELEVANT child remains.

## 8. Exact dependency graph

MC: logical A/opcode → synchronous key address/data → complemented key/type/swap/parameters + current raw byte → registered d. Sega: phase-zero captures logical A14:0/opcode → seven-bit index → synchronous XOR/swap table outputs; phase-one registers bswp(current raw, swap[4:0]) XOR xor. Neither uses the preceding decrypted/raw byte. Bounds: MC address/key2 edges, raw-only1; Sega address/table/result5 edges, raw-only2. See [ordering proof](ordering.md).

## 9. Real encrypted-ROM fixture

[fixture.md](fixture.md) documents real T80, actual production decrypt modules, actual spram/vendor key memory and DLROM tables, actual mapper/decode and live SDRAM with physical CAS2 model. Keys/tables enter through write ports. Three deterministic encrypted programs exercise initialization, prefix/immediate/ROM-data accesses, bank writes, CALL/RET, EI/HALT and NMI/RETN. Other peripheral endpoints retain the documented targeted G12 models; this is not a full-board emulation run.

## 10. Uninterrupted baseline

Canonical encrypted runs keep both CPUs in production Z80 Mode0, enforced by assertions. The independent golden CPU uses current address/opcode/raw media without decrypt history. Uninterrupted reference files pass known-bit checks; DUT consumed-byte assertions also run during pre-capture execution. A startup trace confirms the intended plaintext instructions and initialized alternate/index registers. All final compared suffixes and complete images are known.

## 11. Accepted SAVE-boundary sweep

The saved clock-phase encodings cover 0, 1, 2, 3 (0/10/20/25), both decrypt phases, all six predecessor classes, running-consumed T2 and paused-unconsumed T2. Actual acceptance requires CPU enable, M1/MREQ, ISet00, permitted VBlank/window and idle storage. Before-request, request-issued, raw-pending and unfinished-decrypt points are not independent accepted states: the T1/T2 guard excludes them. Their clock-by-clock reconstruction is observed around actual accepted captures/restarts; no fabricated mid-pipeline capture is counted.

| Saved class | Accepted PC | First restored physical ROM address |
|---|---|---|
| 0 | 013a | 000013a |
| 1 | 010b | 000010b |
| 2 | 010d | 000010d |
| 3 | 010f | 000010f |
| 4 | 0113 | 0000113 |
| 5 | 0117 | 0000117 |

## 12. SAVE-only result

26 initial SAVE-only matrix continuations match uninterrupted reference, including the strengthened per-clock stream cases. The two resaved phase-collision states also have matching subsequent futures. Paused SAVE uses the existing bounded coherent capture-progress exception while retaining logical host Pause; it does not claim zero CPU progress from a non-M1 paused request.

## 13. LOAD result

54 actual LOADs pass across matrix and Pause groups. The12 strong matrix cases compare physical request/raw/decrypted consumer records every host clock, full architectural/bus state and all16,384 modeled WRAM bytes at each suffix end. Every private ROM restart is checked for exactly one fresh acceptance/return before T2. Supporting variants retain independent raw/decrypt assertions and six guest observer bytes.

## 14. Repeated LOAD

Representative images undergo Q1/Q2/Q3 → LOAD T → suffix, with the same complete image immutable across replays. The long prefix witness records materially different phase, madr, raw/result, key selection, CPU and mapper/execution history before the three LOADs. All three reconstructed futures agree; reset is not used as the perturbation.

## 15. Registered-result hazard

Paused accepted M1/T2 images retain a registered but unconsumed result. SAVE transport may recompute it; LOAD reconstructs it rather than preserving its historical register bits. In the paused-System-E witness, stale09 becomes correct32 at clock2678210, before T2 at2678212. The equal-image MC pair also has differing unselected outputs04/7D and identical guest futures. See [causal evidence](causal_evidence.md).

## 16. Address/madr hazard

Sequential and nonsequential code/data, CALL/RET, repeated HALT fetches, bank boundaries and unrelated pre-LOAD histories pass. At admitted active ROM fetches the prior T1 gives the relevant logical address/opcode time to reach madr/tables. Restored requests match the saved PC and the correct fixed/code physical address; [contexts_result.json](contexts_result.json) checks payload classes and restart traces directly. The seven causal madr bits are refilled before observation; the other nine feed only an unconnected rad output.

## 17. Phase/history hazard

Both phase values occur naturally. A legal15-clock transport delay produces accepted states with identical complete v16 image, CPU, raw byte, madr, table outputs and decrypt result but opposite phase. Their next24,000 clocks agree. Literal physical phase identity is false and is not claimed; the two schedules are observationally equivalent because every legal consumer occurs after the worst-case recovery bound. Phase needs no historical payload.

## 18. Opcode-fetch result

Real M1 fetches of ordinary opcodes and CB/ED/DD/FD prefix bytes pass. M1 is explicitly part of both cipher indices; it is not inferred from address alone. The CPU/bus oracle includes M1, and the consumer oracle checks the corresponding decrypted byte.

## 19. Operand/data-read result

Immediate bytes, absolute address operands, arbitrary ROM data and branch targets pass. Key/table selection uses current logical address and opcode/data distinction; physical-bank aliases do not replace that distinction. Six visible observer bytes are checked in supporting cases; the strong cases additionally check every modeled WRAM byte, including subroutine/NMI observer and stack writes.

## 20. Prefix/restart result

All six saved classes0–5 are verified from the actual v16 payload and restored-request traces; the strong matrix repeats each with explicit raw/decrypted streams. EI state and DD/FD register effects match. HALT exit after identical future NMI/RETN and three LOAD histories passes for both active decryptors. Non-M1 or nonzero-ISet capture is not admitted by production; no such state is forced into the image.

## 21. Mapper interaction result

Production mapper_ctrl/memory_decode are instantiated. Guest writes FFFE/FFFF and reads3FFD/3FFE/3FFF/7FFF/8000/8001 plus subroutine ROM data. Normal SMS tests change physical banks while decryption remains active; mode11 also covers encrypted upper-window data. Restored mapper state plus logical requests determines the same physical stream. This is targeted interaction sanity, not a new mapper-history audit.

## 22. Pause matrix result

| Cipher | Saved | Current at LOAD | Compared suffix | Result |
|---|---|---|---:|---|
| MC8123 | running | running | 24000 | PASS |
| MC8123 | running | paused | 24000 | PASS |
| MC8123 | paused | running | 24000 | PASS |
| MC8123 | paused | paused | 24000 | PASS |
| Sega2 | running | running | 24000 | PASS |
| Sega2 | running | paused | 24000 | PASS |
| Sega2 | paused | running | 12000 | PASS |
| Sega2 | paused | paused | 24000 | PASS |

All paths preserve the current logical host Pause through transport, then use real button/VBlank unpause when required. Saved consumption selects historical T2 versus deferred native T2. Private preparation is bounded and does not advance held PSG state.

## 23. Transport-duration result

Legal tail delays cover0,1,7,8,9,10,14,15,24,29; random DDRAM stalls and latency25 supplement the ordinary latency3 cases. One strong case uses the production900,000-clock flush rather than TB_FAST. Guest streams/suffixes are independent of transfer duration. Physical phase may differ, as intentionally isolated by the phase-only collision; consumer-visible state converges in time.

## 24. Perturbation strength

Q histories execute real guest instructions and legal mapper/PSG writes. Logs record different CPU state, retained ROM addresses/raw bytes, phase/madr, table/key selection and registered outputs before LOAD. The history-pair input is canonicalized at capture so physical future input levels are identical. Keys/tables and media stay fixed; there are no internal register deposits or forced accepted CPU/decrypt states.

## 25. Raw ROM address identity

The strong oracle compares the golden CPU’s physical mapped consumer addresses directly at every host clock. Private acceptance/return records and the saved-PC checker establish the first restored logical/physical request independently of decrypt output. G12’s response ownership ledger also checks the address used at each registered return.

## 26. Raw ROM data identity

Every registered physical response is checked against the accepted address, and every consuming ROM read checks raw data before checking decryption. Strong suffix records compare raw bytes to the independent uninterrupted reference. The paused witness explicitly replaces retained94 with returnedAF before decoded32 is consumed; stale-high ready alone is never accepted as freshness proof.

## 27. First decrypt divergence

No canonical guest-consumed decrypt divergence was found. Idle/transient pipeline outputs can differ before convergence; the causal trace records this without treating it as a guest failure. No apparent mismatch crossed the G12 raw boundary, so no G12 obligation is reopened.

## 28. Mandatory non-injective search

Two completed pairs have identical full12,288-word known images and different omitted state. MC pair: normalized SHA256f0c80d318b140c67d1f854040f83fad734d9f0d659611f33e07eed3bc37c3808, outputs04/7D, differing retained raw history while CPU executes RAM. Isolated Sega phase pair: SHA256e87ec2424a24a0cee66276b268a40ad39495224a6f4e850cc5e20ae4ab8410b2, phase1/0 with other named inputs/results equal. Both pairs have identical future files and passing SAVE/LOAD continuation. The MC pair’s differing upstream retained byte is not misreported as a G11 defect. See [collisions_result.json](collisions_result.json).

## 29. Long-suffix result

Compared 72 matrix suffixes, 2 additional post-resave futures and 8 Pause LOAD futures (1,920,000 host-clock samples). Suffix lengths are6,000/12,000/24,000/48,000 clocks; transient bytes are checked before they can be hidden by later architectural convergence.

## 30. G12 sanity

Current committed clock-reference expression, real physical controller/model, owned request/return ledger and exactly-once reconstructed reads pass. No physical address/raw byte divergence precedes decryption. G12 remains CLOSED - FIXED AND PROVEN.

## 31. G01 sanity

Production Z80 Mode0, six actual saved predecessor classes, known full-register/bus suffixes and HALT/NMI continuations pass. No CPU restart-context fix or re-audit was undertaken. G01 remains CLOSED - FIXED AND PROVEN.

## 32. Mapper sanity

Actual guest bank writes, existing mapper serialization and post-LOAD physical streams agree. Existing mapper-history closures are not reopened.

## 33. F12 sanity

The8 real Pause combinations pass their phase-retention and private-replay assertions. Current UI state survives LOAD, accepted capture can seek M1 coherently under the already authorized bounded-progress exception, and no transport-only beam edge introduces an extra toggle. F12 remains closed.

## 34. Simulation groups/cases

34 completed integrated fixture/case groups, including12 strong stream/full-WRAM variants;4 supporting groups (MC forward/inverse construction,8,192 Sega permutation cases,65,536 Sega recovery cases,2,097,152 MC recovery cases). Supporting combinations are not inflated into real-CPU SAVE/LOAD case counts. These groups perform 36 SAVE transports and 54 LOAD transports. Setup/debug/aborted pilot runs are excluded; [fixture.md](fixture.md) lists why.

| Fixture / case | Suffix clocks | LOADs | Stream/full WRAM | Result |
|---|---:|---:|---|---|
| matrix/bypass | 6000 | 1 | supporting variant | PASS |
| campaign/sega_prefix_long | 24000 | 3 | supporting variant | PASS |
| campaign/sega_sms_ordinary | 24000 | 3 | supporting variant | PASS |
| streams/sega_sms_ordinary | 24000 | 3 | yes | PASS |
| campaign/sega_sms_cb | 12000 | 1 | supporting variant | PASS |
| streams/sega_sms_cb | 12000 | 1 | yes | PASS |
| streams/sega_sms_ed | 12000 | 1 | yes | PASS |
| campaign/sega_sms_dd | 12000 | 1 | supporting variant | PASS |
| streams/sega_sms_dd | 12000 | 1 | yes | PASS |
| campaign/sega_sms_fd | 12000 | 1 | supporting variant | PASS |
| streams/sega_sms_fd | 12000 | 1 | yes | PASS |
| streams/sega_sms_ei | 12000 | 1 | yes | PASS |
| campaign/mc_sms_mapper | 48000 | 3 | supporting variant | PASS |
| streams/mc_sms_mapper | 48000 | 3 | yes | PASS |
| campaign/mc_extended_systeme | 24000 | 3 | supporting variant | PASS |
| streams/mc_extended_systeme | 24000 | 3 | yes | PASS |
| streams/mc_halt_nmi | 24000 | 3 | yes | PASS |
| campaign/sega_halt_nmi | 24000 | 3 | supporting variant | PASS |
| streams/sega_halt_nmi | 24000 | 3 | yes | PASS |
| campaign/sega_transport_random | 24000 | 1 | supporting variant | PASS |
| streams/sega_transport_random | 24000 | 1 | yes | PASS |
| streams/mc_full_flush | 24000 | 1 | yes | PASS |
| joystick/mc_history_a | 24000 | 1 | supporting variant | PASS |
| joystick/mc_history_b | 24000 | 1 | supporting variant | PASS |
| phase/sega_resave_even | 24000 | 1 | supporting variant | PASS |
| phase/sega_resave_shift15 | 24000 | 1 | supporting variant | PASS |

## 35. Complete-v16 collisions found

Two distinct named omitted-state pairs, each checked word-for-word across all12,288 known words. The first phase-pair SAVE is also identical, but it is not counted as another omitted-state collision.

## 36. Guest-visible divergences found

Zero in canonical groups. Retained setup failures (RAM init filename, skipped loader entry, two test permutation cases, initial raw Pause oracle and unqualified ModelSim MODE/CPU generic collision) were corrected and excluded; none was promoted into a production defect.

## 37. G11 final classification

**CLOSED - PROVEN RECONSTRUCTABLE**. Active MC and Sega address/table/result state is deterministically refilled before guest observation. Sega’s free-running phase is architecturally irrelevant under the proven timing bounds. Inactive decrypt hardware and fixed session/media/cheat configuration are justified exclusions. No remaining child keeps G11 open, and no production fix is justified.

## 38. Exact evidence limitations

Functional RTL simulation and source dependency/ordering proof, not board validation or external-game cipher compatibility. The integrated programs are targeted, not an exhaustive Z80 ISA or mapper/VDP/audio audit. Other peripheral serializer endpoints retain the documented G12 test models. Most runs shorten only the900,000-clock flush; one strong full-flush case retains it. Media, keys/tables, ROM geometry, BIOS and cheat configuration remain the same session. BIOS buffers/cheat mux are source-classified surrounding paths, not claimed as additional integrated encrypted tests. Literal idle-register/phase equality is not required or claimed where observational irrelevance is proved. No Quartus, F01, F06 or OPLL/FM investigation was performed; G08.FM remains OPEN - BLOCKED BY F01.

## 39. Production RTL/v16 unchanged

All 203 baseline tracked-file SHA256 values match; HEAD is unchanged. Only investigation/test/report files under this directory were written. Nothing staged; no commit, push, PR or Quartus run. [integrity.json](integrity.json) retains the check.

## 40. git diff --stat

```text
(empty)
```
The new investigation files are untracked, so an empty tracked diff does not mean no artifacts were created.

## 41. git status --short

```text
?? tests/
```
The existing untracked tests tree includes prior investigations and this new directory.

## 42. Exact recommended next task

Perform a post-G11 reconciliation of the original G-class closure audit, recording this G11 closure and preserving G08.FM = OPEN - BLOCKED BY F01. Keep any F01/F06/FM investigation or implementation in a separately authorized task.
