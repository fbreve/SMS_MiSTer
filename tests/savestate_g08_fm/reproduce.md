# Reproducing the G08.FM proof

Run from the repository root with Node.js, Windows PowerShell and the retained
Quartus/ModelSim 17.0 installation at `C:/intelFPGA_lite/17.0`. The fixture also
uses the retained F01, G08.release, F06 and G06/G10 test adapters referenced by
the compile scripts. This is a local evidence tree, not a standalone simulator
distribution.

`baseline.json` binds the original F06 HEAD and source files. `baseline/` is the
frozen v18 input; `candidate/` is the tested four-file v19 candidate. The final
collector requires candidate bytes to equal production bytes and all other
tracked sources to equal the baseline. Do not regenerate the baseline from a
modified or later checkout: the original `prepare.js` was an investigation
setup helper run before production edits. The saved baseline is authoritative.

Do not recompile a shared ModelSim library while workers are using it. The
commands below are for an idle workspace; use fresh case names so retained
evidence is preserved.

```powershell
# Known-state v18 publication-edge witness: expected one k0 audio error
# on SAVE and each LOAD, with zero raw FM/PSG/event errors.
powershell -ExecutionPolicy Bypass -File tests/savestate_g08_fm/known.ps1 -Compile -Variant baseline -Phase 70 -Skew 0 -FMOnly 1 -N 48000 -Replays 3 -CaseName repro_v18

# Same boundary with the unforced v19 production correction: all errors zero.
powershell -ExecutionPolicy Bypass -File tests/savestate_g08_fm/known.ps1 -Compile -Variant candidate -Phase 70 -Skew 0 -FMOnly 1 -N 48000 -Replays 3 -CaseName repro_v19

# Opposite channel and mixed-source stereo.
powershell -ExecutionPolicy Bypass -File tests/savestate_g08_fm/known.ps1 -Phase 70 -Skew 1 -FMOnly 0 -Stereo 1 -Stall 2 -N 48000 -Replays 3 -CaseName repro_stereo

# Production video timing, with legal reset duration moving the same FM
# history into VBlank. v18 loses one k0 pair; v19 is exact.
powershell -ExecutionPolicy Bypass -File tests/savestate_g08_fm/beam.ps1 -Variant baseline -Phase 70 -Skew 599700 -FMOnly 1 -N 6000 -Replays 1 -CaseName repro_beam_v18
powershell -ExecutionPolicy Bypass -File tests/savestate_g08_fm/beam.ps1 -Variant candidate -Phase 70 -Skew 599700 -FMOnly 1 -N 6000 -Replays 1 -CaseName repro_beam_v19
```

Use `-FullFlush` for the normal 900,000-clock LOAD flush and omit it for the
fast transport fixture. `-History 0/1 -Converge 1` reproduces the two converged
histories. `-Program 1 -Seed <seed>` selects deterministic varied FM programs.
`silent.ps1` compiles/uses the legal all-channel PSG volume-mute fixture;
`qprobe.ps1 -FullFlush` additionally reads the changed OPLL rows before apply.
Both retain the same actual post-apply 104-row readback and exact audio oracle.

The complete recorded campaign is described by `phase_campaign.ps1` (12
workers), `directed_campaign.ps1` (two workers), the two 1,080,000-pair cases,
`equal.ps1`, the silent/Q probes, `f01.ps1`, `release.ps1`, `original.ps1`, and
the format/import/PSG compile scripts. `workflow.ps1` waits for all directed
cases, runs the 24 random captures, verifies the retained regressions, then
collects the gate and starts controlled Quartus. It is not a setup script for
missing directed results.

`collect_functional.js` is the final fail-closed evidence check. A ModelSim
exit code alone is insufficient: completion markers, `Errors: 0`, zero
mismatch counts and complete actual state readbacks are mandatory. The v18
characterization runs deliberately permit the documented one-pair defect;
every candidate run rejects it.

The build scripts require a passing source-bound functional gate and a fresh
build directory. They preserve all retained F06 settings/inputs except the
four changed production sources. Existing Quartus results must not be
overwritten to manufacture a second run. A confirmation build is allowed
only by the task's single-confirmation rule and requires an explicit reason
in the timing/resource review.
