param([int]$Shard=0,[int]$Shards=3)
$ErrorActionPreference='Stop';$n=0
foreach($mode in @(1,2)){foreach($saved in @(0,1)){foreach($current in @(0,1)){
 if($n%$Shards -eq $Shard){
  if($mode -eq 2 -and $saved -eq 1 -and $current -eq 0 -and (Test-Path (Join-Path $PSScriptRoot 'pause/m2_s1_c0_d8/simulation.log')) -and (Get-Content -Raw (Join-Path $PSScriptRoot 'pause/m2_s1_c0_d8/simulation.log')) -match 'PASS G11 PAUSE'){Write-Output 'Reuse completed canonical Sega saved-paused/current-running witness'}
  else{& (Join-Path $PSScriptRoot run_pause.ps1) -Mode $mode -SavedPaused $saved -CurrentPaused $current -Delay 8 -N 24000}
 }
 $n++
}}}
