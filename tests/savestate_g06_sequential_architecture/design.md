# Frozen candidate A contract

Baseline is committed F01/v17 at 7fcd5e1. All production files remain untouched. Candidate sources live only in candidate_A/. No field removal, format consolidation, F06 or G08.FM work.

The reusable F01 principle is local fixed-slice access to held live state, narrow word enables and synchronous scratch memory. Its initializer gate, cache refill and OPLL delayed counters are algorithm-specific and are not copied into the sprite engine. Neither its negative placed delta nor its estimated per-unit ALMs predict this candidate's result.

## State and mapping

Keep all 4,778 bits per VDP. For slot i (0..63), base=74*i: enable at0, X at1..8, cached planes at9..40, four shifters at41..72, wideclock at73. Fixed fields: address4736..4749, mode2 flags4750..4757, color4758..4761, collide4762, overflow4763, collision delay4764..4777. The evaluator still normalizes WAITING/count0/index0 at the original register-restore strobe. Its boundary exclusion is unchanged.

Port row r contains existing packed bits32*r..32*r+31. Rows0..149 exactly match the low/high halves of existing 75 DDR64 sprite words; row149 bits31:10 are canonical zero. Each field is split at fixed 32-bit boundaries in its owning module. No dynamic slice of a 4,778-bit live vector is used by production synthesis. Shifter offsets are constant instance generics. The initial prototype registered local response pieces and ORed them. The selected implementation ORs local combinational pieces and registers one32-bit response at each VDP boundary, preserving the same one-edge interface. The synchronous identity and exact clock miter are recorded in read_retiming/equivalence.md; this removes unnecessary response copies, not guest state. Writes reach only overlapping constant field slices; ordinary sprite enables remain zero throughout access. Wide legacy output aliases may remain for read-only test probes; no wide shadow bank or parallel restored-state bank is retained in the synthesized candidate.

G10 history stays two phase bits and one consumed-T bit. Its CPU preparation, divider installation, beam commit, NMI hold, memory ownership and normal/turbo/System E/Pause policies remain unchanged. Shared controls are freeze, architectural VDP restore, ownership and version presence. No G10 state is removed or reencoded.

## Storage decision

Use one independent 300x32 logical scratch (9,600 bits) for the two padded records. This needs two M10Ks at the chosen 32-bit width; post-F01 has65 free, leaving63. This is an explicit trade, to be accepted only against measured placed-ALM recovery. It replaces 9,600 snapshot FF and their capture/rotation/insertion muxes. It does not duplicate live sprite storage.

One F01 256x32 scratch cannot hold both records; borrowing it would couple and change the proven F01 engine. A 512x20 representation could fit one physical M10K but needs a nontrivial 20/32/64 repacker, outside the requested 16/32/64 comparison. A16-bit port still requires two blocks and doubles transactions; no concrete advantage justifies building it. A64-bit port also needs two blocks and halves accesses but doubles routed data width; consider it only if measured32-bit decode/latency warrants it. No mechanical width sweep.

Direct SAVE from frozen live state needs no scratch, but LOAD must validate the entire record and subsequent metadata before changing live state. Two-pass DDR rereading would add a new image-stability interval; local RAM avoids that contract change. Local RAM conversion of live shifters cannot preserve parallel pixel updates cheaply. Small-parallel/large-sequential hybrid retains avoidable shadow FF. The chosen bounded experiment uses minimum architectural complexity, not minimum possible RAM bits.

## Ordering

Accepted edge T executes normally. Existing freeze begins after T. Start the scratch capture at ARM; post-T live sprite state is stationary. A 300-row issue/collect scan reads both devices, substituting zero for the inactive second owner. Existing F01 capture and other metadata run unchanged. Sprite descriptor transport waits for scratch idle before use.

SAVE reads each scratch low/high pair synchronously, then issues the unchanged DDR64 payload transaction. Backpressure cannot skip/duplicate rows. External descriptor, phase/ownership word, payload addresses, word order, padding, global commit and version tags remain identical.

LOAD validates each word with the original padding/ownership predicates, then writes its two scratch rows. No live write occurs during gathering or validation. Existing remaining headers, FM extension and memory transport are untouched. Before the first ST_LOAD_RESTORE architectural strobe, scatter all150 words for each active VDP (legacy: literal zeros), then perform the existing scanner normalization and ordinary VDP/CPU/PSG restore. These strobe branches preserve already-installed serialized fields rather than clearing/replacing them. Inactive VDP2 is not modified outside System E, matching production.

No guest CE, evaluator step, shifter step, collision-delay step or extra CPU reconstruction tick is introduced. Raw presentation counters may keep running under the existing contract. Partial installation remains private behind freeze. The unchanged F01 apply/flush and G10 preparation/release follow coherent sprite installation.

## Proof and measurement gate

Prove all9,556 meaningful bits, all44 padding bits, complete v17 byte compatibility, exactly-once access, legacy defaults and malformed rejection before application. Actual sprite equivalence and integration witnesses must cover collision, overflow, evaluator normalization, shifters, SAVE, repeated LOAD, modes, phases and stalls; G05 must pass. Controller/VDP test oracles remain independent committed production behavior. Reduced-slot fixtures are not production64-slot packing proof.

Only after the functional gate passes may candidate A receive a full fresh source-only same-settings Quartus build. Compare needed/placed/FF/M10K/bits/DSP/timing/warnings against the verified post-F01 endpoint. Investigate new worst timing paths. Confirm surprising gain or near-zero timing with one controlled repeat. Production remains unchanged even if the experiment succeeds.

Exact cycle and physical-time budgets will be derived from the implemented handshake, including command/done edges and scan overlap; the208/216 OPLL figures are not reused as sprite numbers. Physical clk_sys derives from the unchanged PLL and must be verified before microsecond conversion.
