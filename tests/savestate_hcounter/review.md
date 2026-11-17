# F07: VDP HCounter savestate fix

Branch: `fix/savestate-hcounter`. Baseline: `8443a0d19a88aff7a5900011bccf386daf146945`. Scope is exclusively F07/S016. No other audit finding was fixed. No commit, push or PR was made.

## Cause and reproduction

`latched_x` is an 8-bit persistent latch. A rising HL captures `x(8 downto 1)` and guest HCounter port 41 reads that latch. The original 128-bit VDP snapshot contained no representation or restore assignment for it. Restoring those128 bits left the later latch value intact.

Before any RTL edit, a focused test compiled **unmodified production VDP, background, sprites, shifters, CRAM and DPRAM** with the shipped Altera RAM model. It used actual HL edges, copied ss_regs_out to ss_regs_in, pulsed ss_regs_set with CPU/video enables stopped, and read port 41 via RD/ce_vdp. No internal latch force was used. Save A = 0, perturb B = 48, restore with no new HL, read returned 48. `before_expected_failure.log` records the assertion `actual=48 expected=0`. `before.log` confirms stale B at eight x values: 0,1,254,255,256,485,486,511. The tests are reproducible against the preserved baseline input tree, not a manually reconstructed latch model.

The RAM model's default init_file=" " crashes this old simulator, so simulation overrides **only the DPRAM initialization generic** to UNUSED. Memory contents and the VDP latch/read logic are not forced or replaced. Two real VDPs (DUT and uninterrupted reference) exceed ModelSim Starter's recommended statement count; the simulator prints a capacity/performance warning but completes. Existing startup numeric_std/std_logic_arith warnings for uninitialized unrelated pipeline values are disabled; explicit HCounter assertions remain enabled.

## Representation and compatibility

The current 128-bit VDP vector is fully occupied, including the legacy reset_flags bit. Reusing bit 103 cannot store an eight-bit value and would silently alter its historical layout. The audio PSGX marker describes audio only and is not a general VDP-version marker.

The internal VDP vector is extended to **136 bits**, with `latched_x` at **135:128**. Every original low128 packing expression and restore field remains unchanged. The shared VDP entity provides this state for both instances; the system and top-level signal widths carry it to the controller. The existing ss_regs_set restores the latch, with priority over a simultaneous HL rise. Normal execution still captures the same x slice on the same HL edge.

No extra DDRAM word, slot size, FSM stage or header size is added. Existing **word 01a** already stores the 22-bit video state and was **fully written with 42 zero upper bits** by the previous 96KiB format. It now contains a self-identifying HCounter extension:

| Bits | Meaning |
|---|---|
| 63:40 | `24'h484301`: "HC", extension version1 |
| 39:38 | reserved00, checked on load |
| 37:30 | VDP2 HCounter, zero for non-System E saves |
| 29:22 | VDP1 HCounter |
| 21:0 | existing video state, unchanged |

Both registered write helper and combinational DDRAM command preview use the same video_word expression. On load, only the complete supported tag plus valid reserved bits allow the two latch bytes to enter the snapshots. There is no reinterpretation of arbitrary untagged payload bytes. A previously generated96KiB snapshot has no tag and restores **zero** for each HCounter, rather than pretending to recover a historical value it never stored. Unknown versions/invalid reserved bits likewise use zero while accepting the existing snapshot format. This is a deliberate deterministic legacy fallback, changed from retaining the post-save latch. New snapshots preserve the exact value.

The oldest 64KiB SMS compatibility path skips word 01a completely. Both extension bytes are initialized to zero at the start of each load, so a preceding modern load or arbitrary/stale data in its unused region cannot leak into it. Old readers can still read the new state because their existing loader ignores the upper 42 video-word bits. This backward-read statement follows the old loader dataflow; a separate old-core simulation was not run. The game/BIOS signature and existing audio validation are unchanged.

## Verification

* **Real VDP test:** post-fix SMS and GG runs pass all eight boundaries, eight repeated save/perturb/load sequences, guest-visible comparison with an uninterrupted real VDP reference, a subsequent HL update, deterministic legacy-zero input, and restore priority over a coincident HL rise. The reference receives the original real latch edge but no perturbation or load. This is a focused HCounter replay, not an assertion that all other VDP pipeline state is equivalent.
* **Production controller round trip:** real savestates FSM, mock DDRAM accepting actual command requests and returning delayed data. Full transfers, drain, restore, 900000-clock flush and release run normally. Only the UI cooldown counter is forced to zero between operations. Modern SMS and System E save/load preserve distinct H1=5a/H2=a5. Previous96KiB format, untagged random padding, unknown version, invalid reserved bits and oldest 64KiB SMS load are accepted and yield zero. The original 128-bit VDP1/VDP2 fields are checked exactly at restore. This separately verifies both controller state paths; it does not instantiate the complete System E CPU/dual-VDP system.
* **End-to-end dual-VDP state integration:** integration_tb connects two actual production VDP entities to the production controller snapshot/restore ports, with delayed mock DDRAM. Real HL captures 5a/a5, actual saved payload, perturbation to 0c/18, load, then normal guest reads with no new HL return 5a/a5. Repeating with the previous 96KiB video-word layout returns 00/00. Later real HL edges return ff/80. Both cases pass. This joins the capture/storage/restore/read paths, including distinct VDP instances and physical se_bank values. CPU/video inputs and DMA memory data are fixtures, not a full System E game or complete VRAM-content integration regression. The900000-clock flush is not shortened; this mixed-language/Altera-model test took about six minutes under Starter's capacity warning.
* **Static consistency:**37 direct VDP field assignments are symmetric. Every original 128-bit packing expression is unchanged. The existing audit static checks run against current RTL in static_current without overwriting the original audit's hashes/report.
* **Existing regressions:** three original audit defect reproductions still pass their expected-divergence checks (GG PDR, EEPROM command, MD6); these are intentionally unresolved findings. PSG replay passes 128 cases covering all eight noise controls and 16 divider phases, 2,560,000 compared cycles. No tests were changed to conceal those gaps. Other prior VDP/DDR test directories contain historical CSV/build artifacts rather than runnable HDL test sources in this checkout; they were not reported as new runs.
* **Diff review:** only SMS.sv, rtl/system.vhd, rtl/vdp.vhd and rtl/savestates.sv change in production. No unrelated field, state machine, normal HCounter timing or formatting refactor. `git diff --check` passes. Isolated build trees and simulator libraries are ignored by the focused test directory; no artifacts or other files are staged.

ModelSim 10.5b rejects the controller's two **pre-existing** forward declarations for mapper_snap/evolution_snap. prepare_controller.js creates a simulation-only copy that moves only those declarations before their uses; expressions, processes, ports and timing are unchanged. Production declarations are not refactored. The VDP regression uses the production VDP source directly. Scripts inspect log failure markers, since this simulator's VHDL break/stop behavior can return shell status0 even after an assertion.

Legacy images are deterministic synthetic fixtures for the established layouts, not downloaded historical game-state files. The previous 96KiB case writes the exact previous zero-padded video word; the oldest 64KiB case selects its historical size/header and unextended PSG path while deliberately leaving a valid modern HCounter tag in the skipped area. It therefore checks that stale modern extension data cannot leak through that compatibility route. It is not an exhaustive legacy CPU/VDP compatibility certification.

## Reproduction commands

Run from tests/savestate_hcounter with Node and ModelSim17.0 installation available:

```powershell
& 'C:/Program Files/nodejs/node.exe' prepare.js --baseline
$env:HCOUNTER_FIXED='false'; $env:HCOUNTER_GG='0'
& C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe -c -do 'do vdp.do' -l before.log
$env:HCOUNTER_FIXED='true'
# Expected assertion on baseline:
& C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe -c -do 'do vdp.do' -l before_expected_failure.log
& 'C:/Program Files/nodejs/node.exe' prepare.js
& C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe -c -do 'do vdp.do' -l after.log
$env:HCOUNTER_GG='1'
& C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe -c -do 'do vdp.do' -l after_gg.log
& 'C:/Program Files/nodejs/node.exe' prepare_controller.js
& C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe -c -do 'do controller.do' -l controller.log
& 'C:/Program Files/nodejs/node.exe' prepare_integration.js
& C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe -c -do 'do integration.do' -l integration.log
& 'C:/Program Files/nodejs/node.exe' static_checks.js
& 'C:/Program Files/nodejs/node.exe' results.js
```

Baseline/candidate Quartus input trees contain exact copies of the project qpf/qsf/files.qip/build_id.v/SMS.sv, rtl and sys. Baseline was copied before edits; candidate after simulations passed. The unchanged seed 1 settings and Quartus 17.0.2 Build 602 are used for both. The old Tcl path normalizer removes Documents in this sandbox, so build.ps1 maps a temporary Z: workspace alias in its execution context. Failed path-setup attempts are not compilation results. Recreate the baseline tree from the recorded baseline revision plus the same sys checkout/build_id.v; it is intentionally ignored rather than proposed as duplicate production source to commit.

## Quartus and final recommendation

**READY TO COMMIT**, subject to the user's requested review before any commit. Both clean isolated builds completed synthesis, fitting, timing analysis and assembly successfully, with no RTL changes after the candidate inputs were copied. SHA256 checks confirm that all four compiled candidate production files exactly match the final working files. `results.json` includes production/test-input hashes, parsed timing results and normalized critical warning sets; fit/STA summaries are copied alongside it. The full compile logs remain in the ignored build directories.

| Metric | Baseline | F07 candidate | Delta |
|---|---:|---:|---:|
| Worst setup slack | 0.508 ns | 0.354 ns | -0.154 ns |
| Worst hold slack | 0.144 ns | 0.188 ns | +0.044 ns |
| Core clk_sys setup | 1.194 ns | 0.862 ns | -0.332 ns |
| Core clk_sys hold | 0.241 ns | 0.188 ns | -0.053 ns |
| Fitted ALMs | 26,465 | 26,532 | +67 (about 0.25%) |
| Fitted registers | 35,709 | 35,817 | +108 (about 0.30%) |
| Synthesis registers | 34,857 | 34,888 | +31 |
| Block memory bits | 3,809,858 | 3,809,858 | 0 |
| RAM blocks / DSP blocks | 487 / 39 | 487 / 39 | 0 / 0 |
| Normalized distinct critical warnings | 38 | 38 | no new messages |

All reported timing categories have nonnegative slack and zero TNS: **zero reported timing violations**. Existing critical warnings remain, including existing power-up/assignment warnings; this is not a claim of a warning-free project. The small ALM increase and 31-register synthesis delta are reasonable for the latch snapshot/restore extension and tag decoder. The final fitted register delta includes physical-optimization differences under the unchanged duplication/retiming settings; it should not be interpreted as 108 new logical state bits. No extra RAM/DSP or optimization work was introduced. Placement-dependent slack changed but remains positive, so no timing optimization was attempted.

Production files changed:

* `rtl/vdp.vhd`: high8 snapshot/restore and restore priority over HL.
* `rtl/system.vhd`: VDP1/VDP2 interface widths and the VDP2 intermediate signal.
* `SMS.sv`: two snapshot/restore wire pairs widened.
* `rtl/savestates.sv`: snapshot widths, video-word extension serialization/validation and deterministic legacy initialization.

New focused assets are this report; `.gitignore`; the preparation/static/result/build scripts; generated VDP, controller and integration testbenches and simulator do-files; before/failing-before/after/GG/controller/integration/regression logs; static log; results/hash JSON; copied fit/STA summaries; production diff and git-status/stat snapshots. `baseline/`, `candidate/`, `work/` and temporary source/check outputs are excluded. The original audit report/matrix/hashes were preserved. Shared regression logs are also copied into this directory as review evidence.

Final `git diff --stat` (tracked production changes; new tests are still untracked):

```text
 SMS.sv            |  4 ++--
 rtl/savestates.sv | 32 ++++++++++++++++++++++++--------
 rtl/system.vhd    | 10 +++++-----
 rtl/vdp.vhd       | 11 +++++++----
 4 files changed, 38 insertions(+), 19 deletions(-)
```

Final `git status --short`:

```text
 M SMS.sv
 M rtl/savestates.sv
 M rtl/system.vhd
 M rtl/vdp.vhd
?? tests/
```

The pre-existing tests tree was already untracked before this task. Nothing is staged, including no generated Quartus artifacts. The complete production diff was inspected and `git diff --check` passes. No commit, push or PR has been made. Next step: review and, when authorized, commit only the F07 production changes and appropriate focused test assets; the remaining audit findings are unchanged.
