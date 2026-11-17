# G06 representation analysis (proposal, not a passed implementation)

The accepted boundary has x<256, and the post-edge ARM observation has x<=256. Every preceding line forces the evaluator to WAITING at x496. Its selected enable is /5, or /2 with accelerated evaluation, while a pixel lasts ten host clocks. Thus x496 is sampled. Startup also initializes WAITING. Before the next scan, x257 overwrites count and index. This argument requires confirmation across the requested mode/cadence matrix; the current fixtures assert WAITING at ARM.

| Field | Proposed classification | First relevant consumer / reason |
|---|---|---|
| state | RECONSTRUCTED BEFORE OBSERVATION | Restore WAITING; x257 starts COMPARE. No evaluator operation in WAITING. |
| count | RECONSTRUCTED BEFORE OBSERVATION | x257 assigns zero before the next cache write or limit check. |
| index | RECONSTRUCTED BEFORE OBSERVATION | x257 assigns zero before a sprite table address is selected. |
| data_address | MUST SERIALIZE | Partial writes and mode changes can retain bits until a subsequent VRAM address consumer. |
| ce_spload | IRRELEVANT AT ACCEPTED BOUNDARY as stored history | Combinational selection of ce_vdp/ce_sp from current sp64 and generic capacity. The shared phase contract determines subsequent enables. |
| m2_flags | MUST SERIALIZE | Legacy LOAD_X reads the early-clock bit; LOAD_1 copies flags to pattern/color cache. A mode change can enter these branches without a preceding legacy LOAD_0. |
| enable | MUST SERIALIZE and MUST FREEZE | Current-line shifter output participates in color and collision before x257. |
| spr_x | MUST SERIALIZE and MUST FREEZE | Shifter reload comparisons occur throughout the current line, before evaluator refill. |
| spr_d0..3 | MUST SERIALIZE and MUST FREEZE | Reload supplies pattern or legacy color data from retained cache. Future mode changes prevent a blanket inactive-plane omission. |
| registered color | MUST SERIALIZE and MUST FREEZE | Output is retained between pixel enables and feeds the VDP pixel path. |
| per-shifter spr_color | IRRELEVANT as separate stored history | Derived from shift registers and mode. |
| spr_active | IRRELEVANT as separate stored history | Derived from shift registers and mode. |
| wideclock | MUST SERIALIZE and MUST FREEZE | Determines the next half-speed shift when wide sprites are active. |
| shift0..3 | MUST SERIALIZE and MUST FREEZE | The next pixel consumes retained current-line pattern/color state. |
| registered collide | MUST SERIALIZE and MUST FREEZE | Source of the collision delay/status path, including the first future pixel. |
| registered overflow | MUST SERIALIZE and MUST FREEZE | Source persists after evaluation and is consumed by status bookkeeping. |
| collision delay (14 bits) | MUST SERIALIZE and MUST FREEZE | Already-launched sprite collision can emerge after capture. Shared G04 dependency; preserving it does not close G04. |
| collide_flag, overflow_flag, line_overflow | MUST FREEZE; already serialized | Existing VDP register record contains these flags. Guard the raw-beam overflow branch during transport rather than duplicating their payload. |

The proposed fixed-width record is 74 bits per slot (enable, X, four cached bytes, four shift bytes, wideclock), plus 42 fixed bits (address14, flags8, color4, collide1, overflow1, delay14). At production capacity64 this is4778 bits per VDP. It omits the16 evaluator control bits in the diagnostic full record. This is a conservative fixed representation with explicit consumer reasoning, not a claim of information-theoretic minimality. Conditional compression of inactive entries is not yet proved safe.

Some inactive cache registers are uninitialized in the original VDP RTL. The new format must not silently replace future-relevant unknown history with zeros or add normal-execution reset behavior solely to make simulations look initialized. Complete-image known-value tests require legal initialization of all retained fields; active guest-output checks alone do not establish that stronger property.

Final validation: the production implementation uses this inventory. All14 sprite scenarios pass, including accelerated64, applicable legacy modes, first visible line and line transition. Accepted ARM observations assert evaluator WAITING. A naturally executed guest program creates index2 and index4 with WAITING/count2, identical full known64-slot v14 images and identical3,000-observation futures. The producer-order argument for state/count/index is unchanged by mode/tall/wide inputs because the x496/x257 branches precede mode decode. The passing search corroborates that argument; it does not prove conditional omission of retained cache/flags/address bits. The later output-register aliases are an exact renaming for Quartus language compatibility and do not add historical state.
