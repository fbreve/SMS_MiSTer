# G12 live-SDRAM restart fix

Authorized scope is G12 only. Production change: `SMS.sv` selects raw /15
SDRAM reference during private CPU replay. No new state or format; v16 remains.
The original investigation is preserved in `../savestate_g12_sdram`.

Use Node at `C:/Program Files/nodejs/node.exe`, PowerShell with
`-NoProfile -ExecutionPolicy Bypass`, ModelSim17.0 and Quartus17.0.2 at the
retained local installation paths. Run scripts from the repository root.

Before production edits on committed v16 with an empty tracked diff:

1. `prepare.js`, then `run.ps1 -Compile -Fast 0` for the exact baseline witness.
2. Run the other three saved/current Pause combinations in the baseline fixture.
3. Compile the prototype with `run.ps1 -Fixture prototype -Compile`; repeat
   full flush and all four Pause combinations.
4. `prepare_protocol.js`; compile `run.ps1 -Fixture protocol -Compile`, run
   all four Pause combinations, `phase_sweep.ps1` shards0..2, and TAC0/7.
5. `prepare_matrix.js` and `prepare_additional.js`; run `matrix.ps1 -Fixture
   matrix -Compile` and selected shards, then `-Cases additional_cases.json`.
6. `prepare_g01.js`, then `g01/run.ps1` for ten targeted current-controller
   prefix/EI/HALT/restart cases.
7. `check_sufficiency.js` must pass before `apply.js` changes production.

After the production patch:

1. `prepare_final.js` extracts the literal clkref expression from current
   SMS.sv into fresh final fixtures; `prepare_focused.js` adds GG-normal and
   System E TAC7 three-LOAD cases.
2. Compile `run.ps1 -Fixture final_protocol -Compile -Fast 0`; this is the
   production-flush original witness with strict exactly-once/freshness checks.
3. `final_protocol.ps1` shards0..2 recheck four Pause combinations, twelve
   transport offsets and legal TAC0/7 arrival. Each paused LOAD later unpauses.
4. Compile and run `matrix.ps1 -Fixture final_matrix` with shards0..3, plus
   `-Cases focused_cases.json`. All51 cases have independent reference and
   replay runs; shared-transfer coverage is only a sanity set and history pair.
5. `check_simulations.js` validates source identity, all completed logs, known
   complete v16 images, unchanged historical proof hashes, exact suffix counts
   and both same-image histories. A check while campaigns are active correctly
   fails closed; such status probes are not failed functional simulations.
6. Only then `prepare_build.js` creates fresh source-only v16/candidate builds.
   Run `build.ps1 -Version v16`; an overlapping candidate is permitted only
   with `-ParallelControlPID` naming that exact guarded control shell.
7. `prepare_collector.js`, `collect_build.js`, `resource_analysis.js`, and `write_report.js` collect
   full flow/resources/warnings and the requested54-item review.

No script stages, commits, pushes or creates a PR. `prepare.js` intentionally
refuses to overwrite the pre-edit baseline after production edits. Reproducing
that phase requires a separate clean committed-v16 worktree, not discarding
the user's working changes.

## Fixture scope and adaptations

The physical chip model, real T80, production mapper/decode/memory bus, actual
divider, Pause process, dual JT89/AudioMix and savestate controller come from
the retained G12 investigation. The final bridge verifies the one changed
top-level expression. Other current production files retain baseline hashes.
System E /10 and SMS /15, GG normal/turbo shared unencrypted ROM paths are
covered with BIOS disabled. This is not a GG link, encrypted ROM, commercial
game or physical FPGA campaign.

ModelSim-only adapters retain prior documented semantics: resolved-wire DQ
driver instead of procedural inout; named access-manager block; controller
forward declarations; observation ports; nonbinary mapper case fallback.
Fast-flush cases shorten only the900000 transport wait, retaining255 settlement.
Original and final full-flush witnesses do not shorten it. No historical CPU,
Pause, divider or SDRAM register is forced. UI cooldown is bypassed for repeated
requests. Immutability/media and initialized SDRAM are session prerequisites.

The independent golden CPU receives matching restore/enables and raw immutable
ROM bytes directly; it bypasses only live SDRAM timing. Freshness assertions
require one accepted and one returned request before first restored consumption,
with matching owner/address/data. General reference campaigns compare complete
CPU/address/strobes/signatures and raw/stereo state at every logical host clock.
Full images reject unknown words. Irrelevant inactive read-cycle output data is
not treated as a guest write. Inactive tristate DQ is not an X-equality oracle.

Inherited ModelSim warnings are recorded, including the unused block-IO mask
width and unconnected unused observation outputs. The new tested programs do
not use block IO; targeted G01 regressions retain their documented adapter.
No warning or mismatch is silently converted to a passing functional result.

Early `prototype` logs and extra verbose pre-unpause traces are retained as
supporting evidence. The canonical strict request ledger is `protocol` and
`final_protocol`; exact counts come from machine-readable simulation results.
Generated libraries, duplicate stdout, reference streams and Quartus trees are
ignored. The existing untracked tests tree predates this task.
