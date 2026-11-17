# Reproduce F16 investigation

Investigation-only integration fixture for committed `d1df590`. Requires Node, PowerShell and ModelSim Intel FPGA Starter Edition 17.0 at the paths in `sim.ps1`/`batch.ps1`. Nothing in this directory modifies production RTL or format.

1. Run `node prepare.js` from this folder. It generates simulation adapters from current production RTL plus the inherited F15 fixture header. Current code must match the baseline for retained hashes/results to apply.
2. Set NMI_EDGE=9999999, NMI_WIDTH=5, NMI_SOURCE=0, NMI_PROGRAM=0, NMI_RUN=1, NMI_TARGET=359; run `powershell -ExecutionPolicy Bypass -File sim.ps1 -Do nmi.do -Label warmup` to compile nmi_sync_work and validate the inactive baseline.
3. Run `powershell -ExecutionPolicy Bypass -File batch.ps1 -Manifest cases_sync.json` for all 314 timing runs. Optional Worker/Workers partitions use one compiled read-only library and distinct output names. Reusing the same case concurrently would overwrite its logs/image.
4. Run the same batch with `-Manifest proofs.json` for the 11 selected snapshot/replay probes.
5. `multi.do` and `causal.do` preserve the exact compile/run invocations for the double-edge and frozen-Q pending-clear proofs. They use the same environment convention; their retained runs use source/program0, edge-60/width5 for multi, edge-15/width5 for causal, run2,target359. These compile separate libraries. Then `extra.ps1` runs the held/fresh Old pair, double-edge reference, CPU-step scheduled SAVE-only controls and EI/prefix/HALT replays using nmi_causal_work.
6. Run `regress.ps1` for the 19 existing CPU/F12–F15 regression invocations, and `node analyze.js --final` for log parsing, known-bit full-image equality, timing coverage and trace comparisons.

`PASS F16` means a run reached its planned observation end without simulation/transport failure. It deliberately does **not** mean LOAD was equivalent: the logged differences are the defect. `analyze.js` performs cross-run comparisons and retains expected divergences in results.json. Review and inventory explain which observations prove F16 and which are post-capture live-input timing effects.

Synchronous read latency on the modeled WRAM savestate port is essential. Preliminary asynchronous-port experiments were discarded and are not canonical evidence. The CPU reads modeled RAM combinationally; the separate savestate port is one-clock synchronous, matching the controller's look-ahead pipeline.

No Quartus build is needed or performed. No proposed metadata/boundary/restore fix is present.
