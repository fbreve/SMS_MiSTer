# Proven correction: accepted-T last mixed channel

Decision C: G08.FM CONFIRMED - MINIMAL FIX REQUIRED.

At the reproduced accepted T, raw FM changes 0x3e14 → 0x3e65. The existing
AudioMix phase selects left at T and consumes the old input, leaving left
0xf0a0. T+1 selects right and consumes the new input 0xf328. Uninterrupted
output is therefore 0xf0a0/0xf328. v18 refills both caches with 0xf328 before
release and returns 0xf328/0xf328. Raw OPLL, PSG, native enables and mixer
phase match. The difference occurs once at k0 on SAVE and each of three LOADs.

The old sample has no post-publication OPLL consumer: mixout is overwritten,
the partial sum is cleared and previous carrier contributions have already
been replaced in the output memories. F01 correctly preserves the post-T
OPLL machine. Reconstructing its discarded previous output from nonlinear
synthesis history has no established general inverse. One pending-event bit
would identify the edge but would not recover the old mixed value. Deferring
capture would change the legal boundary set and leave existing v18 images at
this boundary without the missing history. Broad output/OPLL serialization
is unnecessary.

A cache-only deposit using the naturally observed T values eliminates the
failure without changing OPLL state, valid events, PSG state or phase. A second
causal run deposits only the channel retained at T+1: all 192,000 compared
host pairs pass. An isolated implementation likewise passes SAVE and three
LOADs against the independent unmodified OPLL oracle.

At ARM (T+1 before its edge), capture exactly the channel selected at T:
post-T next phase=1 selects audio_l, next phase=0 selects audio_r. Store that
16-bit last sample alongside the already preserved post-T next phase. At the
first resumed host edge, perform the usual selected-channel update and load
the other channel from the saved last sample. Subsequent edges are unchanged.
Thus both output registers equal the uninterrupted machine at k0; exact F01
state plus the existing G08.release phase/event contract gives equal future
transitions. This stores one output cache, with no duplicate output bank.

v19 outer tag is 0x484313. Audio extension version2 keeps the same word count
and places this sample at word022[47:32]. Bits63:48 remain zero; PSG1 still
uses bits31:0 of that word and PSG2 word024 retains its full zero upper32.
Version1 is accepted with its old zero-padding rules. The outer tag must
agree with the extension version before guest restoration; older tags cannot
reinterpret spare bytes as history. FM's private v17 descriptor and 104 rows,
Sega SRAM full32KiB semantics, all G08.release phase/PSG event semantics and
container size are unchanged. Old images use the documented old reconstruction;
they cannot reproduce this newly represented first-pair history exactly.

Production scope is four files: savestates, AudioMix and their SMS/system
wiring. There is no OPLL architecture change, raw PSG change, framework change,
resource optimization or format consolidation.
