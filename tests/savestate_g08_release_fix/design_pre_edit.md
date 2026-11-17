# G08.release design, before production edits

Baseline f205b05, v15. Production remains unchanged until sufficiency.json
passes. The baseline and phase-only prototype compile directly against unchanged
AudioMix/JT89. No FM/OPLL, PSG synthesis or G10 divider change is proposed.

The first divergent sequential state is AudioMix.toggle on the first resumed
LOAD clock (or odd-duration SAVE transport). The later opposite stereo pairs
are its consumers. All inputs/sums/clipping in AudioMix are combinational;
there is no registered accumulator or partial sum. audio_l/r hold one value
each, updated on the selected alternating host edge.

| State | Width / sites | Update, reset, freeze, LOAD, first consumer | Classification |
|---|---|---|---|
| toggle | 1, AudioMix.vhd signal/process | Every rising edge; no reset; runs through freeze; phase_set overrides selection/next phase at first resume; next channel latch consumes it | MUST SERIALIZE correct next-update phase OR prove a phase reconstruction invariant |
| audio_l/r | 16 each, same process | Alternating rising edges; no reset/freeze/literal LOAD; continuously visible at core ports; restored stable inputs refill before release | OVERWRITTEN BEFORE OBSERVATION under accepted-boundary ordering proved below |
| phase/in1/in2/sum/overflow/clipped | 1/17/17/17/1/17 | Combinational; no retained partial accumulation | RECONSTRUCTABLE |
| PSG soundL/R per chip | 11 each, jt89_mixer.v | Every host rising edge; reconstruct from restored historical channel samples/mux, before AudioMix refill | OVERWRITTEN BEFORE OBSERVATION |
| ce_snd | Unused declaration SMS.sv | No driver or consumer | IRRELEVANT |
| cfg/ext/div/control | Existing payload | Preserve raw PSG semantics; current phase/beam commit and private CPU replay untouched | Existing SERIALIZED/FROZEN state, outside proposed change |

LOAD currently captures toggle at ST_FREEZE after drain, then interprets it as
the channel selection at logical T+1. Those are different clocks. SAVE-only
does not install any phase: every wall-clock transport edge flips toggle, so
transport parity chooses the next channel. The causes share a missing
boundary-relative phase handoff, but have different causal paths: LOAD uses
the wrong saved phase; SAVE uses the live transport phase.

| Family | SAVE / LOAD | Historical bits / format | First samples, stereo/System E/Pause and expected cost |
|---|---|---|---|
| A freeze whole mixer | SAVE holds phase; LOAD still needs historical phase and refill | Freezing alone insufficient for LOAD; snapshot output buses would add32 bits | Holding Q output through LOAD can leak it. Additional refill stage/gates or output serialization needed; avoid |
| B boundary phase + release installation | Both, if capture/first-selection semantics exact | One historical bit; already allocated in descriptor020. v16 identifies corrected meaning | Existing stable-input refill reconstructs both channels. One shared phase applies stereo/dual PSG; current Pause/guest enables unchanged. No new data storage/adder |
| C phase + accumulator | Both if sufficient | One phase plus unnecessary accumulator bits | No registered accumulator exists. Extra state/muxes have no consumer justification |
| D arbitrary canonical phase | Neither universally | Zero history bits | Two valid next-channel phases can give opposite transient pairs under identical future input. clk_sys toggle is not reset by guest reset/old LOAD; clkd parity alone cannot prove its value after valid historical operations |
| E freeze sequence + bit | Both with refill protocol | One phase plus added control/fanout | Correct in principle, but freezes existing reconstruction and requires refill stage. More intrusive than B with no smaller historical representation |

Chosen candidate: B. At ARM (before the following host edge advances mixer),
record post-T toggle, the channel selection required for T+1. Keep the existing
late PSG capture and all synthesis state unchanged. Install that phase on the
first resumed clock on BOTH SAVE and LOAD. AudioMix already uses phase_set
for that clock's selection and next toggle, so it needs no RTL change.

Sufficiency argument to corroborate dynamically: JT89 volume samples update
only on the negedge-derived cen_16; with the production divider, their native
host positions are11/26. PSG stereo sums latch on the next edge; both AudioMix
outputs have latched the new sums by positions14/29. Accepted T classes are
0/10/20/25. Thus no ordinary pending PSG sample-to-mixer update straddles T.
Guest writes and GG panning must finish before the next accepted M1/T2;
the minimum CPU enable interval is10 host clocks, exceeding this pipeline.
The real CPU OUT/pan fixture challenges this consumer bound. Paused qualifying
capture has held inputs; non-M1 capture seeking uses the already authorized
coherent enables until T. Future controls remain identical logical inputs.

At T both cached outputs therefore equal the signed/clipped current source
pair. LOAD restores source history and controls long before release; the
existing drain/flush/settlement provides at least three host clocks for PSG
sum plus both AudioMix channel latches. There is no stale Q cache at release.
Once source pair and next-channel phase equal reference at T+, all subsequent
deterministic pipeline transitions/output values equal under identical future
inputs. This induction covers partial stereo updates AFTER release without
saving output caches. The proof does not claim arbitrary forced mid-clock
images, FM exactness, physical speaker/filter rewind or missing legacy history.

Pre-edit experiments must reproduce both original failures and all six LOADs,
pass both original cases under the one-bit prototype, and exercise natural
distinct earlier audio histories plus real CPU PSG/panning writes. Full-image
comparison is separate from local phase induction; absence of a random collision
alone is not sufficiency proof.

Format decision: introduce v16 header tag484310 because the historical phase
has a corrected temporal meaning. Reuse word020 bit45, with unchanged descriptor
schema, payload lengths and existing v15 BG/v14 sprite records. No extra word,
snapshot register, accumulator, output cache, RAM or DSP is required. v15 and
older cannot promise that historical next-update phase; normalize it to0 on
LOAD. Keep supported raw PSG/CPU/VDP legacy policies. Validate v16 requires its
audio extension before guest writes. SAVE-only always restores its own correct
ARM phase. No final development-format consolidation.

Expected production scope: rtl/savestates.sv only. Correct capture/release plus
v16 tag inheritance and deterministic legacy phase normalization. Reuse the
existing phase register, no added historical state bits or broad datapath. Full
controlled Quartus must assess actual placement/timing; no cost claim is made
before measurement, given v15's92.384% placement.
