# F12 implementation contract decision

Base: committed F11 `dcbe06d`; branch `fix/savestate-systeme-pause`.

Production scope is `SMS.sv` and `rtl/savestates.sv`. The permanent pre-fix runner `pre_fix.ps1` extracts the production SMS/controller from the committed base, uses the original production-T80/PSG reproductions, and writes new logs here without replacing investigation evidence. Baseline generator/scenario and production sources are retained under `baseline/` so the reproductions remain runnable after a fix.

## Contract requiring clarification

The implementation request's phases 3/11 permit temporary execution to reach capture. Phase 8 also requires exact save-only equivalence against an uninterrupted paused reference in every previously reachable phase.

For an already paused, non-M1 CPU bus these are different contracts. The reference executes zero CPU/PSG enables. Making the actual CPU reach M1 requires at least one enable and may change registers, buses and PSG counters. Restoring the host/UI flag afterward cannot undo those machine changes. Existing CPU architectural save registers do not expose the complete arbitrary stopped microcycle for a transparent local rollback. Forcing an acceptance predicate would not prove a valid machine snapshot.

The user explicitly selected: “Allow bounded, coherent CPU/PSG progress solely to reach capture; preserve logical host Pause and document that exception to exact reference equivalence.” The implementation and scoring use that approved contract. The non-M1 case is not claimed equivalent to a zero-progress paused reference.

## Selected mechanism

Keep logical pause/pending flags external and unmodified by save/load. Continue sampling the physical button during frozen transport, ignore new edges inside that interval, and retain pending transitions without consuming raw transport-only VBlank edges. Re-prime/suppress the release edge consistently.

Expose a dedicated combinational capture-progress indication from the production save controller, restricted to state WAIT_BOUNDARY, storage idle, VBlank and x<256, only while its normal unprefixed M1/MREQ predicate is not yet satisfied. Bypass the CPU/PSG pause gates only for that indication; leave logical pause/dimming unchanged. Deassert progress as soon as the qualifying bus is reached, before acceptance, and use ordinary transport freeze thereafter. A paused bus already qualifying for capture needs no override. No v8 metadata or payload change is involved.

The reference checks would retain exact equivalence for running/pending and already qualifying paused cases. The formerly stalled case would explicitly compare the bounded coherent progress against a separately specified capture-progress reference, and report the difference from a reference that stays fully paused. It must never be described as exact equivalence to a zero-progress reference.

Current host phase, rather than historical saved phase, must survive each load. A separate repeated-load regression must change the current host/UI phase after saving and prove that the payload never rewinds it. The original investigation's historical-phase mismatch is retained as evidence, not reinterpreted as a requirement to serialize host pause.
