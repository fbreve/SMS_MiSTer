const fs=require('fs'),path=require('path'),cp=require('child_process'),d=__dirname,r=path.resolve(d,'../..'),prior=path.join(r,'tests/savestate_evolution_selector'),f13=path.join(r,'tests/savestate_mapper_detection_fix');
const write=(n,s)=>fs.writeFileSync(path.join(d,n),s),read=(dir,n)=>fs.readFileSync(path.join(dir,n),'utf8');
let ss=read(r,'rtl/savestates.sv');for(const n of ['mapper_snap','evolution_snap']){const re=new RegExp('^reg\\s+\\[[^\\]]+\\]\\s+'+n+';\\r?\\n','m'),decl=ss.match(re)[0];ss=ss.replace(re,'').replace('// NVRAM size calculation helpers',decl+'// NVRAM size calculation helpers');}write('savestates_sim.sv',ss);
let tb=read(prior,'evolution_tb.sv').split('reg mrst=')[0].replace('module evolution_tb;','module evolution_fixed_tb;\nparameter STALL=0;');
tb=tb.replace('wire [95:0] evolution_out;','wire [159:0] evolution_out;').replace('wire [95:0] evolution_in;','wire [159:0] evolution_in;');
tb=tb.replace('pending<=3;readaddr', 'pending<=STALL?3+cycle%7:3;readaddr');
write('evolution_fixed_tb.sv',tb+read(d,'scenario.sv.in'));
write('evolution_machine.sv',read(prior,'evolution_machine.sv').replace('input[95:0]ein','input[159:0]ein'));
write('history_tb.sv',read(prior,'history_tb.sv').replace(".ein(96'd0)",".ein(160'd0)"));write('history.do',read(prior,'history.do'));
let script=read(prior,'run.do').replaceAll('evolution_work','fixed_work').replaceAll('evolution_tb','evolution_fixed_tb').replace('-gCASE=$env(F14_CASE)','-gCASE=$env(F14_CASE) -gSTALL=$env(F14_STALL)');write('run.do','if {![info exists env(F14_STALL)]} {set env(F14_STALL) 0}\n'+script);
// Preserve executable pre-fix reproducer against immutable committed F13 RTL.
const base=path.join(d,'baseline');fs.mkdirSync(base,{recursive:true});
for(const n of ['evolution_mapper.vhd','evolution_rom_address.vhd','savestates.sv']){
 let s=cp.execFileSync('git',['show','eede89d:rtl/'+n],{cwd:r,encoding:'utf8',stdio:['ignore','pipe','pipe']});
 if(n==='savestates.sv')for(const v of ['mapper_snap','evolution_snap']){const re=new RegExp('^reg\\s+\\[[^\\]]+\\]\\s+'+v+';\\r?\\n','m'),decl=s.match(re)[0];s=s.replace(re,'').replace('// NVRAM size calculation helpers',decl+'// NVRAM size calculation helpers');}
 fs.writeFileSync(path.join(base,n),s);
}
for(const n of ['evolution_tb.sv','evolution_machine.sv'])fs.copyFileSync(path.join(prior,n),path.join(base,n));
write('pre.do',read(prior,'run.do').replaceAll('evolution_work','pre_work').replace('../../rtl/evolution_mapper.vhd','baseline/evolution_mapper.vhd').replace('../../rtl/evolution_rom_address.vhd','baseline/evolution_rom_address.vhd').replace('savestates_sim.sv','baseline/savestates.sv').replace('evolution_machine.sv','baseline/evolution_machine.sv').replace('evolution_tb.sv','baseline/evolution_tb.sv'));
// Full established regression set: advance current writer / future rejection
// only; legacy vectors are independently covered by the format matrices.
const names=['savestate_hcounter','savestate_gg_io','savestate_md6','savestate_master_tap','savestate_paddle','savestate_eeprom','savestate_sc_ram','savestate_lightgun_fix','savestate_systeme_pause_fix','savestate_coverage','sram_architecture'];
for(const name of names){let dest=path.join(d,'regressions',name);fs.mkdirSync(dest,{recursive:true});for(const e of fs.readdirSync(path.join(f13,'regressions',name),{withFileTypes:true}))if(e.isFile()&&/\.(sv|vhd|v|do|mif)$/.test(e.name)){
 let s=read(path.join(f13,'regressions',name),e.name);if(/\.(sv|do)$/.test(e.name))s=s.replaceAll('48430a','48430b').replaceAll('484309','48430a');if(e.name==='savestates_sim.sv')s=ss;fs.writeFileSync(path.join(dest,e.name),s);
}}
fs.mkdirSync(path.join(d,'rtl'),{recursive:true});for(const n of fs.readdirSync(path.join(r,'rtl')))if(n.endsWith('.mif'))fs.copyFileSync(path.join(r,'rtl',n),path.join(d,'rtl',n));
for(const n of ['f13_machine.sv','f13_history_tb.sv','f13_mapper_ctrl_sim.vhd','f13_banking_tb.vhd','f13_run.do','banking.do'])write(n,n==='f13_history_tb.sv'?read(prior,n).replaceAll('484309','48430a'):read(prior,n));
write('regressions.ps1',read(f13,'regressions.ps1').replace("$ErrorActionPreference='Stop'", "$ErrorActionPreference='Stop'\n& 'C:/Program Files/nodejs/node.exe' \"$PSScriptRoot/refresh_model.js\"\nif($LASTEXITCODE -ne 0){throw 'Production controller refresh failed'}"));
// Real production T80/video reproducer; source remains identical except width
// and expected restored mapping/history, plus full-history verification.
let cpu=read(prior,'cpu_tb.sv').replaceAll('wire [95:0] evolution_out','wire [159:0] evolution_out').replaceAll('wire [95:0] evolution_in','wire [159:0] evolution_in').replace('assign evolution_out=extra[95:0]','assign evolution_out=extra');
cpu=cpu.replace("(stage>=2&&data!==8'h48)","(stage>=2&&data!==8'h28)").replace("wait(guest_data==8'h48)","wait(first_after&&guest_data==8'h28)").replace("if(previous!==0||", "if(previous!==16'h2800||").replace('before28 restored48','before28 restored28');
// Model the external ordinary/turbo CPU CE choice: it remains current across
// LOAD, unlike guest menu port latches. Both divisors match the existing CPU
// fixture / production clock-enable ratio; video CE is unaffected.
cpu=cpu.replace('module cpu_tb;','module cpu_tb;\nreg host_turbo=0;').replace('cpu_ce=cycle%15==0','cpu_ce=cycle%(host_turbo?10:15)==0');
cpu=cpu.replace('stage=1;repeat(300)tick;','host_turbo=1;stage=1;repeat(300)tick;');
cpu=cpu.replace('if(previous!==16\'h2800||','if(host_turbo!==1||previous!==16\'h2800||').replace('previous=%h",accepts','previous=%h hostTurboB=1",accepts');
write('cpu_tb.sv',cpu);for(const n of ['T80_sim.vhd','T80s_sim.vhd','cpu.do','guest_bytes.json'])write(n,read(prior,n));
console.log('Prepared F14 baseline and isolated current v10 tests/adapters.');
