# RegisterMemory implementation control: one matched seed-2 experiment

Selected control: `set_global_assignment -name PHYSICAL_SYNTHESIS_EFFORT EXTRA` added to both isolated QSF copies. Original seed-2 Normal builds remain unchanged. All other source inputs, device, constraints, performance/packing settings, seed2 and BUILD_DATE261014 remain identical.

`assignment_help.tcl` queries the actual Quartus Prime Lite17.0.2 Build602 assignment registry with `get_assignment_name_info`. Its log verifies scope and legal values. `documentation.js` extracts and hashes installed2017 help pages; these are the version-specific authority. Later online documentation is only a cross-check.

Run `node prepare.js` into a new output directory. It refuses to overwrite build copies, checks/protects prior evidence and copies the203 qualified seed-2 source files without databases. Run `powershell -NoProfile -ExecutionPolicy Bypass -File build.ps1` for sequential fresh map/fit/asm/sta A and B builds. Z: is temporarily mapped inside the runner process for short Quartus paths. Do not run competing Z:-based jobs concurrently.

Run `node prepare_analysis.js`, then `node measure.js` only after all stages complete. Additional validation must verify effective Extra effort, unchanged seed/settings/source hashes, retiming report entries, actual critical paths and preserved originals. Compare both the new matched A/B pair and each new build against its corresponding retained Normal build. Reused RTL/FM/mapped-bank/savestate simulation results qualify unchanged logical RTL; they do not claim new post-fit simulation or hardware qualification.

Stop after this single experiment, regardless of its outcome. No original QSF/SDC/RTL, experimental branch, retained database, merge, commit, push or PR is part of this workflow. Generated build trees/databases are ignored.
