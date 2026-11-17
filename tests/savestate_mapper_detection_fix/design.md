# F13 implementation contract

Authoritative investigation read in full before production edits: `../savestate_mapper_detection/review.md` (F12 b61f307). Same v8 mapper payload can represent different Sega/bank evidence and remaining window, with observed different future ROM bytes. Reconstruction of these18 bits is impossible. Retaining discarded current history is incorrect.

Preserve timer16 + bank-write evidence1 + Sega-write evidence1. Normalize Wonder Kid's sample count0 at accepted M1; its intermediate1 cannot remain behaviorally active after a native T80 write completes. Keep same-media static metadata, download scanners and existing flags/banks. No scanner/debug/media payload is added.

v9 retains all v1-v8 locations. Word02a: [17] Sega evidence, [16] bank evidence, [15:0] timer, [63:18] zero. Word02b exact descriptor `000000124d444839` (width18, MDH9). Header01a uses484309 and count3; prior payloads remain recognized by exact version/count. Require matching v9 marker, descriptor and zero payload padding. Invalid/missing/future/older extensions normalize timerFFFF, evidence00. No current history leaks into legacy loads.

Capture mapper flags/banks and history together after freeze/drain, so the timer's final pre-freeze increment and terminal fallback settle before serialization. No CPU enable occurs between freeze assertion and that capture. The early ARM mapper snapshot remains only for load/capture setup and is refreshed coherently for SAVE. New LOAD history is driven on the existing mapper_set edge before guest execution.

The two mapper edge trackers settle from restored effective flags/boot state during the clock immediately after mapper_set. Suppress their initialization actions for exactly that settling clock with one transient restore-pending bit; keep tracking actual inputs. This reconstructs previous values without separately serializing edge trackers or duplicating static mapper precedence logic. Normal reset/BIOS handoff/mapper selection behavior stays in its existing branches.

Affected decisions: Dahjee,4PAK, linear, Sega-locked, Wonder Kid, plus false Wonder Kid/BIOS-handoff initialization on first LOAD. Permanent tests must compare first/repeated loads, future decisions/data, explicit saved history, active deadline timing and discarded-history directions. F06 stays unresolved. Production changes are limited to mapper detector/controller, their system/top wires, and savestate FSM/format.
