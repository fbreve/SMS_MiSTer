const fs = require('fs');
const p = require('path');
const cp = require('child_process');
const crypto = require('crypto');
const assert = require('assert');

const d = __dirname;
const repo = p.resolve(d, '../../..');
const refDir = p.join(repo, 'tests/ym2413_v19_fullstate/physical_seed2');
const wtB1 = p.join(repo, 'tests/ym2413_optimized_integration/worktree');
const wtC1 = p.join(repo, 'tests/ym2413_c1_mixer_omission/worktree');
const base = '9873761503510e4b2c7e06600bf5515344235c2f';

const sha = b => crypto.createHash('sha256').update(b).digest('hex');
const norm = b => b.toString('latin1').replace(/\r\n/g, '\n');
const git = (cwd, ...a) => cp.execFileSync('git', ['--no-optional-locks', ...a], { cwd });

const original = JSON.parse(fs.readFileSync(p.join(refDir, 'inputs.json')));
assert.equal(git(wtB1, 'rev-parse', 'HEAD').toString().trim(), base);
assert.equal(git(wtC1, 'rev-parse', 'HEAD').toString().trim(), base);

const changedFiles = new Set([
  'rtl/VM2413/outputgenerator.vhd',
  'rtl/VM2413/outputmemory.vhd',
  'rtl/VM2413/temporalmixer.vhd',
  'rtl/opll_snapshot.sv',
  'rtl/savestates.sv'
]);

const builds = { b1: { inputs: {} }, c1: { inputs: {} } };

for (const [variant, wt] of [['b1', wtB1], ['c1', wtC1]]) {
  for (const [f, info] of Object.entries(original.builds.candidate.inputs)) {if(f.startsWith('releases/'))continue;
    let bytes;
    if (changedFiles.has(f)) {
      bytes = fs.readFileSync(p.join(wt, f));
    } else {
      bytes = fs.readFileSync(p.join(refDir, 'candidate', f));
      assert.equal(sha(bytes), info.SHA256, 'Reference frozen input ' + f);
    }
    const target = p.join(d, variant, f);
    fs.mkdirSync(p.dirname(target), { recursive: true });
    fs.writeFileSync(target, bytes);
    builds[variant].inputs[f] = { ...info, SHA256: sha(bytes) };
  }
}

fs.writeFileSync(p.join(d, 'inputs.json'), JSON.stringify({
  baseline: base,
  version: original.version,
  device: original.device,
  seed: original.seed,
  buildDate: original.buildDate,
  builds
}, null, 2));

console.log('Prepared isolated synthesis_map_compare for B1 and C1');
