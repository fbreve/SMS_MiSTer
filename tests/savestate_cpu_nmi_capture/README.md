# F16 capture semantics prototypes

Read [review.md](review.md) for the precise semantic contract and test scope. Production RTL and savestate format are not edited. Candidate CPU files contain **test-only** history injection, hold and historical-sample inputs; they are not a proposed production patch.

Requires the same Node/PowerShell/ModelSim 17.0 installation as the original F16 evidence. Run from the repository root. Existing F16/F15 evidence folders supply the established fixture header and retained source-only adapters.

```
node tests/savestate_cpu_nmi_capture/prepare.js
node tests/savestate_cpu_nmi_capture/matrix.js
```

To compile the candidate library, set these PowerShell environment variables, then run the fixture driver:

```
$env:CAP_CAND='2'
$env:CAP_EDGE='0'
$env:CAP_WIDTH='1'
$env:CAP_SOURCE='0'
$env:CAP_PROGRAM='0'
$env:CAP_SECOND='9999999'
$env:CAP_HELD='1'
$env:CAP_BAD='0'
powershell -NoProfile -ExecutionPolicy Bypass -File tests/savestate_cpu_nmi_capture/sim.ps1 -Do capture.do -Label held_pilot
```

Then run `batch.ps1` for the 110 cases. Worker/Workers optionally partition the matrix against the same already compiled, read-only library. Do not recompile while workers are active. Each case records one uninterrupted reference plus three candidate replays and asserts 6001 clock-by-clock comparisons per replay, then compares all 8192 RAM bytes.

Run `negative.ps1` for the three **expected failures**. Success here means the trace comparator detected the intentionally broken ordering; their runtime logs contain Fatal and must not be confused with positive candidate runs.

Run `regress.ps1` for the copied 19 existing CPU/F12–F15 cases. Run `established.ps1` for four unchanged F16 actual SAVE/LOAD reproducers and two existing GG regressions. The actual F16 reproductions are expected to retain their original guest divergence because production is unchanged; the candidate prototype equivalence is tested independently by the matrix. These scripts need the copied `regression/` and `established/` source adapters retained in this evidence folder.

After runners finish:

```
node tests/savestate_cpu_nmi_capture/analyze.js
powershell -NoProfile -ExecutionPolicy Bypass -File tests/savestate_cpu_nmi_capture/cleanup.ps1
node tests/savestate_cpu_nmi_capture/analyze.js
```

The analyzer validates counts/results, both candidate agreement, the minimal normalized-Old distinction, negative-control failures, and unchanged production hashes. It writes `results.json` and `repository_status.txt`. Cleanup removes only this task's generated simulator libraries/waves/transient scripts. Canonical logs and source adapters remain.

No Quartus invocation, new format serialization, production fix, staging, commit, push or PR is part of this task.
