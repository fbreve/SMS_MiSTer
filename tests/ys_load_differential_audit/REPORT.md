# Ys LOAD differential investigation

Investigation only, 2026-11-13. No production RTL, existing worktree, sys file, build artifact, branch, commit or PR was changed. Only this new investigation directory was written. No Quartus build was run. The cause of the reported Ys corruption is **not yet established**.

## Source identity is a material finding

| Source | Verified revision and actual source |
| --- | --- |
| Current checkout / integration/ym2413-public-v1-upstream | `8cd53ccc954c24970372ea6d8a3fb2336a14c46f`; no tracked edits |
| Local master | `66f16d5c656fd8906d62570da4d258875bcee684` |
| Supplied tests/ym2413_v19_fullstate/worktree | `9873761503510e4b2c7e06600bf5515344235c2f`; branch experiment/ym2413-v19-fullstate; no tracked edits; untracked historical test outputs and generated source copies listed in source_identity.json |
| Historical broad implementation referenced by v19 test metadata | `7fcd5e12847eedf9e97a44dc937c3dbac3205f7c`; a different source tree, with CPU restart, phase, controller, background and sprite extensions |
| Preserved v19 physical_seed1 source | inputs.json records an **uncommitted FM-only port over 66f16d5c**, using 7fcd5e12 as its FM reference. All 24 recorded production-file SHA-256 values verified against the preserved candidate directory. It is not the complete 7fcd5e12 architecture. |

PR #227 was inspected read-only through the GitHub connector: base 66f16d5c, head 8cd53ccc, matching the current checkout. No remote mutation occurred.

`source_identity.json` records raw hashes for SMS.sv, files.qip and all 74 tracked rtl files, together with line-ending-normalized equality. Byte differences in a few non-FM files are only line endings. Comparing only branch names or old manifests would give the wrong architectural comparison. A known-good RBF filename/hash must be matched to its frozen build inputs before attributing its behavior to either implementation. The user's known-good observation remains valid; the binary-to-source association is unresolved.

## Actual supplied worktree versus current

The following production sources are identical after normalizing line endings: SMS.sv, system.vhd, all VDP files (including background, sprites and CRAM), video.vhd, T80/T80s, mapper_ctrl.vhd, memory_decode.vhd and the RAM primitives. The VDP and T80 files are also byte-identical; SMS.sv and system.vhd differ only in line endings. Their relevant behavior is therefore shared:

| State or sequence | Both implementations |
| --- | --- |
| xram_cpu_A | Captured/restored in bits 83:70 of the 128-bit VDP record |
| address_ff / to_cram | Bits 84 / 85; command decode selects register/read/VRAM/CRAM behavior rather than storing an independent full command byte |
| vram_cpu_D_outl / cram_latch | Bits 93:86 / 101:94 |
| xram_cpu_read | Bit 102 |
| xram_cpu_A_incr | **Not serialized**; forced to zero on register restore |
| cpu_write_data / data_write | Not serialized; restore primes write data from live D_in and clears data_write |
| CPU port edge detectors | Restore old_WR_n, old_RD_n, old_WR_direct from live bus levels; normal updates remain CE-controlled, with Evolution-menu edge capture exception |
| Pending data-port transaction | Normal write captures data and sets increment; a later VDP enable performs increment. Pending read has a separate delay/increment/read-latch path. Restore does not explicitly reconstruct a pending write increment. |
| Restore priority | Register restore runs on clk_sys without requiring ce_vdp. The ordinary CE/edge block is a separate subsequent if, not an elsif. Ordinary SMS freeze gates ce_vdp off; Evolution edge capture needs separate consideration. |
| VRAM DMA | Same port-A mux and two-clock save read pipeline; same 16 KiB SMS region 0x101..0x900 and byte-stream load. No new VRAM storage or restore mechanism in v19 FM-only port. |
| CPU / WRAM / mapper | Same 230-bit CPU architecture, same 8 KiB SMS WRAM DMA, same mapper-before-CPU restore and settle ordering |
| Freeze | Capture CPU pre-tick at eligible opcode fetch; capture VDP/mapper/video at ARM one host clock later; freeze domain enables; drain DDR interface for 32 quiet clocks |
| LOAD completion | Restore memories; mapper; CPU/VDP/PSG/IO/video; CRAM; 900000-clock flush; FM apply; at least 255-clock wait; release on a quiet raw-CE cycle |

These shared omissions deserve reachability checks, but are **not differential evidence** against current FM optimization. An opcode-fetch boundary usually provides time for the preceding VDP transaction to drain; do not assume a pending increment is reachable at accepted SAVE without a trace proving it.

The savestates.sv diff is confined to the FM descriptor, validation and loop bounds: 104 private words/version17 versus 100/version1, 52 versus 50 DDR transfers, and the changed FM field map/guard. opll_snapshot still uses one 256x32 M10K. Capture/apply each traverse four fewer words (eight fewer host clocks); DDR transfer timing also differs. Both use the same REFILL sequence and non-FM restore states. Neither stores the free-running CPU/VDP clock-enable phase in video_snap: video bits 21:4 are beam counters. Quiet release is not proof of identical subsequent relative CE phase.

Therefore a timing-dependent shared restart/access weakness remains possible even with identical VDP RTL. It has not been demonstrated. Padding FM latency alone would be a diagnostic control, not a justified fix.

## Historical broad reference: relevant differences

The full 7fcd5e12 reference DOES differ in non-FM behavior:

- Captures a three-bit predecessor decoder class (ordinary, CB, ED, DD, FD, EI). DIRSet seeds the corresponding old IR instead of always clearing it.
- Reconstructs historical CPU T1/T2 under a private preparation enable while guest domains remain held, including memory-read routing for this preparation.
- Records/restores clock phase, commits video position after preparation, then releases freeze through a phase-ready handshake.
- Records NMI and peripheral history, latched H counter, 139 background-history bits per VDP and sprite records. These were explicitly excluded from the FM-only port, as its retained verify_scope.js documents.
- Still clears xram_cpu_A_incr and primes the same CPU port latches. No evidence that the broad reference fixes Ys by saving that increment bit.

Background/sprite history can explain rendering discrepancies in general; the reported initially correct image, progressive map corruption and recovery after area reload prioritize the future CPU-to-memory update path. Symptoms alone do not prove that VRAM or WRAM restored correctly, or that CPU restart is the cause.

## Deterministic focused result

Ran ModelSim 10.5b using current production T80 sources, with only explicit VHDL entity-instantiation syntax adapted for this simulator. No full system, FM, VDP, ROM image or DDR controller is simulated here.

The natural guest program is `LD BC,2; LD HL,4000h; LD DE,C000h; LDIR; HALT`. Capture uses the production acceptance predicate's CPU-enabled opcode fetch at PC=000A, ISet=00, immediately after ED. Three CPUs compare uninterrupted execution, current architectural LOAD, and a **test-only ED-class restore intervention**. No internal state is forced to create the captured witness.

```
CAPTURE PC=000a ISet=0 (natural ED predecessor)
RESULT uninterrupted=a5,5a current_LOAD=00,00 ED_probe=a5,5a
PASS: current CPU loses pending ED; test-only predecessor restoration recovers both guest writes. Not an Ys reproduction.
```

The earliest information loss in this witness is DIRSet clearing preceding IR. Re-fetch reads B0 correctly but decodes it without ED; the first missing guest copy follows. Existing tests/savestate_g01_cpu_restart/review.md independently documents the earlier canonical ISet divergence, BC divergence one CPU tick later, and the following missing bus read; tests/savestate_g01_cpu_restart_fix retains broader six-class evidence. Those older fixtures include extra infrastructure, so their passes are not presented as current integrated-system validation.

This new test establishes a current CPU defect and the sufficiency of restoring ED **for this witness**. It does not establish an earliest Ys divergence. The supplied FM-only v19 worktree has this same CPU defect. It cannot by itself explain a verified good/bad pair built from those two sources.

Existing FM nonFM_tb coverage uses supplied register vectors and synthetic memory input patterns, and compares serialized non-FM payloads / restore outputs. It does not execute Ys, run a live VDP access stream, or check subsequent CPU writes. Its recorded PASS cannot close this gap. No existing Ys ROM revision, before/after memory dump or post-LOAD bus trace was identified in the inspected evidence.

Reproduce from this directory: `node prepare.js`, then `vsim -c -do run.do -l simulation.log`. Test-only generated CPU copies are never in files.qip. The ED intervention is deliberately not a deployable six-class correction. Simulator reports pre-existing width and startup metavalue warnings; assertions use known final memory bytes and all pass.

## Minimal correction proposal, conditional on the next trace

Do not change production yet. If the good binary is the full historical implementation and Ys first diverges in CPU prefix/EI reconstruction, port only the three-bit semantic predecessor capture/restore and the necessary proven CPU replay/read-settle sequence. Retain current 100-word FM architecture. Do not import full video/sprite history or full v19 storage without a separate causal witness. If the good binary is the FM-only port, investigate release-phase/access timing first: the CPU predecessor defect is shared.

If instead CPU address/data/mapper streams match and the first divergence is a VDP write address, fix only the identified pending transaction or release ordering. Preserve exactly-once writes; do not blindly clear/replay pending writes or increment the restored address.

Three predecessor bits cannot be reconstructed from a snapshot that never recorded them. For that solution, use currently unused CPU word5 padding with an independently versioned/validated extension marker and explicit legacy fallback; retain existing slot and FM descriptor sizes. The historical broad reference uses word5 bits43:41 for restart and bits40:38 for NMI, but its video tag/subtype is incompatible with current FM v1. Do not copy its tag interpretation wholesale. New readers must retain old-state normalization; old readers would ignore added context and cannot provide exact new-state replay. An extension discriminator must be specified before implementation; simply filling padding does not establish compatibility. No format change was made.

Expected resources: three snapshot bits plus small decoder/mux/wiring for predecessor state; a bounded preparation FSM and phase registers if trace requires them. No additional FM scratch RAM, DSP or wide sprite/background storage is required for that proposal. A precise ALM/register/timing delta is unknown without implementation and synthesis. A sequencing-only access fix may require only a few control bits. No claim of zero timing cost or guaranteed fit is justified.

## Next focused causality test

1. Identify known-good RBF by hash and frozen input manifest. Do not equate the historical branch name with its current contents.
2. Use identical Ys ROM bytes (record SHA-256), core settings, scene and scripted movement. SAVE/LOAD independently in each implementation; never interchange FM snapshots. First compare each LOAD against its own uninterrupted continuation from its own saved instant.
3. At accepted SAVE and before first resumed guest tick capture all VRAM bytes, WRAM, mapper/CPU architecture, predecessor class, VDP record, pending increment/read/write flags, write data and port edge history. Compare restored memory to that implementation's own saved memory, including offscreen tiles.
4. Trace raw CEs, freeze edges, restore strobes, PC/opcode/prefix, CPU address/data and MREQ/IORQ/RD/WR, mapper bank, VDP port acceptance and actual VRAM WE/address/data. Record early post-LOAD traffic and extend until the first newly exposed corrupt tile is written/read. Stop at the first causal divergence, not the visible symptom.
5. If CPU diverges first, rerun with only predecessor/replay correction in test copies. If CPU stream matches and VDP address diverges, intervene only in that access path. Sweep release CE phase in simulation as a diagnostic for the eight-clock FM apply difference. Keep both FM formats independent.

Acceptance: same memory immediately after LOAD, same first subsequent guest transactions, then matching movement-driven tile updates; the regression must fail without the isolated change and pass with it. Until this test, CPU restart is the strongest demonstrated candidate for the broad-reference comparison, and a timing-sensitive shared issue remains the candidate for the supplied FM-only-source comparison. Neither is a confirmed Ys root cause.
