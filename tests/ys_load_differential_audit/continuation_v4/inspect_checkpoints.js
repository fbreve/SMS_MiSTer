const fs=require('fs'),p=require('path'),crypto=require('crypto');const d=__dirname;
const hash=b=>crypto.createHash('sha256').update(b).digest('hex');
const log=fs.readFileSync(p.join(d,'discovery_running.log'),'utf8');
const result={purpose:'Cold startup qualification, not a SAVE/LOAD corruption comparison',SRAMInitialization:'FF at all32768 bytes, matching pinned master SMS.sv nvram_ff.mif',checkpoints:[]};
for(const f of fs.readdirSync(d).filter(f=>/^discovery_boot\d+\.mem$/.test(f)).sort((a,b)=>+a.match(/boot(\d+)/)[1]-+b.match(/boot(\d+)/)[1])){
 const bytes=fs.readFileSync(p.join(d,f));if(bytes.length!==73728)continue;
 const label=f.match(/_(boot\d+)/)[1],line=log.split(/\r?\n/).find(l=>l.includes('CHECKPOINT '+label+' '));
 const map=line?.match(/MAP=([0-9a-f]+)/i),mapper=map?BigInt('0x'+map[1]):null;
 const banks=[];for(let k=0;k<2;k++){const b=bytes.subarray(40960+k*16384,40960+(k+1)*16384);banks.push({bank:k,bytes:b.length,SHA256:hash(b),nonFF:b.reduce((s,v)=>s+(v!==255),0),nonzero:b.reduce((s,v)=>s+(v!==0),0)});}
 const wram=bytes.subarray(32768,40960);
 result.checkpoints.push({label,mapperWord:map?.[1],nvram_e:mapper===null?null:Number((mapper>>50n)&1n),nvram_ex:mapper===null?null:Number((mapper>>51n)&1n),nvram_p:mapper===null?null:Number((mapper>>52n)&1n),SRAM_SHA256:hash(bytes.subarray(40960)),banks,heldC01b:wram[0x1b],edgeC01c:wram[0x1c]});
}
fs.writeFileSync(p.join(d,'checkpoint_inspection.json'),JSON.stringify(result,null,2)+'\n');
console.log('Recorded',result.checkpoints.length,'complete startup checkpoints, both physical SRAM banks included.');
