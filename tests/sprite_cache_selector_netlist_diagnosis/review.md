# Native sprite cache-write selector diagnosis — committed v19

**INCONCLUSIVE on surviving normal-write selector duplication. STOP; no PoC selected.** The retained evidence demonstrates some shared evaluator control and clear logic, and extensive mux restructuring. It does **not** expose complete mapped data-pin fanin, LUT truth tables or count-decoder connectivity for all five cache fields across the 64 slots. Consequently it cannot distinguish a materially repeated identical normal-data network from already factored data plus required local write/restore logic.

This is an evidence limitation, not proof that all normal-write expressions are shared, and not a finding of redundant combinational logic. Zero removable LUTs are demonstrated; that is not an upper bound of zero on a future optimization. No production RTL, candidate, netlist or Quartus result was generated.

## 1. Verified v19 provenance

HEAD **1b2a52d87d2659c908d4f9f846416d14bfd85bea**, branch **investigate/cram-memory-inference**, savestate **v19 / tag0x484313**, 96 KiB container. All **204 tracked raw hashes** match the established committed baseline. Tracked/index diffs remain empty. All **137 retained build inputs** match their raw manifest hashes; final verification independently compares **135** to HEAD with CRLF/LF normalization. The other two are unused `.bak`/`.orig` files. The manifest's historical HEAD label predates v19; actual content comparison establishes provenance.

Authoritative build: [savestate_g08_fm/quartus_early](../savestate_g08_fm/quartus_early/), Quartus Prime Lite **17.0.2 Build602**, Cyclone V **5CSEBA6U23I7**, SMS/sys_top, **seed1**, **BUILD_DATE261025**, **MISTER_FB=1**. Original QSF/SDC/QIP/IP, STANDARD FIT, HIGH PERFORMANCE EFFORT, SPEED, LOW ALM register packing and physical/router optimization configuration are unchanged.

| Retained production seed1 metric | Value |
| --- | ---: |
| Needed / placed ALMs | 37,117 / 38,599 |
| Mapped / fitted registers | 46,327 / 48,880 |
| Logic / routing ALUTs | 46,835 / 18,266 |
| M10K | 488 /553 |
| Setup / hold slack | +0.104 /+0.239 ns |
| Reported violating timing groups | 0 |

Inherited unconstrained categories and critical warnings remain. No new signoff coverage or statistical robustness is claimed. The four requested reports were read in full: [non-controller audit](../non_savestate_optimization_audit/review.md), [structural audit](../structural_resource_audit/review.md), [v16 sprite experiment](../savestate_sprite_resource_optimization/review.md), and [v19 sprite feasibility](../sprite_restore_architecture_feasibility/review.md). Historical experiment results are not substituted for this baseline.

[provenance.json](provenance.json) binds the source/input ledger and **1,001 retained evidence hashes**. In addition to the existing reports/exports, this investigation hashes all **624 files /288,117,631 bytes** under the authoritative build's db, incremental_db and output_files directories. [artifact_inventory.json](artifact_inventory.json) records names and sizes. These include opaque retained netlist databases, not merely report summaries. No database was loaded by Quartus or regenerated.

The controller SHA256 remains `e8de50db09447138fc661205fb9edd178d45e691819a056bad87631ef3d76557`; [collect.js](collect.js) verifies source and existing evidence before deriving the new tables. All new outputs are analytical files under this directory.

## 2. Exact source-level normal-write truth tables

Source is [vdp_sprites.vhd](../../rtl/vdp_sprites.vhd), production MAX_SPPL=63, independently instantiated for both owners. Each owner has X and four plane arrays, each64×8: **2,560 cache bits/owner**, 5,120 total. Enable64 is separate. Both instances run simultaneously in System E with independent VRAM data, flags, modes, count/state and restore buses. A common expression means common **within an owner** unless exact identical operands across owners are proved; runtime similarity is insufficient.

The following is an exact binary-input functional decomposition of the existing clocked assignments. It is a specification extracted from the source, **not a mapped implementation or new RTL**.

Notation:

- `R = ss_regs_set`, `V = ss_sprite_valid`, `M = smode_M4`, `T = tall`, `F = old m2_flags[7]`, `B = current vram_D[7:0]`.
- `C_i = (count == i)`, with the complete integer count0..64, for physical slot i0..63. Do not truncate to six bits and alias count64 to slot0.
- `E = ce_spload`; in production `E=ce_vdp` when sp64=0, otherwise ce_sp (:135). These already receive the top-level freeze gating.
- `N = !R && E && x!=257 && x!=496`. Let `P_i=N && C_i`. State names below denote the **old** three-bit state at the edge: WAITING=000, COMPARE=001, LOAD_N=010, LOAD_X=011, LOAD_0=100, LOAD_1=101, LOAD_2=110, LOAD_3=111.
- `S_i` denotes the corresponding restored field in ss_sprite_in. Arithmetic on X is modulo256. No new registered precomputation or host edge is implied.

### Priority before normal writes

| Highest applicable branch, sampled at rising clk_sys | X/d0/d1/d2/d3 | Other relevant actions |
| --- | --- | --- |
| R=1, V=1 | All slots take their independent saved fields | Evaluator WAITING, count0,index0; restore enable/address/flags/overflow |
| R=1, V=0 | All slots zero | Same normalization and legacy-zero defaults |
| R=0,E=0 | Hold | No normal evaluator write |
| R=0,E=1,x=257 | **Hold all five cache fields** | Clear all enables/count/index/overflow; stateCOMPARE |
| R=0,E=1,x=496 | **Hold all five cache fields** | stateWAITING; other fields hold unless otherwise assigned in this branch |
| R=0,E=1,other x | Only selected count slot and listed state writes below | Unassigned registers hold |

The x257 clear is **not** a cache-array clear. Only legacy restore explicitly zeroes every cache field. There is no runtime reset_n input in this entity; state has a declaration initialization, but arbitrary current cache history is not erased by host reset. Restore takes precedence even if an enable or boundary coincides (:145–185).

### Normal writes for selected slot i

Every row requires `P_i`. Every unlisted state/mode combination holds that field.

| Field | Mode/state/extra condition | New data | Source lines |
| --- | --- | --- | --- |
| X | M=1,LOAD_X | B−1 |236 |
| X | M=0,LOAD_X,F=0 | B−1 |301–302 |
| X | M=0,LOAD_X,F=1 | B−33 |303–304 |
| d0 | M=1,LOAD_0 | B |240 |
| d0 | M=0,LOAD_1 | B |311 |
| d1 | M=1,LOAD_1 | B |244 |
| d1 | M=0,LOAD_1 | 0 |312 |
| d1 | M=0,LOAD_2,T=1 | B |319–320 |
| d1 | M=0,LOAD_2,T=0 | **Hold** |319–321 |
| d2 | M=1,LOAD_2 | B |248 |
| d2 | M=0,LOAD_1 | 0 |313 |
| d3 | M=1,LOAD_3 | B |252 |
| d3 | M=0,LOAD_1 | **old registered m2_flags[7:0]** |314 |

Equivalent same-edge write predicates/data relationships:

| Field | Normal write predicate, apart from P_i | Data on a write |
| --- | --- | --- |
| X | stateLOAD_X | `B - (M || !F ? 1 : 33)` |
| d0 | `(M && stateLOAD_0) || (!M && stateLOAD_1)` | B; **no Mode4/legacy normal-data mux required functionally** |
| d1 | `stateLOAD_1 || (!M && stateLOAD_2 && T)` | Zero only for legacy LOAD_1; B otherwise |
| d2 | `(M && stateLOAD_2) || (!M && stateLOAD_1)` | B for Mode4; zero for legacy |
| d3 | `(M && stateLOAD_3) || (!M && stateLOAD_1)` | B for Mode4; old m2_flags otherwise |

These predicates can be written once symbolically. That alone does not establish whether the mapped circuit currently contains one copy or 64. Synthesis can absorb them into FF ENA/SCLR, local muxes, or shared control, with different Boolean decompositions.

### Count/index, mode and boundary subtleties

- Mode4 accepts a matching Y row in COMPARE only when count<64 and (count<8 or sp64=1). Legacy accepts when count<32 and (count<4 or sp64=1). These are **admission checks in COMPARE** (:213,:272), not extra guards on every LOAD-state write. Do not add them to the write equations or assume an unchanging mode/configuration across a multi-edge evaluation without proof.
- Mode4 terminates at d9=208 only when smode_M1=0 and smode_M3=0. Legacy terminates at d9=208 unconditionally. d9 is nine-bit B, with B>=240 adjusted by−256; delta and tall/wide tests select admission. None directly changes cache write data once in a LOAD state.
- A nonmatching Mode4 COMPARE increments index only if index<63; legacy only if index<31. At successful completion, index increments in its six-bit width regardless: no blanket index31/63 suppression is present in those completion branches. Preserve that distinction rather than inventing an index clamp.
- Mode4 LOAD_N→LOAD_X→LOAD_0→LOAD_1→LOAD_2→LOAD_3; final LOAD_3 sets enable(count), increments count and index, then COMPARE. Legacy LOAD_N→LOAD_0 (captures m2_flags)→LOAD_X→LOAD_1→LOAD_2; final LOAD_2 enables/increments even when tall=0 and d1 holds. All fields use pre-edge count and flags, not incremented count or a new combinational flags value.
- `count=64` is representable, but is not a valid cache subscript. A replacement must not silently turn an out-of-range LOAD-state access into a write to slot0. This report does not extend the source's legal indexing contract or claim every arbitrary forced state is reachable. The full-count comparison and existing edge priorities remain obligations.
- Slots0/7/8/31/32/63 use the same LOAD-state assignment rules when selected; different limits arise from admission and mode history. Full saved records can independently populate all slots, including currently inactive planes. No field omission or zero assumption follows from normal limits.
- Both VDPs have independent valid/restore inputs. Their architectural restore edge remains the original receiving edge after the controller's strobe NBA; no private preparation, staggered install or release timing is changed here.

## 3. Available netlist connectivity and its limitations

The retained artifacts were searched and inspected in place. This investigation did **not** create a new mapped netlist, run EDA export, launch a tool database query, synthesize or analyze timing.

| Artifact | Information actually available | What it cannot establish here |
| --- | --- | --- |
| SMS.map.rpt / structural tables | Exclusive synthesis counts, recognized mux widths/estimates/example names | Full LUT input-net identities, masks, actual common data-driver graph or exact decoder sharing |
| SMS.fit.rpt / transformation table | Fitted counts, top fanout, named clone source/destination and reasons | Each cache D/ENA/SCLR fanin graph; why every clone is necessary or removable |
| Existing TimeQuest path text | Selected ordered cell/pin arcs, locations, fanout, delays; some real sharing demonstrated below | All other LUT inputs, truth tables, complete fanout lists and all64-slot cones. These are **post-fit** paths, not the post-synthesis network |
| baseline_registers.tsv / selected locations.tsv | Surviving cache FF names; selected other queried locations | Combinational connectivity. The selected location export has **no cache-node rows**; cache positions available here come from timing traces |
| db/SMS.hier_info | Textual hierarchy/operator port connections; two sprite sections each28,281 lines | Unique mapped LUT identities/masks or a complete cache-register D-driver graph |
| db/*.tdf | Generated operators such as lpm_decode/mux and RAM implementation descriptions | Binding of a particular generic operator to each cache's post-map logic, final Boolean factoring or physical cost |
| SMS.map.cdb/hdb, SMS.cmp.cdb/hdb and related binary databases | Retained original synthesis/fitted databases; hashed and preserved | No compatible readable full combinational export was found. They were not loaded or reverse-engineered; absence of a readable export is not absence of a stored netlist |

No .vqm/.vo/.vho/.edf/.edif/.eqn gate-level export was found in the authoritative retained build. Searches of the relevant audit/diagnosis exports likewise found no full cache-cone pin/LUT-mask dump. Binary database presence is explicitly acknowledged rather than concluding that no netlist exists.

The `SMS.hier_info` discovery adds source-bound structural evidence beyond the earlier aggregate audit, but it is **operator/port-level evidence**, not proof of surviving LUT replication. Primary section lines378854–407134 and secondary453773–482053 contain repeated entries such as `vram_D[0] => spr_d0.DATAB`, `tall => spr_d1.OUTPUTSELECT`, FF clock and outward snapshot associations. Repeated generic destination spelling lacks the unique slot/operator IDs needed to establish 64 distinct mapped data-select cells. Neither section contains `lut_mask`, `combout`, LABCELL or physical FF location fields. Its exact compilation stage is not inferred from the filename alone.

[hierarchy_connectivity.json](hierarchy_connectivity.json) retains representative original line references. For primary slot0, line392166 associates `ss_sprite_out[9]` with `spr_d0[0][0].DB_MAX_OUTPUT_PORT_TYPE`; line392158 similarly associates X bit0. Secondary equivalents are467085 and467077. These identify state/read associations, **not their D-input drivers**. `vram_D[0]` has264 textual port associations per section; that number is not physical fanout. A `count[0]` match provides its clock association, not six-/seven-bit decoder fanin.

The missing decisive evidence is a source-bound **post-map atom connectivity/Boolean export**, for both owners, covering every cache bit's D/ENA/SCLR and all upstream combinational cells to VRAM data, m2_flags, mode/tall, count/state, boundaries, restore input/valid/strobe and feedback. It needs unique cell and net IDs, pin order, LUT masks/equations, arithmetic/carry identities, polarity and cell types. To distinguish synthesis sharing from fanout replication, the corresponding post-fit fanout/clone correspondence and locations are also needed. A path report alone cannot supply that full graph. No such export is generated in this task.

## 4. Shared versus duplicated selector evidence

### Mapping report, all slots and both owners

[mapping.json](mapping.json) extracts **640 registered eight-bit cache mux rows**, 64×five fields×two owners, covering all5,120 cache bit positions. These are recognition/statistical rows, not 640 physical mux instances. The table below shows the exact uniform row values per owner.

| Field | Rows per owner | Recognized inputs | Baseline estimate per row | Restructured estimate per row | Primary /secondary map lines |
| --- | ---: | --- | --- | --- | --- |
| d0 |64|19:1|96 LEs|0 LEs|4026–4089 /3961–4024 |
| d1 |64|21:1|112 LEs|0 LEs|4505–4631 /4376–4502, interleaved X |
| d2 |64|21:1|112 LEs|0 LEs|4228–4354 /4100–4226, interleaved d3 |
| d3 |64|21:1|112 LEs|16 LEs|4229–4355 /4101–4227, interleaved d2 |
| X |64|21:1|112 LEs|16 LEs|4506–4632 /4377–4503, interleaved d1 |

For example the primary d3 row names `spr_d3[63][0]`; secondary names `spr_d3[63][6]`. The named bit is the **example multiplexer output**, not a complete list of mapped cells for all eight bits. Zero residual LE estimate does not mean d0/d1/d2 registers, clear/enable or restore logic are free. Conversely X/d3's16-LE residual cannot be assigned solely to duplicated normal-data selection: the table does not separate hold, restore, index decode and data choices. Arithmetic addition or Boolean sharing may also exist outside the recognized group.

Summing X/d3 residual numbers would give `128 rows/owner ×16 =2048 estimated LEs/owner`, 4096 across owners. This is arithmetic on an optimizer estimate, **not a verified count or upper bound of removable LUTs**. It must not be converted to ALUT/ALM savings. The large baseline estimates are still less suitable as a prediction.

### A–D classification

| Class | Evidence and status |
| --- | --- |
| **A: shared mapped expressions** | Actual fitted primary `state~0` LUT drives263 reported loads and feeds a second LUT used by three observed d3 slot6 bit-enable paths. A secondary clear-control LUT drives550 loads and reaches multiple d2 slot18 SCLR pins. Thus some sharing is directly demonstrated. Normal-data factoring across64 slots remains unknown |
| **B: identical redundant combinational replicas** | **None demonstrated.** No pair of distinct normal-data LUTs is supplied with complete identical input-net tuples and truth tables. The X/d3 residual estimates are suspects, not evidence of this class |
| **C: required slot-specific logic** | Functionally, `count==i` differs across slots; hold/old Q_i and arbitrary restored S_i differ; FF receiving sites and independent values remain. Those complete functions cannot be replaced by one identical data/enable function. The number and topology of actual mapped count decoders are unknown |
| **D: physical duplication** |483 evaluator register-clone records correspond to483 surviving named duplicate FF nodes in the retained exports.397 belong to X/d0–d3,86 to other parent state. This demonstrates physical **FF** replication, not redundant combinational data selection. No complete cache combinational-buffer/clone partition is available |

Both evaluator parents have **2,668 synthesis FF**, exactly their declared state count, with **2,305 primary /2,311 secondary own synthesis ALUT**. Fit gives **2,910/2,909 own FF**, and the same own ALUT counts. That aggregate ALUT equality does not prove identical cells or connectivity survived fitting. Existing surviving cache register names number **5,517 =5,120 ordinary +397 duplicates**, recorded in [cache_nodes.json](cache_nodes.json). The router log attributes the parent clones to routability; those cloned FFs must not be reclassified as64-way selector copies.

For d0 there is only one normal data source B; its source-level Mode4/legacy difference is **write timing**, not write-data selection. For d1/d2, zero writes can sometimes map to SCLR rather than data muxes. The observed secondary SCLR path supports the presence of a shared clear implementation, but does not reveal every normal zero-write mapping. For d3, B versus m2_flags is a genuine owner-common normal-data choice; X has owner-common offset arithmetic. Whether those are already common drivers or repeated LUT cones is precisely what remains unresolved.

## 5. Exact observed nodes, fanout, placement and timing

Names in the following paths use TimeQuest's physical report spelling, where intermediate elements omit entity types. They are not substituted for names at another compilation stage. Original row references and selected cells are retained in [timing_excerpts.json](timing_excerpts.json).

### Primary normal-control path, actual ENA consumer

From [vdp_enable_setup.rpt:94](../structural_resource_audit/vdp_enable_setup.rpt:94):

| Source / destination pin | Location | Reported output fanout | Meaning established |
| --- | --- | ---: | --- |
| `emu\|ce_vdp~DUPLICATE\|q` | FF_X25_Y32_N13 |33|Native enable launch, falling/inverted source edge |
| `emu\|system\|vdp_inst\|vdp_main_inst\|vdp_spr_inst\|state~0\|datac → combout` | LABCELL_X24_Y40_N33 |263|One shared control LUT on these paths; full other inputs/equation absent |
| `...\|spr_d3[6][7]~50\|dataf → combout` | LABCELL_X33_Y47_N24 |8|One output reaches three independently reported bit ENA consumers; exact remaining five sinks not enumerated |
| `...\|spr_d3[6][0]\|ena` | FF_X30_Y56_N59 |1 at FF result row|Register enable pin, **not D** |
| `...\|spr_d3[6][7]\|ena` | FF_X30_Y56_N52 |1 at FF result row|Same two upstream LUT locations |
| `...\|spr_d3[6][6]\|ena` | FF_X30_Y56_N55 |1 at FF result row|Same two upstream LUT locations |

The report has three setup paths: +1.698/+1.699/+1.699 ns, relationship9.313 ns (half the18.626 ns emulation-clock period), skew−0.428/−0.435/−0.429 ns and data6.857/6.849/6.855 ns. First path data is5.536 ns interconnect +1.321 ns cell, **two logic levels**. The FF's final row is not another LUT. There are exactly **two unique combinational cell locations on these three traces**; this is a verified local path count, not the total selector-network cost.

This contradicts the simplistic assumption of one independent mode/state enable expression for every bit of a byte. It does not prove all64 slots share their count predicates or their normal B/flags data selectors. New common-data routes could add fanout to an already shared, spatially distributed control network; buffering or replication is plausible but unmeasured.

### Secondary restore/default path, actual SCLR consumer

[vdp2_restore_setup.rpt:94](../structural_resource_audit/vdp2_restore_setup.rpt:94) reports:

| Source / destination pin | Location | Output fanout |
| --- | --- | ---: |
| `emu\|savestates_inst\|vdp2_regs_set\|q` | FF_X40_Y31_N41 |5,448 |
| `emu\|system\|vdp2_inst\|vdp_main_inst\|vdp_spr_inst\|data_address[9]~0\|combout` | MLABCELL_X3_Y11_N33 |156 |
| `...\|spr_d2[63][3]~0\|combout` | LABCELL_X31_Y27_N54 |550 |
| `...\|spr_d2[18][7]\|sclr` | FF_X23_Y8_N56 |FF result row1 |

Worst slack+4.996 ns, data12.781 ns, two logic levels. [legacy_setup.rpt:94](../structural_resource_audit/legacy_setup.rpt:94) traces `has_restart` at FF_X43_Y27_N11, fanout1,410, into **another input of the same first LUT**, then the same550-load second LUT, reaching d2[18][4] SCLR at FF_X23_Y8_N38, and bits6/7 in the other reported paths. Its worst slack is+6.363 ns, first-path data11.414 ns. These are restore/presence/default arcs; **not evidence of normal VRAM data reaching a D pin**.

The generated name `spr_d2[63][3]~0` therefore cannot be assumed slot63-specific data logic: an observed sink is slot18, and its output has550 loads. Likewise `data_address[9]~0` is an alias for mapped combinational logic on this path, not proof of an address-data connection to every cache bit. MLABCELL is a physical location class here; global fitted MLAB memory use remains zero.

### Other fanout and timing evidence

The Fitter high-fanout table names primary/secondary `data_address[0]~1` with3,440/3,471 direct loads; generated d1/d2 controls have548–568 loads; mode_M4 has667/614. These counts locate broad cones but lack full sink/mask descriptions. They do not identify a replicated normal-data selector or a removal budget. New owner-common write data bits would each reach up to64 logical slot data choices before factoring/buffering; current physical fanout for those particular B/flags/offset nets is **not measured by these reports**.

The retained 50 worst core setup and50 worst core hold paths have **no X/d0–d3 cache start/end names**. That is a limit of ranked coverage, not proof cache D paths have ample margin. The selected ce_vdp paths are ENA, and the secondary paths are SCLR. No complete normal VRAM/m2_flags/X-arithmetic→cache-D setup/hold list or count→all-slot-D/ENA list was found.

Nearby worst hold is primary shifter60 shift0[2]→[3], +0.239 ns, data0.347 ns and skew+0.108 ns. Shifter state differs from cached planes; this does not establish a cache hold bound. Global seed1 setup remains HDMI shadowmask→OSD +0.104 ns; core CRC→T80 +0.895 ns. A source-local change can perturb unrelated placement. No path or gate is relaxed here, and positive existing timing is not a guarantee for additional shared fanout.

## 6. Defensible opportunity bounds and same-edge alternative

| Quantity | Defensible interpretation |
| --- | --- |
| Verified removable identical normal-data LUTs | **0 demonstrated**; absence of a demonstrated set is not proof none exist |
| Exact mapped cache-selector/decoder cell count | **Unavailable**: no complete atom fanin graph/masks |
| Very loose own-hierarchy combinational ceiling | Primary2,305 +secondary2,311 =**4,616 ALUTs** contain cache selection **and** scanner/address/priority/collision/restore/control. Within this reported allocation convention any wholly parent-contained target is a subset. This is not a cache-only bound on physical changes or recoverable area |
| Tighter verified removable-logic upper bound | **Cannot derive from retained evidence**. Cross-boundary packing/sharing and physical resynthesis prevent using the hierarchy ceiling as an optimization forecast |
| X/d3 residual2048 LE estimates/owner | Statistical source-mux estimates; neither surviving LUT count nor removable upper bound |
| Clone counts397 cache /483 parent | Fitted duplicate FF, not combinational opportunity |
| Unique LUTs on primary observed three paths | Two, already shared locally. Their full truth tables and all sinks are unknown; neither is shown redundant |

The **same-edge** abstract alternative would form the normal plane predicates/data from section2 once per owner and retain each slot's independent full-count select, feedback, restored data and priority. No cache/state FF can disappear merely from factoring a normal-data expression. In particular d0 offers no functional normal-data choice to remove, and restore inputs across slots remain different. New global eight-bit data paths and plane predicates still need local write qualification and physical delivery. Preventing synthesis from factoring or duplicating them is not assumed.

For scale only: if a literal independent eight-bit B-versus-flags mux existed64 times, replacing it by one could remove at most `(64−1)×8=504` **abstract 2:1 bit-mux positions per owner before replacements**. This is a conditional representation count, not evidence that such muxes exist. It omits slot hold/restore/control, LUT packing and routing, and must not be converted to ALUT or placed ALM savings. X's arithmetic and offset-selection mapping need their own graph; adding another504 as a measured opportunity would be unsupported. d1/d2 may already exploit clear/enable primitives.

Because complete next-state functions contain Q_i, S_i and count==i, their truth tables differ by slot even when their normal-data **subexpression** is common. Only a cut below those slot-specific inputs could be merged. We cannot locate/count that cut in the current mapped data network. Under the user’s GO criterion, no material surviving duplicated combinational network or safe net physical replacement has been demonstrated.

## 7. Comparison with prior sprite work

The v16 **common-mux extraction** factored controller sprite snapshot capture/rotation/insertion, retaining9,600 shadow FF and all receiver paths. Board placed ALMs increased47, needed106; the parallel-mask formulation added9,532 standalone ALUT. This task's normal-data hypothesis concerns **native evaluator cache writes**, with original shadow banks/restore interface untouched, so it is not the identical source transformation. That distinction is necessary but insufficient: native gate duplication must first be demonstrated, rather than inferring benefit from a new RTL location.

The v17 packed300×32 scratch/global scatter changed state storage and receiver access, adding thousands of ALUTs and failing physical qualification. The later local-RAM feasibility study found a runtime-reset interruption gap for direct live installation; atomic shadows retained most storage. None proves the normal evaluator data-selection network redundant, and none is reintroduced here. A Boolean same-edge factoring proposal would avoid a new partial-LOAD stage but still preserve freeze, restores/defaults and native execution exactly. There is no permission to alter savestate bytes, System E ownership, first native enable, or error/reset behavior.

No new synthesis, simulation or fit supports any candidate in this diagnosis. Old passing tests and failing resource experiments remain evidence under their own source/version/seed scopes.

## 8. Decision and exactly one recommended next action

**INCONCLUSIVE. Recommended action: STOP after this report; do not implement a PoC.**

Some common control logic is physically shared; slot-specific functions are necessary; physical FF clones are real. The specific question—materially duplicated **identical normal-write data-selection LUT networks** versus already factored expressions—cannot be resolved from the retained readable connectivity. A GO would exceed the evidence. A definitive NO-GO on the basis that every such network is already shared would also exceed it.

The outstanding prerequisite is the existing-source **post-map pin/LUT-equation connectivity** described in section3, with sufficient pre-/post-fit correspondence to separate factoring from routing replication. This identifies the missing measurement; it is not a recommendation to synthesize or a request to launch another tool. No Quartus query/export, timing analysis, new netlist, seed or candidate is run. Await review before any further work.

## 9. Final Git state and preservation checks

[verification.json](verification.json) verifies unchanged HEAD/branch,204 tracked hashes,137 retained inputs,135 normalized HEAD comparisons and1,001 retained evidence hashes, including all624 authoritative build database/output files. Existing reports, builds and untracked artifacts remain in place. New analysis files are confined to `tests/sprite_cache_selector_netlist_diagnosis/`.

Final `git diff --stat`:

```text
(empty)
```

Final `git status --short`:

```text
?? tests/
```

Index and production sources remain unchanged. No RTL/candidate/netlist creation, formats/constraints/IP changes, test weakening, simulation, Quartus synthesis/fit/route/timing/query, branch change, checkout, reset, clean, commit, push, merge or PR. **INCONCLUSIVE; stopped after the report.**
