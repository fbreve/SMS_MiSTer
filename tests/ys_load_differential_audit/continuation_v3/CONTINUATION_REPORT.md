# Ys LOAD investigation — native controller continuation

2026-11-13. Continues the v2 report without replacing it. **Production NO-GO. Ys graphical corruption has not been reproduced or resolved in this experiment.** The completed A/B simulation is inconclusive because it did not reach the first playable screen or qualified map updates.

## Source and isolation

- Master source: `66f16d5c656fd8906d62570da4d258875bcee684`.
- Existing checkout/FM integration HEAD: `8cd53ccc954c24970372ea6d8a3fb2336a14c46f`.
- Expanded historical reference: `1b2a52d87d2659c908d4f9f846416d14bfd85bea`, branch `investigate/cram-memory-inference`. This is distinct from the newer FM-only v19 worktree. Hardware/RBF provenance and utilization remain independently unverified.
- Pinned master files were extracted with `git show`; existing checkout content was not presumed to equal master. `manifest.json` records source hashes and previous report hashes. Final tracked status is clean; these refs remain unchanged.

All new sources, generated simulation data and results are confined to this directory. No production RTL, sys/, existing worktree, previous report, ROM, RBF or savestate was overwritten. No commits, pushes, merges, PR operations or Quartus builds were performed. ModelSim compilation/simulation was used.

## Test-only candidate

`prepare.js` produces a copy of the actual master savestate FSM in `savestates_probe.sv`, with a parameter selecting A (current behavior) or B (predecessor context only). Both use the same native CPU/VDP dividers, actual mapper and IO RTL, and production CPU `T2Write=0`. Both retain the full 900000-clock controller flush. There is no private CPU preparation, NMI-history restoration, clock-phase restoration or background/sprite snapshot in B.

B captures the existing six-class predecessor encoding (three bits) alongside the accepted CPU snapshot. CPU word 5 upper bits contain proposed owner `4352`, version 1, class, and zero reserved bits; architecture bits 37:0 are unchanged. Both controller write paths are updated. The reader validates owner, version, class and reserved bits before restoring CPU or memory. Zero upper bits use legacy behavior; the old 64-KiB path bypasses this extension. This is an experimental allocation, not a production format decision. Old readers ignore the extra context and cannot promise exact continuation of a new snapshot. No FM payload/descriptor changes are proposed.

The full harness uses master VDP/video, standard eight-sprite mode, NTSC/export, BIOS disabled, and turbo disabled. External ROM is read in place. Synchronous ROM/WRAM/SRAM service models replace physical SDRAM; deterministic DDR reads take three host clocks. PSG/FM snapshot inputs are quiescent placeholders, not complete audio simulations. Common cold initialization sets unknown behavioral-model storage to zero in A and B; this initialization does not run again at the intervening hard reset. The behavioral VRAM model was checked against the vendor primitive for 128 read/write cycles, including same-port NEW_DATA and mixed-port OLD_DATA collisions (`ram_equivalence.log`). These are material harness limits.

## Exact attempted reproduction and results

Standard USA/Europe/Brazil ROM SHA256: `02e9404e81bddd4ca21fef2b2711dfe562c3bd7b230bf042df3142362e29a6a9` (262144 bytes).

Each run starts independently from cold initialization and generates its own controller savestate. Parameters: `CANDIDATE=0` or `1`, `BOOT_FRAMES=60`, `ACTION=0`, `MOTION_STEP=1`. `compile.do` builds the isolated sources; `run.do` reads `YS_CANDIDATE`, `YS_BOOT_FRAMES`, `YS_ACTION`, `YS_MOTION_STEP`, `YS_ROM`, and `YS_OUT`.

1. Boot for 60 video frames. After each frame, Fire1 is asserted when `frame >= 2 && frame % 8 < 2`; otherwise inputs are neutral. This was an exploratory input movie, not a verified game-start procedure.
2. Request SAVE through the actual controller and wait for completion.
3. Apply hard reset for 128 host clocks, clear modeled WRAM, retain physical SRAM/VRAM and the DDR slot, then wait eight video frames.
4. Request LOAD through the actual controller and wait for completion.
5. Wait five frames neutral, hold left for four frames, then right for eight frames, taking per-frame memory/image checkpoints.

Both runs completed at host cycle 76892132, video frame 85. Evidence: `baseline.log`, `candidate.log`, their `_events.log` files, checkpoint `.mem` files, and machine-readable `comparison.json`.

| Observation | A: master behavior | B: context only |
| --- | --- | --- |
| SAVE acceptance | cycle 53523101, frame 60, beam 9/192 | identical |
| CPU at SAVE | PC 0C0E, prior IR 12, context 0 | identical |
| Mapper at SAVE | 0040000003050100 | identical |
| LOAD acceptance | cycle 60719396, frame 68, beam 2/192 | identical |
| CPU restore | cycle 60759502, PC 0C0E, context invalid | same cycle/PC, context 0 valid |
| Immediate restored VRAM/WRAM vs own slot | zero differences | zero differences |
| Complete physical SRAM vs own pre-SAVE SRAM | zero differences | zero differences |
| Checkpoints compared | 21, all memory bytes equal A/B | identical |
| CPU enabled samples after LOAD | 20000 | identical active-bus/decoding projection |
| VDP data/control writes after LOAD | 3440 | identical |
| Actual VRAM writes after LOAD | 3072 | identical |

Each checkpoint contains 32768 VRAM bytes, 8192 WRAM bytes and all 32768 physical SRAM bytes. Register logs include CPU, VDP and mapper state. Port traces include command/address state; actual VRAM writes include address, data and beam position. There is no first divergence in these recorded comparisons. This does not establish that B eliminates or delays a map failure: the saved predecessor class was zero, so the intended correction was not exercised at this SAVE.

**Scene qualification failed.** SAVE images have display disabled; later images show startup/intro graphics rather than a verified playable first screen. Directional input and VRAM writes during startup do not qualify as affected map updates. There is no uninterrupted playable-map reference in this result. CPU tracing is capped at the first 20000 enabled samples and ends before the movement input; port/VRAM tracing continues through the end. Future qualified runs must retain a CPU ring or additional trace window during movement.

Diagnostic image caveat: the executed harness exported PPM with red and blue exchanged relative to SMS.sv's color wiring. This affects screenshot colors, not memory/transaction comparisons or the display-disabled observation. Do not interpret these images as color-accurate hardware captures. Earlier bounded discovery logs are exploratory/aborted and are excluded from the comparison above.

## Regression results

Previously completed v2 evidence is retained: 98 CPU, 32 VDP-access, 24 reset/changed-history cases, and the standard-ROM startup ED B0 decoding witness. That witness remains evidence of a real CPU defect, not proof of graphical causality.

New results address actual integration differences:

- `cpu_native_results.json`: 39 expected outcomes with production `T2Write=0`. Context-only candidate matches the reference in 27/27 cases: twelve instruction/boundary cases plus fifteen applicable held/later INT and new post-LOAD NMI cases. Baseline ordinary boundary matches; eleven predecessor cases differ as expected. These tests do not claim to repair capture-edge/held-low NMI-history omissions documented in v2.
- `protocol_results.json`: eight actual-controller cases pass. Current roundtrip, candidate roundtrip and legacy zero-metadata fallback restore VRAM16K/WRAM8K/SRAM16K. Five malformed metadata cases reject before memory writes or CPU restoration. The old-format bypass is present in source but is not a new complete old-format roundtrip regression here.
- `ram_equivalence.log`: 128-cycle vendor/model equivalence passes.

## User-supplied physical save: separate evidence

Read-only inspection of `\\mister\sdcard\savestates\SMS\Ys - The Vanished Omens - FM Sound Restoration (USA, Europe) v1.2_4.ss` succeeded. No raw save copy was made and it was not loaded in simulation. Details are in `hardware_state_metadata.json` and `rom_owner_results.json`.

- Size 98304 bytes; SHA256 `94c26472d08c58e42935a825ebb8e19569a8e245096a26390b7ca78ae5430576`.
- Game ID `5bc7d104` matches the local FM Restoration v1.2 hack, SHA256 `480d3c638b578e2831c8fad3d4b24a0a733e68ee9d5bb42b45ef38cf06311994`. The signature calculation follows SMS.sv. Neither standard nor Japanese ROM matches. Filename alone was not used to assign ownership.
- Public FM descriptor `00640101464d5331`, video tag `484311`, no predecessor metadata. This is not an expanded historical-v19 save.
- CPU PC 1A60, SP DFEA; VDP display enabled. The file alone does not identify the preceding opcode or prove the exact playable location.
- Mapper `0040000003070100`: SRAM enable/extension flags are zero. Under the current master's `has_nvram` conditions, **zero SRAM bytes are captured/restored for this mapper state**, despite a fixed-size file. Contents of an unwritten tail must not be treated as valid saved SRAM.

This makes one historical difference concrete: expanded v19's `transfer_full_sram` preserves the complete physical 32-KiB SRAM backing on SAVE for the applicable ordinary cartridge configuration, independently of its current mapper visibility. Master conditions the transfer on active mapper flags. This mechanism is absent from both A and B. It is a plausible independent explanation for correct existing VRAM followed by bad graphics generated from changed offscreen game data, but that explanation is an inference, not a demonstrated Ys causal chain. The current startup A/B happened to recreate identical SRAM after reset, so it does not test the hazardous case. No incompatible FM/v19 savestates were exchanged.

## Decision and smallest next experiment

**NO-GO for a production fix.** The CPU predecessor defect remains supported; this new run neither establishes nor rejects it as the cause of the walking corruption. No Ys graphics fix can be claimed. The larger historical restart timing and background-history mechanisms remain separate candidates; none was added.

The smallest prerequisite is a verified first-playable-screen input movie for the standard ROM (or a matching standard-ROM physical save to locate/validate the scene), with region/BIOS matching the test. The supplied hack save must remain separate. Extend boot until the scene is visually verified, then generate independent A/B snapshots through the controller and run the same reset/LOAD/movement sequence against an uninterrupted reference. Keep CPU trace windows during movement and stop at the first differing read, mapper transition or VRAM write. A nonzero predecessor SAVE is needed to test this candidate's causal role.

At that qualified SAVE, compare **all physical SRAM** before SAVE and after LOAD even when disabled. If it differs, trace its first later read into the bad map update. Then test SRAM preservation alone as an independent intervention, with the same baseline movie; do not combine it with predecessor/timing/background changes. A synthetic SRAM-omission test would verify transport behavior but would not alone establish the Ys cause. If CPU semantics are corrected and SRAM is intact while the map still corrupts, advance to restart timing and then the earliest proven background field, individually.

Expected predecessor implementation cost remains three saved context bits plus small capture/decode/mux/validation logic, without new FM storage or complete VDP pipelines. Exact ALM/register/timing impact is unmeasured. Full physical SRAM preservation could reuse the existing 32-KiB transfer path and slot region, but requires explicit format validity/legacy handling so unwritten old tails are never restored; it is not yet a production recommendation. No broad optimization or full-v19 restoration is warranted.
