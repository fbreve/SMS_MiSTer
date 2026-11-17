# Public FM v1 candidate: preparation and focused validation

Prepared on 2026-11-12. Candidate branch: `integration/ym2413-public-v1`. Worktree: `tests/ym2413_public_v1_integration/worktree`. HEAD remains pinned baseline `9873761503510e4b2c7e06600bf5515344235c2f`; no commit was made. C1 seed-1 physical testing PASS is recorded as user-reported evidence, without claiming a new v1 hardware test.

## Exact production scope

Only these five approved C1 production changes are present relative to the pinned baseline:

| File | Relative to validated C1 |
| --- | --- |
| rtl/VM2413/outputgenerator.vhd | Byte-identical |
| rtl/VM2413/outputmemory.vhd | Byte-identical |
| rtl/VM2413/temporalmixer.vhd | Byte-identical |
| rtl/opll_snapshot.sv | Byte-identical |
| rtl/savestates.sv | One descriptor-version byte change and three version comments |

The sole executable difference from C1 is:

```diff
-localparam [63:0] FM_DESC = {16'd100,8'd20,8'd1,32'h464d5331};
+localparam [63:0] FM_DESC = {16'd100,8'd1,8'd1,32'h464d5331};
```

Descriptor value: `64'h00640101464d5331`. Public v1 is the first intended public FM format. Versions 17, 18 and 20 remain unsupported local experiments; no compatibility decoder was added. The 100-word/50-transfer layout, 0x2997 descriptor address, 0x2998..0x29c9 payload, word masks, SlotCounter state, OutputMemory collision guard, MLAB implementation and remaining logic memories are unchanged from C1. Existing non-FM legacy handling is unchanged.

Exact baseline-to-candidate patch: [production.patch](production.patch), 5 files, 15 insertions / 56 deletions. Exact C1-to-candidate patch: [c1_to_public_v1.patch](c1_to_public_v1.patch). Source hashes: [candidate_manifest.json](candidate_manifest.json). Reversing only the descriptor byte and three comment labels reproduces the complete C1 savestates.sv text exactly; the other four files match raw hashes.

All verification scripts, generated/compiled libraries, fixtures, logs, audit documents and result manifests are outside the integration worktree. Its Git status lists only the five approved RTL files. No main workspace, C1, B1, baseline, sys/ or previous experiment was edited.

## Focused simulation results

All ten final invocations passed, with zero simulation errors and explicit exit status 0:

| Invocation | Coverage/result |
| --- | --- |
| compile | Fresh production-derived fixtures and independent reference libraries compile. |
| protocol | Independent public-v1 descriptor literal accepted; exact 100-word capture/apply; v17/v18/v20 and v17 with a 100-word count rejected; wrong owner/payload/tag cases rejected before any live-state write; 64/96 KiB non-FM legacy fallback passes. Native FLUSH_MAX retained. |
| guard_protocol | A/B collision counterexamples reject; stage-zero pending write and back-to-back valid recovery pass; experimental descriptors reject; no live non-FM/FM writes on rejected cases. |
| map | Eight independent injected patterns, 800 word checks, 100-word capture/apply, moved word 79 and boundaries 78/79/98/99 match the unchanged independent C1 map. |
| nonfm | Eight comparative cases covering System E, BIOS, slots and stalls pass against preserved non-FM reference behavior. |
| validator_stream | Actual production validator accepts 6,912 coherent/guarded payloads; rejects both A/B payloads; no live FM writes. |
| early_validator | 432 early/coherent payloads accepted by production validator; no live FM writes. |
| guard_live | Live OPLL + native DDRAM transport: public-v1 save/load and internal/audio oracle checks; explicit experimental v17/v18/v20 rejection; A/B rejection; legacy tail ignored. 14 oracle checkpoints, 149,361 audio checks, 3 captures. |
| atomicity_public_v1 | Descriptor and late-payload rejection: shadow changed, zero live writes. Forced late DDRAM timeout: eight VRAM byte writes, zero CPU/FM apply, freeze released. |
| atomicity_baseline | Same rejection/timeout behavior reproduced from pinned baseline RTL in a separate simulation library. |

The only warning in guard_live is the ModelSim Starter Edition recommended design-capacity warning (13,051 statements); simulation completed normally. Initial audit-fixture compile/layout assertion errors were corrected only in external test fixtures; those failed attempts remain preserved in named failed-attempt directories. They were not production RTL failures.

Final logs, PASS evidence, exit statuses and SHA-256 hashes are in [focused_results.json](focused_results.json). Exact tested source/tool hashes are in verification_source_manifest.json. Runners use sequential Idle-priority ModelSim execution; no Quartus tool was invoked. New fixtures use public-v1 expectations rather than the inherited stale v17/104-word protocol fixture.

C1's existing 72/72 differential campaign is reused for unchanged payload, local map, omitted-state convergence and OPLL logic. The full 72-phase campaign was not repeated: the changed executable bits affect only descriptor save/acceptance, which the new focused protocol/live tests exercise. Existing three-seed timing and physical PASS remain C1/v20 evidence, not v1 build results.

## Rejected LOAD conclusion and recommendation

See [LOAD_AUDIT.md](LOAD_AUDIT.md) for source ordering, live/shadow distinctions, baseline comparisons, implementation options, resource estimates and compatibility implications.

An invalid FM descriptor, malformed FM payload or A/B collision counterexample is rejected before any live RAM/core apply. Snapshot registers and FM scratch can change, but the focused all-write-interface monitors confirm they are not applied live. The existing early FM-validation pass already provides the proposed lightweight prevalidation.

A later DDRAM failure during live RAM streaming can leave a partial restore. Both v1 and baseline fault-injection runs reproduced eight VRAM bytes changed while CPU/FM were not applied. This is inherited non-transactional I/O failure behavior, not a new v1 descriptor defect. Recommendation: retain the existing FM prevalidation and document late transport-failure recovery limitations; a general rollback/transactional LOAD guarantee would require a separately approved architecture change. No such change was implemented.

## Preservation and readiness

All 17 pre-existing worktrees retain their original HEADs, tracked status and diff hashes. Master is unchanged. Main-workspace tracked file hashes remain unchanged from the start of this task, including the previously repaired comments. 1,514 preserved historical source/tool/report/artifact hashes verify.

The C1 seed-1 RBF remains experimental v20 and is byte-identical:

```text
tests/ym2413_b1_c1_seed_study/seed1/c1/output_files/SMS.rbf
7f4ba7e188c99a5ae623e49e4df4311084a23fbd47404a93de3ab974e728fafa
```

The candidate is prepared and focused-simulation validated for the next separately authorized Quartus build, with the documented inherited timeout limitation. **No v1 RBF exists from this work, no Quartus timing/resource result is claimed for v1, and no compilation or architectural fix was started.** A final v1 build must use its own source manifest, reports and RBF hash; its actual timing and memory inference must be checked. No commits, merges, pushes or PRs were made.
