# Final upstream integration preparation

Clean candidate: `tests/ym2413_upstream_v1_audit/worktree`.
Branch: `integration/ym2413-public-v1-upstream`.
Baseline/HEAD: `66f16d5c656fd8906d62570da4d258875bcee684`.

Both local master and origin/master resolve to the requested baseline. No remote fetch was performed. The candidate remains uncommitted, with an empty index. No PR was opened.

## Complete scope

The validated implementation differs from upstream in 24 production files, not five. All 24 are retained; the 18 inherited experimental verification files are excluded. The clean candidate adds only README documentation and `docs/ym2413-savestates-v1.md`, producing a 26-file proposed change. The new snapshot module and format document are deliberately untracked until a future approved staging/commit step; they are included in the complete review patch.

[FILE_AUDIT.md](FILE_AUDIT.md) classifies every included and excluded file, records line counts, and describes the supporting interface changes and review noise. [upstream_candidate.patch](upstream_candidate.patch) contains the complete proposed change, including both new untracked files. [PR_DRAFT.md](PR_DRAFT.md) contains the proposed title and reviewer-facing description.

## Intentional SRAM comment and existing modifications

The main workspace already contains the requested English comment. Its register-memory implementation also differs functionally from validated public v1. Copying that whole file would have changed the validated readback/freeze behavior, so only the comment was transplanted into the clean candidate's validated registermemory.vhd. All ss_* ports, packed-state access, initialization logic and logic ramstyle are retained.

The only production-text difference from validated v1 is now:

```vhdl
-- Channel information storage: single-read, single-write SRAM.
```

at `rtl/VM2413/registermemory.vhd:62`. Its before/after hashes and original CP932-decoded comment are recorded in clean_manifest.json. Other Japanese comments remain CP932; ASCII/SystemVerilog and UTF-8 system.vhd remain in their original encodings. Original mixed line endings are preserved, not normalized across the tree.

## Checks performed

- All 24 production files have identical executable and non-comment whitespace bytes to validated public v1. Twenty-three are raw-byte identical; registermemory.vhd differs only in the specified comment.
- All 109 other tracked production RTL/project/constraint files compared with the validated worktree are byte-identical.
- All 107 RTL paths expanded by the validated Quartus project are present. files.qip includes the snapshot transport, and OPLL component hierarchy sources are retained.
- Public descriptor v1, 100 words / 50 transfers, word-78 mask, same-transfer collision guard, MLAB/logic attributes, omitted TemporalMixer serialization and non-FM state-machine behavior remain unchanged.
- Exact 24 production + 2 documentation file scope; no tests, binaries, reports or sys/ changes. Git diff whitespace checks pass. New files are included in the review patch and manifest even though they are not staged.
- All ten preserved public-v1 focused simulation logs match their recorded hashes. The hardware-tested v1 RBF matches its expected SHA-256. No functional RTL delta was found, so no simulation, 72-phase campaign or Quartus build was repeated.
- All 18 pre-existing worktrees retain their HEADs, tracked status, diff hashes and index hashes. All 1,761 protected source/report/artifact hashes match the task-start snapshot, including main-workspace modifications, the intentional main SRAM comment, and both validated RBFs.

Machine-readable checks and source hashes: [verification.json](verification.json). Source-copy and exclusion manifest: [clean_manifest.json](clean_manifest.json).

## Review points and blockers

No functional or provenance blocker was found for the requested pinned upstream baseline. Hardware PASS is user-reported; no new hardware test is implied for the comment-only clean source. The existing RBF retains its original build-input hashes, linked to the clean candidate by executable-byte equivalence.

Some broad out-to-buffer mode alignment, generated-style formatting, removed historical comments and internal F01 labels remain in the validated VHDL. lineartable.vhd and voicerom.vhd have only supporting port-mode changes. They are identified for reviewer attention; removing them alone would leave mismatched validated component declarations, and a wider interface/style refactor was neither approved nor performed.

The inherited late-DDRAM-timeout partial-restore behavior is documented, not redesigned. Full transactional recovery is not a guarantee of this PR. Experimental FM descriptors have no public compatibility obligation and remain rejected; legacy non-FM images remain supported.

Before an eventual merge, confirm that upstream has not moved beyond the requested baseline and recheck the reviewed scope if it has. Any executable change introduced during review invalidates the no-rebuild justification and needs appropriate focused validation. Staging, committing, pushing, opening a PR and merging remain explicit future actions; none was performed here.
