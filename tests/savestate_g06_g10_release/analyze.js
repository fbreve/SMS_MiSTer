const fs=require('fs'),p=require('path'),crypto=require('crypto'),cp=require('child_process');const dir=__dirname,root=p.resolve(dir,'../..');
const read=f=>fs.readFileSync(p.join(dir,f),'utf8'),hash=s=>crypto.createHash('sha256').update(s).digest('hex');
function rows(folder){const text=read(folder+'/timeline.csv').trim().split(/\r?\n/),keys=text.shift().split(',');return text.map(s=>s.split(',')).filter(a=>a.length===keys.length).map(a=>Object.fromEntries(a.map((v,i)=>[keys[i],v])));}
const fields=['clkd','ce_cpu','ce_vdp','ce_pix','ce_sp','cpu_tick','MC','TS','restart','M1','MREQ','RD','IORQ','bus_A','acc','ram','x','y','sprites','vdp'];
const short=r=>r&&Object.fromEntries(['cycle',...fields,'status_request','status_sample','freeze','logical_freeze'].map(k=>[k,r[k]]));
const bit=(r,n)=>Number((BigInt('0x'+r.vdp)>>BigInt(n))&1n);
const names=fs.readdirSync(dir).filter(f=>fs.existsSync(p.join(dir,f,'timeline.csv')));const result={head:cp.execFileSync('git',['rev-parse','HEAD'],{cwd:root,encoding:'utf8'}).trim(),format:13,cases:{}};
const data={};for(const name of names){
 const a=rows(name),log=read(name+'/simulation.log');data[name]=a;
 const arm=[...log.matchAll(/DIVIDER_ARM cycle(\d+) clkd(\d+) ce(\d+) save([01])/g)].map(m=>({cycle:+m[1],phase:+m[2],ce:m[3],save:+m[4]}));
 const release=[...log.matchAll(/DIVIDER_RELEASE cycle(\d+) clkd(\d+) ce(\d+) save([01])/g)].map(m=>({cycle:+m[1],phase:+m[2],ce:m[3],save:+m[4]}));
 const ref=name.startsWith('reference_'),start=ref?arm[0]?.cycle:release.at(-1)?.cycle;
 const suffix=a.filter(r=>+r.cycle>=(start??1e99)&&r.logical_freeze==='0');
 const event=(k,v)=>suffix.filter((r,i)=>r[k]===v&&(i===0||suffix[i-1][k]!==v));
 const firstDistance=k=>suffix.find(r=>r[k]==='1')?+suffix.find(r=>r[k]==='1').cycle-start:null;
 const status=event('status_request','1').map(short),samples=suffix.filter(r=>r.status_sample==='1').map(short);
 const image=p.join(dir,name,'image.hex');
 result.cases[name]={complete:/PASS UNINTERRUPTED|DONE SAVE_ONLY|DONE VDP/.test(log),errors:/\*\* (Fatal|Error|Failure)|Errors: [1-9]/.test(log),rows:a.length,arm,release,restore:a.filter(r=>r.state==='33').map(short),firstDistances:Object.fromEntries(['ce_cpu','cpu_tick','ce_vdp','ce_pix','ce_sp'].map(k=>[k,firstDistance(k)])),firstClocks:suffix.slice(0,32).map(short),statusRequests:status,statusSamples:samples,firstAccChanges:event('acc','3f').map(short),image:fs.existsSync(image)?{words:read(name+'/image.hex').trim().split(/\r?\n/).length,sha256:hash(fs.readFileSync(image)),known:!/[xz]/i.test(read(name+'/image.hex'))}:null,logSha256:hash(fs.readFileSync(p.join(dir,name,'simulation.log')))};
}
for(const candidate of ['common_t1','forced_common_t1'])if(result.cases[candidate]?.release.length===2&&result.cases.reference_t1?.complete){
 const ref=data.reference_t1,dut=data[candidate],r0=result.cases.reference_t1.arm[0].cycle+1,d0=result.cases[candidate].release.at(-1).cycle+1;
 const lookup=new Map(ref.map(r=>[+r.cycle-r0,r]));const pairs=dut.filter(r=>+r.cycle>=d0).map(r=>[lookup.get(+r.cycle-d0),r]).filter(([r])=>r);
 const key=candidate==='common_t1'?'commonPhase':'forcedCommonPhase';
 result[key]={referenceStart:r0,loadStart:d0,clocks:pairs.length,differences:Object.fromEntries(fields.map(k=>{const d=pairs.filter(([a,b])=>a[k].toLowerCase()!==b[k].toLowerCase());return[k,{count:d.length,first:d[0]?{reference:short(d[0][0]),loaded:short(d[0][1])}:null}];}))};
 const normalized=data[candidate].find((r,i,a)=>+r.cycle>d0&&r.restart==='0'&&a[i-1]?.restart==='3');
 result[key].canonicalCpuReached=short(normalized);
}
for(const name of names.filter(n=>n.startsWith('phase'))){
 const c=result.cases[name];if(!c.release.length||!data.reference_t0)continue;
 const ref=data.reference_t0.filter(r=>+r.cycle>=result.cases.reference_t0.arm[0].cycle);
 const lookup=new Map(ref.filter(r=>['1','11','21'].includes(r.clkd)).map(r=>[r.x+','+r.y,r]));
 const samples=data[name].filter(r=>+r.cycle>c.release.at(-1).cycle&&r.logical_freeze==='0'&&['1','11','21'].includes(r.clkd));
 const pairs=samples.map(r=>[lookup.get(r.x+','+r.y),r]).filter(([r])=>r);
 c.pixelComparison={compared:pairs.length,differences:Object.fromEntries(['acc','ram','vdp','sprites'].map(k=>{const d=pairs.filter(([a,b])=>a[k].toLowerCase()!==b[k].toLowerCase());return[k,{count:d.length,first:d[0]?{reference:short(d[0][0]),saved:short(d[0][1])}:null}];})),statusBits:Object.fromEntries([103,117,118,119].map(n=>[n,pairs.filter(([a,b])=>bit(a,n)!==bit(b,n)).length]))};
}
const b=JSON.parse(read('baseline.json'));result.baselineChanged=Object.entries(b.hashes).filter(([f,h])=>hash(fs.readFileSync(p.join(root,f)))!==h).map(([f])=>f);
const phaseNames=names.filter(n=>n.startsWith('phase')&&result.cases[n].complete&&result.cases[n].image);
result.sameImageTransportPair=phaseNames.length?{cases:phaseNames,words:12288,byteIdentical:phaseNames.every(n=>read(n+'/image.hex')===read(phaseNames[0]+'/image.hex')),sha256:result.cases[phaseNames[0]].image.sha256,note:'Positive pair is SAVE-only release, not two LOADs. Same historical capture phase25; external DDR timing selects different future legal release phases.'}:null;
result.git={stat:cp.execFileSync('git',['diff','--stat'],{cwd:root,encoding:'utf8'}),staged:cp.execFileSync('git',['diff','--cached','--stat'],{cwd:root,encoding:'utf8'}),status:cp.execFileSync('git',['status','--short'],{cwd:root,encoding:'utf8'})};
fs.writeFileSync(p.join(dir,'results.json'),JSON.stringify(result,null,2)+'\n');
console.log(JSON.stringify(Object.fromEntries(Object.entries(result.cases).map(([k,v])=>[k,{complete:v.complete,errors:v.errors,release:v.release,firstDistances:v.firstDistances,status:v.statusRequests.slice(0,6).map(r=>({x:r.x,y:r.y,acc:r.acc,ram:r.ram})),pixel:v.pixelComparison&&Object.fromEntries(Object.entries(v.pixelComparison.differences).map(([f,d])=>[f,d.count])),image:v.image}])),null,2));
for(const key of ['commonPhase','forcedCommonPhase'])if(result[key])console.log(JSON.stringify({control:key,clocks:result[key].clocks,differences:Object.fromEntries(Object.entries(result[key].differences).map(([k,v])=>[k,v.count])),canonicalCpu:result[key].canonicalCpuReached},null,2));
if(process.argv.includes('--final')){
 if(result.baselineChanged.length||result.git.stat||result.git.staged)throw Error('Production/index changed');
 for(const c of Object.values(result.cases))if(!c.complete||c.errors)throw Error('incomplete/error runtime');
 if(!result.sameImageTransportPair?.byteIdentical||phaseNames.some(n=>!result.cases[n].image.known||result.cases[n].image.words!==12288))throw Error('complete known equal images missing');
 const phases=new Set(phaseNames.map(n=>result.cases[n].release.at(-1).phase));if([21,23,27,29].some(n=>!phases.has(n)))throw Error('compatible phase coverage missing');
 for(const n of phaseNames){const c=result.cases[n],d=c.pixelComparison.differences,phase=c.release.at(-1).phase;if(d.sprites.count)throw Error('sprite source differs');if(phase<25&&(!d.acc.count||!d.ram.count))throw Error('early phase guest failure missing');if(phase>25&&(d.acc.count||d.ram.count||d.vdp.count))throw Error('late phase common oracle failed');}
 const f=result.forcedCommonPhase;if(!f||['clkd','ce_cpu','ce_vdp','ce_pix','ce_sp','cpu_tick','x','y','sprites'].some(k=>f.differences[k].count)||!f.differences.TS.count||!f.differences.acc.count||!f.differences.ram.count)throw Error('full common phase separation missing');
 console.log('PASS investigation evidence gates; confirmed divergences retained, no production fix.');
}
