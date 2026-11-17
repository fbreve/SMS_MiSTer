const fs=require('fs'),p=require('path'),rl=require('readline'),crypto=require('crypto'),{once}=require('events');
const d=__dirname,sha=b=>crypto.createHash('sha256').update(b).digest('hex');
const prefix=process.argv[2]||'',names=['baseline','sram','reference','context','sham'].map(n=>prefix+n);
const externalROM=fs.readFileSync(JSON.parse(fs.readFileSync(p.join(d,'../rom_owner_results.json'))).results[0].path);
function memoryDiff(a,b){const result={};for(const [region,start,end]of[['VRAM',0,32768],['WRAM',32768,40960],['SRAM',40960,73728]]){let count=0,first=[];for(let i=start;i<end;i++)if(a[i]!==b[i]){count++;if(first.length<8)first.push({address:(i-start).toString(16),a:a[i],b:b[i]});}result[region]={count,first};}return result;}
function pixelsDiff(a,b){const header=x=>{const m=x.toString('ascii',0,64).match(/^P6\s+256 192\s+255\n/);if(!m)throw Error('bad PPM');return m[0].length;};const aa=header(a),bb=header(b);let map=0,hud=0,bounds={minX:256,maxX:-1,minY:192,maxY:-1};for(let i=0;i<49152;i++)if(a[aa+i*3]!==b[bb+i*3]||a[aa+i*3+1]!==b[bb+i*3+1]||a[aa+i*3+2]!==b[bb+i*3+2]){const y=i>>8,x=i&255;if(y<160){map++;bounds.minX=Math.min(bounds.minX,x);bounds.maxX=Math.max(bounds.maxX,x);bounds.minY=Math.min(bounds.minY,y);bounds.maxY=Math.max(bounds.maxY,y);}else hud++;}return{mapPixels:map,HUDPixels:hud,mapBounds:map?bounds:null};}
function checkpoints(name){const text=fs.readFileSync(p.join(d,name+'_map.log'),'utf8');return{text,completed:text.includes('COMPLETE movement sequence')&&!/\*\* (Fatal|Error)/.test(text),records:[...text.matchAll(/CHECKPOINT (\w+) cycle=(\d+) frame=(\d+) VRAM=(\w+) WRAM=(\w+) SRAM=(\w+) MAP=(\w+) VDP=(\w+) CPU=(\w+)(?: CRAM=(\w+) IO=(\w+) VIDEO=(\w+) PROBE=(\w+))?/g)].map(m=>({label:m[1],cycle:m[2],frame:+m[3],VRAM:m[4],WRAM:m[5],SRAM:m[6],mapper:m[7],VDP:m[8],CPU:m[9],CRAM:m[10],IO:m[11],video:m[12],probe:m[13]}))};}
async function normalize(name){
 const file=p.join(d,name+'_events.log'),dir=p.join(d,name+'_canonical');fs.mkdirSync(dir,{recursive:true});
 const stat=fs.statSync(file),summary=p.join(dir,'summary.json');
 if(fs.existsSync(summary)){const cached=JSON.parse(fs.readFileSync(summary));if(cached.version===2&&cached.sourceBytes===stat.size&&cached.sourceMtimeMs===stat.mtimeMs)return cached;}
 const kinds=['F','N','P','Q','V','E','G','W','M','T'],writers={},counts={},last={};for(const k of kinds){writers[k]=fs.createWriteStream(p.join(dir,k+'.log'));counts[k]=0;}
 const isReference=name.endsWith('reference'),snapshot=p.join(d,name+(isReference?'_saved.mem':'_loaded.mem'));
 const initial=fs.readFileSync(snapshot),vram=Buffer.from(initial.subarray(0,32768));
 const saved=fs.readFileSync(p.join(d,name+'_saved.mem')).subarray(40960),loaded=initial.subarray(40960),written=new Set();
 const log=fs.readFileSync(p.join(d,name+'_map.log'),'utf8'),accept=log.match(/ACCEPT stage=1 save=1[^\r\n]+/);
 const savedPC=accept?parseInt(accept[0].match(/PC=(\w+)/)[1],16):null;
 const replayAllowed=!isReference&&!!accept&&/CTX=0 .*MC=1 TS=2/.test(accept[0])&&savedPC<1024;
 let firstUnrestoredRead=null,lineNumber=0,firstFetch=true,replayedFetch=null;
 async function emit(kind,key,line){if((kind==='V'||kind==='T')&&last[kind]===key)return;last[kind]=key;counts[kind]++;if(!writers[kind].write(key+'\t'+lineNumber+'\t'+line+'\n'))await once(writers[kind],'drain');}
 const input=rl.createInterface({input:fs.createReadStream(file),crlfDelay:Infinity});
 for await(const line of input){lineNumber++;const t=line.split(' '),kind=t[0];
  if(kind==='C'&&t[6]==='1'&&t[7]==='2'&&t[8][0]==='0'&&t[8][1]==='0'){
   // SAVE accepted the original opcode fetch at T2; LOAD must replay that fetch.
   // Normalize only a verified ordinary-context replay with the correct ROM byte.
   const replay=firstFetch&&replayAllowed&&parseInt(t[2],16)===savedPC&&parseInt(t[9],16)===externalROM[savedPC]&&t[4]==='0'&&t[5]==='0';
   if(replay)replayedFetch={lineNumber,line,savedPC:savedPC.toString(16),expectedOpcode:externalROM[savedPC],reason:'Original fetch was accepted at SAVE T2 and therefore precedes the reference post-SAVE trace. Opcode and ordinary context independently checked.'};
   else await emit('F',[t[2],t[9],t[4],t[5]].join(' '),line);
   firstFetch=false;
  }
  if(kind==='N'){
   const direction=t[9],read=direction==='01'&&t[8]==='2',write=direction==='10'&&t[8]==='3';
   if(read||write){const address=parseInt(t[4],16),data=parseInt(t[read?5:6],16);await emit('N',[read?'R':'W',t[2],t[3],t[4],t[read?5:6]].join(' '),line);
    if(read&&!written.has(address)&&data!==saved[address]&&!firstUnrestoredRead)firstUnrestoredRead={lineNumber,line,physicalAddress:address.toString(16),readData:data,requiredAtSAVE:saved[address],physicalAtLOAD:loaded[address]};
    if(write)written.add(address);
   }
  }
  if(kind==='P'){await emit('P',[(parseInt(t[2],16)&255).toString(16),t[3]].join(' '),line);await emit('Q',t.slice(4,7).join(' '),line);}
  if(kind==='V'){const a=parseInt(t[2],16),v=parseInt(t[3],16);await emit('V',t[2]+' '+t[3],line);if(vram[a]!==v){await emit('E',t[2]+' '+t[3],line);if(a>=0x3800&&a<0x3d00)await emit('G',t[2]+' '+t[3],line);}vram[a]=v;}
  if(kind==='W')await emit('W',t[3]+' '+t[4],line);
  if(kind==='M')await emit('M',t[2],line);
  if(kind==='T')await emit('T',t[2],line);
 }
 await Promise.all(kinds.map(k=>new Promise(resolve=>writers[k].end(resolve))));
 const result={version:2,sourceBytes:stat.size,sourceMtimeMs:stat.mtimeMs,counts,replayedFetch,firstUnrestoredRead,sourceSHA256:sha(fs.readFileSync(file))};
 fs.writeFileSync(summary,JSON.stringify(result,null,2)+'\n');return result;
}
async function firstDifference(a,b,kind){
 const inputs=[a,b].map(n=>{const stream=fs.createReadStream(p.join(d,n+'_canonical',kind+'.log'));return{stream,reader:rl.createInterface({input:stream,crlfDelay:Infinity})};});
 const it=inputs.map(o=>o.reader[Symbol.asyncIterator]());let index=0,result=null;
 while(true){const next=await Promise.all(it.map(i=>i.next()));if(next.every(q=>q.done))break;const records=next.map(q=>q.done?null:q.value.split('\t'));
  if(records.some(q=>q===null)||records[0][0]!==records[1][0]){result={index,a:records[0]?{key:records[0][0],sourceLine:+records[0][1],trace:records[0][2]}:null,b:records[1]?{key:records[1][0],sourceLine:+records[1][1],trace:records[1][2]}:null};break;}index++;
 }
 for(const o of inputs){o.reader.close();o.stream.destroy();}return result;
}
(async()=>{
 const result={status:'Analysis only: visual map qualification and causal interpretation still required',runs:{},comparisons:{}};
 for(const name of names){const log=p.join(d,name+'_map.log');if(!fs.existsSync(log))continue;const c=checkpoints(name);result.runs[name]={completed:c.completed,accepts:c.text.match(/ACCEPT[^\r\n]+/g),saveMetadata:c.text.match(/SAVE_METADATA[^\r\n]+/g),loadChecks:c.text.match(/LOAD_CHECK[^\r\n]+/g),checkpoints:c.records};if(c.completed)result.runs[name].events=await normalize(name);}
 for(const [a,b]of[['baseline','reference'],['sram','reference'],['context','baseline'],['sham','baseline'],['sham','sram']].map(pair=>pair.map(n=>prefix+n))){
  if(!result.runs[a]?.completed||!result.runs[b]?.completed)continue;
  const q={checkpoints:[],events:{}};
  for(const record of result.runs[a].checkpoints){const label=record.label;if(!result.runs[b].checkpoints.some(r=>r.label===label))continue;
   const ma=fs.readFileSync(p.join(d,a+'_'+label+'.mem')),mb=fs.readFileSync(p.join(d,b+'_'+label+'.mem'));
   const ia=p.join(d,a+'_'+label+'.ppm'),ib=p.join(d,b+'_'+label+'.ppm');
   q.checkpoints.push({label,memory:memoryDiff(ma,mb),pixels:fs.existsSync(ia)&&fs.existsSync(ib)?pixelsDiff(fs.readFileSync(ia),fs.readFileSync(ib)):null});
  }
  for(const k of ['F','N','P','Q','V','E','G','W','M','T'])q.events[k]=await firstDifference(a,b,k);
  result.comparisons[a+'_vs_'+b]=q;
 }
 fs.writeFileSync(p.join(d,prefix+'map_comparison.json'),JSON.stringify(result,null,2)+'\n');console.log('Recorded',Object.keys(result.runs).length,'runs and',Object.keys(result.comparisons).length,'completed comparisons. This script does not declare graphics PASS.');
})().catch(e=>{console.error(e);process.exitCode=1;});
