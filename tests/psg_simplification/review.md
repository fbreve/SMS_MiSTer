# Isolated PSG savestate simplification: functional qualification

**Candidate C merits a matched physical comparison; Candidate B does not merit further qualification toward adoption. Neither is approved for production.** C preserves the architectural stereo/FM controls while dropping exact generator replay. B demonstrably loses persistent control behavior. Both deliberately lose deterministic tone/noise history. No Quartus or hardware test was run.

Baseline: **8443a0d19a88aff7a5900011bccf386daf146945**. Qualification completed October 29, 2026, America/Sao_Paulo.

| Candidate | Branch | Isolated worktree | Result |
| --- | --- | --- | --- |
| B: minimal PSG | `experiment/psg-b-minimal` | [B](B/) | Basic PSG1/PSG2 configuration restores; persistent stereo/FM-control regression confirmed |
| C: architectural controls | `experiment/psg-c-controls` | [C](C/) | Basic configuration plus stereo/FM controls restores; suitable for measurement of the deliberately weaker audio contract |

Both branches still point to the exact baseline; their RTL changes are **uncommitted**. Master, the primary workspace and all pre-existing branches/experiments were preserved.

## Diff boundary and preservation

Each candidate changes exactly nine paths: `SMS.sv`, `rtl/system.vhd`, `rtl/savestates.sv`, `rtl/AudioMix.vhd`, and JT89's Verilog top, VHDL component package, tone, noise and volume modules. Reviewable patches: [B.diff](B.diff), [C.diff](C.diff). Source totals: B **44 added / 369 removed** lines; C **54 added / 359 removed**. These line counts include comments, interface changes and formatting, not gate counts. Final `git diff --check` passes for both. Two restored declarations had historical trailing whitespace removed after simulation; the verifier checks token equality with the tested PSG sources and controller.

The implementations remove only the extension from `a196cf11`, then add candidate-specific format checks and, for C, architectural controls. This is **not a revert of merge 5ae6260d**. `a196cf11`'s immediate parent already includes the independent **998d8aa6** DDRAM fix. The registered request/acceptance machinery, byte-7 preservation, transport tail and BIOS size-only publication were compared against protected master. Both command-preview and sequential BIOS publication paths are retained. Basic PSG configuration still captures after the frozen pipeline drain, avoiding restoration of the older pre-drain capture boundary.

All **194 other tracked blobs** match the baseline, allowing only Git checkout CRLF normalization for text. This includes CPU/VDP/mapper/cartridge corrections, native JT89 mixer, VM2413, source manifests and constraints. Within the mixed integration files, the diff preserves normal decode, memory paths, native audio gating/mixing, and #219's removed unused reset interface. The seven extension FSM states, PSGX descriptor/payload paths, quiescence assertion/export, divider restoration and mixer release override are removed. Existing global non-audio legacy-layout branches remain; strict new headers prevent importing those old layouts. No PSGX fallback remains.

[Verification](results.json) rechecks **22,031 protected source/report/input files**, primary HEAD/branch/tracked and staged differences, and every pre-existing ref. The only new refs are the two requested branches. The original `rtl/VM2413/phasememory.vhd` edit and untracked tests remain unchanged. [Input manifest](input_manifest.json) records original Git blobs and raw candidate hashes. Prior build databases and binaries were not used as writable test locations.

## Format contract

The slot allocation and all non-audio offsets remain unchanged: 96 KiB, size field 24,574 32-bit words. Version 1 is encoded in distinct cartridge/BIOS magic values:

| Field | B v1 | C v1 |
| --- | --- | --- |
| Cartridge magic | `534D4201` | `534D4301` |
| BIOS magic | `53424201` | `53424301` |
| Word `00e` | configuration `[51:0]`, System E `[52]`, reserved zero `[63:53]` | configuration `[51:0]`, stereo `[59:52]`, FM detect `[62:60]`, System E `[63]` |
| Word `018` | Existing PSG2 configuration container | Same |
| Words `020..024` | Not written or interpreted | Not written or interpreted |

The native 56-bit configuration interfaces remain; only 52 bits carry actual configuration. Unallocated PSG2 container padding keeps its historical behavior and is not reinterpreted as metadata. No CRC or whole-slot power-loss atomicity is introduced or claimed.

Wrong size, production/other-candidate/future magic, wrong game, wrong System E mode, and B's nonzero reserved PSG bits are rejected before live restore or RAM/CRAM writes. Cross-BIOS/cartridge identity is separated by magic. Unsupported images are not silently loaded with a different interpretation. Backward compatibility, including production files, is intentionally absent for these isolated experiments. Invalid-header checks are mirrored in the DDRAM command preview and the sequential FSM.

## Functional results

ModelSim-Altera **10.5b** was used. Final qualification checks both PASS markers and absence of Error/Fatal diagnostics; shell exit code alone is insufficient with this simulator. All final runs passed their stated contracts.

| Test | Result and evidence |
| --- | --- |
| Existing protected-master replay | Original 128 cases pass: eight noise controls × sixteen divider phases, 20,000 compared cycles each. [Log](sim_A/replay.log) |
| Strengthened master replay | Same exact replay passes after 40,000 continuously enabled warm-up clocks. [Log](strong_A/strengthened.log) |
| Strengthened B/C replay | Configuration remains exact. Each has output differences in **128/128 cases**: **2,454,216 / 2,560,000** compared cycles, including **113,608** differences in the combined final-1,000-cycle windows. Raw generator/divider history differs throughout. [B](strong_B/strengthened.log), [C](strong_C/strengthened.log) |
| Complete B controller SAVE/LOAD | **16,710,342 clocks**, eight saves and sixteen loads; PSG2 restored eight times; eight safe rejections; 115,104 DDR reads, 57,532 writes and 2,109,739 busy clocks. [Log](sim_B/controller_final.log) |
| Complete C controller SAVE/LOAD | **16,689,121 clocks**, eight saves and sixteen loads; PSG2 restored eight times; seven safe rejections; 115,089 reads, 57,532 writes and 2,104,516 busy clocks. [Log](sim_C/controller_final.log) |
| Controller coverage | SMS/System E, BIOS/cart, slots 0–3, repeated loads and replacement saves, actual PSG writes/configuration restoration, all eight FM-detect values, asymmetric stereo, primary/secondary/passive VRAM and WRAM/NVRAM data patterns; pseudo-random busy/response latency. Stalled requests must retain command/address/data/byte enables. Malformed loads must not issue any architectural restore or RAM/CRAM write. |
| Native operation, SS inactive | **198,354 exact checks** across A/B/C; dual PSG, stereo samples, AudioMix outputs, controls, resets and clock-enable/freeze sequences. 197,861 nonzero-audio checks, 146,792 unequal-stereo checks, 2,662 control changes. Tone values 0–7 and 1023 plus all eight noise controls. [Log](native/native.log) |
| Architectural consumers | **16,000 checks**: C matches master controls and the extracted native FM/PSG gating/routing expressions. B retains the changed FM-detect value and swaps the intended stereo side throughout the observation. Exercises SMS/GG/System E and detect values 0–7. [Log](native/controls.log) |
| Transient vs sustained history | Six tone<6/sample-playback cases show stale-sample differences for **72 test clocks**, then equality through clock 999. Eight isolated noise modes plus a tone-only case retain waveform differences in the later 40,000 clocks of a 50,000-clock observation. [Log](native/focused_qualified.log) |
| System interface analysis | Current production `system.vhd` and its instantiated VHDL dependencies analyze for both candidates with documented simulator syntax adapters. [B](analyze_B/system_analysis_pass.log), [C](analyze_C/system_analysis_pass.log) |

**A limitation in the retained replay was found.** Its original warm-up gives only about 29 generator ticks. Tone/noise counters initially decrement from zero and need 1,024/2,048 ticks to wrap. An adapted configuration-only replay therefore produced internal differences but no output differences over its short suffix. This was a stimulus limitation, not evidence of audio equivalence. Original artifacts are untouched; [diagnostic](diagnose_B/diagnose.log) and [strengthening script](strengthen_replay.js) retain the explanation and changed stimulus.

### Interpretation

- **Persistent functional regression:** B can restore the wrong stereo routing and FM/PSG selection, including FM gating and software-visible detect state, until software rewrites the controls. C prevents that specific regression. These are real state/consumer defects, not just cycle-comparison failures.
- **Bounded sample transient:** the isolated stale-volume sample cases settle after 72 clocks in the tested enable schedule. This is a measured example, not a universal settling bound or proof of an audible click.
- **Sustained waveform divergence:** both candidates retain current tone/noise history rather than the saved history. The stronger mixed and isolated tests demonstrate output differences beyond the immediate restore pipeline. They must not be described as a universally short transient. Audibility, musical impact and perceptual acceptability remain unmeasured.
- **Cycle-only differences:** divider/counter/polarity/LFSR state can differ while selected output samples match, as the weak replay demonstrated. Those mismatches alone do not establish audibility.
- **SS-inactive operation:** no difference was observed in the exact native audio/control comparison. This is subsystem qualification, not formal proof or full-game certification.

The controller uses real PSGs, AudioMix and the verbatim extracted `system.vhd` audio-control process, with synthetic CPU/VDP snapshots and constant RAM test patterns. The controls test uses native routing expressions and a fixed nonzero FM source; it does not certify OPLL waveform restoration. No CPU/ROM/full-game, host SD persistence, real DDR controller, hardware listening, or physical cable test is claimed. Existing master savestate limitations outside this scope remain.

Simulation adaptations: controller declaration ordering for old ModelSim; explicit `entity work` syntax for existing VHDL shorthand; VM2413 scalar subtype range spelling and missing metavalue case alternatives; VHDL-93 for VM2413's `Release` identifier. [B adapters](analyze_B/adapters.json), [C adapters](analyze_C/adapters.json) record analysis-only edits. AudioMix toggle receives a simulator deposit of zero because its existing VHDL declaration lacks initialization. Candidate RTL is not changed for these adaptations. Early fixture-development failures and compiler diagnostics are retained separately; the final logs linked above qualify the final source.

## Complexity and storage widths

These are **source-level widths**, not measured flip-flops, ALMs, timing or routing savings.

| Item | Master | B | C |
| --- | ---: | ---: | ---: |
| Basic PSG controller snapshot + restore containers, both PSGs | 224 bits | 224 | 224 |
| Additional audio data banks | 416 bits | 0 | 22 |
| Additional audio flags/index/strobes | 6 bits | 0 | 0 |
| Total extension-specific controller register declarations | **422 bits** | **0** | **22** |
| Removed declaration bits versus master | — | **422** | **400** |
| Extra descriptor/payload DDR64 words, SMS/GG / System E | 3 / 5 | 0 / 0 | 0 / 0 |
| Extension-specific FSM states | 7 | 0 | 0 |

Master's 416 data bits are two copies of 192-bit dual-PSG payloads plus divider/control/mixer phase (16 bits per copy). Its six bookkeeping bits are presence flag, three-bit payload index and two strobes. C keeps only an 11-bit control snapshot and 11-bit restore register and reuses `psg_set`. Both remove generator/sample/divider restore selections from both PSGs and the mixer phase mux. Native counters, LFSRs, samples, divider registers, both PSG instances and mixer arithmetic remain.

Useful serialized configuration/control bits are B 53 (SMS/GG) / 105 (System E), and C 64 / 116, including one mode bit. The DDR slot and firmware file allocation remain 96 KiB. No M10K or FPGA savings follow directly from these counts; synthesis may trim unused bits and change sharing/packing.

## Recommendation and stop

**C: GO for a separately authorized matched master-versus-C two-seed physical comparison.** Keep exact device/tool/dependencies/build date/QSF/SDC/settings and compare both seeds, including placed/needed area, mapped/fitted registers, memory, routing, setup/hold and warnings. C preserves the meaningful architectural controls while substantially reducing source-level restore machinery. Its loss of exact audio history is an explicit tradeoff, not a correctness-equivalence result.

**B: NO-GO for adoption-oriented measurement.** Keep it as a diagnostic lower-feature comparison; its persistent control loss is already demonstrated. The 22-bit controller difference between B and C is not an area estimate or justification for accepting that loss.

Before any production decision on C, hardware A/B listening remains necessary for sustained tones, noise, sample playback, GG stereo, dual PSG and repeated loads. No Quartus process, synthesis/fit/STA, commit, push, merge or PR was performed. Stop after this functional report.

Reproduction and evidence: [instructions](reproduce.md), [results](results.json), [verification script](verify.js), [preservation ledger](preservation_before.json), [input manifest](input_manifest.json).
