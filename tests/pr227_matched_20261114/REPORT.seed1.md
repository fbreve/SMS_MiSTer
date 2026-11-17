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

## Capacity and margins

| Resource | Capacity | Baseline maximum use | Candidate maximum use | Candidate minimum headroom |
|---|---:|---:|---:|---:|
| Needed ALMs | 41,910 | 26,416 (63.03%) | 27,297 (65.13%) | 14,613 (34.87%) |
| Placed ALMs | 41,910 | 31,445 (75.03%) | 32,221 (76.88%) | 9,689 (23.12%) |
| M10K blocks | 553 | 488 (88.25%) | 489 (88.43%) | 64 (11.57%) |
| Logical block memory bits | 5,662,720 | 3,810,182 (67.29%) | 3,818,374 (67.43%) | 1,844,346 (32.57%) |
| DSP blocks | 112 | 39 (34.82%) | 39 (34.82%) | 73 (65.18%) |

Smallest baseline setup/hold margin across tested seeds: 0.456 / 0.243 ns.

Smallest candidate setup/hold margin across tested seeds: 0.582 / 0.243 ns.

Compare candidate minus baseline within each seed. Differences between seeds measure fitter variability and must not be counted as feature cost.

## Warnings, unconstrained paths and violations

Seed 1: 40 baseline and 40 candidate unique critical-warning messages/table entries after normalizing build paths and source line locations. New: 0; removed: 0. New/removed unconstrained-port names or reasons: 0/0. Negative timing-summary entries: baseline 0, candidate 0.

The original critical synthesis warnings concern ignored power-up levels (one group plus 37 register messages); report tables also flag evolution_ss_out (96 versus 160 elements) and mode (4 versus 5 elements) port widths. Full texts and report filenames are in measurements.json and comparison_audit.json. Equal warning sets do not establish that those existing warnings are harmless.

Unconstrained I/O paths are outside the quoted setup/hold pass. Port-list equality is checked explicitly; differing path counts are disclosed above. The unchanged constraints do not establish timing closure for these unconstrained paths. This comparison does not validate completeness of the existing SDC.

## Fitter hierarchy evidence

Inclusive subtree totals follow; parent and child rows overlap and must not be summed. Fractional ALMs are fitter hierarchy accounting estimates and can differ from rounded whole-design totals.

| Seed | Subtree | Baseline needed ALMs | Candidate needed ALMs | Difference |
|---|---|---:|---:|---:|
| 1 | savestates | 3933.3 | 4219.5 | 286.2 |
| 1 | opll_snapshot | 0.0 | 152.0 | 152.0 |
| 1 | opll | 1024.3 | 1515.1 | 490.8 |

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

Across 1 matched seeds, candidate minus baseline needed ALMs is 881 (3.335% of baseline; 2.102 percentage points of device ALM capacity). Placed-ALM change is 776. M10K change is 1; DSP change is 0.

The incremental cost is **small in whole-device capacity terms**, supported by those paired resource deltas. All tested builds pass constrained setup and hold timing with zero TNS. The board-level resource closest to capacity is M10K storage: the candidate uses 489/553 blocks, leaving 64 (11.57%). Timing differences are whole-design fitter outcomes and do not show a guaranteed timing improvement or a direct FM-path penalty. Seed-to-seed ranges describe variability; the feature cost is measured only within matched pairs. This resource assessment does not settle the RTL maintenance-complexity tradeoff.

The user reports that omitting FM restoration can leave Double Dragon and Ys audio incorrect until a soundtrack change. That functional observation is user-reported, with hardware reconfirmation pending; it was not verified by these compilations.

## Suggested upstream summary

I compiled exact pre-PR 66f16d5c656fd8906d62570da4d258875bcee684 and post-PR 8cd53ccc954c24970372ea6d8a3fb2336a14c46f with Quartus Lite 17.0.2 Build 602 for 5CSEBA6U23I7, using matched seeds 1, unchanged common constraints/settings and a fixed BUILD_DATE. The paired incremental cost was 881 needed ALMs (3.335%), 776 placed ALMs, one M10K/8,192 logical bits and no DSPs. All builds passed constrained setup/hold timing with zero TNS. Candidate minimum setup/hold margins were 0.582/0.243 ns. No new critical warnings were introduced. Existing unconstrained I/O remains; per-seed path-count differences are disclosed in the report. The resource increment is small relative to device capacity. The report includes original Quartus reports and hashed input manifests. Separately, the reported Double Dragon/Ys audio persistence until a soundtrack change still awaits hardware reconfirmation.
