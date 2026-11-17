# G05 reproducibility and evidence

The baseline is committed `58583189b5c650dc6658ef467e8dcb72d9f6e6c2` (v14).
Production changes are the six files in `production_sources.json`. The final
report is `review.md`; machine-readable results are `simulation_results.json`
and `build_results.json` after all gates complete.

Use Node `C:/Program Files/nodejs/node.exe`, ModelSim Starter17.0 and Quartus
Lite17.0.2. PowerShell commands below run from the repository root. All fixture
libraries are isolated; parallel simulations may read a compiled library but
must never recompile it while active.

## Pre-edit evidence

The preparation/gate/application scripts represent an ordered workflow on a
pristine baseline checkout, **not commands to rerun over the applied patch**:
`prepare_baseline.js`, `analyze_baseline.js`, `inventory.js`, the prototype/text
fixture preparations, `prepare_proposed.js`, `prepare_component.js`,
`prepare_format.js`, `gate_sufficiency.js`, `apply_proposed.js`, then
`preserve_endings.js`. They deliberately reject or cannot double-apply the
proposal over production v15. Preserve the original gate JSON: it proves that
production was unchanged when sufficiency was established. The corrected
derived baseline decoder distinguishes beam x124 from pipeline x131; the raw
capture logs are unchanged.

Compile each fixture from its directory using `vmap -c`, then
`vsim -c -do 'do compile.do' -l compile.log`. Run reference then DUT with:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
./tests/savestate_g05_background_fix/run.ps1 -Fixture baseline -Cases h0,h1
./tests/savestate_g05_background_fix/run.ps1 -Fixture prototype -Cases h0,h1
```

Baseline PASS is **defect characterization** (nine visible errors per LOAD),
not a successful production result. Intentional omission controls are separately
asserted expected negatives. The transparent-foreground text pilot had no RGB
divergence and is not counted as a causal success. Component and format tests
run their own `run.do`; their models/mock endpoints are not whole-machine proof.

## Applied-v15 runtime matrix

`prepare_integrated.js` generates actual-controller integration families from
retained investigation fixtures. It strips prototype side-record feedback.
`prepare_q_history.js`, `prepare_dual_render.js`, `prepare_extra_runtime.js`
add guest memory/register Q, independent dual backgrounds, legal stalls,
natural divider phases, full production flush and left-column masking.
Do not regenerate/compile a family during its simulations.

```powershell
./tests/savestate_g05_background_fix/run_dut.ps1 -Fixture integrated_original -Case h0 -Reference baseline/reference_h0
./tests/savestate_g05_background_fix/run_dut.ps1 -Fixture integrated_original -Case h1 -Reference baseline/reference_h1
./tests/savestate_g05_background_fix/run.ps1 -Fixture integrated_rich -Cases mode4,gg,text,graphics1,graphics2,mixed_m3,sms224,pal240,scroll
./tests/savestate_g05_background_fix/run.ps1 -Fixture integrated_mode_switch -Cases special
./tests/savestate_g05_background_fix/run.ps1 -Fixture integrated_visible_text -Cases early
./tests/savestate_g05_background_fix/run.ps1 -Fixture integrated_dead_text_bits -Cases h0,h1
./tests/savestate_g05_background_fix/run.ps1 -Fixture integrated_q -Cases history
./tests/savestate_g05_background_fix/run.ps1 -Fixture integrated_dual_render -Cases primary,secondary,both
./tests/savestate_g05_background_fix/run.ps1 -Fixture integrated_g02 -Cases active
./tests/savestate_g05_background_fix/run.ps1 -Fixture integrated_g03 -Cases bus
./tests/savestate_g05_background_fix/run.ps1 -Fixture integrated_g04 -Cases pending
./tests/savestate_g05_background_fix/run.ps1 -Fixture integrated_g06 -Cases sanity_collision,sanity_overflow
./tests/savestate_g05_background_fix/run.ps1 -Fixture integrated_dual_irq -Cases enabled
./tests/savestate_g05_background_fix/run.ps1 -Fixture integrated_hl -Cases edges
./tests/savestate_g05_background_fix/run.ps1 -Fixture integrated_stalls -Cases deterministic,lfsr,phases,full_flush
./tests/savestate_g05_background_fix/run.ps1 -Fixture integrated_masked -Cases masked
```

The four deferred cases retain their exact ROM/memory/request arguments and
long suffix. Fresh independent v15 references account for the documented
deterministic missing-history normalization; the original natural full-frame
witness uses untouched v14 references. All sampled colors are compared, without
assuming registered VBlank always correctly labels viewport-transition pixels.

Actual64-slot production sprite packing is exercised by the original pair,
dead-bit pair and G06 regressions. Other8-slot fixtures prove BG139 transport
and native restart with reduced sprite topology, not full sprite-layout coverage.

The long audit cases were distributed across independent workers. Some unchanged
`run.do` files were temporarily named `run.queued.do` while older serial queues
were stopped from launching duplicate work; all original names are restored.
An initial Mode4 DUT launch was deliberately interrupted for rescheduling and
retained as `scheduling_interruption_simulation.log`; it is not a functional
result. The final gate uses only complete, independently verified runs.

## Targeted CPU/Pause sanity and final gates

```powershell
./tests/savestate_g05_background_fix/run_sanity.ps1 -Fixture sanity_g01
./tests/savestate_g05_background_fix/run_sanity.ps1 -Fixture sanity_nmi
./tests/savestate_g05_background_fix/run_sanity.ps1 -Fixture sanity_pause
& 'C:/Program Files/nodejs/node.exe' tests/savestate_g05_background_fix/check_simulations.js
```

The checker verifies complete logs, exact replay counts, known complete v15
images, image/future pair conclusions, all139-bit production source hashes,
controller identity and the entire VDP transition cone after stripping only
read-only observations/named-port ordering. It rejects staged/unintended
tracked changes. `--progress` writes a partial ledger and never authorizes a build.

Only after that final gate passes:

```powershell
& 'C:/Program Files/nodejs/node.exe' tests/savestate_g05_background_fix/prepare_build.js
./tests/savestate_g05_background_fix/build.ps1 -Version v14
./tests/savestate_g05_background_fix/build.ps1 -Version v15
& 'C:/Program Files/nodejs/node.exe' tests/savestate_g05_background_fix/collect_build.js
& 'C:/Program Files/nodejs/node.exe' tests/savestate_g05_background_fix/assess_build.js
& 'C:/Program Files/nodejs/node.exe' tests/savestate_g05_background_fix/generate_review.js
& 'C:/Program Files/nodejs/node.exe' tests/savestate_g05_background_fix/final_hygiene.js
git diff --check
git diff --cached --stat
```

Build preparation is source-only and can precede the simulation gate; invocation
cannot. It requires fresh ignored directories and verifies134 committed source
inputs against the retained v14 build. Both full flows use matching date/tool/
constraints/seed and no prior database. The collector reports deltas versus both
the fresh control and retained committed-v14 metrics. Review warning messages
and any substantial logic growth before marking READY. No command stages,
commits, pushes or creates a PR.
