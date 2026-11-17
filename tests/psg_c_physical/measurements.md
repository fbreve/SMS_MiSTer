## Seed 1

| Metric | Master | C | C − master | Relative delta |
| --- | ---: | ---: | ---: | ---: |
| Needed ALMs | 26,505 | 25,943 | -562 | -2.12% |
| Placed ALMs | 31,615 | 30,989 | -626 | -1.98% |
| Fitted registers | 35,772 | 35,384 | -388 | -1.08% |
| Mapped registers | 34,857 | 34,446 | -411 | -1.18% |
| M10K blocks | 487 | 487 | +0 | +0.00% |
| MLAB cells | 0 | 0 | +0 | n/a |
| MLAB memory bits | 0 | 0 | +0 | n/a |
| Logical block-memory bits | 3,809,858 | 3,809,858 | +0 | +0.00% |
| DSP blocks | 39 | 39 | +0 | +0.00% |
| Logic ALUTs | 37,082 | 36,435 | -647 | -1.74% |
| Routing ALUTs | 13,118 | 12,818 | -300 | -2.29% |
| Setup slack (ns) | 0.518 | 0.390 | -0.128 | -24.71% |
| Hold slack (ns) | 0.231 | 0.243 | +0.012 | +5.19% |
| Setup TNS (ns) | 0.000 | 0.000 | +0.000 | n/a |
| Hold TNS (ns) | 0.000 | 0.000 | +0.000 | n/a |

| Final interconnect (%) | Master | C | Delta (percentage points) | Relative delta |
| --- | ---: | ---: | ---: | ---: |
| Average Total | 29.1 | 29.0 | -0.1 | -0.34% |
| Average H | 29.5 | 29.3 | -0.2 | -0.68% |
| Average V | 28.0 | 28.1 | +0.1 | +0.36% |
| Peak Total | 45.5 | 48.0 | +2.5 | +5.49% |
| Peak H | 45.9 | 47.2 | +1.3 | +2.83% |
| Peak V | 47.7 | 54.9 | +7.2 | +15.09% |

| Physical-synthesis observation | Master | C | Delta | Relative delta |
| --- | ---: | ---: | ---: | ---: |
| Retimed-register table entries | 690 | 700 | +10 | +1.45% |
| Scaler retimed-register entries | 374 | 384 | +10 | +2.67% |
| Luminance retimed-register entries | 39 | 37 | -2 | -5.13% |
| Fitted minus mapped register count | 915 | 938 | +23 | +2.51% |

New normalized warnings: **0**; removed: **1**. Critical warning messages: master **38**, C **38**. RAM structure unchanged: **true**. Actual fitter-setting differences: **0**.

## Seed 2

| Metric | Master | C | C − master | Relative delta |
| --- | ---: | ---: | ---: | ---: |
| Needed ALMs | 26,492 | 26,041 | -451 | -1.70% |
| Placed ALMs | 31,560 | 31,030 | -530 | -1.68% |
| Fitted registers | 35,814 | 35,330 | -484 | -1.35% |
| Mapped registers | 34,857 | 34,446 | -411 | -1.18% |
| M10K blocks | 487 | 487 | +0 | +0.00% |
| MLAB cells | 0 | 0 | +0 | n/a |
| MLAB memory bits | 0 | 0 | +0 | n/a |
| Logical block-memory bits | 3,809,858 | 3,809,858 | +0 | +0.00% |
| DSP blocks | 39 | 39 | +0 | +0.00% |
| Logic ALUTs | 37,082 | 36,455 | -627 | -1.69% |
| Routing ALUTs | 13,142 | 12,823 | -319 | -2.43% |
| Setup slack (ns) | 0.367 | -0.012 | -0.379 | -103.27% |
| Hold slack (ns) | 0.243 | 0.213 | -0.030 | -12.35% |
| Setup TNS (ns) | 0.000 | -0.069 | -0.069 | n/a |
| Hold TNS (ns) | 0.000 | 0.000 | +0.000 | n/a |

| Final interconnect (%) | Master | C | Delta (percentage points) | Relative delta |
| --- | ---: | ---: | ---: | ---: |
| Average Total | 29.5 | 28.2 | -1.3 | -4.41% |
| Average H | 29.5 | 28.2 | -1.3 | -4.41% |
| Average V | 29.4 | 28.4 | -1.0 | -3.40% |
| Peak Total | 50.8 | 46.0 | -4.8 | -9.45% |
| Peak H | 52.1 | 48.2 | -3.9 | -7.49% |
| Peak V | 49.0 | 59.3 | +10.3 | +21.02% |

| Physical-synthesis observation | Master | C | Delta | Relative delta |
| --- | ---: | ---: | ---: | ---: |
| Retimed-register table entries | 690 | 700 | +10 | +1.45% |
| Scaler retimed-register entries | 374 | 384 | +10 | +2.67% |
| Luminance retimed-register entries | 39 | 37 | -2 | -5.13% |
| Fitted minus mapped register count | 957 | 884 | -73 | -7.63% |

New normalized warnings: **1**; removed: **1**. Critical warning messages: master **38**, C **39**. RAM structure unchanged: **true**. Actual fitter-setting differences: **0**.

Percentages use the matched master as denominator. n/a means the denominator is zero. Interconnect absolute deltas are percentage points. TNS is the worst reported setup/hold-group TNS; full groups are retained in results.json. Physical-synthesis counts are report entries, not unique register counts.
