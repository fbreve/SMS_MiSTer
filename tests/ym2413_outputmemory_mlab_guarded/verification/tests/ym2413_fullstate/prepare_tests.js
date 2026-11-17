const fs=require('fs'),cp=require('child_process'),p=require('path');
const d=__dirname,root=p.resolve(d,'../..'),ref='9873761503510e4b2c7e06600bf5515344235c2f';
const git=(...a)=>cp.execFileSync('git',a,{cwd:"C:\\Users\\fbrev\\Documents\\Diversos\\Dev\\SMS_MiSTer\\tests\\ym2413_outputmemory_mlab_guarded\\worktree",encoding:'latin1'}),put=(n,s)=>fs.writeFileSync(p.join(d,n),s,'latin1');
fs.mkdirSync(p.join(d,'reference'),{recursive:true});
fs.mkdirSync(p.join(d,'candidate'),{recursive:true});
const names=['vm2413','slotcounter','voicerom','voicememory','registermemory','attacktable','envelopememory','envelopegenerator','phasememory','phasegenerator','sinetable','operator','feedbackmemory','outputmemory','lineartable','outputgenerator','temporalmixer','controller','opll'];
function adapt(s){
 s=s.replace(/\bRelease\b/g,'EG_Release').replace(/VOICE_ID_TYPE'range/gi,'0 to 37').replace(/ch_type'range/gi,'0 to 8');
 // Quartus accepts incomplete std_logic case statements; ModelSim requires others.
 let stack=[],insert=[];
 const clean=s.replace(/--[^\r\n]*/g,m=>' '.repeat(m.length));
 for(const m of clean.matchAll(/\bcase\s+[^;\n]+?\bis\b|\bwhen\s+others\b|\bend\s+case\b/gi)){
  if(/^case/i.test(m[0]))stack.push(false);else if(/^when/i.test(m[0]))stack[stack.length-1]=true;else if(!stack.pop())insert.push(m.index);
 }
 for(const i of insert.reverse())s=s.slice(0,i)+'when others => null; '+s.slice(i);
 s=s.replace(/\bprocess\(clk,reset\)/,'oracle_process: process(clk,reset)');
 return s;
}
for(const n of names){
 put('reference/'+n+'.vhd',adapt(git('show',ref+':rtl/VM2413/'+n+'.vhd')));
 put('candidate/'+n+'.vhd',adapt(fs.readFileSync(p.join(root,'rtl/VM2413/'+n+'.vhd'),'latin1')));
}
// Extract the actual production wrapper, not a separately reimplemented model.
function wrapper(source,name){
 const a=source.indexOf('\tfm: work.opll'),b=source.indexOf('FM_gated <=',a);
 let body=source.slice(a,b).replace('fm: work.opll','fm: entity work.opll');
 return `library ieee;use ieee.std_logic_1164.all;use work.vm2413.all;
entity ${name} is port(clk_sys,RESET_n,ce_raw,ss_freeze,fm_initialization_run,fm_legacy_reset,fm_ena:in std_logic;
 D_in:in std_logic_vector(7 downto 0);A:in std_logic_vector(15 downto 0);fm_WR_n:in std_logic;
 fm_state_addr:in std_logic_vector(7 downto 0);fm_state_read,fm_state_write:in std_logic;
 fm_state_wdata:in std_logic_vector(31 downto 0);fm_state_rdata:out std_logic_vector(31 downto 0);
 fm_initialized:out std_logic;FM_out:out std_logic_vector(13 downto 0);audible:out std_logic_vector(12 downto 0));end;
architecture test of ${name} is
 signal ce_cpu,fm_a:std_logic;signal fm_d:std_logic_vector(7 downto 0);
 signal fm_local_rdata,fm_wrapper_rdata:std_logic_vector(31 downto 0);
 signal FM_gated:std_logic_vector(12 downto 0);
 alias FM_sign:std_logic is FM_out(13);alias FM_adj:std_logic is FM_out(12);
 constant mapper_evolution:std_logic:='0';constant det_D:std_logic_vector(2 downto 0):="001";
begin
 ce_cpu<=ce_raw and not ss_freeze;
${body}
${source.slice(b,source.indexOf(';',b)+1)}
audible<=FM_gated;
end;
`;
}
put('candidate_wrapper.vhd',wrapper(fs.readFileSync(p.join(root,'rtl/system.vhd'),'latin1'),'candidate_wrapper'));
put('reference_wrapper.vhd',wrapper(git('show',ref+':rtl/system.vhd'),'reference_wrapper'));
// Only move forward declarations for ModelSim. The synthesized file is unchanged.
let src=fs.readFileSync(p.join(root,'rtl/savestates.sv'),'latin1');
for(const n of ['mapper_snap','evolution_snap','dout_latch']){const re=new RegExp('^reg\\s+\\[[^\\]]+\\]\\s+'+n+';\\r?\\n','m');const m=src.match(re);if(!m)throw Error(n);src=src.replace(re,'').replace('// Helpers',m[0]+'// Helpers');}
put('savestates_sim.sv',src);
let base=git('show','66f16d5c656fd8906d62570da4d258875bcee684:rtl/savestates.sv');
for(const n of ['mapper_snap','evolution_snap']){const re=new RegExp('^reg\\s+\\[[^\\]]+\\]\\s+'+n+';\\r?\\n','m');const m=base.match(re);base=base.replace(re,'').replace('// NVRAM size calculation helpers',m[0]+'// NVRAM size calculation helpers');}
put('master_savestates.sv',base.replace('module savestates (','module master_savestates ('));
const ports=[];
for(const m of src.split(');')[0].replace(/\/\/[^\n]*/g,'').matchAll(/\b(input|output)\s+(?:reg\s+)?(\[[^\]]+\]\s*)?([\s\S]*?)(?=\binput\b|\boutput\b|$)/g))
 for(const n of m[3].split(',').map(x=>x.trim()).filter(Boolean))ports.push(['',m[1],m[2],n]);
const driven=new Set(['fm_state_rdata','fm_initialized']);
put('ports.svh',ports.map(([,kind,w,n])=>`${kind==='input'&&!driven.has(n)?'reg':'wire'} ${w||''}${n}${kind==='input'&&!driven.has(n)?"='0":''};`).join('\n')+'\nsavestates dut('+ports.map(x=>'.'+x[3]+'('+x[3]+')').join(',')+');\n');
put('compile.do',`onerror {quit -code 1}
onbreak {quit -code 1}
vlib candidate_work
vlib reference_work
vlib test_work
vmap candidate_work candidate_work
vmap reference_work reference_work
vmap test_work test_work
vcom -2008 -quiet -work candidate_work ${names.map(n=>'candidate/'+n+'.vhd').join(' ')} candidate_wrapper.vhd
vcom -2008 -quiet -work reference_work ${names.map(n=>'reference/'+n+'.vhd').join(' ')} reference_wrapper.vhd
vlog -sv -quiet -work test_work ../../rtl/opll_snapshot.sv savestates_sim.sv master_savestates.sv tb.sv
quit -code 0
`);
put('.gitignore','candidate_work/\nreference_work/\ntest_work/\nfast_work/\ntranscript\n*.wlf\nmodelsim.ini\nreference/\ncandidate/\n');
put('source_identity.json',JSON.stringify({baseline:git('rev-parse','HEAD').trim(),reference:ref,names,wrapper:'extracted from production system.vhd including FM gating; ce_cpu gated as SMS.sv',simulationAdapters:['Release renamed to EG_Release','integer subtype range expanded to equivalent bounds','when others => null added for meta-valued case coverage','main process labeled for read-only internal variable access','fm: work.opll made an explicit entity instantiation','move mapper_snap/evolution_snap/dout_latch declarations for ModelSim'],fastOnly:'FLUSH_MAX reduced from900000 to90; native test keeps900000'},null,2));
put('savestates_fast.sv',src.replace("20'd900000","20'd90"));
put('fast_compile.do',`onerror {quit -code 1}
vlib fast_work
vmap fast_work fast_work
vlog -sv -quiet -work fast_work ../../rtl/opll_snapshot.sv savestates_fast.sv tb.sv
quit -code 0
`);
console.log('Prepared pinned source libraries and actual-wrapper fixtures');
