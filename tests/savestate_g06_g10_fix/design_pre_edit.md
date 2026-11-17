# Coupled restart selection before production edits

Baseline8ffd15e/v13. See contract.md for domain ownership and state_inventory.md for the G06 consumer inventory.

| Alternative | Assessment |
|---|---|
| Literal clkd | Five history bits, v14; restores enable order independent of transport but does not isolate historical CPU preparation. Equal-phase witness disproves sufficiency. |
| One arbitrary canonical phase | No phase payload, but changes next CPU/VDP/pixel/sprite/PSG ordering relative to captured beam. Equal-image phase witness disproves this without a further reconstruction proof. |
| Restart sequencer alone | Isolates CPU preparation and preserves G01/F16 mechanics, including Pause liveness, but loses historical enable relationships. Cannot alone meet the first-enable oracle. |
| Captured phase plus sequencer | Sufficient temporal structure when paired with required sprite history and CPU capture-edge consumption. Literal phase can be compressed to two bits at the accepted boundary. |
| Minimal G06 record plus encoded phase and sequencer | Selected draft:4778 bits per VDP, two phase bits and one CPU-consumption bit. v14 required. Independent dual VDP records share one logical phase; ordinary/turbo/System E use their existing normal enable policies after release. |

All selected preparation cycles hold VDP beam-relative guest state, sprite/status and both PSG enable paths; only CPU reconstruction and necessary read setup are admitted. This prevents the equal-phase two-pixel error structurally. GG/IO settle before F16 metadata installation, and the NMI sampler remains held until logical T+1. Current host Pause is retained; private preparation overrides it only to reconstruct the saved CPU phase. The historical consumption bit distinguishes a paused pre-T2 capture from a consumed T2 without serializing UI Pause.

Transport duration affects wall time only. A falling-edge phase installation with all CEs suppressed is acknowledged at the next rising edge, which installs the post-T beam and releases guest hold. Normal recurrence starts at the next falling edge. At most two effective private CPU ticks, or one for a stopped capture, are required; metadata can suppress one raw tick opportunity. Storage stalls and capture-window seeking have separate preexisting bounds.

No fixed two-pixel offset or artificial guest tick is used. Existing900000-cycle restore flush and255-cycle peripheral settling are retained; their duration no longer selects the guest release phase. Legacy snapshots deterministically clear missing sprite history, use phase0, and preserve the prior historical-T1/T2 policy. Old64KB images additionally normalize absent beam history to origin.

Synthesis expectation: snapshot storage and restore muxes add registers/ALUTs, not a deliberate new RAM block. Two75-word records fit the existing96KB container beyond System E passive VRAM. Dynamic word selection and wide restore fanout require actual fitting/timing checks. No timing/resource conclusion is assumed before the controlled build. M10K must be compared against487 baseline blocks.

PSG sanity concerns both raw /15 enables and held state during preparation; AudioMix/G08.release is not closed. F01 FM state is outside scope. G02 status-clear, G03 CPU/VDP transaction completion, G04 collision/IRQ and G05 background pipeline assumptions require contamination assessment after this new temporal baseline; none is closed here.
