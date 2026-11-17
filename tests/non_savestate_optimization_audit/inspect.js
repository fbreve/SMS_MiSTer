const fs=require('fs'),p=require('path'),crypto=require('crypto'),d=__dirname,root=p.resolve(d,'../..');
const read=f=>fs.readFileSync(p.join(root,f),'utf8'),save=(f,x)=>fs.writeFileSync(p.join(d,f),JSON.stringify(x,null,2)+'\n');
const ledger=JSON.parse(read('tests/non_savestate_optimization_audit/provenance.json'));
const extra=['tests/cpu_restore_alias_timing_diagnosis/baseline_registers.tsv','tests/cpu_restore_alias_timing_diagnosis/paths.json','tests/cpu_restore_alias_timing_diagnosis/provenance.json','tests/cpu_restore_alias_timing_diagnosis/query.tcl','tests/cpu_restore_alias_timing_diagnosis/review.md'];
for(const f of extra)ledger.retained[f]=crypto.createHash('sha256').update(fs.readFileSync(p.join(root,f))).digest('hex');save('provenance.json',ledger);
const nodes=read(extra[0]).trim().split(/\r?\n/),counts={};
for(const [key,pred,declared]of [['shifters',s=>s.includes('vpd_sprite_shifter:'),4224],['evaluatorParents',s=>s.includes('vdp_sprites:')&&!s.includes('vpd_sprite_shifter:'),5336]]){const a=nodes.filter(pred);counts[key]={declaredStateBits:declared,timingNodes:a.length,duplicates:a.filter(s=>s.includes('~DUPLICATE')).length,names:a};}
save('sprite_registers.json',counts);
const paths=JSON.parse(read(extra[1])),compact={};for(const [k,a]of Object.entries(paths))if(k.startsWith('baseline_'))compact[k]=a.map(({slack,from,to,delay,skew,relationship,launch,capture})=>({slack,from,to,delay,skew,relationship,launch,capture}));save('timing.json',compact);
console.log(JSON.stringify({registers:Object.fromEntries(Object.entries(counts).map(([k,{names,...v}])=>[k,v])),timing:Object.fromEntries(Object.entries(compact).map(([k,a])=>[k,{count:a.length,worst:a[0]?.slack,bestReported:a.at(-1)?.slack}]))},null,2));
