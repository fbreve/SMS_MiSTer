# G09.last-read investigation

**CLOSED - PROVEN RECONSTRUCTABLE**, for the omitted `last_read_addr` latch. The accepted fetch overwrites it with logical address F, and the production post-LOAD historical T2 overwrites it with the same F before any dependent write can occur. No serialization or v12 change is needed for this child.

This is a narrow state-reconstruction conclusion, **not** a claim that every CPU restart replay passed. Two stricter LDIR CPU-vector comparisons stopped after successful latch reconstruction, with a CPU-register difference at the following enable. They are retained, excluded from passing replay counts, and not investigated as G01 in this task. No guest-visible mapping divergence caused by `last_read_addr` was established.

## 1. Identity and scope

HEAD: `faf7036e4450027f79cc639a731053dca29840ca`, committed post-F16. Branch: `investigate/savestate-g09-last-read`. Date: 2026-10-22.

The complete [closure audit](../savestate_g_closure/review.md), especially its G09 evidence map, was read. G09.handoff and G09.eeprom-pulse remain CLOSED - PROVEN BY EXISTING EVIDENCE; G09.reset remains CLOSED - JUSTIFIED EXCLUSION. No contradiction to those three dispositions was found. The historical master report is not rewritten by this follow-up.

Only G09.last-read was investigated. No production RTL, v12, fix, Quartus run, staging, commit, push or PR. No investigation of the other G rows, F01 or F06 was undertaken. The incidental CPU observation below is recorded as a limit, not diagnosed or fixed.

## 2–8. Exact current RTL inventory

The complete source-level inventory and proof are in [contract.md](contract.md). Production has exactly three textual occurrences, all in [mapper_ctrl.vhd](../../rtl/mapper_ctrl.vhd):

| Item | Exact contract |
|---|---|
| Declaration, line96 | `signal last_read_addr : std_logic_vector(15 downto 0);` — 16 bits, no initializer |
| Reset | **No assignment.** Initial RTL simulation value is U; subsequent reset assertion retains its previous value. Do not infer reset-zero |
| Sole assignment, line306 | `last_read_addr <= A;` |
| Effective enable | Rising clk_sys, RESET_n=1, mapper_set=0, ce_z80=1, WR_n=1, MREQ_n=0 |
| RD relationship | RD_n is **not tested**. Refresh cycles can update the latch too |
| Sole consumer, line447 | Generic A000 case: `if last_read_addr /= x"A000" then if mapper_codies='0' then bank2 <= D_in; end if; end if;` |
| Additional consumer gates | Generic priority branch, ss_freeze=0, WR_n=0, MREQ_n=0, nvram_e=0, mapper_lock=0. Write handling is host-clocked, not ce_z80 gated |
| Serialization | No v12 field, exported production state or restore assignment |
| Freeze | No local ss_freeze term on the updater. The actual top-level freezes system CPU/pixel enables, hence ce_z80. Dependent writes independently require !ss_freeze |
| Mapper restore | mapper_set bypasses both update and normal write branches; does not consume or restore this latch |
| CPU restore | DIRSet canonicalizes wrapper strobes high and MC1/T1; F16 then installs NMI history with CPU progression stopped, followed by T1/T2 fetch preparation |

The generic consumer is bypassed by active Janggun, EEPROM, System E/SC/Castle/linear/Dahjee/Sega-locked, 4PAK, active Zemina, and the eligible first-4PAK trigger. Janggun has a separate A000 consumer which does not read this latch. Thus System E's generic last-read guard is excluded by priority, rather than presumed tested by changing its cadence.

Mapper detection never reads last_read_addr. Detector/history and BIOS/Wonder Kid edge logic independently select or initialize banks. They can alter which branch is enabled, but add no hidden latch consumer. The generic A000 case has no extra bootloader_n predicate; its enclosing priority chain must be considered. Evolution does not introduce a separate last-read register.

Causal chain: qualified logical CPU A sample -> latch -> generic A000 guard -> bank2 update or suppression -> production memory_decode physical ROM address -> CPU-visible byte. It does not affect the read address, read data mux, CPU enable, restore inputs or timing needed to reconstruct itself.

## 9–10. Exact first post-LOAD ordering and mandatory read

The authoritative implementation is [T80s.vhd](../../rtl/T80/T80s.vhd), [T80.vhd](../../rtl/T80/T80.vhd), [system.vhd](../../rtl/system.vhd) and [savestates.sv](../../rtl/savestates.sv).

| Stage | CPU/bus | last_read_addr / consumer consequence |
|---|---|---|
| Mapper restore during global freeze | CPU stopped; saved banks/visibility/history installed | mapper_set skips updater/consumer; Q latch can remain |
| DIRSet | MC1/T1, RD/WR/MREQ/IORQ high | No dependent write; no qualifying memory sample |
| NMI metadata installation | Wrapper preparation phase01, core CEN0 | No guest write or latch-dependent action |
| First native preparation enable, T1 | Address F from restored CPU fetch; WR stays1; wrapper drives RD/MREQ low after edge | Pre-edge MREQ was high, so normally no latch update on this edge |
| Second native enable, historical T2 | Pre-edge WR1/MREQ0/RD0 and address F | Mapper assigns latch=F. It exactly matches the uninterrupted accepted-T2 assignment |
| Later guest cycles | Normal refresh, reads, and eventually writes | Every later guard sees F or later qualified logical samples; never stale Q |

This proof does not rely on register-file packing alone. The WR1 updater and WR0 consumer are mutually exclusive. Before T2 the wrapper cannot issue a dependent write; after T2 the old cache value has been overwritten. Mapper_set ended long before preparation, and tests assert it cannot overlap the reconstructing read.

Representative trace (`p0_o1200_t15_s0_c0.log`): Q produces last0316/bank09, then another LOAD uses a different Q path. The restore's first memory sample is the saved fetch address; the full recorded post-T2 state equals the independent reference. All three following A000 suffixes select the same bank03 and guest byte03. In HALT replay `p9_o3100_t15_s0_c0.log`, a Q latch0512 is replaced by fetch0121 at MC1/T2 before any later A000 write; signature09 is restored.

The first possible dependent consumer can be an ordinary instruction's A000 store, an RMW/block destination, or even an NMI stack write if SP places it at A000. All follow the mandatory fetch/dummy-fetch T1/T2. The latter corner follows the wrapper ordering argument; this fixture uses SP=DFE0 and does not claim a dynamic SP=A001 test.

## 11–19. Real T80 programs and observations

[prepare.js](prepare.js), [machine.sv](machine.sv) and [tail.sv.in](tail.sv.in) reuse the established F16 CPU/controller/DDRAM harness. Current production T80/T80s, mapper_detect, mapper_ctrl, memory_decode, video and IO run with two independently executed CPUs. Observation-only ports expose the latch and existing CPU phase. The savestate adapter moves three forward declarations; the mapper adapter adds default null arms for std_logic metavalues in existing binary-exhaustive cases. No binary-input transition expression changes.

ROM code is immutable during each run and mirrored through mapped pages so banking does not replace the test instructions. Probe8123 returns its physical page; A000 returns05 and9000 returns06. WRAM is the established synchronous fixture array. A test input port7D selects Q routines; other IO uses production IO. This controlled stimulus is not a complete MiSTer/HPS/physical-controller environment. BIOS visibility is transcribed from the existing external-BIOS port3E/reset/restore contract, with mirrored instruction data; not a complete external BIOS boot.

| Program | Guest operations | Reference and completed restored mapping result |
|---|---|---|
| 0 | Read8123; LD A,03; LD(A000),A | bank03 / signature03 |
| 1 | LD A,(A000); LD(A000),A | bank05 / signature05: the intervening fetch/operands replace the earlier A000 read history |
| 2 | LD A,(9000); LD(A000),A | bank06 / signature06 |
| 3 | A000,9000,A000 repeated reads; later ordinary A000 store | bank05 / signature05 |
| 4 | HL=A000, DE=A000, BC=2; LDIR | A000 source-to-destination write suppressed, bank02 / signature02 |
| 5 | HL=9000, DE=A000, BC=2; LDIR | First write permitted from source9000, bank06 / signature06 |
| 6 | Terminal BC=1 LDIR; immediately following ordinary A000 store | bank00 / signature00. LDI/LDIR preserves A=0 from dispatcher; the following store writes00 |
| 7 | Guest writeFFFF=07 changes mapping; A000 read and store | bank05 / signature05 |
| 8 | DD-prefixed IX=A000; INC(IX+0) | Read-modify-write suppressed by last=A000; bank02 / signature02 |
| 9 | HALT; logical-future NMI; handler/return; A000 store09 | bank09 / signature09; Q is woken separately by a current Pause pulse before each perturbation |
| System E control | Program5, ten-clock CPU cadence and System E mapper priority | Generic A000 guard unreachable; bank02 / signature02 |

The original semantic guard is exercised in both directions, not replaced by an assertion that the internal latch matches itself. Logs show `A000 ... lasta000 D05 bank02` for blocked LDIR and `A000 ... last9000 D06 bank06` for allowed LDIR.

Ordinary15-clock and turbo10-clock cadences are used; System E uses10-clock CPU cadence with the consumer bypass. This checks the local ce_z80 contract, not the excluded global CE-phase audit. Prefix and HALT tests establish their relevance to latch reconstruction, not complete CPU instruction coverage.

The source/destination, repeating and terminal block paths execute in successful full replays. Capture sweeps include naturally accepted block fetches between iterations. Two full replay attempts at that fetch also expose the separate CPU-vector limitation below; those are not presented as successful between-iteration whole-CPU replays.

## 12–13. Accepted SAVE count and boundary coverage

**15 canonical completed SAVE cases**, each with three completed LOADs. These comprise programs0–8 at offset1200/period15, program4 offset500/period15, program9 offset3100/period15, programs4/5 offset0/period10, program8 offset800/period10, and program5 offset0/period10/System E.

Separate canonical capture sweeps: **21 runs ×180 =3,780 actual production acceptance observations** (ten programs at both cadences plus System E control). They vary request delay by `(case*37)%997` host clocks, covering fetch, operand read, memory write, repeat/terminal and mapping-change phases. Requests during a nonqualifying phase defer naturally; all observed acceptances are MC1/T2 with saved PC equal to fetch A. Requested phase, bus strobes/address, prior latch, accepted PC/phase/address and cycle are recorded in logs and [results.json](results.json).

The capture observer resets **only the request controller before ARM**, leaving the CPUs and mapper running naturally. These are real accepted capture points, **not completed DDR SAVEs/LOADs**. The exact count is not inflated into full transport cases. Earlier21×90 sweeps are retained as exploratory coverage, bringing all capture observations to5,670; the later180-case set is the canonical phase evidence.

Dynamic sampling is not an exhaustive enumeration of every legal instruction/input history. The universal closure argument is the mandatory bus ordering and complete consumer inventory, corroborated by these samples. Per-program MC/TS coverage and A000 read/write request counts are machine-readable; rare combinations absent from a finite sweep are not falsely claimed tested.

## 20–23. Replay, Q, repeated LOAD and SAVE-only

The independent reference executes P to actual accepted T and records12,000 logical host clocks of suffix S. It never loads a payload. DUT completes unshortened controller transport/flush/release, executes legal Q code, loads the same image, performs production canonical restart, then compares from post-historical-T2.

The primary full-replay scoreboard compares active CPU transfers and data, logical/physical addresses, complete mapper word, sticky detector evidence, last_read_addr, IO/GG, full CPU architectural/phase observations and the guest signature. All8,192 WRAM bytes are compared at suffix end. The detector timer is mature at T and preserved in its existing payload; this is not a new active-detection-window timing audit.

Q1/Q2 select distinct guest paths at0300/0400, toggle BIOS visibility through OUT3E, and perform legal Sega-register writes. Q3 uses0500 and writes8000 while the restarted AB-media detection window is open, producing actual Wonder Kid recognition. Examples include Q histories30396,3044A,303B4 and wonder0/0/1, while the saved mature history is restored. Different pre-LOAD fetch/latch addresses are observed at DIR, not deposited internally. No guest/mapper state is forced; only UI operation cooldown is bypassed.

**45 canonical LOADs, 546,045 exact host-clock comparisons and368,640 final RAM-byte comparisons pass.** Each case uses three different Q histories and reproduces the independent original suffix and signature. Canonical SAVE-only adds400 native-tick comparisons per case,6,000 total. The full900,000-clock flush and release guards are retained. Different Q histories do not survive the reconstructing read.

Two additional successful full runs are supporting evidence only: the initial pilot and the earlier HALT run without a deliberate Q wake. Including them gives17 successful full runs/51 completed LOADs. The corrected HALT run is canonical. They are not used to inflate the canonical matrix.

## 24–28. Non-injective candidate, surviving differences and proof limits

The strongest proposed counterexample needs equal complete v12 images but different last-read histories that reach a dependent write. The attempted distinction fails at the relevant semantic boundary: the **accepted clock itself** writes F into both latch histories. Requests and pre-acceptance observations do contain different values, including operand and refresh addresses; they are not a persistent post-T distinction. On LOAD, the same saved image is tested after three natural Q histories with different latch values. Every checked historical T2 replaces Q by F before any dependent consumer.

Every retained full-save image contains12,288 known64-bit words, including initialized unused bytes. No pair of complete current-v12 images with divergent future **caused by this latch** was established. We do not claim format injectivity merely because no pair was found, nor claim that three Q LOADs are two naturally reached identical SAVE images. The proof rules out survival/use of the proposed missing-latch distinction independently of such an image collision.

The exact reconstruction argument is in [contract.md](contract.md): before F is sampled, WR is high and no dependent consumer is possible; F is determined by restored CPU fetch state and does not depend on the stale latch; afterward the old value is gone and future samples determine the latch completely. Bank changes, prefixes, block repeat, HALT and selected NMI do not introduce an earlier consumer. Maskable interrupt acknowledge has MREQ high and is excluded from the accepted memory-fetch predicate. No new interrupt-policy audit was undertaken.

**No new guest-visible mapping divergence attributable to G09.last-read was found.** There are two explicit interrupted stricter replays:

| Retained log | Observation |
|---|---|
| [Turbo LDIR capture](p4_o800_t10_s0_c0.log) | Accepted PC012A, BC0001. Canonical post-T2 latch and full scored state match. At logical+10, the CPU vector differs (BC0000 reference /0001 DUT); last-read, mapper, bus, mapped data and every other non-CPU-vector scoreboard field are still equal |
| [Normal LDIR capture](p4_o1056_t15_s0_c0.log) | Accepted PC012A, BC0002. Post-T2 reconstruction matches; at logical+15, CPU vector differs (BC0001 /0002), with the non-CPU-vector projection still equal |

These assertions stopped at the first difference, so neither establishes a later guest-visible divergence or a completed replay. Neither is labeled PASS, a confirmed G09 defect, or a proved G01 root cause. The macro's generic fatal text says “Guest mapping replay differs” because it checks the combined vector; field decoding in results.json records that the first difference is confined to the CPU vector. No cause was pursued and no assertion was weakened to admit these traces.

They limit **whole-CPU block-restart replay**, not the last-read reconstruction proof: at the last instant when stale Q could matter, the actual latch has already been set to the same F, and it has no other consumer. Closing this cache obligation therefore does not certify the separate CPU-normalization obligation or erase these interrupted observations.

## 29–30. Minimal existing regression sanity

Two existing current-F16 regression fixtures were copied into this investigation so earlier evidence was not overwritten:

* F13 case0: PASS — saved detector evidence, Dahjee future route, first/repeated mapped-byte replay.
* F15 actual-T80 offset0: PASS — armed Evolution switch, F14 selector/history context, exact guest byte and three LOADs through current F16 restart. It is an interaction sanity check, not a rerun of all F14/F15 cases.

Current F16 CPU/T80s/controller sources are directly exercised throughout the new harness, including HALT plus later NMI, metadata installation, memory ownership and T1/T2. No broad F16 timing/NMI matrix or unrelated savestate suite was rerun. Prior F13 handoff, reset and EEPROM-pulse closures remain intact; the new Q tests independently restore the saved bank/visibility without a false handoff.

## 31. Run accounting and reproduction

Final exact totals are generated by [analyze.js](analyze.js):61 new elaborated targeted simulation runs plus2 existing sanity runs, **63 total**. Targeted runs consist of42 capture-sweep runs,17 successful full replays including the two supporting runs, and2 interrupted full replay attempts. Setup failures before elaboration (initial working-directory command and a testbench literal-spacing compile error) are not simulation cases or passing evidence.

Canonical coverage is21×180 accepted captures plus15 full SAVE/three-LOAD cases. Logs, every requested/accepted phase, latch-before-write events, first restart reads, Q history, source hashes, image files and failure projections are retained. Old90-case sweeps and the pilot remain clearly distinct. `analyze.js` rejects incomplete logs, passing logs containing errors, unexpected boundaries, changed production or staged/tracked changes.

From this directory:

```powershell
& 'C:/Program Files/nodejs/node.exe' prepare.js
powershell -NoProfile -ExecutionPolicy Bypass -File run.ps1 -Program 0 -Offset 1200 -Compile
powershell -NoProfile -ExecutionPolicy Bypass -File run.ps1 -Program 4 -Period 10 -Captures 180
& 'C:/Program Files/nodejs/node.exe' analyze.js
```

The generator is based on retained F16/F13 harness sources; production files come from current HEAD. The common wrapper uses testbench memory/IO inputs, not live SDRAM or a complete motherboard. Historical source variants differ only in capture-delay scheduling, HALT Q wake and fixture instrumentation; none changes production transitions. A generic full matrix can be reproduced from the named canonical cases and parameters above. The two interrupted replay commands are expected to stop at their retained mismatch; they are not positive regression commands.

## 32–34. Repository hygiene

Production RTL and v12 remain unchanged. `analyze.js` checks all75 tracked SMS/RTL/manifest inputs against HEAD and records hashes. Only investigation/test/report files were added. Earlier audit/fix reports and production tests were preserved. Disposable simulator libraries and waves are ignored; no Quartus artifact was produced. Nothing staged, committed, pushed or submitted as a PR.

`git diff --stat` and `git diff --cached --stat` are both empty.

`git status --short`:

```text
?? tests/
```

The untracked tests tree predates this task.

## 35. Final classification

**CLOSED - PROVEN RECONSTRUCTABLE.** Current production restart necessarily performs the historical fetch's qualifying logical-A sample before any possible last-read-dependent write. That sample produces exactly the uninterrupted post-accepted-T2 latch value, destroying Q history. All future latch consumers depend only on this reconstructed value and subsequent qualified bus samples. This is a complete local dataflow/order argument supported by real-T80 accepted-boundary and stored/restored mapping evidence; it does not depend on a missing collision being treated as a proof.

No G09.last-read fix, serialization or format change is justified. The other three G09 children retain their closed dispositions. The two separate CPU-vector observations remain explicit limitations of broader block-restart replay and were left uninvestigated under this task's scope.
