param([int]$First=0,[int]$Last=8,[string]$Prefix='')
$ErrorActionPreference='Stop'
$sim='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe'
foreach($case in $First..$Last){
 $name=if($case -eq 0){'case0_final'}else{"case$case"}
 $caseDir=Join-Path $PSScriptRoot ($Prefix+$name)
 New-Item -ItemType Directory -Force -Path $caseDir | Out-Null
 Copy-Item -LiteralPath "$PSScriptRoot/../savestate_f01_opll_architecture/case$case/reference.dat" -Destination "$caseDir/reference.dat"
 Copy-Item -LiteralPath "$PSScriptRoot/rom.hex" -Destination "$caseDir/rom.hex"
 $taskIni=(Get-Content "$PSScriptRoot/../savestate_f01_opll_architecture/modelsim.ini" -Raw).Replace('[Library]',("[Library]`nwork_v17 = "+$PSScriptRoot.Replace('\','/')+'/work_v17'))
 Set-Content -LiteralPath "$caseDir/modelsim.ini" -Value $taskIni
 Push-Location $caseDir
 try {
  $env:FMCASE="$case";$env:HISTORY='0';$env:REF='0';$env:STALL='0'
  & $sim -c -do 'do ../run.do' -l replay.log *> replay_stdout.log
  if($LASTEXITCODE -ne 0 -or !(Select-String -Quiet -Pattern 'PASS F01' replay.log) -or (Select-String -Quiet -Pattern '\*\* (Fatal|Failure|Error):' replay.log)){throw "F01 case$case failed"}
  $good=@(Select-String -Pattern 'FM_RESULT pass[0-3] errors0 first-1' replay.log).Count
  if($good -ne 4){throw "Incomplete raw FM comparison case$case"}
 } finally {Pop-Location}
 Write-Output "PASS F01 case$case SAVE + three LOADs, 80000 raw-FM host clocks"
}
