const fs=require('fs'),p=require('path'),crypto=require('crypto'),assert=require('assert'),zlib=require('zlib'),cp=require('child_process');
const root=p.resolve(__dirname,'../..'),dir=p.join(__dirname,'physical');
const read=f=>{const b=fs.readFileSync(f);return b.toString(b[0]===255&&b[1]===254?'utf16le':'utf8').replace(/^\uFEFF/,'');};
const hash=b=>crypto.createHash('sha256').update(b).digest('hex');
const json=(file,value)=>fs.writeFileSync(p.join(dir,file),JSON.stringify(value,null,2)+'\n');
const manifest=JSON.parse(read(p.join(dir,'input_manifest.json')));
const tools=JSON.parse(read(p.join(dir,'tool_identity.json'))),prior=JSON.parse(read(p.join(dir,'pr224_reference.json')));
assert(/17\.0\.2 Build 602/.test(tools.version));
assert.deepEqual(tools.binaries,prior.toolBinaries,'Quartus executable identities changed');
assert.equal(cp.execFileSync('git',['rev-parse','master'],{cwd:root,encoding:'utf8'}).trim(),manifest.revisions.baseline);
assert.equal(cp.execFileSync('git',['diff',manifest.revisions.candidate,'--','rtl'],{cwd:root}).length,0);
const workflow=read(p.join(dir,'workflow.log'));
const selectedSeeds=process.argv.includes('--partial')?manifest.seeds.filter(seed=>['baseline','candidate'].every(v=>workflow.includes(`seed${seed} ${v} sta ended exit=0`))):manifest.seeds;
assert(selectedSeeds.length,'No complete matched pair');
const results={revisions:manifest.revisions,configuration:{tool:tools.version,device:'5CSEBA6U23I7',top:'sys_top',revision:'SMS',seeds:manifest.seeds,buildDate:manifest.buildDate},builds:{},delta:{},baselineVsPrior:{},warnings:{},archive:{}};
results.complete=selectedSeeds.length===manifest.seeds.length;
const normalize=s=>s.replaceAll('Z:/baseline/','<BUILD>/').replaceAll('Z:/candidate/','<BUILD>/').replace(/(savestates\.sv Line:) \d+/g,'$1 <LINE>');
function measure(folder,seed){
 const fit=read(p.join(folder,'output_files/SMS.fit.summary')),rpt=read(p.join(folder,'output_files/SMS.fit.rpt'));
 const map=read(p.join(folder,'output_files/SMS.map.summary')),maprpt=read(p.join(folder,'output_files/SMS.map.rpt')),sta=read(p.join(folder,'output_files/SMS.sta.summary'));
 const n=(re,s=fit)=>{const m=s.match(re);assert(m,'Missing metric '+re);return +m[1].replaceAll(',','');};
 const out={needed:n(/Logic utilization[^:]*:\s*([\d,]+)/),placed:n(/\[A\] ALMs used in final placement[^;]*;\s*([\d,]+)/,rpt),registers:n(/Total registers\s*:\s*([\d,]+)/),mappedRegisters:n(/Total registers\s*:\s*([\d,]+)/,map),M10K:n(/; M10K blocks\s*;\s*([\d,]+)/,rpt),memoryBits:n(/Total block memory bits\s*:\s*([\d,]+)/),DSP:n(/Total DSP Blocks\s*:\s*([\d,]+)/),logicALUT:n(/Combinational ALUT usage for logic\s*;\s*([\d,]+)/,rpt),routingALUT:n(/Combinational ALUT usage for route-throughs\s*;\s*([\d,]+)/,rpt)};
 out.effectiveSeed=n(/Fitter Initial Placement Seed\s*;\s*(\d+)/,rpt);assert.equal(out.effectiveSeed,seed);
 out.recoverable=n(/\[B\] Estimate of ALMs recoverable[^;]*;\s*([\d,]+)/,rpt);
 out.unavailable=n(/\[C\] Estimate of ALMs unavailable[^;]*;\s*([\d,]+)/,rpt);
 out.MLABbits=n(/Total MLAB memory bits\s*;\s*([\d,]+)/,rpt);
 assert.equal(out.needed,out.placed-out.recoverable+out.unavailable);
 out.timing=[...sta.matchAll(/Type\s*:\s*([^\r\n]+)\r?\nSlack\s*:\s*(-?[\d.]+)\r?\nTNS\s*:\s*(-?[\d.]+)/g)].map(m=>({type:m[1],slack:+m[2],tns:+m[3]}));
 for(const type of ['Setup','Hold'])assert(out.timing.some(t=>t.type.startsWith(type)));
 out.setup=Math.min(...out.timing.filter(t=>t.type.startsWith('Setup')).map(t=>t.slack));
 out.hold=Math.min(...out.timing.filter(t=>t.type.startsWith('Hold')).map(t=>t.slack));
 out.setupTNS=Math.min(...out.timing.filter(t=>t.type.startsWith('Setup')).map(t=>t.tns));
 out.holdTNS=Math.min(...out.timing.filter(t=>t.type.startsWith('Hold')).map(t=>t.tns));
 out.savestatesFitRows=rpt.split(/\r?\n/).filter(l=>/;\s*savestates\s*;\s*work\s*;/.test(l));
 out.savestatesMapRows=maprpt.split(/\r?\n/).filter(l=>/;\s*savestates\s*;\s*work\s*;/.test(l));
 assert.equal(out.savestatesFitRows.length,1);assert.equal(out.savestatesMapRows.length,1);
 const fitCells=out.savestatesFitRows[0].split(';').slice(1,-1).map(s=>s.trim());
 const mapCells=out.savestatesMapRows[0].split(';').slice(1,-1).map(s=>s.trim());
 out.savestatesMapped={logicALUT:parseFloat(mapCells[1]),registers:parseFloat(mapCells[2])};
 out.savestatesFitted={needed:parseFloat(fitCells[1]),placed:parseFloat(fitCells[2]),logicALUT:parseFloat(fitCells[6]),registers:parseFloat(fitCells[7])};
 const header=(r,title)=>{const start=r.indexOf('; '+title);return r.slice(start,start+12000).split(/\r?\n/).filter(l=>/^;\s*Compilation Hierarchy Node/.test(l));};
 out.fitHierarchyHeaders=header(rpt,'Fitter Resource Utilization by Entity');
 out.mapHierarchyHeaders=header(maprpt,'Analysis & Synthesis Resource Utilization by Entity');
 out.interconnect=rpt.split(/\r?\n/).filter(l=>/Average interconnect usage|Peak interconnect usage/.test(l));
 const files=fs.readdirSync(p.join(folder,'output_files')).filter(f=>/\.(rpt|summary)$/.test(f)).map(f=>'output_files/'+f).concat(['map.log','fit.log','asm.log','sta.log']);
 const all=files.map(f=>read(p.join(folder,f))).join('\n');
 out.warnings=[...new Set(all.split(/\r?\n/).map(l=>l.trim()).filter(l=>/^(Critical )?Warning(?: \(\d+\))?:/.test(l)))];
 out.normalizedWarnings=[...new Set(out.warnings.map(normalize))].sort();
 out.warningIds=[...new Set(out.warnings.map(l=>(l.match(/Warning \((\d+)\)/)||[])[1]||'unnumbered'))].sort();
 out.criticalWarnings=out.warnings.filter(l=>l.startsWith('Critical')).length;
 out.unconstrained=[...new Set([...all.matchAll(/Design is not fully constrained for (setup|hold) requirements/g)].map(m=>m[1]))];
 return {out,files};
}
for(const seed of selectedSeeds){
 results.builds[seed]={};
 for(const variant of ['baseline','candidate']){
  const folder=p.join(dir,'runs','seed'+seed,variant);
  for(const stage of ['map','fit','asm','sta'])assert(workflow.includes(`seed${seed} ${variant} ${stage} ended exit=0`),`Incomplete seed${seed} ${variant} ${stage}`);
  for(const [file,input] of Object.entries(manifest.inputs[variant])){
   const bytes=fs.readFileSync(p.join(folder,file));
   assert.equal(hash(bytes),file==='SMS.qsf'?manifest.qsfHashes[seed+'/'+variant]:input.sha256,`Source changed: ${seed}/${variant}/${file}`);
  }
  assert.equal(hash(fs.readFileSync(p.join(folder,'build_id.v'))),manifest.generated.build_id);
  assert.equal(hash(fs.readFileSync(p.join(folder,'jtag.cdf'))),manifest.generated.jtag);
  const {out,files}=measure(folder,seed);results.builds[seed][variant]=out;
  for(const file of files){
   const bytes=fs.readFileSync(p.join(folder,file)),rel=`evidence/seed${seed}/${variant}/${file.replace('output_files/','reports/')}.gz`,target=p.join(dir,rel);
   fs.mkdirSync(p.dirname(target),{recursive:true});fs.writeFileSync(target,zlib.gzipSync(bytes,{level:9}));
   results.archive[rel]={original:file,sha256:hash(bytes),gzipSha256:hash(fs.readFileSync(target)),bytes:bytes.length};
  }
 }
 const a=results.builds[seed].baseline,b=results.builds[seed].candidate;
 results.delta[seed]=Object.fromEntries(['needed','placed','registers','mappedRegisters','M10K','MLABbits','memoryBits','DSP','logicALUT','routingALUT','setup','hold'].map(k=>[k,+(b[k]-a[k]).toFixed(3)]));
 results.baselineVsPrior[seed]=Object.fromEntries(Object.entries(prior.expectedBaselineBySeed[seed]).map(([k,v])=>[k,+(a[k==='synthesisRegisters'?'mappedRegisters':k]-v).toFixed(3)]));
 results.warnings[seed]={added:b.normalizedWarnings.filter(x=>!a.normalizedWarnings.includes(x)),removed:a.normalizedWarnings.filter(x=>!b.normalizedWarnings.includes(x))};
}
// Re-read compressed reports to qualify the preserved evidence, not merely the local databases.
for(const [file,item] of Object.entries(results.archive))assert.equal(hash(zlib.gunzipSync(fs.readFileSync(p.join(dir,file)))),item.sha256);
results.scripts=Object.fromEntries(['prepare_physical.js','build_physical.ps1','collect_physical.js'].map(f=>[f,hash(fs.readFileSync(p.join(__dirname,f)))]));
json('results.json',results);
let table='| Seed | Variant | Needed ALMs | Placed ALMs | Mapped FF | Fitted FF | M10K | Setup ns | Hold ns |\n| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |\n';
for(const seed of selectedSeeds)for(const variant of ['baseline','candidate']){const x=results.builds[seed][variant];table+=`| ${seed} | ${variant} | ${x.needed} | ${x.placed} | ${x.mappedRegisters} | ${x.registers} | ${x.M10K} | ${x.setup} | ${x.hold} |\n`;}
fs.writeFileSync(p.join(dir,'comparison.md'),table);
console.log(JSON.stringify({delta:results.delta,baselineVsPrior:results.baselineVsPrior,warnings:results.warnings},null,2));
