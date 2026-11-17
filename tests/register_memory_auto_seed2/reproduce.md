# RegisterMemory AUTO seed-2 reproduction

The seed-1 runner `../register_memory_auto/prepare_seed2.js` creates this source-only pair only after verifying all seven functional passes, negative whole-design needed/placed ALM deltas and passing candidate timing. Run it only into a nonexistent output directory; do not overwrite these builds or logs.

All 203 inputs are verified against the qualified seed-1 manifest before copying. SMS.qsf SEED1→2 changes in both variants; only RegisterMemory's logic attribute differs within this pair. PhaseMemory remains original. Fixed build date, device, original constraints/settings and tool binaries are unchanged. No database is copied.

Run `powershell -NoProfile -ExecutionPolicy Bypass -File build.ps1`; it runs fresh map/fit/asm/sta sequentially for baseline and candidate using a temporary process-local Z: mapping and Quartus 17.0.2. Then run `node measure.js`, `node verify_pair.js`, and `node ../register_memory_auto/finalize.js .`.

The seven seed-1 functional tests are reused explicitly, not rerun or reported as seed-2 simulation. Final validation verifies effective seed, fixed date, original PhaseMemory and protected reports/branches. Compare mapped RegisterMemory parameters and both memory layouts with seed 1 before accepting that qualification. All generated databases/build copies are ignored. No merge, push, PR or hardware installation is part of this experiment.
