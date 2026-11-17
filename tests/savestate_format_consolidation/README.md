# Format consolidation experiment

The authoritative inputs are the retained fixture/source files and their hashes in `baseline.json`, `functional_gate.json` and the build manifests. All production inputs remain untouched. The candidate changes only `rtl/savestates.sv` in an isolated source copy; `candidate.patch` shows the complete experiment.

The final decision belongs in `review.md` after completed resource/timing measurement. `format_history.md`, `history.json`, `network_evidence.json`, `compatibility_inventory.json` and `dependency_map.md` provide the history and static audit independently of the fit.

## Functional reproduction

Use ModelSim Intel FPGA Starter Edition at the path recorded in the PowerShell drivers. Invoke scripts with a process-local execution-policy override if required by the workstation; no global policy change is needed.

1. Run `node check_decode.js` from this directory for the source-derived public/current predicate enumeration.
2. Run `references.ps1 -Family <family>` for each of `reg_g05`, `reg_sprites`, `reg_g10`, `reg_dual`, `reg_g04`. This compiles the unchanged golden controller in `golden_work` and temporarily maps each case's logical `vdp_work` alias to it. The VDP setup import is the retained public96 path, replacing the original v13-only setup dependency. Reference outputs are generated independently before candidate replay.
3. Run `regress.ps1` for the 28 component cases, or use its `-Set core`, `-Set vdp`, `-Family`, `-Case`, `-Worker` and `-Workers` selectors. Candidate compilation and mapping use the separate candidate library. `run_vdp.ps1`/`run_vdp_cases.ps1` can wait for completed reference cases during a pipelined run.
4. Run `run_f01.ps1` for the two real OPLL/PSG replays with the retained external references.
5. From `format`, `imports`, `miter`, `peripherals` and `evolution`, invoke `vsim -c -do "do run.do" -l simulation.log`. From this directory invoke `vsim -c -do "do psg.do" -l psg.log`.
6. Run `node validate_gate.js` from the repository root using its full relative path. It checks the final completion/error markers, original golden source, candidate source, fixture hashes and all tracked production files, then freezes the proof manifest. A changed result requires deliberate new proof capture; a completed gate is not silently rewritten.

The fixture preparation scripts document derivation from the retained F01 test families. Existing simulation-only portability changes, `TB_FAST` and flush shortening are preserved. Production synthesis uses the complete controller with full counters and the original build settings. G08.FM publication is outside this experiment: F01 tests require exact raw FM restoration, and the G08.release fixtures retain their established isolation contract.

## Controlled build reproduction

`prepare_build.js experiment` requires a passed functional gate, original HEAD, all original tracked hashes and the exact proved candidate hash. It creates a fresh source-only build folder from the retained F01 production inputs, preserving all QSF/SDC/QIP/IP settings, seed1 and BUILD_DATE261025. It refuses to reuse an existing build database.

`build.ps1 -Name experiment` runs explicit map, fit, asm and STA stages. Its process verifies its own Z: mapping to this repository; a mapping in another process is not assumed. `collect_build.js experiment` checks all built input hashes and stage completion and measures the actual reports against the F01 production build. `analyze_paths.ps1 -Name experiment` extracts the detailed setup/hold paths.

Any confirmation is conditional on the measured result; the presence of a preparation option is not authorization for a seed sweep. No production consolidation follows unless the decision is C and its additional phases are completed.

`provenance.json` distinguishes initial gate-file creation, the subsequent identical-proof verification timestamp and build preparation. Every final functional result predates primary build preparation, and the proved candidate hash equals the built source hash.

No commit, push or PR is part of this workflow. Generated build databases, programming files and simulation libraries remain local artifacts.
