# Preflight and controlled execution

Preflight passed on 2026-11-11. Production worktrees and previous experiments were read only.

Evidence: preflight_*.json records original reference identity (66f16d5...), installed executable hashes, reused result hashes, and B1/C1 source hashes. B1/C1 worktree HEAD is 9873761...; these are distinct identities. All frozen reference input and output report hashes and RBF hashes were checked for all three seeds. All reference QSF/SDC files match between baseline and full-state candidate. Candidate inputs across seeds differ only by QSF SEED. Quartus is 17.0.2 Build 602, device 5CSEBA6U23I7. The full-state frozen source and validated candidate worktrees differ in exactly the five reviewed RTL files after normalizing line endings. Those five candidate files also match the corresponding 72-phase verification trees. Generated build_id and dependency inputs come from the frozen manifest.

Infrastructure fixes:

- Preparation validates all evidence before writing, refuses to overwrite existing inputs or query scripts, checks existing manifests, and preserves manifests on resume.
- Runner uses an exclusive process-lifetime lock, verifies stage artifact hashes before skipping, checks successful tool completion and all required reports, and snapshots the entire variant directory before retrying an interrupted stage. Existing failure markers stop execution. Successful stage markers cannot be overwritten.
- Query completion requires settings, source declarations, and all requested timing reports; a partially written physical_setup.rpt no longer skips queries.
- Collector checks source hashes, actual fitter seed, tool/device, RAM table, setup/hold presence, warning counts, detailed critical paths, report and RBF hashes. It distinguishes pending/interrupted builds, tool/infrastructure failures, and completed builds with timing violations. It preserves per-group TimeQuest data, worst-group TNS and sum of group TNS. Three-seed averages require three completed results for each candidate. Qualification covers constrained paths; original unconstrained/ignored-SDC reports remain available.
- All stages execute sequentially from the short W: project path at inherited Idle priority. No Quartus settings were changed to obtain low priority.

Validation:

- Preparation run twice successfully with unchanged manifests and sources.
- JS syntax and PowerShell parser checks passed.
- Collector regression reproduces resource, timing, warning counts and setup paths from all three full-state reference seeds, including seed 1's timing failure.
- Artifact regression verifies seal/resume, refuses duplicate markers, rejects incomplete stages, and detects report tampering. Fixture retained under infrastructure_fixture_*.

Execution:

The first runner executes seed 1 in B1/C1 order. continue_after_pair.ps1 waits for filesystem completion events and runner lock release. It stops on a paired-build failure, verifies all stage hashes, and requires two identical collector outputs before starting seeds 2 and 3 in B1/C1 order. It writes paired_seed1_verified.txt, then unattended.done or unattended.failed. Logs and all build products remain in this directory. No final candidate selection is automated.

Results are written after each build to study_results.json and study_results.md. JSON preserves all warning text, per-group timing and critical-path endpoints. Reference averages are available immediately; candidate averages remain null until all three seeds complete.
