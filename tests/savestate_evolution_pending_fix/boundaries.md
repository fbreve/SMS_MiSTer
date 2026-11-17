# F15 accepted-boundary sweep

All requests use production acceptance; CPU architecture is captured at the accepted edge, Evolution at existing ARM one host clock later.

| Offset | SAVE input pulse cycle | Accepted cycle | Accepted phase | CPU address | Guest after LOAD |
|---|---|---|---|---|---|
| -1 | 657302 | 657316 | 000000 | 000a | Flash288123 / DI28 |
| 0 | 657467 | 657511 | 010000 | 000d | Flash288123 / DI28 |
| 1 | 657468 | 657511 | 010000 | 000d | Flash288123 / DI28 |
| 14 | 657481 | 657511 | 010000 | 000d | Flash288123 / DI28 |
| 28 | 657495 | 657511 | 010000 | 000d | Flash288123 / DI28 |
| 29 | 657496 | 657511 | 010000 | 000d | Flash288123 / DI28 |
| 30 | 657497 | 657511 | 010000 | 000d | Flash288123 / DI28 |
| 31 | 657498 | 657511 | 010000 | 000d | Flash288123 / DI28 |
| 42 | 657509 | 657511 | 010000 | 000d | Flash288123 / DI28 |
| 43 | 657510 | 657511 | 010000 | 000d | Flash288123 / DI28 |
| 44 | 657511 | 657661 | 000000 | 0020 | Flash288123 / DI28 |
| 45 | 657512 | 657661 | 000000 | 0020 | Flash288123 / DI28 |
| 46 | 657513 | 657661 | 000000 | 0020 | Flash288123 / DI28 |
| 59 | 657526 | 657661 | 000000 | 0020 | Flash288123 / DI28 |
| 74 | 657541 | 657661 | 000000 | 0020 | Flash288123 / DI28 |
| 89 | 657556 | 657661 | 000000 | 0020 | Flash288123 / DI28 |
| 149 | 657616 | 657661 | 000000 | 0020 | Flash288123 / DI28 |
| 209 | 657676 | 657856 | 000000 | 0023 | Flash288123 / DI28 |

Phase order: pending, armed, read-pending, menu-arm, old-M1, launch.

| Directed case | Saved phase | Word02C | SAVE-only clock comparisons | Identical LOAD trajectories |
|---|---|---|---|---|
| 0 | 010000 | 0200000000000000 | 28139 | 5 |
| 1 | 001000 | 0524000000002400 | 28247 | 5 |
| 2 | 000100 | 0924000000002400 | 28213 | 5 |
| 5 | 011000 | 0724000000002400 | 28180 | 5 |
| 6 | 010100 | 0b24000000002400 | 28149 | 5 |
| 7 | 001100 | 0d24000000002400 | 28249 | 5 |
| 8 | 011100 | 0f24000000002400 | 28185 | 5 |
| 9 | 001000 | 0524000024004800 | 28139 | 5 |
