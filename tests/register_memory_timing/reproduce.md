# Reproduce the read-only timing investigation

Use a new output directory; preparation refuses to overwrite scratch and query runners refuse to overwrite attempts. Retained original folders are tests/register_memory_auto and tests/register_memory_auto_seed2. All four fitted databases must be available. No new compilation is required.

1. Run `node prepare.js` to hash/protect original evidence and clone source inputs and fitted db files. Preserve relative source layout and build_id.v. The ignored scratch copies are the only projects opened by TimeQuest.
2. Run `powershell -NoProfile -ExecutionPolicy Bypass -File query.ps1`, then `families.ps1`. Each maps Z: to a scratch seed directory within its process, invokes Quartus 17.0.2 quartus_sta with a short Tcl/project/output path, and copies new reports back here. Never run these scripts concurrently because both temporarily use Z:.
3. Run `node analyze.js`, `node evidence.js`, and `node write_report.js` to regenerate measurements and the detailed report.
4. Run `node verify.js` to verify original bytes, branch refs, warnings, reproduced slack values and query completion. Read preservation_after.json.

The original xibiso2 package failure was resolved by using the established short script/output paths; its failed log remains separate. The failed invocation did not create a timing netlist. Earlier command-help CLI attempts did not open a project. help.tcl and command_help.log capture the installed TimeQuest command reference used to construct the queries.

No RTL, SDC, QSF, fitter setting, seed, original report, original db or branch ref is changed by this workflow. It does not attempt a timing fix. Scratch copies contain generated Quartus state and remain outside Git through .gitignore.
