# F11 accepted-boundary investigation

**CONFIRMED - FIX REQUIRED. Production RTL remains unchanged.** The conclusive defect is an incomplete lightgun freeze: its ungated hit comparator can manufacture a pending hit during save-only transport. Real production T80 CPUs then execute identical polling code but read different controller data and acquire different A registers. This does not depend on CPU restore timing, F07 failure, changed host input, or forced lightgun registers.

This investigation does **not** establish that every omitted register needs serialization or that v8 is necessary. Additional load-time sensor history differences were measured at the I/O interface, but the independently conclusive CPU case is save-only. A separate authorized fix should first freeze local protocol time correctly and establish the minimum restore representation from CPU-visible evidence.

**1. Complete dataflow.** External HPS mouse/joystick input becomes live lg_x/lg_y, then frame-latched x/y/offscreen. Locally counted HDE/VDE timing generates a hit, sensor_pend and sensor_time generate SENSOR, SMS registers its inverse onto selected P1/P2 TH, io.vhd exposes TH in $DD and produces HL_out, and the VDP latches x/2 for $41. TARGET/draw only produces the host crosshair overlay. There is no physical sensor-bit input or dedicated sensor synchronizer: SENSOR is generated internally. Detailed paths and configuration conditions are in [inventory.md](inventory.md).

**2. Complete state inventory.** The historical matrix labels lightgun S074; the request calls it S073. This is F11/lightgun, not the already fixed paddle finding. inventory.md classifies every gun register and relevant surrounding state as already saved, reconstructed, external, omitted local, or irrelevant. The conservative guest beam/sensor candidate set is 74 bits: hcnt/vcnt/vtotal 27, hde_d 16, old_hde/old_vde 2, frame x/y 18, offscreen 1, pending 1, time 8, SENSOR 1. The module's other declared bits cover host pointer processing, trigger sampling, crosshair-only history, an overwritten calculation temporary and unused old_pix. They must not automatically be serialized. The existing video22, IO ctrl and F07 HCounter fields are already saved; TH caches and HL/direction history are recomputed.

**3. External-input boundary.** Raw mouse data/strobe/buttons, joystick coordinates/buttons and configuration remain external. Sampled frame targets and the sensor pipeline are local history. All definitive counterexamples keep external aim and trigger constant throughout save, transport and continuation. Mouse cursor integration policy from historical audit S075 is not needed for the proof and is not changed or proposed for rewind. Relative mouse motion replay and every host-input mode are not claimed exhaustively validated.

**4. Exact acceptance.** The real controller requires !storage_busy, cpu_ce, M1_n=0, MREQ_n=0, ISet=00, VBlank=1 and x<256. CPU snapshot occurs at this edge. ST_ARM_FREEZE takes video/VDP/IO one host clock later and asserts freeze. The production enable pattern gives no additional pixel tick between acceptance and freeze. The load release guard is >=255 host clocks and releases on a quiet CE phase after raw video reaches saved x/y, or the existing alignment timeout. Tests verify complete 22-bit video-state equality at release; they do not manufacture a timeout mismatch.

**5. Freeze/transport behavior.** Raw video timing and its HDE/VDE continue throughout DDRAM transport. Gun CE_PIX is suppressed. Gun hcnt/vcnt/vtotal/hde_d/old_hde/old_vde/frame target/offscreen/SENSOR hold. However the host-clock hit comparator remains active: if raw HDE and VDE become true while frozen local hcnt and vcnt match the held target, it sets pending and resets time. These two fields therefore are not fully frozen. Live host-coordinate/strobe/trigger/crosshair sampling also continues. IO and SMS TH caches continue tracking SENSOR. On load no gun state is restored. The ordinary FLUSH_MAX=900000 flush and release alignment remain intact. At hardware clk_sys=53.693175MHz, the 896035-clock real-CPU save lasts about 16.688ms, roughly a full NTSC frame; effective lightgun pixel ticks during freeze are zero while raw video traverses that frame.

**6. Reachability at capture.** VBlank does not canonicalize the local sensor pipeline. It starts before the first blank line's delayed HDE falling edge has cleared local vcnt. Accepted x<256 can retain the last visible line's sensor tail or a local beam counter still in its hit window. The reference and DUT run naturally through complete frames; RESET is unused by lightgun.sv, so no internal seed/reset is fabricated. At the real-CPU save acceptance (254,192), freeze holds local hcnt=253, vcnt=192 and target=(253,189), initially pending=0,time=255,SENSOR=0. These are naturally reachable, not deposited register values.

**7. Replay methodology.** Full controller tests instantiate production video.vhd and io.vhd, the production lightgun process with a fixture-only reference hold guard, the actual savestate FSM and a DDRAM handshake model. The production one-clock SMS TH inversion is retained. The F07 latch block is extracted exactly for this minimal path; unchanged full-VDP F07 regressions run separately. The seven positive load/I/O tests and one negative load sample drive legal fetch-interface conditions and port strobes; they do not instantiate a CPU. The independent conclusive save-only case instantiates two actual T80s processors, actual I/O, ROM polling code, real acceptance signals and the real controller. Reference state is held at T and never restored from a snapshot. Save-only release leaves both CPUs in identical state; complete video state is also identical. Common future enables and external inputs isolate the gun's pending/time discrepancy.

ModelSim-only adaptations are reversible: move two savestate declarations before use; declare procedural gun outputs reg; move TARGET assignment after declarations; add the reference hold guard; make T80 direct-entity syntax explicit in local copies. No expression in production gun/CPU logic is changed. ModelSim retains the existing T80 operand-width compile warning at its block-I/O calculation; no CPU logic is repaired in this investigation. static.log verifies these adaptations and all 136 committed-F10 source/settings files.

**8. Case counts.** Nine full-controller cases execute 17 accepted operations: eight save/load pairs and one save-only operation. Seven load/I/O samples diverge, one short-tail sample converges before its tested read, and the real-CPU save-only case diverges. Separately, 33 continuous natural timing sweeps examine 332,424 potential capture observations and find 84 with SENSOR active. These potential observations are sampled at actual pixel/CPU-enable phases and qualifying VBlank/x positions; they are **not** claimed to be completed savestate transactions or actual CPU fetches. The real CPU supplies its own M1/MREQ/ISet in the conclusive case.

**9. Sensor-edge sweep.** Target pairs include minimum/offscreen coordinates, middle positions, x=240,254,255 and near-bottom y=248,252,255. Inputs are moved externally only after natural warm-up so inactive targets do not rely on uninitialized SENSOR. Continuous runs include inactive-to-active and active-to-inactive sensor transitions and hit/miss targets. The default 192-line x=254/255 near-bottom cases allow ten potential captures with post-boundary x values 1..14 while SENSOR is still high. Middle/offscreen targets produce no such active-sensor capture window. These sweeps characterize reachability; a full DDRAM replay of every candidate was unnecessary to classify the independently proven defect.

**10. HDE/beam sweep.** Each sweep runs complete natural frames and visits every implemented horizontal count, HDE rise/fall, active/VBlank transition and VBlank CPU-enable position. Positive reachability summaries:

| Timing | Mode | Border | First VBlank y | Post-boundary x with active SENSOR | Potential observations |
|---|---:|---:|---:|---|---:|
| NTSC | 192 | 0 | 192 | 1..14 | 10 |
| NTSC | 224 | 0 | 224 | 1..14 | 10 |
| NTSC | 240 | 0 | 240 | 1..14 | 10 |
| PAL | 192 | 0 | 192 | 1..14 | 10 |
| PAL | 224 | 0 | 224 | 1..14 | 10 |
| PAL | 240 | 0 | 240 | 1..14 | 10 |
| NTSC | 192 | 1 | 216 | 1..2 | 2 |
| PAL | 192 | 1 | 240 | 1..2 | 2 |

The raw production video counter's implemented modes are used without repairing or substituting their timing. Border mode includes extra visible extent in the learned vtotal. The PAL/JP P2 border sample carries SENSOR at release with time=63 but clears within three effective pixel ticks, before that fixture's tested read. This is a local negative observation, not a global exclusion.

**11. HCounter interaction.** In the primary load case, full video state at release is 002c01 on both paths and both HCounter latches equal 92. Nevertheless SENSOR is 0/1, TH is 1/0 and $DD is F4/B4. Thus the observed TH difference is not an F07 restore failure. In the real-CPU case no register load occurs at all: matching CPUs and beam timing diverge only after the newly armed sensor pulse. Source inspection confirms no direct gun IRQ/NMI output; SENSOR can cause a future HL latch. Actual I/O NMI remains 1 on both paths. The CPU proof disables unrelated VDP interrupts rather than claiming a complete IRQ simulation.

**12. Transport results.** The first four rows vary transport only: no stalls, deterministic stalls, seeded random stalls and a deliberately long 1900/2048 busy-duty profile. All preserve the same aim and reproduce the same I/O difference. Later rows add ports/region timing.

| Log | Saved video / HCounter | DUT/reference $DD | Frozen save clocks | Frozen load clocks |
|---|---|---|---:|---:|
| boundary0.log | 002c01 / 92 | F4 / B4 | 896,040 | 1,832,225 |
| boundary1.log | 002c01 / 92 | F4 / B4 | 896,040 | 1,840,035 |
| boundary2.log | 002c01 / 92 | F4 / B4 | 896,040 | 1,844,925 |
| boundary3.log | 002c01 / 92 | F4 / B4 | 896,040 | 2,319,885 |
| variant0.log | 002c01 / 92 | F4 / 74 | 896,040 | 1,832,225 |
| variant1.log | 002c01 / 92 | F4 / B4 | 1,070,460 | 1,110,605 |
| variant2.log | 002c01 / 92 | F4 / 74 | 1,070,460 | 1,110,605 |

The negative extended-border load uses save=1070460 and load=1110605 clocks and reads F4/F4 after the tail expires. The separate real-CPU save-only operation lasts 896035 clocks. No SS flush counter, alignment wait or memory walk is shortened; only the UI cooldown is bypassed in the interface-level load harness. The real-CPU save request uses the normal initially zero cooldown.

**13. Region/model/port coverage.** Full load cases cover P1/P2, NTSC/PAL, export and JP IO region, normal and extended border timing. Natural timing sweeps cover 192/224/240 mode selection under NTSC/PAL plus border variants. Gun mode selects joystick0/joystick1/mouse independently of the destination port; the module path is common, but actual mouse-motion and every input-source/trigger setting are not exhaustively replayed. Root gun_en is gun_mode!=0 && !gg; disabled/GG guest routing is structurally excluded. System E/other non-GG model combinations allowed by the root expression are traced but not dynamically certified here. No claim of a complete future-fix validation matrix is made.

**14. Guest-visible divergences.** Main load/I/O counterexample: F4 versus B4 on P1 ($DD bit6), or F4 versus 74 on P2 (bit7), while saved HCounter remains correct. Stronger real-CPU save-only counterexample: DUT pending/time become 1/0 during transport while reference remains 0/255; subsequent actual IN bus samples are B4/F4 and A becomes B4/F4. The ten recorded post-release CPU read sampling opportunities include four mismatching samples across two IN instructions; they are not ten distinct instructions. First mismatch is 559 host clocks after release.

**15. Minimal conclusive reproducer.** Run cpu.do after prepare.js and prepare_cpu.js. The ROM is bytes 3E FF D3 3F DB DD C3 04 00: LD A,FF; OUT (3F),A; loop IN A,(DD); JP loop. Keep JOY_X=7D and JOY_Y=7C (target 253/189 after scaling), mouse and trigger unchanged. Naturally reach the sixth frame's first VBlank line with a real M1 memory read at x254. Request save one host clock before that eligible CPU tick. Freeze captures SENSOR=0,pending=0,time=255 and local beam 253/192. Raw video continues while gun CE_PIX is zero, arming pending=1 and resetting time=0. Release returns both video states to 1fcc01 and leaves both CPU states equal. After the delayed false hit, real IN reads differ and A diverges. No load, CPU DIRSet, internal gun forcing, input perturbation or unrelated timing fix is involved. cpu.log contains exact capture/release and architectural evidence.

**16. Resynchronization and fix scope.** A global harmless-resynchronization proof is impossible: the false pending hit persists until it generates a guest-visible pulse during VBlank, and actual CPU execution observes it. A simple reset/normalization on load or serialization alone cannot fix a save-only corruption. Correct freezing must at least suppress the ungated hit arm/time reset during transport. The 74-bit conservative local-state inventory should be reviewed for exact restore versus proven reconstruction. Whether the additional load-time histories can always converge before the first real post-load CPU observation has not been proved here; interface-level tail differences must not be used alone to demand a format change. A freeze-only fix might retain v7. If exact new fields are needed, validated presence/version metadata and fresh unused words would be appropriate, potentially v8. No layout or production fix is selected or implemented in this branch.

**17. Existing regressions.** Sixteen unchanged regression logs pass: F07 SMS/GG eight HCounter boundaries each, ten controller cases and real dual-VDP DDRAM; F08 2560 short +160 production-timeout replays and 13 DDRAM cases; F09 4096 short +64 production-timeout replays, 100000-clock ordinary/shared-timer equivalence and 21 DDRAM cases; F10 896 directed +6712 complete-phase +224 mode-transition cases, 1000000-clock ordinary equivalence and 22 DDRAM cases. Investigation copies do not alter shared production RTL or existing test sources. results.json validates 59 canonical evidence/regression logs with hashes; sources.json records the committed baseline and source hashes.

**18. F06.** Sega SRAM remains unresolved and outside this investigation. No SRAM policy or payload change was made.

**19. F07–F10 unchanged.** All 136 committed-F10 production/settings files match the prior successful build sources after line-ending normalization. git diff and staged diff are empty. Existing fixes were only regression-tested, not changed. No F01–F10 or F12–F16 fix was attempted. The real-CPU save-only proof specifically avoids interpreting CPU load/microcycle behavior as F11.

**20. git diff --stat.** No output: tracked diff is empty. All newly authored investigation source/evidence is under tests/savestate_lightgun. No Quartus run or new Quartus artifacts were created for this investigation; pre-existing build trees remain untouched.

**21. git status --short.** Branch investigate/savestate-lightgun, HEAD 77147af4b1c0657d99bfaa840bcb17ad0be5d658 (committed F10).

```text
?? tests/
```

The untracked tests tree existed before this task and now also contains this investigation. Nothing was staged, committed, pushed or submitted as a PR.

**22. Final classification: CONFIRMED - FIX REQUIRED.** The exact technical reason is that raw HDE/VDE still drives the lightgun hit comparator while emulated pixel time is frozen. A naturally reachable accepted save point leaves local counters matching the target; transport then sets sensor_pend and resets sensor_time, and real CPUs executing the same future program observe a false TH pulse. F11 is not a justified exclusion and does not depend on another unresolved finding. Stop at this evidence; a separate authorized fix task must choose the minimal freeze/restore design.
