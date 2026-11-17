# G11 investigation artifacts

Baseline HEAD: cb2e8615128d61adb996ada68e6bbdcc314c20f6, v16.
Toolchain: ModelSim Intel FPGA Starter10.5b from the local Intel17.0 install,
Node.js and PowerShell. No Quartus invocation is part of this investigation.

The final result is in review.md; detailed dependencies, fixture adaptations,
ordering bounds and exact witnesses are in architecture.md, fixture.md,
ordering.md and causal_evidence.md. JSON collectors retain exact case status,
full-image comparisons, payload classes and unchanged-source evidence.

To rebuild the fixtures on the same baseline, run prepare_lut.js, lut.ps1,
prepare.js, prepare_campaign.js, prepare_campaign.js phase, prepare_cache.js,
prepare_pause.js, prepare_streams.js and prepare_joystick.js in that order. Helpers oracle.do,
recovery.do and mc_recovery.do run from this directory with local ModelSim.
The current production source bridge is checked by check_source_bridge.js.

Canonical integrated runs:

```powershell
./run.ps1 -Fixture matrix -Cases cases.json -Compile -Shard 0 -Shards 3
./run.ps1 -Fixture campaign -Cases campaign_pilot.json -Compile
./run.ps1 -Fixture campaign -Cases targeted.json -Shard 0 -Shards 3
./run.ps1 -Fixture campaign -Cases targeted.json -Shard 1 -Shards 3
./run.ps1 -Fixture streams -Cases targeted.json -Compile
./run.ps1 -Fixture joystick -Cases collisions.json -Compile
./run.ps1 -Fixture phase -Cases resave.json -Compile -Shard 0 -Shards 2
./run.ps1 -Fixture phase -Cases resave_shift15.json
```

The phase-shift15 canonical run reused the completed identical uninterrupted
reference from the scoped phase-odd reference pilot; reference_source.txt
records that provenance. A fresh run without ReferenceFrom regenerates the
same reference independently. Delay affects only LOAD tail reads, not the
uninterrupted reference or initial SAVE image.

Run run_pause.ps1 for each Mode1/2, SavedPaused0/1 and CurrentPaused0/1,
Delay8, with Compile once. All use24000 suffix clocks except the retained
Sega saved-paused/current-running witness, which uses12000. pause_suite.ps1
is a shardable convenience runner and reuses that completed canonical witness.
Each independent case must have its own leaf directory; do not start the same
case twice concurrently.

After runs finish, execute check_collisions.js, check_contexts.js,
check_source_bridge.js, check_integrity.js and collect_results.js. The report
writer refuses closure until all required runtime/integrity gates pass.
Compiled libraries and large transient reference files are locally ignored.
Retained invalid/debug pilots are explicitly excluded by the collector;
their corrections are documented in fixture.md. Nothing is staged or committed.
