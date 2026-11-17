const fs=require('fs'),p=require('path'),crypto=require('crypto'),assert=require('assert');const d=__dirname,prefix=process.argv[2]||'e_';
const sha=b=>crypto.createHash('sha256').update(b).digest('hex');
function readHex(f){const a=[];let at=0;for(let line of fs.readFileSync(f,'utf8').split(/\r?\n/)){line=line.replace(/\/\/.*$/,'').trim();if(!line)continue;let m=line.match(/^([0-9a-f]+):\s*(.*)$/i);if(m){at=parseInt(m[1],16);line=m[2];}for(const t of line.split(/\s+/).filter(Boolean))if(t[0]==='@')at=parseInt(t.slice(1),16);else a[at++]=BigInt('0x'+t);}assert.equal(a.length,12288);assert(!a.includes(undefined));return a;}
function payload(words,base,n){const b=Buffer.alloc(n);for(let i=0;i<n;i++)b[i]=Number(words[base+(i>>3)]>>BigInt((i&7)*8)&255n);return b;}
const result={scope:'Actual independently generated controller slots; unmarked tails are never treated as complete',slots:[]};
for(const kind of ['baseline','sram','reference','context','sham']){
 const name=prefix+kind,file=p.join(d,name+'_saved_slot.hex');if(!fs.existsSync(file))continue;
 const w=readHex(file),m=fs.readFileSync(p.join(d,name+'_saved.mem')),upper=w[5]>>38n;
 assert.equal(w[0]>>32n,24574n);assert.equal(w[1],0xa458e3d4534d5331n);
 const complete=upper!==0n&&!!(w[5]&(1n<<43n)),context=upper!==0n&&!!(w[5]&(1n<<42n));
 if(upper!==0n){assert.equal(w[5]>>48n,0x5953n);assert.equal(w[5]>>44n&15n,1n);assert.equal(w[5]>>38n&1n,0n);}
 const v=payload(w,0x101,16384),wr=payload(w,0x901,8192),s=payload(w,0xd01,32768);
 assert(v.equals(m.subarray(0,16384)),'VRAM payload mismatch '+name);assert(wr.equals(m.subarray(32768,40960)),'WRAM payload mismatch '+name);
 if(complete)assert(s.equals(m.subarray(40960)),'complete SRAM payload mismatch '+name);
 const cpu=w[2]|w[3]<<64n|w[4]<<128n|(w[5]&((1n<<38n)-1n))<<192n;
 const comparable=[cpu.toString(16),w[6].toString(16),w[7].toString(16),...w.slice(8,14).map(x=>x.toString(16)),w[15].toString(16),w[25].toString(16),(w[26]&((1n<<22n)-1n)).toString(16),sha(v),sha(wr),sha(m.subarray(40960))];
 result.slots.push({name,slotSHA256:sha(fs.readFileSync(file)),word5:w[5].toString(16).padStart(16,'0'),mapper:w[15].toString(16).padStart(16,'0'),SRAMEnable:Number(w[15]>>50n&1n),SRAMBank:Number(w[15]>>52n&1n),PC:Number(cpu>>64n&65535n).toString(16),completePhysicalSRAM:complete,predecessorPresent:context,predecessorClass:context?Number(w[5]>>39n&7n):null,physicalSRAMSHA256:sha(m.subarray(40960)),SRAMPayloadValidity:complete?'marked complete and byte-exact to all32768 physical bytes':'unmarked: not a complete physical SRAM image',comparableStateSHA256:sha(Buffer.from(comparable.join('\n')))});
}
result.allCapturedStatesEqualIgnoringFeatureMetadata=result.slots.length===5&&new Set(result.slots.map(q=>q.comparableStateSHA256)).size===1;
fs.writeFileSync(p.join(d,prefix+'saved_slot_validation.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify({slots:result.slots.length,equal:result.allCapturedStatesEqualIgnoringFeatureMetadata,metadata:result.slots.map(q=>({name:q.name,word5:q.word5,SRAMEnable:q.SRAMEnable,complete:q.completePhysicalSRAM}))},null,2));
