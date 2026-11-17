# F03 / S068 and F04 / S034 EEPROM savestate review

Base: committed F08 `e090434`, branch `fix/savestate-eeprom`. Only F03/F04 are addressed. No staging, commit, push, or PR is authorized or performed.

## Root causes and before-fix proof

F03: the engine exported only write-enable/output and read diagnostics; the wrapper added pin/window latches. Load restored write-enable/DO but explicitly forced `WAIT_START` and `wr_phase=0`, losing the command, read shift, address, sampled SK and automatic byte-write pipeline. The pipeline also ran independently of CPU enables and savestate freeze.

F04: backing EEPROM bytes live in the shared 32 KB NVRAM RAM, at byte offsets0..127. EEPROM cartridge detection does not assert the ordinary SRAM visibility/size flags consumed by savestates. The 64-bit EEPROM word contains no backing data. Thus the normal NVRAM DMA skipped EEPROM cartridges.

Both defects were confirmed dynamically before production edits. `protocol_before.log` is the original audit's partial-EWEN reproduction: the reference completes EWEN, whereas the loaded DUT retains write-enable=0. `backing_before.log` uses production cartridge wrapper, serial engine and synchronous byte RAM interface: write words A55A at word0 and 3CC3 at word63; save; write1234 and5678; load protocol word. Byte0 remains12 instead ofA5, and byte127 remains78 instead ofC3. No internal protocol state was forced. Reproducible baseline-only fixtures and logs (`before_protocol.do`, `before_backing.do`, `*_baseline_recheck.log`) retain the same demonstrations against the untouched saved F08 source.

## Complete inventory

[inventory.csv](inventory.csv) classifies every persistent engine/wrapper item and relevant integration state. Required state totals138 bits: 81 previously omitted protocol/pipeline bits and57 meaningful existing legacy/wrapper bits. The backing store is another1024 bits. There are no unresolved EEPROM state items.

Preserved engine state includes the nine-position FSM, sampled SK, write-enable, DO, opcode/address shift, shared input/output data shift register, cycle counter, pending RAM write strobe/address/data, write phase, write-all flag/count, pending word address/data, read counter and exported read diagnostics. Wrapper CS/SK/DI, upper line readback bits and FFFC window latch are preserved. Low line bits duplicate those pins and reconstruct exactly.

There is no separate busy register or hidden sequential-read register. Sequential address/wrap and read-latency progress are encoded in the saved state/opcode/address/cycles/data. Clocked process variables are assigned before every read and do not carry future-relevant state. The unexported EWEN/write/erase diagnostic counters are never consumed; `trace_buf` is never used. They are dead for this functional contract and intentionally excluded. `ce_cpu` is unused by this implementation.

Cartridge EEPROM detection/enable is configuration state, independently of current CS, window selection or CPU address. CPU activity and reset inputs are external future inputs; normal ROM-bank/mapper state already uses the existing mapper snapshot. Mapper-control EEPROM soft-reset is a bounded pulse cleared every clock, with bus writes blocked during freeze; the accepted M1 fetch and drain leave it zero before observable use. The shared RAM output is reconstructed by refill, not serialized. Host SD/dirty/queued-request state is interlocked rather than rewound.

## Write timing, freeze and coherent capture

Writes are not atomic: an operation prepares the high-byte output in phase1 and low-byte output in phase2, with RAM committing the previously registered strobe at the next clock. Write-all repeats this across64 words. A snapshot may be accepted during this progress; M1/VBlank acceptance does not imply EEPROM quiescence.

Freeze the wrapper and all functional engine registers during `ss_freeze`; ordinary timing, resets and opcode behavior outside transport remain unchanged. Capture both legacy and full protocol words in post-drain `ST_FREEZE`, after the final normal edge at ARM. Stream the128 backing bytes while the engine is held.

The pending `nv_we_r` is deliberately preserved rather than cleared. On freeze, the physical RAM port switches to DMA, so a newly generated strobe can represent a byte not yet committed. The frozen image contains the prior committed RAM contents plus that pending write. Restoring both and releasing executes the pending byte exactly once, producing the uninterrupted reference timeline.

Restore backing bytes before engine/wrapper registers. Apply protocol in `ST_PRE_UNFREEZE`, then use the existing release guard to refill RAM from restored `nv_a_r`. The RAM's existing same-port `NEW_DATA_NO_NBE_READ` behavior and at least two refill clocks reconstruct the expected input for saved READ latch states. The actual-RAM integration deliberately captures `READ_WAIT1_LATCH` at word63, where the restored high-byte address126 differs from DMA's final address127, so an omitted refill would corrupt the next read.

## Exact versioned representation

All addresses below are64-bit DDRAM word offsets within the existing slot. Stride remains`3000`; existing header/size and all other regions remain unchanged.

| Address/field | v4 representation |
|---|---|
| `01a[63:40]` | tag`484304`, version4 |
| `01a[39:38]` | count3 for unchanged GG/GG/MD base payload |
| `01a[37:30]` | unchanged VDP2 HCounter |
| `01a[29:22]` | unchanged VDP1 HCounter |
| `01a[21:0]` | unchanged video state |
| `01b` | unchanged legacy EEPROM/wrapper layout, or existing Evolution data when applicable |
| `01c–01d` | unchanged GG128 |
| `01e` | unchanged MD P1/P2 word |
| `01f` | EEPROM descriptor |
| `030–031` | full protocol extension, low word first |
| `040–04f` | exactly128 backing bytes, eight bytes per word, lowest byte in bits7:0 |

Descriptor01f: magic`45455058` (“EEPX”) at31:0; descriptor version1 at39:32; presence at40; protocol count2 at43:41; memory count16 at48:44; reserved63:49 zero. Non-EEPROM descriptors retain magic/version with presence and counts zero. Only an exact present descriptor under validated v4 and the current EEPROM cartridge configuration authorizes full restoration.

Protocol extension bit layout:

| Bits | State |
|---|---|
| 3:0 | FSM enumeration0..8 |
| 4 | sampled SK |
| 12:5 | opcode |
| 28:13 | data buffer |
| 33:29 | cycles |
| 34 | pending RAM write strobe |
| 41:35 | RAM address |
| 49:42 | RAM write data |
| 51:50 | write phase |
| 52 | write-all |
| 58:53 | write-all word count |
| 64:59 | pending word address |
| 80:65 | pending word data |
| 127:81 | zero padding |

Legacy01b remains: read_count63:56, read_word055:40, read_word0_addr39:34, last_read_data33:18, padding17:11, upper line bits10:6, CS5, SK4, DI3, window2, write-enable1, DO0. Loader validates full extension padding, FSM≤8, cycles≤15, write phase≤2, and legacy padding17:11. Invalid full data falls back to safe legacy behavior without consuming backing bytes.

The new region040..04f is below VRAM101 and separate from PSG020..024 and protocol030..031. The existing NVRAM byte-transfer implementation is reused with explicit EEPROM mode, size127 and base040. Original SRAM flags, size predicates and base0d01 are unchanged. Both ordinary and System E save paths reach EEPROM DMA when configured. No F05/F06 selection fix was necessary.

## Legacy and malformed snapshots

| Format | EEPROM behavior | Existing extensions |
|---|---|---|
| Untagged96K | retain live backing; use available legacy word; normalize missing protocol | HCounter/GG/MD historical defaults |
| v1`484301`, count0 | same lossy EEPROM policy | HCounter preserved |
| v2`484302`, count2 | same lossy EEPROM policy | HCounter/GG preserved |
| v3`484303`, count3 | same lossy EEPROM policy | HCounter/GG/MD preserved |
| Old64K | retain backing; absent EEPROM word defaults to1: wrapper inactive, writes disabled, DO ready, diagnostics zero | existing oldest-format behavior |
| Valid v4 with valid EEPROM descriptor/payload | exact protocol and128-byte restoration | HCounter/GG/MD positions retained |
| Unknown tag/version/count | retain backing and apply legacy normalization | existing invalid-extension defaults |
| Valid v4 with malformed EEPROM descriptor/state/padding | retain backing and apply available legacy normalization | independently valid HCounter/GG/MD retained |
| Non-EEPROM cartridge | never consume EEPROM backing payload | ordinary SRAM behavior unchanged |

Normalization restores available legacy write-enable/DO/diagnostics and wrapper pins/window, sets FSM toWAIT_START, clears opcode/data/cycles, write pipeline, pending byte/address/data and write-all state, and derives sampled SK from restored wrapper SK. Old64K has none of those historical fields and uses the deterministic defaults described above. Previously unused bytes are never interpreted as EEPROM contents. Legacy compatibility is necessarily lossy and is not exact historical EEPROM restoration.

## Verification

`replay.log`:6642 reference-vs-restored cases. Each command encoding is tested with write-enable initially disabled/enabled, at every clock in its stimulus and automatic completion period. READ covers word0,31,63, sequential transition and wraparound. All command/opcode/address/data positions, first/middle/final data bits, write phases, write-all byte boundaries, completion and CS deassert/reassert are sampled. Freeze exceeds write-all duration; the DUT is reset/advanced and every backing byte perturbed through its RAM interface before restore. Compare guest pins/bus-active every future clock, all exported functional state, and all128 final bytes. A subsequent real WRITE without another EWEN/EWDS command verifies the resulting write-enable behavior through backing memory. No internal EEPROM state is forced.

`integration.log`, `integration_stalls.log`, `integration_random.log`:20 cases per run,60 full DDRAM scenarios total, using two production cartridge wrappers and actual production32 KB dual-port RAM models. The reference naturally reaches the same accepted freeze point and never loads a snapshot. Tests check both serialized protocol and each backing byte against the frozen reference, then perturb/reset only the DUT and compare after full load and future activity. Full unshortened transfer/flush/release FSM runs; only the UI cooldown is bypassed. Stall modes are none, deterministic bursts, and deterministic LFSR-random backpressure. Cases include partial EWEN, mid-write-all, READ latch phase, partial WRITE, idle/not-accessed EEPROM, repeated save/load, restore then WRITE/ERASE, alternating and deterministic varied patterns, all128 bytes including0/127, v0/v1/v2/v3, invalid metadata/padding/state, non-EEPROM, ordinary16 KB SRAM, and System E with/without EEPROM. Existing GG/MD positions are checked. The final old64 default change was specifically rerun in all three stall modes (`old64*.log`), preserving backing contents and verifying the exact ready-state word1.

The original F03 audit stimulus is converted to a positive full-protocol EWEN regression in both generated fixture and Python/Node generators. F07 tests pass direct SMS/GG latch checks,10 metadata cases including explicit v1/v2/v3, and actual dual-VDP DDRAM modern/legacy replay. F02 passes24 serial cases and14 full DDRAM cases both with and without stalls. F08 passes2560 shortened and160 production-timeout replay cases plus13 full DDRAM cases. PSG passes128 noise/divider combinations,20000 future cycles per case. Original audit checks run in isolated output directories, retaining historical reports/hashes. Format expectations advance to v4 and unsupported-version tests advance to v5; unrelated failures are not hidden.

## SD/persistent-storage interaction

Savestates wait for active SD state/read/write/ack before freezing and advertise busy while queued or running. SD starts are blocked during that interval, while an already active backup continues to completion. Requests during transport are latched and serviced afterward; reset cancels deferred requests. This prevents the RAM's second port from reading transient restoration bytes or writing over DMA.

Normal write-dirty tracking excludes frozen engine strobes and DMA. A completed full EEPROM restore marks the coherent restored image dirty, allowing normal later backup/autosave. No direct SD write is issued by EEPROM restoration itself. SD sector sequencing and RAM inference are unchanged.

`persistence.log` compiles the actual extracted production dirty/SD processes with the actual savestate controller. It verifies an existing backup finishes before freeze, one-clock save/load requests survive transport, restored-image autosave starts only afterward, normal guest dirty tracking still works, and reset cancels deferred requests. Five complete transfers exercise320 sector handshakes, with an assertion preventing SD/savestate RAM-ownership overlap.

## Deliberately unchanged behavior and limits

This is replay correctness for the current implementation, not a new93C46 command-emulation implementation. Existing WRAL executes immediately using current data_buf instead of collecting a new16-bit word. Existing ERAL encoding follows the special-command write-enable branch and does not erase all bytes. Both encodings are replay-tested exactly; these independent command semantics are disclosed and remain unchanged as required by the F03/F04-only scope.

As in earlier extensions, metadata validation is not a general truncated-file detector: DDRAM exposes no external file-length signal or payload checksum. Same-media/configuration and identical future external inputs remain preconditions. General crash/power-loss or interrupted-restore recovery is outside this change.

## Diff and build review

Production changes are confined to SMS.sv, rtl/eeprom_93c46.vhd, rtl/cart_eeprom.vhd, rtl/system.vhd and rtl/savestates.sv. RAM source, mapper-control/detection source, ordinary SRAM predicates, and F07/F02/F08 engines are unchanged. Static symmetry checks cover all13 new fields; the existing57 meaningful bits retain their positions. `static_checks.js` verifies all136 committed F08 source/settings files against its known successful Quartus build. The new candidate build is isolated, uses unchanged seed1/settings, and will be compared primarily with that verified baseline. Final metrics, warnings, diff and recommendation are appended after Quartus completes.

## Final signoff

Fresh Quartus17.0.2 full compilation, synthesis and fitter succeeded on5CSEBA6U23I7 with unchanged seed1/settings. Comparison uses the existing successful committed F08 build, whose136 source/settings files were byte-verified against e090434c449d77c506b9c46548399da4ab76d119; generated build IDs also match.

| Resource | F08 | EEPROM fix | Delta |
|---|---:|---:|---:|
| alms | 26618 | 26914 | +296 |
| registers | 36237 | 36452 | +215 |
| memoryBits | 3809858 | 3809858 | +0 |
| ramBlocks | 487 | 487 | +0 |
| dspBlocks | 39 | 39 | +0 |

Worst setup 0.636ns (F08 0.694); worst hold 0.246ns (F08 0.242). Timing summaries with negative slack/TNS: 0. RAM source and RAM resource inference remain unchanged. Full timing summaries are retained.

New normalized numbered warnings 0; new critical warnings 0. Distinct critical warnings F08/new: 38/38. Distinct numbered warnings F08/new: 84/84.

`git diff --stat`:

```text
 SMS.sv               |  42 +++++++++++---
 rtl/cart_eeprom.vhd  |  10 +++-
 rtl/eeprom_93c46.vhd |  67 ++++++++++++++++++++---
 rtl/savestates.sv    | 152 +++++++++++++++++++++++++++++++++++++++++++--------
 rtl/system.vhd       |   7 +++
 5 files changed, 237 insertions(+), 41 deletions(-)
```

`git status --short`:

```text
 M SMS.sv
 M rtl/cart_eeprom.vhd
 M rtl/eeprom_93c46.vhd
 M rtl/savestates.sv
 M rtl/system.vhd
?? tests/
```

**READY TO COMMIT** for F03/F04: protocol/backing restoration, coherence, compatibility, SD interlock, required regressions and Quartus checks pass. Existing WRAL/ERAL command semantics remain explicitly outside scope. Nothing staged; no commit/push/PR performed.
