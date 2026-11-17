const fs=require('fs'),path=require('path'),cp=require('child_process'),crypto=require('crypto');
const d=__dirname,r=path.resolve(d,'../..');
function git(...args){return cp.execFileSync('git',args,{cwd:r,encoding:'utf8',stdio:['ignore','pipe','pipe']}).trim();}
function read(n){let b=fs.readFileSync(path.join(d,n));return b[0]===255&&b[1]===254?b.subarray(2).toString('utf16le'):b.toString('utf8').replace(/^\uFEFF/,'');}
function assert(c,m){if(!c)throw Error(m);}
let logs=[];
function log(n,needle){const s=read(n);assert(!/\*\* (Error|Fatal|Failure)|Errors: [1-9]/.test(s),'Failed '+n);assert(s.includes(needle)&&s.includes('# Errors: 0'),'Missing completion '+n);logs.push({file:n,completion:s.split(/\r?\n/).filter(l=>l.includes(needle)),warnings:[...s.matchAll(/\*\* Warning: ([^\r\n]+)/g)].map(m=>m[1])});return s;}
let cases=[];
for(let i=0;i<12;i++){
 const s=log(`case${i}.log`,`PASS F13 case${i} `);
 assert(s.includes(`SAVE_ONLY PASS case${i} `),'save-only absent '+i);
 const captures=[...s.matchAll(/CAPTURE case\d+ clock(\d+) age(\d+) mapper([0-9a-f]+) sega(\d)/g)].map(m=>({clock:+m[1],age:+m[2],mapper:m[3],sega:+m[4]}));
 const restores=[...s.matchAll(/RESTORE case\d+ clock(\d+) mapper([0-9a-f]+) sega-before(\d)/g)].map(m=>({clock:+m[1],mapper:m[2],segaBefore:+m[3]}));
 assert(captures.length===3&&restores.length===2,'wrong FSM operation totals '+i);
 cases.push({case:i,divergent:[0,1,6,7,9].includes(i),captures,restores,result:s.split(/\r?\n/).find(l=>l.includes('RESULT case')),pairs:s.split(/\r?\n/).filter(l=>l.includes('NONINJECTIVE'))});
}
const boundary=log('boundary.log','PASS F13 boundary sweep 183 accepted captures');
assert((boundary.match(/# BOUNDARY kind/g)||[]).length===183,'sweep count mismatch');
const hist=[...boundary.matchAll(/HISTORY ticks=(\d+) bank=(\d+) sega=(\d+) wonderkid_count=(\d+)/g)].map(m=>({ticks:+m[1],bank:+m[2],sega:+m[3],count:+m[4]}));
assert(hist.length===183,'history sample count mismatch');
assert(hist.some(h=>h.ticks<65535)&&hist.some(h=>h.ticks===65535),'deadline not crossed');
let cpu=[];for(let i=0;i<2;i++){let s=log(`cpu${i}.log`,`PASS F13 real T80/video accepted EARLY${i}`);cpu.push(s.split(/\r?\n/).find(l=>l.includes('PASS F13 real')));}
const edge=log('edge.log','PASS F13 edge-history MODE0 first LOAD DATA00 second LOAD DATA03');
assert((edge.match(/CAPTURE case8/g)||[]).length===3&&(edge.match(/RESTORE case8/g)||[]).length===2,'edge FSM coverage incomplete');
const bootEdge=log('boot_edge.log','PASS F13 edge-history MODE1 first LOAD DATA02 second LOAD DATA03');
assert((bootEdge.match(/CAPTURE case0/g)||[]).length===3&&(bootEdge.match(/RESTORE case0/g)||[]).length===2,'boot edge FSM coverage incomplete');
const regNames=['banking','mapper_memory','eeprom_direct','eeprom_ddr','eeprom_persistence','sc_ram','f07_controller','f07_systeme','f08_md6','f09_tap','f10_paddle','f11_lightgun','f12_paused'];
for(const n of regNames)log(`reg_${n}.log`,'PASS');
assert(read('reg_banking.log').includes('PASS current mapper directed regression complete'),'directed banking incomplete');
assert((read('reg_sc_ram.log').match(/PASS F05 fullDDR/g)||[]).length===60,'SC coverage incomplete');
assert((read('reg_eeprom_ddr.log').match(/PASS EEPROM DDRAM case/g)||[]).length===24,'EEPROM coverage incomplete');
assert(read('reg_f12_paused.log').includes('PASS FIXED'),'F12 incomplete');
assert(git('branch','--show-current')==='investigate/savestate-mapper-detection','wrong branch');
assert(git('rev-parse','HEAD').startsWith('b61f307'),'unexpected base');
assert(git('diff','--stat')==='','tracked diff present');
assert(git('diff','--cached','--stat')==='','staged diff present');
const sourceNames=['SMS.sv','rtl/system.vhd','rtl/mapper_detect.vhd','rtl/mapper_ctrl.vhd','rtl/memory_decode.vhd','rtl/evolution_mapper.vhd','rtl/evolution_rom_address.vhd','rtl/io.vhd','rtl/video.vhd','rtl/savestates.sv','rtl/T80/T80.vhd','rtl/T80/T80s.vhd','rtl/cart_eeprom.vhd','rtl/eeprom_93c46.vhd','rtl/memory_bus.vhd'];
const hash=f=>crypto.createHash('sha256').update(fs.readFileSync(f)).digest('hex');
let sourceHashes=Object.fromEntries(sourceNames.map(n=>[n,hash(path.join(r,n))]));
let ss=fs.readFileSync(path.join(r,'rtl/savestates.sv'),'utf8');
for(const n of ['mapper_snap','evolution_snap']){const re=new RegExp('^reg\\s+\\[[^\\]]+\\]\\s+'+n+';\\r?\\n','m'),decl=ss.match(re)[0];ss=ss.replace(re,'').replace('// NVRAM size calculation helpers',decl+'// NVRAM size calculation helpers');}
assert(fs.readFileSync(path.join(d,'savestates_sim.sv'),'utf8')===ss,'controller adapter differs');
let ctrl=fs.readFileSync(path.join(r,'rtl/mapper_ctrl.vhd'),'utf8').replace(/(case A\(1 downto 0\) is[\s\S]*?)(\s*end case;)/g,(m,a,b)=>/when others/i.test(a)?m:a+'\n when others => null;'+b);
assert(fs.readFileSync(path.join(d,'mapper_ctrl_sim.vhd'),'utf8')===ctrl,'banking adapter differs');
let result={classification:'CONFIRMED - FIX REQUIRED',branch:git('branch','--show-current'),head:git('rev-parse','HEAD'),trackedDiffStat:git('diff','--stat'),stagedDiffStat:git('diff','--cached','--stat'),status:git('status','--short'),sourceHashes,canonicalLogs:logs.length,completeControllerOperations:42,completedSaves:14,completedLoads:28,boundaryCaptures:183,realCpuCaptures:2,boundaryHistoryValues:[...new Set(hist.map(h=>h.ticks))].sort((a,b)=>a-b),cases,cpu,edgeHistory:[edge,bootEdge].flatMap(s=>s.split(/\r?\n/).filter(l=>l.includes('EDGE_HISTORY')||l.includes('PASS F13 edge-history'))),regressions:regNames,logs,F06:'unresolved; untouched',implementation:false,formatChanged:false,quartusBuild:false};
fs.writeFileSync(path.join(d,'results.json'),JSON.stringify(result,null,2)+'\n');
fs.writeFileSync(path.join(d,'git_status.txt'),`branch: ${result.branch}\nHEAD: ${result.head}\ngit diff --stat:\n${result.trackedDiffStat}\ngit diff --cached --stat:\n${result.stagedDiffStat}\ngit status --short:\n${result.status}\n`);
console.log(`PASS ${logs.length} canonical logs, 42 full controller operations, 183 boundary captures, 2 real T80/video captures; tracked/staged diff empty.`);
