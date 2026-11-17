# F13 mapper state inventory

Source: committed `rtl/mapper_detect.vhd`, `rtl/mapper_ctrl.vhd`, their instances and packing in `rtl/system.vhd`. A = architectural mapper state; B = future-relevant detection history; C = derived/reconstructable; D = diagnostic/dead history; E = media/host state; F = reachability needs qualification. Widths below are logical widths, not Quartus allocation. Integer ranges are retained explicitly.

For the runtime detector, **R** means synchronous RESET_n=0 or bootloader_n=0. R clears all runtime flags/history and timer. Restore has priority over bootloader and freeze, but below reset. **W** means bootloader_n=1, no manual force, not frozen, and old timer <65535. Runtime state is not reset directly by ROMEN: top-level cartridge download holds reset while media is replaced. For the controller, reset is asynchronous; BIOS handoff and game launch have additional initialization described below.

| Persistent item | Width / initial or reset | Update, consumers, lifetime | mapper_set / current serialization | Class / future addressing |
|---|---|---|---|---|
| sega_mapper_write_seen | 1 / 0 at R | W, memory WR at FFFC–FFFF sets 1. Suppresses Wonder Kid, Dahjee, and first 4PAK selection. Remains relevant after timer saturates because last two consumers are outside W. | cleared / absent | B; ROM and RAM |
| bank_write_seen | 1 / 0 at R | W memory writes at 4000,8000,A000,3FFE,7FFF,BFFF,FFFC–FFFF set 1. Consumed only at old timer=65534 for 4-page linear or 6-page Sega-locked fallback. Irrelevant once terminal decision has executed. | cleared / absent | B before decision, D afterward; ROM/write acceptance |
| mapper_detect_ticks | 16 / 0 at R | Increments once per unfrozen host clock after BIOS handoff, saturates 65535. Gates Sega/bank evidence and Wonder Kid; schedules fallback at 65534. No CPU CE qualification. | assigned 65535 / absent | B while active; C terminal after decisions; ROM |
| wonderkid_write_count | integer 0..3 (2 bits) / 0 at R | W eligible 8000 level increments to 2; old count=1 plus AB header sets Wonder Kid. FFFC–FFFF/3FFE/7FFF/BFFF reset it. This counts host-clock samples, **not distinct CPU writes**. Saturated 2 cannot retrigger recognition; 1 can. | cleared / absent | B/F for count=1; accepted-boundary relevance qualified below |
| detect_dahjee_a | 1 / 0 at R | Eligible AB-header write 2000–3FFF except 3FFE, SMS, no Sega history; not limited by timer. Sticky until R/restore. | bit48 / saved via effective mapper_dahjee_a | A; RAM enable and linear ROM |
| detect_linear | 1 / 0 at R | 4 ROM pages, no bank evidence at timer65534; sticky. | bit63 / saved | A; linear ROM |
| detect_sega_locked | 1 / 0 at R | 6 ROM pages, no bank evidence at timer65534; sticky. | bit49 / saved | A; blocks bank writes |
| detect_wonderkid | 1 / 0 at R | Two eligible 8000 samples and AB header in W; sticky. | bit62 / saved | A; mapper startup banks and 8000 writes |
| detect_castle | 1 / 0 at R | No runtime recognition assignment; legacy restore only. Does not select Castle hardware. ORed with static Castle in output bit61 for RAM snapshot compatibility. | bit61 / saved | D for selection; A compatibility RAM predicate |
| bank0..bank3 | 4×8 / 0,1,2,3 reset | Production Sega/Codies/4PAK/Zemina/Korean maps; Wonder Kid initialization; BIOS handoff and Evolution launch restore defaults. Guarded writes and force precedence in mapper_ctrl. | standard bytes0..3; Evolution bytes5..2; System E excludes bank0 / saved | A; ROM |
| jang_bank1..4, jang_rev1..4 | 4×6 + 4×1 / banks2,3,4,5 and rev0 at reset | Janggun writes4000,6000,8000,A000 and paired FFFE/FFFF; handoff resets. | packed 4×8 with pad bits / saved | A; ROM and bit reversal |
| nvram_e, nvram_ex, nvram_p, nvram_cme | 4×1 / 0 reset/handoff | Sega FFFC control; Codies4000 bit7. | bits50..53, cleared for Evolution / saved | A; RAM enable, bank, persistence |
| mapper_codies, mapper_codies_lock | 2×1 / 0 reset | Static/forced Codies on reset or BIOS handoff; Sega writes clear provisional Codies under guards. BIOS active clears these if no OSD lock. | bits58,60; Evolution clears / saved | A; mapper selection and banking |
| lock_mapper_B | 1 / 0 reset | Written on Codies/Wonder Kid initialization and BIOS/reset transitions, restored and packed, but has no current mapper decision/address consumer. | bit59; Evolution clears / saved | D; retained compatibility/debug bit, not a global finalization gate |
| mapper_4pak | 1 / 0 reset | First eligible3FFE write, with no Sega evidence and higher-priority mapper branches inactive; then sticky until reset/restore. No counter or timer guard. | bit57; Evolution clears / saved | A; ROM |
| pak4_reg0 | 8 / 0 reset | 4PAK3FFE and first selection. Equals bank0 whenever 4PAK active. | restored from byte0 except System E / bank0 alias saved | C when active; ROM bank2 high part |
| pak4_reg2 | 8 / 0 reset | 4PAKBFFF or first selection sets0. | byte4 / saved | A; ROM bank2 |
| nem_bank0 | 8 / 0 declaration/reset | First post-reset clock selects last 8K page for CRC Nemesis, otherwise0. | byte5 / saved | A; ROM |
| mapper_wonderkid_prev | 1 / 0 reset | Every ordinary host clock follows effective mapper_wonderkid; rising edge initializes banks and lock_B. | primed from **current effective** mapper_wonderkid / not separately saved | C reconstructable from restored effective flag, but current priming is incorrect; edge.log confirms first-load bank destruction and repeat-load dependence |
| reset_n_prev | 1 / 0 reset | Follows RESET_n; generates first post-reset initialization. | primed from current RESET_n / absent | C; raw reset is not loaded from the snapshot |
| bootloader_n_prev | 1 / 0 reset | Follows BIOS handoff; rising edge initializes banks, even frozen. | primed from current boot input / absent | C reconstructable from restored mapper bit54 (or Evolution active cart1), but currently primed from discarded boot state; boot_edge.log confirms first-load bank destruction |
| last_read_addr | 16 / uninitialized, no reset assignment | Every ce_z80 memory-read level (WR high,MREQ low) remembers A; inhibits Korean A000 write after A000 read. Not detection, no mapper choice consumer. | unchanged / absent | architectural bus history outside F13 detection scope; no separate finding investigated |
| eeprom_soft_reset | 1 / initial0; ordinary clock defaults0 | One-cycle result of EEPROM FFFC bit7; cart EEPROM protocol consumes it. | defaults0 / EEPROM protocol saved separately | transient control, outside history selection; no new payload proposed |

Media metadata below is retained for the same downloaded cartridge across load, independent of runtime reset. None is changed by mapper_set or ss_freeze. None is restored from the mapper payload (even packed static Zemina bit55 is informational on load). These are E after download, with scanner work C during download. Same-media identity is required; restoring across different media is not a history reconstruction policy.

| Persistent media item | Width / initialization | Update / clear / consumer | Classification and addressing |
|---|---|---|---|
| rom_size_pages | 8 / 0 | ROMEN+ROMCL highest page+1, address0 restarts; fallback, Zemina size, Nemesis startup | E; ROM |
| rom_crc16_run | 16 / FFFF | ROMCL each downloaded byte; each8K block restarts; Wonder Kid and Nemesis signatures | E; ROM |
| rom_crc32 | 32 / FFFFFFFF | ROMCL each byte; address0 restarts; Janggun and EEPROM identities | E; ROM/RAM |
| rom_page0_byte0, rom_page0_byte1 | 2×8 / FF | Address0 initializes then captures byte0; byte1 at address1; Wonder Kid and Dahjee AB guards | E; ROM/RAM |
| detect_zemina_static | 1 / 0 | Clear address0; final first32K byte compares counts; use_zem guards require >8 pages and SMS | E; ROM |
| zem_scan_state | integer0..2 (2 bits) / 0 | ROMCL opcode/operand scanner; reset address0 | C during download, D afterward |
| zem_scan_lo | 8 / 0 | Saves opcode low operand; reset address0 | C during download, D afterward |
| zem_count_0002, zem_count_ffff | 2×integer0..127 (7 bits each) / 0 | Saturating matching opcode counts in first32K; reset address0; final Zemina compare | C during download, D afterward |
| detect_dahjee_static | 1 / 0 | Clear address0; final32K byte sets if blank2000–3FFF, >10 relevant stores and count23>=countDEF | E; RAM/ROM |
| dahjee_prev2, dahjee_prev1 | 2×8 / 00 | ROMCL rolling opcode operands; address0 sets prev2=0,prev1=byte0 | C during download, D afterward |
| dahjee_skip | integer0..2 (2 bits) / 0 | Skip two samples after matching destination; address0 resets | C during download, D afterward |
| dahjee_count_23, dahjee_count_def | 2×integer0..16383 (14 bits each) / 0 | Count matching stores; address0 resets; static Dahjee final compare | C during download, D afterward |
| dahjee_region_ff | 1 / declaration0, newdownload1 | Cleared by non-FF byte2000–3FFF; static Dahjee final gate | C during download, E result afterward |
| codies_byte_fe0, codies_byte_fe3 | 2×8 / FF | clk_sys samples ROMEN at7FE0/7FE3; address0 resets | C during download, E afterward |
| detect_codies_static | 1 / 0 | clk_sys address7FEF checks stored header and byte0; address0 or recognized EEPROM clears | E; ROM |
| castle_signature_match | 10 / 0 | ROMCL independently tracks exact signature bytes1CC3–1CCC; address0 clears | C during download, E afterward |
| detect_castle_static | 1 / 0 | ROMCL derives from signature match vector; address0 clears | E; RAM |

`mapper_manual_force`, `mapper_janggun`, `mapper_castle`, `mapper_nemesis_auto`, `mapper_wonderkid`, `mapper_linear`, `mapper_sega_locked`, `mapper_dahjee_a`, `mapper_eeprom`, and `use_zem` are continuously assigned combinational outputs, even where their declarations have initializers. They add no independent persistent history (C). OSD mapper_lock/Codies/Dahjee/linear/Zemina/Evolution forces, gg, systeme, SC mode and game identity are E inputs, not snapshot-owned history.

The only sequential mapper-detection items outside these two modules are the media/download and Evolution board state already handled by their own architectural interfaces. Static helper function variables (`crc`, `crc32_v`, `matches`, `byte_index`, `count_23`, `count_def`) are assigned before use from current signal/input values and do not add historical state. There is no current signal named `count`; the audit shorthand resolves to `wonderkid_write_count`.

Count=1 is a one-host-clock intermediate during an eligible held write. T80s changes WR_n only under CEN. SMS CPU enables are separated by15 host clocks, and turbo/System E pixel enables by10. Thus even the shortest held write supplies at least two detector samples before a subsequent M1/MREQ capture. If the window remains open and AB is present, count2 implies detect_wonderkid already set. If AB is absent, it cannot become present without replacing media/resetting history. Count1 can survive a write only when the detection window closes before its second sample, making it permanently unconsumed. At an accepted capture, preserving the resolved flag and timer is therefore sufficient; count can normalize to0 without changing any future decision. Count2 with a resolved Wonder Kid flag merely reasserts that same sticky flag if normalized0 later recognizes again. Sega/4PAK register writes clear both original and normalized counters. No arbitrary count=1 accepted snapshot is claimed, and no count payload is recommended for the current T80/native-enable architecture. Reassess this exclusion if future CPU/bus changes allow a single-host-clock write or media mutation without reset.
