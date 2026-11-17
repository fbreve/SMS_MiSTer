const fs=require('fs'),p=require('path'),assert=require('assert');const d=__dirname;
const r=JSON.parse(fs.readFileSync(p.join(d,'combined_results.json')));assert.equal(r.status,'PASS');assert.equal(r.cases.length,72);
const all=r.cases.flatMap(c=>c.lastMismatch),followMin=Math.min(...all.map(x=>x.followNs)),followMax=Math.max(...all.map(x=>x.followNs)),clampMin=Math.min(...all.map(x=>x.clampCE)),clampMax=Math.max(...all.map(x=>x.clampCE));
const diff=fs.readFileSync(p.join(d,'production.diff'),'utf8'),num=n=>n.toLocaleString('en-US');
const text=`# Combined mix + mixout YM2413 self-healing experiment

PASS in functional simulation; ready for independent review. No Quartus build or
MiSTer hardware validation was performed for this experiment.

## Scope and isolation

- Branch: \`${r.branch}\`.
- Worktree: \`tests/ym2413_selfhealing_combined/worktree\`.
- Exact committed full-state baseline: \`${r.baseline}\`.
- Only production changes: omit word-101 \`mix\` restoration and word-102
  \`mixout\` restoration. Word-101 \`mute\` and \`maddr\` retain restoration.
- All 104 words, version 17, capture, transport, initialization, pipeline
  restoration, operational registers and normal register resets remain intact.
- \`verify_combined_scope.js\` checks every production source against the baseline,
  permitting exactly those two assignment substitutions. It verifies master,
  \`sys/\`, an empty index, and the preserved full-state, mixout-only,
  accumulator-only and old minimal worktrees, including accepted source digests.
- No commits, merges, pushes, PRs or physical builds were made.

## Measured results

| Check | Result |
|---|---|
| Slot/stage positions | 72 |
| Repeated SAVE/LOAD operations | ${r.loads} |
| Independently decoded trace pairs | ${num(r.traceRows)} |
| Both poisons initially different from restored reference | All LOADs |
| Accumulator equality | First normal reset, 1–72 enabled FM clocks |
| Last combined state/raw-audio mismatch | 72–143 enabled FM clocks |
| First complete state/raw/clamped-audio equality | 73–144 enabled FM clocks |
| Last clamped-output mismatch | ${clampMin}–${clampMax} enabled FM clocks; zero denotes none |
| Follow-up **after convergence**, each LOAD | ${(followMin/1e6).toFixed(6)}–${(followMax/1e6).toFixed(6)} ms |
| Later musical writes / independently checked effects | ${r.loads*9} / ${r.loads*9} |
| Distinct simultaneous poison pairs | ${r.poisonPairs.length} |
| Detected poisoned-prefix accumulator wraps | ${num(r.overflows)} |
| Candidate saturated samples before convergence | ${num(r.saturatedSamples)} |
| Saved envelope encodings | ${r.envelopeStates.join(', ')} |
| Other persistent FM state divergence | None observed |
| Delayed state or output divergence | None observed |
| Peak simultaneous GHDL simulations | ${r.verifiedPeakConcurrency}, all Low / Idle |

The last bad host-clock observations are exactly \`15 * (full_ce - 1)\`:
1080–2145 host clocks. The next host observations, 1081–2146, are fully equal
(20.197404–40.095864 microseconds from the bench resume boundary). The conservative
144-enabled-clock upper bound is 40.357440 microseconds.

PAL and NTSC production video counters measure periods of 1,070,460 and 896,040
host clocks, respectively. Both use the same 18.684 ns host period in this test,
giving 20.00047464 ms PAL and 16.74161136 ms NTSC periods. Every convergence occurs
before either counter's first VSYNC edge and far before two actual frames.
142,728 enabled FM clocks are approximately 40 ms, two PAL frames, **not 2.85 s**.

## New interaction and propagation

There are two potentially wrong output plateaus. The deliberately stale \`mixout\`
persists until the first normal stage-2/slot-17 boundary. That boundary transfers
the poisoned partial accumulator to the output and clears \`mix\`. The next
complete 72-enable sum replaces the partial result. Thus combining the omissions
extends the mixout-only recovery bound to the accumulator-only bound, 73–144
enables; it did not add another recovery cycle in these tests.

Independent trace arithmetic verifies a constant modulo-14-bit accumulator offset
before its clear, and the same offset in the first transferred partial sum. Cases
include opposite signs, both signed extremes, zero/nonzero pairs, alternating
bits, sign flips and deterministic varied values. Both initial mismatches are
asserted. Accidental equality is adjusted. Actual wraps and clipping occur and
are counted; matching clipped samples cannot substitute for internal/raw equality.

Source inspection finds no path from \`mix\` or \`mixout\` into feedback, envelope,
phase, instrument RAM or controller logic: their reads serve accumulation,
snapshot capture and the audio output. Continuous comparisons experimentally
check feedback, envelopes/lastkey, phase, controller state and pipelines,
rhythm/noise, custom voices, output RAM, the additional factory voice RAM and
delayed slot counters. Only the two deliberately poisoned temporal fields may
differ before convergence; every field must remain equal afterwards.

## Independent verification and later activity

The candidate and exact committed reference use separately compiled RTL libraries.
Both receive the same snapshot and identical post-restore stimuli. The candidate
alone is advanced/corrupted and simultaneously poisoned beforehand. Simulation-only
hooks are enabled during word 0 restoration and disabled before words 101/102;
the reference hook remains disabled. Separate negative controls reinstate each
restore assignment and are correctly rejected before unfreeze.

All 104 observed words are packed independently from live registers, process
variables and RAMs, rather than read through the SAVE path. A second ModelSim Tcl
oracle independently checks this packing in both libraries at 28 checkpoints.
The worst-position short pilot matches GHDL and ModelSim exactly:
${num(r.crossEngine.rows)} CSV rows, normalized SHA-256
\`${r.crossEngine.normalizedCSVsha256}\`.
GHDL binary records also match every CSV field. The main sweep retains every
enabled sample in that verified binary layout; \`collect_combined.js\` separately
decodes every record and validates exact last mismatches, propagation arithmetic,
clamped output, wraps, saturation, frame periods, exit status and provenance.
Fresh generation independently produces the identical bench and identical VHDL
statements in all 38 native files. Non-ASCII comment encoding differs in a few
adapters because of early normalization; exact campaign adapters and both digest
sets are retained in \`reproduction_results.json\` for reproducible replay.

After convergence, nine actual wrapper writes per LOAD exercise key-off/on,
rhythm/percussion changes, custom instrument AR/DR, and ML/flag updates. Separate
live-state assertions verify every effect. State and both audio comparisons stay
active throughout the entire follow-up. Clock enable remains every fifteen host
clocks; I/O strobes occur in the intervening host clocks. No host clocks or
comparisons are skipped. Each simulation has an explicit two-second simulated-time
watchdog and a checked process exit code.

Baseline regressions passed: independent 104-word pattern mapping, protocol and
registered/backpressured DDRAM behavior, non-FM compatibility, all 72 SAVE/LOAD
phases, and the normal-latency end-to-end case. That case checks three captures,
four restores including legacy loading, nine oracle checkpoints and 380,803
continuation samples. Candidate protocol and non-FM checks were repeated and
passed. ModelSim reports its Starter Edition recommended-capacity warning for the
large designs. Baseline compilation also reports existing aggregate-range-direction
warnings; independent packing checks pass. No functional errors are reported.
The long sweep uses GHDL 6.0.0.

Every GHDL instance is launched from a Low-priority parent; actual owned-child
priority is verified. Compilation and negative-control priorities are recorded,
and long-run priorities are sampled every two seconds. The workflow independently
verifies a peak of four simultaneous runs. Unrelated processes and global Windows
scheduling settings are untouched.

## Exact production diff

\`\`\`diff
${diff.trim()}
\`\`\`

## Limits and recommendation

The combined omission passes the requested functional test and is suitable for
independent review. These finite simulations are not formal proof or hardware
validation. Downstream MiSTer audio filtering/DAC state and audibility of the
short transient remain unmeasured. FPGA resource savings and timing remain unknown:
normal registers and the full capture/transport format are retained.

Keep this experiment separate from both single-omission controls. Obtain review
before any physical build or further omission. No further optimization is included.

Detailed sources, assertions and logs are under
\`worktree/tests/ym2413_fullstate/\`: \`combined_results.json\`,
\`campaign_source_manifest.json\`, \`combined_runs/\`,
\`combined_trace_0.bin\` through \`combined_trace_71.bin\`,
\`baseline_regression/\`, \`candidate_regressions/\`, \`controls/\` and
\`models_calibration/\`. See \`COMBINED_EXPERIMENT.md\` for reproduction.
`;
fs.writeFileSync(p.resolve(d,'../../../review.md'),text);console.log('Wrote combined review from independently validated results');
