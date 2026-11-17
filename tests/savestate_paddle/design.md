# F10 design and inventory

Baseline: committed F09 `52fb749`, branch `fix/savestate-paddle`.

The complete local state is exactly 32 bits. All declarations and uses were traced in SMS.sv; there is no separate paddle module. `nib` and `nib_q` in the audit describe the two four-bit registers per port, not additional one-bit selectors.

| Item | Bits | Class | Reason |
|---|---:|---|---|
| P1/P2 `paddle_N_nib` | 4 each | A | Currently driven nibble, sometimes a past low sample, sometimes copied high sample |
| P1/P2 `paddle_N_nib_q` | 4 each | A | Cached high nibble; a later rising TH edge does not sample current position |
| P1/P2 `paddle_N_tr` | 1 each | A | Guest-visible TR; P1 TR also selects the shared JP alternation branch |
| P1/P2 `joyX_th_out_q` | 1 each | A | Export-mode edge history; held in JP mode and matters if mode changes |
| `cnt_en16khz` | 12 shared | A | Next JP transition depends on exact divider phase |
| `en16khz` | combinational | B | Equality to zero, no additional state |
| TH rise/fall wires | combinational | B | Boolean functions of restored history and existing restored I/O output |
| `joya`/`joyb` paddle pin cache | derived | B | Existing accessory process recomputes every host clock, including freeze; 255-clock restore guard settles it |
| TH/TR outputs / I/O direction and output control | existing I/O payload | A (already saved) | Restored by existing I/O load path before paddle normalization |
| `paddle_0/1`, `joy0_x/joy1_x` | 8 each | C | Host/user input; sampled transform `~axis[7],axis[6:0]` becomes local history only after assignment to nibble registers |
| `jp_region`, `paddle_joy`, `paddle_en` | config | C | Current region and accessory configuration, like MD6/Master Tap selection; future configuration identical in replay |
| `ce_cpu`, `ce_pix`, global divider | unrelated | C / existing machine timing | Paddle runs directly on clk_sys; none drives its divider or protocol |
| reset | none in original block | D for paddle | Original protocol has no reset branch; reset must retain ordinary behavior |
| extra sampled position/mode/low cache/selector | absent | D | No additional registers exist in the production block |

The two ports have independent nibble caches, TR and TH histories. JP shares the divider and P1-TR-controlled alternation; both TR outputs become equal on each JP event. Export ports consume independent TH edges. The protocol runs even when the paddle is disabled, so all state remains preserved without changing enable semantics. Physical inputs remain external, including joystick sign conversion until it is sampled into the nibble pair.

The 53.693175 MHz clk_sys drives a modulo-3356 divider (0..3355). `en16khz` is true for the entire clock at count zero; JP consumes the old zero at the next rising clock. Frequency is approximately 15,999.158 Hz; each nibble is held 3356 clocks, a full alternation is 6712 clocks. No paddle state uses a gated CPU enable. All 32 bits previously advanced during freeze. New code holds both processes while frozen, with restore taking priority. No ordinary-timing expression changes. Letting time continue and merely applying a captured word would still advance during the release guard and would let JP consume current inputs while the machine is paused; freezing both state processes also makes save-only transport invisible. The held-reference replays verify this semantic independently of the MD6 and Master Tap decisions. Configuration and raw input can still change externally; their future sequences must agree in a replay.

v7 uses the existing video extension tag `0x484307`, count 3. All v1-v6 locations stay intact. Word 0x027 is new: bits 31:0 `0x50414437` (PAD7), bits 63:32 state. State bits 31:20 divider, 19 P2 TH history, 18 P1 TH history, 17 P2 TR, 16 P1 TR, 15:12 P2 high cache, 11:8 P2 current nibble, 7:4 P1 high cache, 3:0 P1 current nibble. Validity requires v7/count3, exact PAD7 magic, and divider <=3355. Every other 20-bit protocol pattern is representable (including independent TR histories inherited from mode changes).

Only validated v7 consumes the new word. Untagged, v1, v2, v3, v4, v5, v6, old 64KiB, unsupported/future tags, invalid counts, bad magic and invalid divider normalize identically at the late restore strobe: divider zero, TR bits zero, TH histories equal current restored I/O TH, nibble pairs freshly sampled from current external position or current converted joystick axis. This is a new current sample, not a claim to recover a past position. JP's first released zero-count event copies that current high nibble and raises both TR bits. Export waits for a real subsequent TH transition. Normalization occurs even when disabled, so later activation has deterministic local history.

No F11 dependency: `en16khz`, the divider and TH-history registers have no uses outside the paddle block. Lightgun instantiation and accessory override remain byte-for-byte unchanged. MD6 and Master Tap state machines and payloads remain independent and unchanged. F06 Sega SRAM visibility/size predicates are unchanged and remain unresolved.
