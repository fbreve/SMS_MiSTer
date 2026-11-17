# Physical acceptance and timing analysis

The primary candidate **failed routing**. Its resource table is provisional. There is no completed primary TimeQuest result, no valid primary worst setup/hold path, and no usable placed-ALM gain proven under the unchanged production seed. The alternate-seed result is reported separately below. The stop-on-failure driver correctly did not run assembler or STA after failed fitting. Baseline timing must not be copied into the candidate column.

| Run | Seed | Map | Fit | Assembler | STA | Setup | Hold |
|---|---:|---|---|---|---|---|---|
| Current production |1|PASS|PASS|PASS|PASS|+0.105ns|+0.206ns|
|A|1|PASSED|FAILED|NOT RUN|NOT RUN|N/A|N/A|
|confirmation|2|PASSED|PASSED|PASSED|PASSED|-0.100ns|+0.244ns|

The completed baseline global worst setup clock is HDMI at+0.105ns; emulation clock setup is+0.635ns. Existing partially unconstrained paths remain. The failing primary has unknown timing violation count, not zero. No unrouted timing estimate is treated as signoff.

## Observed primary failure

Fitter placement stage completed; routing then emitted:

- Info188005: large hold-delay demand and reducing delays to try to converge.
- Warning16684: excessive routing congestion, predicted setup/hold risk.
- Warning16618: routing terminated due to congestion.
- CriticalWarning188026: failed to route.
- Error170143: final fitting attempt unsuccessful.
- Error11802: cannot fit design.

`quartus_A/fit.log` ends unsuccessful,2errors/10warnings; fit elapsed26m06s. Early routing estimate average42%, peak65% in regionX45_Y23..X55_Y34 does not mean all routing resources are available at each location. The failed-report table later shows average44.7% and peak total/H/V66.2/66.3/93.3%. Baseline completed table is49.5% average and79.2/78.5/81.4% peak. These are different completion states; lower global average is not a successful routing improvement.

## Locality, hold repair and fanout

Primary occupies4,099/4,191LABs versus baseline4,106 (both98%). Reported ALMs fall36,983vs38,598, but active-LAB footprint barely changes. The extra two M10Ks and new local decode/read-reduction/write-enable topology change physical locality. Their separate causal contribution to the failure is **not proven**. No congestion-path partition or seed-independent root-cause assertion is made.

Aggregate hold-repair delay, emulation domain:4,655.6ns primary vs6,528.0ns baseline. HDMI675.8vs518.5ns; primary also reports133.4ns audio. These are sums across paths, not worst-path slack. A claim that increased total emulation hold repair caused the failure would contradict the measured sum. The detailed table includes existing HDMI/EEPROM paths; its largest repair row is not a completed candidate worst timing path.

Baseline top non-global fanout includes ARM9,663,z80_set5,920,vdp2_regs_set5,454 and sprite-ring controls~4,800. Primary top entries are system comb~6(4,455),comb~7(4,165),top comb~80(1,128); z80_set703. Source hierarchy suggests selected local control consequences, but opaque comb names alone do not prove exact logic identity. Global fanout reduction does not remove local routing pressure. `physical_diagnostics.json` retains the20 top rows and both full report locations.

## Area movement, not additive causality

Primary mappedFF36,892 vs46,289 (-9,397); provisional fittedFF36,558vs48,948 (-12,390). Provisional logicALUT52,434vs47,032 (+5,402). Fitter hierarchy allocation estimates: controller placed6,405.9vs10,836.9; primary VDP6,155.2vs5,081.1; secondary6,068.8vs5,106.7. Local sprite entities also grow. These estimates are not additive attribution: shared packing, absorbed logic and allocation can cross hierarchy boundaries. They support the structural observation that narrow access replaces shadow storage while adding local decode/merge and reduction costs.

The reported route-throughALUT8vs18,182 is **not** an18,174 routing-ALUT optimization: the candidate routing failed. Packing estimates and all failed-fit resource percentages remain provisional.

## Warning review

New primary numeric warning types10230,16618,16684,169069,188026 are retained in `A_results.json`.

- **10230:** sprite local address expression is9bits assigned to8. Engine invariant index0..299 and owner subtraction yield local address0..149, so the dropped bit is zero for every issued access. Unit tests cover every address/owner; this is a bounded-width diagnostic, not ignored arbitrary truncation. Source remains frozen; it was not edited during builds.
- **16618/16684/188026:** material new routing failure diagnostics; acceptance fails.
- **169069:** following8constant-datain pins are listed on the unsuccessful-fit reporting path. The137 production source/config inputs outside the isolated substitutions and the top-level pin connections are unchanged; no pin assignment or connectivity fix was attempted. The fitter warns such connectivity can affect fitting.
- Baseline171167 (ignored assignments) is absent from this failed-report message set; this is not evidence that assignments were fixed. SameQSF,SDC and IP are retained and fitting stopped at a different point.

Existing I/O power-up/unused/initial-value and partial-constraint diagnostics remain; raw messages and normalized differences are retained, rather than comparing counts alone.

## One controlled confirmation

Seed2 uses identical candidate/source/settings, with only the explicit SEED assignment changed and fresh source-only build. Result: PASSED; reported placed38012,needed35214,FF39626,M10K490,bits3827650,DSP39. Setup-0.100ns,hold+0.244ns. Seed2 routes but fails timing; no candidate is timing-qualified. Routing success only in the alternate seed demonstrates seed sensitivity. No paired seed2 production baseline was built. Detailed path review follows:

Seed2 completes map/fit/assembler/STA, but **does not meet timing**: setup-0.100ns, hold+0.244ns. One setup clock-summary check fails; HDMI endpoint TNS is-2.016ns. The ten requested worst setup paths are all violated; this is not an exhaustive count of all violating paths. Other summary checks have nonnegative slack/TNS.

Both detailed reports use the **Slow1100mV100C** model and unchanged SDC. [Baseline setup](baseline_paths_setup.rpt) reproduces+0.105ns; [confirmation setup](confirmation_paths_setup.rpt) reproduces-0.100ns. [Confirmation hold](confirmation_paths_hold.rpt) reproduces+0.244ns.

| Property | Production seed1 | Candidate seed2 |
|---|---|---|
| Worst setup launch | HDMI shadowmask `dout[20]` | HDMI shadowmask altshift_taps RAM `ram_block5a0` |
| Worst setup endpoint | HDMI OSD `nrdout1[20]` | HDMI OSD `pixcnt[8]` (others have similar violations) |
| Clock | pll_hdmi counter0/divclk | same |
| Setup relationship |6.732ns|6.732ns|
| Clock skew | -0.568ns | -0.736ns |
| Data delay |5.859ns|5.896ns|
| Slack |+0.105ns|-0.100ns|
| Emulation-clock worst setup |+0.635ns|+0.773ns|
| Global worst hold |+0.206ns|+0.244ns|

The new worst path is in the existing **HDMI shadowmask-to-OSD infrastructure**, not the local sprite-state port, snapshot RAM or G10 replay logic. The failing path has2logic levels and5.896ns data delay, of which4.893ns (83%) is interconnect in the detailed report. The whole emulation clock domain remains positive at+0.773ns; the serialized port does not set the measured global worst path.

This is consistent with an indirect global placement/routing effect, not evidence of a functional defect or a direct new sequential-port timing arc. Baseline and control also use different seeds, so the-0.205ns global worst-slack change cannot be assigned solely to the RTL architecture. A paired production seed2 baseline was not built. Different worst endpoints also prevent treating the two data-delay/skew rows as the same logical path before/after.

Candidate seed2 reports38,012placed ALMs (-586),35,214needed (-1,961),39,626fitted FF (-9,322),490M10Ks (+2), and logicALUT52,448 (+5,416). It occupies4,144/4,191LABs (99%) vs4,106 (98%) baseline. Completed average interconnect53.1% vs49.5%, and peak total/H/V81.9/83.5/83.9% vs79.2/78.5/81.4%. These completed-route figures are valid physical evidence, unlike the primary failed-route route-through count. They show that removing shadow FF has not yielded a robust routing/timing improvement.

**No timing optimization was performed.** The same candidate source was retained. No SDC, hold-fix setting, clock, fitter effort, local decode, RAM geometry or port width changed after the gate. This failed timing result completes the bounded experiment with decisionE.

The first read-only path-analysis invocation lacked the process-local Z: mapping and did not open a project. It produced no timing evidence. After mapping the verified repository path, the retry and baseline analysis completed successfully, and reproduced the existing slacks without rebuilding or changing inputs. Source/hash verification follows in final_integrity.json.

## Acceptance

**E. FUNCTIONAL OR TIMING RISK - DO NOT CONVERT.** Functional proof passes, but the physical routing/timing gate does not establish a robust usable conversion. No SDC, hold optimization setting, fitter effort, RTL, clock, width or RAM packing was changed to rescue the candidate. Production F01/v17 remains intact. The next recommendation is5:reconsider capacity strategy, using this decode/locality evidence before authorizing another architecture or production change.
