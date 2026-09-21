# Evolution simulation

This directory contains focused regression simulations for the Master System
Evolution work.

## evolution_bios_arb_tb.vhd

A deliberately small harness for the external-BIOS $3E arbitration in
`rtl/system.vhd`. It documents both sides of the current problem:

* a normal SMS BIOS must be able to disable and re-enable itself while probing
  cartridge/media slots;
* after the BIOS has launched Evolution, embedded software such as Shinobi can
  write $04/$00 to port $3E, which the current core interprets as selecting the
  external BIOS again.

The earlier Evolution-specific "keep BIOS disabled after handoff" experiment
fixed the latter by breaking the former. This test prevents us from repeating
that mistake.

Run with GHDL:

```sh
ghdl -a --std=08 sim/evolution/evolution_bios_arb_tb.vhd
ghdl -e --std=08 evolution_bios_arb_tb
ghdl -r --std=08 evolution_bios_arb_tb --assert-level=error
```

This is **not** yet a full ROM execution test. The next layer should instantiate
the repository T80 and feed the exact external BIOS and Evolution flash images,
while logging PC/M1/MREQ/IORQ, port $3E, media control, bootloader state and the
selected instruction source. ROM images are intentionally not committed here.


## evolution_t80_bios_trace_tb.vhd

Second-stage harness using the repository's real T80. It loads the BIOS and
16 MiB Evolution flash as simulation-time binary files and logs instruction
fetches, writes to port $3E, BIOS/cart source changes, bootloader state and
media-control bits.

Run:

```sh
sh sim/evolution/run_t80_trace.sh "/path/to/HangOnBIOS.sms" "/path/to/MS132X1E.sms"
```

The peripheral side is intentionally stubbed and the first version maps the
Evolution flash linearly. Therefore this stage is for validating the external
BIOS handoff and finding the first point where richer cartridge/peripheral
modelling becomes necessary. It must not be treated as proof that the full
BIOS -> menu -> attract sequence is reproduced yet.

The next increment, once the first trace is inspected, is to lift the exact
`cart_precedence` / `cart_memory_selected` arbitration and Evolution launch
page translation from `rtl/system.vhd` rather than guessing peripheral
behaviour.


### Direct Shinobi control

The T80 harness has two start modes. The default `BIOS_EVOLUTION` follows the
external BIOS into the Evolution flash. `DIRECT_SHINOBI` is a control path:
after the same BIOS arbitration, cartridge reads are translated directly to
Shinobi's physical base at `$05C000`, bypassing Evolution menu/attract state.

```sh
sim/evolution/run_t80_trace.sh hangon_bios.bin MS132X1E.sms 2000000 BIOS_EVOLUTION
sim/evolution/run_t80_trace.sh hangon_bios.bin MS132X1E.sms 2000000 DIRECT_SHINOBI
```

Compare the first post-launch `OUT $3E` writes, `media_control`,
`bootloader_n`, cartridge selection, and Sega banks between the two traces.
The harness intentionally uses the CPU address bus for reported fetch/write
addresses rather than depending on the T80 debug REG vector layout.
