# G06 design gate — production unchanged

Baseline8ffd15e2a7e530c0d77b07c6eeae3e8dc0aa0c8a, format13. Branch fix/savestate-g06-vdp-sprites. This is an analysis and test-only prototype; no production design has been selected or applied.

## Two root causes

Failure A is a temporal hold defect. Evaluator overflow holds while its enable is stopped, but vdp.vhd's ce_vdp=0 branch continues following raw x/y. It clears line_overflow outside its window and later re-arms overflow_flag from the held source. The durable guest flag changes with transport duration. The minimum local correction must gate that host-clock branch with the actual transport freeze. Adding image bits cannot make SAVE-only transparent.

Failure B discards a future-producing source. At x10/y168 the two sprites have already been evaluated and their X120 opportunity is ahead. Resetting enables/positions/patterns/shifters removes that source until the next x257 scan. The image's VRAM/SAT bytes do not reconstruct the already evaluated cache on the accepted line by themselves.

The production top is `system #(63)`, hence64 slots per VDP. The old exact witness uses the entity's default8 slots and normal sp64=0. Reproducing it is necessary but does not validate all64-slot or accelerated-ce_sp behavior.

## Families (not a selection)

| Family | A / B coverage | State, format, interfaces and limitations |
|---|---|---|
| A freeze only | Fixes A locally; cannot recover historical sprite source for B | No payload/version change. Add defaulted VDP freeze input and connect existing system.ss_freeze to both VDPs; guard only the ungated overflow bookkeeping. Normal non-save branch remains identical. Shared119/118 status consumer is analyzed; IRQ/reset_flags/background/bus unchanged |
| B collision/overflow metadata only | Needs A separately; can replay a particular pending flag but not reconstruct future pixels/sources for arbitrary suffixes | Current flags already saved; pending shift/output could need extra bits, but those cannot replace X/pattern/shifter history while future sprites remain live. A witness-only patch is insufficient |
| C future-relevant evaluator/cache/shifters | Can address B under identical future inputs; still needs A | Must establish each field's consumer order before selecting width. New payload would require v14, independent VDP1/2 interfaces and deterministic legacy normalization. Snapshot FF/mux/routing cost could be substantial but no new backing RAM is inherently necessary |
| D canonical boundary | Potentially zero extra historical bits; still needs A | Merely VBlank is disproven by GG crop. A true blank interval must leave sufficient refill before collision/status or visible pixels, for all heights/regions/legacy modes and both VDPs. Guest mode/register writes and caches not cleared at x257 defeat a superficial “one blank line refills everything” argument. Changing acceptance also changes F12 progress/liveness and invalidates prior G02–G05 boundary assumptions. No general proof yet |
| E hybrid | Necessary if C chosen: temporal hold plus proven minimal state | Same v14/legacy/interface consequences as C. A version bump is allowed only after necessity and sufficiency are demonstrated; no production payload allocation made here |

G07's exclusion remains valid while accepted x remains<256 (ARM at most256). No new boundary is applied by these tests.

## Consumer-order inventory relevant to minimality

The exact declarations/assignments/consumers and reset behavior are retained in the completed investigation's inventory.json/state_behavior.md and its cross-module connections.json. They remain source-identical at this gate. New categorization below deliberately leaves uncertain cases unresolved rather than calling every latch mandatory.

| Field | Candidate category / reason |
|---|---|
| evaluator state3, count7, index6 | B/E at existing accepted x<=256: x496 puts scanner WAITING; x257 resets count/index before the next evaluation. Need corroboration for64-slot/sp64 and all enabled phases |
| ce_spload | D, combinational selection of ce_vdp/ce_sp; not a stored bit |
| data_address14, m2_flags8 | B in a fixed-mode fresh scan, but potentially C under legal mode writes during evaluation: paths can change between assignments and consumers. Do not exclude merely because a fixed-mode test refills them |
| enable[64] | C while current-line sprite output can still affect status/pixels; masks shifter outputs |
| spr_x[64], spr_d0–3[64] | C for enabled slots and future reloads; inactive-slot exclusion requires a full fresh-before-effective-use argument, including mode changes and early-clock variants |
| spr_color[64], spr_active[64] | D, combinational projections of shifter planes/mode |
| wideclock[64], shift0–3[64] | C for current-line phase/content; inactive-slot exclusion not established globally |
| registered color4, collide1 | C: these are one-enabled-step delayed outputs, not aliases of the new shifter state |
| evaluator overflow1 | A/C: must hold through SAVE and reproduce the captured source on LOAD until its next normal overwrite |
| line_overflow1 / overflow_flag1 | Already serialized; A during transport. Do not add duplicate payload bits for their missing hold |
| xspr_collide_shift14 | G04 shared dependency: a source can already be in flight at T. Preserving source alone may be insufficient. Any change must be justified for complete G06 timing and explicitly invalidate the affected G04 evidence without closing G04 |

Mode4 normal loads occur at x<255 or511, shifted loads at x<248 or>=504. Legacy early-clock loading can begin at x>=480. The legacy evaluator is limited to32 source indices; Mode4 may evaluate64 with ce_sp. These facts can support a bounded refill argument, but arbitrary legal mode changes can cross decoder assignment paths. No whole-pipeline boundary proof is claimed from a fixed-mode steady case.

## Test-only ceiling, before production edits

The prototype side record preserves **every** evaluator/cache/shifter storage element plus the14 delayed collision bits. It intentionally over-preserves to answer whether incomplete sprite representation alone explains the mandatory replay oracle. This is not the chosen minimal representation and not a v14 implementation.

Per slot: enable1 + X8 + four pattern bytes32 + four shifter bytes32 + wideclock1 =74 bits. Fixed sprite fields: state3 + count7 + index6 + address14 + m2_flags8 + registered color4/collision1/overflow1 =44 bits. Add14 collision-delay bits. Total650 bits for the exact8-slot witness;4794 bits for production64 slots. Spr_color/spr_active and ce_spload are derived and not duplicated. A future proven exclusion of state/count/index alone would remove16 bits, but this is not a final width decision.

The side record is captured at the same ARM edge as the real VDP state and applied by the same LOAD ss_regs_set pulse. The v13 writer/reader, DDR transport and900000 flush remain unchanged. It is outside the image solely for this sufficiency experiment. Some unused legacy/inactive diagnostic fields are X in the old witness; those are retained only for diagnostic four-state identity, never counted as initialized-pixel/image evidence. Real VDP status/RGB and guest signatures still reject unknowns. A real format proposal must prove meaningful state and validation independently.

The prototype also applies only the local overflow-freeze guard. It leaves all CPU/controller release timing untouched. If a residual status-clear timing difference remains even at this ceiling, adding more G06 bits cannot explain that residual; the coupled restart contract must be resolved before selecting a production design or claiming the mandatory end-to-end witness passes.

## Resource baseline and expectations

The committed post-G01 build has ALMs needed27368, placed32684, fitted registers36831, M10K487, memory bits3809858, DSP39, setup+0.483ns and hold+0.213ns. Current M10K487/553 is the tightest requested resource. These are retained build results, not a new Quartus run.

Freeze-only should add a wire/guard and no memory. A naive full side-record production clone would add roughly two4794-bit snapshots plus validation/transport control and many restore muxes, so it cannot be justified by passing two examples. No extra M10K is inherently required if flat FF snapshots are used, but exact synthesis/fit/memory inference must be measured only after the simulation gate passes. No Quartus is authorized before that gate.

## Open gate

No production RTL, format, acceptance, CPU release, mapper or audio behavior has changed. Exact unchanged witnesses and ceiling prototypes are running. Local freeze success, full source restoration and any residual CPU/VDP observation timing will be recorded before further design decisions. Legacy-state handling remains the existing v13 policy until a proven representation is selected; unavailable historical sprite history must never be invented.

Update: all seven runtimes completed. The freeze-only prototype passes the exact overflow SAVE-only oracle. The full raw sprite+delay record restores identically, then matches the uninterrupted sprite record, CE schedule and beam for1999 native clocks. Nevertheless CPU status reads occur two pixels later (x28 vs26, x130 vs128), with historical fetch replay occupying the first two pixel enables. It still produces9 collision-flag and6 status-bus differences. See review.md and trace_analysis.json. Further production design is gated on resolving the request's exact Phase10 timing requirement against its explicit G10 exclusion. A narrow shared restart-ordering scope decision is pending; no production fix or minimality claim has been made.
