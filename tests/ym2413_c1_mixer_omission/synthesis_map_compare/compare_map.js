const fs = require('fs');
const p = require('path');

function rows(s) {
  return s.split(/\r?\n/).filter(x => x.startsWith(';')).map(x => x.split(';').slice(1, -1).map(v => v.trim()));
}
function table(s, title) {
  const i = s.indexOf('; ' + title + ' ');
  if (i < 0) return [];
  const lines = s.slice(i).split(/\r?\n/);
  let stop = lines.findIndex((x, j) => j > 3 && !x.trim());
  if (stop < 0) stop = lines.length;
  return rows(lines.slice(0, stop).join('\n'));
}
function parse(v) {
  const rpt = fs.readFileSync(p.join(__dirname, v, 'output_files/SMS.map.rpt'), 'utf8');
  const res = table(rpt, 'Analysis & Synthesis Resource Usage Summary');
  const ram = table(rpt, 'Analysis & Synthesis RAM Summary');
  const ent = table(rpt, 'Analysis & Synthesis Resource Utilization by Entity');
  const entHeader = ent[0];
  const fmEnt = ent.filter(r => r[0] && (/opll|TemporalMixer|SlotCounter|OutputGenerator|OutputMemory|savestates|system/i.test(r[0])));
  const warnings = rpt.split(/\r?\n/).map(x => x.trim()).filter(x => /^(Critical )?Warning/.test(x)).map(x => x.replace(/W:[\\/](?:b1|c1)[\\/]/gi, '<BUILD>/').replace(/Line: \d+/g, 'Line: <N>').replace(/\(\d+\):/g, '(<N>):'));
  return { res, ramCount: ram.length, fmRam: ram.filter(r => /opll|fm_snapshot/i.test(r[0] || '')), entHeader, fmEnt, warnings };
}

const b1 = parse('b1');
const c1 = parse('c1');

console.log('=== RESOURCE USAGE SUMMARY ===');
for (let i = 0; i < b1.res.length; i++) {
  const br = b1.res[i], cr = c1.res[i];
  if (JSON.stringify(br) !== JSON.stringify(cr)) console.log('DIFF:', br.join(' | '), ' ==> ', cr.join(' | '));
  else console.log('SAME:', br.join(' | '));
}

console.log('\n=== ENTITY COMPARISON ===');
console.log('Header:', b1.entHeader.slice(0, 10).join(' | '));
const mapC1 = Object.fromEntries(c1.fmEnt.map(r => [r[0], r]));
for (const r of b1.fmEnt) {
  const cr = mapC1[r[0]];
  if (cr && JSON.stringify(r.slice(0, 10)) !== JSON.stringify(cr.slice(0, 10))) {
    console.log('DIFF B1:', r.slice(0, 10).join(' | '));
    console.log('DIFF C1:', cr.slice(0, 10).join(' | '));
  } else {
    console.log('SAME   :', r.slice(0, 10).join(' | '));
  }
}

console.log('\n=== FM RAM SUMMARY ===');
console.log('B1:', b1.fmRam);
console.log('C1:', c1.fmRam);

console.log('\n=== ALL ENTITY DIFFS ===');
const allB1 = table(fs.readFileSync(p.join(__dirname, 'b1/output_files/SMS.map.rpt'), 'utf8'), 'Analysis & Synthesis Resource Utilization by Entity');
const allC1 = table(fs.readFileSync(p.join(__dirname, 'c1/output_files/SMS.map.rpt'), 'utf8'), 'Analysis & Synthesis Resource Utilization by Entity');
const mapAllC1 = Object.fromEntries(allC1.map(r => [r[7] || r[0], r]));
for (const r of allB1) {
  const k = r[7] || r[0];
  const cr = mapAllC1[k];
  if (cr && JSON.stringify(r.slice(0, 6)) !== JSON.stringify(cr.slice(0, 6))) {
    console.log(r[0].padEnd(38), 'B1:', r.slice(1, 4).join(' | ').padEnd(35), 'C1:', cr.slice(1, 4).join(' | '));
  }
}

console.log('\n=== WARNING DIFFS ===');
console.log('B1 total warnings:', b1.warnings.length, 'C1 total warnings:', c1.warnings.length);
console.log('Added in C1:', c1.warnings.filter(w => !b1.warnings.includes(w)));
console.log('Removed in C1:', b1.warnings.filter(w => !c1.warnings.includes(w)));
