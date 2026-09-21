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
