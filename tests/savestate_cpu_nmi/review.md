# F16 CPU NMI savestate investigation

**CONFIRMED - FIX REQUIRED. Investigation only; no production RTL or format changes.**

Branch `investigate/savestate-cpu-nmi`, baseline `d1df590` (committed F15). The real T80 reaches accepted production SAVE boundaries with unsaved pending and accepted-NMI state. LOAD clears that state. A ROM handler increments C100 in the continuation but does not run after LOAD; the restored counter remains zero. Complete, known v11 images are identical across states with different future execution. GG restoration additionally depends on post-save edge history.

## 1–3. Inventory, sequence, acceptance

[inventory.md](inventory.md) contains the complete source-to-CPU inventory, widths, reset/update/restore behavior, payload mapping, T80 sequence and A/B/C acceptance classification. Relevant production locations: `SMS.sv:1044`, `rtl/system.vhd:620`, `rtl/io.vhd:185`, `rtl/T80/T80.vhd:1090`, `rtl/savestates.sv:1014` and `:2380`.

No internal flag or acceptance predicate is forced. The only controller force bypasses UI operation cooldown. T80 instrumentation exports observations without feeding them back. ModelSim adapters qualify VHDL entity instantiations and move two SV declarations before use; production behavior is unchanged. Real video, T80/T80s, IO and savestate controller run together; host inputs, ROM, DDR and synchronous WRAM are fixture models. This is integration validation of the normal NMI source expression and actual local GG endpoint, not a complete MiSTer top or FPGA hardware run. Remote serial frames were not independently swept; the serial source is inventoried and shares the tested CPU input path. PC6 exercises the actual GG endpoint rather than driving its NMI output directly.

## 4–5. Timing coverage and reachable states

157 timing/input cases, each run uninterrupted and SAVE-only: **314 canonical runs**, each compared over 430 enabled CPU steps (67,510 paired steps). Programs cover DI with RAM increment/JP, EI, HALT, and DD-prefixed LD IX. SMS timings include a contiguous **every-host-clock sweep -61 through +2** about the nominal accepted boundary, plus offsets -450,-360,-300,-120,-30,-16,-15,-14,+15,+60 and inactive control; duplicates are removed. Coarse timings are repeated across all four programs. GG PC6 includes the coarse pulse sweep and selected held levels. Five-clock pulses and held-low assertions are distinct cases.

Offsets refer to nominal T=ready+359, not an assumed acceptance instant. Every actual request and accepted cycle is recorded; HALT, prefixes, early interrupt delivery and handler execution can move acceptance. The sweep includes before request, on its CPU-enable region, request-to-acceptance, the immediately preceding host clocks, the capture half-clock, and following clocks. Exact physical setup/hold or metastability is outside RTL simulation; transitions are placed on negative edges before the rising sampling edge.

`cases_sync.json` specifies every run; `results.json` records request/actual acceptance, complete CPU word, pending, entry, Old and input. Logs include M1/MREQ, MCycle/TState/Prefix/IFFs, PC, SP, data and CPU bus strobes. State observation encoding is `{NMI_s,NMICycle,IntCycle,MCycle[2:0],TState[2:0],Prefix[1:0],IFF1,IFF2}`. Thus 10a0=pending, 08a0=entry, 18a0=both, with MC1/T2 and IFFs0. The single-edge sweep accepts 00,10,01; the double-edge case naturally accepts11. EI also accepts entry with IFF2=1. Non-fetch and prefix requests defer; they do not exclude the subsequent vulnerable fetch.

## 6–9. Replay, first divergences, real guest effect

The strongest matched-prefix case is SMS, DI, five-host-clock Pause pulse at ready+344..349, SAVE request at cycle69243, actual acceptance **cycle69301** (ready68942, relative359). Input and Old are both high at T. CPU PC0101, SPDFE0, MC1/T2, pending1, NMICycle0, IFF1/2=0, ISet00, M1/MREQ both low. Full CPU payload:

```
00100000000000000000000000c101000000000101dfe00a004400007f
```

This state is reached by instructions and a normal Pause input pulse. No handler has run and C100/C102 are zero at T. Future inputs remain inactive. The independent reference and SAVE-only traces match on every enabled step. They finish the current JP, enter NMI, push the return PC, fetch0066, write C100=1 and C102=1, RETN and continue. The same snapshot, after Q and LOAD with inactive input, fetches ordinary code at0101, never enters0066, and leaves C100/C102=0. See `sync_pending.log`, `sync_s0_p0_e-15_w5_r0.log`, and its r1 counterpart.

The first internal divergence is restore itself: saved pending1 is absent after DIRSet; PC/SP/IFFs restore but pending and entry are explicitly zero. A frozen-Q pulse in `causal_dir.log` makes this directly observable: DIR_BEFORE at cycle2851830 has N=10b0, DIR_AFTER N=0090. Old remains1. For the matched inactive continuation there is no later falling edge to repair the lost pending request.

The first guest bus difference is the reference's NMI stack write DFDF=01 (followed by DFDE=00, return PC0100); restored ordinary execution instead proceeds to the next C101 progress write with no stack entry. The unambiguous handler result is C100=1 reference versus0 restored. PC/vector, SP, stack writes and the signature corroborate the counter, rather than merely observing an internal latch.

The accepted-entry case uses a pulse at ready+299..304. At exactly the same T and CPU payload, pending0/NMICycle1 is already selected before the dummy fetch's T2. Reference immediately follows entry microcode and pushes PC0101, including DFDE=01. LOAD clears NMICycle and executes an ordinary JP. This is independently guest-visible and cannot be fixed by restoring only NMI_s. A second pulse at ready+344..349 gives pending1/NMICycle1 at T and two handler increments; LOAD gives zero. Three vector-fetch observations in this double-NMI test include the first handler-address dummy fetch and the later return to0066; they must not be mistaken for three handler increments.

## 10. Full non-injective state proof

Six naturally reached accepted images are compared word-for-word across **all 12,288 initialized DDR words**, including the complete saved image, headers/checksum and every modeled peripheral/memory payload. There are no X/Z bits. All six have SHA256 of normalized words:

`795f07e3665159fba2513553891db7b71748090e63020d02f84e11d59f0bfde3`

| State at T | Input / Old | Pending / entry | Continuation |
|---|---|---|---|
| Inactive | 1/1 | 0/0 | No NMI, counter0 |
| Released recent pulse | 1/1 | 1/0 | One NMI after current instruction, counter1 |
| Released earlier pulse | 1/1 | 0/1 | Entry already selected; different return PC, counter1 |
| Two released pulses | 1/1 | 1/1 | Two handler increments |
| Earlier pulse held low | 0/0 | 0/1 | One handler increment |
| Earlier released pulse, fresh low at capture | 0/1 | 0/1 | Two handler increments |

The first four share **identical future high input**, proving two independent missing entry/pending distinctions. The last two share identical low input at T and throughout the suffix, identical flags, CPU payload and entire v11 image, but differ only in Old at capture. At the capture clock the fresh low becomes another pending edge; held low does not. This independently proves the edge-history distinction. `old_held.log` versus `old_fresh.log` is therefore stronger than assuming current level determines Old. Snapshot filenames, hashes, all 15 pair comparisons, and known-bit checks are in `results.json`.

## 11. SAVE-only result and its limits

141/157 wall-clock stimulus pairs match all 430 complete CPU/bus/internal-state observations; 146/157 match CPU/bus observations when pending-latch observation is excluded; 155/157 match handler counter and signature. **Every mismatch has its external edge after the actual accepted capture.** No pre-capture history case differs under SAVE-only.

This does not justify claiming universal wall-clock SAVE-only equivalence. T80 samples raw Pause on host clocks while its CEN is frozen. A later wall-clock edge can become pending earlier in CPU instruction time than in uninterrupted execution. Nine HALT cases consequently differ in exact architectural timing (including HALT release), although their handler results agree. Two five-clock GG PC6 pulses at nominal +15/+60 are observed by uninterrupted IO but occur entirely inside SAVE freeze in the saved run; the frozen GG synchronizer misses them and its handler counter stays0 instead of1. These are **SAVE/external-stimulus timing effects**, not evidence that LOAD discarded a T-time bit. They are retained and reported, not counted as exact passes or used to prove F16.

Two additional controlled suffix pairs deliver the same pulse after enabled step29, independently of transport duration, for ordinary and HALT programs. Both match all 430 full steps. This isolates CPU/NMI preservation from host wall-clock motion. It does not rewind a physical host or remote peer. Exact arbitrary live-peer equivalence would require a separate input/transport contract; serializing CPU flags alone cannot guarantee it.

## 12–14. Repeated LOAD, input matrix, DIRSet causality

16 directed replay scenarios perform **48 LOADs**. Each uses three Q histories: inactive input; another pulse then release; another assertion held through LOAD. CPU instructions and handler activity perturb Q before each actual accepted LOAD. Source levels remain current; no saved external host input is applied. For the vulnerable SMS pending and entry snapshots, each LOAD loses the saved event and finishes C100/C102=0, including when the source is held low (Old has already sampled low in Q). Released pulses do not magically reappear; a held level is not a new edge. An inactive baseline remains counter0 after all Q histories, showing Q's already-handled interrupt is not preserved as a T event. Fresh or post-T edge probes are matrix controls; an event arriving after T is not claimed to belong in T's payload. The primary positive proofs use pulses fully before T and matched inactive future inputs.

The input matrix covers inactive/inactive; pending with input released at T; held-low at T then released before LOAD; held-low at T and at LOAD; changed source between SAVE and LOAD; and fresh edge at capture. `causal_dir.log` additionally creates pending1 during LOAD freeze and observes its unconditional clear at DIRSet. This proves the statement's effect, rather than merely correlating a later missing vector. SMS Old is untouched by DIRSet, so both inactive-high and held-low Q histories fail to recreate T's pulse.

GG PC6 uses actual synchronization, direction enable and latched-source acknowledge by OUT02 in the handler. For the accepted-entry snapshot in `proof_s1_e-120_w0_r2.log`, local saved gg_nmi_pc6=1. When Q cleared it, simultaneous gg_set/DIRSet restores the source from high to low; DIR_AFTER shows input0/Old1, so the next host clock recreates pending. A handler runs, **late**: the stack's return-PC low byte is00 instead of reference01. When Q already has its source asserted and Old0, gg_set restores an already-low output; no falling edge exists, so the same snapshot produces **no handler**. The repeated counter results are [1,0,0]. The pending-GG snapshot at offset-60 has the same [1,0,0] dependence. Equal count on the first LOAD is not exact preservation. The source's serialized flag is insufficient to reconstruct the CPU's consumption history. Offset-15 GG exercises source-pipeline state that has not yet asserted CPU NMI at T and is treated separately.

## 15–19. Reconstructability, minimal architecture and format

Unique reconstruction from v11 is impossible under an all-reachable-states criterion: the complete identical-image examples above have distinct continuation traces under identical future inputs, including equal current input levels. IFFs, PC/SP, R, HALT, GG source flags and input level cannot supply the missing information. Pending and entry can both be1, so a single pending/active enum bit is insufficient. Old cannot be derived solely from current input, nor retained from Q.

The smallest straightforward complete temporal payload is **three one-bit fields: NMI_s, NMICycle, OldNMI_n**, captured coherently with the pre-tick CPU state and restored from T, with ordinary restart sequencing respecting saved NMICycle. Edge-on-capture semantics must be explicit: either save the pre-edge triplet and replay the input sample correctly, or normalize that edge into pending and sampled input consistently. IO/GG post-tick capture and simultaneous restore require corresponding ordering. This is an architecture proposal, not a validated fix. It does not claim that every physical encoding of future-equivalence classes must literally store three named registers, or that flags alone solve arbitrary live-peer SAVE timing.

| Candidate | Result |
|---|---|
| Serialize coherent T-time triplet | Viable smallest direct proposal; avoids changing guest execution or waiting for a host release |
| Reconstruct from v11 | Ruled out by full non-injective images |
| Exclude pending and NMICycle at acceptance | Insufficient alone: a fresh edge can arrive on capture, and Old/current level still matter |
| Require no flags and input/Old both high | Known canonical NMI state, but no finite bound: host may hold Pause low indefinitely or keep supplying edges; changes the accepted-boundary contract |
| Run until handler finishes | Not bounded for arbitrary handler code or repeated edges; can add arbitrary guest progress and still needs edge coherence |
| Preserve current flags/Old through DIRSet | Incorrect: Q contains events after T; GG repeated LOAD proves current-history dependence |
| Capture/reconstruct from a new small side record | Equivalent explicit serialization, provided metadata is versioned and atomically associated with T |

No safe **bounded** v11 acceptance-only solution has been established. Under the existing acceptance contract, explicit state is required. Validated available space: CPU word5[63:38] is 26 zero padding bits on both write paths; LOAD currently uses only [37:0]. A proposal could use word5[40:38] for the three bits with 23 padding bits remaining, no new DDR word and no change to the 230-bit architectural register meaning. Both generation and reader validation/identification would need updating. Reserved directory words need not be consumed. This is static space validation, not an implemented round trip.

The evidence, rather than a presumption about version numbers, establishes the need for a new versioned temporal-state extension. For the normal sequential version scheme that means **v12** (or an equivalently explicit independently validated extension). Silently writing new meanings into v11 padding would make old readers discard the history and would not make old v11 images complete. Old-reader rejection of a new extension must be checked during implementation; this investigation does not assert existing readers reject every future tag.

## 20. Legacy policy proposal

For snapshots without metadata, exact NMI restoration is impossible. A deterministic conservative policy is pending0/entry0 and normalize Old to the **settled current NMI input after local GG source restore**, before CPU release. This avoids inventing an event solely because LOAD restored a low level or because Q had a different Old value. Later genuine falling edges are processed normally. It intentionally cannot recover an old pending/accepted event; document that legacy limitation or reject legacy images if exactness is mandatory. Never preserve Q's flags or infer a queued NMI merely from GG's asserted local source. No policy or rejection behavior was implemented.

## 21–22. Existing regressions

All 19 selected existing regressions pass against the committed baseline, using independent libraries and copied infrastructure in `regression/`:

- CPU architectural restore / real T80 Evolution replay;
- F12 System E paused save-only, case4 (2,552,454 checks; bounded capture progress exception retained);
- F13 mapper detection cases0/6;
- F14 selector cases0,2,3,4,12,30;
- F15 pending cases0,1,2,5,6,7,8,9 and real T80 offset0 with three LOADs.

`regress.out` and per-case compile/runtime logs retain the evidence. No tests or results in the prior F12–F15 folders were changed. The F16 NMI fixture initializes all architectural registers used by the full-image proof; inherited F12 test logs may contain their preexisting unused-register X values and are not part of that proof.

## 23–27. Scope and repository hygiene

F06 remains unresolved. This task neither changes nor reclassifies F01–F15. Production RTL, the v11 format and every tracked file have zero diff from committed F15. `git diff --stat` and `git diff --cached --stat` are empty. `git status --short` is:

```
?? tests/
```

The preexisting tests tree was already untracked. This task adds only `tests/savestate_cpu_nmi/` investigation infrastructure/evidence. `source_hashes.json` records 74 tracked SMS/RTL source SHA256 comparisons to HEAD (text normalized to LF because core.autocrlf=true; raw worktree hashes also retained); `repository_status.txt` records branch, commit, status and empty tracked/staged diff statistics. `verification.json` records passed cross-run assertions and regression totals. No Quartus run or new Quartus artifact, no staging, commit, push or PR. Temporary simulator libraries, waveforms and redundant preliminary asynchronous-WRAM runs are removed; canonical synchronous-WRAM logs and images are retained.

Final classification: **CONFIRMED - FIX REQUIRED**. A real pending NMI and an already selected NMI entry both survive to accepted production boundaries, are absent from complete v11 images, and are lost or reconstructed inconsistently by LOAD, causing different real guest execution. Investigation stops before any production fix.

## Capture-edge prerequisite resolved

The focused [capture-edge implementation contract](../savestate_cpu_nmi_capture/review.md) resolves the earlier A/B ambiguity without production changes. Select B: at the accepted MC1/T2 edge, save normalized `(NMI_s OR (OldNMI_n AND NOT NMI_n), NMICycle, NMI_n)` alongside the unchanged pre-edge architectural CPU payload. The third component is the resulting historical sampled Old, not a command to restore a physical input.

Restore the triplet after the last DIRSet, with sampling held; hold GG through CPU-only T1 setup and historical T2 replay, then resume normal sampling on logical T+1. This prevents both replay of the accepted sample and double advancement of the already post-T GG snapshot. Candidate A also passes when it carries and replays a fourth historical sample bit; B is the equivalent three-bit normalized representation. The follow-on report specifies the exact clock alignment, ordering, v12 proposal, legacy policy and validated scope. Status: **F16 IMPLEMENTATION UNBLOCKED**; F16 remains **CONFIRMED - FIX REQUIRED**, with no production fix implemented.
