# Fitter cost attribution (before experimental RTL edits)

Original matched evidence is read-only. Full reference is 8cd53ccc; pre-FM is 66f16d5c. Values below are measured seed-1 fitted hierarchy attributions, not predictions of removable logic. Quartus reports fractional shared ALMs. Inclusive totals contain all descendants; exclusive values in parentheses belong to that entity only. Do not sum a parent with its children. Whole-chip packing prevents summing fractional hierarchy deltas into an exact chip delta.

| Entity | Full inclusive needed ALMs | Pre-FM inclusive | Delta inclusive | Full exclusive | Delta exclusive | Fitted register delta inclusive |
|---|---:|---:|---:|---:|---:|---:|
| savestates:savestates_inst | 4219.5 | 3933.3 | 286.2 | 4067.6 | 134.3 | 189 |
| savestates:savestates_inst / opll_snapshot:fm_snapshot | 152 | 0 | 152 | 152 | 152 | 167 |
| savestates:savestates_inst / opll_snapshot:fm_snapshot / altsyncram:memory_rtl_0 | 0 | 0 | 0 | 0 | 0 | 0 |
| savestates:savestates_inst / opll_snapshot:fm_snapshot / altsyncram:memory_rtl_0 / altsyncram_p3p1:auto_generated | 0 | 0 | 0 | 0 | 0 | 0 |
| system:system / opll:fm | 1515.1 | 1024.3 | 490.8 | 28.3 | 24.1 | 166 |
| system:system / opll:fm / Operator:op | 187.7 | 130.3 | 57.4 | 88.3 | 35.6 | 64 |
| system:system / opll:fm / Operator:op / SineTable:u_sine_table | 99.2 | 77.7 | 21.5 | 99.2 | 21.5 | 33 |
| system:system / opll:fm / OutputGenerator:og | 210.6 | 278.3 | -67.7 | 48.9 | 15 | -179 |
| system:system / opll:fm / OutputGenerator:og / FeedbackMemory:Fmem | 57.5 | 48.7 | 8.8 | 57.5 | 8.8 | -1 |
| system:system / opll:fm / OutputGenerator:og / LinearTable:Ltbl | 63.1 | 59.7 | 3.4 | 63.1 | 3.4 | 0 |
| system:system / opll:fm / OutputGenerator:og / OutputMemory:Mmem | 41.1 | 136 | -94.9 | 21.1 | -114.9 | -209 |
| system:system / opll:fm / PhaseGenerator:pg | 174.8 | 101.5 | 73.3 | 151.1 | 64.1 | 43 |
| system:system / opll:fm / PhaseGenerator:pg / PhaseMemory:MEM | 23.8 | 14.5 | 9.3 | 23.8 | 9.3 | 1 |
| system:system / opll:fm / SlotCounter:s0 | 13.2 | 6.3 | 6.9 | 13.2 | 6.9 | 10 |
| system:system / opll:fm / SlotCounter:s2 | 14.3 | 6 | 8.3 | 14.3 | 8.3 | 0 |
| system:system / opll:fm / SlotCounter:s5 | 20.8 | 5.7 | 15.1 | 20.8 | 15.1 | -2 |
| system:system / opll:fm / SlotCounter:s8 | 11.1 | 8.3 | 2.8 | 11.1 | 2.8 | -1 |
| system:system / opll:fm / TemporalMixer:tm | 26.2 | 27.4 | -1.2 | 26.2 | -1.2 | -3 |
| system:system / opll:fm / controller:ct | 415.2 | 247 | 168.2 | 222.6 | 120.3 | 84 |
| system:system / opll:fm / controller:ct / RegisterMemory:u_register_memory | 104.5 | 88.8 | 15.7 | 104.5 | 15.7 | 2 |
| system:system / opll:fm / controller:ct / VoiceMemory:vmem | 88.1 | 55.8 | 32.3 | 60.3 | 34.1 | 36 |
| system:system / opll:fm / envelopegenerator:eg | 412.7 | 209.2 | 203.5 | 321 | 176.6 | 129 |
| system:system / opll:fm / envelopegenerator:eg / AttackTable:u_attack_table | 62.5 | 46.1 | 16.4 | 62.5 | 16.4 | 35 |
| system:system / opll:fm / envelopegenerator:eg / EnvelopeMemory:u_envelope_memory | 29.1 | 17 | 12.1 | 29.1 | 12.1 | 3 |

## Ranked targets

1. OPLL scalar state access collectively: OPLL +490.8 inclusive ALMs. Envelope +203.5 inclusive (+176.6 exclusive), controller +168.2 inclusive (+120.3 exclusive). These are mixed functional/access logic attribution differences, not a direct isolated measurement of serializer cost. Added read-response registers, write selection and freeze enables are visible in RTL. Combining read-response registers might save logic, but process-local variables, synchronous RAM readback and exact latency make a cross-module rewrite substantial. Estimated opportunity only; no number of removable ALMs claimed.
2. Savestate hierarchy +286.2 inclusive. Snapshot child 152.0 ALMs / 167 fitted registers / one M10K; own savestates delta +134.3 ALMs / 22 registers. The parent owns FM validation, DDR/control state and format handling, but hierarchy cannot separate those individual FM portions from optimization/packing changes in unrelated logic. Do not label all 4067.6 exclusive parent ALMs as FM.
3. Slotcounter restore: four counters add about 33.1 needed ALMs in aggregate. Delay-5 grows 5.7 to20.8. Source computes one of two constant-offset expressions from an 8-bit bus narrowed to seven bits. An explicit constant-select then one 7-bit addition preserves every restore value and is a small reviewable experiment. Actual savings unknown until fitting.
4. Snapshot paired-word address uses index+1 in high-half states even though index is always even there. Replacing that increment with concatenation is cycle-exact for reachable states, potentially reducing a carry chain. Opportunity is small and synthesis may already optimize it.
5. Buffer reset and capture staging: removing resets from private data buffers may reduce control fanout but is not presumed to save ALMs. Moving a low-word write earlier to remove staging can change interrupted/reset behavior, so it is rejected before implementation.

Negative deltas in output-history storage reflect changed inference and mapping, not negative access cost. Phase, feedback and envelope RAM access deltas are included above at leaf granularity. Existing phase/envelope/custom-voice RAMs still account for four OPLL M10Ks; the added transport is a distinct fifth FM-associated M10K. Reducing RTL text or arithmetic expression count alone proves no resource benefit.

No lossy omission is considered. The reference already omits temporal mixer state. The preceding 43 reduction pilots cover only ~0.336 ms and qualify no new omission.

## Attribution boundary and RTL paths

The whole-device seed-1 increment is 881 needed ALMs. The disjoint OPLL and savestate inclusive deltas sum to 777.0; the remaining 104.0 is spread across enclosing wrapper/system logic and changed packing/optimization elsewhere. It is not a measured block of removable FM logic. The system entity's own attribution grows 322.7 ->352.2 ALMs (+29.5), with nine added registers matching the restored wrapper bus; emu's own attribution grows 487.2 ->499.1 (+11.9), despite its register count falling. These numbers illustrate why inclusive hierarchy subtraction alone cannot assign every LUT to one source-level feature.

| Source path | Added access structure | Attribution limit |
|---|---|---|
| rtl/opll_snapshot.sv | 256x32 synchronous transport RAM, 64-bit incoming staging, 64-bit bulk output, state/index/refill control, legacy default selection | Snapshot is separately measured: 152 ALMs,167 fitted registers,1 M10K in seed1 |
| rtl/savestates.sv | Descriptor/tag/word checks,100-word validation masks, DDR save/load states, snapshot handshake | Parent exclusive delta +134.3 ALMs; individual validator/DDR/FM-control portions are not separately measured |
| rtl/VM2413/opll.vhd | Local CPU-write state, wired OR of child responses, ready reduction, distributed bus | Parent exclusive delta +24.1 ALMs; not the cost of all child decoders |
| rtl/VM2413/controller.vhd | Cache and decoded-parameter packing, partial-word custom voice writes, register/voice pending state, freeze gates | Controller own delta +120.3; child RegisterMemory +15.7 and VoiceMemory inclusive +32.3 are already inside controller total |
| rtl/VM2413/envelopegenerator.vhd | Working envelope, key history, AM/noise state,writeback and registered read selection | Own delta +176.6, child AttackTable +16.4, EnvelopeMemory +12.1; shared-ALM attribution and rounding mean these entries need not sum exactly |
| rtl/VM2413/phasegenerator.vhd | Phase writeback,key/noise and PM state, freeze/read/write selection | Own delta +64.1; child PhaseMemory +9.3 is included in +73.3 total |
| rtl/VM2413/feedbackmemory.vhd | Additional state-access address/data/write selection | +8.8 ALMs inclusive; actual feedback RAM remains part of the functional synthesizer |
| rtl/VM2413/slotcounter.vhd | Shared word78 readout and delayed-count reconstruction | Four independent instantiations; +33.1 ALMs aggregate in seed1 is the selected trial target |

Repeated VHDL packing temporaries are not assumed to be registers. A temporary assigned before use may optimize to wires; a text simplification of those assignments may have zero physical benefit. Likewise, common decoder expressions may already be shared by Quartus. Registered response consolidation is a plausible larger strategy but must preserve pre-write read semantics, process-variable timing and synchronous RAM latency; moving a register indiscriminately would change the access protocol.

