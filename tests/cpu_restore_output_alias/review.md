# v19 CPU restore-output alias experiment

**REJECTED — PHYSICAL QUALIFICATION FAILED; PRODUCTION UNCHANGED.**

All 40 qualified functional cases passed. No production RTL, format, constraints, IP, branch, HEAD or index changed. The candidate is retained only as reproducible experiment evidence. No candidate is applied, so no production rollback is needed. The isolated source and reports are retained as rejected evidence; do not promote it.

## Baseline and provenance

HEAD `1b2a52d87d2659c908d4f9f846416d14bfd85bea`, branch `investigate/cram-memory-inference`, format v19/tag484313. The complete internal audit, all198 declaration records and its machine evidence were read before candidate generation. [provenance.json](provenance.json), [measured_baseline.json](measured_baseline.json) and [source_bridge.json](source_bridge.json) verify all204 tracked files, all137 retained build inputs and prior reports. Of those inputs,135 match committed HEAD with CRLF/LF normalization; two unused backup files are preserved. The retained v19 seed1 build is `tests/savestate_g08_fm/quartus_early`. Its historical manifest label is not used instead of actual source equality.

Baseline controller SHA256: `e8de50db09447138fc661205fb9edd178d45e691819a056bad87631ef3d76557`. Isolated candidate SHA256: `0d6a000152980f2bd64bce3b847c82dd5a5acfa9aa1a001527ada929189e774f`.

Quartus17.0.2 Build602 Lite; device5CSEBA6U23I7; SMS/sys_top; BUILD_DATE261025; unchanged constraints/IP, fit effort, packing/physical optimization and framebuffer settings. Fresh databases were used. Seed1 changes only `rtl/savestates.sv`; any second pair changes SEED to2 on both sides, with the same single RTL difference between them. All source/build hashes and functional-gate hashes are in the build input manifests.

## Exact change and consuming-edge proof

At [candidate/rtl/savestates.sv](candidate/rtl/savestates.sv): the z80_dir output declaration changes from reg to wire; `assign z80_dir = z80_snap;` is added after the snapshot declaration; the sole registered copy assignment at ST_LOAD_RESTORE is removed. The reverse transformation in source_bridge.js reproduces the exact baseline. All230 snapshot bits, NMI/restart history, z80_set, every other output, validation and transport remain unchanged. No bytes or compatibility support change.

[consumer_proof.md](consumer_proof.md) was established before candidate generation. SMS → system → T80s → T80/T80_Reg use the same host clock. T80's architectural/IFF/HALT readers require DIRSet; its only ungated payload reader is the combinational Alternate permutation into RegDIR. T80_Reg consumes that permutation only at rising Clk with DIRSet=1, regardless of CEN; normal register reads depend on stored state. No stateful reader observes DIR outside DIRSet.

At restore edge R, the baseline schedules its copy and strobe together by NBA; physical consumers see them at R+1. The snapshot has no writer in that state or its following CRAM/flush/private-preparation/release lifetime. Hence snapshot and baseline output are equal at every consuming edge, including a stalled receiving edge. Reset clears the strobe and changes neither data bank; even the reset-at-consuming-edge register-file case sees equal data. SAVE, partial LOAD, malformed metadata, repeated LOAD, stale responses and timeout/error paths may change only unused bus values before a new restore. Their gating and release paths remain identical.

Expected inactive differences: the alias follows SAVE capture and partial/private LOAD staging, while the original retains the last applied image or an unreset value. The unused RegDIR permutation can follow those differences. The miter counts these clocks explicitly (19,996,261); no consumed bit or CPU-state comparison is masked.

## Functional proof and qualified runs

[functional_gate.json](functional_gate.json) contains every qualified log hash, compiled controller/test/consumer source hash, fixture/image hash, parameter set and pass record. Every controller output except the inactive DIR payload is compared with four-state equality on every host edge. All230 DIR bits are compared whenever z80_set is consumed. A second real T80/T80_Reg or registered-ROM CPU machine consumes the alias; full architectural state, available private/NMI probes and native bus outputs are compared every clock through preparation, first execution and long suffixes. Original native reference/replay oracles remain. Common producer inputs are valid by induction: all shadow CPU outputs and controller controls match, closing the feedback loop; unchanged peripheral receivers see identical controls/data.

Totals: **91,413,628 host clocks; 209 consuming edges; 495,599 accepted DDR writes; 1,591,538 accepted DDR reads. Zero qualified mismatches, errors or missing terminal pass markers.**

| Coverage | Qualified evidence |
|---|---|
| SAVE bytes |16 complete96KiB profiles, 196,608 known64-bit words; every accepted address/data/BE/burst compared, including every image write;48 modern replays plus old64 System E fallback |
| Compatibility |22 LOADs: tags1–18, public96, public64, current before/after |
| Malformed metadata |321 unique late mutations, each after changed private CPU words, exactly once across8 shards; original rejection-before-guest-mutation oracle plus4 recovery LOADs per shard |
| Error/reset |Header and late-metadata watchdog expiration; successful recovery; asynchronous reset during private parsing |
| G01 |Ten registered-ROM prefix/ED/CB/DD/FD/EI/block/HALT/INT/NMI cases,3 LOADs from different live Q each, SAVE-only and long native reference suffixes |
| F16 |Eight reachable NMI triplets (000, 001, 010, 011, 100, 101, 110, 111), accepted-edge pulses and two GG ordering cases;3 replays each |
| G06/G10 |Real CPU/VDP bus activity, independent dual-VDP collision/history,13-LOAD release-phase sweep, random/long transport stalls, repeated deterministic suffixes, full900000-clock flush |
| Pause |All four saved/current Pause combinations, bounded coherent capture progress, stopped PSG during private preparation, exact resume and live SDRAM pin/accepted-transaction oracles |

Full image SHA256: `fdf869feb491797d055773220ad462df6abcd8f51673655fa9cbff43bf476f85`. Image/replay locations are retained per case in the ledger; images.hex contains all16 complete profiles. The identical accepted write stream proves full image-byte equality for common initial DDR contents, including unchanged/unwritten bytes. Transport-duration independence is also checked by the native repeated-replay oracles.

Simulation-only adaptations, shared by both versions: explicit VHDL entity binding; read-only observation ports; the retained zero-extension of the inherited block-IO mask for ModelSim width checking; current v19 input completion and expected writer tag; matching cooldown bypass; TB_FAST where selected. The full-flush case retains production timing. Malformed parser observers use a production-rate /15 CPU enable; all host-edge and consuming-edge checks remain. Source bridges independently match all six native consumer families to current production. No production CPU/RegDIR logic or test mask changes.

Unqualified preparation attempts are not counted: missing same-line port names in the initial generator, one wrong-working-directory compile, forward-declaration/parser corrections and the Pause sample-port completion. The optional exhaustive unrelated BG-position campaign was stopped in favor of the focused late-CPU-staging rejection set; its files remain. Rejection shards partition the complete focused321-case set, not a smaller subset; the final gate checks uniqueness/count. Initial serial attempts remain as artifacts. All existing tests/reports are preserved.

## Seed1 physical result

[candidate1_results.json](candidate1_results.json), [build_candidate1_inputs.json](build_candidate1_inputs.json), fitted register query and isolated map/fit/asm/STA logs retain the source-bound result.

| Metric | Baseline | Candidate | Delta |
|---|---:|---:|---:|
| Placed ALMs | 38,599 | 38,457 | -142 |
| Needed ALMs | 37,117 | 37,005 | -112 |
| Mapped FF | 46,327 | 46,097 | -230 |
| Fitted FF | 48,880 | 48,744 | -136 |
| Logic ALUT | 46,835 | 46,947 | +112 |
| Routing ALUT | 18,266 | 18,310 | +44 |
| M10K | 488 | 488 | 0 |
| Block memory bits | 3,818,050 | 3,818,050 | 0 |
| DSP | 39 | 39 | 0 |
| Recoverable ALMs | 2,055 | 2,060 | +5 |
| Unavailable ALMs | 573 | 608 | +35 |
| Setup ns | 0.104 | -0.714 | -0.818 |
| Hold ns | 0.239 | 0.241 | +0.002 |
| Reported violating groups | 0 | 1 | +1 |

Packing: baseline `38599 - 2055 + 573 = 37117`; candidate `38457 - 2060 + 608 = 37005`. Lower needed ALMs alone do not establish a placed saving.

Controller exclusive allocation: baseline 10647.6 placed / 10497.5 needed / 6966 ALUT / 14773 FF; candidate 10613.4 placed / 10443.7 needed / 7136 ALUT / 14539 FF. These fractional hierarchy allocations include cross-hierarchy packing and are not an isolated per-register ALM price.

Named CPU snapshot/output register families: 460 → 230 (230 fewer). Both families are counted because an output alias may rename the surviving snapshot. The full names and global/own FF deltas distinguish disappearance of the intended bank from unrelated physical duplication changes.

[register_delta.json](register_delta.json) reconciles the controller's fitted names exactly: z80_dir230 →0, z80_snap230 →230, and four fewer ddram_watchdog physical duplicates. Controller own FF14,773 →14,539 (−234); all other controller stems and the child timing-node count are unchanged. The remainder of the design gains98 fitted-register allocations, giving whole-design −234 +98 =−136. Thus the target230 disappear, but the whole fitted-FF reduction is not230; physical mapping/packing/duplication elsewhere offsets part of it. No new guest-state fields were introduced.

Final interconnect total average/peak: 49.7%/74% → 48.9%/77%. Full total/H/V and router-estimate rows are retained separately; they are not interchangeable metrics. Unique critical warnings: 38 → 39; new normalized critical messages: 1; new warning types: 332148. Existing unconstrained setup/hold categories are inherited; positive reported checks do not claim new constraint coverage.

The physical keep gate was deliberately conservative before fitting: intended230-register disappearance, lower placed ALMs, unchanged M10K, no growth in routing ALUT or total average/peak interconnect usage, positive setup/hold, zero reported violations and no new critical warning. Seed1 gate: **FAIL**.

The rejection does not depend on the conservative routing criteria: setup is negative and new critical warning332148 reports timing requirements not met. A read-only query of the completed netlist ([failure_setup.txt](failure_setup.txt), [core_setup.txt](core_setup.txt), [failure_paths.log](failure_paths.log)) locates the worst path in the unchanged HDMI hierarchy: shadowmask RAM ram_block5a0 → hdmi_osd h_cnt[2]~DUPLICATE, −0.714ns; relationship6.732ns, clock skew−0.692ns, data delay6.554ns. The HDMI clock group's TNS is−12.187ns; multiple paths fail, not only one path. The core PLL group remains positive at+0.716ns (baseline+0.895ns). The baseline global worst also belongs to shadowmask→HDMI OSD but has a different endpoint; those individual path delays are not treated as an isolated CPU-bank charge.

The router's preliminary estimated peak65% (baseline66%) differs from the final fitter total peak77% (baseline74%). The lower estimate cannot override the final routing/timing failure. Only this diagnostic read of the existing netlist followed rejection: no second fit, RTL change, constraint relaxation or alternate seed was attempted.

No second seed was run: the first physical gate failed. A different favorable unpaired seed was not substituted.

## Disposition and final repository state

**REJECTED — PHYSICAL QUALIFICATION FAILED; PRODUCTION UNCHANGED.** Failed criteria: positiveTiming, noViolations, noNewCritical, noRoutingALUTGrowth, noPeakRoutingGrowth. No expansion or further optimization was attempted.

Production remains byte-for-byte unchanged, including all204 tracked files, v19 format and all prior reports. The isolated candidate is evidence only. No commit, push, merge, checkout, reset, clean or PR. HEAD and the existing branch remain unchanged; the index is empty.

Final git diff --stat:

```text
(empty)
```

Final git status --short:

```text
?? tests/
```

The untracked tests tree predates this experiment. New artifacts are confined to tests/cpu_restore_output_alias/. Stop here; production application requires separate authorization.
