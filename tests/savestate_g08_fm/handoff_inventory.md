# FM handoff inventory before any production change

Baseline: F06 commit 854761c3d4ab3f6d5c5d0dda00b4682c1523c443, v18.
F01 is 7fcd5e1; G08.release is 08cf142. Their established contracts remain closed.
The only intervening production edit is F06's controller version/full-SRAM logic.

|Element|Normal edge/event|SAVE / transport|LOAD / restore|Release / first consumer|
|---|---|---|---|---|
|OPLL base counter, slot/stage and full synthesis state|Host rising edge with `xena=system.ce_cpu`; FM CE is /15 even with /10 guest CPU|Accepted T executes; `ss_hold` inhibits ordinary temporal writes from T+1|104 rows restored, then eight stationary cache-refill clocks|Historical counter and state execute on first native FM CE|
|OPLL TemporalMixer partial sum, address, mute|Accumulate at stage2; slot17 stage2 publishes sum and clears accumulator|Frozen; saved in row101|Restored in row101|Existing F01 transition contract|
|OPLL mixout, 14 bits|Publishes at pre-edge base counter70 with active xena; holds between events|Post-T value frozen and saved in row102|Restored before local completion|Already-valid retained sample; next update event is counter-derived|
|FM-valid/update|No separate stored valid bit or external valid output; derived publication event above|No event while held|No guest update during private restore/refill|First event must equal reference; a nonzero value is not a valid-event definition|
|system.fm_a/d, 9 bits|Unfrozen F0/F1 host-edge write latch|Frozen; row76|Restored through same local word|Consumed by OPLL on native CE; no register-program replay|
|FM_gated, 13 bits|Combinational production sign clamp and enable/decode|Tracks frozen restored raw sample|Tracks intermediate install privately|Stable restored input to AudioMix before release|
|mix2_inL/R and left shift by3|Combinational; System E selects PSG2 instead of FM|Continue combinational evaluation|Same|No independent FM input register|
|AudioMix in1/in2/sum/overflow/clipped|Combinational signed sum and existing overflow selection|Continue|Continue|Sampled by selected output register on each host edge|
|AudioMix.toggle, 1 bit|Alternates each host edge|Post-T next phase is captured; live toggle continues during transport|Saved phase loaded into controller|`ss_phase_set` overrides selection on first resumed edge, then ordinary alternation|
|AudioMix.audio_l/r, 16 bits each|One selected cache updates each host rising edge|Continue running and refill from held source|Reconstructed from restored source during stationary interval|Selected half updates at T+1; other half retains its pre-release cache|
|system.audioL/R and SMS.AUDIO_L/R|Direct wires from AudioMix|No further register|No further register|Core-port observation point; host filtering/DAC histories are outside this proof|

Coherent comparison: T is the actual accepted rising edge. Reference k0 is
T+1; replay k0 is the first rising edge after freeze falls and the release
phase has been installed. No settling samples, channel values or valid events
may be skipped. Transport and private preparation are omitted from logical
time, but their effects on the first core-visible pair remain observable.

Boundary hypothesis to test, not yet a confirmed defect: on an FM publication
at T, AudioMix consumes the old raw FM value while OPLL installs the new raw
sample. Post-T reconstruction can make both caches contain the new sample
before T+1. The unselected channel at T+1 may consequently differ from the
uninterrupted cache written at T. The directed counter70 capture tests this
without forcing any historical state or modifying production RTL.
