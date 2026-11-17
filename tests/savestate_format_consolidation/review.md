# Savestate format consolidation investigation

**A. CONSOLIDATION NOT WORTHWHILE.** No meaningful FPGA capacity is recovered: the paired production-settings experiment uses 27 more placed ALMs and only 10 fewer needed ALMs. The single seed 2 sensitivity check fails setup. Production remains v17.

Branch: `investigate/savestate-format-consolidation`. Investigation and isolated measurement only. No production format change, commit, push or PR.

Prerequisite evidence read completely: [resource growth](../savestate_resource_growth/review.md), [sprite resource optimization](../savestate_sprite_resource_optimization/review.md), [F01 architecture](../savestate_f01_opll_architecture/review.md), [F01 implementation](../savestate_f01_opll_fix/review.md), and [rejected G06 sequential architecture](../savestate_g06_sequential_architecture/review.md). Their hashes are retained in baseline.json.

## 1. Baseline HEAD

`7fcd5e12847eedf9e97a44dc937c3dbac3205f7c` (F01), unchanged throughout this investigation.

## 2. Baseline v17

Outer tag `484311`, subtype 3. Container 96 KiB; 32-bit size count 24574 (`0x5ffe`), 64-bit DDR slot stride `0x3000`. The v17 F01 record remains 104x32 bits at 2998..29cb with descriptor 2997. No experiment changes current payload contents or addresses.

## 3. Baseline resources

Exact retained [F01 production build](../savestate_f01_opll_fix/quartus_final/output_files/SMS.fit.summary), Quartus 17.0.2 Build 602,5CSEBA6U23I7, SMS/sys_top, seed 1, MISTER_FB=1, BUILD_DATE261025. All 137 build inputs and fixed build ID were hash-checked.

|Resource|Baseline|Capacity|Use|
|---|---:|---:|---:|
|ALMs needed|37,175|41,910|88.702%|
|ALMs placed|38,598|41,910|92.097%|
|Fitted registers|48,948|167,640|29.198%|
|M10K|488|553|88.246%|
|Memory bits|3,818,050|5,662,720|67.424%|
|DSP|39|112|34.821%|

Mapped registers: 46,289. The previous G06 sequential experiment was rejected; none of its production modifications are included here.

## 4. Baseline timing

Setup +0.105 ns; hold +0.206 ns; 0 failing summary categories. The retained [baseline paths](../savestate_g06_sequential_architecture/baseline_paths_setup.rpt) show the global worst path from HDMI shadowmask dout[20] to HDMI OSD nrdout1[20]. Existing partially unconstrained checks remain a baseline limitation; this is constrained STA comparison, not hardware signoff.

## 5. Complete format-version history

| Format | Commit/date | Fields and reader change | Master | Public release |
|---|---|---|---|---|
|untagged64|[077545e0](https://github.com/MiSTer-devel/SMS_MiSTer/commit/077545e09bdbcb98b777fcd5dafd01b7af3810ad), 2026-05-28T09:25:31+08:00|212-bit CPU, 56-bit PSG, 64 KiB slot, SMS1 magic|yes|[SMS_20260603.rbf](https://github.com/MiSTer-devel/SMS_MiSTer/blob/4d364780502d1c5d212ad06962a44341c3bbfeaf/releases/SMS_20260603.rbf), blob b592ff3cf2d2a1321ef4428c768b00d7200824fa|
|untagged96|[8f3bcb2b](https://github.com/MiSTer-devel/SMS_MiSTer/commit/8f3bcb2bb7129139940cfbb18cc66f5ef139bd1f), 2026-06-13T11:28:35+08:00|230-bit CPU, 96 KiB slot, gameID, SystemE second device, IO/video; August release also 64-bit EEPROM wrapper|yes|[SMS_20260823.rbf](https://github.com/MiSTer-devel/SMS_MiSTer/blob/3ae7eec9cc2a9e02f824771e2e5652f5992ed906/releases/SMS_20260823.rbf), blob 26632aabd2f9db6b1f593f460e0701eb2591acce|
|v1|60c6552afdbc87dd6f7f3ccfbab14ee41be7195e, 2026-10-20T10:11:07-03:00|two 8-bit HCounter latches, word 01a; tag HC01/subtype 0; reader extends presence/tag membership and retains established older behavior|no|no; not ancestor of either release, nor any of 56 live branch/tag refs|
|v2|02838b753751530576045c3c15cbfafa684c5f6e, 2026-10-20T11:21:31-03:00|GG temporal 114 bits in 128-bit container at 01c..01d; subtype 2; reader extends presence/tag membership and retains established older behavior|no|no; not ancestor of either release, nor any of 56 live branch/tag refs|
|v3|e090434c449d77c506b9c46548399da4ab76d119, 2026-10-20T12:17:53-03:00|MD6 two-port46 bits, 01e; common subtype 3; reader extends presence/tag membership and retains established older behavior|no|no; not ancestor of either release, nor any of 56 live branch/tag refs|
|v4|b0f4b710d1d182635a59c238a6a0341bf3d8ba7c, 2026-10-20T13:13:55-03:00|EEPROM128-bit temporal extension, descriptors and 128-byte contents; legacy64-bit wrapper retained; reader extends presence/tag membership and retains established older behavior|no|no; not ancestor of either release, nor any of 56 live branch/tag refs|
|v5|e4a1ac90a5beed09218cb9720af16ae39445a6e1, 2026-10-20T15:17:08-03:00|SC RAM 2/16/32 KiB footprint and SCR5 descriptor; reader extends presence/tag membership and retains established older behavior|no|no; not ancestor of either release, nor any of 56 live branch/tag refs|
|v6|52fb7496aeeaf2227e332194e06ec2cdfcf43932, 2026-10-20T16:26:13-03:00|MasterTap 19 bits, MTAP descriptor; reader extends presence/tag membership and retains established older behavior|no|no; not ancestor of either release, nor any of 56 live branch/tag refs|
|v7|77147af4b1c0657d99bfaa840bcb17ad0be5d658, 2026-10-20T17:21:56-03:00|paddle 32 bits, PAD7 descriptor; reader extends presence/tag membership and retains established older behavior|no|no; not ancestor of either release, nor any of 56 live branch/tag refs|
|v8|dcbe06d5527f96d3fb172472aaed44c3845a1e43, 2026-10-21T11:00:37-03:00|lightgun 46 bits plus owner descriptor; reader extends presence/tag membership and retains established older behavior|no|no; not ancestor of either release, nor any of 56 live branch/tag refs|
|v8 (no bump)|b61f307dcb161a6ac9a70fd544d435436807191d, 2026-10-21T13:42:04-03:00|Fix System E pause handling during savestates; behavioral ordering correction, no new format|no|no; not ancestor of either release, nor any of 56 live branch/tag refs|
|v9|eede89d01a6441906dbbda237865a0cbc761d830, 2026-10-21T15:35:17-03:00|mapper detection18 bits, history descriptor; reader extends presence/tag membership and retains established older behavior|no|no; not ancestor of either release, nor any of 56 live branch/tag refs|
|v10|ff9d66b79c20f90cea53d5fd78ae8f8021462a53, 2026-10-21T22:48:25-03:00|Evolution selector/history 57 bits; reader extends presence/tag membership and retains established older behavior|no|no; not ancestor of either release, nor any of 56 live branch/tag refs|
|v11|d1df5902e4e671ed0cb87e770b43b15da53a3a92, 2026-10-22T07:30:02-03:00|Evolution pending6 bits across existing fields; EV11 width60 descriptor; reader extends presence/tag membership and retains established older behavior|no|no; not ancestor of either release, nor any of 56 live branch/tag refs|
|v12|faf7036e4450027f79cc639a731053dca29840ca, 2026-10-22T11:57:05-03:00|normalized CPU NMI3 bits atword5[40:38]; reader extends presence/tag membership and retains established older behavior|no|no; not ancestor of either release, nor any of 56 live branch/tag refs|
|v13|8ffd15e2a7e530c0d77b07c6eeae3e8dc0aa0c8a, 2026-10-22T20:17:38-03:00|CPU instruction-restart3 bits atword5[43:41]; reader extends presence/tag membership and retains established older behavior|no|no; not ancestor of either release, nor any of 56 live branch/tag refs|
|v14|58583189b5c650dc6658ef467e8dcb72d9f6e6c2, 2026-10-23T22:25:46-03:00|two 4778-bit sprite records, 2-bit phase, accepted-tick flag; deterministic restart contract; reader extends presence/tag membership and retains established older behavior|no|no; not ancestor of either release, nor any of 56 live branch/tag refs|
|v15|f205b05dc058fc5f7f2432779b61e8f3b0e22519, 2026-10-24T15:13:41-03:00|two 139-bit background records; reader extends presence/tag membership and retains established older behavior|no|no; not ancestor of either release, nor any of 56 live branch/tag refs|
|v16|08cf1426bfd2e1f2a73fdb25aaf57715d408db11, 2026-10-24T22:41:33-03:00|historical AudioMix phase bit; coherent pending PSG tick handling uses existing restart/divider state; reader extends presence/tag membership and retains established older behavior|no|no; not ancestor of either release, nor any of 56 live branch/tag refs|
|v16 (no bump)|cb2e8615128d61adb996ada68e6bbdcc314c20f6, 2026-10-25T16:59:36-03:00|Fix ROM request restart across savestates; behavioral ordering correction, no new format|no|no; not ancestor of either release, nor any of 56 live branch/tag refs|
|v17|7fcd5e12847eedf9e97a44dc937c3dbac3205f7c, 2026-10-26T13:31:53-03:00|OPLL104x32=3328 stored bits (1896meaningful), FMS1 descriptor and 52DDR words; reader extends presence/tag membership and retains established older behavior|no|no; not ancestor of either release, nor any of 56 live branch/tag refs|

### Untagged history before v1

- 077545e09bdbcb98b777fcd5dafd01b7af3810ad|2026-05-28T09:25:31+08:00|Implement savestates and enhance detection for Zemina/Nemesis (#191)
- 8f3bcb2bb7129139940cfbb18cc66f5ef139bd1f|2026-06-13T11:28:35+08:00|SaveStates and Pause for System-E, enhanced SaveStates for SMS (#192)
- 11ff6379c939acc2952180538b650842b49b3891|2026-07-04T22:34:42+08:00|Fix loading of pre-#192 save states (#195)
- 9dfc10739f35b13987ba54afc2f88fb4662ee511|2026-08-15T04:57:37+08:00|Refine Codemasters mapper handling and add Game Gear EEPROM support (#199)
- 0f768a858698ab4e680fab8ba15682ad5858d8a3|2026-09-09T11:08:30-03:00|Add Master System Evolution support
- 19fedb6cfeaddf15380823c203c4d9738bde6e7a|2026-10-05T16:50:35+08:00|Refactor savestate transfers and fix controller/RAM issues (#216)
- ce5a63c6ca473a6913a31a87286b6203adc3f391|2026-10-06T16:29:07+08:00|Remove dead savestate FSM states (#217)
- 998d8aa6f17499c913c2df64d858f76b7a5d8d4a|2026-10-08T09:36:14-03:00|Fix savestate DDRAM transaction handshake
- a196cf113e0d36a9ec11c2c39a2c5142b1e0ea3f|2026-10-08T09:36:59-03:00|Preserve PSG state across savestates

The untagged96 family evolved on master after the August release, including Evolution and PSGX1. This experiment retains the existing untagged reader, the PSGX presence/validation path, and both public size layouts. It does not assert that every untagged master state was a release. The only intentionally rejected formats are the 16 numbered development tags HC01..HC10.



## 6. Git evidence per version

[history.json](history.json) records all introducing SHAs, dates, no-bump corrections and ancestry results. All 19 commits after 8443a0d, including the 17 numbered formats and F12/G12 no-bump corrections, are absent from both live master refs and all 56 live branch/tag references. Per-transition source patches:

- [60c6552afdbc87dd6f7f3ccfbab14ee41be7195e](history/60c6552a.patch): Fix HCounter state restoration in savestates; master=false; published refs containing commit=0.
- [02838b753751530576045c3c15cbfafa684c5f6e](history/02838b75.patch): Preserve Game Gear I/O state across savestates; master=false; published refs containing commit=0.
- [e090434c449d77c506b9c46548399da4ab76d119](history/e090434c.patch): Preserve MD6 handshake state across savestates; master=false; published refs containing commit=0.
- [b0f4b710d1d182635a59c238a6a0341bf3d8ba7c](history/b0f4b710.patch): Preserve EEPROM state and contents across savestates; master=false; published refs containing commit=0.
- [e4a1ac90a5beed09218cb9720af16ae39445a6e1](history/e4a1ac90.patch): Preserve SC cartridge RAM across savestates; master=false; published refs containing commit=0.
- [52fb7496aeeaf2227e332194e06ec2cdfcf43932](history/52fb7496.patch): Preserve Master Tap protocol state across savestates; master=false; published refs containing commit=0.
- [77147af4b1c0657d99bfaa840bcb17ad0be5d658](history/77147af4.patch): Preserve paddle state across savestates; master=false; published refs containing commit=0.
- [dcbe06d5527f96d3fb172472aaed44c3845a1e43](history/dcbe06d5.patch): Preserve lightgun state across savestates; master=false; published refs containing commit=0.
- [b61f307dcb161a6ac9a70fd544d435436807191d](history/b61f307d.patch): Fix System E pause handling during savestates; master=false; published refs containing commit=0.
- [eede89d01a6441906dbbda237865a0cbc761d830](history/eede89d0.patch): Preserve mapper detection history across savestates; master=false; published refs containing commit=0.
- [ff9d66b79c20f90cea53d5fd78ae8f8021462a53](history/ff9d66b7.patch): Preserve Evolution selector state across savestates; master=false; published refs containing commit=0.
- [d1df5902e4e671ed0cb87e770b43b15da53a3a92](history/d1df5902.patch): Preserve Evolution pending operations across savestates; master=false; published refs containing commit=0.
- [faf7036e4450027f79cc639a731053dca29840ca](history/faf7036e.patch): Preserve CPU NMI state across savestates; master=false; published refs containing commit=0.
- [8ffd15e2a7e530c0d77b07c6eeae3e8dc0aa0c8a](history/8ffd15e2.patch): Preserve CPU restart context across savestates; master=false; published refs containing commit=0.
- [58583189b5c650dc6658ef467e8dcb72d9f6e6c2](history/58583189.patch): Fix deterministic CPU and VDP savestate restart; master=false; published refs containing commit=0.
- [f205b05dc058fc5f7f2432779b61e8f3b0e22519](history/f205b05d.patch): Preserve VDP background pipeline across savestates; master=false; published refs containing commit=0.
- [08cf1426bfd2e1f2a73fdb25aaf57715d408db11](history/08cf1426.patch): Fix audio restart sequencing across savestates; master=false; published refs containing commit=0.
- [cb2e8615128d61adb996ada68e6bbdcc314c20f6](history/cb2e8615.patch): Fix ROM request restart across savestates; master=false; published refs containing commit=0.
- [7fcd5e12847eedf9e97a44dc937c3dbac3205f7c](history/7fcd5e12.patch): Preserve OPLL state across savestates; master=false; published refs containing commit=0.

The untagged transitions are also retained as patches, including public 64 introduction077545e0,96KiB8f3bcb2b, old64 reader correction11ff6379, EEPROM9dfc1073, Evolution0f768a85, transfer refactoring19fedb6c, dead-state cleanupce5a63c6, DDR handshake998d8aa6 and exact PSGXa196cf11. Being present on master does not make an untagged transition a release.

## 7. Release evidence per version

Fresh [GitHub GET evidence](network_evidence.json) separately captures both master refs, all available branches/tags, GitHub Releases responses and the official releases directory. Both master refs are 8443a0d19a88aff7a5900011bccf386daf146945. GitHub Releases API returns an empty list; actual binaries are checked into releases/.

- Public64: [Release20260603](https://github.com/MiSTer-devel/SMS_MiSTer/commit/4d364780502d1c5d212ad06962a44341c3bbfeaf), binary blob `b592ff3cf2d2a1321ef4428c768b00d7200824fa`.
- Public96: [Release20260823](https://github.com/MiSTer-devel/SMS_MiSTer/commit/3ae7eec9cc2a9e02f824771e2e5652f5992ed906), binary blob `26632aabd2f9db6b1f593f460e0701eb2591acce`. This exact release commit was verified live.
- All v1..v17 numbered changes postdate and are not ancestors of either public release. No numbered HC tag appears in the associated public source snapshots. The six published annotated fork tags peel to older May/June commits. No newer binary appears in the captured official directory.

## 8. Last public/stable format

**Untagged96 KiB associated with SMS_20260823.rbf**, source commit3ae7eec9cc2a9e02f824771e2e5652f5992ed906. Word01a contains 22 video bits and 42 zero upper bits; no HC tag, no later PSGX history or FM snapshot. The experiment also retains the older public 64 KiB reader. It never treats "newest public" as permission to delete another released reader. [Both exact source snapshots](history/) are retained.

## 9. Confidence in compatibility floor

**STRONGLY SUPPORTED.** Live official release-file/commit/blob evidence agrees with the local Git tree and exact source snapshots. All candidate development tags are absent from the public refs and releases examined. This is source-to-release association, without a reproducible-build attestation extracting the format from the bitstream, so PROVEN is not claimed. Confidence exceeds the required compatibility-floor gate.

## 10. Current compatibility inventory

[compatibility_inventory.json](compatibility_inventory.json) contains 17 tag constants, 95 textual tag comparisons, 210 controller expressions/fallback statements and 125 destination references. Each structure records version conditions, logical widths, affected state, semantic mux/decode widths, source references and separately reported physical fanout. Expression rows link to those structures. Destination rows explicitly distinguish aggregate semantic width from per-statement physical cost. Unreported/merged physical fanout is marked unavailable, never guessed.

|Structure|Select/data width|Affected state / semantic mux width|Role|
|---|---:|---|---|
|is_old_format|1|64 KiB size vs96 KiB; old CPU layout, magic/gameID, mapper/RAM, IO/video skip; 230 bits|public|
|load_ext_magic|24|24-bit tag normalization v12..17 -> v11; routes GG/history; no historical bits reconstructed; 128 bits|development-only|
|modern_nmi_tag|1|CPU NMI history presence; 3 bits|mixed: decode collapses, public default retained|
|modern_restart_tag|1|CPU instruction/restart padding and presence; 3 bits|mixed: decode collapses, public default retained|
|has_nmi_history|1|CPU NMI triplet vs001; 3 bits|public fallback required|
|has_restart_context|1|T80 instruction context vs canonical M1; 3 bits|public fallback required|
|has_restart|1|dual4778-bit sprite records, capture tick, restart phase; 9559 bits|public fallback required|
|has_background|1|dual139-bit background records vs deterministic invalid history; 278 bits|public fallback required|
|has_fm|1|F01 sequential OPLL exact104rows vs canonical reset/28rows/refill; 3328 bits|public fallback required|
|has_audio_ext|1|dual96-bit exact PSG history, divider4, audio control11, phase1; 208 bits|public fallback required|
|has_md_ext|1|MD6 handshake history vs invalid; 46 bits|public fallback required|
|has_eeprom_tag|1|EEPROM serial temporal state/presence vs legacy wrapper; 128 bits|public fallback required|
|has_sc_tag|1|SC RAM size tag vs old mapper handling; 2 bits|public fallback required|
|has_tap_tag|1|MasterTap protocol state; 19 bits|public fallback required|
|has_paddle_tag|1|paddle protocol state; 32 bits|public fallback required|
|has_gun_tag|1|lightgun guest latches; 46 bits|public fallback required|
|has_mapper_history|1|mapper detection vs0ffff legacy defaults; 18 bits|public fallback required|
|has_evolution_history|1|Evolution57-bit selector plus 6 pending; old images rejected for Evolution; 63 bits|public rejection/fallback required|
|evolution_history_valid|1|history descriptor validity vs no historical state; 63 bits|public rejection required|
|GG_RESET|128|reset image for absent GG temporal state and padding fallback; 128 bits|public|
|MAPPER_HISTORY_LEGACY|18|mapper detector safe deterministic fallback; 18 bits|public|
|nmi_padding_ok|1|v12 padding vs v13+ restart padding; 3 bits|development distinction removable; current validation retained|
|restart_padding_ok|1|combined NMI/instruction semantic validation; 6 bits|current validation required|

## 11. Development-only compatibility inventory

Sixteen old HC tag constants and their overlapping membership/normalization predicates, the v12-only NMI padding distinction, and distinctions among v13/v14/v15/v16 presence classes are candidates for removal. The experiment eliminates the 24-bit v12+ -> v11 alias, rewrites current membership directly and reduces95 textual outer-tag comparisons to 6 uses of the same current tag plus the HC-prefix rejection check. Repetition is not a physical comparator count. Current/public presence flags and all current data banks remain. Untagged PSGX decoding is shared with the current exact path and public absence fallback; it is retained, not represented as a released format or separately recoverable development bank.

## 12. Public compatibility inventory

Both 64 KiB and 96 KiB layouts retain size/magic/gameID rules, old212 -> 230 CPU normalization, original RAM footprints, 64 KiB IO/video skipping, 96 KiB IO/video/EEPROM restoration, missing-HCounter/default GG/accessory behavior, mapper defaults, legacy CPU/VDP behavior, configuration-only PSG import and canonical FM fallback. Evolution images without required historical selector/pending state remain rejected.

[Detailed fallback limits](dependency_map.md#limits-of-public-imports): some peripheral defaults sample present pins; public PSG timers/noise/divider are not functions of the public image and are not reconstructed or newly canonicalized. EEPROM/SC extensions absent historically are not invented. Existing v17 representation and restoration behavior are preserved; missing public history is not reconstructed. F06 and G08.FM remain outside this task.

## 13. Version-decode topology

[Dependency map](dependency_map.md): size/tag/subtype -> membership/presence -> command/FSM route -> restore validity/default -> destination state. Production uses membership predicates and one shared alias, not seventeen sequential conversion passes. Both combinational DDR command selection and registered FSM progression contain the GG route and are changed consistently. The source-derived decode check enumerates all 256 public/current contexts and compares 4352 predicate outcomes, including both padding flags, audio presence and live/saved Evolution flags.

## 14. Restore-mux topology

Current or legacy selects still drive9556 sprite bits plus phase/tick, 278 background bits, CPU NMI/restart behavior, GG128/MD46/EEPROM128/tap19/paddle 32/gun46/mapper18/Evolution history and the sequential3328-bit OPLL representation. Public readers require the absent-history alternatives. Descriptor/range/padding validation remains. These are current state banks and shared public fallbacks, not duplicated banks for sixteen old versions. Their widths cannot be summed as removable compatibility hardware.

## 15. Fanout findings

Baseline physical fanout: ARM_FREEZE9663; z80_set5920; vdp2_regs_set5454; LOAD_HDR_RD5262; sprite-bank controls approximately4800; has_restart1410. The largest controls remain necessary for current capture/restart. has_restart still distinguishes current from public imports, so its1410 sinks are not all development cost. Other source-reference counts are explicitly not substituted for physical fanout. Full baseline fitter excerpts and the candidate fitter data are retained in the inventories/results.

Post-fit [baseline](baseline_fanout.tsv) and [experimental](experiment_fanout.tsv) TimeQuest queries fill in named control-register fanout. Their metric is the transitive `get_fanouts` node-collection size, distinct from direct physical Fitter loads:

|Signal|Baseline timing nodes|Experimental timing nodes|
|---|---:|---:|
|is_old_format|14718|14710|
|has_audio_ext|14718|14710|
|has_background|351|352|
|has_restart|11588|11575|
|has_fm|14|14|
|has_nmi_history|4|no named register|
|has_restart_context|7|no named register|
|has_md_ext|5|no named register|
|has_eeprom_tag|3|47|
|has_sc_tag|9|9|
|has_tap_tag|6|no named register|
|has_paddle_tag|5|no named register|
|has_gun_tag|40|no named register|
|has_mapper_history|6|no named register|
|has_evolution_history|6|6|
|evolution_history_valid|14718|14710|
|nmi_padding_ok|14718|no named register|
|restart_padding_ok|14718|14710|

Eight former control-register names have no independent named register in the experimental netlist, consistent with presence-flag merging and removal of the v12-only padding state; synthesis reports eight fewer registers. High transitive counts include shared DDR step/control effects and cannot be added as removable data muxes. The raw TSV header uses "endpoints"; the precisely defined measured object is the TimeQuest fanout-node collection, as documented by the retained local tool help.

## 16. Static cost assessment

The plausible direct saving is comparator/membership/alias logic and a small amount of obsolete control state. Common prefixes and repeated equality terms share logic. Required public defaults prevent deleting the large modern restore paths. Presence registers have differing clear/capture lifetimes, so equal LOAD predicates do not guarantee equal registers. No M10K saving was assumed. Static expectation was limited Boolean/register savings with potentially larger, unpredictable packing/routing effects; measured results govern the classification.

## 17. Experimental variant definition

Only [candidate/rtl/savestates.sv](candidate/rtl/savestates.sv) differs from the production build inputs:25insertions, 40deletions. It retains v17 contents/addressing, public 64/public 96 and existing untagged/shared PSGX handling. The HC prefix with a noncurrent tag is explicitly rejected, including unknown HC versions, rather than silently reinterpreted as an untagged public file. The complete v17 tag alias is removed before old comparisons are eliminated. Constant-false terms remain only in the experimental source; synthesis folds them so their hardware cost can be measured without a production rewrite. No G06 sequential prototype, F06 or G08.FM change enters the build.

## 18. Functional-gate result

**PASS before Quartus.** [Immutable proof manifest](functional_gate.json), [decode proof](decode_equivalence.json), [build chronology](provenance.json).

- 28 component cases: 10 G01; one G05; two sprite; three G10; one dual VDP; one pending VDP; four G12/F12; six G08.release/audio cases. G05 covers 42,000 SAVE-only and 126,000 LOAD trace comparisons.
- Two real F01 replays, seeds 1 and 10: each covers SAVE plus three LOADs and 192,000 raw FM host samples. Seed 10 also exercises System E isolation. This does not close G08.FM.
- 2,416 format cases: 2,032 rejections and 384 acceptances, including 139 one-hot background positions and 240 valid counter encodings. The inherited floating restart input was tied to a legal value. The final suite requires all 98,304 current image bytes to be known.
- Every-clock comparison of all 101 controller outputs: 16 profiles, 48 current LOADs, 32 public96 and 16 public64 LOADs, over 11,555,938 clocks.
- Nonzero peripheral matrix: 16 profiles, 48 current LOADs and 8,247,115 clocks; System E, Pause, SC-size and EEPROM combinations with GG, MD6, MasterTap, paddle and lightgun payloads.
- Evolution: eight pending-operation profiles, 24 current LOADs and 16 required public-history rejections, over 1,642,659 clocks.
- Raw PSG: 128 cases of 20,000 compared cycles each, covering all 16 divider phases and eight noise controls.

Five VDP fixture families previously used unsupported v13 during setup. Their setup import was changed to retained public96. Reference traces were regenerated with the unchanged v17 golden controller in a separate compiled library. The driver maps the logical vdp_work alias to golden_work for reference generation, then to the candidate library for replay. Current scoring and three LOAD replays remain. Existing simulation-only portability changes, TB_FAST and flush shortening are documented in the gate. Production synthesis uses full counters and original settings. All 204 tracked files remain hash-identical.

## 19. Stable-format experimental result

**PASS**, preserving the existing reader contract. Both public layouts match all 101 golden outputs cycle for cycle across repeated imports, poisoned modern tail metadata, transport stalls and owner/Pause profiles. The explicit import probe checks legacy validity flags, GG reset, peripheral defaults, mapper defaults, mixer phase0, EEPROM public 64 default, FM reset-once plus 28 writes, and exact current FM104 write routing before/after legacy. Evolution public rejection is also checked. [Legacy behavior limits](dependency_map.md#limits-of-public-imports) distinguish present historical state, canonical defaults, input-dependent defaults and configuration-only PSG import. No missing history is claimed reconstructed.

## 20. Experimental ALMs needed

37,165 / 41,910 = 88.678%; baseline 37,175; delta -10.

## 21. Experimental ALMs placed

38,625 / 41,910 = 92.162%; baseline 38,598; delta +27.

## 22. Experimental fitted registers

48,846 / 167,640 = 29.137%; baseline 48,948; delta -102.

## 23. Experimental M10K

488 / 553 = 88.246%; baseline 488; delta +0.

## 24. Experimental memory bits

3,818,050 / 5,662,720 = 67.424%; baseline 3,818,050; delta +0.

## 25. Experimental DSP

39 / 112 = 34.821%; baseline 39; delta +0.

## 26. Experimental setup

+0.365 ns; baseline +0.105 ns; delta +0.260 ns. Full requirement summary is retained in [experiment_results.json](experiment_results.json).

## 27. Experimental hold

+0.233 ns; baseline +0.206 ns; delta +0.027 ns.

## 28. Experimental timing/routing result

Primary seed 1 completed map/fit/asm/STA with zero errors, zero failing timing summary categories and no routing failure. Setup improves by +0.260 ns and hold by +0.027 ns in that one fit. Average/peak routing use is 40%/59%; the seed 2 confirmation routes at 39%/60% but fails setup. This does not establish a robust timing benefit.

0 failing STA summary categories. New warning types: none. [Full resource/warning evidence](experiment_results.json), [setup paths](experiment_paths_setup.rpt), [hold paths](experiment_paths_hold.rpt). The primary global worst setup path moves from HDMI shadowmask dout[20] -> HDMI OSD nrdout1[20] (+0.105 ns) to HDMI scaler o_vacpt[9] -> o_vpixq_pre[3].g[7] (+0.365 ns). Primary worst hold is in VDP2 sprite shifter shift0[6] -> shift0[7] (+0.233 ns). The emulation-clock worst setup improves from +0.635 ns to +1.162 ns, remaining an SDRAM-to-CPU path: baseline sd_dat[8] -> T80 IR[4], primary sd_dat[11] -> T80s DI_Reg[1]_OTERM325. Neither ten-worst emulation report contains the savestate controller. [Baseline emulation paths](baseline_emu_setup.rpt), [primary emulation paths](experiment_emu_setup.rpt). These are global placement/routing effects in unchanged source hierarchies, not evidence that development-version decode was the critical path. Confirmation returns a failing HDMI-output path at -0.013 ns.

## 29. Confirmation result

One fresh seed-2 sensitivity build was performed because the primary timing gain warranted checking. All RTL, IP, constraints and build-date inputs match the primary; only SEED changes from 1 to 2. [Control proof](confirmation_controls.json). Both fits and routes completed; the confirmation has an HDMI setup violation.

|Metric|Production seed 1|Experiment seed 1|Confirmation seed 2|
|---|---:|---:|---:|
|ALMs needed|37,175|37,165|37,197|
|ALMs placed|38,598|38,625|38,524|
|Fitted registers|48,948|48,846|48,913|
|Mapped registers|46,289|46,281|46,281|
|M10K|488|488|488|
|Memory bits|3,818,050|3,818,050|3,818,050|
|DSP|39|39|39|
|Setup ns|+0.105|+0.365|-0.013|
|Hold ns|+0.206|+0.233|+0.207|
|Failing STA summary categories|0|0|1|

Seed 2 is **not paired with a seed 2 production baseline**. Its apparent 74-ALM reduction versus seed 1 production is not an attributable compatibility saving; its difference from the primary is seed sensitivity. Needed ALMs are 22 above the retained baseline, and the global setup result is -0.013 ns (TNS-0.013 ns). New warning type 332148, "Timing requirements not met", appears only in this confirmation. The detailed ten-worst setup report contains one failing path, d[14] -> hdmi_out_d[14]; hold remains positive at +0.207 ns. Emulation-clock setup is +1.112 ns. [Confirmation results](confirmation_results.json), [setup paths](confirmation_paths_setup.rpt), [hold paths](confirmation_paths_hold.rpt). No further seed or architecture sweep was run.

## 30. Compatibility-cost classification

**NEGLIGIBLE.** The paired seed 1 build reduces needed ALMs by 10 (0.024 percentage points of device capacity) while increasing placed ALMs by 27 (0.064 points); there is no placed capacity recovery. Only 8 mapped control registers disappear. Fitted registers fall 102, with no M10K, memory-bit or DSP recovery. Whole-design logic ALUT usage falls 171 while route-through ALUT usage rises 162. Shared current/public restore paths and modern state banks dominate the retained cost. Seed 2 shows only a small, unpaired placement movement and fails setup, so the primary timing gain is not robust.

## 31. Decision gate

**A. CONSOLIDATION NOT WORTHWHILE.** The public floor is strongly supported and the current/public functional gate passes, but the required meaningful resource-cost/capacity-recovery condition is not demonstrated. A code cleanup or one favorable timing placement does not justify a production format change for the stated capacity objective. Choose A and stop after investigation.

## 32. Reason consolidation was not performed

The experiment does not recover material placed capacity, and the single confirmation does not preserve the timing improvement. Production consolidation is therefore not justified by the evidence. Both released reader families and all existing v17 behavior remain in the untouched production tree. Production remains v17; no v18 definition or production rewrite was performed. Phases 13-22 are conditional on C and were not entered.

## 33. Recommended next roadmap step

Keep the committed v17 production configuration and resume the next separately scoped functional roadmap task, with resource and STA checks against the retained baseline. Carry the verified public 64/public 96 history forward for any later format-consolidation decision. G08.FM remains open; this audit does not close it. F06 and G08.FM were not investigated or changed, and G06/G10 sequential architecture was not revisited.

## 34. git diff --stat

```text
(empty)
```

Untracked investigation scripts, fixtures, logs, source snapshots and this report are not counted by git diff. All 204 tracked files match the initial baseline; all 137 controlled build inputs are checked, with only the isolated controller replacement. No generated Quartus artifact is tracked.

## 35. git status --short

```text
?? tests/
```

Nothing staged. HEAD remains 7fcd5e12847eedf9e97a44dc937c3dbac3205f7c. No commit, push or PR. Previous untracked test directories are preserved; experimental G06 sequential RTL is neither applied to production nor included in this build. [Hygiene proof](hygiene.json).

