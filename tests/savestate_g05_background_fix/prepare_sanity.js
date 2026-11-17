const fs=require('fs'),p=require('path'),d=__dirname,root=p.resolve(d,'../..'),old=p.join(root,'tests/savestate_g06_g10_fix'),adapter=require('../savestate_g06_g10_fix/controller_adapter');
function read(f){return fs.readFileSync(f,'utf8').replace(/\r\n/g,'\n');}
const ports='debug_ctx : out std_logic_vector(63 downto 0); debug_nmi : out std_logic_vector(12 downto 0); debug_old : out std_logic;\n';
function cpu(dst,src){for(const [file,out] of [['T80.vhd','T80_integrated.vhd'],['T80s.vhd','T80s_integrated.vhd']]){let s=read(p.join(root,'rtl/T80',file)).replace('DIRSet     :',ports+'DIRSet     :');
 s=s.replace(/:\s*(?:work\.)?(T80(?:_MCode|_ALU|_Reg)?)\b/g,': entity work.$1');
 if(file==='T80.vhd'){const donor=read(p.join(src,out));let obs=donor.slice(donor.indexOf(' debug_ctx <='),donor.indexOf('\n\tREG <='));if(!obs.includes('debug_old'))throw Error('observation anchor');s=s.replace('\tREG <=',obs+'\n\tREG <=');}
 else s=s.replace('DIRSet => DIRSet,','debug_ctx => debug_ctx, debug_nmi => debug_nmi, debug_old => debug_old, DIRSet => DIRSet,');
 fs.writeFileSync(p.join(dst,out),s);
}}
function prepare(kind,files){const src=p.join(old,'candidate_'+kind),dst=p.join(d,'sanity_'+kind);fs.mkdirSync(dst,{recursive:true});for(const file of files){let s=read(p.join(src,file)).replaceAll("24'h48430e","24'h48430f").replaceAll('v14 writer tag','v15 writer tag').replaceAll('v14 payload','v15 payload');s=s.replace('savestates dut(',"savestates #(.TB_FAST(1)) dut(.bg_out(139'd0),.bg2_out(139'd0),.bg_in(),.bg2_in(),.bg_valid(),");
 if(kind==='nmi'&&file==='fixed_tb.sv')s=s.replace('if(FORMAT==12)begin',"if(FORMAT==14)mem['h1a][63:40]=24'h48430e;\n if(FORMAT==12)begin").replaceAll('FORMAT==0||FORMAT==12','FORMAT==0||FORMAT==12||FORMAT==14');fs.writeFileSync(p.join(dst,file),s);}
 cpu(dst,src);fs.writeFileSync(p.join(dst,'savestates_integrated.sv'),adapter(p.join(root,'rtl/savestates.sv')));
 let c=read(p.join(src,'run.do')).split('\nvsim ')[0]+'\nquit -code 0\n';fs.writeFileSync(p.join(dst,'compile.do'),c);return dst;}
const g01=prepare('g01',['integrated_machine.sv','io_instance.sv','mapper_ctrl_observed.vhd','mapping.sv','trace_tb.sv']);
const nmi=prepare('nmi',['machine.sv','io_instance.sv','fixed_tb.sv']);
function cases(dst,lib,items){fs.writeFileSync(p.join(dst,'cases.json'),JSON.stringify(items,null,2));for(const c of items){const args=Object.entries(c.args).map(([k,v])=>'-g'+k+'='+v).join(' ');fs.writeFileSync(p.join(dst,c.id+'.do'),`onerror {quit -code 1}\nonbreak {quit -code 1}\nvsim -c -t 1ps -L altera_mf ${lib} ${args}\nset NumericStdNoWarnings 1\nset StdArithNoWarnings 1\nrun -all\nquit -code 0\n`);}}
cases(g01,'trace_work.fixed_tb',JSON.parse(read(p.join(old,'matrix_g01/cases.json'))).filter(c=>[1,4,9,45,64].includes(c.id)));
const names=['nmi_final_both_released','nmi_final_replay_both_pending_entry','nmi_final_replay_gg_edge-15','nmi_final_replay_old_needed_held','nmi_final_replay_sms_edge-121','nmi_final_replay_sms_edge-30','nmi_final_replay_sms_edge0','nmi_final_replay_sms_held-60'];
let ns=JSON.parse(read(p.join(old,'matrix_nmi/cases.json'))).filter(c=>names.includes(c.id));if(ns.length!==8)throw Error('NMI case selection '+ns.length);ns.push({id:'v14_compat',args:{...ns[0].args,FORMAT:14}},{id:'legacy64_compat',args:{...ns[0].args,FORMAT:99}});cases(nmi,'final_work.fixed_tb',ns);
const pause=p.join(d,'sanity_pause'),ps=p.join(old,'pause_known');fs.mkdirSync(pause,{recursive:true});for(const file of ['fixed_tb.sv','pause_fixture.sv','rom.hex','compile.do','T80_sim.vhd','T80s_sim.vhd']){let s=read(p.join(ps,file));if(file==='fixed_tb.sv')s=s.replace(/savestates\s+dut\(/,"savestates dut(.bg_out(139'd0),.bg2_out(139'd0),.bg_in(),.bg2_in(),.bg_valid(),");fs.writeFileSync(p.join(pause,file),s);}
fs.writeFileSync(p.join(pause,'savestates_sim.sv'),adapter(p.join(root,'rtl/savestates.sv')));
cases(pause,'pause_work.pause_tb',[{id:'paused_m1',args:{CASE:3,DELAY:36}},{id:'paused_nonm1',args:{CASE:4,DELAY:6}},{id:'load_current_pause',args:{CASE:7,DELAY:6}},{id:'load_current_running',args:{CASE:8,DELAY:6}}].map(c=>({id:c.id,args:{...c.args,FULL:0,'/pause_tb/dut/TB_FAST':1}})));
console.log('Prepared fresh v15 CPU, NMI and current-Pause sanity fixtures');
