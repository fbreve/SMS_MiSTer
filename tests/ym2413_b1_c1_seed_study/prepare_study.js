const fs = require('fs');
const p = require('path');
const cp = require('child_process');
const crypto = require('crypto');
const assert = require('assert');

const d = __dirname;
const repo = p.resolve(d, '../..');
const refRoot = p.join(repo, 'tests/ym2413_v19_fullstate');
const wtB1 = p.join(repo, 'tests/ym2413_optimized_integration/worktree');
const wtC1 = p.join(repo, 'tests/ym2413_c1_mixer_omission/worktree');
const base = '9873761503510e4b2c7e06600bf5515344235c2f';

const sha = b => crypto.createHash('sha256').update(b).digest('hex');
const git = (cwd, ...a) => cp.execFileSync('git', ['--no-optional-locks', ...a], { cwd });

assert.equal(git(wtB1, 'rev-parse', 'HEAD').toString().trim(), base, 'B1 worktree HEAD mismatch');
assert.equal(git(wtC1, 'rev-parse', 'HEAD').toString().trim(), base, 'C1 worktree HEAD mismatch');

const changedFiles = new Set([
  'rtl/VM2413/outputgenerator.vhd',
  'rtl/VM2413/outputmemory.vhd',
  'rtl/VM2413/temporalmixer.vhd',
  'rtl/opll_snapshot.sv',
  'rtl/savestates.sv'
]);

const refSeed1 = p.join(refRoot, 'physical_seed1');
const original = JSON.parse(fs.readFileSync(p.join(refSeed1, 'inputs.json'), 'utf8'));
require('./preflight.js');

for (const seed of [1, 2, 3]) {
  const seedDir = p.join(d, 'seed' + seed);
  if (!fs.existsSync(seedDir)) fs.mkdirSync(seedDir, { recursive: true });

  const refSeedDir = p.join(refRoot, 'physical_seed' + seed);
  assert(fs.existsSync(p.join(refSeedDir, 'results.json')), 'Missing validated baseline results in ' + refSeedDir);

  const builds = { b1: { inputs: {} }, c1: { inputs: {} } };

  for (const [variant, wt] of [['b1', wtB1], ['c1', wtC1]]) {
    const varDir = p.join(seedDir, variant);
    for (const [f, info] of Object.entries(original.builds.candidate.inputs)) {if(f.startsWith('releases/'))continue;
      let bytes;
      if (changedFiles.has(f)) {
        bytes = fs.readFileSync(p.join(wt, f));
      } else {
        bytes = fs.readFileSync(p.join(refSeed1, 'candidate', f));
        assert.equal(sha(bytes), info.SHA256, 'Reference frozen input changed: ' + f);
      }
      if (f === 'SMS.qsf' && seed !== 1) {
        const text = bytes.toString();
        assert.equal((text.match(/set_global_assignment -name SEED 1/g) || []).length, 1, 'Expected SEED 1 in SMS.qsf');
        bytes = Buffer.from(text.replace('set_global_assignment -name SEED 1', 'set_global_assignment -name SEED ' + seed));
      }
      const target = p.join(varDir, f);
      fs.mkdirSync(p.dirname(target), { recursive: true });
      if (fs.existsSync(target)) assert.equal(sha(fs.readFileSync(target)), sha(bytes), 'Existing input differs; refusing overwrite: ' + target);
      else fs.writeFileSync(target, bytes, {flag: 'wx'});
      builds[variant].inputs[f] = { ...info, SHA256: sha(bytes), seed };
    }
  }

  for (const tcl of ['settings.tcl', 'paths.tcl']) {
    const source = fs.readFileSync(p.join(refSeed1, tcl)), target = p.join(seedDir, tcl);
    if (fs.existsSync(target)) assert.equal(sha(fs.readFileSync(target)), sha(source), 'Existing query differs: ' + target);
    else fs.writeFileSync(target, source, {flag:'wx'});
  }

  const manifestPath = p.join(seedDir, 'inputs.json');
  const manifest = {
      baseline: base,
      reusedBaselineResults: p.relative(d, p.join(refSeedDir, 'results.json')).replace(/\\/g, '/'),
      reusedBaselineResultsSHA256: sha(fs.readFileSync(p.join(refSeedDir, 'results.json'))),
      version: original.version,
      device: original.device,
      seed,
      changedFiles: [...changedFiles],
      builds
    };
  if (fs.existsSync(manifestPath)) assert.deepEqual(JSON.parse(fs.readFileSync(manifestPath)), manifest, 'Existing manifest differs: ' + manifestPath);
  else fs.writeFileSync(manifestPath, JSON.stringify(manifest, null, 2) + '\n', {flag:'wx'});
}

console.log('Prepared three-seed B1/C1 study directories (reusing validated baseline results from tests/ym2413_v19_fullstate/physical_seed1..3).');

