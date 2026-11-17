const fs=require('fs'),p=require('path'),d=__dirname;
const inv=JSON.parse(fs.readFileSync(p.join(d,'inventory.json'))),sim=JSON.parse(fs.readFileSync(p.join(d,'simulation_results.json'))),micro=JSON.parse(fs.readFileSync(p.join(d,'micro_results.json'))),pair=JSON.parse(fs.readFileSync(p.join(d,'non_injective.json')));
const replay=sim.simulations.filter(s=>s.file==='replay.log'&&s.complete),ordinary=replay.filter(s=>s.case!=='pair_b');
const casesTable=ordinary.map(s=>`|${s.case}|${s.results[0]?.rawFmDifferences}|${s.results.slice(1).map(r=>r.rawFmDifferences).join('/')}|${s.mixer.reduce((n,r)=>n+r.rawPsgErrors,0)}|`).join('\n');
const microTable=micro.micros.map(m=>`|${m.name}|${m.alut}|${m.registers}|${m.memoryBits}|${m.placed}|${m.needed}|${m.virtualUnavailable}|`).join('\n');
let out=`# F01 OPLL savestate architecture and capacity investigation

**Decision C — SEQUENTIAL / SCAN-STYLE SNAPSHOT-RESTORE.** Prefer a32-bit frozen state interface, existing local memory ports and one M10K scratchpad. Exact FM history is missing from v16. Capacity appears plausible for this architecture; a production fit is not established. F01 remains CONFIRMED — FIX REQUIRED; G08.FM remains OPEN — BLOCKED BY F01. No production implementation or format change was made.

## 1. Current HEAD

cb2e8615128d61adb996ada68e6bbdcc314c20f6, branch investigate/savestate-f01-opll-architecture. [baseline.json](baseline.json) records all203 tracked regular-file hashes and the five completely read prerequisite reports. HEAD and index are unchanged.

## 2. v16 confirmation

rtl/savestates.sv retains MIXER_MAGIC=0x484310 and the96KiB /12,288×64-bit container. There are no OPLL capture/restore ports or FM payload. No new version, magic, address allocation or compatibility policy was implemented.

## 3. Resource baseline

Source-verified post-G12 controlled endpoint: **36,300 needed /39,001 placed /41,910 ALMs**,48,428 fitted FF /167,640;45,808 synthesis FF;487/553 M10K;3,809,858/5,662,720 memory bits;39/112 DSP. Setup+0.465ns, hold+0.198ns,0 reported failing timing-summary categories under the unchanged SDC. Quartus17.0.2 Build602,5CSEBA6U23I7, seed1 and unchanged performance/packing settings. This reuses the verified baseline; no production build was required or run. See ../savestate_resource_growth/review.md and ../savestate_g12_sdram_fix/quartus_candidate.

## 4. Production FM architecture

SMS.sv gates system.ce_cpu with ss_freeze and the logical Pause execution gate. Its native divider asserts audio/FM CE at phases10/25; CPU uses /15 normally or /10 in System E/turbo. system.vhd decodes FM writes at portsF0/F1 (IORQ_n0,M1_n1,WR_n0, Evolution off), latches fm_a/d on host rising edges while unfrozen, and instantiates **work.opll:fm** with xin=clk_sys,xena=ce_cpu,ic_n=RESET_n,cs_n=we_n=0. Thus OPLL sees a held address/data command repeatedly, not a one-cycle CPU write pulse.

Actual hierarchy is the nineteen files in rtl/VM2413/OPLL.qip: four slotcounter instances with delays0/2/5/8; controller plus RegisterMemory and VoiceMemory/VoiceROM; EnvelopeGenerator plus EnvelopeMemory/AttackTable; PhaseGenerator plus PhaseMemory; Operator plus SineTable; OutputGenerator plus LinearTable/FeedbackMemory/OutputMemory; TemporalMixer. Controller traverses18 slots in72 enabled ticks. Voice/phase/envelope parameters, logarithmic operator output, linear conversion, historical feedback and output rows feed the partial temporal sum and14-bit mixout.

system clamps14-bit FM to signed13-bit FM_gated, controlled by fm_ena, det_D(0) and Evolution mode. FM_gated shifted left3 goes to both second AudioMix inputs. System E selects PSG2 instead, although its single hidden OPLL still clocks. Disabling audible FM does not reset its temporal state. AudioMix alternates host-clock left/right updates and uses v16's historical release phase. JT89 is the separate PSG implementation, not the FM engine. Host output filtering/DAC is outside this raw/core-port oracle.

## 5. Complete sequential inventory

[inventory.md](inventory.md), [inventory.csv](inventory.csv) and [inventory.json](inventory.json) enumerate122 rows including scratch declarations, every sequential port/latch, process variable, array, memory output and initializer. Each records module, signal, width/count/bits, storage inference, reset, update/CE, dependency, first consumer, guest programmability, derived/history classification and source location. Logical arrays are counted once; Quartus physical read-port duplication is a separate resource fact. No declaration-only state2/state5/state8 or unused LinearTable.w_data is counted as a flip-flop. Immutable lookup tables and purely combinational multiplier helpers are explicitly listed.

## 6. Total state bits

**3,559 logical OPLL bits**, plus wrapper fm_a/d9 =**3,568**. This includes source-sized integer fields and fixed voice-memory backing, not just independently necessary information. It is not the mapped FF count. Quartus maps the existing OPLL to1,599 FF,3,186 memory bits, three M10Ks and four DSP blocks; type constants, unreachable bits, registered RAM ports and duplicated voice reads explain why source bits do not equal FF+RAM counts.

## 7. Architectural program bits

322 declared bits including wrapper;293 meaningful represented bits after18 channel padding bits,9 unwritable user-carrier TL/FB bits and two unused rflag bits are removed. This includes nine22-bit channel records,63 writable user-voice bits, rhythm flags, extra_mode, held pointer/data and wrapper inputs. extra_mode is live: an addressF0/data80 command changes whether later ordinary user-instrument writes are accepted, even though alternate indexing code is commented out. Pending strobes and lagged parameter copies are separate temporal history.

## 8. Temporal bits

1,652 source bits, including37 initialization controls. After five high user_voice_addr bits, five high vindex bits and two always-zero regs_wdata bits are removed, **1,640 temporal bits** remain conservatively represented. Of these,1,603 belong to the initialized steady-state representation. Retain phase324, envelope450, feedback90, output180, key histories, PM13, AM20, noise18 plus rhythm phase taps, one base schedule7, partial sum/output, CE pipelines, parameter caches, in-flight write/address/data and command history. The shared-delay invariant reconstructs three7-bit counters from the base phase; [counter_proof.json](counter_proof.json) checks576 transition cases and states the reset induction.

## 9. Derived/reconstructable bits

283 source bits:262 read/lookup copies (including EG.aridx22) and21 delayed-counter bits. RAM read outputs refill from stable saved addresses; LinearTable takes two host edges; aridx takes one. Eight stationary host clocks with temporal writers held is the proposed preparation budget. The counter copies are computed from the saved base, not canonicalized to zero. CE-clocked sine and attack histories are retained. All omission reasons appear per row; the 72-phase read-cache experiment supports the initialized-state refill, while startup readiness/port interposition remains a separate implementation proof obligation.

## 10. Unknown necessity

**1,296 fixed-voice backing bits have unresolved pre-initialization necessity**, although they are provably immutable ROM values once initialization finishes. Current SAVE acceptance has no OPLL-ready predicate, cooldown resets to0, and video has no core-reset input. Reset during an existing VBlank therefore defeats an unconditional “first capture is after114 clocks” argument. The conservative architecture retains those contents and the37 initialization controls. The measured steady-state core needs a1,896-bit representation; the unrestricted conservative allowance is **3,229 bits**. This is not a claim that each uncertain bit independently affects audio. A future proved initialization-ready acceptance gate could remove the1,333-bit allowance. Fifteen other source bits (unused output entry18 and stale rm) are excluded with the source reasons in the inventory. No unidentified sequential declaration is hidden in this unknown count.

## 11. Dependency graph

\`\`\`mermaid
flowchart LR
 IO[CPU F0/F1 writes] --> CMD[wrapper and sticky command]
 CMD --> PROG[channel and user voice state]
 PROG --> CT[lagged parameters and key/rhythm]
 CT --> PG[phase memory and PM]
 CT --> EG[envelope state, key edges, AM and noise]
 PG --> OP[phase/modulation and sine pipeline]
 EG --> OP
 FB[feedback history] --> OP
 OP --> LIN[linear pipeline]
 LIN --> OM[output memory]
 OM --> FB
 OM --> TM[partial temporal sum and held FM sample]
 TM --> MIX[clamp and AudioMix]
 CLK[base slot phase and pending writes] --> CT
 CLK --> PG
 CLK --> EG
 CLK --> OP
 INIT[initializers and early voice contents] --> PROG
\`\`\`

mixout/mix can alter the first observed sample immediately. Output rows and feedback can alter a later sum or modulator/carrier; the feedback-only omission first differs at host2325. Phase/lastkey/PM affects pitch and future key reset; envelope/AM/noise affects attenuation, rates and rhythm later, even if the first sample agrees. inst_cache/parameter ports can lag a guest write. Schedule loss changes the next consumer; phase0 schedule omission first differs at165 host clocks. Source noise is not assumed to be an abstract textbook OPLL LFSR: retain the implementation's variable-shift/tap ordering and PG noise14/noise17 histories.

## 12. Freeze behavior

**Partial freeze.** xena-gated slot, controller, phase/envelope oscillators, last-key histories, sine/attack pipelines, output controls and temporal mixer hold. Register/voice/phase/envelope/feedback/output memory processes clock every host edge; a held strobe can repeat the same write. Read ports, VoiceROM, LinearTable and EG.aridx keep updating. During completed initialization, repeated writes are idempotent because address/data are held; caches settle before their next enabled consumer. Startup initializers instead advance independently and must not be called stationary. A future private accessor must gate every ordinary writer and every initializer, or prove a ready-gated contract. Existing PSG pending-tick and mixer-phase release behavior stays separate.

## 13. Sustained-tone witness

case0: custom sustained key-on voice, nonzero evolving phase, full volume and feedback7. Uninterrupted raw FM ranges-511..-211 over20,000 host clocks; SAVE-only is exact. Each of three Q→LOAD replays differs at all20,000 raw FM clocks starting k0, while raw PSG/divider/native phase have0 errors. The native-video/CPU-OUT witness independently ranges-449..511 and has the same exact SAVE versus failing LOAD result.

## 14. Attack witness

case2 captures channel0 modulator/carrier in source state01 (Attack), with envelope word0ADFFFF and evolving nonzero raw output (-482..511 during its20,000-clock suffix). SAVE-only matches; all three LOADs differ from k0. case1's slower attack remains silent throughout its short window and is supporting state characterization only, not the changing-audio witness.

## 15. Decay witness

The additional decay case waits12,000 host clocks after case2's prefix. Captured envelope1000180 decodes state10/phase0x180. Its changing suffix ranges-127..511. SAVE matches exactly; three LOADs each have20,000 raw FM differences from k0. The earlier case2 capture was correctly classified Attack rather than being relabeled Decay because of its requested test name.

## 16. Sustain witness

case0/case3 retain key-on with EG sustain enabled and rr=0. In this implementation sustained holding is represented by state11/Release with zero effective rate, not a separate Sustain encoding. Captured envelope1800030 is stable while phase continues. This is an active evolving tone, not a silence equality test. case3 duplicates the same setup intentionally; it is not an independent waveform family.

## 17. Release witness

case4 performs a legal key-off before capture; retained envelope/key history is compared with the uninterrupted future. The suffix remains changing (-511..-331), SAVE matches, and three LOADs diverge. Source lastkey determines key-edge behavior separately from current programmed key. Retaining only current key and volume cannot recover the saved release phase/rate trajectory.

## 18. Feedback witness

case0's user instrument selects feedback7. A focused behavioral ablation restores everything except FeedbackMemory.data_array; with the same restored program, phase, envelope, output rows and other pipeline history, it produces **2,160 differing samples /60,000**, first at2325. This isolates feedback sensitivity. The broader output/feedback-category omission also fails. Preset1 case5 has a silent reference window and is not used as the primary feedback proof.

## 19. User-instrument witness

case0/case6 program all eight user-instrument byte addresses through the production held-address/data behavior. Q selects a different preset and frequency before each LOAD. v16 cannot recover either architectural user parameters or their existing synthesis trajectory. case6 repeats the same custom instrument setup; the natural collision below additionally has identical final program and still different phase/future.

## 20. Rhythm/noise witness

case7 legally programs channels6–8 and rhythm register0E=3F, with all five rhythm key bits. The captured envelope/phase arrays show active rhythm slots; exact raw suffix ranges-3669..1261. Retain envelope ntable18 and PG noise14/noise17 plus registered noise, phase and rhythm-key histories. SAVE matches and repeated LOAD fails. This tests implemented rhythm/noise, not a substituted noise model.

## 21. Multiple channels

case8 adds preset2 channel1 to the custom channel0, with independent frequency/block/key programming. Captured phase/envelope rows2/3 are active along with0/1; both channels participate in the temporal mixer/output-memory path. The changing combined suffix is scored exactly; SAVE passes and three LOADs fail. It is a targeted two-channel test, not all possible nine-channel combinations.

## 22. SAVE-only result

The${ordinary.length} completed same-history replay configurations each score20,000 logical host clocks from the first resumed edge. Every one has0 raw FM differences and0 raw PSG/divider/phase errors on SAVE-only. This includes native video, attack/decay/release/rhythm and transaction-qualified13/31 DDRAM busy stalls. It supports the initialized-state idempotent-write/frozen-CE argument, not a proof about every startup/reset boundary. No first-sample tolerance or grace interval is used.

## 23. LOAD result

All same-history configurations preserve fully known current-controller images, then apply distinct legal Q histories and LOAD. Each checks raw FM and both mixer channels for20,000 clocks; every one of the${ordinary.length*3} LOADs reproduces a raw FM divergence. The PSG/configuration/extension/divider/native-clock oracle remains exact. The completed native fixture uses real T80 OUT instructions and production video; unrelated machine endpoints remain mocks. Full result ledger:

|Configuration|SAVE raw FM differences|LOAD1/2/3 raw FM differences|Total PSG/phase errors|
|---|---:|---|---:|
${casesTable}

## 24. Repeated LOAD

Three independent Q→LOADs per configuration use the same immutable96KiB image. The test checks every12,288 image word for binary knownness and immutability. The differing Q frequency/instrument/PSG histories are logged. Three additional pair_b LOADs are retained but not counted as same-history oracle failures, because its intentionally different earlier FM history already differs from case0 before LOAD. Successful characterization markers mean the current defect was reproduced, not that F01 is fixed.

## 25. Natural non-injective proof

case0 and pair_b differ by one bit in an earlier legal frequency write (address10:data91 versusB1); later both write91 at the same host clock. No internal OPLL history is forced. CPU, video/peripheral endpoints, RAM, PSG, request timing and future inputs are identical. Complete saved images are byte-equal, SHA256 **${pair.sha256}**,98,304 bytes. At acceptance, phase rows0/1 are27290 versus2A190; envelopes are equal. The future raw FM differs15,680/20,000 clocks, starting k0. This is the smallest established pair in this search (one guest data bit, earliest possible observed differing sample), not a claim of globally minimal phase distance. [pair_a.bin](pair_a.bin), [pair_b.bin](pair_b.bin), [non_injective.json](non_injective.json). Natural reachability is within the documented production-component composition, not a whole-game-machine state claim.

## 26. Minimal-state search

Behavioral local snapshots capture every sequential process target/variable, then legal writes evolve only DUT while reference remains at T. Full restore gives0/60,000 differences at each of72 natural OPLL phases (4,320,000 clocks). Restoring everything except the operator/sine category fails at21/72 phases,180,360 differing clocks, despite passing phase0. Restoring everything except stationary memory/linear read caches passes72/72 after eight zero-xena host edges. Nine initial category probes fail when command, phase, envelope, output/feedback, schedule, controller/program or partial sum history is omitted. Feedback-only omission independently fails. Total ${sim.search.length} completed behavioral experiments are in simulation_results.json. Group sufficiency and causal necessity are established for these traces; no globally minimal bit-entropy claim or per-bit necessity proof is made.

The steady-state representation is1,896 bits:1,305 array bits +591 scalar/pipeline bits. Conservative unrestricted capture adds37 initializer controls and1,296 uncertain voice-backing bits, giving3,229. Preserving unknown-necessity bits in RAM is a bounded architecture allowance, not permission to silently declare them all required or all irrelevant.

## 27. Reconstruction opportunities

ROM constants after readiness, fixed zero/type-padding bits, three delayed counters, current-address RAM outputs, linear interpolation cache and aridx can be generated without advancing guest synthesis. Counter reset/CE induction and explicit source dependencies support those reductions. Ordinary reset plus replay of the same programmed registers fails60,000/60,000 compared samples. Full state restoration followed by an ordinary72-xena “warm-up” fails57,840/60,000. Thus program replay, a canonical zero oscillator phase, or advancing envelopes/noise to hide a preparation interval cannot provide exact historical audio. The natural same-program collision rules out any deterministic finite warm-up based only on those registers for both histories. A stationary lookup refill is materially different and is tested.

## 28. Canonical restart feasibility

Do not canonicalize synthesis time. Preserve historical base phase, pipeline state, key edges, partial sum and held sample. A bounded host-only preparation with xena=0 can reconstruct pure caches. All initializers and ordinary memory writers must remain inhibited while partial state is installed. The proposed unrestricted schedule targets181 host clocks after validated LOAD, including eight refill clocks; the ready-gated variant targets108. These are design targets, not measured port-prototype latencies. FM/PSG/CPU clocks do not advance. Refill samples are private; AudioMix must receive stable restored raw FM before phase-controlled release. The existing PSG falling-edge pending event is neither consumed nor synthesized by FM preparation.

## 29. Architecture A — direct parallel

Conservative flat nonconstant state is3,512 represented bits, including reconstructable caches/delayed counters, so55×64-bit transport words and an8-byte descriptor =448 bytes. This is an upper-bound flat representation, not an information minimum. A parallel capture/restore cannot directly access all38×36 voice words and18×25 envelope words through existing M10K ports in one edge. Demotion, splitting or an internal sequential phase is necessary; the latter ceases to be pure A. Estimate5,300–7,000 added FF including scratch and demoted live storage;2,500–5,000 added placed ALMs, M10K potentially-3 if demoted, high timing/placement risk. These are engineering ranges, not Quartus production deltas. Wide capture/restore fanout and source-priority mux choices make A unsuitable for an unconditional safe-to-implement decision.

## 30. Architecture B — minimal parallel + reconstruction

Preserve3,229 conservative bits (1,896 only with proved readiness) and rebuild283 source-sized derived bits. Parallel array restore still conflicts with RAM port width. Estimate5,000–6,000 added FF for unrestricted parallel scratch plus memory demotion,2,200–4,500 placed ALMs; zero guest ticks, eight host refill clocks plus any local array access. The ready-gated variant could be substantially smaller but is not established by assuming reset always precedes a whole frame. Lower payload alone does not eliminate live restore muxes or M10K demotion. Correctness confidence is medium after an appropriate boundary proof; placement risk remains high.

## 31. Architecture C — compact snapshot + sequential restore

**Recommended.** Read frozen live state through module-local32-bit words and existing memory ports into one256×32 M10K; validate LOAD fully there, then write one local word/array entry at a time while all guest consumers and initializers hold. No full parallel shadow bank. Preserve3,229 conservative bits; use the fixed-row680-byte record below or416-byte tightly packed record. Added registers estimated80–180 for bus buffers/address/control, additional needed ALMs roughly150–700 and placed ALMs **250–1,000**, +1 M10K,0 DSP. Ordinary restore data width is32, with a local36-bit assembled user-voice write. Capture/restore local schedule targets336/181 clocks, excluding arbitrary DDRAM stalls. Primary risk is temporal writer isolation and source-port interposition, not raw RAM capacity. [architecture.md](architecture.md) states the exact contract and required implementation proofs. This architecture is not implemented by the behavioral test hooks.

## 32. Architecture D — reuse existing OPLL memory ports

The six production memory interfaces cover all channel,voice,phase,envelope,feedback and output arrays:2,601 conservative bits,1,305 after readiness. Only513 historical initialized bits (envelope450 +user63) currently reside in block RAM; other arrays are logic with existing synchronous access paths. Reuse these paths under freeze with local address/data/write selection; do not add a parallel input to every cell. Estimate50–250 local ALMs plus controls, no new M10K for the live stores. D alone omits628 scalar/control bits and is incomplete; combine it with C or F. No independent assertion that unused bits in a voice/envelope M10K can be shared with an unrelated snapshot.

## 33. Architecture E — scan/shift

Dedicated scan over frozen scalar FF avoids a parallel shadow bank; memory arrays still need safe sequential access. A1-bit scan of628 scalar/control bits plus148 array-row operations is feasible in principle; use dedicated scan control, not ordinary xena. A32-bit scan may need padded live rings whose padding becomes data-bearing during rotation; do not count that padding as permanently dead FF. Approximate150–900 placed ALMs,50–150 extra control/buffer FF,+1 scratch M10K, hundreds to >1,000 host clocks depending width/protocol. The isolated scan bank is cheap, but shifting pending writer/address controls is dangerous unless all writers/initializers are isolated first. Correctness/verification risk is higher than C; a low isolated count does not validate a live scan implementation.

## 34. Architecture F — hybrid

Parallel-capture628 scalar/control bits (potentially640 physical ring bits) and sequentially move2,601 array bits through existing ports. +1 scratch M10K, roughly700–900 added control/snapshot FF and450–1,200 placed ALMs estimated. Width32/36 for arrays but628-bit scalar capture/restore fanout; sequential array latency remains. It is a credible second choice if freezing and reading scalars in place proves difficult. It preserves all required timing but spends FF/placement to simplify coherent scalar capture. No evidence currently requires that extra bank, so prefer C first.

## 35. Parallel mux risk

Do not divide source mux estimates by an arbitrary ALM ratio. The seven initial synthetic experiments show a simple parallel load can map onto dedicated register load controls with almost no ALUTs, yet adding a2,048-bit snapshot bank costs1,025 placed sites in that synthetic fit. Real OPLL has differing reset/CE/partial-write paths and M10K ports, and the G06/G10 wide multiway banks already demonstrated implementation sensitivity. A would expose up to3,512 scratch data bits plus broad live selection; C exposes32-bit returned words and local enables. A naive one-edge RAM snapshot at the experimentally used32-bit width would need at least101 independent blocks for3,229 simultaneous bits, exceeding66 free blocks. Even the ready-only1,896-bit variant needs60 such banks. Small total bits do not make a full-width RAM snapshot cheap.

## 36. Sequential restore feasibility

There is no guest consumer during freeze, so partial array/scalar installation is permissible only while ordinary writes, initializers and guest enables are inhibited. Existing RAM address/data buses provide narrow entry access; scalar fields get local fixed-slice read/write enables. Retain pre-commit arrays and pending writers for unrestricted startup, rather than advancing initialization during capture. After restoring the last field, return addresses to runtime owners and perform stationary refill before release. This replaces a large full-width shadow/restore fabric; it does not eliminate per-bit receiver selection or prove the new port logic automatically equivalent. Enforce local assertions for no premature store, no temporal tick and exact first enabled consumption.

## 37. RAM feasibility

Existing OPLL map: envelope18×25 =450 bits in one M10K; voices38×36 duplicated for two registered read ports =2×1,368 bits in two M10Ks. Phase, feedback, output and channel arrays explicitly request logic where stated in source; preserve that inference initially. Fixed voice contents share addresses/ports with mutable voices and initialization, so unused block capacity cannot be freely borrowed. A dedicated256×32 scratch consumes8,192 logical bits in one new M10K and has adequate capacity for168 row slots. Port width, synchronous latency and read-during-write mode must remain explicit. The isolated fullram experiment verifies this geometry; no migration of the live FM algorithm to a different RAM organization is proposed.

## 38. M10K headroom

487/553 used;66 whole blocks free. One snapshot scratch gives488/553,65 free. Nominal unused bits1,852,862 includes holes in allocated memories; wholly free block capacity is66×10,240 =675,840 bits. Live OPLL's three underfilled blocks cannot simply absorb a fourth independently clocked/addressed store. A separate block for a small1929/3229-bit packed snapshot may waste capacity, but one block is justified by safe sequential access and ALM avoidance, rather than the existence of nominal spare bits alone.

## 39. Physical ALM headroom

2,909 unplaced sites; the needed estimate leaves5,610. FF nominal headroom119,212 does not solve distributed placement. C's250–1,000-site engineering range gives39,251–40,001 placed ALMs (93.655–95.445%). No measured production F01 delta or timing margin is implied. The conservative startup allowance increases RAM rows/latency far more than live scalar mux width, so it does not restore the wide parallel-bank problem.

## 40. Utilization budgets

|Limit|Maximum whole placed sites|Additional sites from39,001|
|---|---:|---:|
|95%|39,814|813|
|97%|40,652|1,651|
|98%|41,071|2,070|
|99%|41,490|2,489|

C plausibly stays below97%, with95% not guaranteed. F's forecast also fits97% but spends more reserve. Unrestricted A/B can exceed98/99% or device capacity; the ready-gated forms remain unmeasured. E is plausible on counts but has higher temporal proof risk. D is not a complete architecture. These are capacity comparisons, not signoff thresholds or measured integrated results.

## 41. Isolated synthesis

Eight same-device Quartus17 map/fit structures, virtual pins, root performance settings, no production integration/SDC signoff. Columns separate mapped ALUT/FF/memory from actual placed sites and the virtual-I/O contamination of needed counts:

|Structure|Mapped ALUT|FF|Logical RAM bits|Placed ALMs|Needed estimate|Unavailable due virtual IO|
|---|---:|---:|---:|---:|---:|---:|
${microTable}

The2,048-bit parallel bank adds2,048 FF and1,025 placed sites relative to base. Indexed32-bit sequential access adds832 ALUT and766 placed sites without adding a shadow FF bank: a central read crossbar is costly, motivating reuse of local memory ports. Simple CE/scan banks use dedicated load hardware; their tiny ALUT counts do not predict costs of OPLL's multiway updates. Small/dual/full RAM structures establish a one-block synchronous scratch option, not full-chip savings. Needed counts in the large virtual-port tests are dominated by3,110 virtual-I/O unavailable ALMs; never substitute them for production resource deltas. [micro_results.json](micro_results.json) preserves report hashes.

## 42. Locality and fanout

Keep the state accessor local to the FM hierarchy. Local memory write selection is at most36 bits, not2,601 parallel cell inputs. Scalar read muxes cover628 bits across a few modules, then return32 bits through a bank selector. Global address/control reaches local decoders; each write enable selects one local word rather than all3,229 endpoints. A32-bit bus still has roughly a few dozen destination groups and may require replication. Preserve normal clock/CE routes; avoid using global version/default selection on each live data bit. The production fit must examine routing/packing and timing, not just ALUT counts.

## 43. Payload requirements

No version/address assigned. One proposed64-bit descriptor identifies layout/length/presence/mode with validated reserved bits and final commit validity; its8 bytes are included below.

|Representation|Historical allowance / represented bits|Packed bytes|64-bit payload bytes|Payload padding|With descriptor|
|---|---:|---:|---:|---:|---:|
|A flat nonconstant + derived copies|3,512|439|440|8 bits|448 bytes|
|B/C/E/F tightly packed conservative|3,229|404 (3 pad bits)|408|35 bits|416 bytes|
|C selected natural32-bit rows|3,229 in5,376 transported bits|672|672|2,147 bits|680 bytes|
|Ready-gated minimal variant (conditional)|1,896|237|240|24 bits|248 bytes|
|Ready-gated natural rows (conditional)|1,896 in3,072 transported bits|384|384|1,176 bits|392 bytes|

D alone preserves arrays, not a complete record; a viable D composition uses C/F's full payload. Conservative C has168×32-bit rows:148 array rows plus20 scalar rows. All2,147 unused positions are zero and validated. Snapshot RAM is256×32, not168 independent banks. Sparse rows consume more file bytes but avoid a variable-width packer. Minimum meaningful history is not proven globally:1,296 startup backing bits are a conservative uncertainty allowance;1,896 is a sufficient initialized-state candidate, not a lower-bound entropy theorem. Future placement could justify the optional33-bit redundant-counter/type simplification being encoded differently; that would be explicit format design, not an undocumented reinterpretation.

## 44. Stable-format compatibility

Verified local release tree: SMS_20260823.rbf, commit3ae7eec9cc2a9e02f824771e2e5652f5992ed906, blob26632aabd2f9db6b1f593f460e0701eb2591acce. Its associated source is untagged96KiB,0x3000 words/slot, NEW_SS_WORDS24574, SMS1/SMSB plus game signature. It is not a development HC version. Its system still connects OPLL only to clocks/reset/address/data; no FM program or temporal image exists. Therefore do **not** promise even saved-register replay for that stable format. Recommend a documented deterministic local FM reset/program-default fallback, completing initialization while other guest domains remain frozen, with explicitly lossy missing FM history. Retain any independently saved controls according to their actual fields; do not infer FM parameters from PSG words or WRAM. The older public64KiB reader is a separate compatibility policy. No network freshness or bitstream/source reproducible-build attestation is made. v16 likewise lacks the missing FM history.

## 45. F01 versus G08.FM

F01 must supply a coherent raw OPLL record at accepted T and exact14-bit raw output plus enabled transition sequence after restore, including startup, commands, rhythm and partial sum. Preserve or prove normalized pending-store ordering; do not derive OPLL ticks from JT89's pending event. G08.FM later checks FM→clamp→AudioMix publication: stable restored inputs, cache refill, historical left/right phase, first resumed sample, near-T FM/PSG writes, independent FM/PSG phases, silence transitions, repeated LOAD, long/random stalls and Pause. Provide independent uninterrupted raw FM and signed stereo traces from k0, saved metadata, source hashes and native enable schedule. System E substitutes PSG2 and has no second FM engine. No G08.FM closure is attempted here; raw-source restoration and mixer release ordering remain separate proof obligations.

## 46. Resource-risk matrix and ranking

All production area ranges below are engineering estimates. Correctness confidence refers to feasibility of the proposed state representation, not an implemented/verified F01 fix.

|Rank / family|Completeness / confidence|Record bytes|Added FF estimate|Placed ALM estimate|M10K delta|Timing / placement risk|Implementation / verification|
|---|---|---:|---:|---:|---|---|---|
|1 C sequential local access|Conservative complete candidate; medium|680 (416 packed)|80–180|250–1,000|+1|medium / medium|high temporal-port proof; manageable local hardware|
|2 F hybrid|Same history; medium|680 or416|700–900|450–1,200|+1|medium / medium|coherent scalar bank simpler; more FF/fanout|
|3 E dedicated scan + memory access|Complete only with writer isolation; medium-low|416 or680|50–150 control|150–900|+1|medium / medium|highest scan/pending-writer proof burden|
|4 B minimal parallel|Candidate history complete; medium|416|5,000–6,000 unrestricted|2,200–4,500|-3..+1 depending split|high / high|RAM demotion/repartition + reconstruction|
|5 A flat parallel|Conservative state; high inventory confidence, low physical confidence|448|5,300–7,000|2,500–5,000|-3..+1 depending organization|high / very high|wide scratch/live mux and memory redesign|
|D reuse ports (component)|Arrays only; incomplete alone|not standalone|small local controls|50–250 local, excludes scalar/transport|0 live|low-medium locally|required subcomponent of C/F|

Keeping one scratch M10K does not guarantee a fit, and no isolated report authorizes replacing an integrated delta with this range. The failed sprite optimization remains NO SAFE MATERIAL OPTIMIZATION FOUND; no assumed savings from it, tag consolidation or F06 are credited to F01.

## 47. Exactly one recommended architecture

**C. SEQUENTIAL / SCAN-STYLE SNAPSHOT-RESTORE**, specifically local sequential32-bit access with one RAM scratchpad and existing array ports, rather than a live shift-chain implementation. It preserves the conservative startup allowance without a parallel3,229-bit shadow bank, has a credible one-M10K geometry, keeps history local and reduces central bus width. Do not label this direct serialization safe to implement. [architecture.md](architecture.md) defines the required freeze/capture/validation/restart obligations and the optional smaller ready-gated variant.

## 48. Capacity conclusion

**Plausibly feasible on the current device; not measured production signoff.** Even the conservative startup-capable state fits one scratch M10K and leaves65 free. C's local bus/decoder forecast is within1,651-site97% headroom and may meet the813-site95% target. The geometry and representative structures support proceeding to a constrained implementation experiment. Neither “all FM state is cheap because FF are free” nor “F01 is impossible above93%” follows from the evidence. Full-board timing/placement remains a required future gate.

## 49. F01/F06 ordering

Recommend **1. implement F01**, using the selected sequential architecture and staged proof/resource gates. First resolve the startup representation in that task: retain conservative state, or prove an initialization-ready acceptance contract before reducing it. Do not solve F06, redesign unrelated resources, or consolidate development formats merely to assume area recovery. F06 was not investigated. No proposed roadmap step is performed by this investigation.

## 50. Evidence limitations

No F01 production fix, new-interface miter, integrated F01 Quartus fit, timing signoff or hardware/game-ROM run. Source inventory and initialized-state causal tests establish a strong architecture basis, not exhaustive equivalence for arbitrary guest inputs or all reset/pause/mode combinations. Startup1,296-bit necessity is explicitly unresolved and preserved in the conservative plan;37 initializer controls cannot be excluded using the completed late-capture tests. Eight-host refill at startup and new port interposition need the future exact boundary proof. Counter derivation is an inductive source proof plus576 enumerated transitions, not a new production implementation. FM native test has real OUT/video but mocked unrelated endpoints. Fast tests use legal fixture IO; current-image collision is natural within that composition. Two silent probes are not counted as changing-signal witnesses; the corrected native initialization pilot and setup failures are excluded. All retained uninterrupted suffixes are within the production FM clamp pass-through range; raw FM is the primary oracle, so no unsupported clamp/saturation conclusion is inferred from wrong post-LOAD mixer values. Fixed-seed synthetic virtual-pin fits have no production timing constraints. Legacy release identification is from local Git history only.

## 51. git diff --stat

\`\`\`text
(empty)
\`\`\`

Tracked production files and all five prerequisite reports retain their baseline hashes. New artifacts are under this investigation directory. Generated micro databases and simulator libraries are ignored, not staged.

## 52. git status --short

\`\`\`text
?? tests/
\`\`\`

The tests tree was already untracked before this task. Nothing staged; no commit, push or PR. No production Quartus run, production RTL edit, v16 edit, F06 investigation or G08.FM closure.

## 53. Exact next task

Separately authorize an F01 implementation using **local sequential32-bit snapshot/restore, one256×32 M10K scratchpad and existing memory ports** from this unchanged HEAD. Establish a pre-edit accepted-edge specification that includes reset during VBlank and OPLL initialization: either preserve the3,229-bit conservative state or prove a ready-gated1,896-bit alternative. Implement private writer/initializer isolation and all-field access first in an isolated candidate; prove against the untouched production oracle, with no global state forcing. Retain the natural full-image collision, active attack/decay/sustain/release, feedback-only, user instrument, rhythm, multichannel, CPU-OUT/native clocks, SAVE-only and repeated-LOAD/stall witnesses. Extend to same-edge writes, first FM sample, paused/near-reset capture and post-fix equal-image search. Only after sufficiency passes integrate a tagged payload under a separately chosen format policy, preserve PSG/G10/F12 contracts, and run controlled full-board Quartus. Aim ≤813 added placed ALMs; report any crossing and stop/review if resource/timing correctness gates fail. G08.FM release closure follows as its own oracle-driven task; F06 stays outside scope. Do not commit/publish unless separately requested.
`;
const spaceNumbers=s=>s.replace(/\b(all|a|an|the|one|two|three|four|five|six|seven|eight|nine|and|with|of|for|by|after|before|at|from|plus|takes|is|in|has|each|its|to|only|channel|feedback|phase|envelope|output|voices|noise|AM|PM|slot|key|TL|data|word|delay|instrument)(?=\d)/gi,'$1 ');
fs.writeFileSync(p.join(d,'review.md'),spaceNumbers(out));
console.log('Wrote53-item architecture review');
