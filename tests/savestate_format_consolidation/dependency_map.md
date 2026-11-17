# Compatibility dependency and cost map

The complete machine-readable inventory is `compatibility_inventory.json`. Its controller expressions join to structure rows and tag records by signal name. Source references are lexical counts. Physical fanout is recorded only when separately present in the retained v17 fitter report; a missing value means Quartus did not separately report that merged net, not zero fanout. Mux widths describe semantic destinations and cannot be added as independent removable hardware.

| Decode | Selection | Destination/control | Public requirement |
|---|---|---|---|
| word0 size ==0x3ffe | `is_old_format` | old212-bit CPU zero extension; skip gameID, newer IO/video/EEPROM; old RAM footprint; Evolution rejection | retain64KiB and96KiB |
| word01a24-bit HC tag + subtype | nested membership checks; v12+ aliases to v11 | choose GG, MD6, EEPROM, SC RAM, MasterTap, paddle, lightgun, mapper and Evolution readers | replace development memberships with current/public distinction; retain absent-state behavior |
| v12/v13+ membership | NMI/restart valid and alternate padding checks | CPU3-bit NMI,3-bit instruction context | collapse distinction; retain public legacy CPU behavior |
| v14+ membership | `has_restart` | phase/tick, two4778-bit sprite records, `sprite_valid`, T2 replay | public needs invalid/normalized sprite path; current needs full payload |
| v15+ membership | `has_background` | two139-bit background records and `bg_valid` | public needs deterministic pipeline fallback |
| v16+ membership | historical phase vs zero | AudioMix publication phase | public needs phase0; current exact phase unchanged |
| v17 membership | `has_fm` | sequential F01 capture/restore or reset +28canonical writes + stationary refill | retain current full FM and public deterministic FM fallback |
| PSG word presence + PSGX1 descriptor | `has_audio_ext` | exact dual PSG/divider/control restore or old56-bit config restore | public requires configuration fallback; current exact PSG must remain |
| extension descriptor/padding/range checks | per-device valid/full | destination exact state or established safe defaults; early rejection for absent Evolution history | retain validation; removing versions cannot remove current validation |

Both command generation and registered FSM progression contain the GG/read-route conditions. The candidate changes both expressions together. It removes the v12+ to v11 alias before eliminating old-tag comparisons, so current v17 still selects the full current payload. It rejects HC-prefixed noncurrent development tags rather than accidentally treating them as untagged imports. It leaves public64/public96, magic/gameID, PSGX, all descriptor/range validation, state contents, addresses, timing/restart, snapshot modules and destination modules intact.

There is no runtime conversion through seventeen successive versions. The production implementation uses overlapping membership predicates and a shared tag alias. Repeated source comparisons can share one synthesized comparator; removing95 textual comparisons cannot be interpreted as removing95 independent24-bit comparators.

## Static estimate before measurement

The likely directly removable logic is the sixteen old-tag equality terms, their membership OR trees, the24-bit tag alias selection and the v12-only padding distinction. Comparator terms share the HC prefix. Most presence flags still distinguish public from current and remain. Many registers have different reset/clear/capture lifetimes, preventing automatic merging even when LOAD writes the same current predicate.

The large state banks are current history, not copies retained for old versions:9556sprite bits,278background bits and the3328-bit OPLL scratch representation remain. Public imports require the invalid-history branches in the VDP and CPU, plus legacy peripheral and FM defaults. Removing these would break a released compatibility contract. There is no justified static claim of a memory-block saving.

The retained v17 fitter reports physical fanout9663 for ARM_FREEZE,5920 for z80_set,5454 for vdp2_regs_set,5262 for LOAD_HDR_RD, approximately4800 for sprite-bank shift controls and1410 for has_restart. These show that capture/restore/ring routing dominates the reported high-fanout list. Only has_restart is a compatibility presence net, and it still distinguishes current from public. Its1410 sinks cannot be attributed wholly to development versions.

Expected direct register and Boolean savings are limited. Placement/packing may move much more than the local logic delta, including HDMI timing outside the savestate controller. Only a completed, controlled fit and STA can determine practical resource recovery. No cost classification or production decision is justified by this static estimate alone.

## Limits of public imports

Preserving a released reader does not imply recovering history absent from its image. Public64 restores the212-bit CPU subset and zero-extends the eighteen newer bits; public96 has the230-bit register representation. Both lack the later NMI/instruction, sprite/background, accessory and FM histories. The retained validity/default paths distinguish those cases rather than claiming reconstruction. Evolution imports lacking the required selector/pending history remain rejected.

Some established peripheral fallbacks sample present input pins: MasterTap uses the restored TH level with its timeout/index defaults; paddle uses a fresh current analog sample and current TH cache. They are deterministic given those inputs, not recovered historical samples. EEPROM full temporal/content restoration and SC RAM extensions are absent from the public images; the existing legacy wrapper/mapper memory footprint remains unchanged.

Public PSG imports are specifically configuration-only. `has_audio_ext=0` selects the56-bit configuration strobe; `jt89` restores its tone/volume/control/latch configuration but does not install the unsaved divider, tone counters or noise history through `ss_ext_set`. Those unrecorded internals are not a deterministic function of the public image. This investigation does not silently canonicalize them or claim exact public audio continuation. It preserves the existing released-reader behavior. The current v17 exact PSG path, pending-tick correction and historical mixer phase remain fully represented and tested.

The separate FM legacy path is canonical: reset, initialization,28default writes and refill are retained. Public FM history is explicitly not reconstructed. These differing public behaviors must not be combined into a claim that an entire public image recreates the complete modern historical state.
