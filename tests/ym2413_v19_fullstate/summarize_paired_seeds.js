const fs=require('fs'),p=require('path'),crypto=require('crypto'),assert=require('assert');
const root=__dirname,hash=b=>crypto.createHash('sha256').update(b).digest('hex'),load=f=>JSON.parse(fs.readFileSync(f));
const original=load(p.join(root,'physical_seed1/inputs.json')),pairs=[];
for(const seed of [1,2,3]) {
 const dir=p.join(root,'physical_seed'+seed),m=load(p.join(dir,'inputs.json')),r=load(p.join(dir,'results.json'));
 assert.equal(m.seed,seed);assert.equal(r.identity.seed,seed);assert.equal(m.baseline,original.baseline);
 for(const v of ['baseline','candidate']) {
  assert(r.builds[v].complete);for(const [file,info]of Object.entries(m.builds[v].inputs)) {
   const bytes=fs.readFileSync(p.join(dir,v,file));assert.equal(hash(bytes),info.SHA256);
   if(seed!==1&&file!=='SMS.qsf')assert.equal(info.SHA256,original.builds[v].inputs[file].SHA256,'Non-seed input changed');
   if(seed!==1&&file==='SMS.qsf')assert.equal(hash(Buffer.from(bytes.toString().replace('set_global_assignment -name SEED '+seed,'set_global_assignment -name SEED 1'))),original.builds[v].inputs[file].SHA256);
  }
  assert.equal(String(r.builds[v].actualSeed[1]),String(seed));
 }
 const shadowmaskOSD={};for(const v of ['baseline','candidate']){const file=p.join(dir,v,'physical_shadowmask_osd.rpt');if(fs.existsSync(file)){const bytes=fs.readFileSync(file),match=bytes.toString().match(/Worst case slack is (-?[\d.]+)/);assert(match);shadowmaskOSD[v]={slack:+match[1],SHA256:hash(bytes),path:'physical_seed'+seed+'/'+v+'/physical_shadowmask_osd.rpt'};}}
 pairs.push({seed,inputsManifestSHA256:hash(fs.readFileSync(p.join(dir,'inputs.json'))),resultsSHA256:hash(fs.readFileSync(p.join(dir,'results.json'))),shadowmaskOSD,results:r});
}
const out=p.join(root,'paired_seed_study');assert(!fs.existsSync(out),'Refuse overwriting study artifacts');fs.mkdirSync(out);
const sourceId=load(p.join(root,'physical_seed1/artifact_identity.json'));
const artifacts=[];
for(const pair of pairs) {
 const b=pair.results.builds.candidate;if(!b.qualifiedConstrainedTiming)continue;
 const source=p.join(root,'physical_seed'+pair.seed,b.rbf.path);assert.equal(hash(fs.readFileSync(source)),b.rbf.SHA256);
 const name=`SMS_YM2413_FULLSTATE_104W_v17_66f16d5c_src${sourceId.sourceTreeSHA256.slice(0,12)}_Q17.0.2_seed${pair.seed}_TIMING_PASS_${b.rbf.SHA256.slice(0,12)}.rbf`;
 fs.copyFileSync(source,p.join(out,name));artifacts.push({seed:pair.seed,file:name,SHA256:hash(fs.readFileSync(p.join(out,name))),bytes:b.rbf.bytes,sourceRevision:original.baseline,completePatchSHA256:sourceId.completePatchSHA256,seed1SourceTreeSHA256:sourceId.sourceTreeSHA256,inputsManifestSHA256:pair.inputsManifestSHA256,resultsSHA256:pair.resultsSHA256,status:'CONSTRAINED TIMING PASS / NOT HARDWARE VALIDATED'});
}
fs.writeFileSync(p.join(out,'study.json'),JSON.stringify({baseline:original.baseline,FMreference:original.candidate.FMreference,toolVersion:original.version,device:original.device,scope:'Seeds 1, 2, 3 only; frozen RTL; QSF seed is sole input difference',pairs,artifacts},null,2)+'\n');
let text='# Full-state YM2413 matched three-seed study\n\n';
text+='Fresh seeds 2 and 3 use the exact frozen Seed 1 source inputs and compilation stages. Only the QSF seed differs. Baseline is upstream master `'+original.baseline+'`; candidate is its reviewed uncommitted 104-word/version-17 port. Quartus Prime Lite 17.0.2 Build 602, Cyclone V '+original.device+'. No RTL, test, shared sys or existing worktree files were edited. No retries, additional seeds, commits, merges or PRs.\n\n';
text+='| Seed | Build | Needed ALMs | Placed ALMs | Fitted registers | M10Ks | Setup WNS (ns) | Setup TNS (ns) | Hold WNS (ns) |\n|---|---|---:|---:|---:|---:|---:|---:|---:|\n';
for(const pair of pairs)for(const v of ['baseline','candidate']){const b=pair.results.builds[v];text+=`| ${pair.seed} | ${v} | ${b.neededALMs} | ${b.placedALMs} | ${b.fittedRegisters} | ${b.M10K} | ${b.setupSlack} | ${b.setupTNS} | ${b.holdSlack} |\n`;}
text+='\n## Assessment and recommendation\n\n';
text+='Recommend the preserved Seed 2 candidate for manual MiSTer validation: setup +0.367 ns, hold +0.244 ns, no reported constrained timing violations. Seed 3 also passes, but its +0.002 ns setup margin is only 2 ps and offers little margin. Hardware FM functionality remains untested. Seed 1 remains timing-failing and is not recommended.\n\n';
text+='Master passes all three seeds; candidate passes two of three. Candidate minus master WNS is -0.629, -0.306 and -0.317 ns (mean -0.417 ns). Candidate WNS spans -0.173 to +0.367 ns. The timing failure is placement-sensitive, while a lower timing margin is consistent across all matched pairs. Three seeds do not establish statistical robustness or isolate the cause of the whole-fit placement/routing change. Do not treat the result as evidence that the resource overhead has no timing cost.\n\n';
text+='All candidate worst paths remain in HDMI. Seed 1: shadowmask RAM to OSD h_cnt; Seed 2: scaler o_v_poly_t.r1 to o_v_poly_pix.r; Seed 3: shadowmask RAM to OSD dsp_width. Thus the exact Seed 1 worst endpoint does not recur as the worst endpoint, but the shadowmask-to-OSD path family recurs in Seed 3. Targeted shadowmask-to-h_cnt checks are recorded below. All FM/PhaseMemory/snapshot queries are positive; the worst FM-to slack is +2.261, +1.917 and +2.431 ns for seeds 1, 2 and 3. Core clock setup slack is +1.183, +0.719 and +1.361 ns. Hold timing passes in all runs.\n\n';
text+='The measured candidate overhead is +980 to +1050 needed ALMs, +982 to +1108 placed ALMs, +614 to +773 fitted registers, and exactly one M10K across seeds. Mapped-register overhead stays +481; physical-register variation reflects fitter optimization. PhaseMemory remains AUTO 18 x 18 simple-dual-port single-clock storage in one M10K, zero MLABs, with unchanged register/read-during-write settings. The additional memory is the 256 x 32 snapshot scratch RAM.\n\n';
text+='Actual fitter settings match within every pair, including the requested seed; expanded assignments differ only by the approved snapshot source. The reviewed production HDL is compiled, including rtl/opll_snapshot.sv. Seeds 2 and 3 add only the inherited full-state unused ss_v_ff_count warning relative to master, with no latch/multiple-driver/width diagnostics. Native reports stayed unchanged after read-only queries. Both builds retain the same external-I/O constraint gaps: 27 input ports/94 paths and 91 output ports/153 paths for setup and hold; no unconstrained clocks. Timing qualification is limited to existing project constraints.\n\n';
for(const pair of pairs)for(const [v,x]of Object.entries(pair.shadowmaskOSD))text+=`- Seed ${pair.seed} ${v}, targeted shadowmask-to-OSD h_cnt: ${x.slack} ns; [full path](../${x.path}).\n`;
text+='\n## Critical paths and FM checks\n\n';
for(const pair of pairs)for(const v of ['baseline','candidate']){const b=pair.results.builds[v];text+=`### Seed ${pair.seed}: ${v}\n\n`;for(const kind of ['setup','fm_from','fm_to','phase_from','phase_to','snapshot_from','snapshot_to']){const x=b.paths[kind]?.[0];if(x)text+=`- ${kind}: ${x.slack} ns; \`${x.from}\` to \`${x.to}\`.\n`;}text+='\nViolating groups: '+JSON.stringify(b.violations)+'.\n\n';}
text+='## Preserved timing-passing candidates\n\n';
for(const a of artifacts)text+=`- Seed ${a.seed}: [${a.file}](${a.file}); SHA-256 \`${a.SHA256}\`.\n`;
if(!artifacts.length)text+='None.\n';
text+='\nExact source hashes, tool identity, native reports, settings and logs are retained in each physical_seedN directory. study.json binds all result/input manifests and preserved RBFs. Existing unconstrained external I/O paths limit timing qualification; these builds are not hardware validation.\n';
fs.writeFileSync(p.join(out,'review.md'),text);console.log(text);
