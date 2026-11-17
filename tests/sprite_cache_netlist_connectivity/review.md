# Bounded Quartus sprite-cache connectivity investigation — v19

**NO-GO for the proposed per-slot normal-data factoring PoC. STOP.** The retained **post-map** netlist already shares the nontrivial X and d3 data expressions across **all 64 slots of each owner**. There are **30 common data LCELL_COMB nodes**: seven X result-bit selectors and eight d3 selectors per VDP. X bit0 uses the common VRAM read bit directly, with inversion folded into each slot's required restore-data mux. The remaining per-slot D muxes have independent saved-data inputs; the count predicates select different slots. They are not 64 identical normal-data networks that a new shared-data architecture would eliminate.

Both post-map and post-fit databases were opened without compilation, entirely in an isolated copy. Complete requested six-slot connectivity and an all-slot final-D inspection were retained. An **optional later atom-mode metadata query asserted inside Quartus**; further tool calls stopped. This limits arithmetic-mode equivalence claims and one extra fitted feeder's upstream detail, but does not undo the completed all-slot post-map sharing proof. No RTL PoC, compilation, timing analysis, netlist regeneration or database repair occurred.

## 1. Verified provenance and baseline

HEAD **1b2a52d87d2659c908d4f9f846416d14bfd85bea**, branch **investigate/cram-memory-inference**, production **v19 /tag0x484313**, unchanged 96 KiB format. All **204 tracked raw hashes** and the retained seed1 input/evidence hashes were verified before database access. Final verification repeats those checks, including **135 normalized HEAD/input comparisons** among137 retained inputs. Two unused `.bak`/`.orig` inputs have no production Git blob.

Authoritative build: [savestate_g08_fm/quartus_early](../savestate_g08_fm/quartus_early/), Quartus Prime Lite **17.0.2 Build602**, Cyclone V **5CSEBA6U23I7**, SMS/sys_top, **SEED1**, **BUILD_DATE261025**, **MISTER_FB=1**. All original source, constraints, IP and performance/packing settings remain intact. The manifest's older HEAD label is not used in place of the verified v19 source contents.

| Official retained seed1 metric | Value |
| --- | ---: |
| Needed /placed ALMs |37,117 /38,599 |
| Mapped /fitted FF |46,327 /48,880 |
| Logic /routing ALUT |46,835 /18,266 |
| M10K |488 /553 |
| Setup /hold |+0.104 /+0.239 ns |
| Reported violating timing groups |0 |

Inherited unconstrained categories and warning limitations remain. No new STA or signoff claim is made. Read the requested [selector diagnosis](../sprite_cache_selector_netlist_diagnosis/review.md), [non-controller audit](../non_savestate_optimization_audit/review.md) and [structural audit](../structural_resource_audit/review.md). Their missing mapped connectivity motivated this task; their resource estimates are not substituted for atom evidence.

[provenance.json](provenance.json) retains the source/input ledger and1,001 pre-existing evidence hashes, including all624 authoritative db/incremental_db/output_files artifacts,288,117,631 bytes. The controller hash remains `e8de50db09447138fc661205fb9edd178d45e691819a056bad87631ef3d76557`. These original files were never tool working files.

## 2. Quartus 17.0.2 capability findings

All executable discovery and syntax probing used the installed **17.0.2** tools, not documentation for a newer release. Tool entry point was `C:/intelFPGA_lite/17.0/quartus/bin64/quartus_cdb.exe -t <script>`. No quartus_map, quartus_fit, quartus_asm, quartus_sta, flow compile, incremental compilation or netlist-writing command was executed.

| API /capability | Actual observation |
| --- | --- |
| `load_package atoms` | Available in quartus_cdb17.0.2 |
| `project_open SMS` | Opens compatible retained project/database; **no -force**. Public help warns -force can overwrite an incompatible DB, so it was not used |
| `read_atom_netlist -type map` | Reads existing post-map DB;94,972 atom nodes enumerated in the initial access probe |
| `read_atom_netlist -type cmp` | Reads existing post-fit DB without fitting or timing analysis |
| `get_atom_nodes`, `get_atom_node_info` | Unique integer atom ID, hierarchy-qualified name, cell type; fitted `location` available. Post-map location query correctly says placement is required; no placement was run |
| `get_atom_iports/oports`, `get_atom_port_info` | Pin IDs/types, source `(atom,output-port)` pair, fanout `(atom,input-port)` pairs, input inversion and logical constants |
| `get_atom_port_info ... -type oport -key lutmask` | **Correct mask interface**, returning raw hex masks for used combinational outputs. Node-level LUT_MASK guesses are unsupported in this version |
| Net identity | Stage-local source atom ID +output-port ID identifies each output net; no invented global wire-name ID |
| Map↔fit correspondence | Matched atom names and IDs for the observed common cut nodes, plus fitted pin/mask/location data. No general assumption of ID stability across stages |
| Source association | Hierarchy/signal names connect atoms to RTL structures. No per-cell HDL source-line debug export was established |
| Public atom command help | Commands exist, but public `help -cmd` does not document them; direct help options return no atom usage text |

Installed vendor examples under `quartus/common/tcl/apps/pmaff/pmadirect_ff_placer.tcl` explicitly use atoms-package pin traversal and `read_atom_netlist -type cmp`; internal EDA scripts also read atom netlists. These provided version-local examples, not authorization to run those scripts or their mutating placement operations. Only the recorded getters/read/unload/project-close operations were used.

`get_legal_info_keys -type` takes **property categories** such as string, bitvec, enum and atom_bits, not node/iport categories. This was discovered through runtime errors and inspection of strings in the installed `atm_ctcl.dll`. [capabilities.log](capabilities.log), [key_categories.log](key_categories.log) and [other_keys.log](other_keys.log) retain results. Legal category membership does **not** guarantee a flag is legal for every atom instance; the later assertion demonstrates that limitation.

No general netlist export was needed or invoked. TSV/JSON files here contain targeted query results from existing databases; no synthesis/fitted netlist was regenerated or written back.

## 3. Database isolation, bounds and tool diagnostics

[copy_manifest.json](copy_manifest.json) records each copied file, original hash and size. The first access context copied SMS.qpf/SMS.qsf and db/incremental_db only:611 files. That probe read the map DB but reported three missing project Tcl/QIP warnings. To remove the missing-include ambiguity, the remaining135 retained input files were copied byte-for-byte, bringing the isolated context to **746 files**. Source/configuration assignments were not edited. Subsequent normal queries opened with zero missing-include warnings.

The context is [inspection/](inspection/), wholly under this task's output directory. Its project-relative sources are copies, not links to authoritative files. All commands ran there or in this task directory. No `-force`, export_assignments, write_atom_netlist, set_atom_node_info, set_atom_port_info, SDC read/update or timing-netlist creation was used. Successful scripts call `unload_atom_netlist` and `project_close -dont_export_assignments`.

Extraction was bounded in two distinct steps:

1. [extract.tcl](extract.tcl): slots **0,7,8,31,32,63**, X/d3, all eight bits, both owners, including surviving duplicates in fit. Traverse D/ENA/SCLR and other non-clock inputs through LCELL_COMB to sequential FF/RAM boundaries. Cap5,000 visited nodes. This completed at **882 map /906 fit nodes**, with **192 map /207 fit target FFs**. Node types: map341 combinational+477 FF+64 RAM; fit341 combinational+501 FF+64 RAM. RAM outputs and FF Q are sequential cut boundaries, not omitted combinational logic.
2. [data_grid.tcl](data_grid.tcl): the six-slot result indicated sharing. To check that slots in between did not use replicated data selectors, inspect **all64 slots' final D driver and its immediate input connections**, without expanding every full cone. Separate caps2,400 FF roots and2,400 D drivers. Completed map**2,048 roots /2,048 drivers** and fit**2,207 matched FFs /2,180 exported D-pin rows /2,024 drivers**. These populations are views of the same design and are not summed as independent hardware.

All used combinational output ports in the six-slot extraction have a raw mask. The script also asked for masks on unused/non-combinational output ports; Quartus emitted **2,853 map /4,797 fit Warning38000** “No valid data of type lutmask found” messages for those requests. Empty masks are retained rather than replaced with guessed functions. These are query diagnostics, not new compilation critical warnings. The all-slot data-grid queries completed with **zero errors and zero warnings**.

Two setup probes were corrected within the new task directory: atom public-help syntax was initially uninformative, and one script was initially created in the isolated project rather than its parent, causing a script-not-found invocation. The script was moved within this new directory and the successful result retained. No authoritative file was involved.

### Optional metadata assertion and stop

After the successful connectivity extractions, [metadata.tcl](metadata.tcl) attempted additional atom mode/flag getters on a narrowed ID list. A broader metadata plan exceeded the script's5,000-ID planning bound **before any tool invocation**; it was narrowed to2,197 map /2,176 fit missing-name/comb-attribute IDs. This was metadata only, not additional cone expansion.

The same optional query was scheduled for both database views before its logs were inspected. Both aborted in `get_atom_node_info`:

```text
Internal Error: Sub-system: CDB_ATOM
File: /quartus/db/cdb_atom/cdb_atom_sys.cpp, Line: 7676
this->bit_is_legal(bit)
Stack: CDB_ATOM_NODE::test_bit -> CTCL_UTIL::process_atom_bit
```

[metadata_map.log](metadata_map.log) and [metadata_cmp.log](metadata_cmp.log) preserve both traces. Buffered metadata outputs are empty; no result from them is used. The stack identifies atom-bit applicability as the failure, but the exact key cannot be certified from the empty buffered output. Tcl `catch` cannot catch this native assertion. **No further Quartus calls, repair or retries followed.** The completed extraction outputs remained available for offline analysis.

[isolation_changes.json](isolation_changes.json) records the final file comparison: **all746 copied files unchanged**, none missing; the tool created only `inspection/cr_ie_info.json` inside the isolated context. Both crash logs are outside that context but inside this task directory. Original source and database hashes were independently verified afterward.

## 4. Exact extracted connectivity

[map_cones.tsv](map_cones.tsv), [cmp_cones.tsv](cmp_cones.tsv) and [connectivity.json](connectivity.json) preserve IDs, types, locations, input types/polarities/source-port pairs and output masks/fanout lists. [map_data_grid.tsv](map_data_grid.tsv), [cmp_data_grid.tsv](cmp_data_grid.tsv) and [data_grid.json](data_grid.json) contain the all-slot final-D inspection. Masks are unpadded raw API hex strings. Pin assignment can change during fitting, so raw masks at different stages must not be compared without their pin bindings.

The exact source truth tables remain in [previous diagnosis, section2](../sprite_cache_selector_netlist_diagnosis/review.md). In brief, normal X is VRAM−1 except legacy m2_flags[7] selecting−33; d3 is VRAM in Mode4 LOAD_3 and old m2_flags in legacy LOAD_1. Restore has priority over native enables; x257 clears enables but holds cache data, x496 holds caches; count selects a slot; sp64 selects ce_vdp versus accelerated ce_sp. These predicates were not rewritten.

### Primary X bit1, all64 slots

Post-map common node **57424**, `...vdp:vdp_inst|...vdp_spr_inst|spr_x~5`, LCELL_COMB, output0 COMBOUT, mask **082A082A082A082A**, fanout**64**:

| Input pin | Source `(atom,port)` | Source association |
| --- | --- | --- |
| DATAA |47187,0|controller z80_set, merged primary restore strobe |
| DATAB |57423,0|owner-common mode/offset selection logic; complete upstream cone retained |
| DATAC |9466,1|Add1~1 SUMOUT |
| DATAD |9467,1|Add4~1 SUMOUT |

Slot0 FF **5194** (`spr_x[0][1]`) receives D from terminal node **57425**, `spr_x~6`, mask**1F1F1F1F1F1F1F1F**. Its inputs are restore47187, saved bit1247 and common node57424 (see raw file for exact saved-bit ID; no same-data assumption across slots). Other slots have their **own** terminal restore mux and saved bit, but use that **same57424 output net**. The all-slot identity intersection proves this for all64 ordinary FFs, not just six representatives.

In fit,57424 retains its name and output net identity, at **MLABCELL_X21_Y51_N42**, fanout64. Its mask is **040404048C8C8C8C**, with pins permuted: DATAA57423, DATAB47187, DATAC9467:1, DATAF9466:1. A changed pin/mask representation is not additional normal-data replication.

### Primary d3 bit0, all64 slots

Post-map common node **60009**, `...spr_d3~0`, LCELL_COMB/output0, mask **2070207020702070**, fanout64:

| Input pin | Source `(atom,port)` | Source association |
| --- | --- | --- |
| DATAA |49983,0|mode_M4 |
| DATAB |57297,0|shared VRAM read-data bit0 mux output |
| DATAC |47187,0|merged primary restore strobe |
| DATAD |10358,0|m2_flags[0] |

Slot0 FF **5947** D is from **60010** (`spr_d3~1`), mask1F1F1F1F1F1F1F1F, with restore47187, its independent `sprite_snap[33]` at2560 and common data60009. Slot7 FF **17768** D is from **80823** (`spr_d3~376`), mask3737373737373737, with restore47187, **the same60009** and its own `sprite_snap[551]` at22328. Different masks reflect input arrangements; the common data node is not inferred from name similarity.

In fit,60009 is **MLABCELL_X25_Y42_N15**, output fanout64, mask**000C000CCC0CCC0C**, with DATAB47187, DATAC10358, DATAD49983, DATAF57297. This is an actual shared post-fit data node.

### Full32-bit cut summary across both owners

[normal_cut_summary.md](normal_cut_summary.md) and [normal_cut_summary.json](normal_cut_summary.json) enumerate every bit, map ID, mask/fanout, fitted location/mask, all64-slot coverage and fitted sink coverage. Each owner has:

- X bit0: **one common VRAM read bit** (primary57297, secondary57287), fanout280 post-map including consumers beyond X. Its inversion/restore choice is fused into the required per-slot terminal LUT; there is no64-copy standalone inversion network to extract.
- X bits1..7: **seven common data nodes**, each fanout64; primary57424/57557/57651/57789/57870/57957/58036, secondary57420/57554/57648/57786/57867/57954/58033.
- d3 bits0..7: **eight common data nodes**, each fanout64; primary60009/60071/60118/60160/60224/60318/60376/60472, secondary60005/60069/60116/60158/60222/60316/60374/60470.

Thus all **2,048 post-map X/d3 FF D inputs** have the expected owner/bit common source before their local restore function. All32 source-bit groups cover slots0..63. The30 nontrivial common selector nodes already have the physical structure the proposed shared-data architecture was intended to introduce.

### ENA, count decode and SCLR

The requested six-slot full cones also expose real local and shared control. For primary slot0 X, FF5168 has:

```text
D    <- (57298,0)  spr_x~0 : local saved-data/normal choice
SCLR <- (57299,0)  data_address[0]~1 : shared restore/default clear
ENA  <- (57302,0)  spr_x[0][0]~3 : selected-slot write/restore predicate
```

Node57302 takes restore47187, slot0 decoder57054 and common write control57301. Slot7's ENA80585 takes the same restore and57301 but decoder75963. Decoder57054 has six count-bit inputs9361..9366 and mask8000000000000000; decoder75963 uses those same inputs with mask0100000000000000. Their functions select different slots and cannot be merged as identical predicates. The complete control cone includes count's remaining state/qualification logic; this six-input partial decoder observation is not permission to alias full count64 to slot0.

X and d3 in slot0 share decoder57054. d3 ENA60012 additionally takes state6458, common control58162 and mode/state predicate60011. ENA grouping is shared within bytes; it is not one independent identical data-selection network per bit.

Shared SCLR57299 takes restore47187 and has_restart721, mask4444444444444444 post-map, fanout2,901. In fit it is **MLABCELL_X21_Y64_N51**, fanout3,440; pins/mask are permuted. Secondary equivalent57289 is also shared. This directly resolves why a generated `data_address[0]~1` name had thousands of loads: it is not thousands of private address-data selectors.

### Fitted feeder limitation

The fitted all-slot inspection contains2,207 FFs, reflecting159 extra named X/d3 FF nodes, and2,024 unique immediate D-driver atoms. Those totals are not independently removable cells. **2,179 of the2,180 exported fitted D-pin rows directly expose the same cut point through their final driver.** The script matched2,207 fitted FFs, but27 had no D-type pin in its enumeration, so it emitted no D row for them. Their other data/control pin behavior was not expanded in the all-slot grid; no constant-value or equivalence assumption is made for them. The requested six-slot extraction separately retains all enumerated non-clock inputs. One exported D path has an extra feeder:

```text
spr_d3[59][3], atom17428, FF_X28_Y45_N31
  D <- atom494540, spr_d3[59][3]~feeder, MLABCELL_X28_Y45_N30
       DATAF <- (80651,0), COMBOUT mask00000000FFFFFFFF
```

Atom80651's further input detail was not in the representative full cone or immediate-driver grid; no further query followed the optional metadata assertion. The common primary d3 bit3 node60160 remains present at **LABCELL_X31_Y43_N45**, fanout64. The feeder is not treated as a newly proved normal-data duplicate or silently bypassed in a Boolean proof. Full post-fit connectivity for this one bridge remains incomplete; **post-map all64-slot factoring is complete**.

## 5. Shared, repeated and slot-specific logic findings

| Class | Supported conclusion |
| --- | --- |
| A genuinely shared logic | Thirty nontrivial X/d3 common data nodes are demonstrated across all64 slots/owner in map; the same nodes survive in fit with fanout64 and locations. Native/restore control and byte/slot enables are also factored |
| B identical duplicated normal-data networks | **No64-way redundant data-selector network demonstrated.** Remaining per-slot D selectors differ in saved-data inputs. Small arithmetic prefix mask/signature matches exist, but are not a material per-slot network |
| C necessary slot-specific logic | Independent saved X/d3 bits, count==slot, local D/ENA receiving functions and stored Q differ across slots. Merging those functions would change restore or indexed updates |
| D physical replication |207 versus192 representative fit/map roots and2,207 versus2,048 all-slot fit/map roots expose physical FF duplicates. Fitted pin permutations, changed masks, merged drivers and the explicit feeder are implementation changes, not proof of functional redundancy |

The byte-level same-edge data/predicate architecture is therefore **already present in the important sense**: normal arithmetic/byte choice is upstream of local saved-data selection and slot qualification. Writing that structure explicitly in RTL might change synthesis heuristics or routing, but would not remove64 independent copies of an existing normal-data selector. It could also force more fanout or disturb the fitter's local packing.

### Small arithmetic matches, with a strict qualification

[classification.json](classification.json) includes `matchingPinMaskSignaturesNotEquivalenceProof`:18 post-map and10 post-fit output groups. A recursive signature uses output type/mask, typed input bindings/polarities/constants and sequential cut identities. Every match is in **Add1/Add4 carry-chain prefixes**, not in a64-slot normal-selector array. SUMOUT and COUT groups can refer to the same cells, so output-group counts are not cell counts or ALUT savings.

For example secondary12047 `Add1~30` and12048 `Add4~30` each have DATAD57287 and inverted logical-ground CIN; each COUT reports maskFF, but feeds a different arithmetic chain. Primary equivalents12052/12053 use57297. Source−1 and−33 arithmetic has common low-bit behavior, so small repeated prefixes are unsurprising. However, arithmetic-mode flags affect interpretation and carry-chain implementation. The optional applicability query asserted before a usable mode export completed. **Raw equal masks/signatures are not promoted to a complete arithmetic-equivalence or safe-removal proof.** In particular SUMOUT/COUT maskFF is not treated as an ordinary constant-output LUT equation.

No per-slot identical normal-data LUT is found by that signature comparison. The comparison is deliberately not claimed exhaustive under every Boolean rewriting, pin permutation, arithmetic mode or FF-clone equivalence. The positive same-node sharing evidence does not require such a minimization proof.

## 6. Resource and routing implications

The verified current structure has **one shared normal-data node per nontrivial owner/field/bit**, not64. The30-node count is a connectivity count, not isolated ALM allocation. Its producer arithmetic, mode predicates and VRAM read muxes are common too, with full relevant fanin recorded for the six-slot cut. The2,048 mapped terminal D-driver cells are not another2,048 redundant normal-data cells: they combine independently restored data with common normal results. Removing them would require a different restore/FF architecture, outside this hypothesis and its correctness contract.

Consequently **demonstrated removable cells for the proposed64-copy normal-selector mechanism: zero**. This does not prove a globally minimal implementation or preclude every different algebraic fusion. No exact placed-ALM saving or new M10K trade is claimed. Even the small arithmetic-prefix candidates would require mode/carry correctness and placement proof; their bounded scalar scale is not a credible material-area justification for this PoC.

Fanout is already material: each shared selector drives64 terminal logic inputs; common raw VRAM bits have280 map consumers, and common clear has thousands of mapped/fitted sinks. A more globally forced shared-data topology would largely recreate these nets or increase their delivery burden. The fit already permutes pins/masks and inserts a feeder. No source change, logic-suppression assignment or buffering experiment was performed.

Existing timing exposure remains the retained v19 evidence, not a new query: ce_vdp→primary d3 slot6 ENA has+1.698 ns at a9.313 ns relationship; worst hold is adjacent shifter state+0.239 ns; global HDMI setup+0.104 ns. These are different cones and must not be substituted for a full new candidate D-path signoff. The current normal-data sharing passes the retained build; increasing or reorganizing its fanout has unknown whole-design packing/routing consequences.

This mechanism differs from the rejected v16 controller common-mux extraction in **source location**, but the intended native sharing is already realized. Neither its+47 placed result nor the failed packed sprite-RAM experiments justify another native factoring variant. The prior feasibility STOP on local RAM/reset authority is unchanged. No format, state, System E support, same-edge cache behavior or native release contract is relaxed.

## 7. Decision and exactly one recommended next action

**NO-GO for one native X/d3 shared-data factoring PoC. Recommended action: STOP this optimization line after this report.**

The previously missing post-map evidence now resolves the main question: normal-data expressions are already shared across all64 slots; required local restore/count logic explains the remaining repetition. No specific material redundant per-slot combinational network is demonstrated. The optional metadata failure and one fitted feeder limit stronger arithmetic/minimality claims, so no broader claim that all sprite logic is optimal is made.

No fallback arithmetic rewrite, further API probing, database repair, synthesis, timing analysis or seed experiment is recommended or started here. Await review. The native assertion is documented rather than bypassed by a repair or compilation attempt.

## 8. Final source/database verification and Git status

[verification.json](verification.json) verifies unchanged HEAD/branch/index,204 tracked hashes,137 retained input hashes,135 normalized HEAD matches and all1,001 authoritative/pre-existing evidence hashes. It also records the new report/query artifact hashes. [isolation_changes.json](isolation_changes.json) verifies every copied file unchanged and identifies the sole tool-created inspection file. Existing untracked reports/builds were preserved in place.

Final `git diff --stat`:

```text
(empty)
```

Final `git status --short`:

```text
?? tests/
```

All new outputs are under `tests/sprite_cache_netlist_connectivity/`. No production RTL/candidate, QSF/SDC/QIP/IP or format changes; no netlist regeneration, synthesis, fit, route, assembly, timing analysis, branch change, checkout, reset, clean, commit, push, merge or PR. **NO-GO; stopped after the report.**
