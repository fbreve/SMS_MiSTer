# F14 investigation reproduction

Production RTL is unchanged. These tests assert that the **existing defect is reproduced**, not that F14 has been fixed. `review.md` is the investigation report; `results.json` records canonical results and production source hashes.

From the repository root, with Node and ModelSim 10.5b installed:

```powershell
& 'C:/Program Files/nodejs/node.exe' tests/savestate_evolution_selector/prepare.js
& 'C:/Program Files/nodejs/node.exe' tests/savestate_evolution_selector/prepare_cpu.js
powershell -NoProfile -ExecutionPolicy Bypass -File tests/savestate_evolution_selector/run.ps1 -Group f14
powershell -NoProfile -ExecutionPolicy Bypass -File tests/savestate_evolution_selector/run.ps1 -Group cpu
powershell -NoProfile -ExecutionPolicy Bypass -File tests/savestate_evolution_selector/run.ps1 -Group history
powershell -NoProfile -ExecutionPolicy Bypass -File tests/savestate_evolution_selector/run.ps1 -Group regressions
& 'C:/Program Files/nodejs/node.exe' tests/savestate_evolution_selector/results.js
```

`prepare.js` creates simulation-only source adapters and copies the unchanged F13 regression fixtures into an isolated directory. It requires the retained `tests/savestate_mapper_detection_fix` and HCounter investigation sources. Their prior logs/results are never overwritten. The only production SystemVerilog adaptation moves two existing declarations ahead of their first use for ModelSim; the established VHDL T80 adapters spell component bindings as explicit entities. F13's mapper adapter adds missing `when others => null` choices only for non-binary case selectors.

The focused Evolution wrapper instantiates the two **unmodified production** Evolution modules and exactly packs `system.vhd`'s Evolution mapper word. It substitutes the reset Sega banks `00/01/02/03` and the corresponding identity address below `$C000`. The test never writes Sega bank registers; this substitution is exact for all tested ROM accesses. The independent existing bank-controller regression covers its actual restoration and launch behavior. Synthetic ROM content returns the physical address's top byte at `$8123`; the real CPU test mirrors a small guest program across the mapped pages. This is a functional data-path test, not a commercial ROM/game compatibility claim.

The directed tests drive normal CPU bus inputs; their savestate boundary signals are connected to that same bus. The T80 test supplies actual CPU bus timing, register capture/restore, and production video timing. Only the user-interface operation cooldown is bypassed. Selector registers, pending flags, and saved payloads are never forced or edited.

ModelSim libraries, `transcript`, and `vsim.wlf` are disposable generated artifacts and are removed from this investigation at completion. All retained `.sv`, `.vhd`, and `.do` files are reproducible test sources/adapters. No Quartus project/build is created.
