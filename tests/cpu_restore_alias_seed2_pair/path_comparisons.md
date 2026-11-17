# Seed-2 path comparison ledger

Identical -npaths50 -nworst1 group/cone selections; global endpoint lists use1000. One worst path per physical endpoint. Full route details and pin identities are in paths.json and matching text files.

## hdmi_setup

### baseline2

| Rank | Slack ns | From | To | Skew ns | Data ns |
| --- | --- | --- | --- | --- | --- |
| 1 | 0.401 | ascal:ascal / altsyncram:o_line3[0].r[7]__5 / altsyncram_ccn1:auto_generated / ram_block1a0~PORT_B_WRITE_ENABLE_REG | ascal:ascal / o_vpix_outer[1].r[5] | -1.179 | 4.952 |
| 2 | 0.411 | ascal:ascal / o_vcpt_pre3[3] | ascal:ascal / o_vcpt_pre3[5] | -0.107 | 6.014 |
| 3 | 0.416 | ascal:ascal / o_vcpt_pre3[3] | ascal:ascal / o_vcpt_pre3[2] | -0.102 | 6.014 |
| 4 | 0.481 | ascal:ascal / altsyncram:o_line2[0].r[7]__4 / altsyncram_ccn1:auto_generated / ram_block1a0~PORT_B_WRITE_ENABLE_REG | ascal:ascal / o_vpix_inner[0].r[7] | -1.184 | 4.867 |
| 5 | 0.489 | ascal:ascal / o_hacc_next[6] | ascal:ascal / o_hacc_next[11] | -0.116 | 5.927 |
| 6 | 0.493 | ascal:ascal / o_hcpt[3] | ascal:ascal / o_hcpt[6] | -0.115 | 5.924 |
| 7 | 0.493 | ascal:ascal / o_hcpt[3] | ascal:ascal / o_hcpt[11] | -0.115 | 5.924 |
| 8 | 0.493 | ascal:ascal / o_hcpt[3] | ascal:ascal / o_hcpt[5] | -0.115 | 5.924 |
| 9 | 0.493 | ascal:ascal / o_hcpt[3] | ascal:ascal / o_hcpt[4] | -0.115 | 5.924 |
| 10 | 0.493 | ascal:ascal / o_hcpt[3] | ascal:ascal / o_hcpt[0] | -0.115 | 5.924 |
| 11 | 0.498 | ascal:ascal / o_hcpt[3] | ascal:ascal / o_hcpt[7] | -0.11 | 5.924 |
| 12 | 0.498 | ascal:ascal / o_hcpt[3] | ascal:ascal / o_hcpt[10] | -0.11 | 5.924 |
| 13 | 0.498 | ascal:ascal / o_hcpt[3] | ascal:ascal / o_hcpt[9] | -0.11 | 5.924 |
| 14 | 0.498 | ascal:ascal / o_hcpt[3] | ascal:ascal / o_hcpt[8] | -0.11 | 5.924 |
| 15 | 0.498 | ascal:ascal / o_hcpt[3] | ascal:ascal / o_hcpt[3] | -0.11 | 5.924 |
| 16 | 0.498 | ascal:ascal / o_hcpt[3] | ascal:ascal / o_hcpt[2] | -0.11 | 5.924 |
| 17 | 0.498 | ascal:ascal / o_hcpt[3] | ascal:ascal / o_hcpt[1] | -0.11 | 5.924 |
| 18 | 0.505 | ascal:ascal / o_hacc_next[6] | ascal:ascal / o_hacc_next[13] | -0.116 | 5.911 |
| 19 | 0.509 | ascal:ascal / altsyncram:o_line2[0].r[7]__4 / altsyncram_ccn1:auto_generated / ram_block1a0~PORT_B_WRITE_ENABLE_REG | ascal:ascal / o_vpix_outer[1].r[7] | -1.187 | 4.836 |
| 20 | 0.532 | ascal:ascal / altsyncram:o_line0[0].r[7]__2 / altsyncram_ccn1:auto_generated / ram_block1a9~PORT_B_WRITE_ENABLE_REG | ascal:ascal / o_vpix_outer[1].g[5] | -1.18 | 4.82 |
| 21 | 0.549 | ascal:ascal / o_hacc_next[6] | ascal:ascal / o_hacc_next[8] | -0.112 | 5.871 |
| 22 | 0.585 | ascal:ascal / o_vcpt_pre2[8] | ascal:ascal / o_vss | -0.134 | 5.813 |
| 23 | 0.596 | ascal:ascal / o_vacpt[8] | ascal:ascal / o_vpixq_pre[2].r[0] | -0.486 | 5.45 |
| 24 | 0.6 | ascal:ascal / o_vacpt[8] | ascal:ascal / o_vpixq_pre[2].r[4] | -0.482 | 5.45 |
| 25 | 0.604 | ascal:ascal / altsyncram:o_line2[0].r[7]__4 / altsyncram_ccn1:auto_generated / ram_block1a0~PORT_B_WRITE_ENABLE_REG | ascal:ascal / o_vpix_outer[0].r[7] | -1.184 | 4.744 |
| 26 | 0.605 | ascal:ascal / o_hbcpt[0]~DUPLICATE | ascal:ascal / o_primv[0] | -0.114 | 5.813 |
| 27 | 0.605 | ascal:ascal / o_vacpt[8] | ascal:ascal / o_vpixq_pre[2].g[2] | -0.488 | 5.439 |
| 28 | 0.617 | ascal:ascal / o_vpix_inner[1].g[7] | ascal:ascal / o_poly_lum[7]_OTERM221_OTERM1276 | -0.494 | 5.421 |
| 29 | 0.629 | ascal:ascal / altsyncram:o_line2[0].r[7]__4 / altsyncram_ccn1:auto_generated / ram_block1a19~PORT_B_WRITE_ENABLE_REG | ascal:ascal / o_vpix_inner[0].b[4] | -1.178 | 4.725 |
| 30 | 0.65 | ascal:ascal / o_vcpt_pre3[3] | ascal:ascal / o_vcpt_pre3[4] | -0.114 | 5.768 |
| 31 | 0.65 | ascal:ascal / o_vcpt_pre3[3] | ascal:ascal / o_vcpt_pre3[3] | -0.114 | 5.768 |
| 32 | 0.65 | ascal:ascal / o_vcpt_pre3[3] | ascal:ascal / o_vcpt_pre3[7] | -0.114 | 5.768 |
| 33 | 0.655 | ascal:ascal / o_vcpt_pre3[3] | ascal:ascal / o_vcpt_pre3[1] | -0.109 | 5.768 |
| 34 | 0.662 | ascal:ascal / altsyncram:o_line1[0].r[7]__3 / altsyncram_ccn1:auto_generated / ram_block1a0~PORT_B_WRITE_ENABLE_REG | ascal:ascal / o_vpix_outer[2].r[7] | -1.156 | 4.714 |
| 35 | 0.706 | ascal:ascal / altsyncram:o_line2[0].r[7]__4 / altsyncram_ccn1:auto_generated / ram_block1a19~PORT_B_WRITE_ENABLE_REG | ascal:ascal / o_vpix_outer[1].b[4] | -1.181 | 4.645 |
| 36 | 0.708 | ascal:ascal / altsyncram:o_line1[0].r[7]__3 / altsyncram_ccn1:auto_generated / ram_block1a0~PORT_B_WRITE_ENABLE_REG | ascal:ascal / o_vpix_inner[0].r[5] | -1.172 | 4.652 |
| 37 | 0.769 | ascal:ascal / o_hacc_next[6] | ascal:ascal / o_hacc_next[12] | -0.112 | 5.651 |
| 38 | 0.776 | ascal:ascal / o_hacc_next[2] | ascal:ascal / o_hacc_next[7] | -0.116 | 5.64 |
| 39 | 0.782 | ascal:ascal / o_hacc_next[6] | ascal:ascal / o_hacc_next[10] | -0.112 | 5.638 |
| 40 | 0.782 | ascal:ascal / o_hacc[4] | ascal:ascal / o_dir[0][10] | -0.137 | 5.613 |
| 41 | 0.782 | ascal:ascal / altsyncram:o_linf2[0].r[7]__8 / altsyncram_m6n1:auto_generated / ram_block1a0~PORT_B_WRITE_ENABLE_REG | ascal:ascal / o_vpix_outer[1].r[4] | -1.979 | 3.771 |
| 42 | 0.789 | ascal:ascal / o_div[0][20] | ascal:ascal / o_div[1][20] | -0.11 | 5.633 |
| 43 | 0.793 | ascal:ascal / altsyncram:o_linf2[0].r[7]__8 / altsyncram_m6n1:auto_generated / ram_block1a0~PORT_B_WRITE_ENABLE_REG | ascal:ascal / o_vpix_inner[0].r[4] | -1.976 | 3.763 |
| 44 | 0.804 | ascal:ascal / altsyncram:o_line3[0].r[7]__5 / altsyncram_ccn1:auto_generated / ram_block1a4~PORT_B_WRITE_ENABLE_REG | ascal:ascal / o_vpix_inner[0].g[7] | -1.184 | 4.544 |
| 45 | 0.805 | ascal:ascal / o_hcpt[3] | ascal:ascal / o_vcpt_sync[2] | -0.126 | 5.601 |
| 46 | 0.805 | ascal:ascal / o_hcpt[3] | ascal:ascal / o_vcpt_sync[0] | -0.126 | 5.601 |
| 47 | 0.805 | ascal:ascal / o_hcpt[3] | ascal:ascal / o_vcpt_sync[8] | -0.126 | 5.601 |
| 48 | 0.805 | ascal:ascal / o_hcpt[3] | ascal:ascal / o_vcpt_sync[6] | -0.126 | 5.601 |
| 49 | 0.805 | ascal:ascal / o_hcpt[3] | ascal:ascal / o_vcpt_sync[4] | -0.126 | 5.601 |
| 50 | 0.805 | ascal:ascal / o_hcpt[3] | ascal:ascal / o_vcpt_sync[10] | -0.126 | 5.601 |

### candidate2

| Rank | Slack ns | From | To | Skew ns | Data ns |
| --- | --- | --- | --- | --- | --- |
| 1 | 0.524 | ascal:ascal / altsyncram:o_line3[0].r[7]__5 / altsyncram_ccn1:auto_generated / ram_block1a0~PORT_B_WRITE_ENABLE_REG | ascal:ascal / o_vpix_outer[1].r[7] | -1.561 | 4.447 |
| 2 | 0.53 | ascal:ascal / altsyncram:o_line3[0].r[7]__5 / altsyncram_ccn1:auto_generated / ram_block1a0~PORT_B_WRITE_ENABLE_REG | ascal:ascal / o_vpix_inner[0].r[7] | -1.558 | 4.444 |
| 3 | 0.566 | ascal:ascal / o_hacc[9] | ascal:ascal / o_dir[0][10] | -0.18 | 5.786 |
| 4 | 0.591 | ascal:ascal / o_hacc[9] | ascal:ascal / o_div[0][20] | -0.179 | 5.762 |
| 5 | 0.685 | ascal:ascal / o_div[2][20] | ascal:ascal / o_hfrac[1][4] | -0.482 | 5.365 |
| 6 | 0.719 | ascal:ascal / o_hcpt[0] | ascal:ascal / o_vcpt[0] | -0.122 | 5.691 |
| 7 | 0.738 | ascal:ascal / altsyncram:o_line1[0].r[7]__3 / altsyncram_ccn1:auto_generated / ram_block1a14~PORT_B_WRITE_ENABLE_REG | ascal:ascal / o_vpix_outer[1].g[1] | -1.507 | 4.287 |
| 8 | 0.743 | ascal:ascal / altsyncram:o_line1[0].r[7]__3 / altsyncram_ccn1:auto_generated / ram_block1a14~PORT_B_WRITE_ENABLE_REG | ascal:ascal / o_vpix_inner[0].g[1] | -1.505 | 4.284 |
| 9 | 0.744 | ascal:ascal / o_vcpt_pre3[1] | ascal:ascal / o_sync | -0.094 | 5.694 |
| 10 | 0.744 | ascal:ascal / altsyncram:o_line1[0].r[7]__3 / altsyncram_ccn1:auto_generated / ram_block1a9~PORT_B_WRITE_ENABLE_REG | ascal:ascal / o_vpix_outer[1].g[3] | -1.506 | 4.282 |
| 11 | 0.75 | ascal:ascal / altsyncram:o_linf0[0].r[7]__6 / altsyncram_m6n1:auto_generated / ram_block1a0~PORT_B_WRITE_ENABLE_REG | ascal:ascal / o_vpix_inner[0].r[4] | -2.389 | 3.393 |
| 12 | 0.788 | ascal:ascal / o_adrs_pre[9] | ascal:ascal / o_adrs[10] | -0.406 | 5.338 |
| 13 | 0.791 | ascal:ascal / o_vcpt_pre2[0] | ascal:ascal / o_divstart | -0.16 | 5.581 |
| 14 | 0.803 | ascal:ascal / altsyncram:o_linf0[0].r[7]__6 / altsyncram_m6n1:auto_generated / ram_block1a0~PORT_B_WRITE_ENABLE_REG | ascal:ascal / o_vpix_inner[0].r[0] | -2.399 | 3.33 |
| 15 | 0.814 | ascal:ascal / altsyncram:o_line1[0].r[7]__3 / altsyncram_ccn1:auto_generated / ram_block1a9~PORT_B_WRITE_ENABLE_REG | ascal:ascal / o_vpix_inner[0].g[3] | -1.503 | 4.215 |
| 16 | 0.815 | ascal:ascal / altsyncram:o_linf1[0].r[7]__7 / altsyncram_m6n1:auto_generated / ram_block1a0~PORT_B_WRITE_ENABLE_REG | ascal:ascal / o_vpix_outer[2].b[3] | -2.039 | 3.678 |
| 17 | 0.819 | ascal:ascal / altsyncram:o_linf0[0].r[7]__6 / altsyncram_m6n1:auto_generated / ram_block1a0~PORT_B_WRITE_ENABLE_REG | ascal:ascal / o_vpix_outer[1].r[0] | -2.402 | 3.311 |
| 18 | 0.821 | ascal:ascal / o_hcpt[0] | ascal:ascal / o_vcpt_pre3[5] | -0.129 | 5.582 |
| 19 | 0.821 | ascal:ascal / o_hcpt[0] | ascal:ascal / o_vcpt_pre3[4] | -0.129 | 5.582 |
| 20 | 0.821 | ascal:ascal / o_hcpt[0] | ascal:ascal / o_vcpt_pre3[3] | -0.125 | 5.586 |
| 21 | 0.821 | ascal:ascal / o_hcpt[0] | ascal:ascal / o_vcpt_pre3[2] | -0.125 | 5.586 |
| 22 | 0.821 | ascal:ascal / o_hcpt[0] | ascal:ascal / o_vcpt_pre3[1] | -0.125 | 5.586 |
| 23 | 0.821 | ascal:ascal / o_hcpt[0] | ascal:ascal / o_vcpt_pre3[0] | -0.129 | 5.582 |
| 24 | 0.821 | ascal:ascal / altsyncram:o_line0[0].r[7]__2 / altsyncram_ccn1:auto_generated / ram_block1a0~PORT_B_WRITE_ENABLE_REG | ascal:ascal / o_vpix_outer[1].r[6] | -1.176 | 4.535 |
| 25 | 0.829 | ascal:ascal / o_hcpt[0] | ascal:ascal / o_vcpt_pre3[7] | -0.128 | 5.575 |
| 26 | 0.829 | ascal:ascal / o_hcpt[0] | ascal:ascal / o_vcpt_pre3[6] | -0.128 | 5.575 |
| 27 | 0.829 | ascal:ascal / o_hcpt[0] | ascal:ascal / o_vcpt_pre3[8] | -0.128 | 5.575 |
| 28 | 0.829 | ascal:ascal / o_hcpt[0] | ascal:ascal / o_vcpt_pre3[9] | -0.124 | 5.579 |
| 29 | 0.829 | ascal:ascal / o_hcpt[0] | ascal:ascal / o_vcpt_pre3[11] | -0.124 | 5.579 |
| 30 | 0.829 | ascal:ascal / o_hcpt[0] | ascal:ascal / o_vcpt_pre3[10] | -0.124 | 5.579 |
| 31 | 0.836 | ascal:ascal / altsyncram:o_linf0[0].r[7]__6 / altsyncram_m6n1:auto_generated / ram_block1a0~PORT_B_WRITE_ENABLE_REG | ascal:ascal / o_vpix_outer[1].r[4] | -2.392 | 3.304 |
| 32 | 0.837 | ascal:ascal / altsyncram:o_line0[0].r[7]__2 / altsyncram_ccn1:auto_generated / ram_block1a0~PORT_B_WRITE_ENABLE_REG | ascal:ascal / o_vpix_inner[0].r[6] | -1.173 | 4.522 |
| 33 | 0.84 | osd:hdmi_osd / h_cnt[16] | osd:hdmi_osd / osd_hcnt2[8] | -0.18 | 5.512 |
| 34 | 0.868 | osd:hdmi_osd / h_cnt[16] | osd:hdmi_osd / osd_de[0] | -0.14 | 5.524 |
| 35 | 0.899 | ascal:ascal / o_vpix_inner[1].g[7] | ascal:ascal / o_poly_lum[7]_OTERM223_OTERM1288 | -0.117 | 5.516 |
| 36 | 0.9 | ascal:ascal / o_vpix_inner[1].g[7] | ascal:ascal / o_poly_lum[7]_OTERM223_OTERM1286 | -0.117 | 5.515 |
| 37 | 0.903 | ascal:ascal / o_poly_lum[7]_OTERM223_OTERM1292 | ascal:ascal / o_poly_lum1[0] | -0.488 | 5.141 |
| 38 | 0.91 | ascal:ascal / o_hcpt[0] | ascal:ascal / o_vcpt_pre[7] | -0.142 | 5.48 |
| 39 | 0.92 | osd:hdmi_osd / h_cnt[16] | osd:hdmi_osd / osd_hcnt2[1] | -0.174 | 5.438 |
| 40 | 0.924 | ascal:ascal / o_h_poly_t.b1[13] | ascal:ascal / o_h_poly_pix.b[2] | -0.427 | 5.181 |
| 41 | 0.926 | ascal:ascal / o_h_poly_t.b1[13] | ascal:ascal / o_h_poly_pix.b[3] | -0.428 | 5.178 |
| 42 | 0.928 | ascal:ascal / o_h_poly_t.b1[13] | ascal:ascal / o_h_poly_pix.b[0] | -0.423 | 5.181 |
| 43 | 0.928 | ascal:ascal / o_h_poly_t.b1[13] | ascal:ascal / o_h_poly_pix.b[7] | -0.423 | 5.181 |
| 44 | 0.928 | ascal:ascal / o_h_poly_t.b1[13] | ascal:ascal / o_h_poly_pix.b[5] | -0.423 | 5.181 |
| 45 | 0.93 | ascal:ascal / o_h_poly_t.b1[13] | ascal:ascal / o_h_poly_pix.b[6] | -0.424 | 5.178 |
| 46 | 0.93 | ascal:ascal / o_h_poly_t.b1[13] | ascal:ascal / o_h_poly_pix.b[1] | -0.424 | 5.178 |
| 47 | 0.93 | ascal:ascal / o_h_poly_t.b1[13] | ascal:ascal / o_h_poly_pix.b[4] | -0.424 | 5.178 |
| 48 | 0.943 | ascal:ascal / altsyncram:o_linf3[0].r[7]__9 / altsyncram_m6n1:auto_generated / ram_block1a0~PORT_B_WRITE_ENABLE_REG | ascal:ascal / o_vpix_outer[1].r[5] | -2.021 | 3.568 |
| 49 | 0.955 | ascal:ascal / altsyncram:o_linf3[0].r[7]__9 / altsyncram_m6n1:auto_generated / ram_block1a0~PORT_B_WRITE_ENABLE_REG | ascal:ascal / o_vpix_inner[0].r[5] | -2.018 | 3.559 |
| 50 | 0.959 | ascal:ascal / o_hcpt[0] | ascal:ascal / o_vcpt_pre[3] | -0.136 | 5.437 |

## core_setup

### baseline2

| Rank | Slack ns | From | To | Skew ns | Data ns |
| --- | --- | --- | --- | --- | --- |
| 1 | 0.551 | emu:emu / sdram:ram / sd_dat[8] | emu:emu / system:system / T80s:z80_inst / T80:u0 / IR[6]~DUPLICATE | -1.514 | 16.231 |
| 2 | 0.556 | emu:emu / sdram:ram / sd_dat[8] | emu:emu / system:system / T80s:z80_inst / T80:u0 / IR[6] | -1.511 | 16.229 |
| 3 | 0.563 | emu:emu / sdram:ram / sd_dat[8] | emu:emu / system:system / T80s:z80_inst / DI_Reg[1]_OTERM305 | -1.512 | 16.221 |
| 4 | 0.58 | emu:emu / sdram:ram / sd_dat[8] | emu:emu / system:system / T80s:z80_inst / T80:u0 / IR[0] | -1.516 | 16.2 |
| 5 | 0.622 | emu:emu / sdram:ram / sd_dat[8] | emu:emu / system:system / T80s:z80_inst / T80:u0 / IR[4] | -1.506 | 16.168 |
| 6 | 0.696 | emu:emu / sdram:ram / sd_dat[8] | emu:emu / system:system / T80s:z80_inst / T80:u0 / IR[2] | -1.511 | 16.089 |
| 7 | 0.73 | emu:emu / sdram:ram / sd_dat[8] | emu:emu / system:system / T80s:z80_inst / T80:u0 / IR[7] | -1.508 | 16.058 |
| 8 | 0.747 | emu:emu / sdram:ram / sd_dat[8] | emu:emu / system:system / T80s:z80_inst / T80:u0 / IR[3] | -1.514 | 16.035 |
| 9 | 0.75 | emu:emu / sdram:ram / sd_dat[8] | emu:emu / system:system / T80s:z80_inst / DI_Reg[7]_OTERM321 | -1.511 | 16.035 |
| 10 | 0.812 | emu:emu / ce_cpu~DUPLICATE | emu:emu / system:system / opll:fm / envelopegenerator:eg / ntable[2] | -0.409 | 7.762 |
| 11 | 0.812 | emu:emu / ce_cpu~DUPLICATE | emu:emu / system:system / opll:fm / envelopegenerator:eg / ntable[1] | -0.409 | 7.762 |
| 12 | 0.813 | emu:emu / ce_cpu~DUPLICATE | emu:emu / system:system / opll:fm / envelopegenerator:eg / ntable[3] | -0.414 | 7.756 |
| 13 | 0.813 | emu:emu / ce_cpu~DUPLICATE | emu:emu / system:system / opll:fm / envelopegenerator:eg / ntable[0] | -0.414 | 7.756 |
| 14 | 0.813 | emu:emu / ce_cpu~DUPLICATE | emu:emu / system:system / opll:fm / envelopegenerator:eg / ntable[2]~DUPLICATE | -0.416 | 7.754 |
| 15 | 0.972 | emu:emu / sdram:ram / sd_dat[8] | emu:emu / system:system / T80s:z80_inst / DI_Reg[3]_OTERM299 | -1.512 | 15.812 |
| 16 | 0.993 | emu:emu / ce_cpu~DUPLICATE | emu:emu / savestates:savestates_inst / z80_snap[185] | -0.491 | 7.499 |
| 17 | 0.996 | emu:emu / sdram:ram / sd_dat[8] | emu:emu / system:system / T80s:z80_inst / T80:u0 / IR[1]_OTERM557 | -1.47 | 15.83 |
| 18 | 0.997 | emu:emu / sdram:ram / sd_dat[8] | emu:emu / system:system / T80s:z80_inst / T80:u0 / IR[5] | -1.511 | 15.788 |
| 19 | 1.001 | emu:emu / ce_cpu~DUPLICATE | emu:emu / savestates:savestates_inst / z80_snap[163] | -0.487 | 7.495 |
| 20 | 1.004 | emu:emu / ce_cpu~DUPLICATE | emu:emu / savestates:savestates_inst / z80_snap[171] | -0.491 | 7.488 |
| 21 | 1.015 | emu:emu / sdram:ram / sd_dat[8] | emu:emu / system:system / T80s:z80_inst / DI_Reg[2]_OTERM351 | -1.511 | 15.77 |
| 22 | 1.051 | emu:emu / ce_cpu~DUPLICATE | emu:emu / savestates:savestates_inst / z80_snap[170] | -0.487 | 7.445 |
| 23 | 1.063 | emu:emu / ce_cpu~DUPLICATE | emu:emu / system:system / opll:fm / envelopegenerator:eg / ntable[10] | -0.434 | 7.486 |
| 24 | 1.064 | emu:emu / ce_cpu~DUPLICATE | emu:emu / system:system / opll:fm / envelopegenerator:eg / ntable[12] | -0.437 | 7.482 |
| 25 | 1.064 | emu:emu / ce_cpu~DUPLICATE | emu:emu / system:system / opll:fm / envelopegenerator:eg / ntable[8] | -0.437 | 7.482 |
| 26 | 1.065 | emu:emu / ce_cpu~DUPLICATE | emu:emu / system:system / opll:fm / envelopegenerator:eg / ntable[11] | -0.452 | 7.466 |
| 27 | 1.065 | emu:emu / ce_cpu~DUPLICATE | emu:emu / system:system / opll:fm / envelopegenerator:eg / ntable[9] | -0.451 | 7.467 |
| 28 | 1.09 | emu:emu / ce_cpu~DUPLICATE | emu:emu / savestates:savestates_inst / z80_snap[121] | -0.442 | 7.451 |
| 29 | 1.091 | emu:emu / ce_cpu~DUPLICATE | emu:emu / savestates:savestates_inst / z80_snap[127] | -0.442 | 7.45 |
| 30 | 1.092 | emu:emu / ce_cpu~DUPLICATE | emu:emu / savestates:savestates_inst / z80_snap[120] | -0.447 | 7.444 |
| 31 | 1.093 | emu:emu / ce_cpu~DUPLICATE | emu:emu / savestates:savestates_inst / z80_snap[101] | -0.447 | 7.443 |
| 32 | 1.098 | emu:emu / ce_cpu~DUPLICATE | emu:emu / savestates:savestates_inst / z80_snap[95] | -0.442 | 7.443 |
| 33 | 1.1 | emu:emu / ce_cpu~DUPLICATE | emu:emu / savestates:savestates_inst / z80_snap[94] | -0.447 | 7.436 |
| 34 | 1.103 | emu:emu / ce_cpu~DUPLICATE | emu:emu / savestates:savestates_inst / z80_snap[124] | -0.442 | 7.438 |
| 35 | 1.105 | emu:emu / ce_cpu~DUPLICATE | emu:emu / savestates:savestates_inst / z80_snap[123] | -0.447 | 7.431 |
| 36 | 1.107 | emu:emu / bios_config_reset | emu:emu / system:system / jt89:psg2_inst / cen_16 | -0.834 | 7.042 |
| 37 | 1.107 | emu:emu / bios_config_reset | emu:emu / system:system / jt89:psg_inst / cen_16 | -0.834 | 7.042 |
| 38 | 1.11 | emu:emu / ce_cpu~DUPLICATE | emu:emu / savestates:savestates_inst / z80_snap[116] | -0.442 | 7.431 |
| 39 | 1.112 | emu:emu / ce_cpu~DUPLICATE | emu:emu / savestates:savestates_inst / z80_snap[85] | -0.447 | 7.424 |
| 40 | 1.15 | emu:emu / sdram:ram / sd_dat[8] | emu:emu / system:system / T80s:z80_inst / DI_Reg[4]_OTERM347 | -1.509 | 15.637 |
| 41 | 1.158 | emu:emu / ce_cpu~DUPLICATE | emu:emu / system:system / opll:fm / envelopegenerator:eg / ntable[7]~DUPLICATE | -0.46 | 7.365 |
| 42 | 1.158 | emu:emu / ce_cpu~DUPLICATE | emu:emu / system:system / opll:fm / envelopegenerator:eg / ntable[6] | -0.458 | 7.367 |
| 43 | 1.158 | emu:emu / ce_cpu~DUPLICATE | emu:emu / system:system / opll:fm / envelopegenerator:eg / ntable[5] | -0.454 | 7.371 |
| 44 | 1.158 | emu:emu / ce_cpu~DUPLICATE | emu:emu / system:system / opll:fm / envelopegenerator:eg / ntable[4] | -0.455 | 7.37 |
| 45 | 1.158 | emu:emu / ce_cpu~DUPLICATE | emu:emu / system:system / opll:fm / envelopegenerator:eg / ntable[7] | -0.454 | 7.371 |
| 46 | 1.172 | emu:emu / ce_cpu~DUPLICATE | emu:emu / savestates:savestates_inst / cur_game_id[15] | -0.43 | 7.381 |
| 47 | 1.173 | emu:emu / ce_cpu~DUPLICATE | emu:emu / savestates:savestates_inst / cur_game_id[26] | -0.429 | 7.381 |
| 48 | 1.173 | emu:emu / ce_cpu~DUPLICATE | emu:emu / savestates:savestates_inst / cur_game_id[27] | -0.431 | 7.379 |
| 49 | 1.183 | emu:emu / ss_phase_ready | emu:emu / savestates:savestates_inst / state.ST_LOAD_VRAM2_PASSIVE | -0.376 | 7.424 |
| 50 | 1.183 | emu:emu / sdram:ram / sd_dat[4] | emu:emu / system:system / T80s:z80_inst / T80:u0 / IR[1]_OTERM565 | -1.572 | 15.541 |

### candidate2

| Rank | Slack ns | From | To | Skew ns | Data ns |
| --- | --- | --- | --- | --- | --- |
| 1 | 1.077 | emu:emu / system:system / mapper_detect:mapper_detect_inst / rom_crc32[25]~DUPLICATE | emu:emu / system:system / jt89:psg_inst / cen_16 | -0.768 | 7.138 |
| 2 | 1.079 | emu:emu / system:system / mapper_detect:mapper_detect_inst / rom_crc32[25]~DUPLICATE | emu:emu / system:system / jt89:psg2_inst / cen_16 | -0.766 | 7.138 |
| 3 | 1.112 | emu:emu / ce_pix~DUPLICATE | emu:emu / system:system / vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:58:shifter / shift3[7] | -0.349 | 7.522 |
| 4 | 1.112 | emu:emu / ce_pix~DUPLICATE | emu:emu / system:system / vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:58:shifter / shift3[2] | -0.349 | 7.522 |
| 5 | 1.112 | emu:emu / ce_pix~DUPLICATE | emu:emu / system:system / vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:58:shifter / shift3[3] | -0.349 | 7.522 |
| 6 | 1.215 | emu:emu / ce_pix~DUPLICATE | emu:emu / system:system / vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:58:shifter / shift0[1] | -0.338 | 7.43 |
| 7 | 1.215 | emu:emu / ce_pix~DUPLICATE | emu:emu / system:system / vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:58:shifter / shift1[7] | -0.336 | 7.432 |
| 8 | 1.274 | emu:emu / sdram:ram / sd_dat[11] | emu:emu / system:system / T80s:z80_inst / T80:u0 / IR[4] | -1.536 | 15.486 |
| 9 | 1.28 | emu:emu / sdram:ram / sd_dat[11] | emu:emu / system:system / T80s:z80_inst / T80:u0 / IR[2]_OTERM557~DUPLICATE | -1.561 | 15.455 |
| 10 | 1.284 | emu:emu / ce_pix~DUPLICATE | emu:emu / system:system / vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:50:shifter / shift2[6] | -0.438 | 7.261 |
| 11 | 1.284 | emu:emu / ce_pix~DUPLICATE | emu:emu / system:system / vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:50:shifter / shift2[4] | -0.438 | 7.261 |
| 12 | 1.284 | emu:emu / ce_pix~DUPLICATE | emu:emu / system:system / vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:50:shifter / shift2[2] | -0.438 | 7.261 |
| 13 | 1.284 | emu:emu / ce_pix~DUPLICATE | emu:emu / system:system / vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:50:shifter / shift1[7] | -0.438 | 7.261 |
| 14 | 1.284 | emu:emu / ce_pix~DUPLICATE | emu:emu / system:system / vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:50:shifter / shift1[1] | -0.438 | 7.261 |
| 15 | 1.284 | emu:emu / ce_pix~DUPLICATE | emu:emu / system:system / vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:50:shifter / shift0[7] | -0.438 | 7.261 |
| 16 | 1.284 | emu:emu / ce_pix~DUPLICATE | emu:emu / system:system / vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:50:shifter / shift1[5] | -0.438 | 7.261 |
| 17 | 1.285 | emu:emu / sdram:ram / sd_dat[11] | emu:emu / system:system / T80s:z80_inst / T80:u0 / IR[2]_OTERM557 | -1.554 | 15.457 |
| 18 | 1.285 | emu:emu / ce_pix~DUPLICATE | emu:emu / system:system / vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:50:shifter / shift1[6] | -0.436 | 7.262 |
| 19 | 1.285 | emu:emu / ce_pix~DUPLICATE | emu:emu / system:system / vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:50:shifter / shift1[2] | -0.436 | 7.262 |
| 20 | 1.285 | emu:emu / ce_pix~DUPLICATE | emu:emu / system:system / vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:50:shifter / shift0[6]~DUPLICATE | -0.436 | 7.262 |
| 21 | 1.285 | emu:emu / ce_pix~DUPLICATE | emu:emu / system:system / vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:50:shifter / shift2[6]~DUPLICATE | -0.442 | 7.256 |
| 22 | 1.285 | emu:emu / ce_pix~DUPLICATE | emu:emu / system:system / vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:50:shifter / shift2[1] | -0.436 | 7.262 |
| 23 | 1.285 | emu:emu / ce_pix~DUPLICATE | emu:emu / system:system / vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:50:shifter / shift2[3] | -0.436 | 7.262 |
| 24 | 1.285 | emu:emu / ce_pix~DUPLICATE | emu:emu / system:system / vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:50:shifter / shift1[4] | -0.442 | 7.256 |
| 25 | 1.285 | emu:emu / ce_pix~DUPLICATE | emu:emu / system:system / vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:50:shifter / shift1[3] | -0.436 | 7.262 |
| 26 | 1.286 | emu:emu / ce_pix~DUPLICATE | emu:emu / system:system / vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:50:shifter / shift2[5] | -0.443 | 7.254 |
| 27 | 1.286 | emu:emu / ce_pix~DUPLICATE | emu:emu / system:system / vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:50:shifter / shift0[6] | -0.443 | 7.254 |
| 28 | 1.286 | emu:emu / ce_pix~DUPLICATE | emu:emu / system:system / vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:50:shifter / shift2[7] | -0.443 | 7.254 |
| 29 | 1.286 | emu:emu / ce_pix~DUPLICATE | emu:emu / system:system / vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:50:shifter / shift2[1]~DUPLICATE | -0.443 | 7.254 |
| 30 | 1.286 | emu:emu / ce_pix~DUPLICATE | emu:emu / system:system / vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:50:shifter / shift1[3]~DUPLICATE | -0.443 | 7.254 |
| 31 | 1.352 | emu:emu / ce_pix~DUPLICATE | emu:emu / system:system / vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:38:shifter / shift3[0]~DUPLICATE | -0.423 | 7.208 |
| 32 | 1.358 | emu:emu / ce_pix~DUPLICATE | emu:emu / system:system / vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:38:shifter / shift3[0] | -0.419 | 7.206 |
| 33 | 1.381 | emu:emu / ce_pix~DUPLICATE | emu:emu / system:system / vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:58:shifter / shift3[6] | -0.339 | 7.263 |
| 34 | 1.381 | emu:emu / ce_pix~DUPLICATE | emu:emu / system:system / vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:58:shifter / shift3[5] | -0.342 | 7.26 |
| 35 | 1.381 | emu:emu / ce_pix~DUPLICATE | emu:emu / system:system / vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:58:shifter / shift3[4] | -0.342 | 7.26 |
| 36 | 1.385 | emu:emu / ce_pix~DUPLICATE | emu:emu / system:system / vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:49:shifter / shift2[6]~DUPLICATE | -0.446 | 7.152 |
| 37 | 1.385 | emu:emu / ce_pix~DUPLICATE | emu:emu / system:system / vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:49:shifter / shift2[4] | -0.446 | 7.152 |
| 38 | 1.385 | emu:emu / ce_pix~DUPLICATE | emu:emu / system:system / vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:49:shifter / shift1[4] | -0.446 | 7.152 |
| 39 | 1.385 | emu:emu / ce_pix~DUPLICATE | emu:emu / system:system / vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:49:shifter / shift1[5]~DUPLICATE | -0.446 | 7.152 |
| 40 | 1.385 | emu:emu / ce_pix~DUPLICATE | emu:emu / system:system / vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:49:shifter / shift1[7] | -0.446 | 7.152 |
| 41 | 1.386 | emu:emu / ce_pix~DUPLICATE | emu:emu / system:system / vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:49:shifter / shift2[5] | -0.444 | 7.153 |
| 42 | 1.386 | emu:emu / ce_pix~DUPLICATE | emu:emu / system:system / vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:49:shifter / shift2[3] | -0.444 | 7.153 |
| 43 | 1.386 | emu:emu / ce_pix~DUPLICATE | emu:emu / system:system / vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:49:shifter / shift2[2] | -0.45 | 7.147 |
| 44 | 1.386 | emu:emu / ce_pix~DUPLICATE | emu:emu / system:system / vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:49:shifter / shift0[7] | -0.45 | 7.147 |
| 45 | 1.386 | emu:emu / ce_pix~DUPLICATE | emu:emu / system:system / vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:49:shifter / shift0[6] | -0.444 | 7.153 |
| 46 | 1.386 | emu:emu / ce_pix~DUPLICATE | emu:emu / system:system / vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:49:shifter / shift2[7] | -0.444 | 7.153 |
| 47 | 1.386 | emu:emu / ce_pix~DUPLICATE | emu:emu / system:system / vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:49:shifter / shift2[6] | -0.45 | 7.147 |
| 48 | 1.386 | emu:emu / ce_pix~DUPLICATE | emu:emu / system:system / vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:49:shifter / shift1[6] | -0.45 | 7.147 |
| 49 | 1.386 | emu:emu / ce_pix~DUPLICATE | emu:emu / system:system / vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:49:shifter / shift1[5] | -0.45 | 7.147 |
| 50 | 1.386 | emu:emu / ce_pix~DUPLICATE | emu:emu / system:system / vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:49:shifter / shift1[3] | -0.444 | 7.153 |

## hdmi_hold

### baseline2

| Rank | Slack ns | From | To | Skew ns | Data ns |
| --- | --- | --- | --- | --- | --- |
| 1 | 0.257 | ascal:ascal / o_vcpt_sync[4] | ascal:ascal / o_vcpt_sync[4] | 0.111 | 0.368 |
| 2 | 0.261 | ascal:ascal / o_vcpt_sync[2] | ascal:ascal / o_vcpt_sync[2] | 0.111 | 0.372 |
| 3 | 0.27 | osd:hdmi_osd / Add2~73_OTERM399 | osd:hdmi_osd / Add2~73_OTERM399 | 0.093 | 0.363 |
| 4 | 0.279 | ascal:ascal / o_dcptv[13][4] | ascal:ascal / o_dcptv[13][4] | 0.094 | 0.373 |
| 5 | 0.293 | shadowmask:HDMI_shadowmask / b3_x[4] | shadowmask:HDMI_shadowmask / b4[4] | 0.095 | 0.388 |
| 6 | 0.33 | vga_out:vga_scaler_out / altshift_taps:din1_rtl_0 / shift_taps_quu:auto_generated / altsyncram_dr91:altsyncram4 / ram_block5a15 | d[15] | 0.753 | 1.083 |
| 7 | 0.349 | osd:hdmi_osd / Add2~17_OTERM427DUPLICATE | osd:hdmi_osd / pixsz[2] | 0.095 | 0.444 |
| 8 | 0.349 | vga_out:vga_scaler_out / altshift_taps:din1_rtl_0 / shift_taps_quu:auto_generated / altsyncram_dr91:altsyncram4 / ram_block5a14 | d[16] | 0.761 | 1.11 |
| 9 | 0.35 | shadowmask:HDMI_shadowmask / pcnt[0] | shadowmask:HDMI_shadowmask / pde[1] | 0.13 | 0.48 |
| 10 | 0.35 | vga_out:vga_scaler_out / altshift_taps:din1_rtl_0 / shift_taps_quu:auto_generated / altsyncram_dr91:altsyncram4 / ram_block5a19 | d[11] | 0.825 | 1.175 |
| 11 | 0.352 | osd:hdmi_osd / Add2~25_OTERM423 | osd:hdmi_osd / pixsz[4] | 0.1 | 0.452 |
| 12 | 0.366 | osd:hdmi_osd / Add2~49_OTERM411DUPLICATE | osd:hdmi_osd / pixsz[11] | 0.087 | 0.453 |
| 13 | 0.369 | osd:hdmi_osd / Add2~37_OTERM417 | osd:hdmi_osd / pixsz[6] | 0.095 | 0.464 |
| 14 | 0.373 | osd:hdmi_osd / Add2~37_OTERM417 | osd:hdmi_osd / pixsz[7] | 0.101 | 0.474 |
| 15 | 0.385 | ascal:ascal / o_vpixq_pre[3].b[6] | ascal:ascal / o_vpixq[3].b[6] | 0.799 | 1.184 |
| 16 | 0.386 | ascal:ascal / o_hpixq[7][1].b[7] | ascal:ascal / o_hpixq[8][1].b[7] | 0.813 | 1.199 |
| 17 | 0.387 | ascal:ascal / o_vpixq_pre[2].r[3] | ascal:ascal / o_vpixq[2].r[3] | 0.842 | 1.229 |
| 18 | 0.388 | ascal:ascal / o_vpixq_pre[2].r[1] | ascal:ascal / o_vpixq[2].r[1] | 0.836 | 1.224 |
| 19 | 0.391 | ascal:ascal / o_vpixq_pre[1].r[3] | ascal:ascal / o_vpixq[1].r[3] | 0.807 | 1.198 |
| 20 | 0.396 | vga_out:vga_scaler_out / altshift_taps:din1_rtl_0 / shift_taps_quu:auto_generated / altsyncram_dr91:altsyncram4 / ram_block5a26 | d[4] | 0.811 | 1.207 |
| 21 | 0.407 | d[21] | hdmi_out_d[21] | 1.79 | 2.197 |
| 22 | 0.408 | ascal:ascal / o_vpixq_pre[2].b[5] | ascal:ascal / o_vpixq[2].b[5] | 0.813 | 1.221 |
| 23 | 0.408 | ascal:ascal / o_vpixq_pre[2].b[6] | ascal:ascal / o_vpixq[2].b[6] | 0.796 | 1.204 |
| 24 | 0.408 | vga_out:vga_scaler_out / altshift_taps:din1_rtl_0 / shift_taps_quu:auto_generated / altsyncram_dr91:altsyncram4 / ram_block5a8 | d[22] | 0.753 | 1.161 |
| 25 | 0.41 | vga_out:vga_scaler_out / altshift_taps:din1_rtl_0 / shift_taps_quu:auto_generated / altsyncram_dr91:altsyncram4 / ram_block5a29 | d[1] | 0.815 | 1.225 |
| 26 | 0.413 | ascal:ascal / o_vpixq_pre[3].g[0] | ascal:ascal / o_vpixq[3].g[0] | 0.452 | 0.865 |
| 27 | 0.415 | ascal:ascal / o_vpixq_pre[2].b[2] | ascal:ascal / o_vpixq[2].b[2] | 0.816 | 1.231 |
| 28 | 0.417 | ascal:ascal / o_vpixq_pre[3].g[4] | ascal:ascal / o_vpixq[3].g[4] | 0.455 | 0.872 |
| 29 | 0.417 | vga_out:vga_scaler_out / altshift_taps:din1_rtl_0 / shift_taps_quu:auto_generated / altsyncram_dr91:altsyncram4 / ram_block5a16 | d[14] | 0.759 | 1.176 |
| 30 | 0.418 | ascal:ascal / o_hcpt[0] | ascal:ascal / o_hcpt[0] | 0.109 | 0.527 |
| 31 | 0.418 | ascal:ascal / o_vacpt[3] | ascal:ascal / o_vacpt[3] | 0.112 | 0.53 |
| 32 | 0.418 | ascal:ascal / o_acpt1[0] | ascal:ascal / o_acpt2[0] | 0.128 | 0.546 |
| 33 | 0.419 | ascal:ascal / o_dev[5] | ascal:ascal / o_dev[6] | 0.113 | 0.532 |
| 34 | 0.419 | ascal:ascal / o_vpixq_pre[3].r[3] | ascal:ascal / o_vpixq[3].r[3] | 0.83 | 1.249 |
| 35 | 0.421 | vga_out:vga_scaler_out / altshift_taps:din1_rtl_0 / shift_taps_quu:auto_generated / altsyncram_dr91:altsyncram4 / ram_block5a28 | d[2] | 0.822 | 1.243 |
| 36 | 0.422 | ascal:ascal / o_vacpt[0] | ascal:ascal / o_vacpt[0] | 0.111 | 0.533 |
| 37 | 0.424 | ascal:ascal / o_vpixq_pre[3].b[2] | ascal:ascal / o_vpixq[3].b[2] | 0.797 | 1.221 |
| 38 | 0.428 | ascal:ascal / o_vpixq_pre[3].r[4] | ascal:ascal / o_vpixq[3].r[4] | 0.828 | 1.256 |
| 39 | 0.429 | ascal:ascal / o_hacpt[8] | ascal:ascal / o_hacpt[8] | 0.114 | 0.543 |
| 40 | 0.429 | ascal:ascal / o_alt[0] | ascal:ascal / o_altx[0] | 0.12 | 0.549 |
| 41 | 0.43 | ascal:ascal / o_ad[2] | ascal:ascal / o_ad[2] | 0.115 | 0.545 |
| 42 | 0.43 | ascal:ascal / o_ad[0] | ascal:ascal / o_ad[0] | 0.115 | 0.545 |
| 43 | 0.43 | ascal:ascal / o_adturn | ascal:ascal / o_adturn | 0.115 | 0.545 |
| 44 | 0.43 | ascal:ascal / o_vpixq_pre[1].b[0] | ascal:ascal / o_vpixq[1].b[0] | 0.776 | 1.206 |
| 45 | 0.431 | ascal:ascal / o_hpixq[5][0].b[4] | ascal:ascal / o_hpixq[6][0].b[4] | 0.098 | 0.529 |
| 46 | 0.431 | ascal:ascal / o_vpixq_pre[0].r[5] | ascal:ascal / o_vpixq[0].r[5] | 0.799 | 1.23 |
| 47 | 0.432 | ascal:ascal / o_vcpt_sync[6] | ascal:ascal / o_vcpt_sync[6] | 0.111 | 0.543 |
| 48 | 0.433 | ascal:ascal / o_vpixq_pre[3].b[0] | ascal:ascal / o_vpixq[3].b[0] | 0.813 | 1.246 |
| 49 | 0.434 | vga_out:vga_scaler_out / altshift_taps:din1_rtl_0 / shift_taps_quu:auto_generated / altsyncram_dr91:altsyncram4 / ram_block5a18 | d[12] | 0.75 | 1.184 |
| 50 | 0.435 | ascal:ascal / o_vdivr[6] | ascal:ascal / o_vdivr[7] | 0.128 | 0.563 |

### candidate2

| Rank | Slack ns | From | To | Skew ns | Data ns |
| --- | --- | --- | --- | --- | --- |
| 1 | 0.256 | ascal:ascal / o_vdivr[16] | ascal:ascal / o_vdivr[17] | 0.106 | 0.362 |
| 2 | 0.262 | ascal:ascal / o_vcpt_sync[4] | ascal:ascal / o_vcpt_sync[4] | 0.111 | 0.373 |
| 3 | 0.266 | ascal:ascal / o_vdivr[19] | ascal:ascal / o_vdivr[20] | 0.112 | 0.378 |
| 4 | 0.275 | shadowmask:HDMI_shadowmask / pcnt[4] | shadowmask:HDMI_shadowmask / pcnt[4] | 0.093 | 0.368 |
| 5 | 0.289 | vga_out:vga_scaler_out / altshift_taps:din1_rtl_0 / shift_taps_quu:auto_generated / altsyncram_dr91:altsyncram4 / ram_block5a29 | d[1] | 0.809 | 1.098 |
| 6 | 0.306 | vga_out:vga_scaler_out / altshift_taps:din1_rtl_0 / shift_taps_quu:auto_generated / altsyncram_dr91:altsyncram4 / ram_block5a28 | d[2] | 0.803 | 1.109 |
| 7 | 0.328 | vga_out:vga_scaler_out / altshift_taps:din1_rtl_0 / shift_taps_quu:auto_generated / altsyncram_dr91:altsyncram4 / ram_block5a18 | d[12] | 0.76 | 1.088 |
| 8 | 0.338 | vga_out:vga_scaler_out / altshift_taps:din1_rtl_0 / shift_taps_quu:auto_generated / altsyncram_dr91:altsyncram4 / ram_block5a10 | d[20] | 0.824 | 1.162 |
| 9 | 0.359 | osd:hdmi_osd / Add2~5_OTERM497DUPLICATE | osd:hdmi_osd / pixsz[11] | 0.086 | 0.445 |
| 10 | 0.361 | ascal:ascal / o_vpixq_pre[1].b[7] | ascal:ascal / o_vpixq[1].b[7] | 0.808 | 1.169 |
| 11 | 0.363 | vga_out:vga_scaler_out / altshift_taps:din1_rtl_0 / shift_taps_quu:auto_generated / altsyncram_dr91:altsyncram4 / ram_block5a11 | d[19] | 0.803 | 1.166 |
| 12 | 0.367 | ascal:ascal / o_off[1][2] | ascal:ascal / o_off[0][2] | 0.115 | 0.482 |
| 13 | 0.372 | ascal:ascal / o_vpixq_pre[1].b[4] | ascal:ascal / o_vpixq[1].b[4] | 0.47 | 0.842 |
| 14 | 0.382 | ascal:ascal / o_vpixq_pre[2].g[1] | ascal:ascal / o_vpixq[2].g[1] | 0.452 | 0.834 |
| 15 | 0.382 | vga_out:vga_scaler_out / altshift_taps:din1_rtl_0 / shift_taps_quu:auto_generated / altsyncram_dr91:altsyncram4 / ram_block5a24 | d[6] | 0.804 | 1.186 |
| 16 | 0.382 | vga_out:vga_scaler_out / altshift_taps:din1_rtl_0 / shift_taps_quu:auto_generated / altsyncram_dr91:altsyncram4 / ram_block5a16 | d[14] | 0.76 | 1.142 |
| 17 | 0.383 | ascal:ascal / o_vpixq_pre[1].b[3] | ascal:ascal / o_vpixq[1].b[3] | 0.464 | 0.847 |
| 18 | 0.385 | osd:hdmi_osd / Add2~45_OTERM477 | osd:hdmi_osd / pixsz[2] | 0.098 | 0.483 |
| 19 | 0.388 | vga_out:vga_scaler_out / altshift_taps:din1_rtl_0 / shift_taps_quu:auto_generated / altsyncram_dr91:altsyncram4 / ram_block5a23 | d[7] | 0.804 | 1.192 |
| 20 | 0.389 | vga_out:vga_scaler_out / altshift_taps:din1_rtl_0 / shift_taps_quu:auto_generated / altsyncram_dr91:altsyncram4 / ram_block5a12 | d[18] | 0.759 | 1.148 |
| 21 | 0.391 | vga_out:vga_scaler_out / altshift_taps:din1_rtl_0 / shift_taps_quu:auto_generated / altsyncram_dr91:altsyncram4 / ram_block5a9 | d[21] | 0.802 | 1.193 |
| 22 | 0.392 | vga_out:vga_scaler_out / altshift_taps:din1_rtl_0 / shift_taps_quu:auto_generated / altsyncram_dr91:altsyncram4 / ram_block5a30 | d[0] | 0.807 | 1.199 |
| 23 | 0.394 | ascal:ascal / o_vpixq_pre[0].g[1] | ascal:ascal / o_vpixq[0].g[1] | 0.462 | 0.856 |
| 24 | 0.395 | ascal:ascal / o_vpixq_pre[2].g[5] | ascal:ascal / o_vpixq[2].g[5] | 0.45 | 0.845 |
| 25 | 0.397 | ascal:ascal / o_hpixq[7][3].r[3] | ascal:ascal / o_hpixq[8][3].r[3] | 0.414 | 0.811 |
| 26 | 0.397 | vga_out:vga_scaler_out / altshift_taps:din1_rtl_0 / shift_taps_quu:auto_generated / altsyncram_dr91:altsyncram4 / ram_block5a21 | d[9] | 0.746 | 1.143 |
| 27 | 0.399 | vga_out:vga_scaler_out / altshift_taps:din1_rtl_0 / shift_taps_quu:auto_generated / altsyncram_dr91:altsyncram4 / ram_block5a20 | d[10] | 0.752 | 1.151 |
| 28 | 0.402 | ascal:ascal / o_vpixq_pre[0].r[0] | ascal:ascal / o_vpixq[0].r[0] | 0.811 | 1.213 |
| 29 | 0.408 | vga_out:vga_scaler_out / altshift_taps:din1_rtl_0 / shift_taps_quu:auto_generated / altsyncram_dr91:altsyncram4 / ram_block5a27 | d[3] | 0.809 | 1.217 |
| 30 | 0.41 | ascal:ascal / o_vpixq_pre[0].b[2] | ascal:ascal / o_vpixq[0].b[2] | 0.466 | 0.876 |
| 31 | 0.412 | hdmi_dv_hs | hs | 0.506 | 0.918 |
| 32 | 0.414 | ascal:ascal / o_vpixq_pre[1].g[0] | ascal:ascal / o_vpixq[1].g[0] | 0.456 | 0.87 |
| 33 | 0.415 | ascal:ascal / o_vpixq_pre[1].r[1] | ascal:ascal / o_vpixq[1].r[1] | 0.804 | 1.219 |
| 34 | 0.416 | ascal:ascal / o_vcpt_sync[0] | ascal:ascal / o_vcpt_sync[0] | 0.111 | 0.527 |
| 35 | 0.418 | ascal:ascal / o_vcpt_sync[3] | ascal:ascal / o_vcpt_sync[3] | 0.112 | 0.53 |
| 36 | 0.421 | ascal:ascal / o_vpixq_pre[1].r[6] | ascal:ascal / o_vpixq[1].r[6] | 0.805 | 1.226 |
| 37 | 0.421 | ascal:ascal / o_vpixq_pre[0].r[7] | ascal:ascal / o_vpixq[0].r[7] | 0.455 | 0.876 |
| 38 | 0.422 | ascal:ascal / o_hacpt[5] | ascal:ascal / o_hacpt[5] | 0.11 | 0.532 |
| 39 | 0.422 | ascal:ascal / o_dev[8] | ascal:ascal / o_dev[9] | 0.109 | 0.531 |
| 40 | 0.422 | ascal:ascal / o_vpixq_pre[0].g[3] | ascal:ascal / o_vpixq[0].g[3] | 0.462 | 0.884 |
| 41 | 0.423 | vga_out:vga_scaler_out / altshift_taps:din1_rtl_0 / shift_taps_quu:auto_generated / altsyncram_dr91:altsyncram4 / ram_block5a19 | vga_out:vga_scaler_out / pr_1g[4] | 0.364 | 0.787 |
| 42 | 0.424 | ascal:ascal / o_hacpt[0] | ascal:ascal / o_hacpt[0] | 0.109 | 0.533 |
| 43 | 0.424 | ascal:ascal / o_vacpt[3] | ascal:ascal / o_vacpt[3] | 0.111 | 0.535 |
| 44 | 0.425 | ascal:ascal / o_vdivr[9] | ascal:ascal / o_vdivr[10] | 0.124 | 0.549 |
| 45 | 0.425 | ascal:ascal / o_vpixq_pre[2].r[6] | ascal:ascal / o_vpixq[2].r[6] | 0.47 | 0.895 |
| 46 | 0.425 | ascal:ascal / o_hpix3.r[0] | ascal:ascal / o_hpixq[2][0].r[0] | 0.126 | 0.551 |
| 47 | 0.425 | ascal:ascal / o_hpixq[5][0].g[0] | ascal:ascal / o_hpixq[6][0].g[0] | 0.1 | 0.525 |
| 48 | 0.425 | ascal:ascal / o_vpixq_pre[0].r[3] | ascal:ascal / o_vpixq[0].r[3] | 0.453 | 0.878 |
| 49 | 0.426 | ascal:ascal / o_lastt2 | ascal:ascal / o_lastt3 | 0.11 | 0.536 |
| 50 | 0.428 | ascal:ascal / o_hsv[6] | ascal:ascal / o_hsv[7] | 0.109 | 0.537 |

## core_hold

### baseline2

| Rank | Slack ns | From | To | Skew ns | Data ns |
| --- | --- | --- | --- | --- | --- |
| 1 | 0.235 | emu:emu / system:system / vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:61:shifter / shift0[6] | emu:emu / system:system / vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:61:shifter / shift0[7] | 0.107 | 0.342 |
| 2 | 0.244 | emu:emu / savestates:savestates_inst / flush_cnt[2] | emu:emu / savestates:savestates_inst / flush_cnt[2] | 0.112 | 0.356 |
| 3 | 0.244 | emu:emu / system:system / vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:61:shifter / shift2[5] | emu:emu / system:system / vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:61:shifter / shift2[6] | 0.113 | 0.357 |
| 4 | 0.245 | emu:emu / sd_lba[2] | emu:emu / sd_lba[2] | 0.111 | 0.356 |
| 5 | 0.248 | emu:emu / savestates:savestates_inst / nvram_save_addr[2] | emu:emu / savestates:savestates_inst / nvram_save_addr[2] | 0.114 | 0.362 |
| 6 | 0.248 | sys_umuldiv:ar_muldiv / sys_umul:umul / result[4] | sys_umuldiv:ar_muldiv / sys_umul:umul / result[4] | 0.115 | 0.363 |
| 7 | 0.248 | emu:emu / sd_lba[22] | emu:emu / sd_lba[22] | 0.115 | 0.363 |
| 8 | 0.249 | emu:emu / video_freak:video_freak / sys_umul:mul / result[14]~DUPLICATE | emu:emu / video_freak:video_freak / sys_umul:mul / result[14] | 0.115 | 0.364 |
| 9 | 0.25 | sys_umuldiv:ar_muldiv / sys_udiv:udiv / rem[29] | sys_umuldiv:ar_muldiv / sys_udiv:udiv / rem[30] | 0.108 | 0.358 |
| 10 | 0.25 | sys_umuldiv:ar_muldiv / sys_umul:umul / result[14] | sys_umuldiv:ar_muldiv / sys_umul:umul / result[14] | 0.113 | 0.363 |
| 11 | 0.251 | emu:emu / savestates:savestates_inst / flush_cnt[14] | emu:emu / savestates:savestates_inst / flush_cnt[14] | 0.112 | 0.363 |
| 12 | 0.252 | emu:emu / system:system / vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:49:shifter / shift2[1] | emu:emu / system:system / vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:49:shifter / shift2[2] | 0.115 | 0.367 |
| 13 | 0.252 | emu:emu / savestates:savestates_inst / op_cooldown[12] | emu:emu / savestates:savestates_inst / op_cooldown[12] | 0.111 | 0.363 |
| 14 | 0.252 | yc_out:yc_out / cburst_phase[2] | yc_out:yc_out / cburst_phase[2] | 0.114 | 0.366 |
| 15 | 0.252 | emu:emu / savestates:savestates_inst / ss_change_det[23] | emu:emu / savestates:savestates_inst / ss_change_det[23] | 0.111 | 0.363 |
| 16 | 0.252 | ascal:ascal / i_vdivr[16] | ascal:ascal / i_vdivr[17] | 0.111 | 0.363 |
| 17 | 0.252 | emu:emu / sd_lba[14] | emu:emu / sd_lba[14] | 0.111 | 0.363 |
| 18 | 0.253 | emu:emu / savestates:savestates_inst / ss_change_det[3] | emu:emu / savestates:savestates_inst / ss_change_det[3] | 0.109 | 0.362 |
| 19 | 0.253 | emu:emu / timeout[23] | emu:emu / timeout[23] | 0.113 | 0.366 |
| 20 | 0.254 | emu:emu / savestates:savestates_inst / ss_change_det[15] | emu:emu / savestates:savestates_inst / ss_change_det[15] | 0.109 | 0.363 |
| 21 | 0.255 | emu:emu / video_freak:video_freak / sys_umul:mul / result[14]~DUPLICATE | emu:emu / video_freak:video_freak / sys_umul:mul / result[14]~DUPLICATE | 0.111 | 0.366 |
| 22 | 0.256 | emu:emu / savestates:savestates_inst / flush_cnt[17] | emu:emu / savestates:savestates_inst / flush_cnt[17] | 0.112 | 0.368 |
| 23 | 0.257 | emu:emu / timeout[15] | emu:emu / timeout[15] | 0.112 | 0.369 |
| 24 | 0.258 | emu:emu / video_freak:video_freak / video_scale_int:scale / sys_udiv:div / rem[32] | emu:emu / video_freak:video_freak / video_scale_int:scale / sys_udiv:div / rem[33] | 0.116 | 0.374 |
| 25 | 0.259 | emu:emu / system:system / vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:49:shifter / shift2[1] | emu:emu / system:system / vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:49:shifter / shift2[2]~DUPLICATE | 0.107 | 0.366 |
| 26 | 0.259 | emu:emu / video_freak:video_freak / video_scale_int:scale / sys_udiv:div / rem[29] | emu:emu / video_freak:video_freak / video_scale_int:scale / sys_udiv:div / rem[30] | 0.105 | 0.364 |
| 27 | 0.259 | emu:emu / savestates:savestates_inst / ss_change_det[5] | emu:emu / savestates:savestates_inst / ss_change_det[5] | 0.109 | 0.368 |
| 28 | 0.26 | emu:emu / savestates:savestates_inst / wram_load_addr[4] | emu:emu / savestates:savestates_inst / wram_load_addr[4] | 0.115 | 0.375 |
| 29 | 0.26 | emu:emu / video_freak:video_freak / video_scale_int:scale / sys_umul:mul / result[14] | emu:emu / video_freak:video_freak / video_scale_int:scale / sys_umul:mul / result[14] | 0.112 | 0.372 |
| 30 | 0.26 | emu:emu / screen_rotate:screen_rotate / hcnt[6]~reg1 | emu:emu / screen_rotate:screen_rotate / hcnt[6]~reg1 | 0.114 | 0.374 |
| 31 | 0.262 | emu:emu / sega_controller:controller_p2 / timer[4] | emu:emu / sega_controller:controller_p2 / timer[4] | 0.111 | 0.373 |
| 32 | 0.262 | emu:emu / video_freak:video_freak / sys_umul:mul / result[21] | emu:emu / video_freak:video_freak / sys_umul:mul / result[21] | 0.112 | 0.374 |
| 33 | 0.262 | emu:emu / video_freak:video_freak / video_scale_int:scale / sys_udiv:div / rem[30] | emu:emu / video_freak:video_freak / video_scale_int:scale / sys_udiv:div / rem[31] | 0.116 | 0.378 |
| 34 | 0.262 | emu:emu / timeout[18] | emu:emu / timeout[18] | 0.112 | 0.374 |
| 35 | 0.263 | emu:emu / sd_lba[17] | emu:emu / sd_lba[17] | 0.111 | 0.374 |
| 36 | 0.263 | emu:emu / timeout[25] | emu:emu / timeout[25] | 0.113 | 0.376 |
| 37 | 0.264 | yc_out:yc_out / cburst_phase[4] | yc_out:yc_out / cburst_phase[4] | 0.114 | 0.378 |
| 38 | 0.265 | sys_umuldiv:ar_muldiv / sys_udiv:udiv / rem[32] | sys_umuldiv:ar_muldiv / sys_udiv:udiv / rem[33] | 0.111 | 0.376 |
| 39 | 0.267 | sync_fix:sync_h / cnt[24] | sync_fix:sync_h / cnt[24] | 0.095 | 0.362 |
| 40 | 0.267 | sync_fix:sync_h / cnt[4] | sync_fix:sync_h / cnt[4] | 0.095 | 0.362 |
| 41 | 0.267 | emu:emu / savestates:savestates_inst / ss_change_det[25] | emu:emu / savestates:savestates_inst / ss_change_det[25] | 0.111 | 0.378 |
| 42 | 0.269 | emu:emu / ram_clr_addr[2] | emu:emu / ram_clr_addr[2] | 0.097 | 0.366 |
| 43 | 0.269 | emu:emu / savestates:savestates_inst / op_cooldown[14] | emu:emu / savestates:savestates_inst / op_cooldown[14] | 0.111 | 0.38 |
| 44 | 0.27 | sys_umuldiv:ar_muldiv / sys_udiv:udiv / rem[27] | sys_umuldiv:ar_muldiv / sys_udiv:udiv / rem[28] | 0.108 | 0.378 |
| 45 | 0.27 | line_cnt[4] | line_cnt[4] | 0.115 | 0.385 |
| 46 | 0.273 | emu:emu / sd_lba[24] | emu:emu / sd_lba[24] | 0.115 | 0.388 |
| 47 | 0.274 | emu:emu / system:system / opll:fm / TemporalMixer:tm / mix[10]~DUPLICATE | emu:emu / system:system / opll:fm / TemporalMixer:tm / mix[10]~DUPLICATE | 0.113 | 0.387 |
| 48 | 0.275 | emu:emu / savestates:savestates_inst / op_cooldown[4] | emu:emu / savestates:savestates_inst / op_cooldown[4] | 0.114 | 0.389 |
| 49 | 0.276 | emu:emu / ram_clr_addr[4] | emu:emu / ram_clr_addr[4] | 0.097 | 0.373 |
| 50 | 0.276 | yc_out:yc_out / phase_accum[17] | yc_out:yc_out / phase_accum[17] | 0.096 | 0.372 |

### candidate2

| Rank | Slack ns | From | To | Skew ns | Data ns |
| --- | --- | --- | --- | --- | --- |
| 1 | 0.238 | emu:emu / system:system / vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:38:shifter / shift0[6] | emu:emu / system:system / vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:38:shifter / shift0[7] | 0.108 | 0.346 |
| 2 | 0.24 | emu:emu / system:system / vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:36:shifter / shift0[1] | emu:emu / system:system / vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:36:shifter / shift0[2] | 0.115 | 0.355 |
| 3 | 0.242 | emu:emu / system:system / vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:35:shifter / shift1[3] | emu:emu / system:system / vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:35:shifter / shift1[4]~DUPLICATE | 0.108 | 0.35 |
| 4 | 0.242 | emu:emu / system:system / vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:62:shifter / shift0[6] | emu:emu / system:system / vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:62:shifter / shift0[7] | 0.109 | 0.351 |
| 5 | 0.242 | emu:emu / savestates:savestates_inst / nvram_load_addr[2] | emu:emu / savestates:savestates_inst / nvram_load_addr[2] | 0.114 | 0.356 |
| 6 | 0.243 | emu:emu / system:system / vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:29:shifter / shift0[3] | emu:emu / system:system / vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:29:shifter / shift0[4] | 0.111 | 0.354 |
| 7 | 0.243 | emu:emu / sd_lba[2] | emu:emu / sd_lba[2] | 0.113 | 0.356 |
| 8 | 0.244 | emu:emu / system:system / vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:51:shifter / shift1[2] | emu:emu / system:system / vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:51:shifter / shift1[3] | 0.116 | 0.36 |
| 9 | 0.244 | sys_umuldiv:ar_muldiv / sys_udiv:udiv / rem[29] | sys_umuldiv:ar_muldiv / sys_udiv:udiv / rem[30] | 0.112 | 0.356 |
| 10 | 0.244 | emu:emu / savestates:savestates_inst / ss_change_det[15] | emu:emu / savestates:savestates_inst / ss_change_det[15] | 0.109 | 0.353 |
| 11 | 0.245 | emu:emu / system:system / vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:38:shifter / shift0[6] | emu:emu / system:system / vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:38:shifter / shift0[7]~DUPLICATE | 0.103 | 0.348 |
| 12 | 0.245 | emu:emu / video_freak:video_freak / sys_umul:mul / result[14] | emu:emu / video_freak:video_freak / sys_umul:mul / result[14]~DUPLICATE | 0.119 | 0.364 |
| 13 | 0.245 | emu:emu / savestates:savestates_inst / ss_change_det[23] | emu:emu / savestates:savestates_inst / ss_change_det[23] | 0.111 | 0.356 |
| 14 | 0.246 | emu:emu / system:system / vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:35:shifter / shift1[5] | emu:emu / system:system / vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:35:shifter / shift1[6]~DUPLICATE | 0.108 | 0.354 |
| 15 | 0.246 | emu:emu / system:system / vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:43:shifter / shift1[5] | emu:emu / system:system / vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:43:shifter / shift1[6] | 0.114 | 0.36 |
| 16 | 0.246 | emu:emu / savestates:savestates_inst / flush_cnt[2] | emu:emu / savestates:savestates_inst / flush_cnt[2] | 0.112 | 0.358 |
| 17 | 0.247 | emu:emu / system:system / vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:10:shifter / shift2[2] | emu:emu / system:system / vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:10:shifter / shift2[3]~DUPLICATE | 0.107 | 0.354 |
| 18 | 0.247 | emu:emu / savestates:savestates_inst / ss_change_det[3] | emu:emu / savestates:savestates_inst / ss_change_det[3] | 0.109 | 0.356 |
| 19 | 0.248 | emu:emu / system:system / vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:60:shifter / shift1[4] | emu:emu / system:system / vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:60:shifter / shift1[5] | 0.108 | 0.356 |
| 20 | 0.249 | emu:emu / system:system / vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:35:shifter / shift1[3] | emu:emu / system:system / vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:35:shifter / shift1[4] | 0.103 | 0.352 |
| 21 | 0.249 | emu:emu / system:system / vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:13:shifter / shift1[4] | emu:emu / system:system / vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:13:shifter / shift1[5]~DUPLICATE | 0.109 | 0.358 |
| 22 | 0.25 | emu:emu / system:system / vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:29:shifter / shift0[3] | emu:emu / system:system / vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:29:shifter / shift0[4]~DUPLICATE | 0.106 | 0.356 |
| 23 | 0.25 | emu:emu / sd_lba[14] | emu:emu / sd_lba[14] | 0.113 | 0.363 |
| 24 | 0.251 | emu:emu / system:system / vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:54:shifter / shift0[3] | emu:emu / system:system / vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:54:shifter / shift0[4] | 0.115 | 0.366 |
| 25 | 0.251 | emu:emu / video_freak:video_freak / sys_umul:mul / result[14] | emu:emu / video_freak:video_freak / sys_umul:mul / result[14] | 0.115 | 0.366 |
| 26 | 0.252 | emu:emu / system:system / vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:35:shifter / shift2[4] | emu:emu / system:system / vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:35:shifter / shift2[5] | 0.114 | 0.366 |
| 27 | 0.252 | emu:emu / system:system / vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:62:shifter / shift0[5] | emu:emu / system:system / vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:62:shifter / shift0[6] | 0.116 | 0.368 |
| 28 | 0.252 | emu:emu / savestates:savestates_inst / nvram_save_addr[2] | emu:emu / savestates:savestates_inst / nvram_save_addr[2] | 0.114 | 0.366 |
| 29 | 0.252 | emu:emu / hps_io:hps_io / video_calc:video_calc / ccnt[14] | emu:emu / hps_io:hps_io / video_calc:video_calc / ccnt[14] | 0.112 | 0.364 |
| 30 | 0.253 | emu:emu / system:system / mapper_detect:mapper_detect_inst / mapper_detect_ticks[2] | emu:emu / system:system / mapper_detect:mapper_detect_inst / mapper_detect_ticks[2] | 0.109 | 0.362 |
| 31 | 0.253 | emu:emu / system:system / vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:43:shifter / shift1[5] | emu:emu / system:system / vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:43:shifter / shift1[6]~DUPLICATE | 0.106 | 0.359 |
| 32 | 0.253 | emu:emu / system:system / vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:35:shifter / shift1[5] | emu:emu / system:system / vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:35:shifter / shift1[6] | 0.103 | 0.356 |
| 33 | 0.253 | emu:emu / savestates:savestates_inst / flush_cnt[14] | emu:emu / savestates:savestates_inst / flush_cnt[14] | 0.112 | 0.365 |
| 34 | 0.254 | emu:emu / system:system / vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:31:shifter / shift1[4] | emu:emu / system:system / vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:31:shifter / shift1[5]~DUPLICATE | 0.115 | 0.369 |
| 35 | 0.254 | emu:emu / system:system / vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:10:shifter / shift2[2] | emu:emu / system:system / vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:10:shifter / shift2[3] | 0.102 | 0.356 |
| 36 | 0.254 | emu:emu / savestates:savestates_inst / nvram_load_addr[4] | emu:emu / savestates:savestates_inst / nvram_load_addr[4] | 0.114 | 0.368 |
| 37 | 0.255 | emu:emu / sd_lba[4] | emu:emu / sd_lba[4] | 0.113 | 0.368 |
| 38 | 0.255 | sys_umuldiv:ar_muldiv / sys_umul:umul / result[14] | sys_umuldiv:ar_muldiv / sys_umul:umul / result[14] | 0.113 | 0.368 |
| 39 | 0.255 | ascal:ascal / i_vdivr[16] | ascal:ascal / i_vdivr[17] | 0.107 | 0.362 |
| 40 | 0.256 | emu:emu / system:system / vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:26:shifter / shift0[2] | emu:emu / system:system / vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:26:shifter / shift0[3] | 0.119 | 0.375 |
| 41 | 0.256 | emu:emu / system:system / vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:13:shifter / shift1[4] | emu:emu / system:system / vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:13:shifter / shift1[5] | 0.104 | 0.36 |
| 42 | 0.256 | emu:emu / savestates:savestates_inst / op_cooldown[14] | emu:emu / savestates:savestates_inst / op_cooldown[14] | 0.112 | 0.368 |
| 43 | 0.257 | emu:emu / soft_reset_cnt[4] | emu:emu / soft_reset_cnt[4] | 0.11 | 0.367 |
| 44 | 0.257 | emu:emu / video_freak:video_freak / video_scale_int:scale / sys_udiv:div / rem[29] | emu:emu / video_freak:video_freak / video_scale_int:scale / sys_udiv:div / rem[30] | 0.109 | 0.366 |
| 45 | 0.258 | emu:emu / video_freak:video_freak / video_scale_int:scale / sys_umul:mul / result[14] | emu:emu / video_freak:video_freak / video_scale_int:scale / sys_umul:mul / result[14]~DUPLICATE | 0.12 | 0.378 |
| 46 | 0.259 | emu:emu / system:system / vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:62:shifter / shift0[5] | emu:emu / system:system / vdp:vdp_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:62:shifter / shift0[6]~DUPLICATE | 0.108 | 0.367 |
| 47 | 0.259 | emu:emu / savestates:savestates_inst / op_cooldown[12] | emu:emu / savestates:savestates_inst / op_cooldown[12] | 0.112 | 0.371 |
| 48 | 0.26 | yc_out:yc_out / cburst_phase[2] | yc_out:yc_out / cburst_phase[2] | 0.111 | 0.371 |
| 49 | 0.26 | emu:emu / timeout[15] | emu:emu / timeout[15] | 0.109 | 0.369 |
| 50 | 0.261 | emu:emu / system:system / vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:31:shifter / shift1[4] | emu:emu / system:system / vdp:vdp2_inst / vdp_main:vdp_main_inst / vdp_sprites:vdp_spr_inst / vpd_sprite_shifter:\shifters:31:shifter / shift1[5] | 0.107 | 0.368 |

## hcnt

### baseline2

| Rank | Slack ns | From | To | Skew ns | Data ns |
| --- | --- | --- | --- | --- | --- |
| 1 | 3.1 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[2] | -0.235 | 3.197 |
| 2 | 3.1 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[5]~DUPLICATE | -0.237 | 3.195 |
| 3 | 3.1 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[8] | -0.235 | 3.197 |
| 4 | 3.1 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[9] | -0.237 | 3.195 |
| 5 | 3.1 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[4] | -0.235 | 3.197 |
| 6 | 3.105 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[5] | -0.23 | 3.197 |
| 7 | 3.105 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[9]~DUPLICATE | -0.23 | 3.197 |
| 8 | 3.106 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[4]~DUPLICATE | -0.231 | 3.195 |
| 9 | 3.106 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[2]~DUPLICATE | -0.231 | 3.195 |
| 10 | 3.106 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[8]~DUPLICATE | -0.231 | 3.195 |
| 11 | 3.109 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[3] | -0.237 | 3.186 |
| 12 | 3.109 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[1] | -0.237 | 3.186 |
| 13 | 3.114 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[7] | -0.23 | 3.188 |
| 14 | 3.115 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[0] | -0.231 | 3.186 |
| 15 | 3.115 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[6] | -0.231 | 3.186 |
| 16 | 3.118 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[22] | -0.258 | 3.156 |
| 17 | 3.118 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[14] | -0.258 | 3.156 |
| 18 | 3.119 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[15]~DUPLICATE | -0.259 | 3.154 |
| 19 | 3.123 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[22]~DUPLICATE | -0.255 | 3.154 |
| 20 | 3.123 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[15] | -0.253 | 3.156 |
| 21 | 3.123 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[14]~DUPLICATE | -0.255 | 3.154 |
| 22 | 3.127 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[20] | -0.258 | 3.147 |
| 23 | 3.128 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[23] | -0.259 | 3.145 |
| 24 | 3.128 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[11] | -0.259 | 3.145 |
| 25 | 3.128 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[19] | -0.259 | 3.145 |
| 26 | 3.132 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[21] | -0.253 | 3.147 |
| 27 | 3.132 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[13] | -0.253 | 3.147 |
| 28 | 3.132 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[12] | -0.255 | 3.145 |
| 29 | 3.132 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[10] | -0.255 | 3.145 |
| 30 | 3.132 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[16] | -0.255 | 3.145 |
| 31 | 3.132 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[18] | -0.255 | 3.145 |
| 32 | 3.132 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[17] | -0.253 | 3.147 |

### candidate2

| Rank | Slack ns | From | To | Skew ns | Data ns |
| --- | --- | --- | --- | --- | --- |
| 1 | 2.679 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[8] | -0.194 | 3.659 |
| 2 | 2.679 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[7] | -0.196 | 3.657 |
| 3 | 2.679 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[4]~DUPLICATE | -0.194 | 3.659 |
| 4 | 2.679 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[9] | -0.196 | 3.657 |
| 5 | 2.679 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[5]~DUPLICATE | -0.196 | 3.657 |
| 6 | 2.684 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[9]~DUPLICATE | -0.189 | 3.659 |
| 7 | 2.684 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[7]~DUPLICATE | -0.189 | 3.659 |
| 8 | 2.684 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[5] | -0.189 | 3.659 |
| 9 | 2.685 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[8]~DUPLICATE | -0.19 | 3.657 |
| 10 | 2.685 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[4] | -0.19 | 3.657 |
| 11 | 2.688 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[1] | -0.196 | 3.648 |
| 12 | 2.688 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[0] | -0.194 | 3.65 |
| 13 | 2.688 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[6] | -0.194 | 3.65 |
| 14 | 2.688 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[2] | -0.194 | 3.65 |
| 15 | 2.693 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[3] | -0.189 | 3.65 |
| 16 | 3.205 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[17]~DUPLICATE | -0.234 | 3.093 |
| 17 | 3.205 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[15]~DUPLICATE | -0.234 | 3.093 |
| 18 | 3.208 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[15] | -0.228 | 3.096 |
| 19 | 3.208 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[17] | -0.228 | 3.096 |
| 20 | 3.213 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[10] | -0.233 | 3.086 |
| 21 | 3.213 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[18] | -0.233 | 3.086 |
| 22 | 3.213 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[22] | -0.233 | 3.086 |
| 23 | 3.214 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[11] | -0.234 | 3.084 |
| 24 | 3.214 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[19] | -0.234 | 3.084 |
| 25 | 3.214 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[21] | -0.234 | 3.084 |
| 26 | 3.214 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[23] | -0.234 | 3.084 |
| 27 | 3.218 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[14] | -0.23 | 3.084 |
| 28 | 3.218 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[13] | -0.228 | 3.086 |
| 29 | 3.218 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[12] | -0.23 | 3.084 |
| 30 | 3.218 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[16] | -0.23 | 3.084 |
| 31 | 3.218 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / h_cnt[20] | -0.23 | 3.084 |

## width

### baseline2

| Rank | Slack ns | From | To | Skew ns | Data ns |
| --- | --- | --- | --- | --- | --- |
| 1 | 2.829 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[20] | -0.259 | 3.444 |
| 2 | 2.833 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[21] | -0.255 | 3.444 |
| 3 | 2.967 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[2] | -0.25 | 3.315 |
| 4 | 2.971 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[4] | -0.246 | 3.315 |
| 5 | 2.971 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[1] | -0.246 | 3.315 |
| 6 | 2.971 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[0] | -0.246 | 3.315 |
| 7 | 3.014 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[6] | -0.239 | 3.279 |
| 8 | 3.018 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[7] | -0.235 | 3.279 |
| 9 | 3.018 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[5] | -0.235 | 3.279 |
| 10 | 3.018 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[3] | -0.235 | 3.279 |
| 11 | 3.023 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[15] | -0.249 | 3.26 |
| 12 | 3.038 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[18] | -0.248 | 3.246 |
| 13 | 3.038 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[16] | -0.248 | 3.246 |
| 14 | 3.239 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[17] | -0.241 | 3.052 |
| 15 | 3.239 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[14] | -0.241 | 3.052 |
| 16 | 3.239 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[12] | -0.241 | 3.052 |
| 17 | 3.239 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[9] | -0.241 | 3.052 |
| 18 | 3.243 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[19] | -0.237 | 3.052 |
| 19 | 3.243 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[13] | -0.237 | 3.052 |
| 20 | 3.243 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[11] | -0.237 | 3.052 |
| 21 | 3.243 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[10] | -0.237 | 3.052 |
| 22 | 3.243 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[8] | -0.237 | 3.052 |

### candidate2

| Rank | Slack ns | From | To | Skew ns | Data ns |
| --- | --- | --- | --- | --- | --- |
| 1 | 2.673 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[15] | -0.209 | 3.65 |
| 2 | 2.678 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[19] | -0.204 | 3.65 |
| 3 | 2.678 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[18] | -0.204 | 3.65 |
| 4 | 2.678 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[17] | -0.204 | 3.65 |
| 5 | 2.858 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[11] | -0.21 | 3.464 |
| 6 | 2.858 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[9] | -0.21 | 3.464 |
| 7 | 2.858 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[8] | -0.21 | 3.464 |
| 8 | 2.858 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[13] | -0.21 | 3.464 |
| 9 | 2.862 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[12] | -0.206 | 3.464 |
| 10 | 2.862 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[10] | -0.206 | 3.464 |
| 11 | 2.862 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[6] | -0.206 | 3.464 |
| 12 | 2.862 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[14] | -0.206 | 3.464 |
| 13 | 2.866 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[20] | -0.204 | 3.462 |
| 14 | 3.081 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[2] | -0.21 | 3.241 |
| 15 | 3.085 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[1] | -0.206 | 3.241 |
| 16 | 3.085 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[0] | -0.206 | 3.241 |
| 17 | 3.385 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[5] | -0.211 | 2.936 |
| 18 | 3.385 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[4] | -0.211 | 2.936 |
| 19 | 3.385 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[21] | -0.211 | 2.936 |
| 20 | 3.389 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[7] | -0.207 | 2.936 |
| 21 | 3.389 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[3] | -0.207 | 2.936 |
| 22 | 3.389 | shadowmask:HDMI_shadowmask / altshift_taps:vid_rtl_0 / shift_taps_0vu:auto_generated / altsyncram_pr91:altsyncram4 / ram_block5a0 | osd:hdmi_osd / dsp_width[16] | -0.207 | 2.936 |

## dir

### baseline2

| Rank | Slack ns | From | To | Skew ns | Data ns |
| --- | --- | --- | --- | --- | --- |
| 1 | 12.637 | emu:emu / savestates:savestates_inst / z80_dir[185] | emu:emu / system:system / T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[2][1] | -0.385 | 5.274 |
| 2 | 12.641 | emu:emu / savestates:savestates_inst / z80_dir[185] | emu:emu / system:system / T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[6][1] | -0.379 | 5.276 |
| 3 | 12.867 | emu:emu / savestates:savestates_inst / z80_dir[37] | emu:emu / system:system / T80s:z80_inst / T80:u0 / I[5] | -0.39 | 5.039 |
| 4 | 13.439 | emu:emu / savestates:savestates_inst / z80_dir[163] | emu:emu / system:system / T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsL[5][3] | -0.452 | 4.405 |
| 5 | 13.471 | emu:emu / savestates:savestates_inst / z80_dir[163] | emu:emu / system:system / T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsL[1][3] | -0.446 | 4.379 |
| 6 | 13.572 | emu:emu / savestates:savestates_inst / z80_dir[77] | emu:emu / system:system / T80s:z80_inst / T80:u0 / A[13] | -0.525 | 4.199 |
| 7 | 13.578 | emu:emu / savestates:savestates_inst / z80_dir[77] | emu:emu / system:system / T80s:z80_inst / T80:u0 / A[13]~DUPLICATE | -0.521 | 4.197 |
| 8 | 13.855 | emu:emu / savestates:savestates_inst / z80_dir[78] | emu:emu / system:system / T80s:z80_inst / T80:u0 / A[14]~DUPLICATE | -0.509 | 3.932 |
| 9 | 13.86 | emu:emu / savestates:savestates_inst / z80_dir[78] | emu:emu / system:system / T80s:z80_inst / T80:u0 / A[14] | -0.502 | 3.934 |
| 10 | 13.962 | emu:emu / savestates:savestates_inst / z80_dir[71] | emu:emu / system:system / T80s:z80_inst / T80:u0 / A[7] | -0.532 | 3.802 |
| 11 | 13.969 | emu:emu / savestates:savestates_inst / z80_dir[71] | emu:emu / system:system / T80s:z80_inst / T80:u0 / A[7]~DUPLICATE | -0.528 | 3.799 |
| 12 | 13.981 | emu:emu / savestates:savestates_inst / z80_dir[3] | emu:emu / system:system / T80s:z80_inst / T80:u0 / ACC[3] | -0.056 | 4.259 |
| 13 | 14.019 | emu:emu / savestates:savestates_inst / z80_dir[67] | emu:emu / system:system / T80s:z80_inst / T80:u0 / A[3] | -0.47 | 3.807 |
| 14 | 14.026 | emu:emu / savestates:savestates_inst / z80_dir[67] | emu:emu / system:system / T80s:z80_inst / T80:u0 / A[3]~DUPLICATE | -0.466 | 3.804 |
| 15 | 14.045 | emu:emu / savestates:savestates_inst / z80_dir[97] | emu:emu / system:system / T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsL[5][1] | -0.581 | 3.67 |
| 16 | 14.08 | emu:emu / savestates:savestates_inst / z80_dir[68] | emu:emu / system:system / T80s:z80_inst / T80:u0 / A[4]~DUPLICATE | -0.535 | 3.681 |
| 17 | 14.087 | emu:emu / savestates:savestates_inst / z80_dir[68] | emu:emu / system:system / T80s:z80_inst / T80:u0 / A[4] | -0.531 | 3.678 |
| 18 | 14.107 | emu:emu / savestates:savestates_inst / z80_dir[35] | emu:emu / system:system / T80s:z80_inst / T80:u0 / I[3] | -0.483 | 3.706 |
| 19 | 14.368 | emu:emu / savestates:savestates_inst / z80_dir[2] | emu:emu / system:system / T80s:z80_inst / T80:u0 / ACC[2] | -0.072 | 3.856 |
| 20 | 14.389 | emu:emu / savestates:savestates_inst / z80_dir[97] | emu:emu / system:system / T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsL[1][1] | -0.576 | 3.331 |
| 21 | 14.395 | emu:emu / savestates:savestates_inst / z80_dir[97] | emu:emu / system:system / T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsL[1][1]~DUPLICATE | -0.572 | 3.329 |
| 22 | 14.438 | emu:emu / savestates:savestates_inst / z80_dir[102] | emu:emu / system:system / T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsL[1][6]~DUPLICATE | -0.578 | 3.28 |
| 23 | 14.443 | emu:emu / savestates:savestates_inst / z80_dir[33] | emu:emu / system:system / T80s:z80_inst / T80:u0 / I[1] | -0.535 | 3.318 |
| 24 | 14.443 | emu:emu / savestates:savestates_inst / z80_dir[102] | emu:emu / system:system / T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsL[1][6] | -0.571 | 3.282 |
| 25 | 14.453 | emu:emu / savestates:savestates_inst / z80_dir[171] | emu:emu / system:system / T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[1][3] | -0.529 | 3.314 |
| 26 | 14.456 | emu:emu / savestates:savestates_inst / z80_dir[171] | emu:emu / system:system / T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[5][3]~DUPLICATE | -0.525 | 3.315 |
| 27 | 14.457 | emu:emu / savestates:savestates_inst / z80_dir[171] | emu:emu / system:system / T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[1][3]~DUPLICATE | -0.523 | 3.316 |
| 28 | 14.459 | emu:emu / savestates:savestates_inst / z80_dir[171] | emu:emu / system:system / T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[5][3] | -0.52 | 3.317 |
| 29 | 14.467 | emu:emu / savestates:savestates_inst / z80_dir[102] | emu:emu / system:system / T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsL[5][6] | -0.578 | 3.251 |
| 30 | 14.518 | emu:emu / savestates:savestates_inst / z80_dir[1] | emu:emu / system:system / T80s:z80_inst / T80:u0 / ACC[1] | -0.058 | 3.72 |
| 31 | 14.554 | emu:emu / savestates:savestates_inst / z80_dir[67] | emu:emu / system:system / T80s:z80_inst / T80:u0 / PC[3] | -0.083 | 3.659 |
| 32 | 14.56 | emu:emu / savestates:savestates_inst / z80_dir[67] | emu:emu / system:system / T80s:z80_inst / T80:u0 / PC[3]~DUPLICATE | -0.079 | 3.657 |
| 33 | 14.575 | emu:emu / savestates:savestates_inst / z80_dir[196] | emu:emu / system:system / T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsL[7][4] | -0.573 | 3.148 |
| 34 | 14.671 | emu:emu / savestates:savestates_inst / z80_dir[96] | emu:emu / system:system / T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsL[5][0] | -0.512 | 3.113 |
| 35 | 14.715 | emu:emu / savestates:savestates_inst / z80_dir[96] | emu:emu / system:system / T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsL[1][0] | -0.507 | 3.074 |
| 36 | 14.782 | emu:emu / savestates:savestates_inst / z80_dir[70] | emu:emu / system:system / T80s:z80_inst / T80:u0 / A[6] | -0.48 | 3.034 |
| 37 | 14.786 | emu:emu / savestates:savestates_inst / z80_dir[69] | emu:emu / system:system / T80s:z80_inst / T80:u0 / A[5]~DUPLICATE | -0.531 | 2.979 |
| 38 | 14.789 | emu:emu / savestates:savestates_inst / z80_dir[70] | emu:emu / system:system / T80s:z80_inst / T80:u0 / A[6]~DUPLICATE | -0.476 | 3.031 |
| 39 | 14.792 | emu:emu / savestates:savestates_inst / z80_dir[79] | emu:emu / system:system / T80s:z80_inst / T80:u0 / A[15] | -0.518 | 2.986 |
| 40 | 14.793 | emu:emu / savestates:savestates_inst / z80_dir[69] | emu:emu / system:system / T80s:z80_inst / T80:u0 / A[5] | -0.527 | 2.976 |
| 41 | 14.798 | emu:emu / savestates:savestates_inst / z80_dir[79] | emu:emu / system:system / T80s:z80_inst / T80:u0 / A[15]~DUPLICATE | -0.514 | 2.984 |
| 42 | 14.818 | emu:emu / savestates:savestates_inst / z80_dir[111] | emu:emu / system:system / T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[1][7] | -0.518 | 2.96 |
| 43 | 14.831 | emu:emu / savestates:savestates_inst / z80_dir[111] | emu:emu / system:system / T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[5][7] | -0.518 | 2.947 |
| 44 | 14.865 | emu:emu / savestates:savestates_inst / z80_dir[228] | emu:emu / system:system / T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[2][0] | -0.124 | 3.307 |
| 45 | 14.865 | emu:emu / savestates:savestates_inst / z80_dir[228] | emu:emu / system:system / T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[2][3] | -0.12 | 3.311 |
| 46 | 14.87 | emu:emu / savestates:savestates_inst / z80_dir[228] | emu:emu / system:system / T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[2][2] | -0.119 | 3.307 |
| 47 | 14.871 | emu:emu / savestates:savestates_inst / z80_dir[228] | emu:emu / system:system / T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[2][6] | -0.123 | 3.302 |
| 48 | 14.873 | emu:emu / savestates:savestates_inst / z80_dir[228] | emu:emu / system:system / T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[6][2] | -0.12 | 3.303 |
| 49 | 14.873 | emu:emu / savestates:savestates_inst / z80_dir[228] | emu:emu / system:system / T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[2][7] | -0.124 | 3.299 |
| 50 | 14.878 | emu:emu / savestates:savestates_inst / z80_dir[26] | emu:emu / system:system / T80s:z80_inst / T80:u0 / Fp[2] | -0.118 | 3.3 |

## alias

### candidate2

| Rank | Slack ns | From | To | Skew ns | Data ns |
| --- | --- | --- | --- | --- | --- |
| 1 | 14.662 | emu:emu / savestates:savestates_inst / z80_snap[185] | emu:emu / system:system / T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[2][1] | -0.487 | 3.147 |
| 2 | 14.663 | emu:emu / savestates:savestates_inst / z80_snap[11] | emu:emu / system:system / T80s:z80_inst / T80:u0 / F[3] | -0.119 | 3.514 |
| 3 | 14.678 | emu:emu / savestates:savestates_inst / z80_snap[110] | emu:emu / system:system / T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[1][6] | -0.481 | 3.137 |
| 4 | 14.697 | emu:emu / savestates:savestates_inst / z80_snap[185] | emu:emu / system:system / T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[6][1] | -0.489 | 3.11 |
| 5 | 14.732 | emu:emu / savestates:savestates_inst / z80_snap[15] | emu:emu / system:system / T80s:z80_inst / T80:u0 / F[7] | -0.124 | 3.44 |
| 6 | 14.826 | emu:emu / savestates:savestates_inst / z80_snap[1] | emu:emu / system:system / T80s:z80_inst / T80:u0 / ACC[1]~DUPLICATE | -0.143 | 3.327 |
| 7 | 14.829 | emu:emu / savestates:savestates_inst / z80_snap[1] | emu:emu / system:system / T80s:z80_inst / T80:u0 / ACC[1] | -0.138 | 3.329 |
| 8 | 14.838 | emu:emu / savestates:savestates_inst / z80_snap[110] | emu:emu / system:system / T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[5][6] | -0.484 | 2.974 |
| 9 | 14.876 | emu:emu / savestates:savestates_inst / z80_snap[77] | emu:emu / system:system / T80s:z80_inst / T80:u0 / A[13] | -0.121 | 3.299 |
| 10 | 14.926 | emu:emu / savestates:savestates_inst / z80_snap[14] | emu:emu / system:system / T80s:z80_inst / T80:u0 / F[6] | -0.13 | 3.24 |
| 11 | 14.93 | emu:emu / savestates:savestates_inst / z80_snap[159] | emu:emu / system:system / T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[0][7] | -0.481 | 2.885 |
| 12 | 14.957 | emu:emu / savestates:savestates_inst / z80_snap[152] | emu:emu / system:system / T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[4][0] | -0.484 | 2.855 |
| 13 | 15.013 | emu:emu / savestates:savestates_inst / z80_snap[107] | emu:emu / system:system / T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[5][3] | -0.489 | 2.794 |
| 14 | 15.015 | emu:emu / savestates:savestates_inst / z80_snap[8] | emu:emu / system:system / T80s:z80_inst / T80:u0 / F[0] | -0.106 | 3.175 |
| 15 | 15.032 | emu:emu / savestates:savestates_inst / z80_snap[107] | emu:emu / system:system / T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[1][3] | -0.48 | 2.784 |
| 16 | 15.083 | emu:emu / savestates:savestates_inst / z80_snap[0] | emu:emu / system:system / T80s:z80_inst / T80:u0 / ACC[0] | -0.118 | 3.095 |
| 17 | 15.086 | emu:emu / savestates:savestates_inst / z80_snap[152] | emu:emu / system:system / T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[0][0] | -0.476 | 2.734 |
| 18 | 15.089 | emu:emu / savestates:savestates_inst / z80_snap[0] | emu:emu / system:system / T80s:z80_inst / T80:u0 / ACC[0]~DUPLICATE | -0.115 | 3.092 |
| 19 | 15.101 | emu:emu / savestates:savestates_inst / z80_snap[70] | emu:emu / system:system / T80s:z80_inst / T80:u0 / PC[6] | -0.133 | 3.062 |
| 20 | 15.115 | emu:emu / savestates:savestates_inst / z80_snap[87] | emu:emu / system:system / T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsL[4][7] | -0.141 | 3.04 |
| 21 | 15.129 | emu:emu / savestates:savestates_inst / z80_snap[12] | emu:emu / system:system / T80s:z80_inst / T80:u0 / F[4] | -0.119 | 3.048 |
| 22 | 15.137 | emu:emu / savestates:savestates_inst / z80_snap[67] | emu:emu / system:system / T80s:z80_inst / T80:u0 / A[3] | -0.15 | 3.009 |
| 23 | 15.143 | emu:emu / savestates:savestates_inst / z80_snap[67] | emu:emu / system:system / T80s:z80_inst / T80:u0 / A[3]~DUPLICATE | -0.147 | 3.006 |
| 24 | 15.225 | emu:emu / savestates:savestates_inst / z80_snap[10] | emu:emu / system:system / T80s:z80_inst / T80:u0 / F[2] | -0.114 | 2.957 |
| 25 | 15.23 | emu:emu / savestates:savestates_inst / z80_snap[10] | emu:emu / system:system / T80s:z80_inst / T80:u0 / F[2]~DUPLICATE | -0.111 | 2.955 |
| 26 | 15.267 | emu:emu / savestates:savestates_inst / z80_snap[79] | emu:emu / system:system / T80s:z80_inst / T80:u0 / A[15]~DUPLICATE | -0.133 | 2.896 |
| 27 | 15.272 | emu:emu / savestates:savestates_inst / z80_snap[79] | emu:emu / system:system / T80s:z80_inst / T80:u0 / A[15] | -0.126 | 2.898 |
| 28 | 15.282 | emu:emu / savestates:savestates_inst / z80_snap[53] | emu:emu / system:system / T80s:z80_inst / T80:u0 / SP[5] | -0.108 | 2.906 |
| 29 | 15.319 | emu:emu / savestates:savestates_inst / z80_snap[214] | emu:emu / system:system / T80s:z80_inst / T80:u0 / WZ[2] | -0.114 | 2.863 |
| 30 | 15.324 | emu:emu / savestates:savestates_inst / z80_snap[54] | emu:emu / system:system / T80s:z80_inst / T80:u0 / SP[6] | -0.078 | 2.894 |
| 31 | 15.33 | emu:emu / savestates:savestates_inst / z80_snap[87] | emu:emu / system:system / T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsL[0][7] | -0.123 | 2.843 |
| 32 | 15.359 | emu:emu / savestates:savestates_inst / z80_snap[159] | emu:emu / system:system / T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[4][7] | -0.484 | 2.453 |
| 33 | 15.386 | emu:emu / savestates:savestates_inst / z80_snap[78] | emu:emu / system:system / T80s:z80_inst / T80:u0 / A[14]~DUPLICATE | -0.118 | 2.792 |
| 34 | 15.391 | emu:emu / savestates:savestates_inst / z80_snap[78] | emu:emu / system:system / T80s:z80_inst / T80:u0 / A[14] | -0.111 | 2.794 |
| 35 | 15.404 | emu:emu / savestates:savestates_inst / z80_snap[195] | emu:emu / system:system / T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsL[7][3] | -0.112 | 2.78 |
| 36 | 15.427 | emu:emu / savestates:savestates_inst / z80_snap[226] | emu:emu / system:system / T80s:z80_inst / T80:u0 / WZ[14] | -0.1 | 2.769 |
| 37 | 15.434 | emu:emu / savestates:savestates_inst / z80_snap[13] | emu:emu / system:system / T80s:z80_inst / T80:u0 / F[5] | -0.134 | 2.728 |
| 38 | 15.438 | emu:emu / savestates:savestates_inst / z80_snap[2] | emu:emu / system:system / T80s:z80_inst / T80:u0 / ACC[2] | -0.148 | 2.71 |
| 39 | 15.441 | emu:emu / savestates:savestates_inst / z80_snap[6] | emu:emu / system:system / T80s:z80_inst / T80:u0 / ACC[6] | -0.143 | 2.712 |
| 40 | 15.444 | emu:emu / savestates:savestates_inst / z80_snap[2] | emu:emu / system:system / T80s:z80_inst / T80:u0 / ACC[2]~DUPLICATE | -0.145 | 2.707 |
| 41 | 15.447 | emu:emu / savestates:savestates_inst / z80_snap[6] | emu:emu / system:system / T80s:z80_inst / T80:u0 / ACC[6]~DUPLICATE | -0.14 | 2.709 |
| 42 | 15.46 | emu:emu / savestates:savestates_inst / z80_snap[73] | emu:emu / system:system / T80s:z80_inst / T80:u0 / A[9] | -0.139 | 2.697 |
| 43 | 15.488 | emu:emu / savestates:savestates_inst / z80_snap[3] | emu:emu / system:system / T80s:z80_inst / T80:u0 / ACC[3] | -0.129 | 2.679 |
| 44 | 15.496 | emu:emu / savestates:savestates_inst / z80_snap[228] | emu:emu / system:system / T80s:z80_inst / T80:u0 / Alternate | -0.082 | 2.718 |
| 45 | 15.524 | emu:emu / savestates:savestates_inst / z80_snap[25] | emu:emu / system:system / T80s:z80_inst / T80:u0 / Fp[1] | -0.135 | 2.637 |
| 46 | 15.545 | emu:emu / savestates:savestates_inst / z80_snap[228] | emu:emu / system:system / T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[0][5] | -0.087 | 2.664 |
| 47 | 15.558 | emu:emu / savestates:savestates_inst / z80_snap[179] | emu:emu / system:system / T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsL[6][3] | -0.127 | 2.611 |
| 48 | 15.567 | emu:emu / savestates:savestates_inst / z80_snap[64] | emu:emu / system:system / T80s:z80_inst / T80:u0 / PC[0] | -0.109 | 2.62 |
| 49 | 15.572 | emu:emu / savestates:savestates_inst / z80_snap[215] | emu:emu / system:system / T80s:z80_inst / T80:u0 / WZ[3] | -0.122 | 2.602 |
| 50 | 15.572 | emu:emu / savestates:savestates_inst / z80_snap[228] | emu:emu / system:system / T80s:z80_inst / T80:u0 / T80_Reg:Regs / RegsH[4][3] | -0.101 | 2.623 |

## controls

### baseline2

| Rank | Slack ns | From | To | Skew ns | Data ns |
| --- | --- | --- | --- | --- | --- |
| 1 | 9.01 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / IR[5] | -0.447 | 8.839 |
| 2 | 9.234 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / NMICycle | -0.382 | 8.68 |
| 3 | 9.235 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / IR[6]~DUPLICATE | -0.45 | 8.611 |
| 4 | 9.24 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / IR[6] | -0.447 | 8.609 |
| 5 | 9.244 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / IR[7] | -0.444 | 8.608 |
| 6 | 9.272 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / IR[0] | -0.452 | 8.572 |
| 7 | 9.279 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / IR[3] | -0.45 | 8.567 |
| 8 | 9.528 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / NMI_s | -0.378 | 8.39 |
| 9 | 9.786 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / IR[4] | -0.442 | 8.068 |
| 10 | 9.809 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / A[14] | -0.422 | 8.065 |
| 11 | 9.81 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / A[14]~DUPLICATE | -0.429 | 8.057 |
| 12 | 9.81 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / A[15] | -0.427 | 8.059 |
| 13 | 9.81 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / A[13]~DUPLICATE | -0.423 | 8.063 |
| 14 | 9.81 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / A[13] | -0.427 | 8.059 |
| 15 | 9.81 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / A[15]~DUPLICATE | -0.423 | 8.063 |
| 16 | 9.84 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / A[6] | -0.428 | 8.028 |
| 17 | 9.84 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / A[3] | -0.428 | 8.028 |
| 18 | 9.84 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / A[4]~DUPLICATE | -0.428 | 8.028 |
| 19 | 9.84 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / A[5]~DUPLICATE | -0.428 | 8.028 |
| 20 | 9.84 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / A[7] | -0.428 | 8.028 |
| 21 | 9.84 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / A[6]~DUPLICATE | -0.424 | 8.032 |
| 22 | 9.84 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / A[3]~DUPLICATE | -0.424 | 8.032 |
| 23 | 9.84 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / A[4] | -0.424 | 8.032 |
| 24 | 9.84 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / A[7]~DUPLICATE | -0.424 | 8.032 |
| 25 | 9.84 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / A[5] | -0.424 | 8.032 |
| 26 | 9.9 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / WZ[12] | -0.398 | 7.998 |
| 27 | 9.901 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / WZ[12]~DUPLICATE | -0.402 | 7.993 |
| 28 | 10.099 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / A[0] | -0.435 | 7.762 |
| 29 | 10.099 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / A[1] | -0.435 | 7.762 |
| 30 | 10.199 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / A[12] | -0.467 | 7.63 |
| 31 | 10.199 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / A[10]~DUPLICATE | -0.467 | 7.63 |
| 32 | 10.199 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / A[9]~DUPLICATE | -0.465 | 7.632 |
| 33 | 10.199 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / A[11]~DUPLICATE | -0.467 | 7.63 |
| 34 | 10.204 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / A[10] | -0.46 | 7.632 |
| 35 | 10.204 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / A[11] | -0.46 | 7.632 |
| 36 | 10.205 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / A[8] | -0.461 | 7.63 |
| 37 | 10.205 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / A[9] | -0.461 | 7.63 |
| 38 | 10.233 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / A[2] | -0.464 | 7.599 |
| 39 | 10.355 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / IR[2] | -0.447 | 7.494 |
| 40 | 10.459 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / PC[10] | -0.418 | 7.419 |
| 41 | 10.461 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / IR[1]_OTERM569 | -0.391 | 7.444 |
| 42 | 10.465 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / PC[10]~DUPLICATE | -0.415 | 7.416 |
| 43 | 10.546 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / PC[8] | -0.417 | 7.333 |
| 44 | 10.552 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / PC[8]~DUPLICATE | -0.414 | 7.33 |
| 45 | 10.552 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / PC[13] | -0.414 | 7.33 |
| 46 | 10.589 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / WZ[8] | -0.397 | 7.31 |
| 47 | 10.589 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / WZ[10] | -0.404 | 7.303 |
| 48 | 10.589 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / WZ[11] | -0.398 | 7.309 |
| 49 | 10.589 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / WZ[9] | -0.398 | 7.309 |
| 50 | 10.589 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / WZ[14] | -0.398 | 7.309 |

### candidate2

| Rank | Slack ns | From | To | Skew ns | Data ns |
| --- | --- | --- | --- | --- | --- |
| 1 | 10.104 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / IR[5] | -0.432 | 7.76 |
| 2 | 10.544 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / IR[3] | -0.428 | 7.324 |
| 3 | 10.712 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / IR[4] | -0.428 | 7.156 |
| 4 | 10.806 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / A[14]~DUPLICATE | -0.454 | 7.036 |
| 5 | 10.806 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / A[15]~DUPLICATE | -0.454 | 7.036 |
| 6 | 10.811 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / A[15] | -0.447 | 7.038 |
| 7 | 10.811 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / A[14] | -0.447 | 7.038 |
| 8 | 10.812 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / A[13] | -0.448 | 7.036 |
| 9 | 10.959 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / A[3]~DUPLICATE | -0.47 | 6.867 |
| 10 | 10.959 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / A[3] | -0.473 | 6.864 |
| 11 | 10.988 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / WZ[4] | -0.474 | 6.834 |
| 12 | 10.988 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / WZ[3]~DUPLICATE | -0.474 | 6.834 |
| 13 | 10.988 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / WZ[3] | -0.477 | 6.831 |
| 14 | 10.988 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / WZ[5] | -0.474 | 6.834 |
| 15 | 11.045 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / WZ[14] | -0.459 | 6.792 |
| 16 | 11.046 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / WZ[8] | -0.457 | 6.793 |
| 17 | 11.066 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / WZ[12] | -0.465 | 6.765 |
| 18 | 11.067 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / WZ[9] | -0.469 | 6.76 |
| 19 | 11.068 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / WZ[11] | -0.47 | 6.758 |
| 20 | 11.178 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / WZ[13] | -0.455 | 6.663 |
| 21 | 11.224 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / PC[7]~DUPLICATE | -0.469 | 6.603 |
| 22 | 11.224 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / PC[1] | -0.469 | 6.603 |
| 23 | 11.225 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / PC[7] | -0.473 | 6.598 |
| 24 | 11.289 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / WZ[6] | -0.467 | 6.54 |
| 25 | 11.289 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / WZ[0] | -0.467 | 6.54 |
| 26 | 11.289 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / WZ[7] | -0.467 | 6.54 |
| 27 | 11.295 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / PC[8] | -0.475 | 6.526 |
| 28 | 11.295 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / PC[15] | -0.475 | 6.526 |
| 29 | 11.295 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / PC[11] | -0.475 | 6.526 |
| 30 | 11.295 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / PC[10] | -0.475 | 6.526 |
| 31 | 11.295 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / PC[13] | -0.475 | 6.526 |
| 32 | 11.295 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / PC[12] | -0.475 | 6.526 |
| 33 | 11.328 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / A[0] | -0.458 | 6.51 |
| 34 | 11.328 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / A[6] | -0.458 | 6.51 |
| 35 | 11.328 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / A[7]~DUPLICATE | -0.458 | 6.51 |
| 36 | 11.328 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / A[5]~DUPLICATE | -0.458 | 6.51 |
| 37 | 11.328 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / A[4] | -0.458 | 6.51 |
| 38 | 11.328 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / A[2]~DUPLICATE | -0.458 | 6.51 |
| 39 | 11.329 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / A[2] | -0.461 | 6.506 |
| 40 | 11.329 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / A[5] | -0.461 | 6.506 |
| 41 | 11.329 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / A[7] | -0.461 | 6.506 |
| 42 | 11.413 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / PC[14]~DUPLICATE | -0.472 | 6.411 |
| 43 | 11.413 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / PC[9] | -0.472 | 6.411 |
| 44 | 11.414 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / PC[14] | -0.475 | 6.407 |
| 45 | 11.456 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / WZ[15] | -0.473 | 6.367 |
| 46 | 11.457 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / WZ[10]~DUPLICATE | -0.474 | 6.365 |
| 47 | 11.462 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / WZ[10] | -0.467 | 6.367 |
| 48 | 11.462 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / WZ[15]~DUPLICATE | -0.469 | 6.365 |
| 49 | 11.694 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / A[1] | -0.459 | 6.143 |
| 50 | 11.706 | emu:emu / savestates:savestates_inst / z80_set | emu:emu / system:system / T80s:z80_inst / T80:u0 / WZ[2] | -0.473 | 6.117 |

## Exact matched HDMI endpoint pairs

### hcnt

| To | Baseline slack | Candidate slack | Delta | Baseline data | Candidate data | Baseline skew | Candidate skew |
| --- | --- | --- | --- | --- | --- | --- | --- |
| osd:hdmi_osd / h_cnt[2] | 3.1 | 2.688 | -0.412 | 3.197 | 3.65 | -0.235 | -0.194 |
| osd:hdmi_osd / h_cnt[5]~DUPLICATE | 3.1 | 2.679 | -0.421 | 3.195 | 3.657 | -0.237 | -0.196 |
| osd:hdmi_osd / h_cnt[8] | 3.1 | 2.679 | -0.421 | 3.197 | 3.659 | -0.235 | -0.194 |
| osd:hdmi_osd / h_cnt[9] | 3.1 | 2.679 | -0.421 | 3.195 | 3.657 | -0.237 | -0.196 |
| osd:hdmi_osd / h_cnt[4] | 3.1 | 2.685 | -0.415 | 3.197 | 3.657 | -0.235 | -0.19 |
| osd:hdmi_osd / h_cnt[5] | 3.105 | 2.684 | -0.421 | 3.197 | 3.659 | -0.23 | -0.189 |
| osd:hdmi_osd / h_cnt[9]~DUPLICATE | 3.105 | 2.684 | -0.421 | 3.197 | 3.659 | -0.23 | -0.189 |
| osd:hdmi_osd / h_cnt[4]~DUPLICATE | 3.106 | 2.679 | -0.427 | 3.195 | 3.659 | -0.231 | -0.194 |
| osd:hdmi_osd / h_cnt[8]~DUPLICATE | 3.106 | 2.685 | -0.421 | 3.195 | 3.657 | -0.231 | -0.19 |
| osd:hdmi_osd / h_cnt[3] | 3.109 | 2.693 | -0.416 | 3.186 | 3.65 | -0.237 | -0.189 |
| osd:hdmi_osd / h_cnt[1] | 3.109 | 2.688 | -0.421 | 3.186 | 3.648 | -0.237 | -0.196 |
| osd:hdmi_osd / h_cnt[7] | 3.114 | 2.679 | -0.435 | 3.188 | 3.657 | -0.23 | -0.196 |
| osd:hdmi_osd / h_cnt[0] | 3.115 | 2.688 | -0.427 | 3.186 | 3.65 | -0.231 | -0.194 |
| osd:hdmi_osd / h_cnt[6] | 3.115 | 2.688 | -0.427 | 3.186 | 3.65 | -0.231 | -0.194 |
| osd:hdmi_osd / h_cnt[22] | 3.118 | 3.213 | 0.095 | 3.156 | 3.086 | -0.258 | -0.233 |
| osd:hdmi_osd / h_cnt[14] | 3.118 | 3.218 | 0.1 | 3.156 | 3.084 | -0.258 | -0.23 |
| osd:hdmi_osd / h_cnt[15]~DUPLICATE | 3.119 | 3.205 | 0.086 | 3.154 | 3.093 | -0.259 | -0.234 |
| osd:hdmi_osd / h_cnt[15] | 3.123 | 3.208 | 0.085 | 3.156 | 3.096 | -0.253 | -0.228 |
| osd:hdmi_osd / h_cnt[20] | 3.127 | 3.218 | 0.091 | 3.147 | 3.084 | -0.258 | -0.23 |
| osd:hdmi_osd / h_cnt[23] | 3.128 | 3.214 | 0.086 | 3.145 | 3.084 | -0.259 | -0.234 |
| osd:hdmi_osd / h_cnt[11] | 3.128 | 3.214 | 0.086 | 3.145 | 3.084 | -0.259 | -0.234 |
| osd:hdmi_osd / h_cnt[19] | 3.128 | 3.214 | 0.086 | 3.145 | 3.084 | -0.259 | -0.234 |
| osd:hdmi_osd / h_cnt[21] | 3.132 | 3.214 | 0.082 | 3.147 | 3.084 | -0.253 | -0.234 |
| osd:hdmi_osd / h_cnt[13] | 3.132 | 3.218 | 0.086 | 3.147 | 3.086 | -0.253 | -0.228 |
| osd:hdmi_osd / h_cnt[12] | 3.132 | 3.218 | 0.086 | 3.145 | 3.084 | -0.255 | -0.23 |
| osd:hdmi_osd / h_cnt[10] | 3.132 | 3.213 | 0.081 | 3.145 | 3.086 | -0.255 | -0.233 |
| osd:hdmi_osd / h_cnt[16] | 3.132 | 3.218 | 0.086 | 3.145 | 3.084 | -0.255 | -0.23 |
| osd:hdmi_osd / h_cnt[18] | 3.132 | 3.213 | 0.081 | 3.145 | 3.086 | -0.255 | -0.233 |
| osd:hdmi_osd / h_cnt[17] | 3.132 | 3.208 | 0.076 | 3.147 | 3.096 | -0.253 | -0.228 |

### width

| To | Baseline slack | Candidate slack | Delta | Baseline data | Candidate data | Baseline skew | Candidate skew |
| --- | --- | --- | --- | --- | --- | --- | --- |
| osd:hdmi_osd / dsp_width[20] | 2.829 | 2.866 | 0.037 | 3.444 | 3.462 | -0.259 | -0.204 |
| osd:hdmi_osd / dsp_width[21] | 2.833 | 3.385 | 0.552 | 3.444 | 2.936 | -0.255 | -0.211 |
| osd:hdmi_osd / dsp_width[2] | 2.967 | 3.081 | 0.114 | 3.315 | 3.241 | -0.25 | -0.21 |
| osd:hdmi_osd / dsp_width[4] | 2.971 | 3.385 | 0.414 | 3.315 | 2.936 | -0.246 | -0.211 |
| osd:hdmi_osd / dsp_width[1] | 2.971 | 3.085 | 0.114 | 3.315 | 3.241 | -0.246 | -0.206 |
| osd:hdmi_osd / dsp_width[0] | 2.971 | 3.085 | 0.114 | 3.315 | 3.241 | -0.246 | -0.206 |
| osd:hdmi_osd / dsp_width[6] | 3.014 | 2.862 | -0.152 | 3.279 | 3.464 | -0.239 | -0.206 |
| osd:hdmi_osd / dsp_width[7] | 3.018 | 3.389 | 0.371 | 3.279 | 2.936 | -0.235 | -0.207 |
| osd:hdmi_osd / dsp_width[5] | 3.018 | 3.385 | 0.367 | 3.279 | 2.936 | -0.235 | -0.211 |
| osd:hdmi_osd / dsp_width[3] | 3.018 | 3.389 | 0.371 | 3.279 | 2.936 | -0.235 | -0.207 |
| osd:hdmi_osd / dsp_width[15] | 3.023 | 2.673 | -0.35 | 3.26 | 3.65 | -0.249 | -0.209 |
| osd:hdmi_osd / dsp_width[18] | 3.038 | 2.678 | -0.36 | 3.246 | 3.65 | -0.248 | -0.204 |
| osd:hdmi_osd / dsp_width[16] | 3.038 | 3.389 | 0.351 | 3.246 | 2.936 | -0.248 | -0.207 |
| osd:hdmi_osd / dsp_width[17] | 3.239 | 2.678 | -0.561 | 3.052 | 3.65 | -0.241 | -0.204 |
| osd:hdmi_osd / dsp_width[14] | 3.239 | 2.862 | -0.377 | 3.052 | 3.464 | -0.241 | -0.206 |
| osd:hdmi_osd / dsp_width[12] | 3.239 | 2.862 | -0.377 | 3.052 | 3.464 | -0.241 | -0.206 |
| osd:hdmi_osd / dsp_width[9] | 3.239 | 2.858 | -0.381 | 3.052 | 3.464 | -0.241 | -0.21 |
| osd:hdmi_osd / dsp_width[19] | 3.243 | 2.678 | -0.565 | 3.052 | 3.65 | -0.237 | -0.204 |
| osd:hdmi_osd / dsp_width[13] | 3.243 | 2.858 | -0.385 | 3.052 | 3.464 | -0.237 | -0.21 |
| osd:hdmi_osd / dsp_width[11] | 3.243 | 2.858 | -0.385 | 3.052 | 3.464 | -0.237 | -0.21 |
| osd:hdmi_osd / dsp_width[10] | 3.243 | 2.862 | -0.381 | 3.052 | 3.464 | -0.237 | -0.206 |
| osd:hdmi_osd / dsp_width[8] | 3.243 | 2.858 | -0.385 | 3.052 | 3.464 | -0.237 | -0.21 |

