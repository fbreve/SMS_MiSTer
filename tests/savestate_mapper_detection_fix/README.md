# F13 mapper-detection fix evidence

`design.md` records the implementation contract extracted from the completed investigation before production edits. `review.md` is the final report; `results.json` contains validated logs, timing/resources and source hashes. Historical investigation evidence remains unchanged in `../savestate_mapper_detection/`.

Generate current isolated fixtures once, then run independent groups:

```powershell
& 'C:/Program Files/nodejs/node.exe' prepare_fixed.js
& 'C:/Program Files/nodejs/node.exe' prepare_edges_fixed.js
& 'C:/Program Files/nodejs/node.exe' prepare_format.js
& 'C:/Program Files/nodejs/node.exe' prepare_cpu_fixed.js
& 'C:/Program Files/nodejs/node.exe' prepare_boundary_fixed.js
& 'C:/Program Files/nodejs/node.exe' prepare_terminal.js
& 'C:/Program Files/nodejs/node.exe' prepare_regressions.js
powershell -NoProfile -ExecutionPolicy Bypass -File run_fixed.ps1 -Group core
powershell -NoProfile -ExecutionPolicy Bypass -File run_fixed.ps1 -Group deadline
powershell -NoProfile -ExecutionPolicy Bypass -File run_fixed.ps1 -Group stress
powershell -NoProfile -ExecutionPolicy Bypass -File regressions.ps1 -Group a
powershell -NoProfile -ExecutionPolicy Bypass -File regressions.ps1 -Group b
```

Run `edge_fixed.do` twice with F13_EDGE_MODE=0/1, `cpu_fixed.do` with F13_EARLY=0/1, and `format.do`/`boundary_fixed.do`/`terminal_fixed.do` using ModelSim17.0's vsim.exe path used in the drivers. Preserve output as `fixed_edge0/1.log`, `fixed_cpu0/1.log`, `format.log`, `boundary_fixed.log`, `terminal_fixed.log`. Run `banking_current.do` as `reg_banking.log`. The ordinary core/deadline/stress drivers write unique libraries/logs automatically.

`pre_fix.ps1` uses the immutable F12 HDL/fixtures in `baseline/`. Its four behavioral logs are expected defect reproductions, not passing correctness claims; two other logs retain real T80/video reachability. Baseline production copies were made before editing RTL. A full pre-fix rerun is independent of current fixed production interfaces.

Regression clones retain the prior tests' datapath assertions. Their only compatibility edits are current writer marker8→9, future unknown marker9→10, explicit terminal/zero history inputs for mapper-free models, the current controller model, and relative source/MIF paths. Existing v1–v7 mutation vectors remain unchanged. The new24-case format matrix explicitly tests v8 as a legacy version, in addition to all earlier versions and v9. `regressions/` and `rtl/` contain these isolated source/MIF copies; original historical tests/reports/logs are preserved. `prepare_regressions.js` records every copied source filename.

Simulator adaptations are limited to the established two savestate forward-declaration moves, three binary-case default null choices in mapper_ctrl, and VHDL T80 entity qualification. No mapper history, CPU state or controller state is forced. The UI cooldown alone is bypassed between operations. All evidence is accumulated through production reset/download/bus behavior. The real CPU test uses actual mapped cartridge reads, OUT data, real video VBlank and CPU restore.

Core tests rebuild the uninterrupted reference prefix to the recorded capture age, freeze it through the same detector drain, and compare history exactly. Each accepted LOAD is checked at the actual mapper_set edge, before legitimate post-release clock progress. First future traces compare reference/DUT every host clock; later traces compare the complete recorded mapper/history/address/RAM-enable/read-data trajectory. Stress uses8 LOADs per snapshot and alternating discarded Sega/bank/Wonder Kid writes with command-time DDR backpressure. The phased sweep tests15 native enable offsets ×3 evidence classes ×5 deadline requests =225 coherent captures. Another15 phase cases independently anchor the enable offset to BIOS handoff and explicitly cover timer65534, avoiding correlation between successive global divider phases. These240 samples stop each transaction after capture and are not counted as completed transfers.

An early exploratory stall profile asserted BUSY even while idle and therefore never offered the required32 quiet drain clocks. The final stress model asserts backpressure only for commands, matching the established controller fixtures. This was a fixture correction; production drain rules were preserved.

Run `results.js --sim-only` to validate the complete simulation gate. `build.ps1` refuses to start Quartus until it passes, verifies the committed F12 baseline, and compiles a fresh isolated `candidate/` with the same framework and build ID. `results.js` then validates completed full compilation and every build/source hash. No staging/commit/push/PR is performed. Quartus products remain isolated and untracked for review.
