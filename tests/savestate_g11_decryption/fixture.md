# Fixture and evidence boundaries

The integrated fixtures derive from the committed-source G12 final_matrix and
final_protocol fixtures. They retain real T80/T80s, mapper_ctrl, memory_decode,
memory_bus, the live SDRAM controller, physical CAS2 SDRAM model, video beam,
host Pause logic and v16 controller transport/restart. The top-level clkref
expression is the current G12-fixed production expression. CPU clock periods
are /15 for ordinary SMS and /10 for System E/turbo cases. No accepted CPU,
mapper, decrypt register or bus state is deposited or forced. A storage-busy
input can postpone an otherwise legal SAVE until a targeted predecessor class.
The inherited UI cooldown override does not bypass a capture/restore stage.
The [source bridge](source_bridge.json) verifies constrained equivalence to
current production: entity qualification, three null case arms for binary
mapper selectors, inout driver split/block name, and declaration placement /
parameterized flush only. Six decrypt/memory sources are compiled directly.

The actual MC8123 module uses the actual production spram and vendor
altsyncram model. The actual Sega2 module uses actual production DLROM tables.
All keys/tables are loaded through their normal write interfaces before CPU
reset is released. The key RAM simulation generic uses init_file="UNUSED"
because this ModelSim vendor model treats production's default "none" as an
unsupported filename. Every key byte is then explicitly downloaded, so no
power-up value is used by guest execution. Both pipelines remain clocked during
freeze and transport, as in production.

The synthetic encrypted ROM is deliberately nonuniform. Code bytes are
encoded for their logical address and opcode/operand classification. Other
physical ROM addresses use a deterministic nonuniform hash. The golden CPU
computes the byte directly from logical A, opcode/M1 and the physical raw byte,
without decrypt pipeline history. It does not stand in for the DUT decryptor:
the DUT consumes the real production pipeline output, with its real key/table
latencies. Cipher-algorithm compatibility with external game dumps is outside
this savestate investigation.

Program 0 initializes main/alternate/index registers and loops through bank
writes and distinctive boundary reads. Program 1 adds CB, ED, DD, FD, EI/DI,
immediates, absolute operands, CALL/RET and stack activity. Program 2 adds
EI/HALT and a future NMI/RETN handler. The canonical RAM-history pair uses
IN A,(DC), a real upper IO/controller read in production, with two legal
J1_up input levels. It performs one input-selected ROM read, erases
architectural differences, then executes a
fixed RAM loop. Its external IO input becomes the same level in both runs at
capture, before identical future stimuli. A later NMI requires new ROM input.

The matrix oracle records every host-clock architectural/bus sample and six
guest WRAM observer bytes, together with inherited audio controls. Every v16
image word is checked known; the full 12,288-word image remains immutable over
LOADs. A transaction ledger rejects overlapping/unowned physical responses and
checks raw data against the accepted physical address. A separate consumer
assertion checks raw ROM before comparing decrypt output. The Pause fixture
adds the G12 exactly-once private reissue contract and a golden CPU restored
through the same restart controls, with history-free decrypt evaluation.

The streams variant strengthens this with a per-clock ROM-consumption record:
valid bit, physical address25, raw byte8 and decrypted byte8. The uninterrupted
golden CPU supplies its own mapped address and history-free raw/decrypted data;
each SAVE-only and LOAD suffix must match the record at every host clock.
It also compares all16,384 modeled WRAM bytes at the end of every suffix and
counts exactly one accepted/returned private ROM reissue per LOAD. The targeted
12-case matrix is run through this variant; earlier variants remain supporting
evidence with their stated six-byte guest observer.

Other peripheral serializer endpoints remain the documented G12 test models
(including optional inactive VDP endpoints). This is a targeted ROM/decrypt
investigation, not a full-board game/VDP/audio/FM regression. Architectural CPU
and consumed ROM checks are the G11 oracle; unused decrypt outputs can differ
or be unknown during initialization without constituting a guest divergence.
No unknown is allowed in accepted complete images or compared suffixes.

## Excluded setup/debug runs

The inherited cache/ RAM-history pair used an arbitrary test IO read at7C.
Production routes that read to VDP data, so those runs remain supporting
overapproximation tests, not canonical natural-input collisions. The canonical
joystick/ pair instead uses real portDC and has been rerun independently;
the collector counts only that pair. The same external input levels apply
from capture onward. system.vhd io_upper_port and io.vhd even-port controller
decode establish that the chosen0/1 values are reachable digital inputs.

Retained pilot logs document unsupported key-RAM init filename, an initial
clock transition that skipped download entry zero, two transposed test-only
Sega permutation cases, and an initially raw rather than decrypted Pause
golden input. The Sega permutation oracle subsequently passed all 8,192
mode/byte combinations against production bswp.

Most importantly, ModelSim's unqualified -gMODE argument also changed nested
VHDL CPU Mode generics: mode2 selected 8080 and mode1 selected Fast Z80. Those
encrypted runs are invalid evidence and are retained under invalid_global_mode.
All canonical arguments are scoped to /pause_tb; canonical campaign/Pause
fixtures assert both CPU Mode values are production Z80=0. A corrected startup
trace demonstrates known alternate/index registers and real prefix semantics.
The original mode0 bypass run is unaffected. Earlier PASS labels from invalid
encrypted runs are not included in the final canonical case counts.

Recovery-only tests exhaust 65,536 Sega index/raw/phase combinations and
2,097,152 MC key-address/raw combinations with real downloaded memories and
production registers. They support temporal overwrite bounds; they are not
claimed as real-CPU SAVE/LOAD cases or non-injective witnesses.
