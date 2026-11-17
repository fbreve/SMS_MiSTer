# Internal resource-cost audit: committed v19 savestate controller

The controller's 14,773 exclusive FFs are now reconciled to surviving register
names. **9,600 (65.0%) are the two sprite transport rings; 1,499 (10.1%) are
registered restore-data outputs.** Exact current ALM charges for those banks
cannot be recovered from hierarchy, mux or fanout tables independently.

**Decision: GO for one separately authorized, bounded CPU restore-output
bank experiment; STOP before implementation here.** Its target is the existing
230-FF `z80_dir` copy, with all snapshot information, bytes, validation and
strobes retained. No ALM saving is promised. Larger sprite RAM/shared-storage
conversions remain unqualified. Production, branch and HEAD are unchanged.

## 1. Verified baseline and provenance

Authoritative HEAD: `1b2a52d87d2659c908d4f9f846416d14bfd85bea`, “Preserve FM
sample state across savestates”. Existing branch:
`investigate/cram-memory-inference`. Format **v19**, outer tag **0x484313**
(`AUDIO_LAST_MAGIC`, `rtl/savestates.sv:458`), 96 KiB container. The committed
controller SHA-256 is
`e8de50db09447138fc661205fb9edd178d45e691819a056bad87631ef3d76557`.

[baseline.json](baseline.json) records all 204 tracked regular-file hashes,
the requested prerequisite reports and machine evidence, and all retained
build input hashes. All **137** build inputs match their original manifest;
**135** match committed HEAD with explicit CRLF/LF normalization. The other
two are unused `.bak`/`.orig` files, not alternate production sources. The
old build manifest's HEAD label predates the v19 commit; source comparison
establishes applicability, rather than that label. All six requested prior
reports are present and were consulted; historical v16/v17 recommendations
are treated as historical evidence, not current functional status.

Retained build: `tests/savestate_g08_fm/quartus_early`, Quartus Prime Lite
17.0.2 Build 602, Cyclone V `5CSEBA6U23I7`, SMS/sys_top, seed 1,
fixed BUILD_DATE261025 and MISTER_FB=1. STANDARD FIT, HIGH PERFORMANCE EFFORT,
SPEED, final placement ALWAYS, ALM register packing LOW, automatic register
packing NORMAL, physical optimization/duplication/retiming and router
duplication remain the measured settings.

| Whole design, current v19 | Value |
| --- | ---: |
| ALMs needed | 37,117 / 41,910 |
| ALMs placed | 38,599 / 41,910 (92.100%) |
| Mapped / fitted registers | 46,327 / 48,880 |
| M10Ks | 488 / 553; 65 free |
| Reported block memory bits | 3,818,050 / 5,662,720 |
| DSPs | 39 / 112 |
| Worst setup / hold | +0.104 / +0.239 ns |
| Reported violating timing groups | 0 |
| Logic / routing ALUTs | 46,835 / 18,266 |

[provenance_check.json](provenance_check.json) freshly parses the retained
fit/map hierarchy and global summaries and verifies the raw fit/map/STA
report hashes against the structural audit. Thus neither a rejected candidate
nor an older checkpoint is silently substituted. Needed ALMs are the fitter's
packing-adjusted estimate: `38,599 - 2,055 + 573 = 37,117`.

There are inherited unconstrained setup/hold categories and 38 unique critical
warning messages. This audit does not repair them or claim unconstrained-path
signoff. The baseline is one routed seed-1 result, not a multi-seed guarantee.

No full Quartus compilation was run. One **read-only TimeQuest metadata query**
loaded the existing netlist to enumerate register names; it completed with
zero errors/warnings. This missing measurement was useful because declared
widths and transformation logs alone cannot distinguish surviving banks,
folded outputs and hard-memory register nodes. Commands are retained in
[registers.tcl](registers.tcl), [query.ps1](query.ps1) and `registers_query.log`.

## 2. Reconciliation of exclusive and inclusive costs

| Hierarchy / stage | Placed ALMs | Needed ALMs | ALUTs | Dedicated FF | M10K |
| --- | ---: | ---: | ---: | ---: | ---: |
| Controller own, synthesis | not reported | not reported | 7,028 | 14,768 | 0 |
| Controller own, fitted | **10,647.6** | **10,497.5** | **6,966** | **14,773** | 0 |
| `opll_snapshot:fm_snapshot` child, fitted | 156.9 | 150.7 | 224 | 167 | 1 |
| Controller including child, synthesis | not reported | not reported | 7,252 | 14,924 | 1 |
| Controller including child, fitted | 10,804.5 | 10,648.1 | 7,190 | 14,940 | 1 |

Source: current fit hierarchy line 9278 and map hierarchy line 809. The extra
8,192 memory bits belong to the child RAM. They are **not 8,192 controller
FFs**, and the child's 156.9 ALMs must not be added again to the exclusive
10,647.6 when describing the latter.

The new query finds 14,991 timing register nodes in the subtree: **14,773 own**
and **218 child**. The child has 167 dedicated registers and 51 internal RAM
timing nodes. Those 51 are identified by their nested RAM hierarchy; they do
not represent another 51 dedicated-FF allocation or the RAM's stored bits.

The source declaration index contains 14,856 nominal sequential bit positions,
excluding the combinational `ddram_cmd_*` variables and the separate child.
Constants, merging, state recoding and physical duplication explain why this
is not the fitted count. The 7-bit source FSM has 108 named fitted state FFs.
The watchdog has 25 ordinary bit names plus five surviving `~DUPLICATE` nodes
(bits 7, 12, 17, 18, 20). These five also reconcile the net own map-to-fit FF
increase. Other physical transformations can cancel; this is not proof that
every synthesis operation corresponds to a surviving named duplicate.

**Attribution limits.** Fitter ALM hierarchy allocations are fractional
estimates with cross-hierarchy packing. ALUTs, FFs, routing ALUTs and ALMs are
different measures. One FF does not imply one independently recoverable ALM.
The reports do not identify a disjoint set of occupied ALMs for each source
bank, reset mux, version condition or control net. Full-module allocation is
an investigative envelope, not its removable saving.
The rounded child/parent needed estimates differ by 0.1 when added; use the
reported parent value rather than treating fractional allocations as integers.

## 3. Disjoint current register-cost decomposition

The following groups partition the **14,773 own fitted register nodes** exactly.
They exclude live CPU/VDP/OPLL state and the child RAM. Classification is by
surviving names, with every stem recorded in [inventory.json](inventory.json).

| Own structure | Surviving FF nodes | Resource attribution confidence |
| --- | ---: | --- |
| Primary sprite transport ring | 4,800 | High for FF; current isolated ALMs unavailable |
| Secondary sprite transport ring | 4,800 | High for FF; current isolated ALMs unavailable |
| Two CRAM snapshots | 768 | High for FF; live palettes are elsewhere |
| Two background history rings | 278 | High for FF; receiver helpers are elsewhere |
| CPU image + NMI + restart snapshots | 236 | High: 230 + 3 + 3 |
| Other snapshots and captured metadata | 1,369 | High name counts; mixed semantic roles |
| Registered restore-data outputs | 1,499 | High FF count; redundancy is not established for the whole group |
| DMA and DDR transport | 633 | High name counts; includes addresses, output data, pipelines and flags |
| Presence, handshake, selectors and CRAM write interface | 117 | High count; includes CRAM addresses/data/strobes; combinational fanout not partitioned |
| FSM encoding | 108 | High surviving state-node count |
| Timers, drain and watchdog | 92 | High: 28 + 20 + 8 + 6 + 30 |
| Operation identity | 73 | High count; nominal widths partly folded |
| **Total** | **14,773** | Matches exclusive Fitter FF exactly |

All snapshot/metadata categories together are 12,251 FFs; registered restore
data 1,499; DMA/DDR 633; remaining control/timer/identity and CRAM write
interface 390. These are FF
partitions, **not an ALM partition**. Current ALUT/ALM confidence is high only
for the aggregate controller/child allocations. Historical controlled deltas
give medium-confidence causal scale; estimates of future savings remain low.

## 4. Register inventory, lifetimes and consumers

[inventory.md](inventory.md) indexes **all 198 register declarations**, including
output ports and combinational `reg` variables: source line, declared width,
surviving name count, explicit reset, and all sequential write locations.
[inventory.json](inventory.json) retains assignment expressions and the complete
own group map. This is a declaration/assignment index, checked against every
own fitted name, rather than a replacement for the source's enable conditions.

Unless explicitly assigned, clocked data holds. Strobed outputs default low
each host clock (`savestates.sv:1234–1260`). Reset is asynchronous for the main
process (`:1165`); many data banks intentionally have **no explicit reset**,
while validity/control or later complete filling protects their consumers.
Absence of reset is not permission to consume uninitialized state. The table
below supplies the semantic lifetime and consumer requirements for substantial
declarations; exact per-name reset/write expressions are in the index.

| Bank / RTL location | Declared width; surviving FF | Capture, SAVE/LOAD and hold behavior | Reset/default and consumers |
| --- | --- | --- | --- |
| `sprite_snap`, `sprite2_snap`, :605 | 4,800 each; 9,600 | ARM captures post-T records, secondary zero when absent; accepted SAVE rotates 64; LOAD inserts 64 | Reset/header clear; 22-bit tail padding validated; direct 4,778-bit VDP restore buses gated by `has_restart` and architectural strobes |
| `bg_snap`, `bg2_snap`, :588 | 139 each; 278 | ARM capture; SAVE rotates 64/64/11; LOAD inserts 64/64/11 | Reset/header clear; absent-owner zero and counter/padding checks; direct BG buses under VDP restore/validity |
| `z80_snap`, :651; `nmi_snap`, :652; `restart_snap`, :653 | 230+3+3; 236 | Accepted T captures pre-tick CPU inputs; four CPU words replace image on LOAD; immutable through restore/preparation | CPU image has no explicit reset; NMI reset 001, restart 0, legacy validity/defaults retained; DDR word selection and T80 restore |
| `vdp_snap`, `vdp2_snap`, :662/:668 | 136 each; 272 | ARM post-T capture; two ordinary words plus HCounter extension install LOAD state | No full explicit reset; legacy header clears high HCounter fields; ordinary VDP registered outputs and video extension |
| `cram_snap`, `cram2_snap`, :663/:675 | 384 each; 768 | ARM parallel palette capture; six fixed SAVE slices; six LOAD words; indexed 12-bit entry restore | No full reset; legacy64 System E retains ARM live-secondary fallback; 32 CRAM writes, both owners parallel |
| `psg_snap`, `psg2_snap`, :664/:676 | 56 each; 112 | ARM preliminary capture, post-drain SAVE recapture; LOAD configuration words | No full reset; exact/legacy routes differ; registered PSG inputs and original set strobes |
| `psg_ext_snap`, `psg2_ext_snap`, :416 | 96 each; 192 | Post-drain quiescent capture; two-word payload per owner; held for exact LOAD | Presence/descriptor/padding validation; restore through 96-bit output copies; raw timers/noise/divider remain historical |
| Audio divider/control/phase/last, :417–421 | 4+11+1+16; 32 data FF | Divider/control post-drain; phase/last at ARM; parsed exact audio extension on LOAD | Phase/last normalized for absent history; `has_audio_last` separate; last sample aliases snapshot; release replays pending PSG event using saved phase/tick/divider |
| `mapper_snap`, :665; mapper history :384 | 64+18; 82 | Initial ARM mapper, then settled post-drain mapper/history pair on SAVE; LOAD stages original/current defaults | History reset/default `18'h0ffff`; registered mapper outputs applied before memory restore/CPU preparation |
| `evolution_snap`, :666 | 160; 156 | ARM base state; partial LOAD writes combine base and selector/pending extension | No full reset; header clears high history; tagged owner/width/reserved checks and old-image rejection; 160-bit output copy has 156 surviving FF |
| `eeprom_snap`, :679; `eeprom_ext_snap`, :355 | 64+128; 192 | Post-drain capture; legacy wrapper and exact serial temporal extension loaded separately | Extension reset zero; legacy64 wrapper defaults to 1; presence checks precede use; final EEPROM strobe/refill after flush |
| GG :344 | 128; 128 | ARM capture; two LOAD words; fixed SAVE slices | `GG_RESET` at reset/header fallback; 114 surviving restore-output FF, validation/padding not a separate guest bank |
| MD6 :348; tap :365; paddle :370; gun :374 | 46+19+32+46; 143 | Post-freeze/drain capture; LOAD temporal records/defaults | Explicit zero defaults plus presence/valid flags; apply at their established early/final restore stages, not arbitrarily together |
| IO :677; beam/video :678 | 32+22; 54 | ARM capture; word and extension LOAD; SAVE slices | Reset zero; public64 skips ordinary IO and chooses deterministic beam; video used again at phase acknowledgment/release |
| Phase/tick :608–609; SC size :359; EEPROM presence :356 | 2+1+2+1; 6 | SAVE boundary/ARM or post-drain metadata; LOAD validated owner/phase/footprint | Capture-tick reset 1; phase/header default 0; selects replay, memory footprint and peripheral ownership |
| Registered restore payloads, ports :86–244 | Mixed widths; **1,499** | Separate output registers hold previously applied values; loaded at mapper, CPU/VDP, accessory and release-specific stages | Per-port resets vary; only eligible after proving every consumer's strobe isolation and source lifetime; detailed split below |
| `vram/wram/nvram_word_buf`, :697/:709/:719 | 64 each; **56 each** | Assemble bytes for SAVE; hold through accepted DDR write | No full data reset; 8th byte bypass means top 8 positions already optimized away; independent DMA state machines |
| Three `*_d_latch`, :702/:712/:722 | 8 each; 24 | Preserve byte 7 on first BUSY stall while source RAM pipeline advances | Valid flags distinguish held data; cannot share away merely because normal RAM read address is held |
| `dout_latch`, :465 | 64; 64 | Capture only an expected DDR response; all LOAD parsers and byte unpackers consume it | Explicit reset zero; expected-response flag rejects stale scaler responses |
| DDR registered outputs, :247–254 | 111 nominal; 97 named | Hold address/data/BE/request until receiving-edge acceptance | RD/WE reset/defaults; constants/merging fold address, BE and burst bits; external shared bus consumes stable transaction |
| DMA addresses/counters/output registers, :189–222/:643/:693–723 | 14/15-bit address families, 8-bit writes, 2/3-bit pipeline and byte indices | Issue/read pipeline, assemble word, retain pending write, unpack LOAD bytes | Initialized before each DMA and enables reset low; passive/active VRAM routing derived from FSM, not another registered data bank |
| FSM :625 and transfer selectors :589/:606/:424/:467 | 7-bit source state; 108 state FF; small indices | Central operation/owner/word progression only on permitted acceptance; independent helper handshakes | IDLE/reset and error paths; counters have family-specific terminal tests |
| Cooldown/drain/watchdog/flush/unfreeze, :648/:649/:747/:751/:753 | 20/8/25/6/28; 92 physical FF | Flush 900,000, settle 255/4, quiet drain 32, timeout, cooldown | Reset zero; timeout and stale-response logic cannot become ordinary transport progress |
| Slot/base/identity :635–640 | 2/29/32/32/32/1; 73 physical FF | Sample request/boundary; increment change detector at SAVE completion | `base_addr` only 5 named FF, `cur_magic` 1; constant bits already folded; BIOS/game/slot validation remain |

### Restore-output bank breakdown

The 1,499 surviving output data FFs are: CPU `z80_dir` 230; VDP input pairs
135+135; PSG legacy inputs 52+52; PSG exact inputs 96+96; mapper 64; Evolution
156; EEPROM wrapper/extension 57+81; GG 114; MD6 46; gun 46; paddle 32; tap 19;
IO 32; video 22; mapper history 18; audio control 11, divider 4, phase 1.
Nominal declaration widths and surviving counts differ because padding,
constants and aliases have already been optimized.

This group is a **candidate envelope**, not 1,499 FFs proved removable. Some
outputs have distinct reset defaults, restore stages or multiple consuming
edges. Validity, NMI history, phase/tick and freeze flags are not included as
disposable payload. The recommended experiment covers only the 230-bit CPU
output, not the whole group.

## 5. Sprite history, physical storage and live restore are distinct

Each live VDP record has 64 slots × 74 bits = 4,736: enable 1, X 8, cached
planes 4×8, shifted planes 4×8, wideclock 1. Fixed history contributes 42:
data address 14, mode-2 flags 8, output color 4, collide 1, overflow 1,
collision-delay pipeline 14. Total **4,778 per owner**, 9,556 across System E.
The two 4,800-bit rings add 44 representation positions.

Live history resides in `rtl/vdp_sprites.vhd`, `rtl/vdp_sprite_shifter.vhd`
and VDP collision-delay logic. Its parallel shifting/priority/collision
consumers and distributed restore muxes lie in those hierarchies, not in the
controller's exclusive 10,647.6. The 4,778-bit output vectors through system,
VDP and main are wires. Do not count them as extra shadow registers.

The controller does:

```
accepted T -> held post-T live record -> ARM capture into each 4,800-bit ring
  SAVE: low 64 bits -> DDR; rotate 64 only on acceptance; 75 rotations restore ring
  LOAD: 75 validated incoming words -> same ring; retain both records
  architectural restore -> independent full-width buses and original strobes
  CPU preparation -> phase/beam acknowledgment -> exact first native enable
```

SAVE and LOAD use **the same two banks**. Frozen live state can replace a SAVE
capture source after a stability proof, but LOAD still needs incoming P while
live Q remains unchanged. Removing only ARM assignments does not remove the
9,600 FFs. One shared 4,800-bit ring cannot simultaneously drive two arbitrary
independent records at the current common restore edge.

G06's equal-image/different-future witnesses establish missing historical
information beyond architectural registers/VRAM. They do not prove 9,556 bits
of independent entropy at every reachable boundary. No new reconstruction
algorithm or permission to drop fields follows from this audit. Evaluator
WAITING/count/index normalization is an existing proven reconstruction;
cached planes, partly shifted copies, wide phase and collision history remain
under the current contract, including inactive slots and mode transitions.

All 22 high positions per ring carry meaningful bits during intermediate
rotations. They cannot be tied to zero or removed as constant FFs. A new
tail-aware representation can generate image padding, with at most 44 nominal
positions at issue before its control cost; it is not a material supported win.

Historical controlled G06/G10 addition: controller own mapped FF 4,838→14,439
(+9,601), ALUT 5,390→6,003 (+613); controller exclusive placed allocation
5,387.5→10,190.1 (+4,802.6). Whole design +9,603 mapped FF, +8,051 needed
and +5,458 placed. Primary/secondary VDP subtree placement grows about
594.4/576.5 with distributed restore and physical remapping. Other hierarchies
shrink. These are overlapping transition explanations, not an additive current
price for snapshot FF, mux, fanout and live history.

## 6. OPLL, background, peripherals and validation

**F01/OPLL.** `opll_snapshot` is already sequential: 104 private 32-bit rows
(3,328 serialized bits, 1,896 meaningful) in one 256×32 M10K. It gathers via
local 32-bit reads, services 52 DDR64 pairs and applies local rows followed by
refill. Memory and its output have no array reset. The child has 64-bit incoming
and 64-bit bulk-response registers, small state/index/refill/legacy controls,
167 dedicated FF and 224 ALUTs. It has no parallel 3,328-bit FF shadow.
The controller's `fm_word_valid` (:478–582) checks masks/ranges before application;
its ALUT cost is not separately reported. Mask cases share logic. F01 legacy
reset/initialization and exact apply ordering remain necessary; unused scratch
addresses do not constitute removable FFs.

**G05.** The 278 ring FFs and transport logic are controller-owned; `/6`, modulo,
text-position reconstruction and live BG restore are largely receiver costs.
The historical approximately 107.4-ALM helper allocation is not a current
controller cost. BG accepted fields include counter ranges, tail padding and
absent secondary-owner checks. No unproved semantic compression is proposed.

**Evolution/EEPROM/accessories.** Partial word updates and format-dependent
defaults create input selectors. Current mux recognition includes Evolution
11:1×60 and 8:1×64 groups, plus smaller fragments. The useful protocol history
and base mapper image have different roles; the whole 160-bit container is not
just the 60-bit selector extension. EEPROM wrapper, exact temporal state and
RAM contents also have different lifetimes. Changing these encodings or treating
present peripheral pins as reconstruction of missing current history is unsafe.

**Version and malformed-image validation.** Presence, subtype, owner, magic,
padding/range, audio-v2 sample presence, restart and Evolution predicates feed
private staging and routing before guest application. Tags are shared membership
logic, not sequential full-state converters or one bank per supported version.
Public64/public96 defaults and current exact restore paths remain even if older
development tags disappear. Current accepted image values must remain accepted;
natural writer invariants alone do not authorize narrowing a loaded 16-bit
mixed sample or merging independently supplied fields.

Private scratch mutation during parsing is intentional. Moving incoming data
directly into live state before later validation would add a failure behavior
that the current private banks avoid. Existing LOAD is not generally a rollback
transaction for arbitrary bus timeout after accepted RAM writes; that does not
license an extra early sprite/CPU mutation on malformed metadata. Keep existing
rejection-before-application guarantees and failure/release behavior exactly.

## 7. Mux, command, reset and high-fanout topology

The main cones are (a) bank next-data selection, (b) serialized field/word
selection, (c) DDR command/address preview and acceptance, (d) version/validation
route and defaults, and (e) capture/restore/freeze enables. They share gates and
registers. They are not five additive area allocations.

| Evidence | Current topology / interpretation |
| --- | --- |
| Sprite mux recognition | 8:1×4,736 and 9:1×4,736, with smaller fixed/tail groups; before-restructure estimates 23,680/28,416 LEs, after-restructure estimate zero for these groups |
| Evolution | Partial-write 11:1×60 and 8:1×64 plus 6:1/7:1 fragments; not a 160-bit removable version-only mux |
| CRAM staging | Multiple 4:1/5:1×64 slice-update groups; restore indexes a 384-bit vector into 12-bit entries |
| DDR preview | Combinational `ddram_cmd_*` is 103 nominal bits (:790–813), not another 103 FF; large FSM source cases choose fixed words, descriptors, buffers, addresses and masks |
| FSM | 108 surviving one-hot-style named state registers; source cardinality/mux recognition includes 118/119/120-way descriptions, not that many serial logic levels |
| Real transaction storage | Registered DDR address/data/BE/request held while BUSY; `ddram_step` gates mutations and progression on acceptance |

A zero residual recognized-mux estimate means restructuring, not zero physical
cost for the bank. LE estimates cannot be summed or converted into fitted ALMs.
Nor can repeated command-case text be counted as two complete physical decoders.
The preview closes G12's issue/accept ordering; removing it based on source
similarity risks advancing the ring/FSM before the receiving edge accepts a word.

Direct non-global Fitter fanout, from the **v19** report:

| Net | Direct loads | Measured worst queried setup |
| --- | ---: | ---: |
| `state.ST_ARM_FREEZE` | 9,670 | +6.259 ns |
| `z80_set` (shared primary restore implementation) | 5,901 | +8.589 ns |
| `vdp2_regs_set` | 5,448 | +4.996 ns |
| `state.ST_LOAD_HDR_RD` | 5,265 | +5.838 ns |
| Secondary ring generated controls | 4,811 and 4,800 | not independently isolated |
| Primary ring generated control | 4,800 | not independently isolated |
| `has_restart` | 1,410 | +6.363 ns |
| `ddram_step` | 527 | not independently isolated |

`z80_set` does not mean all 5,901 sinks are CPU storage; equivalent primary
restore strobes are merged/shared. The 4,800-load names are generated control
aliases, not evidence that an individual sprite data bit fans out to 4,800
ordinary data consumers. Freeze's queried path has +4.435 ns. All quoted
control queries pass; global worst setup is HDMI shadowmask→OSD (+0.104 ns),
and core worst setup is mapper CRC→T80 IR (+0.895 ns). These fanout values
identify locality risks, not the measured limiting global path.

The existing physical log contains 321 register-packing duplication records
and 2,962 router duplication records. The latter group by source hierarchy:
VDP 2,080; other core 603; scaler 409; framework 175; savestate subtree **16**.
Records are neither unique surviving cells nor extra ALMs. The own query's
five surviving watchdog duplicates are concrete current register evidence;
they do not explain thousands of controller ALMs. Receiver duplication cannot
be charged again to the controller's exclusive allocation. Clock/reset global
loads, direct routed fanout and transitive TimeQuest fanout-node counts must
also remain separate. Full extracted rows are in inventory.json.

## 8. Storage/transport architecture constraints

Capture has distinct time classes: CPU inputs at accepted T; sprite/BG/VDP/
CRAM at post-T ARM; PSG, settled mapper and some peripherals after drain;
OPLL through its held sequential capture protocol. One common serial capture
bus is safe only after a producer-by-producer freeze/stability proof. G08
PSG pending-event and v19 retained sample behavior cannot be normalized away.

| Architecture | Width/banking and memory trade | Principal unresolved obligation |
| --- | --- | --- |
| Current FF rings | Full parallel capture/restore, 64-bit accepted transport; zero sprite M10K | Large state/update-control footprint, already measured |
| Direct frozen-live SAVE | Live record remains held; no new RAM intrinsically | LOAD still requires both private records; does not remove the same 9,600 FF by itself |
| Narrow sequential RAM shadow | Two 150×32 owner records were implemented using two M10Ks; 64-bit DDR pairs assembled sequentially | Parallel capture/restore must be replaced; previous local receiver decode/read/scatter failed physical qualification |
| Wide RAM parallel restore | At M10K simple-dual-port width up to 40, each 4,800-bit one-edge word needs at least 120 blocks; two need 240 before other overhead | Far beyond 65 free blocks; true-dual-port configurations can constrain width further; raw bit capacity is not the port budget |
| One combined 150×64 transport RAM | Width 64 needs multiple physical blocks; a 300×32 logical store cannot fit a single 256-deep x32 M10K despite 9,600 raw bits being below its nominal 10,240 bits | Can hold both records cheaply, but cannot deliver two 4,778-bit restore buses in one edge without recreating FF staging or changing receivers |
| Field-/slot-banked RAM | Smaller local ports can trade block count against decode fanout; live caches/shifters still have concurrent per-pixel consumers | Per-slot tiny allocation wastes blocks; all-slot shifts cannot be replaced with one narrow port at the existing clock; new distribution must differ materially from failed gather/scatter |
| Existing OPLL scratch tail | Rows 104..255 give 152×32=4,864 spare content bits; rows 104..253 can hold one 4,800-bit record, zero extra blocks | Cannot hold both; sharing needs arbitration and a new receiver/install mechanism, not capacity arithmetic alone |
| One FF ring + reread | Nominal one fewer 4,800-bit bank; zero extra M10K | Original restore consumes independent P1/P2 together. Split install adds read/timeout/partial-live-state and source-immutability obligations |
| Destructive live scan | May algebraically remove shadows with no RAM | Live Q changes while frozen; complete rotation, error recovery, dependent-state isolation and restore ordering become new obligations |
| Snapshot-driven restore-data buses | Retain authoritative snapshots; remove eligible output-holding copies; zero new M10K | Prove every consuming strobe sees the same stable value, including NBA edge ordering, reset and errors; routing/packing can offset FF savings |

OPLL's successful sequential architecture is a precedent for narrow local
access with refill, not a transferable ALM saving for a 64-slot parallel sprite
engine. Keeping a full-width FF restore stage behind a new narrow RAM commonly
retains the expensive bank one intended to replace.

For any staged LOAD, validate complete relevant metadata/payload before its
first guest application. A validate/reread design also needs image-source
immutability or equivalent protection against a different second pass. After
partially installing one VDP, a new timeout cannot simply unfreeze mixed P/Q
state via today's `ST_ERROR`. Rollback or a changed failure contract cannot be
assumed free. System E owner isolation, legacy defaults and both full-width
records must survive. All staged work must finish before the unchanged CPU
replay, NMI ordering, phase/beam acknowledgment and first native enable.

## 9. Historical cross-checks and rejected approaches

| Evidence / actual baseline era | Controlled result | Why it does not supply a qualified current placed saving |
| --- | --- | --- |
| G06/G10 addition, v13→v14 | Whole design +8,051 needed, +5,458 placed, +9,603 mapped FF; controller +4,802.6 placed | Strong attribution of the expansion to storage plus update/restore topology, not an exact current per-bank ALM partition |
| G05 addition, v14→v15 | +526 needed, +576 placed, +309 mapped FF | BG is much smaller than the preceding sprite discontinuity; receiver reconstruction/control and global mapping accompany the 278 snapshot FF |
| G12 request restart, v16 | +232 needed, +185 placed, unchanged mapped FF | Ordering logic and physical remapping cost area without another payload bank; DDR acceptance is correctness infrastructure |
| F01, v16→v17 | +875 needed, **-403 placed**, +481 mapped FF, +1 M10K | Logical growth can accompany better packing; this is a whole-design result, not a negative intrinsic FM cost |
| F06, v17→v18 | -44 needed, -148 placed, +1 mapped FF | Additional completeness/control does not imply monotonic placement growth |
| FM sample, v18→v19 | -14 needed, +149 placed, +37 mapped FF, -19 fitted FF | v19 added sample/presence information and changed merges; the placement increase is not a 149-ALM isolated sample register |
| Common-mux extraction, **v16** | Standalone -38 ALUT; board **+106 needed / +47 placed**, mapped FF unchanged | Still 9,600 FF and broad control; physical resynthesis/remapping erased the syntactic simplification. The packing gap actually improved; calling this simply packing degradation is inaccurate |
| Parallel-mask formulation, **v16** | Standalone ALUT 6,161→15,693 (**+9,532**); same 14,819 standalone FF | Explicit parallel masks expanded combinational implementation; rejected before board fit. Standalone counts are not v19 controller counts |
| Development-format consolidation, **v17** | Paired seed1 -10 needed, **+27 placed**, -8 mapped FF; no RAM saving | Most current/public fallback and restore logic remains. Repeated tag syntax shared gates. Unpaired seed2 apparent -74 placed failed setup -0.013 ns and cannot establish attributable savings |
| Sequential G06 shadow RAM, **v17** | -9,397 mapped FF, +2 M10Ks, approximately +5,402 logic ALUT; seed1 route failed; seed2 38,012 placed, setup -0.100 ns | New local read/decode/scatter network consumed the storage win. Seed1's provisional -1,615 placed is unusable; seed2's -586 versus seed1 baseline is unqualified and not a matched-seed saving |
| G06/G10 storage study, **v19** | Phase-5 stop; no candidate implementation or build | Frozen-live SAVE stability is supported, but LOAD still needs the banks. Shared ring, scratch tail and destructive scan introduced unresolved restore/error/port obligations. It did not measure a zero-cost optimized design |
| CRAM inference, **v19** | -1,055 needed, **+121 placed**, -764 fitted FF, +4 M10Ks; setup +0.067, hold +0.231 | Local CRAM placed allocation fell 712.7 ALMs, but controller rose 76.9 and scaler own placement rose 427.4 under unchanged RTL. Global routing ALUT +997 and recoverable-packing estimate +1,182; no placed win. Four RAM replicas were inferred, rather than the predicted two |

CRAM's fitter identity is `38,720 - 3,237 + 579 = 36,062 needed`, versus v19
`38,599 - 2,055 + 573 = 37,117`. Both timing results pass; the physical keep
gate failed. In particular CRAM did **not** remove the controller's 768-bit
snapshot staging or change its 14,773 own FF count. Its local success cannot
be counted as current controller savings. The experiment was fully reverted.

The historical table is diagnostic. Do not mix v16's 39,001-site baseline,
v17's 38,598, or a failed route's provisional count with current v19 38,599.
Do not sum historical whole-design deltas, FF partitions, mux estimates,
fanout records and fractional hierarchy allocations as independent area.

## 10. Ranked experiments and correctness gates

Potential impact below names **observed target structures**, not predicted ALM
recovery. No unbuilt architecture has a measured placed saving.

| Rank / candidate | Evidence and potential scale | Extra M10K | Timing / correctness / proof complexity | Decision |
| --- | --- | ---: | --- | --- |
| 1. Eliminate eligible registered restore-data copies; **CPU-only pilot first** | 1,499 own FF in the broader class; measured CPU snapshot 230 plus separate output 230; sole output assignment and strobe-gated T80 consumers | 0 | Medium timing (fanout moves to snapshot); low-to-medium semantic risk for CPU only after consumer proof; moderate replay/miter proof. Wider class requires individual lifetime proofs | **Recommend only the 230-bit CPU pilot under separate authorization** |
| 2. New local sprite storage/access topology | 9,600 FF dominant; capacity/port trade is material, but existing 32-bit architecture failed | At least the demonstrated 2 for that layout; alternative banking unmeasured | High routing/correctness/proof risk; must supply a genuinely different locality mechanism before implementation | Defer; do not rerun the rejected port network |
| 3. Shared FF ring, OPLL tail or destructive scan | Nominal bank-sized storage opportunity; actual shared capacity known | 0 possible for one record/tail | Very high restore/failure/lifetime risk; missing simultaneous full restore and error recovery proof | Stop at feasibility gate, as prior v19 study |
| 4. Share mutually exclusive DMA payload/addresses | 633 own transport FF overall; three 56-bit assembly buffers and stall latches visible | 0 intended | Medium timing, high acceptance/stale-response/stall proof; much smaller removable subset than 633 | Low priority; no redundancy proof or area attribution yet |
| 5. Alternate validation/FSM/reset/decode organization | 108 state FF and shared combinational predicates; exact individual ALUT/ALM charge unavailable | 0 or an added lookup block depending on design | Binary encoding/ROM masks can add decode, latency and fanout; malformed-image and exact control equivalence complex | No supported material trial; do not repeat tag consolidation or mask rewrite |
| 6. Small BG/peripheral stage reorganization | 278 BG FF; Evolution 156 snapshot +156 output; EEPROM/peripheral copies in rank1 envelope | Port-dependent; coarse RAM can be wasteful | Mode/partial-write/default/read-before-write proof high relative to size | Defer; do not add this envelope to rank1 or sprite estimates |

Physical replication is a consequence of locality and timing constraints,
not an independently removable bank of thousands of controller FFs. A generic
“balance the enables” experiment without a bounded selected cone and consuming
edge proof is not recommended. Constraint/IP/packing changes are also outside
this audit and cannot be mixed into an RTL experiment's attribution.

## 11. Exactly one recommended next action

**After separate authorization, run one CPU restore-output lifetime/alias pilot
against this exact v19 baseline.** Keep `z80_snap[229:0]`, NMI/restart snapshots,
all bytes, parser validation, `z80_set`, NMI hold/replay, preparation and phase
release unchanged. Investigate replacing only the separate 230-bit `z80_dir`
holding register with a snapshot-driven data bus. Do not change VDP/PSG/
mapper/peripheral output banks, G06 rings, OPLL scratch or DDR transport in
that experiment. Do not change formats or public readers.

Concrete source evidence:

- Declaration at `savestates.sv:86`; snapshot at :651. Both have 230 distinct
  surviving register nodes. No current physical merge already removes the copy.
- Sole `z80_dir <= z80_snap` assignment is :2811, at `ST_LOAD_RESTORE` when
  `cram_entry==0`; `z80_set<=1` is :2812. The snapshot is already filled and
  stable through the receiving edge and private preparation.
- Wiring: `SMS.sv:1169–1170,1288–1289` → `system.vhd:663–664` →
  `T80s.vhd:185–186`. T80 architectural assignments are under DIRSet
  (`T80.vhd:442` and :1142). RegDIR's combinational permutation (:290–298)
  feeds `T80_Reg`, whose DIR writes are also under DIRSet (:109).
- Existing NMI/restart DIR data already aliases snapshots (:655–659), with
  separate validity/ordering. This is a structural precedent, not permission
  to alter those controls.

Let edge R execute the controller restore action. In the baseline, its NBA
loads the output register and raises `z80_set`; the T80 consumes at R+1.
A snapshot-driven bus is eligible only if the snapshot at R+1 equals the
baseline output and all other DIR consumers ignore differing inactive data.
This must include stalled R/R+1, reset and repeated LOAD; merely assigning a
wire in place of a register is not a completed proof. The baseline's unreset
inactive output value is not a new architectural default to reconstruct.

Required gates for that future task:

1. Audit **all** DIR/RegDIR readers, prove consuming-edge equality and snapshot
   stability from before every DIRSet edge through consumption; no use outside
   the strobe or changed combinational feedback. Stop on an unproved reader.
2. Prove identical controller control outputs, DDR commands/acceptance, image
   words and both unchanged history rings. Document any difference limited to
   inactive restore-data values; never mask a consumed value or first cycle.
3. Preserve reset, public64/public96 and all currently accepted tagged imports,
   malformed-image rejection before CPU mutation, errors/timeouts and SAVE-only.
4. Run G01/F16 real-CPU/NMI/prefix/EI/HALT/private-replay cases, G06/G10 first
   native enable and dual-VDP suffixes, Pause, random stalls, long suffixes and
   repeated LOAD after different live Q. Include late metadata rejection after
   CPU words have already changed private `z80_snap`.
5. Only after proof/simulation, use fresh source-isolated full fits with fixed
   date/settings and matched baseline/candidate seeds. Confirm any favorable
   result with a second **paired** seed; no favorable-seed substitution. Require
   lower whole-chip placed ALMs, preserved timing/routing and no new critical
   warnings, as well as actual disappearance of the intended 230 output FF.
   If it does not help physically, revert and stop rather than expanding scope.

This is a small causal pilot into an observed 1,499-FF architectural class;
it is not a forecast that all that class is removable, nor a promise of a
1,000-ALM controller reduction. If a minimum 1,000 placed-ALM win is required
before any experiment, **no candidate currently has evidence supporting that
guarantee**. The proposed pilot has a materially different mechanism and a
smaller correctness surface than the rejected sprite/CRAM/format trials.

## 12. Execution boundary, preservation and final Git state

Evidence gathering and audit artifacts only. No production RTL, formats,
constraints or IP changed; no optimization candidate was implemented. No
new synthesis, fit or assembler run. Existing v19 reports and source hashes
were checked again after the read-only query. Existing tests/reports were
read in place and preserved. No new functional regression is claimed for
unchanged production.

Final `git diff --stat`:

```text
(empty)
```

Final `git status --short`:

```text
?? tests/
```

The untracked tests directory predates this task. New audit files are confined
to `tests/savestates_internal_cost_audit/`. All 204 tracked file hashes, HEAD,
existing branch and index are unchanged. No commit, push, merge or PR.
[verification.json](verification.json) records final preservation and artifact
hash checks. **Stop here; RTL changes require a new authorization.**
