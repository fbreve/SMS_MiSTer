# Exact-reference 100-word inventory

Reference: `8cd53ccc954c24970372ea6d8a3fb2336a14c46f`. Generated from committed read packing, with RAM ranges expanded. All unlisted bits are reserved zero.

| Word | Owner | Persistence | Fields / dependency |
|---|---|---|---|
| 0 | channel registers | persistent | Frequency, block, instrument, volume, sustain, key; drives controller |
| 1 | channel registers | persistent | Frequency, block, instrument, volume, sustain, key; drives controller |
| 2 | channel registers | persistent | Frequency, block, instrument, volume, sustain, key; drives controller |
| 3 | channel registers | persistent | Frequency, block, instrument, volume, sustain, key; drives controller |
| 4 | channel registers | persistent | Frequency, block, instrument, volume, sustain, key; drives controller |
| 5 | channel registers | persistent | Frequency, block, instrument, volume, sustain, key; drives controller |
| 6 | channel registers | persistent | Frequency, block, instrument, volume, sustain, key; drives controller |
| 7 | channel registers | persistent | Frequency, block, instrument, volume, sustain, key; drives controller |
| 8 | channel registers | persistent | Frequency, block, instrument, volume, sustain, key; drives controller |
| 9 | custom voices | persistent | Two 36-bit operator voices; ROM cannot reconstruct custom instruments |
| 10 | custom voices | persistent | Two 36-bit operator voices; ROM cannot reconstruct custom instruments |
| 11 | custom voices | persistent | Two 36-bit operator voices; ROM cannot reconstruct custom instruments |
| 12 | custom voices | persistent | Two 36-bit operator voices; ROM cannot reconstruct custom instruments |
| 13 | operator phase RAM | persistent | 18-bit accumulated phase; drives oscillator and rhythm phase |
| 14 | operator phase RAM | persistent | 18-bit accumulated phase; drives oscillator and rhythm phase |
| 15 | operator phase RAM | persistent | 18-bit accumulated phase; drives oscillator and rhythm phase |
| 16 | operator phase RAM | persistent | 18-bit accumulated phase; drives oscillator and rhythm phase |
| 17 | operator phase RAM | persistent | 18-bit accumulated phase; drives oscillator and rhythm phase |
| 18 | operator phase RAM | persistent | 18-bit accumulated phase; drives oscillator and rhythm phase |
| 19 | operator phase RAM | persistent | 18-bit accumulated phase; drives oscillator and rhythm phase |
| 20 | operator phase RAM | persistent | 18-bit accumulated phase; drives oscillator and rhythm phase |
| 21 | operator phase RAM | persistent | 18-bit accumulated phase; drives oscillator and rhythm phase |
| 22 | operator phase RAM | persistent | 18-bit accumulated phase; drives oscillator and rhythm phase |
| 23 | operator phase RAM | persistent | 18-bit accumulated phase; drives oscillator and rhythm phase |
| 24 | operator phase RAM | persistent | 18-bit accumulated phase; drives oscillator and rhythm phase |
| 25 | operator phase RAM | persistent | 18-bit accumulated phase; drives oscillator and rhythm phase |
| 26 | operator phase RAM | persistent | 18-bit accumulated phase; drives oscillator and rhythm phase |
| 27 | operator phase RAM | persistent | 18-bit accumulated phase; drives oscillator and rhythm phase |
| 28 | operator phase RAM | persistent | 18-bit accumulated phase; drives oscillator and rhythm phase |
| 29 | operator phase RAM | persistent | 18-bit accumulated phase; drives oscillator and rhythm phase |
| 30 | operator phase RAM | persistent | 18-bit accumulated phase; drives oscillator and rhythm phase |
| 31 | envelope RAM | persistent | 2-bit state plus 23-bit progression per operator |
| 32 | envelope RAM | persistent | 2-bit state plus 23-bit progression per operator |
| 33 | envelope RAM | persistent | 2-bit state plus 23-bit progression per operator |
| 34 | envelope RAM | persistent | 2-bit state plus 23-bit progression per operator |
| 35 | envelope RAM | persistent | 2-bit state plus 23-bit progression per operator |
| 36 | envelope RAM | persistent | 2-bit state plus 23-bit progression per operator |
| 37 | envelope RAM | persistent | 2-bit state plus 23-bit progression per operator |
| 38 | envelope RAM | persistent | 2-bit state plus 23-bit progression per operator |
| 39 | envelope RAM | persistent | 2-bit state plus 23-bit progression per operator |
| 40 | envelope RAM | persistent | 2-bit state plus 23-bit progression per operator |
| 41 | envelope RAM | persistent | 2-bit state plus 23-bit progression per operator |
| 42 | envelope RAM | persistent | 2-bit state plus 23-bit progression per operator |
| 43 | envelope RAM | persistent | 2-bit state plus 23-bit progression per operator |
| 44 | envelope RAM | persistent | 2-bit state plus 23-bit progression per operator |
| 45 | envelope RAM | persistent | 2-bit state plus 23-bit progression per operator |
| 46 | envelope RAM | persistent | 2-bit state plus 23-bit progression per operator |
| 47 | envelope RAM | persistent | 2-bit state plus 23-bit progression per operator |
| 48 | envelope RAM | persistent | 2-bit state plus 23-bit progression per operator |
| 49 | feedback RAM | recursive | signed 9-bit magnitude plus sign; recurrent operator modulation |
| 50 | feedback RAM | recursive | signed 9-bit magnitude plus sign; recurrent operator modulation |
| 51 | feedback RAM | recursive | signed 9-bit magnitude plus sign; recurrent operator modulation |
| 52 | feedback RAM | recursive | signed 9-bit magnitude plus sign; recurrent operator modulation |
| 53 | feedback RAM | recursive | signed 9-bit magnitude plus sign; recurrent operator modulation |
| 54 | feedback RAM | recursive | signed 9-bit magnitude plus sign; recurrent operator modulation |
| 55 | feedback RAM | recursive | signed 9-bit magnitude plus sign; recurrent operator modulation |
| 56 | feedback RAM | recursive | signed 9-bit magnitude plus sign; recurrent operator modulation |
| 57 | feedback RAM | recursive | signed 9-bit magnitude plus sign; recurrent operator modulation |
| 58 | operator output RAM | recursive/output | Modulator history feeds carriers; carrier samples feed mixer |
| 59 | operator output RAM | recursive/output | Modulator history feeds carriers; carrier samples feed mixer |
| 60 | operator output RAM | recursive/output | Modulator history feeds carriers; carrier samples feed mixer |
| 61 | operator output RAM | recursive/output | Modulator history feeds carriers; carrier samples feed mixer |
| 62 | operator output RAM | recursive/output | Modulator history feeds carriers; carrier samples feed mixer |
| 63 | operator output RAM | recursive/output | Modulator history feeds carriers; carrier samples feed mixer |
| 64 | operator output RAM | recursive/output | Modulator history feeds carriers; carrier samples feed mixer |
| 65 | operator output RAM | recursive/output | Modulator history feeds carriers; carrier samples feed mixer |
| 66 | operator output RAM | recursive/output | Modulator history feeds carriers; carrier samples feed mixer |
| 67 | operator output RAM | recursive/output | Modulator history feeds carriers; carrier samples feed mixer |
| 68 | operator output RAM | recursive/output | Modulator history feeds carriers; carrier samples feed mixer |
| 69 | operator output RAM | recursive/output | Modulator history feeds carriers; carrier samples feed mixer |
| 70 | operator output RAM | recursive/output | Modulator history feeds carriers; carrier samples feed mixer |
| 71 | operator output RAM | recursive/output | Modulator history feeds carriers; carrier samples feed mixer |
| 72 | operator output RAM | recursive/output | Modulator history feeds carriers; carrier samples feed mixer |
| 73 | operator output RAM | recursive/output | Modulator history feeds carriers; carrier samples feed mixer |
| 74 | operator output RAM | recursive/output | Modulator history feeds carriers; carrier samples feed mixer |
| 75 | operator output RAM | recursive/output | Modulator history feeds carriers; carrier samples feed mixer |
| 76 | SMS wrapper | transaction | fm_a bit 0, fm_d bits 8:1; pending CPU write |
| 77 | opll.vhd | pipeline/mixed | ss_response(7 downto 0) := opllptr(7 downto 0); ss_response(15 downto 8) := oplldat(7 downto 0); ss_response(16) := opllwr; |
| 78 | slotcounter.vhd | scheduler | ff_count bits 6:0; delayed counters reconstructed from base minus 2/5/8 modulo 72 |
| 79 | outputgenerator.vhd | pipeline/mixed | ss_response(0) := fb_wr; ss_response(1) := mo_wr; ss_response(5 downto 2) := ss_v_fb_addr(3 downto 0); ss_response(10 downto 6) := mo_addr(4 downto 0); ss_response(20 downto 11) := ss_v_fb_wdata(9 downto 0); ss_response(30 downto 21) := ss_v_mo_wdata(9 downto 0); |
| 80 | controller.vhd | pipeline/mixed | ss_response(31 downto 0) := ss_v_inst_cache(31 downto 0); |
| 81 | controller.vhd | pipeline/mixed | ss_response(3 downto 0) := ss_v_inst_cache(35 downto 32); ss_response(7 downto 4) := regs_addr(3 downto 0); ss_response(13 downto 8) := ss_v_slot_voice_addr(5 downto 0); ss_response(14) := ss_v_user_voice_addr(0); ss_response(15) := user_voice_wr; |
| 82 | controller.vhd | pipeline/mixed | ss_response(31 downto 0) := ss_v_user_voice_wdata(31 downto 0); |
| 83 | controller.vhd | pipeline/mixed | ss_response(3 downto 0) := ss_v_user_voice_wdata(35 downto 32); ss_response(4) := regs_wr; ss_response(26 downto 5) := regs_wdata(23 downto 16) & regs_wdata(13 downto 0); |
| 84 | controller.vhd | pipeline/mixed | ss_response(5 downto 0) := rflag(5 downto 0); ss_response(6) := am; ss_response(7) := pm; ss_response(8) := wf; ss_response(12 downto 9) := ml(3 downto 0); ss_response(19 downto 13) := tl(6 downto 0); ss_response(22 downto 20) := fb(2 downto 0); ss_response(26 downto 23) := ar(3 downto 0); ss_response(30 downto 27) := dr(3 downto 0); |
| 85 | controller.vhd | pipeline/mixed | ss_response(3 downto 0) := sl(3 downto 0); ss_response(7 downto 4) := rr(3 downto 0); ss_response(10 downto 8) := blk(2 downto 0); ss_response(19 downto 11) := fnum(8 downto 0); ss_response(23 downto 20) := rks(3 downto 0); ss_response(24) := key; ss_response(25) := rhythm; ss_response(26) := extra_mode; ss_response(27) := ss_v_vindex(0); |
| 86 | envelopegenerator.vhd | pipeline/mixed | ss_response(4 downto 0) := rslot(4 downto 0); ss_response(29 downto 5) := ss_v_memin(24 downto 0); ss_response(30) := memwr; |
| 87 | envelopegenerator.vhd | pipeline/mixed | ss_response(12 downto 0) := egout(12 downto 0); ss_response(30 downto 13) := lastkey(17 downto 0); |
| 88 | envelopegenerator.vhd | persistent/mixed | ss_response(19 downto 0) := amphase(19 downto 0); |
| 89 | envelopegenerator.vhd | pipeline/mixed | ss_response(22 downto 0) := egphase(22 downto 0); ss_response(24 downto 23) := egstate(1 downto 0); |
| 90 | envelopegenerator.vhd | persistent/mixed | ss_response(17 downto 0) := ntable(17 downto 0); |
| 91 | attacktable.vhd | pipeline/mixed | ss_response(7 downto 0) := ff_w(7 downto 0); ss_response(14 downto 8) := ff_d1(6 downto 0); ss_response(21 downto 15) := ff_d2(6 downto 0); |
| 92 | attacktable.vhd | pipeline/mixed | ss_response(12 downto 0) := data(12 downto 0); |
| 93 | phasegenerator.vhd | pipeline/mixed | ss_response(0) := memwr; ss_response(18 downto 1) := memin(17 downto 0); ss_response(31 downto 19) := pmcount(12 downto 0); |
| 94 | phasegenerator.vhd | pipeline/mixed | ss_response(0) := noise; ss_response(18 downto 1) := pgout(17 downto 0); |
| 95 | phasegenerator.vhd | persistent/mixed | ss_response(17 downto 0) := lastkey(17 downto 0); ss_response(18) := noise14; ss_response(19) := noise17; |
| 96 | operator.vhd | pipeline/mixed | ss_response(17 downto 0) := addr(17 downto 0); ss_response(30 downto 18) := ff_egout(12 downto 0); |
| 97 | operator.vhd | pipeline/mixed | ss_response(3 downto 0) := ss_v_faddr(3 downto 0); ss_response(17 downto 4) := opout(13 downto 0); |
| 98 | sinetable.vhd | pipeline/mixed | ss_response(10 downto 0) := ff_data0(10 downto 0); ss_response(21 downto 11) := ff_data1(10 downto 0); ss_response(22) := ff_sign; ss_response(23) := ff_wf; |
| 99 | sinetable.vhd | pipeline/mixed | ss_response(8 downto 0) := ff_weight(8 downto 0); ss_response(22 downto 9) := ff_data(13 downto 0); |

## Dependency and omission decisions

Preserve channel registers, both custom voices, envelope state/progression, oscillator phase, both lastkey vectors, AM phase, PM count, rhythm flags and noise state for deterministic sustained notes and percussion. Key edge history is required to avoid artificial retriggers. Phase offsets do not generally decay; an autonomous counter is not a settling filter. Noise sequence offset likewise has no guaranteed convergence. Feedback recurrence may converge for a particular voice but cannot be assumed to contract for all voices.

Words 80-85 mix cached instrument identity, pending register/custom-voice writes and current decoded parameters. A stale write strobe/address/data can overwrite the restored macro state before refreshing. Words 86 and 89 contain an envelope RAM writeback and working progression: stale values can corrupt one operator permanently. Word 93 mixes phase writeback with persistent PM count. Words 94 and 96-99 are short arithmetic pipelines, but their results flow into operator history and feedback, making their *effects* potentially persistent. Word 79 contains pending feedback/output RAM writes; it is not an output-only buffer. Word 87 mixes envelope output and persistent key history. Word 95 mixes key history with rhythm phase-derived noise latches.

Least risky tests: omit attack lookup words 91-92, sine lookup words 98-99, operator pipeline 96-97, then output writeback 79; test separately before combinations. RAM output-history 58-75 must be tested separately from feedback 49-57. A macro-only variant retains 0-57 plus scheduler and persistent subfields; do not silently classify all words >=79 as disposable.

The exact 100-word reference already does NOT save temporal mixer mute/address/accumulator/output (the later 104-word experiments do). There are no mixer state words here to remove. Factory voice ROM, combinational tables, continuously assigned RAM read ports and scratch variables overwritten before use are also outside this state map. Thus earlier mixer-omission savings cannot be claimed again.

Format experiment policy: retain capture, word numbering, descriptor, reserved bits, initialization and legacy reset/default flow. Only gate selected restore writes in the experimental harness; this models stale state after a load without changing the file format. It does not prove synthesis savings. A production omission would also need to simplify readback/validation without making files unreadable by the complete reference.

## RAM bit layouts

Words 0-8: FNUM[8:0], BLK[11:9], KEY[12], SUS[13], VOL[17:14], INST[21:18]. Words 9/11 are low 32 custom-voice bits, 10/12 high four bits: RR[3:0], SL[7:4], DR[11:8], AR[15:12], FB[18:16], WF[19], TL[25:20], KL[27:26], ML[31:28], KR[32], EG[33], PM[34], AM[35]. Words 13-30 are phase[17:0]. Words 31-48 pack phase[22:0], envelope state[24:23]. Words 49-75 pack magnitude[8:0] and sign[9].

## Field lifetimes and consumers

| Fields | Lifetime and dependency | Omission consequence |
|---|---|---|
| opllptr/oplldat/opllwr (77), wrapper bus (76) | CPU transaction survives until later write; controller consumes at stage 2 | Wrong register writes or persistent sound settings |
| count (78) | Repeating 72-enable scheduler; generates four coherent delayed counters | Misaddressed operator work; retain or reconstruct coherently |
| inst_cache (80,81) | Until instrument changes; governs cache-refresh decisions | Stale cache can prevent refresh; persistent |
| regs_addr, slot_voice_addr, user_voice_addr (81) | Current channel/voice selection | Wrong RAM read/update until overwritten; effects can outlive field |
| user_voice_wr/wdata, regs_wr/wdata (81-83) | Pending RAM writes | May overwrite restored custom voice or channel register |
| rflag (84), extra_mode (85) | Global rhythm/extra mode, until CPU write | Broken rhythm/mode can persist indefinitely |
| am,pm,wf,ml,tl,fb,ar,dr,sl,rr,blk,fnum,rks,key,rhythm (84,85), vindex (85) | Decoded slot parameters / selection, refreshed per slot | Intermediate transient drives phase/envelope and pending writes |
| rslot,memin,memwr (86) | Envelope RAM address/write pipeline | Can corrupt one restored envelope |
| egout (87) | Operator attenuation pipeline | Wrong amplitude enters feedback/history |
| EG lastkey (87) | One edge-history bit/operator until next visit | Artificial attack/release changes long-lived envelope |
| amphase (88) | Autonomous AM oscillator, not reset by normal samples | LFO offset need not converge |
| egphase,egstate (89) | Working envelope progression between RAM read/update | Wrong writeback can persist through sustained notes |
| ntable (90) | Autonomous feedback-shift noise generator | Sequence phase is not a settling filter; percussion affected |
| ff_w,ff_d1,ff_d2,data (91,92) | Attack interpolation pipeline | Short local lifetime, potentially persistent envelope/output effects |
| memwr,memin (93) | Phase RAM pending update | Wrong phase increment/writeback persists |
| pmcount (93) | PM LFO phase | Persistent pitch modulation offset |
| noise,pgout (94) | Rhythm noise output and operator phase pipeline | Can propagate into operator and feedback history |
| PG lastkey (95) | Key edge history per operator | Artificial oscillator restart |
| noise14,noise17 (95) | Phase-derived rhythm latches refreshed at slots 14/17 | Usually locally short, verify percussion and feedback effects |
| addr,ff_egout,faddr,opout (96,97) | Operator lookup address, attenuation, feedback address, output | Stale operator results feed recurrent history |
| ff_data0,ff_data1,ff_sign,ff_wf,ff_weight,ff_data (98,99) | Sine interpolation pipeline | Short local lifetime; resulting samples feed recurrent history |
| fb_wr,mo_wr,fb_addr,mo_addr,fb_wdata,mo_wdata (79) | Output/feedback RAM pending transactions | Stale transactions may change modulation and feedback |

No blanket time bound is implied by the word classification. A refreshed pipeline can leave altered RAM behind. Register settings alone do not encode accumulated oscillator/envelope histories.
