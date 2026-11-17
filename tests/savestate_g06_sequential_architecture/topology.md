# Architecture and attribution evidence

Production reference: committed F01/v17 at `7fcd5e12847eedf9e97a44dc937c3dbac3205f7c`. All experimental source changes are under `candidate_A/`.

## F01 principles, and what was not copied

The OPLL port is 32 data bits, 8 address bits, read/write strobes, and a one-edge registered response. Constant local address comparisons expose registers and the already-existing VoiceMemory/EnvelopeMemory arrays. Writes update only the selected field/row; the whole internal state is not multiplexed into one dynamic flattened vector. A `256x32` synchronous scratch uses one M10K. The engine captures/installs a bounded sequence while guest enables are held. DDR64 access reads/writes pairs of scratch rows. Decode remains beside its owner; the top routes an address, narrow data and a few enables. Muxing remains in the local word response, selected array row and ordinary per-register update choices; it is not absent.

OPLL initializer gating, memory cache refill and delayed operator/phase counters are algorithm-specific. Their causal proof is not transferable to sprites. The measured F01 placement change 39,001 to 38,598 (-403) is evidence that this pattern can fit efficiently, not a prediction of sprite savings. Its RTL, scratch, ordering and v17 representation are unchanged here. The retained isolation oracle additionally compares raw OPLL/PSG state and audio for SAVE and three LOADs, with the fixture's existing FM-output suppression; it does not claim G08.FM closure.

## Production sprite path

Each VDP exposes 4,778 bits continuously: 64 slots x 74 bits, 28 fixed sprite-parent bits and 14 collision-delay bits. The savestate controller holds **two 4,800-bit registers**, including 22 zero padding bits per owner. ARM captures the full post-T vectors. SAVE emits the low64 bits of the selected bank and rotates that bank by64 for each of75 words; after75 rotations the bank returns to its original order. LOAD shifts each received DDR64 word into the corresponding bank. `sprite_valid=has_restart` selects the v14-and-later record versus legacy defaults. Both restore buses fan back through `system`, `vdp`, `vdp_main` and sprite children. The original `ss_regs_set` simultaneously installs sprite arrays/shifters, registers and collision delay and normalizes the evaluator.

Thus **the external DDR path was already 64-bit sequential**. The architectural target is the wide internal snapshot/restore storage and update muxes, not an imaginary parallel external transfer. The ring already avoids an arbitrary 4,800-to64 indexed read crossbar. Its cost remains the 9,600 scratch FF and capture/hold/rotate/insert/zero choices plus local parallel restore choices. The previous mux-only rewrite left that architectural cost and increased placement by47 ALMs; it is not repeated.

Production control fans out as follows: ARM capture to9,600 shadow bits; ring update to4,800 bits of the selected owner; architectural restore and validity/default choice to the local live fields; guest freeze to domain enables and raw overflow bookkeeping. Version decode originates centrally in `has_restart`, but its selected record/default consequence reaches many receiver registers. Wires themselves are not counted as FF. A compiler may prune constant padding and replicate/combine control logic; source fanout is not a physical fanout count. Measured high-fanout report rows and controller hierarchy estimates are retained in build metrics. They cannot establish an additive area attribution.

## G06 exact inventory

`inventory.json` lists all17 field groups with owning module, width, count, total bits, old capture/restore/mux/freeze/version representation, first consumer and reason. `map` enumerates every local row and external half-word. Slot fields use stride74:

| Field | Width x count per VDP | Total | Offset within slot / fixed absolute offset | First future consumer |
|---|---:|---:|---|---|
| enable | 1 x64 | 64 | slot+0 | registered color/collision reduction |
| spr_x | 8 x64 | 512 | slot+1 | load comparator |
| spr_d0..3 | each8 x64 | 2,048 | slot+9,17,25,33 | shifter reload / legacy color interpretation |
| shift0..3 | each8 x64 | 2,048 | slot+41,49,57,65 | next and later enabled pixels |
| wideclock | 1 x64 | 64 | slot+73 | half-rate width advancement |
| data_address | 14 x1 | 14 | 4,736 | evaluator VRAM address |
| m2_flags | 8 x1 | 8 | 4,750 | legacy offset / color load |
| color_reg | 4 x1 | 4 | 4,758 | pixel composition |
| collide_reg | 1 x1 | 1 | 4,762 | delayed collision source |
| overflow_reg | 1 x1 | 1 | 4,763 | VDP status bookkeeping |
| xspr_collide_shift | 14 x1 | 14 | 4,764 | collision flag / IRQ timing |
| **Total** | | **4,778** | | |

All these fields are historical; none is reconstructed or removed. Across two VDPs:9,556 meaningful bits and44 external padding bits. Evaluator state is a3-bit FSM, count0..64 (7 bits) and6-bit index:16 existing live bits per VDP. The established boundary contract does not serialize these; the original restore strobe normalizes WAITING/count0/index0. Their live declarations and normalization remain. This experiment does not broaden the original boundary proof.

## G10 and shared controls

These are distinct from the large G06 shadow bank. Unless specified, a row is a control signal/live implementation register, **not another historical payload**. Width is logical declaration width, not an isolated fitted-FF count.

| Module / field | Width x count | Capture / restore and selection | Version / freeze | First consumer / necessity |
|---|---:|---|---|---|
| savestates.phase_snap | 2 x1 | capture class0/10/20/25; word02f[1:0]; drive phase_in | v14..17; old normalization unchanged | canonical divider installation |
| savestates.capture_tick_snap | 1 x1 | accepted-T consumed-enable bit; word02f[3] | v14..17; legacy ReplayT2=1 | choose one/two historical CPU ticks; existing pending PSG rule also uses it |
| SMS.clkd | 5 x1 | existing divider; phase-set loads0/10/20/25 | private negedge phase commit under freeze | first native CPU/VDP/pixel/sprite order |
| SMS.ce_cpu/ce_vdp/ce_pix/ce_sp | 1 x4 | existing enable FF; cleared on phase-set then ordinary divider generation | guest gating held until commit | exact first resumed event sequence |
| SMS.ss_phase_ready | 1 x1 | registered acknowledgment of phase_set on negedge | no payload; no guest tick | prevent premature release |
| savestates.clock_phase_set / ss_cpu_prepare | 1 x2 | registered request/preparation controls; states105/106 unchanged | no payload | replay completion then acknowledged phase/beam install |
| T80s.nmi_restart | 2 x1 | existing00/live,01/install,10/T1,11/T2 sequencing; DIRSet then private CEN | deterministic reconstruction, not extra saved state | complete historical CPU restart before VDP release |
| T80s ReplayT2 / RestoreHold / NMIReplay, system nmi_replay_hold | 1-bit wires/ports | unchanged local decode/CE/hold network; no independent storage | retained CPU context/NMI payload and old version rules unchanged | NMI/context replay and held peripheral time |
| savestates.state | 7 x1 | existing common FSM; G10 uses105/106; experiment adds122..126 within7bits | no independent payload | transaction and restart ordering |
| ss_freeze / delayed ss_freeze_r | 1 x2 | hold request and existing edge history | accepted T finishes; raw overflow held too | isolate transport/private reconstruction from guest |
| VDP1/2 ss_regs_set | 1 x2 | original architectural strobe; scanner normalization retained | after private sequential installation | coherent register and IRQ install |
| has_restart / sprite_valid | 1 stored bit plus alias | descriptor/version presence; legacy zero policy | original v14..17 and older paths | central compatibility decision |
| sprite_word / sprite_second | 7+1 | original75-word/two-owner transport index | same ownership and addresses | exact payload order |
| System E owner | 1 metadata bit | word02f[2], compared to live mode | absent secondary must be zero | avoid applying another owner or inactive VDP |
| video_state_in / video_state_set | 22+1 | original beam register and install strobe | same phase-ack release | align first observable raster cycle |
| WRAM/NVRAM private CPU address muxes | 14 /15 data bits | existing ss_freeze&&!ss_cpu_prepare ownership; no new FF bank | all guest writes held during replay | correct reconstruction data without side effects |

G10 historical payload remains **three bits**, excluding the separate System E ownership bit. CPU230/NMI3/decoder3 and beam22 fields predate/are shared with these controls; their representation is unchanged. Main FSM, wrapper replay, RAM ownership, phase decode, normal/turbo/Pause/System E policies are byte-preserved except the inserted sprite transport/apply wait states. They are not optimization targets.

## Historical +5,458 attribution

Measured pre/post G06/G10 deltas: needed+8,051; placed+5,458; synthesisFF+9,603; fittedFF+11,171; controller mappedFF+9,601 and top+2; logicALUT+5,818; routingALUT+5,399. The 9,600 shadow bits explain almost all mapped FF growth. The 1,568 difference between fitted and mapped FF growth includes fitting transformations/duplication and cannot be assigned solely to sprite history.

The aggregate `placed-needed` gap **improved by2,593**. Aggregate packing degradation therefore does not explain the transition. Inference: snapshot FF and their broad capture/rotation/insertion/restore choices are the main architectural opportunity. Unknown: separate additive placed-ALM shares for live restore muxes, ring transport, version decode, restart muxes, fanout, locality/routing and global remapping. Hierarchy ALM estimates overlap packing and are not an additive causal partition. Candidate measurement gives a controlled architectural delta against current F01; it does not retroactively identify every historical ALM's cause.

## Candidate topology and remaining costs

Frozen live fields -> constant local field extracts -> OR of selected32-bit pieces -> **one registered32-bit response per VDP** -> controller engine -> synchronous300x32 scratch -> same DDR64 record. Reverse path: validate original image -> scratch -> synchronous read -> one selected32-bit local write -> original architectural strobe -> unchanged G10 preparation/phase/beam/release.

No 4,778-bit dynamic slice, broad top-level restored-state bank, or parallel shadow copy feeds the synthesized candidate. Existing wide aliases remain only as unused production inputs/read-only test probes; build mapped FF and netlist RAM evidence verify the large bank has gone. Local write choices and a32-bit reduction/mux tree remain. Address8/read/write fan out to sprite children; wdata32 is routed to owners, and constant field/row decode qualifies writes. This trades a narrow distributed decoder and two RAMs for wide FF transport. It does not promise zero fanout or zero muxes. Physical fanout and packing/timing must be measured rather than inferred from the narrower interface.

Two M10Ks are intentional:300x32 exceeds256x32 depth. F01's scratch has only8,192 bits and remains independent. One logical memory holds both padded records; no additional FF copy is made before serial scanning. Direct SAVE could eliminate scratch writes but LOAD still needs validated temporary storage before installation; sharing the required scratch keeps one data path. A20-bit or40-bit repacker could use a different single-block geometry but adds unproven reformatting complexity. At16/32/64 widths,32 is the smallest justified experiment:16 keeps two RAMs and doubles accesses;64 keeps two RAMs and reduces cycles but doubles routed response/write width. Neither had a demonstrated physical advantage requiring a second build. This is a bounded architecture experiment, not a proof of optimal width or RAM count.

## Physical result caveat and why F01 cannot simply be copied

The primary synthesis delta is -9,397 FF, but the **failed-route** fitter table reports logicALUT+5,402, neededALMs-1,838 and placedALMs-1,615. The latter are provisional physical-attempt counts, not a usable area win. In contrast to OPLL's existing addressable memories and naturally grouped state words, dense sprite slot stride74 crosses32-bit boundaries, and each independently updated live bit needs the appropriate local row/write-merge decision. Read contributions also require a reduction network across many spatially distributed shifters. These costs are not abolished by replacing the shadow FF with RAM. This is a structural explanation of why the F01 principle alone does not guarantee the same physical outcome, **not a measured additive allocation of the5,402 extra logicALUTs**.

The failed attempt still occupies4,099/4,191 LABs versus baseline4,106 (both98%). Partial vertical peak interconnect is93.3% versus the completed baseline81.4%; incomplete routing makes global route-through counts noncomparable. Fitter reports congestion and hold-delay repair and does not complete routing. Aggregate emulation-domain added hold delay is lower than baseline (4,655.6ns vs6,528.0ns), so increased total hold repair cannot simply be asserted as the root cause. Fewer global ALMs/FF and lower average interconnect do not prove local routability. Only one same-source seed2 control is permitted here; no RTL, timing setting, SDC, width or RAM-packing tune follows the failure. The final report records both attempts and rejects conversion if physical robustness is absent.

## Candidate private control/storage inventory

These are bounded transaction implementation state, not new guest history or new external payload:

| Owner / declaration | Logical width/count | Role and first consumer |
|---|---:|---|
| sprite_snapshot.memory | 32 x300 =9,600 | validated image scratch; capture/store/apply/bulk access |
| state | 4 x1 | eleven declared command/issue/collect states; local bounded timing |
| index | 9 x1 | row0..299; owner/local-address decode |
| incoming | 64 x1 | accepted bulk LOAD word; two successive RAM writes |
| bulk_rdata | 64 x1 | assembled RAM pair; unchanged external DDR write |
| ram_q | 32 x1 | synchronous memory response; local scatter / bulk assembly |
| legacy_mode,dual,done | 1 x3 | command policy and persistent completion acknowledgment |
| VDP ss_state_rdata | 32 x2 =64 | one-edge local response to capture engine |
| savestates sp_capture/sp_apply/sp_bulk_read/sp_bulk_write/sp_apply_complete | 1 x5 | single command pulses and install completion guard |
| savestates.state | existing7 x1 | inserted states122..126, no declaration-width increase |

Apart from RAM, new declarations total245 bits (176 engine,64 response,5 controller); compiler mapping, RAM output registers, state encoding, sharing and other absorbed controls mean this is **not** the net mapped/fitted-FF delta. The measured net synthesis delta is-9,397 after deleting9,600 shadow FF. Addr8/owner/read/write/busy wires add no independently declared FF. All new command state resets independently of RAM; validated/current capture always supplies the RAM before use, while legacy application supplies literal zeros.
