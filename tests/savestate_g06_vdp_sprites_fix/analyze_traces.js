// Read-only diagnostic analysis. X bits remain X; they are not image evidence.
const fs=require('fs'), path=require('path'), crypto=require('crypto');
const root=__dirname;
function csv(rel){const rows=fs.readFileSync(path.join(root,rel),'utf8').trim().split(/\r?\n/);const keys=rows.shift().split(',');return rows.map(s=>Object.fromEntries(s.split(',').map((v,i)=>[keys[i],v])));}
function bits(s){return [...s.toLowerCase()].map(c=>/[0-9a-f]/.test(c)?parseInt(c,16).toString(2).padStart(4,'0'):'xxxx').join('');}
function field(s,lo,width){const b=bits(s);return b.slice(b.length-lo-width,b.length-lo);}
function sprite(r){return {state:field(r.sprites,592,3),count:field(r.sprites,595,7),index:field(r.sprites,602,6),overflow:field(r.sprites,635,1),collide:field(r.sprites,634,1),delay:field(r.sprites,636,14),enable0:field(r.sprites,0,1),x0:field(r.sprites,1,8),shift0:field(r.sprites,41,33),enable1:field(r.sprites,74,1),x1:field(r.sprites,75,8),shift1:field(r.sprites,115,33)};}
function select(r){return {...r,sprite:sprite(r),collisionFlag:field(r.vdp,117,1),overflowFlag:field(r.vdp,118,1),lineOverflow:field(r.vdp,119,1)};}
const out={note:'Test-only ceiling, not a production fix or format proof.',files:{}};
for(const name of ['trace_overflow','trace_reference','trace_collision']){
 const rel=`prototype/${name}/cycles.csv`,file=path.join(root,rel);if(!fs.existsSync(file))continue;
 const rows=csv(rel), releases=[];
 for(let i=1;i<rows.length;i++)if(rows[i-1].freeze==='1'&&rows[i].freeze==='0')releases.push(i);
 const captureIndex=rows.findIndex(r=>r.freeze==='1');
 const tail=releases.length?rows.slice(releases.at(-1)):(name==='trace_reference'&&captureIndex>=0?rows.slice(captureIndex):rows);
 const events=tail.filter((r,i)=>i===0||r.ce_vdp==='1'||r.ce_pix==='1');
 out.files[name]={rows:rows.length,sha256:crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex'),capture:rows.find(r=>r.freeze==='1')&&select(rows.find(r=>r.freeze==='1')),releases:releases.map(i=>select(rows[i])),firstEnables:events.slice(0,12).map(select),statusReadEvents:tail.filter((r,i)=>r.RD==='0'&&r.IORQ==='0'&&(i===0||tail[i-1].RD!=='0'||tail[i-1].IORQ!=='0')).map(select)};
}
if(out.files.trace_reference&&out.files.trace_collision.releases.length===2){
 const ref=csv('prototype/trace_reference/cycles.csv'),dut=csv('prototype/trace_collision/cycles.csv');
 const refStart=Number(out.files.trace_reference.capture.cycle),dutStart=Number(out.files.trace_collision.releases.at(-1).cycle);
 const byOffset=new Map(ref.map(r=>[Number(r.cycle)-refStart,r]));
 const comparisons=dut.filter(r=>Number(r.cycle)>=dutStart).map(r=>[byOffset.get(Number(r.cycle)-dutStart),r]).filter(([a])=>a);
 const different=(a,b,k)=>a[k].toLowerCase()!==b[k].toLowerCase();
 const fields=['ce_vdp','ce_pix','x','y','sprites','A','RD','IORQ'];
 out.alignedNativeClocks={refStart,dutStart,compared:comparisons.length,fields:Object.fromEntries(fields.map(k=>{const diffs=comparisons.filter(([a,b])=>different(a,b,k));return[k,{differences:diffs.length,first:diffs.length?{reference:select(diffs[0][0]),restored:select(diffs[0][1])}:null}];})),note:'sprites compares all 650 raw bits including retained unused X. It is a diagnostic identity result, not initialized whole-image proof.'};
}
fs.writeFileSync(path.join(root,'trace_analysis.json'),JSON.stringify(out,null,2)+'\n');
console.log(JSON.stringify(Object.fromEntries(Object.entries(out.files).map(([k,v])=>[k,{rows:v.rows,releases:v.releases.map(r=>({cycle:r.cycle,x:r.x,y:r.y})),statusReads:v.statusReadEvents.map(r=>({cycle:r.cycle,x:r.x,y:r.y,DI:r.DI,replay:r.replay}))}])),null,2));
if(out.alignedNativeClocks)console.log(JSON.stringify({alignedClocks:out.alignedNativeClocks.compared,differences:Object.fromEntries(Object.entries(out.alignedNativeClocks.fields).map(([k,v])=>[k,v.differences]))},null,2));
