# Canonical current-baseline runs

Generated from results.json; partial and superseded pilots are not passes. Reference and DUT are separate simulations; a completed DUT normally contains one SAVE-only suffix and three LOAD suffixes.

PASS: **102**; DEFERRED — G05 STOP RULE: **4**; COUNTEREXAMPLE COMPLETED: **2**. Total canonical rows: **108**; integrated rows: **102**. Deferred rows describe stopped or unlaunched completion obligations, not completed runs.

| Family / run | Disposition | Samples per suffix | Final SAVE request | Final SAVE acceptance |
|---|---|---:|---|---|
| fixture/reference_sanity_collision | PASS | 1000 | x489 y168 regs0005075614d4e0007fcc27e0005ff1c0a0 | save1 cycle1572458 x5 y168 PC008b ce110 regs0005875614d4e0007fcc27e0005ff1c0a0 probe00000000 |
| fixture/dut_sanity_collision | PASS | 1000 | x489 y168 regs0005075614d4e0007fcc27e0005ff1c0a0 | save1 cycle1572458 x5 y168 PC008b ce110 regs0005875614d4e0007fcc27e0005ff1c0a0 probe00000000 |
| fixture/reference_sanity_overflow | PASS | 1000 | x489 y168 regs0005c75614d4e0007fcc27e0005ff1c0a0 | save1 cycle1572458 x5 y168 PC008b ce110 regs0005875614d4e0007fcc27e0005ff1c0a0 probe00000000 |
| fixture/dut_sanity_overflow | PASS | 1000 | x489 y168 regs0005c75614d4e0007fcc27e0005ff1c0a0 | save1 cycle1572458 x5 y168 PC008b ce110 regs0005875614d4e0007fcc27e0005ff1c0a0 probe00000000 |
| fixture/reference_status_normal | PASS | 1000 | x4 y168 regs0005075614d4e0007fcc27e0005ff1c0a0 | save1 cycle1572613 x11 y168 PC008d ce101 regs0005875614d4e0007fcc27e0005ff1c0a0 probe00000000 |
| fixture/dut_status_normal | PASS | 1000 | x4 y168 regs0005075614d4e0007fcc27e0005ff1c0a0 | save1 cycle1572613 x11 y168 PC008d ce101 regs0005875614d4e0007fcc27e0005ff1c0a0 probe00000000 |
| fixture/reference_status_turbo | PASS | 1000 | x490 y168 regs0005075614d4e0007fcc27e0005ff1c0a0 | save1 cycle1572458 x5 y168 PC008b ce110 regs0005875614d4e0007fcc27e0005ff1c0a0 probe00000000 |
| fixture/dut_status_turbo | PASS | 1000 | x490 y168 regs0005075614d4e0007fcc27e0005ff1c0a0 | save1 cycle1572458 x5 y168 PC008b ce110 regs0005875614d4e0007fcc27e0005ff1c0a0 probe00000000 |
| fixture/reference_status_irq | PASS | 1000 | x490 y168 regs0005075614d4e0007fcc27e0005ff1c1a0 | save1 cycle1572458 x5 y168 PC008b ce110 regs0005875614d4e0007fcc27e0005ff1c1a0 probe00000000 |
| fixture/dut_status_irq | PASS | 1000 | x490 y168 regs0005075614d4e0007fcc27e0005ff1c1a0 | save1 cycle1572458 x5 y168 PC008b ce110 regs0005875614d4e0007fcc27e0005ff1c1a0 probe00000000 |
| dual/reference_status | PASS | 1000 | x497 y192 regs0005073e14c1e000bfcc27e0005ff1c0a0 | save1 cycle1812323 x2 y192 PC00fd ce111 regs0005873e14c1e000bfcc27e0005ff1c0a0 probe00000000 |
| dual/dut_status | PASS | 1000 | x497 y192 regs0005073e14c1e000bfcc27e0005ff1c0a0 | save1 cycle1812323 x2 y192 PC00fd ce111 regs0005873e14c1e000bfcc27e0005ff1c0a0 probe00000000 |
| bus/reference_normal | PASS | 1000 | x496 y168 regs0005075614d4e0007fcc27e0005ff1c0a0 | save1 cycle1572553 x5 y168 PC0234 ce101 regs0005875614c1e000bfcc27e0005ff1c0a0 probe00000000 |
| bus/dut_normal | PASS | 1000 | x496 y168 regs0005075614d4e0007fcc27e0005ff1c0a0 | save1 cycle1572553 x5 y168 PC0234 ce101 regs0005875614c1e000bfcc27e0005ff1c0a0 probe00000000 |
| bus/reference_clone | PASS | 1000 | x53 y168 regs0005875814c1c04fbfcc27e0005ff1c0a0 | save1 cycle676928 x55 y168 PC020c ce110 regs0005875814e9404fffcc27e0005ff1c0a0 probe00000000 |
| bus/dut_clone | PASS | 1000 | x53 y168 regs0005875814c1c04fbfcc27e0005ff1c0a0 | save1 cycle676928 x55 y168 PC020c ce110 regs0005875814e9404fffcc27e0005ff1c0a0 probe00000000 |
| pair/reference_h0 | PASS | 1000 | x203 y192 regs0005874014dd804fffcc27e0005ff1c0a0 | save1 cycle760618 x215 y192 PC00a9 ce111 regs0005874014dd804fffcc27e0005ff1c0a0 probe00000000 |
| pair/dut_h0 | PASS | 1000 | x203 y192 regs0005874014dd804fffcc27e0005ff1c0a0 | save1 cycle760618 x215 y192 PC00a9 ce111 regs0005874014dd804fffcc27e0005ff1c0a0 probe00000000 |
| pair/reference_h1 | PASS | 1000 | x203 y192 regs0005874014dd804fffcc27e0005ff1c0a0 | save1 cycle760618 x215 y192 PC00a9 ce111 regs0005874014dd804fffcc27e0005ff1c0a0 probe00000000 |
| pair/dut_h1 | PASS | 1000 | x203 y192 regs0005874014dd804fffcc27e0005ff1c0a0 | save1 cycle760618 x215 y192 PC00a9 ce111 regs0005874014dd804fffcc27e0005ff1c0a0 probe00000000 |
| pair_live/reference_h0 | PASS | 1000 | x191 y192 regs0005874014dd804fffcc27e0005ff1c0a0 | save1 cycle760388 x191 y192 PC00a4 ce110 regs0005874014dd804fffcc27e0005ff1c0a0 probe00000000 |
| pair_live/dut_h0 | PASS | 1000 | x191 y192 regs0005874014dd804fffcc27e0005ff1c0a0 | save1 cycle760388 x191 y192 PC00a4 ce110 regs0005874014dd804fffcc27e0005ff1c0a0 probe00000000 |
| pair_live/reference_h1 | PASS | 1000 | x191 y192 regs0005874014dd804fffcc27e0005ff1c0a0 | save1 cycle760388 x191 y192 PC00a4 ce110 regs0005874014dd804fffcc27e0005ff1c0a0 probe00000000 |
| pair_live/dut_h1 | PASS | 1000 | x191 y192 regs0005874014dd804fffcc27e0005ff1c0a0 | save1 cycle760388 x191 y192 PC00a4 ce110 regs0005874014dd804fffcc27e0005ff1c0a0 probe00000000 |
| direct/reference_owner1 | PASS | 1000 | x163 y192 regs0005274014e9404fbfcc27e0005ff1c0a0 | save1 cycle917888 x169 y192 PC0131 ce111 regs0005274014e9404fbfcc27e0005ff1c0a0 probe00000000 |
| direct/dut_owner1 | PASS | 1000 | x163 y192 regs0005274014e9404fbfcc27e0005ff1c0a0 | save1 cycle917888 x169 y192 PC0131 ce111 regs0005274014e9404fbfcc27e0005ff1c0a0 probe00000000 |
| direct_consistent/reference_owner0 | PASS | 1000 | x163 y192 regs0005274014e9404fbfcc27e0005ff1c0a0 | save1 cycle917888 x169 y192 PC0131 ce111 regs0005274014e9404fbfcc27e0005ff1c0a0 probe00000000 |
| direct_consistent/dut_owner0 | PASS | 1000 | x163 y192 regs0005274014e9404fbfcc27e0005ff1c0a0 | save1 cycle917888 x169 y192 PC0131 ce111 regs0005274014e9404fbfcc27e0005ff1c0a0 probe00000000 |
| dual_corrected/reference_bus | PASS | 1000 | x489 y192 regs00052f3e14e9404fbfcc27e0005ff1c0a0 | save1 cycle1812323 x4 y192 PC0125 ce111 regs00052f3e14e9404fbfcc27e0005ff1c0a0 probe00000000 |
| dual_corrected/dut_bus | PASS | 1000 | x489 y192 regs00052f3e14e9404fbfcc27e0005ff1c0a0 | save1 cycle1812323 x4 y192 PC0125 ce111 regs00052f3e14e9404fbfcc27e0005ff1c0a0 probe00000000 |
| dual_corrected/reference_collision | PASS | 1000 | x489 y192 regs0005073e14c1e000bfcc27e0005ff1c0a0 | save1 cycle1812323 x2 y192 PC00fd ce111 regs0005873e14c1e000bfcc27e0005ff1c0a0 probe00000000 |
| dual_corrected/dut_collision | PASS | 1000 | x489 y192 regs0005073e14c1e000bfcc27e0005ff1c0a0 | save1 cycle1812323 x2 y192 PC00fd ce111 regs0005873e14c1e000bfcc27e0005ff1c0a0 probe00000000 |
| rich/reference_mode4 | PASS | 170000 | x51 y192 regs0005874014d4e0007fcc27e1705ff1c0a0 | save1 cycle759103 x63 y192 PC0090 ce111 regs0005874014d4e0007fcc27e1705ff1c0a0 probe00000000 |
| rich/dut_mode4 | PASS | 170000 | x51 y192 regs0005874014d4e0007fcc27e1705ff1c0a0 | save1 cycle759103 x63 y192 PC0090 ce111 regs0005874014d4e0007fcc27e1705ff1c0a0 probe00000000 |
| rich/reference_gg | PASS | 65000 | x44 y168 regs0005875814d4e0007fcc27e1705ff1c0a0 | save1 cycle676888 x53 y168 PC008b ce111 regs0005875814d4e0007fcc27e1705ff1c0a0 probe00000000 |
| rich/dut_gg | PASS | 65000 | x44 y168 regs0005875814d4e0007fcc27e1705ff1c0a0 | save1 cycle676888 x53 y168 PC008b ce111 regs0005875814d4e0007fcc27e1705ff1c0a0 probe00000000 |
| rich/reference_text | PASS | 42000 | x51 y192 regs0005874014d4e0007fcc27e1705ff1c280 | save1 cycle759103 x63 y192 PC0090 ce111 regs0005874014d4e0007fcc27e1705ff1c280 probe00000000 |
| rich/dut_text | PASS | 42000 | x51 y192 regs0005874014d4e0007fcc27e1705ff1c280 | save1 cycle759103 x63 y192 PC0090 ce111 regs0005874014d4e0007fcc27e1705ff1c280 probe00000000 |
| rich/reference_graphics1 | PASS | 42000 | x51 y192 regs0005874014d4e0007fcc27e1705ff1c080 | save1 cycle759103 x63 y192 PC0090 ce111 regs0005874014d4e0007fcc27e1705ff1c080 probe00000000 |
| rich/dut_graphics1 | DEFERRED — G05 STOP RULE | 42000 | x51 y192 regs0005874014d4e0007fcc27e1705ff1c080 | save1 cycle759103 x63 y192 PC0090 ce111 regs0005874014d4e0007fcc27e1705ff1c080 probe00000000 |
| rich/reference_graphics2 | PASS | 42000 | x51 y192 regs0005874014d4e0007fcc27e1705ff1c0c0 | save1 cycle759103 x63 y192 PC0090 ce111 regs0005874014d4e0007fcc27e1705ff1c0c0 probe00000000 |
| rich/dut_graphics2 | PASS | 42000 | x51 y192 regs0005874014d4e0007fcc27e1705ff1c0c0 | save1 cycle759103 x63 y192 PC0090 ce111 regs0005874014d4e0007fcc27e1705ff1c0c0 probe00000000 |
| rich/reference_mixed_m3 | PASS | 42000 | x46 y240 regs0005071014d4e0007fcc27e1705ff1c4c0 | save1 cycle923168 x56 y240 PC008d ce110 regs0005071014d4e0007fcc27e1705ff1c4c0 probe00000000 |
| rich/dut_mixed_m3 | PASS | 42000 | x46 y240 regs0005071014d4e0007fcc27e1705ff1c4c0 | save1 cycle923168 x56 y240 PC008d ce110 regs0005071014d4e0007fcc27e1705ff1c4c0 probe00000000 |
| rich/reference_sms224 | PASS | 42000 | x44 y224 regs0005872014d4e0007fcc27e1705ff1c2e0 | save1 cycle868433 x54 y224 PC008d ce110 regs0005872014d4e0007fcc27e1705ff1c2e0 probe00000000 |
| rich/dut_sms224 | DEFERRED — G05 STOP RULE | 42000 | x44 y224 regs0005872014d4e0007fcc27e1705ff1c2e0 | save1 cycle868433 x54 y224 PC008d ce110 regs0005872014d4e0007fcc27e1705ff1c2e0 probe00000000 |
| rich/reference_pal240 | PASS | 60000 | x46 y240 regs0005071014d4e0007fcc27e1705ff1c4e0 | save1 cycle923168 x56 y240 PC008d ce110 regs0005071014d4e0007fcc27e1705ff1c4e0 probe00000000 |
| rich/dut_pal240 | PASS | 60000 | x46 y240 regs0005071014d4e0007fcc27e1705ff1c4e0 | save1 cycle923168 x56 y240 PC008d ce110 regs0005071014d4e0007fcc27e1705ff1c4e0 probe00000000 |
| rich/reference_scroll | PASS | 42000 | x250 y192 regs00f1873e14d4c245ffcc27e17f1ff1c0a0 | save1 cycle1657033 x254 y192 PC008d ce111 regs00f1873e14d4c245ffcc27e17f1ff1c0a0 probe00000000 |
| rich/dut_scroll | DEFERRED — G05 STOP RULE | 42000 | x250 y192 regs00f1873e14d4c245ffcc27e17f1ff1c0a0 | save1 cycle1657033 x254 y192 PC008d ce111 regs00f1873e14d4c245ffcc27e17f1ff1c0a0 probe00000000 |
| g04/reference_pending64 | PASS | 1000 | x120 y168 regs0005875614d4e0007fcc27e0005ff1c0a0 | save1 cycle1573723 x131 y168 PC0090 ce111 regs0005a75614d4e0007fcc27e0005ff1c0a0 probe00000000 |
| g04/dut_pending64 | PASS | 1000 | x120 y168 regs0005875614d4e0007fcc27e0005ff1c0a0 | save1 cycle1573723 x131 y168 PC0090 ce111 regs0005a75614d4e0007fcc27e0005ff1c0a0 probe00000000 |
| g04/reference_near | PASS | 1000 | x120 y168 regs0005875614d4e0007fcc27e0005ff1c0a0 | save1 cycle1573723 x131 y168 PC0090 ce111 regs0005875614d4e0007fcc27e0005ff1c0a0 probe00000000 |
| g04/dut_near | PASS | 1000 | x120 y168 regs0005875614d4e0007fcc27e0005ff1c0a0 | save1 cycle1573723 x131 y168 PC0090 ce111 regs0005875614d4e0007fcc27e0005ff1c0a0 probe00000000 |
| g04/reference_late | PASS | 1000 | x248 y168 regs0005875614d4e0007fcc27e0005ff1c0a0 | save1 cycle1574938 x254 y168 PC008d ce111 regs0005875614d4e0007fcc27e0005ff1c0a0 probe00000000 |
| g04/dut_late | PASS | 1000 | x248 y168 regs0005875614d4e0007fcc27e0005ff1c0a0 | save1 cycle1574938 x254 y168 PC008d ce111 regs0005875614d4e0007fcc27e0005ff1c0a0 probe00000000 |
| g04/reference_overflow | PASS | 1000 | x120 y168 regs0005875614d4e0007fcc27e0005ff1c0a0 | save1 cycle1573723 x131 y168 PC0090 ce111 regs0005a75614d4e0007fcc27e0005ff1c0a0 probe00000000 |
| g04/dut_overflow | PASS | 1000 | x120 y168 regs0005875614d4e0007fcc27e0005ff1c0a0 | save1 cycle1573723 x131 y168 PC0090 ce111 regs0005a75614d4e0007fcc27e0005ff1c0a0 probe00000000 |
| irq/reference_t0 | PASS | 1000 | x145 y168 regs0005875814d4c280000c27e0005ff1c1a8 | save1 cycle677983 x152 y168 PC01a8 ce101 regs0005875814d4c280000c27e0005ff1c1a8 probe00000000 |
| irq/dut_t0 | PASS | 1000 | x145 y168 regs0005875814d4c280000c27e0005ff1c1a8 | save1 cycle677983 x152 y168 PC01a8 ce101 regs0005875814d4c280000c27e0005ff1c1a8 probe00000000 |
| irq/reference_t1 | PASS | 1000 | x122 y168 regs0005875814d4c280000c27e0005ff1c1a8 | save1 cycle677628 x126 y168 PC01a8 ce110 regs0005875814d4c280000c27e0005ff1c1a8 probe00000000 |
| irq/dut_t1 | PASS | 1000 | x122 y168 regs0005875814d4c280000c27e0005ff1c1a8 | save1 cycle677628 x126 y168 PC01a8 ce110 regs0005875814d4c280000c27e0005ff1c1a8 probe00000000 |
| bg_pair/reference_h0 | PASS | 42000 | x120 y192 regs00050f3e14d4c0013fcc27e0005ff1c0a0 | save1 cycle1655738 x125 y192 PC008b ce110 regs00050f3e14d4c0013fcc27e0005ff1c0a0 probe00000000 |
| bg_pair/dut_h0 | PASS | 42000 | x120 y192 regs00050f3e14d4c0013fcc27e0005ff1c0a0 | save1 cycle1655738 x125 y192 PC008b ce110 regs00050f3e14d4c0013fcc27e0005ff1c0a0 probe00000000 |
| bg_pair/reference_h1 | PASS | 42000 | x120 y192 regs00050f3e14d4c0013fcc27e0005ff1c0a0 | save1 cycle1655738 x125 y192 PC008b ce110 regs00050f3e14d4c0013fcc27e0005ff1c0a0 probe00000000 |
| bg_pair/dut_h1 | PASS | 42000 | x120 y192 regs00050f3e14d4c0013fcc27e0005ff1c0a0 | save1 cycle1655738 x125 y192 PC008b ce110 regs00050f3e14d4c0013fcc27e0005ff1c0a0 probe00000000 |
| text_history/reference_h0 | PASS | 42000 | x120 y192 regs00050f3e14d4c2403fcc27e0005ff1c280 | save1 cycle1655733 x123 y192 PC01b7 ce110 regs00050f3e14d4c2403fcc27e0005ff1c280 probe00000000 |
| text_history/dut_h0 | COUNTEREXAMPLE COMPLETED | 42000 | x120 y192 regs00050f3e14d4c2403fcc27e0005ff1c280 | save1 cycle1655733 x123 y192 PC01b7 ce110 regs00050f3e14d4c2403fcc27e0005ff1c280 probe00000000 |
| text_history/reference_h1 | PASS | 42000 | x120 y192 regs00050f3e14d4c2403fcc27e0005ff1c280 | save1 cycle1655733 x123 y192 PC01b7 ce110 regs00050f3e14d4c2403fcc27e0005ff1c280 probe00000000 |
| text_history/dut_h1 | COUNTEREXAMPLE COMPLETED | 42000 | x120 y192 regs00050f3e14d4c2403fcc27e0005ff1c280 | save1 cycle1655733 x123 y192 PC01b7 ce110 regs00050f3e14d4c2403fcc27e0005ff1c280 probe00000000 |
| hl/reference_edges | PASS | 1000 | x87 y168 regs0005875814d4e0007fcc27e0005ff1c0a0 | save1 cycle677518 x105 y168 PC0090 ce111 regs0005875814d4e0007fcc27e0005ff1c0a0 probe00000000 |
| hl/dut_edges | PASS | 1000 | x87 y168 regs0005875814d4e0007fcc27e0005ff1c0a0 | save1 cycle677518 x105 y168 PC0090 ce111 regs0005875814d4e0007fcc27e0005ff1c0a0 probe00000000 |
| ops/reference_write_address | PASS | 1000 | x217 y169 regs0005875714c1f00fbfcc27e0005ff1c0a0 | save1 cycle681988 x219 y169 PC0208 ce111 regs0005875714c1c04fbfcc27e0005ff1c0a0 probe00000000 |
| ops/dut_write_address | PASS | 1000 | x217 y169 regs0005875714c1f00fbfcc27e0005ff1c0a0 | save1 cycle681988 x219 y169 PC0208 ce111 regs0005875714c1c04fbfcc27e0005ff1c0a0 probe00000000 |
| ops/reference_vram_write | PASS | 1000 | x53 y168 regs0005875814c1c04fbfcc27e0005ff1c0a0 | save1 cycle676928 x55 y168 PC020c ce110 regs0005875814e9404fffcc27e0005ff1c0a0 probe00000000 |
| ops/dut_vram_write | PASS | 1000 | x53 y168 regs0005875814c1c04fbfcc27e0005ff1c0a0 | save1 cycle676928 x55 y168 PC020c ce110 regs0005875814e9404fffcc27e0005ff1c0a0 probe00000000 |
| ops/reference_partial_control | PASS | 1000 | x89 y168 regs0005875814db00503fcc27e0005ff1c0a0 | save1 cycle677288 x91 y168 PC0214 ce110 regs0005875814db104f7fcc27e0005ff1c0a0 probe00000000 |
| ops/dut_partial_control | PASS | 1000 | x89 y168 regs0005875814db00503fcc27e0005ff1c0a0 | save1 cycle677288 x91 y168 PC0214 ce110 regs0005875814db104f7fcc27e0005ff1c0a0 probe00000000 |
| ops/reference_read_setup | PASS | 1000 | x107 y168 regs0005875814db104f7fcc27e0005ff1c0a0 | save1 cycle677468 x109 y168 PC0218 ce110 regs0005875814d4404fbfcc27e0005ff1c0a0 probe00000000 |
| ops/dut_read_setup | PASS | 1000 | x107 y168 regs0005875814db104f7fcc27e0005ff1c0a0 | save1 cycle677468 x109 y168 PC0218 ce110 regs0005875814d4404fbfcc27e0005ff1c0a0 probe00000000 |
| ops/reference_first_read | PASS | 1000 | x116 y168 regs0005875814d4404fbfcc27e0005ff1c0a0 | save1 cycle677578 x120 y168 PC021a ce111 regs0005875814e9404fffcc27e0005ff1c0a0 probe00000000 |
| ops/dut_first_read | PASS | 1000 | x116 y168 regs0005875814d4404fbfcc27e0005ff1c0a0 | save1 cycle677578 x120 y168 PC021a ce111 regs0005875814e9404fffcc27e0005ff1c0a0 probe00000000 |
| ops/reference_next_read | PASS | 1000 | x140 y168 regs0005875814e9404fffcc27e0005ff1c0a0 | save1 cycle677818 x144 y168 PC021f ce111 regs0005875814db00503fcc27e0005ff1c0a0 probe00000000 |
| ops/dut_next_read | PASS | 1000 | x140 y168 regs0005875814e9404fffcc27e0005ff1c0a0 | save1 cycle677818 x144 y168 PC021f ce111 regs0005875814db00503fcc27e0005ff1c0a0 probe00000000 |
| ops/reference_cram_low | PASS | 1000 | x209 y168 regs0005875814db20003fcc27e0005ff1c0a0 | save1 cycle678488 x211 y168 PC022e ce110 regs0005875814d4e0007fcc27e0005ff1c0a0 probe00000000 |
| ops/dut_cram_low | PASS | 1000 | x209 y168 regs0005875814db20003fcc27e0005ff1c0a0 | save1 cycle678488 x211 y168 PC022e ce110 regs0005875814d4e0007fcc27e0005ff1c0a0 probe00000000 |
| ops/reference_cram_high | PASS | 1000 | x227 y168 regs0005875814d4e0007fcc27e0005ff1c0a0 | save1 cycle678668 x229 y168 PC0232 ce110 regs0005875814c1e000bfcc27e0005ff1c0a0 probe00000000 |
| ops/dut_cram_high | PASS | 1000 | x227 y168 regs0005875814d4e0007fcc27e0005ff1c0a0 | save1 cycle678668 x229 y168 PC0232 ce110 regs0005875814c1e000bfcc27e0005ff1c0a0 probe00000000 |
| g04_native/reference_pending | PASS | 1000 | x120 y168 regs0005875614d4e0007fcc27e0005ff1c0a0 | save1 cycle1573723 x131 y168 PC0090 ce111 regs0005a75614d4e0007fcc27e0005ff1c0a0 probe00000000 |
| g04_native/dut_pending | PASS | 1000 | x120 y168 regs0005875614d4e0007fcc27e0005ff1c0a0 | save1 cycle1573723 x131 y168 PC0090 ce111 regs0005a75614d4e0007fcc27e0005ff1c0a0 probe00000000 |
| dual_irq/reference_enabled | PASS | 1000 | x88 y192 regs0005874014c1e000800c27e0005ff1c1a8 | save1 cycle917198 x97 y192 PC01fb ce111 regs0005874014c1e000800c27e0005ff1c1a8 probe00000000 |
| dual_irq/dut_enabled | PASS | 1000 | x88 y192 regs0005874014c1e000800c27e0005ff1c1a8 | save1 cycle917198 x97 y192 PC01fb ce111 regs0005874014c1e000800c27e0005ff1c1a8 probe00000000 |
| line_irq/reference_active | PASS | 5000 | x154 y168 regs0005a70014d4c280000c27e0005ff1c1a8 | save1 cycle1574113 x161 y168 PC01a8 ce101 regs0005870014d4c280000c27e0005ff1c1a8 probe00000000 |
| line_irq/dut_active | PASS | 5000 | x154 y168 regs0005a70014d4c280000c27e0005ff1c1a8 | save1 cycle1574113 x161 y168 PC01a8 ce101 regs0005870014d4c280000c27e0005ff1c1a8 probe00000000 |
| memory_events/reference_bus | PASS | 1000 | x209 y168 regs0005875814db20003fcc27e0005ff1c0a0 | save1 cycle678488 x211 y168 PC022e ce110 regs0005875814d4e0007fcc27e0005ff1c0a0 probe00000000 |
| memory_events/dut_bus | PASS | 1000 | x209 y168 regs0005875814db20003fcc27e0005ff1c0a0 | save1 cycle678488 x211 y168 PC022e ce110 regs0005875814d4e0007fcc27e0005ff1c0a0 probe00000000 |
| bus/dut_fullflush | PASS | 1000 | x53 y168 regs0005875814c1c04fbfcc27e0005ff1c0a0 | save1 cycle1576928 x55 y168 PC020c ce110 regs0005875814e9404fffcc27e0005ff1c0a0 probe00000000 |
| stalls_valid/dut_p1 | PASS | 1000 | x53 y168 regs0005875814c1c04fbfcc27e0005ff1c0a0 | save1 cycle910475 x55 y168 PC020c ce110 regs0005875814e9404fffcc27e0005ff1c0a0 probe00000000 |
| stalls_valid/dut_p2 | PASS | 1000 | x53 y168 regs0005875814c1c04fbfcc27e0005ff1c0a0 | save1 cycle719426 x55 y168 PC020c ce110 regs0005875814e9404fffcc27e0005ff1c0a0 probe00000000 |
| g04_stalls_valid/dut_pending | PASS | 1000 | x120 y168 regs0005875614d4e0007fcc27e0005ff1c0a0 | save1 cycle1807291 x131 y168 PC0090 ce111 regs0005a75614d4e0007fcc27e0005ff1c0a0 probe00000000 |
| mode_switch/reference | PASS | 42000 | x51 y192 regs0005274014d4e0007fcc27e0005ff1c0a0 | save1 cycle758983 x57 y192 PC018f ce111 regs0005274014d4e0007fcc27e0005ff1c0a0 probe00000000 |
| mode_switch/dut | DEFERRED — G05 STOP RULE | 42000 | x489 y192 regs00052f3e14d4e0007fcc27e0005ff1c0a0 | save1 cycle1654518 x3 y192 PC018f ce110 regs00052f3e14d4e0007fcc27e0005ff1c0a0 probe00000000 |
| scan/t0_p0 | PASS | — |  |  |
| scan/t1_p0 | PASS | — |  |  |
| scan/t1_p1 | PASS | — |  |  |
| sanity/hcounter_sms | PASS | — |  |  |
| sanity/hcounter_gg | PASS | — |  |  |
| sanity/mcode | PASS | — |  |  |

## Accepted post-T state and restart observations

The final ARM row for save1, before suffix/repeated LOAD, supplies post-T state. Earlier ARM entries belong to legal legacy initialization. Raw accepted T and post-T beam may differ by one pixel. These are known runtime values, not forced targets. Full logs retain pre-acceptance I/O, CE/CPU phase, state transitions, preparation and every first enable.

- **fixture/dut_sanity_collision**: # BOUNDARY T cycle1572458 xy5,168 MC1 TS2 phase20 ce_vdp1 audit000000000003c000 reset0; # ARM x6 y168 regs0005875614d4e0007fcc27e0005ff1c0a0 probe00000000.
- **fixture/dut_sanity_overflow**: # BOUNDARY T cycle1572458 xy5,168 MC1 TS2 phase20 ce_vdp1 audit000000000003c000 reset0; # ARM x6 y168 regs0005875614d4e0007fcc27e0005ff1c0a0 probe00000000.
- **fixture/dut_status_normal**: # BOUNDARY T cycle1572613 xy11,168 MC1 TS2 phase25 ce_vdp1 audit000000000002c000 reset0; # ARM x11 y168 regs0005875614d4e0007fcc27e0005ff1c0a0 probe00000000.
- **fixture/dut_status_turbo**: # BOUNDARY T cycle1572458 xy5,168 MC1 TS2 phase20 ce_vdp1 audit000000000003c000 reset0; # ARM x6 y168 regs0005875614d4e0007fcc27e0005ff1c0a0 probe00000000.
- **fixture/dut_status_irq**: # BOUNDARY T cycle1572458 xy5,168 MC1 TS2 phase20 ce_vdp1 audit000000000003c000 reset0; # ARM x6 y168 regs0005875614d4e0007fcc27e0005ff1c1a0 probe00000000.
- **dual/dut_status**: # BOUNDARY T cycle1812323 xy2,192 MC1 TS2 phase10 ce_vdp1 audit000000000002c000 reset0; # ARM x3 y192 regs0005873e14c1e000bfcc27e0005ff1c0a0 probe00000000.
- **bus/dut_normal**: # BOUNDARY T cycle1572553 xy5,168 MC1 TS2 phase25 ce_vdp1 audit000000000002c070 reset0; # ARM x5 y168 regs0005875614c1e000bfcc27e0005ff1c0a0 probe00000000.
- **bus/dut_clone**: # BOUNDARY T cycle676928 xy55,168 MC1 TS2 phase20 ce_vdp1 audit000000000003ca50 reset0; # ARM x56 y168 regs0005875814e9404fffcc27e0005ff1c0a0 probe00000000.
- **pair/dut_h0**: # BOUNDARY T cycle760618 xy215,192 MC1 TS2 phase10 ce_vdp1 audit000000000003c000 reset0; # ARM x216 y192 regs0005874014dd804fffcc27e0005ff1c0a0 probe00000000 audit000000000003c000.
- **pair/dut_h1**: # BOUNDARY T cycle760618 xy215,192 MC1 TS2 phase10 ce_vdp1 audit000000000003c000 reset0; # ARM x216 y192 regs0005874014dd804fffcc27e0005ff1c0a0 probe00000000 audit000000000003c000.
- **pair_live/dut_h0**: # BOUNDARY T cycle760388 xy191,192 MC1 TS2 phase20 ce_vdp1 audit000000000003c030 reset0; # ARM x192 y192 regs0005874014dd804fffcc27e0005ff1c0a0 probe00000000 audit000000000003c030.
- **pair_live/dut_h1**: # BOUNDARY T cycle760388 xy191,192 MC1 TS2 phase20 ce_vdp1 audit000000000003cc30 reset0; # ARM x192 y192 regs0005874014dd804fffcc27e0005ff1c0a0 probe00000000 audit000000000003cc30.
- **direct/dut_owner1**: # BOUNDARY T cycle917888 xy169,192 MC1 TS2 phase10 ce_vdp1 audit027c014a0003c000 reset0; # ARM x170 y192 regs0005274014e9404fbfcc27e0005ff1c0a0 probe00000000.
- **direct_consistent/dut_owner0**: # BOUNDARY T cycle917888 xy169,192 MC1 TS2 phase10 ce_vdp1 audit027c014a0003c000 reset0; # ARM x170 y192 regs0005274014e9404fbfcc27e0005ff1c0a0 probe00000000.
- **dual_corrected/dut_bus**: # BOUNDARY T cycle1812323 xy4,192 MC1 TS2 phase10 ce_vdp1 audit000000000002ca50 reset0; # ARM x5 y192 regs00052f3e14e9404fbfcc27e0005ff1c0a0 probe00000000.
- **dual_corrected/dut_collision**: # BOUNDARY T cycle1812323 xy2,192 MC1 TS2 phase10 ce_vdp1 audit000000000002c000 reset0; # ARM x3 y192 regs0005873e14c1e000bfcc27e0005ff1c0a0 probe00000000.
- **rich/dut_mode4**: # BOUNDARY T cycle759103 xy63,192 MC1 TS2 phase10 ce_vdp1 audit2a6639800003c000 reset0; # ARM x64 y192 regs0005874014d4e0007fcc27e1705ff1c0a0 probe00000000.
- **rich/dut_gg**: # BOUNDARY T cycle676888 xy53,168 MC1 TS2 phase10 ce_vdp1 audit621209800003c000 reset0; # ARM x54 y168 regs0005875814d4e0007fcc27e1705ff1c0a0 probe00000000.
- **rich/dut_text**: # BOUNDARY T cycle759103 xy63,192 MC1 TS2 phase10 ce_vdp1 audit185af9800003c000 reset0; # ARM x64 y192 regs0005874014d4e0007fcc27e1705ff1c280 probe00000000.
- **rich/dut_graphics2**: # BOUNDARY T cycle759103 xy63,192 MC1 TS2 phase10 ce_vdp1 audit4b85f9800003c000 reset0; # ARM x64 y192 regs0005874014d4e0007fcc27e1705ff1c0c0 probe00000000.
- **rich/dut_mixed_m3**: # BOUNDARY T cycle923168 xy56,240 MC1 TS2 phase20 ce_vdp1 audit7b81f9800002c000 reset0; # ARM x57 y240 regs0005071014d4e0007fcc27e1705ff1c4c0 probe00000000.
- **rich/dut_pal240**: # BOUNDARY T cycle923168 xy56,240 MC1 TS2 phase20 ce_vdp1 audit2bd9d9800002c000 reset0; # ARM x57 y240 regs0005071014d4e0007fcc27e1705ff1c4e0 probe00000000.
- **g04/dut_pending64**: # BOUNDARY T cycle1573723 xy131,168 MC1 TS2 phase10 ce_vdp1 audit00000000ff83c000 reset0; # ARM x132 y168 regs0005a75614d4e0007fcc27e0005ff1c0a0 probe00000000 audit00000000ff03c000 CPU01f010000000000000000000000000000000000091dff03a004400441f.
- **g04/dut_near**: # BOUNDARY T cycle1573723 xy131,168 MC1 TS2 phase10 ce_vdp1 audit000000000003c000 reset0; # ARM x132 y168 regs0005875614d4e0007fcc27e0005ff1c0a0 probe00000000 audit000000000003c000 CPU01f010000000000000000000000000000000000091dff03a004400441f.
- **g04/dut_late**: # BOUNDARY T cycle1574938 xy254,168 MC1 TS2 phase10 ce_vdp1 audit000000001ffec000 reset0; # ARM x255 y168 regs0005875614d4e0007fcc27e0005ff1c0a0 probe00000000 audit000000003ffec000 CPU01fc0000000000000000000000000000000000008edff045004400441f.
- **g04/dut_overflow**: # BOUNDARY T cycle1573723 xy131,168 MC1 TS2 phase10 ce_vdp1 audit00000000ff83c000 reset0; # ARM x132 y168 regs0005a75614d4e0007fcc27e0005ff1c0a0 probe00000000 audit00000000ff03c000 CPU01f010000000000000000000000000000000000091dff03a004400441f.
- **irq/dut_t0**: # BOUNDARY T cycle677983 xy152,168 MC1 TS2 phase25 ce_vdp1 audit000000000003c000 reset0; # ARM x152 y168 regs0005875814d4c280000c27e0005ff1c1a8 probe00000000.
- **irq/dut_t1**: # BOUNDARY T cycle677628 xy126,168 MC1 TS2 phase0 ce_vdp1 audit000000000002c000 reset0; # ARM x127 y168 regs0005875814d4c280000c27e0005ff1c1a8 probe00000000.
- **bg_pair/dut_h0**: # BOUNDARY T cycle1655738 xy125,192 MC1 TS2 phase20 ce_vdp1 audit626639800003c000 reset0; # ARM x126 y192 regs00050f3e14d4c0013fcc27e0005ff1c0a0 probe00000000 BG4cde008045b7208068bb411200000000.
- **bg_pair/dut_h1**: # BOUNDARY T cycle1655738 xy125,192 MC1 TS2 phase20 ce_vdp1 audit626639800003c000 reset0; # ARM x126 y192 regs00050f3e14d4c0013fcc27e0005ff1c0a0 probe00000000 BG4cde008045b7208068bb411200000000.
- **text_history/dut_h0**: # BOUNDARY T cycle1655733 xy123,192 MC1 TS2 phase0 ce_vdp1 audit1bbd49800003c000 reset0; # ARM x124 y192 regs00050f3e14d4c2403fcc27e0005ff1c280 probe00000000 BG5020f7002032dd000017e87fd8795a93.
- **text_history/dut_h1**: # BOUNDARY T cycle1655733 xy123,192 MC1 TS2 phase0 ce_vdp1 audit1bbd49800003c000 reset0; # ARM x124 y192 regs00050f3e14d4c2403fcc27e0005ff1c280 probe00000000 BG5020ff007a0497005027b80fd8795a93.
- **hl/dut_edges**: # BOUNDARY T cycle677518 xy105,168 MC1 TS2 phase10 ce_vdp1 audit000000000003c000 reset0; # ARM x106 y168 regs0005875814d4e0007fcc27e0005ff1c0a0 probe00000000.
- **ops/dut_write_address**: # BOUNDARY T cycle681988 xy219,169 MC1 TS2 phase10 ce_vdp1 audit000000000003c070 reset0; # ARM x220 y169 regs0005875714c1c04fbfcc27e0005ff1c0a0 probe00000000.
- **ops/dut_vram_write**: # BOUNDARY T cycle676928 xy55,168 MC1 TS2 phase20 ce_vdp1 audit000000000003ca50 reset0; # ARM x56 y168 regs0005875814e9404fffcc27e0005ff1c0a0 probe00000000.
- **ops/dut_partial_control**: # BOUNDARY T cycle677288 xy91,168 MC1 TS2 phase20 ce_vdp1 audit000000000003c6c0 reset0; # ARM x92 y168 regs0005875814db104f7fcc27e0005ff1c0a0 probe00000000.
- **ops/dut_read_setup**: # BOUNDARY T cycle677468 xy109,168 MC1 TS2 phase20 ce_vdp1 audit000000000003c6c0 reset0; # ARM x110 y168 regs0005875814d4404fbfcc27e0005ff1c0a0 probe00000000.
- **ops/dut_first_read**: # BOUNDARY T cycle677578 xy120,168 MC1 TS2 phase10 ce_vdp1 audit000000000002c6c0 reset0; # ARM x121 y168 regs0005875814e9404fffcc27e0005ff1c0a0 probe00000000.
- **ops/dut_next_read**: # BOUNDARY T cycle677818 xy144,168 MC1 TS2 phase10 ce_vdp1 audit000000000002c6c0 reset0; # ARM x145 y168 regs0005875814db00503fcc27e0005ff1c0a0 probe00000000.
- **ops/dut_cram_low**: # BOUNDARY T cycle678488 xy211,168 MC1 TS2 phase20 ce_vdp1 audit000000000003c530 reset0; # ARM x212 y168 regs0005875814d4e0007fcc27e0005ff1c0a0 probe00000000.
- **ops/dut_cram_high**: # BOUNDARY T cycle678668 xy229,168 MC1 TS2 phase20 ce_vdp1 audit000000000003c070 reset0; # ARM x230 y168 regs0005875814c1e000bfcc27e0005ff1c0a0 probe00000000.
- **g04_native/dut_pending**: # BOUNDARY T cycle1573723 xy131,168 MC1 TS2 phase10 ce_vdp1 audit00000000ff83c000 reset0; # ARM x132 y168 regs0005a75614d4e0007fcc27e0005ff1c0a0 probe00000000 audit00000000ff03c000 CPU01f010000000000000000000000000000000000091dff03a004400441f.
- **dual_irq/dut_enabled**: # BOUNDARY T cycle917198 xy97,192 MC1 TS2 phase10 ce_vdp1 audit000000000003c000 reset0; # ARM x98 y192 regs0005874014c1e000800c27e0005ff1c1a8 probe00000000.
- **line_irq/dut_active**: # BOUNDARY T cycle1574113 xy161,168 MC1 TS2 phase25 ce_vdp1 audit000000000002c000 reset0; # ARM x161 y168 regs0005870014d4c280000c27e0005ff1c1a8 probe00000000.
- **memory_events/dut_bus**: # BOUNDARY T cycle678488 xy211,168 MC1 TS2 phase20 ce_vdp1 audit000000000003c530 reset0; # ARM x212 y168 regs0005875814d4e0007fcc27e0005ff1c0a0 probe00000000.
- **bus/dut_fullflush**: # BOUNDARY T cycle1576928 xy55,168 MC1 TS2 phase20 ce_vdp1 audit000000000003ca50 reset0; # ARM x56 y168 regs0005875814e9404fffcc27e0005ff1c0a0 probe00000000.
- **stalls_valid/dut_p1**: # BOUNDARY T cycle910475 xy55,168 MC1 TS2 phase20 ce_vdp1 audit000000000003ca50 reset0; # ARM x56 y168 regs0005875814e9404fffcc27e0005ff1c0a0 probe00000000.
- **stalls_valid/dut_p2**: # BOUNDARY T cycle719426 xy55,168 MC1 TS2 phase20 ce_vdp1 audit000000000003ca50 reset0; # ARM x56 y168 regs0005875814e9404fffcc27e0005ff1c0a0 probe00000000.
- **g04_stalls_valid/dut_pending**: # BOUNDARY T cycle1807291 xy131,168 MC1 TS2 phase10 ce_vdp1 audit00000000ff83c000 reset0; # ARM x132 y168 regs0005a75614d4e0007fcc27e0005ff1c0a0 probe00000000 audit00000000ff03c000 CPU01f010000000000000000000000000000000000091dff03a004400441f.

## Transport and native timing assertions

- text_history/dut_h0: TEXT_HISTORY_RESULT pass0 visiblePixelDiff9 fetchDiff8
- text_history/dut_h0: TEXT_HISTORY_RESULT pass1 visiblePixelDiff9 fetchDiff8
- text_history/dut_h0: TEXT_HISTORY_RESULT pass2 visiblePixelDiff9 fetchDiff8
- text_history/dut_h1: TEXT_HISTORY_RESULT pass0 visiblePixelDiff9 fetchDiff8
- text_history/dut_h1: TEXT_HISTORY_RESULT pass1 visiblePixelDiff9 fetchDiff8
- text_history/dut_h1: TEXT_HISTORY_RESULT pass2 visiblePixelDiff9 fetchDiff8
- hl/dut_edges: FIRST_SP host1 xy87,168
- hl/dut_edges: FIRST_VDP host5 xy87,168 regs0005875814d4e0007fcc27e0005ff1c0a0
- hl/dut_edges: FIRST_PIX host5 xy87,168 regs0005875814d4e0007fcc27e0005ff1c0a0
- hl/dut_edges: FIRST_CPU host15 actualCPU1 MC1 TS3 A006a M11 MREQ1 IO1 RD1 WR1
- hl/dut_edges: FIRST_SP host2 xy87,168
- hl/dut_edges: FIRST_VDP host5 xy87,168 regs0005875814d4e0007fcc27e0005ff1c0a0
- hl/dut_edges: FIRST_CPU host10 actualCPU1 MC1 TS3 A006a M11 MREQ1 IO1 RD1 WR1
- hl/dut_edges: FIRST_PIX host10 xy87,168 regs0005875814d4e0007fcc27e0005ff1c0a0
- hl/dut_edges: FIRST_SP host2 xy106,168
- hl/dut_edges: FIRST_VDP host5 xy106,168 regs0005875814d4e0007fcc27e0005ff1c0a0
- hl/dut_edges: FIRST_PIX host10 xy106,168 regs0005875814d4e0007fcc27e0005ff1c0a0
- hl/dut_edges: FIRST_CPU host15 actualCPU1 MC1 TS3 A006b M11 MREQ1 IO1 RD1 WR1
- hl/dut_edges: FIRST_SP host2 xy106,168
- hl/dut_edges: FIRST_VDP host5 xy106,168 regs0005875814d4e0007fcc27e0005ff1c0a0
- hl/dut_edges: FIRST_PIX host10 xy106,168 regs0005875814d4e0007fcc27e0005ff1c0a0
- hl/dut_edges: FIRST_CPU host15 actualCPU1 MC1 TS3 A006b M11 MREQ1 IO1 RD1 WR1
- hl/dut_edges: FIRST_SP host2 xy106,168
- hl/dut_edges: FIRST_VDP host5 xy106,168 regs0005875814d4e0007fcc27e0005ff1c0a0
- hl/dut_edges: FIRST_PIX host10 xy106,168 regs0005875814d4e0007fcc27e0005ff1c0a0
- hl/dut_edges: FIRST_CPU host15 actualCPU1 MC1 TS3 A006b M11 MREQ1 IO1 RD1 WR1
- hl/dut_edges: FIRST_SP host2 xy106,168
- hl/dut_edges: FIRST_VDP host5 xy106,168 regs0005875814d4e0007fcc27e0005ff1c0a0
- hl/dut_edges: FIRST_PIX host10 xy106,168 regs0005875814d4e0007fcc27e0005ff1c0a0
- hl/dut_edges: FIRST_CPU host15 actualCPU1 MC1 TS3 A006b M11 MREQ1 IO1 RD1 WR1
- g04_native/reference_pending: PASS G04_NATIVE hostclocks10000 shift14 IRQ CPU230 VDP136 RAM lastXafterFirstVDP
- g04_native/dut_pending: PASS G04_NATIVE hostclocks10000 shift14 IRQ CPU230 VDP136 RAM lastXafterFirstVDP
- g04_native/dut_pending: PASS G04_NATIVE hostclocks10000 shift14 IRQ CPU230 VDP136 RAM lastXafterFirstVDP
- g04_native/dut_pending: PASS G04_NATIVE hostclocks10000 shift14 IRQ CPU230 VDP136 RAM lastXafterFirstVDP
- g04_native/dut_pending: PASS G04_NATIVE hostclocks10000 shift14 IRQ CPU230 VDP136 RAM lastXafterFirstVDP
- dual_irq/reference_enabled: DUAL_INDEPENDENT_IRQ clocks1140 handlerRAM02
- dual_irq/dut_enabled: DUAL_INDEPENDENT_IRQ clocks2310 handlerRAM02
- stalls_valid/dut_p1: TRANSPORT_DURATION save1 profile1 hostclocks151968
- stalls_valid/dut_p1: TRANSPORT_DURATION save0 profile1 hostclocks150467
- stalls_valid/dut_p1: TRANSPORT_DURATION save1 profile1 hostclocks151953
- stalls_valid/dut_p1: TRANSPORT_DURATION save0 profile1 hostclocks155397
- stalls_valid/dut_p1: TRANSPORT_DURATION save0 profile1 hostclocks155442
- stalls_valid/dut_p1: TRANSPORT_DURATION save0 profile1 hostclocks155407
- stalls_valid/dut_p2: TRANSPORT_DURATION save1 profile2 hostclocks50319
- stalls_valid/dut_p2: TRANSPORT_DURATION save0 profile2 hostclocks61067
- stalls_valid/dut_p2: TRANSPORT_DURATION save1 profile2 hostclocks50282
- stalls_valid/dut_p2: TRANSPORT_DURATION save0 profile2 hostclocks62907
- stalls_valid/dut_p2: TRANSPORT_DURATION save0 profile2 hostclocks62967
- stalls_valid/dut_p2: TRANSPORT_DURATION save0 profile2 hostclocks62707
- g04_stalls_valid/dut_pending: TRANSPORT_DURATION save1 profile1 hostclocks151974
- g04_stalls_valid/dut_pending: TRANSPORT_DURATION save0 profile1 hostclocks150477
- g04_stalls_valid/dut_pending: TRANSPORT_DURATION save1 profile1 hostclocks151999
- g04_stalls_valid/dut_pending: PASS G04_NATIVE hostclocks10000 shift14 IRQ CPU230 VDP136 RAM lastXafterFirstVDP
- g04_stalls_valid/dut_pending: TRANSPORT_DURATION save0 profile1 hostclocks155417
- g04_stalls_valid/dut_pending: PASS G04_NATIVE hostclocks10000 shift14 IRQ CPU230 VDP136 RAM lastXafterFirstVDP
- g04_stalls_valid/dut_pending: TRANSPORT_DURATION save0 profile1 hostclocks155372
- g04_stalls_valid/dut_pending: PASS G04_NATIVE hostclocks10000 shift14 IRQ CPU230 VDP136 RAM lastXafterFirstVDP
- g04_stalls_valid/dut_pending: TRANSPORT_DURATION save0 profile1 hostclocks155382
- g04_stalls_valid/dut_pending: PASS G04_NATIVE hostclocks10000 shift14 IRQ CPU230 VDP136 RAM lastXafterFirstVDP

## Region, height and rendering windows

| Reference | Region / GG | Requested height boundary | Samples | Known rows | Distinct line0 / line1 x1..256 |
|---|---|---:|---:|---:|---|
| rich/reference_mode4 | PAL0 / GG0 | 192 | 170000 | 170000 | 256 / 256 |
| rich/reference_gg | PAL0 / GG1 | 168 | 65000 | 65000 | 256 / 256 |
| rich/reference_text | PAL0 / GG0 | 192 | 42000 | 42000 | 256 / 256 |
| rich/reference_graphics1 | PAL0 / GG0 | 192 | 42000 | 42000 | 256 / 256 |
| rich/reference_graphics2 | PAL0 / GG0 | 192 | 42000 | 42000 | 256 / 256 |
| rich/reference_mixed_m3 | PAL0 / GG0 | 240 | 42000 | 42000 | 256 / 256 |
| rich/reference_sms224 | PAL0 / GG0 | 224 | 42000 | 42000 | 256 / 256 |
| rich/reference_pal240 | PAL1 / GG0 | 240 | 60000 | 60000 | 256 / 256 |
| rich/reference_scroll | PAL0 / GG0 | 192 | 42000 | 42000 | 256 / 256 |
| text_history/reference_h0 | PAL0 / GG0 | 192 | 42000 | 42000 | 256 / 256 |
| text_history/reference_h1 | PAL0 / GG0 | 192 | 42000 | 42000 | 256 / 256 |
| mode_switch/reference | PAL0 / GG0 | 192 | 42000 | 42000 | 256 / 256 |
