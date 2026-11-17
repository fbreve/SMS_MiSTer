# Main-workspace comment correction

Applied only to `rtl/savestates.sv` in the main repository. The original bytes were valid UTF-8 without BOM, containing double-encoded multiplication, approximation and arrow characters in 25 comments. Changes used byte-offset patches inside verified comment spans; no whole-file re-encoding.

Replacements: corrupted multiplication -> `*`; corrupted approximation -> `approx.`; corrupted arrow -> `->`. All 2,214 CRLF line endings and all bytes outside comments remain identical. All pre-existing uncommitted functional changes were preserved. The Git index and porcelain status are unchanged.

Before SHA-256: `01c08e36d9aacf1d161177d88cad4d8aee2ca5627d6eace3f62fad2544eb0011`
After SHA-256: `fe7412ae1a4fbc12f5ec5503cebd1b559c3c41f0ba221749261f56b7c7eb175e`
Common SHA-256 of all bytes outside comments (including original whitespace and string literals): `f9e7e32f01e74a09453f57f2f290ff1915c8520771f9806c83719a4af483c2d3`

Exact corrected lines (line numbers unchanged):

| Line | Corrected text |
| --- | --- |
| 7 | `//   Word 0x002-0x005: Z80 REG[211:0]   (4 * 64-bit words, MSBs unused)` |
| 8 | `//   Word 0x006-0x007: VDP regs [127:0] (2 * 64-bit words)` |
| 9 | `//   Word 0x008-0x00D: CRAM [383:0]     (6 * 64-bit words)` |
| 10 | `//   Word 0x00E:       PSG  [55:0]      (1 * 64-bit word, upper 8 bits unused)` |
| 11 | `//   Word 0x00F:       Mapper [63:0]    (1 * 64-bit word)` |
| 12 | `//   Word 0x010-0x011: VDP2 regs [127:0] (System E only; 2 * 64-bit words)` |
| 13 | `//   Word 0x012-0x017: CRAM2 [383:0]   (System E only; 6 * 64-bit words)` |
| 14 | `//   Word 0x018:       PSG2 [55:0]     (System E only; 1 * 64-bit word)` |
| 15 | `//   Words 0x101-0x900: VRAM 16KB       (2048 * 64-bit words)` |
| 16 | `//   Words 0x901-0xD00: WRAM 8KB        (1024 * 64-bit words) [SMS/GG]` |
| 17 | `//   Words 0x901-0x1100: WRAM 16KB      (2048 * 64-bit words) [System E; reuses NVRAM region]` |
| 19 | `//   Words 0x1101-0x1900: VRAM2 16KB    (System E only; 2048 * 64-bit words)` |
| 210 | `// Placed after the 4 game slots (4 * 0x3000 = 0xC000 words above base).` |
| 242 | `localparam ST_LOAD_CRAM    = 6'd28;  // streams 32 * 12-bit entries via cram_A/D/wr` |
| 279 | `localparam [19:0] FLUSH_MAX       = 20'd900000;    // approx. 16.8ms @ 53.7MHz` |
| 391 | `reg [63:0]  vram_word_buf;   // accumulate 8 bytes -> 1 DDRAM write` |
| 429 | `// ~2^25 / 53e6 approx. 630 ms -- far longer than any real DDRAM latency.` |
| 1044 | `// z80_snap[228:0] = 229 bits -> 4 * 64-bit words` |
| 1075 | `// cram_snap[383:0] = 6 * 64 bits` |
| 1179 | `// Start VRAM DMA: 16384 bytes -> 2048 * 64-bit words` |
| 1209 | `// 6 words * 64-bit = 384 bits = CRAM2` |
| 1478 | `//           slot = 96KB = 98304 bytes; minus 8-byte control word = 98296 bytes -> 24574 words` |
| 1819 | `// Read 2 * 64-bit words for VDP2 regs` |
| 1842 | `// Read 6 * 64-bit words for CRAM2` |
| 1915 | `// VRAM done -> WRAM` |

Proof/artifacts: `savestates.before.sv`, `comment_only.patch`, `git_diff_before.patch`, `git_diff_after.patch`, and `comment_correction.json`. The JSON records exact before/after text and each byte offset. These are new audit records; no prior experiment was changed.

The correction is present in the main workspace, not C1. Main RTL is now entirely ASCII (a valid UTF-8 subset). No C1/B1/baseline/sys or historical input/report/RBF was changed. 1522 protected files were rechecked during the correction.

Version normalization is planned separately in VERSION_1_MIGRATION_PLAN.md. No descriptor has been changed and no Quartus build has started.
