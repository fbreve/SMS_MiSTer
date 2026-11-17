# G06 fix gate — NOT READY TO COMMIT

This is a scope-decision gate report, not a completed implementation. Production RTL remains unchanged. G06 is **FIX INCOMPLETE**. The diagnostic full-state ceiling is deliberately not a selected minimal representation or a new savestate format. Its remaining LOAD mismatches prevent the simulation gate and therefore prevent Quartus.

## Blocking contract conflict

The request says, “Do NOT investigate or fix G08, G10-G12, F01 or F06.” Phase10 also requires identical collision timing, status clear behavior and guest-visible CPU results against uninterrupted execution. The full-state ceiling proves that source preservation alone cannot satisfy that oracle on the existing restart schedule.

At native host cycle1553894 the complete650-bit diagnostic side record is restored exactly. After release, **1999 aligned native clocks have identical ce_vdp, ce_pix, x, y and all650 sprite/collision-delay bits**. The comparison retains irrelevant X fields as X rather than treating them as initialized image proof. The enabled two-sprite data, live collision source and delay trace are not lost. CPU bus timing differs: the reference starts status reads at x26,60,94,128,162,196 on y168; LOAD starts them at x28,62,96,130,164,198. The first two pixel enables after LOAD have `NMIReplay=1`, while the reference is already past the historical fetch. This is a two-pixel CPU/VDP observation offset, not a residual difference in the captured sprite source or its enabled evolution.

| First resumed clocks | Uninterrupted | Full-state LOAD |
|---|---|---|
| Beam x10, first pixel enable | CPU bus A004C, replay0 | CPU bus A0090, replay1 |
| Beam x11, next pixel enable | A004C, replay0 | A0090, replay1 |
| Beam x12, intervening VDP enable | A0091, replay0 | A004C, replay0 |
| First status-read assertion | x26/y168 | x28/y168 |
| Collision-sensitive status-read assertion | x128/y168 | x130/y168 |

Here A means the CPU **address bus**, not accumulator A. A read-assertion's DI column can still contain the preceding value before the next VDP sampling edge; it must not be mislabeled as the completed IN result. The original pixel-sampled status oracle remains authoritative for its six bus differences.

Evidence: [native-clock analysis](trace_analysis.json), [LOAD trace](prototype/trace_collision/cycles.csv), [uninterrupted trace](prototype/trace_reference/cycles.csv), and [assertion/runtime log](prototype/trace_collision/dut.log). The analysis compares reference cycle607472 onward against LOAD cycle3345972 onward; CE and beam schedules match exactly. It finds1549 address-bus,1190 RD and240 IORQ differences in the same1999-clock interval.

A narrow next step would make the bounded historical CPU replay complete before the restored VDP's post-T evolution resumes, then release coherent guest execution. That requires review of the shared prepare/release ordering and its G01/NMI/mapper dependencies; it is not an extra sprite payload bit. No such production change or wider G10 investigation has been made. A scope question asks whether that narrow shared ordering change is authorized, or the explicit exclusion must remain and implementation stop as incomplete. No oracle has been weakened to declare a pass.

## Evidence and reproducibility

Run commands from the repository root using PowerShell with execution-policy bypass for the scripts. Node generators create observation-only local adapters; do not substitute them into production.

```powershell
& 'C:/Program Files/nodejs/node.exe' tests/savestate_g06_vdp_sprites_fix/prepare_reproduction.js
powershell -NoProfile -ExecutionPolicy Bypass -File tests/savestate_g06_vdp_sprites_fix/reproduction/run.ps1 -Compile
powershell -NoProfile -ExecutionPolicy Bypass -File tests/savestate_g06_vdp_sprites_fix/reproduction/run.ps1 -Sprites 9
& 'C:/Program Files/nodejs/node.exe' tests/savestate_g06_vdp_sprites_fix/prepare_prototype.js
& 'C:/Program Files/nodejs/node.exe' tests/savestate_g06_vdp_sprites_fix/prepare_trace.js
powershell -NoProfile -ExecutionPolicy Bypass -File tests/savestate_g06_vdp_sprites_fix/prototype/run.ps1 -Compile
powershell -NoProfile -ExecutionPolicy Bypass -File tests/savestate_g06_vdp_sprites_fix/prototype/run.ps1 -Sprites 9
powershell -NoProfile -ExecutionPolicy Bypass -File tests/savestate_g06_vdp_sprites_fix/prototype/trace.ps1 -Sprites 9 -Proto 0
powershell -NoProfile -ExecutionPolicy Bypass -File tests/savestate_g06_vdp_sprites_fix/prototype/trace.ps1 -Sprites 2 -Proto 1
& 'C:/Program Files/nodejs/node.exe' tests/savestate_g06_vdp_sprites_fix/analyze_traces.js
```

Generators overwrite their own generated adapters. Preserve completed evidence before regenerating. Diagnostic runs use independent recorded uninterrupted references from the source investigation. The new native-clock reference trace is supplementary. Original witnesses retain the original default eight sprite slots; production uses 64 and is not validated by those witnesses alone.

The complete field inventory and proposed categorization are in [design.md](design.md), with exact declarations/assignments/consumers in the unchanged [source inventory](../savestate_g02_g06_vdp/inventory.json) and [state behavior inventory](../savestate_g02_g06_vdp/state_behavior.md). Tentative categories are explicitly tentative; no omission proof is claimed complete.

## Required report items

| # | Obligation | Result at this gate |
|---|---|---|
| 1 | Baseline HEAD | `8ffd15e2a7e530c0d77b07c6eeae3e8dc0aa0c8a`; branch `fix/savestate-g06-vdp-sprites`. |
| 2 | Baseline format | v13. |
| 3 | Original SAVE-only overflow failure | Reproduced unchanged: 16 overflow-flag samples, 2 status-read samples, 34 CPU A samples and 34 guest-store samples differ in the 1000-pixel suffix. [Log](reproduction/overflow9/dut.log). |
| 4 | Original repeated-LOAD collision failure | Original two-sprite fixture repeats lost first-line collision. Per completed replay: 38 flag samples / 6 status-bus samples differ. [Log](reproduction/dut.log). |
| 5 | Reproduction status | Both exact witnesses complete. Three LOADs each reproduce 38 collision / 6 status samples (114 / 18 total). No production edits preceded these runs. |
| 6 | First divergent SAVE-only state | Host cycle 609932, raw beam x256/y168: `line_overflow` changes 1→0 while frozen. Cycle 610532, x486/y168: held evaluator overflow re-arms durable overflow flag 0→1. [Native trace](prototype/trace_overflow/cycles.csv). |
| 7 | First lost LOAD state | Original restore clears enabled cached sprites and shifters at the VDP restore strobe. Their historical X120 event on the restored y168 line remains ahead; no scanner restart occurs until x257. The raw capture/restore packet diagnostic separately checks the full-state ceiling. |
| 8 | Shared or distinct roots | **TWO DISTINCT ROOT CAUSES**: missing transport hold in overflow bookkeeping; discarded historical sprite source on LOAD. |
| 9 | Complete G06 inventory | See linked inventory and design table. Includes evaluator, cached positions/patterns/enables, all shifters, registered color/collide/overflow, and shared 14-bit collision delay. |
| 10 | Freeze inventory | Evaluator and shifters stop with gated CEs. Overflow consumer uses `ce_vdp=0` and raw beam, so CE gating alone does not stop it. Capture is post-accepted tick at ARM. LOAD applies while frozen; raw video keeps advancing until alignment. |
| 11 | Accepted-boundary live state | GG crop allows VBlank at y168 while underlying collision qualification is active. Enabled current-line cache remains live. Scanner WAITING/refill arguments require complete 64-slot, mode and first-enable proof before exclusion. |
| 12 | Solution A | Local actual-freeze guard fixes demonstrated SAVE-only failure without payload. Cannot recover missing historical source. |
| 13 | Solution B | Existing flags alone cannot generate future collision/pixels. Adding only metadata is not a complete source representation. |
| 14 | Solution C | Requires field-by-field omission proof and temporal first-consumer proof; neither is complete. Diagnostic ceiling is 650 bits for 8 slots / 4794 for 64, including collision delay. |
| 15 | Solution D | Existing VBlank is disproven as canonical. Stronger boundary needs all-mode refill, legal mode-write, System E and Pause/liveness proof; not selected. |
| 16 | Solution E | Freeze correction plus proven minimal state is a candidate, not a finalized production design. |
| 17 | Chosen design | None finalized. Full-state diagnostic measures representation ceiling before production changes. |
| 18 | Sufficiency | Not established for a minimal representation. Full-state identity holds through1999 aligned clocks, but exact LOAD status still fails because CPU reads are two pixels later. Passing source restoration alone is insufficient. |
| 19 | Format | Production retains v13 because no implementation is applied. Any additional historical payload must use v14 tagged extension as requested. |
| 20 | Legacy handling | Production policy unchanged. Future design must normalize missing history deterministically and cannot claim to recover unavailable historical collision/cache. |
| 21 | Production changes | None. Only new diagnostic files under this test directory. |
| 22 | Post-fix SAVE-only | No production fix. Test-only actual-freeze guard passes strict full136-bit VDP/RGB comparison for the exact overflow witness, 1000 observations. [Prototype log](prototype/overflow9/dut.log). |
| 23 | Post-fix A/RAM | Same prototype passes exact A/RAM comparisons against the independent seven-column overflow reference. No masked line-overflow bit in this check. |
| 24 | Collision LOAD | Test-only full-state ceiling: 9 flag / 6 status-bus differences in one replay. **Fails mandatory equivalence.** [Prototype log](prototype/dut.log). |
| 25 | Three-LOAD result | Original reproduction completes three LOADs of the same image: each 38 collision / 6 status differences, 3000 observations total. Full-state prototype initially runs one diagnostic LOAD. No three-LOAD production pass. |
| 26 | Initialized matrix | Not executed for a production fix. Original initialized exact witnesses only; no matrix coverage claim. |
| 27 | Overflow | Original corruption reproduced; one test-only freeze correction passes. Broad post-fix overflow matrix pending. |
| 28 | Collision | Original loss reproduced; raw source preservation alone does not pass complete replay oracle. |
| 29 | First visible line | Not proven. Blank-line status witness is not a first-visible-pixel proof. |
| 30 | Legacy modes | Not proven by the Mode4 GG witness. Mode-dependent cache assignment paths explicitly prevent an assumed general refill proof. |
| 31 | Dual VDP | Not run. Distinct System E memory/activity independence remains required. |
| 32 | Boundary sweep | Not run. Requested x40 qualifies at x489/y168; accepted T x9/y168, ARM x10/y168 in exact witness. |
| 33 | Transport duration | One native transport duration tested for the freeze prototype. Varied stalls/durations remain required. |
| 34 | Perturbations | Original fixture's repeated running histories retained. Not a replacement for the required distinct SAT/pattern/register/history perturbation matrix. |
| 35 | Equal-image search | No new-format representation exists to test. Diagnostic side record is not a complete new-format image. |
| 36 | G02 | No production change or closure. Status-clear timing in the mandatory oracle remains a shared dependency to resolve. |
| 37 | G03 | No production change or closure. CPU status-read edge sampling remains baseline behavior. |
| 38 | G04 | Collision delay/status overlaps G06. Diagnostic ceiling preserves 14 delay bits to distinguish source loss from temporal observation. Any eventual shared production change needs G04 evidence reassessment; no closure here. |
| 39 | G05 | No production change or closure. Background pipeline is not included in the sprite side record. |
| 40 | F07 regression | Not rerun at this gate; production unchanged. Historical pass is not a new result. |
| 41 | F11 regression | Not rerun at this gate; production unchanged. |
| 42 | F12 regression | Not rerun at this gate; production unchanged. |
| 43 | G01 regression | Not rerun at this gate; production unchanged. CPU/context implementation remains committed baseline. |
| 44 | Run count | Seven completed runtimes,12000 pixel observations across SAVE/reference/LOAD suffixes, five diagnostic LOAD replays total. See ledger. Compile attempts and source-analysis commands are not simulation cases. |
| 45 | G06 classification | **FIX INCOMPLETE**. |
| 46 | Setup slack | No candidate Quartus run; committed baseline +0.483ns. |
| 47 | Hold slack | No candidate Quartus run; committed baseline +0.213ns. |
| 48 | Timing violations | Candidate unmeasured; committed baseline 0. |
| 49 | ALMs needed | Candidate unmeasured; baseline 27368/41910, 65.30%; no candidate delta. |
| 50 | ALMs placed | Candidate unmeasured; baseline 32684/41910, 77.99%; no candidate delta. |
| 51 | Registers | Candidate unmeasured; baseline 36831/167640, 21.97%; no candidate delta. |
| 52 | M10K | Candidate unmeasured; baseline 487/553, 88.07%; no candidate delta. No new inferred-memory claim. |
| 53 | Memory bits | Candidate unmeasured; baseline 3809858/5662720, 67.28%; no candidate delta. |
| 54 | DSP | Candidate unmeasured; baseline 39/112, 34.82%; no candidate delta. |
| 55 | New warning types | No candidate Quartus run. Diagnostic ModelSim missing-port/capacity warnings are fixture warnings, not candidate fit evidence. |
| 56 | git diff --stat | Empty for tracked production changes. Newly created tests remain untracked, so this command alone does not enumerate them. |
| 57 | git status --short | `?? tests/`; no staging. |
| 58 | Recommendation | **NOT READY TO COMMIT**. No commit, push, PR or Quartus run. |

## Runtime ledger

| Runtime | Purpose | Current result |
|---|---|---|
| reproduction/overflow9 | Original SAVE-only witness | Complete; original failure characterized, 1000 samples. |
| reproduction | Original exact three LOADs | Complete; each 38 collision / 6 status differences, 3000 samples. |
| prototype/overflow9 | Strict freeze-only ceiling check | Complete; 1000 VDP/RGB/A/RAM observations pass. |
| prototype | Full raw sprite + delay restoration ceiling | Complete; one LOAD, 9 collision / 6 status differences; not a pass. |
| prototype/trace_overflow | Original native-clock overflow trace | Complete; first internal and durable divergence logged. |
| prototype/trace_collision | Post-restore identity and first enables | Complete; restore identity passes,1999-clock sprite/CE/beam identity, one LOAD still has9 collision /6 status differences. |
| prototype/trace_reference | Supplemental native uninterrupted trace | Complete; 1000 observations, matches the original uninterrupted reference. |

The diagnostic full-state packing and caveats are documented in design.md. Unknown unused/inactive fields are retained for four-state identity checks only. They are not accepted as known image data or as evidence for non-injective image claims. Guest status and RGB checks reject unknowns.
