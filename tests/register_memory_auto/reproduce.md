# Independent RegisterMemory AUTO experiment

Production branch lives in the isolated `worktree/`; the original worktree and its uncommitted PhaseMemory change remain intact. Baseline is 8443a0d19a88aff7a5900011bccf386daf146945. Only the RegisterMemory `ramstyle of regs_array` specification is deleted. PhaseMemory retains its original logic attribute in both builds.

Source-only build trees are materialized by `prepare.js` from exact Git blobs. RegisterMemory is decoded/encoded as Latin-1 to preserve non-UTF8 comments. `input_manifest.json` hashes all source inputs. Do not overwrite existing builds/logs; reproduce in a new directory. `setup.js` is the fixture adaptation record; final generated scripts include the corrections documented in `fixture_notes.md`.

Run `node verify_inputs.js`, `node prepare_sim.js`, then ModelSim `vsim -c -do bank.do -l bank.log` and `fm.do`. Use the installed Quartus 17.0.2 and ModelSim 10.5b binaries listed in `tools.json`.

Run `node prepare_gate.js`; `powershell -NoProfile -ExecutionPolicy Bypass -File gate_build.ps1`; rename only exported Verilog top module RegisterMemory to RegisterMemory_gate in a copy named `RegisterMemory_gate.vo`. Run `gate.do`, `node prepare_mapped_sim.js`, then `fm_gate.do`. Vendor libraries in the DO files are required. AUTO inference is tested directly, without an explicit block type or RTL rewrite.

Run `node prepare_savestate.js`, `savestate.do`, `node prepare_savestate_gate.js`; set environment GATE_REFERENCE=1 and run `savestate_gate.do` to record the native oracle; then GATE_REFERENCE=0 and repeat to compare the mapped implementation. Keep separate logs for the two passes. The oracle trace and simulation databases are ignored generated files.

Run `powershell -NoProfile -ExecutionPolicy Bypass -File build.ps1` for fresh sequential baseline/candidate map, fit, asm, sta. The script temporarily maps Z: inside its process to keep Quartus paths short. Both builds use seed 1, fixed BUILD_DATE 261014, original device/project constraints/settings. The direct stage invocation bypasses only date-generating preflow. Do not reuse compile databases. Run `node measure.js` only after all eight build stages and all seven simulations complete; verify PASS lines and absence of fatal/errors/unbound components.

Reports describe simulation and measured whole-design implementation results. No hardware execution, merge, push or PR is part of this experiment.
