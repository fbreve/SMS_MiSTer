# Synthesis structure audit — production baseline 8443a0d

Audit date: 2026-10-29 (America/Sao_Paulo). Repository: fbreve/SMS_MiSTer. Investigation branch: `investigate/synthesis-structure`, created at `8443a0d19a88aff7a5900011bccf386daf146945`.

## Decision and evidence boundaries

The strongest verified experiment targets are four small OPLL/FM RAM-like banks explicitly forced into logic. Quartus identifies the exact inference blocker; their single-clock, sequential initialization and registered reads make a bounded inference experiment reasonable. Whether removing the attribute preserves all semantics and improves whole-design implementation is **unverified**. No production change is recommended without that experiment.

CRAM is also implemented in registers, but its 384-bit simultaneous snapshot interface explains that result. CPU registers, live sprite state, cheat codes and controller snapshots likewise have access requirements that ordinary RAM cannot replace directly. No unexplained large RAM inference failure was established. No concrete unintended arithmetic unit, inferred latch or combinational-loop warning was found in the reviewed baseline reports. This is a report/source audit, not an exhaustive graph proof that feedback cannot exist.

No RTL, QSF, SDC, QIP, production initialization file or existing audit artifact was edited. No compilation, simulation, PR, merge, push or commit was performed. The installed Quartus executable was run only with `--version`. Existing reports and fitted memory mappings were reused without opening or changing their compilation databases. All new files are under this directory.

## 1. Baseline, tool and reuse qualification

Initial worktree: clean tracked files, untracked `tests/`, branch `investigate/cram-memory-inference` at `1b2a52d87d2659c908d4f9f846416d14bfd85bea`. The requested branch was created at the specified baseline. The Git metadata sandbox initially denied the switch; the authorized escalation succeeded. Neither protected branch ref moved.

Installed tool, independently executed: `C:/intelFPGA_lite/17.0/quartus/bin64/quartus_sh.exe --version` → **17.0.2 Build 602, Lite Edition**. Retained build: [timing-history F](../timing_history/builds/F/), including original `db`, `incremental_db`, map, fit and STA reports. Device **5CSEBA6U23I7**, revision SMS, top `sys_top`, seed 1. Settings: STANDARD FIT, HIGH PERFORMANCE EFFORT, SPEED, final placement ALWAYS, ALM register packing LOW, automatic packing NORMAL, `MISTER_FB=1`; original IP and timing constraints retained. Physical optimization/duplication is enabled; fitted resource attribution includes those transformations.

[provenance.json](provenance.json) independently compares **134 tracked retained build inputs** with both Git baseline blobs and the current worktree, normalizing CRLF/LF only for comparison: **zero mismatches**. This input domain comes from the earlier production provenance audit; it is not a new exhaustive transitive dependency discovery. Raw SHA256s and original report hashes are recorded. Timing-history F's original build date is 261014; do not regenerate a current date and call that a matched baseline. The HCounter retained baseline independently supplies identical measured endpoints with a different build date, as documented in [current production cost](../current_savestate_resource_cost/review.md).

| Baseline metric | Recorded value |
| --- | ---: |
| ALMs needed / placed | 26,465 / 31,531 |
| Device ALM capacity | 41,910 |
| Synthesis / fitted registers | 34,857 / 35,709 |
| Fitted combinational / routing ALUTs | 37,056 / 13,159 |
| M10Ks / capacity | 487 / 553 |
| MLAB memory bits / ALMs used as memory | 0 / 0 |
| Logical/configured bits / allocated M10K capacity bits | 3,809,858 / 4,986,880 |
| DSP blocks / capacity | 39 / 112 |
| Worst reported setup / hold slack | +0.508 / +0.144 ns |
| Setup / hold TNS | 0 / 0 ns in all reported summary clock groups |

Sources: [fit summary](../timing_history/builds/F/output_files/SMS.fit.summary), [fit report](../timing_history/builds/F/output_files/SMS.fit.rpt), [map report](../timing_history/builds/F/output_files/SMS.map.rpt), [STA summary](../timing_history/builds/F/output_files/SMS.sta.summary), [historical metrics](../timing_history/metrics.csv). Extracts: [settings](settings.json), [timing summary](timing_summary.json), [hierarchy](hierarchy.json). Fractional fitted hierarchy ALMs are allocations, not removable independent sites. Parent totals include descendants; do not sum them with children.

There are **66 nominally free M10Ks**, not 66 blocks guaranteed available at any location/port configuration. [baseline_metrics.json](baseline_metrics.json) independently sums the fitted RAM rows to487 M10Ks, zero MLAB cells and3,809,858 configured bits. Allocated physical capacity is487×10,240=4,986,880 bits; it includes unused width/depth and is not additional payload. Small banks waste capacity in M10K; MLAB may be a better area/placement tradeoff but consumes ALMs and must support the precise clock/read semantics. `MLABCELL_X...` location names in a report do not prove MLAB RAM use: the actual fitted memory totals are zero. Positive summary slack does not resolve inherited unconstrained setup/hold categories or critical warnings.

### Previous investigations reviewed

- Timing-history metrics, checkpoints, paths and original F map/fit/STA reports were reused. `tests/timing_history/review.md` is absent. `savestate_area_investigation` retains a DDRAM exported netlist but no prose report; it was not assumed source-matched or used for gate attribution.
- [Current production savestate cost](../current_savestate_resource_cost/review.md) establishes the applicable controller allocation and distributed-state limitations. [Resource growth](../savestate_resource_growth/review.md), [structural audit](../structural_resource_audit/review.md), and [consolidation](../fpga_resource_optimization_summary/review.md) distinguish production baseline from later v19.
- [PSG resource investigation](../../output_files/psg_resource_review/report.md) and retained raw-PSG reports describe prior codec/state experiments. Those historical deltas are not new baseline measurements. The dedicated reset/PSG fanout prose report was not found in the retained tree. The `optimize/reset-psg-fanout` branch currently points at the same `8443a0d` baseline, not a distinct retained optimization result. This audit reuses baseline fanout/path evidence and does not repeat a reset/PSG rewrite.
- Later CRAM and CPU alias trials in the consolidation are negative experimental context. They used different RTL and cannot establish an A/B result for this baseline. In particular v19's two 4,800-bit sprite snapshot rings and OPLL scratch M10K **do not exist in this controller**.

## 2. Memory inventory and implementation

[declarations.json](declarations.json) records 86 array/memory-attribute declaration matches across tracked HDL, including framework sources and unused library definitions. It is a search inventory, not a count of instantiated RAMs. [report_sections.json](report_sections.json) contains original synthesis RAM/DSP and fitter RAM/fanout sections with report line numbers. [fitted_ram.json](fitted_ram.json) preserves physical memory modes, actual block counts, locations and read-during-write fields. These fitted mappings provide implementation evidence; no new technology-map GUI or atom-connectivity query was performed.

| Storage / RTL location | Semantics, size and verified implementation | Assessment |
| --- | --- | --- |
| WRAM `SMS.sv`, `ram_inst`; `rtl/spram.vhd` | Single addressed port, 16,384×8 = 131,072 bits; synthesis RAM row, fitted M10K | Already hard RAM; CPU/restore arbitration is outside the bank |
| Cartridge SRAM/NVRAM `SMS.sv`, `nvram_inst`; `rtl/dpram.vhd` | True dual port, 32,768×8 = 262,144 bits, initialized `nvram_ff.mif`; fitted M10K | Sega/other mapper SRAM share this physical store; do not count logical mapper windows as separate arrays |
| EEPROM `rtl/cart_eeprom.vhd:33`, `:58`; `rtl/eeprom_93c46.vhd` | Serial protocol and shift/control state; 7-bit byte NVRAM address accesses existing NVRAM | No missing local EEPROM payload RAM; protocol shift registers are justified |
| VRAM `rtl/vdp.vhd`, `vdp_vram_inst`, both VDPs | Each true dual port 32,768×8 = 262,144 bits; fitted M10K | Already inferred/instantiated; bank ownership and simultaneous accesses matter |
| CRAM `rtl/vdp_cram.vhd:25–26` | Each 32×12 = 384 bits; clocked display read plus all-entry combinational snapshot, priority restore/CPU write | FFs expected for current interface; two modules 738.5 placed ALMs / 795 fitted FF / 0 M10K |
| T80 `rtl/T80/T80_Reg.vhd:100–102` | Two 8×8 banks = 128 bits; three asynchronous indexed read pairs, full parallel DOR, full parallel DIR restore | 207.5 placed ALMs / 139 fitted FF / 0 M10K; not ordinary RAM semantics |
| VDP sprite evaluator `rtl/vdp_sprites.vhd:53–63` | Per-slot enable/X/four byte planes; every slot feeds its own concurrent pixel shifter/selection | Native parallel state, not an address-only store. Own allocation 1,953.0 + 1,890.0 ALMs; shifter descendants excluded |
| Sprite shifters `rtl/vdp_sprite_shifter.vhd`; background `rtl/vdp_background.vhd` | Simultaneous shifts, plane loads, per-slot heads, pipeline histories | Register pipelines justified; register count alone is not inference-failure evidence |
| Savestates `rtl/savestates.sv` | CPU230, VDP256, palettes768, PSG112+192 and other snapshots; 1,852 declared snapshot bits plus separate restore/transport/control state | Controller 4,319.8 placed ALMs / 3,808 fitted FF / 0 M10K; full parallel capture and differing lifetimes prevent attribute-only conversion |
| Mapper `rtl/mapper_ctrl.vhd`, `rtl/mapper_detect.vhd`, Evolution modules | Banking/control registers, constant signature arrays, CRC and indexed selectors | No large writable payload memory found outside existing WRAM/NVRAM/ROM. Const signature syntax does not imply a missing RAM |
| FM VoiceMemory `rtl/VM2413/voicememory.vhd:54` | 38×36 = 1,368 logical bits, two independent clocked reads; two physical copies, 2,736 reported bits / 2 M10Ks | Valid replication for read-port demand; not two independent logical payloads |
| FM EnvelopeMemory `rtl/VM2413/envelopememory.vhd:50` | 18×25 = 450 bits; sequential startup writes, clocked read | Already 1 M10K; 17.2 placed ALMs / 7 fitted FF are surrounding control |
| FM Phase/Feedback/Output/Register memories | Four explicit `ramstyle="logic"` banks, detailed below | Verified suppressed inference; experiment candidates |
| FM ROMs/cache `attacktable`, `lineartable`, `sinetable`, `voicerom`, `controller` | Constant tables, per-channel instrument cache and lookup constants | May become Boolean lookup logic or be folded into consumers; no unexpected large mutable RAM failure established |
| Cheat codes `rtl/cheatcodes.sv:34` | 32×34 = 1,088 bits; all enabled entries compare concurrently with priority override | Parallel associative storage, not an ordinary addressed RAM |
| Keyboard `rtl/keyboard.sv:13`; `rtl/parts.v` library arrays | Small key-row state; multiple generic RAM modules present in library | Inspect instantiated report rows, not library declaration totals; unused module definitions do not consume resources |
| BIOS/decryption | SMS BIOS262,144×8, GG BIOS16,384×8, boot ROM16,384×8, key8,192×8; decryption tables128×5 /128×8 | Hard memories listed in synthesis and fitted RAM reports |
| Framework scaler/OSD/gamma/HQ2x/shadowmask/delay stores | Scaler lines2048×24, burst32×128, coefficients256×40, OSD4096×8 each, gamma768×8, HQ2x300×24/600×96 and small delays | Existing hard-memory implementation; source pipeline arrays with multiple taps are not automatically RAM candidates |

Byte enables, clock modes, output-register placement and read-during-write modes must be taken from each fitted RAM row. No global assertion that every declaration should map to M10K is made. EEPROM/mapper semantics are particularly easy to miscount because they expose addresses into shared storage rather than private arrays.

## 3. Ranked experiment candidates

### 1. FM banks explicitly forced to logic — strongest bounded experiment

The original map report at **13048–13052**, retained in [ram_diagnostics.json](ram_diagnostics.json), says `Found 4 instances of uninferred RAM logic`, and identifies each as uninferred because `"logic"` is set as its `ramstyle` attribute. This is direct tool evidence, not an inference from source names.

| Signal / exact source | Declared bits | Placed / needed ALMs | Fitted FF | Confidence |
| --- | ---: | ---: | ---: | --- |
| `phase_array`, `rtl/VM2413/phasememory.vhd:50`, attribute:52 | 18×18 = 324 | 235.0 / 123.6 | 349 | High: explicit blocker |
| `regs_array`, `rtl/VM2413/registermemory.vhd:54`, attribute:56 | 9×24 = 216 | 155.3 / 91.7 | 224 | High: explicit blocker |
| `data_array`, `rtl/VM2413/feedbackmemory.vhd:55`, attribute:57 | 9×10 = 90 | 75.7 / 51.7 | 106 | High: explicit blocker |
| `data_array`, `rtl/VM2413/outputmemory.vhd:51`, attribute:53 | 19×10 = 190 declared | 179.8 / 135.8 | 218 | High blocker; lower mapping simplicity |
| **Disjoint module totals** | **820 declared** | **645.8 / 402.8** | **897** | Whole-module envelope only |

Fit report rows: 8095, 8098, 8100, 8107. FF counts include output/control/physical effects; they are not exact payload costs. OutputMemory declares indices0..18 but startup initializes only0..17; do not silently change the last entry or assume an invalid address is unreachable. `PHASE_TYPE` is18 bits and `SIGNED_LI_VECTOR_TYPE` is10 bits in `rtl/VM2413/vm2413.vhd:91–99`.

These banks do **not** asynchronously clear all payload entries on reset. Reset initializes a sequencer; subsequent clocks write entries one by one. Reads occur within the same clocked process. Normal same-address read/write uses the pre-write signal value (old data); during reset the output holds. Phase/Register have a shared logical address; Feedback has independent read/write addresses. OutputMemory has two read addresses plus a write, so replication/true-dual-port restrictions and read-during-write behavior must be checked rather than promising one block.

Minimal experiment, only after approval: separate isolated source copies, one bank at a time, remove only the `logic` attribute and record Quartus's selected mapping. Start PhaseMemory, then RegisterMemory; Feedback's smaller cost makes it a lower-value follow-up; OutputMemory last because of its ports. If AUTO does not infer, inspect the resulting diagnostic before trying an explicit M10K/MLAB attribute or changed coding template. Do not change latency, initialization order, reset behavior or interfaces merely to obtain an inference message.

Expected benefit: potentially replace part of ~646 allocated ALMs with a few memory blocks. **Actual ALM delta, number of blocks and timing benefit are unknown.** MLAB can be worth comparing for these shallow banks; do not assume it preserves the same registered read/reset contract. The already-inferred EnvelopeMemory is a useful nearby reference, not proof all other ports map identically.

Functional risks: startup reads before initialization completes, repeated/reset interruption, write suppression during initialization, old-data collisions, output hold during reset, address18/uninitialized behavior, audio pipeline alignment and freeze/enable behavior. Current baseline savestate support differs from later v19; do not import v19 scratch/scan assumptions or silently change historical FM resume behavior.

Required validation: cycle-by-cycle bank equivalence with reset asserted between/on clocks, reset during initialization, every legal address, simultaneous reads/writes and address collisions, initialization-boundary writes and repeated reset. Preserve unknown/uninitialized semantics deliberately rather than zeroing them to make comparison pass. Then native FM audio traces over all slots/instruments/rhythm, System E/audio-mode transitions, save/load/freeze sequences and first resumed samples. Finally run the matched Quartus comparison described below. Confidence in inference cause **high**; confidence in equivalent hard-memory mapping **medium**; confidence in net whole-design saving **unmeasured**.

### 2. CRAM snapshot interface — architectural candidate, not a template bug

Exact signals: `ram`, `rtl/vdp_cram.vhd:26`; simultaneous snapshot `ss_D`, generated at:47–50; display read process:53–60. Two banks hold768 payload bits. Fit rows8140/8215 show370.5/368.0 placed ALMs,399/396 FF, zero M10K. Root cause confidence **high**: all32 entries are continuously visible, beyond block-RAM read-port capacity. Restore/CPU writes already have one writer with explicit priority, so multiple independent writers are not the principal blocker. Initialization alone is not evidence that RAM inference must fail.

Minimal distinct future experiment: design an addressed frozen snapshot reader with an explicit old-data/latency contract and use the existing write arbitration, then compare the complete controller+CRAM implementation. This requires interface and capture sequencing changes, not just a RAM attribute. Preserve 32-entry order, GG12-bit palette, SMS/TMS behavior, display read latency, writes on freeze boundaries, reset interruption and both System E owners. Keep the historical save format unchanged or explicitly define compatibility requirements before implementation.

Expected benefit unknown; the738.5-ALM module envelope is not recoverable saving. Later [CRAM investigation](../cram_memory_inference/review.md) on v19 inferred four replicas and reduced local allocation but increased whole-design placement by121 ALMs and routing ALUTs by997. That does not predict this baseline's delta, but rejects the assumption that hard RAM necessarily improves the core. Risk and validation cost **high**. Lower priority than FM; do not repeat the prior design unchanged. Required simulation includes palette read/write collisions, exact snapshot boundary, normal rendering and interrupted/legacy/current save-load; required fit comparison includes controller and global routing changes.

### Not recommended as RAM conversions

T80's parallel128-bit restore/read and three asynchronous addressed read ports, cheat-code parallel matching, live sprite per-slot outputs, shifters and controller full-width capture are justified register structures under their existing interfaces. Their conversion would require scheduling/state/interface redesign with substantial compatibility risk. No minimal attribute-only experiment is justified. Controller's4,319.8 ALMs are a concentration, not proof of failed inference or incremental savestate cost. See the source-matched production-cost report for the1,852-bit snapshot inventory and separate restore-data lifetimes.

## 4. Arithmetic and width propagation

[arithmetic_scan.json](arithmetic_scan.json) contains582 search matches across tracked HDL for multiplication/division/remainder and signed/unsigned conversions. This is triage, including casts and benign constants, not582 expensive arithmetic units. Map DSP summary:39 physical blocks; configurations3 independent9×9,6 two-independent18×18,1 independent18×18-plus36,22 sum-of-two18×18,7 independent27×27. Signed/unsigned/mixed multiplier counts describe logical operators, not additional DSP blocks.

Source checks and retained synthesis/fitter hierarchy support these conclusions:

- `rtl/savestates.sv:196` and:205 multiply a two-bit slot by constant`29'h3000`. This is a bounded constant shift/add address expression, not evidence of a general29×29 multiplier. There is no isolated residual arithmetic-cone cost in the retained reports; no rewrite is recommended on textual grounds.
- `rtl/vdp_background.vhd:152–175` declares integer temporaries but derives `text_row` from five source bits and multiplies by40, ultimately selecting10 address bits. Quartus may narrow/factor this. Two complete background modules occupy155.4/147.8 placed ALMs, including rendering state and control; no evidence isolates an oversized retained32-bit multiplier or divider. Narrowing the source type alone has no demonstrated benefit. The later mod6/div6 restore helper mentioned in v19 reports is absent here.
- Framework `sys/math.sv:3` implements `sys_udiv`;:85 implements `sys_umuldiv`; `sys/sys_top.v:880` uses12/12/12 parameters and `sys/video_freak.sv:165` uses24/12 division. These are intentional arithmetic for video sizing/aspect ratio, not accidentally inferred combinational `/` units. Iterative arithmetic cannot be removed based on operator names.
- Scaler/audio interpolation and gain arithmetic have genuine concurrent throughput/precision requirements. Existing mapped DSP use is evidence of implementation, not proof of redundant multipliers. Runtime-exclusive output modes do not establish that their pipelines can share arithmetic without retaining histories and latency.

No concrete unnecessary multiplier/divider, signed conversion or oversized residual adder/comparator was verified. In particular no report-derived width/cone evidence establishes an arithmetic change worth implementing. A future width proposal must first identify mapped operands and surviving upper bits, prove bounds for every supported mode, and show Quartus has not already narrowed/shared the logic. It would then require combinational equivalence (including overflow/rounding/saturation), full pixel/audio trace checks and matched implementation. No speculative arithmetic saving is claimed.

## 5. Fanout, feedback and actual timing

Fitter's [non-global fanout section](../timing_history/builds/F/output_files/SMS.fit.rpt) starts at11201. Highest entries:

| Fitted net | Fanout | Interpretation |
| --- | ---: | --- |
| `savestates_inst|z80_set` | 4,812 | Restore control and synthesis-shared control distribution; source output at`rtl/savestates.sv:48`, asserted:1862 |
| `savestates_inst|vdp2_regs_set` | 4,511 | VDP2 restore distribution; output:139, asserted:1883 |
| `psg_inst|clr_noise~0` | 2,401 | Generated PSG/reset/control cone; generated name alone does not prove a literal one-to-one source net |
| primary / secondary VDP `mode_M4` | 1,265 /1,264 | Intentional mode distribution across64 sprite children per owner |

Source `SMS.sv:416` combines external/reset/download/BIOS/loading/eject conditions into `raw_reset`; `bios_config_reset` is registered at:402. These are broad intentional controls. Factoring or duplicating them can change routing and fitted duplication. Their fanout is evidence for investigation, not a demonstrated timing or ALM defect. Do not globally suppress fitter duplication or add reset pipelines without proving cycle behavior.

Actual baseline worst setup is **scaler line-store write-enable register → `ascal|o_vpix_inner[0].r[7]`**, +0.508ns; worst hold is **`ascal|o_poly_phase_b.t3[4]` → `ascal|o_poly_phase_b2.t3[4]`**, +0.144ns. Both are HDMI PLL paths in the retained detailed reports. They are not the v19 shadowmask/OSD limit or sprite hold limit. Global fanout includes clock distribution (maximum28,709); highest non-global4,812 is the relevant separate figure. Neither the FM banks nor the listed reset/restore controls are these worst endpoints. This does not prove they have no local timing cost.

[messages.json](messages.json) collects70 report warning/error occurrences, not70 distinct warning classes. Reviewed map/fit/STA messages show no inferred-latch or combinational-loop diagnostic. Incomplete-case warnings require examining defaults; they are not automatically latches. Inherited PLL connectivity/assignment/unconstrained categories remain. No exhaustive SCC/latch-cell netlist walk was run, so the verified statement is absence of such reported warnings, not an unconditional graph-level guarantee. No feedback/fanout implementation experiment is recommended without a new endpoint/cone correlation. Repeating reset/PSG work without new evidence is not justified.

## 6. Required A/B procedure after separate implementation approval

1. Use isolated copies of this exact baseline, Quartus17.0.2 Build602,5CSEBA6U23I7, SMS/sys_top, identical IP/QIP/SDC/QSF, seed1 and fixed original BUILD_DATE. Preserve the complete input manifest. Fresh source-only A and B databases avoid stale/incremental effects. Retained F is a reference; the new A must reproduce or explain differences before B is interpreted.
2. Make one bank/semantic change per pair. First demonstrate bank/native simulation equivalence, then inspect map RAM diagnostics and fitted memory port/clock/read-during-write configuration. Report replication explicitly.
3. Complete full fitter and STA. Record needed/placed ALMs, mapped/fitted FF, logic/routing ALUTs, M10K/MLAB/DSP, packing, routing utilization, warnings, setup/hold slack and TNS per clock and the changed cones. Include controller/scaler/global allocation changes rather than reporting only the optimized module.
4. Reject loss of function, save compatibility, timing coverage or implementation success. A second matched seed is useful only after the first pair demonstrates a credible saving and functional correctness; do not compare arbitrary seeds or claim improvement from local synthesis alone.

## 7. Reproduction, limitations and final repository state

Run `node tests/synthesis_structure/collect.js` from repository root with Node and the recorded Quartus path available. It reads tracked HDL, Git objects and retained reports; it writes JSON only under this directory. [provenance.json](provenance.json) records source/report hashes, tool output and branch refs. [ram_diagnostics.json](ram_diagnostics.json), [fitted_ram.json](fitted_ram.json), [report_sections.json](report_sections.json), [hierarchy.json](hierarchy.json), [settings.json](settings.json) and [timing_summary.json](timing_summary.json) support the measurements. The collector inventories selected input/report domains; it does not simulate, compile or query an atom graph.

Verified findings: four intentionally suppressed FM RAM inferences totaling820 declared bits and645.8 placed module ALMs; CRAM's parallel interface explains its register storage; major CPU/video payload RAMs already map to hard memory; zero fitted MLAB memory; known high-fanout controls are separate from the measured global timing limits. Unverified hypotheses: equivalent and beneficial hard-memory mapping for the four FM banks, and net benefit from an altered CRAM snapshot interface. No arithmetic/feedback optimization is evidence-qualified.

Recommended first approval scope is **PhaseMemory-only semantics/equivalence and matched Quartus A/B**, followed by RegisterMemory if useful. No production RTL has been modified and no improvement is claimed.

Final branch HEAD remains8443a0d. `master` remains8443a0d; `investigate/cram-memory-inference` remains1b2a52d. Tracked diff is empty. Existing untracked artifacts remain in place; new audit artifacts are untracked under`tests/synthesis_structure`. No new Quartus database was generated or staged. Local ignore rules exclude future database directories. Work stops here pending approval for any RTL experiment.
