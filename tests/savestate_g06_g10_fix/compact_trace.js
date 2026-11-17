// Preserve the complete baseline trace losslessly before compacting wait rows.
const fs=require('fs'),p=require('path'),z=require('zlib'),rl=require('readline'),crypto=require('crypto'),{pipeline}=require('stream/promises');
(async()=>{for(const name of ['phase23','phase27','equalphase']){
 const d=p.join(__dirname,'baseline_phase',name),f=p.join(d,'timeline.csv'),gz=f+'.full.gz',tmp=f+'.compact';if(fs.existsSync(gz))continue;
 const log=fs.readFileSync(p.join(d,'simulation.log'),'utf8');if(!/DONE (?:VDP|SAVE_ONLY)/.test(log))throw Error('Incomplete baseline '+name);
 const release=[...log.matchAll(/DIVIDER_RELEASE cycle(\d+)/g)].map(m=>+m[1]);
 const digest=crypto.createHash('sha256');for await(const b of fs.createReadStream(f))digest.update(b);
 await pipeline(fs.createReadStream(f),z.createGzip(),fs.createWriteStream(gz));
 const out=fs.createWriteStream(tmp);let total=0,kept=0;
 for await(const line of rl.createInterface({input:fs.createReadStream(f),crlfDelay:Infinity})){
  total++;let keep=total===1;if(!keep){const a=line.split(','),next=release.find(t=>t>=+a[0]);keep=a[9]!=='34'||next===undefined||+a[0]>=next-16;}
  if(keep){kept++;if(!out.write(line+'\n'))await new Promise(resolve=>out.once('drain',resolve));}
 }
 await new Promise(resolve=>out.end(resolve));fs.renameSync(tmp,f);
 fs.writeFileSync(p.join(d,'trace_archive.json'),JSON.stringify({originalSha256:digest.digest('hex'),originalRows:total-1,retainedRows:kept-1,archive:'timeline.csv.full.gz',rule:'All guest/restore clocks; state34 wait retains last16 before release; full original archived losslessly'},null,2)+'\n');
 console.log(name+': '+total+' -> '+kept);
}})().catch(e=>{console.error(e);process.exitCode=1;});
