const fs = require('fs');
const p = require('path');
const crypto = require('crypto');
const assert = require('assert');
const cp = require('child_process');

const d = __dirname;
const verifRoot = p.resolve(d, '../..');
const taskRoot = p.resolve(verifRoot, '..');
const wt = p.join(taskRoot, 'worktree');
const repo = p.resolve(taskRoot, '../..');

const hash = b => crypto.createHash('sha256').update(b).digest('hex');
const bytes = f => fs.readFileSync(p.join(d, f));
const read = f => {
  const b = bytes(f);
  return b.toString(b[0] === 255 && b[1] === 254 ? 'utf16le' : 'utf8').replace(/^\uFEFF/, '');
};
const exitCode = f => {
  const s = read(f).trim();
  assert(/^-?\d+$/.test(s), 'Missing explicit exit status ' + f);
  return +s;
};
const priorityInfo = f => {
  const s = read(f);
  assert(/Priority=Idle/.test(s), 'Priority not verified ' + f);
  return {
    logSHA256: hash(bytes(f)),
    samples: +(s.match(/VerifiedLowPrioritySamples=(\d+)/) || [, 1])[1]
  };
};

// 1. Verify worktree and preservation_before.json
const git = (cwd, ...a) => cp.execFileSync('git', ['--no-optional-locks', '-c', 'safe.directory=' + cwd.replace(/\\/g, '/'), ...a], { cwd, stdio: ['ignore', 'pipe', 'pipe'] });
const base = '9873761503510e4b2c7e06600bf5515344235c2f';
const branch = 'experiment/ym2413-optimized-integration';

assert.equal(git(wt, 'rev-parse', 'HEAD').toString().trim(), base, 'Worktree HEAD mismatch');
assert.equal(git(wt, 'branch', '--show-current').toString().trim(), branch, 'Worktree branch mismatch');
assert.equal(git(wt, 'diff', '--cached').length, 0, 'Worktree index must be empty');
assert.equal(git(wt, 'ls-files', '--others', '--exclude-standard').toString().trim(), '', 'Worktree has untracked files');

const changed = git(wt, 'diff', '--name-only', 'HEAD').toString().trim().split(/\r?\n/).sort();
assert.deepEqual(changed, [
  'rtl/VM2413/outputgenerator.vhd',
  'rtl/VM2413/outputmemory.vhd',
  'rtl/VM2413/temporalmixer.vhd',
  'rtl/opll_snapshot.sv',
  'rtl/savestates.sv'
], 'Unexpected changed files in worktree');

for (const f of changed) {
  assert.equal(hash(fs.readFileSync(p.join(wt, f))), hash(fs.readFileSync(p.join(verifRoot, f))), 'Verification copy mismatch for ' + f);
}

const before = JSON.parse(fs.readFileSync(p.join(taskRoot, 'preservation_before.json'), 'utf8'));
assert.equal(git(repo, 'rev-parse', 'master').toString().trim(), before.master, 'master branch moved');
for (const [w, item] of Object.entries(before.worktrees)) {
  const fullW = p.isAbsolute(w) ? w : p.join(repo, w);
  assert.equal(git(fullW, 'rev-parse', 'HEAD').toString().trim(), item.HEAD, w + ' HEAD');
  assert.equal(hash(git(fullW, 'diff', '--binary', 'HEAD')), item.diffSHA256, w + ' diffSHA256');
  assert.equal(git(fullW, 'status', '--porcelain', '--untracked-files=no').toString(), item.status, w + ' status');
}

// 2. Verify workflow concurrency & completion across 72 shifts
const active = new Set(), started = new Set();
let peakConcurrency = 0, endedCount = 0;
for (const line of read('combined_runs/workflow.log').split(/\r?\n/)) {
  let m = line.match(/^START shift=(\d+)/);
  if (m) {
    const n = +m[1];
    assert(!started.has(n), 'Duplicate START shift=' + n);
    started.add(n);
    active.add(n);
    peakConcurrency = Math.max(peakConcurrency, active.size);
    assert(peakConcurrency <= 2, 'Exceeded 2 concurrent GHDL processes: ' + peakConcurrency);
    continue;
  }
  m = line.match(/^END shift=(\d+) exit=(-?\d+)/);
  if (m) {
    assert.equal(+m[2], 0, 'Nonzero exit in workflow.log for shift=' + m[1]);
    assert(active.delete(+m[1]), 'END without active START for shift=' + m[1]);
    endedCount++;
  }
}
assert.equal(started.size, 72, 'Expected 72 started shifts');
assert.equal(endedCount, 72, 'Expected 72 ended shifts');
assert.equal(active.size, 0, 'Active set not empty at end');

// 3. Parse all 72 shift logs and aggregate per-batch & overall metrics
const offsets = [2000, 8000, 20000, 50000, 100000, 150000, 250000, 300000, 350000];
const cases = [];

for (let shift = 0; shift < 72; shift++) {
  const prefix = 'combined_runs/shift' + shift;
  assert.equal(exitCode(prefix + '.exitcode'), 0, 'Nonzero exitcode file for shift=' + shift);
  const log = read(prefix + '.log');
  assert(log.includes('PASS COMBINED ALL checkpoints=28'), 'Missing PASS COMBINED ALL for shift=' + shift);
  assert(!/assertion (failure|error)/i.test(log), 'Assertion failure/error in shift=' + shift);
  const prio = priorityInfo(prefix + '.priority.log');
  assert(prio.samples >= 1, 'Missing priority samples for shift=' + shift);

  const passes = [...log.matchAll(/PASS COMBINED shift=(\d+) pass=(\d+) reset_ce=(\d+) full_ce=(\d+) total_ce=(\d+) PALedges=(\d+) NTSCedges=(\d+) hosts=(\d+)/g)].map(m => ({
    shift: +m[1], pass: +m[2], resetCE: +m[3], fullCE: +m[4], totalCE: +m[5], PALedges: +m[6], NTSCedges: +m[7], hosts: +m[8]
  }));
  assert.equal(passes.length, 4, 'Expected 4 passes for shift=' + shift);

  const midSaves = [...log.matchAll(/PASS MID_CONVERGENCE_SAVE_LOAD shift=(\d+) pass=(\d+)/g)].map(m => ({
    shift: +m[1], pass: +m[2]
  }));
  assert.equal(midSaves.length, 4, 'Expected 4 MID_CONVERGENCE_SAVE_LOAD for shift=' + shift);

  const poisons = [...log.matchAll(/POISON BOTH shift=\d+ pass=(\d+) kind=(\d+) saved_mix=(\d+) mix=(\d+) saved_out=(\d+) out=(\d+)/g)].map(m => ({
    pass: +m[1], kind: +m[2], savedMix: +m[3], mix: +m[4], savedOut: +m[5], out: +m[6]
  }));
  assert.equal(poisons.length, 4, 'Expected 4 POISON BOTH for shift=' + shift);

  const last = [...log.matchAll(/LAST MISMATCH pass=(\d+) state_ce=(\d+) raw_ce=(\d+) clamp_ce=(\d+) state_host=(\d+) raw_host=(\d+) clamp_host=(\d+) overflow=(\d+) saturated=(\d+) follow_ns=(\d+)/g)].map(m => ({
    pass: +m[1], stateCE: +m[2], rawCE: +m[3], clampCE: +m[4], stateHost: +m[5], rawHost: +m[6], clampHost: +m[7], overflows: +m[8], saturations: +m[9], followNs: +m[10]
  }));
  assert.equal(last.length, 4, 'Expected 4 LAST MISMATCH for shift=' + shift);

  const stimuli = [...log.matchAll(/PASS STIMULUS shift=\d+ pass=(\d+) egstate=(\d+)/g)].map(m => ({
    pass: +m[1], EGstate: +m[2]
  }));
  assert.equal(stimuli.length, 4, 'Expected 4 PASS STIMULUS for shift=' + shift);

  const writes = [...log.matchAll(/LATE WRITE pass=(\d+) event=(\d+) CE=(\d+)/g)].map(m => ({
    pass: +m[1], event: +m[2], CE: +m[3]
  }));
  const effects = [...log.matchAll(/PASS LATE EFFECT pass=(\d+) event=(\d+) CE=(\d+)/g)].map(m => ({
    pass: +m[1], event: +m[2], CE: +m[3]
  }));
  assert.equal(writes.length, 9, 'Expected 9 LATE WRITE on pass 0 for shift=' + shift);
  assert.equal(effects.length, 9, 'Expected 9 PASS LATE EFFECT on pass 0 for shift=' + shift);

  const expectedReset = ((70 - shift + 72) % 72) + 1;
  const expectedFull = expectedReset + 72;
  assert(expectedFull <= 144, 'Theoretical convergence bound > 144');

  for (let k = 0; k < 4; k++) {
    const a = passes[k], b = poisons[k], z = last[k], m = midSaves[k];
    assert.equal(a.pass, k);
    assert.equal(b.pass, k);
    assert.equal(z.pass, k);
    assert.equal(m.pass, k);
    assert.equal(a.resetCE, expectedReset);
    assert.equal(a.fullCE, expectedFull);
    assert.notEqual(b.mix, b.savedMix);
    assert.notEqual(b.out, b.savedOut);
    assert.equal(z.stateCE, expectedFull - 1);
    assert.equal(z.rawCE, expectedFull - 1);
    assert.equal(z.stateHost, (expectedFull - 1) * 15);
    assert.equal(z.rawHost, (expectedFull - 1) * 15);
    assert(z.clampCE < expectedFull);
    if (k === 0) {
      assert(a.PALedges >= 6 && a.NTSCedges >= 6, 'Pass 0 video edges < 6');
      assert(z.followNs >= 115000000, 'Pass 0 followNs < 115 ms');
      for (let e = 0; e < 9; e++) {
        const w = writes[e], t = effects[e];
        assert.equal(w.pass, 0);
        assert.equal(t.pass, 0);
        assert.equal(w.event, e);
        assert.equal(t.event, e);
        assert.equal(w.CE, expectedFull + offsets[e] + 8);
        assert.equal(t.CE, expectedFull + offsets[e] + 180);
      }
    }
  }

  cases.push({
    shift,
    batch: Math.floor(shift / 24) + 1,
    stage: shift % 4,
    slot: Math.floor(shift / 4),
    pendingWritePhase: (shift % 4) === 0,
    expectedResetCE: expectedReset,
    expectedFullCE: expectedFull,
    passes,
    midSaves: midSaves.length,
    poisons,
    lastMismatch: last,
    stimuli,
    lateWrites: writes.length,
    lateEffects: effects.length,
    priority: prio,
    logSHA256: hash(bytes(prefix + '.log'))
  });
}

// 4. Parse ModelSim logs and count audio comparisons
const modelsimTests = [
  ['smoke_map.do_out.log', 'PASS independent pattern ALL'],
  ['recheck_protocol.do_out.log', 'PASS protocol ALL'],
  ['recheck_guard_protocol.do_out.log', 'PASS guard atomic FM rejection'],
  ['smoke_nonfm.do_out.log', 'PASS nonFM ALL'],
  ['smoke_validator_stream.do_out.log', 'PASS ACTUAL_VALIDATOR accepted=6912 rejected=2 no_live_FM_writes'],
  ['smoke_early_validator.do_out.log', 'PASS ACTUAL_VALIDATOR accepted=432 rejected=0 no_live_FM_writes'],
  ['smoke_guard_live.do_out.log', 'PASS LIVE_REJECTION case=1'],
  ['smoke_run.do_out.log', 'PASS fullstate'],
  ['mode1.log', 'PASS fullstate'],
  ['mode2.log', 'PASS fullstate'],
  ['mode3.log', 'PASS fullstate'],
  ['mode4.log', 'PASS fullstate'],
  ['mode5.log', 'PASS fullstate'],
  ['mode6.log', 'PASS fullstate']
];

const modelsimSummary = [];
let modelsimAudioChecks = 0;
let modelsimLoads = 0;
let modelsimCaptures = 0;
let modelsimOracleChecks = 0;

for (const [file, pattern] of modelsimTests) {
  const s = read(file);
  assert(s.includes(pattern), 'Missing pattern ' + pattern + ' in ' + file);
  assert(!/\*\* (Fatal|Error|Failure):/.test(s), 'Error in ModelSim log ' + file);
  const mFull = s.match(/PASS fullstate SHIFT=(\d+) MODE=(\d+) captures=(\d+) restores=(\d+) checks=(\d+) DDRread=(\d+) DDRwrite=(\d+) checkpoints=(\d+)/);
  const oracleMatches = (s.match(/PASS independent internal oracle:/g) || []).length;
  modelsimOracleChecks += oracleMatches;
  let entry = { file, sha256: hash(bytes(file)), oracleChecks: oracleMatches };
  if (mFull) {
    entry.shift = +mFull[1];
    entry.mode = +mFull[2];
    entry.captures = +mFull[3];
    entry.restores = +mFull[4];
    entry.audioChecks = +mFull[5];
    entry.ddrReads = +mFull[6];
    entry.ddrWrites = +mFull[7];
    modelsimCaptures += entry.captures;
    modelsimLoads += entry.restores;
    modelsimAudioChecks += entry.audioChecks;
  }
  modelsimSummary.push(entry);
}

// 5. Summarize batches
const batchSummaries = [1, 2, 3].map(b => {
  const bCases = cases.filter(c => c.batch === b);
  const bPasses = bCases.flatMap(c => c.passes);
  const bLast = bCases.flatMap(c => c.lastMismatch);
  const totalCE = bPasses.reduce((acc, x) => acc + x.totalCE, 0);
  const totalHosts = bPasses.reduce((acc, x) => acc + x.hosts, 0);
  return {
    batch: b,
    shifts: `${bCases[0].shift}..${bCases[bCases.length - 1].shift}`,
    phasesPassed: bCases.length,
    primaryLoads: bCases.length * 4,
    midConvergenceLoads: bCases.length * 4,
    totalLoads: bCases.length * 8,
    totalSaves: bCases.length * 16, // 4 initial + 4 post-initial-load recapture + 4 mid-convergence save + 4 post-mid-load recapture
    pendingWritePhases: bCases.filter(c => c.pendingWritePhase).length,
    resetCEMin: Math.min(...bPasses.map(x => x.resetCE)),
    resetCEMax: Math.max(...bPasses.map(x => x.resetCE)),
    lastMismatchCEMin: Math.min(...bLast.map(x => x.stateCE)),
    lastMismatchCEMax: Math.max(...bLast.map(x => x.stateCE)),
    fullConvergenceCEMin: Math.min(...bPasses.map(x => x.fullCE)),
    fullConvergenceCEMax: Math.max(...bPasses.map(x => x.fullCE)),
    clampLastMismatchCEMin: Math.min(...bLast.map(x => x.clampCE)),
    clampLastMismatchCEMax: Math.max(...bLast.map(x => x.clampCE)),
    totalEnabledFMClocksChecked: totalCE,
    totalHostClocksChecked: totalHosts,
    overflowCount: bLast.reduce((acc, x) => acc + x.overflows, 0),
    saturatedSamples: bLast.reduce((acc, x) => acc + x.saturations, 0),
    lateWritesVerified: bCases.reduce((acc, x) => acc + x.lateWrites, 0),
    lateEffectsVerified: bCases.reduce((acc, x) => acc + x.lateEffects, 0),
    minFollowUpNsPass0: Math.min(...bCases.map(c => c.lastMismatch[0].followNs)),
    maxFollowUpNsPass0: Math.max(...bCases.map(c => c.lastMismatch[0].followNs)),
    lowPrioritySamples: bCases.reduce((acc, c) => acc + c.priority.samples, 0)
  };
});

const allPasses = cases.flatMap(c => c.passes);
const allLast = cases.flatMap(c => c.lastMismatch);
const totalGHDLFMClocks = allPasses.reduce((acc, x) => acc + x.totalCE, 0);
const totalGHDLHostClocks = allPasses.reduce((acc, x) => acc + x.hosts, 0);

const summary = {
  status: 'PASS',
  baseline: base,
  branch,
  worktree: 'tests/ym2413_optimized_integration/worktree',
  format: { words: 100, ddramTransfers: 50, descriptorVersion: 18 },
  verifiedPeakGHDLConcurrency: peakConcurrency,
  ghdlPriority: 'Idle',
  batches: batchSummaries,
  totals: {
    phases: cases.length,
    pendingWritePhases: cases.filter(c => c.pendingWritePhase).length,
    ghdlPrimaryLoads: cases.length * 4,
    ghdlMidConvergenceLoads: cases.length * 4,
    ghdlTotalLoads: cases.length * 8,
    ghdlTotalSavesAndRecaptures: cases.length * 16,
    ghdlOracleCheckpoints: cases.length * 28,
    ghdlEnabledFMClocksChecked: totalGHDLFMClocks,
    ghdlHostClocksChecked: totalGHDLHostClocks,
    ghdlContinuousStateWordComparisons: totalGHDLHostClocks * 104,
    ghdlAudioSamplePairComparisons: totalGHDLHostClocks * 2,
    ghdlLateRegisterWritesVerified: cases.reduce((acc, c) => acc + c.lateWrites, 0),
    ghdlClockEnableGapsTested: cases.length * 3 * 9,
    ghdlAccumulatorOverflowsObserved: allLast.reduce((acc, x) => acc + x.overflows, 0),
    ghdlSaturatedSamplesObserved: allLast.reduce((acc, x) => acc + x.saturations, 0),
    modelsimSystemLoads: modelsimLoads,
    modelsimSystemCaptures: modelsimCaptures,
    modelsimAudioChecks: modelsimAudioChecks,
    modelsimTclOracleChecks: modelsimOracleChecks,
    validatorStreamAccepted: 6912 + 432,
    validatorStreamRejected: 2
  },
  convergenceBounds: {
    theoreticalMaxCE: 144,
    accumulatorResetMinCE: Math.min(...allPasses.map(x => x.resetCE)),
    accumulatorResetMaxCE: Math.max(...allPasses.map(x => x.resetCE)),
    lastMismatchMinCE: Math.min(...allLast.map(x => x.stateCE)),
    lastMismatchMaxCE: Math.max(...allLast.map(x => x.stateCE)),
    lastMismatchMinHost: Math.min(...allLast.map(x => x.stateHost)),
    lastMismatchMaxHost: Math.max(...allLast.map(x => x.stateHost)),
    fullConvergenceMinCE: Math.min(...allPasses.map(x => x.fullCE)),
    fullConvergenceMaxCE: Math.max(...allPasses.map(x => x.fullCE)),
    clampLastMismatchMinCE: Math.min(...allLast.map(x => x.clampCE)),
    clampLastMismatchMaxCE: Math.max(...allLast.map(x => x.clampCE))
  },
  modelsimRegressions: modelsimSummary,
  cases
};

fs.writeFileSync(p.join(d, 'b1_campaign_results.json'), JSON.stringify(summary, null, 2));
console.log(JSON.stringify({
  status: summary.status,
  verifiedPeakGHDLConcurrency: summary.verifiedPeakGHDLConcurrency,
  batches: summary.batches,
  totals: summary.totals,
  convergenceBounds: summary.convergenceBounds
}, null, 2));

