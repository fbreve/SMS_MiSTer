$ErrorActionPreference='Stop'
[System.Diagnostics.Process]::GetCurrentProcess().PriorityClass = [System.Diagnostics.ProcessPriorityClass]::Idle
Set-Location $PSScriptRoot
$ghdl=(Resolve-Path ../../../tools/ghdl6/bin/ghdl.exe).Path
$names=@('vm2413','slotcounter','voicerom','voicememory','registermemory','attacktable','envelopememory','envelopegenerator','phasememory','phasegenerator','sinetable','operator','feedbackmemory','outputmemory','lineartable','outputgenerator','temporalmixer','controller','opll')
foreach($lib in @('candidate','reference')){
 $dir="ghdl_$lib";if(Test-Path $dir){throw 'Refuse existing native compilation'};New-Item -ItemType Directory $dir | Out-Null
 foreach($name in $names){& $ghdl -a --std=08 -fsynopsys -fexplicit --work="${lib}_work" --workdir=$dir "native_$lib/$name.vhd";if($LASTEXITCODE){throw "Compile failed $lib/$name"}}
 & $ghdl -a --std=08 -fsynopsys -fexplicit --work="${lib}_work" --workdir=$dir "${lib}_wrapper.vhd";if($LASTEXITCODE){throw 'Wrapper compile failed'}
}
& $ghdl -a --std=08 -fsynopsys -fexplicit --work=candidate_work --workdir=ghdl_candidate -Pghdl_reference ../../rtl/video.vhd acc_native_tb.vhd
if($LASTEXITCODE){throw 'Bench compile failed'}
& $ghdl --version
