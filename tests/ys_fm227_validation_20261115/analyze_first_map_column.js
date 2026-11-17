const fs=require('fs'),rl=require('readline');
async function scan(name){
 const map=[],reads=[],ports=[],writes=[];let lineNumber=0;
 const input=rl.createInterface({input:fs.createReadStream(name+'_events.log'),crlfDelay:Infinity});
 for await(const line of input){lineNumber++;const t=line.split(' '),cycle=+t[1];
  if(t[0]==='V'){const address=parseInt(t[2],16);if(address>=0x3800&&address<0x3d00)map.push({lineNumber,cycle,address,data:parseInt(t[3],16),line});}
  if(t[0]==='N'&&cycle>=119000000&&cycle<=120170000)reads.push({lineNumber,line});
  if(t[0]==='P'&&cycle>=120148000&&cycle<=120151000)ports.push({lineNumber,line});
  if(t[0]==='W'&&cycle>=119360000&&cycle<=119362000)writes.push({lineNumber,line});
 }
 return {map,readsNearFirstColumn:reads,wramStagingNearFirstFunctionalDifference:writes,portsNearFirstFunctionalDifference:ports};
}
(async()=>{
 const names=['e_baseline','e_sram','e_reference'],runs={};for(const name of names)runs[name]=await scan(name);
 const comparisons={};
 for(const other of ['e_baseline','e_reference']){
  const a=runs[other].map,b=runs.e_sram.map;let raw=null,functional=null;
  for(let i=0;i<Math.min(a.length,b.length);i++){
   if(!raw&&(a[i].address!==b[i].address||a[i].data!==b[i].data))raw={index:i,other:a[i],sram:b[i]};
   const mask=(a[i].address&1)?0x1f:0xff;
   if(!functional&&(a[i].address!==b[i].address||(a[i].data&mask)!==(b[i].data&mask)))functional={index:i,mask,other:a[i],sram:b[i]};
  }
  comparisons[other+'_vs_sram']={otherWrites:a.length,sramWrites:b.length,firstRaw:raw,firstRenderingRelevant:functional};
 }
 fs.writeFileSync('first_map_column_evidence.json',JSON.stringify({scope:'Mode4 name-table writes; high byte only bits4:0 affect rendering. Full movement completion is assessed separately.',comparisons,runs},null,2));
 console.log(JSON.stringify(comparisons,null,2));
})();
