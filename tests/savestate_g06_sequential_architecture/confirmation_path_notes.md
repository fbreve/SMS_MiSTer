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
