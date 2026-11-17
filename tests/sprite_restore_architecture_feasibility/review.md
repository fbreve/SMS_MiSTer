# G06/G10 sprite restore architecture feasibility, committed v19

**STOP — no proof-of-concept selected.** A genuinely different distribution mechanism is identifiable: private RAM near small groups of whole 74-bit slot records, with narrow transport terminating at those memories. It avoids the previous global packed-word scatter topology. However, direct installation into live registers leaves an unresolved existing-reset interruption window. A private FF commit stage addresses partial live-state exposure but recreates almost the entire snapshot bank and has no supported material physical saving. Neither presently meets the selection gate. This does not prove that future sprite optimization is impossible.

No production or candidate RTL was written. No synthesis, fit, route, simulation, Quartus query, additional seed, branch change or Git write occurred. New artifacts are analytical evidence and this report only.

## 1. Verified baseline and historical provenance

HEAD **1b2a52d87d2659c908d4f9f846416d14bfd85bea**, branch **investigate/cram-memory-inference**, v19 outer tag **0x484313**, 96 KiB image. All **204 tracked raw hashes** match the committed audit baseline; tracked/index diffs are empty. All **137 retained seed-1 inputs** match their raw manifest hashes; **135** independently match HEAD after explicit CRLF/LF normalization. The remaining two are unused `rtl/system.vhd.bak` and `rtl/vdp_background.vhd.orig`. The historical manifest's older HEAD label is not substituted for source identity. [provenance.json](provenance.json) records these checks and **117 retained report/evidence hashes**.

Controller SHA256: `e8de50db09447138fc661205fb9edd178d45e691819a056bad87631ef3d76557`.

Authoritative retained production build: [savestate_g08_fm/quartus_early](../savestate_g08_fm/quartus_early/), Quartus 17.0.2 Build 602 Lite, Cyclone V 5CSEBA6U23I7, SMS/sys_top, seed 1, BUILD_DATE261025, MISTER_FB=1. Performance/packing/physical optimization, constraints and IP remain unchanged. Fresh parsing of existing reports confirms:

| Current v19 seed-1 metric | Value |
| --- | ---: |
| Needed / placed ALMs | 37,117 / 38,599 of 41,910 |
| Mapped / fitted FF | 46,327 / 48,880 |
| Logic / routing ALUT | 46,835 / 18,266 |
| M10K | 488 of 553; 65 free |
| Block memory bits / DSP | 3,818,050 / 39 |
| Setup / hold | +0.104 / +0.239 ns |
| Reported violating groups | 0 |

Packing identity: `38599 - 2055 + 573 = 37117`. Existing unconstrained setup/hold categories and 38 critical-warning messages remain. This study does not expand signoff coverage. Controller exclusive allocation is 10,647.6 placed ALMs, 6,966 ALUTs and 14,773 FFs; its two rings account for exactly 9,600 surviving FF names in the retained inventory. Live receiver costs are separate. Hierarchy allocations, mux estimates, fanout and FF counts are not additive recoverable ALM charges.

The complete seven requested reviews were read, along with relevant machine evidence and the old sequential receiver implementation:

| Evidence / era | Finding carried forward |
| --- | --- |
| [Structural audit](../structural_resource_audit/review.md), v19 | Large storage/distribution costs; current seed-1 global setup limiter is HDMI, not an established sprite-control critical path |
| [Sequential architecture](../savestate_g06_sequential_architecture/review.md), v17 | 300×32 private RAM, +2 M10Ks, net −9,397 mapped FF, about +5,402 logic ALUT. Seed 1 failed routing. Seed 2 routed at 38,012 placed but setup −0.100 ns; its −586 comparison uses a seed-1 baseline and is not a qualified paired saving |
| [Sprite optimization](../savestate_sprite_resource_optimization/review.md), v16 | Common-mux extraction: +47 placed/+106 needed; masks: +9,532 standalone ALUTs. Neither removed the bank |
| [Storage investigation](../g06_g10_storage_optimization/review.md), v19 | Stable frozen SAVE sources supported; private LOAD lifetime persists; shared-ring/reread/scan alternatives failed selection gate |
| [Internal audit](../savestates_internal_cost_audit/review.md), v19 | Exact FF inventory; no isolated current ALM price for ring storage, restore or fanout |
| [Growth audit](../savestate_resource_growth/review.md), through v16 | G06/G10 transition: +9,603 mapped FF, +8,051 needed, +5,458 placed; not a current savings forecast |
| [CPU alias paired seed 2](../cpu_restore_alias_seed2_pair/review.md), v19 | −230 mapped FF produced only −4 paired placed ALMs; routing ALUT +105 and peak 72.8→72.9% failed gates despite positive timing. Candidate is rejected and is not production |

The v17 finite functional campaign supports its tested protocol, not a current v19 implementation or every reset-prefix case. Historical roadmap recommendations are not additional work authorized here.

## 2. Field-by-field producer, consumer and lifetime inventory

Production instantiates `system #(63)` at [SMS.sv:1013](../../SMS.sv:1013): 64 slots per VDP, two instantiated VDPs. Default/reduced eight-slot fixtures are not the production geometry.

Per slot: enable 1 + X 8 + cached planes 32 + shifted planes 32 + wideclock 1 = **74 bits**. Per owner: **64×74 = 4,736 slot bits**, plus **42 fixed bits** = **4,778 meaningful bits**, plus 22 transport padding = 4,800. System E retains two independent records: **9,556 meaningful bits + 44 padding**. [field_inventory.json](field_inventory.json) preserves all 17 meaningful field groups plus padding, exact offsets and source references.

Offsets below are relative to `74*i` for slot fields and absolute for fixed fields. Every field is captured from post-T held state at ARM, staged privately on LOAD, and currently consumed at the architectural restore edge.

| Field | Bits / owner record | Native producer | Consumer and access requirement |
| --- | --- | --- | --- |
| enable | slot +0; 64 bits | ce_spload: all-slot x257 clear, indexed successful load | All-slot pixel qualification; low eight also collision reduction. Parallel reads, indexed writes/all-slot clear |
| X | slot +1..8; 512 bits | Evaluator LOAD_X: X−1 or legacy X−33 | Every shifter's X/load comparison, shifted +8 and FF wrap exclusion; parallel pixel reads |
| cached d0 | slot +9..16; 512 bits | LOAD_0 / legacy LOAD_1 | Shifter0 reload source; indexed writes, concurrent per-slot reload availability |
| cached d1 | slot +17..24; 512 bits | LOAD_1; legacy zero/tall LOAD_2 | Shifter1 reload and legacy 16-bit history; differs from partly shifted copy |
| cached d2 | slot +25..32; 512 bits | LOAD_2 / legacy zero | Shifter2 reload and later mode changes; current legacy disuse does not permit omission |
| cached d3 | slot +33..40; 512 bits | LOAD_3 / legacy m2_flags copy | Reload/color; bit7 also affects native reload predicates |
| shift0 | slot +41..48; 512 bits | ce_pix load/shift | Pixel head and active; legacy shift1 feeds its low bit. Concurrent update across slots |
| shift1 | slot +49..56; 512 bits | ce_pix load/shift | Mode4 plane head and legacy shift0 continuation; concurrent update |
| shift2 | slot +57..64; 512 bits | ce_pix load/shift | Mode4 head; retain across legacy modes even when current output ignores it |
| shift3 | slot +65..72; 512 bits | ce_pix load; Mode4 shift, legacy retained color | Mode4 plane head or legacy low-four-bit color; mode-dependent concurrent access |
| wideclock | slot +73; 64 bits | Each slot load clears; other ce_pix toggles | Independent wide-pixel shift qualification; not one reconstructable global phase |
| data_address | 4736..4749; 14 bits | Evaluator COMPARE/LOAD_N/legacy LOAD_1 updates | Sprite VRAM address and subsequent fetches; scalar, not an all-slot port |
| m2_flags | 4750..4757; 8 bits | Legacy LOAD_0 | X offset and cached color/flag source; scalar history |
| color_reg | 4758..4761; 4 bits | ce_pix priority reduction | vdp_main color/CRAM selection; registered result must not expose partial reduction |
| collide_reg | 4762; 1 bit | ce_pix low-eight-slot collision reduction | Input to delayed collision pipeline |
| overflow_reg | 4763; 1 bit | Evaluator overflow/line reset under ce_spload | VDP status overflow; raw presentation branch needs ss_freeze gate |
| collision delay | 4764..4777; 14 bits | ce_vdp shifts and samples collide_reg | High tap affects collide_flag/status/IRQ; exact pipeline history |
| padding | 4778..4799; 22 positions | Literal zero at capture; meaningful bits rotate through positions during SAVE | Last DDR word rejects nonzero bits63:42. Not dead FF in the current representation |

Native-parallel access is different from parallel restore. In current RTL all 64 slots supply pixel load predicates and priority/color inputs concurrently; all shifters update on the same ce_pix. Cache writes are indexed, but simultaneous equal-X sprites can require concurrent reload sources. Scalar fixed fields do not intrinsically need a full-record parallel port. Frozen sequential installation could change the restore interface without changing native access, **if** isolation and interruption guarantees were proved.

All fields remain mandatory under current semantics; this is not an entropy proof that all 9,556 bits are independent in every reachable state. Existing reconstruction normalizes only evaluator WAITING/count0/index0: 3+7+6 bits per owner, outside this historical payload. It does not authorize reconstructing caches, partly shifted planes, wideclock, fixed fields or collision history.

Source: [vdp_sprites.vhd:59](../../rtl/vdp_sprites.vhd:59) arrays, record assembly:79, VRAM mux:114, ce_spload:135, restore/evaluator:145, pixel reduction:334; [vdp_sprite_shifter.vhd:37](../../rtl/vdp_sprite_shifter.vhd:37) state and restore/native update process; [vdp.vhd:190](../../rtl/vdp.vhd:190) delay and status restore:631. These are source observations, not new mapping results.

## 3. Current lifecycle and exact receiving edge

```text
accepted T completes normally
 -> freeze; ARM captures post-T sprite record
 -> SAVE:75 accepted low64 words/owner, private rotation on acceptance only
 -> LOAD:75 validated response words/owner, private insertion
 -> remaining metadata validation and memory transport
 -> restore issue R; both active VDPs consume independent records at R+1
 -> CRAM/flush/OPLL/peripheral work, CPU-only preparation
 -> phase/beam acknowledgment -> exact first native enable -> deterministic suffix
```

At [savestates.sv:1309](../../rtl/savestates.sv:1309), an eligible actual CPU/M1/MREQ VBlank boundary is accepted. CPU/NMI state is sampled at T, whereas [ARM:1325](../../rtl/savestates.sv:1325) samples post-T device history. Those edge classes must remain distinct. Freeze masks ce_vdp/ce_pix/ce_sp at [SMS.sv:1025](../../SMS.sv:1025). Evaluator writes require ce_spload; shifter/pixel result writes require ce_pix; delay shifts require ce_vdp. The raw overflow branch at vdp.vhd:652 explicitly requires freeze=0. The prior 3,278,000-edge baseline probe supports ordinary frozen SAVE stability, excluding reset/explicit restores; it is not rerun here.

[savestates.sv:601](../../rtl/savestates.sv:601) defines descriptor02e, phase/consumed-T/owner word02f, primary2901..294b and secondary294c..2996. SAVE sends 75 words per owner, including absent-owner zeros; 75 accepted rotations restore the captured ring representation. [Request/acceptance logic:788](../../rtl/savestates.sv:788) and registered transport ownership:2935 hold address/data/BE/burst through BUSY. A future local RAM fetch cannot count as DDR acceptance or permit cursors to skip a held request. Unexpected/stale responses cannot write private/live state.

[LOAD sprite:1645](../../rtl/savestates.sv:1645) checks descriptor, phase reserved/owner bits, high22 padding and every absent-secondary payload word. BG descriptor/positions, FM descriptor/row validity, EEPROM/accessory metadata can still reject later. A valid sprite record is not permission to write live state. Mapper restoration precedes optional NVRAM; only after the remaining transport does [ST_LOAD_RESTORE:2803](../../rtl/savestates.sv:2803) register CPU/VDP/PSG inputs and strobes at cram_entry=0.

Verilog NBA ordering makes the receiving edge **R+1**. VDP1 and active VDP2 consume independent 4,778-bit buses on that same edge, while frozen. The vectors through SMS/system/VDP/main are wires, not extra holding banks. [system.vhd:720](../../rtl/system.vhd:720) and:778 wire independent owners/strobes; vdp.vhd:235 forwards 4,764 bits to main and appends delay14; vdp_main.vhd:162 forwards evaluator/shifter fields.

`vdp_sprites` prioritizes ss_regs_set over ce_spload, installs enable/X/cache/address/flags/overflow and normalizes the evaluator. Each shifter independently prioritizes ss_regs_set over ce_pix and installs shifts/wideclock. A separate parent process installs color/collide; VDP's status process installs collision delay with IRQ/status. Missing history supplies zeros. Repeating the global pulse per slot would also repeat unrelated VDP/BG normalization/restores. A narrow installer needs distinct local writes and a final original architectural pulse that preserves already installed data.

[savestates.sv:2855](../../rtl/savestates.sv:2855) retains 32 CRAM writes, flush, F01 apply/refill, peripheral settlement, NMI release, semantic CPU replay and phase/beam acknowledgment. [SMS.sv:1696](../../SMS.sv:1696) installs phase0/10/20/25 with enables zero before native release. Extra local work may extend frozen wall time, but cannot add guest ticks, lose pending PSG work, change AudioMix/sample/OPLL history or logical host Pause, or change first-native CPU/VDP/pixel/sprite order. No new replay or long-suffix qualification is claimed here.

## 4. Incremental installation: successful schedule and interruption gap

A successful frozen schedule is plausible **after all metadata and the final expected DDR response/NVRAM write complete**, with dout_expected=0 and no pending DDR command. Keep all native enables masked. Install slot fields with separate local writes, keeping fixed color/collide/overflow/address/delay unchanged until final commit. Finish both owners, then issue the original architectural restore once. Subsequent FM/CPU/phase work retains its order. This avoids the shared-ring proposal's additional fallible external reread after the first live write.

Slot-derived spr_color/spr_active feed registered parent reductions only on ce_pix; raw overflow is freeze-gated. That supports successful-path isolation. It does not prove live fields stayed bitwise Q, all observers ignore a partial prefix, or an interrupted schedule is safe. The v17 local-port campaign does not supply a new v19 reset-prefix proof for this different topology.

### Reset is an existing interrupt

The controller's asynchronous reset at [savestates.sv:1165](../../rtl/savestates.sv:1165) clears freeze, strobes, pending transport and returns IDLE. It is connected to reset_active at [SMS.sv:1269](../../SMS.sv:1269). However, **vdp_sprites and vdp_sprite_shifter have no reset_n input or user-reset branch**. Initial signal values describe FPGA initialization, not runtime reset. Some parent architectural registers reset; the complete sprite history does not reset with them.

The falling-edge enable generator at SMS.sv:1696 has no reset_active branch. Masks at:1026..1028 depend on freeze, not reset_active. Therefore reset does not guarantee an eight/nine-clock rollback window: a native sprite/pixel enable can arrive before a narrow recovery completes. A long WRAM-clear/reset interval does not prove those sprite enables are held, since their masks do not test that reset.

Abstract prefix: Q is the pre-install live record; a nonempty proper set of slots has been overwritten from P; others remain Q. Reset aborts before architectural commit. The original receiver has no corresponding partial-slot writes; the proposed receiver retains a mixed prefix and can clock it after freeze drops. Differing P/Q fields illustrate this storage distinction, **not a newly simulated reachable guest waveform or proof every reset changes visible output**. The missing proof is equivalence of every retained prefix to existing reset/first-enable behavior across allowed inputs and modes. Display-off during reset is not proof that history is erased or later suffixes match.

A Q backup needs authority, surviving control and recovery bandwidth as well as capacity. Extending freeze through reset-time rollback changes the current reset protocol and requires an explicit equivalence proof. No new production defect or reopening of G06/G10 is claimed by this feasibility gap.

| Interruption / stage | Existing behavior relevant to sprites | Replacement obligation |
| --- | --- | --- |
| Late sprite/BG/FM/EEPROM malformed metadata | Private buffers may change; live sprites not installed | Keep P private; undoing an earlier mutation later does not satisfy rejection-before-mutation |
| DDR response timeout before installation | Existing ST_ERROR releases freeze on an eligible FSM edge; live sprites not yet installed | No live writes before final validation/transport; preserve watchdog and stale-response handling |
| Permanent BUSY before acceptance | Request stays stable; no automatic BUSY deadline is added | No issue-only cursor advance or new timeout policy |
| Pure local prefix after transport | Current receiver has no equivalent partial-slot phase | Prove observer isolation and bounded completion; avoid new abort/error exits after partial writes |
| User reset during prefix | Controller clears freeze; sprite/shifter history lacks corresponding reset clear | Restore/cancel authority before first native use; no such proof exists for this proposal |
| Failure after architectural commit | Existing memory/mapper/CPU/VDP/FM protocol applies | Do not add external reads or an error exit after updating only one owner |
| Repeated LOAD after success/rejection | Parser repopulates/initializes private state | Invalidate incomplete banks on reset/error; refill each active owner and fixed tail before use |

Current LOAD is **not globally transactional for all memory/mapper changes**: RAM may already have changed before a later transfer timeout, and mapper apply precedes NVRAM. This does not permit new earlier sprite mutations. Compare the actual per-bank guarantees rather than assuming either full global rollback or unrestricted early application.

## 5. A genuinely different physical mechanism: local whole-slot private banks

This is an analytical design, **not RTL or a selected experiment**. Partition each VDP into eight groups of eight existing native slots. Each group gets private 8×80 scratch: all 74 slot bits plus six internal zero positions. Native live registers remain FF and retain parallel pixel behavior. Keep fixed42 per owner in separate private FF for final architectural commit.

**Format identity: 64×74 = 4,736 = 74×64.** The first 74 DDR words contain slot fields only; word75 contains exactly fixed42 + public padding22. A bounded central accumulator repacks 74-bit records to/from unchanged64-bit words. Eight slots occupy592 bits, so successive group boundaries advance16 bits modulo the64-bit DDR word: no per-group padding may be inserted into the public image. A32-slot group occupies2368 bits =37 complete DDR words, an alternative analytical granularity rather than another implementation proposal.

- **SAVE:** select one frozen slot per group through a local 8:1×74 mux and write the whole word into local RAM. All groups can capture in parallel. No live scan or rotation occurs. The inactive secondary emits canonical zeros without altering its live state. Delayed capture is equivalent to ARM only under the held-source preconditions, including cancellation on reset.
- **LOAD gathering:** reconstruct each74-bit slot and write two40-bit halves into its selected group's private RAM. Global transport data terminates at RAM inputs instead of reaching every live-field D input. Keep original64-bit validation and all later checks. Incomplete RAM data must remain unconsumable under a clear validity protocol.
- **Installation:** each group reads one whole80-bit word and writes only its selected74-bit slot. Each data bit has at most eight local slot destinations; a three-bit index is decoded locally. System E's16 groups install concurrently from independent RAM contents. Eight slot-install edges plus initial synchronous read latency give a nine-edge data burst under this schedule, before handoff/final commit overhead. Fixed fields and original architectural strobes remain separate.
- **Ports:** capture, LOAD gathering, transport read and installation are distinct phases. Each width slice needs a write path and one synchronous read output, not concurrent native pixel ports. Both width slices supply the local restore word together. No read-during-write collision or native live-RAM access is required by this schedule. RAM need not have array reset if complete/valid and legacy-zero handling are proved.

The rejected design broadcast an eight-bit **packed-word** address and32-bit data to fields throughout both evaluators and all shifters. Fields tested overlap with32-bit rows and sometimes merged fragments; reads returned through a broad OR/reduction network. This proposal instead terminates narrow traffic at **local storage**, then writes a **whole slot with one local enable**, without per-field packed `ss_merge` at the receiver. All normal native cache/shift/priority logic remains. Local capture muxes and a bank-selection/return network still cost logic. Hierarchy names do not guarantee placement locality, and32 RAM locations can constrain placement badly; the physical benefit is a hypothesis, not a result.

## 6. Separated resource, port and cycle budgets

These are representation/access counts or explicit planning designs. None is a new mapping/placement result. Arithmetic is in [budgets.json](budgets.json).

| Architecture | Controller FF removed | Added FF / duplicated state | Memory/ports | Restore/access cost | Comparison / disposition |
| --- | ---: | --- | --- | --- | --- |
| Current rings | 0 | Existing9600 private plus9556 meaningful live bits; vectors add no FF |0 spriteM10K | Full ARM/restore;75 accepted words/owner | Production reference |
| Ordinary300×32 or width-only512×20 scratch | Nominal9600 | Prior32-bit net−9397 mappedFF is measured, not a new estimate | Measured2 M10Ks at32; theoretical480×20 fits one512×20 block | Prior150 rows/owner with packed-field scatter; other widths need repacking | Already rejected topology; dimensions alone are not a new mechanism |
| Local8-slot M10K shadow, direct install | 9600 | Example502 data FF plus unimplemented control; live9556 unchanged |16 groups×2 width40 blocks =32 intendedM10K; total520,33 free. Width32 fallback3/group=48, total536,17 free |8 capture writes/group;8 installs+initial read;128 halfword reads/writes/owner plus tail transport | New distribution; reset prefix unresolved; no PoC |
| Same local shadow using MLAB | 9600 | Same502 example data FF/control; output-register placement unknown |4×20×32 units/group =64 MLAB units,0 addedM10K; occupies memory-capable logic sites |8 capture writes; async-read or registered-output install schedule must be specified | Same reset gap, new inference/site-packing risk |
| Local RAM plus private parallel FF commit bank | 9600 | Recreate9556 private P FF, including fixed84; add418 bridge data FF (138+80+200) plus control. Live Q remains separate | Same32 intendedM10K or distributed-RAM family | Narrow private fill, then original atomic live restore | Addresses partial-live authority, but recreates storage; material benefit unsupported |
| Load-only local serial private FF shadows, direct frozen-live SAVE | 9600 nominally moved out of controller |9556 private receiver FF remain; narrow buffers, local indices and pipeline/control are additional. Only44 original padding positions disappear before overhead |0 extraM10K; no RAM port replication | Selected74-bit shadow consumes37 two-bit shifts;75 DDR words still serialize2400 pairs/owner including padding | Reset-safe authority can be retained; new serial/control topology, but bank-scale SAVE read selection and nearly all storage remain; not selected for a material-area PoC |
| Destructive live neighbor scan with private P | 9600 nominal | Live Q overwritten; rollback representation up to9556 bits plus controls/buffers | A selected300×32 P store uses2 M10K; a separate equally sized Q store another2; other banking possible |1-bit chain:4778 shifts/owner; two concurrent owner chains still4778 cycles | New scan wiring, but SAVE hold/observers/reset/recovery unproved |
| One4800-bit ring / OPLL tail with split owners | 4800 nominal | Simultaneous private second commit needs another4778 FF or a different receiver; Q recovery not free |0 extra for sharing/existing4864-bit tail; otherwise other-owner RAM | Split apply/reread/arbitration | Storage ownership does not solve receiver ports or timeout after first-owner mutation |
| Native cache/shifter conversion to few-port RAM | Depends on execution redesign; no justified ring deletion | Must still provide concurrent heads/X/reload sources or new scheduled working state | Naive per-slot parallel32-bit-plane access:128 blocks across owners with X/enable retained in FF; whole74-bit slot width40:256 blocks | New prefetch/bypass/deadline/collision/capture-phase proof | Native execution redesign, not a memory attribute; no safe schedule supplied |

### What is included in the local-bank example

**Information:** all9,556 meaningful bits remain. Slot memory holds9,472 useful bits plus768 internal pad bits =10,240 logical bits, apart from84 fixed FF. Internal padding never changes the canonical slot stream or word75.

**Memory width and replication:**32 M10Ks is a port/locality budget, not `ceil(9600/10240)`. Each group splits80 into two40-bit read/write width slices; a32-bit-only layout needs three. The fallback is a capacity/port estimate, not an assertion that its adapter retains the40-bit model's halfword counts and exact pipeline. The prior audit's40-bit mode is a planning assumption, not measured inference for this topology. No extra read-port replicas are required by the phase-separated interface, but actual inference must be checked in a future authorized implementation. Do not repeat the CRAM mistake of assuming a port-compatible mapping merely from bit count.

**FF data staging:** one explicit allocation is fixed tails84 + bit accumulator138 + slot assembly80 + registered40-bit return tree200 = **502 FF**. The accumulator covers63 pending output bits plus a74-bit slot, or73 partial input bits plus64 input bits. A chosen16→4→1 return tree registers4×40+40 bits. These are separate from live registers and hard-memory timing nodes. Approximately200 further control FF could be reserved for local indices/valid/commands and bridge bookkeeping; that is an illustrative allowance, not a derived minimum or implemented count. Under it, nominal source reduction is9600−502−200=8898 FF before further output registers/duplication. If all16×80 RAM outputs are implemented in external FF, add1280; they are not silently free.

**Mux/decode:**16 local8:1×74 selectors have1184 selected bit lanes, or8288 two-input mux positions before Boolean packing. All9472 live slot bits still need native-versus-install selection. The new override replaces an old restore choice; it is neither automatically another full mux nor automatically free. One-of-eight local enables, RAM capture-versus-transport input selection, global group/half/owner decode and a40-bit return tree remain. No conversion of those source counts to ALUT/ALM savings is justified.

**Routing:** the40-bit transport reaches32 RAM block inputs, not every live field. Local80-bit outputs reach eight slots/group. Capture commands reach16 groups, with local enables. Native evaluator/mode/priority/collision wiring remains. The final architectural pulse remains for CPU/VDP/BG/status/normalization; removing its slot-data uses could change fanout, but fewer loads are not an independent ALM credit. Actual proximity to M10K columns and fitter replication are unmeasured.

**Cycles:** eight capture writes and nine read/install burst edges assume all groups operate together and the stated synchronous latency. Add command acceptance, valid propagation, done observation, defaults and final strobe/phase release. Transport needs128 selected40-bit reads or writes/owner for64 slots, plus fixed-tail handling. A pipelined RAM/return path needs fill/drain; a conservative issue/wait bridge takes longer. No exact added operation latency is claimed without RTL. BUSY can extend transport under the existing contract. Extra wall time must not change the logical first-native event.

### Granularity trade within the same unimplemented family

| Slots/group | Groups across two VDPs | Intended width40 M10K blocks | Blocks free afterward | Data destinations/local bus | Capture / pipelined-install edges |
| --- | ---: | ---: | ---: | ---: | --- |
|4|32|64|1|4|4 /5|
|8|16|32|33|8|8 /9|
|16|8|16|49|16|16 /17|
|32|4|8|57|32|32 /33|
|64|2|4|61|64|64 /65|

Small groups buy locality using underfilled blocks and more return endpoints; large groups approach broad selection/distribution. The32-slot variant aligns37 DDR words/group, not a demonstrated physical advantage. This is an analytical trade table, not an implementation sweep; none is selected.

The installed vendor `cyclonev_mlab_cell` atom at `quartus/eda/sim_lib/cyclonev_atoms.v:1208` declares20-bit data and five-bit addresses; its XML parameter model has640-bit initialization. This supports the planning20×32 unit. MLAB consumes memory-capable logic/LAB resources; zero current MLAB usage does not establish free eligible placement sites or an exact ALM saving. No memory inference or physical budget is measured for these proposals.

## 7. Rollback capacity versus authority and bandwidth

For local banks, Q can be captured nondestructively into another eight rows/group before installing P. **P rows0..7 and Q rows8..15 fit in the same width-sliced blocks**, including a32-row MLAB model. Q backup does not inherently double32 M10Ks: it adds9472 meaningful RAM bits, another84 fixed-tail backup bits if held in FF, capture cycles, epoch/valid state and restore traffic. That capacity is real; it is not sufficient recovery.

Narrow rollback still needs eight installs plus memory latency. Reset clears the original controller's freeze and operation state; an independent surviving recovery engine or extended reset-time freeze would need a new exact reset-domain/enable proof. A bank-select flag cannot rewind overwritten live FF or make a few RAM ports supply all64 slots on the next native edge. No permission to change that reset contract is inferred. A failure requiring DDR rereading Q would additionally reintroduce an unbounded external dependency after guest mutation.

Conversely, a **private parallel FF commit bank** can be filled without touching live Q. Reset cancels its validity/strobe, leaving Q authoritative before architectural commit. The original receiving edge can then copy a complete P atomically; reset coinciding with that edge must retain existing priority behavior. This is a defensible atomic-install arrangement at the architectural level, subject to implementation proof and explicit operation/commit-phase correspondence.

Its area problem is different: removing9600 controller FF adds9556 private receiver FF plus418 bridge data FF in the explicit example, while retaining the live9556. The fixed84 are already included in9556 and must not be counted twice. This is9974 new private/bridge data FF versus9600 old private FF, or+374 before control/duplication, plus RAM. Simplifying FF-input muxes or replacing long global wires with local wiring could still help, so **FF count alone does not disprove an ALM win**. However, existing reports do not isolate a compelling recoverable mux/distribution budget for that extra copy and RAM. The current finite evidence does not justify it as the material next PoC.

A naive direct one-edge RAM restore requires at least `2*ceil(4778/40)=240` width slices before implementation details, exceeding65 free blocks. Returning to a full-width external FF stage recreates the storage being removed. Replacing normal all-slot pixel execution with few-port RAM instead requires a different scheduler: a nominal ten-host-clock pixel gap is insufficient proof, because accelerated evaluator writes occur every two clocks, same-X reloads can coincide, and capture/reset/first-native points may interrupt a prefetch/update pass. G10 phase codes do not automatically serialize new pending micro-operations. No faster clock or altered guest schedule is assumed.

### A reset-safe private shadow does not necessarily need RAM

An additional distinct option is **direct frozen-live SAVE plus load-only private per-slot FF shadows**. Keep a74-bit private P shadow beside each existing live slot. A selected shadow shifts a two-bit input through fixed local neighbor wiring for37 accepted pair steps; all other shadows hold. With low pairs sent first and `Pshadow <- {pair,Pshadow[73:2]}`, the completed37-pair result is exactly the original74-bit slot. The fixed42-bit private tail needs21 pair steps. The22 public padding bits are validated/generated rather than stored. Global inputs can be a two-bit stream plus selected owner/slot and local shift enable; the final architectural pulse consumes the completed local shadows atomically.

SAVE reads Q nondestructively through a registered, hierarchical two-bit selector; it does not shift live Q or require P shadows to capture Q. LOAD can fill private shadows before late metadata validation because they are not the live native registers. Invalid/incomplete shadows remain unconsumable; the architectural strobe stays suppressed on malformed input, timeout or reset. The receiving-edge/reset priority proof still must follow the existing global strobe, but there is no partially overwritten live-Q prefix requiring a RAM rollback. Neither RAM capacity nor a full-width RAM read port is an obstacle in this version.

All9472 slot shadow FF plus84 fixed shadow FF remain, so the only direct storage reduction is44 transport-padding positions before buffers/control. It does change the old bank-update graph: no live-Q capture choice on every shadow FF, no whole4800-bit SAVE rotation, no per-field packed32-bit merge, and no need to reset/clear every private FF if validity/defaults protect consumers. Narrow stream input reaches only selected local chains; local shadow outputs can replace long controller-to-receiver record wiring. These are genuine physical hypotheses, not the earlier common-mux extraction, which retained global capture/rotation/insertion.

The replacement read network is substantial. An unfactored binary selector over128 slots ×37 bit pairs has `2*(128*37-1)=9470` two-input mux positions for two output bits, excluding fixed tails and selection/control. Equivalently, local slot/pair selection plus a group-return tree remains bank-scale. Those are source-level positions, not ALUT counts, but they demonstrate that eliminating shadow input muxes does not eliminate the cost of reading every frozen live field. Local command registers/pipeline stages needed for timing/fanout are additional FF and logic. A global pipeline can hide latency while frozen, yet must preserve pair identity and stop on DDR backpressure without overwriting an accepted word.

The stream contains2400 two-bit units per owner for75 unchanged64-bit words:2368 slot units,21 fixed-history units and11 padding units. These are transfer-step counts, not complete operation latency; registered read latency, command/ack and DDR acceptance add time. No full-width FF register may be silently shifted while simultaneously being treated as immutable P at the final consuming edge. Repeated LOAD must finish every active private chain before commit, including independent System E state.

This removes the RAM-duplication objection and is architecturally safer than direct live installation. It may improve enable locality or packing; it is not rejected merely because FF count stays similar. The area case is nevertheless weak with current evidence: nearly the full shadow bank remains, a roughly bank-sized SAVE selector replaces part of its old input network, and pipelining/local decoding consume more resources. The earlier sequential experiment already shows that read/distribution logic can erase large storage wins. No disjoint measured cost or new source-level reduction establishes a **material net physical** advantage for this topology. It is retained as an unselected research possibility, not a selected implementation or a claim that such a distribution can never help.

## 8. System E, formats and independent lifetimes

P1 and P2 are independent, not two views of one record. Both must remain privately available until their complete installation and the original common architectural action. A local bank address must carry owner identity; group counters/done masks cannot let owner1 completion imply owner2 completion. Both eight-group sets must acknowledge completion in System E before either device's final architectural strobe is released. One active owner needs only its eight groups; inactive VDP2 must not acquire a new restore pulse or live write.

Runtime System E support prevents static deletion of the second store. Outside System E, SAVE still emits75 zero secondary words and LOAD rejects a nonzero absent-secondary payload. Legacy missing sprite history still installs all original zero defaults on the original active owners. Private RAM may remain physically unreset only if a clear valid/complete/owner protocol prevents stale records from becoming live, including after rejected/repeated LOAD and reset/session changes.

No format consolidation, field compression or reachability-only restriction is proposed. Preserve public64/public96 and every development/current tag accepted by the v19 parser. Keep descriptor, owner, padding/range, NMI/context and FM checks in their current semantic order; canonical slot packing and word75 are unchanged. Neither unused internal80-bit padding nor memory-bank alignment may change accepted external bytes.

The staging lifetime spans later BG/FM/EEPROM validation and all required memory transfers. Reusing F01's unused4864-bit scratch tail holds only one4800-bit record; it also requires port arbitration and a receiver mechanism. It cannot supply both original parallel records by capacity arithmetic. Re-reading DDR after applying one owner adds a timeout/source-immutability interval where ST_ERROR would release mixed P/Q; no current all-memory transactional guarantee fixes that new sprite-specific exposure.

## 9. Ranked decision and comparison with rejected mechanisms

| Rank / family | Plausible material scale | Semantic risk | Physical risk | Complexity / missing feasibility result | Decision |
| --- | --- | --- | --- | --- | --- |
|1 local whole-slot private banks, direct live install | Targets9600 ring FF with hundreds of example bridge FF, preserving information | High: reset during partial live install; independent owner authority | High but genuinely changed topology: RAM termination and local whole-slot enables;32 intendedM10K for eight-slot groups | Complete reset/abort authority and all-consumer isolation proof missing | NO-GO for PoC now |
|2 local banks plus private parallel FF commit bank | No large net FF reduction; possible simpler muxes/local wires | Lower architectural risk: Q untouched until commit; receiving-edge/reset proof still needed | Recreates9556 FF plus RAM/bridge; block sites constrain placement | A compelling non-overlapping recoverable logic/distribution budget is missing | NO-GO for material-area PoC now |
|2b load-only serial private FF shadows, direct frozen-live SAVE | Targets input-control/global wiring rather than bank deletion; only44 padding FF directly disappear | Lower authority risk: private prefix only; atomic architectural install retained |0 addedM10K, but9556 shadow FF and roughly9470 source mux positions for a full two-bit slot selector remain, before buffering/control | Need an evidence-backed material net locality/packing advantage rather than exchanging mux placement | Not selected; no material-area case established |
|3 distributed-MLAB local shadow | Same bank-scale target, different storage sites | Same partial-live reset gap | Memory-site allocation, inference and packing unmeasured | Both reset protocol and actual memory-site cost need support | NO-GO |
|4 destructive live neighbor scan | Nominal bank-scale removal; no packed scatter | Very high: SAVE-only hold, cross-field observers, prefix/reset/rollback | Replaces addressed distribution with broad scan enables and neighbor paths | Nondestructive SAVE taps or reversible scan plus exact abort proof missing | NO-GO |
|5 native-cache/shifter RAM scheduler | Could target live FF as well as shadows | Very high: ordinary execution, pending work and first-native timing change | Naive parallel ports exceed free blocks; scheduled ports/bypasses unproved | No complete native scheduler or exact boundary normalization | NO-GO |
|6 old packed-RAM width changes, shared ring/F01 tail | Memory-capacity or one-bank sharing only | Repeats split-owner/reread/recovery constraints | Packed scatter remains or arbitration is added | Does not independently solve the old receiver network | NO-GO; do not repeat |

The local-slot RAM mechanism differs from v17 **at the receiver**, not merely RAM organization: local native grouping, whole-slot write enable, transport terminating at private RAM, and removal of per-field packed32-bit merging. The serial private-FF alternative instead retains atomic FF authority with load-only local chains and direct non-destructive SAVE. Both are genuinely distinct; neither has a demonstrated net material physical budget. A claimed benefit requires replacement logic/storage to fit and place better with all physical gates, rather than only fewer controller-local FF or narrower external wires.

The common-mux and parallel-mask trials retained the full bank and wide-control regime; the former increased placed ALMs and the latter expanded logic substantially. The300×32 trial removed the bank but added thousands of ALUTs and failed qualification. Width20/32/64 changes that retain its broad field-decode/reduction/scatter graph do not answer that failure. Local slot banks change that graph, but their direct-live form has an unclosed reset contract. Adding the safe private commit bank changes the area argument back toward full duplicate storage. This distinction prevents disguising the rejected experiment as a new RAM layout.

The CPU alias pair also shows why neither logical FF removal nor a passing second seed establishes usable placed improvement: −230 mappedFF became −4 placedALMs with failed routing gates. This is a caution about measurement, not an ALM-per-FF predictor for sprites. No current proposal is promised500,1000 or any other placed-ALM saving.

## 10. Correctness obligations, not newly claimed test results

Before any future authorized implementation, a selected architecture must provide:

- A complete field/owner mapping and source-bound receiving-edge and interruption proof. Preserve all9556 meaningful bits, evaluator normalization, status/IRQ, collision delay and mode/width behavior; do not normalize additional history on appearance alone.
- Identical canonical bytes and accepted formats, including public imports and legacy defaults. Late BG/FM/EEPROM rejection must never expose live sprite writes. Rejected operations may mutate private scratch only where current lifetimes permit it.
- Exactly-once accepted DDR ordering under arbitrary qualified BUSY and stale responses, original read-timeout behavior, reset at every local capture/install prefix, and repeated LOAD from distinct Q. Reset must be compared at explicitly matched operation/commit phases; extra elapsed time does not excuse an unproved retained prefix.
- Independent System E records and completion, with no new inactive-owner mutation. Any staged work must finish before the original CPU/VDP/PSG architectural action and final release sequence.
- SAVE-only coherence, first-visible/line-transition/collision/overflow cases, all saved phase classes, strict first-native enable order and long deterministic suffixes. CPU/NMI/private preparation, PSG pending tick, AudioMix phase/sample, OPLL apply/refill and host Pause must retain their existing contracts. No grace cycles or observation masks.

No candidate exists here, so no newly rerun simulation or functional qualification is claimed. Historical passing tests remain preserved evidence under their recorded scopes. This report is source analysis and arithmetic only.

## 11. Exactly one recommended next action: STOP

**STOP at architectural feasibility. Do not implement a sprite PoC or launch Quartus.** The missing result is a concrete topology combining existing reset/abort authority and first-enable behavior for both owners with a compelling **net material area mechanism after replacement storage, selectors and control are counted**. Direct live installation lacks its reset/authority proof. Private atomic-commit variants address that hazard but retain nearly all shadow FF and add or relocate substantial selection/distribution. Retaining FF is not automatically disqualifying; the missing part for those variants is a sufficiently supported physical benefit argument. The evidence bounds the trade but does not supply the combined result.

The private commit-bank variant remains an unmeasured distribution trade, not a selected fallback experiment. No material placed-ALM reduction is established. This is the request's conditional STOP outcome, not proof every architecture must fail. There is no recommendation to rerun300×32, sweep seeds/widths, change reset/format behavior, remove history, borrow OPLL machinery or expand into unrelated optimization. Await review before any implementation or further experiment.

## 12. Preservation and final Git state

[verification.json](verification.json) records final checks of204 tracked hashes,137 retained seed-1 inputs,135 normalized HEAD matches,117 frozen report/evidence hashes and unchanged branch/HEAD/index. Existing seed-1/seed-2 builds and untracked reports were read in place and preserved; no new candidate tree was created. New files are confined to `tests/sprite_restore_architecture_feasibility/`.

Final git diff --stat:

```text
(empty)
```

Final git status --short:

```text
?? tests/
```

Production remains committed v19. No synthesis, fit, route, Quartus query, simulator, commit, push, merge, PR, branch change, checkout, reset or clean. **No PoC selected; stop after this report.**
