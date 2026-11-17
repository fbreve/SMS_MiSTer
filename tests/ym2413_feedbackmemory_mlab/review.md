# FeedbackMemory MLAB inference experiment

Functional tests and Analysis & Synthesis passed. Guaranteed silicon OLD_DATA compatibility remains unresolved. A constructed range-legal LOAD reaches a consumer of a collision-produced read, so collision irrelevance cannot be asserted for every accepted payload. Recommendation: hold the Seed 2 full build for independent review of this finding. No Fitter or hardware test was run.

## Isolation and exact production change

Baseline: `9873761503510e4b2c7e06600bf5515344235c2f`. Branch: `experiment/ym2413-feedbackmemory-mlab`. Worktree: `worktree`. Only production change:

```diff
-  attribute ramstyle of data_array : signal is "logic";
+  attribute ramstyle of data_array : signal is "MLAB";
```

The 9x10 sign-magnitude array, negative zero, registered read, initialization, raw-clock operation and snapshot words49-57 are unchanged. All104 words and descriptor version17 remain. RegisterMemory and OutputMemory retain baseline logic attributes; mix and mixout restoration remain intact. No sys/master/reference/other experiment changes. Test scaffolding and generated test inputs belong only to this isolated experiment and must be excluded from any final production-only upstream PR.

## Functional evidence

- Independently compiled reference and candidate GHDL libraries differ only in the requested attribute after identical compatibility adapters and read-only observers. Sources are pinned to commit98737615, not an earlier HEAD or v19. Independent internal-state packing checks SAVE and LOAD, rather than comparing two uses of the serializer.
- All72 slot/stage positions, two LOADs each:144 long LOADs, 888,919,308 raw-clock state/audio checkpoints. Each LOAD has115.186860ms follow-up plus later musical writes. All104 words, persistent feedback/output/operator/phase/envelope state, factory instruments, delay counters, both OutputMemory read ports and FeedbackMemory read output compare exactly. No self-healing allowance.
- Each phase injects an independently specified feedback image containing +0, -0, +511, -511, alternating bits and smaller magnitudes. All nine entries are checked against those constants in captured/restored state. All four envelope states are covered;36 captures have pending OutputMemory writes and18 have pending feedback writes in word100. First raw unfreeze edges and a1000-raw-clock CE-low gap are compared. Key-on/off, rhythm and custom-instrument writes have independent effect assertions.
- Independent FeedbackMemory scoreboard:22,691 cycles,136,310 counted checks, all81 write/read address pairs across six patterns,3,283 collisions including2,137 snapshot collisions,5,426 invalid/frozen access cases and731 negative-zero observations. Checks pre-edge stability, registered OLD_DATA, post-edge/falling-edge stability, async control reset/read-output retention, initialization/readiness, held initialization, snapshot writes during initialization, invalid snapshot addresses and repeated raw writes.
- Supplemental collision-consumption diagnostic:72 positions /144 short LOADs,2,592 snapshot collision cycles, zero normal collisions and zero enabled Operator consumptions in those bounded coherent traces. These short diagnostic LOADs are separate from the144 long continuation LOADs. They do not establish exhaustive reachability or silicon semantics.
- Independent ModelSim regressions passed:832 state patterns; DDRAM protocol/BUSY/registered-read tests; non-FM comparison;72-position stalled-read sweep with three short LOADs per position; seven musical/SystemE/BIOS/rhythm/key-off/partial-write/disabled modes including legacy handling. Mode0 uses the original native flush interval; modes1-6 use the existing fast transport fixture. Full checkpoint summaries and hashes are in regression_results.json.
- All 192 GHDL invocations explicitly sampled Idle priority. Maximum concurrent GHDL simulations was four. Toolhelp child snapshots also verified Idle, including owned child processes. ModelSim diagnostics ran sequentially. No unrelated process priorities or global scheduling settings were changed.

## Inferred structure and measured synthesis resources

Quartus Prime Lite17.0.2 Build602, Cyclone V5CSEBA6U23I7, original SMS/sys_top configuration and SDC, frozen full-state Seed2 settings. BUILD_DATE261104 retained for equivalence. All221 source/configuration inputs are hashed; production inputs match the committed baseline except the one attribute. Aggregate SHA256: `34f6fffc26fd97a05e7f542e3c5c77cdc2a95d65cdb14f1f97ce2b47d29cfb39`.

| Local synthesis metric | Logic baseline | MLAB candidate | Delta |
|---|---:|---:|---:|
| ALUTs |73|32|-41|
| Registers |105|15|-90|
| Logical MLAB RAMs |0|1|+1|
| Stored state bits |90|90|0|

One9x10 simple-dual-port RAM, no replication; ten Cyclone V MLAB bit-slice cells, four-bit addresses, last address8. The generated macro estimates one MLAB plus ten output registers. This is an inference estimate, not a measured placed physical block count. Fifteen mapped registers comprise ten output registers and five local initialization/readiness registers. Global mapped registers fall34,942->34,852. Needed/placed ALMs, fitted registers, physical block counts, routing and timing are unmeasured.

Read address/control are unregistered; write address/data/control are on INCLOCK and read output on OUTCLOCK. Actual exported cells feed ten DFFEAS registers using the same raw clk, enable !reset, clrn=VCC and sclr=GND. No additional read stage, FM CE gate or ss_hold gate was introduced at the read output. Initialization counter/readiness and upstream normal-vs-snapshot write selection remain in logic. Snapshot access uses the same read port; no extra read copy is inferred.

Other normalized inferred memory organizations/modes are unchanged, including PhaseMemory and snapshot scratch RAM. No new normalized Analysis & Synthesis warnings:62 unique warnings match the reference. No new latch, multiple-driver, width or memory-inference warning. Functional EDA export separately reports the existing audio-PLL LOCKED/FBOUTCLK warning21300. ModelSim full regressions retain the Starter Edition capacity warning. None is suppressed as evidence of collision safety.

## Collision semantics and targeted mapped-cell test

Raw mixed-port configuration is DONT_CARE, not native OLD_DATA. The exported RAM read is unregistered (vendor default port_b_data_out_clock=none) followed by actual external clocked output registers. Their presence does not establish an unconditional silicon OLD_DATA guarantee.

The targeted vendor test mechanically retains all actual memory/read-output cells, defparams and aliases. It cuts at write/read addresses, write data/enable and output enable; initialization/snapshot arbitration is separately checked by the RTL scoreboard. Independent expected OLD_DATA test passes11,108 cycles /33,296 checks,635 collisions,100 output-hold cycles and813 negative-zero checks, with zero final errors/warnings. This is functional vendor-model evidence, not a full-core mapped simulation, post-route timing simulation or silicon proof.

## Reachable accepted-LOAD counterexample

A separate diagnostic deliberately changes word100 of an otherwise checked payload. This is a range-legal constructed pipeline state, not a state shown to arise from normal coherent SAVE. All104 words were passed through an exact extraction of the unchanged production fm_word_valid function: PASS. Key values:

- word78=0x00000001: Operator slot17/stage0 on its next enabled clock.
- word97=0x0001fff8: faddr8.
- word100=0x457ffc21: fb_wr1, fb_addr8, pending write data0x3ff (-511). Existing OutputMemory fields remain legal.
- FeedbackMemory[8] is0x000 (+0). After refill, unfreeze with CE low for the first raw edge; assert the first enabled pulse on the following edge.

The first raw edge performs a same-address read/write. The following enabled Operator stage0 consumes that registered read. The diagnostic detects this consumption and exits with an intentional hazard-found PASS; no actual RTL/candidate mismatch or silicon corruption is asserted. Under OLD_DATA the carrier modulation is zero. If the unspecified result were the new -511 value, Operator addr would change by2048 modulo2^18, altering persistent word96 state. Thus the question is not settled by the zero-consumption result for coherent SAVE traces.

Guaranteed OLD_DATA is still an unmet silicon proof obligation. Passing vendor models cannot close it. The experiment must not be described as compatible for every accepted LOAD payload, nor should arbitrary collision results be treated as self-healing. No no_rw_check or semantic-relaxation directive was added. No architectural rewrite was attempted.

## Recommendation, provenance and retained artifacts

Recommend independent review before authorizing Seed2 full compilation. Functional simulation and MLAB inference pass and show a local synthesis opportunity, but compatibility acceptance is not complete. A full resource build would measure area/timing; it would not resolve DONT_CARE semantics. Required next decision is whether a supported hardware OLD_DATA guarantee or a scoped/proven collision-consumption argument can satisfy the compatibility requirement. Do not broaden scope or implement reconstruction automatically.

Primary evidence: results.json; functional_results.json; regression_results.json; production.diff; source_manifest.json; synthesis/inputs.json and synthesis/results.json; synthesis/candidate/output_files/; synthesis/FeedbackMemory_mapped.v; vendor/extraction.json and mapped.log; validator/payload.hex, validate.sv and validate.log; worktree/tests/ym2413_fullstate/logs/collision_*.stdout.log and legal_payload_probe.stdout.log. Detailed bounded tests/scripts and priority logs are preserved. artifact_hashes.json records retained evidence hashes. Full netlist SHA256: `edbe6c37fe83739bf2666dd2fbc2238d99e1a24de3a1d83d9e938b1f66f05ae0`.

No Fitter, assembler, STA, RBF, commit, merge, push, PR or hardware test was performed. Earlier experimental candidates remain unchanged. Findings stop here for review.
