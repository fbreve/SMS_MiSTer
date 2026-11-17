# v19 CPU restore-output alias: one paired seed-2 experiment

**REJECTED / NOT A QUALIFIED PAIRED IMPROVEMENT.** Both builds pass reported timing, but candidate routing ALUTs increase by105 and final total peak interconnect increases72.8%->72.9%. The placed saving is only4 ALMs. Failed gates: noRoutingALUTGrowth, noPeakRoutingGrowth. The seed-1 candidate remains failed. No production promotion is authorized or performed, regardless of this pair's outcome. Exactly two fresh implementations ran: original v19 seed2, then the retained alias seed2, sequentially on the same host.

## Verified source, qualification and configuration

Read the complete [original experiment](../cpu_restore_output_alias/review.md) and [timing diagnosis](../cpu_restore_alias_timing_diagnosis/review.md). HEAD remains **1b2a52d87d2659c908d4f9f846416d14bfd85bea**, branch **investigate/cram-memory-inference**, savestate **v19 / tag0x484313**. [preflight.json](preflight.json) and [preflight.js](preflight.js) verify all 204 tracked hashes, both 137-input retained seed1 manifests, retained evidence and the existing 40-case qualification before preparing the new builds. The old baseline manifest's historical HEAD label is not substituted for its actual verified v19 source contents.

The 40 cases' log hashes, terminal pass/error markers, compiled controller/real consumer/test sources, fixture hashes, source bridges, complete 196608-word image hash and qualification ledger were checked. Qualified totals remain **91413628 host clocks,209 consuming edges,495599 accepted writes and1591538 accepted reads**. All eight NMI triplets remain covered. The same 230-bit consuming-edge equality, native CPU/NMI/restart, compatibility, late rejection, transport-stall, SAVE-only, repeated LOAD, dual-VDP and Pause proof remains applicable. No tests were changed, weakened, masked or replaced; simulations were not rerun for a seed-only physical change. The existing ledger is source-bound, not a claim of new post-route functional simulation.

The retained candidate was copied byte-for-byte; no RTL variant was created. Its reverse transformation reproduces the original controller: output reg becomes wire, continuous z80_dir=z80_snap is added, and the sole registered copy assignment is removed. All snapshots, other output registers, z80_set, image bytes, public readers, DDR transport and constraints remain unchanged.

| Source / input | SHA256 |
| --- | --- |
| Original controller | e8de50db09447138fc661205fb9edd178d45e691819a056bad87631ef3d76557 |
| Existing alias controller | 0d6a000152980f2bd64bce3b847c82dd5a5acfa9aa1a001527ada929189e774f |
| Retained 40-case ledger | 72ecaf8cfdd48a88650950b79fd4655c1c7795cfe2abf72d7b41e6026361307e |
| Common seed2 SMS.qsf | 32b15ee0200f91c5c09307049d162f493f6502902eeba86ecdec6c4553e23583 |
| Common build_id.v | 5b35f414663a939035468cad510c62429d250fa24e1114e19f171e449bd5e5c1 |

[build_baseline2_inputs.json](build_baseline2_inputs.json) and [build_candidate2_inputs.json](build_candidate2_inputs.json) contain every input hash. Baseline2 differs from the retained seed1 source tree only by SEED1->2 in SMS.qsf. Candidate2 differs from that same tree by the identical seed edit and exact retained controller. **Between the two new builds, the only input difference is rtl/savestates.sv**; all other 136 inputs and build_id match. Fresh databases were used; no seed1 database was copied or rebuilt.

Quartus **17.0.2 Build602 Lite**, Cyclone V **5CSEBA6U23I7**, SMS/sys_top, **SEED2**, BUILD_DATE **261025**, MISTER_FB=1; same QSF/SDC/QIP/IP, STANDARD FIT, HIGH PERFORMANCE EFFORT, SPEED, final placement ALWAYS, LOW ALM register packing, NORMAL automatic packing and enabled physical optimization/duplication/retiming/router duplication. Both executions used one PowerShell process with unchanged inherited tool environment on the same host. [environment.json](environment.json) records host/tool executable hashes; all eight stage logs identify tool version and configuration. No seed3, alternate RTL, retry fit or changed constraints were used.

## Complete implementations and retained evidence

[build_pair.ps1](build_pair.ps1) runs map, fit, asm and sta for A, then the same four stages for B. Every stage returned success and completed its report. Tool success is distinguished from the timing/physical gate below. [workflow.log](workflow.log) records starts, ends and exit codes. Full source-isolated trees, databases, programming outputs, logs and reports remain in [quartus_baseline2](quartus_baseline2/) and [quartus_candidate2](quartus_candidate2/). Input manifests are rechecked after compilation and read-only timing queries.

| Build | Stage | Wall | Aggregate CPU | Peak virtual MB |
| --- | --- | --- | --- | --- |
| baseline2 | map | 00:11:39 | 00:03:14 | 6814 |
| baseline2 | fit | 00:19:54 | 01:29:58 | 10422 |
| baseline2 | asm | 00:00:31 | 00:00:31 | 5431 |
| baseline2 | sta | 00:00:25 | 00:00:50 | 6192 |
| candidate2 | map | 00:09:23 | 00:03:06 | 6815 |
| candidate2 | fit | 00:19:32 | 01:37:46 | 10530 |
| candidate2 | asm | 00:00:20 | 00:00:19 | 5425 |
| candidate2 | sta | 00:00:15 | 00:00:27 | 6169 |

No paired comparison uses seed1 as its denominator. The former seed1 failure remains historical evidence and is not overwritten or waived by these measurements.

## Paired resource and timing measurements

| Metric | Baseline seed2 | Candidate seed2 | Candidate minus baseline |
| --- | --- | --- | --- |
| Needed ALMs | 37139 | 37032 | -107 |
| Placed ALMs | 38463 | 38459 | -4 |
| Mapped FF | 46327 | 46097 | -230 |
| Fitted FF | 48793 | 48676 | -117 |
| Logic ALUT | 46834 | 46948 | 114 |
| Routing ALUT | 18254 | 18359 | 105 |
| M10K | 488 | 488 | 0 |
| Block memory bits | 3818050 | 3818050 | 0 |
| DSP | 39 | 39 | 0 |
| Recoverable ALMs | 1917 | 2021 | 104 |
| Unavailable ALMs | 593 | 594 | 1 |
| Worst setup ns | 0.401 | 0.524 | 0.123 |
| Worst hold ns | 0.235 | 0.238 | 0.003 |
| Reported violating timing groups | 0 | 0 | 0 |

Packing identities: baseline **38463-1917+593=37139**; candidate **38459-2021+594=37032**. Needed versus placed, logic versus routing ALUT, and source versus fitted registers are distinct measures; none is added to another as an independent ALM saving.

| Final interconnect utilization | Baseline2 total / H / V | Candidate2 total / H / V |
| --- | --- | --- |
| Average % | 49.4 / 48.9 / 50.8 | 48.8 / 48.3 / 50.3 |
| Peak % | 72.8 / 70.7 / 81.4 | 72.9 / 72.8 / 78.3 |

Final utilization is taken from the fitter's final average/peak rows, not preliminary router estimates. Routing gates below check total/H/V components without hiding a directional increase. All original rows are retained in paired_results.json and the fit reports.

| Gate | Result |
| --- | --- |
| bothPositiveTiming | PASS |
| noTimingViolations | PASS |
| lowerPlaced | PASS |
| noM10KGrowth | PASS |
| noRoutingALUTGrowth | FAIL |
| noAverageRoutingGrowth | PASS |
| noPeakRoutingGrowth | FAIL |
| noNewCritical | PASS |
| functionalSourceStillApplicable | PASS |
| intended230RegisterRemoval | PASS |

Both positive setup/hold and zero reported violations are required; if the baseline fails, a passing candidate is not a qualified paired improvement. The baseline passes these reported timing checks.

## Timing groups, TNS and violating endpoints

The configured STA reports identify **Slow1100mV100C** with final timing models. The same existing constraints/model and query definitions are used on both sides; this is not additional multi-corner signoff or a repair of inherited unconstrained categories. The compiled reports retain all configured setup, hold, recovery, removal and pulse-width groups:

| Type / full clock group | Baseline slack | Candidate slack | Baseline TNS | Candidate TNS |
| --- | --- | --- | --- | --- |
| Setup 'pll_hdmi / pll_hdmi_inst / altera_pll_i / cyclonev_pll / counter[0].output_counter / divclk' | 0.401 | 0.524 | 0 | 0 |
| Setup 'emu / pll / pll_inst / altera_pll_i / cyclonev_pll / counter[0].output_counter / divclk' | 0.551 | 1.077 | 0 | 0 |
| Setup 'sysmem / fpga_interfaces / clocks_resets / h2f_user0_clk' | 4.427 | 4.106 | 0 | 0 |
| Setup 'spi_sck' | 5.529 | 5.254 | 0 | 0 |
| Setup 'FPGA_CLK2_50' | 6.2 | 6.039 | 0 | 0 |
| Setup 'FPGA_CLK1_50' | 7.33 | 8.339 | 0 | 0 |
| Setup 'pll_audio / pll_audio_inst / altera_pll_i / general[0].gpll~PLL_OUTPUT_COUNTER / divclk' | 15.369 | 14.18 | 0 | 0 |
| Hold 'emu / pll / pll_inst / altera_pll_i / cyclonev_pll / counter[0].output_counter / divclk' | 0.235 | 0.238 | 0 | 0 |
| Hold 'pll_hdmi / pll_hdmi_inst / altera_pll_i / cyclonev_pll / counter[0].output_counter / divclk' | 0.257 | 0.256 | 0 | 0 |
| Hold 'pll_audio / pll_audio_inst / altera_pll_i / general[0].gpll~PLL_OUTPUT_COUNTER / divclk' | 0.27 | 0.262 | 0 | 0 |
| Hold 'sysmem / fpga_interfaces / clocks_resets / h2f_user0_clk' | 0.404 | 0.358 | 0 | 0 |
| Hold 'FPGA_CLK2_50' | 0.405 | 0.27 | 0 | 0 |
| Hold 'FPGA_CLK1_50' | 0.416 | 0.278 | 0 | 0 |
| Hold 'spi_sck' | 0.462 | 0.36 | 0 | 0 |
| Recovery 'pll_hdmi / pll_hdmi_inst / altera_pll_i / cyclonev_pll / counter[0].output_counter / divclk' | 3.987 | 4.1 | 0 | 0 |
| Recovery 'emu / pll / pll_inst / altera_pll_i / cyclonev_pll / counter[0].output_counter / divclk' | 5.399 | 3.877 | 0 | 0 |
| Recovery 'sysmem / fpga_interfaces / clocks_resets / h2f_user0_clk' | 7.196 | 7.042 | 0 | 0 |
| Recovery 'FPGA_CLK1_50' | 16.593 | 16.456 | 0 | 0 |
| Recovery 'FPGA_CLK2_50' | 17.608 | 17.866 | 0 | 0 |
| Removal 'sysmem / fpga_interfaces / clocks_resets / h2f_user0_clk' | 0.753 | 1.627 | 0 | 0 |
| Removal 'pll_hdmi / pll_hdmi_inst / altera_pll_i / cyclonev_pll / counter[0].output_counter / divclk' | 1.08 | 0.782 | 0 | 0 |
| Removal 'FPGA_CLK1_50' | 1.113 | 1.102 | 0 | 0 |
| Removal 'FPGA_CLK2_50' | 1.225 | 1.109 | 0 | 0 |
| Removal 'emu / pll / pll_inst / altera_pll_i / cyclonev_pll / counter[0].output_counter / divclk' | 2.038 | 1.286 | 0 | 0 |
| Minimum Pulse Width 'pll_hdmi / pll_hdmi_inst / altera_pll_i / cyclonev_pll / fpll_0 / fpll / vcoph[0]' | 1.122 | 1.122 | 0 | 0 |
| Minimum Pulse Width 'emu / pll / pll_inst / altera_pll_i / cyclonev_pll / fpll_0 / fpll / vcoph[0]' | 1.164 | 1.164 | 0 | 0 |
| Minimum Pulse Width 'pll_audio / pll_audio_inst / altera_pll_i / general[0].gpll~FRACTIONAL_PLL / vcoph[0]' | 1.196 | 1.196 | 0 | 0 |
| Minimum Pulse Width 'pll_hdmi / pll_hdmi_inst / altera_pll_i / cyclonev_pll / counter[0].output_counter / divclk' | 1.93 | 1.929 | 0 | 0 |
| Minimum Pulse Width 'sysmem / fpga_interfaces / clocks_resets / h2f_user0_clk' | 3.604 | 3.596 | 0 | 0 |
| Minimum Pulse Width 'spi_sck' | 4.206 | 4.213 | 0 | 0 |
| Minimum Pulse Width 'emu / pll / pll_inst / altera_pll_i / cyclonev_pll / counter[0].output_counter / divclk' | 7.875 | 7.877 | 0 | 0 |
| Minimum Pulse Width 'FPGA_CLK2_50' | 9.208 | 9.212 | 0 | 0 |
| Minimum Pulse Width 'FPGA_CLK1_50' | 9.21 | 9.204 | 0 | 0 |
| Minimum Pulse Width 'FPGA_CLK3_50' | 9.73 | 9.73 | 0 | 0 |
| Minimum Pulse Width 'pll_audio / pll_audio_inst / altera_pll_i / general[0].gpll~PLL_OUTPUT_COUNTER / divclk' | 18.928 | 18.909 | 0 | 0 |

[query.tcl](query.tcl) and [query.ps1](query.ps1) perform only read-only TimeQuest netlist loading, SDC evaluation, timing reports and name/location queries after both implementations finish. Global setup/hold lists use -npaths1000 -nworst1; core/HDMI and restricted cones use -npaths50 -nworst1 with full routing detail. One worst path is retained per physical endpoint, including actual duplicates. The global lists extend beyond all negative endpoints, so their negative count is bounded rather than inferred from a truncated failing list. No extra synthesis, fit or route was run for these queries.

| Build | Check | Violating physical endpoints | Endpoint TNS ns | Endpoints queried |
| --- | --- | --- | --- | --- |
| baseline2 | setup | 0 | 0 | 1000 |
| baseline2 | hold | 0 | 0 | 1000 |
| candidate2 | setup | 0 | 0 | 1000 |
| candidate2 | hold | 0 | 0 | 1000 |

[path_comparison.json](path_comparison.json) records negative counts and endpoint TNS by capture clock. [paths.json](paths.json), *_all_setup.txt and *_all_hold.txt retain endpoint identities; [path_comparisons.md](path_comparisons.md) lists matched and ranked detailed queries. TNS reconciliation is checked against the compiled summary; tied ranks are not assumed identical. Overlapping global, group and restricted lists are not added together.

## Matched HDMI shadowmask-to-OSD and CPU paths

| Build / query | Slack ns | From | To | Data ns | Skew ns |
| --- | --- | --- | --- | --- | --- |
| baseline2 all_setup | 0.401 | ascal:ascal / altsyncram:o_line3[0].r[7]__5 / altsyncram_ccn1:auto_generated / ram_block1a0~PORT_B_WRITE_ENABLE_REG | ascal:ascal / o_vpix_outer[1].r[5] | 4.952 | -1.179 |
| baseline2 all_hold | 0.235 | emu:emu / system:system / vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:61:shifter / shift0[6] | emu:emu / system:system / vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:61:shifter / shift0[7] | 0.342 | 0.107 |
| baseline2 hdmi_setup | 0.401 | ascal:ascal / altsyncram:o_line3[0].r[7]__5 / altsyncram_ccn1:auto_generated / ram_block1a0~PORT_B_WRITE_ENABLE_REG | ascal:ascal / o_vpix_outer[1].r[5] | 4.952 | -1.179 |
| baseline2 core_setup | 0.551 | emu:emu / sdram:ram / sd_dat[8] | emu:emu / system:system / T80s:z80_inst / T80:u0 / IR[6]~DUPLICATE | 16.231 | -1.514 |
| baseline2 dir | 12.637 | emu:emu / savestates:savestates_inst / z80_dir[185] | emu:emu / system:system / T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[2][1] | 5.274 | -0.385 |
| baseline2 controls | 9.01 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / IR[5] | 8.839 | -0.447 |
| candidate2 all_setup | 0.524 | ascal:ascal / altsyncram:o_line3[0].r[7]__5 / altsyncram_ccn1:auto_generated / ram_block1a0~PORT_B_WRITE_ENABLE_REG | ascal:ascal / o_vpix_outer[1].r[7] | 4.447 | -1.561 |
| candidate2 all_hold | 0.238 | emu:emu / system:system / vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:38:shifter / shift0[6] | emu:emu / system:system / vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:38:shifter / shift0[7] | 0.346 | 0.108 |
| candidate2 hdmi_setup | 0.524 | ascal:ascal / altsyncram:o_line3[0].r[7]__5 / altsyncram_ccn1:auto_generated / ram_block1a0~PORT_B_WRITE_ENABLE_REG | ascal:ascal / o_vpix_outer[1].r[7] | 4.447 | -1.561 |
| candidate2 core_setup | 1.077 | emu:emu / system:system / mapper_detect:mapper_detect_inst / rom_crc32[25]~DUPLICATE | emu:emu / system:system / jt89:psg_inst / cen_16 | 7.138 | -0.768 |
| candidate2 alias | 14.662 | emu:emu / savestates:savestates_inst / z80_snap[185] | emu:emu / system:system / T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[2][1] | 3.147 | -0.487 |
| candidate2 controls | 10.104 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / IR[5] | 7.76 | -0.432 |

Restricted shadowmask ram_block5a0->h_cnt and ->dsp_width queries establish **29 exact h_cnt** and **22 exact dsp_width** start/end matches. Names with different duplicate suffixes are not silently merged. The following chooses the worst candidate path with an exact baseline endpoint match, allowing a concrete routed logical-path comparison. Full pin traces identify the memory output and receiver control pin; generated LUT spelling and placements may change under physical optimization.

| Matched path metric | Baseline2 | Candidate2 |
| --- | --- | --- |
| Endpoint | osd:hdmi_osd / h_cnt[5]~DUPLICATE | osd:hdmi_osd / h_cnt[5]~DUPLICATE |
| Slack ns | 3.1 | 2.679 |
| Data delay ns | 3.195 | 3.657 |
| Skew ns | -0.237 | -0.196 |

For this matched pair, candidate-minus-baseline data delay is **0.462ns**, skew change **0.041ns**, slack change **-0.421ns**. This is an exact-pair observation, not a decomposition of unrelated global worst endpoints.

### baseline matched route

| Location | Cell/pin | Incremental cell delay ns | Reported fanout |
| --- | --- | --- | --- |
| M10K_X14_Y74_N0 | HDMI_shadowmask / vid_rtl_0 / auto_generated / altsyncram4 / ram_block5a0 / portbdataout[0] | 0.025 | 28 |
| LABCELL_X12_Y77_N9 | hdmi_osd / always3~5 / combout | 0.079 | 71 |
| FF_X12_Y80_N46 | osd:hdmi_osd / h_cnt[5]~DUPLICATE | 0.885 | 1 |

| Physical data delay class | Value | Count | Total delay ns |
| --- | --- | --- | --- |
| IC |  | 2 | -0.002 |
| Cell |  | 3 | 0.989 |
| Routing Element |  | 15 | 2.208 |

Routing sequence: M10K_X14_Y74_N0 (STRATIXV_RAM, 0ns); M20K_BUFFER_X14_Y74_N0_I0 (MEDIUM_EAB_BUFFER, 0.137ns); R3_X11_Y74_N0_I15 (H_SEG3, 0.193ns); C4_X11_Y75_N0_I2 (V_SEG4, 0.261ns); R3_X12_Y77_N0_I5 (H_SEG3, 0.255ns); LOCAL_INTERCONNECT_X12_Y77_N0_I11 (LAB_LINE, 0.188ns); BLOCK_INPUT_MUX_X12_Y77_N0_I15 (LEIM_INPUT, 0.127ns); LABCELL_X12_Y77_N9 (ARRIAV_LCELL_COMB, 0ns); LE_BUFFER_X12_Y77_N0_I6 (LE_BUFFER, 0.078ns); C4_X12_Y78_N0_I2 (V_SEG4, 0.305ns); R6_X7_Y80_N0_I33 (H_SEG6, 0.292ns); LOCAL_INTERCONNECT_X12_Y80_N0_I36 (LAB_LINE, 0.191ns); BLOCK_INPUT_MUX_PASSTHROUGH_X12_Y80_N0_I83 (LEIM, 0.181ns); LEIMSEL_X12_Y80_N0_I1 (LEIMSEL, 0ns); LAB_INPUT_X12_Y80_N0_I9 (LAB_INPUT, 0ns).

### candidate matched route

| Location | Cell/pin | Incremental cell delay ns | Reported fanout |
| --- | --- | --- | --- |
| M10K_X14_Y66_N0 | HDMI_shadowmask / vid_rtl_0 / auto_generated / altsyncram4 / ram_block5a0 / portbdataout[0] | 0.025 | 17 |
| LABCELL_X11_Y73_N39 | hdmi_osd / always3~4 / combout | 0.082 | 71 |
| FF_X12_Y74_N46 | osd:hdmi_osd / h_cnt[5]~DUPLICATE | 0.885 | 1 |

| Physical data delay class | Value | Count | Total delay ns |
| --- | --- | --- | --- |
| IC |  | 2 | 0.001 |
| Cell |  | 3 | 0.992 |
| Routing Element |  | 17 | 2.664 |

Routing sequence: M10K_X14_Y66_N0 (STRATIXV_RAM, 0ns); M20K_BUFFER_X14_Y66_N0_I0 (MEDIUM_EAB_BUFFER, 0.135ns); C2_X13_Y67_N0_I2 (V_SEG2, 0.249ns); C2_X13_Y69_N0_I2 (V_SEG2, 0.245ns); C2_X13_Y71_N0_I2 (V_SEG2, 0.238ns); C2_X13_Y73_N0_I2 (V_SEG2, 0.234ns); R6_X8_Y73_N0_I24 (H_SEG6, 0.292ns); LOCAL_INTERCONNECT_X11_Y73_N0_I8 (LAB_LINE, 0.203ns); BLOCK_INPUT_MUX_X11_Y73_N0_I55 (LEIM_INPUT, 0.126ns); LABCELL_X11_Y73_N39 (ARRIAV_LCELL_COMB, 0ns); LE_BUFFER_X11_Y73_N0_I26 (LE_BUFFER, 0.102ns); C4_X11_Y74_N0_I0 (V_SEG4, 0.212ns); R6_X12_Y74_N0_I2 (H_SEG6, 0.263ns); LOCAL_INTERCONNECT_X12_Y74_N0_I20 (LAB_LINE, 0.196ns); BLOCK_INPUT_MUX_PASSTHROUGH_X12_Y74_N0_I83 (LEIM, 0.169ns); LEIMSEL_X12_Y74_N0_I1 (LEIMSEL, 0ns); LAB_INPUT_X12_Y74_N0_I9 (LAB_INPUT, 0ns).


Read-only register-location metadata and the detailed routing sequences retain the physical RAM, clear-decode LUT and endpoint locations. Routing-element count/delay and clock skew are observed physical quantities, not proof of a particular congestion cause. Differences in matched route placement do not by themselves isolate which fitter decision produced them.

Baseline dir->T80 and candidate snap->T80 queries inspect the actual restore-data launch bank. Baseline snap may have no direct T80 path because it first enters the output holding register; an empty baseline alias set is not an omitted consumed path. Direct data and z80_* control envelopes are shown separately above. Comparing different worst endpoints does not claim a matched-bit speedup. All original consumer-edge proof and source equality remain unchanged; reported timing gates independently determine whether an implementation is eligible.

## Register removal and warnings

| Fitted named bank | Baseline2 | Candidate2 |
| --- | --- | --- |
| Original z80_snap nodes | 230 | 230 |
| Separate z80_dir nodes | 230 | 0 |
| Controller own timing-register nodes | 14772 | 14541 |

The target 230 z80_dir holding FFs disappear only in candidate2; the230-bit snapshot remains. Mapped whole-design delta is **-230**. Fitted whole-design delta **-117** can differ because of unrelated physical duplication/retiming/packing. [register_delta.json](register_delta.json) retains every controller stem and changed name count; full name/location lists retain other physical allocations. Child RAM timing nodes are not mistaken for dedicated controller FFs.

Unique compiled critical-warning messages: **38->38**. New normalized candidate critical warnings: **0**. Build-root paths/source-line annotations are normalized, with complete raw warning lists and normalization logic retained in paired_results.json and collect.js. Inherited unconstrained setup/hold categories remain disclosed. New critical messages:

```text
(none)
```

## Concrete physical findings

The seed-2 shadowmask control cone is comfortably positive on both sides: worst RAM->h_cnt slack **+3.100 baseline / +2.679 candidate**, and RAM->dsp_width **+2.829 / +2.673ns**. Neither is the seed-2 global limiter. Both global worst setup paths are now in the scaler's o_line3 RAM->o_vpix_outer logic, with different receiver bits, at **+.401 / +.524ns**. Thus the former seed-1 HDMI shadowmask failure is not reproduced in this seed-2 pair; this is evidence of seed-dependent physical outcomes, not a statistical success rate or proof of repeat-fit determinism.

The selected exact matched h_cnt[5]~DUPLICATE path uses portbdataout[0]->sclr and the same HDMI PLL counter0 output clock, with6.732ns relationship on both sides. Its data delay grows **3.195->3.657ns (+.462)**, skew improves **-.237->-.196ns (+.041)**, and slack falls **3.100->2.679ns (-.421)**. Data routing grows **2.208->2.664ns**,15->17 routing elements; cell delay changes **.989->.992ns**, IC annotation **-.002->+.001ns**. These sum to the observed data-delay change. The RAM moves M10K_X14_Y74_N0->M10K_X14_Y66_N0; decode LUT LABCELL_X12_Y77_N9->LABCELL_X11_Y73_N39; receiver FF_X12_Y80_N46->FF_X12_Y74_N46. Decode fanout remains71, while the RAM output's reported fanout falls28->17. The local route worsens without becoming near-critical, and clock skew offsets part of it. A specific congestion cause is not established.

The original seed-1 failed physical endpoint h_cnt[2]~DUPLICATE exists in baseline2 (+3.106ns) but **not in candidate2**. It cannot be compared as an unchanged physical duplicate across those builds. The ordinary logical h_cnt[2] endpoint does exist on both sides: **+3.100->+2.688ns**, data3.197->3.650, skew-.235->-.194. All22 dsp_width names match, including dsp_width[19] **+3.243->+2.678ns**. Duplicate-name differences are kept explicit rather than stripped to manufacture a match.

The worst direct restore-data path in each build happens to represent the **same image bit185 and the same T80_Reg RegsH[2][1] receiver**. Baseline launches z80_dir[185]; candidate launches z80_snap[185]. Relationship18.626ns is unchanged. Slack improves **+12.637->+14.662ns**; data delay5.274->3.147 and skew-.385->-.487ns. These are physically different launch banks with the previously proven consuming-edge equivalence, not an unchanged physical launch-cell comparison. The unchanged z80_set->IR[5] control pair also remains positive, **+9.010->+10.104ns**. No queried alias data path approaches the native core timing limit.

The 230 output FFs disappear and the snapshot stays230. Controller own fitted count changes **14772->14541 (-231)**: exactly z80_dir-230 plus one fewer watchdog duplicate (4->3). Other fitted allocations sum to **+114**, giving whole-design -231+114=-117. This distinguishes target-bank removal from physical mapping elsewhere. Needed ALMs fall107, but placed ALMs fall only4 because the packing-adjustment gap changes: recoverable+104 and unavailable+1. These are whole-design physical outcomes, not an isolated per-FF ALM price.

The routing rejection does not depend on checking horizontal/vertical components separately: **routing ALUT18254->18359 (+105)** and **total peak72.8%->72.9%** already violate the stated no-growth gates. Average total utilization improves49.4%->48.8%; horizontal peak rises70.7%->72.8% and vertical peak falls81.4%->78.3%. An improved average does not waive the peak or routing-ALUT failures. Both M10K counts remain488, all reported timing checks pass, and neither build adds a critical warning relative to the paired baseline.

## Interpretation, disposition and limitations

**REJECTED / NOT A QUALIFIED PAIRED IMPROVEMENT.** The seed2 physical gates are not all met; this candidate implementation is retained as rejected evidence. Functional equivalence and removal of230 mapped FFs do not override a failed physical gate.  

One pair cannot establish statistical confidence, repeat-fit determinism or intrinsic CPU-alias slowness. An HDMI failure is assessed through matched physical routes rather than attributed to the CPU solely by temporal association. Seed1 remains failed. Even a fully favorable seed2 pair cannot authorize promotion or an unpaired favorable-seed substitution. Further robustness work requires separate authorization; no further seed or variant is launched here.

Production RTL, savestate bytes/compatibility, constraints, IP, branch, HEAD and index remain unchanged. Existing untracked tests, reports, seed1 implementations and candidate evidence are preserved. New outputs are confined to tests/cpu_restore_alias_seed2_pair/. No checkout/reset/clean/commit/push/merge/PR or deployment occurred.

Final git diff --stat:

```text
(empty)
```

Final git status --short:

```text
?? tests/
```

**Stop after this single pair and await review.**
