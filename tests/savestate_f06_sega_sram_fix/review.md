# F06 Sega SRAM savestate completeness

READY TO COMMIT

## 1. Baseline HEAD

`7fcd5e12847eedf9e97a44dc937c3dbac3205f7c`, branch `fix/savestate-f06-sega-sram`. Before editing, all 204 tracked regular files and all 137 retained production build inputs were hashed. See `baseline.json`. Only `rtl/savestates.sv` differs.

## 2. Baseline v17

Committed outer tag `0x484311`. The frozen original controller is `baseline/savestates.sv`. Its OPLL private descriptor remains v17 in the new format.

## 3. Baseline resources

Quartus Lite 17.0.2 Build 602; Cyclone V 5CSEBA6U23I7; SMS/sys_top; seed 1; MISTER_FB=1; fixed BUILD_DATE 261025. Needed 37,175/41,910 (88.702%); placed 38,598/41,910 (92.097%); fitted registers 48,948/167,640; M10K 488/553; memory bits 3,818,050/5,662,720; DSP 39/112. Retained authoritative build: `../savestate_f01_opll_fix/quartus_final`.

## 4. Baseline timing

Worst setup +0.105 ns; hold +0.206 ns; zero failing timing-summary categories. Existing partly unconstrained setup/hold limitation remains relevant.

## 5. Same-ROM contract

Every presented savestate belongs to the currently loaded ROM. No cartridge identity, ownership flag, access-history heuristic, checksum or fingerprint is introduced. Cross-ROM validation is outside this acceptance contract.

## 6. Physical SRAM organization

`SMS.sv` instantiates 32,768 × 8 dual-port live SRAM: physical 0x0000–0x7fff, two 16 KiB banks. `memory_bus` forms the bank bit from `nvram_p and not A14` and retains A13:0; the extended upper window selects bank 0. Persistent storage already transfers 64 × 512-byte sectors.

## 7. Previous F06 failure

The committed controller decides transfer length from mapper enable/size flags. Disabled SRAM transfers zero bytes; the 16 KiB case omits the retained upper bank. The actual old-controller fixture reproduces identical complete 98,304-byte images with physical byte 0 equal to 0x41 or 0x42, followed by different guest reads. [old/simulation0.log](old/simulation0.log)

## 8. v18 definition

Outer tag `0x484312`, existing subtype 3. The tag establishes complete physical SRAM representation; `has_full_sram` is decoded only on current-format LOAD. v17 and older tags retain their previous semantics. All inherited modern payload gates also recognize v18. OPLL descriptor/state layout and all other endpoint payloads are unchanged.

## 9. Complete SRAM representation

Ordinary SRAM mode always carries 4096 64-bit words at DDR slot word offsets 0x0d01–0x1d00, representing physical bytes 0x0000–0x7fff. Existing 96 KiB slot capacity is unchanged. EEPROM mode, nonzero SC RAM mode and System E use their separate established layouts; System E overlaps this address range with video storage and must be excluded. Evolution ordinary backing SRAM is covered.

## 10. SAVE architecture

`transfer_full_sram = (do_save || has_full_sram) && !systeme && sc_size_snap == 0 && !eeprom_present`. This ignores Sega visibility/bank/access history. The existing byte packer streams authoritative live RAM directly through DDRAM. No new RAM, SRAM snapshot, wide restore mux or secondary copy is added.

## 11. LOAD architecture

The accepted v18 tag selects the full physical span. Existing mapper restoration establishes the captured mapping before the SRAM transfer; guest execution stays frozen through all SRAM writes, CPU preparation, state/CRAM restore, flush and deterministic release. The last byte is written before release. Existing ROM restart ordering is unchanged. Focused fixtures verify mapper equality, exact write counts, immutable images and all bytes after each of three LOADs.

## 12. Persistent-save separation

Production `SMS.sv`, dirty tracking, host sector FSM and storage arbitration are byte-identical to baseline. Savestate full-span selection is local to the savestate controller. No savestate operation requests persistent file writes.

## 13. Legacy v17 behavior

Explicit v17 imports restore 0, 16,384, 32,768 and 32,768 bytes for flags 0x00, 0x08, 0x0c and 0x18. Missing bytes retain later live contents, even if an otherwise populated current image tail is present and deliberately poisoned. Missing history cannot be reconstructed; no old unused bytes become valid without v18. Public 64/96 KiB and older development imports remain supported. [legacy/simulation.log](legacy/simulation.log)

## 14. Witness A: enabled

PASS: case0: enabled SRAM. Checked at ready, fixed-backpressure and randomized-backpressure schedules. See [current/final0.log](current/final0.log), [current/final1.log](current/final1.log), [current/final2.log](current/final2.log).

## 15. Witness B: disabled

PASS: case1: disable after writes. Checked at ready, fixed-backpressure and randomized-backpressure schedules. See [current/final0.log](current/final0.log), [current/final1.log](current/final1.log), [current/final2.log](current/final2.log).

## 16. Witness C: bank 0 visible

PASS: case2: bank 0 visible while bank 1 retained. Checked at ready, fixed-backpressure and randomized-backpressure schedules. See [current/final0.log](current/final0.log), [current/final1.log](current/final1.log), [current/final2.log](current/final2.log).

## 17. Witness D: bank 1 visible

PASS: case3: bank 1 visible while bank 0 retained. Checked at ready, fixed-backpressure and randomized-backpressure schedules. See [current/final0.log](current/final0.log), [current/final1.log](current/final1.log), [current/final2.log](current/final2.log).

## 18. Witness E: 16 KiB visible

PASS: case4: 16 KiB mapping with distinct retained upper bank. Checked at ready, fixed-backpressure and randomized-backpressure schedules. See [current/final0.log](current/final0.log), [current/final1.log](current/final1.log), [current/final2.log](current/final2.log).

## 19. Witness F: 32 KiB configuration

PASS: case5: extended 32 KiB mapping. Checked at ready, fixed-backpressure and randomized-backpressure schedules. See [current/final0.log](current/final0.log), [current/final1.log](current/final1.log), [current/final2.log](current/final2.log).

## 20. Witness G: before first access

PASS: case6: host initializes physical storage; mapper reset and SAVE precede guest SRAM access. Checked at ready, fixed-backpressure and randomized-backpressure schedules. See [current/final0.log](current/final0.log), [current/final1.log](current/final1.log), [current/final2.log](current/final2.log).

## 21. Witness H: after access

PASS: case7: guest fills SRAM before SAVE. Checked at ready, fixed-backpressure and randomized-backpressure schedules. See [current/final0.log](current/final0.log), [current/final1.log](current/final1.log), [current/final2.log](current/final2.log).

## 22. Witness I: reset then SAVE

PASS: case8: retained storage survives mapper reset. Checked at ready, fixed-backpressure and randomized-backpressure schedules. See [current/final0.log](current/final0.log), [current/final1.log](current/final1.log), [current/final2.log](current/final2.log).

## 23. Witness J: repeated LOAD

PASS: each of all nine profiles runs three LOADs with fresh complement perturbation. Checked at ready, fixed-backpressure and randomized-backpressure schedules. See [current/final0.log](current/final0.log), [current/final1.log](current/final1.log), [current/final2.log](current/final2.log).

## 24. Witness K: SAVE-only

PASS: each profile checks physical RAM and mapper equality after SAVE. Checked at ready, fixed-backpressure and randomized-backpressure schedules. See [current/final0.log](current/final0.log), [current/final1.log](current/final1.log), [current/final2.log](current/final2.log).

## 25. Full-bank canaries

PASS. Address-dependent, bank-distinct byte patterns cover all 32,768 locations, including 0, 0x3fff, 0x4000 and 0x7fff. DDR word addresses and RAM write addresses/counts are checked exactly once, detecting skipped/duplicate words, wrapping and bank swaps. Physical port scans precede guest-window scans. The fixture models the legitimate stretched FFFC write alias at physical 0x3ffc in extended mode.

## 26. Inactive-bank result

PASS. Both physical banks receive distinct patterns; SAVE occurs with only one selected, both are perturbed, then LOAD restores each byte and later independent guest exposure reads both banks.

## 27. Disabled-SRAM result

PASS. Mapper-disabled SAVE still records all 32 KiB; LOAD restores the disabled mapper state and all physical bytes; later guest enable observes the saved data.

## 28. Before-first-access result

PASS. Host RAM port initialization establishes same-ROM retained contents. No guest SRAM access or eligibility heuristic is used before capture. Subsequent LOAD and guest exposure recover both banks.

## 29. Repeated-LOAD result

PASS. Nine profiles × three transport schedules × three LOADs = 81 full physical restorations. Both banks are perturbed before every LOAD; all image words remain immutable.

## 30. SAVE-only result

PASS physical SRAM/mapper transparency for all nine profiles and all three schedules. Broader CPU/VDP/audio SAVE-only transparency is covered by inherited independent replay fixtures; focused SRAM fixtures model constant legal CPU endpoints rather than a complete top-level CPU run.

## 31. Transport-stall result

PASS. Ready DDR, deterministic busy/read latency, and LFSR busy/variable response schedules all produce exact 4096-word capture and 32,768-byte restoration. Fixed schedule totals: SAVE 113,154 clocks, LOAD 230,408 clocks; randomized totals depend on schedule. These measurements are fixture-specific, not universal DDR bounds.

## 32. Persistent-save regression

PASS actual production persistence FSM + actual mapper, memory_bus and vendor dual-port RAM: automatic and explicit 32 KiB file LOAD, complete 64-sector file SAVE, no savestate-triggered persistence/dirty request, no overwrite on v18 release, and pending savestate held until an in-progress file transfer finishes. [persistence/simulation.log](persistence/simulation.log)

## 33. Existing savestate regression

PASS inherited 28 replay cases: G01 ten instruction histories; G05; G06 sprite collision/overflow and System E; G10 natural phases, deterministic release and flush; G04 pending state; G12 four Pause/System E combinations; six AudioMix/PSG matrix cases. Independent ROM/reference fixtures are retained byte-for-byte. Generated image.hex files are outputs, not independent oracles. F01 actual OPLL seeds 1/10 each replay 192,000 raw samples across three LOADs; raw PSG 128 × 20,000 cycles; EEPROM raw 6,642 cases plus eight actual-controller valid/hidden/invalid cases at two stalls. One old EEPROM READLATCH timing stimulus fails identically on committed v17 and is excluded, with baseline failure retained in eeprom/baseline/simulation.log; no oracle was relaxed. History tests cover all eight NMI encodings, mapper histories and Evolution pending payloads over 24 LOADs. These are protocol/payload checks, not a new reachability proof. The G10 transport stimulus correction is documented in stimulus_revision.md; production-duration flush has a separate gate.

## 34. Shared-transfer proof

PASS ten profiles × three schedules: all four System E video-bank combinations, ordinary SRAM, SC 2/16/32 KiB, EEPROM 128 bytes and Evolution backing RAM. Distinct owners and complete arrays check written prefixes and untouched tails for both VDP memories, WRAM and NVRAM. Full data byte sequencers and addresses are source-identical to v17. [shared/final0.log](shared/final0.log)

## 35. Non-injectivity regression

PASS. v17 complete images for physical byte 0x41 versus 0x42 are identical. v18 complete images differ at exactly byte offset 0x6808 (word 0x0d01), containing that needed SRAM byte, and nowhere else. Both guest futures read the corresponding value. Images and hashes are retained.

## 36. Simulation gate

PASS. 47 clean logs; source SHA256 e8d8836f0c2e63e68c5c82db6195fff9e39a9555f3fa04efdb1f4a955c717b94. See functional_gate.json. Format validation rejects 2,016 malformed images and accepts 400 valid cases; import suite covers 20 imports. Initial-v18 non-EEPROM inherited compiles differ from final source only in the tightened EEPROM exclusion. A 101-output controller miter compares both over 16 profiles, 48 current LOADs plus public formats and 13,600,225 clocks; actual final-source EEPROM valid/invalid tests cover the changed context. Test-only adapters shorten most flush waits and accommodate ModelSim forward declarations/VHDL portability; the separate full production flush passed with all 900,000 clocks.

## 37. Final ALMs needed

37,131 / 41,910 = 88.597%; delta -44 versus committed v17 seed 1. 

## 38. Final ALMs placed

38,450 / 41,910 = 91.744%; delta -148 versus committed v17 seed 1. 

## 39. Final fitted registers

48,899 / 167,640 = 29.169%; delta -49 versus committed v17 seed 1. 

## 40. Final M10K

488 / 553 = 88.246%; delta +0 versus committed v17 seed 1. 

## 41. Final memory bits

3,818,050 / 5,662,720 = 67.424%; delta +0 versus committed v17 seed 1. 

## 42. Final DSP

39 / 112 = 34.821%; delta +0 versus committed v17 seed 1. 

## 43. Final setup slack

+0.366 ns; delta 0.261 ns. 

## 44. Final hold slack

+0.234 ns; delta 0.028 ns.

## 45. Timing violations

0 failing STA summary categories. See early_results.json for each clock/corner slack and TNS. Existing partly unconstrained design means this does not establish timing on every unconstrained path.

## 46. Routing failures

Map, fitter, assembler and STA completed successfully; no routing failure.

## 47. New warning types

None. No normalized new warning message was found. Normalized new/removed warning messages are retained in early_results.json; inherited warnings are distinguished from new types.

## 48. Worst-path analysis

PASS. The paired seed1 build has no failing timing-summary category or routing failure. No confirmation build was needed.

- v17 worst setup: +0.105 ns, `shadowmask:HDMI_shadowmask|dout[20]` → `osd:hdmi_osd|nrdout1[20]` ([path report](baseline_paths_setup.rpt)).
- v18 worst setup: +0.366 ns, `ascal:ascal|o_vacpt[5]` → `ascal:ascal|o_vpixq_pre[2].r[3]` ([path report](early_paths_setup.rpt)).
- v17 worst hold: +0.206 ns, `ascal:ascal|o_poly_phase_b.t1[8]` → `ascal:ascal|o_poly_phase_b2.t1[8]` ([path report](baseline_paths_hold.rpt)).
- v18 worst hold: +0.234 ns, `emu:emu|system:system|vdp:vdp2_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\shifters:31:shifter|shift0[6]` → `emu:emu|system:system|vdp:vdp2_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\shifters:31:shifter|shift0[7]` ([path report](early_paths_hold.rpt)).
- v17 emulation-clock worst setup: +0.635 ns, `emu:emu|sdram:ram|sd_dat[8]` → `emu:emu|system:system|T80s:z80_inst|T80:u0|IR[4]` ([path report](baseline_emu_setup.rpt)).
- v18 emulation-clock worst setup: +0.983 ns, `emu:emu|ce_cpu` → `emu:emu|sdram:ram|q[0]` ([path report](early_emu_setup.rpt)).

The new global worst setup path remains in the unchanged HDMI/scaler framework. The emulation-clock minimum improves by +0.348 ns. These endpoint changes and positive margins provide no evidence of structural critical-path growth from F06. The source-only input manifest proves that the framework, CPU, VDP and audio RTL were unchanged. Realized slack changes include global placement/routing effects; a single paired build does not measure an intrinsic timing benefit from the extra flag. Existing partially unconstrained setup/hold coverage remains unchanged. Detailed reports use the Slow 1100 mV 100 C model; the complete multi-corner STA summary is retained in the build outputs.


## 49. Additional SAVE clocks/time

Ready-DDR fixture: +36,866 clocks (686.605 µs NTSC; 692.925 µs PAL) versus disabled v17; +18,432 (343.284 µs NTSC) versus 16 KiB; zero versus full 32 KiB. Total measured SAVE 65,954 clocks (1228.350 µs NTSC), including common controller overhead with test-fast flush.

## 50. Additional LOAD clocks/time

Ready-DDR fixture: +53,248 clocks (991.709 µs NTSC; 1000.838 µs PAL) versus disabled v17; +26,624 (495.854 µs NTSC) versus 16 KiB; zero versus full 32 KiB. Total measured LOAD 95,481 clocks (1778.271 µs NTSC), with test-fast flush. Production's unchanged 900,000-clock flush adds 16761.907 µs NTSC to that common path.

## 51. User-visible latency assessment

Less than about 1 ms extra at ready DDR for the formerly omitted 32 KiB, with added host wait depending on DDR backpressure. Guest time remains frozen during transfer. Persistent file size and savestate slot capacity do not grow; only the current snapshot occupancy increases. This quantifies the correctness cost rather than an end-to-end host/UI latency promise.

## 52. Resource assessment

PASS. One decoded format-presence flag and existing sequential transport are used. Synthesis registers change 46289 → 46290 (+1); fitted registers change 48948 → 48899. M10K delta 0; memory-bit delta 0; DSP delta 0. No additional 32 KiB FPGA copy is inferred. Packing identity: baseline 38598 − 1955 + 532 = 37175; v18 38450 − 1964 + 645 = 37131. Logic ALUT delta -304; routing ALUT delta 21. Treat the realized reductions as compiler optimization and placement variation. The structural change adds one control register. Remaining physical ALM sites: 3460; remaining M10Ks: 65. Utilization remains high enough to require controlled builds for subsequent work. No timing confirmation was needed; only seed1 was built.

## 53. Final correctness gate

F06 CLOSED under the same-ROM contract. Complete physical SRAM representation and restoration, disabled/inactive/before-access cases, repeated LOAD, SAVE-only transparency, persistence, shared transfers and relevant inherited regressions pass. Resource and timing gates pass in the paired seed1 production build. No cartridge-identity heuristic was introduced.

## 54. Final classification

READY TO COMMIT

## 55. Recommended next step

Review the single production diff and retained evidence, then decide whether to commit. No commit has been made.

## 56. git diff --stat

```text
rtl/savestates.sv | 34 ++++++++++++++++++++++------------
 1 file changed, 22 insertions(+), 12 deletions(-)
```

## 57. git status --short

```text
M rtl/savestates.sv
?? tests/
```

Nothing staged: `git diff --cached --stat` is empty. HEAD is unchanged. No commit, push or PR. No framework, ownership, fingerprint, FM investigation or format-consolidation production changes. Tests and generated build evidence remain untracked under the pre-existing untracked tests tree.
