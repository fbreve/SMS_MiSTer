# F05 / S033 — SC cartridge RAM savestate fix

Branch `fix/savestate-sc-ram`, based on committed F03/F04 `b0f4b71`. F05 only; F06 remains intentionally unresolved. Production changes are limited to `SMS.sv` and `rtl/savestates.sv`. Nothing staged, committed, pushed or submitted as a PR.

1. **Root cause.** SC cartridge RAM is routed through SC configuration in `rtl/system.vhd` and `rtl/memory_bus.vhd`. The savestate controller previously selected shared backing RAM only through ordinary mapper snapshot bits. Normal SC configurations leave those bits clear, so save/load transferred no cartridge RAM despite guest-visible contents.

2. **Ownership.** SC ownership and size are explicit in `sc3000_en` plus `sc_cart_ram`. They are known before first guest access and do not depend on persistence flags or discovered Sega SRAM use. SC configuration changes cause a core reset; they do not clear backing bytes. The controller captures the effective configuration at freeze. EEPROM, Evolution and System E are distinct owners/machine paths and do not select this SC transfer. Unsupported combined SC/System E configuration is not changed by this patch.

3. **Topology.** The existing 15-bit, 32768-byte FPGA dual-port RAM is shared with other cartridge memory types. SC uses an unbanked physical prefix: selector 01 = 2048 bytes mirrored through CPU 8000-bfff; selector 10 = 16384 bytes at 8000-bfff; selector 11 = 32768 bytes at 8000-ffff. Selector 00 has no SC cartridge RAM. Internal SC WRAM is separate and was already included. Plain SG content does not itself establish cartridge RAM; explicit SC configuration selects the same positive cases. Physical RAM and mapper timing are unchanged.

4. **Pre-fix dynamic evidence.** `before.log` confirms the omission for all three sizes using production memory decode, actual dual-port RAM and the complete production savestate/DDRAM controller. Guest accesses fill every backing byte with A, save, replace every byte with B, load and read every byte. Each case transfers zero SC payload words and retains B. At physical byte zero A=35/B=ca, and load returns ca in every size. For 2 KiB, offset 07ff has A=bd/B=42 and load returns 42. All sampled endpoints/middle values and the deterministic full-image formula are recorded in `before_values.csv` and `prepare.js`. The original before controller fixture is preserved separately from the fixed fixture.

5. **Files.** `rtl/savestates.sv` adds captured SC size, validated descriptor states, SC-specific transfer selection/length, v5 decoding and a completed-restore pulse. `SMS.sv` supplies effective SC configuration and marks restored SC RAM dirty under the existing host persistence eligibility. No mapper, system routing, EEPROM engine, VDP, IO or controller source changed. New test/evidence files are in `tests/savestate_sc_ram`; existing untracked regression generators were updated for the current tag/new ports, while retaining explicit historical cases. The pre-existing untracked tests tree was preserved.

6. **DDRAM layout.** New descriptor is slot-relative word 025. SC data reuses the existing NVRAM DMA region:

| Cartridge bytes | 64-bit words | Inclusive slot-relative range |
|---:|---:|---|
| 2048 | 256 | d01-e00 |
| 16384 | 2048 | d01-1500 |
| 32768 | 4096 | d01-1d00 |

The descriptor adds one word; all existing positions remain fixed. EEPROM descriptor/protocol/backing remain 01f, 030-031 and 040-04f. Normal WRAM ends d00. SC ends at most 1d00. System E's additional allocations end 2900 and are mutually exclusive with the normal SC machine. Slot stride remains 3000 64-bit words, or 98304 bytes. `design.md` inventories every occupied region; static range checks and full serialized-byte comparisons verify non-overlap and exact transfer lengths. Extra transferred payload occupies existing slot capacity and uses existing live RAM; it does not enlarge the save slot or allocate another backing RAM.

7. **Version/presence.** New writers use v5 tag 484305 at 01a with unchanged base count 3. Descriptor 025 is `{30'd0, size[1:0], 32'h53435235}` (SCR5). Size 00 explicitly describes absence. Load requires validated v5 tag/count and exact descriptor equality with the captured nonzero current SC size. The new version distinguishes snapshots that actually stored SC RAM from v4 and earlier snapshots, which did not. HCounter, GG, MD6 and EEPROM field layouts remain intact.

8. **Legacy.** Untagged, v1, v2, v3 and v4 do not validate an SC payload and retain current SC backing bytes. The older 64 KiB format also retains SC backing. Invalid/future version, invalid base count, wrong magic, nonzero reserved bits, zero size and a size mismatch retain current backing. No zero-fill or arbitrary old DDRAM is substituted. A mismatch does not change configuration or force visibility. Other devices retain their existing historical fallback behavior. Explicit v4 EEPROM loading remains functional.

9. **Coherence.** Existing freeze disables CPU writes in `memory_bus`; top-level port A mux gives the savestate engine exclusive ownership. Existing `storage_busy`/`ss_busy` interlock prevents SD port-B traffic from racing capture or restoration. Active attempted writes during capture are tested and blocked. Complete restored contents are also checked through the physical SD RAM read port. No normal SC timing or new freeze mechanism is introduced. Existing reset-aborted operation behavior is not redesigned.

10. **Full-memory replay.** Every size receives address-dependent, alternating and deterministic pseudo-random full-memory patterns, full-memory perturbation, exact full-memory scans, endpoint/middle coverage, repeated load, save/load after a new write, reset retention and configuration hide/re-expose checks. Tail canaries for smaller configurations prove restoration leaves memory beyond the required prefix untouched.

11. **Full DDRAM.** All 153 cases pass: 17 scenarios x 3 sizes x no stalls/fixed stalls/LFSR randomized stalls. Each accepted current payload is checked byte-for-byte in DDRAM, then against guest reads after restore. Per-operation word counters prove exact lengths. Scenarios include current format, untagged/v1/v2/v3/v4, older64K, malformed/unsupported metadata, size mismatch, repeated operations and later writes. Fixed/random runs also attempt CPU writes during frozen transport.

12. **Negative controls and persistence.** Zero-size SC and ordinary SMS controls transfer no cartridge RAM. Existing EEPROM/non-EEPROM/System E and ordinary SRAM controls pass. A full SC restore marks dirty only when the existing host policy enables persistence; normal 64-sector SAVE proceeds after savestate release. Existing in-progress-SD exclusion, queued save/load, EEPROM restore dirty tracking and normal guest write behavior pass. SAVE-port content readback covers all configured SC bytes. The normal SAVE remains 32768 bytes; unused physical tail bytes retain their existing contents. No Sega persistence eligibility or ownership policy changes.

13. **F06 unchanged.** Static checks compare all original 8/16/32 KiB/combined SRAM predicates and size branches byte-for-byte with HEAD and verify equivalent selection when SC size is zero. Mapper, decode, backing implementation and normal persistence policy are unchanged. Re-running `sram_architecture` confirms both banks retain their original behavior across disable/reset/reload and persistence events. The current-format ordinary SRAM 16 KiB control also passes. F06's disabled/second-bank savestate omission is **intentionally unresolved**, not claimed fixed or counted as a new F05 regression.

14. **Regressions.** PASS: original audit IO/EEPROM/MD scenarios and static checks; F07 real SMS/GG HCounter replay, ten controller compatibility cases and dual-real-VDP DDRAM integration; F02 24 local serial cases and fourteen DDRAM cases; F08 2560 directed short-timer cases, 160 real-timer cases and thirteen DDRAM cases; F03/F04 6642 protocol/backing replay cases and twenty DDRAM cases; explicit historical v4 EEPROM load with randomized stalls; existing EEPROM persistence scenarios plus SC restore; PSG 128-case replay; relevant SC routing/no-RAM checks and SRAM architecture characterization. Simulation logs contain no assertion failures or errors. Expected simulator warnings are Altera mixed-port read modeling and Starter Edition capacity warnings; they are distinct from FPGA build warnings.

15-18. **Quartus, timing, resources and warnings.** Full Quartus Prime 17.0.2 Build 602 compilation, synthesis, fitter, assembler and TimeQuest succeeded on 5CSEBA6U23I7 with unchanged seed/settings. Elapsed compilation time: 26:01. The successful committed F03/F04 baseline matches all 136 source/settings inputs; all 136 candidate inputs also match the working tree. Both generated build IDs are 261020.

| Resource | Committed F03/F04 | F05 | Delta |
|---|---:|---:|---:|
| ALMs | 26914 | 26958 | +44 |
| Fitted registers | 36452 | 36355 | -97 |
| RAM bits | 3809858 | 3809858 | 0 |
| RAM blocks | 487 | 487 | 0 |
| DSP blocks | 39 | 39 | 0 |

Synthesis registers: 35506 versus 35498 (+8). Synthesis and fitted totals are distinct counts after physical optimization. No additional FPGA RAM allocation.

Worst setup slack **0.409 ns** (baseline 0.636 ns); worst hold slack **0.246 ns** (baseline 0.246 ns). All reported slack and TNS checks are nonnegative. Timing violations: **0**.

New warnings: **0**. New critical warnings: **0**. Distinct normalized numbered warnings remain 84, including the same 38 critical warnings. Quartus reports 100 total warnings; 98 numbered diagnostic occurrences appear in the captured log. The normalized comparison is retained in results.json.

19-20. **Final diff and status.** Complete production diff reviewed; only F05 configuration, metadata, transport selection and SC restore dirty tracking changed. `git diff --check` passes. No staged files or generated Quartus artifacts.

`git diff --stat`:

```text
 SMS.sv            |  5 +++++
 rtl/savestates.sv | 64 +++++++++++++++++++++++++++++++++++++++++++++----------
 2 files changed, 58 insertions(+), 11 deletions(-)
```

`git status --short`:

```text
 M SMS.sv
 M rtl/savestates.sv
?? tests/
```

21. **Recommendation: READY TO COMMIT (F05 only).** Complete SC RAM is preserved; historical missing RAM is retained; F06 remains unresolved and unchanged. All requested regression groups pass, and Quartus has no new warnings or timing violations. Nothing staged, committed, pushed or submitted as a PR.
