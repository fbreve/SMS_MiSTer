const fs=require('fs'),path=require('path');
const d=__dirname,r=path.resolve(d,'../..'),old=path.join(r,'tests/savestate_mapper_detection_fix');
fs.mkdirSync(d,{recursive:true});
let ss=fs.readFileSync(path.join(r,'rtl/savestates.sv'),'utf8');
for(const n of ['mapper_snap','evolution_snap']) {const re=new RegExp('^reg\\s+\\[[^\\]]+\\]\\s+'+n+';\\r?\\n','m'),decl=ss.match(re)[0];ss=ss.replace(re,'').replace('// NVRAM size calculation helpers',decl+'// NVRAM size calculation helpers');}
fs.writeFileSync(path.join(d,'savestates_sim.sv'),ss);
let prefix=fs.readFileSync(path.join(r,'tests/savestate_hcounter/controller_tb.sv'),'utf8').split('reg [63:0] video_saved;')[0].replace('module controller_tb;','module evolution_tb;\nparameter CASE=0;');
prefix=prefix.replace("reg [63:0] mapper_out = '0;",'wire [63:0] mapper_out;').replace("reg [95:0] evolution_out = '0;",'wire [95:0] evolution_out;');
prefix=prefix.replace('.ss_freeze(ss_freeze),',".ss_freeze(ss_freeze),.ss_capture_progress(),.mapper_history_out(18'h0ffff),.mapper_history_in(),");
prefix=prefix.replace('if(saving)ss_save=1;','tick;if(saving)ss_save=1;');
prefix=prefix.replace("reg z80_m1_n = '0;",'wire z80_m1_n;').replace("reg z80_mreq_n = '0;",'wire z80_mreq_n;');
prefix=prefix.replace('force dut.op_cooldown=0;','boundary;\n force dut.op_cooldown=0;');
fs.writeFileSync(path.join(d,'evolution_tb.sv'),prefix+fs.readFileSync(path.join(d,'scenario.sv.in'),'utf8'));
fs.writeFileSync(path.join(d,'run.do'),`onerror {quit -code 1}
onbreak {quit -code 1}
vlib evolution_work
vcom -work evolution_work -2008 -quiet ../../rtl/evolution_mapper.vhd ../../rtl/evolution_rom_address.vhd
vlog -work evolution_work -sv -quiet savestates_sim.sv evolution_machine.sv evolution_tb.sv
vsim -c -t 1ps -voptargs=+acc evolution_work.evolution_tb -gCASE=$env(F14_CASE)
set NumericStdNoWarnings 1
run -all
quit -code 0
`);
// Immutable source-only copies of the F13 regression adapters: no semantic edits.
for(const name of ['savestate_hcounter','savestate_md6','savestate_master_tap','savestate_paddle','savestate_lightgun_fix','savestate_systeme_pause_fix']) {
 const src=path.join(old,'regressions',name),dst=path.join(d,'regressions',name);fs.mkdirSync(dst,{recursive:true});
 for(const ent of fs.readdirSync(src,{withFileTypes:true}))if(ent.isFile()&&/\.(sv|vhd|v|do|mif)$/.test(ent.name))fs.copyFileSync(path.join(src,ent.name),path.join(dst,ent.name));
}
for(const n of ['mapper_ctrl_sim.vhd','banking_tb.vhd','banking_current.do','machine.sv','history_tb.sv','run.do'])fs.copyFileSync(path.join(old,n),path.join(d,'f13_'+n));
let f13=fs.readFileSync(path.join(d,'f13_run.do'),'utf8').replaceAll('mapper_ctrl_sim.vhd','f13_mapper_ctrl_sim.vhd').replaceAll('machine.sv','f13_machine.sv').replaceAll('history_tb.sv','f13_history_tb.sv').replaceAll('work','f13_work');
// Replace-all above names the library but also the -work flag; repair it.
f13=f13.replaceAll('-f13_work','-work').replace('vcom -2008','vcom -work f13_work -2008').replace('vlog -sv','vlog -work f13_work -sv');
fs.writeFileSync(path.join(d,'f13_run.do'),f13);
fs.writeFileSync(path.join(d,'banking.do'),fs.readFileSync(path.join(d,'f13_banking_current.do'),'utf8').replaceAll('mapper_ctrl_sim.vhd','f13_mapper_ctrl_sim.vhd').replaceAll('banking_tb.vhd','f13_banking_tb.vhd'));
