# Complete upstream file audit

Baseline: `66f16d5c656fd8906d62570da4d258875bcee684` (both local master and origin/master; no remote fetch performed). Source implementation: hardware-validated public v1 worktree. This audit covers the complete implementation, not only the five-file C1 optimization layer.

## Included production files

| File | Classification | Reason | Added/deleted lines |
| --- | --- | --- | --- |
| SMS.sv | Required FM implementation | Connect the system wrapper and savestate controller with FM address/data/read/write, readiness and legacy-reset signals. | +11 / -2 |
| files.qip | Required FM implementation | Include the new sequential opll_snapshot transport in the Quartus project. | +2 / -0 |
| rtl/VM2413/attacktable.vhd | Required FM implementation | Freeze and restore attack-table pipeline; serialize words 91..92. | +86 / -23 |
| rtl/VM2413/controller.vhd | Required FM implementation | State access for register/user-voice memories and controller words 80..85; freeze merged controller processes; combine readback/readiness. | +361 / -123 |
| rtl/VM2413/envelopegenerator.vhd | Required FM implementation | Freeze/apply envelope generator words 86..90; expose attack-table and envelope-memory state/readiness. | +164 / -43 |
| rtl/VM2413/envelopememory.vhd | Required FM implementation | Read/write envelope-history words 31..48 while frozen and expose initialization readiness. | +37 / -6 |
| rtl/VM2413/feedbackmemory.vhd | Required FM implementation / implementation constraint | Serialize feedback-history words 49..57; preserve logic ramstyle and fixed-latency access. | +35 / -4 |
| rtl/VM2413/lineartable.vhd | Supporting FM interface alignment | Only output modes change from out to buffer to match validated component declarations; no snapshot payload added here. Retained, not refactored. | +3 / -3 |
| rtl/VM2413/operator.vhd | Required FM implementation | Serialize operator words 96..97, freeze operator pipeline and expose sine-table state/readiness. | +100 / -22 |
| rtl/VM2413/opll.vhd | Required FM implementation | Expose state bus, combine all child readback/readiness, freeze command latch word 77 and connect delayed counters/submodules. | +204 / -53 |
| rtl/VM2413/outputgenerator.vhd | Required FM implementation / optimization correctness | Serialize pending feedback/output writes at word 79; connect feedback and MLAB OutputMemory state; preserve required pending-write recovery. | +121 / -23 |
| rtl/VM2413/outputmemory.vhd | Required FM implementation / optimization | Serialize words 58..75; switch data_array to MLAB. Safety depends on the preserved same-transfer stage-zero guard. | +37 / -6 |
| rtl/VM2413/phasegenerator.vhd | Required FM implementation | Serialize phase/noise generator words 93..95 and expose phase memory/readiness while frozen. | +115 / -18 |
| rtl/VM2413/phasememory.vhd | Required FM implementation / optimization | Serialize words 13..30; expose readiness; retain AUTO memory inference rather than forcing logic. | +37 / -6 |
| rtl/VM2413/registermemory.vhd | Required FM implementation / documentation | Retain all ss_* ports, frozen RAM read/write, 22-bit packed fields, initialization and logic ramstyle. Copy only the intentional SRAM comment translation from main, not its different executable logic. | +36 / -5 |
| rtl/VM2413/sinetable.vhd | Required FM implementation | Freeze/read/write sine interpolation pipeline words 98..99; expose state/readiness. | +97 / -24 |
| rtl/VM2413/slotcounter.vhd | Required FM implementation / optimization correctness | Serialize shared word 78; restore delayed counters coherently modulo 72 and freeze counting. | +56 / -10 |
| rtl/VM2413/temporalmixer.vhd | Required FM implementation / optimization | Freeze live mixer with the core; intentionally serialize none of mute/maddr/mix/mixout; return zero local readback and preserve convergence behavior. | +62 / -35 |
| rtl/VM2413/vm2413.vhd | Required FM interface declarations | Update shared OPLL component ports and buffer modes consistently with entity/instantiations. | +12 / -3 |
| rtl/VM2413/voicememory.vhd | Required FM implementation | Serialize user-voice words 9..12, freeze writes and expose initialization readiness. | +40 / -8 |
| rtl/VM2413/voicerom.vhd | Supporting FM interface alignment | Only data port mode changes from out to buffer to match the validated voice-memory component declaration; no ROM-content change. | +1 / -1 |
| rtl/opll_snapshot.sv | Required FM implementation / optimization | Sequential 256x32 M10K transport scratch, 100-word capture/apply, refill and deterministic legacy fallback. | +92 / -0 |
| rtl/savestates.sv | Required FM implementation / correctness | Public v1 descriptor, 100 masks/ranges, 50-transfer state machine, discovery tag, initialized capture, early validation, collision guard and non-FM fallback. | +192 / -13 |
| rtl/system.vhd | Required FM implementation / correctness | Wire OPLL freeze, readback and apply; capture/restore FM bus latch word 76; deterministic legacy reset/initialization and FM clock-enable control. | +28 / -4 |

## Documentation

| File | Classification | Reason |
| --- | --- | --- |
| README.md | Documentation | Link the public FM v1 format and compatibility notes. |
| docs/ym2413-savestates-v1.md | Documentation | Descriptor fields, word map, 400-byte/50-transfer payload, memory/guard constraints, non-FM fallback, experimental rejection, mixer convergence and inherited transport failure limitation. |

## Excluded experimental files

All 18 files below were inherited by the private full-state branch but do not belong in this production candidate:

| File | Classification | Decision |
| --- | --- | --- |
| tests/ym2413_fullstate/.gitignore | Experimental verification infrastructure | Exclude entirely; preserve original outside candidate. |
| tests/ym2413_fullstate/campaign.ps1 | Experimental verification infrastructure | Exclude entirely; preserve original outside candidate. |
| tests/ym2413_fullstate/map.do | Experimental verification infrastructure | Exclude entirely; preserve original outside candidate. |
| tests/ym2413_fullstate/map_tb.sv | Experimental verification infrastructure | Exclude entirely; preserve original outside candidate. |
| tests/ym2413_fullstate/nonfm.do | Experimental verification infrastructure | Exclude entirely; preserve original outside candidate. |
| tests/ym2413_fullstate/oracle.tcl | Experimental verification infrastructure | Exclude entirely; preserve original outside candidate. |
| tests/ym2413_fullstate/phase_fixture.vhd | Experimental verification infrastructure | Exclude entirely; preserve original outside candidate. |
| tests/ym2413_fullstate/prepare_nonfm.js | Experimental verification infrastructure | Exclude entirely; preserve original outside candidate. |
| tests/ym2413_fullstate/prepare_patterns.js | Experimental verification infrastructure | Exclude entirely; preserve original outside candidate. |
| tests/ym2413_fullstate/prepare_phases.js | Experimental verification infrastructure | Exclude entirely; preserve original outside candidate. |
| tests/ym2413_fullstate/prepare_tests.js | Experimental verification infrastructure | Exclude entirely; preserve original outside candidate. |
| tests/ym2413_fullstate/protocol.do | Experimental verification infrastructure | Exclude entirely; preserve original outside candidate. |
| tests/ym2413_fullstate/protocol_tb.sv | Experimental verification infrastructure | Exclude entirely; preserve original outside candidate. |
| tests/ym2413_fullstate/results.js | Experimental verification infrastructure | Exclude entirely; preserve original outside candidate. |
| tests/ym2413_fullstate/run.do | Experimental verification infrastructure | Exclude entirely; preserve original outside candidate. |
| tests/ym2413_fullstate/run_all.ps1 | Experimental verification infrastructure | Exclude entirely; preserve original outside candidate. |
| tests/ym2413_fullstate/tb.sv | Experimental verification infrastructure | Exclude entirely; preserve original outside candidate. |
| tests/ym2413_fullstate/verify_scope.js | Experimental verification infrastructure | Exclude entirely; preserve original outside candidate. |

All historical RBFs, logs, reports, payloads, generated sources, test libraries and experiment directories remain external and are not copied. Main workspace uncommitted RTL variants are excluded, including alternate registermemory readback/hold logic. The SRAM comment alone is intentionally carried forward.

## Questionable or unnecessary details

- The validated VHDL contains broad out-to-buffer mode alignment, including lineartable.vhd and voicerom.vhd with no serialized state of their own. These small supporting files must not be accidentally omitted while their parent component declarations retain buffer modes. Whether the modes can be narrowed is a separate HDL interface refactor, not approved here.
- Existing generated-style formatting, blank lines, removed old explanatory comments, F01 internal labels and some apparently redundant helper variables/imports remain in the validated implementation. They add review noise; they were not cosmetically rewritten or deleted because the requested candidate must keep executable RTL identical and preserve mixed source encodings. No additional functional fix is proposed on this basis.
- No unrelated executable production changes were identified in the validated implementation beyond the FM state-access/freeze plumbing and its required memory, phase and pending-write handling. The stripped 18-file laboratory suite is not being presented as an upstream test suite.
- LOAD is not transactional under a late DDRAM transport timeout. This is documented explicitly; early malformed FM descriptor/payload rejection occurs before live restore writes. A rollback architecture or checksum format would require separate approval.

## Source equivalence and evidence

23 of the 24 copied production files are raw-byte identical to the validated public-v1 worktree. registermemory.vhd differs only in one comment at line 62, with before/after hashes recorded in clean_manifest.json. A byte lexer confirms all non-comment bytes, including whitespace and string literals, match. No executable change was discovered, so no repeat 72-phase campaign, simulation run or Quartus build was warranted.

Public v1 physical MiSTer testing PASS was reported by the user on 2026-11-13 for RBF SHA-256 `f91797c3860370d6d0ee377f6a5416a73a693ba6d52a902695f5ec041ec6a5a0`. The preserved binary was built from the original v1 source bytes; the clean source has a documented comment-only provenance bridge, not a newly built RBF identity.

Checks and source hashes: verification.json. Preservation snapshot: preservation_before.json. Exact complete candidate patch: upstream_candidate.patch.
