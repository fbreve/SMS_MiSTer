# PhaseMemory automatic RAM inference experiment

Date: 2026-10-29 (America/Sao_Paulo). Baseline: `8443a0d19a88aff7a5900011bccf386daf146945`. Branch: `experiment/phasememory-auto-inference`.

## Result and recommendation

The AUTO change is a measured whole-design area improvement for this matched seed-1 pair, with passing reported timing. Keep it experimental; a paired second seed and hardware validation are appropriate before production adoption.

Whole-design candidate minus fresh baseline: **-253 placed ALMs, -122 needed ALMs, -346 fitted registers, +1 M10K**. Setup/hold slack: **0.495/0.242 ns**, versus 0.508/0.144 ns. Setup/hold TNS: **0/0 ns**. These are measured implementation results, not estimates from the local bank. No RegisterMemory or other bank was changed or tested as an optimization.

## Scope and reproducibility

The sole production change removes `attribute ramstyle of phase_array : signal is "logic";` from [rtl/VM2413/phasememory.vhd](../../rtl/VM2413/phasememory.vhd), originally line52. The declaration and all functional RTL remain unchanged. [production.diff](production.diff) records the one-line deletion. No explicit M10K/MLAB attribute or inference-template rewrite was attempted: AUTO succeeded.

Fresh source-only A and B builds used Quartus Prime Lite **17.0.2 Build602**, device **5CSEBA6U23I7**, revision SMS, top sys_top, seed1, fixed BUILD_DATE261014, MISTER_FB=1, original QSF/QIP/SDC/IP and unchanged performance/packing settings. Both started without databases. Direct map/fit/asm/sta stages bypassed only the date-generating preflow. The source manifests hash all203 tracked file blobs; only PhaseMemory differs. See [input_manifest.json](input_manifest.json), [build.ps1](build.ps1), [workflow.log](workflow.log), and [reproduction instructions](reproduce.md).

The fresh A reproduces timing-history F **exactly for every compared global resource count and setup/hold slack**; [results.json](results.json) records zero deltas in baselineVsRetained. F was a control-reproduction reference; B was compared with the newly compiled A, not a substituted historical build. Identical metric endpoints do not imply identical timestamps/report bytes.

## Functional and mapped equivalence

| Evidence | Result | Recorded coverage |
| --- | --- | --- |
| [bank.log](bank.log) | PASS | ** Note: PASS bank equivalence: cycles=101458 checks=406112 unknown_reads=9 all18 read/write/collision addresses;18 payload bits;19 startup interruption cuts |
| [gate.log](gate.log) | PASS | ** Note: PASS mapped candidate vs RTL defined-state equivalence: cycles=101458 checks=406112 unknown_reads=9 all18 read/write/collision addresses;18 payload bits;19 startup interruption cuts |
| [fm.log](fm.log) | PASS | ** Note: PASS full OPLL: cycles=946616 known=946616 nonzero=882358 freeze_phases=1152 instruments=16 channels=9 rhythm_keys=32 reset_cuts=19 |
| [fm_gate.log](fm_gate.log) | PASS | ** Note: PASS full OPLL with mapped candidate PhaseMemory: cycles=946616 known=946616 nonzero=882358 freeze_phases=1152 instruments=16 channels=9 rhythm_keys=32 reset_cuts=19 |
| [savestate.log](savestate.log) | PASS | PASS savestate/FM paired regression cycles=8482683 audio_checks=8482683 outputs=58 operations=16 restored=8 DDRwrites=57580 DDRreads=57564 busy=218975 SMS/SystemE BIOS/cart slots0..3 |
| [savestate_gate_reference.log](savestate_gate_reference.log) | PASS | PASS savestate/FM mapped PhaseMemory regression cycles=2222128 audio_checks=2222128 paired_controllers=0 operations=4 restored=2 DDRwrites=14395 DDRreads=14391 busy=58305 SMS/SystemE BIOS/cart slots0..3 # Nonzero audio checks=56160 REF=1 |
| [savestate_gate.log](savestate_gate.log) | PASS | PASS savestate/FM mapped PhaseMemory regression cycles=2222128 audio_checks=2222128 paired_controllers=0 operations=4 restored=2 DDRwrites=14395 DDRreads=14391 busy=58305 SMS/SystemE BIOS/cart slots0..3 # Nonzero audio checks=56160 REF=0 |

The bank RTL comparison includes an independent old-data/one-clock-latency scoreboard. It checks all18 addresses, all18 payload bit positions, initialization write priority, output hold during reset and between clocks, repeated resets, short reset pulses, interruption after every0..18 startup writes, deterministic random traffic and same-address collisions. Original unknown startup values are checked exactly in RTL; they are not coerced to zero. The mapped comparison checks every baseline-defined value while allowing unspecified hardware power-up payload to differ.

The mapped model is Quartus's exported standalone synthesis functional netlist with bundled vendor RAM models, not a hand-written RAM substitute. Its top module is renamed only. The complete OPLL mapped test replaces only its PhaseMemory instance, leaving all other bank RTL unchanged, and compares audio every cycle. It exercises all16 instruments/nine channels, rhythm keys, irregular enables,1152 freeze-phase cases and19 reset interruption cuts. This is functional mapped simulation, not post-route timing simulation or a hardware test.

Eight RTL save/load cases compare all58 controller outputs and accepted DDR behavior, with CPU/VDP/PSG roundtrip assertions, both physical video owners, BIOS/cartridge slots and DDR backpressure. The mapped integration test uses a single real controller and two deterministic passes: record native OPLL audio, then replay the identical controller/DDR stimuli with mapped PhaseMemory and compare every sample. Its representatives are SMS/cartridge/slot0 and SystemE/BIOS/slot3 with stalls. FM is programmed and warmed before capture; nonzero-audio coverage is required. The native900,000-cycle load flush remains intact. Only the UI request cooldown is bypassed in the fixture.

ModelSim10.5b portability adapters are simulation-only and symmetric: scalar subtype ranges are expanded without changing bounds, missing std_logic meta-value cases get null branches, and two controller declarations move before their uses. Production/source-only Quartus builds use neither adapter. The unadapted bank test separately checks startup unknown semantics.

Preliminary fixture diagnostics are retained: the initial DDR busy cadence starved the controller's intentional32-idle-clock drain; the first DDR mock omitted BIOS slots; oracle checking needed a continuous-assignment delta-cycle correction and an explicit warmup before the first freeze. These were testbench defects, not candidate failures. Final traces/logs above supersede those attempts. Capacity-limited interrupted ModelSim runs are not counted as passes.

This baseline has no complete serialized OPLL history interface. Preserving its behavior does not fix or prove stronger exact-FM savestate behavior introduced on later branches. The verified result is no new difference in the tested baseline execution/save-load scenarios; v19 hooks and format are not imported.

## Memory inference and local allocation

A explicitly reports four uninferred FM RAMs due to the logic attribute. B reports three: OutputMemory, FeedbackMemory and RegisterMemory remain unchanged. B adds **18×18=324 configured bits** as `phase_array_rtl_0`, simple dual-port, same clock. The inferred parameters retain **OLD_DATA** for mixed-port read/write collisions. Registered addressing/enable logic implements the original one-clock read and reset hold; interpreting OUTDATA_REG=UNREGISTERED alone as an asynchronous RTL interface would be incorrect. Mapped simulations independently validate the resulting latency/hold behavior.

| PhaseMemory fitted allocation | A | B |
| --- | ---: | ---: |
| Needed ALMs | 123.6 (123.6) | 15.2 (15.2) |
| Placed ALMs | 235.0 (235.0) | 15.7 (15.7) |
| Dedicated FF | 349 (349) | 6 (6) |
| Configured memory bits | 0 | 324 |
| M10Ks | 0 | 1 |

The whole-design mapped-register delta is-342;324 payload bits plus18 read-output registers leave ordinary FF implementation. Fitted FF changes also include physical transformations elsewhere. Fractional local ALMs are hierarchy allocations, not a separately removable whole-chip delta. The local experiment export is not used as the whole-design resource result.

## Whole-design Quartus A/B

| Metric | Fresh baseline | AUTO candidate | Candidate − baseline |
| --- | ---: | ---: | ---: |
| Needed ALMs | 26465 | 26343 | -122 |
| Placed ALMs | 31531 | 31278 | -253 |
| Mapped registers | 34857 | 34515 | -342 |
| Fitted registers | 35709 | 35363 | -346 |
| Logic ALUTs | 37056 | 36917 | -139 |
| Routing ALUTs | 13159 | 12968 | -191 |
| M10Ks | 487 | 488 | +1 |
| MLAB cells | 0 | 0 | +0 |
| MLAB memory bits | 0 | 0 | +0 |
| Logical memory bits | 3809858 | 3810182 | +324 |
| DSPs | 39 | 39 | +0 |
| Setup slack (ns) | 0.508 | 0.495 | -0.013 |
| Hold slack (ns) | 0.144 | 0.242 | +0.098 |


Reported setup TNS A/B: 0/0 ns; hold TNS A/B: 0/0 ns. Per-clock setup/hold slack and TNS are retained in [timing_table.md](timing_table.md). The original full STA summaries and reports remain under baseline/output_files and candidate/output_files. Inherited unconstrained categories remain: A setup, hold, B setup, hold. Passing reported slack is not fully constrained hardware signoff.

M10K utilization is487/553 → 488/553; nominal free blocks66 → 65. MLAB memory bits0 → 0; DSP blocks39 → 39. No MLAB alternative was attempted. The additional324 logical bits are the same phase payload moved into hard memory, not a change in functional state size or save format.

Routing ALUTs13159 → 12968. Final interconnect rows:

```text
A:
; Average interconnect usage (total/H/V)                      ; 28.9% / 29.0% / 28.7% ;       ;
; Peak interconnect usage (total/H/V)                         ; 53.7% / 54.6% / 56.4% ;       ;
B:
; Average interconnect usage (total/H/V)                      ; 29.3% / 29.1% / 30.0% ;       ;
; Peak interconnect usage (total/H/V)                         ; 49.2% / 48.9% / 59.2% ;       ;
```

Detailed routing-resource rows, warning ledgers, full timing groups, fitted PhaseMemory rows, inferred RAM parameters and report hashes are in [results.json](results.json). Normalized warning messages added/removed: 0/0; the ledgers are unchanged after normalizing build-directory paths. Global physical remapping can move allocation and routing in unchanged modules; local bank savings must not be substituted for these whole-design deltas. Placed area falls253 ALMs (about0.80%), but setup margin falls13ps and average interconnect use rises0.4 percentage points. Peak total/H utilization falls while peak V rises. This is a modest, mixed physical result, not a universal routing/timing improvement.

## Supplemental path queries and tooling limitation

The global setup limiter remains in the scaler: A line-store write-enable → inner vertical-pixel register, B line-store write-enable → outer vertical-pixel register. A's worst hold is scaler phase-pipeline state; B's is the savestate controller's nvram_load_addr[2] self path. Neither setup limit is in PhaseMemory. [path_results.json](path_results.json) retains exact endpoints and the source report names.

| Restricted register-path setup slack (ns) | A | B |
| --- | ---: | ---: |
| From FM | 5.49 | 5.544 |
| To FM | 2.436 | 2.129 |
| From PhaseMemory | 12.612 | 12.231 |
| To PhaseMemory | 7.369 | 9.388 |

These are bounded register-collection queries at the default reported slow1100mV100C corner, not identical endpoint pairs or replacements for full STA. Memory-port sequential nodes in get_registers are not the fitted dedicated-FF accounting column.

The first supplemental candidate query completed its global setup/hold reports, then Quartus17.0.2 crashed while expanding get_keepers wildcards. [candidate_paths.log](candidate_paths.log) retains the access violation in sta_find_duplicates_of_deleted_net_name / add_keeper_to_vector_if_wildcard_matches. This happened after the successful full map/fit/asm/sta compilation. No synthesis settings or RTL were changed to address it. A narrower get_registers query then completed for both builds with zero errors/warnings, retaining the local paths above. [register_paths.tcl](register_paths.tcl) and [query_register_paths.ps1](query_register_paths.ps1) reproduce that successful query. The crashed keeper query is diagnostic evidence, not a pass or a failed full compilation.

## Repository state and stopping point

Protected refs are unchanged: master8443a0d, investigate/synthesis-structure8443a0d, investigate/cram-memory-inference1b2a52d. The experimental branch still has baseline HEAD and the one-line uncommitted RTL deletion. Existing audit/report hashes checked by [preservation_before.json](preservation_before.json) remain unchanged. New supporting scripts, logs and reports are under this directory; databases/build trees are ignored and unstaged. No commit, merge, push or PR was made. No other bank or second seed was attempted. Stop here for review; any further experiment or adoption requires separate authorization.
