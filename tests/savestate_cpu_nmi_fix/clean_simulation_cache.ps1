$ErrorActionPreference='Stop'
$taskRoot=(Resolve-Path $PSScriptRoot).Path
if(Get-Process vsim,vsimk -ErrorAction SilentlyContinue){throw 'Run after ModelSim has exited'}
$removed=@()
function Walk([string]$folder){
 foreach($entry in Get-ChildItem -LiteralPath $folder -Directory){
  if($entry.Name -in 'candidate','failed_overlap'){continue}
  $resolved=(Resolve-Path -LiteralPath $entry.FullName).Path
  if(-not $resolved.StartsWith($taskRoot+[IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase)){throw 'Cache outside intended task root'}
  if($entry.Name.EndsWith('_work') -and (Test-Path -LiteralPath (Join-Path $resolved '_info'))){
   $script:removed+=$resolved
   Remove-Item -LiteralPath $resolved -Recurse -Force
  }else{Walk $resolved}
 }
 foreach($file in Get-ChildItem -LiteralPath $folder -File -Filter '*.wlf'){
  $resolved=(Resolve-Path -LiteralPath $file.FullName).Path
  if(-not $resolved.StartsWith($taskRoot+[IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase)){throw 'Waveform outside intended task root'}
  $script:removed+=$resolved;Remove-Item -LiteralPath $resolved -Force
 }
}
Walk $taskRoot
$removed|ConvertTo-Json|Set-Content "$taskRoot/removed_simulation_cache.json"
Write-Output "Removed $($removed.Count) generated ModelSim cache/waveform paths; reports, logs, images and Quartus evidence retained."
