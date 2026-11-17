param([int]$First=0,[int]$Last=71)
$ErrorActionPreference='Stop'
$sim='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe'
foreach($phase in $First..$Last){
 $caseDir=Join-Path $PSScriptRoot "phase_$phase";New-Item -ItemType Directory -Force -Path $caseDir | Out-Null
 $taskIni=(Get-Content "$PSScriptRoot/../savestate_f01_opll_architecture/modelsim.ini" -Raw)
 foreach($library in @('phase_work','local_work','original_work')){$taskIni=$taskIni.Replace('[Library]',("[Library]`n$library = "+$PSScriptRoot.Replace('\','/')+'/'+$library))}
 Set-Content -LiteralPath "$caseDir/modelsim.ini" -Value $taskIni
 Push-Location $caseDir
 try{
  $env:SHIFT="$phase";$env:STALL="$(($phase*7)%19)"
  & $sim -c -do 'do ../phase_run.do' -l replay.log *> replay_stdout.log
  if($LASTEXITCODE -ne 0 -or !(Select-String -Quiet -Pattern 'PASS LOCAL ALL' replay.log) -or (Select-String -Quiet -Pattern '\*\* (Fatal|Failure|Error):' replay.log)){throw "Phase failure $phase"}
 }finally{Pop-Location}
 Write-Output "PASS scalar/array roundtrip, FM SAVE and three LOADs phase$phase"
}
