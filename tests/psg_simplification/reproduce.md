# Reproduce functional qualification

Baseline is 8443a0d19a88aff7a5900011bccf386daf146945. The B/C worktrees hold uncommitted changes; use B.diff/C.diff to reproduce in fresh independent worktrees. No commit is needed. Do not apply a patch to the primary workspace or an existing experiment.

The retained preparation scripts document exact generation. `prepare.js` is first-creation only: it records preservation inputs and creates the two branches. `implement.js` regenerates candidate RTL and must not be run over later user edits. Existing preservation ledgers are evidence, not inputs to overwrite during reproduction.

Test generators, run with Node from the repository root:

```powershell
node tests/psg_simplification/prepare_tests.js
node tests/psg_simplification/controller_tests.js
node tests/psg_simplification/strengthen_replay.js
node tests/psg_simplification/native_tests.js
node tests/psg_simplification/control_tests.js
node tests/psg_simplification/compile_system.js
```

Use a new artifact directory if preserving these run logs. The executable used here is `C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe`. From each indicated simulation directory run:

```powershell
& C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe -c -do 'do replay.do' -l replay.log
```

Run `replay.do` in sim_A for the original fixture, and in strong_A/strong_B/strong_C for strengthened replay. Run `controller.do` in sim_B and sim_C with `-l controller_final.log`. Do not run simultaneous compilers against the same ModelSim library.

In native/, first run `run.do` with `-l native.log`, then `controls.do` with `-l controls.log`. Copy the preserved top-level focused_tb.sv into native/ and run its retained `focused.do` with `-l focused_qualified.log`. That script compiles focused_tb.sv and runs work.focused_tb. JT89 is identical between B and C; the focused generator test uses C and this equality is verified statically.

Run `run.do` in analyze_B/analyze_C with `-l system_analysis_pass.log` for VHDL interface/dependency analysis. These are not full-machine simulations. Compiler adapters are generated only in analysis directories; the worktree RTL stays untouched. See review.md for their scope.

`node tests/psg_simplification/verify.js` rechecks preserved inputs, existing refs, candidate source boundary, transport/publication logic and final PASS/error markers, then generates results.json, input_manifest.json and candidate patches. Source comparisons normalize only checkout line endings for text. The protected-file set excludes disposable simulator/Quartus db directories; it includes prior reports and RTL sources. Only the final linked logs are qualification results; retained early diagnostics show fixture development and compiler compatibility issues.

No Quartus command belongs to this stage.
