# Investigation status

Recommendation: **retain complete restoration; NO-GO for adopting a reduced variant on current evidence**. This is an adoption decision, not proof that every possible reduction is impossible.

The requested investigation is **not fully qualified**: no two-second continuation, game-specific reduced-state replay, hardware audio comparison, or reduced-state Quartus build has completed. Short runs cannot answer the maintainer's proposed one-to-two-second settling bound. No resource-saving claim is made.

The separate branch `experiment/fm-state-reduction-20261116` and worktree start at exact reference `8cd53ccc954c24970372ea6d8a3fb2336a14c46f`. Production RTL remains unchanged there. Experimental variants are implemented as selected restore-write suppression in `ablation_tb.vhd`, preserving the complete reference in the other instances. Reports and simulation outputs are in this parent directory, outside the branch's tracked tree. Nothing was committed, pushed, merged, or published.

Start with `STATE_INVENTORY.md`, `VARIANTS.md`, `source_manifest.json`, and the generated `REPORT.md`. JSON result records and per-run logs/audio CSVs are retained. `compile.log` includes failed portability attempts before successful compilation; these were harness preparation failures, not functional RTL failures. Simulation-only adapters are regenerated from unchanged reference RTL by `compile.js`.

Existing real-OPLL work informed the component ordering, GHDL tool selection, word map, and production enable cadence. This new harness does not replace the existing end-to-end, legacy, disabled-FM, mode, and hardware qualifications. None of those qualifications transfers automatically to a reduced implementation.

Double Dragon, Ys and California Games remain mandatory acceptance scenarios. The PR discussion reports that the old missing-FM-history corruption lasted until a stage/environment/event change; that does not establish what a partial restore will do. Local Ys SRAM fixtures establish a separate memory defect and must not be relabeled as FM audio tests. Replayable FM failure captures for the three scenarios have not been identified in this investigation.

Do not build reduced RBFs until a specific omission survives broad phase/mode/voice coverage, a sustained non-silent continuation beyond two seconds, repeated loads, later musical writes, internal phase/envelope/feedback/rhythm checks, and the game scenarios. Then use matched Quartus 17.0.2 builds with the exact reference, identical inputs/settings/seeds, reporting needed and placed ALMs, mapped/fitted registers, M10K, DSP, setup/hold, and TNS. The fixed 256x32 transport RAM remains one M10K when only a few restore fields are omitted. A lower payload count alone does not prove its removal.

A different strategy worth investigating is preserving every bit while reducing repeated serializer/decoder/control logic or consolidating memory access. Such changes can be checked against the exact full-state oracle without relying on acoustic settling. No implementation benefit is claimed until measured.
