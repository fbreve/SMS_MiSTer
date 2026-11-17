Title: Add public v1 YM2413 FM savestates

YM2413 FM state now participates in hardware save/load instead of continuing from the pre-LOAD FM endpoint. The implementation freezes and restores the OPLL memories, command/pipeline state and slot counters through a sequential 100-word snapshot using 50 DDRAM payload transfers. It adds public FM descriptor version 1, validates tagged payloads before live restoration writes, and preserves deterministic fallback for legacy non-FM savestates. Unpublished experimental FM descriptors are rejected.

OutputMemory uses guarded MLAB while RegisterMemory and FeedbackMemory remain in logic. TemporalMixer's four transient fields are omitted and regenerate after restore; the preserved differential campaign verified convergence within 144 enabled FM clocks across all 72 phases. The format documentation explains this convergence behavior and the inherited limitation that a late DDRAM timeout during RAM streaming can leave a partial restore without rollback.

Validation:

- Preserved 72/72 phase differential campaign for the unchanged compact state layout, plus ten public-v1 focused compile/simulation invocations covering descriptor acceptance/rejection, 100-word map/transport, collision A/B, legacy fallback and live state/audio checks.
- Quartus Prime 17.0.2 Build 602, Cyclone V 5CSEBA6U23I7, seed 1: 27,297 needed / 32,221 placed ALMs, 35,724 fitted registers, 20 MLAB cells / 380 logical bits, 489 M10Ks and 39 DSP blocks. Constrained setup/hold WNS +0.582/+0.243 ns, zero TNS. Existing unconstrained-I/O qualification remains; warning text matches the reference build.
- Physical MiSTer testing PASS, reported by the user for the preserved public-v1 RBF SHA-256 `f91797c3860370d6d0ee377f6a5416a73a693ba6d52a902695f5ec041ec6a5a0`.
- The clean candidate has no executable RTL difference from that validated implementation. The sole production-text delta is the intentional English SRAM comment in registermemory.vhd. Source-closure, encoding, line-ending, whitespace, scope and preservation checks pass.

This change contains 24 production files and two documentation files relative to master `66f16d5c656fd8906d62570da4d258875bcee684`. It retains the complete registermemory.vhd savestate interface and logic, not only the final five-file optimization layer. It includes no experimental test infrastructure, generated reports, RBFs, sys/ changes or unrelated main-workspace RTL variants.
