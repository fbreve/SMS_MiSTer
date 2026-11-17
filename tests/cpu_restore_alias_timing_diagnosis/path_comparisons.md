# Timing-path comparison ledger

Every query uses -npaths 50 -nworst 1. One worst path per physical endpoint, not 50 variants of one endpoint. Full names, detailed delays and routes are in paths.json and matching text files. Different tied paths can rank differently.

## hdmi_setup

### baseline

| Rank | Slack ns | From | To | Skew ns | Data ns |
| --- | --- | --- | --- | --- | --- |
| 1 | 0.104 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[19] | -0.675 | 5.753 |
| 2 | 0.104 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[13] | -0.675 | 5.753 |
| 3 | 0.104 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[12] | -0.675 | 5.753 |
| 4 | 0.108 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[11] | -0.671 | 5.753 |
| 5 | 0.108 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[20] | -0.671 | 5.753 |
| 6 | 0.108 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[18] | -0.671 | 5.753 |
| 7 | 0.251 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[10] | -0.674 | 5.607 |
| 8 | 0.345 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[14] | -0.677 | 5.51 |
| 9 | 0.349 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[16] | -0.673 | 5.51 |
| 10 | 0.349 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[15] | -0.673 | 5.51 |
| 11 | 0.401 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[8] | -0.674 | 5.457 |
| 12 | 0.401 | shadowmask:HDMI_shadowmask / dout[18] | osd:hdmi_osd / nrdout1[18] | -0.622 | 5.509 |
| 13 | 0.405 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[5] | -0.67 | 5.457 |
| 14 | 0.405 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[9] | -0.67 | 5.457 |
| 15 | 0.405 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[21] | -0.67 | 5.457 |
| 16 | 0.41 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[17] | -0.666 | 5.456 |
| 17 | 0.431 | shadowmask:HDMI_shadowmask / dout[2] | osd:hdmi_osd / nrdout1[2] | -0.572 | 5.529 |
| 18 | 0.478 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[2]~DUPLICATE | -0.685 | 5.369 |
| 19 | 0.478 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[8]~DUPLICATE | -0.685 | 5.369 |
| 20 | 0.478 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[6] | -0.685 | 5.369 |
| 21 | 0.478 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[0]~DUPLICATE | -0.685 | 5.369 |
| 22 | 0.478 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[3]~DUPLICATE | -0.687 | 5.367 |
| 23 | 0.478 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[1] | -0.687 | 5.367 |
| 24 | 0.478 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[9] | -0.687 | 5.367 |
| 25 | 0.478 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[5] | -0.687 | 5.367 |
| 26 | 0.482 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[3] | -0.681 | 5.369 |
| 27 | 0.482 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[9]~DUPLICATE | -0.681 | 5.369 |
| 28 | 0.482 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[5]~DUPLICATE | -0.681 | 5.369 |
| 29 | 0.482 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[1]~DUPLICATE | -0.681 | 5.369 |
| 30 | 0.483 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[0] | -0.682 | 5.367 |
| 31 | 0.483 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[2] | -0.682 | 5.367 |
| 32 | 0.483 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[8] | -0.682 | 5.367 |
| 33 | 0.483 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[6]~DUPLICATE | -0.682 | 5.367 |
| 34 | 0.487 | ascal:ascal / altsyncram:o_line2[0].r[7]__4 / altsyncram_ccn1:auto_generated / ram_block1a9~PORT_B_WRITE_ENABLE_REG | ascal:ascal / o_vpix_inner[0].g[5] | -1.199 | 4.846 |
| 35 | 0.487 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[7] | -0.687 | 5.358 |
| 36 | 0.49 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[7] | -0.682 | 5.36 |
| 37 | 0.492 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[4] | -0.682 | 5.358 |
| 38 | 0.556 | ascal:ascal / altsyncram:o_line1[0].r[7]__3 / altsyncram_ccn1:auto_generated / ram_block1a4~PORT_B_WRITE_ENABLE_REG | ascal:ascal / o_vpix_outer[1].g[7] | -1.177 | 4.799 |
| 39 | 0.609 | osd:hdmi_osd / h_cnt[13]~DUPLICATE | osd:hdmi_osd / osd_hcnt2[14] | -0.56 | 5.363 |
| 40 | 0.611 | ascal:ascal / o_vcpt_pre3[5] | ascal:ascal / o_vcpt_pre3[2] | -0.117 | 5.804 |
| 41 | 0.611 | ascal:ascal / o_vcpt_pre3[5] | ascal:ascal / o_vcpt_pre3[1] | -0.117 | 5.804 |
| 42 | 0.611 | ascal:ascal / o_vcpt_pre3[5] | ascal:ascal / o_vcpt_pre3[7] | -0.117 | 5.804 |
| 43 | 0.616 | ascal:ascal / o_vcpt_pre3[5] | ascal:ascal / o_vcpt_pre3[3] | -0.112 | 5.804 |
| 44 | 0.616 | ascal:ascal / o_vcpt_pre3[5] | ascal:ascal / o_vcpt_pre3[5] | -0.112 | 5.804 |
| 45 | 0.616 | ascal:ascal / o_vcpt_pre3[5] | ascal:ascal / o_vcpt_pre3[4] | -0.112 | 5.804 |
| 46 | 0.633 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[2] | -0.677 | 5.222 |
| 47 | 0.637 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[3] | -0.673 | 5.222 |
| 48 | 0.637 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[1] | -0.673 | 5.222 |
| 49 | 0.637 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[4] | -0.673 | 5.222 |
| 50 | 0.637 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[6] | -0.673 | 5.222 |

### candidate

| Rank | Slack ns | From | To | Skew ns | Data ns |
| --- | --- | --- | --- | --- | --- |
| 1 | -0.714 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[8]~DUPLICATE | -0.692 | 6.554 |
| 2 | -0.714 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[2]~DUPLICATE | -0.692 | 6.554 |
| 3 | -0.714 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[1] | -0.694 | 6.552 |
| 4 | -0.714 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[3]~DUPLICATE | -0.694 | 6.552 |
| 5 | -0.714 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[5]~DUPLICATE | -0.694 | 6.552 |
| 6 | -0.714 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[4] | -0.692 | 6.554 |
| 7 | -0.709 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[1]~DUPLICATE | -0.687 | 6.554 |
| 8 | -0.709 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[5] | -0.687 | 6.554 |
| 9 | -0.709 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[3] | -0.687 | 6.554 |
| 10 | -0.708 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[4]~DUPLICATE | -0.688 | 6.552 |
| 11 | -0.708 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[2] | -0.688 | 6.552 |
| 12 | -0.708 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[8] | -0.688 | 6.552 |
| 13 | -0.705 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[9] | -0.694 | 6.543 |
| 14 | -0.705 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[7] | -0.694 | 6.543 |
| 15 | -0.699 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[0] | -0.688 | 6.543 |
| 16 | -0.699 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[6] | -0.688 | 6.543 |
| 17 | -0.15 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[21] | -0.683 | 5.999 |
| 18 | -0.146 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[20] | -0.679 | 5.999 |
| 19 | -0.112 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[15] | -0.682 | 5.962 |
| 20 | -0.112 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[13] | -0.682 | 5.962 |
| 21 | -0.108 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[17] | -0.678 | 5.962 |
| 22 | -0.108 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[19] | -0.678 | 5.962 |
| 23 | -0.108 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[18] | -0.678 | 5.962 |
| 24 | 0.018 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[9] | -0.707 | 5.807 |
| 25 | 0.077 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[3] | -0.715 | 5.74 |
| 26 | 0.081 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[0] | -0.711 | 5.74 |
| 27 | 0.355 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[20]~DUPLICATE | -0.699 | 5.478 |
| 28 | 0.355 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[10]~DUPLICATE | -0.699 | 5.478 |
| 29 | 0.355 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[18] | -0.699 | 5.478 |
| 30 | 0.356 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[21]~DUPLICATE | -0.7 | 5.476 |
| 31 | 0.356 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[13]~DUPLICATE | -0.7 | 5.476 |
| 32 | 0.356 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[15]~DUPLICATE | -0.7 | 5.476 |
| 33 | 0.356 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[17]~DUPLICATE | -0.7 | 5.476 |
| 34 | 0.36 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[18]~DUPLICATE | -0.696 | 5.476 |
| 35 | 0.36 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[17] | -0.694 | 5.478 |
| 36 | 0.36 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[15] | -0.694 | 5.478 |
| 37 | 0.36 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[20] | -0.696 | 5.476 |
| 38 | 0.36 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[10] | -0.696 | 5.476 |
| 39 | 0.36 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[13] | -0.694 | 5.478 |
| 40 | 0.36 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[21] | -0.694 | 5.478 |
| 41 | 0.362 | ascal:ascal / o_div[0][20] | ascal:ascal / o_div[1][20] | -0.506 | 5.664 |
| 42 | 0.364 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[12] | -0.699 | 5.469 |
| 43 | 0.365 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[19] | -0.7 | 5.467 |
| 44 | 0.365 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[11] | -0.7 | 5.467 |
| 45 | 0.365 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[23] | -0.7 | 5.467 |
| 46 | 0.369 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[22] | -0.696 | 5.467 |
| 47 | 0.369 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[16] | -0.696 | 5.467 |
| 48 | 0.369 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[14] | -0.696 | 5.467 |
| 49 | 0.379 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[5] | -0.709 | 5.444 |
| 50 | 0.379 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[2] | -0.709 | 5.444 |

## core_setup

### baseline

| Rank | Slack ns | From | To | Skew ns | Data ns |
| --- | --- | --- | --- | --- | --- |
| 1 | 0.895 | mapper_detect:mapper_detect_inst / rom_crc32[17] | T80s:z80_inst / T80:u0 / IR[3] | -0.46 | 16.941 |
| 2 | 1.012 | mapper_detect:mapper_detect_inst / rom_crc32[17] | T80s:z80_inst / T80:u0 / IR[6] | -0.458 | 16.826 |
| 3 | 1.076 | mapper_detect:mapper_detect_inst / rom_crc32[17] | T80s:z80_inst / T80:u0 / IR[4] | -0.464 | 16.756 |
| 4 | 1.081 | mapper_detect:mapper_detect_inst / rom_crc32[17] | T80s:z80_inst / T80:u0 / IR[4]~DUPLICATE | -0.461 | 16.754 |
| 5 | 1.222 | mapper_detect:mapper_detect_inst / rom_crc32[17] | T80s:z80_inst / T80:u0 / IR[5] | -0.472 | 16.602 |
| 6 | 1.227 | mapper_detect:mapper_detect_inst / rom_crc32[17] | T80s:z80_inst / T80:u0 / IR[5]~DUPLICATE | -0.469 | 16.6 |
| 7 | 1.329 | mapper_detect:mapper_detect_inst / rom_crc32[17] | T80s:z80_inst / T80:u0 / IR[0] | -0.471 | 16.496 |
| 8 | 1.44 | mapper_detect:mapper_detect_inst / rom_crc32[17] | T80s:z80_inst / T80:u0 / IR[2] | -0.467 | 16.389 |
| 9 | 1.446 | emu:emu / ce_pix | vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:22:shifter / shift0[0] | -0.487 | 7.05 |
| 10 | 1.487 | emu:emu / ce_pix | emu:emu / lightgun:lightgun / offscreen | -0.489 | 7.007 |
| 11 | 1.503 | emu:emu / ce_sp | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / enable[16] | -0.462 | 7.018 |
| 12 | 1.503 | emu:emu / ce_sp | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / enable[19]~DUPLICATE | -0.462 | 7.018 |
| 13 | 1.503 | emu:emu / ce_sp | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / enable[19] | -0.459 | 7.021 |
| 14 | 1.503 | emu:emu / ce_sp | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / enable[16]~DUPLICATE | -0.459 | 7.021 |
| 15 | 1.531 | emu:emu / ce_pix~DUPLICATE | savestates / state.ST_LOAD_BG_DESC | -0.482 | 6.97 |
| 16 | 1.532 | emu:emu / ce_pix~DUPLICATE | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:11:shifter / shift2[2] | -0.463 | 6.988 |
| 17 | 1.532 | emu:emu / ce_pix~DUPLICATE | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:11:shifter / shift0[7] | -0.463 | 6.988 |
| 18 | 1.532 | emu:emu / ce_pix~DUPLICATE | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:11:shifter / shift0[5] | -0.463 | 6.988 |
| 19 | 1.532 | emu:emu / ce_pix~DUPLICATE | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:11:shifter / shift1[7] | -0.463 | 6.988 |
| 20 | 1.532 | emu:emu / ce_pix~DUPLICATE | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:11:shifter / shift0[3]~DUPLICATE | -0.463 | 6.988 |
| 21 | 1.532 | emu:emu / ce_pix~DUPLICATE | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:11:shifter / shift2[4] | -0.463 | 6.988 |
| 22 | 1.533 | emu:emu / ce_pix~DUPLICATE | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:11:shifter / shift2[7] | -0.461 | 6.989 |
| 23 | 1.533 | emu:emu / ce_pix~DUPLICATE | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:11:shifter / shift2[6] | -0.467 | 6.983 |
| 24 | 1.533 | emu:emu / ce_pix~DUPLICATE | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:11:shifter / shift0[6] | -0.461 | 6.989 |
| 25 | 1.533 | emu:emu / ce_pix~DUPLICATE | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:11:shifter / shift0[4] | -0.467 | 6.983 |
| 26 | 1.533 | emu:emu / ce_pix~DUPLICATE | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:11:shifter / shift0[1] | -0.461 | 6.989 |
| 27 | 1.533 | emu:emu / ce_pix~DUPLICATE | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:11:shifter / shift0[3] | -0.467 | 6.983 |
| 28 | 1.533 | emu:emu / ce_pix~DUPLICATE | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:11:shifter / shift0[2] | -0.461 | 6.989 |
| 29 | 1.533 | emu:emu / ce_pix~DUPLICATE | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:11:shifter / shift2[5] | -0.461 | 6.989 |
| 30 | 1.533 | emu:emu / ce_pix~DUPLICATE | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:11:shifter / shift2[3] | -0.461 | 6.989 |
| 31 | 1.534 | emu:emu / ce_pix~DUPLICATE | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:11:shifter / shift2[3]~DUPLICATE | -0.468 | 6.981 |
| 32 | 1.534 | emu:emu / ce_pix~DUPLICATE | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:11:shifter / shift2[1] | -0.468 | 6.981 |
| 33 | 1.534 | emu:emu / ce_pix~DUPLICATE | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:11:shifter / shift1[6] | -0.468 | 6.981 |
| 34 | 1.534 | emu:emu / ce_pix~DUPLICATE | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:11:shifter / shift0[2]~DUPLICATE | -0.468 | 6.981 |
| 35 | 1.539 | mapper_detect:mapper_detect_inst / rom_crc32[17] | T80s:z80_inst / DI_Reg[1]_OTERM305 | -0.465 | 16.292 |
| 36 | 1.54 | mapper_detect:mapper_detect_inst / rom_crc32[17] | T80s:z80_inst / DI_Reg[3]_OTERM299 | -0.465 | 16.291 |
| 37 | 1.546 | mapper_detect:mapper_detect_inst / rom_crc32[17] | T80s:z80_inst / DI_Reg[7]_OTERM321 | -0.462 | 16.288 |
| 38 | 1.566 | emu:emu / ce_pix | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:59:shifter / shift1[6]~DUPLICATE | -0.467 | 6.95 |
| 39 | 1.566 | emu:emu / ce_pix | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:59:shifter / shift0[2] | -0.467 | 6.95 |
| 40 | 1.566 | emu:emu / ce_pix | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:59:shifter / shift0[5]~DUPLICATE | -0.467 | 6.95 |
| 41 | 1.566 | emu:emu / ce_pix | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:59:shifter / shift2[7] | -0.467 | 6.95 |
| 42 | 1.566 | emu:emu / ce_pix | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:59:shifter / shift0[6] | -0.467 | 6.95 |
| 43 | 1.566 | emu:emu / ce_pix | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:59:shifter / shift2[5]~DUPLICATE | -0.467 | 6.95 |
| 44 | 1.567 | emu:emu / ce_pix | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:59:shifter / shift2[1] | -0.471 | 6.945 |
| 45 | 1.567 | emu:emu / ce_pix | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:59:shifter / shift2[3] | -0.471 | 6.945 |
| 46 | 1.567 | emu:emu / ce_pix | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:59:shifter / shift1[6] | -0.471 | 6.945 |
| 47 | 1.567 | emu:emu / ce_pix | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:59:shifter / shift0[1] | -0.465 | 6.951 |
| 48 | 1.567 | emu:emu / ce_pix | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:59:shifter / shift0[3] | -0.465 | 6.951 |
| 49 | 1.567 | emu:emu / ce_pix | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:59:shifter / shift0[4] | -0.465 | 6.951 |
| 50 | 1.567 | emu:emu / ce_pix | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:59:shifter / shift0[5] | -0.471 | 6.945 |

### candidate

| Rank | Slack ns | From | To | Skew ns | Data ns |
| --- | --- | --- | --- | --- | --- |
| 1 | 0.716 | emu:emu / hps_io:hps_io / joystick_1[5] | jt89:psg2_inst / cen_16 | -0.52 | 7.747 |
| 2 | 0.716 | emu:emu / hps_io:hps_io / joystick_1[5] | jt89:psg_inst / cen_16 | -0.52 | 7.747 |
| 3 | 0.817 | emu:emu / sdram:ram / sd_dat[8] | T80s:z80_inst / T80:u0 / IR[5] | -1.547 | 15.932 |
| 4 | 0.822 | emu:emu / sdram:ram / sd_dat[8] | T80s:z80_inst / T80:u0 / IR[5]~DUPLICATE | -1.544 | 15.93 |
| 5 | 1.179 | emu:emu / ce_pix~DUPLICATE | savestates / z80_snap[25] | -0.509 | 7.295 |
| 6 | 1.179 | emu:emu / ce_pix~DUPLICATE | savestates / z80_snap[30] | -0.509 | 7.295 |
| 7 | 1.187 | emu:emu / ce_pix~DUPLICATE | savestates / z80_snap[57] | -0.526 | 7.27 |
| 8 | 1.188 | emu:emu / sdram:ram / sd_dat[8] | T80s:z80_inst / T80:u0 / IR[3]~DUPLICATE | -1.559 | 15.549 |
| 9 | 1.188 | emu:emu / ce_pix~DUPLICATE | savestates / z80_snap[62] | -0.53 | 7.265 |
| 10 | 1.193 | emu:emu / sdram:ram / sd_dat[8] | T80s:z80_inst / T80:u0 / IR[3] | -1.556 | 15.547 |
| 11 | 1.236 | emu:emu / ce_pix~DUPLICATE | savestates / z80_snap[56] | -0.509 | 7.238 |
| 12 | 1.237 | emu:emu / ce_pix~DUPLICATE | savestates / z80_snap[8] | -0.513 | 7.233 |
| 13 | 1.24 | emu:emu / ce_pix~DUPLICATE | savestates / z80_snap[1] | -0.523 | 7.22 |
| 14 | 1.24 | emu:emu / ce_pix~DUPLICATE | savestates / z80_snap[31] | -0.523 | 7.22 |
| 15 | 1.241 | emu:emu / ce_pix~DUPLICATE | savestates / z80_snap[46] | -0.527 | 7.215 |
| 16 | 1.315 | emu:emu / ce_vdp~DUPLICATE | vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / data_address[11] | -0.521 | 7.147 |
| 17 | 1.315 | emu:emu / ce_vdp~DUPLICATE | vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / data_address[12] | -0.518 | 7.15 |
| 18 | 1.37 | emu:emu / ce_pix~DUPLICATE | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:43:shifter / shift3[0] | -0.462 | 7.151 |
| 19 | 1.376 | emu:emu / sdram:ram / sd_dat[8] | T80s:z80_inst / T80:u0 / IR[4] | -1.547 | 15.373 |
| 20 | 1.391 | emu:emu / ce_pix~DUPLICATE | savestates / z80_snap[28] | -0.512 | 7.08 |
| 21 | 1.4 | emu:emu / ce_pix~DUPLICATE | savestates / z80_snap[10] | -0.513 | 7.07 |
| 22 | 1.4 | emu:emu / ce_pix~DUPLICATE | savestates / z80_snap[13] | -0.513 | 7.07 |
| 23 | 1.4 | emu:emu / ce_pix~DUPLICATE | savestates / z80_snap[15] | -0.513 | 7.07 |
| 24 | 1.401 | emu:emu / ce_pix~DUPLICATE | savestates / z80_snap[50] | -0.517 | 7.065 |
| 25 | 1.401 | emu:emu / ce_pix~DUPLICATE | savestates / z80_snap[9] | -0.517 | 7.065 |
| 26 | 1.503 | emu:emu / sdram:ram / sd_dat[8] | T80s:z80_inst / DI_Reg[5]_OTERM305 | -1.557 | 15.236 |
| 27 | 1.526 | emu:emu / ce_pix~DUPLICATE | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:6:shifter / shift3[0] | -0.477 | 6.98 |
| 28 | 1.55 | emu:emu / sdram:ram / sd_dat[8] | T80s:z80_inst / T80:u0 / IR[1]_OTERM581 | -1.519 | 15.227 |
| 29 | 1.552 | emu:emu / ce_pix~DUPLICATE | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:57:shifter / shift0[6] | -0.514 | 6.917 |
| 30 | 1.552 | emu:emu / ce_pix~DUPLICATE | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:57:shifter / shift0[5] | -0.515 | 6.916 |
| 31 | 1.552 | emu:emu / ce_pix~DUPLICATE | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:57:shifter / shift2[3]~DUPLICATE | -0.515 | 6.916 |
| 32 | 1.552 | emu:emu / ce_pix~DUPLICATE | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:57:shifter / shift2[2] | -0.521 | 6.91 |
| 33 | 1.552 | emu:emu / ce_pix~DUPLICATE | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:57:shifter / shift2[4] | -0.521 | 6.91 |
| 34 | 1.552 | emu:emu / ce_pix~DUPLICATE | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:57:shifter / shift0[1]~DUPLICATE | -0.515 | 6.916 |
| 35 | 1.552 | emu:emu / ce_pix~DUPLICATE | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:57:shifter / shift0[2] | -0.521 | 6.91 |
| 36 | 1.552 | emu:emu / ce_pix~DUPLICATE | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:57:shifter / shift0[3]~DUPLICATE | -0.515 | 6.916 |
| 37 | 1.552 | emu:emu / ce_pix~DUPLICATE | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:57:shifter / shift0[4]~DUPLICATE | -0.521 | 6.91 |
| 38 | 1.552 | emu:emu / ce_pix~DUPLICATE | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:57:shifter / shift0[7]~DUPLICATE | -0.515 | 6.916 |
| 39 | 1.552 | emu:emu / ce_pix~DUPLICATE | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:57:shifter / shift0[4] | -0.514 | 6.917 |
| 40 | 1.553 | emu:emu / ce_pix~DUPLICATE | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:57:shifter / shift0[7] | -0.519 | 6.911 |
| 41 | 1.553 | emu:emu / ce_pix~DUPLICATE | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:57:shifter / shift0[1] | -0.519 | 6.911 |
| 42 | 1.553 | emu:emu / ce_pix~DUPLICATE | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:57:shifter / shift0[3] | -0.519 | 6.911 |
| 43 | 1.553 | emu:emu / ce_pix~DUPLICATE | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:57:shifter / shift2[3] | -0.519 | 6.911 |
| 44 | 1.557 | emu:emu / ce_pix~DUPLICATE | savestates / z80_snap[0] | -0.508 | 6.918 |
| 45 | 1.557 | emu:emu / ce_pix~DUPLICATE | savestates / z80_snap[5] | -0.508 | 6.918 |
| 46 | 1.558 | emu:emu / ce_pix~DUPLICATE | savestates / z80_snap[55] | -0.512 | 6.913 |
| 47 | 1.558 | emu:emu / ce_pix~DUPLICATE | savestates / z80_snap[4] | -0.512 | 6.913 |
| 48 | 1.569 | emu:emu / sdram:ram / sd_dat[8] | T80s:z80_inst / DI_Reg[1]_OTERM325 | -1.562 | 15.165 |
| 49 | 1.576 | emu:emu / sdram:ram / sd_dat[8] | T80s:z80_inst / DI_Reg[0]_OTERM329 | -1.546 | 15.174 |
| 50 | 1.632 | emu:emu / ce_pix~DUPLICATE | savestates / z80_snap[48] | -0.506 | 6.845 |

## hdmi_hold

### baseline

| Rank | Slack ns | From | To | Skew ns | Data ns |
| --- | --- | --- | --- | --- | --- |
| 1 | 0.259 | ascal:ascal / o_vdivr[16] | ascal:ascal / o_vdivr[17] | 0.104 | 0.363 |
| 2 | 0.275 | ascal:ascal / o_vdivr[17] | ascal:ascal / o_vdivr[18] | 0.106 | 0.381 |
| 3 | 0.292 | vga_out:vga_scaler_out / altshift_taps:din1_rtl_0 / shift_taps_quu:auto_generated / altsyncram_dr91:altsyncram4 / ram_block5a28 | d[2] | 0.788 | 1.08 |
| 4 | 0.308 | vga_out:vga_scaler_out / altshift_taps:din1_rtl_0 / shift_taps_quu:auto_generated / altsyncram_dr91:altsyncram4 / ram_block5a29 | d[1] | 0.792 | 1.1 |
| 5 | 0.31 | vga_out:vga_scaler_out / altshift_taps:din1_rtl_0 / shift_taps_quu:auto_generated / altsyncram_dr91:altsyncram4 / ram_block5a13 | d[17] | 0.792 | 1.102 |
| 6 | 0.318 | vga_out:vga_scaler_out / altshift_taps:din1_rtl_0 / shift_taps_quu:auto_generated / altsyncram_dr91:altsyncram4 / ram_block5a24 | d[6] | 0.797 | 1.115 |
| 7 | 0.321 | vga_out:vga_scaler_out / altshift_taps:din1_rtl_0 / shift_taps_quu:auto_generated / altsyncram_dr91:altsyncram4 / ram_block5a18 | d[12] | 0.779 | 1.1 |
| 8 | 0.322 | vga_out:vga_scaler_out / altshift_taps:din1_rtl_0 / shift_taps_quu:auto_generated / altsyncram_dr91:altsyncram4 / ram_block5a16 | d[14] | 0.796 | 1.118 |
| 9 | 0.328 | vga_out:vga_scaler_out / altshift_taps:din1_rtl_0 / shift_taps_quu:auto_generated / altsyncram_dr91:altsyncram4 / ram_block5a17 | d[13] | 0.778 | 1.106 |
| 10 | 0.336 | ascal:ascal / o_vpixq_pre[2].b[4] | ascal:ascal / o_vpixq[2].b[4] | 0.821 | 1.157 |
| 11 | 0.343 | ascal:ascal / o_vpixq_pre[2].b[1] | ascal:ascal / o_vpixq[2].b[1] | 0.821 | 1.164 |
| 12 | 0.344 | ascal:ascal / o_vpixq_pre[3].g[4] | ascal:ascal / o_vpixq[3].g[4] | 0.81 | 1.154 |
| 13 | 0.347 | ascal:ascal / o_vpixq_pre[3].b[1] | ascal:ascal / o_vpixq[3].b[1] | 0.824 | 1.171 |
| 14 | 0.348 | vga_out:vga_scaler_out / altshift_taps:din1_rtl_0 / shift_taps_quu:auto_generated / altsyncram_dr91:altsyncram4 / ram_block5a8 | d[22] | 0.797 | 1.145 |
| 15 | 0.351 | vga_out:vga_scaler_out / altshift_taps:din1_rtl_0 / shift_taps_quu:auto_generated / altsyncram_dr91:altsyncram4 / ram_block5a25 | d[5] | 0.792 | 1.143 |
| 16 | 0.357 | ascal:ascal / o_vpixq_pre[3].b[3] | ascal:ascal / o_vpixq[3].b[3] | 0.825 | 1.182 |
| 17 | 0.359 | ascal:ascal / o_vpixq_pre[1].g[2] | ascal:ascal / o_vpixq[1].g[2] | 0.824 | 1.183 |
| 18 | 0.364 | ascal:ascal / o_vpixq_pre[1].g[1] | ascal:ascal / o_vpixq[1].g[1] | 0.834 | 1.198 |
| 19 | 0.365 | ascal:ascal / o_vpixq_pre[0].g[7] | ascal:ascal / o_vpixq[0].g[7] | 0.828 | 1.193 |
| 20 | 0.369 | ascal:ascal / o_vpixq_pre[1].g[5] | ascal:ascal / o_vpixq[1].g[5] | 0.841 | 1.21 |
| 21 | 0.373 | ascal:ascal / o_poly_lum1[2] | ascal:ascal / o_poly_lerp_tb[2] | 0.784 | 1.157 |
| 22 | 0.38 | vga_out:vga_scaler_out / altshift_taps:din1_rtl_0 / shift_taps_quu:auto_generated / altsyncram_dr91:altsyncram4 / ram_block5a30 | d[0] | 0.793 | 1.173 |
| 23 | 0.38 | ascal:ascal / o_vpixq_pre[2].b[0] | ascal:ascal / o_vpixq[2].b[0] | 0.821 | 1.201 |
| 24 | 0.382 | ascal:ascal / o_vpixq_pre[0].b[7] | ascal:ascal / o_vpixq[0].b[7] | 0.797 | 1.179 |
| 25 | 0.388 | ascal:ascal / o_poly_lum1[5] | ascal:ascal / o_poly_lerp_tb[5]~_Duplicate_2 | 0.801 | 1.189 |
| 26 | 0.391 | vga_out:vga_scaler_out / altshift_taps:din1_rtl_0 / shift_taps_quu:auto_generated / altsyncram_dr91:altsyncram4 / ram_block5a26 | d[4] | 0.788 | 1.179 |
| 27 | 0.393 | ascal:ascal / o_poly_lum1[6] | ascal:ascal / o_poly_lerp_tb[6] | 0.781 | 1.174 |
| 28 | 0.393 | vga_out:vga_scaler_out / altshift_taps:din1_rtl_0 / shift_taps_quu:auto_generated / altsyncram_dr91:altsyncram4 / ram_block5a12 | d[18] | 0.801 | 1.194 |
| 29 | 0.395 | ascal:ascal / o_vdivi[7] | ascal:ascal / o_vdivr[19] | 0.112 | 0.507 |
| 30 | 0.395 | ascal:ascal / o_vpixq_pre[1].b[0] | ascal:ascal / o_vpixq[1].b[0] | 0.797 | 1.192 |
| 31 | 0.398 | ascal:ascal / o_poly_lum1[7] | ascal:ascal / o_poly_lerp_tb[7]~_Duplicate_2 | 0.802 | 1.2 |
| 32 | 0.399 | ascal:ascal / o_vpixq_pre[1].r[2] | ascal:ascal / o_vpixq[1].r[2] | 0.784 | 1.183 |
| 33 | 0.401 | ascal:ascal / o_poly_lum1[1] | ascal:ascal / o_poly_lerp_tb[1]~_Duplicate_2 | 0.798 | 1.199 |
| 34 | 0.401 | vga_out:vga_scaler_out / altshift_taps:din1_rtl_0 / shift_taps_quu:auto_generated / altsyncram_dr91:altsyncram4 / ram_block5a10 | d[20] | 0.797 | 1.198 |
| 35 | 0.402 | osd:hdmi_osd / Add2~49_OTERM411 | osd:hdmi_osd / pixsz[11] | 0.094 | 0.496 |
| 36 | 0.403 | vga_out:vga_scaler_out / altshift_taps:din1_rtl_0 / shift_taps_quu:auto_generated / altsyncram_dr91:altsyncram4 / ram_block5a14 | d[16] | 0.793 | 1.196 |
| 37 | 0.404 | ascal:ascal / o_vpixq_pre[0].g[5] | ascal:ascal / o_vpixq[0].g[5] | 0.836 | 1.24 |
| 38 | 0.404 | ascal:ascal / o_vpixq_pre[2].g[6] | ascal:ascal / o_vpixq[2].g[6] | 0.822 | 1.226 |
| 39 | 0.404 | vga_out:vga_scaler_out / altshift_taps:din1_rtl_0 / shift_taps_quu:auto_generated / altsyncram_dr91:altsyncram4 / ram_block5a27 | d[3] | 0.774 | 1.178 |
| 40 | 0.406 | ascal:ascal / o_vpixq_pre[1].g[0] | ascal:ascal / o_vpixq[1].g[0] | 0.835 | 1.241 |
| 41 | 0.406 | vga_out:vga_scaler_out / altshift_taps:din1_rtl_0 / shift_taps_quu:auto_generated / altsyncram_dr91:altsyncram4 / ram_block5a11 | d[19] | 0.794 | 1.2 |
| 42 | 0.411 | ascal:ascal / o_hpix3.b[7] | ascal:ascal / o_hpixq[2][0].b[7] | 0.117 | 0.528 |
| 43 | 0.412 | ascal:ascal / o_vcpt_sync[8] | ascal:ascal / o_vcpt_sync[8] | 0.111 | 0.523 |
| 44 | 0.412 | ascal:ascal / o_hpixq[2][3].g[0] | ascal:ascal / o_hpixq[3][3].g[0] | 0.103 | 0.515 |
| 45 | 0.412 | ascal:ascal / o_vpix_outer[2].g[0] | ascal:ascal / o_vpixq_pre[3].g[0] | 0.114 | 0.526 |
| 46 | 0.414 | ascal:ascal / o_vpixq_pre[2].g[0] | ascal:ascal / o_vpixq[2].g[0] | 0.814 | 1.228 |
| 47 | 0.416 | ascal:ascal / o_vacpt[0] | ascal:ascal / o_vacpt[0] | 0.111 | 0.527 |
| 48 | 0.416 | ascal:ascal / o_vpixq_pre[3].g[7] | ascal:ascal / o_vpixq[3].g[7] | 0.805 | 1.221 |
| 49 | 0.417 | ascal:ascal / o_vpixq_pre[1].b[2] | ascal:ascal / o_vpixq[1].b[2] | 0.828 | 1.245 |
| 50 | 0.419 | ascal:ascal / o_vpixq_pre[2].b[6] | ascal:ascal / o_vpixq[2].b[6] | 0.825 | 1.244 |

### candidate

| Rank | Slack ns | From | To | Skew ns | Data ns |
| --- | --- | --- | --- | --- | --- |
| 1 | 0.247 | vga_out:vga_scaler_out / altshift_taps:din1_rtl_0 / shift_taps_quu:auto_generated / altsyncram_dr91:altsyncram4 / ram_block5a12 | d[18] | 0.826 | 1.073 |
| 2 | 0.258 | ascal:ascal / o_vcpt_sync[2] | ascal:ascal / o_vcpt_sync[2] | 0.111 | 0.369 |
| 3 | 0.26 | ascal:ascal / o_vdivr[16] | ascal:ascal / o_vdivr[17] | 0.104 | 0.364 |
| 4 | 0.261 | ascal:ascal / o_hacpt[4] | ascal:ascal / o_hacpt[4] | 0.112 | 0.373 |
| 5 | 0.27 | ascal:ascal / o_vdivr[19] | ascal:ascal / o_vdivr[20] | 0.106 | 0.376 |
| 6 | 0.279 | vga_out:vga_scaler_out / altshift_taps:din1_rtl_0 / shift_taps_quu:auto_generated / altsyncram_dr91:altsyncram4 / ram_block5a7 | d[23] | 0.82 | 1.099 |
| 7 | 0.307 | vga_out:vga_scaler_out / altshift_taps:din1_rtl_0 / shift_taps_quu:auto_generated / altsyncram_dr91:altsyncram4 / ram_block5a10 | d[20] | 0.832 | 1.139 |
| 8 | 0.312 | vga_out:vga_scaler_out / altshift_taps:din1_rtl_0 / shift_taps_quu:auto_generated / altsyncram_dr91:altsyncram4 / ram_block5a17 | d[13] | 0.804 | 1.116 |
| 9 | 0.313 | vga_out:vga_scaler_out / altshift_taps:din1_rtl_0 / shift_taps_quu:auto_generated / altsyncram_dr91:altsyncram4 / ram_block5a8 | d[22] | 0.819 | 1.132 |
| 10 | 0.314 | vga_out:vga_scaler_out / altshift_taps:din1_rtl_0 / shift_taps_quu:auto_generated / altsyncram_dr91:altsyncram4 / ram_block5a22 | d[8] | 0.806 | 1.12 |
| 11 | 0.33 | ascal:ascal / o_hpixq[7][0].g[4] | ascal:ascal / o_hpixq[8][0].g[4] | 0.795 | 1.125 |
| 12 | 0.335 | vga_out:vga_scaler_out / altshift_taps:din1_rtl_0 / shift_taps_quu:auto_generated / altsyncram_dr91:altsyncram4 / ram_block5a19 | d[11] | 0.81 | 1.145 |
| 13 | 0.344 | vga_out:vga_scaler_out / altshift_taps:din1_rtl_0 / shift_taps_quu:auto_generated / altsyncram_dr91:altsyncram4 / ram_block5a18 | d[12] | 0.807 | 1.151 |
| 14 | 0.347 | vga_out:vga_scaler_out / altshift_taps:din1_rtl_0 / shift_taps_quu:auto_generated / altsyncram_dr91:altsyncram4 / ram_block5a26 | d[4] | 0.823 | 1.17 |
| 15 | 0.355 | vga_out:vga_scaler_out / altshift_taps:din1_rtl_0 / shift_taps_quu:auto_generated / altsyncram_dr91:altsyncram4 / ram_block5a16 | d[14] | 0.813 | 1.168 |
| 16 | 0.356 | vga_out:vga_scaler_out / altshift_taps:din1_rtl_0 / shift_taps_quu:auto_generated / altsyncram_dr91:altsyncram4 / ram_block5a15 | d[15] | 0.832 | 1.188 |
| 17 | 0.375 | vga_out:vga_scaler_out / altshift_taps:din1_rtl_0 / shift_taps_quu:auto_generated / altsyncram_dr91:altsyncram4 / ram_block5a14 | d[16] | 0.812 | 1.187 |
| 18 | 0.383 | ascal:ascal / o_hpixq[7][2].r[0] | ascal:ascal / o_hpixq[8][2].r[0] | 0.801 | 1.184 |
| 19 | 0.387 | ascal:ascal / o_vpixq_pre[0].b[6] | ascal:ascal / o_vpixq[0].b[6] | 0.832 | 1.219 |
| 20 | 0.393 | vga_out:vga_scaler_out / altshift_taps:din1_rtl_0 / shift_taps_quu:auto_generated / altsyncram_dr91:altsyncram4 / ram_block5a9 | d[21] | 0.814 | 1.207 |
| 21 | 0.396 | ascal:ascal / o_hpixq[7][0].g[6] | ascal:ascal / o_hpixq[8][0].g[6] | 0.809 | 1.205 |
| 22 | 0.412 | ascal:ascal / o_off[1][2] | ascal:ascal / o_off[0][2] | 0.117 | 0.529 |
| 23 | 0.412 | ascal:ascal / o_vpix_outer[2].b[4] | ascal:ascal / o_vpixq_pre[3].b[4] | 0.112 | 0.524 |
| 24 | 0.413 | ascal:ascal / o_vpixq_pre[0].g[2] | ascal:ascal / o_vpixq[0].g[2] | 0.405 | 0.818 |
| 25 | 0.413 | vga_out:vga_scaler_out / altshift_taps:din1_rtl_0 / shift_taps_quu:auto_generated / altsyncram_dr91:altsyncram4 / ram_block5a11 | d[19] | 0.822 | 1.235 |
| 26 | 0.415 | ascal:ascal / o_hpixq[7][2].r[6] | ascal:ascal / o_hpixq[8][2].r[6] | 0.796 | 1.211 |
| 27 | 0.418 | ascal:ascal / o_ad1[2] | ascal:ascal / o_ad2[2] | 0.114 | 0.532 |
| 28 | 0.418 | ascal:ascal / o_hpixq[7][0].g[3] | ascal:ascal / o_hpixq[8][0].g[3] | 0.793 | 1.211 |
| 29 | 0.419 | ascal:ascal / o_vpixq_pre[0].b[3] | ascal:ascal / o_vpixq[0].b[3] | 0.762 | 1.181 |
| 30 | 0.42 | ascal:ascal / o_hpix1.b[3] | ascal:ascal / o_hpixq[2][2].b[3] | 0.12 | 0.54 |
| 31 | 0.422 | ascal:ascal / o_vacpt[0] | ascal:ascal / o_vacpt[0] | 0.114 | 0.536 |
| 32 | 0.423 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a80 | ascal:ascal / o_h_poly_phase.t0[16] | 0.387 | 0.81 |
| 33 | 0.424 | ascal:ascal / o_hacpt[0] | ascal:ascal / o_hacpt[0] | 0.112 | 0.536 |
| 34 | 0.424 | ascal:ascal / o_hpixq[7][2].r[4] | ascal:ascal / o_hpixq[8][2].r[4] | 0.42 | 0.844 |
| 35 | 0.425 | ascal:ascal / o_hcpt[0] | ascal:ascal / o_hcpt[0] | 0.109 | 0.534 |
| 36 | 0.425 | ascal:ascal / o_hpixq[2][3].r[6] | ascal:ascal / o_hpixq[3][3].r[6] | 0.096 | 0.521 |
| 37 | 0.426 | ascal:ascal / o_vacpt[3] | ascal:ascal / o_vacpt[3] | 0.115 | 0.541 |
| 38 | 0.426 | ascal:ascal / o_vcpt_sync[8] | ascal:ascal / o_vcpt_sync[8] | 0.111 | 0.537 |
| 39 | 0.426 | ascal:ascal / o_vdivi[9] | ascal:ascal / o_vdivr[21] | 0.111 | 0.537 |
| 40 | 0.426 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a80 | ascal:ascal / o_h_poly_phase.t0[17] | 0.387 | 0.813 |
| 41 | 0.427 | ascal:ascal / o_vdivr[2] | ascal:ascal / o_vdivr[3] | 0.108 | 0.535 |
| 42 | 0.427 | ascal:ascal / o_hpixq[7][0].g[1] | ascal:ascal / o_hpixq[8][0].g[1] | 0.814 | 1.241 |
| 43 | 0.427 | ascal:ascal / o_poly_lum1[2] | ascal:ascal / o_poly_lerp_tb[2]~_Duplicate_2 | 0.76 | 1.187 |
| 44 | 0.427 | ascal:ascal / o_hpixq[7][3].b[3] | ascal:ascal / o_hpixq[8][3].b[3] | 0.374 | 0.801 |
| 45 | 0.428 | ascal:ascal / o_hbcpt[2] | ascal:ascal / o_hbcpt[2]~DUPLICATE | 0.118 | 0.546 |
| 46 | 0.428 | ascal:ascal / o_vcpt_sync[5] | ascal:ascal / o_vcpt_sync[5] | 0.112 | 0.54 |
| 47 | 0.428 | ascal:ascal / o_vcpt_sync[0] | ascal:ascal / o_vcpt_sync[0] | 0.111 | 0.539 |
| 48 | 0.429 | ascal:ascal / o_vdivi[12] | ascal:ascal / o_vdivr[24] | 0.109 | 0.538 |
| 49 | 0.429 | shadowmask:HDMI_shadowmask / vcount[2] | shadowmask:HDMI_shadowmask / vcount[2]~DUPLICATE | 0.117 | 0.546 |
| 50 | 0.43 | ascal:ascal / o_ad[0] | ascal:ascal / o_ad[0] | 0.115 | 0.545 |

## core_hold

### baseline

| Rank | Slack ns | From | To | Skew ns | Data ns |
| --- | --- | --- | --- | --- | --- |
| 1 | 0.239 | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:60:shifter / shift0[2] | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:60:shifter / shift0[3] | 0.108 | 0.347 |
| 2 | 0.241 | vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:62:shifter / shift1[1] | vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:62:shifter / shift1[2]~DUPLICATE | 0.109 | 0.35 |
| 3 | 0.241 | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:13:shifter / shift1[5] | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:13:shifter / shift1[6] | 0.11 | 0.351 |
| 4 | 0.242 | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:25:shifter / shift1[1] | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:25:shifter / shift1[2] | 0.118 | 0.36 |
| 5 | 0.243 | savestates / nvram_load_addr[2] | savestates / nvram_load_addr[2] | 0.113 | 0.356 |
| 6 | 0.243 | savestates / ss_change_det[15] | savestates / ss_change_det[15] | 0.11 | 0.353 |
| 7 | 0.244 | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:28:shifter / shift1[5] | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:28:shifter / shift1[6] | 0.114 | 0.358 |
| 8 | 0.246 | yc_out:yc_out / cburst_phase[2] | yc_out:yc_out / cburst_phase[2] | 0.11 | 0.356 |
| 9 | 0.246 | savestates / ss_change_det[3] | savestates / ss_change_det[3] | 0.11 | 0.356 |
| 10 | 0.247 | vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:62:shifter / shift1[1] | vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:62:shifter / shift1[2] | 0.105 | 0.352 |
| 11 | 0.247 | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:0:shifter / shift2[3] | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:0:shifter / shift2[4]~DUPLICATE | 0.112 | 0.359 |
| 12 | 0.247 | sys_umuldiv:ar_muldiv / sys_umul:umul / result[14] | sys_umuldiv:ar_muldiv / sys_umul:umul / result[14] | 0.115 | 0.362 |
| 13 | 0.248 | vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:48:shifter / shift0[5] | vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:48:shifter / shift0[6] | 0.117 | 0.365 |
| 14 | 0.248 | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:8:shifter / shift2[2] | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:8:shifter / shift2[3] | 0.108 | 0.356 |
| 15 | 0.248 | emu:emu / video_freak:video_freak / sys_umul:mul / result[14]~DUPLICATE | emu:emu / video_freak:video_freak / sys_umul:mul / result[14] | 0.116 | 0.364 |
| 16 | 0.249 | vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:48:shifter / shift0[4] | vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:48:shifter / shift0[5]~DUPLICATE | 0.11 | 0.359 |
| 17 | 0.249 | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:25:shifter / shift1[1] | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:25:shifter / shift1[2]~DUPLICATE | 0.11 | 0.359 |
| 18 | 0.25 | emu:emu / sd_lba[2] | emu:emu / sd_lba[2] | 0.112 | 0.362 |
| 19 | 0.25 | emu:emu / video_freak:video_freak / video_scale_int:scale / sys_udiv:div / rem[29] | emu:emu / video_freak:video_freak / video_scale_int:scale / sys_udiv:div / rem[30] | 0.112 | 0.362 |
| 20 | 0.25 | sys_umuldiv:ar_muldiv / sys_udiv:udiv / rem[29] | sys_umuldiv:ar_muldiv / sys_udiv:udiv / rem[30] | 0.11 | 0.36 |
| 21 | 0.25 | emu:emu / sd_lba[22] | emu:emu / sd_lba[22] | 0.115 | 0.365 |
| 22 | 0.251 | savestates / flush_cnt[14] | savestates / flush_cnt[14] | 0.112 | 0.363 |
| 23 | 0.251 | savestates / ss_change_det[23] | savestates / ss_change_det[23] | 0.111 | 0.362 |
| 24 | 0.252 | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:55:shifter / shift0[4] | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:55:shifter / shift0[5] | 0.109 | 0.361 |
| 25 | 0.254 | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:0:shifter / shift2[3] | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:0:shifter / shift2[4] | 0.107 | 0.361 |
| 26 | 0.254 | savestates / wram_load_addr[2] | savestates / wram_load_addr[2] | 0.113 | 0.367 |
| 27 | 0.254 | emu:emu / video_freak:video_freak / sys_umul:mul / result[14]~DUPLICATE | emu:emu / video_freak:video_freak / sys_umul:mul / result[14]~DUPLICATE | 0.112 | 0.366 |
| 28 | 0.255 | savestates / nvram_load_addr[4] | savestates / nvram_load_addr[4] | 0.113 | 0.368 |
| 29 | 0.256 | vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:48:shifter / shift0[4] | vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:48:shifter / shift0[5] | 0.105 | 0.361 |
| 30 | 0.256 | ascal:ascal / i_vdivr[16] | ascal:ascal / i_vdivr[17] | 0.106 | 0.362 |
| 31 | 0.257 | emu:emu / sd_lba[14] | emu:emu / sd_lba[14] | 0.112 | 0.369 |
| 32 | 0.258 | savestates / ss_change_det[5] | savestates / ss_change_det[5] | 0.11 | 0.368 |
| 33 | 0.258 | emu:emu / sd_lba[24] | emu:emu / sd_lba[24] | 0.115 | 0.373 |
| 34 | 0.26 | emu:emu / timeout[15] | emu:emu / timeout[15] | 0.109 | 0.369 |
| 35 | 0.262 | emu:emu / sd_lba[17] | emu:emu / sd_lba[17] | 0.112 | 0.374 |
| 36 | 0.262 | emu:emu / timeout[23] | emu:emu / timeout[23] | 0.109 | 0.371 |
| 37 | 0.263 | savestates / nvram_save_addr[2] | savestates / nvram_save_addr[2] | 0.112 | 0.375 |
| 38 | 0.263 | sys_umuldiv:ar_muldiv / sys_umul:umul / result[21] | sys_umuldiv:ar_muldiv / sys_umul:umul / result[21] | 0.116 | 0.379 |
| 39 | 0.264 | savestates / ss_change_det[18] | savestates / ss_change_det[18] | 0.11 | 0.374 |
| 40 | 0.265 | emu:emu / cnt_en16khz[2] | emu:emu / cnt_en16khz[2] | 0.111 | 0.376 |
| 41 | 0.265 | emu:emu / timeout[18] | emu:emu / timeout[18] | 0.109 | 0.374 |
| 42 | 0.266 | savestates / op_cooldown[24] | savestates / op_cooldown[24] | 0.112 | 0.378 |
| 43 | 0.266 | sync_fix:sync_v / cnt[4] | sync_fix:sync_v / cnt[4] | 0.096 | 0.362 |
| 44 | 0.267 | savestates / op_cooldown[4] | savestates / op_cooldown[4] | 0.115 | 0.382 |
| 45 | 0.27 | mapper_detect:mapper_detect_inst / mapper_detect_ticks[4] | mapper_detect:mapper_detect_inst / mapper_detect_ticks[4] | 0.111 | 0.381 |
| 46 | 0.27 | emu:emu / cnt_en16khz[4] | emu:emu / cnt_en16khz[4] | 0.111 | 0.381 |
| 47 | 0.271 | yc_out:yc_out / phase_accum[2] | yc_out:yc_out / phase_accum[2] | 0.091 | 0.362 |
| 48 | 0.274 | savestates / nvram_save_addr[4] | savestates / nvram_save_addr[4] | 0.112 | 0.386 |
| 49 | 0.274 | sync_fix:sync_h / cnt[4] | sync_fix:sync_h / cnt[4] | 0.094 | 0.368 |
| 50 | 0.276 | sub_accum[24] | sub_accum[24] | 0.091 | 0.367 |

### candidate

| Rank | Slack ns | From | To | Skew ns | Data ns |
| --- | --- | --- | --- | --- | --- |
| 1 | 0.241 | vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:11:shifter / shift2[5] | vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:11:shifter / shift2[6]~DUPLICATE | 0.107 | 0.348 |
| 2 | 0.242 | vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:14:shifter / shift0[6] | vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:14:shifter / shift0[7] | 0.112 | 0.354 |
| 3 | 0.243 | savestates / flush_cnt[2] | savestates / flush_cnt[2] | 0.113 | 0.356 |
| 4 | 0.244 | emu:emu / sd_lba[2] | emu:emu / sd_lba[2] | 0.112 | 0.356 |
| 5 | 0.245 | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:35:shifter / shift0[6] | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:35:shifter / shift0[7]~DUPLICATE | 0.115 | 0.36 |
| 6 | 0.245 | vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:47:shifter / shift1[3] | vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:47:shifter / shift1[4] | 0.115 | 0.36 |
| 7 | 0.245 | savestates / nvram_load_addr[2] | savestates / nvram_load_addr[2] | 0.113 | 0.358 |
| 8 | 0.246 | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:49:shifter / shift1[4] | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:49:shifter / shift1[5]~DUPLICATE | 0.109 | 0.355 |
| 9 | 0.246 | vcnt[2] | vcnt[2] | 0.11 | 0.356 |
| 10 | 0.247 | savestates / nvram_save_addr[2] | savestates / nvram_save_addr[2] | 0.113 | 0.36 |
| 11 | 0.248 | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:3:shifter / shift2[1] | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:3:shifter / shift2[2] | 0.108 | 0.356 |
| 12 | 0.248 | vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:11:shifter / shift2[5] | vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:11:shifter / shift2[6] | 0.102 | 0.35 |
| 13 | 0.249 | savestates / ss_change_det[3] | savestates / ss_change_det[3] | 0.107 | 0.356 |
| 14 | 0.25 | savestates / flush_cnt[14] | savestates / flush_cnt[14] | 0.113 | 0.363 |
| 15 | 0.251 | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:44:shifter / shift2[3] | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:44:shifter / shift2[4]~DUPLICATE | 0.108 | 0.359 |
| 16 | 0.251 | emu:emu / sd_lba[14] | emu:emu / sd_lba[14] | 0.112 | 0.363 |
| 17 | 0.252 | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:35:shifter / shift0[6] | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:35:shifter / shift0[7] | 0.107 | 0.359 |
| 18 | 0.252 | emu:emu / video_freak:video_freak / video_scale_int:scale / sys_udiv:div / rem[29] | emu:emu / video_freak:video_freak / video_scale_int:scale / sys_udiv:div / rem[30] | 0.108 | 0.36 |
| 19 | 0.253 | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:49:shifter / shift1[4] | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:49:shifter / shift1[5] | 0.104 | 0.357 |
| 20 | 0.254 | savestates / wram_load_addr[2] | savestates / wram_load_addr[2] | 0.107 | 0.361 |
| 21 | 0.254 | sys_umuldiv:ar_muldiv / sys_umul:umul / result[4] | sys_umuldiv:ar_muldiv / sys_umul:umul / result[4] | 0.111 | 0.365 |
| 22 | 0.254 | emu:emu / hps_io:hps_io / video_calc:video_calc / vid_fclks[14]~DUPLICATE | emu:emu / hps_io:hps_io / video_calc:video_calc / vid_fclks[14] | 0.117 | 0.371 |
| 23 | 0.254 | emu:emu / timeout[23] | emu:emu / timeout[23] | 0.112 | 0.366 |
| 24 | 0.255 | savestates / flush_cnt[4] | savestates / flush_cnt[4] | 0.113 | 0.368 |
| 25 | 0.255 | sys_umuldiv:ar_muldiv / sys_udiv:udiv / rem[30] | sys_umuldiv:ar_muldiv / sys_udiv:udiv / rem[31] | 0.117 | 0.372 |
| 26 | 0.255 | sys_umuldiv:ar_muldiv / sys_umul:umul / result[14] | sys_umuldiv:ar_muldiv / sys_umul:umul / result[14] | 0.114 | 0.369 |
| 27 | 0.255 | emu:emu / savestate_ui:savestate_ui_inst / ss_hold_cnt[14] | emu:emu / savestate_ui:savestate_ui_inst / ss_hold_cnt[14] | 0.113 | 0.368 |
| 28 | 0.256 | emu:emu / sd_lba[4] | emu:emu / sd_lba[4] | 0.112 | 0.368 |
| 29 | 0.256 | savestates / ss_change_det[15] | savestates / ss_change_det[15] | 0.107 | 0.363 |
| 30 | 0.256 | savestates / ss_change_det[23] | savestates / ss_change_det[23] | 0.111 | 0.367 |
| 31 | 0.256 | emu:emu / sd_lba[24] | emu:emu / sd_lba[24] | 0.112 | 0.368 |
| 32 | 0.257 | emu:emu / sega_controller:controller_p2 / timer[14] | emu:emu / sega_controller:controller_p2 / timer[14] | 0.112 | 0.369 |
| 33 | 0.257 | emu:emu / video_freak:video_freak / sys_umul:mul / result[14] | emu:emu / video_freak:video_freak / sys_umul:mul / result[14] | 0.111 | 0.368 |
| 34 | 0.257 | emu:emu / timeout[15] | emu:emu / timeout[15] | 0.112 | 0.369 |
| 35 | 0.258 | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:44:shifter / shift2[3] | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:44:shifter / shift2[4] | 0.103 | 0.361 |
| 36 | 0.258 | sys_umuldiv:ar_muldiv / sys_udiv:udiv / rem[29] | sys_umuldiv:ar_muldiv / sys_udiv:udiv / rem[30] | 0.106 | 0.364 |
| 37 | 0.259 | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:38:shifter / shift2[1] | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:38:shifter / shift2[2] | 0.108 | 0.367 |
| 38 | 0.259 | emu:emu / sega_controller:controller_p1 / timer[4] | emu:emu / sega_controller:controller_p1 / timer[4] | 0.114 | 0.373 |
| 39 | 0.259 | opll:fm / TemporalMixer:tm / mix[3] | opll:fm / TemporalMixer:tm / mix[3]~DUPLICATE | 0.111 | 0.37 |
| 40 | 0.259 | emu:emu / sd_lba[22] | emu:emu / sd_lba[22] | 0.112 | 0.371 |
| 41 | 0.26 | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:58:shifter / shift1[6] | vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:58:shifter / shift1[7] | 0.113 | 0.373 |
| 42 | 0.26 | emu:emu / hps_io:hps_io / video_calc:video_calc / vid_fclks[14]~DUPLICATE | emu:emu / hps_io:hps_io / video_calc:video_calc / vid_fclks[14]~DUPLICATE | 0.113 | 0.373 |
| 43 | 0.26 | sub_accum[34] | sub_accum[34] | 0.093 | 0.353 |
| 44 | 0.261 | savestates / flush_cnt[17] | savestates / flush_cnt[17] | 0.113 | 0.374 |
| 45 | 0.261 | savestates / op_cooldown[12] | savestates / op_cooldown[12] | 0.11 | 0.371 |
| 46 | 0.261 | savestates / ss_change_det[5] | savestates / ss_change_det[5] | 0.107 | 0.368 |
| 47 | 0.262 | savestates / nvram_load_addr[4] | savestates / nvram_load_addr[4] | 0.113 | 0.375 |
| 48 | 0.262 | emu:emu / sd_lba[17] | emu:emu / sd_lba[17] | 0.112 | 0.374 |
| 49 | 0.262 | emu:emu / timeout[18] | emu:emu / timeout[18] | 0.112 | 0.374 |
| 50 | 0.263 | emu:emu / savestate_ui:savestate_ui_inst / cooldown_cnt[14] | emu:emu / savestate_ui:savestate_ui_inst / cooldown_cnt[14] | 0.112 | 0.375 |

## cpu_all_setup

### baseline

| Rank | Slack ns | From | To | Skew ns | Data ns |
| --- | --- | --- | --- | --- | --- |
| 1 | 0.895 | mapper_detect:mapper_detect_inst / rom_crc32[17] | T80s:z80_inst / T80:u0 / IR[3] | -0.46 | 16.941 |
| 2 | 1.012 | mapper_detect:mapper_detect_inst / rom_crc32[17] | T80s:z80_inst / T80:u0 / IR[6] | -0.458 | 16.826 |
| 3 | 1.076 | mapper_detect:mapper_detect_inst / rom_crc32[17] | T80s:z80_inst / T80:u0 / IR[4] | -0.464 | 16.756 |
| 4 | 1.081 | mapper_detect:mapper_detect_inst / rom_crc32[17] | T80s:z80_inst / T80:u0 / IR[4]~DUPLICATE | -0.461 | 16.754 |
| 5 | 1.222 | mapper_detect:mapper_detect_inst / rom_crc32[17] | T80s:z80_inst / T80:u0 / IR[5] | -0.472 | 16.602 |
| 6 | 1.227 | mapper_detect:mapper_detect_inst / rom_crc32[17] | T80s:z80_inst / T80:u0 / IR[5]~DUPLICATE | -0.469 | 16.6 |
| 7 | 1.329 | mapper_detect:mapper_detect_inst / rom_crc32[17] | T80s:z80_inst / T80:u0 / IR[0] | -0.471 | 16.496 |
| 8 | 1.44 | mapper_detect:mapper_detect_inst / rom_crc32[17] | T80s:z80_inst / T80:u0 / IR[2] | -0.467 | 16.389 |
| 9 | 1.539 | mapper_detect:mapper_detect_inst / rom_crc32[17] | T80s:z80_inst / DI_Reg[1]_OTERM305 | -0.465 | 16.292 |
| 10 | 1.54 | mapper_detect:mapper_detect_inst / rom_crc32[17] | T80s:z80_inst / DI_Reg[3]_OTERM299 | -0.465 | 16.291 |
| 11 | 1.546 | mapper_detect:mapper_detect_inst / rom_crc32[17] | T80s:z80_inst / DI_Reg[7]_OTERM321 | -0.462 | 16.288 |
| 12 | 1.595 | emu:emu / sdram:ram / sd_dat[5] | T80s:z80_inst / T80:u0 / IR[7] | -1.782 | 14.919 |
| 13 | 1.652 | mapper_detect:mapper_detect_inst / rom_crc32[17] | T80s:z80_inst / T80:u0 / IR[1]_OTERM557 | -0.45 | 16.194 |
| 14 | 1.745 | mapper_detect:mapper_detect_inst / rom_crc32[17] | T80s:z80_inst / DI_Reg[6]_OTERM359 | -0.453 | 16.098 |
| 15 | 1.746 | mapper_detect:mapper_detect_inst / rom_crc32[17] | T80s:z80_inst / DI_Reg[4]_OTERM347 | -0.45 | 16.1 |
| 16 | 1.758 | mapper_detect:mapper_detect_inst / rom_crc32[17] | T80s:z80_inst / DI_Reg[2]_OTERM351 | -0.453 | 16.085 |
| 17 | 1.793 | emu:emu / sdram:ram / sd_dat[8] | T80s:z80_inst / DI_Reg[0]_OTERM363 | -1.566 | 14.937 |
| 18 | 1.821 | mapper_detect:mapper_detect_inst / rom_crc32[17] | T80s:z80_inst / DI_Reg[4]_OTERM349 | -0.464 | 16.011 |
| 19 | 1.848 | mapper_detect:mapper_detect_inst / rom_crc32[17] | T80s:z80_inst / DI_Reg[5]_OTERM357 | -0.472 | 15.976 |
| 20 | 1.917 | mapper_detect:mapper_detect_inst / rom_crc32[17] | T80s:z80_inst / DI_Reg[2]_OTERM353 | -0.47 | 15.909 |
| 21 | 1.958 | emu:emu / sdram:ram / sd_dat[5] | T80s:z80_inst / DI_Reg[3]_OTERM301 | -1.782 | 14.556 |
| 22 | 1.964 | emu:emu / sdram:ram / sd_dat[5] | T80s:z80_inst / DI_Reg[3]_OTERM301~DUPLICATE | -1.779 | 14.553 |
| 23 | 2.051 | mapper_detect:mapper_detect_inst / rom_crc32[17] | T80s:z80_inst / DI_Reg[0]_OTERM365 | -0.47 | 15.775 |
| 24 | 2.054 | emu:emu / ce_cpu | T80s:z80_inst / T80:u0 / PC[11] | -0.478 | 6.451 |
| 25 | 2.054 | emu:emu / ce_cpu | T80s:z80_inst / T80:u0 / PC[14]~DUPLICATE | -0.478 | 6.451 |
| 26 | 2.054 | emu:emu / ce_cpu | T80s:z80_inst / T80:u0 / PC[15] | -0.478 | 6.451 |
| 27 | 2.055 | emu:emu / ce_cpu | T80s:z80_inst / T80:u0 / PC[14] | -0.481 | 6.447 |
| 28 | 2.069 | mapper_detect:mapper_detect_inst / rom_crc32[17] | T80s:z80_inst / DI_Reg[3]_OTERM303 | -0.465 | 15.762 |
| 29 | 2.071 | mapper_detect:mapper_detect_inst / rom_crc32[17] | T80s:z80_inst / DI_Reg[1]_OTERM307 | -0.465 | 15.76 |
| 30 | 2.097 | emu:emu / ce_pix~DUPLICATE | T80s:z80_inst / T80:u0 / WZ[4] | -0.512 | 6.374 |
| 31 | 2.128 | emu:emu / ce_cpu | T80s:z80_inst / T80:u0 / PC[6] | -0.472 | 6.383 |
| 32 | 2.128 | emu:emu / ce_cpu | T80s:z80_inst / T80:u0 / PC[1]~DUPLICATE | -0.472 | 6.383 |
| 33 | 2.128 | emu:emu / ce_cpu | T80s:z80_inst / T80:u0 / PC[7] | -0.472 | 6.383 |
| 34 | 2.128 | emu:emu / ce_cpu | T80s:z80_inst / T80:u0 / PC[4] | -0.472 | 6.383 |
| 35 | 2.128 | emu:emu / ce_cpu | T80s:z80_inst / T80:u0 / PC[3] | -0.472 | 6.383 |
| 36 | 2.128 | emu:emu / ce_cpu | T80s:z80_inst / T80:u0 / PC[2] | -0.472 | 6.383 |
| 37 | 2.129 | emu:emu / ce_cpu | T80s:z80_inst / T80:u0 / PC[5] | -0.476 | 6.378 |
| 38 | 2.129 | emu:emu / ce_cpu | T80s:z80_inst / T80:u0 / PC[1] | -0.476 | 6.378 |
| 39 | 2.149 | mapper_detect:mapper_detect_inst / rom_crc32[17] | T80s:z80_inst / DI_Reg[5]_OTERM355 | -0.45 | 15.697 |
| 40 | 2.151 | emu:emu / ce_cpu | T80s:z80_inst / T80:u0 / Save_ALU_r | -0.476 | 6.356 |
| 41 | 2.151 | emu:emu / ce_cpu | T80s:z80_inst / T80:u0 / ALU_Op_r[1] | -0.476 | 6.356 |
| 42 | 2.152 | emu:emu / ce_cpu | T80s:z80_inst / T80:u0 / ALU_Op_r[3] | -0.474 | 6.357 |
| 43 | 2.162 | emu:emu / ce_pix~DUPLICATE | T80s:z80_inst / T80:u0 / WZ[3] | -0.492 | 6.329 |
| 44 | 2.165 | mapper_detect:mapper_detect_inst / rom_crc32[17] | T80s:z80_inst / DI_Reg[6]_OTERM361 | -0.464 | 15.667 |
| 45 | 2.229 | emu:emu / ce_cpu | T80s:z80_inst / T80:u0 / MCycles[0] | -0.473 | 6.281 |
| 46 | 2.263 | emu:emu / ce_pix~DUPLICATE | T80s:z80_inst / T80:u0 / Pre_XY_F_M[2] | -0.505 | 6.215 |
| 47 | 2.265 | emu:emu / ce_pix~DUPLICATE | T80s:z80_inst / T80:u0 / Pre_XY_F_M[1] | -0.501 | 6.217 |
| 48 | 2.265 | mapper_detect:mapper_detect_inst / rom_crc32[17] | T80s:z80_inst / T80:u0 / IR[1]_OTERM565 | -0.45 | 15.581 |
| 49 | 2.266 | emu:emu / ce_pix~DUPLICATE | T80s:z80_inst / T80:u0 / Pre_XY_F_M[0] | -0.502 | 6.215 |
| 50 | 2.302 | emu:emu / ce_pix~DUPLICATE | T80s:z80_inst / T80:u0 / WZ[5] | -0.505 | 6.176 |

### candidate

| Rank | Slack ns | From | To | Skew ns | Data ns |
| --- | --- | --- | --- | --- | --- |
| 1 | 0.817 | emu:emu / sdram:ram / sd_dat[8] | T80s:z80_inst / T80:u0 / IR[5] | -1.547 | 15.932 |
| 2 | 0.822 | emu:emu / sdram:ram / sd_dat[8] | T80s:z80_inst / T80:u0 / IR[5]~DUPLICATE | -1.544 | 15.93 |
| 3 | 1.188 | emu:emu / sdram:ram / sd_dat[8] | T80s:z80_inst / T80:u0 / IR[3]~DUPLICATE | -1.559 | 15.549 |
| 4 | 1.193 | emu:emu / sdram:ram / sd_dat[8] | T80s:z80_inst / T80:u0 / IR[3] | -1.556 | 15.547 |
| 5 | 1.376 | emu:emu / sdram:ram / sd_dat[8] | T80s:z80_inst / T80:u0 / IR[4] | -1.547 | 15.373 |
| 6 | 1.503 | emu:emu / sdram:ram / sd_dat[8] | T80s:z80_inst / DI_Reg[5]_OTERM305 | -1.557 | 15.236 |
| 7 | 1.55 | emu:emu / sdram:ram / sd_dat[8] | T80s:z80_inst / T80:u0 / IR[1]_OTERM581 | -1.519 | 15.227 |
| 8 | 1.569 | emu:emu / sdram:ram / sd_dat[8] | T80s:z80_inst / DI_Reg[1]_OTERM325 | -1.562 | 15.165 |
| 9 | 1.576 | emu:emu / sdram:ram / sd_dat[8] | T80s:z80_inst / DI_Reg[0]_OTERM329 | -1.546 | 15.174 |
| 10 | 1.634 | emu:emu / sdram:ram / sd_dat[8] | T80s:z80_inst / T80:u0 / IR[7]_OTERM589 | -1.544 | 15.118 |
| 11 | 1.655 | emu:emu / sdram:ram / sd_dat[8] | T80s:z80_inst / T80:u0 / IR[2]_OTERM561 | -1.545 | 15.096 |
| 12 | 1.657 | emu:emu / sdram:ram / sd_dat[8] | T80s:z80_inst / DI_Reg[2]_OTERM321 | -1.543 | 15.096 |
| 13 | 1.674 | emu:emu / sdram:ram / sd_dat[8] | T80s:z80_inst / DI_Reg[4]_OTERM301 | -1.546 | 15.076 |
| 14 | 1.699 | emu:emu / sdram:ram / sd_dat[8] | T80s:z80_inst / T80:u0 / IR[6]_OTERM569 | -1.55 | 15.047 |
| 15 | 1.7 | emu:emu / sdram:ram / sd_dat[8] | T80s:z80_inst / DI_Reg[1]_OTERM327 | -1.557 | 15.039 |
| 16 | 1.753 | emu:emu / sdram:ram / sd_dat[8] | T80s:z80_inst / DI_Reg[7]_OTERM313 | -1.562 | 14.981 |
| 17 | 1.759 | emu:emu / sdram:ram / sd_dat[8] | T80s:z80_inst / DI_Reg[7]_OTERM315 | -1.547 | 14.99 |
| 18 | 1.773 | emu:emu / sdram:ram / sd_dat[8] | T80s:z80_inst / DI_Reg[6]_OTERM309 | -1.565 | 14.958 |
| 19 | 1.782 | emu:emu / sdram:ram / sd_dat[8] | T80s:z80_inst / DI_Reg[4]_OTERM303 | -1.546 | 14.968 |
| 20 | 1.783 | emu:emu / sdram:ram / sd_dat[8] | T80s:z80_inst / DI_Reg[5]_OTERM307 | -1.546 | 14.967 |
| 21 | 1.788 | emu:emu / ce_cpu | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[1][3] | -0.551 | 6.644 |
| 22 | 1.789 | emu:emu / ce_cpu | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[1][4] | -0.555 | 6.639 |
| 23 | 1.789 | emu:emu / ce_cpu | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[1][4]~DUPLICATE | -0.552 | 6.642 |
| 24 | 1.789 | emu:emu / ce_cpu | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[1][6]~DUPLICATE | -0.552 | 6.642 |
| 25 | 1.789 | emu:emu / ce_cpu | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[1][6] | -0.555 | 6.639 |
| 26 | 1.801 | emu:emu / sdram:ram / sd_dat[8] | T80s:z80_inst / T80:u0 / IR[1]_OTERM579 | -1.532 | 14.963 |
| 27 | 1.808 | emu:emu / sdram:ram / sd_dat[8] | T80s:z80_inst / T80:u0 / IR[6]_OTERM567 | -1.548 | 14.94 |
| 28 | 1.823 | emu:emu / sdram:ram / sd_dat[8] | T80s:z80_inst / T80:u0 / IR[0]_OTERM594 | -1.546 | 14.927 |
| 29 | 1.837 | emu:emu / ce_cpu | T80s:z80_inst / T80:u0 / I[4] | -0.542 | 6.604 |
| 30 | 1.838 | emu:emu / ce_cpu | T80s:z80_inst / T80:u0 / I[7] | -0.549 | 6.596 |
| 31 | 1.838 | emu:emu / ce_cpu | T80s:z80_inst / T80:u0 / I[1] | -0.549 | 6.596 |
| 32 | 1.838 | emu:emu / ce_cpu | T80s:z80_inst / T80:u0 / I[0] | -0.543 | 6.602 |
| 33 | 1.838 | emu:emu / ce_cpu | T80s:z80_inst / T80:u0 / I[2] | -0.543 | 6.602 |
| 34 | 1.838 | emu:emu / ce_cpu | T80s:z80_inst / T80:u0 / I[3] | -0.543 | 6.602 |
| 35 | 1.838 | emu:emu / ce_cpu | T80s:z80_inst / T80:u0 / I[5] | -0.549 | 6.596 |
| 36 | 1.838 | emu:emu / ce_cpu | T80s:z80_inst / T80:u0 / I[4]~DUPLICATE | -0.549 | 6.596 |
| 37 | 1.838 | emu:emu / ce_cpu | T80s:z80_inst / T80:u0 / I[6] | -0.543 | 6.602 |
| 38 | 1.838 | emu:emu / ce_cpu | T80s:z80_inst / T80:u0 / I[0]~DUPLICATE | -0.547 | 6.598 |
| 39 | 1.872 | emu:emu / sdram:ram / sd_dat[8] | T80s:z80_inst / DI_Reg[3]_OTERM319 | -1.547 | 14.877 |
| 40 | 1.873 | emu:emu / ce_cpu | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[1][0] | -0.554 | 6.556 |
| 41 | 1.874 | emu:emu / ce_cpu | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[1][1]~DUPLICATE | -0.549 | 6.56 |
| 42 | 1.874 | emu:emu / ce_cpu | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[1][1] | -0.552 | 6.557 |
| 43 | 1.877 | emu:emu / sdram:ram / sd_dat[8] | T80s:z80_inst / T80:u0 / IR[7]_OTERM591 | -1.547 | 14.872 |
| 44 | 1.894 | emu:emu / sdram:ram / sd_dat[8] | T80s:z80_inst / T80:u0 / IR[0]_OTERM596 | -1.547 | 14.855 |
| 45 | 1.899 | emu:emu / sdram:ram / sd_dat[8] | T80s:z80_inst / T80:u0 / IR[2]_OTERM563 | -1.547 | 14.85 |
| 46 | 1.916 | emu:emu / sdram:ram / sd_dat[8] | T80s:z80_inst / DI_Reg[2]_OTERM323 | -1.547 | 14.833 |
| 47 | 1.928 | emu:emu / sdram:ram / sd_dat[8] | T80s:z80_inst / DI_Reg[0]_OTERM331 | -1.547 | 14.821 |
| 48 | 1.932 | emu:emu / sdram:ram / sd_dat[8] | T80s:z80_inst / DI_Reg[6]_OTERM311 | -1.547 | 14.817 |
| 49 | 1.937 | emu:emu / ce_cpu | T80s:z80_inst / T80:u0 / WZ[9] | -0.55 | 6.496 |
| 50 | 1.937 | emu:emu / ce_cpu | T80s:z80_inst / T80:u0 / WZ[14] | -0.55 | 6.496 |

## cpu_restore_setup

### baseline

| Rank | Slack ns | From | To | Skew ns | Data ns |
| --- | --- | --- | --- | --- | --- |
| 1 | 11.691 | savestates / z80_set | T80s:z80_inst / T80:u0 / IR[0] | -0.464 | 6.141 |
| 2 | 11.702 | savestates / z80_set | T80s:z80_inst / T80:u0 / IR[7] | -0.46 | 6.134 |
| 3 | 11.76 | savestates / z80_set | T80s:z80_inst / T80:u0 / WZ[12] | -0.448 | 6.088 |
| 4 | 11.761 | savestates / z80_set | T80s:z80_inst / T80:u0 / IR[3] | -0.453 | 6.082 |
| 5 | 11.761 | savestates / z80_set | T80s:z80_inst / T80:u0 / WZ[11] | -0.449 | 6.086 |
| 6 | 11.761 | savestates / z80_set | T80s:z80_inst / T80:u0 / WZ[13]~DUPLICATE | -0.449 | 6.086 |
| 7 | 11.761 | savestates / z80_set | T80s:z80_inst / T80:u0 / WZ[13] | -0.453 | 6.082 |
| 8 | 11.761 | savestates / z80_set | T80s:z80_inst / T80:u0 / WZ[14] | -0.455 | 6.08 |
| 9 | 11.761 | savestates / z80_set | T80s:z80_inst / T80:u0 / WZ[10] | -0.455 | 6.08 |
| 10 | 11.761 | savestates / z80_set | T80s:z80_inst / T80:u0 / WZ[9] | -0.449 | 6.086 |
| 11 | 11.761 | savestates / z80_set | T80s:z80_inst / T80:u0 / WZ[8] | -0.455 | 6.08 |
| 12 | 11.761 | savestates / z80_set | T80s:z80_inst / T80:u0 / WZ[15]~DUPLICATE | -0.453 | 6.082 |
| 13 | 11.761 | savestates / z80_set | T80s:z80_inst / T80:u0 / WZ[15] | -0.449 | 6.086 |
| 14 | 11.795 | savestates / z80_set | T80s:z80_inst / T80:u0 / IR[5] | -0.465 | 6.036 |
| 15 | 11.8 | savestates / z80_set | T80s:z80_inst / T80:u0 / IR[5]~DUPLICATE | -0.462 | 6.034 |
| 16 | 11.807 | savestates / z80_set | T80s:z80_inst / T80:u0 / IR[4] | -0.457 | 6.032 |
| 17 | 11.812 | savestates / z80_set | T80s:z80_inst / T80:u0 / IR[4]~DUPLICATE | -0.454 | 6.03 |
| 18 | 11.955 | savestates / z80_set | T80s:z80_inst / T80:u0 / IR[2] | -0.46 | 5.881 |
| 19 | 11.979 | savestates / z80_set | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[3][3] | -0.441 | 5.876 |
| 20 | 11.979 | savestates / z80_set | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[3][1] | -0.441 | 5.876 |
| 21 | 11.979 | savestates / z80_set | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[3][7] | -0.441 | 5.876 |
| 22 | 11.979 | savestates / z80_set | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[3][6] | -0.441 | 5.876 |
| 23 | 11.98 | savestates / z80_set | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[3][2] | -0.446 | 5.87 |
| 24 | 11.98 | savestates / z80_set | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[3][0] | -0.446 | 5.87 |
| 25 | 11.98 | savestates / z80_set | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[3][5] | -0.446 | 5.87 |
| 26 | 11.98 | savestates / z80_set | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[3][4] | -0.446 | 5.87 |
| 27 | 12.025 | savestates / z80_set | T80s:z80_inst / T80:u0 / A[15]~DUPLICATE | -0.457 | 5.814 |
| 28 | 12.025 | savestates / z80_set | T80s:z80_inst / T80:u0 / A[12] | -0.455 | 5.816 |
| 29 | 12.025 | savestates / z80_set | T80s:z80_inst / T80:u0 / A[8]~DUPLICATE | -0.457 | 5.814 |
| 30 | 12.025 | savestates / z80_set | T80s:z80_inst / T80:u0 / A[11]~DUPLICATE | -0.457 | 5.814 |
| 31 | 12.025 | savestates / z80_set | T80s:z80_inst / T80:u0 / A[14] | -0.455 | 5.816 |
| 32 | 12.025 | savestates / z80_set | T80s:z80_inst / T80:u0 / A[13] | -0.455 | 5.816 |
| 33 | 12.025 | savestates / z80_set | T80s:z80_inst / T80:u0 / A[10]~DUPLICATE | -0.457 | 5.814 |
| 34 | 12.025 | savestates / z80_set | T80s:z80_inst / T80:u0 / A[9] | -0.455 | 5.816 |
| 35 | 12.029 | savestates / z80_set | T80s:z80_inst / T80:u0 / IR[6] | -0.451 | 5.816 |
| 36 | 12.03 | savestates / z80_set | T80s:z80_inst / T80:u0 / A[15] | -0.45 | 5.816 |
| 37 | 12.03 | savestates / z80_set | T80s:z80_inst / T80:u0 / A[10] | -0.45 | 5.816 |
| 38 | 12.03 | savestates / z80_set | T80s:z80_inst / T80:u0 / A[8] | -0.45 | 5.816 |
| 39 | 12.03 | savestates / z80_set | T80s:z80_inst / T80:u0 / A[11] | -0.45 | 5.816 |
| 40 | 12.031 | savestates / z80_set | T80s:z80_inst / T80:u0 / A[14]~DUPLICATE | -0.451 | 5.814 |
| 41 | 12.031 | savestates / z80_set | T80s:z80_inst / T80:u0 / A[9]~DUPLICATE | -0.451 | 5.814 |
| 42 | 12.031 | savestates / z80_set | T80s:z80_inst / T80:u0 / A[12]~DUPLICATE | -0.451 | 5.814 |
| 43 | 12.031 | savestates / z80_set | T80s:z80_inst / T80:u0 / A[13]~DUPLICATE | -0.451 | 5.814 |
| 44 | 12.045 | savestates / z80_set | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[1][2] | -0.45 | 5.801 |
| 45 | 12.045 | savestates / z80_set | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[1][0] | -0.444 | 5.807 |
| 46 | 12.046 | savestates / z80_set | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[1][1] | -0.445 | 5.805 |
| 47 | 12.046 | savestates / z80_set | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[1][7] | -0.445 | 5.805 |
| 48 | 12.071 | savestates / z80_set | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[5][0] | -0.441 | 5.784 |
| 49 | 12.072 | savestates / z80_set | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[5][1] | -0.442 | 5.782 |
| 50 | 12.072 | savestates / z80_set | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[5][7]~DUPLICATE | -0.442 | 5.782 |

### candidate

| Rank | Slack ns | From | To | Skew ns | Data ns |
| --- | --- | --- | --- | --- | --- |
| 1 | 9.313 | savestates / z80_nmi_hold | T80s:z80_inst / T80:u0 / NMICycle | -0.63 | 8.353 |
| 2 | 9.502 | savestates / z80_nmi_hold | T80s:z80_inst / T80:u0 / NMI_s | -0.63 | 8.164 |
| 3 | 9.676 | savestates / z80_set | T80s:z80_inst / T80:u0 / A[15]~DUPLICATE | -0.506 | 8.114 |
| 4 | 9.676 | savestates / z80_set | T80s:z80_inst / T80:u0 / A[13]~DUPLICATE | -0.506 | 8.114 |
| 5 | 9.677 | savestates / z80_set | T80s:z80_inst / T80:u0 / A[14]~DUPLICATE | -0.508 | 8.111 |
| 6 | 9.681 | savestates / z80_set | T80s:z80_inst / T80:u0 / A[14] | -0.501 | 8.114 |
| 7 | 9.683 | savestates / z80_set | T80s:z80_inst / T80:u0 / A[15] | -0.502 | 8.111 |
| 8 | 9.683 | savestates / z80_set | T80s:z80_inst / T80:u0 / A[13] | -0.502 | 8.111 |
| 9 | 10.376 | savestates / z80_set | T80s:z80_inst / T80:u0 / WZ[9] | -0.51 | 7.41 |
| 10 | 10.376 | savestates / z80_set | T80s:z80_inst / T80:u0 / WZ[14] | -0.51 | 7.41 |
| 11 | 10.378 | savestates / z80_set | T80s:z80_inst / T80:u0 / WZ[10] | -0.515 | 7.403 |
| 12 | 10.378 | savestates / z80_set | T80s:z80_inst / T80:u0 / WZ[15] | -0.515 | 7.403 |
| 13 | 10.475 | savestates / z80_set | T80s:z80_inst / T80:u0 / WZ[13] | -0.511 | 7.31 |
| 14 | 10.476 | savestates / z80_set | T80s:z80_inst / T80:u0 / WZ[11] | -0.515 | 7.305 |
| 15 | 10.476 | savestates / z80_set | T80s:z80_inst / T80:u0 / WZ[12] | -0.509 | 7.311 |
| 16 | 10.477 | savestates / z80_set | T80s:z80_inst / T80:u0 / WZ[8] | -0.516 | 7.303 |
| 17 | 10.533 | savestates / z80_set | T80s:z80_inst / T80:u0 / WZ[2] | -0.524 | 7.239 |
| 18 | 10.533 | savestates / z80_set | T80s:z80_inst / T80:u0 / WZ[1] | -0.524 | 7.239 |
| 19 | 10.533 | savestates / z80_set | T80s:z80_inst / T80:u0 / WZ[3]~DUPLICATE | -0.524 | 7.239 |
| 20 | 10.534 | savestates / z80_set | T80s:z80_inst / T80:u0 / WZ[3] | -0.526 | 7.236 |
| 21 | 10.576 | savestates / z80_set | T80s:z80_inst / T80:u0 / WZ[7] | -0.518 | 7.202 |
| 22 | 10.576 | savestates / z80_set | T80s:z80_inst / T80:u0 / WZ[6] | -0.518 | 7.202 |
| 23 | 10.577 | savestates / z80_set | T80s:z80_inst / T80:u0 / WZ[0] | -0.52 | 7.199 |
| 24 | 10.595 | savestates / z80_set | T80s:z80_inst / T80:u0 / A[12]~DUPLICATE | -0.527 | 7.174 |
| 25 | 10.595 | savestates / z80_set | T80s:z80_inst / T80:u0 / A[8] | -0.527 | 7.174 |
| 26 | 10.596 | savestates / z80_set | T80s:z80_inst / T80:u0 / A[9]~DUPLICATE | -0.528 | 7.172 |
| 27 | 10.601 | savestates / z80_set | T80s:z80_inst / T80:u0 / A[8]~DUPLICATE | -0.523 | 7.172 |
| 28 | 10.601 | savestates / z80_set | T80s:z80_inst / T80:u0 / A[12] | -0.523 | 7.172 |
| 29 | 10.601 | savestates / z80_set | T80s:z80_inst / T80:u0 / A[9] | -0.521 | 7.174 |
| 30 | 10.613 | savestates / z80_set | T80s:z80_inst / T80:u0 / WZ[5] | -0.522 | 7.161 |
| 31 | 10.613 | savestates / z80_set | T80s:z80_inst / T80:u0 / WZ[4] | -0.518 | 7.165 |
| 32 | 10.945 | savestates / z80_set | T80s:z80_inst / T80:u0 / A[11] | -0.521 | 6.83 |
| 33 | 10.951 | savestates / z80_set | T80s:z80_inst / T80:u0 / A[10] | -0.515 | 6.83 |
| 34 | 10.987 | savestates / z80_set | T80s:z80_inst / T80:u0 / ALU_Op_r[1] | -0.52 | 6.789 |
| 35 | 10.987 | savestates / z80_set | T80s:z80_inst / T80:u0 / ALU_Op_r[3] | -0.52 | 6.789 |
| 36 | 10.988 | savestates / z80_set | T80s:z80_inst / T80:u0 / ALU_Op_r[0] | -0.518 | 6.79 |
| 37 | 10.988 | savestates / z80_set | T80s:z80_inst / T80:u0 / MCycles[1] | -0.524 | 6.784 |
| 38 | 10.988 | savestates / z80_set | T80s:z80_inst / T80:u0 / ALU_Op_r[2] | -0.518 | 6.79 |
| 39 | 10.988 | savestates / z80_set | T80s:z80_inst / T80:u0 / Z16_r | -0.524 | 6.784 |
| 40 | 10.989 | savestates / z80_set | T80s:z80_inst / T80:u0 / ALU_Op_r[2]~DUPLICATE | -0.525 | 6.782 |
| 41 | 10.989 | savestates / z80_set | T80s:z80_inst / T80:u0 / ALU_Op_r[0]~DUPLICATE | -0.525 | 6.782 |
| 42 | 11.017 | savestates / z80_set | T80s:z80_inst / T80:u0 / IR[3]~DUPLICATE | -0.515 | 6.764 |
| 43 | 11.022 | savestates / z80_set | T80s:z80_inst / T80:u0 / IR[3] | -0.512 | 6.762 |
| 44 | 11.027 | savestates / z80_set | T80s:z80_inst / T80:u0 / No_BTR | -0.52 | 6.749 |
| 45 | 11.029 | savestates / z80_set | T80s:z80_inst / T80:u0 / Arith16_r | -0.525 | 6.742 |
| 46 | 11.11 | savestates / z80_set | T80s:z80_inst / T80:u0 / IR[6]_OTERM571 | -0.5 | 6.686 |
| 47 | 11.184 | savestates / z80_set | T80s:z80_inst / T80:u0 / PC[11] | -0.532 | 6.58 |
| 48 | 11.193 | savestates / z80_set | T80s:z80_inst / T80:u0 / PC[12] | -0.537 | 6.566 |
| 49 | 11.198 | savestates / z80_set | T80s:z80_inst / T80:u0 / PC[14] | -0.532 | 6.566 |
| 50 | 11.276 | savestates / z80_set | T80s:z80_inst / T80:u0 / PreserveC_r | -0.52 | 6.5 |

## cpu_restore_hold

### baseline

| Rank | Slack ns | From | To | Skew ns | Data ns |
| --- | --- | --- | --- | --- | --- |
| 1 | 0.441 | savestates / z80_dir[89] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[0][1] | 0.509 | 0.95 |
| 2 | 0.446 | savestates / z80_dir[89] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[0][1]~DUPLICATE | 0.506 | 0.952 |
| 3 | 0.476 | savestates / z80_dir[132] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsL[3][4] | 0.503 | 0.979 |
| 4 | 0.497 | savestates / z80_dir[226] | T80s:z80_inst / T80:u0 / WZ[14] | 0.113 | 0.61 |
| 5 | 0.498 | savestates / z80_dir[19] | T80s:z80_inst / T80:u0 / Ap[3] | 0.107 | 0.605 |
| 6 | 0.498 | savestates / z80_dir[222] | T80s:z80_inst / T80:u0 / WZ[10] | 0.118 | 0.616 |
| 7 | 0.503 | savestates / z80_dir[72] | T80s:z80_inst / T80:u0 / PC[8] | 0.481 | 0.984 |
| 8 | 0.504 | savestates / z80_dir[91] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[0][3] | 0.511 | 1.015 |
| 9 | 0.508 | savestates / z80_dir[130] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsL[3][2] | 0.503 | 1.011 |
| 10 | 0.525 | savestates / z80_dir[114] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsL[6][2] | 0.117 | 0.642 |
| 11 | 0.528 | savestates / z80_dir[113] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsL[6][1] | 0.112 | 0.64 |
| 12 | 0.53 | savestates / z80_dir[24] | T80s:z80_inst / T80:u0 / Fp[0] | 0.497 | 1.027 |
| 13 | 0.531 | savestates / z80_dir[224] | T80s:z80_inst / T80:u0 / WZ[12] | 0.12 | 0.651 |
| 14 | 0.532 | savestates / z80_dir[113] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsL[2][1] | 0.117 | 0.649 |
| 15 | 0.536 | savestates / z80_dir[221] | T80s:z80_inst / T80:u0 / WZ[9] | 0.118 | 0.654 |
| 16 | 0.539 | savestates / z80_dir[152] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[0][0] | 0.108 | 0.647 |
| 17 | 0.539 | savestates / z80_dir[227] | T80s:z80_inst / T80:u0 / WZ[15] | 0.118 | 0.657 |
| 18 | 0.54 | savestates / z80_dir[71] | T80s:z80_inst / T80:u0 / PC[7] | 0.482 | 1.022 |
| 19 | 0.542 | savestates / z80_dir[65] | T80s:z80_inst / T80:u0 / A[1]~DUPLICATE | 0.091 | 0.633 |
| 20 | 0.543 | savestates / z80_dir[202] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[7][2] | 0.11 | 0.653 |
| 21 | 0.545 | savestates / z80_dir[227] | T80s:z80_inst / T80:u0 / WZ[15]~DUPLICATE | 0.114 | 0.659 |
| 22 | 0.546 | savestates / z80_dir[65] | T80s:z80_inst / T80:u0 / A[1] | 0.088 | 0.634 |
| 23 | 0.547 | savestates / z80_dir[193] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsL[7][1] | 0.49 | 1.037 |
| 24 | 0.548 | savestates / z80_dir[228] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[0][6] | 0.513 | 1.061 |
| 25 | 0.551 | savestates / z80_dir[228] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[0][7] | 0.515 | 1.066 |
| 26 | 0.551 | savestates / z80_dir[140] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[3][4] | 0.506 | 1.057 |
| 27 | 0.552 | savestates / z80_dir[153] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[4][1] | 0.516 | 1.068 |
| 28 | 0.555 | savestates / z80_dir[228] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[0][4] | 0.513 | 1.068 |
| 29 | 0.556 | savestates / z80_dir[212] | T80s:z80_inst / T80:u0 / WZ[0] | 0.491 | 1.047 |
| 30 | 0.557 | savestates / z80_dir[86] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsL[0][6] | 0.118 | 0.675 |
| 31 | 0.557 | savestates / z80_dir[138] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[3][2] | 0.501 | 1.058 |
| 32 | 0.557 | savestates / z80_dir[84] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsL[0][4] | 0.118 | 0.675 |
| 33 | 0.56 | savestates / z80_dir[172] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[1][4] | 0.511 | 1.071 |
| 34 | 0.564 | savestates / z80_dir[172] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[5][4]~DUPLICATE | 0.521 | 1.085 |
| 35 | 0.567 | savestates / z80_dir[197] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsL[7][5] | 0.487 | 1.054 |
| 36 | 0.568 | savestates / z80_dir[128] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsL[3][0] | 0.484 | 1.052 |
| 37 | 0.569 | savestates / z80_dir[18] | T80s:z80_inst / T80:u0 / Ap[2] | 0.119 | 0.688 |
| 38 | 0.57 | savestates / z80_dir[148] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsL[4][4] | 0.108 | 0.678 |
| 39 | 0.571 | savestates / z80_dir[109] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[5][5] | 0.515 | 1.086 |
| 40 | 0.571 | savestates / z80_dir[172] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[5][4] | 0.516 | 1.087 |
| 41 | 0.572 | savestates / z80_dir[192] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsL[7][0] | 0.485 | 1.057 |
| 42 | 0.574 | savestates / z80_dir[199] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsL[7][7] | 0.498 | 1.072 |
| 43 | 0.58 | savestates / z80_dir[228] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[4][3] | 0.52 | 1.1 |
| 44 | 0.58 | savestates / z80_dir[110] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[5][6] | 0.5 | 1.08 |
| 45 | 0.582 | savestates / z80_dir[228] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[6][2] | 0.513 | 1.095 |
| 46 | 0.583 | savestates / z80_dir[86] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsL[4][6] | 0.112 | 0.695 |
| 47 | 0.583 | savestates / z80_dir[23] | T80s:z80_inst / T80:u0 / Ap[7] | 0.501 | 1.084 |
| 48 | 0.583 | savestates / z80_dir[228] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[2][2] | 0.51 | 1.093 |
| 49 | 0.584 | savestates / z80_dir[228] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[4][0] | 0.514 | 1.098 |
| 50 | 0.587 | savestates / z80_dir[134] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsL[3][6] | 0.491 | 1.078 |

### candidate

| Rank | Slack ns | From | To | Skew ns | Data ns |
| --- | --- | --- | --- | --- | --- |
| 1 | 0.522 | savestates / z80_snap[121] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[6][1] | 0.079 | 0.601 |
| 2 | 0.531 | savestates / z80_snap[88] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[0][0] | 0.084 | 0.615 |
| 3 | 0.539 | savestates / z80_snap[124] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[2][4] | 0.083 | 0.622 |
| 4 | 0.539 | savestates / z80_snap[106] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[1][2] | 0.082 | 0.621 |
| 5 | 0.54 | savestates / z80_snap[124] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[2][4]~DUPLICATE | 0.08 | 0.62 |
| 6 | 0.541 | savestates / z80_snap[123] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[2][3] | 0.081 | 0.622 |
| 7 | 0.541 | savestates / z80_snap[186] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[6][2] | 0.077 | 0.618 |
| 8 | 0.544 | savestates / z80_snap[95] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[0][7] | 0.09 | 0.634 |
| 9 | 0.546 | savestates / z80_snap[105] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[5][1] | 0.087 | 0.633 |
| 10 | 0.546 | savestates / z80_snap[226] | T80s:z80_inst / T80:u0 / WZ[14] | 0.496 | 1.042 |
| 11 | 0.548 | savestates / z80_snap[95] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[0][7]~DUPLICATE | 0.087 | 0.635 |
| 12 | 0.554 | savestates / z80_snap[95] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[4][7] | 0.083 | 0.637 |
| 13 | 0.56 | savestates / z80_snap[173] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[5][5] | 0.082 | 0.642 |
| 14 | 0.56 | savestates / z80_snap[93] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[0][5]~DUPLICATE | 0.087 | 0.647 |
| 15 | 0.562 | savestates / z80_snap[93] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[4][5] | 0.083 | 0.645 |
| 16 | 0.565 | savestates / z80_snap[93] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[0][5] | 0.08 | 0.645 |
| 17 | 0.566 | savestates / z80_snap[106] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[5][2] | 0.083 | 0.649 |
| 18 | 0.566 | savestates / z80_snap[93] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[4][5]~DUPLICATE | 0.077 | 0.643 |
| 19 | 0.567 | savestates / z80_snap[184] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[2][0] | 0.084 | 0.651 |
| 20 | 0.569 | savestates / z80_snap[107] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[1][3] | 0.087 | 0.656 |
| 21 | 0.57 | savestates / z80_snap[82] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsL[0][2] | 0.089 | 0.659 |
| 22 | 0.57 | savestates / z80_snap[106] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[5][2]~DUPLICATE | 0.077 | 0.647 |
| 23 | 0.571 | savestates / z80_snap[184] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[2][0]~DUPLICATE | 0.081 | 0.652 |
| 24 | 0.581 | savestates / z80_snap[87] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsL[0][7] | 0.081 | 0.662 |
| 25 | 0.581 | savestates / z80_snap[90] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[0][2] | 0.085 | 0.666 |
| 26 | 0.586 | savestates / z80_snap[82] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsL[4][2] | 0.087 | 0.673 |
| 27 | 0.591 | savestates / z80_snap[90] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[4][2] | 0.079 | 0.67 |
| 28 | 0.595 | savestates / z80_snap[89] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[0][1] | 0.079 | 0.674 |
| 29 | 0.595 | savestates / z80_snap[110] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[1][6]~DUPLICATE | 0.09 | 0.685 |
| 30 | 0.595 | savestates / z80_snap[111] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[1][7] | 0.093 | 0.688 |
| 31 | 0.596 | savestates / z80_snap[87] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsL[4][7]~DUPLICATE | 0.08 | 0.676 |
| 32 | 0.599 | savestates / z80_snap[110] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[1][6] | 0.087 | 0.686 |
| 33 | 0.6 | savestates / z80_snap[87] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsL[4][7] | 0.077 | 0.677 |
| 34 | 0.6 | savestates / z80_snap[111] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[1][7]~DUPLICATE | 0.086 | 0.686 |
| 35 | 0.601 | savestates / z80_snap[172] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[1][4]~DUPLICATE | 0.09 | 0.691 |
| 36 | 0.605 | savestates / z80_snap[172] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[1][4] | 0.087 | 0.692 |
| 37 | 0.607 | savestates / z80_snap[104] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[5][0] | 0.092 | 0.699 |
| 38 | 0.622 | savestates / z80_snap[28] | T80s:z80_inst / T80:u0 / Fp[4]~DUPLICATE | 0.109 | 0.731 |
| 39 | 0.625 | savestates / z80_snap[62] | T80s:z80_inst / T80:u0 / SP[14] | 0.496 | 1.121 |
| 40 | 0.627 | savestates / z80_snap[28] | T80s:z80_inst / T80:u0 / Fp[4] | 0.106 | 0.733 |
| 41 | 0.628 | savestates / z80_snap[18] | T80s:z80_inst / T80:u0 / Ap[2] | 0.097 | 0.725 |
| 42 | 0.628 | savestates / z80_snap[217] | T80s:z80_inst / T80:u0 / WZ[5] | 0.482 | 1.11 |
| 43 | 0.629 | savestates / z80_snap[173] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[1][5] | 0.085 | 0.714 |
| 44 | 0.631 | savestates / z80_snap[152] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[4][0] | 0.087 | 0.718 |
| 45 | 0.639 | savestates / z80_snap[218] | T80s:z80_inst / T80:u0 / WZ[6] | 0.491 | 1.13 |
| 46 | 0.644 | savestates / z80_snap[209] | T80s:z80_inst / T80:u0 / IStatus[1] | 0.476 | 1.12 |
| 47 | 0.646 | savestates / z80_snap[116] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsL[6][4] | 0.081 | 0.727 |
| 48 | 0.646 | savestates / z80_snap[122] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[2][2] | 0.086 | 0.732 |
| 49 | 0.649 | savestates / z80_snap[185] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[2][1] | 0.088 | 0.737 |
| 50 | 0.662 | savestates / z80_snap[125] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[2][5]~DUPLICATE | 0.091 | 0.753 |

## crc

### baseline

| Rank | Slack ns | From | To | Skew ns | Data ns |
| --- | --- | --- | --- | --- | --- |
| 1 | 0.895 | mapper_detect:mapper_detect_inst / rom_crc32[17] | T80s:z80_inst / T80:u0 / IR[3] | -0.46 | 16.941 |
| 2 | 1.012 | mapper_detect:mapper_detect_inst / rom_crc32[17] | T80s:z80_inst / T80:u0 / IR[6] | -0.458 | 16.826 |
| 3 | 1.076 | mapper_detect:mapper_detect_inst / rom_crc32[17] | T80s:z80_inst / T80:u0 / IR[4] | -0.464 | 16.756 |
| 4 | 1.081 | mapper_detect:mapper_detect_inst / rom_crc32[17] | T80s:z80_inst / T80:u0 / IR[4]~DUPLICATE | -0.461 | 16.754 |
| 5 | 1.222 | mapper_detect:mapper_detect_inst / rom_crc32[17] | T80s:z80_inst / T80:u0 / IR[5] | -0.472 | 16.602 |
| 6 | 1.227 | mapper_detect:mapper_detect_inst / rom_crc32[17] | T80s:z80_inst / T80:u0 / IR[5]~DUPLICATE | -0.469 | 16.6 |
| 7 | 1.329 | mapper_detect:mapper_detect_inst / rom_crc32[17] | T80s:z80_inst / T80:u0 / IR[0] | -0.471 | 16.496 |
| 8 | 1.44 | mapper_detect:mapper_detect_inst / rom_crc32[17] | T80s:z80_inst / T80:u0 / IR[2] | -0.467 | 16.389 |
| 9 | 1.602 | mapper_detect:mapper_detect_inst / rom_crc32[17] | T80s:z80_inst / T80:u0 / IR[7] | -0.467 | 16.227 |
| 10 | 1.652 | mapper_detect:mapper_detect_inst / rom_crc32[17] | T80s:z80_inst / T80:u0 / IR[1]_OTERM557 | -0.45 | 16.194 |
| 11 | 2.265 | mapper_detect:mapper_detect_inst / rom_crc32[17] | T80s:z80_inst / T80:u0 / IR[1]_OTERM565 | -0.45 | 15.581 |
| 12 | 2.845 | mapper_detect:mapper_detect_inst / rom_crc32[17] | T80s:z80_inst / T80:u0 / IR[1]_OTERM561 | -0.45 | 15.001 |

### candidate

| Rank | Slack ns | From | To | Skew ns | Data ns |
| --- | --- | --- | --- | --- | --- |
| 1 | 1.652 | mapper_detect:mapper_detect_inst / rom_crc32[2]~DUPLICATE | T80s:z80_inst / T80:u0 / IR[5] | -0.505 | 16.139 |
| 2 | 1.657 | mapper_detect:mapper_detect_inst / rom_crc32[2]~DUPLICATE | T80s:z80_inst / T80:u0 / IR[5]~DUPLICATE | -0.502 | 16.137 |
| 3 | 1.84 | mapper_detect:mapper_detect_inst / rom_crc32[2]~DUPLICATE | T80s:z80_inst / T80:u0 / IR[3]~DUPLICATE | -0.517 | 15.939 |
| 4 | 1.845 | mapper_detect:mapper_detect_inst / rom_crc32[2]~DUPLICATE | T80s:z80_inst / T80:u0 / IR[3] | -0.514 | 15.937 |
| 5 | 2 | mapper_detect:mapper_detect_inst / rom_crc32[2]~DUPLICATE | T80s:z80_inst / T80:u0 / IR[4] | -0.505 | 15.791 |
| 6 | 2.344 | mapper_detect:mapper_detect_inst / rom_crc32[2]~DUPLICATE | T80s:z80_inst / T80:u0 / IR[2]_OTERM563 | -0.505 | 15.447 |
| 7 | 2.363 | mapper_detect:mapper_detect_inst / rom_crc32[2]~DUPLICATE | T80s:z80_inst / T80:u0 / IR[6]_OTERM569 | -0.508 | 15.425 |
| 8 | 2.375 | mapper_detect:mapper_detect_inst / rom_crc32[2]~DUPLICATE | T80s:z80_inst / T80:u0 / IR[1]_OTERM581 | -0.477 | 15.444 |
| 9 | 2.389 | mapper_detect:mapper_detect_inst / rom_crc32[2]~DUPLICATE | T80s:z80_inst / T80:u0 / IR[7]_OTERM589 | -0.502 | 15.405 |
| 10 | 2.453 | mapper_detect:mapper_detect_inst / rom_crc32[2]~DUPLICATE | T80s:z80_inst / T80:u0 / IR[1]_OTERM579 | -0.49 | 15.353 |
| 11 | 2.533 | mapper_detect:mapper_detect_inst / rom_crc32[2]~DUPLICATE | T80s:z80_inst / T80:u0 / IR[0]_OTERM596 | -0.505 | 15.258 |
| 12 | 2.541 | mapper_detect:mapper_detect_inst / rom_crc32[2]~DUPLICATE | T80s:z80_inst / T80:u0 / IR[7]_OTERM591 | -0.505 | 15.25 |
| 13 | 2.56 | mapper_detect:mapper_detect_inst / rom_crc32[2]~DUPLICATE | T80s:z80_inst / T80:u0 / IR[2]_OTERM561 | -0.503 | 15.233 |
| 14 | 2.614 | mapper_detect:mapper_detect_inst / rom_crc32[2]~DUPLICATE | T80s:z80_inst / T80:u0 / IR[6]_OTERM567 | -0.506 | 15.176 |
| 15 | 2.773 | mapper_detect:mapper_detect_inst / rom_crc32[2]~DUPLICATE | T80s:z80_inst / T80:u0 / IR[0]_OTERM594 | -0.504 | 15.019 |
| 16 | 2.827 | mapper_detect:mapper_detect_inst / rom_crc32[2]~DUPLICATE | T80s:z80_inst / T80:u0 / IR[2]_OTERM557 | -0.502 | 14.967 |
| 17 | 3.097 | mapper_detect:mapper_detect_inst / rom_crc32[2]~DUPLICATE | T80s:z80_inst / T80:u0 / IR[1]_OTERM575 | -0.482 | 14.717 |

## sdram

### baseline

| Rank | Slack ns | From | To | Skew ns | Data ns |
| --- | --- | --- | --- | --- | --- |
| 1 | 1.326 | emu:emu / sdram:ram / sd_dat[2] | T80s:z80_inst / T80:u0 / IR[3] | -1.73 | 15.24 |
| 2 | 1.337 | emu:emu / sdram:ram / sd_dat[5] | T80s:z80_inst / T80:u0 / IR[6] | -1.773 | 15.186 |
| 3 | 1.458 | emu:emu / sdram:ram / sd_dat[5] | T80s:z80_inst / T80:u0 / IR[2] | -1.782 | 15.056 |
| 4 | 1.507 | emu:emu / sdram:ram / sd_dat[2] | T80s:z80_inst / T80:u0 / IR[4] | -1.734 | 15.055 |
| 5 | 1.512 | emu:emu / sdram:ram / sd_dat[2] | T80s:z80_inst / T80:u0 / IR[4]~DUPLICATE | -1.731 | 15.053 |
| 6 | 1.547 | emu:emu / sdram:ram / sd_dat[5] | T80s:z80_inst / T80:u0 / IR[5] | -1.787 | 14.962 |
| 7 | 1.552 | emu:emu / sdram:ram / sd_dat[5] | T80s:z80_inst / T80:u0 / IR[5]~DUPLICATE | -1.784 | 14.96 |
| 8 | 1.566 | emu:emu / sdram:ram / sd_dat[5] | T80s:z80_inst / T80:u0 / IR[0] | -1.786 | 14.944 |
| 9 | 1.595 | emu:emu / sdram:ram / sd_dat[5] | T80s:z80_inst / T80:u0 / IR[7] | -1.782 | 14.919 |
| 10 | 1.875 | emu:emu / sdram:ram / sd_dat[5] | T80s:z80_inst / T80:u0 / IR[1]_OTERM557 | -1.765 | 14.656 |
| 11 | 2.657 | emu:emu / sdram:ram / sd_dat[1] | T80s:z80_inst / T80:u0 / IR[1]_OTERM565 | -1.774 | 13.865 |
| 12 | 2.851 | emu:emu / sdram:ram / sd_dat[5] | T80s:z80_inst / T80:u0 / IR[1]_OTERM561 | -1.765 | 13.68 |

### candidate

| Rank | Slack ns | From | To | Skew ns | Data ns |
| --- | --- | --- | --- | --- | --- |
| 1 | 0.817 | emu:emu / sdram:ram / sd_dat[8] | T80s:z80_inst / T80:u0 / IR[5] | -1.547 | 15.932 |
| 2 | 0.822 | emu:emu / sdram:ram / sd_dat[8] | T80s:z80_inst / T80:u0 / IR[5]~DUPLICATE | -1.544 | 15.93 |
| 3 | 1.188 | emu:emu / sdram:ram / sd_dat[8] | T80s:z80_inst / T80:u0 / IR[3]~DUPLICATE | -1.559 | 15.549 |
| 4 | 1.193 | emu:emu / sdram:ram / sd_dat[8] | T80s:z80_inst / T80:u0 / IR[3] | -1.556 | 15.547 |
| 5 | 1.376 | emu:emu / sdram:ram / sd_dat[8] | T80s:z80_inst / T80:u0 / IR[4] | -1.547 | 15.373 |
| 6 | 1.55 | emu:emu / sdram:ram / sd_dat[8] | T80s:z80_inst / T80:u0 / IR[1]_OTERM581 | -1.519 | 15.227 |
| 7 | 1.634 | emu:emu / sdram:ram / sd_dat[8] | T80s:z80_inst / T80:u0 / IR[7]_OTERM589 | -1.544 | 15.118 |
| 8 | 1.655 | emu:emu / sdram:ram / sd_dat[8] | T80s:z80_inst / T80:u0 / IR[2]_OTERM561 | -1.545 | 15.096 |
| 9 | 1.699 | emu:emu / sdram:ram / sd_dat[8] | T80s:z80_inst / T80:u0 / IR[6]_OTERM569 | -1.55 | 15.047 |
| 10 | 1.801 | emu:emu / sdram:ram / sd_dat[8] | T80s:z80_inst / T80:u0 / IR[1]_OTERM579 | -1.532 | 14.963 |
| 11 | 1.808 | emu:emu / sdram:ram / sd_dat[8] | T80s:z80_inst / T80:u0 / IR[6]_OTERM567 | -1.548 | 14.94 |
| 12 | 1.823 | emu:emu / sdram:ram / sd_dat[8] | T80s:z80_inst / T80:u0 / IR[0]_OTERM594 | -1.546 | 14.927 |
| 13 | 1.877 | emu:emu / sdram:ram / sd_dat[8] | T80s:z80_inst / T80:u0 / IR[7]_OTERM591 | -1.547 | 14.872 |
| 14 | 1.894 | emu:emu / sdram:ram / sd_dat[8] | T80s:z80_inst / T80:u0 / IR[0]_OTERM596 | -1.547 | 14.855 |
| 15 | 1.899 | emu:emu / sdram:ram / sd_dat[8] | T80s:z80_inst / T80:u0 / IR[2]_OTERM563 | -1.547 | 14.85 |
| 16 | 2.163 | emu:emu / sdram:ram / sd_dat[8] | T80s:z80_inst / T80:u0 / IR[2]_OTERM557 | -1.544 | 14.589 |
| 17 | 2.433 | emu:emu / sdram:ram / sd_dat[8] | T80s:z80_inst / T80:u0 / IR[1]_OTERM575 | -1.524 | 14.339 |

## hcnt

### baseline

| Rank | Slack ns | From | To | Skew ns | Data ns |
| --- | --- | --- | --- | --- | --- |
| 1 | 0.478 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[2]~DUPLICATE | -0.685 | 5.369 |
| 2 | 0.478 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[8]~DUPLICATE | -0.685 | 5.369 |
| 3 | 0.478 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[6] | -0.685 | 5.369 |
| 4 | 0.478 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[0]~DUPLICATE | -0.685 | 5.369 |
| 5 | 0.478 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[3]~DUPLICATE | -0.687 | 5.367 |
| 6 | 0.478 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[1] | -0.687 | 5.367 |
| 7 | 0.478 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[9] | -0.687 | 5.367 |
| 8 | 0.478 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[5] | -0.687 | 5.367 |
| 9 | 0.482 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[3] | -0.681 | 5.369 |
| 10 | 0.482 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[9]~DUPLICATE | -0.681 | 5.369 |
| 11 | 0.482 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[5]~DUPLICATE | -0.681 | 5.369 |
| 12 | 0.482 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[1]~DUPLICATE | -0.681 | 5.369 |
| 13 | 0.483 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[0] | -0.682 | 5.367 |
| 14 | 0.483 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[2] | -0.682 | 5.367 |
| 15 | 0.483 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[8] | -0.682 | 5.367 |
| 16 | 0.483 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[6]~DUPLICATE | -0.682 | 5.367 |
| 17 | 0.487 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[7] | -0.687 | 5.358 |
| 18 | 0.492 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[4] | -0.682 | 5.358 |
| 19 | 0.932 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[10] | -0.684 | 4.916 |
| 20 | 0.932 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[19] | -0.686 | 4.914 |
| 21 | 0.932 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[21]~DUPLICATE | -0.686 | 4.914 |
| 22 | 0.932 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[17] | -0.686 | 4.914 |
| 23 | 0.932 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[22] | -0.684 | 4.916 |
| 24 | 0.932 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[13]~DUPLICATE | -0.686 | 4.914 |
| 25 | 0.936 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[13] | -0.68 | 4.916 |
| 26 | 0.936 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[19]~DUPLICATE | -0.68 | 4.916 |
| 27 | 0.936 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[17]~DUPLICATE | -0.68 | 4.916 |
| 28 | 0.936 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[21] | -0.68 | 4.916 |
| 29 | 0.937 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[10]~DUPLICATE | -0.681 | 4.914 |
| 30 | 0.937 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[22]~DUPLICATE | -0.681 | 4.914 |
| 31 | 0.941 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[16] | -0.684 | 4.907 |
| 32 | 0.941 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[15] | -0.686 | 4.905 |
| 33 | 0.941 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[14] | -0.684 | 4.907 |
| 34 | 0.941 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[23] | -0.686 | 4.905 |
| 35 | 0.945 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[11] | -0.68 | 4.907 |
| 36 | 0.946 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[12] | -0.681 | 4.905 |
| 37 | 0.946 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[18] | -0.681 | 4.905 |
| 38 | 0.946 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[20] | -0.681 | 4.905 |

### candidate

| Rank | Slack ns | From | To | Skew ns | Data ns |
| --- | --- | --- | --- | --- | --- |
| 1 | -0.714 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[8]~DUPLICATE | -0.692 | 6.554 |
| 2 | -0.714 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[2]~DUPLICATE | -0.692 | 6.554 |
| 3 | -0.714 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[1] | -0.694 | 6.552 |
| 4 | -0.714 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[3]~DUPLICATE | -0.694 | 6.552 |
| 5 | -0.714 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[5]~DUPLICATE | -0.694 | 6.552 |
| 6 | -0.714 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[4] | -0.692 | 6.554 |
| 7 | -0.709 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[1]~DUPLICATE | -0.687 | 6.554 |
| 8 | -0.709 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[5] | -0.687 | 6.554 |
| 9 | -0.709 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[3] | -0.687 | 6.554 |
| 10 | -0.708 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[4]~DUPLICATE | -0.688 | 6.552 |
| 11 | -0.708 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[2] | -0.688 | 6.552 |
| 12 | -0.708 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[8] | -0.688 | 6.552 |
| 13 | -0.705 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[9] | -0.694 | 6.543 |
| 14 | -0.705 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[7] | -0.694 | 6.543 |
| 15 | -0.699 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[0] | -0.688 | 6.543 |
| 16 | -0.699 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[6] | -0.688 | 6.543 |
| 17 | 0.355 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[20]~DUPLICATE | -0.699 | 5.478 |
| 18 | 0.355 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[10]~DUPLICATE | -0.699 | 5.478 |
| 19 | 0.355 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[18] | -0.699 | 5.478 |
| 20 | 0.356 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[21]~DUPLICATE | -0.7 | 5.476 |
| 21 | 0.356 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[13]~DUPLICATE | -0.7 | 5.476 |
| 22 | 0.356 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[15]~DUPLICATE | -0.7 | 5.476 |
| 23 | 0.356 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[17]~DUPLICATE | -0.7 | 5.476 |
| 24 | 0.36 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[18]~DUPLICATE | -0.696 | 5.476 |
| 25 | 0.36 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[17] | -0.694 | 5.478 |
| 26 | 0.36 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[15] | -0.694 | 5.478 |
| 27 | 0.36 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[20] | -0.696 | 5.476 |
| 28 | 0.36 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[10] | -0.696 | 5.476 |
| 29 | 0.36 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[13] | -0.694 | 5.478 |
| 30 | 0.36 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[21] | -0.694 | 5.478 |
| 31 | 0.364 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[12] | -0.699 | 5.469 |
| 32 | 0.365 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[19] | -0.7 | 5.467 |
| 33 | 0.365 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[11] | -0.7 | 5.467 |
| 34 | 0.365 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[23] | -0.7 | 5.467 |
| 35 | 0.369 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[22] | -0.696 | 5.467 |
| 36 | 0.369 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[16] | -0.696 | 5.467 |
| 37 | 0.369 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[14] | -0.696 | 5.467 |

## width

### baseline

| Rank | Slack ns | From | To | Skew ns | Data ns |
| --- | --- | --- | --- | --- | --- |
| 1 | 0.104 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[19] | -0.675 | 5.753 |
| 2 | 0.104 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[13] | -0.675 | 5.753 |
| 3 | 0.104 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[12] | -0.675 | 5.753 |
| 4 | 0.108 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[11] | -0.671 | 5.753 |
| 5 | 0.108 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[20] | -0.671 | 5.753 |
| 6 | 0.108 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[18] | -0.671 | 5.753 |
| 7 | 0.251 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[10] | -0.674 | 5.607 |
| 8 | 0.345 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[14] | -0.677 | 5.51 |
| 9 | 0.349 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[16] | -0.673 | 5.51 |
| 10 | 0.349 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[15] | -0.673 | 5.51 |
| 11 | 0.401 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[8] | -0.674 | 5.457 |
| 12 | 0.405 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[5] | -0.67 | 5.457 |
| 13 | 0.405 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[9] | -0.67 | 5.457 |
| 14 | 0.405 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[21] | -0.67 | 5.457 |
| 15 | 0.41 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[17] | -0.666 | 5.456 |
| 16 | 0.49 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[7] | -0.682 | 5.36 |
| 17 | 0.633 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[2] | -0.677 | 5.222 |
| 18 | 0.637 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[3] | -0.673 | 5.222 |
| 19 | 0.637 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[1] | -0.673 | 5.222 |
| 20 | 0.637 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[4] | -0.673 | 5.222 |
| 21 | 0.637 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[6] | -0.673 | 5.222 |
| 22 | 0.637 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[0] | -0.673 | 5.222 |

### candidate

| Rank | Slack ns | From | To | Skew ns | Data ns |
| --- | --- | --- | --- | --- | --- |
| 1 | -0.15 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[21] | -0.683 | 5.999 |
| 2 | -0.146 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[20] | -0.679 | 5.999 |
| 3 | -0.112 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[15] | -0.682 | 5.962 |
| 4 | -0.112 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[13] | -0.682 | 5.962 |
| 5 | -0.108 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[17] | -0.678 | 5.962 |
| 6 | -0.108 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[19] | -0.678 | 5.962 |
| 7 | -0.108 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[18] | -0.678 | 5.962 |
| 8 | 0.018 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[9] | -0.707 | 5.807 |
| 9 | 0.077 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[3] | -0.715 | 5.74 |
| 10 | 0.081 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[0] | -0.711 | 5.74 |
| 11 | 0.379 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[5] | -0.709 | 5.444 |
| 12 | 0.379 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[2] | -0.709 | 5.444 |
| 13 | 0.379 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[14] | -0.709 | 5.444 |
| 14 | 0.379 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[12] | -0.709 | 5.444 |
| 15 | 0.379 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[11] | -0.709 | 5.444 |
| 16 | 0.383 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[7] | -0.705 | 5.444 |
| 17 | 0.383 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[6] | -0.705 | 5.444 |
| 18 | 0.383 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[4] | -0.705 | 5.444 |
| 19 | 0.383 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[1] | -0.705 | 5.444 |
| 20 | 0.383 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[16] | -0.705 | 5.444 |
| 21 | 0.383 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[10] | -0.705 | 5.444 |
| 22 | 0.383 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[8] | -0.705 | 5.444 |

## dir

### baseline

| Rank | Slack ns | From | To | Skew ns | Data ns |
| --- | --- | --- | --- | --- | --- |
| 1 | 13.249 | savestates / z80_dir[8] | T80s:z80_inst / T80:u0 / F[0] | -0.55 | 4.497 |
| 2 | 13.397 | savestates / z80_dir[9] | T80s:z80_inst / T80:u0 / F[1] | -0.547 | 4.352 |
| 3 | 13.564 | savestates / z80_dir[4] | T80s:z80_inst / T80:u0 / ACC[4] | -0.496 | 4.236 |
| 4 | 13.725 | savestates / z80_dir[10] | T80s:z80_inst / T80:u0 / F[2] | -0.524 | 4.047 |
| 5 | 13.817 | savestates / z80_dir[116] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsL[2][4] | -0.452 | 4.027 |
| 6 | 13.998 | savestates / z80_dir[12] | T80s:z80_inst / T80:u0 / F[4] | -0.15 | 4.148 |
| 7 | 14.214 | savestates / z80_dir[116] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsL[6][4] | -0.462 | 3.62 |
| 8 | 14.272 | savestates / z80_dir[25] | T80s:z80_inst / T80:u0 / Fp[1] | -0.102 | 3.922 |
| 9 | 14.301 | savestates / z80_dir[151] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsL[0][7] | -0.442 | 3.553 |
| 10 | 14.303 | savestates / z80_dir[151] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsL[4][7] | -0.448 | 3.545 |
| 11 | 14.383 | savestates / z80_dir[229] | T80s:z80_inst / T80:u0 / Halt_FF | -0.442 | 3.471 |
| 12 | 14.392 | savestates / z80_dir[119] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsL[6][7] | -0.441 | 3.463 |
| 13 | 14.55 | savestates / z80_dir[101] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsL[5][5] | -0.448 | 3.298 |
| 14 | 14.585 | savestates / z80_dir[119] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsL[2][7] | -0.445 | 3.266 |
| 15 | 14.592 | savestates / z80_dir[101] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsL[1][5] | -0.443 | 3.261 |
| 16 | 14.601 | savestates / z80_dir[41] | T80s:z80_inst / T80:u0 / R[1] | -0.464 | 3.231 |
| 17 | 14.637 | savestates / z80_dir[26] | T80s:z80_inst / T80:u0 / Fp[2] | -0.476 | 3.183 |
| 18 | 14.675 | savestates / z80_dir[72] | T80s:z80_inst / T80:u0 / A[8]~DUPLICATE | -0.477 | 3.144 |
| 19 | 14.68 | savestates / z80_dir[72] | T80s:z80_inst / T80:u0 / A[8] | -0.47 | 3.146 |
| 20 | 14.778 | savestates / z80_dir[112] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsL[6][0]~DUPLICATE | -0.46 | 3.058 |
| 21 | 14.783 | savestates / z80_dir[112] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsL[6][0] | -0.457 | 3.056 |
| 22 | 14.873 | savestates / z80_dir[80] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsL[4][0]~DUPLICATE | -0.464 | 2.959 |
| 23 | 14.876 | savestates / z80_dir[80] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsL[4][0] | -0.459 | 2.961 |
| 24 | 14.877 | savestates / z80_dir[80] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsL[0][0] | -0.46 | 2.959 |
| 25 | 14.911 | savestates / z80_dir[129] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsL[3][1] | -0.491 | 2.894 |
| 26 | 14.963 | savestates / z80_dir[112] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsL[2][0] | -0.462 | 2.871 |
| 27 | 14.986 | savestates / z80_dir[88] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[0][0] | -0.481 | 2.829 |
| 28 | 14.998 | savestates / z80_dir[120] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[6][0] | -0.107 | 3.191 |
| 29 | 15.008 | savestates / z80_dir[120] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[2][0] | -0.107 | 3.181 |
| 30 | 15.032 | savestates / z80_dir[14] | T80s:z80_inst / T80:u0 / F[6] | -0.484 | 2.78 |
| 31 | 15.037 | savestates / z80_dir[81] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsL[4][1] | -0.15 | 3.109 |
| 32 | 15.042 | savestates / z80_dir[81] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsL[4][1]~DUPLICATE | -0.147 | 3.107 |
| 33 | 15.066 | savestates / z80_dir[81] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsL[0][1] | -0.145 | 3.085 |
| 34 | 15.075 | savestates / z80_dir[188] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[6][4] | -0.436 | 2.785 |
| 35 | 15.079 | savestates / z80_dir[188] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[2][4] | -0.433 | 2.784 |
| 36 | 15.104 | savestates / z80_dir[167] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsL[5][7] | -0.462 | 2.73 |
| 37 | 15.108 | savestates / z80_dir[167] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsL[1][7] | -0.457 | 2.731 |
| 38 | 15.121 | savestates / z80_dir[228] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsL[4][2] | -0.482 | 2.693 |
| 39 | 15.122 | savestates / z80_dir[228] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsL[0][2] | -0.477 | 2.697 |
| 40 | 15.126 | savestates / z80_dir[228] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsL[4][2]~DUPLICATE | -0.479 | 2.691 |
| 41 | 15.128 | savestates / z80_dir[228] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsL[0][2]~DUPLICATE | -0.473 | 2.695 |
| 42 | 15.13 | savestates / z80_dir[208] | T80s:z80_inst / T80:u0 / IStatus[0] | -0.139 | 3.027 |
| 43 | 15.134 | savestates / z80_dir[228] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsL[0][3] | -0.479 | 2.683 |
| 44 | 15.151 | savestates / z80_dir[2] | T80s:z80_inst / T80:u0 / ACC[2] | -0.131 | 3.014 |
| 45 | 15.152 | savestates / z80_dir[228] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsL[4][3] | -0.483 | 2.661 |
| 46 | 15.154 | savestates / z80_dir[228] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsL[1][3] | -0.487 | 2.655 |
| 47 | 15.166 | savestates / z80_dir[228] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsL[1][2] | -0.482 | 2.648 |
| 48 | 15.167 | savestates / z80_dir[161] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsL[1][1] | -0.452 | 2.677 |
| 49 | 15.171 | savestates / z80_dir[161] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsL[5][1] | -0.463 | 2.662 |
| 50 | 15.199 | savestates / z80_dir[43] | T80s:z80_inst / T80:u0 / R[3] | -0.465 | 2.632 |

## alias

### baseline

| Rank | Slack ns | From | To | Skew ns | Data ns |
| --- | --- | --- | --- | --- | --- |


### candidate

| Rank | Slack ns | From | To | Skew ns | Data ns |
| --- | --- | --- | --- | --- | --- |
| 1 | 13.974 | savestates / z80_snap[73] | T80s:z80_inst / T80:u0 / PC[9] | -0.494 | 3.828 |
| 2 | 14.222 | savestates / z80_snap[56] | T80s:z80_inst / T80:u0 / SP[8] | -0.49 | 3.584 |
| 3 | 14.272 | savestates / z80_snap[14] | T80s:z80_inst / T80:u0 / F[6] | -0.482 | 3.542 |
| 4 | 14.277 | savestates / z80_snap[14] | T80s:z80_inst / T80:u0 / F[6]~DUPLICATE | -0.479 | 3.54 |
| 5 | 14.336 | savestates / z80_snap[63] | T80s:z80_inst / T80:u0 / SP[15]~DUPLICATE | -0.485 | 3.475 |
| 6 | 14.342 | savestates / z80_snap[63] | T80s:z80_inst / T80:u0 / SP[15] | -0.481 | 3.473 |
| 7 | 14.348 | savestates / z80_snap[12] | T80s:z80_inst / T80:u0 / F[4] | -0.134 | 3.814 |
| 8 | 14.376 | savestates / z80_snap[51] | T80s:z80_inst / T80:u0 / SP[3] | -0.475 | 3.445 |
| 9 | 14.394 | savestates / z80_snap[58] | T80s:z80_inst / T80:u0 / SP[10]~DUPLICATE | -0.503 | 3.399 |
| 10 | 14.4 | savestates / z80_snap[58] | T80s:z80_inst / T80:u0 / SP[10] | -0.499 | 3.397 |
| 11 | 14.419 | savestates / z80_snap[61] | T80s:z80_inst / T80:u0 / SP[13] | -0.48 | 3.397 |
| 12 | 14.429 | savestates / z80_snap[53] | T80s:z80_inst / T80:u0 / SP[5] | -0.48 | 3.387 |
| 13 | 14.453 | savestates / z80_snap[26] | T80s:z80_inst / T80:u0 / Fp[2] | -0.464 | 3.379 |
| 14 | 14.506 | savestates / z80_snap[52] | T80s:z80_inst / T80:u0 / SP[4] | -0.467 | 3.323 |
| 15 | 14.531 | savestates / z80_snap[10] | T80s:z80_inst / T80:u0 / F[2] | -0.483 | 3.282 |
| 16 | 14.536 | savestates / z80_snap[10] | T80s:z80_inst / T80:u0 / F[2]~DUPLICATE | -0.48 | 3.28 |
| 17 | 14.539 | savestates / z80_snap[78] | T80s:z80_inst / T80:u0 / PC[14] | -0.49 | 3.267 |
| 18 | 14.596 | savestates / z80_snap[8] | T80s:z80_inst / T80:u0 / F[0] | -0.15 | 3.55 |
| 19 | 14.596 | savestates / z80_snap[9] | T80s:z80_inst / T80:u0 / F[1] | -0.144 | 3.556 |
| 20 | 14.6 | savestates / z80_snap[8] | T80s:z80_inst / T80:u0 / F[0]~DUPLICATE | -0.144 | 3.552 |
| 21 | 14.646 | savestates / z80_snap[24] | T80s:z80_inst / T80:u0 / Fp[0] | -0.475 | 3.175 |
| 22 | 14.648 | savestates / z80_snap[13] | T80s:z80_inst / T80:u0 / F[5] | -0.487 | 3.161 |
| 23 | 14.654 | savestates / z80_snap[13] | T80s:z80_inst / T80:u0 / F[5]~DUPLICATE | -0.484 | 3.158 |
| 24 | 14.742 | savestates / z80_snap[71] | T80s:z80_inst / T80:u0 / PC[7] | -0.475 | 3.079 |
| 25 | 14.784 | savestates / z80_snap[49] | T80s:z80_inst / T80:u0 / SP[1] | -0.475 | 3.037 |
| 26 | 14.796 | savestates / z80_snap[20] | T80s:z80_inst / T80:u0 / Ap[4] | -0.148 | 3.352 |
| 27 | 14.818 | savestates / z80_snap[0] | T80s:z80_inst / T80:u0 / ACC[0]~DUPLICATE | -0.489 | 2.989 |
| 28 | 14.82 | savestates / z80_snap[21] | T80s:z80_inst / T80:u0 / Ap[5] | -0.134 | 3.342 |
| 29 | 14.822 | savestates / z80_snap[0] | T80s:z80_inst / T80:u0 / ACC[0] | -0.483 | 2.991 |
| 30 | 14.826 | savestates / z80_snap[2] | T80s:z80_inst / T80:u0 / ACC[2] | -0.485 | 2.985 |
| 31 | 14.841 | savestates / z80_snap[79] | T80s:z80_inst / T80:u0 / PC[15] | -0.497 | 2.958 |
| 32 | 14.846 | savestates / z80_snap[79] | T80s:z80_inst / T80:u0 / PC[15]~DUPLICATE | -0.494 | 2.956 |
| 33 | 14.858 | savestates / z80_snap[60] | T80s:z80_inst / T80:u0 / SP[12] | -0.476 | 2.962 |
| 34 | 14.858 | savestates / z80_snap[15] | T80s:z80_inst / T80:u0 / F[7] | -0.488 | 2.95 |
| 35 | 14.864 | savestates / z80_snap[15] | T80s:z80_inst / T80:u0 / F[7]~DUPLICATE | -0.485 | 2.947 |
| 36 | 14.873 | savestates / z80_snap[65] | T80s:z80_inst / T80:u0 / PC[1] | -0.479 | 2.944 |
| 37 | 14.879 | savestates / z80_snap[65] | T80s:z80_inst / T80:u0 / PC[1]~DUPLICATE | -0.475 | 2.942 |
| 38 | 14.914 | savestates / z80_snap[228] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[2][0]~DUPLICATE | -0.137 | 3.245 |
| 39 | 14.919 | savestates / z80_snap[228] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[2][0] | -0.134 | 3.243 |
| 40 | 15.026 | savestates / z80_snap[11] | T80s:z80_inst / T80:u0 / F[3]~DUPLICATE | -0.469 | 2.801 |
| 41 | 15.028 | savestates / z80_snap[11] | T80s:z80_inst / T80:u0 / F[3] | -0.464 | 2.804 |
| 42 | 15.045 | savestates / z80_snap[55] | T80s:z80_inst / T80:u0 / SP[7] | -0.49 | 2.761 |
| 43 | 15.049 | savestates / z80_snap[59] | T80s:z80_inst / T80:u0 / SP[11] | -0.473 | 2.774 |
| 44 | 15.051 | savestates / z80_snap[55] | T80s:z80_inst / T80:u0 / SP[7]~DUPLICATE | -0.486 | 2.759 |
| 45 | 15.078 | savestates / z80_snap[228] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[6][0] | -0.14 | 3.078 |
| 46 | 15.08 | savestates / z80_snap[228] | T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[2][7] | -0.138 | 3.078 |
| 47 | 15.083 | savestates / z80_snap[27] | T80s:z80_inst / T80:u0 / Fp[3] | -0.484 | 2.729 |
| 48 | 15.089 | savestates / z80_snap[27] | T80s:z80_inst / T80:u0 / Fp[3]~DUPLICATE | -0.481 | 2.726 |
| 49 | 15.136 | savestates / z80_snap[69] | T80s:z80_inst / T80:u0 / PC[5] | -0.475 | 2.685 |
| 50 | 15.161 | savestates / z80_snap[76] | T80s:z80_inst / T80:u0 / PC[12] | -0.509 | 2.626 |

## snapdir_setup

### baseline

| Rank | Slack ns | From | To | Skew ns | Data ns |
| --- | --- | --- | --- | --- | --- |
| 1 | 13.458 | savestates / z80_snap[16] | savestates / z80_dir[16] | -0.476 | 4.362 |
| 2 | 13.499 | savestates / z80_snap[159] | savestates / z80_dir[159] | -0.484 | 4.313 |
| 3 | 13.728 | savestates / z80_snap[114] | savestates / z80_dir[114] | -0.471 | 4.097 |
| 4 | 13.874 | savestates / z80_snap[10] | savestates / z80_dir[10] | -0.459 | 3.963 |
| 5 | 14.026 | savestates / z80_snap[86] | savestates / z80_dir[86] | -0.463 | 3.807 |
| 6 | 14.232 | savestates / z80_snap[221] | savestates / z80_dir[221] | -0.472 | 3.592 |
| 7 | 14.239 | savestates / z80_snap[183] | savestates / z80_dir[183] | -0.499 | 3.558 |
| 8 | 14.332 | savestates / z80_snap[182] | savestates / z80_dir[182] | -0.451 | 3.513 |
| 9 | 14.417 | savestates / z80_snap[187] | savestates / z80_dir[187] | -0.463 | 3.416 |
| 10 | 14.624 | savestates / z80_snap[103] | savestates / z80_dir[103] | -0.56 | 3.112 |
| 11 | 14.637 | savestates / z80_snap[22] | savestates / z80_dir[22] | -0.531 | 3.128 |
| 12 | 14.649 | savestates / z80_snap[90] | savestates / z80_dir[90] | -0.467 | 3.18 |
| 13 | 14.717 | savestates / z80_snap[229] | savestates / z80_dir[229] | -0.499 | 3.08 |
| 14 | 14.795 | savestates / z80_snap[172] | savestates / z80_dir[172] | -0.496 | 3.005 |
| 15 | 14.808 | savestates / z80_snap[51] | savestates / z80_dir[51] | -0.151 | 3.337 |
| 16 | 14.87 | savestates / z80_snap[117] | savestates / z80_dir[117] | -0.483 | 2.943 |
| 17 | 14.893 | savestates / z80_snap[102] | savestates / z80_dir[102] | -0.544 | 2.859 |
| 18 | 14.925 | savestates / z80_snap[180] | savestates / z80_dir[180] | -0.466 | 2.905 |
| 19 | 14.946 | savestates / z80_snap[121] | savestates / z80_dir[121] | -0.473 | 2.877 |
| 20 | 14.975 | savestates / z80_snap[109] | savestates / z80_dir[109] | -0.455 | 2.866 |
| 21 | 15.022 | savestates / z80_snap[47] | savestates / z80_dir[47] | -0.151 | 3.123 |
| 22 | 15.03 | savestates / z80_snap[83] | savestates / z80_dir[83] | -0.477 | 2.789 |
| 23 | 15.052 | savestates / z80_snap[133] | savestates / z80_dir[133] | -0.496 | 2.748 |
| 24 | 15.062 | savestates / z80_snap[147] | savestates / z80_dir[147] | -0.495 | 2.739 |
| 25 | 15.114 | savestates / z80_snap[2] | savestates / z80_dir[2] | -0.498 | 2.684 |
| 26 | 15.128 | savestates / z80_snap[18] | savestates / z80_dir[18] | -0.51 | 2.658 |
| 27 | 15.14 | savestates / z80_snap[189] | savestates / z80_dir[189] | -0.466 | 2.69 |
| 28 | 15.142 | savestates / z80_snap[11] | savestates / z80_dir[11] | -0.502 | 2.652 |
| 29 | 15.195 | savestates / z80_snap[13] | savestates / z80_dir[13] | -0.512 | 2.589 |
| 30 | 15.202 | savestates / z80_snap[35] | savestates / z80_dir[35] | -0.489 | 2.605 |
| 31 | 15.231 | savestates / z80_snap[120] | savestates / z80_dir[120] | -0.439 | 2.626 |
| 32 | 15.231 | savestates / z80_snap[43] | savestates / z80_dir[43] | -0.111 | 2.954 |
| 33 | 15.289 | savestates / z80_snap[9] | savestates / z80_dir[9] | -0.483 | 2.524 |
| 34 | 15.292 | savestates / z80_snap[38] | savestates / z80_dir[38] | -0.478 | 2.526 |
| 35 | 15.32 | savestates / z80_snap[19] | savestates / z80_dir[19] | -0.507 | 2.469 |
| 36 | 15.337 | savestates / z80_snap[8] | savestates / z80_dir[8] | -0.483 | 2.476 |
| 37 | 15.338 | savestates / z80_snap[23] | savestates / z80_dir[23] | -0.495 | 2.463 |
| 38 | 15.344 | savestates / z80_snap[81] | savestates / z80_dir[81] | -0.531 | 2.421 |
| 39 | 15.367 | savestates / z80_snap[210] | savestates / z80_dir[210] | -0.501 | 2.428 |
| 40 | 15.388 | savestates / z80_snap[113] | savestates / z80_dir[113] | -0.449 | 2.459 |
| 41 | 15.411 | savestates / z80_snap[76] | savestates / z80_dir[76] | -0.458 | 2.427 |
| 42 | 15.425 | savestates / z80_snap[85] | savestates / z80_dir[85] | -0.139 | 2.732 |
| 43 | 15.428 | savestates / z80_snap[96] | savestates / z80_dir[96] | -0.166 | 2.702 |
| 44 | 15.431 | savestates / z80_snap[115] | savestates / z80_dir[115] | -0.466 | 2.399 |
| 45 | 15.434 | savestates / z80_snap[171] | savestates / z80_dir[171] | -0.457 | 2.405 |
| 46 | 15.437 | savestates / z80_snap[134] | savestates / z80_dir[134] | -0.508 | 2.351 |
| 47 | 15.455 | savestates / z80_snap[137] | savestates / z80_dir[137] | -0.507 | 2.334 |
| 48 | 15.462 | savestates / z80_snap[177] | savestates / z80_dir[177] | -0.455 | 2.379 |
| 49 | 15.465 | savestates / z80_snap[178] | savestates / z80_dir[178] | -0.472 | 2.359 |
| 50 | 15.485 | savestates / z80_snap[44] | savestates / z80_dir[44] | -0.476 | 2.335 |

## snapdir_hold

### baseline

| Rank | Slack ns | From | To | Skew ns | Data ns |
| --- | --- | --- | --- | --- | --- |
| 1 | 0.466 | savestates / z80_snap[149] | savestates / z80_dir[149] | 0.089 | 0.555 |
| 2 | 0.53 | savestates / z80_snap[220] | savestates / z80_dir[220] | 0.498 | 1.028 |
| 3 | 0.532 | savestates / z80_snap[100] | savestates / z80_dir[100] | 0.083 | 0.615 |
| 4 | 0.548 | savestates / z80_snap[216] | savestates / z80_dir[216] | 0.507 | 1.055 |
| 5 | 0.563 | savestates / z80_snap[201] | savestates / z80_dir[201] | 0.473 | 1.036 |
| 6 | 0.584 | savestates / z80_snap[122] | savestates / z80_dir[122] | 0.085 | 0.669 |
| 7 | 0.6 | savestates / z80_snap[119] | savestates / z80_dir[119] | 0.07 | 0.67 |
| 8 | 0.603 | savestates / z80_snap[25] | savestates / z80_dir[25] | 0.47 | 1.073 |
| 9 | 0.606 | savestates / z80_snap[135] | savestates / z80_dir[135] | 0.497 | 1.103 |
| 10 | 0.636 | savestates / z80_snap[188] | savestates / z80_dir[188] | 0.082 | 0.718 |
| 11 | 0.639 | savestates / z80_snap[104] | savestates / z80_dir[104] | 0.075 | 0.714 |
| 12 | 0.641 | savestates / z80_snap[175] | savestates / z80_dir[175] | 0.081 | 0.722 |
| 13 | 0.641 | savestates / z80_snap[92] | savestates / z80_dir[92] | 0.085 | 0.726 |
| 14 | 0.642 | savestates / z80_snap[132] | savestates / z80_dir[132] | 0.464 | 1.106 |
| 15 | 0.642 | savestates / z80_snap[20] | savestates / z80_dir[20] | 0.487 | 1.129 |
| 16 | 0.643 | savestates / z80_snap[164] | savestates / z80_dir[164] | 0.078 | 0.721 |
| 17 | 0.652 | savestates / z80_snap[24] | savestates / z80_dir[24] | 0.485 | 1.137 |
| 18 | 0.659 | savestates / z80_snap[214] | savestates / z80_dir[214] | 0.496 | 1.155 |
| 19 | 0.665 | savestates / z80_snap[17] | savestates / z80_dir[17] | 0.485 | 1.15 |
| 20 | 0.693 | savestates / z80_snap[199] | savestates / z80_dir[199] | 0.475 | 1.168 |
| 21 | 0.701 | savestates / z80_snap[63] | savestates / z80_dir[63] | 0.135 | 0.836 |
| 22 | 0.703 | savestates / z80_snap[74] | savestates / z80_dir[74] | 0.484 | 1.187 |
| 23 | 0.706 | savestates / z80_snap[71] | savestates / z80_dir[71] | 0.106 | 0.812 |
| 24 | 0.706 | savestates / z80_snap[224] | savestates / z80_dir[224] | 0.125 | 0.831 |
| 25 | 0.709 | savestates / z80_snap[196] | savestates / z80_dir[196] | 0.493 | 1.202 |
| 26 | 0.716 | savestates / z80_snap[3] | savestates / z80_dir[3] | 0.487 | 1.203 |
| 27 | 0.716 | savestates / z80_snap[141] | savestates / z80_dir[141] | 0.474 | 1.19 |
| 28 | 0.72 | savestates / z80_snap[142] | savestates / z80_dir[142] | 0.468 | 1.188 |
| 29 | 0.723 | savestates / z80_snap[93] | savestates / z80_dir[93] | 0.498 | 1.221 |
| 30 | 0.733 | savestates / z80_snap[152] | savestates / z80_dir[152] | 0.473 | 1.206 |
| 31 | 0.751 | savestates / z80_snap[67] | savestates / z80_dir[67] | 0.11 | 0.861 |
| 32 | 0.764 | savestates / z80_snap[215] | savestates / z80_dir[215] | 0.501 | 1.265 |
| 33 | 0.765 | savestates / z80_snap[91] | savestates / z80_dir[91] | 0.073 | 0.838 |
| 34 | 0.768 | savestates / z80_snap[185] | savestates / z80_dir[185] | 0.066 | 0.834 |
| 35 | 0.775 | savestates / z80_snap[165] | savestates / z80_dir[165] | 0.064 | 0.839 |
| 36 | 0.781 | savestates / z80_snap[75] | savestates / z80_dir[75] | 0.482 | 1.263 |
| 37 | 0.787 | savestates / z80_snap[228] | savestates / z80_dir[228] | 0.097 | 0.884 |
| 38 | 0.789 | savestates / z80_snap[181] | savestates / z80_dir[181] | 0.09 | 0.879 |
| 39 | 0.79 | savestates / z80_snap[14] | savestates / z80_dir[14] | 0.107 | 0.897 |
| 40 | 0.795 | savestates / z80_snap[26] | savestates / z80_dir[26] | 0.114 | 0.909 |
| 41 | 0.798 | savestates / z80_snap[161] | savestates / z80_dir[161] | 0.092 | 0.89 |
| 42 | 0.801 | savestates / z80_snap[168] | savestates / z80_dir[168] | 0.092 | 0.893 |
| 43 | 0.809 | savestates / z80_snap[27] | savestates / z80_dir[27] | 0.477 | 1.286 |
| 44 | 0.817 | savestates / z80_snap[144] | savestates / z80_dir[144] | 0.093 | 0.91 |
| 45 | 0.823 | savestates / z80_snap[39] | savestates / z80_dir[39] | 0.492 | 1.315 |
| 46 | 0.824 | savestates / z80_snap[80] | savestates / z80_dir[80] | 0.093 | 0.917 |
| 47 | 0.829 | savestates / z80_snap[208] | savestates / z80_dir[208] | 0.103 | 0.932 |
| 48 | 0.834 | savestates / z80_snap[65] | savestates / z80_dir[65] | 0.107 | 0.941 |
| 49 | 0.836 | savestates / z80_snap[61] | savestates / z80_dir[61] | 0.092 | 0.928 |
| 50 | 0.836 | savestates / z80_snap[28] | savestates / z80_dir[28] | 0.483 | 1.319 |

