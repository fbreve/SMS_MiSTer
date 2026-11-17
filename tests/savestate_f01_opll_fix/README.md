# F01 implementation evidence

Start with [review.md](review.md), which follows all 61 requested report items. The production candidate is frozen in `sufficiency_gate.json`. `final_audit.json` verifies that candidate, clean staging, all gate log hashes, and the final report/build evidence.

This directory deliberately keeps evidence from unsuccessful elaboration/inference pilots. The report and collectors identify the accepted runs; do not count every log as a passing test. In particular, use `current_case0_final`, `current_case1..8`, the named controller witnesses, `phase_0..71`, `random_1..16`, and the regression manifest. Earlier `case*` prototypes and randomized library-order pilots are excluded.

Useful checks from the repository root:

```powershell
node tests/savestate_f01_opll_fix/progress.js
node tests/savestate_f01_opll_fix/collect_regressions.js
node tests/savestate_f01_opll_fix/handoff.js
node tests/savestate_f01_opll_fix/collect_build.js final
node tests/savestate_f01_opll_fix/accept_final.js
node tests/savestate_f01_opll_fix/write_report.js
node tests/savestate_f01_opll_fix/final_audit.js
```

Run the final build collector only after all four build stages finish, then run `accept_final.js` for the resource decision. `write_report.js` marks readiness pending if final results are absent or regression hashes are stale. It never modifies production or expected results. The early collector resets its resource classification; if deliberately rerunning it, follow it with `accept_resource.js`.

Simulation runners use ModelSim 17.0; PowerShell execution policy may require `powershell -NoProfile -ExecutionPolicy Bypass -File ...`. `random.ps1` runs independent original-OPLL oracle generation and then candidate replay for each seed. `regress.ps1` accepts worker indices for distinct fixture families; do not run two workers on one family/library. `regression_results.json` verifies unchanged input ROM/oracle hashes and distinguishes generated SAVE images from inputs.

`prepare_build.js early|final` requires a fresh, absent destination and verifies frozen production hashes. `build.ps1 -Name final` runs map, fit, asm and STA using a short Z: mapping, fixed baseline build date and settings writes disabled. It refuses concurrent Quartus processes. Build databases and simulator libraries are ignored; metrics, hashes and source manifests remain reviewable.

`contract.js`, `implement_local.js` and `integrate.js` are implementation-generation provenance, not routine test commands. The contract was frozen before edits. The implementation generators derive their source from the recorded baseline and overwrite production files; do not run them during evidence review. `prepare_*` scripts produce isolated simulation adaptations, leaving production sources unchanged.

G08.FM remains open. `handoff.json` is the exact restored raw-OPLL oracle for that separate investigation. F06 and format consolidation are excluded. Nothing is staged or committed by these scripts.
