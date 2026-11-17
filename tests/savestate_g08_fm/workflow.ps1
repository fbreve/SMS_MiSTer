$ErrorActionPreference='Stop'
function Verified([string]$path,[string]$marker){
 if(-not(Test-Path $path)){return $false}
 $s=Get-Content $path -Raw
 if($s -match '\*\* (Error|Fatal|Failure):|Errors: [1-9]'){throw "Simulation failure: $path"}
 return ($s -match [regex]::Escape($marker) -and $s -match 'Errors: 0')
}
Push-Location $PSScriptRoot
try {
 $directed=@()
 for($p=0;$p -lt 72;$p++){foreach($s in 0,1){$directed+="sweep_p$($p)_s$s"}}
 $directed+=@('directed70_left_fm','directed70_right_fm','directed70_left_mixed','directed70_right_mixed','directed70_native10_left','directed70_native10_right','turbo70_left','turbo70_right','hidden_fm_systeme','production_full_flush','long_fm','long_mixed','perturbation_probe','equal_candidate_h0','equal_candidate_h1','actual_silent_left','actual_silent_right')
 $directed+='beam_candidate'
 $directed+='beam_reset_candidate'
 while($true){
  $complete=@($directed|Where-Object {Verified "$_/replay.log" 'PASS G08FM'})
  if($complete.Count -eq $directed.Count){break}
  Write-Output "WAIT directed $($complete.Count)/$($directed.Count) $(Get-Date -Format o)"
  Start-Sleep -Seconds 30
 }
 @{passed=$true;cases=$directed;completed=(Get-Date -Format o)}|ConvertTo-Json -Depth 4|Set-Content directed_gate.json
 Write-Output 'PASS DIRECTED GATE; START RANDOMIZED CAPTURE'
 $workers=@()
 for($w=0;$w -lt 8;$w++){
  $auditWorker=Start-Process -FilePath powershell.exe -ArgumentList @('-NoProfile','-ExecutionPolicy','Bypass','-File',"$PSScriptRoot/random_campaign.ps1",'-Worker',"$w",'-Workers','8') -WindowStyle Hidden -PassThru -RedirectStandardOutput "$PSScriptRoot/random_worker$w.log" -RedirectStandardError "$PSScriptRoot/random_worker$($w)_stderr.log"
  $null=$auditWorker.Handle
  $workers+=$auditWorker
 }
 while(@($workers|Where-Object {-not $_.HasExited}).Count){Start-Sleep -Seconds 30}
 foreach($worker in $workers){$worker.WaitForExit();if($worker.ExitCode -ne 0){throw "Random worker failed $($worker.Id): exit=$($worker.ExitCode)"}}
 Write-Output 'PASS RANDOMIZED WORKERS'
 $prereq=@(@('format/simulation.log','PASS V19 FORMAT'),@('imports/simulation.log','PASS'),@('psg/simulation.log','PASS'),@('release_original/stall0.log','PASS CHARACTERIZED'),@('release_original/stall1.log','PASS CHARACTERIZED'))
 for($seed=1;$seed -le 16;$seed++){$prereq+=,@("f01/random_$seed/replay.log",'PASS F01')}
 foreach($row in (Get-Content release_manifest.json -Raw|ConvertFrom-Json)){$prereq+=,@("$($row.family)/$($row.id)/replay.log",'PASS MATRIX')}
 while($true){
  $complete=@($prereq|Where-Object {Verified $_[0] $_[1]})
  if($complete.Count -eq $prereq.Count){break}
  Write-Output "WAIT regressions $($complete.Count)/$($prereq.Count) $(Get-Date -Format o)"
  Start-Sleep -Seconds 30
 }
 Push-Location ../..
 try {
  node tests/savestate_g08_fm/collect_functional.js *> tests/savestate_g08_fm/functional_gate.log
  if($LASTEXITCODE){throw 'Functional collector rejected gate'}
  Write-Output 'PASS FUNCTIONAL GATE'
  node tests/savestate_g08_fm/prepare_build.js early
  if($LASTEXITCODE){throw 'Controlled build preparation rejected'}
  & ./tests/savestate_g08_fm/build.ps1 -Name early
  node tests/savestate_g08_fm/collect_build.js early *> tests/savestate_g08_fm/collect_build.log
  if($LASTEXITCODE){throw 'Build collector rejected'}
  & ./tests/savestate_g08_fm/analyze_paths.ps1 -Name early
  Write-Output 'PASS CONTROLLED BUILD; RESOURCE/TIMING REVIEW REQUIRED'
 }finally{Pop-Location}
}finally{Pop-Location}
