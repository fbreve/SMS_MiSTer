# Historical SMS_MiSTer baseline: 4d8506a

## 1. Outcome and exact historical identity

**Complete historical implementation finished: synthesis, fit/routing, assembly and static timing analysis all returned success.** Reported setup is **+0.562 ns**, hold **+0.249 ns**, with **0 violating timing-summary groups**. Reported constrained timing passes; inherited coverage/warning limitations below still apply. The generated [SMS.rbf](source/output_files/SMS.rbf) is retained (3,334,264 bytes; SHA256 `f50b6b05fc4d5f02987ede398aed8f4d31171a7b8c1faa77e2a61687809dbb2d`).

The exact requested commit is **4d8506a1458349b2c149e682ffcf3c33fe65ba0a**, “Update framework (#173)”, authored/committed **December 6, 2025 (+08:00)**. The user called this “Original (2024)”; this report uses the verified commit date and does not substitute a different 2024 revision. Its root tree and complete source identities are in [input_manifest.json](input_manifest.json). The subsequent contribution-era differences are broad feature/framework changes; this build does not measure one author's exclusive cost or the isolated cost of savestates.

The original was extracted into **source/** using existing Git objects, with no checkout/worktree/ref/index mutation. All **203 source blobs** (superproject and pinned dependency combined) match exact Git blob contents. The historical `mist/mist-modules` dependency is **9bf1ea25deffe35159cec8762a4f689c1db74a8b**, archived from its existing local object database. No newer RTL, framework, IP or missing-file substitute was introduced. No historical design correction, optimization or second implementation was attempted.

## 2. Isolation and preflight evidence

[preservation_before.json](preservation_before.json) freezes **3,200 existing source/evidence files**, HEAD, branch, all local refs, tracked/index diffs and the raw Git index SHA256. It incorporates the prior current-production and optimization evidence, plus their report/manifests. Current working HEAD remains **1b2a52d87d2659c908d4f9f846416d14bfd85bea**, branch **investigate/cram-memory-inference**. Existing untracked tests/reports/builds were preserved.

[prepare.js](prepare.js) retains the source archive and exact-blob verification procedure. The initial extraction check detected Git archive's Windows line-ending conversion in text files; before any compilation, those extracted text bytes were restored from the exact historical blobs and reverified. This was source preparation, not an RTL fix or a failed implementation. The conversion list is retained in the manifest; both original archives remain. No already-prepared or built directory was overwritten.

An unrelated Quartus GUI compilation was active on entry. The first launcher invocation stopped before starting a stage; the queued launcher then waited for external map/fit/asm/STA processes to finish. [queue.log](queue.log) records the wait. No external process was interrupted. A temporary Z: alias was created only if free, pointing to the existing repository for Quartus 17 path normalization, then removed in the launcher's finally block. All actual output paths are under this task directory.

## 3. Historical project, dependencies and configuration

- Quartus Prime **17.0.2 Build 602 Lite**; executable hashes in [tool_manifest.json](tool_manifest.json). Historical QSF's LAST_QUARTUS_VERSION says Standard Edition; that informational last-editor string is unchanged. Actual compiler/stage logs identify Lite. No incompatible licensed feature required a design alteration.
- Cyclone V **5CSEBA6U23I7**, project/revision **SMS**, top **sys_top**, **SEED 1**, **MISTER_FB=1**. Those are already specified by the historical QSF/sys Tcl.
- Historical **SMS.qsf,files.qip,sys/sys.tcl,sys/sys_analog.tcl,sys/sys.qip,sys/sys_top.sdc**, PLL QIP/generated sources and all nested dependencies are retained unchanged. Version-selected pll_q17 is the original Quartus 17 dependency path. Original core and framework sources are used, including the historical audio_out.v rather than newer audio_out.sv.
- STANDARD FIT; HIGH PERFORMANCE EFFORT; SPEED; final placement ALWAYS; ALM register packing LOW; automatic register packing NORMAL; original physical combinational optimization/duplication/retiming and router duplication settings. No extra area option, packing override, timing exception or IP regeneration was introduced.
- Generated **BUILD_DATE 261025**, matching the retained v19 implementation; current-master primary reference uses 261020 (alternate timing-history F 261014). The original date-generator script is unchanged. Explicit map/fit/asm/STA bypass only automatic timestamp preflow, while an explicit generated build_id.v and CDF use its established format. This avoids today's date changing the build ID during comparison. Neither generated file is a tracked historical source. Hashes are in the input manifest.

The original and current-master root QSF differ only in the LAST_QUARTUS_VERSION string; framework/manifest RTL nevertheless differs materially. [configuration_comparison.json](configuration_comparison.json) records historical→master/v19 differences, including scaler, host I/O, OSD, video framework, audio output and source-list changes. Preserve those differences: replacing old sys/IP with current versions would answer a different question. Device/tool/seed/feature/settings are aligned where possible; **these three revisions are not feature-identical controlled variants**. No full three-way same-date rebuild or multi-seed comparison was authorized or run.

## 4. Complete compilation and retained outputs

[build.ps1](build.ps1) runs map→fit→asm→sta sequentially using fresh databases and original settings; settings writes are disabled on map/fit/asm. Each nonzero exit stops the sequence without repair. [workflow.log](workflow.log) records exact stage boundaries and exit codes. Source isolation and a free short-path mapping prevent touching prior build databases.

| Stage | Started | Finished | Wall minutes | Exit |
| --- | --- | --- | ---: | ---: |
| map | 2026-10-28T20:27:47.0501038-03:00 | 2026-10-28T20:31:01.9855839-03:00 | 3.25 | 0 |
| fit | 2026-10-28T20:31:01.9879729-03:00 | 2026-10-28T20:45:28.7818164-03:00 | 14.45 | 0 |
| asm | 2026-10-28T20:45:28.7835212-03:00 | 2026-10-28T20:45:51.0224546-03:00 | 0.37 | 0 |
| sta | 2026-10-28T20:45:51.0250493-03:00 | 2026-10-28T20:46:01.6323251-03:00 | 0.18 | 0 |

Logs: [map.log](source/map.log), [fit.log](source/fit.log), [asm.log](source/asm.log), [sta.log](source/sta.log). Original reports: [map summary](source/output_files/SMS.map.summary), [full map](source/output_files/SMS.map.rpt), [fit summary](source/output_files/SMS.fit.summary), [full fitter report](source/output_files/SMS.fit.rpt), [assembler](source/output_files/SMS.asm.rpt), [STA summary](source/output_files/SMS.sta.summary), [full STA](source/output_files/SMS.sta.rpt). Full db/,incremental_db/,output_files/,SOF/RBF and stage logs remain. No synthesis estimate is substituted for placed resources.

## 5. Three-version measurements using the same definitions

| Resource | Original (Dec 2025) | Current master | Experimental v19 |
| --- | ---: | ---: | ---: |
| Needed ALMs | 19,962 | 26,465 | 37,117 |
| Placed ALMs | 24,230 | 31,531 | 38,599 |
| Logic ALUTs | 28,740 | 37,056 | 46,835 |
| Routing ALUTs | 10,260 | 13,159 | 18,266 |
| Mapped FFs | 28,655 | 34,857 | 46,327 |
| Fitted registers | 29,541 | 35,709 | 48,880 |
| M10K blocks | 217 | 487 | 488 |
| Memory bits | 1,582,422 | 3,809,858 | 3,818,050 |
| DSP blocks | 38 | 39 | 39 |
| Placed ALM utilization | 57.81% | 75.24% | 92.10% |
| Setup slack | +0.562 ns | +0.508 ns | +0.104 ns |
| Hold slack | +0.249 ns | +0.144 ns | +0.239 ns |
| Violating timing groups | 0 | 0 | 0 |
| Unique critical warnings | 29 | 38 | 38 |


Original: **4d8506a**, newly built here. Current master: **8443a0d19a88aff7a5900011bccf386daf146945**, source-verified retained [HCounter baseline](../savestate_hcounter/baseline/output_files/SMS.fit.rpt). Experimental v19: **1b2a52d87d2659c908d4f9f846416d14bfd85bea**, source-verified retained [G08.FM build](../savestate_g08_fm/quartus_early/output_files/SMS.fit.rpt). Remaining original references and 134/135 normalized source checks are in [current-production audit](../current_savestate_resource_cost/review.md) and [v19 consolidation](../fpga_resource_optimization_summary/review.md). Their source/report hashes were rechecked before/after this task.

Needed ALMs are fitter A−B+C; placed ALMs are A, not the fit-summary needed figure. Utilization is calculated placed/41,910. Logic/routing ALUT are separate fitter counters, not additional independent ALMs. Mapped FF use map-summary total registers; fitted registers use fit-summary totals, including categories excluded by dedicated-FF hierarchy columns. M10K is fitted RAM-block count; memory bits are logical block-memory bits, not allocated block capacity. Setup/hold are minimum reported STA-summary slacks of those types. Violations count negative-slack/TNS summary categories, **not endpoint counts**. Unique critical warnings are deduplicated full message lines across reports/logs, not the compiler's repeated diagnostic emission count. [measure.js](measure.js) uses the same existing extraction function for all three trees; [results.json](results.json) retains full metrics, timing groups, warning text and report hashes.

Original packing: **24,230−4,373+105=19,962**. Master: **31,531−5,381+315=26,465**. v19: **38,599−2,055+573=37,117**. Neither differing packing gaps nor FF counts independently price a feature.

## 6. Growth from the exact original to v19

| Resource | Absolute change | Relative growth versus original |
| --- | ---: | ---: |
| Needed ALMs | +17,155 | +85.94% |
| Placed ALMs | +14,369 | +59.30% |
| Logic ALUT | +18,095 | +62.96% |
| Routing ALUT | +8,006 | +78.03% |
| Mapped FF | +17,672 | +61.67% |
| Fitted registers | +19,339 | +65.46% |
| M10K | +271 | +124.88% |
| Memory bits | +2,235,628 | +141.28% |
| DSP | +1 | +2.63% |

Placed ALMs grow **24,230→38,599**, **+14,369 (59.30%)**. Placed device utilization grows **57.81%→92.10%**, **34.29 percentage points**. Percentage growth in ALM count and percentage-point utilization change are different measures.

These are **whole-design revision differences**. They include guest features, fixes, framework/IP evolution, savestate implementation and fitter remapping. They are not a matched current-production with/without-savestate counterfactual, an isolated savestate controller cost, or a sum of independently removable features. Current-master→v19 placement increases31,531→38,599 (+7,068); that also does not measure enabling all savestates, because master already has savestates and the revisions differ beyond a feature switch. The [current cost audit](../current_savestate_resource_cost/review.md) leaves true incremental current savestate cost unknown for that reason.

An identifiable native-memory addition corroborates why this comparison is broader than savestates: the original maps **1,582,422 logical block-memory bits**, while retained April 2026 checkpoint A maps **3,679,574**, a difference of **2,097,152 bits**. The intervening BIOS source adds an external BIOS RAM with 18 address bits and 8 data bits (**2^18×8=2,097,152**). [feature_context.json](feature_context.json) retains the exact source diff, logical-memory cross-check and current-master BIOS hierarchy row. This is evidence for a specific native capacity addition, not an isolated ALM/M10K price or a matched full-design attribution. No replacement BIOS or modern framework was supplied to the original build.

## 7. Timing, routing, warnings and limitations

| Implementation | Final interconnect usage, verbatim total/H/V rows |
| --- | --- |
| Original | Average interconnect usage (total/H/V): 17.8% / 18.4% / 15.9%; Peak interconnect usage (total/H/V): 33.8% / 33.4% / 37.7% |
| Current master | Average interconnect usage (total/H/V): 28.9% / 29.0% / 28.7%; Peak interconnect usage (total/H/V): 53.7% / 54.6% / 56.4% |
| v19 | Average interconnect usage (total/H/V): 49.7% / 49.5% / 50.6%; Peak interconnect usage (total/H/V): 74.0% / 75.5% / 76.9% |

These are final fitter average/peak rows, not preliminary router congestion estimates. Routing ALUTs and global interconnect cannot be partitioned per feature from this table. No claimed local congestion cause or unrelated HDMI/CPU timing attribution is inferred from the aggregate comparison.

Original critical-warning numeric IDs: **18010, 18061**. Master: **18010, 18061**. v19: **18010, 18061**. Complete message text/type ledgers and every reported setup/hold/recovery/removal/pulse-width group are in results.json and the original reports. Differences across historical features/constraints are not automatically new regressions in a controlled experiment. Tool completion is separate from timing qualification.

Original unconstrained-information categories: **setup, hold**; master: **setup, hold**; v19: **setup, hold**. Positive constrained slack does not certify unconstrained paths, all operating corners or hardware behavior. The original project retains TIMEQUEST_MULTICORNER_ANALYSIS OFF; constraints were not strengthened or relaxed for this measurement. This is one historical seed 1 implementation and two retained seed 1 references, not statistical evidence or a three-revision multi-seed study. No functional simulation or hardware/game qualification was requested or claimed for this unchanged historical build.

## 8. Final integrity and disposition

[verification.json](verification.json) verifies every historical/submodule source blob and both generated inputs against the frozen manifest, all 3,200 preserved existing hashes, branch/HEAD/all refs, tracked/index diffs and raw index bytes. It also hashes the new build/report/database artifacts. No historical source/IP/constraint changed during compilation and no existing evidence was overwritten. Source archives and preparation/build/measurement scripts allow reproduction.

Final git diff --stat:

```text
(empty)
```

Final git status --short:

```text
?? tests/
```

The tests tree was already untracked; ordinary Git diff omits this new isolated experiment directory. All new outputs are under tests/historical_baseline_4d8506a/. No branch/ref/index change, production edit, merge/rebase/reset/clean, commit/push or PR. **Historical baseline measurement complete; stop and await review.**
