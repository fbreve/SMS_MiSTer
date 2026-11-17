# G05 background/text savestate fix

Final closure report.

Scope is G05 only. G08.release, G11/G12, F01 and F06 are unchanged and not reclassified.

## 1. Baseline HEAD

`58583189b5c650dc6658ef467e8dcb72d9f6e6c2`, branch `fix/savestate-g05-background`. All 203 tracked files were hashed unchanged before the sufficiency gate. [Manifest](baseline.json), [pre-edit gate](sufficiency_pre_edit.json). No commit, push or PR.

## 2. Baseline format

v14, including the committed G06 sprite record and G10 deterministic restart. Development-version consolidation is outside scope.

## 3. Exact original non-injective witness

Two real-T80 histories use the original immutable ROM, naturally varying earlier scroll/text history and restoring equal architectural memory/registers before accepted SAVE. Both complete known 12,288-word/98,304-byte v14 images have little-endian binary SHA-256 `0ea3e9a697cdb342afbf9ffe0777413913b1e08c8fecb31f17a2382fa0a3baa4`. No payload subset comparison or internal history forcing establishes this equality. Post-T beam is (124,192), ce_vdp/ce_pix=1/1; internal pipeline x=131 (distinct from beam x). VDP136=`00050f3e14d4c2403fcc27e0005ff1c280`; registered fetch address=0x3BD4, priority=0, current RGB=0x7E6. Tile index=320, palette/palette_shift/priority_latch=1/1/1, flip_x=0, datac=0; tile_y=6 vs7. Data0..3=40/65/BA/00 vs F4/09/2E/00; shifts0..3=00/2F/D0/FF vs A0/4F/70/1F. Text shift/index/pattern/phase/column=2C/3C/AD/2/19 in both. Vertical flip is folded into tile_y; no independent flip_y storage exists. Raw BG127=`5020f7002032dd000017e87fd8795a93` vs `5020ff007a0497005027b80fd8795a93`. [Every decoded field and immutable log hashes](baseline_results.json). The pre-edit gate's embedded decoder originally overwrote beam x with internal x; the corrected derived JSON uses separate names. Raw observations and proof outcomes did not change.

## 4. Exact visible corruption

Independent uninterrupted 42,000-sample futures differ at seven visible pixels while CPU230, VDP136 and consumed input counts/values remain equal. First differing visible pixel: sample23840, beam(25,0), RGB46F vs126. Each of the six unmodified-v14 LOADs corrupts nine visible pixels and eight fetch/palette/priority audit samples relative to its own uninterrupted future. Characterizer terminal PASS means reproduction completed, not that v14 replay was correct.

## 5. First causally relevant omitted state

The retained ordinary shifter MSBs and palette_shift select CRAM[0x1C]=46F vs CRAM[0x11]=126 when guest R0 switches from text to Mode4 at x24/y0. Registered CRAM output presents this at x25, even though the shifters already reload on that pixel edge. Clearing only shifters in an otherwise sufficient prototype causes exactly one pixel error at x25; clearing only data0..3 preserves x25 but causes eight later pixel errors starting x26. Thus differing tile_y/data are earlier differing registers, but pre-reload shifters cause the FIRST corrupted pixel. Pattern planes0..2 cause the next errors; plane3 in this Mode4 path comes from current VRAM. [Causal trace and alternatives](design_pre_edit.md), [negative controls](sufficiency_pre_edit.json).

## 6. Complete G05 inventory

[state_inventory.md](state_inventory.md) contains every state width, reset, enable, first consumer, overwrite bound and classification. [state_inventory.json](state_inventory.json) records exact pre-edit source hash and declaration/assignment/consumer sites. The 142-bit raw storage cone is tile_index9, x8, tile_y3, palette1, palette_shift1, priority_latch1, flip_x1, datac8, data0..3×8, shift0..3×8, text_shift6, text_tile_index8, text_pattern8, text_phase3, text_column6, registered VRAM address14 and registered priority1. All retained storage is MUST SERIALIZE under legal mode changes. text_pattern[1:0] have no consumer anywhere. Phase/column encode losslessly in8 bits. Combinational modes/row/color aliases reconstruct; process variables are assigned before use; VRAM/CRAM read Q refill before observation. Architectural mode/table/scroll/latched-scroll, beam and memories are already saved elsewhere.

## 7. Defect class

Combination H: ordinary metadata, fetched historical bytes, pixel shifters, palette/priority, position and independent text history. Inactive paths retain history across mode changes. The original witness is principally shifter-then-data loss, not a newly discovered CPU or sprite restart defect.

## 8. Reconstruction feasibility

The complete equal-v14-image/different-future pair rules out deterministic reconstruction from existing saved registers, VRAM, CRAM, beam, mode, scroll and canonical position. Refetch sees current memory/mode, not the earlier fetch history. Holding architectural time cannot recreate missing historical bits. Current VBlank is registered and can remain high during visible text after a GG224→text viewport change; blank-at-acceptance does not imply safe-to-discard inactive history.

## 9. Solution A: minimal live history

Chosen:139 historical bits per VDP, six payload words plus one descriptor in the existing container. Independent records pass through background→main→VDP→system→top→controller. Restore uses the existing VDP strobe and adds no guest clock or pixel latency. Adds278 snapshot bits and bounded serial transfer/restore logic. It supports ordinary/text/mixed modes without mode-specific replay. Cost must pass Quartus. Field/consumer minimality is claimed; global information-theoretic optimality is not.

## 10. Solution B: hidden reconstruction

Rejected: zero new historical bits cannot distinguish the confirmed pair. Replaying enough earlier mode, memory and fetch events would require unavailable history, a renderer scheduler and dual-VDP arbitration. A fixed hidden pixel count cannot prove sufficiency. Ordinary RAM Q refill is deterministic and retained, but it does not replace historical pipeline storage.

## 11. Solution C: stronger SAVE boundary

Rejected: another blank coordinate cannot canonicalize an inactive ordinary/text path that can retain history indefinitely. Waiting for a guest mode change is unbounded. Forcing mode/time changes would change the save contract and visible future. No sufficient finite boundary with zero additional history was established.

## 12. Solution D: hybrid

Rejected as a smaller sufficient solution: metadata/phase plus current refetch loses cached old pattern/shifter bytes. A codec based on earlier mode/scroll transitions needs additional history and more restore logic. A two-bit x-offset idea also relies on an invariant broken by legal legacy loads at arbitrary saved beam positions; strengthening that legacy policy would add coupling without removing any of the three DMA words. The139-bit field representation keeps literal x and avoids that assumption.

## 13. Chosen design

Retain all live historical storage, discard globally dead text_pattern low2 bits, and encode text_position=6×column+phase. Natural counter transitions permit positions0..239; decode by /6 and mod6. [Exact bit ranges](proposed_fields.json). Capture post-T at the existing ARM stage. SAVE rotates each139-bit bank64/64/11; LOAD shifts64/64/11, avoiding padded192-bit banks and indexed wide crossbars. Install selected registered BG address and priority during existing restore. Ordinary registered RAM reads settle before the first native consumer. G10 states105/106, sprite transport and capture acceptance stay unchanged.

## 14. Pre-production sufficiency proof

The production tree remained byte-identical to all203 baseline hashes until [sufficiency_pre_edit.json](sufficiency_pre_edit.json) passed. Side-record prototype separated the original pair and passed all six exact LOADs. Independent component transition miter passed368 cases/285,959 exact pixel-state comparisons, including every one of240 text counter positions after arbitrary Q, and128 randomized histories/mode/table/scroll/memory changes. A natural text-low-bits pair differed only in raw bits0x600, had equal complete known v14 images/equal139-bit projection, and equal42,000-sample architectural futures. Distinct-foreground real GG text capture and its omission control gave three visible corrupt pixels if text history was dropped. Static transition closure then proves equal retained state + equal future inputs yields equal future state/output for all implemented modes; dead bits cannot influence any consumer. Finite searches support this proof rather than claiming exhaustive machine reachability. The first transparent-foreground text control failed to produce RGB divergence and is explicitly excluded. Prototype initialization used the inherited legacy-x formula; modern139 restore was identical to the selected design, whose deterministic all-zero legacy policy was tested separately.

## 15. Format decision

v15 tag48430F; header/subtype and v14 sprite/phase records remain compatible. Descriptor word032=`008b0f0047354231` (139/version15/G5B1). VDP1 payload033..035; VDP2 payload036..038. Last word has11 useful low bits and53 required zero padding bits. Non-SystemE second record must be allzero. Text position240..255 is invalid. All new metadata is validated before guest-state writes. Unit format test passed511 malformed rejections and398 current/legacy accepts, including descriptor bit flips, padding, absent second-device bits, all139 one-hot payload bits in both banks, every counter code0..239 and genuine old64KiB images. Container remains96KiB.

## 16. Legacy snapshots

v14 and older skip absent G05 history and normalize ALL missing BG storage, including x and registered fetch address, to literal zero. No exact original missing-history future is promised. This removes dependence on discarded pre-load mode/scroll Q. Tags1..14 and old64KiB formats are accepted with their established CPU/sprite compatibility policy. Some retained immediate-after-legacy-warmup cases therefore use fresh independent v15 uninterrupted references with identical ROM/memory/request arguments; the original full-frame witness still compares directly to fresh unmodified-v14 references.

Older files can display normalized pipeline content until the affected path refills. Inactive historical fields remain zero until their next normal overwrite. This is deterministic compatibility behavior, not recovery of unavailable original history.

## 17. Production files changed

Exactly six: `SMS.sv`, `rtl/system.vhd`, `rtl/vdp.vhd`, `rtl/vdp_main.vhd`, `rtl/vdp_background.vhd`, `rtl/savestates.sv`. No CPU, PSG, sprite RTL, memory topology or other peripheral production changes. [production_sources.json](production_sources.json) bridges original mixed line endings to the exact normalized proof-gated source hashes.

## 18. Original pair post-fix

Complete known v15 images differ at words 33, 34. Binary SHA-256 A=e6aaf181fa49667dd28453f3bb4cec3d484558e07b9960919b5bb029312ad1eb, B=fcf65abeba99f0d8c48e26e5eb50c11b0696c71e93e7202a956f7daeb75ccdff. Both retain their correct distinct original futures.

## 19. Six original LOADs

PASS: 42,000 samples, SAVE-only and 3 LOADs. [Log](integrated_original/dut_h0/simulation.log). PASS: 42,000 samples, SAVE-only and 3 LOADs. [Log](integrated_original/dut_h1/simulation.log). Actual64-sprite-slot layout and real controller storage, with independent original v14 uninterrupted references; no side-record feedback. Every sampled color/fetch/priority is checked, including the exact first visible pixel.

## 20. Deferred case 1: Graphics I

PASS: 42,000 samples, SAVE-only and 3 LOADs. [Log](integrated_rich/dut_graphics1/simulation.log). Original ROM, memory initialization, request coordinate and42,000-sample suffix retained.

## 21. Deferred case 2: SMS224

PASS: 42,000 samples, SAVE-only and 3 LOADs. [Log](integrated_rich/dut_sms224/simulation.log). Original ROM, initialization, request and42,000-sample suffix retained.

## 22. Deferred case 3: nontrivial scroll

PASS: 42,000 samples, SAVE-only and 3 LOADs. [Log](integrated_rich/dut_scroll/simulation.log). Original R8/R9 offsets, ROM, initialization, request and42,000-sample suffix retained.

## 23. Deferred case 4: mode switch

PASS: 42,000 samples, SAVE-only and 3 LOADs. [Log](integrated_mode_switch/dut_special/simulation.log). Uses the original long42,000-sample192→240 expansion case; the stale1000-sample pilot is not substituted.

## 24. Initialized Mode4

PASS: 170,000 samples, SAVE-only and 3 LOADs. [Log](integrated_rich/dut_mode4/simulation.log). The170,000-sample suffix crosses first/middle/last visible lines and frame transitions. Nonuniform adjacent tile/row data exercises both palette and priority attributes and H/V flips. PASS: 42,000 samples, SAVE-only and 3 LOADs. [Log](integrated_rich/dut_scroll/simulation.log). PASS: 42,000 samples, SAVE-only and 3 LOADs. [Log](integrated_masked/dut_masked/simulation.log). The masked case sets guest R0=24 and board black_column=1, with nonuniform scrolling contents; all pixels and positions compare exactly.

## 25. Legacy/text modes

PASS: 42,000 samples, SAVE-only and 3 LOADs. [Log](integrated_rich/dut_text/simulation.log). PASS: 42,000 samples, SAVE-only and 3 LOADs. [Log](integrated_rich/dut_graphics1/simulation.log). PASS: 42,000 samples, SAVE-only and 3 LOADs. [Log](integrated_rich/dut_graphics2/simulation.log). PASS: 42,000 samples, SAVE-only and 3 LOADs. [Log](integrated_rich/dut_mixed_m3/simulation.log). Covers distinct text, GraphicsI, GraphicsII and implemented mixed/M3 decode. PASS: 2,000 samples, SAVE-only and 3 LOADs. [Log](integrated_visible_text/dut_early/simulation.log). The latter is genuinely visible foreground15/overscan3 at GG y30 despite stale registered VBlank. Ordinary and text history are retained independently.

## 26. Game Gear

PASS: 65,000 samples, SAVE-only and 3 LOADs. [Log](integrated_rich/dut_gg/simulation.log). 65,000 samples cover GG cropping/viewport, compared at every sampled pixel, stronger than a visibility-only mask. PASS: 2,000 samples, SAVE-only and 3 LOADs. [Log](integrated_visible_text/dut_early/simulation.log). Hidden equality is not used to infer visible sufficiency.

## 27. SystemE dual VDP

PASS: 42,000 samples, SAVE-only and 3 LOADs. [Log](integrated_dual_render/dut_primary/simulation.log). PASS: 42,000 samples, SAVE-only and 3 LOADs. [Log](integrated_dual_render/dut_secondary/simulation.log). PASS: 42,000 samples, SAVE-only and 3 LOADs. [Log](integrated_dual_render/dut_both/simulation.log). Distinct initialized VRAM/CRAM/backgrounds, separate fetch/priority/palette audits, full first and subsequent visible lines, three LOADs each. PASS: 1,000 samples, SAVE-only and 3 LOADs. [Log](integrated_dual_irq/dut_enabled/simulation.log). Additional real CPU second-VDP IRQ path. No shared BG reconstruction bank. Reduced8-slot sprite topology in the full-background cases is not claimed as a64-slot sprite packing proof.

## 28. PAL/NTSC

PASS: 60,000 samples, SAVE-only and 3 LOADs. [Log](integrated_rich/dut_pal240/simulation.log). NTSC cases cover the other mode families. PAL/NTSC select beam/frame timing, not a separate background storage transition function; equal restored beam/mode/history and first-native-enable sequence gives the same induction. This avoids an unnecessary full cross product.

## 29. 192/224/240 lines

192: Mode4, original text-transition and SystemE full-background cases. 224: sms224 and GG. 240: mixed_m3 and PAL240, plus the deferred192→240 transition. Height controls feed the already-saved beam/mode/row selection; all live ordinary/text storage is mode-independent in the v15 record. Accepted states near viewport changes are tested explicitly.

## 30. SAVE-only

Every completed VDP runtime case compares SAVE-only continuation against an independent uninterrupted reference before LOAD replays; CPU230, VDP136, consumed IN values/counts and exact colors/audits are retained where applicable. The original full-frame pair uses v14 references; legacy-normalized cases use new v15 references. No guest hidden advancement is introduced by G05 transport. Paused non-M1 CPU/PSG bounded capture progress follows the existing F12 contract.

## 31. Repeated LOAD with legal Q

PASS: 42,000 samples, SAVE-only and 3 LOADs. [Log](integrated_q/dut_history/simulation.log). An immutable real-T80 NMI handler only during Q writes VRAM0041 (actual CPU readback to C121), CRAM0, R8, R9 and mode/text history, with distinct seeds11/22/33. Completion/readback/register/CRAM assertions precede each LOAD. Same saved T and future inputs must reproduce the same suffix. Other repeated cases vary elapsed rendering/CPU history; those alone are not described as guest memory perturbations.

## 32. Transport duration

PASS: 1,000 samples, SAVE-only and 3 LOADs. [Log](integrated_stalls/dut_deterministic/simulation.log). PASS: 1,000 samples, SAVE-only and 3 LOADs. [Log](integrated_stalls/dut_lfsr/simulation.log). Backpressure is qualified by RD/WE: deterministic83/97 and LFSR13/16 profiles. All139-bit records remain frozen throughout transport and CPU preparation. PASS: 1,000 samples, SAVE-only and 3 LOADs. [Log](integrated_stalls/dut_full_flush/simulation.log). The latter retains the production900,000-host-clock flush. TB_FAST elsewhere removes only that host interval, not native guest clocks.

## 33. Post-fix non-injective search

Natural dead-text-bits pair has equal complete known v15 images (binarySHA 4d330861e880b93ea6784eb4d0536ff20d04cf4d791c0d4f3ea50390e2099620) and equal42,000-sample architectural futures (SHA 478dc8eb88d3bb89d9f40f6379ea90199a918db24fcc2af16f36e89627b67b71); raw differences are only the deliberately omitted text_pattern[1:0]. Each has one LOAD. Original different-future pair now separates. No omitted fetched metadata/data/shifter/palette/priority/address/position remains beyond the proven dead bits and lossless counter encoding. New natural visible-text, guest-Q, mode and independent dual-VDP histories challenge that sufficiency; component tests cover additional transitions not claimed naturally reachable. No remaining equal-v15-image/different-visible-future witness was found.

The entire future files, including the audit column, also match byte-for-byte: SHA-256 `31a56af9c1119b5c705bc7b2bc3b5db1070024fb5474449598d10026068fe4ce`. Raw accepted-SAVE BG127 values are `001e400053c1768027826dc83c00f000` and `001e400053c1768027826dc83c00f600`; their XOR is exactly0x600.

## 34. G02 regression

PASS: 5,000 samples, SAVE-only and 3 LOADs. [Log](integrated_g02/dut_active/simulation.log). Real enabled line IRQ/status-read handler. Status-clear pending acceptance remains excluded by unchanged production boundary logic. No contradictory production evidence; G02 remains CLOSED—JUSTIFIED BOUNDARY EXCLUSION.

## 35. G03 regression

PASS: 1,000 samples, SAVE-only and 3 LOADs. [Log](integrated_g03/dut_bus/simulation.log). Ordered physical memory write events (12:8VRAM+4CRAM), actual memory arrays, CPU and consumed bus values check exactly once reconstruction. No contradictory evidence; G03 remains CLOSED—PROVEN RECONSTRUCTABLE.

## 36. G04 regression

PASS: 1,000 samples, SAVE-only and 3 LOADs. [Log](integrated_g04/dut_pending/simulation.log). Every host clock for10,000 clocks checks nonzero collision-delay/IRQ, CPU230, VDP136, RAM and lastX timing from first enable. Legal stalls and natural phase variation use this oracle too. No contradictory evidence; G04 remains CLOSED—PROVEN RECONSTRUCTABLE.

## 37. G06 regression

PASS: 1,000 samples, SAVE-only and 3 LOADs. [Log](integrated_g06/dut_sanity_collision/simulation.log). PASS: 1,000 samples, SAVE-only and 3 LOADs. [Log](integrated_g06/dut_sanity_overflow/simulation.log). Actual64-slot sprite record packing, collision LOAD and overflow SAVE-only, existing CPU/sprite isolation assertions. Sprite production sources are byte/token identical to baseline.

## 38. G10 regression

PASS: 1,000 samples, SAVE-only and 13 LOADs. [Log](integrated_stalls/dut_phases/simulation.log). Thirteen LOADs naturally vary final DMA response latency to reach12 distinct non-enable divider phases before CPU preparation, without forcing divider state. First60-host-clock native enable order is checked per release, and G04 additionally checks every host clock for10,000 clocks. Capture phase codes observed: 0, 1, 2, 3. Existing states105/106 and CPU/sprite replay semantics are unchanged; only four BG transport states107..110 were added. PASS: 1,000 samples, SAVE-only and 3 LOADs. [Log](integrated_hl/dut_edges/simulation.log). Real HCounter/HL edge path targeted sanity.

## 39. G01 / F16 / F12 sanity

19/19 passed. G01: ED prefix, DDCB, LDIR repeat, EI held INT and protected pulse; three LOADs each. F16: all eight normalized NMI triplets, including GG/capture-edge pending pulse, plus v14 and old64KiB compatibility; three LOADs each (legacy missing-history normalization is not claimed exact historical replay). F12: paused M1 SAVE, bounded paused non-M1 capture progress, repeated LOAD with current host Pause and with current running state; CPU and dual PSG first-native-enable suffix checks. CPU fixtures use known zero mock BG/sprite endpoints, not actual VDP/full memory topology. Pause FULL=0 avoids uninitialized VDP evidence. [Case lists](sanity_g01/cases.json), [NMI](sanity_nmi/cases.json), [Pause](sanity_pause/cases.json).

## 40. Simulation accounting

31/31 actual-storage VDP cases in15 families, 99 specified LOADs;26 fresh uninterrupted references plus two reused fresh unmodified-v14 references; three transport-only variants share the deterministic-profile reference.19 CPU/NMI/Pause cases in3 families. Separately:368 component cases and909 format scenarios (511reject/398accept). Pre-edit defect characterizers, omission negatives and prototype passes are separate evidence and are not counted as successful final-production cases. [Machine-readable ledger](simulation_results.json), source identity and fail-closed build gate in [check_simulations.js](check_simulations.js). Pilots with a path/compile setup error or intentionally interrupted scheduling are not simulation passes. Transparent-foreground omission pilot did not demonstrate visible corruption and is excluded. Finite natural search and component transition proof have distinct scopes.

Total: 20 final groups; 50 runtime cases; 148 LOADs (99 VDP + 49 targeted sanity). The368 component cases and909 format scenarios are disaggregated unit evidence, not additional whole-core runs.

## 41. G05 classification

**CLOSED - FIXED AND PROVEN.** Mandatory deferred cases, post-fix collision search, exact six original LOADs, targeted regressions and full controlled Quartus passed.

## 42. Quartus setup slack

+0.211ns; fresh v14 +0.384ns, delta -0.173ns; retained v14 +0.384ns, delta -0.173ns.

## 43. Quartus hold slack

+0.232ns; fresh v14 +0.226ns, delta 0.006ns; retained v14 +0.226ns, delta 0.006ns.

## 44. Timing violations

0 failing timing-summary checks; fresh v14 0, retained v14 0. All clock-domain setup/hold/recovery/removal/minimum-pulse-width summary checks and TNS are retained in build_results.json. Both flows retain the pre-existing TimeQuest information that setup/hold are not fully constrained; zero reported violations applies under the unchanged SDC, not to unconstrained paths.

## 45. ALMs needed /41,910

35,945/41,910 (85.767%). Delta vs fresh committed-v14 control: +526; vs retained committed-v14 build: +526.

## 46. ALMs placed /41,910

38,718/41,910 (92.384%). Delta vs fresh committed-v14 control: +576; vs retained committed-v14 build: +576.

## 47. Fitted registers /167,640

48,385/167,640 (28.862%). Delta vs fresh committed-v14 control: +383; vs retained committed-v14 build: +383.

## 48. M10K /553

487/553 (88.065%). Delta vs fresh committed-v14 control: +0; vs retained committed-v14 build: +0.

## 49. Memory bits /5,662,720

3,809,858/5,662,720 (67.280%). Delta vs fresh committed-v14 control: +0; vs retained committed-v14 build: +0.

## 50. DSP /112

39/112 (34.821%). Delta vs fresh committed-v14 control: +0; vs retained committed-v14 build: +0.

## 51. New warning types

New warning types: none. Candidate critical warning messages: 38; fresh control: 38. 0 normalized new messages require review (see build_results.json). Both builds use Quartus17.0.2, seed1, source-only fresh databases, identical QSF/SDC/IP and matched generated build date.

The fresh matched-date control reproduces every retained v14 resource and setup/hold metric exactly. G05 adds526 needed ALMs (+1.255 percentage points of device capacity, 1.485% of baseline use), consuming 8.104% of prior needed-ALM headroom. Remaining headroom is 5965 needed ALMs and 3192 placed sites. The checkpoint contains278 snapshot bits total. Synthesis adds309 registers; fitted registers add383, with74 additional differential registers from physical mapping/optimization. Exclusive fitted register deltas reconcile as controller+288, background+69, other+26. Logic ALUTs add909 and routing ALUTs add204. Global packing reconciles exactly: placed+576 minus recoverable+34 plus unavailable-16 = needed+526. Hierarchical ALM estimates are attribution aids, not the global packing equation. The text counter's divide/modulo subentities account for about107.4 estimated fitted ALMs. A shared quotient/remainder implementation or raw140-bit counter is an unbenchmarked resource tradeoff; the current139-bit projection is field/consumer minimal, not a claim of globally optimal ALM encoding. Reconstruction from the existing image is ruled out by the equal-v14-image/different-future witness; no smaller sufficient history projection was established. The measured growth is bounded and the routed design meets the requested gates. M10K, memory bits and DSP are unchanged. Placement is92.384% and worst setup slack is+0.211ns, so physical headroom remains limited. No new warning type/message appears; both builds retain38 distinct critical warning messages and the existing setup/hold unconstrained-path information. This assessment accepts the measured G05 cost and does not broaden other savestate obligations.

## 52. git diff --stat

```text
SMS.sv                 |   4 ++
 rtl/savestates.sv      |  92 +++++++++++++++++++++++++++++---
 rtl/system.vhd         |   5 ++
 rtl/vdp.vhd            |   4 ++
 rtl/vdp_background.vhd | 142 +++++++++++++++++++++++++++++++------------------
 rtl/vdp_main.vhd       |   6 ++-
 6 files changed, 193 insertions(+), 60 deletions(-)
```

## 53. git status --short

```text
M SMS.sv
 M rtl/savestates.sv
 M rtl/system.vhd
 M rtl/vdp.vhd
 M rtl/vdp_background.vhd
 M rtl/vdp_main.vhd
?? tests/
```

`?? tests/` existed before this task. Only the new G05 test tree was added here; historical evidence was retained. Generated simulator libraries and both Quartus build trees are ignored. Nothing staged.

## 54. Final recommendation

**READY TO COMMIT**. Review the v15 legacy-normalization contract and controlled resource delta. No commit, push or PR performed.
