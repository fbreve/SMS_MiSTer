# G06/G10 snapshot-storage investigation

**E. NO SAFE CANDIDATE IDENTIFIED. Stopped at the Phase 5 selection gate.**

No replacement RTL was implemented and no Quartus build was launched. The request explicitly permits stopping with an investigation report if no candidate is sufficiently supported. This is that outcome, not a completed optimization trial or proof that future optimization is impossible.

The investigation confirms a useful distinction: frozen live sprite state can supply SAVE data without a capture copy, but the same physical rings also buffer incoming LOAD records. Removing SAVE assignments alone does not remove those flip-flops. Meaningful storage reduction requires changing LOAD storage or installation as well. The low-risk ring rewrite was already measured unhelpful; the prior RAM/local-port conversion failed physical qualification. Newly examined sharing/scan alternatives introduce unresolved restore/error/port obligations. No semantic history field was found safely removable.

## 1. Baseline HEAD

HEAD `1b2a52d87d2659c908d4f9f846416d14bfd85bea`, “Preserve FM sample state across savestates”. Branch created: `optimize/g06-g10-snapshot-storage`. Format **v19**, outer tag `484313`, unchanged 96 KiB image.

Entry tracked worktree and index were clean; the pre-existing untracked `tests/` tree remains. [baseline.json](baseline.json) records every tracked regular-file hash, all seven prerequisite report hashes and baseline metrics. No production file was edited. Read the requested structural audit, resource growth, sequential architecture, sprite optimization, G06/G10 fix, F01 implementation and G08.FM reports; their historical open classifications are superseded by the committed v19 closure, not reopened here.

## 2. Baseline resources and timing

Verified retained v19 evidence: [source-bound audit verification](../structural_resource_audit/source_verification.json), [build manifest](../savestate_g08_fm/build_early_inputs.json), [resource ledger](../savestate_g08_fm/early_results.json). All 137 retained build inputs match raw manifest hashes; 135 tracked inputs match current HEAD with CRLF/LF normalization, two unused backup files have no HEAD blob. No rebuild was necessary to establish the unchanged baseline.

Quartus Prime Lite17.0.2 Build602, Cyclone V5CSEBA6U23I7, SMS/sys_top, seed1, BUILD_DATE261025, MISTER_FB=1. STANDARD FIT, HIGH PERFORMANCE EFFORT, SPEED, final placement ALWAYS, ALM register packing LOW; physical resynthesis/duplication/retiming and router duplication enabled. No settings/SDC/IP changes.

|Metric|Baseline absolute|Utilization|Change in this task|
|---|---:|---:|---|
|ALMs needed|37,117 /41,910|88.564%|0; unchanged source, no candidate fit|
|ALMs placed|38,599 /41,910|92.100%|0; unchanged source, no candidate fit|
|Fitted registers|48,880 /167,640|29.158%|0|
|Synthesis registers|46,327|—|0|
|M10K|488 /553|88.246%|0|
|Memory bits|3,818,050 /5,662,720|67.424%|0|
|DSP|39 /112|34.821%|0|
|Setup / hold|+.104 /+.239 ns|—|No new STA/build|
|Timing violations / routing failure|0 / none|—|Baseline result, not a candidate result|

Placed and needed are different:38,599−2,055 recoverable+573 unavailable=37,117. Existing unconstrained timing categories and critical warning messages remain. Router estimated average40%, peak66%. The baseline is a completed seed1 fit, not a multi-seed guarantee.

## 3. Complete 9,600-bit inventory

[inventory.md](inventory.md) enumerates all 17 meaningful field groups plus padding. [inventory.json](inventory.json) gives each width, record offset, live source/location, snapshot and restore destination, capture/restore timing, replication count, future consumer, observability and reconstruction limits.

Per slot, i=0..63: enable1; X8; cached planes d0/d1/d2/d3 each8; shift0/1/2/3 each8; wideclock1. Slot subtotal74×64=4,736 per VDP. Fixed: data_address14, m2_flags8, registered color4, registered collide1, registered overflow1, collision delay14:42 per VDP. Meaningful4,778 per VDP; padding22 gives4,800. Two independent VDPs: **9,556 meaningful+44 padding=9,600 declared ring bits**.

`rtl/savestates.sv:605`: `sprite_snap`, `sprite2_snap`. The full-width vectors through system/VDP/main are wiring, not additional register copies. Live sources reside in `rtl/vdp_sprites.vhd`, `rtl/vdp_sprite_shifter.vhd` and `rtl/vdp.vhd:190` collision delay. Restores traverse `ss_sprite_in`, validity and original architectural restore strobes.

G10 separately stores phase2 plus consumed-T1 at word02f; these are **three additional history bits**, not part of the9,600. System E owner is one validated configuration bit. Divider5, enables4, phase acknowledgment, CPU preparation, wrapper replay, beam22 and transfer/FSM controls are separately inventoried; they must not be counted as another sprite-history bank or attributed an exact physical cost from declared widths.

Physical count here means declared storage positions before synthesis transformations. Fitter duplication/retiming and constants prevent a guaranteed one-to-one mapping from source bits to fitted FF. Historical G06/G10 synthesis increase9,603 is consistent with the rings plus small control change; it is not a general per-bit ALM formula.

## 4. Snapshot duplication analysis

SAVE topology: post-T live record → ARM capture → private4,800-bit ring →75 accepted64-bit words. Each accepted word rotates the ring64 positions, returning it exactly after75 writes. LOAD uses **the same** rings:75 incoming words per owner overwrite all prior scratch state, metadata/padding/ownership are checked, then both independent records feed the parallel receiver strobes.

The snapshot copies therefore have two roles: capture isolation and inbound LOAD staging. There are not separate SAVE-only and LOAD-only 9,600-bit banks. While frozen live state can replace the former role, it cannot hold both current Q and an incoming P simultaneously without modifying Q. Eliminating a source assignment while retaining the full-width LOAD/restore interface leaves the storage in hardware.

LOAD currently restores primary and secondary architectural state in the same `ST_LOAD_RESTORE` action (`rtl/savestates.sv:2800..2833`), with independent records. A single shared ring cannot supply two different vectors at that existing consuming edge. The symbolic two-record example in [representation_checks.json](representation_checks.json) establishes this interface limitation; it does not prove a lower bound on all possible architectures.

## 5. Freeze stability analysis

Accepted host edge T executes normally. The controller asserts freeze at T; ARM at T+1 collects post-T device data. Top-level guest VDP/pixel/sprite enables are zero while frozen (`SMS.sv:1025..1028`). Every normal cache/evaluator write requires ce_spload, selected from those held enables. Shifter and registered color/collision updates require ce_pix. Collision delay requires ce_vdp. The raw-presentation overflow branch explicitly requires `ss_freeze='0'` (`rtl/vdp.vhd:652`), closing the earlier SAVE-only defect. No G06 live array is asynchronously advanced by presentation x/y alone.

Thus, for **SAVE**, with no reset, configuration/session replacement, or explicit restore strobe, induction over host edges gives live G06 record(t)=post-T record for the entire frozen interval. DDRAM busy changes private transfer progress, not guest enables. This holds independently of transfer duration and saved phase. It does not mean the private rings are stable: SAVE deliberately rotates them.

For **LOAD**, live records remain unchanged only until intentional restore; then they become the saved P records while freeze still holds. They cannot simultaneously remain a stable copy of original Q after installation. CPU private replay occurs after metadata restoration and keeps VDP/pixel/sprite enables zero. Phase/beam acknowledgment then establishes logical T+1 before release. The live register outputs are suitable SAVE sources, but no unrestricted “all state is always frozen” claim applies to LOAD writes or unrelated AudioMix presentation history.

Fresh baseline-only [freeze.log](freeze.log): **3,278,000 host-edge comparisons** of two complete4,764-bit sprite-parent records,16 mode/width configurations×four presentation-offset/duration profiles,64 total configurations. Every configuration has nonzero state and differing owner records. Maximum held interval150,000 clocks; x/y continue across x257/x496. No historical register was forced/deposited: legal legacy normalization initializes the fixture, followed by ordinary evaluator/shifter activity with different deterministic VRAM responses.

Scope: this probe instantiates unchanged production64-slot `vdp_sprites` and shifters. It excludes the14-bit VDP collision-delay extension, which is covered by source gating and retained integration evidence. Its log labels0/10/20/25 are **presentation offsets**, not actual accepted native divider captures. It is not a new G10 replay/phase sweep, a full controller SAVE/LOAD test, or a proof of reachable independent arbitrary bit patterns. Existing native phase, delay, dual-device and transport-hold tests supply the corresponding retained baseline evidence.

## 6. Reconstruction analysis

No semantic field is proposed for elimination, so no new claimed per-field reconstruction is being accepted without a reachable two-state witness. Existing G06 witnesses already demonstrate that architectural VDP state and VRAM alone do not reconstruct the required current-line cache/shifter/status-source history. Source consumer analysis explains each field's future use, but is not an information-theoretic proof that all4,778 individual bits are independent across every reachable boundary.

Already reconstructed fields remain evaluator WAITING/count0/index0: preceding x496 samples WAITING; x257 overwrites count/index before new use. Prior natural same-image histories with different index corroborate this specific omission. Derived combinational color/active, ce_spload, record concatenations and literal descriptors are not additional saved history. No further exact algorithm was found for cached planes, shifted planes, wide phase, address/flags or collision history across mode changes and all accepted phases.

The44 high padding positions are **not dead FF**. Exhaustive symbolic bit lineage over75 rotations shows every one of the22 positions per bank carries meaningful history during transfer. A tail-aware encoding could regenerate image padding, but changes ring movement/update logic and offers only44 nominal positions before overhead. [representation_checks.js](representation_checks.js) proves the present representation's rotation identity and frozen-live SAVE word equivalence; this is not RTL or reachability equivalence.

G10 phase/consumed-T history remains intact. Arbitrary transport phase, current host Pause and mixer phase do not establish a replacement algorithm. No extra guest tick, guessed canonical phase or altered CPU/NMI/PSG ordering is acceptable.

## 7. Architecture candidates

|Family / candidate|Exact mechanism and storage effect|Combinational/control and M10K effect|Timing / functional risk; decision|
|---|---|---|---|
|A semantic omission / padding trim|Remove only fields proved reconstructable; none newly established. Tail-aware ring at most44 declared positions, not4,800/9,600.|New partial-tail shift/selection and validation logic; no new RAM expected; no measured ALM gain.|No material supported target. Keep all history; padding positions cannot simply be tied off.|
|B frozen live SAVE source|Read each held live record directly instead of ARM capture.|LOAD still needs both rings, so bank count remains9,600. A new word selector/access network may replace capture muxes, with unmeasured logic trade.|SAVE stability is supported, but this alone cannot meet the storage-reduction objective. No independent large FF saving.|
|C alternate ring update organization|Share lower-word movement/head selection, extract bank process or parallel masks.|Prior extraction left FF unchanged and increased placed47; masks increased standalone ALUT9,532.0 M10K.|Already tested and unhelpful; do not repeat as a new architecture.|
|D shared single ring / reread DDR|SAVE primary then capture stable secondary; LOAD first validates both records, retains one, applies that VDP, rereads the other into same ring and applies it.|Nominal−4,800 scratch FF, zero new M10K; new read states/owner/strobe sequencing; combinational saving unmeasured.|Materially different from prior local-port RAM design, but introduces a new read after partial live install, timeout/error coherency and split restore-order obligations. Not selected without a proved failure/recovery contract.|
|D/E reuse OPLL scratch tail|Use unused rows104..253 of existing256×32 RAM for one150-row sprite record; retain other FF ring.|Capacity arithmetic fits one record:152 free rows=4,864 bits. Potential−4,800 FF with0 added M10K; requires shared-port ownership/address extension and receiver read/scatter network.|Real capacity opportunity, not ruled out by8,192<9,600. However synchronous32-bit RAM cannot drive existing4,778-bit restore edge. Reintroduces unqualified local read/write distribution plus F01 scratch ownership risk. Not selected.|
|E new sequential sprite scratch|Local32-bit read/scatter with300×32 RAM, keep all image bits.|Prior net−9,397 synthesis FF, +2M10K, roughly+5,402 logic ALUT; no qualified placed saving.|This is the rejected architecture; no new port/locality mechanism established, so do not repeat.|
|C/E destructive live scan ring|Rotate the live register record as serial scratch during SAVE and shift incoming LOAD words directly into it, with22-bit tail per owner.|Can remove scratch banks algebraically; adds scan-input choices/control across live fields, scan routing and error-recovery state; no new RAM inherently.|Different from addressed scatter, but live fields cease to be held during transport. Need all dependent-state isolation, restore interaction, complete-rotation/error recovery and first-edge proof. Not a low-risk direct reuse of frozen sources.|
|F partition restore fanout|Local replicated enables or balanced per-plane decode; keep stored history.|Storage unchanged; duplication may replace existing Fitter replication rather than reduce it. No quantified ALM saving or new M10K expected.|Measured load counts locate cones but do not identify an additive waste charge. Needs a specific equivalent local Boolean topology; none established here.|

These are structural evaluations, not implemented candidates or measured resource forecasts. One-VDP mode does not statically remove the second bank because System E is selected at runtime. Removing that feature or changing image semantics is outside scope.

## 8. Comparison with rejected sequential architecture

The prior design replaced both shadow banks with two M10Ks and added local32-bit read/scatter ports across sprite fields. Function passed; physical result did not. Seed1 failed routing:−1,615 placed was provisional, timing unavailable. Seed2 routed:38,012 placed versus38,598 baseline (−586), but setup−.100 ns, hold+.244 ns;99% LAB footprint and increased routing pressure. Neither was qualified. These are **v17-era** comparisons, not measured v19 candidate results.

The new sharing ideas differ in storage ownership or using existing scratch capacity. Neither, by itself, solves the prior expensive receiver decode/reduction topology. Reusing OPLL RAM saves block allocation but does not remove that access problem. The single-FF-ring/reread idea avoids local ports, but moves the unresolved risk to transport and partial restoration. No unchanged prior architecture or seed sweep was launched.

## 9. Selected experiment and rationale

**None selected. Phase5 gate fails.** The supported low-risk change—reuse live state for SAVE only—does not remove the LOAD rings. Significant nominal FF reductions require either the already rejected access architecture or a newly unproved restoration/failure protocol. The user explicitly directs stopping here if no candidate is sufficiently supported. No permission question or new speculative implementation is needed to make this decision.

The closest new mechanism is single-ring owner sequencing. Counterexample to treating it as mere storage aliasing: fill ring with primary P1, then secondary P2≠P1; the original simultaneous strobe requires both, but a shared bus supplies only P2. Splitting strobes and rereading can solve that successful-transfer case, but now a watchdog expiry on the added read occurs **after** one owner has been installed. `ST_ERROR` currently clears freeze and returns idle; rollback/current-Q preservation or a different recovery policy would need proof. Existing LOAD is not generally whole-memory transactional, so this is not a claim that all failures currently roll back RAM. It is an unresolved additional live-VDP mutation/failure point and extra transport-dependency contract.

## 10. RTL changes

**None.** Baseline-only tests and investigation artifacts reside under this directory. No local optimized RTL, format change, new synthesized module, QSF/SDC alteration, or unrelated cleanup was created. Thus no revert operation was required.

## 11. Functional proof

Fresh evidence is limited to frozen-live-state stability and exact symbolic current-representation identities, as scoped in sections5–6. Both probes pass. They support the investigation; they do not qualify an optimization.

Retained baseline simulation results are preserved by hash, including G06/G10 native sprite/phase/pending/dual-device/stall/repeated-LOAD campaigns, F01 state/long-suffix/legacy proofs, and current G08.FM first-pair/source/event/OPLL-row regressions. They were not copied into a new candidate PASS count. No full relevant G06/G10 regression was rerun against an optimized controller because no controller was implemented.

## 12. Shared regression

Not triggered: no shared transfer infrastructure or VDP organization changed. No claim of a newly rerun G02–G06/G10 or FM regression. Any future shared-ring, RAM-tail or receiver-port implementation must rerun the affected complete-image/format/stall/error/repeated-LOAD suites plus G02–G06/G10, and F01/G08.FM if its scratch or ordering changes. Legacy missing-history behavior, System E, Pause and first resumed observations must remain explicit.

## 13. Quartus resources

No new map/fit/STA/confirmation run. Phase10 is downstream of selection and simulation gates, which were not reached. Baseline values/utilization and unchanged-source deltas are in section2. Candidate needed/placed/FF/M10K/memory/DSP, warnings and routing: **not measured**, not zero or projected. No source-width calculation is substituted for placed ALMs.

## 14. Timing analysis

No new candidate path exists. Retained current worst setup: HDMI shadowmask RAM→OSD dsp_width[19],+.104 ns,1 logic level,4.485 ns data interconnect+1.268 ns cell delay. Core worst mapper rom_crc32[17]→T80 IR[3],+.895 ns,14 levels,10.732 ns interconnect+6.209 ns cell delay. Hold: primary shifter60 shift0[2]→[3],+.239 ns.

The structural audit's existing read-only source queries give ARM+6.259 ns, primary restore+8.589,secondary restore+4.996,freeze+4.435. High fanout is therefore not established as the current worst setup cause. Prior sequential seed2 failed in HDMI, with core timing improved; physical placement/routing sensitivity remains an unresolved risk. There is no “first new critical path” to attribute in this task, and no confirmation build was justified.

## 15. Fanout changes

None measured or introduced. Baseline Fitter:ARM9,670;z80_set5,901;secondary restore5,448;LOAD header5,265;ring controls4,800–4,811;has_restart1,410. Retained physical optimization ledger has2,080 VDP-source duplication records; these are transformation rows, not2,080 independently removable ALMs. Partitioning controls without a concrete Boolean/placement hypothesis is not a supported savings claim.

## 16. RAM inference changes

None. Both sprite scratch rings remain FF. Full-bank capture/reset/clear, rotation and parallel restore conflict with ordinary one-/two-port RAM. Live shifters have concurrent pixel outputs and shifts; cache versus shifted data are not interchangeable. OPLL scratch remains one256×32 M10K; the arithmetic tail capacity finding is **feasibility only**, not a proved shared-memory design. Do not count spare bits in an allocated block as recovered ALMs.

## 17. Measured savings

**No savings.** Unchanged production and retained build remain38,599 placed ALMs. No candidate fit or tested optimization delta exists. The probe establishes stable live sources; it does not recover storage. The possible−4,800/−9,600 shadow FF counts in section7 are topology changes before replacement logic, not measured FF/ALM savings or promises.

## 18. Functional risks

Significant unresolved risks are partial restore/error recovery for a DDR second pass, System E independent ownership and restore order, local port/decode pressure for RAM, OPLL scratch address/command arbitration, destructive scan isolation, malformed-image validation, and exact phase/beam/CPU/NMI/PSG/FM release semantics. Padding positions, inactive mode planes and live/scratch lifetime duplication must not be removed on appearance alone.

This conclusion does not prove every retained bit minimal, that no storage architecture can work, or that no next experiment is possible. It says no reviewed mechanism presently meets the requested evidence/functional-risk/timing-risk/scope selection gate. Existing closure contracts remain unchanged.

## 19. Final keep/revert decision

**E. NO SAFE CANDIDATE IDENTIFIED.** Investigation stopped at Phase5, as authorized. Production remains committed v19; nothing to keep or revert. No build, commit, push or PR.

## 20. Recommended next optimization target

Follow the structural audit's bounded **CRAM snapshot/read-interface** candidate:384 live bits per palette, full combinational snapshot exposure and32:1×12 read mux, both clock ports actually tied to clk_sys. This has a more isolated inference blocker than another global sprite storage conversion, but no saving is promised and no CRAM work was performed here.

If G06/G10 must remain the next target, first establish a specific local receiver/scan topology or shared-ring failure-recovery contract before another full implementation. In particular, the newly identified4,864-bit OPLL tail can hold one sprite record, but requires a narrow, ownership-proven access design that avoids the prior routing network. Capacity arithmetic alone is insufficient authorization to repeat that network.

## 21. git diff --stat

```text
(empty)
```

Audit/test artifacts are untracked and absent from ordinary diff statistics. [verification.json](verification.json) binds unchanged production, prerequisite report hashes, probe results and this report's22 sections.

## 22. git status --short

```text
?? tests/
```

Branch `optimize/g06-g10-snapshot-storage`; HEAD unchanged; index empty. Generated simulator library files are locally ignored. Only this investigation's report, tests and evidence were added; historical evidence remains untouched.
