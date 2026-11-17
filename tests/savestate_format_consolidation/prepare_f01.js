const fs=require('fs'),p=require('path'),d=__dirname,src=p.join(d,'../savestate_f01_opll_fix'),adapter=require('../savestate_g06_g10_fix/controller_adapter');
for(const file of ['random_tb.sv','audio_tb.sv','pause_fixture.sv','T80_sim.vhd','T80s_sim.vhd','opll_reference.vhd','rom.hex','random_run.do'])fs.copyFileSync(p.join(src,file),p.join(d,file));
fs.cpSync(p.join(src,'sim_opll'),p.join(d,'sim_opll'),{recursive:true});
fs.writeFileSync(p.join(d,'savestates_sim.sv'),adapter(p.join(d,'candidate/rtl/savestates.sv')));
let compile=fs.readFileSync(p.join(src,'random_compile.do'),'utf8');
const orig=p.join(d,'../savestate_f01_opll_architecture/sim_opll');
compile=compile.replace('vlib work_random','vlib work_random\nvlib original_work\nvcom -work original_work -2008 -quiet '+fs.readdirSync(orig).filter(f=>f.endsWith('.vhd')).sort((a,b)=>{const order=['vm2413','slotcounter','voicerom','voicememory','registermemory','attacktable','envelopememory','envelopegenerator','phasememory','phasegenerator','sinetable','operator','feedbackmemory','outputmemory','lineartable','outputgenerator','temporalmixer','controller','opll'];return order.indexOf(p.parse(a).name)-order.indexOf(p.parse(b).name);}).map(f=>'../savestate_f01_opll_architecture/sim_opll/'+f).join(' '));
fs.writeFileSync(p.join(d,'random_compile.do'),compile);
for(const seed of [1,10]){const dst=p.join(d,'random_'+seed);fs.mkdirSync(dst,{recursive:true});for(const f of ['reference.dat','rom.hex'])fs.copyFileSync(p.join(src,'random_'+seed,f),p.join(dst,f));}
fs.writeFileSync(p.join(d,'run_f01.ps1'),`$ErrorActionPreference='Stop'
$bin='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem'
Push-Location $PSScriptRoot
try {
 & "$bin/vsim.exe" -c -do 'do random_compile.do' -l random_compile.log *> random_compile_stdout.log
 if($LASTEXITCODE -or (Get-Content random_compile.log -Raw) -match '\\*\\* (Error|Fatal|Failure):|Errors: [1-9]'){throw 'F01 compile failed'}
 foreach($seed in @(1,10)){
  Push-Location "random_$seed"
  try{
   if(-not(Test-Path modelsim.ini)){& "$bin/vmap.exe" -c *> vmap.log}
   & "$bin/vmap.exe" work_random ../work_random *>> vmap.log
   & "$bin/vmap.exe" original_work ../original_work *>> vmap.log
   $env:RANDOMSEED="$seed";$env:REF='0';$env:STALL='1'
   & "$bin/vsim.exe" -c -do 'do ../random_run.do' -l replay.log *> replay_stdout.log
   $s=Get-Content replay.log -Raw
   if($LASTEXITCODE -or $s -notmatch 'PASS F01' -or $s -match '\\*\\* (Error|Fatal|Failure):|Errors: [1-9]'){throw "F01 seed $seed failed"}
   Write-Output "PASS F01 seed $seed"
  }finally{Pop-Location}
 }
}finally{Pop-Location}
`);
