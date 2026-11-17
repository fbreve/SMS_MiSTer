# Title

Preserve physical SRAM in savestates to fix Ys map corruption

# Description

Depends on [FM savestate PR #227](https://github.com/MiSTer-devel/SMS_MiSTer/pull/227), currently at `8cd53ccc954c24970372ea6d8a3fb2336a14c46f`. The SRAM-only diff is against that head, not current upstream master.

Ys can restore a correct screen and then progressively display incorrect map tiles as the player moves. SRAM disabled in the saved mapper state was omitted from the snapshot even though its physical contents were needed later. In the playable reproduction, LOAD retained 1,479 stale SRAM bytes. The trace connects a wrong tile at physical SRAM `0462` to WRAM `D820`, then VRAM `3A20` through a CPU VDP write.

Preserve the complete eligible physical 32 KiB SRAM backing independently of mapper visibility and bank selection. Keep System E, SC-3000, EEPROM and Evolution behavior excluded from the new full-SRAM path. Only `SMS.sv` and `rtl/savestates.sv` change; the optimized FM implementation is retained.

The 96 KiB snapshot size is unchanged. Marker `0x484314` identifies FM plus complete SRAM; existing FM marker `0x484311` and legacy formats retain their historical SRAM footprints. Both owned FM markers require the existing audio completion commit, rejecting interrupted replacement saves before restoration. Old snapshots cannot recover SRAM they omitted; fresh saves are needed for the Ys correction. New-format saves require the new reader. The completion marker is not a checksum or rollback guarantee for interrupted LOADs.

Validation:

- Actual-controller playable Ys SAVE/environment-change/LOAD/movement reproduction: baseline corruption reproduced; candidate matches uninterrupted execution at all 46 rendered checkpoints and in final VRAM, WRAM and SRAM. No CPU predecessor or VDP pipeline correction is included.
- User-reported real MiSTer hardware PASS for seed-1 RBF SHA-256 `3ebda245e566f22ed2ec1b363359b58f9f83804ad83c5ce83626d431eef103bd`; no specific per-game results were supplied.
- 108 fresh post-commit controller, legacy compatibility, complete SRAM, stalled/interrupted transfer, repeated LOAD, exclusion and ordering cases passed. Existing actual-OPLL capture/restore and FM-disabled evidence is retained by exact qualified source identity.
- Matched Quartus Prime Lite 17.0.2 builds, device `5CSEBA6U23I7`, paired seeds 1/2/3 against the exact FM baseline: +2 mapped registers; unchanged M10K, memory bits and DSPs. Needed-ALM deltas −82/+2/−100; placed-ALM deltas −8/−6/+46, reflecting implementation/seed variability. Candidate setup/hold slack: 0.381/0.244, **0.053/0.243**, 0.148/0.242 ns. All three pass constrained timing with zero setup/hold TNS and no new critical warnings.

The source committed as `ff70cb70ce9724d97cd5cc2946c14ba21c809a96` reproduces the hardware-qualified inputs exactly through Git checkout filters. No recompilation was needed after committing.
