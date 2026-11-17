# G06/G10 shared release investigation

**G10: CONFIRMED - FIX REQUIRED. G06: PARTIALLY BLOCKED BY G10, with its independent temporal-freeze and discarded-source defects still requiring correction. Next task: FIX G06 + G10 AS A COUPLED CHANGE.** No production fix is implemented here.

The positive G10 proof is a normal-speed **SAVE-only** phase pair: the complete v13 image and sprite trace are identical, but legal release phases21/23 versus27/29 change CPU A and guest RAM. Separately, the turbo LOAD's two-pixel delay is caused by historical T1/T2 CPU preparation while the VDP advances: explicitly matching the **entire divider phase and every enable** does not remove it. The original C witness alone therefore did not establish divider-phase causation. A phase correction alone does not solve preparation ordering.

## Evidence boundaries and logical time

Committed HEAD is `8ffd15e2a7e530c0d77b07c6eeae3e8dc0aa0c8a`, format v13. Branch: `investigate/savestate-g06-g10-release`. All seven requested reports were read. Their historical fit/readiness and scoped closures are retained as history, not promoted into current cross-domain evidence. Earlier reports are unchanged. [retained.json](retained.json) freezes the original A/B/C logs, image and raw traces by SHA256. [README.md](README.md) gives runnable commands and observation semantics.

G01/F16 already define T as the accepted pre-edge MC1/T2 clock. The CPU image is architectural A-minus plus predecessor decoder context and normalized NMI history. The uninterrupted CPU consumes that T2 at T. VDP/video/IO snapshots are post-T values captured at ARM one host clock later. A correct restored logical T-plus therefore combines **post-historical-T2 CPU** with **the captured post-T VDP/beam**, not a beam advanced during reconstruction.

Historical T1/T2 are expected CPU normalization, not two guest continuation ticks to discard from every subsystem. Transport clocks are wall-clock time. The F12 exception authorizes bounded coherent progress before capture when a logically paused CPU must seek the boundary; it does not authorize two extra post-T VDP pixels on LOAD. Aligning the CPU after historical T2 while shifting the reference beam by two would change that established contract.

The first unequal normalized CPU MC/TS during preparation is expected. The harmful ordering is allowing post-T VDP/pixel progression concurrently with those reconstruction ticks. In the retained/default turbo LOAD, the CPU reaches MC1/T3 at cycle3345991 with beam x12/y168. Reference post-T CPU is already MC1/T3 with beam x10/y168. There is no single global logical-time alignment that equates both by dropping the two VDP pixels.

The explicit Phase6 control sets only testbench clkd11→1 at the already-quiet LOAD release edge3345971; phase1 is naturally reached at original ARM. For the subsequent9999 aligned host clocks, **clkd, raw ce_cpu, actual turbo CPU enable, ce_vdp, ce_pix, ce_sp, x/y and all650 raw sprite bits have zero differences**. Collision/status still differs by9/6 pixel samples; accumulator and RAM differ for420/750 native clocks in that interval. The CPU spends the first two enabled ticks on historical preparation in both LOAD controls. This excludes a hidden G06 source difference or a different divider phase as the cause of C's remaining two-pixel shift.

| Event | Uninterrupted reference | Full-phase LOAD control |
|---|---|---|
| First unfrozen comparison clock |607472, clkd2, MC1/TS3, beam10/168 |3345972, clkd2, MC1/TS1, beam10/168 |
| First pixel/CPU enable |607480, clkd10: continuation after T |3345980, clkd10: historical T1 while beam advances |
| Second pixel/CPU enable |607490, clkd20: ordinary continuation |3345990, clkd20: historical T2 while beam advances |
| CPU canonical post-T state |Already present at607471, beam10/168 |3345991, MC1/TS3, beam12/168 |
| First BF request |x26/y168 |x28/y168 |
| Collision-sensitive BF request |x128/y168 |x130/y168 |

These are actual core TS encodings and pre-edge timeline observations. clk_sys period is10ns; a recorded rising edge at cycleC is time10*C+5ns. The raw per-clock trace begins before release and runs through the divergent read; compact copies retain the last16 frozen clocks and every observed guest clock, with the complete original wait traces losslessly archived. [Default timeline](common_t1/timeline.csv), [full-phase timeline](forced_common_t1/timeline.csv), [reference timeline](reference_t1/timeline.csv), [machine-readable comparison](results.json).

| Divider milestone | Turbo reference/SAVE | Default turbo LOAD | Full-phase control |
|---|---|---|---|
| Accepted SAVE |607470, phase0 |Same saved image |Same saved image |
| ARM / freeze entry |607471, phase1 |LOAD request ARM1513711, phase1 |Same |
| CPU + VDP/video restore edge |Not applicable |1553894, phase14 |Same |
| Post-flush LOAD completion / pre-unfreeze |Not applicable |2453926, phase16, source-derived |Same |
| First logged final release-wait clock |Not applicable |2454177, phase27, observed |Same |
| Actual release |SAVE1503511, phase1 |3345971, phase11 |Same edge; testbench11→1 |
| Next raw CPU / actual turbo CPU / VDP / pixel / sprite enable distances |9 /9 /4 /9 /1 |14 /9 /4 /9 /1 |9 /9 /4 /9 /1 |

The post-flush milestone means completion of frozen restore/flush before the alignment wait, not final memory-transfer acknowledgement. It is derived from the observed first ST_UNFREEZE/count250 clock and unchanged FSM counts; [milestones.json](milestones.json) explicitly records that distinction. The actual architectural restore edge is directly logged. Normal reference future distances after ARM phase26 are CPU14/VDP4/pixel4/sprite2; the sprite enable on the ARM edge itself is not counted as a future enable.

LOAD repositions the video counter while clkd continues running. Matching the saved beam later therefore does not reconstruct the full modulo30 relationship: the default turbo run releases at11 instead of1. Its /10 pixel/turbo-CPU and /5 VDP schedules happen to agree, while raw /15 CPU/peripheral enables do not. The full-phase control removes even that difference and still retains C.

## Natural phase experiment

The falling-edge divider is extracted unchanged from SMS.sv into [divider_source.sv](divider_source.sv). Only its local clock identifier is renamed. The previously established quiet phases are1,3,7,9,11,13,17,19,21,23,27,29; quiet does not uniquely identify modulo30 phase. A legal initial divider value0 is used in every run and all subsequent phases arise from the production recurrence.

The normal-speed witness accepts T at cycle607465, clkd25, beam x9/y168, CPU MC1/T2 and fetch PC008D. ARM is607466, clkd26, x9/y168. The CPU has already consumed the phase25 tick. The captured beam interval admits quiet phases21,23,27,29. A release at21/23 re-enables the CPU for phase25 **again at that beam position**;27/29 do not. This is the minimal ordering distinction: a normal CPU tick before the next pixel versus the next pixel before the next CPU tick. No discarded sprite state differs.

The testbench holds external DDR BUSY only in the controller's final SAVE-settle stage, after the last image write. It clears BUSY early enough for the unchanged32-clock settle and255-count release wait to expire at different positions in the same beam interval. Production state, divider, beam and release predicate are never forced in this experiment. The parameter is a transport eligibility target; actual release phases are observed, not assumed.

| BUSY eligibility target | Actual release phase | First CPU / VDP / pixel / sprite distances, host clocks | First BF requests, y168 | Pixel samples differing: status vector / A / C100 |
|---:|---:|---|---|---|
|20 |21 |4 /4 /9 /1 |x51,102,153,204 |29 /6 /6 |
|22 |23 |2 /2 /7 /1 |x51,102,153,204 |29 /6 /6 |
|24 |27 |13 /3 /3 /1 |x53,104,155,206 |0 /0 /0 |
|26 |27 |13 /3 /3 /1 |x53,104,155,206 |0 /0 /0 |
|28 |29 |11 /1 /1 /1 |x53,104,155,206 |0 /0 /0 |

Every case compares1000 post-pixel samples to the independent uninterrupted normal-speed reference. All650 raw sprite/cache/shifter/collision-delay bits match at those samples; unused X fields remain diagnostic X, not initialized-image proof. VDP status and guest values are known. The first scored A difference is x160/y168: early-release A=3F versus reference1F, while C100 is still1F; the later guest store diverges too. Request positions are pre-edge bus assertions, not completed IN results. The native CSV separately records CPU T2 data samples and later accumulator/store changes.

All five complete images contain12288 known64-bit words and are byte-identical, SHA256 `d6c2b33cafe29d3608af682c4f5ee411c5721679d0e47b2d1e21451a34da715b`. Historical capture phase is25 in every case. Thus this proves **transport duration selecting an arbitrary future release phase**, not a requirement to serialize a different historical clkd. It is a positive equal-image resume pair involving SAVE-only, not a falsely labeled pair of two LOADs.

These phase controls retain the investigation-only G06 freeze guard to isolate the release mechanism. No sprite side record is applied during SAVE-only. The guard changes only the frozen overflow bookkeeping, not CEs, release or collision logic. This two-sprite source never raises overflow; the differing guest bit is collision bit5 (3F vs1F), not overflow bit6. The production overflow consumer requires spr_overflow1, so the guard cannot explain the early/late collision result. All production files themselves remain unchanged.

## Required report items

| # | Item | Evidence/result |
|---|---|---|
|1 |HEAD |8ffd15e2a7e530c0d77b07c6eeae3e8dc0aa0c8a. |
|2 |Format |v13 unchanged: tagged extension48430D/subtype3, CPU class word005 bits43:41. |
|3 |Original SAVE-only witness A |Retained exact nine-sprite GG/NTSC/192 Mode4 case. Y167/X120, D0 termination, requestx489/y168, T607470/x9, ARMx10. Original held overflow re-arms through raw beam while frozen; A/C100=5F vs1F. [Original log](../savestate_g06_vdp_sprites_fix/reproduction/overflow9/dut.log). |
|4 |Original LOAD witness B |Retained two-sprite same configuration and natural T. Three LOADs each38 collision /6 status-bus differences. Original restore clears future-producing cache before x257 refill. [Log](../savestate_g06_vdp_sprites_fix/reproduction/dut.log). |
|5 |Post-prototype witness C |Full650-bit side record plus actual-freeze guard, independent of unchanged v13 writer/reader. Original/default turbo LOAD retains9 flag /6 status-bus differences despite source identity. |
|6 |First divergence |Default turbo: raw clkd differs before continuation (reference2 vsLOAD12 at the first unfrozen sampled clock), but effective turbo CPU/pixel/VDP/sprite enables match. CPU MC1/T1 vs reference MC1/T3 is expected normalization. First CPU-enabled reconstruction step also advances the beam; by canonical CPU completion it is two pixels ahead. Normal phase-only pair first differs at release phase, then enables the extra phase25 CPU/VDP edge before the next pixel. |
|7 |Logical reference |Reference immediately after accepted T2, with VDP/video post-T snapshot. CPU normalization clocks are excluded from continuation **only if post-T domains remain at T-plus**. No new equivalence contract is introduced. |
|8 |Reference phase |Turbo T0/ARM1; normal T25/ARM26. Actual clkd is logged independently from modulo10 enables. |
|9 |Restored phase |Default turbo CPU/VDP restore strobe clkd14; release clkd11, not original1. SAVE-only normal natural releases21/23/27/29. Full-phase testbench LOAD control explicitly resets the quiet phase to1. |
|10 |First CPU distance |Normal phase table above uses actual CPU ce_cpu. Turbo actual CPU is ce_pix; raw ce_cpu must be reported separately because it still clocks other production domains. |
|11 |First VDP distance |Normal table above. Turbo reference/LOAD relevant schedule has first VDP four clocks after the quiet release edge. |
|12 |First pixel distance |Normal table above. Turbo first pixel/actual CPU enable is nine clocks after the quiet release edge. |
|13 |First sprite distance |Normal table above; turbo one clock. sp64=0 evaluator uses ce_vdp; ce_sp remains observed as an actual production output. |
|14 |Phase sweep |All four normal-speed quiet phases compatible with this saved beam, plus duplicate27 repeatability. Not a complete natural LOAD/transport sweep over every modulo30 phase; stopped after confirmation plus discriminating control. |
|15 |Status positions |Early21/23 group x51/102/153; late27/29 matches reference x53/104/155. Turbo C request sequence remains x28/62/96/130 vs reference26/60/94/128. |
|16 |Collision/overflow |Two-sprite phase cases change collision/status-clear observation, not the underlying sprite source. No overflow in this two-sprite control. Nine-sprite overflow transport defect remains independently retained. |
|17 |A/RAM |Early phase cases each6 post-pixel A and6 C100 differences; late phases zero. Full turbo source preservation still leaves guest differences, quantified in results.json. |
|18 |Common-phase control |Complete:9999 native clocks with zero clkd/all-five-enable/beam/sprite differences. Still9 collision /6 status-bus pixel differences; A/RAM differ420/750 native clocks. C is a preparation-ordering failure even with full common phase. |
|19 |Phase-only perturbation |External DDR timing only; five equal images, identical raw sprite traces, four actual legal release phases. Both early and late families independently reached naturally. |
|20 |CPU/VDP order |Early phase25 CPU/VDP tick precedes the next pixel; late group reaches pixel phase0 before next CPU phase10. Distinct from LOAD's synthetic T1/T2 running alongside post-T VDP. |
|21 |SAVE-only freeze prototype |Its explicit frozen overflow branch hold is independent of divider phase while frozen. Full SAVE-only replay is nevertheless coupled to G10: even with that guard and identical source, early normal phases alter status/A/RAM. Original nine-sprite guard pass is retained at its original turbo phase, not called an exhaustive new nine-sprite phase sweep. |
|22 |G06 sufficiency |Full diagnostic record reproduces source/cache/shifters/delay for the tested suffix. This is neither a minimal-state proof nor a first-visible-line/all-mode proof. CPU/VDP order must be corrected before those G06 fix validations can establish closure. |
|23 |Equal-v13-image attempt |Positive natural SAVE-only pair above; complete12288-word equality, known words, identical P/config/future guest inputs. Default versus forced turbo LOAD is an explicitly artificial phase control, not a naturally reachable positive LOAD pair. No stronger LOAD non-injective claim. |
|24 |G10 guest divergence |Actual IN-driven A and guest-written RAM change with external transport timing alone. The positive proof needs no CPU DIRSet or sprite restore, excluding historical T1/T2 as its cause. |
|25 |Historical clkd required? |Not established. Identical historical phase25 already produces divergent releases. Five literal phase bits could preserve full modulo30 phase, but necessity/minimum state needs a canonical protocol proof; saving clkd alone does not finish CPU preparation ordering. |
|26 |Canonical alternative |Needs coherent post-T domains plus completed historical CPU preparation, then deterministic full-domain enable ordering. One arbitrary global quiet phase is not sufficient without relating it to the captured boundary. See architecture assessment. |
|27 |G01 |Canonical prefix/EI/NMI CPU semantics remain valid and unchanged; CPU-only reference alignment does not establish global beam coherence. Current terminal LDIR sanity passes three LOADs/36403 comparisons. |
|28 |F12 |Current logical host Pause remains external. Capture-only bounded-progress exception stays before T. Selected paused non-M1 case passes: overrideCPU7/PSG5, one transfer,2552454 comparisons. No LOAD pause policy is changed here. |
|29 |F16 |Capture-edge NMI sanity passes three LOADs/18403 comparisons, normalized100 and handler count1. Future design must retain settled GG, later DIRSet-safe metadata installation, held sampling and historical fetch semantics. |
|30 |System E/turbo |Both VDPs and both PSGs need one coherent guest timeline. Turbo/System E CPU uses ce_pix while PSG paths retain ce_cpu; modulo10 agreement does not prove full modulo30 agreement. No initialized dual-VDP/audio/encryption matrix is claimed. |
|31 |G06 ownership |PARTIALLY BLOCKED BY G10. Freeze remains CONFIRMED - TEMPORAL FREEZE FIX REQUIRED. Original discarded sprite source still needs a proven minimal correction; broad restore-state closure is not granted to the ceiling prototype. |
|32 |G10 classification |CONFIRMED - FIX REQUIRED for transport-selected relative enable phase. Shared post-T-domain advancement during CPU preparation is a separately identified release-coherence requirement; do not equate it with five missing divider bits. |
|33 |Next architecture |Coupled G06 freeze/source correction and deterministic coherent prepare/release. Evaluate historical phase vs reconstruction/canonical phase before choosing payload; no implementation here. |
|34 |New runs/cases |Thirteen completed runtimes: nine initialized VDP runs (two references, default turbo LOAD, five normal SAVE-only phase cases, explicit full-phase LOAD control) with11000 native-pixel observations, plus four selected sanity runs. No aborted functional runtime. Compiler/pre-run working-directory setup mistakes are not runtime cases. |
|35 |Limits |No all-mode/minimal G06 representation proof, first-visible-line matrix, full natural LOAD phase sweep, enabled IRQ, dual initialized System E, PSG/mixer samples or physical ROM/decryption claim. Positive phase pair is SAVE-only. Unused X cache values are diagnostic only. Stop rule applied after confirmed guest divergence and its discriminating control. |
|36 |Production/v13 |All203 baseline regular tracked file hashes unchanged. Prototype remains only in test adapters. No Quartus, fix, staging, commit, push or PR. |
|37 |git diff --stat |Empty tracked diff; no staged diff. New test evidence is untracked. |
|38 |git status --short |`?? tests/`. The tests tree predates this task. Only this new investigation directory was authored in this task. |

## Conceptual architecture assessment for the next task

These are alternatives, not implemented prototypes. All must preserve ordinary non-savestate timing, bounded liveness and the current logical-host-Pause contract.

| Option | Correctness and state/format | CPU/beam/Pause interactions | Audio/System E/turbo, liveness and likely cost |
|---|---|---|---|
|A save/restore clkd |Literal full phase needs5 bits; CE outputs are derived but a correct falling/rising-edge installation protocol must preserve their meaning. Would require a future tagged format change if serialized. Repairs a historical-phase mismatch only when capture/restore phase conventions are exact. Does not by itself prevent post-T beam advancement during synthetic fetch. |Relate pre-T CPU and post-T beam captures explicitly. Preparation must finish without advancing captured domains. Preserve Pause and NMI sequencing rather than issuing ordinary guest ticks under a paused UI. |Full modulo30 relation matters for /10 CPU versus /15 PSG. Both System E chips share phase. Small register/mux cost, no memory block inherently required; clock/update timing and handoff carry more risk than bit count. Bound preparation and phase wait. |
|B normalize to one canonical phase |Zero extra saved bits only if every accepted state can map to an equivalent continuation at that phase. The early/late pair disproves arbitrary quiet release. Merely selecting the same phase for every image need not respect which tick was already consumed at T. |G01 canonical CPU state must be ready when post-T VDP resumes; do not redefine T. Need constructive boundary-to-canonical mapping for normal/turbo/Pause. |Normalize full cross-domain relation, not modulo10 alone. Bound waiting to a finite divider period after preparation; prove audio peripheral capture conventions and both chips. Small gates/FSM, no expected RAM. |
|C hold selected domains during preparation |No new historical bits necessarily; new transient prepare/release handshake may be needed. Can address the proven synthetic-fetch/post-T overlap, but still needs phase reconstruction or normalization for SAVE-only. |Keep post-T VDP/video and applicable peripherals held while CPU reconstructs historical fetch, then release at the proper continuation phase. GG/NMI installation and actual memory ownership/setup must remain correct. Historical reconstruction must not execute new ordinary guest instructions or consume new external events while logically paused. |Both VDP/PSG domains must obey the same logical boundary; identify what is historical CPU setup versus new peripheral execution. Normal-rate setup preserves memory timing. Bounded two-enabled-step reconstruction plus a bounded phase wait is plausible under production WAIT/BUSRQ defaults; prove it. Small control/mux cost; no payload implied. |
|D derive phase from saved CPU/beam |Potential zero payload, but beam alone does not identify a general divider history after video restore or under every cadence/configuration. Need a uniqueness/equivalence proof across accepted phase classes; this task does not provide one. |Use the actual accepted CPU event class and post-T beam convention, not a guessed x modulo. Prefix/EI/NMI metadata already supplies CPU decode context, not clock-tree phase. Pause can stop CPU while beam runs. |Check PAL/NTSC/height/turbo/System E and PSG capture timing. Low hardware cost if a valid formula exists; otherwise insufficient regardless of passing this witness. Derivation must not add an unbounded capture search. |
|E deterministic prepare plus boundary-relative release |Recommended design direction: separate historical CPU reconstruction from guest continuation, and encode/reconstruct only the minimum phase distinction necessary for the boundary. Exact new-bit count/format impact remains a design proof obligation. |Combines coherent preparation with an explicit T-plus release contract; preserves G01/F16 instead of changing the ISA normalization or dropping leading mismatches. Keep F12 current UI semantics. |One protocol for both VDPs/PSGs and normal/turbo; assess independent audio divider restore ordering without reopening mixer-state research. Likely bounded FSM/gates and perhaps a small phase field. No speculative block RAM or synthesis claim. |

The positive pair proves a release protocol must change even for SAVE-only. The LOAD control determines separately whether full phase alignment removes C. Thus “serialize clkd” is not an established complete architecture, and neither G06 source serialization nor local freeze gating alone is a complete coupled fix.

## Reproducibility and stopping

VRAM/CRAM and guest ROM match the retained original witness: both physical16KiB banks explicitly initialized; SAT3F00 Y167 and X120/tile0, plane0 FF, other planes0, nonuniform background and all32 CRAM entries. R0..R10 are04,40,0E,FF,00,7E,04,03,05,00,FF. Guest loop008B executes IN A,(BF), LD(C100),A, JP008B. IRQ is disabled. There is no random seed or varying guest input. ROM bytes are retained in rom.hex/rom.json and the exact pattern generator is in vdp_tb.sv. The only force in ordinary transport fixtures bypasses UI cooldown; CPU/bus/beam acceptance is natural. The explicitly requested common-phase control alone writes clkd at LOAD release.

The phase-only positive pair establishes enough evidence to design a separate fix. No broad additional G10/G06 matrix, production change or unrelated investigation follows it. Already selected discriminating common-phase and protected sanity cases finish; missing broad proofs are recorded rather than mislabeled passes. No G02-G05, G08, G11-G12, F01 or F06 disposition is changed.
