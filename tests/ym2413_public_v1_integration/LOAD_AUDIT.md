# Rejected LOAD audit

Scope: the pinned validated baseline `98737615`, unchanged C1 control flow, and the isolated public-v1 candidate. No LOAD state-machine architecture was changed. Source references below refer to the integration worktree's `rtl/savestates.sv`.

## Format rejection versus late transport failure

The premise that an incompatible FM descriptor is checked only after live RAM/core restoration does **not** match this implementation. Format checks happen before the first live restoration write. This must be distinguished from the existing non-atomic behavior on a later DDRAM response timeout.

The actual ordering is:

1. `ST_WAIT_BOUNDARY` / `ST_ARM_FREEZE` freeze the core and capture local shadow registers (lines 989..1032). The normal freeze/drain behavior can settle pending audio operations and pause/reset surrounding interface bookkeeping. It is not a restore from the candidate image, and rejection does not promise that wall-clock time or every transient interface pipeline is rolled back.
2. Header, ownership, CPU, VDP, CRAM, PSG/audio extension, mapper and I/O words are read into **local snapshot registers**, not live state (`ST_LOAD_HDR_*` through `ST_LOAD_IO`, lines 1542..1766). `io_in` and `video_state_in` reflect shadow data, but their live consumers require the corresponding set strobe. Changing a shadow value is not the same as changing a live register.
3. `ST_LOAD_VIDEO` discovers FM at word 0x01a and rejects nonzero discovery reserved bits (1770..1782). The FM descriptor is checked at 1111. Every FM payload pair is checked for per-word masks/ranges and the pair-39 collision guard at 1113..1115, then written into the existing transport M10K scratch. No FM apply occurs during this staging.
4. Only after **all** FM pairs have passed does `ST_FM_LOAD_NEXT` enter `ST_LOAD_EEPROM` (1119..1121). EEPROM/Evolution extension and System E VDP2/CRAM2/PSG2 values are staged next. They do not precede FM rejection.
5. Live VRAM DMA, WRAM DMA and System E passive/second-VRAM DMA follow (1876..1991). The mapper/Evolution/EEPROM apply strobes occur at `ST_WAIT_RESTORE_BOUNDARY` (1065..1092), after those RAM transfers; optional NVRAM DMA follows that boundary.
6. `ST_LOAD_RESTORE` applies CPU, VDP, PSG/audio, I/O/video and CRAM/CRAM2 (2034 onward). Pipeline flush then precedes FM apply (1123..1127 and 2082..2086).

For rejected FM descriptors, masks/ranges, reserved bits or A/B collision counterexamples, the following live restoration interfaces must remain inactive: CPU, VDP1/2, PSG1/2, audio extension/phase, mapper, Evolution mapper, EEPROM, I/O, video, CRAM1/2, VRAM1/2, WRAM, NVRAM and FM. Focused protocol fixtures monitor all these set/write/reset strobes, rather than only CPU/FM counters. Earlier shadow words and some FM scratch rows can change; neither is applied live on rejection. The next valid LOAD overwrites its complete payload; non-FM fallback deliberately initializes its supported state.

## Where partial restoration remains possible

The global DDRAM watchdog (943 onward) can enter `ST_ERROR` after live DMA has begun. `ST_ERROR` (2132 onward) releases freeze and returns to idle without rollback. For example, losing the second VRAM-word response after a valid FM image has been validated leaves the first eight VRAM bytes restored while CPU/FM remain at the pre-LOAD endpoint. A later timeout may leave more VRAM/WRAM/System E banks changed; after the restore boundary, mapper, Evolution mapper, EEPROM and some NVRAM may also have been restored. A SAVE-side timeout has separate incomplete-publication implications and is not fixed by FM prevalidation.

After the RAM transfer stages there are no further FM descriptor/payload format checks. FM apply consumes the already validated local scratch, not a second unvalidated payload read. A bus timeout after a valid descriptor is a transport failure, not a late FM-format rejection.

The format has no full-image checksum. Bit corruption which still satisfies all format/mask/range checks is not guaranteed detectable. Such an image may be applied; this is different from a structurally malformed FM image being rejected halfway through a live restore.

## Baseline comparison

The pinned full-state baseline `98737615` already validates FM at `ST_LOAD_VIDEO` before live DMA, stages the payload in the same transport scratch, and has the same watchdog/error-release behavior. C1 adds its compact layout and collision guard; the public-v1 change adds neither a new early/late write nor a new rejection point. The earlier non-FM baseline `66f16d5` also has the same streaming RAM restore / watchdog / unfreeze-on-error design (static source comparison); it has no FM descriptor to validate. Thus the late-transport partial-restore limitation predates this public descriptor migration.

The external audit fixtures run full SAVE/LOAD protocol paths against v1 and an independently extracted copy of pinned baseline RTL. They deliberately corrupt a descriptor and a late FM payload word, count all live write strobes, and then inject a missing DDRAM response during VRAM DMA. Only the simulation's watchdog counter is advanced to its production limit to avoid simulating ~640 ms; the production watchdog constant and FSM remain unchanged. Exact results and exit codes are preserved separately from historical tests.

Both final runs passed: descriptor and late-payload rejection changed a CPU shadow sentinel but emitted zero live restoration writes; late timeout emitted eight VRAM byte writes, zero CPU/FM apply strobes, and released freeze. See `verification/atomicity_public_v1.log` and `verification/atomicity_baseline.log`.

## Options and costs

These are structural estimates, not synthesized ALM or timing measurements. No Quartus compilation was performed.

| Option | Expected cost and coverage | Compatibility |
| --- | --- | --- |
| Retain current FM prevalidation | Zero new RTL/resources/cycles. Already checks descriptor plus all 100 words before live restoration, using the existing 256x32 transport M10K. | Preserves non-FM 64/96 KiB fallback; tagged experimental versions reject. |
| Extra early FM descriptor/payload pass | Additional states/flags and transfer control; reusing the scratch can avoid a new RAM. Adds at least a descriptor and 50 payload reads if duplicated. No demonstrated format-rejection gap to close here. Extra preflight reads cannot guarantee that a later bus transaction succeeds. | Same on-disk format possible, but new sequencing requires protocol/legacy validation and actual resource/timing checks. |
| General checksum/full-image scan | Counter/checksum state and an additional image-read pass; checksum storage changes require a defined compatible extension or format design. Detects more data corruption but not a later failing commit transfer. | Must preserve legacy untagged loads; cannot silently reinterpret old fields. Needs approval. |
| Full local buffering or rollback | Architectural change: buffer all applicable RAM/state before commit, or preserve old live contents with a reliable rollback path. A full 96 KiB image alone is 786,432 bits, a theoretical minimum of 77 10-Kbit blocks before organization overhead; the existing design uses 489/553 M10Ks, leaving 64. Selective buffering has different costs and still needs design/synthesis. DDRAM-backed rollback adds traffic and cannot be guaranteed when the DDRAM interface itself has failed. | Can preserve file format, but substantial hardware/control/latency impact; not a lightweight descriptor fix. |

## Recommendation

**Retain the current early FM-validation behavior and document the inherited late-transport-failure limitation.** The evidence does not justify adding another FM prevalidation stage: one is already present. Do not describe a rejected FM descriptor/payload as partially restoring CPU/RAM; distinguish altered local staging from altered live state. Conversely, do not claim complete transactional LOAD atomicity under DDRAM faults or undetectable image corruption.

If publication requires recovery from a DDRAM failure after live writes, treat that as a separately approved architecture requirement and fix it before making such a guarantee. Current behavior resumes without rollback; on a transport error, a reset or a known-good LOAD may be needed. No architectural fix or new compatibility format was implemented in this candidate.
