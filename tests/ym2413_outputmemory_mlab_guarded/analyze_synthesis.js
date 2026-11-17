const fs=require('fs'),p=require('path'),c=require('crypto'),assert=require('assert'),d=__dirname,build=p.join(d,'synthesis/candidate'),ref=p.resolve(d,'../ym2413_outputmemory_mlab/physical_seed2/candidate'),sha=b=>c.createHash('sha256').update(b).digest('hex');
function parse(dir){const f=p.join(dir,'output_files/SMS.map.rpt'),txt=fs.readFileSync(f,'utf8'),lines=txt.split(/\r?\n/);const rows=lines.filter(x=>x.startsWith(';')).map(x=>x.split(';').slice(1,-1).map(y=>y.trim()));
 const field=n=>{const r=rows.find(x=>x[0]===n);return r?r[1]:null;};
 const hierarchy=rows.filter(x=>x.length===10&&/\|sys_top/.test(x[7])).map(x=>({node:x[0],aluts:x[1],registers:x[2],blockBits:x[3],path:x[7],entity:x[8]}));
 const memories=rows.filter(x=>x.length===9&&['AUTO','M10K','MLAB'].includes(x[1])&&/Port/.test(x[2])).map(x=>({name:x[0],type:x[1],mode:x[2],aDepth:x[3],aWidth:x[4],bDepth:x[5],bWidth:x[6],size:x[7],mif:x[8]}));
 const warnings=lines.filter(x=>/^(Warning|Critical Warning)/.test(x));
 return {reportSHA256:sha(fs.readFileSync(f)),summary:{combinationalALUTs:field('Combinational ALUT usage for logic'),registers:field('Total registers'),MLABbits:field('Total MLAB memory bits'),blockBits:field('Total block memory bits')},hierarchy,memories,warnings};
}
const before=parse(ref),after=parse(build);
function local(r,entity){const a=r.hierarchy.filter(x=>x.entity===entity);assert(a.length,entity);return a;}
const hierarchy={};for(const name of ['savestates','OutputMemory','RegisterMemory','FeedbackMemory','PhaseMemory','opll_snapshot'])hierarchy[name]={before:local(before,name),after:local(after,name)};
const num=s=>Number(s.replace(/,/g,'').match(/\d+/)[0]);
const b=hierarchy.savestates.before[0],a=hierarchy.savestates.after[0];
const delta={savestatesALUTs:num(a.aluts)-num(b.aluts),savestatesRegisters:num(a.registers)-num(b.registers)};
for(const k of ['combinationalALUTs','registers','MLABbits','blockBits'])if(before.summary[k]&&after.summary[k])delta[k]=num(after.summary[k])-num(before.summary[k]);
const normalize=s=>s.replace(/\b(?:[A-Z]:[\\/])[^\s"]+/gi,'<path>').replace(/\bline \d+/gi,'line <n>');
const warningBefore=new Set(before.warnings.map(normalize)),warningAfter=new Set(after.warnings.map(normalize));
const warnings={before:before.warnings.length,after:after.warnings.length,added:[...warningAfter].filter(x=>!warningBefore.has(x)),removed:[...warningBefore].filter(x=>!warningAfter.has(x))};
const memoryShape=x=>JSON.stringify(x.map(v=>({...v,name:v.name.replace(/(?:altsyncram|dpram)_[a-z0-9]+/gi,'<generated>')})).sort((a,b)=>a.name.localeCompare(b.name)));
const outMem=after.memories.filter(x=>/data_array/.test(x.name)&&x.type==='MLAB');assert.equal(outMem.length,2);assert(outMem.every(x=>x.aDepth==='19'&&x.aWidth==='10'&&x.bDepth==='19'&&x.bWidth==='10'));
const tdfs=fs.readdirSync(p.join(build,'db')).filter(f=>/^dpram.*\.tdf$/.test(f)).map(f=>({file:f,text:fs.readFileSync(p.join(build,'db',f),'utf8')})).filter(x=>/NUMWORDS=19/.test(x.text)&&/WIDTH=10/.test(x.text));
assert(tdfs.length);const templates=tdfs.map(x=>({file:x.file,SHA256:sha(Buffer.from(x.text)),macro:x.text.split(/\r?\n/)[0],resources:(x.text.match(/--synthesis_resources[^\r\n]*/)||[])[0],rawCollisionModes:[...new Set([...x.text.matchAll(/mixed_port_feed_through_mode\s*=\s*"([^"]+)"/gi)].map(m=>m[1]))],registeredOutput:/OUTDATA_REG="OUTCLOCK"/.test(x.text)}));
assert(templates.every(x=>x.registeredOutput&&x.rawCollisionModes.includes('dont care')));
const result={scope:'Analysis & Synthesis only; ALUT/register counts are mapped logical resources, not fitted ALMs/registers or physical MLAB placement/timing',reference:'unguarded OutputMemory MLAB Seed2 identical frozen config',before:before.summary,after:after.summary,delta,hierarchy,memoriesBefore:before.memories,memoriesAfter:after.memories,memoryShapeUnchanged:memoryShape(before.memories)===memoryShape(after.memories),warnings,templates,reportHashes:{reference:before.reportSHA256,candidate:after.reportSHA256},collisionSafety:'DONT_CARE retained; safety comes from validated sequencing, not native OLD_DATA'};
fs.writeFileSync(p.join(d,'synthesis_results.json'),JSON.stringify(result,null,2));console.log(JSON.stringify({before:result.before,after:result.after,delta,warnings,outputMemoryReplicas:outMem,templates},null,2));
