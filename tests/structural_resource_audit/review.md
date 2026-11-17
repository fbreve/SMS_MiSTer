# Structural FPGA resource audit

## 1. Executive summary

**B. SIGNIFICANT OPTIMIZATION OPPORTUNITIES.** Significant storage/control structures are measured, but **no timing-qualified ALM saving is established by this audit**. This classification identifies justified experiment targets, not a deployable optimization or proof of major structural waste.

The dominant savestate expansion is two 4,800-bit register snapshot rings. G06/G10 added 9,603 synthesis registers, 8,051 needed ALMs and 5,458 placed ALMs, without adding M10K. The current controller alone occupies approximately 10,648 fitted ALMs; both live sprite evaluators together occupy 4,145 ALMs excluding their shifter children. These are concentrated costs, not evidence that all those ALMs can be recovered.

Both developer concerns have substance. RAM-like structures exist in registers, particularly the sprite scratch and CRAM. However, the Fitter reports **zero ALMs used as memory / zero MLAB cells**: ordinary FF banks with update muxes are the issue, rather than a large inferred distributed-RAM allocation. High fanout and physical duplication are also measured. They do not establish a proportional ALM penalty, and they are not the selected global setup bottleneck. That path is routing-dominated HDMI shadowmask-to-OSD logic.

Prior experiments rule out easy conclusions: snapshot mux extraction increased placement by 47 ALMs; sequential sprite scratch failed routing at seed 1 and setup at seed 2; format consolidation increased placement by 27 ALMs. Do not repeat those experiments unchanged. Start with a bounded CRAM interface/inference experiment, then investigate local sprite data/control distribution before considering any revised sequential snapshot architecture.

Investigation only. No production RTL, format, constraints or settings changed. No synthesis, fit, assembler, commit, push or PR was performed. One read-only TimeQuest query used the retained v19 database.

## 2. Baseline identification

- Branch: `investigate/structural-resource-audit`.
- HEAD: `1b2a52d87d2659c908d4f9f846416d14bfd85bea`, “Preserve FM sample state across savestates”, 2026-10-27.
- Format v19, outer tag `0x484313`, unchanged 96 KiB container.
- Retained build: [v19 Quartus directory](../savestate_g08_fm/quartus_early/), Quartus Prime Lite **17.0.2 Build 602**, Cyclone V **5CSEBA6U23I7**, SMS revision, `sys_top`.
- Seed 1, fixed `BUILD_DATE261025`, `MISTER_FB=1`, fresh source-only build database. No incremental result is substituted for a fresh fit.
- STANDARD FIT; HIGH PERFORMANCE EFFORT; SPEED; final placement ALWAYS; ALM register packing LOW, automatic register packing NORMAL. Physical combinational optimization, register duplication/retiming, and router LCELL insertion/logic duplication enabled. Exact effective settings are extracted in [tables.json](tables.json); source settings are in `SMS.qsf`.

[Baseline hashes](baseline.json) bind all 110 tracked HDL files and primary reports. [Source verification](source_verification.json) verifies all 137 retained build inputs byte-for-byte against the build manifest. All 135 tracked inputs match HEAD after CRLF/LF normalization; the two untracked `.bak`/`.orig` manifest files are unused backups, not production inputs. The build manifest predates the commit and names F06 HEAD; actual source comparison, rather than that old HEAD label, establishes its applicability to committed v19.

Read the four available requested prerequisite reports: [growth](../savestate_resource_growth/review.md), [sprite optimization](../savestate_sprite_resource_optimization/review.md), [sequential architecture](../savestate_g06_sequential_architecture/review.md), [format consolidation](../savestate_format_consolidation/review.md). **`tests/timing_history/review.md` does not exist**. Used retained [v19 timing review](../savestate_g08_fm/timing_review.md), full current setup/hold/core path reports, historical STA summaries and sequential-experiment timing analysis instead. This missing document does not leave the current timing metrics unmeasured.

## 3. Complete resource baseline

|Metric|v19|Capacity / qualification|
|---|---:|---|
|ALMs needed|37,117|41,910; 88.564%|
|ALMs placed|38,599|41,910; 92.100%; 3,311 remaining|
|Fitted registers|48,880|167,640; 29.158%|
|Synthesis registers|46,327|Global map summary; not just dedicated-logic hierarchy column|
|M10K blocks|488|553; 65 remaining|
|Logical block-memory bits|3,818,050|5,662,720; 67.424%|
|DSP blocks|39|112|
|Fitted combinational ALUTs|46,835|Not an ALM count|
|Route-through ALUTs|18,266|Not additional independent ALMs|
|Worst setup / hold|+0.104 / +0.239 ns|Zero negative-TNS summary categories|
|LUT+register / LUT-only / register-only ALMs|11,546 / 16,214 / 10,839|Sum 38,599; memory ALMs 0|
|Recoverable B / unavailable C estimates|2,055 / 573|38,599 − 2,055 + 573 = 37,117|

Do not treat nominal unused FF capacity as available ALM capacity, or unused bits inside allocated M10Ks as free blocks. The 65 completely free blocks contain at most 665,600 raw bits; port configuration and placement can constrain use further.

Router estimates average interconnect 40%, peak 66% at X45_Y23..X55_Y34. Fitted routing resources include block interconnect 51%, C4 54%, R3 53%, C2 48%, R6 42%, C12 36%, R14 43%. These are different metrics, not conflicting congestion estimates. Full extraction: [tables.json](tables.json).

No new normalized warning types or messages versus F06. The retained build has the same 38 unique critical-warning messages and inherited unconstrained setup/hold categories. PLL reset/locked connectivity, incomplete I/O assignments, ignored fast-I/O assignments and synthesized-away objects remain. This is not a warning-free or fully constrained signoff claim. See [original warning ledger](../savestate_g08_fm/early_results.json).

## 4. Hierarchical resource breakdown

[hierarchy.json](hierarchy.json) contains **455 fitted entities** and the complete synthesis hierarchy. `emu` subtree: 30,853.3 placed ALMs and 429 M10Ks. Remaining framework allocation: approximately 7,745.3 ALMs and 59 M10Ks. `emu` includes video processing, host I/O, PLL reconfiguration and memories as well as emulation; it is not all savestate logic. Scaler subtree is 2,394.7 ALMs/43 M10Ks; audio output subtree 1,004.2 ALMs; HDMI/VGA OSD 558.6/507.4 ALMs and four M10Ks each.

Parent totals include descendants. Parenthesized own counts exclude them. Rank by **exclusive placed allocation** to avoid double-counting live sprite shifters under both evaluators and individual children. Hierarchical fitted ALMs are fractional allocation estimates; sums differ from integer device totals through rounding/shared packing. Exclusive allocations sum to 38,599.2 versus root estimate 38,598.6 and official integer 38,599. The map and fit hierarchy FF columns exclude some I/O/DSP categories; use summary totals for whole-chip FF.

Flattening, sharing, retiming, register packing and duplication prevent an exact independent physical charge per RTL construct. A module allocation is not its removable ALM saving. RAM instance rows include replicated implementations; count actual fitted blocks, not just HDL declarations.

## 5. Top 20 resource consumers

The full table, with hierarchy paths, own placed/needed ALMs, own combinational ALUTs/registers and subtree memory/M10K counts, is [top20.md](top20.md). These 20 exclusive consumers account for approximately **25,010 ALMs / 64.8%** of placement. Per-consumer mux, inferred-memory and warning interpretation is in [top20_notes.md](top20_notes.md). No inferred RAM in a consumer is reported as register storage merely because its parent has many FF.

Largest own allocations: savestates 10,647.6; scaler 2,391.8; primary sprite evaluator 2,081.5; secondary sprite evaluator 2,063.0; board top 995.0; host I/O 683.0; core top 590.7; T80 560.5; HDMI OSD 558.6; HDMI PLL adjustment 551.3. Shifter child instances remain in the complete hierarchy even though each is below the top-20 cutoff.

## 6. Historical resource attribution

|Checkpoint|Commit|Needed|Placed|Synth FF|Fit FF|M10K|Memory bits|DSP|Setup/hold ns|
|---|---|---:|---:|---:|---:|---:|---:|---:|---|
|Pre major expansion, untagged|8443a0d|26,465|31,531|34,857|35,709|487|3,809,858|39|+.508 / +.144|
|Before G06/G10, v13|8ffd15e|27,368|32,684|35,896|36,831|487|3,809,858|39|+.483 / +.213|
|After G06/G10, v14|5858318|35,419|38,142|45,499|48,002|487|3,809,858|39|+.384 / +.226|
|After G05, v15|f205b05|35,945|38,718|45,808|48,385|487|3,809,858|39|+.211 / +.232|
|After G12, v16|cb2e861|36,300|39,001|45,808|48,428|487|3,809,858|39|+.465 / +.198|
|After F01, v17|7fcd5e1|37,175|38,598|46,289|48,948|488|3,818,050|39|+.105 / +.206|
|After F06, v18|854761c|37,131|38,450|46,290|48,899|488|3,818,050|39|+.366 / +.234|
|Current, v19|1b2a52d|37,117|38,599|46,327|48,880|488|3,818,050|39|+.104 / +.239|

[history.json](history.json) retains report locations and extracted hierarchies. The original [growth measurements](../savestate_resource_growth/measurements.json) and source-verification ledger establish earlier identities. Selected G06 is **`quartus`**, not the abandoned `quartus_failed_congestion`; selected G12 is **`quartus_candidate`**, not its v16 pre-change control. Use official summary counts rather than rounding fractional entity allocations independently.

Common device/tool/performance/packing settings and seed 1. Dates differ across the chain; matched-date controls reproduce preceding endpoints in the original investigations. Thus adjacent controlled deltas are useful; arbitrary distant extrema are not a single-factor experiment. F01 versus G12: +875 needed but **−403 placed**, +481 synthesis FF, +1 M10K. F06 versus F01: −44 needed/−148 placed, +1 synthesis FF. v19 versus F06: −14 needed/+149 placed, +37 synthesis FF/−19 fitted FF. These are real remapping/packing effects, not contradictions or negative state widths.

## 7. G06/G10 cost analysis

The exact transition adds **9,556 meaningful sprite-history bits**, transported in two 4,800-bit FF rings, plus two phase bits and accepted-tick history/control. One sprite record contains 64×74 slot bits plus 42 fixed bits: enable 1, X 8, cached planes 32, live shift planes 32, wide phase 1 per slot; address 14, mode flags 8, output color 4, collide 1, overflow 1, collision delay 14 fixed.

Measured synthesis controller FF: 4,838→14,439 (**+9,601**); core top net +2. Controller combinational ALUT: 5,390→6,003 (+613). Controller exclusive fitted placed allocation: 5,387.5→10,190.1 (+4,802.6), with other net hierarchy allocations accounting for the rest of whole-chip +5,458. Whole-chip fitted logic ALUT +5,818; route-through ALUT +5,399; fitted FF +11,171 versus synthesis +9,603 (additional net physical overhead 1,568). These deltas overlap and must not be added as independent charges.

Capture/clear/hold/SAVE rotation/LOAD insertion induce multiway FF-input selection. Current map explicitly lists **8:1×4,736** and **9:1×4,736** snapshot mux groups. Corresponding baseline pre-restructure estimates 23,680/28,416 LEs are **not fitted ALMs or removable savings**; restructuring reports zero residual area for these recognized groups. Actual controller logic/FF and fitted counts supply the physical evidence.

Exclusive Fitter allocations grouped without parent/child double counting provide a second attribution check:

|Group|Placed allocation delta|Fitted FF delta|Fitted combinational ALUT delta|
|---|---:|---:|---:|
|Snapshot controller|+4,802.6|+9,599|+612|
|Primary VDP subtree|+594.4|+813|+2,653|
|Secondary VDP subtree|+576.5|+745|+2,615|
|Other core subtree|?306.7|+10|+28|
|Framework|?209.0|+4|?90|

These allocations sum to+5,457.8 placed (rounding versus official+5,458),+11,171 FF and+5,818 ALUT. [g06_group_deltas.json](g06_group_deltas.json) retains both endpoints. The bank cost dominates the controller; VDP restore selection/remapping adds substantial logic, while other allocations shrink. Net FF changes inside VDP reflect physical transformations as well as any source registers; do not count them all as newly serialized history.

No block RAM inference was lost: M10K and memory bits remain constant. New storage was explicitly described as parallel vector FF, with full-bank capture/reset/clear and ring movement. The placed-minus-needed gap improves by 2,593, ruling out a simple aggregate packing degradation explanation for the increase. Local control distribution and physical transformations still contribute; no evidence partitions their exact ALM cost.

Previous experiments: common-shift/head mux extraction, +47 placed/+106 needed; parallel masks, +9,532 standalone ALUTs; broad indexed prototype, failed congestion at 39,680 needed. Sequential local 32-bit gather/scatter removed 9,600 shadow FF, added two M10Ks and net −9,397 synthesis FF, but added approximately 5,402 combinational ALUTs. Seed 1 routing failed: its −1,615 provisional placed difference is unusable. Seed 2 routed at 38,012 placed (−586) but setup −.100 ns; neither qualifies. New read/decode/write distribution, high LAB footprint and existing HDMI timing sensitivity consumed the logical gain. This does not disprove all sequential implementations, but prohibits repeating the same candidate as a proven optimization. Details: [prior sequential report](../savestate_g06_sequential_architecture/review.md).

## 8. RAM inference findings

[All 41 fitted RAM instances](ram_inventory.md) reconcile exactly to **488 M10Ks and 3,818,050 logical bits**. No MLAB cells. Major allocations: extended BIOS 256 blocks; VRAM 32 per VDP; cartridge SRAM 32; WRAM 16; GG BIOS 16; boot ROM 16; key RAM 8; scaler 43; HQ2x buffers 14; OSD 4 each. OPLL voice array uses **two** 38×36 RAM instances to supply its read ports; envelope 18×25 uses one; OPLL scratch 256×32 uses one. Normal large memories already use block RAM.

Detailed dimensions, ports, resets, inferred implementation, feasibility and hazards for suspicious structures are in [memory_findings.md](memory_findings.md). Important distinction: intentional `ramstyle="logic"` OPLL arrays are not unexplained inference failures. CRAM's full combinational snapshot and sprite all-slot parallel access are established architectural blockers for a direct one-/two-port replacement. Memory attributes alone cannot fix incompatible access topology.

## 9. Register-array findings

Main register-backed structures: two 4,800-bit scratch rings; two 32×12 CRAM arrays; per-VDP 64×41 enable/X/cache state and 64×33 concurrently active shift state; T80 2×8×8 multi-read registers; 32×34 cheat entries; OPLL phase 18×18, register 9×24, feedback 9×10, output declared 19×10; keyboard 7×12; tiny protocol/filter state. Declared width can exceed optimized implemented bits; do not equate declarations with fitted registers.

Sprite caches and shifters are distinct historical state; a cached plane and its partly shifted copy are not generally equal. All slots are live resources for the 64-sprite mode; disabled/inactive state cannot be dropped merely because a common game uses eight sprites. Shifters shift in parallel every pixel and feed priority/collision reduction. A single M10K cannot provide that concurrency without changing scheduling, port replication or clocking.

## 10. Savestate storage inventory

|Class|Examples and implementation|Audit conclusion|
|---|---|---|
|A architectural|CPU 230-bit image, VDP 136 each, PSG 56 each, mapper 64, Evolution 160, CRAM 384 each; large RAM content read by DMA|Guest/live state remains necessary; packed declarations include wrappers/padding|
|B temporal|Sprite 4,778 each; BG 139 each; CPU NMI 3/restart 3; GG 114 meaningful in 128; MD 46; EEPROM extension 128; tap 19; paddle 32; gun 46; mapper history 18; raw PSG extension 96 each, divider/control; AudioMix phase plus retained sample 16|Confirmed deterministic-replay obligations; no omission authorized|
|C reconstructed|CPU canonical instruction decode/preparation; normalized sprite scanner WAITING/count/index; G03/G04 VDP state; OPLL arithmetic/cache refill; ROM/decryption/SDRAM restart contracts|Existing closure contracts, not generic permission to reconstruct other history|
|D derived/redundant representation|Literal padding, constant descriptors/tag fields, aliases and output concatenations|Often combinational or already folded; no large removable FF bank proven|
|E temporary transfer|Sprite two 4,800-bit rings; BG two 139-bit rings; CPU/VDP/CRAM/peripheral snapshots; OPLL synchronous 256×32 scratch; DDR 64-bit read latch and three byte-to-word DMA buffers|Dominant opportunity is representation/transport, not deletion of guest history|
|F duplicated storage|Live state plus snapshot; SAVE/LOAD use same snapshot banks; two physical voice RAM read replicas; live mixer output plus one retained sample|Different lifetimes or required ports explain duplication; alternatives require proof|

Source declarations/uses: [source_scan.json](source_scan.json), `rtl/savestates.sv:344..424,588..624,651..744`; [G06 field inventory](../savestate_sprite_resource_optimization/attribution.md); F01 local access map and scratch engine. A/B describe semantic purpose; E/F describe physical lifetime/topology, so these rows deliberately overlap and are not additive bit totals.

Wide parallel snapshots: sprite total 9,600 FF, CRAM total 768 snapshot bits in addition to live palette, BG 278, CPU and peripheral banks. OPLL is already sequential: 104×32 serialized rows (3,328 container bits, 1,896 meaningful), one 8,192-bit physical scratch. No full parallel OPLL shadow bank. The 152 unused scratch addresses are capacity slack inside one allocated block, not 152×32 recoverable FF.

Shared DDR path: `SMS.sv:1425..1431` selects scaler/savestate commands through approximately 111 data/control bits, with stable clock. Three 64-bit byte assembly buffers and one 64-bit read latch are small relative to sprite storage. They protect independent DMA lifetimes/backpressure. Sharing them may be possible under mutually exclusive FSM states, but no causal proof of redundancy or measured ALM saving exists.

## 11. Redundant-state candidates

**No large semantic state bank is proven redundant.** Constants/padding can be regenerated only if their register positions never carry other information. In the 4,800-bit ring, the 22 high padding positions hold meaningful bits during rotation: deleting 44 FF is not a constant-propagation cleanup. A different tail encoding changes update logic and needs equivalence/synthesis measurement.

Mixer sample low-bit equality is an arithmetic invariant on naturally produced values, but current v19 accepts a full 16-bit restored sample and its presence path. Width restriction would change accepted-image behavior unless an exact compatible internal encoding is established; not an authorized optimization here. The recent +37 synthesis FF includes 17 snapshot/presence and 20 restored/downstream bits whose previous merges ceased; it is not an unexplained extra FM bank.

OPLL immutable instrument entries and duplicated voice read storage deserve distinction: most voice content is reconstructable from ROM, but read-port replication remains required by current accesses. F01 already saves only the writable history. Removing live tables or rebuilding them with altered initialization timing is not proven equivalent. Format consolidation was measured negligible; do not label old version support as thousands of wasted ALMs.

## 12. Fanout analysis

Direct non-global Fitter loads, not textual references or transitive TimeQuest node counts:

|Source|Loads|Destination cone / origin|Measured worst setup from source|
|---|---:|---|---|
|ARM_FREEZE|9,670|Snapshot capture/control; G06 expanded formerly smaller bank regime|+6.259 ns, controller DDRAM_ADDR[13]|
|z80_set|5,901|Merged/shared primary architectural and VDP/sprite restore, not just CPU|+8.589 ns, primary shifter40 shift3[0]|
|vdp2_regs_set|5,448|Second VDP live restore|+4.996 ns, sprite cache d2 slot18[7]|
|LOAD_HDR_RD|5,265|Bank initialization and LOAD control|+5.838 ns, controller DDRAM_DIN[29]|
|Secondary snapshot control|4,811 and 4,800|FF ring update controls, generated net aliases|Not isolated by register query|
|Primary snapshot control|4,800|FF ring update controls, generated alias|Not isolated by register query|
|Sprite data_address generated controls|3,471 / 3,440|Secondary/primary evaluator update/selection|No standalone generated-net timing charge established|
|has_restart|1,410|Shared legacy/current sprite defaults|+6.363 ns, second sprite d2 slot18[4]|
|mode_M4 primary/secondary|667 / 614|Existing mode control into parallel live pipelines|No isolated contribution established|
|ddram_step|527|Transport acceptance/update gating|No isolated contribution established|

Read-only current queries additionally measure freeze +4.435 ns (PSG2 cen_16), CPU enable +1.704 ns (CPU snapshot bit64), VDP enable +1.698 ns (primary sprite d3 slot6[0]). The enable queries include physical `~DUPLICATE` registers. Literal freeze/enables/reset not appearing in the top-30 non-global list does **not** mean zero fanout. Reset is partly promoted/merged: global `jt89|clr_noise~0` has 12,403 loads plus a 752-load non-global row. A merged name does not establish that all sinks are PSG noise logic. Emulation clock has 41,812 global loads; comparing its count directly with ordinary routed controls is invalid.

G06 already had ARM 9,511, z80_set 5,909, secondary restore 5,418, header 5,126 and approximately 4,800 ring-control loads. Pre-existing clocks/mode/enable networks coexist with new snapshot/restore distribution. Current settings permit replication. Transformation records contain 321 register-packing duplication rows and 2,962 router duplication rows. By source hierarchy: VDP 2,080, other core 603, scaler 409, framework 175, savestate subtree 16. These include historical functional registers duplicated for routability, not only explicit high-fanout drivers. Counts are **records, not unique surviving FF or additional ALMs**; no additive per-control attribution is defensible.

[physical_optimizations.json](physical_optimizations.json), [full Fitter tables](tables.json), and eight `*_setup.rpt` files retain evidence. Queries inspect three worst paths per source under existing constraints; a register-origin path is not an exhaustive spatial fanout map. Local routing impact is supported as a risk, not quantitatively assigned to each load. All queried paths pass; the global setup extremum is elsewhere.

## 13. Mux/decoder analysis

- Snapshot rings: measured 8:1/9:1×4,736 update groups. Current constant rotation avoids the earlier arbitrary wide indexed crossbar. Shared source expressions alone do not imply eliminated hardware.
- CRAM: two **32:1×12** reads, each estimated 252 LEs before/after restructure; 384-bit parallel snapshot per VDP blocks ordinary RAM inference. Measured whole module allocation 731.1 ALMs combined includes storage, decode and routing; it is an envelope, not savings.
- Sprite cache updates: many **19:1×8 / 21:1×8** recognized mux groups alongside variable `count` writes, all-slot restore and mode-dependent plane updates. Each slot's cache supplies a concurrent shifter. Address/data sharing and local decode topology are justified inspection targets.
- BG reconstruction: 543:1×2 mux descriptions reduce from 724 estimated LEs to 12–16 LEs after restructuring. `/6` and modulo helpers in the earlier G05 accounting total approximately 107.4 estimated fitted ALMs. Large source mux cardinality alone overstates physical cost.
- Cheats: 32 simultaneous address/compare tests and last-match priority replacement. This is a comparator/priority network, not an ordinary one-read RAM.
- OPLL: fixed 32-bit local responses and address decode; narrow scratch already M10K. Some nested memory mux groups have 258 source alternatives; synthesis estimates do not prove literal 258-level chains.
- Host config/string response, OSD and scaler have sizable address/mode selectors; these are pre-existing framework costs. No evidence supports deleting framework features for savestate resource relief.
- Shared DDR ownership mux and format/address decode remain necessary. Previous compatibility-only consolidation removed eight synthesis registers but used 27 more placed ALMs. It is a low-priority area target.

Complete measured mux statistics, including baseline/restructured LE estimates and example outputs, are in [tables.json](tables.json). They are recognition/optimization statistics, not independent physical allocations; do not sum them as ALM savings.

## 14. Critical timing paths

|Path|Slack|Logic levels|Data interconnect / cell delay|Interpretation|
|---|---:|---:|---|---|
|HDMI shadowmask shift-tap RAM → hdmi_osd dsp_width[19] (also bits13/12)|+.104 ns|1|4.485 / 1.268 ns|78% routing; total 5.753, relationship6.732, skew−.675|
|Core mapper rom_crc32[17] → T80 IR[3]|+.895 ns|14|10.732 / 6.209 ns|63% routing; total16.941, relationship18.626, skew−.460|
|Hold: primary sprite shifter60 shift0[2] → shift0[3]|+.239 ns|1|.230 / .117 ns|Adjacent live shift/restore cone, total.347, skew+.108|

Path-local data loads are28 at the HDMI RAM output and22 at the OSD combinational driver; the hold data drivers each have fanout1. Core data-path drivers peak at33 on D_out[2] selection, rather than the thousands of loads seen on restore controls. The core path traverses mapper selection, memory_bus, D_out, GAMEGENIE comparison/override, GENIE_DI and CPU decode: the cheat selection is a measured timing-cone participant, though a cheaper equivalent rewrite remains unproven.

Exact endpoint paths, fanouts, cell delays and locations: [setup](../savestate_g08_fm/early_paths_setup.rpt), [core](../savestate_g08_fm/early_emu_setup.rpt), [hold](../savestate_g08_fm/early_paths_hold.rpt). The setup path launches from a physical RAM output rather than an HDL FF. Path-local fanout differs from complete driver sink counts; the reports retain per-arc loads. No 9,670-load ARM arc occurs in the selected global setup path. Its one logic level also excludes a deep savestate decode chain as the direct bottleneck.

High occupancy plausibly perturbs HDMI placement and routing, but that is an inference. No controlled placement-isolated experiment proves a common root cause between the savestate ALM cost and +.104 ns setup. Historical changes move worst endpoints nonmonotonically. The core mapper/ROM/CPU cone has a real deep combinational path but passes with more margin. Do not reinterpret the positive hold path as a defect or remove hold repair to recover area.

## 15. Routing pressure

38,599/41,910 placement and 18,266 route-through ALUTs indicate substantial physical use despite low overall FF utilization. Global estimates conceal local distribution. Read-only control paths establish adequate current timing, not absence of congestion sensitivity. Router replication is concentrated in VDP, consistent with large parallel evaluator/shifter cones and shared controls; source-to-physical causal shares remain unproven.

The failed sequential experiment is a particularly useful counterexample: fewer FF and lower needed ALMs did not guarantee routability. Its completed seed-2 build had 99% LAB footprint and higher interconnect pressure, with setup failing in unchanged HDMI infrastructure while core timing improved. An optimization must pass full routing and every constrained timing check; micro-synthesis and provisional failed-fit counts cannot qualify it.

## 16. Optimization candidate ranking

|Priority / class|Affected module and measured problem|Mechanism for a future experiment|ALM opportunity / uncertainty|M10K impact|Timing / functional risk|Required proof|
|---|---|---|---|---|---|---|
|1 STRONG OPTIMIZATION CANDIDATE|CRAM: 2×384 live FF plus parallel snapshots, 731.1 module ALM envelope, two32:1×12 reads|Replace all-entry exposure with bounded held-state entry scan; explicit dual-port RAM with guest timing preserved|Unmeasured;731.1 is the present direct module envelope before replacement costs, not a bound on global Fitter movement; no promised saving|Likely +1 per independent palette, subject to actual ports/packing|Medium / medium: registered read/write collision semantics (both production ports use clk_sys)|Native color/CPU accesses, all palette words/images, System E, malformed LOAD, SAVE/LOAD stalls and first restored pixel|
|2 STRONG OPTIMIZATION CANDIDATE|Live sprite cache distribution: 4,144.5 evaluator own ALMs, generated3,440/3,471-load controls,2,080 VDP duplication records|Factor/localize per-plane data/address/update decode without changing parallel shifters or snapshot architecture|Unmeasured, shared cone; no numeric recoverable allocation|0 intended|High / high: partial plane updates, count/index/mode behavior|Clock-for-clock full64-slot evaluator/shifter/collision equivalence across modes, existing G06/G10/G05/native replay|
|3 STRONG OPTIMIZATION CANDIDATE, CONDITIONAL|9,600 FF snapshot scratch; prior RAM conversion logically smaller but physically rejected|Only after locality evidence: partition local word routing/write enables, unlike prior full-owner scan/reduction network|Prior −586 placed was timing-failing, −1,615 failed-route provisional; neither is usable forecast|Prior +2; revised organization unmeasured|Very high / high: coherent partial LOAD and release ordering|Retain complete image/format, full history, first-clock replay, latency, malformed no-live-write, two qualified matched-seed fits|
|4 SPECULATIVE IDEA|OPLL logic arrays phase/register/feedback/output: combined598.8 own fitted ALMs including local controls|Individually evaluate synchronous RAM ports, preserving init/RDW and two-read output semantics|Unmeasured; below module envelope and potentially negative net result|At least individual blocks; output two-read may need replicas|Medium / high: F01 timing and reconstruction contract|Exact raw OPLL104 rows and long audio suffixes, repeated restore, init and FM handoff regressions|
|5 SPECULATIVE IDEA|Cheat32×34 FF,539.9 module ALMs|Balance equivalent last-match reduction; storage needs simultaneous comparisons|Unmeasured, comparator cost remains|0 intended|Medium / medium: priority and code-load/reset|All match/compare/priority overlaps, streaming code updates and CPU read timing|
|6 SPECULATIVE IDEA|LOW register packing/high-performance flow,1,482 placed-minus-needed gap|One controlled packing-effort setting trial after RTL hypotheses|Unmeasured; B/C are estimates, not available savings|0 intended|High timing/routing / low RTL semantic|Same source/tool/date/seed, all timing/routing and source identity checks|
|7 SPECULATIVE / LOW PRIORITY|Small DMA staging, BG helper decode, format control|Prove state lifetimes/invariants before any sharing or encoding|No quantified saving; prior format test +27 placed|0 expected|Medium / medium-high|All existing transport/legacy/replay contracts|

**PROVEN STRUCTURAL WASTE:** no major safely removable structure proven. Known constants/wires are largely folded, ring padding moves meaningful data, duplicated live/snapshot state has required lifetimes, and physical duplication has routing purpose. The strong candidates concern implementation topology, not unnecessary guest state. Candidate envelopes overlap and cannot be summed.

## 17. Quantified opportunities and uncertainty

|Reduction threshold|Assessment|
|---|---|
|500 ALMs|Plausible research target across CRAM and localized control changes, not established. Prior sequential seed2 reached586 fewer placed but failed setup; this supplies scale, not qualification. CRAM alone has only731.1 total module allocation before replacement costs.|
|1,000 ALMs|Possible only with a broader successful sprite/control change or combined independent wins; no timing-qualified evidence supports a forecast.|
|2,000 ALMs|Unproven. Prior needed reduction1,961 did not become comparable usable placed recovery; provisional seed1 placement difference was only1,615 and unrouted. Requires a materially better physical topology.|
|4,000+ ALMs|Unsupported by present experiments. Recovering most of historical5,458 would require removing much of necessary storage/update/restore cost while avoiding replacement decode/routing. Do not budget it.|

Meaningful reductions may be achievable without changing semantic state or format, but current evidence does not establish a safe magnitude. For planning, **qualified guaranteed saving is zero**. Full module allocations are investigative ceilings only. There is no extrapolation from FF count divided by ALM FF capacity.

## 18. Recommended experiment order

No experiments implemented here. Each future task should preserve v19 and the existing baseline until its keep criteria pass.

1. **CRAM-only pilot.** Hypothesis: full parallel snapshot exposure, rather than normal registered read, forces palette FF storage. Measurable effect: intended RAM inference and fewer palette FF/ALUTs in micro-synthesis; then lower full-chip placed ALMs. Keep guest read latency and original CPU/VDP clock behavior, and retain complete image bytes. Both production palette clock ports are tied to clk_sys in rtl/vdp.vhd:308..312. Test simultaneous read/write, GG/SMS palettes, System E, first resumed pixels, repeated LOAD and rejected images. Compare source-isolated fresh full fits at matched date/tool/seed1; confirm favorable result at matched seed2. Keep only if both route/pass timing, M10K trade is acceptable and placement beats matched baseline in both; otherwise revert.
2. **Local sprite-control pilot, no snapshot replacement.** Hypothesis: per-slot/plane update data and mode/address selection are physically duplicated. First use node-level source/destination grouping of the measured VDP duplicate cones to choose one bounded rewrite. Measurable effect: lower selected cone ALUT/duplication and lower full-chip placement without changing9,556 live history bits or transfer image. Require full64-slot cycle equivalence, collision/overflow, wide/mode transitions, G06/G10 native suffixes, System E and Pause. Same two-seed controlled full-fit criteria; reject if gain only shifts cost elsewhere or loses timing.
3. **Conditional snapshot architecture study.** Proceed only if experiment2 provides new locality evidence that addresses the earlier failed read/decode/write network. Hypothesis must specify exactly how port distribution differs from the rejected300×32 design. Expected effect: remove9,600 shadow FF while avoiding the previously measured~5,402 added ALUTs and congestion. Preserve formats, validation-before-apply, freeze, capture edge and acknowledged restart. Repeat complete images, all150 sprite words, full64-slot state/output and native first-clock replays, long suffixes/stalls, latency and System E. No keep without completed route and nonnegative all-domain timing on both paired seeds. Do not repeat the old candidate unchanged.
4. **Small alternatives only if justified.** Isolate one OPLL logic-array mapping or equivalent cheat priority rewrite, with exact port/reset/priority proof and its retained regression suite. Measure actual inferred memory and full-board resources; reject negative or seed-sensitive unqualified results. A packing-setting experiment is separate from RTL experiments so causal attribution remains possible.

Save all input hashes, actual build settings, official needed/placed counts, FF/ALUT/M10K/DSP deltas, route usage, warnings and endpoint paths. No format simplification, state omission, feature removal or favorable-seed search substitutes for equivalence and physical qualification.

## 19. Risks and limitations

- Current production is source-bound to one routed seed1 result, not multi-seed/hardware signoff. Existing unconstrained categories persist.
- Hierarchy allocations and mux estimates are not exact additive optimization costs. Duplication records are not unique site counts. No measured ALM share is assigned solely to fanout.
- Scan covered all110 tracked HDL files and complete455-entity fitted hierarchy; disabled helper definitions and unused source modules do not imply active hardware. All41 fitted RAM instances reconcile. The regular-expression source scan is an index, not a complete HDL elaborator; source review and elaborated reports determine implementation.
- Source identity uses explicit CRLF/LF normalization for Git blobs; all137 retained build files also match raw manifest hashes. Two backup files have no HEAD blob and are unused.
- Requested timing-history report is absent. Current complete path reports and historical retained summaries supply the available evidence; no missing document is fabricated.
- No architecture experiment, new synthesis or fit was run. Functional regressions were not rerun for an unchanged production tree. The read-only timing query and audit collectors are verified separately.
- All savestate closure claims remain under their documented contracts. Required history is not declared reconstructable by this resource audit.

## 20. Final recommendation

**B. SIGNIFICANT OPTIMIZATION OPPORTUNITIES.** Prioritize CRAM's demonstrable parallel-snapshot inference blocker and local sprite control/data distribution. Keep the current v19 implementation until an isolated experiment proves both behavior and physical improvement. The evidence does not justify deleting history, changing formats, repeating the failed sequential implementation, disabling features, or promising a1,000–4,000 ALM reduction.

## 21. git diff --stat

Tracked diff is empty. Audit artifacts are untracked under the already-untracked `tests/` tree, so ordinary `git diff --stat` does not enumerate them. [artifact_manifest.json](artifact_manifest.json) lists this task's files and hashes; no pre-existing test evidence was edited.

## 22. git status --short

```text
?? tests/
```

Branch `investigate/structural-resource-audit`; HEAD unchanged; index empty. No production changes, commit, push or PR. See [verification.json](verification.json).
