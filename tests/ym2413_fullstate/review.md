# YM2413 Phase 0 full-state port

The isolated branch is `experiment/ym2413-v19-fullstate`, based exactly on
`66f16d5c656fd8906d62570da4d258875bcee684`. The only FM implementation reference is
`7fcd5e12847eedf9e97a44dc937c3dbac3205f7c`.

Worktree: `tests/ym2413_v19_fullstate/worktree` under the original repository.
The original experimental checkout and its existing modified files were not edited.
No master changes, `sys/` changes, commits, merges, PRs, Quartus commands or state
reductions were made.

Status: all acceptance simulations and final scope/whitespace checks passed.
No simulation failures remain unresolved. The complete full-state port is ready
for independent source review; it is not yet a physical FPGA baseline.

## Production changes

24 production files: 23 modified and one added; 1,968 insertions and 433 deletions.
The exact diff and SHA-256 file
identities are in `complete.diff` and `manifest.json`. Test sources and logs are
additional, under this directory.

Integration files:

- `SMS.sv`: private FM connections between the system and savestate controller.
- `files.qip`: includes the new transport module.
- `rtl/system.vhd`: reference wrapper state, registered read response, hold/reset/init integration.
- `rtl/savestates.sv`: FM capture, DDR transfer/validation and final apply in master's FSM.
- `rtl/opll_snapshot.sv` (new): exact reference 104-word sequential transport,
  including its 256x32 scratch RAM, legacy initialization and eight-clock refill.

FM files, all under `rtl/VM2413/`:

`attacktable.vhd`, `controller.vhd`, `envelopegenerator.vhd`,
`envelopememory.vhd`, `feedbackmemory.vhd`, `lineartable.vhd`, `operator.vhd`,
`opll.vhd`, `outputgenerator.vhd`, `outputmemory.vhd`, `phasegenerator.vhd`,
`phasememory.vhd`, `registermemory.vhd`, `sinetable.vhd`, `slotcounter.vhd`,
`temporalmixer.vhd`, `vm2413.vhd`, `voicememory.vhd`, `voicerom.vhd`.

These match the supplied FM reference, apart from imported trailing whitespace
cleanup and preservation of master's PhaseMemory AUTO RAM inference. The I/O and
video restore aliases remain intact. `verify_scope.js` asserts these properties
and rejects unrelated production changes.

## Compatibility adaptations

Master lacks v19's CPU/VDP/background extension chain. This port therefore adds
only the FM states to master's existing SAVE/LOAD routes. It does not copy the
reference controller wholesale or restore the unrelated preceding v19 commits.

- Descriptor: unchanged `{104, 17, 1, "FMS1"}` at 64-bit slot offset `0x2997`.
- Payload: unchanged 104 private 32-bit words, packed into 52 DDR words at
  `0x2998..0x29cb`.
- Discovery: video word `0x01a` has reference FM tag `0x484311` in bits 63:40;
  bits 39:22 are zero and the existing video bits 21:0 retain their meaning.
- Tagged images require the exact descriptor, legal field values and zero padding.
- Untagged 96 KiB images ignore the FM tail, even if a stale descriptor remains.
  They use the reference reset/initialization/default-history fallback.
- Old 64 KiB images also use that fallback without reading the FM tail.
- FM state is preserved even when output is disabled; output gating is unchanged.

This preserves the reference **FM component format**, not the complete v19
CPU/VDP savestate image format. A complete v19 image with its additional header
fields is not advertised as interchangeable with this master-based format.

Ownership was checked before enabling the transfers: master's highest System E
region ends at `0x2900`; maximum NVRAM ends at `0x1d00`. FM ends below the slot's
`0x3000` limit. The manifest records all compared intervals. Existing regions
overlap each other only where their modes are mutually exclusive; none overlap FM.

SAVE captures after freeze/drain and audio quiescence. LOAD restores FM after
master's existing restore/flush work and waits for transport completion before
unfreeze. Ordinary writers remain held throughout apply. Pending writes, delayed
slot counters and memory-read refill are preserved exactly. Initialization readiness
guards entry to both operations; RAM initialization advances on host clocks.

## Verification and reproducibility

`results.json` is the machine-checked acceptance index. It records log hashes,
explicit PASS markers and independent-oracle counts. Every test has a timeout;
the runners reject missing completion markers, assertion failures and simulator errors.

- `case0.log`: native 900,000-clock flush timer, three full SAVE/LOAD continuations
  and a legacy load; 284,889 host-clock audio comparisons. This initial test predates
  the strengthened all-channel programming fixture below.
- `setup.log`, `mode1.log` through `mode6.log`: strengthened musical setup with
  controller-safe write spacing and explicit assertions for all nine channel keys
  and rhythm configuration. Cases cover ordinary FM, System E, BIOS, rhythm,
  key-off/release, unfinished custom-instrument writes and disabled FM output.
  They include repeated full SAVE/LOAD, subsequent key transitions, DDRAM stalls
  and variable registered-read latency. Only the non-FM flush timer is shortened
  to 90 clocks in these additional tests; the FM RTL and transport are unchanged.
- `map.log`: eight sets of independently generated legal words, 832 words total.
  The test injects them into the transport and compares **live internal registers,
  process variables and RAM** before invoking capture. Capture is then checked
  separately. This catches serializer/apply symmetry errors.
- `phases.log`: 72 slot/stage offsets; SAVE and three LOAD continuations per offset
  against the pinned reference, with three idle clocks inserted between private accesses.
- `protocol.log`: initialization readiness, exact v17 descriptor, 104-word apply,
  bad descriptor, illegal counter, reserved-word and tag-padding rejection;
  legacy 64/96 KiB fallback and stale FM tail handling.
- `nonfm.log`: eight paired master/candidate SAVE/LOAD scenarios across SMS/System E,
  BIOS/cartridge, all slots and stalled/unstalled DDRAM. Existing slot contents
  are compared outside the added FM metadata, along with non-FM restore outputs.
  Its DMA data inputs are fixture values; it is a controller regression, not a
  full-console memory-system simulation.

`oracle.tcl` explicitly packs the audited internal fields. It does not read the
private serializer or derive expected values from DDRAM SAVE output. Each integrated
musical case checks 104 words against the independent reference at capture, compares
DDRAM with those live values, then compares restored internals with the original
values, on three successive operations. Raw and clamped FM outputs are compared
clock by clock during continuation. Nonzero audio is not the acceptance criterion.

The actual FM wrapper and clamp logic are extracted from production `system.vhd`.
Clock enables follow master's 30-host-clock CPU/VDP/pixel/SP pattern and FM enables
are gated by freeze, as in `SMS.sv`. Held wrapper writes and raw-clock RAM activity
remain active where the production design permits them.

ModelSim 10.5b needs mechanical simulation adapters: rename the VHDL-2008 keyword
`Release`, expand integer subtype ranges, supply `when others => null` for
meta-values, label processes for internal-variable observation, make the existing
OPLL instantiation explicitly an entity, and move forward declarations. These are
documented in `source_identity.json` and generated for both pinned source libraries.
Production RTL does not receive those simulator-specific edits. ModelSim's design
capacity and aggregate-direction warnings are recorded; acceptance logs must have
no errors or assertion failures.

To regenerate and rerun from this directory:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File run_all.ps1
```

`port.js` records the initial selective-port procedure; it is not part of the
regression runner. Generated simulator libraries/reference copies are ignored,
while test sources, patterns, manifests and acceptance logs remain available.

## Review gate and remaining validation

The full-state port is for independent source review. No optimization experiment,
including omission of `mixout`, is included.

Before establishing a physical FPGA baseline:

1. Independently review the integration, descriptor ownership and test adapters.
2. Obtain explicit authorization for Quartus builds. Check actual inferred RAM,
   ALMs/FFs/M10Ks, fitted routing, timing and RAM read/write semantics. Source
   attributes alone do not establish physical resource usage.
3. Validate on MiSTer hardware with representative FM games/music, repeated saves
   and loads, rhythm/custom instruments, FM-disabled modes and legacy images.

The tests exercise the FM subsystem and master controller with the production
wrapper. They do not elaborate the complete MiSTer top level or establish full
console/hardware equivalence. No physical resource baseline has been claimed.
