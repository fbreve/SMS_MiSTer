const fs=require('fs'),p=require('path'),assert=require('assert');const d=__dirname,j=f=>JSON.parse(fs.readFileSync(p.join(d,f))),fmt=x=>Number.isInteger(x)?x.toLocaleString('en-US'):Number(x).toFixed(3),delta=x=>(x>0?'+':'')+fmt(x),link=(label,file)=>`[${label}](</${p.resolve(d,file).replaceAll('\\','/')}>)`;
const gate=j('r2/functional_gate.json'),physical=j('physical_r2/comparison.json'),release=j('release/MANIFEST.json'),preserved=j('preservation_final.json'),movie=j('r2/e_map_comparison.json'),slots=j('r2/saved_slot_validation.json');assert.equal(gate.status,'PASS');assert.equal(preserved.status,'PASS');assert.equal(physical.pairs.length,3);assert(physical.pairs.every(q=>q.setupHoldPass&&q.otherNegativeTiming.length===0));
const b=movie.comparisons.e_sram_vs_e_reference,a=movie.comparisons.e_baseline_vs_e_reference,finalA=a.checkpoints.find(q=>q.label==='clear_right64'),pairs=physical.pairs.sort((a,b)=>a.seed-b.seed);
const metrics={neededALMs:'Needed ALMs',placedALMs:'Placed ALMs',mappedRegisters:'Mapped registers',fittedRegisters:'Fitted registers',logicALUTs:'Logic ALUTs',routingALUTs:'Routing ALUTs',M10K:'M10K blocks',memoryBits:'Logical memory bits',DSP:'DSP blocks'};
let resource='| Metric | B1 | C1 | Delta1 | B2 | C2 | Delta2 | B3 | C3 | Delta3 |\n|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|\n';for(const [key,label]of Object.entries(metrics))resource+=`|${label}|`+pairs.flatMap(q=>[fmt(q.baseline[key]),fmt(q.candidate[key]),delta(q.delta[key])]).join('|')+'|\n';
let timing='| Seed | Variant | Setup ns | Hold ns | Setup TNS | Hold TNS |\n|---|---|---:|---:|---:|---:|\n';for(const q of pairs)for(const [name,m]of [['Baseline',q.baseline],['Candidate',q.candidate]])timing+=`|${q.seed}|${name}|${fmt(m.worstSetup)}|${fmt(m.worstHold)}|${fmt(m.setupTNS)}|${fmt(m.holdTNS)}|\n`;
let warnings='| Seed | Baseline unique critical warnings | Candidate unique critical warnings | New warning texts |\n|---|---:|---:|---:|\n';for(const q of pairs)warnings+=`|${q.seed}|${q.criticalWarnings.baseline.length}|${q.criticalWarnings.candidate.length}|${q.criticalWarnings.newText.length}|\n`;
const suiteRows=[['Ported controller matrix',51,'r2/transport_results.json'],['Physical SRAM/stalls/interruption/repeated LOAD/exclusions',16,'r2/stress_results.json'],['Older FM upgrade/commit boundaries',10,'r2/upgrade_results.json'],['Legacy mapper footprints',28,'r2/legacy_mapper_results.json'],['Excluded public-output equivalence',2,'r2/exclusion_systeme.log'],['Restore ordering',1,'r2/ordering.log'],['Reused focused FM suites',7,'r2/fm_results.json'],['Additional live FM mode cases',7,'r2/fm_modes_results.json'],['Native900000-flush live FM case',1,'r2/fm_native_qualified.json']];
let suites='| Scope | Completed cases | Evidence |\n|---|---:|---|\n';for(const [name,n,file]of suiteRows)suites+=`|${name}|${n}|${link('result',file)}|\n`;
const transport=j('r2/transport_results.json').results,find=c=>transport.find(q=>q.candidate===c&&q.format===0&&q.map===0&&q.eligible===1),clocks=q=>{const s=q.result.match(/SAVE_cycles=(\d+) LOAD_cycles=(\d+)/);return[+s[1],+s[2]];},ac=clocks(find(0)),bc=clocks(find(2)),extra=[bc[0]-ac[0],bc[1]-ac[1]];
const primary=release.artifacts.find(q=>q.seed===1),first=j('r2/first_map_column_evidence.json').comparisons.e_baseline_vs_sram.firstRenderingRelevant;
const text=`# Ys physical SRAM fix on FM PR227 — qualification report

Date:2026-11-15 (America/Sao_Paulo). **GO for experimental hardware testing. Hardware has not been tested with these RBFs.**

## Source identity and review

FM baseline is8cd53ccc954c24970372ea6d8a3fb2336a14c46f, confirmed by a read-only upstream PR227 metadata check. The experimental branch remains\n\`fix/ys-physical-sram-on-fm-pr227\`, HEAD\`69edeb48455820d3119ab54d052bf3de906c91fa\`, **plus an uncommitted completion-guard correction**. No new commit was made.

Patch SHA256: \`${gate.identity.uncommittedPatchSHA256}\`. Compiled production savestates.sv SHA256: \`${gate.identity.productionSHA256}\`. The RBF must not be described as clean69edeb48 alone. ${link('Exact source identity','r2/source_identity.json')}, ${link('reviewable correction','r2/production_correction.patch')}, ${link('complete code audit','AUDIT.md')}.

The existing two commits add complete eligible physical32K SRAM transfers, independent of mapper visibility, video marker484314, old484311 recognition, and SystemE/SC/EEPROM/Evolution exclusions. Against FM baseline they change onlySMS.sv andrtl/savestates.sv. The additional correction changes onlyrtl/savestates.sv (7insertions/5deletions): both owned FM tags now require the existing audio completion commit, and the read-command guard matches rejection conditions. It introduces no new storage, format marker, FM payload, CPU restart or video-history machinery.

The demonstrated defect was an interrupted overwrite of an older FM484311 slot: after audio invalidation, but before video-tag replacement,69edeb48 accepted the remaining old owned tag as loadable. ${link('Failing pre-correction witness','interrupted_older_fm_probe.log')} and ${link('corrected rejection','r2/interrupted_older_fm_fixed.log')}. Positive old-FM states remain accepted.

## Functional qualification

${suites}
All listed cases ran successfully on the corrected source. The51-case matrix is ported from the previous controller fixtures to the production FM/SRAM format; old experimental CPU-context inputs are inert, and their malformed-format checks are replaced by applicable FM/audio/SRAM checks. This is not a claim that the old CPU predecessor correction is included or fixed.

BUSY tests assert registered-request stability and full byte-exact32K transfer. Interrupted SAVE boundaries cover invalidation, video, partial/last SRAM, descriptor, commit, header, blocked commit and before invalidation. Interrupted LOAD followed by retry restores the complete image. Exclusion tests preserve old behavior; legacy mapper tests cover disabled SRAM, Sega16/32/bank1, DahjeeA8, Codemasters8 and Castle32, including old64K Dahjee-only handling. Mapper restoration precedes all SRAM writes; all32768 writes occur while frozen and before CPU restore.

The live-FM tests use actual OPLL and an independent100-word internal oracle plus continuation audio. Native-flush case:3captures,4restores,374201checks. Additional modes cover ordinary/SystemE/BIOS/rhythm/key-release/reset/FM-disabled behavior. The extra mode sweep uses the existing fast-only900000-to90 flush adapter andNCONT5000; it is a diagnostic, not a hardware transfer-time measurement. The original FM fixture schedules endpoints with cooldown forced0; controller stress and the movie retain native cooldown. Only one completed native matrix case is counted, not the original larger plan or its cancelled next attempt.

${link('Functional gate and complete-memory hashes','r2/functional_gate.json')}, ${link('independent slot validation','r2/saved_slot_validation.json')}.

## Actual-controller playable Ys experiment

Standard USA/Europe/Brazil ROM, SHA25602e9404e81bddd4ca21fef2b2711dfe562c3bd7b230bf042df3142362e29a6a9, read locally without modification or distribution. NTSC/export, BIOSoff, turbooff, normal eight sprites. Reused qualified first-town fixture comes from two identical cold runs reaching the playable map at frame150, rather than the earlier frame60 startup endpoint. A legacy controller slot and a separately captured physical SRAM image initialize each run once; unmarked tail bytes are not treated as SRAM. Each variant then generates its own independent valid SAVE with identical comparable captured state.

SAVE in initial town; UP112frames through north gate; neutral40frames outdoors; LOAD own state; neutral5; LEFT8; RIGHT80; DOWN16; RIGHT64. The down/right leg clears a tree and forces real newly exposed map columns. This is not a startup-only or no-update trial. Same ROM/configuration/input schedule is used for baseline, candidate and uninterrupted reference.

| Observation | FM baseline | Corrected candidate |
|---|---:|---:|
| SRAM enable at SAVE/LOAD |0|0|
| Physical bytes differing from SAVE immediately after LOAD |1479|0|
| SRAM DDR words transferred each direction |0|4096|
| First rendered frame versus reference |exact|exact|
| All46 compared rendered checkpoints versus reference |corruption reproduced|pixel-exact|
| Final VRAM byte differences |${movie.comparisons.e_baseline_vs_e_reference.checkpoints.find(q=>q.label==='end').memory.VRAM.count}|0|
| Final WRAM byte differences |${movie.comparisons.e_baseline_vs_e_reference.checkpoints.find(q=>q.label==='end').memory.WRAM.count}|0|
| Final physical SRAM byte differences |1479|0|

The first stale source read is physical0419: baseline00, saved town80, candidate80. Natural environment history changes889 bytes in cache0400–07FF and1479 physical bytes overall. Both banks are captured and hashed, including currently inaccessible banks. First raw name-table difference3821 (00/80) involves unused rendering bits; the first rendering-relevant tile is${first.other.address.toString(16).toUpperCase()}: baseline${first.other.data.toString(16).toUpperCase()} versus candidate/reference${first.sram.data.toString(16).toUpperCase()}. The trace connects SRAM0462→WRAMD820→CPU VDP data port→VRAM3A20. The CPU supplies the wrong tile before the VDP write, rejecting a speculative VDP address-increment/background-history cause for this reproduced failure.

Candidate matches all${gate.renderedCheckpointsExact} rendered checkpoints, all${movie.runs.e_sram.events.counts.P} CPU VDP writes with their address/latch observations, all${movie.runs.e_sram.events.counts.V} VRAM writes, and complete SRAM/mapper transaction streams in normalized event order. Final${gate.finalMemoryBytesExact} modeled VRAM/WRAM/SRAM bytes are identical. Both candidate and baseline produce actual map writes. The baseline ends with${finalA.pixels.mapPixels} differing map-area pixels and${finalA.pixels.HUDPixels} HUD differences; that pixel count includes sprite differences, while the tile-write trace separately proves background corruption. The correction eliminates the first relevant divergence throughout the complete movie rather than merely delaying it.

Some internal CPU/VDP transient state is not cycle-identical: an IRQ/polling fetch difference and intermediate stack-area WRAM differences are retained in the trace report. They do not change the complete relevant transaction streams, any compared image or final memory. No CPU predecessor/NMI/clock/background/sprite mechanism is bundled into the correction. The separate previously demonstrated predecessor defect remains outside this fix.

${link('Complete comparisons and source-line evidence','r2/e_map_comparison.json')}, ${link('first map-column trace','r2/first_map_column_evidence.json')}, ${link('baseline final image','r2/e_baseline_clear_right64.png')}, ${link('candidate final image','r2/e_sram_clear_right64.png')}, ${link('reference final image','r2/e_reference_clear_right64.png')}.

## Format and compatibility

File size remains98304bytes (96KiB), header24574 32-bit words excluding control word. SRAM0D01–1D00 is disjoint from FM descriptor2997/payload2998–29C9. Public FM descriptor remains100words/version1/FMS1; optimized storage and all FM validation masks/apply behavior remain intact.484314 plus valid audio completion means complete eligible physical SRAM. Missing/invalid completion rejects before live restore; committed484311 and untagged/old64 formats retain their old conditional SRAM footprints. Older saves missing hidden SRAM cannot be repaired by a new reader. Fresh states are required for a meaningful Ys fix test. Older readers do not understand484314 and are not safe forward-compatible readers of new states.

The commit marker proves the producer finished under the existing ordered DDR contract; it is not a checksum or an atomic rollback mechanism. An interrupted/failed LOAD can already have changed memory, as in the existing FM baseline. Retry behavior is tested, not rollback. Untagged legacy images have no owned completeness contract; their fallback is deliberately retained.

## Matched Quartus qualification

Quartus Prime Lite17.0.2 Build602, CycloneV5CSEBA6U23I7, fixedBUILD_DATE261114, seeds1/2/3. Fresh corrected candidate exports use identical QSF/QIP/SDC/IP/dependency/settings to the verified FM baseline. Prior8cd53ccc candidate builds frompr227_matched_20261114 are reused as this task's **FM baseline**, after verifying every input/report/tool hash; its master baseline and historical v19 builds are not used. OnlySMS.sv andrtl/savestates.sv differ. ${link('Input/tool provenance','physical_r2/provenance.json')}, ${link('verified baseline reuse','physical_r2/baseline_reuse.json')}.

B=FM baseline, C=corrected candidate. Actual measured values:

${resource}
${timing}
All three fit and complete timing analysis. Constrained setup/hold TNS is0 and no negative timing entries remain. Raw per-clock timing, unconstrained-path information and report hashes are retained in ${link('measurements','physical_r2/measurements.json')}. A successful analyzer run is distinguished from passing timing.

${warnings}
Full warning texts, newly differing messages and controller/FM hierarchy rows are in ${link('paired comparison','physical_r2/comparison.json')}. Any new warnings required explicit review before artifact promotion. Existing unconstrained I/O and critical warnings are not hidden by the aggregate slack table.

Baseline seed spread: neededALMs${fmt(physical.ranges.neededALMs.baseline.span)}, placedALMs${fmt(physical.ranges.placedALMs.baseline.span)}, fitted registers${fmt(physical.ranges.fittedRegisters.baseline.span)}. Candidate spread: neededALMs${fmt(physical.ranges.neededALMs.candidate.span)}, placedALMs${fmt(physical.ranges.placedALMs.candidate.span)}, fitted registers${fmt(physical.ranges.fittedRegisters.candidate.span)}. Paired average needed-ALM delta${delta(physical.ranges.neededALMs.meanPairedDelta)}, placed-ALM delta${delta(physical.ranges.placedALMs.meanPairedDelta)}. Placed/fitted differences include packing/routing seed variability; they are not an exact standalone logic-cost estimate. Mapped-register and memory/DSP deltas are measured separately in the table. No full-v19 storage was imported.

## Transfer overhead

Native controller fixture with mapper disabled and BUSY0/three-clock read response: baseline SAVE${ac[0]}/LOAD${ac[1]} clocks; candidate SAVE${bc[0]}/LOAD${bc[1]}. Measured increment: SAVE${extra[0]}, LOAD${extra[1]} host clocks, plus32768bytes/4096 DDR64 words each direction. At nominal53.7MHz the clock deltas correspond theoretically to${(extra[0]/53700).toFixed(3)}ms SAVE/${(extra[1]/53700).toFixed(3)}ms LOAD. These are not measured physical MiSTer latency figures; real DDR backpressure adds variation. File size and optimized FM payload size do not grow.

## Experimental RBF and hardware handoff

Primary: ${link(primary.file,'release/'+primary.file)}. SHA256\`${primary.SHA256}\`. Source HEAD plus patch and exact tool/seed/settings are in ${link('release manifest','release/MANIFEST.json')}; all three qualified seed artifacts are preserved. The retained261114 OSD date is intentional for matched compilation, not the experiment's run date. Identify the experiment by unique filename and SHA.

${link('Hardware test procedure','HARDWARE_TEST.md')} covers fresh independent standard/hack/Japanese states, environment-change and reset→LOAD, DoubleDragon/CaliforniaGames FM restoration, FM-disabled behavior and older-state limitations. Standard simulation only is claimed; Japanese/FM-hack map execution and actual hardware behavior remain unverified. The map memory service is simplified synchronous ROM/WRAM/SRAM plus deterministic DDR, with opaque PSG and a zero FM endpoint; audible FM is verified separately with actual OPLL. This is a GO for hardware testing, not a hardware PASS or permission to merge/push/publish.

${link('Preservation verification','preservation_final.json')} confirms only the authorized RTL correction differs; master/FM refs, sys/, protected reports and existing rootRBFs remain unchanged. No new commits, pushes, merges, PR writes or existing-worktree resets were performed.

Automatic approval review rejected copying the supplied real save into a raw local fixture, citing the read-only/no-raw-copy constraint. That actual-file transport check was not run. Read-only metadata confirms its existing audio commit and public-v1 descriptor; completed synthetic older-format tests provide the compatibility evidence used here.
`;
fs.writeFileSync(p.join(d,'REPORT.md'),text,{flag:'wx'});console.log('Wrote final technical report from actual functional, physical and artifact records.');
