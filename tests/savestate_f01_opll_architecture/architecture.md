# Proposed frozen sequential access contract

This is an architecture specification for a future F01 task, not implemented RTL. The behavioral audit hooks are category-preservation experiments, not this interface.

Use a 32-bit private state bus, local word enables, the existing six memory interfaces, and one 256×32 M10K transport/validation scratchpad. Do not add a complete parallel snapshot bank. Hold guest OPLL xena, CPU, VDP and PSG enables through the existing freeze contract. Private access must never assert a guest enable.

## Unrestricted startup is the conservative default

Current acceptance does not require OPLL initialization complete: op_cooldown resets to zero, video has no core-reset input, and initialization runs on host clocks. A reset during an existing VBlank therefore invalidates a blanket assumption that every accepted capture is after initialization. The completed audio witnesses are after initialization; they do not prove that startup history is dispensable.

Retain **37 initialization-control bits** and conservatively retain **1,296 bits** of fixed-voice backing contents whose pre-initialization necessity is unresolved. Together with the1,896-bit steady-state representation, this gives **3,229 bits**. There are148 natural array32-bit rows and20 scalar rows:168 rows /672 bytes, plus one64-bit descriptor =**680 bytes**. One256×32 M10K is sufficient. The packed minimum is404 bytes,408 with64-bit alignment,416 including the descriptor. The padded680-byte layout avoids variable packing.

For this unrestricted variant, hold **initialization FSMs and every ordinary memory writer from the first frozen host edge**, before any T+1 initialization step. Save pre-commit arrays plus their pending write/data/address state. Do not normalize by advancing initialization or silently wait it out during transport. After validated restore and stationary cache refill, resume the pending initialization/store step on its original logical clock. The row-schedule target is336 clocks for collection and181 clocks after validated LOAD (168 row slots +3 regenerated counters +2 handoff +8 refill). These are design targets, not measured implementation bounds. Refill is permitted only for pure lookup/read caches, with every temporal initializer frozen.

An alternative may add an explicit initialization-ready acceptance gate and prove unchanged SAVE-only behavior and bounded request latency. Only under that proven contract may it omit the1,333-bit startup allowance and use the smaller variant below. Do not implement the steady-state-only exclusion without that proof. Retaining the uncertain backing contents in the conservative plan is not a claim that every bit has an independently established future effect.

## Capture boundary and pending writes

Let T be the accepted SAVE rising edge. Normal OPLL xena at T, if present, is consumed on T before ss_freeze rises. The wrapper also sees the old freeze value. There is no OPLL falling-edge divided-enable register analogous to JT89.cen_16. Preserve the resulting post-T slot, command, phase/envelope work registers, write strobes, addresses and data.

For an initialization-ready capture, the following host edge can commit a write generated at T. A candidate may allow that pending write to commit with its original address/data, then inhibit **all six ordinary memory writers**. Their held address/data/strobe makes repeated frozen writes idempotent. This permits a post-commit array value together with the saved pending strobe. The conservative alternative freezes before that commit and retains pre-commit contents plus pending state. The implementation must choose and prove one representation; these are not interchangeable without ordering proof. Neither permits an extra xena, envelope increment, key-edge update, LFO/noise step, feedback recomputation or accumulated sample.

Scalar temporal state stays in place while frozen. Read it through local fixed slices. In particular EG.aridx is a recomputable host-clock copy of retained egphase; it is not additional history. Memory read latches and LinearTable caches can change during private access; reconstruct them later with xena=0. Do not apply this exemption to CE-clocked sine/attack pipelines: the 72-phase ablation found an operator-pipeline counterexample.

The normalized boundary is supported by current source ordering, exact SAVE-only tests at different accepted clock classes and durations, and stationary-cache experiments. An implementation must prove the proposed port interposition itself against an independent unmodified oracle, including same-edge FM writes, before production integration. No such port prototype or accepted-edge sufficiency proof for a new implementation is claimed here.

## Smaller initialization-ready variant (conditional)

Historical arrays: channel9×22, user voices63 total, phase18×18, envelope18×25, feedback9×10, output18×10 = **1,305 bits**. The remaining **591 bits** are scalar/pipeline history, including wrapper9 and one base slot phase7.

Use 76 natural 32-bit memory rows: 9 channel rows, 4 rows for two 36-bit user-voice records, 18 phase,18 envelope,9 feedback,18 output. Unwritable user-voice bits are checked zero. Nineteen scalar32 rows hold591 bits; their17 unused positions are zero. Total95 rows =3,040 bits. Pad to96 rows for48 64-bit DDRAM words; add one64-bit descriptor =**392 bytes**. This deliberately trades144 bytes against a minimum packed record to avoid a large variable bit packer. All1,176 unused payload bits must be canonical and validated. Use local fixed wiring for padding, not a giant variable shifter.

No magic, address or format version is assigned. A future descriptor must identify layout/length/presence/mode, require zero reserved bits and commit validity only after payload completion. Existing v16 remains untouched. The loader validates the whole candidate record in scratch RAM before changing live OPLL state.

Validate bounded integer/index fields as well as padding: base count0..71; delayed counts are generated, not trusted; voice address0..37; channel addresses0..8; slot addresses0..17; initializer counters0..9,0..18 or0..38 as declared; initialization rstate0..2. Field widths alone do not reject every illegal source state.

At one read-issue plus one store edge per32-bit row, snapshot collection targets190 host clocks. After LOAD validation,95 private row slots plus three regenerated delayed-counter writes, two control/port handoff clocks and eight stationary refill clocks target **108 host clocks** before release. These are schedule bounds for the proposed protocol, not measured implementation latency. DDRAM busy/response time is additional and unbounded by this local estimate. Private current-format preparation advances zero emulated FM ticks. A reset-based legacy fallback is different: voice initialization alone takes114 host clocks and needs its own complete ready condition.

## Restore and publication

1. Keep guest xena=0 and every ordinary memory writer inhibited.
2. Restore all validated array rows through original narrow data/address interfaces. The user-voice upper/lower rows assemble before their one36-bit write.
3. Restore scalar/pipeline history with local word enables. Partial scalar values must not escape to ordinary writers. Restore the base counter; derive delayed counts as `(base+72-delay) mod72`, delays2/5/8. This calculation can share a small private arithmetic unit and is outside the guest timing path.
4. Return addresses to their saved runtime owners. In the unrestricted pre-commit representation, keep **all** ordinary writers and initializers inhibited during refill, and resume them on the first logical host edge. A separately proven initialized/post-commit representation may replay an idempotent saved store during preparation; never mix those representations. Refill RAM read ports, EG.aridx and the two-host-edge linear lookup without temporal advancement. Keep CE-clocked attack/sine state exactly restored. Eight private host edges provide a conservative refill budget; prove the first enabled consumers match, including startup memory-write priority.
5. Restore raw FM mixout and partial sum. Give AudioMix stable restored inputs before its existing first-resumed phase selection. Do not use the PSG pending event to clock OPLL. Preserve the existing PSG/divider/pending-tick release sequence.
6. Release through the existing native clock-phase handshake. Future G08.FM tests must check both the release-edge pair and every following logical host clock.

## Why this reduces wide mux pressure

The existing memory writers already multiplex one word into an array. Add private address/data selection there; avoid a new restore input at each physical array bit. For scalar fields, a32-bit data bus and locally decoded enables replace a1,896-bit common restore bus and a2,179-bit scratch shift/capture bank. Global address/control reaches a small number of local decoders. There are19 scalar words plus six array endpoints, rather than thousands of independent full-width endpoints. A word-enable receiver can still require per-bit selection; sequential access does **not** make mux cost zero. Quantify it in the future integrated map.

Keep module-local read muxes and one final32-bit bank selector. The isolated full2,048-bit indexed read/write experiment added832 mapped ALUTs and766 placed ALMs relative to its virtual-pin baseline; therefore do not collect every live bit in one large central indexed vector. Existing RAM read ports reduce this crossbar to scalar history and a few returned memory words.

## Proof obligations before adoption

Prove live state stationary during collection; pending-store normalization at each accepted phase; identical SAVE-only future for arbitrary transport duration; no ordinary write from partially restored values; every field and all padding validated before application; exact current-image raw output from the first resumed clock; repeated LOAD; all envelope/rhythm/instrument/channel cases; near-T CPU writes; Pause; muted-then-enabled FM; unchanged PSG pending-event semantics. Use the retained natural collision and immutable images. Then measure full-board needed/placed ALMs, FF, M10K, setup/hold and warning deltas with the established build configuration. The resource target is at most813 added placed ALMs when possible;1,651 is a risk-review ceiling for the proposed next task, not existing authorization to accept a regression.
