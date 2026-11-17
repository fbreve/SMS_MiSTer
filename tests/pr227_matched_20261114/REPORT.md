# PR #227: matched Quartus comparison

Baseline: `66f16d5c656fd8906d62570da4d258875bcee684`. Candidate: `8cd53ccc954c24970372ea6d8a3fb2336a14c46f`.

Quartus Prime Lite 17.0.2 Build 602; Cyclone V 5CSEBA6U23I7; fixed BUILD_DATE `261114`. Fresh isolated exports from Git, including submodule `mist/mist-modules` at `9bf1ea25deffe35159cec8762a4f689c1db74a8b`. Original source QSF is byte-identical. Both isolated QSFs append the same pre-flow script override to write the fixed date; no sys/ file or production RTL was edited. The necessary upstream files.qip addition of rtl/opll_snapshot.sv is retained in the candidate; all other QIP/SDC/IP/Tcl settings match.

## Provenance and verification

See provenance.json, baseline_inputs.json, candidate_inputs.json, integrity.json and each build's original output_files/SMS.{map,fit,sta,flow}.rpt. measurements.json contains raw extracted metrics, per-clock timing, hierarchy entries, critical warnings, and SHA-256 hashes of original reports. prepare.js exports exact commit archives; verify.js checks input and protected workspace file hashes. No existing build was reused: searches of local reports and manifests found historical v19, experimental and pre-cleanup v1 evidence, but no fully verified pair of these exact commits. Historical measurements are excluded.

Build directories are seedN/baseline and seedN/candidate. The first launch encountered PowerShell stderr handling and the second encountered Quartus 17 path normalization dropping Documents. Neither reached synthesis. Their logs are retained. The successful launch uses a temporary Z: mapping to this comparison directory. Commands and exit statuses are retained in runner scripts and status JSON files. No commit, push or PR comment was made.

## Seed 1

| Metric | Baseline | Candidate | Candidate − baseline | Relative change |
|---|---:|---:|---:|---:|
| Needed ALMs | 26,416 | 27,297 | +881 | +3.34% |
| Placed ALMs | 31,445 | 32,221 | +776 | +2.47% |
| Mapped registers | 34,461 | 34,731 | +270 | +0.78% |
| Fitted registers | 35,435 | 35,724 | +289 | +0.82% |
| Logic ALUTs | 36,960 | 38,274 | +1,314 | +3.56% |
| Routing ALUTs | 13,040 | 13,075 | +35 | +0.27% |
| M10K blocks | 488 | 489 | +1 | +0.20% |
| Logical block memory bits | 3,810,182 | 3,818,374 | +8,192 | +0.22% |
| DSP blocks | 39 | 39 | 0 | 0.00% |
| Worst setup slack (ns) | 0.456 | 0.582 | +0.126 | — |
| Worst hold slack (ns) | 0.243 | 0.243 | 0 | — |
| Setup TNS (ns) | 0 | 0 | 0 | — |
| Hold TNS (ns) | 0 | 0 | 0 | — |

Fitting successful: baseline true, candidate true. TimeQuest analysis completed successfully: baseline true, candidate true. Timing slack/TNS values come from the original sta.summary; TNS is the sum of reported per-clock values for that analysis type. A successful analyzer run is distinguished from passing timing.

Unconstrained-path summary (baseline, then candidate):

```text
; Unconstrained Clocks            ; 0     ; 0    ;
; Unconstrained Input Ports       ; 27    ; 27   ;
; Unconstrained Input Port Paths  ; 94    ; 94   ;
; Unconstrained Output Ports      ; 91    ; 91   ;
; Unconstrained Output Port Paths ; 153   ; 153  ;
; Unconstrained Clocks            ; 0     ; 0    ;
; Unconstrained Input Ports       ; 27    ; 27   ;
; Unconstrained Input Port Paths  ; 94    ; 94   ;
; Unconstrained Output Ports      ; 91    ; 91   ;
; Unconstrained Output Port Paths ; 155   ; 155  ;
```

Per-clock setup/hold slack, to expose core-domain changes that the global worst slack can mask:

| Analysis / clock | Baseline ns | Candidate ns | Difference ns |
|---|---:|---:|---:|
| Setup 'pll_hdmi / pll_hdmi_inst / altera_pll_i / cyclonev_pll / counter[0].output_counter / divclk' | 0.456 | 0.582 | 0.126 |
| Setup 'emu / pll / pll_inst / altera_pll_i / cyclonev_pll / counter[0].output_counter / divclk' | 1.109 | 0.907 | -0.202 |
| Setup 'sysmem / fpga_interfaces / clocks_resets / h2f_user0_clk' | 4.425 | 4.114 | -0.311 |
| Setup 'spi_sck' | 5.620 | 5.836 | 0.216 |
| Setup 'FPGA_CLK2_50' | 6.503 | 6.208 | -0.295 |
| Setup 'FPGA_CLK1_50' | 8.486 | 8.252 | -0.234 |
| Setup 'pll_audio / pll_audio_inst / altera_pll_i / general[0].gpll~PLL_OUTPUT_COUNTER / divclk' | 14.888 | 15.038 | 0.150 |
| Hold 'emu / pll / pll_inst / altera_pll_i / cyclonev_pll / counter[0].output_counter / divclk' | 0.243 | 0.243 | 0 |
| Hold 'pll_hdmi / pll_hdmi_inst / altera_pll_i / cyclonev_pll / counter[0].output_counter / divclk' | 0.246 | 0.260 | 0.014 |
| Hold 'pll_audio / pll_audio_inst / altera_pll_i / general[0].gpll~PLL_OUTPUT_COUNTER / divclk' | 0.248 | 0.264 | 0.016 |
| Hold 'FPGA_CLK2_50' | 0.258 | 0.417 | 0.159 |
| Hold 'sysmem / fpga_interfaces / clocks_resets / h2f_user0_clk' | 0.369 | 0.299 | -0.070 |
| Hold 'FPGA_CLK1_50' | 0.414 | 0.301 | -0.113 |
| Hold 'spi_sck' | 0.454 | 0.352 | -0.102 |

## Seed 2

| Metric | Baseline | Candidate | Candidate − baseline | Relative change |
|---|---:|---:|---:|---:|
| Needed ALMs | 26,371 | 27,261 | +890 | +3.37% |
| Placed ALMs | 31,382 | 32,136 | +754 | +2.40% |
| Mapped registers | 34,461 | 34,731 | +270 | +0.78% |
| Fitted registers | 35,339 | 35,781 | +442 | +1.25% |
| Logic ALUTs | 36,953 | 38,272 | +1,319 | +3.57% |
| Routing ALUTs | 13,122 | 12,796 | -326 | -2.48% |
| M10K blocks | 488 | 489 | +1 | +0.20% |
| Logical block memory bits | 3,810,182 | 3,818,374 | +8,192 | +0.22% |
| DSP blocks | 39 | 39 | 0 | 0.00% |
| Worst setup slack (ns) | 0.673 | 0.453 | -0.220 | — |
| Worst hold slack (ns) | 0.203 | 0.151 | -0.052 | — |
| Setup TNS (ns) | 0 | 0 | 0 | — |
| Hold TNS (ns) | 0 | 0 | 0 | — |

Fitting successful: baseline true, candidate true. TimeQuest analysis completed successfully: baseline true, candidate true. Timing slack/TNS values come from the original sta.summary; TNS is the sum of reported per-clock values for that analysis type. A successful analyzer run is distinguished from passing timing.

Unconstrained-path summary (baseline, then candidate):

```text
; Unconstrained Clocks            ; 0     ; 0    ;
; Unconstrained Input Ports       ; 27    ; 27   ;
; Unconstrained Input Port Paths  ; 94    ; 94   ;
; Unconstrained Output Ports      ; 91    ; 91   ;
; Unconstrained Output Port Paths ; 154   ; 154  ;
; Unconstrained Clocks            ; 0     ; 0    ;
; Unconstrained Input Ports       ; 27    ; 27   ;
; Unconstrained Input Port Paths  ; 94    ; 94   ;
; Unconstrained Output Ports      ; 91    ; 91   ;
; Unconstrained Output Port Paths ; 153   ; 153  ;
```

Per-clock setup/hold slack, to expose core-domain changes that the global worst slack can mask:

| Analysis / clock | Baseline ns | Candidate ns | Difference ns |
|---|---:|---:|---:|
| Setup 'pll_hdmi / pll_hdmi_inst / altera_pll_i / cyclonev_pll / counter[0].output_counter / divclk' | 0.673 | 0.453 | -0.220 |
| Setup 'emu / pll / pll_inst / altera_pll_i / cyclonev_pll / counter[0].output_counter / divclk' | 0.862 | 1.224 | 0.362 |
| Setup 'spi_sck' | 3.727 | 5.686 | 1.959 |
| Setup 'sysmem / fpga_interfaces / clocks_resets / h2f_user0_clk' | 3.727 | 4.584 | 0.857 |
| Setup 'FPGA_CLK2_50' | 6.539 | 6.347 | -0.192 |
| Setup 'FPGA_CLK1_50' | 8.663 | 8.732 | 0.069 |
| Setup 'pll_audio / pll_audio_inst / altera_pll_i / general[0].gpll~PLL_OUTPUT_COUNTER / divclk' | 14.671 | 14.651 | -0.020 |
| Hold 'pll_hdmi / pll_hdmi_inst / altera_pll_i / cyclonev_pll / counter[0].output_counter / divclk' | 0.203 | 0.199 | -0.004 |
| Hold 'emu / pll / pll_inst / altera_pll_i / cyclonev_pll / counter[0].output_counter / divclk' | 0.243 | 0.151 | -0.092 |
| Hold 'pll_audio / pll_audio_inst / altera_pll_i / general[0].gpll~PLL_OUTPUT_COUNTER / divclk' | 0.285 | 0.249 | -0.036 |
| Hold 'FPGA_CLK2_50' | 0.348 | 0.260 | -0.088 |
| Hold 'sysmem / fpga_interfaces / clocks_resets / h2f_user0_clk' | 0.361 | 0.359 | -0.002 |
| Hold 'spi_sck' | 0.390 | 0.462 | 0.072 |
| Hold 'FPGA_CLK1_50' | 0.411 | 0.414 | 0.003 |

## Seed 3

| Metric | Baseline | Candidate | Candidate − baseline | Relative change |
|---|---:|---:|---:|---:|
| Needed ALMs | 26,465 | 27,341 | +876 | +3.31% |
| Placed ALMs | 31,471 | 32,151 | +680 | +2.16% |
| Mapped registers | 34,461 | 34,731 | +270 | +0.78% |
| Fitted registers | 35,326 | 35,791 | +465 | +1.32% |
| Logic ALUTs | 36,958 | 38,268 | +1,310 | +3.54% |
| Routing ALUTs | 12,966 | 12,959 | -7 | -0.05% |
| M10K blocks | 488 | 489 | +1 | +0.20% |
| Logical block memory bits | 3,810,182 | 3,818,374 | +8,192 | +0.22% |
| DSP blocks | 39 | 39 | 0 | 0.00% |
| Worst setup slack (ns) | 0.319 | 0.516 | +0.197 | — |
| Worst hold slack (ns) | 0.241 | 0.237 | -0.004 | — |
| Setup TNS (ns) | 0 | 0 | 0 | — |
| Hold TNS (ns) | 0 | 0 | 0 | — |

Fitting successful: baseline true, candidate true. TimeQuest analysis completed successfully: baseline true, candidate true. Timing slack/TNS values come from the original sta.summary; TNS is the sum of reported per-clock values for that analysis type. A successful analyzer run is distinguished from passing timing.

Unconstrained-path summary (baseline, then candidate):

```text
; Unconstrained Clocks            ; 0     ; 0    ;
; Unconstrained Input Ports       ; 27    ; 27   ;
; Unconstrained Input Port Paths  ; 94    ; 94   ;
; Unconstrained Output Ports      ; 91    ; 91   ;
; Unconstrained Output Port Paths ; 153   ; 153  ;
; Unconstrained Clocks            ; 0     ; 0    ;
; Unconstrained Input Ports       ; 27    ; 27   ;
; Unconstrained Input Port Paths  ; 94    ; 94   ;
; Unconstrained Output Ports      ; 91    ; 91   ;
; Unconstrained Output Port Paths ; 153   ; 153  ;
```

Per-clock setup/hold slack, to expose core-domain changes that the global worst slack can mask:

| Analysis / clock | Baseline ns | Candidate ns | Difference ns |
|---|---:|---:|---:|
| Setup 'pll_hdmi / pll_hdmi_inst / altera_pll_i / cyclonev_pll / counter[0].output_counter / divclk' | 0.319 | 0.516 | 0.197 |
| Setup 'emu / pll / pll_inst / altera_pll_i / cyclonev_pll / counter[0].output_counter / divclk' | 1.098 | 1.088 | -0.010 |
| Setup 'sysmem / fpga_interfaces / clocks_resets / h2f_user0_clk' | 4.437 | 4.001 | -0.436 |
| Setup 'FPGA_CLK2_50' | 5.023 | 6.489 | 1.466 |
| Setup 'spi_sck' | 6.168 | 5.518 | -0.650 |
| Setup 'FPGA_CLK1_50' | 8.509 | 7.578 | -0.931 |
| Setup 'pll_audio / pll_audio_inst / altera_pll_i / general[0].gpll~PLL_OUTPUT_COUNTER / divclk' | 15.185 | 12.328 | -2.857 |
| Hold 'emu / pll / pll_inst / altera_pll_i / cyclonev_pll / counter[0].output_counter / divclk' | 0.241 | 0.237 | -0.004 |
| Hold 'pll_audio / pll_audio_inst / altera_pll_i / general[0].gpll~PLL_OUTPUT_COUNTER / divclk' | 0.264 | 0.263 | -0.001 |
| Hold 'pll_hdmi / pll_hdmi_inst / altera_pll_i / cyclonev_pll / counter[0].output_counter / divclk' | 0.305 | 0.237 | -0.068 |
| Hold 'sysmem / fpga_interfaces / clocks_resets / h2f_user0_clk' | 0.316 | 0.378 | 0.062 |
| Hold 'spi_sck' | 0.369 | 0.454 | 0.085 |
| Hold 'FPGA_CLK1_50' | 0.386 | 0.410 | 0.024 |
| Hold 'FPGA_CLK2_50' | 0.418 | 0.418 | 0 |

## Capacity and margins

| Resource | Capacity | Baseline maximum use | Candidate maximum use | Baseline minimum headroom | Candidate minimum headroom |
|---|---:|---:|---:|---:|---:|
| Needed ALMs | 41,910 | 26,465 (63.15%) | 27,341 (65.24%) | 15,445 (36.85%) | 14,569 (34.76%) |
| Placed ALMs | 41,910 | 31,471 (75.09%) | 32,221 (76.88%) | 10,439 (24.91%) | 9,689 (23.12%) |
| M10K blocks | 553 | 488 (88.25%) | 489 (88.43%) | 65 (11.75%) | 64 (11.57%) |
| Logical block memory bits | 5,662,720 | 3,810,182 (67.29%) | 3,818,374 (67.43%) | 1,852,538 (32.71%) | 1,844,346 (32.57%) |
| DSP blocks | 112 | 39 (34.82%) | 39 (34.82%) | 73 (65.18%) | 73 (65.18%) |

Smallest baseline setup/hold margin across tested seeds: 0.319 / 0.203 ns.

Smallest candidate setup/hold margin across tested seeds: 0.453 / 0.151 ns.

Compare candidate minus baseline within each seed. Differences between seeds measure fitter variability and must not be counted as feature cost.

Mapped registers come from the Analysis & Synthesis Summary; fitted registers are the fitter total, including I/O registers. Physical synthesis can change the fitted count. Logic and routing ALUT counts are the fitter's separate logic and route-through fields. Needed ALMs incorporate the fitter's packing accounting; placed ALMs describe actual placement occupancy. Logical memory-bit headroom is not interchangeable with available M10K blocks because of block granularity and packing.

## Warnings, unconstrained paths and violations

Seed 1: 40 baseline and 40 candidate unique critical-warning messages/table entries after normalizing build paths and source line locations. New: 0; removed: 0. New/removed unconstrained-port names or reasons: 0/0. Negative timing-summary entries: baseline 0, candidate 0.

Seed 2: 40 baseline and 40 candidate unique critical-warning messages/table entries after normalizing build paths and source line locations. New: 0; removed: 0. New/removed unconstrained-port names or reasons: 0/0. Negative timing-summary entries: baseline 0, candidate 0.

Seed 3: 40 baseline and 40 candidate unique critical-warning messages/table entries after normalizing build paths and source line locations. New: 0; removed: 0. New/removed unconstrained-port names or reasons: 0/0. Negative timing-summary entries: baseline 0, candidate 0.

The original critical synthesis warnings concern ignored power-up levels (one group plus 37 register messages); report tables also flag evolution_ss_out (96 versus 160 elements) and mode (4 versus 5 elements) port widths. Full texts and report filenames are in measurements.json and comparison_audit.json. Equal warning sets do not establish that those existing warnings are harmless.

Unconstrained I/O paths are outside the quoted setup/hold pass. Port-list equality is checked explicitly; differing path counts are disclosed above. The unchanged constraints do not establish timing closure for these unconstrained paths. This comparison does not validate completeness of the existing SDC.

## Fitter hierarchy evidence

Inclusive subtree totals follow; parent and child rows overlap and must not be summed. Fractional ALMs are fitter hierarchy accounting estimates and can differ from rounded whole-design totals.

| Seed | Subtree | Baseline needed ALMs | Candidate needed ALMs | Difference |
|---|---|---:|---:|---:|
| 1 | savestates | 3933.3 | 4219.5 | 286.2 |
| 1 | opll_snapshot | 0.0 | 152.0 | 152.0 |
| 1 | opll | 1024.3 | 1515.1 | 490.8 |
| 2 | savestates | 3871.9 | 4219.6 | 347.7 |
| 2 | opll_snapshot | 0.0 | 155.7 | 155.7 |
| 2 | opll | 1023.0 | 1523.2 | 500.2 |
| 3 | savestates | 3921.5 | 4239.0 | 317.5 |
| 3 | opll_snapshot | 0.0 | 140.0 | 140.0 |
| 3 | opll | 1026.7 | 1515.2 | 488.5 |

The FM subtree and savestates subtree are the principal measured local contributors. The snapshot block is inside savestates and accounts for the added 8,192 logical bits and one M10K. Residual whole-design ALM differences include changes elsewhere in the fitted design; they are not assigned to particular RTL mechanisms without hierarchy evidence.

The largest local additions can also be examined without subtree overlap using the fitter's parenthesized own-entity ALM values. Seed-1 leading contributors are:

| Entity | Baseline own ALMs | Candidate own ALMs | Difference |
|---|---:|---:|---:|
| envelopegenerator | 144.4 | 321.0 | 176.6 |
| opll_snapshot | 0.0 | 152.0 | 152.0 |
| savestates | 3933.3 | 4067.6 | 134.3 |
| controller | 102.3 | 222.6 | 120.3 |
| PhaseGenerator | 87.0 | 151.1 | 64.1 |

## Technical assessment

Across 3 matched seeds, candidate minus baseline needed ALMs is 876 to 890 (3.310 to 3.375% of baseline; 2.090 to 2.124 percentage points of device ALM capacity). Placed-ALM change is 680 to 776. M10K change is 1; DSP change is 0.

Core-clock setup slack changes range from -0.202 to 0.362 ns; core-clock hold changes range from -0.092 to 0 ns. Global worst setup changes range from -0.220 to 0.197 ns, and global worst hold changes from -0.052 to 0 ns. Thus a single seed's improved global setup slack must not be presented as an inherent feature benefit. The smallest candidate hold margin is 0.151 ns versus 0.203 ns for baseline across these seeds; both are positive.

The incremental cost is **small in whole-device capacity terms**, supported by those paired resource deltas. All tested builds pass constrained setup and hold timing with zero TNS. The board-level resource closest to capacity is M10K storage: the candidate uses 489/553 blocks, leaving 64 (11.57%). Timing differences are whole-design fitter outcomes and do not show a guaranteed timing improvement or a direct FM-path penalty. Seed-to-seed ranges describe variability; the feature cost is measured only within matched pairs. This resource assessment does not settle the RTL maintenance-complexity tradeoff.

The user reports that omitting FM restoration can leave Double Dragon and Ys audio incorrect until a soundtrack change. That functional observation is user-reported, with hardware reconfirmation pending; it was not verified by these compilations.

## Reproduction

To recompile, copy the JavaScript harness scripts into a **new empty comparison directory**, keep the repository as the current directory, and run the sequence below with Node.js and Quartus 17.0.2 installed at the recorded path. Z: must be unused in that process session. The scripts refuse to overwrite existing build directories or compile logs. The pre-flow harness is generated by prepare.js. No PowerShell execution-policy change is required for this Node runner.

```text
node <fresh-directory>/prepare.js
node <fresh-directory>/run.js
node <fresh-directory>/collect.js
node <fresh-directory>/extra_seeds.js
node <fresh-directory>/verify.js
node <fresh-directory>/finalize.js
node <fresh-directory>/seal.js
```

For report-only verification, run collect.js, audit.js and report.js against the preserved original reports; no Quartus compile is required. final_provenance.json records all successful compile exit statuses and artifact_manifest.json hashes the completed outputs, including RBFs. Original reports remain in seedN/{baseline,candidate}/output_files.

## Evidence index

[Final provenance](final_provenance.json), [input integrity](integrity.json), [artifact hashes](artifact_manifest.json), [CSV metrics](measurements.csv), [full extraction](measurements.json), [warning/hierarchy comparison](comparison_audit.json), [existing-evidence search](SEARCH_NOTES.md). Run `node verify_artifacts.js` in this directory to verify hashes of the 96 original output artifacts.

| Seed | Revision | Synthesis | Fitter | Timing |
|---|---|---|---|---|
| 1 | baseline | [map report](seed1/baseline/output_files/SMS.map.rpt) | [fit report](seed1/baseline/output_files/SMS.fit.rpt) | [STA summary](seed1/baseline/output_files/SMS.sta.summary) / [STA report](seed1/baseline/output_files/SMS.sta.rpt) |
| 1 | candidate | [map report](seed1/candidate/output_files/SMS.map.rpt) | [fit report](seed1/candidate/output_files/SMS.fit.rpt) | [STA summary](seed1/candidate/output_files/SMS.sta.summary) / [STA report](seed1/candidate/output_files/SMS.sta.rpt) |
| 2 | baseline | [map report](seed2/baseline/output_files/SMS.map.rpt) | [fit report](seed2/baseline/output_files/SMS.fit.rpt) | [STA summary](seed2/baseline/output_files/SMS.sta.summary) / [STA report](seed2/baseline/output_files/SMS.sta.rpt) |
| 2 | candidate | [map report](seed2/candidate/output_files/SMS.map.rpt) | [fit report](seed2/candidate/output_files/SMS.fit.rpt) | [STA summary](seed2/candidate/output_files/SMS.sta.summary) / [STA report](seed2/candidate/output_files/SMS.sta.rpt) |
| 3 | baseline | [map report](seed3/baseline/output_files/SMS.map.rpt) | [fit report](seed3/baseline/output_files/SMS.fit.rpt) | [STA summary](seed3/baseline/output_files/SMS.sta.summary) / [STA report](seed3/baseline/output_files/SMS.sta.rpt) |
| 3 | candidate | [map report](seed3/candidate/output_files/SMS.map.rpt) | [fit report](seed3/candidate/output_files/SMS.fit.rpt) | [STA summary](seed3/candidate/output_files/SMS.sta.summary) / [STA report](seed3/candidate/output_files/SMS.sta.rpt) |

## Suggested upstream summary

Matched Quartus Lite 17.0.2 Build 602 compilations of exact pre-PR 66f16d5c656fd8906d62570da4d258875bcee684 and post-PR 8cd53ccc954c24970372ea6d8a3fb2336a14c46f on 5CSEBA6U23I7 (seeds 1, 2, 3, fixed BUILD_DATE) show a small whole-device increment: +876 to 890 needed ALMs (+3.31–3.37%), +680 to 776 placed ALMs, +1 M10K/+8,192 logical bits, and no DSP increase. All six builds pass constrained setup/hold with zero TNS. Candidate minimum setup/hold margins are 0.453/0.151 ns; timing changes vary by seed. No new critical warnings or unconstrained ports/clocks appeared; existing unconstrained I/O path counts differ by seed and are disclosed. Original reports and hashed inputs accompany the comparison. Double Dragon/Ys audio remaining incorrect until a soundtrack change is user-reported and still awaits hardware reconfirmation.
