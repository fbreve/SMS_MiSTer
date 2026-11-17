# Extracted-bank transition equivalence

Only private sprite bank assignments move out of the main FSM. State numbers,
DDRAM request generation/acceptance, descriptor/padding/owner checks, device
capture edge, all external strobes and restart preparation are untouched.

For each bank i, define the original mutually exclusive clock events:

- C: ddram_step and ST_ARM_FREEZE.
- R: ddram_step and ST_LOAD_HDR_RD and not DDRAM_BUSY.
- S_i: ddram_step and ST_SAVE_SPRITE and not DDRAM_BUSY, selected bank i.
- L_i: ddram_step and ST_LOAD_SPRITE, not the response-latch branch,
  not dout_expected, not DDRAM_BUSY, no last-word padding rejection and no
  absent-device rejection, selected bank i.

The original transition is reset->0; R->0; C->padded live state (bank2 zero
outside System E); S_i->{old low64, old4799:64};
L_i->{dout_latch, old4799:64}; otherwise hold.

The extracted process has exactly those priorities and events. C/R/S/L are
exclusive by FSM state; bank selects are exclusive. On a shift, the lower4736
next bits are identical for SAVE and LOAD, so select only the new64-bit head:
incoming DDRAM word for L, selected bank low64 for S. This changes data/control
topology without changing the next bank value. Reset is identical.

By induction from reset, bank values and every other state element match at
every clock for identical known physical input histories. DDRAM_DIN and both
sprite restore buses therefore match continuously, not only at their consuming
strobes. Rejected binary images follow identical error paths. This proof does
not rely on a lower bound on transport duration, an extra frozen cycle, a
canonical inactive sprite value or a smaller semantic record. No snapshot
clock event is added/removed. Meaningful inactive cache bits and padding remain.

The two-state transition argument covers arbitrary binary data/control values;
natural valid-capture reachability is supplied by the unchanged production FSM
and existing G06/G10 contract. Runtime tests additionally compare four-state
vectors with !==, reject unknown complete images, and retain the original
uninitialized-device restrictions. Artificial X-valued malformed padding is
not a valid physical image and is not claimed as a four-state formal proof.

Verification layers:

1. Current committed v16 controller versus isolated candidate, same inputs:
   all95 output ports, exact FSM state and full9600 bank bits every clock.
   No transport bus or image word is masked. Test adapter only relocates two
   forward declarations and optionally shortens the900000 host flush.
2. Full current format suite, including old64KiB and tags1..15, descriptor,
   padding and second-device rejections, background field coverage; separate
   randomized full-width sprite records with16 metadata combinations and48
   repeated LOADs, independently checking all150 payload words and immutable
   full12288-word images under transport stalls.
3. Complete original14-scenario G06 sprite matrix, plus original G05 pair,
   legal phase sweep, full-flush/stall, current G02/G03/G04 and legal guest-Q
   and dual-device integrations. Immutable earlier independent reference files
   are retained as oracles; no generator overwrites earlier evidence.

The focused miter omits only the139 background one-hot and240 background
position sweeps to gate an early physical fit. It retains532 format scenarios
and all48 randomized sprite LOADs. The separate full miter retains all911
format scenarios. Their counts must be reported separately.
