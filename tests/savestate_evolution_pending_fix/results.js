const fs=require('fs'),path=require('path'),crypto=require('crypto'),cp=require('child_process'),d=__dirname,r=path.resolve(d,'../..');
const read=n=>{let b=fs.readFileSync(path.join(d,n));return b[0]===255&&b[1]===254?b.toString('utf16le').slice(1):b.toString('utf8');};
const sha=b=>crypto.createHash('sha256').update(b).digest('hex'),assert=(x,m)=>{if(!x)throw Error(m);};
let logs=[];
function log(n,marker='PASS'){const s=read(n+'.log');assert(s.includes(marker)&&s.includes('Errors: 0')&&!/\*\* (Fatal|Error|Failure)|Errors: [1-9]/.test(s),n);logs.push({name:n,sha256:sha(fs.readFileSync(path.join(d,n+'.log')))});return s;}
for(const i of [0,1,2])log(`baseline/pre_directed${i}`,'PASS F15');log('baseline/pre_cpu','Flash=008123 DI=00');
let pending=[],checks=0,loads=0,saves=0;
for(const i of [0,1,2,5,6,7,8,9]){const s=log('fixed_directed'+i,'PASS F15');assert(!s.includes('FIRST_STATE')&&!s.includes('FIRST_FLASH'),'pending mismatch '+i);assert((s.match(/REPLAY CASE\d+ Q/g)||[]).length===5,'five LOADs '+i);const capture=s.match(/V10 CASE\d+ phase=([01]{6}) mapper=(\w+) 019=(\w+) 01b=(\w+) 02c=(\w+) 02d=(\w+)/);assert(capture,'payload '+i);const phase=capture[1],word=BigInt('0x'+capture[5]),expected=BigInt(Number(phase[1])+(Number(phase[2])<<1)+(Number(phase[3])<<2));assert(((word>>57n)&7n)===expected&&word>>60n===0n,'independent flag bit oracle '+i);assert(capture[6].toLowerCase()==='0000003c45563131','descriptor');const n=Number(s.match(/comparisons=(\d+)/)[1]);checks+=n;loads+=5;saves++;pending.push({case:i,phase,word:capture[5],comparisons:n});}
const offsets=[-1,0,1,14,28,29,30,31,42,43,44,45,46,59,74,89,149,209],cpu=[];
for(const i of offsets){const s=log('fixed_cpu'+i,'PASS F15 real T80');assert(s.includes('LAUNCH_TIMING')&&!/LAUNCH_TIMING[^\n]*frozen=1/.test(s),'semantic launch timing '+i);const replay=s.match(/CPU READ restored[^\n]*/g)||[];assert(replay.length===(i===0?3:1)&&replay.every(x=>x.includes('Flash=288123 DI=28')),'CPU byte '+i);loads+=replay.length;saves++;cpu.push({offset:i,request:s.match(/OP_REQUEST saving1[^\r\n]*/)[0],accept:s.match(/ACCEPT op1[^\r\n]*/)[0],replays:replay.length});}
const ce=n=>read(n+'.log').split(/\r?\n/).filter(s=>s.startsWith('# CE '));
log('cpu_reference','PASS F15 uninterrupted');assert(JSON.stringify(ce('cpu_reference'))===JSON.stringify(ce('fixed_cpu0'))&&ce('cpu_reference').length===78,'uninterrupted/SAVE-only CPU trajectory');
const turbo=log('turbo_cpu','PASS F15 real T80');assert(turbo.includes('-gHOST_CHANGE=1')&&(turbo.match(/CPU READ restored[^\n]*Flash=288123 DI=28/g)||[]).length===3,'current host turbo B');saves++;loads+=3;
for(const i of [3,4])log('fixed_pair'+i,'PASS F15 projection pair');
const words=n=>read(n).split(/\r?\n/).filter(x=>/^[0-9a-f]{16}$/i.test(x)).map(x=>BigInt('0x'+x));
const pairA=words('pairA.mem'),pairB=words('pairB.mem');assert(pairA.length===12288&&pairB.length===12288,'initialized pair images');const differences=pairA.map((v,i)=>v!==pairB[i]?i:-1).filter(i=>i>=0);assert(differences.length===1&&differences[0]===0x2c&&(pairA[0x2c]^pairB[0x2c])===(1n<<59n),'v11 distinguishes old collision only by saved menu arm');saves+=2;
let one=0n,zero=0n,mask=(1n<<57n)-1n;
for(let i=0;i<=30;i++){const s=log('f14_case'+i,'PASS FIXED F14');let v=BigInt('0x'+s.match(/SAVE_ONLY PASS CASE\d+ F14=(\w+)/)[1]);one|=v;zero|=~v&mask;}
assert((one&mask)===mask&&zero===mask,'F14 all57 bits zero/one');
for(const i of [0,2,3,4,12])log('f14_stress'+i,'PASS FIXED F14');
log('f14_cpu','hostTurboB=1');log('evolution_history','PASS F14 history');
for(const i of [0,6])log('f13_case'+i,'PASS FIXED F13');log('banking','PASS current mapper directed');
for(const i of [0,1])log('format_stall'+i,'cases31 rejected25 accepted6');log('compat','PASS F13 format cases30');
for(const n of ['mapper_memory','eeprom_direct','eeprom_ddr','eeprom_persistence','sc_ram','f07_controller','f07_systeme','f02_direct','f02_ddr','f08_md6','f09_tap','f10_paddle','f11_lightgun','f11_format0','f11_format3','f12_paused','psg'])log('reg_'+n);
assert((read('reg_eeprom_ddr.log').match(/PASS EEPROM DDRAM case/g)||[]).length===24,'EEPROM24');assert((read('reg_sc_ram.log').match(/PASS F05 fullDDR/g)||[]).length===60,'SC60');
const git=(...a)=>cp.execFileSync('git',a,{cwd:r,encoding:'utf8'}).trim();
assert(git('branch','--show-current')==='fix/savestate-evolution-pending','branch');assert(git('rev-parse','--short','HEAD')==='ff9d66b','baseline');assert(!git('diff','--cached','--stat'),'index');
const expected=['rtl/evolution_mapper.vhd','rtl/savestates.sv','rtl/system.vhd'];assert(JSON.stringify(git('diff','--name-only').split(/\r?\n/).sort())===JSON.stringify(expected),'production scope');
const sourceHashes=Object.fromEntries(expected.map(n=>[n,sha(fs.readFileSync(path.join(r,n)))]));
const result={baseline:'ff9d66b',sourceHashes,canonicalLogs:logs.length,logs,pending,cpu,acceptedSaves:saves,acceptedLoads:loads,clockComparisons:checks,saveOnlyCpuEnableSamples:78,all57F14BitsZeroAndOne:true,fullT80CollisionProof:'Not established or required; confirmed replay defect fixed.',F06:'unresolved',F16:'untouched'};
fs.writeFileSync(path.join(d,'simulation_results.json'),JSON.stringify(result,null,2)+'\n');
let boundaries='# F15 accepted-boundary sweep\n\nAll requests use production acceptance; CPU architecture is captured at the accepted edge, Evolution at existing ARM one host clock later.\n\n| Offset | SAVE input pulse cycle | Accepted cycle | Accepted phase | CPU address | Guest after LOAD |\n|---|---|---|---|---|---|\n';
for(const x of cpu){const q=x.request.match(/cycle(\d+)/),a=x.accept.match(/cycle(\d+) phase=([01]+) A=(\w+)/);boundaries+=`| ${x.offset} | ${q[1]} | ${a[1]} | ${a[2]} | ${a[3]} | Flash288123 / DI28 |\n`;}
boundaries+='\nPhase order: pending, armed, read-pending, menu-arm, old-M1, launch.\n\n| Directed case | Saved phase | Word02C | SAVE-only clock comparisons | Identical LOAD trajectories |\n|---|---|---|---|---|\n';for(const x of pending)boundaries+=`| ${x.case} | ${x.phase} | ${x.word} | ${x.comparisons} | 5 |\n`;
fs.writeFileSync(path.join(d,'boundaries.md'),boundaries);
console.log('PASS '+logs.length+' canonical logs, '+saves+' F15 SAVEs / '+loads+' LOADs, '+checks+' clock comparisons, 78 exact CPU-enable samples, all57 F14 bits.');
