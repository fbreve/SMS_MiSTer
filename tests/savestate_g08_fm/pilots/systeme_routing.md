# Excluded System E isolation-option pilots

Random seeds105 and115 originally selected `FM_ONLY=1` because the generic
selector used seed parity. Both are System E programs (`seed % 5 == 0`).
System E does not route FM to AudioMix: it routes PSG2. In the retained fixture,
`FM_ONLY` zeroes the first PSG input, but the DUT's System E second-input branch
still routes actual PSG2. The reference second-input branch additionally
zeroes that input when `FM_ONLY=1`. This option combination therefore compares
two different input networks, even without SAVE/LOAD.

Seed105 shows actual `0ff0/0ff0`, expected `0000/0000`, at k0 and throughout
SAVE-only. All48,000 raw FM, PSG, counter and phase checks pass. Seed115 has the
same invalid option combination. Their original logs, references, ROMs and
SAVE images are retained in `random_capture_105_misrouted/` and
`random_capture_115_misrouted/`. Neither is a passing proof run.

The corrected campaign uses `FM_ONLY=0` for every System E seed and the actual
dual-PSG route in both machines. FM remains hidden but its complete state,
execution counter, publication event and raw output remain checked exactly.
Ordinary SMS programs retain the alternating FM-only/mixed-source selector.
Both references and replays are regenerated for the corrected input option;
all state/event/audio assertions remain enabled. No production RTL or
simulation DUT implementation changes were made for this correction.
