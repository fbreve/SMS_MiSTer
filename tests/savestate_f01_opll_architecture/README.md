# F01 OPLL architecture investigation

Branch `investigate/savestate-f01-opll-architecture`, HEAD `cb2e8615128d61adb996ada68e6bbdcc314c20f6`. Production RTL and v16 are unchanged. No implementation, staged changes, commit, push or PR.

Read [review.md](review.md), [inventory.md](inventory.md), [architecture.md](architecture.md), [simulation_results.json](simulation_results.json), [non_injective.json](non_injective.json), and [micro_results.json](micro_results.json).

## Reproduction

Use Node24 and ModelSim Intel FPGA Starter10.5b from the installed Quartus17 tree. From this directory:

```powershell
& 'C:/Program Files/nodejs/node.exe' prepare.js
& 'C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vmap.exe' -c
& 'C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe' -c -do 'do compile.do' -l compile_fast.log
powershell -NoProfile -ExecutionPolicy Bypass -File campaign.ps1
& 'C:/Program Files/nodejs/node.exe' search_prepare.js
& 'C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe' -c -do 'do search_compile.do' -l search_compile.log
powershell -NoProfile -ExecutionPolicy Bypass -File search.ps1
& 'C:/Program Files/nodejs/node.exe' native_prepare.js
& 'C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe' -c -do 'do native_compile.do' -l native_compile.log
powershell -NoProfile -ExecutionPolicy Bypass -File native.ps1
& 'C:/Program Files/nodejs/node.exe' micro.js
powershell -NoProfile -ExecutionPolicy Bypass -File micro.ps1
& 'C:/Program Files/nodejs/node.exe' inventory.js
& 'C:/Program Files/nodejs/node.exe' collect.js
& 'C:/Program Files/nodejs/node.exe' report.js
& 'C:/Program Files/nodejs/node.exe' verify.js
```

Do not compile a simulator library while another kernel uses it. Cases have separate working directories and reference files. `run.do` accepts FMCASE/HISTORY/REF/STALL environment values. `decay_run.do` adds12,000 host clocks to the FMCASE2 prefix. `pair_b` reuses case0's oracle with HISTORY1; `stalled` reuses it with STALL1. The immutable known images and all result counts are checked by collect/verify. A ModelSim exit code alone is insufficient; require terminal markers and no Error/Fatal/Failure.

## Test composition and adapters

The controller adapter is the established G06/G10 test adapter: declaration ordering for ModelSim and optional shortened host-only LOAD flush. The controller, T80 and JT89 come from current production source. T80 `: work.Entity` instantiations receive the standard `entity` keyword. JT89's existing implicit-net redeclaration warning2388 is suppressed, without source alteration.

VM2413 uses Quartus-accepted scalar `'range`, incomplete binary std_logic case choices and a `Release` identifier that became reserved in VHDL2008. Test copies replace scalar ranges with their literal bounds, rename that identifier consistently, and add `when others => null` for non-binary choices. Binary-state behavior is unchanged. Production VM2413 is never edited. The behavioral `search_opll` copies additionally contain nonsynthesized local snapshot variables and test-package commands so experiments can preserve or omit categories. These hooks are deliberately **not** the proposed production snapshot architecture. `search_manifest.json` enumerates every intercepted process target/variable.

The focused composition uses real CPU, FM, PSG, divider, mixer and current controller with fixed VBlank/x and known zero VDP/peripheral/memory endpoints. It is a production-component/transaction test, not a complete game machine. Its CPU schedule corresponds to SMS turbo (`/10` CPU, `/15` FM), with System E off. FM writes use legal fixture IO latch stimulus. The native case instead executes real T80 `OUT` instructions and uses production video timing. It still mocks unrelated VDP/RAM/peripheral endpoints; do not call it whole-core/hardware coverage. UI cooldown alone is overridden for repeat requests; no OPLL history, guest counter or guest bus state is forced to establish the natural pair.

Both mixer inputs are scored, while raw14-bit FM is scored separately. Fast fixtures truncate the FM top sign bit at the mixer interface; every retained uninterrupted suffix is within the production clamp's pass-through range (range ledger), so expected stereo values agree there. Perturbed/LOAD mixer discrepancies are supporting evidence; the raw FM oracle is authoritative. The native fixture contains the production clamp expression; no claim is made that raw FM preservation alone closes G08.FM release.

The slow-attack case1 and preset1 case5 have silent20,000-clock uninterrupted windows. They are retained characterization probes, not the primary changing-signal attack/feedback witnesses. Case2 supplies changing active-attack audio; the additional decay case proves actual state10 at capture. User instrument case0 uses feedback7; the feedback-only memory ablation proves its sensitivity.

The first native pilot omitted initialization of alternate/general CPU registers and correctly stopped on an unknown image word. `native/pilot_*` logs are retained and excluded from successful counts. The completed native ROM includes the original register initialization prefix. Early syntax/library setup failures and one unnamed-generate micro compile failure are not simulation/resource passes. Final generated sources compile successfully.

All completed waveform tests capture after OPLL initialization. Current source has no initialization-ready SAVE predicate, so these tests cannot justify dropping initializer history or partly initialized fixed-voice backing. The conservative architecture includes that allowance (3,229 bits); the smaller initialized-state representation (1,896 bits) is conditional on a proved readiness contract. Source/necessity uncertainty is reported, not hidden as a passing startup test.

No production Quartus build was run. Eight synthetic map/fit projects use the same Quartus17.0.2, CycloneV device and relevant root performance settings. Virtual pins materially distort needed/unavailable ALM figures; separate placed counts and virtual-pin rows. They have no production SDC timing signoff. Mapped ALUTs, FF and M10K are representative structure measurements, not production deltas. Generated databases are ignored.
