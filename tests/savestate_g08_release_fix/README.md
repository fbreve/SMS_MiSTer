# G08.release coupled fix evidence

The original phase-only sufficiency search found an independent pending PSG
event omission. `review_blocked.md`, `sufficiency.json`, raw baseline traces and
initial prototypes retain that finding. The user subsequently authorized the
minimal coupled correction. `design_coupled.md` is the current design;
`design_pre_edit.md` records the earlier alternatives and state inventory.

`pre_edit_gate.json` records the passing coupled proposal before production
edits. `check_simulations.js` audits the completed final campaign, source
identities and one-line legacy fallback bridge, producing
`simulation_results.json`. Controlled results are in `build_results.json`;
the final 52-item report is `review.md` once both full builds pass. Historical
failing gates are intentionally retained and are not final acceptance gates.

Run from repository root with Node and ModelSim Intel FPGA17.0. PowerShell
scripts use `powershell -NoProfile -ExecutionPolicy Bypass -File`. Do not run
preparation scripts over active simulator/build directories.

The retained source preparation/runners are:

| Suite | Preparation | Runner |
|---|---|---|
| Original six LOADs | prepare_original_combined.js | original.ps1 |
| Component matrix35 | prepare_combined.js matrix; plan_matrix.js | matrix.ps1 -Compile |
| Literal modes10 | prepare_modes.js | matrix.ps1 -Fixture modes -Compile |
| Boundary neighbors12 | plan_boundaries.js | matrix.ps1 -Fixture modes -Cases boundary_cases.json |
| Format/raw PSG/VDP | prepare_regressions.js | regress.ps1 -Fixture format / raw_psg / vdp_original / vdp_g06 (one value per invocation) |
| Compatibility18 LOADs | prepare_legacy.js | execute legacy/run.do in legacy/ with vsim -c -do 'do run.do' -l simulation.log |

All scripts are under tests/savestate_g08_release_fix. Preparation uses the
fixed committed baseline for proposals and current production for final
regression adapters. The original campaign's matrix/format/VDP adapters retain
the pre-legacy-guard controller. Its single differing ARM LOAD initialization
is checked by the final gate; tagged LOAD overwrites it before use. A fresh
reproduction of those suites should use final RTL and adjust that historical
identity bridge, rather than substituting new logs into the archived campaign.

The35-case matrix independently varies audio component controls. Literal
production-mode chip-select/panning is covered separately by ten mode cases
and twelve phase/divider neighbors. Targeted VDP fixtures use the ordinary
eight-sprite limit, including two-sprite collision and nine-sprite overflow.
Physical64-slot packing has no production change and is not re-audited here.
Completed64-slot references and interrupted pilots are under controls64 and
excluded from final pass counts. ModelSim capacity warnings affect speed.
The retained VDP completion string says `PASS V15 VDP`; it is a fixture label,
not a tag oracle. The audited controller adapter writes/loads the v16 header.

The full build procedure uses two fresh source-only directories prepared by
prepare_build.js; its manifest verifies committed v15 and candidate inputs.
build.ps1 reruns the completed simulation gate before Quartus and refuses
unrelated active Quartus processes. The optional -ParallelControlPID permits
only the known isolated v15 control to overlap v16. Build directories,
simulator libraries and large offline reference streams are ignored.

```powershell
node tests/savestate_g08_release_fix/check_simulations.js
# prepare_build.js requires fresh directories; retained build inputs already exist.
powershell -NoProfile -ExecutionPolicy Bypass -File tests/savestate_g08_release_fix/build.ps1 -Version v15
powershell -NoProfile -ExecutionPolicy Bypass -File tests/savestate_g08_release_fix/build.ps1 -Version v16
node tests/savestate_g08_release_fix/collect_build.js
node tests/savestate_g08_release_fix/write_report.js
```

No commit, staging, push or PR is part of this task. G10 remains CLOSED;
G08.FM remains OPEN - BLOCKED BY F01.
