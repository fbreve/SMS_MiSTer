// Proposed codec only. Not integrated into either production or test DDR FSM.
const fs=require('fs'),cp=require('child_process'),p=require('path'),assert=require('assert'),crypto=require('crypto');
const d=__dirname,root=p.resolve(d,'../../..');
const source=ref=>cp.execFileSync('git',['show',ref+':rtl/savestates.sv'],{cwd:root,encoding:'utf8'});
const master=source('66f16d5c'),fm=source('8cd53ccc');
for(const s of [master,fm]){
 assert(s.includes("{26'd0, z80_snap[229:192]}"));
 assert(s.includes('z80_snap[229:192] <= dout_latch[37:0]'));
}
assert(fm.includes("dout_latch[39:22]!=0"),'FM tag padding check must remain unchanged');
const lowMask=(1n<<38n)-1n,marker=0x4352n;
function encode(low,ctx,nmi){assert(ctx>=0&&ctx<=5);assert(nmi>=0&&nmi<=7);return (marker<<48n)|(1n<<44n)|(BigInt(ctx)<<41n)|(BigInt(nmi)<<38n)|(low&lowMask);}
function decode(word,old64=false){
 if(old64)return{legacy:true};
 if((word>>38n)===0n)return{legacy:true};
 if((word>>48n)!==marker)throw Error('unknown owner');
 if(((word>>44n)&15n)!==1n)throw Error('unknown version');
 const ctx=Number((word>>41n)&7n);if(ctx>5)throw Error('reserved class');
 return{legacy:false,ctx,nmi:Number((word>>38n)&7n),low:word&lowMask};
}
let roundtrips=0;
for(let ctx=0;ctx<6;ctx++)for(let nmi=0;nmi<8;nmi++){
 const low=0x123456789n,w=encode(low,ctx,nmi),v=decode(w);
 assert.deepEqual(v,{legacy:false,ctx,nmi,low});
 assert.equal(w&lowMask,low,'old master/FM reader keeps architectural payload');roundtrips++;
}
const malformed=[encode(0n,0,0)^(1n<<48n),encode(0n,0,0)^(3n<<44n),(marker<<48n)|(1n<<44n)|(6n<<41n),(marker<<48n)|(1n<<44n)|(7n<<41n)];
for(const word of malformed)assert.throws(()=>decode(word));
assert(decode(0n).legacy);assert(decode(0x12345n).legacy);assert(decode(encode(0n,2,4),true).legacy);
const result={status:'PASS codec/static audit only',roundtrips,malformedRejected:malformed.length,proposedLayout:{'63:48':'owner 0x4352 (proposal, not allocated)','47:44':'version 1','43:41':'predecessor class 0..5','40:38':'normalized NMI history','37:0':'unchanged CPU architecture'},legacy:'all-zero upper26 falls back; old64 never interprets extension',oldReader:'master and public FM ignore upper26 and cannot restore new context exactly',FM:'video tag/padding and FM descriptor unchanged',limitation:'No integrated DDR reader/writer implementation or rejection timing validation; owner allocation and broader format interoperability remain review items.'};
fs.writeFileSync(p.join(d,'format_results.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify(result));
