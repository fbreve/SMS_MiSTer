# F11 investigation: confirmed, no production fix

Read review.md for the requested 22-point report and inventory.md for every state item and its clock/freeze behavior. results.json and sources.json record canonical log hashes, coverage metrics, branch/base and unchanged production-source hashes.

The conclusive minimal reproducer is cpu.do: production T80 CPUs run the nine-byte polling ROM documented in the review. A real M1 boundary at beam 254/192 triggers the real savestate controller. The saved local hcnt equals the target, so ungated hit logic arms a false pending sensor event during save-only transport. Both CPUs and video states agree at release; subsequent IN data and A registers diverge. No CPU or lightgun register is forced, and no load is needed for this proof.

stalls0.do through stalls3.do exercise full DDRAM save/load with no stalls, fixed stalls, seeded random stalls and deliberately long busy intervals. These use legal fetch-interface signals and I/O reads rather than complete CPUs. variant0..2 add P2, PAL and JP coverage; variant3 records an intentionally negative extended-border sample where the short old sensor tail ends before the tested read. That observation does not justify excluding F11.

prepare_sweep.js generates 33 sweep_caseN.do files. Each runs a complete natural timing/target case with the production video generator and gun process, sampling all qualifying pixel/CPU-enable positions in VBlank. Their 332424 observations are potential capture candidates, not 332424 completed saves or real CPU instruction boundaries. sweep_cases.json lists the configurations. Each .do is run in its own ModelSim process; groups sharing a compiled library must run sequentially.

To reproduce, use Node and the installed Intel FPGA Lite 17.0 ModelSim. Run commands from this directory:

1. node prepare.js
2. node prepare_cpu.js
3. vsim -c -do cpu.do
4. Run stalls0.do..stalls3.do and variant0.do..variant3.do separately to reproduce the existing log cases.
5. node prepare_sweep.js; run sweep_case0.do..sweep_case32.do, logging each separately.
6. From the root, run regressions.ps1 f07/f08/f09/f10 using PowerShell with a process-local execution-policy override if required. These run existing tests unchanged and keep logs here.
7. node static_checks.js; node results.js; node review.js.

prepare.js consumes the existing controller fixture prefix for committed F10 RTL from tests/savestate_hcounter/controller_tb.sv. It copies the production FSM with only the established two declaration moves for ModelSim. Gun adaptations are limited to explicit procedural output types, declaration ordering and a reference-only hold guard. CPU copies add direct-entity syntax accepted by ModelSim. static_checks.js reverses these adaptations and compares source expressions. The reduced probe.sv/probe.do is a warm-up diagnostic used to establish natural cold-start behavior; it is not the accepted-boundary proof.

The F07 latch slice is used in the minimal lightgun hierarchy; unchanged regressions separately instantiate the complete VDP. The real-CPU proof uses save-only, so it does not depend on CPU-load microcycle behavior. A new serialized payload or version bump is not established as necessary: correct freezing is mandatory, and any additional restore state must be justified during the separately authorized fix design.

All source/evidence authored for F11 is confined here. ModelSim libraries/waves are ignored. Production RTL has zero diff. No Quartus build, staging, commit, push or PR is part of this investigation. F06 remains unresolved.
