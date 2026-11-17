const fs=require('fs'),p=require('path'),crypto=require('crypto'),assert=require('assert'),d=__dirname;
function image(name){let cursor=0,mem=Array(12288);for(const line of fs.readFileSync(p.join(d,name,'image_save.hex'),'utf8').split(/\r?\n/)){
 const s=line.replace(/\/\/.*$/,'').trim();if(!s)continue;for(const tok of s.split(/\s+/)){if(tok.startsWith('@'))cursor=parseInt(tok.slice(1),16);else{assert(/^[0-9a-f]{1,16}$/i.test(tok),name+' unknown word');mem[cursor++]=BigInt('0x'+tok);}}
 }assert(mem.length===12288&&mem.every(x=>typeof x==='bigint'));const b=Buffer.alloc(98304);mem.forEach((x,i)=>b.writeBigUInt64LE(x,i*8));return {mem,bytes:b,sha256:crypto.createHash('sha256').update(b).digest('hex')};}
const a=image('current_case0_final'),b=image('pair_b'),ca=image('converge_a'),cb=image('converge_b');
const diff=[];for(let i=0;i<12288;i++)if(a.mem[i]!==b.mem[i])diff.push({word:i.toString(16),a:a.mem[i].toString(16),b:b.mem[i].toString(16)});
assert(diff.length>0,'Original information collision was not separated');
assert(ca.bytes.equals(cb.bytes),'Convergent natural histories do not have equal images');
const ar=fs.readFileSync(p.join(d,'current_case0_final/reference.dat'),'utf8').trim().split(/\r?\n/),br=fs.readFileSync(p.join(d,'pair_b/reference.dat'),'utf8').trim().split(/\r?\n/);
assert(ar.length===20000&&br.length===20000);let differences=0;for(let i=0;i<20000;i++)if(ar[i].split(/\s+/).at(-1)!==br[i].split(/\s+/).at(-1))differences++;
assert(differences>0,'Original natural histories lost FM contrast');
const car=fs.readFileSync(p.join(d,'converge_a/reference.dat'),'utf8'),cbr=fs.readFileSync(p.join(d,'converge_b/reference.dat'),'utf8');assert(car===cbr,'Equal current images have different reference futures');
const out={original:{oldCompleteV16SHA256:'85e45a86cf942106d12432cdd8a5a6837d65698a7a891e3f9d81efda8f4aa617',currentA:a.sha256,currentB:b.sha256,wordsDiffering:diff,rawFutureDifferences:differences,samples:20000},convergentSearch:{a:ca.sha256,b:cb.sha256,bytes:98304,equalCompleteImages:true,equalReferenceFuture:true,explicitlyDifferingOmittedStateAtCapture:false,limitation:'Earlier guest histories differ; this finite convergent pair does not establish that a pure cache or rm differs at capture. Structural exclusion proofs and the72-phase receiver replay complement this search.'}};
fs.writeFileSync(p.join(d,'pairs.json'),JSON.stringify(out,null,2));for(const[n,v]of[['pair_a',a],['pair_b',b],['converge_a',ca],['converge_b',cb]])fs.writeFileSync(p.join(d,n+'.bin'),v.bytes);
console.log({originalDifferentWords:diff.length,rawFutureDifferences:differences,convergentEqual:ca.sha256});
