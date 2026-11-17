# G10 v18 stimulus correction

The inherited natural-phase test calibrates the distance from the final WRAM
DDR read (word 0xd00) to CPU preparation using its genuine legacy-v13 warmup.
It then delays that read response to target twelve exact divider phases.

v18 adds 4096 SRAM words after this calibration point. With this fixture's
three-clock read response, each sequential word costs 13 clocks, adding
53,248 clocks. The unmodified target calculation therefore requested phase 1
but reached phase 29. This failed the stimulus assertion before replay scoring.
The failed run is retained as `reg_g10/dut_phases/pre_v18_stimulus.log`.

The fixture now adds `dut.has_full_sram ? 4096*13 : 0` to its calibrated
distance when choosing DDR response delay. It does not force the divider,
alter production timing, alter saved state, regenerate reference data, or
weaken the target-phase, enable-order, CPU, memory, pixel or replay assertions.
The twelve exact requested phases must still be observed naturally.

This adjustment applies only to the fixed-latency NATURAL_PHASE test.
The independent randomized-stall F06 tests do not use this calculation.
