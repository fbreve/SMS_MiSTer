const fs=require('fs'),p=require('path'),rl=require('readline');const d=__dirname;
(async()=>{
 const result={scope:'Partial trace diagnostic while native trials run; not a graphics PASS',runs:[]};
 for(const name of ['e_baseline','e_sram','e_context','e_sham']){
  const file=p.join(d,name+'_events.log'),loadedFile=p.join(d,name+'_loaded.mem');if(!fs.existsSync(loadedFile))continue;
  const saved=fs.readFileSync(p.join(d,name+'_saved.mem')).subarray(40960),loaded=fs.readFileSync(loadedFile).subarray(40960),size=fs.statSync(file).size;
  const stream=fs.createReadStream(file,{end:Math.max(0,size-1)}),reader=rl.createInterface({input:stream,crlfDelay:Infinity}),written=new Set();
  let lineNumber=0,reads=0,firstWrong=null,firstWrongCache=null;
  for await(const line of reader){lineNumber++;const t=line.split(' ');if(t[0]!=='N'||t.length<11)continue;
   const a=parseInt(t[4],16);if(t[9]==='10'&&t[8]==='3')written.add(a);
   if(t[9]!=='01'||t[8]!=='2')continue;reads++;
   const data=parseInt(t[5],16);if(!written.has(a)&&data!==saved[a]){
    const q={sourceLine:lineNumber,trace:line,physicalAddress:a.toString(16),data,requiredAtSAVE:saved[a],physicalAtLOAD:loaded[a]};
    firstWrong??=q;if(a>=0x400&&a<0x800)firstWrongCache??=q;
   }
   if(firstWrong&&firstWrongCache)break;
  }
  reader.close();stream.destroy();result.runs.push({name,sourceBytesObserved:size,readsObserved:reads,firstWrong,firstWrongCache});
 }
 fs.writeFileSync(p.join(d,'early_sram_reads.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify(result,null,2));
})().catch(e=>{console.error(e);process.exitCode=1;});
