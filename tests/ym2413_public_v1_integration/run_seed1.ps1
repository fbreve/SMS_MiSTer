$ErrorActionPreference='Stop'
[Diagnostics.Process]::GetCurrentProcess().PriorityClass='Idle'
$root=$PSScriptRoot
$seed=Join-Path $root 'quartus_seed1'
$varRoot=Join-Path $seed 'v1'
$qbin='C:/intelFPGA_lite/17.0/quartus/bin64'
$lock=[IO.File]::Open((Join-Path $seed 'runner.lock'),'OpenOrCreate','ReadWrite','None')
try {
 if(Get-Process quartus_map,quartus_fit,quartus_asm,quartus_sh -ErrorAction SilentlyContinue){throw 'Another Quartus compilation is active'}
 if(Test-Path "$varRoot/build.failed"){throw 'Inspect existing failure before resume'}
 if(Test-Path "$varRoot/build.done"){throw 'Build already complete; no artifacts overwritten'}
 if(Test-Path W:/){throw 'W: occupied'}
 & subst.exe W: $seed
 if($LASTEXITCODE){throw 'subst failed'}
 try {
  Push-Location W:/v1
  try {
   foreach($stage in @('map','fit','asm','sta','queries')){
    if(Test-Path "$stage.done"){
     node "$seed/stage_evidence.js" verify $varRoot $stage
     if($LASTEXITCODE){throw 'Stage hash verification failed'}
     continue
    }
    if((Test-Path "$stage.log") -or ($stage -eq 'queries' -and (Test-Path settings.log))){throw "Incomplete prior stage $stage; preserve and inspect before resume"}
    "START seed=1 public_v1 stage=$stage $(Get-Date -Format o)" | Add-Content "$seed/workflow.log"
    $ErrorActionPreference='Continue'
    if($stage -eq 'queries'){
     & "$qbin/quartus_sh.exe" -t W:/settings.tcl W:/v1 *> settings.log
     $code=$LASTEXITCODE
     if($code -eq 0){& "$qbin/quartus_sta.exe" -t W:/paths.tcl W:/v1/SMS *> paths.log; $code=$LASTEXITCODE}
    } elseif($stage -eq 'sta'){
     & "$qbin/quartus_sta.exe" W:/v1/SMS *> sta.log
     $code=$LASTEXITCODE
    } else {
     & "$qbin/quartus_$stage.exe" --read_settings_files=on --write_settings_files=off W:/v1/SMS *> "$stage.log"
     $code=$LASTEXITCODE
    }
    $ErrorActionPreference='Stop'
    "END seed=1 public_v1 stage=$stage exit=$code $(Get-Date -Format o)" | Add-Content "$seed/workflow.log"
    if($code -ne 0){throw "Tool failure stage=$stage exit=$code"}
    node "$seed/stage_evidence.js" seal $varRoot $stage
    if($LASTEXITCODE){throw "Incomplete reports stage=$stage"}
    if($stage -in @('map','fit')){
     node "$root/memory_gate.js" $stage
     if($LASTEXITCODE){throw "STOP memory inference regression stage=$stage"}
    }
    Write-Output "PASS $stage"
   }
   "COMPLETE $(Get-Date -Format o)" | Set-Content build.done
   node "$root/collect_seed1.js"
   if($LASTEXITCODE){throw 'STOP timing, memory or integrity regression; inspect preserved results'}
   Write-Output 'PUBLIC V1 SEED 1 COMPLETE; NO OTHER SEEDS REQUESTED'
  } finally {Pop-Location}
 } catch {
  $_ | Out-String | Set-Content "$varRoot/build.failed"
  throw
 } finally {& subst.exe W: /D}
} finally {$lock.Dispose()}
