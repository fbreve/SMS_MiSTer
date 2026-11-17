const fs=require('fs'),p=require('path'),d=__dirname;
const r=JSON.parse(fs.readFileSync(p.join(d,'results.json'))),id=JSON.parse(fs.readFileSync(p.join(d,'artifact_identity.json'))),assessment=JSON.parse(fs.readFileSync(p.join(d,'assessment.json')));
const a=r.builds.baseline,b=r.builds.candidate,fmt=x=>typeof x==='number'?x.toLocaleString('en-US',{maximumFractionDigits:4}):x;
const metrics=[['Needed ALMs (logic utilization)','neededALMs'],['Placed ALMs [A]','placedALMs'],['Recoverable ALMs [B]','recoverableALMs'],['Unavailable ALMs [C]','unavailableALMs'],['Logic ALUTs','logicALUTs'],['Routing ALUTs','routingALUTs'],['Mapped registers','mappedRegisters'],['Fitted total registers','fittedRegisters'],['M10K blocks','M10K'],['Logical block-memory bits','memoryBits'],['MLAB cells','MLABcells'],['MLAB bits','MLABbits'],['ALMs for memory','memoryALMs'],['DSP blocks','DSP'],['Worst setup slack (ns)','setupSlack'],['Setup TNS, worst clock group (ns)','setupTNS'],['Worst hold slack (ns)','holdSlack'],['Hold TNS, worst clock group (ns)','holdTNS']];
let s=`# YM2413 full-state Seed 1 physical baseline

**${assessment.readiness}**

${assessment.summary}

## Matched identity and scope

Fresh baseline: upstream master \`${id.HEAD}\`. Candidate: the reviewed uncommitted
\`${id.branch}\` full-state port, with FM reference \`${id.FMreference}\`.
Both use Quartus Prime Lite 17.0.2 Build 602, Cyclone V \`${id.device}\`, project/revision
SMS, top sys_top, MISTER_FB=1, Seed 1 and common BUILD_DATE ${id.buildDate}.
QSF, constraints, shared sys files, IP and optimization settings match. The sole
configuration-source difference is the approved files.qip addition of opll_snapshot.sv.
The pinned mist/mist-modules dependency is recorded in inputs.json.

The build trees are independent fresh copies in baseline/ and candidate/. No existing
database or output was reused. Explicit map/fit/asm/sta stages preserve the project
settings and use identical standard generated build-date/CDF metadata. A temporary
free Z: alias provided short build paths and was removed afterward. The pre-existing
idle TimeQuest process was not interrupted.

All 104 private words, descriptor version 17, handshakes, initialization, pending writes
and refill latency remain unchanged. No RTL edits, state removal, tuning, retries,
additional seeds, commits, merges, PRs or hardware deployment were performed.

## Fitted resource and timing comparison

Delta is candidate minus matched master. Needed ALMs = placed [A] - recoverable [B] + unavailable [C].
Logic/routing ALUTs are not additional ALMs. Register counts include
the fitter's physical optimization effects. Memory bits are logical bits, distinct
from allocated M10K capacity.

| Metric | Master Seed 1 | Full-state Seed 1 | Delta |
|---|---:|---:|---:|
`;
for(const [label,key]of metrics){const delta=r.deltas[key].delta;s+=`| ${label} | ${fmt(a[key])} | ${fmt(b[key])} | ${delta>0?'+':''}${fmt(delta)} |\n`;}
s+='\nRouting utilization (total / horizontal / vertical):\n\n';
for(const kind of ['Average','Peak'])s+=`- ${kind}: master ${a.interconnect[kind].percent.join(' / ')}%; candidate ${b.interconnect[kind].percent.join(' / ')}%.\n`;
s+=`\n${assessment.timingAssessment}\n\n## Source inclusion and memory inference\n\n`;
s+=`Quartus source tables and frozen hashes verify the source actually compiled. The
candidate audit covers ${b.coreAssignmentInclusion.length} core assignments and all
${b.reviewedSourceInclusion.length} reviewed HDL files, including rtl/opll_snapshot.sv;
those reviewed HDL files are reported used in the netlist. No simulation adapters
are present. Expanded settings and actual fitter settings are retained.

${assessment.phaseAssessment}

Fitted FM memories (global total above includes all other core memories):

| Build | Memory | Type / mode | Logical size | M10Ks | MLABs | Read-during-write mode |
|---|---|---|---:|---:|---:|---|
`;
for(const [v,m]of [['Master',a],['Full-state',b]])for(const row of m.fmMemoryImplementations){const name=row.Name.replace(/^.*?(?:opll:fm\||opll_snapshot:fm_snapshot\|)/,'');s+=`| ${v} | ${name.replaceAll('|',' / ')} | ${row.Type} / ${row.Mode} | ${row.Size} | ${row['M10K blocks']} | ${row['MLAB cells']} | ${row['Mixed Width RDW Mode']} |\n`;}
s+='\n## Critical timing paths\n\n';
for(const [v,m]of [['Master',a],['Full-state',b]]){
 s+=`### ${v}\n\n`;
 for(const x of m.paths.setup.slice(0,3))s+=`- Setup ${x.slack} ns: \`${x.from}\` → \`${x.to}\`; launch \`${x.launch}\`, latch \`${x.latch}\`; data delay ${x.dataDelay}, skew ${x.skew}.\n`;
 for(const key of ['fm_from','fm_to','phase_from','phase_to','snapshot_from','snapshot_to'])if(m.paths[key]?.length){const x=m.paths[key][0];s+=`- ${key}: ${x.slack} ns, \`${x.from}\` → \`${x.to}\`.\n`;}
}
s+=`\nFull paths, routing detail, ignored constraints and unconstrained-path reports are
in each build directory as physical_*.rpt. The extra queries do not alter the native
fit/STA reports; their hashes are checked. Native STA summaries remain the acceptance
metrics. Per-clock and other timing checks are retained in results.json.

## Warning review

${assessment.warningAssessment}

${assessment.unresolvedIssues}

All raw warnings, normalized added/removed warnings, latch/driver/width categories
and source locations are retained in results.json and warnings.md. Inherited
constraint gaps are reported explicitly; a successful tool exit alone is not timing
qualification or hardware validation.

## Experimental binaries and source provenance

Candidate: [${p.basename(id.artifacts.candidate.path)}](${id.artifacts.candidate.path})

- RBF SHA-256: \`${id.artifacts.candidate.SHA256}\`
- Bytes: ${id.artifacts.candidate.bytes}
- Exact source-tree identity: \`${id.sourceTreeSHA256}\`
- Complete uncommitted patch SHA-256: \`${id.completePatchSHA256}\`
- Source revision: \`${id.HEAD}\` plus the complete reviewed patch and pinned dependency;
  the uncommitted candidate is not represented as a new Git commit.

The matched master RBF is also preserved under artifacts/. artifact_identity.json,
inputs.json, candidate.diff, workflow.log and results.json bind binaries, actual
inputs, tools and reports. These RBFs are experimental and have not been tested
on a MiSTer. Manual validation must establish real FM SAVE/LOAD correctness and
musical continuity; compilation and timing do not establish that functionality.

## Reproduction

Use a new empty artifact directory and the retained prepare.js/build.ps1 workflow;
the scripts refuse existing build attempts. No retry or optimization is part of
this measurement. query.ps1 performs additional read-only timing/settings queries;
collect.js, preserve.js and report.js retain source-bound evidence and binaries.
`;
fs.writeFileSync(p.join(d,'review.md'),s);
let w='# Warning comparison\n\n## Added normalized warnings\n\n'+(r.warnings.added.length?r.warnings.added.map(x=>'- '+x).join('\n'):'None.')+'\n\n## Removed normalized warnings\n\n'+(r.warnings.removed.length?r.warnings.removed.map(x=>'- '+x).join('\n'):'None.');
for(const [v,m]of [['Master',a],['Full-state',b]])for(const [kind,items]of Object.entries(m.warningReview))w+=`\n\n## ${v}: ${kind}\n\n`+(items.length?items.map(x=>'- '+x).join('\n'):'None.');
fs.writeFileSync(p.join(d,'warnings.md'),w+'\n');
console.log('Wrote physical comparison review and warning evidence');
