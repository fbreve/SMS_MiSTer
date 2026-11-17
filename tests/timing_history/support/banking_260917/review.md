Mapper banking extraction review
===============================

Branch: `refactor/mapper-banking`, created from the clean
`refactor/mapper-detection` branch at
`def1d014ffc07048d87403cb0f0c841bf0d9f262`.
After PR #1 merged as #209, local `master` was fast-forwarded to
`47a48e0382aed4923eef34616175bacc0c8dad52` (`upstream/master`), and the
uncommitted banking branch was moved onto that commit. The original and merged
PR #1 commits have identical Git trees, so the compiled baseline and refactored
RTL remain applicable. The test baseline now references the merged commit.
No commit, push, or PR was made; all banking edits remain uncommitted.

Scope and ownership
-------------------

The complete existing `-- external ram control` process moved verbatim from
`rtl/system.vhd` into `rtl/mapper_ctrl.vhd`, with all 28 owned signals and their
original initial values. It retains the same asynchronous reset, clock,
assignment order, enables, and restore/write priorities. No pipeline stage or
new synchronization register was added. Internal signals and concurrent output
assignments avoid reading VHDL `out` ports.

Moved state:

* `bank0` through `bank3`.
* `jang_bank1` through `jang_bank4`, and `jang_rev1` through `jang_rev4`.
* `nvram_e`, `nvram_ex`, `nvram_p`, and `nvram_cme`.
* `lock_mapper_B`, `mapper_codies`, and `mapper_codies_lock`.
* `mapper_4pak`, `pak4_reg0`, and `pak4_reg2`.
* `nem_bank0`.
* `mapper_wonderkid_prev`, `reset_n_prev`, and `bootloader_n_prev`.
* `eeprom_soft_reset` and the Korean anti-LDIR `last_read_addr`.

The entire process moves coherently, including write-triggered 4-PAK state,
Codemasters locks, bank defaults, BIOS handoff, Wonder Kid startup, special
Evolution/Janggun/System E restore branches, and the EEPROM banking branch.
The existing EEPROM branch still precedes 4-PAK/Zemina/inhibited mapper handling;
the existing Janggun branch still precedes EEPROM. The Wonder Kid `$8000` clause
and its surrounding conditions are unchanged.

Intentionally remaining in `system.vhd`:

* Detector instantiation, mapper selection/precedence expressions, MSX runtime
  detection, BIOS/cartridge arbitration, and Evolution implementation.
* The final `mapper_out` packing, including every Evolution, Janggun, and
  System E conditional layout. No bit assignments or spare bits changed.
* General memory/NVRAM/EEPROM address decoding, ROM address generation,
  Janggun ROM-data reversal, EEPROM enable/protocol implementation, and `D_out`.
* Controller, VDP, System E, SC-3000, and all other unrelated logic.

`mapper_detect.vhd` is byte-for-byte unchanged. Final packing depends on detector
and nonbanking state, and address generation depends on system-level selection,
so moving those would exceed this coherent process extraction. No dependency
prevented moving state owned by the original banking process. The EEPROM
protocol did not need to move or gain a new abstraction: its original reset
pulse is simply an output from the extracted process.

Interface
---------

There are 32 inputs and 23 outputs, explicitly associated once in `system.vhd`.
The authoritative declaration is `rtl/mapper_ctrl.vhd:6`.

| Inputs | Type / purpose |
|---|---|
| `RESET_n`, `clk_sys`, `ce_z80`, `WR_n`, `MREQ_n`, `ss_freeze` | Existing clock, reset, CPU timing, and freeze controls |
| `A`, `D_in` | CPU address (16 bits), write data (8 bits) |
| `mapper_set`, `mapper_in` | Restore strobe and unchanged 64-bit mapper state |
| `evolution_game_launch`, `mapper_evolution`, `evolution_ss_in` | Existing launch flag, selection, and 96-bit restore word; only its original signature slice is examined |
| `systeme`, `sc3000_en`, `bootloader_n`, `mapper_lock` | Existing system/banking controls |
| `mapper_janggun`, `mapper_wonderkid`, `detect_codies_static`, `mapper_codies_force`, `mapper_eeprom`, `mapper_zemina_force`, `mapper_nemesis_auto`, `mapper_castle`, `mapper_linear`, `mapper_dahjee_a`, `mapper_sega_locked`, `use_zem`, `mapper_manual_force`, `sega_mapper_write_seen` | Explicit existing selection/detector inputs |
| `rom_size_pages` | Existing 8-bit ROM page count |

| Outputs (all have `_out` suffix) | Width |
|---|---|
| `bank0`, `bank1`, `bank2`, `bank3`, `pak4_reg2`, `nem_bank0` | 8 bits each |
| `jang_bank1`, `jang_bank2`, `jang_bank3`, `jang_bank4` | 6 bits each |
| `jang_rev1`, `jang_rev2`, `jang_rev3`, `jang_rev4` | 1 bit each |
| `nvram_e`, `nvram_ex`, `nvram_p`, `nvram_cme` | 1 bit each |
| `lock_mapper_B`, `mapper_codies`, `mapper_codies_lock`, `mapper_4pak`, `eeprom_soft_reset` | 1 bit each |

The five remaining owned registers are private. Existing parent signals become
wires driven by the entity. Initial values reside in the entity, including the
original Janggun declaration/reset-value distinction and the originally
uninitialized/unreset last-read address.

Changed files
-------------

* `rtl/mapper_ctrl.vhd`: new entity, state, and original banking process.
* `rtl/system.vhd`: instance, removal of private state declarations, removal of
  initializers on entity-driven wires, and replacement of the original process.
* `files.qip`, `mist/sms_mist.qsf`: exactly one source-list insertion each,
  immediately after `mapper_detect.vhd` and before `system.vhd`.
* `tests/mapper_banking/run.py`, `tests/mapper_banking/README.md`: structural
  audit, directed/differential simulation, and reproducibility instructions.

Structural and simulation validation
------------------------------------

PASS: complete moved process matches the baseline text; all initial values
match; all 28 state signals have one process owner; all 55 ports map exactly
once; parent banking assignments are absent; detector file and all unrelated
parent logic, including final save-state packing, match the baseline. Source
list changes are checked exactly. Quartus synthesis reports no new warnings.

PASS: ModelSim Intel FPGA Starter 10.5b, VHDL-93. Directed assertions cover
Sega, Codemasters (forced/static), Wonder Kid, Zemina, Nemesis, 4-PAK, Janggun,
Castle, Dahjee A, linear, Sega-locked, reset/defaults, standard and conditional
restore, freeze, BIOS handoff, EEPROM priority/exclusion/reset pulse, System E
restore/inhibition, SC-3000 inhibition, Evolution launch priority, and Korean
anti-LDIR behavior. All 23 exported signals also match an independently
generated baseline-process wrapper on every directed clock and 20,000
deterministic randomized clocks. Simulation completed at 202.290 us; the
250 us run returned zero errors and warnings.

ModelSim requires `when others` on three existing binary-only case statements
that Quartus accepts. The harness adds identical `when others => null` branches
to the two generated simulation copies only. Repository RTL remains verbatim;
simulation does not claim to validate nonbinary CPU addresses. This is a
banking-process regression, not a full-system simulation or hardware test.
See `simulation.log` and `tests/mapper_banking/README.md`.

Quartus methodology
-------------------

Both isolated snapshots use Quartus Prime Lite 17.0.2 Build 602, project `SMS`,
device `5CSEBA6U23I7`, existing seed 1, identical source/suppression settings,
and fresh databases. Command: `quartus_sh --flow compile SMS`.

Snapshots:
`C:\Users\fbrev\AppData\Local\Temp\sms_mapper_banking_def1d01\baseline`
and the sibling `refactored` directory. Initial sandboxed attempts could not
open the projects because Quartus misresolved their paths. The actual builds
run outside the sandbox and use the unmodified repository RTL.

Snapshot hashes confirm only the intended three existing source files differ,
plus the new entity. Compiled RTL matches the reviewed RTL except for one
trailing space removed from a changed parent declaration after compilation
started. `snapshot-source-hashes.json` records the source hashes. Detector
SHA-256 in both snapshots is
`b89fd91c25ac9f79a73230aaf0835f0f6ba05c5120b26a49fd6ca92b08118954`.

MiSTer baseline/refactored full builds are the comparison target. The legacy
MiST source list was updated and structurally checked; no legacy MiST full
build is claimed.

Quartus results
---------------

Both full compilations succeeded: **0 errors, 71 visible warnings each**.

| Resource | Baseline | Refactored |
|---|---:|---:|
| Synthesis registers | 34372 | 34372 |
| Fitted ALMs | 25,752 / 41,910 ( 61 % ) | 25,825 / 41,910 ( 62 % ) |
| Fitted registers | 35420 | 35390 |
| Memory bits | 3,809,858 / 5,662,720 ( 67 % ) | 3,809,858 / 5,662,720 ( 67 % ) |
| RAM blocks | 487 / 553 ( 88 % ) | 487 / 553 ( 88 % ) |
| DSP blocks | 39 / 112 ( 35 % ) | 39 / 112 ( 35 % ) |
| PLLs | 3 / 6 ( 50 % ) | 3 / 6 ( 50 % ) |

Fitting changes: **+73 ALMs, -30 registers**. Synthesis register, memory,
DSP, and PLL counts are unchanged. These are hierarchy-related fitter
differences; no timing improvement is claimed.

| Minimum reported slack (ns) | Baseline | Refactored |
|---|---:|---:|
| Setup | 0.509 | 0.378 |
| Hold | 0.244 | 0.242 |
| Recovery | 4.146 | 4.004 |
| Removal | 1.075 | 0.947 |
| Minimum Pulse Width | 1.122 | 1.122 |

Every reported TNS is 0.000 ns. Worst setup slack is on the HDMI PLL clock
in both builds. The main core PLL setup slack changes from 1.045 to 0.442 ns.
The pre-existing timing constraints were not changed. These results describe
constrained, reported paths and do not establish behavior on hardware.

| Setup clock | Baseline slack (ns) | Refactored slack (ns) |
|---|---:|---:|
| `pll_hdmi / pll_hdmi_inst / altera_pll_i / cyclonev_pll / counter[0].output_counter / divclk` | 0.509 | 0.378 |
| `emu / pll / pll_inst / altera_pll_i / cyclonev_pll / counter[0].output_counter / divclk` | 1.045 | 0.442 |
| `sysmem / fpga_interfaces / clocks_resets / h2f_user0_clk` | 4.072 | 4.105 |
| `FPGA_CLK2_50` | 4.759 | 4.795 |
| `spi_sck` | 5.381 | 5.506 |
| `FPGA_CLK1_50` | 7.789 | 8.257 |
| `pll_audio / pll_audio_inst / altera_pll_i / general[0].gpll~PLL_OUTPUT_COUNTER / divclk` | 14.202 | 14.132 |

Warning comparison
------------------

| Stage | Visible baseline / refactored | Suppressed baseline / refactored |
|---|---:|---:|
| map | 66 / 66 | 45 / 45 |
| fit | 5 / 5 | 1 / 1 |
| asm | 0 / 0 | 0 / 0 |
| sta | 0 / 0 | 0 / 0 |

Counts include critical warnings. All warning messages match as multisets
after normalizing snapshot paths, moved source-line numbers, and the new
banking hierarchy. No added/removed warning content remains, including the
existing Janggun power-up warnings. Suppression files were not changed.
See `warnings.json` for warning-code counts and empty difference sets.

RBF and diff
------------

Generated RBF: `output_files/mapper_banking_review/SMS_mapper_banking.rbf`.

Size: 4,068,264 bytes. SHA-256:
`bc7b4f01ab9dc48190dffb0f683041143045b0ad619842a87b5911c3653e11b3`.

Original build output: `C:\Users\fbrev\AppData\Local\Temp\sms_mapper_banking_def1d01\refactored\output_files\SMS.rbf`.

Literal `git diff --stat` (tracked files):

```text
 files.qip         |   1 +
 mist/sms_mist.qsf |   1 +
 rtl/system.vhd    | 441 ++++++++++--------------------------------------------
 3 files changed, 79 insertions(+), 364 deletions(-)
```

Complete diff statistics, including untracked new files:

```text
 files.qip                      |    1 
 mist/sms_mist.qsf              |    1 
 rtl/system.vhd                 |  441 +++++++-------------------------------
 rtl/mapper_ctrl.vhd            |  460 ++++++++++++++++++++++++++++++++++++++++
 tests/mapper_banking/run.py    |  251 ++++++++++++++++++++++
 tests/mapper_banking/README.md |   42 ++++
 6 files changed, 832 insertions(+), 364 deletions(-)
```

The complete patch is `complete.diff`; it was verified with
`git apply --check --reverse`. `git diff --check` passes. The moved process
retains existing whitespace to preserve its original text. All edits remain
uncommitted, awaiting review. **Hardware regression has not been performed.**


Review artifacts
----------------

`complete.diff` includes all six changed/new files without staging them.
`git-diff-stat.txt` is the literal `git diff --stat` output, which excludes
untracked files. `complete-diff-stat.txt` includes the new entity and tests.
`warnings.json` compares visible and suppressed messages after normalizing
snapshot paths, moved line numbers, and the new banking hierarchy.
`baseline/` and `refactored/` contain original build reports and logs.

Hardware regression remains pending code review. No hardware test was run.
