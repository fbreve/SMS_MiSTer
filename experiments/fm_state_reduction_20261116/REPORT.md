# FM state reduction: measured pilot report

**Retain complete restoration. No reduced variant is qualified for adoption.** This report contains actual controlled functional experiments, but the full requested game/hardware/long-duration investigation remains incomplete. See STATUS.md for the acceptance gate.

## Isolation and provenance

Reference/experimental branch: `8cd53ccc954c24970372ea6d8a3fb2336a14c46f` / `experiment/fm-state-reduction-20261116`. The main checkout remains `fix/ys-physical-sram-on-fm-pr227` at `ff70cb70`; master remains `66f16d5c`. The experimental production tree is unchanged. No sys edits, builds, qualified-RBF replacement, commits, pushes or PR mutations occurred.

The maintainer suggests macro-state restoration and a brief settling period; the 1-2 second bound is a hypothesis, not measured evidence. [Upstream discussion](https://github.com/MiSTer-devel/SMS_MiSTer/pull/227#issuecomment-6911777524). Its retrieved contents are preserved in upstream_comments.json.

## Inventory findings

STATE_INVENTORY.md enumerates all 100 words, RAM and scalar bit layouts, persistence, pending transactions and consumers. The exact public reference already omits temporal mixer state. Older local 104-word mixer-omission experiments cannot be treated as new savings against this reference.

Frequency/instrument settings alone cannot reconstruct phase, envelope progression, custom instruments, key edges, feedback or noise history. A pipeline may refresh locally while leaving incorrect phase/envelope/history RAM. Constant phase offsets under equal increments remain offsets modulo 2^18; no natural 1-2 second phase-alignment mechanism follows from that recurrence. This is a dependency argument, not a measured audibility claim.

## Actual experiment

Three separately instantiated real OPLLs: an uninterrupted control held at SAVE, a complete restore, and a selected-write-suppression restore. All start with the same musical writes. The two restore instances advance 21,347 FM enables into the future; both then receive the same captured image, except selected writes are suppressed only in the reduced instance. Capture/restore readback asserts every mapped word, checks retained stale words and reports how many actually differ. No ROM/game is simulated. Nine channels use a synthetic custom AM/PM/feedback voice. Rhythm is enabled in designated cases.

43 production-cadence runs completed with successful exit and readback/audio assertions: 34 group screens at two SAVE points, plus nine stage-position checks for the three least-risk groups. Each run observes 1,200 enabled FM clocks, with 15 host clocks per enable. These are short pilots (~0.336 ms at the 18.684 ns host period used by earlier fixtures), not two-second audio qualifications. The simulation clock itself is 10 ns: physical estimates are derived from enabled-clock counts and are explicitly approximate.

Every follow-up enable checks raw signed-14-bit audio, including unknown detection. Metrics are digital output differences, not perceived loudness, correct-pitch classification, analog audio, PSG mixing or listening results. CSVs sample once per 72 enables; exact bad-count/peak/last metrics use every enabled observation. Full-restore versus uninterrupted differences are retained, not discarded. The harness does not independently inspect hidden process variables during continuation; independent readback roundtrip is weaker than the existing internal oracle. Later musical writes/repeated LOADs and explicit attack/decay phase classifications remain outstanding.

The two no-omission controls match full restoration exactly. Full restoration itself differs from uninterrupted execution for up to 136 enables (~38.1 us), consistent with the already unsaved temporal mixer. No all-silent full reference or unknown audio occurred in these pilots.

One ModelSim 10.5b run of attack omission at point 0 reproduces GHDL metrics and the CSV exactly, independently checking simulator agreement for that case. Portability adapters only rename the VHDL-2008 reserved identifier Release, expand scalar subtype ranges, and add null choices for nonbinary case values. No functional binary-value behavior is intentionally changed.

The first 34 runs in pilot_results.json used one FM enable per host clock. They are retained only as exploratory screening and are excluded from valid production-cadence conclusions because ungated lookup stages depend on host clocks.

## Measurements

`changed` counts stale omitted words, not changed bits. `last=1200` means divergence remains at the endpoint; it does **not** mean it persists for two seconds. `last=0` means no extra raw-audio mismatch was observed in this limited case, not universal safety. Peak is raw signed-14-bit difference; MSE is averaged over all 1,200 enabled observations.

| Group | Point | Rhythm | Changed | Bad enables | Last bad | Peak | MSE |
|---|---:|---|---:|---:|---:|---:|---:|
| am | 0 | false | 1 | 920 | 1200 | 3 | 3.1066666666666665 |
| am | 37 | true | 1 | 682 | 1200 | 5 | 2.6333333333333333 |
| attack | 0 | false | 2 | 0 | 0 | 0 | 0.0 |
| attack | 1 | true | 2 | 432 | 626 | 18 | 3.432e1 |
| attack | 2 | true | 2 | 0 | 0 | 0 | 0.0 |
| attack | 3 | true | 2 | 0 | 0 | 0 | 0.0 |
| attack | 37 | true | 2 | 0 | 0 | 0 | 0.0 |
| control | 0 | false | 0 | 0 | 0 | 0 | 0.0 |
| control | 37 | true | 0 | 0 | 0 | 0 | 0.0 |
| controller | 0 | false | 3 | 200 | 1200 | 1 | 1.6666666666666666e-1 |
| controller | 37 | true | 3 | 1186 | 1200 | 9 | 5.136833333333333e1 |
| eg_work | 0 | false | 1 | 72 | 208 | 90 | 4.86e2 |
| eg_work | 37 | true | 1 | 1186 | 1200 | 498 | 1.8191048333333332e4 |
| eg_write | 0 | false | 1 | 992 | 1200 | 5 | 1.6046666666666667e1 |
| eg_write | 37 | true | 1 | 0 | 0 | 0 | 0.0 |
| envelope | 0 | false | 18 | 1064 | 1200 | 1154 | 6.385809e5 |
| envelope | 37 | true | 18 | 1114 | 1200 | 2264 | 2.660406928333333e6 |
| feedback | 0 | false | 9 | 432 | 712 | 13 | 3.138e1 |
| feedback | 37 | true | 9 | 1042 | 1200 | 31 | 1.7052e2 |
| keys_noise | 0 | false | 1 | 0 | 0 | 0 | 0.0 |
| keys_noise | 37 | true | 0 | 0 | 0 | 0 | 0.0 |
| noise | 0 | false | 1 | 0 | 0 | 0 | 0.0 |
| noise | 37 | true | 1 | 754 | 1200 | 2032 | 6.9817272e5 |
| operator | 0 | false | 2 | 288 | 352 | 134 | 1.07982e3 |
| operator | 37 | true | 2 | 792 | 806 | 1645 | 3.148038e5 |
| output_ram | 0 | false | 18 | 504 | 856 | 266 | 4.91016e3 |
| output_ram | 37 | true | 18 | 1186 | 1200 | 325 | 6.630173333333333e3 |
| pg_output | 0 | false | 1 | 0 | 0 | 0 | 0.0 |
| pg_output | 37 | true | 1 | 0 | 0 | 0 | 0.0 |
| pg_write_pm | 0 | false | 1 | 992 | 1200 | 10 | 2.7946666666666665e1 |
| pg_write_pm | 37 | true | 1 | 0 | 0 | 0 | 0.0 |
| phase | 0 | false | 18 | 1064 | 1200 | 51 | 1.10826e3 |
| phase | 37 | true | 18 | 1186 | 1200 | 5763 | 4.922537595e6 |
| sine | 0 | false | 2 | 0 | 0 | 0 | 0.0 |
| sine | 1 | true | 2 | 72 | 194 | 10 | 6.0 |
| sine | 2 | true | 2 | 0 | 0 | 0 | 0.0 |
| sine | 3 | true | 2 | 0 | 0 | 0 | 0.0 |
| sine | 37 | true | 2 | 0 | 0 | 0 | 0.0 |
| writeback | 0 | false | 1 | 0 | 0 | 0 | 0.0 |
| writeback | 1 | true | 1 | 0 | 0 | 0 | 0.0 |
| writeback | 2 | true | 1 | 72 | 121 | 121 | 8.7846e2 |
| writeback | 3 | true | 1 | 0 | 0 | 0 | 0.0 |
| writeback | 37 | true | 1 | 0 | 0 | 0 | 0.0 |

The attack omission looks exact at points 0,2,3,37 but point 1 produces 432 differing enables, last at 626. Sine omission point 1 produces 72 differing enables, last at 194. Output writeback point 2 produces 72 differing enables, last at 121. These specific discrepancies end within this short window. They are the remaining narrow candidates for longer and broader investigation, not accepted reductions. Envelope/phase/history/controller/AM/noise omissions exhibit endpoint divergence in at least one applicable case. The unchanged key/noise word at rhythm point 37 does not exercise that omission and is not credited as evidence of safety.

## Acceptance assessment

| Requirement | Status |
|---|---|
| Complete documented 100-word inventory | Completed |
| Isolated exact-reference branch/full reference retained | Completed |
| Controlled one-group real-OPLL functional pilots | Completed: 43 valid runs |
| Magnitude/duration measurement | Completed only for short digital pilots |
| Non-silent continuation beyond two seconds | Not performed |
| Broad SAVE/LOAD phases, sustained/attack/decay, later writes and modes | Partial; not qualified |
| Double Dragon stage replay | Not performed |
| Ys FM environment replay | Not performed; local SRAM replay is different evidence |
| California Games event-attempt replay | Not performed |
| Legacy/file compatibility | Production format code unchanged; no new reduced RTL integration qualification |
| Matched reduced-state Quartus 17.0.2 builds | Deferred pending functional credibility |
| Reduced variant hardware audio | Not performed |

No candidate meets all adoption criteria. No needed/placed ALM, register, M10K, DSP or timing savings are reported for reductions. Existing full-versus-no-FM build numbers measure a different comparison. The 256x32 M10K transport remains unchanged by selected restore suppression. A small word-count decrease is not evidence of a removed RAM block or meaningful logic savings.

## Reproduction

From the parent experiment directory: `node inventory.js`, `node compile.js`, `node native_campaign.js`, `node phase_campaign.js`, `node summarize.js`. The native scripts resolve the existing GHDL 6.0.0 tool under the earlier self-healing experiment. Their directories/logs are overwritten on rerun; archive the current evidence first. `node prepare_modelsim.js` creates modelsim.do; run ModelSim there. document.js appends inventory elaboration and should not be rerun repeatedly without regenerating inventory first. Source hashes are in source_manifest.json; raw per-run logs and CSVs are under native_runs/ and phase_runs/.
