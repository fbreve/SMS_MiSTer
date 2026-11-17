# Existing evidence search

Searched the workspace recursively with `rg --files` for Quartus reports, summaries, build scripts and manifests, and searched JSON/Markdown/PowerShell/log evidence for both exact commit IDs. Inspected the Git worktree list, upstream-v1 cleanup manifests, historical v19 inputs, public-v1 Quartus manifests, and timing-history evidence.

Relevant existing evidence:

- `tests/ym2413_upstream_v1_audit/clean_manifest.json` and `verification.json`: source-cleanup verification, not a new matched physical compilation of the exact post-cleanup commit.
- `tests/ym2413_public_v1_integration/quartus_seed1/inputs.json`: physical inputs refer to the experimental/public-v1 integration sources, predating the exact upstream cleanup commit. Not reused.
- `tests/ym2413_v19_fullstate/physical_seed*/inputs.json`: records the requested baseline ID but identifies an uncommitted v19 candidate. Not a matched comparison of the requested candidate; excluded.
- `tests/ym2413_b1_c1_seed_study/`: earlier experimental candidates, not the requested pair; excluded.
- `tests/ys_load_differential_audit/`: source identity and simulation/differential evidence, not the requested paired physical compilation.
- `tests/timing_history/`: no exact revision references found in JSON/Markdown/CSV search.

No existing output was accepted for reuse. Both revisions are exported from their exact Git commits and compiled afresh. No historical resource/timing number is used in the comparison.
