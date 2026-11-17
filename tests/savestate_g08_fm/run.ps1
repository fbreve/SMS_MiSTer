param([int]$Phase=70,[int]$Skew=0,[int]$FMOnly=1,[int]$Stall=0,[switch]$Compile)
$ErrorActionPreference='Stop';$bin='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem'
if($Compile){Push-Location $PSScriptRoot;try{& "$bin/vsim.exe" -c -do 'do compile.do' -l compile.log *> compile_stdout.log;if((Get-Content compile.log -Raw) -match '\*\* (Error|Fatal|Failure):|Errors: [1-9]'){throw 'Compile failed'}}finally{Pop-Location}}
$case="p$($Phase)_s$($Skew)_fm$($FMOnly)_stall$Stall";$folder=Join-Path $PSScriptRoot $case
New-Item -ItemType Directory -Force $folder|Out-Null;Copy-Item "$PSScriptRoot/rom.hex" $folder
Push-Location $folder
try{
 if(-not(Test-Path modelsim.ini)){& "$bin/vmap.exe" -c *> vmap.log}; & "$bin/vmap.exe" fm_work ../fm_work *>> vmap.log;& "$bin/vmap.exe" original_work ../original_work *>> vmap.log
 $env:PHASE="$Phase";$env:RESET_SKEW="$Skew";$env:FM_ONLY="$FMOnly";$env:STALL="$Stall"
 foreach($ref in @(1,0)){
  $env:REF="$ref";$label=if($ref){'reference'}else{'replay'}
  & "$bin/vsim.exe" -c -do 'do ../run.do' -l "$label.log" *> "$($label)_stdout.log"
  $s=Get-Content "$label.log" -Raw
  if($s -notmatch 'Errors: 0' -or $s -match '\*\* (Error|Fatal|Failure):|Errors: [1-9]' -or $s -notmatch 'PASS (REFERENCE|G08FM)'){throw "$case $label failed"}
  Write-Output "PASS $case $label"
 }
}finally{Pop-Location}
