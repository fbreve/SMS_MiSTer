# Reproduce the current-v14 investigation

Read [review.md](review.md) first. This tree contains retained evidence, including superseded/incomplete pilots. Use [results.json](results.json) and [coverage.md](coverage.md) for canonical dispositions; a text-history DUT ending with the general PASS marker still **demonstrates a defect** and is classified COUNTEREXAMPLE COMPLETED.

Prerequisites used: Windows PowerShell, Node at `C:/Program Files/nodejs/node.exe`, ModelSim Intel FPGA Starter17.0 at `C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem`, its `altera_mf` library, and unchanged committed HEAD58583189b5c650dc6658ef467e8dcb72d9f6e6c2. No Quartus is needed. Run from the repository root. Preserve retained evidence before rerunning a case; simulator output files are overwritten.

Compile the retained family sources, then run independent reference and DUT cases:

```powershell
$repoRoot = (Get-Location).Path
$simBin = 'C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem'
Push-Location tests/savestate_g02_g05_v14/text_history
& "$simBin/vsim.exe" -c -do 'do compile.do' -l compile.log
Pop-Location
Set-ExecutionPolicy -Scope Process Bypass
& tests/savestate_g02_g05_v14/run.ps1 -Fixture text_history -Cases h0,h1
& 'C:/Program Files/nodejs/node.exe' tests/savestate_g02_g05_v14/pair_metrics.js
& 'C:/Program Files/nodejs/node.exe' tests/savestate_g02_g05_v14/collect.js
& 'C:/Program Files/nodejs/node.exe' tests/savestate_g02_g05_v14/evidence_tables.js
```

For the decisive pair, check complete image equality and seven visible reference differences in pair_metrics.json, then all six `TEXT_HISTORY_RESULT ... visiblePixelDiff9 fetchDiff8` rows. CPU/VDP/beam/I/O assertions must still pass. The characterizer deliberately continues after visible pixel differences to measure them.

Other useful families/cases (compile each family with the same compile.do command before running its cases):

| Family | Cases | Purpose |
|---|---|---|
|fixture|sanity_collision,sanity_overflow|Actual64-slot G06 SAVE-only/LOAD sanity|
|bus|normal,clone|Actual64-slot normal and reduced-slot clone bus paths|
|ops|write_address,vram_write,partial_control,read_setup,first_read,next_read,cram_low,cram_high|Earliest intended following opcode fetch|
|memory_events|bus|Ordered actual VRAM/CRAM write events, all32KiB VRAM shadow and actual CRAM|
|pair_live|h0,h1|Different stale write-data, equal full images and futures|
|g04|pending64,near,late,overflow|Collision/status at current v14 boundaries|
|g04_native|pending|Every-host collision/IRQ/CPU/VDP oracle|
|line_irq|active|Actual line-IRQ handlers during suffix|
|dual_irq|enabled|Distinct System E pins/status and production VDP2 CPU IRQ routing|
|dual_corrected|bus,collision|Distinct-device bus and collision histories|
|direct_consistent|owner0|Primary direct owner with consistent metadata|
|direct|owner1|Secondary direct owner|
|hl|edges|Real HCounter IN, future HL edges and first-enable logs|

`run.ps1` copies pixel/native/memory reference files to each corresponding DUT. Keep those reference inputs from the matching current source configuration. `bus/dut_fullflush`, `stalls_valid/dut_p1`, `stalls_valid/dut_p2` reuse `bus/reference_clone/reference.dat`. `g04_stalls_valid/dut_pending` reuses both `reference.dat` and `native_reference.dat` from `g04_native/reference_pending`. Run their retained `run.do` directly from their run directories after mapping `vdp_work` to `../vdp_work`; do not use the paired runner for these DUT-only variants. Their family sources must be compiled first. Scan and component sanity cases also have retained individual run.do files; inspect the exact commands beside their logs.

Canonical fixture sources already contain reference DMA isolation, actual CPU input-consumption oracles, correct device muxing and ST_IDLE request discipline. Generator scripts document construction and ROMs, but some construct an earlier intermediate and require subsequent `isolate_reference.js`/family patches. Do not regenerate over retained evidence to reproduce a final case: compile retained sources directly. `prepare_memory_events.js` builds its read-only observer from the retained corrected ops family.

`collect.js` verifies unchanged HEAD, all203 initial tracked-file hashes, empty tracked/staged diffs, and test-adapter identity to current production source after removing read-only probes/direct entity bindings. It checks terminal pass/end/no-error/sample-count markers rather than trusting ModelSim's process exit code. `pair_metrics.js` hashes decoded little-endian complete96KiB images as well as text files and compares architectural suffixes without audit probes. `evidence_tables.js` regenerates the human-readable canonical coverage table.

Four broad G05 DUT rows remain deliberately deferred by the stop rule. Do not turn their absence of a terminal result into a pass. Start further broad G05 work only within a separately authorized focused fix task.
