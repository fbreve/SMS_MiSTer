const fs=require('fs'),p=require('path'),d=__dirname,cases=JSON.parse(fs.readFileSync(p.join(d,'targeted.json'))),results=[];
function words(file){return fs.readFileSync(file,'utf8').replace(/\/\/[^\n]*/g,'').trim().split(/\s+/).filter(x=>!x.startsWith('@'));}
for(const fixture of ['campaign','streams'])for(const c of cases){
 const leaf=p.join(d,fixture,c.id),file=p.join(leaf,'image_save.hex');if(!fs.existsSync(file))continue;
 const w=words(file);if(w.length!==12288||w.some(x=>!/^[0-9a-f]{16}$/i.test(x)))throw Error('unknown/incomplete image '+file);
 const actual=Number((BigInt('0x'+w[5])>>41n)&7n),pc=Number(BigInt('0x'+w[3])&65535n);
 if(c.args.CONTEXT!==undefined&&actual!==c.args.CONTEXT)throw Error('wrong saved predecessor class '+c.id);
 const log=fs.readFileSync(p.join(leaf,'replay.log'),'utf8'),traces=[...log.matchAll(/G11_TRACE cycle(\d+).*?prep1 .*?MC1 TS2 A([0-9a-f]+) phys([0-9a-f]+).*?M10 RD0/gi)];
 if(traces.some(m=>parseInt(m[2],16)!==pc||parseInt(m[3],16)!==((c.args.DUAL<3?0x40000:0)+pc)))throw Error('restored logical/physical request differs '+c.id);
 results.push({fixture,id:c.id,savedClass:actual,savedPC:pc.toString(16).padStart(4,'0'),restoredRequestSamples:traces.length,firstPhysical:traces.length?traces[0][3]:null,replayPassed:/PASS MATRIX/.test(log)});
}
fs.writeFileSync(p.join(d,'contexts_result.json'),JSON.stringify(results,null,2)+'\n');console.log(JSON.stringify(results,null,2));
