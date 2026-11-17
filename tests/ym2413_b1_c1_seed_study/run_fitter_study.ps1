param(
 [ValidateSet(1,2,3)][int[]]$Seeds = @(1,2,3),
 [ValidateSet('b1','c1')][string[]]$Variants = @('b1','c1'),
 [ValidatePattern('^[A-Z]:$')][string]$DriveLetter = 'W:'
)
$ErrorActionPreference='Stop'
[System.Diagnostics.Process]::GetCurrentProcess().PriorityClass='Idle'
$studyRoot=$PSScriptRoot
$qbin='C:/intelFPGA_lite/17.0/quartus/bin64'
$workflowLog=Join-Path $studyRoot 'workflow.log'
$lock=[IO.File]::Open((Join-Path $studyRoot 'runner.lock'),'OpenOrCreate','ReadWrite','None')
try {
 if(Get-Process quartus_map,quartus_fit,quartus_asm,quartus_sh -ErrorAction SilentlyContinue){throw 'Another Quartus compilation is active'}
 node (Join-Path $studyRoot 'prepare_study.js')
 if($LASTEXITCODE){throw 'Input preparation/verification failed'}
 foreach($seed in $Seeds){foreach($variant in $Variants){
  $seedRoot=Join-Path $studyRoot "seed$seed"
  $varRoot=Join-Path $seedRoot $variant
  $doneMarker=Join-Path $varRoot 'build.done'
  $failMarker=Join-Path $varRoot 'build.failed'
  if(Test-Path $failMarker){throw "Existing failure: $failMarker; inspect before resume"}
  if(Test-Path "$DriveLetter/"){throw "$DriveLetter is occupied"}
  & subst.exe $DriveLetter $seedRoot
  if($LASTEXITCODE){throw 'subst failed'}
  try {
   Push-Location "$DriveLetter/$variant"
   try {
    foreach($stage in @('map','fit','asm','sta','queries')){
     $marker=Join-Path $varRoot "$stage.done"
     if(Test-Path $marker){
      node (Join-Path $studyRoot 'stage_evidence.js') verify $varRoot $stage
      if($LASTEXITCODE){throw "Completed evidence invalid: $marker"}
      Write-Output "SKIP seed=$seed variant=$variant stage=$stage"
      continue
     }
     if(Test-Path $doneMarker){throw 'build.done exists with incomplete stage evidence'}
     # Snapshot every artifact from an interrupted attempt, including databases.
     if((Test-Path "$stage.log") -or ($stage -eq 'queries' -and (Test-Path 'settings.log'))){
      $archive=Join-Path $seedRoot ("interrupted_${variant}_${stage}_"+[guid]::NewGuid().ToString('N'))
      Copy-Item -LiteralPath $varRoot -Destination $archive -Recurse
      "ARCHIVE $archive" | Add-Content $workflowLog
     }
     "START seed=$seed variant=$variant stage=$stage $(Get-Date -Format o)" | Add-Content $workflowLog
     $ErrorActionPreference='Continue'
     if($stage -eq 'queries'){
      & "$qbin/quartus_sh.exe" -t "$DriveLetter/settings.tcl" "$DriveLetter/$variant" *> settings.log
      $code=$LASTEXITCODE
      if($code -eq 0){
       & "$qbin/quartus_sta.exe" -t "$DriveLetter/paths.tcl" "$DriveLetter/$variant/SMS" *> paths.log
       $code=$LASTEXITCODE
      }
     } elseif($stage -eq 'sta'){
      & "$qbin/quartus_sta.exe" "$DriveLetter/$variant/SMS" *> "$stage.log"
      $code=$LASTEXITCODE
     } else {
      & "$qbin/quartus_$stage.exe" --read_settings_files=on --write_settings_files=off "$DriveLetter/$variant/SMS" *> "$stage.log"
      $code=$LASTEXITCODE
     }
     $ErrorActionPreference='Stop'
     "END seed=$seed variant=$variant stage=$stage exit=$code $(Get-Date -Format o)" | Add-Content $workflowLog
     if($code -ne 0){throw "Tool failure stage=$stage exit=$code"}
     node (Join-Path $studyRoot 'stage_evidence.js') seal $varRoot $stage
     if($LASTEXITCODE){throw "Incomplete stage artifacts: $stage"}
     Write-Output "PASS seed=$seed variant=$variant stage=$stage"
    }
    if(!(Test-Path $doneMarker)){"COMPLETE $(Get-Date -Format o)" | Set-Content $doneMarker}
    node (Join-Path $studyRoot 'collect_study.js')
    if($LASTEXITCODE){throw 'Collection failed; stop before next build'}
    Write-Output "COMPLETE seed=$seed variant=$variant"
   } finally {Pop-Location}
  } catch {
   if(!(Test-Path $failMarker)){$_ | Out-String | Set-Content $failMarker}
   throw
  } finally {& subst.exe $DriveLetter /D}
 }}
 Write-Output 'ALL REQUESTED BUILDS COMPLETE'
} finally {$lock.Dispose()}
