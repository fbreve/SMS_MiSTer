const fs = require('fs'), p = require('path'), cp = require('child_process');
const crypto = require('crypto'), assert = require('assert');
const root = p.resolve(__dirname, '../..');
const out = p.join(__dirname, 'physical');
const revisions = { baseline: 'ab09fdf41221c9e3e77eee87264a125ba43021fe', candidate: '28ead01f7f8709ddda5dc4a63206b9921cb757e0' };
const git = (...args) => cp.execFileSync('git', args, { cwd: root, maxBuffer: 64 * 1024 * 1024 });
const hash = b => crypto.createHash('sha256').update(b).digest('hex');
const json = (f, value) => fs.writeFileSync(p.join(out, f), JSON.stringify(value, null, 2) + '\n');
assert.equal(git('branch', '--show-current').toString().trim(), 'experiment/shared-savestate-word-buffer');
assert.equal(git('rev-parse', 'master').toString().trim(), revisions.baseline);
assert.equal(git('diff', revisions.candidate, '--', 'rtl').length, 0, 'Unexpected RTL changes');
assert(!fs.existsSync(p.join(out, 'runs')), 'Never overwrite a prepared build');
fs.mkdirSync(out, { recursive: true });
const manifest = { revisions, seeds: [1, 2], buildDate: '261014', sourceDifference: ['rtl/savestates.sv'], inputs: {} };
for (const [variant, revision] of Object.entries(revisions)) {
  const files = git('ls-tree', '-r', revision).toString().trim().split('\n').map(l => l.match(/^(\d+) (\w+) (\w+)\t(.+)$/)).filter(m => m[2] === 'blob');
  manifest.inputs[variant] = {};
  for (const m of files) {
    const rel = m[4], data = git('cat-file', 'blob', m[3]);
    manifest.inputs[variant][rel] = { blob: m[3], sha256: hash(data) };
    for (const seed of manifest.seeds) {
      let bytes = data;
      if (rel === 'SMS.qsf') {
        const qsf = data.toString();
        assert.equal((qsf.match(/set_global_assignment -name SEED 1/g) || []).length, 1);
        bytes = Buffer.from(qsf.replace('set_global_assignment -name SEED 1', 'set_global_assignment -name SEED ' + seed));
      }
      const target = p.join(out, 'runs', 'seed' + seed, variant, rel);
      fs.mkdirSync(p.dirname(target), { recursive: true }); fs.writeFileSync(target, bytes);
    }
  }
}
assert.deepEqual(Object.keys(manifest.inputs.baseline), Object.keys(manifest.inputs.candidate));
const changed = Object.keys(manifest.inputs.baseline).filter(f => manifest.inputs.baseline[f].sha256 !== manifest.inputs.candidate[f].sha256);
assert.deepEqual(changed, manifest.sourceDifference);
const jtag = 'JedecChain;\n\tFileRevision(JESD32A);\n\tDefaultMfr(6E);\n\n\tP ActionCode(Ign)\n\t\tDevice PartName(SOCVHPS) MfrSpec(OpMask(0));\n\tP ActionCode(Cfg)\n\t\tDevice PartName(5CSEBA6U23I7) Path("output_files/") File("SMS.sof") MfrSpec(OpMask(1));\nChainEnd;\n\nAlteraBegin;\n\tChainType(JTAG);\nAlteraEnd;\n';
manifest.generated = { build_id: hash('`define BUILD_DATE "261014"\n'), jtag: hash(jtag) };
manifest.qsfHashes = {};
for (const seed of manifest.seeds) for (const variant of Object.keys(revisions)) {
  const dir = p.join(out, 'runs', 'seed' + seed, variant);
  fs.writeFileSync(p.join(dir, 'build_id.v'), '`define BUILD_DATE "261014"\n');
  fs.writeFileSync(p.join(dir, 'jtag.cdf'), jtag);
  manifest.qsfHashes[seed + '/' + variant] = hash(fs.readFileSync(p.join(dir, 'SMS.qsf')));
}
json('input_manifest.json', manifest);
fs.writeFileSync(p.join(out, 'production.diff'), git('diff', revisions.baseline, revisions.candidate, '--', 'rtl/savestates.sv'));
console.log(JSON.stringify({ files: Object.keys(manifest.inputs.baseline).length, changed, seeds: manifest.seeds }));
