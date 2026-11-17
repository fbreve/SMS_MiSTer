# Accepted-boundary and reissue contract

This writer accepts only an unprefixed M1/MREQ fetch on an effective CPU-enable
edge in its existing VBlank/x window. A request for SAVE is not acceptance.
The boundary campaign varies real request timing; it does not force acceptance
at forbidden CPU bus phases.

| ROM phase | Naturally reachable around a SAVE request | Can the current writer accept there? |
|---|---|---|
| Before request / T1 | Yes; offset sweep and real instruction progression | No: MREQ is high before T1 generates the read; request defers |
| Read asserted after T1 | Yes; physical model and real CPU observe this interval | Only at the next qualifying CPU edge, which is consuming T2; not between CPU enables |
| q0 accepts read | Yes, normally T1+1 | No separate effective CPU enable at this host edge |
| Waiting for response / ACT / READ | Yes, q1..q5 | No separate effective CPU enable; ordinary minimum CPU period10 exceeds seven-clock read completion |
| Physical response arrives | Yes, fixed CAS2 with TAC0/3/7 | Between enabled T1 and T2, not independently accepted |
| Response registered / q6 | Yes, T1+7 | Before the next enabled T2; not independently accepted |
| T2 consumes response | Yes | Yes for running capture; consumed-T=1, CPU architecture before T and devices after T |
| Returned but paused T2 not consumed | Yes | Yes on raw effective cadence while logical Pause suppresses execution; consumed-T=0 |
| Immediately after consumption | Yes | ARM collects post-T devices while freeze prevents another guest tick; acceptance itself was T2 |

Non-M1 operand/data reads also occur in the guest programs, including immediate
and multi-byte operands and reads across3FFF/4000 and7FFF/8000. A SAVE requested
during those reads defers to the next legal fetch. No change to the acceptance
predicate is proposed. A later instruction's operand/data path must still match
the uninterrupted CPU/memory suffix.

## Deterministic reconstruction argument

1. LOAD restores mapper and CPU architecture/context. DIRSet deasserts MREQ/RD.
   The unchanged flush and255-clock settlement leave more than a complete
   controller access, so the previous immutable read finishes and old_rd samples
   low before private T1. No host download overlaps this active-media session.
2. During preparation, the candidate gives SDRAM the same raw /15 reference
   that drives private CPU replay. Prior low reference guarantees an edge at
   T1. On that edge q becomes0 and CPU RD becomes high. At T1+1, q0 accepts
   exactly the restored address. This repairs the previously missing acceptance.
3. q1 ACT, q3 READ and q6 capture follow the original physical command recipe.
   The returned byte is installed at T1+7. The two legal private T1 phases are
   raw10 and25. Switching to /15 while the old reference is high can remove an
   edge but cannot remove this later private T1 edge. Low/high sampling is on
   the same host clock, with single-clock enable pulses.
4. If historical T2 is required, it occurs T1+15, after completion. If it was
   suppressed by saved Pause, preparation ends after T1. Phase commit occurs
   with all CEs zero; the System E/turbo first native CPU edge is ten clocks
   after commit, after completion. Current Pause can postpone that consumer,
   never move it earlier. Normal SMS uses its existing /15 continuation.
5. RD stays high until T2; old_rd=1 after acceptance prevents duplicates at
   subsequent idle slots. T2 deasserts the read; q0 later samples low normally.
   No stale completion can overtake the new one because earlier accesses drained
   before step1. The byte-lane/address register is replaced with the new request.
6. The CPU therefore sees the correct immutable input at the same logical T2
   used by G01. Captured phase/beam, consumed-T bit and every guest enable remain
   unchanged. No additional preparation tick or release delay is introduced.
7. SAVE never asserts cpu_prepare, so its reference-clock selection is exactly
   the original production selection. Ordinary post-release requests retain
   their original timing and implementation, including operand/data reads.

Refresh/source switching also needs legal spacing. Native /10 and private /15
reference edges are on the same30-clock lattice; the closest distinct source
edges are five host clocks apart. There is no active guest read at preparation
entry after settlement. The first new ACT follows the aligned T1, and return
finishes before the next possible consuming/referencing edge. No SDRAM chip
reset, refresh-history restore, command duplication or changed CAS is involved.

This is a protocol sufficiency argument, corroborated by freshness ledgers,
full-image history pairs and transport/source-phase tests. It is not a claim
that a finite random search alone proves injectivity or arbitrary illegal chip
timing. The saved architectural request identifies everything needed to reissue
an immutable read; historical physical q/address/word need no new payload.
