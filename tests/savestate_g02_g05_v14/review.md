# G02–G05 investigation on committed v14

G05 is **CONFIRMED — FIX REQUIRED**. A real-CPU text-to-Mode4 sequence exposes background history that v14 does not contain. G02 is **CLOSED — JUSTIFIED BOUNDARY EXCLUSION**; G03 and G04 are **CLOSED — PROVEN RECONSTRUCTABLE**, subject to the production accepted-boundary/current-input contracts stated below. Their evidence is independent of the G05 counterexample.

This is an investigation. No production RTL, v14 format, or earlier closure report was changed. G08.release remains OPEN. No conclusion about G08, G11–G12, F01 or F06 is made.

The numbered items below follow the requested 45-item report. [results.json](results.json) contains canonical run dispositions, exact parameters, source identity checks, image hashes and reference coverage; [coverage.md](coverage.md) gives the per-run boundary and restart observations. [pair_metrics.json](pair_metrics.json) independently compares complete images and reference futures. Earlier investigations supply context only; all closure evidence below uses fresh current-baseline simulations or current-source consumer proofs.

## 1. Current committed HEAD

`58583189b5c650dc6658ef467e8dcb72d9f6e6c2`, on `investigate/savestate-g02-g05-v14`. The original HEAD and SHA256 of every regular tracked file are retained in [baseline.json](baseline.json).

## 2. v14 G06/G10 baseline

HEAD is “Fix deterministic CPU and VDP savestate restart.” The actual controller writes tag `48430e`, descriptor `12aa0e0047365231`, saved phase/ownership/consumed-T metadata and both sprite records including the fourteen collision-delay bits. Current CPU preparation, VDP hold, phase commit and beam release are exercised, rather than replacing them with a testbench delay. All nine prerequisite reports were read; historical v13 G02–G05 results are not closure evidence here.

## 3. Exact restart assumptions

See [restart_assumptions.md](restart_assumptions.md) and [consumer_proofs.md](consumer_proofs.md). Accepted SAVE is a normal `M1/MREQ`, `ISet=00` fetch in VBlank with raw x<256. CPU architecture/context represents pre-T; accepted T executes normally; VDP/sprite/beam represent post-T. Freeze begins immediately after T and ARM collects that held device state. Metadata restore and private historical CPU T1/T2 preparation occur while both VDPs remain held. State105 prepares the CPU; state106 installs the saved divider phase at a falling edge, then restores saved beam/releases on acknowledgement. Next falling edge is logical T+1.

| Saved phase | First raw ce_cpu | First ce_vdp | First ce_pix | First ce_sp |
|---:|---:|---:|---:|---:|
|0|10|5|10|2|
|10|15|5|10|2|
|20|5|5|10|2|
|25|15|5|5|1|

Distances are host clocks after canonical release. Turbo/System E use ce_pix for guest CPU execution; private replay uses the production /15 CPU enable. Every integrated DUT checks the first sixty host clocks against this contract. The HL case logs actual first CPU/VDP/pixel/sprite events: e.g. ordinary phase10 resumes VDP at5, pixel at10, CPU at15 with MC1/TS3 and no I/O/write; phase25 resumes pixel/VDP at5 and sprite at1. Subsequent normal ROM fetch/VDP I/O are compared through full CPU state and actual T80s input sampling. The native collision witness compares every first resumed host clock, including the first VDP progression, not just eventual frame hashes.

## 4. G02 inventory

`reset_flags` is one Boolean, reset true, set by qualified status read and consumed/cleared on a VDP enable. Bit103 is captured in each architectural VDP record, but LOAD normalizes it false. Its first potential consumer is the first resumed VDP status/IRQ update; a subsequent IN or interrupt is the architectural observation. It holds through freeze once pending effects drain. Full reset/capture/restore/freeze/consumer columns are in [state_inventory.md](state_inventory.md); exact current-source declarations/assignments/consumers are in [inventory.json](inventory.json).

## 5. G03 inventory

`old_RD_n`, `old_WR_n`, `old_WR_direct`, `old_HL`, `data_write`, and `xram_cpu_A_incr` are one bit each; `cpu_write_data` is eight. Bus-edge latches prime from live inactive bus levels; write-data primes from D_in; pending write/increment normalize zero. `old_HL` samples the current input every host clock. An additional omitted eight-bit `D_out` latch was included because it participates in read observation. Architectural address/address_ff, pending-read field, read-ahead data, HCounter and GG low-byte CRAM latch are serialized. Detailed widths/reset exceptions and first consumers are in the inventory. After the accepted-boundary drain proof, stale write-data and old D_out are overwritten before observation; edge latches are normalized and HL is reconstructed under the retained current-input contract.

## 6. G04 inventory

`xspr_collide_shift[13:0]` is **SERIALIZED in v14**, in each 4778-bit 64-slot sprite record. This supersedes the historical zero-normalization premise. `IRQ_n` is a registered one-bit output reconstructed from saved flags/mask/delay. `last_x0` is one bit, primed from live beam and overwritten on the first resumed VDP enable. Only x485/x486 consumers use that parity history. Width/reset/hold/application/observation details are in the inventory and the exact reconstruction proof below.

## 7. G05 inventory

The ordinary background pipeline includes tile_index9, x8, tile_y3, palette/priority/flip latches1 each, datac8, four data planes8 each, four shift planes8 each, and registered VRAM address14. Text adds tile_index8, pattern8, shift6, phase3 and column6. Their restore/reset and first fetch/pixel consumers are listed individually in the inventory. None of this history is in v14. LOAD clears most fields; normal per-line fetching can refill the currently active pipeline. **Ordinary data/shifters hold while text is active**, and later mode selection can consume them before replacement. The measured differing planes are demonstrably future-relevant. This report does not claim every omitted bit needs serialization or select a minimal new payload.

## 8. Initialized deterministic fixture

Real production VDP, video timing, T80/T80s, controller, vendor VRAM and production CRAM are compiled in ModelSim. Test copies add read-only audit/probe ports and direct entity bindings; the controller adapter only relocates forward declarations for the simulator and supplies its established TB_FAST option. [collect.js](collect.js) checks those source equivalences against current RTL. Probes never drive guest state.

Both physical 16KiB VRAM banks and all32 CRAM entries are initialized with known nonuniform patterns. Rich rendering cases add nonuniform names, plane rows, attributes, flips, palette, priority and scroll. Sprite tables are initialized; relevant tests enable actual collision/overflow sources. Legal legacy LOAD initializes retained sprite history, followed where needed by a natural full frame. No unknown equality is accepted as image or architectural evidence. The sole force bypasses UI `op_cooldown`; no CPU, beam, pipeline or historical register is forced.

P and S run in separate independent reference/DUT simulations. The reference shares legal initialization P, then bypasses final freeze/phase/beam application and masks passive SAVE DMA ownership of its CPU VRAM port. It continues uninterrupted. The actual DUT uses real SAVE/LOAD transport. Registered RAM and CPU input sampling remain active. Other peripherals are fixed endpoints and work RAM/ROM are fixture models; the limits in item40 apply.

## 9. Modes covered

Stable rich-render reference/SAVE-only/three-LOAD runs completed for SMS Mode4, GG Mode4, text, legacy graphics2, the implemented mixed M2/M3 branch, and PAL240 Mode4. Mode4 uses170000 pixel samples per suffix (more than a complete NTSC frame); GG65000, text/graphics2/mixed42000, PAL24060000. Every completed rich suffix includes all256 x positions of line0 and line1. Graphics1, SMS224 and scroll-transition DUTs were stopped under the G05 rule; their references completed. The corrected separate mode-switch reference completed, but its corrected DUT was not launched. These are deferred coverage, not passing modes. Different System E background contents were exercised in status/bus/collision tests, not a full independent rich-render mode matrix.

The decisive text-history witness uses a real single-register switch back to Mode4 during line0. Raw legacy mode bits follow implemented RTL semantics; mixed M2/M3 selects the actual240-line timing, not an assumed192-line boundary. No mode/region Cartesian closure is claimed for G05.

## 10. PAL/NTSC

Both regions have current natural accepted-boundary scans; PAL240 and NTSC rendering windows cross frame boundaries. G02/G03 drain latency depends on the shared /5 VDP and minimum /10 CPU cadence, not vertical region. G04's fourteen-bit transition and interrupt-consumer ordering share that cadence; the region-specific beam/flags/delay are serialized. These source equivalences reduce the G02–G04 matrix. They do not justify excluding inactive background history in G05.

## 11. 192/224/240 lines

Natural references cover all three. Completed repeated-LOAD rendering covers192 and240; SMS224 LOAD completion is deferred after G05 confirmation. The boundary/status/IRQ ordering arguments are height-independent because height changes flag/event conditions, not the pending-operation lifetime, saved architectural conditions, or first CPU interrupt consumer. GG cropped blank y168 is explicitly tested: it is not assumed to eliminate sprite/status work.

## 12. System E

Two actual VDP instances have distinct VRAM, CRAM, sprite coordinates/planes and status histories. Current tests exercise independent status reads, read/write bus routing, collision/status and direct writes with each owner, plus three LOADs. The consistent primary direct fixture records mapper ownership bit5=1; secondary usesbit5=0. Direct writes use distinguishable neighbors A5/6C and count actual guest write assertions separately per device. The corrected collision case has primary Y191/X120 and secondary Y191/X40, with different planes/palettes. The enabled IRQ fixture uses production CPU IRQ routing from VDP2, not an AND approximation. Its DUT sees2310 host clocks with differing VDP IRQ pins and handler RAM02; the independent reference counter changes1→2. Both records remain held during preparation. The same VDP entity and the separate records support G02–G04 routing equivalence. Full System E background-mode transition coverage is deferred with G05.

## 13. Accepted-boundary coverage

[coverage.md](coverage.md) retains requested/accepted positions, raw CPU fetch/CE phase and post-T ARM values for each canonical completed DUT. Full logs retain preceding real I/O and controller/preparation transitions. Requests include early/late blank x40/80/100/120/248/250, actual I/O-edge requests and requests crossing a line before acceptance; requested position is never substituted for accepted position.

Eight earliest bus-operation captures accept the intended next fetch exactly: PC0208 atx219/y169, 020C at55/168, 0214 at91/168, 0218 at109/168, 021A at120/168, 021F at144/168, 022E at211/168, 0232 at229/168. Preceding I/O assertion and pending state are logged. G04 captures near collisionx131/y168 and late x254/y168; post-T pending64 beam isx132. The G05 equal-image pair is post-T x124/y192. No arbitrary capture edge is installed.

Natural scans cover885 ordinary and1325 each turbo NTSC/PAL eligible fetch observations after first blank, with zero pending-clear/increment/write at those boundaries. They are prospective eligible fetches, not thousands of full SAVE transfers. Runtime metadata and first-enable assertions exercise the supported phase union0/10/20/25; source ordering handles intermediate request positions before acceptance.

## 14. Transport-duration coverage

Current bus suffixes were replayed with no busy, deterministic transaction-qualified DDRAM_BUSY (83/97 clocks), and transaction-qualified LFSR busy (13/16 states). Both stalled cases pass SAVE-only and all three LOADs. Their complete known images equal the unstalled clone case byte-for-byte. The full900000-clock LOAD flush also passes all three LOADs with the same image/suffix. A nonzero collision-delay witness separately repeats with long stalls and every-host-clock timing comparison. Durations and hashes are in items23/34 and coverage.md. G05 is characterized with unchanged normal transport; broad background stall variants were deferred after confirmation. Its missing-history pair already rules out a mere transport-latency reconstruction explanation.

## 15. G02 status-clear experiments

Real T80 status IN loops run with collision, overflow, frame status, ordinary/turbo cadence, line IRQ, and both distinct System E devices. The line-IRQ case first runs a full frame to reload line count0, then compares5000 pixel samples and three LOADs while the actual handler counter changes106…115. This is genuine handler activity during S; shorter IRQ-enabled controls alone would not establish that. System E frame IRQ similarly changes its handler signature. Actual T80s TState2/CEN DI_Reg samples (including wait samples), CPU230, VDP136, IRQ and guest signature agree. Collision/overflow flags and later clears agree independently of pixel differences. Prospective scans observe zero pending reset_flags at eligible captures.

## 16. G02 non-injective search

Requests were issued around active status reads and their first subsequent eligible fetch; scans inspected pending-clear state. No post-T pending true state was observed. More decisively, bit103 is in the complete image, so distinct post-T reset_flags cannot make equal images. A pre-T true value consumed at T belongs to the captured post-T state, not omitted history.

The current-source boundary proof closes the absence question: detecting and consuming a read-generated pending clear takes at most two /5 VDP opportunities (10 host clocks), while completion of the I/O transaction and reaching an eligible following normal fetch takes at least two fastest CPU opportunities (20 clocks). No new I/O may interpose at that normal fetch. Reset-generated pending state drains before active-session capture. Paused seeking cannot shorten this physical drain interval. Details and source consumers are in consumer_proofs.md; failed search alone is not the proof.

## 17. G02 classification

**CLOSED — JUSTIFIED BOUNDARY EXCLUSION.** Normalizing reset_flags=false cannot discard an outstanding status-clear event at this production accepted boundary. Different flag origins and vertical geometry do not lengthen that pending event's lifetime.

## 18. G03 bus-history experiments

The initialized real T80 bus program performs control setup, partial control words, VRAM writes to distinctive neighboring addresses, VRAM read setup/read-ahead/next read, GG CRAM low/high writes, auto-increment, status reads and RAM signatures. The eight targeted requests capture the earliest intended next fetch after each named operation. Separate clone-enabled and ordinary bus paths, System E devices, and both direct owners pass. The HL/HCounter witness uses actual IN41 and identical future HL pulses at logical pixels5/78; fresh SMS/GG F07 boundary/priority tests also pass.

The additional memory_events witness observes actual RAM write inputs without replacing vendor memory. It compares the ordered physical guest-write event stream, a shadow of all32768 VRAM bytes updated by actual initialization/guest/restore writes, and all32 entries of the actual production CRAM snapshot against an independent uninterrupted reference at the end of SAVE-only and each LOAD suffix. The shadow's CRAM image is also checked against actual CRAM. This supplements architectural read-ahead/address and guest-read comparisons; it is not a claim of scanning every physical RAM output directly.

## 19. G03 exactly-once results

All completed bus/direct/earliest-I/O suffixes agree in full VDP address/control/read-buffer record, actual consumed IN count/value, CPU architecture and guest signature, including the next transaction. Direct fixtures additionally compare actual per-device write counts, preventing same-value duplicates from hiding behind final contents. memory_events passes all four suffixes with the same12 ordered actual physical write events (8 VRAM,4 CRAM), all32768 VRAM shadow bytes and all32 actual CRAM entries matching the independent reference. No duplicate/lost write or increment, stale sampled read, address skew or phantom post-LOAD bus transaction is observed.

The universal ordering argument is separate from these finite tests: data_write drains in one host clock; the longest named queue (read-address setup, read pending, then increment/read-ahead) drains within three VDP opportunities,15 clocks, before the conservative20-clock following-fetch bound. Serialized partial-control/address/read-ahead/CRAM-latch state survives. At the capture/private fetch the VDP-facing bus is inactive, so live-level edge priming cannot invent an edge. First genuine write replaces stale data before its write pulse is consumed. New read replaces D_out within5 clocks before T80s TState2 sampling at least one CPU period later. HL convergence/current input and saved-HCounter application priority are treated separately, not as a rewind of a physical input.

## 20. G03 non-injective search

A real omitted-state pair was obtained. SMS CRAM writes03 versusC3 produce the same converted architectural color, then sanitize CPU-visible state and reach natural accepted T with stale cpu_write_data still03 versusC3, data_write=0 and increment=0. Both complete12288-word known images match (decoded little-endian SHA256 `e1c049503552d76f22f9a0e30c31289b4c8507b794f0370aece6e279fc1754cc`). Capture is post-T x192/y192. Their1000-sample architectural futures are identical, SHA256 `96b9d75f3133308a3af6a829b811e1ec52a86f946689322e340a63eb3e1db044`; both SAVE-only and all six LOAD suffixes pass. See [pair_live](pair_live/) and pair_metrics.json.

This pair demonstrates an irrelevant stale value, not sufficiency by hashing alone. Pending-write/increment distinctions are excluded by the timing proof. An earlier pair converged write-data to0 during warm initialization and is explicitly not evidence of distinct omitted state. No arbitrary internal bus latch was forced.

## 21. G03 classification

**CLOSED — PROVEN RECONSTRUCTABLE.** This label includes safe normalization/overwrite before observation as detailed per field. It relies on the actual accepted normal-fetch boundary and current physical HL contract, with static pending-operation exclusion and independent current real-CPU/direct/memory evidence. It does not grant permission to capture inside an arbitrary I/O transaction.

## 22. G04 collision/IRQ experiments

Fresh current-baseline collision, near/noncollision, late-line collision, overflow interaction, status polling and IRQ cases all run independent reference/SAVE-only/three-LOAD suffixes. The near case separates the second sprite by8 pixels to remove overlap; the late case usesX248 and natural acceptance at254. Real enabled line and System E frame interrupt handlers test architectural interrupt acceptance. The production64-slot pending case confirms actual current packing rather than assuming a reduced fixture is bit-identical to production layout.

## 23. G04 exact logical timing

The pending64 capture contains nonzero fourteen-bit delay `3fc0` (audit `ff03c000`), and the flag transition agrees after LOAD. More strongly, g04_native compares beam, all fourteen delay bits, IRQ, CPU230, VDP136 and RAM on **every one of10000 resumed host clocks** per suffix, including the first; last_x0 must agree after the first VDP enable. SAVE-only and all three LOADs pass. The transaction-stalled native variant repeats those four10000-clock comparisons and passes with the same image SHA256 `a47956dc2580b442cd8471b551985c275b692e7a4cfdd1c9d1c95a2945520a22`. Each ordinary/stalled DUT verifies three pairwise-distinct pre-LOAD CPU+VDP histories, excluding beam-only differences. Thus the timing result is not eventual flag equality after an ignored restart window.

## 24. G04 non-injective search

Collision-shift distinctions cannot form equal complete v14 images because all fourteen bits are serialized. Accepted last_x0 is derivable from saved phase and post-T x parity: opposite for phases0/10/20, equal for25. Even though the reader primes raw beam parity, the first /5 VDP enable overwrites it long before its only x485/486 consumers; accepted post-T x<=256 is decisive.

IRQ_n may temporarily differ from its saved-flag formula if a delay just expired. Its first resumed VDP opportunity at5 host clocks establishes the correct pin before any CPU interrupt decision. Historical preparation is only T1/T2; the earliest first ordinary CPU step is T3, while a normal MC1 cannot complete before T4. An unchanged T80_MCode exhaustive combinational bound checks2359296 opcode/flags/ISet/XY/interrupt-input combinations and finds minimum4. This is a source-consumer lemma, not2359296 claimed reachable machine histories. Fresh actual-handler tests corroborate it. No guest-visible same-image G04 divergence was found; closure follows these serialization/consumer arguments rather than the absence of a searched collision.

## 25. G04 classification

**CLOSED — PROVEN RECONSTRUCTABLE.** The whole obligation includes its already-serialized delay field, an IRQ output reconstructed before first interrupt observation, and parity overwritten before its first consumer. No independent open child remains under the stated boundary. No G06/G10 contradiction appeared.

## 26. G05 initialized-render experiments

Stable-mode successes in item9 show that many ordinary line refills work, including Mode4 scroll/attribute/flip/palette/priority patterns and the text bootstrap. Pixel position/color and background fetch/palette/priority audit are compared against independent initialized reference, alongside CPU/VDP/I/O. Full-frame Mode4 and GG windows cross frame/line boundaries. Those successes do not prove future mode switches safe. A converged preliminary background pair is retained as a negative candidate, not falsely advertised as distinct-history evidence.

The decisive [text_history](text_history/) test has zero sprites, an actual64-slot production record, known nonuniform VRAM/CRAM and identical ROMs. After legal warmup, past controller input selects R9=0 or1 while Mode4 runs. At real VCounter190, a single R0 write enters text. R9 is then restored to0 in both histories while ordinary background planes hold. SAVE is accepted naturally at post-T x124/y192. Identical future controller input releases the wait loop; real VCounter0 triggers a single R0=4 write, selecting Mode4 atx24/y0. No background register or historical side record is installed.

## 27. G05 first-visible-line result

Both independent42000-sample reference futures have identical CPU230, VDP136, input sample values/counts and beam, yet differ in **seven visible RGB pixels**, first at sample23840, x25/y0: history0=`46f`, history1=`126`. The later mode switch consumes retained ordinary planes before the next ordinary fetch/load completes.

Actual v14 LOAD of each image corrupts **nine visible pixels on each of three LOADs**, with **eight fetch/palette/priority-audit differences** each time. First history0 LOAD mismatch is also sample23840/x25/y0: DUT=`50f`, reference=`46f`. Full CPU/VDP/I/O/beam assertions remain exact. These are actual rendered pixel differences, not merely a disagreement in an unused probe or a stale output before CPU sampling.

## 28. G05 subsequent-line/frame result

The counterexample runs42000 samples per suffix, including all256 pixels of line0 and line1; after fresh ordinary fetch/shifter load, subsequent sampled pixels converge. The counted LOAD mismatch window is nine pixels on line0, not permanent corruption. Stable Mode4 passes170000 samples per suffix, exceeding a full NTSC frame; GG65000 and PAL24060000 cover their first/subsequent visible lines. These longer successes cannot recover a previously lost inactive pipeline. Further broad dependent G05 runs were stopped when the equal-image divergence was established.

## 29. G05 legacy result

Stable text, graphics2 and implemented mixed M2/M3 completed all suffixes; graphics1's reference completed but DUT is deferred. The confirmed failure specifically crosses **text→Mode4**, with ordinary planes held during text. It is reachable through actual guest register writes and does not require an emulator-only mode toggle. Reverse inactive-text history and other mode/scroll latch transitions need review in a focused fix task; this investigation does not prematurely declare them safe or select which extra bits to save.

## 30. G05 non-injective search

Both actual complete known images have12288 64-bit words (98304 bytes), tag48430e, descriptor12aa0e0047365231 and phase word`0000000000000008` (phase0, running consumed-T=1, SMS). They are byte-identical:

- Hex-file SHA256: `46b00708a22371df71a5f6b2fba61dfdc0abc404ed159e3abf565cb25c3c1623`.
- Decoded little-endian image SHA256: `0ea3e9a697cdb342afbf9ffe0777413913b1e08c8fecb31f17a2382fa0a3baa4`.
- Captured VDP136, both: `00050f3e14d4c2403fcc27e0005ff1c280`.
- Retained shifts32: history0 `002fd0ff`; history1 `a04f701f`.
- Retained data32: history0 `4065ba00`; history1 `f4092e00`.
- Full read-only BG127: history0 `5020f7002032dd000017e87fd8795a93`; history1 `5020ff007a0497005027b80fd8795a93`.
- Independent architectural suffix SHA256, excluding the audit probe: history0 `15f4c22c8639dac7f8b842c33551e5dc93b06214f7f04096a5321f60e5c25ab9`; history1 `7acfc0a5188aa141894e5bbe141ed945d708c5c647201a9d8f4ad74af294bf03`.

Images are dumped only after SAVE-only transparency succeeds. [pair_metrics.js](pair_metrics.js) checks every word/known digit and computes hashes and reference differences independently. Equal complete images plus differing identical-input guest futures rule out reconstructing all needed history from v14. The 64-slot record and full container, not a truncated register hash, are used for this conclusion.

## 31. G05 classification

**CONFIRMED — FIX REQUIRED.** Lost inactive ordinary background data/shifters cause visible corruption when text switches to Mode4 before fresh replacement. Both missing-information and actual LOAD failure are demonstrated. A deterministic phase/reprime delay alone cannot reproduce both different reference futures from their identical image. No fix or format change is implemented here.

## 32. SAVE-only

Every completed canonical integrated DUT separately checks SAVE-only before using the image for LOAD tests. G06 overflow and collision witnesses pass. G05's two histories each pass42000 SAVE-only samples; only LOAD loses the hidden history. The independent line/frame IRQ and bus cases pass SAVE-only under their own strict CPU/VDP/consumed-I/O oracles. Deferred rich runs are not counted as completed SAVE-only proof unless their retained log establishes it; final canonical dispositions do not infer a pass from an unfinished simulation.

## 33. Repeated LOAD

Completed DUTs perform three LOADs of the unchanged same image after different natural running durations. G04 explicitly asserts pairwise-distinct CPU+VDP perturbation states. Direct/bus tests continue changing address/read/write and signature state; text-history perturbations include the visible mode switch and normal subsequent execution. Saved transport words must remain unchanged across LOAD. G05 reproduces9 pixel/8 audit differences on each of all six LOADs,252000 LOAD sample observations total, despite exact CPU/VDP/I/O. G02–G04 representatives have no architectural suffix difference.

## 34. Transport results

Bus clone, full-flush and both stalled profiles share decoded image SHA256 `aaf70fb12730f80361d3c7d8f60e1eb68a309b8560dcc9d08064e8b3be46e4dd` and the same logical reference suffix. Representative final SAVE freeze duration is151953 host clocks with deterministic busy versus50282 with LFSR; the three LOAD durations are155397/155442/155407 versus62907/62967/62707. Full production flush retains900000 clocks instead of the normal shortened simulation flush. The collision native/stalled images also match, with stalled SAVE151999 and LOAD155417/155372/155382 clocks; every-host logical suffix still agrees. No duration-dependent G02–G04 defect was found. The frozen/preparation device assertions exclude advancing VDP history to hide transport latency.

## 35. Guest-visible divergence

One production finding: G05 visible text→Mode4 pixels. It is independent of sprites (zero sources), CPU restart (CPU230 equal), architectural VDP restore (VDP136 equal), consumed port data (count/value equal) and divider/beam order (strict canonical first-enable/position assertions). Earlier observational pilot failures listed in item40 are not additional findings.

## 36. Complete-v14 collisions

Two useful natural distinct-state pairs are retained: G03 stale write-data03/C3 with equal image and equal future, and G05 retained ordinary background planes with equal image and differing future. Preliminary `pair` and `bg_pair` candidates converged before capture; they provide repeatability controls only. G02 pending-clear distinctions are either represented by bit103 or excluded at accepted T; G04 shift/parity are represented/derivable and IRQ is reconstructed before observation. Those are structural outcomes of each independent search, not fabricated pairs with forced internal values.

## 37. G06/G10 sanity

Fresh actual64-slot collision and overflow reference/SAVE-only/three-LOAD witnesses pass. Current sprite/control records hold through private CPU preparation; preparation rejects VDP I/O or writes. Canonical release restores exact beam and saved phase; first-enable contract is asserted in all integrated DUTs. Pending-collision native replay and full/stalled transports additionally test first resumed progression. No contradictory G06/G10 production evidence was seen, so their existing closures remain intact.

## 38. G01/F16/F12 sanity

Real current T80 restart metadata/private replay and full CPU230 comparison are used throughout, including enabled IM1 handlers. G01 CPU restart therefore receives targeted integration sanity. NMI is held inactive in this investigation and host logical Pause is not requested: no new NMI-edge or paused-capture experiment is claimed. F16/NMI and F12/current-Pause closures are retained; no instrumentation changes their wiring/order. F07/F11-related HL sampling receives the targeted tests described above. The G02–G04 consumer proofs explicitly preserve minimum CPU cadence and current-input priority, so they do not depend on silently restoring an old physical Pause/HL input.

## 39. Simulation runs/cases

Final canonical matrix: **108 rows**, comprising102 integrated reference/DUT rows and6 boundary-scan/component-lemma rows. **104 runs completed:**102 PASS and2 COUNTEREXAMPLE COMPLETED. Four rows are DEFERRED — G05 STOP RULE (three stopped current DUTs and one corrected DUT not launched). The integrated rows contain49 independent references and53 planned DUTs;49 references and49 DUTs completed, with47 passing DUTs and2 defect-characterization DUTs. The6 additional successful runs are three natural scans, SMS/GG HCounter component tests and one microcode bound.

These counts separate simulator invocations from suffixes inside a DUT. Completed DUTs check one SAVE-only and three LOAD suffixes, in addition to legal warm initialization; the two G05 characterizers are not counted as functional replay passes. Compilation jobs, retained superseded pilots and aborted infrastructure runs are excluded from the canonical completion count. The2359296 microcode combinations are one component lemma, not simulation-run inflation. Exact parameters/log hashes are in [coverage.md](coverage.md) and [results.json](results.json).

## 40. Evidence limitations and superseded pilots

This is a CPU/VDP/controller fixture, not a complete SMS top-level hardware signoff. ROM/work RAM and other endpoints are modeled; System E work RAM uses an8KiB alias for a16KiB transfer. Physical SDRAM/decryption, all memory topologies, audio/mixer, host UI Pause/NMI matrices and forbidden obligations are outside its claims. Actual64-slot cases establish production sprite packing and complete-image pair evidence; 8-slot protocol cases carry a padded opaque reduced record, **not** a bit-identical physical64-slot layout. No reduced record is used to prove the G05 full-image collision.

The actual memory observer logs physical write ports and actual CRAM; its VRAM content oracle is a read-only inductive shadow of writes to unchanged vendor RAM, supplemented by actual CPU reads/pixels. It does not claim an independent exhaustive physical readback of every vendor RAM location. Per-pixel CPU230/RAM-signature comparisons are not a full work-RAM hash each clock.

Important retained pilot corrections:

- A passive reference SAVE DMA originally stole the CPU VRAM port. Bus/reference runs were corrected and rerun with reference-only ownership isolation. Actual DUT transport was unchanged; early status-only witnesses did not use that port.
- A stale D_out comparison at initial RD assertion falsely labeled a mode-switch/IRQ pilot. The corrected oracle observes actual T80s TState2/CEN input consumption, count/value and full CPU/RAM. Old markers are superseded, not production findings.
- The mixed M2/M3 pilot requested192 instead of its actual240-line boundary. The corrected240 case completed. The earliest PC0208 pilot accepted correctly at y169 but an overly restrictive y168 assertion rejected it; the corrected exact-PC case completed.
- The old primary direct-owner metadata was inconsistent. The canonical `direct_consistent` primary and original consistent secondary were rerun/passed. Old primary logs are supporting pilots only.
- An immediate request during post-release settlement could be lost; requests now wait for actual ST_IDLE. This is harness request discipline, not a changed controller.
- Unconditional-BUSY bus/G04 reference pilots did not complete their first header state54 and were stopped. No production cause was established. The canonical transaction-qualified deterministic/LFSR profiles completed. Noncompletion is neither a pass nor a new production finding.
- Corrected broad graphics1/SMS224/scroll DUTs were stopped, and the corrected separate mode-switch DUT was deferred, under the G05 stop rule. Their unfinished/stale logs are explicitly classified separately. Subsequent G02–G04 work is independent of text/inactive background rendering.

Some generator scripts prepare initial fixtures and later infrastructure patches were applied by isolate_reference.js. Retained canonical sources/logs and their SHA256 are authoritative. Do not rerun a generator over evidence without preserving it; README provides direct compile/run instructions. ModelSim can return zero after a simulation fatal, so collection requires terminal pass marker, expected sample count, end marker and no error/fatal.

## 41. Production/v14 unchanged

All203 regular tracked files match their initial raw SHA256, HEAD is unchanged, tracked and staged diffs are empty. Test adapter equivalence checks all pass, including the additional read-only memory probe. Only new investigation artifacts under this task tree were authored. No production RTL or format change, Quartus invocation, staging, commit, push or PR occurred.

## 42. git diff --stat

```text
(empty)
```

Investigation artifacts are untracked, so they are not shown in tracked diff statistics.

## 43. git status --short

```text
?? tests/
```

The tests tree already contained untracked historical investigations at entry. This task adds only its own subtree and leaves prior reports untouched. Nothing is staged.

## 44. Overall recommendation

Record G02 as CLOSED — JUSTIFIED BOUNDARY EXCLUSION, G03/G04 as CLOSED — PROVEN RECONSTRUCTABLE, and G05 as CONFIRMED — FIX REQUIRED. Preserve existing G01/G06/G07/G09/G10 closures and G08.release OPEN. Do not call the whole savestate audit complete. The G05 failure is sufficient to stop dependent broad rendering closure work; stable-mode passes do not supersede it.

## 45. Exact next task

Authorize a **G05-only background inactive-history fix task**, beginning with the retained text_history equal-image witness. Establish the minimal ordinary/text/background history and exact accepted-edge capture encoding needed across legal mode switches, including the reverse inactive-text case and both independent System E VDPs. Determine payload/backward-compatibility requirements explicitly; do not assume v14 can reconstruct two different futures from one image. Then implement only the justified G05 change and prove reference/SAVE-only/three-distinct-LOAD equivalence for this witness, the deferred graphics1/224/scroll/mode-transition cases, implemented legacy/GG/System E modes, first/subsequent lines/frame and representative stalls, while retaining G06/G10, G01 and applicable F16/F12 ordering. No implementation is authorized or performed by this investigation.
