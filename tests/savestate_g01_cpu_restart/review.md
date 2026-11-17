# G01 CPU instruction-microarchitecture savestate investigation

**CONFIRMED - FIX REQUIRED.** Both original G09 CPU mismatches are G01 defects: an accepted SAVE can fall between `ED` and `B0`. LOAD discards the preceding `ED`, then executes `B0` as `OR B` instead of `LDIR`. BC, subsequent bus transactions, and guest-written RAM differ from uninterrupted execution.

Investigation only, 2026-10-22. No fix or format change is included. G09.last-read remains **CLOSED - PROVEN RECONSTRUCTABLE**.

## 1. HEAD and scope

HEAD: `faf7036e4450027f79cc639a731053dca29840ca` (post-F16), branch `investigate/savestate-g01-cpu-restart`.

Original G01/S004: `IR`, `ISet`, `XY_State`, `MCycle`, `TState`, bus strobes, ALU pipeline. The obligation is future guest equivalence at every naturally accepted boundary, rather than equality of every internal flip-flop.

Authoritative inputs read: [G closure](../savestate_g_closure/review.md), [G09](../savestate_g09_last_read/review.md), [F16 investigation](../savestate_cpu_nmi/review.md), [F16 capture](../savestate_cpu_nmi_capture/review.md), [F16 fix](../savestate_cpu_nmi_fix/review.md).

The request explicitly says: “If either already produces a reachable guest-visible divergence” classify CONFIRMED, “but continue only enough to characterize the defect precisely.” That stopping rule applies here. Subsequent broad EI/HALT/opcode matrices and non-injective searches were not performed; their absence is not evidence of safety.

## 2. Exact original mismatches and independent reproduction

Both original fixtures were independently executed **before** creating the extended fixtures. The copied `fixed_tb.sv`, `machine.sv`, CPU observers, mapper observer, controller adapter, and runners are byte-identical to G09. [results.json](results.json) records the checked files. Neither the exact reproduction nor its original equality assertion was weakened.

| Original G09 case | Request | Accepted production SAVE | Original reproduction |
|---|---|---|---|
| `p4_o1056_t15_s0_c0` | cycle 170558, A=012A, last=0014, MC1/T1 | cycle 170581, PC=A=012A, MC1/T2, last pre=0014 | Same `Guest mapping replay differs` fatal; BC reference=0001, restored=0002 |
| `p4_o800_t10_s0_c0` | cycle 135692, A=A000, last=A000, MC3/T4 | cycle 135821, PC=A=012A, MC1/T2, last pre=0016 | Same fatal; BC reference=0000, restored=0001 |

Logs: [normal exact reproduction](p4_o1056_t15_s0_c0.log), [turbo exact reproduction](p4_o800_t10_s0_c0.log). These are two expected failing runs, not passing equivalence tests.

Both use real guest PROGRAM=4. Its relevant body is:

```asm
0120: LD HL,A000h
0123: LD DE,A000h
0126: LD BC,0002h
0129: ED
012A: B0                  ; LDIR
012B: LD A,(8123h)
012E: LD (C110h),A        ; original page signature
      JP 0100h
```

The inherited setup initializes other registers, mapper state, RAM, disables INT and establishes SP=DFE0. A000 reads 05; writes there are guarded by the existing mapper behavior. ROM code mirrors across selected pages. No arbitrary internal CPU state is forced. The ordinary run captures the first block iteration (BC=2); the turbo run captures the terminal iteration after the first copy (BC=1, HL=DE=A001).

## 3. Canonical semantic instant and the first divergence

Let T be the actual accepted MC1/T2 host clock. The controller saves pre-edge architecture A(T-), while the reference executes T. F16 records normalized post-sample NMI history; GG/IO are captured after that edge. During LOAD, DIRSet installs architecture and clears selected microstate while the CPU is stopped. The wrapper then installs NMI metadata, replays T1 and historical T2, holds the sampler during replay, and returns to live sampling.

The comparison instant k=0 is **after restored historical T2**, compared with **after reference accepted T**. Transport time and synthetic setup T1 are excluded. Subsequent k counts logical host clocks with the same native enable spacing and future inputs. Reference and restored architecture, NMI projection, strobes, active bus data/address, mapping, GG and IO all compare equal at k=0 in every extended LOAD. Comparing the pending-prefix context at that same instant reveals the problem without misaligning phases.

| Observation | Ordinary, period 15 | Turbo, period 10 |
|---|---|---|
| Pre-T IR / ISet / Prefix | ED / 00 / 10 | ED / 00 / 10 |
| Post-T reference IR / ISet | B0 / 10 | B0 / 10 |
| Post-historical-T2 restored IR / ISet | B0 / 00 | B0 / 00 |
| k=0 architectural PC/SP | equal: 012B / DFE0 | equal: 012B / DFE0 |
| First architecture difference | k=15: BC 0001 vs 0002 | k=10: BC 0000 vs 0001 |
| First active bus projection difference | k=30: reference A000, restored 012B | k=20: reference A001, restored 012B |

The bus difference is a missing block data read: the restored CPU begins the following opcode fetch instead. IR itself agrees at the canonical instant (B0); the discarded **previous** IR has already caused different ISet. MC1/T3 is the first architectural divergence, one CPU enable later. At that first divergence PC, SP, WZ, A/F, IFF1/2 and HALT still agree; BC differs. Later PC/instruction trajectories differ as a consequence of the skipped work. SP and interrupts are not the cause. INT/NMI remain inactive in these cases; interrupt timing equivalence under active inputs was not tested here.

See [normal extended original-ROM log](extended_p4_o1056_t15_s0_sig0.log), [turbo extended original-ROM log](extended_p4_o800_t10_s0_sig0.log), and decoded context/register/bus values in [results.json](results.json).

The extended diagnostic runs continue for 12,000 logical host clocks after each of three LOADs. They intentionally log differences rather than aborting at the known first BC mismatch. `PASS G01 CHARACTERIZED` requires a BC/architecture difference and a bus difference; it does **not** mean equivalence passed. SAVE-only retains its strict equality assertion.

## 4. Guest-visible consequence and classification of each original mismatch

With the exact old ROM, the final page byte C110 remains 02 in both reference and restored execution, and the final sampled RAM arrays agree. That byte measures mapping, not completion of the block instruction. It cannot dismiss the earlier architectural and data-read divergence.

To make lost work persistent, SIGNATURE=1 appends a real guest observer at 012B. All code executed through accepted T is unchanged. The observer runs once per snapshot history (guard C12F), stores BC at C120, DE at C122, HL at C124, then executes the original page-signature continuation. [signature_rom.json](signature_rom.json) contains the exact bytes; [prepare_extended.js](prepare_extended.js) generates the fixture. The stores are actual CPU instructions, with no internal register injection.

| Original accepted state | Reference stored BC/DE/HL | Restored stored BC/DE/HL | Persistent RAM differences |
|---|---|---|---|
| Normal first iteration, BC=2 | 0000 / A002 / A002 | 0002 / A000 / A000 | C120: 00→02; C122: 02→00; C124: 02→00 |
| Turbo terminal iteration, BC=1 | 0000 / A002 / A002 | 0001 / A001 / A001 | C120: 00→01; C122: 02→01; C124: 02→01 |

Each result repeats for Q1, Q2 and Q3. The original page byte remains equal (02 in SMS, 00 in the System E variant). Thus an actual guest memory observer distinguishes the histories even when the mapper-page signature does not.

Mismatch #1 classification: **G01 DEFECT**. It loses both remaining copies from the captured first-iteration context. Mismatch #2 classification: **G01 DEFECT**. It loses the remaining terminal copy. These are two accepted witnesses of the same root cause, rather than two independently established root causes. Neither is expected normalization, harmless reconstruction, or a reference-alignment artifact.

The architecturally distinguishing core is `LD HL,src; LD DE,dst; LD BC,count; ED B0`, accepted on B0 with old IR=ED. A guest `LD (result),BC` afterward observes skipped decrement. The retained fixtures include mapper setup and the full observer, so this is a reduced causal program description, not a claim that an independently minimized ROM was simulated.

## 5. Exact restore/normalization inventory

Categories: A explicitly serialized/restored; B reconstructed by canonical restart; C intentionally reset/normalized; D combinational or refilled before its specified observation; E potentially future-relevant and unproven. A category C assignment describes implementation, **not** proof of harmlessness. Rows with C/E explicitly retain an open correctness obligation.

Sources: production `rtl/T80/T80.vhd` DIRSet blocks (430–456, 1118–1136), register-address process (855–895), combinational datapath, `T80s.vhd` replay/bus process, and `T80_Reg.vhd` DIRSet.

| State or control | Restore behavior / classification | Evidence or remaining obligation |
|---|---|---|
| ACC,F,Ap,Fp,I,R,SP,PC | A: DIR[79:0] | Explicit architectural restore; T2 redoes PC/R progression |
| BC,DE,HL,IX and alternate banks/IY | A: DIR[207:80], Alternate remapping | Register file DIRSet, not reconstructed from lost instruction |
| IM/IStatus, IFF1, IFF2, WZ, Alternate, Halt_FF | A: DIR[229:208] | Architectural serialization; HALT execution/wake timing still needs its own matrix |
| NMI_s, NMICycle, OldNMI_n | A: v12 metadata; NMICycle initially cleared by DIRSet | F16 later metadata application wins with CEN stopped; not overwritten by replay sampling |
| IR | C: 00 on DIRSet, reloaded from DInst at T2 | **Confirmed unsafe for pending ED**: old IR is consumed by Prefix on the re-fetch edge |
| ISet | C: 00, recomputed at T2 from old IR-derived Prefix | **Confirmed wrong 00 vs 10** after canonical T2 |
| XY_State, XY_Ind | C/E: 00/0 | DD/FD/index displacement context not certified by this witness |
| MCycle, TState | C then B: MC1/T1, then historical T2 advances to T3 | Timing alignment proven for witnesses; correct timing alone does not restore decoder context |
| MCycles | C: 001; then decoder-latched MCycles_d | D only conditional on correct decoder context; context is wrong here |
| A output address | C/B: set to saved PC; T1 issues re-fetch | Correct fetch address at k=0, subsequent transfer sequence is wrong |
| DO | C/E: 00, later datapath writes it | Unused when WR inactive at initial fetch; global write-before-use proof not supplied |
| IntCycle | C/E: 0 | Accepted ordinary memory fetch excludes acknowledge; all future EI/INT paths still unproven |
| No_BTR | C/E: 0; recomputed every CEN from I_BT/I_BC/I_BTR, IR, flags | Recalculation depends on decode; all block families/termination cases not certified |
| BTR_r | C/E: 0; later latched repeat decision | Same outstanding block-context dependency |
| Pre_XY_F_M | C/E: 000 | Indexed fetch return history not independently tested |
| Auto_Wait_t1/t2 | C/E: 0, then CEN pipeline from Auto_Wait/IORQ | Broad IO/interrupt timing not certified |
| BusAck, BusReq_s | C/E: 0, BUSRQ resampled | Production fixtures use inactive BUSRQ; arbitrary bus-request histories not tested |
| M1_n | C/B: 0, then historical T2 sets 1 | Matches canonical phase |
| T80s RD_n/WR_n/IORQ_n/MREQ_n | C/B: inactive on DIRSet; generated again at T1/T2 | Equal at k=0; lost LDIR then changes transactions |
| RFSH_n | Retained during DIRSet, regenerated on CEN | E for general refresh-observable behavior; no serialization claim from this investigation |
| T80s DI_Reg | Retained on DIRSet; refilled from DI at historical T2 | D for the ordinary fetch witnesses |
| T80 DI_Reg | D: concurrent alias of DI | No independent storage in T80 |
| Read_To_Reg_r, Arith16_r, Z16_r, ALU_Op_r, Save_ALU_r, PreserveC_r, I_RXDD | C/E: cleared by DIRSet | Pipeline refill depends on instruction and microphase; general proof outstanding |
| RegAddrA_r, RegAddrB_r, RegAddrC, RegBusA_r, IncDecZ | E: no explicit DIRSet branch; updated by ClkEn process | History can survive Q until replay; no global overwrite-before-consumer proof claimed |
| BusA, BusB | E: registered operand buses selected on clock | Need consumer-order proof for all restart classes |
| ALU_Q, F_Out, ID16, RegDIH/L, RegWEH/L, RegAddrA/B, RegBusA/B/C | D: combinational/datapath outputs from current registered inputs | Derived does not imply equivalent when their context inputs differ; BC write mismatch demonstrates this |
| Prefix, SetEI, SetDI, Halt, NextIs_XY_Fetch, T_Res, Auto_Wait, MCycles_d/TStates, decoder controls | D signals, with E semantic obligations | Prefix/SetEI are **not separate serialized latches**; IR/ISet/XY/phase drive them. Clearing IR changes Prefix before T2 |
| T80s nmi_restart, nmi_apply, nmi_hold_i, cen_i | B/D: F16 metadata/T1/T2 sequencing | F16 ordering preserved; new context repair must fit before historical T2 |

This lists direct DIRSet assignments, retained clocked datapath groups, wrapper state, and derived controls. It does not assert every C/E item needs new serialization. The ALU unit itself is combinational; pipeline/operand registers outside it carry the unproven history.

## 6. Root cause, reconstruction and format implications

The production controller accepts `cpu_ce && !M1_n && !MREQ_n && ISet==00` during its capture window. Its comment equates ISet=00 with “not mid-way through CB/DD/ED/FD sequence.” At this accepted B0 fetch, however, old IR is ED while ISet is still 00. The pending prefix has not yet transferred into ISet.

At normal MC1/T2, T80 schedules `IR <= DInst` and `ISet <= Prefix`, where Prefix is decoded from **pre-edge IR**. Therefore the uninterrupted CPU gets IR=B0/ISet=10. DIRSet clears IR and ISet; replay fetches exactly the correct B0 from exactly the correct address, but old IR is now 00. Restored ISet remains 00. The ED decoder's block `IncDec_16` BC decrement is replaced by ordinary OR-B decode. This explains the first BC difference, lost source read, and the RAM results without invoking mapper state or NMI sampling.

The existing restart is insufficient. A future fix could investigate (a) proving a stronger acceptance boundary that defers across pending prefixes and other prior-instruction effects, or (b) preserving enough coherent pre-T decoder context before historical T2. Neither is implemented or validated here. Reading PC-1 is not proved sufficient for all legal histories or mutable memory.

No naturally reached same-media pair with **identical complete v12 images** was constructed. There is no injectivity claim. A direct reference-vs-LOAD counterexample already establishes the present restoration defect; it does not establish that all correct restorations require additional image bits.

Consequently serialization is **not yet proved necessary**. This witness requires distinguishing at least pending-ED from no-prefix, but one bit is only a distinction for this witness, not a validated general format allocation. A 2-bit prefix class or an 8-bit pre-edge IR is a possible investigation target; neither has been shown sufficient for XY/EI/pipeline state. The additional-bit requirement for all G01 obligations remains unknown; a boundary-only repair could require zero new image bits.

Restore ordering: any retained pending decoder context must be installed after the DIRSet clears that would erase it and before historical T2 consumes it. It must coexist with F16's later stopped-CPU NMI metadata installation, GG post-T restore, T1 re-fetch, and held historical-T2 sampling. Blindly restoring post-T IR/ISet then replaying T2 would mix instants and is not validated.

## 7. Coverage and limits (requested report items 10–29)

| Obligation | Result in this investigation |
|---|---|
| EI-delay (10) | OPEN - NEEDS MORE EVIDENCE. No new EI/INT timing matrix; first confirmed defect invokes stopping rule |
| HALT (11) | OPEN - NEEDS MORE EVIDENCE. No new HALT/wake matrix; F16 prior coverage is not a substitute |
| LDIR (12) | CONFIRMED - FIX REQUIRED. First iteration BC2 and terminal BC1 accepted contexts; both skip remaining block work |
| LDDR (13) | OPEN; not simulated |
| CPIR (14) | OPEN; not simulated |
| CPDR (15) | OPEN; not simulated |
| INIR (16) | OPEN; not simulated |
| INDR (17) | OPEN; not simulated |
| OTIR (18) | OPEN; not simulated |
| OTDR (19) | OPEN; not simulated |
| Prefix/restart (20) | CONFIRMED for naturally accepted ED→B0; CB/DD/FD/DDCB/FDCB remain OPEN |
| Ordinary microcycle classes (21) | No broad register/immediate/memory/stack/CALL/RET/branch/IO sweep; inherited setup/observer execution is incidental, not closure |
| Accepted boundaries (22) | Two distinct original states, plus the same first/terminal contexts with observer and System E. All production-accepted, no forced MC/TS/context |
| SAVE ONLY (23) | All five extended cases: strict projection equality for 400 CPU-enable samples each; existing F16/G09 sanity also retains strict checks. No claim for untested EI/HALT families |
| Repeated LOAD (24) | Five cases × three loads × 12,001 host-clock samples = 180,015 diagnostic comparisons. Q1/Q2/Q3 vary guest mapper/bank/BIOS/WonderKid history; no new interrupt/HALT-history matrix |
| Ordinary cadence (25) | Period15 SMS normal witness confirmed, exact and observer ROMs |
| Turbo (26) | Period10 SMS terminal witness confirmed, exact and observer ROMs |
| System E (27) | SYS1/period10 observer witness confirmed, same BC/bus/RAM deltas. This exercises controller System E selection and representative CPU spacing, not the complete production clock tree or G10 |
| Non-injective searches (28) | Not performed after early direct guest counterexample. Static omitted-prefix analysis only; no forced-state or cross-ROM pair is presented as such a search |
| Complete-v12 collisions (29) | None established; absence of a constructed pair proves neither injectivity nor reconstructability |

For all accepted witnesses MC1/T2 has M1=0, MREQ=0, RD=0, WR=1, IORQ=1; ISet=00, IR=ED, Prefix=10, HALT=0, SetEI=0, No_BTR=0. Request phases and accepted PC are in section 2; canonical replay is in section 3 and logs. No all-phase accepted-boundary sweep is claimed.

The fixture uses an explicit independent running reference and the current controller/DDRAM save/load path, real CPU, IO, mapper/decode observers, and video timing. Other peripherals are fixture stubs as in G09. Test-only CPU adapters add outputs; they do not alter CPU transition rules. Host-clock spacing models normal/turbo/System E representative cadence; it is not a board timing validation. Original and observer ROMs are separate experiments, not a same-media image-collision pair. Saved image filenames are shared by signature modes; logs and generated source establish which experiment ran, and those files must not be used to claim a collision.

## 8. Scoped regressions and run ledger

| Run | Outcome |
|---|---|
| Exact original normal | Expected original CPU mismatch reproduced |
| Exact original turbo | Expected original CPU mismatch reproduced |
| Extended normal / original ROM | Characterized BC/bus divergence; final old page byte masks defect |
| Extended turbo / original ROM | Same, terminal iteration |
| Extended normal / observer ROM | Characterized divergence, three persistent guest RAM bytes |
| Extended turbo / observer ROM | Same, terminal iteration |
| Extended System E period10 / observer ROM | Same CPU root cause and RAM divergence |
| G09 PROGRAM0/OFFSET1200/period15 | PASS, three LOADs, 36,403 comparisons; latch read precedes dependent writes |
| F16 capture-edge pulse | PASS, three LOADs, 18,403 comparisons; normalized pending100, one handler entry per replay |

Commands from repository root:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/savestate_g01_cpu_restart/run.ps1 -Program 4 -Offset 1056 -Compile
powershell -NoProfile -ExecutionPolicy Bypass -File tests/savestate_g01_cpu_restart/run.ps1 -Program 4 -Offset 800 -Period 10
node tests/savestate_g01_cpu_restart/prepare_extended.js
powershell -NoProfile -ExecutionPolicy Bypass -File tests/savestate_g01_cpu_restart/extended.ps1 -Program 4 -Offset 1056 -Compile
powershell -NoProfile -ExecutionPolicy Bypass -File tests/savestate_g01_cpu_restart/extended.ps1 -Program 4 -Offset 800 -Period 10
powershell -NoProfile -ExecutionPolicy Bypass -File tests/savestate_g01_cpu_restart/extended.ps1 -Program 4 -Offset 1056 -Signature 1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/savestate_g01_cpu_restart/extended.ps1 -Program 4 -Offset 800 -Period 10 -Signature 1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/savestate_g01_cpu_restart/extended.ps1 -Program 4 -Offset 800 -Period 10 -Sys 1 -Signature 1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/savestate_g01_cpu_restart/run.ps1 -Program 0 -Offset 1200
powershell -NoProfile -ExecutionPolicy Bypass -File tests/savestate_g01_cpu_restart/nmi_sanity/sim.ps1 -Do fixed.do -Label first_capture_pulse
node tests/savestate_g01_cpu_restart/analyze.js
```

The first two commands intentionally fail the original oracle. The five extended commands assert characterization of the defect, not successful restore equivalence. `-Compile` is needed for the first invocation of each library.

F16 sanity copies the existing fixture unchanged except for production source relative paths and literal generic values: SOURCE0, PROGRAM0, EDGE0, WIDTH1, SECOND9999999, HELD0, SCHEDULE0, FORMAT0, REPLAYS3. This is the pulse first sampled at accepted SAVE clock and released before LOAD; it checks normalized pending history and repeated restore. It uses current production datapath source plus observation-only CPU adapters. Initial harness setup errors (missing include, then empty generic expansion) were corrected before the actual sanity simulation; those attempts are not guest test cases.

F16 result: [first_capture_pulse.log](nmi_sanity/first_capture_pulse.log) reports `PASS F16 fixed source0 program0 edge0 held0 format0 loads3 comparisons18403`, no errors. SAVE ONLY compares exactly, and each LOAD produces counter=signature=vectors=1. This is a scoped regression, not a repeat of F16's full state space.

There are **nine completed guest simulation cases**: two expected-failing original reproductions, five extended characterization cases, and two passing scoped regressions. The five extended cases exercise five actual SAVE operations and fifteen LOADs. Initial observation-adapter compile corrections and F16 setup/elaboration errors are excluded from this count. No additional acceptance sweep is hidden in that number.

G09 sanity is [p0_o1200_t15_s0_c0.log](p0_o1200_t15_s0_c0.log). Its closure is retained: historical fetch correctly reconstructs last_read before a dependent mapper write. The newly found instruction decode defect does not contradict that latch ordering.

F12: no logical host Pause override or bounded paused capture progress was exercised. F15: no Evolution pending-operation path was selected. Their broader suites were not rerun. No work was done on other G obligations, F01 or F06.

## 9. Repository hygiene and final disposition

All tracked source contents compare equal to HEAD after normalizing checkout CRLF (204 tracked entries inspected, submodule directories skipped); `git diff --stat` and `git diff --cached --stat` are empty. `git status --short`:

```text
?? tests/
```

This untracked tree already contained prior investigation evidence. New work is under `tests/savestate_g01_cpu_restart/`. No production RTL, v12 definition, or prior report was edited. Nothing staged, no commit, no push, no PR, no Quartus. The generated observations, logs and report are investigation artifacts only.

**Final G01 classification: CONFIRMED - FIX REQUIRED.** The universal reconstruction claim is falsified by a natural pending-ED accepted boundary with subsequent guest RAM divergence. Independently scoped EI-delay, HALT, other block instructions, other prefix contexts and general normalization remain OPEN - NEEDS MORE EVIDENCE. Neither those children nor all category-C state are declared defective without evidence.
