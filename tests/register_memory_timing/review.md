# RegisterMemory AUTO setup regression: retained-implementation investigation

Baseline: 8443a0d19a88aff7a5900011bccf386daf146945. Independent RegisterMemory AUTO experiment, seeds 1 and 2. Quartus Prime Lite 17.0.2 Build602, 5CSEBA6U23I7. This investigation performs TimeQuest queries only, on copies of the existing fitted databases. No synthesis/fitting, RTL, SDC, QSF, seed or implementation change was performed.

## Finding and recommendation

The lost setup margin is **not a critical path through RegisterMemory**. It is an indirect whole-design implementation change in HDMI video logic. Both AUTO builds lack the baseline's recorded physical register-retiming transformations; the scaler luminance family consequently has seven logic levels rather than four. Placement/routing then selects different worst paths: a long shadowmask-RAM-to-OSD route in seed 1, versus the deeper scaler luminance cone in seed 2. Calling this only random placement noise would miss the repeatable retiming difference.

The global setup regression repeats: 0.508→0.146 ns and 0.451→0.019 ns. Its exact failing-margin mechanism varies by seed. All four reported setup/hold TNS remain zero, but 19 ps is insufficient evidence for production adoption.

**Least invasive direction:** retain RegisterMemory AUTO's storage semantics and target implementation stability of the existing video pipeline: recover the baseline-class scaler retiming and keep shadowmask RAM/OSD control local, without changing video latency or relaxing timing requirements. This is a recommendation of scope, not a demonstrated fix or an implementation-experiment proposal. The supported mechanism and license feasibility need review first. No available AUTO implementation in these two seeds preserves the baseline global margin. Keep the branch experimental.

Restoring timing may consume some of the reported whole-design area saving. The fitter attributes about 77.0/72.8 fewer needed ALMs to RegisterMemory itself, while the measured whole-design reductions are 293/329 ALMs. The full reduction includes different global optimization outcomes; it cannot be promised unchanged when baseline video retiming is restored. Hierarchical ALM attribution is not additive proof of causality.

## Reproduction and evidence

[prepare.js](prepare.js) verifies all 203 source inputs of each retained build, hashes original artifacts/databases and protected branch refs, and copies source inputs plus fitted db into ignored scratch trees. [query.ps1](query.ps1) and [query.tcl](query.tcl) run create_timing_netlist -model slow, read the original SDC, and extract 20 global setup paths plus FM/RegisterMemory/scaler paths. [families.ps1](families.ps1) and [families.tcl](families.tcl) compare four common video path families. [analyze.js](analyze.js) checks extracted minima against the retained summaries and checks cell-plus-interconnect delay sums. [evidence.js](evidence.js) records original fitter transformations, messages, constraints and warnings. No get_keepers wildcard query is used directly.

An initial long-path invocation failed before netlist creation with a Tcl xibiso2 package-loading error. The retained failure log is seed1_baseline_query_package_failure.log. The established short Z: path invocation succeeds for all four copies; all eight successful query runs report zero errors/warnings. Earlier help-command invocation failures did not open a project. These are query invocation issues, not synthesis or design failures.

Primary machine-readable evidence: [path_comparison.json](path_comparison.json), [implementation_evidence.json](implementation_evidence.json), each *_paths.tsv / *_points.tsv, and the linked detailed reports. The timing corner is the same Slow 1100mV 100°C model as the original STA; this is not a new multi-corner signoff. The project retains TIMEQUEST_MULTICORNER_ANALYSIS OFF.

## Exact global worst paths

All eight launch/latch clocks below are the same HDMI PLL output clock: pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk. Its relationship is 6.732 ns (about 148.54 MHz); all four worst paths have setup start/end multicycle values 1/1. Exact endpoints and locations are preserved below.

| Build | Slack ns | Data delay ns | Data cell ns | Data routing ns | Logic levels | Reported skew ns | CPPR ns |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| [Seed 1 baseline](seed1_baseline_setup.rpt) | 0.508 | 3.626 | 1.696 | 1.930 | 2 | -2.398 | 0.966 |
| [Seed 1 AUTO](seed1_candidate_setup.rpt) | 0.146 | 5.701 | 1.265 | 4.436 | 2 | -0.685 | 0.966 |
| [Seed 2 baseline](seed2_baseline_setup.rpt) | 0.451 | 5.591 | 3.144 | 2.447 | 4 | -0.490 | 0.966 |
| [Seed 2 AUTO](seed2_candidate_setup.rpt) | 0.019 | 6.413 | 4.030 | 2.383 | 7 | -0.100 | 1.355 |

Data cell/routing values come from TimeQuest Physical Delays → Arrival Path → Data. Routing sums IC and Routing Element delays; small signed IC corrections are retained. These are TimeQuest path-model categories, not a count of RTL arithmetic operators. Reported clock skew already incorporates common-clock pessimism removal (CPPR); do not add CPPR again. All four paths use −0.200 ns clock uncertainty. Their reported values satisfy slack = relationship + reported skew − data delay − 0.200 ns. Full launch/capture clock routes and per-element locations are in each report.

### Seed 1 baseline

```text
FROM ascal:ascal|altsyncram:o_linf2[0].r[7]__8|altsyncram_m6n1:auto_generated|ram_block1a0~PORT_B_WRITE_ENABLE_REG
  at M10K_X26_Y77_N0
TO   ascal:ascal|o_vpix_inner[0].r[7]
  at FF_X22_Y75_N7
Arrival 14.233 ns; required 14.741 ns
```

### Seed 1 AUTO

```text
FROM shadowmask:HDMI_shadowmask|altshift_taps:vid_rtl_0|shift_taps_0vu:auto_generated|altsyncram_pr91:altsyncram4|ram_block5a0
  at M10K_X14_Y65_N0
TO   osd:hdmi_osd|osd_div[2]
  at FF_X10_Y11_N31
Arrival 14.552 ns; required 14.698 ns
```

### Seed 2 baseline

```text
FROM ascal:ascal|o_hcpt[0]
  at FF_X29_Y73_N2
TO   ascal:ascal|o_vcpt_pre3[2]
  at FF_X24_Y71_N59
Arrival 14.278 ns; required 14.729 ns
```

### Seed 2 AUTO

```text
FROM ascal:ascal|o_vpix_inner[1].r[0]
  at FF_X16_Y78_N29
TO   ascal:ascal|o_poly_lum[6]
  at FF_X18_Y78_N55
Arrival 15.102 ns; required 15.121 ns
```

Seed-1 baseline is a scaler line-buffer read/output-selection path, not the new FM RAM. Seed-2 baseline is the horizontal-counter-controlled vertical pre-counter update. Source context is [ascal.vhd:2773](../register_memory_auto/baseline/sys/ascal.vhd#L2773) for output sweep, ascal.vhd:2899–2911 for pixel selection, and the detailed RAM primitive names above. The source label PORT_B_WRITE_ENABLE_REG is TimeQuest's internal RAM timing node; it is not an RTL write-enable net driving the destination register.

## Compare the same video families, not different global winners

| Constrained path family, minimum setup slack ns | Seed 1 baseline | Seed 1 AUTO | Seed 2 baseline | Seed 2 AUTO |
| --- | ---: | ---: | ---: | ---: |
| o_linf2 → o_vpix_inner | [0.508](seed1_baseline_linebuf.rpt) | [1.001](seed1_candidate_linebuf.rpt) | [0.942](seed2_baseline_linebuf.rpt) | [0.878](seed2_candidate_linebuf.rpt) |
| shadowmask vid RAM → osd_div | [2.333](seed1_baseline_shadow_osd.rpt) | [0.146](seed1_candidate_shadow_osd.rpt) | [2.913](seed2_baseline_shadow_osd.rpt) | [1.865](seed2_candidate_shadow_osd.rpt) |
| o_hcpt → o_vcpt_pre3 | [0.633](seed1_baseline_counter.rpt) | [0.982](seed1_candidate_counter.rpt) | [0.451](seed2_baseline_counter.rpt) | [1.134](seed2_candidate_counter.rpt) |
| o_vpix_inner → o_poly_lum | [0.533](seed1_baseline_poly_lum.rpt) | [0.960](seed1_candidate_poly_lum.rpt) | [1.529](seed2_baseline_poly_lum.rpt) | [0.019](seed2_candidate_poly_lum.rpt) |

Family minima can choose different bits and routes. In particular the baseline luminance endpoints are retimed OTERM registers, so they are not identical physical register boundaries to AUTO. This difference is evidence of changed implementation, not a claim of a same-register path comparison.

### Seed 1 AUTO: long shadowmask/OSD placement

For the exact same logical RAM source ram_block5a0 and destination osd_div[2], baseline slack is 2.352 ns; AUTO is 0.146 ns. Data delay rises 3.588→5.701 ns (+2.113), and reported skew worsens −0.592→−0.685 ns (−0.093), accounting for the −2.206 ns loss on that pair. Cell delay rises 0.874→1.265 ns; routing rises 2.714→4.436 ns, accounting for 1.722 ns of the data-delay increase. Both retain two reported logic levels.

The baseline source/destination are M10K_X26_Y69_N0 / FF_X10_Y72_N26; AUTO uses M10K_X14_Y65_N0 / FF_X10_Y11_N31. The destination has moved from the upper video region to near Y11 while the RAM remains at Y65. The large separation and route delay support a physical locality explanation; coordinate distance alone is not a calibrated wire-delay metric. Full routing elements prove the delay increase.

The path is legitimate video control: [shadowmask.sv:96](../register_memory_auto/baseline/sys/shadowmask.sv#L96) shifts VS/HS/DE in vid; outputs come from vid[11:9] at line116. [sys_top.v:1159–1196](../register_memory_auto/baseline/sys/sys_top.v#L1159) connects those outputs into hdmi_osd. [osd.v:238–245](../register_memory_auto/baseline/sys/osd.v#L238) updates osd_div under that video control. The critical RAM is the existing shadowmask shift-register RAM, not RegisterMemory. The new FM M10K is at X76/Y9 in seed1 (X76/Y22 in seed2); it does not occupy the displaced shadowmask's old location. A direct one-block site collision is not supported.

### Seed 2 AUTO: deeper luminance cone and missing retiming

The worst path traverses pixel components into scaler poly_lum, whose [ascal.vhd:1128–1151](../register_memory_auto/baseline/sys/ascal.vhd#L1128) computes max(R,G,B) with two comparisons and selection. The adaptive luminance assignments are at lines2413–2418; input pipeline assignment is at line2976. AUTO's detailed path includes LessThan27, v~1, LessThan28 and o_poly_lum selection logic, ending in o_poly_lum[6].

| Luminance family minimum | Cell ns | Routing ns | Data ns | Levels | Skew ns | Slack ns |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Seed 1 baseline | 2.251 | 3.598 | 5.849 | 4 | -0.150 | 0.533 |
| Seed 1 AUTO | 2.996 | 2.470 | 5.466 | 7 | -0.106 | 0.960 |
| Seed 2 baseline | 2.428 | 2.424 | 4.852 | 4 | -0.151 | 1.529 |
| Seed 2 AUTO | 4.030 | 2.383 | 6.413 | 7 | -0.100 | 0.019 |

Seed2 family degradation is 1.529→0.019 ns (−1.510). The data delay increases 4.852→6.413 ns (+1.561), mostly cell delay (+1.602); routing actually decreases about0.042 ns. Skew improves by0.051 ns. Thus this result cannot be explained as simply worse routing or clock skew. Baseline and AUTO logic boundaries differ because of physical retiming.

## Repeatable global physical-synthesis difference

All four QSFs enable PHYSICAL_SYNTHESIS_REGISTER_RETIMING, register duplication, combinational physical synthesis and HIGH PERFORMANCE EFFORT. The first register-retiming pass reports estimated improvement279 ps in both baselines, versus0 ps in both AUTO builds; subsequent pass0 ps in all four. These estimates are optimizer diagnostics, not final slack improvements.

| Fitter Netlist Optimizations report entries | Seed 1 baseline | Seed 1 AUTO | Seed 2 baseline | Seed 2 AUTO |
| --- | ---: | ---: | ---: | ---: |
| Retimed Register, whole design | 708 | 0 | 706 | 0 |
| Retimed Register, ascal | 383 | 0 | 383 | 0 |
| Retimed Register, luminance-related | 49 | 0 | 49 | 0 |

Counts are transformation-report rows, not a new physical FF utilization metric. Baseline entries explicitly mark o_poly_lum[6]_OTERM251/253/255/257 and other o_poly_lum/o_h_lum_pix registers as Retimed Register / Physical Synthesis / Timing optimization. AUTO contains no such entries anywhere. The actual baseline critical luminance endpoints are live OTERM registers in the timing netlist. See selectedTransformationRows and optimizationMessages in implementation_evidence.json.

Confidence is high that the retained implementations differ in physical retiming and that this affects luminance depth. The logs do **not** disclose why the one-line RAM inference change makes Quartus's heuristic choose no retiming. A compiler heuristic interaction, rather than a logical dependency between FM and HDMI, is plausible but its internal decision is unverified. No compiler bug, global retiming prohibition caused by M10K, or universally reproducible cause beyond these two seeds is established.

## RegisterMemory and FM are not the global setup bottleneck

| Minimum constrained setup slack ns | Seed 1 baseline | Seed 1 AUTO | Seed 2 baseline | Seed 2 AUTO |
| --- | ---: | ---: | ---: | ---: |
| From RegisterMemory timing nodes | [10.159](seed1_baseline_register_from.rpt) | [8.171](seed1_candidate_register_from.rpt) | [9.196](seed2_baseline_register_from.rpt) | [9.189](seed2_candidate_register_from.rpt) |
| To RegisterMemory timing nodes | [7.472](seed1_baseline_register_to.rpt) | [8.833](seed1_candidate_register_to.rpt) | [7.855](seed2_baseline_register_to.rpt) | [7.892](seed2_candidate_register_to.rpt) |
| From FM timing nodes | [5.490](seed1_baseline_fm_from.rpt) | [5.507](seed1_candidate_fm_from.rpt) | [4.858](seed2_baseline_fm_from.rpt) | [5.094](seed2_candidate_fm_from.rpt) |
| To FM timing nodes | [2.436](seed1_baseline_fm_to.rpt) | [2.654](seed1_candidate_fm_to.rpt) | [2.690](seed2_baseline_fm_to.rpt) | [2.596](seed2_candidate_fm_to.rpt) |

These queries include RAM internal timing nodes; their collection sizes are not fitted FF counts. RegisterMemory paths use the core PLL domain, relationship18.626 ns, not the HDMI6.732 ns domain. AUTO does alter local RAM-access timing (e.g. seed1 minimum from-bank slack10.159→8.171 ns), but it remains far from the whole-design limit. All top20 global paths are saved; none traverses the FM bank. The HDMI-versus-core clock groups are exclusive in the existing SDC.

## Constraints and critical warnings

The source SDC SHA256 is identical in all four builds: 0a5fa4015b82ad7ce38e56d1ae4aadea6209af59c5dd9eff56a11139cf16ce86. report_sdc and report_sdc -ignored are retained for each implementation; all report no ignored SDC constraints. Effective PLL clocks and0.200 ns uncertainty are unchanged. Detailed report timing was reproduced exactly from copied DBs, so the regression is not a different-corner or stale-summary artifact.

Existing OSD multicycle exceptions target *_osd|osd_vcnt* (setup2/hold1), not osd_div. All four worst paths are single-cycle. Existing scaler false paths target configuration inputs, not the measured o_vpix_inner→o_poly_lum or o_hcpt→o_vcpt_pre3 paths. Broad existing clock-group/configuration/IO exceptions and unconstrained external IO limit overall signoff scope, but do not explain the measured intra-HDMI A/B difference. report_exceptions lists existing false-path and partially overridden multicycle statuses; these are not new AUTO warnings or grounds to waive the critical paths.

All four original result sets count38 critical warnings, with unchanged critical-warning content after normalizing build paths. They concern ignored VDP register power-up levels (18061/18010), not the measured HDMI data paths. The only normalized warning additions in AUTO are the expected synthesized-away RAM header and unused RegisterMemory columns14/15. Existing fitter warnings include audio PLL LOCKED connection21300, ignored fast-IO assignments176250/176251, invalid assignments171167 and LogicLock subscription warning292013. None identifies an AUTO-only clock/constraint error that accounts for this regression. LogicLock is therefore not an assumed available remedy in this Lite installation.

## Consistency, limits and stopping point

The **global setup loss and lack of reported retiming are consistent across both seeds**. The global worst endpoint, data routing and size of luminance loss are strongly implementation-dependent. Shadowmask→OSD family slack varies0.146→1.865 ns between AUTO seeds; luminance varies0.960→0.019 ns. Counter-family timing improves in both AUTO builds. Average global interconnect rises in both AUTO pairs while total peak usage falls; those aggregate figures alone cannot diagnose either path.

Do not treat seed selection alone as evidence that the margin issue is solved. Do not relax HDMI period/uncertainty or invent an OSD multicycle to conceal a legitimate single-cycle path. Do not change RegisterMemory latency, reset/collision semantics or savestate behavior to address a path that does not traverse it. Recovering video retiming/locality is the least invasive target, but no validated remedy preserving both the full area saving and timing margin exists in these four databases.

This report stops before implementation-experiment design or execution. Review the timing evidence, available implementation-control mechanisms and the acceptable area-versus-margin target first. PhaseMemory, v19, the independent branch, original fitted DBs, RTL, constraints, settings and seeds remain preserved; [preservation_after.json](preservation_after.json) verifies 6,869 protected files (including original databases) and 126 branch refs, with zero mismatches.
