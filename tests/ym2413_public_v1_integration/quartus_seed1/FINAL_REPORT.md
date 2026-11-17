# Public v1 seed-1 RBF

The public-v1 RBF was generated and verified successfully. It is ready for physical MiSTer testing; it has not been deployed or hardware-tested by this build task. Only seed 1 was run.

## Comment audit and source verification

No comment correction was applied. The SRAM comment in `rtl/VM2413/registermemory.vhd:62` is correctly encoded CP932 and unchanged from C1/baseline. The user explicitly chose to retain it and keep the exact five-file scope. Other Japanese VHDL comments decode correctly with strict CP932/Shift-JIS decoding; none required repair. No source was decoded/re-encoded as Latin-1. Exact before/after hashes and the decision are in `../comment_audit_seed1/decision.json`; the original bytes are preserved there.

The integration branch remains `integration/ym2413-public-v1`, pinned to baseline `9873761503510e4b2c7e06600bf5515344235c2f`, with only the five approved changed production files. Relative to hardware-validated C1, four files are byte-identical; `savestates.sv` differs only in three comments and the executable descriptor version byte, 20 -> 1. The public descriptor is `64'h00640101464d5331`:

```systemverilog
localparam [63:0] FM_DESC = {16'd100,8'd1,8'd1,32'h464d5331};
```

The 100-word map, 50 DDRAM transfers, same-transfer OutputMemory collision guard, masks, omitted TemporalMixer snapshot state and non-FM legacy fallback remain identical to C1. Experimental FM descriptors 17/18/20 remain intentionally rejected.

The ten existing focused ModelSim invocations and their source/log hashes were reverified successfully. They cover v1 acceptance, experimental rejection, 100-word capture/apply, independent map checks, collision A/B and stage-zero acceptance, non-FM fallback, validator streams, live OPLL/oracle checks and LOAD atomicity probes. No source changed since those tests, so no redundant simulation or full 72-phase campaign was run. C1's 72/72 campaign remains preserved evidence for the unchanged OPLL/payload logic.

## Build identity and integrity

Quartus Prime 17.0.2 Build 602; Cyclone V 5CSEBA6U23I7; sys_top; SMS revision; seed 1. Map, Fitter, Assembler, TimeQuest and read-only settings/path queries all completed with exit 0. Stage artifacts and completion-marker hashes verify.

All 221 frozen input hashes verify. Every QSF/SDC is byte-identical to hardware-validated C1 seed 1, and expanded global/instance settings match after normalizing only the project directory name. The installed tool executable hashes match the original study. Of the frozen input files, only savestates.sv differs from C1 seed 1. No settings or RTL were tuned during or after compilation.

Builds ran sequentially at Idle priority in the fresh `quartus_seed1/v1` directory. All source inputs, logs, reports, databases, RBF and hash manifests are retained. No historical artifacts were overwritten.

## Quartus comparison

| Metric | C1 seed 1 (v20) | Public v1 seed 1 | Difference |
| --- | --- | --- | --- |
| Needed ALMs | 27,274 | 27,297 | +23 |
| Placed ALMs | 32,333 | 32,221 | -112 |
| Fitted registers | 35,789 | 35,724 | -65 |
| Mapped registers | 34,731 | 34,731 | 0 |
| MLAB cells | 20 | 20 | 0 |
| MLAB logical bits | 380 | 380 | 0 |
| M10K blocks | 489 | 489 | 0 |
| DSP blocks | 39 | 39 | 0 |
| Setup WNS (ns) | +0.566 | +0.582 | +0.016 |
| Hold WNS (ns) | +0.245 | +0.243 | -0.002 |
| Setup TNS (ns) | 0 | 0 | 0 |
| Hold TNS (ns) | 0 | 0 | 0 |

All reported constrained timing groups have positive slack and zero TNS. The 2 ps reduction in worst hold margin is disclosed; it remains positive at 243 ps. No additional run or tuning was attempted. Qualification does not extend to unconstrained I/O paths; those inherited reports are preserved. No SDC constraints were ignored.

Synthesis and fitted RAM evidence both confirm OutputMemory uses two MLAB RAM instances totaling 20 cells / 380 logical bits, with no M10Ks. RegisterMemory and FeedbackMemory remain implemented in logic: synthesis reports explicit `logic` ramstyle uninference, and neither appears as a RAM in the Fitter RAM Summary. No memory-inference regression occurred.

## Critical paths and warnings

- Worst setup: `ascal:ascal|o_h_poly_t.b0[10]` -> `ascal:ascal|o_h_poly_pix.b[3]`, HDMI PLL clock, +0.582 ns.
- Worst hold: `emu:emu|savestates:savestates_inst|ss_change_det[15]` -> the same register, core emu PLL clock, +0.243 ns.
- Deduplicated report warnings: 67, including 38 Critical Warning lines, exactly matching C1 seed 1 after normalizing project paths. No warning text was added or removed. These are not zero-warning builds.

All timing groups, warning text, critical-path endpoints and report hashes are in `results.json`; complete routed path details are in `v1/physical_setup.rpt` and `v1/physical_hold.rpt`. `final_integrity.json` records the final hash/settings/preservation checks and warning comparison.

## Exact bitstream

```text
C:\Users\fbrev\Documents\Diversos\Dev\SMS_MiSTer\tests\ym2413_public_v1_integration\quartus_seed1\v1\output_files\SMS.rbf
```

SHA-256:

```text
f91797c3860370d6d0ee377f6a5416a73a693ba6d52a902695f5ec041ec6a5a0
```

Size: 4,128,104 bytes. The RBF hash matches the Assembler completion marker and final collector. This is the public-v1 descriptor build, not the earlier v20 binary. Its next step is physical MiSTer testing with newly saved v1 states and legacy non-FM cases; FM-tagged experimental saves are intentionally incompatible.

Main workspace, master, sys/, C1/B1 and all pre-existing worktrees and evidence remain unchanged. The original C1 seed-1 RBF still hashes to `7f4ba7e188c99a5ae623e49e4df4311084a23fbd47404a93de3ab974e728fafa`. No commits, merges, pushes, PRs, deployment, extra seeds or LOAD architecture changes were performed. The inherited late-DDRAM-timeout partial-restore limitation remains documented in `../LOAD_AUDIT.md`.
