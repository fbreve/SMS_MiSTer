const fs=require('fs'),p=require('path'),crypto=require('crypto'),assert=require('assert');const d=__dirname;
const read=f=>fs.readFileSync(p.join(d,f),'utf8'),sha=b=>crypto.createHash('sha256').update(b).digest('hex');
const logs=['baseline','candidate'].map(name=>({name,text:read(name+'.log')}));
const result={status:'INCONCLUSIVE unless first playable screen and affected map updates are independently validated',configuration:'Standard ROM; NTSC/export; no external BIOS; turbo off; native divider; production T2Write=0; master controller900000-clock flush; deterministic DDR response3clocks; synchronous ROM/WRAM/SRAM service models.',sceneValidated:false,mapUpdatesValidated:false,runs:[],checkpoints:[],events:{}};
for(const r of logs){result.runs.push({name:r.name,completed:r.text.includes('COMPLETE movement sequence'),errors:[...r.text.matchAll(/\*\* (?:Fatal|Error):[^\r\n]*/g)].map(m=>m[0]),accepts:[...r.text.matchAll(/ACCEPT[^\r\n]+/g)].map(m=>m[0]),restores:[...r.text.matchAll(/RESTORE[^\r\n]+/g)].map(m=>m[0]),loadChecks:[...r.text.matchAll(/LOAD_CHECK[^\r\n]+/g)].map(m=>m[0]),logSHA256:sha(Buffer.from(r.text))});}
const names=fs.readdirSync(d).filter(f=>/^baseline_.*\.mem$/.test(f));
for(const a of names){const b=a.replace(/^baseline_/,'candidate_');if(!fs.existsSync(p.join(d,b)))continue;const x=fs.readFileSync(p.join(d,a)),y=fs.readFileSync(p.join(d,b));assert(x.length===73728&&y.length===73728);const diffs={VRAM:0,WRAM:0,SRAM:0},first=[];for(let i=0;i<x.length;i++)if(x[i]!==y[i]){const region=i<32768?'VRAM':i<40960?'WRAM':'SRAM',address=i-(region==='WRAM'?32768:region==='SRAM'?40960:0);diffs[region]++;if(first.length<8)first.push({region,address,baseline:x[i],candidate:y[i]});}result.checkpoints.push({label:a.slice(9,-4),baselineSHA256:sha(x),candidateSHA256:sha(y),differences:diffs,first});}
function events(name){const f=p.join(d,name+'_events.log');return fs.readFileSync(f,'utf8').trim().split(/\r?\n/).filter(Boolean).map(l=>({line:l,t:l.split(/\s+/)}));}
const ea=events('baseline'),eb=events('candidate');
for(const kind of ['C','P','V']){const a=ea.filter(e=>e.t[0]===kind),b=eb.filter(e=>e.t[0]===kind);let first=null,decode=null;
 for(let i=0;i<Math.min(a.length,b.length);i++){
  let x=a[i].t,y=b[i].t;if(kind==='C'){
   const projection=t=>{const strobes=t[8];return[t[1],t[2],t[3],t[4],t[5],t[6],t[7],strobes,strobes[3]==='0'?t[9]:'-',strobes[4]==='0'?t[10]:'-'].join(' ');};
   if(!first&&projection(x)!==projection(y))first={index:i,baseline:a[i].line,candidate:b[i].line};
   if(!decode&&x[3]===y[3]&&x[5]!==y[5])decode={index:i,baseline:a[i].line,candidate:b[i].line};
  }else if(!first&&a[i].line!==b[i].line)first={index:i,baseline:a[i].line,candidate:b[i].line};
 }
 if(!first&&a.length!==b.length)first={index:Math.min(a.length,b.length),baseline:a[Math.min(a.length,b.length)]?.line??null,candidate:b[Math.min(a.length,b.length)]?.line??null};
 result.events[kind]={counts:[a.length,b.length],firstDifference:first,...(kind==='C'?{firstEqualOpcodeDifferentISet:decode}:{})};
}
const pre=result.checkpoints.filter(c=>['saved','before_load'].includes(c.label));result.preLoadControlEqual=pre.length===2&&pre.every(c=>Object.values(c.differences).every(n=>n===0));
fs.writeFileSync(p.join(d,'comparison.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify(result,null,2));
