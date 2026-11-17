const fs=require('fs'),cp=require('child_process'),p=require('path'),crypto=require('crypto');
const d=__dirname,root=p.resolve(d,'../..'),ref='7fcd5e12847eedf9e97a44dc937c3dbac3205f7c';
const git=(...args)=>cp.execFileSync('git',args,{cwd:root,encoding:'latin1',stdio:['ignore','pipe','pipe']});
const read=n=>fs.readFileSync(p.join(root,n),'latin1');
const assert=(v,m)=>{if(!v)throw Error(m);};
assert(git('rev-parse','HEAD').trim()==='66f16d5c656fd8906d62570da4d258875bcee684','baseline moved');
assert(git('branch','--show-current').trim()==='experiment/ym2413-v19-fullstate','wrong branch');
const changed=git('diff','--name-only').trim().split('\n').filter(Boolean);
const allowed=new Set(['SMS.sv','files.qip','rtl/system.vhd','rtl/savestates.sv']);
const normalize=s=>s.replace(/\r\n/g,'\n').replace(/[ \t]+$/gm,'');
for(const n of changed){
 assert(!n.startsWith('sys/'),'shared sys modification');
 if(n.startsWith('rtl/VM2413/')){
  let expected=git('show',ref+':'+n);
  if(n.endsWith('/phasememory.vhd'))expected=expected.replace('  attribute ramstyle of phase_array : signal is "logic";\n','');
  assert(normalize(read(n))===normalize(expected),'unexpected FM change '+n);
 }else assert(allowed.has(n),'unrelated changed file '+n);
}
assert(read('rtl/opll_snapshot.sv')===git('show',ref+':rtl/opll_snapshot.sv'),'snapshot differs from reference');
const s=read('rtl/savestates.sv');
assert(s.includes('assign io_in = io_snap;')&&s.includes('assign video_state_in = video_snap;'),'master aliases lost');
assert(!read('rtl/VM2413/phasememory.vhd').includes('attribute ramstyle of phase_array'),'AUTO inference lost');
for(const tag of ['RESTART_MAGIC','BACKGROUND_MAGIC','ss_bg_out','ss_cpu_prepare'])assert(!s.includes(tag),'unrelated v19 integration '+tag);
const existing=[['registers/extensions',0,0x24],['VRAM1',0x101,0x900],['WRAM maximum',0x901,0x1100],['NVRAM maximum',0xd01,0x1d00],['VRAM2 active',0x1101,0x1900],['VRAM1 passive',0x1901,0x2100],['VRAM2 passive',0x2101,0x2900]];
for(const [name,lo,hi] of existing)assert(hi<0x2997||lo>0x29cb,'FM overlap '+name);
assert(0x2998+52-1===0x29cb&&0x29cb<0x3000,'FM slot bounds');
const manifest={baseline:git('rev-parse','HEAD').trim(),reference:ref,branch:git('branch','--show-current').trim(),changedProduction:[...changed,'rtl/opll_snapshot.sv'],diffStat:git('diff','--stat'),ownership:{unit:'64-bit DDR words relative to slot base',existing,FM:{descriptor:0x2997,payloadFirst:0x2998,payloadLast:0x29cb,privateWords:104,descriptorVersion:17,slotWords:0x3000},note:'Existing mode-exclusive ranges overlap each other; no existing range overlaps FM.'},sha256:{}};
const counts=git('diff','--numstat').trim().split('\n').map(x=>x.split('\t'));
manifest.diffTotals={productionFiles:changed.length+1,insertions:counts.reduce((sum,x)=>sum+ +x[0],0)+read('rtl/opll_snapshot.sv').trimEnd().split('\n').length,deletions:counts.reduce((sum,x)=>sum+ +x[1],0)};
for(const n of manifest.changedProduction)manifest.sha256[n]=crypto.createHash('sha256').update(fs.readFileSync(p.join(root,n))).digest('hex');
fs.writeFileSync(p.join(d,'manifest.json'),JSON.stringify(manifest,null,2)+'\n');
let addition;try{addition=git('diff','--no-index','--','NUL','rtl/opll_snapshot.sv');}catch(e){if(e.status!==1)throw e;addition=e.stdout;}
fs.writeFileSync(p.join(d,'complete.diff'),git('diff','--no-ext-diff')+'\n'+addition,'latin1');
console.log('PASS scope/reference identity, master aliases/AUTO inference and FM address ownership');
