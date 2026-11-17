# F16 NMI state inventory

Baseline: `d1df590` (committed F15). Source locations below refer to unchanged production files.

## Sources and ownership

`SMS.sv:1044` supplies `systeme ? 1 : joya[6] & joyb[6]` as Pause. These are current host controller inputs, not emulated historical state. System E host Pause is the separate F12 clock-control path and disables this SMS NMI source. `SMS.sv:1417` enables the physical GG link only for the selected USERIO mode and GG; `SMS.sv:1489` permutes physical USER_IN into PC0..PC6. Those pins, host mode, and peer behavior are external inputs, not state to rewind.

`rtl/system.vhd:620` drives T80 NMI_n with `(pause or effective_gg) and gg_link_nmi_n`; effective_gg includes Evolution GG mode. Thus SMS Pause is masked in GG. The fixture uses this exact expression, actual production IO and T80s, normal IO port qualification and a real ROM program. It does not instantiate the complete MiSTer top, SDRAM, or physical host bridge. DDR and synchronous WRAM are behavioral transport/memory models; unrelated peripheral snapshots are fixed. The accelerated initial video blanking phase uses ce_pix every clock while CPU reset is asserted, then the ordinary 1:10 pixel enable. No CPU NMI flag or SAVE boundary is forced.

## CPU inventory

| Item | Width, reset | Update and role | v11 / LOAD / DIRSet | Future relevance |
|---|---|---|---|---|
| NMI_n input | 1, source dependent | Combinational source expression | External level is not CPU payload; GG endpoint state is separately saved | Falling transition can request NMI |
| OldNMI_n | 1 process variable, **no reset assignment** | Every rising system clock outside DIRSet, regardless of CEN: remembers NMI_n; simulation starts U until sampled | Unsaved; DIRSet leaves Q's value unchanged and skips sampling on that edge | Distinguishes already sampled low from a fresh falling edge; does not hold while CPU frozen |
| NMI_s | 1, reset 0 | Falling input detected using old OldNMI_n sets it. At enabled final instruction T_Res with Prefix=00, pending is consumed. It coalesces edges rather than queues them | Unsaved; DIRSet explicitly clears it | Pending future NMI, even when input has returned high |
| NMICycle | 1, reset 0 | At instruction-end arbitration, pending sets NMICycle=1 and clears IFF1. Cleared at next instruction-end arbitration | Unsaved; DIRSet explicitly clears it | Selects special entry microcode, suppresses normal fetch/PC increment, pushes PC and vectors to 0066 |
| IntCycle | 1, reset 0 | Competing maskable interrupt acceptance; NMI has priority | Unsaved; DIRSet clears | Determines interrupt microcode; not asserted in the NMI-only fixture (INT held inactive) |
| IFF1 / IFF2 | 1 each, reset 0 | EI sets both, DI clears both, NMI clears only IFF1; RETN copies IFF2 to IFF1 | Saved REG[210]/[211], restored by DIRSet | They do **not** encode NMI pending/entry: DI already gives IFF1=0 without NMI |
| IM | 2, reset 00 | IM instructions; affects maskable interrupts | REG[209:208], restored | NMI always vectors 0066, independent of IM |
| Halt_FF | 1, reset 0 | HALT sets; accepted interrupt cycles clear on enabled clocks | REG[229], restored | NMI releases HALT; a halted CPU is not an exclusion of NMI capture |
| PC, SP | 16 each, reset 0000/FFFF | Fetch/flow; entry decrements SP twice and pushes PC; final entry sets PC=0066 | REG[79:64]/[63:48], restored | Before the first dummy fetch's T2, neither distinguishes normal fetch from accepted NMI |
| R, I | 8 each, reset 00 | R increments on M1; I is software set/vector base for maskable IM2 | REG[47:40]/[39:32], restored | R changes during entry, but at accepted pre-T2 capture is still identical to normal fetch |
| A,F,A',F', GPR bank, WZ, alternate selector | 8/8/8/8,128,16,1; AF and AF' reset FFFF; register-file 128 bits have no reset (U until written in simulation); WZ reset0000, alternate reset0 | Normal CPU datapath and instruction side effects; fixture explicitly initializes all primary/alternate GPRs and IX/IY | REG[7:0]/[15:8]/[23:16]/[31:24], [207:80], [227:212], [228]; restored | Handler may change them; no unique NMI-history encoding |
| MCycle / TState | 3 each, reset 001/000 | Enabled microcycle machine | Unsaved; DIRSet normalizes 001/001 | Accepted opcode bus in this fixture is MC1/T2, including NMI dummy fetch; restarting ordinary fetch discards entry context |
| Prefix / ISet / Pre_XY_F_M | Prefix/ISet 2, Pre_XY_F_M 3, reset normal/000 | Prefix decode and extra index cycles | Not payload; ISet=00 required at capture; DIRSet clears prefix-related sequencing | Pending can persist through prefixes; acceptance is delayed while nonzero ISet |
| IR, decoder controls, T_Res, MCycles, TStates | IR8 plus combinational controls | NMI MC1/T2 forces IR=00; NMICycle alters that NOP's microcode into entry | IR not saved; canonical fetch is reconstructed, decoder controls derived | Existing restart is valid only when NMI entry selection is also reconstructed |
| M1_n, MREQ_n, RD_n, WR_n, IORQ_n | 1 each; inactive at reset | T80/T80s bus phases; T80s updates on CEN | Unsaved; DIRSet M1 low and other strobes high | Acceptance tests only M1/MREQ, which do not exclude NMI entry |
| No_BTR, Auto_Wait_t1/2, BusAck, BusReq_s | 1 each, reset 0 | Instruction repeat, wait, bus request machinery | DIRSet clears; no payload | Affect scheduling; normal production T80s defaults WAIT_n/BUSRQ_n inactive; fixture matches those defaults |

T80 REG is exactly 230 bits, including Halt at bit229; no hidden NMI state is exported through it. CPU words 2..5 store 64+64+64+38 bits; word5[63:38] is written zero and ignored by CPU restore.

## GG endpoint inventory

All fields below are in `rtl/io.vhd`, initialized by declaration and reset. Reset overrides noted where different. Protocol and ordinary IO side effects hold during ss_freeze. GG-disabled/link-disabled ordinary clocks clear NMI flags and RX state, and normalize synchronizers. The later gg_state_set block restores the following from gg_state_in **even while frozen**, on the same system edge as T80 DIRSet. DIRSet itself does not touch IO.

| Field | Width / reset | Saved bits | Role / update |
|---|---|---|---|
| gg_ddr | 8 / FF | 7:0 | OUT02 controls direction; bit7 disables/clears PC6 NMI; bit6 must be input for falling-edge NMI |
| gg_txd / rxd / pdr | 8 each / 00,FF,7F (pdr declaration00) | 15:8 / 23:16 / 31:24 | Local TX/RX data and parallel drive state |
| gg_sctrl | 5 / 0 | 36:32 | Baud, TX/RX enables and serial NMI enable; disabling IRQ clears serial NMI |
| gg_tx_line / busy / shift[9:1] | 1/1/9 / 1,0,all1 | 37 / 38 / 47:39 | Local serial output engine; shift bit0 is reconstructed zero on restore |
| gg_tx_cnt / bits | 14/4 / 0 | 61:48 / 65:62 | Enabled-clock baud timing and remaining TX bits |
| gg_tx_pending / pending_data | 1/8 / 0 | 66 / 74:67 | Buffered TX request |
| gg_rx_sync / pc6_sync | 3 each / 111 | 77:75 / 80:78 | Enabled-clock pipelines from current physical PC5/PC6 |
| gg_pc6_prev | 1 / 1 | 81 | Prior synchronized PC6; qualified falling edge sets gg_nmi_pc6 |
| gg_rx_state / cnt / bits / shift | 2/14/3/8 / 0,0,0,FF | 83:82 / 97:84 / 100:98 / 108:101 | RX start/data/stop sampling; completion with sctrl(3)=1 sets serial NMI, including error completion |
| gg_rx_ready / frame_err | 1 each / 0 | 109 / 110 | RX status; IN04 clears them and serial NMI |
| gg_nmi_serial / pc6 | 1 each / 0 | 111 / 112 | Latched local NMI sources; output low while either set and GG/link enabled |
| gg_tx_wr_d | 1 / 0 | 113 | TX bus write edge history |

gg_state_out[127:114] are reserved zeros. Other IO fields (ctrl, multicart latch, SK1100 selector, analog selectors) are separately serialized and do not encode T80 NMI history. GG local source restoration can create a new falling **output** transition after DIRSet when Q's source was cleared. It cannot identify whether the T-time CPU already consumed that edge, still had it pending, or was entering an NMI. It is therefore not a substitute for CPU temporal state.

## Exact sequence and acceptance overlay

1. Inactive: input high, Old high, pending0, entry0.
2. Input falls: before sampling, input0/Old1; CPU register payload is unchanged.
3. On ordinary host clock: NMI_s becomes1, Old becomes0, including with CEN=0. A released pulse leaves pending1/Old1.
4. On enabled instruction end (`T_Res`, final MCycle, Prefix=00): pre-edge NMI_s is consumed, NMICycle becomes1, IFF1 clears. An edge first sampled on this same clock is not consumed unless there was already pending state; signal assignment ordering can coalesce a simultaneous second event.
5. First NMI MC1 dummy fetch: M1/MREQ can both be low, ISet00. At T2 normal opcode/PC increment are suppressed, IR00 forced and R incremented. NMI entry uses three machine cycles, first length5; SP decrements, PC high/low are written to the stack, then PC becomes0066.
6. Handler executes normally; NMICycle clears at its preceding entry instruction end. RETN restores IFF1 from IFF2. A further falling edge during entry can set NMI_s again, including pending1 and NMICycle1 simultaneously.

Production SAVE requires `state==ST_WAIT_BOUNDARY`, !storage_busy, cpu_ce, !M1, !MREQ, ISet00, vblank, x<256. CPU REG is captured **pre-tick on that accepted edge**. ST_ARM_FREEZE captures IO/GG/video one host clock later and freezes before next CPU enable; 32 idle clocks drain transport. Neither pending, NMICycle nor Old is tested. T80's input sampler keeps running while frozen.

| Stage | Class | Explanation |
|---|---|---|
| Inactive normal fetch | A | Canonical accepted baseline |
| Fresh external falling edge, not sampled until capture clock | A | Input can change in preceding half-clock without forcing CPU state |
| Pending at non-fetch / nonzero prefix | B | Request waits for M1/MREQ and ISet00 |
| Pending at ordinary eligible fetch | A | Accepted with pending1, input either high or low |
| Instruction-end arbitration edge itself | C | M1/MREQ pre-edge bus is not the eligible fetch in the exercised normal instruction path; the following fetch is eligible |
| Accepted NMICycle first dummy fetch | A | Real T80 produces eligible M1/MREQ with NMICycle1 before stack writes |
| NMI stack-write machine cycles | C | M1 high; request waits |
| Both pending and entry at first dummy fetch | A when a second physical edge arrives | Separate double-pulse fixture checks this case |
| First handler opcode / later normal handler fetch | A | PC0066 and guest side effects then become ordinary architectural state |
| Prefix tails / read / write phases | B for request, C for acceptance in those phases | Acceptance waits; pending is not thereby excluded |

Classes concern semantic stages; storage busy, non-vblank, x>=256 and absent CPU enable additionally defer every stage. No claim of hardware metastability behavior is made for a physical input exactly on the sampling edge: tests place transitions on the preceding negative edge.
