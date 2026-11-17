const fs=require('fs'),path=require('path'),cp=require('child_process'),crypto=require('crypto');
const d=__dirname,r=path.resolve(d,'../..');
function read(n){let b=fs.readFileSync(path.join(d,n));return b[0]===255&&b[1]===254?b.toString('utf16le').slice(1):b.toString('utf8');}
function assert(x,m){if(!x)throw Error(m);}
const cpu=[['before','cpu_offset_before.log'],...[0,1,14,29,30,44,45,59,74,89,149,209].map(i=>[i,`cpu_offset${i}.log`])].map(([offset,n])=>{
 let s=read(n);assert(s.includes('PASS F15 real T80')&&!/\*\* (Fatal|Error)/.test(s),n);
 const observation=s.match(/REQUEST cycle(\d+) offset(-?\d+) phase=([01]+) A=(\w+) M1=(\d) MREQ=(\d) WR=(\d)/),request=s.match(/OP_REQUEST saving1 cycle(\d+) phase=([01]+) A=(\w+) M1=(\d) MREQ=(\d) RD=(\d) WR=(\d)/),accept=s.match(/ACCEPT op1 cycle(\d+) phase=([01]+) A=(\w+) M1=(\d) MREQ=(\d) RD=(\d) WR=(\d) CPU=(\w+)/),payload=s.match(/V10 map=(\w+) extra=(\w+) cpu=([^\r\n]+)/);
 assert(request,'Exact SAVE input pulse missing '+n);
 return{offset,observation:observation.slice(1),request:request.slice(1),accept:accept.slice(1),payload:payload.slice(1),vulnerable:s.includes('vulnerable=1'),log:n};
});
const ce=n=>read(n).split(/\r?\n/).filter(l=>l.startsWith('# CE '));
const ref=ce('cpu_reference.log'),saved=ce('cpu_offset0.log');assert(ref.length===78&&JSON.stringify(ref)===JSON.stringify(saved),'Uninterrupted/SAVE-only CE trajectory');
const pairA=read('pairA.mem'),pairB=read('pairB.mem');assert(pairA===pairB,'Pair complete DDR images');assert(!/[xz]/i.test(pairA.replace(/\/\/[^\n]*/g,'')),'Pair initialized bytes');
const regressions=[...Array.from({length:15},(_,i)=>`reg_f14_${i}.log`),'reg_f14_cpu.log','reg_evolution_history.log','reg_f13_0.log','reg_f13_6.log','reg_banking.log','regressions/savestate_systeme_pause_fix/reg_f12.log'];
for(const n of regressions){const s=read(n);assert(/PASS/.test(s)&&!/\*\* (Fatal|Error|Failure)|Errors: [1-9]/.test(s),n);}
const cases=[0,1,2,5,6,7,8,9];
const directed=cases.map(i=>{const n=`directed${i}.log`,s=read(n);assert(s.includes('PASS F15')&&!/\*\* (Fatal|Error)/.test(s),n);return{case:i,request:s.match(/REQUEST CASE\d+ saving1 cycle(\d+) phase=(\d+) A=(\w+)/).slice(1),accept:s.match(/ACCEPT CASE\d+ cycle(\d+) phase=(\d+) A=(\w+)/).slice(1),payload:s.match(/V10 CASE[^\r\n]+/)[0],comparisons:Number(s.match(/comparisons=(\d+)/)[1]),firstState:Number(s.match(/FIRST_STATE sample(\d+)/)[1]),firstFlash:Number(s.match(/FIRST_FLASH sample(\d+)/)[1]),replay:s.match(/REPLAY CASE\d+ Q0[^\r\n]+/)[0]};});
assert(new Set(directed.map(x=>x.accept[1].slice(1,4))).size===7,'All nonzero accepted phase combinations');
for(const n of ['directed3.log','directed4.log'])assert(read(n).includes('PASS F15')&&!/\*\* (Fatal|Error)/.test(read(n)),n);
const git=(...args)=>cp.execFileSync('git',args,{cwd:r,encoding:'utf8'}).trim();
assert(git('branch','--show-current')==='investigate/savestate-evolution-pending','branch');assert(git('rev-parse','--short','HEAD')==='ff9d66b','baseline');assert(git('diff','--stat')===''&&git('diff','--cached','--stat')==='','No tracked/staged changes');
const production=['SMS.sv','rtl/system.vhd','rtl/evolution_mapper.vhd','rtl/evolution_rom_address.vhd','rtl/mapper_ctrl.vhd','rtl/mapper_detect.vhd','rtl/savestates.sv'];
const hashes={};for(const n of production){const b=fs.readFileSync(path.join(r,n));hashes[n]=crypto.createHash('sha256').update(b).digest('hex');}
// Strip ONLY the two added observation declarations; functional text must match.
let obs=read('evolution_observed.vhd').replace('debug_phase : out std_logic_vector(5 downto 0);\n        ','').replace("    debug_phase <= switch_pending & switch_armed & record_read_pending_r & menu_launch_armed_r & old_m1_n & game_launch_r;\n",'');
assert(obs===fs.readFileSync(path.join(r,'rtl/evolution_mapper.vhd'),'utf8'),'Observation adapter changes functional logic');
const result={classification:'CONFIRMED - FIX REQUIRED',baseline:'ff9d66b',branch:git('branch','--show-current'),cpuBoundaryTimings:cpu.length,cpu,directed,saveOnly:{identicalCpuEnableSamples:ref.length,directedClockComparisons:directed.map(x=>x.comparisons)},replay:{directedCases:cases.length,perturbationsPerCase:5,realCpuArmedLoads:3,investigativeSaves:13+cases.length+2,investigativeLoads:15+cases.length*5},pair:{equalInitializedDdrImage:true,words:12288,scope:'Production mapper + controller; synthetic zero architectural CPU input. Full reachable T80-state pair NOT established.'},regressionLogs:regressions.length,regressions,productionHashes:hashes,diffStat:git('diff','--stat'),status:git('status','--short')};
fs.writeFileSync(path.join(d,'results.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify({classification:result.classification,timings:cpu.length,vulnerable:cpu.filter(x=>x.vulnerable).length,saveOnlyCe:ref.length,regressions:regressions.length,pairEqual:true}));
let table='# Accepted-boundary evidence\n\nPhase order: pending, armed, read-pending, menu-arm, old-M1, launch. Request below is the actual raised SAVE input.\n\n| CPU offset | Request cycle / phase / A | Accepted cycle / phase / A | Mapper | Evolution160 | Result |\n|---|---|---|---|---|---|\n';
for(const x of cpu)table+=`| ${x.offset} | ${x.request.slice(0,3).join(' / ')} | ${x.accept.slice(0,3).join(' / ')} | ${x.payload[0]} | ${x.payload[1]} | ${x.vulnerable?'lost armed commit':'equivalent control'} |\n`;
table+='\n| Directed case | Request cycle / phase / A | Accepted cycle / phase / A | First state sample | First Flash sample | Final probe |\n|---|---|---|---|---|---|\n';
for(const x of directed)table+=`| ${x.case} | ${x.request.join(' / ')} | ${x.accept.join(' / ')} | ${x.firstState} | ${x.firstFlash} | ${x.replay} |\n`;
table+='\nEach directed case compares every observed host-clock suffix sample against the reference and every repeated LOAD against the first loaded trajectory, over five Q histories. Complete CPU architectural words and bus controls are retained in results.json and the logs.\n';
fs.writeFileSync(path.join(d,'boundaries.md'),table);
