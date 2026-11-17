# Current non-FM audio state cone

Production baseline: f205b05dc058fc5f7f2432779b61e8f3b0e22519, v15.
Sites below refer to unchanged production files. `ce_snd` has no driver or
consumer, so it is not an audio sampling clock. Audio is continuously visible
at the core ports, independently of ce_cpu.

| Element | Width / assignment sites | Enable/reset | Freeze, LOAD, preparation | First update / observation | Classification |
|---|---|---|---|---|---|
| Each JT89 configuration | 52 meaningful bits, jt89.v configuration always block; tone0/1/2, vol0..3, ctrl3, regn | reset; ss_set/ss_ext_set; rising wr_n edge detector | Restored; guest writes held by production CPU bus | Configuration affects oscillator/volume/mux consumers | SERIALIZED |
| Each JT89 divider | 4, jt89.v clk_div block | reset0; ss_ext_set; clk_en | Holds without guest enable; restored from common divider field | Next enabled increment | SERIALIZED, FROZEN |
| Each tone state | 10-bit cnt + 1-bit out, jt89_tone.v | reset; ss_set; cen_16 | Holds and restores | Next cen_16 | SERIALIZED, FROZEN |
| Noise state | 11-bit cnt + 16-bit shift, jt89_noise.v | reset; ss_set; cen_16, clr | Holds; restores; clr drains | Next cen_16 or control write | SERIALIZED, FROZEN |
| Four channel signed samples per PSG | 4 x 9, jt89_vol.v snd block | reset0; ss_set; cen_16 | Holds and restores; attenuation lookup max is combinational | Following host-clock PSG mixer | SERIALIZED, FROZEN |
| JT89 cen_16 | 1, jt89.v negedge block | reset1; otherwise !ss_ext_set && clk_en && (&clk_div) | Recomputed with gated clk_en; not literal saved bit | Following posedge oscillator/volume consumers | COMBINATIONAL/DERIVED through a register; capture-edge ordering must be checked |
| JT89 last_wr / clr_noise | 1 + 1, jt89.v configuration block | tracks wr_n / clears after pulse; ext restore sets 1/0 | Drained before late audio capture; ext restore normalizes | Next host edge / noise reset consumer | OVERWRITTEN BEFORE OBSERVATION at quiescent capture; uses established raw-PSG contract |
| PSG1/2 soundL, soundR | 2 x 11 per device, jt89_mixer.v always @(posedge clk) | Every host clock; no reset | Continues during freeze/LOAD/preparation; no literal restore | First host edge after restored channel snd/mux, then core mixer on next edge | POTENTIALLY HISTORICAL at release; steady reconstructable |
| PSG mux + FM detect/control det_D | 8 + 3, system.vhd audio_control_out; IO registers | Guest IO/reset; audio_ext_set restores | Current v15 word00e audio control | Combinational PSG routing and FM isolation | SERIALIZED |
| Mix inputs, signed extensions, sum, overflow, clipped | 13-bit system buses, 16/17-bit AudioMix cone | Combinational | Immediately reflects restored/routed PSG outputs | Selected channel at next host edge | COMBINATIONAL/DERIVED |
| AudioMix toggle | 1, AudioMix.vhd process(clk) | Every host clock; phase_set selects saved phase; no reset | Keeps toggling while frozen; LOAD phase_set on first resumed clock; SAVE does not set it | Chooses which channel updates on every host edge | SERIALIZED (late capture), but release relationship requires proof |
| AudioMix audio_l / audio_r | 16 each, AudioMix.vhd process(clk) | Alternating host edges; no reset | Keeps updating while frozen; no literal LOAD; same behavior during CPU preparation | One selected output on each host edge; both core ports continuously observable | POTENTIALLY HISTORICAL at release; steady reconstructable in two clocks |
| system audioL/audioR; SMS audio_l/audio_r; AUDIO_L/AUDIO_R | 16 each | Direct aliases/wires, SMS.sv 1621..1624 | No mute, freeze gate, sample enable or extra register | Immediate continuous observation | COMBINATIONAL/DERIVED |
| AUDIO_S, AUDIO_MIX | constants1 | SMS.sv 691..692 | Unchanged | MiSTer host interface | COMBINATIONAL/DERIVED, signed samples |
| FM input | Excluded synthesis state | FM disabled (zero FM_gated), second mix input zero in primary proof | No FM correctness oracle | None in proof | F01 / G08.FM remains OPEN - BLOCKED BY F01 |

JT89 exports 56 configuration bits but only 52 are meaningful; ext96 plus div4
gives 152 meaningful oscillator/config/sample bits per PSG (156 port-vector
bits including four leading configuration zeros). PSG2 has an independent
record; production asserts equal dividers for quiescent System E capture.
Unused declarations (`last_out`, noise `v`/`update`) have no assigned consumed
storage and are not additional history.

Production scaling is `(sign & PSG11 & '0') & "000"`, equivalent to signed
PSG11 multiplied by16. The mixer adds sign-extended inputs and saturates
overflow to 0x7fff/0x8000. AUDIO_S=1 declares signed output; there is no
unsigned conversion/filter inside the core before AUDIO_L/R.

Outside the core boundary, sys/sys_top.v routes these ports to audio_out.sv
on independent clk_audio. That host path has stable-input sampling cl1/cl2/cl
and cr1/cr2/cr (16 each), rate/divider state, startup enables, IIR delay state,
DC blockers, volume/boost/crossfeed/ALSA pipelines, I2S/SPDIF and DAC state.
Signed conversion is {~is_signed ^ cl[15],cl[14:0]}; with AUDIO_S=1 it is the
identity. The DAC later flips the sign bit for offset-binary conversion.
These stages are downstream of the requested final *core* outputs and are
not rewound or paused by ss_freeze. Their wall-clock/filter/physical-output
history is not a core logical-time savestate oracle. No claim of physical
speaker waveform rewind is made. A difference at AUDIO_L/R cannot be dismissed
by assuming the independently clocked host sampler never sees it.
