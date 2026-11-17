# Current upstream SMS_MiSTer savestate resource cost

## 1. Verified production identity and compact answer

**Current upstream is not the previously audited v19.** Live upstream metadata checked twice on 2026-10-28 identifies [MiSTer-devel/SMS_MiSTer](https://github.com/MiSTer-devel/SMS_MiSTer), default branch **`master`**, at **`8443a0d19a88aff7a5900011bccf386daf146945`** (“Fix SMS cartridge disable through port $3E (#223)”). The local `origin` is the fbreve fork, not the upstream authority. Local HEAD remains `1b2a52d87d2659c908d4f9f846416d14bfd85bea` on `investigate/cram-memory-inference`.

For source-matched upstream production, the retained controller allocation is approximately **4,319.8 placed ALMs, 3,889.6 needed ALMs, 4,269 fitted logic ALUTs, 3,808 dedicated FFs and zero M10Ks**. A separate savestate UI contributes a measured **71.8 placed ALMs,124 logic ALUTs,95 dedicated FFs,zero M10Ks**. Additional restore/capture/freeze/transport hardware is distributed through shared native modules, but its exclusive physical cost is not isolated by the retained reports. **The actual incremental whole-design cost of enabling current savestates is UNKNOWN: no valid current-production with/without pair was found.**

| Resource | Verified direct controller allocation | Verified distributed savestate allocation | Total incremental cost | Evidence quality |
| --- | ---: | --- | --- | --- |
| Placed ALMs | 4,319.8 | UI71.8; other distributed portion **unknown** | **Unknown** | Source-matched fitted hierarchy; fractional attribution, not removable sites |
| Needed ALMs | 3,889.6 | UI68.9; other portion **unknown** | **Unknown** | Fitter estimates; not an additive whole-chip delta |
| Logic ALUT | 4,269 | UI124; other portion **unknown** | **Unknown** | Fitted hierarchy allocation |
| Routing ALUT | Unknown per controller | Unknown | **Unknown** | Only chipwide13,159 known; no exclusive source partition |
| Dedicated fitted FF | 3,808 | UI95; other portion **unknown** | **Unknown** | Fitted dedicated-register column; excludes some global categories |
| Mapped FF | 3,805 | UI and other mapped allocations not separately extracted here | **Unknown** | Controller synthesis hierarchy; global map34,857 |
| M10K | 0 | UI0; net distributed memory-inference/port effect **unknown** | **Unknown** | No controller RAM; native block allocation is not all savestate overhead |

The two measured disjoint savestate-only entities sum to **4,391.6 placed ALM allocation,4,393 logic ALUT,3,903 dedicated FF,zero M10Ks** (calculated). This is a known hierarchy subtotal, **not a measured total incremental cost or a guaranteed lower bound on removable whole-chip ALMs**. Removal can change packing, inference, duplication and placement globally.

## 2. Remote verification, source differences and production format

The read-only commands `git remote -v` and `git ls-remote --symref upstream HEAD refs/heads/master` establish repository identity, actual default branch and matching HEAD/master SHA. The latter was repeated successfully; [upstream_metadata.json](upstream_metadata.json) retains the response. An initial sandboxed network attempt failed; permitted read-only remote queries succeeded afterward. The commit object was already local, so no `fetch`, remote-tracking ref update, checkout or branch/index change was needed. Current means the upstream default-branch tip **at the recorded observation**, not every deployed RBF or a guarantee about future remote updates.

Source comparison establishes **42 changed paths** between this upstream and local v19: CPU/T80, VDP, PSG/AudioMix, mapper/peripheral hooks, VM2413, controller and integration changes. [source_verification.json](source_verification.json) records the exact name/status list and Git blobs. Root SMS.qsf and SMS.qpf blobs are identical across those commits. `files.qip` differs by adding `rtl/opll_snapshot.sv`; its VM2413 sources also changed. There are no QSF/SDC changes in that commit comparison, but **unchanged constraints do not make changed RTL a comparable current-cost netlist**. Existing retained input verification covers relevant QIP/IP/framework source as well as core HDL. Generated build dates differ between retained implementations, as documented below.

Production uses the **untagged 96 KiB family**, **not v19 /0x484313**. Executable constants in [upstream controller](../savestate_hcounter/baseline/rtl/savestates.sv:185) define `SMS1` magic `0x534D5331`, BIOS `SMSB` `0x534D5342`, current size24,574 32-bit words (`0x5ffe`), and legacy size16,382 (`0x3ffe`). Slot stride is `0x3000` DDR64 words. The current writer has a **230-bit CPU snapshot**, despite its stale top-of-file memory-map comment saying212. The **PSGX1** audio extension descriptor is `0x50534758` with its own version1; that is not an outer numbered development tag. Public64 import support is present. Header/game-signature, ownership and optional-extension behavior must be read from this implementation, not borrowed from the v19 parser.

Consequently the v19 **10,647.6 controller-own placed ALMs /14,773 FF /6,966 ALUT**, its two4,800-bit sprite rings, background-history banks, OPLL scratch M10K and newer sample/restart controls are **inapplicable as current upstream measurements**. The [consolidation](../fpga_resource_optimization_summary/review.md), [structural audit](../structural_resource_audit/review.md), [controller audit](../savestates_internal_cost_audit/review.md), [growth history](../savestate_resource_growth/review.md), [native audit](../non_savestate_optimization_audit/review.md) and [connectivity report](../sprite_cache_netlist_connectivity/review.md) were used as historical/provenance context. Their native sharing/fanout conclusions are source-bound to their v19 build and are not silently promoted to this upstream netlist. The growth audit's **historical** checkpoint, however, is exactly this upstream SHA and supplies applicable retained evidence.

## 3. Existing production build provenance

Two retained implementations match upstream production sources:

| Build | Production source verification | Build date / seed | Whole-design needed / placed | Mapped / fitted FF | Logic / routing ALUT | M10K | Setup / hold ns |
| --- | --- | --- | ---: | ---: | ---: | ---: | ---: |
| [HCounter investigation baseline](../savestate_hcounter/baseline/) | 134 tracked build inputs rechecked against upstream SHA | 261020 /1 | 26,465 /31,531 | 34,857 /35,709 | 37,056 /13,159 | 487 | +.508 /+.144 |
| [Timing-history F](../timing_history/builds/F/) | Same134 inputs independently rechecked | 261014 /1 | 26,465 /31,531 | 34,857 /35,709 | 37,056 /13,159 | 487 | +.508 /+.144 |

Both use Quartus Prime **17.0.2 Build602 Lite**, Cyclone V **5CSEBA6U23I7**, SMS /`sys_top`, MISTER_FB=1, STANDARD FIT, HIGH PERFORMANCE EFFORT, SPEED, final placement ALWAYS, ALM register packing LOW and the retained original IP/constraints. Source contents match after CRLF/LF normalization; raw hashes are preserved separately. The134 inputs come from the original growth proof and manifest domain, with two additional unused `.bak`/`.orig` entries outside Git. The [rechecked primary proof](source_verification.json) and [alternate build evidence](additional_build_evidence.json) retain every checked path, source hash and metric. The original [growth proof](../savestate_resource_growth/source_verification.json) reports no missing inputs, mismatches or environment differences.

The table shows equal measured endpoints, **not a matched savestate-removal experiment or a claim that BUILD_DATE never matters**. These are existing source-only historical production implementations, not fresh compilations for this task. Their build dates differ from local v19's261025 and must be retained if a future measurement chooses one as its baseline.

Primary original reports: [fit summary](../savestate_hcounter/baseline/output_files/SMS.fit.summary), [full fitter report](../savestate_hcounter/baseline/output_files/SMS.fit.rpt), [map report](../savestate_hcounter/baseline/output_files/SMS.map.rpt), [STA summary](../savestate_hcounter/baseline/output_files/SMS.sta.summary). [measurements.json](measurements.json) re-extracts them without Quartus. Whole design uses **3,809,858 logical memory bits,39 DSPs**. Final interconnect average total/H/V is **28.9/29.0/28.7%**, peak **53.7/54.6/56.4%**. Packing identity: **31,531−5,381 recoverable+315 unavailable=26,465 needed**. These are implementation metrics, not savestate-only quantities.

There are **38 unique critical-warning messages** and inherited unconstrained setup/hold categories. Reported violating groups are zero; that does not make the design fully constrained or hardware-signed-off. No current timing query or compilation was run. The build's source and configuration, rather than a directory name or nominal version string, justify using its hierarchy values.

## 4. Direct controller breakdown

The original fitted entity row at [SMS.fit.rpt:8032](../savestate_hcounter/baseline/output_files/SMS.fit.rpt:8032) gives **needed3,889.6 /placed4,319.8 /logicALUT4,269 /dedicatedFF3,808 /memory bits0 /M10K0**. Inclusive and exclusive numbers are identical: this controller has **no fitted resource-owning child subtree** in the retained436-row hierarchy. [hierarchy.json](hierarchy.json) preserves the original inclusive/own strings. Its synthesis row gives **4,095 mapped ALUT /3,805 mapped FF**; do not substitute synthesis ALUT for fitted logic ALUT.

Source inventory below describes **declared storage widths**, not exact per-bank fitted allocations. [declarations.json](declarations.json) lists register declarations and source locations from the verified upstream controller. Dead bits, constant fields, FSM recoding, shared logic and physical duplication prevent assigning each source field an exact ALM cost from those widths.

| Snapshot subsystem | Declared bits | Purpose / consumption |
| --- | ---: | --- |
| CPU `z80_snap` | 230 | Four DDR64 payload words; restored through separately held230-bit `z80_dir` |
| Primary +secondary VDP architectural register snapshots | 128+128=256 | Independent records, not live sprite cache history |
| Primary +secondary palettes | 384+384=768 | Six DDR64 words each;32 addressed entry writes per active owner on restore |
| Primary +secondary legacy PSG configuration | 56+56=112 | Legacy interface; some container bits are not independent live history |
| Exact PSG temporal payloads | 96+96=192 | Quiescent post-drain capture and extension restore |
| Audio divider /control /phase snapshots | 4+11+1=16 | Descriptor/control and release selection |
| Mapper | 64 | Restored before core release/memory routing |
| Evolution extra state | 96 | Packed through established IO/EEPROM routes |
| IO /video | 32+22=54 | Current-layout restore; legacy behavior differs |
| EEPROM wrapper | 64 | Existing limited historical interface, not v19 completeness |
| **Declared snapshot total** | **1,852** | Source-width sum; not a fitted-register partition |

Capture is not one universal clock: boundary/ARM stages capture CPU/VDP/mapper-related state, while the PSG path explicitly captures after pending work drains and `audio_quiescent` is true ([controller:902](../savestate_hcounter/baseline/rtl/savestates.sv:902)). LOAD fills private latches and later copies subsets into registered outputs; CRAM is restored entry by entry. The relevant distinction is this upstream implementation's actual behavior, including its historical limitations, not the stronger v19 validation/restart contract.

The separately declared **restore-data outputs total1,084 bits**, matching the non-CRAM snapshot data widths: CPU230, VDP256, PSG112, exact PSG192, audio divider/control/phase16, mapper64, Evolution96, EEPROM64, IO32, video22. Palette restore uses two5-bit addresses/two12-bit data buses plus strobes instead of two384-bit output banks. These outputs have different write/strobe lifetimes; a scalar source bit is not proof of a removable duplicate.

Transport/staging includes three **64-bit byte-assembly buffers** (192 declared bits), one **64-bit DDR read latch**, three **8-bit stalled-last-byte latches** plus validity, separate save/load byte addresses, byte counters and RAM-latency pipelines. Registered DDR command outputs comprise address29,data64,BE8,RD/WE and burst count8. VRAM1/2, WRAM and NVRAM have distinct addressed restore/read outputs. Their accepted-transaction state is savestate-specific, but some declared bits optimize away. In particular the `ddram_cmd_*` **103-bit combinational preview** is declared with Verilog `reg` and driven by `always @(*)`; it is **not103 FF** to add to storage totals.

Control includes a declared **7-bit FSM**, operation/slot/base-address/change-detector/game-ID/magic state, legacy/audio-valid flags, word/entry/CPU/VDP indices, **20-bit flush**, **8-bit unfreeze**, **22-bit alignment timeout**, **25-bit DDR watchdog**, **6-bit drain counter** and **28-bit cooldown**. State recoding and duplication require actual mapped-node evidence for a fitted subpartition. No new netlist query was authorized or needed; this report leaves those per-bank fitted counts **unknown**, rather than forcing the declaration totals to equal3,808.

There are **no two4,800-bit sprite history rings, no two139-bit G05 snapshot banks, and no F01 OPLL scratch memory** in this upstream controller. Live sprite/shifter/background registers still exist outside it for native execution; absence of a controller snapshot does not make native registers savestate overhead.

## 5. Distributed savestate-related hardware

The following inventory traces the **verified upstream source tree retained with the build**, not current worktree v19 files. Restore muxes/qualifiers can fuse with native data/enable equations. Hierarchy allocations in mixed modules cannot separate that fused cost without a controlled counterfactual or disjoint mapped ownership proof.

| Location / mechanism | Attribution class | What is established; what is not |
| --- | --- | --- |
| [savestate_ui](../savestate_hcounter/baseline/rtl/savestate_ui.sv), own entity | **Exclusive savestate hardware** | Measured71.8 placed /68.9 needed /124 logicALUT /95 dedicatedFF /0M10K. Separate from controller. Handles requests/slot/input/status presentation. |
| [SMS.sv:540](../savestate_hcounter/baseline/SMS.sv:540), game signature | **Savestate-specific source state/logic** | 32-bit `ss_game_id` updated during download for header validation; fitted own cost inseparable from core top here. Do not delete unrelated mapper CRC/decryption state under the same label. |
| [SMS.sv:882](../savestate_hcounter/baseline/SMS.sv:882), restored enable history | **Savestate-specific staging/control** | Two2-bit restored-enable banks,valid1 and two2-bit prior-status banks (nine declared bits), plus restore/live-status selection. Source count is not a verified nine-fitted-FF allocation. |
| [SMS.sv:41](../savestate_hcounter/baseline/SMS.sv:41), freeze edge /Pause; native enable gating | **Exclusive qualifiers mixed with native control** | Freeze delay/unfreeze edge, CPU/VDP/pixel/sprite gates, Pause interaction and write suppression. Native dividers and Pause behavior are shared requirements, not whole-module overhead. |
| [SMS.sv:1314](../savestate_hcounter/baseline/SMS.sv:1314), DDR owner muxes | **Savestate-specific mux/select function; shared bus** | Select SS or scaler/rotation command buses under freeze. Native owner and DDR clock remain needed without SS. No exclusive mapped mux/route cost isolated. |
| [T80](../savestate_hcounter/baseline/rtl/T80/T80.vhd:270), T80s, T80_Reg | **Shared native registers +exclusive restore selection** | REG observation, alternate RegDIR permutation, DIRSet load priorities and wrapper bus behavior. CPU architectural/register-file state is required natively; do not count all T80 FF as savestate. |
| [VDP](../savestate_hcounter/baseline/rtl/vdp.vhd:263), VDP main/background/sprites/shifters | **Shared native state +restore/default/clear logic** |128-bit architectural snapshot export and restore; background reinitialization, sprite clear/restart controls; no current-production full-history receiver bank. Native caches, shifts, IRQ/collision/control registers remain functional state. |
| [CRAM](../savestate_hcounter/baseline/rtl/vdp_cram.vhd:13) | **Native storage with savestate-specific access topology** | Full384-bit asynchronous observation and prioritized entry write port. Native contents/renderer latency remain needed. Snapshot fanout can obstruct RAM inference; baseline's FF palette allocation is not entirely overhead and no native-only memory result is measured. |
| VDP VRAM port A, [SMS WRAM/NVRAM muxes](../savestate_hcounter/baseline/SMS.sv:963) | **Shared live RAM +savestate access arbitration** | SS read/write address/data/WE selection and frozen ownership. System E passive VRAM, WRAM expansion, persistent SRAM and EEPROM contents serve unrelated native/persistence purposes. Additional net M10K cost is unknown, not487. |
| [JT89](../savestate_hcounter/baseline/rtl/jt89/jt89.v:87), tone/noise children | **Shared native temporal state +restore/observation/qualification** | Divider, period/volume/noise/history loads and quiescent detection. Tone counters/noise LFSR/mixer histories are native, not an extra snapshot bank. Source exports are often wires. |
| [AudioMix](../savestate_hcounter/baseline/rtl/AudioMix.vhd:35), system audio controls | **Shared native toggle/output +restore phase selection** | Saved-phase override and PSG/control restore. Native L/R output registers and arithmetic remain. No F01 exact OPLL restoration or v19 last-sample extension in this source. |
| [Mapper/Evolution](../savestate_hcounter/baseline/rtl/evolution_mapper.vhd:116), IO, EEPROM wrapper | **Shared functional state +restore/freeze branches** | Mapping/register loads, serial wrapper restoration and write freeze. Native mapper selection, EEPROM storage/protocol and decryption are not wholly savestate resources. Older incomplete restoration is not filled in with v19 hardware. |
| Video state export/restore, top input masking/status/info | **Shared counters/state +savestate-specific interface logic** | Video beam restore, SS hotkey directional suppression, OSD/status/info connections and host metadata. HPS/video/scaler whole hierarchies are not exclusive SS blocks. |
| High-fanout enable/clear and physical clones | **Physical attribution uncertain** | Production report lists `z80_set`4,812 loads,secondaryVDP restore4,511. Clones/routes can serve native and observation loads together; no causal exclusive FF/ALM partition. |

As context only, the source-matched palettes' own allocations are **368.0+370.5=738.5 placed ALMs**, **601+601=1,202 logicALUT**, **396+399=795 dedicatedFF**, noM10K. Those numbers include native storage/read logic and are **not** entered as verified distributed savestate overhead. Similarly T80_Reg's207.5 placed allocation includes native register-file function. The full [hierarchy export](hierarchy.json) permits checking these distinctions without adding nested parents and children twice.

The existing fitter log has **1,345 router-duplication operation rows** chipwide. That is an operation count, not a proved surviving FF population caused by savestates. The much larger v19 native-audit duplication populations are not a valid substitution. Snapshot fanout, restore qualifiers and DDR ownership can change packing/replication outside the controller, but neither a load count nor a duplicated FF name gives an exact ALM penalty. There is no per-module routing-ALUT ownership map in the retained hierarchy table.

Private snapshots and command latches support coherence/staging in this implementation. Other modules implement prioritized loads, clears, freeze gating and ownership. This does **not** establish an all-memory transactional rollback guarantee or v19-strength malformed-image rejection for upstream. A future no-savestate measurement removes the SS function; it must preserve unrelated normal functionality, not retroactively “fix” savestate semantics as part of the area comparison.

## 6. Search for a valid incremental comparison

The retained-build search included ignored/hidden files: `rg --files --hidden --no-ignore -g SMS.fit.summary tests`, plus report/manifest searches for no-savestate/disabled/without-savestate variants. [build_search.json](build_search.json) records **71 retained fit-summary locations**, source availability, controller instantiation and explicit savestate-related feature defines. Of these,16 do not have top-level source beside the report and cannot be certified from that adjacency check;55 have source,53 instantiate the controller. No explicit savestate feature define was found in those QSF checks. This is an evidence search, not a claim that every retained summary represents a successful complete fit or an independent experiment.

The two source-present controller-free cases were investigated rather than assumed valid controls:

| Existing no-controller source | Identity / mismatch | Eligibility |
| --- | --- | --- |
| [Timing-history A](../timing_history/builds/A/) | `260e0a19037b5b0333ab5abeb061a927187660a7`, April lightgun checkpoint before savestates; BUILD_DATE261014 | **Invalid current counterfactual**: many unrelated core/framework/features differ from8443a0d |
| [Timing-history G](../timing_history/builds/G/) | `2b92232d7b681ac6bab952fd88572ddc729b8bd7`, historical pre-introduction checkpoint; BUILD_DATE261014 | **Invalid current counterfactual**: different source baseline, not current production minus only SS |

See [checkpoint identities](../timing_history/checkpoints.csv), [source verification](../timing_history/source_verification.csv), [historical synthesis ledger](../timing_history/synthesis_isolation.csv), [intervening commits](../timing_history/commits.csv) and [new comparison evidence](additional_build_evidence.json). Historical A→B also includes reset, mapper, SC-3000/keyboard, link/VDP and other work; even the introduction commit combines savestates with mapper detection. There are multiple timing-history stage/report ledgers; this report does not resolve their historical synthesis-only versus later fit provenance by using a convenient scalar. Neither A nor G meets the source-equivalence prerequisite regardless.

No valid current8443a0d savestate-disabled build pair was identified. Report-only directories or older checkpoint differences do not fill that gap. The v19 growth/optimization builds all target different implementations and/or retain savestates. No accepted pair exists from which to calculate current needed/placed ALMs, logic/routing ALUT, mapped/fitted FF, M10K, setup/hold or final-routing **incremental deltas**.

**Measured current incremental deltas: unknown for every requested metric.** Do not subtract A/G from F, pre-fix from v19, a controller hierarchy allocation from a chip total, or historical per-feature growth from current production to manufacture the answer. Whole-chip31,531 placed and controller4,319.8 placed answer different questions.

## 7. What is known, unknown and comparable

| Component / inference | Status |
| --- | --- |
| Current default branch /tip and format | Verified live Git metadata plus exact local object/source; untagged96,PSGX1 |
| Controller/UI hierarchy resource allocation | Verified original map/fit reports for source-matched implementations |
| Source snapshot/data-output/transport widths | Verified from current upstream source; declared widths, not per-bank FF/ALM measurements |
| Distributed savestate functionality exists | Verified restore/load/freeze/access branches and integration wiring |
| Exclusive cost inside mixed CPU/VDP/PSG/mapper/framework modules | Unknown physical split; UI is the separately measured exception |
| Net M10K impact of adding/removing SS | Unknown; direct controller zero does not determine memory inference elsewhere |
| Router duplication attributable specifically to SS | Unknown; global operation count/fanout is not causation |
| Current with/without whole-design cost | **Unknown; no eligible retained pair** |
| v19 controller/resource measurements applicable here | **No**, source and savestate architecture differ substantially |

The direct allocations are high-confidence **implementation observations under one configuration/seed**, not analytic gate prices. Native register banks and RAM serve the guest even when savestates are never requested. Extra observation ports may change their mapping without adding stored information; restore muxes can fuse with native selection. Removing the function may even change M10K count in the opposite direction to a simple “delete RAM” intuition. Those interactions are why a measured counterfactual is necessary.

## 8. Proposed controlled measurement — design only

This protocol is **not implemented or authorized by this report**. No new RTL, compile-time option, source worktree or candidate was created. It is the minimum defensible way to answer the remaining whole-design question.

**Pinned source and control.** Use upstream **8443a0d19a88aff7a5900011bccf386daf146945**, not local v19. Select the verified HCounter-baseline input set with **BUILD_DATE261020**, MISTER_FB=1, Quartus17.0.2 Build602 Lite,5CSEBA6U23I7, original QSF/QPF/SDC/QIP/IP and settings. The existing fit is the retained reference, but fresh paired original/counterfactual builds should establish each seed's comparison on the same host. If production upstream advances before authorization, explicitly decide whether to keep this pinned question or reverify the new tip; do not silently mix revisions.

**Define the counterfactual precisely.** Remove the ability to capture/import/transport savestates while preserving all native emulation, video/audio, System E, BIOS/cart/mapper/decryption, download, controllers, cheat, persistent file-save/load and host memory behavior. Only SS trigger/menu/info/status behavior may intentionally disappear; document how that affects hotkey masking and slot fields. This is feature-cost measurement, not an optimization preserving SS capability.

Removal/bypass boundary must include:

1. Controller and `savestate_ui`; SS-only game fingerprint/history, operation status, request handling and restored-enable staging. Prune only data with no remaining native/persistence consumer; do not confuse SS signature with native mapper CRC/detection.
2. Tie restore strobes and SS memory-write/read requests inactive, remove restore-data/observation interfaces where exclusive, and remove freeze from native enable/write qualifiers. Replace ownership muxes with the normal **current-production** owner path. A stub that merely stops UI requests while leaving active restore inputs/observation consumers is not adequate removal; confirm synthesis actually eliminates the target functions.
3. Remove DIR/RegDIR restore-only muxes, VDP register/clear/restart qualifiers, PSG/audio divider/phase restore paths, mapper/IO/EEPROM/video state restore and SS-specific exports. Preserve every normal update, reset priority, clock enable, latency and initialization. Keep all native cache/shifter/CPU/serial state. Do not replace native state with constants just because its snapshot output disappears.
4. Remove exclusive palette-wide snapshot demand and SS memory arbitration while preserving renderer/CPU read-during-write and initialization semantics. Any changed native RAM inference is part of measured feature removal, but must remain functionally equivalent. Do not force extra RAM substitutions or alter IP/constraints to improve the counterfactual.
5. Preserve live WRAM/VRAM/SRAM/EEPROM contents, persistent-save arbitration/dirty tracking and System E passive/active banks. The current no-SS native DDR path still uses the established `DDRAM_CLK=clk_sys`; do not revert unrelated clock wiring to an earlier historical implementation. Preserve native memory ownership and accepted transactions when SS is idle.

**Prevent accidental feature elimination.** Produce a source diff/classified consumer inventory before building, a complete input manifest, and static checks for unchanged native entities, capacities and feature defines. Inspect elaborated/mapped hierarchy and surviving memory blocks, clocks, CPU/VDP/PSG/OPLL instances, mapper variants and host paths. Reductions outside the selected removal boundary require explanation; they may be legitimate loss of SS observation loads or a regression, not automatically a win. Do not remove second VDP/PSG based on one test configuration: System E is runtime-supported concurrent functionality.

**Functional gates.** Compare original and no-SS variants with SS requests inactive, using actual CPU/VDP/PSG/OPLL/mapper consumers and equivalent initialized guest/input histories. Check every native update/enable and accepted memory transaction, first-cycle/reset behavior and long suffixes for SMS/GG/SG/SC/System E, BIOS, turbo, peripheral/controller modes, video/palette/renderer collisions and stereo audio. Include ordinary Pause/reset, CPU prefixes/interrupts/HALT, ROM fetch/decryption, downloads and persistent NVRAM file operations. Test attempted SS hotkeys/host requests separately against the declared disabled-interface contract; native execution must continue safely and no SS DDR/write activity may occur. No guest differences, observation grace or masks may suppress legitimate regressions. Existing upstream semantic defects must not be fixed or recreated as part of this counterfactual.

**Physical protocol.** Once source/functional gates pass under separate authorization, run fresh original and disabled implementations sequentially for **seed1 on both**, then **seed2 on both**, same host/tool environment, fixed261020 and all other sources/settings identical apart from the classified SS removal. Retain full map/fit/asm/STA databases/logs, warnings, exact input hashes and functional/source ledgers. Two pairs are practical for this bounded measurement if build time/disk are authorized; historical full-board work was roughly tens of minutes per build, but runtime/memory for this older source has not been benchmarked here and is not promised. Do not substitute the v19 CPU pair's measurements or a favorable unpaired seed.

For each pair report `with_SS − without_SS` (state that sign convention explicitly) for needed/placed ALMs, mapped/fitted FF, logic/routing ALUT,M10K, memory bits,DSP, setup/hold,TNS/endpoints,critical warnings and final total/H/V average/peak interconnect. Require positive reported setup/hold and no new violations; preserve inherited constraint-coverage limits. Report both seeds even if costs differ or a fit fails. A failed route has no completed timing result; a failing baseline/disabled design leaves qualification incomplete rather than granting a usable area estimate from a successful opposite side.

**Separate removal from remapping.** Confirm controller/UI elimination and intended restore-only nodes/ports, then compare disjoint hierarchy/register/memory families and physical duplication. The whole-design delta is the resource effect of the defined feature removal **including** remapping; it is not a sum of per-mux costs. Use two paired seeds to expose placement variability, not to claim statistical confidence or an exact invariant “ALMs per savestate.” Explain local/global differences and source-unrelated physical movements without assigning unsupported causes. No optimization, seed sweep, alternate packing setting, relaxed constraint or unrelated feature removal belongs in that experiment.

## 9. Confidence, preservation and final Git state

High confidence: live upstream tip/default branch, non-equivalence to v19,134 normalized upstream/build source matches per applicable implementation, original controller/UI/global metrics and current source-level snapshot/restore-access inventory. Moderate confidence: search completeness within the retained local artifact set; missing-source reports cannot certify a pair. Unknown: exclusive distributed cost, exact fitted per-bank partition, net memory inference change, total incremental cost and future build/seed behavior. No hardware signoff, formal exhaustiveness or new timing coverage is claimed.

Preservation checks freeze **3,187 existing source/evidence files**, including the prior1,584-file consolidation ledger and both current-production build trees and relevant historical ledgers. Raw source/build hashes are retained in [preservation_before.json](preservation_before.json); [final verification](preservation_after.json) rechecks them, all local refs, HEAD, branch, tracked diff and index. Queries read existing Git objects and remote metadata only. No existing report/generator was rewritten or rerun. No RTL/candidate/IP/format/QSF/SDC/QIP changes, Quartus/simulator process, synthesis/fit/route/assembly/STA, checkout/reset/clean, commit/push/merge/PR or branch/index update occurred. New outputs are confined to this report directory.

Final `git diff --stat`:

```text
(empty)
```

Final `git status --short`:

```text
?? tests/
```

The tests tree was already untracked; ordinary diff statistics omit this documentation addition. Local HEAD remains `1b2a52d87d2659c908d4f9f846416d14bfd85bea`; branch remains `investigate/cram-memory-inference`. Upstream is the separately verified8443a0d commit, not this local branch.

## 10. Exactly one recommended next action

**Review and separately authorize the controlled current-production with/without-savestates measurement in section8 if a numerical total is required.** Do not implement an optimization or substitute v19 figures. The existing evidence answers direct allocation and identifies distributed mechanisms, but only a correctly scoped paired counterfactual can answer the total incremental question. Stop after this report and await review.
