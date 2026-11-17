const fs = require('fs');
const p = require('path');
const crypto = require('crypto');
const assert = require('assert');

const d = __dirname;
const repo = p.resolve(d, '../..');
const refRoot = p.join(repo, 'tests/ym2413_v19_fullstate');
const sha = f => crypto.createHash('sha256').update(fs.readFileSync(f)).digest('hex');
const read = f => { const b=fs.readFileSync(f); return b.toString(b[0]===255&&b[1]===254?'utf16le':'utf8'); };
const rows=s=>s.split(/\r?\n/).filter(x=>x.startsWith(';')).map(x=>x.split(';').slice(1,-1).map(v=>v.trim()));
function paths(file,kind) {
  return read(file).split(new RegExp('Path #\\d+: '+kind+' slack is ')).slice(1).map(s=>{
    const r=rows(s),get=n=>(r.find(x=>x[0]===n)||[])[1];
    return {slack:+s.split(/\s/)[0],from:get('From Node'),to:get('To Node'),launch:get('Launch Clock'),latch:get('Latch Clock')};
  });
}

function parseVariant(dir) {
  const out = p.join(dir, 'output_files');
  if (fs.existsSync(p.join(dir,'build.failed')) || !fs.existsSync(p.join(dir, 'build.done')) || !fs.existsSync(p.join(out, 'SMS.sta.summary'))) {
    const failed=p.join(dir,'build.failed');
    return { complete: false, outcome:fs.existsSync(failed)?'tool_or_infrastructure_failure':'pending_or_interrupted',failure:fs.existsSync(failed)?read(failed):null };
  }
  const fit = read(p.join(out, 'SMS.fit.rpt'));
  const summary = read(p.join(out, 'SMS.fit.summary'));
  const ms = read(p.join(out, 'SMS.map.summary'));
  const ss = read(p.join(out, 'SMS.sta.summary'));
  const n = (re, s = fit) => {
    const m = s.match(re);
    assert(m, 'Missing metric ' + re + ' in ' + dir);
    return +m[1].replaceAll(',', '');
  };
  const timing = [...ss.matchAll(/Type\s*:\s*([^\r\n]+)\r?\nSlack\s*:\s*(-?[\d.]+)\r?\nTNS\s*:\s*(-?[\d.]+)/g)].map(x => ({
    type: x[1], slack: +x[2], tns: +x[3]
  }));
  const tKind = k => timing.filter(x => x.type.startsWith(k));
  const setupSlack = Math.min(...tKind('Setup').map(x => x.slack));
  const setupTNS = Math.min(...tKind('Setup').map(x => x.tns));
  const holdSlack = Math.min(...tKind('Hold').map(x => x.slack));
  const holdTNS = Math.min(...tKind('Hold').map(x => x.tns));
  const violations = timing.filter(x => x.slack < 0 || x.tns < 0);
  assert(tKind('Setup').length&&tKind('Hold').length,'Missing setup/hold results in '+dir);
  const reportFiles=fs.readdirSync(out).filter(f=>/\.(rpt|summary)$/.test(f));
  const warnings=[...new Set(reportFiles.flatMap(f=>read(p.join(out,f)).split(/\r?\n/)).map(x=>x.trim()).filter(x=>/^(Critical )?Warning(?: \(\d+\))?:/.test(x)))];
  const ram=fit.slice(fit.indexOf('; Fitter RAM Summary ')).split(/\r?\n\s*\r?\n/)[0];
  const ramRows=rows(ram),header=ramRows.find(x=>x.includes('MLAB cells')&&x.includes('M10K blocks'));
  assert(header,'Missing RAM summary header');
  const ml=header.indexOf('MLAB cells'),m10=header.indexOf('M10K blocks');
  const resources=ramRows.filter(x=>/^\d+$/.test(x[ml])&&/^\d+$/.test(x[m10]));
  assert(resources.length,'Missing RAM rows');
  const physical=Object.fromEntries(fs.readdirSync(dir).filter(f=>/^physical_.*\.rpt$/.test(f)).map(f=>[f,sha(p.join(dir,f))]));
  const expectedSeed=+p.basename(p.dirname(dir)).match(/seed([123])$/)[1];
  assert(new RegExp('Fitter Initial Placement Seed\\s*;\\s*'+expectedSeed+'\\s*;').test(fit),'Wrong fitter seed');
  assert(summary.includes('17.0.2 Build 602')&&summary.includes('Device : 5CSEBA6U23I7'),'Wrong tool/device');
  const mapped=read(p.join(out,'SMS.map.rpt')).replace(/\\/g,'/');
  const inputs=JSON.parse(read(p.join(p.dirname(dir),'inputs.json'))).builds[p.basename(dir)].inputs;
  for(const [f,i]of Object.entries(inputs))assert.equal(sha(p.join(dir,f)),i.SHA256,'Changed build input '+f);
  const sourceRows=rows(mapped);
  for(const f of ['rtl/VM2413/outputgenerator.vhd','rtl/VM2413/outputmemory.vhd','rtl/VM2413/temporalmixer.vhd','rtl/opll_snapshot.sv','rtl/savestates.sv'])assert(sourceRows.some(x=>x[0].toLowerCase()===f.toLowerCase()&&x[1]==='yes'),'Source absent or unused in map report '+f);
  assert.equal(resources.reduce((s,x)=>s+ +x[m10],0),n(/; M10K blocks\s*;\s*([\d,]+)/),'RAM row totals disagree');

  return {
    complete: true,
    outcome: violations.length?'timing_failure':'timing_pass',
    timing,
    setupTNSDistinctGroups:tKind('Setup').reduce((s,x)=>s+x.tns,0),
    holdTNSDistinctGroups:tKind('Hold').reduce((s,x)=>s+x.tns,0),
    warnings,
    warningCounts:{total:warnings.length,critical:warnings.filter(x=>x.startsWith('Critical')).length},
    paths:{setup:paths(p.join(dir,'physical_setup.rpt'),'Setup'),hold:paths(p.join(dir,'physical_hold.rpt'),'Hold')},
    MLABcells:resources.reduce((s,x)=>s+ +x[ml],0),
    reportHashes:Object.fromEntries(reportFiles.map(f=>[f,sha(p.join(out,f))])),
    physicalReportHashes:physical,
    neededALMs: n(/Logic utilization[^:]*:\s*([\d,]+)/, summary),
    placedALMs: n(/\[A\] ALMs used in final placement[^;]*;\s*([\d,]+)/),
    recoverableALMs: n(/\[B\] Estimate of ALMs recoverable[^;]*;\s*([\d,]+)/),
    unavailableALMs: n(/\[C\] Estimate of ALMs unavailable[^;]*;\s*([\d,]+)/),
    fittedRegisters: n(/Total registers\s*:\s*([\d,]+)/, summary),
    mappedRegisters: n(/Total registers\s*:\s*([\d,]+)/, ms),
    M10K: n(/; M10K blocks\s*;\s*([\d,]+)/),
    memoryBits: n(/Total block memory bits\s*:\s*([\d,]+)/, summary),
    MLABbits: n(/Total MLAB memory bits\s*;\s*([\d,]+)/),
    memoryALMs: n(/ALMs used for memory[^;]*;\s*([\d,]+)/),
    DSP: n(/Total DSP Blocks\s*:\s*([\d,]+)/, summary),
    logicALUTs: n(/Combinational ALUT usage for logic\s*;\s*([\d,]+)/),
    routingALUTs: n(/Combinational ALUT usage for route-throughs\s*;\s*([\d,]+)/),
    setupSlack,
    setupTNS,
    holdSlack,
    holdTNS,
    qualifiedConstrainedTiming: violations.length === 0 && setupSlack >= 0 && holdSlack >= 0,
    violations,
    rbfSHA256: sha(p.join(out, 'SMS.rbf'))
  };
}

const study = { seeds: [], tnsDefinition:'setupTNS/holdTNS = worst clock-group TNS; DistinctGroups = sum over reported groups; units ns. Timing qualification covers constrained paths only.' };
for (const seed of [1, 2, 3]) {
  const manifest=p.join(d,'seed'+seed,'inputs.json');
  if(fs.existsSync(manifest))assert.equal(sha(p.join(refRoot,'physical_seed'+seed,'results.json')),JSON.parse(read(manifest)).reusedBaselineResultsSHA256,'Reused reference results changed');
  const refRes = JSON.parse(read(p.join(refRoot, 'physical_seed' + seed, 'results.json')));
  const base = refRes.builds.baseline;
  const full104 = refRes.builds.candidate;
  const b1 = parseVariant(p.join(d, 'seed' + seed, 'b1'));
  const c1 = parseVariant(p.join(d, 'seed' + seed, 'c1'));
  study.seeds.push({
    seed,
    baseline: {
      ...base,
      complete: true,
      neededALMs: base.neededALMs,
      placedALMs: base.placedALMs,
      fittedRegisters: base.fittedRegisters,
      mappedRegisters: base.mappedRegisters,
      M10K: base.M10K,
      MLABbits: base.MLABbits,
      memoryALMs: base.memoryALMs,
      setupSlack: base.setupSlack,
      setupTNS: base.setupTNS,
      holdSlack: base.holdSlack,
      qualifiedConstrainedTiming: base.qualifiedConstrainedTiming
    },
    v17_104w: {
      ...full104,
      complete: true,
      neededALMs: full104.neededALMs,
      placedALMs: full104.placedALMs,
      fittedRegisters: full104.fittedRegisters,
      mappedRegisters: full104.mappedRegisters,
      M10K: full104.M10K,
      MLABbits: full104.MLABbits,
      memoryALMs: full104.memoryALMs,
      setupSlack: full104.setupSlack,
      setupTNS: full104.setupTNS,
      holdSlack: full104.holdSlack,
      qualifiedConstrainedTiming: full104.qualifiedConstrainedTiming
    },
    b1,
    c1
  });
}

const metrics=['neededALMs','placedALMs','fittedRegisters','mappedRegisters','MLABcells','MLABbits','M10K','setupSlack','holdSlack','setupTNS','holdTNS'];
study.averages={};
for(const v of ['baseline','v17_104w','b1','c1']) {
  const builds=study.seeds.map(s=>s[v]);
  study.averages[v]=builds.every(b=>b.complete)?Object.fromEntries(metrics.map(k=>[k,builds.reduce((s,b)=>s+b[k],0)/3])):null;
}
study.allComplete=study.seeds.every(s=>s.b1.complete&&s.c1.complete);
const columns=['seed','variant',...metrics,'warnings','critical','outcome'];
const lines=[columns.join(' | '),columns.map(()=> '---').join(' | ')];
for(const s of study.seeds)for(const v of ['v17_104w','b1','c1']) {
 const b=s[v];lines.push([s.seed,v,...metrics.map(k=>b.complete?b[k]:'pending'),b.warningCounts?.total??'',b.warningCounts?.critical??'',b.complete?(b.qualifiedConstrainedTiming?'timing_pass':'timing_failure'):'incomplete'].join(' | '));
}
for(const [v,a]of Object.entries(study.averages))if(a)lines.push(['average',v,...metrics.map(k=>a[k].toFixed(3)),'','',''].join(' | '));
fs.writeFileSync(p.join(d,'study_results.md'),lines.join('\n')+'\n\n'+study.tnsDefinition+'\n\nCritical paths and complete warning text are preserved in study_results.json. Averages for B1/C1 require all three completed builds.\n');
fs.writeFileSync(p.join(d, 'study_results.json'), JSON.stringify(study, null, 2) + '\n');
console.log(JSON.stringify({allComplete:study.allComplete,averages:study.averages}, null, 2));

