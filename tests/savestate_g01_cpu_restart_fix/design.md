# G01 restart representation, before production edits

Baseline faf7036e4450027f79cc639a731053dca29840ca. This records a proposed representation; simulation gates must pass before applying it to production.

The accepted predicate is an ordinary memory opcode fetch with ISet=00. With the production T80s bus sequencing and WAIT tied high, that is pre-edge MC1/T2. IR is the preceding opcode, not the byte currently being read. The preceding T1 has cleared Save_ALU_r and Read_To_Reg_r; MC1/T2 is not T_Res. Consequently no pending general ALU/register writeback survives the boundary. T2 uses old IR to select Prefix, SetEI, and Halt/Jump/Call controls before replacing IR with DInst. All T2 architectural effects must be inventoried, not just ED.

## Candidate minimal semantic classes

| Encoding | Meaning | Representative old IR |
|---|---|---|
| 0 | ordinary predecessor, no pending prefix/EI | 00 |
| 1 | pending CB | CB |
| 2 | pending ED | ED |
| 3 | pending DD | DD |
| 4 | pending FD | FD |
| 5 | pending EI action | FB |
| 6/7 | reserved, reject in new format | none |

Six classes require three bits in a fixed-width representation. This is semantic normalization rather than literal serialization of every old opcode bit. CB, ED, DD and FD select different next instruction contexts; DD/FD also determine the index register. EI affects IFF1/IFF2 at T2 and exclusion of immediate interrupt arbitration. Architectural HALT plus saved NMICycle already determine fetch PC suppression; no new HALT bit is proposed.

Other old-IR decoder outputs are overwritten or do not reach an architectural consumer at MC1/T2: Jump/Call are asserted only in their later microcycles; general datapath completion is outside the MC1/T1..T3 fetch clause; register increment/decrement is gated off at MC1/T2; the fresh instruction supplies its own decode before MC1/T3's register decrement and before later ALU consumers. Arith16_r/PreserveC_r are re-latched at T2/T3 before a meaningful ALU writeback. BTR_r can be stale but is not consumed in the fetch clause; it is overwritten at instruction-end before its next non-fetch T2 consumer. No_BTR is recomputed from I_BT/I_BC/I_BTR; with ISet00 those controls are zero. Thus repeat decisions belong to restored architectural BC/flags plus the correctly fetched ED instruction, not another saved repeat latch.

XY_State is overwritten by a pending DD/FD, cleared by pending ED or no-prefix, or retained by pending CB. The latter is accepted only for unindexed CB: indexed CB routes through MC6/MC7 displacement/opcode fetch rather than another MC1/MREQ-low fetch with old IR=CB. DDCB/FDCB can accept immediately before fetching CB with old IR=DD/FD; saving that DD/FD class reconstructs the index selector before entering MC6. Arbitrary repeated/mixed DD/FD remain accepted and choose the most recent prefix. XY_Ind/pre-index return state cannot survive as an independent needed distinction at the accepted MC1/T2: their next relevant use is preceded by prefix establishment/displacement sequencing. This reachability claim must be corroborated by real prefix-chain/index fixtures.

## Edge timeline for the original normal witness

* T-60 (cycle170521): fetch ED at0129, IR becomes ED, ISet remains00; Prefix becomes10 after the edge.
* T-45 and T-30: ED prefix MC1/T3 and T4 finish; next MC1 begins without consuming B0.
* Request cycle170558 sees MC1/T1; T-15 is the next fetch's T1 setup.
* T=170581: pre-edge PC/A012A, IR=ED, ISet00, Prefix10. Controller captures pre-T architecture and semantic class2, normalized NMI history. Reference simultaneously fetches B0, sets ISet10 and PC012B.
* T+1: ARM captures post-T IO/GG and freezes. No second CPU enable intervenes.
* LOAD restores architecture plus semantic class at DIRSet. Class2 seeds old IR=ED, with ISet00/XY cleared and MC1/T1 as before.
* F16 metadata installation remains later with CEN0. Historical T1 issues the mandatory fetch; historical T2 reads B0 and consumes seeded ED, obtaining ISet10. Sampling/GG remain held as in F16.
* The next enable executes LDIR's BC decrement, followed by its data read/write and repeat/terminal sequence. Reference and LOAD must match from post-historical-T2 onward.

The first lost information in baseline LOAD is the pending old-IR decoder class, erased by DIRSet's IR=00. It precedes the ISet mismatch and later BC difference.

## Alternatives

| Design | Assessment |
|---|---|
| A: exclude pending prefix/EI | No general bounded progress proof: an immutable ROM can contain an arbitrary or cyclic prefix stream. Paused capture may execute an unbounded amount seeking a canonical boundary. Changing acceptance also shifts shared capture timing. No format bits, but changes CPU boundary interface and F12 liveness contract; rejected |
| B: preserve six semantic classes | Three payload bits and small decode mux, unchanged acceptance, no RAM/DSP expectation. New CPU context ports through system/top/controller. v13 required. Legacy normalizes to ordinary. F16 order and G09 historical read unchanged. Verification must cover all classes and omitted pipeline state; preferred if proof passes |
| C: re-read preceding instruction stream | PC-1 is insufficient for DD/FD chains, mutable code, control flow and EI history. Replaying guest predecessors risks duplicate effects. Would need additional history/transport, exceeds B complexity; not proven |
| D: exclude some classes, preserve others | Inherits acceptance/liveness burden and still needs tagged state. No correctness or resource advantage over one three-bit field; rejected |

No boundary/progress change is proposed. F12 bounded coherent progress therefore retains the same endpoint. F16 sampler/GG ordering is unchanged; context is seeded at architectural DIRSet, not by advancing the sampler. G09 still gets exactly historical T1 then T2. Old snapshots without context cannot regain missing pending prefix/EI history; deterministic ordinary normalization preserves the existing legacy behavior, without claiming exact restoration of events never recorded.

## Pre-edit evidence convention

`proof_*` uses the unchanged v12 controller and a test-only side record captured at actual acceptance, with the proposed context restore port. This proves CPU representation separately from format transport. `quick_*` additionally shortens only controller flush latency to128 for these CPU prototypes and holds the fixture beam during global freeze (as production does). Neither is evidence of production v13 validation or physical SDRAM correctness. Final production integration must use the real writer/reader, no side record, unchanged flush, and exact guest scoreboards.

## Consumer-order detail supporting the representation

The actual T1 preceding SAVE may complete an earlier ALU/register write. A− is already **after** that T1, so LOAD must retain its architectural result and must not replay its writeback. DIRSet clears the writeback enables; synthetic T1 is bus setup. Each seeded representative (NOP/CB/ED/DD/FD/EI) is architecturally side-effect-free at T1.

At MC1/T2 the main datapath takes its fetch clause (MCycle1/TState<4), not the non-fetch/completion clause. Consequently its SP increment, WZ/jump/exchange/block-completion consumers are unreachable there. RegWE's 16-bit increment/decrement exception is explicitly gated to MC1/T3, using the **new** opcode and combinational register address. Ordinary register/ALU writeback is scheduled at instruction-end and consumed subsequently; its selected operands and addresses have refilled by then. An old Arith16_r/PreserveC_r value cannot write flags while Save_ALU_r is zero and ALU_Op_r is cleared; the new opcode relatches those controls before any later writeback. IncDecZ's block/DJNZ consumers likewise have their own earlier update in the new instruction.

T2's PC/R/refresh behavior uses saved PC/R/I, saved Halt_FF, and saved NMI entry. A maskable interrupt acknowledge cannot be accepted: T80s drives MREQ high for IntCycle1 in M1. All Mode0 M1 instruction lengths exceed T2, so no instruction-end arbitration occurs during synthetic T1 or historical T2. SetEI is the remaining old-IR IFF action; SetDI acts at T3 after the new IR has been installed. Prefix selection is the remaining old-IR index/instruction-set action. This isolates precisely the six classes rather than serializing pipeline fields merely because DIRSet clears them.

No_BTR is zero after an eligible ISet00 T1; the preceding prefix's completion also writes BTR_r=0. A contrary arbitrary deposited repeat bit is not a naturally accepted production state. Auto-wait is zero in an ordinary fetch (no IO acknowledge, WAIT fixed high), while BUSRQ is tied inactive in system.vhd. These invariants are production assumptions, not general claims about every possible T80 port configuration.
