# PhaseMemory paired seed-2 validation

Run preparation once from repository root:

```powershell
node tests/phase_memory_auto_seed2/prepare.js
node tests/phase_memory_auto_seed2/prepare_analysis.js
powershell -NoProfile -ExecutionPolicy Bypass -File tests/phase_memory_auto_seed2/build.ps1
node tests/phase_memory_auto_seed2/measure.js
node tests/phase_memory_auto_seed2/report.js
```

Preparation refuses to overwrite existing builds. It verifies every source against the qualified seed-1 manifest, copies only the203 tracked input blobs plus fixed build_id.v/jtag.cdf, and changes only SMS.qsf's SEED1→2 in both copies. A/B still differ only in the PhaseMemory logic attribute. The root project settings and RTL are untouched. Baseline commit8443a0d, device5CSEBA6U23I7, SMS/sys_top, Quartus17.0.2 Build602 Lite, fixed BUILD_DATE261014, original performance/packing/constraint settings.

Both builds start without compilation databases. The build script executes map/fit/asm/sta in order for A then B, under the same temporary Z:/baseline and Z:/candidate paths as seed1. It bypasses only the date-generating preflow. An exited Quartus crash-process handle left by the documented seed-1 optional keeper query is excluded from the active-compiler guard. Live compilers still prevent starting. Existing drive mappings are never replaced.

The seed-1 functional, mapped-memory, native FM and savestate qualification is reused explicitly: only placement seed changes here. No additional simulation claim is made. Logical mapping/resource signatures are cross-checked across seeds. Existing seed-1 reports and top-level artifacts are hashed before/after and are not regenerated. Generated databases and build trees are ignored and must remain unstaged.

The comparison uses candidate minus its own same-seed baseline. It does not compare a seed-2 candidate with a seed-1 baseline or select the best run from different seeds. Full setup/hold slack and TNS by clock, fitted allocation, memory mapping, routing, warnings and source identity are retained in results.json. Separate read-only TimeQuest paths are unnecessary to repeat the seed-1 keeper query failure; the full compiled STA reports remain authoritative.
