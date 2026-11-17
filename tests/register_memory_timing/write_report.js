const fs=require('fs'),p=require('path'),d=__dirname,r=JSON.parse(fs.readFileSync(p.join(d,'path_comparison.json'))),e=JSON.parse(fs.readFileSync(p.join(d,'implementation_evidence.json')));
const num=x=>Number(x).toFixed(3),tags=Object.keys(r),label=t=>t.replace('seed','Seed ').replace('_baseline',' baseline').replace('_candidate',' AUTO');
let s=`# RegisterMemory AUTO setup regression: retained-implementation investigation

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
`;
for(const t of tags){const x=r[t].main[0],cp=e[t].worstClockAdjustments.find(q=>q.type==='ccpp').delay;s+=`| [${label(t)}](${x.file}) | ${num(x.slack)} | ${num(x.data)} | ${num(x.cell)} | ${num(x.ic+x.routingElements)} | ${x.levels} | ${num(x.skew)} | ${num(cp)} |\n`;}
s+='\nData cell/routing values come from TimeQuest Physical Delays → Arrival Path → Data. Routing sums IC and Routing Element delays; small signed IC corrections are retained. These are TimeQuest path-model categories, not a count of RTL arithmetic operators. Reported clock skew already incorporates common-clock pessimism removal (CPPR); do not add CPPR again. All four paths use −0.200 ns clock uncertainty. Their reported values satisfy slack = relationship + reported skew − data delay − 0.200 ns. Full launch/capture clock routes and per-element locations are in each report.\n';
for(const t of tags){const x=r[t].main[0];s+=`\n### ${label(t)}\n\n\`\`\`text\nFROM ${x.from}\n  at ${x.sourceLocation}\nTO   ${x.to}\n  at ${x.destinationLocation}\nArrival ${num(x.arrival)} ns; required ${num(x.required)} ns\n\`\`\`\n`;}
s+=`\nSeed-1 baseline is a scaler line-buffer read/output-selection path, not the new FM RAM. Seed-2 baseline is the horizontal-counter-controlled vertical pre-counter update. Source context is [ascal.vhd:2773](../register_memory_auto/baseline/sys/ascal.vhd#L2773) for output sweep, ascal.vhd:2899–2911 for pixel selection, and the detailed RAM primitive names above. The source label PORT_B_WRITE_ENABLE_REG is TimeQuest's internal RAM timing node; it is not an RTL write-enable net driving the destination register.

## Compare the same video families, not different global winners

| Constrained path family, minimum setup slack ns | Seed 1 baseline | Seed 1 AUTO | Seed 2 baseline | Seed 2 AUTO |
| --- | ---: | ---: | ---: | ---: |
`;
for(const [key,name]of [['linebuf','o_linf2 → o_vpix_inner'],['shadow_osd','shadowmask vid RAM → osd_div'],['counter','o_hcpt → o_vcpt_pre3'],['poly_lum','o_vpix_inner → o_poly_lum']])s+=`| ${name} | ${tags.map(t=>`[${num(r[t].families[key][0].slack)}](${r[t].families[key][0].file})`).join(' | ')} |\n`;
s+=`\nFamily minima can choose different bits and routes. In particular the baseline luminance endpoints are retimed OTERM registers, so they are not identical physical register boundaries to AUTO. This difference is evidence of changed implementation, not a claim of a same-register path comparison.

### Seed 1 AUTO: long shadowmask/OSD placement

For the exact same logical RAM source ram_block5a0 and destination osd_div[2], baseline slack is 2.352 ns; AUTO is 0.146 ns. Data delay rises 3.588→5.701 ns (+2.113), and reported skew worsens −0.592→−0.685 ns (−0.093), accounting for the −2.206 ns loss on that pair. Cell delay rises 0.874→1.265 ns; routing rises 2.714→4.436 ns, accounting for 1.722 ns of the data-delay increase. Both retain two reported logic levels.

The baseline source/destination are M10K_X26_Y69_N0 / FF_X10_Y72_N26; AUTO uses M10K_X14_Y65_N0 / FF_X10_Y11_N31. The destination has moved from the upper video region to near Y11 while the RAM remains at Y65. The large separation and route delay support a physical locality explanation; coordinate distance alone is not a calibrated wire-delay metric. Full routing elements prove the delay increase.

The path is legitimate video control: [shadowmask.sv:96](../register_memory_auto/baseline/sys/shadowmask.sv#L96) shifts VS/HS/DE in vid; outputs come from vid[11:9] at line116. [sys_top.v:1159–1196](../register_memory_auto/baseline/sys/sys_top.v#L1159) connects those outputs into hdmi_osd. [osd.v:238–245](../register_memory_auto/baseline/sys/osd.v#L238) updates osd_div under that video control. The critical RAM is the existing shadowmask shift-register RAM, not RegisterMemory. The new FM M10K is at X76/Y9 in seed1 (X76/Y22 in seed2); it does not occupy the displaced shadowmask's old location. A direct one-block site collision is not supported.

### Seed 2 AUTO: deeper luminance cone and missing retiming

The worst path traverses pixel components into scaler poly_lum, whose [ascal.vhd:1128–1151](../register_memory_auto/baseline/sys/ascal.vhd#L1128) computes max(R,G,B) with two comparisons and selection. The adaptive luminance assignments are at lines2413–2418; input pipeline assignment is at line2976. AUTO's detailed path includes LessThan27, v~1, LessThan28 and o_poly_lum selection logic, ending in o_poly_lum[6].

| Luminance family minimum | Cell ns | Routing ns | Data ns | Levels | Skew ns | Slack ns |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
`;
for(const t of tags){const x=r[t].families.poly_lum[0];s+=`| ${label(t)} | ${num(x.cell)} | ${num(x.ic+x.routingElements)} | ${num(x.data)} | ${x.levels} | ${num(x.skew)} | ${num(x.slack)} |\n`;}
s+=`\nSeed2 family degradation is 1.529→0.019 ns (−1.510). The data delay increases 4.852→6.413 ns (+1.561), mostly cell delay (+1.602); routing actually decreases about0.042 ns. Skew improves by0.051 ns. Thus this result cannot be explained as simply worse routing or clock skew. Baseline and AUTO logic boundaries differ because of physical retiming.

## Repeatable global physical-synthesis difference

All four QSFs enable PHYSICAL_SYNTHESIS_REGISTER_RETIMING, register duplication, combinational physical synthesis and HIGH PERFORMANCE EFFORT. The first register-retiming pass reports estimated improvement279 ps in both baselines, versus0 ps in both AUTO builds; subsequent pass0 ps in all four. These estimates are optimizer diagnostics, not final slack improvements.

| Fitter Netlist Optimizations report entries | Seed 1 baseline | Seed 1 AUTO | Seed 2 baseline | Seed 2 AUTO |
| --- | ---: | ---: | ---: | ---: |
`;
for(const [key,name]of [['retimedRows','Retimed Register, whole design'],['scalerRetimedRows','Retimed Register, ascal'],['luminanceRetimedRows','Retimed Register, luminance-related']])s+=`| ${name} | ${tags.map(t=>e[t][key]).join(' | ')} |\n`;
s+=`\nCounts are transformation-report rows, not a new physical FF utilization metric. Baseline entries explicitly mark o_poly_lum[6]_OTERM251/253/255/257 and other o_poly_lum/o_h_lum_pix registers as Retimed Register / Physical Synthesis / Timing optimization. AUTO contains no such entries anywhere. The actual baseline critical luminance endpoints are live OTERM registers in the timing netlist. See selectedTransformationRows and optimizationMessages in implementation_evidence.json.

Confidence is high that the retained implementations differ in physical retiming and that this affects luminance depth. The logs do **not** disclose why the one-line RAM inference change makes Quartus's heuristic choose no retiming. A compiler heuristic interaction, rather than a logical dependency between FM and HDMI, is plausible but its internal decision is unverified. No compiler bug, global retiming prohibition caused by M10K, or universally reproducible cause beyond these two seeds is established.

## RegisterMemory and FM are not the global setup bottleneck

| Minimum constrained setup slack ns | Seed 1 baseline | Seed 1 AUTO | Seed 2 baseline | Seed 2 AUTO |
| --- | ---: | ---: | ---: | ---: |
`;
for(const [key,name]of [['register_from','From RegisterMemory timing nodes'],['register_to','To RegisterMemory timing nodes'],['fm_from','From FM timing nodes'],['fm_to','To FM timing nodes']])s+=`| ${name} | ${tags.map(t=>`[${num(r[t].local[key][0].slack)}](${r[t].local[key][0].file})`).join(' | ')} |\n`;
s+=`\nThese queries include RAM internal timing nodes; their collection sizes are not fitted FF counts. RegisterMemory paths use the core PLL domain, relationship18.626 ns, not the HDMI6.732 ns domain. AUTO does alter local RAM-access timing (e.g. seed1 minimum from-bank slack10.159→8.171 ns), but it remains far from the whole-design limit. All top20 global paths are saved; none traverses the FM bank. The HDMI-versus-core clock groups are exclusive in the existing SDC.

## Constraints and critical warnings

The source SDC SHA256 is identical in all four builds: 0a5fa4015b82ad7ce38e56d1ae4aadea6209af59c5dd9eff56a11139cf16ce86. report_sdc and report_sdc -ignored are retained for each implementation; all report no ignored SDC constraints. Effective PLL clocks and0.200 ns uncertainty are unchanged. Detailed report timing was reproduced exactly from copied DBs, so the regression is not a different-corner or stale-summary artifact.

Existing OSD multicycle exceptions target *_osd|osd_vcnt* (setup2/hold1), not osd_div. All four worst paths are single-cycle. Existing scaler false paths target configuration inputs, not the measured o_vpix_inner→o_poly_lum or o_hcpt→o_vcpt_pre3 paths. Broad existing clock-group/configuration/IO exceptions and unconstrained external IO limit overall signoff scope, but do not explain the measured intra-HDMI A/B difference. report_exceptions lists existing false-path and partially overridden multicycle statuses; these are not new AUTO warnings or grounds to waive the critical paths.

All four original result sets count38 critical warnings, with unchanged critical-warning content after normalizing build paths. They concern ignored VDP register power-up levels (18061/18010), not the measured HDMI data paths. The only normalized warning additions in AUTO are the expected synthesized-away RAM header and unused RegisterMemory columns14/15. Existing fitter warnings include audio PLL LOCKED connection21300, ignored fast-IO assignments176250/176251, invalid assignments171167 and LogicLock subscription warning292013. None identifies an AUTO-only clock/constraint error that accounts for this regression. LogicLock is therefore not an assumed available remedy in this Lite installation.

## Consistency, limits and stopping point

The **global setup loss and lack of reported retiming are consistent across both seeds**. The global worst endpoint, data routing and size of luminance loss are strongly implementation-dependent. Shadowmask→OSD family slack varies0.146→1.865 ns between AUTO seeds; luminance varies0.960→0.019 ns. Counter-family timing improves in both AUTO builds. Average global interconnect rises in both AUTO pairs while total peak usage falls; those aggregate figures alone cannot diagnose either path.

Do not treat seed selection alone as evidence that the margin issue is solved. Do not relax HDMI period/uncertainty or invent an OSD multicycle to conceal a legitimate single-cycle path. Do not change RegisterMemory latency, reset/collision semantics or savestate behavior to address a path that does not traverse it. Recovering video retiming/locality is the least invasive target, but no validated remedy preserving both the full area saving and timing margin exists in these four databases.

This report stops before implementation-experiment design or execution. Review the timing evidence, available implementation-control mechanisms and the acceptable area-versus-margin target first. PhaseMemory, v19, the independent branch, original fitted DBs, RTL, constraints, settings and seeds remain preserved; [preservation_after.json](preservation_after.json) verifies 6,869 protected files (including original databases) and 126 branch refs, with zero mismatches.
`;
fs.writeFileSync(p.join(d,'review.md'),s);console.log('Wrote detailed timing report.');
