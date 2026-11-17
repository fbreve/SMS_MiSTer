# Savestate FPGA resource-growth audit

**Decision: C. PERFORM TARGETED RESOURCE OPTIMIZATION BEFORE F01.** The dominant measured growth is G06/G10 sprite snapshot and restore implementation, not G05 alone or demonstrated compatibility bloat. No production change or Quartus invocation was made for this audit.

## 1. Current HEAD

`cb2e8615128d61adb996ada68e6bbdcc314c20f6`, unchanged. Investigation branch: `investigate/savestate-resource-growth`. Current HEAD and post-G12 checkpoint are identical; there is no additional current-HEAD cost.

## 2. Current savestate version

v16: MIXER_MAGIC=0x484310 in rtl/savestates.sv. G12 changes request restart ordering without changing that format.

## 3. Controlled Quartus configuration

Quartus Prime Lite **17.0.2 Build 602**, Cyclone V **5CSEBA6U23I7**, project/revision **SMS**, top **sys_top**, seed **1**, MISTER_FB=1; normal HDMI/framebuffer configuration. Root SMS.qsf normalized SHA256 is identical in all retained trees: `c8cc9727eae0e4e78549db15da75373427e79729ff58c4bb287b06d0e7926405`.

Source-only isolated builds, unchanged files.qip/sys Tcl/QIP/SDC/IP sources, STANDARD FIT, HIGH PERFORMANCE EFFORT, SPEED, final placement ALWAYS, ALM_REGISTER_PACKING_EFFORT LOW, automatic register packing NORMAL, physical synthesis combinational optimization/register duplication/retiming enabled, router LCELL insertion/duplication enabled. This is the established configuration, not an area-optimized alternative. Refer to the retained SMS.qsf and [measurements.json](measurements.json).

Build dates vary across the historical sequence. Pairwise controls use matched dates; G06/G10, G05, G08 and G12 fresh controls reproduce preceding retained endpoints exactly, including timing. Thus this is a chain of controlled incremental comparisons, not a claim that every build used one date or a multi-seed statistical sample. Path aliases are environmental only. No old RTL was adapted.

## 4. Complete checkpoint/commit map

- **Historical pre-fix**, untagged: `8443a0d19a88aff7a5900011bccf386daf146945`.
- **F07 HCounter**, v1: `60c6552afdbc87dd6f7f3ccfbab14ee41be7195e`.
- **F02 GG I/O**, v2: `02838b753751530576045c3c15cbfafa684c5f6e`.
- **F08 MD6**, v3: `e090434c449d77c506b9c46548399da4ab76d119`.
- **F03/F04 EEPROM**, v4: `b0f4b710d1d182635a59c238a6a0341bf3d8ba7c`.
- **F05 SC RAM**, v5: `e4a1ac90a5beed09218cb9720af16ae39445a6e1`.
- **F09 Master Tap**, v6: `52fb7496aeeaf2227e332194e06ec2cdfcf43932`.
- **F10 Paddle**, v7: `77147af4b1c0657d99bfaa840bcb17ad0be5d658`.
- **F11 Lightgun**, v8: `dcbe06d5527f96d3fb172472aaed44c3845a1e43`.
- **F12 System E Pause**, v8: `b61f307dcb161a6ac9a70fd544d435436807191d`.
- **F13 mapper history**, v9: `eede89d01a6441906dbbda237865a0cbc761d830`.
- **F14 Evolution selector**, v10: `ff9d66b79c20f90cea53d5fd78ae8f8021462a53`.
- **F15 Evolution pending**, v11: `d1df5902e4e671ed0cb87e770b43b15da53a3a92`.
- **F16 CPU NMI**, v12: `faf7036e4450027f79cc639a731053dca29840ca`.
- **G01 CPU restart**, v13: `8ffd15e2a7e530c0d77b07c6eeae3e8dc0aa0c8a`.
- **G06/G10 CPU/VDP restart**, v14: `58583189b5c650dc6658ef467e8dcb72d9f6e6c2`.
- **G05 background pipeline**, v15: `f205b05dc058fc5f7f2432779b61e8f3b0e22519`.
- **G08.release mixer/PSG**, v16: `08cf1426bfd2e1f2a73fdb25aaf57715d408db11`.
- **G12 ROM request restart**, v16: `cb2e8615128d61adb996ada68e6bbdcc314c20f6`.

F03/F04 are one EEPROM commit; G06/G10 are one coupled implementation commit. F12 and G12 do not increment the format. No other commits intervene in the first-parent sequence from 8443a0d to HEAD. Full subjects are in measurements.json.

## 5. Existing-report measurements

**EXISTING CONTROLLED** for all 19 checkpoints. [source_verification.json](source_verification.json) verifies **134 tracked build inputs per checkpoint** against its exact Git revision; no missing inputs or mismatches. Two additional retained backup/original manifest files are unchanged and unused. Sources external to those tracked inputs match the current retained environment. All selected fits successful; all selected timing summaries report zero negative-TNS categories.

The scan also retained an **EXISTING BUT NOT DIRECTLY COMPARABLE** G06/G10 intermediate failed-congestion implementation (39,680 needed /39,698 placed). Its RTL is an abandoned prototype, not commit 5858318; exclude it from chronological deltas. Alternate EEPROM multi-seed experiments likewise are not seed1 timeline checkpoints. **MISSING: none** of the requested final checkpoints or requested scalar resource metrics. Existing evidence includes fit/map/STA summaries, full fit/map reports and task-specific build/source manifests. [measurements.json](measurements.json) enumerates the selected and auxiliary immediate build trees; this is not an inventory of every historical experiment under tests/.

## 6. Rebuilt checkpoints

**None.** Mining supplies a source-verified controlled endpoint at every requested checkpoint, including both sides of G01, G06/G10 and G05. The minimum missing-checkpoint rebuild set is empty. Additional fits would not bracket an unknown transition; no Quartus process was started.

## 7. Full chronological resource table

|Checkpoint / feature|Commit|Format|Needed|ΔN|N %|Placed|ΔP|P %|P−N|P/N|Synth FF|Fit FF|ΔFF|M10K|Mem bits|DSP|Setup ns|Hold ns|Evidence|
|---|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|
|Historical pre-fix|8443a0d|untagged|26,465|0|63.147%|31,531|0|75.235%|5,066|1.1914|34,857|35,709|0|487|3,809,858|39|0.508|0.144|[historical](../savestate_hcounter/baseline/output_files/SMS.fit.summary)|
|F07 HCounter|60c6552|1|26,532|+67|63.307%|31,628|+97|75.466%|5,096|1.1921|34,888|35,817|+108|487|3,809,858|39|0.354|0.188|[hcounter](../savestate_hcounter/candidate/output_files/SMS.fit.summary)|
|F02 GG I/O|02838b7|2|26,656|+124|63.603%|31,852|+224|76.001%|5,196|1.1949|35,158|36,100|+283|487|3,809,858|39|0.434|0.153|[gg_io](../savestate_gg_io/candidate/output_files/SMS.fit.summary)|
|F08 MD6|e090434|3|26,618|-38|63.512%|31,810|-42|75.901%|5,192|1.1951|35,256|36,237|+137|487|3,809,858|39|0.694|0.242|[md6](../savestate_md6/candidate/output_files/SMS.fit.summary)|
|F03/F04 EEPROM|b0f4b71|4|26,914|+296|64.219%|32,177|+367|76.776%|5,263|1.1955|35,498|36,452|+215|487|3,809,858|39|0.636|0.246|[eeprom](../savestate_eeprom/candidate/output_files/SMS.fit.summary)|
|F05 SC RAM|e4a1ac9|5|26,958|+44|64.324%|32,220|+43|76.879%|5,262|1.1952|35,506|36,355|-97|487|3,809,858|39|0.409|0.246|[sc_ram](../savestate_sc_ram/candidate/output_files/SMS.fit.summary)|
|F09 Master Tap|52fb749|6|27,083|+125|64.622%|32,297|+77|77.063%|5,214|1.1925|35,547|36,542|+187|487|3,809,858|39|0.687|0.205|[master_tap](../savestate_master_tap/candidate/output_files/SMS.fit.summary)|
|F10 Paddle|77147af|7|27,150|+67|64.782%|32,413|+116|77.340%|5,263|1.1938|35,616|36,556|+14|487|3,809,858|39|0.412|0.242|[paddle](../savestate_paddle/candidate/output_files/SMS.fit.summary)|
|F11 Lightgun|dcbe06d|8|27,369|+219|65.304%|32,644|+231|77.891%|5,275|1.1927|35,716|36,598|+42|487|3,809,858|39|0.408|0.158|[lightgun_fix](../savestate_lightgun_fix/candidate/output_files/SMS.fit.summary)|
|F12 System E Pause|b61f307|8|27,189|-180|64.875%|32,587|-57|77.755%|5,398|1.1985|35,716|36,649|+51|487|3,809,858|39|0.525|0.245|[systeme_pause_fix](../savestate_systeme_pause_fix/candidate/output_files/SMS.fit.summary)|
|F13 mapper history|eede89d|9|27,359|+170|65.280%|32,589|+2|77.759%|5,230|1.1912|35,757|36,763|+114|487|3,809,858|39|0.435|0.202|[mapper_detection_fix](../savestate_mapper_detection_fix/candidate/output_files/SMS.fit.summary)|
|F14 Evolution selector|ff9d66b|10|27,920|+561|66.619%|32,961|+372|78.647%|5,041|1.1806|35,877|36,959|+196|487|3,809,858|39|0.582|0.232|[evolution_selector_fix](../savestate_evolution_selector_fix/candidate/output_files/SMS.fit.summary)|
|F15 Evolution pending|d1df590|11|27,388|-532|65.350%|32,692|-269|78.005%|5,304|1.1937|35,883|36,816|-143|487|3,809,858|39|0.358|0.203|[evolution_pending_fix](../savestate_evolution_pending_fix/candidate/output_files/SMS.fit.summary)|
|F16 CPU NMI|faf7036|12|27,416|+28|65.416%|32,784|+92|78.225%|5,368|1.1958|35,892|36,840|+24|487|3,809,858|39|0.540|0.246|[cpu_nmi_fix](../savestate_cpu_nmi_fix/candidate/output_files/SMS.fit.summary)|
|G01 CPU restart|8ffd15e|13|27,368|-48|65.302%|32,684|-100|77.986%|5,316|1.1942|35,896|36,831|-9|487|3,809,858|39|0.483|0.213|[g01_cpu_restart_fix](../savestate_g01_cpu_restart_fix/candidate/output_files/SMS.fit.summary)|
|G06/G10 CPU/VDP restart|5858318|14|35,419|+8051|84.512%|38,142|+5458|91.009%|2,723|1.0769|45,499|48,002|+11171|487|3,809,858|39|0.384|0.226|[g06_g10_fix](../savestate_g06_g10_fix/quartus/output_files/SMS.fit.summary)|
|G05 background pipeline|f205b05|15|35,945|+526|85.767%|38,718|+576|92.384%|2,773|1.0771|45,808|48,385|+383|487|3,809,858|39|0.211|0.232|[g05_background_fix](../savestate_g05_background_fix/quartus_v15/output_files/SMS.fit.summary)|
|G08.release mixer/PSG|08cf142|16|36,068|+123|86.061%|38,816|+98|92.618%|2,748|1.0762|45,808|48,258|-127|487|3,809,858|39|0.141|0.243|[g08_release_fix](../savestate_g08_release_fix/quartus_v16/output_files/SMS.fit.summary)|
|G12 ROM request restart|cb2e861|16|36,300|+232|86.614%|39,001|+185|93.059%|2,701|1.0744|45,808|48,428|+170|487|3,809,858|39|0.465|0.198|[g12_sdram_fix](../savestate_g12_sdram_fix/quartus_candidate/output_files/SMS.fit.summary)|

Deltas are against the immediately preceding row, baseline delta 0. Every resource measurement is EXISTING CONTROLLED. Memory/DSP columns are constant. All timing violation counts are 0. Full hashes are in item 4. Current HEAD duplicates the final G12 row. “Needed” is the fitter’s packing-adjusted estimate, not a pure synthesis logic count; “placed” is the physical placement count.

## 8. ALMs-needed growth

26,465 → 36,300: **+9,835**, 63.147% → 86.614%. G06/G10 contributes8051 (81.86% of net growth). Negative increments at MD6, F12, F15 and G01 show remapping effects; adding functionality does not force a monotonic needed count.

## 9. ALMs-placed growth

31,531 → 39,001: **+7470**, 75.235% → 93.059%. G06/G10 contributes5458 (73.07% of net growth). The F16→G05 interval is +5934: G01−100, G06/G10+5458, G05+576. G05 accounts for 9.71% of that interval, not the entire rise.

## 10. Register growth

Synthesis:34,857→45,808, **+10,951**. Fitted:35,709→48,428, **+12,719**. G06/G10 accounts for 9603 synthesis FF and11171 fitted FF; G05 adds 309/383. G08 and G12 add 0 synthesis FF although fitted counts change−127/+170. Physical duplication/retiming and mapping account for fitted-vs-synthesis differences; fitted deltas do not directly count new guest state.

## 11. M10K growth

487→487 /553; delta 0 at every checkpoint. No audited fix adds block RAM.

## 12. Memory-bit growth

3,809,858→3,809,858 /5,662,720; delta 0 throughout. Snapshot growth is implemented in registers, not inferred M10K storage.

## 13. DSP growth

39→39 /112; delta 0 throughout.

## 14. Placed-minus-needed growth

5066→2701, **−2365** net. Full raw incremental distribution: F15 Evolution pending: +263; F12 System E Pause: +123; F02 GG I/O: +100; F03/F04 EEPROM: +71; F16 CPU NMI: +64; G05 background pipeline: +50; F10 Paddle: +49; F07 HCounter: +30; F11 Lightgun: +12; F05 SC RAM: -1; F08 MD6: -4; G08.release mixer/PSG: -25; G12 ROM request restart: -47; F09 Master Tap: -48; G01 CPU restart: -52; F13 mapper history: -168; F14 Evolution selector: -189; G06/G10 CPU/VDP restart: -2593. Positive differences are packing estimates, not independently removable cells. G06/G10 decreases this gap2593 while placement rises5458.

## 15. Placed/needed-ratio growth

1.1914→1.0744: ratio declines. All raw incremental ratio changes, chronological: F07 HCounter +0.0006; F02 GG I/O +0.0029; F08 MD6 +0.0001; F03/F04 EEPROM +0.0005; F05 SC RAM -0.0004; F09 Master Tap -0.0027; F10 Paddle +0.0013; F11 Lightgun -0.0011; F12 System E Pause +0.0058; F13 mapper history -0.0074; F14 Evolution selector -0.0106; F15 Evolution pending +0.0131; F16 CPU NMI +0.0021; G01 CPU restart -0.0016; G06/G10 CPU/VDP restart -0.1174; G05 background pipeline +0.0003; G08.release mixer/PSG -0.0010; G12 ROM request restart -0.0018.

Raw placed ranking: G06/G10 CPU/VDP restart: +5458; G05 background pipeline: +576; F14 Evolution selector: +372; F03/F04 EEPROM: +367; F11 Lightgun: +231; F02 GG I/O: +224; G12 ROM request restart: +185; F10 Paddle: +116; G08.release mixer/PSG: +98; F07 HCounter: +97; F16 CPU NMI: +92; F09 Master Tap: +77; F05 SC RAM: +43; F13 mapper history: +2; F08 MD6: -42; F12 System E Pause: -57; G01 CPU restart: -100; F15 Evolution pending: -269.

Raw needed ranking: G06/G10 CPU/VDP restart: +8051; F14 Evolution selector: +561; G05 background pipeline: +526; F03/F04 EEPROM: +296; G12 ROM request restart: +232; F11 Lightgun: +219; F13 mapper history: +170; F09 Master Tap: +125; F02 GG I/O: +124; G08.release mixer/PSG: +123; F07 HCounter: +67; F10 Paddle: +67; F05 SC RAM: +44; F16 CPU NMI: +28; F08 MD6: -38; G01 CPU restart: -48; F12 System E Pause: -180; F15 Evolution pending: -532.

The ranked distribution has one dominant transition (5458 placed), a second tier576/372/367, then231 and smaller. “Major” below selects the top three **placed increases**, rather than imposing an arbitrary utilization percentage. F14 is separately significant because its561 needed increase exceeds G05’s526. Overhead increases are separately ranked in item 14.

## 16. Major transition #1: G06/G10

32684→38142 placed (+5458);27368→35419 needed (+8051); synthesis FF+9603; fitted FF+11171. **A/B/C/E/F/H** are supported: two 4800-bit snapshot banks, restore paths into both VDP sprite pipelines, shared capture/load controls and routing. Controller synthesis FF4838→14439 (+9601); top adds 2. Controller ALUT5390→6003 (+613), while restore selection and global mapping add other cost. Whole-design fitted logic ALUT+5818 and routing ALUT+5399. Packing equation Δneeded=5458−(−2410)+183=8051. Aggregate packing improves (G is not the primary explanation). Physical FF beyond mapped increase is 1568. These findings come from synthesis_ledger.json, quartus_results.json and build_assessment.json in ../savestate_g06_g10_fix/.

## 17. Major transition #2: G05

38142→38718 placed (+576),35419→35945 needed (+526). **A/B/C**, with minor mapping/locality effects:278 snapshot bits across two 139-bit BG banks, synthesis FF+309, fitted FF+383. Fitted logic ALUT+909, routing ALUT+204. Δneeded=576−34−16=526. Controller fitted FF+288, background+69, other+26. Divide/modulo-by 6 reconstruction costs approximately107.4 estimated fitted ALMs across text-position helper entities. The required historical BG state is proven non-reconstructable; implementation encoding can still be compared later. See ../savestate_g05_background_fix/review.md and build_results.json.

## 18. Major transition #3: F14 Evolution selector

32589→32961 placed (+372),27359→27920 needed (+561). **A/B/C**, plus physical mapping.57 historical bits widen a partially-written snapshot; mapped FF+120 and fitted FF+196. Controller mapped ALUT5212→5861 (+649); mapper itself62→66 ALUT, unchanged175 FF. The 11:1 snapshot mux estimate is 399 LEs, not399 ALMs. Controller own fitted needed allocation+373.2; other estimated hierarchy+187.8. Δneeded=372−(−190)−1=561. Routing ALUT drops150, so a routing-cell explosion is not supported. Source and hierarchy evidence: ../savestate_evolution_selector_fix/resource_analysis.json and review.md.

## 19. Additional significant transitions

EEPROM is the close fourth placed increase:+367, needed+296, synthesis FF+242, fitted FF+215; protocol/history storage, RAM refill/control and mux paths (**A/B/C/F**). Lightgun adds 231 placed/219 needed and100 synthesis FF. F15 then removes269 placed/532 needed despite adding6 synthesis FF: global synthesis/fitter remapping dominates its negative aggregate. F13 adds 170 needed but only 2 placed as the estimated packing gap shrinks168; attributing that to large physical expansion would be wrong. G08/G12 are quantified separately. No extra threshold-selected transition is hidden.

## 20. G01 contribution

**−100 placed, −48 needed**, +4 mapped FF and−9 fitted FF. Minimal semantic predecessor class, validity/padding and CPU decode restore; no broad CPU microarchitecture serialization. No large placement jump occurs here. Controller mapped ALUT5399→5390; CPU858→880. Exact physical FF attribution is retained in ../savestate_g01_cpu_restart_fix/resource_analysis.json.

## 21. G06/G10 contribution

The chronological discontinuity is this commit, not G01 or G05. Two 4778-bit historical records padded to 4800 bits each explain the 9600-bit snapshot storage. Capture, hold, SAVE rotation, LOAD insertion and reset/default branches create multiway register-input muxes; live sprite pipelines also gain restore selectors. Current map reports8:1 over4736 primary bits (23680 estimated LEs) and9:1 over4736 secondary bits (28416 estimated LEs). These are pre-fit mux estimates and must not be added or converted directly to ALMs. The already-tried indexed transport failed congestion at39680 needed; sequential transport reduced needed by 4261 and routed. This supplies real evidence of implementation sensitivity, not a promise that another4261 can be recovered.

## 22. G05 contribution

Only **+576 placed**, versus +5458 in preceding G06/G10. Adds a smaller BG snapshot/restore cone. Both v14 and v15 fresh controlled builds exist and reproduce the earlier v14 endpoint. G05’s physical increase slightly exceeds its526 needed increase; overhead+50 and ratio1.0769→1.0771. This minor packing change cannot explain the earlier six-thousand-site interval.

## 23. G08 incremental cost

38718→38816 placed (**+98**);35945→36068 needed (**+123**); fitted FF48385→48258 (−127), mapped FF unchanged45808. Δneeded=98−30+55=123; fitted logic ALUT+72, routing ALUT−117. Mixer historical phase and pending-PSG preservation change temporal control rather than adding a broad payload bank. Aggregate overhead−25; no material new packing discontinuity. Setup0.211→0.141 ns; hold0.232→0.243 ns.

## 24. G12 incremental cost

38816→39001 placed (**+185**);36068→36300 needed (**+232**); fitted FF+170 with mapped FF unchanged45808. Existing-clock combinational request selection changes restart ordering. Δneeded=185−(−30)+17=232; fitted logic ALUT+411, routing ALUT+63. Mapped ALUT+385, every mapped entity’s own FF delta 0. Overhead−47; no material packing discontinuity. Setup improves0.324 ns; hold loses0.045 ns but remains positive. See ../savestate_g12_sdram_fix/resource_analysis.json and build_results.json.

## 25. Version-compatibility inventory

[compatibility_inventory.json](compatibility_inventory.json) records exact source sites and identifiers. There are **16 distinct 24-bit HC tag constants**, referenced in **89 source equality/inequality expressions**. Counts are syntax inventory, not distinct fitted comparators: synthesis shares equal expressions and prefix decode. Families:

|Cone|Compatibility behavior|
|---|---|
|HC01–HC0B|Chained tag membership selects HCounter, GG, MD6, EEPROM, SC, Tap, Paddle, gun, mapper and Evolution fields/read addresses|
|HC0C–HC10|modern_nmi_tag, modern_restart_tag, load_ext_magic fold newer formats onto predecessor payloads|
|has_* latches|Persist field presence across LOAD states; has_restart/has_background drive wide live restore defaults|
|is_old_format|64KiB size detection, game-ID bypass, old coordinate/IO/NVRAM handling|
|Legacy defaults|Zero missing BG/sprite/context state; legacy mapper/evolution/accessory defaults; pre-v16 mixer-phase normalization|
|Descriptor/padding validation|Current ownership, width, System E presence, reserved bits; much remains necessary even after consolidation|

Key controller sites:580–585,1893–1909,2136–2170,2189–2318,2618–2625. The artifact contains the source text with line numbers. Validity is distributed through top/system/VDP/CPU to select defaults. Repeated source checks are not proof of replicated gates.

## 26. Estimated compatibility cost

Structural estimate: a fully unshared implementation of the 16 tag tests spans384 bit comparisons plus membership OR trees, about 13 persisted version/presence flags (audio/MD/EEPROM/SC/Tap/Paddle/gun/mapper/Evolution/NMI/context/restart/BG), and version-controlled payload/default selection. Shared decode should be tens to low hundreds of LUT functions; this is an engineering order-of-magnitude estimate, **not measured ALMs saved**. Wide default/valid selectors can affect thousands of endpoints (has_restart fanout1415 currently), but a replacement public/current decoder would still need to distinguish missing historical state. Thus much cannot disappear merely by dropping intermediate tags.

No defensible isolated fitted-ALM saving is established. The measured lower bound on recoverable sites is 0; the broad upper envelope includes the controller and restore cones and is not a useful savings forecast. No compatibility-only ablation was authorized/performed. Existing hierarchy cannot distinguish shared current/legacy functions. In particular do not assign the 9600 required snapshot FF, the whole8051 needed delta, or all wide transport muxes to development compatibility. This uncertainty prevents selecting B based on an assumed large saving.

## 27. Restore-mux findings

|Target|Required current-state implementation|Compatibility amplification|
|---|---|---|
|Sprite / G06|Two 4800-bit capture/shift/load banks;4778 live bits each; multiway input mux and live restore enables|Legacy-zero path/has_restart adds choices; capture/shift/load/hold remains essential|
|BG / G05|Two 139-bit banks;9:1–11:1 mapped input mux groups; live address/priority/shifter restore; /6 and mod6 decode|has_background chooses literal legacy defaults; transport and text decode are current-format costs|
|CPU context|Three-bit class snapshot plus valid/padding; representative IR and NMI restore|Old images choose ordinary context; width is small|
|Peripheral protocol|GG114, MD46, Tap19, paddle32, gun46 snapshots and local restore controls|Absent-tag defaults and read-path branches; actual protocol history remains|
|Mapper history|18-bit snapshot, descriptor/padding validation|Legacy timer/evidence default, small field width|
|Evolution history|60-bit history and existing96-bit mapper image, multiway partial-write bank|v10/pending distinction and rejection; current pending/selector bits remain required|
|AudioMix/PSG|Existing raw state/divider plus historical mixer phase and coupled enable ordering|Legacy phase normalization; raw current snapshot/validation remains|
|System E|Independent second-VDP/sprite/BG/PSG state, second-bank selects, private CPU preparation|Absent second payload/default paths; dual-state ownership remains inherent|

These widths identify implementation targets, not independent additive fitted-resource estimates. [hierarchy_fanout_mux.json](hierarchy_fanout_mux.json) preserves mapped mux and fitted hierarchy rows at every checkpoint.

## 28. Freeze/restart fanout findings

Current non-global report: ST_ARM_FREEZE9669, z80_set5898, vdp2_regs_set5426, ST_LOAD_HDR_RD5272, sprite-bank controls4811/4800/4800, sprite data-address controls3464/3444, has_restart1415. G06/G10 already shows9511/5909/5418/5126 and4800-wide bank controls, has_restart1424. Thus the large control network appears with the large banks; recent G08/G12 increments do not create a second fanout regime. ss_freeze and preparation signals are synthesized into gates/encoded state; absence of their literal names from the top fanout list is not zero fanout. LOAD controls dominate several thousands of endpoints; version-derived has_restart is materially shared. Physical synthesis duplication is enabled. These reports support fanout/locality risk, but do not isolate an ALM delta caused solely by each control.

## 29. Packing/locality findings

Needed=A−B+C, where A is placed, B estimated recoverable by dense packing, C estimated unavailable. Current39001−3225+524=36300. Historical31531−(B−C)=26465, gap5066; current gap2701. G06/G10 improves aggregate gap2593 despite more routing ALUTs and physical FF duplication. Added snapshot FF and restore muxes are the principal structural cost; locality/control replication are secondary physical effects. Hierarchy allocations are estimates, not exact additive physical-site ownership. The LOW packing/high-performance settings are unchanged throughout; a settings change cannot explain the timeline. Changing packing effort later would be a separate experiment with timing risk, not a demonstrated free recovery.

## 30. Timing/resource correlation

Item7 tabulates both slacks against every resource checkpoint. Timing is nonmonotonic: GG adds 224 sites while setup improves0.080 ns; Tap adds 77 while setup improves0.278 ns; F14 adds 372 while setup improves0.147 ns; F16 adds 92 while setup improves0.182 ns; G12 adds 185 while setup improves0.324 ns. G06/G10 loses0.099 ns and G05 loses0.173 ns; G08 loses0.070 ns. All selected builds have positive worst setup/hold and zero negative-TNS categories. Current+0.465/+0.198 ns is better setup than several lower-placement checkpoints. Single-seed evidence gives measured margins, not a probability of future fit/timing success.

## 31. Logical ALM headroom

41,910−36,300 = **5,610 ALMs (13.386%)** by the fitter’s needed estimate. It is not a guaranteed synthesis-logic budget independent of packing.

## 32. Physical ALM headroom

41,910−39,001 = **2,909 sites (6.941%)**. This smaller physical reserve is the immediate ALM planning limit. Some needed-vs-placed gap is estimated recoverable, but recovering it has not been demonstrated under current timing constraints.

## 33. Register headroom

167,640−48,428 = **119,212 FF (71.112%)** nominally free. FF capacity is not the limiting count; dispersed FF/control placement can consume ALMs long before this ceiling.

## 34. M10K headroom

553−487 = **66 blocks (11.935%)**. Used88.065%. Granularity, port width and parallel access are important; a small bit count need not consume few blocks.

## 35. Memory-bit headroom

5,662,720−3,809,858 = **1,852,862 bits (32.720%)**. Only 66 physical M10Ks remain; multiplying66×10240 gives675840 bits in wholly free blocks. The larger nominal unused-bit count includes unused capacity in allocated blocks and is not all independently allocatable.

## 36. DSP headroom

112−39 = **73 DSP blocks (65.179%)**. No observed savestate fix consumes DSP; DSP capacity is not the relevant bottleneck.

## 37. 95% placement budget

The mathematical threshold is 39814.5 sites. **813 additional whole placed ALMs** keep utilization at or below 95%; the next site crosses it. Physical space remaining at that floor: 2096 sites. This is a capacity threshold, not an endorsed safe target.

## 38. 97% placement budget

The mathematical threshold is 40652.7 sites. **1651 additional whole placed ALMs** keep utilization at or below 97%; the next site crosses it. Physical space remaining at that floor: 1258 sites. This is a capacity threshold, not an endorsed safe target.

## 39. 98% placement budget

The mathematical threshold is 41071.8 sites. **2070 additional whole placed ALMs** keep utilization at or below 98%; the next site crosses it. Physical space remaining at that floor: 839 sites. This is a capacity threshold, not an endorsed safe target.

## 40. 99% placement budget

The mathematical threshold is 41490.9 sites. **2489 additional whole placed ALMs** keep utilization at or below 99%; the next site crosses it. Physical space remaining at that floor: 420 sites. This is a capacity threshold, not an endorsed safe target.

## 41. F01 capacity assessment

**HARD CAPACITY RISK:** no present overflow; ALMs have2909 placed sites and5610 needed estimate, M10K66 blocks. **PLACEMENT/PACKING RISK:** principal prospective risk; only 813 extra sites fit under 95%, while a single necessary historical-state addition recently cost5458. **TIMING RISK:** current build passes, but margins are finite and cannot be extrapolated from counts. There is no measured F01 implementation or justified F01 area estimate in this audit, so these figures cannot prove it fits or fails.

RAM migration is plausible for sequential transport storage but not automatically cheap: simultaneous capture and wide live restore impose width/port/banking demands. Two 4800-bit banks need only 9600 raw bits, yet a naive fully parallel implementation could exhaust66 spare blocks. A phased/banked implementation might reduce ALMs while using a modest number of M10Ks, but must preserve accepted-time capture and deterministic release. No such design is proposed or validated here. M10K granularity is the second limiting resource; spare DSP/nominal FF do not solve ALM placement.

## 42. Stable/public-format identification

Local Git release history identifies **SMS_20260823.rbf**, blob `26632aabd2f9db6b1f593f460e0701eb2591acce`, release commit `3ae7eec9cc2a9e02f824771e2e5652f5992ed906` (parallel-history release commit `ee73fc496b778192e3541419dd7dd4890a65293f` also exists). Release-associated RTL is **untagged 96KiB**,0x3000 DDRAM words per slot, NEW_SS_WORDS24574 (0x5FFE), SMS1/SMSB magic plus game signature; no HC01–HC10 development tags and no later exact-PSG extension. Do not call it v1 or v16.

An **older public64KiB format also exists**, in release `4d364780502d1c5d212ad06962a44341c3bbfeaf` /SMS_20260603.rbf:0x2000 slot words, SMS1 magic, old size16382. It is public history, not development compatibility. For the stated latest previously released-stable policy, the 96KiB20260823 format is the identified target; dropping the older public64KiB reader would be a separate explicit policy decision, not cleanup of an unreleased tag.

The local upstream/master reference and release tree supply this identification. No network freshness claim or bitstream-to-source reproducible-build attestation is made. Evidence distinguishes checked-in published binaries/source at release commits from private branch names/tags. [release_history.txt](release_history.txt) records commands/results and relevant source layout.

## 43. Consolidation opportunity

A future public/current two-format reader could remove HC01–HC0F membership ladders, intermediate version defaults, v10/v11 Evolution transitional rejection and some has_* selection. Keep public-format import defaults, current descriptors/reserved-bit validation, current complete state and transport checks. The latest public format also lacks sprite/BG/NMI/context history, so current-vs-public validity/default paths survive. Consolidation could simplify control but no measured recovery meets a resource target yet. It would not inherently eliminate the dominant9600 snapshot FF or current SAVE/LOAD muxing.

## 44. Inherent current-state cost

Historical necessity is established by earlier equal-image/different-future witnesses, not re-investigated here. Two independent4778-bit sprite records, two 139-bit BG records, CPU context/NMI, mapper/peripheral/Evolution protocol history and audio temporal state must be represented or coherently preserved. That does **not** prove the current padded register banks, bit encoding, input-mux structure, or transfer organization are area-minimal. Logical information and its physical implementation must remain separate.

## 45. Development-compatibility cost

The 16 HC tags and their membership/default chains are the removable development-version dimension; public96KiB and older public64KiB handling are not development-only. Counted source comparisons share hardware. Quantitative compatibility-only placed savings remain unmeasured; item 26 gives the structural estimate and explicit limits. Neither the F14 whole-design561 needed increase nor the G06/G10 whole-design8051 can be assigned to compatibility alone.

## 46. Potential optimization candidates

|Rank / future experiment|Expected resource target, not promised saving|Confidence|Correctness risk / regression scope|Before F01?|Obsolete after consolidation?|
|---|---|---|---|---|---|
|1 Sprite snapshot input/transport controls|9600 FF and8:1/9:1 wide mux cones; seek >=1000 placed-ALM recovery in a controlled comparison, no established saving|High target attribution; unmeasured savings|High temporal/ordering risk; full G06/G10, CPU/NMI, dual VDP, Pause, memory and repeated/stalled LOAD/SAVE|Yes, bounded experiment first|No; current state/transport remains|
|2 Localize/encode capture/LOAD gating|9669-fanout ARM,4800 bank controls; reduce physical replication/routing overhead|Medium target, low savings estimate|High freeze/restart risk; exact boundary and transport-independence matrix|Only coupled to 1 if causal|Partly; legacy control removal may alter topology|
|3 BG text-position decode/restore implementation|~107.4 estimated fitted ALMs in /6/mod6 helpers plus BG mux cone|Medium; raw-vs-encoded tradeoff unmeasured|Medium; G05 all modes, flips, text/graphics changes, both VDPs|Secondary if1 insufficient|Possibly if format encoding changes|
|4 Development tag consolidation|16 tags, decode/default trees; no defensible placed saving yet|High removability; low area confidence|High compatibility regression scope; actual public imports/current rejection tests|Not resource prerequisite without measurement|Yes, it is consolidation|
|5 Evolution partial-write snapshot organization|Current60-bit 11:1 mux estimate420 LEs plus other96-bit groups|Medium target; low global effect|Medium-high mapper menu/pending-op history regression|After dominant target|May partly simplify|
|6 Packing-effort / physical-synthesis settings experiment|2701 placed-needed gap; no guaranteed recovery|Low, placement-sensitive|Timing/fit risk across complete core; controlled same-source A/B and timing|Only after RTL-focused bounded experiment|No|

>=1000 is a proposed success criterion for a later experiment: it exceeds the 813-site reserve to 95% and is material against the 5458-site dominant addition. It is not an area forecast or an authorized optimization in this task.

## 47. Ranked optimization recommendation

First authorize a bounded same-format sprite snapshot/transport implementation experiment against committed cb2e861, preserving all proven state and boundary semantics, with simulation gates before controlled Quartus. Measure needed/placed/FF/M10K/slack and exact packing identity; reject proposals that merely move pressure into too many RAM blocks or lose restart behavior. Rank local control topology second, BG encoding third. Consolidation remains a planned compatibility simplification but is not supported as the first resource remedy by current area attribution. Stop the experiment if a worthwhile saving cannot be demonstrated; reassess rather than broadening into F01.

## 48. Decision gate

**C. PERFORM TARGETED RESOURCE OPTIMIZATION BEFORE F01.** Evidence: dominant growth localized to a source-verified 9600-bit snapshot/restore implementation; mapped wide muxes and ~4800–9669 fanout; previously measured 4261-needed implementation difference between failed indexed and routed sequential prototypes; current only 813 placed sites below 95%. This is more specific than a >90% utilization rule. A is not supported by any measured F01 budget; B lacks isolated compatibility saving and retains public/default needs; D is premature because the core fits/meets timing and a concrete implementation target exists. This recommends future work; it does not authorize or perform it.

## 49. Evidence limitations

Single seed and fixed performance settings; no seed distribution or isolated compatibility-area ablation. Build dates differ historically, bridged by matched-date controls reproducing prior endpoints; not every old candidate was rebuilt today. Fit “needed” and hierarchy are estimates, not a synthesized Boolean-minimum count. Fanout tables list only highest non-global nets and do not establish exact control-only cell cost. Mux LE estimates are not fitted ALMs. Existing controlled reports and source identity permit attribution; they do not prove a particular optimization saving or F01 fit. Public release identification uses local Git history, not a fresh online-release audit or binary decompilation. No F01/F06/FM functional investigation, production optimization or format change was performed.

## 50. git diff --stat

```text
(empty)
```

All 203 tracked regular files have unchanged SHA256; [integrity.json](integrity.json). No staged diff. New files are audit scripts/results/report only under this audit directory; prior untracked tests/ is preserved.

## 51. git status --short

```text
?? tests/
```

Nothing staged; no commit, push or PR. No Quartus run. Branch creation is the only Git metadata mutation.

## 52. Exact recommended next task

Authorize a bounded resource experiment on a new optimization branch from cb2e861, **only the G06 sprite snapshot/transport and associated shared controls**, retaining v16 bytes,4778 bits per VDP, accepted SAVE semantics and G10 deterministic release. Require baseline/new boundary, dual-VDP, Pause, CPU/NMI, repeated LOAD and transport-duration regressions; controlled same-config Quartus after simulations pass; report logical/physical ALM and memory/timing tradeoffs. Target >=1000 placed-ALM recovery with no correctness/timing regression; if not demonstrated, stop and report. Do not begin F01/F06/FM or consolidate formats as part of that bounded task. No implementation has been started here.

