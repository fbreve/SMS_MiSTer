const fs=require('fs'),p=require('path'),cp=require('child_process'),assert=require('assert'),d=__dirname,r=require('./paired_results.json'),pre=require('./preflight.json'),pc=require('./path_comparison.json'),ps=require('./physical_path_summary.json'),rd=require('./register_delta.json'),paths=require('./paths.json');
const b=r.builds.baseline2,c=r.builds.candidate2,table=(h,rs)=>'| '+h.join(' | ')+' |\n| '+h.map(()=> '---').join(' | ')+' |\n'+rs.map(row=>'| '+row.map(x=>String(x).replaceAll('|',' / ')).join(' | ')+' |').join('\n');
const regGate=rd.passed&&rd.intendedBankRemoved===230&&r.delta.synthesisRegisters===-230;r.gates.intended230RegisterRemoval=regGate;r.physicalGate=Object.values(r.gates).every(Boolean);fs.writeFileSync(p.join(d,'paired_results.json'),JSON.stringify(r,null,2));let pass=r.physicalGate,failed=Object.entries(r.gates).filter(([k,v])=>!v).map(([k])=>k),verdict=pass?'SEED-2 PAIRED DIAGNOSTIC PASS; NO PRODUCTION PROMOTION':'REJECTED / NOT A QUALIFIED PAIRED IMPROVEMENT';
let metricNames={needed:'Needed ALMs',placed:'Placed ALMs',synthesisRegisters:'Mapped FF',registers:'Fitted FF',logicALUT:'Logic ALUT',routingALUT:'Routing ALUT',M10K:'M10K',memoryBits:'Block memory bits',DSP:'DSP',recoverable:'Recoverable ALMs',unavailable:'Unavailable ALMs',setup:'Worst setup ns',hold:'Worst hold ns',violations:'Reported violating timing groups'};
let metricTable=table(['Metric','Baseline seed2','Candidate seed2','Candidate minus baseline'],Object.entries(metricNames).map(([k,label])=>[label,b[k],c[k],Number(r.delta[k].toFixed(3))]));
let groups=[...new Set([...b.timing,...c.timing].map(x=>x.type))];let timingTable=table(['Type / full clock group','Baseline slack','Candidate slack','Baseline TNS','Candidate TNS'],groups.map(g=>{let x=b.timing.find(x=>x.type===g),y=c.timing.find(x=>x.type===g);return[g,x?.slack,y?.slack,x?.tns,y?.tns]}));
let timingCounts=table(['Build','Check','Violating physical endpoints','Endpoint TNS ns','Endpoints queried'],Object.entries(pc.counts).flatMap(([name,modes])=>Object.entries(modes).map(([mode,v])=>[name,mode,v.violatingEndpoints,v.tns,v.reportedEndpoints])));
let q=(k,kind)=>paths[k+'_'+kind]?.[0],pathTable=table(['Build / query','Slack ns','From','To','Data ns','Skew ns'],['baseline2','candidate2'].flatMap(k=>['all_setup','all_hold','hdmi_setup','core_setup','dir','alias','controls'].filter(t=>q(k,t)).map(t=>{let x=q(k,t);return[k+' '+t,x.slack,x.from,x.to,x.delay,x.skew]})));
let match=ps.matched,matchedTable=match?table(['Matched path metric','Baseline2','Candidate2'],[['Endpoint',match.to,match.to],['Slack ns',match.baseline.slack,match.candidate.slack],['Data delay ns',match.baseline.delay,match.candidate.delay],['Skew ns',match.baseline.skew,match.candidate.skew],...['baseline','candidate'].flatMap(()=>[])]):'No exact physical endpoint match found; see complete restricted query sets.';
let detail=match?['baseline','candidate'].map(k=>'### '+k+' matched route\n\n'+table(['Location','Cell/pin','Incremental cell delay ns','Reported fanout'],match[k].coords.map(x=>[x.location,x.element,x.delay,x.fanout]))+'\n\n'+table(['Physical data delay class','Value','Count','Total delay ns'],match[k].delayRows.map(x=>x.slice(0,4)))+'\n\nRouting sequence: '+match[k].dataRoutes.map(x=>x.location+' ('+x.type+', '+x.delay+'ns)').join('; ')+'.\n').join('\n'):'';
let elapsed=table(['Build','Stage','Wall','Aggregate CPU','Peak virtual MB'],['baseline2','candidate2'].flatMap(k=>Object.entries(r.builds[k].elapsed).map(([stage,t])=>[k,stage,t.wall,t.cpu,t.peakVirtualMB])));
let diff=cp.execFileSync('git',['--no-optional-locks','diff','--stat']).toString().trim(),index=cp.execFileSync('git',['--no-optional-locks','diff','--cached','--stat']).toString().trim(),status=cp.execFileSync('git',['--no-optional-locks','status','--short']).toString().trim();assert.equal(diff,'');assert.equal(index,'');
let text=`# v19 CPU restore-output alias: one paired seed-2 experiment

**${verdict}.** ${pass?'The seed-2 pair passes all listed physical gates.':'Failed gates: '+failed.join(', ')+'.'} The seed-1 candidate remains failed. No production promotion is authorized or performed, regardless of this pair's outcome. Exactly two fresh implementations ran: original v19 seed2, then the retained alias seed2, sequentially on the same host.

## Verified source, qualification and configuration

Read the complete [original experiment](../cpu_restore_output_alias/review.md) and [timing diagnosis](../cpu_restore_alias_timing_diagnosis/review.md). HEAD remains **${pre.head}**, branch **${pre.branch}**, savestate **v19 / tag0x484313**. [preflight.json](preflight.json) and [preflight.js](preflight.js) verify all204 tracked hashes, both137-input retained seed1 manifests, retained evidence and the existing40-case qualification before preparing the new builds. The old baseline manifest's historical HEAD label is not substituted for its actual verified v19 source contents.

The40 cases' log hashes, terminal pass/error markers, compiled controller/real consumer/test sources, fixture hashes, source bridges, complete196608-word image hash and qualification ledger were checked. Qualified totals remain **91413628 host clocks,209 consuming edges,495599 accepted writes and1591538 accepted reads**. All eight NMI triplets remain covered. The same 230-bit consuming-edge equality, native CPU/NMI/restart, compatibility, late rejection, transport-stall, SAVE-only, repeated LOAD, dual-VDP and Pause proof remains applicable. No tests were changed, weakened, masked or replaced; simulations were not rerun for a seed-only physical change. The existing ledger is source-bound, not a claim of new post-route functional simulation.

The retained candidate was copied byte-for-byte; no RTL variant was created. Its reverse transformation reproduces the original controller: output reg becomes wire, continuous z80_dir=z80_snap is added, and the sole registered copy assignment is removed. All snapshots, other output registers, z80_set, image bytes, public readers, DDR transport and constraints remain unchanged.

| Source / input | SHA256 |
| --- | --- |
| Original controller | ${pre.baselineSHA} |
| Existing alias controller | ${pre.candidateSHA} |
| Retained40-case ledger | ${pre.functionalGateSHA} |
| Common seed2 SMS.qsf | ${require('./build_baseline2_inputs.json').inputs['SMS.qsf']} |
| Common build_id.v | ${require('./build_baseline2_inputs.json').buildIdSHA} |

[build_baseline2_inputs.json](build_baseline2_inputs.json) and [build_candidate2_inputs.json](build_candidate2_inputs.json) contain every input hash. Baseline2 differs from the retained seed1 source tree only by SEED1->2 in SMS.qsf. Candidate2 differs from that same tree by the identical seed edit and exact retained controller. **Between the two new builds, the only input difference is rtl/savestates.sv**; all other136 inputs and build_id match. Fresh databases were used; no seed1 database was copied or rebuilt.

Quartus **17.0.2 Build602 Lite**, Cyclone V **5CSEBA6U23I7**, SMS/sys_top, **SEED2**, BUILD_DATE **261025**, MISTER_FB=1; same QSF/SDC/QIP/IP, STANDARD FIT, HIGH PERFORMANCE EFFORT, SPEED, final placement ALWAYS, LOW ALM register packing, NORMAL automatic packing and enabled physical optimization/duplication/retiming/router duplication. Both executions used one PowerShell process with unchanged inherited tool environment on the same host. [environment.json](environment.json) records host/tool executable hashes; all eight stage logs identify tool version and configuration. No seed3, alternate RTL, retry fit or changed constraints were used.

## Complete implementations and retained evidence

[build_pair.ps1](build_pair.ps1) runs map, fit, asm and sta for A, then the same four stages for B. Every stage returned success and completed its report. Tool success is distinguished from the timing/physical gate below. [workflow.log](workflow.log) records starts, ends and exit codes. Full source-isolated trees, databases, programming outputs, logs and reports remain in [quartus_baseline2](quartus_baseline2/) and [quartus_candidate2](quartus_candidate2/). Input manifests are rechecked after compilation and read-only timing queries.

${elapsed}

No paired comparison uses seed1 as its denominator. The former seed1 failure remains historical evidence and is not overwritten or waived by these measurements.

## Paired resource and timing measurements

${metricTable}

Packing identities: baseline **${b.placed}-${b.recoverable}+${b.unavailable}=${b.needed}**; candidate **${c.placed}-${c.recoverable}+${c.unavailable}=${c.needed}**. Needed versus placed, logic versus routing ALUT, and source versus fitted registers are distinct measures; none is added to another as an independent ALM saving.

${table(['Final interconnect utilization','Baseline2 total / H / V','Candidate2 total / H / V'],[['Average %',b.routingAverage.join(' / '),c.routingAverage.join(' / ')],['Peak %',b.routingPeak.join(' / '),c.routingPeak.join(' / ')]])}

Final utilization is taken from the fitter's final average/peak rows, not preliminary router estimates. Routing gates below check total/H/V components without hiding a directional increase. All original rows are retained in paired_results.json and the fit reports.

${table(['Gate','Result'],Object.entries(r.gates).map(([k,v])=>[k,v?'PASS':'FAIL']))}

Both positive setup/hold and zero reported violations are required; if the baseline fails, a passing candidate is not a qualified paired improvement. ${b.setup<=0||b.hold<=0||b.violations?'That baseline limitation applies here.':'The baseline passes these reported timing checks.'}

## Timing groups, TNS and violating endpoints

The configured STA reports identify **Slow1100mV100C** with final timing models. The same existing constraints/model and query definitions are used on both sides; this is not additional multi-corner signoff or a repair of inherited unconstrained categories. The compiled reports retain all configured setup, hold, recovery, removal and pulse-width groups:

${timingTable}

[query.tcl](query.tcl) and [query.ps1](query.ps1) perform only read-only TimeQuest netlist loading, SDC evaluation, timing reports and name/location queries after both implementations finish. Global setup/hold lists use -npaths1000 -nworst1; core/HDMI and restricted cones use -npaths50 -nworst1 with full routing detail. One worst path is retained per physical endpoint, including actual duplicates. The global lists extend beyond all negative endpoints, so their negative count is bounded rather than inferred from a truncated failing list. No extra synthesis, fit or route was run for these queries.

${timingCounts}

[path_comparison.json](path_comparison.json) records negative counts and endpoint TNS by capture clock. [paths.json](paths.json), *_all_setup.txt and *_all_hold.txt retain endpoint identities; [path_comparisons.md](path_comparisons.md) lists matched and ranked detailed queries. TNS reconciliation is checked against the compiled summary; tied ranks are not assumed identical. Overlapping global, group and restricted lists are not added together.

## Matched HDMI shadowmask-to-OSD and CPU paths

${pathTable}

Restricted shadowmask ram_block5a0->h_cnt and ->dsp_width queries establish **${pc.matched.hcnt.length} exact h_cnt** and **${pc.matched.width.length} exact dsp_width** start/end matches. Names with different duplicate suffixes are not silently merged. The following chooses the worst candidate path with an exact baseline endpoint match, allowing a concrete routed logical-path comparison. Full pin traces identify the memory output and receiver control pin; generated LUT spelling and placements may change under physical optimization.

${matchedTable}

${match?'For this matched pair, candidate-minus-baseline data delay is **'+(match.candidate.delay-match.baseline.delay).toFixed(3)+'ns**, skew change **'+(match.candidate.skew-match.baseline.skew).toFixed(3)+'ns**, slack change **'+(match.candidate.slack-match.baseline.slack).toFixed(3)+'ns**. This is an exact-pair observation, not a decomposition of unrelated global worst endpoints.':''}

${detail}

Read-only register-location metadata and the detailed routing sequences retain the physical RAM, clear-decode LUT and endpoint locations. Routing-element count/delay and clock skew are observed physical quantities, not proof of a particular congestion cause. Differences in matched route placement do not by themselves isolate which fitter decision produced them.

Baseline dir->T80 and candidate snap->T80 queries inspect the actual restore-data launch bank. Baseline snap may have no direct T80 path because it first enters the output holding register; an empty baseline alias set is not an omitted consumed path. Direct data and z80_* control envelopes are shown separately above. Comparing different worst endpoints does not claim a matched-bit speedup. All original consumer-edge proof and source equality remain unchanged; reported timing gates independently determine whether an implementation is eligible.

## Register removal and warnings

${table(['Fitted named bank','Baseline2','Candidate2'],[['Original z80_snap nodes',rd.registers.baseline2.snapshot.length,rd.registers.candidate2.snapshot.length],['Separate z80_dir nodes',rd.registers.baseline2.dir.length,rd.registers.candidate2.dir.length],['Controller own timing-register nodes',rd.registers.baseline2.controllerOwnNodes,rd.registers.candidate2.controllerOwnNodes]])}

The target230 z80_dir holding FFs disappear only in candidate2; the230-bit snapshot remains. Mapped whole-design delta is **${r.delta.synthesisRegisters}**. Fitted whole-design delta **${r.delta.registers}** can differ because of unrelated physical duplication/retiming/packing. [register_delta.json](register_delta.json) retains every controller stem and changed name count; full name/location lists retain other physical allocations. Child RAM timing nodes are not mistaken for dedicated controller FFs.

Unique compiled critical-warning messages: **${b.criticalWarnings}->${c.criticalWarnings}**. New normalized candidate critical warnings: **${r.newCritical.length}**. Build-root paths/source-line annotations are normalized, with complete raw warning lists and normalization logic retained in paired_results.json and collect.js. Inherited unconstrained setup/hold categories remain disclosed. New critical messages:

\x60\x60\x60text
${r.newCritical.join('\n')||'(none)'}
\x60\x60\x60

## Interpretation, disposition and limitations

**${verdict}.** ${pass?'This bounded seed2 pair satisfies the listed area/routing/timing/warning/FF gates. It demonstrates feasibility for this one paired seed, not robust success across seeds.':'The seed2 physical gates are not all met; this candidate implementation is retained as rejected evidence. Functional equivalence and removal of230 mapped FFs do not override a failed physical gate.'} ${!r.gates.bothPositiveTiming?'Negative reported setup or hold is not accepted.':''} ${!r.gates.lowerPlaced?'The candidate has no paired placed-ALM saving.':''}

One pair cannot establish statistical confidence, repeat-fit determinism or intrinsic CPU-alias slowness. An HDMI failure is assessed through matched physical routes rather than attributed to the CPU solely by temporal association. Seed1 remains failed. Even a fully favorable seed2 pair cannot authorize promotion or an unpaired favorable-seed substitution. Further robustness work requires separate authorization; no further seed or variant is launched here.

Production RTL, savestate bytes/compatibility, constraints, IP, branch, HEAD and index remain unchanged. Existing untracked tests, reports, seed1 implementations and candidate evidence are preserved. New outputs are confined to tests/cpu_restore_alias_seed2_pair/. No checkout/reset/clean/commit/push/merge/PR or deployment occurred.

Final git diff --stat:

\x60\x60\x60text
${diff||'(empty)'}
\x60\x60\x60

Final git status --short:

\x60\x60\x60text
${status}
\x60\x60\x60

**Stop after this single pair and await review.**
`;
fs.writeFileSync(p.join(d,'review.md'),text);fs.writeFileSync(p.join(d,'DISPOSITION.md'),'# Isolated physical experiment only\n\n'+verdict+'. Production unchanged. Seed1 remains failed. Do not promote either programming output; no further implementation is authorized.\n');console.log(verdict,failed);
