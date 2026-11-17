# Hardware qualification addendum — 2026-11-16

The user confirmed successful real MiSTer hardware testing of the following experimental artifact:

- RBF: `../ys_fm227_validation_20261115/release/SMS_ys_sram_fm227_69edeb48_p8e59c978_s1.rbf`
- SHA-256: `3ebda245e566f22ed2ec1b363359b58f9f83804ad83c5ce83626d431eef103bd`
- Result: **hardware PASS, reported by the user**.

The confirmation did not enumerate individual games, ROM hashes, reset types, repetitions, audio observations or photos. No per-game PASS or completion of every item in the prepared hardware procedure is inferred. The confirmation date recorded here is 2026-11-16; the exact test time was not supplied.

This addendum updates the qualification record without overwriting the original report, release manifest, hardware procedure or RBF. Their statements that hardware was untested describe the state when those records were created. This addendum supersedes that status only for the identified seed-1 artifact. Seeds 2 and 3 retain their compilation qualification; no hardware test of them was reported.

The qualified source was HEAD `69edeb48455820d3119ab54d052bf3de906c91fa` plus correction patch SHA-256 `8e59c978d1cecf4bb0f86d5b3f4ffd8bcb104f34a66637f6b5b7ee61480df0a4`. The correction is now committed as `ff70cb70ce9724d97cd5cc2946c14ba21c809a96` on `fix/ys-physical-sram-on-fm-pr227`.

Both compiled RTL input hashes are unchanged:

| File | Qualified/unchanged Windows source SHA-256 |
|---|---|
| `SMS.sv` | `a58f21d3d8421e726dd5cb6c08acc79be549abadc6f35f892056831c9a1f4120` |
| `rtl/savestates.sv` | `fa3c4334433284a930c26e6f30b348935738a66e8dd56f756368c44439fe2303` |

Git stores LF blobs and the original compiled Windows inputs use CRLF. The committed content matches after line-ending normalization, and `git cat-file --filters HEAD:<path>` reproduces the qualified file bytes exactly. See [before identity](identity_before.json) and [after identity](identity_after.json).

No RBF was rebuilt, renamed or replaced to adopt the new commit identifier. The original three-seed physical qualification remains applicable to this exact implementation. See the original [qualification report](../ys_fm227_validation_20261115/REPORT.md) and [release manifest](../ys_fm227_validation_20261115/release/MANIFEST.json), together with the new [consolidation report](REPORT.md).
