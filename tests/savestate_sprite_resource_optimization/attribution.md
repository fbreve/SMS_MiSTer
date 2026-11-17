# Pre-edit attribution and candidate gate

Baseline cb2e861, v16. This document precedes production edits. Evidence is the
source-verified resource audit, retained full map/fit reports, and g06_g10.diff.
No semantic state reduction is proposed.

|Diff addition / current expression|Purpose and width|Structure and observed impact|Still required?|
|---|---|---|---|
|sprite_out/sprite2_out through system/VDP/main|Two 4778-bit historical records|Combinational wiring; no independent storage allocation|Yes, G06 state|
|sprite_snap/sprite2_snap|Two 4800-bit padded scratch banks|9600 mapped FF; capture/clear/rotate/load/hold input mux; current map 8:1 x4736 and 9:1 x4736 bulk groups, estimates23680/28416 LEs, not fitted ALMs|State yes, exact input topology not intrinsic|
|ST_ARM_FREEZE capture concatenations|Collect post-T record, zero absent System E bank|Parallel assignments under FSM priority; ARM fanout9511 at G06,9669 current|Capture edge and owner policy yes|
|ST_SAVE_SPRITE rotations|Low64 output, cyclic64 shift over75 words|Two wide shift paths, selected bank, shared transaction accept gate|Image/timing yes; mux organization replaceable|
|ST_LOAD_SPRITE insertion|64-bit incoming word shifted into selected4800 bank|Same lower4736-bit shift as SAVE, but separately described in main FSM|Behavior yes; duplicated descriptions replaceable|
|ST_LOAD_HDR_RD bank clear|Deterministic initialization before legacy/current reads|9600 synchronous-zero destinations in addition to async reset; shared header fanout5272 current|Yes, preserve exact legacy/error behavior|
|sprite_second/sprite_word/address/head select|2 banks x75 words,64-bit bus|One bank selection and address generation, not 9600 independent version comparators|Yes|
|has_restart / sprite_valid|Legacy missing-record normalization|One shared bit; current reported fanout1415; receiver defaults across sprite state|Yes, all formats preserved|
|ss_regs_set and per-field restore|Install live enable/X/cache/shifters/fixed fields|Receiver FF input selection; z80_set5898 and vdp2_regs_set5426 current high fanout report (shared beyond sprite cone)|Yes; not first optimization target|
|ss_freeze guard on overflow branch|Keep raw-beam overflow bookkeeping held|Small enable/control expression; no new historical bank|Yes, G06 SAVE-only correction|
|clock_phase/phase_snap/capture_tick|Two-bit phase and one consumed-T history|Three semantic history bits plus additional control storage/gates. The net mapped delta outside9600 bank FF is3 across all synthesis changes,not an isolated G10 cost|Yes; untouched|
|ST_CPU_PREPARE/ST_PHASE_COMMIT, RestoreHold|Private CPU replay while guest held|Small control/FSM paths, memory ownership selection, saved-phase installation|Yes, G10; untouched|
|ss_cpu_prepare,clock_phase_set,ss_phase_ready|Three one-bit registered controls/acknowledgement|State105/106 decode,falling-edge acknowledgement,rising-edge release;source FF counts differ from global net mapped deltas|Yes; untouched|
|clkd and ce_cpu/ce_vdp/ce_pix/ce_sp|Existing5-bit divider and four existing1-bit enables|Four-way phase installation into existing registers;all enables0 during handshake|Yes|
|ss_phase_out|2-bit combinational class from5-bit clkd|Equality decode for0/10/20/25;not a separate5-bit historical record|Yes|
|ce_z80 / ss_prepare_ce / nmi_replay_hold|1-bit private/native CEN selection|Normal/turbo/SystemE/Pause/replay gate;existing2-bit wrapper replay state gains conditional T2 exit|Yes|
|RestoreHold / nmi_hold_i / ReplayT2|1-bit sampler hold and1-bit consumption policy|Existing NMI/replay state selected by freeze/captured consumption;no isolated area allocation|Yes|
|ram_inst.address / nvram_inst.address_a|14-/15-bit existing memory-address muxes|Private replay read ownership while guest writes remain inhibited|Yes|
|video_state_in/set|Existing22-bit beam input and1-bit strobe|Post-T beam install with acknowledged phase;no new historical beam bank|Yes|
|removed align_timeout|22-bit obsolete counter declaration/updates|Unread timeout removed;no claim of22 FF savings without synthesis evidence|Not required;predates this optimization|

The exact total G06/G10 delta is +8051 needed/+5458 placed/+9603 mapped FF/
+11171 fitted FF. Controller mapped FF+9601, top+2. Controller mapped ALUT
+613; whole fitted logic ALUT+5818 and route-through ALUT+5399. Needed=A-B+C:
5458-(-2410)+183=8051. Aggregate placed-minus-needed *shrinks*2593, excluding
global packing degradation as the dominant explanation. Extra1568 fitted FF
are physical mapping/duplication overhead. These figures cannot be additively
partitioned into version, freeze and routing costs by the available hierarchy.
We explicitly do not assign every wide mux to compatibility.

## Complete preserved sprite width

For slot i=0..63, base=74*i:

|Field / source|Saved bit range|Width per slot|Restore width / consumer|Meaning and selection|
|---|---|---:|---|---|
|enable(i)|base+0|1|1; output/collision contribution|Every bit meaningful; independently restored|
|spr_x(i)|base+1..8|8|8; shifter reload comparison|All X positions; independently restored|
|spr_d0(i)|base+9..16|8|8; cached plane/color|All bits retained across modes|
|spr_d1(i)|base+17..24|8|8; cached plane/color|All bits retained across modes|
|spr_d2(i)|base+25..32|8|8; cached plane/color|All bits retained across modes|
|spr_d3(i)|base+33..40|8|8; cached plane/color|All bits retained across modes|
|shift0(i)|base+41..48|8|8; next pixels|All bits meaningful|
|shift1(i)|base+49..56|8|8; next pixels|All bits meaningful|
|shift2(i)|base+57..64|8|8; next pixels|All bits meaningful|
|shift3(i)|base+65..72|8|8; next pixels|All bits meaningful|
|wideclock(i)|base+73|1|1; wide sprite half-shift|Historical phase|

64*74=4736 slot bits. Fixed bits: data_address[13:0] at4736..4749,
m2_flags[7:0]4750..4757, color_reg[3:0]4758..4761,
collide_reg4762, overflow_reg4763, xspr_collide_shift[13:0]4764..4777.
All42 fixed bits remain. Transport adds22 zero high-padding bits and sends75
64-bit words per bank. Restore consumes4778 meaningful bits. Second bank is
serialized as allzero outside System E. No semantic bit or padding check is
removed. Evaluator WAITING/count/index normalization is unchanged from G06.

The22 captured high-padding bits are zero in the serialized final word,but their
register positions hold other meaningful words during64-bit ring rotation.
They are not44 globally dead FF across both banks. A4778-bit partial-tail ring
would need different64/42-bit movement while retaining75 output words;the tiny
storage reduction alone is not substantial recovery and additional wide
selection would need separate synthesis. No padding/register position is dropped.

Source live record -> ARM padded bank ->75 accepted low-word writes/rotations
-> same image -> validated75 LOAD insertions -> bank low4778 -> shared
has_restart -> existing distributed live restore. SAVE returns the complete
ring to its initial value. LOAD shifts out arbitrary Q after75 insertions.

## Candidate families

A: Move SAVE/LOAD selection to one64-bit incoming head and shared shift event;
extract exact bank events from the main FSM. No timing/storage/format change.

B: Centralize live restore would touch VDP receiver topology and many fields.
Possible, but larger proof surface; defer unless lower-risk bank changes fail.

C: Explicit shared bank enable plus mutually exclusive parallel capture/shift
data mask (candidate_B.sv). Preserve clears/reset and every bank clock value.

D: Bank/word arrays could improve locality, but indexed read/write already
failed at39680 needed in G06; avoid rediscovering that crossbar. Constant ring
topology retained for initial candidates.

E: Version decode is already shared (has_restart); do not change compatibility
or claim removal of its unavoidable current/legacy restore selection.

F: Separate scratch register process from live-state representation/main FSM.
Combined with A in candidate_A.sv; all4778 meaningful bits remain represented.

G: Staged restore while frozen is possible but changes intermediate consumed
state and preparation timing. Higher risk; not needed unless structural
alternatives fail. No implementation of this family yet.

H: RAM-backed wide snapshot requires port/banking analysis; parallel capture
and restore are not automatically one M10K. Prefer existing FF state and
shared mux events. Semantic compression is outside preferred scope.

Micro gate: full standalone controller map, same device/seed/performance
settings, virtual ports, no board peripherals. Compare baseline versus A and
C (file candidate_B). These are *mapped* estimates, not fitted board savings.
For the selected path require all-clock95-output and full9600-bit bank miter,
v16/legacy/rejection checks and current integration regressions before fit.
