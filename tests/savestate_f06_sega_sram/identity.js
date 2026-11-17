// Finite collision witness for the actual two 32-bit ROM signatures. No ROM
// database or game-file assumptions; bytewise affine maps are solved over GF(2).
const fs=require('fs'),crypto=require('crypto'),d=__dirname;
function signatures(bytes){let roll=0x811c9dc5,crc=0xffffffff;for(let a=0;a<bytes.length;a++){
 roll=(((roll<<1)|(roll>>>31))^bytes[a]^(((a&1)<<2)|(((a>>>8)&1)<<1)|((a>>>16)&1)))>>>0;
 crc=(crc^bytes[a])>>>0;for(let b=0;b<8;b++)crc=((crc>>>1)^((crc&1)?0xedb88320:0))>>>0;
}return (BigInt(roll)<<32n)|BigInt((crc^0xffffffff)>>>0);}
const a=Buffer.from(Array.from({length:32768},(_,i)=>(i*73+(i>>>5))&255));
const origin=signatures(a),basis=new Map();let solution;
for(let i=0;i<96&&!solution;i++){
 let b=Buffer.from(a);b[128+(i>>>3)]^=1<<(i&7);let v=signatures(b)^origin,mask=1n<<BigInt(i);
 for(let bit=63;bit>=0;bit--){if(!(v&(1n<<BigInt(bit))))continue;let old=basis.get(bit);if(old){v^=old.v;mask^=old.mask;}else{basis.set(bit,{v,mask});break;}}
 if(v===0n)solution=mask;
}
if(!solution)throw Error('no collision');const b=Buffer.from(a),changes=[];
for(let i=0;i<96;i++)if(solution&(1n<<BigInt(i))){b[128+(i>>>3)]^=1<<(i&7);changes.push(i);}
if(a.equals(b)||signatures(a)!==signatures(b))throw Error('invalid collision');
fs.writeFileSync(d+'/identity_a.bin',a);fs.writeFileSync(d+'/identity_b.bin',b);
const sha=b=>crypto.createHash('sha256').update(b).digest('hex');
fs.writeFileSync(d+'/identity.json',JSON.stringify({bytes:a.length,signature:'0x'+(origin>>32n).toString(16),crc32:'0x'+(origin&0xffffffffn).toString(16),shaA:sha(a),shaB:sha(b),changedBits:changes,meaning:'Both current ROM signatures collide for two same-length different byte streams; neither signal labels the retained SRAM owner.'},null,2));
console.log('PASS distinct full ROM byte streams, identical rolling signature and CRC32');
