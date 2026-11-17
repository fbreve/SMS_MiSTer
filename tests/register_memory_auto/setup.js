// Create independent, byte-preserving RegisterMemory AUTO experiment fixtures.
const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto'),assert=require('assert');
const d=__dirname,root=p.resolve(d,'../..'),old=p.join(root,'tests/phase_memory_auto');
const hash=b=>crypto.createHash('sha256').update(b).digest('hex');
const git=(...a)=>cp.execFileSync('git',a,{cwd:root,maxBuffer:64*1024*1024});
assert(!fs.existsSync(p.join(d,'baseline')),'Never overwrite builds');
const before={refs:{},files:{}};
for(const line of git('for-each-ref','--format=%(refname) %(objectname)','refs/heads').toString().trim().split('\n')){const [r,h]=line.trim().split(' ');before.refs[r]=h;}
function protect(dir){for(const e of fs.readdirSync(p.join(root,dir),{withFileTypes:true})){const rel=dir+'/'+e.name;if(e.isFile())before.files[rel]=hash(fs.readFileSync(p.join(root,rel)));else if(!['baseline','candidate','gate_candidate','baseline_sim','candidate_sim'].includes(e.name)&&!e.name.endsWith('_work'))protect(rel);}}
for(const dir of ['tests/phase_memory_auto','tests/phase_memory_auto_seed2','tests/synthesis_structure'])protect(dir);
before.files['rtl/VM2413/phasememory.vhd']=hash(fs.readFileSync(p.join(root,'rtl/VM2413/phasememory.vhd')));
fs.writeFileSync(p.join(d,'preservation_before.json'),JSON.stringify(before,null,2)+'\n');
let prep=fs.readFileSync(p.join(old,'prepare.js'),'utf8');
// Keep original source materialization and provenance, using Latin-1 for Japanese comments.
prep=prep.slice(0,prep.indexOf('const previous='))+prep.slice(prep.indexOf('const manifest='));
prep=prep.replaceAll('phase_array','regs_array').replaceAll('phasememory.vhd','registermemory.vhd').replace('bytes.toString().replace','Buffer.from(bytes.toString("latin1").replace').replace("/m,''):bytes", "/m,''),'latin1'):bytes");
prep=prep.replace('/^  attribute ramstyle','/^ +attribute ramstyle');
prep=prep.replace('refs:preservation.refs','refs:JSON.parse(fs.readFileSync(p.join(out,"preservation_before.json"))).refs');
fs.writeFileSync(p.join(d,'prepare.js'),prep);
for(const file of ['prepare_sim.js','fm_tb.vhd','fm.do','prepare_savestate.js','savestate.do','prepare_savestate_gate.js','savestate_gate.do','gate.do','gate_build.ps1','prepare_gate.js','prepare_mapped_sim.js','fm_gate.do']){
 let s=fs.readFileSync(p.join(old,file),'utf8').replaceAll('PhaseMemory','RegisterMemory').replaceAll('phasememory','registermemory');
 if(file==='prepare_mapped_sim.js')s=s.replace("original.split('architecture RTL')[0]","original.split(/architecture\\s+rtl\\b/i)[0]");
 if(['prepare_gate.js','prepare_mapped_sim.js'].includes(file))s=s.replaceAll('slot:in std_logic_vector(4 downto 0);memwr:in std_logic;memout:out std_logic_vector(17 downto 0);memin:in std_logic_vector(17 downto 0)','addr:in std_logic_vector(3 downto 0);wr:in std_logic;idata:in std_logic_vector(23 downto 0);odata:out std_logic_vector(23 downto 0)').replaceAll('clk,reset,slot,memwr,memout,memin','clk,reset,addr,wr,idata,odata');
 if(file==='fm.do'||file==='fm_gate.do')s=s.replace('envelopegenerator registermemory phasegenerator','envelopegenerator phasememory phasegenerator');
 fs.writeFileSync(p.join(d,file),s);
}
fs.copyFileSync(p.join(root,'tests/phase_memory_auto_seed2/build.ps1'),p.join(d,'build.ps1'));
let tb=fs.readFileSync(p.join(old,'bank_tb.vhd'),'utf8').replaceAll('PhaseMemory','RegisterMemory').replaceAll('4 downto 0','3 downto 0').replaceAll('17 downto 0','23 downto 0').replaceAll('0 to 17','0 to 8').replaceAll('0 to 18','0 to 9').replaceAll('init<18','init<9').replaceAll('mod 18','mod 9').replaceAll('262144,18','16777216,24').replaceAll('262143','16777215').replaceAll('to_unsigned(addr,5)','to_unsigned(addr,4)').replaceAll('tick(17','tick(8').replaceAll('17-i','8-i').replaceAll('all18','all9').replaceAll(';18 payload bits;19',';24 payload bits;10').replaceAll('port map(clk,reset,slot,wr,qa,din)','port map(clk,reset,slot,wr,din,qa)').replaceAll('port map(clk,reset,slot,wr,qb,din)','port map(clk,reset,slot,wr,din,qb)').replaceAll('rng(26 downto 9)','rng(31 downto 8)');
tb=tb.replace('for bitno in 0 to 8','for bitno in 0 to 23');
fs.writeFileSync(p.join(d,'bank_tb.vhd'),tb);
fs.writeFileSync(p.join(d,'bank.do'),fs.readFileSync(p.join(old,'bank.do'),'utf8').replaceAll('phasememory.vhd','registermemory.vhd'));
fs.writeFileSync(p.join(d,'.gitignore'),fs.readFileSync(p.join(old,'.gitignore'),'utf8')+'worktree/\n');
let measure=fs.readFileSync(p.join(old,'measure.js'),'utf8').replaceAll('PhaseMemory','RegisterMemory').replaceAll('phasememory','registermemory').replaceAll('phase_array','regs_array').replaceAll('phaseHierarchy','registerHierarchy').replaceAll('phaseRamRows','registerRamRows').replaceAll('phaseParameters','registerParameters');
measure=measure.replace("['diff','--','rtl/VM2413/registermemory.vhd'],{cwd:root}","['diff','--','rtl/VM2413/registermemory.vhd'],{cwd:p.join(d,'worktree')}");
fs.writeFileSync(p.join(d,'measure.js'),measure);
console.log('Independent RegisterMemory fixtures prepared; production edit not yet applied.');
