# Ys investigation continuation — 2026-11-13

**Recommendation: NO-GO for a production fix or a claim that Ys is fixed. GO for a small integrated restart experiment.** A master-based three-bit predecessor correction is sufficient for the demonstrated instruction defect and the standard Ys startup witness. It is not yet a proven fix for the reported first-screen movement corruption.

This report supplements, and does not overwrite, ../REPORT.md. All new work is in this directory. Production RTL, sys/, existing worktrees/RBFs/reports, master, the FM integration and PR227 remain untouched. No commits, merges, pushes, PR mutations or Quartus builds. Final protected refs and source/log hashes are in final_results.json.

## Confirmed reference and exact missing features

Historical reference: fbreve/SMS_MiSTer, investigate/cram-memory-inference, **1b2a52d87d2659c908d4f9f846416d14bfd85bea**, verified locally and read-only through GitHub. The reported good hardware result is accepted as user evidence; RBF provenance and approximately93% utilization remain independently unverified. This is distinct from the FM-only v19 port.

Master is **66f16d5c656fd8906d62570da4d258875bcee684**. The current checkout remains **8cd53ccc954c24970372ea6d8a3fb2336a14c46f**. The user confirms the issue predates PR227, so FM optimization is not the working explanation.

[HISTORICAL_AUDIT.md](HISTORICAL_AUDIT.md) documents the commit-level split:

- **8ffd15e2** records the six predecessor classes ordinary/CB/ED/DD/FD/EI and seeds IR at DIRSet. ISet=00 at acceptance does not exclude a preceding ED/CB/index prefix or an EI action still consumed on historical T2.
- Its **faf7036e** dependency restores three normalized NMI-history bits after DIRSet and suppresses sampling during reconstruction. This is a separate correctness mechanism.
- **58583189** completes historical CPU preparation with VDP held, routes CPU reads during preparation, restores divider phase through a falling-edge handshake, then commits video/release. It also packages a large sprite-history snapshot and freeze fixes; those are not required merely to test the sequencing mechanism.
- **f205b05d** restores139 background-history bits per VDP. Its general equal-image/different-visible-future evidence is valid, but no Ys-specific need for that storage has been established.
- Broader v19 also preserves all32 KiB physical Sega SRAM regardless of visibility (854761c3). This is another potential distinction to check at the game scene, not bundled into the CPU correction.

The broad reference does not save an additional pending xram_cpu_A_incr bit; both paths normalize that flag on restore. No evidence justifies starting with that bit or importing full sprite/background storage.

## Minimal test-only implementation

prepare.js reads pinned master sources with git show and adds only RestartContext/RestartDIR/RestartValid, a three-bit encoder of the preceding IR and its representative restore mux to T80/T80s. Existing IR storage is reused. No NMI correction, renderer state, FM state, system glue or production format is imported into this context-only variant. Observation ports expose IR/MCycle/TState without forcing them.

The test harness captures architecture/context before naturally eligible T, retains the reference after T, restores the candidate, privately performs historical T1/T2, and compares at canonical k=0 and700 subsequent CPU ticks. Side records are test-only: **the production DDR writer/reader and native release FSM are not integrated into this candidate**. That distinction prevents interpreting the tests as complete savestate compatibility or native timing validation.

Control variants use the historical CPU/NMI wrapper directly, normally executing the same guest program, then either enable or disable only predecessor restoration. This is a two-way CPU-mechanism test, not a full historical-core simulation.

## Deterministic regression results

The final98 CPU cases and32 production-VDP access cases are validated by collect_results.js; each CPU continuation checks701 canonical samples. See matrix_results.json and vdp_matrix_results.json.

| Variant | 12 inactive-interrupt instruction cases | 25 interrupt cases | 8 production-VDP access cases |
| --- | --- | --- | --- |
| Master behavior, context disabled | ordinary passes;11 differ | not rerun | ordinary passes;7 differ |
| Master + three-bit context | **12/12 equal** |15 equal;10 capture-edge/held-low NMI cases differ | **8/8 equal** |
| Historical CPU/NMI restart + context | **12/12 equal** | **25/25 equal** | **8/8 equal** |
| Same historical CPU/NMI restart, context disabled | ordinary passes; same11 differ | not rerun | ordinary passes; same7 differ |

Instructions cover CB rotation, ED arithmetic, DD/FD register changes, indexed DD/FD-CB, mixed prefix chains, EI, EI/HALT, LDIR and OTIR, plus an ordinary boundary. Interrupt controls include held INT at EI, later INT, NMI on capture, NMI held low and a new post-LOAD NMI waking HALT. The predecessor-only NMI failures omit a handler observed by the reference; they are pre-existing NMI-history omissions, not evidence that the predecessor correction introduced an NMI regression. Existing historical all-triplet/repeated-load evidence is reused and clearly separated from the new tests.

The VDP tests instantiate the production VDP and vendor RAM model, use a controlled blank/static beam and stop the renderer. They compare ordered real port-A writes, not just CPU output vectors. In the OTIR witness, master-style restoration loses three bytes: reference has5 VRAM writes and restored execution2. Context restoration yields5/5, with first writes address0/data81 and address1/data5A matching. The first CPU divergence is ISet at k=0; the first active bus difference is k=2; the first VDP-port transaction differs. This is a deterministic defect/correction result, not a rendered Ys frame comparison.

### Reset and changed-history controls

The latest user clarification is material: on the first playable screen, SAVE; then **either reset or leave the screen**; LOAD; move left/right, turbo disabled. Same-screen LOAD without either intervening action is unconfirmed.

An additional24 production-VDP access probes cover a DUT reset before LOAD and700 ticks of different pre-LOAD guest execution. They initialize VRAM through public DMA, restore the synthetic snapshot's VRAM through that port after the changed-history run, restore CPU RAM/control state, and compare the same future. These are cold/dirty-state controls, not an emulation of an actual environment transition. For ordinary/EI/LDIR/OTIR, both corrected variants match all8 reset/changed-history probes each; master behavior matches ordinary only (2/8). preload_results.json records each result. No extra production state was added to make these controls pass.

## Actual local Ys diagnostics

Both user-confirmed revisions were found outside this workspace. They are read in place at runtime: no ROM, conversion, hexdump, memory checkpoint or copyrighted excerpt is copied or packaged. Identity hashes:

- Standard USA/Europe/Brazil,262144 bytes: 02e9404e81bddd4ca21fef2b2711dfe562c3bd7b230bf042df3142362e29a6a9.
- Japan,262144 bytes: 816ddb63d3aa30e7c4fc0efb706ff5e66f4b6f17cf331d5fc97f6681d1905a61.

The reduced harness runs the real ROM, real T80, production VDP/video and vendor VRAM model, with direct Sega bank/WRAM/SRAM models. It selects a natural ED B0/B3 fetch with ISet=00, VBlank and x<256; no CPU microstate is forced to create it.

| ROM | Candidate | Result | Evidence |
| --- | --- | --- | --- |
| standard | master-style restore | different; architecture first=0, bus first=2; WRAM differences=1, SRAM differences=58, mapper different | [ys_standard_current_sram.log](ys_standard_current_sram.log) |
| standard | context-only restore | equal; architecture first=-1, bus first=-1; WRAM differences=0, SRAM differences=0, mapper equal | [ys_standard_context_sram.log](ys_standard_context_sram.log) |
| japan | master-style restore | incomplete bounded probe | [ys_japan_current_sram.log](ys_japan_current_sram.log) |
| japan | context-only restore | not run | [ys_japan_context_sram.log](ys_japan_context_sram.log) |

For the standard ROM, the witness is startup PC07C0, beam(30,192), BC17D6, HL8828, DE8829, mapper control88, pages0/1/2. Control88 enables SRAM bank0. The corrected and master-style probes capture the same values. Master loses ED immediately, reads B0 correctly but decodes it without that prefix, then diverges in bus accesses two enabled steps later. After700 steps, one WRAM byte and58 SRAM bytes differ and mapper state differs. With the context correction, architecture, active bus projection, WRAM, SRAM and mapper all match through that continuation. **No VRAM writes occur in this continuation window.**

Thus the CPU defect is now demonstrated on real standard Ys code, beyond the synthetic ED B0 program. It supports the CPU hypothesis as a mechanism capable of corrupting game state. It does not connect that startup corruption to the specific first-screen walking artifact.

The Japanese probe did not deliver a qualified comparison within its600-second process bound; the paired context trial was not run after that failed prerequisite. It is inconclusive, not a rejection of the hypothesis and not a pass. That runner's failed completion assertion is recorded as an incomplete ROM diagnostic, separate from passing regressions.

Important limits: these are not complete MiSTer simulations. ROM/WRAM/SRAM reads use direct models rather than the actual SDRAM/WRAM routing and latency; not all IO/controller/counter ports are modeled; renderer uses the ordinary8-sprite configuration; the Japan-specific ysj_quirk is not enabled in this reduced probe. CPU ticks have15-host-clock spacing here, but their full native phase and the master restore controller are not reproduced. Reference and restored guest time are aligned canonically by the harness, including private preparation, rather than exercising master's actual unfreeze sequence. No reset-to-first-playable-screen or left/right movement reproduction has completed. The first standard-ROM probe lacking SRAM handling is superseded and excluded from final results.

## Snapshot bits, validation and resources

Both master and public FM writers zero CPU word5 bits63:38; both readers take only37:0 for current CPU architecture. The old64 KiB branch has a different lower-word interpretation and must bypass any new extension. Historical broad v19 used43:41 for context and40:38 for NMI, but identifies its larger format through video tags that are incompatible with current FM tag/padding assumptions.

format_audit.js tests a **proposed codec only**: CPU word5 owner63:48, version47:44, class43:41, NMI40:38, existing architecture37:0. It passes48 class/NMI roundtrips and rejects four malformed owner/version/class cases; zero upper26 bits and old64 snapshots retain legacy fallback. This owner is a proposal, not an allocated format. No DDR FSM was changed or validated. A real implementation must update both combinational command generation and sequential helper write paths, reject malformed context before applying state, and test live readback/legacy paths. Old readers ignore context and cannot guarantee exact execution of a new snapshot.

The public FM video padding39:22 is explicitly checked as zero; it cannot silently become a phase/context payload. The codec above also does not allocate the additional phase/actual-tick metadata. These are open integration decisions, not a claim that spare bits automatically solve compatibility. FM's100-word descriptor/payload need not change for a separate CPU extension.

Expected incremental cost for predecessor context is three snapshot bits and small decode/mux/routing, reusing the live IR register, with no new FM RAM/DSP or sprite/background bank. If needed, NMI history and private preparation/phase require a few further metadata/control bits and a small sequencer. Exact ALM, register and timing deltas remain unknown; no Quartus build was allowed or run.

## Smallest next experiment and GO/NO-GO

**NO-GO production at this stage.** The instruction defect is confirmed and the narrow correction is warranted as a test candidate. The native release, compatibility and reported map-scene gates remain open; the Japanese ROM probe is incomplete. Do not describe Ys graphical corruption as fixed.

The next experiment should use **current master + only the predecessor field/restore mechanism**, with a versioned test-only word5 extension in the actual DDR save/load path. Keep the optimized FM path unchanged and first retain master's release behavior as a control. In each ROM separately, turbo off: start the first playable screen, SAVE, then (A) reset or (B) move to another environment, LOAD, move left/right. Also run the same-screen/no-reset control because that behavior is unknown. Never interchange historical/current FM snapshots.

Capture pre-SAVE and immediately-post-LOAD VRAM/WRAM/all physical SRAM, mapper and CPU context, plus native CE phase. Compare against that implementation's own uninterrupted continuation; stop at the first architecture/read-data/mapper/VRAM-write divergence, before a visible bad tile. A small ordered transaction ring should include PC/IR/context, bus strobes/address/data, VDP address/control latches and actual VRAM WE/address/data. Exercise real memory-read routing during refetch, not the direct model used here.

If context alone restores CPU semantics but the first access occurs at the wrong beam/CE position, add **only** private T1/T2 preparation, correct read routing and divider commit from58583189. Existing two-pixel evidence makes that an explicit second mechanism, not a reason to import sprite records. If all CPU transactions and memories match but pixels still differ, compare the background-history fields at the first differing pixel and intervene only in the proven field/cone. Do not import the complete139-bit record or full sprite state without a Ys-specific witness. Check SRAM visibility/bank use at the real SAVE as another independent v19 difference.

GO means a deterministic red/green exact-scene regression through the real controller, compatibility rejection/readback tests, and no new interrupt/transaction failure for the selected correction. Only then is a separately authorized resource/timing build appropriate. No broad optimization campaign is proposed.
