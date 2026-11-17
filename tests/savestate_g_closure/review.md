# Post-F16 closure audit of the twelve original G obligations

**G AUDIT CLOSED - REMAINING TARGETED PROOFS.** The accounting audit is finished; functional savestate coverage is not complete. Of the twelve original rows, nine remain OPEN, one is CLOSED by justified boundary exclusion, and two are SPLIT with explicitly open children. No additional defect or complete current-v12 non-injective pair was established. Absence of a new counterexample is not a completeness proof.

## 1–2. Repository and original baseline

Current committed HEAD: `faf7036e4450027f79cc639a731053dca29840ca`, “Preserve CPU NMI state across savestates.” Branch: `investigate/savestate-g-closure`. Original audit baseline: `8443a0d19a88aff7a5900011bccf386daf146945`, dated 2026-10-20. This investigation was performed on 2026-10-22.

The [original master report](../savestate_coverage/review.md) was read completely, including its PSG assessment, memory arithmetic, historical cross-check, feature answers and closure requirements. The original CSV, rather than the fourteen subsystem summary rows, defines the twelve-item universe. [inventory.json](inventory.json) preserves every original column, original row ID and stable G ID. Report/source/log hashes and repository checks are in [results.json](results.json).

## 3. Exact original G universe

| Audit ID / original row | Subsystem / exact original state | Exact original G rationale | Original risk / representation |
|---|---|---|---|
| G01 / S004 | CPU: `IR,ISet,XY_State,MCycle,TState,bus strobes,ALU pipeline` | Boundary normalization exists, but interrupted EI delay, block repeats and HALT require reference replay; do not equate register packing with CPU completeness | Instruction skipped/repeated or interrupt accepted differently; clean opcode fetch |
| G02 / S015 | VDP1/VDP2: `reset_flags` | Asymmetry is explicit; need prove no pending status clear survives accepted save boundary | P3 status/IRQ difference; bit 103 saved but deliberately not restored |
| G03 / S017 | VDP1/VDP2: `old_RD_n,old_WR_n,old_HL,old_WR_direct,cpu_write_data,data_write,xram_cpu_A_incr` | Priming is explicit, but old_HL also updated later unconditionally; pipeline completion at boundary needs proof | P2 phantom/lost IO side effect; live bus priming |
| G04 / S018 | VDP1/VDP2: `xspr_collide_shift; IRQ_n; last_x0` | IRQ recomputation checked; collision shift can have pending bits for y<234 even during VBlank; require phase-specific replay | P3 collision/IRQ timing; derived/reset |
| G05 / S019 | VDP1/VDP2: `tile_index,x,tile_y,palette/priority/flip,datac,data0-3,shift0-3,text pipeline` | Save is VBlank x<256; first visible line ought to refill, but blanking collision/IRQ and all legacy modes not proven | P2 first-line graphics or status; NONE; reset/reprime |
| G06 / S020 | VDP1/VDP2: `state,count,index,data_address,ce_spload,m2_flags,enable,spr_x,spr_d0-3,spr_color,spr_active,wideclock,shift0-3` | No full deterministic replay of sprite collision and overflow around chosen VBlank boundary | P2 sprite/status difference; NONE; scanner/shifters reset |
| G07 / S022 | Video: `vcounter_cpu_reg` | Formula inspected; restore occurs same edge as VDP mode restore, so derivation may see pre-load smode at transition; compare cross-mode loads | P2 off-by-one VCounter; derived from hcount/vcount and mode |
| G08 / S043 | AudioMix: `audio_l,audio_r` | Steady pipeline reconstructs; strict first resumed sample and FM contribution need integration proof | P3 first stereo sample; derived |
| G09 / S054 | Mapper: `reset_n_prev,bootloader_n_prev,mapper_wonderkid_prev,last_read_addr,eeprom_soft_reset` | Need prove priming avoids spurious handoff/reset and last_read_addr is diagnostic-only for current hierarchy | P2 mapping/reset transition; partial live tracking |
| G10 / S083 | Clock enables: `clkd,ce_cpu,ce_vdp,ce_pix,ce_sp,ce_snd` | Quiet release forbids active enables but does not prove unique relative phase; need whole-core cycle replay including turbo | P3 timing drift/first-edge ordering; not encoded |
| G11 / S085 | ROM/decryption: `registered decrypt result,madr,phase` | Likely refilled during long frozen flush, but CPU address/mapping transitions need reference proof for all encryption modes | P2 first opcode stale on encrypted System E; recomputed from restored address |
| G12 / S086 | Memory controller: `q,a,bank,data,sd_dat,wr,ram_req,mode,old_rd/ref,reset counter,ack flags` | SDRAM ROM contents immutable; prove last in-flight read and CPU release receive correct new mapping; DDRAM drain is a different bus | P2 stale first fetch; no machine-mutable RAM stored here |


These are S004, S015, S017–S020, S022, S043, S054, S083, S085 and S086, in original CSV order. S016 HCounter is F07, S005 NMI is F16, and S032 retained SRAM is F06: none is an additional original G row. Transfer and feature-summary obligations are accounted below without inventing G13 or renaming the original rows.

## 4. Post-F16 evidence map and validity

All counts below describe retained evidence, not new runs in this task. A fix report's historical READY TO COMMIT statement is superseded by current committed RTL. The older format version in a report does not invalidate unchanged local transition logic; it also does not prove the current reader or newly changed release sequence. F16's current-RTL regression copies supply the stated bridge to v12. They cover selected cases, not every historical matrix.

| Evidence | What it proves / relevant G | What it does not prove | Effect of later RTL |
|---|---|---|---|
| [F07 HCounter](../savestate_hcounter/review.md), direct SMS/GG and real dual-VDP DDR replay | Eight boundary latch tests, independent H1/H2 and legacy zero; useful G03 HL coupling evidence | G02 status clear, G04 collision/IRQ, G05/G06 rendering normalization, G07 early VCounter | VDP latch implementation retained. F11 added earlier TH settling; F16 current regression includes dual-VDP transport. Older isolated latch tests remain valid within scope |
| [F02 GG](../savestate_gg_io/review.md), 24 direct serial cases, actual IO/controller DDR replay | Complete 114 meaningful local protocol bits, baud/bit/error/pending/NMI paths, frozen hold and identical future link stimulus; relevant G01/G03 interactions | Physical peer rewind, arbitrary wall-clock traffic, global CE phase | F16 changed GG hold during CPU restart. Current F16 GG direct/DDR and actual GG/NMI replay validate selected integration cases; old release timing alone is insufficient |
| [F08 MD6](../savestate_md6/review.md) | 2,560 shortened and 160 production-timeout local cases; both ports; complete DDR, pending TH/type and save-only replay | G10 actual top-level generator, general CPU restart | Payload retained; F16 current real-time MD6 regression bridges current controller. Earlier exhaustive local logic coverage remains applicable |
| [F03/F04 EEPROM](../savestate_eeprom/review.md) | 6,642 local cases, full 128-byte backing, pending write exactly once, read refill, three DDR stall profiles, SD exclusion; supports G09 soft-reset pulse reasoning | All live SDRAM ROM reads (G12), all System E VRAM, F06 | Engine/backing semantics retained; current F16 EEPROM direct/DDR/persistence selected regressions pass |
| [F05 SC RAM](../savestate_sc_ram/review.md), [SRAM architecture](../sram_architecture/review.md) | Complete configured 2/16/32 KiB prefixes, tail canaries, byte endpoints, random DDR stalls, persistence; distinguishes owner from visibility | Disabled/other-bank Sega SRAM recovery, complete System E four-half VRAM coverage | SC path retained and current F16 60-case selected SC regression passes. F06 omission remains, not invalidated by SC success |
| [F09 Tap](../savestate_master_tap/review.md) | 4,096 short/64 production cases, 63 integrated cases including real-IO accepted pending TH, state/pin reference replay | G10 whole-core phase; arbitrary physical accessory rewind | Local logic retained, current F16 directed Tap replay passes; older broad DDR evidence is supporting evidence rather than a complete v12 rerun |
| [F10 paddle](../savestate_paddle/review.md) | 7,832 local cases including all 3,356 divider phases in both JP halves, full DDR/routing/combined Tap, accepted pending edges | G10 system enables or general CPU/VDP correctness | Local divider independent of CE generator. Current F16 selected paddle replay passes; broad legacy matrix remains historical |
| [F11 investigation](../savestate_lightgun/review.md), [fix](../savestate_lightgun_fix/review.md) | Naturally accepted save-only CPU divergence fixed; 61 full-load pairs, 1.3M-clock suffixes, omitted field convergence before hit, TH-before-HCounter ordering | Initialized VRAM pixel/collision/overflow equivalence for G04–G06; actual-T80 full LOAD proof for the gun | Current F16 direct/current-input and format/stall gun regressions pass. F16 deferred early gun clear for validation; old early-restore sequencing alone is obsolete |
| [F12 investigation](../savestate_systeme_pause/review.md), [fix](../savestate_systeme_pause_fix/review.md) | Current logical host pause retained; non-M1 seeking; 63 scenarios/85 transfers, dual real PSG and selected dual-VDP save-only; repeated LOAD scores first native enables | All dual-VDP initialized graphics, encrypted ROM transport, general dual-chip LOAD sample identity | F16 changes CPU preparation; current paused CPU/PSG replay passes. Authorized bounded-progress exception remains, not exact zero-execution paused-reference equivalence |
| [F13 investigation](../savestate_mapper_detection/review.md), [fix](../savestate_mapper_detection_fix/review.md) | 18-bit history, deadline ordering, false BIOS/Wonder Kid edge suppression, first/repeated LOAD mapped bytes, real T80; directly closes G09 handoff child | Does not establish `last_read_addr` is diagnostic; complete ROM SDRAM timing | Mapper_ctrl unchanged after F13. Current F16 directed banking and history/deadline regressions pass; old random mapper oracle remains stale/excluded |
| [F14 investigation](../savestate_evolution_selector/review.md), [fix](../savestate_evolution_selector_fix/review.md) | 57-bit history, candidate62 invariant, all bits, fallback/record/menu histories and actual CPU byte replay | F15 pending stage or entire BIOS boot/graphics | F15 added pending/freeze behavior, so F14 alone cannot certify operation timing. Current F16 selected selector and actual CPU tests pass |
| [F15 investigation](../savestate_evolution_pending/review.md), [fix](../savestate_evolution_pending_fix/review.md) | Three accepted flags, excluded drained switch_pending, old-M1 priming, exact launch count/timing, actual T80 three LOADs, save-only | Full-T80 identical whole-image collision; G11/G12 transport; all mode histories | F16 changed CPU restart. Current actual Evolution and directed pending replay plus v11 compatibility tests provide selected post-change coverage |
| [F16 investigation](../savestate_cpu_nmi/review.md), [capture contract](../savestate_cpu_nmi_capture/review.md), [fix](../savestate_cpu_nmi_fix/review.md) | v11 non-injectivity resolved by normalized three-bit v12 metadata; 174 exact LOADs, capture-edge/held/released pulse, all eight triplets, GG/DIRSet ordering, repeated LOAD and save-only | EI-delay masked IRQ, block-repeat restart, full HALT interrupt matrix, actual top-level CE, physical SDRAM | Current HEAD. No subsequent production change. Strong CPU evidence is narrow evidence for G01, not automatic CPU completeness |
| [Master PSG replay](../savestate_coverage/psg_replay_tb.sv), [current F16 log](../savestate_cpu_nmi_fix/regressions/savestate_coverage/psg.log) | 128 cases, eight noise controls ×16 divider phases, 2.56M future cycles, raw tone/noise/config/sample preservation | G08 AudioMix first resumed channel pair, arbitrary subsequent writes/sample playback, complete dual-PSG storage integration, FM | JT89 core unchanged. Current log re-establishes the same scoped result. Historical Contract-A mismatch is not a new current failure |

## 5. G01 — OPEN - NEEDS TARGETED PROOF

Original concern is instruction microarchitecture normalization, not just NMI. Current T80 serializes HALT, IFFs, WZ and architectural registers, but DIRSet resets MCycle/TState, IntCycle, prefix/pre-index context, No_BTR and auto-wait context. F16 now explicitly sequences T1 setup and historical T2 replay and restores normalized NMI history. That proves its tested instruction paths and NMI semantics, not equivalence for every discarded instruction context.

Independent dispositions: **EI delay OPEN** (EI was executed in F16, but no masked-IRQ acceptance/delay matrix); **HALT OPEN** for complete restart/INT/NMI/held-level behavior (F16 supplies positive NMI cases); **block instructions OPEN** (no LDIR/LDDR/CPIR/CPDR/INIR/INDR/OTIR/OTDR accepted replay found); **general restart OPEN**, with positive ordinary/prefix/NMI and Evolution witnesses. No new defect is inferred from a register being reset.

Minimum proof: actual T80 + current controller + independent uninterrupted suffix; EI followed by pending INT and distinct next-instruction side effect; HALT with inactive/INT/NMI transitions; block terminal/repeat/interrupt boundaries and observable RAM/IO effects. Sweep requests through instruction phases, ordinary/turbo/System E cadence, three Q histories and repeated LOAD. Compare active bus transfers, registers, writes and vector timing from historical T2 onward. For a collision attempt, use equal architectural register/PC/HALT/IFF captures with different discarded SetEI/IR/repeat context, then compare the **entire** v12 image. Such a naturally reachable complete pair has not been constructed here.

## 6. G02 — OPEN - NEEDS TARGETED PROOF

`reset_flags` is still exported at VDP bit103 and deliberately restored false. It clears status/IRQ on a later ce_vdp; calling it a one-cycle side effect does not by itself prove it is zero at every accepted boundary. F07 checks packing and latch reads; F11 uses gun/controller reads; neither supplies a complete status-IN-to-M1 exclusion proof. Minimum experiment: real T80 status IN followed by the earliest eligible SAVE, sweeping CE phase, ordinary/turbo/System E, both VDPs and enabled frame/line IRQ. Check pending clear at acceptance/ARM and next guest status/IRQ on save-only and repeated LOAD. Candidate collision is equal saved status/control with a consumed versus pending clear; no reachable complete-image pair established.

## 7. G03 — OPEN - NEEDS TARGETED PROOF

Bus history is primed and pending data/address increment is cleared on restore. `old_HL` subsequently updates unconditionally; F07 and F11 provide useful restore priority and TH-direction settling replay. Those results do not exclude a remaining write/read/address-increment pipeline at every legal capture. Evolution's capture_cpu_edges path also deserves explicit coverage. Minimum proof: real CPU data/control/CRAM OUT and VRAM IN immediately before accepted M1; full RAM state, read-ahead latch and first subsequent access versus reference, both VDPs/direct writes/clone edge capture. Compare write counts to detect loss/duplication. Candidate equal images with different pending write or increment remain unproved; arbitrary deposited pending values would not establish reachability.

## 8. G04 — OPEN - NEEDS TARGETED PROOF

Restore still zeros the 14-bit collision shift, derives IRQ_n from saved flags/delay and primes last_x0. Current code can consume collision bits when y<234 and x<=256; VBlank alone does not exclude that range. HCounter correctness does not establish collision latency or line/frame interrupt identity. Minimum proof: initialized sprites causing collisions and overflow through the first blank lines; sweep accepted x/CE phase, IRQ delays and status reads, PAL/NTSC 192/224/240 and both System E VDPs. Look for identical complete images with differing pending collision shifts and identical future input; otherwise prove the shift cannot matter before canonical refill. No such pair or new guest divergence established.

## 9. G05 — OPEN - NEEDS TARGETED PROOF

Background/tile/text/shifter state is reset/reprimed, not serialized. Architectural scroll registers and the separate horizontal latch [127:120] are preserved. This is coverage of the latch, not proof of the first subsequent row's fetch/shift behavior. Existing dual-VDP tests either focus on HCounter or compare uninitialized rendering fields; X===X is not initialized-pixel evidence. Minimum proof: initialized VRAM/CRAM, distinctive rows, scroll writes either side of latch, each implemented legacy mode and mode change, save during every relevant blanking phase, compare status and first visible pixels/addresses to reference through a complete frame. Candidate differing tile/shifter histories may be overwritten before use; no accepted non-injective pair established.

## 10. G06 — OPEN - NEEDS TARGETED PROOF

Sprite evaluator, arrays and shifters reset on restore. No report proves all collision/overflow and first-visible-line outcomes survive that normalization. Minimum proof shares G04/G05's initialized fixture, adding sprite limits, terminated lists, tall/wide/shift variants, legacy modes, line transitions and independent System E halves. Score collision/overflow reads and IRQ timing as well as pixels. Candidate identical architectural/VRAM images with different evaluator progress was considered, but natural accepted-state future relevance has not been demonstrated. Keep OPEN; neither VBlank nor a passing latch test closes it.

## 11. G07 — CLOSED - JUSTIFIED EXCLUSION

The original concern is old mode being seen by early-VCounter reconstruction on simultaneous VDP/video restore. In current `video.vhd`, only saved hcount486/487 selects a mode-dependent formula. The accepted predicate in `savestates.sv` requires x<256; ARM captures video one host clock later. Even allowing one pixel increment, saved x<=256. Neither early-transition value can be captured by this writer. At every reachable saved position in that window, CPU VCounter equals saved vcount[7:0]; the restore branch assigns exactly that slice without reading smode. Normal mode restoration settles before the next early-transition event. Thus an additional saved VCounter register is unnecessary for current naturally accepted images.

[video_boundary_tb.vhd](video_boundary_tb.vhd) compiles unchanged production video. It naturally advances 332,800 pixel iterations per configuration from initial counters, across complete frames: 64 PAL/border/GG/M1/M2/M3 configurations, 21,299,200 iterations total. It checks 3,987,950 reachable VBlank x<=256 observations and 77,609 restores at x0/1/254/255/256. During restore the DUT deliberately sees the opposite discarded mode; VCounter and all22 video bits immediately equal the held reference, and remain equal after mode settles. M4 has no video.vhd consumer, so duplicating it adds no state-space coverage. Static boundary/invariant reasoning supplies the exclusion; this finite simulation corroborates it.

This closes exactly S022. It does not certify G02–G06, corrupted externally edited x486/487 images, arbitrary cross-session configuration changes, or legacy states with an unspecified historical capture contract.

## 12. G08 — SUPERSEDED / SPLIT

The original rationale distinguishes steady reconstruction from first resumed sample and FM contribution; these now have different dispositions:

* **G08.steady: CLOSED - JUSTIFIED EXCLUSION.** AudioMix inputs are combinational signed sums with clipping; each clock writes one output and flips toggle. Two clocks with stable restored inputs reconstruct both output registers regardless of old outputs. Toggle is already serialized via audio descriptor020 and installed on the first resumed clock. Persistent output history is not needed for steady reconstruction.
* **G08.release: OPEN - NEEDS TARGETED PROOF.** Strict first resumed samples, not merely settled steady outputs, need actual PSG1/PSG2 → AudioMix → controller capture/storage/restore replay. F12 proves selected CPU/PSG pause/release cases; raw JT89 replay omits AudioMix; neither certifies every quiescent divider/toggle/input-change relationship.
* **G08.FM: OPEN - NEEDS TARGETED PROOF**, note **OPEN - BLOCKED BY F01**. Exact FM contribution cannot be replayed while OPLL state is unrepresented. No deep OPLL investigation was performed.

Minimum non-FM proof: both System E PSGs initialized differently, all16 divider phases ×both toggle phases, tone/noise/stereo writes including low-period playback, SAVE-only and repeated full-DDR LOAD with stalls. Compare every first resumed channel update and subsequent stereo sample, complete raw state, and synchronization assertion. A differing pre-capture output cache is only a candidate; without proving a guest-observable first-sample difference for naturally accepted complete images it is not a confirmed defect.

## 13. G09 — SUPERSEDED / SPLIT

* **G09.handoff: CLOSED - PROVEN BY EXISTING EVIDENCE.** F13 directly reproduces and fixes false Wonder Kid and BIOS handoff initialization, reconstructing trackers while mapper_restore_pending suppresses the following false edge. First and repeated LOAD restore mapped03 instead of00/02; actual T80 and directed post-F16 mapper regressions support current behavior. Mapper_ctrl has not changed since F13.
* **G09.reset: CLOSED - JUSTIFIED EXCLUSION.** RESET_n is current reset control, not a snapshot-restored historical level. Under the active nonreset session contract its history settles to1; mapper_set primes it. A genuine future reset remains a new reset, not an event to rewind.
* **G09.eeprom-pulse: CLOSED - PROVEN BY EXISTING EVIDENCE.** F03's inventory identifies the host-clock-cleared reset pulse; a prior mapper write cannot remain pending across accepted normal M1 and drain. Its actual wrapper/full-DDR replay covers partial transactions and perturbing reset histories, with current F16 direct/DDR/persistence regressions. The durable resulting EEPROM state is serialized, rather than the already consumed reset strobe.
* **G09.last-read: OPEN - NEEDS TARGETED PROOF.** Important correction to the original proposed exclusion: last_read_addr is consumed at mapper_ctrl's A000 write guard. It is not merely diagnostic. It is overwritten by ce_z80 memory reads and likely reconstructed by canonical fetch before any write, but that exact boundary/restore order needs proof, especially block transfers and changed mappings. No new defect is established.

Minimum proof: actual T80 A000 reads/writes and LDIR-like source/destination sequences with SAVE at each legal fetch, plus BIOS/Wonder Kid perturbation, comparing bank writes/physical ROM bytes across repeated LOAD. Candidate equal v12 images with last-read A000 versus another address must survive the mandatory fetch update and affect a subsequent write; no such pair was found by source-level reachability analysis, and no exhaustive replay is claimed.

## 14. G10 — OPEN - NEEDS TARGETED PROOF

The actual SMS divider runs on falling clk_sys, not on ss_freeze. Quiet release forbids active CPU/VDP/pixel/sprite enables but does not restore clkd. The new [phase test](phase_tb.sv) extracts the production process unchanged and reaches all30 phases naturally from a legal initial phase. Twelve phases satisfy the quiet predicate (mask28aa2a8a). Different permissible release phases can have different next-enable distances. This is an actual process simulation, not a complete top-level SAVE/LOAD replay; raw quiet candidates may be reduced by beam alignment or F16 preparation. Consequently phase multiplicity alone is not a defect proof.

Minimum experiment: production divider, video and current controller coupled to real CPU, initialized VDP and PSGs; sweep request/stall durations over modulo30, ordinary/turbo/System E CPU choices. Score relative first enables and guest bus/IRQ/pixel/audio traces from equivalent logical time. Seek naturally accepted equal complete images with differing unencoded phase and divergent identical-input future; validate both actual release paths before claiming non-injectivity. Existing fixtures that prescribe common future enables cannot close this obligation. `ce_snd` is declared but has no update/use found beyond its declaration; it is not an additional functioning oscillator to serialize.

## 15. G11 — OPEN - NEEDS TARGETED PROOF

MC8123 result is clocked from current data/key/address/M1; Sega decryptors alternate address capture and result computation with phase, plus downloaded immutable tables. Long flush can reconstruct stable-address results. It does not prove first post-restore opcode after address/mapping/M1 transition, particularly through live SDRAM. F13/F14/F15 synthetic mapped-byte tests do not instantiate both decryptor families with actual ROM transport. Minimum proof: production encrypted path and known fixture keys/tables for both Sega types, MC8123 and bypass; actual CPU canonical restart and first data/opcode reads after bank/BIOS changes, at each phase, normal/turbo/System E. Compare to uninterrupted first fetch and following instructions. Candidate differing stale result/madr/phase is likely flushed while address is stable, but no complete boundary/refill proof establishes every transition. No confirmed pair. Depends on G12's correct incoming data and G10's timing bound, not F01/F06.

## 16. G12 — OPEN - NEEDS TARGETED PROOF

This row is the **live SDRAM ROM controller**, not savestate DDRAM nor on-chip cart RAM. It latches address/bank at request start, detects read edges, progresses against clkref and returns a registered word/byte. Top-level rd_rdy is unconnected; correct bus setup is therefore material. DDRAM's32-clock drain and 900,000-clock flush do not by themselves prove a new mapped ROM request is issued and returns before T80's historical T2. F16 explicitly tests registered fixture ROM ownership and setup, not the physical SDRAM state machine/model.

Minimum proof: actual sdram.sv with a timing-aware chip model, production request generator/clock relation and real CPU restart. Start LOAD with each old in-flight transaction/byte lane and refresh phase, perturb bank/BIOS address, verify new request and correct first/last read data before fetch, ordinary/turbo/System E plus decryption. ROM contents and download tables stay fixed; initialization/download state is an external session prerequisite. Candidate equal v12 images with different old controller transactions must be shown to survive refill and alter actual consumed data; not established here. Do not classify this as F06 or close it with EEPROM DDR stalls.

## 17–22. Closure accounting

| Required account | Result |
|---|---|
| Whole original G rows closed exclusively by later F evidence | None. F13 closes G09.handoff; F03/F04 support G09.eeprom-pulse. F16 closes the separate F16 NMI family and supplies partial G01 evidence |
| Whole rows closed by justified exclusion | G07 only; G08.steady and G09.reset are additional closed children |
| Whole rows OPEN | G01, G02, G03, G04, G05, G06, G10, G11, G12 |
| Split rows with remaining work | G08.release / G08.FM; G09.last-read |
| Newly CONFIRMED defects | None; no item upgraded just because it lacks a replay |
| Solely F01-blocked | G08.FM child; primary status remains OPEN - NEEDS TARGETED PROOF |
| Solely F06-blocked | No original G row. SRAM completeness and final integration remain separately blocked by unresolved F06 |

Counts: 9 OPEN +1 CLOSED - JUSTIFIED EXCLUSION +2 SUPERSEDED / SPLIT =12. Every split child is accounted. NMI/mapper/accessory fixes do not make an original G disappear.

## 23–32. Subsystem and temporal conclusions

**CPU:** F16 NMI closed for modern v12 with documented legacy normalization and logical future inputs. EI delay, full HALT/block and broader restart remain G01. Tests running EI/HALT code are not interchangeable with testing their interrupt/repeat acceptance semantics.

**VDP:** F07 latch and scroll-latch representation present; G07 early counter exclusion closed. Status clear, bus increment/write completion, collision/IRQ phase, background and sprite normalization remain G02–G06. Both VDP instances inherit these concerns. Cross-mode rendering remains open even though old mode cannot influence G07's accepted restore branch.

**Memory:** F03/F04 and F05 have full-content, endpoint, repeated transfer and random-busy evidence. Range arithmetic and selected ordinary16KiB SRAM controls also exist. General WRAM/VRAM transfer remains a separate integration proof obligation: all four System E physical16KiB halves, independent bank select combinations, ordinary8KiB/System E16KiB WRAM, address-dependent/random patterns, canaries, exact transfer lengths, first/last/eighth-byte backpressure, delayed ready and no duplicate/missing commands. Existing EEPROM/SC randomized tests strongly exercise shared DDR handshake but do not establish every VRAM topology. Live SDRAM is G12; F06 is still the retained/inactive SRAM architecture defect. No new G ID assigned to the master's cross-cutting transfer requirement.

**PSG/audio:** keep the original COMPLETE WITH JUSTIFIED EXCLUSIONS verdict for raw modern oscillator/noise state. Do not reopen it. Quiescence assertion, late audio capture and selected F12 dual-PSG replay are positive evidence. Complete dual-PSG storage/synchronization, AudioMix first resumed samples and arbitrary subsequent writes remain G08.release/G10 integration work. FM exactness depends on F01.

**Controllers/peripherals:** F08–F11 local obligations have accepted-boundary/reference replay, frozen save-only and stored/restored state evidence as described in the map. F11 specifically proves omitted gun fields converge before the hit window. Those local temporal findings are closed; they were original F rows, not new G rows. Common input/CE/VDP/CPU timing remains scoped to G01/G03/G04/G10. No duplicate peripheral fix or generalized framework is warranted.

**GG:** F02 owns mutable emulated DDR/PDR/TX/RX/control, shift/counter/pending/frame/NMI/synchronizer history; F16 owns CPU consumption history and GG/DIRSet ordering. Both restore. The external cable peer, current pins and future host input are not rewound. Exact replay requires identical logical future pin sequences; an ongoing remote frame during wall-clock transport is not guaranteed. Excluding the remote environment does not justify excluding local synchronizers or endpoint state. GG BIOS bytes are immutable session media; mutable visibility is covered below.

**System E:** F12 Pause closed under the authorized current-UI contract, including bounded coherent CPU/PSG progress solely to reach capture. Second HCounter covered by F07, second PSG raw state represented; selected dual-chip pause/save-only replay passes. It does not close initialized dual-VDP LOAD graphics/status, every VRAM-half transfer, dual-chip CE/release, first stereo samples or encrypted first opcode. These map to G01–G06/G08/G10–G12 and the cross-cutting memory proof. No historical pause payload is required under the agreed contract.

**Mapper/Evolution:** F13 history and false handoff edges, F14 selector/predecessor/candidate/started history, F15 pending flags and launch timing have direct replay evidence. Candidate62 reconstruction and consumed switch_pending/launch/old-M1 exclusions remain justified within their validated accepted CPU path. New F16 restart has selected actual Evolution regressions. G09.last-read remains separate; complete CRC-download/BIOS boot and physical transport are not certified by mirrored synthetic ROMs. No speculative extra Evolution state is promoted to a defect.

**BIOS/media/config:** retain same immutable ROM/BIOS, key/table, cheats and relevant machine configuration precondition. A host BIOS replacement/download is a new environment, not a missing rewindable register. `bootloader_n` is serialized through mapper visibility (Evolution uses its defined active-cart interpretation); IO bit31 serializes cartridge disable; SC/PPI and System E selection latches have consumers. F13 fixes reconstructed BIOS/Wonder Kid edges; F14/F15 fix guest-written Evolution menu/launch history, which is emulated state rather than current host configuration. No additional mutable external-BIOS latch omission established. Actual first mapped fetch still depends on G11/G12. Do not serialize immutable media to bypass that proof.

**Protocol/temporal umbrella:** local GG, EEPROM, MD6, Tap, paddle, gun, host pause, mapper detection, Evolution history/pending and NMI map respectively to completed F02, F03/F04, F08, F09, F10, F11, F12, F13, F14/F15 and F16. Cart RAM selection maps to completed F05 and unresolved F06. Audio synthesis gap maps to F01; CPU restart to G01; VDP status/bus/collision/rendering to G02–G06; early VCounter to closed G07; mixer to G08; mapper read/edge history to G09; enable phase to G10; decrypt and live ROM transport to G11/G12. Shared full-memory DDR topology, storage ordering and final cross-chip replay remain explicitly named integration obligations, not hidden in the umbrella. Current input/remote peers/immutable configuration are exclusions with the limits above.

## 33. Post-F16 completeness matrix

| Subsystem | Current status | Resolved F | Unresolved F | Relevant G / remaining work |
|---|---|---|---|---|
| CPU | NEEDS TARGETED PROOF | F16 | — | G01; G10/G12 execution environment |
| VDP | NEEDS TARGETED PROOF | F07 | — | G02–G06 open; G07 closed; G10 timing; initialized dual replay |
| Memory | INCOMPLETE | F03/F04/F05 | F06 | G12 live ROM; full WRAM/VRAM random-stall topology proof |
| PSG | RAW STATE COMPLETE WITH JUSTIFIED EXCLUSIONS; integration open | Prior PSG fix retained | — | G08.release/G10; dual stored/restored first samples |
| FM | INCOMPLETE | — | F01 | G08.FM blocked by F01 |
| Mapper | NEEDS TARGETED PROOF | F13 | F06 affects retained backing | G09.last-read, G11/G12 first mapped fetch |
| EEPROM | LOCAL STATE/BACKING PROVEN | F03/F04 | — | No independent new G; shared G01/G10 execution environment |
| Controllers/peripherals | LOCAL PROTOCOL REPLAY PROVEN; global integration open | F08/F09/F10/F11 | — | G01/G03/G04/G10 for coupled observation; no duplicate local work |
| Game Gear | LOCAL ENDPOINT/NMI PROVEN; common machine proof open | F02/F07/F16 | F06 where applicable | G01–G06/G08/G10/G12; current peer-input contract |
| SG-1000/SC-3000 | CONFIGURED RAM PROVEN; common machine proof open | F05/F07 | — | G01–G06/G10/G12; legacy video modes |
| System E | PAUSE PROVEN; dual-machine coverage open | F07/F12 | — | G01–G06/G08/G10–G12; full four-half VRAM topology |
| Evolution | SELECTOR/PENDING REPLAY PROVEN; common timing proof open | F13/F14/F15/F16 | — | G01/G09.last-read where used/G10/G12; full boot integration |
| BIOS/media selection | VISIBILITY COVERED WITH IMMUTABLE-SESSION EXCLUSION; transport open | F13/F14/F15 | — | G09 closed handoff children; G11/G12 first fetch |
| Protocol/temporal | INCOMPLETE | F02–F05/F07–F16 | F01/F06 | All open G children and cross-cutting integration above |

No subsystem is called globally COMPLETE while a relevant G remains OPEN.

## 34–37. New experiments, divergences and non-injectivity

**Two new simulation runs**, both narrowly scoped after evidence mapping:

1. Production video boundary/invariant run: PASS, 64 configurations, 3,987,950 observations, 77,609 restore checks. This closes G07's old-mode concern by a static boundary exclusion corroborated by reachable-state replay. It is not 77,609 full DDR transactions or real CPU acceptances. The deliberately tested superset x<=256 includes every possible ARM position. Log: [video.log](video.log).
2. Extracted unchanged production CE process: PASS, all30 phases visited, twelve quiet phases. This rejects the inference “quiet implies unique phase,” leaving G10 open. No CPU/VDP/audio output is modeled in this probe. Log: [phase.log](phase.log).

The video run's shell exit is1 because ModelSim's std.env.stop invokes the do-file's onbreak quit-code-1 after its complete PASS marker. Both compiles and runtime report zero errors/warnings; audit.js independently requires exact counts and absence of Error/Failure/Fatal. This is disclosed, not concealed as exit0. Phase run exits0. No aborted/failed functional test is counted as a passing run. No old regression was rerun or counted as new here.

Reproduce from this directory with Node `prepare_phase.js`, then ModelSim `-c -do "do video.do" -l video.log` and `-c -do "do phase.do" -l phase.log`; run Node `audit.js` from any directory to validate logs, inventory and unchanged production/index. Video's documented stop/exit convention applies.

**New guest-visible divergences: zero. New naturally reachable identical complete v12 images with divergent future: zero established.** The open-item sections record candidate missing-state distinctions, whether fetch/flush can destroy them, and minimum discriminating experiments. This task attempted reachability/reconstructability analysis for those candidates and dynamically tested the two bounded questions above; it did not manufacture internal register values or claim to have completed full-image collision searches for G01–G06/G08–G12. Those searches remain part of the specified targeted proofs. No pair found is explicitly not evidence of injectivity. Existing v9/v10/v11 collisions are historical fixed F findings; they are not current v12 defects.

Further full-machine simulation was unnecessary to classify these remaining items OPEN: the relevant reports explicitly lack the required evidence and current source does not complete the exclusion argument. Building a large shared framework before that classification would exceed the narrowly scoped experiment policy. Each next experiment above can either demonstrate a reachable guest divergence or establish its particular exclusion/reconstruction; a negative finite sweep alone cannot close arbitrary reachable histories.

## 38. Remaining work queue, in recommended order

| Order / group | Concrete work | Risk, likelihood, dependencies and cost |
|---|---|---|
| 1 / A targeted proof | G09.last-read real-T80 A000/block guard test | Cheap and narrowly bounded; original diagnostic-only assumption is false. No RTL/resource cost for proof; any failure needs separate fix authorization |
| 2 / A targeted proof | G01 EI/INT, HALT, block and restart matrix | High guest-execution risk; reuse current CPU/controller harness. Local setup first, then actual CE coupling. F16 NMI coverage is retained, not repeated wholesale |
| 3 / A targeted proof | One initialized real-VDP fixture closing G02/G03 status/IO boundaries, then G04–G06 collision/render/sprite normalization | High likelihood of detecting meaningful discarded state; share VRAM setup but keep assertions per original G. Include both instances and legacy modes. Proof costs simulation time, no FPGA resources |
| 4 / A targeted proof | G10 actual divider/beam/controller release sweep | High coupling risk; use the now-established CPU/VDP scoreboards. Must distinguish phase-equivalent output from guest divergence. Any phase fix could affect broad timing and requires separate review |
| 5 / A targeted proof | G12 live SDRAM first-fetch/reissue timing, then G11 decrypt pipeline replay | G11 depends on correct ROM input and CE timing. Narrow timing-aware chip model, not a full commercial-game platform. Potential fixes may be small but carry clock/memory risk; none confirmed yet |
| 6 / A targeted proof | G08.release complete dual PSG/storage/AudioMix first-sample matrix, plus missing WRAM/four-half System E VRAM randomized transfer proof | Raw PSG remains closed. Reuse tested transport logic; assert complete data and first sample, not just metadata. No production cost unless a separately confirmed issue appears |
| B confirmed small fix | **Empty for newly discovered G defects** | Do not pre-authorize speculative serialization/format changes. If an A proof confirms a defect, add its bounded fix and rerun dependents before final integration |
| 7 / D F06 SRAM architecture | Resolve unknown-cartridge ownership contract; implement complete retained backing and compatibility/persistence behavior in a separately authorized task | Known correctness defect, policy dependency, broad media lifetime impact. Prefer cheap G proofs first; F06 is not a new G item. Require pre-first-use, disabled and both-bank tests |
| 8 / C F01 OPLL | Separately inventory/design/implement exact synthesis-state capture and replay | Known unresolved defect, deeper/invasive state and FPGA resource risk. Unlocks G08.FM. Can be scheduled after cheap high-risk G proofs; not automatically first. No deep investigation in this audit |
| 9 / A dependent closure | Close G08.FM with restored OPLL + actual mixer replay | Depends on F01 implementation, not needed to investigate pure PSG release. New resources/timing assessed in that fix task |
| 10 / E final integration/regression | Full mode/owner/size/bank and current/legacy matrix, all F/G witnesses, malformed input behavior, storage ordering and cross-chip release; final source/format identity review | After every simulation/RTL fix. Include System E initialized dual graphics/audio/encryption and GG identical-future endpoint tests; no claim of physical peer rewind |
| 11 / E final hardware | **ONE** hardware validation campaign after all simulation/RTL work is complete | Agreed policy. Exercise representative SMS/GG/SG-SC/System E/Evolution, accessories, first fetch/audio, persistence and legacy behavior. No intermediate hardware test is presently necessary |

Groups C and D retain their required labels despite recommended execution ordering. Proof work has no synthesized resource cost. Any resulting RTL fix must assess area/timing independently; current F16 fit leaves M10K pressure high, so speculative extra memories are especially unjustified.

## 39. Exact threshold for functional audit completion

The phrase “functional savestate coverage audit complete” requires all of the following, not merely completion of this accounting report:

1. Every F01–F16 family disposed: retain F02–F05/F07–F16 passing current-format witnesses; resolve F01 exact OPLL state and F06 retained backing architecture. If any is deliberately excluded, that must be an explicit revised functional contract rather than an undisclosed omission.
2. All twelve original G rows and every split child closed by a recorded reachable-state replay, reconstructability proof or justified boundary exclusion; resolve any newly confirmed defect and its replay before marking it closed. Current G07 exclusion must remain true after later acceptance/format changes.
3. Complete the independent shared DDR transfer proof across WRAM/VRAM/topologies, delays and first/last/eighth-byte boundaries; live ROM SDRAM and encrypted first fetch are separately proven. SD ownership and restored dirty behavior remain coherent.
4. Current full integration compares real CPU bus/IRQ, initialized VDP pixels/status, both PSGs/mixer/FM and peripherals at equivalent logical time, including save-only and repeated LOAD after diverse Q. Preserve the documented F12 bounded-progress and current-input/peer contracts.
5. Current-format inheritance and supported legacy paths have explicit tests and truthful policies: old files cannot recover missing history; malformed v12 rejected before guest writes; missing fields normalize only as documented; unsupported Evolution images reject before restore. Permissive old readers dropping new NMI history are not exact-v12 compatibility. Format consolidation, if separately undertaken later, requires its own compatibility proof.
6. Final simulations, source identity, synthesis/fit/timing for any separately authorized RTL changes, then the agreed **single final hardware campaign** all pass. No claim of an exhaustive physical-environment rewind or flip-flop equivalence beyond the stated contract.

## 40–44. Scope and repository hygiene

F01 was not modified or deeply investigated. F06 remains unresolved and unmodified. Production RTL and **v12 are unchanged**. No fix, format consolidation, Quartus invocation, new Quartus artifact, staging, commit, push or PR was performed. Only this audit/test/report directory was added. Earlier untracked test evidence was preserved.

`audit.js` verifies all75 tracked SMS/RTL/manifest files against HEAD with normalized text equality and records raw SHA256 hashes. It verifies empty tracked and staged diffs. `git diff --stat`:

```text
(empty)
```

`git diff --cached --stat`:

```text
(empty)
```

`git status --short`:

```text
?? tests/
```

The tests tree was already untracked before this task, so this status is not a claim that its entire contents are new. New reproducible sources/logs are retained here; disposable local simulator libraries/waves are excluded. This report is not a commit recommendation or authorization for a fix.

## 45. Overall conclusion

**G AUDIT CLOSED - REMAINING TARGETED PROOFS.** All twelve original obligations are accounted for. G07 is closed by accepted-boundary exclusion; G08/G09 have explicitly closed and open children; nine other original rows remain open. No new defect is confirmed. Functional coverage remains incomplete until the named proofs, F01/F06 work, final integration/legacy validation and one final hardware campaign are complete.
