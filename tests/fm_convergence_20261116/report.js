const fs=require('fs'),p=require('path'),crypto=require('crypto'),cp=require('child_process');
const d=__dirname,root=p.resolve(d,'../..'),a=require('./analysis_summary.json');
const sha=b=>crypto.createHash('sha256').update(b).digest('hex');
const before=require('./preservation_before.json'),after={};for(const [f,h]of Object.entries(before)){after[f]=sha(fs.readFileSync(p.join(root,f)));if(after[f]!==h)throw Error('Protected file changed: '+f);}fs.writeFileSync(p.join(d,'preservation_after.json'),JSON.stringify(after,null,2));
function git(cwd,...args){return cp.execFileSync('git',args,{cwd,encoding:'utf8'}).trim();}
const preservation={rootHEAD:git(root,'rev-parse','HEAD'),master:git(root,'rev-parse','master'),rootTrackedDiff:git(root,'diff','--stat','HEAD'),experimentHEAD:git(p.join(d,'worktree'),'rev-parse','HEAD'),experimentBranch:git(p.join(d,'worktree'),'branch','--show-current'),experimentTrackedDiff:git(p.join(d,'worktree'),'diff','--stat','HEAD'),protectedHashesMatch:true};
if(preservation.rootTrackedDiff||preservation.experimentTrackedDiff||preservation.experimentHEAD!=='8cd53ccc954c24970372ea6d8a3fb2336a14c46f')throw Error('Preservation check');fs.writeFileSync(p.join(d,'preservation.json'),JSON.stringify(preservation,null,2));
const f=n=>n===0?'0':n.toFixed(6),m=n=>n.toFixed(3),link=x=>`[${x.name}](${x.stage==='game_checked'?'games_checked':x.stage==='game_frozen'?'games_frozen':x.stage}/${x.name}/result.json)`;
let s=`# Two-second FM restoration convergence experiments — 2026-11-16

The maintainer's settling hypothesis is supported for selected narrow omissions, but is not a general property of reduced restoration. Actual production-cadence runs show natural exact output convergence for attack, sine and writeback omissions in selected cases. Envelope/phase history and a defined macro-state candidate do not consistently converge within two seconds. Game music can repair differences through subsequent writes; it must not be mistaken for natural settling.

Recommendation: retain the qualified complete implementation. The tested stale-pipeline macro candidate is NO-GO for adoption. Narrow omissions are candidates for further qualification, not approved reductions: listening acceptability, broader positions/modes, console integration and meaningful hardware savings remain unqualified. This conclusion comes from extended experiments, not the previous 0.336-ms pilots. No production RTL or savestate format was changed.

## Reference and experimental isolation

Full reference: \`8cd53ccc954c24970372ea6d8a3fb2336a14c46f\`. Experimental worktree: [worktree](worktree), branch \`experiment/fm-two-second-convergence-20261116\`, clean at that exact commit. The complete 100-word implementation remains available unchanged. The [existing inventory](../fm_state_reduction_20261116/STATE_INVENTORY.md) and [historical report](../fm_state_reduction_20261116/REPORT.md) are not edited.

Main checkout remains at \`ff70cb70ce9724d97cd5cc2946c14ba21c809a96\`; master remains \`66f16d5c656fd8906d62570da4d258875bcee684\`. No tracked source differences in either checkout. No sys changes, RBF replacement, commit, merge, push or publication. [Preservation checks](preservation.json) and [protected hashes](preservation_after.json) include the qualified Ys RBF (SHA256 \`3ebda245e566f22ed2ec1b363359b58f9f83804ad83c5ce83626d431eef103bd\`). Existing untracked files outside this experiment were left in place.

## Feasibility and independent validation

The real VHDL OPLL from the exact reference was compiled with GHDL 6.0.0, lowered to Verilog, and compiled natively with Verilator 5.055 / GCC 13.2. Three real OPLL instances run concurrently inside each executable. This is not a behavioral FM substitute. [Source hashes/adapters](source_manifest.json), [export script](export.js), [native build](build_native.js), generated [OPLL](opll.v), [triad](triad.v), compiler diagnostics and executable hashes in each run.json are retained. GHDL synthesis adapters rename the reserved Release identifier, expand scalar subtype ranges and supply null nonbinary case alternatives in simulation copies only. The native backend is two-state; this is a limitation, not a formal proof of compiler equivalence.

Independent ORIGINAL-VHDL simulation crosschecks pass in [seven primary cases](calibration_results.json) and [two additional cases](calibration_v2_results.json): 7,200 enabled audio samples per case, all three trajectories, captured/stale images and all 100 restored words match exactly. Additional cases exercise early phase/AM/PM rollover and combined narrow omissions. The original VHDL asserts that audio contains no unknowns. This validates the acceleration on finite tested cases; the long campaign itself uses the compiled backend.

Every FM enable executes 15 host clocks, including all idle host clocks. Host 53.693175 MHz / FM 3.579545 MHz comes from the production PLL; a VHDL testbench's illustrative clock period is not used as an audio-duration shortcut. Each ordinary long run follows 7,517,045 enables = 2.100000140 s = 112,755,675 follow clocks. Two event experiments follow 10,738,635 enables = 3 s. Initial measured throughput was approximately 828,500 host clocks/s solo; long cases took minutes, not a multi-day 43-times-6,000 campaign. Wall times are recorded per result. The official OSS CAD Suite 20261116 archive and [download provenance](tool_download.json) are retained; archive SHA256 \`99a1ace9c584433f9fa50ebd9bb26b620d26ec37a7eeb8859cfb34b56ec286e3\` matches the official release digest.

Staged selection: 432 short narrow probes (3 variants × 2 profiles × 72 restore offsets; 20,000 enables each) produced 325 exercised cases and 107 explicit 'omission not exercised' exclusions. Those exclusions are unchanged omitted values, not functional failures. A further 216 macro probes cover sustain, attack and rhythm across 72 offsets. Long candidates include short-sweep positions still divergent at the probe endpoint, macro positions that corrupt channel state, and no-LFO controls. Short sweeps do not establish two-second behavior. There are **28 valid long cases**, including an all-state control, 19 synthetic cases total and 9 game-driven cases. All baseline full-state readbacks are exact; all final full/uninterrupted 100-word images match. PASS on a run means the measurement/restore checks completed, not that the reduced variant is functionally acceptable.

## Three trajectories and scope

At SAVE all three instances freeze and capture the same image. The uninterrupted control stays frozen while full and reduced instances run a distinct stale future. LOAD restores all 100 words into the full instance; the reduced instance restores selected bits and retains stale omitted bits. Both readbacks are checked against the exact expected image. Then all resume together with identical inputs. This is omission of restoration, not clearing omitted state to zero. Snapshot enumeration remains 0–99; no public format, descriptor or legacy path is edited.

This is a core-level OPLL experiment, not a complete console/DMA simulation. Snapshot word 76 (external bus context in the integrated implementation) is zero in this core harness; bus inputs are controlled separately, and game experiments explicitly save/restore external bus context. The OPLL controller and every other accessible word use real RTL. Existing integration, legacy, interrupted SAVE/LOAD, FM-disabled and hardware qualifications remain those of the unchanged full implementation; this campaign does not requalify those properties for a reduced production implementation.

The reference itself omits temporal mixer state. Full vs uninterrupted therefore has a short initial mismatch: maximum in this campaign is ${Math.max(...a.map(x=>x.baselineLastMismatchCE))} enables (${m(Math.max(...a.map(x=>x.baselineLastMismatchCE))/3579545*1e6)} µs), then exact audio to the endpoint; all final captured words agree. Reduced-vs-full errors are reported separately, not attributed to this expected baseline transient.

## Defined omissions

Masks are executable in [driver.cpp](driver.cpp), [driver_v2.cpp](driver_v2.cpp), and [game driver](game_driver_safe.cpp); every state.csv records all 100 image, stale, mask, full and reduced values. Mask 1 means restored; mask 0 means left stale. Addresses below are decimal, bit masks hexadecimal.

| Variant | Omission / preserved exceptions |
|---|---|
| attack | Omit 91–92, attack pipeline |
| sine | Omit 98–99, sine pipeline |
| writeback | Omit 79, writeback pipeline |
| envelope | Omit 31–48, envelope history RAM |
| phase | Omit 13–30, phase history RAM |
| feedback | Omit 49–57, feedback history |
| controller | Omit 80–85 except 84 mask 0000003f (rflag), 85 mask 04000000 (extra mode) |
| macro | Keep 0–57; keep 76,77,78,80,88,90,95 fully; keep 81 mask 0000000f, 84 mask 0000003f, 85 mask 04000000, 87 mask 7fffe000 (EG lastkey), 93 mask fff80000 (PM); omit remaining bits in 58–99 |

Macro deliberately preserves registers, custom instrument, phase/envelope/feedback RAM, timing and selected key/LFO controllers while leaving decoded/pending/output history stale. It is an explicitly defined conservative interpretation of macro states, not a claim that the maintainer specified this exact mask. It retains 70 nonzero word masks (65 full + 5 partial); no state-file word-count or resource saving is inferred from that.

Synthetic profiles: 0 held custom note with AM/PM; 1 captured in attack; 2 in decay; 3 released; 4 rhythm plus held melody; 6 held note without AM/PM. Profile 5 is a rollover calibration only. Custom flags e1 (21 without LFO), feedback 7, channel 0 volume 6, FNUM 401 / block 4. Sustain uses zero decay/release rates: its captured EG encoding is Release but key is held and the reference remains sounding. Profiles 1/2 actually capture Attack/Decay, confirmed in result.json. Restore offsets are FM-enable offsets after initialization, not seconds of game play. Baseline has no post-LOAD writes; internal EG/PG key transitions are separately counted.

## Complete long-run measurements

All times below are relative to resume, in seconds. First/last differences, RMS and peak compare reduced vs full raw signed 14-bit digital output at **every FM enable**; RMS includes the entire observation interval. A last difference at the endpoint means only 'not converged by this endpoint', never indefinite divergence. Clamped 13-bit measurements and reduced/uninterrupted comparisons also appear in each linked result. Digital differences alone do not prove audible corruption or wrong pitch.

| Case (raw evidence) | Duration | First difference | Last difference | RMS | Peak | Interpretation |
|---|---:|---:|---:|---:|---:|---|
`;
for(const x of a)s+=`| ${x.stage}: ${link(x)} | ${f(x.seconds)} | ${f(x.total.raw.first_seconds)} | ${f(x.total.raw.last_seconds)} | ${m(x.total.raw.rms)} | ${x.total.raw.peak} | ${x.classification} |\n`;
s+=`\nFirst/last zero means no output difference observed, not an unexercised omission; changed-word guards passed for every non-control long case. Silence classifications use the sampled audio trace after the last every-enable difference; they are deliberately not counted as active-note convergence. An equality interval through 2.1 s is finite evidence, not a guarantee about future writes or all possible states. Controller/macro p1 retain a final latent mismatch at word 82 despite exact output; several other matching cases have all 100 words equal. See analysis_summary.json for final differing words.

## Residuals at requested milestones

Each cell is RMS difference / RMS full reference over the preceding 50 ms ending at 0.1, 0.5, 1.0 or 2.0 s (ceil to FM enables). This avoids a coincidental zero at one sample. Units are raw digital counts; it is not a perceptual threshold.

| Case | 0.1 s | 0.5 s | 1.0 s | 2.0 s |
|---|---:|---:|---:|---:|
`;
for(const x of a)s+=`| ${x.stage}/${x.name} | ${x.residual_50ms.map(y=>m(y.raw.rms)+' / '+m(y.raw.reference_rms)).join(' | ')} |\n`;
s+=`\n## Natural settling, wrong notes and event causality

Narrow selected cases naturally settle while full reference continues sounding: attack 0.057829 ms, sine 41.432920 ms and writeback 23.581489 ms. Without AM/PM, sine takes 100.468356 ms and writeback 73.243666 ms. No external write or new EG/PG key-on occurs in those cases. Feedback and controller p1 settle at 62.398713 / 91.524202 ms; these are one-position observations, not broad qualification. Attack also runs on all three game logs; Ys/Double Dragon have no output difference, California Games ends at 0.048889 ms.

Envelope history does not settle on the held note by 2.1 s: 2-s residual 5.062 counts vs reference 34.816. The 1.5–2-s level difference is −1.376 dB. Its release example becomes equal at 0.511732 s only as the sound becomes silent; that does not establish correct continuing envelope history. Phase history remains different through 2.1 s with no new key event. Its RMS difference is large, but the dominant frequency bins remain around the same fundamental and total level differs only about +0.020 dB. A phase difference is not automatically a wrong note. The diagnostic spectral magnitude error is 0.161; integer-lag alignment does not explain it as one simple shifted waveform. No claim of human audibility follows from these screens alone.

The phase counterfactual runs 3 s with key-off scheduled at 2.10 s and key-on at 2.12 s. It stays different until 2.120111 s, then agrees through 3 s. Thus this example is event-repaired, not a natural two-second settling result. The baseline and event experiment share identical no-event history through immediately before the 2.10-s transaction; see causal_checks.json.

Macro p1 naturally matches after 55.137455 ms, but p19 sustain/attack/decay and p33 rhythm do not by 2.1 s. In p19 sustain, channel word 5 changes from full 00000000 to reduced 00001900 (key 1, FNUM 256), despite registers and RAM being correctly restored initially. Reduced EG/PG key-on edges appear at enables 44/48 with **no external musical writes**; full/control have none. This is a measured wrong-key/channel-state corruption, not merely phase cancellation. The stale decoded/pending controller history clobbering a restored channel is consistent with the controller RTL; a dedicated internal write trace was not captured, so that causal microarchitecture explanation remains inference. No-LFO macro also fails. A separate 3-s macro run remains different despite the scheduled channel-0 writes, which do not necessarily repair the spurious channel 5. These tests reject this stale-pipeline mask as universally self-healing; they do not disprove a different design that reconstructs or safely drains pending pipeline state before resume.

## Game-driven tests and counterfactuals

Sources are pinned public SMS Power FM VGM music logs: [Double Dragon](https://www.smspower.org/Music/DoubleDragon-SMS-FM) Mission 1, [Ys](https://www.smspower.org/Music/Ys-SMS-FM) First Step Towards Wars, [California Games](https://www.smspower.org/Music/CaliforniaGames-SMS-FM) Half Pipe. [Manifest and hashes](game_sources/safe_manifest.json), original archives and extracted tracks are retained. These are representative game-driven register sequences, not the original failing savestates, CPU replays, or reproductions of the stage/environment/event-attempt failures. No conclusion that those historical hardware failures are fixed is supported here.

VGM frame timestamps are parsed strictly; unsupported opcodes fail. PSG/stereo writes are counted and excluded from FM-only audio. VGM clock metadata is 3,579,540 Hz; simulation follows the actual reference 3,579,545-Hz clock. Each address/data pair uses the qualified 157-enable writer (data at +6); bursts are serialized with bounded lateness, at most 1.667 ms for DD/Ys and 2.281 ms for California Games. These logs preserve frame-level musical intent but are not cycle-exact CPU bus recordings. All nine channel register mirrors are verified at SAVE before results are accepted. Six earlier replay attempts using insufficient bus hold time failed that mirror check; they are retained in game_results.json / games and excluded entirely from the long measurements. They are infrastructure failures, not evidence against reduction.

Attack cases save near 0.2 s of source music; macro cases near 1 s. The real game stream supplies 0.6 s of stale future before restoring, then resumes the saved stream. Each macro frozen-write case uses an identical captured image, stale image and restored image to its continuing-write counterpart (state.csv byte-equality checked). Only subsequent musical writes are removed. This is a controlled test of whether further events are needed, not an emulation of a frozen game CPU.

| Macro source | Last error with normal writes | Last error with writes stopped | 2-s frozen error RMS / reference RMS | Interpretation |
|---|---:|---:|---:|---|
`;
for(const x of require('./game_counterfactuals.json'))s+=`| ${x.game} | ${f(x.withWritesLastSeconds)} | ${f(x.frozenLastSeconds)} | ${m(x.frozenResidualAt2)} / ${m(x.frozenReferenceRMSAt2)} | ${x.frozen} |\n`;
s+=`\nContinuing-write macro trajectories use 165 DD, 325 Ys and 234 California Games post-LOAD register writes. Recovery within 0.100–0.783 s under those sequences does not demonstrate natural relaxation: frozen DD/Ys remain different at the 2.1-s endpoint while their references remain active. Frozen California Games still differs in the 2-s window and becomes equal only near 2.098454 s as the sampled sound becomes silent. The counterfactual establishes dependence on subsequent writes in these examples, not which individual write is sufficient. Source events and internal key transition counts are retained for further attribution.

## Synchronized audio and reproducibility

[Analysis summary](analysis_summary.json) records every result, internal key counts, final state differences and spectral diagnostics. Each analysis/<stage>__<case>/ directory contains synchronized uninterrupted.wav, full.wav and reduced.wav plus common_gain counterparts. Raw captures use clamped signed 13-bit ×8 in 16-bit PCM. Common gain is identical across all three trajectories of a case and is recorded, never normalized independently. Sample rate is 49,716 Hz rounded from FM/72 = 49,715.902778 Hz. First frame is enable 72; exact every-enable metrics remain in result.json. WAVs are FM-only post-LOAD audio, with no PSG, analog filtering, console mute model or preroll. They support listening comparisons; no hardware listening or blinded acceptability evaluation was performed.

Useful pairs: [macro wrong-key reference](analysis/long_diverse__macro_worst_sustain/full_common_gain.wav) / [reduced](analysis/long_diverse__macro_worst_sustain/reduced_common_gain.wav); [sine reference](analysis/long_diverse__sine_no_lfo/full_common_gain.wav) / [reduced](analysis/long_diverse__sine_no_lfo/reduced_common_gain.wav); [Ys frozen reference](analysis/games_frozen__Ys_macro/full_common_gain.wav) / [reduced](analysis/games_frozen__Ys_macro/reduced_common_gain.wav). Compare original-gain captures too: gain normalization can make a quiet hiccup seem more prominent. Spectrum/lag screens are diagnostics, not hearing models or acceptance gates.

Reproduction order: prepare.js; export.js; build_native.js; calibrate.js; build_v2.js; calibrate_v2.js; campaign.js with jobs_<stage>.json; parse_vgm_safe.js; build_game_safe.js; run_games_safe.js; run_games_frozen.js; analyze.js; causal_checks.js; report.js. Tools are workspace-local; build scripts show exact dependencies and retained errors from the initial Windows make attempt. Campaign runners refuse overwriting existing run.json: use a fresh experiment directory to repeat measurements. Historical results are never rewritten. The v2 driver adds no-LFO/rollover profiles and a combined omission used only in calibration; the game driver changes stimuli, not OPLL RTL. Each raw run includes driver binary SHA256, commands, log, result.json, state.csv, final_state.csv, key_events.json, events.csv, audio.csv and internals.csv.

## Decision and remaining work

The two-second question now has measured conditional answers: **some narrow state omissions naturally converge well before two seconds; several broader ones do not, and game writes can hide their persistence**. No claim of indefinite divergence follows from a 2.1/3-s endpoint. No claim that all possible macro restoration strategies fail follows from one stale-state mask.

No reduced variant is adopted. A narrow attack-pipeline omission is the strongest next qualification candidate because its tested discrepancies are extremely brief and all three selected game replays agree almost immediately. Sine/writeback remain experimentally interesting, but even a 73–100-ms interruption needs listening and more restore positions/modes before acceptance. Feedback/controller have only limited long-position coverage. Rhythm/attack/decay coverage is representative, not exhaustive for every omission.

Do not launch Quartus solely because word count is smaller: these experiments retain the format and do not implement a production resource optimization. No new matched Quartus build, ALM/M10K saving or timing benefit is claimed. Physical builds are deferred until an actual reduced RTL design passes wider functional/integration and audible-acceptability checks and has a plausible hardware benefit; the existing M10K may remain regardless of omitted words. Until then, the qualified complete restoration remains the correctness and deployment recommendation. A different strategy could reconstruct pending controller state while retaining macro RAM, but it requires a new isolated experiment rather than assuming natural self-healing.
`;
fs.writeFileSync(p.join(d,'REPORT.md'),s);console.log('Wrote report:',a.length,'long cases; preservation passed');
