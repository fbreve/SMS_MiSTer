# F14 Evolution selector/history fix

**READY TO COMMIT.** F14 only, branch `fix/savestate-evolution-selector`, based on committed F13 `eede89d`. 64 canonical simulation logs pass; the full Quartus compile completes with 0 timing-summary violations and 0 new distinct warnings. Nothing staged, committed, pushed, or published.

## Correctness and implementation (items 1–9)

1. **Root cause:** v9 saved mutable guest port61/62 but omitted active/previous/candidate history and first-launch history. LOAD substituted ports into active/candidate state, zeroed predecessors, and derived started from mode bits. Distinct reachable states therefore resumed through different Flash pages. The authoritative [investigation](../savestate_evolution_selector/review.md) was read before production edits; it was not repeated from scratch.

2. **Exact 57 bits:** payload [15:0] active game `{game62,game61}`; [31:16] previous game; [39:32] candidate61; [55:40] prior candidate `{prior62,prior61}`; [56] `game_started`. Candidate62 is restored from existing saved bank62, following the proved reset/OUT62 invariant. This preserves raw selector/history values rather than the optional predicate compression discussed in the investigation.

3. **Host boundary:** port61/62 and board menu registers are CPU-written **emulated** latches, including guest BIOS/menu writes. They and their execution history restore from T. Current raw host configuration and media remain external. The T80 test changes the external CPU-enable ordinary/turbo selection from period15 to period10 after SAVE and asserts host B remains current after LOAD; byte/address/history restore independently. It models the production CE ratio, not the entire HPS menu subsystem. Fixed Evolution media/enable is maintained throughout.

4. **Pre-fix proof:** four baseline fixtures execute committed-F13 production source. The strongest pair has identical mapper `0000000102038700` and 96-bit Evolution representation `8700000000000000E1320048`, but previous game2800 versus2400. Its fallback read at CPU8123 addresses Flash288123 versus488123. Pre-fix LOAD clears the distinguishing history. The retained prior real-T80 evidence showed byte28 before LOAD and48 after.

5. **Architecture:** reuse existing live Evolution registers, widen the existing transport to160 bits, and capture/restore exact bits[152:96] alongside the unchanged low96. Candidate62 uses saved port62. The existing ARM capture and mapper-before-CPU restore ordering are retained. No F15 pending-state capture/restore mechanism is added. Four new FSM states95–98 fit the existing seven-bit state register. DDR request preview and sequential acceptance routes match under stalls. [design.md](design.md) gives the complete contract.

6. **Production files:** [evolution_mapper.vhd](../../rtl/evolution_mapper.vhd) exports/restores the57 bits; [system.vhd](../../rtl/system.vhd) widens input transport and explicitly retains the detector's original low96-bit view; [SMS.sv](../../SMS.sv) carries160 bits both ways; [savestates.sv](../../rtl/savestates.sv) implements validated storage, version inheritance and rejection. Detection, bank control, Flash decoder and all other production files remain unchanged. Test/evidence additions are isolated here.

7. **v10 layout:** word01A marker `48430A`, count3, unchanged HCounter/video bit meanings. Word02C contains the57 bits above with [63:57]=0. Word02D is exact `0000003945563130`: width57 and owner ASCII `EV10`. Low96 Evolution data remains in019/01B and existing mapper word00F. Every prior payload location and serialized write expression remains unchanged. Slot stride/size and RAM regions are unchanged; no overlap with F13 words02A/02B or EEPROM beginning030/040.

8. **Validation:** exact v10 marker/count, E132 Evolution ownership, all seven zero padding bits, and full width/owner descriptor. Presence/validity resets per LOAD. A valid extension cannot inherit a previous LOAD's validation. Unsupported new metadata is discarded to zero for non-Evolution owners; their old extension compatibility remains intact. Bad F13 metadata still normalizes its history independently, even when F14 is valid.

9. **Legacy policy:** follow the investigation's explicit recommendation: untagged/v1–v9, unknown/future versions, oldest64K, missing owner or malformed v10 **Evolution** snapshots are rejected through existing ST_ERROR before CPU/mapper/peripheral/memory restore writes. No history is invented, and post-save state is not presented as a successful old restore. A rejected operation leaves the running machine in place after its ordinary capture pause. This uses the existing error/idle path, with no new UI-specific notification. Early lightgun clear is deferred for current Evolution until compatibility is known; valid v10 reaches ordinary later gun restore. Other mapper legacy behavior is preserved.

## Dynamic results (items 10–21)

10. **Pair after fix:** two actual SAVE operations retain identical old words and write different02C values: A=`0128000028004800`, B=`0124000024004800`. LOAD B matches its uninterrupted peer at Flash488123/data48; LOAD A matches its reference at288123/data28. This directly demonstrates why additional state is necessary.

11. **Real T80:** production T80/T80s and video timing, full CPU DIR restore, actual OUT61/62, completed3FFE switches, LD A,(8123), and OUT20. Before and after LOAD: CPU8123, Flash288123, DI28, game4800, previous2800. Host turbo B remains1. The former28/48 divergence is eliminated. The synthetic guest is mirrored across Flash pages so instructions remain executable; no commercial-ROM or pixel correctness claim is made.

12. **Reference replay:** naturally reached P, accepted T, post-save Q, LOAD, identical S. All active/candidate/history state (via the full exported payload), mapper word, Flash address, data byte and launch pulse match the uninterrupted reference for the first replay. No selector registers are forced. The only force bypasses the host UI operation cooldown. Focused ordinary Sega banks stay00/01/02/03, for which relative ROM address equals CPU A belowC000; an independent production bank-controller regression covers bank restoration/launch reset.

13. **Repeated LOAD:** every current selector test uses three different Q histories (selectors6000,9440,2180, different mode/8C writes), then restores the same T and compares the complete next-clock trajectory against the first replay. 110 directed LOADs in total, including separate pair-B restores. Exact exported state is checked on the restore edge and before S. Q does not leak backward.

14. **Boundary coverage:** 15 original boundary histories (initial, first, same, alternating, adjacent, nonadjacent, before/after candidate update, multiple transitions, menu/record path);16 additional walking/complement byte-pattern histories;5 DDR-stall runs. Total36 scenario runs,31 distinct prefixes. All57 bits occur as both zero and one; an independent numeric oracle checks every patterned saved field. 148 accepted directed operations, 1,076,601 clock-state comparisons. Stall fixtures vary BUSY acceptance and response latency without blocking the production quiet-drain window.

15. **Menu/config perturbation:** saved guest selectors and board latches return to T after differing Q values; current external turbo choice remains B in the actual CPU/CE test. No newly serialized value is sourced from current menu latches during LOAD. Media identity/mapper enable remains fixed as required by the correctness contract.

16. **F15 isolation:** each F14 T follows both required falling-M1 switch stages; no pending switch, record read, menu launch operation or launch pulse remains in flight. The source audit verifies every assignment to pending/armed/read/edge sampler/launch pulse fields is unchanged. The completed-record test masks fallback history as expected. These results do not close F15 around a pending operation.

17. **SAVE-only:** uninterrupted reference comparisons pass throughout every save transport and subsequent probe. Exported selector/history/mapper/address values and launch pulses remain equivalent. The actual CPU test also reads28 after SAVE before LOAD. The first-launch menu test restores started0 and reproduces the next launch pulse on each LOAD.

18. **Evolution/mapper regressions:** committed-F13 four-case negative baseline; current history matrix (reset, same/alternating/adjacent/nonadjacent, menu return/re-entry and record override); existing directed bank mapper restore/launch priorities, generic BIOS handoff/frozen handoff/restore-edge suppression, System E mapper layout, and two F13 history/deadline repeated-load cases: PASS. No standalone old Evolution Flash/BIOS test existed beyond these; the production-module matrix and T80 test supply that coverage. The existing directed banking adapter excludes the already-documented stale historical random oracle; no new random-differential claim is made.

19. **Broader regressions:** F07 controller10 cases and integrated dual VDP; F02 GG direct and DDR14 cases; F08 MD6 real80540 timeout/160 snapshots; F09 Master Tap4096 state/pin cases; F10 Paddle896 cases; F11 ordinary1M cycles/32k held observations and two18-case format/stall matrices; F12 paused System E actual CPU/PSG2,552,454 comparisons; F13 mapper history and deadline replay; EEPROM6642 direct operations,24 DDR cases and persistence; SC RAM60 DDR cases across2/16/32KiB; PSG128 snapshots ×20k future ticks: PASS. Separate format matrices cover30 Evolution validation cases (27 rejects,3 valid loads) and30 non-Evolution cases through v10, including untagged/old64K/v1–v9, future11, bad/padding metadata and previous GG/MD/Tap/Paddle/gun/F13 values.

20. **F06:** unresolved and intentionally untouched; no cartridge-RAM ownership fix is claimed.

21. **F15–F16:** untouched. No unrelated Evolution refactor, new pending-operation fields or format consolidation.

## Quartus and resources (items 22–32)

22. **Build:** full Quartus Prime Lite17.0.2 compile, CycloneV5CSEBA6U23I7; synthesis, fitter, assembler and timing analyzer successful. Baseline is the retained committed-F13 full build, verified against134 tracked manifest inputs and two unused manifest-only backups. Framework, build ID, constraints and device are retained; no compilation database was copied. Final source hashes match both workspace and compiled candidate. An early elaboration run was interrupted to correct the detector bus slice; its partial log is isolated under exploratory/. Only the completed final run supplies the results below.

23. **Worst timing:** setup **0.582 ns**, hold **0.232 ns**; baseline0.435/0.202 ns.

24. **Violations:** 0 negative-slack/TNS timing-summary groups; all reported summary groups are included in results.json. Existing baseline unconstrained-path/clock warnings remain part of the warning comparison, not a new claim of complete timing constraint coverage.

25–30. **Absolute utilization and deltas versus F13:**

| Resource | Used / device capacity | Utilization | Delta |
|---|---:|---:|---:|
| ALMs needed | 27,920 / 41,910 | 66.619% | +561 |
| ALMs used in final placement | 32,961 / 41,910 | 78.647% | +372 |
| Total fitted registers | 36,959 / 167,640 | 22.047% | +196 |
| M10K blocks | 487 / 553 | 88.065% | 0 |
| Block-memory bits | 3,809,858 / 5,662,720 | 67.280% | 0 |
| DSP blocks | 39 / 112 | 34.821% | 0 |

ALMs needed are logical demand; ALMs used in final placement are physical placed occupancy, before the fitter's recoverable-packing estimate. Baseline needed27,359 and placed32,589 are distinct. Register denominator167,640 is the device's83,820 primary +83,820 secondary core-ALM register positions from the Fitter report. Quartus total fitted registers includes I/O FFs as well: candidate dedicated logic36,858 plus I/O101 equals36,959. The table ratio uses core-register capacity, not a separately reported total including every I/O storage element; the dedicated-logic-only ratio is21.986%. M10K bit capacity is5,662,720 bits (553 ×10,240); occupied blocks and used bits measure different packing constraints.

31. **Constraint pressure:** M10K is still the highest utilized of the requested ALM/register/M10K/DSP capacities. The fitter also reports3,994 /4,191 LABs partially or completely occupied (95.299%). That LAB occupancy can exceed M10K percentage because partially occupied LABs count as used; it is distinct from placed-ALM pressure and does not imply that all ALMs in those LABs are occupied. Do not reduce FPGA utilization to a single percentage.

32. **Warnings:** 0 new distinct normalized warning types / critical warnings. Baseline distinct84, candidate84; baseline critical38, candidate critical38; Quartus full-compilation total100. The only changed warning text is12241's hierarchy count, improved from20 to19. That count is normalized for type comparison and recorded separately, not classified as a new warning. Other normalization removes source-path/line shifts. Exact counts/differences are retained in results.json. Simulation-only warnings include pre-reset T80 unknown GPR operands, unconnected unused fixture outputs, width extension in old non-Evolution adapters, and Starter Edition capacity notices; all asserted guest/data fields are known and all canonical logs have zero errors.

### Resource sanity analysis

Synthesis registers: 35,877 vs35,757 (+120). The new payload adds57 bits each to the existing snapshot and restore-output banks:114 logical FFs, plus validation/FSM control. Existing live Evolution registers are reused. Payload mux/validation and restore distribution add logic; no new RAM or DSP backing is allocated. The fitted-register ledger reconciles exactly to+196 across the whole design, rather than attributing every fitted change to the57-bit payload. Physical retiming/secondary register/packing effects can change unchanged entities.

| Entity (largest own-register changes) | F13 | F14 | Delta |
|---|---:|---:|---:|
|  / sys_top / emu:emu / savestates:savestates_inst | 4704 | 4823 | +119 |
|  / sys_top / ascal:ascal | 4108 | 4135 | +27 |
|  / sys_top / emu:emu / system:system / vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst | 2742 | 2760 | +18 |
|  / sys_top / emu:emu / system:system / vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst | 2777 | 2793 | +16 |
|  / sys_top / osd:vga_osd | 610 | 625 | +15 |
|  / sys_top / emu:emu / hps_io:hps_io / video_calc:video_calc | 659 | 670 | +11 |
|  / sys_top / emu:emu / system:system / T80s:z80_inst / T80:u0 | 254 | 265 | +11 |
|  / sys_top / emu:emu / video_mixer:video_mixer / scandoubler:sd / Hq2x:Hq2x | 654 | 665 | +11 |
|  / sys_top / alsa:alsa | 551 | 543 | -8 |
|  / sys_top / emu:emu / system:system / vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_background:vdp_bg_inst | 161 | 153 | -8 |

The complete per-entity ledger and synthesis/fitter reconciliation are in [resource_analysis.json](resource_analysis.json). Register growth follows the expected snapshot/output-bank structure; no RAM or DSP allocation was added.
The larger-than-initially-expected ALM increase was investigated before declaring ready. The new 57-bit snapshot path is an 11:1 state/hold/data mux in Quartus's Multiplexer Restructuring report (evolution_snap[143]), estimated at 399 LEs. This is an area estimate in the mux report, **not 399 ALMs**. Widening the existing partially written snapshot inherits its FSM mux structure; the cost includes payload muxing plus validation/control logic rather than only 57 storage bits.

The synthesis controller rises from 5,212 to 5,861 combinational ALUTs (+649) and 4,701 to 4,821 registers (+120). The Evolution mapper itself keeps 175 registers and rises from 62 to 66 synthesized ALUTs. No further live-state register bank is duplicated. After physical optimization the controller owns 1,024 more ALUTs and 373.2 more needed ALMs; the rest of the whole-design needed-ALM increase is 187.8 across other physical packing/optimization changes. Controller fitted FF growth is 119; other entities sum to 77, reconciling 196 total.

The global accounting is exact: placed ALMs 32,589→32,961 (+372), estimated recoverable ALMs 5,529→5,339 (-190), unavailable ALMs 299→298 (-1). Therefore needed-ALM delta = 372 -(-190) +(-1) = 561. Routing ALUTs actually decrease 13,312→13,162 (-150), while logic ALUTs rise 38,122→39,287 (+1,165). This quantifies the snapshot-mux and physical mapping cost, rather than labeling all 561 ALMs as new stored bits. The cost is material but understood; full placement/timing pass with the utilization above, and no unrelated optimization was performed.

## Repository state (items 33–35)

33. `git diff --stat`:

```text
 SMS.sv                   |   2 +-
 rtl/evolution_mapper.vhd |  29 +++++++-----
 rtl/savestates.sv        | 119 +++++++++++++++++++++++++++++++++++++----------
 rtl/system.vhd           |   4 +-
 4 files changed, 114 insertions(+), 40 deletions(-)
```

34. `git status --short`:

```text
 M SMS.sv
 M rtl/evolution_mapper.vhd
 M rtl/savestates.sv
 M rtl/system.vhd
?? tests/
```

The untracked tests/ directory already held prior evidence; this task adds tests/savestate_evolution_selector_fix. Nothing is staged. The isolated candidate build is retained as evidence; generated ModelSim libraries/transcripts/waves are removed. No generated Quartus artifacts are staged. No commit, push or PR was made.

35. **READY TO COMMIT:** exact saved-time57-bit state is restored; the v9 collision is distinguished by v10; real T80 byte28/48 divergence is eliminated; menu/host boundary and three-load determinism pass; metadata and legacy rejection are validated; F13 remains intact; all required simulations and full FPGA checks pass. F06 and F15–F16 remain unresolved/outside this fix as stated above.
