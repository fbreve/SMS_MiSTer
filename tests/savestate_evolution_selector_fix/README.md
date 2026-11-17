# F14 selector/history fix validation

`design.md` states the exact contract. `review.md` is the final report; `simulation_results.json` and `results.json` hold checked evidence and production hashes. Prior investigations are retained unchanged.

Retained fixtures are ready to run directly with `run.ps1` and `regressions.ps1`; both refresh their controller adapters from current production RTL before compiling. The negative baseline deliberately remains frozen. No prior investigation directory is needed to run the permanent pair/CPU/history/format fixtures as retained here. The optional preparation generators rebuild fixtures from the retained prior F13/F14 investigation sources and require those directories.

From the repository root, using installed Node, ModelSim and Quartus (the first three preparation lines are optional regeneration):

```powershell
& 'C:/Program Files/nodejs/node.exe' tests/savestate_evolution_selector_fix/prepare.js
& 'C:/Program Files/nodejs/node.exe' tests/savestate_evolution_selector_fix/prepare_format.js
& 'C:/Program Files/nodejs/node.exe' tests/savestate_evolution_selector_fix/prepare_compat.js
powershell -NoProfile -ExecutionPolicy Bypass -File tests/savestate_evolution_selector_fix/run.ps1 -Group pre
powershell -NoProfile -ExecutionPolicy Bypass -File tests/savestate_evolution_selector_fix/run.ps1 -Group core
powershell -NoProfile -ExecutionPolicy Bypass -File tests/savestate_evolution_selector_fix/run.ps1 -Group bits
powershell -NoProfile -ExecutionPolicy Bypass -File tests/savestate_evolution_selector_fix/run.ps1 -Group stress
powershell -NoProfile -ExecutionPolicy Bypass -File tests/savestate_evolution_selector_fix/run.ps1 -Group cpu
powershell -NoProfile -ExecutionPolicy Bypass -File tests/savestate_evolution_selector_fix/run.ps1 -Group history
powershell -NoProfile -ExecutionPolicy Bypass -File tests/savestate_evolution_selector_fix/run.ps1 -Group format
powershell -NoProfile -ExecutionPolicy Bypass -File tests/savestate_evolution_selector_fix/run.ps1 -Group compat
powershell -NoProfile -ExecutionPolicy Bypass -File tests/savestate_evolution_selector_fix/run.ps1 -Group f13
powershell -NoProfile -ExecutionPolicy Bypass -File tests/savestate_evolution_selector_fix/regressions.ps1 -Group a
powershell -NoProfile -ExecutionPolicy Bypass -File tests/savestate_evolution_selector_fix/regressions.ps1 -Group b
& 'C:/Program Files/nodejs/node.exe' tests/savestate_evolution_selector_fix/results.js --sim-only
powershell -NoProfile -ExecutionPolicy Bypass -File tests/savestate_evolution_selector_fix/build.ps1
& 'C:/Program Files/nodejs/node.exe' tests/savestate_evolution_selector_fix/resource_analysis.js
& 'C:/Program Files/nodejs/node.exe' tests/savestate_evolution_selector_fix/results.js
```

`cpu` also runs the history matrix; the standalone `history` group is optional. Run core/stress/bits sequentially because they share one compiled library. Independent groups use distinct libraries. ModelSim adapters move only two existing savestate declarations before use, explicitly bind T80 entities, and retain the established mapper case/meta-value adapter. Regression clones update current-writer/future-version expectations to v10/v11; datapath assertions and old v1–v8 vectors remain intact. The independent compatibility matrix explicitly includes v9.

The focused wrapper instantiates production Evolution mapper and Flash decoder, and packs the exact system Evolution mapper word. Ordinary Sega banks remain `00/01/02/03`, for which the substituted cartridge-relative address equals CPU A below `$C000`; all tested ROM accesses meet that condition. An independent production bank-controller regression checks actual bank restore/launch behavior. The real T80 guest program is mirrored across synthetic Flash pages; the byte at `$8123` is physical address[23:16]. This proves guest data-path equivalence without claiming commercial game or pixel correctness.

No selector state is forced. The sole force bypasses the user-interface save cooldown. Format tests deliberately mutate saved DDR words to test validation. Baseline tests execute committed-F13 sources copied into `baseline/`; their expected defect remains separate from passing current-model tests.

The build verifies 134 manifest inputs against committed F13 and two manifest-only unused backups, copies framework/source files into `candidate/`, preserves the baseline build ID and constraints, and never copies compilation databases. Full Quartus starts only after the complete simulation gate passes. Build artifacts remain isolated and untracked; nothing is staged or committed. Generated ModelSim libraries/waves are disposable and removed after validation.
