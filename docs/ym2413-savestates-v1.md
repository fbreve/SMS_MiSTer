# YM2413 FM savestates, version 1

FM snapshot version 1 is the first public FM savestate format. It saves the
YM2413 state alongside the existing CPU, video, memory, mapper and PSG state.
The existing 96 KiB savestate slot allocation is unchanged.

## Format

The FM payload contains **100 32-bit words (400 bytes)** and uses **50 64-bit
DDRAM payload transfers**, plus a separate descriptor transfer. All addresses
below are 64-bit DDRAM word offsets relative to the selected savestate slot.

| Offset | Contents |
| --- | --- |
| 0x01a, bits 63:40 | Discovery marker 0x484311 |
| 0x01a, bits 39:22 | Reserved, zero |
| 0x01a, bits 21:0 | Existing video state |
| 0x2997 | FM descriptor |
| 0x2998..0x29c9 | 50 payload transfers, low 32-bit word followed by high word |

The descriptor is `64'h00640101464d5331`:

```systemverilog
{16'd100, 8'd1, 8'd1, 32'h464d5331}
```

Its fields are payload word count [63:48], format version [47:40], owner/schema
identifier [39:32], and FMS1 signature [31:0]. The loader compares the complete
descriptor and checks payload reserved bits, ranges and the pending-write guard
before applying FM state. Future incompatible layouts require a new version.

| Private 32-bit word indices | State |
| --- | --- |
| 0..8 | Channel register memory |
| 9..12 | User-voice memory |
| 13..30 | Phase memory |
| 31..48 | Envelope memory |
| 49..57 | Feedback memory |
| 58..75 | Output memory |
| 76 | FM bus address/data latch |
| 77 | OPLL command latch |
| 78 | SlotCounter, bits 6:0; all upper bits zero |
| 79 | OutputGenerator pending-write state |
| 80..85 | Controller state |
| 86..90 | Envelope generator state |
| 91..92 | Attack-table pipeline |
| 93..95 | Phase generator state |
| 96..97 | Operator state |
| 98..99 | Sine-table pipeline |

OutputMemory uses MLAB. A pending OutputMemory write is valid only at stage
zero: for transfer pair 39 (words 78/79), word 79 bit 1 requires word 78 bits
1:0 to be zero. RegisterMemory and FeedbackMemory remain implemented in logic.
The sequential transport scratch uses M10K; it is not a second parallel bank of
all live FM registers.

## Compatibility

Existing legacy non-FM savestates, including old 64 KiB and untagged 96 KiB
images, remain supported. An untagged image does not consult a stale FM tail;
the loader initializes FM deterministically instead of restoring absent FM
history. Existing non-FM header, ownership and audio-extension checks remain in
effect.

FM-tagged images must contain the exact version-1 descriptor. Versions 17, 18
and 20 were unpublished local experiments, are not public compatibility
formats, and are rejected. An incompatible FM descriptor is not interpreted as
a legacy non-FM image. A version-1 core should save fresh FM snapshots rather
than use experimental FM-tagged files.

## Restore convergence

TemporalMixer's `mute`, `maddr`, `mix` and `mixout` are intentionally omitted
from the serialized snapshot. They remain frozen with the core, then regenerate
from restored state as enabled FM clocks resume. Restore therefore does not
promise immediate bit-for-bit equality of these transient mixer fields or every
initial audio sample. Differential validation across all 72 phases, including
simultaneous poisoning of all four omitted registers and mid-convergence
reloads, observed full-state convergence within 144 enabled FM clocks. Pauses
in the FM clock enable extend wall-clock convergence time.

## Rejection and transport failures

Malformed FM descriptors, invalid payload words and pending-write guard
violations are rejected before live core/RAM restoration writes. Local snapshot
registers and transport scratch may have been populated, but they are not
applied by a rejected FM-format load.

LOAD is not a general transactional operation. The inherited RAM restore path
streams data into live VRAM/WRAM and other applicable memories. A DDRAM response
timeout after those writes begin releases the core without rolling them back,
so the machine can be left partially restored. Reset or a known-good LOAD may
be necessary after a transport failure. This limitation predates FM version 1.
There is no full-image checksum: corruption that satisfies structural checks
is not guaranteed to be detected.
