# SMS_MiSTer v19 FPGA resource optimization consolidation

## 1. Executive summary

**STOP: the retained evidence does not support further immediate optimization implementation.** Production remains committed v19, including the CPU/NMI, sprite/background/restart, PSG/mixer, SDRAM, OPLL, complete Sega SRAM and first-FM-sample corrections. No rejected area experiment is incorporated into production. This report consolidates existing evidence; it introduces no candidate or new functional/physical result.

The investigations identified concentrated costs, especially the controller's two sprite snapshot rings, but did not establish a deployable whole-design area optimization. The common-mux rewrite and format consolidation passed their functional gates but increased placed ALMs. Packed sequential sprite RAM removed thousands of FFs but failed routing or setup. CRAM RAM inference improved its own hierarchy substantially but increased whole-design placement and block use. The CPU output alias passed its consuming-edge qualification but failed seed-1 timing; its separately authorized, genuinely paired seed-2 test passed timing but failed routing-resource gates and saved only four placed ALMs. Those results remain negative evidence, rather than a menu of pending production changes.

Read-only studies then examined alternatives and native logic outside the controller. Local sprite RAM needs a proved reset/interruption authority contract; safe private atomic variants retain nearly all staging storage without a demonstrated net area mechanism. The final mapped-netlist investigation resolved the leading native selector question: the targeted X/d3 normal-write expressions are **already shared across all 64 slots of each VDP**. It found no material duplicated normal-data network to remove. Large allocations, repeated source syntax and routed FF clones are not evidence of avoidable gates.

This is a decision about the evidence currently available, **not a proof of globally optimal RTL**. A genuinely different mechanism with a complete correctness contract and matched physical qualification could reopen the question. No speculative PoC, seed search or settings change is recommended now.

### 1.1 Documentation scope and branch boundary

> [!NOTE]
> This consolidation report and its companion structural audits belong exclusively to branch doc/resource-optimization-consolidation of fork breve/SMS_MiSTer. This documentation branch is isolated and will not be integrated into master or submitted upstream to the official MiSTer repository (MiSTer-devel/SMS_MiSTer).

### 1.2 Recent optimization outcomes and conclusion

This resource optimization roadmap round for the SMS_MiSTer core is formally concluded. The verified production baseline remains established on master with the proven integration of PhaseMemory (PR #224, commit b09fdf41221c9e3e77eee87264a125ba43021fe), preserving all prior functional and architectural fixes.

Recent physical experiments and structural static audits are categorized as follows:
1. **Approved and merged in master:**
   - **PhaseMemory (OPLL)** via automatic RAM inference (AUTO): confirmed across two independent paired seeds with measured savings of **207 to 253 Placed ALMs** and **310 to 346 Dedicated Registers**, consuming one additional M10K block while preserving positive setup slack (+0.472 ns in Seed 1; +0.334 ns in Seed 2). Integrated via PR #224 (commit b09fdf4).
2. **Implementations rejected by physical failure (Timing / Retiming / Routing):**
   - **FeedbackMemory (OPLL):** **NO-GO**. Automatic inference was functionally equivalent in simulation, but resulted in **+5 whole-design Placed ALMs** and a **218 ps setup slack regression** (+0.508 ns down to +0.290 ns, a 43% loss of margin), with a reduction of retimed registers in the HDMI/scaler pipeline from 708 to 697. Rejected on Seed 1.
   - **RegisterMemory (OPLL):** **NO-GO**. Automatic inference achieved nominal savings of 275-288 Placed ALMs and 346-369 FFs, but caused **100% loss of global physical retiming across the design** in the tested configurations (reducing retimed registers in the core and scaler to zero). This severely degraded setup slack to **+0.146 ns in Seed 1 and +0.019 ns in Seed 2** (bordering on critical timing failure). Diagnostic trials with localized register packing directives partially recovered setup slack, but physical retiming was not recovered under the tested configurations.
   - **CRAM RAM Inference:** **NO-GO / Reverted**. Dual-port RAM inference reduced local hierarchy counts, but caused **+121 whole-design Placed ALMs**, **+997 routing ALUTs**, and consumed 4 M10K blocks due to 4 parallel replicas required for concurrent renderer color access.
   - **CPU Restore Alias:** **NO-GO**. Bus sharing passed 40 functional qualification cases, but **failed timing on Seed 1 (-0.714 ns setup slack)**; the paired Seed 2 confirmation passed setup timing but **failed routing limits (+105 routing ALUTs, increased peak interconnect)**, saving only 4 Placed ALMs.
   - **PSG Simplification (jt89):** **NO-GO**. Attempting to discard generator phase history (Candidate C) reduced ALMs, but resulted in a **critical setup timing failure on Seed 2 (-0.012 ns setup slack, -0.069 ns TNS)**.
   - **4-PAK Shared Decode and Shared Word Buffer:** **NO-GO**. Both attempts to factor combinational decoding or word buffering resulted in increased Needed and Placed ALMs across both seeds due to routing and multiplexer dispersion.
3. **Audited modules without a promising opportunity identified (Static Structural Audits):**
   - Structural audits of dp_sprites.vhd (cache write logic and pixel priority tree), dp_background.vhd, T80 (Z80 CPU microcode and datapath), cheatcodes.sv (Game Genie), and io.vhd identified no promising resource-reduction opportunities that preserve functional behavior and bus timing. Quartus synthesis already performs multiplexer restructuring and common-factor sharing. These findings reflect the absence of promising opportunities identified in the current structures, **not a mathematical proof of absolute impossibility** for future optimization under a substantially different architecture.

## 2. Verified baseline and reproducibility

Current HEAD is `1b2a52d87d2659c908d4f9f846416d14bfd85bea`, branch `investigate/cram-memory-inference`. The writer is **v19 / `0x484313`**, a 96 KiB container. Authoritative retained implementation: [G08.FM production build](../savestate_g08_fm/quartus_early/), particularly [fit summary](../savestate_g08_fm/quartus_early/output_files/SMS.fit.summary), [full fit report](../savestate_g08_fm/quartus_early/output_files/SMS.fit.rpt), [map summary](../savestate_g08_fm/quartus_early/output_files/SMS.map.summary) and [STA summary](../savestate_g08_fm/quartus_early/output_files/SMS.sta.summary). The [original source verification](../structural_resource_audit/source_verification.json) and [input manifest](../savestate_g08_fm/build_early_inputs.json) bind that build to the actual committed v19 sources.

| Measured production seed-1 quantity | Value |
| --- | ---: |
| Needed ALMs | 37,117 |
| Placed ALMs / device capacity | 38,599 / 41,910 |
| Mapped / fitted FF | 46,327 / 48,880 |
| Logic / routing ALUT | 46,835 / 18,266 |
| M10K / capacity | 488 / 553 |
| Logical block-memory bits | 3,818,050 |
| DSP | 39 |
| Worst reported setup / hold | +0.104 / +0.239 ns |
| Reported violating timing-summary groups | 0 |
| Final interconnect average total / H / V | 49.7 / 49.5 / 50.6% |
| Final interconnect peak total / H / V | 74.0 / 75.5 / 76.9% |

These values were re-extracted from the original reports during this documentation task, using the existing read-only measurement function. See [before verification](preservation_before.json) and [verification code](verify.js). The final interconnect rows are distinct from the **preliminary** router estimate of 40% average / 66% peak quoted by some earlier audits. Both exist; they refer to different implementation stages. Neither is a local congestion heatmap.

Configuration: Quartus Prime Lite **17.0.2 Build 602**, Cyclone V **5CSEBA6U23I7**, SMS revision / `sys_top`, seed 1, fixed **BUILD_DATE 261025**, **MISTER_FB=1**. STANDARD FIT, HIGH PERFORMANCE EFFORT, SPEED, final placement ALWAYS, ALM register packing LOW, automatic packing NORMAL; physical combinational optimization, duplication/retiming and router duplication enabled. QSF/SDC/QIP/IP are unchanged. This is the established performance configuration, not an area-mode trial. See [structural baseline](../structural_resource_audit/review.md) and [effective settings/tables](../structural_resource_audit/tables.json).

Integrity checks cover **204 tracked file hashes**, **137 retained build input hashes**, and **135 normalized HEAD/input matches**. The other two input-manifest entries are unused `.bak`/`.orig` files without corresponding HEAD blobs. Raw retained hashes and CRLF/LF-normalized source comparisons serve different purposes; normalization was not used to modify files. The old build manifest's HEAD label predates the v19 commit: actual input contents, not that stale label, establish provenance. Current `rtl/savestates.sv` SHA256 is `e8de50db09447138fc661205fb9edd178d45e691819a056bad87631ef3d76557`.

The preflight also revalidated all **1,001 entries** in the prior connectivity preservation ledger, including the authoritative databases/reports, and added existing consolidation prerequisites and their immediate machine evidence. In total **1,584 distinct files** are frozen for this task's before/after comparison. The ledger is an explicit hash set, not a claim that every byte of every historical build was independently inventoried anew. No previous evidence generator was rerun. No Quartus executable, simulator or new implementation was invoked.

Coverage limits remain: inherited unconstrained setup/hold categories, **38 unique inherited critical-warning messages**, and configured STA/query corner limits. Positive reported slack is not fully constrained hardware signoff. Timing-history documentation requested by an earlier audit was absent; retained original STA and path reports supplied measured timing instead. See [original warning ledger](../savestate_g08_fm/early_results.json). None of those limitations is silently repaired here.

## 3. Historical progression: production versus experiments

The production order below follows actual first-parent commits and source-bound reports, not directory names. [Resource-growth history](../savestate_resource_growth/review.md), [its machine ledger](../savestate_resource_growth/measurements.json), and [format history](../savestate_format_consolidation/history.json) retain the earlier transition details and dates. Historical reports saying “READY TO COMMIT” describe their writing-time state; ancestry of current HEAD establishes subsequent retention.

| Production checkpoint | Commit | Needed / placed ALMs | Mapped / fitted FF | M10K | Setup / hold ns |
| --- | --- | ---: | ---: | ---: | ---: |
| Untagged pre-fix | `8443a0d` | 26,465 / 31,531 | 34,857 / 35,709 | 487 | +.508 / +.144 |
| G01, v13 | `8ffd15e` | 27,368 / 32,684 | 35,896 / 36,831 | 487 | +.483 / +.213 |
| G06/G10, v14 | `5858318` | 35,419 / 38,142 | 45,499 / 48,002 | 487 | +.384 / +.226 |
| G05, v15 | `f205b05` | 35,945 / 38,718 | 45,808 / 48,385 | 487 | +.211 / +.232 |
| G08.release, v16 | `08cf142` | 36,068 / 38,816 | 45,808 / 48,258 | 487 | +.141 / +.243 |
| G12, still v16 | `cb2e861` | 36,300 / 39,001 | 45,808 / 48,428 | 487 | +.465 / +.198 |
| F01 OPLL, v17 | `7fcd5e1` | 37,175 / 38,598 | 46,289 / 48,948 | 488 | +.105 / +.206 |
| F06 complete SRAM, v18 | `854761c3` | 37,131 / 38,450 | 46,290 / 48,899 | 488 | +.366 / +.234 |
| G08.FM retained sample, v19 | `1b2a52d8` | 37,117 / 38,599 | 46,327 / 48,880 | 488 | +.104 / +.239 |

Sources for the later endpoints: [F01 implementation](../savestate_f01_opll_fix/review.md), [F06 implementation](../savestate_f06_sega_sram_fix/review.md), [G08.FM closure](../savestate_g08_fm/review.md). Earlier intervening fixes are HCounter, GG I/O, MD6, EEPROM, SC RAM, MasterTap, paddle, lightgun, System E Pause, mapper history, Evolution selector/pending operation and normalized CPU NMI. They remain in production; their individual resource transitions are in the growth ledger. F12 and G12 change ordering without a tag increment. This table selects major resource checkpoints rather than hiding the earlier fixes.

G06/G10's controlled transition added **8,051 needed / 5,458 placed ALMs**, **9,603 mapped / 11,171 fitted FF**, **5,818 logic / 5,399 routing ALUT**, with no new M10K. That includes storage, receivers and global implementation changes. G05 later added **526 needed / 576 placed**, **309 mapped / 383 fitted FF**, **909 logic / 204 routing ALUT**. Neither transition is a pure price for one RTL construct. Historical pairwise build dates were matched within controls, but were not identical across the entire chronology; the growth report explicitly documents that distinction.

The investigative sequence follows report dependencies and their verified baselines:

1. At post-G12 **v16**, the resource-growth audit identified G06/G10 as the dominant expansion and recommended capacity work before F01. The common-mux/mask trials followed and were rejected.
2. F01 architecture selection and implementation retained **localized sequential access** at **v17**, using one M10K scratch. This production success does not establish that the sprite receiver can use the same architecture cheaply.
3. At **v17**, packed sequential sprite RAM/scatter was tested and rejected; format consolidation explicitly reads that rejected study and was rejected in turn. These are historical v17 experiments, not current v19 fits.
4. Production then gained **F06 v18**, streaming the complete physical SRAM span through existing transport, and **G08.FM v19**, retaining the first stereo-half sample without redesigning OPLL.
5. The **v19 structural audit** identified measured concentrations and suggested bounded CRAM investigation. The storage study stopped at feasibility. CRAM was experimentally converted and reverted after its physical result. The internal controller audit then selected only a CPU output-alias pilot, subject to proof.
6. That **v19 CPU alias** passed functional qualification but failed seed-1 timing. A read-only diagnosis recommended one paired seed-2 experiment; that later pair was authorized, run, and rejected on its own physical gates. The original report's “no second seed” is correct for its earlier scope, not the final historical outcome.
7. Subsequent sprite architecture feasibility and the non-controller audit selected no PoC. Readable-export selector diagnosis was **INCONCLUSIVE**; the subsequent bounded atom-connectivity query resolved the targeted normal-data factoring question as **NO-GO / already shared**. The optional metadata assertion limits stronger claims, not that positive connectivity evidence.

Older recommendations are therefore historical decision points, not active requests to repeat experiments. This report's final decision supersedes their pending-investigation suggestions without altering those reports.

## 4. Experimental results and comparison rules

All deltas below are **candidate minus its stated baseline**. FF and ALUT columns show **mapped/fitted FF** and **fitted logic/routing ALUT**, respectively. A negative number is a count reduction, not automatically a qualified saving. “Not measured” is different from zero. Full source manifests, functional logs and original reports are linked by row.

| Experiment / baseline and seed | Functional result | Δ needed / placed ALM | Δ mapped / fitted FF | Δ logic / routing ALUT | Δ M10K | Candidate setup / hold ns | Route / decision |
| --- | --- | ---: | ---: | ---: | ---: | ---: | --- |
| [Controller common-mux extraction](../savestate_sprite_resource_optimization/review.md), v16 `cb2e861`, paired seed 1 | Controller miter PASS; 24/24 canonical native cases, 82 specified current LOADs | +106 / +47 | 0 / −66 | +14 / −77 | 0 | +.360 / +.196 | Completed; area objective failed; rejected |
| [Parallel register masks](../savestate_sprite_resource_optimization/review.md), same v16, standalone synthesis only | Not separately board-qualified | Not measured | Standalone FF unchanged; board not measured | **Standalone** ALUT +9,532; board not measured | Board not measured | Not measured | No full fit; rejected at micro-synthesis |
| [Packed 300×32 sprite RAM/scatter](../savestate_g06_sequential_architecture/review.md), v17 `7fcd5e1`, seed-1 control | Finite functional gate PASS | −1,838 / −1,615 **provisional** | −9,397 / −12,390 **fit provisional** | +5,402 / −18,174 **route incomplete** | +2 | Not measured / not measured | Routing FAILED; asm/STA not run; rejected |
| Same packed candidate, seed 2 only | Same source-bound qualification | **Not comparable:** no seed-2 baseline | Mapped candidate 36,892; fitted 39,626 | Candidate 52,448 / 9,075 | Candidate 490 | −.100 / +.244 | Route completed, setup failed; unpaired historical sensitivity result |
| [Development-format consolidation](../savestate_format_consolidation/review.md), v17 `7fcd5e1`, paired seed 1 | Format/native/legacy gates PASS | −10 / +27 | −8 / −102 | −171 / +162 | 0 | +.365 / +.233 | Completed; no placed recovery; rejected |
| Same format candidate, seed 2 only | Same variant | **Not comparable:** no seed-2 baseline | Candidate 46,281 / 48,913 | See original results; no paired delta | Candidate 488 | −.013 / +.207 | Completed; setup failed; unpaired |
| [CRAM inference](../cram_memory_inference/review.md), v19 `1b2a52d8`, paired seed 1 | Native/transport/image/compatibility gates PASS | −1,055 / +121 | −790 / −764 | −1,493 / +997 | +4 | +.067 / +.231 | Completed; physical area/block objective failed; reverted |
| [CPU output alias](../cpu_restore_output_alias/review.md), v19 `1b2a52d8`, paired seed 1 | 40-case consuming-edge qualification PASS | −112 / −142 | −230 / −136 | +112 / +44 | 0 | **−.714** / +.241 | Completed; setup/routing gates failed; rejected |
| [Same CPU alias](../cpu_restore_alias_seed2_pair/review.md), v19, **paired seed 2** | Exact retained 40-case source qualification applies; no weakened/rerun tests | −107 / −4 | −230 / −117 | +114 / +105 | 0 | +.524 / +.238 | Completed; routing gates failed; rejected |
| [PhaseMemory AUTO RAM inference](../phase_memory_auto/review.md), `8443a0d`, paired seeds 1 & 2 | Functional / savestate coverage PASS | −207 a −253 placed | −310 a −346 fitted FF | logic −214..−268 / route −10..+24 | +1 | Seed1 +.472 / Seed2 +.334 | Completed; timing/retiming preserved; **APPROVED & MERGED (PR #224, commit `ab09fdf4`)** |
| [FeedbackMemory AUTO RAM inference](../feedback_memory_auto/review.md), `8443a0d`, seed 1 | Functional / savestate coverage PASS | −19 / **+5 placed** | −100 / −100 | +26 / −37 | +1 | +.290 / +.245 (slack fell 218 ps) | Completed; placed area increased, setup margin degraded; **REJECTED (NO-GO)** |
| [RegisterMemory AUTO RAM inference](../register_memory_auto/review.md), `8443a0d`, paired seeds 1 & 2 | Functional / savestate coverage PASS | −311 a −319 / −275 a −288 placed | −369 / −346 a −369 fitted FF | logic −319..−329 / route +1..+42 | +1 | Seed1 +.146 / Seed2 +.019 | Completed; **100% physical retiming loss globally**, timing margin degraded; **REJECTED (NO-GO)** |
| [PSG Simplificação Candidato C](../psg_c_physical/review.md), `8443a0d`, paired seeds 1 & 2 | Functional controls PASS; generator replay dropped | −47 a −50 / −47 a −52 placed | −34 / −34 fitted FF | logic −61..−67 / route +12..+20 | 0 | Seed1 +.171 / **Seed2 −.012 (FAILED)** | Completed; **setup slack failure on seed 2 (−0.012 ns)**; **REJECTED (NO-GO)** |
| [Shared Standard 4-PAK Decode](../shared_standard_4pak_decode/review.md), `8443a0d`, paired seeds 1 & 2 | Bus decoding functional PASS | +2 a +7 / +4 a +18 placed | 0 / −2 a +1 | logic +2..+7 / route +5..+16 | 0 | Seed1 +.422 / Seed2 +.315 | Completed; placed area increased in both seeds; **REJECTED (NO-GO)** |
| [Shared Savestate Word Buffer](../shared_savestate_word_buffer/_archive/package_check/physical/review.md), `ab09fdf4`, paired seeds 1 & 2 | Buffer functional PASS | +3 a +6 / +5 a +12 placed | 0 / 0 | logic +3..+6 / route +4..+14 | 0 | Seed1 +.441 / Seed2 +.320 | Completed; placed and needed area increased in both seeds; **REJECTED (NO-GO)** |

Exact machine evidence: [common-mux board results](../savestate_sprite_resource_optimization/build_results.json), [format results](../savestate_format_consolidation/experiment_results.json), [format seed-2 results](../savestate_format_consolidation/confirmation_results.json), [CPU seed-1 results](../cpu_restore_output_alias/candidate1_results.json), and [CPU seed-2 pair](../cpu_restore_alias_seed2_pair/paired_results.json). Other rows' reports link their original fit/map/STA and input manifests. **No row supplies an exact forecast for an unbuilt architecture.**

For the packed-RAM seed-2 candidate, the often-quoted **586 fewer placed / 1,961 fewer needed ALMs** is arithmetic against the **v17 seed-1** baseline, not a matched-seed optimization result. The completed seed-2 values are 38,012 placed / 35,214 needed; the earlier baseline is 38,598 / 37,175. The incomplete seed-1 routing ALUT count of eight is not an extraordinary routing improvement. The format seed-2 candidate's apparent 74-placed reduction is likewise against seed 1 and is not attributable savings.

Read-only studies—structural, internal controller, storage feasibility, native audit and connectivity—have **no new functional or physical candidate result**. Reusing their verified baseline is not a zero-delta candidate experiment. Production feature transitions in section 3 are retained correctness work, not rows in this rejected-optimization table.

## 5. Controller costs: measured allocation versus state

The [internal cost audit](../savestates_internal_cost_audit/review.md) and its [complete inventory](../savestates_internal_cost_audit/inventory.json) distinguish declarations, fitted names and hierarchy allocations. Controller **exclusive** cost is **10,647.6 placed / 10,497.5 needed ALMs, 6,966 logic ALUT and 14,773 dedicated FF**. Its OPLL scratch child adds **156.9 placed / 150.7 needed, 224 ALUT, 167 dedicated FF and one M10K**. The complete controller subtree is **10,804.5 placed, 7,190 ALUT, 14,940 dedicated FF**. Needed subtotals have displayed-rounding differences; none is an isolated removable cost.

| Disjoint own fitted-FF category from the audit | FF |
| --- | ---: |
| Two sprite rings | 9,600 |
| CRAM snapshots | 768 |
| G05 background snapshots | 278 |
| CPU/NMI/restart snapshots | 236 |
| Other snapshots | 1,369 |
| Registered restore-data outputs | 1,499 |
| DMA/DDR data/control staging | 633 |
| Presence/handshake/selectors/CRAM write controls | 117 |
| Encoded implementation FSM | 108 |
| Timers | 92 |
| Operation identity | 73 |
| **Total own dedicated FF** | **14,773** |

The declared FSM width does not predict implemented FF count; synthesis creates the reported state implementation. Likewise physical watchdog duplicates do not add historical state. RAM timing nodes are not dedicated FFs. Source-width totals, timing-register exports, synthesis hierarchy and whole-device summary totals are intentionally separate measures.

The rings account for approximately **65% of controller-own FF** (calculated 9,600/14,773), not 65% of its ALMs. Each owner has **4,778 meaningful bits**: 64 slots ×74 bits =4,736, plus 42 fixed bits. A slot has enable1, X8, four cached bytes32, four shift bytes32 and wideclock1. Fixed history comprises address14, flags8, color4, collide1, overflow1 and collision delay14. Each 4,800-bit physical ring adds 22 transport-padding positions. Combined: **9,556 meaningful +44 padding =9,600 positions**. Padding positions carry meaningful values during the 75×64-bit rotation, so they are not simply constant FFs available for deletion.

These are the **same banks for SAVE capture/serialization and incoming LOAD staging**, not separate SAVE-only and LOAD-only copies. Live sprite state resides in VDP evaluator/shifter hierarchies outside the controller and must not be counted again inside this allocation. Wide intermodule restore buses are wiring, not additional register banks. G10 phase2 plus consumed-tick1 are separate history, not a third sprite record. [Storage inventory and lifetimes](../g06_g10_storage_optimization/review.md) give the detailed mapping.

The 1,499 output FF class is a possible lifetime-analysis envelope, not a proved removable bank. Only the 230-bit CPU subset was proven and measured; its negative physical outcome does not license other output aliases. G05's two 139-bit histories, Evolution/EEPROM staging and validation/transport state retain distinct consumers and lifetimes. OPLL uses localized sequential capture/apply plus its M10K rather than another broad parallel shadow bank. Full validation-before-apply and accepted-DDR stall latches are functional obligations, not parser “overhead” safe to discard.

Historical cross-check: G06/G10 controller map FF rose 4,838→14,439 and ALUT 5,390→6,003, while fitted exclusive placement rose 5,387.5→10,190.1. Other receiver/global allocations also moved. These corroborate storage concentration without partitioning the entire transition into independently priced snapshot, mux and fanout cones. No disjoint per-construct placed-ALM charge is available.

## 6. Rejected sprite storage and transport architectures

The [v17 sequential experiment](../savestate_g06_sequential_architecture/review.md), [v19 storage investigation](../g06_g10_storage_optimization/review.md) and [later feasibility study](../sprite_restore_architecture_feasibility/review.md) concern different mechanisms. The latter two contain architectural reasoning, not new fits of the former. Their shared constraint is **restore authority**: while an incoming P is incomplete or invalid, the pre-operation guest Q must retain the existing observable/error/reset behavior. A frozen guest is not permission to overwrite Q piecemeal.

| Architecture | Actual mechanism and replacement cost | Rejection / limitation |
| --- | --- | --- |
| Controller common-mux extraction | Hoists capture/rotate/insert expression; retains full FF rings and wide-control network | Standalone controller ALUT 6,161→6,123, but paired board placed **+47**. Board fitted controller logic also rose after implementation. Mapped simplification did not survive as useful placement recovery. Packing gap actually improved by 59; “packing became worse” alone is not the explanation. |
| Parallel masks | Expresses bank updates with masks instead of original conditional graph | Standalone controller ALUT **6,161→15,693**, FF unchanged at 14,819. Rejected before expensive full-board trial; no claimed routed result. |
| Packed sequential RAM / global scatter | Replaces rings with 300×32 scratch, two M10Ks, local word decode/gather/scatter and handshakes | Removes 9,397 mapped FF net, but adds about 5,402 fitted logic ALUT in seed 1; routing fails. Seed 2 routes but setup fails. Narrow storage did not remove receiver/distribution cost. Exact causal split among scatter locality, hold repair and global fitting is unproved. |
| Direct frozen-live SAVE | Reads stable live Q instead of capturing a separate SAVE copy | Frozen-live stability is supported, but rings also stage LOAD P. Removing SAVE capture assignments alone leaves inbound staging and cannot remove the banks. |
| One shared ring or OPLL unused tail | Reuses capacity across owners or borrows unused FM scratch rows | Original simultaneous restore needs independent P1/P2. Unused OPLL tail is **152×32=4,864 bits**, enough for one record only; arbitration/receiver still missing. Rereading DDR after installing one owner adds a new mixed-P/Q timeout interval. |
| Destructive live scan | Shifts live native state as transport storage | SAVE-only observers, interruption/reset prefixes, inverse scan/rollback and first-native authority are unproved. Freeze alone does not isolate every observer or guarantee full recovery before release. No candidate tested. |
| Local whole-slot private RAM, then narrow live install | Eight groups of eight slots per owner; memory terminates near receiver, avoiding old global field scatter | Distinct mechanism, but direct-live partial installation lacks reset/abort authority. Runtime reset drops controller freeze; children have no equivalent rollback guarantee before native enables resume. No PoC selected. |
| Local RAM plus private parallel FF commit bank | Stages P privately, then commits atomically at original edge | Addresses the partial-live authority hazard, but recreates **9,556 private FF** plus RAM/bridge. Explicit example totals **9,974 private/bridge data FF**, **374 more** than old rings before control/duplication. Simpler muxes/locality could help, but no material net budget is demonstrated. |
| Load-only local serial FF shadows plus direct-live SAVE | Private 74-bit per-slot chains; narrow input; original atomic live commit; no extra RAM | Retains **9,556 shadow FF**, directly removes only **44 padding positions** before overhead. A full two-bit SAVE selector has roughly **9,470 abstract two-input mux positions**, not ALUTs. New selector/pipeline/control cost has no supported net material gain. Unselected, not physically disproved. |
| Native cache/shifter RAM scheduler | Replaces live all-slot state with addressed RAM and a new access schedule | All-slot same-X reload and first-native edges require concurrent state. No complete cycle/port/bypass schedule proves equivalence. Nominal idle host clocks are not a schedule proof. |

Memory arithmetic in the feasibility study is explicitly **hypothetical**, not fitted utilization. Local 8×80 storage needs two width-40 M10Ks per group: **32 additional blocks**, total 520 with 33 free. A 32-bit fallback uses **48**, total 536 with 17 free. An MLAB version uses **64 logical 20×32 units**, consuming sites/ALMs rather than free dedicated blocks. Backing up Q in extra rows of those blocks need not double block count, but does not solve restore authority or recovery bandwidth. Conversely a naive one-edge full-width two-owner RAM restore takes at least **2×ceil(4,778/40)=240 width slices**, exceeding the 65 free M10Ks. Port width and simultaneous delivery, not just total stored bits, dominate these estimates.

The packed experiment's functional evidence is substantial but finite: **320,016 full-64-slot component comparisons**, **16 byte-identical 98,304-byte images**, **48 LOADs per implementation**, and **2,416 format cases** (2,016 reject /400 accept), plus retained sprite/background/restart witnesses. It was not exhaustive reset-prefix proof of every later architecture. Ready-DDR incremental latency was **1,348 SAVE clocks**, **1,053 single-owner /1,353 dual-owner LOAD clocks**; those are fixture-specific serialization costs, not bounds on stalled wall time. No physically invalid result becomes acceptable because added pause time is small.

A new architecture must preserve accepted-edge capture ordering: CPU boundary state, post-accepted-tick VDP history, PSG drain/pending tick and OPLL scan/apply are not interchangeable sampling points. Atomic validation before LOAD, private staging lifetime through late metadata, full-width consuming-edge restore, independent System E records and deterministic release remain coupled obligations. Narrowing a bus or changing RAM width alone does not answer them.

## 7. Other material experiments and retained architecture choices

**CRAM inference — functional success, physical rejection.** The [CRAM report](../cram_memory_inference/review.md) establishes that the original two 32×12 palettes are FF/read-mux structures because parallel snapshot access obstructs ordinary RAM inference. The experiment removes that parallel access using a frozen scanner, preserving renderer latency, old-data collisions, initialization, CPU/GG writes and restore priority. Public64 System E LOAD requires scanning too because its missing secondary palette falls back to live ARM state; SAVE-only scanning is insufficient.

Qualification included **16 native cases**, **16 paired full images /12,288 words each**, **2,098 malformed rejects /420 accepts**, compatibility and long SAVE/LOAD suffixes. The two palette hierarchies fell **731.1→18.4 placed ALMs (−712.7)** and **803→0 FF** locally. Yet whole-chip placement rose **121**, route-through ALUT **997**, and blocks **four**: two read needs caused replicated memory implementations rather than the hoped-for two-block total. Unchanged scaler-own placement moved **+427.4**, demonstrating nonlocal physical effects, not newly added scaler functionality. Packing changed from `38599−2055+573=37117` to `38720−3237+579=36062`. The trial was reverted exactly. An explicit primitive/port study remains **unattempted**, not an authorized retry or a promised fix.

**CPU restore-output alias — proved narrow semantic opportunity, no qualified physical win.** The [consumer proof](../cpu_restore_output_alias/consumer_proof.md) follows SMS→system→T80s→T80/T80_Reg. DIR/RegDIR stateful consumption is under DIRSet. At controller restore edge R, baseline NBA copies snapshot to output and raises the strobe; consumption is R+1. The retained snapshot has the same value and lifetime at that edge. The alias may change unused bus values during SAVE or partial parsing; consuming data, first native execution, controls and DDR transactions remain compared. This is not a claim that every output bank can alias.

The isolated alias SHA256 is `0d6a000152980f2bd64bce3b847c82dd5a5acfa9aa1a001527ada929189e774f`. Its **40-case qualification** covers **91,413,628 host clocks, 209 consuming edges, 495,599 accepted DDR writes and 1,591,538 reads**, all eight NMI triplets, real CPU restart/prefix/EI/HALT/private preparation, repeated LOAD from different Q, legacy readers, late rejection, Pause, dual VDP and exact full-image equality. Full image SHA256 is retained in the [functional gate](../cpu_restore_output_alias/functional_gate.json). These are source-bound finite tests and consumer reasoning, not post-route simulation or exhaustive formal verification.

Seed 1 removed the intended **230** output FF, retaining **230** snapshot FF. Controller-own fitted FF fell **234** (output230 plus four fewer watchdog clones); elsewhere **98** fitted allocations appeared, reconciling the whole **−136**. Controller logic ALUT rose **170**, offset by **−58** elsewhere to global **+112**. [Timing diagnosis](../cpu_restore_alias_timing_diagnosis/review.md) locates those exclusive changes; it cannot assign the global **+44 routing ALUT** or **+35 unavailable ALMs** to one cause. The failure is real even though the changed data cone has ample timing margin.

The later [paired seed-2 test](../cpu_restore_alias_seed2_pair/review.md) uses fresh original and exact retained alias builds, same host/configuration, seed 2 on both. Baseline2 **38,463 placed /+.401 setup /+.235 hold** versus candidate2 **38,459 /+.524 /+.238**. Both have zero reported violations and unchanged **488 M10Ks** and **38 critical warnings**, but routing ALUT **18,254→18,359**, final total peak **72.8→72.9%**, horizontal peak **70.7→72.8%**. The original no-growth routing gates fail. Average total decreases **49.4→48.8%**; a lower average does not cancel peak/routing growth. Seed-1 failure is not overturned. The candidate remains isolated rejected evidence, never production.

**Format consolidation — compatibility syntax was not a material area bank.** The [v17 report](../savestate_format_consolidation/review.md) tested dropping numbered development tags while retaining public64/public96 and current payload. This is a historical isolated compatibility-changing variant, **not current production policy**. Qualification includes **28 component cases**, **2,416 format cases** (2,032 reject /384 accept), legacy golden-output comparison and raw PSG sweeps. Current/public shared restore paths and state storage mostly remain. Only **eight mapped FF** disappear; paired placement rises **27** despite **171 fewer fitted logic ALUT**, with **162 more routing ALUT**. The unpaired seed-2 candidate fails setup. No accepted-format support was removed from production; further compatibility removal requires a separate policy decision and cannot be presented as semantics-preserving optimization.

**F01 sequential OPLL is retained, not a rejected RAM experiment.** The [architecture study](../savestate_f01_opll_architecture/review.md) and [implementation](../savestate_f01_opll_fix/review.md) select localized sequential 32-bit access using one **256×32 M10K**, **104 rows /3,328 encoded bits**, **1,896 meaningful bits**. Pure derived caches are refilled under stationary guest state; pending/history fields are saved. LOAD validates first, applies local rows and refills before original global restart. The v16→v17 build changes **+875 needed, −403 placed, +481 mapped FF, +520 fitted FF, +one M10K**; the negative placed transition is whole-design remapping, not a negative isolated cost for FM completeness. No unsupported assumption that this transfers profitably to sprites follows.

F06 then retains complete **32 KiB** physical SRAM using existing byte-pack/DDR streaming, with no new SRAM snapshot bank; same-ROM operation is its explicit contract. G08.FM v19 adds the **16-bit historical last output sample** at the existing release edge, preserving exact first L/R behavior after OPLL restore. The [G08.FM report](../savestate_g08_fm/review.md) records **207 LOADs in 187 main cases**, including publication/phase coverage. Those are causal correctness fixes retained by commits, not optional state that may be traded for area. Historical whole-design decreases during feature work do not authorize removing their information.

## 8. Exclusive non-controller inventory and concurrent ownership

The [non-controller audit](../non_savestate_optimization_audit/review.md), [exclusive groups](../non_savestate_optimization_audit/groups.json) and [structural hierarchy](../structural_resource_audit/hierarchy.json) provide the resource basis. Summing exclusive placed allocations gives **38,599.2**, close to official integer **38,599**; root inclusive estimate is **38,598.6**. The controller subtree **10,804.5** leaves **27,794.7** outside it by that exclusive sum (calculated). Fractional allocation and cross-hierarchy packing prevent independent removable site prices.

The following rows are **disjoint exclusive allocations or sums of disjoint leaves**. They are selected consumers, not a complete chip-total partition. Child rows listed separately are excluded from their listed parents.

| Outside-controller structure | Exclusive placed ALM | Logic ALUT | Dedicated FF | Memory interpretation |
| --- | ---: | ---: | ---: | --- |
| Both native sprite evaluator parents, no shifters | 4,144.5 | 4,616 | 5,819 | No own M10K |
| All 128 sprite shifter children | 4,360.6 | 6,579 | 5,700 | No M10K |
| Scaler parent, excluding children | 2,391.8 | 3,059 | 4,059 | Parent own0; subtree43 M10K |
| Board `sys_top`, excluding children | 995.0 | 1,400 | 1,432 | Excludes memory children |
| HPS I/O, excluding video_calc | 683.0 | 770 | 746 | Excludes children |
| Core `emu`, excluding children | 590.7 | 1,002 | 659 | Excludes children |
| T80 own logic, excluding decode/register children | 560.5 | 889 | 262 | No own M10K |
| T80 microcode decode | 297.3 | 474 | 0 | Separate child |
| T80 register file | 177.8 | 260 | 137 | Separate child |
| HDMI OSD parent | 558.6 | 906 | 618 | Subtree4 M10K, not own0 meaning absent buffers |
| HDMI PLL adjustment | 551.3 | 778 | 503 | Separate framework logic |
| Cheat engine | 539.9 | 530 | 1,104 | Associative state and control |
| VGA OSD parent | 507.4 | 886 | 608 | Subtree4 M10K |
| Core PLL reconfiguration core | 495.7 | 766 | 255 | Separate generated core |
| Both original CRAM parents | 731.1 | 1,214 | 803 | Ordinary FFs, no M10K |
| System wrapper, excluding children | 360.3 | 582 | 31 | Not a second CPU charge |
| OPLL envelope generator, excluding RAM | 323.9 | 524 | 236 | RAM child separately allocated |
| HPS video_calc | 319.0 | 474 | 649 | Separate child |
| Guest I/O | 307.4 | 544 | 187 | Separate logic |
| ALSA | 302.3 | 400 | 550 | Separate audio logic |

Alternative **inclusive family views, not additions to that table**: both complete VDP subtrees **10,295.7 placed /14,057 ALUT /13,094 FF /64 M10K**; scaler subtree **2,394.7 /43 M10K**; video mixer/scandoubler/HQ2x/gamma **827.5 /15 M10K**; selected mapper/decode/address entities **808.1 /1,229 ALUT /507 FF**; backgrounds with helpers **556.7 placed**, versus parent-only **447.2**. The audio-output family exclusive-row sum **1,004.4** differs slightly from an older inclusive hierarchy display **1,004.2**; preserve the grouping/rounding distinction, not a fabricated new saving.

Needed hierarchy estimates are not an exact additive partition: exclusive-row sum **37,084.4**, root inclusive **37,116.2**, official **37,117**. The **31.8** own-to-root difference exceeds simple displayed rounding and is not assigned to a module. Dedicated hierarchy FF sum **48,779** differs from global **48,880** because the summary includes other allocation categories. Outside-controller dedicated FF **33,839**, ALUT **39,645**, M10K **487** reconcile within their own columns; memory timing nodes must not be converted into FF.

System E's two VDPs receive common native enables but operate on **independent history simultaneously**. Mutually exclusive CPU-port address selection does not make pixel evaluation or all-slot shift/reload mutually exclusive. Both P records are needed on the original restore consuming edge and both live engines can be active on the next native edge. Runtime configuration therefore cannot justify statically deleting the secondary bank or scheduler. Cached/shifted planes that are inactive in one mode can matter after mode changes. These facts bound storage-sharing proposals and native priority/control rewrites.

## 9. Decisive sprite-cache connectivity finding

The [readable-export diagnosis](../sprite_cache_selector_netlist_diagnosis/review.md) correctly stopped **INCONCLUSIVE**: hierarchy counts, generic operator-port dumps and mux-recognition tables did not expose enough LUT connectivity to prove residual duplication. Recognized cache muxes included 19:1×8 and 21:1×8 operators, many restructured to zero recognized area. Their nominal input counts and estimates are not physical cell counts. Surviving duplicated FF names also cannot answer whether combinational data functions repeat.

The subsequent [atom-connectivity report](../sprite_cache_netlist_connectivity/review.md) used retained mapped/fitted netlists in a copied inspection tree and **read-only `quartus_cdb -t` queries**, without compiling, writing a netlist or running STA. That was an earlier authorized investigation; this consolidation invokes no Quartus. [All-slot normal-cut summary](../sprite_cache_netlist_connectivity/normal_cut_summary.json), [readable summary](../sprite_cache_netlist_connectivity/normal_cut_summary.md), [cone connectivity](../sprite_cache_netlist_connectivity/connectivity.json) and [D-input grid](../sprite_cache_netlist_connectivity/data_grid.json) supply direct evidence:

- Per VDP, **X bit0** uses a common VRAM-read source. Its required inversion/restore choice is fused locally; no standalone 64-copy inversion bank was established.
- Per VDP, **X bits1..7** use **seven shared normal-data nodes**, each with 64 mapped sinks.
- Per VDP, **d3 bits0..7** use **eight shared normal-data nodes**, each with 64 mapped sinks.
- Across both owners, **30 nontrivial shared selectors** already implement the proposed normal-data factoring. All **32 owner/field/bit groups** cover slots0..63; all **2,048 mapped X/d3 FF D inputs** use the corresponding shared source before their independent restore selection.

For example, primary X bit1 uses atom **57424 `spr_x~5`** shared into slot-specific terminals; primary d3 bit0 uses **60009 `spr_d3~0`**. Slot0's terminal uses saved `sprite_snap[33]`, while slot7's uses its own `sprite_snap[551]` and the same common 60009. These are distinct required restore functions. The fitted common d3 node is **MLABCELL_X25_Y42_N15**, fanout64; common X bit1 is **MLABCELL_X21_Y51_N42**. Physical cell names containing MLABCELL are not proof that these selectors are inferred MLAB memory. LUT pin/mask permutations between map and fit do not constitute new duplicated functions.

Selected full control cones show shared global normal predicates and clear, plus **different slot count predicates**. Primary slot0 decoder57054 and slot7 decoder75963 have the same count inputs but different masks/functions. Merging them would select the wrong slot. Shared restore/default SCLR57299 has **2,901 mapped /3,440 fitted loads**; its generated `data_address[0]~1` spelling does not imply thousands of independent address-data muxes. ENA is shared within bytes where appropriate, while per-slot selection and independent restore values remain necessary.

Post-fit coverage is explicitly bounded: **2,207 matched FF**, **2,180 exported D-pin rows**, **2,179 direct common-cut matches** and **one unresolved feeder bridge**. Another **27 matched FF** had no D-type pin row in that enumeration. The unresolved primary d3[59][3] feeder is not silently treated as proof of a constant or new selector. The six-slot full-cone samples and all-slot mapped grid answer the selected factoring question; they do not prove global Boolean minimality or exhaustive fitted equivalence of every arithmetic node.

An optional arithmetic mode/flag metadata query triggered **CDB_ATOM internal assertion** `this->bit_is_legal(bit)` in `cdb_atom_sys.cpp:7676`. Both map/fit optional queries had been scheduled before their logs were inspected. No further Quartus calls followed inspection of the assertion logs; no database repair or regeneration was attempted. Those optional exports were unusable. Small same-mask arithmetic-prefix signatures therefore remain **uncertified**, not safe-removal evidence. The assertion does not invalidate previously completed positive same-node connectivity and all-slot mapped sharing. See [classification](../sprite_cache_netlist_connectivity/classification.json) and [verification](../sprite_cache_netlist_connectivity/verification.json).

Preservation in that task verified **204 tracked hashes,137 inputs,135 normalized HEAD matches,1,001 original evidence hashes**, and **746 copied inspection files unchanged**. Only a crash-info file appeared in the inspection tree. This consolidation rechecks the original source/evidence ledger and the retained query/report evidence; no new API probing is warranted by this task.

**Final classification: NO-GO for a native X/d3 per-slot normal-data factoring PoC.** Demonstrated removable combinational cells for the alleged 64-copy network: **zero**. That is a bound on the demonstrated opportunity, not an assertion that all terminal logic is mathematically irreducible or a prediction of zero savings for every imaginable architecture. Native location differs from the old controller common-mux rewrite, but the desired sharing is already synthesized. No material surviving duplicate network supports a replacement.

## 10. Timing, routing and physical attribution risks

The [v19 structural paths](../structural_resource_audit/review.md), [non-controller timing analysis](../non_savestate_optimization_audit/review.md) and [CPU timing diagnosis](../cpu_restore_alias_timing_diagnosis/review.md) support the following distinct exposures. These are existing paths, not new analyses or an exhaustive new candidate timing qualification.

| Retained v19 seed-1 path family | Setup / hold ns | Interpretation |
| --- | ---: | --- |
| HDMI shadowmask RAM→OSD `dsp_width[19]` | Setup +.104 | Global worst; data5.753 ns =4.485 interconnect+1.268 cell; skew−.675 ns |
| Mapper CRC→T80 IR | Setup +.895 | Native CPU input, 14 levels; data16.941 ns, interconnect10.732/cell6.209 |
| SDRAM data→T80 IR | Setup +1.326 | External-memory/native input cone; not CPU restore alias |
| `ce_vdp`→cache d3 slot6 ENA | Setup +1.698 | 9.313 ns half-cycle relationship, data6.857 ns; control fanout/locality exposure |
| Primary sprite shifter60 adjacent shift bits | Hold +.239 | Data.347 ns, skew+.108; local hold margin matters even if setup improves |

For the CPU seed-1 alias, the **matched** RAM→`h_cnt[2]~DUPLICATE` path changes **+.478→−.714 ns**. Its relationship remains **6.732 ns**; data **5.369→6.554 ns** (+1.185), skew **−.685→−.692 ns** (−.007), cell **.993→.993 ns**. Thus the matched **−1.192 ns** slack change is overwhelmingly routed data, not new logic depth or dominant clock skew. RAM moves **M10K_X14_Y64_N0→M10K_X26_Y63_N0**, receiver **FF_X30_Y4_N38→FF_X82_Y36_N38**. The measured post-clear-LUT route contributes **+.901 ns** of the data change; route resources include additional long horizontal segments/local detours. The global baseline worst is a different endpoint, so its **−.818 ns** worst-slack change must not be decomposed with matched-path percentages.

The candidate HDMI setup TNS is **−12.187 ns**, reconciled over **23 failing endpoints** in the retained selected set (16 h_cnt,7 dsp_width). Other reported setup groups and holds pass. Queried CPU restore data envelopes have large positive slack; moved snapshot fanout is real, but it is not the failed HDMI path. Broad physical placement/routing response is supported; the fitter's initiating choice, exact local congestion cause and repeat-build determinism are unproved. It is incorrect both to call the CPU alias intrinsically slow and to assume an unrelated path will pass on another seed.

The paired seed-2 CPU result demonstrates a different physical outcome under one different common seed. It does **not** establish statistical confidence or a robust implementation. A four-placed-ALM saving with routing gate failures is not a qualified recovery. Format and packed-sprite seed-2 runs were unpaired and cannot supply additional paired samples for this candidate.

High fanout includes ARM **9,670**, primary restore **5,901**, secondary restore **5,448**, header **5,265**, and ring-control loads about **4,800**. Those nets overlap the same receivers and cannot be added as independent area penalties. Global transformation logs record **321 register-packing duplication operations** and **2,962 router duplication operations**; operation counts are not universally surviving FF counts. Sprite names provide stronger selected reconciliation: **1,476 shifter +483 evaluator** surviving duplicates; another121 VDP router operations bring that VDP operation category to **2,080**. For cache X/d0..d3 specifically, **5,120 ordinary +397 duplicate FF** are recorded, a subset of parent totals. Physical clones serve routability; they are not evidence of redundant state or removable combinational logic.

Whole-design placement obeys packing and spatial constraints. Baseline identity is **38,599−2,055 recoverable+573 unavailable=37,117 needed**. These estimates, ALUT counts, FF counts, fanout totals and hierarchy allocations are overlapping views of the same implementation, not additive cost buckets. Reduced FF/needed ALMs can coexist with increased placed ALMs, route-throughs, local congestion or unavailable packing. Per-net/per-hierarchy routing-ALUT ownership and local congestion maps are generally missing. No proportional assignment from global routing counts to CPU, HDMI or sprite logic is defensible.

## 11. Consolidated decision register

| Idea / work | Current classification | Evidence-based disposition |
| --- | --- | --- |
| Historical state/restart fixes through v19 | **Retained in production** | Commit chain in section3; correctness information/default/ordering obligations remain |
| F01 localized sequential OPLL +M10K | **Retained in production** | [F01](../savestate_f01_opll_fix/review.md); purpose-built local ports and stationary refill; not proof sprites transfer cheaply |
| Full physical SRAM streaming | **Retained in production** | [F06](../savestate_f06_sega_sram_fix/review.md); no new snapshot bank, explicit same-ROM contract |
| Controller common-mux rewrite | **Rejected by measurement** | [v16 trial](../savestate_sprite_resource_optimization/review.md); +47 placed despite functional pass |
| Parallel masks | **Rejected by measurement** | Same report; standalone +9,532 ALUT; no board fit |
| Packed sprite RAM/scatter | **Rejected by measurement** | [v17 trial](../savestate_g06_sequential_architecture/review.md); seed1 route failure, unpaired seed2 setup failure |
| Development-tag consolidation | **Rejected by measurement** | [format trial](../savestate_format_consolidation/review.md); +27 placed paired; unpaired seed2 setup failure; production readers retained |
| CRAM inferred RAM/scanner | **Rejected by measurement; reverted** | [CRAM](../cram_memory_inference/review.md); +121 placed,+4 blocks despite local improvement |
| PhaseMemory AUTO RAM inference | **APPROVED & MERGED IN MASTER** | PR #224, commit `ab09fdf4`; −207 a −253 placed ALMs, −310 a −346 FFs, +1 M10K, timing preserved across paired seeds |
| FeedbackMemory AUTO RAM inference | **Rejected by measurement; NO-GO** | [FeedbackMemory](../feedback_memory_auto/review.md); +5 placed ALMs, setup slack fell 218 ps (43%), retiming reduction |
| RegisterMemory AUTO RAM inference | **Rejected by measurement; NO-GO** | [RegisterMemory](../register_memory_auto/review.md); 100% loss of global physical retiming in scaler/core, setup margin degraded to +0.019 ns |
| PSG Simplificação Candidato C | **Rejected by measurement; NO-GO** | [PSG physical](../psg_c_physical/review.md); setup slack failure on seed 2 (−0.012 ns / −0.069 ns TNS) |
| Shared Standard 4-PAK Decode | **Rejected by measurement; NO-GO** | [4-PAK](../shared_standard_4pak_decode/review.md); placed area increased in both seeds |
| Shared Savestate Word Buffer | **Rejected by measurement; NO-GO** | [Shared buffer](../shared_savestate_word_buffer/_archive/package_check/physical/review.md); placed/needed ALMs increased in both seeds |
| CPU restore-data alias | **Rejected by measurement; isolated** | [seed1](../cpu_restore_output_alias/review.md) timing failure; [paired seed2](../cpu_restore_alias_seed2_pair/review.md) routing failures; no promotion |
| Frozen-live SAVE alone removes rings | **Rejected by architectural feasibility as bank deletion** | [storage study](../g06_g10_storage_optimization/review.md); LOAD staging survives |
| Shared ring / OPLL-tail borrowing / destructive scan | **Rejected by architectural feasibility at current gate** | Same study and [feasibility](../sprite_restore_architecture_feasibility/review.md); owner capacity, observer/reset/recovery authority unresolved |
| Local RAM direct live install / native RAM scheduler | **Rejected by architectural feasibility at current gate** | [feasibility](../sprite_restore_architecture_feasibility/review.md); no complete interruption/port/native schedule proof |
| Private atomic FF commit / serial local shadow variants | **Inconclusive physical benefit; no candidate selected** | Same report; safer authority mechanism, near-full FF staging and replacement selectors remain; no fitted evidence |
| Native X/d3 shared-data factoring | **Already implemented by synthesis; NO-GO** | [connectivity](../sprite_cache_netlist_connectivity/review.md);30 shared nontrivial nodes, all64 slots per owner |
| Hoist common screen-range predicates | **Already implemented in source** | [native audit](../non_savestate_optimization_audit/review.md); per-slot X operands still differ |
| Small matching arithmetic-prefix signatures | **Inconclusive / insufficient evidence** | [connectivity classification](../sprite_cache_netlist_connectivity/classification.json); optional mode query asserted; masks alone do not prove safe elimination |
| Native sprite evaluators & shifters | **Audited; no promising opportunity identified** | [native audit](../non_savestate_optimization_audit/review.md); duplicate FFs serve routing, no promising factoring identified |
| VDP background generation | **Audited; no promising opportunity identified** | [vdp_background audit](../../rtl/vdp_background.vhd); 543:1 address mux already restructured to 12-16 LEs, high scroll quirk risk |
| T80 CPU Microcode & Datapath | **Audited; no promising opportunity identified** | [T80 audit](../../rtl/T80/); bus and instruction timing critical, synthesis already shares control |
| Game Genie Cheatcodes | **Audited; no promising opportunity identified** | [cheatcodes audit](../../rtl/cheatcodes.sv); dense 1,104 FF packing in 349 needed ALMs, 32 parallel comparators necessary |
| Guest I/O (`io.vhd`) | **Audited; no promising opportunity identified** | [io.vhd audit](../../rtl/io.vhd); port read multiplexing and serial GG timing constrained, no promising opportunity identified |
| Scaler/filter sharing, mapper/cheat decode, small OPLL arrays, PLL/config/BG arithmetic | **Not attempted; selection NO-GO** | Same audit; missing schedule/port/range or residual-logic benefit proof, timing exposure or small scale |
| Other restore-output/DMA lifetime sharing | **Not attempted** | [controller audit](../savestates_internal_cost_audit/review.md); no per-consumer proof or physical result; CPU pilot does not generalize |
| Explicit CRAM primitive / memory-width retries | **Not attempted** | [CRAM](../cram_memory_inference/review.md) and feasibility reports; different port contract would need new evidence, not a default retry |

“Rejected by architectural feasibility” means the current selection gate was not met, not a universal impossibility proof. “Not attempted” does not mean harmless, beneficial or authorized. The earlier selector report remains historically inconclusive; the later positive connectivity evidence resolves its particular X/d3 factoring hypothesis, not every native logic opportunity.

## 12. Conditions for reopening

Reopen only when genuinely new evidence identifies a **distinct concrete resource-removal mechanism**, rather than another spelling of a rejected mux, packed-scatter network, memory width, seed or clone-suppression setting. It must identify actual surviving nodes/storage and consumers, replacement selectors/ports/buffering and an evidence-backed material net opportunity. Exact ALM savings need not be predicted before building, but large parent allocations and theoretical bit packing are insufficient.

Before any separately authorized implementation:

1. Prove current-format information and bytes, accepted public/tagged imports and defaults, System E concurrent ownership, SAVE-only state, frozen guest behavior, accepted DDR transactions/stale responses/timeouts, late malformed-image rejection, repeated LOAD from different Q, reset at every staged prefix and the original restore-authority contract. No silent rollback interval or bus reread dependency may be added.
2. Establish exact consuming-edge/NBA correspondence and deterministic first native release, including CPU/NMI/private preparation, sprite/background history, pending PSG tick, AudioMix phase/retained sample, OPLL capture/apply/refill and Pause. No extra native cycles, settling grace or legitimate-difference masks.
3. Use bounded source-bound equivalence/real-consumer miters plus relevant existing component/integration/image/native-suffix regressions. State finite coverage and remaining assumptions explicitly. A source-only feasibility argument is not a functional pass.
4. Only after functional gates, compare fresh source-isolated baseline/candidate physical implementations with unchanged tool/device/date/IP/constraints/settings. Confirm with **at least two paired seeds**, same seed on both sides of each pair; retain unsuccessful pairs. **Duas seeds constituem o critério mínimo adotado para triagem de sensibilidade física no Cyclone V, e não uma prova universal de estabilidade ou timing signoff.** Nenhum resultado pode usar substituição de seed desemparelhada ou seed shopping. A failing baseline cannot qualify a passing candidate as an improvement over a timing-qualified control.
5. Require lower whole-design placed ALMs, positive reported setup and hold, zero new timing violations/critical warnings, acceptable block/resource use and routing. Retain original reports, TNS/endpoints, mapped/fitted FF, logic/routing ALUT, packing identity and final total/directional interconnect. For a continuation of these pilots, preserve the established no-growth routing gates unless a separately authorized decision explicitly changes the acceptance contract; do not retroactively waive a failed gate.
6. **Restrições obrigatórias permanentes:** nunca modificar arquivos em `sys/` (framework compartilhado MiSTer); nunca reduzir funcionalidades, modos de vídeo ou compatibilidade regional; conduzir experimentos em branches/worktrees isolados; e exigir validação funcional e física completa antes de qualquer integração.

No constraint relaxation, false paths, altered clocks, feature removal, public-reader deletion or state loss counts as a semantics-preserving area optimization. New evidence would justify **review of a bounded proposal**, not automatic authorization to implement or run Quartus. No specific speculative PoC is selected here.

## 13. Final conclusion and preservation

**No immediate implementation work is supported. Recommended next action: STOP and review this consolidation.** Retain committed v19 and all negative evidence. The resource budget is concentrated and physically sensitive; investigated storage substitutions, syntax simplifications and the narrow CPU alias have not yielded a qualified production win. The leading native normal-selector opportunity is already synthesized. Alternative architectures retain unresolved correctness authority or unsupported net physical benefit.

This does not establish global optimality, prove all future optimizations impossible, or guarantee current timing across seeds/hardware. It establishes that the current record supplies no sufficiently justified next implementation. Reopening requires the new evidence and qualification gates above.

Final preservation evidence is [preservation_after.json](preservation_after.json). It rechecks the same **1,584 frozen files**, including all204 tracked files,137 retained input hashes and the prior1,001-entry evidence ledger;135 normalized input/HEAD comparisons still match. HEAD, branch and index are unchanged. New documentation and verification artifacts are confined to `tests/fpga_resource_optimization_summary/`; all earlier evidence remains in place. No RTL/IP/QSF/SDC/format or tests were edited, no candidate created, and no Quartus/simulator/build, checkout/reset/clean, commit/push/merge/PR performed.

Final `git diff --stat`:

```text
(empty)
```

Final `git status --short`:

```text
?? tests/
```

The pre-existing untracked tests tree includes this new report, so ordinary tracked diff statistics do not describe the size of the documentation addition. Stop after the report and await review.
