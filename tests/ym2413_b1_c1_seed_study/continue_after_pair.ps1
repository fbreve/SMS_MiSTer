param([string]$DriveLetter='W:')
$ErrorActionPreference='Stop'
[System.Diagnostics.Process]::GetCurrentProcess().PriorityClass='Idle'
$studyRoot=$PSScriptRoot
$done=Join-Path $studyRoot 'unattended.done'
$failed=Join-Path $studyRoot 'unattended.failed'
if((Test-Path $done) -or (Test-Path $failed)){throw 'Controller already finished; inspect preserved status'}
$watcher=New-Object IO.FileSystemWatcher
$watcher.Path=Join-Path $studyRoot 'seed1'
$watcher.IncludeSubdirectories=$true
$watcher.Filter='build.*'
try {
 # Wait for filesystem completion events; no process or log polling.
 while(!(Test-Path "$studyRoot/seed1/c1/build.done")){
  if((Test-Path "$studyRoot/seed1/b1/build.failed") -or (Test-Path "$studyRoot/seed1/c1/build.failed")){throw 'Seed-1 paired build failed; no remaining builds launched'}
  $null=$watcher.WaitForChanged([IO.WatcherChangeTypes]::All,60000)
 }
 # build.done precedes collector execution; wait for the paired runner to release its lock.
 $pairLock=$null
 while(!$pairLock){
  try {$pairLock=[IO.File]::Open((Join-Path $studyRoot 'runner.lock'),'Open','ReadWrite','None')}
  catch [IO.IOException] {Start-Sleep -Seconds 2}
 }
 try {
  foreach($variant in @('b1','c1')){
   if(Test-Path "$studyRoot/seed1/$variant/build.failed"){throw 'Seed-1 collection/evidence failure'}
   foreach($stage in @('map','fit','asm','sta','queries')){
    node "$studyRoot/stage_evidence.js" verify "$studyRoot/seed1/$variant" $stage
    if($LASTEXITCODE){throw 'Seed-1 stage evidence failed'}
   }
  }
  node "$studyRoot/collect_study.js"
  if($LASTEXITCODE){throw 'Seed-1 collection failed'}
  $firstHash=(Get-FileHash "$studyRoot/study_results.json" -Algorithm SHA256).Hash
  node "$studyRoot/collect_study.js"
  if($LASTEXITCODE){throw 'Seed-1 repeated collection failed'}
  if((Get-FileHash "$studyRoot/study_results.json" -Algorithm SHA256).Hash -ne $firstHash){throw 'Seed-1 collector is not deterministic'}
  $results=Get-Content "$studyRoot/study_results.json" -Raw | ConvertFrom-Json
  if(!$results.seeds[0].b1.complete -or !$results.seeds[0].c1.complete){throw 'Seed-1 pair is incomplete'}
  "PASS paired seed=1 stage hashes verified; repeated collection identical SHA256=$firstHash $(Get-Date -Format o)" | Set-Content "$studyRoot/paired_seed1_verified.txt"
 } finally {$pairLock.Dispose()}
 & "$studyRoot/run_fitter_study.ps1" -Seeds @(2,3) -DriveLetter $DriveLetter
 node "$studyRoot/collect_study.js"
 if($LASTEXITCODE){throw 'Final collection failed'}
 $results=Get-Content "$studyRoot/study_results.json" -Raw | ConvertFrom-Json
 if(!$results.allComplete){throw 'Final results incomplete'}
 "COMPLETE $(Get-Date -Format o)" | Set-Content $done
} catch {
 $_ | Out-String | Set-Content $failed
 throw
} finally {$watcher.Dispose()}
