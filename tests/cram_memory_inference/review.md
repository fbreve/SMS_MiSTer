# CRAM memory inference and savestate optimization

**Trial reverted.** Placed ALMs increased by 121 and M10K use increased by four.
All 204 tracked production files exactly match the entry v19 hashes.

## 1. Baseline

Branch `investigate/cram-memory-inference`, committed v19 HEAD
`1b2a52d87d2659c908d4f9f846416d14bfd85bea`. All existing F01–F16/G01–G12
closures remain the starting contract. No commit, push or PR is authorized.
The tracked tree and index were clean on entry; the existing `?? tests/`
directory contains prior investigation artifacts.

The retained production build is `tests/savestate_g08_fm/quartus_early`:
Quartus 17.0.2 Build 602 Lite, Cyclone V `5CSEBA6U23I7`, project SMS,
top sys_top, seed 1, fixed `BUILD_DATE "261025"`. All 137 retained inputs
were hash verified, and 135 tracked build inputs match HEAD after line-ending
normalization; two unused `.bak`/`.orig` inputs remain untouched. The exact
production QSF/SDC/QIP/IP are reused, with a fresh database. STANDARD FIT,
HIGH PERFORMANCE EFFORT, SPEED, final placement ALWAYS, ALM packing LOW,
physical combination/duplication/retiming and router duplication stay enabled.

Baseline needed ALMs 37,117; placed 38,599/41,910 (92.100%); fitted registers
48,880; synthesis registers 46,327; M10K 488/553; memory bits 3,818,050;
DSP 39. Worst setup +0.104 ns, hold +0.239 ns, reported timing violations 0.
There are inherited unconstrained setup/hold categories and 38 unique inherited
critical-warning messages. Qualification compares against these limitations;
positive reported slack is not a claim that previously unconstrained paths
have become constrained.

The six required predecessor reports were read before selecting the candidate;
their hashes and the 204 tracked source hashes are in [baseline.json](baseline.json).

## 2. CRAM architecture

Each VDP owns 32 × 12 bits = 384 bits, with two independent palettes physically
present. CPU writes and savestate restore writes use one clocked process:
restore has priority. Renderer lookup has one registered clock of latency.
Both entity clock ports connect to `clk_sys`; this experiment adds no domain.
The array initializes to FFF and has no runtime reset. Warm VDP reset preserves
its contents. All 12 bits must survive LOAD, even in modes not displaying CRAM.

SMS expands each two-bit channel into four bits. GG latches the even byte and
commits a 12-bit color on the odd byte, with the existing shifted word address.
TMS modes retain their fixed-color selection. System E has independent palette
owners and strobes. These frontend and renderer rules are unchanged.

Original capture exposes all 384 bits asynchronously and samples them at ARM
into an existing controller scratch record. Six DDR words contain each palette:
primary offsets 0x08–0x0d, secondary 0x12–0x17. LOAD validates/stages those words and
writes all 32 entries through the existing restore interface.

## 3. Current inferred implementation

The committed v19 Fitter reports CRAM exclusive placed ALMs of 364.3 for the
primary and 366.8 for the secondary, with 399/404 registers. Neither palette
appears in the synthesis RAM table or consumes an M10K. The full design reports
zero ALMs used as inferred memory. Thus the baseline palettes are ordinary
registers plus read mux/decode logic, not an assumed hidden MLAB allocation.
The structural audit retains the original hierarchy and memory tables.

## 4. RAM inference barriers

The 32-entry parallel asynchronous snapshot is the decisive extra read-port
requirement. Ordinary block RAM cannot expose its entire array in parallel.
The renderer's synchronous registered read is compatible with RAM. CPU and
restore form one prioritized write port, rather than two simultaneous writers.
Restore address/data selection is a mux; it need not prevent inference.
There is no asynchronous runtime array reset, internal byte enable or new CDC.
Initialization to ones and mixed-port OLD_DATA on a same-address renderer
read/write edge are requirements, not optimizations to discard.

## 5. Functional contract

Preserve CPU commits, restore priority, initial/warm-reset contents, every
renderer response and palette output, SMS/GG byte semantics, dual-owner
independence, SAVE-only guest suffixes, v19 payload layout, legacy imports,
repeated LOAD and deterministic restart at accepted legal capture boundaries.
No renderer cycle can be added. Private frozen transport may take additional
host clocks without executing guest work.

The accepted M1 memory-read bus boundary excludes an active CPU write. VDP
`data_write` is a registered pulse followed by a RAM commit on the next host
edge. Producer timing was checked rather than assuming that freeze clears a
pending write: /5 VDP sampling plus one host edge completes within /10 or /15
CPU write cycles; Evolution captures falling write edges and does not generate
a new commit at the rising end of a previous write. Real T80/VDP G03 baseline
coverage observed 361 eligible boundaries and zero pending writes; explicit
candidate monitors compare ARM contents with the completed scan and reject
CPU writes during scanner ownership.

Legacy 64 KiB System E LOAD omits the secondary palette payload but restores
the live value captured at ARM. Consequently the scan must run on **SAVE and
System E LOAD**. A SAVE-only scanner would break this established fallback.
The retained paired positive/negative test demonstrates the distinction.

## 6. Candidate architectures

| Option | Expected physical effect | Costs, latency, risks and proof |
| --- | --- | --- |
| A. Sequential snapshot | Removes the parallel read barrier; permits addressed memory | Two private clocks per entry; prove ordering, quiescence and packed image equivalence |
| B. Separate staging memory | Does not itself remove the live parallel array | Extra memory/transfer machinery; current scratch already supports validated LOAD; no demonstrated saving |
| C. Dual-port inferred RAM | Replace 768 live-array FF with two small M10Ks | +2 blocks expected, read Q/address mux overhead; preserve one-clock renderer and mixed-port OLD_DATA; verify actual inference/timing |
| D. Reorganize ports | Share CPU/restore writes and snapshot reads on A; renderer on B | No third port or CDC; scanner must exclude guest writes; selected with A/C |
| E. Remove snapshot state | No redundant bank proven: scratch also holds validated LOAD data | Would couple validation/application and widen proof scope; not selected |
| F. Change restore order | Existing word writes already suit RAM | No solution to parallel capture; unnecessary compatibility/restart risk; not selected |

The FF count is a structural target, not an ALM forecast. M10K consumption is
justified only by measured placement savings and passing timing. Unlike the
rejected G06 sequential experiment, CRAM already has naturally addressed words
and a registered renderer read; no 74-bit field scatter or owner reduction
tree is introduced. See [architecture.md](architecture.md) for the full analysis.

## 7. Safety analysis

Before production edits, the isolated component miter and real-CPU baseline
boundary test passed. [pre_edit_gate.json](pre_edit_gate.json) binds that gate
to the unchanged production source hashes; [design_gate.md](design_gate.md)
records the proof plan. Supported same-clock RAM semantics, unchanged renderer
latency, capture quiescence and exact image reconstruction justified the trial.
LOAD staging, format validation, G06/G10 snapshot storage, CPU reconstruction,
beam, phase, mixer and release logic remain outside the change.

## 8. Selected experiment

Replace `ss_D[383:0]` with addressed registered `ss_Q[11:0]` and `ss_rd`.
RAM port A selects restore/scan address while owned, otherwise CPU address.
Restore wins over CPU write. Q holds on writes and is consumed only following
a nonwrite scan edge; no unnecessary same-port OLD_DATA contract is imposed.
Port B retains the original registered renderer read. `ramstyle="M10K"`
requests block storage, subject to actual Quartus confirmation.

ARM sets address 0. WAIT lets the registered RAM read complete; COLLECT shifts
12 bits into the existing 384-bit scratch, advances the address, and repeats.
After 32 insertions, entry 0 occupies bits 11:0 and entry 31 bits 383:372,
exactly matching v19. Both owners scan in parallel. The scanner adds 64 private
host clocks before the existing freeze drain on SAVE/System E LOAD. Other
LOADs skip it. DDR layout, validation and subsequent restore order stay intact.
The host may observe later operation completion; the 64 scan clocks are
transport work, not an added guest or renderer cycle. Their contribution to
total wall time can overlap waiting for an already outstanding transaction.

Only five production files change: CRAM entity, VDP/system/top-level interface
wiring, and the controller's early capture states. No format version changes.

## 9. Functional results

The component miter compares the renamed committed CRAM and candidate every
renderer edge, initialized contents, all 32 addresses, adjacent/same-address
access, randomized 12-bit writes, restore priority, scans and repeated LOAD.
It passed 207,492 checks, including 200,000 random host edges, 25,051
same-address cases, 14,461 priority checks, 206 scans and three LOADs.

Paired original-v19/candidate controller tests compare **all 12,288 words**
of each of 16 images: four saved phase codes × two owners × two consumed-tick
values, randomized nonzero palettes, variable transport response, and three
LOADs each. The complete exported images match byte for byte. Both also pass
the old64 System E live-secondary fallback. The SAVE-only pilot fails that
fallback as expected, proving the added case detects the compatibility defect.
These metadata combinations are protocol coverage, not a claim that every
combination is naturally reachable from an actual CPU.

Native T80/VDP tests retain uninterrupted-reference pixel/status/CPU/RAM and
first-native-enable oracles, SAVE-only and repeated LOAD suffixes. Coverage
includes GG, SMS mode 4, Graphics I/II, text, mixed M3, scroll, 224-line, PAL
240-line, pending CPU/VRAM work, dual System E collision/IRQ, deterministic
and full-flush transport, and all 12 targeted G10 transport phases.
Read-only full-RAM probes exist only in copied simulation sources.
[source_bridge.json](source_bridge.json) proves unchanged production transition
logic after removing those probes; non-System-E fixtures also prove the final
System E LOAD refinement does not affect their compiled path.

Two inherited fixture issues were corrected without weakening an oracle:
v13 warm-up conversion now adjusts its extension descriptor consistently with
its tag; G10 phase calibration now uses the first modern LOAD instead of an
old64 LOAD. The old calibration fails identically on unchanged v19 because
modern full-SRAM restore adds work after the fixture's former last-VRAM marker.
Both baseline and candidate pass the corrected 13-LOAD/12-target sweep;
calibration distances are 372 legacy versus 53,770 modern clocks. Rejected
pilot logs are retained and excluded from passing totals.

All **16 native cases passed**, totaling **558,000 SAVE-only suffix checks** and **1,684,000 LOAD suffix checks**, with **58 modern LOAD replays** (13 in the phase sweep, three in each other case). All 12 targeted transport phases passed on unchanged v19 and the candidate. Format validation rejected 2,098 malformed images and accepted 420 valid cases; legacy/current import coverage passed 22 LOADs. The paired full-image export is 3,538,944 bytes with SHA-256 `fdf869feb491797d055773220ad462df6abcd8f51673655fa9cbff43bf476f85`.

[functional_gate.json](functional_gate.json) binds the passing logs, fixture hashes, complete-image equality, selected source hashes and 199 unchanged tracked files. [reproduce.md](reproduce.md) gives the commands. Quartus started only after this complete gate passed.
No exhaustive formal proof or physical hardware test is claimed.

## 10. Quartus results

The complete functional gate passed before build launch. The first analysis
attempt was stopped after the diff check caught CRLF whitespace artifacts on
three added VDP lines. Only those new line endings were corrected; canonical
HDL/source bridges and the complete functional collector passed again. Its
partial database/logs are retained in `pilots/quartus_newline` and do not count
as a physical result. The selected source hashes are bound to a second fresh
137-input build with unchanged settings. Analysis & Synthesis, Fitter,
Assembler and TimeQuest all completed successfully. The running wrapper retained
its original two-block forecast guard and stopped after the successful fit;
after verifying the four mapped blocks, assembly/STA resumed at `-StartStage asm`.
No synthesis/fit rerun, RTL change, setting change or seed search followed.

Analysis & Synthesis succeeded: 45,537 registers (−790) and 3,819,586 block
memory bits (+1,536). The RAM table contains **four** 32×12 simple dual-port
M10K instances, two replicas per logical palette. The initial expectation of
one true dual-port M10K per palette was **not** realized. Quartus serves the
two read paths with replicated storage receiving the same prioritized writes.
No production change was made to hide or compensate for that measured cost.
The completed fitter confirms 492 total M10Ks, four more than v19.

[inference_results.json](inference_results.json) checks all four elaborated
RAM parameter sets: `ADDRESS_REG_B=CLOCK0`, `OUTDATA_REG_B=UNREGISTERED`,
`READ_DURING_WRITE_MODE_MIXED_PORTS=OLD_DATA`, 32×12 M10K, no array clear,
and all 32 initialization entries equal FFF. The registered address implements
the original one-clock renderer response without an added output stage.

[early_results.json](early_results.json) verifies every built input against
[build_early_inputs.json](build_early_inputs.json), the passing pre-build gate,
fixed date and paired seed/settings. There are **no new warning types or
normalized warning messages**, including no new critical warnings. Both builds
retain 38 unique critical-warning messages and the same unconstrained setup/
hold categories. No previously unconstrained timing was repaired by this trial.

## 11. Resource deltas

| Metric | Committed v19 | Candidate | Delta |
| --- | ---: | ---: | ---: |
| ALMs needed | 37,117 | 36,062 | -1,055 |
| ALMs placed | 38,599 | 38,720 | +121 |
| Fitted registers | 48,880 | 48,116 | -764 |
| Synthesis registers | 46,327 | 45,537 | -790 |
| M10K blocks | 488 | 492 | +4 |
| Reported block memory bits | 3,818,050 | 3,819,586 | +1,536 |
| DSP blocks | 39 | 39 | 0 |
| Logic ALUTs | 46,835 | 45,342 | -1,493 |
| Routing ALUTs | 18,266 | 19,263 | +997 |
| Estimated recoverable ALMs | 2,055 | 3,237 | +1,182 |
| Estimated unavailable ALMs | 573 | 579 | +6 |

Needed utilization falls from 88.564% to 86.046%, while placed utilization
rises from 92.100% to 92.388%. M10K usage rises from 88.246% to 88.969%,
leaving 61 blocks instead of 65. The memory-bit metric counts mapped content;
the four complete M10K allocations cost more raw capacity than those 1,536 bits.

The palette conversion works locally: combined exclusive CRAM placement falls
from 731.1 to 18.4 ALMs (-712.7), and CRAM exclusive registers fall from 803
to zero. Each palette now has two M10Ks and 768 mapped content bits. Controller
exclusive registers remain 14,773, confirming that the existing snapshot/LOAD
staging was retained. Controller own placed ALMs rise 76.9, to 10,724.5, despite
own ALUTs falling by four. Unchanged scaler hierarchy own placement rises by
427.4 ALMs, from 2,391.8 to 2,819.2. These are physical allocation changes;
the scaler and other unrelated RTL hashes remain unchanged.

The official global counts decide the result. Quartus reports:

```
v19:       38,599 - 2,055 + 573 = 37,117 needed
candidate: 38,720 - 3,237 + 579 = 36,062 needed
```

Thus a lower needed count does not establish a lower placed count: the dense-
packing recovery estimate grows by 1,182 ALMs. The candidate saves logic and
registers, yet this fixed fit occupies 121 more ALMs and uses 997 more routing
ALUTs. Router average utilization stays 40%; peak falls from 66% to 65% in the
same X45_Y23–X55_Y34 region. See [structure_results.json](structure_results.json)
for exclusive hierarchy, RAM, routing and fanout tables. Fractional hierarchy
allocations are estimates and are not independently placeable device blocks.

## 12. Timing deltas

| Metric | Committed v19 | Candidate | Delta |
| --- | ---: | ---: | ---: |
| Worst setup slack, ns | +0.104 | +0.067 | -0.037 |
| Worst hold slack, ns | +0.239 | +0.231 | -0.008 |
| Core-clock worst setup, ns | +0.895 | +0.808 | -0.087 |
| Reported violating timing groups | 0 | 0 | 0 |

All reported timing passes with unchanged constraints. Global worst setup
remains HDMI shadow-mask RAM to OSD `dsp_width` (candidate bit 13, baseline
bit 19), with a 6.732 ns relationship. Candidate data delay improves from
5.753 to 5.685 ns, while skew worsens from -0.675 to -0.780 ns; their combined
effect reduces slack by 37 ps. Worst hold moves from primary sprite shifter 60
to secondary shifter 46, `shift0[5]` to `[6]`, and remains positive.

The worst core path changes: baseline mapper CRC to CPU IR, candidate PSG2
`cen_16` to controller `ST_FM_SAVE_FETCH`, a 9.313 ns relationship. Their data
delays are not a comparison of the same path. Queried candidate CRAM paths
have +9.889 ns from palette RAM to staging and +5.412 ns into palette write
enable. CRAM is not the limiting setup path in this fit.

[timing_results.json](timing_results.json) records endpoints, relationships,
skew and delay; the `early_paths_*.rpt` files retain detailed paths. This is
one paired seed-1 build under the retained production constraints, with the
inherited unconstrained categories described above.

## 13. Final decision

**B. REVERT — NO MEANINGFUL SAVINGS**

Functional equivalence checks and reported timing passed. The predeclared
safety plan requires a measurable placed-ALM gain, and this trial fails that
physical gate. Its substantial local/needed-logic savings do not yield a
qualified reduction in the requested placed footprint under the controlled
settings. Four additional M10Ks and slightly lower timing margins strengthen
the decision to retain v19.

All five production files were restored byte for byte. All 204 entry tracked
hashes match; HEAD, branch and index remain unchanged. The tested candidate is
preserved in [candidate/](candidate/), [experiment.patch](experiment.patch)
and the source-bound build. [restore_verification.json](restore_verification.json)
records both candidate and baseline hashes. No F/G obligation is reopened.
This one rejected fit does not establish that every RAM-based CRAM organization
will have the same placement result.

## 14. Recommended next target

A separate CRAM port-mapping study is the most directly supported next step:
determine whether one explicit true dual-port primitive per palette can share
CPU/restore writes and snapshot reads on A, with the renderer on B, without
the two replicas observed here. Same-port output during writes is outside
the consumed snapshot contract; renderer mixed-port OLD_DATA and one-clock
latency remain mandatory. This is a hypothesis, not a qualified saving.
Reuse the retained miter, exact images, legacy System E witness and native
replays, then require a fresh controlled fit with actual placed savings.
Do not reopen G06/G10 storage or consolidate formats to pursue it.

## 15. git diff --stat

Final `git diff --stat` is empty: production is restored.
The archived experiment before restoration was:

```
 SMS.sv            |  7 +++--
 rtl/savestates.sv | 31 ++++++++++++++++++----
 rtl/system.vhd    |  9 ++++---
 rtl/vdp.vhd       |  8 +++---
 rtl/vdp_cram.vhd  | 78 +++++++++++++++++--------------------------------------
 5 files changed, 66 insertions(+), 67 deletions(-)
```

## 16. git status --short

```
?? tests/
```

The untracked tests directory already existed on entry; this task adds its
scoped investigation artifacts. No tracked or staged changes remain. Branch
`investigate/cram-memory-inference` stays at `1b2a52d87d2659c908d4f9f846416d14bfd85bea`.
[final_verification.json](final_verification.json) checks the final report,
restored production, preserved candidate, evidence hashes, clean index and
diff whitespace. No commit, push or PR was performed.
