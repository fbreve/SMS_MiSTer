# G06/G10 restart-ordering investigation

No production changes or format changes. Run from the repository root with Node and ModelSim17 installed at the paths used by the existing fixtures.

```powershell
& 'C:/Program Files/nodejs/node.exe' tests/savestate_g06_g10_release/prepare.js
powershell -NoProfile -ExecutionPolicy Bypass -File tests/savestate_g06_g10_release/run.ps1 -Compile -Turbo 1 -Reference 1 -Label reference_t1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/savestate_g06_g10_release/run.ps1 -Turbo 0 -Reference 1 -Label reference_t0
powershell -NoProfile -ExecutionPolicy Bypass -File tests/savestate_g06_g10_release/run.ps1 -Turbo 1 -Label common_t1
foreach($delay in 20,22,24,26,28) {
  powershell -NoProfile -ExecutionPolicy Bypass -File tests/savestate_g06_g10_release/run.ps1 -Turbo 0 -SaveOnly 1 -Diagnostic 1 -SavePhase $delay -Label "phase${delay}_t0"
}
powershell -NoProfile -ExecutionPolicy Bypass -File tests/savestate_g06_g10_release/run.ps1 -Turbo 1 -CommonPhase 1 -Label forced_common_t1
& 'C:/Program Files/nodejs/node.exe' tests/savestate_g06_g10_release/analyze.js --final
```

`SavePhase` schedules external DDR BUSY clearance, not a forced internal phase. The unchanged controller chooses the next legal quiet edge: timing targets20/22/24/26/28 produce actual phases21/23/27/27/29. The duplicated27 cases check repeatability. No CPU, video, sprite, divider or controller state is forced in these phase-only cases. The sole `clkd=1` assignment is the explicitly requested Phase6 common-phase control and executes only with `CommonPhase=1` at LOAD release; its already-quiet CE values agree with the target phase.

The divider source is extracted verbatim from SMS.sv; only its local clock identifier changes. CPU adapter additions expose MCycle, TState and restart-controller phase. The retained G06 test-only snapshot/freeze adapters are copied without promotion into production. All initialized memory and ROM details are in vdp_tb.sv, rom.hex and rom.json. No random seed is used.

Previous witnesses A/B/C are frozen by the SHA256 references in retained.json. `prepare.js` does not regenerate or alter that evidence. The latest fixture adds disabled-by-default diagnostic controls between runs; unchanged production transition logic and the active original branches are retained. `DIAGNOSTIC=1` records all mismatches instead of stopping at the first; analyze.js requires the expected guest divergence, source equality and late-phase equality explicitly. A completed characterization is not a fixed replay pass.

`timeline.csv` samples **pre-rising-edge** inputs/state after the falling-edge divider updates. The `DIVIDER_RELEASE` event is the phase of the rising edge whose NBA deasserts freeze; the next host clock is the first unfrozen edge. Distances count from that release edge. Status request means active BF read. `status_sample` means a CPU-enabled non-M1 T2 read-data latch; I/O wait sequencing can produce multiple such samples per IN, so the field is not an instruction counter. `acc` is accumulator A; `bus_A` is the address bus. MC/TS are the core's actual exposed signals.

The long raw-video alignment wait can produce large CSVs. After completion, `compact_trace.js common_t1 forced_common_t1` archives each full CSV losslessly and retains all observed guest/capture/restore clocks plus16 pre-release frozen clocks. Archive hashes and selection rules are recorded alongside the trace. Do not compact a running simulation.

Sanity fixtures are retained under sanity/: G01 terminal LDIR, F16 capture-edge NMI, F12 paused non-M1 capture, and F07 GG latch. Their logs state the exact narrow assertions; no full regression suite or Quartus run is part of this investigation.
