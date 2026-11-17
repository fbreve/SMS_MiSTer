# F13 investigation

Production RTL is intentionally unchanged. See `review.md` and `inventory.md`.

Run from this directory with Node and ModelSim 10.5b at the installed paths:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File run.ps1
& 'C:/Program Files/nodejs/node.exe' prepare_edge.js
$env:F13_EDGE_MODE='0' # Wonder Kid; repeat with 1 for BIOS handoff edge
& 'C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe' -c -do edge.do
& 'C:/Program Files/nodejs/node.exe' prepare_boundary.js
& 'C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe' -c -do boundary.do
& 'C:/Program Files/nodejs/node.exe' prepare_cpu.js
$env:F13_EARLY='0' # repeat with 1
& 'C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe' -c -do cpu.do
powershell -NoProfile -ExecutionPolicy Bypass -File regressions.ps1
& 'C:/Program Files/nodejs/node.exe' results.js
```

`run.ps1` preserves twelve canonical case logs. For an individual case, run `prepare.js`, set `F13_CASE`, then run `run.do`. Transport models use real SAVE/LOAD FSM, DDR reads with3-clock latency and full slot writes; UI cooldown is the sole forced internal signal. All mapper history is accumulated by external download/reset/bus activity. Bus replay uses30-host-clock writes, compatible with native CPU enable spacing. No mapper history or FSM state is forced.

The twelve cases cover Sega-evidence Dahjee/4PAK divergences (0/1), no-evidence controls (2/3), already-selected controls (4/5), early linear/Sega-locked fallback loss (6/7), already-recognized Wonder Kid (8), suppressed future Wonder Kid (9), bank-evidence non-injective pair (10), and a Sega write after the evidence window (11). Each performs SAVE ONLY, reference replay, perturb/LOAD, and a second LOAD of the same state. It rebuilds the reference prefix to the recorded capture age for the LOAD comparison; no internal history assignment is used. The reference’s architectural mapper word is asserted equal to the saved word before perturbation.

`prepare_boundary.js` uses the same production detector/controller interfaces to accept183 capture points:61 adjacent request clocks around the terminal decision × no evidence/Sega evidence/bank-only evidence. It stops each transaction after capture and resets naturally for the next point; these are reachability samples, not183 completed transports. Tcl `examine` reads internal history without modifying it.

`prepare_cpu.js` adds actual T80 and production `video.vhd`. A synthetic cartridge executes real Sega and Korean bank writes then loops. Mature and early BIOS-handoff captures use actual CPU M1/MREQ/ISet, actual native enables and actual video VBlank/x. This proves reachability independently of the scripted bus fixture. It does not claim a commercial-game or complete real-CPU SAVE/LOAD replay.

`prepare_edge.js` derives a separate fixture/library with two modes. Mode0 saves recognized Wonder Kid with bank2=3, resets only the discarded machine, then performs two real LOADs. The first falsely replays the mapper-initialization edge and clears bank2; the second preserves the saved bank. Mode1 instead changes only the discarded BIOS visibility. The wrapper restores bootloader_n from mapper bit54 on mapper_set, matching the production system process; the first LOAD falsely replays BIOS handoff and sets bank2=2, while the second preserves3. Both edge trackers are reconstructable from already serialized state without additional payload.

Simulation adapters: move two existing forward declarations in savestates for ModelSim; add `when others => null` to three non-exhaustive std_logic cases in mapper_ctrl; qualify existing T80 VHDL entity instances. They change no binary-valued datapath or FSM expression. Normal SMS mapper packing is the exact production concatenation; System E/Evolution layouts are exercised separately by the existing directed mapper regression.

The old mapper differential oracle predates current interface/EEPROM simplifications. `banking_tb.vhd` removes the unused Evolution input connection from the DUT instance and retains all original directed checks, including System E/Evolution/EEPROM; its stale randomized differential phase is excluded. The exploratory failure is retained as `exploratory_stale_banking_oracle.log`, not counted as a passing run. Other existing regressions run directly against their production modules and refreshed current savestate controller model. Original historical reports/logs are preserved.

Generated HDL adapters are retained for review/reproduction; ModelSim libraries and waveforms are disposable and removed at completion. No Quartus build is needed or performed.
