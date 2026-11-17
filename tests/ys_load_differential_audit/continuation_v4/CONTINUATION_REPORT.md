# Ys LOAD investigation — physical SRAM experiment (v4)

Date: 2026-11-14. Test-only investigation; no production patch or FPGA build.

**GO to propose the narrow physical-SRAM correction.** The playable standard-ROM environment-change case reproduces progressive map corruption in baseline, and physical-SRAM preservation alone prevents it for the entire tested sequence. Predecessor-only does not help this case. A timing-matched discarded-write control restores the corruption. This is a causal simulation result, not a claim of a verified hardware fix, Japanese/FM-hack coverage, or permission to modify production now.

## Source and scope

- Baseline: master `66f16d5c656fd8906d62570da4d258875bcee684`, copied into this isolated test directory.
- Existing checkout / optimized FM integration: `8cd53ccc954c24970372ea6d8a3fb2336a14c46f`; read-only integration checks, not the simulated master baseline.
- Historical expanded reference: `1b2a52d87d2659c908d4f9f846416d14bfd85bea`. Only its complete physical SRAM mechanism motivates B; its CPU, clock, NMI, sprite and background machinery is not imported.
- Protected earlier reports and initial tracked-source status are recorded in `provenance.json`. Native executed-source hashes are in `candidate_v2/native_source_manifest.json`.

All new implementation and results are under this v4 directory. No `sys/`, production RTL, existing worktree, RBF, historical artifact or earlier report was edited. No commits, pushes, merges, PR operations or Quartus builds were performed.

The local standard USA/Europe/Brazil ROM is read in place, SHA256 `02e9404e81bddd4ca21fef2b2711dfe562c3bd7b230bf042df3142362e29a6a9`, 262144 bytes, computed savestate game ID `a458e3d4`. No ROM was modified or copied into the audit. Japanese and FM hack map-level A/B tests are not claimed.

The user's supplied FM Restoration save was inspected read-only, not loaded into this different ROM. It is 98304 bytes, SHA256 `94c26472d08c58e42935a825ebb8e19569a8e245096a26390b7ca78ae5430576`, game ID `5bc7d104`, mapper `0040000003070100`, SRAM disabled. A background-only preview is `hardware_background.png`; it is not a reconstructed execution test.

## Stage 1: playable map reached

The earlier startup stopping point was too early, not proof of a CPU hang. With NTSC/export region, BIOS disabled, turbo disabled, ordinary Sega mapper and the standard ROM, cold Fire1 pulses on frames 8/9, 16/17, ... 144/145 reach the playable castle-town map by frame 150. The fixture uses `frame>=2 && frame%8<2`; no directional input is applied during boot. Display enable occurs around frame62; asset setup continues beyond frame120. The CPU's `0046–004C` loop polls WRAM `C021`; it is an ordinary wait loop.

Evidence: `discovery_boot150.png`, `discovery_running.log`, `startup_analysis.json`, `intro_control_flow.json`. A separate cold seed run reproduces the frame150 image and all 73728 captured memory bytes exactly. Frames1/5/10/30/60 also match the previous v3 cold run (`cold_prefix_comparison.json`). The first map changes 938 physical SRAM bytes versus startup, within `0400–07EF` (`startup_sram_delta.json`). SRAM's power-up FF initialization agrees with pinned master's `nvram_ff.mif`; it is not an invented zero-filled cache.

ModelSim PE does not support the attempted process checkpoint operation (`checkpoint_probe.log`). To avoid five redundant cold boots, the actual master controller exports a legacy seed slot and a **separate physical SRAM fixture** at the same freeze. `candidate_v2/seed_manifest.json` validates the slot, game ID, all VRAM/WRAM payload and the separate SRAM image. The unmarked slot's tail is never treated as a complete SRAM image.

Each experiment initially LOADs that common slot through the actual controller and installs the separate physical SRAM fixture once during this initial setup freeze. It then waits five guest frames and the normal 500ms controller cooldown before its own independent SAVE. No fixture SRAM is injected during the tested LOAD. Five independently generated saves have identical comparable CPU/VDP/CRAM/IO/video/VRAM/WRAM/physical-SRAM state (`candidate_v2/e_saved_slot_validation.json`). All save with SRAM disabled and predecessor class0.

## Exact experiment

Actual master savestate FSM, T80 CPU with production `T2Write=0`, VDP, mapper, I/O and native clock enables are simulated. VDP-generated interrupts remain live; Pause/NMI is inactive. Video exports use corrected RGB channel order; older v3 previews had red/blue swapped. Normal eight-sprite configuration is retained.

Variants:

| Run | Active change |
|---|---|
| `e_baseline` (A) | None |
| `e_sram` (B) | Complete physical SRAM preservation only |
| `e_context` (C) | Predecessor-context correction only |
| `e_reference` | Uninterrupted post-SAVE execution; skips history and tested LOAD |
| `e_sham` | B's valid slot, DMA commands and timing; suppress only physical SRAM writes during the tested LOAD |

The sham is a negative control for added freeze/DMA time, not a proposed fix. D (both corrections) is unnecessary unless B alone fails or the scene requires nonordinary predecessor context. No variant enables historical NMI history, clock-phase restoration or background/sprite snapshots.

Common tested sequence: SAVE in town; hold UP112 frames, then neutral40, passing through the north gate into the outdoor coast/bridge scene; verify changed physical cache and display enabled; LOAD the run's own save; neutral5; LEFT8; RIGHT80; DOWN16; RIGHT64. Checkpoints/images are taken every four movement frames. The DOWN/RIGHT extension clears the tree that blocked the first pilot's horizontal movement and reaches actual background map updates.

`candidate_v2/prepare_environment_case.js`, `ys_environment_load_tb.sv`, `environment_case.do` and `run_environment_variants.js` define the reproducible case. `environment_new_environment.png` from the path-discovery run verifies the outdoor scene. All five SAVE contexts are validated independently in `e_saved_slot_validation.json`.

At SAVE: mapper `0040000003060100`, SRAM enable0/bank0, physical SRAM SHA256 `72bcb4c802a59aae1974df38df197cfbd439c3abef83d921775aa9a061ffa334` (FNV `eeee267280e5dabb`). Natural environment change replaces 889 bytes in cache window0400–07FF and 1479 physical SRAM bytes overall. These are game writes, not artificial corruption injection.

At LOAD, all tested variants restore VRAM/WRAM exactly from their own slots. A/C transfer no SRAM and retain 1479 wrong physical bytes. B transfers4096 DDR64 words each way and restores all32768 bytes exactly. Sham transfers the same payload and attempts32768 byte writes but intentionally retains the wrong physical contents. Immediately after a complete rendered frame, the restored town still looks correct in A and B; the `loaded.ppm` image itself is stale framebuffer content and is not used as evidence of successful rendering.

## First data divergence already established

`candidate_v2/early_sram_reads.json` and raw `e_*_events.log` identify the first stale cache read:

```text
A/C: N 317521 4ab6 8419 0419 00 00 2 2 01 0044000003070100
B:   N 317523 4ab6 8419 0419 80 00 2 2 01 0044000003070100
sham:N 317523 4ab6 8419 0419 00 00 2 2 01 0044000003070100
```

CPU address8419 maps to physical SRAM0419. The saved town requires80; later-environment SRAM contains00. Mapper SRAM is enabled for this subsequent read even though it was disabled at SAVE/LOAD. B and sham differ at the same post-LOAD clock, ruling out their equal DMA delay as the explanation for that read. `N` records physical read data, not just mapper visibility. The shown PC is the CPU's architectural observation at the access; no unverified meaning is assigned to bit80.

B/sham agree for2570 raw opcode-fetch records (including the common replayed SAVE fetch) before their first subsequent execution divergence (`timing_control_first_divergences.json`); the normalized comparison counts2569. C retains the bad read: restoring an ordinary predecessor class0 cannot reconstruct missing physical SRAM. The independently established ED/CB/DD/FD/EI predecessor defect remains real but is a separate issue until tested in an affected save context.

The first scrolling-column write differs at3821 (00 versus80), but bit7 of a Mode4 name-table high byte does not affect rendering. The first **rendering-relevant** differing map entry is VRAM3A20: baseline12 versus SRAM-only/reference1A. The observed source path is:

```text
A: N 119360926 2bae 8462 0462 12 83 2 2 01 0044000003020100
A: W 119360972 2bae d820 12
A: P 120149524 26be 12 3a20 0 0
A: V 120149527 3a20 12 155 215
B: N 119360688 2bae 8462 0462 1a 83 2 2 01 0044000003020100
B: W 119360734 2bae d820 1a
B: P 120149404 26be 1a 3a20 0 0
B: V 120149409 3a20 1a 143 215
```

Thus the game reads the later environment's tile from physical SRAM0462, stages it in ordinary WRAM, and issues the wrong VDP data write. The wrong tile is present before rendering; this is not a speculative VDP background-latch explanation. `candidate_v2/first_map_column_evidence.json` retains source-line numbers, column writes, nearby physical SRAM reads, WRAM staging and VDP transactions. The high-byte rendering mask is checked against the simulated Mode4 VDP source (`vdp_background.vhd`, tile index/flip/palette/priority capture).

## Regression and compatibility

The isolated candidate controller is `candidate_v2/savestates_probe.sv`; its generator is `prepare_candidate.js` in this v4 directory. Bitmask2 enables SRAM only; bitmask1 enables context only. `candidate/` is explicitly superseded: the first generator put a sequential commit block in the combinational case and its timing results are invalid. Use only `candidate_v2` results.

The final controller regression has43 distinct-address-pattern cases plus8 legacy-footprint cases (51 expected outcomes), and two exclusion equivalence tests. Both physical16K banks have distinct patterns; tests cover all32K byte-exact transfers with mapper disabled, legacy conditional16K/32K footprints, old64K bypass, invalid metadata rejected before restore writes, all six predecessor classes and ineligible configurations. The two exclusion tests compare all60 public output ports (1404 bits) cycle-for-cycle through SAVE/reset/LOAD, including nonzero EEPROM state. They test SystemE and the SC/EEPROM eligibility boundary, not complete SC/EEPROM machine emulation. See `distinct_transport_results.json`, `legacy_footprint_results.json`, and `exclusion_*log` under `candidate_v2`.

Existing v2/v3 CPU and VDP regression evidence is reused rather than rerun:98 CPU,32 VDP-access,24 reset/history cases, plus the native v3 production-T2Write and controller/RAM checks. These are supporting regressions, not graphics causality results.

Experimental metadata occupies previously zero upper bits of always-written CPU word5: owner5953 in63:48, version1 in47:44, physical-SRAM-complete43, context-present42, class41:39, reserved38=0; existing CPU state37:0 is unchanged. B does not enable context. The owner/version is experimental, not an allocated upstream format. Writer emits incomplete first and commits completeness only after the full payload/audio drain, before the final framework change detector. Validation precedes restore writes.

A marker only in an unused DDR word is unsafe because an old writer can leave it stale. Both pinned master and optimized public FM overwrite word5 upper26 bits with zero, clearing this marker when overwriting a slot. Old unmarked saves keep legacy mapper-conditional semantics; missing SRAM cannot be reconstructed. Old64K saves bypass the new marker. New marked snapshots require a compatible reader for guaranteed complete restoration; an older reader ignores the marker. Fresh independent saves are required for A/B. Fixed96KiB size alone does not imply valid SRAM payload.

Existing32K physical SRAM, DMA counters/ports and DDR slot0D01–1D00 are reused. SystemE is excluded internally; a test-only `full_sram_allowed` input represents ordinary-cartridge eligibility. A production proposal needs actual active SC cartridge-RAM and EEPROM wiring: exclude `(sc3000_en && sc_cart_ram!=0)` and EEPROM, not dormant option bits. See `FM_INTEGRATION_NOTES.md`. FM100-row storage, descriptor, private payload, video tag and optimized architecture are unchanged. Historical484312 video tagging is not imported.

## Resource and transfer implications

Measured controller protocol timings with DDR BUSY=0/read response3 clocks:

| Mapper disabled | SAVE clocks | LOAD clocks |
|---|---:|---:|
| A/C |28056|940396|
| B/D |64956|993642|
| Added |36900|53246|

The added transfer is32768 bytes/4096 DDR64 words per direction; fixed file size is unchanged. At53.7MHz those clock deltas correspond theoretically to about0.687ms SAVE and0.992ms LOAD; these are not physical hardware latency measurements. Existing900000-clock flush remains. Additional logic is flags, eligibility/metadata validation and completion commit control; no new32K on-chip copy or full-v19 storage is proposed. FSM identifiers73/74 fit the existing7-bit register and do not collide with pinned public FM states111–121, though synthesis encoding is unmeasured. ALM/register/Fmax impacts are **not measured**; no Quartus build was run.

## Limits and discarded trials

- The synchronous memory service model returns ROM/WRAM/SRAM in one host clock and keeps ROM read data updating during freeze. It can mask real SDRAM restart-read timing defects. DDR latency/backpressure is simplified. Audio state is opaque quiescent stubs, not actual FM synthesis.
- Common FPGA power-up values are explicitly initialized for deterministic simulation; results are not proof of every hardware power-up state.
- Early reset pilot incorrectly retained WRAM; it is superseded (`candidate_v2/PILOT_SUPERSEDED.md`). Corrected reset tests model master's16384-clock RAM clear and CPU/controller hold. Even corrected reset plus8frames leaves physical SRAM unchanged. Their32/128-frame movement hits a tree, makes no effective map-name writes, and is **inconclusive**, not a graphics PASS. `r_map_comparison.json` records those results. Do not infer that real resets always preserve the cache; the user's exact reset type is not confirmed.
- The uninterrupted control has small interrupt/sprite timing differences from restored runs even with intact SRAM. In the reset control the first normalized fetch divergence is an IRQ entry; final differences are12 SAT VRAM bytes and40 WRAM bytes, no SRAM differences. This does not establish background corruption or justify importing a clock/background mechanism. Full raw traces remain available.
- An ordinary SAVE T2 fetch already precedes the reference's post-SAVE trace, but LOAD replays it. The analyzer excludes only that independently checked initial ordinary-context opcode fetch when aligning execution; raw traces and `replayedFetch` records are retained.
- v3's report said ACTION0 while its logs used ACTION1 reset. Its frame60 trial never reached the playable map and remains inconclusive. Earlier reports are preserved unchanged.

## Final movement result and decision

All five final trials completed with simulator exit0, Errors0/Warnings0. Their complete post-LOAD movement sequence contains real newly exposed map writes. `analyze_map_runs.js e_` separates VRAM write attempts, effective mutations and effective background map-name writes3800–3CFF, excluding HUD/SAT. These are not startup-only or tree-blocked runs.

| Run | Wrong physical SRAM bytes immediately after LOAD | Effective map-name mutations | Final result |
|---|---:|---:|---|
| A baseline |1479|144|Progressive right-edge corruption reproduced|
| B SRAM only |0|32|Correct, matching uninterrupted reference|
| C predecessor only |1479|144|Same corrupted images/memories/normalized transaction streams as A|
| Uninterrupted |0|32|Correct reference|
| Timing-matched sham |1479|144|Same corrupted images/memories/normalized streams as A|

All five issue200 map-name write attempts during scrolling; different effective mutation counts reflect the wrong contents, not missing coverage. Baseline's newly exposed strip is visibly corrupt by `clear_right40` and grows through `clear_right64`. It ends with4123 differing map-area pixels and zero HUD pixel differences versus reference. That pixel count includes sprite/position differences as well as the bad background; the VRAM tile-write trace independently establishes actual background corruption.

The SRAM-only candidate matches the reference **pixel-for-pixel at all46 compared rendered checkpoints**, including every movement checkpoint. All47622 CPU-to-VDP port address/data records, their command/address/latch observations, all41318 VRAM writes, all359 physical SRAM transactions and all1035 mapper-state records match in normalized event order. The200 scrolling map-name writes also match exactly, including the first formerly wrong tile. Thus this corrects the first relevant divergence rather than delaying visible failure within the tested movie.

At the final checkpoint, B and uninterrupted reference match **all73728 captured memory bytes**: both VRAM banks as modeled, WRAM and the full physical32K SRAM. A/C/sham each differ from reference by159 VRAM bytes,293 WRAM bytes and1479 SRAM bytes. C and sham are individually byte-exact with A at every shared checkpoint.

B is **not** claimed to have every internal CPU/VDP transient identical to uninterrupted execution. Its first normalized opcode-fetch difference is IRQ entry0038 versus polling0046 at index12917. Four intermediate checkpoints differ by only1–3 WRAM bytes in stack-area DFE0–DFEA, converging completely at the end; the initial internal VDP-access probe also differs. None changes the complete observed VDP/SRAM/mapper transaction sequences or any compared image. These residual restart-phase observations remain documented, not silently fixed by importing another mechanism.

Evidence:

- `candidate_v2/e_map_comparison.json`: completed runs, counts, per-checkpoint complete-memory/pixel differences, first normalized divergences and source lines.
- `candidate_v2/first_map_column_evidence.json`: first raw versus rendering-relevant name-table difference and SRAM→WRAM→VDP trace.
- `candidate_v2/e_saved_slot_validation.json`: independent valid saves and identical captured source states.
- `candidate_v2/sram_checkpoint_hashes.json`: complete32K and separate16K-bank hashes before SAVE/history/LOAD and at the end, including mapper-invisible contents.
- `candidate_v2/final_results.json`: asserted final outcome and residual differences; generated by `finalize_results.js`. The native runner's `completed_pending_analysis` means execution completed; this final result records the subsequent analysis.
- Final screenshots: `candidate_v2/e_baseline_clear_right64.png`, `e_sram_clear_right64.png`, `e_reference_clear_right64.png`, `e_context_clear_right64.png`, `e_sham_clear_right64.png`.
- Raw controller/machine logs and event streams retain the complete evidence; `e_*_canonical` contains alignment results, not replacement source traces.

**Conclusion:** omission of physically present SRAM while it is mapper-invisible is sufficient to cause the reproduced Ys map corruption after returning from another environment. Restoring complete physical SRAM alone is sufficient to prevent this specific failure in the tested standard ROM. CPU predecessor preservation is neither necessary nor sufficient for this particular class0 SAVE. D is consequently not needed. This does not reject the separate CPU predecessor defect or prove that every reported reset/ROM variant has the same sole cause.

**Smallest production proposal:** carry over only complete eligible physical32K SRAM transfer and explicit validated completeness metadata, reusing the existing DMA/storage. Preserve legacy conditional LOAD behavior for unmarked saves and existing SystemE/active-SC/EEPROM exclusions. Keep the optimized FM architecture and its descriptor untouched. Do not bundle predecessor/NMI/phase/background snapshots into this graphical fix. The experimental namespace needs review before any production allocation, and production wiring/integrated tests would be required; none has been applied here.

**Next single experiment:** when hardware testing/builds are authorized, perform an independently saved hardware A/B on the standard ROM with this exact town→north gate→settle outdoors→LOAD→LEFT8/RIGHT80/DOWN16/RIGHT64 movie, turbo off and the same BIOS/region. Use a fresh save per implementation; collect the first right-edge image and whether hidden SRAM0462 restores to the saved town value1A. This validates the demonstrated mechanism against the real memory service and hardware report without combining other historical fixes. Japanese/FM-hack coverage and the ambiguous reset procedure remain subsequent coverage, not a reason for another broad audit.

The recommendation is **GO for proposing a narrowly scoped SRAM fix; hardware resolution/release remains unverified**. Production, PR227 and all protected earlier artifacts remain untouched (`preservation_results.json`).
