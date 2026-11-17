# SMS MiSTer FPGA resource comparison

| Resource | Original (Dec 2025) | Current master | Experimental v19 |
| --- | ---: | ---: | ---: |
| Needed ALMs | 19,962 | 26,465 | 37,117 |
| Placed ALMs | 24,230 | 31,531 | 38,599 |
| Logic ALUTs | 28,740 | 37,056 | 46,835 |
| Routing ALUTs | 10,260 | 13,159 | 18,266 |
| Mapped FFs | 28,655 | 34,857 | 46,327 |
| Fitted registers | 29,541 | 35,709 | 48,880 |
| M10K blocks | 217 | 487 | 488 |
| Memory bits | 1,582,422 | 3,809,858 | 3,818,050 |
| DSP blocks | 38 | 39 | 39 |
| Placed ALM utilization | 57.81% | 75.24% | 92.10% |
| Setup slack | +0.562 ns | +0.508 ns | +0.104 ns |
| Hold slack | +0.249 ns | +0.144 ns | +0.239 ns |
| Violating timing groups | 0 | 0 | 0 |
| Unique critical warnings | 29 | 38 | 38 |


Cyclone V 5CSEBA6U23I7; Quartus 17.0.2 Build 602 Lite; seed 1; MISTER_FB=1. Exact revisions: original `4d8506a`, current master `8443a0d`, experimental v19 `1b2a52d`.

**Original→v19 placed ALMs: 24,230→38,599, +14,369 (+59.30%).** Utilization: 57.81%→92.10% (+34.29 percentage points).

The requested original SHA is dated **December 2025**, not 2024. Historical RTL/framework/IP are unchanged; generated BUILD_DATE is 261025 (v19 same; retained master 261020). All four historical tool stages completed. Reported historical setup/hold pass. Critical warnings and inherited unconstrained timing categories remain; positive slack is not full hardware signoff.

These are **complete FPGA builds of different revisions**, including framework and functional changes—not the isolated cost of savestates or one contributor. Master already includes savestates. [Detailed audit and evidence](review.md).
