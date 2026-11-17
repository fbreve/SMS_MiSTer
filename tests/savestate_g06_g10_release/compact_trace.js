// Keep all guest clocks and the last 16 frozen clocks before each release.
// Archive the untouched long raw-video alignment wait losslessly first.
const fs=require('fs'),p=require('path'),zlib=require('zlib'),readline=require('readline'),{pipeline}=require('stream/promises'),crypto=require('crypto');
const dir=__dirname;
(async()=>{for(const name of process.argv.slice(2)){
 const folder=p.join(dir,name),file=p.join(folder,'timeline.csv'),archive=file+'.full.gz',tmp=file+'.compact';
 const log=fs.readFileSync(p.join(folder,'simulation.log'),'utf8');
 if(!/DONE VDP/.test(log))throw Error('runtime not complete '+name);
 const release=[...log.matchAll(/DIVIDER_RELEASE cycle(\d+)/g)].map(m=>+m[1]);
 if(fs.existsSync(archive))throw Error('already compacted '+name);
 const digest=crypto.createHash('sha256');for await(const chunk of fs.createReadStream(file))digest.update(chunk);
 await pipeline(fs.createReadStream(file),zlib.createGzip(),fs.createWriteStream(archive));
 const out=fs.createWriteStream(tmp),lines=readline.createInterface({input:fs.createReadStream(file),crlfDelay:Infinity});
 let total=0,kept=0;
 for await(const line of lines){total++;let keep=total===1;if(!keep){const a=line.split(',');const next=release.find(r=>r>=+a[0]);keep=a[9]!=='34'||next===undefined||+a[0]>=next-16;}if(keep){kept++;if(!out.write(line+'\n'))await new Promise(resolve=>out.once('drain',resolve));}}
 await new Promise(resolve=>out.end(resolve));fs.renameSync(tmp,file);
 fs.writeFileSync(p.join(folder,'trace_archive.json'),JSON.stringify({originalSha256:digest.digest('hex'),originalRows:total-1,retainedRows:kept-1,archive:'timeline.csv.full.gz',rule:'All observed guest/capture/restore clocks; state34 raw-video wait retains last16 clocks before each release. Full original is losslessly archived.'},null,2)+'\n');
 console.log(name+': '+total+' -> '+kept+' lines');
}})().catch(e=>{console.error(e);process.exitCode=1;});
