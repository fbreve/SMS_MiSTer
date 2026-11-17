# F08 / S070 MD6 savestate review

Base: committed F02 `02838b7`, branch `fix/savestate-md6`. Only F08 is addressed. No commit, push, PR, or staging is authorized or performed.

## Root cause and pre-fix evidence

Each emulated controller has four persistent registers: `timer`, `rises`, `th_prev`, and `type_prev`. None crossed the savestate interface. Saving ordinary IO TH alone cannot reconstruct phase or elapsed timeout. Furthermore, these registers advanced throughout savestate transport, so even saving without loading could consume a short-lived handshake phase.

`original_before.log` reruns the original audit reproduction against committed F02 before any production edit: third-rise all-pressed XYZ/Mode was `110000`, while the advanced DUT became `111111`. No protocol register was forced. `characterize_before.log` and `characterize_real_before.log` exercise phases 0–4 with the original production module at 64 and 80540 cycles. At timer `T-2`, phase is intact; at `T-1`, phase remains intact for that clock; the next clock clears rises and leaves the terminal timer saturated. Phase 3 high changes immediately from XYZ/Mode to ordinary buttons. Phase 2 low and phase 3 low also have distinct identification responses. Phases 0, 1 and 4 may initially share high outputs, but their different histories affect later TH sequences.

Missing timer changes when the phase expires. Missing rises changes the response and which future edge exposes extended buttons. Missing TH history loses or invents a pending rise. Missing type history can turn the first clock after a type change from reset into an edge/count update. Replay explicitly covers input changes between sampling clocks, including simultaneous MD3→MD6 selection and a TH rise.

`integration_before.log` additionally runs the complete DDRAM save/load against the untouched saved F02 RTL at production timeout. The load freezes the machine for 940414 clocks; original MD state continues advancing and both saved phases are lost. P1 DUT output is `111111` while the independently held reference remains `110000`. The adapter only observes original registers, never forces them, and gates the reference clock to hold the save point. The DUT and original F02 savestate FSM remain unmodified. This expanded baseline test was run after the initial pre-edit confirmation, against the preserved baseline copy.

## Persistent-state inventory

See [inventory.csv](inventory.csv) for the complete classification, including integration state. Per port the required new state is exactly 23 bits: timer 17, rises 3, TH history 1, effective type history 2. There is no separate timeout or phase register, no dead MD6 register, and no unresolved MD6 item.

IO ctrl already preserves guest TH control in the existing IO word. Current TH is reconstructed from restored ctrl and external region settings. Buttons, effective selection and configuration are external inputs; they are not rewound. The registered joystick frontend refills before guest execution resumes. Master Tap `jcnt` is forced to zero whenever that accessory is disabled, which is required for active MD emulation. Its `old_th`/`tmr`, real-controller serial path, and paddle/gun state belong to separate paths and are unchanged. No F09/F10 state was added.

## Freeze and restoration semantics

Choose option B: suspend all four protocol registers during `ss_freeze`, and also serialize/restore them. Restore has priority over freeze; existing reset remains effective. No CPU enable, turbo, or ordinary pause signal gates the normal protocol clock. Thus timing outside savestate transport remains identical to F02, including real-time MD6 timeout during ordinary pauses.

The savestate FSM asserts freeze at ARM, but the pad executes that edge using the previous freeze value. Capture MD state at the subsequent post-drain `ST_FREEZE`, after the last normal pad edge, rather than taking an inconsistent pre-edge ARM snapshot. Saving leaves that exact local state held throughout transport. Loading supplies the stored state in `ST_PRE_UNFREEZE`, after IO restoration and the 900000-clock flush have settled. The restore strobe is consumed while freeze remains asserted; all restored history stays held through the release guard. Legacy normalization samples the restored TH and current effective type at this late point, preventing a synthetic rising edge on release.

## Exact format

Word addresses are 64-bit DDRAM offsets within the existing slot. Header/slot size and EEPROM word `01b` remain unchanged.

| Word/bits | Representation |
|---|---|
| `01a[63:40]` | tag `484303`, extension version 3 |
| `01a[39:38]` | `3`: two GG payload words plus one MD payload word |
| `01a[37:30]` | existing VDP2 HCounter, zero outside System E |
| `01a[29:22]` | existing VDP1 HCounter |
| `01a[21:0]` | existing video state |
| `01c–01d` | identical F02 GG128 representation and reserved-bit validation |
| `01e[22:0]` | P1 MD state |
| `01e[45:23]` | P2 MD state |
| `01e[63:46]` | reserved, written zero and validated zero |

Within either 23-bit port field: timer `[16:0]`, rises `[19:17]`, TH history `[20]`, type history `[22:21]`. The controller module retains parameter-dependent state width for shortened-timeout tests; top-level production instances use the default 17-bit timer. Both ports are transported independently in the same 64-bit word. New data is consumed only for the complete v3 tag and count. Loader additionally rejects timer values ≥80540 and rises >4 in either port. Invalid MD payload normalizes both ports; it does not discard valid HCounter or GG data.

## Compatibility

| Snapshot | HCounter | GG | MD |
|---|---|---|---|
| Untagged 96K | zero | F02 reset | initial phase |
| Old 64K | zero | F02 reset | initial phase, current TH because ordinary IO restoration is intentionally skipped |
| v1 `484301`, count 0 | preserved | F02 reset | initial phase |
| v2 `484302`, count 2 | preserved | preserved if GG padding valid | initial phase |
| v3 `484303`, count 3 | preserved | preserved if GG padding valid | exact state if MD payload valid |
| Unknown tag, unsupported version, wrong count | zero | F02 reset | initial phase |
| v3 with invalid MD padding/timer/phase | preserved | normal independent GG validation | initial phase |

Initial phase means timer=0, rises=0, TH history=current restored TH, type history=current effective type, all held until release. This is ordinary MD3-compatible behavior with no invented edge; the first subsequent actual rise counts normally. Old reserved bytes are never interpreted as MD data. v1/v2 tags, counts, layouts and meaning are unchanged. As before, unsupported older readers cannot recover newer private fields; this is backward reading compatibility in the new core, not forward support in old cores.

## Verification

`replay.sv`: 2560 shortened-timeout cases across types 0–3, phases 0–4, TH high/low, all 16 XYZ/Mode combinations, and ordinary/pre-terminal/terminal/post-timeout positions. Every case performs repeated save/perturb/load, compares complete protocol state and pins, exercises immediate TH edges, long idle, type changes and reset. Additional pending TH/type transitions test exact sampled history. The perturbation resets/advances the DUT while reference state remains held. No internal protocol state is forced. The same suite runs 160 representative cases with the production 80540-cycle timeout. Each simulated transport wait exceeds its timeout.

`integration_tb.sv` is generated by `prepare_integration.js` from the established full savestate/DDRAM fixture and instantiates production IO plus two production-timeout pad DUTs and two independently held reference pads. P1 saves third-rise high, P2 second-rise low, with different nonzero timers. Both reference pads reach the save point through the same actual TH sequence and are then held during perturbation; neither reference ever loads a snapshot or restored payload. Full normal save/load FSM, DDRAM backpressure and 900000-clock flush run without shortening. Only the UI cooldown is forced to zero. Stored v3 fields and payload are checked against captured state, then restored states/pins compare against reference through long idle and timeout. Save freezes roughly 30370 clocks; loads freeze roughly 940400 clocks, exceeding the real timeout by more than 11 times. Save alone preserves phase. Twelve cases cover v3 twice, untagged, v1, v2, unsupported/random metadata, wrong count, reserved bits, invalid timer, invalid phase and oldest64K. F02 GG words remain intact for valid formats.

The original F08 audit reproduction is now a positive restore regression, updated in both its fixture and Python source generator. The EEPROM expected-gap reproduction remains unchanged and continues documenting its separate finding. F07 checks cover both SMS/GG direct HCounter tests, full controller metadata compatibility including v1 and v2, and two real VDPs through DDRAM with modern/legacy snapshots. F02 checks cover all 24 baud/phase/error/status/NMI cases and 13 full DDRAM cases with and without stalls. PSG covers all 128 noise/divider cases and 20000 future cycles per case. Original audit static checks run into isolated directories so historical evidence is preserved.

`static_checks.js` verifies the normal controller update and combinational decode match F02, untouched IO/VDP/system/EEPROM/settings, exact three-file production scope, new field validation, and all 136 baseline build inputs against the known successful committed F02 build. `F02_reference.json` records those hashes and its metrics. Final build metrics and test completion are recorded in `results.json` and the final appendix below after Quartus completes.

## Scope and limitations

Production changes are confined to `rtl/sega_controller.sv`, `rtl/savestates.sv`, and `SMS.sv`. No unrelated refactor or timing optimization. Physical external pad/remote input state is outside this emulated-protocol contract. As with F02, the DDRAM controller has no external file-length signal; version/count and payload validation do not constitute a general truncated-file detector. No unrelated savestate finding is fixed or suppressed.

## Final signoff

Quartus 17.0.2 full compilation, synthesis and fitter succeeded on Cyclone V 5CSEBA6U23I7 with unchanged seed 1/settings. The candidate is a fresh complete build, compared against the existing successful F02 build whose 136 source/settings inputs were byte-verified against committed 02838b753751530576045c3c15cbfafa684c5f6e. The generated build ID also matches.

| Resource | Committed F02 | F08 | Delta |
|---|---:|---:|---:|
| alms | 26656 | 26618 | -38 |
| registers | 36100 | 36237 | +137 |
| memoryBits | 3809858 | 3809858 | +0 |
| ramBlocks | 487 | 487 | +0 |
| dspBlocks | 39 | 39 | +0 |

Worst setup: 0.694 ns (F02 0.434 ns). Worst hold: 0.242 ns (F02 0.153 ns). Negative slack/nonzero negative TNS summaries: 0. Full per-clock summaries are in candidate_sta.summary and results.json.

New normalized numbered warnings: 0; new critical warnings: 0. Distinct critical warnings F02/F08: 38/38; distinct numbered warnings F02/F08: 84/84.

All required local and full-transfer tests passed, including unchanged expected EEPROM-gap coverage. No other finding was fixed. P1/P2 fields remain independent; F07 and F02 field positions are retained. Complete production diff was reviewed; there is no staged content. Test changes comprise this focused directory, the converted audit MD fixture/generator, and F07/F02 format expectations plus explicit v2 coverage and F02 optional stalls. Generated Quartus data remains under ignored candidate/baseline directories.

`git diff --stat`:

```text
 SMS.sv                 | 14 ++++++++--
 rtl/savestates.sv      | 69 ++++++++++++++++++++++++++++++++++++++++++++------
 rtl/sega_controller.sv | 49 ++++++++++++++++++++++++-----------
 3 files changed, 107 insertions(+), 25 deletions(-)
```

`git status --short`:

```text
 M SMS.sv
 M rtl/savestates.sv
 M rtl/sega_controller.sv
?? tests/
```

**READY TO COMMIT**: F08 implementation, compatibility, simulations, synthesis/fitter and timing checks pass. No commit, push, or PR has been performed.
