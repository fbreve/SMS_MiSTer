# RegisterMemory AUTO: two fresh matched seed pairs

**Recommendation: retain the independent experiment; do not promote it to production based on these results.** All functional qualification passes and the whole-design area reduction repeats, but setup margin degrades in both matched seeds (−0.362/−0.432 ns), leaving only **+0.019 ns (19 ps)** in seed 2. Setup/hold TNS remains zero. Timing passes under the existing constraints, but the measured loss of margin merits investigation before adoption. Hardware FM/save-load validation is also outstanding. No further experiment or RTL change was performed.

| Whole-design metric | Seed 1 A | Seed 1 AUTO | Delta | Seed 2 A | Seed 2 AUTO | Delta |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Needed ALMs | 26465 | 26172 | -293 | 26489 | 26160 | -329 |
| Placed ALMs | 31531 | 31256 | -275 | 31545 | 31257 | -288 |
| Mapped registers | 34857 | 34637 | -220 | 34857 | 34637 | -220 |
| Fitted registers | 35709 | 35340 | -369 | 35772 | 35426 | -346 |
| Logic ALUTs | 37056 | 36509 | -547 | 37057 | 36509 | -548 |
| Routing ALUTs | 13159 | 13210 | 51 | 13184 | 13203 | 19 |
| M10Ks | 487 | 488 | 1 | 487 | 488 | 1 |
| MLAB cells | 0 | 0 | 0 | 0 | 0 | 0 |
| MLAB bits | 0 | 0 | 0 | 0 | 0 | 0 |
| DSP blocks | 39 | 39 | 0 | 39 | 39 | 0 |
| Fitted block-memory bits | 3809858 | 3810056 | 198 | 3809858 | 3810056 | 198 |
| Worst setup slack (ns) | 0.508 | 0.146 | -0.362 | 0.451 | 0.019 | -0.432 |
| Worst hold slack (ns) | 0.144 | 0.241 | 0.097 | 0.243 | 0.240 | -0.003 |
| Setup TNS (ns) | 0 | 0 | 0 | 0 | 0 | 0 |
| Hold TNS (ns) | 0 | 0 | 0 | 0 | 0 | 0 |
| Average interconnect (total %)  | 28.9 | 29.6 | 0.7 | 29.1 | 29.6 | 0.5 |
| Peak interconnect (total %)  | 53.7 | 53.0 | -0.7 | 47.3 | 45.3 | -2.0 |

Deltas are AUTO minus its matched fresh baseline. Average interconnect increases in both seeds, while total peak interconnect decreases; horizontal/vertical peaks and individual resource counts are in each detailed report. Both candidates use one additional M10K, zero MLABs, and retain 39 DSP blocks. PhaseMemory remains original in all four builds.
