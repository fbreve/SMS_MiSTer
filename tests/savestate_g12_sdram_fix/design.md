# G12 pre-edit design and evidence plan

Baseline: committed v16, HEAD 08cf1426bfd2e1f2a73fdb25aaf57715d408db11.
Production remains unchanged while the sufficiency gate is open.

The current top-level SDRAM reference is selected from the normal effective CPU
cadence (/10 for System E/turbo, /15 otherwise). Private CPU reconstruction
instead always uses raw /15. In the confirmed suppressed-T capture, private T1
asserts RD at raw phase25 without a /10 reference edge. Phase installation then
removes the upcoming native edge. q reaches15 without accepting RD; the first
ordinary T2 consumes the old word before the next q0 can see the request.
old_rd=0 excludes the already-issued-history diagnosis. rd_rdy=1 belongs to an
older completion and has no connected production consumer.

The prototype selects raw /15 as SDRAM clkref while cpu_prepare is asserted,
then returns to the original cadence. It leaves the physical SDRAM controller,
CPU, divider, savestate transfer, guest enable gates and payload untouched.
This is a protocol-alignment candidate, not yet a proven production fix.

## Alternatives

| Family | Correctness and cost assessment before experiments |
|---|---|
| A: invalidate and force reissue | Explicit old_rd invalidation alone cannot create a q0 before consumption. Clearing returned data merely changes the wrong byte. A safe invalidation must also schedule acceptance/completion; adds controller controls and possibly a freshness bit. No payload is inherently needed. Pause/private replay and first-read timing must still be proven. |
| B: historical request state | Saving q/address/data/valid could reproduce one physical phase but requires chip command reconciliation, more payload and muxing. Minimal pending history is not shown necessary: the restored architectural bus already identifies the immutable read. v17 would be required for new history. Unnecessary unless deterministic reissue fails. |
| C: canonicalize and fence handshake | Can be sufficient if the fence identifies this request, observes acceptance, and only then completion. Waiting on old ready alone is incorrect. Adds request-freshness state and a release/preparation stall; extends G10/F12 bounds and requires careful historical T2 gating. No payload needed. Useful fallback if timing coupling cannot guarantee completion. |
| D: save returned data/valid | Eight or sixteen data bits plus validity/owner context could supply the first fetch, but would need a first-consumer mux and correct mapping/lane semantics. Duplicates immutable ROM information. Does not by itself repair later requests. v17, more storage/routing, and extra G11 input selection obligations. |
| E: deterministic reissue with aligned scheduling | Existing DIRSet deasserts bus strobes; long settlement naturally samples low. Private T1 then reissues the restored bus read. Coupling clkref to that exact private cadence schedules q0 before consumption without extra state, payload, or guest ticks. Selected prototype; must survive Pause, source-switch, phase and transport sweeps. |

All options must preserve G01's semantic T1/T2 replay and G10's captured phase
handoff. No option changes G11 decryption semantics; its future input oracle is
the raw byte/address/M1 relationship after this path is correct. Logical Pause
remains current host state, not historical payload. No option authorizes normal
CPU execution while paused beyond existing bounded preparation.

## Timing argument to challenge

At private T1, /15 clkref rises; q becomes0 while the CPU asserts RD. At T1+1,
q0 sees RD and latches the restored address. ACT follows, READ follows, and q6
registers the returned word at T1+7. Historical T2, when required, is fifteen
host clocks after T1. A suppressed-T System E image resumes its first native
CPU enable ten clocks after phase commitment, which follows T1. Both leave
time for this read. This must be checked against actual edge ordering,
old_ref, all private-T1 phases, and source switching, not inferred from ready.

An unrelated native reference edge must not truncate the transaction after
leaving preparation. SAVE does not enter private preparation and therefore
must preserve its original clock relation exactly.

## Reproduction

`prepare.js` clones retained, production-equivalent investigation adapters into
independent baseline/prototype libraries. Only the prototype's DUT clkref is
changed. `run.ps1` selects saved/current logical Pause using real button/VBlank
transitions and records MCycle, TState, PC, address, strobes, q, pending, ready,
raw byte, freeze, controller state and replay. Independent golden T80 receives
the same restore and execution enables, bypassing only live SDRAM timing.
Original physical chip timing, immutable distinctive ROM and transaction ledger
are retained. No controller/CPU/Pause register is deposited.

The mandatory gate remains open until original/full-flush witnesses, all four
Pause transitions, exactly-once and non-injective/boundary searches pass.
No production patch or Quartus is permitted before that gate.
