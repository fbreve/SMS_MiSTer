# F09 / Master Tap savestate review

Branch `fix/savestate-master-tap`, base committed F05 `e4a1ac9`. Investigation and implementation address F09 only. The audit CSV names this row S072; the request uses S071. Both identify the same Master Tap state omission. No commit, staging, push or PR.

1. **Root cause.** `SMS.sv` retains a player index `jcnt`, sampled TH history `old_th` and capacitor/timeout counter `tmr`, but the committed savestate format has no representation or restore interface for them. Raw `ce_cpu` continues while the CPU itself is frozen, so TH sampling, phase advance and timeout can consume accessory time during transport. Restoring IO control alone cannot restore the selected player or timer history.

2. **Complete state inventory.** Exactly 19 persistent local protocol bits: jcnt[1:0] (selected player), old_th (pending falling-edge history), tmr[15:0] (timeout and next-edge eligibility). All are class A. There is one Master Tap path selecting four `joy[]` inputs on port A; port B is blanked. No independent per-port Tap instance, mode-history register or cached player input vector exists. Registered joya/joyb/joyser, TH returns and USER_OUT are class B derived caches: current inputs and restored protocol state reconstruct them before the existing 255-clock release guard. Buttons, physical USER pins, enable/mode/swap and controller configuration are class C external inputs; physical devices are not rewound. Already-restored IO control is a prerequisite for current TH history. Existing MD6 state stays in its separate F08 payload. The global CE generator is an unchanged core timing input, not a new accessory field; local replay uses identical future CE/TH/input samples. Known whole-core clock-phase uncertainty from the original audit is not broadened into this fix. `inventory.csv` contains the full classification, including excluded F10/F11 state.

The timer is one physical local register shared with raw-serial pause-combo conditioning. It is captured/restored as that same register and its local updates pause under freeze in both original branches. No timer split or new raw-serial protocol is introduced. Current physical pins continue to be sampled. The shared local countdown therefore also participates in this preservation; ordinary behavior outside savestate operation is verified against the baseline.

3. **Before-fix evidence.** Extracted, unmodified production accessory logic gives 53 divergent continuations in 64 cases at shortened threshold 8, and 53/64 at the production threshold 57000. Cases cover four phase setups, TH low/high, pending edges and timer boundary/expired states. The naturally held reference resumes with identical future inputs; no restored payload is injected into the reference. Full-DDRAM baseline verification uses the committed F05 controller and real one-in-15 CPU enable cadence: all three cases diverge after load. Case 0 records saved state 50028, live state 4dea9, reference 50029 and guest pin vectors ee/dd; cases 1/2 return ee where the reference returns 77. Baseline load freeze lasts 940423 host clocks. The actual production logic and full controller are used; test fixtures drive bus/controller inputs rather than forcing state arrays.

4. **Production timeout.** The comparison threshold is 57000, timer saturates at 57001, and phase reset occurs when a CPU tick sees old timer >57000. From zero under continuously high TH this takes 57,002 ticks. Raw CE occurs every 15 host clocks, so the full interval is 855030 host clocks, approximately 15.924370 ms at the PLL's configured 53.693175 MHz (`rtl/pll/pll_0002.v:30`). Falling TH clears the timer and advances player only if the old timer is <57000. The strict boundary deliberately ignores the first falling edge after discharge.

5. **Freeze decision.** Suspend local temporal state during transport and restore it once. Merely restoring after a load would leave save-only operations capable of consuming protocol time. `ce_cpu` generation is unchanged; only the local update condition adds `!ss_freeze`. The shared raw-serial timer's local writes also honor freeze. Restoring the 19-bit state takes priority. Existing ordinary reset behavior is unchanged: no new timer initialization or reset semantics are added. Derived pin caches keep reconstructing from current inputs, which is safe while guest execution is frozen and ensures settled pins before release.

6. **Files.** Production changes only `SMS.sv` and `rtl/savestates.sv`. Top-level declarations expose the existing local registers, connect the accessory bus and add freeze/late-restore handling. The controller captures, validates and transports the state. No new production module, mapper/controller abstraction or source-list change. Tests/evidence are under `tests/savestate_master_tap`; existing untracked regression generators were updated for current tag/new ports and explicit v5 compatibility. Historical logs are retained separately.

7. **Exact representation.** Word 026, one 64-bit slot-relative word:

| Bits | Meaning |
|---|---|
| 63:51 | Reserved zero |
| 50 | old_th |
| 49:48 | jcnt |
| 47:32 | tmr |
| 31:0 | 4d544150, MTAP magic |

Loader requires validated v6 tag/count, exact MTAP magic, zero reserved bits and timer <=57001. All four phase values and both history values are valid. Capture occurs post-drain with freeze already active; restore strobe occurs at pre-unfreeze after IO TH settles. Writer always records the local state, including when Tap is disabled, because the retained timer/history can affect future enabling. Configuration itself is not changed by restore.

8. **Version decision.** v6 tag 484306 is required because v5 and earlier never encoded word 026 as Master Tap state. Existing validated metadata has no Tap presence meaning. Base count remains 3; every existing payload stays at its original position. SC descriptor 025 is followed by new 026, then EEPROM 030/031. EEPROM backing 040-04f, GG 01c/01d, MD6 01e, HCounter/video 01a and PSG 020-024 are unchanged. SC data still uses d01-e00/d01-1500/d01-1d00 by size. System E allocations end 2900. Slot stride remains 3000 words (96 KiB); no overlap or additional backing RAM allocation is introduced.

9. **Legacy normalization.** Untagged/v1/v2/v3/v4/v5 and the old64KiB format have no Tap payload. They restore jcnt=0, tmr=57001, old_th=current restored TH. Future/unknown tags, invalid base count, wrong magic, reserved bits and impossible timer normalize identically. Old unused word 026 is never consumed without a validated v6 tag. Normalization represents the existing expired/discharged idle state; it does not invent a historical phase. Timer zero would be wrong because it would advance on the first falling edge. Tests verify first fall ignored and second fall advances. Historical fields for other subsystems keep their existing behavior.

10. **Directed replay.** PASS 4096 cases at threshold 8 (64 player-input patterns x four phase setups x low/high x four timer positions x pending/nonpending edge) and 64 cases at threshold 57000. Independent reference state is held naturally while DUT advances along a discarded timeline, then restored. Compare every protocol bit and registered pin response through future edges, input changes, long idle, repeated save/load, immediate transitions, reset and disable/re-enable. Separate legacy tests verify normalization. Each selected player's six primary input bits span the input pattern set.

11. **Production-timeout replay.** PASS real threshold replay plus complete DDRAM operations with CE every15 host clocks. Across 63 integrated cases, save freeze spans28065-48082 host clocks and load spans940357-953333, all longer than the complete855,030-clock timeout. At the 100MHz accelerated fixture clock these are0.280650-0.480820ms save and9.403570-9.533330ms load. At configured hardware frequency the same cycle counts are approximately0.522692-0.895496ms and17.513529-17.755199ms. Counter values and CE ratios are production values; clock scaling does not alter the synchronous transition sequence. The pre-fix full-DDRAM tests demonstrate that these loads actually expire the old timer.

12. **Full DDRAM.** PASS 20 scenarios each with no stalls, fixed stalls and deterministic LFSR randomized stalls (60 total), plus three targeted real-IO pending-edge cases. The latter accept a TH change on the save boundary, preserve old_th independently and replay the edge once. Covers phases1/2/3, nonzero and boundary timer, TH history, repeated operations, current payload, untagged/v1-v5, old64KiB, invalid/future tags/count/magic/reserved/timer, disabled Tap and guest reads through actual production IO. Checks serialized word 026 against frozen live reference and previous payload positions against their existing values. Naturally held reference never receives restored data.

13. **MD6 interaction.** Existing `md_pad_enable` excludes status[14], raw serial and other accessory modes, so Tap and MD pad protocol handling are configuration-exclusive. Integrated tests instantiate both real MD pad paths: Tap enabled routes SMS pins with MD type 0; Tap disabled exercises real MD6 state restoration. F08's 2,560 short-timer cases, 160 real-timer cases and13 DDRAM cases pass. MD payload 01e and source/routing are unchanged. Local Tap CE gating does not gate the core or MD clock.

14. **Regressions.** PASS F07 SMS/GG real-VDP replay,10 controller cases and dual-real-VDP integration; F02 24 local serial cases and14 DDRAM cases; F08 directed/production/DDRAM as above; F03/F04 6,642 protocol/backing cases,22 DDRAM cases including explicit v4/v5 payloads, and persistence; F05 162 full-memory DDRAM cases across all sizes/three stall profiles, tail/SD-port/negative controls and restored-dirty persistence; PSG 128-case replay; original audit scenarios and static checks. PASS 100000 host clocks of ordinary Master Tap/disabled/raw-serial behavior against the committed production accessory block. Source-derived tests also verify shared local timer freeze/restore. All checked logs have zero errors/assertion failures. Expected simulator memory-model and Starter Edition capacity warnings are retained.

15. **F06 and other scope.** F06 is intentionally unresolved and unchanged. Original SRAM selection predicates, transfer sizes and persistence blocks are byte-identical. SC selection, EEPROM engines, mapper/decode, MD6, IO and VDP source are unchanged. Paddle/lightgun override branches remain byte-identical; their known omitted state is not fixed. No global CE phase, NMI, Evolution or other audit finding is addressed.

16-19. **Quartus, timing, resources and warnings.** Full Quartus Prime 17.0.2 Build 602 synthesis, fitter, assembly and TimeQuest succeeded on 5CSEBA6U23I7 with unchanged seed/settings. Compilation elapsed 00:26:54. All 136 baseline inputs match the committed F05 build; all 136 candidate inputs match the working tree. Generated build IDs match.

| Resource | Committed F05 | F09 | Delta |
|---|---:|---:|---:|
| ALMs | 26958 | 27083 | +125 |
| Fitted registers | 36355 | 36542 | +187 |
| RAM bits | 3809858 | 3809858 | 0 |
| RAM blocks | 487 | 487 | 0 |
| DSP blocks | 39 | 39 | 0 |

Synthesis register total is 35547 versus 35506 (+41); this is distinct from the fitted register total after physical optimization. Additional snapshot payload is one 64-bit DDRAM word, with no slot enlargement or new backing RAM allocation.

Worst setup slack **0.687 ns** (F05 0.409 ns); worst hold slack **0.205 ns** (F05 0.246 ns). Reported timing violations: **0**.

New normalized numbered warnings: **0**; new critical warnings: **0**. Distinct warning totals baseline/candidate: 84/84; critical totals 38/38. Quartus reports 100 total warnings. Complete comparison and timing summaries are retained.

20-21. **Final diff and status.** Complete production diff inspected; only F09 state exposure, freeze/restore and validated format transport changed. `git diff --check` passes. No staged files or generated Quartus artifacts.

`git diff --stat`:

```text
 SMS.sv            | 30 ++++++++++++++++++++++++------
 rtl/savestates.sv | 53 +++++++++++++++++++++++++++++++++++++++++++++--------
 2 files changed, 69 insertions(+), 14 deletions(-)
```

`git status --short`:

```text
 M SMS.sv
 M rtl/savestates.sv
?? tests/
```

22. **Recommendation: READY TO COMMIT (F09 only).** Complete Master Tap local state is preserved, transport time is suspended, legacy states normalize safely, and prior-fix regressions pass. F06 remains unresolved; F10/F11 and unrelated logic are unchanged. Nothing staged, committed, pushed or submitted as a PR.
