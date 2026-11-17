const fs=require('fs'),cp=require('child_process'),p=require('path'),crypto=require('crypto');
const d=__dirname,root=p.resolve(d,'../..'),baseline='9873761503510e4b2c7e06600bf5515344235c2f';
const git=(...a)=>cp.execFileSync('git',a,{cwd:root,stdio:['ignore','pipe','pipe']}),assert=(v,m)=>{if(!v)throw Error(m);};
assert(git('rev-parse','HEAD').toString().trim()===baseline,'baseline moved');
assert(git('branch','--show-current').toString().trim()==='experiment/ym2413-selfhealing-mix','wrong branch');
const files=git('ls-tree','-r','--name-only',baseline,'--','SMS.sv','files.qip','rtl/','sys/').toString().trim().split('\n');
const normalize=b=>b.toString('latin1').replace(/\r\n/g,'\n');
const sha256={};for(const f of files){const bytes=fs.readFileSync(p.join(root,f));assert(normalize(bytes)===normalize(git('show',baseline+':'+f)),'production differs from baseline '+f);sha256[f]=crypto.createHash('sha256').update(bytes).digest('hex');}
const s=fs.readFileSync(p.join(root,'rtl/savestates.sv'),'utf8');
assert(s.includes('assign io_in = io_snap;')&&s.includes('assign video_state_in = video_snap;'),'master aliases lost');
assert(!fs.readFileSync(p.join(root,'rtl/VM2413/phasememory.vhd'),'utf8').includes('attribute ramstyle of phase_array'),'AUTO inference lost');
const existing=[['registers/extensions',0,0x24],['VRAM1',0x101,0x900],['WRAM maximum',0x901,0x1100],['NVRAM maximum',0xd01,0x1d00],['VRAM2 active',0x1101,0x1900],['VRAM1 passive',0x1901,0x2100],['VRAM2 passive',0x2101,0x2900]];
for(const [name,lo,hi] of existing)assert(hi<0x2997||lo>0x29cb,'FM overlap '+name);
assert(0x2998+52-1===0x29cb&&0x29cb<0x3000,'FM slot bounds');

fs.writeFileSync(p.join(d,'manifest.json'),JSON.stringify({baseline,reference:baseline,sha256,productionMatchesBaseline:true,FM:{descriptor:0x2997,payloadFirst:0x2998,payloadLast:0x29cb,privateWords:104,descriptorVersion:17}},null,2)+'\n');
console.log('PASS committed production identity, aliases, AUTO inference and FM address ownership');
