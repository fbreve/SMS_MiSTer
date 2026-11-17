# F03/F04 design, recorded before RTL edits

Base: committed F08 e090434; dedicated branch fix/savestate-eeprom. Both pre-fix dynamic reproductions pass as expected defects (protocol_before.log, backing_before.log).

Freeze both EEPROM wrapper and engine during ss_freeze. Retain the registered pending NVRAM write strobe/address/data: the RAM port switches to DMA on freeze, so that strobe represents an uncommitted byte and must execute exactly once on release. Capture protocol only after freeze becomes active; copy all backing bytes while held. Restore backing bytes before protocol, then refill the shared RAM read port from restored EEPROM address during the release guard. This preserves read-wait pipeline states without serializing the shared RAM output register. Ordinary timing is unchanged.

Use the existing NVRAM byte-transfer implementation with an explicit EEPROM selection, size 127 and dedicated DDRAM base 040. Existing SRAM flags, predicates, size choices, and base 0d01 remain unchanged. Presence comes from cartridge EEPROM configuration, independently of its bus/window visibility. No F05/F06 correction is required.

Version 4: tag 484304, bits39:38 remain 3 for the GG/GG/MD base payload. All HCounter fields, GG words01c/01d, MD word01e and legacy EEPROM word01b stay in place. Word01f is an EEPROM descriptor: [31:0]=45455058 (EEPX), [39:32]=1, [40]=presence, [43:41]=protocol extension word count (2 when present), [48:44]=memory word count (16 when present), [63:49]=zero. Absent descriptors have presence/counts zero. Only an exact present descriptor in validated v4 on an EEPROM cartridge authorizes backing restoration.

Protocol extension: words030/031, low word first. Fields: state3:0; sampled SK4; opcode12:5; data_buf28:13; cycles33:29; pending nv_we34; nv_a41:35; nv_di49:42; wr_phase51:50; wr_all52; all_cnt58:53; pending_waddr64:59; pending_wdata80:65; reserved127:81 zero. Existing word01b retains write-enable, data_o, wrapper pins/upper line bits/window and exported read diagnostics. Validate state<=8, cycles<=15, wr_phase<=2, extension padding and word01b[17:11]=0 before using full state.

Backing payload: words040..04f inclusive, 16 little-endian byte-packed 64-bit words, exactly bytes0..127. This is below VRAM base101 and does not overlap PSG020..024 or any existing slot region. Stride3000 and header size stay unchanged. Snapshot state plus pending memory-write output correspond to the same frozen boundary as the memory image.

Untagged/v1/v2/v3 and invalid/missing new metadata remain loadable. They retain current backing bytes, preserve available legacy write-enable/output and exported diagnostic values, normalize all omitted protocol/pipeline fields, and reconstruct SK history from the restored wrapper SK bit. They cannot recover historical backing contents or exact in-progress commands. Valid v4 restores exact local state. Non-EEPROM cartridges never consume the memory payload.

SD interlock: the savestate controller waits for existing SD activity before freezing and advertises its operation as busy while queued/running. SD starts wait until it is idle; manual request edges remain pending. Savestate DMA does not generate normal write notifications. A completed full EEPROM restoration marks backup dirty so later normal persistence sees restored data, never transient DMA contents.

Existing opcode behavior is a replay contract, not changed in this task: this RTL handles WRAL immediately using its current data buffer, and the ERAL encoding follows the special-command write-enable branch rather than erasing memory. Tests must cover and disclose these existing semantics without silently fixing independent command-emulation issues.
