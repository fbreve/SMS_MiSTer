# Complete sequential inventory

Declared logical widths; arrays counted once, wrapper separately. Scratch rows have zero stored bits. Full reset/CE/dependency/consumer fields are in [inventory.csv](inventory.csv) and [inventory.json](inventory.json).

|Module|Field|Width × count|Stored bits|Class|Update / CE|Reset|First consumer|Exclusion / preservation rationale|
|---|---|---:|---:|---|---|---|---|---|
|system|fm_a|1 × 1|1|ARCHITECTURAL PROGRAM STATE|!ss_freeze && FM IO write|0|opll address/data selection|Retain temporal/program history unless a separately proven reconstruction is supplied.|
|system|fm_d|8 × 1|8|ARCHITECTURAL PROGRAM STATE|!ss_freeze && FM IO write|0|opll sticky command|Retain temporal/program history unless a separately proven reconstruction is supplied.|
|opll|opllptr|8 × 1|8|ARCHITECTURAL PROGRAM STATE|xena && a=0|0|controller addr|Retain temporal/program history unless a separately proven reconstruction is supplied.|
|opll|oplldat|8 × 1|8|ARCHITECTURAL PROGRAM STATE|xena && a=1|none|controller data|Retain temporal/program history unless a separately proven reconstruction is supplied.|
|opll|opllwr|1 × 1|1|TEMPORAL SYNTHESIS STATE|xena && bus write|0|controller stage2|Sticky write: not an edge pulse.|
|opll/s0|ff_count|7 × 1|7|TEMPORAL SYNTHESIS STATE|xena, modulo72|71-delay|slot/stage|Retain one historical modulo72 phase.|
|opll/s2|ff_count|7 × 1|7|DERIVED / RECONSTRUCTABLE|xena, modulo72|71-delay|slot/stage|Common reset and xena prove count=(s0-delay) mod72; restore privately with fixed delay2/5/8, without guest ticks. See counter_proof.json.|
|opll/s5|ff_count|7 × 1|7|DERIVED / RECONSTRUCTABLE|xena, modulo72|71-delay|slot/stage|Common reset and xena prove count=(s0-delay) mod72; restore privately with fixed delay2/5/8, without guest ticks. See counter_proof.json.|
|opll/s8|ff_count|7 × 1|7|DERIVED / RECONSTRUCTABLE|xena, modulo72|71-delay|slot/stage|Common reset and xena prove count=(s0-delay) mod72; restore privately with fixed delay2/5/8, without guest ticks. See counter_proof.json.|
|ct|inst_cache|4 × 9|36|TEMPORAL SYNTHESIS STATE|CE stage3|none|stage0 voice address|Can lag programmed channel instrument; preserve pending lag.|
|ct|regs_addr|4 × 1|4|TEMPORAL SYNTHESIS STATE|CE stage0|0|registermemory read|Retain temporal/program history unless a separately proven reconstruction is supplied.|
|ct|slot_voice_addr|6 × 1|6|TEMPORAL SYNTHESIS STATE|CE stage0|0|voice read|Retain temporal/program history unless a separately proven reconstruction is supplied.|
|ct|user_voice_addr|6 × 1|6|TEMPORAL SYNTHESIS STATE|CE stage0|0|voice read/write|Retain temporal/program history unless a separately proven reconstruction is supplied.|
|ct|user_voice_wr|1 × 1|1|TEMPORAL SYNTHESIS STATE|CE stage0/2|0|voice write|Retain temporal/program history unless a separately proven reconstruction is supplied.|
|ct|user_voice_wdata|36 × 1|36|TEMPORAL SYNTHESIS STATE|CE stage2 guest write|none|voice write|Retain temporal/program history unless a separately proven reconstruction is supplied.|
|ct|regs_wr|1 × 1|1|TEMPORAL SYNTHESIS STATE|CE stage0/2|0|register write|Retain temporal/program history unless a separately proven reconstruction is supplied.|
|ct|regs_wdata|24 × 1|24|TEMPORAL SYNTHESIS STATE|CE stage2 matching channel|none|register write|Retain temporal/program history unless a separately proven reconstruction is supplied.|
|ct|rflag|8 × 1|8|ARCHITECTURAL PROGRAM STATE|CE stage2 addr14|0|rhythm/key/voice select|Only low6 used; upper2 non-observable.|
|ct|am|1 × 1|1|TEMPORAL SYNTHESIS STATE|CE stage3, regs+slot voice|none|EG/PG/operator after stage delay|Retain temporal/program history unless a separately proven reconstruction is supplied.|
|ct|pm|1 × 1|1|TEMPORAL SYNTHESIS STATE|CE stage3, regs+slot voice|none|EG/PG/operator after stage delay|Retain temporal/program history unless a separately proven reconstruction is supplied.|
|ct|wf|1 × 1|1|TEMPORAL SYNTHESIS STATE|CE stage3, regs+slot voice|0|EG/PG/operator after stage delay|Retain temporal/program history unless a separately proven reconstruction is supplied.|
|ct|ml|4 × 1|4|TEMPORAL SYNTHESIS STATE|CE stage3, regs+slot voice|0|EG/PG/operator after stage delay|Retain temporal/program history unless a separately proven reconstruction is supplied.|
|ct|tl|7 × 1|7|TEMPORAL SYNTHESIS STATE|CE stage3, regs+slot voice|0|EG/PG/operator after stage delay|Retain temporal/program history unless a separately proven reconstruction is supplied.|
|ct|fb|3 × 1|3|TEMPORAL SYNTHESIS STATE|CE stage3, regs+slot voice|0|EG/PG/operator after stage delay|Retain temporal/program history unless a separately proven reconstruction is supplied.|
|ct|ar|4 × 1|4|TEMPORAL SYNTHESIS STATE|CE stage3, regs+slot voice|0|EG/PG/operator after stage delay|Retain temporal/program history unless a separately proven reconstruction is supplied.|
|ct|dr|4 × 1|4|TEMPORAL SYNTHESIS STATE|CE stage3, regs+slot voice|0|EG/PG/operator after stage delay|Retain temporal/program history unless a separately proven reconstruction is supplied.|
|ct|sl|4 × 1|4|TEMPORAL SYNTHESIS STATE|CE stage3, regs+slot voice|0|EG/PG/operator after stage delay|Retain temporal/program history unless a separately proven reconstruction is supplied.|
|ct|rr|4 × 1|4|TEMPORAL SYNTHESIS STATE|CE stage3, regs+slot voice|0|EG/PG/operator after stage delay|Retain temporal/program history unless a separately proven reconstruction is supplied.|
|ct|blk|3 × 1|3|TEMPORAL SYNTHESIS STATE|CE stage3, regs+slot voice|0|EG/PG/operator after stage delay|Retain temporal/program history unless a separately proven reconstruction is supplied.|
|ct|fnum|9 × 1|9|TEMPORAL SYNTHESIS STATE|CE stage3, regs+slot voice|0|EG/PG/operator after stage delay|Retain temporal/program history unless a separately proven reconstruction is supplied.|
|ct|rks|4 × 1|4|TEMPORAL SYNTHESIS STATE|CE stage3, regs+slot voice|0|EG/PG/operator after stage delay|Retain temporal/program history unless a separately proven reconstruction is supplied.|
|ct|key|1 × 1|1|TEMPORAL SYNTHESIS STATE|CE stage3, regs+slot voice|0|EG/PG/operator after stage delay|Retain temporal/program history unless a separately proven reconstruction is supplied.|
|ct|rhythm|1 × 1|1|TEMPORAL SYNTHESIS STATE|CE stage3, regs+slot voice|0|EG/PG/operator after stage delay|Retain temporal/program history unless a separately proven reconstruction is supplied.|
|ct|extra_mode (variable)|1 × 1|1|ARCHITECTURAL PROGRAM STATE|CE stage2 addr240|0|future user-instrument writes|Disables standard user writes when set; not dead although alternate voice indexing is commented out.|
|ct|vindex (variable)|6 × 1|6|TEMPORAL SYNTHESIS STATE|CE stage0 slot mod2|0|stage2 user write decode|Only0/1 reachable, so one historical bit sufficient.|
|ct/u_register_memory|regs_array|24 × 9|216|ARCHITECTURAL PROGRAM STATE|init then regs_wr (ungated host)|startup sweep|registered odata|22 meaningful bits/entry; bits15:14 zero,18 padding bits total.|
|ct/u_register_memory|odata|24 × 1|24|DERIVED / RECONSTRUCTABLE|every host edge from addressed array|none|ct stage2/3|Can refill stationary ports before resume; old-data write/read collision requires capture normalization.|
|ct/u_register_memory|init_state (variable)|4 × 1|4|TEMPORAL SYNTHESIS STATE|startup sweep0..9|0|initialization|Source contains no initialization-ready SAVE guard. Conservatively retain initialization position/control for unrestricted early capture; may be excluded only with a proven ready-gated capture contract.|
|ct/vmem|voices user entries0..1|36 × 2|72|ARCHITECTURAL PROGRAM STATE|startup then user_voice_wr|ROM startup|two registered read ports|63 writable bits,9 carrier TL/FB bits remain ROM zero.|
|ct/vmem|voices fixed entries2..37|36 × 36|1296|UNKNOWN|startup only|ROM startup|voice reads|Immutable ROM constants AFTER initialization. Before completion, old backing contents are not proven overwritten before observation. Conservatively preserve these1296 bits or prove an initialization-ready capture gate.|
|ct/vmem|odata|36 × 1|36|DERIVED / RECONSTRUCTABLE|every host edge, voices+address|none|ct voice controls/update|Stationary synchronous read cache; refill with writes suppressed.|
|ct/vmem|rodata|36 × 1|36|DERIVED / RECONSTRUCTABLE|every host edge, voices+address|none|ct voice controls/update|Stationary synchronous read cache; refill with writes suppressed.|
|ct/vmem|rom_addr|6 × 1|6|TEMPORAL SYNTHESIS STATE|initialization only|none|VoiceROM|Source contains no initialization-ready SAVE guard. Conservatively retain initialization position/control for unrestricted early capture; may be excluded only with a proven ready-gated capture contract.|
|ct/vmem|rstate|2 × 1|2|TEMPORAL SYNTHESIS STATE|startup three-state sweep|0|voices init|Source contains no initialization-ready SAVE guard. Conservatively retain initialization position/control for unrestricted early capture; may be excluded only with a proven ready-gated capture contract.|
|ct/vmem|init_id (variable)|6 × 1|6|TEMPORAL SYNTHESIS STATE|startup0..38|0|voices init|Source contains no initialization-ready SAVE guard. Conservatively retain initialization position/control for unrestricted early capture; may be excluded only with a proven ready-gated capture contract.|
|ct/vmem/ROM2413|data|36 × 1|36|DERIVED / RECONSTRUCTABLE|every host edge, fixed ROM|none|vmem startup|ROM lookup output; after init not used to mutate state.|
|eg|rslot|5 × 1|5|TEMPORAL SYNTHESIS STATE|CE stage2|0|envelope prefetch|Retain temporal/program history unless a separately proven reconstruction is supplied.|
|eg|memin|25 × 1|25|TEMPORAL SYNTHESIS STATE|CE stage2|none|envelope write|Retain temporal/program history unless a separately proven reconstruction is supplied.|
|eg|memwr|1 × 1|1|TEMPORAL SYNTHESIS STATE|CE stage2/3|0|envelope write|Retain temporal/program history unless a separately proven reconstruction is supplied.|
|eg|aridx|22 × 1|22|DERIVED / RECONSTRUCTABLE|EVERY HOST EDGE from egphase|none|attack lookup|Recomputed from retained egphase on one stationary host edge before the next xena; no temporal advance required.|
|eg|egout|13 × 1|13|TEMPORAL SYNTHESIS STATE|CE stage2|none|operator stage2|Retain temporal/program history unless a separately proven reconstruction is supplied.|
|eg|lastkey (variable)|18 × 1|18|TEMPORAL SYNTHESIS STATE|CE; state/phase load stage0, evolve stage2|0|envelope/noise/AM evolution|Retain temporal/program history unless a separately proven reconstruction is supplied.|
|eg|amphase (variable)|20 × 1|20|TEMPORAL SYNTHESIS STATE|CE; state/phase load stage0, evolve stage2|0x08000|envelope/noise/AM evolution|Retain temporal/program history unless a separately proven reconstruction is supplied.|
|eg|egphase (variable)|23 × 1|23|TEMPORAL SYNTHESIS STATE|CE; state/phase load stage0, evolve stage2|0|envelope/noise/AM evolution|Retain temporal/program history unless a separately proven reconstruction is supplied.|
|eg|egstate (variable)|2 × 1|2|TEMPORAL SYNTHESIS STATE|CE; state/phase load stage0, evolve stage2|Finish|envelope/noise/AM evolution|Retain temporal/program history unless a separately proven reconstruction is supplied.|
|eg|ntable (variable)|18 × 1|18|TEMPORAL SYNTHESIS STATE|CE; state/phase load stage0, evolve stage2|all ones|envelope/noise/AM evolution|Retain temporal/program history unless a separately proven reconstruction is supplied.|
|eg|rm (variable)|5 × 1|5|IRRELEVANT AFTER LOAD|CE stage2 except Finish|0|same stage arithmetic|Finish leaves rm stale but case Finish never applies it; next active state overwrites before use.|
|eg/u_envelope_memory|egdata_set|25 × 18|450|TEMPORAL SYNTHESIS STATE|init then memwr (UNGATED HOST)|startup all ones|rdata -> EG|18*(state2+phase23).|
|eg/u_envelope_memory|rdata|25 × 1|25|DERIVED / RECONSTRUCTABLE|every host edge|none|EG stage0|Refill at stationary rslot with writes suppressed.|
|eg/u_envelope_memory|init_slot (variable)|5 × 1|5|TEMPORAL SYNTHESIS STATE|startup0..18|0|initialization|Source contains no initialization-ready SAVE guard. Conservatively retain initialization position/control for unrestricted early capture; may be excluded only with a proven ready-gated capture contract.|
|eg/u_attack_table|ff_w|8 × 1|8|TEMPORAL SYNTHESIS STATE|EVERY CE, aridx / old lookup latches|none|attack envelope stage2|CE pipeline; blind warm-up can overwrite in-flight history.|
|eg/u_attack_table|ff_d1|7 × 1|7|TEMPORAL SYNTHESIS STATE|EVERY CE, aridx / old lookup latches|none|attack envelope stage2|CE pipeline; blind warm-up can overwrite in-flight history.|
|eg/u_attack_table|ff_d2|7 × 1|7|TEMPORAL SYNTHESIS STATE|EVERY CE, aridx / old lookup latches|none|attack envelope stage2|CE pipeline; blind warm-up can overwrite in-flight history.|
|eg/u_attack_table|data|13 × 1|13|TEMPORAL SYNTHESIS STATE|EVERY CE, aridx / old lookup latches|none|attack envelope stage2|CE pipeline; blind warm-up can overwrite in-flight history.|
|pg|memwr|1 × 1|1|TEMPORAL SYNTHESIS STATE|CE stage0/2/3|0|phase memory|Retain temporal/program history unless a separately proven reconstruction is supplied.|
|pg|memin|18 × 1|18|TEMPORAL SYNTHESIS STATE|CE stage2|none|phase write|Retain temporal/program history unless a separately proven reconstruction is supplied.|
|pg|pmcount|13 × 1|13|TEMPORAL SYNTHESIS STATE|CE stage2 slot0|0|delta phase LFO|Retain temporal/program history unless a separately proven reconstruction is supplied.|
|pg|noise|1 × 1|1|TEMPORAL SYNTHESIS STATE|every CE, noise14 xor noise17|none|rhythm operator|Retain temporal/program history unless a separately proven reconstruction is supplied.|
|pg|pgout|18 × 1|18|TEMPORAL SYNTHESIS STATE|CE stage2|none|operator stage0|Retain temporal/program history unless a separately proven reconstruction is supplied.|
|pg|lastkey (variable)|18 × 1|18|TEMPORAL SYNTHESIS STATE|CE stage2 per selected slot|0|phase key edge / rhythm noise|Retain temporal/program history unless a separately proven reconstruction is supplied.|
|pg|noise14 (variable)|1 × 1|1|TEMPORAL SYNTHESIS STATE|CE stage2 per selected slot|0|phase key edge / rhythm noise|Retain temporal/program history unless a separately proven reconstruction is supplied.|
|pg|noise17 (variable)|1 × 1|1|TEMPORAL SYNTHESIS STATE|CE stage2 per selected slot|0|phase key edge / rhythm noise|Retain temporal/program history unless a separately proven reconstruction is supplied.|
|pg/MEM|phase_array|18 × 18|324|TEMPORAL SYNTHESIS STATE|init then memwr (UNGATED HOST)|startup0|memout -> delta phase|Retain temporal/program history unless a separately proven reconstruction is supplied.|
|pg/MEM|memout|18 × 1|18|DERIVED / RECONSTRUCTABLE|every host edge|none|pg stage2|Stationary port refill possible; staged pending write must settle coherently.|
|pg/MEM|init_slot (variable)|5 × 1|5|TEMPORAL SYNTHESIS STATE|startup0..18|0|initialization|Source contains no initialization-ready SAVE guard. Conservatively retain initialization position/control for unrestricted early capture; may be excluded only with a proven ready-gated capture contract.|
|op|addr|18 × 1|18|TEMPORAL SYNTHESIS STATE|CE stage0|none|sine lookup|Retain temporal/program history unless a separately proven reconstruction is supplied.|
|op|ff_egout|13 × 1|13|TEMPORAL SYNTHESIS STATE|CE stage2|0|operator stage3|Retain temporal/program history unless a separately proven reconstruction is supplied.|
|op|faddr|4 × 1|4|TEMPORAL SYNTHESIS STATE|CE stage2 carrier|none|feedback read|Retain temporal/program history unless a separately proven reconstruction is supplied.|
|op|opout|14 × 1|14|TEMPORAL SYNTHESIS STATE|CE stage3|0|linear lookup|Retain temporal/program history unless a separately proven reconstruction is supplied.|
|op/u_sine_table|ff_data0|11 × 1|11|TEMPORAL SYNTHESIS STATE|EVERY CE from current addr / previous latches|none|operator stage3|Two CE lookup pipeline cannot be flushed with phase frozen without proving delayed wave alignment.|
|op/u_sine_table|ff_data1|11 × 1|11|TEMPORAL SYNTHESIS STATE|EVERY CE from current addr / previous latches|none|operator stage3|Two CE lookup pipeline cannot be flushed with phase frozen without proving delayed wave alignment.|
|op/u_sine_table|ff_sign|1 × 1|1|TEMPORAL SYNTHESIS STATE|EVERY CE from current addr / previous latches|none|operator stage3|Two CE lookup pipeline cannot be flushed with phase frozen without proving delayed wave alignment.|
|op/u_sine_table|ff_wf|1 × 1|1|TEMPORAL SYNTHESIS STATE|EVERY CE from current addr / previous latches|none|operator stage3|Two CE lookup pipeline cannot be flushed with phase frozen without proving delayed wave alignment.|
|op/u_sine_table|ff_weight|9 × 1|9|TEMPORAL SYNTHESIS STATE|EVERY CE from current addr / previous latches|none|operator stage3|Two CE lookup pipeline cannot be flushed with phase frozen without proving delayed wave alignment.|
|op/u_sine_table|ff_data|14 × 1|14|TEMPORAL SYNTHESIS STATE|EVERY CE from current addr / previous latches|none|operator stage3|Two CE lookup pipeline cannot be flushed with phase frozen without proving delayed wave alignment.|
|og|fb_wr|1 × 1|1|TEMPORAL SYNTHESIS STATE|CE stage0/3|0|feedback write|Retain temporal/program history unless a separately proven reconstruction is supplied.|
|og|mo_wr|1 × 1|1|TEMPORAL SYNTHESIS STATE|CE stage0/3|0|output write|Retain temporal/program history unless a separately proven reconstruction is supplied.|
|og|fb_addr|4 × 1|4|TEMPORAL SYNTHESIS STATE|CE stage3 modulator|none|feedback write|Retain temporal/program history unless a separately proven reconstruction is supplied.|
|og|mo_addr|5 × 1|5|TEMPORAL SYNTHESIS STATE|every CE|none|output read/write|Retain temporal/program history unless a separately proven reconstruction is supplied.|
|og|fb_wdata|10 × 1|10|TEMPORAL SYNTHESIS STATE|CE stage3 modulator|none|feedback write|Retain temporal/program history unless a separately proven reconstruction is supplied.|
|og|mo_wdata|10 × 1|10|TEMPORAL SYNTHESIS STATE|CE stage3|none|output write|Retain temporal/program history unless a separately proven reconstruction is supplied.|
|og/Ltbl|ff_sign|1 × 1|1|DERIVED / RECONSTRUCTABLE|every host edge, opout/previous latches|none|og stage3|Two host-edge recomputation from restored stable opout; gate downstream writes until refill.|
|og/Ltbl|ff_weight|6 × 1|6|DERIVED / RECONSTRUCTABLE|every host edge, opout/previous latches|none|og stage3|Two host-edge recomputation from restored stable opout; gate downstream writes until refill.|
|og/Ltbl|ff_data0|9 × 1|9|DERIVED / RECONSTRUCTABLE|every host edge, opout/previous latches|none|og stage3|Two host-edge recomputation from restored stable opout; gate downstream writes until refill.|
|og/Ltbl|ff_data1|9 × 1|9|DERIVED / RECONSTRUCTABLE|every host edge, opout/previous latches|none|og stage3|Two host-edge recomputation from restored stable opout; gate downstream writes until refill.|
|og/Ltbl|data|10 × 1|10|DERIVED / RECONSTRUCTABLE|every host edge, opout/previous latches|none|og stage3|Two host-edge recomputation from restored stable opout; gate downstream writes until refill.|
|og/Fmem|data_array|10 × 9|90|TEMPORAL SYNTHESIS STATE|init then fb_wr (UNGATED HOST)|startup0|operator modulation|Retain temporal/program history unless a separately proven reconstruction is supplied.|
|og/Fmem|rdata|10 × 1|10|DERIVED / RECONSTRUCTABLE|every host edge|none|operator stage0|Refill stable faddr.|
|og/Fmem|init_ch (variable)|4 × 1|4|TEMPORAL SYNTHESIS STATE|startup0..9|0|initialization|Source contains no initialization-ready SAVE guard. Conservatively retain initialization position/control for unrestricted early capture; may be excluded only with a proven ready-gated capture contract.|
|og/Mmem|data_array entries0..17|10 × 18|180|TEMPORAL SYNTHESIS STATE|init then mo_wr (UNGATED HOST)|startup0|feedback average and temporal sum|Retain temporal/program history unless a separately proven reconstruction is supplied.|
|og/Mmem|data_array entry18|10 × 1|10|IRRELEVANT AFTER LOAD|unreachable legal slot18|uninitialized|none|Declared extra entry not initialized or addressed by legal counters.|
|og/Mmem|rdata|10 × 1|10|DERIVED / RECONSTRUCTABLE|every host edge|none|feedback average / temporal mixer|Refill stable read address with writes suppressed.|
|og/Mmem|rdata2|10 × 1|10|DERIVED / RECONSTRUCTABLE|every host edge|none|feedback average / temporal mixer|Refill stable read address with writes suppressed.|
|og/Mmem|init_ch (variable)|5 × 1|5|TEMPORAL SYNTHESIS STATE|startup0..18|0|initialization|Source contains no initialization-ready SAVE guard. Conservatively retain initialization position/control for unrestricted early capture; may be excluded only with a proven ready-gated capture contract.|
|tm|mute|1 × 1|1|TEMPORAL SYNTHESIS STATE|CE stage0|1|next output / sum|Retain temporal/program history unless a separately proven reconstruction is supplied.|
|tm|maddr|5 × 1|5|TEMPORAL SYNTHESIS STATE|CE stage0|0|next output / sum|Retain temporal/program history unless a separately proven reconstruction is supplied.|
|tm|mix|14 × 1|14|TEMPORAL SYNTHESIS STATE|CE stage2|0|next output / sum|Retain temporal/program history unless a separately proven reconstruction is supplied.|
|tm|mixout|14 × 1|14|TEMPORAL SYNTHESIS STATE|CE stage2 slot17|0|next output / sum|Retain temporal/program history unless a separately proven reconstruction is supplied.|
|ct|kflag (scratch variable)|1 × 1|0|OVERWRITTEN BEFORE OBSERVATION|assigned before every effective read|not applicable|same activation|No inter-activation dependence; combinational temporary.|
|ct|tll (scratch variable)|8 × 1|0|OVERWRITTEN BEFORE OBSERVATION|assigned before every effective read|not applicable|same activation|No inter-activation dependence; combinational temporary.|
|ct|kll (scratch variable)|8 × 1|0|OVERWRITTEN BEFORE OBSERVATION|assigned before every effective read|not applicable|same activation|No inter-activation dependence; combinational temporary.|
|ct|regs_tmp (scratch variable)|24 × 1|0|OVERWRITTEN BEFORE OBSERVATION|assigned before every effective read|not applicable|same activation|No inter-activation dependence; combinational temporary.|
|ct|user_voice_tmp (scratch variable)|36 × 1|0|OVERWRITTEN BEFORE OBSERVATION|assigned before every effective read|not applicable|same activation|No inter-activation dependence; combinational temporary.|
|ct|fb_buf (scratch variable)|3 × 1|0|OVERWRITTEN BEFORE OBSERVATION|assigned before every effective read|not applicable|same activation|No inter-activation dependence; combinational temporary.|
|ct|wf_buf (scratch variable)|1 × 1|0|OVERWRITTEN BEFORE OBSERVATION|assigned before every effective read|not applicable|same activation|No inter-activation dependence; combinational temporary.|
|pg|dphase (scratch variable)|18 × 1|0|OVERWRITTEN BEFORE OBSERVATION|assigned before every effective read|not applicable|same activation|No inter-activation dependence; combinational temporary.|
|pg|pgout_buf (scratch variable)|18 × 1|0|OVERWRITTEN BEFORE OBSERVATION|assigned before every effective read|not applicable|same activation|No inter-activation dependence; combinational temporary.|
|eg|egtmp (scratch variable)|15 × 1|0|OVERWRITTEN BEFORE OBSERVATION|assigned before every effective read|not applicable|same activation|No inter-activation dependence; combinational temporary.|
|eg|dphase (scratch variable)|23 × 1|0|OVERWRITTEN BEFORE OBSERVATION|assigned before every effective read|not applicable|same activation|No inter-activation dependence; combinational temporary.|
|op|opout_buf (scratch variable)|14 × 1|0|OVERWRITTEN BEFORE OBSERVATION|assigned before every effective read|not applicable|same activation|No inter-activation dependence; combinational temporary.|
|og/AVERAGE|vL (scratch variable)|11 × 1|0|OVERWRITTEN BEFORE OBSERVATION|assigned before every effective read|not applicable|same activation|No inter-activation dependence; combinational temporary.|
|og/AVERAGE|vR (scratch variable)|11 × 1|0|OVERWRITTEN BEFORE OBSERVATION|assigned before every effective read|not applicable|same activation|No inter-activation dependence; combinational temporary.|

Immutable lookup constants (not sequential): voice ROM base/VRC7 38×36 each; attack128×7; sine128×11; linear128×9; controller KL16×6; PG multiplier16×5 and noise tables64+8. Combinational multiplier helper entities contain no sequential state. Unused opll state2/state5/state8 and LinearTable.w_data are not storage. ROM output registers themselves are included above.
