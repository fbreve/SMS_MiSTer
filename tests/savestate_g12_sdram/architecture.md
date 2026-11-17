# Current memory hierarchy and G12 boundary

| Path / requester | Address/request, data/ack and first consumer | Storage/control/arbitration |
|---|---|---|
| CPU cartridge ROM | T80s A/MREQ_n/RD_n -> memory_bus rom_RD; memory_decode -> rom_a_i -> evolution_rom_address -> SMS ram_addr -> optional512-byte header offset/cart mask -> sdram raddr25. dout8 -> system rom_do -> plain/combinational reversal/decrypt mux -> memory_D_out -> CPU DI_Reg at fetch T2 | The live `rtl/sdram.sv`; one edge-detected read, latched25-bit address,16-bit returned word/byte lane. rd_rdy intentionally unconnected; CPU WAIT defaults1. No guest arbiter/backpressure |
| CPU internal boot ROM | A[13:0], sprom synchronous Q, active BIOS mux -> DI | Immutable initialized M10K; not live SDRAM |
| SMS external BIOS | BIOS download ROMAD[17:0]/BIOSWEN writes spram18; reads mapper-translated rom_a_i[17:0] -> registered RAM Q -> BIOS mux -> DI | Immutable session media in BRAM; no live SDRAM response ownership |
| GG external BIOS | ROMAD[13:0]/GG_BIOSWEN vs CPU A[13:0], spram14 Q -> BIOS mux | Same distinction; visibility is existing mapper/IO architecture |
| CPU WRAM | system ram_a: SC A[10:0], ordinary A[12:0], System E A[13:0]; memory_bus ram_WR/data D_in. SMS ram_inst spram14 with synchronous read Q -> ram_D_out -> DI | Physical16KiB M10K. Save/LOAD overrides address/write, ordinary8KiB/System E16KiB transfer. Preparation returns read ownership to CPU; guest writes remain inhibited |
| Cart SRAM/SC RAM | nvram_a with owner/size/bank decode; nvram_we/data; dual-port nvram backing -> nvram_D_out -> CPU | Internal BRAM, explicit existing NVRAM transfer policies. No G12 storage; this investigation does not claim F06 Sega SRAM completeness |
| EEPROM | Serial protocol engine -> nvram address/data/write; backing Q -> engine read latch -> CPU pin/data bit | Internal emulated EEPROM and shared BRAM; explicit state/backing saves already proven. Not physical ROM SDRAM |
| System E VRAM | Independent VDP1/VDP2 CPU/direct and renderer ports; each32KiB two physical16KiB halves, selection bits mapper[7]/[6] | Private VDP dual-port BRAM. No live SDRAM contention. Savestate ports select each half directly; transfer proof is separate below |
| System E ROM | Same CPU/request controller, fixed low-ROM window and rom_bank-based upper window via current memory_decode | Same live SDRAM controller. Neither VDP requests it |
| Savestate DDRAM | savestates DDRAM_ADDR29, RD/WE,64-bit data,BE8,BURSTCNT1; BUSY acceptance/DOUT_READY response. SMS mux switches from screen_rotate when frozen; sys_top forwards HPS memory interface | A different physical memory bus/controller from SDRAM pins. No guest ROM response/rd_rdy enters its drain |
| Screen rotation DDRAM | screen_rotate CLK_VIDEO path normally owns mux; SAVE takes over with stable clk_sys DDRAM_CLK | Presentation infrastructure; not a guest ROM requester. Drain watches this bus's residual transactions |

The v16 freeze drain waits32 consecutive host clocks with neither DDRAM_BUSY nor
DDRAM_DOUT_READY. It does **not** observe live sdram.q, ram_req, rd_rdy, old_rd,
sd_dat, SDRAM command pins or CAS. The long flush also does not by itself issue
a restored ROM read. Correctness depends on the actual private CPU T1 request,
physical read completion, and only then historical T2/guest consumption.

G12 ends at the8-bit physical `ram_dout` / system `rom_do` input. MC8123 and
SEGASYS1 registered decrypt outputs and their address/opcode history are G11.
This task identifies those ports and mux boundaries only; no G11 proof or FM
state investigation is performed. BIOS and on-chip RAM read-Q refill is distinct
from SDRAM transaction history.

The exact DDRAM platform wrapper is `sys/sys_top.v:sysmem` of module
`sysmem_lite`, defined in `sys/sysmem.sv` (the filename does not match the module
name). Its RAM1 path passes through `sys/f2sdram_safe_terminator.sv` to
`sysmem_HPS_fpga_interfaces`, also defined in sysmem.sv, and the
`cyclonev_hps_interface_fpga2sdram` hard interface. This is neither
`rtl/sdram.sv` nor a second guest ROM arbiter. RAM2/audio and VBUF/scaler have
separate ports/terminators. Transfer tests exercise the legal RAM1 user-interface
contract; they do not simulate the HPS/Linux/physical DDR3 internals or global
reset termination.

Timing contract to corroborate: accepted SAVE is a CPU-enable M1+MREQ fetch with
ISet00, VBlank and x<256, not an arbitrary request-time stop. Normal fetch T1
asserts the read; the aligned clkref resynchronizes q. Acceptance at T2 is10 or15
host clocks later, after q6 sampled the returned word. During LOAD, DIRSet and
the long held interval supply a sampled-low rd. Private T1 reissues the restored
address; private T2 is15 clocks later. For turbo/System E private T1 at raw phase25,
the next /10 reference pulse is5 clocks later: completion is at most12 clocks
after T1, before T2. Ordinary /15 aligned T1 completes within7 clocks. Actual
monitors must check these bounds and returned data rather than infer them from
an idle flag. Suppressed/paused T captures need the one-private-T1 case checked
separately before closure.
