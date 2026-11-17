# Warning comparison

## Added normalized warnings

- Critical Warning (332148): Timing requirements not met
- Warning (10036): Verilog HDL or VHDL warning at slotcounter.vhd(<N>): object "ss_v_ff_count" assigned a value but never read File: <BUILD>/rtl/VM2413/slotcounter.vhd Line: <N>

## Removed normalized warnings

None.

## Master: latches

None.

## Master: multipleDrivers

None.

## Master: widths

None.

## Master: ram

- Warning (13410): Pin "SDRAM_BA[1]" is stuck at GND File: Z:/baseline/sys/sys_top.v Line: 55
- Warning (13410): Pin "SDRAM_CKE" is stuck at VCC File: Z:/baseline/sys/sys_top.v Line: 57

## Full-state: latches

None.

## Full-state: multipleDrivers

None.

## Full-state: widths

None.

## Full-state: ram

- Warning (13410): Pin "SDRAM_BA[1]" is stuck at GND File: Z:/candidate/sys/sys_top.v Line: 55
- Warning (13410): Pin "SDRAM_CKE" is stuck at VCC File: Z:/candidate/sys/sys_top.v Line: 57
