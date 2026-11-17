# PhaseMemory AUTO: paired seed-2 confirmation

Date: 2026-10-29 (America/Sao_Paulo). Branch: `experiment/phasememory-auto-inference`. Baseline: `8443a0d19a88aff7a5900011bccf386daf146945`.

## Result and recommendation

The area reduction repeats in both matched seed pairs and all reported timing passes. PhaseMemory AUTO inference is a reasonable candidate for hardware validation. Keep it experimental until that validation; this is evidence from two seeds on one device/tool configuration, not a production signoff.

Seed2 candidate minus its fresh seed2 baseline: **-207 placed ALMs, -120 needed ALMs, -310 fitted registers, -137 routing ALUTs, +1 M10K**. Candidate setup/hold: **0.572/0.177 ns**, versus A 0.451/0.243 ns. Setup/hold TNS: B 0/0 ns; A 0/0 ns.

## Matched build identity

This adds only a seed2 A/B pair to the [seed1 experiment](../phase_memory_auto/review.md). All203 tracked source inputs were verified against its manifest before copying; only SMS.qsf SEED1→2 changed in both new trees. Fixed BUILD_DATE261014, Quartus Prime Lite17.0.2 Build602, device5CSEBA6U23I7, SMS/sys_top, MISTER_FB=1, original QIP/IP/SDC and all performance/packing settings are identical across pairs. The original root QSF remains unchanged.

Both seed2 builds started without databases and completed map/fit/asm/sta. They used the same Z:/baseline and Z:/candidate project path layout as seed1. Direct stages bypass only the date-generating preflow. [input_manifest.json](input_manifest.json), [build.ps1](build.ps1), [workflow.log](workflow.log), [results.json](results.json) and [reproduce.md](reproduce.md) retain exact inputs, stages, hashes and instructions. Generated build trees/databases are ignored and unstaged. No incremental implementation or best-of-seed substitution was used.

Both fitter reports confirm effective seed2. [tool_identity.json](tool_identity.json) verifies that all six Quartus executable hashes match seed1.

A/B still differ only by removal of PhaseMemory's `ramstyle="logic"` specification, originally rtl/VM2413/phasememory.vhd:52. [production.diff](production.diff) is the unchanged one-line source experiment. No additional RTL, attribute or memory bank was modified.

## Whole-design two-seed comparison

Each Δ is candidate minus its own same-seed baseline. Needed/placed ALMs are distinct; mapped/fitted FF and logic/routing ALUTs must not be added as independent area charges.

| Metric | Seed1 A | Seed1 B | Δ1 | Seed2 A | Seed2 B | Δ2 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Needed ALMs | 26465 | 26343 | -122 | 26489 | 26369 | -120 |
| Placed ALMs | 31531 | 31278 | -253 | 31545 | 31338 | -207 |
| Mapped FF | 34857 | 34515 | -342 | 34857 | 34515 | -342 |
| Fitted registers | 35709 | 35363 | -346 | 35772 | 35462 | -310 |
| Logic ALUTs | 37056 | 36917 | -139 | 37057 | 36918 | -139 |
| Routing ALUTs | 13159 | 12968 | -191 | 13184 | 13047 | -137 |
| M10Ks | 487 | 488 | +1 | 487 | 488 | +1 |
| MLAB cells | 0 | 0 | +0 | 0 | 0 | +0 |
| DSP blocks | 39 | 39 | +0 | 39 | 39 | +0 |
| Setup slack ns | 0.508 | 0.495 | -0.013 | 0.451 | 0.572 | +0.121 |
| Hold slack ns | 0.144 | 0.242 | +0.098 | 0.243 | 0.177 | -0.066 |
| Setup TNS ns | 0 | 0 | — | 0 | 0 | — |
| Hold TNS ns | 0 | 0 | — | 0 | 0 | — |


Full per-clock seed2 setup/hold slack and TNS: [timing_table.md](timing_table.md). Full STA/map/fit reports remain in baseline/output_files and candidate/output_files. The inherited unconstrained categories remain A setup, hold, B setup, hold; positive reported slack does not mean fully constrained hardware signoff. No additional keeper wildcard query was needed; the successful full STA reports provide this seed's timing evidence.

## Memory mapping and local versus global cost

Logical mapping signatures match seed1 in both A and B: mapped FF totals, logical memory bits, DSP counts and PhaseMemory RAM parameters are unchanged across seeds. B's phase_array is the same18×18 simple-dual-port RAM with OLD_DATA collision semantics; one extra fitted M10K, zero MLABs. The other three FM banks retain their logic attributes. No fallback inference template or explicit block attribute was tried.

| PhaseMemory hierarchy allocation | Needed ALMs | Placed ALMs | Dedicated FF | Memory bits | M10Ks |
| --- | ---: | ---: | ---: | ---: | ---: |
| 1 baseline | 123.6 (123.6) | 235.0 (235.0) | 349 (349) | 0 | 0 |
| 1 candidate | 15.2 (15.2) | 15.7 (15.7) | 6 (6) | 324 | 1 |
| 2 baseline | 121.2 (121.2) | 234.0 (234.0) | 349 (349) | 0 | 0 |
| 2 candidate | 15.3 (15.3) | 15.5 (15.5) | 8 (8) | 324 | 1 |

Fractional hierarchy counts are allocations, not guaranteed removable sites. The whole-design tables above, including changes elsewhere from packing/duplication/routing, determine the physical result. Logical state width and savestate format are unchanged. An extra324 configured memory bits records existing phase state moved from FFs to RAM; it is not new functional state. M10K use moves487→488 out of553, leaving65 nominally free blocks. DSP and MLAB totals are unchanged.

## Routing and warnings

```text
Seed1 baseline:
; Average interconnect usage (total/H/V)                      ; 28.9% / 29.0% / 28.7% ;       ;
; Peak interconnect usage (total/H/V)                         ; 53.7% / 54.6% / 56.4% ;       ;
Seed1 candidate:
; Average interconnect usage (total/H/V)                      ; 29.3% / 29.1% / 30.0% ;       ;
; Peak interconnect usage (total/H/V)                         ; 49.2% / 48.9% / 59.2% ;       ;
Seed2 baseline:
; Average interconnect usage (total/H/V)                      ; 29.1% / 29.4% / 28.4% ;       ;
; Peak interconnect usage (total/H/V)                         ; 47.3% / 46.3% / 51.1% ;       ;
Seed2 candidate:
; Average interconnect usage (total/H/V)                      ; 29.3% / 29.3% / 29.0% ;       ;
; Peak interconnect usage (total/H/V)                         ; 53.2% / 55.1% / 48.8% ;       ;
```

Routing-resource utilization rows and normalized warning ledgers are in [results.json](results.json). Seed2 normalized warning messages added/removed: **0/0**. Seed1's average interconnect rose28.9→29.3% even though placed ALMs/routing ALUTs fell; evaluate seed2's average, peak and directional figures separately. These are implementation tradeoffs, not a claim every routing/timing metric improves. No per-operator ALM estimate replaces the measured full-device result.

For seed2 specifically, average total interconnect rises29.1→29.3%; peak total rises47.3→53.2% and peak H rises46.3→55.1%, while peak V falls51.1→48.8%. Routing ALUTs fall137. Setup margin improves121ps, but hold margin falls66ps and remains positive at177ps. Thus the repeated area gain does not establish an across-the-board routing or timing improvement. These higher routing peaks remain a reason to keep the change experimental until hardware validation.

## Functional qualification reused

No functional RTL changed between seeds. The prior unadapted bank scoreboard, mapped-memory comparison, complete OPLL RTL/mapped comparisons and native-controller savestate tests remain applicable and passed. This includes101,458 bank cycles/406,112 checks,946,616 complete OPLL cycles,8,482,683 paired-controller cycles and2,222,128 mapped savestate audio samples with56,160 nonzero samples. [Prior functional results](../phase_memory_auto/functional_results.json) and [prior detailed limitations](../phase_memory_auto/review.md) remain unchanged. **No new simulations were run or claimed for seed2.** Source hashes and identical logical mapping signatures bind the reused qualification to these builds.

This preserves the specified baseline's behavior; it does not add later v19 complete OPLL save-state history. Neither seed is hardware validation. The two observed paired fits are evidence about this device/tool/settings combination, not an exhaustive seed search or a statistical guarantee.

The untested seed2 candidate bitstream is [candidate/output_files/SMS.rbf](candidate/output_files/SMS.rbf). [bitstreams.json](bitstreams.json) records both generated RBF sizes and SHA256s for later identification; no bitstream was installed on hardware.

## Preservation and stopping point

[preservation_before.json](preservation_before.json) freezes109 prior seed1 artifact/report hashes plus protected refs and the root PhaseMemory hash. [final_validation.json](final_validation.json) confirms zero preservation mismatches, identical root RTL, unchanged refs and no staged files. The active experimental branch still has HEAD8443a0d with only the previously authorized one-line PhaseMemory deletion uncommitted. Master, v19 and the structural-investigation branch are unchanged.

All new seed2 artifacts are under tests/phase_memory_auto_seed2. No seed1 report/database was regenerated, no other bank or third seed was attempted, and no commit, merge, push or PR was made. Stop here for review; hardware validation or any further work requires separate authorization.
