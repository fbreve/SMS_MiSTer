// Read-only background preview; not a LOAD and not an emulation of VDP pipelines/sprites.
const fs=require('fs'),p=require('path'),crypto=require('crypto');
const source=String.raw`\\mister\sdcard\savestates\SMS\Ys - The Vanished Omens - FM Sound Restoration (USA, Europe) v1.2_4.ss`;
const b=fs.readFileSync(source),word=n=>b.readBigUInt64LE(n*8);
const state=word(6)|(word(7)<<64n),field=(lo,n)=>Number((state>>BigInt(lo))&((1n<<BigInt(n))-1n));
const vram=b.subarray(0x101*8,0x901*8),cram=b.subarray(8*8,14*8),base=(field(13,4)&14)*1024;
const pixels=Buffer.alloc(256*192*3),rgb=[];
let palette=0n;for(let i=0;i<cram.length;i++)palette|=BigInt(cram[i])<<BigInt(i*8);
for(let i=0;i<32;i++){let v=Number((palette>>BigInt(i*12))&4095n);rgb.push([(v&15)*17,((v>>4)&15)*17,((v>>8)&15)*17]);}
for(let y=0;y<192;y++)for(let x=0;x<256;x++){
 let sx=(x-((field(0,1)&&y<16)?0:field(28,8))+256)%256;
 let sy=(y+((field(1,1)&&x>=192)?0:field(36,8)))%224;
 let name=base+((sy>>3)*32+(sx>>3))*2,attr=vram[name]|(vram[name+1]<<8);
 let tx=sx&7,ty=sy&7;if(attr&512)tx=7-tx;if(attr&1024)ty=7-ty;
 let a=(attr&511)*32+ty*4,index=0;for(let plane=0;plane<4;plane++)index|=((vram[a+plane]>>(7-tx))&1)<<plane;
 if(attr&2048)index+=16;
 const c=rgb[index];for(let k=0;k<3;k++)pixels[(y*256+x)*3+k]=c[k];
}
fs.writeFileSync(p.join(__dirname,'hardware_background.ppm'),Buffer.concat([Buffer.from('P6\n256 192\n255\n'),pixels]));
fs.writeFileSync(p.join(__dirname,'hardware_background_metadata.json'),JSON.stringify({sourceSHA256:crypto.createHash('sha256').update(b).digest('hex'),mode4:field(5,1),display:field(7,1),base,scrollX:field(28,8),scrollY:field(36,8),limitations:'Static background only. No sprite, masking, border, scanline latch or VDP pipeline emulation. SRAM tail is not imported.'},null,2)+'\n');
