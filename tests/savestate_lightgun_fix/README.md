# F11 implementation validation

Branch `fix/savestate-lightgun`, committed F10 base `77147af`. Production scope is
`SMS.sv`, `rtl/lightgun.sv`, and `rtl/savestates.sv`. Nothing is staged or committed.
The authoritative pre-fix investigation in `../savestate_lightgun/` is preserved.

The final implementation freezes the local pixel pipeline and ungated hit arm,
while host cursor integration, mouse-strobe consumption and button sampling keep
running. Save-only needs this hold. Full save/load additionally needs historical
state: the freeze-only experiment in `freeze_only_stalls0.log` still releases
SENSOR=0 against the saved reference SENSOR=1 and returns F4/B4 on port DD.

The final v8 payload is 46 bits, not the preliminary 74-bit candidate:

| Bits | State |
|---|---|
| 45:37 | `vcnt` |
| 36:28 | `vtotal` |
| 27:12 | `hde_d` |
| 11 | `old_hde` |
| 10 | `offscreen` |
| 9 | `sensor_pend` |
| 8:1 | `sensor_time` |
| 0 | `SENSOR` |

`hcnt` resets during horizontal blanking before the next active line. `old_vde`
samples the restored blank level; frame-latched `x/y` refresh on VDE rising in
horizontal blanking before the next HDE hit window. Replay explicitly checks
their convergence whenever HDE and VDE are both active. Delayed HDE/vertical
history is retained because it controls learning `vtotal` and current aim scaling;
the accepted first VBlank line can still have a nonzero `vcnt` and active pulse.

Word 028 contains the 46-bit payload with zero upper 18 bits. Word 029 must equal
`0000002e4c475538` (width 46 and LGU8). The video extension marker is `484308`,
with the established marker/count field 3. Existing fields, slot size, and memory
payload offsets remain unchanged. Untagged/v1-v7/old64 or invalid gun metadata
normalize the gun to a masked, idle pulse with cleared vertical history; other
accessory legacy rules remain unchanged. Valid gun state applies early, before
VDP/F07 restoration, so intentional TH restoration settles before the saved latch
is installed and its edge detector is re-primed.

A further F11 restore-coherence counterexample changed discarded IO control to
00 before loading an active saved pulse with control FF. Installing gun state
early alone was insufficient: the later TH-direction change overwrote HCounter
92 with 00. The new v8 path therefore settles only control direction bits 1 and 3
alongside gun state, preserving every other current IO bit; the ordinary full IO
restore stays in its existing stage. VDP/IO implementations and legacy paths are
unchanged. The failing trace is archived in exploratory74/logs/; io_order0/1 are
permanent positive regressions on both ports, including long transport.

Canonical final tests:

- Four production-T80 save-only cases, one per stall profile. Compare actual
  qualified controller-bus reads, complete CPU register output (including A),
  SENSOR, HL, HCounter latch and NMI after resume. IRQ is tied inactive; there is
  no gun-specific IRQ. These tests do not load CPU state or address F01.
- Eight original accepted-boundary cases: four stall profiles and four
  port/region/PAL/border variants. Restore and compare real I/O, TH, SENSOR and
  HCounter effects through the next frame.
- 33 full save/load target/configuration sweeps using the investigation's exact
  parameter combinations, plus 16 requested capture-phase cases. Requested
  phases can share an eligible CPU acceptance tick; logs record actual acceptance
  and capture positions. These are 57 full pairs, not the investigation's 332424
  hypothetical acceptance observations.
- Two additional HCounter guard replays (no stalls and long stalls): save transport
  leaves the latch unchanged; after F07 installs the loaded latch, it remains
  unchanged throughout the remaining freeze. A legitimate next-frame gun rise
  must occur. Intentional TH settling before F07 restoration is distinguished
  from a spurious event after the restored machine state is installed.
- Two direction-restore replays extend that guard to discarded TH-direction
  changes. Final totals are 61 full pairs and 202 controller-transport operations
  including the T80 and format cases.
- 18 format cases under four profiles: 72 loads covering untagged, all v1-v7,
  valid/repeated v8, future/unknown tags, old64, bad descriptor/width/count and
  reserved bits. v7 explicitly retains MD6/Tap/Paddle payloads.
- One million ordinary cycles against the original F10 production gun, comparing
  the entire 74-bit temporal cone, crosshair, trigger and host cursor handling.
- Eight current-input cases, 32000 held-state observations. SENSOR is synthesized
  here: there is no external photodiode bit. Tests cover inactive/active captured
  pulse states and joystick aim, mouse events and button transitions during hold.
  Current input is consumed normally; already-seen mouse strobes are not replayed.
- Existing F07/F02/F08/F09/F10/F03/F04/F05/PSG regressions. Only format expectations
  move from writer v7/future v8 to writer v8/future v9, with explicit positive v7
  cases added. Accessory replay/ordinary tests remain unchanged. Original generator
  text is retained in `regression_sources/`.

`exploratory74/` and early `fixed_*.log` are preliminary evidence, excluded from
the final manifest. Final selected logs and source hashes are checked by
`results.js`; `simulation_results.json` is written only when all required checks
pass. `results.json` additionally requires a successful complete Quartus build.

Reproduce from the repository root with Node and ModelSim 10.5b:

1. Generate the current dynamic controller prefix with
   `node tests/savestate_hcounter/prepare_controller.js`.
2. Run `prepare.js`, `prepare_cpu.js`, `prepare_direct.js`, `prepare_format.js`
   `prepare_io_order.js` and `prepare_regressions.js` in this directory, after generating existing
   accessory integration fixtures. The checked-in fixture scripts use production
   logic; ModelSim adaptations only relocate declarations/explicit output regs
   and add `entity work.` to production T80 direct instantiations.
3. Execute `run.ps1 -Group 0` through group 11. Execute `run.ps1 -Phase -Group 0`
   through group 7. Independent groups use independent ModelSim libraries.
4. Execute `direct.do`, `format0.do` through `format3.do`, and the regression
   runners. `final_regressions.ps1` supplies final DDRAM/profile checks; ordinary
   replay logs come from `regressions.ps1`.
   `rerun.ps1 -Group 0..17` distributes the complete primary rerun; the two
   io_order do-files run separately. Split final regression groups f03_0..2,
   f05_0..2, f09_0..2 and f10_0..2 allow independent profile processes.
5. Run `static_checks.js`, existing F07/F02 static checks, and
   `node tests/savestate_lightgun_fix/results.js --sim-only`.
6. Only after simulation passes, compile the isolated `candidate/SMS` with the
   established Quartus 17.0.2 full flow. Run `results.js` for final metrics and
   warning comparison against the built committed-F10 candidate.

The build script regenerates `build_id.v` from the current date. This generated
date is reported separately from the 136 source/settings inputs; it is not a
production source change. All Quartus products stay beneath `candidate/`.
