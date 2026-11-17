const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto'),assert=require('assert');
const d=__dirname,root=p.resolve(d,'../../..'),master='66f16d5c656fd8906d62570da4d258875bcee684',history='1b2a52d87d2659c908d4f9f846416d14bfd85bea';
const git=(...a)=>cp.execFileSync('git',a,{cwd:root,encoding:'utf8',maxBuffer:20*1024*1024});
const get=(ref,f)=>git('show',ref+':'+f).replace(/\r\n/g,'\n');
const sha=s=>crypto.createHash('sha256').update(s).digest('hex');
const put=(f,s)=>fs.writeFileSync(p.join(d,f),s);
const adapt=s=>s.replace(/:\s*work\.(\w+)/g,': entity work.$1').replace('ioq and x"7"','ioq and "000000111"'); // explicit zero-extension for ModelSim
const manifest={master,history,checkout:git('rev-parse','HEAD').trim(),masterRef:git('rev-parse','master').trim(),branchRef:git('rev-parse','investigate/cram-memory-inference').trim(),trackedStatus:git('status','--porcelain','--untracked-files=no').trim(),sources:{},historicalCommits:{}};
for(const c of ['8ffd15e2','58583189','f205b05d','faf7036e']){manifest.historicalCommits[c]=git('show','-s','--format=%H %s',c).trim();put('history_'+c+'.diff',git('show','--format=fuller',c,'--','SMS.sv','rtl'));}
for(const f of ['T80_Reg.vhd','T80_MCode.vhd','T80_ALU.vhd'])put(f,get(master,'rtl/T80/'+f));
let cpu=get(master,'rtl/T80/T80.vhd');
cpu=cpu.replace('DIRSet     : in',`RestartContext : out std_logic_vector(2 downto 0);
 RestartDIR : in std_logic_vector(2 downto 0) := "000";
 RestartValid : in std_logic := '0';
 DIRSet     : in`);
cpu=cpu.replace('ISet_out <= ISet;',`ISet_out <= ISet;
 RestartContext <= "001" when IR=x"CB" else "010" when IR=x"ED" else
 "011" when IR=x"DD" else "100" when IR=x"FD" else "101" when IR=x"FB" else "000";`);
const at=cpu.indexOf("if DIRSet = '1' then"),ir=cpu.indexOf('IR <= "00000000";',at);assert(ir>at);
cpu=cpu.slice(0,ir)+cpu.slice(ir).replace('IR <= "00000000";',`IR <= x"00";
 if RestartValid='1' then
 case RestartDIR is
 when "001" => IR <= x"CB"; when "010" => IR <= x"ED";
 when "011" => IR <= x"DD"; when "100" => IR <= x"FD";
 when "101" => IR <= x"FB"; when others => null;
 end case; end if;`);
let wrap=get(master,'rtl/T80/T80s.vhd');
wrap=wrap.replace('DIRSet     : in',`RestartContext : out std_logic_vector(2 downto 0);
 RestartDIR : in std_logic_vector(2 downto 0) := "000";
 RestartValid : in std_logic := '0';
 NMIState : out std_logic_vector(2 downto 0);
 NMIDIR : in std_logic_vector(2 downto 0) := "001";
 NMIValid, NMIEnable, NMIHold, RestoreHold : in std_logic := '0';
 ReplayT2 : in std_logic := '1'; NMIReplay : out std_logic;
 DIRSet     : in`);
wrap=wrap.replace('DIRSet => DIRSet,','RestartContext=>RestartContext, RestartDIR=>RestartDIR, RestartValid=>RestartValid, DIRSet => DIRSet,');
wrap=wrap.replace('begin\n','begin\n NMIState <= "001"; NMIReplay <= \'0\';\n');
// Observation-only ports allow exact canonical comparisons without forcing state.
function debug(s,iswrap){s=s.replace('DIRSet     : in',`TestIR : out std_logic_vector(7 downto 0);
 TestMC,TestTS : out std_logic_vector(2 downto 0);
 DIRSet     : in`);
 if(iswrap)s=s.replace('DIRSet => DIRSet,','TestIR=>TestIR,TestMC=>TestMC,TestTS=>TestTS,DIRSet => DIRSet,');
 else s=s.replace('ISet_out <= ISet;','ISet_out <= ISet; TestIR<=IR;TestMC<=MCycle;TestTS<=std_logic_vector(TState);');return s;}
put('T80_context.vhd',adapt(debug(cpu,false).replace(/\bT80\b/g,'T80_context')));
put('T80s_context.vhd',adapt(debug(wrap,true).replace(/\bT80s\b/g,'T80s_context').replace(/work\.T80\b/g,'work.T80_context')));
put('T80_historical.vhd',adapt(debug(get(history,'rtl/T80/T80.vhd'),false).replace(/\bT80\b/g,'T80_historical')));
put('T80s_historical.vhd',adapt(debug(get(history,'rtl/T80/T80s.vhd'),true).replace(/\bT80s\b/g,'T80s_historical').replace(/work\.T80\b/g,'work.T80_historical')));
for(const f of ['rtl/T80/T80.vhd','rtl/T80/T80s.vhd','rtl/savestates.sv','SMS.sv','rtl/vdp_background.vhd','rtl/vdp.vhd'])manifest.sources[f]={master:sha(get(master,f)),history:sha(get(history,f))};
const diff=cp.spawnSync('git',['diff','--no-index','--',p.join(root,'rtl/T80/T80.vhd'),p.join(d,'T80_context.vhd')],{encoding:'utf8'});assert(diff.status===1);put('context_only.diff',diff.stdout);
put('manifest.json',JSON.stringify(manifest,null,2)+'\n');
console.log('Prepared master-based context-only CPU, historical CPU +/- context, no production changes.');
