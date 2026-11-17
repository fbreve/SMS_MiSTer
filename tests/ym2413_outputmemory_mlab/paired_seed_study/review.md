# OutputMemory MLAB: three paired seeds

Baseline 9873761503510e4b2c7e06600bf5515344235c2f; unchanged attribute-only candidate. Quartus Prime Lite 17.0.2 Build 602, device 5CSEBA6U23I7, SMS/sys_top, exact matched assignments and SDC. Only QSF SEED differs between candidate builds. BUILD_DATE261104 intentionally retained. Native reference reports and archived hashes verified for all seeds. Production source hash: 1845f746d20bd6173bf76e2424d786ee5dab6acb58e7327570c74553ed0fc7c1. All 931 existing Seed 2 files are byte-identical to the pre-study snapshot. No reference or prior experiment worktree changes.

## Absolute measurements

| Seed / implementation | Needed ALMs | Placed ALMs | Registers | M10K | MLAB blocks / cells | Average / peak routing | Setup WNS ns | Setup TNS ns | Timing |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---|
| 1 / baseline | 27438 | 32465 | 36049 | 489 | 0 / 0 | 31.2% / 48.6% | -0.173 | -3.970 | FAIL |
| 1 / candidate | 27091 | 31963 | 35825 | 489 | 2 / 20 | 31% / 52.7% | +0.755 | 0 | PASS |
| 2 / baseline | 27421 | 32490 | 36112 | 489 | 0 / 0 | 31.5% / 51% | +0.367 | 0 | PASS |
| 2 / candidate | 27144 | 32057 | 35758 | 489 | 2 / 20 | 31.1% / 53% | +0.646 | 0 | PASS |
| 3 / baseline | 27445 | 32453 | 36044 | 489 | 0 / 0 | 31.8% / 53.3% | +0.002 | 0 | PASS |
| 3 / candidate | 27143 | 32221 | 35835 | 489 | 2 / 20 | 31% / 51.4% | +0.531 | 0 | PASS |

## Paired deltas and statistics

| Seed | Needed ALMs | Placed ALMs | Registers | M10K | Setup WNS ns | Setup TNS ns |
|---|---:|---:|---:|---:|---:|---:|
| 1 | -347 | -502 | -224 | 0 | +0.928 | +3.970 |
| 2 | -277 | -433 | -354 | 0 | +0.279 | 0 |
| 3 | -302 | -232 | -209 | 0 | +0.529 | 0 |

| Metric | Baseline mean [min, max] | Candidate mean [min, max] | Paired delta mean [min, max] |
|---|---:|---:|---:|
| neededALMs | 27434.667 [27421, 27445] | 27126 [27091, 27144] | -308.667 [-347, -277] |
| placedALMs | 32469.333 [32453, 32490] | 32080.333 [31963, 32221] | -389 [-502, -232] |
| fittedRegisters | 36068.333 [36044, 36112] | 35806 [35758, 35835] | -262.333 [-354, -209] |
| M10K | 489 [489, 489] | 489 [489, 489] | 0 [0, 0] |
| MLABcells | 0 [0, 0] | 20 [20, 20] | 20 [20, 20] |
| physicalMLABs | 0 [0, 0] | 2 [2, 2] | 2 [2, 2] |
| averageRouting | 31.500 [31.200, 31.800] | 31.033 [31, 31.100] | -0.467 [-0.800, -0.200] |
| peakRouting | 50.967 [48.600, 53.300] | 52.367 [51.400, 53] | 1.400 [-1.900, 4.100] |
| setupSlack | 0.065 [-0.173, 0.367] | 0.644 [0.531, 0.755] | 0.579 [0.279, 0.928] |
| setupTNS | -1.323 [-3.970, 0] | 0 [0, 0] | 1.323 [0, 3.970] |
| holdSlack | 0.194 [0.168, 0.244] | 0.233 [0.213, 0.245] | 0.039 [-0.003, 0.075] |
| holdTNS | 0 [0, 0] | 0 [0, 0] | 0 [0, 0] |

Candidate timing passes 3/3 seeds; reference passes 2/3. Each absolute result governs readiness; averages do not excuse failures. Existing external/unconstrained path qualifications remain.

## Structure, warnings and critical paths

Seed 1: two 19x10 MLAB replicas, 20 cells, 20 packed clocked read-output bits, common write signals and independent read addresses. Locations: X78_Y24, X78_Y26. Raw mixed-port behavior DONT_CARE. Same memory dimensions, primitive parameters, output-register packing and shared-write/independent-read topology; placement and decoder/net names may differ.

Worst setup +0.755ns: ascal:ascal|o_hacc[2] -> ascal:ascal|o_dir[0][10]; clock pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk. Hold WNS +0.213ns / TNS 0. OutputMemory targeted from/to: 6.681 / 8.596ns.

Compilation warnings: 67 unique / 38 critical; normalized added=0, removed=1. Added: []; removed: ["Critical Warning (332148): Timing requirements not met"]. No newly introduced inferred latches, multiple drivers or width warnings unless explicitly listed in individual results.

Seed 2: two 19x10 MLAB replicas, 20 cells, 20 packed clocked read-output bits, common write signals and independent read addresses. Locations: X72_Y12, X72_Y14. Raw mixed-port behavior DONT_CARE. Previously tested Seed 2 structure retained.

Worst setup +0.646ns: ascal:ascal|o_vpix_inner[1].g[6] -> ascal:ascal|o_poly_lum[7]_OTERM221_OTERM1164; clock pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk. Hold WNS +0.241ns / TNS 0. OutputMemory targeted from/to: 6.904 / 8.884ns.

Compilation warnings: 67 unique / 38 critical; normalized added=0, removed=0. Added: []; removed: []. No newly introduced inferred latches, multiple drivers or width warnings unless explicitly listed in individual results.

Seed 3: two 19x10 MLAB replicas, 20 cells, 20 packed clocked read-output bits, common write signals and independent read addresses. Locations: X78_Y22, X78_Y23. Raw mixed-port behavior DONT_CARE. Same memory dimensions, primitive parameters, output-register packing and shared-write/independent-read topology; placement and decoder/net names may differ.

Worst setup +0.531ns: ascal:ascal|o_vpix_inner[1].g[7] -> ascal:ascal|o_poly_lum[7]_OTERM221_OTERM1164; clock pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk. Hold WNS +0.245ns / TNS 0. OutputMemory targeted from/to: 7.366 / 8.131ns.

Compilation warnings: 67 unique / 38 critical; normalized added=0, removed=0. Added: []; removed: []. No newly introduced inferred latches, multiple drivers or width warnings unless explicitly listed in individual results.

Both new seeds were checked in the compiled fitted atom database and exported functional netlist. Primitive parameter organization and output packing match Seed 2; only placement/decoder/net identifiers differ. No extra read pipeline stage appears. Other fitted memory organizations/modes remain unchanged; RegisterMemory remains logic, PhaseMemory remains its M10K implementation, snapshot scratch remains M10K. Full per-entity counts and normalized memory comparisons are retained in each results.json.

Quartus only exports a functional simulation netlist for this device (warning10905); this is structural evidence, not a post-route delay simulation. Auxiliary export activity updates SMS.flow.rpt; native map/fit/asm/sta reports remain unchanged. Before/after flow-report hashes are recorded. Seed 2 auxiliary-export limitations and vendor-model evidence remain preserved unchanged.

**Collision uncertainty:** DONT_CARE primitives do not guarantee silicon OLD_DATA. The prior vendor-model pass and identical fitted topology do not remove that uncertainty. OutputMemory feeds FeedbackMemory, so no self-healing allowance applies. Physical validation must compare exact audible/savestate continuation against the full-state reference, with nonzero feedback, simultaneous collisions, pending writes/unfreeze, repeated SAVE/LOAD, key transitions, rhythm and custom instruments.

## Artifacts and recommendation

Seed 1: source/configuration SHA256 030097fe3eecfe6d8d8182f0538ec29c250425233765d49b09812c07f895fafb; timing-qualified hardware-test candidate SMS_YM2413_OUTPUTMEM_MLAB_104W_v17_98737615_src030097fe3eec_Q17.0.2_seed1_TIMING_PASS_15bde5089ac5.rbf; SHA256 15bde5089ac5cdc83f84634a71fc6da403e7b7fdc6995317c5996a93a55b1f5e.

Seed 2: source/configuration SHA256 49345108d16d04378f73fb2b0d6a9b6955149dba20849c92c93b2656c1cca0d5; timing-qualified hardware-test candidate SMS_YM2413_OUTPUTMEM_MLAB_104W_v17_98737615_src49345108d16d_Q17.0.2_seed2_TIMING_PASS_60a5ccb2ff8f.rbf; SHA256 60a5ccb2ff8fe9d642bc20abf7efcb98b1bc78f9244a2fdb086580f771451c2b.

Seed 3: source/configuration SHA256 c69e56f270a017af74813d79ae2bc9a870be1a149e7e624961271b2610fab3a8; timing-qualified hardware-test candidate SMS_YM2413_OUTPUTMEM_MLAB_104W_v17_98737615_srcc69e56f270a0_Q17.0.2_seed3_TIMING_PASS_0fcf788dfc4d.rbf; SHA256 0fcf788dfc4d3a85d9bb5dcf6306d238c12e9bd519bf44987b1d3d0fc4848f38.

Detailed native reports, paths, synthesis/fitter hierarchy and warning review are in ../physical_seedN/. inputs.json pins all sources/settings/tools; production.diff confirms attribute-only scope. Fitted_output_packing.txt, fitted_atoms.tsv and OutputMemory_fitted_functional.v capture memory evidence for new seeds. artifact_hashes.json covers retained reports, provenance, inspection scripts and RBFs; source inputs are separately hash-pinned. Experimental tests/artifacts must not be included in an eventual production-only upstream PR.

Recommendation: ready to nominate a timing-passing RBF for controlled manual MiSTer validation, subject to independent review and the explicit collision uncertainty. Seed 2 remains a suitable first choice (+0.646ns and targeted vendor-model evidence). This is not integration approval or a claim of hardware correctness.

Only Seeds 1 and 3 newly compiled. No source change, additional seed, GHDL, hardware test or Git mutation.
