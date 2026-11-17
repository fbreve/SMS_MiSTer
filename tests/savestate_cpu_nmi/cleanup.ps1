$ErrorActionPreference='Stop'
$taskRoot=[IO.Path]::GetFullPath($PSScriptRoot)
function RemoveGenerated([string]$candidate){
 $absolute=[IO.Path]::GetFullPath($candidate)
 if(-not $absolute.StartsWith($taskRoot+[IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase)){throw "Outside investigation folder: $absolute"}
 Remove-Item -LiteralPath $absolute -Recurse -Force
}
# Run only after the simulation runners finish. Preserve all canonical logs,
# adapters, source fixtures, reports, manifests and snapshot images.
$libraries=Get-ChildItem -LiteralPath $taskRoot -Directory -Recurse | Where-Object {$_.Name -like '*work'}
foreach($item in $libraries){RemoveGenerated $item.FullName}
$files=Get-ChildItem -LiteralPath $taskRoot -File -Recurse
foreach($item in $files){
 $n=$item.Name
 if($n -match '\.wlf$|\.transcript$|\.tmp$|\.sim\.do$' -or $n -eq 'transcript' -or
    $n -match '^(s[01]_p.*\.(log|do)|pilot.*\.(log|do)|proof_pending.*\.(log|do)|batch[0-2]\.(out|err)|snapshot\.hex)$'){
  RemoveGenerated $item.FullName
 }
}
Write-Output 'Removed own temporary ModelSim libraries/waves and discarded preliminary runs.'
