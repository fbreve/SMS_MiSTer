OutputMemory MLAB isolated experiment — functional verification and Analysis & Synthesis, 2026-11-07–08

The candidate passes the exact functional campaign, the independent memory scoreboard, wrapper/transport regressions and targeted Intel vendor-model tests of the actual exported RAM/output-register cells. Quartus infers two replicated 19x10 MLAB memories. The candidate is ready for independent review before one controlled Seed 2 physical comparison. No fitter, assembler, timing analysis, RBF or hardware test was run.

Branch `experiment/ym2413-outputmemory-mlab` was created directly from `9873761503510e4b2c7e06600bf5515344235c2f`, in `tests/ym2413_outputmemory_mlab/worktree`. RegisterMemory is still the original logic implementation; neither its MLAB optimization nor any mixer omission is included. The sole production diff is:

```diff
-  attribute ramstyle of data_array : signal is "logic";
+  attribute ramstyle of data_array : signal is "MLAB";
```

The array remains declared 0 to 18, with ten bits per entry (sign plus nine-bit magnitude). Both registered read ports, the single write path, raw-clock behavior, initialization/reset, freeze, snapshot words 58–75 and pending OutputGenerator word 100 are unchanged. All 104 words and descriptor version 17 are preserved. No no_rw_check or other semantic waiver was added.

| Verification | Result |
|---|---|
| Independent RTL bank scoreboard | PASS: 33,075 cycles; 298,761 counted checks; all 19 entries |
| Bank collisions | 13,146 on read port 1; 1,004 on read port 2; 680 on both |
| Invalid/frozen write conditions | 6,027 exercised |
| Entry-18 read conditions | 4,874 exercised |
| Long full-core differential campaign | PASS: 72 slot/stage positions, two LOADs each, 144 completed LOADs |
| Raw-clock state/audio checkpoints | 888,916,572 |
| Follow-up for each long LOAD | 115.18686 ms, including subsequent musical writes |
| Captured pending writes in word 100 | 36 output writes; 18 feedback writes |
| Envelope states at SAVE | All four; nonzero feedback exercised in every phase |
| Independent state-map patterns | PASS: 832 words, eight complete 104-word patterns |
| Wrapper/transport protocol | PASS: 2,905,606 cycles; 9,508 DDR reads |
| Non-FM regression | PASS: eight restores per controller, all slots; 8,645,354 cycles |
| Supplementary short phase regression | PASS: all 72 offsets, three LOAD continuations each |
| Seven wrapper modes | PASS: ordinary FM, System E, BIOS addressing, rhythm, key-off, unfinished custom write, FM disabled; legacy handling also checked |
| Actual mapped-cell vendor probe | PASS: 86,467 cycles; 518,686 checks; zero errors/warnings |

The long campaign uses independently compiled baseline/candidate RTL libraries and the production FM wrapper. Both libraries have identical compatibility adapters and read-only observation instrumentation; they differ only in the requested attribute. Every enabled comparison is exact, with no self-healing allowance. It compares all 104 independently observed state words, delay counters, factory instruments, digital/audio-gated outputs, both OutputMemory read outputs, entry 18 and the FeedbackMemory read output. Persistent FeedbackMemory, operator, phase and envelope state are included. SAVE payloads are checked against independently packed live internals, rather than a second invocation of SAVE. Deliberate pre-LOAD evolution ensures restoration is meaningful. The independent bank scoreboard supplies expected memory contents, old-data samples, readiness and snapshot responses without using either implementation's serializer.

The bank test covers all 19x19 operational read-address pairs and all 19x19 pairs against every initialization write address. During normal operation the first read shares the write address by interface definition; initialization provides independent write/read/read addresses. It checks changes before the clock edge, registered results after the edge and stability afterward. Normal/snapshot collisions, opposite sign representations, magnitude extremes, negative zero, alternating patterns, random values, long raw-clock writes, frozen pending writes, invalid snapshot addresses and first raw unfreeze edges are exercised. The core test preserves the real 15-raw-clock enable pattern and includes a long CE-low interval immediately after LOAD. The supplementary wrapper tests exercise registered DDR reads, stalls/backpressure, the original native flush interval and the actual capture/apply/legacy transport FSM. Their shorter directed continuations are separate from, and not counted as, the 144 long follow-up LOADs.

Entry 18 is explicitly characterized: it is not cleared by the 0–17 initialization sequence and is outside snapshot words 58–75, but normal address 18 can read/write it. After a defined write, its value survives reset-driven initialization of the other entries. Before its first write it is unspecified in RTL; the bank test observes that rather than assuming initialization. Vendor tests only demand concrete values from locations once written. No attempt was made to remove, initialize or add snapshot coverage for this entry.

All 116 successful GHDL invocations were explicitly sampled at Windows Idle priority, with at most four concurrent simulations. Toolhelp process-tree checks also verified observed GHDL processes/children at Idle. No unrelated priorities or global scheduling settings were changed. Four earlier incomplete phase-36–39 attempts hit the original wall-clock watchdog while Windows was suspended. Their logs and Kernel-Power evidence are retained under `suspend_interruption_36_39`. Those attempts are not counted as passing. The same stimuli were rerun after changing only the test-launcher watchdog to bounded active time, excluding S3 sleep. No RTL assertion failed, and no comparison/assertion was removed or relaxed.

Quartus Analysis & Synthesis ran only after both functional gates passed. It used Prime Lite 17.0.2 Build 602, Cyclone V `5CSEBA6U23I7`, SMS/sys_top and the matched full-state project inputs. All 221 inputs were frozen and hashed. The only production-input difference from the archived full-state Seed 2 source set is OutputMemory's attribute; all compiled production/integration sources were checked against commit 98737615. The reference BUILD_DATE=261104 was deliberately retained for comparable inputs, although the actual run occurred November 8. Source lists confirm the real OutputMemory and `rtl/opll_snapshot.sv` were used, with no simulation instrumentation in synthesis.

| OutputMemory mapped resource | Logic reference | MLAB candidate | Delta |
|---|---:|---:|---:|
| Local combinational ALUTs | 191 | 38 | -153 |
| Local mapped logic registers | 216 | 26 | -190 |
| Output registers | 20 | 20 | unchanged |
| Logical storage | One 19x10 register array | Two coherent 19x10 MLAB replicas | Storage replicated |
| Useful MLAB bits | 0 | 380 | +380 |
| Inferred MLAB macros | 0 | 2 | +2 |

These are synthesis measurements, not fitted FPGA savings. Needed/placed ALMs, final register packing, physical MLAB placement/count, routing, WNS and TNS are unmeasured. Each generated RAM macro estimates one MLAB plus ten output registers; the two inferred macros do not yet constitute a placed physical measurement. No OutputMemory M10K is inferred. The whole-design mapped-register count is 34,752 versus the reference's 34,942. Physical resource/timing comparison is the next separately authorized step.

The inferred replicas are `data_array_rtl_0` and `data_array__dual_rtl_0`, each ALTDPRAM simple dual port, 19x10. Their writes are shared; the first read selects the operational or snapshot address, and the second read remains independently addressed. The generated macro has registered write inputs, unregistered read address/control and a ten-bit OUTCLOCK output register bank. Twenty output registers remain, plus six ordinary control registers (five initialization-counter bits and readiness). The 38 remaining ALUTs implement surrounding address/data arbitration, decoding and control. Both replicas include entry 18.

**The raw mixed-port mode is DONT_CARE, not native OLD_DATA.** This was not accepted merely because registers exist. A functional post-map netlist was exported with Quartus EDA Netlist Writer; no placement or timing flow was invoked. The actual OutputMemory module was retained as `synthesis/OutputMemory_mapped.v`. Inspection identifies 20 Cyclone V MLAB bit-slice cells and 20 actual DFFEAS output registers. All cells use the common raw clock, both replicas share exactly the same write address/enable/data connections, and the output registers use that clock with enable `!reset`, without an FM clock-enable or hold gate. Read addresses differ independently between replicas.

The vendor probe in `vendor/mapped_output_cut.v` retains the exported cell instance bodies, parameters and signal aliases unchanged. The cutpoints are the RAM write address/data/enable, the two read addresses and the output enable. It is not a handwritten replacement memory model. `vendor/extraction.json` records hashes, counts and connection checks. Intel's Cyclone V/ALNSIM and DFFEAS models execute those actual cells; a separate single-memory scoreboard supplies expected samples for both copies.

The probe exhaustively crosses all 19^3 write/read/read address combinations for six data patterns, with a subsequent read after each write. It reports 2,397 collisions on port 1, 2,395 on port 2, 145 on both simultaneously, 38,275 all-distinct write/read/read cases and 100 disabled-output cycles. It checks pre-write OLD_DATA at the clocked outputs, stability away from edges, coherent replicas, repeated raw writes and entry-18 retention across output reset/initialization sequences. This gives experimental support for the registered interface under the actual inferred DONT_CARE primitive arrangement rather than assuming it safe.

The probe is intentionally not a complete end-to-end post-map simulation: upstream address/write arbitration is cut at the documented memory inputs and is tested by the separate independent RTL scoreboard. Nor is it post-fit timing/SDF or physical validation. Fitter packing, physical setup/hold timing and eventual MiSTer behavior remain unvalidated. A controlled physical build must recheck that these registers/modes remain intact.

No new normalized Analysis & Synthesis warnings were found compared with the full-state reference. No new latch, multiple-driver, width, unsupported-memory or collision warning appeared. Other inferred memories, including PhaseMemory and the snapshot scratch RAM, retain their modes/shapes. Existing core power-up/connectivity diagnostics remain. EDA export separately emitted warning 21300 about the unchanged audio PLL's LOCKED/FBOUTCLK connection; this is outside OutputMemory and was not modified. ModelSim wrapper runs retain the Starter Edition design-size recommendation warning and existing aggregate-direction warnings; the actual mapped-cell probe has zero warnings/errors.

Exact provenance and evidence:

- Frozen synthesis-input aggregate SHA-256: `49345108d16d04378f73fb2b0d6a9b6955149dba20849c92c93b2656c1cca0d5` (sorted path/hash pairs).
- `source_manifest.json`: independent test-library/wrapper/bench hashes and production diff hash.
- `synthesis/inputs.json`: all production/configuration/tool hashes and original reference directory.
- `functional_results.json`: each of the 72 phases, long follow-up durations, pending-write coverage and raw checkpoint counts.
- `regression_results.json`: independent oracle, protocol, non-FM and wrapper-mode results with log hashes.
- `synthesis/results.json`: RAM parameter tables, hierarchy counts, generated primitive text/hashes and warning/memory comparisons.
- `vendor/extraction.json`, `vendor/mapped.log`: actual exported-cell connection proof and vendor-model assertions.
- `results.json`, `artifact_hashes.json`: consolidated outcome, tool identities and retained evidence hashes.

Native logs, bounded test sources/scripts, generated input libraries, the full 51 MB functional netlist, the extracted OutputMemory module and mapped-cell probe are retained. No fitter/STA/assembler reports or RBF were generated. Final preservation checks confirm master, sys, all previous worktree HEADs/tracked diffs/status and pinned source inputs are unchanged. No commits, merges, pushes or PRs were created.

Experimental test fixture changes/generated libraries belong only to this experiment. The eventual upstream production change remains the one-line attribute edit; experimental tests/build products must not enter that PR. RegisterMemory MLAB remains a separate preferred candidate awaiting its own manual hardware validation and is not included here.

Recommendation: ready for review before one controlled Seed 2 physical resource comparison. The functional and mapped-cell evidence supports measuring this candidate; it does not establish actual ALM/M10K/routing savings or timing closure. Do not combine candidates, rewrite the memory, start a fitter build or initiate hardware testing automatically.
