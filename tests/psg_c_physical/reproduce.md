# Matched master / PSG Candidate C physical comparison

Baseline: `8443a0d19a88aff7a5900011bccf386daf146945`. Candidate: the reviewed uncommitted `experiment/psg-c-controls` changes. `candidate_C.diff` freezes that exact patch. The candidate worktree and all previous reports remain read-only throughout this comparison.

`prepare.js` records read-only functional/source revalidation, preservation hashes and metadata, then materializes four independent trees from exact baseline Git blobs and the pinned `mist/mist-modules` dependency. Only nine reviewed C files replace baseline files. It does not copy an existing database, output directory or build log. It refuses to overwrite an existing prepared comparison.

The four trees are `seed1/A`, `seed1/C`, `seed2/A`, `seed2/C`. Paired inputs differ only in the nine reviewed RTL files. Between seeds, only the QSF SEED assignment changes. Common generated `build_id.v` is fixed to BUILD_DATE 261029, and common `jtag.cdf` follows the existing project generator. Explicit map/fit/asm/sta execution bypasses date-changing preflow without editing the QSF or preflow script.

Tool: Quartus Prime 17.0.2 Build 602 Lite. Project/revision SMS; top sys_top; Cyclone V 5CSEBA6U23I7; MISTER_FB=1. Original optimization, physical-synthesis, packing, timing, QIP/IP and SDC settings are retained. Executable and input hashes are in input_manifest.json; configuration_equality.json lists matched configuration files.

Fresh compilation command, from the repository root:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tests/psg_c_physical/build.ps1
```

The execution-policy option applies only to this child process; no persistent policy is changed. The script uses a temporary free Z: alias to the new comparison directory, checks frozen inputs before each build, and compiles sequentially. All compiler output is retained per build. Map/fit/asm use read_settings_files=on and write_settings_files=off. STA uses the same project and unchanged constraints. It refuses existing databases/output/logs. A failed stage prevents dependent stages for that build; remaining independent builds continue without source or settings changes. No automatic retry or tuning occurs.

The pre-existing idle TimeQuest PID is recorded and never interrupted. External map/fit/asm/sh processes prevent starting this runner. An initial shell-policy rejection happened before any compiler stage; the command above was then used.

After all four runs, additional read-only full-path reports can be obtained with:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tests/psg_c_physical/query_paths.ps1
node tests/psg_c_physical/measure.js
node tests/psg_c_physical/report_data.js
node tests/psg_c_physical/verify_preservation.js
```

The path query creates a slow-model timing netlist from each completed database; it does not run fitting or change RTL. Default STA summary values remain the acceptance metrics. The extraction preserves raw warnings plus comparisons normalized for build-directory and source-line differences. RAM comparisons distinguish placement coordinates from structural inference. Physical-synthesis table entry counts are not unique register counts or causal proof.

Read review.md and results.json for final measurements and limitations. Reproduction must use a new artifact directory; do not rerun these commands over retained completed outputs. No commit, push, merge or PR is part of this task.
