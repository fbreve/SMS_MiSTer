# YM2413 RegisterMemory AUTO: functional qualification

**PASS: ready for a controlled, separately authorized Quartus resource comparison.** No synthesis, physical compilation or hardware validation has been performed for this candidate. No FPGA savings or actual RAM inference are claimed.

## Isolation and exact production change

- Baseline and current experimental HEAD: `9873761503510e4b2c7e06600bf5515344235c2f`.
- Branch: `experiment/ym2413-registermemory-auto`.
- Worktree: `tests/ym2413_registermemory_auto/worktree`.
- The only production difference is in `rtl/VM2413/registermemory.vhd`:

```diff
-    attribute ramstyle of regs_array : signal is "logic";
+    attribute ramstyle of regs_array : signal is "AUTO";
```

The 9×24-bit array, address handling, registered read, write priorities, raw-clock behavior, reset and sequential initialization remain unchanged. All 104 snapshot words, descriptor version 17, capture/restore assignments and transport remain intact. Neither mixer omission is included. `production.diff` contains the complete production patch.

Final source checks compare every tracked production file in `rtl/`, `sys/`, `SMS.sv` and `files.qip` against the exact baseline, permitting only this attribute replacement. The staged index is empty. Master and all prior worktree HEADs, tracked diffs and tracked status match the initial preservation record. The full-state, mixout-only, accumulator-only and combined candidates remain unchanged.

## Independent functional verification

| Check | Result and coverage |
|---|---|
| Long full-core differential campaign | **72/72 positions, 144 LOADs**, two SAVE/LOAD operations per position; 888,916,572 raw-edge state/audio checkpoints |
| Follow-up per LOAD | **115.18686000–115.18686000 ms**, with exact comparison from the first raw edge after unfreeze; no self-healing allowance |
| Persistent state | All 104 independently observed words, delayed slot counters and factory voice RAM; both raw 14-bit and clamped 13-bit audio compared |
| RegisterMemory independent model | **16,174 cycles; 48,524 checks; all nine entries**, including random normal/SS writes, old-data collisions, registered latency and reset/initialization |
| Pending writes | **8 long-campaign snapshots** with the controller register-write strobe asserted; direct bank tests also deliberately restore values different from the pending normal write before unfreeze |
| Additional short continuation sweep | **72 positions × three LOAD continuations**, 200 enabled clocks per continuation, with clock-enable stalls |
| Independent state-map patterns | Eight independently masked patterns across all 104 words |
| Full-state transport modes | **7/7 passed**, three tagged SAVE/LOAD continuations and a legacy load in each; includes System E, BIOS, rhythm, key-off, partial custom-instrument writes and FM-disabled operation |
| Protocol | PASS: DDRAM backpressure and registered reads, malformed descriptor rejection, legacy 64/96 KiB handling and stale FM-tail rejection |
| Non-FM behavior | PASS: eight cases covering BIOS/cartridge, System E, all four slots and stalls against the upstream non-FM controller |

The reference RTL was extracted from the committed baseline with `git show`; candidate RTL came from this new worktree. They were independently compiled into `reference_work` and `candidate_work` libraries. Verification also checks that their normalized module sources differ only in the RAM attribute. Wrappers are extracted from the actual production integration, including freeze gating and wrapper writes.

Transport mode 0 retains the production 900,000-clock load flush and 80,000-clock continuation setting. Modes 1–6 use the existing accelerated transport fixture (90-clock flush and 5,000-clock continuation). The separate long GHDL campaign uses the production FM RTL and wrapper with a 15:1 raw/FM-enable schedule and explicit raw-clock gaps; it directly drives the private snapshot interface rather than simulating DDRAM for each 115 ms continuation. The protocol and full-state transport regressions separately qualify the DDRAM/controller behavior. These fixture profiles are kept distinct in the retained scripts and results.

Read-only observation signals expose live RAM and internal state; expected snapshot values are checked against those observations rather than values produced by SAVE itself. A separate bank scoreboard models the registered old-data contract from input transactions. The full-state ModelSim regressions additionally use the existing independent hierarchical oracle and the actual transport/controller.

The long campaign programs all nine channel entries with independent instrument, frequency and key expectations; launches instrument commands immediately before SAVE and after LOAD; corrupts the candidate before restoration; checks every restored word against the original internal image; and exercises 1,000 raw clocks with no FM enable after unfreeze. It then applies nine verified later events per LOAD (**1,296 events total**): key-off/on, rhythm/percussion changes and partial custom-instrument updates. Envelope state/phase, oscillator phase, feedback, controller pipelines and audio remain equal throughout. Snapshot envelope codes recorded at SAVE were 0, 1, 2, 3; continuous equality checks also cover the intervening envelope evolution and key transitions.

The bank scoreboard checks address/data changes before the next clock do not propagate to the registered output; reads return pre-write data on both normal and savestate collisions; SS writes suppress a frozen pending normal write; the first raw edge after unfreeze executes the pending write correctly; long frozen intervals preserve RAM; and reset restarts sequential initialization without clearing payload asynchronously. Both cold initialization and legacy initialization/transport are exercised. Normal addresses 9–15 are outside the array and are not qualified behavior.

Simulation-only language adapters are documented in `source_identity.json`: reserved identifier renaming, equivalent integer bounds, meta-valued case alternatives, process labels, explicit entity binding and declaration-order compatibility. State observation is read-only. No production behavior or RAM structure is rewritten for simulation. There are no poison hooks or tolerated mixer differences.

All 117 GHDL invocations have explicit Idle/Low priority samples, including compilation. Workers inherit Idle from their owned PowerShell parent and verify GHDL priority throughout execution. Simulation concurrency never exceeds four. A Toolhelp process-tree check verified running GHDL processes and their observed children at Idle; unrelated process priorities and global scheduling settings were not modified.

No unresolved functional assertion failures or timeouts remain. A preliminary two-LOAD pilot is retained separately and is not included in the 144-LOAD campaign total. ModelSim reported its existing Starter Edition design-size/performance warning; this is not a Quartus inference warning. Native execution uses the recorded GHDL binary SHA-256 `dc983e37f4a606d9803557f728902b8e2bcb96cd9fb3f117307fb4de129e6a91`.

## Inference concerns and expected resource trade-offs

This is **RTL simulation equivalence**, not synthesis equivalence. GHDL executes the same functional RAM process for either attribute value; its success does not prove that Quartus chooses block RAM or implements the required collision behavior.

The structure has a single clock, registered reads, a single priority-controlled writer and sequential payload initialization. Reset affects the initialization/control state rather than asynchronously resetting the array. No obvious structural blocker was found, but actual Quartus inference remains unknown. The normal/init/SS address and write-data selection still requires circuitry, and AUTO is allowed to retain logic. No memory restructuring has been attempted.

Potential benefit is moving small-array storage and access logic out of ALMs/flip-flops. Possible costs include an additional M10K or MLAB allocation, underused memory capacity, different routing and changed timing. These are qualitative possibilities, not measured savings. The array dimensions, format and DDRAM snapshot size have not been reduced.

Before establishing a physical baseline, an authorized Quartus run must inspect the inferred memory and its effective read latency/read-during-write mode, compare whole-design and local resources/timing, and verify PhaseMemory and snapshot scratch RAM inference. A mapped functional bank test should repeat the independent scoreboard, especially OLD_DATA collisions, initialization, SS writes and the first raw edge after unfreeze. A DONT_CARE or otherwise incompatible collision contract cannot be accepted solely because RTL simulation passed. If AUTO does not infer RAM, document that result without automatically restructuring the source.

## Evidence and reproduction

- `results.json`: phase-by-phase results, counts, hashes, regression summaries and remaining synthesis qualification.
- `source_manifest.json`: exact baseline, independently prepared source libraries, frozen test inputs and GHDL identity.
- `preservation_before.json`, `verify.js`: source/ref preservation and exact attribute-only scope checks.
- `worktree/tests/ym2413_fullstate/logs/`: separate native stdout/stderr, priority samples, exit codes, ModelSim logs and wave files.
- `workflow.log`: phase start/end records.
- `run_all.ps1`, `compile.ps1`, `bank.ps1`, `regress.ps1`, `launch_campaign.ps1`, `one.ps1`, `run_ghdl.ps1`: reproduction entry points; completed logs are intentionally not overwritten. Use a fresh output/library copy when replaying.

The isolated test scripts now pin the committed baseline instead of the old pre-commit HEAD assumptions. The generation helper uses the retained, neutral observation harness from the previous experiment; compiled RTL is sourced independently from the baseline and this candidate, not from experimental mixer RTL. For a fresh setup, retain the test sources and scripts, regenerate libraries with `prepare.js` from a fresh baseline worktree, then use `run_all.ps1`. Do not rerun preparation over completed evidence.

**Stopped after functional qualification. No Quartus builds, commits, merges, pushes, PRs or hardware tests were performed.**
