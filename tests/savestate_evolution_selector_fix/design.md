# F14 implementation contract and design

Authoritative prior evidence: `../savestate_evolution_selector/review.md`, read in full before production edits. This implementation addresses F14 only.

The required 57 bits are active `{game62,game61}` (architectural, 16), previous game selector (historical, 16), candidate61 (historical, 8), prior candidate selector (historical, 16), and sticky `game_started` (historical, 1). Candidate62 is exactly reconstructable from the already-saved bank62: reset initializes both zero, OUT62 updates both to the same byte, and no other ordinary update separates them. Candidate61 is not reconstructable after a partial OUT61.

The old restore copied saved current ports into game and candidate selectors, zeroed previous/prior history, and guessed started from mode bits. The confirmed pair has identical mapper `0000000102038700` and extra `8700000000000000E1320048`, but previous selector `$2800` versus `$2400`. Its first restored address diverges at bus zero (`$280000` vs `$480000`), then at guest `$8123` (`$288123` vs `$488123`). Real production T80 reads/output bytes `$28` before LOAD and `$48` afterward.

Port61/62 and board configuration registers are **emulated CPU-written latches**, including writes made by the guest Evolution menu/BIOS. Raw host status, mapper enable and media remain current/external; none supplies the missing history. Tests change guest menu latches after saving. The real T80 test additionally changes the external ordinary/turbo CPU CE choice from period15 to period10 after SAVE; current host choice B remains active through LOAD while the historical selector/Flash byte restores to `$28`.

The chosen architecture extends the existing Evolution transport to 160 bits. The original 96 bits retain their location/meaning. Upper bits `[152:96]` carry exactly the missing 57 bits; `[159:153]` are constant zero. No new live Evolution state register is introduced. The mapper restores existing live registers from these bits; candidate62 uses the already-saved port62. Existing ARM capture takes the entire Evolution snapshot together. F15 pending phase assignments and their capture/clear policy are unchanged; all functional F14 cases complete both switch-fetch stages before capture.

v10 header word01A has marker `48430A` and existing count3, preserving the HCounter fields and previous extension chain. New word02C is:

| Bits | Meaning |
|---|---|
| 15:0 | active game selector, high62 / low61 |
| 31:16 | previous game selector |
| 39:32 | candidate61 |
| 55:40 | prior candidate, high62 / low61 |
| 56 | game_started |
| 63:57 | zero padding |

Word02D is exact descriptor `0000003945563130` (width57, ASCII `EV10`). No old payload is moved or reinterpreted; slot stride/size, WRAM/VRAM, EEPROM, SC RAM, PSG and F13 history locations stay unchanged. Four new states95–98 fit the existing 7-bit state register. Both DDR request preview and acceptance FSM follow the same routes under stalls.

For valid v10 Evolution snapshots, restoration uses only T's saved values. For untagged, v1–v9, future/unknown versions, wrong length, missing owner, invalid descriptor or nonzero padding, Evolution LOAD returns through existing `ST_ERROR` before architectural/peripheral/memory restore writes. No historical values are fabricated or retained as a purported restore; the attempted LOAD is rejected and current execution is left in place. Even the oldest64K route rejects when current media is Evolution. The existing early lightgun clear is deferred for current Evolution until validation, so rejection does not mutate that peripheral. A valid v10 reaches the ordinary later lightgun restore.

This follows the investigation's explicit recommendation to reject ambiguous legacy Evolution snapshots. There is no new UI compatibility notification: rejection uses the existing controller error/idle path. A future UX treatment can expose the existing failure separately. Other mapper types retain their established legacy semantics; unsupported/malformed F14 extension values are discarded to zero there. Bad F13 metadata still invokes its established terminal-history normalization independently of a valid F14 extension.

The prior report also discussed a 27-bit functional predicate compression. It is intentionally not used: the authorized 57-bit representation preserves actual raw selectors/history and avoids changing Evolution's internal representation. F06 remains unresolved; F15 pending operation and F16 remain untouched.
