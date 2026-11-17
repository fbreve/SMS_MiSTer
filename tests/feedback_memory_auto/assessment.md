**Recommendation: retain FeedbackMemory's forced-logic implementation. Stop after seed 1; do not run seed 2 or adopt this change.** The independent AUTO experiment is functionally qualified, but it fails the whole-design acceptance criteria: placed ALMs increase, setup margin falls by 218 ps (43%), and video retiming changes remain unexplained. No reproducible two-seed resource benefit is established.

The fresh control exactly reproduces the retained baseline's measured ALMs, registers, M10Ks, DSPs, logic/routing ALUTs and setup/hold minima. The full source-only baseline/AUTO pair completed all eight map/fit/asm/sta stages successfully with Quartus Prime Lite 17.0.2 Build 602, seed 1 and identical settings. Only `rtl/VM2413/feedbackmemory.vhd:57` differs: deletion of its forced-logic attribute. Original PhaseMemory and RegisterMemory are present in both build copies.

Local attribution improves: FeedbackMemory's needed/placed ALMs fall from 51.7/75.7 to 9.2/9.5 and its registers from 106 to 6. These fractional hierarchy attributions do not predict additive whole-design savings. Whole-design needed ALMs fall by only 19, placed ALMs rise by 5, and logic ALUTs rise by 26. One additional M10K is consumed for 90 bits. The fitter explicitly reports MLAB ineligibility: **No - Unsupported Mixed Feed Through Setting**. The actual implementation is a single-clock, simple dual-port 9-by-10 M10K at `M10K_X76_Y22_N0`, mixed-port **Old data**, with no MLAB. Total M10Ks become 488/553, leaving 65.

All seven functional qualifications passed. RTL and mapped-bank tests each made 864,600 checks across 216,114 cycles; native and mapped full-FM tests each ran 946,616 cycles. Native savestate testing passed eight restore cases over 8,482,683 cycles; native-reference and mapped savestate replays each passed 2,222,128 cycles, including 56,160 nonzero-audio checks. No functional or savestate regression was observed in this coverage. This is not formal enumeration of all 2^90 stored states, hardware validation, or post-route timing simulation.

Final setup/hold TNS is zero in both builds, and the normalized warning sets are identical (66 distinct warning lines, including 38 critical warnings). Positive slack alone does not satisfy the requested preservation of timing margin.

### HDMI/scaler evidence

Both worst paths are in the same HDMI output-clock domain, with the original 6.732 ns relationship and Slow 1100mV 100C model. The unchanged SDC was read into each newly fitted database. Source reports are [baseline_setup.rpt](baseline_setup.rpt), [candidate_setup.rpt](candidate_setup.rpt), the targeted `*_poly_lum.rpt` files, and [path_summary.json](path_summary.json).

| Worst setup path statistic | Baseline | AUTO |
| --- | ---: | ---: |
| Slack (ns) | 0.508 | 0.290 |
| Data delay (ns) | 3.626 | 5.774 |
| Data cell subtotal (ns) | 1.696 | 3.023 |
| Data routing subtotal (ns) | 1.928 | 2.751 |
| Clock skew (ns) | -2.398 | -0.468 |
| Logic levels | 2 | 4 |

Baseline's worst path starts at the scaler line-buffer RAM `ascal:ascal|altsyncram:o_linf2[0].r[7]__8|altsyncram_m6n1:auto_generated|ram_block1a0~PORT_B_WRITE_ENABLE_REG` and ends at `ascal:ascal|o_vpix_inner[0].r[7]`. AUTO's starts at `ascal:ascal|o_hcpt[0]` and ends at `ascal:ascal|o_vcpt[6]`. These are different paths: their delay differences cannot be attributed to a single unchanged cone. Report rounding and small additional terms can prevent the displayed cell/routing subtotals from summing exactly to reported data delay.

Physical-retiming report entries change from 708 to 697 overall, 383 to 377 in the scaler, and 49 to 45 in the luminance families. First-pass estimated retiming benefit changes from 279 to 73 ps. This is **not** RegisterMemory AUTO's complete loss of physical retiming: the FeedbackMemory candidate still has 697 entries and retimed luminance endpoints. Nevertheless the video transformation set differs, and the mechanism selecting a different set is not established here.

The targeted `o_vpix_inner` to `o_poly_lum` family actually improves in its worst reported slack, from 0.533 to 1.160 ns, while the global scaler worst case deteriorates. Thus the evidence does not support claiming that luminance retiming loss directly caused the 218 ps regression. It supports an indirect whole-design physical-optimization/placement change; proving its specific cause would require further investigation. No timing fix or additional experiment was attempted.

Final fitter interconnect results also differ from the earlier router estimates:

| Final interconnect utilization (total / horizontal / vertical) | Baseline | AUTO |
| --- | --- | --- |
| Average | 28.9% / 29.0% / 28.7% | 29.8% / 29.9% / 29.5% |
| Peak | 53.7% / 54.6% / 56.4% | 48.7% / 50.5% / 61.2% |

Average use rises despite fewer routing ALUTs; vertical peak use also rises. Router estimates of 25% average and 46%/42% peak are preliminary and are not the final utilization values above.

### Acceptance and stopping decision

| Criterion | Result |
| --- | --- |
| No functional/savestate regression | Passed the stated simulation coverage |
| Reproducible whole-design resource savings | Not established; seed 1 placed area increases |
| No material timing-margin loss | Failed: setup slack decreases 218 ps |
| No unexplained video-retiming loss | Not satisfied: fewer scaler/luminance entries, mechanism unresolved |

The unfavorable result does not depend on the conservative 50 ps second-seed screening threshold: it also fails placed-area savings and video-retiming preservation. Under the user's conditional seed-2 instruction, a second seed is not warranted. No cross-seed consistency claim is made.

Preservation checks match all 8,828 protected existing files and 127 branch references, including the retained fitted databases and prior reports. Master and v19 remain unchanged. The new `experiment/feedbackmemory-auto-inference` branch points to `8443a0d19a88aff7a5900011bccf386daf146945`; its separate worktree contains only the uncommitted attribute deletion. The original PhaseMemory and RegisterMemory worktrees retain their previous edits. No commit, push, merge or PR was made. Both new fitted databases are retained and ignored by Git. The experiment stops here.

The generated measurements and qualification details follow.
