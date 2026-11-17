const fs=require('fs'),path=require('path'),cp=require('child_process'),crypto=require('crypto');
const d=__dirname,r=path.resolve(d,'../..');
const git=(...args)=>cp.execFileSync('git',args,{cwd:r,encoding:'utf8',stdio:['ignore','pipe','pipe']}).trim();
const read=n=>{const b=fs.readFileSync(path.join(d,n));return b[0]===255&&b[1]===254?b.subarray(2).toString('utf16le'):b.toString('utf8');};
const names=[...Array.from({length:15},(_,i)=>`case${i}`),'cpu','history','banking','f13_dahjee','f13_deadline','f07','f08','f09','f10','f11','f12'];
const logs=names.map(name=>{const s=read(name+'.log');if(!/PASS/.test(s)||/\*\* (Error|Fatal|Failure)|Errors: [1-9]/.test(s))throw Error(name+' failed');return {name,pass:true,evidence:s.split(/\r?\n/).filter(l=>/PAIR |REPLAY |RESTORE_EDGE |SAVE_ONLY|PASS|CPU READ/.test(l))};});
for(let i=0;i<15;i++)if(!read(`case${i}.log`).includes('accepted=3 loaded=2'))throw Error('incomplete capture coverage '+i);
const cpu=read('cpu.log');if(!/actual OUT20 data before28 restored48/.test(cpu)||!cpu.includes('Flash=288123 DI=28')||!cpu.includes('Flash=488123 DI=48'))throw Error('CPU evidence incomplete');
const sourceNames=['SMS.sv','rtl/system.vhd','rtl/evolution_mapper.vhd','rtl/evolution_rom_address.vhd','rtl/mapper_ctrl.vhd','rtl/mapper_detect.vhd','rtl/memory_decode.vhd','rtl/io.vhd','rtl/video.vhd','rtl/savestates.sv','rtl/T80/T80.vhd','rtl/T80/T80s.vhd'];
const sources=sourceNames.map(name=>({name,sha256:crypto.createHash('sha256').update(fs.readFileSync(path.join(r,name))).digest('hex')}));
if(git('diff','--name-only')||git('diff','--cached','--name-only'))throw Error('tracked/index changes');
if(git('branch','--show-current')!=='investigate/savestate-evolution-selector')throw Error('wrong branch');
const out={classification:'CONFIRMED - FIX REQUIRED',branch:git('branch','--show-current'),head:git('rev-parse','HEAD'),production_diff:false,staged:false,format:9,logs,sources,
 counts:{logs:logs.length,f14DirectedCases:15,f14AcceptedOperations:45,f14Loads:30,realCpuAcceptedOperations:2,historyMatrixStages:10},
 diffStat:git('diff','--stat'),status:git('status','--short'),f06:'unresolved, unchanged'};
fs.writeFileSync(path.join(d,'results.json'),JSON.stringify(out,null,2)+'\n');
fs.writeFileSync(path.join(d,'git_status.txt'),out.status+'\n');fs.writeFileSync(path.join(d,'diff_stat.txt'),out.diffStat+'\n');
console.log(`PASS ${logs.length} canonical logs; 45 directed accepted operations, 30 LOADs, 2 real-CPU operations; tracked diff/index empty.`);
