# Complete source register declaration index

Source: committed v19 rtl/savestates.sv. Width is declared, named nodes are surviving own TimeQuest register nodes; zero does not prove an independent zero-cost cone. Output ports are included. ddram_cmd_* are combinational reg variables, not flops. Reset expression is listed only where explicit. All sequential data otherwise holds absent an assigned event, except default-cleared strobes and continuously running timer/control updates. Semantic group lifetimes and consumers are in review.md. Full assignment expressions/locations are in inventory.json.

|Name|RTL line|Width|Named nodes|Group|Explicit reset|Write locations|
|---|---:|---:|---:|---|---|---|
|ss_freeze|54|1|1|presence, handshake and selectors|0|1277, 1315, 1354, 1364, 1376, 2905, 2912, 2925|
|ss_cpu_prepare|56|1|1|presence, handshake and selectors|0|2887, 2894, 2923|
|clock_phase_set|62|1|1|presence, handshake and selectors|0|2895, 2905, 2923|
|z80_nmi_hold|84|1|1|presence, handshake and selectors|0|1320, 2886, 2913, 2926|
|z80_dir|86|230|230|registered restore data|none explicit|2811|
|z80_set|87|1|1|presence, handshake and selectors|0|1236, 2812|
|vdp_regs_in|104|136|135|registered restore data|none explicit|2813|
|vdp_regs_set|105|1|0|presence, handshake and selectors|0|1237, 2814|
|cram_A|109|5|5|presence, handshake and selectors|none explicit|2840|
|cram_D|110|12|12|presence, handshake and selectors|none explicit|2841|
|cram_wr|111|1|1|presence, handshake and selectors|0|1238, 2839|
|vram_en|114|1|1|DMA and DDR transport|0|1755, 1807, 1818, 1856, 1858, 1871|
|vram_A|115|15|15|DMA and DDR transport|none explicit|1756, 1808, 1824, 1842, 1852|
|vram_WE|117|1|1|DMA and DDR transport|0|779, 1244|
|vram_WA|118|15|15|DMA and DDR transport|none explicit|780|
|vram_WD|119|8|8|DMA and DDR transport|none explicit|781|
|psg_in|123|56|52|registered restore data|none explicit|2815|
|psg_set|124|1|0|presence, handshake and selectors|0|1239, 2816|
|psg_ext_in|129|96|96|registered restore data|0|2818|
|psg2_ext_in|130|96|96|registered restore data|0|2819|
|psg_div_in|132|4|4|registered restore data|0|2820|
|audio_control_in|134|11|11|registered restore data|0|2821|
|audio_phase_in|140|1|1|registered restore data|0|2906|
|audio_ext_set|141|1|1|presence, handshake and selectors|0|1258, 2822|
|audio_phase_set|142|1|1|presence, handshake and selectors|0|1259, 2906|
|mapper_history_in|148|18|18|registered restore data|MAPPER_HISTORY_LEGACY|1418|
|mapper_in|149|64|64|registered restore data|none explicit|1417|
|mapper_set|150|1|1|presence, handshake and selectors|0|1240, 1419|
|evolution_in|156|160|156|registered restore data|160'd0|1420|
|evolution_set|157|1|0|presence, handshake and selectors|0|1241, 1421|
|eeprom_ext_in|165|128|81|registered restore data|0|2868|
|eeprom_full|166|1|1|presence, handshake and selectors|0|2106, 2544, 2558|
|nvram_refill|167|1|1|DMA and DDR transport|0|1327, 2865|
|gun_in|170|46|46|registered restore data|0|2136, 2516|
|gun_set|171|1|1|presence, handshake and selectors|0|1254, 2136, 2516|
|gun_valid|172|1|1|presence, handshake and selectors|0|2103, 2136, 2461, 2469|
|paddle_in|175|32|32|registered restore data|0|2875|
|paddle_set|176|1|0|presence, handshake and selectors|0|1255, 2875|
|paddle_valid|177|1|1|presence, handshake and selectors|0|2104, 2450|
|tap_in|179|19|19|registered restore data|0|2876|
|tap_set|180|1|0|presence, handshake and selectors|0|1256, 2876|
|tap_valid|181|1|1|presence, handshake and selectors|0|2105, 2438|
|sc_ram_restored|183|1|1|presence, handshake and selectors|0|1243, 2866|
|eeprom_in|185|64|57|registered restore data|none explicit|2868|
|eeprom_set|186|1|1|presence, handshake and selectors|0|1242, 2869|
|wram_A|189|14|14|DMA and DDR transport|none explicit|1864, 1877, 1922, 1938|
|wram_WE|191|1|1|DMA and DDR transport|0|1245, 2728, 2735|
|wram_WA|192|14|14|DMA and DDR transport|none explicit|2729, 2736|
|wram_WD|193|8|8|DMA and DDR transport|none explicit|2730, 2737|
|nvram_A|196|15|15|DMA and DDR transport|none explicit|1899, 1957, 1978, 1994|
|nvram_WE|198|1|1|DMA and DDR transport|0|1246, 2774, 2781|
|nvram_WA|199|15|15|DMA and DDR transport|none explicit|2775, 2782|
|nvram_WD|200|8|8|DMA and DDR transport|none explicit|2776, 2783|
|vdp2_regs_in|207|136|135|registered restore data|none explicit|2832|
|vdp2_regs_set|208|1|1|presence, handshake and selectors|0|1247, 2833|
|cram2_A|212|5|5|presence, handshake and selectors|none explicit|2845|
|cram2_D|213|12|12|presence, handshake and selectors|none explicit|2846|
|cram2_wr|214|1|1|presence, handshake and selectors|0|1248, 2844|
|vram2_en|217|1|1|DMA and DDR transport|0|1817, 1895, 1946|
|vram2_A|218|15|15|DMA and DDR transport|none explicit|1823, 1841, 1888, 1947|
|vram2_WE|220|1|1|DMA and DDR transport|0|775, 1250|
|vram2_WA|221|15|15|DMA and DDR transport|none explicit|776|
|vram2_WD|222|8|8|DMA and DDR transport|none explicit|777|
|psg2_in|226|56|52|registered restore data|none explicit|2834|
|psg2_set|227|1|0|presence, handshake and selectors|0|1249, 2835|
|md_in|231|46|46|registered restore data|0|2873|
|md_set|232|1|0|presence, handshake and selectors|0|1253, 2873|
|md_valid|233|1|1|presence, handshake and selectors|0|2100, 2405|
|gg_in|235|128|114|registered restore data|GG_RESET|2809|
|gg_set|236|1|0|presence, handshake and selectors|0|1252, 2810|
|io_in|238|32|32|registered restore data|32'd0|2521, 2825|
|io_set|239|1|1|presence, handshake and selectors|0|1251, 2522, 2826|
|video_state_in|243|22|22|registered restore data|22'd0|2827, 2896, 2903|
|video_state_set|244|1|1|presence, handshake and selectors|0|1257, 2828, 2896, 2903, 2905|
|DDRAM_ADDR|247|29|26|DMA and DDR transport|none explicit|1134, 1146, 2938, 2944|
|DDRAM_DIN|248|64|64|DMA and DDR transport|none explicit|1135, 2939, 2944|
|DDRAM_BE|249|8|3|DMA and DDR transport|none explicit|1136, 1147, 2940, 2945|
|DDRAM_WE|250|1|1|DMA and DDR transport|0|1137, 1148, 1157, 2937, 2943|
|DDRAM_RD|253|1|1|DMA and DDR transport|0|1138, 1149, 1158, 2936, 2943|
|DDRAM_BURSTCNT|254|8|2|DMA and DDR transport|8'd1|1139, 1150, 2941, 2945|
|gg_snap|344|128|128|other snapshots|GG_RESET|1350, 2099, 2381, 2386, 2387|
|gg_word|345|1|1|presence, handshake and selectors|0|1557, 1566, 2364, 2382|
|md_snap|348|46|46|other snapshots|0|1391, 2100, 2408|
|has_md_ext|349|1|1|presence, handshake and selectors|0|2100, 2352|
|eeprom_ext_snap|355|128|128|other snapshots|0|1396, 2106, 2540, 2543, 2545, 2546, 2547|
|eeprom_exists_snap|356|1|1|other snapshots|0|1397|
|has_eeprom_tag|356|1|1|presence, handshake and selectors|0|2106, 2351|
|eeprom_ext_word|356|1|1|presence, handshake and selectors|0|1726, 1734, 2528, 2540|
|sc_size_snap|359|2|2|other snapshots|0|1341|
|has_sc_tag|360|1|1|presence, handshake and selectors|0|1342, 2350|
|sc_ram_full|360|1|1|presence, handshake and selectors|0|1342, 2427|
|has_full_sram|361|1|1|presence, handshake and selectors|0|1278, 2336|
|tap_snap|365|19|19|other snapshots|0|1394, 2105, 2437|
|has_tap_tag|366|1|1|presence, handshake and selectors|0|2105, 2349|
|paddle_snap|370|32|32|other snapshots|0|1393, 2104, 2449|
|has_paddle_tag|371|1|1|presence, handshake and selectors|0|2104, 2348|
|gun_snap|374|46|46|other snapshots|0|1392, 2103, 2460|
|has_gun_tag|375|1|1|presence, handshake and selectors|0|2103, 2347|
|mapper_history_snap|384|18|18|other snapshots|MAPPER_HISTORY_LEGACY|1390, 2101, 2478, 2486|
|has_mapper_history|385|1|1|presence, handshake and selectors|0|2101, 2346|
|has_evolution_history|395|1|1|presence, handshake and selectors|0|2102, 2341|
|evolution_history_valid|395|1|1|presence, handshake and selectors|0|2102, 2496|
|do_save|397|1|1|presence, handshake and selectors|none explicit|1284, 1288|
|psg_ext_snap|416|96|96|other snapshots|none explicit|1400, 2274, 2275|
|psg2_ext_snap|416|96|96|other snapshots|none explicit|1401, 2277, 2278|
|audio_div_snap|417|4|4|other snapshots|none explicit|1402, 2254|
|audio_control_snap|418|11|11|other snapshots|none explicit|1403, 2236|
|audio_phase_snap|419|1|1|other snapshots|none explicit|1280, 1330, 2255, 2334|
|has_audio_ext|419|1|1|presence, handshake and selectors|0|1279, 2281|
|audio_last_snap|420|16|16|other snapshots|0|1279, 1331, 2276|
|has_audio_last|421|1|1|presence, handshake and selectors|0|1279, 1332, 2253|
|audio_word|424|3|3|presence, handshake and selectors|0|1405, 2025, 2256, 2285|
|dout_latch|465|64|64|DMA and DDR transport|64'd0|1455, 1647, 1694, 2117, 2128, 2155, 2164, 2188, 2208, 2232, 2250, 2268, 2295, 2319, 2331, 2378, 2402, 2407, 2424, 2435, 2439, 2447, 2450, 2458, 2467, 2476, 2484, 2493, 2502, 2525, 2537, 2556, 2588, 2611, 2633, 2651, 2722, 2768|
|fm_capture|466|1|1|presence, handshake and selectors|0|1234, 1406|
|fm_apply|466|1|1|presence, handshake and selectors|0|1234, 1470|
|fm_legacy|466|1|1|presence, handshake and selectors|0|1234, 1470|
|fm_bulk_read|466|1|1|presence, handshake and selectors|0|1234, 1446|
|fm_bulk_write|466|1|1|presence, handshake and selectors|0|1234, 1461|
|has_fm|466|1|1|presence, handshake and selectors|0|1278, 2335|
|fm_word|467|7|7|presence, handshake and selectors|0|1451, 1459, 1467, 1689|
|bg_snap|588|139|139|background rings|0|1333, 1684, 1685, 1705, 1706, 2093|
|bg2_snap|588|139|139|background rings|0|1333, 1681, 1682, 1702, 1703, 2093|
|bg_word|589|2|2|presence, handshake and selectors|0|1676, 1688, 1690, 1698, 1711, 1712, 2093|
|bg_second|590|1|1|presence, handshake and selectors|0|1676, 1688, 1698, 1711, 2093|
|has_background|590|1|1|presence, handshake and selectors|0|1334, 2093, 2340|
|sprite_snap|605|4800|4800|sprite rings|0|1335, 1639, 1661, 2092|
|sprite2_snap|605|4800|4800|sprite rings|0|1336, 1638, 1660, 2092|
|sprite_word|606|7|7|presence, handshake and selectors|0|1634, 1641, 1643, 1654, 1667, 1668|
|sprite_second|607|1|1|presence, handshake and selectors|0|1634, 1641, 1654, 1667|
|has_restart|607|1|1|presence, handshake and selectors|0|2092, 2339|
|phase_snap|608|2|2|other snapshots|0|1316, 1654, 2092|
|capture_tick_snap|609|1|1|other snapshots|1|1316, 1654|
|state|625|7|108|FSM encoding|ST_IDLE|1267, 1286, 1290, 1321, 1356, 1369, 1381, 1406, 1432, 1434, 1445, 1446, 1447, 1450, 1451, 1453, 1458, 1459, 1460, 1461, 1464, 1466, 1467, 1471, 1473, 1478, 1493, 1507, 1527, 1536, 1543, 1550, 1558, 1565, 1573, 1580, 1587, 1594, 1601, 1607, 1613, 1619, 1625, 1630, 1634, 1642, 1650, 1651, 1652, 1655, 1658, 1664, 1676, 1689, 1697, 1698, 1699, 1708, 1720, 1727, 1733, 1747, 1759, 1772, 1792, 1811, 1855, 1867, 1880, 1891, 1900, 1901, 1950, 1960, 1962, 1996, 2013, 2024, 2032, 2038, 2045, 2062, 2068, 2079, 2110, 2121, 2142, 2147, 2179, 2196, 2222, 2238, 2242, 2258, 2261, 2271, 2283, 2304, 2307, 2311, 2324, 2343, 2366, 2369, 2390, 2393, 2411, 2414, 2417, 2429, 2441, 2452, 2462, 2471, 2479, 2488, 2497, 2508, 2510, 2529, 2531, 2548, 2570, 2579, 2600, 2623, 2642, 2679, 2687, 2696, 2705, 2708, 2752, 2755, 2791, 2850, 2857, 2879, 2888, 2897, 2907, 2916, 2927, 2929|
|cur_slot|635|2|2|operation identity|none explicit|1285, 1289|
|base_addr|636|29|5|operation identity|none explicit|1307|
|ss_change_det|637|32|32|operation identity|0|2066|
|cur_magic|638|32|1|operation identity|MAGIC|1309|
|cur_game_id|639|32|32|operation identity|0|1310|
|cur_bios_mode|640|1|1|operation identity|0|1308|
|word_cnt|643|12|12|DMA and DDR transport|none explicit|1430, 1757, 1809, 1837, 1853, 1865, 1878, 1889, 1899, 1934, 1948, 1958, 1990, 2303, 2577, 2640, 2667, 2677, 2685, 2694, 2703, 2742, 2750, 2788|
|cram_idx|644|3|3|presence, handshake and selectors|none explicit|1508, 1529, 1745, 1771, 1791, 1794, 2195, 2225, 2569, 2593, 2598, 2614, 2615, 2616, 2617, 2618, 2621|
|cram_entry|645|5|5|presence, handshake and selectors|none explicit|1435, 2221, 2709, 2756, 2792, 2852|
|cpu_idx|646|3|3|presence, handshake and selectors|none explicit|1479, 1496, 2141, 2181|
|vdp_idx|647|3|1|presence, handshake and selectors|none explicit|1494, 1510, 1746, 1774, 2178, 2198|
|flush_cnt|648|20|20|timers and drain/watchdog|0|2849, 2859|
|unfreeze_cnt|649|8|8|timers and drain/watchdog|0|2078, 2145, 2878, 2884, 2905, 2918|
|z80_snap|651|230|230|CPU snapshots|none explicit|1317, 2158, 2159, 2160, 2167, 2168, 2169, 2170, 2172|
|nmi_snap|652|3|3|CPU snapshots|3'b001|1318, 2090, 2162|
|restart_snap|653|3|3|CPU snapshots|0|1319, 2091, 2163|
|has_restart_context|654|1|1|presence, handshake and selectors|0|2091, 2338|
|restart_padding_ok|654|1|1|presence, handshake and selectors|1|2091, 2164|
|has_nmi_history|658|1|1|presence, handshake and selectors|0|2090, 2337|
|nmi_padding_ok|658|1|1|presence, handshake and selectors|1|2090, 2165|
|vdp_snap|662|136|136|other snapshots|none explicit|1337, 2097, 2191, 2192, 2356, 2359|
|cram_snap|663|384|384|CRAM snapshots|none explicit|1338, 2211, 2212, 2213, 2214, 2215, 2216|
|psg_snap|664|56|56|other snapshots|none explicit|1339, 1398, 2234|
|mapper_snap|665|64|64|other snapshots|none explicit|1340, 1389, 2297|
|evolution_snap|666|160|156|other snapshots|none explicit|1343, 2102, 2299, 2322, 2495, 2505, 2560, 2563|
|vdp2_snap|668|136|136|other snapshots|none explicit|1345, 2098, 2357, 2360, 2592, 2597|
|cram2_snap|675|384|384|CRAM snapshots|none explicit|1346, 2614, 2615, 2616, 2617, 2618, 2620|
|psg2_snap|676|56|56|other snapshots|none explicit|1347, 1399, 2635|
|io_snap|677|32|32|other snapshots|32'd0|1349, 2321|
|video_snap|678|22|22|other snapshots|22'd0|1351, 2095, 2345|
|eeprom_snap|679|64|64|other snapshots|none explicit|1395, 2108, 2561, 2564|
|vram_pipe|693|3|3|DMA and DDR transport|none explicit|1754, 1806, 1821, 1851, 1887, 1945|
|vram_save_addr|694|15|15|DMA and DDR transport|none explicit|1751, 1803, 1840, 1848, 1884, 1942|
|vram_load_addr|695|15|15|DMA and DDR transport|none explicit|2300, 2574, 2637, 2658, 2663, 2674, 2700, 2747|
|vram_byte_cnt|696|3|3|DMA and DDR transport|none explicit|1752, 1804, 1831, 1849, 1885, 1943, 2301, 2575, 2638, 2652, 2659, 2665, 2675, 2701, 2748|
|vram_word_buf|697|64|56|DMA and DDR transport|none explicit|1753, 1805, 1829, 1850, 1886, 1944|
|vram_load_active|698|1|1|DMA and DDR transport|0|2302, 2576, 2639, 2653, 2664, 2676, 2702, 2749|
|vram_d_latch|702|8|8|DMA and DDR transport|none explicit|1908, 2951|
|vram_d_latched|703|1|1|DMA and DDR transport|none explicit|1758, 1810, 1828, 1854, 1890, 1909, 1949, 2951|
|wram_save_addr|706|14|14|DMA and DDR transport|none explicit|1860, 1873, 1937|
|wram_load_addr|707|14|14|DMA and DDR transport|none explicit|2682, 2691, 2731, 2738|
|wram_byte_cnt|708|3|3|DMA and DDR transport|none explicit|1861, 1874, 1929, 2683, 2692, 2723, 2732, 2740|
|wram_word_buf|709|64|56|DMA and DDR transport|none explicit|1862, 1875, 1927|
|wram_pipe|710|2|2|DMA and DDR transport|none explicit|1863, 1876, 1920|
|wram_load_active|711|1|1|DMA and DDR transport|0|2684, 2693, 2724, 2739|
|wram_d_latch|712|8|8|DMA and DDR transport|none explicit|1967, 2954|
|wram_d_latched|713|1|1|DMA and DDR transport|none explicit|1866, 1879, 1926, 1968, 2954|
|nvram_save_addr|716|15|15|DMA and DDR transport|none explicit|1897, 1953, 1993|
|nvram_load_addr|717|15|15|DMA and DDR transport|none explicit|1427, 2777, 2784|
|nvram_byte_cnt|718|3|3|DMA and DDR transport|none explicit|1428, 1897, 1954, 1985, 2769, 2778, 2786|
|nvram_word_buf|719|64|56|DMA and DDR transport|none explicit|1898, 1955, 1983|
|nvram_pipe|720|2|2|DMA and DDR transport|none explicit|1898, 1956, 1976|
|nvram_load_active|721|1|1|DMA and DDR transport|0|1429, 2770, 2785|
|nvram_d_latch|722|8|8|DMA and DDR transport|none explicit|2000, 2957|
|nvram_d_latched|723|1|1|DMA and DDR transport|none explicit|1899, 1959, 1982, 2001, 2957|
|dout_expected|742|1|1|DMA and DDR transport|0|1151, 1265, 1365, 1455, 1647, 1694, 2116, 2127, 2154, 2187, 2207, 2231, 2249, 2267, 2294, 2318, 2330, 2377, 2401, 2424, 2435, 2447, 2458, 2467, 2476, 2484, 2493, 2502, 2525, 2537, 2555, 2587, 2610, 2632, 2650, 2721, 2767|
|ddram_watchdog|747|25|30|timers and drain/watchdog|0|1266, 1269, 1271|
|freeze_drain_cnt|751|6|6|timers and drain/watchdog|0|1355, 1367, 1371, 2031, 2037, 2039, 2061, 2067, 2076, 2081|
|op_cooldown|753|28|28|timers and drain/watchdog|0|1282, 2915|
|is_old_format|754|1|1|presence, handshake and selectors|0|1278, 2119, 2146|
|ddram_cmd_rd|790|1|0|presence, handshake and selectors|none explicit||
|ddram_cmd_we|790|1|0|presence, handshake and selectors|none explicit||
|ddram_cmd_addr|791|29|0|presence, handshake and selectors|none explicit||
|ddram_cmd_data|792|64|0|presence, handshake and selectors|none explicit||
|ddram_cmd_be|793|8|0|presence, handshake and selectors|none explicit||
