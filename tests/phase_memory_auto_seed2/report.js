const fs=require('fs'),p=require('path'),assert=require('assert'),cp=require('child_process'),crypto=require('crypto');
const d=__dirname,root=p.resolve(d,'../..'),read=f=>fs.readFileSync(p.join(d,f),'utf8'),r=JSON.parse(read('results.json'));
const first=JSON.parse(fs.readFileSync(p.join(d,'../phase_memory_auto/results.json'),'utf8'));
const toolIdentity=JSON.parse(read('tool_identity.json'));assert(toolIdentity.identicalToSeed1);
const effectiveSeeds={};for(const v of ['baseline','candidate']){const fit=read(v+'/output_files/SMS.fit.rpt'),m=fit.match(/;\s*(?:Fitter Initial Placement )?Seed\s*;\s*(\d+)/i);assert(m,'Missing effective seed '+v);effectiveSeeds[v]=Number(m[1]);assert.equal(effectiveSeeds[v],2);}
const hash=f=>crypto.createHash('sha256').update(fs.readFileSync(f)).digest('hex');
const inputManifest=JSON.parse(read('input_manifest.json'));assert.equal(inputManifest.seed,2);
for(const v of ['baseline','candidate']){assert.equal(hash(p.join(d,v,'build_id.v')),inputManifest.generated['build_id.v'][v]);assert.equal(r.builds[v].buildDate,first.builds[v].buildDate);}
const bitstreams={};for(const v of ['baseline','candidate']){const file=v+'/output_files/SMS.rbf';bitstreams[v]={file,bytes:fs.statSync(p.join(d,file)).size,sha256:hash(p.join(d,file))};assert(bitstreams[v].bytes>0);}
fs.writeFileSync(p.join(d,'bitstreams.json'),JSON.stringify(bitstreams,null,2)+'\n');
assert(Object.values(r.simulations).every(x=>x.pass),'Reused functional qualification is incomplete');
const rows=[['Needed ALMs','needed'],['Placed ALMs','placed'],['Mapped FF','synthesisRegisters'],['Fitted registers','registers'],['Logic ALUTs','logicALUT'],['Routing ALUTs','routingALUT'],['M10Ks','M10K'],['MLAB cells','MLABcells'],['DSP blocks','DSP'],['Setup slack ns','setup'],['Hold slack ns','hold']];
const sign=x=>(x>=0?'+':'')+Number(x.toFixed(3)),tns=(m,t)=>Math.min(...m.timing.filter(x=>x.type.startsWith(t)).map(x=>x.tns));
let table='| Metric | Seed1 A | Seed1 B | Δ1 | Seed2 A | Seed2 B | Δ2 |\n| --- | ---: | ---: | ---: | ---: | ---: | ---: |\n';
for(const [label,k] of rows)table+=`| ${label} | ${first.builds.baseline[k]} | ${first.builds.candidate[k]} | ${sign(first.delta[k])} | ${r.builds.baseline[k]} | ${r.builds.candidate[k]} | ${sign(r.delta[k])} |\n`;
table+=`| Setup TNS ns | ${tns(first.builds.baseline,'Setup')} | ${tns(first.builds.candidate,'Setup')} | — | ${tns(r.builds.baseline,'Setup')} | ${tns(r.builds.candidate,'Setup')} | — |\n| Hold TNS ns | ${tns(first.builds.baseline,'Hold')} | ${tns(first.builds.candidate,'Hold')} | — | ${tns(r.builds.baseline,'Hold')} | ${tns(r.builds.candidate,'Hold')} | — |\n`;
fs.writeFileSync(p.join(d,'two_seed_comparison.md'),table);
const mapping={};for(const v of ['baseline','candidate']){
 mapping[v]={sameMappedRegisters:first.builds[v].synthesisRegisters===r.builds[v].synthesisRegisters,sameMemoryBits:first.builds[v].memoryBits===r.builds[v].memoryBits,sameDSP:first.builds[v].DSP===r.builds[v].DSP,sameM10K:first.builds[v].M10K===r.builds[v].M10K,sameMLAB:first.builds[v].MLABcells===r.builds[v].MLABcells,sameRamParameters:JSON.stringify(first.builds[v].phaseParameters)===JSON.stringify(r.builds[v].phaseParameters)};
 assert(Object.values(mapping[v]).every(Boolean),'Logical mapping signatures differ across seeds: '+v);
}
const timingPass=[first,r].every(s=>Object.values(s.builds).every(m=>m.setup>=0&&m.hold>=0&&m.violations===0));
const areaPass=[first,r].every(s=>s.delta.placed<0&&s.delta.needed<0);
const recommendation=areaPass&&timingPass?'The area reduction repeats in both matched seed pairs and all reported timing passes. PhaseMemory AUTO inference is a reasonable candidate for hardware validation. Keep it experimental until that validation; this is evidence from two seeds on one device/tool configuration, not a production signoff.':!timingPass?'Do not promote this candidate yet: the two-seed study includes a timing failure. Successful memory inference and local FF savings do not override whole-design timing qualification.':'The whole-design area gain does not repeat consistently across both matched seeds. Do not promote the change as a reliable area optimization on this evidence.';
const clocks='| Seed2 clock group | A slack / TNS ns | B slack / TNS ns |\n| --- | ---: | ---: | ---: |\n'+r.builds.baseline.timing.filter(x=>/^(Setup|Hold)/.test(x.type)).map(x=>{const b=r.builds.candidate.timing.find(b=>b.type===x.type);assert(b);return `| ${x.type.replaceAll('|',' / ')} | ${x.slack} / ${x.tns} | ${b.slack} / ${b.tns} |`;}).join('\n')+'\n';
fs.writeFileSync(p.join(d,'timing_table.md'),clocks);
const localRows=[first,r].flatMap((s,i)=>['baseline','candidate'].map(v=>{const c=s.builds[v].phaseHierarchy[0];assert(c);return `| ${i+1} ${v} | ${c[1]} | ${c[2]} | ${c[7]} | ${c[9]} | ${c[10]} |`;})).join('\n');
const routeRows=[first,r].flatMap((s,i)=>['baseline','candidate'].map(v=>`Seed${i+1} ${v}:\n${s.builds[v].finalInterconnect.map(x=>x.trim()).join('\n')}`)).join('\n');
const before=JSON.parse(read('preservation_before.json'));
const final={branch:cp.execFileSync('git',['branch','--show-current'],{cwd:root,encoding:'utf8'}).trim(),refs:Object.fromEntries(Object.keys(before.refs).map(x=>[x,cp.execFileSync('git',['rev-parse',x],{cwd:root,encoding:'utf8'}).trim()])),seed1AndEarlierEvidenceMismatches:r.preservationMismatches,rootPhaseUnchanged:hash(p.join(root,'rtl/VM2413/phasememory.vhd'))===before.productionPhaseSHA256,sourceDifference:r.sourceDifference,staged:cp.execFileSync('git',['diff','--cached','--stat'],{cwd:root,encoding:'utf8'}).trim(),effectiveSeeds,identicalToolBinaries:toolIdentity.identicalToSeed1,newSimulationsRun:false,reusedFunctionalEvidencePass:Object.values(r.simulations).every(x=>x.pass),mappingSignatures:mapping,areaPass,timingPass,recommendation};
assert(final.rootPhaseUnchanged);assert.equal(final.staged,'');assert.deepEqual(final.refs,before.refs);
fs.writeFileSync(p.join(d,'final_validation.json'),JSON.stringify(final,null,2)+'\n');
fs.writeFileSync(p.join(d,'review.md'),`# PhaseMemory AUTO: paired seed-2 confirmation

Date: 2026-10-29 (America/Sao_Paulo). Branch: \`experiment/phasememory-auto-inference\`. Baseline: \`8443a0d19a88aff7a5900011bccf386daf146945\`.

## Result and recommendation

${recommendation}

Seed2 candidate minus its fresh seed2 baseline: **${sign(r.delta.placed)} placed ALMs, ${sign(r.delta.needed)} needed ALMs, ${sign(r.delta.registers)} fitted registers, ${sign(r.delta.routingALUT)} routing ALUTs, ${sign(r.delta.M10K)} M10K**. Candidate setup/hold: **${r.builds.candidate.setup}/${r.builds.candidate.hold} ns**, versus A ${r.builds.baseline.setup}/${r.builds.baseline.hold} ns. Setup/hold TNS: B ${tns(r.builds.candidate,'Setup')}/${tns(r.builds.candidate,'Hold')} ns; A ${tns(r.builds.baseline,'Setup')}/${tns(r.builds.baseline,'Hold')} ns.

## Matched build identity

This adds only a seed2 A/B pair to the [seed1 experiment](../phase_memory_auto/review.md). All203 tracked source inputs were verified against its manifest before copying; only SMS.qsf SEED1→2 changed in both new trees. Fixed BUILD_DATE261014, Quartus Prime Lite17.0.2 Build602, device5CSEBA6U23I7, SMS/sys_top, MISTER_FB=1, original QIP/IP/SDC and all performance/packing settings are identical across pairs. The original root QSF remains unchanged.

Both seed2 builds started without databases and completed map/fit/asm/sta. They used the same Z:/baseline and Z:/candidate project path layout as seed1. Direct stages bypass only the date-generating preflow. [input_manifest.json](input_manifest.json), [build.ps1](build.ps1), [workflow.log](workflow.log), [results.json](results.json) and [reproduce.md](reproduce.md) retain exact inputs, stages, hashes and instructions. Generated build trees/databases are ignored and unstaged. No incremental implementation or best-of-seed substitution was used.

Both fitter reports confirm effective seed2. [tool_identity.json](tool_identity.json) verifies that all six Quartus executable hashes match seed1.

A/B still differ only by removal of PhaseMemory's \`ramstyle="logic"\` specification, originally rtl/VM2413/phasememory.vhd:52. [production.diff](production.diff) is the unchanged one-line source experiment. No additional RTL, attribute or memory bank was modified.

## Whole-design two-seed comparison

Each Δ is candidate minus its own same-seed baseline. Needed/placed ALMs are distinct; mapped/fitted FF and logic/routing ALUTs must not be added as independent area charges.

${table}

Full per-clock seed2 setup/hold slack and TNS: [timing_table.md](timing_table.md). Full STA/map/fit reports remain in baseline/output_files and candidate/output_files. The inherited unconstrained categories remain A ${r.builds.baseline.unconstrainedInfo.join(', ')}, B ${r.builds.candidate.unconstrainedInfo.join(', ')}; positive reported slack does not mean fully constrained hardware signoff. No additional keeper wildcard query was needed; the successful full STA reports provide this seed's timing evidence.

## Memory mapping and local versus global cost

Logical mapping signatures match seed1 in both A and B: mapped FF totals, logical memory bits, DSP counts and PhaseMemory RAM parameters are unchanged across seeds. B's phase_array is the same18×18 simple-dual-port RAM with OLD_DATA collision semantics; one extra fitted M10K, zero MLABs. The other three FM banks retain their logic attributes. No fallback inference template or explicit block attribute was tried.

| PhaseMemory hierarchy allocation | Needed ALMs | Placed ALMs | Dedicated FF | Memory bits | M10Ks |
| --- | ---: | ---: | ---: | ---: | ---: |
${localRows}

Fractional hierarchy counts are allocations, not guaranteed removable sites. The whole-design tables above, including changes elsewhere from packing/duplication/routing, determine the physical result. Logical state width and savestate format are unchanged. An extra324 configured memory bits records existing phase state moved from FFs to RAM; it is not new functional state. M10K use moves487→488 out of553, leaving65 nominally free blocks. DSP and MLAB totals are unchanged.

## Routing and warnings

\`\`\`text
${routeRows}
\`\`\`

Routing-resource utilization rows and normalized warning ledgers are in [results.json](results.json). Seed2 normalized warning messages added/removed: **${r.warningComparison.added.length}/${r.warningComparison.removed.length}**. Seed1's average interconnect rose28.9→29.3% even though placed ALMs/routing ALUTs fell; evaluate seed2's average, peak and directional figures separately. These are implementation tradeoffs, not a claim every routing/timing metric improves. No per-operator ALM estimate replaces the measured full-device result.

For seed2 specifically, average total interconnect rises29.1→29.3%; peak total rises47.3→53.2% and peak H rises46.3→55.1%, while peak V falls51.1→48.8%. Routing ALUTs fall137. Setup margin improves121ps, but hold margin falls66ps and remains positive at177ps. Thus the repeated area gain does not establish an across-the-board routing or timing improvement. These higher routing peaks remain a reason to keep the change experimental until hardware validation.

## Functional qualification reused

No functional RTL changed between seeds. The prior unadapted bank scoreboard, mapped-memory comparison, complete OPLL RTL/mapped comparisons and native-controller savestate tests remain applicable and passed. This includes101,458 bank cycles/406,112 checks,946,616 complete OPLL cycles,8,482,683 paired-controller cycles and2,222,128 mapped savestate audio samples with56,160 nonzero samples. [Prior functional results](../phase_memory_auto/functional_results.json) and [prior detailed limitations](../phase_memory_auto/review.md) remain unchanged. **No new simulations were run or claimed for seed2.** Source hashes and identical logical mapping signatures bind the reused qualification to these builds.

This preserves the specified baseline's behavior; it does not add later v19 complete OPLL save-state history. Neither seed is hardware validation. The two observed paired fits are evidence about this device/tool/settings combination, not an exhaustive seed search or a statistical guarantee.

The untested seed2 candidate bitstream is [candidate/output_files/SMS.rbf](candidate/output_files/SMS.rbf). [bitstreams.json](bitstreams.json) records both generated RBF sizes and SHA256s for later identification; no bitstream was installed on hardware.

## Preservation and stopping point

[preservation_before.json](preservation_before.json) freezes109 prior seed1 artifact/report hashes plus protected refs and the root PhaseMemory hash. [final_validation.json](final_validation.json) confirms zero preservation mismatches, identical root RTL, unchanged refs and no staged files. The active experimental branch still has HEAD8443a0d with only the previously authorized one-line PhaseMemory deletion uncommitted. Master, v19 and the structural-investigation branch are unchanged.

All new seed2 artifacts are under tests/phase_memory_auto_seed2. No seed1 report/database was regenerated, no other bank or third seed was attempted, and no commit, merge, push or PR was made. Stop here for review; hardware validation or any further work requires separate authorization.
`);
console.log(JSON.stringify({recommendation,deltaSeed1:first.delta,deltaSeed2:r.delta,mapping},null,2));
