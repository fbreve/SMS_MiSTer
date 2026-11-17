const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto'),assert=require('assert'),d=__dirname,root=p.resolve(d,'../..'),prior=p.join(root,'tests/register_memory_auto');
const hash=b=>crypto.createHash('sha256').update(b).digest('hex'),git=(...a)=>cp.execFileSync('git',a,{cwd:root,maxBuffer:64*1024*1024}),rev='8443a0d19a88aff7a5900011bccf386daf146945';
assert(!fs.existsSync(p.join(d,'baseline')),'Never overwrite prepared builds');
const saved=JSON.parse(fs.readFileSync(p.join(root,'tests/register_memory_impl_control/preservation_before.json'))),files={...saved.files};
for(const [f,h]of Object.entries(files))assert.equal(hash(fs.readFileSync(p.join(root,f))),h,f);
function protect(dir){for(const e of fs.readdirSync(p.join(root,dir),{withFileTypes:true})){const f=dir+'/'+e.name;if(e.isFile())files[f]=hash(fs.readFileSync(p.join(root,f)));else if(!['scratch','worktree'].includes(e.name)&&!e.name.endsWith('_work'))protect(f);}}
protect('tests/register_memory_impl_control');
fs.writeFileSync(p.join(d,'preservation_before.json'),JSON.stringify({files,refs:git('show-ref','--heads').toString(),status:git('status','--short').toString()},null,2)+'\n');
const entries=git('ls-tree','-r',rev).toString().trim().split('\n').map(s=>s.match(/^(\d+) (\w+) (\w+)\t(.+)$/)).filter(m=>m[2]==='blob'&&!m[4].startsWith('releases/')),inputs={};
for(const e of entries){const f=e[4],b=git('cat-file','blob',e[3]);inputs[f]={blob:e[3]};for(const v of ['baseline','candidate']){let bytes=b;if(v==='candidate'&&f==='rtl/VM2413/feedbackmemory.vhd'){bytes=Buffer.from(b.toString('latin1').replace(/^ +attribute ramstyle of data_array : signal is "logic";\r?\n/m,''),'latin1');assert(!bytes.equals(b));}const target=p.join(d,v,f);fs.mkdirSync(p.dirname(target),{recursive:true});fs.writeFileSync(target,bytes);inputs[f][v]=hash(bytes);}}
assert.deepEqual(Object.keys(inputs).filter(f=>inputs[f].baseline!==inputs[f].candidate),['rtl/VM2413/feedbackmemory.vhd']);
fs.copyFileSync(p.join(d,'candidate/rtl/VM2413/feedbackmemory.vhd'),p.join(d,'worktree/rtl/VM2413/feedbackmemory.vhd'));
for(const v of ['baseline','candidate']){fs.writeFileSync(p.join(d,v,'build_id.v'),'`define BUILD_DATE "261014"\n');fs.copyFileSync(p.join(root,'tests/timing_history/builds/F/jtag.cdf'),p.join(d,v,'jtag.cdf'));}
fs.writeFileSync(p.join(d,'input_manifest.json'),JSON.stringify({baseline:rev,seed:1,buildDate:'261014',inputs},null,2)+'\n');
for(const f of ['prepare_sim.js','fm_tb.vhd','fm.do','prepare_savestate.js','savestate.do','prepare_savestate_gate.js','savestate_gate.do','run_savestates.ps1','functional_results.js','gate.do'])fs.writeFileSync(p.join(d,f),fs.readFileSync(p.join(prior,f),'utf8').replaceAll('RegisterMemory','FeedbackMemory'));
fs.copyFileSync(p.join(prior,'build.ps1'),p.join(d,'build.ps1'));
fs.copyFileSync(p.join(prior,'.gitignore'),p.join(d,'.gitignore'));
let fm=fs.readFileSync(p.join(prior,'fm_gate.do'),'utf8').replace('if {$source eq "registermemory"}','if {$source eq "feedbackmemory"}').replace('mapped_registermemory.vhd','mapped_feedbackmemory.vhd');fs.writeFileSync(p.join(d,'fm_gate.do'),fm);
fs.writeFileSync(p.join(d,'fm_gate_tb.vhd'),fs.readFileSync(p.join(d,'fm_tb.vhd'),'utf8').replaceAll('fm_tb','fm_gate_tb').replaceAll('candidate_work','mapped_work').replace('PASS full OPLL:','PASS full OPLL with mapped candidate FeedbackMemory:'));
const flat=`library ieee;use ieee.std_logic_1164.all;use ieee.numeric_std.all;use work.vm2413.all;
entity FeedbackMemory_flat is port(clk,reset,wr:in std_logic;waddr:in std_logic_vector(3 downto 0);wdata:in std_logic_vector(9 downto 0);raddr:in std_logic_vector(3 downto 0);rdata:out std_logic_vector(9 downto 0));end;
architecture adapter of FeedbackMemory_flat is signal rd,wd:SIGNED_LI_TYPE;signal wi,ri:CH_TYPE;begin
wi<=to_integer(unsigned(waddr));ri<=to_integer(unsigned(raddr));wd<=CONV_SIGNED_LI(wdata);
u:entity work.FeedbackMemory port map(clk,reset,wr,wi,wd,ri,rd);
rdata<=CONV_SIGNED_LI_VECTOR(rd);end;\n`;
fs.writeFileSync(p.join(d,'FeedbackMemory_flat.vhd'),flat);
const src=fs.readFileSync(p.join(d,'candidate/rtl/VM2413/feedbackmemory.vhd'),'latin1').split(/architecture\s+RTL\b/i)[0];
fs.writeFileSync(p.join(d,'mapped_feedbackmemory.vhd'),src+`architecture mapped of FeedbackMemory is
component FeedbackMemory_gate is port(clk,reset,wr:in std_logic;waddr:in std_logic_vector(3 downto 0);wdata:in std_logic_vector(9 downto 0);raddr:in std_logic_vector(3 downto 0);rdata:out std_logic_vector(9 downto 0));end component;
signal wa,ra:std_logic_vector(3 downto 0);signal wd,rd:std_logic_vector(9 downto 0);
begin wa<=std_logic_vector(to_unsigned(waddr,4));ra<=std_logic_vector(to_unsigned(raddr,4));wd<=CONV_SIGNED_LI_VECTOR(wdata);rdata<=CONV_SIGNED_LI(rd);u:FeedbackMemory_gate port map(clk,reset,wr,wa,wd,ra,rd);end;\n`.replace('architecture mapped','library ieee;use ieee.numeric_std.all;\narchitecture mapped'),'latin1');
console.log({sourceFiles:entries.length,onlyRTLChange:'FeedbackMemory logic attribute deleted',protectedFiles:Object.keys(files).length});
