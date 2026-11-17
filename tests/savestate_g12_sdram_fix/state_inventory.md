# G12 causal sequential inventory

Source: current `rtl/sdram.sv`, `SMS.sv`, `rtl/T80/T80s.vhd`, and
`rtl/savestates.sv`. The [investigation inventory](../savestate_g12_sdram/state_inventory.md)
retains full assignment and platform-wrapper details. This table classifies the
candidate deterministic reconstruction; its closure is conditional on the
pending sufficiency gate.

No live SDRAM field has a SAVE/LOAD/freeze input. All continue clocking through
transport. No new reset or physical chip initialization is proposed.

| State / owner | Width / reset | Capture, LOAD, freeze, restart / first consumer | Required treatment |
|---|---|---|---|
| CPU architecture/context/NMI |230+3+3; existing T80 architectural reset | Existing pre-T representation, DIRSet/metadata/private T1 and optional T2; CPU execution consumes | MUST PRESERVE, unchanged v16 |
| CPU MREQ/RD and MCycle/TState | Bus2 reset11, cycle3/state3 reset MC1/TS0 | DIRSet deasserts strobes and normalizes MC1/T1; historical T1 asserts read; consuming T2 samples byte | MUST REISSUE / DETERMINISTICALLY RECONSTRUCTABLE |
| CPU wrapper DI_Reg |8; reset0 | T2 captures input, frozen before consumer; ordinary operand reads refill | OVERWRITTEN BEFORE OBSERVATION with timely reconstructed response |
| Host Pause flags |3; reset0 | Current UI retained; only bounded private replay bypasses execution gate | MUST PRESERVE current host state, no historical payload |
| Host Pause edge history |joy8_r/VBlank_r/ss_freeze_r,3; sampled live each host edge | Current input/beam/freeze tracking continues through transport; suppresses synthetic release transitions and recognizes later unpause | MUST PRESERVE live host tracking, not saved historical UI state |
| CPU replay stage |2; reset0 | DIRSet→metadata→T1→optionalT2, remains held otherwise | DETERMINISTICALLY RECONSTRUCTABLE, existing protocol |
| clkd and CPU/pixel enables |5+1+1; no explicit divider reset | Falling-edge30-clock recurrence continues through transport; captured phase installs with both enables0; memory reference and CPU consume | MUST PRESERVE semantic phase via existing2-bit record; physical count/enables DETERMINISTICALLY RECONSTRUCTABLE |
| phase_snap / capture_tick_snap |2+1; controller reset0/1 | Capture accepted phase and actual CPU consumption, LOAD from word02F; private T2 selection and phase commitment consume | MUST PRESERVE, existing v16 payload |
| cpu_prepare / phase-set / phase-ready |1+1+1; existing controller/handshake initialization | Existing private replay completion and falling/rising-edge phase handshake; controller release and new combinational clock selector consume | DETERMINISTICALLY RECONSTRUCTABLE; unchanged FSM and no new temporal storage |
| Controller q |4; no explicit reset | Increments to15; clkref rising sets0; q0 accepts, q1 ACT, q3 READ, q6 captures | DETERMINISTICALLY RECONSTRUCTABLE by coupling private reference to private T1; old timing must not qualify response |
| old_ref |1; no explicit reset | Samples clkref each host edge; detects next reference | DETERMINISTICALLY RECONSTRUCTABLE; source-switch edge ordering must pass sweep |
| old_rd |1; no explicit reset | Samples RD only at q0; recognizes new request | MUST INVALIDATE logically by existing DIRSet low and settlement, then MUST REISSUE via T1; no explicit register reset proposed |
| a/bank |23+2; no explicit reset | Latch accepted address; drive ACT/READ and byte lane | OVERWRITTEN BEFORE OBSERVATION by the reconstructed request; old Q address must never satisfy first consumer |
| ram_req |1; initial0 | q0 clears/accepts; q6 controls return; may remain1 after completion | DETERMINISTICALLY RECONSTRUCTABLE; a high value alone is not an outstanding transaction |
| wr |1; no explicit reset | q0 clears, download write can set; controls command/return | OVERWRITTEN BEFORE OBSERVATION for immutable-media read session |
| sd_dat |16; no explicit reset | q6 read captures physical DQ, never cleared by idle or LOAD | OVERWRITTEN BEFORE OBSERVATION; must prove correct new response before CPU T2 |
| rd_rdy |1; initial0 | q0 defaults1, accepted read0, q6 returns1; no connected top-level consumer | IRRELEVANT as architectural state; stale-high cannot prove freshness |
| data |8; no explicit reset | Download write latch, drives write slot | IRRELEVANT to guest read reconstruction under same-media/no-download session |
| we_ack |1; initial0 | Download toggle handshake, q6 updates | IRRELEVANT under no-download session; preserve ordinary host download logic |
| mode |2; no explicit reset | Initialization sequencing at q7, then NORMAL | DETERMINISTICALLY RECONSTRUCTABLE session prerequisite, unchanged |
| reset counter / init_old |5 initial31 /1 initial0 | Physical initialization progresses on q7; init falling reloads | IRRELEVANT to historical guest state once active-session initialization completed |
| SDRAM_A/BA |13+2; registered | Derived from q/address/bank/direction; physical chip command consumer | DETERMINISTICALLY RECONSTRUCTABLE from newly accepted request |
| nCS/nRAS/nCAS/nWE |4; registered | Command case each host edge, otherwise inhibit | DETERMINISTICALLY RECONSTRUCTABLE, no new command recipe |
| DQ output drive |16; registered | Z except write slot; physical read resolves chip data | IRRELEVANT historical write contents under immutable guest ROM |

There is no response FIFO, independent valid register, queue owner, cache,
prefetch state, burst progress or per-bank open-row table. `dout` byte selection
is combinational from a[0] and sd_dat. The physical chip uses auto-precharge and
single-word CAS2 reads. Read ownership/transaction IDs are testbench observers,
not proposed production registers. Upstream mapper records remain unchanged.

The confirmed defect combines B (the generated bus level misses an acceptance
slot), D (retained data reaches the consumer), E (release lacks the required
memory precondition), and F (suppressed-T/private /15 versus native /10 ordering).
A is excluded by observed old_rd=0. C is not causal: ready is unconnected and
cannot suppress anything. A new current-request completion proof is required;
neither the old ready flag nor long DDRAM flush supplies it.
