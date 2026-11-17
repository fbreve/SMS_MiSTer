# Work log

Final: completed. All24 runtime cases/82 current-image LOADs,all14 G06 scenarios,
full95567723-clock miter and911 format scenarios pass. Full controlled fit A:
needed36406 (+106),placed39048 (+47),fitted FF48362 (-66),setup+.360ns,
hold+.196ns,zero negative-TNS checks,no new warning types. No area recovery;
NO SAFE MATERIAL OPTIMIZATION FOUND. No production changes retained. Recommend
roadmapD capacity/architecture planning before F01 implementation. review.md has
all51 items;validation.json passes. All processes finished;phase lock removed.
Nothing staged,committed,pushed or published. Prior reports unchanged.

## Historical checkpoint below (superseded by final status)

2026-10-25 21:42 local: current task remains active; no final classification yet.
HEAD cb2e861, branch optimize/savestate-sprite-resources. Production unchanged.
User request is attachment602864ee-7049-4da5-830e-4b449f0e9127. No commit/stage/push/PR.

All six prerequisite reports were read; baseline.json records their hashes.
Exact G06/G10 diff saved. attribution.md/equivalence.md document source map,
all74*64+42 fields and the structural proof. No semantic bits removed.

Micro baseline6161 ALUT/14819 FF; A6123/14819; B15693/14819 (reject masks).
Full-board mapped A45004 ALUT versus45302 baseline, controller6467 vs6547;
total mapped registers45808 unchanged. A is still isolated candidate_A.sv.

Focused miter PASS9294437 clocks/532 format scenarios/48 randomized LOADs.
Full miter PASS95567723 clocks/911 format scenarios/48 randomized LOADs.
Both compare all95 outputs,full9600 bank bits and FSM every clock.

Canonical simulations:23/24 PASS in simulation_results.json. All14 original
G06 scenarios including accelerated64 and long first-visible pass; G02,G03,
G04(native10000 clocks),G05 targeted42000 samples,13 natural phases,both stall
profiles,full900000 flush and dual-VDP IRQ all pass. Only guest_q/dut_history
is running (real NMI guest writes to VRAM/CRAM/scroll/mode,42000 samples x4).
Main remaining runner session10806 (worker0) will complete after guest_q.
Worker1 session82233 had been waiting on phases/parallel.lock; lock removed
after all four parallel cases passed at21:42. It should skip their completed
logs and the already-passed dual case,then finish. Parallel phase sessions
29452/49122/41792/68526 passed. All14 sprite workers passed.

Full controlled build session74608 started21:05; fitter PID100084 started21:15.
At21:42 it remains active in physical synthesis boolean division; no fit or
timing result yet. One full candidate fit only,three standalone micro maps.
Do not claim savings/readiness before fit. Fixed exact established config.
prepare_build.js verified136 inputs/134 committed plus two unused backups;
only controller differs. build_id copied/date verified by collect_build.js.

Once fit completes: run collect_build.js, inspect needed/placed/FF/packing,
setup/hold,all warning IDs and source verification. User stop conditions apply
if timing fails/resources materially worsen; no test weakening. If beneficial
and materially worth retaining AND all24 cases pass,adopt candidateA into
rtl/savestates.sv only,trim trailing whitespace,verify --retained and diffcheck.
Otherwise preserve unchanged production and classify evidence honestly.

Create decision.json with classification exactly one of the user's four,
retained boolean,summary,selectionReason,recoveryAssessment,packingExplanation,
furtherWork,classificationReason,roadmap,nextTask (optional stopReason/fanoutFinding).
Then report.js writes required51-item review.md. No review.md/decision.json yet.
collect_progress.js refreshes canonical logs/hashes. verify_artifacts.js verifies
all203 tracked files,6 prerequisite reports,adapter identity and56 consumed
ROM/oracle inputs; passes with no production changes as of21:39.
Need final validation/source identity/report links/51 items/git status/staged.

Infrastructure exclusions: missing-ROM copy pilots stopped; G04 missing native
oracle failed twice because conditional fopen was missed; corrected preflight,
file identity verified and final G04 PASS. Runner markers corrected to inherited
PASS V15/RICH V15 labels (controller actuallyv16). Large64-slot G05 support
pilot incomplete/one native-command abort; excluded. Canonical G05 is unchanged
post-G08 targeted8-slot no-sprite42000 sample case,passed. Dual child named
dut_collision runs completed sourceName=dut_enabled dual-IRQ fixture,not old
uncompleted dual pilot; manifest records scenario. All original data preserved.
