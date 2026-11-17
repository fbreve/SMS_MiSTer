# F11 dataflow and state inventory

Baseline: committed F10 `77147af`, branch `investigate/savestate-lightgun`. Production RTL is unchanged.

There is no physical sensor-bit input to this implementation. HPS mouse deltas/buttons/strobe and joystick coordinates/buttons are external; lightgun.sv synthesizes SENSOR from a frame-latched aim point and locally counted display timing. The path is:

`HPS input -> lg_x/lg_y -> frame-latched x/y/offscreen -> local hcnt/vcnt comparison -> sensor_pend/sensor_time/SENSOR -> registered SMS joya_th or joyb_th -> io.vhd $DD and HL_out -> VDP old_HL/latched_x -> $41`.

`TARGET = !offscreen && draw` feeds the host crosshair RGB overlay. It does not feed SENSOR, framebuffer brightness, IRQ or guest memory. There is no analog photodiode input, sensor synchronizer chain, or lightgun-specific interrupt/NMI output. Sensor delay is synthetic, not a sampled external sensor. The output called TH is an input to guest I/O; CPU-controlled TH outputs are separate signals.

Classes: A already saved; B deterministically recomputed; C raw external input/configuration; D omitted local state; E irrelevant/dead for guest lightgun behavior. D alone is not evidence of a bug.

| State/input | Bits | Class | Update/freeze and consequence |
|---|---:|---|---|
| Video hcount/vcount, sync and blank levels | 22 | A | Raw CE_PIX continues during transport; restored from video word, then release waits for matching x/y |
| VDP latched_x, each applicable VDP | 8 | A | F07 extension; restored explicitly. Both lightgun-load tests and unchanged real-VDP F07 tests check it |
| VDP old_HL | 1 | B | Tracks HL each host clock; re-primed from live HL on register restore; not the F11 root cause |
| I/O ctrl | 8 | A | Existing IO32 payload; selects TH input/output behavior |
| I/O j1_th_dir, j2_th_dir, HL_out | 1 each | B | Updated every host clock, even during freeze, from ctrl and current TH; propagates omitted SENSOR state |
| SMS joya_th/joyb_th and gun TL/pin caches | derived | B | Existing accessory process runs every host clock. Selected TH is one registered inversion of SENSOR; not a separate historical sensor sample |
| Gun hcnt | 9 | D | CE_PIX increments/saturates; resets while both delayed/raw HDE inactive. Held during freeze |
| Gun vcnt | 9 | D | CE_PIX + delayed HDE falling edge; counts active lines or clears in VBlank. Held during freeze |
| Gun vtotal | 9 | D | Learns previous active extent at the first blank-line delayed HDE fall. Held during freeze |
| Gun hde_d | 16 | D | CE_PIX shift history of raw HDE. Held during freeze |
| Gun old_hde | 1 | D | CE_PIX sample of hde_d[15]. Held during freeze |
| Gun old_vde | 1 | D | CE_PIX sample of VDE; detects frame coordinate latch. Held during freeze |
| Gun x/y | 9 each | D | Frame-latched target at VDE rising edge; these are emulated history distinct from current host position |
| Gun offscreen | 1 | D | Frame-latched target qualification; masks delayed SENSOR |
| Gun sensor_pend | 1 | D | CE_PIX may clear it, but ungated hit comparator can SET it during freeze |
| Gun sensor_time | 8 | D | CE_PIX increment/saturation and pulse timing; ungated hit comparator can RESET it during freeze |
| Gun SENSOR | 1 | D | Set/cleared only on CE_PIX. Held during freeze and never restored; directly guest-visible through TH |
| Gun lg_x/lg_y | 9 each | D, input representation | Sampled/processed host-coordinate storage. Joystick mode refreshes continuously using current vtotal; mouse mode integrates deltas. Original audit S075 excludes host pointer representation. No cursor rewind is proposed; constant-input counterexamples avoid this policy boundary |
| Gun old_ms | 1 | D, input handler | Host-clock mouse strobe history; continues during freeze. No mouse changes are needed for either reproduced F11 defect |
| Gun TRIGGER | 1 | B | Refreshed every host clock from current mouse button or JOY[4]/JOY[9]. Top supplies eight JOY bits, so JOY[9] is zero there |
| Gun xm/xp/ym/yp | 9 each | E (presentation history) | Frame-latched crosshair bounds; used only for TARGET/draw |
| Gun cross_sz | 9 | B/E | Refreshed each host clock from SIZE; only affects crosshair bounds |
| Gun draw | 1 | E (presentation history) | Host-clock crosshair output; no guest sensor feedback |
| Gun jy_scaled | 18 | E (temporary) | Blocking calculation written before use within the same joystick update; old value never affects later execution |
| Gun old_pix | 1 | E | Declared but never read or assigned |
| RESET | input | E in gun module | Entirely unused; no gun reset branch. Tests establish state by naturally running frames |
| MOUSE, MOUSE_XY, JOY_X/Y, JOY, BTN_MODE, SIZE | inputs | C | Current external input/configuration, not serialized by this investigation |
| SENSOR_DELAY | 8 config | C | Top-level constant 34 |
| Raw CE generation / clkd | shared source | existing timing | Gun uses CE_PIX, not the paddle's 16 kHz divider. Tests use the committed production enable pattern and common future enables |

The immediate guest beam/sensor candidate set is 74 bits: hcnt/vcnt/vtotal (27), hde_d (16), old_hde/old_vde (2), frame x/y (18), offscreen (1), sensor_pend (1), sensor_time (8), SENSOR (1). This is a conservative inventory, not an approved serialization layout. Some beam fields may be reconstructable at a restricted boundary, but that has not been proved for a future fix. The ten sensor pipeline/output bits are priority candidates, but interface-level load differences alone do not prove that every one must be serialized before the first real CPU observation. The real-CPU counterexample conclusively requires freezing the ungated hit arm; whether additional serialization is necessary remains a separate design question. The 159 declared register bits in the module also include host input representation, presentation-only history and a temporary; they must not automatically all be serialized.

The active top-level condition is gun_mode != 0 and !gg. Gun mode 1 selects joystick 0, mode 2 joystick 1, mode 3 mouse XY; the guest destination P1/P2 is selected independently. Raw serial and ordinary controller outputs are calculated first, then gun output overrides the selected port. Paddle overrides its own five pins afterward; its independent TH-output history does not read gun_sensor. MD6 is disabled whenever gun_en is active. Master Tap uses CPU TH-output history, not the gun TH-input signal. No paddle 16 kHz state is shared with lightgun logic.

Save acceptance is exactly `!storage_busy && cpu_ce && !M1_n && !MREQ_n && ISet==00 && VBlank && x<256`. CPU snapshot is taken there. One host clock later ST_ARM_FREEZE captures video/VDP/IO and asserts freeze. With the production divider, no additional pixel pulse occurs between these two clocks. Lightgun CE_PIX is gated, while the raw video generator continues. After 32 quiet DDR clocks, state transport proceeds; no lightgun snapshot exists. On load, video/VDP/IO restore occurs before the 900000-clock pipeline flush, followed by a >=255-clock guard and quiet-enable release at the saved x/y (or the existing 2200000-clock alignment timeout). Both reproduced cases verify full video-state equality at release; neither uses the timeout to manufacture a mismatch.

At the first VBlank line, local vcnt has not yet cleared: that happens on a delayed HDE falling edge later in the line. The x<256 acceptance window does not exclude a still-active sensor tail from the previous visible line. It also allows a held local hcnt equal to a target x while local vcnt still lies in the hit window. During transport, raw HDE/VDE subsequently go active, so the ungated hit comparator can arm sensor_pend and reset sensor_time even though CE_PIX is zero. This latter mechanism corrupts save-only continuation; restoring additional fields on load alone cannot fix it.
