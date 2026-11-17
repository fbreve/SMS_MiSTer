# Sprite resource experiment

Start with review.md, attribution.md and equivalence.md. The immutable baseline
is cb2e861 / v16. No format consolidation or guest-state reduction is included.
All earlier test trees are inputs and must remain unchanged.

Tools: Node24.20, ModelSim Intel FPGA Starter10.5b, Quartus Prime Lite17.0.2
Build602, device5CSEBA6U23I7, SMS/sys_top, seed1. Board QSF/SDC/IP/settings are
copied verbatim from the committed/source-verified post-G12 controlled build.

## Sources and micro-synthesis

prepare.js records tracked-file/report hashes, the exact G06/G10 diff and two
isolated controller variants. It requires a clean tracked baseline. It does not
edit production. candidate_A.sv is the priority/enable extraction; candidate_B.sv
is the parallel-mask experiment. The letter of that file is not the user's
candidate-family label: candidate_B implements family C. micro.ps1 synthesizes
the standalone full controller with virtual ports. Its area numbers are ALUTs,
not physical ALMs or board-fit results. Virtual-pin wildcard warnings apply to
these micro experiments only.

## Controller equivalence

prepare_miter.js A prepares miter_A; adding --focused prepares focused_A. Run
ModelSim from that generated directory with `-c -do "do run.do"`. The full miter
retains all911 v16/current/legacy/rejection/background scenarios, then16
full-width sprite profiles and48 repeated LOADs. It compares all95 outputs,
the FSM and all9600 snapshot bits every clock. The focused variant omits only
background one-hot/counter enumeration and keeps532 format cases plus the same
sprite profiles. No image, data-bus or first resumed clock is masked.

PowerShell redirected console files can be UTF16LE; the collectors detect BOM.
Simulator -l files are plain text. A zero native return code alone is not a pass.

## Current integration matrix

Preparation sequence (only within this task tree):

1. prepare_regressions.js A
2. prepare_targeted_g05.js
3. prepare_dual.js
4. fix_oracle_copies.js
5. add_hold_monitor.js

The final regression_manifest.json is authoritative. It contains14 original G06
sprite scenarios and ten targeted VDP/restart cases. Sprite independent oracles
are the retained original reference_*/reference.dat files, copied byte-for-byte.
The other oracles/guest ROM hashes are in the manifest. All literal read-mode
file dependencies are checked by fix_oracle_copies.js before execution.

Use regress.ps1 -Worker0/-Worker1 -Workers2 -SkipSprites for non-sprite families.
It preserves completed cases. Compile sprites/compile.do once, then use four
sprite_matrix.ps1 workers. Each sprite worker runs unchanged original arguments
and SAVE-only/three LOADs, using the immutable original independent oracle.

The G05 target is the existing post-G0842,000-pixel text-to-Mode4 case, retaining
its no-sprite8-slot configuration and three replays. See g05_targeted_scope.md.
The dual directory's historical child name dut_collision runs the completed
independent-dual-VDP IRQ fixture, sourceName=dut_enabled; scenario metadata and
the exact run.do identify it. No uncompleted old dual pilot is an oracle.
Inherited PASS V15 labels name the old fixture, not the new controller format;
the actual controller is current v16 and the full format miter verifies it.

For parallel phase/stall execution, compile phases/compile.do once, then run
run_case.ps1 -Family phases -Name <dut_phases|dut_deterministic|dut_lfsr|
dut_full_flush> in separate processes. During the recorded run, parallel.lock
prevents the sequential runner recompiling that shared read-only library.
Remove that single lock file only after all four processes have completed and
their logs passed. The lock is test orchestration, never production input.
run_case.ps1 can also run an already compiled dual/dut_collision case.

collect_progress.js produces the fail-closed canonical simulation_results.json.
Incomplete supporting64-slot G05 attempts, the interrupted fresh-reference
pilot, missing-ROM/native-reference pilots and runner-marker errors are excluded.
Original assertions and sample counts are retained. Failed infrastructure logs
are archived separately; no functional divergence is reclassified as a pass.

## Full controlled fit

prepare_build.js verifies136 retained baseline input hashes (134 committed
inputs plus two unused retained backups), checks the focused simulation gate,
and prepares a fresh source-only quartus_A. Only rtl/savestates.sv differs.
The exact build_id.v is copied and verified after the same-date pre-flow script.
build.ps1 runs one full fixed-configuration fit via the existing Z: alias.
collect_build.js verifies all inputs again and extracts resource, packing,
hierarchy, fanout, timing and warning-ID differences against the retained exact
committed baseline. No database reuse or QSF/seed/SDC optimization is performed.

Only a beneficial, fully verified result may be adopted into production. The
decision and actual retained diff belong in review.md. No staging, commit,
push or PR is part of this task.
