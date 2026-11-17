# Reproduction and evidence

Run from the repository root using Node and Quartus/ModelSim 17.0.2 paths in
the scripts. Preserved baseline files and baseline.json identify committed
v19; no Git mutation is necessary to inspect this investigation.

**Final state: the candidate was rejected and production was restored.**
The five tested candidate files are under candidate/ and experiment.patch
contains their diff. Existing prepared simulation copies and the Quartus
directory retain the candidate. To regenerate source-dependent fixtures or
the pre-build functional gate, use an isolated copy containing those five
candidate files; those collectors intentionally expect candidate production
inputs and should not be run against the restored v19 tree. The final-state
check is verify_final.js, which validates the restored tree and archived trial.

Do not rerun `implement.js` against an already modified tree: it deliberately
requires all pre-edit source hashes. It reconstructs the five-file experiment
only from the preserved, unchanged baseline. The final candidate hashes are
recorded by collect_functional.js.

The component test is `component.do` in this directory. Native library compile
scripts are `native_*/compile.do`; each fixture's `run.do` selects its original
test parameters. `prepare_native.js` prepares copies, instruments observation
ports, adapts the current controller and records input fixture hashes. The
generated `image.hex` is a DUT output, not a fixture consumed by these runs.
Do not rerun preparation while native cases are executing.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/cram_memory_inference/run_native.ps1 -Family g03 -Name dut_bus
```

Repeat for the 16 cases in native_manifest.json. The runner skips an already
verified completed case and uses an exclusive file lock to prevent two workers
from executing a case simultaneously. To intentionally rerun a completed
case, preserve/rename its simulation.log first. `run_remaining.ps1` splits the
long remaining campaign across two workers; individual later cases may also
run independently on this 28-logical-processor host.

`prepare_image_proof.js` prepares both original and selected-controller image
tests; each `image_*/run.do` compiles/runs its test. format/run.do and
imports/run.do run compatibility validation. Original fixture pilots are
retained under pilots/ and explicitly excluded from passing evidence. The
image_negative test is expected to fail the old64 secondary-palette assertion.

After all mandatory simulations complete:

```powershell
node tests/cram_memory_inference/collect_functional.js
node tests/cram_memory_inference/prepare_build.js
powershell -NoProfile -ExecutionPolicy Bypass -File tests/cram_memory_inference/build.ps1
node tests/cram_memory_inference/collect_build.js
node tests/cram_memory_inference/collect_structure.js
powershell -NoProfile -ExecutionPolicy Bypass -File tests/cram_memory_inference/analyze_paths.ps1
```

The source-only build must be fresh; prepare_build.js refuses an existing
quartus_early directory. It reuses the exact retained v19 settings, seed and
build date, and verifies the functional gate and five source hashes first.
Build and timing scripts create/check the Z: mapping in their own process;
they do not depend on a drive mapping inherited across sessions.

ModelSim may return exit code zero after `$fatal`. Passing evidence therefore
requires terminal PASS markers, `Errors: 0`, no Error/Fatal/Failure, original
suffix counters, and source/fixture bindings. `collect_functional.js` rejects
incomplete logs and generates the machine-readable functional gate.
