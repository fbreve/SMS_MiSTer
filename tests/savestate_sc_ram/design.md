# F05 SC cartridge RAM savestate design

Base b0f4b71, branch fix/savestate-sc-ram. Scope: F05 only. F06 ownership is intentionally unresolved.

SC ownership is configuration, not discovery: the actual normal SC machine uses sc3000_en and sc_cart_ram. Selection 00 has no cartridge RAM; 01 has 2048 bytes mirrored through CPU 8000-bfff; 10 has 16384 bytes at 8000-bfff; 11 has 32768 bytes at 8000-ffff. The backing prefix begins at physical zero, has no banks, and resides in the already allocated shared 32768-byte dual-port FPGA RAM. The SC size selector describes total machine RAM in the menu (4/18/32 KiB); transferred cartridge sizes are 2/16/32 KiB. Internal SC WRAM is already handled separately. SG extension alone does not enable SC cartridge RAM. Explicit SC mode can be used with SG content.

References: rtl/system.vhd:1000 address translation; rtl/memory_bus.vhd:39 windows and :49 frozen write qualification; SMS.sv:1684 backing RAM; SMS.sv:396 reset on SC config changes. Ordinary mapper/reset/config visibility changes do not clear this backing RAM. SD SAVE can replace it through port B. SC RAM ownership has no F06 ambiguity because its size is explicitly selected before the guest first accesses it. Sega mode/visibility flags remain insufficient and untouched.

The controller receives a two-bit SC size, gated at the top level to the normal SC machine (excluding System E, EEPROM and Evolution owners). SC+System E is not a supported combined RAM topology; their large payload ranges overlap. EEPROM takes physical backing ownership when enabled. This patch does not change machine routing, mapper behavior, or conflicting user configurations.

Extension v5 is necessary: v4 did not encode SC payload presence. Stable current SC configuration alone cannot distinguish an old absent payload from a new complete one. New writers use tag 484305 with unchanged base count 3 at 01a. Reader keeps explicit v1/v2/v3/v4 support. All existing field positions remain fixed.

025 is a new 64-bit descriptor: bits 31:0 = 53435235 (SCR5), bits 33:32 = SC size, bits 63:34 = zero. Zero size explicitly describes absence. A loader reads it only after validated v5 tag/count and accepts nonzero size only on exact equality with the captured current SC configuration. No old unused bytes or arbitrary unsupported-version payloads become RAM. A mismatch retains current backing; it does not change user configuration or visibility.

| Region, 64-bit slot-relative words | Use |
|---|---|
| 000-018 | Existing header/CPU/VDP/CRAM/PSG/mapper/System E metadata |
| 019 | Existing IO/Evolution |
| 01a | Existing video/HCounter fields, current extension tag changes to v5 |
| 01b | Existing EEPROM wrapper / Evolution |
| 01c-01d | Existing GG payload |
| 01e | Existing MD6 |
| 01f | Existing EEPROM descriptor |
| 020-024 | Existing PSG extension |
| 025 | New SC descriptor |
| 030-031 | Existing EEPROM protocol extension |
| 040-04f | Existing EEPROM 128-byte backing |
| 101-900 | VRAM, 16384 bytes |
| 901-d00 | Normal WRAM, 8192 bytes |
| d01-e00 | SC 2 KiB: 256 words |
| d01-1500 | SC 16 KiB: 2048 words |
| d01-1d00 | SC 32 KiB: 4096 words |
| 901-1100, 1101-1900, 1901-2100, 2101-2900 | System E WRAM and additional VRAM, mutually exclusive with normal SC payload |

SC reuses the existing ordinary NVRAM transfer region and DMA engine. It does not coexist there with Sega/CME/Dahjee/Castle RAM. In SC mode the configured size takes priority and absence of a validated SC payload suppresses fallback through unrelated old mapper bits. With SC size zero, the original Sega/NVRAM predicates and size branches apply unchanged. Full F06 disabled-SRAM and bank-ownership omissions remain unresolved.

Slot stride remains 3000 words = 98304 bytes (96 KiB). Largest SC payload ends at 1d00; largest System E allocation ends at 2900; both below 3000. No offsets overlap in a valid machine configuration. Additional payload uses existing live RAM and existing slot capacity; it does not request new FPGA RAM.

Legacy untagged/v1/v2/v3/v4, old 64 KiB states, unsupported versions, invalid count, invalid descriptor/magic/reserved bits, absent size and mismatched size all leave current SC backing bytes intact. Existing legacy behavior for other devices and old SRAM payloads remains intact when SC mode is absent. v4 EEPROM keeps its descriptor/protocol/backing positions and is accepted by the v5 reader.

Snapshot coherence uses existing ss_freeze: CPU backing writes are gated off in memory_bus, physical port A is owned by savestate DMA, and existing storage_busy/ss_busy arbitration excludes SD port-B producers. SC size is captured when freeze is armed; top-level configuration changes reset the operation under existing reset semantics. No normal SC write latency or timing is changed. Existing aborted-operation behavior is not redesigned.

A one-cycle sc_ram_restored strobe occurs after a complete validated SC restore at pre-unfreeze. It marks bk_pending when existing bk_ena permits persistence. The normal SAVE remains the existing full 64-sector/32768-byte image; visibility changes do not alter that file. Host requests still wait for savestate release. Sega dirty/persistence policy is unchanged. No new SRAM ownership signal or sticky discovery field is added.

Production changes: SMS.sv wires SC configuration and restore dirty strobe; rtl/savestates.sv adds descriptor states, validated v5 decoding and SC transfer selection/length. Mapper, system routing, EEPROM engine, controller and VDP files remain byte-identical to HEAD.
