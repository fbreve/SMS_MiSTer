# YM2413 collision reachability and fault injection

Reference: `9873761503510e4b2c7e06600bf5515344235c2f`.

**Result: both accepted-LOAD hazards reproduce. RegisterMemory also depends on collision results during coherent normal operation. OutputMemory has a small, producer-compatible candidate acceptance guard, but that guard changes today's accepted payload set. No production fix was implemented.**

All new files are confined to this verification directory. No existing worktree, production source, master or sys file was changed. No branch, commit, merge, push, PR, Quartus run or RBF was created. Existing worktree HEADs, tracked diffs/status and master were checked against `preservation_before.json`; collection passes. Prior experimental evidence was only read. These experimental files must not enter the production-only upstream PR.

## Method and reproducibility

`reproduce.ps1` prepares independently compiled baseline and fault-model libraries, runs the probes, invokes ModelSim on the unchanged production validator function and clock-divider statements, and collects results. GHDL is 6.0.0, mcode JIT. Binary hash/version/configuration are retained under `logs/`. All GHDL instances inherit Idle from their dedicated runner, with explicit priority samples. Toolhelp process enumeration checks active GHDL processes and descendants; Windows console hosts are observed but their priorities are not changed. At most two simulations ran concurrently. CIM was unavailable; the final runner uses Toolhelp and tolerates processes exiting during enumeration.

`prepare.js` obtains VM2413 files directly from the commit, applies the existing simulation compatibility adaptations to both libraries, and adds independent internal-state observations. It changes only isolated verification copies. The fault model replaces registered memory read values only on actual operational, snapshot-write or initialization collisions. Writes, addresses, pipeline enables and all production worktree sources remain unchanged. This is an adversarial model of unspecified collision outputs, not a claim that silicon produces every injected pattern.

Modes: 0 OLD_DATA; 1 NEW_DATA; 2 zero; 3 all ones; 4 alternating bits; 5 complement of the actual pre-write row. Additional mode 6 sets all 22 useful RegisterMemory bits while retaining the fitted zero padding at bits 15:14 (`FF3FFF`). Both the stage-2 counterexample and coherent musical-write hazard reproduce with that physically constrained pattern; the finding does not require corrupting padding. OLD_DATA controls remain exact. Zero equals OLD_DATA in the initially-zero directed examples, so absence of divergence in that combination is expected. Independent initial read-value assertions establish that substitution occurred. `collect.js` adds 51 independent consumer/commit assertions using integer sign-magnitude arithmetic, channel-register packing, the specified low-byte write and cache nibble selection; it does not call DUT averaging or SAVE code.

Every checked raw clock compares all 104 independently observed state words and both raw/wrapper audio outputs. CSVs retain pre-edge read values and post-edge state. Logs record first/last differences per word, audio differences, active consumer clocks and PASS/FAIL termination. Tests have simulation and process timeouts. Final aggregate results and artifact SHA-256s are in `results.json` and `artifact_hashes.json`.

The local LOAD driver follows AP_READ/AP_WRITE sequencing and eight raw REFILL clocks. Capture reads are checked against internal state, not a second serializer. The complete DDRAM/Z80/video FSM campaign was not repeated; the actual production word-validator predicate was extracted unchanged and executed on every payload. Descriptor/version/format were not modified. Production divider statements were separately simulated, and the one-clock ARM_FREEZE and quiet-unfreeze conditions were inspected in the baseline FSM.

## Executable accepted-payload counterexamples

`validator.log`: all four complete directed payloads pass the unchanged production `fm_word_valid`, as do 6,480 producer snapshots and 432 additional guard-compatible incoherent payloads. Normal valid descriptor/header framing is assumed; this is not an end-to-end DDRAM transaction test.

Output A uses word 78 `00000003`, word 100 `7FE00402`, and entry 16/word 74 zero. Output B uses word 78 `00000002`, word 100 `7FE00042`, word 101 `00000002`, and entry 1/word 59 zero. Other fields come from the reference capture. Full images are `payload_0_0.hex` and `payload_1_0.hex`.

Register stage 3 uses word 78 `3`, word 81's register address zero, word 83 `00800010`, row 0 zero, and word 77 `00018110`. Stage 2 changes word 78 to `2`. These restore `regs_wr=1`, pending instrument-1 data and a matching channel-0 low-byte command. Other fields retain valid captured values. Full images are `payload_2_0.hex` and `payload_3_0.hex`.

Clock numbering below starts with E1, the first unfrozen raw edge. The first enabled FM edge is E2. `clock_check.log` confirms this is reachable: quiet release at divider phase 22, E1 at phase 23, E2/FM enable at phase 24. This satisfies the production quiet-release condition, including SP enable. The copied production divider also passes 445 ARM-edge checks across both CPU boundary selections and all 30 initial divider phases.

| Probe | E1 | E2 consumer | E3 / subsequent effect |
|---|---|---|---|
| Output A, NEW_DATA | Write entry 16; injected read is `3FF` (-511), reference read is zero | OutputGenerator slot 16/stage 3 averages injected data with the same linear sample | FeedbackMemory entry 8 becomes `2E6` (-230), versus `019` (+25). Operator/lookup/output state subsequently differs; first audio difference E2087 |
| Output B, NEW_DATA | Write entry 1; both matching reads receive `3FF` | TemporalMixer slot 0/stage 2 accumulates -511 | Mix is `3E01` (-511), versus zero; first mixout/audio difference E1022 |
| Register stage 3, NEW_DATA | Write row 0; injected read is `100000`, reference read zero | `inst_cache(0)` becomes 1 versus 0 at E2 | Voice address differs E17; controller parameters, envelope RAM and Operator state subsequently differ; first audio difference E2087 |
| Register stage 2, useful bits all ones | Inject read `FF3FFF` with padding zero | Read-modify-write preserves the injected unaffected fields and changes only the commanded low byte | Row 0 becomes packed `003FFF81`, versus `00000081`, at E3; phase/envelope RAM differ from E33; first audio difference E2102 |

See `trace_0_1_gap1.csv`, `trace_1_1_gap1.csv`, `trace_2_1_gap1.csv`, `trace_3_6_gap1.csv` and matching logs. The first 64 raw edges are retained as CSV; later first/last events are logged.

Across the 24 directed case/pattern combinations, 16 diverge; all four OLD_DATA controls are exact. In the one-raw-gap NEW_DATA Output A case, FeedbackMemory differs E3–E1082 and audio E2087–E3166; the tested difference ultimately heals. Output B changes only mixer state/audio and ultimately heals. Both still fail mandatory exact equivalence. Register stage-2/all-one corruption remains in row 0, phase RAM, envelope RAM, key history and audio through E983056: 65,536 follow-up enabled clocks, 18.30813696 ms at this harness's clock rate. This is an observation bound, not a claim of infinite-duration testing. Without a later correcting write, the read-modify-write has already committed incorrect channel fields.

Boundary controls also pass: immediate first-edge enable (gap 0) avoids the directed Output consumption; zero injection with gap 13 reproduces both failures. Gap 13 is reachable from quiet divider phase 10. Gap-14 logs are supplemental long-enable-gap probes, not a standard quiet-divider release phase.

## Coherent producers and supported legacy behavior

The producer sweep passes 6,480 capture/reload checks: 72 counter positions × six musical scenarios × 15 quiescent freeze offsets. It includes all nine initialized channel entries, sustained notes, key-off/on, rhythm changes, custom instruments, pending channel writes and long held capture/LOAD intervals with CE low. Captures include 2,430 pending register-write states and 1,620 pending output-write states. The earliest tested freeze allows the ARM raw edge to commit the enabled edge's pending write before hold is asserted. SAVE read values and restored state are checked independently.

Structural induction from reset, plus these assertions, establishes the following for normal coherent producers:

| State | Relationship |
|---|---|
| Word 78 | The shared counter advances on an enabled, unheld edge; delayed counters restore from the same value, with delays 2, 5 and 8 |
| Word 100 `mo_wr` | Set at OutputGenerator stage 3, while the counter advances to stage 0; cleared when stage 0 executes. Therefore `mo_wr => word78[1:0]==0` |
| Word 100 `fb_wr` | Likewise only survives at global stage 0; assertion additionally depends on the previous OutputGenerator slot being even |
| Word 83 `regs_wr` | Set at controller stage 2; survives at saved stages 3 and 0; cleared at stage 0 |
| Words 81/83 | Controller register address changes at stage 0; read-modify-write happens at stage 2 and controller/cache consumption at stage 3. ARM-boundary captures verify the pending data has reached its selected RAM row |
| Word 97 | `faddr` updates at Operator's delayed stage 2 on odd slots, to the next channel, wrapping channel 8 to 0. It is not generally equal to word 100's feedback-write address |
| Word 101 | Mixer address/mute update at global stage 0 using the then-current rhythm mode. Muted slots can retain a previous address; stage 2 consumes only when unmuted and not slot 17 |

Independent transition scoreboards check controller address, OutputGenerator address, Operator feedback address and mixer address/mute against pre-edge inputs. Thus these relationships are not inferred solely from matching serialized words. Blanket restrictions equating feedback addresses or deriving every saved mixer address from the current rhythm bit would reject legitimate pipeline state.

Normal coherent execution records 587 RegisterMemory collision-consumer events in the producer sweep, and zero OutputMemory collision-consumer events. An additional six-pattern coherent musical-write test confirms the distinction: RegisterMemory OLD_DATA and NEW_DATA remain equal after repeated identical writes, but zero/ones/alternating/complement faults affect 23–26 saved words and audio. The all-one witness reaches controller stage 3 at raw E545, changes cache/controller state there, and phase/envelope RAM at E561. This does not prove that silicon generates such a value; it proves the implementation is not independent of the unspecified result.

All six patterns remain exact for OutputMemory during coherent musical writes, supported legacy-reset/initialization/replay sequencing, and initialization with all 15 first-CE offsets. Legacy fallback values are checked against the actual production `legacy_word` function. Legacy clears pending OutputMemory writes and refills reads before release.

The v19 reference's controller, OutputGenerator, TemporalMixer, SlotCounter and snapshot transport match the committed baseline after ignoring line-ending differences. This supports applying the same producer invariant to those known functional version-17 producers. It does not certify every external or historical experimental version-17 writer.

## Proposed guard: evidence and compatibility

The proposed Output-only condition is:

`word100.mo_wr == 0 || word78.stage == 0`

No production validator was changed. A separate cohort loads 432 payloads (72 positions × six patterns) satisfying that condition while deliberately making register pending state, feedback address/write state, output address and mixer control inconsistent with the producer pipeline. Every payload passes the original validator. Both cores remain identical in all 104 words and audio at every checked raw edge, including seven initial raw writes, 16 fault-enabled FM clocks and 144 subsequent FM clocks per load.

The safety argument does not require the other fields to be coherent: if `mo_wr=0`, there is no resumed output collision before a deterministic read; if `mo_wr=1` at stage 0, that stage consumes neither port and clears the flag. Stage 1 supplies a write-free read before stage-2 mixer and stage-3 feedback consumers. SAVE/LOAD holds consumers during array writes; REFILL supplies initial reads. Arbitrary addresses/data do not defeat this sequencing because all addresses remain range-legal and delayed counters derive from word 78.

The guard accepts all 6,480 producer snapshots, permits legitimate pending output writes, and leaves the separate legacy path intact. It rejects directed Output A/B, which are currently accepted. Therefore it is an acceptance-contract tightening, not preservation of all previously accepted payloads. A later SAVE immediately following an already-incoherent accepted LOAD could also preserve incoherence; no blanket compatibility claim is made for that chain or unexamined external producers. The guard is a collision-safety condition, not a complete coherence validator.

Implementation would need to retain the stage-zero predicate while validating the later word 100, or reuse an existing captured counter. Expected cost is a small amount of validation state/comparison logic, not measured here. No ALM savings or cost is claimed. Rejecting every pending write would be incompatible and is unnecessary. A register-stage validator cannot fix normal RegisterMemory consumption.

## Ranked resolutions

**OutputMemory:**

1. If an explicit acceptance-contract tightening is acceptable, investigate the stage guard as the smallest change. It has structural and targeted experimental support, preserves the audited producer snapshots, and removes reliance on primitive collision data for the newly accepted set. Obtain compatibility approval before implementing it.
2. If every currently accepted payload must retain exact baseline behavior, retain logic. This is the immediate deterministic option.
3. For resource optimization with the same accepted set, use a memory architecture with guaranteed OLD_DATA semantics, potentially replicated native block memory for the two reads. Inference, latency, resource cost and timing would require a separate experiment; none was run.
4. A cached-OLD_DATA bypass is another investigation, not a proven small fix. It must recover the row before the current write, distinguish the first write from repeated writes, track addresses and handle initialization, snapshot writes and post-LOAD address changes. When the same row was written on the previous raw edge, the previous committed write data is actual OLD_DATA. For the first write, NEW_DATA is not a substitute: a valid pre-write sample or deterministic storage access is required. Merely delaying consumers, clearing pending writes or adding refill after committing them can change the logic reference's behavior on incoherent payloads.

**RegisterMemory:**

1. Retain logic for integration. No validator-only restriction resolves coherent normal-operation dependence.
2. Reconsider the previously measured AUTO/M10K candidate if its explicit OLD_DATA implementation, extra M10K and measured timing trade-off are acceptable. It is a safer resource direction than assuming MLAB collision behavior, subject to the existing evidence and normal review.
3. Pursue MLAB only as a separately approved deterministic OLD_DATA architecture experiment. The 22 useful data bits, initialization and read-modify-write behavior make shadow/history/bypass circuitry a meaningful cost. Full shadow storage could erase much of the gain. NEW_DATA forwarding is demonstrably incorrect for the directed stage-2 payload. Do not assume net savings without measuring the completed safe architecture.

**Recommendation:** OutputMemory is worth pursuing through a small validator-guard proposal with explicit compatibility approval. It is not yet unconditionally safe for the unchanged accepted payload set. RegisterMemory's current attribute-only MLAB implementation should not be integrated; retaining logic or evaluating the known native-OLD_DATA alternative is the more economical next decision. Existing MiSTer success remains empirical evidence and is not contradicted by an observed silicon failure here. Stop before any production fix.
