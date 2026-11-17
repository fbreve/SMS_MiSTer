# Combined mixer restoration experiment

Branch `experiment/ym2413-selfhealing-combined`, based exactly on
`9873761503510e4b2c7e06600bf5515344235c2f`.
Only the `mix` and `mixout` restore assignments are omitted. The other word-101
fields, all 104 capture words, version 17, operational registers, initialization,
wrapper, handshakes and DDRAM transport retain their committed implementations.

## Reproduce in a fresh experimental worktree

1. Before applying the production omission, run `baseline_regression.ps1` with
   Windows PowerShell. It checks exact baseline identity, then mapping, protocol,
   non-FM behavior, all 72 SAVE/LOAD phases and the normal-latency end-to-end case.
   The last case checks three captures, four restores including legacy loading,
   live internal state, audio continuation and actual controller DDRAM behavior.
2. Apply the two-line production change shown in `production.diff`. Copy the
   pre-experiment reference inventory to the parent `preservation_before.json`,
   then run `node verify_combined_scope.js`.
3. Generate simulation sources in order: `node prepare_tests.js`,
   `node instrument_oracle.js`, `node prepare_native.js`,
   `node prepare_combined.js`.
4. Run `compile_combined.ps1`. The GHDL 6.0.0 portable executable and supporting
   files must be in the parent experiment's `tools/ghdl6/`. Its archive, executable,
   generated sources and compiled-library metadata are hashed in
   `campaign_source_manifest.json`. The reference is extracted from the exact
   committed baseline and compiled into a separate library.
5. Run `combined_controls.ps1`. Both deliberately incorrect implementations must
   fail before unfreeze: restoring either omitted field destroys its poison.
6. Calibrate with `combined_one.ps1 -Shift 71 -FrameEvents 0 -RunDirectory
   pilot_binary71 -TraceCSV`. Preserve its CSV/binary files before later runs reuse
   the phase-numbered output filenames. `binary_layout.json` records the checked
   26-byte GHDL header and 48-byte, twelve-integer record layout. Every pilot record
   is compared with CSV independently.
7. From a separate `models_calibration` directory, run ModelSim 10.5b with
   `-c -do ../combined_models.do`. Set `COMBINED_SHIFT=71`, then run ModelSim with
   `-c -do ../combined_oracle.do`. Its Tcl oracle checks all 104 live fields in
   both libraries at all 28 checkpoints. Compare the entire CSV against the GHDL
   pilot; the accepted normalized digest is in `cross_engine.json`.
8. Run `combined_campaign.ps1`. It refuses to overwrite an existing campaign and
   launches at most four simulations. Every owned GHDL process inherits Windows
   Low (`Idle`) priority from its launcher. Each process's actual priority is
   sampled after spawning and every two seconds. A priority mismatch rejects the
   run. No unrelated process priorities or global settings are modified.
9. After all 72 phases finish, run `node collect_combined.js`. It reads every
   retained sample independently, checks poison propagation, modulo arithmetic,
   overflow, saturation, raw/clamped output, exact last mismatch, clock cadence,
   video periods, late effects, priorities, exit statuses and source digests.

## What is exercised

Each phase performs four SAVE/LOAD cycles with both mixer states simultaneously
poisoned. Cases include opposite signed extremes, both positive or negative
extremes, zero/nonzero pairs, alternating bits, sign-flipped saved values and
deterministic varied pairs. Accidental equality is adjusted and both initial
differences must be demonstrated. The test-only write hook runs during restore
word 0 and is disabled before either omitted word, preventing it from masking an
accidentally retained restore assignment. The reference's hook remains disabled.

All unaffected snapshot fields, additional factory voice RAM and delayed controller
counters must stay equal immediately after restore. Every state field and raw /
clamped output must be equal after convergence and remain equal. Live architectural
observations are independently packed from registers, variables and RAM, rather
than read back through the SAVE path. The ModelSim Tcl oracle separately validates
this packing against the hierarchy.

The normal accumulator clear is stage 2 / slot 17. Before that clear, accumulator
error must be a constant modulo-14-bit offset; the independently poisoned output
must retain its injected value. The clear transfers the wrong partial sum to
`mixout` and resets `mix`. The following complete 72-enable sum must replace that
output exactly. The last mismatching enabled sample and final host-clock sample
are explicitly measured for internal state, raw output and clamped output.

After convergence, each LOAD continues for at least 115 ms. Nine subsequent
register writes exercise key-off, key-on, rhythm/percussion changes and custom
instrument AR/DR and ML/flags changes. These use the actual production wrapper,
with write strobes in non-enabled host cycles and uninterrupted FM enable every
15 host clocks. Separate assertions verify that each write took effect, while
the continuous state/audio comparisons remain enabled.

Production `rtl/video.vhd` counters run in PAL and NTSC modes with pixel enable
every ten host clocks. Frame periods are measured from actual VSYNC edges; the
test uses the same 18.684 ns host period for both modes. 142,728 enabled FM clocks
are approximately 40 ms, or two PAL frames, not 2.85 seconds.

Binary traces retain every enabled sample. Their columns are phase, pass, enabled
clock index, candidate raw output, reference raw output, candidate accumulator,
reference accumulator, host index, PAL edges, NTSC edges, candidate clamped output,
reference clamped output. CSV is optional for small cross-engine calibration only.
No clocks, state comparisons or output comparisons are skipped by binary logging.

`verify_reproduction.js` generates fresh adapters in a separate directory and
checks all 38 native VHDL statement streams plus byte equality of the complete
bench. `reproduction_results.json` records the outcome and digests. Some non-ASCII
comments were normalized during early preparation; fresh generation preserves
their original bytes. This affects comments only. Use the retained campaign
adapters for byte-for-byte replay of the recorded source/library digests.

This is functional simulation only. It does not measure downstream analog audio,
MiSTer hardware behavior, Quartus inference, resource savings or physical timing.
