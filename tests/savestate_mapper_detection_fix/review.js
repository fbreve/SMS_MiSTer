const fs=require('fs'),path=require('path'),d=__dirname;
const x=JSON.parse(fs.readFileSync(path.join(d,'results.json'),'utf8'));
const stat=fs.readFileSync(path.join(d,'diff_stat.txt'),'utf8').trim(),status=fs.readFileSync(path.join(d,'git_status.txt'),'utf8').trim();
const signed=n=>(n>0?'+':'')+n;
const labels={ALMs:'ALMs',fittedRegisters:'Fitted registers',memoryBits:'Memory bits',RAMBlocks:'RAM blocks',DSPs:'DSP blocks',synthesisRegisters:'Synthesis registers'};
const resources=Object.keys(x.candidate).map(k=>`| ${labels[k]} | ${x.baseline[k]} | ${x.candidate[k]} | ${signed(x.delta[k])} |`).join('\n');
let text=`# F13 mapper-detection savestate fix

**${x.recommendation}.** Only F13 is addressed, on branch \`fix/savestate-mapper-detection\` from committed F12 \`b61f307dcb161a6ac9a70fd544d435436807191d\`. No commit, push or PR was made. The authoritative investigation was read completely before editing production RTL; its evidence remains unchanged at [the investigation report](../savestate_mapper_detection/review.md). [design.md](design.md) records the extracted implementation contract. [results.json](results.json) and [simulation_results.json](simulation_results.json) contain canonical logs, source hashes and all boundary samples.

## 1–5. Root cause, selected/excluded state, mapper_set and affected heuristics

F12 restored current mapper/bank fields but reset Sega/bank write evidence, saturated the detector timer and cleared Wonder Kid's sample count. Later Dahjee/4PAK decisions still consumed lost Sega evidence; early loads lost remaining linear/Sega-locked/Wonder Kid recognition time. Separate edge trackers sampled the discarded context on mapper_set, so restoring Wonder Kid selection or BIOS visibility could replay startup initialization and overwrite correctly loaded banks on the following clock. First and second LOADs could therefore produce different ROM bytes.

Preserve exactly18 bits: detector timer16, bank-write evidence1 and Sega-write evidence1. Reconstruct Wonder Kid and BIOS-handoff previous values during the single clock after mapper_set: a transient restore-pending bit inhibits their initialization actions while their ordinary trackers settle from restored effective inputs. Normal handoff/recognition actions stay in their existing branches. No extra saved edge bits or duplicated static-mapper precedence logic are added.

Explicit exclusions: Wonder Kid's sample counter normalizes0. With the unchanged T80/native enable spacing (at least10 host clocks), its active count1 intermediate cannot survive an eligible write and reach a later accepted M1 while the detection window remains open; with AB present, count2 already implies the sticky resolved flag, and without AB no later count can recognize it for the same media. A count1 stranded at window closure is unconsumed. Download scanners, CRC/header metadata, dead lock_B history and host mapper forces add no payload. Existing architectural banks/flags remain in their original fields. See the investigation inventory for widths/lifetimes and the exclusion proof.

The controller presents loaded history alongside mapper_in on the existing mapper_set edge, before guest execution. The detector consumes these saved bits instead of clearing current history. Mapper state and history are captured together after freeze/drain, incorporating the final ARM-edge timer increment and terminal fallback coherently. CPU execution is already stopped; CPU/VDP/IO capture points remain unchanged. The240 capture checks include timer65534 and assert both mapper and history snapshots equal the settled live state.

Affected paths covered: Dahjee,4PAK, ordinary Sega evidence,32K linear fallback,48K Sega-locked fallback, Wonder Kid recognition and the false Wonder Kid/BIOS-handoff initialization edges. System E, Evolution and EEPROM selection/restore precedence are retained.

## 6. Recorded pre-fix results

Six F12 baseline runs completed before production edits. \`pre_case0.log\` reproduces Dahjee data03/02 and RAM access0/1; \`pre_case1.log\` reproduces4PAK data03/00. \`pre_edge0.log\` observes Wonder Kid first LOAD00, second03; \`pre_edge1.log\` observes BIOS-handoff first LOAD02, second03. These logs print PASS only when the expected defect is reproduced. \`pre_cpu0/1.log\` retain mature/early real T80/video capture reachability, not a claim of corrected load behavior. Frozen F12 modules and fixtures are retained under \`baseline/\`; the pre-fix driver compiles those copies independently of the current RTL.

## 7–10. Architecture, discarded history and reconstruction

The selected hybrid restores the18 unreconstructable history bits and reconstructs the two edge trackers from restored effective state. Merely preventing mapper_set from clearing current history would retain discarded writes and elapsed time accumulated after T. It would fail snapshots with no evidence loaded after evidence-rich execution, as well as partial-window snapshots loaded after expiration. The stress tests alternate those post-save histories and check exact restored history on every restore edge.

Reconstruction of the18 bits from v8 is impossible: the investigation demonstrated equal packed mapper state with different Sega/bank evidence and different future mapper decisions/data. Remaining timer values likewise are not encoded by current selected flags. Explicit serialization is required. Edge trackers are reconstructable from restored mapper/boot inputs, so they are not serialized. The one transient settling bit is protocol control, not additional snapshot history.

## 11–13. v9 representation and deterministic legacy policy

The v9 format is justified by that non-injectivity. All v1–v8 locations and write expressions remain intact, checked against committed F12. Snapshot size/slot stride and RAM transfer ownership are unchanged. Header word01a retains its existing fields; its24-bit marker becomes484309 and its2-bit existing base-payload count remains3. It inherits the existing GG/MD/EEPROM/SC/Tap/Paddle/gun extensions.

| Location | Representation / validation |
|---|---|
| 02a | [15:0] timer; [16] bank evidence; [17] Sega evidence; [63:18] zero |
| 02b | exact64-bit descriptor000000124d444839: width18 at[39:32], MDH9 at[31:0], remaining bits zero |
| 01a | exact484309 version marker and count3 are required before reading history |

The loader requires both the exact descriptor and zero payload padding. Unknown/future markers, wrong counts, malformed descriptor/width/padding, missing extension, untagged, v1–v8 and old64K snapshots restore deterministic timerFFFF/evidence00/count0. No positive evidence is invented and no arbitrary discarded history survives. Existing resolved mapper/bank fields are retained; old snapshots cannot reproduce history they never stored, so their documented compatibility normalization cannot promise exact historical heuristic replay. Normal BIOS-active initialization can subsequently reset detector state as before.

## 14–18. Replay, repeated LOADs, boundaries and SAVE ONLY

All${x.canonicalLogs} canonical logs passed (${x.canonicalLogs-6} post-fix logs plus6 expected pre-fix/reachability logs). Targeted post-fix scenarios complete${x.targetedCompleteOperations} real SAVE/LOAD controller operations. The main cases check mapper type/flags, complete18-bit history, banks through the packed mapper word, physical ROM address, Dahjee RAM-access enable and mapped read bytes. Identical bus addresses and mapper/RAM-control inputs also determine equal RAM addresses through the unchanged production decode; these tests do not claim a new F06 SRAM-ownership proof.

First post-load suffixes compare reference/DUT every host clock, and later suffixes compare recorded complete state/address/enable/data trajectories: **${x.replayClockChecks.toLocaleString('en-US')} comparisons**. LOAD is checked at the actual restore edge before legitimate post-release timer progress; this matters when the detector reaches its deadline during the first resumed clocks. The reference is rebuilt naturally to the saved capture age and held through the same detector drain. No history/internal CPU/FSM value is forced; only the UI operation cooldown is bypassed.

Twelve core scenarios cover history-rich/empty and already selected states. Eighteen full deadline replays sweep linear/Sega-locked/Wonder Kid captures before/at/after expiration. Both first-versus-second LOAD regressions now return03 on every load. Additional stress performs8 LOADs of each of three snapshots (24 stressed LOADs), with alternating discarded Sega/bank/Wonder Kid activity and command-time DDR backpressure. Every restored suffix and its guest-visible read values match the original suffix; current post-save evidence does not leak backward.

The225-phase/evidence/request sweep plus15 independent terminal-phase cases accept **${x.boundaryCaptures} coherent captures**, including65534. These stop after capture and are not counted as full transfers. SAVE ONLY stays equivalent in every full core/deadline/stress scenario. Static comparison confirms ordinary detector logic is unchanged outside restoration; save adds snapshot/transport operations without changing live detector updates. An initial stress fixture erroneously kept BUSY active while idle, denying the existing32-clock drain; the corrected command-time profile preserves production drain behavior. Another fixture correction standardized the initial idle bus for repeated suffixes. Neither required a production workaround.

## 19. Real T80/video and guest execution

The stronger post-fix test executes a synthetic cartridge on the actual T80 through production mapper/decode and real video VBlank. The CPU reads mapped8123 data03 and reports it through an OUT. A guest instruction sequence changes bank2, producing07. LOAD restores CPU, mapper and history; resumed guest execution reports03 again. Both mature and early BIOS-handoff versions pass (\`fixed_cpu0/1.log\`). This validates actual guest data/execution, not only internal mapper registers. Video supplies the genuine accepted capture window; no new pixel/rendered-game equivalence claim is made.

## 20–23. Existing regressions and scope

All18 selected existing regression runs pass: mapper directed checks (ordinary Sega, Dahjee/4PAK exclusions, System E and Evolution restore layouts, EEPROM priority), SRAM routing controls, EEPROM protocol/full-DDR24-case/persistence, SC RAM60 size/case combinations, F07 controller-format and dual-System-E-VDP integration, F02 GG direct/DDR, F08 real-time MD6, F09 Master Tap, F10 paddle, F11 lightgun plus two18-case format profiles, F12 paused non-M1 capture, and PSG128-case/all-divider replay. The24-case new format matrix independently proves untagged/v1–v8 compatibility, v9 and malformed/future behavior while checking prior GG/MD/Tap/Paddle/gun payloads.

Regression copies keep datapath assertions, update only current writer expectations8→9/future rejection9→10 and relative paths, and supply terminal/zero history for mapper-free fixtures. Historical test sources/reports/logs remain preserved. The known stale mapper random differential oracle remains excluded as established by the investigation; all existing directed mapper checks remain enabled. No broad mapper cleanup or refactor is included.

**F06 remains unresolved and untouched. F14–F16 remain untouched.** F02–F12 are exercised as regressions, not reimplemented. Only five production files change: SMS top/system history wiring, mapper detector restore/export, mapper controller edge settling and the savestate extension/FSM.

## 24–27. Full Quartus and F12 comparison

Fresh isolated full Quartus17.0 build completed after the full simulation gate. Synthesis and fitter succeeded. The136-input baseline manifest was verified against F12:134 tracked inputs match the committed baseline, plus two unchanged manifest-only backup files. Framework and build ID match; no db/incremental_db was copied into the fresh candidate.

| Resource | Committed F12 build | F13 | Delta |
|---|---:|---:|---:|
${resources}

Worst setup slack: **${x.worstSlack.setup.toFixed(3)} ns** (F12:0.525). Worst hold slack: **${x.worstSlack.hold.toFixed(3)} ns** (F12:0.245). Negative-slack/TNS summary entries: **${x.violations.length}**. Full timing summaries are recorded in results.json.

Distinct normalized warnings:${x.warningCounts.candidate} versus${x.warningCounts.baseline}; critical warnings:${x.warningCounts.candidateCritical} versus${x.warningCounts.baselineCritical}; tool-reported total:${x.warningCounts.toolTotal}. New warnings:${x.newWarnings.length}.${x.newWarnings.length?'\n\n'+x.newWarnings.map(w=>'- '+w).join('\n'):''}

Physical resource deltas include synthesis and fitting/retiming decisions. The logical addition is the18-bit history snapshot,18-bit restore staging, history-tag control and one transient edge-settling bit, plus the new FSM states. No new RAM or DSP payload is intended; measured deltas above are authoritative. Every current source hash equals the compiled candidate input.

## 28–30. Repository state and recommendation

\`git diff --stat\`:

\`\`\`text
${stat}
\`\`\`

\`git status --short\`:

\`\`\`text
${status}
\`\`\`

No staging, commit, push or PR. Quartus products remain isolated under this evidence directory and are not staged. Original evidence is preserved. **${x.recommendation}**: saved-time history and coherent mapper state are restored, all first/repeated data replays and legacy checks pass, and full hardware compilation/timing/warning comparisons are recorded above.
`;
// Keep prose spacing readable when embedding numeric measurements.
text=text.replace(/\b(All|The|the|its|exactly|exact|plus|at|least|of|with|performs|uses|word|width|count|timer|RAM|Quartus|complete|evidence|normalizes|data|access|reproduces|LOAD|second|old|two|PSG|becomes|remains|expectations|rejection)(?=\d)/g,'$1 ').replace(/([^\d]),(?=\d)/g,'$1, ').replace(/; critical warnings:/g,'; critical warnings: ').replace(/; tool-reported total:/g,'; tool-reported total: ').replace(/warnings:(?=\d)/g,'warnings: ').replace(/versus(?=\d)/g,'versus ');
text=text.replace('The 136-input baseline manifest was verified against F12:134 tracked inputs match the committed baseline, plus two unchanged manifest-only backup files.','The 136-entry source/settings manifest was verified against F12: 134 tracked entries match the committed baseline, plus two unchanged, unused manifest-only backup files.');
text=text.replace('RAM access 0/1','Dahjee cartridge/RAM-route selector 0/1').replace('Dahjee RAM-access enable','Dahjee cartridge/RAM-route selector');
text=text.replace('Every current source hash equals the compiled candidate input.','Every current source hash equals the compiled candidate input. The [entity register ledger](resource_analysis.json) reconciles the complete fitted-register delta; 42 registers are added in the savestate entity, with further physical changes distributed across mapper/control and existing design blocks.');
fs.writeFileSync(path.join(d,'review.md'),text);console.log('Wrote final F13 implementation review.');
