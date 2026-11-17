# Continuation: confirmed historical v19 and minimal restart probes

This directory is isolated from production, historical worktrees, RBFs and the earlier audit. The final report is `CONTINUATION_REPORT.md`; machine-readable results are in `matrix_results.json`, `vdp_matrix_results.json`, `format_results.json`, `local_rom_identity.json` and `ys_results.json`.

Source generation reads master `66f16d5c` and historical `1b2a52d8` through `git show`; it never checks out or edits either branch. All generated CPU/VDP files are test copies. None is listed in production files.qip.

Reproduction with Node and the installed ModelSim 10.5b:

1. `node prepare.js`, then `vsim -c -do compile.do -l compile.log`.
2. `node run_matrix.js` for the CPU-only matrix. VARIANT 0 disables the added context restore and retains master behavior; 1 enables only the master-based context mechanism; 2 uses the historical CPU/NMI wrapper; 3 disables only predecessor restoration in that same historical wrapper. Historical reference runs normally, with no LOAD intervention.
3. `node prepare_vdp.js`, then `vsim -c -do compile_vdp.do -l compile_vdp.log`, then `node run_vdp_matrix.js` for production-VDP CPU-port checks.
4. `node format_audit.js` for the proposed word5 codec and static production-reader checks. This does not implement a DDR format change.
5. Local diagnostics only: `node local_roms.js`, `node prepare_ys.js`, then `vsim -c -do compile_ys.do -l compile_ys.log`. Point `YS_ROM` to the original external ROM and `YS_MODE` to 0 or 1, then run `vsim -c -do probe_ys.do -l <new-log-name>`. No ROM is included, copied, converted, dumped or packaged. The paths in local_roms.js are specific to this machine.

The CPU probes use a test side record, not the production savestate DDR writer/reader. Architecture is captured pre-accepted T; the reference is retained post-T; the restored CPU performs historical T1/T2 while reference guest time is held, and comparisons begin at canonical k=0. VDP access tests keep the renderer stopped, comparing actual port-A writes. Ys probes run the production VDP renderer/video and direct Sega memory models but do not instantiate the complete MiSTer core/controller/SDRAM path. See the final report for limits.

Simulation adapters: explicit `entity work` bindings, a 9-bit spelling of the existing `ioq and x"7"` mask required by ModelSim, observation-only ports, and `UNUSED` instead of a blank RAM initialization filename for the vendor simulation model. The last two do not add saved production state. The matrix's PERIOD=15 setting produces one CPU tick every 16 host clocks because of task setup; the Ys driver explicitly adjusts that task to 15 host clocks. Relative CPU/VDP phase and the full master release FSM are not certified by these probes.

Early failed development logs are not evidence. In particular `first_probe.log`, `m3_retry.log` and the first standard-ROM probe without a complete SRAM model are superseded by the final JSON-listed runs. The initial top-level parameter MODE was renamed VARIANT to avoid ModelSim overriding the VHDL CPU Mode generic. Final matrix runs use Z80 mode and the JSON-listed logs only. ModelSim's design-capacity advisory remains for full-VDP probes; it reports no functional errors in completed final runs.
