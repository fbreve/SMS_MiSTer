# YM2413 Compact Savestate (B1 vs. C1) — Handoff Document

## 1. Baseline & Active Experimental Worktrees

- **Baseline Commit**: `9873761503510e4b2c7e06600bf5515344235c2f`
- **Validated B1 Reference Worktree**:
  - **Path**: `c:\Users\fbrev\Documents\Diversos\Dev\SMS_MiSTer\tests\ym2413_optimized_integration\worktree`
  - **Branch**: `experiment/ym2413-optimized-integration` (`HEAD = 9873761503510e4b2c7e06600bf5515344235c2f`)
  - **Format**: 100 words, 50 DDRAM transfers, private descriptor `v18` (`16'd18`).
  - **Optimizations**: `OutputMemory` MLAB with same-transfer stage-0 guard (`dout_latch[33] && dout_latch[1:0] != 2'b00` on word pair 39); omits `TemporalMixer.mix` and `TemporalMixer.mixout`; packs `SlotCounter` (`[6:0]`), `mute` (`[7]`), and `maddr` (`[12:8]`) into word 78 (`mask = 0x00001FFF`); moves `OutputGenerator` to word 79.
- **Validated C1 Candidate Worktree**:
  - **Path**: `c:\Users\fbrev\Documents\Diversos\Dev\SMS_MiSTer\tests\ym2413_c1_mixer_omission\worktree`
  - **Branch**: `experiment/ym2413-c1-mixer-omission` (`HEAD = 9873761503510e4b2c7e06600bf5515344235c2f`)
  - **Format**: 100 words, 50 DDRAM transfers, private descriptor `v20` (`16'd20`).
  - **Optimizations**: All B1 optimizations plus omission of `TemporalMixer.mute` and `TemporalMixer.maddr` from snapshot readback and restoration (`word 78` holds only `SlotCounter` `[6:0]`, `mask = 0x0000007F`).
- **Modified Production Files (Identical 5-file scope in both worktrees)**:
  - `rtl/VM2413/outputgenerator.vhd`
  - `rtl/VM2413/outputmemory.vhd`
  - `rtl/VM2413/temporalmixer.vhd`
  - `rtl/opll_snapshot.sv`
  - `rtl/savestates.sv`
- **Preservation Status**:
  - `master`, `sys/`, `tests/ym2413_optimized_integration/worktree`, `tests/ym2413_c1_mixer_omission/worktree`, and all 15 prior worktrees in `tests/ym2413_optimized_integration/preservation_before.json` are verified untouched.

---

## 2. Completed Functional Validation & Preliminary Synthesis Evidence

1. **B1 Full 72-Phase Campaign (`PASS 72/72`)**:
   - **Evidence JSON**: `tests/ym2413_optimized_integration/verification_b1/tests/ym2413_fullstate/b1_campaign_results.json`
   - **Logs**: `tests/ym2413_optimized_integration/verification_b1/tests/ym2413_fullstate/combined_runs/shift0..71.log`
2. **C1 Full 72-Phase Campaign (`PASS 72/72`)**:
   - **Evidence JSON**: `tests/ym2413_c1_mixer_omission/verification_c1/tests/ym2413_fullstate/c1_campaign_results.json`
   - **Aggregator Script**: `tests/ym2413_c1_mixer_omission/verification_c1/tests/ym2413_fullstate/collect_c1_campaign.js`
   - **Logs**:
     - `tests/ym2413_c1_mixer_omission/verification_c1/tests/ym2413_fullstate/combined_runs/shift0..71.log` (all 72 phases with `FRAME_EVENTS=6`: `576` `LOAD`s, `1,152` captures/recaptures, `2,016` oracle checkpoints, `449,110,935` host-clock comparisons, simultaneous 4-register poisoning `POISON ALL4`, exact convergence in `73..144 <= 144` enabled FM clocks).
     - `tests/ym2413_c1_mixer_omission/verification_c1/tests/ym2413_fullstate/targeted_runs/shift{0,1,2,3,11,12,13,55,56,57,68,69,70,71}.log` (initial 14 boundary-phase logs preserved).
     - `tests/ym2413_c1_mixer_omission/logs/modelsim_*.log` (all 13 ModelSim protocol, map, validator-stream, negative-control A/B rejection, non-FM, and live DDRAM `MODE=0..6` logs).
3. **Preliminary `quartus_map` Synthesis Comparison (Completed)**:
   - **Directory**: `tests/ym2413_c1_mixer_omission/synthesis_map_compare` (`b1/output_files/SMS.map.rpt` vs. `c1/output_files/SMS.map.rpt`)
   - **Result**: C1 reduces estimated needed ALMs by **`-60` ALMs** (`17,452.6` vs. `17,512.7`), combinational ALUTs by **`-61`** (`26,184` vs. `26,245`), and dedicated logic registers by **`-6`** (`20,693` vs. `20,699`) relative to B1.

---

## 3. Running Processes Check

- **Active Compilations**: None (`quartus_map`, `quartus_fit`, `quartus_asm`, `quartus_sh`, and `ghdl` are not running).
- **Pre-existing Background GUI/STA Processes** (started 2026-10-28/29, recorded in `tests/ym2413_v19_fullstate/physical_seed2/preexisting_sta.json`; left untouched):
  - `PID 87924` (`quartus.exe`)
  - `PID 105696` (`quartus_sta.exe`)

---

## 4. Pending Three-Seed Quartus Fitter Study (`B1` and `C1`)

Validated baseline (`master`) and full-state 104-word (`v17`) 3-seed Fitter results already exist in:
- `tests/ym2413_v19_fullstate/physical_seed1/results.json`
- `tests/ym2413_v19_fullstate/physical_seed2/results.json`
- `tests/ym2413_v19_fullstate/physical_seed3/results.json`

Therefore, only **6 candidate builds** (`Seeds 1, 2, 3` × `b1, c1`) are needed rather than 9.

### Prepared Resumable Study Scripts
Located in `c:\Users\fbrev\Documents\Diversos\Dev\SMS_MiSTer\tests\ym2413_b1_c1_seed_study`:
1. `prepare_study.js`: Creates `seed1..3/{b1,c1}` from the exact frozen inputs in `tests/ym2413_v19_fullstate/physical_seed1`, substituting only the 5 reviewed RTL files from B1/C1 worktrees and the QSF `SEED` assignment (`1, 2, 3`), and links the validated baseline `results.json` per seed.
2. `run_fitter_study.ps1`: Sequential, resumable PowerShell runner at Windows `Idle` priority:
   - Maps `W:` via `subst.exe` to each `seedN` directory.
   - Runs `map` -> `fit` -> `asm` -> `sta` plus read-only `settings.tcl` and `paths.tcl` queries sequentially.
   - Writes per-stage `*.done` markers and per-variant `build.done` markers so interrupted runs resume without overwriting completed stages or reports.
   - Moves any interrupted stage log to `<stage>.incomplete_<timestamp>.log` and writes `build.failed` on error.
3. `collect_study.js`: Parses completed `seed1..3/{b1,c1}` reports alongside the reused baseline and `v17` results from `tests/ym2413_v19_fullstate/physical_seed1..3/results.json` into `study_results.json`.

### Commands to Run or Resume the Three-Seed Study

```powershell
Set-Location 'c:\Users\fbrev\Documents\Diversos\Dev\SMS_MiSTer\tests\ym2413_b1_c1_seed_study'

# 1. Run all 6 builds (or a subset via -Seeds @(1) -Variants @('b1','c1')); safe to re-run to resume:
.\run_fitter_study.ps1

# 2. Aggregate results (can also be run after any individual seed/variant completes):
node .\collect_study.js
```

