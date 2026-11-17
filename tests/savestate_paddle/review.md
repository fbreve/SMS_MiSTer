# F10 paddle functional savestate review

**Recommendation: READY TO COMMIT.** Only F10 was addressed. No files were staged, committed or pushed; no PR was created.

**1. Exact root cause.** The paddle's entire 32-bit local state was omitted from savestates. Its two always_ff processes ran on raw clk_sys throughout savestate transport. Current output can contain an old low nibble or a copied old high nibble; later rising TH uses cached high bits rather than current position. Export TH history and JP shared divider/TR alternation also stayed on the discarded timeline. VBlank does not canonicalize these states. The historical matrix labels this Paddle row S073; the request calls the same F10 finding S072.

**2. Complete persistent-state inventory.** A = preserve; B = reconstruct; C = external; D = absent/dead. No unresolved E items remain.

| Item | Bits | Class | Reason |
|---|---:|---|---|
| P1/P2 `paddle_N_nib` | 4 each | A | Currently driven nibble, sometimes a past low sample, sometimes copied high sample |
| P1/P2 `paddle_N_nib_q` | 4 each | A | Cached high nibble; a later rising TH edge does not sample current position |
| P1/P2 `paddle_N_tr` | 1 each | A | Guest-visible TR; P1 TR also selects the shared JP alternation branch |
| P1/P2 `joyX_th_out_q` | 1 each | A | Export-mode edge history; held in JP mode and matters if mode changes |
| `cnt_en16khz` | 12 shared | A | Next JP transition depends on exact divider phase |
| `en16khz` | combinational | B | Equality to zero, no additional state |
| TH rise/fall wires | combinational | B | Boolean functions of restored history and existing restored I/O output |
| `joya`/`joyb` paddle pin cache | derived | B | Existing accessory process recomputes every host clock, including freeze; 255-clock restore guard settles it |
| TH/TR outputs / I/O direction and output control | existing I/O payload | A (already saved) | Restored by existing I/O load path before paddle normalization |
| `paddle_0/1`, `joy0_x/joy1_x` | 8 each | C | Host/user input; sampled transform `~axis[7],axis[6:0]` becomes local history only after assignment to nibble registers |
| `jp_region`, `paddle_joy`, `paddle_en` | config | C | Current region and accessory configuration, like MD6/Master Tap selection; future configuration identical in replay |
| `ce_cpu`, `ce_pix`, global divider | unrelated | C / existing machine timing | Paddle runs directly on clk_sys; none drives its divider or protocol |
| reset | none in original block | D for paddle | Original protocol has no reset branch; reset must retain ordinary behavior |
| extra sampled position/mode/low cache/selector | absent | D | No additional registers exist in the production block |

The A paddle fields total exactly 32 bits: 16 cached/current nibble bits + 2 TR + 2 TH histories + 12 divider. Existing I/O output/direction state is already serialized separately. The output-cache process recomputes paddle pins every host clock and settles well before the existing release guard ends.

**3. External input versus state.** HPS paddle_0/1 and joystick axes are external inputs. Neither raw position nor status/configuration is serialized. Once either physical position or the sign-converted joystick axis has been sampled into nib/nib_q, its stored bits are local state and are preserved even when current external position differs. Both replay paths receive identical future input and guest I/O sequences.

**4. Pre-fix dynamic evidence.** before.log was recorded before any production edit, using extracted committed production logic. Five cases show observable divergence: cached high nibble, nib != nib_q, save between TH phases, JP alternating phase, and raw-divider progression during freeze. The first three criteria share the same export setup T, repeated as cases 0-2: saved state 00d05ca3, later state 00f02976, immediate pins 126/183; following the same future rising TH yields pins 047/0aa and caches 2/7 versus 5/A. JP case 3 saves 001355aa and advances to 00105ca3 during one 3356-clock interval; case 4 saves 080355aa and advances to af405ca3 during 100000 frozen clocks. Future pins differ 081/37e in both.

The subsequent full-DDRAM baseline reproduction uses committed F09, production I/O and actual controller transport, with a naturally held reference. Exact observed results:

| Baseline case | Saved paddle state | Guest DUT/reference | Frozen save/load clocks |
|---|---|---|---|
| Export cached sample | 0c405ca3 | 56 / 13 | 28065 / 940429 |
| JP high phase, joystick source | 09b355aa | 16 / 7a | 28065 / 940429 |
| JP low phase, physical source | 09005ca3 | fe / 13 | 28065 / 940429 |

See before.log and before_full.log for exact live/reference state and outputs. References never receive restored paddle fields. Since original RTL has no reset branch, fixtures select one legal initial divider value, then establish caches/TR/history through real TH transitions before saving.

**5. 16 kHz architecture.** clk_sys is 53.693175 MHz, from the unchanged PLL. A shared 12-bit counter increments every host clock and wraps after 3355: 3356 meaningful phases, about 15999.158 events/second. en16khz is count==0; JP consumes the old zero on the next clock. A full low/high alternation is 6712 clocks. No CPU/pixel enable drives this local timer. Export protocol ignores the divider, but future JP operation makes its phase relevant.

**6. Freeze decision.** Both paddle processes now hold during ss_freeze, with restore taking priority. This makes save-only transport invisible and prevents JP from sampling changing external input while the emulated machine is paused. Restoring a word while allowing subsequent guard-time progression would introduce extra protocol time; the counter, edge history and cache must remain held until release. Full-state/pin comparisons against a held reference prove the selected semantic. Ordinary branch and divider expressions are unchanged.

**7. Variants and ports.** Export mode has independent P1/P2 TH-edge histories and cached nibbles. JP HPD-200 shares the divider and P1-TR-controlled alternation; it updates both port TR outputs on each event. Both physical-paddle and joystick-axis sources are supported. Both ports' TR bits remain independently representable, including histories inherited from a mode change. Protocol logic still runs normally when disabled; serialization does not introduce a new enable/reset policy.

**8. Files changed.** Production: SMS.sv adds the 32-bit bus, frozen local state and restore/legacy sampling; rtl/savestates.sv adds capture, validated transport and v7 capability handling. New evidence is under tests/savestate_paddle. Existing untracked regression generators are updated to recognize the current writer tag and retain explicit historical formats; historical logs remain intact. The report is also copied to output_files/mapper_banking_review/paddle_review.md.

**9. Exact representation.** Existing slot stride, header size and payload locations are unchanged. New word 0x027: [31:0]=50414437 (PAD7), [63:32]=paddle state. Within that state: [31:20] divider, [19] P2 TH history, [18] P1 TH history, [17] P2 TR, [16] P1 TR, [15:12] P2 cached high, [11:8] P2 driven nibble, [7:4] P1 cached high, [3:0] P1 driven nibble. Presence requires v7/count3, exact PAD7 magic and divider <=3355. No old unused bits are reinterpreted.

**10. Version decision.** v7 is required to distinguish present historical paddle state from older uninitialized words. The existing video extension tag becomes 484307 with unchanged count 3 and unchanged lower HCounter/video fields. Older HCounter, GG, MD6, EEPROM, SC RAM and Master Tap descriptors/payloads retain their original locations and expressions.

**11. Legacy behavior.** Untagged, v1, v2, v3, v4, v5, v6 and old-64KiB snapshots contain no paddle history. At the late restore strobe they all set divider=0, TR=0, TH histories=current restored I/O TH, and freshly sample current physical position or converted joystick axis into both nibble pairs. This explicitly initializes from current input rather than inventing a historical position. Export waits for subsequent real TH edges; JP's first released zero-count event presents the newly sampled high nibble and raises TR. Unsupported/future tags, invalid count, bad PAD7 magic and counter 3356/4095 use the same normalization. Valid v7 restores every bit exactly. v6 still restores Master Tap exactly while normalizing only the absent paddle fields.

**12. Directed results.** PASS: 896 directed combinations cover positions 00, ff, 80, a3, 5c, 01, fe; both regions and sources; low/high nibble phases; independent TH levels and pending edges; immediate reads/edges; long idle; repeated restore; physical/joystick legacy normalization. An additional 224 JP-to-export cases cover inherited independent TR state. The 1,000,000-clock baseline equivalence test changes both TH pins, inputs, region and source while comparing all state and pins each clock. Production I/O reset, disabled routing and later paddle activation also pass the routed integration cases. No ordinary reset behavior was changed.

**13. Complete timing-phase results.** PASS: every count 0..3355 in both JP alternating states, 6712 cases. Each runs more than a full subsequent alternation and compares all 32 state bits and both port outputs every future clock. Combined paddle replay total: 7832 cases. Testbench clock is 10ns, with production divider/cycle counts unchanged. Frozen full-save durations span 28,067..48,084 clocks (0.523..0.896 ms at hardware clock); loads span 940,357..953,334 clocks (17.514..17.755 ms). A pre-fix load advances roughly 280.20..284.07 divider events; the baseline full-DDRAM test demonstrates the resulting divergence. Fixed state remains held and replay matches.

**14. Full DDRAM results.** PASS: 22 main cases per no-stall/fixed-stall/seeded-random-stall profile (66), plus five routed cases per profile (15), plus nine simultaneous Master Tap+paddle cases (export and both JP phases under all stall profiles), total 90. Includes cached samples, nontrivial divider phase, TH/TR history, both JP phases, accepted-point pending edge, repeated operations, untagged/v1-v6/old64, future/unknown tag, invalid count/magic/divider and disabled paddle. All final cases use the actual SMS accessory output process and actual io.vhd controller reads, with the top-level active-low pin order verified against SMS.sv and the MD pass-through mapping. The earlier fixture pin-order error was corrected and all 90 cases rerun without a production change. The controller executes its full 900000-clock flush and release guards. Only UI cooldown is bypassed. Older payloads are checked as canaries and through their existing functional regression suites.

**15. Accessory interactions.** MD6 routing explicitly disables MD protocol for paddle, Master Tap, raw serial, lightgun, GG and System E. Master Tap and paddle configuration bits are independently representable: the existing production accessory process computes Tap/ordinary outputs first, then paddle overwrites only its established five pins per port. That priority is unchanged; state machines remain separate. The full routed tests cover ordinary/disabled pins and enable after restore. Nine supplemental simultaneous Master Tap+paddle cases restore both independent payloads and compare both state machines and guest reads in export and both JP phases, with all three stall profiles. Master Tap/disabled/raw-serial ordinary equivalence (100000 clocks), MD6 replay/DDRAM and GG replay/DDRAM all pass. Static comparison proves the complete routing process is byte-identical to F09.

**16. Existing regression results.** All 64 required/supplemental simulation/static logs validate successfully:

| Suite | Passing evidence |
|---|---|
| F07 HCounter | Eight boundary cases each for SMS/GG, ten controller cases, two real System E VDP DDRAM cases; original field/static checks |
| F02 GG | 24 serial/NMI replay cases; 14 DDRAM cases each with zero and deterministic stalls; 24-field/114-bit packing checks |
| F08 MD6 | 2560 short-timeout + 160 production-timeout replays; 13 full-DDRAM cases |
| F09 Master Tap | 4096 short + 64 production-timeout replays; 63 DDRAM cases, including explicit v6 compatibility; ordinary/shared timer equivalence |
| F03/F04 EEPROM | 6642 protocol replays; 69 full-DDRAM cases across three stall profiles including explicit v4/v5/v6; actual RAM and SD persistence/exclusion |
| F05 SC RAM | 171 full-DDRAM cases across all three sizes/stall profiles including v5/v6 compatibility; full prefixes, tail canaries, active-write freeze, SD-port readback, dirty/persistence and negative controls |
| PSG | 128 cases, all eight noise controls and 16 divider phases, 20000 compared future clocks per case |
| Original audit/controllers | Original IO/EEPROM/MD dynamic fixtures and audit/static evidence pass |

simulation_results.json records log hashes, markers, counts and transport bounds. sources.json and static.log verify the complete source/settings scope against F09. The independent prior finding implementations are unchanged.

**17. F06.** Sega SRAM coverage remains intentionally unresolved. Current visibility/size predicates and bank ownership rules are unchanged. No always-save backing policy or bank fix was introduced.

**18. F11.** Lightgun state and implementation remain unchanged. Paddle divider/history have no uses outside the paddle block, so F10 is isolated. No other savestate finding was addressed.

**19. Quartus.** Full Analysis & Synthesis, fitter, assembler and timing analysis succeeded using Quartus Prime Lite 17.0.2 Build 602, device 5CSEBA6U23I7, unchanged seed/settings/constraints. The build was started after the complete initial simulation/regression matrix passed. Nine supplemental combined-accessory cases also passed against the same unchanged RTL during synthesis. The primary baseline is the established successful committed F09 build; all 136 source/settings hashes match the pre-edit baseline copy. Candidate build source hashes also match the final working tree.

**20. Timing.** Worst constrained setup slack: 0.412 ns (F09 0.687 ns). Worst hold slack: 0.242 ns (F09 0.205 ns). Negative-slack/TNS timing categories: 0. No unrelated timing optimization was performed.

**21. Resources relative to committed F09.**

| Resource | F09 baseline | F10 candidate | Delta |
|---|---:|---:|---:|
| ALMs | 27,083 | 27,150 | +67 |
| Fitted registers | 36,542 | 36,556 | +14 |
| Synthesis registers | 35,547 | 35,616 | +69 |
| RAM bits | 3,809,858 | 3,809,858 | +0 |
| RAM blocks | 487 | 487 | +0 |
| DSP blocks | 39 | 39 | +0 |

**22. Warnings.** New normalized warnings/critical warnings: 0. Baseline/candidate distinct numbered warnings: 84/84; distinct critical warnings: 38/38. Tool-reported total candidate warnings: 100. Existing warnings are retained in the logs. Normalization removes source-line/path differences, not warning text. No new warning text was introduced.

**23. git diff --stat.** Tracked production diff only; the pre-existing untracked tests tree contains the new evidence as well as earlier findings' tests.

```text
 SMS.sv            | 25 ++++++++++++++++++++++++
 rtl/savestates.sv | 58 +++++++++++++++++++++++++++++++++++++++++++++----------
 2 files changed, 73 insertions(+), 10 deletions(-)
```

**24. git status --short.** Branch fix/savestate-paddle, base 52fb7496aeeaf2227e332194e06ec2cdfcf43932.

```text
M SMS.sv
 M rtl/savestates.sv
?? tests/
```

Nothing is staged; generated Quartus artifacts remain ignored. The complete production diff is saved in production.diff. Source/static checks prove that the ordinary paddle core expressions, all non-paddle SMS logic, all prior payload writes and the other 134 source/settings files remain unchanged. The version capability predicates only add v7 support while retaining all older cases.

**25. Recommendation.** **READY TO COMMIT**: F10 is isolated, fully serialized, frozen and dynamically verified, legacy behavior is deterministic, required regressions and full build pass, timing is positive and no new warnings were introduced. This report precedes any commit, push or PR, as requested.
