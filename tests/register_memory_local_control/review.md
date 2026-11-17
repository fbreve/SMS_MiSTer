# Experimental Report: Localized RegisterMemory Control (`QII_AUTO_PACKED_REGISTERS OFF`)

## 1. Hypothesis & Experimental Design

In `tests/register_memory_auto` (Seed 1) and `tests/register_memory_auto_seed2` (Seed 2), removing `attribute ramstyle of regs_array : signal is "logic";` in `rtl/VM2413/registermemory.vhd` inferred a 9x24 Simple Dual-Port M10K (`regs_array_rtl_0`, 198 physical bits with bits 14–15 pruned via Warning 14285). While this reduced Needed ALMs by 293–329 and Placed ALMs by 275–288, it caused Fitter physical synthesis register retiming to drop from 706–708 retimed registers globally (383 in `ascal:ascal`) to 0, and degraded worst-case setup slack in `pll_hdmi` (`6.732 ns`) from `0.508 ns` to `0.146 ns` (Seed 1) and from `0.451 ns` to `0.019 ns` (Seed 2).

In `tests/register_memory_impl_control`, increasing global `PHYSICAL_SYNTHESIS_EFFORT` from `NORMAL` to `EXTRA` in Seed 2 produced zero difference in every resource, retiming, and timing metric.

In this experiment (`tests/register_memory_local_control`, branch `experiment/registermemory-local-control`), we tested a single localized instance assignment in `SMS.qsf` targeting `RegisterMemory` only, without touching `sys/`, OPLL RTL, or global QSF settings:

```tcl
set_instance_assignment -name QII_AUTO_PACKED_REGISTERS OFF -to "emu:emu|system:system|opll:fm|controller:ct|RegisterMemory:u_register_memory"
```

## 2. Seed 2 Results (Executed First)

| Metric | Baseline (Logic) | AUTO (Uncontrolled) | AUTO + Local Control | Local Control vs Baseline | Local Control vs AUTO |
| --- | ---: | ---: | ---: | ---: | ---: |
| Needed ALMs | 26,489 | 26,160 | 26,234 | -255 | +74 |
| Placed ALMs | 31,545 | 31,257 | 31,281 | -264 | +24 |
| Mapped Registers | 34,857 | 34,637 | 34,637 | -220 | 0 |
| Fitted Registers | 35,772 | 35,426 | 35,324 | -448 | -102 |
| M10K Blocks | 487 | 488 | 488 | +1 | 0 |
| DSP Blocks | 39 | 39 | 39 | 0 | 0 |
| Setup Slack (ns) | 0.451 | 0.019 | **0.556** | **+0.105** | **+0.537** |
| Setup TNS (ns) | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 |
| Hold Slack (ns) | 0.243 | 0.240 | 0.182 | -0.061 | -0.058 |
| Hold TNS (ns) | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 |
| Retimed Registers (Whole Design) | 706 | 0 | 0 | -706 | 0 |
| Retimed Registers (`ascal`) | 383 | 0 | 0 | -383 | 0 |
| Retimed Registers (Luminance) | 49 | 0 | 0 | -49 | 0 |

- Worst setup path in Seed 2 Local Control: `ascal:ascal|o_hcpt[1] -> ascal:ascal|o_vcpt[9]` (`0.556 ns` slack).
- Targeted `ascal:ascal|o_vpix_inner* -> ascal:ascal|o_poly_lum*` path slack improved from `0.019 ns` (in `AUTO`) to **`0.761 ns`** (despite still having 7 logic levels and 0 retimed registers), because the Fitter placed `o_vpix_inner` and `o_poly_lum` into adjacent LABs (`X10_Y75` and `X11_Y75`) with compact local routing (`5.650 ns` data delay vs `6.413 ns` in `AUTO`).

## 3. Seed 1 Results (Executed After Seed 2 Recovery)

| Metric | Baseline (Logic) | AUTO (Uncontrolled) | AUTO + Local Control | Local Control vs Baseline | Local Control vs AUTO |
| --- | ---: | ---: | ---: | ---: | ---: |
| Needed ALMs | 26,465 | 26,172 | 26,214 | -251 | +42 |
| Placed ALMs | 31,531 | 31,256 | 31,323 | -208 | +67 |
| Mapped Registers | 34,857 | 34,637 | 34,637 | -220 | 0 |
| Fitted Registers | 35,709 | 35,340 | 35,358 | -351 | +18 |
| M10K Blocks | 487 | 488 | 488 | +1 | 0 |
| DSP Blocks | 39 | 39 | 39 | 0 | 0 |
| Setup Slack (ns) | 0.508 | 0.146 | **0.600** | **+0.092** | **+0.454** |
| Setup TNS (ns) | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 |
| Hold Slack (ns) | 0.144 | 0.241 | 0.244 | +0.100 | +0.003 |
| Hold TNS (ns) | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 |
| Retimed Registers (Whole Design) | 708 | 0 | 0 | -708 | 0 |
| Retimed Registers (`ascal`) | 383 | 0 | 0 | -383 | 0 |
| Retimed Registers (Luminance) | 49 | 0 | 0 | -49 | 0 |

## 4. Key Causal Conclusion

This experiment **disproves** the hypothesis that the loss of physical retiming in `ascal` is the necessary cause of the timing regression (`0.019 ns` / `0.146 ns`):
1. Both `AUTO` and `AUTO + Local Control` produce the exact same `SMS.map.rpt` synthesis netlist (`34,637` mapped registers, `198` RAM bits in `RegisterMemory`) and the exact same `0` physical retiming transformations across the entire chip (`Info 128003: register retiming complete: estimated slack improvement of 0 ps`).
2. Yet, simply changing the local packing constraint on the 4 fabric registers of `RegisterMemory:u_register_memory` (`init_state[3:0]`, expanding `u_register_memory` from `14.9` to `16.3` Needed ALMs) perturbations the Fitter's initial placement trajectory enough that `ascal` and `hdmi_osd` achieve **`0.556 ns` (Seed 2) and `0.600 ns` (Seed 1) setup slack** — **exceeding** the original retimed baselines (`0.451 ns` and `0.508 ns`) without a single retimed register!
3. Furthermore, about `250` of the `293–329` Needed ALM reduction observed when removing `ramstyle = "logic"` in `RegisterMemory` is not from `RegisterMemory` itself (`-72.8` to `-77.0` Needed ALMs), but is a global collateral effect of the Fitter skipping physical synthesis retiming, boolean division (`savestates_inst` `-172` Needed ALMs), and Pass-2 register duplication (`-156` duplicates).

