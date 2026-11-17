# F16 CPU NMI savestate implementation

READY TO COMMIT. Branch fix/savestate-cpu-nmi; committed F15 baseline d1df590. No commit, staging, push, PR or unrelated finding implementation.

## 1. Exact root cause

The 230-bit CPU architectural image omits pending NMI_s, selected-entry NMICycle and the edge detector’s OldNMI_n. DIRSet clears pending/entry, while live post-save sampling can retain unrelated Q history. Complete v11 images are non-injective, so reconstruction is impossible.

## 2. Canonical capture

At accepted MC1/T2 clock T, architecture remains A^- and normalized history is (P OR (Old AND NOT NMI_n), C, NMI_n). C is unchanged on this eligible T2. IO/GG capture at T+1 contains post-T G^+. See contract.md and the authoritative ../savestate_cpu_nmi_capture/review.md.

## 3. Three-bit state

Bit2=P=NMI_s, bit1=C=NMICycle, bit0=sampled OldNMI_n, all normalized for the same semantic instant. All eight normalized triplets are exercised.

## 4. No fourth event bit

The coincident sample is folded into pending and sampled Old together. A historical edge has already been consumed by normalization; replaying another historical input sample would duplicate it. Restart phase/validity controls are protocol state, not additional saved event history.

## 5. GG and DIRSet ordering

Hold sampling throughout LOAD. Restore architecture with DIRSet and post-T GG together. Wait for DIRSet to fall and GG to settle. Install canonical triplet with CPU CEN=0. Return CPU memory ownership; execute CPU-only normal-rate T1 then historical T2, holding GG and sampling. Resume the sampler on the following logical T+1. First ordinary execution sees the saved pending/entry and current settled input, never a replay of H(T).

## 6. Pre-fix non-injectivity

Mandatory pre-edit reruns passed their expected-failure gates. Two full 12,288-word v11 images are identical: SHA256 795f07e3665159fba2513553891db7b71748090e63020d02f84e11d59f0bfde3. Distinct pending history requires different handler behavior. baseline/ retains images and logs; pre.out records six gates.

## 7. Pre-fix real T80

Four expected-failure scenarios (accepted pending, causal ordering, capture-edge pulse, held edge) each execute three actual LOADs. Reference handler counter=1; restored counter=0. The two remaining pre-runs produce the complete-image pair.

## 8. Implementation architecture

Expose normalized history from T80 and a separate temporal restore port. T80s sequences installation and T1/T2 restart with a two-bit phase controller; system holds IO/GG through this preparation. Savestates captures three bits, validates v12 and inhibits live sampling during LOAD. Architectural register restoration and normal NMI execution remain otherwise unchanged.

## 9. Files changed

Production: SMS.sv, rtl/T80/T80.vhd, rtl/T80/T80s.vhd, rtl/system.vhd, rtl/savestates.sv. New evidence, scripts, fixtures and isolated build are under tests/savestate_cpu_nmi_fix/. Existing investigation and prior-fix artifacts are preserved.

## 10. v12 payload layout

DDRAM word0x005: bits40=NMI_s,39=NMICycle,38=OldNMI_n; bits37:0 retain Z80 REG[229:192]; bits63:41 zero. Words2–4 unchanged. Word0x01a bits63:40=0x48430c,39:38=3. All existing v1–v11 locations and fields, including EV11 descriptor/pending payload, are inherited. No extra DDR words.

## 11. Validation

Only tag48430c enables historical NMI restore. Reject v12 subtype0/1/2 or any set word5 padding bit63:41 before guest state writes. All 23 padding positions and three bad subtypes are tested; 30 rejected LOAD requests total. Existing Evolution ownership/descriptor validation remains enforced. Tagged images defer the existing early lightgun clear until ST_LOAD_EE_DESC, after validation; untagged files retain their early clear because they bypass that state. The rejection monitor checks connected guest-state strobes including lightgun, RAM, CPU, mapper/Evolution, IO/GG, VDP and audio. The remaining peripheral restore states are unreachable on that rejection path.

## 12. Legacy normalization

Untagged 64KB and v1–v11 clear pending/entry and sample Old from the settled current NMI input after GG restoration. Ignore arbitrary old unused CPU bits. Historical events absent from old images cannot be recovered. Current host input remains external; no pin is driven from saved history. Old readers do not support exact v12 NMI replay; some permissive non-Evolution readers may load older fields while dropping NMI history. The retained F15-reader format suites directly confirm v12 rejection for Evolution and permissive older-field fallback for non-Evolution; that fallback does not implement NMI history. Genuine v1 subtype0 and v2 subtype2 are rechecked on real CPUs for both sources. In the v2 GG case, arbitrary stored111 is ignored and the installed tuple is000 from the settled low GG input, even though the original v12 captured tuple was001. All three replays retain counter0, proving that this normalization does not invent a falling edge.

## 13. Post-fix image pairs

Four whole-image comparisons differ only at word5: inactive/pending, inactive/entry, pending/both, held/released sampled Old. Each matching valid-v12 replay follows its own independent uninterrupted reference. simulation_results.json contains hashes, exact differing addresses and metadata values.

## 14. Real T80 post-fix

174 exact actual LOADs compare PC, SP, all230 architectural bits, temporal NMI state, active bus transfers, GG/IO, handler counter/signature and final guest result. 1.044.174 host-clock comparisons and 1.425.408 final WRAM-byte comparisons pass. Handler execution occurs at the reference semantic point, including zero/one/multiple-entry scenarios.

## 15. Capture-edge pulse

First sample at accepted T is normalized into pending; the pulse is released before LOAD. Actual three-LOAD handler replay equals reference with external input inactive. SMS pause and GG-source timing paths are covered.

## 16. Held-level input

Low input held through LOAD reproduces the historical handler once, with saved Old low preventing a duplicate edge. Repeated perturbations do not leak Q history.

## 17. Timing sweep

157 established timing conditions execute actual SAVE-only against an independent reference in the same simulation. In addition, 55 focused replay scenarios execute three LOADs each. Two DDR-stall replay scenarios and one both-flags/released scenario extend the exact-load total to174. cases.json enumerates inputs and accepted-relative timing.

## 18. Edge/level matrix

Inactive, already asserted, first sample at T, deassertion around T, pulse ended before LOAD, held through LOAD, pending, consumed, active entry and simultaneous pending/entry are covered. All eight normalized triplets occur; both-released fills111.

## 19. GG interaction

Real production IO/GG is connected, including PC6 source and first effective GG-generated NMI around T. GG restoration and historical NMI installation remain distinct. Exact GG state and handler traces match reference through restart; stalled-GG replay also passes.

## 20. DIRSet tracing

Logs trace DIRSet, frozen/hold flags, saved triplet/validity and restart MC1/T1,T2. Assertions prohibit a write or advanced entry during preparation. Complete post-T2 equality and subsequent host-clock replay prove the canonical metadata survives DIRSet and no historical sample is repeated.

## 21. Repeated LOAD

174 valid-v12 LOADs use three Q perturbations per scenario, including different intervening NMI activity. Every replay restores the same saved history and its independent reference behavior. 72 legacy LOADs separately verify normalization.

## 22. Save-only equivalence

106.000 enabled-tick comparisons across265 runs pass. SAVE normalization is observational and does not change live execution. Equivalence uses identical logical future pin sequences; this does not claim frozen wall-clock host input or live-peer serial traffic is serialized.

## 23. No premature execution

During GG restoration, DIRSet and transfers CPU CEN remains stopped. Metadata installation forces CEN0; T1/T2 restart assertions allow no early memory write or NMI entry. Handler PC/SP/bus/memory then match uninterrupted reference at every replay clock.

## 24. Established regressions

37 established runtime groups pass:19 CPU/F12–F15,5 mapper/EEPROM/SC,11 HCounter/SystemE/GG/MD6/Tap/Paddle/Lightgun/PSG,2 format/compatibility suites. Copied fixtures use current RTL and qualified VHDL entity declarations for ModelSim. Inactive mock NMI is tied001; actual CPU uses new restore protocol. Writer expectations use v12; unsupported future-tag test uses v13. Legacy malformed-length fallback fixtures explicitly retain v11 tag, while v12 malformed subtypes are rejection tests. Copied SRAM MIF relative path is corrected. Untagged fixture clears the modern PSG presence flag and absent high CPU fields. No assertion was weakened to accept a mismatched guest replay. Additional validation passes three real-T80 v11 Evolution LOADs with arbitrary unused CPU bits and two unchanged F15-reader format suites (40 runtime groups including these additions).

## 25. F06

F06 remains intentionally unresolved. No work on F01–F15 production behavior.

## 26. Quartus synthesis/fitter

Full established Quartus17.0 compile completes successfully from a source-only isolated candidate, with no reused DB/output. F15 manifest is verified against committed d1df590 (134 tracked sources plus2 unused retained backup inputs); current source hashes match candidate build inputs. The generated build-date header follows the existing script. Final candidate QSF mode: unchanged. qsf_flow.json and verify_qsf.js check the original QSF or exact expansion of unchanged sys/sys.tcl, sys/sys_analog.tcl and files.qip assignments, allowing only whitespace and the tool’s HPS-location spelling normalization. Every other manifested source remains byte-identical to the prepared build input; production/root QSF is unchanged. An initial invalid attempt produced QSF-change errors125085 and module error293007. Superseded-launcher interference was suspected but not conclusively established: multiple quartus_map children also occur normally in a single run. The invalid attempt is retained under failed_overlap/ (a historical directory label, not proof of cause). All compiler processes were confirmed stopped before the canonical candidate was recreated from source and the complete flow rerun serially. Only the final canonical build supplies these results.

## 27. Worst slack

Setup 0.54ns; hold 0.246ns. Committed F15 setup 0.358ns, hold 0.203ns.

## 28. Timing violations

0 timing summary checks with negative slack/TNS. Full STA summaries retained.

## 29. ALMs needed

27,416 / 41,910 = 65.416%; delta +28 (0.067 percentage points; 0.102% relative to F15).

## 30. ALMs placed

32,784 / 41,910 = 78.225%; delta +92 (0.220 percentage points; 0.281% relative to F15).

## 31. Fitted registers

36,840 / 167,640 = 21.976%; delta +24 (0.014 percentage points; 0.065% relative to F15).

## 32. M10K

487 / 553 = 88.065%; delta +0 (0.000 percentage points; 0.000% relative to F15).

## 33. Memory bits

3,809,858 / 5,662,720 = 67.28%; delta +0 (0.000 percentage points; 0.000% relative to F15).

## 34. DSP

39 / 112 = 34.821%; delta +0 (0.000 percentage points; 0.000% relative to F15).

## 35. Most constrained requested resource

M10K has the highest utilization among the six requested resources (88.065%). LAB occupancy is reported separately and must not be confused with ALMs placed. The specified register denominator includes primary and secondary ALM register positions, while the fitted count also includes IO registers; dedicated/IO subtotals are retained in results.json.

## 36. Warnings and resource sanity

Distinct warnings 84→84; critical 38→38. New warnings: 0; added connectivity sections: 0. New warning details: []. resource_analysis.json provides synthesis entity counts, register ledger, per-entity ALM deltas and placed−recoverable+unavailable reconciliation. Snapshot muxing adds only three word5 data bits, restore muxing adds only the three temporal inputs; version validation and two-bit restart control are bounded. Physical packing is evaluated independently from ALMs needed; see the resource ledger below.

The eight new source-declared registers are three snapshot bits, valid/padding/hold controls, and two restart-phase bits. Synthesis adds nine mapped registers: the existing cur_bios_mode is no longer merged with cur_magic[0], with its reset/capture assignments unchanged. Prefit controller ALUTs increase 5346→5399 (+53); CPU own ALUTs 852→858 (+6), wrapper 16→20 (+4); CPU own registers remain 216. Fitted controller registers increase 4829→4835 (+6), wrapper 31→33 (+2), the unchanged T80 register-file implementation decreases 137→136 (-1), and other physical entity changes sum +17, reconciling the total +24. These physical mapping changes do not change the emulated register-file definition.

The existing Evolution snapshot mux remains 11:1, 60 bits, 420 estimated LEs; the DDR write bus stays 64bits and only three former padding bits carry new data. Restore muxing adds only three temporal inputs. Version/padding checks and hold/restart control add no RAM or DSP.

Whole-design packing reconciles exactly: ALMs needed=placed−recoverable+unavailable; F15 32692−5601+297=27388, F16 32784−5670+302=27416. Delta 28=92−69+5. Logic ALUTs increase 73 and routing ALUTs 190. Placed ALMs rise only 92 (0.281% relative to F15), with no substantial unexplained placement increase. No unrelated RTL or fitter optimization was performed.

## 37. git diff --stat

```text
 SMS.sv            |  6 +++++
 rtl/T80/T80.vhd   | 25 ++++++++++++++----
 rtl/T80/T80s.vhd  | 34 +++++++++++++++++++++---
 rtl/savestates.sv | 79 +++++++++++++++++++++++++++++++++++--------------------
 rtl/system.vhd    | 11 ++++++--
 5 files changed, 116 insertions(+), 39 deletions(-)
```

## 38. git status --short

```text
 M SMS.sv
 M rtl/T80/T80.vhd
 M rtl/T80/T80s.vhd
 M rtl/savestates.sv
 M rtl/system.vhd
?? tests/
```

## 39. Recommendation

READY TO COMMIT. All required simulation/build gates pass; only F16 production scope changed. Nothing staged or committed.

## Resource ledger

| Resource | F15 | F16 | Capacity | F16 utilization | Delta |
|---|---:|---:|---:|---:|---:|
| ALMs needed | 27,388 | 27,416 | 41,910 | 65.416% | +28 |
| ALMs placed | 32,692 | 32,784 | 41,910 | 78.225% | +92 |
| Fitted registers | 36,816 | 36,840 | 167,640 | 21.976% | +24 |
| M10K | 487 | 487 | 553 | 88.065% | 0 |
| Memory bits | 3,809,858 | 3,809,858 | 5,662,720 | 67.28% | 0 |
| DSP | 39 | 39 | 112 | 34.821% | 0 |

```json
{
  "synthesis": {
    "savestates": {
      "baseline": {
        "aluts": 5346,
        "registers": 4827
      },
      "candidate": {
        "aluts": 5399,
        "registers": 4834
      }
    },
    "evolution": {
      "baseline": {
        "aluts": 62,
        "registers": 175
      },
      "candidate": {
        "aluts": 62,
        "registers": 175
      }
    },
    "cpuWrapper": {
      "baseline": {
        "aluts": 16,
        "registers": 12
      },
      "candidate": {
        "aluts": 20,
        "registers": 14
      }
    },
    "cpu": {
      "baseline": {
        "aluts": 852,
        "registers": 216
      },
      "candidate": {
        "aluts": 858,
        "registers": 216
      }
    }
  },
  "registerDeltas": [
    {
      "entity": "|sys_top|emu:emu|video_freak:video_freak",
      "baseline": 210,
      "candidate": 232,
      "delta": 22
    },
    {
      "entity": "|sys_top|emu:emu|hps_io:hps_io",
      "baseline": 768,
      "candidate": 749,
      "delta": -19
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp2_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst",
      "baseline": 2742,
      "candidate": 2760,
      "delta": 18
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst",
      "baseline": 2754,
      "candidate": 2737,
      "delta": -17
    },
    {
      "entity": "|sys_top|osd:hdmi_osd",
      "baseline": 610,
      "candidate": 627,
      "delta": 17
    },
    {
      "entity": "|sys_top|emu:emu",
      "baseline": 646,
      "candidate": 658,
      "delta": 12
    },
    {
      "entity": "|sys_top|emu:emu|video_freak:video_freak|sys_umul:mul",
      "baseline": 70,
      "candidate": 82,
      "delta": 12
    },
    {
      "entity": "|sys_top|emu:emu|video_mixer:video_mixer|scandoubler:sd|Hq2x:Hq2x|Blend:blender",
      "baseline": 356,
      "candidate": 368,
      "delta": 12
    },
    {
      "entity": "|sys_top|alsa:alsa",
      "baseline": 558,
      "candidate": 547,
      "delta": -11
    },
    {
      "entity": "|sys_top|ascal:ascal",
      "baseline": 4099,
      "candidate": 4110,
      "delta": 11
    },
    {
      "entity": "|sys_top",
      "baseline": 1466,
      "candidate": 1456,
      "delta": -10
    },
    {
      "entity": "|sys_top|emu:emu|video_freak:video_freak|video_scale_int:scale|sys_udiv:div",
      "baseline": 78,
      "candidate": 70,
      "delta": -8
    },
    {
      "entity": "|sys_top|emu:emu|system:system|mapper_detect:mapper_detect_inst",
      "baseline": 228,
      "candidate": 221,
      "delta": -7
    },
    {
      "entity": "|sys_top|emu:emu|video_mixer:video_mixer|scandoubler:sd|Hq2x:Hq2x",
      "baseline": 644,
      "candidate": 651,
      "delta": 7
    },
    {
      "entity": "|sys_top|emu:emu|hps_io:hps_io|video_calc:video_calc",
      "baseline": 656,
      "candidate": 650,
      "delta": -6
    },
    {
      "entity": "|sys_top|emu:emu|savestates:savestates_inst",
      "baseline": 4829,
      "candidate": 4835,
      "delta": 6
    },
    {
      "entity": "|sys_top|emu:emu|video_mixer:video_mixer|scandoubler:sd",
      "baseline": 295,
      "candidate": 289,
      "delta": -6
    },
    {
      "entity": "|sys_top|yc_out:yc_out",
      "baseline": 293,
      "candidate": 287,
      "delta": -6
    },
    {
      "entity": "|sys_top|emu:emu|lightgun:lightgun",
      "baseline": 144,
      "candidate": 139,
      "delta": -5
    },
    {
      "entity": "|sys_top|emu:emu|system:system|mapper_ctrl:mapper_banking",
      "baseline": 110,
      "candidate": 115,
      "delta": 5
    },
    {
      "entity": "|sys_top|emu:emu|system:system|opll:fm|TemporalMixer:tm",
      "baseline": 47,
      "candidate": 42,
      "delta": -5
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp2_inst|vdp_main:vdp_main_inst|vdp_background:vdp_bg_inst",
      "baseline": 154,
      "candidate": 159,
      "delta": 5
    },
    {
      "entity": "|sys_top|shadowmask:HDMI_shadowmask",
      "baseline": 251,
      "candidate": 256,
      "delta": 5
    },
    {
      "entity": "|sys_top|csync:csync_vga",
      "baseline": 51,
      "candidate": 55,
      "delta": 4
    },
    {
      "entity": "|sys_top|emu:emu|screen_rotate:screen_rotate",
      "baseline": 199,
      "candidate": 203,
      "delta": 4
    },
    {
      "entity": "|sys_top|emu:emu|system:system|CODES:GAMEGENIE",
      "baseline": 1099,
      "candidate": 1103,
      "delta": 4
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp2_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:34:shifter",
      "baseline": 33,
      "candidate": 37,
      "delta": 4
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp2_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:44:shifter",
      "baseline": 33,
      "candidate": 37,
      "delta": 4
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp2_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:47:shifter",
      "baseline": 33,
      "candidate": 37,
      "delta": 4
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:35:shifter",
      "baseline": 38,
      "candidate": 34,
      "delta": -4
    },
    {
      "entity": "|sys_top|emu:emu|video:video",
      "baseline": 35,
      "candidate": 39,
      "delta": 4
    },
    {
      "entity": "|sys_top|osd:vga_osd",
      "baseline": 616,
      "candidate": 612,
      "delta": -4
    },
    {
      "entity": "|sys_top|csync:csync_hdmi",
      "baseline": 59,
      "candidate": 56,
      "delta": -3
    },
    {
      "entity": "|sys_top|emu:emu|sdram:ram",
      "baseline": 64,
      "candidate": 61,
      "delta": -3
    },
    {
      "entity": "|sys_top|emu:emu|system:system|opll:fm|controller:ct|RegisterMemory:u_register_memory",
      "baseline": 225,
      "candidate": 228,
      "delta": 3
    },
    {
      "entity": "|sys_top|emu:emu|system:system|opll:fm|controller:ct|VoiceMemory:vmem",
      "baseline": 20,
      "candidate": 17,
      "delta": -3
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp2_inst",
      "baseline": 183,
      "candidate": 180,
      "delta": -3
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp2_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:15:shifter",
      "baseline": 37,
      "candidate": 34,
      "delta": -3
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp2_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:16:shifter",
      "baseline": 33,
      "candidate": 36,
      "delta": 3
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp2_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:18:shifter",
      "baseline": 36,
      "candidate": 33,
      "delta": -3
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp2_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:19:shifter",
      "baseline": 37,
      "candidate": 34,
      "delta": -3
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp2_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:20:shifter",
      "baseline": 37,
      "candidate": 34,
      "delta": -3
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp2_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:22:shifter",
      "baseline": 33,
      "candidate": 36,
      "delta": 3
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp2_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:23:shifter",
      "baseline": 33,
      "candidate": 36,
      "delta": 3
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp2_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:28:shifter",
      "baseline": 33,
      "candidate": 36,
      "delta": 3
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp2_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:55:shifter",
      "baseline": 34,
      "candidate": 37,
      "delta": 3
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp_inst",
      "baseline": 188,
      "candidate": 185,
      "delta": -3
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:4:shifter",
      "baseline": 33,
      "candidate": 36,
      "delta": 3
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:5:shifter",
      "baseline": 37,
      "candidate": 34,
      "delta": -3
    },
    {
      "entity": "|sys_top|mcp23009:mcp23009",
      "baseline": 52,
      "candidate": 49,
      "delta": -3
    },
    {
      "entity": "|sys_top|audio_out:audio_out|spdif:toslink",
      "baseline": 63,
      "candidate": 65,
      "delta": 2
    },
    {
      "entity": "|sys_top|emu:emu|pll_cfg:pll_cfg|altera_pll_reconfig_top:pll_cfg_inst|altera_pll_reconfig_core:NM28_reconfig.reconfig_core.altera_pll_reconfig_core_inst0",
      "baseline": 251,
      "candidate": 253,
      "delta": 2
    },
    {
      "entity": "|sys_top|emu:emu|savestate_ui:savestate_ui_inst",
      "baseline": 92,
      "candidate": 94,
      "delta": 2
    },
    {
      "entity": "|sys_top|emu:emu|system:system|T80s:z80_inst",
      "baseline": 31,
      "candidate": 33,
      "delta": 2
    },
    {
      "entity": "|sys_top|emu:emu|system:system|opll:fm",
      "baseline": 17,
      "candidate": 19,
      "delta": 2
    },
    {
      "entity": "|sys_top|emu:emu|system:system|opll:fm|OutputGenerator:og|FeedbackMemory:Fmem",
      "baseline": 105,
      "candidate": 107,
      "delta": 2
    },
    {
      "entity": "|sys_top|emu:emu|system:system|opll:fm|OutputGenerator:og|OutputMemory:Mmem",
      "baseline": 217,
      "candidate": 219,
      "delta": 2
    },
    {
      "entity": "|sys_top|emu:emu|system:system|opll:fm|PhaseGenerator:pg|PhaseMemory:MEM",
      "baseline": 351,
      "candidate": 349,
      "delta": -2
    },
    {
      "entity": "|sys_top|emu:emu|system:system|spram:ext_bios_inst|altsyncram:altsyncram_component|altsyncram_22o1:auto_generated",
      "baseline": 9,
      "candidate": 7,
      "delta": -2
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp2_inst|dpram:vdp_vram_inst|altsyncram:altsyncram_component|altsyncram_lbo2:auto_generated",
      "baseline": 5,
      "candidate": 7,
      "delta": 2
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp2_inst|vdp_cram:vdp_cram_inst",
      "baseline": 397,
      "candidate": 399,
      "delta": 2
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp2_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:10:shifter",
      "baseline": 35,
      "candidate": 33,
      "delta": -2
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp2_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:26:shifter",
      "baseline": 37,
      "candidate": 35,
      "delta": -2
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp2_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:27:shifter",
      "baseline": 33,
      "candidate": 35,
      "delta": 2
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp2_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:29:shifter",
      "baseline": 36,
      "candidate": 34,
      "delta": -2
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp2_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:36:shifter",
      "baseline": 36,
      "candidate": 34,
      "delta": -2
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp2_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:39:shifter",
      "baseline": 37,
      "candidate": 35,
      "delta": -2
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp2_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:41:shifter",
      "baseline": 34,
      "candidate": 36,
      "delta": 2
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp2_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:45:shifter",
      "baseline": 34,
      "candidate": 36,
      "delta": 2
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp2_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:46:shifter",
      "baseline": 34,
      "candidate": 36,
      "delta": 2
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp2_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:4:shifter",
      "baseline": 36,
      "candidate": 34,
      "delta": -2
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp2_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:50:shifter",
      "baseline": 37,
      "candidate": 35,
      "delta": -2
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp2_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:52:shifter",
      "baseline": 36,
      "candidate": 34,
      "delta": -2
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp2_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:53:shifter",
      "baseline": 37,
      "candidate": 35,
      "delta": -2
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp2_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:57:shifter",
      "baseline": 36,
      "candidate": 34,
      "delta": -2
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp2_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:5:shifter",
      "baseline": 37,
      "candidate": 35,
      "delta": -2
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp2_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:63:shifter",
      "baseline": 36,
      "candidate": 34,
      "delta": -2
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp2_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:6:shifter",
      "baseline": 35,
      "candidate": 37,
      "delta": 2
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp2_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:8:shifter",
      "baseline": 36,
      "candidate": 34,
      "delta": -2
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:16:shifter",
      "baseline": 34,
      "candidate": 36,
      "delta": 2
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:1:shifter",
      "baseline": 35,
      "candidate": 33,
      "delta": -2
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:22:shifter",
      "baseline": 36,
      "candidate": 34,
      "delta": -2
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:2:shifter",
      "baseline": 34,
      "candidate": 36,
      "delta": 2
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:34:shifter",
      "baseline": 36,
      "candidate": 34,
      "delta": -2
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:36:shifter",
      "baseline": 33,
      "candidate": 35,
      "delta": 2
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:38:shifter",
      "baseline": 34,
      "candidate": 36,
      "delta": 2
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:39:shifter",
      "baseline": 33,
      "candidate": 35,
      "delta": 2
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:42:shifter",
      "baseline": 35,
      "candidate": 33,
      "delta": -2
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:47:shifter",
      "baseline": 35,
      "candidate": 33,
      "delta": -2
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:48:shifter",
      "baseline": 33,
      "candidate": 35,
      "delta": 2
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:52:shifter",
      "baseline": 36,
      "candidate": 34,
      "delta": -2
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:54:shifter",
      "baseline": 35,
      "candidate": 37,
      "delta": 2
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:56:shifter",
      "baseline": 35,
      "candidate": 33,
      "delta": -2
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:57:shifter",
      "baseline": 35,
      "candidate": 33,
      "delta": -2
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:7:shifter",
      "baseline": 35,
      "candidate": 33,
      "delta": -2
    },
    {
      "entity": "|sys_top|emu:emu|video_freak:video_freak|video_scale_int:scale|sys_umul:mul",
      "baseline": 81,
      "candidate": 83,
      "delta": 2
    },
    {
      "entity": "|sys_top|sync_fix:sync_v",
      "baseline": 37,
      "candidate": 35,
      "delta": -2
    },
    {
      "entity": "|sys_top|audio_out:audio_out",
      "baseline": 171,
      "candidate": 170,
      "delta": -1
    },
    {
      "entity": "|sys_top|audio_out:audio_out|aud_mix_top:audmix_r",
      "baseline": 136,
      "candidate": 135,
      "delta": -1
    },
    {
      "entity": "|sys_top|audio_out:audio_out|sigma_delta_dac:sd_l",
      "baseline": 19,
      "candidate": 20,
      "delta": 1
    },
    {
      "entity": "|sys_top|emu:emu|dpram:nvram_inst|altsyncram:altsyncram_component|altsyncram_q3r2:auto_generated",
      "baseline": 5,
      "candidate": 4,
      "delta": -1
    },
    {
      "entity": "|sys_top|emu:emu|spram:ram_inst|altsyncram:altsyncram_component|altsyncram_h0o1:auto_generated",
      "baseline": 1,
      "candidate": 2,
      "delta": 1
    },
    {
      "entity": "|sys_top|emu:emu|system:system|T80s:z80_inst|T80:u0|T80_Reg:Regs",
      "baseline": 137,
      "candidate": 136,
      "delta": -1
    },
    {
      "entity": "|sys_top|emu:emu|system:system|cart_eeprom:cart_eeprom_inst|eeprom_93c46:eeprom_inst",
      "baseline": 135,
      "candidate": 134,
      "delta": -1
    },
    {
      "entity": "|sys_top|emu:emu|system:system|opll:fm|OutputGenerator:og|LinearTable:Ltbl",
      "baseline": 29,
      "candidate": 30,
      "delta": 1
    },
    {
      "entity": "|sys_top|emu:emu|system:system|opll:fm|SlotCounter:s0",
      "baseline": 10,
      "candidate": 11,
      "delta": 1
    },
    {
      "entity": "|sys_top|emu:emu|system:system|opll:fm|SlotCounter:s5",
      "baseline": 8,
      "candidate": 9,
      "delta": 1
    },
    {
      "entity": "|sys_top|emu:emu|system:system|opll:fm|SlotCounter:s8",
      "baseline": 10,
      "candidate": 11,
      "delta": 1
    },
    {
      "entity": "|sys_top|emu:emu|system:system|opll:fm|controller:ct",
      "baseline": 158,
      "candidate": 157,
      "delta": -1
    },
    {
      "entity": "|sys_top|emu:emu|system:system|opll:fm|envelopegenerator:eg|EnvelopeMemory:u_envelope_memory",
      "baseline": 8,
      "candidate": 7,
      "delta": -1
    },
    {
      "entity": "|sys_top|emu:emu|system:system|sprom:boot_rom_inst|altsyncram:altsyncram_component|altsyncram_tig1:auto_generated",
      "baseline": 2,
      "candidate": 1,
      "delta": -1
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp2_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:0:shifter",
      "baseline": 34,
      "candidate": 33,
      "delta": -1
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp2_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:11:shifter",
      "baseline": 34,
      "candidate": 35,
      "delta": 1
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp2_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:12:shifter",
      "baseline": 34,
      "candidate": 33,
      "delta": -1
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp2_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:13:shifter",
      "baseline": 36,
      "candidate": 35,
      "delta": -1
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp2_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:14:shifter",
      "baseline": 34,
      "candidate": 33,
      "delta": -1
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp2_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:25:shifter",
      "baseline": 35,
      "candidate": 34,
      "delta": -1
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp2_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:31:shifter",
      "baseline": 35,
      "candidate": 34,
      "delta": -1
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp2_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:32:shifter",
      "baseline": 36,
      "candidate": 35,
      "delta": -1
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp2_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:33:shifter",
      "baseline": 34,
      "candidate": 35,
      "delta": 1
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp2_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:37:shifter",
      "baseline": 36,
      "candidate": 35,
      "delta": -1
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp2_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:38:shifter",
      "baseline": 33,
      "candidate": 34,
      "delta": 1
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp2_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:48:shifter",
      "baseline": 34,
      "candidate": 33,
      "delta": -1
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp2_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:49:shifter",
      "baseline": 34,
      "candidate": 35,
      "delta": 1
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp2_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:51:shifter",
      "baseline": 35,
      "candidate": 34,
      "delta": -1
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp2_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:54:shifter",
      "baseline": 35,
      "candidate": 36,
      "delta": 1
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp2_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:56:shifter",
      "baseline": 36,
      "candidate": 35,
      "delta": -1
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp2_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:61:shifter",
      "baseline": 36,
      "candidate": 35,
      "delta": -1
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp2_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:7:shifter",
      "baseline": 34,
      "candidate": 35,
      "delta": 1
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp2_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:9:shifter",
      "baseline": 35,
      "candidate": 36,
      "delta": 1
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp_inst|dpram:vdp_vram_inst|altsyncram:altsyncram_component|altsyncram_lbo2:auto_generated",
      "baseline": 5,
      "candidate": 6,
      "delta": 1
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp_inst|vdp_cram:vdp_cram_inst",
      "baseline": 397,
      "candidate": 398,
      "delta": 1
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp_inst|vdp_main:vdp_main_inst|vdp_background:vdp_bg_inst",
      "baseline": 158,
      "candidate": 157,
      "delta": -1
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:11:shifter",
      "baseline": 34,
      "candidate": 33,
      "delta": -1
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:12:shifter",
      "baseline": 33,
      "candidate": 34,
      "delta": 1
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:13:shifter",
      "baseline": 35,
      "candidate": 34,
      "delta": -1
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:14:shifter",
      "baseline": 35,
      "candidate": 36,
      "delta": 1
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:15:shifter",
      "baseline": 35,
      "candidate": 36,
      "delta": 1
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:18:shifter",
      "baseline": 34,
      "candidate": 33,
      "delta": -1
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:19:shifter",
      "baseline": 35,
      "candidate": 34,
      "delta": -1
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:20:shifter",
      "baseline": 35,
      "candidate": 34,
      "delta": -1
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:23:shifter",
      "baseline": 35,
      "candidate": 34,
      "delta": -1
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:24:shifter",
      "baseline": 36,
      "candidate": 35,
      "delta": -1
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:30:shifter",
      "baseline": 34,
      "candidate": 33,
      "delta": -1
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:31:shifter",
      "baseline": 36,
      "candidate": 35,
      "delta": -1
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:32:shifter",
      "baseline": 33,
      "candidate": 34,
      "delta": 1
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:33:shifter",
      "baseline": 35,
      "candidate": 36,
      "delta": 1
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:37:shifter",
      "baseline": 36,
      "candidate": 35,
      "delta": -1
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:3:shifter",
      "baseline": 36,
      "candidate": 35,
      "delta": -1
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:40:shifter",
      "baseline": 36,
      "candidate": 35,
      "delta": -1
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:44:shifter",
      "baseline": 35,
      "candidate": 34,
      "delta": -1
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:45:shifter",
      "baseline": 34,
      "candidate": 33,
      "delta": -1
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:46:shifter",
      "baseline": 36,
      "candidate": 35,
      "delta": -1
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:49:shifter",
      "baseline": 34,
      "candidate": 35,
      "delta": 1
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:50:shifter",
      "baseline": 35,
      "candidate": 36,
      "delta": 1
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:51:shifter",
      "baseline": 35,
      "candidate": 36,
      "delta": 1
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:53:shifter",
      "baseline": 33,
      "candidate": 34,
      "delta": 1
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:59:shifter",
      "baseline": 34,
      "candidate": 35,
      "delta": 1
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:62:shifter",
      "baseline": 34,
      "candidate": 33,
      "delta": -1
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:63:shifter",
      "baseline": 35,
      "candidate": 34,
      "delta": -1
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:6:shifter",
      "baseline": 33,
      "candidate": 34,
      "delta": 1
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:8:shifter",
      "baseline": 34,
      "candidate": 35,
      "delta": 1
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\\shifters:9:shifter",
      "baseline": 35,
      "candidate": 34,
      "delta": -1
    },
    {
      "entity": "|sys_top|emu:emu|video_freak:video_freak|video_scale_int:scale",
      "baseline": 180,
      "candidate": 181,
      "delta": 1
    },
    {
      "entity": "|sys_top|emu:emu|video_mixer:video_mixer|gamma_corr:gamma",
      "baseline": 72,
      "candidate": 73,
      "delta": 1
    },
    {
      "entity": "|sys_top|pll_cfg_hdmi:pll_cfg_hdmi|fpll_dprio_init:fpll_dprio_init_inst",
      "baseline": 15,
      "candidate": 14,
      "delta": -1
    },
    {
      "entity": "|sys_top|pll_hdmi_adj:pll_hdmi_adj",
      "baseline": 506,
      "candidate": 505,
      "delta": -1
    },
    {
      "entity": "|sys_top|scanlines:VGA_scanlines",
      "baseline": 8,
      "candidate": 9,
      "delta": 1
    },
    {
      "entity": "|sys_top|sync_fix:sync_h",
      "baseline": 37,
      "candidate": 36,
      "delta": -1
    },
    {
      "entity": "|sys_top|sys_umuldiv:ar_muldiv|sys_udiv:udiv",
      "baseline": 64,
      "candidate": 63,
      "delta": -1
    },
    {
      "entity": "|sys_top|sys_umuldiv:ar_muldiv|sys_umul:umul",
      "baseline": 69,
      "candidate": 70,
      "delta": 1
    },
    {
      "entity": "|sys_top|sysmem_lite:sysmem|f2sdram_safe_terminator:f2sdram_safe_terminator_ram1",
      "baseline": 80,
      "candidate": 81,
      "delta": 1
    },
    {
      "entity": "|sys_top|sysmem_lite:sysmem|f2sdram_safe_terminator:f2sdram_safe_terminator_vbuf",
      "baseline": 83,
      "candidate": 84,
      "delta": 1
    },
    {
      "entity": "|sys_top|vga_out:vga_out",
      "baseline": 212,
      "candidate": 213,
      "delta": 1
    },
    {
      "entity": "|sys_top|vga_out:vga_scaler_out",
      "baseline": 206,
      "candidate": 205,
      "delta": -1
    }
  ],
  "packing": {
    "baseline": {
      "needed": 27388,
      "placed": 32692,
      "recoverable": 5601,
      "unavailable": 297,
      "logicALUTs": 38357,
      "routingALUTs": 13574
    },
    "candidate": {
      "needed": 27416,
      "placed": 32784,
      "recoverable": 5670,
      "unavailable": 302,
      "logicALUTs": 38430,
      "routingALUTs": 13764
    },
    "delta": {
      "needed": 28,
      "placed": 92,
      "recoverable": 69,
      "unavailable": 5,
      "logicALUTs": 73,
      "routingALUTs": 190
    }
  },
  "largestEntityDeltas": [
    {
      "entity": "|sys_top|emu:emu|savestates:savestates_inst",
      "baseline": {
        "needed": 4771.4,
        "placed": 5433.2,
        "recoverable": 730.6,
        "unavailable": 68.8,
        "aluts": 5505,
        "registers": 4829
      },
      "candidate": {
        "needed": 4731.9,
        "placed": 5451.4,
        "recoverable": 802,
        "unavailable": 82.5,
        "aluts": 5470,
        "registers": 4835
      },
      "delta": {
        "needed": -39.5,
        "placed": 18.2,
        "recoverable": 71.4,
        "unavailable": 13.7,
        "aluts": -35,
        "registers": 6
      }
    },
    {
      "entity": "|sys_top|emu:emu|system:system|vdp:vdp_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst",
      "baseline": {
        "needed": 1211,
        "placed": 1958.9,
        "recoverable": 771.1,
        "unavailable": 23.1,
        "aluts": 1259,
        "registers": 2754
      },
      "candidate": {
        "needed": 1176,
        "placed": 1911.6,
        "recoverable": 749.6,
        "unavailable": 14,
        "aluts": 1258,
        "registers": 2737
      },
      "delta": {
        "needed": -35,
        "placed": -47.3,
        "recoverable": -21.5,
        "unavailable": -9.1,
        "aluts": -1,
        "registers": -17
      }
    },
    {
      "entity": "|sys_top|emu:emu|pll_cfg:pll_cfg|altera_pll_reconfig_top:pll_cfg_inst|altera_pll_reconfig_core:NM28_reconfig.reconfig_core.altera_pll_reconfig_core_inst0",
      "baseline": {
        "needed": 465.9,
        "placed": 479.3,
        "recoverable": 14.4,
        "unavailable": 1,
        "aluts": 732,
        "registers": 251
      },
      "candidate": {
        "needed": 495.1,
        "placed": 516.8,
        "recoverable": 22.2,
        "unavailable": 0.5,
        "aluts": 780,
        "registers": 253
      },
      "delta": {
        "needed": 29.2,
        "placed": 37.5,
        "recoverable": 7.8,
        "unavailable": -0.5,
        "aluts": 48,
        "registers": 2
      }
    },
    {
      "entity": "|sys_top|emu:emu|hps_io:hps_io",
      "baseline": {
        "needed": 585.2,
        "placed": 720.9,
        "recoverable": 137.8,
        "unavailable": 2.1,
        "aluts": 774,
        "registers": 768
      },
      "candidate": {
        "needed": 612.7,
        "placed": 751.7,
        "recoverable": 141.1,
        "unavailable": 2.2,
        "aluts": 771,
        "registers": 749
      },
      "delta": {
        "needed": 27.5,
        "placed": 30.8,
        "recoverable": 3.3,
        "unavailable": 0.1,
        "aluts": -3,
        "registers": -19
      }
    },
    {
      "entity": "|sys_top",
      "baseline": {
        "needed": 828.9,
        "placed": 1095.7,
        "recoverable": 269.7,
        "unavailable": 2.9,
        "aluts": 1382,
        "registers": 1466
      },
      "candidate": {
        "needed": 846.6,
        "placed": 1104.6,
        "recoverable": 264.8,
        "unavailable": 6.8,
        "aluts": 1380,
        "registers": 1456
      },
      "delta": {
        "needed": 17.7,
        "placed": 8.9,
        "recoverable": -4.9,
        "unavailable": 3.9,
        "aluts": -2,
        "registers": -10
      }
    },
    {
      "entity": "|sys_top|emu:emu|system:system|opll:fm|PhaseGenerator:pg|PhaseMemory:MEM",
      "baseline": {
        "needed": 139.1,
        "placed": 240.8,
        "recoverable": 106,
        "unavailable": 4.2,
        "aluts": 179,
        "registers": 351
      },
      "candidate": {
        "needed": 123.2,
        "placed": 232.2,
        "recoverable": 110.3,
        "unavailable": 1.3,
        "aluts": 168,
        "registers": 349
      },
      "delta": {
        "needed": -15.9,
        "placed": -8.6,
        "recoverable": 4.3,
        "unavailable": -2.9,
        "aluts": -11,
        "registers": -2
      }
    },
    {
      "entity": "|sys_top|emu:emu|hps_io:hps_io|video_calc:video_calc",
      "baseline": {
        "needed": 306.2,
        "placed": 337.7,
        "recoverable": 37.5,
        "unavailable": 6.1,
        "aluts": 475,
        "registers": 656
      },
      "candidate": {
        "needed": 293.2,
        "placed": 337.5,
        "recoverable": 47.8,
        "unavailable": 3.5,
        "aluts": 474,
        "registers": 650
      },
      "delta": {
        "needed": -13,
        "placed": -0.2,
        "recoverable": 10.3,
        "unavailable": -2.6,
        "aluts": -1,
        "registers": -6
      }
    },
    {
      "entity": "|sys_top|emu:emu|system:system|cart_eeprom:cart_eeprom_inst|eeprom_93c46:eeprom_inst",
      "baseline": {
        "needed": 167.1,
        "placed": 173.6,
        "recoverable": 6.9,
        "unavailable": 0.4,
        "aluts": 239,
        "registers": 135
      },
      "candidate": {
        "needed": 179.2,
        "placed": 186.8,
        "recoverable": 7.7,
        "unavailable": 0.1,
        "aluts": 268,
        "registers": 134
      },
      "delta": {
        "needed": 12.1,
        "placed": 13.2,
        "recoverable": 0.8,
        "unavailable": -0.3,
        "aluts": 29,
        "registers": -1
      }
    }
  ]
}
```

Reproduce with PowerShell ExecutionPolicy Bypass: pre.ps1 (baseline), prepare.js, matrix.js, sim.ps1/fixed.do to compile, batch.ps1 partitions, extras.js/extras.ps1, stalls.js/stalls.ps1, regress.ps1, broad.ps1 groups a/b/format; check_simulations.js --final gates build.ps1. Afterwards run resource_analysis.js, quartus_results.js and report.js. For a fresh retry use batch.ps1 -MissingOnly; retained earlier failing fixture/debug logs are not passing evidence. See README.md for the canonical v1/v2 rechecks and old-reader suites.
