# Non-controller structural optimization audit, committed v19

> [!NOTE]
> This structural audit report and its parent consolidation belong exclusively to branch doc/resource-optimization-consolidation of fork breve/SMS_MiSTer. This documentation branch is isolated and will not be integrated into master or submitted upstream to the official MiSTer repository (MiSTer-devel/SMS_MiSTer). For the official conclusion and resource balance of this optimization roadmap round (including the approval and merge of PhaseMemory via PR #224 and the complete ledger of physical experiments and static structural audits), see the consolidated summary report at [tests/fpga_resource_optimization_summary/review.md](../fpga_resource_optimization_summary/review.md).

**NO-GO for implementation; STOP after this audit.** The strongest remaining target is the native sprite evaluator/shifter network, with approximately **8,505.1 exclusive placed ALMs** across both owners. That is a measured allocation, not recoverable area. The retained netlist now distinguishes **1,959 surviving duplicated sprite FF nodes** from the original state. They serve routing, and no supported replacement topology establishes a material net reduction while preserving timing. Smaller Boolean and memory opportunities exist, but none presently meets the requested material-area selection gate. No proof-of-concept is selected.

No production source, candidate RTL, constraints, IP, branch, HEAD or index changed. No simulation, synthesis, fit, route, seed experiment or Quartus query ran. Only analysis scripts, derived evidence and this report were added under this directory.

## 1. Verified baseline and provenance

Production HEAD is **1b2a52d87d2659c908d4f9f846416d14bfd85bea**, branch **investigate/cram-memory-inference**, savestate **v19 / 0x484313**, unchanged 96 KiB container. Controller SHA256 is `e8de50db09447138fc661205fb9edd178d45e691819a056bad87631ef3d76557`. All **204 tracked raw file hashes** match the committed baseline ledger. Tracked and staged diffs are empty. All **137 retained seed-1 inputs** match their raw manifest hashes. The final verification also compares **135 inputs to HEAD with explicit CRLF/LF normalization**; two unused `.bak`/`.orig` files are excluded from that Git-blob comparison. The build manifest's earlier HEAD label is not used as proof of v19 source identity.

Authoritative physical evidence: [retained v19 build](../savestate_g08_fm/quartus_early/), Quartus Prime Lite **17.0.2 Build 602**, Cyclone V **5CSEBA6U23I7**, SMS/sys_top, **seed 1**, **BUILD_DATE261025**, **MISTER_FB=1**. STANDARD FIT, HIGH PERFORMANCE EFFORT, SPEED, final placement ALWAYS, LOW ALM register packing, NORMAL automatic packing and the original physical/router optimization settings apply. QSF, QIP, SDC and IP remain unchanged.

| Official whole-design metric | Retained v19 seed 1 |
| --- | ---: |
| Needed / placed ALMs | 37,117 / 38,599 of 41,910 |
| Mapped / fitted registers | 46,327 / 48,880 |
| Logic / routing ALUTs | 46,835 / 18,266 |
| M10K blocks | 488 of 553; 65 free |
| Logical block-memory bits / DSP | 3,818,050 / 39 |
| Setup / hold slack | +0.104 / +0.239 ns |
| Reported violating timing groups | 0 |

Packing identity: `38599 - 2055 + 573 = 37117`. Existing unconstrained setup/hold categories and 38 unique critical-warning messages remain; this audit does not claim additional signoff coverage. Baseline values were freshly parsed from retained reports, with no rebuild.

The complete nine requested reports were read. Their scope and chronology matter:

| Report | Evidence carried forward |
| --- | --- |
| [Structural audit](../structural_resource_audit/review.md) | Current 455-entity hierarchy, RAM, fanout, mux and transformation tables; original CRAM recommendation is superseded by its experiment |
| [Resource growth](../savestate_resource_growth/review.md) | Controlled history through v16; historical deltas are not current per-module prices |
| [Internal cost audit](../savestates_internal_cost_audit/review.md) | Controller storage and attribution limits; controller itself excluded here |
| [Sprite optimization](../savestate_sprite_resource_optimization/review.md) | v16 extraction +47 placed; masks expand logic |
| [Sequential sprite architecture](../savestate_g06_sequential_architecture/review.md) | v17 packed RAM/scatter fails physical qualification |
| [Storage investigation](../g06_g10_storage_optimization/review.md) | Frozen SAVE sources versus private LOAD lifetime; no selected replacement |
| [Sprite architecture feasibility](../sprite_restore_architecture_feasibility/review.md) | Local whole-slot RAM reset-interruption gap and atomic-shadow cost; STOP |
| [CPU alias paired seed 2](../cpu_restore_alias_seed2_pair/review.md) | Only four fewer placed ALMs; routing gates fail; no production adoption |
| [CRAM inference](../cram_memory_inference/review.md) | Functional/local logic success but +121 whole-design placed, +4 M10K; reverted |

[provenance.json](provenance.json) records input/source/evidence hashes and parsed metrics. [collect.js](collect.js) re-extracts all hierarchy rows from the original fit report and checks every retained field against the structural audit. [inspect.js](inspect.js) examines existing register-name and timing exports. Neither script invokes Quartus. Historical artifacts are read in place.

## 2. Ranked exclusive resource inventory

The ranking excludes the **entire controller subtree**, including its OPLL scratch child. This avoids presenting that child as a new opportunity outside the controller. The whole design's exclusive allocations sum to **38,599.2 placed** versus official integer **38,599**; the controller subtree contributes **10,804.5**, leaving **27,794.7** outside. Excluding only the controller's own 10,647.6 would leave its 156.9-ALM child in scope; that is not the convention used here.

All **455 fitted rows**, including inclusive parent values, are retained in [hierarchy.json](hierarchy.json). [hierarchy.md](hierarchy.md) ranks the top 40 outside the controller, with full paths, exact fit-report lines and exclusive memory attribution. The short table below uses unambiguous instance labels; **every numeric cost column is exclusive**.

| Rank | Hierarchy / instance | Placed ALMs | Needed estimate | Logic ALUT | FF | Own M10K |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| 1 | ascal | 2,391.8 | 2,021.9 | 3,059 | 4,059 | 0 |
| 2 | primary vdp_spr_inst, excluding shifters | 2,081.5 | 2,077.6 | 2,305 | 2,910 | 0 |
| 3 | secondary vdp_spr_inst, excluding shifters | 2,063.0 | 2,075.1 | 2,311 | 2,909 | 0 |
| 4 | sys_top, excluding all children | 995.0 | 874.9 | 1,400 | 1,432 | 0 |
| 5 | emu/hps_io, excluding video_calc | 683.0 | 635.0 | 770 | 746 | 0 |
| 6 | emu, excluding all children | 590.7 | 547.4 | 1,002 | 659 | 0 |
| 7 | T80/u0, excluding decode/register children | 560.5 | 554.8 | 889 | 262 | 0 |
| 8 | hdmi_osd | 558.6 | 543.4 | 906 | 618 | 0 |
| 9 | pll_hdmi_adj | 551.3 | 536.1 | 778 | 503 | 0 |
| 10 | GAMEGENIE | 539.9 | 349.3 | 530 | 1,104 | 0 |
| 11 | vga_osd | 507.4 | 502.9 | 886 | 608 | 0 |
| 12 | core PLL reconfiguration generated core | 495.7 | 492.2 | 766 | 255 | 0 |
| 13 | secondary CRAM | 366.8 | 365.5 | 607 | 404 | 0 |
| 14 | primary CRAM | 364.3 | 363.9 | 607 | 399 | 0 |
| 15 | system wrapper, excluding children | 360.3 | 367.2 | 582 | 31 | 0 |
| 16 | OPLL envelope generator, excluding RAM | 323.9 | 325.2 | 524 | 236 | 0 |
| 17 | hps_io/video_calc | 319.0 | 287.8 | 474 | 649 | 0 |
| 18 | guest IO wrapper | 307.4 | 313.3 | 544 | 187 | 0 |
| 19 | ALSA | 302.3 | 256.7 | 400 | 550 | 0 |
| 20 | T80_MCode | 297.3 | 297.3 | 474 | 0 | 0 |

The small shifter children are hidden by a simple top-20 list. Aggregation by source family changes the investigative priority:

| Family, summing exclusive rows once | Placed ALMs | Logic ALUT | FF | M10K |
| --- | ---: | ---: | ---: | ---: |
| Both sprite evaluator parents | 4,144.5 | 4,616 | 5,819 | 0 |
| All 128 shifter children | 4,360.6 | 6,579 | 5,700 | 0 |
| Both complete VDP subtrees | 10,295.7 | 14,057 | 13,094 | 64 |
| Scaler including RAM/control children | 2,394.7 | 3,065 | 4,063 | 43 |
| Video mixer/scandoubler/HQ2x/gamma subtree | 827.5 | 1,012 | 1,408 | 15 |
| Selected mapper/decode/address entities | 808.1 | 1,229 | 507 | 0 |
| Audio output/filter subtree | 1,004.4 | 1,662 | 1,092 | 0 |

These family rows **overlap**: evaluator/shifter rows are inside the VDP total. They are alternate views, not an additive chip budget. Background including helper children is 556.7 ALMs; the two background entities alone are 224.7 + 222.5 = 447.2. The helpers explain the difference and cannot be charged twice. [groups.json](groups.json) defines each grouping explicitly.

The fit hierarchy reports 48,779 dedicated FF and 46,835 logic ALUT in total; official fitted FF are 48,880, including categories not represented in that hierarchy column. Outside-controller dedicated FF total 33,839, ALUT 39,645 and M10K 487. These reconcile by column, without treating memory bits as FF. Exclusive M10K/memory counts are derived by subtracting direct-child inclusive counts; RAM leaves own the blocks, so scaler/OSD parent own-memory zero does not mean their buffers are absent.

**Needed is not an additive physical charge.** Summing reported own-needed rows yields 37,084.4, while the root inclusive estimate is 37,116.2 and official summary is 37,117. The 31.8 own-to-root difference is too large to explain solely as one-decimal rounding. The hierarchy's packing-adjusted estimates are not an exact additive needed-resource partition. Preserve the individual reported values and use the official global packing identity; do not assign that residual to a source block. Likewise, fractional placed allocations do not identify independently removable ALM sites.

Per-entity routing ALUT and congestion costs are **not available** in the hierarchy table. Global routing ALUTs must not be divided in proportion to logic ALUT, FF or fanout. Available local indicators are transformation/name counts, direct fanout and specific routed paths, discussed below.

## 3. Sprite evaluators and shifters: concrete costs

### Native cache update and restore selectors

[vdp_sprites.vhd:59](../../rtl/vdp_sprites.vhd:59) declares 64 enables, 64 eight-bit X values and four 64×8 cached planes per owner: **2,624 state bits**. Add evaluator state3, count7, index6, address14, flags8, color4, collide1 and overflow1: **2,668 bits per parent**, 5,336 total. The existing full-netlist register export contains **5,819 parent timing-register nodes, 483 named duplicates**, matching 5,336 ordinary nodes. This is stronger than treating every fitted FF as original guest state.

Normal writes at :239–323 use variable `count`: Mode4 writes X then d0/d1/d2/d3 on different evaluator states; legacy writes X with one of two offsets, then d0, zero d1/d2, flags into d3, and conditionally d1 for tall sprites. At :145 the architectural restore takes priority and supplies every slot independently or legacy zeros. At x257, all enables clear; count/index/state also change. Successful LOAD must preserve all these priorities. No reset or scheduling change is proposed.

The source therefore induces per-slot **selected writes, hold, mode-specific values and parallel restore**. Map rows recognize 19:1×8 and 21:1×8 cache muxes; many have **zero residual recognized area after restructuring**. The nominal mux input count does not prove literal remaining deep mux hardware. The Fitter names `data_address[0]~1` with **3,440/3,471 direct loads**, and generated plane controls with 548–568 loads, identify broad evaluator update/default cones. A generated name is not proof that an address data bit literally drives all those cache D pins.

A concrete unimplemented alternative is to calculate **one normal write-data value and write predicate per plane**, decode `count==slot` locally, and preserve the existing independent full-width restore selection. Mode4 d0 accepts VRAM in LOAD_0; legacy d0 accepts it in LOAD_1. d1 combines Mode4 LOAD_1, legacy LOAD_1 zero and tall LOAD_2 VRAM; d2/d3 have their corresponding distinct rules. X's subtract1/subtract33 can be selected once upstream. This could move repeated mode/data selection before per-slot write qualification. It removes no history and needs no M10K or new cycles.

Its replacement costs are important: shared eight-bit data/plane predicates still need routed distribution; a full six-bit slot decoder or factored groups remains; restore muxes remain; boundary x257/x496 overrides remain. Unregistered source factoring may already be performed by synthesis. Pipelining would change native capture edges and introduce new state, so it is excluded from this candidate. Current evidence supports a target, **not an unsynthesized claim that hundreds of mux copies survive**. This missing residual Boolean/locality proof prevents selecting it now as a material-area PoC.

### Shifter state and repeated load/shift choices

[vdp_sprite_shifter.vhd:37](../../rtl/vdp_sprite_shifter.vhd:37) has four eight-bit shift planes and wideclock, **33 bits × 128 = 4,224**. Retained register names give **5,700 nodes = 4,224 ordinary + 1,476 duplicates**. All 1,476 corresponding Fitter duplication rows are explicitly router **Routability optimization** operations. The evaluator's 483 rows are also router operations. Thus these particular surviving names/counts corroborate physical replication; this does not license interpreting all transformation logs everywhere as surviving FF.

Each child occupies 30.0–43.5 estimated placed ALMs. The aggregate 4,360.6 includes native shifts/reloads, comparisons, restore selection and physical implementation. The source's ordinary pixel edge compares X, X+8 and FF-wrap exclusion, chooses reload versus shift/hold, handles wideclock, retains legacy color in shift3 and chains shift1 into shift0. It then exposes four heads or legacy color/active. Restored inactive planes remain relevant to later mode changes and cannot be dropped.

The source already **hoists common screen-range comparisons outside all 64 children** at [vdp_sprites.vhd:96](../../rtl/vdp_sprites.vhd:96). Therefore proposing to hoist those same comparisons is a repeat of existing structure. Per-slot X comparisons are genuinely different operands. A future per-owner common X+8 term or shared mode-specific shift predicate is possible, but synthesis may already share it; forcing more sharing can increase fanout and duplicate it again. Blanket duplicate suppression would remove the fitter's routing remedy and is not a resource mechanism backed by equivalence and timing evidence. The current worst hold path is in this family.

### Priority and collision

[vdp_sprites.vhd:334](../../rtl/vdp_sprites.vhd:334) walks slots from high to low; later assignments make the **lowest numbered active enabled slot win**. The lower eight additionally form the collision vector. Collision is not “any two of 64”: extended slots participate in color priority but not that low-eight collision test. The y/mode gate and exact register edge remain necessary.

A balanced tree over `(valid,color)` can represent the same lowest-index choice in six binary levels for 64 leaves, with the same color/collide registers and restore edge. But a binary tree still has 63 combining nodes; the linear description already maps through Quartus restructuring. There is no isolated fitted cost for the priority cone or proof that balancing reduces area rather than only depth. One-hot prefix grants similarly add prefix reduction, masks and OR trees; their area should not be assumed lower. This is a feasible equivalence exercise, but weaker for **material placed-area** than the parent/native update target.

## 4. Background, palette, collision and status

[vdp_background.vhd:55](../../rtl/vdp_background.vhd:55) contains distinct captured pattern/tile/palette/flip state, four plane latches and shifters, text pattern/shift/phase/column and registered VRAM address/priority. [Restore decoding:139](../../rtl/vdp_background.vhd:139) reconstructs text phase/column from unchanged eight-bit text position using mod6/div6. Their helpers contribute approximately 109.5 current hierarchy ALMs when grouped with the parents (historical G05 estimate about 107.4). This is a measured small cone, not a thousand-ALM target.

Native address generation chooses Mode4 versus legacy Graphics I/II versus text, and has distinct current-byte versus delayed pattern usage. `data3` and the direct VRAM byte at the shifter reload are not redundant copies. The source explicitly records a prior datap pipeline regression. Removing “duplicate” pattern/color registers or sharing operations across mode transitions without preserving the exact edges can break G05. A constant-divisor lookup or bounded quotient/remainder rewrite could change restore-only logic with no format change, but adds decode/lookup/routing and cannot recover more than an unmeasured part of a small envelope. Large 543:1 mux source descriptions were already restructured to roughly 12–16 LE estimates in prior evidence.

[vdp_main.vhd:166](../../rtl/vdp_main.vhd:166) combines sprite/background activity, background priority, text blanking, borders and overscan into CRAM address/color. SMS/GG/TMS palettes and display regions differ. This is real mode selection, not repeated independent rendering hardware for every source-level branch. [vdp.vhd:631](../../rtl/vdp.vhd:631) restores IRQ/status, overflow source and the 14-bit collision delay. The raw overflow branch requires freeze=0 even when ce_vdp=0; changing it to a generic enable would regress SAVE-only behavior. Collision/status pipelines must preserve their entire history and first resumed clock.

CRAM is **731.1 placed ALMs**, 803 fitted FF across the two parents, zero M10K. Its 384-bit parallel output blocks ordinary RAM inference. The complete inference experiment has already tested scanning plus RAM: actual **four** replicas, locally −712.7 ALMs but globally **+121**, routing ALUT **+997**, despite passing function/timing. Repeating inferred RAM is excluded. An explicit true-dual-port mapping is a different port mechanism in principle, but is not selected here: it still needs scanner/controller changes, exact OLD_DATA/read latency and legacy System E fallback, and has no demonstrated whole-design benefit. The present audit does not override the user's exclusion by relabeling that trial.

## 5. Scaler, framebuffer and framework video

[ascal.vhd:120](../../sys/ascal.vhd:120) supports nearest, bilinear, sharp bilinear, bicubic and polyphase/adaptive filtering, framebuffer formats, deinterlace and downscaling. The actual [instance:714](../../sys/sys_top.v:714) uses FRAC8, 128-bit memory data and 28-bit addresses; runtime mode selection preserves supported features. Compile-time switches are not authorization to remove features or reduce supported resolution.

The measured **43 M10Ks** include four 2048×24 output line stores (five blocks each), input line store, 128-bit burst staging, coefficient/palette memories, small line segments and a tapped delay. These are already hard memories. The 4,059 own FF and 3,059 ALUT include arithmetic and scheduling, not a 4,059-bit RAM accidentally inferred as FF. Short `o_hfrac`, `o_hpixq`, `o_div` and `o_dir` arrays at :518–552 explicitly request **logic**, with multiple pipeline taps. A memory attribute cannot supply all those taps at once.

Source structures worth distinguishing:

- Horizontal/vertical interpolation functions at :795, :905–981 and :1053 have arithmetic stages, RGB lane replication, coefficient reads and intermediate precision. Sharing horizontal and vertical filters requires concurrent throughput and independent fractional/coefficient histories; similar equations do not imply an idle reusable unit.
- :2626–2707 propagates horizontal fraction/pixel taps into separate filter branches, selecting the result after their pipelines. Runtime-exclusive output mode does not prove their input histories may be invalidated when modes change.
- :2737–2753 writes selected line stores and reads four lines in parallel; :2903–2935 aligns vertical taps and mode choices. Memory write-enable/read-output control is in the seed-2 setup limiter. Collapsing line banks adds ports or scheduling/bypasses, not merely fewer HDL arrays.
- Width narrowing needs an invariant valid for every supported framebuffer size, signed coefficient value, accumulation, rounding/saturation and asynchronous mode change. No such redundant upper-bit proof was found. Replacing arithmetic with DSPs could consume unused DSP capacity, but current scaler already uses 23 DSPs in its subtree; unmeasured DSP packing/latency/placement cannot be called an ALM saving.

The **409 scaler duplication records** indicate physical transformations, not 409 disposable pipeline FF. The CRAM trial's **+427.4 scaler own placed ALMs with identical scaler RTL** illustrates global physical sensitivity. It does not prove the scaler source has that much waste.

[osd.v:102](../../sys/osd.v:102) measures pixel size and display timing; :133 pipelines start-position arithmetic; :155 implements wide counters, rotation/multiscan and overlay address selection. Each OSD has an already-mapped 4096×8 buffer / four M10Ks. HDMI and VGA OSD have different clocks/DE/sync, counts and read addresses, so a shared read/control engine would require CDC and simultaneous-read support. Shared host write content does not establish shareable renderer state. Narrowing 22/24-bit counters based on usual video resolutions changes saturation and long-blanking behavior unless bounds are proved. This is directly exposed to the current critical HDMI path and is not a small safe area cleanup.

HQ2x/scandoubler/gamma together occupy 827.5 ALMs / 15 M10Ks. [hq2x.sv:65](../../sys/hq2x.sv:65) already time-multiplexes neighborhood work over four `cyc` values; its Blend child is 254.0 ALMs, with pipelined 24-bit operands and packed-lane arithmetic. A further serial filter would change throughput. The constant table's MLAB source attribute does not imply fitted MLABs: the global fitted count is zero. The two input buffers and 96-bit four-pixel output buffer already use M10K. Removing HQ2x, gamma, rotation, composite output or framebuffer support would sacrifice functionality and is excluded.

## 6. Mapper, memory, CPU and other significant logic

[memory_decode.vhd:65](../../rtl/memory_decode.vhd:65) already shares cartridge/BIOS ownership predicates. Its physical ROM address process selects System E, multicart, linear/Dahjee, Janggun, Zemina/Nemesis, 4-PAK and ordinary Sega/Codemasters banking with real precedence. [memory_bus.vhd:47](../../rtl/memory_bus.vhd:47) separately derives read/write windows and byte selection; [system.vhd:1412](../../rtl/system.vhd:1412) selects BIOS/decryption/raw ROM then :1439 selects CPU IO/memory data. GAMEGENIE then overrides it before T80. These layers partly serve different outputs and side effects. Removing duplicated textual address comparisons is not proof of duplicated fitted decode.

The selected mapper/decode/address entities total **808.1 ALMs**, including mapper_detect237.4, mapper_ctrl229.4 and Evolution ROM address151.4. Some additional selection is in system's 360.3 own ALMs; do not add it all as mapper-only. The detector's ROM CRC/signature and timer state drive real mapper choices and saved F13/F14/F15 state. [mapper_ctrl.vhd:123](../../rtl/mapper_ctrl.vhd:123) preserves reset/restore/write priority and freeze gating. A one-hot ownership network with shared predicates could reduce serial mux depth, but adds owner qualification, validity and data OR trees, and must preserve overlap precedence for BIOS+cartridge, RAM, EEPROM, System E and decryption. It changes a measured near-critical cone and has no supported material-area price. Retiming, caching a ROM byte or changing SDRAM request acceptance is not an equivalent combinational cleanup.

[sdram.sv:99](../../rtl/sdram.sv:99) prioritizes write toggles over read edges, latches address/data, tracks request completion and samples 16-bit SDRAM data before byte selection. The G12 live request/restart contract includes this external state. A narrower or merged handshake state cannot be assumed safe from its modest FF count; there is no large unused staging bank in its source. The seed-1 restricted SDRAM→T80 path has only +1.326 ns margin.

[cheatcodes.sv:34](../../rtl/cheatcodes.sv:34) declares **32×34 = 1,088 code bits** plus index/change state; 1,104 fitted FF / 539.9 ALMs. All enabled entries compare address and optional current data simultaneously; the highest matching index wins because the loop overwrites earlier results. Ordinary addressed RAM cannot provide those comparisons. A balanced match/data tree can preserve priority and has a straightforward miter, but retains 32 comparators and 1,088 bits; 31 pairwise data combines still exist. Masked-OR priority may increase logic. Resetting only valid bits could remove wide reset choices while retaining all payload FF, but requires arbitrary post-reset contents to stay unobservable through code-load/available/enable transitions. Neither offers a demonstrated material resource mechanism, and this block participates in the CPU read critical cone.

T80 itself is 560.5 own ALMs plus 297.3 MCode and 177.8 Regs children. Registers have multiple reads and independent write/restore ports; decode/prefix/EI/HALT/NMI and G01 preparation semantics constrain reencoding or pipelining. CPU output aliasing was already tested and rejected. No new CPU RTL variant is proposed.

Other physical consumers were not omitted merely because they are framework or audio:

| Consumer | Concrete source structure and resource interpretation | Opportunity limit |
| --- | --- | --- |
| sys_top995.0 / emu590.7 own | Output/DDR ownership, format/control, host and video gates; many children excluded | No single removable bank or disjoint costly decode identified; changing DDR arbitration risks accepted transactions |
| hps_io683.0 + video_calc319.0 | [hps_io.sv:244](../../sys/hps_io.sv:244) has optional config-string BRAM; actual SMS instance uses default CONF_STR_BRAM0. Command response and concurrent timing-measurement counters also contribute | Config ROM is a concrete separate mechanism, but its isolated fitted mux share and exact response latency/port budget are not known; the full 683 is not a ROM charge. Counter histories are simultaneous measurements |
| pll_hdmi_adj551.3 | [pll_hdmi_adj.vhd:66](../../sys/pll_hdmi_adj.vhd:66): three 41-bit fractional values, 24-bit measurement counters, variable right shift and add/sub at :358; reconfiguration handshake | Sequentializing arithmetic might exploit long frame intervals, but must preserve every snoop/update/waitrequest edge. Latency and one-operation-at-a-time assumptions are unproved; entire envelope is modest |
| Core PLL reconfig495.7 | Generated vendor counter-cache/config/control implementation | No measured equivalent replacement; deleting generated state or rewriting IP is high-risk and not a bounded source optimization |
| OPLL phase203.6, output182.1, register137.3, feedback75.8 own memory entities | [phasememory.vhd:65](../../rtl/VM2413/phasememory.vhd:65), registermemory and outputmemory deliberately use logic arrays. Phase18×18 and register9×24 have registered reads and sequential init/private access; output has two independent registered reads | Port-compatible explicit RAM is conceivable for individual arrays, but read-during-write, initialization and F01 local read/refill latency must match. Output may require replicas. No broad FM conversion or promised aggregate gain; F01 scratch is excluded |
| Audio output1,004.4 subtree; ALSA302.3 | Filter arithmetic and taps, left/right histories, mixer pipelines. [alsa.sv:65](../../sys/alsa.sv:65) uses two 61-bit stable CDC samples; 64-bit fetch buffer supplies stereo pairs and ring pointers | Stereo histories are independent; CDC samples are protocol state. Sharing them or serializing filters needs a new timing/stream contract; no large redundant bank proved |
| IO307.4 / EEPROM165.8 / lightgun135.0 | Runtime port decode, serial protocol, accessory temporal history | F02–F16 timing/restore/defaults remain. Small independent structures; combining their envelopes is not evidence for one material bounded PoC |

Large block RAM capacity is not the same as logic opportunity: extended BIOS uses **256 M10Ks**, dual VRAM64, cartridge SRAM32, WRAM16 and GG BIOS/boot ROM16 each. Those memories are already block-mapped; dropping capacity or support is not optimization under this contract. Free bits within allocated blocks are not free independent ports or placeable M10Ks.

## 7. System E concurrency and sharing limits

[system.vhd:668](../../rtl/system.vhd:668) and :736 instantiate two full VDPs with the **same ce_vdp, ce_pix and ce_sp**, independent registers, VRAM, palettes and history buses. Shared x/y makes their edges simultaneous, not mutually exclusive. They can produce different sprite priorities, collision histories, background phases, addresses and colors on that edge. Primary Evolution overrides also differ from secondary inputs. System E is runtime configuration, not a compile-time constant permitting deletion of the second instance.

| Operation | Actual concurrency/ownership | Sharing conclusion without scheduling changes |
| --- | --- | --- |
| CPU accesses to VDP1 versus VDP2 ports | A(2)/System E select one port at a time, system:1256–1259 | Common decode terms can be factored; local side effects/status and read data remain independently selected |
| Native background/sprite evaluation | Both VDPs run at the same enables, using independent state and VRAM | Cannot replace two arithmetic/cache-update pipelines with one owner mux on that edge |
| Pixel shift/reload, priority/color/collision | Both active on ce_pix, including simultaneous equal-X sprite reloads | All per-owner native state and parallel reads required by current schedule; output compositing does not make the hidden owner's history disposable |
| Sprite evaluator state branches within one owner | Exactly one FSM state/mode branch applies; count selects one cache slot per write | Normal plane data/predicates may be factored combinationally; no additional registered stage or removed hold behavior follows |
| Background versus sprite VRAM address mux | Existing x>=256 and x<496 selects sprite address, otherwise BG | Address selection already shares one native VRAM path per owner. It does not make shifter/color histories or all producers inactive |
| Architectural restore | Independent primary/secondary records consumed together after controller NBA raises strobes | A shared restore bus cannot provide distinct P1/P2 simultaneously; serializer needs new private authority/install proof |
| Snapshot/SAVE versus normal guest updates | Freeze holds native enables; private transport proceeds | Stable SAVE is useful, but LOAD needs private P while Q remains authoritative. No early guest writes or destructive live scan allowed |
| Palette/VRAM CPU versus renderer | Existing arbitration and physical RAM ports define exact read/write collision behavior | Port compatibility must be proved; CPU mutual exclusion across owners alone does not supply both renderer reads |

There are legitimate common inputs—presentation comparisons, x+8, screen ranges, host-write decode—and no reason to duplicate pure functions of identical wires intentionally. Some are already hoisted or synthesized together. A new shared combinational net must prove identical operands in all modes and preserve values on the consuming edge; its greater fanout can consume more buffering/duplicates than it removes. Instance similarity is not evidence of removable independent state.

The sprite feasibility study's reset distinction remains binding. The controller clears freeze on runtime reset, while sprite parent/shifter children lack a corresponding reset input. Live prefix installation cannot assume a recovery window. A native Boolean rewrite that leaves state, strobes and clock enables unchanged avoids that new partial-LOAD phase, which makes it semantically preferable to a storage conversion. It still requires full behavioral and physical proof before implementation.

## 8. Timing, routing and physical exposure

All paths below come from **existing source-bound production seed-1 exports**, not a new query. [timing.json](timing.json) retains compact data for the existing 50-path HDMI/core/CPU lists and restricted SDRAM/CRC/restore lists; exact traces remain in the diagnosis directory and original early path reports. Lists overlap and are not added as independent paths or TNS. The query definitions and SDC are unchanged.

| Existing cone | Worst slack | Data delay / skew | Scope and optimization exposure |
| --- | ---: | --- | --- |
| HDMI shadowmask RAM→OSD dsp_width[19] | +0.104 ns | 5.753 / −0.675 ns | 6.732 ns relationship, one logic level; 4.485 interconnect +1.268 cell delay. OSD/shared-DE rewrites directly affect this cone |
| Same RAM→h_cnt duplicate | +0.478 ns | 5.369 / −0.685 ns | 38 reported restricted endpoints; name/physical duplicate identity matters |
| Mapper CRC→T80 IR[3] | +0.895 ns | 16.941 / −0.460 ns | 18.626 ns relationship, 14 logic levels; 10.732 interconnect +6.209 cell. ROM/owner/cheat rewrites directly exposed |
| Restricted SDRAM sd_dat[2]→T80 IR[3] | +1.326 ns | 15.240 / −1.730 ns | Negative skew consumes substantial margin; changing bus selection or CDC/latency is not free |
| ce_vdp physical duplicate→primary cache d3 | +1.698 ns | 6.857 ns data | Existing enable query; evaluator factoring can alter a genuinely near-critical core control path |
| ce_cpu physical duplicate→snapshot | +1.704 ns | 6.824 ns data | Boundary/control distribution must remain intact even though controller optimization is excluded |
| freeze→secondary PSG cen_16 | +4.435 ns | 3.814 ns data | Pending audio/release ordering cannot be normalized to save control logic |
| Secondary restore→cache d2 | +4.996 ns | 12.781 ns data | Broad restore wiring; successful query does not prove every new localized design will pass |
| Primary shared restore→shifter40 | +8.589 ns | 9.330 ns data | Reported z80_set name is merged primary restore, not thousands of CPU-only sinks |
| Core worst hold, shifter60 shift0[2]→[3] | +0.239 ns | 0.347 / +0.108 ns | Directly in shifter family; one logic level, 0.230 interconnect +0.117 cell. Shortening local paths can consume hold margin |
| HDMI-group hold, scaler o_vdivr[16]→[17] | +0.259 ns | 0.363 / +0.104 ns | Scaler arithmetic/shift structures have hold exposure as well as setup |

The 50 core setup paths span +0.895 to +1.567 ns; the 50 HDMI setup paths span +0.104 to +0.637 ns. These are finite ranked lists, not every path in the netlist. No new selected sprite data-cone setup envelope was measured; global/core lists and control queries do not substitute for such a restriction. Existing node/location and path exports can support a later focused analysis, but this audit does not claim exhaustive fanout destination cones.

**Scaler timing is a real concern even though seed 1 is limited elsewhere.** In the existing original-v19 **seed-2 baseline**, the global setup limiter is scaler o_line3 RAM write-enable-register→o_vpix_outer[1].r[5], +0.401 ns, 4.952 ns data, −1.179 ns skew. This is production RTL with a different seed, not a new current baseline or an optimization result. The alias seed-2 candidate moves that endpoint to bit7; it cannot be used as a matched-path scaler saving. This illustrates why moving a mux into scaler line/tap logic needs both RAM-control and data timing coverage.

Retained seed-1 route metrics are:

- **Final interconnect total/H/V average 49.7/49.5/50.6%; peak 74.0/75.5/76.9%**, fit report lines7919–7920.
- Preliminary router estimates average40%, peak66%, X45_Y23–X55_Y34; these are different stages/metrics, not interchangeable with final utilization.
- Fitted routing usage: block interconnect51%, C4 54%, R3 53%, C2 48%, R6 42%, C12 36%, R14 43%; global routing ALUT18,266.

[topology.json](topology.json) retains fanout, mux and duplication rows. VDP-associated duplication operations partition into **1,476 shifter +483 evaluator +121 other VDP =2,080**, all in the router operation category for those sprite subgroups. The earlier aggregate is thus localized more precisely. Other records include scaler409, controller subtree16 and other sources778. Counting both register-packing and router operations globally gives a different operation total from the router-only2,962; those stages must stay distinct. Surviving sprite-name counts corroborate only the selected sprite duplicate population, not all other operation counts.

No evidence assigns each duplicated FF an otherwise empty ALM, nor proves that one shared enable caused each clone. The duplicated shift bits may serve scan/snapshot read, adjacent shift, pixel-head and local load consumers with different spatial needs. The transformation reason says **routability**, not the exact fanout partition. Forcing uniqueness could simply relocate muxes or consume route-through ALUTs. No per-module congestion grid or additive routing-ALM attribution is available.

The unchanged-source CRAM/scaler movement and CPU alias's seed-dependent HDMI failure are measured warnings about placement sensitivity. They neither prove an unrelated optimization intrinsically slow nor predict that another seed will pass. No statistical confidence or independent repeat-fit determinism is inferred from the retained pairs.

## 9. Ranked candidate mechanisms and proof requirements

The ranking orders investigative strength and potential scale, **not predicted ALM savings**. No numerical placed-area recovery is asserted for an unbuilt architecture. Module allocations overlap and cannot be summed to forecast a package of savings. Materiality here requires a credible net structural mechanism at whole-design scale; it does not require guaranteed savings before an experiment, but a large parent allocation alone is insufficient.

| Rank / bounded mechanism | Affected storage/logic and physical evidence | Replacement costs / M10K | Functional / timing / implementation risk | Selection gate |
| --- | --- | --- | --- | --- |
| 1. Native per-plane cache-write factoring, no storage/restore change | Both evaluator parents4,144.5 ALMs; 5,336 ordinary +483 duplicate FF; indexed writes, mode data choices, broad generated controls | Retain all cache/history FF and full restore. Shared8-bit data per plane, predicates and local slot decode;0 M10K; may add buffering | Medium semantics with exact same-edge transition miter; high routing risk near ce_vdp path. Moderate implementation | Strongest source target, but recognized muxes already heavily restructure. No demonstrated residual repeated selector removed; **not selected** |
| 2. Shifter input/control locality, retaining all33 bits/slot | 4,360.6 ALMs, 4,224 ordinary +1,476 duplicate FF; exact source reload/shift/restore structure | Per-slot X compare and independent cached data remain; common predicates might gain fanout/duplicates.0 M10K | High hold/routing risk, medium semantics across Mode4/legacy/wide/shift. Moderate complexity | No concrete unique Boolean network yet explaining avoidable surviving duplication. No blanket no-duplicate assignments; **NO-GO** |
| 3. Balanced sprite priority tree, existing output registers | Lowest-index active winner over64 slots, parent allocation includes it |63 binary combines remain; valid propagation/color mux, unchanged collision logic,0 M10K | Low-to-medium Boolean proof complexity; new internal routes; preserve register edge | Feasible regression, but no isolated priority cost or credible material area reduction versus current restructuring; **not selected** |
| 4. Mapper/CPU-read shared ownership decode |808.1 selected mapper/decode ALMs plus shared system logic; measured14-level CRC→IR cone | One-hot guards, priority exclusion/OR tree; no new storage or0 M10K intended; buffering possible | High semantic overlap/BIOS/mapper/decryption risk and near-critical setup; moderate-high complexity | Source predicates already shared in places; no disjoint duplicate decoder cost proved; **NO-GO** |
| 5. Scaler mode/tap/width or arithmetic reorganization |2,394.7 subtree ALMs,43 M10K,409 duplication records; dual-axis filter pipelines | Preserve all filter modes/precision/history; sharing adds muxes/working state, RAM ports or DSP cost | Very high throughput/CDC/mode-transition risk; observed seed-2 critical cone; large proof surface | No complete port/schedule/range invariant; **NO-GO** |
| 6. Cheat balanced last-match reduction or valid-only reset |539.9 ALMs/1,104 FF;32 associative comparisons in CPU path |31 combine nodes still needed; payload FF retained; valid qualification/clear/load decode,0 M10K | Moderate semantics, manageable component miter; high CPU setup exposure | Concrete rewrite possible, weak material-area mechanism; **not selected** |
| 7. One OPLL logic array mapped to exact-port RAM |Phase203.6, register137.3, output182.1, feedback75.8 ALMs; deliberate logic arrays | Phase/register each plausibly one block before proof; two output reads may replicate; retain pipeline/init/ss response; extra mux/output control | High raw-FM/savestate semantics, medium timing, substantial audio regression | Naturally addressed unlike sprites, but modest individual scale and no verified primitive/RDW contract or net benefit; **not selected** |
| 8. Config-string ROM / PLL arithmetic / BG constant-divisor rewrite |Concrete small selectors,41-bit shift/add or roughly109.5 BG-helper envelope | RAM output/read latency or new sequencer/lookup/control; targeted cost is only part of parent | Low-to-high depending cone; each needs exact protocol/range proof | No source-bound isolated material target; do not bundle unrelated tweaks to claim materiality; **NO-GO** |

Required regression strategies, if a future bounded candidate becomes justified:

1. **Native sprite factoring/tree:** renamed committed-versus-candidate full64-slot component miter, every state/cache/shift/fixed output and edge; both owners with independent VRAM/modes; arbitrary legal host enables and no extra pipeline cycles. Include count0/7/8/31/32/63/64, x255/257/496/511, FF X wrapping, shifted load, wide/tall, Mode4/legacy transitions, low-eight collision versus extended priority, restore priority and legacy zero defaults. Preserve uninitialized/reset semantics rather than masking data. Then retained G02–G06/G10, System E IRQ, SAVE-only/repeated LOAD, pending collision, all phase classes, long suffix, Pause and DDR-stall/error suites; no local restore prefix added.
2. **Mapper/cheat:** all overlap/priority matches, optional compare, load-toggle/reset/index saturation and enable transitions. Exercise every mapper family, BIOS/cart precedence, read/write side effects, open bus, System E VRAM windows and decryption; CPU fetch/data/NMI/G01 preparation, G11/G12 live SDRAM restart, stalls/stale responses and immutable complete images.
3. **Video/scaler/framework:** exact pixel/DE/HS/VS and accepted memory transactions under all filters, formats, coefficients, input/output dimensions, interlace/rotation, palette updates, underflow/backpressure, mode changes and reset; cross-domain timing/latency and both output pipelines. Guest-state savestate proofs alone do not qualify a framework video change.
4. **OPLL/audio or palette:** exact old-data collisions, initialization, fixed local response latency, full raw-row and first-sample/stereo equality, all F01/G08.FM release cases, repeated LOAD and long audio suffixes; CRAM additionally needs public64 secondary fallback and the original native palette suite. These tests are required, not newly run results.

Any subsequently authorized physical experiment needs source-isolated fresh matched baseline/candidate fits with unchanged date/tool/settings/constraints and full map/fit/asm/STA evidence. Confirm an apparent win with a second **paired** seed; compare needed and placed, logic/routing ALUT, mapped/fitted FF, M10K/DSP, final directional interconnect, setup/hold/TNS/endpoints and warnings. Require actual lower whole-chip placed ALMs with positive constrained timing and acceptable routing/resources; a local/module or needed-only win is insufficient. No seed shopping or relaxed constraints. This paragraph defines future gates; no build is authorized or launched by this report.

## 10. Historical-rejection cross-check

| Excluded approach | Existing result / architectural limit | Why the remaining native hypotheses differ, and why that is insufficient by itself |
| --- | --- | --- |
| Packed sequential sprite RAM with global scatter | v17 net−9,397 mapped FF,+2 M10K, about+5,402 logic ALUT. Seed1 route failed; seed2 setup−0.100. Its−586 versus seed1 baseline is unpaired/unqualified | Native write factoring retains private rings/full restore and adds no selected packed-state port. Distinct scope; still no physical benefit proved |
| Sprite common-mux extraction / masks | v16 board+47 placed/+106 needed; masks+9,532 standalone ALUT | It targeted controller capture/rotation, whereas proposed native factoring targets evaluator cache updates. A different source location alone does not prove new savings; current mux restructuring must be respected |
| CRAM inferred-memory substitution | v19−1,055 needed,+121 placed,+4 M10K; local−712.7 allocation offset elsewhere | No repeat selected. Explicit primitive ports would need a separate new contract, not a memory-attribute retry |
| CPU restore-output alias | Seed1−142 placed but setup−0.714; paired seed2−4 placed, routing+105 and peak72.8→72.9% | No further CPU output or source alias variant. This also rules out assuming FF deletion implies a useful global gain |
| Format consolidation | v17 paired+27 placed,−8 mapped FF; unrelated seed2 negative setup | All accepted formats/bytes/defaults retained. Compatibility syntax is not a large non-controller waste bank |
| Destructive live sprite scan | Frozen live Q is altered; observer/abort/reset and rollback authority unproved | Not proposed as a native/control factoring mechanism; no live scans or altered clocks |
| Local sprite RAM with unproved interruption | Eight-slot local bank architecture changes distribution but runtime reset clears freeze before narrow rollback can be assumed complete; atomic FF variants restore most storage | This audit retains the exact atomic restore interface. It does not reopen that STOP by calling local RAM a receiver optimization |
| Seed/packing/constraint shopping | Earlier pairs demonstrate physical sensitivity, not guaranteed favorable outcomes | No settings, seed sweep, feature removal, false paths, multicycle exceptions or duplicate-suppression assignments proposed |

Historical G06/G10 **+5,458 placed** spans snapshot banks, receiver choices and global mapping. It is not an 8,505-ALM native-engine optimization budget, nor proof the pre-savestate live engine can be recovered unchanged. G05's +576 historical placement includes controller storage and helper/receiver effects; the current BG-only allocation is smaller. Current source and global counters remain v19 throughout this audit.

## 11. Exactly one recommended next action: STOP

**STOP without selecting or implementing a PoC.** Preserve committed v19 and await review. The hierarchy and source identify concentrated native sprite costs, but no reviewed candidate combines a demonstrated residual cost-removal mechanism, credible material whole-design area benefit, preserved cycle/restore semantics and bounded timing/routing exposure well enough to meet the selection gate.

The main missing evidence for the leading idea is specific: **which repeated normal-write selector or decoder remains after current mux restructuring, which exact slot/plane sinks consume it, and how a same-edge factored network would reduce that implementation after its own fanout/buffers are included**. For shifters, the missing connection is a topology that reduces the need for the 1,476 surviving routability duplicates while retaining all concurrent consumers and hold margin. This audit establishes where those nodes are and their aggregate cost, but does not establish such a replacement. For scaler, a complete throughput/precision/port schedule is missing; for smaller candidates, the isolated physical opportunity is too weak to justify a material-area selection.

This is not a claim that no future optimization can work, and it does not require an exact ALM forecast before experimentation. It rejects selecting a build simply because a parent is large, because source code is repetitive, or because a miter would be easy to run. Guaranteed qualified savings remain **zero**. No additional investigation, compilation or fallback trial is started here.

## 12. Preservation and final Git state

[verification.json](verification.json) records final unchanged HEAD/branch, 204 tracked hashes,137 retained seed-1 inputs,135 normalized HEAD comparisons and all **305 evidence hashes** retained by this audit. Existing tests/builds/reports were read in place; no old generator was run to refresh its evidence. The full baseline register/timing exports were mined without loading a Quartus database. No candidate tree or experimental HDL was created.

New files are confined to `tests/non_savestate_optimization_audit/`. Ordinary Git diff statistics omit that already-untracked tests tree.

Final `git diff --stat`:

```text
(empty)
```

Final `git status --short`:

```text
?? tests/
```

Branch remains `investigate/cram-memory-inference`; HEAD remains `1b2a52d87d2659c908d4f9f846416d14bfd85bea`; index unchanged. No production edits, tests weakened, format changes, Quartus/simulator invocation, commit, push, merge, PR, branch change, checkout, reset or clean. **NO-GO; stop after the report.**
