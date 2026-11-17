const fs=require('fs'),p=require('path'),cp=require('child_process'),assert=require('assert'),crypto=require('crypto');
const d=__dirname,root=p.resolve(d,'../..'),old=p.join(root,'tests/ys_fm227_validation_20261115'),read=f=>JSON.parse(fs.readFileSync(f));
const identity=read(p.join(d,'identity_after.json')),reg=read(p.join(d,'regression_results.json')),physical=read(p.join(old,'physical_r2/comparison.json')),upstream=read(p.join(d,'upstream_pr227_status.json'));
const sha=b=>crypto.createHash('sha256').update(b).digest('hex');
for(const [f,h]of Object.entries(identity.source))assert.equal(sha(fs.readFileSync(p.join(root,f))),h,f+' changed after commit');
for(const [f,h]of Object.entries(identity.protectedHashes))assert.equal(sha(fs.readFileSync(p.join(old,f))),h,f+' protected artifact changed');
assert.equal(cp.execFileSync('git',['diff','--name-only'],{cwd:root}).toString().trim(),'');
assert.equal(cp.execFileSync('git',['diff','--cached','--name-only'],{cwd:root}).toString().trim(),'');
assert.equal(reg.status,'PASS');assert.equal(reg.cases,108);assert.equal(reg.sourceCommit,identity.head);assert.equal(identity.head,cp.execFileSync('git',['rev-parse','HEAD'],{cwd:root}).toString().trim());assert.equal(upstream.response.merged,false);assert.equal(upstream.response.head_sha,'8cd53ccc954c24970372ea6d8a3fb2336a14c46f');
cp.execFileSync('git',['diff','8cd53ccc954c24970372ea6d8a3fb2336a14c46f','HEAD','--check'],{cwd:root});
const patch=cp.execFileSync('git',['diff','--binary','8cd53ccc954c24970372ea6d8a3fb2336a14c46f','HEAD','--','SMS.sv','rtl/savestates.sv'],{cwd:root});fs.writeFileSync(p.join(d,'UPSTREAM_DIFF.patch'),patch,{flag:'wx'});
let table='| Metric | B1 | C1 | Delta | B2 | C2 | Delta | B3 | C3 | Delta |\n|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|\n';
for(const [k,label]of Object.entries({neededALMs:'Needed ALMs',placedALMs:'Placed ALMs',mappedRegisters:'Mapped registers',fittedRegisters:'Fitted registers',logicALUTs:'Logic ALUTs',routingALUTs:'Routing ALUTs',M10K:'M10K',memoryBits:'Memory bits',DSP:'DSP',worstSetup:'Setup slack ns',worstHold:'Hold slack ns',setupTNS:'Setup TNS',holdTNS:'Hold TNS'}))table+='|'+label+'|'+physical.pairs.flatMap(q=>[q.baseline[k],q.candidate[k],Number(q.delta[k].toFixed(3))]).join('|')+'|\n';
const text=`# Ys SRAM fix consolidation — 2026-11-16

**GO for publication readiness as an independent SRAM correction dependent on PR #227.** No push or PR was performed. PR #227 remains open and unmerged; an independent upstream-master PR must wait for that dependency or use an upstream-supported stacking arrangement. The current upstream-master diff would include FM, so it must not be presented as SRAM-only.

## Source and hardware identity

Branch: \`fix/ys-physical-sram-on-fm-pr227\`. Final HEAD: \`${identity.head}\`. Parent: \`69edeb48455820d3119ab54d052bf3de906c91fa\`. New commit: \`Reject incomplete owned FM savestate images\`.

The new commit records exactly the previously qualified uncommitted correction: 7 insertions / 5 deletions in \`rtl/savestates.sv\`. No behavior changed during consolidation. Both FM tags require audio completion; the combinational read gate and sequential error path agree. Untagged legacy fallback is retained. [Original patch](../ys_fm227_validation_20261115/r2/production_correction.patch) SHA-256: \`${identity.originalPatchSHA256}\`.

The complete diff against exact FM baseline \`8cd53ccc954c24970372ea6d8a3fb2336a14c46f\` changes only:

- \`SMS.sv\`: two necessary SC/EEPROM eligibility signals.
- \`rtl/savestates.sv\`: full physical SRAM transfer, format recognition, completion checks and comments.

Total: 40 insertions / 18 deletions across two files. [Reviewable baseline diff](UPSTREAM_DIFF.patch). No CPU, VDP, audio source or full-v19 snapshot machinery is added. Git whitespace checks pass. The tracked working tree is clean; existing untracked tests and \`SMS_ym2413_test_s1.rbf\` were left in place and not staged.

Both working RTL files and the committed files reproduced through Git checkout filters are byte-identical to the qualified compiled inputs. Git blobs are LF and the original Windows inputs are CRLF; canonical LF hashes are separately recorded rather than incorrectly comparing raw LF and CRLF bytes. [Before](identity_before.json) / [after](identity_after.json) checks also preserve original reports, manifest, all three RBFs, master/FM refs and sys tree. The original patch SHA matches the pre-commit diff exactly.

[Hardware PASS addendum](HARDWARE_PASS.md): the user confirmed successful real MiSTer testing of the original seed-1 RBF, SHA-256 \`3ebda245e566f22ed2ec1b363359b58f9f83804ad83c5ce83626d431eef103bd\`. No per-game, per-reset or FM-specific results were supplied; none are invented. Original report/manifest statements reflect their earlier creation time and are preserved, not rewritten. No RBF was rebuilt or replaced merely to change its commit identifier.

## Functional recheck

[Fresh post-commit results](regression_results.json): **108 cases PASS** — 51 controller matrix, 10 older-FM interrupted-overwrite boundaries, 28 legacy mapper footprints, 16 stalled/interrupted/repeated-LOAD/eligibility/bank cases, two exclusion-equivalence tests and one restore-ordering test. Fresh simulation sources were copied into this isolated directory; the production-derived simulator adapter is text-identical to the qualified adapter. Both-marker interruption protection, valid committed older FM, mapper-hidden/banked physical memory, excluded modes and legacy behavior are covered.

Existing playable Ys and actual OPLL evidence is reused, not claimed as freshly rerun. Source identity is exact. The [original qualification report](../ys_fm227_validation_20261115/REPORT.md) records the actual-controller playable map reproduction, SRAM 0462 → WRAM D820 → VRAM 3A20 causal trace, all 46 rendered checkpoints and final 73,728 modeled VRAM/WRAM/SRAM bytes matching uninterrupted execution. The baseline retained 1,479 stale SRAM bytes and corrupted the newly exposed map. Existing focused actual-OPLL suites, seven mode cases and one completed native-flush case remain applicable. Movie memory services and accelerated FM mode tests retain their documented limitations; no new graphics run or hardware per-game matrix is claimed.

## Format and compatibility

The file remains 96 KiB. Eligible physical 32 KiB SRAM is captured independently of mapper enable/bank visibility; System E, SC-3000, EEPROM and Evolution are excluded from this new path. Marker 0x484314 means FM plus complete SRAM; old 0x484311 and legacy formats keep their old SRAM footprints. Both owned FM tags require the existing audio completion commit, preventing interrupted overwrites of old FM slots from being accepted. FM payload, descriptor and optimized storage remain unchanged.

Fresh saves are required to preserve hidden SRAM absent from old snapshots. New saves require the new reader. The completion marker is not a checksum or rollback contract. A transport failure during LOAD can leave partially restored memory, as in the FM baseline; retry is covered. The optional real supplied-save raw-fixture test was not run in the original qualification after automatic review rejected copying it; read-only metadata and synthetic compatibility evidence remain the stated scope.

## Retained three-seed Quartus comparison

Exact matched FM baseline; Quartus Prime Lite 17.0.2 Build 602, Cyclone V 5CSEBA6U23I7, fixed BUILD_DATE=261114, seeds 1/2/3. These are actual retained measurements, not estimates or new builds. B=FM baseline, C=qualified SRAM candidate.

${table}
All three passed constrained timing with zero setup/hold TNS and no negative timing entries. **Seed 2 has only +0.053 ns setup slack.** Seed 1, the hardware-tested artifact, has +0.381 ns setup / +0.244 ns hold. There are 40 unique inherited critical-warning texts per variant/seed and zero new texts; unconstrained paths remain outside constrained-timing qualification.

Mapped registers increase by two for every seed. M10K, memory bits and DSPs are unchanged. Needed-ALM deltas are −82/+2/−100; placed-ALM deltas −8/−6/+46. Mean needed delta −60 and placed delta +10.667 must not be interpreted as a standalone gate-cost reduction: packing/seed variability affects placement. Baseline needed/placed spans are 80/85 ALMs; candidate spans 48/83. No new full-state storage is introduced.

Extra transfer: 32,768 bytes / 4,096 DDR64 words each direction with mapper SRAM disabled, without enlarging the file. Measured fixture increments: SAVE +36,868 host clocks, LOAD +53,248. Nominal 53.7 MHz equivalents (0.687/0.992 ms) are theoretical conversions, not measured hardware latency.

[Paired measurements and warnings](../ys_fm227_validation_20261115/physical_r2/comparison.json), [per-clock timing](../ys_fm227_validation_20261115/physical_r2/per_clock_timing.csv), [original manifest](../ys_fm227_validation_20261115/release/MANIFEST.json). No expensive compilation was repeated because committing did not change the inputs.

## Publication path and remaining limitations

[PR #227](https://github.com/MiSTer-devel/SMS_MiSTer/pull/227) checked read-only on 2026-11-16: open, merged=false, head 8cd53ccc954c24970372ea6d8a3fb2336a14c46f, upstream base 66f16d5c656fd8906d62570da4d258875bcee684. [Metadata](upstream_pr227_status.json). Retain this FM head as the dependency/review base. No rebase is warranted now and none was attempted. After it merges, verify the resulting upstream content before any rebase; do not assume a future merge preserves the qualified input. If a rebase changes implementation, qualification must be reassessed.

[Draft PR title/description](PR_DRAFT.md) is ready for review. Publication is technically GO with the declared dependency and timing/compatibility limitations, but no new upstream PR, push or merge is authorized by this consolidation. For a genuinely SRAM-only PR against upstream master, wait for PR #227 to merge. Hardware confirmation is user-reported and not a detailed per-game test matrix. Seeds 2/3 were not hardware-tested. The separate CPU predecessor defect is not fixed here.
`;
fs.writeFileSync(p.join(d,'REPORT.md'),text,{flag:'wx'});
console.log('Wrote final report and independent two-file diff; preserved prior artifacts.');
