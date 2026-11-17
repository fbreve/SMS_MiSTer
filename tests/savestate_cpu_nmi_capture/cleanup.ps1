$ErrorActionPreference='Stop'
$taskRoot=[IO.Path]::GetFullPath($PSScriptRoot)
function RemoveGenerated([string]$candidate){
 $absolute=[IO.Path]::GetFullPath($candidate)
 if(-not $absolute.StartsWith($taskRoot+[IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase)){throw "Outside capture investigation: $absolute"}
 Remove-Item -LiteralPath $absolute -Recurse -Force
}
# Use after all simulation runners finish; never touch earlier evidence folders.
$libraries=Get-ChildItem -LiteralPath $taskRoot -Recurse -Directory | Where-Object {$_.Name -like '*work'}
foreach($item in $libraries){RemoveGenerated $item.FullName}
foreach($item in Get-ChildItem -LiteralPath $taskRoot -Recurse -File){
 if($item.Name -match '\.wlf$|\.transcript$|\.tmp$|\.sim\.do$|^pilot_[ab]\.(compile\.)?log$' -or $item.Name -eq 'transcript'){RemoveGenerated $item.FullName}
}
Write-Output 'Removed this task''s transient simulator artifacts; canonical evidence retained.'
