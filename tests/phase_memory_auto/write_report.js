const fs=require('fs'),p=require('path'),assert=require('assert');const d=__dirname,r=JSON.parse(fs.readFileSync(p.join(d,'results.json'))),a=r.builds.baseline,b=r.builds.candidate;
assert(Object.values(r.simulations).every(x=>x.pass),'Incomplete simulation qualification');
const phase=m=>{const c=m.phaseHierarchy[0];assert(c,'Missing fitted PhaseMemory row');return {needed:c[1],placed:c[2],FF:c[7],bits:c[9],M10K:c[10]};};
const worst=(m,t)=>Math.min(...m.timing.filter(x=>x.type.startsWith(t)).map(x=>x.tns));
const n=x=>Number(x.toFixed(3)),signed=x=>(x>=0?'+':'')+n(x),pa=phase(a),pb=phase(b);
const paths=JSON.parse(fs.readFileSync(p.join(d,'path_results.json')));
let clocks='| Timing group | A slack / TNS (ns) | B slack / TNS (ns) |\n| --- | ---: | ---: |\n';
for(const c of a.timing.filter(x=>/^(Setup|Hold)/.test(x.type))){const q=b.timing.find(x=>x.type===c.type);assert(q,'Timing group changed');clocks+=`| ${c.type.replaceAll('|',' / ')} | ${c.slack} / ${c.tns} | ${q.slack} / ${q.tns} |\n`;}
fs.writeFileSync(p.join(d,'timing_table.md'),clocks);
const pass=b.setup>=0&&b.hold>=0&&b.violations===0;
const conclusion=pass&&r.delta.placed<0?'The AUTO change is a measured whole-design area improvement for this matched seed-1 pair, with passing reported timing. Keep it experimental; a paired second seed and hardware validation are appropriate before production adoption.':pass?'AUTO inference is functionally qualified in the tested scope and reported timing passes, but this pair does not establish a placed-ALM improvement. Do not promote it as an area optimization.':'Do not promote this candidate: the physical/timing qualification failed despite successful RAM inference. Retain it only as experimental evidence.';
const simRows=Object.entries(r.simulations).map(([k,v])=>`| [${k}.log](${k}.log) | PASS | ${v.passLine.join(' ').replace(/^# /,'').replaceAll('|',' / ')} |`).join('\n');
fs.writeFileSync(p.join(d,'review.md'),`# PhaseMemory automatic RAM inference experiment

Date: 2026-10-29 (America/Sao_Paulo). Baseline: \`8443a0d19a88aff7a5900011bccf386daf146945\`. Branch: \`experiment/phasememory-auto-inference\`.

## Result and recommendation

${conclusion}

Whole-design candidate minus fresh baseline: **${signed(r.delta.placed)} placed ALMs, ${signed(r.delta.needed)} needed ALMs, ${signed(r.delta.registers)} fitted registers, ${signed(r.delta.M10K)} M10K**. Setup/hold slack: **${b.setup}/${b.hold} ns**, versus ${a.setup}/${a.hold} ns. Setup/hold TNS: **${worst(b,'Setup')}/${worst(b,'Hold')} ns**. These are measured implementation results, not estimates from the local bank. No RegisterMemory or other bank was changed or tested as an optimization.

## Scope and reproducibility

The sole production change removes \`attribute ramstyle of phase_array : signal is "logic";\` from [rtl/VM2413/phasememory.vhd](../../rtl/VM2413/phasememory.vhd), originally line52. The declaration and all functional RTL remain unchanged. [production.diff](production.diff) records the one-line deletion. No explicit M10K/MLAB attribute or inference-template rewrite was attempted: AUTO succeeded.

Fresh source-only A and B builds used Quartus Prime Lite **17.0.2 Build602**, device **5CSEBA6U23I7**, revision SMS, top sys_top, seed1, fixed BUILD_DATE261014, MISTER_FB=1, original QSF/QIP/SDC/IP and unchanged performance/packing settings. Both started without databases. Direct map/fit/asm/sta stages bypassed only the date-generating preflow. The source manifests hash all203 tracked file blobs; only PhaseMemory differs. See [input_manifest.json](input_manifest.json), [build.ps1](build.ps1), [workflow.log](workflow.log), and [reproduction instructions](reproduce.md).

The fresh A reproduces timing-history F **exactly for every compared global resource count and setup/hold slack**; [results.json](results.json) records zero deltas in baselineVsRetained. F was a control-reproduction reference; B was compared with the newly compiled A, not a substituted historical build. Identical metric endpoints do not imply identical timestamps/report bytes.

## Functional and mapped equivalence

| Evidence | Result | Recorded coverage |
| --- | --- | --- |
${simRows}

The bank RTL comparison includes an independent old-data/one-clock-latency scoreboard. It checks all18 addresses, all18 payload bit positions, initialization write priority, output hold during reset and between clocks, repeated resets, short reset pulses, interruption after every0..18 startup writes, deterministic random traffic and same-address collisions. Original unknown startup values are checked exactly in RTL; they are not coerced to zero. The mapped comparison checks every baseline-defined value while allowing unspecified hardware power-up payload to differ.

The mapped model is Quartus's exported standalone synthesis functional netlist with bundled vendor RAM models, not a hand-written RAM substitute. Its top module is renamed only. The complete OPLL mapped test replaces only its PhaseMemory instance, leaving all other bank RTL unchanged, and compares audio every cycle. It exercises all16 instruments/nine channels, rhythm keys, irregular enables,1152 freeze-phase cases and19 reset interruption cuts. This is functional mapped simulation, not post-route timing simulation or a hardware test.

Eight RTL save/load cases compare all58 controller outputs and accepted DDR behavior, with CPU/VDP/PSG roundtrip assertions, both physical video owners, BIOS/cartridge slots and DDR backpressure. The mapped integration test uses a single real controller and two deterministic passes: record native OPLL audio, then replay the identical controller/DDR stimuli with mapped PhaseMemory and compare every sample. Its representatives are SMS/cartridge/slot0 and SystemE/BIOS/slot3 with stalls. FM is programmed and warmed before capture; nonzero-audio coverage is required. The native900,000-cycle load flush remains intact. Only the UI request cooldown is bypassed in the fixture.

ModelSim10.5b portability adapters are simulation-only and symmetric: scalar subtype ranges are expanded without changing bounds, missing std_logic meta-value cases get null branches, and two controller declarations move before their uses. Production/source-only Quartus builds use neither adapter. The unadapted bank test separately checks startup unknown semantics.

Preliminary fixture diagnostics are retained: the initial DDR busy cadence starved the controller's intentional32-idle-clock drain; the first DDR mock omitted BIOS slots; oracle checking needed a continuous-assignment delta-cycle correction and an explicit warmup before the first freeze. These were testbench defects, not candidate failures. Final traces/logs above supersede those attempts. Capacity-limited interrupted ModelSim runs are not counted as passes.

This baseline has no complete serialized OPLL history interface. Preserving its behavior does not fix or prove stronger exact-FM savestate behavior introduced on later branches. The verified result is no new difference in the tested baseline execution/save-load scenarios; v19 hooks and format are not imported.

## Memory inference and local allocation

A explicitly reports four uninferred FM RAMs due to the logic attribute. B reports three: OutputMemory, FeedbackMemory and RegisterMemory remain unchanged. B adds **18×18=324 configured bits** as \`phase_array_rtl_0\`, simple dual-port, same clock. The inferred parameters retain **OLD_DATA** for mixed-port read/write collisions. Registered addressing/enable logic implements the original one-clock read and reset hold; interpreting OUTDATA_REG=UNREGISTERED alone as an asynchronous RTL interface would be incorrect. Mapped simulations independently validate the resulting latency/hold behavior.

| PhaseMemory fitted allocation | A | B |
| --- | ---: | ---: |
| Needed ALMs | ${pa.needed} | ${pb.needed} |
| Placed ALMs | ${pa.placed} | ${pb.placed} |
| Dedicated FF | ${pa.FF} | ${pb.FF} |
| Configured memory bits | ${pa.bits} | ${pb.bits} |
| M10Ks | ${pa.M10K} | ${pb.M10K} |

The whole-design mapped-register delta is${r.delta.synthesisRegisters};324 payload bits plus18 read-output registers leave ordinary FF implementation. Fitted FF changes also include physical transformations elsewhere. Fractional local ALMs are hierarchy allocations, not a separately removable whole-chip delta. The local experiment export is not used as the whole-design resource result.

## Whole-design Quartus A/B

${fs.readFileSync(p.join(d,'comparison_table.md'),'utf8')}

Reported setup TNS A/B: ${worst(a,'Setup')}/${worst(b,'Setup')} ns; hold TNS A/B: ${worst(a,'Hold')}/${worst(b,'Hold')} ns. Per-clock setup/hold slack and TNS are retained in [timing_table.md](timing_table.md). The original full STA summaries and reports remain under baseline/output_files and candidate/output_files. Inherited unconstrained categories remain: A ${a.unconstrainedInfo.join(', ')}, B ${b.unconstrainedInfo.join(', ')}. Passing reported slack is not fully constrained hardware signoff.

M10K utilization is${a.M10K}/553 → ${b.M10K}/553; nominal free blocks${553-a.M10K} → ${553-b.M10K}. MLAB memory bits${a.MLABbits} → ${b.MLABbits}; DSP blocks${a.DSP} → ${b.DSP}. No MLAB alternative was attempted. The additional324 logical bits are the same phase payload moved into hard memory, not a change in functional state size or save format.

Routing ALUTs${a.routingALUT} → ${b.routingALUT}. Final interconnect rows:

\`\`\`text
A:
${a.finalInterconnect.map(x=>x.trim()).join('\n')}
B:
${b.finalInterconnect.map(x=>x.trim()).join('\n')}
\`\`\`

Detailed routing-resource rows, warning ledgers, full timing groups, fitted PhaseMemory rows, inferred RAM parameters and report hashes are in [results.json](results.json). Normalized warning messages added/removed: ${r.warningComparison.added.length}/${r.warningComparison.removed.length}; the ledgers are unchanged after normalizing build-directory paths. Global physical remapping can move allocation and routing in unchanged modules; local bank savings must not be substituted for these whole-design deltas. Placed area falls253 ALMs (about0.80%), but setup margin falls13ps and average interconnect use rises0.4 percentage points. Peak total/H utilization falls while peak V rises. This is a modest, mixed physical result, not a universal routing/timing improvement.

## Supplemental path queries and tooling limitation

The global setup limiter remains in the scaler: A line-store write-enable → inner vertical-pixel register, B line-store write-enable → outer vertical-pixel register. A's worst hold is scaler phase-pipeline state; B's is the savestate controller's nvram_load_addr[2] self path. Neither setup limit is in PhaseMemory. [path_results.json](path_results.json) retains exact endpoints and the source report names.

| Restricted register-path setup slack (ns) | A | B |
| --- | ---: | ---: |
| From FM | ${paths.registerQueries.baseline.fm_from} | ${paths.registerQueries.candidate.fm_from} |
| To FM | ${paths.registerQueries.baseline.fm_to} | ${paths.registerQueries.candidate.fm_to} |
| From PhaseMemory | ${paths.registerQueries.baseline.phase_from} | ${paths.registerQueries.candidate.phase_from} |
| To PhaseMemory | ${paths.registerQueries.baseline.phase_to} | ${paths.registerQueries.candidate.phase_to} |

These are bounded register-collection queries at the default reported slow1100mV100C corner, not identical endpoint pairs or replacements for full STA. Memory-port sequential nodes in get_registers are not the fitted dedicated-FF accounting column.

The first supplemental candidate query completed its global setup/hold reports, then Quartus17.0.2 crashed while expanding get_keepers wildcards. [candidate_paths.log](candidate_paths.log) retains the access violation in sta_find_duplicates_of_deleted_net_name / add_keeper_to_vector_if_wildcard_matches. This happened after the successful full map/fit/asm/sta compilation. No synthesis settings or RTL were changed to address it. A narrower get_registers query then completed for both builds with zero errors/warnings, retaining the local paths above. [register_paths.tcl](register_paths.tcl) and [query_register_paths.ps1](query_register_paths.ps1) reproduce that successful query. The crashed keeper query is diagnostic evidence, not a pass or a failed full compilation.

## Repository state and stopping point

Protected refs are unchanged: master8443a0d, investigate/synthesis-structure8443a0d, investigate/cram-memory-inference1b2a52d. The experimental branch still has baseline HEAD and the one-line uncommitted RTL deletion. Existing audit/report hashes checked by [preservation_before.json](preservation_before.json) remain unchanged. New supporting scripts, logs and reports are under this directory; databases/build trees are ignored and unstaged. No commit, merge, push or PR was made. No other bank or second seed was attempted. Stop here for review; any further experiment or adoption requires separate authorization.
`);
console.log(JSON.stringify({recommendation:conclusion,phase:{baseline:pa,candidate:pb},delta:r.delta},null,2));
