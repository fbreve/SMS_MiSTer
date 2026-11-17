# Accepted-boundary evidence

Phase order: pending, armed, read-pending, menu-arm, old-M1, launch. Request below is the actual raised SAVE input.

| CPU offset | Request cycle / phase / A | Accepted cycle / phase / A | Mapper | Evolution160 | Result |
|---|---|---|---|---|---|
| before | 657302 / 000000 / 000a | 657316 / 000000 / 000a | 0000000102030000 | 00000000000000000000000000000000e1320028 | equivalent control |
| 0 | 657467 / 000010 / 3ffe | 657511 / 010000 / 000d | 0000000102030000 | 00000000000000008700000000000000e1320028 | lost armed commit |
| 1 | 657468 / 100010 / 3ffe | 657511 / 010000 / 000d | 0000000102030000 | 00000000000000008700000000000000e1320028 | lost armed commit |
| 14 | 657481 / 100010 / 3ffe | 657511 / 010000 / 000d | 0000000102030000 | 00000000000000008700000000000000e1320028 | lost armed commit |
| 29 | 657496 / 010000 / 000d | 657511 / 010000 / 000d | 0000000102030000 | 00000000000000008700000000000000e1320028 | lost armed commit |
| 30 | 657497 / 010000 / 000d | 657511 / 010000 / 000d | 0000000102030000 | 00000000000000008700000000000000e1320028 | lost armed commit |
| 44 | 657511 / 010000 / 000d | 657661 / 000000 / 0020 | 0000000102038700 | 01000000000028008700000000000000e1320028 | equivalent control |
| 45 | 657512 / 010000 / 0006 | 657661 / 000000 / 0020 | 0000000102038700 | 01000000000028008700000000000000e1320028 | equivalent control |
| 59 | 657526 / 010010 / 0006 | 657661 / 000000 / 0020 | 0000000102038700 | 01000000000028008700000000000000e1320028 | equivalent control |
| 74 | 657541 / 010010 / 0006 | 657661 / 000000 / 0020 | 0000000102038700 | 01000000000028008700000000000000e1320028 | equivalent control |
| 89 | 657556 / 010010 / 000e | 657661 / 000000 / 0020 | 0000000102038700 | 01000000000028008700000000000000e1320028 | equivalent control |
| 149 | 657616 / 010010 / 000f | 657661 / 000000 / 0020 | 0000000102038700 | 01000000000028008700000000000000e1320028 | equivalent control |
| 209 | 657676 / 000010 / 0007 | 657856 / 000000 / 0023 | 0000000102038700 | 01000000000028008700000000000000e1320028 | equivalent control |

| Directed case | Request cycle / phase / A | Accepted cycle / phase / A | First state sample | First Flash sample | Final probe |
|---|---|---|---|---|---|
| 0 | 118 / 010000 / 0100 | 121 / 010000 / 0100 | 0 | 4 | REPLAY CASE0 Q0 REF=288123/28 LOAD=008123/00 launches=0 phase=000010 |
| 1 | 374 / 001000 / 1380 | 376 / 001000 / 1380 | 0 | 113 | REPLAY CASE1 Q0 REF=288123/28 LOAD=488123/48 launches=0 phase=000010 |
| 2 | 477 / 000100 / 1400 | 481 / 000100 / 1400 | 0 | 113 | REPLAY CASE2 Q0 REF=288123/28 LOAD=2a0123/2a launches=0 phase=000010 |
| 5 | 443 / 011000 / 1380 | 451 / 011000 / 1380 | 0 | 40 | REPLAY CASE5 Q0 REF=288123/28 LOAD=020123/02 launches=0 phase=000010 |
| 6 | 513 / 010100 / 1400 | 526 / 010100 / 1400 | 0 | 4 | REPLAY CASE6 Q0 REF=288123/28 LOAD=020123/02 launches=0 phase=000010 |
| 7 | 477 / 001100 / 1380 | 481 / 001100 / 1380 | 0 | 149 | REPLAY CASE7 Q0 REF=288123/28 LOAD=2a0123/2a launches=0 phase=000010 |
| 8 | 513 / 011100 / 1380 | 526 / 011100 / 1380 | 0 | 40 | REPLAY CASE8 Q0 REF=288123/28 LOAD=020123/02 launches=0 phase=000010 |
| 9 | 447 / 001000 / 1380 | 451 / 001000 / 1380 | 0 | 4 | REPLAY CASE9 Q0 REF=288123/28 LOAD=488123/48 launches=0 phase=000010 |

Each directed case compares every observed host-clock suffix sample against the reference and every repeated LOAD against the first loaded trajectory, over five Q histories. Complete CPU architectural words and bus controls are retained in results.json and the logs.
