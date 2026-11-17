# F14 Evolution selector savestate investigation

**CONFIRMED - FIX REQUIRED.** Investigation only, on `investigate/savestate-evolution-selector`, based on committed F13 `eede89d` (`Preserve mapper detection history across savestates`). Production RTL and format v9 are unchanged. F06 remains unresolved and untouched. Nothing staged; no commit, push, PR, or Quartus build.

Two naturally reached Evolution states have identical existing saved Evolution representation and different physical Flash addresses under the same future bus activity. A real production T80 guest reads `$28` before SAVE/LOAD and `$48` afterward. SAVE alone preserves execution. These witnesses have completed all delayed switches before capture, isolating persistent F14 history from F15.

## 1. State inventory and host boundary

Sources: [Evolution state machine](../../rtl/evolution_mapper.vhd), [Flash address decoder](../../rtl/evolution_rom_address.vhd), [system wiring](../../rtl/system.vhd), [controller](../../rtl/savestates.sv), and [top-level wiring](../../SMS.sv). Relevant anchors: mapper declarations lines 56–82, reset 89–115, restore 116–143, switch consumption 166–189, record read 198–203, port writes 207–231, serialization 261–273; decoder selection 127 onward; system instantiation 555, address decode 1055, mapper packing 1478; controller capture 1020/1066 and restore 1111.

Classification: A architectural emulated state; B persistent execution history affecting future behavior; C current host configuration; D uniquely reconstructable; E functionally irrelevant/redundant; F requires further evidence outside F14. Reset values are zero unless specified.

| State | Bits | Ordinary update / future consumer | Current SAVE and LOAD | Class / ownership |
|---|---:|---|---|---|
| `bank61_r` | 8 | CPU OUT `$61`; low byte for later candidate/game selection | Saved extra `[15:8]`, also mapper `[7:0]`; restored exactly | A, emulated port latch |
| `bank62_r` | 8 | CPU OUT `$62`; high selector byte, including controls | Saved extra `[7:0]`; restored exactly | A, emulated port latch |
| `game_bank61_r/62_r` | 16 | Committed `$87/$97/$C7` switch copies current ports; drives current Flash base | **Not saved**; LOAD substitutes current saved port pair | A, active emulated selector; case1 disproves reconstruction |
| `prev_game_bank61_r/62_r` | 16 | Every committed game switch copies prior candidate; address decoder tests equality to `$2800` | **Not saved**; LOAD clears | B; case0 proves future address relevance; only equality predicate is consumed |
| `candidate_bank61_r` | 8 | OUT `$62` updates candidate pair if either byte changed; previous value becomes prior candidate | **Not saved**; LOAD substitutes saved `bank61` | B, case2 isolates this omitted value |
| `candidate_bank62_r` | 8 | OUT `$62` writes the same value as `bank62` | Not independently saved; restored from saved `bank62` | D: invariant `candidate62=bank62`, including reset/restore |
| `prior_candidate_bank61_r/62_r` | 16 | Changed candidate shifts old candidate here; next game commit copies to previous game | **Not saved**; LOAD clears | B, case3 isolates it; only eventual equality to `$2800` affects addresses |
| `reg3ffe_r` | 8 | Second falling M1 after memory write commits recognized mode `$85/$87/$97/$C7` | Saved mapper `[15:8]`, restored exactly | A, active menu/game view |
| `game_started` | 1 | First game commit sets sticky 1; gates future `game_launch` pulses with menu-launch arm | **Not saved**; LOAD sets mapper bit15 OR bit14 | B, incorrect for first-launch menu `$85`; case4 |
| `reg8c_r`, `regcd_r`, `reg63_r`, `reg88_r`, `reg8d_r`, `reg8e_r`, `reg8f_r` | 56 | CPU OUT corresponding ports; readback and video/GG interpretation | Extra `[87:32]`, all restored exactly | A, emulated latches; not host UI; no direct selector-address consumer |
| `launch_fetch_addr_r` | 16 | Completed data read following menu opcode fetch `$1380`; record-index lookup and collision aliases | Mapper `[63:48]`, restored exactly | A/B, historical emulated menu record |
| `reg3ffe_pending` | 8 | Memory write `$3FFE` | Extra `[95:88]`, restored exactly | A, pending command byte; phase belongs to F15 |
| `switch_pending`, `switch_armed` | 1+1 | Write arms first/second subsequent falling M1 stages | Not saved; LOAD clears | F/F15 pending phase; zero at all F14 captures |
| `record_read_pending_r`, `menu_launch_armed_r` | 1+1 | Opcode `$1380`, subsequent data read, and game launch | Not saved; LOAD clears | F/F15 operation progress; zero at all F14 captures |
| `old_m1_n` | 1 | Every enabled clock samples actual M1; reset 1 | Not saved; LOAD samples current M1 | Edge sampler; pending-stage correctness is F15, not changed here |
| `game_launch_r` | 1 | One host-clock pulse on first/armed game commit; cleared each clock | Not saved; ordinary clear applies on LOAD | Transient output to bank reset, not an extra persistent F14 payload bit; zero at captures |
| Sega `bank0/1/2/3` | 32 | CPU bank writes or `game_launch`; resets `00/01/02/03` | Evolution mapper `[47:16]`, restored by actual `mapper_ctrl` | A; existing unchanged regression verifies restoration and launch reset |
| Evolution enable / media | host mode + ROM CRC | Force or exact supported image CRC selects mapper | Current host/media identity remains in effect | C; constant for this correctness contract |
| BIOS/media routing | boot latch / media-control state | Generic system BIOS handoff and IO restoration; E132 LOAD chooses cartridge active | Existing controller/system policy retained | Existing shared state; checked via directed BIOS/banking regression; not changed |
| `ss_out[159:96]` | 64 | Constant zero | Upper output is discarded by the current 96-bit top-level wire | E currently; **not available saved history** |

Every `$61/$62` value implicated by the audit is a latch written by **guest CPU I/O**, including software running in the Evolution menu/BIOS. No host status/menu latch feeds those two registers directly. Changing current host mapper selection/media is outside the fixed-media contract and is not a way to reconstruct old guest state. The “menu configuration perturbation” tests therefore change the actual guest menu ports and board latches through legal bus writes. Current host configuration stays fixed; saved emulated latches must return to T. This corrects the potential ambiguity in the original static audit's phrase “current menu latches.”

## 2. Flash dataflow and non-injectivity

The pipeline is:

`OUT61/62 -> current port pair -> candidate / prior candidate -> completed game switch -> game / previous-game selector -> effective selector -> selector page or record-page override -> Flash address`.

OUT `$61` changes only the current low port. OUT `$62` changes the high port and, when the pair differs from candidate, shifts candidate to prior candidate. A committed game switch copies **current ports** to game selector and **prior candidate** to previous game selector. Repeated writes of an unchanged pair do not shift history; they cannot reconstruct an omitted predecessor.

The decoder first applies special selector aliases. In particular, selector `$4800` in mode `$97` resolves to `$2800`; in other game modes it also resolves to `$2800` when previous game equals `$2800`. The fallback table maps plain `$4800` to page `$4800` and `$2800` to page `$2800`. Other explicit record-dependent aliases cover `$4C00/$4E00/$5200/$6800`.

Recognized launch-record addresses then override that fallback using the record-index page table. `$20A8` chooses page `$2800` regardless of selector history. Unknown record zero takes the fallback, a supported production service/selector route exercised here. Final game address is `(game_page << 8) + rom_a_i[19:0]`, modulo 24 bits; ordinary Sega bank bits above bit5 are discarded. In menu/initial modes the 22-bit cartridge-relative address passes through. The dedicated history test checks menu return and record re-entry as well as ordinary game mapping.

The focused wrapper uses ordinary banks `00/01/02/03`, making `rom_a_i=A` for every tested ROM access below `$C000`. Its exact Evolution mapper word is `{record16, bank0, bank1, bank2, bank3, mode8, bank61}`. The production Flash decoder itself is instantiated unchanged. Separate existing bank-controller tests cover actual bank updates.

### Strong pair: previous-game history, case0

P for state A: select `$2800`; complete switch `$87`; select `$4800`; complete switch `$87`. P for state B: substitute `$2400` for the first selection. Both use the same physical media, current selector `$4800`, active mode `$87`, record zero, board latches zero, and Sega reset banks.

Both representations are exactly:

```text
mapper word 00F             0000000102038700
Evolution extra 01B/019     8700000000000000E1320048  (96 bits)
v9 marker                  484309, count 3
```

A has `game=$4800, previous=$2800`; B has `game=$4800, previous=$2400`. Reading CPU `$8123` yields A Flash `$288123`, B Flash `$488123`. The synthetic byte at those addresses is `$28` / `$48`. The test checks equality of **all existing Evolution representation bits**, and verifies the actual SAVE DDR words match it. Other peripheral fields are fixed fixture inputs; no claim of equality of unrelated full machine histories is needed.

Three further dynamic pairs separate missing items:

| Case | Same current saved representation, different omitted state | Identical suffix | A / B / restored result |
|---|---|---|---|
| 1 | Active game `$2800` vs `$2400`; both current ports `$4800` | Read `$8123` | `$288123` / `$248123` / `$488123` |
| 2 | Candidate `$2800` vs `$2802`; game `$2400`, previous zero, prior candidate `$2400`, current ports `$2801` identical | Select `$4800`, complete `$87`, read | `$288123` / `$488123` / `$488123` |
| 3 | Prior candidate `$2800` vs `$2802`; game `$2400`, previous zero, candidate/current `$4800` identical | Complete `$87`, read | `$288123` / `$488123` / `$488123` |

Case2 reaches the collision by changing low port `$61` without another `$62` write. Case3 changes candidates without committing a game switch. Both are stable states between completed instructions, not unfinished F15 switches.

Case4 saves initial menu mode `$85`, before any game has launched. LOAD derives `game_started=1` from mode bit7 even though the reference retains zero. The next completed game switch emits one `game_launch` pulse in the reference and none after LOAD. The actual shared bank controller resets banks on that pulse, so this persistent flag is required independently of the address-history witness. The focused case measures the pulse, not a new dynamically observed bank-data failure. A second reachable state with identical selector values and started=1 can be constructed by launching selector zero before returning to `$85`; mode alone cannot determine the sticky flag.

## 3. Accepted capture, replay, history and BIOS results

`case0..14.log` execute **45 real controller operations: 15 SAVEs and 30 LOADs**. Each requires the production controller to reach its accepted M1/MREQ/VBlank/X boundary and perform DDR serialization/restoration. The controller's boundary wires are connected to the same directed bus seen by the Evolution mapper. No selector/history register is forced; no snapshot word is edited. Only the UI operation cooldown is bypassed. Directed bus stimulus is supplemented by actual T80 timing below.

At every T, both switch phase bits and both menu-operation flags are idle. Completed `$3FFE` writes have received both required falling M1 events. `game_launch` has returned low. The record-override case likewise completes the launch after reading the record. F15 remains uninvestigated/unfixed; no pending-state preservation is proposed here.

The primary test performs identical P on reference and DUT, SAVE at T, legal post-save selector/board writes on DUT, LOAD, and identical future S. On the first `evolution_set` restore edge, case0 clears DUT previous `$2800` to zero; the reference retains it. The `RESTORE_EDGE` log records this **one host clock after the asserted restore signal**, after the VHDL update. With bus address zero, the decoder already differs `$280000` / `$480000`; the next probe `$8123` differs `$288123` / `$488123`. Case1 diverges immediately in active selector. Cases2/3 first develop the relevant address divergence on the completed future game switch. This distinguishes a transient restore discrepancy from a persistent guest-observable error.

SAVE-only compares the complete Evolution payload, mapper word, active/previous selectors and Flash address against the uninterrupted reference on every save-transport clock, as well as the following probe. All 15 cases remain equivalent (about 28,100 checked clocks each). No additional save-only mechanism was found in these quiescent F14 states; this does not close F15 around in-flight switches.

Every case then changes ports to `$6000`, commits a game switch and writes board port `$8C=$AA` before the first LOAD. The second perturbation instead uses `$9440`, menu `$85`, and `$8C=$55`. Both LOADs restore the same saved current ports/board registers, and reproduce the same DUT Flash result under S. The first/second LOAD difference suggested in the request **does not occur** here: missing state is deterministically normalized/substituted, rather than retaining arbitrary post-save state. Deterministically wrong is still a violation.

| Cases | Coverage / result |
|---|---|
| 0–3 | Four non-injective pairs and reference/restored divergence described above |
| 4 | Initial Evolution BIOS/menu `$85`; missing first-launch pulse |
| 5 | Recognized record `$20A8`; record-page lookup masks lost history and preserves address |
| 6 | Reset/initial mode `$00`; control, no tested address divergence |
| 7 | First `$2800` transition; control, no tested address divergence |
| 8 | Repeated same `$2800`; no history shift, control |
| 9 | Alternating `$2800/$4800/$2800`; previous `$4800` is cleared but does not select the `$2800` special predicate, control |
| 10 | Adjacent `$2800/$2900`, then `$4800`; previous `$2900`, control |
| 11 | Nonadjacent `$2800/$6000/$4800`; previous `$6000`, control |
| 12 | Immediately before candidate update: `$61` changed, `$62` not yet written; LOAD substitutes game `$2804` for `$2800`; Flash `$688523` vs `$288123` |
| 13 | Immediately after corresponding `$62` candidate update, before a game switch; same active-game substitution failure |
| 14 | Multiple alternating transitions ending `$4800` with previous `$2800`; address failure persists |

`history.log` independently checks reset, first selection, same-bank selection, alternating, adjacent, nonadjacent, menu return, game re-entry, and a completed `$1380` record-read/relaunch path. Menu `$85` passes CPU `$8123` through to Flash `$008123`; re-entry consumes the historical selector again. A recognized record preserves the current page but cannot generally prove future candidate/history equivalence. No unsupported claim about a named commercial title or visible video corruption is made.

## 4. Real CPU and existing regressions

`cpu.log` uses the production T80/T80s implementation, production video timing, unmodified Evolution mapper and address decoder, and full v9 controller SAVE/LOAD with CPU DIR register restoration. A small synthetic program performs actual OUT `$61/$62`, memory writes `$3FFE`, jump/fetch switch completion, `LD A,($8123)`, and OUT `$20`. Instruction bytes are mirrored across mapped Flash pages so execution can continue after the base changes. No selector internals are forced.

```text
CPU READ before   cycle658787  addr=8123 Flash=288123 DI=28
CPU SAVE_ONLY PASS accepted=1 game=4800 prev=2800 guestOUT=28
CPU READ restored cycle3388637 addr=8123 Flash=488123 DI=48
PASS F14 real T80/video accepted=2 actual OUT20 data before28 restored48
```

The CPU path is intentionally an unperturbed SAVE/LOAD witness; the primary reference replay separately supplies the required post-save perturbations. CPU instruction timings and the production video gate validate actual accepted-boundary reachability. Two normal time-zero T80 unknown-operand warnings occur before reset settles; asserted CPU data/address/mapper values are known. No pixel-level test is claimed.

All canonical logs are checked by `results.js` for PASS, zero errors/fatals/failures, complete capture counts, source hashes and clean production/index diffs. Regression adapters and assertions are copied unchanged from the committed-F13 investigation fixtures into this directory; old logs are preserved.

| Log | Existing coverage and result |
|---|---|
| `banking.log` | All existing directed mapper tests, including Evolution bank restoration/launch reset, generic BIOS handoff/frozen handoff/restore edge suppression, and System E mapper restoration: PASS |
| `f13_dahjee.log` | F13 saved detection history, Dahjee future route, first/repeated LOAD: PASS |
| `f13_deadline.log` | F13 deadline/fallback replay and repeated LOAD: PASS |
| `f07.log` | Existing 10-case modern SMS/System E HCounter controller/legacy format regression: PASS |
| `f08.log` | MD6 real timeout 80540, 160 repeated-snapshot state/pin cases: PASS |
| `f09.log` | Master Tap 4096 state/pin, phase, timeout and repeated-restore cases: PASS |
| `f10.log` | Paddle 896 directed cases, 3356 counter phases: PASS |
| `f11.log` | Lightgun 1,000,000 ordinary cycles and 32,000 held observations: PASS |
| `f12.log` | Paused System E actual CPU/PSG save-only replay, 2,552,454 comparisons: PASS; bounded capture CPU progress 7 / PSG 5, logical pause preserved |

There was no standalone existing Evolution ROM-address/selector BIOS simulation to rerun in the inspected test sources. The new production-module history, record-override and real-CPU cases supply that coverage. The directed banking fixture retains the earlier documented simulation adapter and excludes the stale 20,000-step historical random oracle; no new claim of an unchanged random differential PASS is made. Full dual-VDP pixel/beam tests and Quartus builds are unnecessary for unchanged production RTL and were not rerun.

## 5. Reconstructability and candidate fix, analysis only

**v9 cannot reconstruct F14.** Cases0–3 disprove injectivity of its entire available Evolution representation. Changing LOAD order or retaining current post-save history cannot restore T. Stopping overwrites alone also leaves stale runtime state. Saved current ports and saved launch record are useful inputs but cannot supply missing active/candidate/history values on every supported route.

There are 65 raw persistent bits absent from v9: game16, previous16, candidate16, prior-candidate16, and started1. Eight are uniquely reconstructable: candidate high byte always equals current `bank62`. Proof by induction: reset initializes both zero; every OUT62 writes both to the same byte (if unchanged, candidate already equals it); no other live assignment separates them; the existing LOAD also writes both from the same saved byte. OUT61 can separate the **low** bytes, as case2 proves.

The smallest direct representation preserving all raw F14 selector/history values is therefore **57 bits**:

| Proposed payload bits | Value |
|---|---|
| `[15:0]` | active game `{game62,game61}` |
| `[31:16]` | previous game `{prev62,prev61}` |
| `[39:32]` | candidate61; candidate62 reconstructed exactly from saved bank62 |
| `[55:40]` | prior candidate `{prior62,prior61}` |
| `[56]` | `game_started` |
| `[63:57]` | zero, validated reserved padding |

This is a proposed one-word payload, **not implemented**. It is the recommended minimal low-complexity architecture: explicit capture/restore of 57 bits, plus the proven 8-bit reconstruction, at the same quiescent architectural capture/restore point as existing Evolution state. It restores history from T rather than preserving perturbations. Coordinate any eventual capture-point changes with the separate F15 work; current controller captures Evolution at ARM and mapper word later at FREEZE, but the present idle witnesses are stable through both.

For strictly functional Flash/bank equivalence, full previous and prior-candidate values each have only one consumer: equality to `$2800`. The transition machine can instead retain two predicates, leaving a **27-bit sufficient functional representation**: active16 + candidate61 eight + prior-is2800 one + previous-is2800 one + started one. Updating the prior predicate from candidate equality and previous predicate from prior is closed under every ordinary transition. Other bits of those historical vectors never affect future output in the current production code. This is a possible further compression, not a proof that 27 is an information-theoretic minimum. It requires canonicalizing otherwise unused raw history or changing internal representation and would not preserve exact historical vector values. The 57-bit approach avoids that extra semantic change and satisfies the requested selector/history comparisons directly.

Available storage: v9 words `$02C..$02F` are unused. A prospective `$02C` payload plus `$02D` exact owner/width descriptor would use two 64-bit words (57 useful payload bits); slot stride/size and RAM regions need not change. There is **no existing validated v9 F14 space**: the Evolution module's upper 64 output bits are constant zero, discarded by the 96-bit wiring, and neither saved nor restored. Reusing them requires widening the transport and defining a validated extension. Silently putting new data into unused v9 words would not make existing v9 snapshots carry it.

Because explicit serialization is proven necessary, a future **v10 development format extension is warranted**, with exact marker/descriptor/padding checks and explicit legacy handling. It is not an assumption made before the investigation and no marker/layout has been changed here. The proposed 57-bit payload deliberately excludes F15 pending bits.

## 6. Legacy semantics and remaining limits

An old Evolution snapshot cannot tell whether its missing previous selector was `$2800`, which active selector preceded port edits, or which candidate existed before a partial write. A recognized menu record only masks certain immediate addresses. “Game already selected” or “menu currently active” alone does not establish history irrelevance for all future traces. Mode `$85` also cannot reveal the sticky first-launch flag. No universal exact legacy reconstruction exists.

For a future fix that promises exact resume, recommend **rejecting ambiguous legacy Evolution snapshots lacking the validated new history extension**, with a clear compatibility result, while retaining legacy behavior for other mapper types. Do not claim that initializing missing history to zero reconstructs T. A separately chosen best-effort compatibility policy could explicitly normalize to reset-history semantics, but that is a behavior change with known divergence, not a correctness fix and not recommended as exact restoration. Proving a narrower safely accepted legacy subset would need an independent invariant; this investigation establishes no broad “all menu” or “all launched games” exemption. Initial reset capture in case6 is a passing control, not a serialized proof that an arbitrary old snapshot was captured at reset.

F06 cartridge-RAM ownership remains unresolved. F15 pending operation state remains outside scope. No production/source-format fix was made, and no unrelated finding was reopened.

## 7. Repository hygiene

Final canonical evidence: **26 passing logs**, comprising 15 F14 directed cases, real CPU, history matrix, and nine existing regression runs. `results.json` contains source hashes and machine-readable results. Generated ModelSim libraries/wave/transcript artifacts are removed; retained files are test sources, simulation adapters, drivers, reports and logs. No FPGA build artifacts were created.

`git diff --stat`: empty (zero tracked changes).

`git diff --cached --stat`: empty (nothing staged).

`git status --short`:

```text
?? tests/
```

That untracked directory already contained the prior investigation evidence before this task; this investigation adds `tests/savestate_evolution_selector`. No commit, push or PR was created.

**Final classification: CONFIRMED - FIX REQUIRED.** The accepted-boundary non-injective pair, reference/LOAD mismatch and actual T80-visible byte divergence rule out a justified exclusion. Explicit restoration of historical emulated selector state is required.
