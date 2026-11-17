# G06/G10 sequential architecture experiment

Read `review.md` for the58 required findings and decision. Production RTL is untouched; `candidate_A/` is the isolated32-bit proof-of-concept, not a production patch. Build and functional source hashes bind the measured version. Do not copy this tree over production as part of this investigation.

Evidence navigation:

- `baseline.json`: HEAD, branch, prerequisites, historical endpoints, tracked raw hashes.
- `inventory.json`, `topology.md`, `design.md`: exact state, map, storage and sequencing contract.
- `functional_gate.json`: immutable pre-Quartus completed proof and frozen candidate hashes.
- `functional_results.json`: completed supplemental native fixtures, retained oracle hashes and F01 isolation.
- `read_retiming/equivalence.md`: exact bridge from the first distributed-response prototype to the selected boundary-response implementation. Archived sources are intentionally separate.
- `local*.log`, `memory.log`, `protocol/`: full-slot state/output, engine, complete-image and malformed/legacy tests.
- `sprites/`, `phases/`, `background/`, `dual/`, `pending/`: native integration fixtures. Reduced-slot and full64-slot evidence are distinguished in the report.
- `fm_isolation/`: retained exact raw OPLL/PSG/audio oracle; existing FM-output suppression, no new G08.FM scope.
- `build_*_inputs.json`, `*_results.json`, `timing_analysis.md`, `physical_diagnostics.json`: controlled physical evidence. A failed route has no valid completed timing-path report; its timing fields remain unknown.
- `latency.json`: intrinsic scan/application counts, fixed-response controller deltas, actual native phase-controlled observations and nominal PAL/NTSC conversion.
- `pilots.md`: excluded setup/scheduling pilots, never counted as completed proof.
- `final_integrity.json`: production, index, source binding and report identity verification.

Collectors are read-only with respect to RTL/build inputs (they write only evidence JSON):

```powershell
node tests/savestate_g06_sequential_architecture/collect_functional.js
node tests/savestate_g06_sequential_architecture/latency.js
node tests/savestate_g06_sequential_architecture/collect_build.js A
node tests/savestate_g06_sequential_architecture/collect_build.js confirmation
```

`prepare_build.js` refuses an existing build directory and requires the functional gate and unchanged production/candidate sources. `build.ps1` refuses concurrent Quartus, verifies the short-path mapping, disables settings writes, preserves the matched build date, and performs map/fit/asm/sta explicitly. Confirmation uses only one alternate seed, not a sweep.

**Do not rerun `bootstrap.js` or generator/preparer scripts over retained evidence.** They create fixtures or initial prototypes and may overwrite later source refinements. The frozen candidate and manifests are authoritative. A fresh reproduction should use a separate experiment copy and the archived source/fixture identities. ModelSim terminal pass markers plus `Errors: 0` are required; process exit0 alone is insufficient.

No commit, push, PR, permanent conversion, format change or next roadmap task belongs to this experiment.
