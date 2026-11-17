const fs=require('fs'),p=require('path'),crypto=require('crypto');const d=__dirname;
const path=process.argv[2]||'\\\\mister\\sdcard\\savestates\\SMS\\Ys - The Vanished Omens - FM Sound Restoration (USA, Europe) v1.2_4.ss';
const bytes=fs.readFileSync(path),sha=crypto.createHash('sha256').update(bytes).digest('hex');
const word=n=>bytes.readBigUInt64LE(n*8),hex=(n,w=16)=>n.toString(16).padStart(w,'0'),bit=(n,k)=>Number((n>>BigInt(k))&1n);
const headerOffsets=[];for(let off=0;off<Math.min(bytes.length,64);off+=4){const v=bytes.readUInt32LE(off);if(v===0x534d5331||v===0x534d5342)headerOffsets.push(off);}
const result={source:path,bytes:bytes.length,SHA256:sha,magicOffsets:headerOffsets,readOnly:true};
if(headerOffsets.includes(8)&&bytes.length>=0x1c*8){
 const mapper=word(15),video=word(26),cpu=word(2)|(word(3)<<64n)|(word(4)<<128n)|((word(5)&((1n<<38n)-1n))<<192n),vdp=word(6)|(word(7)<<64n);
 Object.assign(result,{control:hex(word(0)),size32:Number(word(0)>>32n),magic:hex(word(1)&0xffffffffn,8),gameID:hex(word(1)>>32n,8),CPU:{PC:Number((cpu>>64n)&65535n),SP:Number((cpu>>48n)&65535n),word5:hex(word(5)),upper26:hex(word(5)>>38n,7)},mapper:{word:hex(mapper),bank0:Number(mapper&255n),bank1:Number((mapper>>8n)&255n),bank2:Number((mapper>>16n)&255n),bank3:Number((mapper>>24n)&255n),dahjee:bit(mapper,48),nvram_e:bit(mapper,50),nvram_ex:bit(mapper,51),nvram_p:bit(mapper,52),nvram_cme:bit(mapper,53),bootloader_n:bit(mapper,54)},video:{word:hex(video),tag:hex(video>>40n,6),x:Number((video>>13n)&511n),y:Number((video>>4n)&511n)},VDP:{word:hex(vdp,32),display_on:bit(vdp,7),address:Number((vdp>>70n)&16383n),address_ff:bit(vdp,84)},FMDescriptor:bytes.length>(0x2997+1)*8?hex(word(0x2997)):null});
 result.currentMasterSRAMBytes=(result.mapper.nvram_ex||result.mapper.nvram_p||bit(mapper,61))?32768:result.mapper.nvram_e?16384:(result.mapper.dahjee||result.mapper.nvram_cme)?8192:0;
 result.interchangeAuthorized=false;result.note='Metadata inspection only. ROM ownership and format compatibility must be established before any test LOAD.';
}
fs.writeFileSync(p.join(d,'hardware_state_metadata.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify(result,null,2));
