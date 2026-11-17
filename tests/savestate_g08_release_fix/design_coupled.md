# Coupled source-event and mixer-phase correction

The user's scope amendment explicitly permits the necessary pending PSG
capture/restart correction. F01/G08.FM, G11/G12 and F06 remain excluded. G10's
deterministic divider/CPU preparation contract stays CLOSED and unchanged;
the missing source event is not a new arbitrary-phase release defect.

There are two independent defects. AudioMix uses a transport-time phase after
LOAD and live transport parity after SAVE. Separately, an accepted raw PSG
enable can imply a /16 event at the following falling edge, which freeze
suppresses before generation. The unchanged-v15 witness accepts at clkd10,
pre-divider14/post-divider15. Reference cen_16 becomes1 on the next falling
edge and is consumed at logical T+1; frozen DUT cen_16 stays0. The event is
not already consumed at capture and is lost during the freeze handoff, before
LOAD or CPU preparation is involved.

No new pending-event history bit is needed. Existing v14/v15 metadata records
capture phase, capture_tick_snap and post-T PSG divider. The complete predicate
for the deferred event is:

    capture_tick_snap && phase_snap in {10,25} && audio_div_snap == 15

Accepted phase classes are0/10/20/25; only10/25 clock the raw PSG divider.
Actual capture_tick_snap excludes a logically stopped qualifying Pause capture.
JT89's falling-edge test uses the post-increment divider, so15 (pre14), not
wrap0, selects its /16 event. No accepted phase can have an already-high
cen_16 waiting at T: native generated/consumed positions are11/26. Config/IO
write pipelines have ended before the eligible M1/T2. Thus the predicate is
complete for the production capture contract. Both SystemE chips use the
same enable/divider but independent synthesis histories.

The combined proposal retains existing raw cfg/ext/div capture at late
quiescence. That state is post-T, before the deferred event, because frozen
clk_en already suppresses it. A combinational output qualifies the predicate
with the existing audio_phase_set release strobe. Through SMS/system it reaches
one new JT89 input. At the falling edge before the FIRST resumed rising edge,
this input sets cen_16=1. The next rising edge consumes exactly the original
T+1 event; the strobe clears and the next falling edge resumes the unchanged
ordinary equation. clk_div is not advanced by this replay. No guest clock is
inserted, no tick occurs during transport/CPU preparation, and no raw oscillator,
noise, sample or register payload changes. Ordinary execution remains identical
when the new input is0. Legacy VHDL instances default it to0.

This also preserves sub-clock pipeline history: at T both AudioMix caches have
settled to post-T raw sample values. Restored old sample bits reconstruct the
PSG stereo sums and both mixer outputs while frozen. On the first resumed edge
the replayed oscillator/volume update occurs alongside the same OLD PSG stereo
sum/mixer consumers as uninterrupted T+1. Later registers refill naturally.
Draining the event into the saved sample prematurely, or issuing it during
preparation, would expose a different first sample and is not the design.

The separate mixer correction captures post-T next-channel phase at ARM and
installs it on the first resumed clock for both SAVE and LOAD. There is no
registered partial accumulator. Once old source state/output caches, next
channel and the derived pending event match T+, identical future inputs give
identical state and output transitions by induction, including half-completed
stereo cycles after release. Natural-history full-image searches and real CPU
OUT/pan boundary cases challenge this argument; finite absence of a collision
is not substituted for it.

The proposed v16 header identifies the corrected historical mixer phase. It
reuses descriptor020 bit45 (already allocated) with no payload growth. Existing
v14/v15 restart metadata can also derive a pending PSG event; older formats
without that metadata deterministically use phase0 and no replay. Missing old
mixer phase normalizes to0. No exact unavailable legacy history is promised.

Production scope is five files: savestates.sv for capture/phase/predicate/tag,
jt89.v for the single resume-only cen_16 branch, jt89.vhd for its defaulted
component port, system.vhd and SMS.sv for wiring. No AudioMix arithmetic, raw
state layout, divider recurrence, CPU preparation, VDP or FM synthesis edit.
The existing phase snapshot/strobe and saved metadata supply all storage.
Expected cost is a small decoder/wiring/mux, with zero new historical flip-flops,
RAM or DSP; controlled full fitting must measure actual global placement.
