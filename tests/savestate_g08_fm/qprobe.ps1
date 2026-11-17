param([ValidateSet('baseline','candidate')][string]$Variant='candidate',[int]$Phase=70,[int]$Skew=0,[int]$FMOnly=1,[int]$Stall=0,[int]$N=6000,[int]$Replays=1,[int]$Stereo=0,[int]$Program=0,[int]$Seed=1,[int]$History=0,[int]$Converge=0,[switch]$Compile,[switch]$ReuseReference,[switch]$FullFlush,[string]$CaseName='')
$ErrorActionPreference='Stop';$bin='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem';$lib='qprobe_work'
if($Compile){Push-Location $PSScriptRoot;try{& "$bin/vsim.exe" -c -do "do qprobe_compile.do" -l "qprobe_compile.log" *> "qprobe_compile_stdout.log";if((Get-Content "qprobe_compile.log" -Raw) -match '\*\* (Error|Fatal|Failure):|Errors: [1-9]'){throw 'Known compile failed'}}finally{Pop-Location}}
if(-not $CaseName){$CaseName="$($Variant)_p$($Phase)_s$($Skew)_fm$($FMOnly)_stall$Stall"}
$folder=Join-Path $PSScriptRoot $CaseName;New-Item -ItemType Directory -Force $folder|Out-Null;Copy-Item "$PSScriptRoot/rom.hex" $folder
Push-Location $folder
try {
 if(-not(Test-Path modelsim.ini)){& "$bin/vmap.exe" -c *> vmap.log};& "$bin/vmap.exe" $lib "../$lib" *>> vmap.log;& "$bin/vmap.exe" original_work ../original_work *>> vmap.log
 $env:PHASE="$Phase";$env:RESET_SKEW="$Skew";$env:FM_ONLY="$FMOnly";$env:STALL="$Stall";$env:N="$N";$env:REPLAYS="$Replays";$env:STEREO="$Stereo";$env:PROGRAM="$Program";$env:RANDOMSEED="$Seed";$env:CONVERGE="$Converge";$env:HISTORY="$History"
 $env:TB_FAST=if($FullFlush){'0'}else{'1'}
 $runs=if($ReuseReference){@(0)}else{@(1,0)}
 foreach($ref in $runs){
  $env:REF="$ref";$label=if($ref){'reference'}else{'replay'}
  & "$bin/vsim.exe" -c -do "do ../qprobe_run.do" -l "$label.log" *> "$($label)_stdout.log"
  $s=Get-Content "$label.log" -Raw
  if($s -notmatch 'Errors: 0' -or $s -match '\*\* (Error|Fatal|Failure):|Errors: [1-9]' -or $s -notmatch 'PASS (REFERENCE|G08FM)'){throw "$CaseName $label failed"}
  Write-Output "PASS $CaseName $label"
 }
}finally{Pop-Location}
