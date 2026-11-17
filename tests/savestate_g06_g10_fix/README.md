# Reproduction and evidence

Read [review.md](review.md), [contract.md](contract.md), [state_inventory.md](state_inventory.md), [simulation_results.json](simulation_results.json) and [evidence_metrics.json](evidence_metrics.json). Reports/logs are evidence; `*_work`, waveform files and the isolated `quartus` tree are rebuildable and ignored. No production behavior depends on a testbench define.

Tools used: Node24.20.0, ModelSim Intel FPGA Starter10.5b, Quartus Prime Lite17.0.2, seed1, Windows PowerShell. Tool paths are explicit in the runners. Run PowerShell scripts with `-NoProfile -ExecutionPolicy Bypass -File` if local policy requires it. The existing earlier savestate test trees are fixture-generation dependencies. Never copy all draft files over production automatically.

From the repository root, verify retained results:

```powershell
& 'C:/Program Files/nodejs/node.exe' tests/savestate_g06_g10_fix/evidence_metrics.js
& 'C:/Program Files/nodejs/node.exe' tests/savestate_g06_g10_fix/check_simulations.js
```

To rerun the CPU/Pause matrices, execute `matrix_g01/matrix.ps1`, `matrix_nmi/matrix.ps1`, and `pause_known/matrix.ps1`. Each recompiles its own library and checks every log for both errors and its explicit pass marker. Their `cases.json` and individual `.do` files are the authoritative parameter manifests. The full-flush representatives use `candidate_g01/run.do` and `candidate_nmi/run.do`, executed from those directories with ModelSim `-c -do 'do run.do'`; preserve the gated result filenames if replacing results.

For VDP integrations, compile once in the family directory with `vsim -c -do 'do compile.do'`. `candidate/run.ps1` provides the following final fixtures (run matching reference first):

```powershell
# Paths below are relative to this directory.
./candidate/run.ps1 -Reference 1 -Turbo 1 -Extended 1 -Warmup 1 -Fast 1 -Label reference_warm_t1
./candidate/run.ps1 -Turbo 1 -Extended 1 -Warmup 1 -Fast 1 -Slots 64 -Replays 3 -Label known64_turbo
./candidate/run.ps1 -Turbo 1 -Extended 1 -Warmup 1 -Fast 1 -Slots 64 -Natural 1 -Replays 13 -Label known64_natural13_turbo
./candidate/run.ps1 -Reference 1 -Turbo 0 -Extended 1 -Label reference_ext_t0
./candidate/run.ps1 -Turbo 0 -Extended 1 -Fast 1 -Natural 1 -Replays 13 -Label native13_normal
./stalls/run.ps1 -Sprites 9 -Turbo 1 -SaveOnly 1 -Stall 1 -Fast 1 -Label overflow_stall1
./stalls/run.ps1 -Sprites 9 -Turbo 1 -SaveOnly 1 -Stall 2 -Fast 1 -Label overflow_stall2
```

The ordinary sprite cases are fully specified in `sprites/cases.json`. `sprites/matrix.ps1 -Worker 0 -Workers 1` runs all14 references and14 DUT cases sequentially. It retains already passing logs; to deliberately rerun a case, move its old `simulation.log` to a distinct archival name first. Worker partitioning is optional process concurrency, not agent delegation.

`systeme/run.ps1` runs the complete two-VDP/two-JT89 board. Use `-Turbo 0 -Sys 1 -Extended 1 -Fast 1 -Replays 3`, then the following matching settings:

| Reference label | DUT label | Additional settings |
|---|---|---|
| reference_ui0_t0 | dual_systeme_running | UiPause0, Warmup0, Slots8 |
| reference_ui1_t0 | dual_systeme_paused | UiPause1, Warmup1, Slots8 |
| reference_ui0_t0 | dual_systeme_64_running | UiPause0, Warmup0, Slots64 for DUT |

Run each reference with `-Reference 1` before its DUT with `-Reference 0`. Wait for the complete paused reference, including unpause oracle files, before starting that DUT. `-DeferUnpause` was only used to overlap an already matched reference prefix; it is unnecessary for sequential reproduction. The64-slot running DUT uses the first8 active slots with SP64 disabled; higher entries cannot contribute. `psg/run.ps1` provides the separate dual-JT89 board (`-Sys 1 -Turbo 1 -Extended 1 -Fast 1 -Replays 3`, reference label `reference_s1_t1`, DUT `dual_psg_replay`).

For the natural omitted-state search, compile `search/compile.do`, then execute `search/history0_64/run.ps1` and `search/history1_64/run.ps1`. These fixed `.do` files select actual64 slots and opposite past controller histories. `search/program.json` hashes the guest ROM; `prepare_search.js` and its calibration pass explain the legal late SAT writes. Compare every word of both `image.hex` files and every line of both `suffix.dat` files; `evidence_metrics.js` also rejects unknown image words. No divider/evaluator register is forced for this search or the natural phase sweep.

`format/run.do` performs170 malformed rejects and15 valid/legacy accepts. `prepare_alias_equivalence.js` checks the final synthesis compatibility correction is exactly a register rename plus output aliases; execute `alias_equivalence/run.do` for the50,000-clock64-slot old/new implementation comparison. Its old source is retained as `before.vhd`; the failed strict93 check was a harness diagnostic against preexisting nonstatic port-map expressions, not a production requirement. Quartus checks its actual project language settings.

The mandatory distinct-Q proof is `distinct_q`: compile `compile.do` in that directory, map `vdp_work` to `../vdp_work` from `distinct_q/dut`, and run its fixed `run.do`. It preserves the original collision guest ROM/reference, uses actual64 slots and the final aliased production sprite source, and waits80/1450/2820 naturally executed host clocks before each request. At accepted LOAD it asserts pairwise different full live CPU/VDP/sprite/RAM/beam signatures, then compares each1,000-pixel resumed suffix exactly and checks the entire image immutable. Earlier three-LOAD controls used80/111/142 clocks and converged at acceptance; they prove repeatability, but are not counted as three distinct-Q coverage. The second Quartus attempt was stopped when this gap was found; only a fresh build after the expanded gate may establish the final result.

Generators are local and named `prepare_*.js`. The order for a fresh fixture regeneration is protocol, CPU protocol, candidate, integrated, CPU candidate, matrices, PSG, System E, Pause, sprites, format, stalls and search. The protocol generator reads the retained baseline witness fixtures. Before rewriting any evidence, archive old logs and note which source revision they prove. The initial prototypes predate the production consumed-T bit and are not current-format proofs.

For synthesis, `prepare_build.js` prepares a **new** source-only `quartus` directory and refuses reuse. It verifies134 committed post-G01 baseline files and two retained external baseline-manifest files, copies136 current hashed inputs, and preserves the baseline QSF, seed and build_id. Archive any previous isolated build within this task directory before preparing another; never remove or move repository sources. `build.ps1` reruns the full simulation gate before launching full compilation. After success, `quartus_results.js` verifies compiled/current source hashes and produces absolute/delta resources, setup/hold, violations, warning changes and a reconciled per-entity register ledger.

ModelSim can return process status0 after a testbench `$fatal`. Always use the log-checking gate. Shortened test-only flush paths retain the255-clock peripheral settlement; production and named full-flush representatives retain900,000 clocks. Reduced8-slot records are opaque transport proofs, not actual64-slot packing proofs; see the report's explicit evidence limits.

The request tasks bypass the host UI `op_cooldown` rate limiter so repeated SAVE/LOAD requests need not wait through the administrative cooldown. This does not force CPU, VDP, sprite or divider history, change capture eligibility, or replace naturally executed guest instructions. Claims of unforced natural histories concern those guest historical registers; the host request-rate bypass is explicitly excluded from that claim.

Build-date control: copying `build_id.v` does not pin it, because `sys/build_id.tcl` regenerates BUILD_DATE in the pre-flow step. The retained baseline is261022, while this candidate is261023. `prepare_baseline_control.js` verifies and copies the unchanged committed8ffd post-G01 sources, and `build_baseline_control.ps1` performs a separate full build with the candidate's261023 header. `controlled_comparison.js` verifies every control source hash and exact generated header equality, then records candidate deltas versus both retained and same-date baselines. The two builds have separate source/database/output trees; their deliberate process overlap shares no compilation inputs or output paths. No production Tcl, QSF, constraints or build-date generator is altered.
