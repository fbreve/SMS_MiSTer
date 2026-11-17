# OutputMemory MLAB � controlled Seed 2 physical measurement

Completed 2026-11-08. Quartus map, fit, asm and sta all returned zero. Candidate merits an independently authorized paired multi-seed assessment. Collision behavior in silicon remains a separate validation gate; no hardware functionality is claimed.

## Scope and provenance

Baseline commit: `9873761503510e4b2c7e06600bf5515344235c2f`. Branch: `experiment/ym2413-outputmemory-mlab`. Worktree: `../worktree`. Only production diff: `rtl/VM2413/outputmemory.vhd`, `attribute ramstyle of data_array : signal is "logic";` ? `"MLAB"`. RegisterMemory remains logic; both mixer restore assignments remain present. All 104 words and version 17 preserved. Existing test fixture changes were not included as production sources.

Quartus Prime Lite 17.0.2 Build 602; Cyclone V `5CSEBA6U23I7`; project/revision SMS; top sys_top; Seed 2. All 221 frozen build inputs match the previously approved synthesis manifest. Aggregate source SHA-256: `49345108d16d04378f73fb2b0d6a9b6955149dba20849c92c93b2656c1cca0d5`. Original full-state source archive was checked against the committed production baseline; tool executable hashes and original reports were verified. BUILD_DATE remains `261104` for matched configuration, despite actual compilation on Nov 8. Expanded assignments and fitter settings compare identically to the full-state Seed 2 reference. SDC/configuration files are hash-pinned in inputs.json. Source parsing confirms OutputMemory and opll_snapshot.sv are included.

Original authoritative reference: `../../ym2413_v19_fullstate/physical_seed2/candidate/output_files/`. Its native fit/sta reports were read and original report hashes validated, rather than relying on the supplied figures alone.

## Measured results

| Metric | Full-state Seed 2 | OutputMemory MLAB Seed 2 | Delta |
|---|---:|---:|---:|
| neededALMs | 27421 | 27144 | -277 |
| placedALMs | 32490 | 32057 | -433 |
| fittedRegisters | 36112 | 35758 | -354 |
| mappedRegisters | 34942 | 34752 | -190 |
| M10K | 489 | 489 | 0 |
| MLABcells | 0 | 20 | +20 |
| MLABbits | 0 | 380 | +380 |
| memoryALMs | 0 | 20 | +20 |
| logicALUTs | 38348 | 38012 | -336 |
| routingALUTs | 13115 | 13061 | -54 |
| setupSlack | 0.367 | 0.646 | +0.279 |
| setupTNS | 0 | 0 | 0 |
| holdSlack | 0.244 | 0.241 | -0.003 |
| holdTNS | 0 | 0 | 0 |
| Physical MLAB blocks | 0 | 2 | +2 |
| Average interconnect usage | 31.5% | 31.1% | -0.4 percentage points |
| Peak interconnect usage | 51.0% | 53.0% | +2.0 percentage points |

Block memory bits remain 3,818,374 and DSP blocks remain 39. The 380 logical MLAB bits are additional distributed-memory bits, not extra M10K allocation. Whole-core fitted deltas include physical optimization and placement effects; they are not all attributable to the local hierarchy.

## Fitted memory structure and collision qualification

Two 19�10 simple-dual-port MLAB replicas survive fitting: LAB_X72_Y12_N0 and LAB_X72_Y14_N0, ten MLAB cells each. Entry 18 remains in both. Native fitter RAM rows report single-clock operation, registered write inputs, unregistered read addresses and registered read outputs. All 20 original read DFFEAS are packed into MLAB port-B output registers; no additional pipeline stage is introduced. The exported primitives explicitly set `port_b_data_out_clock="clock1"`; clk0 and clk1 both connect to the same raw emu PLL clock, with ena1=!reset. Write enable is unchanged. Long clkena gaps do not gate the raw memory clock.

The read-only compiled (`cmp`) atom query independently confirms all 20 fitted LUTRAM locations, identical write-clock/write-enable/write-address fanins across both copies, matching write-data fanins bit by bit, and distinct five-bit read-address vectors. See fitted_atoms.tsv, fitted_output_packing.txt and results.json. The functional export is not byte-identical to the earlier pre-fit export: output-register packing and decoder optimization are visible and documented, rather than assumed away.

Both raw replicas still specify `mixed_port_feed_through_mode="dont care"`. The native fitter collision columns are blank; they do not assert OLD_DATA. A supplementary ModelSim vendor-model test extracted the actual post-fit functional-export cells, including their packed output registers and unchanged defparams: 86,467 cycles / 518,686 independent expected-value checks PASS, collision counts port0=2,397, port1=2,395, both=145, distinct=38,275, held=100, zero final warnings/errors. The initial cut-generation syntax error was corrected only in new measurement artifacts and retained separately; it was not an RTL mismatch.

These functional vendor-model results are NOT an unconditional silicon OLD_DATA guarantee. OutputMemory feeds feedback, so exact behavior is mandatory and self-healing is not acceptable. Physical validation must exercise collisions, nonzero feedback, savestates/pending writes and repeated LOADs, with comparison to the full-state reference. A timing pass qualifies the RBF for controlled evaluation, not integration approval.

## Hierarchy and other memories

OutputMemory mapped ALUTs: 191?38; mapped logic registers: 216?26 (20 subsequently packed, six local control). Fitted hierarchy: ALUTs 190?38; dedicated logic registers 219?9; needed ALMs 150.4?41.1 inclusive of 20 memory ALMs; placed 192.0?41.6. Packing affects how output registers are counted; they remain architecturally present.

No other normalized fitted RAM organization/mode differs after excluding OutputMemory and physical locations. PhaseMemory retains its 18�18 M10K with OLD_DATA; snapshot scratch retains its 256�32 M10K; RegisterMemory remains logic (mapped121ALUT/225FF; fitted121ALUT/229FF versus228FF reference). PhaseMemory map48?49ALUT, fit9?10FF; snapshot map213?217ALUT, fit162?166FF. These local logic/replication differences are visible in the hierarchy evidence; no inference regression or RAM mode change was found.

## Timing and warnings

All reported setup/hold/recovery/removal/minimum-pulse groups pass. Setup WNS +0.646ns, TNS0; hold WNS +0.241ns, TNS0. Worst setup remains HDMI scaler: `ascal|o_vpix_inner[1].g[6]` ? `ascal|o_poly_lum[7]_OTERM221_OTERM1164`, data delay5.392ns, skew-0.494ns. This is a different scaler path from the reference but no new timing violation. Targeted FM paths are positive: from FM +4.678ns, to FM +1.852ns; OutputMemory from +6.904ns, to +8.884ns. Detailed paths retained in candidate/physical_*.rpt.

Normalized compilation warning set is identical to reference:67 unique warnings, including38 pre-existing critical warnings. No inferred-latch, multiple-driver, width-mismatch or new memory-inference warning was found. Existing power-up/connectivity and incomplete/unconstrained external-path qualifications remain; positive constrained timing is not a claim that every external path is constrained.

Export limitations: Quartus EDA warning10905 says only a functional simulation netlist is supported for this device, even when functional=off is requested. The successful export reflects packed output primitives but carries no post-route delay simulation guarantee. A separate read-only fitted-atom Verilog exporter failed internally in A2V on an unsupported atom; its partial file is explicitly named INCOMPLETE_NOT_VALID and excluded from proof. Successful cmp connectivity queries, native fitter reports and the functional export agree on the memory structure. No recompile or source change was made. Native map/fit/asm/sta reports stayed hash-identical after inspection; only SMS.flow.rpt was updated by Quartus auxiliary export/query activity, with before/after hashes recorded.

## Preserved artifacts and recommendation

RBF: `SMS_YM2413_OUTPUTMEM_MLAB_104W_v17_98737615_src49345108d16d_Q17.0.2_seed2_TIMING_PASS_60a5ccb2ff8f.rbf` (4137224 bytes). SHA-256: `60a5ccb2ff8fe9d642bc20abf7efcb98b1bc78f9244a2fdb086580f771451c2b`.

Inputs/configuration/tool hashes: inputs.json. Exact production diff: production.diff. Native reports: candidate/output_files/. Detailed numerical, hierarchy, warning, connectivity and provenance evidence: results.json. Actual OutputMemory functional export: OutputMemory_functional_export.v. Supplemental vendor-model evidence: vendor_fitted/. Build stage timestamps: workflow.log. artifact_hashes.json hashes reports, scripts, provenance and retained RBF; source files are separately hash-pinned in inputs.json.

Recommend paired Seeds1and3 assessment if separately authorized: this seed shows meaningful resource reduction without M10K increase and acceptable timing. Do not infer robustness from one seed. Collision uncertainty remains a hardware-validation gate and this candidate remains experimental. RegisterMemory MLAB is not included. No hardware testing, extra seed, GHDL, production edit, commit, merge, push or PR was performed. Master, sys, reference and prior experiment worktrees remain unchanged. Any eventual upstream PR must contain approved production changes only, not these experimental tests/artifacts.
