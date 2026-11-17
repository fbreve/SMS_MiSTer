const fs=require('fs'),path=require('path');
const dir=__dirname,root=path.resolve(dir,'../..');
let ss=fs.readFileSync(path.join(root,'rtl/savestates.sv'),'utf8');
for(const n of ['mapper_snap','evolution_snap']){let re=new RegExp('^reg\\s+\\[[^\\]]+\\]\\s+'+n+';\\r?\\n','m'),d=ss.match(re)[0];ss=ss.replace(re,'').replace('// NVRAM size calculation helpers',d+'// NVRAM size calculation helpers');}
fs.writeFileSync(path.join(dir,'savestates_sim.sv'),ss);
// Existing production 2-bit std_logic case choices omit meta-values. Match the
// established mapper simulation adapter: no action for non-binary selectors.
let ctrl=fs.readFileSync(path.join(root,'rtl/mapper_ctrl.vhd'),'utf8').replace(/(case A\(1 downto 0\) is[\s\S]*?)(\s*end case;)/g,(m,a,b)=>/when others/i.test(a)?m:a+'\n when others => null;'+b);
fs.writeFileSync(path.join(dir,'mapper_ctrl_sim.vhd'),ctrl);
let signals=new Map(),instances=[];
const external=new Set(['clk_sys','ROMCL','ROMAD','ROMDT','ROMEN','RESET_n','ss_freeze','bootloader_n','A','D_in','WR_n','MREQ_n','mapper_set','mapper_in']);
const ones=new Set(['ce_z80','dbr']);
for(const mod of ['mapper_detect','mapper_ctrl','memory_decode']){
 let src=fs.readFileSync(path.join(root,'rtl',mod+'.vhd'),'utf8').split(/end (?:entity|mapper_detect)/i)[0].replace(/--[^\r\n]*/g,'');
 let ports=[...src.matchAll(/(\w+)\s*:\s*(in|out)\s+(std_logic_vector\((\d+) downto (\d+)\)|std_logic)/gi)].map(m=>({n:m[1],d:m[2].toLowerCase(),w:m[4]?`[${m[4]}:${m[5]}]`:''}));
 let conn=ports.map(p=>{let n=p.n.replace(/_out$|_o$/,'');if(!signals.has(n))signals.set(n,{w:p.w,out:false});if(p.d==='out')signals.get(n).out=true;return `.${p.n}(${n})`;});
 instances.push(`${mod} ${mod}_inst(${conn.join(',')});`);
}
let decl=[...signals].filter(([n])=>!external.has(n)).map(([n,p])=>`wire ${p.w} ${n}${p.out?'':` = ${ones.has(n)?"'1":"'0"}`};`).join('\n');
let pack=`{detect_linear,detect_wonderkid,detect_castle,mapper_codies_lock,lock_mapper_B,mapper_codies,mapper_4pak,1'b0,detect_zemina_static,bootloader_n,nvram_cme,nvram_p,nvram_ex,nvram_e,detect_sega_locked,mapper_dahjee_a,nem_bank0,pak4_reg2,bank3,bank2,bank1,bank0}`;
fs.writeFileSync(path.join(dir,'machine.sv'),`module machine(input clk_sys,ROMCL,input[24:0]ROMAD,input[7:0]ROMDT,input ROMEN,RESET_n,ss_freeze,bootloader_n,input[15:0]A,input[7:0]D_in,input WR_n,MREQ_n,mapper_set,input[63:0]mapper_in,output[63:0]state_out,output[21:0]rom_address,output dahjee,output sega_seen,output[7:0]read_data);\n${decl}\n${instances.join('\n')}\nassign state_out=${pack};\nassign rom_address=rom_a_i;assign dahjee=dahjee_cart_access;assign sega_seen=sega_mapper_write_seen;\n// Synthetic cartridge byte is physical 16KB page; distinct pages expose mapping changes.\nassign read_data=rom_a_i[21:14];\nendmodule\n`);
// Reuse the established DDR transport/declaration prefix; connect the F12
// capture-progress output explicitly (unused in these ordinary SMS cases).
let prefix=fs.readFileSync(path.join(root,'tests/savestate_hcounter/controller_tb.sv'),'utf8').split('reg [63:0] video_saved;')[0];
prefix=prefix.replace('module controller_tb;','module history_tb;\nparameter CASE=0;');
prefix=prefix.replace(/reg \[63:0\] mapper_out = '0;/,'wire [63:0] mapper_out;');
prefix=prefix.replace('if(saving)ss_save=1;', 'tick;if(saving)ss_save=1;');
prefix=prefix.replace('.ss_freeze(ss_freeze),','.ss_freeze(ss_freeze),.ss_capture_progress(),');
let banking=fs.readFileSync(path.join(root,'simulation/mapper_banking/tb.vhd'),'utf8');
banking=banking.replace(/(dut: entity work.mapper_ctrl port map[^;]+);/,m=>m.replace('evolution_ss_in => evolution_ss_in, ',''));
// Historical differential oracle predates EEPROM fallback simplification; retain
// every existing directed assertion, exclude its stale random comparison phase.
banking=banking.split('for i in 0 to 19999 loop')[0]+'report "PASS current mapper directed regression complete"; wait; end process; end;';
fs.writeFileSync(path.join(dir,'banking_tb.vhd'),banking);
fs.writeFileSync(path.join(dir,'history_tb.sv'),prefix+fs.readFileSync(path.join(dir,'scenario.sv.in'),'utf8'));
fs.writeFileSync(path.join(dir,'run.do'),`onerror {quit -code 1}\nonbreak {quit -code 1}\nvlib work\nvcom -2008 -quiet ../../rtl/mapper_detect.vhd mapper_ctrl_sim.vhd ../../rtl/memory_decode.vhd\nvlog -sv -quiet savestates_sim.sv machine.sv history_tb.sv\nvsim -c -t 1ps -voptargs=+acc work.history_tb -gCASE=$env(F13_CASE)\nset NumericStdNoWarnings 1\nrun -all\nquit -code 0\n`);
