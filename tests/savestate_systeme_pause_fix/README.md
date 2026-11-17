# F12 System E pause implementation validation

Base: committed F11 `dcbe06d`; branch `fix/savestate-systeme-pause`.

Only `SMS.sv` and `rtl/savestates.sv` change in production. Format remains v8, with no host pause payload. `review.md` is the final 29-point report; `results.json` contains build/resources and selected-log hashes, and `simulation_results.json` contains scenario latencies/progress/transport lengths.

The user explicitly authorized bounded coherent CPU/PSG execution when a paused non-M1 bus must reach capture. This is an exception to a reference that remains completely stopped. Logical Pause and dimming stay asserted throughout. An already qualifying paused bus executes zero override ticks. Running and pending saves retain ordinary save-only equivalence.

## Fixtures and scoring

The generator extracts the actual SMS pause process and uses the actual save controller, two T80s, two live JT89 PSGs and a reference PSG. The independent reference uses its own request latch and bus predicate to implement the approved capture-progress contract. It is held during transport, then continues from the equivalent release point. Actual raw video continues for DUT as in production. Only UI cooldown is bypassed; CPU buses, UI phase, FSM and capture predicates are not forced.

The fast scenarios use idle VDP snapshot/memory models. `FULL=1` instantiates two DUT and two reference production VDPs and compares both architectural outputs every scored host clock, along with CPU/PSG and raw beam timing, through save-only and subsequent button toggles. Memory/read/render fields that are uninitialized remain X and are compared with four-state equality. This is not a commercial-ROM or rendered-image test. F07's separate real dual-VDP DDRAM test supplies known guest HCounter restore coverage.

Save-only compares all CPU register outputs, address/control/data buses and both PSGs' state/divider/audio every scored host clock. Repeated LOAD starts observing at release and compares the FIRST 128 native CPU and PSG enables. Read-cycle CPU data-out is unused; repeated-load scoring qualifies data-out with WR, while checking registers, addresses and control pins on every CPU tick. Native-clock scoring does not skip an arbitrary initial host interval.

`boundary_tb.sv` tests the extracted pause process directly. Its 1,600 cases are separate from full controller transactions: 1,568 edge/phase/offset/pattern/duration cases plus 32 held-level cases. Additional coupled-controller tests cover actual request, override, capture, transport and release timing.

`baseline/` captures the F11 SMS/controller, original generator/scenario and controller prefix. The permanent pre-fix reproductions therefore do not depend on an overwritten investigation fixture. Other compiled RTL comes from the repository, unchanged by F12. Broader regression runners require the existing F02–F11 audit test directories. ModelSim adaptation only moves two controller declarations and qualifies VHDL entity names; the pause process and controller expressions are production logic.

## Reproduce

Requires Node and ModelSim/Quartus from Intel FPGA Lite 17.0 at the paths in the scripts, with `altera_mf` available. Run from repository root:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/savestate_systeme_pause_fix/pre_fix.ps1
powershell -NoProfile -ExecutionPolicy Bypass -Command "& './tests/savestate_systeme_pause_fix/fixed.ps1' -Cases 0,1,2,3,4,5,6,7,8,9,20,21,22,23,24"
powershell -NoProfile -ExecutionPolicy Bypass -File tests/savestate_systeme_pause_fix/phases.ps1 -Group 0
powershell -NoProfile -ExecutionPolicy Bypass -File tests/savestate_systeme_pause_fix/phases.ps1 -Group 1
```

Run `stalls.ps1 -Profile 1`, `2`, and `3`; `edges.ps1 -Group 0` and `1`; and `fixed.ps1 -Cases 1,4 -Full 1`. For the process sweep, run `prepare.js` then ModelSim `boundary.do` from this directory. The full VDP configurations exceed Starter Edition's recommended design capacity and run slowly.

Run `prepare_regressions.js` once, then `regressions.ps1 -Group a`, `b`, `c`, and `d`. These refresh controller simulation copies from current production and write new logs here, leaving prior reports/logs intact. Run `static_checks.js` for controller-body/payload and top-level wiring scope checks.

`results.js --sim-only` requires exactly 105 selected clean logs: 63 fixed controller scenarios, five pre-fix reproductions, one 1,600-case process sweep and 36 broader runs. It verifies unchanged format and production scope. After this gate, `build.ps1` prepares an isolated candidate using the established F11 framework, compiles the complete core and records source hashes/resources/timing. `review.js` writes the final report after `results.json` exists. The 63 fixed scenarios complete 85 save/load transfers.

Core cases: 0 running; 1 pending pause; 2 last-cycle capture edge; 3 qualifying pause; 4 previously stalled non-M1 pause; 5 unpause before request; 6 unpause after equivalent point; 7 current paused LOAD; 8 current running LOAD from a saved pending phase; 9 pending unpause; 20 current pending-unpause LOAD; 21 current pending-pause LOAD; 22 pre-capture held input; 23 held input arriving inside transport; 24 held repeated-LOAD history. Case 16 sweeps 14 physical reset phases. Additional cases 10/18/11/14/15 supply the coupled edge sweep.

## Exploratory test-driver corrections

The original repeated-load checker waited twelve arbitrary host clocks before sampling, which skipped a PSG enable on one load. It was replaced by complete native-enable traces starting at release. That monitor returns after a rising edge; the request helper was then aligned to a falling edge so its pulse always contains a controller sampling edge. The early read-bus checker also compared data-out during reads; diagnostics showed equal CPU registers/address/control and differing unused DO values. The final checker compares DO on actual writes. None of these corrections changed production RTL or serialized state.

Only the manifest-selected logs are canonical. Exploratory logs are archived separately and are not pass/fail evidence for the final candidate. `clean.ps1` removes local compiled ModelSim libraries while retaining sources, canonical logs and the isolated Quartus build. Existing T80 width/Starter capacity and unused new-output warnings in old non-pause test instances are preserved. The actual production top connects the progress output; full Quartus warnings are compared separately against F11.

No staging, commit, push or PR is performed by these scripts.
