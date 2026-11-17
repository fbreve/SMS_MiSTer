# C1 hardware readiness review

C1 seed 1 has a valid, preserved RBF ready for MiSTer hardware testing. This is readiness for testing, not evidence that hardware testing has already passed. No Quartus process was started, no source was changed, and no historical build artifact or report was rewritten by this review.

## Build integrity

All six B1/C1 builds completed map, fit, asm, sta and report queries with exit 0. Every stage has a valid completion marker; every artifact hash recorded in those markers matches. All build.done markers exist and no build.failed marker exists. Original tool reports contain successful completion with zero errors. B1 seed 3 completed successfully as a tool run but failed setup timing.

All 221 input hashes per build match their frozen manifests. The five substituted files match their respective validated B1/C1 worktrees. All other inputs match the full-state frozen seed-1 inputs byte for byte, with only the specified SMS.qsf SEED substitution. Installed Quartus executable hashes match the reference tool hashes. Reports identify Quartus Prime 17.0.2 Build 602, device 5CSEBA6U23I7, top sys_top, revision SMS, and the correct fitter seed. QSF/SDC hashes match; expanded global and instance settings are identical across all six builds after normalizing only project path and seed. No SDC constraints were ignored.

The original study_results.json and study_results.md were regenerated entirely in memory using the collector, and both matched exactly. Historical result files were not written. Original report hashes, physical path report hashes, RBF hashes and reused reference-results hashes also match.

| Seed | B1 setup ns | B1 hold ns | B1 setup TNS ns | C1 setup ns | C1 hold ns | C1 setup TNS ns |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | 0.438 | 0.241 | 0 | 0.566 | 0.245 | 0 |
| 2 | 0.344 | 0.076 | 0 | 0.520 | 0.225 | 0 |
| 3 | -0.036 | 0.245 | -0.044 | 0.430 | 0.242 | 0 |

All six hold TNS values are zero. C1 passes all reported TimeQuest check types in all three seeds. The timing qualification remains limited to constrained paths: preserved reports show zero unconstrained clocks, but 27 unconstrained input ports / 94 input paths and 91 unconstrained output ports / 153 output paths. This is already reflected in the study's qualification note. Warning text and counts reproduce the original collector results; they are not zero-warning builds.

## Fitted register evidence

The original Fitter Resource Usage Summary explicitly separates design implementation, routing optimization and I/O registers. These categories exactly account for the fitted total:

| Seed | Variant | Mapped | Design implementation | Routing optimization | I/O | Fitted |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | B1 | 34737 | 33932 | 1527 | 101 | 35560 |
| 1 | C1 | 34731 | 34199 | 1489 | 101 | 35789 |
| 2 | B1 | 34737 | 33932 | 1436 | 101 | 35469 |
| 2 | C1 | 34731 | 34199 | 1512 | 101 | 35812 |
| 3 | B1 | 34737 | 33932 | 1470 | 101 | 35503 |
| 3 | C1 | 34731 | 34199 | 1529 | 101 | 35829 |

C1 has six fewer mapped registers but 267 more Fitter design-implementation registers. Routing differences are -38, +76 and +59, accounting exactly for fitted increases of +229, +343 and +326. The increased fitted count therefore does not represent an increase in the synthesis-reported RTL register count.

The Fitter Netlist Optimizations table documents 754 `Retimed Register / Physical Synthesis / Timing optimization` entries for each C1 seed; B1 has none. C1's retiming messages report estimated slack improvements of 582, 580 and 586 ps. Register-packing timing-optimization duplication entries are 318 for C1 versus 162 for B1, and C1 has an additional `Created 156 register duplicates` message after physical synthesis. Router duplication entries exactly equal the routing-register counts above. These are documented optimization differences, not a claim that every optimization-table entry corresponds to one net additional register. The reports do not provide a complete one-to-one causal ledger attributing all 267 design-implementation registers to one particular transformation.

Original evidence: [seed-1 C1 Fitter](../ym2413_b1_c1_seed_study/seed1/c1/output_files/SMS.fit.rpt), [seed-1 B1 Fitter](../ym2413_b1_c1_seed_study/seed1/b1/output_files/SMS.fit.rpt). Extracted categories and optimization counts for all six builds are in integrity_evidence.json.

## Memory implementation

All six builds use OutputMemory MLAB: two RAM-summary instances total 20 MLAB cells, 380 logical bits, zero M10Ks. The entire design uses 489 M10Ks. RegisterMemory and FeedbackMemory do not appear as inferred RAMs in the Fitter RAM Summary. Analysis & Synthesis explicitly reports both arrays uninferred because `logic` is set as their ramstyle attribute; fitted entity rows also show zero memory ALMs, block-memory bits and M10Ks for those entities. They remain implemented in logic. A physical location label such as MLABCELL in a control-signal report does not change that RAM-inference evidence.

## Exact C1 seed-1 bitstream

Path:

```text
C:\Users\fbrev\Documents\Diversos\Dev\SMS_MiSTer\tests\ym2413_b1_c1_seed_study\seed1\c1\output_files\SMS.rbf
```

SHA-256:

```text
7f4ba7e188c99a5ae623e49e4df4311084a23fbd47404a93de3ab974e728fafa
```

Size: 4,132,904 bytes. Its hash matches both the original asm completion marker and study results. It was not rebuilt, renamed, copied over another RBF, or deployed by this review.

## Comment audit and encoding

No confirmed mojibake exists in the five reviewed C1 production files. Consequently, changed comment lines: **none**. Executable tokens and RTL logic are unchanged, proven by byte-for-byte unchanged source hashes, not only by comment stripping.

- `rtl/VM2413/outputgenerator.vhd`: legacy Shift-JIS. Japanese comments at lines 123, 137, 185 and 186 decode correctly using Shift-JIS and have byte-identical counterparts in baseline commit 9873761 and B1. Decoding this file as UTF-8 produces replacement characters; it is not evidence that the source bytes themselves are damaged. Do not save an editor's replacement-character rendering over the file.
- `rtl/VM2413/outputmemory.vhd`, `rtl/VM2413/temporalmixer.vhd`, `rtl/opll_snapshot.sv`: ASCII comments; no suspicious encoding sequences.
- `rtl/savestates.sv`: valid UTF-8. Its 25 non-ASCII comment lines contain correct multiplication, approximation and arrow characters, with identical raw comment lines in baseline and B1. No double-encoded UTF-8 sequence was found.

The exact reported `Ãƒâ€”` corruption **does exist in the main workspace's** `rtl/savestates.sv`, along with double-encoded approximation/arrow characters, affecting 25 lines. That is a different file from the C1 worktree file. The main workspace file was read only and remains untouched under the restriction against modifying master. Its affected lines and original hash are recorded in integrity_evidence.json. No repair was propagated to baseline, B1, sys/ or historical synthesis inputs.

Original C1 bytes were preserved under original_sources/. source_hashes_before.json and source_hashes_after.json separately record identical original/current hashes. The exact original CRLF and mixed CRLF/LF layouts remain unchanged.

Relevant source-editing/preparation scripts were inspected. Paired latin1 input/output preserves raw bytes, including Shift-JIS and UTF-8; it must not be replaced blindly with UTF-8 decoding. Buffer-based preparation copies also preserve source bytes. No incorrect latin1-read/default-UTF8-write production-source path was found in the reviewed scripts, so no script changes were necessary. Detailed findings and script hashes are in script_encoding_audit.json. This review does not identify the earlier operation that corrupted the main-workspace comments.

## Provenance and next action

The existing C1 seed-1 RBF matches its recorded artifact hashes, and the five reviewed current C1 RTL files exactly match their frozen build-input hashes. The full 221-file frozen input manifest also verifies. No build is needed before testing that preserved binary. No comment cleanup was required in C1.

If comment-only cleanup is later performed, it need not trigger synthesis merely to preserve RTL behavior, provided byte-level comment bounds and executable-token equivalence are verified. Retain the original source hashes, cleaned source hashes and equivalence record as a provenance bridge; the existing RBF must retain its original build-input hashes. Claiming a newly built RBF from cleaned source hashes requires a separately authorized build. No such build has been started.

Verification code: verify_readonly.js. Its writes are limited to this new audit directory. It rechecked all protected-file hashes at the end of the review. No optimization experiment, commit, merge, push or PR was started.
