# F12 System E pause / savestate investigation

Investigation branch: `investigate/savestate-systeme-pause`, based on committed F11 `dcbe06d`. Production RTL and savestate format remain unchanged. Results below distinguish an arcade hardware snapshot from the core's external pause feature.

## 1. Architecture

`SMS.sv:48–91` selects bit 8 of the current raw joystick using `swap`. This is the separately mapped System E Pause button, e.g. position 5 in the Tetris MRA; it is not the arcade Start/Coin input. `joy8_r` detects rising edges on every host clock. A rising edge while running queues `se_pause_pending`; VBlank falling applies pause. A rising edge while paused queues `se_unpause_pending`; VBlank rising releases pause. Edges while either transition is pending are ignored. VBlank comes from the production `video` timing generator.

The raw joysticks arrive through `hps_io`; this pause path bypasses the normal low-eight-bit gameplay hotkey mask. The independent save UI receives SaveState bit 12 and directions, or OSD/keyboard save/load requests; its legacy `joyPause` input is bit 6, not System E's bit 8. A valid loaded game/BIOS must satisfy `ss_state_allowed` before requests enter the controller. There is no System E pause veto there. Input polling and the save UI run on host clocks and can recognize fresh unpause input while the CPU is stopped.

`se_pause_gate = systeme & se_paused`. In SMS's `system` instance, it gates `ce_cpu`, which clocks both PSGs, FM and IO/controller logic. Independently, `system.vhd:960–961` gates `ce_z80` with `se_pause`; the System E Z80 otherwise runs on `ce_pix`, not `ce_cpu`. Both VDPs retain pixel/VDP/sprite enables while paused. Raw video timing also continues. RGB is halved while paused (`SMS.sv:1674–1676`); HDMI freeze is tied low. Thus this is a CPU/audio pause with continuing arcade video timing, not a complete machine freeze.

The ordinary console Pause input is tied inactive in System E (`.pause(systeme ? 1'b1 : ...)`); T80 NMI receives that inactive input combined with GG link NMI. The host pause button does not become a System E emulated hardware NMI. Arcade controls use separate IO inputs.

Savestate transport gates the system's CPU, pixel, VDP and sprite enables. The separate raw `video` module continues during transport and the controller aligns release to the saved beam. System E snapshots already include both VDPs/CRAMs/VRAM banks/PSGs, 16 KiB WRAM, IO banking, video timing and output enables. There is no pause-state connection to the controller or payload.

Raw reset includes external/menu reset, download/BIOS transitions, backup loading, eject and the Evolution reset combination (`SMS.sv:416`). It clears the three host phase flags, as does leaving System E. The CPU/controller use the longer `reset_active` including RAM clear. Button and VBlank edge history keep tracking during reset; a held button is not synthesized into a fresh edge. PSG clock stopping holds its counters/mixer output; this path does not explicitly force its sample to zero.

## 2. State classification

| Item | Class | Reason |
|---|---|---|
| `se_paused` | B, host/UI state with machine effects | Core-created toggle gate and presentation dimming; not an arcade register/input latch |
| `se_pause_pending`, `se_unpause_pending` | C, synchronization of B | Schedule that host request on particular beam edges; persist across frames |
| `joy8_r` | C, host input edge history | Tracks the current external button even during transport |
| `VBlank_r` | C/D | One-host-clock edge history of the current raw beam |
| `ss_freeze_r`, `ss_unfreeze` | C/D | Transport edge history and derived falling-edge pulse |
| `se_pause_gate`, gated enables, dim RGB | D | Combinational results of mode/pause/freeze |
| T80 registers, PSG configuration/counters, VDP/VRAM/IRQ state | A | Emulated machine state affected by the above gates |
| Raw joystick, swap selection, raw reset | B | Current external controls, not historic snapshot contents |
| Raw beam/video counters | A | Emulated timing, separately serialized/aligned by savestates |

No E classification remains for the immediate pause process. Whether a product should deliberately cancel host pause is a policy question; it must not be confused with proof of execution equivalence.

## 3. Semantics

The implemented pause is a host convenience feature resembling a partial debugger stop. It is not the original arcade Pause hardware. The comments require pause after the VBlank handler finishes and resume during VBlank, to avoid incomplete graphics updates. History deliberately clears this UI state during save/load. Therefore the evidence does **not** establish a missing arcade hardware register.

It does establish that save-only is not transparent to an already queued host pause: it cancels the request and changes subsequent CPU/PSG execution. A held paused CPU can also prevent a request from ever reaching capture. The strict reference comparison requested for this investigation consequently cannot support a justified exclusion.

## 4. Acceptance

The controller receives `clkref_cpu = (systeme | turbo) ? ce_pix : ce_cpu`, bypassing pause and transport gating. In state 37 it requires: storage idle, that raw enable high, M1 low, MREQ low, unprefixed ISet=0, VBlank high, and x<256. It captures T80 registers on that edge, then enters state 41. One host clock later it snapshots VDP/IO/video and asserts freeze. Audio extended state is captured after quiescence/drain. A raw enable does not imply the paused T80 actually executed a tick: a held qualifying bus is accepted; a held nonqualifying bus cannot progress toward acceptance.

## 5. Freeze and release

Every host clock with `raw_reset | ~systeme | ss_freeze | ss_unfreeze` clears all three pause/transition flags. `ss_unfreeze` extends that clear through the first host clock after transport release. `joy8_r` and `VBlank_r` continue tracking throughout. No old button edge or pending transition is reconstructed. Save and load use the same destructive pause path.

The running/pending reproducer requests at cycle 658648, accepts at 658730 (x208/y192, pending=1), and asserts freeze at 658731. The three flags are zero before the first DDRAM transfer at 658766. Release is cycle 1554771, after 896040 transport clocks. The first resumed CPU enable executes at the rising edge indexed 1554780; the falling-edge observer reports it at 1554781. CPU comparisons run before nonblocking updates, so reported first divergence is the first observation of the changed state, one host clock after the enabled update. Controller logs include state 54 drain, state 1 capture, state 34 alignment and state 63 settle. Load logs additionally record CPU/VDP/PSG restore strobes and states 33/59/56.

## 6. Reachability

All tested pause states arise from physical button pulses and running production timing/T80 logic. Only UI cooldown is bypassed between operations. CPU bus, pause flags, capture predicates and FSM state are never forced. Initial reset duration, and physical reset between phase searches before any save, select different instruction phases. Valid pause phases are running, pause pending, paused, and paused with unpause pending. A pause edge on the acceptance tick can create pending state before the next-clock freeze. Pending pause is therefore not excludable from analysis on reachability grounds.

## 7–9. Save-only, load and transition results

The canonical per-case outcomes and exact event traces are in `results.json` and `case*_keep*_full*.log`. Case definitions and commands are in `README.md`.

| Case | Reachable state / action | Result |
|---|---|---|
| 0 | Running save-only | CPU and PSG reference remain equal |
| 1 | Pending pause before request | Accepted with pending=1; save cancels it; CPU/PSG diverge |
| 2 | Physical edge on last host cycle before acceptance | Pending forms before freeze; save cancels it; CPU/PSG diverge |
| 3 | Already paused, held M1/MREQ qualifying | Capture succeeds; save clears pause and resumes CPU/PSGs |
| 4 | Already paused, held bus nonqualifying | No capture in >2 frames; external unpause recovers |
| 5 | Unpause at preceding VBlank rise | CPU and PSG reference remain equal after save |
| 6 | Unpause input just after equivalent reference point | Same edge queues opposite transitions in DUT/reference |
| 7 | Pending save, execution perturbation, two loads | Historical pending phase absent after both loads |
| 8 | Paused save, execution perturbation, two loads | Historical paused phase absent after both loads |
| 9 | Pending unpause during accepted VBlank | Reachable at capture; freeze discards the queued transition |

The running control retains equal full T80 register output and PSG extended state after release and one million further host clocks. Pending pause before request, and an edge on the last host cycle before acceptance, are cancelled by save-only. At the next reference frame start the reference pauses; DUT continues. For the pending case the first observed T80 divergence is cycle 1791871 at x491/y0. After one million release clocks, the bus addresses differ (0000 versus 0002), PSG divider is 7 versus 9, and signed audio is 75 versus -331. These are values from the deterministic test ROM, not a commercial game's symptoms.

The remaining canonical logs cover already paused capture, non-M1 request recovery, unpause before capture, a subsequent unpause button edge, pending unpause at capture, and two repeated full DDRAM loads after perturbation. Load has no pause fields to restore. Its exact phase-loss evidence must be read alongside save-only; CPU instruction restart differences on DIRSet are not attributed to F12 or investigated here.

For case 7, the two loads each transfer 10282 DDRAM words. First load accepts at 2554790, restores CPU/both VDPs/PSGs at 2688200, and releases at 4480281; second accepts at 4510300, restores at 4643710 and releases at 6435791. Both log saved phase `010` and actual phase `000`. The reference has meanwhile reached phase `100`. Each load transports for 1925490 host clocks. Raw pixel/CPU enables are at cycle indices divisible by ten, so the first resumed CPU ticks are 4480290 and 6435800. These load results demonstrate phase loss, not an assertion of unrelated CPU microcycle restore correctness.

Case 8 similarly logs historical phase `100` becoming `000` after each load. Its load accept/restore/release cycles are 3448760/3582170/5374251 and 5405030/5538440/7330521. Case 9 accepts `paused=1, pause_pending=0, unpause_pending=1` at cycle 1552690, freezes at 1552691 and releases at 2448731 with all three flags zero while the reference remains paused with unpause queued. Thus both transition directions are naturally reachable and affected.

The supplementary `edge.log` confirms that a button held through transport creates no duplicate release edge, fresh edges still queue transitions, and pending unpause is cleared. This is a process-level test; the natural controller case 9 is the accepted-boundary proof.

## 10. CPU progression

Two actual production T80s execute `INC A; JP 0`. The reference omits savestate and is held only while DUT spends host time transporting, then resumes at the equivalent beam point. All CPU registers are compared using four-state equality; uninitialized architectural registers remain visible in the logs and are not misreported as tested numeric values. Pause stops CPU execution, not only an abstract counter. F12's strongest comparison is save-only, which does not use DIRSet and therefore avoids attributing unrelated CPU restore behavior to pause.

## 11. Dual VDP

Both VDP clocks continue while paused and stop for savestate transport, while raw beam timing continues. The full configuration instantiates two actual VDPs, with all three production enables and distinct bank inputs, plus T80s and PSGs. It completes the same accepted-pending reproduction and subsequent button toggles. Its uninitialized video-memory/read/render fields appear as X in the snapshot; this is not a claim of rendered-image equivalence. The fast isolation cases intentionally use idle VDP snapshot/memory models. The independent existing F07 System E integration restores both real VDPs through DDRAM and verifies guest-visible HCounter 5A/A5 for the current format and zero/zero for legacy, followed by new latch activity. Neither test alone claims commercial-ROM graphics replay or whole-motherboard coverage.

## 12. PSG/audio

Two live production JT89 PSGs receive `ce_cpu & ~paused & ~ss_freeze`; the reference PSG receives the corresponding reference gates. Ordinary running save-only matches extended counters/divider/audio. Pending cancellation changes when counters stop and produces the explicit divider/audio differences above. During established pause, counters hold after pipeline settling while video advances. The existing PSG savestate regression separately passes 128 cases, all 16 divider phases and eight noise controls, with 20000 future cycles per case.

## 13. Liveness and candidate architecture

Clearing during freeze cannot repair a stall **before** freeze. The held nonqualifying bus cannot satisfy state 37 regardless of continuing raw CPU enables or future VBlanks. An external unpause is required to let that CPU reach an instruction boundary. There is no state-37 timeout that repairs this.

The fixture-only KEEP experiment removes just the freeze/unfreeze clears. Pending pause then sees a raw VBlank fall during transport and applies early, before the equivalent reference time. In case 1, it releases paused while the reference is still pending; register divergence is first observed almost immediately after release, at cycle 1554801, and PSG/audio diverge. Already established pause on a qualifying bus survives the transport with equal reference CPU/PSG state in KEEP case 3; no pause clear is needed for that completed transfer. KEEP case 4 still stalls before capture. Merely deleting the clears is therefore not an adequate fix.

A future architecture must separate host pause phase from transport gating, suppress pending-transition consumption on transport-only beam edges, prime edge detection coherently at release, and define how a paused non-M1 CPU reaches a valid capture. Temporarily advancing a paused CPU to M1 changes the paused machine state and is not automatically an exact-preservation solution. Possible product policies include explicit unpause/defer/reject behavior with UI feedback, or a coherent pause-aware capture mechanism. Any exact-preservation implementation must resolve the CPU boundary constraint without silently changing the reference point. No such production fix is implemented here, and no unrelated CPU serialization work is authorized by this investigation.

## 14. History

`history.txt` contains exact local Git evidence. `c3a804b` introduced System E pause and dual-machine savestates without clearing pause during transport. `03d912f` deliberately added the freeze clear. `4768249` deliberately added unfreeze clearing, explicitly describing avoidance of a stuck paused state. `7bdd6d4` moved toward full transport gating and beam alignment. Mainline squash `8f3bcb2` introduced the current pause block on 2026-06-13; line history shows no later behavioral change to that block through F11. Earlier development commits are historical evidence from other local refs, not additional mainline ancestors. The clear is a historical workaround, not accidental fallout from F07–F11.

## 15–16. Divergence and minimal reproducer

Run case 1 with KEEP=0: run System E, press and release Pause during VBlank, then request save before VBlank falls. The accepted boundary still has `paused=0, pause_pending=1, unpause_pending=0`. Freeze clears the queue. After release the uninterrupted reference pauses at the next frame start, but DUT keeps executing and clocking PSGs. This divergence has no finite convergence bound without another external input; it is not a one-cycle synchronizer discrepancy. A fresh physical button edge can now mean pause to DUT and unpause to reference, so subsequent transitions are not equivalent.

The paused nonqualifying-bus case is a second, pre-capture liveness issue. It is not falsely reported as an accepted snapshot defect.

## 17–18. Serialization and format

Save-only preservation can use local phase retention and sequencing without adding payload bits or bumping a format. Exact save/perturb/load restoration of the historical host pause phase cannot be recovered from the current payload: the same CPU/VDP/PSG snapshot can be paired with a current or queued host toggle. Four valid phases need two encoded bits, or the existing three flags with validity constraints. This is a host phase extension, not a newly discovered arcade register. Current button history should remain current to prevent a held button creating a synthetic edge; beam edge history can be primed from the release beam rather than blindly restoring old host-clock history.

If a future product contract includes historical UI phase, it needs both coherent sequencing and a distinguishable serialized representation. Reserved space exists, but assigning it requires compatibility design; this investigation does not prescribe v9 or prove a version bump mandatory. If the contract explicitly excludes historical host pause, no pause payload is required, but the stalled-request handling still needs a defined behavior. No format or production change was made.

Thus the requested exact historical-phase contract requires category C (sequencing plus phase serialization), with an additional solution to paused non-M1 capture eligibility. The existing cancel-pause UI contract instead permits category A/D (request sequencing and an explicit UI policy) without serializing pause. The three flags have four valid combinations and can be represented as `00` running, `01` pause pending, `10` paused, `11` unpause pending; two UI phase bits alone do not solve arbitrary paused CPU capture.

## 19. Regressions

See `results.json` for selected clean logs: current/legacy controller formats; System E real dual-VDP DDRAM restore; F08 real-time MD6; F09 Tap directed replay; F10 directed/all phases/modes; F11 one-million-cycle ordinary equivalence/current input tests, actual-T80 save-only and TH-direction restore ordering; PSG replay. This is a scoped regression selection, not a rerun of every earlier audit fixture or a Quartus build.

All **26 canonical logs** complete with zero simulator errors: 14 F12 controller scenarios (10 production cases, three naive-preservation experiments, one full dual-VDP configuration), one input-edge process test, and 11 existing regression runs. The F12 controller scenarios complete 18 save/load transfers; the two stalled-request tests each require external unpause before their transfer. Regression counts include F08 160 real-time cases, F09 4096 directed cases, F10 7832 directed/phase/mode cases, F11 one million ordinary cycles plus eight current-input cases/32000 held observations and actual CPU/restore-order replay, and PSG 128 cases. Existing T80 width and Starter Edition capacity warnings remain visible; they are not simulator errors.

## 20–21. Scope

F06 remains unresolved and untouched. F07–F11 production behavior is unchanged: their committed RTL has zero diff and selected regressions pass. No work on F01–F11 or F13–F16 findings was implemented. No Quartus build, format bump, staging, commit, push or PR.

The writer remains format v8. Only investigation sources, reports and logs are retained in this directory; generated ModelSim libraries, copied RTL/adapted simulation sources and transcripts are removed using `clean.ps1`.

## 22–23. Repository state

`git diff --stat` is empty (`diff_stat.txt`). `git status --short` is `?? tests/` (`git_status.txt`), which includes earlier untracked investigation evidence as well as this directory. No claim is made that all of `tests/` belongs to F12. Production hashes and exact base commit are recorded in `results.json`.

## 24. Classification

**CONFIRMED - FIX REQUIRED**, for the requested transparent pause/save execution contract and the reproduced pause/request liveness failure. This is **not** evidence that System E arcade hardware contains an omitted pause register. The host pause state is intentionally external in the implementation and deliberately cancelled historically; nevertheless the clear changes accepted-boundary CPU/PSG execution, and clearing only after acceptance cannot solve the pre-capture stall. A justified exclusion would need an explicit cancellation contract plus coherent request handling, not a false claim that the current behavior preserves equivalent execution. Production modifications require a separately authorized fix task.
