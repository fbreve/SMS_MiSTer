# G05 design before any production edit

Baseline58583189b5c650dc6658ef467e8dcb72d9f6e6c2, v14. This is a **proposal pending prototype gates**, not a completed sufficiency result. The original controller and all production files remain unchanged while these tests run. The final report must name any revision to this proposal.

## Information loss and first causal consumer

The original real-CPU pair changes past R9 while Mode4 renders, enters text near row190, restores identical current R9, and captures at post-T x124/y192. Ordinary plane and shifter registers hold in text. A later single R0 write selects Mode4 atx24/y0. The currently selected shifter bit7 immediately drives bg_color; registered CRAM sampling then supplies the differing visible RGB. At the first pixel clock, ordinary xphase7 simultaneously reloads shifters from cached data, so a post-edge probe already shows the new planes. **That does not make the data bytes the first causal source:** the sampled CRAM RGB still reflects the pre-reload shifter selection. Additional baseline read-only probes record registered VRAM address, priority, CE, the complete declared pipeline and pixels. A prototype omission control retains all other proposed fields while clearing shifters, and another clears cached data while retaining shifters, to separate the first-pixel and subsequent-pixel causes.

Fresh trace: immediately before the switch, history0 shifters002fd0ff select color nibbleC with palette1, hence CRAM1C=46F. History1 shiftersA04F701F select nibble1 with palette1, hence CRAM11=126. Those are exactly the first divergent RGB values atx25. After that pixel edge, shifters have reloaded4065BAA7 versusF4092EA7; the latter selects CRAM19=B8E for the next pixelx26. The fourth Mode4 plane comes from current VRAM A7; it is not the old data3 byte. This explains both the old-history path and why looking only at the first post-edge differing register would misidentify the first cause.

The equal complete v14 image/different future already proves no function of existing architectural registers, VRAM, CRAM, beam, scroll and canonical restart can recover both required histories. Hidden refetch from the same image cannot select between them. A fixed delay would discard guest-visible original pixels rather than reproduce them.

## Why active text/phase/address cannot simply be excluded

The production video VBlank is **registered**, cleared only when vcount equals the mode-dependent vbl_end. In GG224, it stays high through rows0..39. A real CPU transition to text at row29 changes vbl_end to24 after that row has passed. The accepted predicate can consequently still see VBlank high at row30 while the text mixer considers row30 visible. This is being tested with an actual CPU, not an injected VBlank or beam. The G07 x<=256 exclusion and G02–G04 CPU drain bounds are unaffected.

Thus a blanket “all captured text data is invisible until bootstrap” argument is invalid. Likewise a height/viewport change may expose an ordinary pipeline before a new horizontal reset. Current mode and scroll do not encode the mode/scroll at previous fetch/latch edges. Retain historical ordinary counter, metadata, cached data, current shifters, registered address, and active text state unless a specific consumer argument removes a field.

## Proposed representation

The full declared historical background cone is142 bits: the127-bit prior audit vector, fourteen registered address bits and one registered priority output. The proposal is **139 bits per VDP**, with no memory, mode/register duplication, sprite state or RAM read-Q payload:

- Remove text_pattern[1:0]. Every consumer uses only text_pattern[7:2]; those two bits have no address/control/priority/color fanout. Restore them deterministically zero.
- Encode text_column*6+text_phase in8 bits rather than separate6+3 bits. Naturally reachable text_phase is0..5 and column0..39. Both start/reset0; at most239 advances occur within x8..246 before outside-window or line/nontext reset. Thus position0..239 is bijective, decoded by /6 and mod6. Positions240..255 must reject before guest-state writes.
- Retain the other historical fields literally, listed with exact ranges in proposed_fields.json. This includes background VRAM address and registered priority, which are easy to miss if only the old127-bit probe is considered.

This is field/consumer minimality under arbitrary supported guest mode/register writes, not a claim to solve global information-theoretic compression of all renderer reachable states. A conditional renderer-history codec would require a separate equivalence proof and more restore logic; it cannot omit the ordinary/text histories merely because one is currently inactive. No unconsumed process variable or combinational mode/color/row alias is serialized.

## Sufficiency argument to validate before production change

At post-T capture, store the139-bit projection. Restore each retained storage element exactly, and restore the semantic text counter bijectively. Only two raw dead bits differ; no transition or output consumes them. The registered VRAM address is installed while guest CEs stay held; ordinary host-clock RAM read Q refills from the restored address during existing settlement/phase commit, before the first VDP/pixel consumer. CRAM read Q similarly refills from restored architecture/palette/beam, before the first pixel. The original sprite/CPU preparation and divider/beam commit remain untouched.

Consequently, after RAM setup, equal retained state and equal future inputs give equal next retained state, fetch address, priority and pixel for every implemented ordinary/text/mixed mode. Induction covers later lines/frames and mode transitions. A testbench side record must first reproduce both original histories exactly, a component transition miter must challenge changed modes/tables/scroll/VRAM and different Q histories, and natural additional searches must challenge dead-bit omission and active text capture. Unknown equality is not accepted. No prototype side record is claimed to be present in v14.

## Four solution families

| Family | Correctness / bits / format / interfaces / latency / modes / System E / resources / proof |
|---|---|
|A: minimal live history|Proposed139 historical bits/device; v15 tagged extension; through background/main/VDP/system/top/controller. Existing restore strobe, no guest latency; two independent records. Adds278 snapshot bits plus restore/control logic. Requires field sufficiency, packing, malformed/legacy and exact future proof.|
|B: hidden refetch/reconstruction|Zero new bits cannot recover the confirmed pair. A sufficiently detailed earlier-render replay would itself require lost mode/VRAM/input history, mode-specific scheduling and memory arbitration. Potentially large latency/logic and dual-device coordination. Rejected without such a deterministic source.|
|C: strengthen boundary|Current text history can remain inactive indefinitely, so choosing another x/blank row alone does not canonicalize it. Waiting for a guest mode change is unbounded; forcing one changes guest time/video. Zero payload only with a changed, substantially narrower save contract and liveness proof; not selected.|
|D: metadata plus refetch|Fetched bytes can predate current VRAM or mode/scroll, and shifters can retain another mode indefinitely. Metadata alone does not select the lost byte history. Encoding enough past renderer/memory events is more complex than retaining live bytes; no smaller sufficient hybrid established.|

## Provisional format and transport design

If gates pass, introduce v15 tag48430f, retaining v14 sprite descriptor/layout and deterministic restart. A new descriptor at032 will identify width139/version15/G5B1; six words033..038 contain two independently padded records (three words each). Width139 leaves53 high padding bits in the last word, all validated zero; absent second-device payload must be zero. Text-position range is checked. All new metadata is read/validated in the existing early header chain, before any early IO/gun/CPU/VDP/guest-memory restore. Older tags skip the extension and normalize missing history deterministically; they cannot recover its unavailable original future.

Prefer139-bit snapshot banks with sequential 64/64/11 transfers over a dynamic indexed139-bit crossbar or a separate192-bit padded bank. SAVE rotates64,64,11 to restore the snapshot; LOAD shifts64,64,11. This bounds added storage and routing. DDRAM preview and registered command paths must match exactly under stalls. No acceptance, CPU/NMI/Pause, sprite or phase-commit policy changes are proposed.

The existing container remains96KiB. Development-version consolidation is explicitly excluded. Resource pressure is checked only after all required simulations pass; full controlled Quartus must compare with the committed v14 resource/timing baseline, and significant growth requires revisiting the representation/transport before recommending commit.

Legacy refinement before production: normalize x to literal zero too. Reusing the old mode/scroll-dependent ss_restore formula would see discarded pre-load mode on that same edge and would not be deterministic across Q histories. All missing G05 history therefore normalizes to zero. The already-running first side-record prototype retains the old legacy-x formula only in its initialization; its modern valid139-bit restoration is identical. The selected production proposal and subsequent source gates use literal-zero legacy x. No exact missing-history replay is promised for legacy files.
