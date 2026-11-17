param([int]$First=1,[int]$Last=16)
$ErrorActionPreference='Stop'
$decision=Get-Content "$PSScriptRoot/early_results.json" -Raw|ConvertFrom-Json
if($decision.classification -notin @('FITS COMFORTABLY','FITS BUT REQUIRES CAUTION')){throw 'Resource gate blocks full regression'}
$sim='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe'
foreach($seed in $First..$Last){
 $caseDir=Join-Path $PSScriptRoot "random_$seed";New-Item -ItemType Directory -Force -Path $caseDir|Out-Null
 Copy-Item -LiteralPath "$PSScriptRoot/rom.hex" -Destination "$caseDir/rom.hex"
 $taskIni=Get-Content "$PSScriptRoot/../savestate_f01_opll_architecture/modelsim.ini" -Raw
 foreach($library in @('work_random','original_work')){$taskIni=$taskIni.Replace('[Library]',("[Library]`n$library = "+$PSScriptRoot.Replace('\','/')+'/'+$library))}
 Set-Content -LiteralPath "$caseDir/modelsim.ini" -Value $taskIni
 Push-Location $caseDir
 try{
  $env:RANDOMSEED="$seed";$env:STALL="$($seed%3)"
  foreach($reference in @('1','0')){
   $env:REF=$reference;$label=if($reference -eq '1'){'reference'}else{'replay'}
   & $sim -c -do 'do ../random_run.do' -l "$label.log" *> "$label`_stdout.log"
   $marker=if($reference -eq '1'){'PASS REFERENCE'}else{'PASS F01'}
   if($LASTEXITCODE -or !(Select-String -Quiet -Pattern $marker "$label.log") -or (Select-String -Quiet -Pattern '\*\* (Fatal|Failure|Error):' "$label.log")){throw "Random seed$seed $label failed"}
  }
  if(@(Select-String -Pattern 'FM_RESULT pass[0-3] errors0 first-1' replay.log).Count -ne 4){throw "Random seed$seed incomplete"}
 }finally{Pop-Location}
 Write-Output "PASS random seed$seed SAVE + three LOADs 192000 FM host samples"
}
