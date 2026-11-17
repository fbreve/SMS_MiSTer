# F12 investigation

Investigation only, based on `dcbe06d`. No production edits or format change.

`prepare.js` extracts the SMS pause process, with a parameterized fixture-only clear override, and adapts only declaration order in the production save controller and VHDL entity qualification for ModelSim. The controller prefix is reused from `../savestate_hcounter/controller_tb.sv`; all scenarios are replaced. The System E clock mapping comes from SMS/system: T80/controller use raw pixel enables, PSGs use CPU enables gated by pause, raw video continues, VDP enables are independent of pause. Two actual T80s execute an `INC A; JP 0` loop, with a transport-held reference. Physical reset release phases and button pulses reach the tested states; no pause flags, CPU bus signals, FSM states, or capture predicates are forced. Only the UI cooldown is bypassed between operations.

`FULL=1` adds two actual production VDPs with distinct physical bank inputs. The fast scenarios isolate the pause/controller/CPU/PSG interaction and replace VDP snapshots and memory data with idle values; they do not claim a complete System E motherboard simulation. The existing F07 dual-VDP DDRAM restore regression provides separate real-VDP load coverage. Both live PSGs and a reference PSG are instantiated by the current generator. The initial full-VDP run was compiled before the additional reference PSG and expanded FSM logging; its two live PSGs and pause/CPU/VDP logic are the same.

Run from the repository root:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/savestate_systeme_pause/run.ps1
powershell -NoProfile -ExecutionPolicy Bypass -Command "& './tests/savestate_systeme_pause/run.ps1' -Cases 1 -Full 1"
powershell -NoProfile -ExecutionPolicy Bypass -Command "& './tests/savestate_systeme_pause/run.ps1' -Cases 1,3,4 -Keep 1"
powershell -NoProfile -ExecutionPolicy Bypass -File tests/savestate_systeme_pause/regressions.ps1 -Group short
powershell -NoProfile -ExecutionPolicy Bypass -File tests/savestate_systeme_pause/regressions.ps1 -Group f07
powershell -NoProfile -ExecutionPolicy Bypass -File tests/savestate_systeme_pause/regressions.ps1 -Group f11
& 'C:/Program Files/nodejs/node.exe' tests/savestate_systeme_pause/collect.js
powershell -NoProfile -ExecutionPolicy Bypass -File tests/savestate_systeme_pause/clean.ps1
```

ModelSim 10.5b, Intel FPGA Lite 17.0, `altera_mf` precompiled library required. Large dual-VDP designs exceed Starter Edition's recommended capacity and run slowly. Existing unrelated T80 overloaded-AND width warning is retained.

Cases: 0 running control; 1 pending pause before request; 2 last host cycle before accepted capture; 3 already paused on qualifying held M1; 4 already paused on nonqualifying held bus, then external recovery; 5 unpause before capture; 6 unpause button after the equivalent reference point; 7 pending-state save/perturb/two loads; 8 paused-state save/perturb/two loads; 9 pending unpause during accepted VBlank. `KEEP=1` removes only freeze/unfreeze clears in the extracted fixture; this is a deliberately naive experiment, not a proposed fix.

`edge.do` is a small additional test of the extracted process's current-button history and held-input behavior; run `prepare.js` first. It is not an accepted-boundary test.

`PASS` on a reproduction means the expected defect was observed, not that production satisfies pause preservation. `results.json` lists selected logs and evidence. ModelSim libraries and generated simulation sources are removed by `clean.ps1`; they can be regenerated and are not deliverable build artifacts.
