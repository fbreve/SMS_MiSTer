# Current live-controller sequential inventory

Scope: current `rtl/sdram.sv` instance `SMS.sv:ram`, its direct top-level
download/request wiring and immediate combinational memory wrappers. The live
controller has no ss_freeze, SAVE, LOAD, DIRSet or format input. No listed live
controller field is serialized in v16. All continue on clk_sys during transport.
The final witness invalidates the proposed universal overwrite-before-consumer
argument for paused-to-running LOAD. The table retains ordinary-path reasoning;
the overriding final classifications immediately below are authoritative.

| State | Width / initialization / assignment | First consumer and classification |
|---|---|---|
| q |4; no reset; increment until15, clkref rising edge sets0 | Access/command/CAS schedule. POTENTIALLY FUTURE-RELEVANT, confirmed: private T1 need not coincide with a reference pulse; consumption can precede q0 acceptance |
| access-manager old_ref |1; no initializer; sample clkref every host edge | q resynchronization. DETERMINISTICALLY RECONSTRUCTED by low/high raw clock levels; phase-install quiet edge and subsequent native source pulse |
| access-manager old_rd |1; no initializer; sample rd at q0 | Rising-request acceptance. OVERWRITTEN BEFORE OBSERVATION: real read deassertion, and LOAD's DIRSet/long hold, provide low sampling before private T1 reissues. Paused held fetch is separately a returned/unconsumed case |
| a |23; no reset; q0 accepted write/read address[22:0] | ACT row, READ column and output byte lane. POTENTIALLY FUTURE-RELEVANT at restart when replacement request is lost; ordinary next read does overwrite it. RAM-resident code can leave benign differences |
| bank |2; no reset; same acceptance, address[24:23] | SDRAM bank output. Same classification/order as a |
| data |8; no reset; q0 accepted host download write | DQ drive during write slot. BOUNDARY-EXCLUDED as historical guest state: download resets CPU/controller-side savestate engine, immutable-session prerequisite |
| wr |1; no reset; q0 clears then accepted write sets | Command direction, capture and ack. Read-only guest context completes before next request. Host-write branch BOUNDARY-EXCLUDED |
| ram_req |1; initial0; q0 clears, accepted request sets | ACT/READ/WRITE generation and q6 completion. Guest read DRAINED BEFORE CAPTURE at consuming M1/T2; a completed ram_req may remain1 until next q0, which is not a pending transaction |
| sd_dat |16; no reset; q6 and read ram_req captures resolved DQ | dout=a[0]?high:low. POTENTIALLY FUTURE-RELEVANT, confirmed stale opcode at restart. Ordinary requests replace it; BRAM/IO can ignore it. Idle alone never clears it |
| rd_rdy |1; initial0; q0 defaults1, accepted read0, q6 completion1 | Top-level port is unconnected; no CPU WAIT connection. OVERWRITTEN BEFORE OBSERVATION / no guest consumer. Cannot be used as a variable-latency handshake |
| we_ack |1; initial0; q6 write acknowledges current toggle | Top-level ioctl_wait/romwr_a. BOUNDARY-EXCLUDED host download context |
| mode |2; no reset; q7 initialization sequence, then NORMAL | Command selection. BOUNDARY-EXCLUDED initialization prerequisite; ordinary SAVE/LOAD does not reinitialize physical SDRAM |
| initialization reset counter |5; initial31; falling init reload31, q7 decrements | mode PRE at14, LDM at3, otherwise RESET, then NORMAL. BOUNDARY-EXCLUDED initialization prerequisite |
| init_old |1; initial0; sample init each clock | Falling-init detector. BOUNDARY-EXCLUDED PLL/session initialization |
| SDRAM_A |13; registered command-dependent row/column/masks/mode, otherwise0 | Pin/address/byte enables at physical command clock. DETERMINISTICALLY RECONSTRUCTED from accepted a/wr/mode/q before consuming command |
| SDRAM_BA |2; q1 selects bank or0 in initialization | Physical command bank. DETERMINISTICALLY RECONSTRUCTED |
| nCS/nRAS/nCAS/nWE |4; every clock command case, otherwise INHIBIT | Physical command decoder. DETERMINISTICALLY RECONSTRUCTED; q6 means one return for one READ |
| SDRAM_DQ procedural drive |16; every clock Z, q3 drives {data,data} | Resolved bidirectional pins. Host-write datum BOUNDARY-EXCLUDED; otherwise no historical guest state |

No burst counter, cache, prefetch queue, per-requester identity, open-row table,
separate CAS shift register, or independent refresh timer exists. Burst length
is the mode constant1. Every access uses auto-precharge. Unused q1 slots issue
AUTO_REFRESH. The SDRAM chip's open row/CAS progression is modeled separately;
completed auto-precharged immutable ROM reads have no persistent architectural
effect. Physical refresh is not used as a substitute for proving response order.

Immediate `memory_bus`, `memory_decode`, and `evolution_rom_address` are
combinational. Architectural mapper banking/history is already serialized and
is upstream of G12; production mapper_ctrl is exercised but is not re-audited.
T80s DI_Reg is a CPU fetch consumer reconstructed by historical T1/T2, not an
extra external-controller response FIFO. Registered decryption results are G11.

Top-level host download wrapper storage: rom_wr1 initialized0 (toggle on accepted
download byte), romwr_a24 (zero at download start, increment on matching ack),
ioctl_wait1 (set on byte, clear on ack/reset), block-local old_download1 and
old_reset1 (sample host download/reset). These implement the sole write requester;
all are BOUNDARY-EXCLUDED by active download/reset and same-immutable-media
contract, not serialized or arbitrated between guest devices. ROM signature32,
cart_download_r1 and format-identification download fields track media identity;
they are not live SDRAM guest transaction queues. Immutable ROM masks/media
configuration are session inputs. Host download write priority at q0 is real,
but no second guest SDRAM requester or writable guest SDRAM path exists.

The physical output registers are included above even though their contents are
often called wires/pins. Initialization uses natural clock progression, never
deposited q/mode/a/sd_dat values. Testbench-only counters/IDs do not alter this
protocol.

## Final overriding G12 disposition

`q` and its relationship to private T1/clkref are **POTENTIALLY FUTURE-RELEVANT,
confirmed**: private T1 at raw25 is not a /10 clkref pulse. Phase commit releases
before any q0 accepts that fetch. The first running T2 consumes the old returned
word; only then does q resynchronize, after rd has deasserted, losing the request.
`a`, `bank`, `sd_dat` and the output byte lane therefore are **POTENTIALLY
FUTURE-RELEVANT, confirmed** at restart, because their assumed replacement has
not occurred. Their omission remains benign in the positive ordinary/cache
history cases, but cannot receive a universal OVERWRITTEN classification.
`old_rd` does see the required low during LOAD; the defect is that no acceptance
slot samples the subsequent high before consumption. `ram_req=0`, flight=0 and
rd_rdy=1 describe an unaccepted request, not completed current data. No missing
historical payload bit has been established as necessary: this is a confirmed
request/response ordering defect at reconstruction/release. Do not serialize
refresh/address/data speculatively to fix it.

## Separate DDRAM platform wrapper state

These fields are inventoried to distinguish the complete memory hierarchy,
not to silently include HPS DDR3 in the G12 live-ROM-controller classification.
`sys/sysmem.sv` has two reset synchronizer bits per RAM1/RAM2/VBUF clock, and an
initial power-on init_reset_n1 plus a32-bit integer timeout (initial0, counts
to2,000,000) in the clock domain. They track platform
reset, never ss_freeze/LOAD. The hard HPS interfaces are external storage-service
state, not guest architecture or snapshot payload.

For each `f2sdram_safe_terminator` instance: init_reset_deasserted1 and lock_stage1
start0; state_write1 starts0; write_burstcounter8, write_burstcount_latch8 and
write_address_latch29 start0 (VBUF address width28); write_terminate_counter8,
burstcount_latch8 and address_latch29 start0; terminating1/read_terminating1/
write_terminating1 start0. The burst observer advances on write acceptance;
addresses/counts latch on burst start or synchronized platform reset. Reset
locks input and finishes an outstanding transfer with masked writes. During
ordinary non-reset operation, terminating/read_terminating/write_terminating
remain0 and the bus mux passes address/count/read/write/BE directly; read data,
read valid and waitrequest are unconditional passthrough. Observer history has
no normal-mode data/ordering consumer. SAVE/LOAD never asserts platform reset.
Thus these are external-service/session or overwritten transaction-observer
states, not missing guest SDRAM history. The transfer proof is explicitly for
legal user-interface responses with platform reset inactive; it does not prove
core replacement or HPS reset during DMA.
