# First public FM snapshot: version 1 integration plan

Status: planning only. No integration worktree, descriptor change, simulation campaign or Quartus build has been started. Versions 17, 18 and 20 were unpublished local experiments. They have no external FM compatibility contract. Existing non-FM savestates do have a compatibility requirement.

## Frozen starting point and minimal runtime change

Create the final integration worktree later from pinned commit `9873761503510e4b2c7e06600bf5515344235c2f` and the five validated C1 production files, not from the main workspace's unrelated dirty RTL. Pin dependencies and record the complete input manifest before editing. Preserve every original C1 input, report and RBF.

The only required functional change relative to validated C1 is in `rtl/savestates.sv:297`:

```systemverilog
localparam [63:0] FM_DESC = {16'd100, 8'd1, 8'd1, 32'h464d5331};
```

Exact descriptor: `64'h00640101464d5331`.

| Bits | Meaning | Required value |
| --- | --- | --- |
| 63:48 | Number of private 32-bit words | 100 |
| 47:40 | FM snapshot format version | 1 |
| 39:32 | Existing owner/schema discriminator | 1, unchanged |
| 31:0 | Existing FMS1 signature | 0x464d5331, unchanged |

Change only the version byte `8'd20` to `8'd1`. The trailing `1` in the FMS1 signature is not a second field to renumber. Update comments at lines 23, 290 and 296 to describe the first public FM format; do not edit those lines in frozen C1.

Both the command scheduler (`ST_FM_LOAD_DESC`, line 582) and sequential descriptor validator (line 1111) already compare against the shared `FM_DESC`. Save paths (lines 581 and 1106) already write that same constant. No additional decoder branches, experimental-version whitelist, conversion path or migration support are required. Preserve exact full-descriptor equality: an FM-tagged image with any incompatible descriptor must reach `ST_ERROR`, not the legacy fallback.

## Layout, guard and legacy behavior that must remain identical

- Keep `rtl/opll_snapshot.sv` byte-identical to C1: `WORDS=100`, its capture/apply endpoints, 256x32 M10K transport scratch, refill behavior and deterministic missing-history fallback.
- Keep the other three modified VHDL files byte-identical to C1: `outputgenerator.vhd`, `outputmemory.vhd`, `temporalmixer.vhd`. Their mixed source encodings are not part of this migration.
- Keep descriptor address 0x2997, payload addresses 0x2998..0x29c9 inclusive, and 50 DDRAM transfers indexed 0..49. Retain the 96 KiB slot size, slot/BIOS bases, existing header and discovery marker `FM_MAGIC=24'h484311` in video word 0x01a, with reserved bits [39:22] zero.
- Preserve all 100 per-word masks and range checks, including word 78 mask `0x0000007f`, word 79 OutputGenerator state, word 99 bounds, SlotCounter phase coherence, and the C1 omission of TemporalMixer mute/maddr/mix/mixout. No repacking, renumbering or counter-width change.
- Preserve the same-transfer OutputMemory MLAB collision check at `rtl/savestates.sv:1114` exactly: `fm_word==39 && dout_latch[33] && (dout_latch[1:0]!=2'b00)`. Keep its position before `fm_bulk_write`. Pair 39 contains words 78/79; stage-zero pending writes remain legal. Retain the MLAB attribute/inference and logic implementations of RegisterMemory/FeedbackMemory.
- Preserve non-FM 64 KiB and untagged 96 KiB load paths, game/BIOS ownership checks, existing PSG/audio descriptors and old-format handling. Their version fields are separate from FM_DESC; do not renumber them. Untagged legacy images ignore the FM tail even if it contains an experimental or corrupted descriptor. Their deterministic FM fallback still applies words 76..99 (24 words).
- No FM-tagged version 17, 18 or 20 is accepted. A tagged incompatible FM image is rejected before FM/core apply; it is never treated as a non-FM legacy image.

## Dependency audit and exact test/tool changes in the new worktree only

`descriptor_dependency_audit.json` records paths, line numbers, content and hashes for the audited current source/test/document/tool references. The following are changes to future copies, not instructions to rewrite historical evidence.

| File or group, relative to source described below | Required integration change |
| --- | --- |
| C1 `worktree/rtl/savestates.sv` | One version byte and three version comments, as above. All other executable bytes unchanged relative to C1. |
| Validated `verification_c1/tests/ym2413_fullstate/protocol_tb.sv:52,56..58` | Independent positive check for literal `00640101464d5331`; label PASS as public FM v1; retain v17/v18 rejection and add v20 rejection. Restore the v1 descriptor after every negative case. |
| Validated `guard_protocol_tb.sv:52,56,69..70` | Same version changes. Keep counterexamples A/B, stage-zero acceptance, back-to-back recovery and unchanged layout/reserved-bit checks. |
| Validated `guard_live_tb.sv`, `tb.sv` | Retain native-DDRAM live load/save/oracle comparisons and legacy tests. Add explicit live rejection of all experimental descriptors before any FM/core apply, then a successful v1 reload. The existing guard_live comment mentions v17 rejection but its corresponding final sequence exercises A/B, not an explicit v17 descriptor assignment: add actual coverage, not merely a new comment. |
| Validated `validator_stream_tb.sv`, `early_validator_stream_tb.sv` | They initialize `dut.dout_latch=dut.FM_DESC`, so regenerate/compile against v1 and retain stream/early-rejection tests; keep the independent literal positive check in protocol tests to avoid a self-confirming expectation. |
| Generated `savestates_sim.sv`, `savestates_fast.sv`, `ports.svh`, compiled libraries | Regenerate from final v1 production RTL in a fresh validation directory. Do not hand-patch generated or historical copies. Keep only documented simulation adapters; fast FLUSH_MAX remains simulation-only, with a native FLUSH_MAX case retained. |
| Validated `combined_tb.vhd:623..627,668..669` | Replace misleading candidate diagnostic labels `v18`/`v20` with `public FM v1` or layout-specific wording. Keep 100-word candidate mapping, moved word 79, eliminated words 100..103 zero checks, four-register poisoning and the complete convergence/oracle checks. |
| `oracle.tcl`, `map_tb.sv`, `acc_tb.vhd`, `prepare_native_c1.js`, `instrument_oracle.js`, VHDL reference model | Carry forward the validated C1 packing, masks and independent oracle/poison instrumentation without changing their algorithms. Local word-level tests need no descriptor renumbering. A 104-word internal full-state oracle is not a 104-word public snapshot: do not globally replace 104 with 100, 52 with 50, or all occurrences of 17/18/20. |
| Inherited `worktree/tests/ym2413_fullstate/protocol_tb.sv:38,41` | Stale v17/104-word expectations: replace the integration copy with the validated 100-word C1 fixture updated for v1. Do not run the inherited fixture unchanged. |
| Inherited `verify_scope.js:6..7,26..27` | Replace obsolete branch/base/scope assertions with the pinned integration identity and reviewed C1+version-byte delta. Change metadata to `privateWords:100`, `descriptorVersion:1`, `ddramTransfers:50`, `payloadLast:0x29c9`, bounds `0x2998+50-1==0x29c9`. Existing 104/52/0x29cb/version17 metadata is stale for C1. |
| `prepare_tests.js`, `.do` files, `run_all.ps1`, campaign runners | Retarget production/reference/output directories to the final integration and fresh validation copies. Wire the validated protocol, guard, early/stream validator, non-FM, live modes and 72-phase combined fixtures into the actual entrypoint. Check return codes, compile paths, source hashes and version-specific PASS markers. Do not invoke original scripts in their historical directories. |
| Validated `collect_c1_campaign.js:37..71,340..346` and report tooling | Create an integration collector with pinned final branch/worktree/reference paths and fresh source/tool/log hashes. Set format metadata to version 1, 100 words, 50 transfers, full literal descriptor. Require independent positive and explicit 17/18/20 rejection evidence before reporting PASS. Retain separate preservation checks for historical C1/B1; never relax their original hashes. The `*104` full-state comparison metric is an oracle width, not a format bug. |
| `source_identity.json`, manifests and any new result JSON/Markdown | Generate new v1 identities and hashes from actual inputs/tests. Do not edit old c1_campaign_results.json, study_results files, input manifests, stage markers or reports to say version 1. |
| Existing seed-study preparation/preflight/collector | Keep frozen. They pin old paths/hashes and correctly describe v20 C1 and the experimental `v17_104w` reference. A future v1 build needs separate directories, manifests, logs and markers; do not reuse v20 build.done or inject a new source hash into an old result. |

## Descriptor test matrix

Require tests through both descriptor command gating and sequential validation, including native DDRAM live transport. For negative FM-tagged cases assert `ST_ERROR`, no FM/core apply and no payload-read command caused by a rejected descriptor; verify a subsequent valid operation recovers.

| Descriptor | Expectation |
| --- | --- |
| `00640101464d5331` | Accept/save exactly this public v1 descriptor; capture/apply addresses 0..99 and transfer indices 0..49. |
| `00681101464d5331` | Reject original experimental v17/104-word descriptor. |
| `00641201464d5331` | Reject original experimental v18/100-word descriptor. |
| `00641401464d5331` | Reject original experimental v20/100-word descriptor, even though its payload layout equals public v1. |
| `00641101464d5331` | Reject version 17 even with the correct 100-word count, isolating the version check. |
| v1 with wrong count, owner/schema, signature, version 0 or version 2 | Reject; do not weaken full-descriptor equality into a version-only check. |
| Untagged legacy 64/96 KiB image with stale valid/invalid/v17/v18/v20 FM tail | Follow unchanged non-FM fallback; ignore the FM tail. |

Retain existing malformed payload, reserved bit, phase-count, pending-write guard A/B, stage-zero acceptance, ownership/signature, legacy-mode, map/oracle and initialization-readiness coverage. Preserve public-v1 round-trip checks in SMS, GG, System E and BIOS modes.

## Documentation and release wording

Add a public format section to the integration README (or linked format document) documenting descriptor bits/literal, 100-word map, 50-transfer boundaries, MLAB collision invariant and non-FM fallback. State explicitly: "FM snapshot version 1 is the first public format. Versions 17, 18 and 20 were unpublished local experiments and are rejected when FM-tagged."

The audited root/C1 README files currently have no public FM-version compatibility claim to remove. Correct inherited labels, stale format metadata and any copied integration prose implying that these laboratory versions were public releases. Do not rewrite lab handoffs, old PASS messages, old branch names, full-state oracle references or original study columns: retain those as experimental historical evidence. Rejection test labels should call 17/18/20 experimental, not legacy/public. General non-FM compatibility claims remain valid and distinct.

## Validation and release gate (future work, not launched)

1. Freeze an integration input manifest. Compare to validated C1: the only executable RTL delta must be FM_DESC[47:40], 20 -> 1; all layout/mask/guard logic and the other four modified C1 files must match. Verify unrelated production inputs/dependencies and non-FM state machines unchanged.
2. Regenerate fixtures from those exact sources. Run positive/negative descriptor, map, full/native and fast protocol, A/B guard, stream validation, non-FM legacy and live MODE=0..6 tests. Require the independent literal descriptor check and experimental rejection cases in collector output.
3. Re-run complete 72-phase differential validation against the preserved independent reference, retaining four-register poisoning, enabled-clock convergence limits, late writes, capture/recapture and audio/internal-state checks. Old C1 PASS evidence is supporting evidence, not a v1 run.
4. After explicit authorization, build v1 separately with the pinned Quartus 17.0.2/device/settings and fresh output directories. Recheck actual timing and OutputMemory MLAB / RegisterMemory and FeedbackMemory logic. A three-seed repeat would provide the same timing robustness evidence as the current study. Do not infer final v1 timing or an RBF from the v20 results.
5. Record the final v1 RTL/test/report/RBF hashes and perform appropriate hardware save/load validation, including positive v1 and negative experimental-descriptor cases. Do not relabel or reuse a v20 RBF as a v1 artifact.

## Preserved initial hardware candidate

The existing C1 seed-1 binary remains experimental descriptor version **20** and is suitable for initial hardware validation:

```text
tests/ym2413_b1_c1_seed_study/seed1/c1/output_files/SMS.rbf
SHA-256 7f4ba7e188c99a5ae623e49e4df4311084a23fbd47404a93de3ab974e728fafa
```

Its hash was checked while correcting main-workspace comments. No binary, C1 source, historical evidence or experimental descriptor was changed. Public version 1 will need its own validated source identity and separately authorized build.
