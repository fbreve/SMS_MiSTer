# PhaseMemory AUTO experiment reproduction

Baseline commit: `8443a0d19a88aff7a5900011bccf386daf146945`. Experimental branch: `experiment/phasememory-auto-inference`.

Only the specification `attribute ramstyle of phase_array : signal is "logic";` is removed. The attribute declaration, storage declaration, processes, reset, initialization and ports are unchanged. Source files in `baseline/` and `candidate/` are exact Git blobs except that one line. Generated `build_id.v` is fixed at261014 in both. Do not regenerate a new date between A and B.

Preparation (once, from repository root):

```powershell
node tests/phase_memory_auto/prepare.js
```

This script refuses to overwrite an existing build pair. Its manifest hashes all203 tracked source-tree blobs. The unused MiST submodule is not needed for the SMS/sys_top project; all required sources are present and synthesis checks the actual project dependencies.

Simulation (from this directory), using ModelSim-Intel FPGA Starter10.5b bundled with Quartus17.0.2:

```powershell
vsim -c -do bank.do -l bank.log
node prepare_sim.js
vsim -c -do fm.do -l fm.log
node prepare_gate.js
powershell -NoProfile -ExecutionPolicy Bypass -File gate_build.ps1
node -e "const fs=require('fs');fs.writeFileSync('PhaseMemory_gate.vo',fs.readFileSync('gate_candidate/netlist/PhaseMemory.vo','utf8').replace('module PhaseMemory (','module PhaseMemory_gate ('));"
vsim -c -do gate.do -l gate.log
node prepare_mapped_sim.js
vsim -c -do fm_gate.do -l fm_gate.log
node prepare_savestate.js
vsim -c -do savestate.do -l savestate.log
node prepare_savestate_gate.js
$env:GATE_REFERENCE='1'
vsim -c -do savestate_gate.do -l savestate_gate_reference.log
$env:GATE_REFERENCE='0'
vsim -c -do savestate_gate.do -l savestate_gate.log
```

Bank tests compile production sources without adapters, in VHDL93. Full OPLL simulation expands scalar subtype`'range` to identical`'low to 'high` bounds for ModelSim portability and supplies missing`when others => null` branches for std_logic meta values. Legal binary cases are unchanged. The controller's two forward-referenced snapshot declarations are moved before their uses, and module names are changed to permit paired instances. None of these simulation-only copies is used by Quartus. All adapters are applied identically to A and B. They follow the portability issues already encountered by prior audits; they are not fixes to production RTL.

The gate test uses the **exported standalone synthesis functional netlist**, not a hand-written RAM behavioral substitute. Only its top module is renamed. `altera_lnsim_ver`, `altera_ver` and other bundled model libraries must resolve through the installed ModelSim configuration. This validates defined behavior of the chosen mapping; it is not post-route timing simulation. Unknown baseline startup payload is not required to match a particular hardware power-up value. Every baseline-defined value is checked. The RTL bank test separately preserves and checks U values exactly.

The full mapped FM simulation replaces only PhaseMemory in a separate`mapped_work` library. Both complete OPLL instances receive the same stimuli. The eight-case RTL savestate test compares all58 controller outputs, accepted DDR transactions, restored CPU/VDP/PSG data and OPLL samples over actual freeze intervals. The mapped savestate test uses two representatives (SMS/cartridge/slot0, SystemE/BIOS/slot3 with DDR stalls) and explicitly programs nonzero FM audio. To avoid ModelSim Starter's10k-statement performance limit, it uses one real controller and one OPLL per pass: REF1 records every native audio sample; REF0 checks the mapped OPLL against that stream under identical deterministic stimuli and actual controller freeze behavior. The separate eight-case RTL test supplies the paired-controller comparison. The full controller's900,000-cycle load flush is retained; only the UI operation cooldown is forced to zero symmetrically between requests. The testbench watchdog is200ms. Preliminary runs exposed fixture defects: the original busy pattern permitted only18 idle clocks, preventing the required32-clock drain, and the initial mock DDR array omitted BIOS slots. The final fixture provides92 idle clocks per97-clock stall period and includes both cartridge and BIOS slot regions. Initial timeout/interrupted diagnostic logs are retained and are not passes. Per-case restore-count assertions catch rejected loads immediately. An initial oracle self-check also needed a testbench delta-cycle correction: it now compares the variable read from the stream directly, rather than its not-yet-updated continuous-assignment alias.

Fresh whole-design builds (from repository root):

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/phase_memory_auto/build.ps1
node tests/phase_memory_auto/measure.js
powershell -NoProfile -ExecutionPolicy Bypass -File tests/phase_memory_auto/query_register_paths.ps1
node tests/phase_memory_auto/collect_paths.js
node tests/phase_memory_auto/write_report.js
```

The build script refuses existing attempts and other active whole-design compilers. It creates a temporary local Z: mapping to shorten paths, runs A then B in order with map/fit/asm/sta, and removes its mapping on exit. The standalone gate export uses a separate temporary Y: mapping. Existing mappings are never replaced. ExecutionPolicy Bypass affects only these child processes, not the machine policy.

Direct stages bypass only the date-generating preflow; original QSF/QIP/SDC, device5CSEBA6U23I7, SMS/sys_top, seed1, performance/packing settings and processor setting remain identical. Both builds start without databases. Outputs/databases are ignored and must not be staged. Use new directories for a rerun rather than deleting or overwriting the retained evidence. Final analysis verifies input hashes and protected branch refs and compares global resources, per-clock timing/TNS, PhaseMemory allocation, warnings and routing. Retained timing-history F is a reproducibility reference, not the experimental A endpoint.

The original supplemental`query_paths.ps1` uses get_keepers and crashes on the candidate after exporting its global setup/hold paths. Its diagnostic log is retained. The successful register-only query is the recommended local-path reproduction. Neither query is a full rebuild or a substitute for the compiled STA summaries. `path_results.json` records the endpoints and slacks extracted from those reports. `functional_results.json`, `tools.json` and compressed`savestate_oracle.trace.gz` retain simulation/tool provenance.
