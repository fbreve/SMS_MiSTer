# F02: local Game Gear IO/protocol savestate coverage

Base: committed F07 `60c6552`, branch `fix/savestate-gg-io`. This change addresses only F02/S064–S066. F03/F04 EEPROM, CPU NMI acceptance, and other audit findings remain outside scope. No commit, push or PR is authorized or performed.

## Contract and root causes

All persistent state **local to the implemented GG IO endpoint** must be preserved under identical future CPU/external inputs. A physical peer and host inputs are not rewound. Restoring a local endpoint while its remote peer has advanced can naturally produce a different subsequent exchange. Tests use an identical deterministic external input stream, and do not claim physical cable replay equivalence or certify the separate CPU interrupt-state finding.

The old 32-bit IO vector contained ctrl, SC paging/PPI and System E selectors/enables, but no GG registers or local serial state. Its restore never wrote those GG values. In addition, GG read-clear effects and TX-write edge history were not held by ss_freeze; restoring a status value alone would not keep it stable through the frozen flush if a bus read remained asserted. CPU enables alone were insufficient to hold every GG assignment.

Before RTL changes, the existing real-port PDR fixture reproduced saved35 -> write6a -> load -> read6a on the committed F07 base. Expanded pre-fix characterization found divergence in **24/24** reachable baud/phase scenarios, including DDR/TXD/control/status, RXD=5a versus resetff, pending TX, frame error/completion and local NMI behavior. Four baud divisors745/1491/2982/11931 were exercised at transfer start, half-bit timing, intermediate bits, RX completion and idle after pending TX completion. The corrected-expectation baseline fails with17,911 differences in its first scenario. `pdr_before.log`, `before.log` and `before_expected_failure.log` preserve the evidence. No internal state was forced to create failures: configuration, traffic, perturbation and reset used ordinary entity ports.

## Exact local inventory

`inventory.json` and `inventory.csv` provide individual widths, bit positions, reset values and classifications. There are **24 preserved fields / 114 meaningful bits**, ten derived/read-pipeline items (B), three grouped external input/configuration entries (C), and one dead bit (D). No local GG state remains classified E. The existing shared ctrl register remains covered by the unchanged low32 IO image.

| Field(s), classification A | Width | Payload bits | Legacy normalization |
|---|---:|---|---|
| gg_ddr | 8 | 7:0 | ff |
| gg_txd | 8 | 15:8 | 00 |
| gg_rxd | 8 | 23:16 | ff |
| gg_pdr | 8 | 31:24 | 7f |
| gg_sctrl(7:3) | 5 | 36:32 | 0 |
| gg_tx_line / gg_tx_busy | 1 / 1 | 37 / 38 | 1 / 0 |
| gg_tx_shift(9:1) | 9 | 47:39 | all ones |
| gg_tx_cnt / gg_tx_bits | 14 / 4 | 61:48 / 65:62 | 0 / 0 |
| gg_tx_pending / gg_tx_pending_data | 1 / 8 | 66 / 74:67 | 0 / 0 |
| gg_rx_sync / gg_pc6_sync / gg_pc6_prev | 3 / 3 / 1 | 77:75 / 80:78 / 81 | 111 / 111 / 1 |
| gg_rx_state / gg_rx_cnt / gg_rx_bits | 2 / 14 / 3 | 83:82 / 97:84 / 100:98 | 0 / 0 / 0 |
| gg_rx_shift | 8 | 108:101 | ff |
| gg_rx_ready / gg_rx_frame_err | 1 / 1 | 109 / 110 | 0 / 0 |
| gg_nmi_serial / gg_nmi_pc6 | 1 / 1 | 111 / 112 | 0 / 0 |
| gg_tx_wr_d | 1 | 113 | 0 |

The serial control bits all have implemented consumers: baud, RX/TX enables and interrupt enable. Separate NMI source latches must be preserved even when the OR output masks one source, since RX-data reads and DDR writes acknowledge different sources. Synchronizer history is **local stored state**, not equivalent to sampling current peer pins anew. Pending data, shift position and countdowns likewise affect later outputs under identical future pins.

Port00's pause/region/PAL response is derived from external inputs. Port06 reads a constant ff in io.vhd; its stereo-balance write is implemented in system.vhd as PSG_mux and is already carried by the existing audio-control extension. It is not a missing second copy of local GG serial state. The PSG regression remains separate and passing.

Classification B: gg_status, gg_baud_div/half, gg_pc_drive_en/val/read/in_mux, gg_link_out and gg_link_nmi_n are combinational results of restored registers and current inputs. Registered D_out is refilled by the next valid IO read before CPU consumption; it has no feedback into GG protocol state. Guest read comparisons allow its existing clocked read latency. Classification C: gg_link_in, host pause/region/pal and link-enable configuration remain external. CPU bus/enables come from the surrounding machine rather than this endpoint image.

Classification D: **gg_tx_shift(0)** is discarded by every shift and never consumed by the transmitter/output logic. Only bits9:1 are serialized; bit0 is restored zero. This does not change the normal transmit shift equation or output timing. All other initialized GG registers have implemented future consumers; none was dismissed because it changes frequently or is later overwritten.

## Format, wiring, atomic restore and legacy behavior

The 32-bit IO image and the original128 VDP register bits are unchanged. The separate GG image is128 bits with bits113:0 above and **127:114 reserved zero**. It travels through io.gg_state_out -> system -> SMS -> savestates.gg_out -> gg_snap; the reverse route uses gg_in and a one-clock gg_set/gg_state_set strobe. The snapshot is captured alongside the existing IO snapshot at ST_ARM_FREEZE. Restore happens with the other live register images while frozen. GG restore assignments have priority on that edge; GG protocol updates, RX read-clear and TX write-history changes hold until release.

F07's video-word extension is extended to **version2**, rather than introducing another unrelated descriptor/tag:

| DDRAM word/bits | Representation |
|---|---|
| 01a[63:40] | `24'h484302`, HC family version2 |
| 01a[39:38] | GG payload length, exactly2 64-bit words |
| 01a[37:30] / [29:22] | Existing HCounter2 / HCounter1 bytes, unchanged positions |
| 01a[21:0] | Existing video state |
| 01c | GG payload63:0 |
| 01d | GG payload127:64; high14 bits must be zero |

The two words were outside the previously written payload and before VRAM101; they do not overlap EEPROM01b, Evolution fields019/01b, PSG020–024, any memory DMA range or another slot. Two accepted write/read transactions and two FSM states are added. Slot size/header size remain unchanged. Sequential commands and the accepted-request preview both implement the same routes. The words are written in all modes, preserving local endpoint history across mode transitions; inactive GG outputs remain gated as before. GG presence is established only by the supported full tag **and** exact length; random older bytes at01c/01d are never consulted without it.

Accepted F07 version1 (`484301`, reserved00) retains exact HCounter behavior but has no GG payload. Older untagged96KiB and the oldest64KiB path likewise have no GG payload. At every load start GG snapshot defaults to `128'h00001fe00003f8000000ffa07fff00ff`, the reset values in the inventory, with the one dead bit normalized. Missing/invalid tag, unsupported version, invalid count and invalid payload padding therefore normalize the **entire** local GG endpoint deterministically. No field retains the discarded future timeline, and no serial progress is invented. External inputs can still affect pin reads after reset normalization. The new GG restore strobe also runs for64KiB loads, which deliberately skip ordinary IO restoration; no legacy SMS/SC fields are reset merely to normalize GG.

This is backwards compatibility of the **new loader reading old snapshots**. A F07-only older loader does not understand version2 and cannot recover its extended fields; forward-reading new snapshots on an old core is not promised. In particular, the old F07 reader's absent-tag fallback applies to the new tag. Version1 reading remains explicitly tested in the current core.

There is no independent file-length signal on the DDRAM interface. Invalid declared length and nonzero reserved payload bits are representable and tested. A truly absent DDRAM response remains governed by the existing read watchdog; checksum detection of arbitrary silently substituted payload data is not introduced here. A valid tag alone cannot validate arbitrary corruption of otherwise valid-width state, consistent with the existing savestate transport contract.

## Verification

* `after.log`:24 deterministic local reference replays, four baud rates and six phase/error combinations. DUT reset/guest writes perturb the timeline while reference holds. Restore matches all114 serialized bits, local pins/NMI and guest reads. Each future protocol cycle is compared for24 bit periods, covering pending TX drain, RX completion/error/status transitions and idle. Held RX reads while frozen do not clear restored status. A second save/load of the evolved point, reset after restore and a new complete TX transaction also pass. No internal latch force is used.
* Original F02 PDR test now expects35 after perturbation to6a and passes. Its fixture/generator alone was updated to connect the new GG state interface; EEPROM/MD expected-defect tests are unchanged and still reproduce their known findings.
* `integration.log` and `integration_stalls.log`: actual production IO and full savestate FSM with mock DDRAM, ordinary fields plus a reached/asserted TX-busy, pending-TX and RX-progress point. Saved fields pass through actual words01c/01d, are restored into live IO, and match an uninterrupted endpoint under identical subsequent pins for250,000 system clocks. Twelve modern/legacy/invalid/non-GG cases check exact normalization and preserved low IO fields. SMS, System E, SG and SC cases verify ordinary IO values and inactive GG outputs. The stalled version holds requests busy for deterministic intervals and returns delayed read data. CPU/memory/video data are fixtures; this is an endpoint/storage integration regression, not a game replay or physical-peer rewind.
* F07 tests: SMS/GG real latch/read/reference tests pass unchanged. Controller assertions were adapted for the version2 writer, and an additional version1 case preserves5a/a5. The real dual-VDP/controller integration is rerun with the new transport and legacy fallback.
* PSG replay:128 cases /2,560,000 compared clocks pass. Existing EEPROM and MD6 audit reproductions remain failures of those features, as expected; no code or test was altered to conceal them.
* Static checks: all24 GG fields have matching packing/unpacking ranges;14 reserved bits and reset constant agree; original IO32 packing is identical; VDP, cart_eeprom and eeprom_93c46 sources match the F07 base. The existing audit checks run into a separate output directory, preserving its historical report/hashes.

ModelSim10.5b uses the same simulation-only declaration relocation for the controller's two pre-existing forward references as F07. Expressions/processes are unchanged. IO itself is compiled directly from production. F07 RAM-model initialization generic is UNUSED for simulation only; no VDP RTL edit is made. Starter capacity warnings are performance warnings, not new RTL failures. Check log Failure/Fatal/Error markers as well as PASS text: old ModelSim can return shell status0 on a VHDL assertion break. The intentionally failing baseline log is retained separately.

## Reproduction

From tests/savestate_gg_io (Node and the established Quartus/ModelSim17.0 environment):

```powershell
& 'C:/Program Files/nodejs/node.exe' prepare.js --baseline
$env:GG_FIXED='false'
& C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe -c -do 'do gg.do' -l before.log
& 'C:/Program Files/nodejs/node.exe' prepare.js
$env:GG_FIXED='true'
& C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe -c -do 'do gg.do' -l after.log
# controller_model.sv.in contains the established DDRAM fixture model.
& 'C:/Program Files/nodejs/node.exe' prepare_integration.js
& C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe -c -do 'do integration.do' -l integration_stalls.log
& 'C:/Program Files/nodejs/node.exe' static_checks.js
& 'C:/Program Files/nodejs/node.exe' results.js
```

baseline contains the untouched committed-F07 inputs, copied before edits. candidate is an isolated copy of the final production inputs. Neither build tree, simulator library nor generated temporary controller copy is a proposed source change. F07_reference.json and the copied fit/STA summaries preserve the existing successful F07 build after verifying its source hashes against committed F07. Build-ID pre-flow generation uses the same date. Tool/device/qsf/seed are unchanged; the temporary Z: mapping avoids the established old-Tcl Documents-path issue. Evidence hashes and final comparison are recorded in results.json. The local controller model reproduces the tested integration fixture byte-for-byte without depending on a generated fixture in the F07 directory.

## Final review / Quartus

**READY TO COMMIT** after the user's requested review. F02's local-state contract is implemented and verified, the F07 regressions pass, compatibility is explicit, and the complete production diff addresses no other finding. VDP/HCounter and EEPROM production sources remain unchanged. No commit, push or PR has been made.

Quartus17.0.2 Build602 completed synthesis, fitting, timing analysis and assembly successfully, using the established device/qsf/seed1 environment. Candidate compilation took24:34. All reported timing categories have nonnegative slack and zero TNS: **zero reported timing violations**. Source hashes verify that the compiled production files match the final working copies. The comparison baseline is F07, not pre-F07 master.

| Metric | Committed F07 baseline | F02 | Delta |
|---|---:|---:|---:|
| Worst setup slack | 0.354 ns | 0.434 ns | +0.080 ns |
| Worst hold slack | 0.188 ns | 0.153 ns | -0.035 ns |
| Core clk_sys setup | 0.862 ns | 0.434 ns | -0.428 ns |
| Core clk_sys hold | 0.188 ns | 0.245 ns | +0.057 ns |
| Fitted ALMs | 26,532 | 26,656 | +124 (about0.47%) |
| Fitted registers | 35,817 | 36,100 | +283 (about0.79%) |
| Synthesis registers | 34,888 | 35,158 | +270 |
| Block memory bits | 3,809,858 | 3,809,858 | 0 |
| RAM blocks | 487 | 487 | 0 |
| DSP blocks | 39 | 39 | 0 |
| Normalized distinct critical warnings | 38 | 38 | 0 new |

Both builds report100 warnings. Comparison of normalized numbered warning messages found **no new warnings**, including no new critical warnings. Existing power-up/assignment/constraint warnings remain; this is not a warning-free-project claim. The small fixed-state increase is reasonable for the114-bit live-state restore/snapshot paths and extension control; synthesis/fitter counts include optimization and duplication effects, not just payload-bit counts. RAM/DSP usage and slot size are unchanged. Timing optimization was not attempted: all required margins remain positive.

Production files changed:

* `rtl/io.vhd`: GG payload packing/atomic restore and freeze holds for local protocol/side effects.
* `rtl/savestates.sv`: version2 header, two payload transfers, validation, deterministic legacy image and GG restore strobe.
* `rtl/system.vhd` and `SMS.sv`: route the GG state interface.

Focused assets created under this directory include inventory JSON/CSV, this review, direct and integration fixtures, preparation/static/result scripts, the local DDRAM-model template, before/after/legacy/stalled/regression logs, verified F07 baseline evidence, candidate fit/STA summaries, results/hashes, and production diff/status/stat snapshots. Generated build trees and simulator libraries are ignored. The original F02 PDR fixture/generators were updated to assert the correct restored value through the new interface. F07 controller/integration generators were adapted for version2 and an explicit version1 case; their latch/read RTL tests and expected correctness were retained. Other audit tests were not changed to conceal known failures.

Legacy fixtures are synthetic images matching the established layouts. They deliberately leave stale valid GG payload words behind when stripping/changing the metadata, and leave a valid version2 tag in the skipped region of a64KiB image. This verifies absence handling; it is not an exhaustive historical game-state compatibility certification.

Final `git diff --stat` (tracked production changes only; test assets remain untracked):

```text
 SMS.sv            |  8 +++++++
 rtl/io.vhd        | 62 ++++++++++++++++++++++++++++++++++++++++++++++++
 rtl/savestates.sv | 71 ++++++++++++++++++++++++++++++++++++++++++++++++++-----
 rtl/system.vhd    |  7 ++++++
 4 files changed, 142 insertions(+), 6 deletions(-)
```

Final `git status --short`:

```text
 M SMS.sv
 M rtl/io.vhd
 M rtl/savestates.sv
 M rtl/system.vhd
?? tests/
```

The tests tree was already untracked at task start. Nothing is staged, including no Quartus artifacts. `git diff --check` passes. Next step: review and, when authorized, commit only the F02 production changes and appropriate focused/shared test assets. The external peer remains outside the snapshot, and the other audit findings remain open.
