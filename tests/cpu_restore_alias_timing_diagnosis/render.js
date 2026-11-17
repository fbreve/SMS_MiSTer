const fs=require('fs'),p=require('path'),crypto=require('crypto'),cp=require('child_process'),assert=require('assert'),d=__dirname,root=p.resolve(d,'../..');const sha=b=>crypto.createHash('sha256').update(b).digest('hex'),read=f=>{let b=fs.readFileSync(f);return b.toString(b[0]===255?'utf16le':'utf8')};
const paths=require('./paths.json'),cmp=require('./comparison.json'),cost=require('./hierarchy_deltas.json'),measure=require('../cpu_restore_output_alias/measure');
let builds={baseline:p.join(root,'tests/savestate_g08_fm/quartus_early'),candidate:p.join(root,'tests/cpu_restore_output_alias/quartus_candidate1')};let m=Object.fromEntries(Object.entries(builds).map(([k,v])=>[k,measure(v)]));
let original=require('../cpu_restore_output_alias/candidate1_results.json');for(let k of Object.keys(builds)){assert.deepEqual(m[k].hashes,original[k].hashes);let manifest=require(k==='baseline'?'../savestate_g08_fm/build_early_inputs.json':'../cpu_restore_output_alias/build_candidate1_inputs.json');assert.equal(sha(fs.readFileSync(p.join(builds[k],'build_id.v'))),manifest.buildIdSHA);}
fs.writeFileSync(p.join(d,'metrics.json'),JSON.stringify(m,null,2));
let evidence={};for(let dir of ['tests/savestates_internal_cost_audit','tests/cpu_restore_output_alias'])for(let f of fs.readdirSync(p.join(root,dir))){let q=p.join(root,dir,f);if(fs.statSync(q).isFile()&&/\.(json|md|tcl|ps1|js|txt|tsv)$/.test(f)){let b=fs.readFileSync(q);if(f.endsWith('.json'))JSON.parse(b.toString());evidence[dir+'/'+f]=sha(b);}}
fs.writeFileSync(p.join(d,'retained_evidence_hashes.json'),JSON.stringify(evidence,null,2));
let short=x=>x.replace('emu:emu|system:system|','').replace('emu:emu|savestates:savestates_inst|','savestates|');
let table=(heads,rows)=>'| '+heads.join(' | ')+' |\n| '+heads.map(()=> '---').join(' | ')+' |\n'+rows.map(r=>'| '+r.map(x=>String(x).replaceAll('|',' / ')).join(' | ')+' |').join('\n');
let appendix='# Timing-path comparison ledger\n\nEvery query uses -npaths 50 -nworst 1. One worst path per physical endpoint, not 50 variants of one endpoint. Full names, detailed delays and routes are in paths.json and matching text files. Different tied paths can rank differently.\n\n';
for(let kind of ['hdmi_setup','core_setup','hdmi_hold','core_hold','cpu_all_setup','cpu_restore_setup','cpu_restore_hold','crc','sdram','hcnt','width','dir','alias','snapdir_setup','snapdir_hold']){appendix+='## '+kind+'\n\n';for(let k of ['baseline','candidate']){let a=paths[k+'_'+kind];if(!a)continue;appendix+='### '+k+'\n\n'+table(['Rank','Slack ns','From','To','Skew ns','Data ns'],a.map((x,i)=>[i+1,x.slack,short(x.from),short(x.to),x.skew,x.delay]))+'\n\n';}}
fs.writeFileSync(p.join(d,'path_comparisons.md'),appendix);
let types=[...new Set([...m.baseline.timing,...m.candidate.timing].map(x=>x.type))];let timing=table(['Type / clock group','Baseline slack','Candidate slack','Baseline TNS','Candidate TNS'],types.map(t=>{let b=m.baseline.timing.find(x=>x.type===t),c=m.candidate.timing.find(x=>x.type===t);return[t.replace(/'.*emu\|pll.*'/,'CORE').replace(/'.*pll_hdmi.*'/,'HDMI').replace(/'.*pll_audio.*'/,'AUDIO'),b?.slack,c?.slack,b?.tns,c?.tns]}));
let ledger=table(['Exclusive hierarchy','Placed ALM delta','Logic ALUT delta','FF delta'],cost.filter(x=>['|sys_top|emu:emu|savestates:savestates_inst','|sys_top|emu:emu|system:system|T80s:z80_inst|T80:u0','|sys_top|emu:emu|system:system|T80s:z80_inst|T80:u0|T80_Reg:Regs','|sys_top|ascal:ascal','|sys_top|osd:hdmi_osd','|sys_top|shadowmask:HDMI_shadowmask'].includes(x.n)).map(x=>[x.n,(x.placed).toFixed(1),x.alut,x.ff]));
let ffOutside=cost.filter(x=>!x.n.includes('savestates_inst')).reduce((s,x)=>s+x.ff,0);assert.equal(ffOutside,98);
let q=(k,kind)=>paths[k+'_'+kind][0];
let report=`# v19 CPU restore-output alias: physical timing diagnosis

**The observed setup failure is dominated by changed HDMI data routing. The measured CPU restore cone passes comfortably.** Matched physical endpoints and RAM output pins establish this directly; global placement/routing perturbation is the supported mechanism of the observed path regression. The causal chain from the CPU edit to the fitter's particular HDMI placement is not recoverable from these reports. Clock skew is a small contributor. One seed does not establish repeatability or seed sensitivity.

**Recommended next action: one separately authorized paired seed-2 reproducibility experiment, for diagnosis only.** No compilation or new physical experiment ran here. The rejected seed-1 candidate remains rejected and isolated.

## Provenance and read-only procedure

Read both complete prerequisite reviews, the internal inventory/declaration/group/fanout/mux/physical-operation evidence, the alias consumer proof, functional ledger, source bridge, provenance, input manifests, measured results and register delta. [retained_evidence_hashes.json](retained_evidence_hashes.json) indexes consumed retained reports/machine evidence. Read the existing fit/map/STA reports and queried both existing routed timing netlists; no new candidate or functional qualification is claimed.

HEAD remains **1b2a52d87d2659c908d4f9f846416d14bfd85bea**, branch **investigate/cram-memory-inference**, v19 tag **0x484313**. All **204 tracked hashes** and **137 inputs per retained build** verify. [provenance.json](provenance.json) retains source/report hashes. Baseline is ../savestate_g08_fm/quartus_early; rejected candidate is ../cpu_restore_output_alias/quartus_candidate1. The baseline manifest labels an older HEAD; the retained input hashes and prior normalized comparison with current HEAD establish actual v19 applicability. Two unused backup files are retained. This is not a v16/v17 comparison.

Only manifest input difference is rtl/savestates.sv: baseline SHA256 e8de50db09447138fc661205fb9edd178d45e691819a056bad87631ef3d76557; candidate 0d6a000152980f2bd64bce3b847c82dd5a5acfa9aa1a001527ada929189e774f. The change makes z80_dir a wire alias of retained z80_snap and removes the single registered copy; the earlier source bridge verifies reverse reconstruction. All bytes, CPU/NMI information and controls remain the previously proven experiment.

Both use Quartus Lite **17.0.2 Build602**, Cyclone V **5CSEBA6U23I7**, SMS/sys_top, seed1, BUILD_DATE261025 (build_id hash checked), MISTER_FB=1, identical QSF/QIP/SDC/IP/source inputs apart from that single RTL file. STANDARD FIT, HIGH PERFORMANCE EFFORT, SPEED, LOW ALM register packing, NORMAL automatic packing, final placement ALWAYS and the same physical synthesis/register duplication/retiming/router duplication settings. Query logs identify the same tool version, derived clocks and sys/sys_top.sdc. Final map/fit/STA report hashes still match the earlier measured results.

[query.tcl](query.tcl), [query_extra.tcl](query_extra.tcl), [query_fanout.tcl](query_fanout.tcl), [query_locations.tcl](query_locations.tcl) and their PowerShell launchers document the only Quartus operations: project_open, create_timing_netlist, read_sdc, update_timing_netlist, report_timing and metadata enumeration, then delete_timing_netlist/project_close. No execute_flow, map, fit, route, assembler or full STA compile. Reports are written only here. Queries take approximately6?21 seconds each and about6.0?6.25GB peak virtual memory.

The first query intentionally encounters an empty candidate z80_dir collection (two query warnings). An initial fanout API attempt passed individual IDs instead of collections, yielding invalid zero counts and query warnings; **those *_fanout.tsv files are discarded evidence, never used**. Corrected *_fanout_valid.tsv uses get_fanouts [get_registers name] and completes without warnings. The locations TSV's third field is a list/edge-handle representation, not a sink count, and is not used for fanout attribution. These diagnostic warnings are unrelated to compiled design warnings. Valid timing and location queries complete without errors.

## Timing groups, failing endpoints and path definitions

[metrics.json](metrics.json) freshly parses both original summaries, including all reported timing groups and TNS; [paths.json](paths.json) contains full queried path details. [path_comparisons.md](path_comparisons.md) lists the top50 per selected group and restricted cone. Queries use identical constraints, slow1100mV100C default netlists, -npaths50 -nworst1, full_path and show_routing. Thus each list retains one worst path per physical endpoint. Original multi-corner summaries remain the source of global signoff numbers; these matched default-corner queries reproduce their limiting setup and hold values for the relevant groups, not an exhaustive new multi-corner signoff.

${timing}

Setup failing endpoints: baseline **0**; candidate **23** in the HDMI group's selected set, all from shadowmask vid_rtl_0 ram_block5a0: **16 h_cnt and7 dsp_width**. The top50 includes27 nonfailing endpoints; the negative slacks sum exactly to **?12.187ns**. This reconciles the group's endpoint TNS and bounds the failing endpoint count for this constrained setup result. Every other reported setup group has zero TNS/positive slack; all reported holds pass. No unconstrained category is silently counted as passing. Candidate adds only compiled critical warning332148, timing requirements not met (38?39 unique critical warnings).

HDMI setup top50 spans baseline +0.104 onward versus candidate ?0.714 onward, with **26 exact start/end matches** in both ranked lists. Core top50 spans **+0.895..+1.567** versus **+0.716..+1.632ns**, but has **zero exact start/end matches** between the two ranked windows. This reflects ranking/physical-topology changes; it does not prove the corresponding baseline paths disappeared. Restricted CRC and SDRAM queries below supply comparisons beyond these windows. No overlapping list is added to another as a distinct failing endpoint count.

Worst hold: baseline **+0.239ns**, primary VDP shifter60 shift0[2]?[3], skew+.108/data.347; candidate **+0.241ns**, secondary VDP shifter11 shift2[5]?[6]~DUPLICATE, skew+.107/data.348. HDMI worst hold changes **+.259?+.247ns**, from scaler o_vdivr[16]?[17] to VGA-output RAM?d[18]; these are different physical paths. Fifty hold endpoints per core/HDMI group are retained, all positive. No minimum improvement is inferred for matched endpoints from differing worst paths.

## Matched HDMI path: data routing dominates

The earlier global-worst comparison used different endpoints. The new restricted queries find the **exact same named RAM and h_cnt[2]~DUPLICATE in both builds**, with the same **portbdataout[0]?OSD synchronous-clear** arc. Duplicate suffix alone is not proof of identity: the actual pin-level trace and unchanged RTL establish logical equivalence here. Different physical instances/layouts remain, so this is a routed logical-path comparison, not an unchanged placement experiment.

| Matched h_cnt[2]~DUPLICATE path | Baseline | Candidate | Delta |
| --- | ---: | ---: | ---: |
| Setup slack ns | +0.478 | ?0.714 | ?1.192 |
| Relationship ns | 6.732 | 6.732 | 0 |
| Reported skew ns | ?0.685 | ?0.692 | ?0.007 |
| Data delay ns | 5.369 | 6.554 | +1.185 |
| Data arrival ns | 14.226 | 15.385 | +1.159 |
| Data required ns | 14.704 | 14.671 | ?0.033 |
| Data routing-element delay ns | 4.375 | 5.562 | +1.187 |
| Data IC annotation ns | +0.001 | ?0.001 | ?0.002 |
| Data cell delay ns | 0.993 | 0.993 | 0 |
| Data routing elements | 27 | 32 | +5 |
| Logic levels | 1 | 1 | 0 |

Slack loss decomposes as **?1.185?0.007=?1.192ns** at displayed precision. Approximately99.4% of this matched-path degradation is data delay, 0.6% skew. These percentages describe this comparison, not a whole-design CPU cost. The global-worst degradation ?.818ns cannot be decomposed using those percentages because the baseline global worst is a different endpoint.

Both clocks are the same HDMI PLL output-counter divclk; launch/latch edge relation6.732ns, uncertainty0.200ns, common-clock pessimism removal0.966ns and clock-control resource CLKCTRL_G5 are unchanged. Launch clock path8.857?8.831ns; required-side clock path8.172?8.139ns. Their differential explains the .007ns skew change. There is no evidence of a new clock domain, constraint relaxation, changed period or dominant skew failure. Global HDMI clock-control reported fanout3651?3667 is a separate physical observation, not an ALM or data-fanout count.

Placement of matched path:

| Physical element | Baseline | Candidate |
| --- | --- | --- |
| RAM | M10K_X14_Y64_N0 | M10K_X26_Y63_N0 |
| Clear-decode LUT | LABCELL_X29_Y3_N3, always3~5 | LABCELL_X81_Y35_N27, always3~4 |
| h_cnt[2] duplicate | FF_X30_Y4_N38 | FF_X82_Y36_N38 |

The RAM's routed output fanout shown on this arc falls28?16, while the clear LUT's reported fanout remains77. The longer path is therefore not explained by an increased reported fanout at those pins. RAM output cell delay.025ns, LUT.081ns, receiving sclr arc.887ns remain unchanged. The LUT spelling changes under resynthesis; source and pin function, not generated spelling, define the comparison.

The baseline route uses long vertical C12 segments along X26 from Y52 through Y4, then local OSD logic. Candidate uses vertical segments along X25 toY27 and four long horizontal R14 resources at Y33 (X26,40,54,68) to reach the relocated OSD. The candidate post-LUT branch also traverses C2_X81_Y36, R3_X79_Y37, C4_X78_Y33 and R3_X79_Y36 before reaching the adjacent receiver region. Baseline post-LUT uses C2_X29_Y4 and R3_X30_Y4. These are measured route-resource sequences, not inferred straight-line wire lengths. The extra local excursion is a concrete detour/topology difference; the reports do not state which blocked tracks or timing trade caused its selection.

From RAM output to LUT input: **3.542?3.826ns (+.284)**. From LUT output to receiving sclr input: **.834?1.735ns (+.901)**. Those changes sum to the1.185ns data regression because cell delays stay fixed. Thus the largest measured increment is **after the high-fanout clear-decode LUT**, not in the CPU alias or a changed RAM function. Route congestion as the specific cause remains unproved.

For the baseline global-worst endpoint **dsp_width[19]**, the exact matched pair is **+.104??.108ns (?.212)**. All22 dsp_width endpoint names match between restricted sets;33 h_cnt names match (38baseline/37candidate total endpoints). Other duplicates differ and are not silently matched by stripping suffixes. The candidate's worst h_cnt path was already a marginal baseline HDMI control cone; its regression is not a newly introduced logical HDMI dependency.

## HDMI placement, duplication and congestion limits

Location metadata in *_locations.tsv finds dedicated OSD FFs **618?612**, bounding box **X16..72/Y1..69?X48..88/Y4..55**. This is a measured register distribution/extent, not a density or congestion heatmap. The specific RAM/LUT/register movements above establish local relocation more strongly than an overall bounding box. Both complete register name sets are retained.

HDMI OSD fitted hierarchy: placed558.6?554.0, needed543.4?544.2, logicALUT906?907, FF618?612, M10K4 unchanged. Its timing-node duplicate-name count37?31, h_cnt duplicates14?13. Shadowmask subtree: placed152.4?158.2, needed133.7?132.6, logicALUT255?254, dedicatedFF255?260, M10K4 unchanged; duplicate-name count7?12. Its timing-register-node count480?485 includes hard-memory timing nodes, which are not dedicated FFs. These two hierarchies together do not explain all global physical changes.

Final interconnect average total/H/V: baseline **49.7/49.4/50.8%**, candidate **48.9/48.6/50.0%**; peak total/H/V values are retained verbatim in the build results and original fit reports (total **74?77%**, candidate H/V **76.6/80.9%**). A smaller global average and larger peak coexist. Router preliminary estimates40% average in both, peak66?65%, with peak-estimate region moving X45_Y23..X55_Y34?X22_Y35..X32_Y45. Those preliminary peak regions are not final local HDMI congestion maps. Neither total usage nor estimated regions identify track pressure on the failing branch. No retained local congestion map supplies a defensible HDMI routing-utilization percentage. No such percentage is invented.

Fitter hierarchy memory-ALM allocation is not routing-ALUT allocation; the hierarchy's memory columns cannot explain route-through counts. Global routing ALUT **18266?18310 (+44)** is measured. Neither the existing hierarchy rows nor these TimeQuest path traces provide an exclusive per-HDMI or per-CPU routing-ALUT decomposition. Routing elements on a path are not routing ALUTs.

## CPU restore and native timing

The real consumers and exact consuming edges remain covered by the earlier40-case functional gate; no new RTL or test masking is introduced. Physical timing asks a different question. Baseline z80_dir?T80 worst queried setup is **+13.249ns**, data4.497/skew?.550 (dir[8]?F[0]); candidate z80_snap?T80 worst is **+13.974ns**, data3.828/skew?.494 (snap[73]?PC[9]). These are worst envelopes of different endpoint sets, not a matched-bit speedup. Fifty endpoints from each are retained. Baseline snapshot?output copy stage separately has worst **+13.458ns**; it is removed, so the two-stage baseline must not be compared as if it were one combinational candidate path.

Including all controller z80_* controls, worst setup **+11.691?+9.313ns**; worst hold **+.441?+.522ns**. Candidate's worst control is z80_nmi_hold?NMICycle (data8.353/skew?.630); this is an unchanged logical control with ample margin. The alias data paths and controls are not near-critical in either group window.

Corrected get_fanouts endpoint collections show per-snapshot-bit maximum **6?116**; total endpoint-count sums **628?929**, with **snap[228] (Alternate) now116**. Baseline dir[228] already reached107 fanout endpoints; that responsibility moved to the retained snapshot. These are **transitive TimeQuest fanout endpoint collections**, not direct Fitter loads, unique chipwide sink sums or an additive area estimate. No surviving snapshot duplicate bank appears:230snapshot bits remain230. T80 subtree dedicatedFF426?467 and duplicate-name count53?86 demonstrate material receiver physical remapping, but do not uniquely identify buffering added by each alias bit. Without a disjoint LUT/buffer ownership map, an exact alias-buffer ALM charge cannot be recovered.

The core group's new worst is **joystick_1[5]?secondary PSG cen_16**, +.716ns (9.313ns relation), not CPU restore. Worst native T80 input now **SDRAM sd_dat[8]?IR[5]**, +.817ns (data15.932/skew?1.547), versus baseline's mapper CRC?IR +.895. Restricted SDRAM?IR envelope changes **+1.326?+.817**, and mapper CRC?IR envelope improves **+.895?+1.652**. All native T80 top50 paths remain positive; candidate window ends+1.937 versus baseline+2.302. New relative near-critical native core paths therefore exist, but are ordinary ROM/input and joystick/PSG cones; there is no measured near-critical alias-data path. Restricted family queries allow physical duplication to choose different launches; these envelopes do not claim identical start/end matches. Full paths and generated-node identities remain in the ledger.

## What the resource changes do and do not explain

Whole chip: placed **38599?38457 (?142)**; needed **37117?37005 (?112)**; mappedFF46327?46097 (?230); fittedFF48880?48744 (?136); logicALUT46835?46947 (+112); routingALUT18266?18310 (+44); M10K488 and memorybits3818050 unchanged. The intended230-bit bank is removed. Controller ownFF14773?14539 (?234) consists of z80_dir?230 and watchdog duplicates?4; z80_snap230 unchanged. Other dedicated FF allocations sum exactly to **+98**, not98 unidentified CPU or HDMI registers.

${ledger}

[hierarchy_deltas.json](hierarchy_deltas.json) partitions **exclusive** own FF and logicALUT deltas over all hierarchy rows: totals?136FF and+112ALUT exactly. In particular controller own+170logicALUT is offset by **?58 elsewhere**. Major outside ALUT changes include Evolution-address+36, EEPROM serial+23, primary sprite evaluator+20, OPLL output memory?21, scaler?13 and others. These are mapping locations, not proof those unchanged sources acquired new functional logic or proof of which optimization pass caused each change.

T80 subtotal+41FF is T80 own+33, Regs+9 and wrapper?1; these are disjoint. Other outside examples: video_calc+14, scaler own+13, top own+11, HPS own+10, primary sprite evaluator?31, primary BG+10 and secondary BG?9. The full exclusive ledger reconciles all98 without adding inclusive counts. Timing-node names show altered duplicates and retimed OTERM families, but source names/renumbering alone do not support a one-to-one causal identity for every new FF. RAM internal timing nodes are excluded from the dedicated-FF arithmetic.

Unavailable ALMs573?608 (**+35**) and recoverable2055?2060 (+5) are global fitter packing estimates. Packing identities are **38599?2055+573=37117**, **38457?2060+608=37005**. The retained per-hierarchy rows do not partition the global unavailable estimate (their unavailable entries are0), so assigning the35 to HDMI, CPU fanout or a particular packing rule would be unsupported. The44 routingALUT increase similarly remains globally measured but locally unattributed. These quantities must not be added to logicALUT/FF/hierarchy deltas as independent ALM costs.

## Confidence, alternatives and next action

**High confidence:** correct paired seed1 inputs; consumed CPU bank removal; matched HDMI pin/function and physical locations; data-route/cell/skew arithmetic;23failing endpoints and reconciled TNS; positive queried CPU alias/native timing; global resource deltas and exclusive FF/logicALUT ledger.

**Moderate confidence:** a global placement/routing response to the bounded source change is the mechanism connecting the experiment to the HDMI regression. Multiple unchanged hierarchies move/remap and the limiting route's topology measurably changes. These observations support physical perturbation, but do not reconstruct the fitter's optimization decisions or isolate whether placement, routing resource conflicts, timing-driven duplication or interactions initiated that response.

**Unproved:** repeat-fit determinism with this exact seed/environment; statistical seed sensitivity; a particular local congestion bottleneck; local routingALUT/unavailable-ALM ownership; whether another seed passes. The routed netlist deterministically reports the failure when queried, which is not proof that rebuilding it is reproducible. One failed seed cannot prove intrinsic CPU slowness or promise another seed succeeds. Previous CRAM/global remapping observations are context, not additional samples of this alias experiment. Existing unconstrained categories and default-query corner limits remain.

**Exactly one recommendation: seek authorization for one fresh paired seed2 baseline/candidate reproducibility experiment.** This is scientifically useful because the observed limiting mechanism is a relocated unchanged HDMI route, while the direct changed cone has large positive margin and there is a real142-placed-ALM seed1 saving. The pair would test whether that physical trade recurs under one different common placement seed; it would not establish statistical confidence or repair the rejected build. No topology rewrite or timing-constraint experiment is recommended concurrently.

Both fresh source-isolated builds must use the same authoritative v19 inputs, only the already-retained230-bit alias source difference, **SEED2 on both**, Quartus17.0.2 Lite/configuration/device/IP/SDC, fixed BUILD_DATE261025, same host/tool environment and fresh databases. Keep all prior evidence and measure the same metrics/corners/warnings, matched HDMI route family and CPU cones; verify input manifests before/after. No source edits beyond the existing isolated candidate, seed setting or permitted build staging. The existing functional proof applies only after confirming byte-identical candidate inputs; no qualification scope may be weakened.

Recorded candidate map9m22s, fit17m58s, plus assembler/STA give approximately **28?30minutes per fresh build**, so budget **aboutonehour for the pair**, potentially longer. Fit peak virtual memory **10421MB**, about92m13s aggregate CPU time; each fit needs at least that order of virtual-memory headroom. Run sequentially on the same host to limit contention. Retain both full build trees, reports/databases and input ledgers; disk usage is implementation-dependent, not measured as a promised bound here.

A favorable paired diagnostic requires candidate230mappedFF removal, lower **paired** placedALMs, unchangedM10K, acceptable routing (retain the earlier no-growth routingALUT/final average/peak gate), all reported setup/hold positive, no new violating group or critical warning, and unchanged functional/source evidence. Compare to its own seed2 baseline, never seed1 baseline. A positive candidate with a failing seed2 baseline cannot prove a repeatable improvement over a qualified baseline. Baseline passes/candidate fails indicates the timing risk recurs; both fail leaves high-utilization/timing sensitivity unresolved; both pass with area/routing gates passing supports seed-dependent feasibility, **but does not overturn failed seed1 or authorize production promotion**. Area reversal or mixed timing/routing results means no robust demonstrated win. Do not cherry-pick a favorable unpaired seed or accept negative slack. Stop after that bounded pair for a new decision rather than silently extending the seed search.

## Preservation and final repository state

Production files, v19 bytes/compatibility, constraints, IP, branch, HEAD and index are unchanged. Existing builds, tests, rejected candidate and evidence remain in place. No checkout/reset/clean/commit/push/merge/PR or full compilation occurred. Only this diagnosis directory was created. Final verification rechecks all tracked and retained source/report/evidence hashes.

Final git diff --stat:

\x60\x60\x60text
(empty)
\x60\x60\x60

Final git status --short:

\x60\x60\x60text
?? tests/
\x60\x60\x60

The untracked tests tree predates this task; new files are confined to tests/cpu_restore_alias_timing_diagnosis/. **Stop here and await authorization before any synthesis or physical experiment.**
`;
fs.writeFileSync(p.join(d,'review.md'),report);console.log('Wrote review and path ledger; retained reports/source hashes verified.');
