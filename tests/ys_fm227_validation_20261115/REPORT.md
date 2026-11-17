# Ys physical SRAM fix on FM PR227 — qualification report

Date: 2026-11-15 (America/Sao_Paulo). **GO for experimental hardware testing. Hardware has not been tested with these RBFs.**

## Source identity and review

FM baseline is 8cd53ccc954c24970372ea6d8a3fb2336a14c46f, confirmed by a read-only upstream PR227 metadata check. The experimental branch remains
`fix/ys-physical-sram-on-fm-pr227`, HEAD `69edeb48455820d3119ab54d052bf3de906c91fa`, **plus an uncommitted completion-guard correction**. No new commit was made.

Patch SHA256: `8e59c978d1cecf4bb0f86d5b3f4ffd8bcb104f34a66637f6b5b7ee61480df0a4`. Compiled production savestates.sv SHA256: `fa3c4334433284a930c26e6f30b348935738a66e8dd56f756368c44439fe2303`. The RBF must not be described as clean 69edeb48 alone. [Exact source identity](</C:/Users/fbrev/Documents/Diversos/Dev/SMS_MiSTer/tests/ys_fm227_validation_20261115/r2/source_identity.json>), [reviewable correction](</C:/Users/fbrev/Documents/Diversos/Dev/SMS_MiSTer/tests/ys_fm227_validation_20261115/r2/production_correction.patch>), [complete code audit](</C:/Users/fbrev/Documents/Diversos/Dev/SMS_MiSTer/tests/ys_fm227_validation_20261115/AUDIT.md>).

The existing two commits add complete eligible physical 32 KiB SRAM transfers, independent of mapper visibility, video marker 0x484314, old 0x484311 recognition, and System E/SC/EEPROM/Evolution exclusions. Against FM baseline they change only SMS.sv and rtl/savestates.sv. The additional correction changes only rtl/savestates.sv (7 insertions / 5 deletions): both owned FM tags now require the existing audio completion commit, and the read-command guard matches rejection conditions. It introduces no new storage, format marker, FM payload, CPU restart or video-history machinery.

The demonstrated defect was an interrupted overwrite of an older FM 0x484311 slot: after audio invalidation, but before video-tag replacement, 69edeb48 accepted the remaining old owned tag as loadable. [Failing pre-correction witness](</C:/Users/fbrev/Documents/Diversos/Dev/SMS_MiSTer/tests/ys_fm227_validation_20261115/interrupted_older_fm_probe.log>) and [corrected rejection](</C:/Users/fbrev/Documents/Diversos/Dev/SMS_MiSTer/tests/ys_fm227_validation_20261115/r2/interrupted_older_fm_fixed.log>). Positive old-FM states remain accepted.

## Functional qualification

| Scope | Completed cases | Evidence |
|---|---:|---|
|Ported controller matrix|51|[result](</C:/Users/fbrev/Documents/Diversos/Dev/SMS_MiSTer/tests/ys_fm227_validation_20261115/r2/transport_results.json>)|
|Physical SRAM/stalls/interruption/repeated LOAD/exclusions|16|[result](</C:/Users/fbrev/Documents/Diversos/Dev/SMS_MiSTer/tests/ys_fm227_validation_20261115/r2/stress_results.json>)|
|Older FM upgrade/commit boundaries|10|[result](</C:/Users/fbrev/Documents/Diversos/Dev/SMS_MiSTer/tests/ys_fm227_validation_20261115/r2/upgrade_results.json>)|
|Legacy mapper footprints|28|[result](</C:/Users/fbrev/Documents/Diversos/Dev/SMS_MiSTer/tests/ys_fm227_validation_20261115/r2/legacy_mapper_results.json>)|
|Excluded public-output equivalence|2|[result](</C:/Users/fbrev/Documents/Diversos/Dev/SMS_MiSTer/tests/ys_fm227_validation_20261115/r2/exclusion_systeme.log>)|
|Restore ordering|1|[result](</C:/Users/fbrev/Documents/Diversos/Dev/SMS_MiSTer/tests/ys_fm227_validation_20261115/r2/ordering.log>)|
|Reused focused FM suites|7|[result](</C:/Users/fbrev/Documents/Diversos/Dev/SMS_MiSTer/tests/ys_fm227_validation_20261115/r2/fm_results.json>)|
|Additional live FM mode cases|7|[result](</C:/Users/fbrev/Documents/Diversos/Dev/SMS_MiSTer/tests/ys_fm227_validation_20261115/r2/fm_modes_results.json>)|
|Native 900,000-clock-flush live FM case|1|[result](</C:/Users/fbrev/Documents/Diversos/Dev/SMS_MiSTer/tests/ys_fm227_validation_20261115/r2/fm_native_qualified.json>)|

All listed cases ran successfully on the corrected source. The 51-case matrix is ported from the previous controller fixtures to the production FM/SRAM format; old experimental CPU-context inputs are inert, and their malformed-format checks are replaced by applicable FM/audio/SRAM checks. This is not a claim that the old CPU predecessor correction is included or fixed.

BUSY tests assert registered-request stability and full byte-exact 32 KiB transfer. Interrupted SAVE boundaries cover invalidation, video, partial/last SRAM, descriptor, commit, header, blocked commit and before invalidation. Interrupted LOAD followed by retry restores the complete image. Exclusion tests preserve old behavior; legacy mapper tests cover disabled SRAM, Sega 16/32 KiB and bank 1, Dahjee A 8 KiB, Codemasters 8 KiB and Castle 32 KiB, including old 64 KiB Dahjee-only handling. Mapper restoration precedes all SRAM writes; all 32,768 writes occur while frozen and before CPU restore.

The live-FM tests use actual OPLL and an independent 100-word internal oracle plus continuation audio. Native-flush case: 3 captures, 4 restores, 374,201 checks. Additional modes cover ordinary/System E/BIOS/rhythm/key-release/reset/FM-disabled behavior. The extra mode sweep uses the existing fast-only 900,000-to-90 flush adapter and NCONT=5000; it is a diagnostic, not a hardware transfer-time measurement. The original FM fixture schedules endpoints with cooldown forced to 0; controller stress and the movie retain native cooldown. Only one completed native matrix case is counted, not the original larger plan or its cancelled next attempt.

[Functional gate and complete-memory hashes](</C:/Users/fbrev/Documents/Diversos/Dev/SMS_MiSTer/tests/ys_fm227_validation_20261115/r2/functional_gate.json>), [independent slot validation](</C:/Users/fbrev/Documents/Diversos/Dev/SMS_MiSTer/tests/ys_fm227_validation_20261115/r2/saved_slot_validation.json>).

## Actual-controller playable Ys experiment

Standard USA/Europe/Brazil ROM, SHA256 02e9404e81bddd4ca21fef2b2711dfe562c3bd7b230bf042df3142362e29a6a9, read locally without modification or distribution. NTSC/export, BIOS off, turbo off, normal eight sprites. Reused qualified first-town fixture comes from two identical cold runs reaching the playable map at frame 150, rather than the earlier frame 60 startup endpoint. A legacy controller slot and a separately captured physical SRAM image initialize each run once; unmarked tail bytes are not treated as SRAM. Each variant then generates its own independent valid SAVE with identical comparable captured state.

SAVE in initial town; UP for 112 frames through north gate; neutral for 40 frames outdoors; LOAD own state; neutral for 5 frames; LEFT for 8 frames; RIGHT for 80 frames; DOWN for 16 frames; RIGHT for 64 frames. The down/right leg clears a tree and forces real newly exposed map columns. This is not a startup-only or no-update trial. Same ROM/configuration/input schedule is used for baseline, candidate and uninterrupted reference.

| Observation | FM baseline | Corrected candidate |
|---|---:|---:|
| SRAM enable at SAVE/LOAD |0|0|
| Physical bytes differing from SAVE immediately after LOAD |1479|0|
| SRAM DDR words transferred each direction |0|4096|
| First rendered frame versus reference |exact|exact|
| All 46 compared rendered checkpoints versus reference |corruption reproduced|pixel-exact|
| Final VRAM byte differences |159|0|
| Final WRAM byte differences |293|0|
| Final physical SRAM byte differences |1479|0|

The first stale source read is physical 0x0419: baseline 0x00, saved town 0x80, candidate 0x80. Natural environment history changes 889 bytes in cache 0x0400–0x07FF and 1,479 physical bytes overall. Both banks are captured and hashed, including currently inaccessible banks. First raw name-table difference 0x3821 (0x00/0x80) involves unused rendering bits; the first rendering-relevant tile is 0x3A20: baseline 0x12 versus candidate/reference 0x1A. The trace connects SRAM 0x0462 → WRAM 0xD820 → CPU VDP data port → VRAM 0x3A20. The CPU supplies the wrong tile before the VDP write, rejecting a speculative VDP address-increment/background-history cause for this reproduced failure.

Candidate matches all 46 rendered checkpoints, all 47,622 CPU VDP writes with their address/latch observations, all 41,318 VRAM writes, and complete SRAM/mapper transaction streams in normalized event order. Final 73,728 modeled VRAM/WRAM/SRAM bytes are identical. Both candidate and baseline produce actual map writes. The baseline ends with 4,123 differing map-area pixels and 0 HUD differences; that pixel count includes sprite differences, while the tile-write trace separately proves background corruption. The correction eliminates the first relevant divergence throughout the complete movie rather than merely delaying it.

Some internal CPU/VDP transient state is not cycle-identical: an IRQ/polling fetch difference and intermediate stack-area WRAM differences are retained in the trace report. They do not change the complete relevant transaction streams, any compared image or final memory. No CPU predecessor/NMI/clock/background/sprite mechanism is bundled into the correction. The separate previously demonstrated predecessor defect remains outside this fix.

[Complete comparisons and source-line evidence](</C:/Users/fbrev/Documents/Diversos/Dev/SMS_MiSTer/tests/ys_fm227_validation_20261115/r2/e_map_comparison.json>), [first map-column trace](</C:/Users/fbrev/Documents/Diversos/Dev/SMS_MiSTer/tests/ys_fm227_validation_20261115/r2/first_map_column_evidence.json>), [baseline final image](</C:/Users/fbrev/Documents/Diversos/Dev/SMS_MiSTer/tests/ys_fm227_validation_20261115/r2/e_baseline_clear_right64.png>), [candidate final image](</C:/Users/fbrev/Documents/Diversos/Dev/SMS_MiSTer/tests/ys_fm227_validation_20261115/r2/e_sram_clear_right64.png>), [reference final image](</C:/Users/fbrev/Documents/Diversos/Dev/SMS_MiSTer/tests/ys_fm227_validation_20261115/r2/e_reference_clear_right64.png>).

## Format and compatibility

File size remains 98,304 bytes (96 KiB), header 24,574 32-bit words excluding control word. SRAM 0x0D01–0x1D00 is disjoint from FM descriptor 0x2997 / payload 0x2998–0x29C9. Public FM descriptor remains 100 words / version 1 / FMS1; optimized storage and all FM validation masks/apply behavior remain intact. 0x484314 plus valid audio completion means complete eligible physical SRAM. Missing/invalid completion rejects before live restore; committed 0x484311 and untagged / old 64 KiB formats retain their old conditional SRAM footprints. Older saves missing hidden SRAM cannot be repaired by a new reader. Fresh states are required for a meaningful Ys fix test. Older readers do not understand 0x484314 and are not safe forward-compatible readers of new states.

The commit marker proves the producer finished under the existing ordered DDR contract; it is not a checksum or an atomic rollback mechanism. An interrupted/failed LOAD can already have changed memory, as in the existing FM baseline. Retry behavior is tested, not rollback. Untagged legacy images have no owned completeness contract; their fallback is deliberately retained.

## Matched Quartus qualification

Quartus Prime Lite 17.0.2 Build 602, Cyclone V 5CSEBA6U23I7, fixed BUILD_DATE=261114, seeds 1/2/3. Fresh corrected candidate exports use identical QSF/QIP/SDC/IP/dependency/settings to the verified FM baseline. Prior 8cd53ccc candidate builds from pr227_matched_20261114 are reused as this task's **FM baseline**, after verifying every input/report/tool hash; its master baseline and historical v19 builds are not used. OnlySMS.sv and rtl/savestates.sv differ. [Input/tool provenance](</C:/Users/fbrev/Documents/Diversos/Dev/SMS_MiSTer/tests/ys_fm227_validation_20261115/physical_r2/provenance.json>), [verified baseline reuse](</C:/Users/fbrev/Documents/Diversos/Dev/SMS_MiSTer/tests/ys_fm227_validation_20261115/physical_r2/baseline_reuse.json>).

B=FM baseline, C=corrected candidate. Actual measured values:

| Metric | B1 | C1 | Delta1 | B2 | C2 | Delta2 | B3 | C3 | Delta3 |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
|Needed ALMs|27,297|27,215|-82|27,261|27,263|+2|27,341|27,241|-100|
|Placed ALMs|32,221|32,213|-8|32,136|32,130|-6|32,151|32,197|+46|
|Mapped registers|34,731|34,733|+2|34,731|34,733|+2|34,731|34,733|+2|
|Fitted registers|35,724|35,731|+7|35,781|35,765|-16|35,791|35,724|-67|
|Logic ALUTs|38,274|38,154|-120|38,272|38,176|-96|38,268|38,155|-113|
|Routing ALUTs|13,075|12,976|-99|12,796|12,894|+98|12,959|13,014|+55|
|M10K blocks|489|489|0|489|489|0|489|489|0|
|Logical memory bits|3,818,374|3,818,374|0|3,818,374|3,818,374|0|3,818,374|3,818,374|0|
|DSP blocks|39|39|0|39|39|0|39|39|0|

| Seed | Variant | Setup ns | Hold ns | Setup TNS | Hold TNS |
|---|---|---:|---:|---:|---:|
|1|Baseline|0.582|0.243|0|0|
|1|Candidate|0.381|0.244|0|0|
|2|Baseline|0.453|0.151|0|0|
|2|Candidate|0.053|0.243|0|0|
|3|Baseline|0.516|0.237|0|0|
|3|Candidate|0.148|0.242|0|0|

All three fit and complete timing analysis. Constrained setup/hold TNS is 0 and no negative timing entries remain. Raw per-clock timing ([CSV](physical_r2/per_clock_timing.csv)), unconstrained-path information and report hashes are retained in [measurements](</C:/Users/fbrev/Documents/Diversos/Dev/SMS_MiSTer/tests/ys_fm227_validation_20261115/physical_r2/measurements.json>). The smallest candidate setup margin is 0.053 ns in seed 2; seed 1 is the primary hardware artifact with 0.381 ns setup and 0.244 ns hold margin. Passing constrained timing does not qualify unconstrained paths.

| Seed | Baseline unique critical warnings | Candidate unique critical warnings | New warning texts |
|---|---:|---:|---:|
|1|40|40|0|
|2|40|40|0|
|3|40|40|0|

Full warning texts, newly differing messages and controller/FM hierarchy rows are in [paired comparison](</C:/Users/fbrev/Documents/Diversos/Dev/SMS_MiSTer/tests/ys_fm227_validation_20261115/physical_r2/comparison.json>). Any new warnings required explicit review before artifact promotion. Existing unconstrained I/O and critical warnings are not hidden by the aggregate slack table.

Baseline seed spread: needed ALMs 80, placed ALMs 85, fitted registers 67. Candidate spread: needed ALMs 48, placed ALMs 83, fitted registers 41. Paired average needed-ALM delta −60, placed-ALM delta +10.667. Placed/fitted differences include packing/routing seed variability; they are not an exact standalone logic-cost estimate. Mapped-register and memory/DSP deltas are measured separately in the table. No full-v19 storage was imported.

## Transfer overhead

Native controller fixture with mapper disabled and BUSY=0/three-clock read response: baseline SAVE 28,708 / LOAD 941,160 clocks; candidate SAVE 65,576 / LOAD 994,408. Measured increment: SAVE 36,868, LOAD 53,248 host clocks, plus 32,768 bytes / 4,096 DDR64 words each direction. At nominal 53.7 MHz the clock deltas correspond theoretically to 0.687 ms SAVE / 0.992 ms LOAD. These are not measured physical MiSTer latency figures; real DDR backpressure adds variation. File size and optimized FM payload size do not grow.

## Experimental RBF and hardware handoff

Primary: [SMS_ys_sram_fm227_69edeb48_p8e59c978_s1.rbf](</C:/Users/fbrev/Documents/Diversos/Dev/SMS_MiSTer/tests/ys_fm227_validation_20261115/release/SMS_ys_sram_fm227_69edeb48_p8e59c978_s1.rbf>). SHA256 `3ebda245e566f22ed2ec1b363359b58f9f83804ad83c5ce83626d431eef103bd`. Source HEAD plus patch and exact tool/seed/settings are in [release manifest](</C:/Users/fbrev/Documents/Diversos/Dev/SMS_MiSTer/tests/ys_fm227_validation_20261115/release/MANIFEST.json>); all three qualified seed artifacts are preserved. The retained 261114 OSD date is intentional for matched compilation, not the experiment's run date. Identify the experiment by unique filename and SHA.

[Hardware test procedure](</C:/Users/fbrev/Documents/Diversos/Dev/SMS_MiSTer/tests/ys_fm227_validation_20261115/HARDWARE_TEST.md>) covers fresh independent standard/hack/Japanese states, environment-change and reset→LOAD, Double Dragon / California Games FM restoration, FM-disabled behavior and older-state limitations. Standard simulation only is claimed; Japanese/FM-hack map execution and actual hardware behavior remain unverified. The map memory service is simplified synchronous ROM/WRAM/SRAM plus deterministic DDR, with opaque PSG and a zero FM endpoint; audible FM is verified separately with actual OPLL. This is a GO for hardware testing, not a hardware PASS or permission to merge/push/publish.

[Preservation verification](</C:/Users/fbrev/Documents/Diversos/Dev/SMS_MiSTer/tests/ys_fm227_validation_20261115/preservation_final.json>) confirms only the authorized RTL correction differs; master/FM refs, sys/, protected reports and existing root RBFs remain unchanged. No new commits, pushes, merges, PR writes or existing-worktree resets were performed.

Automatic approval review rejected copying the supplied real save into a raw local fixture, citing the read-only/no-raw-copy constraint. That actual-file transport check was not run. Read-only metadata confirms its existing audio commit and public-v1 descriptor; completed synthetic older-format tests provide the compatibility evidence used here.
