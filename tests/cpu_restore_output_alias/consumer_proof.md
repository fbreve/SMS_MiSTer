# Pre-implementation consuming-edge proof

Baseline: committed v19 1b2a52d87d2659c908d4f9f846416d14bfd85bea.
This proof precedes candidate generation. Only the DIR payload is eligible.

## Complete read cone

SMS.sv:876,1169–1170,1288–1289 connects the controller output to system's input.
system.vhd:151,159,646,663–664 passes it directly to T80s. Both use clk_sys;
the system's T80s CLK maps directly to clk_sys. There is no divided/gated clock
on this route: enables gate execution, not restore sampling.
T80s.vhd:113–114,185–186 passes DIR/DIRSet unchanged into T80.
Its other DIRSet readers (:136,144,199) control NMI sequencing and bus-idle
outputs, never read DIR data. They remain bit-for-bit unchanged.

T80.vhd has exactly three payload read regions. :442–457 restores architectural
state on rising CLK_n under DIRSet. :1142–1145 restores IFF/HALT on that same
strobe. :290–298 combinationally permutes DIR using Alternate bit228 and drives
only T80_Reg.DIR (:1013–1014). This last wire can change outside DIRSet, but
cannot reach ALU, address, register read ports or DOR without storage consumption.
T80_Reg.vhd:109–132 loads all 16 bytes only on rising Clk with DIRSet=1, regardless
of CEN. Its normal write branch is elsif CEN, and all read outputs (:144–150)
depend on RegsH/RegsL, not on DIR. There is no ungated stateful payload reader.
An unknown Alternate on an inactive bus can change only this unused permutation.

## Clock-edge invariant

Let S denote z80_snap, B the baseline holding output, E=z80_set. Initially E=0.
In ST_LOAD_RESTORE, cram_entry=0, edge R schedules B<=S and E<=1 via NBA.
No assignment to S exists in this state. At R both implementations' CPUs see
the previous E=0. After NBA B equals S and the alias equals S. At R+1 both
CPUs see E=1 and identical 230 bits; the combinational permutation settled a
whole clock earlier. R+1 either advances the CRAM index or is stalled; neither
case writes S. E defaults low even on a stall. If restore action were repeated
because advancement is held, B and alias would still carry the same immutable S.

The exhaustive S writers are the accepted boundary (:1317) and LOAD CPU parsing
(:2158–2172), mutually exclusive FSM states from ST_LOAD_RESTORE. They cannot
execute while E from the immediately preceding restore action is high. The
CRAM stream then flush, FM apply, accessories, unfreeze delay, NMI install,
private T1/T2 preparation, phase/beam acknowledgment and native release do not
write S. B and alias remain equal throughout this entire consuming lifetime.
The DIR bus is not read during replay; only the already installed CPU state,
separate NMI/restart payloads and unchanged controls are used.

## All operation classes

- SAVE-only: boundary replaces S while E stays zero throughout. B may retain
  an older LOAD value. The alias differs only on the unused data bus.
- LOAD from any accepted format: existing parser fills S, including public64
  defaults. Only the unchanged successful restore action raises E.
- Late malformed metadata: parsing may replace S while B retains an older
  value; validation/error paths never assert E. No CPU mutation is introduced.
- Repeated LOAD from arbitrary live Q: boundary and CPU-word staging can again
  differ from B with E=0; the next R/R+1 reestablishes consuming equality.
- BUSY stalls, stale responses, timeout and errors: DDR acceptance/watchdog
  code is unchanged. Only expected responses can fill S. No such writer is
  active in the restore state; error release never raises a new E. Existing
  partial-memory error semantics are unchanged, not upgraded to rollback.
- Reset: neither S nor B has an explicit reset, E asynchronously clears.
  T80's reset dominates its architectural process. T80_Reg has no reset;
  if reset occurs at a consuming clock before E clearing propagates, S=B
  already holds from the preceding R and neither reset path changes them.
  With E cleared, unknown/different inactive data cannot be consumed. No new
  initial architectural value is promised.
- Pause/System E: these alter enables/other consumers but not the common CLK
  or DIRSet priority. Secondary VDP routing is outside the changed cone.

## Induction and obligations for the executable miter

Except B and the externally inactive payload/permutation, every next-state
expression remains identical. With equal inputs and initial states, control,
staging, DDR transactions and image words are equal by induction. At every
possible CPU consumption S=B, so real T80 and register-file next states are
equal, closing the feedback induction through first native execution and all
later cycles. Dynamic checks must still exercise these contracts; comparing
only post-release registers would miss an earlier error.

Decision: pre-implementation source proof PASSES. Candidate may be generated
only in the experiment directory. Physical qualification remains unproven.
