# v14 restart assumptions used in this investigation

Committed baseline is recorded in baseline.json. The current writer tags word01A with48430E/subtype3, descriptor02E is12AA0E0047365231, and word02F encodes accepted phase, System E ownership and whether CPU consumed T. The container remains12288 words. No production or format change is made.

| Stage | CPU | VDP/background/sprites | Beam/divider |
|---|---|---|---|
| Accepted SAVE T | Capture pre-edge architecture/context; finish actual accepted tick | Finish T, then hold | Capture phase at T; post-T beam follows accepted pixel if any |
| ARM | Held | Collect post-T architectural and sprite records | Presentation may subsequently run during transport |
| Transport / metadata | Held; DIRSet and later NMI metadata are restoration | Held except explicit state application | Raw presentation is not guest progression |
| ST_CPU_PREPARE105 | LOAD only: private /15 enables AND replay, historical T1/T2 only | Both chips' guest enables stay zero | Raw divider runs until canonical installation |
| ST_PHASE_COMMIT106 | No new guest instruction | Held | Falling-edge saved phase installation clears CEs; acknowledged rising edge installs saved beam and releases |
| First continuation | Canonical MC1/T3 for consumed-T running captures | Ordinary guest enables resume | Next falling edge is logical T+1 |

Accepted x<256 gives post-T x<=256. Ordinary capture phases are10/25; turbo/System E phases0/10/20. The permitted union is0,10,20,25. All current running witnesses save consumed-T=1. Current host Pause is not exercised by these fixtures; the existing bounded-progress/current-UI F12 contract is retained, not replaced by a historical pause bit.

| Saved phase | First raw CPU / VDP / pixel / sprite enable, host clocks after release |
|---:|---|
|0 |10 /5 /10 /2 |
|10 |15 /5 /10 /2 |
|20 |5 /5 /10 /2 |
|25 |15 /5 /5 /1 |

Turbo/System E CPU uses pixel enable; raw /15 remains distinct. Each integrated DUT checks the first60 host clocks against this contract. Preparation assertions hold the full architectural VDP and sprite record and reject CPU I/O/writes while private replay runs. The HCounter/HL witness logs FIRST_CPU, FIRST_VDP, FIRST_PIX and FIRST_SP with actual bus/MC/TS/beam observations. The G04 native oracle compares every first resumed host clock against uninterrupted execution, rather than dropping preparation pixels or comparing transport wall time.

The uninterrupted reference executes the same legal legacy initialization P, then bypasses final SAVE hold and canonical beam/phase strobes. It also masks passive SAVE DMA ownership of the CPU VRAM port after initialization: allowing that DMA while the reference CPU reads/writes VRAM is intrusive. Actual DUT SAVE/LOAD always uses the production transport path. Requests wait for ST_IDLE after the four-clock release settlement, and only UI op_cooldown is bypassed. Registered RAM timing,255-clock settlement and semantic CPU replay remain active. Most cases use TB_FAST to shorten only the900000-clock LOAD flush; a separate full-flush replay checks the unchanged production duration. Different legal DDRAM_BUSY profiles additionally test duration independence.
