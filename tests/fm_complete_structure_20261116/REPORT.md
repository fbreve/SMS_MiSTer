# Complete-state FM structural optimization

**NO-GO for adopting the tested counter refactor; retain complete reference restoration.** Functional equivalence passed, and a real small mapped-logic reduction was found. Needed ALMs fell in all seeds, but placed ALMs changed -147/+117/+26 (mean -1.33), worst setup margin decreased in every seed, and mapped registers/M10K/DSP did not decrease. The small local saving does not establish a worthwhile physical or overall maintenance simplification.

## Scope and reference

Experimental branch `experiment/fm-complete-slot-adder-20261116`, based on exact `8cd53ccc954c24970372ea6d8a3fb2336a14c46f`. Only production change: slotcounter restore arithmetic. All 100 words, descriptor, validation, compatibility, restoration latency, transport and legacy behavior remain intact. No reduced-state restoration was introduced. Main checkout stays at qualified Ys correction ff70cb70; master, sys, historical evidence and qualified RBFs are unchanged. No commits, pushes, merges or publication. Candidate.patch and the worktree retain the independently reviewable trial, not an adopted implementation.

The existing 100-word reference already omits temporal mixer state. The earlier 43 reduction pilots covered only ~0.336 ms and qualified no further omission. This study makes no claim about their behavior at 1-2 seconds.

## Cost attribution and candidates

The actual original fitter hierarchy was audited before editing RTL. See [COST_AUDIT.md](COST_AUDIT.md) and hierarchy.json for all three seeds, inclusive and exclusive values. Seed1 attribution: OPLL +490.8 inclusive ALMs, of which envelope +203.5 and controller +168.2; savestate hierarchy +286.2 including the separately measured 152-ALM/167-register/one-M10K snapshot transport. Parent and child totals are not added. Hierarchy changes mix access overhead with inference/packing changes; they do not measure the exact removable cost of each mux.

| Rank | Structural opportunity | Evidence and decision |
|---|---|---|
| 1 | Consolidate envelope/controller scalar response selection | Largest measured access-related increases; potential savings remain estimates. Process-local variables, synchronous RAMs and pre-write read semantics make indiscriminate register movement unsafe. Not implemented in this study. |
| 2 | Simplify savestate validation/control and transport staging | Snapshot and own-parent attribution measurable; validator versus unrelated parent logic is not separately measured. Earlier low-word write to remove staging rejected because it can alter interrupted/reset-visible memory behavior. |
| 3 | Factor delayed-counter restore into one bounded addition | Implemented and functionally qualified; physical result below. |
| 4 | Replace snapshot high-half index increment with a low-bit selection | Invariant: bulk index is even in those states. Small estimated opportunity; synthesis may already eliminate the carry chain. Not implemented. |
| 5 | Simplify temporary packing / narrow integer decoders | May be a text-only change after synthesis; no unmeasured ALM benefit claimed. |

The trial selects a seven-bit constant before a seven-bit addition instead of selecting between two arithmetic expressions. It preserves every seven-bit bus value, not just 0..71. See CANDIDATE.md for the local equivalence argument and limitations.

## Functional results

| Check | Result |
|---|---|
| Existing focused compile/protocol/guard/map/non-FM/validator/live suites | 8 successful cases |
| Independent pattern oracle | 8 images of 100 words; direct RAM/signal/process-variable packing |
| Exhaustive actual delayed counters | 128 inputs x4 delays; all 256 addresses; read/write/hold/run/reset equivalence |
| Main end-to-end test, production 900,000-clock flush | 3 captures, 3 complete restores, 1 legacy load, 9 independent oracle checkpoints;374207 continuation checks |
| Additional mode/phase cases | 12 successful cases; existing 90-clock flush adapter, NCONT=5000; not native transfer-time evidence |
| Strict simultaneous full-reference comparison | 72 repeated SAVE/LOAD pairs;442502 checked host clocks; raw/clamped audio and capture/restored readback exact; no post-LOAD exclusion window; unknown-audio assertion passed |
| Strict independent internal oracle | Capture,restored candidate,restored reference and continuation packing checked for each pair |
| Interrupted-load/format regression | Malformed format no live writes; late DDR timeout retains reference partial-VRAM behavior,CPU/FM not applied |

Mode0 is normal FM,1 SystemE,2 BIOS slot,3 rhythm,4 key-off,5 unfinished custom-voice write,6 disabled audible output. Extra capture offsets1,2,3 are tested in normal and rhythm cases. The strict run reports 48 distinct captured counter positions; it does not claim an exhaustive 72-position integration sweep. The separate local counter test exhausts the arithmetic domain.

No new game replay or real MiSTer hardware audio qualification is claimed. Here the correctness criterion is exact behavior versus the complete reference, supported by internal state, exhaustive local equivalence and continuation checks, not assumed acoustic settling. The qualified hardware implementation remains the reference. The legacy/timeout tests preserve existing behavior; this patch does not make SAVE/LOAD atomic or integrate the later Ys correction into the older reference.

## Matched Quartus Prime Lite 17.0.2 seed1 measurement

Cyclone V 5CSEBA6U23I7, seed 1, fixed BUILD_DATE `261114`, identical QSF/QIP/SDC/IP/dependency inputs. The exact existing full-reference seed1 build is reused after verifying its original input and report hashes and tool version. This is a fresh candidate against a verified historical reference, not two fresh compilations. Only slotcounter.vhd differs in the candidate build export. See physical/baseline_reuse.json,candidate_inputs.json,measurements.json and original reports.

| Metric | Full reference | Candidate | Delta |
|---|---:|---:|---:|
| Needed ALMs | 27297 | 27209 | -88 |
| Placed ALMs | 32221 | 32074 | -147 |
| Mapped registers | 34731 | 34731 | 0 |
| Fitted registers | 35724 | 35682 | -42 |
| Logic ALUTs | 38274 | 38288 | +14 |
| Routing ALUTs | 13075 | 12948 | -127 |
| M10K | 489 | 489 | 0 |
| Logical block-memory bits | 3818374 | 3818374 | 0 |
| DSP | 39 | 39 | 0 |
| Worst constrained setup ns | 0.582 | 0.187 | -0.395 |
| Worst constrained hold ns | 0.243 | 0.243 | 0 |
| Setup TNS ns | 0 | 0 | 0 |
| Hold TNS ns | 0 | 0 | 0 |

| Counter | Reference needed ALMs | Candidate needed ALMs | Delta |
|---|---:|---:|---:|
| SlotCounter:s0 | 13.2 | 13.2 | 0 |
| SlotCounter:s2 | 14.3 | 11.1 | -3.2 |
| SlotCounter:s5 | 20.8 | 12.5 | -8.3 |
| SlotCounter:s8 | 11.1 | 10.8 | -0.3 |

Modified counter hierarchy delta: -11.8 needed ALMs. A whole-device delta alone is not treated as isolated counter savings.

| Clock / analysis | Reference slack ns | Candidate slack ns | Candidate TNS ns |
|---|---:|---:|---:|
| Setup 'pll_hdmi / pll_hdmi_inst / altera_pll_i / cyclonev_pll / counter[0].output_counter / divclk' | 0.582 | 0.187 | 0 |
| Setup 'emu / pll / pll_inst / altera_pll_i / cyclonev_pll / counter[0].output_counter / divclk' | 0.907 | 0.855 | 0 |
| Setup 'sysmem / fpga_interfaces / clocks_resets / h2f_user0_clk' | 4.114 | 4.203 | 0 |
| Setup 'spi_sck' | 5.836 | 5.921 | 0 |
| Setup 'FPGA_CLK2_50' | 6.208 | 5.979 | 0 |
| Setup 'FPGA_CLK1_50' | 8.252 | 8.442 | 0 |
| Setup 'pll_audio / pll_audio_inst / altera_pll_i / general[0].gpll~PLL_OUTPUT_COUNTER / divclk' | 15.038 | 14.275 | 0 |
| Hold 'emu / pll / pll_inst / altera_pll_i / cyclonev_pll / counter[0].output_counter / divclk' | 0.243 | 0.243 | 0 |
| Hold 'pll_hdmi / pll_hdmi_inst / altera_pll_i / cyclonev_pll / counter[0].output_counter / divclk' | 0.26 | 0.254 | 0 |
| Hold 'FPGA_CLK1_50' | 0.301 | 0.271 | 0 |
| Hold 'pll_audio / pll_audio_inst / altera_pll_i / general[0].gpll~PLL_OUTPUT_COUNTER / divclk' | 0.264 | 0.277 | 0 |
| Hold 'sysmem / fpga_interfaces / clocks_resets / h2f_user0_clk' | 0.299 | 0.307 | 0 |
| Hold 'FPGA_CLK2_50' | 0.417 | 0.422 | 0 |
| Hold 'spi_sck' | 0.352 | 0.453 | 0 |

Seeds2/3 were performed because seed1 showed a genuine local saving and lower whole-device area. Their mixed placement results do not support adopting the trial. This is not proof that larger lossless optimizations are impossible. Neither removal of the transport M10K nor register savings is inferred from shorter RTL. The 256x32 snapshot transport remains intact. Constrained timing does not cover existing unconstrained I/O; unconstrained summaries and critical warnings are retained with the measurements.

## Review and reproduction

COST_AUDIT.md records measured attribution versus estimates; CANDIDATE.md explains semantics; candidate.patch is the production diff. functional_summary.json and per-run logs retain test evidence. physical/ contains the build manifest,status,original reports and measurements. preservation_after.json verifies protected files and qualified RBF hashes. encoding_note.json records a nonfunctional comment-encoding correction after the initial export; physical build inputs remain frozen exactly as hashed. No functional RTL changed after the candidate simulations/build export.

Preparation scripts refuse overwriting key evidence. Reproduce in a new directory with the same exact-reference worktree and existing fixture/tool paths. Do not rerun over historical outputs. The initial wrapper-debug/concatenation compile failures and wrong-directory launches are retained as preparation diagnostics; successful corrected runs are the functional evidence.

## Three-seed comparison

Seeds2/3 were expanded only after the seed1 local and device reductions. All three candidates use the same frozen functional RTL and per-seed matched settings. See physical/extra_baseline_reuse.json for verified seed2/3 reference inputs/reports.

| Metric | B1 | C1 | B2 | C2 | B3 | C3 |
|---|---:|---:|---:|---:|---:|---:|
| Needed ALMs | 27297 | 27209 | 27261 | 27226 | 27341 | 27201 |
| Placed ALMs | 32221 | 32074 | 32136 | 32253 | 32151 | 32177 |
| Mapped registers | 34731 | 34731 | 34731 | 34731 | 34731 | 34731 |
| Fitted registers | 35724 | 35682 | 35781 | 35859 | 35791 | 35791 |
| Logic ALUTs | 38274 | 38288 | 38272 | 38284 | 38268 | 38285 |
| Routing ALUTs | 13075 | 12948 | 12796 | 13052 | 12959 | 12773 |
| M10K | 489 | 489 | 489 | 489 | 489 | 489 |
| Block-memory bits | 3818374 | 3818374 | 3818374 | 3818374 | 3818374 | 3818374 |
| DSP | 39 | 39 | 39 | 39 | 39 | 39 |

| Seed | Variant | Worst setup ns | Worst hold ns | Setup TNS | Hold TNS | Core setup ns |
|---|---|---:|---:|---:|---:|---:|
| 1 | Reference | 0.582 | 0.243 | 0 | 0 | 0.907 |
| 1 | Candidate | 0.187 | 0.243 | 0 | 0 | 0.855 |
| 2 | Reference | 0.453 | 0.151 | 0 | 0 | 1.224 |
| 2 | Candidate | 0.423 | 0.191 | 0 | 0 | 1.048 |
| 3 | Reference | 0.516 | 0.237 | 0 | 0 | 1.088 |
| 3 | Candidate | 0.406 | 0.221 | 0 | 0 | 1.374 |

All per-clock setup/hold rows are in [physical/per_clock_timing.csv](physical/per_clock_timing.csv). Local counter needed-ALM deltas by seed: seed1 -11.8, seed2 -12.6, seed3 -10.6. Mapping evidence independently shows thirteen fewer combinational ALUTs and unchanged mapped counter registers in seed1; whole-device placement changes cannot all be attributed to this local logic reduction.
