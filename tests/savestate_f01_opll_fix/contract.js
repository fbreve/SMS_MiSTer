const fs=require('fs'),p=require('path'),crypto=require('crypto'),cp=require('child_process');
const dir=__dirname,root=p.resolve(dir,'../..');
const inventory=JSON.parse(fs.readFileSync(p.join(dir,'../savestate_f01_opll_architecture/inventory.json')));
const initializer=r=>r.signal.includes('init_')||(r.module==='ct/vmem'&&['rom_addr','rstate'].includes(r.signal));
const arrays=[['ct/u_register_memory','regs_array',9,22],['ct/vmem','voices user entries0..1',2,36],['pg/MEM','phase_array',18,18],['eg/u_envelope_memory','egdata_set',18,25],['og/Fmem','data_array',9,10],['og/Mmem','data_array entries0..17',18,10]];
let next=0;const rows=inventory.rows.map(r=>({...r,stored:false,slices:[],resolution:'',save:'',load:'',ordering:'',reconstructed:false}));
for(const [module,signal,count,width] of arrays){const r=rows.find(r=>r.module===module&&r.signal===signal);r.stored=true;
 for(let entry=0;entry<count;entry++)for(let bit=0;bit<width;bit+=32)r.slices.push({word:next++,entry,sourceLo:bit,wordLo:0,width:Math.min(32,width-bit)});
 r.resolution=module==='ct/vmem'?'Entry 1 TL[5:0]/FB[2:0] are stored as canonical zero; these carrier fields have no operational reader.':'Meaningful array bits retained; register bits 15:14 excluded.';
 r.save='Private synchronous read through original array port; writers inhibited from first frozen edge.';
 r.load='Private synchronous entry write; voice low32 staged, high4 commits one36-bit entry.';
 r.ordering='Validated arrays first, scalar pending writers afterwards; no ordinary writes during either phase.';
}
const scalarGroups=new Map();
for(const r of rows){if(r.stored)continue;
 if(initializer(r)){r.resolution='Require all initializer-ready outputs before accepting SAVE. LOAD restores only ready images; initializer completion remains established. Legacy reset waits for complete initialization.';r.reconstructed=true;continue;}
 if(r.category==='UNKNOWN'){r.resolution='Fixed voice entries 2..37 are immutable ROM constants after the explicit readiness acceptance guard. Their pre-initialization values cannot enter a v17 snapshot.';r.reconstructed=true;continue;}
 if(!r.historicalBits){r.resolution=r.note||'No inter-activation state.';r.reconstructed=r.derived;r.ordering=r.derived?'Return runtime addresses; eight stationary host edges, all writers held; then release.':'';continue;}
 r.stored=true;if(!scalarGroups.has(r.module))scalarGroups.set(r.module,[]);scalarGroups.get(r.module).push(r);
}
for(const [module,fields] of scalarGroups){let bit=0,word=next++;
 for(const r of fields){let width=r.historicalBits;if(bit+width>32){word=next++;bit=0;}
 // inst_cache is nine independent nibbles, and voice_wdata is a 36-bit record.
 let left=width,sourceLo=0;
 while(left){let n=Math.min(left,32-bit);r.slices.push({word,sourceLo,wordLo:bit,width:n});left-=n;sourceLo+=n;bit+=n;if(left){word=next++;bit=0;}}
 r.save='Read frozen post-acceptance-T scalar/variable before any private write.';
 r.load='Local word enable writes only named slices while all ordinary consumers/writers hold.';
 r.resolution=r.note||'Historical state retained.';r.ordering='After arrays; derive delayed counters from restored s0; stationary refill before release.';
 }
}
if(next%2)next++;
const masks=Array(next).fill(0n);for(const r of rows)for(const s of r.slices)masks[s.word]|=((1n<<BigInt(s.width))-1n)<<BigInt(s.wordLo);
const carrier=rows.find(r=>r.module==='ct/vmem'&&r.stored).slices.find(s=>s.entry===1&&s.sourceLo===0).word;
masks[carrier]&=~((63n<<20n)|(7n<<16n));
const result={variant:'Initialization-ready, pre-commit arrays',wordBits:32,words:next,descriptorBytes:8,payloadBytes:next*4,masks:masks.map(x=>x.toString(16).padStart(8,'0')),rows};
fs.writeFileSync(p.join(dir,'state_map.json'),JSON.stringify(result,null,2)+'\n');
fs.writeFileSync(p.join(dir,'state_map.md'),'# F01 implementation contract, before production changes\n\n32-bit synchronous local read/write; addresses below are private 32-bit rows. One 256x32 M10K scratch. Each read has one registered response; SAVE uses issue/collect edges. LOAD validates the complete descriptor, row padding and bounded fields before any live write. No variable barrel packer.\n\nSAVE acceptance additionally requires all six initialization-ready signals. Each initializer progresses on host clocks even with xena=0; all complete within 114 rising edges after reset release. This gate delays acceptance, never freezes guest execution early. Normal acceptance conditions still apply. Both SAVE and LOAD preserve the pre-commit array representation from the first frozen edge. Ordinary stores and initializers remain inhibited during all collection, restore and refill. Eight stationary host edges refill pure caches; no attack/sine/guest tick.\n\nThe 37 initializer-control bits and 1296 fixed voice bits explicitly remain outside the payload only under this readiness contract. ModelSim uninitialized backing is not evidence of hardware power-up constants; readiness follows explicit RTL writes. Warm reset drops readiness immediately. Legacy LOAD resets OPLL locally and waits for readiness; it cannot reproduce absent historical FM.\n\n|Source|Field|Declared bits|Stored row:bits (source offset)|SAVE|LOAD|Reconstructed / resolution|Ordering|First consumer|\n|---|---|---:|---|---|---|---|---|---|\n'+rows.map(r=>`|${r.source}:${r.line}|${r.module}.${r.signal}|${r.bits}|${r.slices.map(s=>`${s.word.toString(16)}:${s.wordLo+s.width-1}..${s.wordLo} <- ${s.entry===undefined?'':`entry${s.entry}:`}${s.sourceLo+s.width-1}..${s.sourceLo}`).join('; ')||'excluded'}|${r.save}|${r.load}|${r.resolution}|${r.ordering}|${r.firstConsumer}|`).join('\n')+`\n\nMap length: ${next} rows / ${next*4} payload bytes, plus 8-byte descriptor. Every unassigned bit is canonical zero and validated before application. Exact bit-level masks are in state_map.json. User voice carrier bits are canonicalized; scalar source packing excludes only inventory-proven padding.\n`);
if(!fs.existsSync(p.join(dir,'baseline.json'))){const files=cp.execFileSync('git',['ls-files'],{cwd:root,encoding:'utf8'}).trim().split('\n');const hashes={};for(const f of files){const q=p.join(root,f);if(fs.existsSync(q)&&fs.statSync(q).isFile())hashes[f]=crypto.createHash('sha256').update(fs.readFileSync(q)).digest('hex');}fs.writeFileSync(p.join(dir,'baseline.json'),JSON.stringify({head:cp.execFileSync('git',['rev-parse','HEAD'],{cwd:root,encoding:'utf8'}).trim(),branch:cp.execFileSync('git',['branch','--show-current'],{cwd:root,encoding:'utf8'}).trim(),hashes},null,2));}
console.log({rows:rows.length,words:next,bytes:next*4+8,inventoryHistoricalBits:inventory.historicalBits,selectedHistoricalBits:1896});
