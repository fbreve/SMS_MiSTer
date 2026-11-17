# Canonical causal evidence

All integrated encrypted evidence in this document uses explicitly scoped
testbench parameters and production Z80 Mode=0 assertions.

## Paused System E image, LOAD into running host

Source: pause/m2_s1_c0_d8/simulation.log. Saved CPU consumption bit is zero;
the first native T2, rather than historical T2, is the required observer.

| Host clock | Raw request / pipeline observation |
|---:|---|
| 2678201 | Exactly one reconstructed ROM request accepted, physical0040121 |
| 2678206 | Pending q5, old raw94, decrypt09; CPU still held at MC1/T2 |
| 2678207 | q6 response capture edge, correct rawAF installed after edge |
| 2678208 | RawAF visible; output still09; madr8121, xorC8, swap11 |
| 2678209 | Phase-one calculation edge with correct rawAF/table inputs |
| 2678210 | Registered decrypted32 visible, equal to mathematical oracle |
| 2678212 | First native consuming T2; rawAF/decrypted32 both correct |
| 2678213 | CPU advances to T3/refresh; unused output may subsequently differ |

PASS_REISSUE proves one acceptance and one response, not merely a stale-high
ready signal. The raw predecessor94 is explicitly replaced before decryption
and consumption. The decrypt output is *not* restored historically: it changes
from09 to32 before observation. CPU, bus and guest-memory suffix agree for
12,000 clocks after release/unpause. No upstream G12 contradiction occurs.

## Complete-v16 collision: MC result history

Sources: joystick/mc_history_a and joystick/mc_history_b. A real DC-controller input history selects
different ROM addresses, then guest instructions canonicalize registers and
enter a fixed RAM loop. No historical CPU/decrypt field is forced.

Both accepted SAVE images contain 12,288 known64-bit words and have normalized
SHA256 f0c80d318b140c67d1f854040f83fad734d9f0d659611f33e07eed3bc37c3808.
There are zero differing image words. Acceptance is clock656700 in both runs.

| Omitted/live observation | A | B |
|---|---|---|
| CPU architectural image | identical | identical |
| CPU bus address at capture | 000B refresh | 000B refresh |
| Sega madr | C020 | C020 |
| Sega phase | 1 | 1 |
| MC current key data | 65 | 65 |
| Retained raw byte | 94 | B5 |
| MC registered result | 04 | 7D |

The differing retained raw word belongs to upstream G12 history and is not a
guest ROM response at this RAM-loop capture. This pair is a convergence
witness, not a claimed G11 defect. The future IO input is made identical at
capture. Identical future NMI input causes new ROM reads through the actual
G12-fixed controller and decryptor. Both SAVE-only continuations and perturbed
LOAD replays match the identical 24,000-clock reference file; full CPU/bus
samples and guest observer bytes agree. Both runs pass with68 accepted,
returned and physical ROM transactions, with no outstanding transaction.

## Complete-v16 collision: Sega phase only

Sources: phase/sega_resave_even and phase/sega_resave_shift15. Each executes
real SAVE, perturbed execution, LOAD and an identical suffix, then requests
another real SAVE. A legal15-clock tail-response delay shifts the free-running
decrypt phase without changing the saved guest state. The second accepted
SAVE is clock934432 versus934447.

Both full12,288-word images have normalized SHA256
e87ec2424a24a0cee66276b268a40ad39495224a6f4e850cc5e20ae4ab8410b2.
CPU, raw22, madr820A, xorEB, swap17, registered resultC9 and MC/key outputs
are identical at acceptance. Phase alone differs:1 versus0. Both further
24,000-clock CPU/bus/guest-signature futures are byte-identical, with consumed
raw/decrypt assertions active. This directly isolates phase from G12 history.

Phase therefore need not be restored to the same physical bit value. Its two
schedules belong to the same guest-observable equivalence class under the
proven recovery bounds and legal CPU/ROM timing. Other registered results are
reconstructed before observation. Literal equality of every idle pipeline bit
is neither established nor claimed.

## Exhaustive production pipeline recovery groups

recovery.log: 65,536 Sega cases (128 indices x256 raw bytes x2 phases), with
address/table/output reconstruction within5 edges and raw-only recovery within2.
mc_recovery.log: 2,097,152 MC cases (8192 key addresses x256 raw bytes), with
key/address recovery within2 edges and raw-only recovery within1. Keys/tables
are downloaded through real memory write ports. These are supporting temporal
proofs, not counted as millions of SAVE/LOAD cases.
