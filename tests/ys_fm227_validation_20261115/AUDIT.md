# Production FM + physical SRAM audit

Baseline: `8cd53ccc954c24970372ea6d8a3fb2336a14c46f`.
Experimental branch: `fix/ys-physical-sram-on-fm-pr227`, HEAD `69edeb48455820d3119ab54d052bf3de906c91fa`.
Initial tracked worktree clean. Baseline-to-HEAD changes only `SMS.sv` and `rtl/savestates.sv` (38 insertions,18 deletions). This audit adds one minimal, uncommitted correction in `rtl/savestates.sv` on the experimental branch; master and the FM integration branch remain unchanged. Exact HEAD plus patch/source SHA256 are recorded in `r2/source_identity.json` and `r2/production_correction.patch`.

## Demonstrated defect and correction

`interrupted_older_fm_probe.log` fails on unmodified69edeb48: after an old committed FM484311 slot is invalidated by the start of its replacement SAVE, but before video word replacement, LOAD accepts the remaining owned FM tag with audio presence0. The same construction preserves a valid older public-FM layout; stale extra SRAM tail bytes are not part of its contract. The test requires rejection, not reclassification as untagged legacy.

The correction requires `has_audio_ext` for **both** owned FM tags, not just484314, and makes the combinational read guard match rejection conditions. Committed PR227 FM images always have the audio commit; their compatibility is retained. Untagged legacy images keep their original fallback. `r2/interrupted_older_fm_fixed.log` passes the formerly failing case, rejecting before CPU/SRAM restoration. Additional positive legacy-FM cases must remain passing. No new state, format marker, storage, FM payload or CPU mechanism is introduced.

Pre-correction results remain in this report's parent directory and are not reported as final fixed-source results. The final fixed-source tests and candidate movie live in `r2/`. Baseline and uninterrupted movie runs remain valid controls because their source has not changed.

## Completion and transport

The writer invalidates PSG/audio presence at word00E before replacing the header, CPU or memory. Video word01A selects484314 only for eligible physical SRAM; FM-only remains484311. Writing484314 alone does not commit SRAM: LOAD requires a valid committed audio extension, valid video padding, current size, eligible configuration, and the unchanged FM descriptor/payload checks. After the correction, owned FM484311 also requires audio completion.

The physical SRAM loop finishes before audio payload/descriptor writes. A32-consecutive-idle-clock drain precedes the audio commit bit; framework change detector remains last. The registered DDR request machinery is unchanged from PR227 and retains address/data/byte-enable while BUSY. Interrupted overwrite of a previously valid full-SRAM image therefore has audio presence clear until all SRAM/FM/audio payloads have completed. A cut before invalidation leaves the previous committed image intact; a cut after audio commit may load the completed replacement even if framework publication was interrupted.

The actual main RTL confirms physical access: `SMS.sv` instantiates `nvram_inst` with15-bit portA, clocked continuously by `clk_sys`; its address/write/data mux selects `ss_nvram_*` whenever `ss_freeze` is asserted, and `nvram_q` feeds the controller directly. This path is not gated by mapper visibility. No physical RAM-port change is needed. The reused T80/VDP/video/I/O/mapper sources have no differences between master66f16d5c and FM baseline8cd53ccc, so reusing their already validated probes does not substitute a different CPU/video implementation for the FM baseline.

This assumes the existing ordered, lossless DDR acceptance contract. The marker is not a checksum against later media corruption, and the controller is not a rollback engine for partially applied LOADs. Reset during a LOAD is tested by retrying a complete committed image. No stronger atomic-rollback guarantee is claimed. Truly untagged legacy images have no owned completion contract; an interrupted overwrite before a discoverable new tag cannot always be distinguished from a legitimate old image. Legacy fallback remains unchanged and is not represented as full-SRAM completeness.

## FM and compatibility

FM descriptor2997 remains `{100,1,1,FMS1}`; payload2998–29C9 is unchanged. FM snapshot architecture, state validation masks, live-state apply order and transport are unchanged. Both484311 and484314 follow those same FM validation paths. Bad descriptors/state words are rejected before live restoration. The new marker does not import historical484312 tagging or the test-only5953 CPU marker.

Unmarked/older FM484311 images retain mapper-conditional8/16/32K SRAM behavior. In particular, an old mapper-disabled image does not restore stale tail contents just because its file is96KiB. Old64KiB saves retain the Dahjee-A-only bypass; completeness cannot be inferred from upper unused data. Old readers are not forward-compatible with484314 and must not be relied on to restore its FM/SRAM extension. Older images missing hidden SRAM cannot be repaired by a newer loader; create fresh states for a meaningful hardware comparison.

## Physical banks and mapping

`transfer_full_sram = sram_eligible && (do_save || has_full_sram)`. It selects all32768 physical bytes regardless of current Sega SRAM enable/bank flags. The existing15-bit DMA port/counters and SRAM backing are reused; no extra on-chip32K snapshot is introduced. On LOAD the mapper/EEPROM/Evolution restore strobes precede SRAM DMA, while CPU/VDP restoration and unfreeze follow it.

The supplied `sc3000_mode` is the active `sc3000_en` expression, including automatic mode; `eeprom_present` uses `eeprom_active`. SystemE and Evolution also exclude full-SRAM transfer. Existing `has_nvram` behavior remains the fallback in excluded modes, rather than being forcibly disabled. Thus exclusion preserves the old mapper-specific footprint; it does not mean that all old NVRAM transfers are prohibited. Full-SRAM-tagged images loaded under an ineligible mode are rejected rather than truncated.

## Layout and failure boundary

Full SRAM occupies0D01–1D00 (4096 DDR64 words), FM descriptor/payload starts2997/2998, slot limit2FFF. SystemE/SC/EEPROM/Evolution exclusions prevent inappropriate backing/layout reinterpretation. File remains98304 bytes and framework size24574 32-bit words excluding the control word. Completeness is coupled to an always-rewritten audio word, preventing an old writer from leaving an effective stale full-SRAM commit marker.

Malformed/missing commit metadata is rejected before SRAM/VRAM/WRAM/CPU/FM restoration. A transfer interruption during an otherwise valid LOAD can already have changed memory before reset/error; this inherited controller property is distinguished from accepting an incomplete SAVE as valid. No production defect requiring a broader transactional-memory redesign is inferred from that distinction.

## Validation adapters

The map fixture runs exact baseline/candidate FSM behavior and real `opll_snapshot`, but supplies a synchronous zero-initialized100-word FM endpoint model. It is not an audible FM test. Actual OPLL/FM correctness is tested separately by the reused PR227 suites with an independent hierarchical100-word oracle and audio comparison.

ModelSim-only changes to copied OPLL sources: `Release` identifier renamed `EG_RELEASE`; integer subtype ranges written explicitly (VOICE_ID0..37, channel0..8); null complements for nonbinary/unreachable case alternatives; three process labels added for independent internal-variable inspection. An obsolete unused wrapper debug assignment is removed. No production/Quartus source uses these adapters. Early failed adapter/compile attempts are preserved and do not count as passed regressions.

The51-case matrix is ported to the production FM/SRAM marker. Its old CPU-context class inputs are inert; malformed5953 CPU-format cases are replaced by malformed audio/FM/SRAM validation cases. This does not claim a rerun of an unchanged CPU correction against this branch. No predecessor/NMI/background/sprite/clock mechanism is introduced.

The original live-FM fixtures schedule endpoints with `op_cooldown` forced0; the mode sweep additionally uses the existing fast-only900000-to90 flush adapter. A separate live-FM case retains the native900000 flush, and controller stress/repeated LOAD and the playable movie retain the actual cooldown. These scopes are reported separately. An initial larger native-matrix plan was stopped after its first complete PASS; the next partial case is not counted as a PASS (`r2/fm_native_qualified.json`).

## Actual older-save metadata and approval boundary

The supplied FM-hack save's SHA256 remains94c26472d08c58e42935a825ebb8e19569a8e245096a26390b7ca78ae5430576. Read-only inspection confirms audioPresence1, PSG word9fff3fffc0000000, audio descriptor0000aa0150534758, FM video484311000000df51 and FM descriptor00640101464d5331 (`older_hardware_commit.json`). Its completion metadata satisfies the corrected guard.

Automatic approval review rejected making a complete local raw fixture from that supplied save, citing the read-only/no-raw-copy constraint. No raw fixture was created and the actual-file transport test was not run. Completed synthetic legacy/public-FM compatibility tests and the read-only actual metadata check are used instead. The helper's rejected export operation is disabled; this restriction is not bypassed by an indirect simulation or another copy path.
