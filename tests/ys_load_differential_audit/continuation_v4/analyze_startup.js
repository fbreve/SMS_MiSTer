const fs=require('fs'),p=require('path'),crypto=require('crypto');
const d=__dirname,identity=JSON.parse(fs.readFileSync(p.join(d,'rom_owner_results.json'))).results[0];
const rom=fs.readFileSync(identity.path),word=a=>rom.readUInt16LE(a);
// Focused diagnostics only. No cartridge bytes or disassembly are exported.
const result={ROM_SHA256:crypto.createHash('sha256').update(rom).digest('hex'),waitLoop:{loadAt:'0046',loadAbsolute:rom[0x46]===0x3a,address:word(0x47).toString(16),testAAt0049:rom[0x49]===0xb7,branchNZAt004a:rom[0x4a]===0x20,branchTarget:(0x4c+(rom[0x4b]<<24>>24)).toString(16)},inputReadCandidates:[],checkpointObservations:[]};
for(let i=0;i<rom.length-1;i++)if(rom[i]===0xdb&&rom[i+1]===0xdc)result.inputReadCandidates.push(i.toString(16));
result.inputBufferEvidence={readAt0773:rom[0x773]===0xdb&&rom[0x774]===0xdc,HLBufferAddress:rom[0x775]===0x21?word(0x776).toString(16):null,heldStoreAt077d:rom[0x77d]===0x70,edgeStoreAt0780:rom[0x780]===0x77};
for(const [dir,prefix]of[['../continuation_v3','baseline'],['.','discovery']])for(const frame of [1,5,10,30,60,90,120,150,180,210,240]){
 const f=p.join(d,dir,`${prefix}_boot${frame}.mem`);if(!fs.existsSync(f))continue;
 const b=fs.readFileSync(f);result.checkpointObservations.push({source:dir,frame,heldC01b:b[32768+0x1b],edgeC01c:b[32768+0x1c],waitC021:b[32768+0x21]});
}
result.limits='Static pattern checks identify candidate routine semantics, not general control-flow proof. Runtime C01B=16 after the Fire1 pulse is corroborating evidence of delivered input. No first-screen or causality PASS follows from these observations.';
fs.writeFileSync(p.join(d,'startup_analysis.json'),JSON.stringify(result,null,2)+'\n');
console.log(JSON.stringify(result,null,2));
