# YM2413 mixout-only self-healing experiment

Simulation result: PASS. Stop before synthesis or hardware testing.

Branch: `experiment/ym2413-selfhealing-mixout`. Parent/HEAD: `9873761503510e4b2c7e06600bf5515344235c2f`.
The full-state reference, master, shared sys and previous worktrees remain unchanged.
No commits, Quartus builds, merges, pushes or PRs were made for this experiment.

## Baseline gate and reproducibility fixes

Before editing production RTL, reran the entire full-state suite with committed
production content checked against 9873761503510e4b2c7e06600bf5515344235c2f (normalizing checkout line endings). All 11 result
logs pass: independent injected 104-word map; readiness/legacy/malformed protocol;
non-FM master comparison; all 72 phase offsets with three LOADs each; native
FLUSH_MAX=900000 musical continuation; and modes 1 through 6 (System E, BIOS,
rhythm, key-off, partial writes and disabled FM). Logs and identity manifests are
preserved in [baseline_validation](baseline_validation/results.json).

The original test scripts assumed an uncommitted port on upstream HEAD.
prepare_tests.js now pins the FM reference to the committed full-state baseline
and the independent non-FM controller to upstream 66f16d5c656fd8906d62570da4d258875bcee684.
verify_scope.js now checks the experiment branch/parent and every production file
against the committed baseline; test-only edits are allowed. The runner now
checks each preparation script's exit status. No production file changed before
the baseline gate passed.

## Exact production change

Only rtl/VM2413/temporalmixer.vhd changes:

```diff
diff --git a/rtl/VM2413/temporalmixer.vhd b/rtl/VM2413/temporalmixer.vhd
index 18574930..5d4b2766 100644
--- a/rtl/VM2413/temporalmixer.vhd
+++ b/rtl/VM2413/temporalmixer.vhd
@@ -119,8 +119,7 @@ maddr <= ss_v_maddr;
 ss_v_mix(13 downto 0) := ss_wdata(19 downto 6);
 mix <= ss_v_mix;
 when 102 =>
-ss_v_mixout(13 downto 0) := ss_wdata(13 downto 0);
-mixout <= ss_v_mixout;
+null; -- Experiment: output is refreshed by the next normal mixer update.
 when others => null; end case;
 end if;
 end if;
```

The operational register, reset, normal slot-17/stage-2 update and capture of
word 102 remain. The format remains 104 words/version 17. Capture, scratch RAM,
DDRAM transport, handshakes, refill, initialization and every other restored
field match the committed baseline. No other omission was introduced.

## Experimental method

Two actual production FM wrappers use identical host clocks, one enabled FM
clock per 15 host clocks, and the committed full-state reference in a separate
simulation library. The test uses the real wrapper bus-write behavior and
freeze/restore ports. It validates initialization and visits every actual saved
counter value 0..71, verified from word 78. Every position performs three repeated
SAVE/LOAD cycles: custom-instrument sustained/key-on notes, key-off with rhythm,
then retrigger/custom update with the rhythm flags cleared. Assertions verify all nine
key flags, rhythm flags and nonzero custom-instrument data at SAVE. Saved envelope
states observed: 0, 1, 2, 3 (encoding from the production state map).

To avoid an accidentally equal or silent output hiding the omission, before each
LOAD the candidate mixout is deposited with saved word 102 XOR 1. Both wrappers
then receive all 104 writes, at the same alternating-host-clock cadence as the
snapshot apply port, followed by eight refill clocks. The reference restores
word 102; the candidate must retain the unequal stale value. No other field is
poisoned or omitted. This establishes a deliberately mismatching-output bound;
natural stale output may already equal the saved output and converge earlier.

The independent Tcl oracle packs actual RAM/registers, never ss_rdata. It checks
all 103 other words against the pre-SAVE expected state immediately after LOAD;
all 104 words against the reference at convergence, after the long follow-up,
and after subsequent identical key transitions. It also checks coherence of the
three delayed slot counters. Actual raw 14-bit FM and clamped 13-bit wrapper
audio are compared on every host clock from the predicted normal update onward.
Every enabled-clock raw audio pair is preserved in heal_audio_*.csv, including
the pre-convergence mismatches. The collector independently rechecks all CSV rows,
counts, first-equal positions, exit codes and PASS/FAIL markers, then hashes traces,
logs and sources. Explicit simulation watchdogs and campaign completion checks apply.

## Measurements

- 72 actual slot/stage positions, 216 LOADs, 30,837,132 recorded enabled-clock audio pairs.
- Exact measured convergence: 1..72 enabled FM clocks, matching `((70-saved_count+72)%72)+1` in every LOAD.
- Best position: count 70 (one enable); worst position: count 71 (72 enables).
- Maximum frame-equivalent bound: 72/59736 = 0.001205303 NTSC frames; 72/71364 = 0.001008912 PAL frames.
- After convergence, each LOAD follows 142,728 more enabled clocks: two PAL frames, or 2.389312977 NTSC-frame equivalents.
- No post-convergence raw/clamped audio mismatch or persistent-state mismatch appeared.

The frame conversion is explicit enabled-period accounting: the production pixel
enable is every 10 host clocks, FM enable every 15, with 342 pixels per line and
262 NTSC / 313 PAL lines. Thus frames contain 59736 / 71364 FM periods. This
bench does not instantiate a running VDP; figures are frame equivalents, not
measured video interrupts or an absolute nanosecond claim at a particular PLL rate.

## Artifacts and reproduction

Detailed results: [heal_results.json](worktree/tests/ym2413_fullstate/heal_results.json).
Per-position logs/exit codes: worktree/tests/ym2413_fullstate/heal_runs/.
Full raw audio traces: worktree/tests/ym2413_fullstate/heal_audio_0.csv through heal_audio_71.csv.
Source and trace SHA-256 identities are in heal_results.json.

For a fresh reproduction, create a worktree at the pinned baseline; apply only the
test-script fixes and run run_all.ps1 before the production patch. Preserve its
logs/manifests in ../baseline_validation. Apply the mixout patch and new heal test
sources; run node prepare_tests.js, compile with ModelSim heal_compile.do, then
run heal_campaign.ps1 and node collect_heal.js. The campaign refuses overwriting
an existing heal_runs directory. ModelSim executable paths follow the installed
Quartus Lite 17.0 tools. Do not run the strict full-state equality oracle on the
candidate expecting word 102 equality immediately after LOAD: that difference
is the experiment's intentional transient, and the heal oracle checks it explicitly.

An initial launcher classified four successful simulations as failures because
PowerShell Start-Process returned empty ExitCode properties. These diagnostics
are preserved separately in heal_runner_diagnostic; the driver now uses explicit
per-process exitcode files, and all 72 positions were rerun with stimulus checks.
The short pilot and old diagnostic cases are excluded from the acceptance totals.

## Remaining risks and decision

The omission is experimentally self-healing within the permitted interval for
the tested cases. The output does not feed back into the FM envelope, oscillator,
RAM or controller state; the tests demonstrate equality of those persistent fields
and continued audio equality. A transient output difference is still expected and
could be audible. These checks do not cover every possible software event stream.

The bench compares FM and wrapper-clamped output, not the entire downstream
MiSTer audio/filter/DAC chain or physical hardware. Frame equivalence is derived
from production clock ratios. Further physical validation is still required.
No resource saving is claimed: mixout remains a normal register, and only its
restore input/control logic can shrink. Whether Quartus saves ALMs, registers or
routing must be measured in a separately authorized paired physical build.

Ready for independent review of this one-field experiment. No synthesis or next
optimization has been started.
