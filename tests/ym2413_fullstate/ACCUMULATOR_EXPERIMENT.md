# Accumulator-only restoration experiment

Base: `9873761503510e4b2c7e06600bf5515344235c2f`.
Branch: `experiment/ym2413-selfhealing-mix`.
The only production change removes `mix <= ss_v_mix` from word 101 restoration.
`mute`, `maddr`, word 102 (`mixout`), and all capture/transport behavior remain intact.

## Reproduction

Run from this directory, in a fresh copy of the experimental worktree. Generated
simulation adapters, libraries, traces and logs must not be added to source control.
The scripts refuse to overwrite an existing native campaign directory.
GHDL launch scripts use Windows Low (`Idle`) priority, inherited by the simulator.

1. Run `node prepare_tests.js` to extract the independent committed full-state
   reference and the candidate, including their wrapper integration.
2. Run `node instrument_oracle.js` to expose the independently packed architectural
   state. These observation signals exist only in the simulation adapters.
3. Compile `acc_compile.do` with ModelSim 10.5b. The Tcl oracle in `acc_run.do`
   independently reads live module fields and verifies their packing at each
   checkpoint. Use the phase-70 pilot to calibrate the native harness.
4. Run `node prepare_native.js`, then `powershell -NoProfile -ExecutionPolicy
   Bypass -File native_compile.ps1`. The portable GHDL 6.0.0 archive, published
   digest and extracted executable are recorded under the experiment's `tools/`.
5. Run `powershell -NoProfile -ExecutionPolicy Bypass -File native_campaign.ps1`.
   This runs all 72 phases, four repeated LOADs each, with six actual PAL VSYNC
   edges of follow-up per LOAD. It does not accelerate or skip host clock edges.
6. Run `node collect_acc.js` after all 72 children complete. This separately reads
   every recorded enabled-clock sample, validates the measured video periods,
   accumulator offsets, output differences and exact convergence boundaries, and
   writes `acc_results.json` and `production.diff`.
7. Run `node verify_preservation.js` and `git diff --check`.

The native injection hook is confined to simulation adapters. It is active only
while frozen, during the first restore word, and is disabled before word 101 is
written. It cannot mask an incorrectly retained accumulator restore assignment.
The full-state reference's injection hook remains disabled throughout.

## Assertions and interpretation

All 104 architectural words, the additional factory instrument RAM, delayed
controller counters, raw mixer output and clamped output are compared independently
of the capture path. Before convergence, only the accumulator and subsequently
the mixer output may differ. Other fields are compared continuously, including
feedback, envelope, phase, noise, RAM contents and controller state.

Poison cases include both signed extremes, an opposite-sign extreme, zero, -1,
alternating bits, a deterministic varied value, and a negated saved value. An
accidental match is adjusted by one bit. Every case asserts a meaningful initial
difference and the opposite-sign case verifies its sign explicitly.

The expected accumulator reset is the first enabled stage-2/slot-17 update. The
bad partial sum can reach `mixout` at that boundary. The next complete sum replaces
it exactly 72 enabled FM clocks later. Neither value feeds feedback or the other
synthesis state. The bench asserts these boundaries and separately scans the trace.

At the chosen 18.684 ns host period and FM enable every 15 host clocks, 142,728
enabled FM clocks are approximately 40 ms (two PAL frames), not 2.85 seconds.
The production video counter measures PAL and NTSC frame periods directly; the
NTSC counter is driven at the same host clock for this test. Six PAL sync edges
contain five complete measured PAL periods plus the initial partial period.

`cross_engine/` preserves the identical phase-70 ModelSim/GHDL pilot traces.
`acc_monitor_performance_diagnostic/` and `acc_runs/` contain deliberately stopped
ModelSim performance runs. They are not acceptance results. Only the completed
`native_runs/` campaign and its independently checked traces count as acceptance.

No Quartus compilation or hardware validation is part of this experiment.
