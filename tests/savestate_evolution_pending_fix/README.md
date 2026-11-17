# F15 fix validation

Baseline committed F14 `ff9d66b`. Read [design.md](design.md) and final `review.md`/`results.json`. Production changes are limited to Evolution phase export/restore, its freeze connection in system, and validated v11 metadata in savestates.

Prepare current models and equality regressions, then run groups from repository root:

```powershell
& 'C:/Program Files/nodejs/node.exe' tests/savestate_evolution_pending_fix/prepare.js
& 'C:/Program Files/nodejs/node.exe' tests/savestate_evolution_pending_fix/post_prepare.js
powershell -NoProfile -ExecutionPolicy Bypass -File tests/savestate_evolution_pending_fix/validate.ps1 -Group pending
powershell -NoProfile -ExecutionPolicy Bypass -File tests/savestate_evolution_pending_fix/validate.ps1 -Group cpu
powershell -NoProfile -ExecutionPolicy Bypass -File tests/savestate_evolution_pending_fix/validate.ps1 -Group turbo
powershell -NoProfile -ExecutionPolicy Bypass -File tests/savestate_evolution_pending_fix/validate.ps1 -Group pairs
$env:F15_OFFSET='0'
powershell -NoProfile -ExecutionPolicy Bypass -File tests/savestate_evolution_pending_fix/sim.ps1 -Do reference.do -Label cpu_reference
powershell -NoProfile -ExecutionPolicy Bypass -File tests/savestate_evolution_pending_fix/validate.ps1 -Group selector
powershell -NoProfile -ExecutionPolicy Bypass -File tests/savestate_evolution_pending_fix/validate.ps1 -Group format
powershell -NoProfile -ExecutionPolicy Bypass -File tests/savestate_evolution_pending_fix/validate.ps1 -Group f13
powershell -NoProfile -ExecutionPolicy Bypass -File tests/savestate_evolution_pending_fix/regressions.ps1 -Group a
powershell -NoProfile -ExecutionPolicy Bypass -File tests/savestate_evolution_pending_fix/regressions.ps1 -Group b
& 'C:/Program Files/nodejs/node.exe' tests/savestate_evolution_pending_fix/static_checks.js
& 'C:/Program Files/nodejs/node.exe' tests/savestate_evolution_pending_fix/results.js
```

Run groups sequentially unless their libraries are separate. The retained final_cpu.do/final_reference.do and guard_cpu.do use separate library names for isolated concurrent validation; they compile the same current sources as cpu.do. `sim.ps1` compiles directly and runs the remaining Tcl simulation commands, records compile/runtime logs and requires PASS/zero errors. Old F14 result scripts contain historical branch/HEAD assertions and must not be used for this task.

`baseline/` retains the immutable F14 controller/Evolution observation adapters and four rerun expected-defect regressions, created before production edits. Its relative RTL paths reach only unchanged decoder/T80/video dependencies. Baseline runtime logs demonstrate armed switch, record read, bank reset and actual T80 data28/00. Those expected-loss tests pass by finding the confirmed defect. Current tests fail on any lost, duplicated, early or late state transition. In particular every real T80 launch must occur at target0020 while not frozen, with exactly one launch after an uncommitted snapshot and none after a committed snapshot. Directed suffixes compare all254 observed bits each host clock and compare repeated LOADs against the first restored trajectory.

Development corrections: an initial observer assertion reversed `{armed,read,menu}` relative to numeric payload order `{menu,read,armed}`; the payload/RTL mapping was correct and the assertion was fixed. The initial format wrapper used the debug observation port with the unmodified production entity; it now uses the established plain wrapper. More importantly, a deliberate semantic-timing test failed the first serialization-only candidate: T80 DIRSet created a false falling M1 while frozen and launched at000D. The production freeze connection and restored-M1 reconstruction fix that direct F15 ordering dependency. `timing_before_guard.log` is exploratory expected failure, not a passing regression or a pre-F14 baseline. Mirrored ROM alone masked that early commit, so the permanent launch-timing/count assertions are required.

The three payload bits are checked independently against logged internal flags. All57 F14 bits are exercised zero and one. Format matrices include each remaining padding bit, descriptor/owner/count/version defects, untagged/v1-v10/old64K Evolution rejection, valid phase-bit values, and non-Evolution compatibility through v11 including genuine v10 tag/old descriptor. Nothing reinterprets legacy unused padding.

The two old projection-pair cases now produce separate v11 packet images that differ at word02C **only by bit59**, the menu-arm field; every other initialized word is identical. Their different live futures remain distinct. This tests the format correction and does not claim a full-T80 architectural collision proof. The additional host-change case restores the armed snapshot three times while retaining current turbo B. Final simulation gate counts95 canonical logs,29 F15 SAVEs/63 LOADs,225,501 directed clock comparisons and78 matching CPU-enable samples.

After the simulation gate passes, prepare a source-only candidate with `prepare_build.js`, run full Quartus through `build.ps1`, then run `resource_analysis.js` and `quartus_results.js`. The F14 manifest is verified against committed HEAD; framework/device/constraints/build ID are retained, no compilation database is copied. Absolute resource and timing results compare to the retained successful F14 build. No commit, push or PR is performed. ModelSim libraries/transcripts/waves/temporary runner files are removed after validation; sources, logs and isolated Quartus evidence remain untracked.

Exploratory timing-before-guard and intermediate guard logs are isolated under exploratory/ and excluded from canonical passing logs.
