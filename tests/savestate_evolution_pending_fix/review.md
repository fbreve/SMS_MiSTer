# F15 Evolution pending-operation savestate fix

**READY TO COMMIT.** All95 canonical simulation logs and the full Quartus compile pass, with0 reported timing violations and0 new distinct warnings. Branch `fix/savestate-evolution-pending`, committed F14 baseline `ff9d66b`. No staging, commit, push or PR. F06 remains unresolved; F16 is untouched.

## Correctness and architecture (items1–13)

1. **Root cause:** v10 restored the command byte and57 F14 history bits but cleared three independently future-relevant protocol flags. The next guest fetch/data read/game commit therefore lost an armed switch, recognized record read or launch bank reset. The complete [investigation](../savestate_evolution_pending/review.md) was read before production edits; its stronger full-T80 collision proof was neither established nor required for this confirmed replay defect.

2. **Preserved state:** reset-zero `switch_armed`1 bit, `record_read_pending_r`1 bit and `menu_launch_armed_r`1 bit. First post-command falling M1 arms the switch; the next consumes it. Menu-context1380 fetch recognizes a pending data read; qualifying non-M1 MREQ/RD read consumes it and sets menu arm. A later game commit consumes menu arm and resets banks even when started=1. All seven nonzero flag combinations and the distinct committed-game record transition are covered.

3. **Excluded:** switch_pending is consumed before production T80's accepted MREQ-low fetch CE and restores0. Launch is a consumed one-clock pulse, not an outstanding saved operation. Old-M1 is reconstructed as the restored T80 fetch level0. Existing pending command8 and all57 F14 bits keep their locations and meanings. No new live architectural registers are added.

4–7. **Pre-fix reruns:** frozen committed-F14 models under baseline/ reproduce armed switch288123/28→008123/00; actual T80 before28/restored00 on three LOADs; record read288123/28→488123/48; launch-reset288123/28→2A0123/2A. These expected-defect tests complete before production edits and remain reproducible. The production T80 witness is synthetic mirrored code with known bus/data, not a commercial game or pixel validation claim.

8–10. **Architecture:** serialize exactly the three accepted flags through existing160-bit Evolution transport and apply them at the existing mapper-before-CPU restore point. No unique reconstruction rule is established. Waiting for menu arm/read-pending to clear can wait forever, so no unproved deferral or guest-state change is used to avoid serialization.

Implementation timing validation exposed a necessary direct dependency: with serialization alone, T80 DIRSet forced M1 low after the mapper had sampled Q's high M1, consuming restored armed state **during freeze at000D**. Mirrored ROM still returned28, so byte equality alone masked early execution. A new permanent launch timing/count assertion reproduced that failure. The final fix connects existing ss_freeze to Evolution, holds ordinary bus observation while frozen, and initializes old-M1 to0 on restore. Reset/restore retain priority; launch remains an unconditional one-clock pulse. T80 restart is not mistaken for the next guest opcode. SAVE-only is checked again with the production freeze connection. This dependency is scoped to F15 capture/restore coherence; F14 history is not redesigned.

11–12. **v11 layout:** video word01A marker48430B/count3; previous video bit meanings unchanged. Word02C bits[56:0] remain the57 F14 bits; bit57 armed,58 record-read-pending,59 menu-launch-armed; bits[63:60] must be0. Word02D exact descriptor `0000003C45563131` (width60, owner EV11). Evolution transport maps these to153/154/155 and zeros159:156. No new DDR words, slot/stride changes, FSM states or wider buses. Old96 and every earlier payload write remain unchanged; both DDR preview and accepted-write paths use the same new60-bit packing.

13. **Legacy:** unsupported Evolution untagged/v1-v10/old64K and malformed v11 are rejected before CPU/peripheral/memory/mapper restore writes. A stale command is not a phase-valid flag. Idle normalization is deterministic but proven inexact, so it is not presented as exact restoration. Current Q flags are not imported into old T. Non-Evolution compatibility retains v1-v10 inheritance and recognizes current v11; its irrelevant Evolution extension normalizes to0. This follows the investigation's safe exactness policy. No arbitrary legacy padding becomes protocol state.

## Replay and regressions (items14–27)

14–17. Armed, record-read, launch-reset and real T80 post-fix equality are asserted, including every pending flag, F14 state, banks, Flash address and guest byte. Each directed suffix compares all254 observed bits every host clock to the independently recorded save-only reference, and every later LOAD trajectory to the first restored trajectory. The real CPU must launch at target0020 while not frozen and exactly once after an uncommitted snapshot, zero times after a completed snapshot. Its required result is28/28, not merely restored internal equality.

The strongest actual SAVE is accepted at cycle657511, CPU000D, M1/MREQ/RD low, WR high, pending0/armed1/read0/menu0, command87, mode00 and ports0028. After LOAD, launch occurs on the guest target fetch0020 rather than during freeze at000D; the subsequent CPU8123 data read addresses Flash288123 and returns28 on each replay. The pre-fix same snapshot reads008123/00. [boundaries.md](boundaries.md) records the requested/accepted cycles for the expanded sweep; [simulation_results.json](simulation_results.json) hashes the95 canonical passing logs. Unused T80 GPRs start unknown in the established simulation fixture, but every asserted bus/address/command/guest-data value is known.

18. Expanded CPU sweep:18 request offsets `-1,0,1,14,28,29,30,31,42,43,44,45,46,59,74,89,149,209`; actual SAVE input pulse and accepted cycles/bus/protocol are logged separately. Eight directed accepted prefixes cover armed/read/menu transitions, combinations and game-view recognition. These primary replay fixtures have26 SAVEs/60 LOADs. An additional current-host-turbo case and two packet-pair SAVEs bring total F15 validation to29 SAVEs/63 LOADs. Acceptance conditions and capture timing are not changed. The v11 pair images differ only at02C bit59, distinguishing the former v10 mapper projection collision without asserting a stronger full-T80 proof.

19–20. Each directed snapshot is loaded five times after Q that completes old activity, initiates97, performs a different menu record read2100, changes selector9440/port8C/commandC7, or returns to menu idle. Saved-time F15/F14/bank state restores, and all next-clock trajectories match reference. The strongest real CPU snapshot repeats LOAD three times; launch counting forbids lost or duplicated execution. Remaining CPU sweep snapshots each have one LOAD. Q disappears completely.

21. SAVE-only: each directed SAVE and subsequent S matches an uninterrupted bus-driven peer. A separate uninterrupted real-T80 run and armed SAVE-only run compare all78 executing CPU-enable samples, including bus, available architecture, Evolution160, phase flags, banks/Flash and data; host transport duration is excluded. The freeze guard does not force pending operations to complete or discard them during capture.

22–24. F13 detector/history/deadline replay and directed mapper restore/banking/BIOS/SystemE priorities are retained. F14's31 prefixes plus5 stall cases exercise all57 bits as0 and1, three Q histories and repeated LOAD; its actual T80 before28/restored28 case retains current external turbo B. Evolution history/address/record overrides remain covered. F13/mapper_ctrl/address decoder/SMS source are unchanged. Focused Evolution fixtures use a fixed valid F13 history; the independent production detector regressions verify its restoration. No full CRC-download boot or full-T80 non-injective pair is claimed.

25. Broader matrix includes F07 controller/dual VDP integration; GG direct/DDR; MD6 real T80; Master Tap; Paddle; Lightgun direct and two format/stall matrices; SystemE Pause actual CPU/PSG; EEPROM direct/24 DDR/persistence; SC RAM60 DDR cases across2/16/32KiB; PSG128 snapshots ×20k future ticks. Format matrices run31 Evolution cases at two stall settings, each25 rejections and6 accepted loads; all four padding bits and phase-bit values are covered. Thirty non-Evolution compatibility cases include a v10 tag with old EV10 descriptor and earlier controller payloads.

26–27. F06 remains intentionally unresolved. F16 remains untouched. No unrelated Evolution refactor or F01–F14 fix was undertaken. Existing test assertions are preserved except required current-version expectations; old evidence is not overwritten.

## FPGA validation and repository state (items28–41)

28. **Full build:** Quartus Prime Lite17.0.2, CycloneV5CSEBA6U23I7, seed1; synthesis, fitter, assembly and TimeQuest successful. Completed2026-10-22 00:17:22 local, elapsed17:46. The F14 source manifest was checked against134 committed inputs and two unused manifest-only backups. Framework, device, constraints and build ID remain those of F14; no compilation database was copied. Final source hashes match the tested workspace and compiled candidate.

29–30. **Worst setup0.358ns; worst hold0.203ns;0 timing-summary violations.** F14 baseline0.582/0.232ns. All reported groups have nonnegative slack and TNS0. Baseline unconstrained-path/clock warnings remain; this is not a new assertion of complete timing-constraint coverage.

31–36. Absolute resource usage and deltas against F14:

| Resource | Used / capacity | Percentage | Delta |
|---|---:|---:|---:|
| ALMs needed | 27,388 /41,910 | 65.350% | -532 |
| ALMs placed | 32,692 /41,910 | 78.005% | -269 |
| Total fitted registers | 36,816 /167,640 | 21.961% | -143 |
| M10K blocks | 487 /553 | 88.065% | 0 |
| Memory bits | 3,809,858 /5,662,720 | 67.280% | 0 |
| DSP blocks | 39 /112 | 34.821% | 0 |

Needed ALMs measure logical demand after packing estimates; placed ALMs count actual physical placement. These are distinct. The requested register denominator is83,820 primary plus83,820 secondary core-ALM positions; the total fitted count includes36,715 dedicated logic FFs plus101 I/O FFs, so it is not a separate all-I/O-inclusive device capacity.

**Resource sanity:** synthesized registers35,883 versus35,877, exactly+6: three bits in the existing snapshot bank and three in the restore-output bank. Evolution live state stays175 registers. Its synthesized ALUT count is62 versus66; the controller has4,827 FFs versus4,821 and5,346 ALUTs versus5,861. There is no duplicated live flag bank, added RAM or DSP. The existing11:1 snapshot mux widens57→60 bits; Quartus estimates399→420 **LEs**, not ALMs.

The fitted controller owns4,829 FFs versus4,823 (+6); other entities sum-149, reconciling the total-143. Largest other changes include second-VDP sprites-51, scaler-36, Hq2x-21, top+17 and hps_io+14, reflecting physical optimization/retiming in unchanged entities rather than removed emulated state. [resource_analysis.json](resource_analysis.json) contains the complete per-entity ledger. Controller fitted ALUTs fall6,336→5,505 (-831); its needed-ALM contribution falls267.5, with the rest of the whole-design reduction264.5 across physical mapping/packing. No unrelated optimization was performed; these are observed mappings, not a claim that storing three flags intrinsically saves532 ALMs.

Whole-design packing reconciles exactly: placed-269, recoverable+262, unavailable-1; needed delta=-269-262-1=-532. Logic ALUTs39,287→38,357 (-930); route-through ALUTs13,162→13,574 (+412). This distinguishes the small logical storage addition from global fitter differences. There is no large ALM increase to explain away.

37. **M10K remains the most constrained requested resource** at88.065%. The fitter separately reports3,964/4,191 LABs partially or completely occupied (94.584%); counting partially filled LABs is distinct from ALM placement, so that metric can exceed M10K's percentage.

38. **Warnings:**0 new distinct normalized warnings or critical warnings. Both builds have84 distinct warning messages, including38 critical; full compile total100. Connectivity warning12241 reports19 hierarchies in each, and no added/removed connectivity-report hierarchy. Source path/line changes are normalized consistently. Simulation warnings include unused fixture outputs, established width adaptation, ModelSim Starter capacity notices and initial unknown unused T80 GPRs; all asserted guest/bus/data values are known. Expected exploratory harness failures are excluded from canonical passing logs and documented in README.

39. `git diff --stat`:

```text
 rtl/evolution_mapper.vhd | 20 +++++++++++++-------
 rtl/savestates.sv        | 47 ++++++++++++++++++++++++-----------------------
 rtl/system.vhd           |  1 +
 3 files changed, 38 insertions(+), 30 deletions(-)
```

40. `git status --short`:

```text
 M rtl/evolution_mapper.vhd
 M rtl/savestates.sv
 M rtl/system.vhd
?? tests/
```

The untracked tests directory already contained prior evidence. This task adds `tests/savestate_evolution_pending_fix`; earlier reports/logs remain unchanged. Generated simulation libraries, waves, transcripts and runner temporary files are removed; isolated Quartus source/build evidence is retained. Nothing is staged, including Quartus artifacts. No commit, push or PR was made.

41. **READY TO COMMIT:** all three confirmed state-loss mechanisms are fixed; actual T8028/00 becomes28/28; restore-time CPU restart cannot consume the operation early; each launch occurs exactly once at the target fetch; saved-time flags/history/banks restore independently of Q; repeated LOAD and SAVE-only equivalence pass; F13/F14 remain intact; current host turbo is preserved. Format v11 is validated and legacy Evolution exactness is handled by pre-write rejection. F06 remains unresolved, F16 untouched, and no stronger full-T80 collision proof is claimed.
