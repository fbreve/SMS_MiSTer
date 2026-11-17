const fs=require('fs'),p=require('path'),crypto=require('crypto'),d=__dirname;
const sha=b=>crypto.createHash('sha256').update(b).digest('hex'),read=f=>fs.readFileSync(p.join(d,f),'utf8');
const fields=[['tile_index',9],['x',8],['tile_y',3],['palette',1],['palette_shift',1],['priority_latch',1],['flip_x',1],['datac',8],['data0',8],['data1',8],['data2',8],['data3',8],['shift0',8],['shift1',8],['shift2',8],['shift3',8],['text_shift',6],['text_tile_index',8],['text_pattern',8],['text_phase',3],['text_column',6]];
function decode(s,extra){let n=BigInt('0x'+s),remaining=127,out={};for(const[name,width]of fields){remaining-=width;out[name==='x'?'pipeline_x':name]=Number((n>>BigInt(remaining))&((1n<<BigInt(width))-1n));}if(extra){let v=parseInt(extra,16);out.pattern_address=v>>2;out.priority_output=(v>>1)&1;out.observed_ce_pix=v&1;}return out;}
function image(name){const s=read(name+'/image.hex'),words=s.trim().split(/\s+/);if(words.length!==12288||words.some(s=>!/^[0-9a-f]{16}$/i.test(s)))throw Error('not complete known image');let b=Buffer.alloc(98304);words.forEach((s,i)=>b.writeBigUInt64LE(BigInt('0x'+s),8*i));return{words:12288,bytes:98304,hexSha:sha(s),binarySha:sha(b),tag:words[26],phase:words[47],raw:words};}
const captures=[],images=[];
for(const hist of [0,1]){const log=read('baseline/dut_h'+hist+'/simulation.log'),ref=read('baseline/reference_h'+hist+'/reference.dat'),req=log.lastIndexOf('# REQUEST x');
const arm=log.slice(req).match(/# ARM x(\d+) y(\d+) regs([0-9a-f]+) probe[0-9a-f]+ BG([0-9a-f]+) EXTRA([0-9a-f]+) RGB([0-9a-f]+) CE([01])([01])/i);
if(!arm)throw Error('expanded capture missing');
const bg=decode(arm[4],arm[5]);captures.push({history:hist,accepted:log.slice(req).match(/# ACCEPT save1[^\r\n]*/)?.[0],postT:{x:+arm[1],y:+arm[2],vdp:arm[3],rawBG:arm[4],...bg,currentRenderedRGB:arm[6],ce_vdp:+arm[7],ce_pix:+arm[8]},loadResults:[...log.matchAll(/TEXT_HISTORY_RESULT pass(\d+) visiblePixelDiff(\d+) fetchDiff(\d+)/g)].map(m=>({pass:+m[1],pixels:+m[2],audit:+m[3]})),complete:/# End time:/.test(log)&&/PASS RICH V14 VDP/.test(log)&&!/\*\* (Fatal|Error|Failure)/.test(log),sourceLogSha:sha(log),referenceSha:sha(ref)});
let im=image('baseline/dut_h'+hist);images.push(im);
}
const refs=[0,1].map(h=>read('baseline/reference_h'+h+'/reference.dat').trim().split(/\r?\n/).map(l=>l.trim().split(/\s+/)));
let differences={cpu:0,vdp:0,io:0,visibleRGB:0,first:null};for(let i=0;i<refs[0].length;i++){let a=refs[0][i],b=refs[1][i];if(a.some(v=>!/^[0-9a-f]+$/i.test(v))||b.some(v=>!/^[0-9a-f]+$/i.test(v)))throw Error('unknown reference');if(a[7]!==b[7])differences.cpu++;if(a[2]!==b[2])differences.vdp++;if(a[4]!==b[4]||a[10]!==b[10])differences.io++;let x=parseInt(a[0],16),y=parseInt(a[1],16);if(x>0&&x<=256&&y<192&&a[3]!==b[3]){differences.visibleRGB++;if(!differences.first)differences.first={index:i,x,y,rgb0:a[3],rgb1:b[3]};}}
const causal=captures.map((c,i)=>{let bg=c.postT,nibble=(bg.shift0>>7)|((bg.shift1>>7)<<1)|((bg.shift2>>7)<<2)|((bg.shift3>>7)<<3),index=(bg.palette_shift<<4)|nibble;
let cram=0n;for(let j=0;j<6;j++)cram|=BigInt('0x'+images[i].raw[8+j])<<BigInt(64*j);let rgb=Number((cram>>BigInt(index*12))&4095n).toString(16).padStart(3,'0');return{history:i,preReloadShifterNibble:nibble,palette:bg.palette_shift,cramIndex:index,rgbFromActualSavedCRAM:rgb,firstObservedReferenceRGB:refs[i][differences.first.index][3]};});
for(const im of images)delete im.raw;
const out={baseline:'58583189b5c650dc6658ef467e8dcb72d9f6e6c2',images,equalCompleteImages:images[0].binarySha===images[1].binarySha,captures,differences,causal};
fs.writeFileSync(p.join(d,'baseline_results.json'),JSON.stringify(out,null,2));
if(!out.equalCompleteImages||differences.visibleRGB!==7||differences.cpu||differences.vdp||differences.io||causal.some(c=>c.rgbFromActualSavedCRAM!==c.firstObservedReferenceRGB))throw Error('original reproduction changed');
console.log(JSON.stringify({equalCompleteImages:out.equalCompleteImages,imageSha:images[0].binarySha,capturesComplete:captures.map(c=>c.complete),loadResults:captures.map(c=>c.loadResults),differences,causal},null,2));
