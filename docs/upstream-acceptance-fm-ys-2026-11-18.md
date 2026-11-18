# Upstream acceptance — YM2413 FM savestates and Ys SRAM fix (2026-11-18)

## Status

Both changes were accepted into the official [MiSTer-devel/SMS_MiSTer](https://github.com/MiSTer-devel/SMS_MiSTer) repository on **2026-11-18 (UTC)**.

| Change | Upstream PR | Submitted head | Status |
| --- | --- | --- | --- |
| Preserve YM2413 FM synthesis state across save/load | [#227](https://github.com/MiSTer-devel/SMS_MiSTer/pull/227) | `8cd53ccc954c24970372ea6d8a3fb2336a14c46f` | Merged, 2026-11-18 06:38:05 UTC |
| Preserve physical cartridge SRAM to fix *Ys* corruption after load | [#228](https://github.com/MiSTer-devel/SMS_MiSTer/pull/228) | `e8f957bd5286f7405a30605ed184d904a57cf042` | Merged, 2026-11-18 06:38:03 UTC |

The verified upstream `master` commit is [`bb77fbd8deca57e384d276e0ddb0454ee0242d32`](https://github.com/MiSTer-devel/SMS_MiSTer/commit/bb77fbd8deca57e384d276e0ddb0454ee0242d32). At closure, the fork `fbreve/SMS_MiSTer:master` was fast-forwarded to the **same SHA**, without rewriting history.

## Scope and provenance

- **FM:** YM2413 synthesis/snapshot capture and restoration, versioned descriptor, and compatibility handling for non-FM savestates. The PR describes differential simulation covering 72 FM phases, focused regressions, Quartus timing checks, and successful hardware testing. This closure note does not represent a new test run.
- **Ys / physical SRAM:** preserve the full 32 KiB physical cartridge SRAM across savestates, including mapper-hidden banks, to prevent graphical corruption after loading. The SRAM change was physically tested before submission. The preserved test-build reference is `tests/ys_fm227_validation_20261115/release/SMS_ys_sram_fm227_69edeb48_p8e59c978_s1.rbf` with SHA-256 `3ebda245e566f22ed2ec1b363359b58f9f83804ad83c5ce83626d431eef103bd`, as documented by the storage-cleanup report. Existing saves made without the required SRAM data may not provide complete restoration; prefer fresh savestates.

## Research and experiment archives

The pre-acceptance experiments and conclusions remain available via the fork's historical archive branches. Important records include:

- [Experimental worktree preservation report](https://github.com/fbreve/SMS_MiSTer/blob/archive/20261117/cleanup-report/tests/worktree_cleanup_20261117/REPORT.md).
- [Scientific artifact preservation and storage cleanup report](https://github.com/fbreve/SMS_MiSTer/blob/archive/20261117/tests-storage-cleanup/tests/tests_cleanup_20261117/REPORT.md).
- The original experimental branch commits and outcome reports referenced by those manifests.

Large scientific artifacts, compressed raw data, and historical binaries remain local for synchronization/backup and were **not** uploaded by this closure step. No further CPU/FPGA benchmarks, scientific runs, or hardware regressions were performed solely for closing these PRs.

## Post-merge follow-up

1. Treat #227 and #228 as integrated, not as pending changes.
2. Track new regressions against current official `master` and preserve minimal reproduction cases.
3. Keep archival research branches immutable; do not merge failed optimization experiments into production.
4. Update each local checkout only after inspecting its branch and working-tree state; no automatic reset or merge into an experimental checkout.
